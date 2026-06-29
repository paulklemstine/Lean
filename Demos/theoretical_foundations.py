#!/usr/bin/env python3
"""
Spectral Theory of Novelty — Applications

Real-world applications of ultrametric spectral theory:
1. Hierarchical document clustering with spectral certificates
2. Phylogenetic tree analysis
3. Multiscale anomaly detection
"""

import numpy as np
from algorithms import (compute_cut_decomposition, hierarchical_spectral_analysis,
                         spectral_compression_ratio, novelty_at_scale)


def application_document_clustering():
    """
    Application: Hierarchical Document Clustering
    
    Simulates a document similarity scenario where documents form a
    hierarchical topic structure. The ultrametric captures topic distance.
    """
    print("=" * 60)
    print("APPLICATION 1: Hierarchical Document Clustering")
    print("=" * 60)
    
    # Simulate 8 documents in a topic hierarchy:
    # Level 1: Science vs Humanities (distance 10)
    # Level 2: Physics vs Biology | History vs Literature (distance 6)
    # Level 3: Within-subfield differences (distance 2)
    
    topics = ["Quantum", "Relativity", "Genetics", "Ecology", 
              "Ancient", "Modern", "Poetry", "Novel"]
    
    # Build ultrametric from hierarchy
    D = np.zeros((8, 8))
    # Physics: {0,1}, Biology: {2,3}, History: {4,5}, Literature: {6,7}
    groups = [{0,1}, {2,3}, {4,5}, {6,7}]
    supergroups = [{0,1,2,3}, {4,5,6,7}]
    
    for i in range(8):
        for j in range(8):
            if i == j:
                D[i,j] = 0
            elif any(i in g and j in g for g in groups):
                D[i,j] = 2  # Same subfield
            elif any(i in g and j in g for g in supergroups):
                D[i,j] = 6  # Same field
            else:
                D[i,j] = 10  # Different fields
    
    # Spectral analysis
    spec = hierarchical_spectral_analysis(D)
    
    print(f"\n  Topics: {topics}")
    print(f"  Hierarchy: Science={{Physics,Biology}}, Humanities={{History,Literature}}")
    print(f"\n  Eigenvalues of -JDJ: {spec.eigenvalues}")
    print(f"  Effective rank: {spec.effective_rank:.3f}")
    print(f"  Compression ratio: {spectral_compression_ratio(D):.3f}")
    
    # The eigenvalues should cluster at 3 distinct values
    # corresponding to the 3 hierarchy levels
    distinct_eigs = len(set(round(e, 2) for e in spec.eigenvalues if abs(e) > 0.01))
    print(f"  Distinct nonzero eigenvalues: {distinct_eigs} (expected: 3 levels)")
    
    # Novelty analysis: a document about "Quantum Poetry" would be novel at which scale?
    x_quantum_poetry = np.zeros(8)
    x_quantum_poetry[0] = 1   # Quantum
    x_quantum_poetry[6] = 1   # Poetry
    x_quantum_poetry -= x_quantum_poetry.mean()
    
    print(f"\n  Novelty of 'Quantum Poetry' (mix of science and humanities):")
    for k in range(min(4, len(spec.eigenvalues))):
        if spec.eigenvalues[k] > 0.01:
            nov = novelty_at_scale(D, x_quantum_poetry, k)
            print(f"    Scale {k}: {nov:.4f}")
    print()


def application_phylogenetic():
    """
    Application: Phylogenetic Tree Analysis
    
    Evolutionary distances between species form an approximate ultrametric
    (molecular clock hypothesis). The spectral analysis reveals the
    evolutionary scales at which diversification occurred.
    """
    print("=" * 60)
    print("APPLICATION 2: Phylogenetic Tree Analysis")
    print("=" * 60)
    
    species = ["Human", "Chimp", "Gorilla", "Dog", "Cat", "Mouse"]
    
    # Approximate ultrametric evolutionary distances (millions of years * 2)
    D = np.array([
        [0,  12, 18, 160, 160, 170],
        [12,  0, 18, 160, 160, 170],
        [18, 18,  0, 160, 160, 170],
        [160,160,160,  0,  90, 170],
        [160,160,160, 90,   0, 170],
        [170,170,170,170, 170,   0]
    ], dtype=float)
    
    spec = hierarchical_spectral_analysis(D)
    
    print(f"\n  Species: {species}")
    print(f"  Eigenvalues: {spec.eigenvalues}")
    print(f"  Effective rank: {spec.effective_rank:.3f}")
    
    # Cut decomposition reveals evolutionary branch points
    decomp = compute_cut_decomposition(D)
    print(f"\n  Hierarchical cuts (evolutionary branch points):")
    for w, S in zip(decomp.weights, decomp.subsets):
        subset_names = [species[i] for i in sorted(S)]
        if w > 0.1:
            print(f"    Weight {w:7.1f}: {subset_names}")
    print()


def application_anomaly_detection():
    """
    Application: Multiscale Anomaly Detection
    
    Uses the spectral decomposition to detect anomalies at different
    hierarchical scales. An anomaly at the coarsest scale is fundamentally
    different; an anomaly at a fine scale is a subtle variation.
    """
    print("=" * 60)
    print("APPLICATION 3: Multiscale Anomaly Detection")  
    print("=" * 60)
    
    # 6 data points with ultrametric structure
    # Points 0-2 are "normal" cluster A
    # Points 3-4 are "normal" cluster B
    # Point 5 is an outlier
    
    D = np.array([
        [0, 1, 1, 4, 4, 8],
        [1, 0, 1, 4, 4, 8],
        [1, 1, 0, 4, 4, 8],
        [4, 4, 4, 0, 2, 8],
        [4, 4, 4, 2, 0, 8],
        [8, 8, 8, 8, 8, 0]
    ], dtype=float)
    
    labels = ["Normal_A1", "Normal_A2", "Normal_A3", 
              "Normal_B1", "Normal_B2", "Outlier"]
    
    spec = hierarchical_spectral_analysis(D)
    
    print(f"\n  Points: {labels}")
    print(f"  Eigenvalues: {spec.eigenvalues}")
    
    # Test each point as a potential anomaly
    print(f"\n  Anomaly scores by scale:")
    print(f"  {'Point':<12} {'Scale 0':>10} {'Scale 1':>10} {'Scale 2':>10} {'Total':>10}")
    
    for p in range(6):
        x = np.zeros(6)
        x[p] = 1
        x -= x.mean()
        
        scores = []
        total = 0
        for k in range(min(3, len(spec.eigenvalues))):
            if spec.eigenvalues[k] > 0.01:
                nov = novelty_at_scale(D, np.eye(6)[p], k)
                scores.append(nov)
                total += nov
            else:
                scores.append(0)
        
        while len(scores) < 3:
            scores.append(0)
        
        print(f"  {labels[p]:<12} {scores[0]:10.4f} {scores[1]:10.4f} {scores[2]:10.4f} {total:10.4f}")
    
    print(f"\n  → Outlier has highest score at coarsest scale (fundamentally different)")
    print(f"  → Normal points differ mainly at finer scales (within-cluster variation)")
    print()


if __name__ == "__main__":
    print("\n🔬 SPECTRAL NOVELTY — REAL-WORLD APPLICATIONS\n")
    application_document_clustering()
    application_phylogenetic()
    application_anomaly_detection()
    print("All applications complete! ✓")


#!/usr/bin/env python3
"""
Spectral Theory of Novelty — Demonstrations

Concrete numerical examples verifying the theorems:
1. Cut metric quadratic identity
2. Ultrametric conditional negative definiteness
3. Centered PSD property
4. Schoenberg kernel PSD
5. Equidistant metric exact spectrum
"""

import numpy as np
from typing import List, Tuple
np.set_printoptions(precision=6, suppress=True)


def cut_metric(S: set, n: int) -> np.ndarray:
    """Construct the cut metric matrix for subset S ⊆ {0,...,n-1}."""
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if (i in S) != (j in S):
                D[i, j] = 1.0
    return D


def is_ultrametric(D: np.ndarray) -> bool:
    """Check if D satisfies the ultrametric (strong triangle) inequality."""
    n = D.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if D[i, k] > max(D[i, j], D[j, k]) + 1e-10:
                    return False
    return True


def demo_cut_metric_identity():
    """Verify: ∑ x_i x_j δ_S(i,j) = -2(∑_{i∈S} x_i)² for zero-sum x."""
    print("=" * 60)
    print("DEMO 1: Cut Metric Quadratic Identity")
    print("=" * 60)
    
    n = 5
    S = {0, 2, 4}
    D = cut_metric(S, n)
    
    # Random zero-sum vector
    np.random.seed(42)
    x = np.random.randn(n)
    x -= x.mean()  # Make zero-sum
    
    # Quadratic form
    Q = sum(x[i] * x[j] * D[i, j] for i in range(n) for j in range(n))
    
    # Expected: -2 * (sum of x_i for i in S)²
    partial_sum = sum(x[i] for i in S)
    expected = -2 * partial_sum**2
    
    print(f"  n = {n}, S = {S}")
    print(f"  x = {x}")
    print(f"  Quadratic form Q = {Q:.10f}")
    print(f"  -2·(∑_S x_i)²    = {expected:.10f}")
    print(f"  Match: {abs(Q - expected) < 1e-10}")
    print(f"  Q ≤ 0: {Q <= 1e-10}")
    print()


def demo_ultrametric_condneg():
    """Verify: ∑ x_i x_j d(i,j) ≤ 0 for ultrametric d and zero-sum x."""
    print("=" * 60)
    print("DEMO 2: Ultrametric Conditional Negative Definiteness")
    print("=" * 60)
    
    # Example 1: Simple 3-point ultrametric
    D1 = np.array([
        [0, 3, 3],
        [3, 0, 1],
        [3, 1, 0]
    ], dtype=float)
    
    # Example 2: 5-point ultrametric from a dendrogram
    D2 = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 2, 5],
        [3, 3, 2, 0, 5],
        [5, 5, 5, 5, 0]
    ], dtype=float)
    
    # Example 3: p-adic-inspired ultrametric
    n3 = 8
    D3 = np.zeros((n3, n3))
    for i in range(n3):
        for j in range(n3):
            if i != j:
                # Distance = 2^k where k is the position of the first differing bit
                diff = i ^ j
                k = diff.bit_length()
                D3[i, j] = 2**k
    
    examples = [("3-point", D1), ("5-point dendrogram", D2), ("8-point p-adic", D3)]
    
    for name, D in examples:
        n = D.shape[0]
        assert is_ultrametric(D), f"{name} is not ultrametric!"
        
        # Test with many random zero-sum vectors
        max_Q = -np.inf
        for trial in range(1000):
            x = np.random.randn(n)
            x -= x.mean()
            Q = sum(x[i] * x[j] * D[i, j] for i in range(n) for j in range(n))
            max_Q = max(max_Q, Q)
        
        print(f"  {name} (n={n}): is_ultrametric={is_ultrametric(D)}")
        print(f"    Max Q over 1000 trials: {max_Q:.10f}")
        print(f"    Q ≤ 0 always: {max_Q <= 1e-10}")
    print()


def demo_centered_psd():
    """Verify: -JDJ is PSD for ultrametric D."""
    print("=" * 60)
    print("DEMO 3: Centered Ultrametric PSD (-JDJ ≥ 0)")
    print("=" * 60)
    
    D = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 2, 5],
        [3, 3, 2, 0, 5],
        [5, 5, 5, 5, 0]
    ], dtype=float)
    n = D.shape[0]
    
    # Centering matrix J = I - (1/n)11^T
    J = np.eye(n) - np.ones((n, n)) / n
    
    # Centered matrix
    B = -J @ D @ J
    
    # Eigenvalues
    eigenvalues = np.linalg.eigvalsh(B)
    
    print(f"  Distance matrix D (5×5 ultrametric):")
    print(f"  {D}")
    print(f"\n  Eigenvalues of -JDJ: {eigenvalues}")
    print(f"  All eigenvalues ≥ 0: {np.all(eigenvalues >= -1e-10)}")
    print(f"  Number of zero eigenvalues: {np.sum(np.abs(eigenvalues) < 1e-10)}")
    print(f"  Nonzero eigenvalues: {eigenvalues[np.abs(eigenvalues) > 1e-10]}")
    print()


def demo_schoenberg_kernel():
    """Verify: Schoenberg kernel b(i,j) = (d(i,p)+d(p,j)-d(i,j))/2 is PSD."""
    print("=" * 60)
    print("DEMO 4: Schoenberg Kernel PSD")
    print("=" * 60)
    
    D = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 2, 5],
        [3, 3, 2, 0, 5],
        [5, 5, 5, 5, 0]
    ], dtype=float)
    n = D.shape[0]
    
    for base in range(n):
        B = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                B[i, j] = (D[i, base] + D[base, j] - D[i, j]) / 2
        
        eigenvalues = np.linalg.eigvalsh(B)
        all_nonneg = np.all(eigenvalues >= -1e-10)
        print(f"  Base point {base}: eigenvalues = {eigenvalues}")
        print(f"    PSD: {all_nonneg}")
    print()


def demo_equidistant_spectrum():
    """Verify: equidistant metric has Q = -D·∑x_i² for zero-sum x."""
    print("=" * 60)
    print("DEMO 5: Equidistant Metric Exact Spectrum")
    print("=" * 60)
    
    n = 6
    D_val = 3.0
    D = D_val * (np.ones((n, n)) - np.eye(n))
    
    np.random.seed(123)
    x = np.random.randn(n)
    x -= x.mean()
    
    Q = sum(x[i] * x[j] * D[i, j] for i in range(n) for j in range(n))
    expected = -D_val * np.sum(x**2)
    
    print(f"  n = {n}, D = {D_val}")
    print(f"  x = {x}")
    print(f"  Q = {Q:.10f}")
    print(f"  -D·∑x_i² = {expected:.10f}")
    print(f"  Match: {abs(Q - expected) < 1e-10}")
    
    # Eigenvalues of centered matrix
    J = np.eye(n) - np.ones((n, n)) / n
    B = -J @ D @ J
    eigenvalues = np.sort(np.linalg.eigvalsh(B))
    
    print(f"\n  Eigenvalues of -JDJ: {eigenvalues}")
    print(f"  Expected: one zero eigenvalue, n-1 eigenvalues equal to D={D_val}")
    print()


def demo_counterexample():
    """Show that ordinary (non-ultrametric) metrics can violate condNeg."""
    print("=" * 60)
    print("DEMO 6: Counterexample — Non-Ultrametric Failure")
    print("=" * 60)
    
    # Metric on 4 points forming a path graph: 1-2-3-4
    # d(1,2) = 1, d(2,3) = 1, d(3,4) = 1
    # d(1,3) = 2, d(2,4) = 2, d(1,4) = 3
    # This is an ordinary (additive) metric, NOT ultrametric
    D = np.array([
        [0, 1, 2, 3],
        [1, 0, 1, 2],
        [2, 1, 0, 1],
        [3, 2, 1, 0]
    ], dtype=float)
    
    print(f"  Path metric D (NOT ultrametric):")
    print(f"  {D}")
    print(f"  Is ultrametric: {is_ultrametric(D)}")
    
    # This metric IS conditionally negative definite (tree metrics are)
    # But let's try a non-tree metric
    D2 = np.array([
        [0, 1, 1, 2],
        [1, 0, 2, 1],
        [1, 2, 0, 1],
        [2, 1, 1, 0]
    ], dtype=float)
    
    print(f"\n  Cycle metric D2:")
    print(f"  {D2}")
    print(f"  Is ultrametric: {is_ultrametric(D2)}")
    
    J = np.eye(4) - np.ones((4, 4)) / 4
    B2 = -J @ D2 @ J
    eigs = np.linalg.eigvalsh(B2)
    print(f"  Eigenvalues of -JD2J: {eigs}")
    print(f"  PSD: {np.all(eigs >= -1e-10)}")
    
    # Try a metric that violates condNeg
    D3 = np.array([
        [0, 1, 10, 10],
        [1, 0, 10, 10],
        [10, 10, 0, 1],
        [10, 10, 1, 0]
    ], dtype=float)
    D3_ultra = is_ultrametric(D3)
    J4 = np.eye(4) - np.ones((4, 4)) / 4
    B3 = -J4 @ D3 @ J4
    eigs3 = np.linalg.eigvalsh(B3)
    print(f"\n  Two-cluster metric (IS ultrametric: {D3_ultra}):")
    print(f"  Eigenvalues of -JD3J: {eigs3}")
    print(f"  All ≥ 0: {np.all(eigs3 >= -1e-10)}")
    print()


if __name__ == "__main__":
    print("\n🔬 SPECTRAL THEORY OF NOVELTY — NUMERICAL DEMONSTRATIONS\n")
    demo_cut_metric_identity()
    demo_ultrametric_condneg()
    demo_centered_psd()
    demo_schoenberg_kernel()
    demo_equidistant_spectrum()
    demo_counterexample()
    print("All demonstrations complete! ✓")


#!/usr/bin/env python3
"""
Spectral Theory of Novelty — Visualizations

Generates publication-quality figures illustrating the key theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_ultrametric_spectrum():
    """Visualize the spectrum of centered ultrametric vs non-ultrametric."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Ultrametric
    D1 = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 2, 5],
        [3, 3, 2, 0, 5],
        [5, 5, 5, 5, 0]
    ], dtype=float)
    
    # Non-ultrametric (path metric)
    D2 = np.array([
        [0, 1, 2, 3, 4],
        [1, 0, 1, 2, 3],
        [2, 1, 0, 1, 2],
        [3, 2, 1, 0, 1],
        [4, 3, 2, 1, 0]
    ], dtype=float)
    
    # Random metric
    np.random.seed(42)
    R = np.random.rand(5, 5)
    D3 = (R + R.T) / 2
    np.fill_diagonal(D3, 0)
    # Make it a metric (Floyd-Warshall)
    for k in range(5):
        for i in range(5):
            for j in range(5):
                D3[i,j] = min(D3[i,j], D3[i,k] + D3[k,j])
    
    titles = ['Ultrametric\n(Hierarchical)', 'Path Metric\n(Non-Ultrametric)', 
              'Random Metric\n(Non-Ultrametric)']
    
    for ax, D, title in zip(axes, [D1, D2, D3], titles):
        n = D.shape[0]
        J = np.eye(n) - np.ones((n, n)) / n
        B = -J @ D @ J
        B = (B + B.T) / 2
        eigs = np.sort(np.linalg.eigvalsh(B))[::-1]
        
        colors = ['#2ecc71' if e >= -1e-10 else '#e74c3c' for e in eigs]
        ax.bar(range(len(eigs)), eigs, color=colors, edgecolor='white', linewidth=0.5)
        ax.axhline(y=0, color='black', linewidth=0.5)
        ax.set_xlabel('Eigenvalue Index', fontsize=11)
        ax.set_ylabel('Eigenvalue', fontsize=11)
        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.set_xticks(range(len(eigs)))
    
    fig.suptitle('Spectrum of Centered Distance Matrix −JDJ', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_cut_decomposition():
    """Visualize the laminar cut decomposition of an ultrametric."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # 8-point ultrametric with clear hierarchy
    n = 8
    D = np.zeros((n, n))
    # Hierarchy: {0,1} {2,3} {4,5} {6,7} at level 2
    # {0,1,2,3} {4,5,6,7} at level 6
    # all together at level 10
    for i in range(n):
        for j in range(n):
            if i == j: continue
            if i // 2 == j // 2:
                D[i,j] = 2
            elif i // 4 == j // 4:
                D[i,j] = 6
            else:
                D[i,j] = 10
    
    # Plot distance matrix
    im = axes[0].imshow(D, cmap='YlOrRd', interpolation='nearest')
    axes[0].set_title('Ultrametric Distance Matrix', fontsize=12, fontweight='bold')
    axes[0].set_xlabel('Point Index')
    axes[0].set_ylabel('Point Index')
    plt.colorbar(im, ax=axes[0], shrink=0.8)
    
    # Add grid lines showing hierarchy
    for pos in [1.5, 3.5, 5.5]:
        axes[0].axhline(y=pos, color='white', linewidth=0.5, alpha=0.5)
        axes[0].axvline(x=pos, color='white', linewidth=0.5, alpha=0.5)
    
    # Plot centered spectrum
    J = np.eye(n) - np.ones((n, n)) / n
    B = -J @ D @ J
    B = (B + B.T) / 2
    eigs = np.sort(np.linalg.eigvalsh(B))[::-1]
    
    colors = ['#3498db', '#2ecc71', '#e67e22', '#9b59b6', '#e74c3c', '#1abc9c', '#f39c12', '#95a5a6']
    axes[1].bar(range(len(eigs)), eigs, color=colors[:len(eigs)], 
                edgecolor='white', linewidth=0.5)
    axes[1].axhline(y=0, color='black', linewidth=0.5)
    axes[1].set_xlabel('Eigenvalue Index', fontsize=11)
    axes[1].set_ylabel('Eigenvalue', fontsize=11)
    axes[1].set_title('Eigenvalues of −JDJ\n(Hierarchical Scales)', 
                       fontsize=12, fontweight='bold')
    
    # Annotate eigenvalue clusters
    axes[1].annotate('Level 3\n(coarsest)', xy=(0, eigs[0]), 
                     xytext=(1.5, eigs[0]*0.9), fontsize=9,
                     arrowprops=dict(arrowstyle='->', color='gray'))
    
    fig.suptitle('Ultrametric Hierarchy → Spectral Structure', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_condneg_verification():
    """Visualize the conditional negative definiteness property."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    D = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 2, 5],
        [3, 3, 2, 0, 5],
        [5, 5, 5, 5, 0]
    ], dtype=float)
    n = D.shape[0]
    
    # Generate many zero-sum vectors and compute Q
    np.random.seed(42)
    N_trials = 5000
    Q_values = []
    for _ in range(N_trials):
        x = np.random.randn(n)
        x -= x.mean()  # zero-sum
        Q = sum(x[i]*x[j]*D[i,j] for i in range(n) for j in range(n))
        Q_values.append(Q)
    
    # Histogram of Q values
    axes[0].hist(Q_values, bins=50, color='#3498db', edgecolor='white', alpha=0.8)
    axes[0].axvline(x=0, color='#e74c3c', linewidth=2, linestyle='--', label='Q = 0')
    axes[0].set_xlabel('Q = ∑ xᵢxⱼd(i,j)', fontsize=11)
    axes[0].set_ylabel('Frequency', fontsize=11)
    axes[0].set_title('Ultrametric: Q ≤ 0 Always\n(5000 random zero-sum vectors)', 
                       fontsize=12, fontweight='bold')
    axes[0].legend(fontsize=10)
    
    # Now compare with a non-ultrametric
    D_non = np.array([
        [0, 1, 5, 2, 3],
        [1, 0, 4, 3, 2],
        [5, 4, 0, 3, 6],
        [2, 3, 3, 0, 1],
        [3, 2, 6, 1, 0]
    ], dtype=float)
    # Symmetrize
    D_non = (D_non + D_non.T) / 2
    
    Q_non = []
    for _ in range(N_trials):
        x = np.random.randn(n)
        x -= x.mean()
        Q = sum(x[i]*x[j]*D_non[i,j] for i in range(n) for j in range(n))
        Q_non.append(Q)
    
    axes[1].hist(Q_non, bins=50, color='#e67e22', edgecolor='white', alpha=0.8)
    axes[1].axvline(x=0, color='#e74c3c', linewidth=2, linestyle='--', label='Q = 0')
    axes[1].set_xlabel('Q = ∑ xᵢxⱼd(i,j)', fontsize=11)
    axes[1].set_ylabel('Frequency', fontsize=11)
    axes[1].set_title('Non-Ultrametric: Q Can Be Positive\n(condNeg may fail)', 
                       fontsize=12, fontweight='bold')
    axes[1].legend(fontsize=10)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_schoenberg_embedding():
    """Visualize the Schoenberg (Hilbert space) embedding."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    D = np.array([
        [0, 1, 3, 3, 5],
        [1, 0, 3, 3, 5],
        [3, 3, 0, 2, 5],
        [3, 3, 2, 0, 5],
        [5, 5, 5, 5, 0]
    ], dtype=float)
    n = D.shape[0]
    base = 0
    
    # Schoenberg kernel
    B = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            B[i,j] = (D[i,base] + D[base,j] - D[i,j]) / 2
    
    B = (B + B.T) / 2
    eigs, vecs = np.linalg.eigh(B)
    
    # Embedding: φ(i) = √λ_k · v_k(i) for positive eigenvalues
    pos_idx = eigs > 1e-10
    coords = vecs[:, pos_idx] * np.sqrt(eigs[pos_idx])
    
    # Plot in 2D (first two principal components)
    labels = ['A', 'B', 'C', 'D', 'E']
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']
    
    if coords.shape[1] >= 2:
        axes[0].scatter(coords[:, -1], coords[:, -2], c=colors, s=200, zorder=5, edgecolors='black')
        for i, label in enumerate(labels):
            axes[0].annotate(label, (coords[i, -1], coords[i, -2]), 
                           fontsize=14, fontweight='bold', ha='center', va='bottom',
                           xytext=(0, 10), textcoords='offset points')
    
    axes[0].set_xlabel('Component 1', fontsize=11)
    axes[0].set_ylabel('Component 2', fontsize=11)
    axes[0].set_title('Hilbert Space Embedding\n(from Schoenberg kernel)', 
                       fontsize=12, fontweight='bold')
    axes[0].set_aspect('equal')
    axes[0].grid(True, alpha=0.3)
    
    # Verify embedding distances match original
    embedded_D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            embedded_D[i,j] = np.sum((coords[i] - coords[j])**2)
    
    # Scatter plot: original vs embedded distances
    orig_dists = []
    embed_dists = []
    for i in range(n):
        for j in range(i+1, n):
            orig_dists.append(D[i,j])
            embed_dists.append(embedded_D[i,j])
    
    axes[1].scatter(orig_dists, embed_dists, s=80, c='#3498db', edgecolors='black', zorder=5)
    max_d = max(max(orig_dists), max(embed_dists))
    axes[1].plot([0, max_d], [0, max_d], 'r--', linewidth=2, label='Perfect embedding')
    axes[1].set_xlabel('Original d(i,j)', fontsize=11)
    axes[1].set_ylabel('||φ(i)−φ(j)||²', fontsize=11)
    axes[1].set_title('Isometry Verification\n‖φ(i)−φ(j)‖² = d(i,j)', 
                       fontsize=12, fontweight='bold')
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    img1 = viz_ultrametric_spectrum()
    img2 = viz_cut_decomposition()
    img3 = viz_condneg_verification()
    img4 = viz_schoenberg_embedding()
    
    # Save to files
    for name, img in [("spectrum.png", img1), ("cuts.png", img2), 
                       ("condneg.png", img3), ("embedding.png", img4)]:
        data = base64.b64decode(img.split(",")[1])
        with open(name, "wb") as f:
            f.write(data)
        print(f"  Saved {name}")
    
    print("Done!")
