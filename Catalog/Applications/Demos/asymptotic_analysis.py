"""
Applications of the Markov-Tropical Bridge Theorem

Real-world applications demonstrating how tropical cycle geometry
provides certificates for Markov chain mixing properties.
"""

import numpy as np


def pagerank_tropical_analysis(
    adjacency: np.ndarray,
    damping: float = 0.85
) -> dict:
    """
    Apply tropical analysis to a PageRank-style random walk.
    
    The PageRank transition matrix is:
        P = d * A * D^{-1} + (1-d)/n * J
    where A is the adjacency matrix, D is the diagonal degree matrix,
    d is the damping factor, and J is the all-ones matrix.
    
    Args:
        adjacency: Binary adjacency matrix of the web graph
        damping: PageRank damping factor (default 0.85)
    
    Returns:
        Tropical analysis results
    """
    n = adjacency.shape[0]
    
    # Build transition matrix
    degrees = adjacency.sum(axis=1)
    degrees[degrees == 0] = 1  # handle dangling nodes
    
    P = damping * adjacency / degrees[:, np.newaxis] + (1 - damping) / n
    
    W = -np.log(P)
    
    # Triangle cycle mean
    min_tcm = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = (W[i,j] + W[j,k] + W[k,i]) / 3
                min_tcm = min(min_tcm, val)
    
    # Mixing analysis for various m
    results = []
    for m in [1, 5, 10, 20, 50]:
        Pm = np.linalg.matrix_power(P, m)
        alpha = Pm.max()
        barrier = -np.log(alpha) / m
        results.append({
            'm': m,
            'alpha': alpha,
            'barrier': barrier,
            'tcm': min_tcm,
            'holds': barrier <= min_tcm + 1e-10
        })
    
    return {
        'n': n,
        'damping': damping,
        'triangle_cycle_mean': min_tcm,
        'log_n': np.log(n),
        'mixing_results': results
    }


def metastability_detection(P: np.ndarray, threshold: float = 0.5) -> dict:
    """
    Detect metastable states using tropical cycle geometry.
    
    States with high self-loop tropical cost W(i,i) = -log P(i,i)
    are "easy to leave" (low probability of staying), while states
    with low W(i,i) are "traps" (high probability of staying).
    
    The tropical cycle mean provides a global certificate of how
    quickly the chain mixes, complementing local metastability analysis.
    
    Args:
        P: Positive row-stochastic matrix
        threshold: Threshold for classifying metastable states
    
    Returns:
        Metastability analysis results
    """
    n = P.shape[0]
    W = -np.log(P)
    
    # Self-loop costs
    self_costs = np.diag(W)
    
    # Classify states
    metastable = self_costs < threshold  # low cost = high staying probability
    
    # Triangle cycle mean
    min_tcm = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = (W[i,j] + W[j,k] + W[k,i]) / 3
                min_tcm = min(min_tcm, val)
    
    return {
        'n': n,
        'self_loop_costs': self_costs,
        'metastable_states': np.where(metastable)[0].tolist(),
        'triangle_cycle_mean': min_tcm,
        'min_self_cost': self_costs.min(),
        'max_self_cost': self_costs.max(),
    }


def channel_capacity_bound(P: np.ndarray) -> dict:
    """
    Bound channel capacity using tropical cycle geometry.
    
    For a discrete memoryless channel with transition matrix P,
    the tropical cycle mean of -log P provides information about
    the minimum surprise along any cycle, which relates to the
    channel's information-carrying capacity.
    
    Args:
        P: Channel transition matrix (rows = inputs, cols = outputs)
    
    Returns:
        Channel analysis results
    """
    n = P.shape[0]
    W = -np.log(P)
    
    # Triangle cycle mean
    min_tcm = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = (W[i,j] + W[j,k] + W[k,i]) / 3
                min_tcm = min(min_tcm, val)
    
    # Entropy of each row (conditional entropy)
    row_entropies = -np.sum(P * np.log(P), axis=1)
    
    return {
        'n': n,
        'triangle_cycle_mean': min_tcm,
        'log_n': np.log(n),
        'avg_conditional_entropy': row_entropies.mean(),
        'min_row_entropy': row_entropies.min(),
        'max_row_entropy': row_entropies.max(),
    }


if __name__ == "__main__":
    print("="*60)
    print("  APPLICATIONS OF THE MARKOV-TROPICAL BRIDGE")
    print("="*60)
    
    # Application 1: PageRank-style analysis
    print("\n--- Application 1: Web Graph (PageRank) ---")
    # Small web graph
    adj = np.array([
        [0, 1, 1, 0, 0],
        [1, 0, 0, 1, 0],
        [0, 1, 0, 1, 1],
        [1, 0, 0, 0, 1],
        [0, 0, 1, 1, 0]
    ], dtype=float)
    
    result = pagerank_tropical_analysis(adj, damping=0.85)
    print(f"  Graph: {result['n']} nodes")
    print(f"  Triangle cycle mean: {result['triangle_cycle_mean']:.4f}")
    print(f"  log(n): {result['log_n']:.4f}")
    print(f"  Mixing progression:")
    for r in result['mixing_results']:
        print(f"    m={r['m']:3d}: α={r['alpha']:.4f}, "
              f"barrier={r['barrier']:.4f}, holds={r['holds']}")
    
    # Application 2: Metastability
    print("\n--- Application 2: Metastability Detection ---")
    P_meta = np.array([
        [0.95, 0.04, 0.01],
        [0.03, 0.92, 0.05],
        [0.02, 0.03, 0.95]
    ])
    
    meta = metastability_detection(P_meta)
    print(f"  Self-loop costs: {meta['self_loop_costs']}")
    print(f"  Metastable states: {meta['metastable_states']}")
    print(f"  Triangle cycle mean: {meta['triangle_cycle_mean']:.4f}")
    
    # Application 3: Channel capacity
    print("\n--- Application 3: Channel Capacity ---")
    P_channel = np.array([
        [0.7, 0.2, 0.1],
        [0.1, 0.8, 0.1],
        [0.2, 0.1, 0.7]
    ])
    
    chan = channel_capacity_bound(P_channel)
    print(f"  Triangle cycle mean: {chan['triangle_cycle_mean']:.4f}")
    print(f"  log(n): {chan['log_n']:.4f}")
    print(f"  Avg conditional entropy: {chan['avg_conditional_entropy']:.4f}")
    
    print("\n" + "="*60)
    print("  ALL APPLICATIONS DEMONSTRATED")
    print("="*60)


"""
Markov-Tropical Bridge: Numerical Demonstrations

Demonstrates the theorem that for a positive row-stochastic matrix P,
if all m-step transition probabilities satisfy P^m(i,j) ≤ α, then:

    triangleCyc(-log P) ≥ -log(α) / m

This is the tropicalization of mixing decay into cycle energy barriers.
"""

import numpy as np
from typing import Tuple


def tropical_cost(P: np.ndarray) -> np.ndarray:
    """Compute the tropical cost matrix W(i,j) = -log(P(i,j))."""
    return -np.log(P)


def triangle_mean(W: np.ndarray, i: int, j: int, k: int) -> float:
    """Mean weight of the triangle cycle i → j → k → i."""
    return (W[i, j] + W[j, k] + W[k, i]) / 3.0


def triangle_cyc(W: np.ndarray) -> float:
    """Minimum triangle cycle mean over all triples (i,j,k)."""
    n = W.shape[0]
    min_val = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = triangle_mean(W, i, j, k)
                if val < min_val:
                    min_val = val
    return min_val


def verify_theorem(P: np.ndarray, m: int, name: str = "Matrix") -> dict:
    """
    Verify the multi-step tropical gap theorem for a given matrix and step count.
    
    Returns a dict with the key quantities and whether the bound holds.
    """
    n = P.shape[0]
    Pm = np.linalg.matrix_power(P, m)
    alpha = Pm.max()
    
    W = tropical_cost(P)
    tcyc = triangle_cyc(W)
    
    neg_log_alpha = -np.log(alpha)
    bound = neg_log_alpha / m
    
    holds = bound <= tcyc + 1e-12  # small tolerance for floating point
    
    result = {
        'name': name,
        'n': n,
        'm': m,
        'alpha': alpha,
        '-log(alpha)': neg_log_alpha,
        '-log(alpha)/m': bound,
        'triangleCyc': tcyc,
        'gap': tcyc - bound,
        'holds': holds,
    }
    return result


def print_result(r: dict) -> None:
    """Pretty-print a verification result."""
    status = "✓ VERIFIED" if r['holds'] else "✗ FAILED"
    print(f"\n{'='*60}")
    print(f"  {r['name']} (n={r['n']}, m={r['m']})")
    print(f"{'='*60}")
    print(f"  max P^m entry (α)     = {r['alpha']:.6f}")
    print(f"  -log(α)               = {r['-log(alpha)']:.6f}")
    print(f"  -log(α) / m           = {r['-log(alpha)/m']:.6f}")
    print(f"  triangleCyc(-log P)   = {r['triangleCyc']:.6f}")
    print(f"  gap (≥ 0 if theorem)  = {r['gap']:.6f}")
    print(f"  Status: {status}")


def demo_uniform_matrix() -> None:
    """Demo 1: Uniform doubly-stochastic matrix (all entries 1/n)."""
    print("\n" + "="*60)
    print("  DEMO 1: Uniform Matrix (P = 1/n · J)")
    print("="*60)
    
    for n in [2, 3, 4, 5]:
        P = np.ones((n, n)) / n
        for m in [1, 2, 5, 10]:
            r = verify_theorem(P, m, f"Uniform {n}×{n}")
            print_result(r)


def demo_near_identity() -> None:
    """Demo 2: Near-identity matrix (mostly stays, small transition probability)."""
    print("\n" + "="*60)
    print("  DEMO 2: Near-Identity Matrix P = (1-ε)I + ε/(n-1)·(J-I)")
    print("="*60)
    
    n = 3
    eps = 0.1
    P = eps / (n - 1) * np.ones((n, n))
    np.fill_diagonal(P, 1 - eps)
    
    print(f"\n  P (ε={eps}):")
    print(f"  {P}")
    
    for m in [1, 2, 5, 10, 50, 100]:
        r = verify_theorem(P, m, f"Near-Id (ε={eps})")
        print_result(r)


def demo_cyclic_permutation() -> None:
    """Demo 3: Near-cyclic permutation matrix."""
    print("\n" + "="*60)
    print("  DEMO 3: Near-Cyclic Permutation")
    print("="*60)
    
    n = 3
    eps = 0.05
    # Cyclic: state 0→1→2→0 with probability 1-2ε, self-loop ε, reverse ε
    P = np.array([
        [eps, 1-2*eps, eps],
        [eps, eps, 1-2*eps],
        [1-2*eps, eps, eps]
    ])
    
    print(f"\n  P (ε={eps}):")
    print(f"  {P}")
    
    for m in [1, 2, 3, 6, 9, 12, 30]:
        r = verify_theorem(P, m, f"Cyclic (ε={eps})")
        print_result(r)


def demo_extremal_ceiling() -> None:
    """Demo 4: Convergence to the information-theoretic ceiling log(n)."""
    print("\n" + "="*60)
    print("  DEMO 4: Convergence to Information-Theoretic Ceiling")
    print("="*60)
    print("  For large m, α(m) → 1/n, so -log(α)/m → 0")
    print("  But -log(α) → log(n) (the entropy ceiling)")
    
    n = 4
    eps = 0.2
    P = eps / (n - 1) * np.ones((n, n))
    np.fill_diagonal(P, 1 - eps)
    
    W = tropical_cost(P)
    tcyc = triangle_cyc(W)
    
    print(f"\n  n = {n}, triangleCyc(-log P) = {tcyc:.6f}")
    print(f"  log(n) = {np.log(n):.6f}")
    print(f"\n  {'m':>5} {'α(m)':>10} {'-log α':>10} {'-log α/m':>10} {'triangleCyc':>12} {'holds':>6}")
    print(f"  {'-'*55}")
    
    for m in [1, 2, 5, 10, 20, 50, 100, 500]:
        Pm = np.linalg.matrix_power(P, m)
        alpha = Pm.max()
        neg_log_a = -np.log(alpha)
        bound = neg_log_a / m
        holds = bound <= tcyc + 1e-12
        print(f"  {m:5d} {alpha:10.6f} {neg_log_a:10.6f} {bound:10.6f} {tcyc:12.6f} {'✓' if holds else '✗':>6}")
    
    print(f"\n  As m → ∞: α → 1/{n} = {1/n:.4f}, -log(α) → log({n}) = {np.log(n):.4f}")


def demo_tightness() -> None:
    """Demo 5: Show the bound is tight for m=1."""
    print("\n" + "="*60)
    print("  DEMO 5: Tightness of the Bound (m=1)")
    print("="*60)
    
    for n in [2, 3, 4, 5]:
        # Uniform matrix achieves equality
        P = np.ones((n, n)) / n
        W = tropical_cost(P)
        tcyc = triangle_cyc(W)
        neg_log_alpha = np.log(n)  # α = 1/n for uniform, -log α = log n
        
        print(f"\n  n={n}: -log(α) = log({n}) = {neg_log_alpha:.6f}, "
              f"triangleCyc = {tcyc:.6f}, ratio = {tcyc/neg_log_alpha:.6f}")


if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Markov-Tropical Bridge: Numerical Demonstrations        ║")
    print("║                                                          ║")
    print("║  Theorem: -log(α)/m ≤ triangleCyc(-log P)               ║")
    print("║  where P^m(i,j) ≤ α for all i,j                         ║")
    print("╚════════════════════════════════════════════════════════════╝")
    
    demo_uniform_matrix()
    demo_near_identity()
    demo_cyclic_permutation()
    demo_extremal_ceiling()
    demo_tightness()
    
    print("\n" + "="*60)
    print("  ALL DEMONSTRATIONS COMPLETE")
    print("="*60)


"""Generate PACKAGE.json with all artifacts embedded."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import (
    plot_mixing_vs_barrier,
    plot_state_space_comparison, 
    plot_phase_diagram,
    plot_tropical_cost_heatmap
)

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

print("Generating visualizations...")
viz1 = plot_mixing_vs_barrier()
viz2 = plot_state_space_comparison()
viz3 = plot_phase_diagram()
viz4 = plot_tropical_cost_heatmap()

print("Reading source files...")
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algo_code = read_file('algorithms.py')
app_code = read_file('applications.py')
lean_code = read_file('Catalog/Tropical/MarkovTropicalBridge.lean')

package = {
    "title": "The Markov–Tropical Bridge: Mixing Bounds as Cycle Energy Barriers",
    "domain": "Tropical Geometry / Markov Chains",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Markov-Tropical Bridge Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": app_code
        }
    ],
    "algorithms": [
        {
            "name": "Triangle Cycle Mean Computation",
            "pseudocode": "Input: Positive matrix P\\nOutput: triangleCyc(-log P)\\n\\n1. W ← -log(P)\\n2. min_val ← +∞\\n3. for i,j,k in states:\\n4.   val ← (W[i,j] + W[j,k] + W[k,i]) / 3\\n5.   min_val ← min(min_val, val)\\n6. return min_val\\n\\nComplexity: O(n³) time, O(n²) space",
            "code": algo_code
        }
    ],
    "visualizations": [
        {
            "name": "Mixing Decay vs Tropical Energy Barrier",
            "data": viz1
        },
        {
            "name": "Tropical Barriers Across State Space Sizes",
            "data": viz2
        },
        {
            "name": "Phase Diagram: Spectral Gap vs Tropical Cycle Mean",
            "data": viz3
        },
        {
            "name": "Tropicalization: Probabilities → Costs",
            "data": viz4
        }
    ],
    "lean_proofs": lean_code
}

print("Writing PACKAGE.json...")
with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


"""
Visualizations for the Markov-Tropical Bridge Theorem.
Generates publication-quality figures showing key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def triangle_cycle_mean(W, i, j, k):
    return (W[i,j] + W[j,k] + W[k,i]) / 3.0

def triangle_cyc(W):
    n = W.shape[0]
    m = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                m = min(m, triangle_cycle_mean(W, i, j, k))
    return m


def plot_mixing_vs_barrier():
    """Plot the mixing bound α(m) vs tropical energy barrier."""
    n = 4
    eps = 0.2
    P = eps / (n-1) * np.ones((n, n))
    np.fill_diagonal(P, 1 - eps)
    
    W = -np.log(P)
    tcyc = triangle_cyc(W)
    
    ms = list(range(1, 101))
    alphas = []
    barriers = []
    
    for m in ms:
        Pm = np.linalg.matrix_power(P, m)
        alpha = Pm.max()
        alphas.append(alpha)
        barriers.append(-np.log(alpha) / m)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.plot(ms, alphas, 'b-', linewidth=2, label=r'$\alpha(m) = \max_{i,j} P^m(i,j)$')
    ax1.axhline(y=1/n, color='r', linestyle='--', alpha=0.7, label=f'1/n = {1/n:.3f}')
    ax1.set_xlabel('Step count m', fontsize=12)
    ax1.set_ylabel(r'Mixing bound $\alpha(m)$', fontsize=12)
    ax1.set_title('Mixing Decay', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    ax2.plot(ms, barriers, 'g-', linewidth=2, label=r'$-\log(\alpha)/m$ (barrier)')
    ax2.axhline(y=tcyc, color='r', linestyle='--', alpha=0.7, 
                label=f'triangleCyc = {tcyc:.4f}')
    ax2.fill_between(ms, barriers, [tcyc]*len(ms), alpha=0.15, color='green',
                     label='Gap (theorem guarantees ≥ 0)')
    ax2.set_xlabel('Step count m', fontsize=12)
    ax2.set_ylabel('Energy barrier', fontsize=12)
    ax2.set_title('Tropical Energy Barrier vs Cycle Mean', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle(f'Markov–Tropical Bridge (n={n}, ε={eps})', fontsize=16, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_state_space_comparison():
    """Compare tropical barriers across different state space sizes."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))
    
    for idx, n in enumerate([2, 3, 4, 5, 8]):
        eps = 0.3
        P = eps / (n-1) * np.ones((n, n))
        np.fill_diagonal(P, 1 - eps)
        
        W = -np.log(P)
        tcyc = triangle_cyc(W)
        
        ms = list(range(1, 51))
        barriers = []
        for m in ms:
            Pm = np.linalg.matrix_power(P, m)
            alpha = Pm.max()
            barriers.append(-np.log(alpha) / m)
        
        ax.plot(ms, barriers, '-', color=colors[idx], linewidth=2,
                label=f'n={n} (TCM={tcyc:.3f})')
        ax.axhline(y=tcyc, color=colors[idx], linestyle=':', alpha=0.4)
    
    ax.set_xlabel('Step count m', fontsize=12)
    ax.set_ylabel(r'Energy barrier $-\log(\alpha)/m$', fontsize=12)
    ax.set_title('Tropical Barriers Across State Space Sizes', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_phase_diagram():
    """Phase diagram: relationship between mixing rate and tropical geometry."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    eps_values = np.linspace(0.05, 0.45, 30)
    n = 3
    
    tcycs = []
    spectral_gaps = []
    
    for eps in eps_values:
        P = eps / (n-1) * np.ones((n, n))
        np.fill_diagonal(P, 1 - eps)
        
        W = -np.log(P)
        tcycs.append(triangle_cyc(W))
        
        eigs = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
        spectral_gaps.append(1 - eigs[1])
    
    scatter = ax.scatter(spectral_gaps, tcycs, c=eps_values, cmap='plasma',
                        s=80, edgecolors='black', linewidth=0.5)
    
    ax.set_xlabel('Spectral Gap', fontsize=12)
    ax.set_ylabel('Triangle Cycle Mean', fontsize=12)
    ax.set_title('Phase Diagram: Spectral Gap vs Tropical Cycle Mean\n(3-state chain)',
                fontsize=13)
    
    cbar = plt.colorbar(scatter, ax=ax)
    cbar.set_label('Mixing parameter ε', fontsize=11)
    
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig_to_base64(fig)


def plot_tropical_cost_heatmap():
    """Heatmap of the tropical cost matrix."""
    n = 4
    eps = 0.15
    P = np.zeros((n, n))
    for i in range(n):
        P[i, i] = 1 - 3*eps
        for d in [-1, 0, 1]:
            j = (i + d) % n
            if i != j:
                P[i, j] = eps
    # Ensure row-stochastic
    P = P / P.sum(axis=1, keepdims=True)
    
    W = -np.log(P)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    im1 = ax1.imshow(P, cmap='Blues', vmin=0)
    ax1.set_title('Transition Matrix P', fontsize=13)
    ax1.set_xlabel('Target state')
    ax1.set_ylabel('Source state')
    for i in range(n):
        for j in range(n):
            ax1.text(j, i, f'{P[i,j]:.2f}', ha='center', va='center', fontsize=10)
    plt.colorbar(im1, ax=ax1)
    
    im2 = ax2.imshow(W, cmap='YlOrRd')
    ax2.set_title('Tropical Cost W = -log(P)', fontsize=13)
    ax2.set_xlabel('Target state')
    ax2.set_ylabel('Source state')
    for i in range(n):
        for j in range(n):
            ax2.text(j, i, f'{W[i,j]:.2f}', ha='center', va='center', fontsize=9)
    plt.colorbar(im2, ax=ax2)
    
    fig.suptitle('Tropicalization: Probabilities → Costs', fontsize=15, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    img1 = plot_mixing_vs_barrier()
    print(f"  Mixing vs barrier: {len(img1)} chars")
    
    img2 = plot_state_space_comparison()
    print(f"  State space comparison: {len(img2)} chars")
    
    img3 = plot_phase_diagram()
    print(f"  Phase diagram: {len(img3)} chars")
    
    img4 = plot_tropical_cost_heatmap()
    print(f"  Tropical cost heatmap: {len(img4)} chars")
    
    print("All visualizations generated successfully.")
