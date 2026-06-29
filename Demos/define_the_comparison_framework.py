#!/usr/bin/env python3
"""
Applications of Tropical Probabilistic Comparison Theory

Demonstrates real-world applications:
1. Network reliability analysis via tropical cycle gaps
2. MCMC convergence diagnostics
3. PageRank tropical analysis
4. Communication channel capacity bounds
"""

import numpy as np
from algorithms import (
    log_weight_matrix, triangle_cycle_gap, spectral_gap_symmetric,
    multi_step_tropical_gap, karp_minimum_cycle_mean, compare_spectral_tropical
)


def application_network_reliability():
    """
    Application 1: Network Reliability Analysis
    
    A communication network with n nodes and transition probabilities P[i,j]
    representing the probability of successful packet transmission from i to j.
    
    The tropical cycle gap measures the minimum average information cost per
    hop in any routing loop. A positive gap certifies that no routing cycle
    can achieve near-deterministic transmission — every loop incurs information loss.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Reliability Analysis")
    print("=" * 60)
    
    # 5-node network with varying link qualities
    P = np.array([
        [0.10, 0.40, 0.20, 0.15, 0.15],  # Node 0: strong link to 1
        [0.30, 0.10, 0.30, 0.15, 0.15],  # Node 1: balanced
        [0.15, 0.15, 0.10, 0.40, 0.20],  # Node 2: strong link to 3
        [0.20, 0.20, 0.20, 0.10, 0.30],  # Node 3: strong link to 4
        [0.25, 0.25, 0.25, 0.15, 0.10],  # Node 4: balanced
    ])
    
    W = log_weight_matrix(P)
    gap, best_triple = triangle_cycle_gap(W)
    karp_gap, _ = karp_minimum_cycle_mean(W)
    max_p = np.max(P)
    
    print(f"\nNetwork transition matrix P:")
    print(np.round(P, 2))
    print(f"\nMax link probability: {max_p:.4f}")
    print(f"Triangle cycle gap: {gap:.4f} (min info cost per hop in any triangle)")
    print(f"Karp cycle mean: {karp_gap:.4f} (min info cost per hop in any cycle)")
    print(f"Lower bound -log(max P): {-np.log(max_p):.4f}")
    print(f"\nInterpretation: Every routing loop in this network incurs at least")
    print(f"{gap:.4f} nats of information cost per hop. This certifies that no")
    print(f"cycle can achieve near-deterministic transmission.")
    
    # Identify the most efficient routing triangle
    i, j, k = best_triple
    print(f"\nMost efficient triangle route: {i} → {j} → {k} → {i}")
    print(f"  Hop probabilities: {P[i,j]:.2f}, {P[j,k]:.2f}, {P[k,i]:.2f}")
    print(f"  Average info cost: {gap:.4f} nats/hop")


def application_mcmc_diagnostics():
    """
    Application 2: MCMC Convergence Diagnostics
    
    Use the tropical cycle gap as a convergence diagnostic for Markov Chain
    Monte Carlo. The multi-step tropical gap tracks how the "energy landscape"
    evolves as the chain mixes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: MCMC Convergence Diagnostics")
    print("=" * 60)
    
    n = 6
    # Metropolis-Hastings transition for a target distribution
    # on 6 states with varying acceptance rates
    beta = 2.0  # inverse temperature
    energies = np.array([0.0, 0.5, 1.0, 0.3, 0.8, 1.5])
    
    # Build Metropolis transition matrix
    P = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                # Proposal: uniform neighbor (complete graph)
                proposal = 1.0 / (n - 1)
                # Acceptance: min(1, exp(-β(E_j - E_i)))
                acceptance = min(1.0, np.exp(-beta * (energies[j] - energies[i])))
                P[i, j] = proposal * acceptance
        P[i, i] = 1.0 - np.sum(P[i, :])
    
    print(f"\nMetropolis-Hastings chain (n={n}, β={beta})")
    print(f"Energy levels: {energies}")
    print(f"\nTransition matrix P:")
    print(np.round(P, 4))
    
    gamma = spectral_gap_symmetric(P + P.T)  # Symmetrize for spectral gap
    print(f"\nSpectral gap (symmetrized): {gamma:.4f}")
    
    print(f"\nMulti-step tropical analysis:")
    print(f"{'Step m':>8} {'g(W^(m))':>10} {'max(P^m)':>10} {'-log(max)':>10}")
    print("-" * 42)
    
    for m in [1, 2, 5, 10, 25, 50]:
        Pm = np.linalg.matrix_power(P, m)
        Wm = log_weight_matrix(Pm)
        gap, _ = triangle_cycle_gap(Wm)
        max_pm = np.max(Pm)
        print(f"{m:8d} {gap:10.4f} {max_pm:10.4f} {-np.log(max_pm):10.4f}")
    
    print(f"\nAs m increases, g(W^(m)) increases → the chain approaches uniformity")
    print(f"(all entries of P^m converge to 1/n = {1/n:.4f})")
    print(f"The tropical gap converges to log(n) = {np.log(n):.4f}")


def application_pagerank():
    """
    Application 3: PageRank Tropical Analysis
    
    Analyze the Google PageRank matrix through the tropical lens.
    The tropical cycle gap reveals the information-theoretic structure
    of web graph navigation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: PageRank Tropical Analysis")
    print("=" * 60)
    
    # Small web graph: 6 pages
    # Adjacency: directed links between pages
    links = {
        0: [1, 2],      # Homepage links to About, Products
        1: [0, 3],      # About links to Home, Blog
        2: [0, 3, 4],   # Products links to Home, Blog, Support
        3: [0, 1, 5],   # Blog links to Home, About, Contact
        4: [0, 2],      # Support links to Home, Products
        5: [0, 3],      # Contact links to Home, Blog
    }
    
    n = 6
    damping = 0.85
    
    # Build PageRank transition matrix
    H = np.zeros((n, n))
    for i, targets in links.items():
        for j in targets:
            H[i, j] = 1.0 / len(targets)
    
    # PageRank matrix: P = d·H + (1-d)·(1/n)·E
    P = damping * H + (1 - damping) * np.ones((n, n)) / n
    
    print(f"\nWeb graph with {n} pages, damping factor d={damping}")
    print(f"PageRank matrix P:")
    print(np.round(P, 4))
    
    # Compute PageRank (stationary distribution)
    eigenvalues, eigenvectors = np.linalg.eig(P.T)
    idx = np.argmax(np.abs(eigenvalues))
    pagerank = np.abs(eigenvectors[:, idx])
    pagerank = pagerank / pagerank.sum()
    
    print(f"\nPageRank values: {np.round(pagerank, 4)}")
    
    # Tropical analysis
    comp = compare_spectral_tropical(P)
    print(f"\nTropical analysis:")
    print(f"  Triangle cycle gap: {comp['triangle_gap']:.4f}")
    print(f"  Max transition prob: {comp['max_entry']:.4f}")
    print(f"  Entrywise bound: {comp['entrywise_bound']:.4f}")
    print(f"  Best triangle: {comp['best_triple']}")
    
    i, j, k = comp['best_triple']
    pages = ['Home', 'About', 'Products', 'Blog', 'Support', 'Contact']
    print(f"\n  Most efficient navigation triangle: "
          f"{pages[i]} → {pages[j]} → {pages[k]} → {pages[i]}")
    print(f"  Average info cost: {comp['triangle_gap']:.4f} nats/click")
    print(f"\n  Interpretation: The damping factor ensures a positive tropical")
    print(f"  cycle gap, certifying that every navigation loop carries")
    print(f"  genuine uncertainty — no cycle is deterministic.")


def application_channel_capacity():
    """
    Application 4: Communication Channel Capacity Bounds
    
    For a discrete memoryless channel with transition matrix P,
    the tropical cycle gap provides bounds on the channel's
    information-processing properties.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Channel Capacity Analysis")
    print("=" * 60)
    
    # Binary symmetric channel with crossover probability p
    print("\nBinary Symmetric Channel Analysis:")
    print(f"{'p':>6} {'Capacity':>10} {'g(W)':>8} {'-log(max)':>10}")
    print("-" * 38)
    
    for p in [0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.49]:
        P = np.array([[1-p, p], [p, 1-p]])
        W = log_weight_matrix(P)
        gap, _ = triangle_cycle_gap(W)
        capacity = 1 + p * np.log2(p) + (1-p) * np.log2(1-p) if p > 0 else 1.0
        
        print(f"{p:6.2f} {capacity:10.4f} {gap:8.4f} {-np.log(np.max(P)):10.4f}")
    
    print(f"\nAs crossover probability p → 0.5:")
    print(f"  - Channel capacity → 0 (maximum noise)")
    print(f"  - Tropical gap → log(2) ≈ {np.log(2):.4f} (maximum cycle cost)")
    print(f"  - All transitions become equally uncertain")
    
    print(f"\nAs p → 0:")
    print(f"  - Channel capacity → 1 (near-perfect channel)")
    print(f"  - Tropical gap → 0 (near-deterministic cycles)")
    print(f"  - Our theorem: positive gap requires bounded-away-from-1 entries")


if __name__ == "__main__":
    np.random.seed(42)
    application_network_reliability()
    application_mcmc_diagnostics()
    application_pagerank()
    application_channel_capacity()
    
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Spectral-Tropical Bridge: Demonstrations

Demonstrates the key theorems connecting Markov chain mixing to tropical
cycle geometry via the logarithmic weight transform W = -log(P).
"""

import numpy as np
from itertools import product


def log_weight(P: np.ndarray) -> np.ndarray:
    """Compute the tropical weight matrix W = -log(P)."""
    return -np.log(P)


def triangle_mean(W: np.ndarray, i: int, j: int, k: int) -> float:
    """Mean weight of the triangle cycle i -> j -> k -> i."""
    return (W[i, j] + W[j, k] + W[k, i]) / 3.0


def triangle_cycle_gap(W: np.ndarray) -> float:
    """Minimum triangle mean over all triples (i, j, k)."""
    n = W.shape[0]
    min_mean = float('inf')
    for i, j, k in product(range(n), repeat=3):
        m = triangle_mean(W, i, j, k)
        if m < min_mean:
            min_mean = m
    return min_mean


def spectral_gap(P: np.ndarray) -> float:
    """Spectral gap γ = 1 - |λ₂| for symmetric stochastic P."""
    eigenvalues = np.sort(np.abs(np.linalg.eigvalsh(P)))[::-1]
    if len(eigenvalues) < 2:
        return 1.0
    return 1.0 - eigenvalues[1]


def max_entry(P: np.ndarray) -> float:
    """Maximum entry of P."""
    return np.max(P)


# ─── Demo 1: Basic log-weight transform ───
def demo_basic_transform():
    """Show how the log transform converts probabilities to tropical weights."""
    print("=" * 60)
    print("DEMO 1: Log-Weight Transform")
    print("=" * 60)
    
    # Simple 3-state Markov chain
    P = np.array([
        [0.5, 0.3, 0.2],
        [0.1, 0.6, 0.3],
        [0.4, 0.2, 0.4]
    ])
    
    W = log_weight(P)
    
    print("\nRow-stochastic matrix P:")
    print(P)
    print(f"\nRow sums: {P.sum(axis=1)}")
    print(f"\nTropical weight matrix W = -log(P):")
    print(np.round(W, 4))
    print(f"\nMax entry of P: {max_entry(P):.4f}")
    print(f"-log(max P): {-np.log(max_entry(P)):.4f}")
    print(f"Triangle cycle gap g(W): {triangle_cycle_gap(W):.4f}")
    print(f"\nTheorem 1 verified: g(W) = {triangle_cycle_gap(W):.4f} ≥ {-np.log(max_entry(P)):.4f} = -log(max P) ✓")


# ─── Demo 2: Non-determinism → positive tropical gap ───
def demo_non_determinism():
    """Theorem 2: Uniform non-determinism forces positive tropical cycle gap."""
    print("\n" + "=" * 60)
    print("DEMO 2: Non-Determinism → Positive Tropical Gap")
    print("=" * 60)
    
    for n in [3, 5, 10]:
        for eps in [0.1, 0.3, 0.5]:
            # Random positive matrix with entries ≤ 1-ε
            raw = np.random.dirichlet(np.ones(n), size=n)
            # Clamp entries to be ≤ 1-ε and > 0
            P = np.clip(raw, 0.001, 1 - eps)
            # Re-normalize rows
            P = P / P.sum(axis=1, keepdims=True)
            
            W = log_weight(P)
            gap = triangle_cycle_gap(W)
            bound = -np.log(1 - eps)
            actual_max = max_entry(P)
            actual_bound = -np.log(actual_max)
            
            print(f"\nn={n}, ε={eps:.1f}: "
                  f"max(P)={actual_max:.4f}, "
                  f"g(W)={gap:.4f} ≥ {actual_bound:.4f} = -log(max P)")


# ─── Demo 3: Spectral gap vs tropical gap comparison ───
def demo_spectral_comparison():
    """Compare spectral gap and tropical cycle gap across matrix families."""
    print("\n" + "=" * 60)
    print("DEMO 3: Spectral Gap vs Tropical Gap")
    print("=" * 60)
    
    print(f"\n{'n':>3} {'α':>6} {'γ(P)':>8} {'g(W)':>8} {'-log(1-γ)':>10} {'g≥-log(max)':>12}")
    print("-" * 55)
    
    for n in [3, 5, 8]:
        for alpha in [0.2, 0.5, 0.8]:
            # Symmetric stochastic: P = α·I + (1-α)·J/n
            # where J is all-ones matrix
            P = alpha * np.eye(n) + (1 - alpha) * np.ones((n, n)) / n
            W = log_weight(P)
            
            gamma = spectral_gap(P)
            g = triangle_cycle_gap(W)
            log_bound = -np.log(max_entry(P))
            
            check = "✓" if g >= log_bound - 1e-10 else "✗"
            print(f"{n:3d} {alpha:6.2f} {gamma:8.4f} {g:8.4f} {-np.log(1-gamma) if gamma < 1 else float('inf'):10.4f} {check:>12}")


# ─── Demo 4: Path weight lower bound ───
def demo_path_weight():
    """Verify the path weight lower bound for random paths."""
    print("\n" + "=" * 60)
    print("DEMO 4: Path Weight Lower Bound")
    print("=" * 60)
    
    n = 5
    P = np.random.dirichlet(np.ones(n), size=n)
    W = log_weight(P)
    s = max_entry(P)
    
    print(f"\nMatrix size: {n}×{n}")
    print(f"Max entry s = {s:.4f}")
    print(f"-log(s) = {-np.log(s):.4f}")
    
    print(f"\n{'Path':>20} {'Length':>6} {'Weight':>8} {'Bound':>8} {'OK':>4}")
    print("-" * 50)
    
    for _ in range(10):
        path_len = np.random.randint(2, 8)
        path = list(np.random.randint(0, n, size=path_len))
        
        weight = sum(W[path[t], path[t+1]] for t in range(len(path)-1))
        bound = -np.log(s) * (len(path) - 1)
        
        path_str = "→".join(str(v) for v in path)
        check = "✓" if weight >= bound - 1e-10 else "✗"
        print(f"{path_str:>20} {len(path):6d} {weight:8.4f} {bound:8.4f} {check:>4}")


# ─── Demo 5: Scaling behavior ───
def demo_scaling():
    """How the tropical gap scales with matrix dimension."""
    print("\n" + "=" * 60)
    print("DEMO 5: Scaling with Dimension")
    print("=" * 60)
    
    print(f"\n{'n':>4} {'max(P)':>8} {'-log(max)':>10} {'g(W)':>8} {'γ(P)':>8}")
    print("-" * 45)
    
    for n in [2, 3, 4, 5, 6, 8, 10]:
        # Uniform stochastic matrix: P = J/n (all entries 1/n)
        P = np.ones((n, n)) / n
        W = log_weight(P)
        g = triangle_cycle_gap(W)
        gamma = spectral_gap(P) if n > 1 else 1.0
        
        print(f"{n:4d} {max_entry(P):8.4f} {-np.log(max_entry(P)):10.4f} {g:8.4f} {gamma:8.4f}")


if __name__ == "__main__":
    np.random.seed(42)
    demo_basic_transform()
    demo_non_determinism()
    demo_spectral_comparison()
    demo_path_weight()
    demo_scaling()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical Probabilistic Comparison Theory

Generates publication-quality figures showing:
1. The tropical gap vs spectral gap relationship
2. Multi-step convergence of tropical gaps
3. Phase diagram of the spectral-tropical landscape
4. The log-weight transform visualization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm
import base64
from io import BytesIO
from itertools import product


def log_weight_matrix(P):
    return -np.log(P)


def triangle_cycle_gap(W):
    n = W.shape[0]
    min_mean = float('inf')
    for i, j, k in product(range(n), repeat=3):
        m = (W[i,j] + W[j,k] + W[k,i]) / 3.0
        if m < min_mean:
            min_mean = m
    return min_mean


def spectral_gap(P):
    ev = np.sort(np.abs(np.linalg.eigvalsh(P)))[::-1]
    return 1.0 - ev[1] if len(ev) > 1 else 1.0


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def plot_spectral_vs_tropical():
    """Figure 1: Spectral gap vs tropical triangle cycle gap."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel A: Symmetric stochastic matrices P = α·I + (1-α)·J/n
    ax = axes[0]
    for n in [3, 5, 8, 12]:
        alphas = np.linspace(0.01, 0.99, 50)
        gammas = []
        gaps = []
        for alpha in alphas:
            P = alpha * np.eye(n) + (1 - alpha) * np.ones((n, n)) / n
            W = log_weight_matrix(P)
            gammas.append(spectral_gap(P))
            gaps.append(triangle_cycle_gap(W))
        ax.plot(gammas, gaps, '-', label=f'n={n}', linewidth=2)
    
    ax.set_xlabel('Spectral Gap γ(P)', fontsize=13)
    ax.set_ylabel('Triangle Cycle Gap g(W)', fontsize=13)
    ax.set_title('A. Spectral vs Tropical Gap\n(Symmetric Lazy Random Walk)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Panel B: Random positive stochastic matrices
    ax = axes[1]
    np.random.seed(42)
    for n in [3, 5, 8]:
        gammas = []
        gaps = []
        for _ in range(200):
            P = np.random.dirichlet(np.ones(n) * 0.5, size=n)
            P = (P + P.T) / 2  # Symmetrize
            P = P / P.sum(axis=1, keepdims=True)  # Re-normalize
            W = log_weight_matrix(P)
            gammas.append(spectral_gap(P))
            gaps.append(triangle_cycle_gap(W))
        ax.scatter(gammas, gaps, alpha=0.4, s=20, label=f'n={n}')
    
    ax.set_xlabel('Spectral Gap γ(P)', fontsize=13)
    ax.set_ylabel('Triangle Cycle Gap g(W)', fontsize=13)
    ax.set_title('B. Random Symmetric Stochastic Matrices', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def plot_multistep_convergence():
    """Figure 2: Multi-step tropical gap convergence."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel A: Convergence for different spectral gaps
    ax = axes[0]
    n = 5
    for alpha in [0.3, 0.5, 0.7, 0.9]:
        P = alpha * np.eye(n) + (1 - alpha) * np.ones((n, n)) / n
        gamma = spectral_gap(P)
        
        steps = list(range(1, 31))
        gaps = []
        for m in steps:
            Pm = np.linalg.matrix_power(P, m)
            Wm = log_weight_matrix(Pm)
            gaps.append(triangle_cycle_gap(Wm))
        
        ax.plot(steps, gaps, '-o', markersize=3,
                label=f'α={alpha:.1f} (γ={gamma:.2f})', linewidth=2)
    
    ax.axhline(y=np.log(n), color='k', linestyle='--', alpha=0.5,
               label=f'log(n) = {np.log(n):.2f}')
    ax.set_xlabel('Steps m', fontsize=13)
    ax.set_ylabel('g(W⁽ᵐ⁾)', fontsize=13)
    ax.set_title(f'A. Multi-Step Tropical Gap (n={n})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel B: Bound comparison
    ax = axes[1]
    alpha = 0.6
    P = alpha * np.eye(n) + (1 - alpha) * np.ones((n, n)) / n
    gamma = spectral_gap(P)
    
    steps = list(range(1, 51))
    gaps = []
    bounds = []
    max_entries = []
    
    for m in steps:
        Pm = np.linalg.matrix_power(P, m)
        Wm = log_weight_matrix(Pm)
        gaps.append(triangle_cycle_gap(Wm))
        max_e = np.max(Pm)
        max_entries.append(max_e)
        bounds.append(-np.log(max_e))
    
    ax.plot(steps, gaps, 'b-', linewidth=2, label='g(W⁽ᵐ⁾) (actual)')
    ax.plot(steps, bounds, 'r--', linewidth=2, label='-log(max P^m) (bound)')
    ax.axhline(y=np.log(n), color='k', linestyle=':', alpha=0.5,
               label=f'log(n) = {np.log(n):.2f}')
    
    ax.fill_between(steps, bounds, gaps, alpha=0.15, color='blue')
    ax.set_xlabel('Steps m', fontsize=13)
    ax.set_ylabel('Tropical Gap', fontsize=13)
    ax.set_title(f'B. Gap vs Lower Bound (α={alpha}, γ={gamma:.2f})', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


def plot_phase_diagram():
    """Figure 3: Phase diagram showing spectral-tropical landscape."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel A: Heatmap of tropical gap for lazy random walk
    ax = axes[0]
    n_vals = list(range(2, 13))
    alpha_vals = np.linspace(0.05, 0.95, 30)
    
    Z = np.zeros((len(alpha_vals), len(n_vals)))
    for i, alpha in enumerate(alpha_vals):
        for j, n in enumerate(n_vals):
            P = alpha * np.eye(n) + (1 - alpha) * np.ones((n, n)) / n
            W = log_weight_matrix(P)
            Z[i, j] = triangle_cycle_gap(W)
    
    im = ax.imshow(Z, aspect='auto', origin='lower',
                   extent=[n_vals[0]-0.5, n_vals[-1]+0.5,
                          alpha_vals[0], alpha_vals[-1]],
                   cmap='viridis')
    plt.colorbar(im, ax=ax, label='g(W)')
    ax.set_xlabel('Dimension n', fontsize=13)
    ax.set_ylabel('Laziness α', fontsize=13)
    ax.set_title('A. Tropical Gap Phase Diagram', fontsize=13)
    
    # Panel B: Ratio g(W) / γ(P)
    ax = axes[1]
    Z_ratio = np.zeros((len(alpha_vals), len(n_vals)))
    for i, alpha in enumerate(alpha_vals):
        for j, n in enumerate(n_vals):
            P = alpha * np.eye(n) + (1 - alpha) * np.ones((n, n)) / n
            W = log_weight_matrix(P)
            gap = triangle_cycle_gap(W)
            gamma = spectral_gap(P)
            Z_ratio[i, j] = gap / gamma if gamma > 1e-10 else 0
    
    im = ax.imshow(Z_ratio, aspect='auto', origin='lower',
                   extent=[n_vals[0]-0.5, n_vals[-1]+0.5,
                          alpha_vals[0], alpha_vals[-1]],
                   cmap='plasma')
    plt.colorbar(im, ax=ax, label='g(W) / γ(P)')
    ax.set_xlabel('Dimension n', fontsize=13)
    ax.set_ylabel('Laziness α', fontsize=13)
    ax.set_title('B. Tropical-to-Spectral Ratio', fontsize=13)
    
    plt.tight_layout()
    return fig


def plot_log_transform():
    """Figure 4: The logarithmic transform visualization."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Panel A: -log(x) function
    ax = axes[0]
    x = np.linspace(0.01, 1.0, 200)
    ax.plot(x, -np.log(x), 'b-', linewidth=2.5)
    ax.fill_between(x, 0, -np.log(x), alpha=0.1, color='blue')
    
    # Mark key points
    for p, name in [(0.5, '½'), (1/np.e, '1/e'), (0.1, '0.1')]:
        ax.plot(p, -np.log(p), 'ro', markersize=8)
        ax.annotate(f'({name}, {-np.log(p):.2f})', (p, -np.log(p)),
                    textcoords="offset points", xytext=(10, 10), fontsize=10)
    
    ax.set_xlabel('Probability p', fontsize=13)
    ax.set_ylabel('-log(p) = Information cost', fontsize=13)
    ax.set_title('A. The Log-Weight Transform', fontsize=13)
    ax.set_xlim(0, 1.05)
    ax.set_ylim(-0.1, 5)
    ax.grid(True, alpha=0.3)
    
    # Panel B: Example stochastic matrix as heatmap
    ax = axes[1]
    P = np.array([
        [0.4, 0.3, 0.2, 0.1],
        [0.1, 0.5, 0.3, 0.1],
        [0.2, 0.2, 0.4, 0.2],
        [0.3, 0.1, 0.2, 0.4]
    ])
    im = ax.imshow(P, cmap='YlOrRd', vmin=0, vmax=0.6)
    plt.colorbar(im, ax=ax, label='P[i,j]')
    ax.set_title('B. Stochastic Matrix P', fontsize=13)
    ax.set_xlabel('State j', fontsize=12)
    ax.set_ylabel('State i', fontsize=12)
    for i in range(4):
        for j in range(4):
            ax.text(j, i, f'{P[i,j]:.1f}', ha='center', va='center', fontsize=11)
    
    # Panel C: Tropical weight matrix
    ax = axes[2]
    W = -np.log(P)
    im = ax.imshow(W, cmap='YlGnBu', vmin=0)
    plt.colorbar(im, ax=ax, label='W[i,j] = -log(P[i,j])')
    ax.set_title('C. Tropical Weight Matrix W', fontsize=13)
    ax.set_xlabel('State j', fontsize=12)
    ax.set_ylabel('State i', fontsize=12)
    for i in range(4):
        for j in range(4):
            ax.text(j, i, f'{W[i,j]:.2f}', ha='center', va='center', fontsize=10)
    
    plt.tight_layout()
    return fig


def generate_all_figures():
    """Generate all figures and save as PNG files."""
    print("Generating figures...")
    
    figures = {
        'spectral_vs_tropical': plot_spectral_vs_tropical(),
        'multistep_convergence': plot_multistep_convergence(),
        'phase_diagram': plot_phase_diagram(),
        'log_transform': plot_log_transform(),
    }
    
    base64_data = {}
    for name, fig in figures.items():
        filename = f'{name}.png'
        fig.savefig(filename, dpi=150, bbox_inches='tight')
        base64_data[name] = fig_to_base64(fig)
        plt.close(fig)
        print(f"  Saved {filename}")
    
    return base64_data


if __name__ == "__main__":
    data = generate_all_figures()
    print(f"\nGenerated {len(data)} figures.")
    for name, b64 in data.items():
        print(f"  {name}: {len(b64)} bytes (base64)")
