from itertools import combinations


def reimer_cube_identity(n: int) -> bool:
    """Verify 2 * sum_{A subset of [n]} |A| == n * 2^n (reimer_tight_cube)."""
    total: int = sum(len(c) for r in range(n + 1) for c in combinations(range(n), r))
    return 2 * total == n * (2 ** n)
