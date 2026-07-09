from typing import Sequence

def total_expected_payoff(ps: Sequence[float]) -> float:
    """Sum of per-card expected payoffs 2*p - 1 over a finite deck."""
    return sum(2.0 * p - 1.0 for p in ps)
