"""
Algorithms for Primewise Persistent Homology

Type-hinted implementations of the core algorithms for computing
primewise persistence barcodes and detecting separating primes.
"""

from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass
import math


@dataclass
class BarcodeInterval:
    """A persistence interval [birth, death)."""
    birth: int
    death: int

    def __post_init__(self) -> None:
        assert self.birth < self.death, f"birth={self.birth} must be < death={self.death}"

    @property
    def lifetime(self) -> int:
        return self.death - self.birth


@dataclass
class PersistenceBarcode:
    """A persistence barcode: a list of intervals."""
    intervals: List[BarcodeInterval]

    def total_persistence(self) -> int:
        """Sum of all interval lifetimes."""
        return sum(iv.lifetime for iv in self.intervals)

    def size(self) -> int:
        """Number of intervals."""
        return len(self.intervals)

    def betti_at(self, t: int) -> int:
        """Betti number at filtration index t."""
        return sum(1 for iv in self.intervals if iv.birth <= t < iv.death)

    def persistence_entropy(self) -> float:
        """Shannon entropy of the persistence diagram."""
        L = self.total_persistence()
        if L == 0:
            return 0.0
        return -sum(
            (iv.lifetime / L) * math.log(iv.lifetime / L)
            for iv in self.intervals
            if iv.lifetime > 0
        )


def is_prime(n: int) -> bool:
    """Primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


def mod_p_vietoris_rips(
    lengths: List[float], p: int, max_dim: int = 2
) -> List[BarcodeInterval]:
    """
    Compute a persistence barcode from geodesic lengths mod p.

    Given a list of geodesic lengths, reduce them mod p to get
    residue classes, then build a Vietoris-Rips-like filtration
    based on pairwise residue distances.

    Parameters:
        lengths: List of geodesic lengths (as floats or ints)
        p: Prime modulus
        max_dim: Maximum homological dimension

    Returns:
        List of barcode intervals
    """
    # Reduce lengths mod p
    residues = [int(l) % p for l in lengths]
    n = len(residues)

    if n == 0:
        return []

    # Pairwise distances in Z/pZ (minimum of d and p-d)
    distances: List[Tuple[int, int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            d = abs(residues[i] - residues[j])
            d = min(d, p - d)
            distances.append((d, i, j))

    distances.sort()

    # Simplified persistence: track connected components
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> bool:
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        parent[rx] = ry
        return True

    # Birth times: all components born at 0
    # Death times: when components merge
    intervals: List[BarcodeInterval] = []
    for d, i, j in distances:
        if union(i, j):
            if d > 0:
                intervals.append(BarcodeInterval(birth=0, death=d))

    return intervals


def compute_primewise_signature(
    lengths: List[float], prime_bound: int
) -> Dict[int, PersistenceBarcode]:
    """
    Compute the primewise persistence signature.

    For each prime p up to prime_bound, compute the mod-p
    persistence barcode of the given length data.

    Parameters:
        lengths: Geodesic length data
        prime_bound: Upper bound on primes to consider

    Returns:
        Dictionary mapping primes to persistence barcodes
    """
    signature: Dict[int, PersistenceBarcode] = {}
    for p in primes_up_to(prime_bound):
        intervals = mod_p_vietoris_rips(lengths, p)
        signature[p] = PersistenceBarcode(intervals)
    return signature


def detect_separating_primes(
    sig1: Dict[int, PersistenceBarcode],
    sig2: Dict[int, PersistenceBarcode],
) -> Tuple[List[int], float]:
    """
    Find primes where two signatures differ in total persistence.

    Parameters:
        sig1, sig2: Primewise persistence signatures

    Returns:
        (separating_primes, estimated_density)
    """
    common_primes = sorted(set(sig1.keys()) & set(sig2.keys()))
    separating: List[int] = []

    for p in common_primes:
        if sig1[p].total_persistence() != sig2[p].total_persistence():
            separating.append(p)

    density = len(separating) / len(common_primes) if common_primes else 0.0
    return separating, density


def sunada_conjugacy_count(
    group_elements: List[int],
    subgroup: Set[int],
    conjugate_fn,
) -> Dict[int, int]:
    """
    Count elements in subgroup per conjugacy class.

    Parameters:
        group_elements: Elements of the group G
        subgroup: Elements of a subgroup H
        conjugate_fn: Function (g, x) -> x * g * x^{-1}

    Returns:
        Dictionary mapping representatives to counts
    """
    counts: Dict[int, int] = {}
    for g in group_elements:
        count = 0
        for h in subgroup:
            # Check if h is conjugate to g
            for x in group_elements:
                if conjugate_fn(h, x) == g:
                    count += 1
                    break
        counts[g] = count
    return counts


def prime_count(n: int) -> int:
    """π(n): number of primes up to n."""
    return len(primes_up_to(n))


def relative_prime_density(
    separating: List[int], prime_bound: int
) -> float:
    """
    Compute the relative density of separating primes
    among all primes up to prime_bound.
    """
    total = prime_count(prime_bound)
    if total == 0:
        return 0.0
    sep_count = sum(1 for p in separating if p <= prime_bound)
    return sep_count / total


if __name__ == "__main__":
    # Quick test
    iv = BarcodeInterval(2, 5)
    bc = PersistenceBarcode([iv])
    print(f"Interval: [{iv.birth}, {iv.death}), lifetime={iv.lifetime}")
    print(f"Total persistence: {bc.total_persistence()}")
    print(f"Betti at 3: {bc.betti_at(3)}")
    print(f"Betti at 5: {bc.betti_at(5)}")
    print(f"Primes up to 50: {primes_up_to(50)}")
