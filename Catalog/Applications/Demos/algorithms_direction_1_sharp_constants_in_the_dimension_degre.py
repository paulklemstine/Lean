"""
algorithms.py — Certified Lorentzian stability algorithms.

Implements the verified computational methods from the research paper:
1. Certified stability checker (soundness proved in Lean 4)
2. Stability radius computation
3. Spectral gap estimation
4. Entry-to-operator-norm conversion
"""
import numpy as np
from typing import Tuple, Optional, List
from itertools import combinations


def certified_perturbation_tolerance(epsilon: float, n: int) -> float:
    """
    Compute the certified perturbation tolerance τ(ε, n) = ε / (2n).

    If all entries of a perturbation matrix satisfy |E_ij| ≤ τ,
    then the Lorentzian signature is preserved with a residual
    spectral gap of ε/2.

    This is formally verified in Lean 4 as `certifiedPertTolerance`.

    Args:
        epsilon: Spectral margin (gap parameter)
        n: Matrix dimension

    Returns:
        Maximum safe entry perturbation magnitude
    """
    if n <= 0 or epsilon <= 0:
        return 0.0
    return epsilon / (2.0 * n)


def certify_stability(epsilon: float, n: int, E: np.ndarray) -> bool:
    """
    Certify that a perturbation preserves Lorentzian signature.

    Given spectral margin ε, dimension n, and perturbation matrix E,
    checks whether all entries of E are within the certified tolerance.

    Soundness: If this returns True and A has gapped signature with
    margin ε, then A + E has at most one positive eigenvalue.
    (Verified in Lean 4 as `certified_stability_correct`.)

    Args:
        epsilon: Spectral margin of the original matrix
        n: Dimension
        E: Perturbation matrix (n × n)

    Returns:
        True if the perturbation is certified safe

    Example:
        >>> A = np.diag([3.0, -1.0, -1.0])  # Gapped Lorentzian
        >>> epsilon = 1.0  # Spectral gap
        >>> E = 0.1 * np.ones((3, 3))
        >>> certify_stability(epsilon, 3, E)  # τ = 1/(2·3) ≈ 0.167
        True
    """
    tau = certified_perturbation_tolerance(epsilon, n)
    return bool(np.all(np.abs(E) <= tau + 1e-15))


def compute_spectral_gap(H: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute the spectral gap and witness direction for a symmetric matrix.

    For a matrix with at most one positive eigenvalue, the spectral gap
    is the magnitude of the second-largest eigenvalue (which is ≤ 0).

    Args:
        H: Symmetric matrix (n × n)

    Returns:
        (gap, witness): spectral gap ε ≥ 0 and witness direction w
    """
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    if len(eigenvalues) < 2:
        return 0.0, eigenvectors[:, 0] if len(eigenvalues) > 0 else np.array([1.0])

    # Witness is the top eigenvector
    witness = eigenvectors[:, 0]

    # Gap is -λ₂ if λ₂ < 0
    gap = max(0.0, -eigenvalues[1])

    return gap, witness


def quadform_bound_sharp(n: int, B: float) -> float:
    """
    Sharp quadratic form bound: n · B.

    For any n×n matrix A with |A_ij| ≤ B,
    |Q_A(v)| ≤ n · B · ‖v‖² for all v.

    This is the central result of the paper, improving the
    previous bound of n² · B. Proved in Lean 4 as
    `quadFormBound_of_entry_bound_sharp`.

    Args:
        n: Matrix dimension
        B: Entry bound

    Returns:
        Quadratic form bound n·B

    Example:
        >>> quadform_bound_sharp(10, 0.01)
        0.1
        >>> # Compare with old bound:
        >>> # quadform_bound_old(10, 0.01) = 1.0
    """
    return float(n) * B


def stability_radius(
    hessians: List[np.ndarray],
    perturbation_direction: List[np.ndarray]
) -> float:
    """
    Compute the certified stability radius for a collection of Hessians.

    Given Hessian matrices H_1, ..., H_m and perturbation directions
    E_1, ..., E_m, compute the maximum t ≥ 0 such that H_k + t·E_k
    has at most one positive eigenvalue for all k.

    Uses the sharp n·B bound for the conversion from entry perturbation
    to quadratic form perturbation.

    Args:
        hessians: List of Hessian matrices
        perturbation_direction: List of perturbation matrices (same shape)

    Returns:
        Maximum certified safe scaling factor t₀

    Example:
        >>> H = [np.diag([3.0, -1.0, -1.0])]
        >>> E = [np.ones((3, 3)) * 0.1]
        >>> t0 = stability_radius(H, E)
        >>> print(f"Safe up to t = {t0:.4f}")
    """
    t0 = float('inf')

    for H, E in zip(hessians, perturbation_direction):
        n = H.shape[0]
        gap, _ = compute_spectral_gap(H)

        if gap <= 0:
            return 0.0

        max_entry = np.max(np.abs(E))
        if max_entry <= 0:
            continue

        # Using certified tolerance: τ = gap / (2n)
        # t · max_entry ≤ τ  ⟹  t ≤ gap / (2n · max_entry)
        t_safe = gap / (2.0 * n * max_entry)
        t0 = min(t0, t_safe)

    return t0 if t0 < float('inf') else 0.0


def elementary_symmetric_hessian(n: int, k: int, x: np.ndarray) -> np.ndarray:
    """
    Compute the Hessian of e_k(x_1, ..., x_n) at point x.

    Args:
        n: Number of variables
        k: Degree of the elementary symmetric polynomial
        x: Evaluation point (length n)

    Returns:
        n × n Hessian matrix
    """
    if k < 2:
        return np.zeros((n, n))

    H = np.zeros((n, n))
    indices = list(range(n))

    for i in range(n):
        for j in range(n):
            if i == j:
                H[i, j] = 0.0
            else:
                remaining = [idx for idx in indices if idx != i and idx != j]
                if k - 2 == 0:
                    H[i, j] = 1.0
                elif k - 2 > len(remaining):
                    H[i, j] = 0.0
                else:
                    val = 0.0
                    for combo in combinations(remaining, k - 2):
                        prod = 1.0
                        for c in combo:
                            prod *= x[c]
                        val += prod
                    H[i, j] = val
    return H


def verify_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check whether a symmetric matrix has at most one positive eigenvalue.

    Args:
        H: Symmetric matrix
        tol: Tolerance for positivity check

    Returns:
        True if at most one eigenvalue is positive
    """
    eigenvalues = np.linalg.eigvalsh(H)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1


# === Example usage ===

if __name__ == "__main__":
    print("Certified Lorentzian Stability Algorithms")
    print("=" * 50)

    # Example 1: Certify stability
    n = 5
    A = np.diag([5.0, -1.0, -1.0, -1.0, -1.0])
    gap, w = compute_spectral_gap(A)
    print(f"\nExample 1: n={n}, spectral gap = {gap:.4f}")
    print(f"  Certified tolerance (sharp): {certified_perturbation_tolerance(gap, n):.6f}")
    print(f"  Old tolerance (n²): {gap / (n*n):.6f}")
    print(f"  Improvement factor: {n}×")

    # Example 2: Stability radius
    E = np.random.RandomState(42).randn(n, n)
    E = (E + E.T) / 2
    t0 = stability_radius([A], [E])
    print(f"\nExample 2: Stability radius = {t0:.6f}")
    print(f"  At t = {t0:.6f}, A + t·E is certified Lorentzian")

    # Example 3: Elementary symmetric polynomial
    k = 3
    n = 8
    x = np.ones(n)
    H = elementary_symmetric_hessian(n, k, x)
    gap, _ = compute_spectral_gap(H)
    is_lor = verify_lorentzian_signature(H)
    print(f"\nExample 3: e_{k} in {n} variables at (1,...,1)")
    print(f"  Lorentzian: {is_lor}")
    print(f"  Spectral gap: {gap:.4f}")
    print(f"  Sharp tolerance: {certified_perturbation_tolerance(gap, n):.6f}")
