"""Pólya-Tree Divisor-Sum Recurrence — numerical demonstrations.

This self-contained script reproduces the results formalized in the companion
Lean development for OEIS A000081, the number a(n) of unlabelled rooted trees
on n nodes.

Core identity (Euler transform):
    c(k)        = sum_{d | k} d * a(d)
    n * a(n+1)  = sum_{k=1}^{n} c(k) * a(n+1-k),   a(1) = 1, a(0) = 0.

Everything below uses exact integer arithmetic; no external libraries.
"""

from __future__ import annotations

from typing import Dict, List, Tuple


def divisors(k: int) -> List[int]:
    """Return the sorted list of positive divisors of k (empty for k = 0)."""
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


def euler_coefficient(a: List[int], k: int) -> int:
    """Euler-transform coefficient c(k) = sum_{d | k} d * a(d).

    `a` must already contain a(d) for every divisor d of k.
    """
    return sum(d * a[d] for d in divisors(k))


def polya_tree_counts(n_max: int) -> List[int]:
    """Compute a(0), a(1), ..., a(n_max) via the divisor-sum recurrence.

    Uses the clean integer identity n * a(n+1) = sum_{k=1}^{n} c(k) a(n+1-k).
    The division by n is always exact (the integrality phenomenon).
    """
    a: List[int] = [0] * (n_max + 1)
    if n_max >= 1:
        a[1] = 1
    # Precompute coefficients lazily as the prefix grows.
    c: List[int] = [0] * (n_max + 1)
    for n in range(1, n_max):
        # Coefficients c(1..n) depend only on a(1..n), all known by now.
        for k in range(1, n + 1):
            c[k] = euler_coefficient(a, k)
        s = sum(c[k] * a[n + 1 - k] for k in range(1, n + 1))
        assert s % n == 0, f"integrality FAILED at n={n}: {s} not divisible by {n}"
        a[n + 1] = s // n
    return a


def integrality_certificates(n_max: int) -> List[Tuple[int, int, int, bool]]:
    """For each n, return (n, S_n, n*a(n+1), S_n % n == 0).

    S_n = sum_{k=1}^{n} c(k) a(n+1-k). This is Algorithm 6.2 of the paper.
    """
    a = polya_tree_counts(n_max + 1)
    rows: List[Tuple[int, int, int, bool]] = []
    for n in range(1, n_max + 1):
        c = {k: euler_coefficient(a, k) for k in range(1, n + 1)}
        s = sum(c[k] * a[n + 1 - k] for k in range(1, n + 1))
        rows.append((n, s, n * a[n + 1], s % n == 0))
    return rows


def coefficient_table(n_max: int) -> Dict[int, int]:
    """Return {k: c(k)} for 1 <= k <= n_max."""
    a = polya_tree_counts(n_max)
    return {k: euler_coefficient(a, k) for k in range(1, n_max + 1)}


REFERENCE_A000081_0_15: List[int] = [
    0, 1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842, 4766, 12486, 32973, 87811,
]


def demo_correctness_table() -> None:
    """Theorem 4.1: first sixteen values agree with OEIS A000081."""
    a = polya_tree_counts(15)
    print("=== Correctness table (Theorem 4.1) ===")
    print("computed :", a)
    print("reference:", REFERENCE_A000081_0_15)
    print("match    :", a == REFERENCE_A000081_0_15)
    print()


def demo_coefficients() -> None:
    """Euler-transform coefficients c(k)."""
    print("=== Euler-transform coefficients c(k) = sum_{d|k} d*a(d) ===")
    coeffs = coefficient_table(10)
    for k, ck in coeffs.items():
        print(f"  c({k:2d}) = {ck}")
    print()


def demo_integrality() -> None:
    """Theorem 4.3: exactness / integrality of the divisor sum."""
    print("=== Integrality certificates (Theorem 4.3) ===")
    print(f"  {'n':>3} {'S_n':>12} {'n*a(n+1)':>12} {'exact':>7}")
    for n, s, na, ok in integrality_certificates(13):
        print(f"  {n:>3} {s:>12} {na:>12} {str(ok):>7}")
    print()


def demo_growth_ratio() -> None:
    """Conjecture C2: a(n+1)/a(n) approaches Otter's constant ~ 2.9557652856."""
    print("=== Growth ratio a(n+1)/a(n) -> Otter's constant ~ 2.9557652856 ===")
    a = polya_tree_counts(25)
    for n in range(10, 25):
        print(f"  a({n+1})/a({n}) = {a[n+1] / a[n]:.10f}")
    print()


if __name__ == "__main__":
    demo_correctness_table()
    demo_coefficients()
    demo_integrality()
    demo_growth_ratio()
