#!/usr/bin/env python3
"""
Tropical Shadows of Lorentzian Stability — Algorithms

Implements the core algorithms for computing tropical spectral gaps,
generating gap certificates, and certifying Lorentzian stability.

All algorithms are polynomial-time in the matrix dimension.
"""

import numpy as np
from typing import Tuple, List, Optional, NamedTuple


class TropicalQuadraticWeight:
    """A symmetric weight function representing log-coefficients of a quadratic form.

    Attributes:
        w: numpy array of shape (n, n), symmetric.
    """

    def __init__(self, w: np.ndarray):
        assert w.ndim == 2 and w.shape[0] == w.shape[1], "Weight must be square"
        assert np.allclose(w, w.T), "Weight must be symmetric"
        self.w = w.copy()
        self.n = w.shape[0]

    def weight(self, i: int, j: int) -> float:
        return self.w[i, j]

    @classmethod
    def uniform(cls, n: int, d: float, c: float) -> 'TropicalQuadraticWeight':
        """Create uniform weight: diagonal=d, off-diagonal=c."""
        w = np.full((n, n), c)
        np.fill_diagonal(w, d)
        return cls(w)

    @classmethod
    def from_positive_matrix(cls, M: np.ndarray) -> 'TropicalQuadraticWeight':
        """Create weight from a positive symmetric matrix via w = log(M)."""
        assert np.all(M > 0), "Matrix must have positive entries"
        return cls(np.log(M))


class GapCertificate(NamedTuple):
    """Certificate for a tropical spectral gap computation.

    Attributes:
        value: The gap value (minimum exchange slack).
        witness_i: First index of the witness pair.
        witness_j: Second index of the witness pair.
        all_slacks: Dictionary mapping (i,j) to exchange slack.
    """
    value: float
    witness_i: int
    witness_j: int
    all_slacks: dict


def diag_exchange_slack(w: TropicalQuadraticWeight, i: int, j: int) -> float:
    """Compute δ(i,j) = 2·w(i,j) - w(i,i) - w(j,j).

    Time complexity: O(1)

    Args:
        w: Tropical quadratic weight.
        i, j: Indices.

    Returns:
        The diagonal exchange slack at (i,j).
    """
    return 2 * w.weight(i, j) - w.weight(i, i) - w.weight(j, j)


def compute_tropical_gap(w: TropicalQuadraticWeight) -> GapCertificate:
    """Compute the tropical spectral gap with a verified certificate.

    Time complexity: O(n²) where n is the dimension.
    Space complexity: O(n²) for storing all slacks.

    This is the main algorithm: it computes the minimum diagonal exchange
    slack over all distinct pairs and returns a certificate containing
    the witness pair.

    Args:
        w: Tropical quadratic weight of dimension n ≥ 2.

    Returns:
        A GapCertificate with the minimum slack and witness pair.

    Example:
        >>> w = TropicalQuadraticWeight.uniform(4, 1.0, 2.0)
        >>> cert = compute_tropical_gap(w)
        >>> print(f"Gap = {cert.value}, witness = ({cert.witness_i}, {cert.witness_j})")
        Gap = 2.0, witness = (0, 1)
    """
    n = w.n
    assert n >= 2, "Need at least 2 indices"

    min_slack = float('inf')
    witness = (0, 1)
    all_slacks = {}

    for i in range(n):
        for j in range(n):
            if i != j:
                slack = diag_exchange_slack(w, i, j)
                all_slacks[(i, j)] = slack
                if slack < min_slack:
                    min_slack = slack
                    witness = (i, j)

    return GapCertificate(
        value=min_slack,
        witness_i=witness[0],
        witness_j=witness[1],
        all_slacks=all_slacks
    )


def verify_certificate(w: TropicalQuadraticWeight, cert: GapCertificate,
                       tol: float = 1e-12) -> bool:
    """Verify that a gap certificate is valid.

    Time complexity: O(n²)

    Args:
        w: Tropical quadratic weight.
        cert: Certificate to verify.
        tol: Numerical tolerance.

    Returns:
        True if the certificate is valid.
    """
    # Check witness produces the claimed value
    actual_slack = diag_exchange_slack(w, cert.witness_i, cert.witness_j)
    if abs(actual_slack - cert.value) > tol:
        return False

    # Check it's a minimum
    for i in range(w.n):
        for j in range(w.n):
            if i != j:
                if diag_exchange_slack(w, i, j) < cert.value - tol:
                    return False

    return True


def certify_lorentzian(w: TropicalQuadraticWeight) -> Tuple[bool, Optional[GapCertificate]]:
    """Certify whether an exp-weight matrix is Lorentzian.

    A positive symmetric matrix M with M(i,j) = exp(w(i,j)) satisfies the
    Lorentzian condition (at most one positive eigenvalue per 2×2 submatrix)
    if and only if the tropical spectral gap is nonneg.

    Time complexity: O(n²)

    Args:
        w: Tropical quadratic weight.

    Returns:
        (is_lorentzian, certificate) where certificate witnesses the gap.

    Example:
        >>> w = TropicalQuadraticWeight.uniform(3, 0.0, 1.0)
        >>> is_lor, cert = certify_lorentzian(w)
        >>> print(f"Lorentzian: {is_lor}, gap = {cert.value}")
        Lorentzian: True, gap = 2.0
    """
    cert = compute_tropical_gap(w)
    return cert.value >= 0, cert


def certify_stability(w: TropicalQuadraticWeight,
                      perturbation_bound: float) -> Tuple[bool, str]:
    """Certify stability of Lorentzian property under perturbation.

    If the tropical gap δ > 4ε where ε is the max entry-wise perturbation,
    then the perturbed weight still has nonneg exchange slacks.

    Time complexity: O(n²)

    Args:
        w: Tropical quadratic weight.
        perturbation_bound: Maximum entry-wise perturbation ε.

    Returns:
        (is_stable, explanation)
    """
    cert = compute_tropical_gap(w)
    threshold = 4 * perturbation_bound

    if cert.value >= threshold:
        return True, (f"Stable: gap {cert.value:.6f} ≥ 4·ε = {threshold:.6f}. "
                      f"Witness: ({cert.witness_i}, {cert.witness_j})")
    elif cert.value >= 0:
        return False, (f"Lorentzian but may lose stability: gap {cert.value:.6f} < "
                       f"4·ε = {threshold:.6f}")
    else:
        return False, f"Not Lorentzian: gap {cert.value:.6f} < 0"


def exp_weight_det2(w: TropicalQuadraticWeight, i: int, j: int) -> float:
    """Compute det₂(i,j) = exp(w_ij)² - exp(w_ii)·exp(w_jj).

    By the tropical-determinant bridge theorem:
    det₂(i,j) = exp(w_ii + w_jj) · (exp(δ(i,j)) - 1)

    Time complexity: O(1)
    """
    return np.exp(w.weight(i, j))**2 - np.exp(w.weight(i, i)) * np.exp(w.weight(j, j))


def rescale_weight(w: TropicalQuadraticWeight, omega: np.ndarray,
                   t: float) -> TropicalQuadraticWeight:
    """Rescale weight: w' = w + t·ω (Maslov dequantization).

    Time complexity: O(n²)

    Args:
        w: Base weight.
        omega: Rescaling direction (symmetric matrix).
        t: Scale parameter.

    Returns:
        Rescaled weight.
    """
    return TropicalQuadraticWeight(w.w + t * omega)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Tropical Gap Certification Examples ===\n")

    # Example 1: Uniform weight (Lorentzian)
    w1 = TropicalQuadraticWeight.uniform(5, 0.0, 2.0)
    is_lor, cert = certify_lorentzian(w1)
    print(f"Uniform (d=0, c=2, n=5):")
    print(f"  Lorentzian: {is_lor}")
    print(f"  Gap: {cert.value}")
    print(f"  Certificate valid: {verify_certificate(w1, cert)}\n")

    # Example 2: Non-Lorentzian
    w2 = TropicalQuadraticWeight.uniform(5, 3.0, 1.0)
    is_lor2, cert2 = certify_lorentzian(w2)
    print(f"Uniform (d=3, c=1, n=5):")
    print(f"  Lorentzian: {is_lor2}")
    print(f"  Gap: {cert2.value}\n")

    # Example 3: Stability certification
    w3 = TropicalQuadraticWeight.uniform(4, 0.0, 1.0)
    for eps in [0.1, 0.3, 0.5, 0.6]:
        stable, msg = certify_stability(w3, eps)
        print(f"  ε={eps}: {msg}")
