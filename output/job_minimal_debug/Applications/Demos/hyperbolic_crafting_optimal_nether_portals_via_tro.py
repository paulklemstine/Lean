#!/usr/bin/env python3
"""
applications.py — Real-world applications of tropical metric compression
and portal network optimization theory.

Demonstrates how the mathematical framework applies to:
1. Logistics and transportation network design
2. Communication network overlay routing
3. Multi-modal transit optimization
4. Data center interconnection
"""

import random
from algorithms import (
    l1_dist, nether_map, dual_world_cost, prim_mst,
    floyd_warshall_tropical, PortalNetworkOptimizer
)

# ============================================================
# Application 1: Logistics Hub Optimization
# ============================================================
def logistics_demo():
    """
    Model a logistics network where:
    - Surface roads = Overworld (slow, cheap per km)
    - Express highway/rail = Nether (8x faster, fixed access cost)

    The theory predicts that the optimal hub network follows the MST
    of the compressed metric, and there's a crossover distance
    beyond which the express network always dominates.
    """
    print("=" * 60)
    print("APPLICATION 1: Logistics Hub Network Design")
    print("=" * 60)

    # Warehouse locations (in km, scaled by 10)
    warehouses = [
        (0, 0),       # Main distribution center
        (150, 0),     # Port facility
        (0, 120),     # Northern warehouse
        (150, 120),   # Airport cargo
        (75, 60),     # Central sorting hub
        (200, 200),   # Rural distribution point
    ]
    names = ["Main DC", "Port", "North WH", "Airport", "Central Hub", "Rural DP"]

    # Highway ramp cost = 30 units (fixed cost to enter/exit express network)
    ramp_cost = 30

    opt = PortalNetworkOptimizer(warehouses, portal_cost=ramp_cost)
    opt.compute_mst()
    opt.compute_shortest_paths()

    print(f"\nWarehouse locations:")
    for i, (name, loc) in enumerate(zip(names, warehouses)):
        print(f"  [{i}] {name}: {loc}")

    print(f"\nExpress network speed advantage: 8×")
    print(f"Ramp access cost: {ramp_cost} units")
    print(f"Crossover distance: {opt.threshold_distance():.0f} km")

    print(f"\nOptimal backbone connections:")
    for u, v in opt.mst_edges:
        print(f"  {names[u]} ↔ {names[v]}  (cost: {opt.dual_cost_matrix[u][v]})")

    savings = opt.savings_report()
    print(f"\nMST total: {savings['mst_cost']}")
    print(f"Best hub-spoke: {savings['best_star_cost']} (hub: {names[savings['best_star_hub']]})")
    print(f"MST saves: {savings['savings_pct']:.1f}%")


# ============================================================
# Application 2: CDN / Overlay Network Routing
# ============================================================
def cdn_demo():
    """
    Content Delivery Network model:
    - Direct internet = Overworld (variable latency)
    - Private backbone = Nether (low latency, peering cost)

    The tropical closure gives optimal all-pairs routing through
    the overlay network.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: CDN Overlay Network Routing")
    print("=" * 60)

    # Data centers (abstract coordinates representing network distance)
    datacenters = [
        (0, 0),       # US-East
        (400, 0),     # US-West
        (200, 300),   # EU-Central
        (500, 400),   # Asia-Pacific
        (100, 150),   # US-Central
    ]
    dc_names = ["US-East", "US-West", "EU-Central", "Asia-Pac", "US-Central"]

    # Peering cost (ms equivalent)
    peering_cost = 15

    opt = PortalNetworkOptimizer(datacenters, portal_cost=peering_cost)
    opt.compute_mst()
    sp = opt.compute_shortest_paths()

    print(f"\nData centers:")
    for i, name in enumerate(dc_names):
        print(f"  [{i}] {name}")

    print(f"\nDirect internet latency matrix:")
    for i in range(len(datacenters)):
        row = [f"{opt.ow_dist_matrix[i][j]:>5}" for j in range(len(datacenters))]
        print(f"  {dc_names[i]:>12}: " + " ".join(row))

    print(f"\nOptimal overlay routing (via tropical closure):")
    for i in range(len(datacenters)):
        row = [f"{int(sp[i][j]):>5}" for j in range(len(datacenters))]
        print(f"  {dc_names[i]:>12}: " + " ".join(row))

    # Show improvement
    print(f"\nLatency improvement (direct vs overlay):")
    for i in range(len(datacenters)):
        for j in range(i+1, len(datacenters)):
            direct = opt.ow_dist_matrix[i][j]
            overlay = int(sp[i][j])
            if overlay < direct:
                pct = 100 * (direct - overlay) / direct
                print(f"  {dc_names[i]} → {dc_names[j]}: "
                      f"{direct} → {overlay} ({pct:.0f}% faster)")


# ============================================================
# Application 3: Multi-Modal Transit
# ============================================================
def transit_demo():
    """
    Urban transit model:
    - Walking/bus = Overworld (slow, ubiquitous)
    - Subway = Nether (fast, station access cost)

    Shows how the portal cost threshold determines which trips
    benefit from subway access.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Multi-Modal Urban Transit")
    print("=" * 60)

    # Locations in city blocks
    locations = [
        (0, 0),       # Downtown
        (40, 0),      # Business district
        (0, 48),      # University
        (40, 48),     # Hospital
        (80, 24),     # Airport
        (20, 24),     # Central park
    ]
    loc_names = ["Downtown", "Business", "University", "Hospital", "Airport", "Central Pk"]

    # Station access time = 5 minutes walking
    station_cost = 5

    print(f"Station access time: {station_cost} min each way")
    threshold = (16 * station_cost) / 7
    print(f"Subway worthwhile for trips > {threshold:.0f} blocks")

    print(f"\nTrip analysis:")
    print(f"{'From':>12} → {'To':<12} {'Walk':>5} {'Subway':>7} {'Best':>5} {'Mode':<8}")
    print("-" * 60)

    for i in range(len(locations)):
        for j in range(i+1, len(locations)):
            walk = l1_dist(locations[i], locations[j])
            subway = dual_world_cost(locations[i], locations[j], station_cost)
            mode = "Subway" if subway < walk else "Walk"
            best = min(walk, subway)
            print(f"{loc_names[i]:>12} → {loc_names[j]:<12} {walk:>5} {subway:>7} {best:>5} {mode:<8}")


# ============================================================
# Application 4: Phase Transition Analysis
# ============================================================
def phase_transition_demo():
    """
    Analyze how the portal cost parameter creates a phase transition
    in optimal network structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Portal Cost Phase Transition")
    print("=" * 60)

    settlements = [
        (0, 0), (100, 0), (0, 100), (100, 100),
        (50, 50), (150, 50), (50, 150), (200, 200),
    ]
    n = len(settlements)

    print(f"\n{'Portal Cost':>12} {'MST Cost':>10} {'Star Cost':>10} {'Savings %':>10} {'Threshold':>10}")
    print("-" * 55)

    for c in [0, 5, 10, 20, 50, 100, 200, 500]:
        opt = PortalNetworkOptimizer(settlements, portal_cost=c)
        opt.compute_mst()
        sr = opt.savings_report()
        thresh = opt.threshold_distance()
        print(f"{c:>12} {sr['mst_cost']:>10.0f} {sr['best_star_cost']:>10.0f} "
              f"{sr['savings_pct']:>9.1f}% {thresh:>10.0f}")


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    logistics_demo()
    cdn_demo()
    transit_demo()
    phase_transition_demo()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Concrete numerical demonstrations of the tropical scaling theorems
for dual-world portal network optimization.

Demonstrates:
1. Exact 1:8 scaling on the 8-lattice
2. Rounding error bounds for arbitrary coordinates
3. Portal cost threshold crossover
4. Tropical matrix multiplication for route optimization
5. MST vs star network cost comparison
"""

import itertools
import random

def l1_dist(p, q):
    """Manhattan (L1) distance between two 2D integer points."""
    return abs(p[0] - q[0]) + abs(p[1] - q[1])

def lift_over(p):
    """Lift Nether coordinates to Overworld (scale by 8)."""
    return (8 * p[0], 8 * p[1])

def nether_map(p):
    """Map Overworld coordinates to Nether (integer floor division by 8).
    Matches Lean 4's Int.div which uses Euclidean (floor) division."""
    return (p[0] // 8, p[1] // 8)

def div_by_8_point(p):
    """Check if a point lies on the 8-lattice."""
    return p[0] % 8 == 0 and p[1] % 8 == 0


# ============================================================
# Demo 1: Exact Scaling on the 8-Lattice
# ============================================================
print("=" * 60)
print("DEMO 1: Exact Tropical Scaling (Theorem 1)")
print("=" * 60)
print()
print("For points on the 8-lattice, Nether distance is exactly 1/8")
print("of Overworld distance.")
print()

lattice_points = [(8*x, 8*z) for x in range(-5, 6) for z in range(-5, 6)]
sample_pairs = random.sample(list(itertools.combinations(lattice_points, 2)), 10)

print(f"{'Overworld A':>15} {'Overworld B':>15} {'OW Dist':>8} {'Nether A':>12} {'Nether B':>12} {'N Dist':>7} {'8×N':>5} {'Match':>6}")
print("-" * 90)

all_match = True
for a, b in sample_pairs:
    ow_dist = l1_dist(a, b)
    na, nb = nether_map(a), nether_map(b)
    n_dist = l1_dist(na, nb)
    match = (n_dist * 8 == ow_dist)
    all_match = all_match and match
    print(f"{str(a):>15} {str(b):>15} {ow_dist:>8} {str(na):>12} {str(nb):>12} {n_dist:>7} {8*n_dist:>5} {'✓' if match else '✗':>6}")

print(f"\nAll pairs match exactly: {'YES ✓' if all_match else 'NO ✗'}")

# Lift form
print("\n--- Lift Form: L1(LiftOver(p), LiftOver(q)) = 8 × L1(p, q) ---")
nether_pts = [(x, z) for x in range(-5, 6) for z in range(-5, 6)]
sample_nether = random.sample(list(itertools.combinations(nether_pts, 2)), 8)

for p, q in sample_nether:
    lp, lq = lift_over(p), lift_over(q)
    d_nether = l1_dist(p, q)
    d_lifted = l1_dist(lp, lq)
    assert d_lifted == 8 * d_nether, f"Scaling failed for {p}, {q}"
    print(f"  Nether {p} → {q}: dist={d_nether}, Lifted dist={d_lifted}, 8×{d_nether}={8*d_nether} ✓")


# ============================================================
# Demo 2: Rounding Error Bounds
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Rounding Error Bounds (Theorem: ±14)")
print("=" * 60)
print()

max_err = -float('inf')
min_err = float('inf')
worst_upper = None
worst_lower = None

for x1 in range(-20, 21):
    for z1 in range(-20, 21):
        for x2 in range(-20, 21):
            for z2 in range(-20, 21):
                p, q = (x1, z1), (x2, z2)
                ow = l1_dist(p, q)
                nd = l1_dist(nether_map(p), nether_map(q))
                err = ow - 8 * nd
                if err > max_err:
                    max_err = err
                    worst_upper = (p, q)
                if err < min_err:
                    min_err = err
                    worst_lower = (p, q)

print(f"Searched all pairs with coordinates in [-20, 20]")
print(f"Maximum error (upper): {max_err}  (bound: ≤ 14)  {'✓' if max_err <= 14 else '✗'}")
print(f"  Worst case: {worst_upper}")
print(f"Minimum error (lower): {min_err}  (bound: ≥ -14) {'✓' if min_err >= -14 else '✗'}")
print(f"  Worst case: {worst_lower}")


# ============================================================
# Demo 3: Portal Cost Threshold
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Portal Cost Threshold")
print("=" * 60)
print()
print("With portal activation cost c each way, Nether travel (2c + d)")
print("beats Overworld travel (8d) when 16c < 7d.")
print()

for c in [10, 50, 100, 500]:
    threshold = (16 * c) / 7
    print(f"  Portal cost c = {c}:")
    print(f"    Threshold distance d > {threshold:.1f}")
    d = int(threshold) + 1
    nether_cost = 2 * c + d
    overworld_cost = 8 * d
    print(f"    At d = {d}: Nether = {nether_cost}, Overworld = {overworld_cost}, "
          f"Savings = {overworld_cost - nether_cost} ({100*(overworld_cost-nether_cost)/overworld_cost:.1f}%)")
    print()


# ============================================================
# Demo 4: Tropical Matrix Multiplication
# ============================================================
print("=" * 60)
print("DEMO 4: Tropical (Min-Plus) Matrix Multiplication")
print("=" * 60)
print()

# Example: 4 portal sites
sites = [(0, 0), (80, 0), (0, 80), (80, 80)]
n = len(sites)

print("Portal sites (Overworld):", sites)
print()

# Weight matrix: dual-world cost with c=10
c = 10
W = [[0]*n for _ in range(n)]
for i in range(n):
    for j in range(n):
        ow_cost = l1_dist(sites[i], sites[j])
        n_cost = 2*c + l1_dist(nether_map(sites[i]), nether_map(sites[j]))
        W[i][j] = min(ow_cost, n_cost) if i != j else 0

print("Dual-world cost matrix W (c=10):")
for row in W:
    print("  ", row)

# Tropical matrix square
def tropical_mul(A, B, n):
    C = [[0]*n for _ in range(n)]
    for i in range(n):
        for k in range(n):
            C[i][k] = min(A[i][j] + B[j][k] for j in range(n))
    return C

W2 = tropical_mul(W, W, n)
print("\nTropical square W² (optimal 2-step routes):")
for row in W2:
    print("  ", row)

# Tropical closure
W_closed = [row[:] for row in W]
for _ in range(n):
    W_new = tropical_mul(W_closed, W, n)
    W_closed = [[min(W_closed[i][j], W_new[i][j]) for j in range(n)] for i in range(n)]

print("\nTropical closure W* (all-pairs shortest paths):")
for row in W_closed:
    print("  ", row)

# Check fixpoint
W_check = tropical_mul(W_closed, W_closed, n)
is_fixpoint = all(W_closed[i][j] == min(W_closed[i][j], W_check[i][j])
                   for i in range(n) for j in range(n))
print(f"\nClosure is a fixpoint: {'YES ✓' if is_fixpoint else 'NO ✗'}")


# ============================================================
# Demo 5: MST vs Star Network
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: MST vs Star Network Cost")
print("=" * 60)
print()

# Prim's MST algorithm
def prim_mst(n, weight):
    """Return MST edges and total cost using Prim's algorithm."""
    in_tree = [False] * n
    in_tree[0] = True
    edges = []
    total = 0
    for _ in range(n - 1):
        best_edge = None
        best_cost = float('inf')
        for u in range(n):
            if not in_tree[u]:
                continue
            for v in range(n):
                if in_tree[v]:
                    continue
                if weight[u][v] < best_cost:
                    best_cost = weight[u][v]
                    best_edge = (u, v)
        if best_edge:
            edges.append(best_edge)
            total += best_cost
            in_tree[best_edge[1]] = True
    return edges, total

# 6 settlements
settlements = [(0, 0), (120, 0), (0, 120), (120, 120), (60, 60), (200, 80)]
n_s = len(settlements)

# Nether-compressed weights
nether_w = [[0]*n_s for _ in range(n_s)]
for i in range(n_s):
    for j in range(n_s):
        nether_w[i][j] = l1_dist(nether_map(settlements[i]), nether_map(settlements[j]))

print("Settlements:", settlements)
print("\nNether-compressed distance matrix:")
for row in nether_w:
    print("  ", row)

mst_edges, mst_cost = prim_mst(n_s, nether_w)
print(f"\nMST edges: {mst_edges}")
print(f"MST total cost: {mst_cost}")

# Star graph cost (hub at vertex 0)
star_cost = sum(nether_w[0][j] for j in range(1, n_s))
print(f"Star graph cost (hub=0): {star_cost}")

# Star graph cost (hub at vertex 4 = center)
star_cost_4 = sum(nether_w[4][j] for j in range(n_s) if j != 4)
print(f"Star graph cost (hub=4): {star_cost_4}")

print(f"\nMST saves {star_cost - mst_cost} over star(hub=0)")
print(f"MST saves {star_cost_4 - mst_cost} over star(hub=4)")

print(f"\n✓ MST cost ≤ all star costs: {mst_cost <= star_cost and mst_cost <= star_cost_4}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
visualizations.py — Generate charts for the tropical portal network paper.
Saves figures as PNG files and also produces base64-encoded versions.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io

from algorithms import (
    l1_dist, nether_map, lift_over, prim_mst,
    floyd_warshall_tropical, PortalNetworkOptimizer
)


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def plot_scaling_law():
    """Fig 1: Exact 1:8 scaling on the lattice."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Overworld grid
    pts_nether = [(x, z) for x in range(-3, 4) for z in range(-3, 4)]
    pts_ow = [lift_over(p) for p in pts_nether]

    ax1.scatter([p[0] for p in pts_ow], [p[1] for p in pts_ow],
               c='steelblue', s=30, zorder=3)
    # Highlight a pair
    a_ow, b_ow = lift_over((-2, 1)), lift_over((3, -1))
    ax1.plot([a_ow[0], b_ow[0]], [a_ow[1], b_ow[1]], 'r-', lw=2, zorder=2)
    ax1.scatter([a_ow[0], b_ow[0]], [a_ow[1], b_ow[1]], c='red', s=80, zorder=4)
    d_ow = l1_dist(a_ow, b_ow)
    ax1.set_title(f'Overworld (8ℤ lattice)\nL1 distance = {d_ow}', fontsize=13)
    ax1.set_xlabel('x')
    ax1.set_ylabel('z')
    ax1.grid(True, alpha=0.3)
    ax1.set_aspect('equal')

    # Right: Nether grid
    ax2.scatter([p[0] for p in pts_nether], [p[1] for p in pts_nether],
               c='darkorange', s=30, zorder=3)
    a_n, b_n = (-2, 1), (3, -1)
    ax2.plot([a_n[0], b_n[0]], [a_n[1], b_n[1]], 'r-', lw=2, zorder=2)
    ax2.scatter([a_n[0], b_n[0]], [a_n[1], b_n[1]], c='red', s=80, zorder=4)
    d_n = l1_dist(a_n, b_n)
    ax2.set_title(f'Nether (ℤ lattice)\nL1 distance = {d_n} = {d_ow}/8', fontsize=13)
    ax2.set_xlabel('x')
    ax2.set_ylabel('z')
    ax2.grid(True, alpha=0.3)
    ax2.set_aspect('equal')

    fig.suptitle('Theorem 1: Exact Tropical Scaling (factor 8)', fontsize=15, fontweight='bold')
    plt.tight_layout()
    fig.savefig('fig_scaling_law.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_rounding_error():
    """Fig 2: Rounding error distribution."""
    fig, ax = plt.subplots(figsize=(10, 5))

    errors = []
    coords = range(-30, 31)
    for x1 in coords:
        for x2 in coords:
            a, b = (x1, 0), (x2, 0)
            ow = l1_dist(a, b)
            nd = l1_dist(nether_map(a), nether_map(b))
            errors.append(ow - 8 * nd)

    ax.hist(errors, bins=range(min(errors)-1, max(errors)+2), color='teal',
            edgecolor='white', alpha=0.8)
    ax.axvline(x=-7, color='red', ls='--', lw=2, label='Per-coord bound: ±7')
    ax.axvline(x=7, color='red', ls='--', lw=2)
    ax.set_xlabel('Rounding Error: L1(p,q) − 8·L1(φ(p),φ(q))', fontsize=12)
    ax.set_ylabel('Count (1D pairs)', fontsize=12)
    ax.set_title('Rounding Error Distribution (single coordinate)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('fig_rounding_error.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_mst_network():
    """Fig 3: MST portal backbone vs star network."""
    settlements = [
        (0, 0), (120, 0), (0, 120), (120, 120), (60, 60), (200, 80)
    ]
    names = ["Base", "East", "North", "NE", "Center", "Far"]
    n = len(settlements)

    opt = PortalNetworkOptimizer(settlements, portal_cost=0)
    mst_edges, mst_cost = opt.compute_mst()

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: MST
    for u, v in mst_edges:
        ax1.plot([settlements[u][0], settlements[v][0]],
                [settlements[u][1], settlements[v][1]],
                'b-', lw=2.5, zorder=2)
    for i, (x, z) in enumerate(settlements):
        ax1.scatter(x, z, c='navy', s=120, zorder=3)
        ax1.annotate(names[i], (x, z), textcoords="offset points",
                    xytext=(8, 8), fontsize=10, fontweight='bold')
    ax1.set_title(f'MST Backbone (total cost: {mst_cost})', fontsize=13, fontweight='bold')
    ax1.set_xlabel('x (Overworld)')
    ax1.set_ylabel('z (Overworld)')
    ax1.grid(True, alpha=0.3)
    ax1.set_aspect('equal')

    # Right: Star (centered at best hub)
    hub = min(range(n), key=lambda h: opt.star_cost(h))
    star_cost = opt.star_cost(hub)
    for j in range(n):
        if j != hub:
            ax2.plot([settlements[hub][0], settlements[j][0]],
                    [settlements[hub][1], settlements[j][1]],
                    'r-', lw=2, alpha=0.7, zorder=2)
    for i, (x, z) in enumerate(settlements):
        c = 'red' if i == hub else 'darkred'
        s = 150 if i == hub else 100
        ax2.scatter(x, z, c=c, s=s, zorder=3)
        ax2.annotate(names[i], (x, z), textcoords="offset points",
                    xytext=(8, 8), fontsize=10, fontweight='bold')
    ax2.set_title(f'Star Network, hub={names[hub]} (total cost: {star_cost})',
                  fontsize=13, fontweight='bold')
    ax2.set_xlabel('x (Overworld)')
    ax2.set_ylabel('z (Overworld)')
    ax2.grid(True, alpha=0.3)
    ax2.set_aspect('equal')

    fig.suptitle('Theorem 3: MST Optimality for Portal Infrastructure', fontsize=15, fontweight='bold')
    plt.tight_layout()
    fig.savefig('fig_mst_network.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_phase_transition():
    """Fig 4: Phase transition in network structure as portal cost varies."""
    settlements = [
        (0, 0), (100, 0), (0, 100), (100, 100),
        (50, 50), (150, 50), (50, 150), (200, 200),
    ]

    costs = list(range(0, 201, 5))
    mst_costs = []
    star_costs = []
    savings_pcts = []

    for c in costs:
        opt = PortalNetworkOptimizer(settlements, portal_cost=c)
        opt.compute_mst()
        sr = opt.savings_report()
        mst_costs.append(sr['mst_cost'])
        star_costs.append(sr['best_star_cost'])
        savings_pcts.append(sr['savings_pct'])

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

    ax1.plot(costs, mst_costs, 'b-', lw=2, label='MST cost')
    ax1.plot(costs, star_costs, 'r--', lw=2, label='Best star cost')
    ax1.fill_between(costs, mst_costs, star_costs, alpha=0.15, color='green')
    ax1.set_xlabel('Portal Activation Cost (c)', fontsize=12)
    ax1.set_ylabel('Total Network Cost', fontsize=12)
    ax1.set_title('Network Cost vs Portal Activation Cost', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.plot(costs, savings_pcts, 'g-', lw=2)
    ax2.fill_between(costs, savings_pcts, alpha=0.2, color='green')
    ax2.set_xlabel('Portal Activation Cost (c)', fontsize=12)
    ax2.set_ylabel('MST Savings over Star (%)', fontsize=12)
    ax2.set_title('MST Advantage: Phase Behavior', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('fig_phase_transition.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


def plot_tropical_matrix():
    """Fig 5: Tropical matrix closure visualization."""
    sites = [(0, 0), (80, 0), (0, 80), (80, 80), (40, 40)]
    n = len(sites)

    # Build dual-world cost matrix
    c = 10
    W = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i != j:
                ow = l1_dist(sites[i], sites[j])
                nw = 2*c + l1_dist(nether_map(sites[i]), nether_map(sites[j]))
                W[i][j] = min(ow, nw)

    D = floyd_warshall_tropical([[float(x) for x in row] for row in W])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    labels = ['(0,0)', '(80,0)', '(0,80)', '(80,80)', '(40,40)']

    im1 = ax1.imshow([[W[i][j] for j in range(n)] for i in range(n)],
                     cmap='YlOrRd', aspect='equal')
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    ax1.set_xticklabels(labels, fontsize=8, rotation=45)
    ax1.set_yticklabels(labels, fontsize=8)
    for i in range(n):
        for j in range(n):
            ax1.text(j, i, str(W[i][j]), ha='center', va='center', fontsize=10)
    ax1.set_title('Edge Cost Matrix W', fontsize=13, fontweight='bold')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    im2 = ax2.imshow([[int(D[i][j]) for j in range(n)] for i in range(n)],
                     cmap='YlOrRd', aspect='equal')
    ax2.set_xticks(range(n))
    ax2.set_yticks(range(n))
    ax2.set_xticklabels(labels, fontsize=8, rotation=45)
    ax2.set_yticklabels(labels, fontsize=8)
    for i in range(n):
        for j in range(n):
            ax2.text(j, i, str(int(D[i][j])), ha='center', va='center', fontsize=10)
    ax2.set_title('Tropical Closure W* (shortest paths)', fontsize=13, fontweight='bold')
    plt.colorbar(im2, ax=ax2, shrink=0.8)

    fig.suptitle('Theorem 2: Tropical Matrix Closure = All-Pairs Shortest Paths',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('fig_tropical_matrix.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_scaling_law()
    print("  ✓ fig_scaling_law.png")
    b64_2 = plot_rounding_error()
    print("  ✓ fig_rounding_error.png")
    b64_3 = plot_mst_network()
    print("  ✓ fig_mst_network.png")
    b64_4 = plot_phase_transition()
    print("  ✓ fig_phase_transition.png")
    b64_5 = plot_tropical_matrix()
    print("  ✓ fig_tropical_matrix.png")
    print("\nAll visualizations generated.")

    # Return base64 data for JSON packaging
    viz_data = {
        "scaling_law": b64_1,
        "rounding_error": b64_2,
        "mst_network": b64_3,
        "phase_transition": b64_4,
        "tropical_matrix": b64_5,
    }
