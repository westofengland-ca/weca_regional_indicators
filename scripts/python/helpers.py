# WECA Data Analysis Helper Functions
#
# Common utility functions for working with indicator data.
# Mirrors the functionality of scripts/R/helpers.R.
#
# Usage:
#   from scripts.python.helpers import load_csv, format_number, pct_change

from __future__ import annotations

from pathlib import Path

import polars as pl


def load_csv(file_path: str | Path, **kwargs: object) -> pl.DataFrame:
    """Load a CSV file with error handling and path validation.

    Uses Polars for fast, memory-efficient loading. Additional keyword
    arguments are forwarded to polars.read_csv().

    Args:
        file_path: Path to the CSV file, relative to the project root or
            absolute.
        **kwargs: Additional arguments passed to polars.read_csv().

    Returns:
        A Polars DataFrame containing the CSV data.

    Raises:
        FileNotFoundError: If the file does not exist.
        ValueError: If the file does not have a .csv extension.

    Example:
        df = load_csv("data/fact/RI_5_ghg_emissions.csv")
    """
    path = Path(file_path)

    if not path.exists():
        raise FileNotFoundError(
            f"File not found: {path}\n"
            f"Tip: use paths relative to the project root, "
            f"e.g. 'data/fact/RI_5_ghg_emissions.csv'."
        )

    if path.suffix.lower() != ".csv":
        import warnings

        warnings.warn(
            f"File does not have a .csv extension: {path}. Attempting to read anyway.",
            stacklevel=2,
        )

    df = pl.read_csv(path, **kwargs)
    print(f"Loaded {df.height} rows and {df.width} columns from {path.name}")
    return df


def format_number(
    value: float,
    fmt: str = "number",
    digits: int | None = None,
    big_mark: bool = True,
) -> str:
    """Format a number for display in tables and chart labels.

    Args:
        value: The numeric value to format.
        fmt: Format type — "number", "percent", or "currency".
        digits: Decimal places. Defaults to 0 for "number", 1 for "percent",
            2 for "currency".
        big_mark: Whether to insert thousands separators (default True).

    Returns:
        A formatted string.

    Example:
        format_number(1_234_567)                    # "1,234,567"
        format_number(0.1234, fmt="percent")        # "12.3%"
        format_number(1_234.56, fmt="currency")     # "£1,234.56"
    """
    defaults = {"number": 0, "percent": 1, "currency": 2}
    if digits is None:
        digits = defaults.get(fmt, 0)

    if fmt == "percent":
        scaled = round(value * 100, digits)
        formatted = f"{scaled:,.{digits}f}" if big_mark else f"{scaled:.{digits}f}"
        return f"{formatted}%"

    rounded = round(value, digits)
    formatted = f"{rounded:,.{digits}f}" if big_mark else f"{rounded:.{digits}f}"

    if fmt == "currency":
        return f"£{formatted}"
    return formatted


def pct_change(
    new_value: float, old_value: float, as_decimal: bool = False
) -> float | None:
    """Calculate percentage change between two values.

    Args:
        new_value: The current value.
        old_value: The baseline value.
        as_decimal: If True, returns a decimal (0.1 for 10%); otherwise
            returns the percentage (10.0).

    Returns:
        The percentage change, or None if old_value is zero.

    Example:
        pct_change(110, 100)               # 10.0
        pct_change(90, 100, as_decimal=True)  # -0.1
    """
    if old_value == 0:
        import warnings

        warnings.warn(
            "old_value is zero — percentage change is undefined. Returning None.",
            stacklevel=2,
        )
        return None

    change = (new_value - old_value) / old_value
    return change if as_decimal else change * 100


def safe_divide(numerator: float, denominator: float) -> float | None:
    """Divide two numbers, returning None instead of inf/nan on zero division.

    Args:
        numerator: The numerator.
        denominator: The denominator.

    Returns:
        The result, or None if the denominator is zero.

    Example:
        safe_divide(100, 10)  # 10.0
        safe_divide(100, 0)   # None
    """
    if denominator == 0:
        return None
    return numerator / denominator


def check_missing(df: pl.DataFrame, threshold: float = 0.0) -> pl.DataFrame:
    """Print a summary of missing values in a DataFrame.

    Args:
        df: The Polars DataFrame to inspect.
        threshold: Minimum percentage of missing values to include in the
            report (default 0 = show all columns with any missing data).

    Returns:
        A Polars DataFrame with columns: column, n_missing, pct_missing.

    Example:
        check_missing(df)
        check_missing(df, threshold=5.0)  # Only columns with >5% missing
    """
    n_rows = df.height
    summary = (
        pl.DataFrame(
            {
                "column": df.columns,
                "n_missing": [df[col].null_count() for col in df.columns],
            }
        )
        .with_columns(
            (pl.col("n_missing") / n_rows * 100).round(1).alias("pct_missing")
        )
        .filter(pl.col("pct_missing") >= threshold)
        .sort("pct_missing", descending=True)
    )

    if summary.height == 0:
        print("No missing data found (or none above threshold).")
    else:
        print(f"Missing data found in {summary.height} column(s):")
        print(summary)

    return summary
