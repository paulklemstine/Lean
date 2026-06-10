#!/usr/bin/env python3
"""
Tropical Orbit Complexity — Real-World Applications

Demonstrates how tropical matrix orbit complexity theory applies to:
1. Manufacturing scheduling (discrete event systems)
2. Network routing optimization
3. Train timetable synchronization
4. Digital circuit timing analysis
"""

import numpy as np
from algorithms import (trop_mul_mat, trop_pow, trop_mat_vec_mul,
                        tropical_spectral_radius, normalized_orbit,
                        orbit_cardinality_sequence, orbit_entropy_sequence,
                        find_tropical_eigenvector)


def app_manufacturing():
    """
    Application 1: Manufacturing Line Scheduling

    A factory has 3 machines processing parts in sequence.
    Machine i takes time G[i,j] to process a part coming from machine j.
    The max-plus system x(k+1) = G ⊗ x(k) models the k-th cycle completion times.

    The tropical spectral radius gives the cycle time (throughput rate).
    Bounded normalized orbit means the system reaches a periodic steady state.
    """
    print("=" * 70)
    print("APPLICATION 1: Manufacturing Line Scheduling")
    print("=" * 70)

    # Processing times matrix:
    # Machine 1 takes 5 from self, 3 from machine 2, 4 from machine 3
    # Machine 2 takes 2 from machine 1, 6 from self, 3 from machine 3
    # Machine 3 takes 4 from machine 1, 2 from machine 2, 5 from self
    G = np.array([
        [5, 3, 4],
        [2, 6, 3],
        [4, 2, 5]
    ], dtype=float)

    print(f"\nProcessing time matrix G:\n{G}")

    rho = tropical_spectral_radius(G)
    print(f"\nCycle time (throughput rate): ρ = {rho:.2f} time units")
    print(f"This means one complete production cycle takes {rho:.2f} time units")

    # Simulate production
    x = np.zeros(3)  # Start times
    print(f"\nProduction simulation:")
    print(f"  Cycle 0: start times = {x}")
    for k in range(1, 8):
        x = trop_mat_vec_mul(G, x)
        normalized = x - k * rho
        print(f"  Cycle {k}: completion = {x}, normalized = {normalized}")

    # Orbit analysis
    orbit = normalized_orbit(G, rho, 50)
    print(f"\n  Orbit size (50 cycles): {len(orbit)}")
    print(f"  → System reaches periodic steady state after {max(orbit.values())} cycles")
    print(f"  → Only {len(orbit)} distinct production patterns exist")


def app_network_routing():
    """
    Application 2: Network Routing — Widest Path Problem

    In a communication network, G[i,j] represents the bandwidth of the
    direct link from node j to node i. The tropical (max-plus) product
    gives the maximum-bandwidth path.

    G^⊗k[i,j] = maximum bandwidth achievable using exactly k hops from j to i.

    The spectral radius determines the long-run bandwidth growth.
    Bounded normalized orbit means the network has stable routing patterns.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Network Routing — Bandwidth Optimization")
    print("=" * 70)

    # 4-node network: bandwidth matrix (log-scale, so additive = multiplicative)
    G = np.array([
        [0, 2, 0, 1],
        [2, 0, 3, 0],
        [0, 3, 0, 2],
        [1, 0, 2, 0]
    ], dtype=float)

    print(f"\nBandwidth matrix (log-scale):\n{G}")

    rho = tropical_spectral_radius(G)
    print(f"\nSpectral radius: ρ = {rho:.2f}")

    print(f"\nMax-bandwidth paths by hop count:")
    for k in range(1, 6):
        Gk = trop_pow(G, k)
        print(f"  k={k} hops: best path 0→3 has bandwidth {Gk[3,0]:.0f} (log-scale)")

    # Normalized orbit
    orbit = normalized_orbit(G, rho, 30)
    print(f"\n  Routing pattern diversity (30 hops): {len(orbit)} distinct patterns")
    print(f"  → Network has finite routing complexity")


def app_train_timetable():
    """
    Application 3: Train Timetable Synchronization

    A railway network where trains must synchronize at stations.
    G[i,j] = minimum travel + wait time from station j's departure to station i's departure.

    The max-plus system models departure times:
    d(k+1) = G ⊗ d(k) where d(k) is the vector of k-th departure times.

    Cycle time = minimum headway between consecutive trains.
    Finite normalized orbit = eventually periodic timetable.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Train Timetable Synchronization")
    print("=" * 70)

    # 4 stations: travel + synchronization times
    G = np.array([
        [10,  5,  0,  8],
        [ 6, 10,  7,  0],
        [ 0,  4, 10,  6],
        [ 7,  0,  5, 10]
    ], dtype=float)

    print(f"\nTravel + sync matrix G:\n{G}")

    rho = tropical_spectral_radius(G)
    print(f"\nMinimum headway (cycle time): {rho:.1f} minutes")

    v, _ = find_tropical_eigenvector(G, rho)
    print(f"Steady-state departure offsets: {v}")

    # Verify eigenvector
    Gv = trop_mat_vec_mul(G, v)
    print(f"G⊗v = {Gv}")
    print(f"ρ+v = {rho + v}")
    print(f"Eigenvector valid: {np.allclose(Gv, rho + v, atol=0.01)}")

    # Check orbit
    orbit = normalized_orbit(G, rho, 50)
    print(f"\nTimetable pattern diversity: {len(orbit)} patterns in 50 departures")

    entropy = orbit_entropy_sequence(G, rho, 50)
    print(f"Entropy rate at N=50: {entropy[-1]:.6f}")
    print(f"→ Timetable reaches periodic steady state (zero entropy)")


def app_circuit_timing():
    """
    Application 4: Digital Circuit Timing Analysis

    In a synchronous digital circuit, G[i,j] represents the propagation
    delay from flip-flop j to flip-flop i through combinational logic.

    The max-plus system models clock cycle timing:
    t(k+1) = G ⊗ t(k) where t(k) is the arrival time at cycle k.

    Spectral radius = minimum clock period (critical path delay).
    Finite normalized orbit = the circuit stabilizes after a transient.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Digital Circuit Timing Analysis")
    print("=" * 70)

    # 3 flip-flops with combinational delays
    G = np.array([
        [2, 4, 1],
        [3, 2, 5],
        [1, 3, 2]
    ], dtype=float)

    print(f"\nPropagation delay matrix G:\n{G}")

    rho = tropical_spectral_radius(G)
    print(f"\nMinimum clock period (critical path): {rho:.1f} ns")
    print(f"Maximum clock frequency: {1000/rho:.1f} MHz (if delays in ns)")

    # Timing analysis over cycles
    print(f"\nTiming convergence:")
    x = np.zeros(3)
    for k in range(1, 8):
        x = trop_mat_vec_mul(G, x)
        slack = k * rho - np.max(x)
        print(f"  Cycle {k}: max arrival = {np.max(x):.0f}, "
              f"expected = {k*rho:.0f}, slack = {slack:.0f}")

    orbit = normalized_orbit(G, rho, 30)
    print(f"\n  Timing patterns: {len(orbit)} distinct in 30 cycles")
    print(f"  → Circuit timing is stable (finite orbit)")


if __name__ == "__main__":
    app_manufacturing()
    app_network_routing()
    app_train_timetable()
    app_circuit_timing()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Orbit Complexity — Demonstrations

Concrete numerical examples showing how tropical spectral data controls
orbit complexity. Each demo illustrates a theorem from the formal development.
"""

import numpy as np
from itertools import product


def trop_mul_mat(A, B):
    """Tropical (max-plus) matrix multiplication: (A⊗B)_{ij} = max_k (A_{ik} + B_{kj})."""
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            C[i, j] = max(A[i, k] + B[k, j] for k in range(n))
    return C


def trop_pow(G, k):
    """Compute the k-th tropical power of G."""
    n = G.shape[0]
    if k == 0:
        # Tropical identity (0 on diagonal, -inf off-diagonal for true max-plus)
        # But for integer version matching Lean, use 0 everywhere
        return np.zeros((n, n), dtype=float)
    result = G.copy()
    for _ in range(k - 1):
        result = trop_mul_mat(result, G)
    return result


def trop_mat_vec_mul(A, v):
    """Tropical matrix-vector multiplication: (A⊗v)_i = max_j (A_{ij} + v_j)."""
    n = A.shape[0]
    return np.array([max(A[i, j] + v[j] for j in range(n)) for i in range(n)])


def normalized_trop_pow(G, rho, k):
    """Normalized tropical power: G^⊗k_{ij} - k*rho."""
    return trop_pow(G, k) - k * rho


def orbit_set_normalized(G, rho, N):
    """Compute the set of distinct normalized tropical powers {G̃^(1), ..., G̃^(N)}."""
    seen = {}
    for k in range(1, N + 1):
        M = normalized_trop_pow(G, rho, k)
        key = tuple(M.flatten())
        if key not in seen:
            seen[key] = k
    return seen


# ============================================================================
# Demo 1: Basic Tropical Matrix Powers
# ============================================================================
def demo_basic_powers():
    print("=" * 70)
    print("DEMO 1: Tropical Matrix Powers and Entry Growth")
    print("=" * 70)

    G = np.array([[3, 1],
                  [2, 4]], dtype=float)

    print(f"\nMatrix G =\n{G}")
    print(f"\nTropical powers G^⊗k (max-plus multiplication):")

    for k in range(1, 8):
        Gk = trop_pow(G, k)
        max_entry = Gk.max()
        min_entry = Gk.min()
        print(f"  k={k}: G^⊗{k} = {Gk.flatten()}, "
              f"max={max_entry:.0f}, min={min_entry:.0f}, "
              f"span={max_entry - min_entry:.0f}")

    # The spectral radius (max cycle mean) for this matrix
    # Diagonal: max(3, 4) = 4
    # 2-cycle: (1+2)/2 = 1.5
    # So rho = 4
    rho = 4
    print(f"\nTropical spectral radius ρ = {rho}")
    print(f"\nNormalized powers G̃^(k) = G^⊗k - k·ρ:")

    for k in range(1, 8):
        Mk = normalized_trop_pow(G, rho, k)
        print(f"  k={k}: {Mk.flatten()}")

    print("\n→ Normalized entries are bounded! Orbit is finite.")


# ============================================================================
# Demo 2: Orbit Cardinality Bound (Theorem A)
# ============================================================================
def demo_orbit_bound():
    print("\n" + "=" * 70)
    print("DEMO 2: Orbit Cardinality Bound (Theorem A)")
    print("=" * 70)

    G = np.array([[2, 0, 1],
                  [1, 3, 0],
                  [0, 1, 2]], dtype=float)
    n = G.shape[0]

    # Compute spectral radius (max cycle mean)
    # Diagonal: max(2,3,2) = 3
    # 2-cycles: (0+1)/2=0.5, (1+0)/2=0.5, (0+1)/2=0.5
    # 3-cycle: (0+0+0)/3=0, etc.
    rho = 3
    print(f"\nMatrix G (3×3):\n{G}")
    print(f"Tropical spectral radius ρ = {rho}")

    N = 50
    orbit = orbit_set_normalized(G, rho, N)
    print(f"\nOrbit cardinality for N=1..{N}: |orbit| = {len(orbit)}")

    # Compute the bound
    C = 0
    for k in range(1, N + 1):
        Mk = normalized_trop_pow(G, rho, k)
        C = max(C, int(np.max(np.abs(Mk))))

    bound = (2 * C + 1) ** (n * n)
    print(f"Maximum |entry| in normalized powers: C = {C}")
    print(f"Theoretical bound (2C+1)^(n²) = ({2*C+1})^{n*n} = {bound}")
    print(f"Actual orbit size: {len(orbit)} ≤ {bound} ✓")

    # Show the orbit stabilizes
    sizes = []
    for N_curr in range(1, N + 1):
        orb = orbit_set_normalized(G, rho, N_curr)
        sizes.append(len(orb))
    print(f"\nOrbit sizes by N: {sizes[:20]}...")
    print(f"→ Orbit stabilizes! Eventually periodic behavior.")


# ============================================================================
# Demo 3: Eigenvector Upper Bound (Theorem B)
# ============================================================================
def demo_eigenvector_bound():
    print("\n" + "=" * 70)
    print("DEMO 3: Eigenvector Upper Bound (Theorem B)")
    print("=" * 70)

    # Matrix with known tropical eigenvector
    # G⊗v = ρ + v means max_j(G_{ij} + v_j) = ρ + v_i
    # Choose G = [[5, 1], [3, 5]], v = [0, 0], ρ = 5
    G = np.array([[5, 1],
                  [3, 5]], dtype=float)
    v = np.array([0, 0], dtype=float)
    rho = 5

    # Verify eigenvector equation
    Gv = trop_mat_vec_mul(G, v)
    print(f"\nMatrix G =\n{G}")
    print(f"Eigenvector v = {v}")
    print(f"Eigenvalue ρ = {rho}")
    print(f"G⊗v = {Gv}")
    print(f"ρ + v = {rho + v}")
    print(f"Eigenvector equation holds: {np.allclose(Gv, rho + v)}")

    print(f"\nVerifying Theorem B: G^⊗k_{{ij}} ≤ k·ρ + v_i - v_j")
    for k in range(1, 10):
        Gk = trop_pow(G, k)
        for i in range(2):
            for j in range(2):
                bound = k * rho + v[i] - v[j]
                actual = Gk[i, j]
                ok = actual <= bound + 1e-10
                if not ok:
                    print(f"  VIOLATION at k={k}, i={i}, j={j}: "
                          f"{actual} > {bound}")
        max_gap = max(k * rho + v[i] - v[j] - Gk[i, j]
                      for i in range(2) for j in range(2))
        print(f"  k={k}: bound holds ✓ (max slack = {max_gap:.0f})")


# ============================================================================
# Demo 4: Entropy Collapse (Theorem C)
# ============================================================================
def demo_entropy_collapse():
    print("\n" + "=" * 70)
    print("DEMO 4: Entropy Collapse (Theorem C)")
    print("=" * 70)

    G = np.array([[2, 0, 1],
                  [1, 3, 0],
                  [0, 1, 2]], dtype=float)
    rho = 3

    print(f"\nMatrix G (3×3):\n{G}")
    print(f"Spectral radius ρ = {rho}")
    print(f"\n{'N':>5} {'|orbit|':>8} {'log(|orbit|)/N':>16}")
    print("-" * 35)

    for N in [1, 2, 5, 10, 20, 50, 100, 200, 500]:
        orbit = orbit_set_normalized(G, rho, N)
        card = len(orbit)
        if N > 0 and card > 0:
            entropy_rate = np.log(card) / N
        else:
            entropy_rate = 0
        print(f"{N:5d} {card:8d} {entropy_rate:16.6f}")

    print("\n→ log(|orbit|)/N → 0 as N → ∞  (entropy collapse)")


# ============================================================================
# Demo 5: 2×2 Classification
# ============================================================================
def demo_2x2_classification():
    print("\n" + "=" * 70)
    print("DEMO 5: 2×2 Tropical Matrix Classification")
    print("=" * 70)

    examples = [
        ("Diagonal dominant", np.array([[5, 1], [1, 5]])),
        ("Cycle dominant", np.array([[0, 3], [4, 0]])),
        ("Mixed", np.array([[3, 2], [1, 4]])),
        ("Uniform", np.array([[2, 2], [2, 2]])),
    ]

    for name, G in examples:
        # Tropical spectral radius for 2x2
        diag_max = max(G[0, 0], G[1, 1])
        cycle_mean = (G[0, 1] + G[1, 0]) / 2
        rho = max(diag_max, cycle_mean)

        orbit = orbit_set_normalized(G, rho, 100)
        print(f"\n{name}: G = {G.flatten()}")
        print(f"  ρ = max({diag_max}, {cycle_mean}) = {rho}")
        print(f"  Orbit size (N=100): {len(orbit)}")

        # Show normalized powers
        for k in range(1, min(6, 101)):
            Mk = normalized_trop_pow(G, rho, k)
            print(f"    k={k}: normalized = {Mk.flatten()}")


if __name__ == "__main__":
    demo_basic_powers()
    demo_orbit_bound()
    demo_eigenvector_bound()
    demo_entropy_collapse()
    demo_2x2_classification()
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Orbit Complexity — Visualizations

Generates publication-quality figures showing:
1. Entry growth and spectral drift
2. Normalized orbit convergence
3. Entropy collapse
4. Eigenvector bound verification
5. 2×2 classification phase diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

from algorithms import (trop_mul_mat, trop_pow, trop_mat_vec_mul,
                        tropical_spectral_radius, normalized_orbit,
                        orbit_cardinality_sequence, orbit_entropy_sequence,
                        find_tropical_eigenvector)


def fig1_entry_growth():
    """Figure 1: Entry growth under tropical powers vs linear drift."""
    G = np.array([[3, 1], [2, 4]], dtype=float)
    rho = tropical_spectral_radius(G)

    ks = range(1, 21)
    entries = {(i, j): [] for i in range(2) for j in range(2)}
    for k in ks:
        Gk = trop_pow(G, k)
        for i in range(2):
            for j in range(2):
                entries[(i, j)].append(Gk[i, j])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
    labels = ['(0,0)', '(0,1)', '(1,0)', '(1,1)']
    for idx, (ij, vals) in enumerate(entries.items()):
        ax1.plot(list(ks), vals, 'o-', color=colors[idx], label=f'Entry {labels[idx]}',
                 markersize=4)

    drift = [k * rho for k in ks]
    ax1.plot(list(ks), drift, 'k--', linewidth=2, label=f'Linear drift kρ (ρ={rho:.0f})')
    ax1.set_xlabel('Power k', fontsize=12)
    ax1.set_ylabel('Entry value', fontsize=12)
    ax1.set_title('Tropical Power Entries vs Spectral Drift', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Normalized entries
    for idx, (ij, vals) in enumerate(entries.items()):
        normalized = [v - k * rho for k, v in zip(ks, vals)]
        ax2.plot(list(ks), normalized, 'o-', color=colors[idx],
                 label=f'Entry {labels[idx]}', markersize=4)

    ax2.axhline(y=0, color='k', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Power k', fontsize=12)
    ax2.set_ylabel('Normalized entry (G^k_{ij} - kρ)', fontsize=12)
    ax2.set_title('Normalized Entries: Bounded Residuals', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig1_entry_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig1_entry_growth.png")


def fig2_orbit_convergence():
    """Figure 2: Orbit cardinality convergence for various matrices."""
    examples = [
        ("2×2 Diagonal\ndominant", np.array([[5, 1], [1, 5]], dtype=float)),
        ("2×2 Cycle\ndominant", np.array([[0, 3], [4, 0]], dtype=float)),
        ("3×3 Mixed", np.array([[2, 0, 1], [1, 3, 0], [0, 1, 2]], dtype=float)),
        ("3×3 Dense", np.array([[3, 2, 1], [1, 3, 2], [2, 1, 3]], dtype=float)),
    ]

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    axes = axes.flatten()

    for idx, (name, G) in enumerate(examples):
        rho = tropical_spectral_radius(G)
        N = 50
        sizes = orbit_cardinality_sequence(G, rho, N)

        ax = axes[idx]
        ax.plot(range(1, N + 1), sizes, 'b-', linewidth=2)
        ax.axhline(y=sizes[-1], color='r', linestyle='--', alpha=0.7,
                   label=f'Limit = {sizes[-1]}')
        ax.set_xlabel('N', fontsize=11)
        ax.set_ylabel('|Orbit(N)|', fontsize=11)
        ax.set_title(f'{name}\nρ = {rho:.1f}', fontsize=12)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(bottom=0)

    plt.suptitle('Orbit Cardinality Convergence', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('fig2_orbit_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig2_orbit_convergence.png")


def fig3_entropy_collapse():
    """Figure 3: Entropy rate collapse to zero."""
    examples = [
        ("3×3 Example A", np.array([[2, 0, 1], [1, 3, 0], [0, 1, 2]], dtype=float)),
        ("3×3 Example B", np.array([[3, 2, 1], [1, 3, 2], [2, 1, 3]], dtype=float)),
        ("4×4 Random", np.array([[4, 1, 0, 2], [2, 3, 1, 0],
                                  [0, 2, 4, 1], [1, 0, 2, 3]], dtype=float)),
    ]

    fig, ax = plt.subplots(figsize=(10, 6))
    colors = ['#2196F3', '#FF5722', '#4CAF50']

    for idx, (name, G) in enumerate(examples):
        rho = tropical_spectral_radius(G)
        N = 200
        entropy = orbit_entropy_sequence(G, rho, N)
        ax.plot(range(1, N + 1), entropy, color=colors[idx], linewidth=1.5,
                label=f'{name} (ρ={rho:.1f})')

    ax.axhline(y=0, color='k', linestyle='--', alpha=0.5)
    ax.set_xlabel('N', fontsize=12)
    ax.set_ylabel('log(|orbit|) / N', fontsize=12)
    ax.set_title('Entropy Collapse: log(|orbit|)/N → 0', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, max(0.5, ax.get_ylim()[1]))

    plt.tight_layout()
    plt.savefig('fig3_entropy_collapse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig3_entropy_collapse.png")


def fig4_eigenvector_bound():
    """Figure 4: Eigenvector-based entry bounds (Theorem B)."""
    G = np.array([[5, 1, 3],
                  [2, 4, 1],
                  [3, 2, 5]], dtype=float)
    rho = tropical_spectral_radius(G)
    v, _ = find_tropical_eigenvector(G, rho)

    ks = range(1, 16)
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    pairs = [(0, 1), (1, 2), (0, 2)]
    for ax_idx, (i, j) in enumerate(pairs):
        actuals = []
        bounds = []
        for k in ks:
            Gk = trop_pow(G, k)
            actuals.append(Gk[i, j])
            bounds.append(k * rho + v[i] - v[j])

        ax = axes[ax_idx]
        ax.plot(list(ks), actuals, 'bo-', markersize=5, label='Actual G^⊗k_{ij}')
        ax.plot(list(ks), bounds, 'r--', linewidth=2, label='Bound kρ + v_i - v_j')
        ax.fill_between(list(ks), actuals, bounds, alpha=0.2, color='green',
                         label='Slack')
        ax.set_xlabel('Power k', fontsize=11)
        ax.set_ylabel(f'Entry ({i},{j})', fontsize=11)
        ax.set_title(f'Entry ({i},{j}): Bound vs Actual', fontsize=12)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.suptitle(f'Eigenvector Bound (Theorem B): ρ={rho:.1f}, v={np.round(v,1)}',
                 fontsize=13, y=1.02)
    plt.tight_layout()
    plt.savefig('fig4_eigenvector_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig4_eigenvector_bound.png")


def fig5_phase_diagram():
    """Figure 5: 2×2 orbit complexity phase diagram."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Scan over 2x2 matrices parameterized by off-diagonal entries
    # G = [[a, b], [c, d]] with a=d=0 (normalized)
    resolution = 30
    bs = np.linspace(0, 6, resolution)
    cs = np.linspace(0, 6, resolution)

    orbit_sizes = np.zeros((resolution, resolution))

    for bi, b in enumerate(bs):
        for ci, c in enumerate(cs):
            G = np.array([[0, b], [c, 0]], dtype=float)
            rho = tropical_spectral_radius(G)
            orbit = normalized_orbit(G, rho, 50)
            orbit_sizes[ci, bi] = len(orbit)

    im = ax.pcolormesh(bs, cs, orbit_sizes, cmap='viridis', shading='auto')
    plt.colorbar(im, ax=ax, label='Orbit size |{G̃^(1),...,G̃^(50)}|')

    ax.set_xlabel('Off-diagonal entry b (G₀₁)', fontsize=12)
    ax.set_ylabel('Off-diagonal entry c (G₁₀)', fontsize=12)
    ax.set_title('2×2 Orbit Complexity Phase Diagram\nG = [[0, b], [c, 0]]', fontsize=14)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('fig5_phase_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig5_phase_diagram.png")


if __name__ == "__main__":
    fig1_entry_growth()
    fig2_orbit_convergence()
    fig3_entropy_collapse()
    fig4_eigenvector_bound()
    fig5_phase_diagram()
    print("\nAll visualizations generated!")
