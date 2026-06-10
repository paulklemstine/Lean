#!/usr/bin/env python3
"""
Algorithms for Fermat Near-Miss Analysis

Provides type-hinted implementations of key algorithms for:
  - Computing Fermat defects and quality measures
  - Searching for near-misses efficiently
  - Verifying the power gap sandwich bounds
  - Testing the exponent gap conjecture
"""

from math import gcd, comb, floor, ceil, log
from typing import List, Tuple, Optional, NamedTuple
from dataclasses import dataclass


@dataclass
class NearMiss:
    """A Fermat near-miss triple with metadata."""
    a: int
    b: int
    c: int
    n: int
    defect: int
    quality: float  # |defect| / c^n

    def is_coprime(self) -> bool:
        """Check if (a, c) and (b, c) are coprime."""
        return gcd(self.a, self.c) == 1 and gcd(self.b, self.c) == 1

    def satisfies_exponent_gap(self) -> bool:
        """Check if |defect| ≥ c^(n-2) (the conjecture)."""
        if self.n < 3:
            return True
        return abs(self.defect) >= self.c ** (self.n - 2)


def fermat_defect(a: int, b: int, c: int, n: int) -> int:
    """Compute the Fermat defect a^n + b^n - c^n."""
    return a**n + b**n - c**n


def cross_term_sum(a: int, b: int, n: int) -> int:
    """Compute Σ_{k=1}^{n-1} C(n,k) a^k b^{n-k}.
    By the mixed-term decomposition, this equals (a+b)^n - a^n - b^n."""
    return sum(comb(n, k) * a**k * b**(n - k) for k in range(1, n))


def power_gap(c: int, n: int) -> int:
    """Compute (c+1)^n - c^n, the gap between consecutive perfect powers."""
    return (c + 1)**n - c**n


def power_gap_bounds(c: int, n: int) -> Tuple[int, int]:
    """Return (lower, upper) for the power gap sandwich:
    n * c^(n-1) ≤ (c+1)^n - c^n ≤ n * (c+1)^(n-1)."""
    lower = n * c**(n - 1)
    upper = n * (c + 1)**(n - 1)
    return lower, upper


def optimal_c(a: int, b: int, n: int) -> int:
    """Find the positive integer c minimizing |a^n + b^n - c^n|.

    By the optimal approximant theorem, the sign change happens
    between consecutive integers, so we only need to check 2 candidates.
    """
    target = a**n + b**n
    # Initial estimate via n-th root
    c_approx = max(1, round(target ** (1.0 / n)))
    # By our theorem, the optimal c is within 1 of the root
    best_c = c_approx
    best_d = abs(fermat_defect(a, b, c_approx, n))
    for dc in [-1, 0, 1]:
        cc = c_approx + dc
        if cc > 0:
            dd = abs(fermat_defect(a, b, cc, n))
            if dd < best_d:
                best_d = dd
                best_c = cc
    return best_c


def search_near_misses(n: int, max_val: int, top_k: int = 20) -> List[NearMiss]:
    """Search for the top-k best Fermat near-misses with a, b ≤ max_val.

    Algorithm:
      For each (a, b) with 1 ≤ a ≤ b ≤ max_val:
        1. Find optimal c via n-th root estimation
        2. Compute defect and quality
        3. Keep top-k by quality (lowest |defect|/c^n)

    Complexity: O(max_val^2 * log(max_val)) time, O(top_k) space.
    """
    results: List[NearMiss] = []
    for a in range(1, max_val + 1):
        for b in range(a, max_val + 1):
            c = optimal_c(a, b, n)
            if c <= b:
                continue
            d = fermat_defect(a, b, c, n)
            if d == 0:
                continue
            q = abs(d) / c**n
            nm = NearMiss(a=a, b=b, c=c, n=n, defect=d, quality=q)
            results.append(nm)
            # Keep only top_k + buffer to avoid O(n^2) sorting
            if len(results) > top_k * 10:
                results.sort(key=lambda x: x.quality)
                results = results[:top_k]
    results.sort(key=lambda x: x.quality)
    return results[:top_k]


def verify_power_gap_sandwich(n: int, max_c: int) -> bool:
    """Verify the power gap sandwich n*c^(n-1) ≤ (c+1)^n - c^n ≤ n*(c+1)^(n-1)
    for all c up to max_c."""
    for c in range(0, max_c + 1):
        gap = power_gap(c, n)
        lower, upper = power_gap_bounds(c, n)
        if not (lower <= gap <= upper):
            return False
    return True


def test_exponent_gap_conjecture(n: int, max_val: int) -> Tuple[bool, Optional[NearMiss]]:
    """Test the Near-Miss Exponent Gap Conjecture for exponent n.

    Returns (holds, counterexample) where counterexample is the first
    violation found, or None if the conjecture holds for all tested triples.
    """
    for a in range(1, max_val + 1):
        for b in range(a, max_val + 1):
            c = optimal_c(a, b, n)
            if c <= b or gcd(a, c) > 1 or gcd(b, c) > 1:
                continue
            d = fermat_defect(a, b, c, n)
            if d == 0:
                continue
            if abs(d) < c ** (n - 2):
                nm = NearMiss(a=a, b=b, c=c, n=n, defect=d, quality=abs(d)/c**n)
                return False, nm
    return True, None


def defect_landscape(n: int, c: int) -> List[Tuple[int, int, int]]:
    """Compute the defect landscape: for a given c and n,
    return [(a, b, defect)] for all 1 ≤ a ≤ b < c."""
    results = []
    for a in range(1, c):
        for b in range(a, c):
            d = fermat_defect(a, b, c, n)
            results.append((a, b, d))
    return results


if __name__ == "__main__":
    # Quick demonstration
    print("Top 5 cubic near-misses (n=3, max=100):")
    for nm in search_near_misses(3, 100, 5):
        print(f"  {nm.a}^3 + {nm.b}^3 - {nm.c}^3 = {nm.defect} "
              f"(quality={nm.quality:.2e}, coprime={nm.is_coprime()})")

    print("\nPower gap sandwich verification:")
    for n in range(1, 8):
        ok = verify_power_gap_sandwich(n, 1000)
        print(f"  n={n}: {'✓' if ok else '✗'}")

    print("\nExponent gap conjecture test:")
    for n in [3, 4, 5]:
        holds, cex = test_exponent_gap_conjecture(n, 100)
        if holds:
            print(f"  n={n}: holds for all tested triples ✓")
        else:
            print(f"  n={n}: VIOLATION at ({cex.a}, {cex.b}, {cex.c})")
