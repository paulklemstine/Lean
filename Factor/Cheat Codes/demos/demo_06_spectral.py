"""
CHEAT CODE #6: SPECTRAL METHODS & THE SPECTRAL GAP
====================================================
Demonstrates the power of eigenvalues for understanding graphs,
mixing times, and computational phase transitions.

Experiments:
1. PageRank: the dominant eigenvector of the web graph
2. Spectral gap and random walk mixing time
3. Spectral clustering: finding hidden communities
4. Phase transition: spectral gap collapse
"""

import numpy as np
from scipy import linalg


def experiment_1_pagerank():
    """PageRank as the dominant eigenvector."""
    print("=" * 60)
    print("EXPERIMENT 1: PageRank — The Dominant Eigenvector")
    print("=" * 60)
    
    np.random.seed(42)
    n = 8
    
    # Create a small web graph
    # Adjacency: page i links to page j
    links = {
        0: [1, 2],      # Page A links to B, C
        1: [0, 3],      # Page B links to A, D
        2: [0, 1, 4],   # Page C links to A, B, E
        3: [1, 5],      # Page D links to B, F
        4: [2, 5, 6],   # Page E links to C, F, G
        5: [3, 4, 7],   # Page F links to D, E, H
        6: [4, 7],      # Page G links to E, H
        7: [5, 6],      # Page H links to F, G
    }
    
    page_names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
    
    # Build transition matrix
    M = np.zeros((n, n))
    for i, targets in links.items():
        for j in targets:
            M[j, i] = 1.0 / len(targets)
    
    # Add damping factor (Google's trick)
    d = 0.85
    G = d * M + (1 - d) / n * np.ones((n, n))
    
    # Method 1: Power iteration (what Google actually does)
    v = np.ones(n) / n
    for iteration in range(50):
        v_new = G @ v
        if np.linalg.norm(v_new - v) < 1e-12:
            break
        v = v_new
    
    # Method 2: Eigenvector
    eigenvalues, eigenvectors = np.linalg.eig(G)
    # Dominant eigenvector (eigenvalue closest to 1)
    idx = np.argmax(np.abs(eigenvalues))
    v_eig = np.abs(eigenvectors[:, idx])
    v_eig = v_eig / np.sum(v_eig)
    
    print(f"\nWeb graph with {n} pages, damping factor d = {d}")
    print(f"\n{'Page':>6} | {'Links to':>15} | {'PageRank (power)':>18} | {'PageRank (eig)':>16}")
    print("-" * 65)
    
    ranking = np.argsort(-v)
    for rank, i in enumerate(ranking):
        link_str = ','.join(page_names[j] for j in links[i])
        print(f"  {page_names[i]:>4} | {link_str:>15} | {v[i]:>18.6f} | {v_eig[i]:>16.6f}")
    
    print(f"\nDominant eigenvalue: {eigenvalues[idx].real:.6f} (should be 1.0)")
    print(f"Convergence: {iteration+1} iterations")
    print("\n✓ PageRank = dominant eigenvector of the web graph transition matrix.\n")


def experiment_2_mixing_time():
    """Spectral gap controls random walk mixing time."""
    print("=" * 60)
    print("EXPERIMENT 2: Spectral Gap → Mixing Time")
    print("=" * 60)
    
    np.random.seed(42)
    
    def make_graph_transition(n, edge_prob):
        """Make a random graph and return its transition matrix."""
        A = (np.random.random((n, n)) < edge_prob).astype(float)
        A = np.maximum(A, A.T)  # Symmetric
        np.fill_diagonal(A, 0)
        # Add self-loops to avoid periodicity issues
        A += np.eye(n)
        D = np.diag(np.sum(A, axis=1))
        P = np.linalg.inv(D) @ A
        return P
    
    def mixing_time(P, threshold=0.01):
        """Estimate mixing time: min t such that max_i |P^t[i,:] - π| < threshold."""
        n = P.shape[0]
        pi = np.ones(n) / n  # Stationary distribution (for doubly stochastic)
        
        # Compute via eigenvalues
        eigvals = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
        spectral_gap = 1 - eigvals[1].real  # Gap between 1st and 2nd eigenvalue
        
        # Theoretical mixing time ≈ log(n/threshold) / spectral_gap
        if spectral_gap > 0:
            t_theory = np.log(n / threshold) / spectral_gap
        else:
            t_theory = float('inf')
        
        # Empirical mixing time
        Pt = np.eye(n)
        for t in range(1, 5000):
            Pt = Pt @ P
            # Check if all rows are close to stationary
            max_dev = np.max(np.abs(Pt - pi))
            if max_dev < threshold:
                return t, spectral_gap, t_theory
        
        return 5000, spectral_gap, t_theory
    
    n = 30
    edge_probs = [0.05, 0.1, 0.15, 0.2, 0.3, 0.5, 0.8]
    
    print(f"\nRandom graphs with n = {n} vertices, varying edge probability:")
    print(f"\n{'p(edge)':>8} | {'Spectral gap':>13} | {'Mixing time':>12} | {'Theory ≈':>10} | {'Ratio':>8}")
    print("-" * 60)
    
    for p in edge_probs:
        P = make_graph_transition(n, p)
        t_mix, gap, t_theory = mixing_time(P)
        ratio = t_mix / t_theory if t_theory > 0 and t_theory < float('inf') else 0
        print(f"{p:>8.2f} | {gap:>13.6f} | {t_mix:>12} | {t_theory:>10.1f} | {ratio:>8.2f}")
    
    print("\n✓ Mixing time ∝ 1/spectral_gap, as predicted by spectral theory.")
    print("  Denser graphs → larger gap → faster mixing.\n")


def experiment_3_spectral_clustering():
    """Use the Fiedler vector (2nd eigenvector of Laplacian) for clustering."""
    print("=" * 60)
    print("EXPERIMENT 3: Spectral Clustering")
    print("=" * 60)
    
    np.random.seed(42)
    n = 40  # 20 nodes in each cluster
    
    # Create two clusters with sparse connections between them
    A = np.zeros((n, n))
    
    # Cluster 1: nodes 0-19, dense
    for i in range(20):
        for j in range(i+1, 20):
            if np.random.random() < 0.6:
                A[i, j] = A[j, i] = 1
    
    # Cluster 2: nodes 20-39, dense
    for i in range(20, 40):
        for j in range(i+1, 40):
            if np.random.random() < 0.6:
                A[i, j] = A[j, i] = 1
    
    # Between clusters: sparse
    for i in range(20):
        for j in range(20, 40):
            if np.random.random() < 0.05:
                A[i, j] = A[j, i] = 1
    
    # Graph Laplacian: L = D - A
    D = np.diag(np.sum(A, axis=1))
    L = D - A
    
    # Eigendecomposition
    eigvals, eigvecs = np.linalg.eigh(L)
    
    print(f"\nGraph with {n} nodes in 2 clusters")
    print(f"Intra-cluster edge prob: 0.6, Inter-cluster: 0.05")
    print(f"\nSmallest eigenvalues of Laplacian:")
    for i in range(5):
        print(f"  λ_{i} = {eigvals[i]:.6f}")
    
    print(f"\nAlgebraic connectivity (λ₁) = {eigvals[1]:.6f}")
    print(f"This is the spectral gap of the Laplacian.")
    
    # Fiedler vector (2nd eigenvector) gives the clustering
    fiedler = eigvecs[:, 1]
    
    # Classify based on sign of Fiedler vector
    cluster_1 = set(np.where(fiedler < 0)[0])
    cluster_2 = set(np.where(fiedler >= 0)[0])
    
    true_cluster_1 = set(range(20))
    true_cluster_2 = set(range(20, 40))
    
    # Accuracy (up to label permutation)
    acc1 = len(cluster_1 & true_cluster_1) + len(cluster_2 & true_cluster_2)
    acc2 = len(cluster_1 & true_cluster_2) + len(cluster_2 & true_cluster_1)
    accuracy = max(acc1, acc2) / n * 100
    
    print(f"\nSpectral clustering accuracy: {accuracy:.1f}%")
    print(f"Cluster 1 (Fiedler < 0): {sorted(cluster_1)[:10]}... ({len(cluster_1)} nodes)")
    print(f"Cluster 2 (Fiedler ≥ 0): {sorted(cluster_2)[:10]}... ({len(cluster_2)} nodes)")
    
    print("\n✓ The Fiedler vector (2nd eigenvector of Laplacian) reveals clusters.")
    print("  Just look at the sign — positive = cluster A, negative = cluster B.\n")


def experiment_4_phase_transition():
    """Spectral gap collapse at a phase transition."""
    print("=" * 60)
    print("EXPERIMENT 4: Spectral Gap Phase Transition")
    print("=" * 60)
    
    np.random.seed(42)
    n = 50
    
    # Erdős-Rényi random graph G(n,p)
    # Connected phase transition at p = ln(n)/n ≈ 0.078
    p_critical = np.log(n) / n
    
    p_values = np.linspace(0.02, 0.3, 20)
    
    print(f"\nErdős-Rényi G(n={n}, p) — connectivity transition at p* ≈ {p_critical:.4f}")
    print(f"\n{'p':>8} | {'Spectral gap':>13} | {'Connected?':>11} | {'2nd eigenval':>13}")
    print("-" * 55)
    
    for p in p_values:
        gaps = []
        connected_count = 0
        n_trials = 20
        
        for _ in range(n_trials):
            A = (np.random.random((n, n)) < p).astype(float)
            A = np.maximum(A, A.T)
            np.fill_diagonal(A, 0)
            
            D = np.diag(np.sum(A, axis=1))
            L = D - A
            eigvals = np.sort(np.linalg.eigvalsh(L))
            
            gaps.append(eigvals[1])
            if eigvals[1] > 0.01:
                connected_count += 1
        
        mean_gap = np.mean(gaps)
        pct_connected = connected_count / n_trials * 100
        marker = " ← p*" if abs(p - p_critical) < 0.015 else ""
        
        print(f"{p:>8.4f} | {mean_gap:>13.4f} | {pct_connected:>10.0f}% | {mean_gap:>13.4f}{marker}")
    
    print(f"\n✓ The spectral gap opens up at the connectivity threshold p* ≈ {p_critical:.4f}.")
    print("  This is a PHASE TRANSITION: disconnected (gap=0) → connected (gap>0).")
    print("  Spectral gaps detect phase transitions in graph structure.\n")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  MATHEMATICS CHEAT CODE #6: SPECTRAL METHODS")
    print("  'Eigenvalues know everything about your graph.'")
    print("=" * 60 + "\n")
    
    experiment_1_pagerank()
    experiment_2_mixing_time()
    experiment_3_spectral_clustering()
    experiment_4_phase_transition()
    
    print("=" * 60)
    print("SUMMARY: Eigenvalues encode global structure. The spectral")
    print("gap controls mixing time, connectivity, and clustering.")
    print("PageRank is just the dominant eigenvector. Phase transitions")
    print("appear as spectral gap collapse. If you have a graph,")
    print("compute its spectrum.")
    print("=" * 60)
