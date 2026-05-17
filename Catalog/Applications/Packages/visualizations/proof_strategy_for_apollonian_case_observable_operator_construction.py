#!/usr/bin/env python3
"""
Apollonian Spectral-Polynomial Transfer: Algorithms

Implements the core algorithms for:
1. Apollonian generator action on polynomial observables
2. Spectral gap computation on finite-dimensional observable spaces
3. Iterate contraction verification
4. Orbit enumeration with Descartes constraint
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from itertools import product as iter_product


# =============================================================================
# Algorithm 1: Apollonian Generator Infrastructure
# =============================================================================

def descartes_matrix() -> np.ndarray:
    """Descartes quadratic form matrix J = 2I₄ - 11ᵀ.
    
    Returns:
        4x4 integer matrix with J[i,i]=1, J[i,j]=-1 for i≠j
    
    Complexity: O(1)
    """
    return np.array([[1,-1,-1,-1],[-1,1,-1,-1],[-1,-1,1,-1],[-1,-1,-1,1]], dtype=int)


def apollonian_generators() -> List[np.ndarray]:
    """The four Apollonian reflection generators.
    
    Generator S_i replaces b_i with 2*sum(b_j, j≠i) - b_i,
    fixing all other coordinates.
    
    Returns:
        List of four 4x4 integer matrices
    
    Complexity: O(1)
    """
    gens = []
    for i in range(4):
        S = np.eye(4, dtype=int)
        for j in range(4):
            S[i, j] = -1 if i == j else 2
        gens.append(S)
    return gens


def descartes_Q(v: np.ndarray) -> int:
    """Evaluate the Descartes quadratic form Q(v) = v^T J v.
    
    Args:
        v: Integer vector of length 4
    
    Returns:
        Q(v) = 2*sum(v_i^2) - (sum(v_i))^2
    
    Complexity: O(1)
    """
    return int(v @ descartes_matrix() @ v)


# =============================================================================
# Algorithm 2: Monomial Basis for Degree-≤k Observables
# =============================================================================

def degree_le_k_monomials(n_vars: int, k: int) -> List[Tuple[int, ...]]:
    """Enumerate all monomials in n_vars variables with total degree ≤ k.
    
    Each monomial is represented as a tuple (a_0, ..., a_{n-1}) where
    a_i is the exponent of variable i.
    
    Args:
        n_vars: Number of variables
        k: Maximum total degree
    
    Returns:
        List of exponent tuples, sorted lexicographically
    
    Complexity: O(C(n_vars + k, k)) where C is binomial coefficient
    """
    if n_vars == 0:
        return [()]
    
    result = []
    for deg in range(k + 1):
        _enumerate_monomials(n_vars, deg, [], result)
    return result


def _enumerate_monomials(n_vars: int, remaining_deg: int, 
                          current: list, result: list):
    """Helper: enumerate monomials of exactly given degree."""
    if len(current) == n_vars - 1:
        result.append(tuple(current + [remaining_deg]))
        return
    for a in range(remaining_deg + 1):
        current.append(a)
        _enumerate_monomials(n_vars, remaining_deg - a, current, result)
        current.pop()


# =============================================================================
# Algorithm 3: Observable Operator Matrix Construction
# =============================================================================

def build_observable_operator(generators: List[np.ndarray], 
                               k: int) -> Tuple[np.ndarray, List[Tuple]]:
    """Build the averaging operator T_k on degree-≤k polynomial observables.
    
    T_k = (1/|G|) * sum_{S in generators} rho_k(S)
    
    where rho_k(S) is the induced action on degree-≤k polynomials:
    (rho_k(S) f)(v) = f(S*v).
    
    We compute T_k as a matrix on the monomial basis by symbolic expansion.
    
    Args:
        generators: List of n×n integer matrices (group generators)
        k: Maximum polynomial degree
    
    Returns:
        (T_k matrix, list of monomial basis elements)
    
    Complexity: O(|G| * dim^2 * k) where dim = C(n+k, k)
    
    Algorithm:
        For each generator S and each basis monomial m(v) = v^a:
            m(Sv) = prod_j (sum_l S[j,l]*v_l)^{a_j}
        Expand symbolically and collect coefficients in the monomial basis.
    """
    n = generators[0].shape[0]
    basis = degree_le_k_monomials(n, k)
    dim = len(basis)
    basis_index = {m: i for i, m in enumerate(basis)}
    
    T = np.zeros((dim, dim))
    n_gens = len(generators)
    
    for S in generators:
        # For each generator, compute the action matrix
        action = np.zeros((dim, dim))
        
        for col_idx, mono in enumerate(basis):
            # Compute the image of monomial mono under S
            # mono = (a_0, ..., a_{n-1})
            # m(Sv) = prod_j (row_j . v)^{a_j}
            # We expand this product symbolically
            coeffs = _expand_monomial_precomp(S, mono, basis_index, n)
            for row_idx, c in coeffs.items():
                action[row_idx, col_idx] = c
        
        T += action / n_gens
    
    return T, basis


def _expand_monomial_precomp(S: np.ndarray, mono: tuple, 
                              basis_index: dict, n: int) -> dict:
    """Expand a monomial after precomposition with matrix S.
    
    Computes the polynomial m(S*v) where m is the monomial with exponent vector 'mono',
    expressed as a linear combination of basis monomials.
    
    Uses the multinomial theorem iteratively.
    """
    # Start with 1 (the polynomial 1, represented as {(): 1.0})
    result = {tuple([0]*n): 1.0}
    
    for j in range(n):
        a_j = mono[j]
        if a_j == 0:
            continue
        
        # Need to multiply by (sum_l S[j,l] * v_l)^{a_j}
        # First compute the linear form as a dict {unit_vector: coefficient}
        linear = {}
        for l in range(n):
            if S[j, l] != 0:
                e = [0] * n
                e[l] = 1
                linear[tuple(e)] = float(S[j, l])
        
        # Raise linear form to power a_j
        power = _poly_power(linear, a_j, n)
        
        # Multiply result by power
        result = _poly_mul(result, power, n)
    
    # Filter to basis monomials
    filtered = {}
    for exp, coeff in result.items():
        if abs(coeff) > 1e-12 and exp in basis_index:
            filtered[basis_index[exp]] = coeff
    
    return filtered


def _poly_mul(p1: dict, p2: dict, n: int) -> dict:
    """Multiply two polynomials (represented as {exponent_tuple: coeff})."""
    result = {}
    for e1, c1 in p1.items():
        for e2, c2 in p2.items():
            e = tuple(e1[i] + e2[i] for i in range(n))
            result[e] = result.get(e, 0.0) + c1 * c2
    return result


def _poly_power(p: dict, k: int, n: int) -> dict:
    """Raise polynomial to the k-th power by repeated multiplication."""
    if k == 0:
        return {tuple([0]*n): 1.0}
    result = dict(p)
    for _ in range(k - 1):
        result = _poly_mul(result, p, n)
    return result


# =============================================================================
# Algorithm 4: Spectral Gap Analysis
# =============================================================================

def spectral_gap_analysis(T: np.ndarray) -> Dict:
    """Analyze the spectral gap of an operator matrix.
    
    Computes eigenvalues, identifies invariant subspace, and measures
    the spectral gap on the complement.
    
    Args:
        T: Square matrix (the operator)
    
    Returns:
        Dictionary with eigenvalues, spectral gap, invariant dimension, etc.
    
    Complexity: O(dim^3) for eigenvalue computation
    """
    eigenvalues, eigenvectors = np.linalg.eig(T)
    
    # Sort by magnitude
    idx = np.argsort(np.abs(eigenvalues))[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]
    
    # Find invariant subspace (eigenvalue = largest |λ|)
    max_eval = np.abs(eigenvalues[0])
    tol = 1e-8
    invariant_dim = sum(1 for ev in eigenvalues if abs(abs(ev) - max_eval) < tol)
    
    # Spectral gap
    if invariant_dim < len(eigenvalues):
        second_eval = np.abs(eigenvalues[invariant_dim])
        gap = max_eval - second_eval
        relative_gap = 1.0 - second_eval / max_eval if max_eval > 0 else 0
    else:
        gap = 0.0
        relative_gap = 0.0
    
    return {
        'eigenvalues': eigenvalues,
        'eigenvectors': eigenvectors,
        'max_eigenvalue': max_eval,
        'second_eigenvalue': np.abs(eigenvalues[invariant_dim]) if invariant_dim < len(eigenvalues) else 0,
        'invariant_dim': invariant_dim,
        'absolute_gap': gap,
        'relative_gap': relative_gap,
        'dimension': len(eigenvalues)
    }


# =============================================================================
# Algorithm 5: Iterate Contraction Verification
# =============================================================================

def verify_iterate_contraction(T: np.ndarray, gap: float, 
                                n_iters: int = 20,
                                n_trials: int = 100) -> Dict:
    """Verify geometric contraction of iterates on centered observables.
    
    For random centered vectors v (orthogonal to the invariant subspace),
    verify ||T^n v|| ≤ (1-γ)^n ||v||.
    
    Args:
        T: Operator matrix
        gap: Spectral gap parameter
        n_iters: Number of iterations to check
        n_trials: Number of random test vectors
    
    Returns:
        Dictionary with contraction data and verification status
    
    Complexity: O(n_trials * n_iters * dim^2)
    """
    dim = T.shape[0]
    
    # Find invariant subspace
    analysis = spectral_gap_analysis(T)
    inv_dim = analysis['invariant_dim']
    
    # Project out invariant subspace
    eigenvalues = analysis['eigenvalues']
    eigenvectors = analysis['eigenvectors']
    max_eval = analysis['max_eigenvalue']
    
    # Build projector onto complement
    P_inv = np.zeros((dim, dim))
    for i in range(inv_dim):
        ev = eigenvectors[:, i:i+1]
        P_inv += np.real(ev @ ev.T.conj()) / np.real(ev.T.conj() @ ev)
    P_comp = np.eye(dim) - P_inv
    
    results = []
    all_satisfied = True
    
    np.random.seed(42)
    for trial in range(n_trials):
        v = np.random.randn(dim)
        v = P_comp @ v  # Project to complement
        v_norm = np.linalg.norm(v)
        
        if v_norm < 1e-10:
            continue
        
        trial_data = []
        w = v.copy()
        for n in range(1, n_iters + 1):
            w = T @ w
            actual = np.linalg.norm(w)
            bound = (1 - gap) ** n * v_norm if gap <= 1 else 0
            satisfied = actual <= bound + 1e-10
            if not satisfied:
                all_satisfied = False
            trial_data.append({
                'n': n,
                'actual_norm': actual,
                'bound': bound,
                'satisfied': satisfied
            })
        results.append(trial_data)
    
    return {
        'all_satisfied': all_satisfied,
        'n_trials': n_trials,
        'n_iters': n_iters,
        'gap_used': gap,
        'results': results
    }


# =============================================================================
# Algorithm 6: Apollonian Orbit Enumeration
# =============================================================================

def enumerate_apollonian_orbit(root: np.ndarray, 
                                max_depth: int) -> Dict:
    """BFS enumeration of the Apollonian orbit.
    
    Starting from a root Descartes quadruple, apply all generators
    at each level, collecting new quadruples.
    
    Args:
        root: Initial curvature vector (Fin 4 -> Z)
        max_depth: Maximum BFS depth
    
    Returns:
        Dictionary with orbit data, curvature statistics
    
    Complexity: O(4^depth) worst case, O(3^depth) typical
    """
    gens = apollonian_generators()
    
    visited = {tuple(root)}
    frontier = [root.copy()]
    depth_data = []
    all_curvatures = set(root.tolist())
    
    for depth in range(1, max_depth + 1):
        new_frontier = []
        for v in frontier:
            for S in gens:
                w = S @ v
                key = tuple(w)
                if key not in visited:
                    visited.add(key)
                    new_frontier.append(w)
                    for c in w:
                        all_curvatures.add(int(c))
        
        frontier = new_frontier
        pos_curvatures = [c for c in all_curvatures if c > 0]
        
        depth_data.append({
            'depth': depth,
            'total_quadruples': len(visited),
            'new_quadruples': len(new_frontier),
            'distinct_curvatures': len(pos_curvatures),
            'max_curvature': max(pos_curvatures) if pos_curvatures else 0
        })
    
    return {
        'root': root.tolist(),
        'depth_data': depth_data,
        'all_curvatures': sorted(all_curvatures),
        'all_quadruples': [list(v) for v in visited]
    }


# =============================================================================
# Main: Run all algorithms with the Apollonian gasket
# =============================================================================

if __name__ == "__main__":
    print("Apollonian Spectral-Polynomial Transfer: Algorithm Suite")
    print("=" * 60)
    
    gens = apollonian_generators()
    
    # Algorithm 3: Build observable operators
    for k in range(1, 4):
        T_k, basis = build_observable_operator(gens, k)
        analysis = spectral_gap_analysis(T_k)
        
        print(f"\nDegree ≤ {k} observable space:")
        print(f"  Dimension: {analysis['dimension']}")
        print(f"  Max eigenvalue: {analysis['max_eigenvalue']:.4f}")
        print(f"  Second eigenvalue: {analysis['second_eigenvalue']:.4f}")
        print(f"  Relative spectral gap: {analysis['relative_gap']:.4f}")
        print(f"  Invariant subspace dim: {analysis['invariant_dim']}")
        
        # Verify contraction
        if analysis['relative_gap'] > 0.01:
            verification = verify_iterate_contraction(
                T_k / analysis['max_eigenvalue'],  # Normalize
                analysis['relative_gap'],
                n_iters=15, n_trials=50
            )
            print(f"  Contraction verified: {verification['all_satisfied']}")
    
    # Algorithm 6: Orbit enumeration
    print("\n" + "=" * 60)
    root = np.array([-1, 2, 2, 3])
    orbit = enumerate_apollonian_orbit(root, max_depth=6)
    print(f"\nOrbit from root {root}:")
    for d in orbit['depth_data']:
        print(f"  Depth {d['depth']}: {d['total_quadruples']} quadruples, "
              f"max curv = {d['max_curvature']}")
