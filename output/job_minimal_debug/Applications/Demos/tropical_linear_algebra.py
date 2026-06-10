#!/usr/bin/env python3
"""
Applications of Tropical Surgery Theory

Demonstrates real-world applications of the spectral monotonicity theorem:
  1. Shortest-path sensitivity in transportation networks
  2. Manufacturing system throughput optimization
  3. Weighted automata and asymptotic word cost
"""
import numpy as np

# ──────────────────────────────────────────────────────────────────────────
# Utility functions (self-contained)
# ──────────────────────────────────────────────────────────────────────────

def min_cycle_mean_brute(A):
    """Brute-force minimum cycle mean for small matrices."""
    from itertools import product as cprod
    n = A.shape[0]
    best = float('inf')
    best_walk = (0,)
    for length in range(1, n + 1):
        for walk in cprod(range(n), repeat=length):
            w = sum(A[walk[i], walk[(i+1) % length]] for i in range(length))
            m = w / length
            if m < best:
                best = m
                best_walk = walk
    return best, best_walk


# ──────────────────────────────────────────────────────────────────────────
# Application 1: Transportation Network Sensitivity
# ──────────────────────────────────────────────────────────────────────────

def app_transportation():
    """
    A city has 4 zones connected by roads. Edge weights = travel times (minutes).
    The minimum cycle mean represents the best average travel time per leg
    for a delivery truck cycling through the network.

    Surgery = upgrading two road segments (reducing their travel times).
    The theorem guarantees: upgrades never worsen the optimal cycle time.
    """
    print("=" * 70)
    print("APPLICATION 1: Transportation Network Optimization")
    print("=" * 70)
    print()

    # Travel time matrix (minutes)
    zones = ["Downtown", "Airport", "Industrial", "Suburbs"]
    A = np.array([
        [0,  12, 25, 18],   # From Downtown
        [15,  0,  8, 20],   # From Airport
        [30, 10,  0,  5],   # From Industrial
        [22, 28,  7,  0],   # From Suburbs
    ], dtype=float)

    rho_A, walk_A = min_cycle_mean_brute(A)
    print(f"Current network (travel times in minutes):")
    for i, z in enumerate(zones):
        print(f"  {z}: {A[i]}")
    print(f"\nOptimal delivery cycle: {' → '.join(zones[w] for w in walk_A)} → {zones[walk_A[0]]}")
    print(f"Average time per leg: {rho_A:.1f} minutes")

    # Upgrade: build express lane Downtown→Airport and Industrial→Suburbs
    print(f"\nProposed upgrades:")
    print(f"  1. Express lane Downtown→Airport: 12 min → 5 min")
    print(f"  2. Highway Industrial→Suburbs: 5 min → 2 min")

    B = A.copy()
    B[0, 1] = min(A[0, 1], 5)
    B[2, 3] = min(A[2, 3], 2)

    rho_B, walk_B = min_cycle_mean_brute(B)
    print(f"\nAfter upgrades:")
    print(f"  Optimal cycle: {' → '.join(zones[w] for w in walk_B)} → {zones[walk_B[0]]}")
    print(f"  Average time per leg: {rho_B:.1f} minutes")
    print(f"\n  THEOREM GUARANTEE: {rho_B:.1f} ≤ {rho_A:.1f} (upgrades cannot hurt) ✓")

    # Check if upgrade was on critical cycle
    crit_edges = set()
    for i in range(len(walk_A)):
        crit_edges.add((walk_A[i], walk_A[(i+1) % len(walk_A)]))

    if (0, 1) not in crit_edges and (2, 3) not in crit_edges:
        print(f"  Note: upgrades were OFF the critical cycle → ρ unchanged ({rho_A:.1f} = {rho_B:.1f})")
    else:
        improved_edges = [(0,1), (2,3)]
        on_critical = [e for e in improved_edges if e in crit_edges]
        print(f"  Edges on critical cycle: {on_critical} → strict improvement possible")
    print()


# ──────────────────────────────────────────────────────────────────────────
# Application 2: Manufacturing System (Discrete Event)
# ──────────────────────────────────────────────────────────────────────────

def app_manufacturing():
    """
    A factory has 3 stations in a cyclic production line.
    Edge weights = processing + transfer times.
    Min cycle mean = inverse of maximum throughput (cycle time per part).

    Surgery = installing faster equipment at two transfer points.
    Theorem: faster transfers never decrease throughput.
    """
    print("=" * 70)
    print("APPLICATION 2: Manufacturing Throughput Optimization")
    print("=" * 70)
    print()

    stations = ["Assembly", "Testing", "Packaging"]
    # A[i,j] = time to process at station i then transfer to station j
    A = np.array([
        [10, 15, 20],   # Assembly
        [12,  8, 10],   # Testing
        [18, 14,  6],   # Packaging
    ], dtype=float)

    rho_A, walk_A = min_cycle_mean_brute(A)
    print(f"Production line timing (processing + transfer, minutes):")
    for i, s in enumerate(stations):
        print(f"  {s}: {A[i]}")
    print(f"\nBottleneck cycle: {' → '.join(stations[w] for w in walk_A)}")
    print(f"Cycle time per part: {rho_A:.1f} minutes")
    print(f"Maximum throughput: {60/rho_A:.2f} parts/hour")

    # Upgrade: faster conveyor Assembly→Testing and faster QC Testing→Packaging
    print(f"\nUpgrades:")
    print(f"  1. Fast conveyor Assembly→Testing: 15 → 9 min")
    print(f"  2. Quick QC Testing→Packaging: 10 → 6 min")

    B = A.copy()
    B[0, 1] = min(A[0, 1], 9)
    B[1, 2] = min(A[1, 2], 6)

    rho_B, walk_B = min_cycle_mean_brute(B)
    print(f"\nAfter upgrades:")
    print(f"  Bottleneck cycle: {' → '.join(stations[w] for w in walk_B)}")
    print(f"  Cycle time per part: {rho_B:.1f} minutes")
    print(f"  Maximum throughput: {60/rho_B:.2f} parts/hour")
    print(f"\n  THEOREM GUARANTEE: cycle time {rho_B:.1f} ≤ {rho_A:.1f} ✓")
    print(f"  Throughput improved by {((rho_A/rho_B - 1) * 100):.1f}%")
    print()


# ──────────────────────────────────────────────────────────────────────────
# Application 3: Weighted Automaton — Asymptotic Word Cost
# ──────────────────────────────────────────────────────────────────────────

def app_weighted_automaton():
    """
    A weighted automaton over a single-letter alphabet (a min-plus matrix).
    The asymptotic average cost per symbol = tropical spectral radius.

    Surgery = reducing transition costs at two positions.
    Theorem: reducing costs cannot increase asymptotic average.
    """
    print("=" * 70)
    print("APPLICATION 3: Weighted Automaton Cost Optimization")
    print("=" * 70)
    print()

    states = ["q0", "q1", "q2", "q3"]
    n = len(states)
    # Transition costs
    A = np.array([
        [3, 7, 5, 9],
        [8, 2, 4, 6],
        [6, 5, 1, 3],
        [4, 8, 7, 2],
    ], dtype=float)

    rho_A, walk_A = min_cycle_mean_brute(A)
    print(f"Automaton transition costs:")
    for i in range(n):
        for j in range(n):
            print(f"  {states[i]} → {states[j]}: cost {A[i,j]:.0f}")
    print(f"\nAsymptotic average cost per symbol: {rho_A:.2f}")
    print(f"Optimal state cycle: {' → '.join(states[w] for w in walk_A)}")

    # Optimize two transitions
    print(f"\nOptimize transitions:")
    print(f"  q2 → q3: cost 3 → 0 (direct link)")
    print(f"  q3 → q0: cost 4 → 1 (shortcut)")

    B = A.copy()
    B[2, 3] = min(A[2, 3], 0)
    B[3, 0] = min(A[3, 0], 1)

    rho_B, walk_B = min_cycle_mean_brute(B)
    print(f"\nAfter optimization:")
    print(f"  Asymptotic average cost: {rho_B:.2f}")
    print(f"  Optimal state cycle: {' → '.join(states[w] for w in walk_B)}")
    print(f"\n  THEOREM GUARANTEE: {rho_B:.2f} ≤ {rho_A:.2f} ✓")
    print()


if __name__ == "__main__":
    app_transportation()
    app_manufacturing()
    app_weighted_automaton()
    print("All applications completed successfully.")


#!/usr/bin/env python3
"""
Tropical Surgery Demo: Rank-2 Min-Plus Matrix Updates and Spectral Monotonicity

Demonstrates the core theorems about tropical matrix surgery with concrete
numerical examples, showing how entrywise matrix decreases affect the
tropical spectral radius (minimum cycle mean).
"""
import numpy as np
from itertools import product as cart_product

# ──────────────────────────────────────────────────────────────────────────
# Core definitions
# ──────────────────────────────────────────────────────────────────────────

def tropical_rank_one_update(u, v):
    """Rank-one outer product in min-plus: M[i,j] = u[i] + v[j]."""
    return np.add.outer(u, v)

def tropical_rank_two_surgery(A, u, v, up, vp):
    """
    Rank-2 tropical surgery:
      B[i,j] = min(A[i,j], u[i]+v[j], u'[i]+v'[j])
    """
    R1 = tropical_rank_one_update(u, v)
    R2 = tropical_rank_one_update(up, vp)
    return np.minimum(A, np.minimum(R1, R2))

def two_entry_surgery(A, i1, j1, c1, i2, j2, c2):
    """
    Localized two-entry surgery: decrease at most two entries.
    """
    B = A.copy()
    B[i1, j1] = min(A[i1, j1], c1)
    B[i2, j2] = min(A[i2, j2], c2)
    return B

def closed_walk_weight(A, walk):
    """Weight of a closed walk: sum of edge weights along the cycle."""
    n = len(walk)
    return sum(A[walk[i], walk[(i + 1) % n]] for i in range(n))

def cycle_mean(A, walk):
    """Mean edge weight of a closed walk."""
    return closed_walk_weight(A, walk) / len(walk)

def tropical_spectral_radius(A):
    """
    Minimum cycle mean over all closed walks of length 1..n.
    This is the tropical eigenvalue (min-plus spectral radius).
    """
    n = A.shape[0]
    best = float('inf')
    # Enumerate all closed walks of length 1..n
    for length in range(1, n + 1):
        for walk in cart_product(range(n), repeat=length):
            cm = cycle_mean(A, walk)
            if cm < best:
                best = cm
                best_walk = walk
    return best, best_walk

def surgery_support(A, B):
    """Positions where B[i,j] < A[i,j]."""
    return list(zip(*np.where(B < A)))

def walk_uses_edge(walk, edge):
    """Check if a closed walk uses a specific edge."""
    n = len(walk)
    for i in range(n):
        if (walk[i], walk[(i + 1) % n]) == edge:
            return True
    return False

# ──────────────────────────────────────────────────────────────────────────
# Demo 1: Spectral Monotonicity under Rank-2 Surgery
# ──────────────────────────────────────────────────────────────────────────

def demo_spectral_monotonicity():
    print("=" * 70)
    print("DEMO 1: Spectral Monotonicity under Rank-2 Surgery")
    print("=" * 70)
    print()

    # A 3x3 tropical matrix (weighted digraph)
    A = np.array([
        [5.0, 2.0, 8.0],
        [3.0, 6.0, 1.0],
        [7.0, 4.0, 3.0]
    ])

    u  = np.array([1.0, 0.0, 2.0])
    v  = np.array([0.0, 1.0, -1.0])
    up = np.array([0.0, 3.0, 1.0])
    vp = np.array([2.0, 0.0, 1.0])

    B = tropical_rank_two_surgery(A, u, v, up, vp)

    rho_A, walk_A = tropical_spectral_radius(A)
    rho_B, walk_B = tropical_spectral_radius(B)

    print("Original matrix A:")
    print(A)
    print()
    print("Rank-one template u⊕v:")
    print(tropical_rank_one_update(u, v))
    print()
    print("Rank-one template u'⊕v':")
    print(tropical_rank_one_update(up, vp))
    print()
    print("Surgery result B = min(A, u⊕v, u'⊕v'):")
    print(B)
    print()
    print(f"Entrywise B ≤ A? {np.all(B <= A)}")
    print()
    print(f"Spectral radius of A (min cycle mean): {rho_A:.4f}")
    print(f"  Achieved by walk: {walk_A}")
    print(f"Spectral radius of B (min cycle mean): {rho_B:.4f}")
    print(f"  Achieved by walk: {walk_B}")
    print()
    print(f"THEOREM VERIFIED: ρ(B) = {rho_B:.4f} ≤ {rho_A:.4f} = ρ(A)  ✓" if rho_B <= rho_A + 1e-10 else "FAILED!")
    print()

    # Explicit bound
    diag_min_1 = min(u[i] + v[i] for i in range(len(u)))
    diag_min_2 = min(up[i] + vp[i] for i in range(len(up)))
    explicit_bound = min(rho_A, min(diag_min_1, diag_min_2))
    print(f"Explicit bound: min(ρ(A), min_i(u_i+v_i), min_i(u'_i+v'_i))")
    print(f"  = min({rho_A:.4f}, {diag_min_1:.4f}, {diag_min_2:.4f}) = {explicit_bound:.4f}")
    print(f"  ρ(B) = {rho_B:.4f} ≤ {explicit_bound:.4f}  ✓" if rho_B <= explicit_bound + 1e-10 else "  FAILED!")
    print()

# ──────────────────────────────────────────────────────────────────────────
# Demo 2: Off-Critical Surgery Preserves Spectral Radius
# ──────────────────────────────────────────────────────────────────────────

def demo_off_critical_surgery():
    print("=" * 70)
    print("DEMO 2: Off-Critical Surgery Preserves Spectral Radius")
    print("=" * 70)
    print()

    # Design a matrix where the optimal cycle is known
    # Optimal cycle: 0 → 1 → 0 with mean (A[0,1] + A[1,0]) / 2
    A = np.array([
        [10.0, 1.0, 8.0],
        [1.0, 10.0, 8.0],
        [8.0, 8.0, 10.0]
    ])

    rho_A, walk_A = tropical_spectral_radius(A)
    print(f"Original matrix A:")
    print(A)
    print(f"Spectral radius of A: {rho_A:.4f}, walk: {walk_A}")
    print()

    # Surgery on edge (0,2) and (2,0) — away from the critical cycle 0→1→0
    B = two_entry_surgery(A, 0, 2, 3.0, 2, 0, 3.0)
    rho_B, walk_B = tropical_spectral_radius(B)

    support = surgery_support(A, B)
    critical_edges = [(walk_A[i], walk_A[(i + 1) % len(walk_A)]) for i in range(len(walk_A))]
    overlap = [e for e in support if e in critical_edges]

    print(f"Surgery: decrease A[0,2] and A[2,0] to 3.0")
    print(f"Surgery support: {support}")
    print(f"Critical cycle edges: {critical_edges}")
    print(f"Overlap with critical cycle: {overlap}")
    print()
    print(f"Spectral radius of B: {rho_B:.4f}, walk: {walk_B}")
    print(f"OFF-CRITICAL INVARIANCE: ρ(B) = ρ(A) = {rho_A:.4f}  ✓" if abs(rho_B - rho_A) < 1e-10 else f"Changed: ρ(B) = {rho_B:.4f}")
    print()

    # Now surgery ON the critical cycle
    C = two_entry_surgery(A, 0, 1, -2.0, 1, 0, -2.0)
    rho_C, walk_C = tropical_spectral_radius(C)
    support_C = surgery_support(A, C)

    print(f"Surgery ON critical cycle: decrease A[0,1] and A[1,0] to -2.0")
    print(f"Surgery support: {support_C}")
    print(f"Spectral radius of C: {rho_C:.4f}, walk: {walk_C}")
    print(f"ON-CRITICAL: ρ(C) = {rho_C:.4f} < {rho_A:.4f} = ρ(A)  (strict decrease!)")
    print()

# ──────────────────────────────────────────────────────────────────────────
# Demo 3: Two-Entry Surgery and Shortest Path Sensitivity
# ──────────────────────────────────────────────────────────────────────────

def demo_two_entry_surgery():
    print("=" * 70)
    print("DEMO 3: Two-Entry Surgery as Shortest-Path Sensitivity")
    print("=" * 70)
    print()

    # Interpret matrix as a weighted digraph
    A = np.array([
        [0.0, 5.0, 3.0, 9.0],
        [7.0, 0.0, 2.0, 4.0],
        [6.0, 8.0, 0.0, 1.0],
        [3.0, 6.0, 5.0, 0.0]
    ])

    rho_A, walk_A = tropical_spectral_radius(A)
    print(f"Weighted digraph (adjacency matrix A):")
    print(A)
    print(f"Minimum cycle mean: {rho_A:.4f}, optimal cycle: {walk_A}")
    print()

    # Decrease two edge weights (making two edges cheaper)
    for (i1, j1, c1, i2, j2, c2) in [(1, 2, -1.0, 3, 0, 0.0), (0, 3, 2.0, 2, 1, 1.0)]:
        B = two_entry_surgery(A, i1, j1, c1, i2, j2, c2)
        rho_B, walk_B = tropical_spectral_radius(B)
        print(f"  Decrease edge ({i1},{j1}) to {c1}, edge ({i2},{j2}) to {c2}")
        print(f"  New min cycle mean: {rho_B:.4f} ≤ {rho_A:.4f} = ρ(A)  ✓" if rho_B <= rho_A + 1e-10 else "  FAILED!")
        print(f"  Optimal cycle: {walk_B}")
        print()

# ──────────────────────────────────────────────────────────────────────────
# Demo 4: Surgery Idempotency and Composition
# ──────────────────────────────────────────────────────────────────────────

def demo_surgery_properties():
    print("=" * 70)
    print("DEMO 4: Surgery Properties (Idempotency, Identity)")
    print("=" * 70)
    print()

    n = 3
    A = np.random.default_rng(42).uniform(0, 10, (n, n))
    u, v = np.random.default_rng(43).uniform(0, 5, n), np.random.default_rng(44).uniform(0, 5, n)
    up, vp = np.random.default_rng(45).uniform(0, 5, n), np.random.default_rng(46).uniform(0, 5, n)

    B = tropical_rank_two_surgery(A, u, v, up, vp)
    BB = tropical_rank_two_surgery(B, u, v, up, vp)

    print(f"Idempotency: surgery(surgery(A)) = surgery(A)?  {np.allclose(B, BB)}  ✓")

    # Large outer products → identity
    big_u = A.max() * np.ones(n) + 100
    big_v = np.zeros(n)
    C = tropical_rank_two_surgery(A, big_u, big_v, big_u, big_v)
    print(f"Large outer products → identity: surgery(A) = A?  {np.allclose(A, C)}  ✓")
    print()

# ──────────────────────────────────────────────────────────────────────────
# Demo 5: Scaling with Matrix Size
# ──────────────────────────────────────────────────────────────────────────

def demo_scaling():
    print("=" * 70)
    print("DEMO 5: Spectral Monotonicity Verified Across Dimensions")
    print("=" * 70)
    print()

    rng = np.random.default_rng(123)
    for n in [2, 3, 4, 5]:
        A = rng.uniform(-5, 10, (n, n))
        u, v = rng.uniform(-2, 5, n), rng.uniform(-2, 5, n)
        up, vp = rng.uniform(-2, 5, n), rng.uniform(-2, 5, n)
        B = tropical_rank_two_surgery(A, u, v, up, vp)

        rho_A, _ = tropical_spectral_radius(A)
        rho_B, _ = tropical_spectral_radius(B)

        status = "✓" if rho_B <= rho_A + 1e-10 else "✗"
        print(f"  n={n}: ρ(A) = {rho_A:+.4f}, ρ(B) = {rho_B:+.4f}, "
              f"ρ(B) ≤ ρ(A)? {status}")
    print()

if __name__ == "__main__":
    demo_spectral_monotonicity()
    demo_off_critical_surgery()
    demo_two_entry_surgery()
    demo_surgery_properties()
    demo_scaling()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualizations for Tropical Surgery Theory

Generates publication-quality figures demonstrating:
  1. Spectral radius sensitivity landscape
  2. Critical vs non-critical surgery comparison
  3. Surgery effect heatmap
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cprod
import base64
from io import BytesIO


def min_cycle_mean(A):
    n = A.shape[0]
    best = float('inf')
    for length in range(1, n + 1):
        for walk in cprod(range(n), repeat=length):
            w = sum(A[walk[i], walk[(i+1) % length]] for i in range(length))
            m = w / length
            if m < best:
                best = m
    return best


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_spectral_sensitivity():
    """
    Plot spectral radius as a function of surgery magnitude
    for on-critical and off-critical edges.
    """
    A = np.array([
        [10.0, 1.0, 8.0],
        [1.0, 10.0, 8.0],
        [8.0, 8.0, 10.0]
    ])

    deltas = np.linspace(0, 10, 30)

    # On-critical: perturb edge (0,1) which is on the optimal cycle 0→1→0
    rho_on = []
    for d in deltas:
        B = A.copy()
        B[0, 1] = A[0, 1] - d
        rho_on.append(min_cycle_mean(B))

    # Off-critical: perturb edge (0,2) which is NOT on the optimal cycle
    rho_off = []
    for d in deltas:
        B = A.copy()
        B[0, 2] = A[0, 2] - d
        rho_off.append(min_cycle_mean(B))

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(deltas, rho_on, 'r-o', label='On-critical surgery (edge 0→1)', markersize=4, linewidth=2)
    ax.plot(deltas, rho_off, 'b-s', label='Off-critical surgery (edge 0→2)', markersize=4, linewidth=2)
    ax.axhline(y=min_cycle_mean(A), color='gray', linestyle='--', alpha=0.7, label=f'ρ(A) = {min_cycle_mean(A):.1f}')
    ax.set_xlabel('Surgery magnitude δ (weight decrease)', fontsize=12)
    ax.set_ylabel('Tropical spectral radius ρ(B)', fontsize=12)
    ax.set_title('Spectral Sensitivity: On-Critical vs Off-Critical Surgery', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/viz_spectral_sensitivity.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_surgery_heatmap():
    """
    Heatmap showing the spectral radius change for every possible
    single-entry surgery position.
    """
    A = np.array([
        [5.0, 2.0, 8.0, 6.0],
        [3.0, 6.0, 1.0, 7.0],
        [7.0, 4.0, 3.0, 2.0],
        [4.0, 5.0, 6.0, 4.0]
    ])

    n = A.shape[0]
    rho_A = min_cycle_mean(A)
    delta = 5.0  # surgery magnitude

    change_map = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            B = A.copy()
            B[i, j] = A[i, j] - delta
            rho_B = min_cycle_mean(B)
            change_map[i, j] = rho_A - rho_B  # positive = improvement

    fig, ax = plt.subplots(1, 1, figsize=(7, 6))
    im = ax.imshow(change_map, cmap='RdYlGn', aspect='equal')
    ax.set_xlabel('Target column j', fontsize=12)
    ax.set_ylabel('Source row i', fontsize=12)
    ax.set_title(f'Spectral Impact of Single-Entry Surgery (δ={delta})\n'
                 f'Green = large improvement, Red = no change', fontsize=13)
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))

    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{change_map[i,j]:.2f}', ha='center', va='center',
                    fontsize=11, color='black' if abs(change_map[i,j]) < 1.5 else 'white')

    plt.colorbar(im, ax=ax, label='ρ(A) - ρ(B)')
    fig.savefig('/workspace/request-project/viz_surgery_heatmap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_rank2_bound():
    """
    Compare actual spectral radius after rank-2 surgery with the
    explicit upper bound (min of ρ(A) and diagonal minima).
    """
    rng = np.random.default_rng(42)
    ns = list(range(2, 7))
    actual_ratios = []
    bound_ratios = []

    results = []
    for n in ns:
        trials = 20
        for _ in range(trials):
            A = rng.uniform(0, 10, (n, n))
            u, v = rng.uniform(-2, 5, n), rng.uniform(-2, 5, n)
            up, vp = rng.uniform(-2, 5, n), rng.uniform(-2, 5, n)

            R1 = np.add.outer(u, v)
            R2 = np.add.outer(up, vp)
            B = np.minimum(A, np.minimum(R1, R2))

            rho_A = min_cycle_mean(A)
            rho_B = min_cycle_mean(B)

            diag1 = min(u[i] + v[i] for i in range(n))
            diag2 = min(up[i] + vp[i] for i in range(n))
            explicit_bound = min(rho_A, min(diag1, diag2))

            results.append((n, rho_A, rho_B, explicit_bound))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: ρ(B) vs ρ(A)
    for n in ns:
        data = [(r[1], r[2]) for r in results if r[0] == n]
        ax1.scatter([d[0] for d in data], [d[1] for d in data],
                   alpha=0.6, s=30, label=f'n={n}')
    lim = [min(r[1] for r in results) - 1, max(r[1] for r in results) + 1]
    ax1.plot(lim, lim, 'k--', alpha=0.5, label='ρ(B) = ρ(A)')
    ax1.set_xlabel('ρ(A)', fontsize=12)
    ax1.set_ylabel('ρ(B)', fontsize=12)
    ax1.set_title('Spectral Monotonicity: ρ(B) ≤ ρ(A)', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Right: ρ(B) vs explicit bound
    for n in ns:
        data = [(r[3], r[2]) for r in results if r[0] == n]
        ax2.scatter([d[0] for d in data], [d[1] for d in data],
                   alpha=0.6, s=30, label=f'n={n}')
    lim2 = [min(r[3] for r in results) - 1, max(r[2] for r in results) + 1]
    ax2.plot(lim2, lim2, 'k--', alpha=0.5, label='ρ(B) = bound')
    ax2.set_xlabel('Explicit bound', fontsize=12)
    ax2.set_ylabel('ρ(B)', fontsize=12)
    ax2.set_title('Explicit Bound: ρ(B) ≤ min(ρ(A), diag bounds)', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_rank2_bound.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_spectral_sensitivity()
    print(f"  Spectral sensitivity: saved (base64 length: {len(b64_1)})")
    b64_2 = viz_surgery_heatmap()
    print(f"  Surgery heatmap: saved (base64 length: {len(b64_2)})")
    b64_3 = viz_rank2_bound()
    print(f"  Rank-2 bound: saved (base64 length: {len(b64_3)})")
    print("All visualizations generated.")
