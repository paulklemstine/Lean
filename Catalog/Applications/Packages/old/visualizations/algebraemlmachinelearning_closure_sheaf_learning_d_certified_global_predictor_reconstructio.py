#!/usr/bin/env python3
"""
Algorithms: Closure-Sheaf Learning Duality
==========================================
Complete implementations of the certified reconstruction algorithm
and obstruction detection for finite local-to-global predictor systems.
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional, Set
from enum import Enum


# ============================================================
# Algorithm 1: Finite Poset Construction & Transitive Closure
# ============================================================

class FinitePoset:
    """
    A finite partially ordered set with efficient comparison.

    Time complexity:
        - Construction: O(n³) for transitive closure (Floyd-Warshall)
        - Comparison: O(1) via lookup table

    Space complexity: O(n²) for the comparison matrix
    """
    def __init__(self, elements: List[str], relations: List[Tuple[str, str]]):
        self.elements = elements
        self.n = len(elements)
        self.idx = {e: i for i, e in enumerate(elements)}

        # Build adjacency matrix and compute transitive closure
        self.matrix = np.eye(self.n, dtype=bool)
        for (a, b) in relations:
            self.matrix[self.idx[a], self.idx[b]] = True

        # Floyd-Warshall transitive closure
        for k in range(self.n):
            for i in range(self.n):
                for j in range(self.n):
                    if self.matrix[i, k] and self.matrix[k, j]:
                        self.matrix[i, j] = True

    def leq(self, i: str, j: str) -> bool:
        """Check i ≤ j in O(1)."""
        return bool(self.matrix[self.idx[i], self.idx[j]])

    def comparable_pairs(self) -> List[Tuple[str, str]]:
        """Return all pairs (i, j) with i ≤ j and i ≠ j."""
        pairs = []
        for i in self.elements:
            for j in self.elements:
                if i != j and self.leq(i, j):
                    pairs.append((i, j))
        return pairs

    def hasse_diagram(self) -> List[Tuple[str, str]]:
        """Return covering relations (edges of the Hasse diagram)."""
        covers = []
        for i in self.elements:
            for j in self.elements:
                if i != j and self.leq(i, j):
                    # Check if there's an intermediate element
                    is_cover = True
                    for k in self.elements:
                        if k != i and k != j and self.leq(i, k) and self.leq(k, j):
                            is_cover = False
                            break
                    if is_cover:
                        covers.append((i, j))
        return covers


# ============================================================
# Algorithm 2: Local System with Linear Restriction Maps
# ============================================================

@dataclass
class LocalSystem:
    """
    A local system (presheaf) over a finite poset with linear restriction maps.

    Fibers are finite-dimensional real vector spaces.
    Restriction maps are linear maps (matrices).
    """
    poset: FinitePoset
    fiber_dims: Dict[str, int]
    restriction_maps: Dict[Tuple[str, str], np.ndarray]

    def res(self, i: str, j: str, x: np.ndarray) -> np.ndarray:
        """
        Restrict section from j to i (requires i ≤ j).

        Time: O(d_i * d_j) for matrix multiplication.
        """
        if i == j:
            return x.copy()
        return self.restriction_maps[(i, j)] @ x

    def verify_functoriality(self, tol: float = 1e-10) -> bool:
        """
        Verify res_id and res_comp axioms.

        Time: O(n³ * d_max³) where n = |P|, d_max = max fiber dim.
        """
        # Check res_id
        for e in self.poset.elements:
            d = self.fiber_dims[e]
            test = np.random.randn(d)
            if not np.allclose(self.res(e, e, test), test, atol=tol):
                return False

        # Check res_comp
        for i in self.poset.elements:
            for j in self.poset.elements:
                for k in self.poset.elements:
                    if (self.poset.leq(i, j) and self.poset.leq(j, k)
                            and i != j and j != k):
                        d_k = self.fiber_dims[k]
                        test = np.random.randn(d_k)
                        comp = self.res(i, j, self.res(j, k, test))
                        direct = self.res(i, k, test)
                        if not np.allclose(comp, direct, atol=tol):
                            return False
        return True


# ============================================================
# Algorithm 3: Certified Predictor Reconstruction
# ============================================================

class ReconstructionResult(Enum):
    SUCCESS = "success"
    OBSTRUCTION = "obstruction"


@dataclass
class ObstructionCertificate:
    """A certificate that an atlas cannot be globally realized."""
    i: str
    j: str
    expected: np.ndarray
    actual: np.ndarray
    discrepancy: float


@dataclass
class GlobalPredictor:
    """A global section of the local system."""
    sections: Dict[str, np.ndarray]


def reconstruct_global_predictor(
    system: LocalSystem,
    local_data: Dict[str, np.ndarray],
    tol: float = 1e-10
) -> Tuple[ReconstructionResult, Optional[GlobalPredictor], Optional[ObstructionCertificate]]:
    """
    Certified global predictor reconstruction.

    Given local data at each point of the poset, either:
    1. Construct a global predictor (if pairwise compatible), or
    2. Return an obstruction certificate (if not).

    Algorithm:
        For each comparable pair (i, j) with i ≤ j:
            Check if res(i,j)(data_j) = data_i
            If not, return obstruction certificate
        If all checks pass, return the atlas as a global section.

    Time complexity: O(n² * d_max²) where n = |P|, d_max = max fiber dimension.
    Space complexity: O(n * d_max) for storing the global section.

    This implements the certified reconstruction theorem:
        reconstructGlobalPredictor_correct_inl / _correct_inr
    """
    for (i, j) in system.poset.comparable_pairs():
        restricted = system.res(i, j, local_data[j])
        expected = local_data[i]
        if not np.allclose(restricted, expected, atol=tol):
            discrepancy = float(np.linalg.norm(restricted - expected))
            cert = ObstructionCertificate(
                i=i, j=j,
                expected=expected,
                actual=restricted,
                discrepancy=discrepancy
            )
            return ReconstructionResult.OBSTRUCTION, None, cert

    return ReconstructionResult.SUCCESS, GlobalPredictor(sections=local_data.copy()), None


# ============================================================
# Algorithm 4: Compatibility Cocycle Computation
# ============================================================

def compute_compatibility_cocycle(
    system: LocalSystem,
    local_data: Dict[str, np.ndarray]
) -> Dict[Tuple[str, str], np.ndarray]:
    """
    Compute the compatibility cocycle of an atlas.

    For each comparable pair (i, j), the cocycle value is:
        δ(i, j) = res(i,j)(data_j) - data_i

    The cocycle vanishes (all values zero) iff the atlas is globally realizable.

    Time: O(n² * d_max²)
    Space: O(n² * d_max) for storing cocycle values.
    """
    cocycle = {}
    for (i, j) in system.poset.comparable_pairs():
        restricted = system.res(i, j, local_data[j])
        cocycle[(i, j)] = restricted - local_data[i]
    return cocycle


def cocycle_vanishes(cocycle: Dict[Tuple[str, str], np.ndarray],
                     tol: float = 1e-10) -> bool:
    """Check if the compatibility cocycle vanishes."""
    return all(np.allclose(v, 0, atol=tol) for v in cocycle.values())


# ============================================================
# Algorithm 5: Idempotent Aggregation
# ============================================================

def idempotent_max_aggregate(sections: List[np.ndarray]) -> np.ndarray:
    """
    Aggregate local sections using idempotent (max) addition.

    In the max-tropical semiring, a ⊕ b = max(a, b) componentwise.
    This operation is idempotent: a ⊕ a = a.

    Time: O(k * d) where k = number of sections, d = dimension.
    """
    result = sections[0].copy()
    for s in sections[1:]:
        result = np.maximum(result, s)
    return result


def idempotent_min_aggregate(sections: List[np.ndarray]) -> np.ndarray:
    """
    Aggregate using min-plus (dual tropical) idempotent addition.

    a ⊕ b = min(a, b) componentwise. Also idempotent.
    """
    result = sections[0].copy()
    for s in sections[1:]:
        result = np.minimum(result, s)
    return result


# ============================================================
# Algorithm 6: Greedy Finite Gluing
# ============================================================

def greedy_finite_gluing(
    system: LocalSystem,
    local_data: Dict[str, np.ndarray],
    tol: float = 1e-10
) -> Tuple[bool, Dict[str, np.ndarray], List[str]]:
    """
    Greedy finite gluing: attempt to build a global section incrementally.

    Process elements in topological order (bottom-up).
    At each step, verify compatibility with already-glued elements.

    Returns:
        (success, global_section, processing_order)

    Time: O(n² * d_max²) — same as direct verification but
          provides the gluing order for diagnostic purposes.
    """
    # Topological sort (bottom elements first)
    remaining = set(system.poset.elements)
    order = []
    while remaining:
        # Find minimal elements
        minimals = []
        for e in remaining:
            is_minimal = True
            for f in remaining:
                if f != e and system.poset.leq(f, e) and not system.poset.leq(e, f):
                    is_minimal = False
                    break
            if is_minimal:
                minimals.append(e)
        order.extend(sorted(minimals))
        remaining -= set(minimals)

    # Glue incrementally
    glued = {}
    for elem in order:
        glued[elem] = local_data[elem].copy()
        # Check compatibility with all previously glued elements below
        for prev in list(glued.keys())[:-1]:
            if system.poset.leq(prev, elem):
                restricted = system.res(prev, elem, glued[elem])
                if not np.allclose(restricted, glued[prev], atol=tol):
                    return False, glued, order

    return True, glued, order


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Closure-Sheaf Learning Duality — Algorithm Suite")
    print("=" * 55)

    # Build a test poset: chain a ≤ b ≤ c
    poset = FinitePoset(['a', 'b', 'c'], [('a', 'b'), ('b', 'c')])
    print(f"\nPoset elements: {poset.elements}")
    print(f"Hasse diagram: {poset.hasse_diagram()}")
    print(f"All comparable pairs: {poset.comparable_pairs()}")

    # Build local system
    res_ab = np.array([[1, 0, 0], [0, 1, 0]])
    res_bc = np.eye(3)
    system = LocalSystem(
        poset=poset,
        fiber_dims={'a': 2, 'b': 3, 'c': 3},
        restriction_maps={
            ('a', 'b'): res_ab,
            ('b', 'c'): res_bc,
            ('a', 'c'): res_ab @ res_bc
        }
    )
    print(f"\nFunctoriality check: {system.verify_functoriality()}")

    # Test 1: Compatible atlas
    print("\n--- Test 1: Compatible Atlas ---")
    data_c = np.array([1.0, 2.0, 3.0])
    data_b = res_bc @ data_c
    data_a = res_ab @ data_b
    local_data = {'a': data_a, 'b': data_b, 'c': data_c}

    result, predictor, cert = reconstruct_global_predictor(system, local_data)
    print(f"Result: {result.value}")
    if predictor:
        for k, v in predictor.sections.items():
            print(f"  Section at {k}: {v}")

    cocycle = compute_compatibility_cocycle(system, local_data)
    print(f"Cocycle vanishes: {cocycle_vanishes(cocycle)}")

    success, glued, order = greedy_finite_gluing(system, local_data)
    print(f"Greedy gluing: success={success}, order={order}")

    # Test 2: Incompatible atlas
    print("\n--- Test 2: Incompatible Atlas ---")
    bad_data = {'a': np.array([5.0, 7.0]),
                'b': np.array([1.0, 2.0, 3.0]),
                'c': np.array([1.0, 2.0, 3.0])}

    result, predictor, cert = reconstruct_global_predictor(system, bad_data)
    print(f"Result: {result.value}")
    if cert:
        print(f"  Obstruction at ({cert.i}, {cert.j})")
        print(f"  Expected: {cert.expected}, Got: {cert.actual}")
        print(f"  Discrepancy: {cert.discrepancy:.4f}")

    cocycle = compute_compatibility_cocycle(system, bad_data)
    print(f"Cocycle vanishes: {cocycle_vanishes(cocycle)}")
    for (i, j), v in cocycle.items():
        if not np.allclose(v, 0):
            print(f"  Non-zero cocycle at ({i},{j}): {v}")

    # Test 3: Idempotent aggregation
    print("\n--- Test 3: Idempotent Aggregation ---")
    sections = [np.array([3, 1, 4]), np.array([1, 5, 2]), np.array([2, 3, 6])]
    agg = idempotent_max_aggregate(sections)
    print(f"Max-aggregate of {sections}: {agg}")
    print(f"Idempotent check (agg ⊕ agg = agg): {np.allclose(np.maximum(agg, agg), agg)}")

    print("\nAll algorithms completed successfully!")
