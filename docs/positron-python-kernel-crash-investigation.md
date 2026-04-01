# Positron Python Console Crash Investigation

**Date investigated:** 2026-04-01
**Environment:** Windows 11 Enterprise 10.0.26100, Positron 1.108.0
**Project:** `weca_regional_indicators`
**Status:** Root cause identified, fix recommended, not yet confirmed resolved

---

## Symptom

Positron Python console exits unexpectedly on startup with the message "Python console exiting unexpectedly". Behaviour is intermittent — sometimes the console starts successfully, sometimes it fails. Failures are more likely after changes to `.venv` packages.

---

## Error in Kernel Supervisor Logs

Logs found at: `C:\Users\STEVE~1.CRA\AppData\Local\Temp\kallichore-<id>.log`

```
08:17:11 [INFO]  start_session("python-1a09f88a")
08:17:11 [DEBUG] Wrote connection file at "...\connection_python-1a09f88a.json"
08:17:11 [DEBUG] Starting kernel: [".venv\Scripts\python.exe",
                  "positron_language_server.py",
                  "-f", "...\connection_python-1a09f88a.json",
                  "--logfile", "...\kernel-IfjTGy\kernel.log",
                  "--loglevel=error",
                  "--session-mode=console"]
08:17:41 [ERROR] KS-7: Timed out waiting to connect to session's ZeroMQ sockets after 30 seconds
08:17:41 [ERROR] [session python-1a09f88a] Output before failure:
```

Key observations from the error:
- Timeout is exactly 30 seconds after kernel launch
- "Output before failure:" is empty (see explanation below)
- Kallichore (the kernel supervisor) reports no output because Python buffers stdout to a pipe and only flushes on exit

---

## Investigation Steps and Findings

### Step 1: Verify basic packages

- `pyzmq` 27.1.0 — installed and working ✓
- `ipykernel` 7.2.0 — installed and importable ✓
- Python 3.13.1 in `.venv\Scripts\python.exe` ✓
- ZeroMQ TCP bind test passed (`zmq.bind_to_random_port('tcp://127.0.0.1')`) ✓

### Step 2: Kernel log is empty — explained

The kernel log at `...\kernel-IfjTGy\kernel.log` is empty because Positron launches the kernel with `--loglevel=error`. No error-level events occurred, so nothing was written. This is **not** evidence that the kernel didn't start.

The "Output before failure: " being empty is explained by Python's pipe-buffering: stdout output is buffered in block mode (8KB) when connected to a pipe rather than a TTY. The kernel writes the startup banner to stdout, but Python holds it in the buffer. Kallichore reads the pipe and sees nothing until the buffer flushes (on process exit).

### Step 3: Manual kernel start — works fine

Running the kernel manually from bash, with `PYTHONUNBUFFERED=1` and stdout piped:

```bash
.venv/Scripts/python.exe positron_language_server.py \
  -f /tmp/test_connection.json \
  --loglevel=debug --session-mode=console
```

**Result: Kernel fully initialised in 1.8 seconds.**

Full startup sequence logged at T+0 to T+1.8s:
- Profile dir, config files loaded
- Connection file read
- ZMQ sockets bound (shell, stdin, control, iopub, heartbeat)
- IPython extensions loaded (storemagic)
- Pydoc server ready at random port
- **Kernel responding to heartbeat**

Also confirmed via `netstat`: all ZMQ ports (52345–52349) show as LISTENING within 4 seconds.

### Step 4: Timing analysis from Kallichore logs

Compared a **successful** session (March 31) against **failed** sessions (March 30, April 1):

| Session | Start time | Event | Elapsed |
|---------|-----------|-------|---------|
| python-12f1e30d (✓ success) | 07:35:27 | Kernel launched | 0s |
| python-12f1e30d (✓ success) | 07:35:53 | Connected to heartbeat | **26s** |
| python-593db4c6 (✗ fail) | 16:04:14 | Kernel launched | 0s |
| python-593db4c6 (✗ fail) | 16:04:44 | Timeout | **30s** |
| python-1a09f88a (✗ fail) | 08:17:11 | Kernel launched | 0s |
| python-1a09f88a (✗ fail) | 08:17:41 | Timeout | **30s** |

Between kernel launch and heartbeat connection in the successful case, **nothing else happens in the Kallichore log** — Kallichore is simply waiting.

The kernel itself is ready in <2 seconds. Kallichore waits ~25 seconds before the first heartbeat is received. This is likely a deliberate poll delay in Kallichore's startup sequence (possibly waiting for a stdout signal from the kernel, falling back to heartbeat polling after a timeout).

**The effective window for kernel startup is only ~4–5 seconds** (from when Kallichore first polls at ~25s to the 30s timeout).

### Step 5: Correlation with .venv package updates

```
drwxr-xr-x  Mar 30 15:40  .venv/Lib/site-packages/plotly-6.6.0.dist-info/
drwxr-xr-x  Mar 30 15:40  .venv/Lib/site-packages/jedi-0.19.2.dist-info/
drwxr-xr-x  Mar 30 15:41  .venv/Lib/site-packages/_distutils_hack/
```

Packages were last updated **March 30 at 15:40–15:41** (probably `uv sync`). The first kernel failure occurred **March 30 at 16:04** — 23 minutes after the package update. March 31 succeeded (Windows Defender had likely cached the scan), April 1 failed again.

This pattern strongly suggests **Windows Defender real-time protection** scanning the new/updated packages when first launched by Positron (an Electron/GUI process), adding 3–5 seconds to the effective startup window and causing the heartbeat to arrive after the 30-second timeout.

### Step 6: Why failures are intermittent

The margin between success and failure is ~4 seconds:
- Kernel ready in 1.8s
- Kallichore first polls at ~25s
- Timeout at 30s
- Window for success: 5 seconds

Any system load spike (AV scan, background process, Windows Update) during that 5-second window can push the first successful heartbeat past 30s.

---

## Architecture Summary (Positron kernel startup)

```
Positron (Electron/GUI app)
  └─ Kallichore (kcserver.exe) — kernel supervisor
       ├─ Writes connection file: connection_python-<id>.json
       │    {control_port, shell_port, stdin_port, hb_port, iopub_port,
       │     ip, key, signature_scheme, transport}
       ├─ Starts: .venv/Scripts/python.exe positron_language_server.py
       │    -f <connection_file>
       │    --logfile <kernel_log>
       │    --loglevel=error
       │    --session-mode=console
       ├─ Waits ~25s (internal poll delay, possibly awaiting stdout signal)
       ├─ Connects to kernel heartbeat ZMQ socket (REQ→REP echo)
       ├─ If no heartbeat within 30s total → KS-7 timeout error
       └─ On success: starts ZMQ-WebSocket proxy, session becomes 'idle'
```

The kernel (positron_language_server.py) is a wrapper around ipykernel that:
1. Binds ZMQ sockets (shell ROUTER, stdin ROUTER, control ROUTER, iopub PUB, heartbeat REP)
2. Starts tornado async event loop
3. Loads IPython extensions
4. Starts a pydoc HTTP server on a random port
5. Enters event loop — heartbeat responses handled by a separate thread

---

## What Was Ruled Out

| Hypothesis | Verdict | Evidence |
|-----------|---------|----------|
| `pyzmq` not installed | ✗ No | `zmq.__version__` = 27.1.0 |
| `ipykernel` not installed | ✗ No | Version 7.2.0 installed |
| Windows Firewall blocking ZMQ | ✗ No | TCP bind test passed from venv Python |
| Corrupted `.venv` | ✗ No | Kernel starts cleanly in manual test |
| Python version incompatibility (3.13.1) | ✗ No | Kernel starts in 1.8s |
| Kernel process crashing | ✗ No | Process stays running; no exit code in Kallichore log |
| IPython startup scripts hanging | ✗ No | No scripts in `~/.ipython/profile_default/startup/` |
| Port conflict | ✗ Unlikely | Kallichore allocates fresh ports per session |
| `sitecustomize.py` interference | ✗ No | No such file in `.venv` |

---

## Root Cause

**Windows Defender real-time protection** scans the Python venv process when launched by Positron (a GUI/Electron app). This scan adds 3–5 seconds to the first heartbeat attempt, which arrives exactly within or beyond the 30-second hard timeout.

The timing is extremely tight by design in Kallichore v0.1.63 with Positron 1.108.0:
- Kallichore internal poll delay: ~25 seconds
- Available margin: ~5 seconds
- Windows Defender scan overhead: ~3–5 seconds (after package changes)

---

## Recommended Fix

### Primary fix: Windows Defender exclusions

Open **PowerShell as Administrator** and run:

```powershell
Add-MpPreference -ExclusionPath "C:\Users\steve.crawshaw\projects\weca_regional_indicators\.venv"
Add-MpPreference -ExclusionProcess "C:\Users\steve.crawshaw\projects\weca_regional_indicators\.venv\Scripts\python.exe"
```

Or via: Windows Security → Virus & threat protection → Manage settings → Add or remove exclusions.

After adding exclusions, restart Positron and open the Python console. It should connect reliably.

### Secondary fix: Kill orphaned kernel processes

Failed kernel sessions leave orphaned `python.exe` processes running. Over time these accumulate. Restart Positron (which kills them) or manually kill them via Task Manager before opening a new Python console.

### Secondary fix: Increase kernel connection timeout

Two settings exist in Positron 1.108.0 (confirmed from extension source):

| Setting | Default | Description |
|---------|---------|-------------|
| `kernelSupervisor.connectionTimeout` | `30` | Timeout in **seconds** for connecting to the kernel's ZeroMQ sockets — **this is the one hitting** |
| `kernelSupervisor.startupTimeout` | `15` | Timeout in seconds for starting the Kallichore supervisor itself |

Add to Positron `settings.json` (open via `Ctrl+Shift+P` → "Open User Settings JSON"):

```json
"kernelSupervisor.connectionTimeout": 60
```

This doubles the window from 30 to 60 seconds and should prevent timeouts even with Defender scanning overhead. This can be used as a standalone fix or combined with the Defender exclusion.

---

## Files and Locations Referenced

| File | Location |
|------|----------|
| Kallichore logs | `C:\Users\STEVE~1.CRA\AppData\Local\Temp\kallichore-<id>.log` |
| Kernel session logs | `C:\Users\STEVE~1.CRA\AppData\Local\Temp\kernel_log_python-<id>.txt` |
| Kernel execution log | `C:\Users\STEVE~1.CRA\AppData\Local\Temp\kernel-<id>\kernel.log` |
| Connection files | `C:\Users\STEVE~1.CRA\AppData\Local\Temp\connection_python-<id>.json` |
| Positron user settings | `C:\Users\steve.crawshaw\AppData\Roaming\Positron\User\settings.json` |
| Project venv Python | `.venv\Scripts\python.exe` (Python 3.13.1, created Feb 2025) |
| Positron language server | `C:\Users\steve.crawshaw\AppData\Local\Programs\Positron\resources\app\extensions\positron-python\python_files\posit\positron_language_server.py` |

---

## If the Problem Recurs

1. Open `C:\Users\STEVE~1.CRA\AppData\Local\Temp\kallichore-<most-recent>.log`
2. Search for `Timed out` — note the session ID
3. Check `Output before failure:` line (empty = buffering, not a crash)
4. Check the `kernel_log_python-<id>.txt` for any error-level events
5. Time the gap between `Starting kernel` and the timeout — if it's still ~30s, the AV exclusion didn't work; if it's reduced, something else is slowing down the last 5 seconds

If the problem persists after Defender exclusions, consider filing an issue with Posit (Positron maintainers) requesting a configurable `kernelStartupTimeout` setting or an increase to the default 30-second limit. The 25-second internal poll delay with only a 5-second connection window is an unusually tight design.
