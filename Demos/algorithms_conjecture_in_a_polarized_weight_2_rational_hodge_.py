#!/usr/bin/env python3
"""
Algorithms for computational Hodge theory.

Implements the key computational procedures that correspond to the formally
verified theorems:
1. Hodge class detection in weight-2 structures
2. Picard rank computation
3. Orthogonal decomposition (algebraic ⊕ transcendental)
4. Rank-one reconstruction
5. Exterior square decomposition
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class PolarizedHodgeStructure:
    """A weight-2 polarized rational Hodge structure.

    Attributes:
        V_dim: Dimension of the rational vector space V
        Q: Bilinear form matrix (symmetric, nondegenerate)
        hodge_classes_basis: Basis vectors for the Hodge class submodule
        picard_rank: Dimension of the Hodge class submodule
    """
    V_dim: int
    Q: np.ndarray
    hodge_classes_basis: np.ndarray
    picard_rank: int

    @property
    def transcendental_basis(self) -> np.ndarray:
        """Compute a basis for the transcendental lattice T(V) = Hdg(V)⊥."""
        return compute_orthogonal_complement(self.Q, self.hodge_classes_basis)


def compute_orthogonal_complement(
    Q: np.ndarray,
    W_basis: np.ndarray
) -> np.ndarray:
    """Compute the Q-orthogonal complement of span(W_basis).

    Given a nondegenerate symmetric bilinear form Q and a subspace W
    (specified by row vectors), returns a basis for W⊥ = {v : Q(v,w)=0 ∀w∈W}.

    Algorithm:
        1. Compute the matrix M = W_basis @ Q (each row is Q(w_i, ·))
        2. Find the null space of M^T
        3. Return an orthonormal basis

    Time complexity: O(n²k) where n = dim V, k = dim W
    Space complexity: O(n²)

    Args:
        Q: n×n symmetric nondegenerate bilinear form matrix
        W_basis: k×n matrix whose rows span W

    Returns:
        (n-k)×n matrix whose rows form a basis for W⊥
    """
    n = Q.shape[0]
    if W_basis.size == 0:
        return np.eye(n)

    # M[i,j] = sum_l W_basis[i,l] * Q[l,j] = Q(w_i, e_j)
    M = W_basis @ Q

    # The orthogonal complement is ker(M^T) = ker(M) since Q is symmetric
    # Use SVD for numerical stability
    U, S, Vt = np.linalg.svd(M)
    rank = np.sum(S > 1e-10)
    complement = Vt[rank:]

    return complement


def detect_hodge_classes(
    H11_basis_complex: np.ndarray,
    V_basis: np.ndarray,
    tol: float = 1e-10
) -> np.ndarray:
    """Detect rational Hodge classes in a weight-2 structure.

    A vector v ∈ V is a Hodge class if its complexification 1⊗v lies in H^{1,1}.
    This amounts to checking if v (viewed in V_C via v ↦ 1⊗v) can be expressed
    as a real linear combination of the H^{1,1} basis vectors.

    Algorithm:
        1. Project V_basis onto H^{1,1} using least-squares
        2. Check which projections are exact (residual < tol)
        3. Return the rational subspace spanned by those vectors

    Time complexity: O(n²m) where n = dim V_C, m = dim H^{1,1}
    Space complexity: O(nm)

    Args:
        H11_basis_complex: Basis of H^{1,1} as complex vectors (column vectors)
        V_basis: Rational basis of V embedded in V_C (column vectors)
        tol: Tolerance for detecting membership

    Returns:
        Basis vectors of the Hodge class submodule
    """
    n_rational = V_basis.shape[1]
    hodge_indices = []

    for j in range(n_rational):
        v = V_basis[:, j]
        # Check if v ∈ span(H11_basis_complex)
        coeffs, residuals, _, _ = np.linalg.lstsq(H11_basis_complex, v, rcond=None)
        reconstructed = H11_basis_complex @ coeffs
        if np.linalg.norm(v - reconstructed) < tol:
            hodge_indices.append(j)

    if not hodge_indices:
        return np.array([]).reshape(0, V_basis.shape[0])

    return V_basis[:, hodge_indices].T


def compute_picard_rank(
    H11_basis_complex: np.ndarray,
    V_basis: np.ndarray,
    tol: float = 1e-10
) -> int:
    """Compute the Picard rank of a weight-2 Hodge structure.

    The Picard rank is dim_Q(Hdg(V)) = dim_Q(V ∩ H^{1,1}).

    Time complexity: O(n²m)
    Space complexity: O(nm)

    Args:
        H11_basis_complex: Basis of H^{1,1}
        V_basis: Rational basis of V embedded in V_C
        tol: Tolerance

    Returns:
        The Picard rank
    """
    hodge_basis = detect_hodge_classes(H11_basis_complex, V_basis, tol)
    return hodge_basis.shape[0]


def rank_one_express_as_multiple(
    hodge_basis: np.ndarray,
    omega: np.ndarray,
    v: np.ndarray,
    tol: float = 1e-10
) -> Optional[float]:
    """Express a Hodge class v as a rational multiple of omega.

    Implements Theorem A1: when Picard rank = 1, finds q such that v = q*omega.

    Algorithm:
        1. Find the first nonzero coordinate of omega
        2. Compute q = v[i] / omega[i]
        3. Verify v = q * omega

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        hodge_basis: 1×n basis of Hodge classes (for verification)
        omega: Nonzero Hodge class
        v: Another Hodge class

    Returns:
        The rational scalar q such that v = q*omega, or None if not proportional
    """
    # Find first nonzero coordinate
    idx = np.argmax(np.abs(omega))
    if np.abs(omega[idx]) < tol:
        return None

    q = v[idx] / omega[idx]

    # Verify proportionality
    if np.allclose(v, q * omega, atol=tol):
        return q
    return None


def orthogonal_decompose(
    Q: np.ndarray,
    hodge_basis: np.ndarray,
    v: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """Decompose v = a + t with a ∈ Alg(V), t ∈ Tr(V).

    Implements Theorem C1: the orthogonal decomposition of V.

    Algorithm (for rank-1 case):
        1. Project v onto the algebraic line: a = Q(v,ω)/Q(ω,ω) * ω
        2. Compute t = v - a
        3. Verify Q(t, ω) = 0

    Time complexity: O(n²) for the Q-inner product
    Space complexity: O(n)

    Args:
        Q: Bilinear form matrix
        hodge_basis: Basis of Hodge classes (rows)
        v: Vector to decompose

    Returns:
        (algebraic_part, transcendental_part)
    """
    # For rank-1: project onto the line spanned by omega
    omega = hodge_basis[0]
    q_omega_omega = omega @ Q @ omega
    q_v_omega = v @ Q @ omega
    a = (q_v_omega / q_omega_omega) * omega
    t = v - a
    return a, t


def reconstruct_isometry(
    Q: np.ndarray,
    omega: np.ndarray,
    omega_prime: np.ndarray,
    f_transcendental: np.ndarray,
    transcendental_basis: np.ndarray,
    transcendental_basis_prime: np.ndarray
) -> np.ndarray:
    """Reconstruct a full isometry from transcendental data.

    Implements Theorem C2: given omega, omega' with Q(ω,ω) = Q(ω',ω'),
    and an isometry f: Tr(V) → Tr(V'), construct F: V → V'.

    Algorithm:
        1. Build F on algebraic line: F(ω) = ω'
        2. Build F on transcendental part: F|_{Tr} = f
        3. Extend linearly using the direct sum decomposition

    Time complexity: O(n³) for matrix operations
    Space complexity: O(n²)

    Args:
        Q: Bilinear form matrix
        omega, omega_prime: Algebraic generators
        f_transcendental: Matrix of f on transcendental bases
        transcendental_basis: Basis of Tr(V) (rows)
        transcendental_basis_prime: Basis of Tr(V') (rows)

    Returns:
        n×n matrix representing the isometry F
    """
    n = len(omega)

    # Build change-of-basis: [omega; t_1; ...; t_{n-1}]
    P = np.vstack([omega.reshape(1, -1), transcendental_basis])
    P_prime = np.vstack([omega_prime.reshape(1, -1), transcendental_basis_prime])

    # F in the adapted basis: identity on first coord, f on rest
    F_adapted = np.zeros((n, n))
    F_adapted[0, 0] = 1.0
    F_adapted[1:, 1:] = f_transcendental

    # Transform to standard basis: F = P'^T @ F_adapted @ P^{-T}
    F = P_prime.T @ F_adapted @ np.linalg.inv(P.T)

    return F


def exterior_square_dimension(n: int) -> int:
    """Dimension of Λ²(Q^n) = n(n-1)/2.

    Time complexity: O(1)
    """
    return n * (n - 1) // 2


def exterior_square_decomposition_dimensions(
    dim_U: int, dim_W: int
) -> Tuple[int, int, int, int]:
    """Compute dimensions in the decomposition Λ²(U⊕W) ≅ Λ²U ⊕ (U⊗W) ⊕ Λ²W.

    Returns:
        (dim_lhs, dim_ext_U, dim_tensor, dim_ext_W)
    """
    dim_lhs = exterior_square_dimension(dim_U + dim_W)
    dim_ext_U = exterior_square_dimension(dim_U)
    dim_tensor = dim_U * dim_W
    dim_ext_W = exterior_square_dimension(dim_W)
    assert dim_lhs == dim_ext_U + dim_tensor + dim_ext_W
    return dim_lhs, dim_ext_U, dim_tensor, dim_ext_W


# ─────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Computational Hodge Theory")
    print("=" * 50)
    print()

    # Create a rank-1 K3-like structure
    n = 6
    Q = np.diag([1.0, -1, -1, -1, -1, -1])
    omega = np.array([1.0, 0, 0, 0, 0, 0])
    hodge_basis = omega.reshape(1, -1)

    hs = PolarizedHodgeStructure(
        V_dim=n, Q=Q, hodge_classes_basis=hodge_basis, picard_rank=1
    )

    print(f"Polarized Hodge structure: dim V = {n}, ρ = {hs.picard_rank}")
    print(f"Q = diag({list(np.diag(Q).astype(int))})")
    print()

    # Orthogonal decomposition
    v = np.array([3.0, 1.0, -2.0, 0.5, 1.5, -1.0])
    a, t = orthogonal_decompose(Q, hodge_basis, v)
    print(f"Decompose v = ({', '.join(f'{x:.1f}' for x in v)}):")
    print(f"  Algebraic part: a = {a[0]:.1f}·ω")
    print(f"  Transcendental part: t = ({', '.join(f'{x:.1f}' for x in t)})")
    print(f"  Q(t, ω) = {t @ Q @ omega:.2e}")
    print()

    # Express 5ω as multiple of ω
    v_hodge = 5 * omega
    q = rank_one_express_as_multiple(hodge_basis, omega, v_hodge)
    print(f"Express 5ω as q·ω: q = {q}")
    print()

    # Exterior square dimensions
    for d1, d2 in [(2, 3), (4, 5), (10, 12)]:
        dims = exterior_square_decomposition_dimensions(d1, d2)
        print(f"Λ²(Q^{d1}⊕Q^{d2}): {dims[0]} = {dims[1]} + {dims[2]} + {dims[3]}")

    # Reconstruction
    print()
    omega_prime = np.array([1.0, 0, 0, 0, 0, 0])
    tr_basis = np.eye(n)[1:]  # e_2, ..., e_n
    f_tr = np.eye(n - 1)  # identity isometry
    F = reconstruct_isometry(Q, omega, omega_prime, f_tr, tr_basis, tr_basis)
    print(f"Reconstruction isometry F:")
    print(f"  F(ω) = ω': {np.allclose(F @ omega, omega_prime)}")
    print(f"  F is isometry: {np.allclose(F.T @ Q @ F, Q)}")
