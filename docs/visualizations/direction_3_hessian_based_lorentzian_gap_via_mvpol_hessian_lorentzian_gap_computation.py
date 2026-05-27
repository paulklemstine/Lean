"""
algorithms.py — Hessian Lorentzian Gap: Core Algorithms

Implements the computation of gradient, Hessian, log-Hessian, and restricted
eigenvalue analysis for multivariate generating polynomials evaluated at the
all-ones point.

These algorithms correspond to the formally verified Lean 4 definitions in
Pythagorean/HessianLorentzianGap.lean.
"""

import numpy as np
from numpy.typing import NDArray
from typing import Dict, Tuple, List, Optional
from itertools import product as cartesian_product


def generating_polynomial_eval(
    coeffs: Dict[Tuple[int, ...], float],
    point: NDArray[np.float64],
) -> float:
    """Evaluate a multivariate polynomial at a given point.

    Args:
        coeffs: Dictionary mapping multi-indices (tuples) to coefficients.
        point: Evaluation point, array of length n (number of variables).

    Returns:
        P(point) = sum_{alpha} c_alpha * prod_i point[i]^alpha[i]
    """
    val = 0.0
    for alpha, c in coeffs.items():
        val += c * np.prod([point[i] ** alpha[i] for i in range(len(alpha))])
    return val


def grad_at_one(
    coeffs: Dict[Tuple[int, ...], float],
    n: int,
) -> NDArray[np.float64]:
    """Compute the gradient of P at the all-ones point.

    g_P(i) = (partial_i P)(1,...,1)

    For a monomial c * x^alpha, partial_i gives c * alpha[i] * x^{alpha - e_i},
    which evaluates to c * alpha[i] at x = (1,...,1).

    Args:
        coeffs: Polynomial coefficients as {multi-index: coefficient}.
        n: Number of variables.

    Returns:
        Array of length n with gradient components.
    """
    grad = np.zeros(n)
    for alpha, c in coeffs.items():
        for i in range(n):
            if alpha[i] > 0:
                # Derivative of c * x^alpha w.r.t. x_i, evaluated at 1
                grad[i] += c * alpha[i]
    return grad


def hessian_at_one(
    coeffs: Dict[Tuple[int, ...], float],
    n: int,
) -> NDArray[np.float64]:
    """Compute the Hessian matrix of P at the all-ones point.

    H_P(i,j) = (partial_i partial_j P)(1,...,1)

    Args:
        coeffs: Polynomial coefficients as {multi-index: coefficient}.
        n: Number of variables.

    Returns:
        n x n symmetric matrix.
    """
    H = np.zeros((n, n))
    for alpha, c in coeffs.items():
        for i in range(n):
            for j in range(n):
                if i == j:
                    if alpha[i] >= 2:
                        H[i][j] += c * alpha[i] * (alpha[i] - 1)
                else:
                    if alpha[i] >= 1 and alpha[j] >= 1:
                        H[i][j] += c * alpha[i] * alpha[j]
    return H


def log_hessian_at_one(
    coeffs: Dict[Tuple[int, ...], float],
    n: int,
) -> NDArray[np.float64]:
    """Compute the Hessian of log P at the all-ones point.

    LogHess_P(i,j) = H_P(i,j)/P(1) - g_P(i)*g_P(j)/P(1)^2

    This is the central geometric object: the curvature of the log-generating
    polynomial at the distinguished all-ones point.

    Args:
        coeffs: Polynomial coefficients.
        n: Number of variables.

    Returns:
        n x n matrix (the log-Hessian).

    Raises:
        ValueError: If P(1) = 0.
    """
    ones = np.ones(n)
    p1 = generating_polynomial_eval(coeffs, ones)
    if abs(p1) < 1e-15:
        raise ValueError("P(1) = 0; log-Hessian undefined.")

    g = grad_at_one(coeffs, n)
    H = hessian_at_one(coeffs, n)

    return H / p1 - np.outer(g, g) / p1**2


def restrict_to_sum_zero(
    M: NDArray[np.float64],
) -> NDArray[np.float64]:
    """Restrict a matrix to the sum-zero subspace.

    The sum-zero subspace has dimension n-1 and consists of vectors
    whose entries sum to zero. We use a basis obtained by QR decomposition
    of the orthogonal complement of the all-ones vector.

    Args:
        M: n x n matrix.

    Returns:
        (n-1) x (n-1) restricted matrix.
    """
    n = M.shape[0]
    if n <= 1:
        return np.array([[0.0]])

    # Build orthonormal basis for {x : sum x_i = 0}
    ones = np.ones(n) / np.sqrt(n)
    # Start with a random basis and Gram-Schmidt against ones
    basis = []
    for k in range(n):
        e = np.zeros(n)
        e[k] = 1.0
        # Remove component along ones
        e = e - np.dot(e, ones) * ones
        # Remove components along previous basis vectors
        for b in basis:
            e = e - np.dot(e, b) * b
        norm = np.linalg.norm(e)
        if norm > 1e-10:
            basis.append(e / norm)

    basis = np.array(basis)  # (n-1) x n
    # Restricted matrix: B @ M @ B^T
    return basis @ M @ basis.T


def hessian_lorentzian_gap(
    coeffs: Dict[Tuple[int, ...], float],
    n: int,
) -> float:
    """Compute the Hessian Lorentzian gap.

    This is the smallest eigenvalue of -logHessianAtOne restricted to the
    sum-zero subspace. Positive gap indicates log-concavity on the simplex
    tangent space.

    Args:
        coeffs: Polynomial coefficients.
        n: Number of variables.

    Returns:
        The Hessian gap (smallest restricted eigenvalue of -LogHess).
    """
    L = log_hessian_at_one(coeffs, n)
    neg_L = -L
    M_restricted = restrict_to_sum_zero(neg_L)
    eigenvalues = np.linalg.eigvalsh(M_restricted)
    return float(eigenvalues[0])


def mass_ratio_gap(
    coeffs: Dict[Tuple[int, ...], float],
) -> float:
    """Compute the mass-ratio surrogate gap: minMass / maxMass.

    Args:
        coeffs: Polynomial coefficients (nonneg values expected).

    Returns:
        min(coeffs) / max(coeffs), or 0 if max = 0.
    """
    vals = [v for v in coeffs.values() if v > 0]
    if not vals:
        return 0.0
    return min(vals) / max(vals)


def multiaffine_from_distribution(
    probs: Dict[Tuple[int, ...], float],
    n: int,
) -> Dict[Tuple[int, ...], float]:
    """Convert a distribution on {0,1}^n to its generating polynomial coefficients.

    P_mu(z) = sum_{S subset [n]} mu(S) * prod_{i in S} z_i

    Args:
        probs: Dictionary mapping binary strings (tuples of 0/1) to probabilities.
        n: Number of variables.

    Returns:
        Polynomial coefficients as {multi-index: coefficient}.
    """
    return {s: p for s, p in probs.items() if abs(p) > 1e-15}


def perturbation_bound(
    coeffs_P: Dict[Tuple[int, ...], float],
    coeffs_Q: Dict[Tuple[int, ...], float],
    n: int,
) -> float:
    """Compute the entrywise log-Hessian perturbation bound delta.

    delta = max_{i,j} |logHessianAtOne(P)(i,j) - logHessianAtOne(Q)(i,j)|

    Args:
        coeffs_P, coeffs_Q: Polynomial coefficients.
        n: Number of variables.

    Returns:
        Maximum entrywise difference delta.
    """
    L_P = log_hessian_at_one(coeffs_P, n)
    L_Q = log_hessian_at_one(coeffs_Q, n)
    return float(np.max(np.abs(L_P - L_Q)))


def verified_gap_certificate(
    coeffs: Dict[Tuple[int, ...], float],
    n: int,
) -> Dict[str, object]:
    """Produce a complete Hessian gap certificate for a polynomial.

    This is the computational pipeline corresponding to the formal verification:
    1. Compute gradAtOne
    2. Compute hessianAtOne
    3. Form logHessianAtOne
    4. Restrict to sum-zero subspace
    5. Return eigenvalue analysis

    Args:
        coeffs: Polynomial coefficients.
        n: Number of variables.

    Returns:
        Dictionary with all intermediate computations and the gap certificate.
    """
    ones = np.ones(n)
    p1 = generating_polynomial_eval(coeffs, ones)
    g = grad_at_one(coeffs, n)
    H = hessian_at_one(coeffs, n)
    L = log_hessian_at_one(coeffs, n)
    neg_L = -L
    M_restricted = restrict_to_sum_zero(neg_L)
    eigs = np.linalg.eigvalsh(M_restricted)
    gap = float(eigs[0])
    mass_gap = mass_ratio_gap(coeffs)

    return {
        "n": n,
        "P_at_one": p1,
        "gradient": g,
        "hessian": H,
        "log_hessian": L,
        "restricted_eigenvalues": eigs,
        "hessian_gap": gap,
        "mass_ratio_gap": mass_gap,
        "is_log_concave_on_simplex": gap > -1e-10,
        "gap_is_positive": gap > 1e-10,
    }


if __name__ == "__main__":
    # Example: uniform distribution on {0,1}^3
    n = 3
    coeffs = {}
    for bits in cartesian_product([0, 1], repeat=n):
        coeffs[bits] = 1.0 / (2**n)

    cert = verified_gap_certificate(coeffs, n)
    print("=== Verified Gap Certificate (Uniform on {0,1}^3) ===")
    for k, v in cert.items():
        if isinstance(v, np.ndarray):
            print(f"  {k}: {np.round(v, 6)}")
        else:
            print(f"  {k}: {v}")
