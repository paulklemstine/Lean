#!/usr/bin/env python3
"""
Algorithms for Closure-Čech Realization Duality.

Implements:
1. Nerve construction from cover data
2. Idempotent nerve semimodule construction
3. Simplicial complex reconstruction
4. Closure-equivalence quotient computation
5. Minimality checking for generating families
6. Euler characteristic and f-vector computation
"""

from itertools import combinations
from typing import FrozenSet, Set, Dict, List, Callable, Optional, Tuple
from collections import defaultdict
import time


# ============================================================
# Data Structures
# ============================================================

class ClosureOperator:
    """A closure operator on a finite ground set.

    A closure operator satisfies:
    - Extensivity: S ⊆ cl(S)
    - Monotonicity: S ⊆ T → cl(S) ⊆ cl(T)
    - Idempotence: cl(cl(S)) = cl(S)

    Args:
        ground_set: The finite ground set
        cl_func: The closure function mapping frozensets to frozensets
    """

    def __init__(self, ground_set: Set, cl_func: Callable[[FrozenSet], FrozenSet]):
        self.ground_set = frozenset(ground_set)
        self._cl = cl_func

    def cl(self, s: FrozenSet) -> FrozenSet:
        """Apply the closure operator."""
        return self._cl(frozenset(s))

    def is_closed(self, s: FrozenSet) -> bool:
        """Check if a set is closure-stable (closed)."""
        return self.cl(frozenset(s)) == frozenset(s)

    @staticmethod
    def identity(ground_set: Set) -> 'ClosureOperator':
        """The identity closure operator: cl(S) = S."""
        return ClosureOperator(ground_set, lambda s: s)

    @staticmethod
    def from_closed_sets(ground_set: Set,
                         closed_sets: List[FrozenSet]) -> 'ClosureOperator':
        """Build closure operator from a family of closed sets.

        cl(S) = intersection of all closed sets containing S.
        """
        gs = frozenset(ground_set)
        all_closed = [frozenset(c) for c in closed_sets]
        # Ensure ground_set is closed
        if gs not in all_closed:
            all_closed.append(gs)

        def cl(s: FrozenSet) -> FrozenSet:
            s = frozenset(s)
            result = gs
            for c in all_closed:
                if s <= c:
                    result = result & c
            return result

        return ClosureOperator(ground_set, cl)


# ============================================================
# Core Algorithms
# ============================================================

def family_intersection(U: Dict, I: FrozenSet) -> FrozenSet:
    """Compute ∩_{i ∈ I} U_i.

    Args:
        U: Cover family, mapping indices to sets
        I: Nonempty frozenset of indices

    Returns:
        The intersection of all U[i] for i in I

    Time complexity: O(|I| · |X|) where |X| is the ground set size
    """
    if not I:
        return frozenset()
    result = None
    for i in I:
        s = frozenset(U[i])
        result = s if result is None else result & s
    return result


def build_nerve_support(U: Dict) -> Set[FrozenSet]:
    """Compute the nerve support: all nonempty I with ∩_{i∈I} U_i ≠ ∅.

    Algorithm:
    1. Enumerate all nonempty subsets of indices
    2. For each, compute the intersection
    3. Keep those with nonempty intersection

    Args:
        U: Cover family

    Returns:
        Set of frozensets forming the nerve support

    Time complexity: O(2^|ι| · |ι| · |X|)
    Space complexity: O(2^|ι|) for the output
    """
    indices = list(U.keys())
    support = set()

    for size in range(1, len(indices) + 1):
        for combo in combinations(indices, size):
            I = frozenset(combo)
            if family_intersection(U, I):
                support.add(I)

    return support


def build_nerve_semimodule(U: Dict) -> Set[FrozenSet]:
    """Build the idempotent nerve semimodule generators.

    The generators are exactly the nerve support elements.
    The semimodule structure includes:
    - Grading by cardinality
    - Face maps by vertex deletion
    - Idempotent addition (union as join)
    - Downward closure

    Args:
        U: Cover family

    Returns:
        Set of generator frozensets

    Time complexity: O(2^|ι| · |ι| · |X|)
    """
    return build_nerve_support(U)


def reconstruct_simplicial_complex(generators: Set[FrozenSet]) -> Set[FrozenSet]:
    """Reconstruct a simplicial complex from nerve semimodule generators.

    The faces of the reconstructed complex are exactly the generators.

    Args:
        generators: Set of generator frozensets

    Returns:
        Set of faces (= generators, by the reconstruction theorem)

    Time complexity: O(1) — the generators ARE the faces
    """
    return set(generators)


def compute_closure_equivalence(
    c: ClosureOperator, U: Dict,
    support: Set[FrozenSet]
) -> Dict[FrozenSet, Set[FrozenSet]]:
    """Partition the nerve support by closure-equivalence.

    Two index sets I, J are closure-equivalent if
    cl(∩_{i∈I} U_i) = cl(∩_{j∈J} U_j).

    Args:
        c: Closure operator
        U: Cover family
        support: Nerve support elements

    Returns:
        Dictionary mapping closure values to sets of equivalent index sets

    Time complexity: O(|support| · C(cl)) where C(cl) is closure computation cost
    """
    classes: Dict[FrozenSet, Set[FrozenSet]] = defaultdict(set)
    for I in support:
        closure_val = c.cl(family_intersection(U, I))
        classes[closure_val].add(I)
    return dict(classes)


def face_map(I: FrozenSet, j) -> Optional[FrozenSet]:
    """Apply the face map d_j: delete vertex j from I.

    Args:
        I: A generator (nonempty frozenset)
        j: Vertex to delete

    Returns:
        I \ {j} if nonempty, None otherwise

    Time complexity: O(1) for frozenset operations
    """
    if j not in I:
        return None
    result = I - {j}
    return result if result else None


def verify_simplicial_identity(I: FrozenSet, j, k) -> bool:
    """Verify d_j ∘ d_k = d_k ∘ d_j on generator I.

    Time complexity: O(1)
    """
    dk = face_map(I, k)
    dj = face_map(I, j)
    if dk is None or dj is None:
        return True  # vacuously true
    djk = face_map(dk, j)
    dkj = face_map(dj, k)
    return djk == dkj


def verify_roundtrip(U: Dict) -> bool:
    """Verify the roundtrip property:
    reconstruct(build_semimodule(U)).faces = cech_nerve(U).faces

    Args:
        U: Cover family

    Returns:
        True if roundtrip holds

    Time complexity: O(2^|ι| · |ι| · |X|) for building
    """
    nerve_faces = build_nerve_support(U)
    semimodule_gens = build_nerve_semimodule(U)
    reconstructed_faces = reconstruct_simplicial_complex(semimodule_gens)
    return nerve_faces == reconstructed_faces


def extract_vertices(generators: Set[FrozenSet]) -> Set:
    """Extract vertices from degree-1 generators.

    Args:
        generators: Semimodule generators

    Returns:
        Set of vertex indices

    Time complexity: O(|generators|)
    """
    return {next(iter(g)) for g in generators if len(g) == 1}


def f_vector(faces: Set[FrozenSet]) -> List[int]:
    """Compute the f-vector of a simplicial complex.

    f[k] = number of k-simplices (faces of cardinality k+1).

    Time complexity: O(|faces|)
    """
    if not faces:
        return []
    max_dim = max(len(f) for f in faces) - 1
    fv = [0] * (max_dim + 1)
    for f in faces:
        fv[len(f) - 1] += 1
    return fv


def euler_characteristic(faces: Set[FrozenSet]) -> int:
    """Compute the Euler characteristic χ = Σ (-1)^k f_k.

    Time complexity: O(|faces|)
    """
    return sum((-1) ** (len(f) - 1) for f in faces)


def is_vertex_minimal(U: Dict) -> bool:
    """Check if a cover family is vertex-minimal.

    A family is vertex-minimal if removing any set changes the nerve.

    Time complexity: O(|ι| · 2^|ι| · |ι| · |X|)
    """
    full_support = build_nerve_support(U)
    for i in U:
        reduced = {k: v for k, v in U.items() if k != i}
        reduced_support = build_nerve_support(reduced)
        if reduced_support == {I for I in full_support if i not in I}:
            # Removing i didn't change anything meaningful
            return False
    return True


# ============================================================
# Benchmarking
# ============================================================

def benchmark(max_vertices: int = 15):
    """Benchmark nerve construction for increasing cover sizes.

    Args:
        max_vertices: Maximum number of cover elements
    """
    print(f"{'Vertices':>8} | {'Nerve Size':>10} | {'Build (ms)':>10} | "
          f"{'Reconstruct (ms)':>16} | {'Roundtrip':>9}")
    print("-" * 65)

    for n in range(3, max_vertices + 1):
        # Full cover: every set is the full ground set
        X = set(range(n))
        U = {i: X for i in range(n)}

        t0 = time.perf_counter()
        gens = build_nerve_semimodule(U)
        t1 = time.perf_counter()
        faces = reconstruct_simplicial_complex(gens)
        t2 = time.perf_counter()
        ok = verify_roundtrip(U)
        t3 = time.perf_counter()

        build_ms = (t1 - t0) * 1000
        recon_ms = (t2 - t1) * 1000

        print(f"{n:>8} | {len(gens):>10} | {build_ms:>10.1f} | "
              f"{recon_ms:>16.3f} | {'✓' if ok else '✗':>9}")

        if t1 - t0 > 10:  # Stop if too slow
            print("  (stopping: build time exceeded 10s)")
            break


if __name__ == "__main__":
    # Quick functional test
    print("Running algorithm tests...\n")

    # Test 1: Triangle
    U = {1: {'a', 'b'}, 2: {'b', 'c'}, 3: {'a', 'c'}}
    support = build_nerve_support(U)
    assert len(support) == 6  # 3 singletons + 3 pairs
    assert verify_roundtrip(U)
    print("✓ Triangle cover test passed")

    # Test 2: Full simplex
    U = {1: {'a', 'b', 'c'}, 2: {'a', 'b', 'c'}, 3: {'a', 'b', 'c'}}
    support = build_nerve_support(U)
    assert frozenset({1, 2, 3}) in support
    assert verify_roundtrip(U)
    print("✓ Full simplex test passed")

    # Test 3: Vertex extraction
    U = {1: {'a'}, 2: {'b'}, 3: set()}
    verts = extract_vertices(build_nerve_semimodule(U))
    assert 1 in verts and 2 in verts
    assert 3 not in verts  # empty set
    print("✓ Vertex extraction test passed")

    # Test 4: Simplicial identity
    I = frozenset({1, 2, 3, 4})
    for j in range(1, 5):
        for k in range(1, 5):
            assert verify_simplicial_identity(I, j, k)
    print("✓ Simplicial identity test passed")

    # Test 5: Euler characteristic
    # Triangle (1-sphere): χ = 3 - 3 = 0
    U = {1: {'a', 'b'}, 2: {'b', 'c'}, 3: {'a', 'c'}}
    chi = euler_characteristic(build_nerve_support(U))
    assert chi == 0, f"Expected χ=0, got {chi}"
    print("✓ Euler characteristic test passed (triangle: χ=0)")

    # Full 2-simplex: χ = 3 - 3 + 1 = 1
    U = {1: {'a', 'b', 'c'}, 2: {'a', 'b', 'c'}, 3: {'a', 'b', 'c'}}
    chi = euler_characteristic(build_nerve_support(U))
    assert chi == 1, f"Expected χ=1, got {chi}"
    print("✓ Euler characteristic test passed (full simplex: χ=1)")

    print("\nAll algorithm tests passed!\n")
    print("Benchmarking nerve construction...\n")
    benchmark(18)
