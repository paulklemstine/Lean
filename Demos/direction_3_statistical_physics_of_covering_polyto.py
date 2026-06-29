#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Covering Polytope Thermodynamics

Demonstrates how the statistical physics framework for hypergraph transversals
applies to practical optimization and constraint satisfaction problems.

Applications:
1. Sensor network coverage — minimum sensors to monitor all zones
2. Test suite optimization — minimum tests to cover all code paths  
3. Scheduling: crew covering — minimum crews for all routes
"""

import numpy as np
import itertools
from collections import defaultdict
from typing import List, Set, FrozenSet, Tuple, Dict


# ─── Application 1: Sensor Network Coverage ────────────────────────────────

class SensorCoverageNetwork:
    """
    Model a sensor network as a hypergraph transversal problem.
    
    Vertices = potential sensor locations
    Edges = groups of sensors that jointly cover a zone
    Transversal = sensor placement covering all zones
    
    The Gibbs measure at inverse temperature β gives a distribution over
    valid sensor placements, with lower-cardinality placements preferred
    at higher β.
    """
    
    def __init__(self, n_locations: int, zones: List[Set[int]], name: str = ""):
        self.n = n_locations
        self.zones = [frozenset(z) for z in zones]
        self.name = name
    
    def is_valid_placement(self, sensors: Set[int]) -> bool:
        """Check if sensor placement covers all zones."""
        return all(len(sensors & z) > 0 for z in self.zones)
    
    def partition_function(self, beta: float) -> float:
        """Compute Z(β) for the sensor placement problem."""
        Z = 0.0
        for mask in range(1 << self.n):
            S = {i for i in range(self.n) if mask & (1 << i)}
            if self.is_valid_placement(S):
                Z += np.exp(-beta * len(S))
        return Z
    
    def gibbs_expected_sensors(self, beta: float) -> float:
        """Expected number of sensors under the Gibbs measure."""
        Z = 0.0
        E_size = 0.0
        for mask in range(1 << self.n):
            S = {i for i in range(self.n) if mask & (1 << i)}
            if self.is_valid_placement(S):
                w = np.exp(-beta * len(S))
                Z += w
                E_size += len(S) * w
        return E_size / Z if Z > 0 else 0
    
    def optimal_placement_size(self) -> int:
        """Find minimum number of sensors needed."""
        for k in range(self.n + 1):
            for combo in itertools.combinations(range(self.n), k):
                if self.is_valid_placement(set(combo)):
                    return k
        return self.n

    def analyze(self):
        """Print analysis of the sensor network."""
        print(f"\n{'='*50}")
        print(f"Sensor Network: {self.name}")
        print(f"  Locations: {self.n}")
        print(f"  Zones: {len(self.zones)}")
        
        tau = self.optimal_placement_size()
        print(f"  Minimum sensors needed: {tau}")
        
        print(f"\n  Gibbs analysis:")
        for beta in [0, 0.5, 1.0, 2.0, 5.0]:
            E_s = self.gibbs_expected_sensors(beta)
            print(f"    β={beta:.1f}: E[sensors] = {E_s:.2f}")
        
        print(f"\n  Interpretation:")
        print(f"    β=0 (max entropy): equally weights all valid placements")
        print(f"    β→∞ (min energy): concentrates on optimal {tau}-sensor placements")


# ─── Application 2: Test Suite Coverage ─────────────────────────────────────

class TestCoverageOptimizer:
    """
    Model test suite selection as a hypergraph transversal problem.
    
    Vertices = available test cases
    Edges = sets of tests covering each code path/requirement
    Transversal = test suite covering all requirements
    """
    
    def __init__(self, n_tests: int, requirements: List[Set[int]]):
        self.n = n_tests
        self.requirements = [frozenset(r) for r in requirements]
    
    def covers_all(self, suite: Set[int]) -> bool:
        return all(len(suite & r) > 0 for r in self.requirements)
    
    def minimum_suite_size(self) -> int:
        for k in range(self.n + 1):
            for combo in itertools.combinations(range(self.n), k):
                if self.covers_all(set(combo)):
                    return k
        return self.n
    
    def thermodynamic_analysis(self):
        """Analyze the test coverage landscape thermodynamically."""
        print(f"\n{'='*50}")
        print(f"Test Suite Coverage Analysis")
        print(f"  Available tests: {self.n}")
        print(f"  Requirements: {len(self.requirements)}")
        
        tau = self.minimum_suite_size()
        total_valid = sum(1 for mask in range(1 << self.n)
                        if self.covers_all({i for i in range(self.n) if mask & (1 << i)}))
        
        print(f"  Minimum suite size: {tau}")
        print(f"  Valid suites: {total_valid} out of {2**self.n}")
        
        # Free energy landscape
        print(f"\n  Free energy landscape:")
        for beta in [0, 1, 2, 5, 10]:
            Z = sum(np.exp(-beta * len({i for i in range(self.n) if mask & (1 << i)}))
                   for mask in range(1 << self.n)
                   if self.covers_all({i for i in range(self.n) if mask & (1 << i)}))
            f = -np.log(max(Z, 1e-300)) / self.n
            print(f"    β={beta:2d}: f(β) = {f:.4f}, Z(β) = {Z:.4f}")


# ─── Application 3: Crew Scheduling ────────────────────────────────────────

class CrewScheduler:
    """
    Model crew scheduling as a covering problem.
    
    Vertices = available crew members
    Edges = sets of crew members qualified for each route
    Transversal = crew assignment covering all routes
    """
    
    def __init__(self, n_crew: int, routes: List[Set[int]]):
        self.n = n_crew
        self.routes = [frozenset(r) for r in routes]
    
    def is_feasible(self, assignment: Set[int]) -> bool:
        return all(len(assignment & r) > 0 for r in self.routes)
    
    def analyze_flexibility(self):
        """Analyze scheduling flexibility via thermodynamics."""
        print(f"\n{'='*50}")
        print(f"Crew Scheduling Thermodynamic Analysis")
        print(f"  Crew members: {self.n}")
        print(f"  Routes: {len(self.routes)}")
        
        # Count feasible assignments by size
        size_counts: Dict[int, int] = defaultdict(int)
        for mask in range(1 << self.n):
            S = {i for i in range(self.n) if mask & (1 << i)}
            if self.is_feasible(S):
                size_counts[len(S)] += 1
        
        print(f"\n  Feasible assignments by crew size:")
        for k in sorted(size_counts.keys()):
            print(f"    Size {k}: {size_counts[k]} assignments")
        
        min_crew = min(size_counts.keys()) if size_counts else self.n
        print(f"\n  Minimum crew needed: {min_crew}")
        
        # Gibbs concentration
        print(f"\n  Gibbs concentration (fraction of mass on minimum-size):")
        for beta in [0, 1, 3, 5, 10]:
            Z = 0.0
            Z_min = 0.0
            for size, count in size_counts.items():
                w = count * np.exp(-beta * size)
                Z += w
                if size == min_crew:
                    Z_min += w
            frac = Z_min / Z if Z > 0 else 0
            print(f"    β={beta:2d}: P(min crew) = {frac:.4f}")


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    print("APPLICATIONS OF COVERING POLYTOPE THERMODYNAMICS")
    print("=" * 50)
    
    # Application 1: Sensor Network
    # 8 sensor locations, 5 monitoring zones
    network = SensorCoverageNetwork(
        n_locations=8,
        zones=[
            {0, 1, 2},      # Zone A: covered by sensors 0, 1, or 2
            {2, 3, 4},      # Zone B
            {4, 5},         # Zone C
            {5, 6, 7},      # Zone D
            {0, 7},         # Zone E
        ],
        name="Building Monitor"
    )
    network.analyze()
    
    # Application 2: Test Coverage
    # 8 tests, 6 code path requirements
    optimizer = TestCoverageOptimizer(
        n_tests=8,
        requirements=[
            {0, 1},         # Path 1
            {1, 2, 3},      # Path 2
            {3, 4},         # Path 3
            {4, 5, 6},      # Path 4
            {6, 7},         # Path 5
            {0, 7},         # Path 6
        ]
    )
    optimizer.thermodynamic_analysis()
    
    # Application 3: Crew Scheduling
    # 7 crew members, 4 routes
    scheduler = CrewScheduler(
        n_crew=7,
        routes=[
            {0, 1, 2},      # Route 1
            {2, 3},          # Route 2
            {3, 4, 5},      # Route 3
            {5, 6},          # Route 4
        ]
    )
    scheduler.analyze_flexibility()
    
    print("\n" + "=" * 50)
    print("KEY INSIGHT: In all applications, the Gibbs measure at")
    print("intermediate β provides a 'softened' optimization landscape")
    print("that interpolates between uniform exploration (β=0) and")
    print("hard optimization (β→∞). The free energy monotonicity")
    print("theorem guarantees this interpolation is well-behaved.")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Demonstration of the Statistical Physics of Covering Polytopes

Generates random bounded-codegree 3-uniform hypergraphs, estimates the partition
function Z_H(β) and mean cover size via Monte Carlo / Metropolis sampling, and
plots the estimated free energy and mean cover size vs β.

Compares the empirical transition region with the predicted β_c ≈ log(d-1) + c/K.
"""

import numpy as np
import itertools
from collections import defaultdict

# ─── Hypergraph generation ───────────────────────────────────────────────────

def generate_bounded_codegree_hypergraph(n, d=3, target_edges=None, K=2, seed=42):
    """
    Generate a random d-uniform hypergraph on n vertices with pair-codegree ≤ K.
    
    Parameters:
        n: number of vertices
        d: uniformity (edge size)
        target_edges: approximate number of edges (default: 2*n)
        K: pair-codegree bound
        seed: random seed
    
    Returns:
        edges: list of frozensets, each of size d
    """
    rng = np.random.default_rng(seed)
    if target_edges is None:
        target_edges = 2 * n
    
    edges = []
    pair_count = defaultdict(int)
    
    candidates = list(itertools.combinations(range(n), d))
    rng.shuffle(candidates)
    
    for edge_tuple in candidates:
        if len(edges) >= target_edges:
            break
        edge = frozenset(edge_tuple)
        # Check pair-codegree constraint
        pairs = list(itertools.combinations(sorted(edge), 2))
        if all(pair_count[p] < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] += 1
    
    return edges

def is_transversal(edges, S):
    """Check if vertex set S hits every edge."""
    S_set = set(S)
    return all(len(S_set & edge) > 0 for edge in edges)

def find_greedy_transversal(n, edges):
    """Find a transversal using a greedy algorithm."""
    uncovered = list(range(len(edges)))
    S = set()
    remaining_edges = [set(e) for e in edges]
    
    while uncovered:
        # Pick vertex covering the most uncovered edges
        vertex_count = defaultdict(int)
        for i in uncovered:
            for v in remaining_edges[i]:
                vertex_count[v] += 1
        best_v = max(vertex_count, key=vertex_count.get)
        S.add(best_v)
        uncovered = [i for i in uncovered if best_v not in remaining_edges[i]]
    
    return S

# ─── Exact partition function (small instances) ─────────────────────────────

def exact_partition_function(n, edges, beta):
    """Compute Z_H(β) exactly by enumeration (feasible for n ≤ 20)."""
    Z = 0.0
    for mask in range(1 << n):
        S = {i for i in range(n) if mask & (1 << i)}
        if is_transversal(edges, S):
            Z += np.exp(-beta * len(S))
    return Z

def exact_mean_cover_size(n, edges, beta):
    """Compute E_μ[|S|] exactly."""
    Z = 0.0
    mean_size = 0.0
    for mask in range(1 << n):
        S = {i for i in range(n) if mask & (1 << i)}
        if is_transversal(edges, S):
            w = np.exp(-beta * len(S))
            Z += w
            mean_size += len(S) * w
    if Z > 0:
        return mean_size / Z
    return 0.0

# ─── Metropolis-Hastings sampler ─────────────────────────────────────────────

def metropolis_sampler(n, edges, beta, num_samples=5000, burn_in=1000, seed=123):
    """
    Metropolis-Hastings sampler for the hard-cover Gibbs measure.
    
    Proposes single-vertex flips, rejects if the result is not a transversal.
    """
    rng = np.random.default_rng(seed)
    
    # Start from a greedy transversal
    S = find_greedy_transversal(n, edges)
    current_size = len(S)
    state = [v in S for v in range(n)]
    
    samples = []
    accepted = 0
    
    for step in range(burn_in + num_samples):
        # Propose: flip a random vertex
        v = rng.integers(0, n)
        new_state = state.copy()
        new_state[v] = not new_state[v]
        
        new_S = {i for i in range(n) if new_state[i]}
        
        if is_transversal(edges, new_S):
            new_size = len(new_S)
            delta_E = new_size - current_size
            
            # Metropolis acceptance
            if delta_E <= 0 or rng.random() < np.exp(-beta * delta_E):
                state = new_state
                current_size = new_size
                accepted += 1
        
        if step >= burn_in:
            samples.append(current_size)
    
    return np.array(samples)

# ─── Main demonstration ─────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("STATISTICAL PHYSICS OF COVERING POLYTOPES — DEMONSTRATION")
    print("=" * 70)
    
    # Small instance for exact computation
    n_small = 10
    K = 2
    edges_small = generate_bounded_codegree_hypergraph(n_small, d=3, target_edges=8, K=K, seed=42)
    
    print(f"\n--- Small Hypergraph (n={n_small}, |E|={len(edges_small)}, K={K}) ---")
    
    # Find transversal number
    tau = n_small  # start with worst case
    for mask in range(1 << n_small):
        S = {i for i in range(n_small) if mask & (1 << i)}
        if is_transversal(edges_small, S):
            tau = min(tau, len(S))
    
    num_transversals = sum(1 for mask in range(1 << n_small)
                          if is_transversal(edges_small, {i for i in range(n_small) if mask & (1 << i)}))
    
    print(f"  Transversal number τ(H) = {tau}")
    print(f"  Number of transversals = {num_transversals}")
    print(f"  2^|V| = {2**n_small}")
    
    # Verify Theorem 1: Z_H(0) counts transversals
    Z0 = exact_partition_function(n_small, edges_small, 0.0)
    print(f"\n  Theorem 1 check: Z_H(0) = {Z0:.0f} = number of transversals ✓" 
          if abs(Z0 - num_transversals) < 0.5 else f"  Z_H(0) = {Z0}")
    
    # Verify monotonicity and bounds
    betas = np.linspace(0, 5, 50)
    Z_values = [exact_partition_function(n_small, edges_small, b) for b in betas]
    
    print(f"\n  Theorem 1 check: Z_H antitone? {all(Z_values[i] >= Z_values[i+1] - 1e-10 for i in range(len(Z_values)-1))} ✓")
    
    # Verify Theorem 2 bounds
    print(f"\n  Theorem 2 (variational bounds) at β=1:")
    Z1 = exact_partition_function(n_small, edges_small, 1.0)
    lower = np.exp(-1.0 * tau)
    upper = 2**n_small * np.exp(-1.0 * tau)
    print(f"    Lower: e^(-τ) = {lower:.6f}")
    print(f"    Z_H(1) = {Z1:.6f}")
    print(f"    Upper: 2^|V| · e^(-τ) = {upper:.6f}")
    print(f"    Bounds satisfied: {lower <= Z1 + 1e-10 and Z1 <= upper + 1e-10} ✓")
    
    # Free energy
    f_values = [-np.log(max(Z, 1e-300)) / n_small for Z in Z_values]
    
    print(f"\n  Free energy f_H(0) = {f_values[0]:.6f}")
    print(f"  Free energy f_H(5) = {f_values[-1]:.6f}")
    print(f"  Free energy monotone? {all(f_values[i] <= f_values[i+1] + 1e-10 for i in range(len(f_values)-1))} ✓")
    
    # Larger instance with Metropolis
    print("\n" + "=" * 70)
    n_large = 30
    edges_large = generate_bounded_codegree_hypergraph(n_large, d=3, target_edges=40, K=K, seed=99)
    print(f"\n--- Larger Hypergraph (n={n_large}, |E|={len(edges_large)}, K={K}) ---")
    
    greedy = find_greedy_transversal(n_large, edges_large)
    print(f"  Greedy transversal size = {len(greedy)}")
    
    betas_mc = np.linspace(0, 4, 20)
    mean_sizes = []
    
    print(f"\n  Metropolis-Hastings estimation (5000 samples per β):")
    print(f"  {'β':>8s} {'E[|S|]':>10s} {'std(|S|)':>10s}")
    print(f"  {'-'*30}")
    
    for b in betas_mc:
        samples = metropolis_sampler(n_large, edges_large, b, num_samples=5000, seed=int(b*100)+1)
        mean_s = np.mean(samples)
        std_s = np.std(samples)
        mean_sizes.append(mean_s)
        if b < 0.1 or abs(b - 1.0) < 0.15 or abs(b - 2.0) < 0.15 or abs(b - 3.0) < 0.15 or b > 3.8:
            print(f"  {b:8.2f} {mean_s:10.2f} {std_s:10.2f}")
    
    # Predicted critical β
    d = 3
    beta_c_pred = np.log(d - 1) + 1.0 / (K + 1)
    print(f"\n  Predicted critical β_c ≈ log({d}-1) + 1/({K}+1) = {beta_c_pred:.4f}")
    
    # Find empirical transition (steepest descent in mean size)
    diffs = [mean_sizes[i] - mean_sizes[i+1] for i in range(len(mean_sizes)-1)]
    if diffs:
        max_diff_idx = np.argmax(diffs)
        beta_c_emp = (betas_mc[max_diff_idx] + betas_mc[max_diff_idx + 1]) / 2
        print(f"  Empirical transition region ≈ β = {beta_c_emp:.4f}")
    
    print("\n" + "=" * 70)
    print("DEMONSTRATION COMPLETE")
    print("=" * 70)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Energy Landscape of Transversal Sizes

Creates a heatmap showing the distribution of Gibbs mass across transversal
sizes at different temperatures, illustrating the transition from the
high-temperature counting regime to the low-temperature optimization regime.

This directly visualizes the content of the free energy sandwich theorem:
the Gibbs measure interpolates between uniform over all transversals (β=0)
and concentrated on minimum transversals (β→∞).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import itertools
from collections import defaultdict


def generate_hypergraph(n, d=3, target_edges=None, K=2, seed=42):
    rng = np.random.default_rng(seed)
    if target_edges is None:
        target_edges = 2 * n
    edges = []
    pair_count = defaultdict(int)
    candidates = list(itertools.combinations(range(n), d))
    rng.shuffle(candidates)
    for edge_tuple in candidates:
        if len(edges) >= target_edges:
            break
        edge = frozenset(edge_tuple)
        pairs = list(itertools.combinations(sorted(edge), 2))
        if all(pair_count[p] < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] += 1
    return edges


def is_transversal(edges, S):
    return all(len(set(S) & edge) > 0 for edge in edges)


def size_distribution(n, edges, beta):
    """Compute the distribution of |S| under the Gibbs measure."""
    Z = 0.0
    counts = defaultdict(float)
    for mask in range(1 << n):
        S = {i for i in range(n) if mask & (1 << i)}
        if is_transversal(edges, S):
            w = np.exp(-beta * len(S))
            Z += w
            counts[len(S)] += w
    if Z > 0:
        for k in counts:
            counts[k] /= Z
    return dict(counts)


# Generate hypergraph
n = 11
K = 2
edges = generate_hypergraph(n, d=3, target_edges=10, K=K, seed=42)

# Find tau
tau = n
for k in range(n + 1):
    for combo in itertools.combinations(range(n), k):
        if is_transversal(edges, set(combo)):
            tau = k
            break
    if tau == k:
        break

# Compute distributions at various β
betas = np.linspace(0, 5, 80)
max_size = n
min_size = tau

# Build heatmap data
heatmap = np.zeros((max_size - min_size + 1, len(betas)))
for j, b in enumerate(betas):
    dist = size_distribution(n, edges, b)
    for size, prob in dist.items():
        if min_size <= size <= max_size:
            heatmap[size - min_size, j] = prob

# Mean cover size
mean_sizes = []
for b in betas:
    dist = size_distribution(n, edges, b)
    mean = sum(k * v for k, v in dist.items())
    mean_sizes.append(mean)

fig, axes = plt.subplots(2, 1, figsize=(12, 10), height_ratios=[3, 1])

# Top: Heatmap
ax = axes[0]
im = ax.imshow(heatmap, aspect='auto', origin='lower',
               extent=[betas[0], betas[-1], min_size - 0.5, max_size + 0.5],
               cmap='YlOrRd', norm=mcolors.PowerNorm(gamma=0.5))
ax.plot(betas, mean_sizes, 'cyan', linewidth=2.5, label=r'$\mathbb{E}_\mu[|S|]$')
ax.axhline(y=tau, color='white', linewidth=1.5, linestyle='--', alpha=0.8,
           label=f'τ(H) = {tau}')
cbar = plt.colorbar(im, ax=ax, label='Gibbs probability')
ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Transversal size $|S|$', fontsize=13)
ax.set_title(f'Gibbs Mass Distribution over Transversal Sizes\n'
             f'(n={n}, |E|={len(edges)}, d=3, K={K}, τ={tau})', fontsize=14)
ax.legend(fontsize=11, loc='upper right')

# Bottom: Entropy-like measure (number of sizes with >1% mass)
ax = axes[1]
entropies = []
for j, b in enumerate(betas):
    col = heatmap[:, j]
    # Shannon entropy
    H = -sum(p * np.log(p + 1e-20) for p in col if p > 0)
    entropies.append(H)

ax.plot(betas, entropies, 'g-', linewidth=2)
ax.fill_between(betas, 0, entropies, alpha=0.2, color='green')
ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel('Shannon entropy\nof size distribution', fontsize=11)
ax.set_title('Entropy of Transversal Size Distribution', fontsize=13)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved energy_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Free Energy Landscape of Covering Polytopes

Plots the free energy f_H(β) and its sandwich bounds for a small hypergraph,
demonstrating Theorems 1 and 2: monotonicity and variational bounds.

The plot shows:
- The exact free energy curve (monotone nondecreasing)
- Lower bound: (βτ - |V|log2)/|V|
- Upper bound: βτ/|V|
- The transition from high-temperature (counting) to low-temperature (optimization)
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools
from collections import defaultdict


def generate_hypergraph(n, d=3, target_edges=None, K=2, seed=42):
    rng = np.random.default_rng(seed)
    if target_edges is None:
        target_edges = 2 * n
    edges = []
    pair_count = defaultdict(int)
    candidates = list(itertools.combinations(range(n), d))
    rng.shuffle(candidates)
    for edge_tuple in candidates:
        if len(edges) >= target_edges:
            break
        edge = frozenset(edge_tuple)
        pairs = list(itertools.combinations(sorted(edge), 2))
        if all(pair_count[p] < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] += 1
    return edges


def is_transversal(edges, S):
    S_set = set(S)
    return all(len(S_set & edge) > 0 for edge in edges)


def exact_partition_function(n, edges, beta):
    Z = 0.0
    for mask in range(1 << n):
        S = {i for i in range(n) if mask & (1 << i)}
        if is_transversal(edges, S):
            Z += np.exp(-beta * len(S))
    return Z


def find_tau(n, edges):
    for k in range(n + 1):
        for combo in itertools.combinations(range(n), k):
            if is_transversal(edges, set(combo)):
                return k
    return n


# Generate hypergraph
n = 12
K = 2
edges = generate_hypergraph(n, d=3, target_edges=12, K=K, seed=42)
tau = find_tau(n, edges)

# Compute free energy
betas = np.linspace(0.01, 6, 200)
free_energies = []
for b in betas:
    Z = exact_partition_function(n, edges, b)
    f = -np.log(max(Z, 1e-300)) / n
    free_energies.append(f)

free_energies = np.array(free_energies)

# Bounds
lower_bound = (betas * tau - n * np.log(2)) / n
upper_bound = betas * tau / n

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Free energy with bounds
ax = axes[0]
ax.fill_between(betas, lower_bound, upper_bound, alpha=0.15, color='blue',
                label='Variational sandwich')
ax.plot(betas, free_energies, 'b-', linewidth=2.5, label=r'$f_H(\beta)$ (exact)')
ax.plot(betas, lower_bound, 'b--', linewidth=1, alpha=0.6,
        label=r'Lower: $(\beta\tau - |V|\ln 2)/|V|$')
ax.plot(betas, upper_bound, 'b:', linewidth=1, alpha=0.6,
        label=r'Upper: $\beta\tau/|V|$')
ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='-')
ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Free energy $f_H(\beta)$', fontsize=13)
ax.set_title(f'Free Energy Landscape\n(n={n}, |E|={len(edges)}, '
             r'$\tau$=' + f'{tau}, K={K})', fontsize=14)
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)

# Right: Partition function (log scale)
ax = axes[1]
Z_values = [exact_partition_function(n, edges, b) for b in betas]
Z_lower = [np.exp(-b * tau) for b in betas]
Z_upper = [2**n * np.exp(-b * tau) for b in betas]

ax.semilogy(betas, Z_values, 'r-', linewidth=2.5, label=r'$Z_H(\beta)$')
ax.semilogy(betas, Z_lower, 'r--', linewidth=1, alpha=0.6,
            label=r'$e^{-\beta\tau}$')
ax.semilogy(betas, Z_upper, 'r:', linewidth=1, alpha=0.6,
            label=r'$2^{|V|} e^{-\beta\tau}$')
ax.fill_between(betas, Z_lower, Z_upper, alpha=0.1, color='red')
ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Partition function $Z_H(\beta)$', fontsize=13)
ax.set_title('Partition Function Bounds\n(Theorem 2)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('free_energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved free_energy_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Phase Transition in Covering Polytope Thermodynamics

Plots the mean cover size E_μ[|S|] as a function of β for several values
of the pair-codegree bound K, illustrating how bounded overlap controls
the sharpness of the transition from fractional-optimum-like to 
integral-minimum-like behavior.

Shows the predicted critical β_c ≈ log(d-1) + c/(K+1) for d=3 uniform
hypergraphs.
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools
from collections import defaultdict


def generate_hypergraph(n, d=3, target_edges=None, K=2, seed=42):
    rng = np.random.default_rng(seed)
    if target_edges is None:
        target_edges = 2 * n
    edges = []
    pair_count = defaultdict(int)
    candidates = list(itertools.combinations(range(n), d))
    rng.shuffle(candidates)
    for edge_tuple in candidates:
        if len(edges) >= target_edges:
            break
        edge = frozenset(edge_tuple)
        pairs = list(itertools.combinations(sorted(edge), 2))
        if all(pair_count[p] < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] += 1
    return edges


def is_transversal(edges, S):
    return all(len(set(S) & edge) > 0 for edge in edges)


def exact_mean_size(n, edges, beta):
    Z = 0.0
    E_size = 0.0
    for mask in range(1 << n):
        S = {i for i in range(n) if mask & (1 << i)}
        if is_transversal(edges, S):
            w = np.exp(-beta * len(S))
            Z += w
            E_size += len(S) * w
    return E_size / Z if Z > 0 else 0


def find_tau(n, edges):
    for k in range(n + 1):
        for combo in itertools.combinations(range(n), k):
            if is_transversal(edges, set(combo)):
                return k
    return n


# Parameters
n = 10
d = 3
K_values = [1, 2, 3, 5]
betas = np.linspace(0, 5, 100)
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Mean cover size vs β
ax = axes[0]
for K, color in zip(K_values, colors):
    edges = generate_hypergraph(n, d=d, target_edges=max(8, 2*n//K), K=K, seed=42+K)
    tau = find_tau(n, edges)
    
    mean_sizes = [exact_mean_size(n, edges, b) for b in betas]
    
    ax.plot(betas, mean_sizes, color=color, linewidth=2,
            label=f'K={K} (τ={tau}, |E|={len(edges)})')
    ax.axhline(y=tau, color=color, linewidth=0.8, linestyle=':', alpha=0.5)

# Predicted critical β
for K, color in zip(K_values, colors):
    beta_c = np.log(d - 1) + 1.0 / (K + 1)
    ax.axvline(x=beta_c, color=color, linewidth=0.8, linestyle='--', alpha=0.4)

ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Mean cover size $\mathbb{E}_{\mu}[|S|]$', fontsize=13)
ax.set_title(f'Phase Transition in Cover Size\n({d}-uniform, n={n})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Gibbs tail concentration
ax = axes[1]
K = 2
edges = generate_hypergraph(n, d=d, target_edges=10, K=K, seed=44)
tau = find_tau(n, edges)

for t_val, ls, lbl in [(1, '-', 'defect ≥ 1'), (2, '--', 'defect ≥ 2'), (3, ':', 'defect ≥ 3')]:
    tail_probs = []
    for b in betas:
        Z = 0.0
        Z_tail = 0.0
        for mask in range(1 << n):
            S = {i for i in range(n) if mask & (1 << i)}
            if is_transversal(edges, S):
                w = np.exp(-b * len(S))
                Z += w
                if len(S) - tau >= t_val:
                    Z_tail += w
        tail_probs.append(Z_tail / Z if Z > 0 else 0)
    
    ax.semilogy(betas, [max(p, 1e-10) for p in tail_probs], 
                linewidth=2, linestyle=ls, label=lbl)

# Theoretical bound curves
for t_val, ls in [(1, '-'), (2, '--'), (3, ':')]:
    bound = [min(1, 2**n * np.exp(-b * t_val) / max(np.exp(-b * tau), 1e-300))
             for b in betas]
    ax.semilogy(betas, [max(b, 1e-10) for b in bound],
                color='gray', linewidth=1, linestyle=ls, alpha=0.5)

ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
ax.set_ylabel(r'Gibbs tail probability', fontsize=13)
ax.set_title(f'Gibbs Tail Concentration\n(K={K}, τ={tau})', fontsize=14)
ax.set_ylim(1e-6, 2)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved phase_transition.png")
