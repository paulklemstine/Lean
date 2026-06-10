"""
algorithms.py — Core algorithms for Neural PDE Universality Classes
via Renormalization Fixed Points.

Implements the renormalization group (RG) coarse-graining iteration,
universality class detection, spectral analysis of effective operators,
and the conjectured class counting formula.
"""

from typing import Callable, List, Tuple, Dict, Optional
import numpy as np


def rg_iterate(
    coarsen: Callable[[np.ndarray], np.ndarray],
    x: np.ndarray,
    n_steps: int
) -> List[np.ndarray]:
    """
    Iterate the coarse-graining operator n_steps times, returning the full orbit.

    Parameters
    ----------
    coarsen : callable
        The RG coarse-graining map T: X -> X.
    x : np.ndarray
        Initial operator (as a vector or matrix).
    n_steps : int
        Number of RG steps.

    Returns
    -------
    orbit : list of np.ndarray
        [x, T(x), T^2(x), ..., T^n(x)].
    """
    orbit = [x.copy()]
    current = x.copy()
    for _ in range(n_steps):
        current = coarsen(current)
        orbit.append(current.copy())
    return orbit


def compute_contraction_rate(
    coarsen: Callable[[np.ndarray], np.ndarray],
    samples: List[np.ndarray],
    dist_fn: Optional[Callable[[np.ndarray, np.ndarray], float]] = None
) -> float:
    """
    Estimate the contraction rate of an RG semigroup from samples.

    Computes max_i,j dist(T(x_i), T(x_j)) / dist(x_i, x_j) over all pairs.

    Parameters
    ----------
    coarsen : callable
        The coarse-graining map.
    samples : list of np.ndarray
        Sample points in operator space.
    dist_fn : callable, optional
        Distance function. Defaults to L2 norm.

    Returns
    -------
    rate : float
        Estimated contraction rate (should be < 1 for contractive RG).
    """
    if dist_fn is None:
        dist_fn = lambda a, b: float(np.linalg.norm(a - b))

    max_ratio = 0.0
    n = len(samples)
    for i in range(n):
        for j in range(i + 1, n):
            d_before = dist_fn(samples[i], samples[j])
            if d_before < 1e-15:
                continue
            d_after = dist_fn(coarsen(samples[i]), coarsen(samples[j]))
            ratio = d_after / d_before
            max_ratio = max(max_ratio, ratio)
    return max_ratio


def detect_universality_classes(
    orbits: List[List[np.ndarray]],
    threshold: float = 1e-4,
    dist_fn: Optional[Callable[[np.ndarray, np.ndarray], float]] = None
) -> List[int]:
    """
    Cluster orbits into universality classes based on asymptotic convergence.

    Two orbits are in the same class if their terminal iterates are within
    `threshold` distance.

    Parameters
    ----------
    orbits : list of list of np.ndarray
        Each inner list is an RG orbit [x, T(x), T^2(x), ...].
    threshold : float
        Distance threshold for class membership.
    dist_fn : callable, optional
        Distance function. Defaults to L2 norm.

    Returns
    -------
    labels : list of int
        Class label for each orbit.
    """
    if dist_fn is None:
        dist_fn = lambda a, b: float(np.linalg.norm(a - b))

    n = len(orbits)
    labels = [-1] * n
    current_label = 0

    for i in range(n):
        if labels[i] >= 0:
            continue
        labels[i] = current_label
        terminal_i = orbits[i][-1]
        for j in range(i + 1, n):
            if labels[j] >= 0:
                continue
            terminal_j = orbits[j][-1]
            if dist_fn(terminal_i, terminal_j) < threshold:
                labels[j] = current_label
        current_label += 1

    return labels


def conjectured_class_count(
    symmetry_dim: int,
    conservation_laws: int,
    diff_order: int  # unused in formula but part of invariant
) -> int:
    """
    Compute the conjectured number of universality classes.

    Formula: (d + 1) * (c + 1) where d = symmetry dimension,
    c = number of conservation laws.

    Parameters
    ----------
    symmetry_dim : int
        Dimension of the symmetry group.
    conservation_laws : int
        Number of independent conservation laws.
    diff_order : int
        Differential order (included for completeness).

    Returns
    -------
    count : int
        Predicted number of universality classes.
    """
    return (symmetry_dim + 1) * (conservation_laws + 1)


def effective_contraction_rate(base_rate: float, diff_order: int) -> float:
    """
    Compute the effective contraction rate for a PDE of given differential order.

    Higher-order PDEs contract faster: rate = base^order.

    Parameters
    ----------
    base_rate : float
        Base contraction rate (0 < base_rate < 1).
    diff_order : int
        Differential order of the PDE.

    Returns
    -------
    rate : float
        Effective contraction rate.
    """
    return base_rate ** diff_order


def spectral_analysis(
    coarsen: Callable[[np.ndarray], np.ndarray],
    fixed_point: np.ndarray,
    perturbation_scale: float = 1e-5
) -> Dict[str, float]:
    """
    Analyze the spectrum of the linearized RG operator at a fixed point.

    Uses finite-difference approximation to the Jacobian.

    Parameters
    ----------
    coarsen : callable
        The coarse-graining map.
    fixed_point : np.ndarray
        A fixed point of the map.
    perturbation_scale : float
        Scale for finite-difference computation.

    Returns
    -------
    spectrum : dict
        Contains 'leading_eigenvalue', 'spectral_gap', 'relevant_dim',
        'critical_exponent'.
    """
    d = len(fixed_point)
    jacobian = np.zeros((d, d))

    for j in range(d):
        e_j = np.zeros(d)
        e_j[j] = perturbation_scale
        f_plus = coarsen(fixed_point + e_j)
        f_minus = coarsen(fixed_point - e_j)
        jacobian[:, j] = (f_plus - f_minus) / (2 * perturbation_scale)

    eigenvalues = np.abs(np.linalg.eigvals(jacobian))
    eigenvalues = np.sort(eigenvalues)[::-1]

    leading = eigenvalues[0] if len(eigenvalues) > 0 else 0.0
    subleading = eigenvalues[1] if len(eigenvalues) > 1 else 0.0
    gap = leading - subleading

    # Count relevant directions (eigenvalue ≥ 1)
    relevant_dim = int(np.sum(eigenvalues >= 1.0 - 1e-10))

    # Critical exponent: ν = log(b) / log(λ_leading) where b is the rescaling factor
    # For simplicity, use ν = 1/log(λ) if λ > 1
    if leading > 1.0:
        critical_exponent = 1.0 / np.log(leading)
    else:
        critical_exponent = float('inf')  # irrelevant direction

    return {
        'leading_eigenvalue': float(leading),
        'spectral_gap': float(gap),
        'relevant_dim': relevant_dim,
        'critical_exponent': float(critical_exponent),
        'eigenvalues': eigenvalues.tolist()
    }


def affine_contraction_rg(
    contraction_rate: float,
    fixed_point: np.ndarray
) -> Callable[[np.ndarray], np.ndarray]:
    """
    Create an affine contraction RG map: T(x) = fp + c * (x - fp).

    This is the concrete ℝ^d instance of the abstract RGSemigroup.

    Parameters
    ----------
    contraction_rate : float
        The contraction rate c (0 ≤ c < 1).
    fixed_point : np.ndarray
        The target fixed point.

    Returns
    -------
    coarsen : callable
        The RG coarse-graining map.
    """
    def coarsen(x: np.ndarray) -> np.ndarray:
        return fixed_point + contraction_rate * (x - fixed_point)
    return coarsen


def simulate_pde_rg_collapse(
    n_architectures: int = 5,
    dim: int = 4,
    n_rg_steps: int = 50,
    contraction_rate: float = 0.7,
    seed: int = 42
) -> Dict:
    """
    Simulate the universality collapse for multiple architectures.

    Creates random initial operators and iterates a contractive RG,
    demonstrating that all orbits converge regardless of initialization.

    Parameters
    ----------
    n_architectures : int
        Number of distinct architectures.
    dim : int
        Dimension of operator space.
    n_rg_steps : int
        Number of RG iterations.
    contraction_rate : float
        Contraction rate (< 1).
    seed : int
        Random seed.

    Returns
    -------
    result : dict
        Contains orbits, distances, fixed point, contraction estimates.
    """
    rng = np.random.RandomState(seed)
    fixed_point = rng.randn(dim)

    coarsen = affine_contraction_rg(contraction_rate, fixed_point)

    # Random initial operators (different "architectures")
    initial_operators = [rng.randn(dim) * 3 + rng.randn(dim) for _ in range(n_architectures)]

    orbits = [rg_iterate(coarsen, x, n_rg_steps) for x in initial_operators]

    # Compute pairwise distances at each step
    distances = np.zeros((n_rg_steps + 1, n_architectures, n_architectures))
    for step in range(n_rg_steps + 1):
        for i in range(n_architectures):
            for j in range(n_architectures):
                distances[step, i, j] = np.linalg.norm(
                    orbits[i][step] - orbits[j][step]
                )

    # Distance to fixed point
    fp_distances = np.zeros((n_rg_steps + 1, n_architectures))
    for step in range(n_rg_steps + 1):
        for i in range(n_architectures):
            fp_distances[step, i] = np.linalg.norm(orbits[i][step] - fixed_point)

    return {
        'orbits': orbits,
        'distances': distances,
        'fp_distances': fp_distances,
        'fixed_point': fixed_point,
        'initial_operators': initial_operators,
        'contraction_rate': contraction_rate
    }
