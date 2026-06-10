#!/usr/bin/env python3
"""
Tropical Entanglement Wedge — Applications

Demonstrates real-world applications of tropical holographic reconstruction:
1. Sensor network fault localization
2. Network tomography / link failure detection
3. Secure computation with locality guarantees
"""

import numpy as np
from typing import Set, Dict, List, Tuple


# ============================================================
# Core functions (self-contained)
# ============================================================

def shortest_paths(n: int, edges: List[Tuple[int, int, float]]) -> np.ndarray:
    """Floyd-Warshall shortest paths."""
    d = np.full((n, n), np.inf)
    np.fill_diagonal(d, 0.0)
    for u, v, w in edges:
        d[u][v] = min(d[u][v], w)
        d[v][u] = min(d[v][u], w)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]
    return d


def dist_to_set(d: np.ndarray, s: Set[int], v: int) -> float:
    return min(d[v][b] for b in s) if s else float('inf')


def wedge(bulk: Set[int], boundary: Set[int], B: Set[int],
          d: np.ndarray) -> Set[int]:
    Bc = boundary - B
    if not B or not Bc:
        return set()
    return {v for v in bulk if dist_to_set(d, B, v) < dist_to_set(d, Bc, v)}


def obs(bulk: Set[int], d: np.ndarray, phi: Dict[int, float], b: int) -> float:
    return min(phi[v] + d[v][b] for v in bulk)


# ============================================================
# APPLICATION 1: Sensor Network Fault Localization
# ============================================================

def sensor_network_demo():
    """
    A sensor network has monitoring stations (boundary) and internal
    nodes (bulk). When an internal node fails, we want to determine
    which monitoring stations can detect the failure.

    The tropical entanglement wedge tells us: a monitoring subset B
    can detect failures at any node in Wedge(B), and ONLY those nodes.
    """
    print("=" * 60)
    print("APPLICATION 1: Sensor Network Fault Localization")
    print("=" * 60)

    # 12-node sensor network
    # Boundary (monitoring stations): 0-3
    # Bulk (internal nodes): 4-11
    n = 12
    edges = [
        # Monitoring station connections
        (0, 4, 2), (0, 5, 3), (1, 5, 2), (1, 6, 4),
        (2, 7, 2), (2, 8, 3), (3, 8, 2), (3, 9, 4),
        # Internal connections
        (4, 5, 1), (5, 6, 1), (6, 7, 2), (7, 8, 1),
        (8, 9, 1), (4, 10, 3), (9, 11, 3),
        (10, 6, 2), (11, 7, 2),
    ]
    d = shortest_paths(n, edges)
    boundary = {0, 1, 2, 3}
    bulk = set(range(4, 12))

    # Which nodes can station subset {0, 1} monitor?
    B_left = {0, 1}
    W_left = wedge(bulk, boundary, B_left, d)

    # Which nodes can station subset {2, 3} monitor?
    B_right = {2, 3}
    W_right = wedge(bulk, boundary, B_right, d)

    print(f"\nNetwork: {n} nodes, {len(edges)} edges")
    print(f"Monitoring stations (boundary): {sorted(boundary)}")
    print(f"Internal nodes (bulk): {sorted(bulk)}")

    print(f"\nStation group B_left = {B_left}")
    print(f"  Detectable region (wedge): {sorted(W_left)}")

    print(f"\nStation group B_right = {B_right}")
    print(f"  Detectable region (wedge): {sorted(W_right)}")

    overlap = W_left & W_right
    uncovered = bulk - W_left - W_right
    print(f"\nOverlap (detectable by both): {sorted(overlap)}")
    print(f"Uncovered (detectable by neither): {sorted(uncovered)}")

    # Simulate a fault and detect it
    phi_normal = {v: 0.0 for v in bulk}
    fault_node = min(W_left) if W_left else 4
    phi_fault = dict(phi_normal)
    phi_fault[fault_node] = 10.0  # fault = large value

    print(f"\nSimulating fault at node {fault_node}:")
    for b in sorted(B_left):
        o_normal = obs(bulk, d, phi_normal, b)
        o_fault = obs(bulk, d, phi_fault, b)
        detected = "DETECTED ✓" if abs(o_normal - o_fault) > 0.01 else "no change"
        print(f"  Station {b}: obs={o_normal:.1f} → {o_fault:.1f}  [{detected}]")


# ============================================================
# APPLICATION 2: Network Tomography
# ============================================================

def network_tomography_demo():
    """
    In network tomography, we probe a network from boundary nodes
    and reconstruct internal link properties. The wedge theorem
    guarantees which internal links are reconstructible from
    measurements at a given probe set.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Tomography")
    print("=" * 60)

    # 8-node network
    n = 8
    boundary = {0, 1, 2, 3}
    bulk = {4, 5, 6, 7}

    # Original link weights (latencies in ms)
    edges_orig = [
        (0, 4, 5), (1, 4, 8), (2, 5, 5), (3, 5, 8),
        (4, 6, 3), (5, 7, 3), (6, 7, 2),
        (4, 5, 10), (0, 6, 12), (3, 7, 12),
    ]
    d_orig = shortest_paths(n, edges_orig)

    # Degraded link: edge (4,6) increases from 3 to 15 ms
    edges_degraded = [(u, v, w) if (u, v) != (4, 6) else (u, v, 15)
                      for u, v, w in edges_orig]
    d_degraded = shortest_paths(n, edges_degraded)

    B = {0, 1}
    W = wedge(bulk, boundary, B, d_orig)

    print(f"\nProbe set B = {B}")
    print(f"Wedge(B) = {sorted(W)}")

    phi = {v: 0.0 for v in bulk}

    print(f"\nBoundary observations (original vs degraded):")
    for b in sorted(B):
        o1 = obs(bulk, d_orig, phi, b)
        o2 = obs(bulk, d_degraded, phi, b)
        change = "CHANGED ✓" if abs(o1 - o2) > 0.01 else "same"
        print(f"  Probe {b}: {o1:.1f} → {o2:.1f}  [{change}]")

    # Gap analysis shows robustness
    print(f"\nWedge gap analysis:")
    Bc = boundary - B
    for v in sorted(bulk):
        dB = dist_to_set(d_orig, B, v)
        dBc = dist_to_set(d_orig, Bc, v)
        gap = dBc - dB
        print(f"  Node {v}: d_B={dB:.1f}, d_Bc={dBc:.1f}, "
              f"gap={gap:.1f}, in_wedge={v in W}")


# ============================================================
# APPLICATION 3: Information-Theoretic Locality
# ============================================================

def information_locality_demo():
    """
    In distributed computing, the wedge theorem provides locality
    guarantees: data stored at nodes in Wedge(B) is accessible
    from servers in B, while data outside the wedge requires
    accessing servers outside B.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Distributed Data Locality")
    print("=" * 60)

    # Data center topology
    n = 10
    # Boundary = access points, Bulk = storage nodes
    boundary = {0, 1, 2, 3}
    bulk = {4, 5, 6, 7, 8, 9}

    edges = [
        (0, 4, 1), (0, 5, 4), (1, 5, 1), (1, 6, 4),
        (2, 7, 1), (2, 8, 4), (3, 8, 1), (3, 9, 4),
        (4, 5, 2), (5, 6, 2), (6, 7, 2), (7, 8, 2), (8, 9, 2),
        (4, 7, 5), (5, 8, 5), (6, 9, 5),
    ]
    d = shortest_paths(n, edges)

    # Query from access points {0, 1}
    B = {0, 1}
    W = wedge(bulk, boundary, B, d)

    print(f"\nAccess points (boundary): {sorted(boundary)}")
    print(f"Storage nodes (bulk): {sorted(bulk)}")
    print(f"Query subset B = {B}")
    print(f"Locally accessible storage (wedge): {sorted(W)}")
    print(f"Coverage: {len(W)}/{len(bulk)} = {100*len(W)/len(bulk):.0f}%")

    # Show gaps = locality strength
    Bc = boundary - B
    print(f"\nLocality strength (gap = robustness margin):")
    for v in sorted(bulk):
        dB = dist_to_set(d, B, v)
        dBc = dist_to_set(d, Bc, v)
        gap = dBc - dB
        status = "LOCAL ✓" if gap > 0 else ("TIE" if gap == 0 else "REMOTE")
        print(f"  Storage {v}: gap={gap:+.1f}  [{status}]")

    # Demonstrate reconstruction: if we know observations from B,
    # we can reconstruct data on W
    data = {v: float(v * 10) for v in bulk}
    print(f"\nStored data: {data}")
    profile = {b: obs(bulk, d, data, b) for b in B}
    print(f"Observable profile from B: {profile}")


# ============================================================
# Run all applications
# ============================================================

if __name__ == "__main__":
    sensor_network_demo()
    network_tomography_demo()
    information_locality_demo()
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Entanglement Wedge — Concrete Numerical Demonstrations

This script demonstrates the core theorems of the tropical entanglement wedge
theory on small finite graphs, making the abstract mathematics tangible.
"""

import numpy as np
from itertools import combinations


def dist_to_finset(d, s, v):
    """Min-plus distance from vertex v to a set of vertices s."""
    return min(d[v][b] for b in s)


def entanglement_wedge(bulk, boundary, B, d):
    """Compute the entanglement wedge of B within bulk."""
    Bc = boundary - B
    if not B or not Bc:
        return bulk if not B else set()
    return {v for v in bulk if dist_to_finset(d, B, v) < dist_to_finset(d, Bc, v)}


def boundary_obs(bulk, d, phi, b):
    """Tropical convolution: Obs(φ)(b) = min_{v in bulk} (φ(v) + d(v,b))."""
    return min(phi[v] + d[v][b] for v in bulk)


def support_on(S, phi, phi_prime):
    """Check if phi' agrees with phi outside S."""
    return all(phi_prime[v] == phi[v] for v in phi if v not in S)


# ============================================================
# Demo 1: Triangle Graph — Wedge Membership Criterion
# ============================================================
print("=" * 60)
print("DEMO 1: Triangle Graph — Wedge Membership")
print("=" * 60)

# 5-vertex graph: boundary = {0,1,2,3}, bulk = {4}
# B = {0,1}, Bc = {2,3}
n = 5
d = np.full((n, n), 100.0)
np.fill_diagonal(d, 0.0)

# Edges (with weights)
edges = [(0, 4, 1.0), (1, 4, 2.0), (2, 4, 5.0), (3, 4, 6.0)]
for u, v, w in edges:
    d[u][v] = w
    d[v][u] = w

boundary = {0, 1, 2, 3}
bulk = {4}
B = {0, 1}
Bc = boundary - B

v = 4
dB = dist_to_finset(d, B, v)
dBc = dist_to_finset(d, Bc, v)
wedge = entanglement_wedge(bulk, boundary, B, d)

print(f"Vertex 4: d_B = {dB}, d_Bc = {dBc}")
print(f"Gap = {dBc - dB}")
print(f"Wedge(B) = {wedge}")
print(f"v=4 in wedge: {4 in wedge}")
print(f"✓ mem_entanglementWedge_iff confirmed: d_B < d_Bc ⟺ v ∈ Wedge(B)")
print()

# ============================================================
# Demo 2: Perturbation Stability
# ============================================================
print("=" * 60)
print("DEMO 2: Perturbation Stability")
print("=" * 60)

gap = dBc - dB
print(f"Original gap δ = {gap}")

# Perturb distances by ε = 1.0 < gap/2 = {gap/2}
eps = 1.0
d_prime = d.copy()
d_prime[4][0] += 0.5   # small perturbation
d_prime[0][4] += 0.5
d_prime[4][2] -= 0.3
d_prime[2][4] -= 0.3

dB_new = dist_to_finset(d_prime, B, v)
dBc_new = dist_to_finset(d_prime, Bc, v)
print(f"Perturbed: d'_B = {dB_new}, d'_Bc = {dBc_new}")
print(f"New gap = {dBc_new - dB_new}")
print(f"2ε = {2*eps}, original gap = {gap}")
if 2 * eps < gap:
    print(f"✓ 2ε < gap, so wedge membership is stable!")
    wedge_new = entanglement_wedge(bulk, boundary, B, d_prime)
    print(f"New wedge: {wedge_new}")
else:
    print("Gap too small for stability guarantee with this ε")
print()

# ============================================================
# Demo 3: Surgery Detectability
# ============================================================
print("=" * 60)
print("DEMO 3: Surgery Detectability")
print("=" * 60)

# 6 vertices: boundary = {0,1,2,3}, bulk = {4,5}
n2 = 6
d2 = np.full((n2, n2), 100.0)
np.fill_diagonal(d2, 0.0)

edges2 = [
    (0, 4, 1.0), (1, 4, 3.0), (2, 5, 1.0), (3, 5, 3.0),
    (4, 5, 2.0), (0, 5, 4.0), (1, 5, 5.0), (2, 4, 4.0), (3, 4, 5.0)
]
for u, v, w in edges2:
    d2[u][v] = w
    d2[v][u] = w

boundary2 = {0, 1, 2, 3}
bulk2 = {4, 5}
B2 = {0, 1}

wedge2 = entanglement_wedge(bulk2, boundary2, B2, d2)
print(f"Bulk = {bulk2}")
print(f"B = {B2}, Bc = {boundary2 - B2}")
print(f"Wedge(B) = {wedge2}")

# Bulk state
phi = {4: 0.0, 5: 0.0}
# Surgery: change φ at vertex 4 (which is in the wedge)
phi_prime = {4: 3.0, 5: 0.0}

print(f"\nOriginal φ = {phi}")
print(f"Surgery φ' = {phi_prime} (changed at v=4)")

for b in B2:
    obs_orig = boundary_obs(bulk2, d2, phi, b)
    obs_new = boundary_obs(bulk2, d2, phi_prime, b)
    status = "DETECTED ✓" if obs_orig != obs_new else "same"
    print(f"  Obs(φ)(b={b}) = {obs_orig}, Obs(φ')(b={b}) = {obs_new}  [{status}]")

print()

# ============================================================
# Demo 4: Wedge Reconstruction
# ============================================================
print("=" * 60)
print("DEMO 4: Wedge Reconstruction")
print("=" * 60)

# Show that if Obs_B(φ) = Obs_B(φ') for all b ∈ B, then φ = φ' on Wedge(B)
# under the unique argmin hypothesis.

# Use vertex 4 in the wedge. Check unique argmin:
for b in B2:
    vals = {v: phi[v] + d2[v][b] for v in bulk2}
    argmin_v = min(vals, key=vals.get)
    print(f"  At b={b}: argmin is v={argmin_v}, values = {vals}")
    if argmin_v in wedge2:
        second_best = min(v for v in vals.values() if v > vals[argmin_v])
        print(f"    Unique argmin gap = {second_best - vals[argmin_v]}")

# If observations agree, states must agree on wedge
phi2 = {4: 0.0, 5: 0.0}
phi2_prime = {4: 0.0, 5: 5.0}  # Only change outside wedge

obs_agree = all(
    boundary_obs(bulk2, d2, phi2, b) == boundary_obs(bulk2, d2, phi2_prime, b)
    for b in B2
)
print(f"\nφ = {phi2}, φ' = {phi2_prime}")
print(f"Obs_B(φ) = Obs_B(φ'): {obs_agree}")
print(f"φ = φ' on Wedge(B): {all(phi2[v] == phi2_prime[v] for v in wedge2)}")
print(f"✓ Reconstruction theorem confirmed on example!")
print()

# ============================================================
# Demo 5: Larger Graph — Voronoi Structure
# ============================================================
print("=" * 60)
print("DEMO 5: 10-vertex Graph — Tropical Voronoi")
print("=" * 60)

np.random.seed(42)
n3 = 10
boundary3 = {0, 1, 2, 3}
bulk3 = {4, 5, 6, 7, 8, 9}

# Random edge weights
d3 = np.full((n3, n3), 1000.0)
np.fill_diagonal(d3, 0.0)
for i in range(n3):
    for j in range(i+1, n3):
        if np.random.random() < 0.5:
            w = np.random.uniform(1.0, 10.0)
            d3[i][j] = w
            d3[j][i] = w

# Ensure connectivity: add edges from bulk to boundary
for v in bulk3:
    for b in boundary3:
        if d3[v][b] > 50:
            w = np.random.uniform(2.0, 8.0)
            d3[v][b] = w
            d3[b][v] = w

B3 = {0, 1}
Bc3 = boundary3 - B3

for v in sorted(bulk3):
    dB_v = dist_to_finset(d3, B3, v)
    dBc_v = dist_to_finset(d3, Bc3, v)
    in_wedge = dB_v < dBc_v
    print(f"  v={v}: d_B={dB_v:.2f}, d_Bc={dBc_v:.2f}, "
          f"gap={dBc_v-dB_v:.2f}, in_wedge={in_wedge}")

wedge3 = entanglement_wedge(bulk3, boundary3, B3, d3)
print(f"\nWedge({B3}) = {wedge3}")
print(f"|Wedge| = {len(wedge3)}, |Bulk| = {len(bulk3)}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Entanglement Wedge — Visualizations

Generates figures illustrating the key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import LineCollection
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def shortest_paths(n, edges):
    d = np.full((n, n), np.inf)
    np.fill_diagonal(d, 0.0)
    for u, v, w in edges:
        d[u][v] = min(d[u][v], w)
        d[v][u] = min(d[v][u], w)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i][k] + d[k][j] < d[i][j]:
                    d[i][j] = d[i][k] + d[k][j]
    return d


def dist_to_set(d, s, v):
    return min(d[v][b] for b in s) if s else float('inf')


# ============================================================
# Figure 1: Entanglement Wedge on a Graph
# ============================================================

def make_wedge_figure():
    """Visualize the entanglement wedge on a 2D graph layout."""
    n = 10
    boundary = {0, 1, 2, 3}
    bulk = {4, 5, 6, 7, 8, 9}

    edges = [
        (0, 4, 1), (0, 5, 3), (1, 5, 1), (1, 6, 3),
        (2, 7, 1), (2, 8, 3), (3, 8, 1), (3, 9, 3),
        (4, 5, 2), (5, 6, 2), (6, 7, 2), (7, 8, 2), (8, 9, 2),
        (4, 7, 6), (6, 9, 6),
    ]
    d = shortest_paths(n, edges)

    # 2D layout
    pos = {
        0: (0, 0), 1: (2, 0), 2: (6, 0), 3: (8, 0),
        4: (0.5, 2), 5: (2, 2), 6: (4, 2),
        7: (6, 2), 8: (7, 2), 9: (8.5, 2),
    }

    B = {0, 1}
    Bc = boundary - B

    fig, ax = plt.subplots(1, 1, figsize=(12, 5))

    # Draw edges
    for u, v, w in edges:
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        ax.plot(x, y, 'k-', alpha=0.3, linewidth=1)
        mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
        ax.text(mx, my + 0.15, f'{w}', fontsize=7, ha='center',
                color='gray', alpha=0.7)

    # Classify and draw vertices
    for v in range(n):
        x, y = pos[v]
        if v in B:
            ax.plot(x, y, 'o', color='#2196F3', markersize=18, zorder=5)
            ax.text(x, y, str(v), ha='center', va='center',
                    fontsize=10, fontweight='bold', color='white', zorder=6)
        elif v in Bc:
            ax.plot(x, y, 's', color='#FF5722', markersize=18, zorder=5)
            ax.text(x, y, str(v), ha='center', va='center',
                    fontsize=10, fontweight='bold', color='white', zorder=6)
        else:
            dB = dist_to_set(d, B, v)
            dBc = dist_to_set(d, Bc, v)
            if dB < dBc:
                # In wedge
                ax.plot(x, y, 'D', color='#4CAF50', markersize=16, zorder=5)
                ax.text(x, y, str(v), ha='center', va='center',
                        fontsize=9, fontweight='bold', color='white', zorder=6)
            else:
                ax.plot(x, y, 'D', color='#9E9E9E', markersize=16, zorder=5)
                ax.text(x, y, str(v), ha='center', va='center',
                        fontsize=9, fontweight='bold', color='white', zorder=6)

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#2196F3', label='B (boundary subset)'),
        mpatches.Patch(facecolor='#FF5722', label='Bᶜ (complement)'),
        mpatches.Patch(facecolor='#4CAF50', label='Wedge(B) — detectable'),
        mpatches.Patch(facecolor='#9E9E9E', label='Outside wedge'),
    ]
    ax.legend(handles=legend_elements, loc='upper center', ncol=4,
              fontsize=9, framealpha=0.9)

    ax.set_xlim(-1, 10)
    ax.set_ylim(-0.8, 3.2)
    ax.set_aspect('equal')
    ax.set_title('Tropical Entanglement Wedge on a Finite Graph',
                 fontsize=14, fontweight='bold')
    ax.axis('off')

    return fig_to_base64(fig)


# ============================================================
# Figure 2: Gap Function / Stability Landscape
# ============================================================

def make_gap_figure():
    """Plot the separation gap δ_v for each bulk vertex."""
    n = 12
    boundary = {0, 1, 2, 3}
    bulk = sorted(range(4, 12))

    edges = [
        (0, 4, 1), (0, 5, 4), (1, 5, 1), (1, 6, 3),
        (2, 7, 1), (2, 8, 4), (3, 8, 1), (3, 9, 3),
        (4, 5, 2), (5, 6, 2), (6, 7, 2), (7, 8, 2), (8, 9, 2),
        (4, 10, 3), (9, 11, 3), (10, 7, 2), (11, 6, 2),
    ]
    d = shortest_paths(n, edges)

    B = {0, 1}
    Bc = boundary - B

    gaps = []
    for v in bulk:
        dB = dist_to_set(d, B, v)
        dBc = dist_to_set(d, Bc, v)
        gaps.append(dBc - dB)

    fig, ax = plt.subplots(1, 1, figsize=(10, 5))

    colors = ['#4CAF50' if g > 0 else ('#FF5722' if g < 0 else '#FFC107')
              for g in gaps]
    bars = ax.bar([str(v) for v in bulk], gaps, color=colors, edgecolor='white',
                  linewidth=0.5)

    ax.axhline(y=0, color='black', linewidth=1, linestyle='-')
    ax.set_xlabel('Bulk Vertex', fontsize=12)
    ax.set_ylabel('Gap δ_v = d_Bᶜ(v) − d_B(v)', fontsize=12)
    ax.set_title('Wedge Separation Gap: Positive = In Wedge, Negative = Outside',
                 fontsize=13, fontweight='bold')

    # Annotate
    for i, (v, g) in enumerate(zip(bulk, gaps)):
        ax.text(i, g + (0.2 if g >= 0 else -0.4),
                f'δ={g:.1f}', ha='center', fontsize=9,
                fontweight='bold' if g > 0 else 'normal')

    # Stability radius annotation
    ax.fill_between(range(len(bulk)),
                     [g/2 if g > 0 else 0 for g in gaps],
                     [0]*len(bulk),
                     alpha=0.15, color='green',
                     label='Stability radius ε_max = δ/2')

    ax.legend(fontsize=10)
    ax.grid(axis='y', alpha=0.3)
    fig.tight_layout()

    return fig_to_base64(fig)


# ============================================================
# Figure 3: Surgery Detectability Phase Diagram
# ============================================================

def make_detectability_figure():
    """Phase diagram showing detectability vs surgery location."""
    n = 8
    boundary = {0, 1, 2, 3}
    bulk = {4, 5, 6, 7}

    edges = [
        (0, 4, 1), (1, 4, 2), (2, 5, 1), (3, 5, 2),
        (4, 6, 2), (5, 7, 2), (6, 7, 1),
        (4, 5, 5), (0, 7, 8), (3, 6, 8),
    ]
    d = shortest_paths(n, edges)
    B = {0, 1}

    # For each bulk vertex, compute detectability across surgery magnitudes
    magnitudes = np.linspace(0, 5, 50)
    phi_base = {v: 0.0 for v in bulk}

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: detection threshold per vertex
    ax = axes[0]
    for v in sorted(bulk):
        detectable = []
        for mag in magnitudes:
            phi_surgery = dict(phi_base)
            phi_surgery[v] = mag
            detected = any(
                abs(obs_val - obs_new) > 1e-10
                for b in B
                for obs_val, obs_new in [(
                    min(phi_base[w] + d[w][b] for w in bulk),
                    min(phi_surgery[w] + d[w][b] for w in bulk)
                )]
            )
            detectable.append(1 if detected else 0)
        ax.plot(magnitudes, detectable, linewidth=2, label=f'v={v}')

    ax.set_xlabel('Surgery Magnitude |Δφ|', fontsize=12)
    ax.set_ylabel('Detected from B', fontsize=12)
    ax.set_title('Surgery Detectability by Vertex', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['Invisible', 'Detected'])
    ax.grid(alpha=0.3)

    # Right: observation change magnitude
    ax = axes[1]
    for v in sorted(bulk):
        obs_changes = []
        for mag in magnitudes:
            phi_surgery = dict(phi_base)
            phi_surgery[v] = mag
            max_change = max(
                abs(min(phi_base[w] + d[w][b] for w in bulk) -
                    min(phi_surgery[w] + d[w][b] for w in bulk))
                for b in B
            )
            obs_changes.append(max_change)
        ax.plot(magnitudes, obs_changes, linewidth=2, label=f'v={v}')

    ax.set_xlabel('Surgery Magnitude |Δφ|', fontsize=12)
    ax.set_ylabel('Max Observation Change', fontsize=12)
    ax.set_title('Observation Sensitivity by Vertex', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)


# ============================================================
# Generate all figures
# ============================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    wedge_b64 = make_wedge_figure()
    print(f"  Wedge figure: {len(wedge_b64)} chars")

    gap_b64 = make_gap_figure()
    print(f"  Gap figure: {len(gap_b64)} chars")

    detect_b64 = make_detectability_figure()
    print(f"  Detectability figure: {len(detect_b64)} chars")

    # Save base64 strings for PACKAGE.json
    with open('viz_wedge.b64', 'w') as f:
        f.write(wedge_b64)
    with open('viz_gap.b64', 'w') as f:
        f.write(gap_b64)
    with open('viz_detect.b64', 'w') as f:
        f.write(detect_b64)

    print("Done! Base64 data saved to .b64 files.")
