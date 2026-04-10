# WECA Branding Theme for Python visualisations
#
# Provides the WECA colour palette and matplotlib/plotly styling.
# Usage:
#   from scripts.python.weca_theme import WECA_COLORS, apply_weca_theme, UA_COLORS_BY_NAME
#
# Example (matplotlib):
#   import matplotlib.pyplot as plt
#   from scripts.python.weca_theme import WECA_COLORS, apply_weca_theme
#
#   apply_weca_theme()
#   fig, axe = plt.subplots()
#   axe.plot(x, y, colour=WECA_COLORS["forest_green"])
#
# Example (plotly):
#   import plotly.graph_objects as go
#   from scripts.python.weca_theme import WECA_COLORS, plotly_weca_layout
#
#   fig = go.Figure(layout=plotly_weca_layout())

from __future__ import annotations

import matplotlib as mpl

# ---------------------------------------------------------------------------
# Colour palettes
# ---------------------------------------------------------------------------

WECA_COLORS: dict[str, str] = {
    "forest_green": "#1D4F2B",
    "claret": "#CE132D",
    "rich_purple": "#590075",
    "black": "#1F1F1F",
    "west_green": "#40A832",
    "park_green": "#007D00",
    "soft_green": "#8FCC87",
    "soft_purple": "#9C66AB",
    "soft_claret": "#ED8073",
}

UA_COLORS_BY_NAME: dict[str, str] = {
    "Bristol": "#CE132D",
    "South Gloucestershire": "#1D4F2B",
    "Bath and North East Somerset": "#590075",
    "North Somerset": "#1F1F1F",
}

UA_COLORS_BY_CODE: dict[str, str] = {
    "E06000023": "#CE132D",
    "E06000025": "#1D4F2B",
    "E06000022": "#590075",
    "E06000024": "#1F1F1F",
}

# Ordered list suitable for categorical charts
WECA_PALETTE: list[str] = list(WECA_COLORS.values())


def get_weca_color(name: str) -> str:
    """Return a single WECA colour hex code by name.

    Args:
        name: Colour name, e.g. "forest_green", "claret".

    Returns:
        Hex colour string, e.g. "#1D4F2B".

    Raises:
        KeyError: If the name is not in the WECA palette.
    """
    if name not in WECA_COLORS:
        available = ", ".join(WECA_COLORS)
        raise KeyError(f"Colour '{name}' not found. Available: {available}")
    return WECA_COLORS[name]


# ---------------------------------------------------------------------------
# Matplotlib theme
# ---------------------------------------------------------------------------

_WECA_RC: dict[str, object] = {
    # Figure
    "figure.facecolor": "white",
    "figure.dpi": 150,
    # Axes
    "axes.facecolor": "white",
    "axes.edgecolor": "#1F1F1F",
    "axes.linewidth": 0.8,
    "axes.grid": True,
    "axes.grid.axis": "y",
    "axes.prop_cycle": mpl.cycler(color=WECA_PALETTE),
    "axes.titlesize": 13,
    "axes.titleweight": "bold",
    "axes.titlecolor": WECA_COLORS["forest_green"],
    "axes.labelsize": 11,
    "axes.labelcolor": WECA_COLORS["black"],
    # Grid
    "grid.color": "#E5E5E5",
    "grid.linewidth": 0.5,
    # Ticks
    "xtick.color": WECA_COLORS["black"],
    "ytick.color": WECA_COLORS["black"],
    "xtick.labelsize": 10,
    "ytick.labelsize": 10,
    # Legend
    "legend.frameon": False,
    "legend.fontsize": 10,
    "legend.loc": "lower center",
    # Lines
    "lines.linewidth": 1.8,
    # Text
    "text.color": WECA_COLORS["black"],
    # Font — Arial is available on Linux via fonts-liberation; falls back to sans-serif
    "font.family": "sans-serif",
    "font.sans-serif": ["Arial", "Liberation Sans", "DejaVu Sans"],
}


def apply_weca_theme() -> None:
    """Apply WECA branding to all subsequent matplotlib figures.

    Call once at the top of a chapter or script before creating any plots.
    Settings persist for the duration of the Python session.

    Example:
        apply_weca_theme()
        fig, axe = plt.subplots()
        axe.plot(years, values)
    """
    mpl.rcParams.update(_WECA_RC)


def reset_theme() -> None:
    """Restore matplotlib defaults (undoes apply_weca_theme)."""
    mpl.rcParams.update(mpl.rcParamsDefault)


# ---------------------------------------------------------------------------
# Plotly theme
# ---------------------------------------------------------------------------

def plotly_weca_layout(**kwargs: object) -> dict:
    """Return a Plotly layout dict with WECA branding.

    Any keyword arguments are merged in and override the defaults, allowing
    per-chart customisation while keeping consistent branding.

    Example:
        import plotly.graph_objects as go
        fig = go.Figure(
            data=[go.Bar(x=areas, y=values)],
            layout=plotly_weca_layout(title_text="Housing completions"),
        )
    """
    layout: dict = {
        "font": {
            "family": "Arial, Liberation Sans, sans-serif",
            "color": WECA_COLORS["black"],
            "size": 12,
        },
        "title": {
            "font": {
                "color": WECA_COLORS["forest_green"],
                "size": 16,
                "family": "Arial, Liberation Sans, sans-serif",
            },
            "x": 0.0,
            "xanchor": "left",
        },
        "paper_bgcolor": "white",
        "plot_bgcolor": "white",
        "colorway": WECA_PALETTE,
        "legend": {
            "orientation": "h",
            "yanchor": "top",
            "y": -0.2,
            "xanchor": "left",
            "x": 0,
        },
        "xaxis": {
            "showgrid": False,
            "linecolor": WECA_COLORS["black"],
            "linewidth": 1,
            "ticks": "outside",
        },
        "yaxis": {
            "gridcolor": "#E5E5E5",
            "gridwidth": 0.5,
            "linecolor": WECA_COLORS["black"],
            "linewidth": 1,
        },
        "margin": {"l": 60, "r": 20, "t": 60, "b": 60},
    }
    layout.update(kwargs)
    return layout
