"""
applications.py — Tropical Information Theory: Real-World Applications

Demonstrates practical applications of tropical channel capacity
to topological data analysis, network analysis, and data compression.

Author: Harmonic Research
"""

import numpy as np
from typing import List, Tuple


def tropical_channel_capacity(degree: int) -> float:
    """Tropical channel capacity: log(d+1)."""
    return np.log(degree + 1)


def graph_from_adj(adj: np.ndarray) -> dict:
    """Extract graph properties from adjacency matrix."""
    n = adj.shape[0]
    degrees = adj.sum(axis=1).astype(int)
    return {
        'n': n,
        'degrees': degrees,
        'max_degree': int(degrees.max()),
        'min_degree': int(degrees.min()),
        'num_edges': int(adj.sum()) // 2,
        'total_capacity': sum(np.log(d + 1) for d in degrees),
    }


# ============================================================
# Application 1: Optimal Filtration Ordering
# ============================================================

def optimal_filtration_order(adj: np.ndarray) -> np.ndarray:
    """
    Compute the optimal vertex ordering for maximum information
    transmission through the tropical barcode channel.

    The greedy strategy orders vertices by decreasing degree,
    maximizing the cumulative capacity at each step.

    Parameters
    ----------
    adj : np.ndarray
        Adjacency matrix.

    Returns
    -------
    np.ndarray
        Optimal vertex ordering (array of vertex indices).

    Example
    -------
    >>> adj = np.array([[0,1,1,0],[1,0,1,1],[1,1,0,0],[0,1,0,0]])
    >>> optimal_filtration_order(adj)
    array([1, 0, 2, 3])
    """
    degrees = adj.sum(axis=1).astype(int)
    return np.argsort(-degrees)


def capacity_curve(adj: np.ndarray, order: np.ndarray) -> np.ndarray:
    """
    Compute the cumulative capacity curve for a given vertex ordering.

    Returns array where entry k = sum of log(deg(v_i)+1) for i=0..k.
    """
    degrees = adj.sum(axis=1).astype(int)
    cumul = np.zeros(len(order) + 1)
    for k, v in enumerate(order):
        cumul[k + 1] = cumul[k] + np.log(degrees[v] + 1)
    return cumul


# ============================================================
# Application 2: Network Stability Assessment
# ============================================================

def stability_assessment(adj: np.ndarray) -> dict:
    """
    Assess the stability properties of a network using tropical
    channel capacity theory.

    Returns a dictionary with:
    - stability_constant: the (D+1) bound
    - capacity_constant: exp(C_max) = D+1 (the information-theoretic form)
    - capacity_gap: log((D+1)/(δ+1)), measuring heterogeneity
    - is_regular: whether all vertices have the same degree

    Example
    -------
    >>> adj = np.ones((5,5)) - np.eye(5)  # K_5
    >>> stability_assessment(adj)
    {'stability_constant': 5, 'capacity_constant': 5, ...}
    """
    props = graph_from_adj(adj)
    D = props['max_degree']
    delta = props['min_degree']

    return {
        'n': props['n'],
        'num_edges': props['num_edges'],
        'max_degree': D,
        'min_degree': delta,
        'stability_constant': D + 1,
        'capacity_constant': D + 1,  # exp(log(D+1)) = D+1
        'max_capacity': np.log(D + 1),
        'min_capacity': np.log(delta + 1),
        'capacity_gap': np.log((D + 1) / (delta + 1)),
        'total_capacity': props['total_capacity'],
        'is_regular': D == delta,
        'capacity_per_vertex': props['total_capacity'] / props['n'],
    }


# ============================================================
# Application 3: Barcode Compression Rate
# ============================================================

def barcode_compression_rate(adj: np.ndarray) -> dict:
    """
    Compute the theoretical compression rate for tropical barcodes.

    The compression rate is determined by the ratio of
    degree entropy to total capacity.

    Returns
    -------
    dict
        compression_rate: bits per vertex for barcode storage
        redundancy: fraction of capacity unused
    """
    degrees = adj.sum(axis=1).astype(int)
    n = adj.shape[0]
    total_cap = sum(np.log(d + 1) for d in degrees)

    # Degree entropy
    total_deg = degrees.sum()
    if total_deg == 0:
        return {'compression_rate': 0, 'redundancy': 0}
    p = degrees / total_deg
    entropy = -np.sum(p[p > 0] * np.log(p[p > 0]))

    return {
        'compression_rate': entropy / np.log(2),  # in bits
        'total_capacity_bits': total_cap / np.log(2),
        'entropy_bits': entropy / np.log(2),
        'redundancy': 1 - entropy / total_cap if total_cap > 0 else 0,
        'capacity_per_vertex_bits': total_cap / (n * np.log(2)),
    }


# ============================================================
# Application 4: Comparing Graph Families
# ============================================================

def compare_graph_families():
    """
    Compare the tropical capacity properties of different graph families.
    """
    results = {}

    # Complete graphs K_n
    for n in [5, 10, 20, 50]:
        adj = np.ones((n, n)) - np.eye(n)
        props = stability_assessment(adj)
        results[f'K_{n}'] = props

    # Cycle graphs C_n
    for n in [5, 10, 20, 50]:
        adj = np.zeros((n, n))
        for i in range(n):
            adj[i, (i + 1) % n] = 1
            adj[(i + 1) % n, i] = 1
        props = stability_assessment(adj)
        results[f'C_{n}'] = props

    # Path graphs P_n
    for n in [5, 10, 20, 50]:
        adj = np.zeros((n, n))
        for i in range(n - 1):
            adj[i, i + 1] = 1
            adj[i + 1, i] = 1
        props = stability_assessment(adj)
        results[f'P_{n}'] = props

    # Star graphs S_n
    for n in [5, 10, 20, 50]:
        adj = np.zeros((n, n))
        for i in range(1, n):
            adj[0, i] = 1
            adj[i, 0] = 1
        props = stability_assessment(adj)
        results[f'S_{n}'] = props

    return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=== Tropical Information Theory: Applications ===\n")

    # Application 1: Optimal filtration
    print("--- Application 1: Optimal Filtration Ordering ---")
    adj = np.array([
        [0, 1, 1, 0, 0],
        [1, 0, 1, 1, 0],
        [1, 1, 0, 1, 1],
        [0, 1, 1, 0, 1],
        [0, 0, 1, 1, 0],
    ], dtype=float)
    order = optimal_filtration_order(adj)
    curve = capacity_curve(adj, order)
    print(f"Vertex degrees: {adj.sum(axis=1).astype(int)}")
    print(f"Optimal order: {order}")
    print(f"Cumulative capacity: {curve}")
    print()

    # Application 2: Stability assessment
    print("--- Application 2: Network Stability Assessment ---")
    K10 = np.ones((10, 10)) - np.eye(10)
    assessment = stability_assessment(K10)
    for key, val in assessment.items():
        print(f"  {key}: {val}")
    print()

    # Application 3: Compression rate
    print("--- Application 3: Barcode Compression ---")
    compression = barcode_compression_rate(adj)
    for key, val in compression.items():
        print(f"  {key}: {val:.4f}")
    print()

    # Application 4: Graph family comparison
    print("--- Application 4: Graph Family Comparison ---")
    results = compare_graph_families()
    print(f"{'Graph':<10} {'Stability':<12} {'Cap/vertex':<12} {'Gap':<10} {'Regular':<8}")
    print("-" * 52)
    for name, props in results.items():
        print(f"{name:<10} {props['stability_constant']:<12} "
              f"{props['capacity_per_vertex']:<12.4f} "
              f"{props['capacity_gap']:<10.4f} "
              f"{'Yes' if props['is_regular'] else 'No':<8}")


"""Build PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

base = '/workspace/request-project'

package = {
    "title": "Tropical Channel Capacity and Barcode Stability: An Information-Theoretic Foundation",
    "domain": "Tropical Information Theory / Topological Data Analysis",
    "article": read_file(os.path.join(base, 'ARTICLE.md')),
    "research_paper": read_file(os.path.join(base, 'RESEARCH_PAPER.md')),
    "future_directions": read_file(os.path.join(base, 'FUTURE_DIRECTIONS.md')),
    "demos": [
        {
            "name": "Erdős-Rényi Capacity Conjecture",
            "code": read_file(os.path.join(base, 'demo.py'))
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Information Theory Algorithms",
            "pseudocode": """Algorithm: Total Tropical Capacity
Input: Adjacency matrix A ∈ {0,1}^{n×n}
Output: Cap(G) = Σ_v log(deg(v) + 1)
1. degrees ← row sums of A
2. Cap ← Σ_v log(degrees[v] + 1)
3. return Cap

Algorithm: Graph Degree Entropy
Input: Adjacency matrix A
Output: H(G) = -Σ_v p_v log(p_v)
1. degrees ← row sums of A
2. total ← Σ degrees
3. if total = 0: return 0
4. p ← degrees / total
5. return -Σ_{v: p_v > 0} p_v log(p_v)""",
            "code": read_file(os.path.join(base, 'algorithms.py'))
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Capacity Landscape",
            "code": read_file(os.path.join(base, 'viz_capacity_landscape.py')),
            "description": "Three-panel visualization showing (1) channel capacity C(d) = log(d+1) as a function of degree, (2) the exponential map from capacity to stability constant, and (3) capacity profiles across different graph families."
        },
        {
            "name": "Stability Bound Tightness",
            "code": read_file(os.path.join(base, 'viz_stability_comparison.py')),
            "description": "Scatter plots comparing actual tropical barcode distance against the stability bound (Δ+1)·ε for complete, cycle, and star graphs, demonstrating that the bound is tighter for regular graphs."
        },
        {
            "name": "Entropy-Capacity Landscape",
            "code": read_file(os.path.join(base, 'viz_entropy_capacity.py')),
            "description": "Three-panel visualization showing (1) entropy vs capacity for random graphs, (2) the Erdős-Rényi capacity ratio converging to 1, and (3) a heatmap of the capacity gap log((Δ+1)/(δ+1))."
        }
    ],
    "interactive_demos": [
        {
            "name": "Tropical Channel Capacity Explorer",
            "html": read_file(os.path.join(base, 'interactive_capacity.html')),
            "description": "Interactive slider to explore how channel capacity, stability constant, and alphabet size change with vertex degree."
        },
        {
            "name": "Tropical Barcode Stability Demo",
            "html": read_file(os.path.join(base, 'interactive_stability.html')),
            "description": "Interactive demo showing how filtration perturbations affect barcode distance, with the stability bound visualized in real-time."
        }
    ],
    "lean_proofs": read_file(os.path.join(base, 'Catalog/Pythagorean/TropicalBridge/TropicalInformationTheory.lean'))
}

with open(os.path.join(base, 'PACKAGE.json'), 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json created successfully")
print(f"Size: {os.path.getsize(os.path.join(base, 'PACKAGE.json'))} bytes")


"""
demo.py — Tropical Information Theory: Erdős-Rényi Capacity Conjecture Demo

Generates random graphs G(n, c/n), computes filtrations, estimates
mutual information I(f; TPB(G,f)), computes degree entropy H(G),
and plots the capacity ratio against the theoretical prediction.

Author: Harmonic Research
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def erdos_renyi_graph(n, p, rng):
    """Generate G(n,p) adjacency matrix."""
    upper = rng.random((n, n)) < p
    adj = np.triu(upper, k=1)
    return (adj + adj.T).astype(float)


def tropical_channel_capacity(degree):
    """log(d+1) capacity of a degree-d vertex."""
    return np.log(degree + 1)


def total_tropical_capacity(adj):
    """Sum of log(deg(v)+1) over all vertices."""
    degrees = adj.sum(axis=1).astype(int)
    return sum(np.log(d + 1) for d in degrees)


def graph_degree_entropy(adj):
    """Shannon entropy of normalized degree sequence."""
    degrees = adj.sum(axis=1)
    total = degrees.sum()
    if total == 0:
        return 0.0
    p = degrees / total
    return -np.sum(p[p > 0] * np.log(p[p > 0]))


def tropical_event_profile(adj, filtration, t):
    """Tropical event profile at time t."""
    degrees = adj.sum(axis=1).astype(int)
    active = filtration <= t
    return sum(degrees[i] + 1 for i in range(len(filtration)) if active[i])


def estimate_mutual_info(adj, n_samples=200, rng=None):
    """Estimate I(f; TPB(G,f)) via correlation proxy."""
    if rng is None:
        rng = np.random.RandomState(42)
    n = adj.shape[0]
    degrees = adj.sum(axis=1).astype(int)

    filtrations = rng.random((n_samples, n))
    times = np.linspace(0, 1, 15)
    barcode_feats = np.zeros((n_samples, len(times)))

    for i, f in enumerate(filtrations):
        for j, t in enumerate(times):
            active = f <= t
            barcode_feats[i, j] = sum(degrees[k] + 1 for k in range(n) if active[k])

    rho_sq_list = []
    for j in range(min(n, len(times))):
        c = np.corrcoef(filtrations[:, min(j, n-1)], barcode_feats[:, j])[0, 1]
        if not np.isnan(c):
            rho_sq_list.append(c**2)

    if not rho_sq_list:
        return 0.0
    avg_rho_sq = np.mean(rho_sq_list)
    return -0.5 * np.log(max(1 - avg_rho_sq, 1e-10))


def main():
    rng = np.random.RandomState(2025)
    n = 100
    c_values = [3, 5, 10]
    n_trials = 200  # per c value

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Erdős-Rényi Capacity Conjecture: Capacity Ratio vs Theory',
                 fontsize=14, fontweight='bold')

    for idx, c in enumerate(c_values):
        p = c / n
        capacity_ratios = []
        mi_ratios = []

        for trial in range(n_trials):
            G = erdos_renyi_graph(n, p, rng)
            cap = total_tropical_capacity(G)
            H = graph_degree_entropy(G)

            # Capacity ratio: cap / (n * log(c))
            ratio = cap / (n * np.log(c)) if np.log(c) > 0 else 0
            capacity_ratios.append(ratio)

            # MI / H ratio
            if H > 0:
                mi = estimate_mutual_info(G, n_samples=100, rng=rng)
                mi_ratios.append(mi / H)

        ax = axes[idx]

        # Histogram of capacity ratios
        ax.hist(capacity_ratios, bins=30, alpha=0.7, color='steelblue',
                edgecolor='white', density=True, label='Capacity ratio')
        ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2,
                   label=f'Predicted = 1.0')
        mean_ratio = np.mean(capacity_ratios)
        ax.axvline(x=mean_ratio, color='green', linestyle='-', linewidth=2,
                   label=f'Mean = {mean_ratio:.3f}')

        ax.set_xlabel('Capacity Ratio', fontsize=12)
        ax.set_ylabel('Density', fontsize=12)
        ax.set_title(f'c = {c} (p = {c}/{n})', fontsize=13)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('erdos_renyi_capacity_conjecture.png', dpi=150, bbox_inches='tight')
    print("Saved: erdos_renyi_capacity_conjecture.png")

    # Print summary statistics
    print("\n=== Erdős-Rényi Capacity Conjecture Results ===\n")
    for c in c_values:
        p = c / n
        ratios = []
        for _ in range(n_trials):
            G = erdos_renyi_graph(n, p, rng)
            cap = total_tropical_capacity(G)
            ratio = cap / (n * np.log(c))
            ratios.append(ratio)
        print(f"c = {c}: mean ratio = {np.mean(ratios):.4f}, "
              f"std = {np.std(ratios):.4f}, "
              f"predicted = 1.0, "
              f"1-e^(-c) = {1 - np.exp(-c):.4f}")


if __name__ == "__main__":
    main()


"""
Visualization: Tropical Channel Capacity Landscape

Visualizes how the tropical channel capacity C(d) = log(d+1) varies with
vertex degree, and shows the capacity gap between different graph families.
This illustrates the key insight that the stability constant (D+1) is the
exponential of the channel capacity.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Capacity function C(d) = log(d+1)
degrees = np.arange(0, 21)
capacities = np.log(degrees + 1)

ax = axes[0]
ax.bar(degrees, capacities, color='steelblue', alpha=0.8, edgecolor='white')
ax.plot(degrees, capacities, 'ro-', markersize=4, linewidth=1.5)
ax.set_xlabel('Vertex Degree d', fontsize=12)
ax.set_ylabel('Channel Capacity C(d) = log(d+1)', fontsize=12)
ax.set_title('Tropical Channel Capacity', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)
ax.annotate('Isolated\nvertex\nC=0', xy=(0, 0), xytext=(2, 0.5),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=9, color='red')

# Panel 2: Stability constant = exp(capacity)
stability = degrees + 1

ax = axes[1]
ax.plot(capacities, stability, 'go-', markersize=6, linewidth=2, label='exp(C(d)) = d+1')
ax.fill_between(capacities, stability, alpha=0.2, color='green')
ax.set_xlabel('Channel Capacity C(d)', fontsize=12)
ax.set_ylabel('Stability Constant Δ+1 = exp(C)', fontsize=12)
ax.set_title('Capacity → Stability', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: Capacity comparison across graph families
n = 20
families = {
    'Complete K₂₀': np.ones((n, n)) - np.eye(n),
    'Cycle C₂₀': np.zeros((n, n)),
    'Star S₂₀': np.zeros((n, n)),
    'Path P₂₀': np.zeros((n, n)),
}

# Build adjacency matrices
C = families['Cycle C₂₀']
for i in range(n):
    C[i, (i+1) % n] = 1
    C[(i+1) % n, i] = 1

S = families['Star S₂₀']
for i in range(1, n):
    S[0, i] = 1
    S[i, 0] = 1

P = families['Path P₂₀']
for i in range(n - 1):
    P[i, i+1] = 1
    P[i+1, i] = 1

ax = axes[2]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
for idx, (name, adj) in enumerate(families.items()):
    degs = adj.sum(axis=1).astype(int)
    caps = sorted([np.log(d + 1) for d in degs], reverse=True)
    ax.plot(range(n), caps, 'o-', color=colors[idx], label=name,
            markersize=4, linewidth=2)

ax.set_xlabel('Vertex rank', fontsize=12)
ax.set_ylabel('Per-vertex capacity', fontsize=12)
ax.set_title('Capacity Profiles by Graph Family', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_capacity_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_capacity_landscape.png")


"""
Visualization: Degree Entropy vs Total Capacity

Shows the relationship between graph degree entropy H(G) and total tropical
capacity Cap(G) across random graphs of varying density. Illustrates that
capacity dominates entropy (entropy ≤ capacity) and that the gap measures
the graph's information-theoretic redundancy.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def graph_degree_entropy(adj):
    """Compute H(G) = -sum p_v log p_v."""
    degrees = adj.sum(axis=1)
    total = degrees.sum()
    if total == 0:
        return 0.0
    p = degrees / total
    return -np.sum(p[p > 0] * np.log(p[p > 0]))


def total_tropical_capacity(adj):
    """Compute Cap(G) = sum log(deg(v)+1)."""
    degrees = adj.sum(axis=1).astype(int)
    return sum(np.log(d + 1) for d in degrees)


def erdos_renyi(n, p, rng):
    upper = rng.random((n, n)) < p
    adj = np.triu(upper, k=1)
    return (adj + adj.T).astype(float)


rng = np.random.RandomState(2025)
n = 50

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Entropy vs Capacity scatter
ax = axes[0]
probs = np.linspace(0.05, 0.95, 20)
for p in probs:
    entropies = []
    capacities = []
    for _ in range(30):
        G = erdos_renyi(n, p, rng)
        entropies.append(graph_degree_entropy(G))
        capacities.append(total_tropical_capacity(G))
    ax.scatter(capacities, entropies, alpha=0.3, s=10,
               color=plt.cm.viridis(p), label=f'p={p:.2f}' if p in [0.05, 0.5, 0.95] else '')

ax.plot([0, max(capacities)*1.1], [0, max(capacities)*1.1], 'r--',
        linewidth=2, label='H = Cap (equality)')
ax.set_xlabel('Total Capacity Cap(G)', fontsize=12)
ax.set_ylabel('Degree Entropy H(G)', fontsize=12)
ax.set_title('Entropy ≤ Capacity\n(colored by edge density p)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Capacity ratio for Erdos-Renyi
ax = axes[1]
c_values = np.linspace(1.5, 15, 30)
mean_ratios = []
std_ratios = []

for c in c_values:
    p_val = c / n
    ratios = []
    for _ in range(50):
        G = erdos_renyi(n, p_val, rng)
        cap = total_tropical_capacity(G)
        ratio = cap / (n * np.log(c)) if c > 1 else 0
        ratios.append(ratio)
    mean_ratios.append(np.mean(ratios))
    std_ratios.append(np.std(ratios))

ax.errorbar(c_values, mean_ratios, yerr=std_ratios, fmt='o-',
            color='steelblue', markersize=4, capsize=3)
ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Predicted = 1')
ax.set_xlabel('Average degree c', fontsize=12)
ax.set_ylabel('Cap(G) / (n·log(c))', fontsize=12)
ax.set_title('Erdős-Rényi Capacity Conjecture\nG(50, c/50)', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.8, 1.3)

# Panel 3: Capacity gap heatmap
ax = axes[2]
D_vals = np.arange(1, 21)
delta_vals = np.arange(0, 20)
gap_matrix = np.zeros((20, 20))

for i, D in enumerate(D_vals):
    for j, delta in enumerate(delta_vals):
        if delta <= D:
            gap_matrix[j, i] = np.log((D + 1) / (delta + 1))
        else:
            gap_matrix[j, i] = np.nan

im = ax.imshow(gap_matrix, aspect='auto', origin='lower',
               cmap='YlOrRd', interpolation='nearest')
ax.set_xlabel('Max degree Δ', fontsize=12)
ax.set_ylabel('Min degree δ', fontsize=12)
ax.set_title('Capacity Gap\nlog((Δ+1)/(δ+1))', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label='Gap (nats)')

plt.tight_layout()
plt.savefig('entropy_capacity_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: entropy_capacity_landscape.png")


"""
Visualization: Stability Bound Tightness

Compares the actual tropical barcode distance against the information-theoretic
stability bound exp(C(Δ)) · ε for random perturbations on different graph families.
Demonstrates that the capacity bound is tight for regular graphs and loose for
irregular graphs (measured by the capacity gap).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tropical_barcode_dist(adj, f, g):
    """Compute tropical barcode distance."""
    degrees = adj.sum(axis=1).astype(int)
    return max(abs(f[i] - g[i]) * (degrees[i] + 1) for i in range(len(f)))


def stability_bound(adj, f, g):
    """Compute (D+1)*epsilon stability bound."""
    D = int(adj.sum(axis=1).max())
    eps = np.max(np.abs(f - g))
    return (D + 1) * eps


def make_cycle(n):
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i, (i+1) % n] = 1
        adj[(i+1) % n, i] = 1
    return adj


def make_star(n):
    adj = np.zeros((n, n))
    for i in range(1, n):
        adj[0, i] = 1
        adj[i, 0] = 1
    return adj


def make_complete(n):
    return np.ones((n, n)) - np.eye(n)


rng = np.random.RandomState(42)
n = 15
n_trials = 300

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Stability Bound Tightness: Barcode Distance vs Capacity Bound',
             fontsize=14, fontweight='bold')

graphs = [
    ('Complete K₁₅ (regular)', make_complete(n)),
    ('Cycle C₁₅ (regular)', make_cycle(n)),
    ('Star S₁₅ (irregular)', make_star(n)),
]

for idx, (name, adj) in enumerate(graphs):
    D = int(adj.sum(axis=1).max())
    distances = []
    bounds = []
    epsilons = []

    for _ in range(n_trials):
        f = rng.random(n)
        eps = rng.uniform(0.01, 0.3)
        perturbation = rng.uniform(-eps, eps, n)
        g = f + perturbation

        dist = tropical_barcode_dist(adj, f, g)
        bound = stability_bound(adj, f, g)
        distances.append(dist)
        bounds.append(bound)
        epsilons.append(np.max(np.abs(f - g)))

    ax = axes[idx]
    ax.scatter(bounds, distances, alpha=0.4, s=15, color='steelblue')
    max_val = max(max(bounds), max(distances))
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='d_T = bound (tight)')
    ax.set_xlabel('Stability bound (Δ+1)·ε', fontsize=12)
    ax.set_ylabel('Actual barcode distance', fontsize=12)
    ax.set_title(f'{name}\nΔ={D}, gap={np.log((D+1)/2):.2f}', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Compute tightness ratio
    ratios = [d / b for d, b in zip(distances, bounds) if b > 0]
    ax.text(0.05, 0.95, f'Mean ratio: {np.mean(ratios):.3f}',
            transform=ax.transAxes, fontsize=10,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('stability_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: stability_comparison.png")
