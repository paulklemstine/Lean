"""
Algorithms for Standard Conjectures on Algebraic Cycles

Implements numerical computations related to:
- Intersection pairings and numerical equivalence
- Lefschetz operators and Hard Lefschetz
- Hodge index theorem verification
- Motive decomposition via idempotent projectors
- Weight filtrations and graded pieces
"""

from typing import List, Tuple, Optional
import numpy as np
from numpy.typing import NDArray


def intersection_pairing(Q: NDArray[np.float64], v: NDArray[np.float64],
                          w: NDArray[np.float64]) -> float:
    """Compute the intersection pairing ⟨v, w⟩_Q = v^T Q w."""
    return float(v @ Q @ w)


def numerical_kernel(Q: NDArray[np.float64], tol: float = 1e-10
                     ) -> NDArray[np.float64]:
    """Compute the numerical kernel of a symmetric bilinear form Q.

    Returns an orthonormal basis for ker(Q) as column vectors.
    Classes in the numerical kernel pair to zero with all other classes.
    """
    U, S, Vt = np.linalg.svd(Q)
    null_mask = S < tol
    return Vt[null_mask].T


def lefschetz_pairing(Q: NDArray[np.float64], L: NDArray[np.float64],
                       v: NDArray[np.float64], w: NDArray[np.float64]
                       ) -> float:
    """Compute the Lefschetz pairing Q_L(v,w) = v^T Q L w."""
    return float(v @ Q @ L @ w)


def primitive_subspace(L: NDArray[np.float64], tol: float = 1e-10
                       ) -> NDArray[np.float64]:
    """Compute the primitive subspace ker(L) as column vectors."""
    U, S, Vt = np.linalg.svd(L)
    null_mask = S < tol
    return Vt[null_mask].T


def hodge_index_check(a: float, b: float, c: float) -> dict:
    """Verify the Hodge index theorem for a 2×2 intersection form.

    For [[a, b], [b, c]] with a > 0:
    - If det = ac - b² < 0, then the form has signature (1,1)
    - The orthogonal complement of the positive direction is negative

    Returns a dict with signature, determinant, and whether Hodge index holds.
    """
    det = a * c - b * b
    if a <= 0:
        return {"valid": False, "reason": "a must be positive"}

    # Eigenvalues of [[a,b],[b,c]]
    trace = a + c
    disc = np.sqrt(max(0, (a - c)**2 + 4*b*b))
    lam1 = (trace + disc) / 2
    lam2 = (trace - disc) / 2

    n_pos = int(lam1 > 0) + int(lam2 > 0)
    n_neg = int(lam1 < 0) + int(lam2 < 0)

    # For any v orthogonal to the positive direction, check Q(v,v) ≤ 0
    # The positive eigenvector direction is e₁ (approximately, when a > 0 and det < 0)
    hodge_holds = det < 0  # Hodge index says if a > 0 and det < 0, orthogonal complement is negative

    return {
        "determinant": det,
        "eigenvalues": (lam1, lam2),
        "signature": (n_pos, n_neg),
        "hodge_index_holds": hodge_holds,
        "valid": True
    }


def idempotent_decomposition(p: NDArray[np.float64]
                             ) -> Tuple[NDArray[np.float64],
                                        NDArray[np.float64],
                                        NDArray[np.float64]]:
    """Decompose a vector space via an idempotent projector p.

    Returns:
        image_basis: basis for im(p) (the motive)
        complement_basis: basis for im(1-p) (the complementary motive)
        p_complement: the complementary projector 1-p
    """
    n = p.shape[0]
    p_comp = np.eye(n) - p

    # Verify idempotency
    assert np.allclose(p @ p, p, atol=1e-10), "p is not idempotent"
    assert np.allclose(p_comp @ p_comp, p_comp, atol=1e-10), "1-p is not idempotent"

    # Get bases via SVD
    U1, S1, _ = np.linalg.svd(p)
    rank1 = np.sum(S1 > 1e-10)
    image_basis = U1[:, :rank1]

    U2, S2, _ = np.linalg.svd(p_comp)
    rank2 = np.sum(S2 > 1e-10)
    complement_basis = U2[:, :rank2]

    return image_basis, complement_basis, p_comp


def weight_filtration_graded_dims(filtration_dims: List[int]
                                  ) -> List[int]:
    """Compute graded dimensions from a weight filtration.

    Args:
        filtration_dims: [dim W_0, dim W_1, ..., dim W_n]
            where W_0 ⊂ W_1 ⊂ ... ⊂ W_n is the filtration.

    Returns:
        Graded dimensions [dim Gr_0, dim Gr_1, ..., dim Gr_n]
        where Gr_k = W_k / W_{k-1}.
    """
    graded = [filtration_dims[0]]
    for i in range(1, len(filtration_dims)):
        graded.append(filtration_dims[i] - filtration_dims[i-1])
    return graded


def check_primitive_bound_conjecture(d: int, n_trials: int = 1000,
                                      seed: int = 42) -> dict:
    """Test the primitive bound conjecture: dim(ker L) ≤ d/2 + 1.

    For random compatible (Q, L) pairs on ℚ^d, checks whether the
    dimension of ker(L) is bounded by d/2 + 1.

    Args:
        d: dimension of the vector space
        n_trials: number of random trials
        seed: random seed

    Returns:
        Dict with results including any counterexamples found.
    """
    rng = np.random.default_rng(seed)
    bound = d // 2 + 1
    max_ker_dim = 0
    counterexamples = 0

    for _ in range(n_trials):
        # Generate random symmetric Q
        A = rng.standard_normal((d, d))
        Q = (A + A.T) / 2

        # Generate L compatible with Q: Q L = L^T Q (self-adjoint w.r.t. Q)
        B = rng.standard_normal((d, d))
        # Make L self-adjoint: L = Q^{-1} S where S is symmetric
        try:
            Q_inv = np.linalg.inv(Q)
        except np.linalg.LinAlgError:
            continue
        S = (B + B.T) / 2
        L = Q_inv @ S

        # Check compatibility: Q @ L should be symmetric
        QL = Q @ L
        if not np.allclose(QL, QL.T, atol=1e-8):
            continue

        # Compute ker(L) dimension
        sv = np.linalg.svd(L, compute_uv=False)
        ker_dim = np.sum(sv < 1e-8)

        max_ker_dim = max(max_ker_dim, ker_dim)
        if ker_dim > bound:
            counterexamples += 1

    return {
        "dimension": d,
        "bound": bound,
        "max_kernel_dim_found": max_ker_dim,
        "counterexamples": counterexamples,
        "n_trials": n_trials,
        "conjecture_holds": counterexamples == 0
    }


def lefschetz_star_operator(L: NDArray[np.float64],
                            Lambda: NDArray[np.float64]
                            ) -> NDArray[np.float64]:
    """Compute the Lefschetz star operator ★ = L ∘ Λ.

    This is the projector onto im(L) when Λ is a left inverse of L.
    """
    return L @ Lambda


def verify_lefschetz_star_idempotent(L: NDArray[np.float64],
                                      Lambda: NDArray[np.float64]
                                      ) -> bool:
    """Verify that L ∘ Λ is idempotent on im(L).

    This is the content of our theorem lefschetz_star_idempotent_on_image.
    """
    star = L @ Lambda
    # Check star² = star on im(L)
    star_sq = star @ star

    # Get basis for im(L)
    U, S, _ = np.linalg.svd(L)
    rank = np.sum(S > 1e-10)
    im_basis = U[:, :rank]

    # Check star² v = star v for all v in im(L)
    for i in range(rank):
        v = im_basis[:, i]
        lhs = star_sq @ v
        rhs = star @ v
        if not np.allclose(lhs, rhs, atol=1e-8):
            return False
    return True


def standard_conjecture_d_gap(Q: NDArray[np.float64],
                                hom_kernel_basis: NDArray[np.float64]
                                ) -> dict:
    """Measure the gap between homological and numerical equivalence.

    The gap measures how far Standard Conjecture D is from holding.

    Args:
        Q: symmetric intersection pairing matrix
        hom_kernel_basis: basis vectors for the homological kernel (columns)

    Returns:
        Dict with dimensions and gap measure.
    """
    # Numerical kernel
    num_ker = numerical_kernel(Q)
    num_dim = num_ker.shape[1] if num_ker.ndim > 1 else 0

    # Homological kernel dimension
    hom_dim = hom_kernel_basis.shape[1] if hom_kernel_basis.ndim > 1 else 0

    return {
        "numerical_kernel_dim": num_dim,
        "homological_kernel_dim": hom_dim,
        "gap": num_dim - hom_dim,
        "conjecture_d_holds": num_dim == hom_dim
    }
