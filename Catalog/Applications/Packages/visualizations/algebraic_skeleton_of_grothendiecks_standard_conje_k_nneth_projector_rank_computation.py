"""
Algorithms for the Algebraic Skeleton of Grothendieck's Standard Conjectures.

Implements computational versions of:
1. Künneth projector rank computation
2. Lefschetz kernel filtration
3. Hodge index signature computation
4. Weight filtration analysis
5. Correspondence algebra projector operations
"""

from typing import List, Tuple, Optional
import numpy as np
from numpy.typing import NDArray


def compute_kunneth_ranks(
    projectors: List[NDArray[np.float64]],
) -> Tuple[List[int], bool]:
    """Compute graded ranks from an orthogonal idempotent system.

    Given a list of square matrices π₁, ..., πₙ forming an orthogonal
    idempotent system, compute rank(πᵢ) for each i and verify
    rank additivity: Σ rank(πᵢ) = dim(V).

    Args:
        projectors: List of n×n numpy arrays representing the projectors.

    Returns:
        Tuple of (list of ranks, whether rank additivity holds).
    """
    n = projectors[0].shape[0]
    ranks: List[int] = []
    for pi in projectors:
        rank = int(np.round(np.linalg.matrix_rank(pi)))
        ranks.append(rank)
    additivity_holds = sum(ranks) == n
    return ranks, additivity_holds


def verify_orthogonal_idempotent(
    projectors: List[NDArray[np.float64]], tol: float = 1e-10
) -> Tuple[bool, bool, bool]:
    """Verify that a system of matrices is an orthogonal idempotent system.

    Returns:
        Tuple of (all idempotent, all pairwise orthogonal, sum equals identity).
    """
    n = projectors[0].shape[0]
    idempotent = all(
        np.allclose(pi @ pi, pi, atol=tol) for pi in projectors
    )
    orthogonal = all(
        np.allclose(projectors[i] @ projectors[j], 0, atol=tol)
        for i in range(len(projectors))
        for j in range(len(projectors))
        if i != j
    )
    total = sum(projectors)
    complete = np.allclose(total, np.eye(n), atol=tol)
    return idempotent, orthogonal, complete


def lefschetz_filtration(
    L: NDArray[np.float64],
) -> List[int]:
    """Compute the kernel filtration of a nilpotent operator.

    For a nilpotent matrix L, compute dim(ker(L^k)) for k = 0, 1, 2, ...
    until stabilization (ker(L^k) = full space).

    Args:
        L: Square numpy array representing the Lefschetz operator.

    Returns:
        List of kernel dimensions [dim(ker(L^0)), dim(ker(L^1)), ...].
    """
    n = L.shape[0]
    dims: List[int] = [0]  # ker(L^0) = ker(I) = {0}, dim = 0
    power = np.eye(n)
    for k in range(1, n + 2):
        power = power @ L
        ker_dim = n - int(np.round(np.linalg.matrix_rank(power, tol=1e-10)))
        dims.append(ker_dim)
        if ker_dim == n:
            break
    return dims


def hodge_signature(
    Q: NDArray[np.float64],
) -> Tuple[int, int, int]:
    """Compute the signature (p, q, z) of a symmetric bilinear form.

    Args:
        Q: Symmetric matrix representing the bilinear form.

    Returns:
        Tuple (positive_count, negative_count, zero_count).
    """
    eigenvalues = np.linalg.eigvalsh(Q)
    tol = 1e-10
    p = int(np.sum(eigenvalues > tol))
    q = int(np.sum(eigenvalues < -tol))
    z = int(np.sum(np.abs(eigenvalues) <= tol))
    return p, q, z


def weight_filtration_analysis(
    filtration_dims: List[int], total_dim: int
) -> Tuple[bool, Optional[int], List[int]]:
    """Analyze a weight filtration given dimensions of each step.

    Args:
        filtration_dims: List of dim(W_k) for k = 0, 1, ..., N.
        total_dim: Total dimension of V.

    Returns:
        Tuple of (is_pure, pure_weight_if_pure, graded_dimensions).
    """
    graded: List[int] = []
    prev = 0
    for d in filtration_dims:
        graded.append(d - prev)
        prev = d

    # Check monotonicity
    is_monotone = all(
        filtration_dims[i] <= filtration_dims[i + 1]
        for i in range(len(filtration_dims) - 1)
    )

    # Check purity: exactly one nonzero graded piece
    nonzero_grades = [(i, g) for i, g in enumerate(graded) if g > 0]
    is_pure = len(nonzero_grades) == 1 and is_monotone
    pure_weight = nonzero_grades[0][0] if is_pure else None

    return is_pure, pure_weight, graded


def projector_complement(
    p: NDArray[np.float64],
) -> NDArray[np.float64]:
    """Compute the complement projector 1 - p."""
    n = p.shape[0]
    return np.eye(n) - p


def projector_transpose_compose(
    p: NDArray[np.float64],
) -> NDArray[np.float64]:
    """Compute the self-adjoint projector p^T * p."""
    return p.T @ p


def verify_primitive_rank_bound(
    L: NDArray[np.float64],
) -> Tuple[bool, int, int, int]:
    """Test the Primitive Rank Bound Conjecture for a nilpotent matrix.

    Checks whether dim(ker L) * (weight + 1) >= dim(V).

    Args:
        L: Square nilpotent numpy array.

    Returns:
        Tuple of (conjecture_holds, ker_dim, weight, total_dim).
    """
    n = L.shape[0]
    ker_dim = n - int(np.round(np.linalg.matrix_rank(L, tol=1e-10)))

    # Find nilpotency weight
    power = L.copy()
    weight = 0
    for k in range(1, n + 1):
        if np.allclose(power, 0, atol=1e-10):
            weight = k - 1
            break
        power = power @ L
    else:
        weight = n

    holds = ker_dim * (weight + 1) >= n
    return holds, ker_dim, weight, n


def random_nilpotent_matrix(n: int, weight: int) -> NDArray[np.float64]:
    """Generate a random nilpotent matrix with given nilpotency weight.

    Uses Jordan form: constructs a block-diagonal matrix with Jordan blocks
    of sizes summing to n, then applies a random similarity transformation.

    Args:
        n: Matrix dimension.
        weight: Desired nilpotency index (L^weight = 0, L^{weight-1} ≠ 0).

    Returns:
        n×n nilpotent numpy array.
    """
    if weight > n or weight < 1:
        raise ValueError(f"Weight must be between 1 and {n}")

    # Create Jordan form with one block of size `weight` and rest size 1
    J = np.zeros((n, n))
    for i in range(min(weight - 1, n - 1)):
        J[i, i + 1] = 1.0

    # Random similarity transformation
    P = np.random.randn(n, n)
    while np.abs(np.linalg.det(P)) < 0.01:
        P = np.random.randn(n, n)
    P_inv = np.linalg.inv(P)

    return P @ J @ P_inv


def build_surface_intersection_form(
    betti_numbers: List[int],
) -> NDArray[np.float64]:
    """Build a model intersection form for a surface with given Betti numbers.

    For a surface with h^{1,1} = rho, the intersection form has
    signature (1, rho - 1).

    Args:
        betti_numbers: List [b0, b1, b2, b3, b4] of Betti numbers.

    Returns:
        Symmetric matrix of signature (1, b2 - 1).
    """
    b2 = betti_numbers[2] if len(betti_numbers) > 2 else 1
    # Signature (1, b2-1): one positive eigenvalue, rest negative
    Q = np.diag([1.0] + [-1.0] * (b2 - 1))
    return Q
