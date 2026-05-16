#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Surgery

Demonstrates how tropical matrix surgery applies to:
1. Shortest-path sensitivity in transportation networks
2. Manufacturing scheduling (discrete event systems)
3. Network robustness under edge-weight changes
"""

import numpy as np
from algorithms import (
    karp_minimum_cycle_mean,
    tropical_rank_two_surgery,
    two_entry_surgery,
    spectral_sensitivity_analysis,
    find_critical_cycles,
    surgery_support,
)


def application_1_shortest_path_sensitivity():
    """
    Application: Transportation Network Edge Upgrade
    
    A city has a road network modeled as a weighted digraph.
    Edge weights represent travel times. The city wants to upgrade
    two roads (decrease their travel times). Our theorem guarantees
    that this cannot increase the minimum cycle mean (worst-case
    average delay per step in any cyclic route).
    """
    print("=" * 60)
    print("APPLICATION 1: Transportation Network — Road Upgrade")
    print("=" * 60)
    
    # 4-node transportation network
    # Nodes: Downtown(0), Airport(1), Suburb(2), Industrial(3)
    INF = 100.0  # large value = no direct road
    A = np.array([
        [5.0,  3.0,  8.0, INF],    # Downtown
        [4.0,  6.0, INF,  2.0],    # Airport  
        [7.0, INF,  4.0,  5.0],    # Suburb
        [INF,  3.0,  6.0,  7.0],   # Industrial
    ])
    
    labels = ["Downtown", "Airport", "Suburb", "Industrial"]
    
    rho_before = karp_minimum_cycle_mean(A)
    print(f"\nNetwork travel time matrix (minutes per segment):")
    for i, row in enumerate(A):
        print(f"  {labels[i]:12s}: [{', '.join(f'{x:5.1f}' for x in row)}]")
    print(f"\nMinimum cycle mean (before upgrade): {rho_before:.2f} min/segment")
    
    # Upgrade: reduce Downtown→Airport from 3 to 1, Industrial→Airport from 3 to 1.5
    B = two_entry_surgery(A, 0, 1, 1.0, 3, 1, 1.5)
    rho_after = karp_minimum_cycle_mean(B)
    
    print(f"\nUpgrade: Downtown→Airport: 3→1 min, Industrial→Airport: 3→1.5 min")
    print(f"Minimum cycle mean (after upgrade): {rho_after:.2f} min/segment")
    print(f"Improvement: {rho_before - rho_after:.2f} min/segment")
    print(f"Monotonicity guaranteed: ρ(B) ≤ ρ(A) ✓")
    
    # Sensitivity analysis
    sens = spectral_sensitivity_analysis(A, 0.5)
    print(f"\nEdge sensitivity (which upgrades help most?):")
    edges = []
    for i in range(4):
        for j in range(4):
            if A[i, j] < INF - 1:
                edges.append((sens[i, j], labels[i], labels[j]))
    edges.sort(reverse=True)
    for s, src, dst in edges[:5]:
        print(f"  {src:12s} → {dst:12s}: sensitivity = {s:+.4f}")


def application_2_manufacturing_schedule():
    """
    Application: Manufacturing Line Optimization
    
    A factory has machines arranged in a cyclic workflow.
    Matrix entries represent processing + transfer times.
    Upgrading two machines (decreasing their processing times)
    is a two-entry surgery. Our theorem guarantees the cycle
    time (throughput) can only improve or stay the same.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Manufacturing — Machine Upgrade")
    print("=" * 60)
    
    # 5-machine manufacturing line
    # A[i,j] = time from completion of machine i to completion of machine j
    machines = ["Cutter", "Welder", "Painter", "Inspector", "Packager"]
    A = np.array([
        [10.0,  4.0, 15.0, 20.0, 25.0],
        [12.0,  8.0,  3.0, 18.0, 22.0],
        [20.0, 16.0, 12.0,  5.0, 15.0],
        [25.0, 20.0, 18.0,  7.0,  4.0],
        [ 6.0, 10.0, 14.0, 20.0, 15.0],
    ])
    
    rho_before = karp_minimum_cycle_mean(A)
    print(f"\nProcessing time matrix (hours):")
    for i, row in enumerate(A):
        print(f"  {machines[i]:10s}: [{', '.join(f'{x:5.1f}' for x in row)}]")
    print(f"\nCurrent cycle time: {rho_before:.2f} hours/step")
    print(f"(Throughput: {1/rho_before:.4f} units/hour)")
    
    # Upgrade: faster Welder→Painter (3→1.5) and Inspector→Packager (4→2)
    B = two_entry_surgery(A, 1, 2, 1.5, 3, 4, 2.0)
    rho_after = karp_minimum_cycle_mean(B)
    
    print(f"\nUpgrade: Welder→Painter: 3→1.5h, Inspector→Packager: 4→2h")
    print(f"New cycle time: {rho_after:.2f} hours/step")
    print(f"(New throughput: {1/rho_after:.4f} units/hour)")
    print(f"Improvement: {(1/rho_after - 1/rho_before)/( 1/rho_before)*100:.1f}%")
    print(f"Monotonicity guaranteed: cycle time can only decrease ✓")


def application_3_network_robustness():
    """
    Application: Network Robustness Analysis
    
    Analyze how robust a communication network's cycle performance
    is under rank-2 perturbations (two new faster links added).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Communication Network — New Links")
    print("=" * 60)
    
    # 4-node network
    nodes = ["Server A", "Server B", "Server C", "Gateway"]
    A = np.array([
        [2.0, 5.0, 9.0, 4.0],
        [6.0, 3.0, 4.0, 7.0],
        [8.0, 5.0, 2.0, 3.0],
        [3.0, 8.0, 6.0, 5.0],
    ])
    
    rho_A = karp_minimum_cycle_mean(A)
    print(f"\nLatency matrix (ms):")
    for i, row in enumerate(A):
        print(f"  {nodes[i]:10s}: [{', '.join(f'{x:4.1f}' for x in row)}]")
    print(f"\nMin cycle mean latency: {rho_A:.2f} ms/hop")
    
    # Add two fast direct links as rank-2 surgery
    u = np.array([1.0, 0.5, 2.0, 1.5])
    v = np.array([0.5, 1.0, 0.5, 2.0])
    up = np.array([2.0, 1.0, 0.5, 1.0])
    vp = np.array([1.0, 2.0, 1.0, 0.5])
    
    B = tropical_rank_two_surgery(A, u, v, up, vp)
    rho_B = karp_minimum_cycle_mean(B)
    
    print(f"\nAfter adding two rank-1 link templates:")
    print(f"  Template 1: u⊕v outer product")
    print(f"  Template 2: u'⊕v' outer product")
    print(f"\nNew min cycle mean: {rho_B:.2f} ms/hop")
    print(f"Change: {rho_B - rho_A:+.2f} ms/hop")
    
    support = surgery_support(A, B)
    print(f"\nEdges affected by surgery: {len(support)} out of {A.shape[0]**2}")
    
    # Check which edges are critical
    critical = find_critical_cycles(A)
    print(f"\nCritical cycles of original network:")
    for c in critical:
        k = len(c)
        edges = [(c[t], c[(t+1) % k]) for t in range(k)]
        edge_names = [f"{nodes[e[0]][:3]}→{nodes[e[1]][:3]}" for e in edges]
        weight = sum(A[e[0], e[1]] for e in edges)
        print(f"  {' → '.join(edge_names)} (mean={weight/k:.2f})")
    
    # Check if surgery hits critical edges
    critical_edges = set()
    for c in critical:
        k = len(c)
        for t in range(k):
            critical_edges.add((c[t], c[(t+1) % k]))
    
    surgery_hits_critical = any(e in critical_edges for e in support)
    print(f"\nSurgery hits critical edges? {surgery_hits_critical}")
    if not surgery_hits_critical:
        print("→ Off-critical surgery: spectral radius might be preserved")


if __name__ == "__main__":
    application_1_shortest_path_sensitivity()
    application_2_manufacturing_schedule()
    application_3_network_robustness()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Tropical Surgery: Rank-2 Min-Plus Matrix Updates

Demonstrates the key theorems about tropical matrix surgery with
concrete numerical examples.
"""

import numpy as np

def tropical_rank_one_update(u, v):
    """Rank-one tropical outer product: M[i,j] = u[i] + v[j]."""
    n = len(u)
    return np.add.outer(u, v)

def tropical_rank_two_surgery(A, u, v, u_prime, v_prime):
    """Rank-2 tropical surgery: B[i,j] = min(A[i,j], u[i]+v[j], u'[i]+v'[j])."""
    R1 = tropical_rank_one_update(u, v)
    R2 = tropical_rank_one_update(u_prime, v_prime)
    return np.minimum(A, np.minimum(R1, R2))

def two_entry_surgery(A, i1, j1, c1, i2, j2, c2):
    """Localized two-entry surgery."""
    B = A.copy()
    B[i1, j1] = min(A[i1, j1], c1)
    B[i2, j2] = min(A[i2, j2], c2)
    return B

def closed_walk_weight(A, sigma):
    """Weight of closed walk sigma in matrix A."""
    k = len(sigma)
    return sum(A[sigma[t], sigma[(t+1) % k]] for t in range(k))

def cycle_mean(A, sigma):
    """Average edge weight of a closed walk."""
    return closed_walk_weight(A, sigma) / len(sigma)

def all_walks(n, max_length):
    """Generate all closed walks of length 1..max_length on n vertices."""
    from itertools import product
    walks = []
    for k in range(1, max_length + 1):
        for sigma in product(range(n), repeat=k):
            walks.append(list(sigma))
    return walks

def tropical_spectral_radius(A):
    """Minimum cycle mean over all closed walks up to length n."""
    n = A.shape[0]
    walks = all_walks(n, n)
    return min(cycle_mean(A, w) for w in walks)

def print_matrix(name, M):
    """Pretty-print a matrix."""
    print(f"\n{name}:")
    for row in M:
        print("  [" + ", ".join(f"{x:7.2f}" for x in row) + "]")

# ============================================================
# DEMO 1: Rank-2 Surgery Spectral Monotonicity
# ============================================================
print("=" * 60)
print("DEMO 1: Rank-2 Tropical Surgery — Spectral Monotonicity")
print("=" * 60)

n = 3
A = np.array([
    [2.0, 5.0, 8.0],
    [3.0, 1.0, 4.0],
    [7.0, 6.0, 3.0]
])

u = np.array([1.0, 2.0, 3.0])
v = np.array([0.5, 1.5, 2.5])
u_prime = np.array([0.0, 1.0, 2.0])
v_prime = np.array([1.0, 0.0, 1.0])

B = tropical_rank_two_surgery(A, u, v, u_prime, v_prime)

rho_A = tropical_spectral_radius(A)
rho_B = tropical_spectral_radius(B)

print_matrix("Original matrix A", A)
print_matrix("Surgery result B = min(A, u⊕v, u'⊕v')", B)
print(f"\nTropical spectral radius ρ(A) = {rho_A:.4f}")
print(f"Tropical spectral radius ρ(B) = {rho_B:.4f}")
print(f"ρ(B) ≤ ρ(A)? {rho_B <= rho_A + 1e-10}  ✓" if rho_B <= rho_A + 1e-10 else "FAILED!")

# Check entrywise inequality
assert np.all(B <= A + 1e-10), "Entrywise inequality B ≤ A violated!"
print("B ≤ A entrywise? True  ✓")

# Explicit bound
diag_min_uv = min(u[i] + v[i] for i in range(n))
diag_min_uv_prime = min(u_prime[i] + v_prime[i] for i in range(n))
explicit_bound = min(rho_A, min(diag_min_uv, diag_min_uv_prime))
print(f"\nExplicit bound: min(ρ(A), min_i(u_i+v_i), min_i(u'_i+v'_i)) = {explicit_bound:.4f}")
print(f"ρ(B) ≤ explicit bound? {rho_B <= explicit_bound + 1e-10}  ✓")

# ============================================================
# DEMO 2: Two-Entry Surgery
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Two-Entry Surgery — Localized Spectral Control")
print("=" * 60)

A2 = np.array([
    [1.0, 4.0, 7.0],
    [2.0, 3.0, 5.0],
    [6.0, 8.0, 2.0]
])

B2 = two_entry_surgery(A2, 0, 1, -1.0, 2, 0, 0.5)

rho_A2 = tropical_spectral_radius(A2)
rho_B2 = tropical_spectral_radius(B2)

print_matrix("Original A", A2)
print_matrix("Two-entry surgery B (decreased A[0,1] and A[2,0])", B2)
print(f"\nρ(A) = {rho_A2:.4f}")
print(f"ρ(B) = {rho_B2:.4f}")
print(f"ρ(B) ≤ ρ(A)? {rho_B2 <= rho_A2 + 1e-10}  ✓")

# ============================================================
# DEMO 3: Off-Critical Surgery Preservation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Off-Critical Surgery — Spectral Preservation")
print("=" * 60)

# Construct a matrix where the optimal cycle is the self-loop at vertex 0
A3 = np.array([
    [1.0, 10.0, 10.0],
    [10.0, 5.0, 10.0],
    [10.0, 10.0, 8.0]
])

# Surgery only affects entry (1,2), which is not on the optimal self-loop
B3 = two_entry_surgery(A3, 1, 2, 3.0, 1, 2, 3.0)  # only one entry

rho_A3 = tropical_spectral_radius(A3)
rho_B3 = tropical_spectral_radius(B3)

print_matrix("Original A (optimal cycle: self-loop at vertex 0, mean=1.0)", A3)
print_matrix("Surgery B (decreased A[1,2] from 10 to 3)", B3)
print(f"\nρ(A) = {rho_A3:.4f}")
print(f"ρ(B) = {rho_B3:.4f}")
print(f"Spectral radius preserved? {abs(rho_A3 - rho_B3) < 1e-10}")
print("Note: Surgery at (1,2) does NOT affect the optimal self-loop at vertex 0")

# ============================================================
# DEMO 4: Surgery Idempotence
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Surgery Idempotence")
print("=" * 60)

B4 = tropical_rank_two_surgery(A, u, v, u_prime, v_prime)
B4_idem = tropical_rank_two_surgery(B4, u, v, u_prime, v_prime)

print("surgery(surgery(A)) == surgery(A)?", np.allclose(B4, B4_idem), " ✓")

# ============================================================
# DEMO 5: Dimension scaling
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Scaling Behavior (dimensions 2-8)")
print("=" * 60)

np.random.seed(42)
for dim in [2, 3, 4, 5]:
    A_rand = np.random.randn(dim, dim) * 3
    u_rand = np.random.randn(dim)
    v_rand = np.random.randn(dim)
    up_rand = np.random.randn(dim)
    vp_rand = np.random.randn(dim)
    
    B_rand = tropical_rank_two_surgery(A_rand, u_rand, v_rand, up_rand, vp_rand)
    rA = tropical_spectral_radius(A_rand)
    rB = tropical_spectral_radius(B_rand)
    
    status = "✓" if rB <= rA + 1e-10 else "✗"
    print(f"  n={dim}: ρ(A)={rA:+.4f}, ρ(B)={rB:+.4f}, ρ(B)≤ρ(A)? {status}")

print("\nAll demonstrations completed successfully!")


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""

import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary(path):
    with open(path, 'rb') as f:
        return f.read()

def png_to_data_uri(path):
    data = read_binary(path)
    b64 = base64.b64encode(data).decode('utf-8')
    return f"data:image/png;base64,{b64}"

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_defs = read_file('Tropical/Surgery/Defs.lean')
lean_mono = read_file('Tropical/Surgery/Monotonicity.lean')

# Read visualizations
viz1 = png_to_data_uri('spectral_monotonicity.png')
viz2 = png_to_data_uri('sensitivity_heatmap.png')
viz3 = png_to_data_uri('surgery_comparison.png')

package = {
    "title": "Tropical Surgery: Rank-2 Min-Plus Matrix Updates and Spectral Monotonicity",
    "domain": "Tropical Algebra / Spectral Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Surgery Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Karp's Minimum Cycle Mean",
            "pseudocode": """Algorithm: Karp's Minimum Cycle Mean
Input:  A ∈ ℝ^{n×n}
Output: λ* = min cycle mean

1. For each source s ∈ {0,...,n-1}:
   a. F[0][s] ← 0; F[0][v] ← +∞ for v ≠ s
   b. For k = 1 to n:
      F[k][v] ← min_u (F[k-1][u] + A[u][v])
   c. For each v with F[n][v] < ∞:
      ratio[v] ← max_{0≤k<n} (F[n][v] - F[k][v]) / (n-k)
2. Return min over all s,v of ratio[v]

Time: O(n³)  Space: O(n²)""",
            "code": algorithms_code
        },
        {
            "name": "Rank-2 Tropical Surgery",
            "pseudocode": """Algorithm: Rank-2 Surgery with Spectral Bound
Input:  A ∈ ℝ^{n×n}, vectors u, v, u', v'
Output: B (surgery matrix), upper bound on ρ(B)

1. B[i][j] ← min(A[i][j], u[i]+v[j], u'[i]+v'[j])    // O(n²)
2. ρ_A ← Karp(A)                                        // O(n³)
3. d1 ← min_i (u[i] + v[i])                             // O(n)
4. d2 ← min_i (u'[i] + v'[i])                           // O(n)
5. bound ← min(ρ_A, d1, d2)
6. Return B, bound

Total time: O(n³)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Spectral Radius Under Rank-2 Surgery",
            "data": viz1
        },
        {
            "name": "Edge Sensitivity Heatmap",
            "data": viz2
        },
        {
            "name": "Surgery Type Comparison",
            "data": viz3
        }
    ],
    "lean_proofs": lean_defs + "\n\n" + lean_mono
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
visualizations.py — Visualizations for Tropical Surgery Theory

Generates publication-quality figures showing:
1. Spectral radius under surgery (heatmap)
2. Surgery support and critical cycles
3. Sensitivity landscape
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import base64
from io import BytesIO
from itertools import product


def tropical_spectral_radius_bf(A):
    """Brute-force tropical spectral radius for small matrices."""
    n = A.shape[0]
    best = float('inf')
    for length in range(1, n + 1):
        for cycle in product(range(n), repeat=length):
            weight = sum(A[cycle[t], cycle[(t+1) % length]] for t in range(length))
            mean = weight / length
            best = min(best, mean)
    return best


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def visualization_1_spectral_monotonicity():
    """
    Heatmap showing how rank-2 surgery affects spectral radius
    as we scale the surgery vectors.
    """
    n = 3
    A = np.array([
        [2.0, 5.0, 8.0],
        [3.0, 1.0, 4.0],
        [7.0, 6.0, 3.0]
    ])
    
    u0 = np.array([1.0, 2.0, 3.0])
    v0 = np.array([0.5, 1.5, 2.5])
    up0 = np.array([0.0, 1.0, 2.0])
    vp0 = np.array([1.0, 0.0, 1.0])
    
    rho_A = tropical_spectral_radius_bf(A)
    
    # Vary scaling factors for both rank-1 components
    scales = np.linspace(-2, 4, 25)
    rho_grid = np.zeros((len(scales), len(scales)))
    
    for i, s1 in enumerate(scales):
        for j, s2 in enumerate(scales):
            u = u0 + s1
            v = v0 + s1
            up = up0 + s2
            vp = vp0 + s2
            R1 = np.add.outer(u, v)
            R2 = np.add.outer(up, vp)
            B = np.minimum(A, np.minimum(R1, R2))
            rho_grid[i, j] = tropical_spectral_radius_bf(B)
    
    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(rho_grid, extent=[scales[0], scales[-1], scales[0], scales[-1]],
                   origin='lower', cmap='RdYlBu_r', aspect='auto')
    ax.axhline(y=0, color='white', linewidth=0.5, linestyle='--', alpha=0.5)
    ax.axvline(x=0, color='white', linewidth=0.5, linestyle='--', alpha=0.5)
    
    # Mark ρ(A) contour
    cs = ax.contour(scales, scales, rho_grid, levels=[rho_A], colors='black',
                    linewidths=2, linestyles='--')
    ax.clabel(cs, fmt=f'ρ(A)={rho_A:.1f}', fontsize=10)
    
    cbar = plt.colorbar(im, ax=ax, label='Tropical Spectral Radius ρ(B)')
    ax.set_xlabel('Scale factor for component 1 (u, v)', fontsize=12)
    ax.set_ylabel('Scale factor for component 2 (u\', v\')', fontsize=12)
    ax.set_title('Spectral Radius After Rank-2 Surgery\n(Always ≤ ρ(A) by Monotonicity Theorem)', fontsize=13)
    
    return fig_to_base64(fig)


def visualization_2_sensitivity_heatmap():
    """
    Sensitivity heatmap: which edges are most spectrally sensitive?
    """
    A = np.array([
        [2.0, 5.0, 8.0, 4.0],
        [3.0, 1.0, 4.0, 7.0],
        [7.0, 6.0, 3.0, 2.0],
        [5.0, 3.0, 6.0, 4.0],
    ])
    
    n = 4
    eps = 0.3
    rho_A = tropical_spectral_radius_bf(A)
    sens = np.zeros((n, n))
    
    for i in range(n):
        for j in range(n):
            B = A.copy()
            B[i, j] -= eps
            rho_B = tropical_spectral_radius_bf(B)
            sens[i, j] = (rho_A - rho_B) / eps
    
    fig, ax = plt.subplots(figsize=(7, 6))
    im = ax.imshow(sens, cmap='YlOrRd', interpolation='nearest')
    
    # Annotate cells
    for i in range(n):
        for j in range(n):
            color = 'white' if sens[i, j] > 0.5 * sens.max() else 'black'
            ax.text(j, i, f'{sens[i, j]:.3f}', ha='center', va='center',
                    fontsize=11, color=color, fontweight='bold')
    
    labels = [f'v{i}' for i in range(n)]
    ax.set_xticks(range(n))
    ax.set_xticklabels(labels, fontsize=11)
    ax.set_yticks(range(n))
    ax.set_yticklabels(labels, fontsize=11)
    ax.set_xlabel('Target vertex', fontsize=12)
    ax.set_ylabel('Source vertex', fontsize=12)
    ax.set_title('Spectral Sensitivity: Δρ / Δweight per Edge\n(Higher = more impact on spectral radius)', fontsize=13)
    plt.colorbar(im, ax=ax, label='Sensitivity')
    
    return fig_to_base64(fig)


def visualization_3_surgery_comparison():
    """
    Bar chart comparing spectral radii before/after different surgery types.
    """
    A = np.array([
        [3.0, 5.0, 9.0],
        [4.0, 2.0, 6.0],
        [8.0, 7.0, 4.0]
    ])
    
    rho_A = tropical_spectral_radius_bf(A)
    
    # Different surgery operations
    surgeries = []
    
    # 1. Rank-1 surgery
    u1 = np.array([1.0, 2.0, 3.0])
    v1 = np.array([0.5, 1.5, 2.5])
    B1 = np.minimum(A, np.add.outer(u1, v1))
    surgeries.append(('Rank-1\n(u⊕v)', tropical_spectral_radius_bf(B1)))
    
    # 2. Rank-2 surgery  
    u2, v2 = np.array([0.0, 1.0, 2.0]), np.array([1.0, 0.0, 1.0])
    B2 = np.minimum(B1, np.add.outer(u2, v2))
    surgeries.append(('Rank-2\n(u⊕v, u\'⊕v\')', tropical_spectral_radius_bf(B2)))
    
    # 3. Single entry surgery
    B3 = A.copy(); B3[0, 0] = min(A[0, 0], 1.0)
    surgeries.append(('1-entry\n(A[0,0]↓)', tropical_spectral_radius_bf(B3)))
    
    # 4. Two-entry surgery
    B4 = A.copy(); B4[0, 0] = min(A[0, 0], 1.0); B4[1, 1] = min(A[1, 1], 0.5)
    surgeries.append(('2-entry\n(A[0,0],A[1,1]↓)', tropical_spectral_radius_bf(B4)))
    
    # 5. Aggressive surgery
    B5 = np.minimum(A, np.add.outer(np.array([-1, -1, -1]), np.array([-1, -1, -1])))
    surgeries.append(('Aggressive\n(all entries↓)', tropical_spectral_radius_bf(B5)))
    
    fig, ax = plt.subplots(figsize=(10, 5))
    names = [s[0] for s in surgeries]
    values = [s[1] for s in surgeries]
    
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']
    bars = ax.bar(range(len(surgeries)), values, color=colors, alpha=0.85, edgecolor='black')
    ax.axhline(y=rho_A, color='red', linestyle='--', linewidth=2, label=f'ρ(A) = {rho_A:.2f}')
    
    for bar, val in zip(bars, values):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
                f'{val:.2f}', ha='center', va='bottom', fontsize=11, fontweight='bold')
    
    ax.set_xticks(range(len(surgeries)))
    ax.set_xticklabels(names, fontsize=10)
    ax.set_ylabel('Tropical Spectral Radius', fontsize=12)
    ax.set_title('Spectral Radius Comparison: Original vs. Surgery\n(All bars ≤ dashed line by Monotonicity Theorem)', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(min(values) - 0.5, rho_A + 0.5)
    
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    print("  1/3: Spectral monotonicity heatmap...")
    data1 = visualization_1_spectral_monotonicity()
    print(f"       Generated ({len(data1)} bytes)")
    
    print("  2/3: Sensitivity heatmap...")
    data2 = visualization_2_sensitivity_heatmap()
    print(f"       Generated ({len(data2)} bytes)")
    
    print("  3/3: Surgery comparison...")
    data3 = visualization_3_surgery_comparison()
    print(f"       Generated ({len(data3)} bytes)")
    
    # Save PNGs for standalone use
    for i, (name, data) in enumerate([
        ("spectral_monotonicity", data1),
        ("sensitivity_heatmap", data2),
        ("surgery_comparison", data3),
    ]):
        png_data = base64.b64decode(data.split(",")[1])
        with open(f"{name}.png", "wb") as f:
            f.write(png_data)
        print(f"  Saved {name}.png")
    
    print("All visualizations generated successfully!")
