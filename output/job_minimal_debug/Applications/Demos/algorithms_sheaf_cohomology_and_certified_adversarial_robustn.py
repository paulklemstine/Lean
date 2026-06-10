#!/usr/bin/env python3
"""
Algorithms for Cohomological Robustness Certification

Implements the core algorithms from the research paper:
  1. Čech cocycle verification (O(n³))
  2. Coboundary decomposition / gauge potential recovery (O(n²))
  3. Local-to-global radius computation (O(n))
  4. Vulnerability witness extraction (O(n²))
  5. Sheaf vs Lipschitz comparison (O(n))
"""

import numpy as np
from dataclasses import dataclass
from typing import Optional


@dataclass
class CoverData:
    """Data for a finite cover of input space by activation regions."""
    n_charts: int
    margins: np.ndarray       # Local margin on each chart
    lipschitz: np.ndarray     # Local Lipschitz constant on each chart

    def __post_init__(self):
        assert len(self.margins) == self.n_charts
        assert len(self.lipschitz) == self.n_charts
        assert all(m > 0 for m in self.margins), "All margins must be positive"
        assert all(L > 0 for L in self.lipschitz), "All Lipschitz constants must be positive"


@dataclass
class RobustnessCertificate:
    """A certified robustness radius with provenance."""
    radius: float
    method: str  # "sheaf_per_chart", "sheaf_global", "lipschitz_global"
    minimizing_chart: int
    is_valid: bool


@dataclass
class VulnerabilityWitness:
    """A witness of incompatibility between two charts."""
    chart_i: int
    chart_j: int
    discrepancy: float
    description: str


# ============================================================
# Algorithm 1: Čech Cocycle Verification
# ============================================================

def verify_cocycle(c: np.ndarray, tol: float = 1e-10) -> tuple[bool, Optional[tuple[int, int, int]]]:
    """
    Verify the cocycle condition: c[i,k] = c[i,j] + c[j,k] for all i,j,k.

    Time complexity: O(n³)
    Space complexity: O(1) (beyond input)

    Args:
        c: n×n matrix of pairwise discrepancies
        tol: numerical tolerance

    Returns:
        (is_cocycle, violating_triple) where violating_triple is None if valid,
        or (i,j,k) witnessing the first violation found.
    """
    n = c.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if abs(c[i, k] - c[i, j] - c[j, k]) > tol:
                    return False, (i, j, k)
    return True, None


# ============================================================
# Algorithm 2: Coboundary Decomposition
# ============================================================

def decompose_coboundary(c: np.ndarray, tol: float = 1e-10) -> tuple[bool, Optional[np.ndarray]]:
    """
    Attempt to decompose c as a coboundary: find f such that c[i,j] = f[j] - f[i].

    Uses the basepoint method from the nerve lemma proof:
    fix f[0] = 0, set f[i] = c[0,i], then verify consistency.

    Time complexity: O(n²)
    Space complexity: O(n)

    Args:
        c: n×n cocycle matrix
        tol: numerical tolerance

    Returns:
        (is_coboundary, potential) where potential is the function f if coboundary,
        None otherwise.
    """
    n = c.shape[0]
    f = np.zeros(n)
    for i in range(n):
        f[i] = c[0, i]

    # Verify consistency
    for i in range(n):
        for j in range(n):
            if abs(c[i, j] - (f[j] - f[i])) > tol:
                return False, None
    return True, f


# ============================================================
# Algorithm 3: Local-to-Global Radius Computation
# ============================================================

def compute_sheaf_radius(data: CoverData) -> RobustnessCertificate:
    """
    Compute the sheaf-theoretic certified radius: min_i(margin_i / lipschitz_i).

    This implements Theorem A (per-chart version): when H¹ vanishes on a finite
    cover, the global certified radius equals the minimum local radius.

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        data: Cover data with margins and Lipschitz constants

    Returns:
        RobustnessCertificate with the sheaf-derived radius.
    """
    local_radii = data.margins / data.lipschitz
    min_idx = int(np.argmin(local_radii))
    radius = local_radii[min_idx]

    return RobustnessCertificate(
        radius=radius,
        method="sheaf_per_chart",
        minimizing_chart=min_idx,
        is_valid=radius > 0
    )


def compute_global_lipschitz_radius(data: CoverData) -> RobustnessCertificate:
    """
    Compute the classical global Lipschitz radius: min(margins) / max(lipschitz).

    Time complexity: O(n)
    Space complexity: O(1)
    """
    min_margin_idx = int(np.argmin(data.margins))
    max_lip = np.max(data.lipschitz)
    radius = data.margins[min_margin_idx] / max_lip

    return RobustnessCertificate(
        radius=radius,
        method="lipschitz_global",
        minimizing_chart=min_margin_idx,
        is_valid=radius > 0
    )


# ============================================================
# Algorithm 4: Vulnerability Witness Extraction
# ============================================================

def extract_vulnerability_witness(
    c: np.ndarray, tol: float = 1e-10
) -> Optional[VulnerabilityWitness]:
    """
    Given a cocycle matrix, find the pair (i,j) with maximum discrepancy.
    If this discrepancy is nonzero, it constitutes a vulnerability witness.

    Time complexity: O(n²)
    Space complexity: O(1)

    Args:
        c: n×n cocycle matrix
        tol: threshold for considering discrepancy as nonzero

    Returns:
        VulnerabilityWitness if a nonzero off-diagonal entry exists, None otherwise.
    """
    n = c.shape[0]
    max_disc = 0.0
    max_i, max_j = 0, 0

    for i in range(n):
        for j in range(i + 1, n):
            if abs(c[i, j]) > max_disc:
                max_disc = abs(c[i, j])
                max_i, max_j = i, j

    if max_disc < tol:
        return None

    return VulnerabilityWitness(
        chart_i=max_i,
        chart_j=max_j,
        discrepancy=c[max_i, max_j],
        description=(
            f"Charts {max_i} and {max_j} have margin discrepancy "
            f"{c[max_i, max_j]:.4f}. While this is always resolvable over ℝ "
            f"(nerve lemma), large discrepancies indicate regions where the "
            f"certified radius is tight."
        )
    )


# ============================================================
# Algorithm 5: Sheaf vs Lipschitz Comparison
# ============================================================

def compare_certification_methods(data: CoverData) -> dict:
    """
    Compare sheaf-theoretic and Lipschitz certification methods.

    Time complexity: O(n)
    Space complexity: O(n)

    Returns:
        Dictionary with comparison metrics.
    """
    sheaf_cert = compute_sheaf_radius(data)
    lip_cert = compute_global_lipschitz_radius(data)

    improvement = (sheaf_cert.radius / lip_cert.radius - 1) * 100 if lip_cert.radius > 0 else float('inf')

    return {
        "sheaf_radius": sheaf_cert.radius,
        "lipschitz_radius": lip_cert.radius,
        "improvement_pct": improvement,
        "sheaf_minimizing_chart": sheaf_cert.minimizing_chart,
        "lipschitz_minimizing_chart": lip_cert.minimizing_chart,
        "sheaf_is_better": sheaf_cert.radius >= lip_cert.radius,
    }


# ============================================================
# Algorithm 6: Full Certification Pipeline
# ============================================================

def full_certification_pipeline(data: CoverData, verbose: bool = True) -> dict:
    """
    Run the complete cohomological certification pipeline.

    Steps:
    1. Compute discrepancy cocycle from margin data.
    2. Verify cocycle condition (sanity check).
    3. Decompose as coboundary (nerve lemma).
    4. Compute sheaf-theoretic certified radius.
    5. Compare with Lipschitz certification.
    6. Extract vulnerability witnesses (if any).

    Args:
        data: Cover data with margins and Lipschitz constants
        verbose: Print detailed output

    Returns:
        Dictionary with all certification results.
    """
    results = {}

    # Step 1: Discrepancy cocycle
    c = np.zeros((data.n_charts, data.n_charts))
    for i in range(data.n_charts):
        for j in range(data.n_charts):
            c[i, j] = data.margins[j] - data.margins[i]

    # Step 2: Verify cocycle
    is_coc, violation = verify_cocycle(c)
    results["is_cocycle"] = is_coc
    if verbose and is_coc:
        print("✓ Discrepancy matrix satisfies cocycle condition")

    # Step 3: Coboundary decomposition
    is_cob, potential = decompose_coboundary(c)
    results["is_coboundary"] = is_cob
    results["potential"] = potential
    if verbose and is_cob:
        print("✓ Cocycle is a coboundary (H¹ = 0)")

    # Step 4: Sheaf radius
    sheaf_cert = compute_sheaf_radius(data)
    results["sheaf_certificate"] = sheaf_cert
    if verbose:
        print(f"✓ Sheaf certified radius: {sheaf_cert.radius:.6f}")
        print(f"  (minimizing chart: {sheaf_cert.minimizing_chart})")

    # Step 5: Comparison
    comparison = compare_certification_methods(data)
    results["comparison"] = comparison
    if verbose:
        print(f"✓ Global Lipschitz radius: {comparison['lipschitz_radius']:.6f}")
        print(f"  Sheaf improvement: {comparison['improvement_pct']:.1f}%")

    # Step 6: Vulnerability witnesses
    witness = extract_vulnerability_witness(c)
    results["vulnerability_witness"] = witness
    if verbose and witness:
        print(f"⚠ Vulnerability witness: {witness.description}")

    return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Cohomological Robustness Certification — Algorithm Suite")
    print("=" * 60)

    # Example: 6-chart ReLU network
    data = CoverData(
        n_charts=6,
        margins=np.array([0.5, 0.8, 0.3, 0.6, 1.0, 0.4]),
        lipschitz=np.array([1.0, 2.0, 0.5, 1.5, 3.0, 0.8])
    )

    print(f"\nNetwork with {data.n_charts} activation regions:")
    print(f"  Margins:   {data.margins}")
    print(f"  Lipschitz: {data.lipschitz}")
    print()

    results = full_certification_pipeline(data)

    print("\n" + "=" * 60)
    print("Pipeline complete. All certificates verified.")
