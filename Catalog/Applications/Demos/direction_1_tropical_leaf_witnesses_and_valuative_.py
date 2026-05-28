"""
Applications of Tropical Leaf Witness Theory
=============================================

Demonstrates real-world applications:
1. Diversity certification in subset selection (DPP)
2. Correlation detection beyond pairwise methods
3. Algorithmic witness extraction from polynomial data
"""

import numpy as np
from itertools import combinations
from fractions import Fraction


# Self-contained implementations
class MvPoly:
    def __init__(self, n, coeffs=None):
        self.n = n
        self.coeffs = {k: v for k, v in (coeffs or {}).items() if abs(v) > 1e-15}

    def pderiv(self, var):
        new = {}
        for exp, c in self.coeffs.items():
            if exp[var] > 0:
                ne = list(exp); nc = c * exp[var]; ne[var] -= 1
                ne = tuple(ne)
                new[ne] = new.get(ne, 0.0) + nc
        return MvPoly(self.n, new)

    def eval_ones(self):
        return sum(self.coeffs.values())

    def coeff_abs_sum(self):
        return sum(abs(c) for c in self.coeffs.values())


def derivative_leaf(p, A):
    result = p
    for i in range(p.n):
        if i not in A:
            result = result.pderiv(i)
    return result


def tropical_leaf_witness(p, A):
    leaf = derivative_leaf(p, A)
    return sum(leaf.pderiv(a).pderiv(a).coeff_abs_sum() for a in A)


def leaf_witness_spectral(p, A):
    leaf = derivative_leaf(p, A)
    tr = sum(leaf.pderiv(a).pderiv(a).eval_ones() for a in A)
    return max(tr, 0.0)


def dpp_polynomial(K):
    n = K.shape[0]
    coeffs = {}
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            det_v = float(np.linalg.det(K[np.ix_(list(S), list(S))])) if S else 1.0
            if abs(det_v) > 1e-15:
                coeffs[tuple(1 if i in S else 0 for i in range(n))] = det_v
    return MvPoly(n, coeffs)


# =============================================================================
# Application 1: DPP Diversity Certification
# =============================================================================

def diversity_certification(K, threshold=0.5):
    """Certify diversity of a DPP kernel using tropical witnesses.
    
    For each subset A, the tropical leaf witness provides a certificate
    that the DPP produces diverse subsets. Higher witness values indicate
    stronger curvature (more diversity) in the generating polynomial.
    
    Args:
        K: DPP kernel matrix (symmetric PSD)
        threshold: Minimum acceptable tropical witness value
    
    Returns:
        Dictionary with diversity analysis
    """
    n = K.shape[0]
    p = dpp_polynomial(K)
    
    results = {
        'n': n,
        'kernel_trace': float(np.trace(K)),
        'certified_subsets': [],
        'uncertified_subsets': [],
    }
    
    for size in range(2, min(n + 1, 5)):
        for A_tuple in combinations(range(n), size):
            A = set(A_tuple)
            w_trop = tropical_leaf_witness(p, A)
            w_spec = leaf_witness_spectral(p, A)
            
            entry = {
                'subset': A_tuple,
                'tropical_witness': w_trop,
                'spectral_witness': w_spec,
                'certified': w_trop >= threshold,
            }
            
            if entry['certified']:
                results['certified_subsets'].append(entry)
            else:
                results['uncertified_subsets'].append(entry)
    
    return results


# =============================================================================
# Application 2: Higher-Order Correlation Detection
# =============================================================================

def detect_higher_order_correlations(data_matrix, top_k=5):
    """Detect higher-order correlations using tropical leaf witnesses.
    
    Given a data matrix, constructs a correlation-based DPP kernel
    and uses tropical leaf witnesses to identify subsets with strong
    multipartite correlations beyond pairwise.
    
    Args:
        data_matrix: m × n matrix (m samples, n features)
        top_k: Number of top correlated subsets to return
    
    Returns:
        List of (subset, witness_value) pairs sorted by witness
    """
    # Construct correlation-based PSD kernel
    cov = np.cov(data_matrix.T)
    # Make PSD via eigendecomposition
    eigvals, eigvecs = np.linalg.eigh(cov)
    eigvals = np.maximum(eigvals, 0)
    K = eigvecs @ np.diag(eigvals) @ eigvecs.T
    K = K / (np.trace(K) + 1e-10)
    
    n = K.shape[0]
    p = dpp_polynomial(K)
    
    witness_scores = []
    for size in range(2, min(n + 1, 4)):
        for A_tuple in combinations(range(n), size):
            A = set(A_tuple)
            w = tropical_leaf_witness(p, A)
            witness_scores.append((A_tuple, w))
    
    witness_scores.sort(key=lambda x: -x[1])
    return witness_scores[:top_k]


# =============================================================================
# Application 3: Algorithmic Witness Extraction
# =============================================================================

def extract_witness_certificate(K, A):
    """Extract a complete tropical witness certificate for a subset.
    
    Returns all the data needed to verify the tropical-spectral bound
    without recomputation.
    
    Args:
        K: DPP kernel matrix
        A: Subset of indices (set or tuple)
    
    Returns:
        Certificate dictionary
    """
    A = set(A) if not isinstance(A, set) else A
    p = dpp_polynomial(K)
    leaf = derivative_leaf(p, A)
    
    # Collect second-derivative coefficient data
    hessian_data = {}
    for a in sorted(A):
        dd = leaf.pderiv(a).pderiv(a)
        hessian_data[a] = {
            'coefficients': dict(dd.coeffs),
            'l1_norm': dd.coeff_abs_sum(),
            'eval_at_ones': dd.eval_ones(),
        }
    
    w_spec = max(sum(hd['eval_at_ones'] for hd in hessian_data.values()), 0.0)
    w_trop = sum(hd['l1_norm'] for hd in hessian_data.values())
    
    return {
        'subset': sorted(A),
        'leaf_support_size': len(leaf.coeffs),
        'leaf_coefficients': dict(leaf.coeffs),
        'hessian_data': hessian_data,
        'spectral_witness': w_spec,
        'tropical_witness': w_trop,
        'gap': w_trop - w_spec,
        'bound_verified': w_trop >= w_spec - 1e-10,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: DPP Diversity Certification")
    print("=" * 60)
    
    np.random.seed(42)
    M = np.random.randn(5, 3)
    K = M @ M.T
    K = K / np.trace(K)
    
    results = diversity_certification(K, threshold=0.01)
    print(f"\nKernel: {results['n']}×{results['n']}, trace={results['kernel_trace']:.3f}")
    print(f"Certified subsets: {len(results['certified_subsets'])}")
    print(f"Uncertified subsets: {len(results['uncertified_subsets'])}")
    
    for entry in results['certified_subsets'][:5]:
        print(f"  {entry['subset']}: W_trop={entry['tropical_witness']:.4f} ✓")
    
    print("\n" + "=" * 60)
    print("APPLICATION 2: Higher-Order Correlation Detection")
    print("=" * 60)
    
    np.random.seed(123)
    # Generate data with structured correlations
    n_features = 5
    n_samples = 100
    # Features 0,1,2 are correlated; 3,4 are independent
    base = np.random.randn(n_samples, 1)
    data = np.random.randn(n_samples, n_features) * 0.3
    data[:, 0] += base[:, 0]
    data[:, 1] += base[:, 0] * 0.8
    data[:, 2] += base[:, 0] * 0.6
    
    top_correlated = detect_higher_order_correlations(data, top_k=8)
    print(f"\nTop correlated subsets (n={n_features}):")
    for subset, witness in top_correlated:
        print(f"  {subset}: tropical_witness = {witness:.6f}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 3: Witness Certificate Extraction")
    print("=" * 60)
    
    cert = extract_witness_certificate(K, {0, 1, 2})
    print(f"\nCertificate for A = {cert['subset']}")
    print(f"  Leaf support size: {cert['leaf_support_size']}")
    print(f"  Spectral witness: {cert['spectral_witness']:.6f}")
    print(f"  Tropical witness: {cert['tropical_witness']:.6f}")
    print(f"  Gap: {cert['gap']:.6f}")
    print(f"  Bound verified: {cert['bound_verified']}")


"""
Tropical Leaf Witness — Interactive Demo
=========================================

Demonstrates the core results of tropical leaf witness theory:
1. Computing derivative leaves of multivariate polynomials
2. Extracting tropical (coefficient-based) witnesses
3. Comparing spectral witnesses against tropical bounds
4. DPP specialization with p-adic valuations
5. Submodularity testing for tropical witnesses

Run: python demo.py
"""

import numpy as np
from itertools import combinations
from fractions import Fraction
import sys


# =============================================================================
# Core polynomial engine (self-contained)
# =============================================================================

class MvPoly:
    """Sparse multivariate polynomial."""
    def __init__(self, n, coeffs=None):
        self.n = n
        self.coeffs = {}
        if coeffs:
            for exp, c in coeffs.items():
                if abs(c) > 1e-15:
                    self.coeffs[tuple(exp)] = c

    def pderiv(self, var):
        new = {}
        for exp, c in self.coeffs.items():
            if exp[var] > 0:
                ne = list(exp)
                nc = c * exp[var]
                ne[var] -= 1
                ne = tuple(ne)
                new[ne] = new.get(ne, 0.0) + nc
        return MvPoly(self.n, new)

    def eval_ones(self):
        return sum(self.coeffs.values())

    def coeff_abs_sum(self):
        return sum(abs(c) for c in self.coeffs.values())

    def __add__(self, other):
        nc = dict(self.coeffs)
        for e, c in other.coeffs.items():
            nc[e] = nc.get(e, 0.0) + c
        return MvPoly(self.n, nc)

    def __repr__(self):
        if not self.coeffs:
            return "0"
        parts = []
        for exp, c in sorted(self.coeffs.items()):
            vs = "·".join(f"x{i}^{e}" for i, e in enumerate(exp) if e > 0)
            parts.append(f"{c:.3g}{'·' + vs if vs else ''}")
        return " + ".join(parts[:8]) + ("..." if len(parts) > 8 else "")


def derivative_leaf(p, A):
    """L_A(p) = (∏_{i∉A} ∂_i) p"""
    result = p
    for i in range(p.n):
        if i not in A:
            result = result.pderiv(i)
    return result


def tropical_leaf_witness(p, A):
    """W_trop(p,A) = ∑_{a∈A} ‖∂²L_A/∂x_a²‖₁"""
    leaf = derivative_leaf(p, A)
    return sum(leaf.pderiv(a).pderiv(a).coeff_abs_sum() for a in A)


def leaf_witness_spectral(p, A):
    """W_spec(p,A) = max(tr(H), 0) where H is mixed Hessian of L_A at 1."""
    leaf = derivative_leaf(p, A)
    tr = 0.0
    for a in A:
        dd = leaf.pderiv(a).pderiv(a)
        tr += dd.eval_ones()
    return max(tr, 0.0)


def dpp_polynomial(K):
    """det(I + diag(x)·K) as MvPoly."""
    n = K.shape[0]
    coeffs = {}
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            if len(S) == 0:
                det_v = 1.0
            else:
                sub = K[np.ix_(list(S), list(S))]
                det_v = float(np.linalg.det(sub))
            if abs(det_v) > 1e-15:
                exp = tuple(1 if i in S else 0 for i in range(n))
                coeffs[exp] = det_v
    return MvPoly(n, coeffs)


def p_adic_val(x, p):
    if abs(x) < 1e-12:
        return float('inf')
    frac = Fraction(x).limit_denominator(10**10)
    num, den = abs(frac.numerator), frac.denominator
    v = 0
    while num and num % p == 0: v += 1; num //= p
    while den and den % p == 0: v -= 1; den //= p
    return v


# =============================================================================
# Demo sections
# =============================================================================

def demo_basic():
    """Demo 1: Basic derivative leaf and witness computation."""
    print("=" * 70)
    print("DEMO 1: Derivative Leaf & Tropical Witness Basics")
    print("=" * 70)
    
    n = 3
    # p = x₀² + x₁² + x₂² + 2x₀x₁ + 2x₁x₂ + 2x₀x₂
    p = MvPoly(n, {
        (2,0,0): 1, (0,2,0): 1, (0,0,2): 1,
        (1,1,0): 2, (0,1,1): 2, (1,0,1): 2,
    })
    print(f"\nPolynomial p = {p}")
    print(f"  (This is (x₀+x₁+x₂)²)")
    
    for A_tuple in [(0,1,2), (0,1), (0,), (1,2)]:
        A = set(A_tuple)
        leaf = derivative_leaf(p, A)
        w_spec = leaf_witness_spectral(p, A)
        w_trop = tropical_leaf_witness(p, A)
        gap = w_trop - w_spec
        
        print(f"\n  A = {A_tuple}")
        print(f"    Derivative leaf L_A = {leaf}")
        print(f"    Spectral witness  = {w_spec:.4f}")
        print(f"    Tropical witness  = {w_trop:.4f}")
        print(f"    Gap (≥ 0 by thm)  = {gap:.4f} {'✓' if gap >= -1e-10 else '✗ VIOLATION!'}")


def demo_main_theorem():
    """Demo 2: Verification of the main theorem on random polynomials."""
    print("\n" + "=" * 70)
    print("DEMO 2: Main Theorem Verification (leafWitness ≤ tropicalLeafWitness)")
    print("=" * 70)
    
    np.random.seed(123)
    
    violations = 0
    total_tests = 0
    max_ratio = 0.0
    
    for trial in range(50):
        n = np.random.randint(2, 6)
        # Random polynomial with ~5 terms
        coeffs = {}
        for _ in range(np.random.randint(3, 8)):
            exp = tuple(np.random.randint(0, 4, size=n))
            coeffs[exp] = np.random.randn()
        p = MvPoly(n, coeffs)
        
        for size in range(1, min(n + 1, 4)):
            for A_tuple in combinations(range(n), size):
                A = set(A_tuple)
                w_spec = leaf_witness_spectral(p, A)
                w_trop = tropical_leaf_witness(p, A)
                
                total_tests += 1
                if w_spec > w_trop + 1e-10:
                    violations += 1
                
                if w_spec > 1e-10:
                    ratio = w_trop / w_spec
                    max_ratio = max(max_ratio, ratio)
    
    print(f"\n  Ran {total_tests} tests across 50 random polynomials")
    print(f"  Violations: {violations}")
    print(f"  Max ratio W_trop/W_spec: {max_ratio:.2f}")
    print(f"  Result: {'✓ THEOREM HOLDS' if violations == 0 else '✗ VIOLATIONS FOUND'}")


def demo_dpp():
    """Demo 3: DPP specialization with spectral vs tropical witnesses."""
    print("\n" + "=" * 70)
    print("DEMO 3: DPP Tropical Witnesses")
    print("=" * 70)
    
    for n_val, label in [(4, "small"), (6, "medium")]:
        print(f"\n  --- n = {n_val} ({label}) ---")
        np.random.seed(42 + n_val)
        M = np.random.randn(n_val, max(2, n_val // 2))
        K = M @ M.T
        K = K / np.trace(K)  # Normalize trace to 1
        
        p = dpp_polynomial(K)
        print(f"  DPP polynomial: {len(p.coeffs)} terms")
        
        # Analyze subsets of sizes 2, 3
        for size in [2, 3]:
            gaps = []
            for A_tuple in combinations(range(n_val), size):
                A = set(A_tuple)
                w_spec = leaf_witness_spectral(p, A)
                w_trop = tropical_leaf_witness(p, A)
                gaps.append(w_trop - w_spec)
            
            print(f"  Size-{size} subsets: "
                  f"min_gap={min(gaps):.6f}, "
                  f"max_gap={max(gaps):.6f}, "
                  f"all_hold={all(g >= -1e-10 for g in gaps)} ✓")


def demo_padic():
    """Demo 4: p-adic tropical witnesses and the falsifiable conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 4: p-adic Tropical Witness Conjecture Testing")
    print("=" * 70)
    
    # Use a rational DPP kernel
    n = 4
    # Simple rational PSD matrix
    K = np.array([
        [2, 1, 0, 1],
        [1, 3, 1, 0],
        [0, 1, 2, 1],
        [1, 0, 1, 3],
    ], dtype=float) / 4.0
    
    p = dpp_polynomial(K)
    print(f"\n  Rational DPP kernel (n={n}), trace(K) = {np.trace(K):.3f}")
    
    for prime in [2, 3, 5]:
        print(f"\n  --- p = {prime} ---")
        for size in [2, 3]:
            for A_tuple in combinations(range(n), size):
                A = set(A_tuple)
                w_spec = leaf_witness_spectral(p, A)
                
                # p-adic tropical witness: sum of |v_p(coeff)| 
                leaf = derivative_leaf(p, A)
                w_trop_padic = 0.0
                for a in A:
                    dd = leaf.pderiv(a).pderiv(a)
                    for c in dd.coeffs.values():
                        v = p_adic_val(c, prime)
                        if v != float('inf'):
                            w_trop_padic += abs(v)
                
                log_spec = np.log(w_spec) if w_spec > 1e-15 else -float('inf')
                delta = w_trop_padic - log_spec
                
                status = "✓" if delta >= -1e-10 or w_spec < 1e-15 else "✗ COUNTEREXAMPLE"
                if size <= 2 or A_tuple == list(combinations(range(n), size))[0]:
                    print(f"    A={A_tuple}: log(W_spec)={log_spec:.3f}, "
                          f"W_trop^({prime})={w_trop_padic:.3f}, "
                          f"Δ={delta:.3f} {status}")


def demo_submodularity():
    """Demo 5: Submodularity of tropical leaf witness."""
    print("\n" + "=" * 70)
    print("DEMO 5: Submodularity Test for Tropical Leaf Witness")
    print("=" * 70)
    
    n = 4
    np.random.seed(7)
    M = np.random.randn(n, 3)
    K = M @ M.T
    K = K / np.trace(K)
    
    p = dpp_polynomial(K)
    
    # Compute tropical witness for all subsets
    f = {}
    for size in range(n + 1):
        for A_tuple in combinations(range(n), size):
            A = set(A_tuple)
            f[frozenset(A_tuple)] = tropical_leaf_witness(p, A)
    
    # Test submodularity
    violations = []
    for A_t in f:
        for B_t in f:
            A, B = set(A_t), set(B_t)
            inter = frozenset(A & B)
            union = frozenset(A | B)
            lhs = f[A_t] + f[B_t]
            rhs = f.get(inter, 0.0) + f.get(union, 0.0)
            if lhs < rhs - 1e-10:
                violations.append((A_t, B_t, rhs - lhs))
    
    print(f"\n  Tested all {len(f)} subsets of [4]")
    print(f"  Submodularity violations: {len(violations)}")
    if violations:
        print(f"  (Expected: submodularity may not hold in general)")
        v = violations[0]
        print(f"  Example violation: A={set(v[0])}, B={set(v[1])}, deficit={v[2]:.6f}")
    else:
        print(f"  Result: ✓ SUBMODULAR for this instance!")
    
    # Show witness values
    print(f"\n  Tropical witness values:")
    for A_t in sorted(f.keys(), key=lambda x: (len(x), x)):
        if len(A_t) <= 3:
            print(f"    {set(A_t)}: {f[A_t]:.6f}")


def demo_visualization_data():
    """Demo 6: Generate data for visualization."""
    print("\n" + "=" * 70)
    print("DEMO 6: Witness Gap Landscape")
    print("=" * 70)
    
    n = 5
    np.random.seed(99)
    M = np.random.randn(n, 3)
    K = M @ M.T
    K = K / np.trace(K)
    p = dpp_polynomial(K)
    
    print(f"\n  DPP kernel: {n}×{n}, {len(p.coeffs)} polynomial terms")
    print(f"\n  {'Subset':<20} {'|A|':>4} {'W_spec':>10} {'W_trop':>10} {'Gap':>10} {'Ratio':>8}")
    print(f"  {'-'*62}")
    
    for size in range(1, 4):
        for A_tuple in combinations(range(n), size):
            A = set(A_tuple)
            ws = leaf_witness_spectral(p, A)
            wt = tropical_leaf_witness(p, A)
            gap = wt - ws
            ratio = wt / ws if ws > 1e-15 else float('inf')
            print(f"  {str(A_tuple):<20} {size:>4} {ws:>10.4f} {wt:>10.4f} {gap:>10.4f} {ratio:>8.2f}")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║       TROPICAL LEAF WITNESSES — INTERACTIVE DEMONSTRATION          ║")
    print("║                                                                    ║")
    print("║  Bridging Tropical Geometry and Spectral Witness Theory            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_basic()
    demo_main_theorem()
    demo_dpp()
    demo_padic()
    demo_submodularity()
    demo_visualization_data()
    
    print("\n" + "=" * 70)
    print("All demos complete.")
    print("=" * 70)


"""
Visualization: Witness Gap Landscape
======================================

Shows how the gap W_trop - W_spec varies across different DPP kernels
and subset sizes, confirming the universal bound.

Uses matplotlib to produce a static PNG.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# --- Self-contained polynomial engine ---
class MvPoly:
    def __init__(self, n, coeffs=None):
        self.n = n
        self.coeffs = {k: v for k, v in (coeffs or {}).items() if abs(v) > 1e-15}
    def pderiv(self, var):
        new = {}
        for exp, c in self.coeffs.items():
            if exp[var] > 0:
                ne = list(exp); nc = c * exp[var]; ne[var] -= 1; ne = tuple(ne)
                new[ne] = new.get(ne, 0.0) + nc
        return MvPoly(self.n, new)
    def eval_ones(self):
        return sum(self.coeffs.values())
    def coeff_abs_sum(self):
        return sum(abs(c) for c in self.coeffs.values())

def derivative_leaf(p, A):
    result = p
    for i in range(p.n):
        if i not in A:
            result = result.pderiv(i)
    return result

def tropical_leaf_witness(p, A):
    leaf = derivative_leaf(p, A)
    return sum(leaf.pderiv(a).pderiv(a).coeff_abs_sum() for a in A)

def leaf_witness_spectral(p, A):
    leaf = derivative_leaf(p, A)
    tr = sum(leaf.pderiv(a).pderiv(a).eval_ones() for a in A)
    return max(tr, 0.0)

def dpp_polynomial(K):
    n = K.shape[0]
    coeffs = {}
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            det_v = float(np.linalg.det(K[np.ix_(list(S), list(S))])) if S else 1.0
            if abs(det_v) > 1e-15:
                coeffs[tuple(1 if i in S else 0 for i in range(n))] = det_v
    return MvPoly(n, coeffs)
# --- End polynomial engine ---


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Witness Gap Landscape Across Random DPP Kernels', 
                 fontsize=14, fontweight='bold')
    
    n = 5
    num_trials = 30
    
    for panel_idx, (rank, title) in enumerate([
        (2, 'Low-rank (rank ≈ 2)'),
        (3, 'Medium-rank (rank ≈ 3)'),
        (5, 'Full-rank (rank ≈ 5)'),
    ]):
        ax = axes[panel_idx]
        
        all_sizes = []
        all_gaps = []
        all_ratios = []
        
        for trial in range(num_trials):
            np.random.seed(trial * 100 + rank)
            M = np.random.randn(n, rank)
            K = M @ M.T
            K = K / np.trace(K)
            p = dpp_polynomial(K)
            
            for size in range(1, 4):
                for A_tuple in combinations(range(n), size):
                    A = set(A_tuple)
                    ws = leaf_witness_spectral(p, A)
                    wt = tropical_leaf_witness(p, A)
                    gap = wt - ws
                    all_sizes.append(size + np.random.uniform(-0.15, 0.15))
                    all_gaps.append(gap)
                    if ws > 1e-10:
                        all_ratios.append(wt / ws)
        
        scatter = ax.scatter(all_sizes, all_gaps, alpha=0.3, s=8, 
                           c=all_gaps, cmap='RdYlGn', vmin=-0.1, 
                           vmax=max(all_gaps) * 0.5)
        ax.axhline(y=0, color='red', linestyle='--', linewidth=1.5, 
                   label='Zero line')
        ax.set_title(title, fontsize=11)
        ax.set_xlabel('|A| (subset size)')
        ax.set_ylabel('Gap (W_trop - W_spec)')
        ax.set_xticks([1, 2, 3])
        ax.legend(fontsize=8)
        
        min_gap = min(all_gaps)
        ax.text(0.02, 0.95, f'Min gap: {min_gap:.2e}',
                transform=ax.transAxes, fontsize=9, va='top',
                color='green' if min_gap >= -1e-10 else 'red',
                fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('gap_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved gap_landscape.png")


if __name__ == "__main__":
    main()


"""
Visualization: Tropical vs Spectral Witness Heatmap
====================================================

Visualizes the gap between tropical leaf witnesses and spectral witnesses
across all subsets of a DPP kernel, organized by subset size.
The heatmap confirms the main theorem: W_trop ≥ W_spec everywhere.

Uses matplotlib to produce a static PNG.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# --- Self-contained polynomial engine ---
class MvPoly:
    def __init__(self, n, coeffs=None):
        self.n = n
        self.coeffs = {k: v for k, v in (coeffs or {}).items() if abs(v) > 1e-15}
    def pderiv(self, var):
        new = {}
        for exp, c in self.coeffs.items():
            if exp[var] > 0:
                ne = list(exp); nc = c * exp[var]; ne[var] -= 1; ne = tuple(ne)
                new[ne] = new.get(ne, 0.0) + nc
        return MvPoly(self.n, new)
    def eval_ones(self):
        return sum(self.coeffs.values())
    def coeff_abs_sum(self):
        return sum(abs(c) for c in self.coeffs.values())

def derivative_leaf(p, A):
    result = p
    for i in range(p.n):
        if i not in A:
            result = result.pderiv(i)
    return result

def tropical_leaf_witness(p, A):
    leaf = derivative_leaf(p, A)
    return sum(leaf.pderiv(a).pderiv(a).coeff_abs_sum() for a in A)

def leaf_witness_spectral(p, A):
    leaf = derivative_leaf(p, A)
    tr = sum(leaf.pderiv(a).pderiv(a).eval_ones() for a in A)
    return max(tr, 0.0)

def dpp_polynomial(K):
    n = K.shape[0]
    coeffs = {}
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            det_v = float(np.linalg.det(K[np.ix_(list(S), list(S))])) if S else 1.0
            if abs(det_v) > 1e-15:
                coeffs[tuple(1 if i in S else 0 for i in range(n))] = det_v
    return MvPoly(n, coeffs)
# --- End polynomial engine ---


def main():
    np.random.seed(42)
    n = 6
    M = np.random.randn(n, 4)
    K = M @ M.T
    K = K / np.trace(K)
    
    p = dpp_polynomial(K)
    
    # Collect data for all subsets of sizes 1..4
    data_by_size = {}
    for size in range(1, 5):
        subsets = list(combinations(range(n), size))
        specs = []
        trops = []
        labels = []
        for A_tuple in subsets:
            A = set(A_tuple)
            ws = leaf_witness_spectral(p, A)
            wt = tropical_leaf_witness(p, A)
            specs.append(ws)
            trops.append(wt)
            labels.append(str(A_tuple))
        data_by_size[size] = (labels, specs, trops)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical vs Spectral Leaf Witnesses\n(DPP Kernel, n=6)', 
                 fontsize=14, fontweight='bold')
    
    for idx, size in enumerate([1, 2, 3, 4]):
        ax = axes[idx // 2][idx % 2]
        labels, specs, trops = data_by_size[size]
        gaps = [t - s for s, t in zip(specs, trops)]
        
        x = np.arange(len(labels))
        width = 0.35
        
        bars1 = ax.bar(x - width/2, specs, width, label='Spectral W', 
                       color='#2196F3', alpha=0.8)
        bars2 = ax.bar(x + width/2, trops, width, label='Tropical W', 
                       color='#FF9800', alpha=0.8)
        
        ax.set_title(f'|A| = {size} ({len(labels)} subsets)', fontsize=11)
        ax.set_ylabel('Witness Value')
        ax.legend(fontsize=8)
        ax.set_xticks(x)
        
        if len(labels) <= 15:
            ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=6)
        else:
            ax.set_xticklabels(['' for _ in labels])
            ax.set_xlabel(f'{len(labels)} subsets (labels omitted)')
        
        # Highlight: all gaps ≥ 0
        all_nonneg = all(g >= -1e-10 for g in gaps)
        color = '#4CAF50' if all_nonneg else '#F44336'
        ax.text(0.98, 0.95, f'Gap ≥ 0: {"✓" if all_nonneg else "✗"}',
                transform=ax.transAxes, ha='right', va='top',
                fontsize=10, color=color, fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('witness_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved witness_heatmap.png")


if __name__ == "__main__":
    main()
