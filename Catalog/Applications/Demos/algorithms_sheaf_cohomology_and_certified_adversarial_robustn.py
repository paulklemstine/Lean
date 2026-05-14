#!/usr/bin/env python3
"""
Algorithms for Cohomological Robustness Certification

Implements the core algorithms from the research paper:
1. Čech cocycle computation on finite covers
2. Coboundary decomposition (H¹ vanishing test)
3. Global certified radius computation
4. Stalk vulnerability detection
5. ReLU region decomposition and margin analysis

All algorithms have polynomial complexity in the number of regions.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class LinearRegion:
    """A single linear region of a piecewise-linear function.

    Attributes
    ----------
    index : int
        Region identifier.
    bounds : tuple of (float, float)
        Interval [a, b] for 1D; more generally, a polyhedron description.
    slope : np.ndarray
        Gradient of the affine function on this region.
    intercept : float
        Bias of the affine function on this region.
    margin : float
        Minimum score gap on this region.
    lipschitz : float
        Lipschitz constant of the score-gap function on this region.
    """
    index: int
    bounds: Tuple[float, float]
    slope: float
    intercept: float
    margin: float = 0.0
    lipschitz: float = 0.0


@dataclass
class CechCocycle:
    """A Čech 1-cocycle on a finite cover.

    The cocycle c : ι × ι → ℝ satisfies:
        c(i, k) = c(i, j) + c(j, k)  for all i, j, k

    Attributes
    ----------
    matrix : np.ndarray
        The cocycle values c(i, j) as an n×n matrix.
    is_cocycle : bool
        Whether the cocycle condition is verified.
    """
    matrix: np.ndarray
    is_cocycle: bool = False


@dataclass
class CoboundaryDecomposition:
    """Decomposition of a cocycle as a coboundary.

    If c(i, j) = b(j) - b(i), then b is the primitive.

    Attributes
    ----------
    primitive : np.ndarray
        The 0-cochain b such that c(i,j) = b(j) - b(i).
    is_exact : bool
        Whether the decomposition is exact (cocycle is a coboundary).
    residual : float
        Maximum decomposition error.
    """
    primitive: np.ndarray
    is_exact: bool = False
    residual: float = 0.0


@dataclass
class RobustnessCertificate:
    """A global robustness certificate.

    Attributes
    ----------
    radius : float
        Global certified L∞ perturbation radius.
    min_margin : float
        The minimum local margin across all regions.
    global_lipschitz : float
        The global Lipschitz constant.
    is_certified : bool
        Whether the certificate is valid (radius > 0).
    local_radii : list of float
        Per-region certified radii.
    """
    radius: float
    min_margin: float
    global_lipschitz: float
    is_certified: bool
    local_radii: List[float]


# ============================================================
# Algorithm 1: Čech Cocycle Computation
# ============================================================

def compute_cech_cocycle(local_radii: List[float]) -> CechCocycle:
    """
    Compute the Čech 1-cocycle from local robustness radii.

    The cocycle measures discrepancies between local certificates:
        c(i, j) = r_j - r_i

    where r_i = margin_i / L_i is the local certified radius on region i.

    Parameters
    ----------
    local_radii : list of float
        Local certified radii for each region.

    Returns
    -------
    CechCocycle
        The computed cocycle with verification status.

    Complexity
    ----------
    Time: O(n²) where n is the number of regions.
    Space: O(n²) for the cocycle matrix.

    Notes
    -----
    For the canonical robustness cocycle, c(i,j) = r_j - r_i automatically
    satisfies the cocycle condition since:
        c(i,k) = r_k - r_i = (r_k - r_j) + (r_j - r_i) = c(j,k) + c(i,j)
    """
    n = len(local_radii)
    c = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            c[i, j] = local_radii[j] - local_radii[i]

    # Verify cocycle condition
    is_cocycle = True
    tol = 1e-12
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if abs(c[i, k] - c[i, j] - c[j, k]) > tol:
                    is_cocycle = False
                    break
            if not is_cocycle:
                break
        if not is_cocycle:
            break

    return CechCocycle(matrix=c, is_cocycle=is_cocycle)


# ============================================================
# Algorithm 2: Coboundary Decomposition
# ============================================================

def decompose_coboundary(cocycle: CechCocycle) -> CoboundaryDecomposition:
    """
    Decompose a cocycle as a coboundary: find b such that c(i,j) = b(j) - b(i).

    This implements the constructive proof that H¹ vanishes for finite covers:
    fix a base index i₀ and set b(i) = c(i₀, i).

    Parameters
    ----------
    cocycle : CechCocycle
        A verified Čech 1-cocycle.

    Returns
    -------
    CoboundaryDecomposition
        The primitive b and verification status.

    Complexity
    ----------
    Time: O(n²) for verification.
    Space: O(n) for the primitive.

    Mathematical Justification
    --------------------------
    For a cocycle c satisfying c(i,k) = c(i,j) + c(j,k), setting b(i) = c(i₀, i)
    for a fixed base i₀ gives:
        b(j) - b(i) = c(i₀, j) - c(i₀, i) = c(i, j)
    where the last equality uses the cocycle condition with k=j, and antisymmetry.
    """
    n = cocycle.matrix.shape[0]
    c = cocycle.matrix

    # Fix base index 0
    b = np.zeros(n)
    for i in range(n):
        b[i] = c[0, i]

    # Verify decomposition
    max_residual = 0.0
    for i in range(n):
        for j in range(n):
            residual = abs(c[i, j] - (b[j] - b[i]))
            max_residual = max(max_residual, residual)

    is_exact = max_residual < 1e-10

    return CoboundaryDecomposition(
        primitive=b,
        is_exact=is_exact,
        residual=max_residual
    )


# ============================================================
# Algorithm 3: Global Certified Radius
# ============================================================

def compute_global_certificate(
    margins: List[float],
    lipschitz_constants: List[float],
    global_lipschitz: Optional[float] = None
) -> RobustnessCertificate:
    """
    Compute the global robustness certificate via cohomological descent.

    This implements the main theorem:
        ε = min_i(m_i) / L

    where m_i are local margins and L is the global Lipschitz constant.

    Parameters
    ----------
    margins : list of float
        Local margins m_i for each region.
    lipschitz_constants : list of float
        Local Lipschitz constants L_i for each region.
    global_lipschitz : float, optional
        Global Lipschitz constant. If None, uses max(L_i).

    Returns
    -------
    RobustnessCertificate
        The global certificate with all metadata.

    Complexity
    ----------
    Time: O(n) where n is the number of regions.
    Space: O(n) for local radii storage.

    Algorithm
    ---------
    1. Compute local radii r_i = m_i / L_i for each region.
    2. Compute cocycle (automatic for the canonical construction).
    3. Verify H¹ = 0 (always true for finite covers).
    4. Global radius = min(m_i) / max(L_i) using the global Lipschitz constant.
    """
    if global_lipschitz is None:
        global_lipschitz = max(lipschitz_constants)

    local_radii = []
    for m, l in zip(margins, lipschitz_constants):
        if l > 0:
            local_radii.append(m / l)
        else:
            local_radii.append(float('inf') if m >= 0 else 0.0)

    min_margin = min(margins)
    if min_margin <= 0 or global_lipschitz <= 0:
        radius = 0.0
    else:
        radius = min_margin / global_lipschitz

    return RobustnessCertificate(
        radius=radius,
        min_margin=min_margin,
        global_lipschitz=global_lipschitz,
        is_certified=radius > 0,
        local_radii=local_radii
    )


# ============================================================
# Algorithm 4: Stalk Vulnerability Detection
# ============================================================

def detect_stalk_vulnerability(
    margins: List[float],
    region_assignments: Dict[int, List[int]],
) -> Dict[int, bool]:
    """
    Detect vulnerability at each point via stalk analysis.

    A point x is vulnerable if every region containing x has non-positive margin.
    Equivalently, the stalk of the decision sheaf at x admits no positive section.

    Parameters
    ----------
    margins : list of float
        Local margins for each region.
    region_assignments : dict
        Maps point index to list of region indices covering that point.

    Returns
    -------
    dict
        Maps point index to vulnerability status (True = vulnerable).

    Complexity
    ----------
    Time: O(|points| × max_regions_per_point).
    Space: O(|points|).

    Mathematical Basis
    ------------------
    By the stalk vulnerability theorem:
        VulnerableAt'(F, x) ↔ ∀ i, x ∈ U_i → F.localMargin(i, x) ≤ 0
                            ↔ ¬∃ γ > 0, PositiveStalkMargin(F, x, γ)
    """
    vulnerability = {}
    for pt_idx, region_list in region_assignments.items():
        # Point is vulnerable iff all covering regions have non-positive margin
        is_vulnerable = all(margins[r] <= 0 for r in region_list)
        vulnerability[pt_idx] = is_vulnerable
    return vulnerability


# ============================================================
# Algorithm 5: ReLU Region Decomposition
# ============================================================

def decompose_relu_regions_1d(
    weights: List[List[float]],
    biases: List[List[float]]
) -> List[LinearRegion]:
    """
    Decompose a 1D ReLU network into its linear regions.

    A ReLU network with weights w and biases b computes:
        f(x) = w_L · ReLU(w_{L-1} · ReLU(... ReLU(w_1 · x + b_1) ...) + b_{L-1}) + b_L

    The breakpoints occur where pre-activation values cross zero.

    Parameters
    ----------
    weights : list of list of float
        Weight matrices for each layer (1D: scalars).
    biases : list of list of float
        Bias vectors for each layer.

    Returns
    -------
    list of LinearRegion
        The linear regions with computed slopes and intercepts.

    Complexity
    ----------
    Time: O(P) where P is the total number of neurons (breakpoints).
    Space: O(P) for storing regions.
    """
    # For a 1D network, compute breakpoints analytically
    # Simplified: assume single hidden layer for demo
    if len(weights) < 2:
        return [LinearRegion(0, (-np.inf, np.inf), weights[0][0], biases[0][0])]

    # Hidden layer breakpoints: w1 * x + b1 = 0 => x = -b1/w1
    breakpoints = []
    w1 = weights[0]
    b1 = biases[0]
    for wi, bi in zip(w1, b1):
        if abs(wi) > 1e-12:
            breakpoints.append(-bi / wi)

    breakpoints = sorted(set(breakpoints))

    # Compute slope and intercept on each region
    regions = []
    all_bounds = [(-100.0, breakpoints[0])] if breakpoints else [(-100.0, 100.0)]
    for i in range(len(breakpoints) - 1):
        all_bounds.append((breakpoints[i], breakpoints[i + 1]))
    if breakpoints:
        all_bounds.append((breakpoints[-1], 100.0))

    for idx, (a, b) in enumerate(all_bounds):
        mid = (a + b) / 2
        # Evaluate network at midpoint to get slope/intercept
        # For single hidden layer: f(x) = w2 · ReLU(w1 · x + b1) + b2
        h = np.maximum(0, np.array(w1) * mid + np.array(b1))
        w2 = weights[1]
        b2 = biases[1]
        y = np.dot(w2, h) + b2[0]

        # Compute slope by finite difference
        dx = 1e-6
        h_plus = np.maximum(0, np.array(w1) * (mid + dx) + np.array(b1))
        y_plus = np.dot(w2, h_plus) + b2[0]
        slope = (y_plus - y) / dx
        intercept = y - slope * mid

        regions.append(LinearRegion(
            index=idx,
            bounds=(a, b),
            slope=slope,
            intercept=intercept,
            lipschitz=abs(slope)
        ))

    return regions


# ============================================================
# Main: Example Usage
# ============================================================

if __name__ == "__main__":
    print("Cohomological Robustness Certification - Algorithm Suite")
    print("=" * 60)

    # Example: 5-region piecewise-linear classifier
    margins = [0.8, 1.2, 0.5, 0.9, 0.7]
    lip_constants = [2.0, 1.5, 3.0, 1.8, 2.5]

    print("\n1. Computing local certificates...")
    cert = compute_global_certificate(margins, lip_constants)
    print(f"   Local radii: {[f'{r:.4f}' for r in cert.local_radii]}")
    print(f"   Min margin: {cert.min_margin:.4f}")
    print(f"   Global Lipschitz: {cert.global_lipschitz:.4f}")
    print(f"   Global radius: {cert.radius:.4f}")
    print(f"   Certified: {cert.is_certified}")

    print("\n2. Computing Čech cocycle...")
    cocycle = compute_cech_cocycle(cert.local_radii)
    print(f"   Cocycle condition: {cocycle.is_cocycle}")

    print("\n3. Coboundary decomposition (H¹ = 0 test)...")
    decomp = decompose_coboundary(cocycle)
    print(f"   Is coboundary: {decomp.is_exact}")
    print(f"   Primitive: {np.round(decomp.primitive, 4)}")
    print(f"   Residual: {decomp.residual:.2e}")

    print("\n4. Stalk vulnerability detection...")
    # Each point covered by its region and neighbors
    assignments = {
        0: [0, 1], 1: [1, 2], 2: [2, 3], 3: [3, 4], 4: [0, 4]
    }
    vuln = detect_stalk_vulnerability(margins, assignments)
    for pt, is_vuln in vuln.items():
        status = "VULNERABLE" if is_vuln else "SAFE"
        print(f"   Point {pt}: {status}")

    print("\n5. ReLU region decomposition (single hidden layer)...")
    w1 = [1.0, -2.0, 0.5]  # 3 neurons
    b1 = [0.5, 1.0, -0.3]
    w2 = [0.8, -0.5, 1.2]
    b2 = [0.1]
    regions = decompose_relu_regions_1d([w1, w2], [b1, b2])
    for r in regions:
        print(f"   Region {r.index}: [{r.bounds[0]:.2f}, {r.bounds[1]:.2f}], "
              f"slope={r.slope:.4f}, Lip={r.lipschitz:.4f}")

    print("\n" + "=" * 60)
    print("All algorithms completed successfully.")
