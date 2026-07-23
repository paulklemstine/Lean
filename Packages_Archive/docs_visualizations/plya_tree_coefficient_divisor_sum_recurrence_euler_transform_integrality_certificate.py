from typing import List, Tuple


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


def integrality_certificates(
    a: List[int], n_max: int
) -> List[Tuple[int, int, int, bool]]:
    """Euler-transform integrality certificate (Algorithm 6.2).

    For each 1 <= n <= n_max compute the unrounded convolution
    S_n = sum_{k=1}^{n} c(k) * a(n+1-k) with c(k) = sum_{d|k} d * a(d), and
    verify divisibility S_n % n == 0, returning rows
    (n, S_n, n*a(n+1), exact). A non-zero remainder would be a counterexample
    to the integrality conjecture; none occurs through n = 13 (and far beyond).

    Complexity: O(n_max^2) integer operations.
    """
    rows: List[Tuple[int, int, int, bool]] = []
    for n in range(1, n_max + 1):
        c = {k: sum(d * a[d] for d in divisors(k)) for k in range(1, n + 1)}
        s = sum(c[k] * a[n + 1 - k] for k in range(1, n + 1))
        rows.append((n, s, n * a[n + 1], s % n == 0))
    return rows
