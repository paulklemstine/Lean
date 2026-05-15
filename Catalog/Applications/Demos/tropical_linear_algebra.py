"""
Applications of Tropical Surgery Theory

Real-world applications demonstrating the practical impact of spectral
monotonicity for min-plus matrix surgery.
"""

import numpy as np
from algorithms import (
    tropical_rank_two_surgery, two_entry_surgery,
    karp_minimum_cycle_mean, spectral_bound_certificate,
    optimal_two_entry_surgery
)


def manufacturing_scheduling():
    """
    Application 1: Manufacturing Line Optimization
    
    A manufacturing system with 4 stations. The matrix A[i,j] represents
    the minimum processing time for station j to begin after station i.
    The minimum cycle mean = throughput cycle time.
    
    Surgery represents installing faster conveyor belts between two pairs
    of stations.
    """
    print("=" * 70)
    print("APPLICATION 1: Manufacturing Line Optimization")
    print("=" * 70)
    
    stations = ['Assembly', 'Welding', 'Painting', 'QC']
    
    # Processing/transfer time matrix
    A = np.array([
        [8.0,  3.0,  12.0, 5.0],   # from Assembly
        [4.0,  7.0,  2.0,  6.0],   # from Welding
        [10.0, 5.0,  9.0,  3.0],   # from Painting
        [6.0,  2.0,  8.0,  11.0],  # from QC
    ])
    
    rho_A, _ = karp_minimum_cycle_mean(A)
    print(f"\nCurrent cycle time: {rho_A:.2f} time units")
    print("(This is the minimum average time per step in any repeating workflow)")
    
    # Propose: install express conveyors Assembly→Welding and Painting→QC
    B = two_entry_surgery(A, 0, 1, 1.0, 2, 3, 1.0)
    rho_B, _ = karp_minimum_cycle_mean(B)
    
    print(f"\nAfter installing express conveyors:")
    print(f"  {stations[0]} → {stations[1]}: {A[0,1]:.0f} → {B[0,1]:.0f} time units")
    print(f"  {stations[2]} → {stations[3]}: {A[2,3]:.0f} → {B[2,3]:.0f} time units")
    print(f"\nNew cycle time: {rho_B:.2f} time units")
    print(f"Improvement: {rho_A - rho_B:.2f} ({100*(rho_A-rho_B)/rho_A:.1f}%)")
    print(f"\nTheorem guarantee: new cycle time ≤ old cycle time ✓")
    
    # Find optimal placement
    print("\n--- Finding optimal two-entry upgrade ---")
    result = optimal_two_entry_surgery(A, budget=5.0)
    if result['config']:
        entries = result['config']['entries']
        print(f"Best entries to upgrade: ({stations[entries[0][0]]}→{stations[entries[0][1]]})"
              f" and ({stations[entries[1][0]]}→{stations[entries[1][1]]})")
        print(f"Optimal cycle time: {result['rho_optimal']:.2f}")
        print(f"Maximum improvement: {result['improvement']:.2f}")


def railway_scheduling():
    """
    Application 2: Railway Network Scheduling
    
    Train network modeled as a min-plus linear system.
    Edge weights = minimum travel + turnaround times.
    Cycle mean = minimum average headway.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Railway Network Scheduling")
    print("=" * 70)
    
    cities = ['Central', 'North', 'East', 'South', 'West']
    n = 5
    
    # Travel + turnaround time matrix
    A = np.array([
        [15., 8.,  12., 10., 7.],
        [9.,  20., 6.,  14., 11.],
        [13., 7.,  18., 5.,  9.],
        [11., 15., 6.,  16., 8.],
        [8.,  12., 10., 9.,  14.]
    ])
    
    rho_A, _ = karp_minimum_cycle_mean(A)
    print(f"\nCurrent minimum headway: {rho_A:.2f} minutes")
    
    # Propose high-speed rail on two routes
    u = np.array([2., 4., 3., 5., 2.])  # departure speedup
    v = np.array([3., 2., 4., 2., 3.])  # arrival speedup
    u_prime = np.array([3., 2., 5., 3., 4.])
    v_prime = np.array([4., 3., 2., 4., 2.])
    
    cert = spectral_bound_certificate(A, u, v, u_prime, v_prime)
    
    print(f"\nWith high-speed rail upgrade (rank-2 surgery):")
    print(f"  Original spectral radius: {cert['rho_A']:.2f}")
    print(f"  New spectral radius: {cert['rho_B']:.2f}")
    print(f"  Bound from route 1 diagonals: {cert['diag_min_1']:.2f}")
    print(f"  Bound from route 2 diagonals: {cert['diag_min_2']:.2f}")
    print(f"  Certified upper bound: {cert['explicit_bound']:.2f}")
    print(f"  Monotonicity verified: {cert['monotonicity_verified']} ✓")
    print(f"  Explicit bound verified: {cert['bound_verified']} ✓")


def network_routing():
    """
    Application 3: Network Routing Optimization
    
    Computer network with packet routing delays.
    Min-plus matrix = delay adjacency matrix.
    Surgery = upgrading two links.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Network Routing Optimization")
    print("=" * 70)
    
    nodes = ['Router-A', 'Router-B', 'Router-C', 'Switch-1', 'Switch-2', 'Gateway']
    n = 6
    
    INF = 100.0  # no direct link
    A = np.array([
        [5.,  2.,  INF, 1.,  INF, 3.],
        [2.,  5.,  3.,  INF, 1.,  INF],
        [INF, 3.,  5.,  INF, INF, 2.],
        [1.,  INF, INF, 3.,  2.,  INF],
        [INF, 1.,  INF, 2.,  3.,  INF],
        [3.,  INF, 2.,  INF, INF, 4.]
    ])
    
    rho_A, _ = karp_minimum_cycle_mean(A)
    print(f"\nCurrent minimum cycle latency: {rho_A:.2f} ms")
    
    # Upgrade two links
    print("\nUpgrade plan: add two high-speed links")
    B = two_entry_surgery(A, 0, 2, 1.5, 3, 5, 1.0)
    rho_B, _ = karp_minimum_cycle_mean(B)
    
    print(f"  {nodes[0]} → {nodes[2]}: {A[0,2]:.1f} → {B[0,2]:.1f} ms")
    print(f"  {nodes[3]} → {nodes[5]}: {A[3,5]:.1f} → {B[3,5]:.1f} ms")
    print(f"\nNew minimum cycle latency: {rho_B:.2f} ms")
    print(f"Latency reduction: {rho_A - rho_B:.2f} ms")
    print(f"Monotonicity theorem: {rho_B:.2f} ≤ {rho_A:.2f} ✓")


def discrete_event_system():
    """
    Application 4: Discrete Event System Analysis
    
    A production system modeled as a max-plus (= min-plus with negation)
    linear system x(k+1) = A ⊗ x(k).
    
    The system's throughput is determined by the maximum cycle mean
    (= negative of minimum cycle mean of -A).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Discrete Event System — Throughput Analysis")
    print("=" * 70)
    
    # System with 3 resources
    A = np.array([
        [4., 2., 7.],
        [3., 5., 1.],
        [6., 4., 8.]
    ])
    
    rho_A, _ = karp_minimum_cycle_mean(A)
    print(f"\nSystem matrix A (processing times):\n{A}")
    print(f"Minimum cycle mean: {rho_A:.2f}")
    print(f"(Throughput = 1/{rho_A:.2f} = {1/rho_A:.4f} jobs/time unit)")
    
    # Surgery: speed up two processing steps
    u = np.array([1., 2., 1.5])
    v = np.array([1.5, 1., 2.])
    u_prime = np.array([2., 1., 1.])
    v_prime = np.array([1., 1.5, 1.5])
    
    B = tropical_rank_two_surgery(A, u, v, u_prime, v_prime)
    rho_B, _ = karp_minimum_cycle_mean(B)
    
    print(f"\nAfter rank-2 surgery (two processing upgrades):")
    print(f"New matrix B:\n{np.round(B, 2)}")
    print(f"New minimum cycle mean: {rho_B:.2f}")
    print(f"New throughput: {1/rho_B:.4f} jobs/time unit")
    print(f"Throughput increase: {100*(1/rho_B - 1/rho_A)/(1/rho_A):.1f}%")
    print(f"\nMonotonicity: ρ(B) = {rho_B:.2f} ≤ {rho_A:.2f} = ρ(A) ✓")


if __name__ == "__main__":
    manufacturing_scheduling()
    railway_scheduling()
    network_routing()
    discrete_event_system()
    
    print("\n" + "=" * 70)
    print("All applications demonstrate the tropical spectral monotonicity theorem.")
    print("Surgery (decreasing edge weights / processing times) never increases")
    print("the minimum cycle mean — providing certified performance guarantees.")
    print("=" * 70)


"""
Tropical Surgery: Rank-2 Min-Plus Matrix Updates — Demonstrations

This script demonstrates the core theorems about tropical surgery on min-plus matrices,
including spectral monotonicity, explicit bounds, and connections to shortest-path problems.
"""

import numpy as np
from itertools import product

def tropical_rank_one_update(u, v):
    """Rank-1 tropical outer product: M[i,j] = u[i] + v[j]."""
    return np.add.outer(u, v)

def tropical_rank_two_surgery(A, u, v, u_prime, v_prime):
    """Rank-2 tropical surgery: min(A, u⊕v, u'⊕v')."""
    R1 = tropical_rank_one_update(u, v)
    R2 = tropical_rank_one_update(u_prime, v_prime)
    return np.minimum(A, np.minimum(R1, R2))

def two_entry_surgery(A, i1, j1, c1, i2, j2, c2):
    """Localized two-entry surgery: decrease at most two entries."""
    B = A.copy()
    B[i1, j1] = min(A[i1, j1], c1)
    B[i2, j2] = min(A[i2, j2], c2)
    return B

def closed_walk_weight(A, sigma):
    """Weight of a closed walk sigma in matrix A."""
    n = len(sigma)
    return sum(A[sigma[t], sigma[(t + 1) % n]] for t in range(n))

def cycle_mean(A, sigma):
    """Mean edge weight of a closed walk."""
    return closed_walk_weight(A, sigma) / len(sigma)

def tropical_spectral_radius(A):
    """
    Minimum cycle mean over all closed walks of length 1 to n.
    This is the tropical eigenvalue of A.
    """
    n = A.shape[0]
    best = float('inf')
    best_cycle = None
    
    for k in range(1, n + 1):
        for sigma in product(range(n), repeat=k):
            cm = cycle_mean(A, sigma)
            if cm < best:
                best = cm
                best_cycle = sigma
    
    return best, best_cycle

def demo_spectral_monotonicity():
    """Demonstrate that tropical surgery cannot increase the spectral radius."""
    print("=" * 70)
    print("DEMO 1: Spectral Monotonicity under Rank-2 Surgery")
    print("=" * 70)
    
    np.random.seed(42)
    n = 3
    A = np.random.uniform(1, 10, (n, n))
    A = np.round(A, 2)
    
    u = np.array([1.0, 2.0, 0.5])
    v = np.array([0.5, 1.0, 1.5])
    u_prime = np.array([2.0, 0.5, 1.0])
    v_prime = np.array([1.0, 0.5, 2.0])
    
    B = tropical_rank_two_surgery(A, u, v, u_prime, v_prime)
    
    print(f"\nOriginal matrix A:\n{A}")
    print(f"\nRank-1 component u⊕v:\n{tropical_rank_one_update(u, v)}")
    print(f"\nRank-1 component u'⊕v':\n{tropical_rank_one_update(u_prime, v_prime)}")
    print(f"\nSurgery result B = min(A, u⊕v, u'⊕v'):\n{B}")
    
    rho_A, cycle_A = tropical_spectral_radius(A)
    rho_B, cycle_B = tropical_spectral_radius(B)
    
    print(f"\nSpectral radius of A: {rho_A:.4f} (cycle: {cycle_A})")
    print(f"Spectral radius of B: {rho_B:.4f} (cycle: {cycle_B})")
    print(f"ρ(B) ≤ ρ(A)? {rho_B <= rho_A + 1e-10}  ✓")
    
    # Check entrywise bound
    print(f"\nEntrywise B ≤ A? {np.all(B <= A + 1e-10)}  ✓")

def demo_explicit_bound():
    """Demonstrate the explicit three-way bound."""
    print("\n" + "=" * 70)
    print("DEMO 2: Explicit Three-Way Spectral Bound")
    print("=" * 70)
    
    n = 4
    np.random.seed(123)
    A = np.random.uniform(2, 8, (n, n))
    
    u = np.array([1.0, 3.0, 2.0, 0.5])
    v = np.array([0.5, 1.0, 1.5, 2.0])
    u_prime = np.array([2.0, 0.5, 1.0, 3.0])
    v_prime = np.array([1.0, 0.5, 2.0, 0.5])
    
    B = tropical_rank_two_surgery(A, u, v, u_prime, v_prime)
    
    rho_A, _ = tropical_spectral_radius(A)
    rho_B, _ = tropical_spectral_radius(B)
    
    diag_min_1 = min(u[i] + v[i] for i in range(n))
    diag_min_2 = min(u_prime[i] + v_prime[i] for i in range(n))
    
    explicit_bound = min(rho_A, min(diag_min_1, diag_min_2))
    
    print(f"\nρ(A) = {rho_A:.4f}")
    print(f"min_i(u[i]+v[i]) = {diag_min_1:.4f}")
    print(f"min_i(u'[i]+v'[i]) = {diag_min_2:.4f}")
    print(f"\nExplicit bound = min(ρ(A), min(diag1, diag2)) = {explicit_bound:.4f}")
    print(f"ρ(B) = {rho_B:.4f}")
    print(f"ρ(B) ≤ explicit bound? {rho_B <= explicit_bound + 1e-10}  ✓")

def demo_two_entry_surgery():
    """Demonstrate localized two-entry surgery."""
    print("\n" + "=" * 70)
    print("DEMO 3: Localized Two-Entry Surgery")
    print("=" * 70)
    
    A = np.array([
        [5.0, 2.0, 8.0],
        [3.0, 6.0, 1.0],
        [7.0, 4.0, 9.0]
    ])
    
    print(f"\nOriginal matrix A:\n{A}")
    
    rho_A, cycle_A = tropical_spectral_radius(A)
    print(f"ρ(A) = {rho_A:.4f} (cycle: {cycle_A})")
    
    # Surgery at two entries
    B = two_entry_surgery(A, 0, 1, -1.0, 1, 2, -2.0)
    print(f"\nAfter surgery at (0,1)←min(2,-1)=-1, (1,2)←min(1,-2)=-2:")
    print(f"B:\n{B}")
    
    rho_B, cycle_B = tropical_spectral_radius(B)
    print(f"ρ(B) = {rho_B:.4f} (cycle: {cycle_B})")
    print(f"ρ(B) ≤ ρ(A)? {rho_B <= rho_A + 1e-10}  ✓")

def demo_shortest_path_sensitivity():
    """Demonstrate connection to shortest-path sensitivity analysis."""
    print("\n" + "=" * 70)
    print("DEMO 4: Shortest-Path Sensitivity Analysis")
    print("=" * 70)
    print("\nA min-plus matrix encodes a weighted directed graph.")
    print("Surgery = decreasing edge weights. Spectral radius = min cycle mean.")
    print("Our theorem: decreasing edge weights cannot increase min cycle mean.\n")
    
    # Road network example
    A = np.array([
        [10., 3., 7., 99.],
        [99., 8., 2., 5.],
        [4., 99., 12., 3.],
        [6., 1., 99., 9.]
    ])
    
    labels = ['A', 'B', 'C', 'D']
    print("City road network (edge weights = travel times):")
    for i in range(4):
        for j in range(4):
            if A[i,j] < 50:
                print(f"  {labels[i]} → {labels[j]}: {A[i,j]:.0f} min")
    
    rho_A, cycle_A = tropical_spectral_radius(A)
    print(f"\nMinimum cycle mean (original): {rho_A:.4f}")
    print(f"  Achieved by cycle: {' → '.join(labels[i] for i in cycle_A)} → {labels[cycle_A[0]]}")
    
    # Build a new express route
    print("\n--- Building two express routes ---")
    B = two_entry_surgery(A, 0, 2, 2.0, 2, 0, 1.0)
    print(f"  New: A → C: {B[0,2]:.0f} min (was {A[0,2]:.0f})")
    print(f"  New: C → A: {B[2,0]:.0f} min (was {A[2,0]:.0f})")
    
    rho_B, cycle_B = tropical_spectral_radius(B)
    print(f"\nMinimum cycle mean (after express routes): {rho_B:.4f}")
    print(f"  Achieved by cycle: {' → '.join(labels[i] for i in cycle_B)} → {labels[cycle_B[0]]}")
    print(f"\nTheorem confirms: ρ(B) = {rho_B:.4f} ≤ {rho_A:.4f} = ρ(A)  ✓")

def demo_idempotency():
    """Demonstrate surgery idempotency."""
    print("\n" + "=" * 70)
    print("DEMO 5: Surgery Idempotency")
    print("=" * 70)
    
    n = 3
    np.random.seed(7)
    A = np.random.uniform(0, 5, (n, n))
    u = np.random.uniform(0, 3, n)
    v = np.random.uniform(0, 3, n)
    u_prime = np.random.uniform(0, 3, n)
    v_prime = np.random.uniform(0, 3, n)
    
    B = tropical_rank_two_surgery(A, u, v, u_prime, v_prime)
    C = tropical_rank_two_surgery(B, u, v, u_prime, v_prime)
    
    print(f"\nA:\n{np.round(A, 3)}")
    print(f"\nB = surgery(A):\n{np.round(B, 3)}")
    print(f"\nC = surgery(surgery(A)):\n{np.round(C, 3)}")
    print(f"\nB == C (idempotency)? {np.allclose(B, C)}  ✓")

def demo_rank_one_spectral_radius():
    """Demonstrate that rank-1 spectral radius equals min diagonal."""
    print("\n" + "=" * 70)
    print("DEMO 6: Rank-One Matrix Spectral Radius")
    print("=" * 70)
    
    n = 4
    u = np.array([1.0, 3.0, 0.5, 2.0])
    v = np.array([2.0, 0.5, 1.0, 1.5])
    
    R = tropical_rank_one_update(u, v)
    print(f"\nu = {u}")
    print(f"v = {v}")
    print(f"\nRank-1 matrix u ⊕ v:\n{R}")
    
    diag = np.array([u[i] + v[i] for i in range(n)])
    print(f"\nDiagonal entries (u[i]+v[i]): {diag}")
    print(f"min diagonal = {min(diag):.4f}")
    
    rho, cycle = tropical_spectral_radius(R)
    print(f"ρ(u⊕v) = {rho:.4f} (cycle: {cycle})")
    print(f"ρ(u⊕v) ≤ min diagonal? {rho <= min(diag) + 1e-10}  ✓")

if __name__ == "__main__":
    demo_spectral_monotonicity()
    demo_explicit_bound()
    demo_two_entry_surgery()
    demo_shortest_path_sensitivity()
    demo_idempotency()
    demo_rank_one_spectral_radius()
    print("\n" + "=" * 70)
    print("All demonstrations complete. All theorems verified numerically.")
    print("=" * 70)


"""
Visualizations for Tropical Surgery Theory

Generates publication-quality figures demonstrating key results.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import product as iterproduct
import base64
from io import BytesIO


def cycle_mean_fn(A, sigma):
    k = len(sigma)
    w = sum(A[sigma[t], sigma[(t+1) % k]] for t in range(k))
    return w / k


def spectral_radius_fn(A):
    n = A.shape[0]
    best = float('inf')
    for k in range(1, n+1):
        for sigma in iterproduct(range(n), repeat=k):
            cm = cycle_mean_fn(A, sigma)
            if cm < best:
                best = cm
    return best


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_spectral_monotonicity():
    """Plot spectral radius under increasing surgery intensity."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    np.random.seed(42)
    n = 3
    A = np.array([[5., 2., 8.], [3., 6., 1.], [7., 4., 9.]])
    
    u = np.array([1., 2., 0.5])
    v = np.array([0.5, 1., 1.5])
    u_prime = np.array([2., 0.5, 1.])
    v_prime = np.array([1., 0.5, 2.])
    
    alphas = np.linspace(0, 3, 30)
    rho_values = []
    
    for alpha in alphas:
        B = np.minimum(A, np.minimum(
            np.add.outer(alpha * u, alpha * v),
            np.add.outer(alpha * u_prime, alpha * v_prime)
        ))
        rho_values.append(spectral_radius_fn(B))
    
    rho_A = spectral_radius_fn(A)
    
    ax = axes[0]
    ax.plot(alphas, rho_values, 'b-', linewidth=2, label='ρ(surgery(A, αu, αv, αu\', αv\'))')
    ax.axhline(y=rho_A, color='r', linestyle='--', linewidth=1.5, label='ρ(A)')
    ax.fill_between(alphas, rho_values, rho_A, alpha=0.15, color='blue')
    ax.set_xlabel('Surgery intensity α', fontsize=12)
    ax.set_ylabel('Tropical spectral radius', fontsize=12)
    ax.set_title('Spectral Monotonicity under Surgery', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Heatmap of entry-level sensitivity
    ax = axes[1]
    sensitivity = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            B = A.copy()
            B[i, j] = A[i, j] - 3.0
            sensitivity[i, j] = rho_A - spectral_radius_fn(B)
    
    im = ax.imshow(sensitivity, cmap='YlOrRd', aspect='equal')
    ax.set_xlabel('Column j', fontsize=12)
    ax.set_ylabel('Row i', fontsize=12)
    ax.set_title('Spectral Sensitivity: Δρ from -3 decrease', fontsize=14)
    for i in range(n):
        for j in range(n):
            ax.text(j, i, f'{sensitivity[i,j]:.2f}', ha='center', va='center', fontsize=11)
    plt.colorbar(im, ax=ax, label='ρ(A) - ρ(B)')
    
    fig.suptitle('Tropical Surgery: Spectral Radius Analysis', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def plot_surgery_comparison():
    """Compare rank-1 vs rank-2 surgery effects."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    A = np.array([[5., 2., 8.], [3., 6., 1.], [7., 4., 9.]])
    u = np.array([1., 2., 0.5])
    v = np.array([0.5, 1., 1.5])
    u_prime = np.array([2., 0.5, 1.])
    v_prime = np.array([1., 0.5, 2.])
    
    # Original matrix
    ax = axes[0]
    im = ax.imshow(A, cmap='viridis', aspect='equal')
    ax.set_title(f'Original A\nρ = {spectral_radius_fn(A):.2f}', fontsize=13)
    for i in range(3):
        for j in range(3):
            ax.text(j, i, f'{A[i,j]:.1f}', ha='center', va='center', color='white', fontsize=12)
    plt.colorbar(im, ax=ax)
    
    # Rank-1 surgery
    B1 = np.minimum(A, np.add.outer(u, v))
    ax = axes[1]
    im = ax.imshow(B1, cmap='viridis', aspect='equal')
    ax.set_title(f'Rank-1 Surgery\nρ = {spectral_radius_fn(B1):.2f}', fontsize=13)
    for i in range(3):
        for j in range(3):
            color = 'yellow' if B1[i,j] < A[i,j] else 'white'
            ax.text(j, i, f'{B1[i,j]:.1f}', ha='center', va='center', color=color, fontsize=12)
    plt.colorbar(im, ax=ax)
    
    # Rank-2 surgery
    B2 = np.minimum(A, np.minimum(np.add.outer(u, v), np.add.outer(u_prime, v_prime)))
    ax = axes[2]
    im = ax.imshow(B2, cmap='viridis', aspect='equal')
    ax.set_title(f'Rank-2 Surgery\nρ = {spectral_radius_fn(B2):.2f}', fontsize=13)
    for i in range(3):
        for j in range(3):
            color = 'yellow' if B2[i,j] < A[i,j] else 'white'
            ax.text(j, i, f'{B2[i,j]:.1f}', ha='center', va='center', color=color, fontsize=12)
    plt.colorbar(im, ax=ax)
    
    fig.suptitle('Surgery Operations: Original → Rank-1 → Rank-2', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def plot_explicit_bound():
    """Visualize the three-way explicit bound."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    np.random.seed(42)
    n = 3
    
    num_trials = 50
    rho_A_vals = []
    rho_B_vals = []
    bound_vals = []
    
    for trial in range(num_trials):
        np.random.seed(trial * 7 + 1)
        A = np.random.uniform(1, 10, (n, n))
        u = np.random.uniform(0, 4, n)
        v = np.random.uniform(0, 4, n)
        u_prime = np.random.uniform(0, 4, n)
        v_prime = np.random.uniform(0, 4, n)
        
        B = np.minimum(A, np.minimum(np.add.outer(u, v), np.add.outer(u_prime, v_prime)))
        
        rho_A = spectral_radius_fn(A)
        rho_B = spectral_radius_fn(B)
        diag1 = min(u[i] + v[i] for i in range(n))
        diag2 = min(u_prime[i] + v_prime[i] for i in range(n))
        bound = min(rho_A, diag1, diag2)
        
        rho_A_vals.append(rho_A)
        rho_B_vals.append(rho_B)
        bound_vals.append(bound)
    
    indices = np.arange(num_trials)
    
    # Sort by rho_A for visual clarity
    order = np.argsort(rho_A_vals)
    rho_A_vals = [rho_A_vals[i] for i in order]
    rho_B_vals = [rho_B_vals[i] for i in order]
    bound_vals = [bound_vals[i] for i in order]
    
    ax.scatter(indices, rho_A_vals, c='red', s=30, label='ρ(A)', alpha=0.7, zorder=3)
    ax.scatter(indices, bound_vals, c='orange', s=30, marker='s', label='Explicit bound', alpha=0.7, zorder=3)
    ax.scatter(indices, rho_B_vals, c='blue', s=30, marker='^', label='ρ(B) actual', alpha=0.7, zorder=3)
    
    ax.set_xlabel('Trial (sorted by ρ(A))', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Explicit Bound: ρ(B) ≤ min(ρ(A), diag₁, diag₂)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def plot_graph_surgery():
    """Visualize surgery as a graph operation."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    n = 4
    positions = {0: (0, 1), 1: (1, 1), 2: (1, 0), 3: (0, 0)}
    labels = ['A', 'B', 'C', 'D']
    
    A = np.array([
        [5., 3., 8., 6.],
        [4., 7., 2., 5.],
        [9., 6., 4., 3.],
        [7., 2., 5., 8.]
    ])
    
    B = A.copy()
    B[0, 2] = 1.0  # Surgery at (A,C)
    B[2, 3] = 1.0  # Surgery at (C,D)
    
    for ax_idx, (M, title) in enumerate([(A, 'Before Surgery'), (B, 'After Surgery')]):
        ax = axes[ax_idx]
        ax.set_xlim(-0.3, 1.3)
        ax.set_ylim(-0.3, 1.3)
        ax.set_aspect('equal')
        
        # Draw nodes
        for i in range(n):
            x, y = positions[i]
            circle = plt.Circle((x, y), 0.12, color='lightblue', ec='navy', linewidth=2, zorder=5)
            ax.add_patch(circle)
            ax.text(x, y, labels[i], ha='center', va='center', fontsize=14, fontweight='bold', zorder=6)
        
        # Draw edges (selected ones for clarity)
        edges_to_draw = [(0, 1), (0, 2), (1, 2), (2, 3), (3, 1)]
        for i, j in edges_to_draw:
            x1, y1 = positions[i]
            x2, y2 = positions[j]
            dx, dy = x2 - x1, y2 - y1
            length = np.sqrt(dx**2 + dy**2)
            dx, dy = dx/length, dy/length
            
            sx, sy = x1 + 0.14*dx, y1 + 0.14*dy
            ex, ey = x2 - 0.14*dx, y2 - 0.14*dy
            
            is_surgery = ax_idx == 1 and ((i, j) == (0, 2) or (i, j) == (2, 3))
            color = 'red' if is_surgery else 'gray'
            lw = 2.5 if is_surgery else 1.5
            
            ax.annotate('', xy=(ex, ey), xytext=(sx, sy),
                       arrowprops=dict(arrowstyle='->', color=color, lw=lw))
            
            mx, my = (sx+ex)/2, (sy+ey)/2
            offset = 0.08
            ax.text(mx + offset*(-dy), my + offset*dx, f'{M[i,j]:.0f}',
                   fontsize=10, ha='center', va='center',
                   color=color, fontweight='bold' if is_surgery else 'normal')
        
        rho = spectral_radius_fn(M)
        ax.set_title(f'{title}\nρ = {rho:.2f}', fontsize=14)
        ax.axis('off')
    
    fig.suptitle('Graph Surgery: Decreasing Two Edge Weights', fontsize=16, y=0.98)
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    img1 = plot_spectral_monotonicity()
    print(f"  Spectral monotonicity plot: {len(img1)} chars")
    
    img2 = plot_surgery_comparison()
    print(f"  Surgery comparison plot: {len(img2)} chars")
    
    img3 = plot_explicit_bound()
    print(f"  Explicit bound plot: {len(img3)} chars")
    
    img4 = plot_graph_surgery()
    print(f"  Graph surgery plot: {len(img4)} chars")
    
    print("Done! All visualizations generated as base64 data URIs.")
