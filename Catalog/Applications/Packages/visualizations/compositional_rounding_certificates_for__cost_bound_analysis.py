"""
Visualization: Compositional Rounding Cost Bounds
===================================================

Shows how the compositional cost ratio varies with boundary size
and edge size, demonstrating the d-approximation guarantee.
Uses matplotlib to produce curves and a heatmap.
"""

import numpy as np
import matplotlib.pyplot as plt
import random

# ---- Inline all needed functions ----

def solve_simple_fractional(vertices, edges):
    """Simple greedy fractional transversal."""
    values = {v: 0.0 for v in vertices}
    for e in edges:
        s = sum(values[v] for v in e)
        if s < 1.0:
            deficit = 1.0 - s
            per_vertex = deficit / len(e)
            for v in e:
                values[v] += per_vertex
    return values

def threshold_round(values, vertices, d):
    if d <= 0:
        return set()
    return {v for v in vertices if values.get(v, 0) >= 1.0 / d - 1e-9}

def random_hypergraph_edges(vertices, num_edges, min_sz, max_sz, rng):
    vlist = sorted(vertices)
    edges = []
    for _ in range(num_edges):
        sz = rng.randint(min_sz, min(max_sz, len(vlist)))
        edges.append(frozenset(rng.sample(vlist, sz)))
    return list(set(edges))

def run_experiment(n, bsize, max_edge_size, num_trials=50):
    """Run compositional rounding experiments and return statistics."""
    ratios = []
    rng = random.Random(42 + n * 100 + bsize * 10 + max_edge_size)

    for trial in range(num_trials):
        all_verts = set(range(n))
        boundary = set(range(bsize))
        remaining = sorted(all_verts - boundary)
        rng.shuffle(remaining)
        split = len(remaining) // 2
        V1 = boundary | set(remaining[:split])
        V2 = boundary | set(remaining[split:])

        edges1 = random_hypergraph_edges(V1, 8, 2, max_edge_size, rng)
        edges2 = random_hypergraph_edges(V2, 8, 2, max_edge_size, rng)

        if not edges1 or not edges2:
            continue

        x1 = solve_simple_fractional(V1, edges1)
        x2 = solve_simple_fractional(V2, edges2)

        for v in boundary:
            val = max(x1.get(v, 0), x2.get(v, 0))
            x1[v] = val
            x2[v] = val

        # Glue
        x_glued = {}
        for v in V1 | V2:
            x_glued[v] = x1[v] if v in V1 else x2[v]

        d = max_edge_size
        S = threshold_round(x_glued, V1 | V2, d)

        # Check all edges covered
        all_edges = list(set(edges1 + edges2))
        all_covered = all(len(e & S) > 0 for e in all_edges)
        if not all_covered:
            continue

        frac_cost = sum(x1[v] for v in V1) + sum(x2[v] for v in V2)
        if frac_cost > 0:
            ratio = len(S) / frac_cost
            ratios.append(ratio)

    return ratios

# ---- Generate data ----

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Cost ratio vs boundary size (fixed edge size)
boundary_sizes = [2, 3, 4, 5, 6, 7]
for d in [2, 3, 4]:
    means = []
    maxes = []
    for bsize in boundary_sizes:
        ratios = run_experiment(20, bsize, d, num_trials=80)
        if ratios:
            means.append(np.mean(ratios))
            maxes.append(np.max(ratios))
        else:
            means.append(0)
            maxes.append(0)
    axes[0].plot(boundary_sizes, means, 'o-', label=f'd={d} (avg)', linewidth=2)
    axes[0].plot(boundary_sizes, maxes, 's--', alpha=0.5, label=f'd={d} (max)')
    axes[0].axhline(y=d, color='gray', linestyle=':', alpha=0.3)

axes[0].set_xlabel('Boundary Size |V₀|', fontsize=12)
axes[0].set_ylabel('Cost Ratio |S| / Σx', fontsize=12)
axes[0].set_title('Cost Ratio vs Boundary Size', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)

# Panel 2: Cost ratio vs edge size (fixed boundary)
edge_sizes = [2, 3, 4, 5]
for bsize in [2, 4, 6]:
    means = []
    for d in edge_sizes:
        ratios = run_experiment(20, bsize, d, num_trials=80)
        if ratios:
            means.append(np.mean(ratios))
        else:
            means.append(0)
    axes[1].plot(edge_sizes, means, 'o-', label=f'|V₀|={bsize}', linewidth=2)

# Theoretical bound line
axes[1].plot(edge_sizes, edge_sizes, 'k--', label='Bound (d)', linewidth=1.5, alpha=0.5)

axes[1].set_xlabel('Max Edge Size d', fontsize=12)
axes[1].set_ylabel('Avg Cost Ratio', fontsize=12)
axes[1].set_title('Cost Ratio vs Edge Size', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

# Panel 3: Heatmap of average cost ratio
bsizes = [2, 3, 4, 5, 6]
dsizes = [2, 3, 4, 5]
heatmap_data = np.zeros((len(dsizes), len(bsizes)))

for i, d in enumerate(dsizes):
    for j, b in enumerate(bsizes):
        ratios = run_experiment(20, b, d, num_trials=60)
        if ratios:
            heatmap_data[i, j] = np.mean(ratios)

im = axes[2].imshow(heatmap_data, cmap='YlOrRd', aspect='auto', origin='lower')
axes[2].set_xticks(range(len(bsizes)))
axes[2].set_xticklabels(bsizes)
axes[2].set_yticks(range(len(dsizes)))
axes[2].set_yticklabels(dsizes)
axes[2].set_xlabel('Boundary Size |V₀|', fontsize=12)
axes[2].set_ylabel('Max Edge Size d', fontsize=12)
axes[2].set_title('Avg Cost Ratio Heatmap', fontsize=13, fontweight='bold')

# Add text annotations
for i in range(len(dsizes)):
    for j in range(len(bsizes)):
        axes[2].text(j, i, f'{heatmap_data[i,j]:.2f}',
                    ha='center', va='center', fontsize=10, fontweight='bold')

fig.colorbar(im, ax=axes[2], shrink=0.8, label='Cost Ratio')

plt.suptitle('Compositional Rounding: Cost Bound Analysis',
            fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_cost_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_cost_bound.png")
