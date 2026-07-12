"""
Numerical demonstration of the Exact Count Theorem for the Isolation Lemma.

For n vertices, each weighted from {0, 1, ..., d-1}, an assignment
w = (w_0, ..., w_{n-1}) is called *isolating* when a single vertex attains the
strict minimum weight (i.e. there is a unique index i with w_i < w_j for all
j != i).

Main result (Exact Count Theorem):

    #{ isolating assignments } = n * sum_{j=0}^{d-1} j^(n-1),

which is exactly the Faber-Harris universal lower bound for inclusion-free
hypergraphs -- so the singleton hypergraph attains that bound term for term.

This script cross-checks the closed form against brute-force enumeration and
against the fiberwise decomposition (argmin vertex x minimum value), and
illustrates the boundary cases.
"""

from __future__ import annotations

from itertools import product
from typing import Iterator, List, Tuple


# ---------------------------------------------------------------------------
# Ground truth: direct enumeration (Algorithm A)
# ---------------------------------------------------------------------------
def enumerate_isolating(n: int, d: int) -> int:
    """Count isolating assignments in [d]^n by exhaustive enumeration.

    Time complexity Theta(n * d^n); intended for small parameters only.
    """
    if n == 0:
        return 0
    count = 0
    for w in product(range(d), repeat=n):
        m = min(w)
        if sum(1 for x in w if x == m) == 1:
            count += 1
    return count


# ---------------------------------------------------------------------------
# Closed form: the Exact Count Theorem (Algorithm B)
# ---------------------------------------------------------------------------
def closed_form(n: int, d: int) -> int:
    """Return n * sum_{j=0}^{d-1} j^(n-1) using truncated (natural) subtraction.

    For n == 0 the leading factor nullifies the sum, so the value is 0.
    Note 0**0 == 1 in Python, matching the natural-number convention.
    """
    if n == 0:
        return 0
    exponent = n - 1
    return n * sum(j ** exponent for j in range(d))


# ---------------------------------------------------------------------------
# Fiberwise decomposition (the proof, made computational)
# ---------------------------------------------------------------------------
def per_vertex_count(n: int, d: int) -> int:
    """Number of assignments for which a FIXED vertex i is the strict minimum.

    Equals sum_{m=0}^{d-1} (d-1-m)^(n-1) = sum_{k=0}^{d-1} k^(n-1),
    independent of i.
    """
    if n == 0:
        return 0
    exponent = n - 1
    return sum((d - 1 - m) ** exponent for m in range(d))


def fiber_count(n: int, d: int, m: int) -> int:
    """Number of assignments with a fixed argmin vertex taking minimum value m:
    the argmin is fixed, and each of the other n-1 vertices exceeds m.
    Equals (d - 1 - m)^(n-1)."""
    if n == 0:
        return 0
    return (d - 1 - m) ** (n - 1)


def decomposition_total(n: int, d: int) -> int:
    """Reconstruct the total via the (argmin vertex, minimum value) fibering."""
    return sum(fiber_count(n, d, m) for _ in range(n) for m in range(d))


# ---------------------------------------------------------------------------
# Reporting helpers
# ---------------------------------------------------------------------------
def grid(n_range: range, d_range: range) -> Iterator[Tuple[int, int]]:
    for n in n_range:
        for d in d_range:
            yield n, d


def verify_grid(n_range: range, d_range: range) -> bool:
    ok = True
    for n, d in grid(n_range, d_range):
        e = enumerate_isolating(n, d)
        c = closed_form(n, d)
        f = decomposition_total(n, d)
        agree = (e == c == f)
        ok = ok and agree
        flag = "OK " if agree else "!! "
        print(f"  {flag}n={n} d={d}: enum={e:>6}  closed={c:>6}  fiber={f:>6}")
    return ok


def sequence_row(n: int, d_max: int) -> List[int]:
    return [closed_form(n, d) for d in range(d_max + 1)]


def main() -> None:
    print("=" * 68)
    print("Exact Count Theorem for the Isolation Lemma (singleton hypergraph)")
    print("   #isolating(n,d) = n * sum_{j<d} j^(n-1)")
    print("=" * 68)

    print("\n[1] Cross-check over a grid (enumeration vs closed form vs fibering):")
    all_ok = verify_grid(range(0, 5), range(1, 6))
    print(f"\n   ==> all agree: {all_ok}")

    print("\n[2] Worked example n=3, d=4:")
    print("   3 * (0^2 + 1^2 + 2^2 + 3^2) = 3 * 14 = 42")
    print(f"   closed_form(3,4)         = {closed_form(3, 4)}")
    print(f"   enumerate_isolating(3,4) = {enumerate_isolating(3, 4)}")
    print(f"   total assignments 4^3    = {4 ** 3}")

    print("\n[3] Per-vertex fiber size (independent of the chosen vertex):")
    for i in range(3):
        print(f"   vertex i={i}: strict-min-at-i count = {per_vertex_count(3, 4)}")
    print("   (each equals sum_{j<4} j^2 = 14, and 3 * 14 = 42)")

    print("\n[4] Isolating-count sequences n * sum_{j<d} j^(n-1):")
    for n in range(1, 5):
        print(f"   n={n}: {sequence_row(n, 6)}")

    print("\n[5] Boundary cases:")
    print(f"   n=0 (no vertices):       closed={closed_form(0,5)} enum={enumerate_isolating(0,5)}")
    print(f"   n=1 (single vertex, d=5): closed={closed_form(1,5)} enum={enumerate_isolating(1,5)} (=d)")
    print(f"   d=1, n=3 (one value):    closed={closed_form(3,1)} enum={enumerate_isolating(3,1)}")

    print("\nDone.")


if __name__ == "__main__":
    main()
