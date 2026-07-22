from __future__ import annotations

def repeated_127_closed(n: int) -> int:
    """Compute the nth term from its exact geometric-series formula."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    numerator = 127 * (pow(1000, n + 1) - 1)
    value, remainder = divmod(numerator, 999)
    if remainder:
        raise ArithmeticError("expected exact division")
    return value

if __name__ == "__main__":
    for i in (0, 1, 2, 10, 50):
        value = repeated_127_closed(i)
        print(i, len(str(value)), str(value)[:24] + ("..." if len(str(value)) > 24 else ""))
