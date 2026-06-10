#!/usr/bin/env python3
"""
Anti-Mathematics: Core Algorithms

Type-hinted implementations of the key algorithms from the anti-mathematics
research program.
"""

from typing import Dict, List, Set, Tuple, Optional, FrozenSet
from dataclasses import dataclass
import itertools


# ===========================================================================
# Algorithm 1: Ackermann Encoding / Decoding
# ===========================================================================

def ackermann_encode(elements: Set[int]) -> int:
    """
    Encode a hereditarily finite set (given as a set of natural numbers)
    into its Ackermann number.
    
    The encoding: {a₁, a₂, ..., aₖ} → 2^a₁ + 2^a₂ + ... + 2^aₖ
    
    Time complexity: O(k) where k = |elements|
    Space complexity: O(1) additional (the result may be exponentially large)
    
    Args:
        elements: Set of natural number indices representing the members
        
    Returns:
        The Ackermann encoding as a natural number
    """
    return sum(1 << m for m in elements)


def ackermann_decode(n: int) -> Set[int]:
    """
    Decode an Ackermann number into its set of members.
    
    Time complexity: O(log n)
    Space complexity: O(log n) for the output set
    
    Args:
        n: Non-negative integer (Ackermann encoding)
        
    Returns:
        Set of member indices
    """
    members: Set[int] = set()
    i = 0
    while n > 0:
        if n & 1:
            members.add(i)
        n >>= 1
        i += 1
    return members


def ackermann_membership(m: int, n: int) -> bool:
    """Check if m ∈ₐ n in the Ackermann encoding."""
    return bool((n >> m) & 1)


def ackermann_union(a: int, b: int) -> int:
    """Compute a ∪ b in the Ackermann encoding (bitwise OR)."""
    return a | b


def ackermann_intersection(a: int, b: int) -> int:
    """Compute a ∩ b in the Ackermann encoding (bitwise AND)."""
    return a & b


def ackermann_difference(a: int, b: int) -> int:
    """Compute a \\ b in the Ackermann encoding."""
    return a & ~b


def ackermann_symmetric_difference(a: int, b: int) -> int:
    """Compute a △ b in the Ackermann encoding (bitwise XOR)."""
    return a ^ b


def ackermann_subset(a: int, b: int) -> bool:
    """Check if a ⊆ b in the Ackermann encoding."""
    return (a & b) == a


def ackermann_powerset(n: int, max_member: int) -> int:
    """
    Compute the power set of n in the Ackermann encoding.
    Since the power set of {a₁,...,aₖ} has 2^k elements, each of which
    is a subset encoded as a number, the result encodes the set of all
    these subset-encodings.
    
    Warning: Grows doubly-exponentially. Only practical for small inputs.
    
    Args:
        n: Ackermann encoding of the input set
        max_member: Upper bound on the elements (for termination)
    
    Returns:
        Ackermann encoding of the power set
    """
    members = ackermann_decode(n)
    subsets: Set[int] = set()
    member_list = sorted(members)
    
    for r in range(len(member_list) + 1):
        for combo in itertools.combinations(member_list, r):
            subsets.add(ackermann_encode(set(combo)))
    
    return ackermann_encode(subsets)


# ===========================================================================
# Algorithm 2: Phantom Index Computation
# ===========================================================================

@dataclass
class MembrshipStructure:
    """A finite membership structure on {0, 1, ..., n-1}."""
    n: int
    rel: List[List[bool]]  # rel[x][y] means x ∈ y
    
    def ext_equiv(self, a: int, b: int) -> bool:
        """Check if a and b are extensionally equivalent."""
        return all(self.rel[x][a] == self.rel[x][b] for x in range(self.n))
    
    def ext_classes(self) -> List[FrozenSet[int]]:
        """Compute the extensional equivalence classes."""
        assigned = [False] * self.n
        classes: List[FrozenSet[int]] = []
        
        for i in range(self.n):
            if assigned[i]:
                continue
            eq_class = {i}
            for j in range(i + 1, self.n):
                if not assigned[j] and self.ext_equiv(i, j):
                    eq_class.add(j)
                    assigned[j] = True
            classes.append(frozenset(eq_class))
            assigned[i] = True
        
        return classes
    
    def phantom_index(self) -> int:
        """Compute the phantom index: n - |equivalence classes|."""
        return self.n - len(self.ext_classes())
    
    def is_anti_extensional(self) -> bool:
        """Check if the structure is anti-extensional."""
        return self.phantom_index() > 0
    
    def is_extensional(self) -> bool:
        """Check if the structure satisfies extensionality."""
        return self.phantom_index() == 0


def compute_phantom_index(n: int, rel: List[List[bool]]) -> int:
    """
    Compute the phantom index of a finite membership structure.
    
    Time complexity: O(n³) — for each pair (i,j), check all x
    Space complexity: O(n)
    
    Args:
        n: Number of elements
        rel: n×n membership relation matrix
        
    Returns:
        The phantom index (non-negative integer)
    """
    return MembrshipStructure(n, rel).phantom_index()


# ===========================================================================
# Algorithm 3: Eventual Idempotent Finder
# ===========================================================================

def find_eventual_idempotent(f: Dict[int, int]) -> Tuple[int, Dict[int, int]]:
    """
    Find the smallest N > 0 such that f^[N] is idempotent.
    
    Time complexity: O(n² · N) where n = |domain| and N is the result
    Space complexity: O(n)
    
    Args:
        f: A function on a finite set, given as a dictionary
        
    Returns:
        Tuple of (N, f^[N] as a dictionary)
    """
    domain = sorted(f.keys())
    n = len(domain)
    
    def iterate(x: int, k: int) -> int:
        result = x
        for _ in range(k):
            result = f[result]
        return result
    
    for N in range(1, n * n + 1):
        fn = {x: iterate(x, N) for x in domain}
        if all(fn[fn[x]] == fn[x] for x in domain):
            return N, fn
    
    # Fallback (should never reach here for finite functions)
    raise ValueError("No idempotent iterate found (this should not happen)")


def find_iterate_collision(f: Dict[int, int]) -> Tuple[int, int]:
    """
    Find m < n such that f^[m] = f^[n] as functions.
    Uses Floyd's cycle detection on the space of functions.
    
    Args:
        f: A function on a finite set
        
    Returns:
        Tuple (m, n) with m < n and f^[m] = f^[n]
    """
    domain = sorted(f.keys())
    
    def iterate_all(k: int) -> Tuple[int, ...]:
        return tuple(
            (lambda x, k=k: (
                result := x,
                [result := f[result] for _ in range(k)],  # type: ignore
                result
            )[-1])()
            for x in domain
        )
    
    # Simple approach: compute iterates until collision
    seen: Dict[Tuple[int, ...], int] = {}
    for k in range(len(domain) ** len(domain) + 1):
        fn_tuple = tuple(
            _iterate_single(f, x, k) for x in domain
        )
        if fn_tuple in seen:
            return seen[fn_tuple], k
        seen[fn_tuple] = k
    
    raise ValueError("No collision found")


def _iterate_single(f: Dict[int, int], x: int, k: int) -> int:
    """Helper: compute f^[k](x)."""
    result = x
    for _ in range(k):
        result = f[result]
    return result


# ===========================================================================
# Algorithm 4: Axiom Defect Spectrum Analysis
# ===========================================================================

@dataclass
class AxiomDefectSpectrum:
    """An axiom defect spectrum for n axioms."""
    defects: List[float]  # Each in [0, 1]
    names: Optional[List[str]] = None
    
    def __post_init__(self):
        for d in self.defects:
            assert 0 <= d <= 1, f"Defect {d} not in [0, 1]"
        if self.names is None:
            self.names = [f"Axiom_{i}" for i in range(len(self.defects))]
    
    @property
    def n(self) -> int:
        return len(self.defects)
    
    def total_defect(self) -> float:
        """Total deficiency (sum of all defects)."""
        return sum(self.defects)
    
    def is_compatible_with(self, other: 'AxiomDefectSpectrum') -> bool:
        """Check if two spectra are compatible."""
        assert self.n == other.n
        return all(
            self.defects[i] + other.defects[i] <= 1.0
            for i in range(self.n)
        )
    
    def convex_combination(self, other: 'AxiomDefectSpectrum',
                           t: float) -> 'AxiomDefectSpectrum':
        """Compute t * self + (1-t) * other."""
        assert 0 <= t <= 1
        return AxiomDefectSpectrum(
            defects=[t * self.defects[i] + (1-t) * other.defects[i]
                     for i in range(self.n)],
            names=self.names
        )


# Standard ZFC axiom names
ZFC_AXIOMS = [
    "Extensionality", "Pairing", "Union", "Power Set",
    "Infinity", "Replacement", "Foundation", "Choice"
]


def zfc_spectrum() -> AxiomDefectSpectrum:
    """The ZFC spectrum: all axioms satisfied perfectly."""
    return AxiomDefectSpectrum([0.0] * 8, ZFC_AXIOMS)


def ackermann_spectrum() -> AxiomDefectSpectrum:
    """The Ackermann model spectrum: only Infinity fails."""
    return AxiomDefectSpectrum(
        [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
        ZFC_AXIOMS
    )


def phantom_spectrum() -> AxiomDefectSpectrum:
    """The phantom universe spectrum: Extensionality and Infinity fail."""
    return AxiomDefectSpectrum(
        [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
        ZFC_AXIOMS
    )


def solovay_spectrum() -> AxiomDefectSpectrum:
    """The Solovay model spectrum: only Choice fails."""
    return AxiomDefectSpectrum(
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0],
        ZFC_AXIOMS
    )


if __name__ == "__main__":
    # Quick self-test
    print("Testing Ackermann encoding...")
    assert ackermann_decode(0) == set()
    assert ackermann_decode(1) == {0}
    assert ackermann_decode(5) == {0, 2}
    assert ackermann_encode({0, 2}) == 5
    assert ackermann_union(5, 6) == 7  # {0,2} ∪ {1,2} = {0,1,2}
    assert ackermann_intersection(5, 6) == 4  # {0,2} ∩ {1,2} = {2}
    print("  ✓ All tests passed")
    
    print("\nTesting phantom index...")
    phantom = MembrshipStructure(2, [[False, False], [False, False]])
    assert phantom.phantom_index() == 1
    assert phantom.is_anti_extensional()
    print("  ✓ All tests passed")
    
    print("\nTesting eventual idempotence...")
    f = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3}
    N, fn = find_eventual_idempotent(f)
    assert all(fn[fn[x]] == fn[x] for x in f)
    print(f"  ✓ Found idempotent iterate N={N}")
    
    print("\nTesting axiom defect spectrum...")
    zfc = zfc_spectrum()
    ack = ackermann_spectrum()
    sol = solovay_spectrum()
    assert zfc.is_compatible_with(ack)
    assert zfc.is_compatible_with(sol)
    assert ack.is_compatible_with(sol)
    print("  ✓ All compatibility checks passed")
    
    print("\nAll algorithm tests passed! ✓")
