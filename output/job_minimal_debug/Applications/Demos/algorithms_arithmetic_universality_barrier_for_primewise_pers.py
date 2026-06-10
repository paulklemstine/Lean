#!/usr/bin/env python3
"""
Algorithms for Arithmetic Universality Barrier Analysis

Type-hinted implementations of the core algorithms for analyzing
primewise persistent encoding capacity and barrier theorems.
"""

from dataclasses import dataclass
from typing import List, Tuple, Dict, Optional, Set, FrozenSet
import math


@dataclass(frozen=True)
class PersistenceInterval:
    """A persistence interval [birth, death] with birth <= death."""
    birth: int
    death: int
    
    def __post_init__(self):
        assert self.birth <= self.death, f"Invalid interval: birth={self.birth} > death={self.death}"
    
    @property
    def persistence(self) -> int:
        """The lifetime of this interval."""
        return self.death - self.birth


@dataclass(frozen=True)
class Barcode:
    """A barcode: a tuple of persistence intervals (immutable for hashing)."""
    intervals: Tuple[PersistenceInterval, ...]
    
    @property
    def size(self) -> int:
        return len(self.intervals)
    
    @property
    def total_persistence(self) -> int:
        return sum(I.persistence for I in self.intervals)
    
    @property
    def max_endpoint(self) -> int:
        if not self.intervals:
            return 0
        return max(I.death for I in self.intervals)
    
    def is_bounded(self, k: int, D: int) -> bool:
        """Check if this barcode is (k, D)-bounded."""
        return self.size <= k and all(I.death <= D for I in self.intervals)
    
    @staticmethod
    def concat(b1: 'Barcode', b2: 'Barcode') -> 'Barcode':
        """Concatenate two barcodes (product encoding)."""
        return Barcode(b1.intervals + b2.intervals)


def enumerate_intervals(D: int) -> List[PersistenceInterval]:
    """Enumerate all valid persistence intervals with endpoints in {0, ..., D}."""
    return [PersistenceInterval(b, d) for b in range(D + 1) for d in range(b, D + 1)]


def barcode_capacity_upper(k: int, D: int) -> int:
    """Upper bound on the number of distinct (k, D)-bounded barcodes: (D+1)^(2k)."""
    return (D + 1) ** (2 * k)


def barcode_capacity_tight(k: int, D: int) -> int:
    """
    Tighter bound: number of multisets of size <= k from (D+1)(D+2)/2 intervals.
    Uses sum of C(n+i-1, i) for i = 0, ..., k where n = (D+1)(D+2)/2.
    """
    n_intervals = (D + 1) * (D + 2) // 2
    total = 0
    for i in range(k + 1):
        # C(n + i - 1, i)
        total += math.comb(n_intervals + i - 1, i)
    return total


def barrier_threshold(k: int, D: int, tight: bool = False) -> int:
    """
    Minimum number of objects that guarantees a collision.
    """
    if tight:
        return barcode_capacity_tight(k, D) + 1
    return barcode_capacity_upper(k, D) + 1


def frobenius_trace_range(p: int) -> Tuple[int, int]:
    """
    Range of Frobenius traces for elliptic curves at prime p.
    By Hasse's theorem: |a_p| <= 2*sqrt(p).
    """
    bound = int(2 * math.sqrt(p))
    return (-bound, bound)


def frobenius_trace_count(p: int) -> int:
    """Number of possible Frobenius traces at prime p."""
    lo, hi = frobenius_trace_range(p)
    return hi - lo + 1


def multi_prime_capacity(per_prime_cap: int, n_primes: int) -> int:
    """Total capacity using n primes."""
    return per_prime_cap ** n_primes


def growth_rate_crossover(k: int, D: int, d: int) -> int:
    """
    Find the smallest R such that the number of degree-d polynomials
    with coefficients in [-R, R] exceeds the barcode capacity.
    Returns R_0 such that (2*R_0 + 1)^(d+1) > (D+1)^(2k).
    """
    cap = barcode_capacity_upper(k, D)
    R = 0
    while (2 * R + 1) ** (d + 1) <= cap:
        R += 1
    return R


def detect_collision(
    objects: List[int],
    encoder: Dict[int, Barcode]
) -> Optional[Tuple[int, int]]:
    """
    Detect a collision: two objects that map to the same barcode.
    Returns (obj1, obj2) if found, None otherwise.
    """
    seen: Dict[Barcode, int] = {}
    for obj in objects:
        bc = encoder[obj]
        if bc in seen:
            return (seen[bc], obj)
        seen[bc] = obj
    return None


def birthday_collision_expected(capacity: int) -> int:
    """
    Expected number of random encodings before first collision (birthday paradox).
    Approximately sqrt(pi * capacity / 2).
    """
    return int(math.sqrt(math.pi * capacity / 2))


def refinement_capacity_ratio(
    k1: int, D1: int, k2: int, D2: int
) -> float:
    """
    Ratio of refined capacity to original capacity.
    Requires k1 <= k2 and D1 <= D2.
    """
    assert k1 <= k2 and D1 <= D2, "Refinement requires k1 <= k2 and D1 <= D2"
    cap1 = barcode_capacity_upper(k1, D1)
    cap2 = barcode_capacity_upper(k2, D2)
    return cap2 / cap1 if cap1 > 0 else float('inf')


def information_bits(k: int, D: int) -> float:
    """
    Information content (in bits) of a (k, D)-bounded barcode.
    = log2((D+1)^(2k)) = 2k * log2(D+1).
    """
    if D + 1 <= 0:
        return 0.0
    return 2 * k * math.log2(D + 1)


def minimum_primes_for_separation(
    n_objects: int, k: int, D: int
) -> int:
    """
    Minimum number of primes needed so that multi-prime capacity >= n_objects.
    Returns smallest n such that (D+1)^(2kn) >= n_objects.
    """
    per_prime_cap = barcode_capacity_upper(k, D)
    if per_prime_cap <= 1:
        return n_objects  # degenerate case
    bits_needed = math.log(n_objects) / math.log(per_prime_cap)
    return int(math.ceil(bits_needed))


def analyze_barrier(k: int, D: int, d: int) -> Dict[str, object]:
    """
    Complete barrier analysis for given parameters.
    Returns a dictionary with all relevant quantities.
    """
    cap = barcode_capacity_upper(k, D)
    tight_cap = barcode_capacity_tight(k, D)
    crossover_R = growth_rate_crossover(k, D, d)
    bits = information_bits(k, D)
    birthday = birthday_collision_expected(cap)
    
    return {
        'k': k,
        'D': D,
        'd': d,
        'capacity_upper': cap,
        'capacity_tight': tight_cap,
        'barrier_threshold': cap + 1,
        'crossover_R': crossover_R,
        'bits_per_prime': bits,
        'birthday_collision': birthday,
        'frob_count_at_crossover': (2 * crossover_R + 1) ** (d + 1),
    }


if __name__ == "__main__":
    # Example usage
    print("Barrier Analysis Examples")
    print("=" * 50)
    
    for k, D, d in [(2, 5, 1), (3, 10, 2), (5, 20, 3)]:
        result = analyze_barrier(k, D, d)
        print(f"\n(k={k}, D={D}, d={d}):")
        for key, val in result.items():
            if isinstance(val, float):
                print(f"  {key}: {val:.2f}")
            else:
                print(f"  {key}: {val:,}" if isinstance(val, int) else f"  {key}: {val}")
