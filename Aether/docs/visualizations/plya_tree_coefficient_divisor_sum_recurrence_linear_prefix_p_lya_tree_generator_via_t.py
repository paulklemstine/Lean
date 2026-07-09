from typing import List


def divisors(k: int) -> List[int]:
    """Sorted positive divisors of k (empty for k <= 0)."""
    if k <= 0:
        return []
    out: List[int] = []
    d = 1
    while d * d <= k:
        if k % d == 0:
            out.append(d)
            if d != k // d:
                out.append(k // d)
        d += 1
    return sorted(out)


def polya_tree_counts(n_max: int) -> List[int]:
    """Linear-prefix Pólya-tree generator (A000081).

    Implements n * a(n+1) = sum_{k=1}^{n} c(k) * a(n+1-k) with
    c(k) = sum_{d|k} d * a(d), a(0) = 0, a(1) = 1. The division by n is
    always exact (the integrality phenomenon), so we assert it.

    Complexity: O(n_max^2) for the convolution, O(n_max log n_max) for the
    divisor sums, O(n_max) space.
    """
    a: List[int] = [0] * (n_max + 1)
    if n_max >= 1:
        a[1] = 1
    c: List[int] = [0] * (n_max + 1)
    for n in range(1, n_max):
        for k in range(1, n + 1):
            c[k] = sum(d * a[d] for d in divisors(k))
        s = sum(c[k] * a[n + 1 - k] for k in range(1, n + 1))
        assert s % n == 0, f"integrality failed at n={n}"
        a[n + 1] = s // n
    return a
