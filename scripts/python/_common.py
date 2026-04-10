# _common.py
# Shared setup imported by every Python chapter in the WECA regional
# indicators report. Mirrors the role of scripts/R/_common.R.
#
# Usage — add this to the setup cell of any Python chapter:
#
#   import sys
#   from pathlib import Path
#   sys.path.insert(0, str(Path.cwd()))   # ensure project root is on path
#
#   from scripts.python._common import *  # noqa: F401,F403

from scripts.python.helpers import (  # noqa: F401
    check_missing,
    format_number,
    load_csv,
    pct_change,
    safe_divide,
)
from scripts.python.weca_theme import (  # noqa: F401
    UA_COLORS_BY_CODE,
    UA_COLORS_BY_NAME,
    WECA_COLORS,
    WECA_PALETTE,
    apply_weca_theme,
    get_weca_color,
    plotly_weca_layout,
)

# Apply WECA matplotlib theme immediately on import so all figures in the
# chapter are styled without any additional setup step.
apply_weca_theme()
