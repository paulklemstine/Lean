#!/usr/bin/env python3
"""
Neural Sheaf Cohomology — Algorithms

Implementations of the core algorithms arising from the formal theory:
1. Cocycle verification
2. Coboundary decomposition
3. Witness family construction (the descent algorithm)
4. Global certified radius computation
5. Vulnerability detection via cohomological obstruction
"""

import numpy as np
from typing import Optional, Tuple, List, Dict
from dataclasses import dataclass


@dataclass
class RobustnessResult:
    """Result of a global robustness certification."""
    global_radius: float
    local_radii: np.ndarray
    witness_family: Optional[np.ndarray]
    is_certified: bool
    vulnerable_pairs: List[Tuple[int, int]]


@dataclass
class CohomologyResult:
    """Result of cohomological analysis of overlap data."""
    is_cocycle: bool
    is_coboundary: bool
    primitive: Optional[np.ndarray]
    obstruction_measure: float  # 0 if coboundary, positive otherwise
    triangle_defects: np.ndarray


# ============================================================
# Algorithm 1: Cocycle Verification
# ============================================================
# Time complexity: O(n³) where n = |ι|
# Space complexity: O(n²) for the defect matrix
# ============================================================

def verify_cocycle(c: np.ndarray, tol: float = 1e-10) -> Tuple[bool, np.ndarray]:
    """
    Verify the additive cocycle condition: c[i,k] = c[i,j] + c[j,k] for all i,j,k.

    Args:
        c: n×n matrix of overlap discrepancies
        tol: numerical tolerance

    Returns:
        (is_cocycle, defects) where defects[i,j,k] = c[i,k] - c[i,j] - c[j,k]

    Complexity: O(n³) time, O(n³) space for full defect tensor
    """
    n = c.shape[0]
    defects = np.zeros((n, n, n))
    max_defect = 0.0

    for i in range(n):
        for j in range(n):
            for k in range(n):
                d = c[i, k] - c[i, j] - c[j, k]
                defects[i, j, k] = d
                max_defect = max(max_defect, abs(d))

    return max_defect < tol, defects


# ============================================================
# Algorithm 2: Coboundary Decomposition
# ============================================================
# Time complexity: O(n²)
# Space complexity: O(n)
# ============================================================

def decompose_coboundary(c: np.ndarray, tol: float = 1e-10) -> CohomologyResult:
    """
    Attempt to decompose c as a coboundary: find b such that c[i,j] = b[j] - b[i].

    For a cocycle, the canonical choice is b[j] = c[0, j] (fixing b[0] = 0).
    This works because the cocycle condition forces consistency.

    Args:
        c: n×n matrix of overlap discrepancies
        tol: numerical tolerance

    Returns:
        CohomologyResult with decomposition data

    Complexity: O(n²) time after cocycle verification
    """
    n = c.shape[0]

    # First check cocycle condition
    is_cyc, defect_tensor = verify_cocycle(c, tol)

    # Compute triangle defects for diagnostics
    triangle_defects = np.zeros((n, n, n))
    for i in range(n):
        for j in range(n):
            for k in range(n):
                triangle_defects[i, j, k] = c[i, k] - c[i, j] - c[j, k]

    if not is_cyc:
        obstruction = np.max(np.abs(defect_tensor))
        return CohomologyResult(
            is_cocycle=False,
            is_coboundary=False,
            primitive=None,
            obstruction_measure=obstruction,
            triangle_defects=triangle_defects
        )

    # Attempt coboundary decomposition: b[j] = c[0, j]
    b = c[0, :].copy()

    # Verify: c[i,j] should equal b[j] - b[i]
    max_err = 0.0
    for i in range(n):
        for j in range(n):
            err = abs(c[i, j] - (b[j] - b[i]))
            max_err = max(max_err, err)

    is_cob = max_err < tol

    return CohomologyResult(
        is_cocycle=True,
        is_coboundary=is_cob,
        primitive=b if is_cob else None,
        obstruction_measure=max_err,
        triangle_defects=triangle_defects
    )


# ============================================================
# Algorithm 3: Witness Family Construction (Descent Algorithm)
# ============================================================
# Time complexity: O(n²)
# Space complexity: O(n)
# ============================================================

def construct_witness_family(
    m: np.ndarray,
    L: np.ndarray,
    b: np.ndarray,
    verify: bool = True
) -> Tuple[np.ndarray, bool, str]:
    """
    Construct the adjusted witness family from coboundary primitive b.

    This implements the key construction from the formal proof:
    w[i] = b[i] - min(b)

    The proof in Lean shows:
    1. w[i] ≥ 0 (since b[i] ≥ min(b))
    2. w[i] ≤ m[i]/L[i] (from the smallness condition |c[i,j]| ≤ m[i]/L[i])
    3. w[j] - w[i] = b[j] - b[i] = c[i,j] (compatibility)

    Args:
        m: margin values per region
        L: Lipschitz constants per region
        b: coboundary primitive (gauge function)
        verify: whether to verify the construction

    Returns:
        (witness_family, is_valid, message)

    Complexity: O(n) for construction, O(n²) for verification
    """
    n = len(m)
    b_min = np.min(b)
    w = b - b_min

    if not verify:
        return w, True, "Construction completed (unverified)"

    # Check nonnegativity
    if np.any(w < -1e-10):
        return w, False, "Nonnegativity violated"

    # Check upper bounds
    radii = m / L
    violations = []
    for i in range(n):
        if w[i] > radii[i] + 1e-10:
            violations.append(i)

    if violations:
        return w, False, f"Upper bound violated at regions {violations}"

    return w, True, "Valid witness family constructed"


# ============================================================
# Algorithm 4: Global Certified Radius
# ============================================================
# Time complexity: O(n)
# Space complexity: O(1)
# ============================================================

def compute_global_radius(m: np.ndarray, L: np.ndarray) -> float:
    """
    Compute the global certified L∞ robustness radius.

    ε = min_i (m[i] / L[i])

    This is the finite minimization step from the descent theorem.

    Args:
        m: margin values per region
        L: Lipschitz constants per region

    Returns:
        Global certified radius ε ≥ 0

    Complexity: O(n) time, O(1) space
    """
    assert np.all(L > 0), "All Lipschitz constants must be positive"
    assert np.all(m >= 0), "All margins must be nonneg"
    return float(np.min(m / L))


# ============================================================
# Algorithm 5: Full Cohomological Robustness Certification
# ============================================================
# Time complexity: O(n³) dominated by cocycle verification
# Space complexity: O(n²)
# ============================================================

def certify_robustness(
    m: np.ndarray,
    L: np.ndarray,
    c: np.ndarray
) -> RobustnessResult:
    """
    Full cohomological robustness certification pipeline.

    Steps:
    1. Verify cocycle condition on overlap data c
    2. Attempt coboundary decomposition
    3. Construct compatible witness family
    4. Extract global certified radius

    This implements the full sheaf_descent_theorem from the Lean formalization.

    Args:
        m: margin values per region (n,)
        L: Lipschitz constants per region (n,)
        c: overlap discrepancy matrix (n, n)

    Returns:
        RobustnessResult with certification data

    Complexity: O(n³) time, O(n²) space
    """
    n = len(m)
    local_radii = m / L

    # Step 1-2: Cohomological analysis
    cohom = decompose_coboundary(c)

    # Detect vulnerable pairs
    vulnerable_pairs = []
    for i in range(n):
        for j in range(n):
            if abs(c[i, j]) > local_radii[i]:
                vulnerable_pairs.append((i, j))

    if not cohom.is_coboundary:
        return RobustnessResult(
            global_radius=0.0,
            local_radii=local_radii,
            witness_family=None,
            is_certified=False,
            vulnerable_pairs=vulnerable_pairs
        )

    # Step 3: Construct witness family
    b = cohom.primitive
    w, is_valid, msg = construct_witness_family(m, L, b)

    # Step 4: Global radius
    eps = compute_global_radius(m, L) if is_valid else 0.0

    return RobustnessResult(
        global_radius=eps,
        local_radii=local_radii,
        witness_family=w if is_valid else None,
        is_certified=is_valid,
        vulnerable_pairs=vulnerable_pairs
    )


# ============================================================
# Algorithm 6: Vulnerability Detection
# ============================================================
# Time complexity: O(n²)
# Space complexity: O(1)
# ============================================================

def detect_vulnerabilities(
    m: np.ndarray,
    L: np.ndarray,
    c: np.ndarray
) -> Dict:
    """
    Detect adversarial vulnerabilities via cohomological analysis.

    Implements both:
    - overlap_inconsistency_yields_small_radius
    - no_compatible_witnesses_of_non_coboundary

    Args:
        m: margin values
        L: Lipschitz constants
        c: overlap discrepancy matrix

    Returns:
        Dictionary with vulnerability analysis
    """
    n = len(m)
    local_radii = m / L

    # Check for direct overlap inconsistencies
    inconsistent_pairs = []
    for i in range(n):
        for j in range(n):
            if abs(c[i, j]) > local_radii[i]:
                inconsistent_pairs.append({
                    "regions": (i, j),
                    "discrepancy": abs(c[i, j]),
                    "margin_budget": local_radii[i],
                    "excess": abs(c[i, j]) - local_radii[i]
                })

    # Cohomological analysis
    cohom = decompose_coboundary(c)

    return {
        "is_cocycle": cohom.is_cocycle,
        "is_coboundary": cohom.is_coboundary,
        "obstruction_measure": cohom.obstruction_measure,
        "inconsistent_pairs": inconsistent_pairs,
        "num_vulnerabilities": len(inconsistent_pairs),
        "cohomological_obstruction": not cohom.is_coboundary,
        "verdict": (
            "CERTIFIED SAFE" if cohom.is_coboundary and len(inconsistent_pairs) == 0
            else "VULNERABLE" if len(inconsistent_pairs) > 0
            else "OBSTRUCTED" if not cohom.is_coboundary
            else "UNCERTAIN"
        )
    }


if __name__ == "__main__":
    print("Neural Sheaf Cohomology — Algorithm Demonstrations\n")

    # Example: 4-region classifier
    m = np.array([2.0, 1.5, 3.0, 1.0])
    L = np.array([1.0, 0.5, 2.0, 0.25])

    # Coboundary cocycle
    b = np.array([0.1, -0.05, 0.15, 0.0])
    c = np.outer(np.ones(4), b) - np.outer(b, np.ones(4))

    print("Certifying robustness with coboundary cocycle...")
    result = certify_robustness(m, L, c)
    print(f"  Certified: {result.is_certified}")
    print(f"  Global radius: {result.global_radius}")
    print(f"  Vulnerable pairs: {result.vulnerable_pairs}")

    print("\nVulnerability detection...")
    vuln = detect_vulnerabilities(m, L, c)
    print(f"  Verdict: {vuln['verdict']}")
    print(f"  Obstruction measure: {vuln['obstruction_measure']:.6f}")
