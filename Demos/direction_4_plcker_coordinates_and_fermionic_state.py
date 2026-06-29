"""
Applications of Fermionic Plücker Coordinates

Demonstrates real-world applications of the matroid-fermion correspondence:
1. Spanning tree sampling in graphs (graphic matroids)
2. Network reliability computation
3. Feature subset selection via DPP
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict


def graph_incidence_matrix(edges: List[Tuple[int, int]], num_vertices: int,
                            root: int = 0) -> np.ndarray:
    """
    Construct the reduced incidence matrix of a graph.
    
    For a graph with n vertices and m edges, this gives an (n-1) x m matrix
    representing the graphic matroid. The bases of this matroid correspond
    to spanning trees of the graph.
    
    Args:
        edges: List of (u, v) edges
        num_vertices: Number of vertices
        root: Vertex to remove (default 0)
    
    Returns:
        Reduced incidence matrix A of shape (n-1, m)
    """
    n = num_vertices
    m = len(edges)
    # Full incidence matrix
    B = np.zeros((n, m))
    for j, (u, v) in enumerate(edges):
        B[u, j] = 1
        B[v, j] = -1
    # Remove the root row
    rows = [i for i in range(n) if i != root]
    return B[rows, :]


def spanning_tree_distribution(edges: List[Tuple[int, int]], num_vertices: int,
                                 weights: np.ndarray = None) -> Dict[Tuple[int, ...], float]:
    """
    Compute the weighted spanning tree distribution using the Plücker mass framework.
    
    Each spanning tree T gets probability proportional to:
      prod_{e in T} w_e * det(A_T)^2
    
    For unit weights, this is the uniform distribution over spanning trees
    (weighted by det^2, which equals 1 for trees in graphic matroids).
    
    Args:
        edges: List of edges
        num_vertices: Number of vertices
        weights: Edge weights (default: all ones)
    
    Returns:
        Dictionary mapping edge subsets to probabilities
    """
    A = graph_incidence_matrix(edges, num_vertices)
    r, m = A.shape  # r = n-1
    
    if weights is None:
        weights = np.ones(m)
    
    # Compute Plücker mass = det(A diag(w) A^T) = weighted Laplacian det
    gram_det = np.linalg.det(A @ np.diag(weights) @ A.T)
    
    dist = {}
    for S in combinations(range(m), r):
        det_S = np.linalg.det(A[:, list(S)])
        if abs(det_S) > 1e-10:
            prob = det_S**2 * np.prod([weights[i] for i in S]) / gram_det
            dist[S] = prob
    
    return dist


def demo_spanning_trees():
    """Demo: Spanning trees of K4 (complete graph on 4 vertices)."""
    print("=" * 60)
    print("APPLICATION: SPANNING TREE SAMPLING IN K4")
    print("=" * 60)
    
    # K4 edges
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    edge_labels = [f"{u}-{v}" for u, v in edges]
    n = 4
    
    A = graph_incidence_matrix(edges, n)
    print(f"Reduced incidence matrix A ({A.shape[0]}x{A.shape[1]}):")
    print(A)
    
    # Unit weights: uniform over spanning trees
    dist = spanning_tree_distribution(edges, n)
    print(f"\nSpanning trees of K4 (uniform distribution):")
    print(f"Number of spanning trees: {len(dist)} (should be 4^2 = 16)")
    for S, p in sorted(dist.items(), key=lambda x: -x[1]):
        tree_edges = [edge_labels[i] for i in S]
        print(f"  T = {{{', '.join(tree_edges)}}}: P = {p:.6f}")
    
    total = sum(dist.values())
    print(f"Total probability: {total:.10f}")
    
    # Weighted case
    w = np.array([1, 2, 3, 1, 2, 3], dtype=float)
    dist_w = spanning_tree_distribution(edges, n, w)
    print(f"\nWeighted spanning tree distribution (w = {w}):")
    for S, p in sorted(dist_w.items(), key=lambda x: -x[1])[:8]:
        tree_edges = [edge_labels[i] for i in S]
        print(f"  T = {{{', '.join(tree_edges)}}}: P = {p:.6f}")


def demo_feature_selection():
    """Demo: Feature subset selection via DPP."""
    print("\n" + "=" * 60)
    print("APPLICATION: DIVERSE FEATURE SELECTION VIA DPP")
    print("=" * 60)
    
    # Create a feature matrix: 3 features from 6 candidates
    np.random.seed(42)
    A = np.random.randn(3, 6)
    feature_names = [f"F{i}" for i in range(6)]
    
    print(f"Feature quality matrix A (rank-3 representation):")
    print(A.round(3))
    
    # Compute DPP kernel
    K = A.T @ np.linalg.inv(A @ A.T) @ A
    print(f"\nDPP kernel K (diversity-quality tradeoff):")
    print(K.round(3))
    
    # Show top feature subsets
    r, n = A.shape
    gram_det = np.linalg.det(A @ A.T)
    
    subsets_probs = []
    for S in combinations(range(n), r):
        det_S = np.linalg.det(A[:, list(S)])
        prob = det_S**2 / gram_det
        subsets_probs.append((S, prob))
    
    subsets_probs.sort(key=lambda x: -x[1])
    
    print(f"\nTop 10 feature subsets by DPP probability:")
    for S, p in subsets_probs[:10]:
        names = [feature_names[i] for i in S]
        print(f"  {{{', '.join(names)}}}: P = {p:.6f}")


if __name__ == "__main__":
    demo_spanning_trees()
    demo_feature_selection()


"""
Fermionic Plücker Coordinates: Interactive Demo

This script demonstrates the core mathematical identities connecting:
- Representable matroids (via matrix minors)
- Cauchy-Binet determinant identities (Gram determinants)
- Fermionic occupation-number amplitudes (Slater determinants)
- Determinantal point processes (projection kernels)

Usage:
    python demo.py
"""

import numpy as np
from itertools import combinations
from math import comb


def all_r_subsets(n, r):
    """Generate all r-element subsets of {0, 1, ..., n-1}."""
    return list(combinations(range(n), r))


def minor_det(A, S):
    """Compute det(A_S) = determinant of the submatrix with columns indexed by S."""
    cols = list(S)
    return np.linalg.det(A[:, cols])


def plucker_mass(A, w):
    """
    Compute the weighted Plücker mass:
      pluckerMass(A, w) = sum_{|S|=r} det(A_S)^2 * prod_{i in S} w_i
    """
    r, n = A.shape
    total = 0.0
    for S in all_r_subsets(n, r):
        d = minor_det(A, S)
        weight_prod = np.prod([w[i] for i in S])
        total += d**2 * weight_prod
    return total


def gram_det(A, w):
    """Compute det(A * diag(w) * A^T)."""
    Dw = np.diag(w)
    G = A @ Dw @ A.T
    return np.linalg.det(G)


def slater_distribution(A):
    """
    Compute the Slater basis distribution:
      P(S) = det(A_S)^2 / det(A A^T)
    for all r-subsets S.
    """
    r, n = A.shape
    gram = np.linalg.det(A @ A.T)
    dist = {}
    for S in all_r_subsets(n, r):
        d = minor_det(A, S)
        dist[S] = d**2 / gram
    return dist


def projection_kernel(A):
    """
    Compute the projection kernel K = A^T (A A^T)^{-1} A.
    This is the one-particle correlation matrix of the fermionic state.
    """
    gram_inv = np.linalg.inv(A @ A.T)
    return A.T @ gram_inv @ A


def dpp_probability(K, S):
    """
    Compute the DPP probability P(S) = det(K_S)
    where K_S is the principal submatrix of K indexed by S.
    """
    idx = list(S)
    return np.linalg.det(K[np.ix_(idx, idx)])


def demo_cauchy_binet(A, w):
    """Demonstrate the Cauchy-Binet identity."""
    r, n = A.shape
    print(f"\n{'='*60}")
    print(f"CAUCHY-BINET IDENTITY: r={r}, n={n}")
    print(f"{'='*60}")
    print(f"A =\n{A}")
    print(f"w = {w}")

    lhs = gram_det(A, w)
    rhs = plucker_mass(A, w)

    print(f"\ndet(A * diag(w) * A^T) = {lhs:.10f}")
    print(f"pluckerMass(A, w)      = {rhs:.10f}")
    print(f"Difference             = {abs(lhs - rhs):.2e}")
    print(f"✓ Identity verified!" if abs(lhs - rhs) < 1e-10 else "✗ MISMATCH!")


def demo_born_rule(A):
    """Demonstrate the Born rule / Slater normalization."""
    r, n = A.shape
    print(f"\n{'='*60}")
    print(f"BORN RULE (SLATER NORMALIZATION): r={r}, n={n}")
    print(f"{'='*60}")

    gram = np.linalg.det(A @ A.T)
    print(f"det(A A^T) = {gram:.10f}")

    sum_sq = sum(minor_det(A, S)**2 for S in all_r_subsets(n, r))
    print(f"sum of squared minors = {sum_sq:.10f}")
    print(f"Difference = {abs(gram - sum_sq):.2e}")

    if gram > 1e-10:
        dist = slater_distribution(A)
        print(f"\nSlater basis distribution:")
        for S, p in sorted(dist.items()):
            if abs(p) > 1e-12:
                print(f"  P({set(S)}) = {p:.6f}")
        total = sum(dist.values())
        print(f"  Sum of probabilities = {total:.10f}")
        print(f"  ✓ Sums to 1!" if abs(total - 1) < 1e-10 else "  ✗ MISMATCH!")


def demo_dpp(A):
    """Demonstrate the determinantal point process connection."""
    r, n = A.shape
    gram = np.linalg.det(A @ A.T)
    if gram < 1e-10:
        print("\n(Skipping DPP demo: A does not have full row rank)")
        return

    print(f"\n{'='*60}")
    print(f"DETERMINANTAL POINT PROCESS: r={r}, n={n}")
    print(f"{'='*60}")

    K = projection_kernel(A)
    print(f"Projection kernel K = A^T (A A^T)^(-1) A:")
    print(f"{K}")
    print(f"\nK is idempotent: ||K^2 - K|| = {np.linalg.norm(K @ K - K):.2e}")
    print(f"K is symmetric: ||K - K^T|| = {np.linalg.norm(K - K.T):.2e}")
    print(f"trace(K) = {np.trace(K):.6f} (should equal r={r})")

    print(f"\nComparison of Slater prob vs DPP prob:")
    print(f"  {'Subset S':<20} {'det(A_S)^2/det(AA^T)':<25} {'det(K_S)':<15} {'Match?'}")
    all_match = True
    for S in all_r_subsets(n, r):
        slater_p = minor_det(A, S)**2 / gram
        dpp_p = dpp_probability(K, S)
        match = abs(slater_p - dpp_p) < 1e-10
        if not match:
            all_match = False
        if abs(slater_p) > 1e-12 or abs(dpp_p) > 1e-12:
            print(f"  {str(set(S)):<20} {slater_p:<25.10f} {dpp_p:<15.10f} {'✓' if match else '✗'}")

    print(f"\n{'✓ All probabilities match!' if all_match else '✗ MISMATCH FOUND!'}")
    print(f"\nThis proves: the matroid basis distribution is a determinantal point process")
    print(f"with projection kernel K = A^T (A A^T)^(-1) A.")


def main():
    print("=" * 60)
    print("FERMIONIC PLÜCKER COORDINATES: DEMONSTRATION")
    print("Connecting Matroids, Grassmannians, and Quantum Physics")
    print("=" * 60)

    # Example 1: 2x4 matrix (rank-2 matroid on 4 elements)
    A1 = np.array([[1, 0, 1, 1],
                    [0, 1, 1, -1]], dtype=float)
    w1 = np.array([1, 2, 3, 4], dtype=float)

    demo_cauchy_binet(A1, w1)
    demo_born_rule(A1)
    demo_dpp(A1)

    # Example 2: 3x5 matrix (rank-3 matroid on 5 elements)
    A2 = np.array([[1, 0, 0, 1, 2],
                    [0, 1, 0, 1, -1],
                    [0, 0, 1, -1, 1]], dtype=float)
    w2 = np.array([1, 1, 1, 2, 3], dtype=float)

    demo_cauchy_binet(A2, w2)
    demo_born_rule(A2)
    demo_dpp(A2)

    # Example 3: Random 2x6 matrix
    np.random.seed(42)
    A3 = np.random.randn(2, 6)
    w3 = np.abs(np.random.randn(6))  # nonneg weights

    demo_cauchy_binet(A3, w3)
    demo_born_rule(A3)
    demo_dpp(A3)

    # Example 4: Random 3x6 matrix
    A4 = np.random.randn(3, 6)
    w4 = np.ones(6)  # unit weights

    demo_cauchy_binet(A4, w4)
    demo_born_rule(A4)
    demo_dpp(A4)

    print(f"\n{'='*60}")
    print("ALL DEMONSTRATIONS COMPLETE")
    print("="*60)
    print("\nKey identities verified:")
    print("1. Cauchy-Binet: det(A Dw A^T) = sum_{|S|=r} det(A_S)^2 prod w_i")
    print("2. Born rule: sum_{|S|=r} det(A_S)^2 = det(A A^T)")
    print("3. DPP: det(A_S)^2 / det(AA^T) = det(K_S) where K = A^T(AA^T)^{-1}A")
    print("4. Normalization: sum P(S) = 1")


if __name__ == "__main__":
    main()


# Visualization: Cauchy-Binet Identity Verification
#
# This script visually demonstrates the Cauchy-Binet identity by comparing
# det(A D_w A^T) with the sum of weighted squared minors for many random
# matrices, showing perfect agreement.

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

def plucker_mass_direct(A, w):
    r, n = A.shape
    total = 0.0
    for S in combinations(range(n), r):
        det_S = np.linalg.det(A[:, list(S)])
        weight_prod = np.prod([w[i] for i in S])
        total += det_S**2 * weight_prod
    return total

def gram_det(A, w):
    return np.linalg.det(A @ np.diag(w) @ A.T)

def main():
    np.random.seed(123)
    
    configs = [(2, 4), (2, 5), (2, 6), (3, 5), (3, 6)]
    n_samples = 50
    
    fig, axes = plt.subplots(1, len(configs), figsize=(20, 4))
    
    for idx, (r, n) in enumerate(configs):
        ax = axes[idx]
        
        gram_vals = []
        plucker_vals = []
        
        for _ in range(n_samples):
            A = np.random.randn(r, n)
            w = np.abs(np.random.randn(n)) + 0.1
            
            g = gram_det(A, w)
            p = plucker_mass_direct(A, w)
            gram_vals.append(g)
            plucker_vals.append(p)
        
        gram_vals = np.array(gram_vals)
        plucker_vals = np.array(plucker_vals)
        
        ax.scatter(gram_vals, plucker_vals, alpha=0.7, s=20, c='#3498db', edgecolors='#2c3e50', linewidth=0.5)
        
        # Perfect agreement line
        lim = max(max(gram_vals), max(plucker_vals)) * 1.1
        ax.plot([0, lim], [0, lim], 'r--', linewidth=1, alpha=0.8, label='y = x')
        
        # Error statistics
        max_err = np.max(np.abs(gram_vals - plucker_vals))
        
        ax.set_xlabel('det(A D_w A^T)', fontsize=10)
        ax.set_ylabel('Σ det(A_S)² ∏w_i', fontsize=10)
        ax.set_title(f'r={r}, n={n}\nmax error: {max_err:.1e}', fontsize=11)
        ax.set_aspect('equal')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Cauchy-Binet Identity: det(A D_w A^T) = Σ det(A_S)² ∏ w_i',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_cauchy_binet.png', dpi=150, bbox_inches='tight')
    print("Saved viz_cauchy_binet.png")

if __name__ == "__main__":
    main()


# Visualization: DPP Kernel and Basis Probabilities
#
# This script visualizes the determinantal point process structure of a
# rank-3 matroid on 6 elements, showing how the projection kernel K
# determines all basis probabilities via det(K_S).

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

def main():
    np.random.seed(7)
    
    # Rank-3 matroid on 6 elements
    A = np.array([[1, 0, 0, 1, 1, 2],
                   [0, 1, 0, 1, -1, 1],
                   [0, 0, 1, 0, 1, -1]], dtype=float)
    r, n = A.shape
    
    # Compute key objects
    gram = A @ A.T
    gram_det_val = np.linalg.det(gram)
    K = A.T @ np.linalg.inv(gram) @ A
    
    # Compute all 3-subsets
    subsets = list(combinations(range(n), r))
    
    slater_probs = []
    dpp_probs = []
    labels = []
    
    for S in subsets:
        idx = list(S)
        det_S = np.linalg.det(A[:, idx])
        slater_p = det_S**2 / gram_det_val
        dpp_p = np.linalg.det(K[np.ix_(idx, idx)])
        slater_probs.append(slater_p)
        dpp_probs.append(dpp_p)
        labels.append(f"{{{S[0]},{S[1]},{S[2]}}}")
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    
    # Plot 1: K heatmap
    ax = axes[0, 0]
    im = ax.imshow(K, cmap='coolwarm', vmin=-0.8, vmax=0.8)
    ax.set_title('Projection Kernel K = Aᵀ(AAᵀ)⁻¹A', fontsize=12, fontweight='bold')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{K[i,j]:.2f}', ha='center', va='center', fontsize=9,
                    color='white' if abs(K[i,j]) > 0.4 else 'black')
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    # Plot 2: Eigenvalues of K
    ax = axes[0, 1]
    eigs = np.sort(np.linalg.eigvalsh(K))[::-1]
    ax.bar(range(n), eigs, color=['#2ecc71' if e > 0.5 else '#bdc3c7' for e in eigs],
           edgecolor='black', linewidth=0.5)
    ax.set_xticks(range(n))
    ax.set_xlabel('Eigenvalue index', fontsize=11)
    ax.set_ylabel('Eigenvalue', fontsize=11)
    ax.set_title(f'Eigenvalues of K\n(rank = {r}, trace = {np.trace(K):.1f})', fontsize=12, fontweight='bold')
    ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5)
    ax.set_ylim(-0.1, 1.2)
    
    # Plot 3: Comparison of Slater vs DPP probabilities
    ax = axes[1, 0]
    x = np.arange(len(subsets))
    width = 0.35
    bars1 = ax.bar(x - width/2, slater_probs, width, label='det(A_S)²/det(AAᵀ)',
                   color='#3498db', alpha=0.8, edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(x + width/2, dpp_probs, width, label='det(K_S)',
                   color='#e74c3c', alpha=0.8, edgecolor='black', linewidth=0.5)
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_ylabel('Probability', fontsize=11)
    ax.set_title('Slater vs DPP Probabilities', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    
    # Plot 4: Scatter plot (should be on y=x line)
    ax = axes[1, 1]
    ax.scatter(slater_probs, dpp_probs, c='#9b59b6', s=50, edgecolors='black',
               linewidth=0.5, zorder=5)
    max_val = max(max(slater_probs), max(dpp_probs)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, alpha=0.5, label='Perfect agreement')
    ax.set_xlabel('Slater: det(A_S)²/det(AAᵀ)', fontsize=11)
    ax.set_ylabel('DPP: det(K_S)', fontsize=11)
    ax.set_title('DPP Identity Verification', fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    max_err = max(abs(s - d) for s, d in zip(slater_probs, dpp_probs))
    ax.text(0.05, 0.95, f'Max error: {max_err:.1e}', transform=ax.transAxes,
            fontsize=10, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.suptitle('Determinantal Point Process Structure of a Rank-3 Matroid on [6]',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_dpp_kernel.png', dpi=150, bbox_inches='tight')
    print("Saved viz_dpp_kernel.png")

if __name__ == "__main__":
    main()


# Visualization: Plücker Coordinate Heatmap
# 
# This script visualizes the squared Plücker amplitudes (basis probabilities)
# for a rank-2 matroid on 5 elements, showing which 2-element subsets are
# matroid bases (nonzero amplitude) and their relative probabilities.

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

def minor_det(A, S):
    return np.linalg.det(A[:, list(S)])

def main():
    # Rank-2 matroid on 5 elements
    A = np.array([[1, 0, 1, 2, -1],
                   [0, 1, 1, 1,  2]], dtype=float)
    r, n = A.shape
    
    # Compute all 2-subsets and their squared amplitudes
    subsets = list(combinations(range(n), r))
    labels = [f"{{{s[0]},{s[1]}}}" for s in subsets]
    amplitudes = [minor_det(A, S) for S in subsets]
    sq_amplitudes = [a**2 for a in amplitudes]
    
    gram_det = np.linalg.det(A @ A.T)
    probabilities = [a / gram_det for a in sq_amplitudes]
    
    # Create heatmap-style visualization
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Squared amplitudes as bar chart
    ax = axes[0]
    colors = ['#2ecc71' if p > 1e-10 else '#e74c3c' for p in probabilities]
    bars = ax.bar(range(len(subsets)), sq_amplitudes, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_xticks(range(len(subsets)))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=9)
    ax.set_ylabel('|det(A_S)|²', fontsize=12)
    ax.set_title('Squared Plücker Amplitudes', fontsize=13, fontweight='bold')
    ax.set_xlabel('2-subset S', fontsize=11)
    
    # Plot 2: Probability distribution (normalized)
    ax = axes[1]
    nonzero_idx = [i for i, p in enumerate(probabilities) if p > 1e-10]
    nonzero_labels = [labels[i] for i in nonzero_idx]
    nonzero_probs = [probabilities[i] for i in nonzero_idx]
    
    wedges, texts, autotexts = ax.pie(nonzero_probs, labels=nonzero_labels,
                                       autopct='%1.1f%%', startangle=90,
                                       colors=plt.cm.Set3(np.linspace(0, 1, len(nonzero_probs))))
    ax.set_title('Slater Basis Distribution\n(Born Probabilities)', fontsize=13, fontweight='bold')
    
    # Plot 3: 5x5 projection kernel heatmap
    ax = axes[2]
    K = A.T @ np.linalg.inv(A @ A.T) @ A
    im = ax.imshow(K, cmap='RdBu_r', vmin=-1, vmax=1, aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('Column index', fontsize=11)
    ax.set_ylabel('Column index', fontsize=11)
    ax.set_title('Projection Kernel K\n(One-Particle Correlations)', fontsize=13, fontweight='bold')
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{K[i,j]:.2f}', ha='center', va='center', fontsize=8,
                    color='white' if abs(K[i,j]) > 0.5 else 'black')
    plt.colorbar(im, ax=ax, shrink=0.8)
    
    plt.suptitle('Fermionic Plücker Coordinates: Rank-2 Matroid on [5]',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_plucker_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved viz_plucker_heatmap.png")

if __name__ == "__main__":
    main()
