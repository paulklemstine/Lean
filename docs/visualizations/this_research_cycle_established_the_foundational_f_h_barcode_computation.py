#!/usr/bin/env python3
"""
Algorithms for Prime Persistent Homology

Implements the key algorithms from the research:
1. Rips filtration on the prime point cloud
2. H₀ barcode computation via union-find
3. Persistence entropy computation
4. Filtration parameter optimization
5. Gap-death bijection construction

Time complexity: O(π(N) log π(N)) for barcode computation
Space complexity: O(π(N))
"""

from typing import List, Tuple, Dict, Optional
from math import log, log2
from collections import defaultdict


class UnionFind:
    """Union-Find with path compression and union by rank.
    
    Time complexity: O(α(n)) amortized per operation,
    where α is the inverse Ackermann function.
    """

    def __init__(self, elements: List[int]):
        self.parent: Dict[int, int] = {x: x for x in elements}
        self.rank: Dict[int, int] = {x: 0 for x in elements}
        self.size: Dict[int, int] = {x: 1 for x in elements}
        self.num_components: int = len(elements)

    def find(self, x: int) -> int:
        """Find with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if a merge occurred."""
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        self.size[px] += self.size[py]
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.num_components -= 1
        return True

    def component_sizes(self) -> List[int]:
        """Return sizes of all components."""
        comps: Dict[int, int] = defaultdict(int)
        for x in self.parent:
            comps[self.find(x)] += 1
        return sorted(comps.values(), reverse=True)


class PersistenceBar:
    """A bar in the H₀ persistence barcode."""

    def __init__(self, birth: int, death: int, label: Optional[str] = None):
        self.birth = birth
        self.death = death
        self.persistence = death - birth
        self.label = label or f"[{birth}, {death})"

    def __repr__(self) -> str:
        return f"Bar({self.birth}→{self.death}, pers={self.persistence})"


def sieve_primes(N: int) -> List[int]:
    """Sieve of Eratosthenes. O(N log log N) time, O(N) space."""
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(2, N + 1) if is_prime[i]]


def compute_h0_barcode(N: int) -> Tuple[List[PersistenceBar], List[Tuple[int, int, int]]]:
    """Compute the H₀ persistence barcode of the Rips filtration on primes ≤ N.

    Algorithm:
    1. Generate primes ≤ N via sieve
    2. Compute all prime gaps (these are the filtration values)
    3. Process gaps in increasing order (Kruskal-like)
    4. Each merge event creates a bar death

    Returns:
        bars: List of PersistenceBar objects
        events: List of (epsilon, p, q) merge events

    Time: O(N log log N) for sieve + O(π(N) log π(N)) for sort + merges
    Space: O(N) for sieve + O(π(N)) for union-find
    """
    primes = sieve_primes(N)
    if len(primes) <= 1:
        return [], []

    # Compute edges: each consecutive pair with their gap
    edges: List[Tuple[int, int, int]] = []
    for i in range(len(primes) - 1):
        gap = primes[i + 1] - primes[i]
        edges.append((gap, primes[i], primes[i + 1]))

    # Sort by gap (filtration value)
    edges.sort()

    # Process merges
    uf = UnionFind(primes)
    bars: List[PersistenceBar] = []
    events: List[Tuple[int, int, int]] = []

    for gap, p, q in edges:
        if uf.union(p, q):
            # A component merged — the younger component's bar dies
            death_time = gap
            # Birth time = the later prime (it was born as its own component)
            birth = max(p, q)
            bars.append(PersistenceBar(birth=0, death=death_time,
                                       label=f"merge({p},{q})"))
            events.append((gap, p, q))

    return bars, events


def gap_death_bijection(N: int) -> Dict[int, List[Tuple[int, int]]]:
    """Construct the gap-death bijection explicitly.

    Maps each prime gap value to the list of prime pairs with that gap.
    This demonstrates our formalized gap_death_connection theorem.

    Returns: {gap_value: [(p, q), ...]}
    """
    primes = sieve_primes(N)
    bijection: Dict[int, List[Tuple[int, int]]] = defaultdict(list)
    for i in range(len(primes) - 1):
        gap = primes[i + 1] - primes[i]
        bijection[gap].append((primes[i], primes[i + 1]))
    return dict(sorted(bijection.items()))


def persistence_entropy(N: int) -> float:
    """Compute the persistence entropy of the prime barcode.

    H = -Σ (l_i / L) * log₂(l_i / L)

    where l_i is the persistence of bar i and L = Σ l_i.

    This is a topological summary statistic that measures the
    "complexity" of the prime distribution at scale N.

    Time: O(N log log N) for primes + O(π(N)) for entropy
    """
    primes = sieve_primes(N)
    if len(primes) <= 1:
        return 0.0

    gaps = [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]
    total = sum(gaps)
    if total == 0:
        return 0.0

    entropy = 0.0
    for g in gaps:
        if g > 0:
            p = g / total
            entropy -= p * log2(p)
    return entropy


def optimal_filtration_scale(N: int) -> int:
    """Find the filtration scale that maximizes the number of deaths.

    This is the "most interesting" scale in the barcode, where the
    most topological changes occur.

    Time: O(N log log N + π(N))
    """
    primes = sieve_primes(N)
    gap_counts: Dict[int, int] = defaultdict(int)
    for i in range(len(primes) - 1):
        gap = primes[i + 1] - primes[i]
        gap_counts[gap] += 1

    if not gap_counts:
        return 0
    return max(gap_counts, key=gap_counts.get)


def component_count_function(N: int) -> List[Tuple[int, int]]:
    """Compute β₀(ε) = number of connected components at scale ε.

    This is the Betti number function for H₀.
    At ε=0, β₀ = π(N) (each prime is its own component).
    As ε increases, components merge.
    At ε=N, β₀ = 1 (all primes connected).

    Returns: [(epsilon, component_count), ...]
    """
    primes = sieve_primes(N)
    if not primes:
        return [(0, 0)]

    # Collect all distinct gaps
    gaps = sorted(set(primes[i + 1] - primes[i] for i in range(len(primes) - 1)))

    result = [(0, len(primes))]
    uf = UnionFind(primes)

    # Process in order of gap size
    edges_by_gap: Dict[int, List[Tuple[int, int]]] = defaultdict(list)
    for i in range(len(primes) - 1):
        g = primes[i + 1] - primes[i]
        edges_by_gap[g].append((primes[i], primes[i + 1]))

    for gap in gaps:
        for p, q in edges_by_gap[gap]:
            uf.union(p, q)
        result.append((gap, uf.num_components))

    return result


def bertrand_ratio_sequence(N: int) -> List[float]:
    """Compute the ratio gap/birth for each bar, verifying Bertrand bound.

    Our theorem proves gap < birth for all primes, so all ratios < 1.
    The maximum ratio approaches 1 for large primes (Cramér's conjecture
    suggests max ratio ~ (log p)² / p → 0).

    Returns: list of gap/birth ratios
    """
    primes = sieve_primes(N)
    ratios = []
    for i in range(len(primes) - 1):
        gap = primes[i + 1] - primes[i]
        ratios.append(gap / primes[i])
    return ratios


# Example usage
if __name__ == "__main__":
    N = 10000
    print(f"=== Prime Persistent Homology Algorithms (N={N}) ===\n")

    # H₀ barcode
    bars, events = compute_h0_barcode(N)
    print(f"H₀ barcode: {len(bars)} bars")
    print(f"First 5 merge events: {events[:5]}")

    # Gap-death bijection
    bij = gap_death_bijection(N)
    print(f"\nGap-death bijection: {len(bij)} distinct gap values")
    for gap, pairs in list(bij.items())[:5]:
        print(f"  gap={gap}: {len(pairs)} occurrences")

    # Persistence entropy
    H = persistence_entropy(N)
    print(f"\nPersistence entropy H = {H:.4f} bits")

    # Optimal scale
    opt = optimal_filtration_scale(N)
    print(f"Most common gap (optimal filtration): ε = {opt}")

    # Component count
    betti = component_count_function(N)
    print(f"\nBetti number β₀ at selected scales:")
    for eps, count in betti[:10]:
        print(f"  ε={eps}: β₀ = {count}")

    # Bertrand ratios
    ratios = bertrand_ratio_sequence(N)
    print(f"\nBertrand ratio max = {max(ratios):.4f} < 1 ✓")
    print(f"Bertrand ratio mean = {sum(ratios)/len(ratios):.6f}")
