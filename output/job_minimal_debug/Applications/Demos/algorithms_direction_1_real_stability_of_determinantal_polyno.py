"""
algorithms.py — Certified real stability checking and DPP analysis algorithms.

Implements:
1. PSD certification via Cholesky decomposition
2. Real stability certification for determinantal polynomials
3. Numerical stability margin computation
4. Ultra log-concavity verification
"""

import numpy as np
from numpy.linalg import eigvalsh, cholesky, det
from itertools import combinations
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class PSDCertificate:
    """Certificate that a matrix is positive semidefinite."""
    is_psd: bool
    eigenvalues: np.ndarray
    cholesky_factor: Optional[np.ndarray]
    min_eigenvalue: float
    error_message: str = ""


@dataclass
class StabilityCertificate:
    """Certificate of real stability for a determinantal polynomial."""
    is_stable: bool
    psd_certificate: PSDCertificate
    stability_margin: float  # min |Z_K(z)| over sampled z ∈ H^n
    num_samples_tested: int
    elementary_symmetric: List[float]
    log_concavity_ratios: List[float]


def verify_symmetry(K: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if K is symmetric within tolerance.

    Args:
        K: Square matrix to check.
        tol: Tolerance for symmetry check.

    Returns:
        True if K is symmetric within tolerance.

    Example:
        >>> K = np.array([[1, 0.5], [0.5, 1]])
        >>> verify_symmetry(K)
        True
    """
    return np.allclose(K, K.T, atol=tol)


def certify_psd(K: np.ndarray, tol: float = 1e-10) -> PSDCertificate:
    """Certify that a symmetric matrix is positive semidefinite.

    Uses eigendecomposition as the primary check and attempts
    Cholesky decomposition as a secondary certificate.

    Args:
        K: Symmetric matrix to certify.
        tol: Tolerance for eigenvalue check.

    Returns:
        PSDCertificate with eigenvalues and Cholesky factor.

    Example:
        >>> K = np.array([[2, 1], [1, 2]])
        >>> cert = certify_psd(K)
        >>> cert.is_psd
        True
        >>> cert.min_eigenvalue > 0
        True
    """
    if not verify_symmetry(K, tol):
        return PSDCertificate(
            is_psd=False,
            eigenvalues=np.array([]),
            cholesky_factor=None,
            min_eigenvalue=float('-inf'),
            error_message="Matrix is not symmetric"
        )

    eigenvalues = eigvalsh(K)
    min_eig = float(eigenvalues.min())

    chol = None
    if min_eig >= -tol:
        try:
            K_shifted = K + max(0, -min_eig + tol) * np.eye(K.shape[0])
            chol = cholesky(K_shifted)
        except np.linalg.LinAlgError:
            pass

    return PSDCertificate(
        is_psd=(min_eig >= -tol),
        eigenvalues=eigenvalues,
        cholesky_factor=chol,
        min_eigenvalue=min_eig
    )


def compute_elementary_symmetric(eigenvalues: np.ndarray) -> List[float]:
    """Compute elementary symmetric polynomials of eigenvalues.

    e_k = sum over k-element subsets S of prod_{i in S} lambda_i

    Args:
        eigenvalues: Array of eigenvalues.

    Returns:
        List [e_0, e_1, ..., e_n] where e_0 = 1.

    Example:
        >>> compute_elementary_symmetric(np.array([2.0, 3.0]))
        [1.0, 5.0, 6.0]
    """
    n = len(eigenvalues)
    e = [0.0] * (n + 1)
    e[0] = 1.0
    for k in range(1, n + 1):
        for S in combinations(range(n), k):
            e[k] += float(np.prod([eigenvalues[i] for i in S]))
    return e


def compute_log_concavity_ratios(e: List[float]) -> List[float]:
    """Compute ultra log-concavity ratios e_k^2 / (e_{k-1} * e_{k+1}).

    By the main theorem, these ratios are always ≥ 1 for PSD matrices.

    Args:
        e: Elementary symmetric polynomials [e_0, ..., e_n].

    Returns:
        List of ratios for k = 1, ..., n-1.

    Example:
        >>> e = [1.0, 5.0, 6.0]
        >>> ratios = compute_log_concavity_ratios(e)
        >>> all(r >= 1.0 for r in ratios)
        True
    """
    ratios = []
    for k in range(1, len(e) - 1):
        denom = e[k - 1] * e[k + 1]
        if denom > 0 and e[k] > 0:
            ratios.append(e[k] ** 2 / denom)
        else:
            ratios.append(float('inf'))
    return ratios


def sample_upper_half_plane(n: int, num_samples: int = 1) -> np.ndarray:
    """Sample random points from the upper half-plane H^n.

    Args:
        n: Dimension.
        num_samples: Number of samples to generate.

    Returns:
        Array of shape (num_samples, n) of complex numbers with Im > 0.
    """
    real_parts = np.random.uniform(-10, 10, (num_samples, n))
    imag_parts = np.random.uniform(0.01, 10, (num_samples, n))
    return real_parts + 1j * imag_parts


def evaluate_determinantal_poly(K: np.ndarray, z: np.ndarray) -> complex:
    """Evaluate det(I + diag(z) * K) for complex z.

    Args:
        K: Real symmetric PSD matrix.
        z: Complex vector with positive imaginary parts.

    Returns:
        Complex value det(I + diag(z) * K).
    """
    n = K.shape[0]
    M = np.eye(n, dtype=complex) + np.diag(z) @ K.astype(complex)
    return complex(det(M))


def certify_real_stability(
    K: np.ndarray,
    num_samples: int = 10000,
    tol: float = 1e-10
) -> StabilityCertificate:
    """Certify real stability of the determinantal polynomial Z_K.

    Algorithm:
    1. Verify K is symmetric
    2. Compute eigenvalues and verify PSD
    3. Compute elementary symmetric polynomials
    4. Compute log-concavity ratios
    5. Numerically verify stability at random upper half-plane points

    By Theorem 3.5, if K is PSD then Z_K is real stable. The numerical
    check provides additional confidence and computes the stability margin.

    Args:
        K: Input matrix.
        num_samples: Number of random upper half-plane points to test.
        tol: Numerical tolerance.

    Returns:
        StabilityCertificate with full analysis.

    Example:
        >>> K = np.array([[1, 0.5], [0.5, 1]])
        >>> cert = certify_real_stability(K)
        >>> cert.is_stable
        True
        >>> all(r >= 1.0 for r in cert.log_concavity_ratios)
        True
    """
    n = K.shape[0]
    psd_cert = certify_psd(K, tol)

    if not psd_cert.is_psd:
        return StabilityCertificate(
            is_stable=False,
            psd_certificate=psd_cert,
            stability_margin=0.0,
            num_samples_tested=0,
            elementary_symmetric=[],
            log_concavity_ratios=[]
        )

    eigenvalues = np.maximum(psd_cert.eigenvalues, 0)
    e = compute_elementary_symmetric(eigenvalues)
    ratios = compute_log_concavity_ratios(e)

    # Numerical stability check
    min_abs = float('inf')
    z_samples = sample_upper_half_plane(n, num_samples)
    for z in z_samples:
        val = evaluate_determinantal_poly(K, z)
        min_abs = min(min_abs, abs(val))

    return StabilityCertificate(
        is_stable=True,  # Guaranteed by theorem when PSD
        psd_certificate=psd_cert,
        stability_margin=min_abs,
        num_samples_tested=num_samples,
        elementary_symmetric=e,
        log_concavity_ratios=ratios
    )


def stability_report(cert: StabilityCertificate) -> str:
    """Generate a human-readable stability report.

    Args:
        cert: StabilityCertificate from certify_real_stability.

    Returns:
        Formatted string report.
    """
    lines = []
    lines.append("=" * 60)
    lines.append("REAL STABILITY CERTIFICATE")
    lines.append("=" * 60)

    lines.append(f"\nPSD Status: {'✓ Positive Semidefinite' if cert.psd_certificate.is_psd else '✗ Not PSD'}")
    if cert.psd_certificate.eigenvalues.size > 0:
        lines.append(f"Eigenvalues: {cert.psd_certificate.eigenvalues.round(6)}")
        lines.append(f"Min eigenvalue: {cert.psd_certificate.min_eigenvalue:.6e}")

    lines.append(f"\nReal Stable: {'✓ Yes (by theorem)' if cert.is_stable else '✗ No (not PSD)'}")
    lines.append(f"Stability margin: {cert.stability_margin:.6e}")
    lines.append(f"Samples tested: {cert.num_samples_tested}")

    if cert.elementary_symmetric:
        lines.append(f"\nElementary symmetric polynomials:")
        for k, e_k in enumerate(cert.elementary_symmetric):
            lines.append(f"  e_{k} = {e_k:.6f}")

    if cert.log_concavity_ratios:
        lines.append(f"\nLog-concavity ratios e_k² / (e_{{k-1}} · e_{{k+1}}):")
        for k, r in enumerate(cert.log_concavity_ratios, 1):
            status = "✓" if r >= 1.0 else "✗"
            lines.append(f"  k={k}: {r:.6f} {status}")

    lines.append("=" * 60)
    return "\n".join(lines)


# ─── Example usage ───

if __name__ == "__main__":
    np.random.seed(42)

    print("Generating random 4×4 PSD matrix...")
    A = np.random.randn(4, 4)
    K = A @ A.T / 4

    print(f"K =\n{K.round(4)}\n")

    cert = certify_real_stability(K)
    print(stability_report(cert))

    print("\n\nTesting with a non-PSD matrix...")
    K_bad = np.array([[1, 2], [2, 1]])
    cert_bad = certify_real_stability(K_bad)
    print(stability_report(cert_bad))
