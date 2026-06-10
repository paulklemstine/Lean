"""
Sheaf Cohomology Robustness Certification — Core Algorithms

Type-hinted implementations of the key algorithms from the sheaf-cohomological
approach to certified adversarial robustness.
"""

from typing import List, Tuple, Callable, Optional
import numpy as np


def compute_persistent_robust_set(
    score_gap: Callable[[np.ndarray], float],
    points: np.ndarray,
    radius: float,
    n_samples: int = 100,
) -> np.ndarray:
    """
    Approximate the persistent robust set at a given radius.

    For each point x, samples n_samples perturbations within the ball of
    the given radius and checks if score_gap remains positive.

    Args:
        score_gap: Function mapping input vectors to score gaps (margin).
        points: Array of shape (N, d) — points to test.
        radius: Perturbation radius.
        n_samples: Number of random perturbations per point.

    Returns:
        Boolean array of shape (N,) indicating membership in the robust set.
    """
    N, d = points.shape
    robust = np.ones(N, dtype=bool)

    for i in range(N):
        x = points[i]
        for _ in range(n_samples):
            # Sample uniform perturbation in L-infinity ball
            delta = np.random.uniform(-radius, radius, size=d)
            y = x + delta
            if score_gap(y) <= 0:
                robust[i] = False
                break

    return robust


def compute_lipschitz_robustness_radius(
    margin: float,
    lipschitz_const: float,
) -> float:
    """
    Compute the certified robustness radius from margin and Lipschitz constant.

    The fundamental certificate: if score_gap(x) >= margin and score_gap is
    L-Lipschitz, then x is robust at radius margin/L.

    Args:
        margin: Score gap at the point (must be positive for nontrivial radius).
        lipschitz_const: Lipschitz constant of the score gap function.

    Returns:
        Certified robustness radius.
    """
    if margin <= 0 or lipschitz_const <= 0:
        return 0.0
    return margin / lipschitz_const


def composition_robustness_radius(
    margin: float,
    lip_feature: float,
    lip_classifier: float,
) -> float:
    """
    Certified radius for composed Lipschitz maps (multi-layer network).

    For f: X -> Y with Lipschitz L1, g: Y -> R with Lipschitz L2,
    if g(f(x)) >= margin, then x is robust at radius margin / (L1 * L2).

    Args:
        margin: Score gap g(f(x)).
        lip_feature: Lipschitz constant of feature extractor f.
        lip_classifier: Lipschitz constant of classifier head g.

    Returns:
        Certified robustness radius for the composition.
    """
    if margin <= 0 or lip_feature <= 0 or lip_classifier <= 0:
        return 0.0
    return margin / (lip_feature * lip_classifier)


def mayer_vietoris_robustness_radius(
    radii: List[float],
) -> float:
    """
    Compute the global robustness radius from local radii via Mayer-Vietoris.

    Given a finite cover with local robustness radii r_1, ..., r_n,
    the global radius (under vanishing H1) is min(r_1, ..., r_n).

    Args:
        radii: List of local robustness radii.

    Returns:
        Global certified robustness radius.
    """
    if not radii:
        return 0.0
    return min(radii)


def cech_cohomology_vanishes(
    cocycle: np.ndarray,
) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Check if a 1-cocycle on a finite index set is a coboundary (H1 = 0).

    A cocycle c: I x I -> R satisfies c(i,k) = c(i,j) + c(j,k).
    It is a coboundary if c(i,j) = b(j) - b(i) for some potential b.

    For finite index sets, H1 always vanishes: fix a base vertex i0,
    set b(j) = c(i0, j), then c(i,j) = c(i0,j) - c(i0,i) = b(j) - b(i).

    Args:
        cocycle: Square matrix of shape (n, n) representing the 1-cocycle.

    Returns:
        Tuple of (vanishes: bool, potential: Optional[np.ndarray]).
        If vanishes is True, potential is the coboundary potential b.
    """
    n = cocycle.shape[0]

    # Check cocycle condition
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if not np.isclose(cocycle[i, k], cocycle[i, j] + cocycle[j, k]):
                    return False, None

    # Construct potential: b(j) = c(0, j)
    potential = cocycle[0, :]

    # Verify coboundary
    for i in range(n):
        for j in range(n):
            if not np.isclose(cocycle[i, j], potential[j] - potential[i]):
                return False, None

    return True, potential


def weight_perturbation_stability(
    margin_lower_bound: float,
    delta: float,
    original_radius: float,
) -> float:
    """
    Compute the certified radius after weight perturbation.

    If the original network has margin lower bound m on the R-ball,
    and the perturbed network is delta-close pointwise, then the
    perturbed network is certified at radius R if m > delta.

    Args:
        margin_lower_bound: Minimum margin of original network on R-ball.
        delta: Pointwise perturbation bound |g1 - g2|.
        original_radius: Original certified radius.

    Returns:
        Certified radius for perturbed network.
    """
    if margin_lower_bound <= delta:
        return 0.0
    return original_radius


def sheaf_lipschitz_globalization(
    margins: List[float],
    lipschitz_consts: List[float],
) -> float:
    """
    Compute the global certified radius from local margin/Lipschitz data.

    For a finite cover where region i has margin m_i and Lipschitz constant L_i,
    the global radius is min_i(m_i / L_i).

    Args:
        margins: List of local margins.
        lipschitz_consts: List of local Lipschitz constants.

    Returns:
        Global certified robustness radius.
    """
    if not margins or not lipschitz_consts:
        return 0.0
    if len(margins) != len(lipschitz_consts):
        raise ValueError("margins and lipschitz_consts must have same length")

    local_radii = [
        m / L for m, L in zip(margins, lipschitz_consts)
        if m > 0 and L > 0
    ]
    if not local_radii:
        return 0.0
    return min(local_radii)


def persistent_robustness_barcode(
    score_gap: Callable[[np.ndarray], float],
    points: np.ndarray,
    radii: np.ndarray,
    n_samples: int = 50,
) -> np.ndarray:
    """
    Compute the persistent robustness "barcode" — the fraction of points
    that are robust at each radius level.

    Args:
        score_gap: Score gap function.
        points: Array of shape (N, d).
        radii: Array of radii to test (sorted ascending).
        n_samples: Perturbation samples per point per radius.

    Returns:
        Array of shape (len(radii),) with fraction of robust points at each radius.
    """
    results = np.zeros(len(radii))
    for k, r in enumerate(radii):
        robust = compute_persistent_robust_set(score_gap, points, r, n_samples)
        results[k] = np.mean(robust)
    return results


def refinement_radius_comparison(
    coarse_radii: List[float],
    fine_radii: List[float],
    refinement_map: List[int],
) -> Tuple[float, float, bool]:
    """
    Compare certified radii between a coarse and refined cover.

    Args:
        coarse_radii: Radii for the coarse cover.
        fine_radii: Radii for the refined cover.
        refinement_map: Maps fine index -> coarse index.

    Returns:
        (coarse_global, fine_global, improved) where improved indicates
        whether refinement strictly improved the global radius.
    """
    coarse_global = min(coarse_radii) if coarse_radii else 0.0
    fine_global = min(fine_radii) if fine_radii else 0.0
    return coarse_global, fine_global, fine_global > coarse_global
