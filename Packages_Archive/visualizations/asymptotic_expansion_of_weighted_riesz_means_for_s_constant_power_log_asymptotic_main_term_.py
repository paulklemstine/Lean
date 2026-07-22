from __future__ import annotations
import math


def main_term(x: float, c: float, alpha: float, k: int) -> float:
    """Power-logarithm main term C * X^alpha * (log X)^k."""
    return c * (x ** alpha) * (math.log(x) ** k)
