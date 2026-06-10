"""
Tropical Orbit Shadowing: Core Algorithms

Type-hinted implementations of the key algorithms from the tropical
orbit shadowing theory.
"""

from typing import Callable, List, Tuple, Optional
import numpy as np


def trop_mv(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical (max-plus) matrix-vector product: (A ⊗ x)_i = max_j(A_ij + x_j).

    Args:
        A: n×n matrix of real numbers
        x: n-vector of real numbers

    Returns:
        n-vector where entry i = max_j(A[i,j] + x[j])
    """
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) for i in range(n)])


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (max-plus) matrix multiplication: (A ⊗ B)_ij = max_k(A_ik + B_kj).

    Args:
        A: n×n matrix
        B: n×n matrix

    Returns:
        n×n matrix where entry (i,j) = max_k(A[i,k] + B[k,j])
    """
    n = A.shape[0]
    result = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            result[i, j] = np.max(A[i, :] + B[:, j])
    return result


def oscillation(x: np.ndarray) -> float:
    """Compute the oscillation of a vector: osc(x) = max(x) - min(x).

    Args:
        x: n-vector

    Returns:
        max(x) - min(x)
    """
    return float(np.max(x) - np.min(x))


def birkhoff_contraction_coefficient(A: np.ndarray, num_samples: int = 10000) -> float:
    """Estimate the Birkhoff contraction coefficient τ(A) numerically.

    Computes sup_{osc(x) > 0} osc(A ⊗ x) / osc(x) via random sampling.

    Args:
        A: n×n tropical matrix
        num_samples: number of random vectors to test

    Returns:
        Estimated contraction coefficient τ(A)
    """
    n = A.shape[0]
    max_ratio = 0.0

    for _ in range(num_samples):
        x = np.random.randn(n) * 5
        osc_x = oscillation(x)
        if osc_x < 1e-12:
            continue
        y = trop_mv(A, x)
        osc_y = oscillation(y)
        ratio = osc_y / osc_x
        max_ratio = max(max_ratio, ratio)

    return max_ratio


def accum_product(L: List[float], k: int, n: int) -> float:
    """Accumulated product of contraction rates: Π_{j=k+1}^{n-1} L[j].

    Args:
        L: list of Lipschitz constants
        k: start index
        n: end index (exclusive)

    Returns:
        Product of L[k+1] * L[k+2] * ... * L[n-1], or 1 if empty
    """
    product = 1.0
    for j in range(k + 1, n):
        product *= L[j]
    return product


def accum_error_sum(L: List[float], n: int) -> float:
    """Accumulated error sum: Σ_{k=0}^{n-1} Π_{j=k+1}^{n-1} L[j].

    This generalizes the geometric partial sum Σ_{k=0}^{n-1} L^k.

    Args:
        L: list of Lipschitz constants (at least n elements)
        n: number of steps

    Returns:
        The accumulated error sum
    """
    total = 0.0
    for k in range(n):
        total += accum_product(L, k, n)
    return total


def non_autonomous_shadowing_bound(
    L: List[float], delta: float, n: int
) -> float:
    """Compute the variable-rate shadowing bound at step n.

    For a non-autonomous system with Lipschitz constants L[0], ..., L[n-1]
    and per-step error delta, the tracking error at step n is bounded by
    delta * accum_error_sum(L, n).

    Args:
        L: list of per-step Lipschitz constants
        delta: per-step pseudo-orbit deviation bound
        n: time step

    Returns:
        Upper bound on dist(true_orbit(n), pseudo_orbit(n))
    """
    return delta * accum_error_sum(L, n)


def autonomous_shadowing_bound(L: float, delta: float) -> float:
    """Classical autonomous shadowing bound: δ/(1-L).

    Args:
        L: Lipschitz constant (must be < 1)
        delta: per-step error bound

    Returns:
        Shadowing radius δ/(1-L)
    """
    if L >= 1:
        raise ValueError(f"L must be < 1, got {L}")
    return delta / (1 - L)


def shadowing_certificate(
    lip_const: float, delta: float
) -> Tuple[float, bool]:
    """Construct a shadowing certificate.

    Args:
        lip_const: Lipschitz constant of the dynamics
        delta: per-step error bound

    Returns:
        Tuple of (certified_radius, is_contractive)
    """
    is_contractive = lip_const < 1.0
    if is_contractive:
        radius = delta / (1 - lip_const)
    else:
        radius = float('inf')
    return radius, is_contractive


def compose_certificates(
    delta1: float, L1: float,
    delta2: float, L2: float
) -> Tuple[float, float]:
    """Compose two shadowing certificates.

    Returns the bound on max(R1, R2) from the certificate composition theorem.

    Args:
        delta1, L1: parameters of first certificate
        delta2, L2: parameters of second certificate

    Returns:
        Tuple of (individual_max_radius, composed_bound)
    """
    R1 = delta1 / (1 - L1) if L1 < 1 else float('inf')
    R2 = delta2 / (1 - L2) if L2 < 1 else float('inf')
    max_R = max(R1, R2)

    L_max = max(L1, L2)
    delta_max = max(delta1, delta2)
    if L_max < 1:
        composed_bound = delta_max / (1 - L_max)
    else:
        composed_bound = float('inf')

    return max_R, composed_bound


def simulate_contraction_pseudo_orbit(
    f: Callable[[float], float],
    x0: float,
    delta: float,
    n_steps: int,
    seed: int = 42
) -> Tuple[List[float], List[float], List[float]]:
    """Simulate a pseudo-orbit with perturbations and its shadow.

    Args:
        f: the contractive map
        x0: starting point
        delta: max per-step perturbation
        n_steps: number of steps
        seed: random seed

    Returns:
        Tuple of (pseudo_orbit, true_orbit, distances)
    """
    rng = np.random.RandomState(seed)

    pseudo = [x0]
    true_orb = [x0]

    for k in range(n_steps):
        # Pseudo-orbit: apply f with perturbation
        noise = rng.uniform(-delta, delta)
        pseudo.append(f(pseudo[-1]) + noise)
        # True orbit: apply f exactly
        true_orb.append(f(true_orb[-1]))

    distances = [abs(t - p) for t, p in zip(true_orb, pseudo)]
    return pseudo, true_orb, distances


def cosine_annealing_lipschitz(
    mu: float, eta0: float, T: int
) -> List[float]:
    """Compute Lipschitz constants for SGD with cosine annealing.

    For gradient descent on a μ-strongly convex function with learning rate
    η_t = η₀ · (1 + cos(πt/T))/2, the Lipschitz constant is |1 - η_t · μ|.

    Args:
        mu: strong convexity parameter
        eta0: initial learning rate
        T: total number of steps (period)

    Returns:
        List of Lipschitz constants L[0], ..., L[T-1]
    """
    L = []
    for t in range(T):
        eta_t = eta0 * (1 + np.cos(np.pi * t / T)) / 2
        L_t = abs(1 - eta_t * mu)
        L.append(L_t)
    return L
