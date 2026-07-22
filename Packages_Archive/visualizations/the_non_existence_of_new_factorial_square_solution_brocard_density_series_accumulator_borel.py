from math import factorial, sqrt
from typing import List


def density_partial_sums(terms: int) -> List[float]:
    """Partial sums of the Brocard density series sum_n 1/sqrt(n!).

    The series converges (ratio of consecutive terms is 1/sqrt(n+1) -> 0),
    which is the analytic input to the Borel-Cantelli finiteness heuristic.
    """
    sums: List[float] = []
    acc: float = 0.0
    for n in range(terms):
        acc += 1.0 / sqrt(float(factorial(n)))
        sums.append(acc)
    return sums


def ratio_test_witness(n: int) -> float:
    """Ratio term_{n+1}/term_n = 1/sqrt(n+1); below 1 for all n >= 1."""
    return 1.0 / sqrt(float(n + 1))


if __name__ == "__main__":
    s = density_partial_sums(25)
    print(f"partial sum (25 terms) = {s[-1]:.10f}")
