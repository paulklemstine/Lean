#!/usr/bin/env python3
"""
Applications of Spectral Exchange Graph Theory

Shows real-world applications of the depth-conductance-spectral chain:
1. Combinatorial optimization (TSP local search)
2. Sampling from discrete distributions
3. Energy landscape analysis
"""

import numpy as np
from typing import List, Tuple, Dict


# ─────────────────────────────────────────────────────────────
# Application 1: Local Search Optimization
# ─────────────────────────────────────────────────────────────

def local_search_analysis(n_cities: int = 6):
    """Analyze the exchange graph of 2-opt moves for small TSP instances.

    The state space is permutations of n cities. Two permutations are
    adjacent if one is obtained from the other by a 2-opt swap (reversing
    a subsequence). The potential is the tour length.

    This demonstrates how depth decrement controls search efficiency.
    """
    from itertools import permutations
    import math

    print("=" * 60)
    print(f"Application 1: TSP 2-opt Exchange Graph (n={n_cities})")
    print("=" * 60)

    # Generate random city positions
    np.random.seed(42)
    cities = np.random.rand(n_cities, 2)

    def tour_length(perm):
        total = 0
        for i in range(len(perm)):
            j = (i + 1) % len(perm)
            dx = cities[perm[i]][0] - cities[perm[j]][0]
            dy = cities[perm[i]][1] - cities[perm[j]][1]
            total += math.sqrt(dx*dx + dy*dy)
        return total

    def two_opt_neighbors(perm):
        """Generate all 2-opt neighbors."""
        neighbors = []
        n = len(perm)
        for i in range(n - 1):
            for j in range(i + 2, n):
                new_perm = list(perm)
                new_perm[i:j+1] = reversed(new_perm[i:j+1])
                neighbors.append(tuple(new_perm))
        return neighbors

    # For small n, enumerate all tours (fix first city)
    perms = [p for p in permutations(range(n_cities)) if p[0] == 0]
    potential = {p: tour_length(p) for p in perms}

    n_states = len(perms)
    print(f"  States: {n_states}")

    # Find depth decrement
    min_pot = min(potential.values())
    delta = float('inf')
    max_degree = 0

    for p in perms:
        if potential[p] <= min_pot + 1e-10:
            continue
        neighbors = two_opt_neighbors(p)
        valid_neighbors = [nb for nb in neighbors if nb in potential]
        max_degree = max(max_degree, len(valid_neighbors))
        best_decrease = max(
            (potential[p] - potential[nb] for nb in valid_neighbors
             if potential[nb] < potential[p]),
            default=0
        )
        if best_decrease > 0:
            delta = min(delta, best_decrease)

    if delta == float('inf'):
        delta = 0

    slb = delta**2 / (2 * max_degree**2) if max_degree > 0 else 0
    mixing_bound = (1/slb) * np.log(n_states) if slb > 0 else float('inf')

    print(f"  Max degree (2-opt): {max_degree}")
    print(f"  Depth decrement δ: {delta:.6f}")
    print(f"  Spectral lower bound δ²/(2D²): {slb:.8f}")
    print(f"  Mixing time bound: {mixing_bound:.1f}")
    print(f"  Optimal tour length: {min_pot:.4f}")
    print()


# ─────────────────────────────────────────────────────────────
# Application 2: Sampling from Boltzmann Distributions
# ─────────────────────────────────────────────────────────────

def boltzmann_sampling_analysis():
    """Analyze mixing of Glauber dynamics on small spin systems.

    The state space is {-1, +1}^n configurations. Adjacency is
    single spin flip. The potential is the Ising energy.
    The depth decrement controls how fast the Markov chain mixes.
    """
    from itertools import product as iprod

    n = 5  # Number of spins
    beta = 0.5  # Inverse temperature

    print("=" * 60)
    print(f"Application 2: Ising Model Sampling (n={n}, β={beta})")
    print("=" * 60)

    # All spin configurations
    states = list(iprod([-1, 1], repeat=n))
    n_states = len(states)

    # Nearest-neighbor Ising energy on a path
    def ising_energy(config):
        return -sum(config[i] * config[i+1] for i in range(n-1))

    potential = {s: ising_energy(s) for s in states}

    # Single spin flip adjacency
    def spin_flip_adj(x, y):
        diffs = sum(1 for i in range(n) if x[i] != y[i])
        return diffs == 1

    # Build adjacency matrix
    adj = np.zeros((n_states, n_states))
    for i in range(n_states):
        for j in range(i+1, n_states):
            if spin_flip_adj(states[i], states[j]):
                adj[i, j] = 1
                adj[j, i] = 1

    pot_vec = np.array([potential[s] for s in states])

    # Compute quantities
    max_deg = adj.sum(axis=1).max()
    min_pot = pot_vec.min()

    delta = float('inf')
    for i in range(n_states):
        if pot_vec[i] <= min_pot + 1e-10:
            continue
        best = 0
        for j in range(n_states):
            if adj[i, j] > 0:
                best = max(best, pot_vec[i] - pot_vec[j])
        if best > 0:
            delta = min(delta, best)

    if delta == float('inf'):
        delta = 0

    # Shell analysis
    unique_pots = sorted(set(pot_vec))
    shells = [int(np.sum(np.abs(pot_vec - v) < 1e-10)) for v in unique_pots]

    # Check log-concavity
    is_lc = all(
        shells[i]**2 >= shells[i-1] * shells[i+1] - 1e-10
        for i in range(1, len(shells) - 1)
    )

    # Spectrum
    degrees = adj.sum(axis=1)
    D_inv_sqrt = np.where(degrees > 0, 1.0 / np.sqrt(degrees), 0)
    L = np.diag(degrees) - adj
    L_norm = np.diag(D_inv_sqrt) @ L @ np.diag(D_inv_sqrt)
    evals = np.sort(np.linalg.eigvalsh(L_norm))
    lam2 = float(evals[1])

    slb = delta**2 / (2 * max_deg**2) if max_deg > 0 else 0
    mixing = (1/lam2) * np.log(n_states) if lam2 > 0 else float('inf')

    print(f"  States: {n_states}")
    print(f"  Max degree: {max_deg:.0f}")
    print(f"  Energy shells: {shells}")
    print(f"  Log-concave shells: {is_lc}")
    print(f"  Depth decrement δ: {delta:.4f}")
    print(f"  Spectral gap λ₂: {lam2:.6f}")
    print(f"  Spectral lower bound: {slb:.6f}")
    print(f"  Mixing time bound (1/λ₂)·ln(n): {mixing:.1f}")
    print()


# ─────────────────────────────────────────────────────────────
# Application 3: Energy Landscape Navigation
# ─────────────────────────────────────────────────────────────

def energy_landscape_analysis():
    """Analyze depth hierarchy for energy landscapes.

    Shows how the catalog depth decrement c/d^(d-k) translates
    to progressively tighter spectral and mixing bounds as
    certificate depth increases.
    """
    print("=" * 60)
    print("Application 3: Depth Hierarchy for Energy Landscapes")
    print("=" * 60)

    for d in [3, 5, 8, 10]:
        c = 1.0
        D = float(d)  # Assume max degree ~ d

        print(f"\n  Dimension d = {d}, c = {c}, D = {D}")
        print(f"  {'k':>4} {'δ_k':>12} {'λ₂ bound':>14} {'t_mix bound':>14} {'Speedup':>10}")
        print(f"  {'─'*54}")

        base_mix = None
        for k in range(d + 1):
            dk = catalog_depth_decrement(d, k, c)
            slb = dk**2 / (2 * D**2)
            mix = (1/slb) * np.log(100) if slb > 0 else float('inf')  # n=100

            if k == 0:
                base_mix = mix

            speedup = base_mix / mix if mix > 0 and mix < float('inf') else float('inf')

            print(f"  {k:>4} {dk:>12.6f} {slb:>14.8f} {mix:>14.1f} {speedup:>10.1f}x")


def catalog_depth_decrement(d, k, c):
    if d == 0:
        return c
    return c / d**(d - k)


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    local_search_analysis()
    boltzmann_sampling_analysis()
    energy_landscape_analysis()


#!/usr/bin/env python3
"""
Spectral Theory of Exchange Graphs — Interactive Demo

Constructs small exchange graphs, computes spectra, plots shell profiles,
and tests the depth-conductance conjecture.

Usage:
    python demo.py
"""

import numpy as np
from collections import defaultdict

# ─────────────────────────────────────────────────────────────
# 1. Exchange Graph Construction
# ─────────────────────────────────────────────────────────────

def build_exchange_graph(states, potential, adj_fn):
    """Build adjacency matrix and potential vector for an exchange graph.

    Args:
        states: list of states (any hashable)
        potential: dict mapping state -> float
        adj_fn: function (s1, s2) -> bool

    Returns:
        adj_matrix (np.ndarray), pot_vec (np.ndarray), state_list (list)
    """
    n = len(states)
    adj = np.zeros((n, n))
    pot = np.array([potential[s] for s in states])
    for i in range(n):
        for j in range(i + 1, n):
            if adj_fn(states[i], states[j]):
                adj[i, j] = 1
                adj[j, i] = 1
    return adj, pot, states


def exchange_step(x, y, d):
    """Check if y is obtained from x by an exchange step in Z^d:
    modify exactly two coordinates by +1 and -1."""
    diffs = [y[k] - x[k] for k in range(d)]
    plus_one = sum(1 for v in diffs if v == 1)
    minus_one = sum(1 for v in diffs if v == -1)
    zero = sum(1 for v in diffs if v == 0)
    return plus_one == 1 and minus_one == 1 and zero == d - 2


def generate_integer_lattice_states(d, bound):
    """Generate all points in {0,...,bound}^d with fixed coordinate sum."""
    from itertools import product as iprod
    total = d * bound // 2  # Fix sum to middle value
    states = []
    for pt in iprod(range(bound + 1), repeat=d):
        if sum(pt) == total:
            states.append(pt)
    return states


# ─────────────────────────────────────────────────────────────
# 2. Spectral Computations
# ─────────────────────────────────────────────────────────────

def compute_laplacian_spectrum(adj_matrix):
    """Compute normalized Laplacian eigenvalues."""
    n = adj_matrix.shape[0]
    degrees = adj_matrix.sum(axis=1)
    # Handle isolated vertices
    D_inv_sqrt = np.zeros(n)
    for i in range(n):
        if degrees[i] > 0:
            D_inv_sqrt[i] = 1.0 / np.sqrt(degrees[i])
    D_mat = np.diag(degrees)
    L = D_mat - adj_matrix
    # Normalized Laplacian: D^{-1/2} L D^{-1/2}
    D_inv_sqrt_mat = np.diag(D_inv_sqrt)
    L_norm = D_inv_sqrt_mat @ L @ D_inv_sqrt_mat
    eigenvalues = np.sort(np.linalg.eigvalsh(L_norm))
    return eigenvalues


def compute_conductance(adj_matrix, pi_weights=None):
    """Compute the Cheeger constant (conductance) of a graph.

    h(G) = min over S with 0 < vol(S) <= vol(V)/2 of
           |E(S, S^c)| / vol(S)
    """
    n = adj_matrix.shape[0]
    if pi_weights is None:
        pi_weights = adj_matrix.sum(axis=1)  # degree weights

    total_vol = pi_weights.sum()
    best_h = float('inf')

    # For small graphs, try all subsets
    if n <= 16:
        for mask in range(1, 2**n):
            S = [i for i in range(n) if mask & (1 << i)]
            Sc = [i for i in range(n) if not (mask & (1 << i))]
            vol_S = sum(pi_weights[i] for i in S)
            if vol_S <= 0 or vol_S > total_vol / 2:
                continue
            boundary = sum(adj_matrix[i, j] for i in S for j in Sc)
            h = boundary / vol_S
            best_h = min(best_h, h)
    else:
        # Random sampling approximation
        for _ in range(1000):
            k = np.random.randint(1, n)
            S = list(np.random.choice(n, k, replace=False))
            Sc = [i for i in range(n) if i not in S]
            vol_S = sum(pi_weights[i] for i in S)
            if vol_S <= 0 or vol_S > total_vol / 2:
                continue
            boundary = sum(adj_matrix[i, j] for i in S for j in Sc)
            h = boundary / vol_S
            best_h = min(best_h, h)

    return best_h if best_h < float('inf') else 0.0


def compute_shell_statistics(potential, states):
    """Compute shell masses and check log-concavity."""
    pot_vals = [potential[s] for s in states]
    unique_vals = sorted(set(pot_vals))
    shell_masses = []
    for v in unique_vals:
        mass = sum(1 for p in pot_vals if p == v)
        shell_masses.append(mass)

    # Check log-concavity
    is_log_concave = True
    for i in range(1, len(shell_masses) - 1):
        if shell_masses[i]**2 < shell_masses[i-1] * shell_masses[i+1]:
            is_log_concave = False
            break

    # Shell ratios
    ratios = []
    for i in range(len(shell_masses) - 1):
        if shell_masses[i] > 0:
            ratios.append(shell_masses[i+1] / shell_masses[i])
        else:
            ratios.append(float('inf'))

    return unique_vals, shell_masses, ratios, is_log_concave


# ─────────────────────────────────────────────────────────────
# 3. Depth Decrement Computation
# ─────────────────────────────────────────────────────────────

def compute_depth_decrement(adj_matrix, potential_vec, states):
    """Compute the minimum depth decrement delta:
    min over non-optimal x of max over neighbors y of (Phi(x) - Phi(y))."""
    n = len(states)
    min_pot = potential_vec.min()
    delta = float('inf')

    for i in range(n):
        if potential_vec[i] <= min_pot + 1e-10:
            continue  # Skip optimal states
        best_decrease = 0
        for j in range(n):
            if adj_matrix[i, j] > 0:
                decrease = potential_vec[i] - potential_vec[j]
                best_decrease = max(best_decrease, decrease)
        if best_decrease > 0:
            delta = min(delta, best_decrease)

    return delta if delta < float('inf') else 0.0


def spectral_lower_bound(delta, D):
    """Compute delta^2 / (2 * D^2)."""
    if D <= 0:
        return 0.0
    return delta**2 / (2 * D**2)


def catalog_depth_decrement(d, k, c):
    """Compute c / d^(d-k)."""
    if d == 0:
        return c
    return c / d**(d - k)


# ─────────────────────────────────────────────────────────────
# 4. Example Exchange Graphs
# ─────────────────────────────────────────────────────────────

def example_path_graph(n):
    """Path graph P_n with potential = position."""
    states = list(range(n))
    potential = {s: float(s) for s in states}
    adj_fn = lambda x, y: abs(x - y) == 1
    return build_exchange_graph(states, potential, adj_fn)


def example_cycle_graph(n):
    """Cycle graph C_n with potential = distance from 0."""
    states = list(range(n))
    potential = {s: float(min(s, n - s)) for s in states}
    adj_fn = lambda x, y: (x - y) % n == 1 or (y - x) % n == 1
    return build_exchange_graph(states, potential, adj_fn)


def example_lattice_exchange(d, bound):
    """Exchange graph on integer lattice points."""
    states = generate_integer_lattice_states(d, bound)
    if not states:
        return None, None, None
    potential = {s: float(sum(x**2 for x in s)) for s in states}
    adj_fn = lambda x, y: exchange_step(x, y, d)
    return build_exchange_graph(states, potential, adj_fn)


def example_hypercube(d):
    """Hypercube Q_d with Hamming weight potential."""
    from itertools import product as iprod
    states = list(iprod([0, 1], repeat=d))
    potential = {s: float(sum(s)) for s in states}
    adj_fn = lambda x, y: sum(abs(x[i] - y[i]) for i in range(d)) == 1
    return build_exchange_graph(states, potential, adj_fn)


# ─────────────────────────────────────────────────────────────
# 5. Main Demo
# ─────────────────────────────────────────────────────────────

def run_demo():
    print("=" * 70)
    print("SPECTRAL THEORY OF EXCHANGE GRAPHS — Demo")
    print("=" * 70)

    examples = [
        ("Path P_8", example_path_graph(8)),
        ("Cycle C_10", example_cycle_graph(10)),
        ("Hypercube Q_3", example_hypercube(3)),
        ("Hypercube Q_4", example_hypercube(4)),
    ]

    # Add lattice example if feasible
    lat = example_lattice_exchange(3, 4)
    if lat[0] is not None and len(lat[2]) <= 50:
        examples.append(("Lattice Z^3 (bound=4)", lat))

    results = []

    for name, (adj, pot, states) in examples:
        print(f"\n{'─' * 60}")
        print(f"  {name}  (n = {len(states)})")
        print(f"{'─' * 60}")

        # Spectrum
        eigenvalues = compute_laplacian_spectrum(adj)
        lambda2 = eigenvalues[1] if len(eigenvalues) > 1 else 0
        print(f"  Laplacian spectrum (first 5): {eigenvalues[:5].round(4)}")
        print(f"  Spectral gap λ₂ = {lambda2:.6f}")

        # Degree
        max_degree = adj.sum(axis=1).max()
        print(f"  Max degree D = {max_degree:.0f}")

        # Depth decrement
        delta = compute_depth_decrement(adj, pot, states)
        print(f"  Depth decrement δ = {delta:.4f}")

        # Conductance
        h = compute_conductance(adj)
        print(f"  Conductance h = {h:.6f}")

        # Shell statistics
        vals, masses, ratios, is_lc = compute_shell_statistics(
            {s: pot[i] for i, s in enumerate(states)}, states)
        print(f"  Shell masses: {masses}")
        print(f"  Log-concave: {is_lc}")
        if ratios:
            print(f"  Shell ratios: {[f'{r:.3f}' for r in ratios[:8]]}")

        # Bounds
        slb = spectral_lower_bound(delta, max_degree)
        print(f"\n  Spectral lower bound δ²/(2D²) = {slb:.6f}")
        print(f"  Actual λ₂ = {lambda2:.6f}")
        print(f"  Ratio λ₂ / bound = {lambda2/slb:.2f}" if slb > 0 else "  Bound = 0")

        # Cheeger comparison
        cheeger_bound = h**2 / 2
        print(f"  Cheeger bound h²/2 = {cheeger_bound:.6f}")
        print(f"  λ₂ ≥ h²/2? {lambda2 >= cheeger_bound - 1e-10}")

        # Linear conjecture test
        if delta > 0 and max_degree > 0:
            linear_ratio = lambda2 * max_degree / delta
            print(f"  Linear conjecture: λ₂·D/δ = {linear_ratio:.4f}")

        results.append({
            'name': name,
            'n': len(states),
            'lambda2': lambda2,
            'D': max_degree,
            'delta': delta,
            'h': h,
            'slb': slb,
            'is_lc': is_lc
        })

    # Summary table
    print(f"\n{'=' * 70}")
    print("SUMMARY TABLE")
    print(f"{'=' * 70}")
    print(f"{'Graph':<20} {'n':>4} {'λ₂':>8} {'D':>4} {'δ':>6} {'h':>8} {'δ²/2D²':>8} {'LC':>4}")
    print("-" * 70)
    for r in results:
        print(f"{r['name']:<20} {r['n']:>4} {r['lambda2']:>8.4f} {r['D']:>4.0f} "
              f"{r['delta']:>6.2f} {r['h']:>8.4f} {r['slb']:>8.4f} {'Y' if r['is_lc'] else 'N':>4}")

    # Depth hierarchy demo
    print(f"\n{'=' * 70}")
    print("DEPTH HIERARCHY — Catalog Decrement c/d^(d-k)")
    print(f"{'=' * 70}")
    for d in [3, 4, 5]:
        c = 1.0
        print(f"\n  d = {d}, c = {c}")
        print(f"  {'k':>4} {'δ_k':>12} {'δ_k²/(2·D²) [D=d]':>20}")
        for k in range(d + 1):
            dk = catalog_depth_decrement(d, k, c)
            slb = spectral_lower_bound(dk, d)
            print(f"  {k:>4} {dk:>12.6f} {slb:>20.8f}")

    print(f"\n{'=' * 70}")
    print("Demo complete.")


if __name__ == "__main__":
    run_demo()


#!/usr/bin/env python3
"""
Visualization: Cheeger Inequality Verification

Compares the actual spectral gap λ₂ with the Cheeger bound h²/2
and the depth-spectral bound δ²/(2D²) across multiple graph families.

Shows that the Cheeger inequality is tight for some families and
that the depth-spectral bound provides a useful lower bound.

CRITICAL: Fully self-contained. No local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iprod


def build_graph(states, potential_fn, adj_fn):
    """Build adjacency matrix and potential from states."""
    n = len(states)
    adj = np.zeros((n, n))
    pot = np.array([potential_fn(s) for s in states])
    for i in range(n):
        for j in range(i+1, n):
            if adj_fn(states[i], states[j]):
                adj[i, j] = 1
                adj[j, i] = 1
    return adj, pot


def spectral_gap(adj):
    """Compute λ₂ of normalized Laplacian."""
    n = adj.shape[0]
    deg = adj.sum(axis=1)
    D_inv = np.where(deg > 0, 1.0/np.sqrt(deg), 0)
    L = np.diag(deg) - adj
    L_norm = np.diag(D_inv) @ L @ np.diag(D_inv)
    evals = np.sort(np.linalg.eigvalsh(L_norm))
    return float(evals[1]) if len(evals) > 1 else 0


def conductance(adj):
    """Exact Cheeger constant for small graphs."""
    n = adj.shape[0]
    deg = adj.sum(axis=1)
    total = deg.sum()
    best = float('inf')
    for mask in range(1, min(2**n, 2**16)):
        S = [i for i in range(n) if mask & (1 << i)]
        vol = sum(deg[i] for i in S)
        if vol <= 0 or vol > total/2:
            continue
        Sc = [i for i in range(n) if not (mask & (1 << i))]
        bnd = sum(adj[i, j] for i in S for j in Sc)
        best = min(best, bnd/vol)
    return best if best < float('inf') else 0


def depth_decrement(adj, pot):
    """Compute minimum descent decrement."""
    n = adj.shape[0]
    min_p = pot.min()
    delta = float('inf')
    for i in range(n):
        if pot[i] <= min_p + 1e-10:
            continue
        best = 0
        for j in range(n):
            if adj[i, j] > 0:
                best = max(best, pot[i] - pot[j])
        if best > 0:
            delta = min(delta, best)
    return delta if delta < float('inf') else 0


# Build graph families
results = []

# Paths
for n in [4, 5, 6, 7, 8]:
    states = list(range(n))
    adj, pot = build_graph(states, lambda s: float(s), lambda x, y: abs(x-y)==1)
    lam2 = spectral_gap(adj)
    h = conductance(adj)
    d = depth_decrement(adj, pot)
    D = adj.sum(axis=1).max()
    results.append(('Path', n, lam2, h, d, D))

# Cycles
for n in [4, 5, 6, 8, 10]:
    states = list(range(n))
    adj, pot = build_graph(states, lambda s: float(min(s, n-s)),
                           lambda x, y: (x-y)%n==1 or (y-x)%n==1)
    lam2 = spectral_gap(adj)
    h = conductance(adj)
    d = depth_decrement(adj, pot)
    D = adj.sum(axis=1).max()
    results.append(('Cycle', n, lam2, h, d, D))

# Hypercubes
for dim in [2, 3, 4]:
    states = list(iprod([0, 1], repeat=dim))
    adj, pot = build_graph(states, lambda s: float(sum(s)),
                           lambda x, y: sum(abs(x[i]-y[i]) for i in range(dim))==1)
    lam2 = spectral_gap(adj)
    h = conductance(adj)
    d = depth_decrement(adj, pot)
    D = adj.sum(axis=1).max()
    results.append(('Cube', 2**dim, lam2, h, d, D))

# Complete graphs
for n in [3, 4, 5, 6]:
    states = list(range(n))
    adj, pot = build_graph(states, lambda s: float(s),
                           lambda x, y: x != y)
    lam2 = spectral_gap(adj)
    h = conductance(adj)
    d = depth_decrement(adj, pot)
    D = adj.sum(axis=1).max()
    results.append(('Complete', n, lam2, h, d, D))

# Plot
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: λ₂ vs h²/2
ax = axes[0]
lam2s = [r[2] for r in results]
cheeger = [r[3]**2/2 for r in results]
family_colors = {'Path': '#2196F3', 'Cycle': '#FF5722', 'Cube': '#4CAF50', 'Complete': '#9C27B0'}

for family in ['Path', 'Cycle', 'Cube', 'Complete']:
    idx = [i for i, r in enumerate(results) if r[0] == family]
    x = [cheeger[i] for i in idx]
    y = [lam2s[i] for i in idx]
    ax.scatter(x, y, c=family_colors[family], s=80, label=family, edgecolors='black', zorder=5)

maxval = max(max(lam2s), max(cheeger)) * 1.1
ax.plot([0, maxval], [0, maxval], '--', color='gray', alpha=0.5, label='λ₂ = h²/2')
ax.set_xlabel('Cheeger bound h²/2', fontsize=12)
ax.set_ylabel('Spectral gap λ₂', fontsize=12)
ax.set_title('Cheeger Inequality: λ₂ ≥ h²/2', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: λ₂ vs δ²/(2D²)
ax = axes[1]
slbs = [r[4]**2 / (2*r[5]**2) if r[5] > 0 else 0 for r in results]

for family in ['Path', 'Cycle', 'Cube', 'Complete']:
    idx = [i for i, r in enumerate(results) if r[0] == family]
    x = [slbs[i] for i in idx]
    y = [lam2s[i] for i in idx]
    ax.scatter(x, y, c=family_colors[family], s=80, label=family, edgecolors='black', zorder=5)

maxval = max(max(lam2s), max(slbs)) * 1.1
ax.plot([0, maxval], [0, maxval], '--', color='gray', alpha=0.5, label='λ₂ = δ²/(2D²)')
ax.set_xlabel('Depth-spectral bound δ²/(2D²)', fontsize=12)
ax.set_ylabel('Spectral gap λ₂', fontsize=12)
ax.set_title('Depth-Spectral Bound Verification', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Ratio λ₂ / (δ²/(2D²))
ax = axes[2]
ratios = [lam2s[i] / slbs[i] if slbs[i] > 0 else 0 for i in range(len(results))]
names = [f"{r[0]}({r[1]})" for r in results]
bar_colors = [family_colors[r[0]] for r in results]

# Sort by ratio
sorted_idx = sorted(range(len(ratios)), key=lambda i: ratios[i])
ax.barh(range(len(sorted_idx)),
        [ratios[i] for i in sorted_idx],
        color=[bar_colors[i] for i in sorted_idx],
        edgecolor='black', alpha=0.8)
ax.set_yticks(range(len(sorted_idx)))
ax.set_yticklabels([names[i] for i in sorted_idx], fontsize=8)
ax.set_xlabel('λ₂ / (δ²/(2D²))', fontsize=12)
ax.set_title('Tightness of Depth-Spectral Bound', fontsize=13, fontweight='bold')
ax.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='Bound = Exact')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='x')

plt.suptitle('Cheeger Inequality Verification Across Graph Families',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('cheeger_comparison.png', dpi=150, bbox_inches='tight')
print("Saved cheeger_comparison.png")


#!/usr/bin/env python3
"""
Visualization: Log-Concavity of Shell Masses and Ratio Monotonicity

Demonstrates the key bridge theorem: log-concave shell masses yield
non-increasing shell ratios, which provide an expansion proxy.

Panel 1: Shell mass profiles for several exchange graphs
Panel 2: Shell ratios showing non-increasing property
Panel 3: Conductance vs depth decrement scatter plot

CRITICAL: Fully self-contained. No local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iprod


def build_hypercube(d):
    """Build hypercube Q_d: states, adjacency, potential (Hamming weight)."""
    states = list(iprod([0, 1], repeat=d))
    n = len(states)
    potential = np.array([float(sum(s)) for s in states])
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i+1, n):
            if sum(abs(states[i][k] - states[j][k]) for k in range(d)) == 1:
                adj[i, j] = 1
                adj[j, i] = 1
    return states, adj, potential


def compute_shells(potential):
    """Return (values, counts) for potential shells."""
    unique = sorted(set(potential))
    counts = [int(np.sum(np.abs(potential - v) < 1e-10)) for v in unique]
    return unique, counts


def compute_conductance_exact(adj, n):
    """Exact Cheeger constant for small graphs."""
    degrees = adj.sum(axis=1)
    total_vol = degrees.sum()
    best_h = float('inf')
    for mask in range(1, min(2**n, 2**16)):
        S = [i for i in range(n) if mask & (1 << i)]
        vol_S = sum(degrees[i] for i in S)
        if vol_S <= 0 or vol_S > total_vol / 2:
            continue
        Sc = [i for i in range(n) if not (mask & (1 << i))]
        boundary = sum(adj[i, j] for i in S for j in Sc)
        h = boundary / vol_S
        best_h = min(best_h, h)
    return best_h if best_h < float('inf') else 0


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Shell mass profiles
ax = axes[0]
dims = [3, 4, 5, 6]
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
all_data = {}

for d, col in zip(dims, colors):
    states, adj, pot = build_hypercube(d)
    vals, counts = compute_shells(pot)
    ax.plot(vals, counts, 'o-', color=col, label=f'Q_{d}', linewidth=2, markersize=7)
    all_data[d] = (states, adj, pot, vals, counts)

ax.set_xlabel('Shell level (Hamming weight)', fontsize=12)
ax.set_ylabel('Shell mass (# states)', fontsize=12)
ax.set_title('Shell Mass Profiles (Hypercubes)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Shell ratios
ax = axes[1]
for d, col in zip(dims, colors):
    _, _, _, vals, counts = all_data[d]
    ratios = [counts[i+1]/counts[i] for i in range(len(counts)-1)]
    ax.plot(range(len(ratios)), ratios, 's-', color=col, label=f'Q_{d}', linewidth=2, markersize=6)

ax.set_xlabel('Shell index n', fontsize=12)
ax.set_ylabel('Ratio a(n+1)/a(n)', fontsize=12)
ax.set_title('Shell Ratios (Non-Increasing ⟹ Log-Concave)', fontsize=13, fontweight='bold')
ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='ratio = 1')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: δ vs conductance
ax = axes[2]
deltas_list = []
conds_list = []
labels = []

for d in [3, 4, 5]:
    states, adj, pot = build_hypercube(d)
    n = len(states)
    min_pot = pot.min()
    delta_val = float('inf')
    for i in range(n):
        if pot[i] <= min_pot + 1e-10:
            continue
        best = 0
        for j in range(n):
            if adj[i, j] > 0:
                best = max(best, pot[i] - pot[j])
        if best > 0:
            delta_val = min(delta_val, best)
    if delta_val == float('inf'):
        delta_val = 0

    D = adj.sum(axis=1).max()
    h = compute_conductance_exact(adj, n) if n <= 16 else 0

    deltas_list.append(delta_val / D if D > 0 else 0)
    conds_list.append(h)
    labels.append(f'Q_{d}')

ax.scatter(deltas_list, conds_list, c=colors[:len(deltas_list)], s=120, zorder=5, edgecolors='black')
for i, label in enumerate(labels):
    ax.annotate(label, (deltas_list[i], conds_list[i]),
                textcoords="offset points", xytext=(10, 5), fontsize=11)

# Reference line
if deltas_list:
    x_line = np.linspace(0, max(deltas_list)*1.2, 50)
    ax.plot(x_line, x_line, '--', color='gray', alpha=0.5, label='h = δ/D')
ax.set_xlabel('δ/D (depth-degree ratio)', fontsize=12)
ax.set_ylabel('Conductance h', fontsize=12)
ax.set_title('Conductance vs Depth-Degree Ratio', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Log-Concavity Bridge: Shells → Ratios → Expansion',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shell_logconcavity.png', dpi=150, bbox_inches='tight')
print("Saved shell_logconcavity.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Chain δ → h → λ₂ → t_mix

Visualizes the core mathematical result: how certificate depth controls
the entire chain from conductance to spectral gap to mixing time.
Three panels show:
1. Depth decrement δ_k vs k for various dimensions
2. Spectral lower bound δ²/(2D²) vs k (log scale)
3. Mixing time bound vs k (log scale)

CRITICAL: This script is fully self-contained. No local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def catalog_depth_decrement(d, k, c=1.0):
    """c / d^(d-k)"""
    if d == 0:
        return c
    return c / d**(d - k)


def spectral_lower_bound(delta, D):
    """delta^2 / (2*D^2)"""
    if D <= 0:
        return 0
    return delta**2 / (2 * D**2)


def mixing_time_bound(slb, n):
    """(1/slb) * ln(n)"""
    if slb <= 0:
        return float('inf')
    return (1/slb) * np.log(n)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
dims = [3, 4, 5, 6]
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
n_states = 100  # For mixing time

# Panel 1: Depth decrement
ax = axes[0]
for d, col in zip(dims, colors):
    ks = list(range(d + 1))
    deltas = [catalog_depth_decrement(d, k) for k in ks]
    ax.plot(ks, deltas, 'o-', color=col, label=f'd={d}', linewidth=2, markersize=6)
ax.set_xlabel('Certificate depth k', fontsize=12)
ax.set_ylabel('Depth decrement δ_k', fontsize=12)
ax.set_title('Depth Decrement vs Certificate Depth', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Spectral lower bound
ax = axes[1]
for d, col in zip(dims, colors):
    ks = list(range(d + 1))
    slbs = [spectral_lower_bound(catalog_depth_decrement(d, k), d) for k in ks]
    ax.plot(ks, slbs, 's-', color=col, label=f'd={d}', linewidth=2, markersize=6)
ax.set_xlabel('Certificate depth k', fontsize=12)
ax.set_ylabel('Spectral lower bound δ²/(2D²)', fontsize=12)
ax.set_title('Spectral Gap Bound vs Depth', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 3: Mixing time
ax = axes[2]
for d, col in zip(dims, colors):
    ks = list(range(d + 1))
    mixes = [mixing_time_bound(
        spectral_lower_bound(catalog_depth_decrement(d, k), d), n_states
    ) for k in ks]
    ax.plot(ks, mixes, '^-', color=col, label=f'd={d}', linewidth=2, markersize=6)
ax.set_xlabel('Certificate depth k', fontsize=12)
ax.set_ylabel('Mixing time bound (1/λ₂)·ln(n)', fontsize=12)
ax.set_title('Mixing Time vs Depth (n=100)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

plt.suptitle('The Depth-Spectral Chain: Certificate Depth Controls Mixing',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_chain.png', dpi=150, bbox_inches='tight')
print("Saved spectral_chain.png")
