"""
Primewise Persistent Homology: Core Algorithms

Type-hinted implementations of the key algorithms for computing
primewise persistence barcodes and detecting separating primes.
"""

from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass
import math


@dataclass(frozen=True)
class PersistenceInterval:
    """A persistence interval [birth, death)."""
    birth: int
    death: int

    def __post_init__(self):
        assert self.birth <= self.death, f"Invalid interval: birth={self.birth} > death={self.death}"

    @property
    def lifetime(self) -> int:
        return self.death - self.birth

    def alive_at(self, t: int) -> bool:
        return self.birth <= t < self.death


Barcode = List[PersistenceInterval]


def interval_match_cost(I: PersistenceInterval, J: PersistenceInterval) -> int:
    """Bottleneck matching cost between two persistence intervals."""
    return max(abs(I.birth - J.birth), abs(I.death - J.death))


def betti_at(barcode: Barcode, t: int) -> int:
    """Betti number at filtration parameter t."""
    return sum(1 for I in barcode if I.alive_at(t))


def rank_function(barcode: Barcode, s: int, t: int) -> int:
    """Persistent rank function β(s, t)."""
    return sum(1 for I in barcode if I.birth <= s and t < I.death)


def total_persistence(barcode: Barcode) -> int:
    """Total persistence (sum of lifetimes)."""
    return sum(I.lifetime for I in barcode)


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
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(n + 1) if sieve[i]]


def mod_p_residues(lengths: List[int], p: int) -> List[int]:
    """Compute sorted distinct residues of lengths mod p."""
    return sorted(set(x % p for x in lengths))


def mod_p_filtration_barcode(lengths: List[int], p: int) -> Barcode:
    """
    Construct a persistence barcode from mod-p filtration of length data.

    For each distinct residue class r that appears in lengths mod p,
    create a persistence interval [r, p).
    """
    residues = mod_p_residues(lengths, p)
    return [PersistenceInterval(birth=r, death=p) for r in residues]


def vietoris_rips_edges(lengths: List[int], epsilon: int) -> List[Tuple[int, int]]:
    """
    Compute edges of the Vietoris-Rips complex at scale epsilon.

    Two lengths are connected if their absolute difference <= epsilon.
    """
    edges = []
    for i in range(len(lengths)):
        for j in range(i + 1, len(lengths)):
            if abs(lengths[i] - lengths[j]) <= epsilon:
                edges.append((i, j))
    return edges


def vietoris_rips_barcode(lengths: List[int], max_epsilon: int) -> Barcode:
    """
    Compute the H0 persistence barcode of the Vietoris-Rips filtration.

    Uses union-find to track connected components.
    """
    n = len(lengths)
    if n == 0:
        return []

    # Compute all pairwise distances and sort
    dist_pairs: List[Tuple[int, int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            d = abs(lengths[i] - lengths[j])
            if d <= max_epsilon:
                dist_pairs.append((d, i, j))
    dist_pairs.sort()

    # Union-Find
    parent = list(range(n))
    rank_uf = [0] * n
    birth = [0] * n  # all components born at 0

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int, death_time: int) -> Optional[PersistenceInterval]:
        rx, ry = find(x), find(y)
        if rx == ry:
            return None
        # Younger component dies (higher birth time dies)
        if rank_uf[rx] < rank_uf[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank_uf[rx] == rank_uf[ry]:
            rank_uf[rx] += 1
        return PersistenceInterval(birth=0, death=death_time)

    barcode: Barcode = []
    for d, i, j in dist_pairs:
        result = union(i, j, d)
        if result and result.lifetime > 0:
            barcode.append(result)

    return barcode


def compute_primewise_barcodes(
    lengths: List[int],
    prime_bound: int
) -> Dict[int, Barcode]:
    """Compute mod-p barcodes for all primes up to prime_bound."""
    return {
        p: mod_p_filtration_barcode(lengths, p)
        for p in primes_up_to(prime_bound)
    }


def find_separating_primes(
    lengths1: List[int],
    lengths2: List[int],
    prime_bound: int
) -> Tuple[Set[int], Set[int]]:
    """
    Find primes that separate two length spectra.

    Returns (separating_primes, agreeing_primes).
    """
    separating: Set[int] = set()
    agreeing: Set[int] = set()

    for p in primes_up_to(prime_bound):
        b1 = mod_p_filtration_barcode(lengths1, p)
        b2 = mod_p_filtration_barcode(lengths2, p)

        if len(b1) != len(b2):
            separating.add(p)
        elif any(i1.birth != i2.birth or i1.death != i2.death
                 for i1, i2 in zip(b1, b2)):
            separating.add(p)
        else:
            agreeing.add(p)

    return separating, agreeing


def separation_density(
    lengths1: List[int],
    lengths2: List[int],
    prime_bound: int
) -> float:
    """Compute the density of separating primes up to prime_bound."""
    sep, agr = find_separating_primes(lengths1, lengths2, prime_bound)
    total = len(sep) + len(agr)
    return len(sep) / total if total > 0 else 0.0


def euler_characteristic(evens: Barcode, odds: Barcode, t: int) -> int:
    """Euler characteristic at filtration parameter t."""
    return betti_at(evens, t) - betti_at(odds, t)


def barcode_bottleneck_distance(b1: Barcode, b2: Barcode) -> int:
    """
    Approximate bottleneck distance between two barcodes.

    Uses a greedy matching heuristic (not optimal, but fast).
    """
    if not b1 and not b2:
        return 0

    # Include deletion costs
    costs = []
    used_j: Set[int] = set()

    for i, I in enumerate(b1):
        best_cost = I.lifetime  # deletion cost
        best_j = -1
        for j, J in enumerate(b2):
            if j not in used_j:
                c = interval_match_cost(I, J)
                if c < best_cost:
                    best_cost = c
                    best_j = j
        if best_j >= 0:
            used_j.add(best_j)
        costs.append(best_cost)

    # Unmatched intervals in b2
    for j, J in enumerate(b2):
        if j not in used_j:
            costs.append(J.lifetime)

    return max(costs) if costs else 0
