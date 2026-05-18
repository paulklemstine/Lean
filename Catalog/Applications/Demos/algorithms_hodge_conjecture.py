#!/usr/bin/env python3
"""
algorithms.py — Algorithms for computing with rational Hodge structures.

Implements:
1. Hodge class identification via complexification membership
2. Algebraicity testing: checking if all Hodge classes are spanned by given generators
3. Orthogonal decomposition computation for polarized structures
4. Direct sum Hodge class computation
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass, field


@dataclass
class HodgeStructureWeightTwo:
    """
    A weight-2 rational Hodge structure on a finite-dimensional ℚ-vector space V.

    Attributes:
        dim: dimension of V over ℚ
        hodge_basis: basis vectors for the Hodge class subspace Hdg(V) ⊂ V
        name: optional label for the structure

    The Hodge class subspace is represented concretely as span(hodge_basis) ⊂ ℚ^dim.
    In the abstract mathematical setting, this is V ∩ H^{1,1} under the embedding
    V → V_ℂ = ℂ ⊗_ℚ V.
    """
    dim: int
    hodge_basis: List[np.ndarray]
    name: str = ""

    @property
    def picard_rank(self) -> int:
        """The Picard rank = dimension of the Hodge class space."""
        if not self.hodge_basis:
            return 0
        return np.linalg.matrix_rank(np.column_stack(self.hodge_basis))

    def is_hodge_class(self, v: np.ndarray, tol: float = 1e-10) -> bool:
        """Check whether v is a Hodge class (i.e., v ∈ Hdg(V))."""
        if not self.hodge_basis:
            return np.linalg.norm(v) < tol
        A = np.column_stack(self.hodge_basis)
        coeffs, _, _, _ = np.linalg.lstsq(A, v, rcond=None)
        return np.linalg.norm(A @ coeffs - v) < tol

    def hodge_coefficients(self, v: np.ndarray) -> Optional[np.ndarray]:
        """
        If v is a Hodge class, return its coordinates in the Hodge basis.
        Returns None if v is not a Hodge class.
        """
        if not self.is_hodge_class(v):
            return None
        A = np.column_stack(self.hodge_basis)
        coeffs, _, _, _ = np.linalg.lstsq(A, v, rcond=None)
        return coeffs


@dataclass
class PolarizedHodgeStructure:
    """
    A polarized weight-2 rational Hodge structure.

    Adds a nondegenerate symmetric bilinear form Q (the polarization)
    to the Hodge structure data.

    Attributes:
        hodge: the underlying Hodge structure
        Q: the polarization matrix (symmetric, nondegenerate)
    """
    hodge: HodgeStructureWeightTwo
    Q: np.ndarray

    def is_nondegenerate(self) -> bool:
        """Check that Q is nondegenerate."""
        return abs(np.linalg.det(self.Q)) > 1e-10

    def is_symmetric(self) -> bool:
        """Check that Q is symmetric."""
        return np.allclose(self.Q, self.Q.T)


# ============================================================
# Algorithm 1: Algebraicity Test
# ============================================================

def test_algebraicity(
    hs: HodgeStructureWeightTwo,
    generators: List[np.ndarray],
    tol: float = 1e-10
) -> Tuple[bool, str]:
    """
    Test whether a given set of generators spans all Hodge classes.

    This implements the algorithmic content of Theorem A (Lefschetz (1,1)-style):
    given generators Z ⊂ Hdg(V), check whether span(Z) = Hdg(V).

    Algorithm:
        1. Verify all generators are Hodge classes.
        2. Compute rank of generators.
        3. Compare with Picard rank.

    Returns:
        (is_algebraic, explanation) where is_algebraic is True iff
        span(generators) = Hdg(V).

    Time complexity: O(n * k^2) where n = dim(V), k = number of generators.
    Space complexity: O(n * k).
    """
    # Step 1: Verify generators are Hodge classes
    for i, g in enumerate(generators):
        if not hs.is_hodge_class(g):
            return False, f"Generator {i} is not a Hodge class"

    # Step 2: Compute ranks
    if not generators:
        if hs.picard_rank == 0:
            return True, "No Hodge classes and no generators: trivially algebraic"
        return False, "Hodge classes exist but no generators provided"

    gen_rank = np.linalg.matrix_rank(np.column_stack(generators))
    picard_rank = hs.picard_rank

    # Step 3: Compare
    if gen_rank == picard_rank:
        return True, (f"Generators span all Hodge classes "
                      f"(rank {gen_rank} = Picard rank {picard_rank})")
    else:
        return False, (f"Generators span a proper subspace "
                       f"(rank {gen_rank} < Picard rank {picard_rank})")


# ============================================================
# Algorithm 2: Orthogonal Decomposition
# ============================================================

def orthogonal_decomposition(
    phs: PolarizedHodgeStructure
) -> Tuple[np.ndarray, np.ndarray, bool]:
    """
    Compute the algebraic-transcendental orthogonal decomposition.

    Given a polarized Hodge structure (V, Q, Hdg), compute:
    - Projection matrix P_alg onto the algebraic part Hdg(V)
    - Projection matrix P_trans onto the transcendental part Hdg(V)^⊥

    This implements Theorem C: V = Alg ⊕ Tr when Q|_Alg is nondegenerate.

    Algorithm:
        1. Compute the Gram matrix G = B^T Q B where B is the Hodge basis matrix.
        2. If det(G) ≠ 0 (restriction is nondegenerate), compute the orthogonal
           projection P_alg = B (G^{-1}) B^T Q.
        3. P_trans = I - P_alg.

    Returns:
        (P_alg, P_trans, is_valid) where is_valid indicates whether the
        decomposition exists (Q|_Alg is nondegenerate).

    Time complexity: O(n^2 * k + k^3) where n = dim(V), k = Picard rank.
    Space complexity: O(n^2).
    """
    if not phs.hodge.hodge_basis:
        # No algebraic part: everything is transcendental
        n = phs.hodge.dim
        return np.zeros((n, n)), np.eye(n), True

    B = np.column_stack(phs.hodge.hodge_basis)
    Q = phs.Q
    n = phs.hodge.dim

    # Gram matrix of Q restricted to Alg
    G = B.T @ Q @ B

    if abs(np.linalg.det(G)) < 1e-10:
        return np.zeros((n, n)), np.eye(n), False

    # Orthogonal projection onto Alg (with respect to Q)
    G_inv = np.linalg.inv(G)
    P_alg = B @ G_inv @ B.T @ Q
    P_trans = np.eye(n) - P_alg

    return P_alg, P_trans, True


def decompose_vector(
    phs: PolarizedHodgeStructure,
    v: np.ndarray
) -> Tuple[np.ndarray, np.ndarray, bool]:
    """
    Decompose v = v_alg + v_trans where v_alg ∈ Alg and v_trans ∈ Tr.

    Returns:
        (v_alg, v_trans, is_valid).
    """
    P_alg, P_trans, is_valid = orthogonal_decomposition(phs)
    if not is_valid:
        return np.zeros_like(v), v, False
    return P_alg @ v, P_trans @ v, True


# ============================================================
# Algorithm 3: Direct Sum Hodge Structure
# ============================================================

def direct_sum_hodge(
    hs1: HodgeStructureWeightTwo,
    hs2: HodgeStructureWeightTwo
) -> HodgeStructureWeightTwo:
    """
    Compute the direct sum Hodge structure on V₁ × V₂.

    This implements Theorem D: Hdg(V₁ × V₂) = Hdg(V₁) × Hdg(V₂).

    The Hodge basis of the product is formed by embedding each factor's
    Hodge basis into the product space.

    Time complexity: O((n₁ + n₂) * (k₁ + k₂)).
    Space complexity: O((n₁ + n₂) * (k₁ + k₂)).
    """
    n1, n2 = hs1.dim, hs2.dim
    n = n1 + n2

    hodge_basis = []

    # Embed hs1 Hodge basis: (v, 0)
    for v in hs1.hodge_basis:
        embedded = np.zeros(n)
        embedded[:n1] = v
        hodge_basis.append(embedded)

    # Embed hs2 Hodge basis: (0, w)
    for w in hs2.hodge_basis:
        embedded = np.zeros(n)
        embedded[n1:] = w
        hodge_basis.append(embedded)

    return HodgeStructureWeightTwo(
        dim=n,
        hodge_basis=hodge_basis,
        name=f"{hs1.name} × {hs2.name}" if hs1.name and hs2.name
             else "Direct Sum"
    )


# ============================================================
# Algorithm 4: Rank-Based Algebraicity Criterion
# ============================================================

def rank_algebraicity_criterion(
    hs: HodgeStructureWeightTwo,
    algebraic_classes: List[np.ndarray]
) -> Tuple[bool, int, int, str]:
    """
    Apply the rank-based algebraicity criterion.

    For Picard rank 1: any single nonzero algebraic class suffices.
    For Picard rank 2: any two linearly independent algebraic classes suffice.
    General: k linearly independent algebraic classes suffice for rank k.

    Returns:
        (all_algebraic, picard_rank, algebraic_rank, explanation).

    Time complexity: O(n * k^2) where n = dim(V), k = max(|algebraic_classes|, Picard rank).
    """
    picard_rank = hs.picard_rank

    # Filter to actual Hodge classes
    valid = [c for c in algebraic_classes if hs.is_hodge_class(c)]

    if not valid:
        if picard_rank == 0:
            return True, 0, 0, "Trivially algebraic: no Hodge classes exist"
        return False, picard_rank, 0, "No valid algebraic classes provided"

    alg_rank = np.linalg.matrix_rank(np.column_stack(valid))

    if alg_rank >= picard_rank:
        if picard_rank == 1:
            explanation = (f"Rank-1 criterion satisfied: single algebraic class "
                          f"generates all Hodge classes (Theorem B1)")
        elif picard_rank == 2:
            explanation = (f"Rank-2 criterion satisfied: two independent algebraic "
                          f"classes generate all Hodge classes (Theorem B2)")
        else:
            explanation = (f"Full rank criterion satisfied: {alg_rank} independent "
                          f"algebraic classes span Picard rank {picard_rank} space")
        return True, picard_rank, alg_rank, explanation
    else:
        return False, picard_rank, alg_rank, (
            f"Insufficient: {alg_rank} independent algebraic classes "
            f"< Picard rank {picard_rank}")


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: K3 surface model (Picard rank 1)
    print("\n--- K3 Surface (Picard rank 1) ---")
    k3 = HodgeStructureWeightTwo(
        dim=22,
        hodge_basis=[np.eye(22)[0]],  # Single generator: the polarization
        name="K3"
    )
    polarization = np.eye(22)[0]
    result = rank_algebraicity_criterion(k3, [polarization])
    print(f"Picard rank: {result[1]}")
    print(f"Algebraic rank: {result[2]}")
    print(f"All algebraic: {result[0]}")
    print(f"Explanation: {result[3]}")

    # Example 2: Abelian surface (Picard rank 2)
    print("\n--- Abelian Surface (Picard rank 2) ---")
    ab = HodgeStructureWeightTwo(
        dim=6,
        hodge_basis=[np.array([1,0,0,0,0,0.]),
                     np.array([0,1,0,0,0,0.])],
        name="Abelian"
    )
    result = rank_algebraicity_criterion(
        ab,
        [np.array([1,0,0,0,0,0.]), np.array([0,1,0,0,0,0.])]
    )
    print(f"Picard rank: {result[1]}")
    print(f"Algebraic rank: {result[2]}")
    print(f"All algebraic: {result[0]}")
    print(f"Explanation: {result[3]}")

    # Example 3: Orthogonal decomposition
    print("\n--- Orthogonal Decomposition ---")
    Q = np.diag([1., 1., -1., -1.])
    phs = PolarizedHodgeStructure(
        hodge=HodgeStructureWeightTwo(
            dim=4,
            hodge_basis=[np.array([1,0,0,0.]), np.array([0,1,0,0.])],
        ),
        Q=Q
    )
    v = np.array([3., -2., 5., 7.])
    v_alg, v_trans, valid = decompose_vector(phs, v)
    print(f"v = {v}")
    print(f"v_alg = {np.round(v_alg, 4)}")
    print(f"v_trans = {np.round(v_trans, 4)}")
    print(f"Q(v_alg, v_trans) = {np.round(v_alg @ Q @ v_trans, 10)}")

    # Example 4: Direct sum
    print("\n--- Direct Sum ---")
    hs1 = HodgeStructureWeightTwo(dim=3, hodge_basis=[np.array([1,0,0.])], name="V")
    hs2 = HodgeStructureWeightTwo(dim=2, hodge_basis=[np.array([1,0.])], name="W")
    hs_sum = direct_sum_hodge(hs1, hs2)
    print(f"{hs_sum.name}: dim = {hs_sum.dim}, Picard rank = {hs_sum.picard_rank}")
    result = test_algebraicity(hs_sum, hs_sum.hodge_basis)
    print(f"All Hodge classes algebraic: {result[0]}")
    print(f"Explanation: {result[1]}")
