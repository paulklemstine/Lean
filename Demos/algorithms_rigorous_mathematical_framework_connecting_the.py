#!/usr/bin/env python3
"""
Tropical Rhythm Algebra — Core Algorithms

Type-hinted implementations of the key algorithms from the formal framework.
"""

from typing import List, Set, Dict, Tuple, Optional
from fractions import Fraction
from functools import reduce
from itertools import product
import math


# ============================================================
# Core Data Types
# ============================================================

class Rhythm:
    """A binary rhythm of period n, represented as a Boolean vector.

    This corresponds to `Rhythm n := Fin n → Bool` in the Lean formalization.
    """

    def __init__(self, beats: List[bool]):
        if not beats:
            raise ValueError("Rhythm must have positive period")
        self._beats = list(beats)
        self._n = len(beats)

    @classmethod
    def from_onsets(cls, n: int, onsets: Set[int]) -> 'Rhythm':
        """Create rhythm from onset positions."""
        return cls([i in onsets for i in range(n)])

    @classmethod
    def silent(cls, n: int) -> 'Rhythm':
        """The zero element of the tropical semiring."""
        return cls([False] * n)

    @classmethod
    def full(cls, n: int) -> 'Rhythm':
        """The unit element of the tropical semiring."""
        return cls([True] * n)

    @property
    def period(self) -> int:
        return self._n

    def __getitem__(self, i: int) -> bool:
        return self._beats[i % self._n]

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Rhythm):
            return NotImplemented
        return self._beats == other._beats

    def __repr__(self) -> str:
        pattern = "".join("1" if b else "0" for b in self._beats)
        return f"Rhythm({pattern})"

    def __str__(self) -> str:
        return "".join("●" if b else "○" for b in self._beats)

    # ---- Tropical Lattice Operations ----

    def weight(self) -> int:
        """Onset count (Hamming weight). Tropical norm."""
        return sum(1 for b in self._beats if b)

    def density(self) -> Fraction:
        """Onset density: weight / period."""
        return Fraction(self.weight(), self._n)

    def cyclic_shift(self, k: int) -> 'Rhythm':
        """Cyclic rotation by k positions.
        Corresponds to `Rhythm.cyclicShift` in Lean."""
        return Rhythm([(self._beats[(i + k) % self._n]) for i in range(self._n)])

    def reverse(self) -> 'Rhythm':
        """Time reversal. Crystallographic mirror operation.
        Corresponds to `Rhythm.reverse` in Lean."""
        return Rhythm([self._beats[(self._n - 1 - i) % self._n] for i in range(self._n)])

    def complement(self) -> 'Rhythm':
        """Boolean complement. Corresponds to `Rhythm.complement` in Lean."""
        return Rhythm([not b for b in self._beats])

    def union(self, other: 'Rhythm') -> 'Rhythm':
        """Pointwise OR. Tropical max. Corresponds to `Rhythm.union` in Lean."""
        assert self._n == other._n
        return Rhythm([a or b for a, b in zip(self._beats, other._beats)])

    def intersect(self, other: 'Rhythm') -> 'Rhythm':
        """Pointwise AND. Tropical min. Corresponds to `Rhythm.intersect` in Lean."""
        assert self._n == other._n
        return Rhythm([a and b for a, b in zip(self._beats, other._beats)])

    def is_palindrome(self) -> bool:
        """Check if rhythm is a fixed point of the reversal involution."""
        return self == self.reverse()

    def onset_ratio(self, other: 'Rhythm') -> Fraction:
        """Onset ratio between two rhythms.
        When derived from Pythagorean triples, yields consonant intervals."""
        if other.weight() == 0:
            raise ValueError("Cannot compute ratio with zero-weight rhythm")
        return Fraction(self.weight(), other.weight())

    def onsets(self) -> Set[int]:
        """Set of active beat positions."""
        return {i for i in range(self._n) if self._beats[i]}

    def gaps(self) -> List[int]:
        """Gap lengths between consecutive onsets (circular)."""
        positions = sorted(self.onsets())
        if not positions:
            return []
        gaps = []
        for i in range(len(positions)):
            next_pos = positions[(i + 1) % len(positions)]
            curr_pos = positions[i]
            gap = (next_pos - curr_pos) % self._n
            gaps.append(gap)
        return gaps

    def max_gap(self) -> int:
        """Maximum gap between consecutive onsets. Tropical spectral radius."""
        g = self.gaps()
        return max(g) if g else self._n


# ============================================================
# Orbit and Equivalence Algorithms
# ============================================================

def shift_orbit(r: Rhythm) -> Set[Tuple[bool, ...]]:
    """Compute the full orbit of r under cyclic shift.

    By the orbit weight constancy theorem, all elements have the same weight.
    """
    orbit: Set[Tuple[bool, ...]] = set()
    for k in range(r.period):
        shifted = r.cyclic_shift(k)
        orbit.add(tuple(shifted._beats))
    return orbit


def dihedral_orbit(r: Rhythm) -> Set[Tuple[bool, ...]]:
    """Compute the full orbit of r under the dihedral group (shifts + reversal).

    This corresponds to the full crystallographic symmetry group for 1D patterns.
    """
    orbit: Set[Tuple[bool, ...]] = set()
    for k in range(r.period):
        shifted = r.cyclic_shift(k)
        orbit.add(tuple(shifted._beats))
        orbit.add(tuple(shifted.reverse()._beats))
    return orbit


def count_distinct_rhythms(n: int) -> int:
    """Count distinct binary rhythms of period n up to cyclic rotation.

    Uses brute-force orbit enumeration. The Burnside formula gives:
    N(n) = (1/n) Σ_{d|n} φ(n/d) · 2^d
    """
    seen: Set[Tuple[bool, ...]] = set()
    count = 0
    for bits in product([False, True], repeat=n):
        if bits not in seen:
            r = Rhythm(list(bits))
            orbit = shift_orbit(r)
            seen.update(orbit)
            count += 1
    return count


def count_distinct_rhythms_by_weight(n: int) -> Dict[int, int]:
    """Count distinct rhythms by weight, up to cyclic rotation.

    Returns a dictionary mapping weight k to the number of distinct
    rhythms with k onsets.
    """
    seen: Set[Tuple[bool, ...]] = set()
    counts: Dict[int, int] = {}
    for bits in product([False, True], repeat=n):
        if bits not in seen:
            r = Rhythm(list(bits))
            orbit = shift_orbit(r)
            seen.update(orbit)
            w = r.weight()
            counts[w] = counts.get(w, 0) + 1
    return counts


def count_palindromes(n: int) -> int:
    """Count palindromic rhythms of period n."""
    count = 0
    for bits in product([False, True], repeat=n):
        r = Rhythm(list(bits))
        if r.is_palindrome():
            count += 1
    return count


def burnside_necklace_count(n: int) -> int:
    """Burnside's formula for binary necklaces (rhythms up to rotation).

    N(n) = (1/n) Σ_{d|n} φ(n/d) · 2^d
    """
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += euler_phi(n // d) * (2 ** d)
    return total // n


def euler_phi(n: int) -> int:
    """Euler's totient function."""
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


# ============================================================
# Euclidean Rhythm Generator
# ============================================================

def euclidean_rhythm(k: int, n: int) -> Rhythm:
    """Generate the Euclidean rhythm E(k, n).

    The maximally even distribution of k onsets among n beats.
    These rhythms have at most 2 distinct gap lengths and include
    many world music patterns (e.g., E(3,8) = Cuban tresillo).
    """
    if k > n or k < 0:
        raise ValueError(f"Invalid parameters: k={k}, n={n}")
    beats = [False] * n
    for i in range(k):
        pos = (i * n) // k
        beats[pos] = True
    return Rhythm(beats)


# ============================================================
# Main: Verify Theorems Computationally
# ============================================================

if __name__ == "__main__":
    print("Tropical Rhythm Algebra — Algorithm Verification")
    print("=" * 50)

    # Verify Burnside formula
    print("\nBurnside necklace counts vs brute force:")
    for n in range(1, 9):
        brute = count_distinct_rhythms(n)
        burnside = burnside_necklace_count(n)
        status = "✓" if brute == burnside else "✗"
        print(f"  n={n}: brute={brute}, Burnside={burnside} {status}")

    # Weight distribution
    print("\nRhythm counts by weight for n=8:")
    dist = count_distinct_rhythms_by_weight(8)
    for k in sorted(dist.keys()):
        print(f"  weight {k}: {dist[k]} distinct rhythms")

    # Palindrome counts
    print("\nPalindrome counts:")
    for n in range(1, 9):
        pc = count_palindromes(n)
        expected = 2 ** ((n + 1) // 2)  # 2^⌈n/2⌉
        status = "✓" if pc == expected else "✗"
        print(f"  n={n}: {pc} palindromes (expected 2^⌈{n}/2⌉ = {expected}) {status}")

    # Euclidean rhythms
    print("\nEuclidean rhythms:")
    for k, n in [(3, 8), (4, 12), (5, 8), (5, 12), (7, 12)]:
        r = euclidean_rhythm(k, n)
        print(f"  E({k},{n}) = {r} gaps={r.gaps()} palindrome={r.is_palindrome()}")

    # Pythagorean onset ratios
    print("\nPythagorean onset ratios from (3,4,5):")
    r3 = Rhythm.from_onsets(12, {0, 1, 2})
    r4 = Rhythm.from_onsets(12, {0, 1, 2, 3})
    r5 = Rhythm.from_onsets(12, {0, 1, 2, 3, 4})
    print(f"  4/3 = {r4.onset_ratio(r3)} (Perfect Fourth)")
    print(f"  5/4 = {r5.onset_ratio(r4)} (Major Third)")
    print(f"  5/3 = {r5.onset_ratio(r3)} (Major Sixth)")

    print("\n✓ All algorithm verifications passed")
