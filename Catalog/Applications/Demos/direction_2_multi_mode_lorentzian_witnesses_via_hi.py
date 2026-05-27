#!/usr/bin/env python3
"""
Applications of Multi-Mode Lorentzian Witness Theory

Demonstrates real-world applications:
  1. Quantum entanglement detection in many-body systems
  2. Feature correlation analysis in machine learning (DPP kernels)
  3. Network community detection via spectral witnesses
  4. Random matrix theory and repulsive point processes

Usage:
    python applications.py
"""

import numpy as np
from itertools import combinations
from typing import Dict, Set, List, Tuple


# ──────────────────────────────────────────────────
# Core polynomial infrastructure (self-contained)
# ──────────────────────────────────────────────────

class MvPoly:
    """Sparse multivariate polynomial over ℝ."""
    def __init__(self, n: int, terms=None):
        self.n = n
        self.terms = {}
        if terms:
            for k, v in terms.items():
                if abs(v) > 1e-15:
                    self.terms[k] = v

    def partial(self, var):
        result = MvPoly(self.n)
        for exp, coeff in self.terms.items():
            if exp[var] > 0:
                ne = list(exp)
                ne[var] -= 1
                ne = tuple(ne)
                result.terms[ne] = result.terms.get(ne, 0) + coeff * exp[var]
        return result

    def eval_ones(self):
        return sum(self.terms.values())

    def add(self, other):
        r = MvPoly(self.n, dict(self.terms))
        for k, v in other.terms.items():
            r.terms[k] = r.terms.get(k, 0) + v
        r.terms = {k: v for k, v in r.terms.items() if abs(v) > 1e-15}
        return r


def build_dpp_poly(K):
    n = K.shape[0]
    p = MvPoly(n)
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            minor = 1.0 if len(S) == 0 else np.linalg.det(K[np.ix_(list(S), list(S))])
            exp = tuple(1 if i in S else 0 for i in range(n))
            p.terms[exp] = p.terms.get(exp, 0) + minor
    p.terms = {k: v for k, v in p.terms.items() if abs(v) > 1e-15}
    return p


def derivative_leaf(p, A_set):
    result = p
    for var in sorted(set(range(p.n)) - A_set):
        result = result.partial(var)
    return result


def mixed_hessian_at_ones(p, A_set):
    indices = sorted(A_set)
    k = len(indices)
    H = np.zeros((k, k))
    for a, i in enumerate(indices):
        pi = p.partial(i)
        for b, j in enumerate(indices):
            H[a, b] = pi.partial(j).eval_ones()
    return H


def spectral_witness(M):
    if M.shape[0] == 0:
        return 0.0
    return max(np.linalg.eigvalsh(M)[-1], 0.0)


def leaf_witness(p, A_set):
    leaf = derivative_leaf(p, A_set)
    H = mixed_hessian_at_ones(leaf, A_set)
    return spectral_witness(H)


def pairwise_witness(p, i, j):
    leaf = derivative_leaf(p, {i, j})
    return leaf.partial(i).partial(j).eval_ones() ** 2


# ──────────────────────────────────────────────────
# Application 1: Quantum Entanglement Detection
# ──────────────────────────────────────────────────

def app_quantum_entanglement():
    """
    Detect multipartite entanglement in free-fermion systems.
    
    A free-fermion state is described by a correlation matrix K (PSD contraction).
    The DPP polynomial Z_K encodes occupation statistics.
    Leaf witnesses detect entanglement between subsystems.
    
    Key insight: pairwise witnesses miss genuine 3-body entanglement
    that higher-order leaf witnesses can detect.
    """
    print("=" * 70)
    print("APPLICATION 1: Quantum Entanglement Detection")
    print("=" * 70)
    
    np.random.seed(42)
    n = 6  # 6 fermionic modes
    
    # Construct a correlation matrix with specific entanglement structure
    # Model: 3-body GHZ-like correlations among modes {0,1,2}
    K = np.eye(n) * 0.5  # Baseline: half-filled modes
    
    # Add off-diagonal correlations
    # Strong 3-body coupling among {0,1,2}
    for i, j in combinations([0, 1, 2], 2):
        K[i, j] = 0.3
        K[j, i] = 0.3
    
    # Weak pairwise coupling among {3,4,5}
    for i, j in combinations([3, 4, 5], 2):
        K[i, j] = 0.05
        K[j, i] = 0.05
    
    # Make PSD by projecting eigenvalues
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)  # Contraction: 0 ≤ K ≤ I
    K = eigvecs @ np.diag(eigvals) @ eigvecs.T
    
    print(f"\nCorrelation matrix K ({n} modes):")
    print(np.round(K, 3))
    print(f"Eigenvalues: {np.round(np.linalg.eigvalsh(K), 3)}")
    
    Z = build_dpp_poly(K)
    
    print("\n--- Entanglement Witnesses ---")
    print("\nTripartite witnesses (3-body):")
    tripartite_results = []
    for A in combinations(range(n), 3):
        w = leaf_witness(Z, set(A))
        tripartite_results.append((set(A), w))
        pw_max = max(pairwise_witness(Z, i, j) for i, j in combinations(A, 2))
        print(f"  A={set(A)}: leaf_witness={w:.4f}, max_pairwise={pw_max:.4f}, "
              f"ratio={w/pw_max:.2f}" if pw_max > 1e-10 else 
              f"  A={set(A)}: leaf_witness={w:.4f}, max_pairwise={pw_max:.4f}")
    
    # Identify the most entangled tripartite subsystem
    best = max(tripartite_results, key=lambda x: x[1])
    print(f"\n  Most entangled 3-body subsystem: {best[0]} (witness={best[1]:.4f})")


# ──────────────────────────────────────────────────
# Application 2: Feature Correlation in ML
# ──────────────────────────────────────────────────

def app_ml_diversity():
    """
    Analyze feature diversity in machine learning using DPP leaf witnesses.
    
    DPPs are used for diverse subset selection in ML. The leaf witness
    quantifies how much "collective diversity" a group of features has
    beyond pairwise dissimilarity.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Feature Diversity Analysis")
    print("=" * 70)
    
    np.random.seed(7)
    n = 5  # 5 features
    
    # Feature similarity kernel (Gram matrix)
    # Features 0,1,2 form a "topic cluster" with shared semantics
    features = np.array([
        [1.0, 0.1, 0.0],  # Feature 0
        [0.9, 0.2, 0.1],  # Feature 1 (similar to 0)
        [0.8, 0.3, 0.2],  # Feature 2 (similar to 0,1)
        [0.0, 1.0, 0.0],  # Feature 3 (independent)
        [0.0, 0.0, 1.0],  # Feature 4 (independent)
    ])
    
    K = features @ features.T
    # Normalize
    norms = np.sqrt(np.diag(K))
    K = K / np.outer(norms, norms)
    
    print(f"\nFeature similarity kernel ({n} features):")
    print(np.round(K, 3))
    
    Z = build_dpp_poly(K)
    
    print("\n--- Diversity Witnesses ---")
    for k in [2, 3]:
        print(f"\nSubsets of size {k}:")
        results = []
        for A in combinations(range(n), k):
            w = leaf_witness(Z, set(A))
            results.append((set(A), w))
        
        results.sort(key=lambda x: -x[1])
        for A_set, w in results[:5]:
            print(f"  {A_set}: diversity_witness={w:.4f}")
        
        print(f"  Most diverse: {results[0][0]} (witness={results[0][1]:.4f})")
        print(f"  Least diverse: {results[-1][0]} (witness={results[-1][1]:.4f})")


# ──────────────────────────────────────────────────
# Application 3: Network Community Detection
# ──────────────────────────────────────────────────

def app_network_communities():
    """
    Detect communities in networks using spectral leaf witnesses.
    
    For a graph with adjacency matrix A, the normalized Laplacian L
    generates a DPP polynomial. Leaf witnesses on vertex subsets
    detect community structure beyond pairwise edge analysis.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Network Community Detection")
    print("=" * 70)
    
    np.random.seed(13)
    n = 6
    
    # Construct a graph with two communities: {0,1,2} and {3,4,5}
    # Strong intra-community edges, weak inter-community edges
    A = np.zeros((n, n))
    # Community 1: {0,1,2}
    for i, j in combinations([0, 1, 2], 2):
        A[i, j] = A[j, i] = 0.9
    # Community 2: {3,4,5}
    for i, j in combinations([3, 4, 5], 2):
        A[i, j] = A[j, i] = 0.8
    # Inter-community (weak)
    A[0, 3] = A[3, 0] = 0.1
    A[1, 4] = A[4, 1] = 0.1
    
    # Normalized Laplacian: L = D^{-1/2} (D - A) D^{-1/2}
    D = np.diag(A.sum(axis=1))
    D_inv_sqrt = np.diag(1.0 / np.sqrt(np.maximum(A.sum(axis=1), 1e-10)))
    L = D_inv_sqrt @ (D - A) @ D_inv_sqrt
    
    # Use pseudoinverse of Laplacian as kernel (for DPP)
    eigvals, eigvecs = np.linalg.eigh(L)
    # Regularize: use L + epsilon * I as kernel
    K = L + 0.1 * np.eye(n)
    
    print(f"\nGraph adjacency ({n} nodes, 2 communities):")
    print(np.round(A, 2))
    
    Z = build_dpp_poly(K)
    
    print("\n--- Community Detection via Leaf Witnesses ---")
    print("\nTripartite subsets:")
    results = []
    for subset in combinations(range(n), 3):
        A_set = set(subset)
        w = leaf_witness(Z, A_set)
        results.append((A_set, w))
    
    results.sort(key=lambda x: -x[1])
    for A_set, w in results:
        label = ""
        if A_set <= {0, 1, 2}:
            label = " [Community 1]"
        elif A_set <= {3, 4, 5}:
            label = " [Community 2]"
        else:
            label = " [Cross-community]"
        print(f"  {A_set}: witness={w:.4f}{label}")
    
    print("\n  Interpretation: Higher witnesses for intra-community subsets")
    print("  indicate stronger collective correlation within communities.")


# ──────────────────────────────────────────────────
# Application 4: Random Matrix Universality
# ──────────────────────────────────────────────────

def app_random_matrix():
    """
    Study universality of leaf witness distributions across
    random matrix ensembles.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Random Matrix Universality")
    print("=" * 70)
    
    n = 5
    n_trials = 50
    
    ensembles = {
        'GOE': lambda: (lambda G: (G + G.T) / (2 * np.sqrt(n)))(np.random.randn(n, n)),
        'Wishart': lambda: (lambda G: G @ G.T / n)(np.random.randn(n, n)),
        'Diagonal': lambda: np.diag(np.abs(np.random.randn(n))),
    }
    
    for name, gen in ensembles.items():
        witnesses_3 = []
        lorentzian_violations = 0
        
        for _ in range(n_trials):
            K = gen()
            # Ensure PSD
            eigvals = np.linalg.eigvalsh(K)
            if np.min(eigvals) < 0:
                K = K - np.min(eigvals) * np.eye(n) + 0.01 * np.eye(n)
            
            Z = build_dpp_poly(K)
            
            for A in combinations(range(n), 3):
                A_set = set(A)
                leaf = derivative_leaf(Z, A_set)
                H = mixed_hessian_at_ones(leaf, A_set)
                eigs = np.linalg.eigvalsh(H)
                n_pos = np.sum(eigs > 1e-8)
                
                if n_pos > 1:
                    lorentzian_violations += 1
                
                witnesses_3.append(max(eigs[-1], 0))
        
        witnesses_3 = np.array(witnesses_3)
        print(f"\n  {name} ensemble ({n_trials} trials):")
        print(f"    Mean 3-body witness: {witnesses_3.mean():.4f}")
        print(f"    Std 3-body witness:  {witnesses_3.std():.4f}")
        print(f"    Max 3-body witness:  {witnesses_3.max():.4f}")
        print(f"    Lorentzian violations: {lorentzian_violations}")


if __name__ == "__main__":
    app_quantum_entanglement()
    app_ml_diversity()
    app_network_communities()
    app_random_matrix()
    
    print("\n" + "=" * 70)
    print("All applications complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demo: Multi-Mode Lorentzian Witnesses via Higher Derivative Leaves

This script demonstrates the core constructions of multi-mode Lorentzian
witness theory:
  1. Computing derivative leaves of multivariate polynomials
  2. Building mixed Hessian matrices at the all-ones point
  3. Computing spectral witnesses (top eigenvalue)
  4. Comparing pairwise vs. higher-order witnesses

Usage:
    python demo.py
"""

import numpy as np
from itertools import combinations
from typing import Dict, Tuple, List, Optional
from numpy.polynomial.polynomial import polyadd


# ─────────────────────────────────────────────────
# §1. Core Data Structures
# ─────────────────────────────────────────────────

class MvPoly:
    """
    Multivariate polynomial represented as a dictionary
    mapping exponent tuples to coefficients.
    
    Example: x0^2 * x1 + 3*x2 would be:
        {(2,1,0): 1.0, (0,0,1): 3.0}
    """
    def __init__(self, n_vars: int, terms: Optional[Dict[Tuple[int,...], float]] = None):
        self.n = n_vars
        self.terms = terms or {}
    
    def __add__(self, other):
        result = MvPoly(self.n, dict(self.terms))
        for exp, coeff in other.terms.items():
            result.terms[exp] = result.terms.get(exp, 0.0) + coeff
        # Clean up zero terms
        result.terms = {k: v for k, v in result.terms.items() if abs(v) > 1e-15}
        return result
    
    def __mul__(self, other):
        result = MvPoly(self.n)
        for e1, c1 in self.terms.items():
            for e2, c2 in other.terms.items():
                new_exp = tuple(a + b for a, b in zip(e1, e2))
                result.terms[new_exp] = result.terms.get(new_exp, 0.0) + c1 * c2
        result.terms = {k: v for k, v in result.terms.items() if abs(v) > 1e-15}
        return result
    
    def __rmul__(self, scalar):
        return MvPoly(self.n, {k: scalar * v for k, v in self.terms.items()})
    
    def partial(self, var: int):
        """Partial derivative with respect to variable `var`."""
        result = MvPoly(self.n)
        for exp, coeff in self.terms.items():
            if exp[var] > 0:
                new_exp = list(exp)
                new_coeff = coeff * exp[var]
                new_exp[var] -= 1
                result.terms[tuple(new_exp)] = result.terms.get(tuple(new_exp), 0.0) + new_coeff
        result.terms = {k: v for k, v in result.terms.items() if abs(v) > 1e-15}
        return result
    
    def eval_at(self, point: np.ndarray) -> float:
        """Evaluate the polynomial at a given point."""
        total = 0.0
        for exp, coeff in self.terms.items():
            total += coeff * np.prod([point[i]**exp[i] for i in range(self.n)])
        return total
    
    def eval_at_ones(self) -> float:
        """Evaluate at the all-ones point."""
        return self.eval_at(np.ones(self.n))
    
    def has_nonneg_coeffs(self) -> bool:
        """Check if all coefficients are nonneg."""
        return all(c >= -1e-15 for c in self.terms.values())
    
    def total_degree(self) -> int:
        """Maximum total degree."""
        if not self.terms:
            return 0
        return max(sum(e) for e in self.terms.keys())
    
    def __repr__(self):
        if not self.terms:
            return "0"
        parts = []
        for exp, coeff in sorted(self.terms.items()):
            monomial = " * ".join(f"x{i}^{e}" for i, e in enumerate(exp) if e > 0)
            if not monomial:
                monomial = "1"
            parts.append(f"{coeff:.4g} * {monomial}")
        return " + ".join(parts)


def X(n_vars: int, var: int) -> MvPoly:
    """Create the polynomial x_var in n_vars variables."""
    exp = tuple(1 if i == var else 0 for i in range(n_vars))
    return MvPoly(n_vars, {exp: 1.0})


def C(n_vars: int, value: float) -> MvPoly:
    """Create a constant polynomial."""
    exp = tuple(0 for _ in range(n_vars))
    return MvPoly(n_vars, {exp: value})


# ─────────────────────────────────────────────────
# §2. Derivative Leaf Construction
# ─────────────────────────────────────────────────

def derivative_leaf(p: MvPoly, subset_A: set) -> MvPoly:
    """
    Compute the derivative leaf L_A(x) = (∏_{i ∉ A} ∂_i) p(x).
    
    Differentiates p once in each variable NOT in the subset A.
    The result is a polynomial whose degree is concentrated on A.
    """
    result = p
    complement = sorted(set(range(p.n)) - subset_A)
    for var in complement:
        result = result.partial(var)
    return result


# ─────────────────────────────────────────────────
# §3. Mixed Hessian at Ones
# ─────────────────────────────────────────────────

def mixed_hessian_at_ones(p: MvPoly, subset_A: set) -> np.ndarray:
    """
    Compute the mixed Hessian matrix of p restricted to variables in A,
    evaluated at the all-ones point.
    
    H[i,j] = eval_1(∂²p / ∂x_i ∂x_j)
    
    where i, j range over the elements of A.
    """
    indices = sorted(subset_A)
    k = len(indices)
    H = np.zeros((k, k))
    
    for a, i in enumerate(indices):
        for b, j in enumerate(indices):
            second_deriv = p.partial(i).partial(j)
            H[a, b] = second_deriv.eval_at_ones()
    
    return H


# ─────────────────────────────────────────────────
# §4. Spectral Witnesses
# ─────────────────────────────────────────────────

def positive_spectral_witness(M: np.ndarray) -> float:
    """
    Compute the positive spectral witness of a symmetric matrix.
    Returns the largest eigenvalue if positive, else 0.
    """
    eigenvalues = np.linalg.eigvalsh(M)
    top = eigenvalues[-1]
    return max(top, 0.0)


def positive_spectral_witness_proxy(M: np.ndarray) -> float:
    """
    Computable proxy: max(trace(M), 0).
    Matches the Lean formalization.
    """
    return max(np.trace(M), 0.0)


def leaf_witness(p: MvPoly, subset_A: set) -> float:
    """
    Compute the leaf witness for a polynomial p and subset A.
    This combines derivative leaf + mixed Hessian + spectral witness.
    """
    leaf = derivative_leaf(p, subset_A)
    H = mixed_hessian_at_ones(leaf, subset_A)
    return positive_spectral_witness(H)


def leaf_witness_proxy(p: MvPoly, subset_A: set) -> float:
    """
    Compute the leaf witness proxy (trace-based, matching Lean formalization).
    """
    leaf = derivative_leaf(p, subset_A)
    H = mixed_hessian_at_ones(leaf, subset_A)
    return positive_spectral_witness_proxy(H)


def pairwise_leaf_witness(p: MvPoly, i: int, j: int) -> float:
    """
    Compute the pairwise leaf witness for variables i and j.
    This is the square of the mixed partial evaluation at ones
    after taking the derivative leaf for {i,j}.
    """
    leaf = derivative_leaf(p, {i, j})
    val = leaf.partial(i).partial(j).eval_at_ones()
    return val ** 2


# ─────────────────────────────────────────────────
# §5. DPP Polynomial Construction
# ─────────────────────────────────────────────────

def dpp_partition_polynomial(K: np.ndarray) -> MvPoly:
    """
    Construct the DPP partition polynomial Z_K(x) = det(I + diag(x) * K).
    
    For an n×n kernel K, this is a polynomial in n variables whose
    coefficients are principal minors of K.
    """
    n = K.shape[0]
    result = MvPoly(n)
    
    # Z_K = sum over S of det(K_S) * prod_{i in S} x_i
    for size in range(n + 1):
        for S in combinations(range(n), size):
            # Compute principal minor det(K_S)
            if len(S) == 0:
                minor = 1.0
            else:
                submat = K[np.ix_(list(S), list(S))]
                minor = np.linalg.det(submat)
            
            exp = tuple(1 if i in S else 0 for i in range(n))
            result.terms[exp] = result.terms.get(exp, 0.0) + minor
    
    result.terms = {k: v for k, v in result.terms.items() if abs(v) > 1e-15}
    return result


def principal_minor(K: np.ndarray, S: set) -> float:
    """Compute the principal minor det(K_S)."""
    if len(S) == 0:
        return 1.0
    indices = sorted(S)
    return np.linalg.det(K[np.ix_(indices, indices)])


# ─────────────────────────────────────────────────
# §6. Main Demonstration
# ─────────────────────────────────────────────────

def demo_basic():
    """Basic demonstration of derivative leaf construction."""
    print("=" * 70)
    print("DEMO 1: Derivative Leaf Construction")
    print("=" * 70)
    
    n = 4
    # p = x0 * x1 * x2 * x3 (product of all variables)
    p = X(n, 0) * X(n, 1) * X(n, 2) * X(n, 3)
    
    print(f"\nPolynomial p = x0 * x1 * x2 * x3 (n={n} variables)")
    print(f"Total degree: {p.total_degree()}")
    print(f"Nonneg coefficients: {p.has_nonneg_coeffs()}")
    
    # Compute derivative leaves for different subsets
    for k in range(1, n + 1):
        for A in combinations(range(n), k):
            A_set = set(A)
            leaf = derivative_leaf(p, A_set)
            print(f"\n  Leaf L_{set(A)}: {leaf}")
            print(f"    Degree: {leaf.total_degree()}")
            if k >= 2:
                H = mixed_hessian_at_ones(leaf, A_set)
                eigs = np.linalg.eigvalsh(H)
                n_pos = np.sum(eigs > 1e-10)
                print(f"    Mixed Hessian eigenvalues: {eigs}")
                print(f"    Positive eigenvalues: {n_pos}")
                print(f"    Leaf witness (spectral): {positive_spectral_witness(H):.6f}")
                print(f"    Leaf witness (proxy): {positive_spectral_witness_proxy(H):.6f}")


def demo_dpp():
    """Demonstration with DPP polynomials from random PSD kernels."""
    print("\n" + "=" * 70)
    print("DEMO 2: DPP Polynomial Derivative Leaves")
    print("=" * 70)
    
    np.random.seed(42)
    n = 4
    
    # Generate a random PSD kernel
    A = np.random.randn(n, n)
    K = A @ A.T / n  # PSD by construction
    
    print(f"\nKernel K (n={n}):")
    print(np.round(K, 4))
    print(f"\nEigenvalues of K: {np.round(np.linalg.eigvalsh(K), 4)}")
    
    # Construct DPP polynomial
    Z = dpp_partition_polynomial(K)
    print(f"\nDPP polynomial Z_K has {len(Z.terms)} terms")
    print(f"Nonneg coefficients: {Z.has_nonneg_coeffs()}")
    
    # Analyze derivative leaves
    print("\n--- Leaf Witnesses ---")
    for k in [2, 3]:
        print(f"\n  Subsets of size {k}:")
        for A in combinations(range(n), k):
            A_set = set(A)
            leaf = derivative_leaf(Z, A_set)
            H = mixed_hessian_at_ones(leaf, A_set)
            eigs = np.linalg.eigvalsh(H)
            n_pos = np.sum(eigs > 1e-10)
            witness = positive_spectral_witness(H)
            proxy = positive_spectral_witness_proxy(H)
            print(f"    A={set(A)}: eigenvalues={np.round(eigs, 4)}, "
                  f"#pos={n_pos}, witness={witness:.4f}, proxy={proxy:.4f}")


def demo_separation():
    """
    Demonstrate the multipartite separation phenomenon:
    find cases where the higher leaf witness detects structure
    that pairwise witnesses miss.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Pairwise vs. Higher-Order Witness Comparison")
    print("=" * 70)
    
    np.random.seed(123)
    
    for trial in range(5):
        n = 6
        # Random PSD kernel with specific structure
        A = np.random.randn(n, 3)  # Low-rank factor
        K = A @ A.T / n
        
        Z = dpp_partition_polynomial(K)
        
        print(f"\n--- Trial {trial + 1} (n={n}) ---")
        
        # Check size-3 subsets
        best_ratio = 0
        best_A = None
        
        for subset in combinations(range(n), 3):
            A_set = set(subset)
            
            # Higher-order witness
            higher_w = leaf_witness(Z, A_set)
            
            # All pairwise witnesses within this subset
            pairwise_ws = []
            for i, j in combinations(subset, 2):
                pw = pairwise_leaf_witness(Z, i, j)
                pairwise_ws.append(pw)
            
            max_pairwise = max(pairwise_ws) if pairwise_ws else 0
            
            if max_pairwise > 1e-10:
                ratio = higher_w / max_pairwise
                if ratio > best_ratio:
                    best_ratio = ratio
                    best_A = A_set
                    best_higher = higher_w
                    best_pair = max_pairwise
        
        if best_A is not None:
            print(f"  Best separation subset: {best_A}")
            print(f"  Higher witness: {best_higher:.6f}")
            print(f"  Max pairwise witness: {best_pair:.6f}")
            print(f"  Ratio (higher/pairwise): {best_ratio:.4f}")
        else:
            print("  No significant separation found")


def demo_spectral_signature():
    """
    Demonstrate the Lorentzian spectral signature:
    show that leaf Hessians have at most one positive eigenvalue
    for DPP polynomials from PSD kernels.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Lorentzian Spectral Signature Verification")
    print("=" * 70)
    
    np.random.seed(7)
    
    for trial in range(3):
        n = 5
        A = np.random.randn(n, n)
        K = A @ A.T / n
        
        Z = dpp_partition_polynomial(K)
        
        print(f"\n--- Trial {trial + 1} (n={n}) ---")
        
        max_pos_eigs = 0
        for k in [2, 3, 4]:
            for subset in combinations(range(n), k):
                A_set = set(subset)
                leaf = derivative_leaf(Z, A_set)
                H = mixed_hessian_at_ones(leaf, A_set)
                eigs = np.linalg.eigvalsh(H)
                n_pos = np.sum(eigs > 1e-8)
                max_pos_eigs = max(max_pos_eigs, n_pos)
                
                if n_pos > 1:
                    print(f"  WARNING: A={set(subset)}, "
                          f"eigenvalues={np.round(eigs, 6)}, #pos={n_pos}")
        
        if max_pos_eigs <= 1:
            print(f"  ✓ All leaf Hessians have ≤ 1 positive eigenvalue")
        else:
            print(f"  ✗ Found Hessian with {max_pos_eigs} positive eigenvalues")


def demo_principal_minors():
    """
    Demonstrate the coefficient–minor bridge:
    show that derivative leaf coefficients are determined by principal minors.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Coefficient–Minor Bridge")
    print("=" * 70)
    
    n = 4
    np.random.seed(99)
    A = np.random.randn(n, n)
    K = A @ A.T / n
    
    print(f"\nKernel K (n={n}):")
    print(np.round(K, 4))
    
    Z = dpp_partition_polynomial(K)
    
    print("\nPrincipal minors:")
    for size in range(n + 1):
        for S in combinations(range(n), size):
            pm = principal_minor(K, set(S))
            print(f"  det(K_{set(S)}) = {pm:.6f}")
    
    print("\nDerivative leaf coefficients (A = {0,1,2}):")
    A_set = {0, 1, 2}
    leaf = derivative_leaf(Z, A_set)
    for exp, coeff in sorted(leaf.terms.items()):
        if abs(coeff) > 1e-15:
            print(f"  {exp}: {coeff:.6f}")
    
    # Show Hessian entries
    H = mixed_hessian_at_ones(leaf, A_set)
    print(f"\nMixed Hessian at ones:")
    print(np.round(H, 4))
    print(f"Eigenvalues: {np.round(np.linalg.eigvalsh(H), 4)}")


if __name__ == "__main__":
    demo_basic()
    demo_dpp()
    demo_separation()
    demo_spectral_signature()
    demo_principal_minors()
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Hessian Spectral Signatures of Derivative Leaves

Visualizes the eigenvalue distributions of mixed Hessian matrices
computed from derivative leaves of DPP polynomials. Demonstrates
the Lorentzian spectral constraint: at most one positive eigenvalue.

Output: hessian_spectrum.png
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# ── Self-contained polynomial infrastructure ──

class MvPoly:
    def __init__(self, n, terms=None):
        self.n = n
        self.terms = {k: v for k, v in (terms or {}).items() if abs(v) > 1e-15}

    def partial(self, var):
        r = MvPoly(self.n)
        for exp, c in self.terms.items():
            if exp[var] > 0:
                ne = list(exp); ne[var] -= 1; ne = tuple(ne)
                r.terms[ne] = r.terms.get(ne, 0) + c * exp[var]
        return r

    def eval_ones(self):
        return sum(self.terms.values())


def build_dpp(K):
    n = K.shape[0]
    p = MvPoly(n)
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            minor = 1.0 if len(S) == 0 else np.linalg.det(K[np.ix_(list(S), list(S))])
            exp = tuple(1 if i in S else 0 for i in range(n))
            p.terms[exp] = p.terms.get(exp, 0) + minor
    p.terms = {k: v for k, v in p.terms.items() if abs(v) > 1e-15}
    return p


def deriv_leaf(p, A):
    r = p
    for v in sorted(set(range(p.n)) - A):
        r = r.partial(v)
    return r


def hessian_ones(p, A):
    idx = sorted(A)
    k = len(idx)
    H = np.zeros((k, k))
    for a, i in enumerate(idx):
        pi = p.partial(i)
        for b, j in enumerate(idx):
            H[a, b] = pi.partial(j).eval_ones()
    return H


# ── Generate data ──

np.random.seed(42)
n = 5
n_trials = 200

all_eigs_2 = []
all_eigs_3 = []
all_eigs_4 = []

for trial in range(n_trials):
    G = np.random.randn(n, n)
    K = G @ G.T / n
    Z = build_dpp(K)

    for A in combinations(range(n), 2):
        leaf = deriv_leaf(Z, set(A))
        H = hessian_ones(leaf, set(A))
        all_eigs_2.extend(np.linalg.eigvalsh(H).tolist())

    for A in combinations(range(n), 3):
        leaf = deriv_leaf(Z, set(A))
        H = hessian_ones(leaf, set(A))
        all_eigs_3.extend(np.linalg.eigvalsh(H).tolist())

    for A in combinations(range(n), 4):
        leaf = deriv_leaf(Z, set(A))
        H = hessian_ones(leaf, set(A))
        all_eigs_4.extend(np.linalg.eigvalsh(H).tolist())

all_eigs_2 = np.array(all_eigs_2)
all_eigs_3 = np.array(all_eigs_3)
all_eigs_4 = np.array(all_eigs_4)

# ── Plot ──

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for ax, eigs, k, color in [
    (axes[0], all_eigs_2, 2, '#2196F3'),
    (axes[1], all_eigs_3, 3, '#FF9800'),
    (axes[2], all_eigs_4, 4, '#4CAF50'),
]:
    ax.hist(eigs, bins=80, density=True, alpha=0.7, color=color, edgecolor='white', linewidth=0.5)
    ax.axvline(x=0, color='red', linestyle='--', linewidth=1.5, alpha=0.8)
    ax.set_xlabel('Eigenvalue', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title(f'Leaf Hessian Eigenvalues (|A|={k})', fontsize=13, fontweight='bold')

    n_pos = np.sum(eigs > 1e-8)
    n_neg = np.sum(eigs < -1e-8)
    n_zero = len(eigs) - n_pos - n_neg
    ax.text(0.95, 0.95, f'n={len(eigs)}\npos: {n_pos}\nneg: {n_neg}\nzero: {n_zero}',
            transform=ax.transAxes, fontsize=9, verticalalignment='top',
            horizontalalignment='right',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

fig.suptitle('Lorentzian Spectral Signature: Derivative Leaf Hessians\n'
             f'(n={n} variables, {n_trials} random PSD kernels)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('hessian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved hessian_spectrum.png")


#!/usr/bin/env python3
"""
Visualization: Derivative Leaf Hierarchy Heatmap

Shows the hierarchical structure of leaf witnesses across different
subset sizes and specific subsets for a fixed DPP kernel.
Demonstrates how Lorentzian geometry organizes multi-mode correlations.

Output: leaf_hierarchy.png
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# ── Self-contained polynomial infrastructure ──

class MvPoly:
    def __init__(self, n, terms=None):
        self.n = n
        self.terms = {k: v for k, v in (terms or {}).items() if abs(v) > 1e-15}

    def partial(self, var):
        r = MvPoly(self.n)
        for exp, c in self.terms.items():
            if exp[var] > 0:
                ne = list(exp); ne[var] -= 1; ne = tuple(ne)
                r.terms[ne] = r.terms.get(ne, 0) + c * exp[var]
        return r

    def eval_ones(self):
        return sum(self.terms.values())


def build_dpp(K):
    n = K.shape[0]
    p = MvPoly(n)
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            minor = 1.0 if len(S) == 0 else np.linalg.det(K[np.ix_(list(S), list(S))])
            exp = tuple(1 if i in S else 0 for i in range(n))
            p.terms[exp] = p.terms.get(exp, 0) + minor
    p.terms = {k: v for k, v in p.terms.items() if abs(v) > 1e-15}
    return p


def deriv_leaf(p, A):
    r = p
    for v in sorted(set(range(p.n)) - A):
        r = r.partial(v)
    return r


def hessian_ones(p, A):
    idx = sorted(A)
    k = len(idx)
    H = np.zeros((k, k))
    for a, i in enumerate(idx):
        pi = p.partial(i)
        for b, j in enumerate(idx):
            H[a, b] = pi.partial(j).eval_ones()
    return H


def leaf_witness_full(p, A):
    """Returns (witness, eigenvalues, hessian)."""
    leaf = deriv_leaf(p, A)
    H = hessian_ones(leaf, A)
    eigs = np.linalg.eigvalsh(H)
    return max(eigs[-1], 0), eigs, H


# ── Build kernel with structured correlations ──

np.random.seed(42)
n = 6

# Block-structured kernel with 2 communities
K = np.zeros((n, n))
# Community 1: {0,1,2} — strong correlations
for i in range(3):
    K[i, i] = 2.0
for i, j in combinations(range(3), 2):
    K[i, j] = K[j, i] = 1.5

# Community 2: {3,4,5} — moderate correlations
for i in range(3, 6):
    K[i, i] = 1.5
for i, j in combinations(range(3, 6), 2):
    K[i, j] = K[j, i] = 0.8

# Cross-community: weak
K[0, 3] = K[3, 0] = 0.2
K[1, 4] = K[4, 1] = 0.15

# Make PSD
eigvals = np.linalg.eigvalsh(K)
if np.min(eigvals) < 0:
    K -= np.min(eigvals) * np.eye(n) - 0.01 * np.eye(n)

Z = build_dpp(K)

# ── Compute all witnesses ──

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Hessian heatmaps for selected subsets
selected_subsets = [
    ({0, 1, 2}, "Community 1: {0,1,2}"),
    ({3, 4, 5}, "Community 2: {3,4,5}"),
    ({0, 1, 3}, "Cross: {0,1,3}"),
    ({0, 3, 5}, "Cross: {0,3,5}"),
]

for idx, (A_set, label) in enumerate(selected_subsets):
    ax = axes[idx // 2][idx % 2]
    w, eigs, H = leaf_witness_full(Z, A_set)

    im = ax.imshow(H, cmap='RdBu_r', aspect='equal',
                   vmin=-np.abs(H).max(), vmax=np.abs(H).max())
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Annotate entries
    for i in range(H.shape[0]):
        for j in range(H.shape[1]):
            ax.text(j, i, f'{H[i,j]:.2f}', ha='center', va='center',
                    fontsize=10, fontweight='bold',
                    color='white' if abs(H[i,j]) > np.abs(H).max() * 0.6 else 'black')

    ax.set_title(f'{label}\nWitness={w:.2f}, λ={np.round(eigs, 2)}',
                 fontsize=11, fontweight='bold')
    labels = sorted(A_set)
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels([f'x{l}' for l in labels])
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels([f'x{l}' for l in labels])

fig.suptitle('Mixed Hessian Matrices of Derivative Leaves\n'
             f'(n={n}, Block-Structured DPP Kernel)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('leaf_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved leaf_hierarchy.png")


#!/usr/bin/env python3
"""
Visualization: Pairwise vs. Higher-Order Witness Comparison

Creates a scatter plot comparing the maximum pairwise leaf witness
against the tripartite leaf witness for randomly generated DPP polynomials.
Points above the diagonal demonstrate multipartite separation.

Output: witness_comparison.png
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# ── Self-contained polynomial infrastructure ──

class MvPoly:
    def __init__(self, n, terms=None):
        self.n = n
        self.terms = {k: v for k, v in (terms or {}).items() if abs(v) > 1e-15}

    def partial(self, var):
        r = MvPoly(self.n)
        for exp, c in self.terms.items():
            if exp[var] > 0:
                ne = list(exp); ne[var] -= 1; ne = tuple(ne)
                r.terms[ne] = r.terms.get(ne, 0) + c * exp[var]
        return r

    def eval_ones(self):
        return sum(self.terms.values())


def build_dpp(K):
    n = K.shape[0]
    p = MvPoly(n)
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            minor = 1.0 if len(S) == 0 else np.linalg.det(K[np.ix_(list(S), list(S))])
            exp = tuple(1 if i in S else 0 for i in range(n))
            p.terms[exp] = p.terms.get(exp, 0) + minor
    p.terms = {k: v for k, v in p.terms.items() if abs(v) > 1e-15}
    return p


def deriv_leaf(p, A):
    r = p
    for v in sorted(set(range(p.n)) - A):
        r = r.partial(v)
    return r


def hessian_ones(p, A):
    idx = sorted(A)
    k = len(idx)
    H = np.zeros((k, k))
    for a, i in enumerate(idx):
        pi = p.partial(i)
        for b, j in enumerate(idx):
            H[a, b] = pi.partial(j).eval_ones()
    return H


def leaf_witness(p, A):
    leaf = deriv_leaf(p, A)
    H = hessian_ones(leaf, A)
    return max(np.linalg.eigvalsh(H)[-1], 0) if H.shape[0] > 0 else 0

def pw_witness(p, i, j):
    leaf = deriv_leaf(p, {i, j})
    return leaf.partial(i).partial(j).eval_ones() ** 2


# ── Generate comparison data ──

np.random.seed(2024)
n_vars = 6
n_trials = 300

higher_witnesses = []
max_pairwise_witnesses = []
subset_sizes = []

for trial in range(n_trials):
    G = np.random.randn(n_vars, max(2, np.random.randint(1, n_vars + 1)))
    K = G @ G.T / n_vars

    Z = build_dpp(K)

    for A_tuple in combinations(range(n_vars), 3):
        A_set = set(A_tuple)
        hw = leaf_witness(Z, A_set)

        pws = [pw_witness(Z, i, j) for i, j in combinations(A_tuple, 2)]
        mpw = max(pws) if pws else 0

        higher_witnesses.append(hw)
        max_pairwise_witnesses.append(mpw)
        subset_sizes.append(3)

higher_witnesses = np.array(higher_witnesses)
max_pairwise_witnesses = np.array(max_pairwise_witnesses)

# ── Plot ──

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Scatter plot
mask_nonzero = (max_pairwise_witnesses > 1e-10) & (higher_witnesses > 1e-10)
hw_nz = higher_witnesses[mask_nonzero]
mpw_nz = max_pairwise_witnesses[mask_nonzero]

scatter = ax1.scatter(mpw_nz, hw_nz, c=hw_nz / (mpw_nz + 1e-15),
                       cmap='plasma', alpha=0.5, s=15, edgecolors='none')
cbar = plt.colorbar(scatter, ax=ax1)
cbar.set_label('Ratio (higher / pairwise)', fontsize=10)

# Diagonal line
lim = max(hw_nz.max(), mpw_nz.max()) * 1.1
ax1.plot([0, lim], [0, lim], 'k--', alpha=0.3, linewidth=1)
ax1.set_xlabel('Max Pairwise Witness', fontsize=12)
ax1.set_ylabel('Tripartite Leaf Witness', fontsize=12)
ax1.set_title('Pairwise vs. Higher-Order Witnesses\n(|A|=3, n=6)', fontsize=13, fontweight='bold')
ax1.set_xlim(0, lim)
ax1.set_ylim(0, lim)

# Ratio histogram
ratios = hw_nz / (mpw_nz + 1e-15)
ax2.hist(np.log10(ratios + 1e-15), bins=60, density=True, alpha=0.7,
         color='#9C27B0', edgecolor='white', linewidth=0.5)
ax2.axvline(x=0, color='red', linestyle='--', linewidth=1.5, alpha=0.8, label='Equal (ratio=1)')
ax2.set_xlabel('log₁₀(Higher / Pairwise)', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Distribution of Witness Ratios', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)

n_above = np.sum(ratios > 1.0)
n_below = np.sum(ratios <= 1.0)
ax2.text(0.95, 0.95, f'Higher > Pairwise: {n_above}\nHigher ≤ Pairwise: {n_below}',
         transform=ax2.transAxes, fontsize=10, verticalalignment='top',
         horizontalalignment='right',
         bbox=dict(boxstyle='round', facecolor='lavender', alpha=0.8))

fig.suptitle('Multipartite Separation: When Higher-Order Witnesses See More',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('witness_comparison.png', dpi=150, bbox_inches='tight')
print("Saved witness_comparison.png")
