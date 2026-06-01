"""
Dark Mathematics: Core Algorithms

Type-hinted implementations of key algorithms for dark witness families,
including construction, verification, spectral analysis, and optimization.
"""

from typing import Dict, Set, Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class DarkWitnessFamily:
    """A dark witness family: finite witness sets indexed by worlds.
    
    Attributes:
        witnesses: mapping from world index to finite witness set
        level: guaranteed minimum witnesses per world
    """
    witnesses: Dict[int, Set[int]]
    level: int
    
    @property
    def num_worlds(self) -> int:
        return len(self.witnesses)
    
    @property
    def universe(self) -> Set[int]:
        """Union of all witness sets."""
        result: Set[int] = set()
        for wset in self.witnesses.values():
            result |= wset
        return result
    
    @property
    def universe_size(self) -> int:
        return max(max(wset) for wset in self.witnesses.values() if wset) + 1


def verify_dark(family: DarkWitnessFamily) -> Tuple[bool, Optional[str]]:
    """Verify that a witness family satisfies the dark properties.
    
    Returns:
        (is_valid, error_message) where error_message is None if valid.
    
    Time complexity: O(m * N) where m = worlds, N = universe size.
    """
    if family.level <= 0:
        return False, "Level must be positive"
    
    # Check sufficiency condition
    for world, wset in family.witnesses.items():
        if len(wset) < family.level:
            return False, f"World {world}: {len(wset)} < {family.level} witnesses"
    
    # Check universality negation
    universe = family.universe
    for n in universe:
        if all(n in wset for wset in family.witnesses.values()):
            return False, f"Element {n} is universal"
    
    return True, None


def compute_shadow(family: DarkWitnessFamily) -> Set[int]:
    """Compute the shadow: elements in ALL witness sets.
    
    For valid dark families, this is always empty (Shadow Emptiness Theorem).
    
    Time complexity: O(N * m).
    """
    universe = family.universe
    return {n for n in universe 
            if all(n in wset for wset in family.witnesses.values())}


def compute_spectrum(family: DarkWitnessFamily, N: int) -> Dict[int, Set[int]]:
    """Compute the darkness spectrum: for each element, which worlds contain it.
    
    The spectrum of element n is the set of worlds where n is a witness.
    By the Spectrum Bound theorem, |spec(n)| < m for all n.
    
    Time complexity: O(N * m).
    """
    spectrum: Dict[int, Set[int]] = {}
    for n in range(N):
        spectrum[n] = {w for w, wset in family.witnesses.items() if n in wset}
    return spectrum


def spectral_gap(family: DarkWitnessFamily) -> int:
    """Compute the spectral gap: max|spec(n)| - min|spec(n)| over active elements.
    
    For extremal families, the spectral gap is conjectured to be 0.
    """
    N = family.universe_size
    spectrum = compute_spectrum(family, N)
    active = {n: s for n, s in spectrum.items() if len(s) > 0}
    if not active:
        return 0
    sizes = [len(s) for s in active.values()]
    return max(sizes) - min(sizes)


# ============================================================
# Construction algorithms
# ============================================================

def construct_two_world(k: int) -> DarkWitnessFamily:
    """Construct the canonical two-world dark family at level k.
    
    World 0: {0, ..., k-1}
    World 1: {k, ..., 2k-1}
    
    Time complexity: O(k).
    """
    return DarkWitnessFamily(
        witnesses={0: set(range(k)), 1: set(range(k, 2 * k))},
        level=k
    )


def construct_complementary_blocks(m: int, N: int) -> DarkWitnessFamily:
    """Construct the extremal dark family via complementary block partition.
    
    Achieves the maximum darkness level N - N/m when m | N.
    World i gets all elements except block i = {i*q, ..., (i+1)*q - 1} where q = N/m.
    
    Precondition: m >= 2, m | N, N > 0.
    Time complexity: O(N).
    """
    assert m >= 2 and N > 0 and N % m == 0
    q = N // m
    universe = set(range(N))
    witnesses: Dict[int, Set[int]] = {}
    for i in range(m):
        block = set(range(i * q, (i + 1) * q))
        witnesses[i] = universe - block
    return DarkWitnessFamily(witnesses=witnesses, level=N - q)


def construct_product(d1: DarkWitnessFamily, d2: DarkWitnessFamily) -> DarkWitnessFamily:
    """Construct the product of two dark families with disjoint witness ranges.
    
    The product family has level = d1.level + d2.level.
    Worlds are indexed by pairs (a, b).
    
    Precondition: witness ranges of d1 and d2 are disjoint.
    Time complexity: O(m1 * m2 * N).
    """
    witnesses: Dict[Tuple[int, int], Set[int]] = {}
    for a, w1 in d1.witnesses.items():
        for b, w2 in d2.witnesses.items():
            witnesses[(a, b)] = w1 | w2
    return DarkWitnessFamily(
        witnesses=witnesses,
        level=d1.level + d2.level
    )


# ============================================================
# Analysis algorithms
# ============================================================

def dark_inequality_bound(m: int, N: int) -> int:
    """Maximum darkness level allowed by the Dark Inequality.
    
    k <= N * (m-1) / m, so max k = floor(N * (m-1) / m).
    """
    return N * (m - 1) // m


def find_max_darkness(m: int, N: int) -> Tuple[int, Optional[DarkWitnessFamily]]:
    """Find the maximum achievable darkness level for m worlds and N elements.
    
    Uses greedy construction: distribute elements to maximize minimum coverage.
    Returns (max_level, achieving_family).
    
    Time complexity: O(N * m) for the greedy construction.
    """
    # Greedy: assign each element to m-1 worlds, cycling which world is excluded
    witnesses: Dict[int, Set[int]] = {i: set() for i in range(m)}
    for n in range(N):
        excluded = n % m  # Exclude world (n mod m) for element n
        for i in range(m):
            if i != excluded:
                witnesses[i].add(n)
    
    min_size = min(len(wset) for wset in witnesses.values())
    family = DarkWitnessFamily(witnesses=witnesses, level=min_size)
    
    valid, _ = verify_dark(family)
    if valid:
        return min_size, family
    return 0, None


def enumerate_all_dark_families(m: int, N: int, level: int) -> List[DarkWitnessFamily]:
    """Enumerate all dark families over Fin m with N-bounded witnesses at given level.
    
    Warning: exponential in N and m. Only use for small parameters.
    """
    from itertools import combinations
    
    results: List[DarkWitnessFamily] = []
    universe = set(range(N))
    
    # Each world must have at least `level` elements from {0,...,N-1}
    # and no element can be in all worlds
    possible_sets = [s for r in range(level, N + 1) 
                     for s in combinations(range(N), r)]
    
    # Too many combinations for large parameters
    if len(possible_sets) ** m > 100000:
        return results
    
    from itertools import product
    for combo in product(possible_sets, repeat=m):
        witnesses = {i: set(combo[i]) for i in range(m)}
        family = DarkWitnessFamily(witnesses=witnesses, level=level)
        valid, _ = verify_dark(family)
        if valid:
            results.append(family)
    
    return results


if __name__ == "__main__":
    # Quick verification of all algorithms
    print("Testing algorithms...")
    
    # Two-world family
    for k in [1, 5, 10, 100]:
        f = construct_two_world(k)
        valid, err = verify_dark(f)
        assert valid, f"Two-world family at level {k} failed: {err}"
        assert compute_shadow(f) == set(), "Shadow not empty!"
    
    # Complementary blocks
    for m, N in [(2, 10), (3, 12), (4, 20), (5, 25)]:
        f = construct_complementary_blocks(m, N)
        valid, err = verify_dark(f)
        assert valid, f"Block partition m={m} N={N} failed: {err}"
        assert f.level == N - N // m
        gap = spectral_gap(f)
        assert gap == 0, f"Extremal family has nonzero spectral gap: {gap}"
    
    # Product
    d1 = construct_two_world(3)
    d2 = DarkWitnessFamily(
        witnesses={0: {10, 11, 12, 13}, 1: {14, 15, 16, 17}},
        level=4
    )
    prod = construct_product(d1, d2)
    valid, err = verify_dark(prod)
    assert valid, f"Product failed: {err}"
    assert prod.level == 7
    
    # Dark inequality
    for m in range(2, 6):
        for N in range(m, 5 * m, m):
            bound = dark_inequality_bound(m, N)
            level, fam = find_max_darkness(m, N)
            assert level <= bound, f"Exceeded bound! m={m} N={N}"
            assert level == bound, f"Didn't achieve bound m={m} N={N}: {level} < {bound}"
    
    print("All algorithm tests passed!")
