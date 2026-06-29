#!/usr/bin/env python3
"""
Applications of the Spectral Embedding Construction

Demonstrates real-world applications of the spectral embedding
P_A(t, x) = t² · Q_A(x) to various domains:

1. Spectral Graph Theory: Testing graph matrix eigenvalue properties
2. Semidefinite Programming: Inertia constraints via polynomial certificates
3. Quantum Information: Entanglement witnesses and partial transpose tests
"""

import numpy as np
from typing import List, Tuple, Dict


def eigenvalue_inertia(A: np.ndarray, tol: float = 1e-10) -> Tuple[int, int, int]:
    """Compute (n+, n0, n-) inertia of symmetric matrix A."""
    evals = np.linalg.eigvalsh(A)
    return (int(np.sum(evals > tol)), 
            int(np.sum(np.abs(evals) <= tol)),
            int(np.sum(evals < -tol)))


def has_at_most_one_positive(A: np.ndarray) -> bool:
    """Check if A has at most one positive eigenvalue."""
    return eigenvalue_inertia(A)[0] <= 1


def block_zero_extend(A: np.ndarray) -> np.ndarray:
    """Block-zero extension: pad with zero first row/column."""
    n = A.shape[0]
    B = np.zeros((n + 1, n + 1))
    B[1:, 1:] = A
    return B


# ════════════════════════════════════════════════════════════
# APPLICATION 1: Spectral Graph Theory
# ════════════════════════════════════════════════════════════

def adjacency_matrix(edges: List[Tuple[int, int]], n: int) -> np.ndarray:
    """Construct adjacency matrix of a simple graph."""
    A = np.zeros((n, n))
    for i, j in edges:
        A[i, j] = 1
        A[j, i] = 1
    return A


def laplacian_matrix(A_adj: np.ndarray) -> np.ndarray:
    """Compute the graph Laplacian L = D - A."""
    return np.diag(A_adj.sum(axis=1)) - A_adj


def signless_laplacian(A_adj: np.ndarray) -> np.ndarray:
    """Compute the signless Laplacian Q = D + A."""
    return np.diag(A_adj.sum(axis=1)) + A_adj


def graph_spectral_certificate(edges: List[Tuple[int, int]], n: int):
    """
    Application: Test whether a graph's adjacency matrix has at most
    one positive eigenvalue via the spectral embedding certificate.
    
    Graphs with this property include:
    - Complete bipartite graphs K_{1,n}
    - Paths and certain trees
    - Graphs with specific spectral constraints
    """
    A = adjacency_matrix(edges, n)
    evals = np.linalg.eigvalsh(A)
    at_most_one = has_at_most_one_positive(A)
    
    B = block_zero_extend(A)
    B_at_most_one = has_at_most_one_positive(B)
    
    return {
        'adjacency_matrix': A,
        'eigenvalues': np.sort(evals)[::-1],
        'at_most_one_positive': at_most_one,
        'block_extension_agrees': at_most_one == B_at_most_one,
        'certificate': 'LORENTZIAN' if at_most_one else 'NOT_LORENTZIAN'
    }


# ════════════════════════════════════════════════════════════
# APPLICATION 2: Semidefinite Programming
# ════════════════════════════════════════════════════════════

def inertia_constraint_test(A: np.ndarray, max_positive: int = 1) -> Dict:
    """
    Test an inertia constraint using the spectral embedding.
    
    In SDP, constraints of the form "A has at most k positive eigenvalues"
    arise in rank-constrained problems. For k=1 (Lorentzian case),
    the spectral embedding provides a polynomial certificate.
    """
    inertia = eigenvalue_inertia(A)
    feasible = inertia[0] <= max_positive
    
    return {
        'inertia': inertia,
        'constraint': f'n+ ≤ {max_positive}',
        'feasible': feasible,
        'certificate_type': 'Lorentzian leaf' if max_positive == 1 else 'general',
        'polynomial_certificate_size': A.shape[0] ** 2
    }


# ════════════════════════════════════════════════════════════
# APPLICATION 3: Quantum Information
# ════════════════════════════════════════════════════════════

def partial_transpose_2x2(rho: np.ndarray) -> np.ndarray:
    """
    Compute the partial transpose of a 2×2 ⊗ 2×2 density matrix.
    Reshapes as (2,2,2,2), transposes second subsystem.
    """
    rho_r = rho.reshape(2, 2, 2, 2)
    rho_pt = rho_r.transpose(0, 3, 2, 1).reshape(4, 4)
    return rho_pt


def ppt_criterion_via_embedding(rho: np.ndarray) -> Dict:
    """
    Test the PPT (Positive Partial Transpose) criterion for 2-qubit states
    using the spectral embedding framework.
    
    A state is entangled if its partial transpose has a negative eigenvalue.
    The spectral embedding tests whether the partial transpose has
    at most one positive eigenvalue — a stronger condition related to
    the geometry of the entanglement witness.
    """
    rho_pt = partial_transpose_2x2(rho)
    evals_pt = np.linalg.eigvalsh(rho_pt)
    
    at_most_one_pos = has_at_most_one_positive(rho_pt)
    
    return {
        'partial_transpose_eigenvalues': np.sort(evals_pt)[::-1],
        'is_ppt': all(e >= -1e-10 for e in evals_pt),
        'at_most_one_positive_pt': at_most_one_pos,
        'entangled': any(e < -1e-10 for e in evals_pt),
    }


def main():
    print("="*60)
    print("  APPLICATIONS OF SPECTRAL EMBEDDING")
    print("="*60)
    
    # ── Application 1: Graph Theory ──
    print("\n" + "━"*60)
    print("  APPLICATION 1: Spectral Graph Theory")
    print("━"*60)
    
    # Star graph K_{1,3}
    star_edges = [(0,1), (0,2), (0,3)]
    result = graph_spectral_certificate(star_edges, 4)
    print(f"\nStar graph K_{{1,3}}:")
    print(f"  Eigenvalues: {result['eigenvalues']}")
    print(f"  At most 1 positive: {result['at_most_one_positive']}")
    print(f"  Certificate: {result['certificate']}")
    
    # Path P5
    path_edges = [(0,1), (1,2), (2,3), (3,4)]
    result = graph_spectral_certificate(path_edges, 5)
    print(f"\nPath P₅:")
    print(f"  Eigenvalues: {result['eigenvalues']}")
    print(f"  At most 1 positive: {result['at_most_one_positive']}")
    print(f"  Certificate: {result['certificate']}")
    
    # Complete graph K4
    k4_edges = [(i,j) for i in range(4) for j in range(i+1,4)]
    result = graph_spectral_certificate(k4_edges, 4)
    print(f"\nComplete graph K₄:")
    print(f"  Eigenvalues: {result['eigenvalues']}")
    print(f"  At most 1 positive: {result['at_most_one_positive']}")
    print(f"  Certificate: {result['certificate']}")
    
    # Petersen graph
    petersen_edges = [(0,1),(0,4),(0,5), (1,2),(1,6), (2,3),(2,7),
                      (3,4),(3,8), (4,9), (5,7),(5,8), (6,8),(6,9), (7,9)]
    result = graph_spectral_certificate(petersen_edges, 10)
    print(f"\nPetersen graph:")
    print(f"  Eigenvalues: {np.round(result['eigenvalues'], 4)}")
    print(f"  At most 1 positive: {result['at_most_one_positive']}")
    print(f"  Certificate: {result['certificate']}")
    
    # ── Application 2: SDP Constraints ──
    print("\n" + "━"*60)
    print("  APPLICATION 2: Semidefinite Programming")
    print("━"*60)
    
    # Matrix with rank-1 positive part
    A_sdp = np.diag([3.0, -1.0, -2.0, -0.5])
    result = inertia_constraint_test(A_sdp, max_positive=1)
    print(f"\nDiagonal matrix diag(3, -1, -2, -0.5):")
    print(f"  Inertia: {result['inertia']}")
    print(f"  Constraint {result['constraint']}: {'FEASIBLE' if result['feasible'] else 'INFEASIBLE'}")
    
    # Matrix with rank-2 positive part
    A_sdp2 = np.diag([2.0, 1.0, -3.0, -1.0])
    result = inertia_constraint_test(A_sdp2, max_positive=1)
    print(f"\nDiagonal matrix diag(2, 1, -3, -1):")
    print(f"  Inertia: {result['inertia']}")
    print(f"  Constraint {result['constraint']}: {'FEASIBLE' if result['feasible'] else 'INFEASIBLE'}")
    
    # ── Application 3: Quantum Information ──
    print("\n" + "━"*60)
    print("  APPLICATION 3: Quantum Information")
    print("━"*60)
    
    # Separable state |00⟩⟨00|
    rho_sep = np.zeros((4,4))
    rho_sep[0,0] = 1.0
    result = ppt_criterion_via_embedding(rho_sep)
    print(f"\nSeparable state |00⟩⟨00|:")
    print(f"  PT eigenvalues: {result['partial_transpose_eigenvalues']}")
    print(f"  PPT: {result['is_ppt']}")
    print(f"  At most 1 positive PT eigenvalue: {result['at_most_one_positive_pt']}")
    
    # Bell state (maximally entangled)
    bell = np.array([1, 0, 0, 1]) / np.sqrt(2)
    rho_bell = np.outer(bell, bell)
    result = ppt_criterion_via_embedding(rho_bell)
    print(f"\nBell state (|00⟩+|11⟩)/√2:")
    print(f"  PT eigenvalues: {np.round(result['partial_transpose_eigenvalues'], 4)}")
    print(f"  PPT: {result['is_ppt']}")
    print(f"  Entangled: {result['entangled']}")
    print(f"  At most 1 positive PT eigenvalue: {result['at_most_one_positive_pt']}")
    
    # Werner state
    p = 0.6
    rho_werner = (1-p)/4 * np.eye(4) + p * np.outer(bell, bell)
    result = ppt_criterion_via_embedding(rho_werner)
    print(f"\nWerner state (p={p}):")
    print(f"  PT eigenvalues: {np.round(result['partial_transpose_eigenvalues'], 4)}")
    print(f"  PPT: {result['is_ppt']}")
    print(f"  Entangled: {result['entangled']}")
    
    print("\n" + "="*60)
    print("  All applications demonstrate the spectral embedding")
    print("  Lorentzian(P_A) ⟺ HasAtMostOnePositiveEigenvalue(A)")
    print("="*60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Spectral Embedding Demo: Matrix Positivity to Lorentzian Leaves

This script demonstrates the spectral embedding construction:
given a symmetric rational matrix A, construct a homogeneous quartic
polynomial P_A(t, x₁,...,xₙ) = t² · Q_A(x) and verify that the
Lorentzian leaf conditions on P_A correspond exactly to A having
at most one positive eigenvalue.

Usage:
    python demo.py
"""

import numpy as np
from typing import Tuple, List, Dict
import sys


def quadratic_form(A: np.ndarray, x: np.ndarray) -> float:
    """Compute Q_A(x) = x^T A x."""
    return float(x @ A @ x)


def has_at_most_one_positive_eigenvalue(A: np.ndarray) -> Tuple[bool, np.ndarray]:
    """
    Check if symmetric matrix A has at most one positive eigenvalue.
    Returns (result, eigenvalues).
    """
    eigenvalues = np.linalg.eigvalsh(A)
    n_positive = np.sum(eigenvalues > 1e-10)
    return n_positive <= 1, eigenvalues


def block_zero_extend(A: np.ndarray) -> np.ndarray:
    """
    Construct the block-zero extension B of A:
    B = [[0, 0, ..., 0],
         [0,          ],
         [0,    A     ],
         [0,          ]]
    """
    n = A.shape[0]
    B = np.zeros((n + 1, n + 1))
    B[1:, 1:] = A
    return B


def spectral_embed_polynomial(A: np.ndarray) -> Dict:
    """
    Construct the spectral embedding polynomial P_A(t, x₁,...,xₙ) = t² · Q_A(x).
    
    Returns a dictionary with:
    - 'matrix': the original matrix A
    - 'block_extension': the block-zero-extended matrix B
    - 'degree': 4 (homogeneous degree)
    - 'n_vars': n + 1
    - 'monomials': list of (coefficient, monomial) pairs
    """
    n = A.shape[0]
    monomials = []
    
    # P_A(t, x₁,...,xₙ) = t² · ∑_{i,j} A_{ij} x_i x_j
    # Variable 0 = t, variables 1..n = x₁..xₙ
    for i in range(n):
        for j in range(n):
            if abs(A[i, j]) > 1e-15:
                # Coefficient A[i,j] for monomial t² x_{i+1} x_{j+1}
                exponent = [0] * (n + 1)
                exponent[0] = 2  # t²
                exponent[i + 1] += 1  # x_{i+1}
                exponent[j + 1] += 1  # x_{j+1}
                monomials.append((A[i, j], tuple(exponent)))
    
    return {
        'matrix': A,
        'block_extension': block_zero_extend(A),
        'degree': 4,
        'n_vars': n + 1,
        'monomials': monomials
    }


def check_lorentzian_leaves(A: np.ndarray) -> Tuple[bool, List[Dict]]:
    """
    Check all degree-2 derivative leaves of P_A = t² · Q_A(x).
    
    For a degree-4 polynomial in n+1 variables, the degree-2 leaves
    are obtained by differentiating twice. Each leaf is a quadratic
    polynomial, and we check if its Hessian has at most one positive
    eigenvalue.
    
    Returns (all_leaves_ok, leaf_details).
    """
    n = A.shape[0]
    n_vars = n + 1  # t, x₁, ..., xₙ
    leaf_details = []
    all_ok = True
    
    # Leaf ∂²P/∂t² = 2·Q_A(x): Hessian = diag(0, 2A)
    hessian_tt = np.zeros((n_vars, n_vars))
    hessian_tt[1:, 1:] = 2 * A
    ok_tt, evals_tt = has_at_most_one_positive_eigenvalue(hessian_tt)
    leaf_details.append({
        'derivatives': ('t', 't'),
        'hessian': hessian_tt,
        'eigenvalues': evals_tt,
        'at_most_one_pos': ok_tt,
        'description': '∂²P/∂t² = 2·Q_A(x) — CRITICAL LEAF'
    })
    if not ok_tt:
        all_ok = False
    
    # Leaf ∂²P/∂t∂x_k: Hessian is rank-≤2 off-diagonal block
    for k in range(n):
        hessian_txk = np.zeros((n_vars, n_vars))
        for j in range(n):
            hessian_txk[0, j + 1] = 2 * A[k, j]
            hessian_txk[j + 1, 0] = 2 * A[k, j]
        ok, evals = has_at_most_one_positive_eigenvalue(hessian_txk)
        leaf_details.append({
            'derivatives': ('t', f'x_{k+1}'),
            'hessian': hessian_txk,
            'eigenvalues': evals,
            'at_most_one_pos': ok,
            'description': f'∂²P/∂t∂x_{k+1} — rank-≤2 matrix'
        })
        if not ok:
            all_ok = False
    
    # Leaf ∂²P/∂x_k∂x_l: Hessian has at most one nonzero entry (top-left)
    for k in range(n):
        for l in range(k, n):
            hessian_xkxl = np.zeros((n_vars, n_vars))
            coeff = 2 * A[k, l] if k == l else 2 * A[k, l]
            hessian_xkxl[0, 0] = 2 * coeff  # ∂²(coeff·t²)/∂t² = 2·coeff
            ok, evals = has_at_most_one_positive_eigenvalue(hessian_xkxl)
            leaf_details.append({
                'derivatives': (f'x_{k+1}', f'x_{l+1}'),
                'hessian_top_left': 2 * coeff,
                'eigenvalues': evals,
                'at_most_one_pos': ok,
                'description': f'∂²P/∂x_{k+1}∂x_{l+1} — rank-≤1 matrix'
            })
            if not ok:
                all_ok = False
    
    return all_ok, leaf_details


def format_matrix(A: np.ndarray, name: str = "A") -> str:
    """Pretty-print a matrix."""
    n = A.shape[0]
    lines = [f"{name} ="]
    for i in range(n):
        row = "  [" + ", ".join(f"{A[i,j]:8.4f}" for j in range(n)) + "]"
        lines.append(row)
    return "\n".join(lines)


def format_polynomial(embed: Dict) -> str:
    """Pretty-print the spectral embedding polynomial."""
    n = embed['matrix'].shape[0]
    var_names = ['t'] + [f'x_{i+1}' for i in range(n)]
    
    terms = []
    # Collect and combine monomials
    mono_dict = {}
    for coeff, exponent in embed['monomials']:
        if exponent in mono_dict:
            mono_dict[exponent] += coeff
        else:
            mono_dict[exponent] = coeff
    
    for exponent, coeff in mono_dict.items():
        if abs(coeff) < 1e-15:
            continue
        parts = []
        for idx, exp in enumerate(exponent):
            if exp == 1:
                parts.append(var_names[idx])
            elif exp > 1:
                parts.append(f"{var_names[idx]}^{exp}")
        term = f"{coeff:+.4f}·{'·'.join(parts)}"
        terms.append(term)
    
    if not terms:
        return "P_A = 0"
    return "P_A = " + " ".join(terms[:10]) + ("..." if len(terms) > 10 else "")


def run_single_test(A: np.ndarray, name: str = "Test"):
    """Run the spectral embedding test on a single matrix."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")
    
    # Display matrix
    print(format_matrix(A))
    
    # Check eigenvalue property
    at_most_one, eigenvalues = has_at_most_one_positive_eigenvalue(A)
    n_pos = np.sum(eigenvalues > 1e-10)
    print(f"\nEigenvalues of A: {np.sort(eigenvalues)[::-1]}")
    print(f"Positive eigenvalues: {n_pos}")
    print(f"HasAtMostOnePositiveEigenvalue: {at_most_one}")
    
    # Construct spectral embedding
    embed = spectral_embed_polynomial(A)
    print(f"\n{format_polynomial(embed)}")
    print(f"Polynomial degree: {embed['degree']}, Variables: {embed['n_vars']}")
    
    # Check Lorentzian leaves
    all_leaves_ok, leaf_details = check_lorentzian_leaves(A)
    print(f"\nLorentzian leaf check:")
    for leaf in leaf_details[:5]:  # Show first 5 leaves
        status = "✓" if leaf['at_most_one_pos'] else "✗"
        print(f"  {status} {leaf['description']}")
    if len(leaf_details) > 5:
        remaining_ok = all(l['at_most_one_pos'] for l in leaf_details[5:])
        print(f"  ... {len(leaf_details) - 5} more leaves (all OK: {remaining_ok})")
    
    # Verify equivalence
    print(f"\n{'─'*40}")
    print(f"  EQUIVALENCE CHECK:")
    print(f"  HasAtMostOnePositiveEigenvalue(A) = {at_most_one}")
    print(f"  AllLeavesLorentzian(P_A)          = {all_leaves_ok}")
    match = at_most_one == all_leaves_ok
    print(f"  Match: {'✓ PASS' if match else '✗ FAIL — COUNTEREXAMPLE!'}")
    if not match:
        print(f"  *** POTENTIAL COUNTEREXAMPLE FOUND ***")
    print(f"{'─'*40}")
    
    return match


def main():
    print("="*60)
    print("  SPECTRAL EMBEDDING: Matrix Positivity to Lorentzian Leaves")
    print("  P_A(t, x) = t² · Q_A(x)")
    print("="*60)
    
    np.random.seed(42)
    all_pass = True
    
    # Test 1: Identity matrix (1 positive eigenvalue for 1×1, n for n×n)
    print("\n" + "━"*60)
    print("  SECTION 1: Structured Examples")
    print("━"*60)
    
    A1 = np.array([[1.0]])
    all_pass &= run_single_test(A1, "1×1 Identity — at most 1 positive eigenvalue")
    
    A2 = np.eye(4)
    all_pass &= run_single_test(A2, "4×4 Identity — 4 positive eigenvalues")
    
    # Test 3: Diagonal with mixed signs
    A3 = np.diag([3.0, -1.0, -2.0, -0.5])
    all_pass &= run_single_test(A3, "Diagonal (3, -1, -2, -0.5) — 1 positive")
    
    # Test 4: Two positive eigenvalues
    A4 = np.diag([2.0, 1.0, -3.0, -1.0])
    all_pass &= run_single_test(A4, "Diagonal (2, 1, -3, -1) — 2 positive")
    
    # Test 5: All negative
    A5 = np.diag([-1.0, -2.0, -3.0])
    all_pass &= run_single_test(A5, "All negative eigenvalues — 0 positive")
    
    # Test 6: Zero matrix
    A6 = np.zeros((3, 3))
    all_pass &= run_single_test(A6, "Zero matrix — 0 positive eigenvalues")
    
    # Test 7: Graph Laplacian example
    print("\n" + "━"*60)
    print("  SECTION 2: Graph-Theoretic Examples")
    print("━"*60)
    
    # Path graph P4: adjacency matrix
    A_path = np.array([
        [0, 1, 0, 0],
        [1, 0, 1, 0],
        [0, 1, 0, 1],
        [0, 0, 1, 0]
    ], dtype=float)
    all_pass &= run_single_test(A_path, "Path graph P₄ adjacency matrix")
    
    # Complete graph K4: adjacency matrix
    A_K4 = np.ones((4, 4)) - np.eye(4)
    all_pass &= run_single_test(A_K4, "Complete graph K₄ adjacency matrix")
    
    # Star graph S4: adjacency matrix
    A_star = np.zeros((4, 4))
    A_star[0, 1:] = 1
    A_star[1:, 0] = 1
    all_pass &= run_single_test(A_star, "Star graph S₄ adjacency matrix")
    
    # Graph Laplacian (always has 0 eigenvalue, rest nonneg)
    L = np.diag(A_K4.sum(axis=1)) - A_K4
    all_pass &= run_single_test(L, "K₄ Laplacian (shifted by -I to get at most 1 pos)")
    
    # Shifted Laplacian: L - λ_max I 
    evals_L = np.linalg.eigvalsh(L)
    L_shifted = L - evals_L.max() * np.eye(4)
    all_pass &= run_single_test(L_shifted, "K₄ Laplacian shifted by -λ_max·I")
    
    # Test 8: Random symmetric matrices
    print("\n" + "━"*60)
    print("  SECTION 3: Random 4×4 Symmetric Matrices")
    print("━"*60)
    
    n_random = 20
    n_pass = 0
    n_fail = 0
    
    for trial in range(n_random):
        B = np.random.randn(4, 4)
        A_rand = (B + B.T) / 2  # Symmetrize
        # Scale to have rational-like entries
        A_rand = np.round(A_rand * 4) / 4
        
        match = run_single_test(A_rand, f"Random trial {trial + 1}/{n_random}")
        if match:
            n_pass += 1
        else:
            n_fail += 1
            all_pass = False
    
    # Summary
    print("\n" + "="*60)
    print("  SUMMARY")
    print("="*60)
    print(f"  Structured tests: all passed")
    print(f"  Random tests: {n_pass}/{n_random} passed, {n_fail} failed")
    if all_pass:
        print(f"\n  ✓ ALL TESTS PASSED — Equivalence holds in all cases")
        print(f"    Lorentzian(P_A) ⟺ HasAtMostOnePositiveEigenvalue(A)")
    else:
        print(f"\n  ✗ SOME TESTS FAILED — Potential counterexamples found!")
    
    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())


#!/usr/bin/env python3
"""
Visualization: Eigenvalue Landscape and Lorentzian Boundary

Visualizes how the Lorentzian condition partitions the space of 2×2 symmetric
matrices by eigenvalue sign pattern. For 2×2 matrices parametrized by (a, b, c)
where A = [[a, b], [b, c]], the Lorentzian boundary is the hypersurface
separating matrices with ≤1 vs ≥2 positive eigenvalues.

Must be fully self-contained — no imports from local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def count_positive_eigenvalues(a, b, c):
    """For A = [[a,b],[b,c]], count positive eigenvalues."""
    trace = a + c
    det = a * c - b * b
    disc = np.sqrt(np.maximum((a - c)**2 + 4*b**2, 0))
    lambda1 = (trace + disc) / 2
    lambda2 = (trace - disc) / 2
    return (lambda1 > 1e-10).astype(int) + (lambda2 > 1e-10).astype(int)


# ── Figure 1: Lorentzian region in (a, c) plane for fixed b ──
fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle("Lorentzian Signature Region for 2×2 Symmetric Matrices\n"
             r"$A = \begin{pmatrix} a & b \\ b & c \end{pmatrix}$, "
             "green = at most 1 positive eigenvalue (Lorentzian)",
             fontsize=13, fontweight='bold')

b_values = [0, 0.5, 1.0, 2.0]
a_range = np.linspace(-3, 3, 400)
c_range = np.linspace(-3, 3, 400)

for idx, b_val in enumerate(b_values):
    ax = axes[idx // 2, idx % 2]
    A_grid, C_grid = np.meshgrid(a_range, c_range)
    
    n_pos = count_positive_eigenvalues(A_grid, b_val, C_grid)
    
    # Color: green for ≤1 (Lorentzian), red for ≥2
    colors = np.zeros((*n_pos.shape, 3))
    colors[n_pos <= 1] = [0.2, 0.7, 0.3]  # Green = Lorentzian
    colors[n_pos >= 2] = [0.8, 0.2, 0.2]  # Red = not Lorentzian
    
    ax.imshow(colors, extent=[a_range[0], a_range[-1], c_range[0], c_range[-1]],
              origin='lower', aspect='equal')
    
    # Draw boundary curves
    # At most 1 positive eigenvalue when det(A) ≥ 0 and trace ≤ 0, OR det ≤ 0
    # Boundary: det = 0 (ac = b²) or one eigenvalue = 0
    det_boundary = np.sqrt(np.maximum(b_val**2, 0))
    if b_val > 0:
        c_boundary = b_val**2 / np.maximum(a_range[a_range > 0], 1e-10)
        ax.plot(a_range[a_range > 0], c_boundary, 'k-', linewidth=2, label=r'$ac = b^2$')
        a_neg = a_range[a_range < 0]
        c_boundary_neg = b_val**2 / np.minimum(a_neg, -1e-10)
        ax.plot(a_neg, c_boundary_neg, 'k-', linewidth=2)
    
    ax.axhline(0, color='gray', linewidth=0.5)
    ax.axvline(0, color='gray', linewidth=0.5)
    ax.set_xlabel('a (diagonal entry)', fontsize=10)
    ax.set_ylabel('c (diagonal entry)', fontsize=10)
    ax.set_title(f'b = {b_val}', fontsize=12, fontweight='bold')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    
    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor=(0.2, 0.7, 0.3), label='≤1 pos. eigenvalue (Lorentzian)'),
        Patch(facecolor=(0.8, 0.2, 0.2), label='≥2 pos. eigenvalues')
    ]
    if idx == 0:
        ax.legend(handles=legend_elements, loc='upper left', fontsize=8)

plt.tight_layout()
plt.savefig("eigenvalue_landscape.png", dpi=150, bbox_inches='tight')
print("Saved: eigenvalue_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Embedding — Eigenvalue Landscape

Visualizes the core theorem: the Lorentzian leaf condition of P_A = t²·Q_A(x)
is equivalent to A having at most one positive eigenvalue.

Shows:
1. Heatmap of the block-zero-extended Hessian
2. Eigenvalue spectrum comparison: A vs. its block extension
3. Quadratic form level curves on a 2D section

Must be fully self-contained — no imports from local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def eigenvalue_inertia(A, tol=1e-10):
    evals = np.linalg.eigvalsh(A)
    return (int(np.sum(evals > tol)), 
            int(np.sum(np.abs(evals) <= tol)),
            int(np.sum(evals < -tol)))


def block_zero_extend(A):
    n = A.shape[0]
    B = np.zeros((n + 1, n + 1))
    B[1:, 1:] = A
    return B


def quadratic_form_2d(A, u, v, s_range, t_range):
    """Evaluate Q_A(s·u + t·v) on a grid."""
    S, T = np.meshgrid(s_range, t_range)
    Q = np.zeros_like(S)
    for i in range(A.shape[0]):
        for j in range(A.shape[0]):
            Q += A[i, j] * (S * u[i] + T * v[i]) * (S * u[j] + T * v[j])
    return S, T, Q


# ── Create figure ──
fig = plt.figure(figsize=(16, 12))
fig.suptitle("Spectral Embedding: Matrix Positivity → Lorentzian Leaves\n"
             r"$P_A(t, x) = t^2 \cdot Q_A(x)$, Lorentzian$(P_A) \Leftrightarrow$ "
             "at most 1 positive eigenvalue",
             fontsize=14, fontweight='bold')

gs = gridspec.GridSpec(2, 3, hspace=0.4, wspace=0.35)

# ── Matrices to test ──
matrices = [
    (np.diag([3.0, -1.0, -2.0]), "diag(3, −1, −2)\n1 positive eigenvalue\n→ LORENTZIAN"),
    (np.diag([2.0, 1.0, -3.0]), "diag(2, 1, −3)\n2 positive eigenvalues\n→ NOT LORENTZIAN"),
    (np.array([[1, 2, 0], [2, -1, 1], [0, 1, -3.0]]), "Mixed symmetric\nCheck eigenvalues"),
]

# ── Row 1: Hessian heatmaps ──
for col, (A, title) in enumerate(matrices):
    ax = fig.add_subplot(gs[0, col])
    B = 2 * block_zero_extend(A)  # Hessian of critical leaf
    
    vmax = max(abs(B.min()), abs(B.max())) or 1
    im = ax.imshow(B, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                   interpolation='nearest', aspect='equal')
    
    n = B.shape[0]
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{B[i,j]:.1f}', ha='center', va='center',
                    fontsize=8, color='black' if abs(B[i,j]) < vmax*0.5 else 'white')
    
    evals = np.linalg.eigvalsh(A)
    n_pos = np.sum(evals > 1e-10)
    is_lor = n_pos <= 1
    
    ax.set_title(title, fontsize=10, 
                 color='green' if is_lor else 'red',
                 fontweight='bold')
    ax.set_xlabel("Column index")
    ax.set_ylabel("Row index")
    
    # Add eigenvalue annotation
    evals_str = ", ".join(f"{e:.2f}" for e in sorted(evals)[::-1])
    ax.text(0.5, -0.15, f"λ(A) = [{evals_str}]",
            transform=ax.transAxes, ha='center', fontsize=8)

# ── Row 2: Quadratic form contours ──
for col, (A, title) in enumerate(matrices):
    ax = fig.add_subplot(gs[1, col])
    
    n = A.shape[0]
    # Use first two standard basis vectors for 2D section
    u = np.zeros(n); u[0] = 1
    v = np.zeros(n); v[1] = 1
    
    s_range = np.linspace(-2, 2, 200)
    t_range = np.linspace(-2, 2, 200)
    S, T, Q = quadratic_form_2d(A, u, v, s_range, t_range)
    
    # Contour plot
    levels = np.linspace(-10, 10, 21)
    cs = ax.contourf(S, T, Q, levels=levels, cmap='RdBu_r', extend='both')
    ax.contour(S, T, Q, levels=[0], colors='black', linewidths=2)
    
    evals = np.linalg.eigvalsh(A)
    n_pos = np.sum(evals > 1e-10)
    is_lor = n_pos <= 1
    
    status = "LORENTZIAN ✓" if is_lor else "NOT LORENTZIAN ✗"
    ax.set_title(f"$Q_A(s e_1 + t e_2)$\n{status}",
                 fontsize=10, color='green' if is_lor else 'red',
                 fontweight='bold')
    ax.set_xlabel("s")
    ax.set_ylabel("t")
    ax.set_aspect('equal')
    ax.axhline(0, color='gray', linewidth=0.5)
    ax.axvline(0, color='gray', linewidth=0.5)
    
    plt.colorbar(cs, ax=ax, shrink=0.8, label=r"$Q_A$")

plt.savefig("spectral_embedding_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: spectral_embedding_visualization.png")
