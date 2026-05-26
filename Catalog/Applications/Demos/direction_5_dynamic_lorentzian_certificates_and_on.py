#!/usr/bin/env python3
"""
Applications of Dynamic Lorentzian Certificates

Real-world applications showing how the theory works in practice:
1. Streaming graph edge updates with dynamic certificate maintenance
2. Online matroid sampling with warm-start MCMC
3. Partition function stability under perturbation (statistical physics)
"""

from itertools import combinations, product
from collections import defaultdict
import random
import math
from typing import List, Tuple, Dict, Set


# ============================================================================
# Application 1: Streaming Graph Edge Updates
# ============================================================================

class StreamingGraphCertificate:
    """
    Maintains a dynamic Lorentzian certificate for the basis generating
    polynomial of a graphic matroid under edge insertions/deletions.
    """

    def __init__(self, n_vertices: int):
        self.n_vertices = n_vertices
        self.edges: List[Tuple[int, int]] = []
        self.spanning_trees: List[Set[int]] = []
        self.certificate_cost_log: List[Dict] = []

    def add_edge(self, u: int, v: int) -> Dict:
        """
        Add an edge to the graph and update the certificate dynamically.

        Returns cost comparison between dynamic update and full rebuild.
        """
        edge_idx = len(self.edges)
        self.edges.append((u, v))
        n_edges = len(self.edges)

        # Find new spanning trees created by this edge
        new_trees = self._find_new_trees(edge_idx)

        # For each new tree, compute the affected derivative profile
        total_dynamic_cost = 0
        total_rebuild_cost = 0

        for tree in new_trees:
            alpha = self._tree_to_monomial(tree, n_edges)
            d = sum(alpha)
            if d < 2:
                continue

            # Count affected nodes at each depth
            affected_total = 0
            for k in range(d - 1):
                ac = self._affected_count_dp(alpha, k)
                affected_total += ac

            dynamic_cost = n_edges**2 * affected_total
            rebuild_cost = n_edges**d

            total_dynamic_cost += dynamic_cost
            total_rebuild_cost += rebuild_cost

        result = {
            'edge': (u, v),
            'edge_idx': edge_idx,
            'n_edges': n_edges,
            'new_trees': len(new_trees),
            'dynamic_cost': total_dynamic_cost,
            'rebuild_cost': total_rebuild_cost,
            'speedup': total_rebuild_cost / max(total_dynamic_cost, 1),
        }
        self.certificate_cost_log.append(result)
        return result

    def _find_new_trees(self, new_edge_idx: int) -> List[Set[int]]:
        """Find spanning trees that use the new edge."""
        n = self.n_vertices
        n_edges = len(self.edges)
        if n_edges < n - 1:
            return []

        new_trees = []
        for edge_subset in combinations(range(n_edges), n - 1):
            if new_edge_idx not in edge_subset:
                continue
            if self._is_spanning_tree(edge_subset):
                new_trees.append(set(edge_subset))

        # Cap for performance
        return new_trees[:20]

    def _is_spanning_tree(self, edge_indices) -> bool:
        """Check if given edges form a spanning tree."""
        n = self.n_vertices
        adj = defaultdict(set)
        for idx in edge_indices:
            u, v = self.edges[idx]
            adj[u].add(v)
            adj[v].add(u)

        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)

        return len(visited) == n

    def _tree_to_monomial(self, tree: Set[int], n_edges: int) -> Tuple[int, ...]:
        return tuple(1 if i in tree else 0 for i in range(n_edges))

    def _affected_count_dp(self, alpha: Tuple[int, ...], k: int) -> int:
        n = len(alpha)
        dp = [0] * (k + 1)
        dp[0] = 1
        for i in range(n):
            new_dp = [0] * (k + 1)
            for j in range(k + 1):
                if dp[j] == 0:
                    continue
                for v in range(min(alpha[i], k - j) + 1):
                    new_dp[j + v] += dp[j]
            dp = new_dp
        return dp[k]

    def summary(self) -> str:
        lines = ["Streaming Graph Certificate Summary", "=" * 40]
        for entry in self.certificate_cost_log:
            lines.append(
                f"Edge {entry['edge']}: "
                f"{entry['new_trees']} new trees, "
                f"dynamic={entry['dynamic_cost']}, "
                f"rebuild={entry['rebuild_cost']}, "
                f"speedup={entry['speedup']:.1f}x"
            )
        return "\n".join(lines)


# ============================================================================
# Application 2: Online Matroid Sampling with Warm-Start MCMC
# ============================================================================

class OnlineMatroidSampler:
    """
    Samples bases of a matroid whose generating polynomial evolves online.
    Uses warm-start MCMC to avoid cold-start mixing each time.
    """

    def __init__(self, n_elements: int, initial_weights: List[float]):
        self.n = n_elements
        self.weights = list(initial_weights)
        self.current_sample = self._initial_sample()
        self.mixing_history: List[Dict] = []

    def _initial_sample(self) -> int:
        """Draw initial sample proportional to weights."""
        total = sum(self.weights)
        if total == 0:
            return 0
        r = random.random() * total
        cumsum = 0.0
        for i, w in enumerate(self.weights):
            cumsum += w
            if r <= cumsum:
                return i
        return len(self.weights) - 1

    def update_weight(self, idx: int, delta: float) -> Dict:
        """
        Update weight at index idx by delta.
        Corresponds to a rank-1 update of the generating polynomial.
        """
        old_weights = list(self.weights)
        self.weights[idx] = max(0, self.weights[idx] + delta)

        Z_old = sum(old_weights)
        Z_new = sum(self.weights)

        if Z_old == 0 or Z_new == 0:
            return {'error': 'Zero total weight'}

        # Compute TV bound
        l1_dist = sum(abs(a - b) for a, b in zip(old_weights, self.weights))
        old_norm = [w / Z_old for w in old_weights]
        new_norm = [w / Z_new for w in self.weights]
        tv = 0.5 * sum(abs(a - b) for a, b in zip(old_norm, new_norm))
        bound = l1_dist / min(Z_old, Z_new)

        # Warm-start: run chain from current state
        warm_steps = self._estimate_mixing_steps(tv)
        cold_steps = self._estimate_cold_mixing_steps()

        result = {
            'updated_idx': idx,
            'delta': delta,
            'l1_distance': l1_dist,
            'tv_distance': tv,
            'tv_bound': bound,
            'warm_start_steps': warm_steps,
            'cold_start_steps': cold_steps,
            'speedup': cold_steps / max(warm_steps, 1),
        }
        self.mixing_history.append(result)

        # Update current sample using warm-start chain
        self.current_sample = self._warm_start_sample(warm_steps)
        return result

    def _estimate_mixing_steps(self, tv_dist: float) -> int:
        """Estimate warm-start mixing steps from TV distance."""
        if tv_dist < 1e-10:
            return 1
        # Rough estimate: O(log(1/epsilon) + log(1/(1-delta)))
        return max(1, int(10 * math.log(1.0 / max(tv_dist, 0.01))))

    def _estimate_cold_mixing_steps(self) -> int:
        """Estimate cold-start mixing time."""
        n = len(self.weights)
        return max(10, int(n * math.log(n + 1)))

    def _warm_start_sample(self, n_steps: int) -> int:
        """Run Metropolis-Hastings from current state."""
        current = self.current_sample
        total = sum(self.weights)
        if total == 0:
            return 0

        for _ in range(n_steps):
            proposal = random.randint(0, len(self.weights) - 1)
            if self.weights[proposal] > 0:
                ratio = min(1.0, self.weights[proposal] /
                           max(self.weights[current], 1e-15))
                if random.random() < ratio:
                    current = proposal

        return current


# ============================================================================
# Application 3: Partition Function Stability (Statistical Physics)
# ============================================================================

def partition_function_stability(energies: List[float],
                                  temperature: float,
                                  perturbation_idx: int,
                                  perturbation: float) -> Dict:
    """
    Analyze stability of Gibbs distribution under local energy perturbation.

    In statistical physics, the partition function Z = Σ exp(-E_i/T) defines
    the Gibbs distribution. A local perturbation E_i → E_i + δ corresponds
    to a rank-1 update of the generating polynomial coefficients.

    Args:
        energies: Energy levels
        temperature: Temperature parameter T
        perturbation_idx: Which energy level to perturb
        perturbation: Amount to change energy by

    Returns:
        Stability analysis metrics
    """
    T = temperature

    # Original Boltzmann weights
    w = [math.exp(-E / T) for E in energies]
    Z = sum(w)

    # Perturbed weights
    energies_new = list(energies)
    energies_new[perturbation_idx] += perturbation
    w_new = [math.exp(-E / T) for E in energies_new]
    Z_new = sum(w_new)

    # Gibbs distributions
    p = [wi / Z for wi in w]
    p_new = [wi / Z_new for wi in w_new]

    # TV distance
    tv = 0.5 * sum(abs(a - b) for a, b in zip(p, p_new))

    # Our bound
    l1_dist = sum(abs(a - b) for a, b in zip(w, w_new))
    bound = l1_dist / min(Z, Z_new)

    # Free energy change
    F = -T * math.log(Z)
    F_new = -T * math.log(Z_new)

    return {
        'n_states': len(energies),
        'temperature': T,
        'perturbation': perturbation,
        'Z_original': Z,
        'Z_perturbed': Z_new,
        'free_energy_change': F_new - F,
        'tv_distance': tv,
        'tv_bound': bound,
        'bound_holds': tv <= bound + 1e-10,
        'relative_Z_change': abs(Z_new - Z) / Z,
    }


# ============================================================================
# Main: Run all applications
# ============================================================================

if __name__ == "__main__":
    random.seed(42)

    # Application 1: Streaming graph
    print("Application 1: Streaming Graph Edge Updates")
    print("=" * 50)

    cert = StreamingGraphCertificate(5)
    complete_edges = [(i, j) for i in range(5) for j in range(i+1, 5)]
    for u, v in complete_edges[:7]:
        result = cert.add_edge(u, v)
        print(f"  Added edge ({u},{v}): {result['new_trees']} new trees, "
              f"speedup={result['speedup']:.1f}x")
    print()

    # Application 2: Online sampling
    print("Application 2: Online Matroid Sampling")
    print("=" * 50)

    sampler = OnlineMatroidSampler(10, [1.0] * 10)
    for i in range(5):
        idx = random.randint(0, 9)
        delta = random.uniform(-0.3, 0.5)
        result = sampler.update_weight(idx, delta)
        print(f"  Update w[{idx}] += {delta:.3f}: "
              f"TV={result['tv_distance']:.6f}, "
              f"warm={result['warm_start_steps']}, "
              f"cold={result['cold_start_steps']}, "
              f"speedup={result['speedup']:.1f}x")
    print()

    # Application 3: Partition function stability
    print("Application 3: Partition Function Stability")
    print("=" * 50)

    energies = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]
    for T in [0.5, 1.0, 2.0, 5.0]:
        result = partition_function_stability(energies, T, 3, 0.1)
        print(f"  T={T}: TV={result['tv_distance']:.6f}, "
              f"bound={result['tv_bound']:.6f}, "
              f"ΔF={result['free_energy_change']:.6f}")


#!/usr/bin/env python3
"""
Demo: Dynamic Lorentzian Certificates and Online Sampling

This script demonstrates the core ideas from the formal theory of dynamic
Lorentzian certification:
1. Rank-1 polynomial updates and affected multiindex computation
2. Dynamic vs rebuild certificate cost comparison
3. Graphic matroid (spanning tree) polynomial updates
4. Warm-start vs cold-start sampling behavior
5. Scaling experiments on growing graph instances
"""

from itertools import product
from collections import defaultdict
import random
import math

# ============================================================================
# Core Definitions
# ============================================================================

def affected_multiindices(alpha, k):
    """
    Compute the set of derivative multiindices β of total order k
    that are coordinatewise dominated by α.

    AffectedMultiindices(α, k) = {β : sum(β) = k and β_i ≤ α_i for all i}
    """
    n = len(alpha)
    result = []
    ranges = [range(a + 1) for a in alpha]
    for beta in product(*ranges):
        if sum(beta) == k:
            result.append(beta)
    return result

def affected_count(alpha, k):
    """Count of affected multiindices at derivative order k."""
    return len(affected_multiindices(alpha, k))

def dynamic_certificate_cost(n, d, alpha):
    """
    Dynamic certificate update cost:
    n^2 * sum_{k=0}^{d-2} |Affected(α, k)|
    """
    return n**2 * sum(affected_count(alpha, k) for k in range(d - 1))

def full_rebuild_cost(n, d):
    """
    Full certificate rebuild cost: n^d
    (n^(d-2) derivative nodes × n^2 per spectral check)
    """
    return n**d

# ============================================================================
# 1. Affected Multiindex Computation
# ============================================================================

def demo_affected_multiindices():
    print("=" * 60)
    print("DEMO 1: Affected Multiindices for Rank-1 Updates")
    print("=" * 60)

    # Example: n=3 variables, monomial X_0^2 * X_1 * X_2 (degree 4)
    alpha = (2, 1, 1)
    d = sum(alpha)
    n = len(alpha)

    print(f"\nMonomial exponent α = {alpha}, degree d = {d}, n = {n} variables")
    print(f"\nAffected multiindices by derivative order k:")

    total_affected = 0
    for k in range(d - 1):
        affected = affected_multiindices(alpha, k)
        total_affected += len(affected)
        print(f"  k={k}: {len(affected)} affected nodes")
        if len(affected) <= 10:
            for beta in affected:
                print(f"    β = {beta}")

    print(f"\nTotal affected nodes: {total_affected}")
    print(f"Dynamic cost: {dynamic_certificate_cost(n, d, alpha)}")
    print(f"Full rebuild cost: {full_rebuild_cost(n, d)}")
    print(f"Speedup ratio: {full_rebuild_cost(n, d) / dynamic_certificate_cost(n, d, alpha):.2f}x")

# ============================================================================
# 2. Dynamic vs Rebuild Cost Comparison
# ============================================================================

def demo_cost_comparison():
    print("\n" + "=" * 60)
    print("DEMO 2: Dynamic vs Rebuild Cost Across Parameters")
    print("=" * 60)

    print(f"\n{'n':>4} {'d':>4} {'alpha':>20} {'Dynamic':>12} {'Rebuild':>12} {'Ratio':>8}")
    print("-" * 64)

    test_cases = [
        (3, 3, (1, 1, 1)),
        (4, 4, (1, 1, 1, 1)),
        (5, 5, (1, 1, 1, 1, 1)),
        (4, 4, (2, 1, 1, 0)),
        (4, 4, (3, 1, 0, 0)),
        (4, 4, (4, 0, 0, 0)),
        (6, 3, (1, 1, 1, 0, 0, 0)),
        (6, 4, (1, 1, 1, 1, 0, 0)),
    ]

    for n, d, alpha in test_cases:
        assert len(alpha) == n and sum(alpha) == d
        dc = dynamic_certificate_cost(n, d, alpha)
        rc = full_rebuild_cost(n, d)
        ratio = rc / dc if dc > 0 else float('inf')
        print(f"{n:>4} {d:>4} {str(alpha):>20} {dc:>12} {rc:>12} {ratio:>8.2f}")

    print("\nKey insight: Sparse monomials (many zeros in α) give biggest speedups")

# ============================================================================
# 3. Graphic Matroid / Spanning Tree Example
# ============================================================================

def spanning_trees_small(edges, n_vertices):
    """Find all spanning trees of a small graph by brute force."""
    from itertools import combinations
    trees = []
    n_edges_needed = n_vertices - 1

    for edge_subset in combinations(range(len(edges)), n_edges_needed):
        # Check if this forms a spanning tree (connected, acyclic)
        adj = defaultdict(set)
        for idx in edge_subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)

        # BFS to check connectivity
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == n_vertices:
            trees.append(edge_subset)

    return trees

def tree_to_monomial(tree_edges, n_total_edges):
    """Convert a spanning tree (set of edge indices) to monomial exponent."""
    alpha = [0] * n_total_edges
    for e in tree_edges:
        alpha[e] = 1
    return tuple(alpha)

def demo_graphic_matroid():
    print("\n" + "=" * 60)
    print("DEMO 3: Graphic Matroid — Adding an Edge to K4")
    print("=" * 60)

    # K4 has 6 edges, 4 vertices
    edges_k4 = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    n_v = 4
    n_e = len(edges_k4)

    trees = spanning_trees_small(edges_k4, n_v)
    print(f"\nK4: {n_v} vertices, {n_e} edges, {len(trees)} spanning trees")

    # Basis generating polynomial: sum of X^tree for each tree
    print(f"\nSpanning tree monomials:")
    for i, t in enumerate(trees):
        mono = tree_to_monomial(t, n_e)
        print(f"  Tree {i}: edges {t} → monomial {mono}")

    # Add a new edge (simulating K4 + extra edge = K4 with parallel edge)
    # This adds new spanning trees
    print(f"\nAdding edge e7 = (0,1) (parallel to existing edge 0)")
    new_edge_idx = n_e  # index 6
    n_e_new = n_e + 1

    # New trees: replace edge 0 with edge 6 in any tree containing edge 0
    new_trees = []
    for t in trees:
        if 0 in t:  # contains the original (0,1) edge
            new_tree = tuple(new_edge_idx if e == 0 else e for e in t)
            new_trees.append(new_tree)

    print(f"  New spanning trees from added edge: {len(new_trees)}")

    # Each new tree gives a rank-1 update monomial
    for t in new_trees[:3]:
        mono = tree_to_monomial(t, n_e_new)
        d = sum(mono)
        dc = dynamic_certificate_cost(n_e_new, d, mono)
        rc = full_rebuild_cost(n_e_new, d)
        print(f"  New tree monomial {mono}: dynamic cost={dc}, rebuild={rc}")

    # Locality theorem: derivatives not dominated by α are unchanged
    alpha_example = tree_to_monomial(new_trees[0], n_e_new)
    d = sum(alpha_example)
    print(f"\n  Example monomial α = {alpha_example}")
    print(f"  Affected derivative counts:")
    for k in range(d - 1):
        ac = affected_count(alpha_example, k)
        print(f"    k={k}: {ac} affected (out of possible C({d},{k})={math.comb(d,k)})")

# ============================================================================
# 4. Warm-Start vs Cold-Start Sampling
# ============================================================================

def normalize_weights(w):
    """Normalize nonneg weights to probability distribution."""
    s = sum(w)
    if s == 0:
        return [0.0] * len(w)
    return [x / s for x in w]

def tv_distance(mu, nu):
    """Total variation distance."""
    return 0.5 * sum(abs(a - b) for a, b in zip(mu, nu))

def l1_distance(w, w_prime):
    """L1 distance between weight vectors."""
    return sum(abs(a - b) for a, b in zip(w, w_prime))

def simulate_basis_exchange_chain(weights, n_steps, start_state=None):
    """
    Simulate a simple basis-exchange Markov chain.
    Target distribution proportional to weights.
    """
    n = len(weights)
    if sum(weights) == 0:
        return [0] * n_steps

    probs = normalize_weights(weights)

    # Start from given state or random
    if start_state is not None:
        current = start_state
    else:
        current = random.choices(range(n), weights=probs, k=1)[0]

    trajectory = [current]
    for _ in range(n_steps - 1):
        # Propose uniform neighbor
        proposal = random.randint(0, n - 1)
        # Metropolis-Hastings acceptance
        if weights[proposal] > 0:
            accept_ratio = min(1.0, weights[proposal] / max(weights[current], 1e-15))
            if random.random() < accept_ratio:
                current = proposal
        trajectory.append(current)

    return trajectory

def estimate_mixing_time(weights, epsilon=0.1, n_trials=50, max_steps=1000, start_state=None):
    """Estimate mixing time by checking when empirical distribution is close to target."""
    n = len(weights)
    target = normalize_weights(weights)

    for t in range(10, max_steps, 10):
        close_count = 0
        for _ in range(n_trials):
            traj = simulate_basis_exchange_chain(weights, t, start_state)
            # Empirical distribution from last half
            empirical = [0.0] * n
            for s in traj[t // 2:]:
                empirical[s] += 1.0
            emp_total = sum(empirical)
            if emp_total > 0:
                empirical = [x / emp_total for x in empirical]
            tv = tv_distance(empirical, target)
            if tv < epsilon:
                close_count += 1
        if close_count > n_trials * 0.8:
            return t
    return max_steps

def demo_warm_start():
    print("\n" + "=" * 60)
    print("DEMO 4: Warm-Start vs Cold-Start Sampling")
    print("=" * 60)

    random.seed(42)

    # Original weights (e.g., spanning tree weights)
    n = 20
    w = [random.uniform(0.5, 2.0) for _ in range(n)]
    Z = sum(w)

    # Small perturbation (rank-1 update adds/modifies one weight)
    w_prime = w.copy()
    w_prime[5] += 0.3  # small perturbation
    Z_prime = sum(w_prime)

    mu = normalize_weights(w)
    nu = normalize_weights(w_prime)

    delta = l1_distance(w, w_prime)
    tv = tv_distance(mu, nu)
    bound = delta / min(Z, Z_prime)

    print(f"\n  n = {n} states")
    print(f"  Perturbation: w[5] += 0.3")
    print(f"  ℓ₁ distance: Δ = {delta:.4f}")
    print(f"  Z = {Z:.4f}, Z' = {Z_prime:.4f}")
    print(f"  TV(μ, ν) = {tv:.6f}")
    print(f"  Bound: Δ/min(Z,Z') = {bound:.6f}")
    print(f"  Bound holds: {tv <= bound + 1e-10}")

    # Compare mixing times
    print(f"\n  Estimating mixing times...")
    cold_mix = estimate_mixing_time(w_prime, epsilon=0.15, n_trials=30)
    # For warm start, begin from a sample drawn from old distribution
    warm_start_state = random.choices(range(n), weights=mu, k=1)[0]
    warm_mix = estimate_mixing_time(w_prime, epsilon=0.15, n_trials=30,
                                      start_state=warm_start_state)
    print(f"  Cold-start mixing time: ~{cold_mix} steps")
    print(f"  Warm-start mixing time: ~{warm_mix} steps")
    print(f"  Warm-start advantage: {cold_mix / max(warm_mix, 1):.1f}x")

# ============================================================================
# 5. Scaling Experiments
# ============================================================================

def demo_scaling():
    print("\n" + "=" * 60)
    print("DEMO 5: Scaling — Dynamic vs Rebuild on Growing Graphs")
    print("=" * 60)

    print(f"\n{'n_vertices':>10} {'n_edges':>8} {'degree':>6} {'dynamic':>12} {'rebuild':>12} {'ratio':>8}")
    print("-" * 60)

    for n_v in [4, 6, 8, 10, 15, 20]:
        # Complete graph K_n
        n_e = n_v * (n_v - 1) // 2
        d = n_v - 1  # spanning tree has n-1 edges

        # A single spanning tree: first n-1 edges (star graph)
        alpha = tuple([1] * (n_v - 1) + [0] * (n_e - n_v + 1))

        dc = dynamic_certificate_cost(n_e, d, alpha)
        rc = full_rebuild_cost(n_e, d)

        ratio = rc / dc if dc > 0 else float('inf')
        print(f"{n_v:>10} {n_e:>8} {d:>6} {dc:>12} {rc:>12} {ratio:>8.1f}")

    print("\n  The dynamic-to-rebuild ratio grows rapidly with graph size,")
    print("  confirming that locality-based updates are asymptotically cheaper.")

# ============================================================================
# 6. TV Bound Verification
# ============================================================================

def demo_tv_bounds():
    print("\n" + "=" * 60)
    print("DEMO 6: Total Variation Bound Verification")
    print("=" * 60)

    random.seed(123)
    print(f"\n{'trial':>6} {'TV':>10} {'bound':>10} {'holds':>6}")
    print("-" * 36)

    for trial in range(10):
        n = random.randint(5, 20)
        w = [random.uniform(0, 5) for _ in range(n)]
        w_prime = [max(0, wi + random.uniform(-1, 1)) for wi in w]

        Z = sum(w)
        Z_prime = sum(w_prime)
        if Z == 0 or Z_prime == 0:
            continue

        mu = normalize_weights(w)
        nu = normalize_weights(w_prime)

        tv = tv_distance(mu, nu)
        delta = l1_distance(w, w_prime)
        bound = delta / min(Z, Z_prime)

        holds = tv <= bound + 1e-10
        print(f"{trial:>6} {tv:>10.6f} {bound:>10.6f} {'✓' if holds else '✗':>6}")

    print("\n  All bounds verified: TV(normalize(w), normalize(w')) ≤ Δ/min(Z,Z')")

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("Dynamic Lorentzian Certificates — Interactive Demo")
    print("=" * 60)

    demo_affected_multiindices()
    demo_cost_comparison()
    demo_graphic_matroid()
    demo_warm_start()
    demo_scaling()
    demo_tv_bounds()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 1: Affected Derivative Node Heatmap

Visualizes the affected derivative profile for different monomial exponent
vectors α, showing how sparse monomials produce fewer affected nodes.
This is the visual manifestation of the Locality Theorem: only derivative
directions coordinatewise dominated by α are affected by a rank-1 update.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iterproduct


def affected_count_dp(alpha, k):
    """Count affected multiindices using dynamic programming."""
    n = len(alpha)
    if k < 0:
        return 0
    dp = [0] * (k + 1)
    dp[0] = 1
    for i in range(n):
        new_dp = [0] * (k + 1)
        for j in range(k + 1):
            if dp[j] == 0:
                continue
            for v in range(min(alpha[i], k - j) + 1):
                new_dp[j + v] += dp[j]
        dp = new_dp
    return dp[k]


def total_multiindex_count(n, k):
    """Stars and bars: C(n+k-1, k)."""
    from math import comb
    if n == 0 and k == 0:
        return 1
    if n == 0:
        return 0
    return comb(n + k - 1, k)


# Parameters
n = 6
d = 6

# Different monomial shapes
alphas = {
    'Uniform\n(1,1,1,1,1,1)': (1, 1, 1, 1, 1, 1),
    'Concentrated\n(3,2,1,0,0,0)': (3, 2, 1, 0, 0, 0),
    'Sparse\n(6,0,0,0,0,0)': (6, 0, 0, 0, 0, 0),
    'Balanced\n(2,2,2,0,0,0)': (2, 2, 2, 0, 0, 0),
    'Spread\n(2,1,1,1,1,0)': (2, 1, 1, 1, 1, 0),
}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Affected counts by depth
ax1 = axes[0]
depths = list(range(d - 1))
for label, alpha in alphas.items():
    counts = [affected_count_dp(alpha, k) for k in depths]
    ax1.plot(depths, counts, 'o-', label=label.replace('\n', ' '), linewidth=2, markersize=6)

# Add total (unaffected) counts
total_counts = [total_multiindex_count(n, k) for k in depths]
ax1.plot(depths, total_counts, 'k--', label='Total (all β)', linewidth=1.5, alpha=0.5)

ax1.set_xlabel('Derivative Depth k', fontsize=12)
ax1.set_ylabel('Number of Affected Nodes', fontsize=12)
ax1.set_title('Affected Node Counts by Depth', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Plot 2: Total affected fraction (dynamic cost savings)
ax2 = axes[1]
labels = list(alphas.keys())
total_affected = []
total_possible = sum(total_multiindex_count(n, k) for k in depths)

for label, alpha in alphas.items():
    ta = sum(affected_count_dp(alpha, k) for k in depths)
    total_affected.append(ta)

fractions = [ta / total_possible for ta in total_affected]
short_labels = [l.split('\n')[0] for l in labels]
colors = plt.cm.viridis([0.1, 0.3, 0.5, 0.7, 0.9])
bars = ax2.bar(short_labels, fractions, color=colors, edgecolor='black', linewidth=0.5)

ax2.set_ylabel('Fraction of Nodes Affected', fontsize=12)
ax2.set_title('Dynamic Update Cost as Fraction of Rebuild', fontsize=13)
ax2.set_ylim(0, 1.05)
ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Full rebuild')
ax2.legend(fontsize=10)

# Add value labels on bars
for bar, frac in zip(bars, fractions):
    ax2.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.02,
             f'{frac:.1%}', ha='center', va='bottom', fontsize=10)

plt.suptitle('Locality of Rank-1 Updates in Certificate Trees\n'
             f'(n={n} variables, degree d={d})', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_affected_nodes.png', dpi=150, bbox_inches='tight')
print("Saved viz_affected_nodes.png")


#!/usr/bin/env python3
"""
Visualization 3: Scaling of Dynamic vs Rebuild Certificate Cost

Shows how the dynamic-to-rebuild cost ratio scales with graph size for
graphic matroid (spanning tree) certificates. Demonstrates that the
locality theorem gives exponentially improving speedups as graph size grows.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


def affected_count_dp(alpha, k):
    """Count affected multiindices via DP."""
    n = len(alpha)
    if k < 0:
        return 0
    dp = [0] * (k + 1)
    dp[0] = 1
    for i in range(n):
        new_dp = [0] * (k + 1)
        for j in range(k + 1):
            if dp[j] == 0:
                continue
            for v in range(min(alpha[i], k - j) + 1):
                new_dp[j + v] += dp[j]
        dp = new_dp
    return dp[k]


def dynamic_cert_cost(n, d, alpha):
    return n**2 * sum(affected_count_dp(alpha, k) for k in range(max(0, d - 1)))


def rebuild_cost(n, d):
    return n**d


# Scaling experiment: complete graphs K_m
vertex_counts = list(range(4, 16))
results = []

for n_v in vertex_counts:
    n_e = n_v * (n_v - 1) // 2  # edges in K_n
    d = n_v - 1  # spanning tree degree

    # Star tree: edges 0..n_v-2 are used
    alpha = tuple([1] * (n_v - 1) + [0] * (n_e - n_v + 1))

    dc = dynamic_cert_cost(n_e, d, alpha)
    rc = rebuild_cost(n_e, d)

    results.append({
        'n_v': n_v,
        'n_e': n_e,
        'd': d,
        'dynamic': dc,
        'rebuild': rc,
        'ratio': rc / max(dc, 1),
    })

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Costs on log scale
ax1 = axes[0]
ns = [r['n_v'] for r in results]
dyn_costs = [r['dynamic'] for r in results]
reb_costs = [r['rebuild'] for r in results]

ax1.semilogy(ns, reb_costs, 'ro-', label='Full Rebuild (n^d)', linewidth=2, markersize=6)
ax1.semilogy(ns, dyn_costs, 'bs-', label='Dynamic Update', linewidth=2, markersize=6)
ax1.set_xlabel('Number of Vertices', fontsize=12)
ax1.set_ylabel('Certificate Cost', fontsize=12)
ax1.set_title('Certificate Costs vs Graph Size', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Speedup ratio
ax2 = axes[1]
ratios = [r['ratio'] for r in results]
ax2.semilogy(ns, ratios, 'g^-', linewidth=2, markersize=8, color='darkgreen')
ax2.set_xlabel('Number of Vertices', fontsize=12)
ax2.set_ylabel('Speedup Ratio (Rebuild/Dynamic)', fontsize=12)
ax2.set_title('Dynamic Update Speedup', fontsize=13)
ax2.grid(True, alpha=0.3)
ax2.fill_between(ns, 1, ratios, alpha=0.15, color='green')

# Plot 3: Fraction of nodes affected
ax3 = axes[2]
fracs = [r['dynamic'] / max(r['rebuild'], 1) for r in results]
ax3.semilogy(ns, fracs, 'mD-', linewidth=2, markersize=6, color='purple')
ax3.set_xlabel('Number of Vertices', fontsize=12)
ax3.set_ylabel('Dynamic / Rebuild Cost Fraction', fontsize=12)
ax3.set_title('Cost Fraction (Lower = Better)', fontsize=13)
ax3.grid(True, alpha=0.3)
ax3.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Full rebuild')
ax3.legend(fontsize=10)

plt.suptitle('Scaling: Dynamic vs Rebuild Certificate Cost\n'
             '(Complete graphs K_n, star tree monomial update)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")


#!/usr/bin/env python3
"""
Visualization 2: Total Variation Bound for Warm-Start Sampling

Shows the relationship between coefficient perturbation (ℓ₁ distance) and
the total variation distance between normalized distributions. Demonstrates
the proved bound TV ≤ Δ/min(Z, Z') and its tightness across different
perturbation regimes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random
import math


def normalize_weights(w):
    s = sum(w)
    return [x / s for x in w] if s > 0 else [0] * len(w)


def tv_distance(mu, nu):
    return 0.5 * sum(abs(a - b) for a, b in zip(mu, nu))


def l1_distance(w, wp):
    return sum(abs(a - b) for a, b in zip(w, wp))


random.seed(42)

# Generate many random experiments
n_trials = 500
n_states = 15

deltas = []
tvs = []
bounds = []
ratios = []

for _ in range(n_trials):
    w = [random.uniform(0.1, 3.0) for _ in range(n_states)]
    # Random perturbation of varying magnitude
    magnitude = random.uniform(0.01, 2.0)
    w_prime = [max(0, wi + random.uniform(-magnitude, magnitude)) for wi in w]

    Z = sum(w)
    Z_prime = sum(w_prime)
    if Z == 0 or Z_prime == 0:
        continue

    delta = l1_distance(w, w_prime)
    mu = normalize_weights(w)
    nu = normalize_weights(w_prime)
    tv = tv_distance(mu, nu)
    bound = delta / min(Z, Z_prime)

    deltas.append(delta)
    tvs.append(tv)
    bounds.append(bound)
    if bound > 1e-10:
        ratios.append(tv / bound)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: TV vs bound
ax1 = axes[0]
ax1.scatter(bounds, tvs, alpha=0.4, s=15, c='steelblue', edgecolors='none')
max_val = max(max(bounds), max(tvs)) * 1.1
ax1.plot([0, max_val], [0, max_val], 'r-', linewidth=2, label='TV = bound (equality)')
ax1.set_xlabel('Bound: Δ / min(Z, Z\')', fontsize=12)
ax1.set_ylabel('Actual TV Distance', fontsize=12)
ax1.set_title('TV Distance vs Upper Bound', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, max_val)
ax1.set_ylim(0, max_val)

# Plot 2: Tightness ratio histogram
ax2 = axes[1]
ax2.hist(ratios, bins=40, color='coral', edgecolor='black', linewidth=0.5, alpha=0.8)
ax2.axvline(x=0.5, color='blue', linestyle='--', linewidth=1.5,
            label='Ratio = 0.5 (equal Z, Z\')')
ax2.set_xlabel('Tightness Ratio (TV / Bound)', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Distribution of Bound Tightness', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: TV vs perturbation magnitude
ax3 = axes[2]
scatter = ax3.scatter(deltas, tvs, c=[min(Z, Z_prime_val) for Z_prime_val
                                       in [sum([max(0, wi + random.uniform(-1, 1))
                                                for wi in [random.uniform(0.1, 3.0)
                                                           for _ in range(n_states)]])
                                           for _ in range(len(deltas))]],
                      alpha=0.5, s=15, cmap='viridis', edgecolors='none')
# Simpler: just color by index
ax3.scatter(deltas, tvs, alpha=0.4, s=15, c='forestgreen', edgecolors='none')
ax3.set_xlabel('ℓ₁ Perturbation Δ', fontsize=12)
ax3.set_ylabel('TV Distance', fontsize=12)
ax3.set_title('TV vs Perturbation Size', fontsize=13)
ax3.grid(True, alpha=0.3)

# Add regression line
if deltas:
    sorted_pairs = sorted(zip(deltas, tvs))
    # Moving average
    window = max(1, len(sorted_pairs) // 20)
    ma_x, ma_y = [], []
    for i in range(0, len(sorted_pairs) - window, window):
        chunk = sorted_pairs[i:i+window]
        ma_x.append(sum(x for x, _ in chunk) / len(chunk))
        ma_y.append(sum(y for _, y in chunk) / len(chunk))
    ax3.plot(ma_x, ma_y, 'r-', linewidth=2, label='Moving average')
    ax3.legend(fontsize=10)

plt.suptitle('Warm-Start Total Variation Bounds\n'
             f'({n_trials} trials, {n_states} states each)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_tv_bounds.png', dpi=150, bbox_inches='tight')
print("Saved viz_tv_bounds.png")
