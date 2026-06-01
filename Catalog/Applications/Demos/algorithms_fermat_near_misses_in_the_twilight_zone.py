#!/usr/bin/env python3
"""
Fermat Near-Misses: Core Algorithms

Type-hinted implementations of the key computational procedures
for finding and analyzing Fermat near-misses.
"""

from typing import List, Tuple, Set, Optional
from math import gcd, floor, ceil, log
from dataclasses import dataclass


@dataclass
class NearMiss:
    """A Fermat near-miss triple with its defect and quality."""
    n: int
    a: int
    b: int
    c: int
    defect: int
    quality: float

    def __repr__(self) -> str:
        return (f"NearMiss(n={self.n}, ({self.a},{self.b},{self.c}), "
                f"defect={self.defect}, quality={self.quality:.2e})")


def fermat_defect(n: int, a: int, b: int, c: int) -> int:
    """Compute the signed Fermat defect a^n + b^n - c^n.

    Args:
        n: The exponent (≥ 1)
        a, b, c: Positive integers

    Returns:
        The integer a^n + b^n - c^n
    """
    return a**n + b**n - c**n


def consecutive_power_gap(n: int, c: int) -> int:
    """Compute the gap between consecutive n-th powers: (c+1)^n - c^n.

    Theorem (proved in Lean): This satisfies the sandwich inequality
        n * c^(n-1) ≤ gap ≤ n * (c+1)^(n-1)

    Args:
        n: The exponent (≥ 1)
        c: Non-negative integer

    Returns:
        (c+1)^n - c^n
    """
    return (c + 1)**n - c**n


def near_miss_quality(n: int, a: int, b: int, c: int) -> float:
    """Compute the relative quality |defect| / c^n.

    Lower quality values indicate closer near-misses.
    Quality 0 would mean an exact Fermat solution (impossible for n ≥ 3
    by Fermat's Last Theorem).

    Theorem (proved in Lean): For the family (1, c, c), quality = 1/c^n,
    which decays super-exponentially in n.
    """
    if c <= 0:
        return float('inf')
    return abs(fermat_defect(n, a, b, c)) / c**n


def optimal_c_for_sum(n: int, a: int, b: int) -> int:
    """Find the c that minimizes |a^n + b^n - c^n|.

    Uses the n-th root to find the closest perfect power to a^n + b^n.

    Args:
        n: The exponent
        a, b: Positive integers

    Returns:
        The c that minimizes |fermat_defect(n, a, b, c)|
    """
    s = a**n + b**n
    c_approx = s ** (1.0 / n)
    c_floor = max(1, int(floor(c_approx)))
    c_ceil = c_floor + 1

    d_floor = abs(s - c_floor**n)
    d_ceil = abs(s - c_ceil**n)

    return c_floor if d_floor <= d_ceil else c_ceil


def search_near_misses(
    n: int,
    N: int,
    max_defect: Optional[int] = None,
    coprime_only: bool = False,
    top_k: int = 20
) -> List[NearMiss]:
    """Search for the best Fermat near-misses with entries bounded by N.

    Algorithm:
        For each (a, b) with 1 ≤ a ≤ b ≤ N, find the optimal c
        minimizing |a^n + b^n - c^n|, then filter and sort by quality.

    Args:
        n: Exponent (should be ≥ 3 for non-trivial results)
        N: Upper bound on max(a, b, c)
        max_defect: If set, only return misses with |defect| ≤ this
        coprime_only: If True, only return coprime triples
        top_k: Number of best results to return

    Returns:
        List of NearMiss objects, sorted by quality (best first)
    """
    results: List[NearMiss] = []

    for a in range(1, N + 1):
        for b in range(a, N + 1):
            # Find optimal c
            c_opt = optimal_c_for_sum(n, a, b)
            # Also check neighbors
            for c in range(max(1, c_opt - 1), min(N + 1, c_opt + 2)):
                d = fermat_defect(n, a, b, c)
                if d == 0:
                    continue  # Exact solution (shouldn't happen for n ≥ 3)

                if max_defect is not None and abs(d) > max_defect:
                    continue

                if coprime_only and gcd(gcd(a, b), c) != 1:
                    continue

                q = abs(d) / c**n
                results.append(NearMiss(n=n, a=a, b=b, c=c, defect=d, quality=q))

    results.sort(key=lambda m: (abs(m.defect), m.quality))
    return results[:top_k]


def compute_spectrum(n: int, N: int) -> Set[int]:
    """Compute the Fermat Near-Miss Spectrum for exponent n, bound N.

    The spectrum S(n, N) = {a^n + b^n - c^n : 1 ≤ a,b,c ≤ N}.

    Theorem (proved in Lean):
        - 1 ∈ S(n, N) for all N ≥ 1, n ≥ 1
        - S(n, N) ⊆ S(n, M) when N ≤ M (monotonicity)
        - 0 ∉ S(n, N) for n ≥ 3 (equivalent to FLT)

    Returns:
        Set of all achievable defect values
    """
    spectrum: Set[int] = set()
    for a in range(1, N + 1):
        for b in range(1, N + 1):
            for c in range(1, N + 1):
                spectrum.add(a**n + b**n - c**n)
    return spectrum


def spectrum_density(n: int, N: int) -> float:
    """Compute the density of the spectrum: |S(n,N)| / range_width.

    As N grows, the spectrum covers a larger fraction of the interval
    [-(N^n - 2), 2*N^n - 1].
    """
    spec = compute_spectrum(n, N)
    if not spec:
        return 0.0
    range_width = max(spec) - min(spec) + 1
    return len(spec) / range_width


def verify_gap_sandwich(n: int, max_c: int = 100) -> bool:
    """Verify the power gap sandwich inequality for all c up to max_c.

    Checks: n * c^(n-1) ≤ (c+1)^n - c^n ≤ n * (c+1)^(n-1)

    Returns True if all checks pass.
    """
    for c in range(max_c + 1):
        gap = consecutive_power_gap(n, c)
        lower = n * c**(n - 1) if n >= 1 else 0
        upper = n * (c + 1)**(n - 1)
        if not (lower <= gap <= upper):
            return False
    return True


def min_coprime_defect(n: int, N: int) -> Tuple[int, Tuple[int, int, int]]:
    """Find the minimum nonzero |defect| among coprime triples bounded by N.

    This is used to test the conjecture that the minimum grows polynomially.

    Returns:
        (min_defect, (a, b, c)) - the minimum defect and achieving triple
    """
    best_d = float('inf')
    best_triple = (0, 0, 0)

    for a in range(1, N + 1):
        for b in range(a, N + 1):
            c_opt = optimal_c_for_sum(n, a, b)
            for c in range(max(1, c_opt - 1), min(N + 1, c_opt + 2)):
                d = abs(fermat_defect(n, a, b, c))
                if d > 0 and gcd(gcd(a, b), c) == 1 and d < best_d:
                    best_d = d
                    best_triple = (a, b, c)

    return (int(best_d), best_triple)


if __name__ == "__main__":
    # Quick demonstration
    print("=== Fermat Near-Miss Search (n=3, N=50) ===")
    misses = search_near_misses(3, 50, top_k=10)
    for m in misses:
        print(f"  {m}")

    print(f"\n=== Gap Sandwich Verification ===")
    for n in [3, 4, 5]:
        ok = verify_gap_sandwich(n, 50)
        print(f"  n={n}: {'✓ Verified' if ok else '✗ FAILED'}")

    print(f"\n=== Spectrum Sizes ===")
    for n in [3, 4]:
        for N in [3, 5, 8]:
            spec = compute_spectrum(n, N)
            print(f"  |S({n},{N})| = {len(spec)}, 0∈S: {0 in spec}")
