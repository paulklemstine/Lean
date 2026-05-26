"""
Applications of Lorentzian Recognition Complexity Theory

Demonstrates practical applications of the theoretical results:
1. Estimating recognition difficulty for given polynomial parameters
2. SAT-to-branch-obstruction pipeline
3. Hessian signature analysis for optimization
4. Certificate size prediction for polynomial families
"""

import numpy as np
from math import comb, log2, factorial
from itertools import product
from typing import List, Tuple, Dict, Optional


def multiindex_count(n: int, d: int) -> int:
    """C(n+d-1, d) = number of multiindices of weight d in n variables."""
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def quadratic_leaf_count(n: int, d: int) -> int:
    """Number of quadratic leaves in Lorentzian recognition tree."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


# ============================================================
# Application 1: Recognition Difficulty Estimator
# ============================================================
def recognition_difficulty(n: int, d: int) -> Dict:
    """
    Estimate the computational difficulty of Lorentzian recognition
    for a polynomial with given parameters.

    Args:
        n: Number of variables
        d: Degree of the polynomial

    Returns:
        Dict with difficulty metrics

    Example:
        >>> recognition_difficulty(10, 5)
        {'n': 10, 'd': 5, 'leaf_count': 220, ...}
    """
    leaves = quadratic_leaf_count(n, d)
    lower = 2 ** (d - 2) if n > d - 2 and d >= 2 else 1
    upper = n ** (d - 2) if d >= 2 else 1

    # Each leaf requires O(n^3) eigenvalue computation
    total_ops_estimate = leaves * n ** 3

    # Classify difficulty
    if d < 2:
        regime = "trivial"
    elif d <= 5:
        regime = "polynomial (fixed degree)"
    elif leaves < 10 ** 6:
        regime = "feasible"
    elif leaves < 10 ** 12:
        regime = "challenging"
    else:
        regime = "intractable"

    return {
        'n': n,
        'd': d,
        'leaf_count': leaves,
        'lower_bound': lower,
        'upper_bound': upper,
        'ops_estimate': total_ops_estimate,
        'log2_leaves': log2(leaves) if leaves > 0 else 0,
        'regime': regime,
    }


# ============================================================
# Application 2: SAT-to-Branch Pipeline
# ============================================================
def sat_to_branch_analysis(n_vars: int, clauses: List[List[Tuple[int, bool]]]) -> Dict:
    """
    Analyze a CNF formula through the lens of branch obstruction.

    For each assignment, finds conflicted clauses and reports statistics
    relevant to the SAT-Lorentzian correspondence.

    Args:
        n_vars: Number of variables
        clauses: CNF clauses

    Returns:
        Dict with branch analysis results
    """
    total_assignments = 2 ** n_vars
    n_obstructed = 0  # assignments with ≥1 conflicted clause
    conflict_histogram = {}  # number of conflicts → count

    for assignment in product([False, True], repeat=n_vars):
        n_conflicts = 0
        for clause in clauses:
            if all(assignment[v] != p for v, p in clause):
                n_conflicts += 1
        if n_conflicts > 0:
            n_obstructed += 1
        conflict_histogram[n_conflicts] = conflict_histogram.get(n_conflicts, 0) + 1

    is_unsat = (n_obstructed == total_assignments)

    return {
        'n_vars': n_vars,
        'n_clauses': len(clauses),
        'total_assignments': total_assignments,
        'obstructed_assignments': n_obstructed,
        'is_unsatisfiable': is_unsat,
        'obstruction_fraction': n_obstructed / total_assignments,
        'conflict_histogram': dict(sorted(conflict_histogram.items())),
    }


# ============================================================
# Application 3: Spectral Obstruction Detector
# ============================================================
def detect_spectral_obstruction(matrix: np.ndarray) -> Dict:
    """
    Analyze a symmetric matrix for Lorentzian signature properties.

    Reports eigenvalue structure, Lorentzian status, and if not Lorentzian,
    provides witness vectors forming a positive-definite subspace.

    Args:
        matrix: Symmetric matrix

    Returns:
        Dict with spectral analysis
    """
    n = matrix.shape[0]
    H = (matrix + matrix.T) / 2  # symmetrize
    eigenvalues, eigenvectors = np.linalg.eigh(H)

    pos_indices = np.where(eigenvalues > 1e-10)[0]
    n_positive = len(pos_indices)
    is_lorentzian = n_positive <= 1

    result = {
        'dimension': n,
        'eigenvalues': eigenvalues.tolist(),
        'n_positive': n_positive,
        'n_negative': int(np.sum(eigenvalues < -1e-10)),
        'n_zero': n - n_positive - int(np.sum(eigenvalues < -1e-10)),
        'is_lorentzian': is_lorentzian,
    }

    if not is_lorentzian and n_positive >= 2:
        # Provide two positive directions as obstruction witness
        v1 = eigenvectors[:, pos_indices[0]]
        v2 = eigenvectors[:, pos_indices[1]]
        result['obstruction_vectors'] = (v1.tolist(), v2.tolist())
        result['quadform_v1'] = float(v1 @ H @ v1)
        result['quadform_v2'] = float(v2 @ H @ v2)

    return result


# ============================================================
# Application 4: Certificate Size Prediction
# ============================================================
def certificate_size_analysis(n_range: range, d_modes: List[str]) -> List[Dict]:
    """
    Predict certificate sizes for different polynomial families.

    Modes:
    - "fixed_3": degree 3 (linear growth)
    - "fixed_5": degree 5 (polynomial growth)
    - "linear": degree = n (exponential growth)
    - "quadratic": degree = n^2 (super-exponential)

    Args:
        n_range: Range of variable counts
        d_modes: List of degree growth modes

    Returns:
        List of prediction records
    """
    results = []
    for n in n_range:
        for mode in d_modes:
            if mode == "fixed_3":
                d = 3
            elif mode == "fixed_5":
                d = 5
            elif mode == "linear":
                d = n
            elif mode == "quadratic":
                d = min(n * n, 30)  # cap for computation
            else:
                continue

            leaves = quadratic_leaf_count(n, d)
            results.append({
                'n': n,
                'd': d,
                'mode': mode,
                'leaves': leaves,
                'log2_leaves': log2(leaves) if leaves > 0 else 0,
            })
    return results


# ============================================================
# Main: Run all applications
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Applications of Lorentzian Recognition Complexity")
    print("=" * 60)

    # App 1: Difficulty estimation
    print("\n--- Recognition Difficulty Estimator ---")
    test_cases = [(5, 3), (10, 5), (20, 10), (50, 50), (100, 4)]
    for n, d in test_cases:
        r = recognition_difficulty(n, d)
        print(f"  n={r['n']:3d}, d={r['d']:3d}: "
              f"leaves={r['leaf_count']:>12}, "
              f"log₂={r['log2_leaves']:6.1f}, "
              f"regime='{r['regime']}'")

    # App 2: SAT analysis
    print("\n--- SAT-to-Branch Pipeline ---")
    formulas = [
        ("x∧¬x", 1, [[(0, True)], [(0, False)]]),
        ("(x₀∨x₁)∧(¬x₀∨x₁)∧(x₀∨¬x₁)∧(¬x₀∨¬x₁)", 2, [
            [(0, True), (1, True)], [(0, False), (1, True)],
            [(0, True), (1, False)], [(0, False), (1, False)],
        ]),
        ("(x₀∨x₁)∧(¬x₀∨x₂)", 3, [
            [(0, True), (1, True)], [(0, False), (2, True)],
        ]),
    ]
    for name, nv, cl in formulas:
        r = sat_to_branch_analysis(nv, cl)
        print(f"  {name}: UNSAT={r['is_unsatisfiable']}, "
              f"obstruction={r['obstruction_fraction']:.1%}, "
              f"conflicts={r['conflict_histogram']}")

    # App 3: Spectral analysis
    print("\n--- Spectral Obstruction Detection ---")
    matrices = [
        ("Lorentzian", np.diag([1., -1., -1.])),
        ("Pos. definite", np.eye(3)),
        ("2 positive", np.diag([2., 1., -3.])),
    ]
    for name, A in matrices:
        r = detect_spectral_obstruction(A)
        print(f"  {name}: Lor={r['is_lorentzian']}, "
              f"eigs={[f'{e:.1f}' for e in r['eigenvalues']]}, "
              f"pos={r['n_positive']}")

    # App 4: Certificate predictions
    print("\n--- Certificate Size Predictions ---")
    results = certificate_size_analysis(range(3, 11), ["fixed_3", "linear"])
    for r in results:
        print(f"  n={r['n']:2d}, mode={r['mode']:>8s}, d={r['d']:3d}: "
              f"leaves={r['leaves']:>10}, log₂={r['log2_leaves']:6.1f}")
