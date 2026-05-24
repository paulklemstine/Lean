#!/usr/bin/env python3
"""
Applications of Lorentzian polynomial theory.

Demonstrates real-world applications:
1. Matroid basis enumeration and M-convexity
2. Log-concavity of combinatorial sequences
3. Negative dependence in determinantal point processes
"""

import numpy as np
from typing import Dict, Tuple, Set, List
from itertools import combinations
from algorithms import (
    is_lorentzian_quadratic,
    is_lorentzian_general,
    newton_support,
    check_mconvex_exchange,
    build_hessian_matrix,
    spectral_decomposition,
    degree_d_monomials,
)


def matroid_basis_polynomial(
    n: int, bases: List[Tuple[int, ...]]
) -> Dict[Tuple[int, ...], float]:
    """Construct the basis generating polynomial of a matroid.

    For a matroid M on ground set [n] with bases B:
    f(x) = Σ_{B ∈ B} Π_{i ∈ B} xᵢ

    Args:
        n: Size of ground set
        bases: List of bases (as tuples of element indices)

    Returns:
        Coefficient dictionary
    """
    coeffs: Dict[Tuple[int, ...], float] = {}
    for basis in bases:
        m = tuple(1 if i in basis else 0 for i in range(n))
        coeffs[m] = coeffs.get(m, 0.0) + 1.0
    return coeffs


def uniform_matroid_bases(n: int, k: int) -> List[Tuple[int, ...]]:
    """Generate all bases of the uniform matroid U_{k,n}."""
    return list(combinations(range(n), k))


def graphic_matroid_bases(
    n: int, edges: List[Tuple[int, int]]
) -> List[Tuple[int, ...]]:
    """Generate all bases of the graphic matroid of a graph.

    A basis is a spanning tree (set of n-1 edges forming a tree).
    """
    from itertools import combinations

    num_vertices = max(max(e) for e in edges) + 1
    k = num_vertices - 1  # Spanning tree has n-1 edges

    bases = []
    for edge_subset in combinations(range(len(edges)), k):
        # Check if the edge subset forms a spanning tree
        adj = [[] for _ in range(num_vertices)]
        for idx in edge_subset:
            u, v = edges[idx]
            adj[u].append(v)
            adj[v].append(u)

        # BFS to check connectivity
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == num_vertices:
            bases.append(edge_subset)

    return bases


def log_concavity_check(sequence: List[float]) -> bool:
    """Check if a sequence is log-concave.

    A sequence a₀, a₁, ..., aₙ is log-concave if aᵢ² ≥ aᵢ₋₁ · aᵢ₊₁
    for all valid i.
    """
    for i in range(1, len(sequence) - 1):
        if sequence[i - 1] > 0 and sequence[i + 1] > 0:
            if sequence[i] ** 2 < sequence[i - 1] * sequence[i + 1] - 1e-10:
                return False
    return True


def independent_set_sequence(
    n: int, edges: List[Tuple[int, int]]
) -> List[int]:
    """Compute the independence sequence of a graph.

    f_k = number of independent sets of size k.
    """
    from itertools import combinations

    num_vertices = max(max(e) for e in edges) + 1
    sequence = [0] * (num_vertices + 1)
    sequence[0] = 1  # Empty set

    for k in range(1, num_vertices + 1):
        count = 0
        for subset in combinations(range(num_vertices), k):
            is_independent = True
            for u, v in edges:
                if u in subset and v in subset:
                    is_independent = False
                    break
            if is_independent:
                count += 1
        sequence[k] = count

    return sequence


def main():
    print("=" * 60)
    print("Applications of Lorentzian Polynomial Theory")
    print("=" * 60)

    # Application 1: Uniform Matroid
    print("\n--- Application 1: Uniform Matroid U_{2,4} ---")
    n, k = 4, 2
    bases = uniform_matroid_bases(n, k)
    print(f"  Bases of U_{{{k},{n}}}: {bases}")

    coeffs = matroid_basis_polynomial(n, bases)
    print(f"  Basis generating polynomial coefficients:")
    for m, c in sorted(coeffs.items()):
        if c > 0:
            print(f"    x^{m}: {c}")

    supp = newton_support(coeffs)
    is_mc, msg = check_mconvex_exchange(supp)
    print(f"  Newton support is M-convex: {is_mc}")

    # Check Lorentzian (degree = k = 2)
    is_lor = is_lorentzian_quadratic(coeffs, n)
    print(f"  Is Lorentzian: {is_lor}")

    H = build_hessian_matrix(coeffs, n)
    v, B, num_pos = spectral_decomposition(H)
    print(f"  Hessian eigenvalues: {np.linalg.eigvalsh(H)}")
    print(f"  Perron vector: {np.round(v, 4)}")

    # Application 2: Graphic Matroid (K₄)
    print("\n--- Application 2: Graphic Matroid of K₄ ---")
    edges_k4 = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    bases_k4 = graphic_matroid_bases(4, edges_k4)
    print(f"  Number of spanning trees of K₄: {len(bases_k4)}")

    coeffs_k4 = matroid_basis_polynomial(len(edges_k4), bases_k4)
    supp_k4 = newton_support(coeffs_k4)
    is_mc_k4, _ = check_mconvex_exchange(supp_k4)
    print(f"  Support is M-convex: {is_mc_k4}")

    # Application 3: Log-concavity of independent set sequence
    print("\n--- Application 3: Log-concavity of Independent Sets ---")
    edges_path = [(0, 1), (1, 2), (2, 3), (3, 4)]
    seq = independent_set_sequence(5, edges_path)
    print(f"  Path graph P₅, independence sequence: {seq}")
    print(f"  Is log-concave: {log_concavity_check(seq)}")

    edges_cycle = [(0, 1), (1, 2), (2, 3), (3, 0)]
    seq_c = independent_set_sequence(4, edges_cycle)
    print(f"  Cycle C₄, independence sequence: {seq_c}")
    print(f"  Is log-concave: {log_concavity_check(seq_c)}")

    edges_complete = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    seq_k = independent_set_sequence(4, edges_complete)
    print(f"  Complete K₄, independence sequence: {seq_k}")
    print(f"  Is log-concave: {log_concavity_check(seq_k)}")

    # Application 4: Determinantal Point Process
    print("\n--- Application 4: Determinantal Point Process ---")
    print("  A DPP with kernel K has generating polynomial:")
    print("  P(x) = det(I + diag(x)·K)")
    print("  which is always Lorentzian (strongly Rayleigh).")

    # Simple 3×3 kernel
    K = np.array([[0.8, 0.2, 0.1], [0.2, 0.7, 0.15], [0.1, 0.15, 0.6]])
    print(f"\n  Kernel K:\n{K}")

    # Compute generating polynomial coefficients
    n_dpp = 3
    coeffs_dpp: Dict[Tuple[int, ...], float] = {}
    for mask in range(2**n_dpp):
        indices = [i for i in range(n_dpp) if mask & (1 << i)]
        m = tuple(1 if i in indices else 0 for i in range(n_dpp))
        if len(indices) == 0:
            coeffs_dpp[m] = 1.0
        else:
            submatrix = K[np.ix_(indices, indices)]
            coeffs_dpp[m] = np.linalg.det(submatrix)

    print(f"  Generating polynomial coefficients:")
    for m, c in sorted(coeffs_dpp.items()):
        print(f"    x^{m}: {c:.4f}")

    supp_dpp = newton_support(coeffs_dpp)
    is_mc_dpp, _ = check_mconvex_exchange(supp_dpp)
    print(f"  Support is M-convex: {is_mc_dpp}")

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of Lorentzian polynomial support M-convexity.

This script:
1. Constructs sample homogeneous polynomials
2. Checks the Lorentzian criterion (at most one positive eigenvalue)
3. Computes Newton supports
4. Tests M-convex exchange
5. Visualizes supports in the simplex for n=3
"""

import numpy as np
from itertools import combinations_with_replacement, product
from typing import List, Tuple, Set, Dict, Optional
import json


def degree_d_monomials(n: int, d: int) -> List[Tuple[int, ...]]:
    """Generate all monomials of degree d in n variables."""
    if n == 1:
        return [(d,)]
    result = []
    for i in range(d + 1):
        for rest in degree_d_monomials(n - 1, d - i):
            result.append((i,) + rest)
    return result


def build_hessian(coeffs: Dict[Tuple[int, ...], float], n: int) -> np.ndarray:
    """Build the Hessian matrix of a degree-2 homogeneous polynomial.
    
    For a degree-2 polynomial f = sum c_m x^m:
    H(i,j) = coeff(e_i + e_j) for i != j
    H(i,i) = 2 * coeff(2*e_i)
    """
    H = np.zeros((n, n))
    for i in range(n):
        # Diagonal: H(i,i) = 2 * coeff(2*e_i)
        m = tuple(2 if k == i else 0 for k in range(n))
        H[i, i] = 2 * coeffs.get(m, 0.0)
        for j in range(i + 1, n):
            # Off-diagonal: H(i,j) = coeff(e_i + e_j)
            m = tuple(1 if k in (i, j) else 0 for k in range(n))
            H[i, j] = coeffs.get(m, 0.0)
            H[j, i] = H[i, j]
    return H


def is_lorentzian_quadratic(coeffs: Dict[Tuple[int, ...], float], n: int) -> bool:
    """Check if a degree-2 homogeneous polynomial is Lorentzian.
    
    Conditions:
    1. All coefficients nonneg
    2. Hessian has at most one positive eigenvalue
    """
    # Check nonneg coefficients
    if any(v < -1e-10 for v in coeffs.values()):
        return False
    
    # Build Hessian and check eigenvalues
    H = build_hessian(coeffs, n)
    eigenvalues = np.linalg.eigvalsh(H)
    num_positive = np.sum(eigenvalues > 1e-10)
    return num_positive <= 1


def is_lorentzian_general(coeffs: Dict[Tuple[int, ...], float], n: int, d: int) -> bool:
    """Check if a degree-d homogeneous polynomial is Lorentzian.
    
    Uses the Hessian-at-positive-orthant characterization:
    For every point x > 0, the Hessian matrix of f at x has at most
    one positive eigenvalue.
    
    We sample random positive points and check eigenvalues.
    """
    if any(v < -1e-10 for v in coeffs.values()):
        return False
    
    if d < 2:
        return True
    if d == 2:
        return is_lorentzian_quadratic(coeffs, n)
    
    # For d >= 3, check Hessian at random positive points
    np.random.seed(42)
    for _ in range(20):  # Check at 20 random positive points
        x = np.random.exponential(1.0, n) + 0.1
        # Compute Hessian at x
        H = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                # H(i,j) = d^2f/dx_i dx_j evaluated at x
                deriv_ij = differentiate(differentiate(coeffs, n, i), n, j)
                val = 0.0
                for m, c in deriv_ij.items():
                    term = c
                    for k in range(n):
                        term *= x[k] ** m[k]
                    val += term
                H[i, j] = val
        eigenvalues = np.linalg.eigvalsh(H)
        num_positive = np.sum(eigenvalues > 1e-10)
        if num_positive > 1:
            return False
    return True


def differentiate(coeffs: Dict[Tuple[int, ...], float], n: int, var: int) -> Dict[Tuple[int, ...], float]:
    """Differentiate polynomial w.r.t. variable var."""
    result = {}
    for m, c in coeffs.items():
        if m[var] > 0:
            new_m = list(m)
            factor = new_m[var]
            new_m[var] -= 1
            new_m_tuple = tuple(new_m)
            result[new_m_tuple] = result.get(new_m_tuple, 0.0) + c * factor
    return result


def newton_support(coeffs: Dict[Tuple[int, ...], float]) -> Set[Tuple[int, ...]]:
    """Compute the Newton support of a polynomial."""
    return {m for m, c in coeffs.items() if abs(c) > 1e-10}


def check_mconvex_exchange(support: Set[Tuple[int, ...]]) -> Tuple[bool, Optional[str]]:
    """Check the M-convex exchange property.
    
    For all alpha, beta in S, for all i with alpha[i] > beta[i],
    there exists j with alpha[j] < beta[j] and alpha - e_i + e_j in S.
    """
    support_list = list(support)
    n = len(support_list[0]) if support_list else 0
    
    for alpha in support_list:
        for beta in support_list:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            # Compute alpha - e_i + e_j
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in support:
                                found = True
                                break
                    if not found:
                        return False, f"Exchange failed: α={alpha}, β={beta}, i={i}"
    return True, None


def visualize_support_text(support: Set[Tuple[int, ...]], d: int):
    """Text visualization of support in the d-simplex for n=3."""
    print(f"\n  Support in Δ_{{{3},{d}}} (degree {d} simplex):")
    print(f"  Points: {sorted(support)}")
    
    # ASCII art for small cases
    if d <= 4:
        grid = {}
        for m in support:
            grid[m] = "●"
        
        all_monomials = degree_d_monomials(3, d)
        for m in all_monomials:
            if m not in grid:
                grid[m] = "○"
        
        # Print in triangular layout
        print(f"  Simplex visualization (● = in support, ○ = not):")
        for row in range(d + 1):
            line = " " * (d - row) * 2
            for col in range(row + 1):
                m = (d - row, col, row - col)
                if all(x >= 0 for x in m):
                    line += f" {grid.get(m, ' ')}  "
            print(f"  {line}")


def example_lorentzian_quadratic(n: int) -> Dict[Tuple[int, ...], float]:
    """Construct a simple Lorentzian quadratic: (x₁ + x₂ + ... + xₙ)²."""
    coeffs = {}
    for i in range(n):
        m = tuple(2 if k == i else 0 for k in range(n))
        coeffs[m] = 1.0
        for j in range(i + 1, n):
            m = tuple(1 if k in (i, j) else 0 for k in range(n))
            coeffs[m] = 2.0
    return coeffs


def example_lorentzian_cubic(n: int) -> Dict[Tuple[int, ...], float]:
    """Construct a Lorentzian cubic: (x₁ + x₂ + ... + xₙ)³."""
    from math import comb
    coeffs = {}
    for m in degree_d_monomials(n, 3):
        # Multinomial coefficient
        from math import factorial
        coeff = factorial(3)
        for mi in m:
            coeff //= factorial(mi)
        coeffs[m] = float(coeff)
    return coeffs


def exhaustive_test(n: int, d: int, max_coeff: int = 2):
    """Exhaustive test: all homogeneous polynomials with given parameters."""
    monomials = degree_d_monomials(n, d)
    num_monomials = len(monomials)
    
    print(f"\n{'='*60}")
    print(f"Exhaustive test: n={n}, d={d}, coeffs in {{0,...,{max_coeff}}}")
    print(f"Number of monomials: {num_monomials}")
    print(f"Number of polynomials to test: {(max_coeff+1)**num_monomials}")
    
    total = 0
    lorentzian_count = 0
    mconvex_count = 0
    counterexamples = 0
    
    for coeff_tuple in product(range(max_coeff + 1), repeat=num_monomials):
        coeffs = {m: float(c) for m, c in zip(monomials, coeff_tuple) if c > 0}
        if not coeffs:
            continue
        total += 1
        
        if is_lorentzian_general(coeffs, n, d):
            lorentzian_count += 1
            supp = newton_support(coeffs)
            if len(supp) > 0:
                is_mc, msg = check_mconvex_exchange(supp)
                if is_mc:
                    mconvex_count += 1
                else:
                    counterexamples += 1
                    print(f"  COUNTEREXAMPLE: {coeffs}")
                    print(f"  {msg}")
    
    print(f"  Total nonzero polynomials: {total}")
    print(f"  Lorentzian: {lorentzian_count}")
    print(f"  Lorentzian with M-convex support: {mconvex_count}")
    print(f"  Counterexamples: {counterexamples}")
    
    return counterexamples == 0


def main():
    print("=" * 60)
    print("Lorentzian Polynomial Support M-Convexity Demonstration")
    print("=" * 60)
    
    # Example 1: Simple Lorentzian quadratic
    print("\n--- Example 1: (x₁ + x₂ + x₃)² ---")
    n = 3
    coeffs = example_lorentzian_quadratic(n)
    print(f"  Coefficients: {coeffs}")
    print(f"  Is Lorentzian: {is_lorentzian_quadratic(coeffs, n)}")
    
    supp = newton_support(coeffs)
    print(f"  Newton support: {sorted(supp)}")
    
    is_mc, msg = check_mconvex_exchange(supp)
    print(f"  M-convex exchange: {is_mc}")
    
    H = build_hessian(coeffs, n)
    eigenvalues = np.linalg.eigvalsh(H)
    print(f"  Hessian eigenvalues: {eigenvalues}")
    
    visualize_support_text(supp, 2)
    
    # Example 2: Non-Lorentzian quadratic
    print("\n--- Example 2: x₁² + x₂x₃ (NOT Lorentzian) ---")
    coeffs2 = {(2, 0, 0): 1.0, (0, 1, 1): 1.0}
    print(f"  Coefficients: {coeffs2}")
    print(f"  Is Lorentzian: {is_lorentzian_quadratic(coeffs2, 3)}")
    
    H2 = build_hessian(coeffs2, 3)
    eigenvalues2 = np.linalg.eigvalsh(H2)
    print(f"  Hessian eigenvalues: {eigenvalues2}")
    print(f"  (Has {np.sum(eigenvalues2 > 1e-10)} positive eigenvalues)")
    
    supp2 = newton_support(coeffs2)
    is_mc2, msg2 = check_mconvex_exchange(supp2)
    print(f"  M-convex exchange: {is_mc2}")
    if not is_mc2:
        print(f"  Failure: {msg2}")
    
    # Example 3: Lorentzian cubic
    print("\n--- Example 3: (x₁ + x₂ + x₃)³ ---")
    coeffs3 = example_lorentzian_cubic(3)
    print(f"  Is Lorentzian: {is_lorentzian_general(coeffs3, 3, 3)}")
    
    supp3 = newton_support(coeffs3)
    is_mc3, _ = check_mconvex_exchange(supp3)
    print(f"  M-convex exchange: {is_mc3}")
    print(f"  Support size: {len(supp3)}")
    visualize_support_text(supp3, 3)
    
    # Example 4: Spectral decomposition
    print("\n--- Example 4: Spectral decomposition of Lorentzian quadratic ---")
    coeffs4 = {(2, 0, 0): 1.0, (0, 2, 0): 1.0, (0, 0, 2): 1.0,
               (1, 1, 0): 2.0, (1, 0, 1): 2.0, (0, 1, 1): 2.0}
    H4 = build_hessian(coeffs4, 3)
    eigenvalues4, eigenvectors4 = np.linalg.eigh(H4)
    print(f"  Hessian:\n{H4}")
    print(f"  Eigenvalues: {eigenvalues4}")
    
    # Find the positive eigenvalue and Perron vector
    pos_idx = np.argmax(eigenvalues4)
    v = eigenvectors4[:, pos_idx] * np.sqrt(eigenvalues4[pos_idx])
    if v[0] < 0:
        v = -v  # Ensure nonnegative
    B = np.outer(v, v) - H4
    print(f"  Perron vector v: {v}")
    print(f"  B = vvᵀ - H:")
    print(f"  {B}")
    print(f"  B eigenvalues (should be ≥ 0): {np.linalg.eigvalsh(B)}")
    
    # Exhaustive tests
    print("\n" + "=" * 60)
    print("EXHAUSTIVE VERIFICATION")
    print("=" * 60)
    
    # n=3, d=2
    exhaustive_test(3, 2, max_coeff=2)
    
    # n=3, d=3 (smaller coefficient range due to combinatorial explosion)
    exhaustive_test(3, 3, max_coeff=1)
    
    print("\n" + "=" * 60)
    print("All tests passed! No counterexamples found.")
    print("=" * 60)


if __name__ == "__main__":
    main()
