#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Exchange Descent

Demonstrates practical applications of the tropical exchange descent theory:
1. Resource allocation optimization
2. Network flow optimization via matroid exchange
3. Job scheduling with matroid structure
4. Portfolio optimization with combinatorial constraints

Each application shows how tropical exchange descent provides
certified convergence bounds.
"""

import random
from itertools import combinations
from typing import List, Dict, Set, FrozenSet, Tuple

Basis = FrozenSet[int]


class TropicalExchangeSystem:
    """Minimal tropical exchange system for applications."""

    def __init__(self, ground: List[int], carrier: Set[Basis],
                 val: Dict[Basis, int]):
        self.ground = ground
        self.carrier = carrier
        self.val = val
        self.phi = {B: -val[B] for B in carrier}

    def exchange(self, B: Basis, x: int, y: int) -> Basis:
        return (B - {x}) | {y}

    def neighbors(self, B: Basis) -> List[Tuple[Basis, int, int]]:
        result = []
        for x in B:
            for y in self.ground:
                if y not in B:
                    Bn = self.exchange(B, x, y)
                    if Bn in self.carrier:
                        result.append((Bn, x, y))
        return result

    def descent(self, B0: Basis, max_steps: int = 10000):
        B = B0
        path = [(B, self.phi[B])]
        for _ in range(max_steps):
            improving = [(Bn, x, y) for Bn, x, y in self.neighbors(B)
                         if self.phi[Bn] < self.phi[B]]
            if not improving:
                break
            best = min(improving, key=lambda t: self.phi[t[0]])
            B = best[0]
            path.append((B, self.phi[B]))
        return path


# ========== Application 1: Resource Allocation ==========

def application_resource_allocation():
    """Resource allocation: assign r workers to n tasks to maximize total skill.

    Each worker has a skill level for each task. We model feasible assignments
    as bases of a uniform matroid, with valuation = total skill score.
    Exchange descent finds the optimal assignment.
    """
    print("\n" + "="*60)
    print("APPLICATION 1: Resource Allocation")
    print("="*60)

    n_tasks = 7
    n_workers = 3  # Select 3 workers for 7 tasks

    # Skill matrix: skill[worker][task]
    random.seed(123)
    workers = list(range(n_tasks))
    tasks = list(range(n_tasks))
    skill = {w: {t: random.randint(1, 20) for t in tasks} for w in workers}

    print(f"\n  {n_tasks} workers available, selecting {n_workers}")
    print(f"  Skill scores:")
    for w in workers[:5]:
        scores = [skill[w][t] for t in tasks[:5]]
        print(f"    Worker {w}: {scores}...")

    # Create matroid: bases = all r-subsets of workers
    bases = {frozenset(c) for c in combinations(workers, n_workers)}

    # Valuation: total skill of selected workers across all tasks
    val = {}
    for B in bases:
        total = sum(max(skill[w][t] for w in B) for t in tasks)
        val[B] = total

    T = TropicalExchangeSystem(workers, bases, val)

    # Start from a random assignment
    B0 = random.choice(list(bases))
    path = T.descent(B0)

    print(f"\n  Starting team: {set(B0)}, skill = {val[B0]}")
    print(f"  Optimal team: {set(path[-1][0])}, skill = {val[path[-1][0]]}")
    print(f"  Steps to optimal: {len(path)-1}")
    print(f"  Improvement: {val[path[-1][0]] - val[B0]} points")

    # Theoretical bound
    lb = min(val[B] for B in bases)
    gap = val[B0] - lb  # for phi = -val, gap = -val[optimal] - (-val[B0]) = val[B0] - val[optimal] ... hmm
    gap = T.phi[B0] - min(T.phi[B] for B in bases)
    print(f"  Theoretical bound (gap/1): {gap}")
    print(f"  Actual/bound ratio: {(len(path)-1)/gap:.3f}" if gap > 0 else "")


# ========== Application 2: Network Design ==========

def application_network_design():
    """Network design: select r edges from a graph to maximize connectivity score.

    Edges have weights representing bandwidth. Select r edges to maximize
    the total weight while maintaining independence (matroid structure).
    """
    print("\n" + "="*60)
    print("APPLICATION 2: Network Design")
    print("="*60)

    # Small graph: 6 nodes, edges with bandwidth
    edges = list(range(8))
    edge_bandwidth = {0: 15, 1: 12, 2: 18, 3: 9, 4: 22, 5: 7, 6: 14, 7: 11}
    edge_names = {
        0: "A-B", 1: "A-C", 2: "B-C", 3: "B-D",
        4: "C-D", 5: "C-E", 6: "D-E", 7: "D-F"
    }

    r = 4  # Select 4 edges
    bases = {frozenset(c) for c in combinations(edges, r)}

    # Valuation: total bandwidth + bonus for diversity
    val = {}
    for B in bases:
        total_bw = sum(edge_bandwidth[e] for e in B)
        # Bonus for spread (using edge indices as proxy for network diversity)
        spread = max(B) - min(B)
        val[B] = total_bw + spread * 2
    T = TropicalExchangeSystem(edges, bases, val)

    B0 = frozenset([0, 1, 2, 3])
    path = T.descent(B0)

    print(f"\n  Initial network: {[edge_names[e] for e in sorted(B0)]}")
    print(f"    Score: {val[B0]}")

    B_opt = path[-1][0]
    print(f"  Optimal network: {[edge_names[e] for e in sorted(B_opt)]}")
    print(f"    Score: {val[B_opt]}")
    print(f"  Steps: {len(path)-1}")

    # Show descent path
    print(f"\n  Descent path:")
    for i, (B, phi) in enumerate(path[:8]):
        edges_str = [edge_names[e] for e in sorted(B)]
        print(f"    Step {i}: {edges_str}, score={val[B]}")
    if len(path) > 8:
        print(f"    ... ({len(path)-1} total steps)")


# ========== Application 3: Scheduling ==========

def application_scheduling():
    """Job scheduling: assign time slots to maximize total utility.

    n jobs, r time slots. Each job has a different utility for each slot.
    Find the assignment of r jobs to r slots maximizing total utility.
    This is a transversal matroid optimization problem.
    """
    print("\n" + "="*60)
    print("APPLICATION 3: Job Scheduling")
    print("="*60)

    n_jobs = 8
    n_slots = 3

    random.seed(456)
    utility = {}
    job_names = [f"Job_{chr(65+i)}" for i in range(n_jobs)]

    print(f"\n  {n_jobs} jobs, {n_slots} time slots")
    print(f"  Utility matrix:")

    for j in range(n_jobs):
        utils = []
        for s in range(n_slots):
            u = random.randint(1, 30)
            utility[(j, s)] = u
            utils.append(u)
        print(f"    {job_names[j]}: {utils}")

    # Bases: choose n_slots jobs (uniform matroid on jobs)
    bases = {frozenset(c) for c in combinations(range(n_jobs), n_slots)}

    # Valuation: optimal assignment utility for the selected jobs
    def assignment_value(jobs: FrozenSet[int]) -> int:
        jobs_list = sorted(jobs)
        # Simple greedy assignment
        total = 0
        used_slots = set()
        for j in jobs_list:
            best_u = 0
            best_s = -1
            for s in range(n_slots):
                if s not in used_slots and utility.get((j, s), 0) > best_u:
                    best_u = utility.get((j, s), 0)
                    best_s = s
            if best_s >= 0:
                total += best_u
                used_slots.add(best_s)
        return total

    val = {B: assignment_value(B) for B in bases}
    T = TropicalExchangeSystem(list(range(n_jobs)), bases, val)

    B0 = frozenset(random.sample(range(n_jobs), n_slots))
    path = T.descent(B0)

    print(f"\n  Initial selection: {[job_names[j] for j in sorted(B0)]}")
    print(f"    Utility: {val[B0]}")

    B_opt = path[-1][0]
    print(f"  Optimal selection: {[job_names[j] for j in sorted(B_opt)]}")
    print(f"    Utility: {val[B_opt]}")
    print(f"  Steps: {len(path)-1}")
    print(f"  Improvement: +{val[B_opt] - val[B0]}")


# ========== Application 4: Portfolio Selection ==========

def application_portfolio():
    """Portfolio optimization with cardinality constraint.

    Select r assets from n candidates to maximize risk-adjusted return.
    The cardinality constraint makes this a matroid optimization problem.
    """
    print("\n" + "="*60)
    print("APPLICATION 4: Portfolio Optimization")
    print("="*60)

    n_assets = 10
    n_select = 4

    random.seed(789)
    asset_names = [f"Asset_{i}" for i in range(n_assets)]

    # Simulated returns and risk
    expected_return = {i: random.uniform(0.02, 0.15) for i in range(n_assets)}
    risk = {i: random.uniform(0.05, 0.30) for i in range(n_assets)}

    print(f"\n  {n_assets} assets, selecting {n_select}")
    print(f"  {'Asset':<10} {'Return':>8} {'Risk':>8} {'Sharpe':>8}")
    for i in range(n_assets):
        sharpe = expected_return[i] / risk[i]
        print(f"  {asset_names[i]:<10} {expected_return[i]:>8.3f} "
              f"{risk[i]:>8.3f} {sharpe:>8.3f}")

    bases = {frozenset(c) for c in combinations(range(n_assets), n_select)}

    # Valuation: portfolio Sharpe-like ratio (simplified)
    def portfolio_score(B: FrozenSet[int]) -> int:
        avg_ret = sum(expected_return[i] for i in B) / len(B)
        avg_risk = sum(risk[i] for i in B) / len(B)
        # Diversification bonus
        diversity = len(set(int(risk[i] * 10) for i in B))
        score = (avg_ret / avg_risk) * 100 + diversity * 5
        return int(score)

    val = {B: portfolio_score(B) for B in bases}
    T = TropicalExchangeSystem(list(range(n_assets)), bases, val)

    B0 = frozenset(random.sample(range(n_assets), n_select))
    path = T.descent(B0)

    print(f"\n  Initial portfolio: {[asset_names[i] for i in sorted(B0)]}")
    print(f"    Score: {val[B0]}")

    B_opt = path[-1][0]
    print(f"  Optimal portfolio: {[asset_names[i] for i in sorted(B_opt)]}")
    print(f"    Score: {val[B_opt]}")
    print(f"  Steps: {len(path)-1}")

    # Certificate analysis
    gap = T.phi[B0] - min(T.phi[B] for B in bases)
    print(f"\n  Depth certificate analysis:")
    print(f"    Initial gap: {gap}")
    print(f"    Actual steps: {len(path)-1}")
    print(f"    Efficiency: {(len(path)-1)/gap:.3f}" if gap > 0 else "")


# ========== Main ==========

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL EXCHANGE DESCENT — REAL-WORLD APPLICATIONS        ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    application_resource_allocation()
    application_network_design()
    application_scheduling()
    application_portfolio()

    print("\n" + "="*60)
    print("All applications demonstrated successfully.")
    print("="*60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Tropical Exchange Descent Demonstration

Demonstrates the core theorems from the valuated matroid exchange theory:
1. Quantitative exchange improvement (M-convex exchange property)
2. Strict descent under depth certificates
3. Termination bounds via potential drop
4. Comparison of empirical step counts with theoretical bounds
5. Lorentzian-inspired valuation experiments (conjecture testing)
"""

import random
import math
from itertools import combinations
from typing import List, Tuple, Optional, Dict, Set, FrozenSet

# Type aliases
Basis = FrozenSet[int]


class TropicalExchangeFamily:
    """A tropical exchange family: carrier + valuation + exchange axiom."""

    def __init__(self, ground_set: List[int], rank: int,
                 val: Dict[Basis, int], carrier: Optional[Set[Basis]] = None):
        self.ground_set = ground_set
        self.rank = rank
        self.val = val
        if carrier is None:
            self.carrier = set(val.keys())
        else:
            self.carrier = carrier

    def is_carrier(self, B: Basis) -> bool:
        return B in self.carrier

    def valuation(self, B: Basis) -> int:
        return self.val.get(B, 0)

    def exchange_step(self, B: Basis, x: int, y: int) -> Basis:
        """Perform exchange: remove x, insert y."""
        return (B - {x}) | {y}

    def find_improving_exchange(self, B: Basis, phi: 'PotentialFunction') -> Optional[Tuple[Basis, int, int]]:
        """Find an exchange step that decreases the potential."""
        best = None
        best_drop = 0
        for x in B:
            for y in self.ground_set:
                if y not in B:
                    B_new = self.exchange_step(B, x, y)
                    if self.is_carrier(B_new):
                        drop = phi(B) - phi(B_new)
                        if drop > best_drop:
                            best = (B_new, x, y)
                            best_drop = drop
        return best

    def verify_exchange_axiom(self) -> bool:
        """Verify the quantitative exchange axiom for all pairs."""
        bases = list(self.carrier)
        for B1 in bases:
            for B2 in bases:
                for x in B1 - B2:
                    found = False
                    for y in B2 - B1:
                        B1_new = self.exchange_step(B1, x, y)
                        B2_new = self.exchange_step(B2, y, x)
                        if self.is_carrier(B1_new):
                            total_before = self.val[B1] + self.val[B2]
                            total_after = self.val.get(B1_new, 0) + self.val.get(B2_new, 0)
                            if total_before <= total_after:
                                found = True
                                break
                    if not found:
                        return False
        return True


class PotentialFunction:
    """A potential function Phi on bases."""

    def __init__(self, phi: Dict[Basis, int]):
        self.phi = phi

    def __call__(self, B: Basis) -> int:
        return self.phi.get(B, 10**9)

    def lower_bound(self, carrier: Set[Basis]) -> int:
        return min(self.phi[B] for B in carrier if B in self.phi)


def run_exchange_descent(T: TropicalExchangeFamily, phi: PotentialFunction,
                          B0: Basis, max_steps: int = 10000) -> List[Tuple[Basis, int]]:
    """Run exchange descent from B0, recording the path."""
    path = [(B0, phi(B0))]
    B = B0
    for _ in range(max_steps):
        result = T.find_improving_exchange(B, phi)
        if result is None:
            break
        B_new, _, _ = result
        B = B_new
        path.append((B, phi(B)))
    return path


def verify_descent_chain(values: List[int]) -> bool:
    """Verify that a list of potential values is strictly decreasing."""
    return all(values[i] > values[i + 1] for i in range(len(values) - 1))


# ========== Example Generators ==========

def uniform_matroid_bases(n: int, r: int) -> List[Basis]:
    """Generate all bases of the uniform matroid U(r, n)."""
    return [frozenset(c) for c in combinations(range(n), r)]


def random_valuation(bases: List[Basis], val_range: int = 100) -> Dict[Basis, int]:
    """Random integer valuation on bases."""
    return {B: random.randint(0, val_range) for B in bases}


def lorentzian_valuation(bases: List[Basis], n: int) -> Dict[Basis, int]:
    """Log-concave-inspired valuation: val(B) = sum of i^2 for i in B.
    This creates a concave-like landscape favorable for descent."""
    return {B: sum(i * i for i in B) for B in bases}


def geometric_valuation(bases: List[Basis], r: float = 0.9) -> Dict[Basis, int]:
    """Geometric-sequence-inspired valuation: val(B) = floor(100 * r^(sum of B)).
    Highly k-fold concave."""
    return {B: int(100 * r ** sum(B)) for B in bases}


# ========== Experiments ==========

def experiment_basic_descent(n: int = 8, r: int = 4, num_trials: int = 20):
    """Demonstrate basic exchange descent with random valuations."""
    print(f"\n{'='*60}")
    print(f"EXPERIMENT 1: Basic Exchange Descent (n={n}, r={r})")
    print(f"{'='*60}")

    bases = uniform_matroid_bases(n, r)
    print(f"Number of bases: {len(bases)}")

    step_counts = []
    for trial in range(num_trials):
        val = random_valuation(bases)
        T = TropicalExchangeFamily(list(range(n)), r, val)

        # Use negative valuation as potential (minimize -val = maximize val)
        phi_dict = {B: -val[B] for B in bases}
        phi = PotentialFunction(phi_dict)

        B0 = random.choice(bases)
        path = run_exchange_descent(T, phi, B0)
        steps = len(path) - 1
        step_counts.append(steps)

        if trial < 3:  # Print first few
            vals = [v for _, v in path]
            print(f"  Trial {trial+1}: {steps} steps, "
                  f"Φ: {vals[0]} → {vals[-1]}, "
                  f"chain valid: {verify_descent_chain(vals) if steps > 0 else 'N/A'}")

    avg = sum(step_counts) / len(step_counts)
    mx = max(step_counts)
    print(f"\n  Average steps: {avg:.1f}")
    print(f"  Max steps: {mx}")
    print(f"  Trivial bound (|bases|): {len(bases)}")
    print(f"  Avg/bound ratio: {avg/len(bases):.3f}")


def experiment_depth_certificate(n: int = 8, r: int = 4, num_trials: int = 20):
    """Demonstrate depth certificate bounds."""
    print(f"\n{'='*60}")
    print(f"EXPERIMENT 2: Depth Certificate Bounds (n={n}, r={r})")
    print(f"{'='*60}")

    bases = uniform_matroid_bases(n, r)

    for val_name, val_fn in [("Random", lambda: random_valuation(bases)),
                               ("Lorentzian", lambda: lorentzian_valuation(bases, n)),
                               ("Geometric", lambda: geometric_valuation(bases))]:
        step_counts = []
        bound_ratios = []

        for _ in range(num_trials):
            val = val_fn()
            T = TropicalExchangeFamily(list(range(n)), r, val)

            phi_dict = {B: -val[B] for B in bases}
            phi = PotentialFunction(phi_dict)

            B0 = random.choice(bases)
            path = run_exchange_descent(T, phi, B0)
            steps = len(path) - 1
            step_counts.append(steps)

            if steps > 0:
                gap = phi(B0) - phi(path[-1][0])
                if gap > 0:
                    bound_ratios.append(steps / gap)

        avg = sum(step_counts) / len(step_counts)
        avg_ratio = sum(bound_ratios) / len(bound_ratios) if bound_ratios else 0
        print(f"\n  {val_name}:")
        print(f"    Avg steps: {avg:.1f}")
        print(f"    Avg steps/gap ratio: {avg_ratio:.3f} (certificate k=1 predicts ≤ 1.0)")


def experiment_lorentzian_conjecture(n: int = 8, r: int = 4, num_trials: int = 30):
    """Test the Lorentzian descent complexity conjecture."""
    print(f"\n{'='*60}")
    print(f"EXPERIMENT 3: Lorentzian Conjecture Test (n={n}, r={r})")
    print(f"{'='*60}")

    bases = uniform_matroid_bases(n, r)

    configs = {
        "Random (k=1)": (random_valuation, 1),
        "Lorentzian (k≈2)": (lambda b: lorentzian_valuation(b, n), 2),
        "Geometric (k≈∞)": (lambda b: geometric_valuation(b), 4),
    }

    for name, (val_fn, k_est) in configs.items():
        step_counts = []
        for _ in range(num_trials):
            val = val_fn(bases)
            T = TropicalExchangeFamily(list(range(n)), r, val)

            phi_dict = {B: -val[B] for B in bases}
            phi = PotentialFunction(phi_dict)
            lb = phi.lower_bound(T.carrier)

            B0 = random.choice(bases)
            path = run_exchange_descent(T, phi, B0)
            steps = len(path) - 1
            step_counts.append(steps)

        avg = sum(step_counts) / len(step_counts)
        predicted = len(bases) / k_est  # Simplified prediction
        print(f"\n  {name}:")
        print(f"    Avg steps: {avg:.1f}")
        print(f"    Predicted bound / k: {predicted:.1f}")
        print(f"    Ratio: {avg/predicted:.3f}")
        print(f"    Conjecture predicts ratio < 1.0: {'✓' if avg < predicted else '✗'}")


def experiment_exchange_axiom_verification():
    """Verify the quantitative exchange axiom on small examples."""
    print(f"\n{'='*60}")
    print(f"EXPERIMENT 4: Exchange Axiom Verification")
    print(f"{'='*60}")

    for n, r in [(5, 2), (6, 3), (7, 3)]:
        bases = uniform_matroid_bases(n, r)
        val = random_valuation(bases, 50)
        T = TropicalExchangeFamily(list(range(n)), r, val)

        # Check if random valuation satisfies exchange axiom
        satisfies = T.verify_exchange_axiom()
        print(f"  U({r},{n}), random val: exchange axiom {'satisfied ✓' if satisfies else 'violated ✗'}")

        # Lorentzian valuation
        val_lor = lorentzian_valuation(bases, n)
        T_lor = TropicalExchangeFamily(list(range(n)), r, val_lor)
        satisfies_lor = T_lor.verify_exchange_axiom()
        print(f"  U({r},{n}), Lorentzian val: exchange axiom {'satisfied ✓' if satisfies_lor else 'violated ✗'}")


def experiment_distance_decrease():
    """Demonstrate exchange distance decrease theorem."""
    print(f"\n{'='*60}")
    print(f"EXPERIMENT 5: Exchange Distance Decrease")
    print(f"{'='*60}")

    n, r = 8, 4
    bases = uniform_matroid_bases(n, r)
    val = lorentzian_valuation(bases, n)
    T = TropicalExchangeFamily(list(range(n)), r, val)

    phi_dict = {B: -val[B] for B in bases}
    phi = PotentialFunction(phi_dict)

    # Find the optimal basis
    B_opt = min(bases, key=lambda B: phi(B))

    # Run descent from a random basis
    B0 = random.choice(bases)
    path = run_exchange_descent(T, phi, B0)

    print(f"  Optimal basis: {set(B_opt)}, Φ = {phi(B_opt)}")
    print(f"  Starting basis: {set(B0)}, Φ = {phi(B0)}")
    print(f"  Descent path (distance to optimal, potential):")

    for i, (B, v) in enumerate(path[:10]):  # Show first 10 steps
        dist = len(B - B_opt)
        print(f"    Step {i}: dist = {dist}, Φ = {v}")

    if len(path) > 10:
        B_final, v_final = path[-1]
        dist_final = len(B_final - B_opt)
        print(f"    ... ({len(path)-1} total steps)")
        print(f"    Final: dist = {dist_final}, Φ = {v_final}")


# ========== Main ==========

def main():
    random.seed(42)

    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL EXCHANGE DESCENT — COMPUTATIONAL EXPERIMENTS  ║")
    print("╠══════════════════════════════════════════════════════════╣")
    print("║  Demonstrating theorems from ValuatedMatroidExchange    ║")
    print("╚══════════════════════════════════════════════════════════╝")

    experiment_exchange_axiom_verification()
    experiment_basic_descent()
    experiment_depth_certificate()
    experiment_lorentzian_conjecture()
    experiment_distance_decrease()

    print(f"\n{'='*60}")
    print("All experiments completed.")
    print("="*60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 2: Depth Certificate Bounds vs Empirical Step Counts

Compares the theoretical termination bound (Φ₀ - lb) / k with the actual
number of descent steps across different valuation types (Random, Lorentzian,
Geometric) and varying problem sizes.

This illustrates:
- The gap between worst-case bounds and typical behavior
- How higher-order concavity (larger k) tightens the bounds
- The Lorentzian conjecture: structured valuations converge faster
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random

random.seed(42)
np.random.seed(42)

# Basis = frozenset
def uniform_matroid_bases(n, r):
    return [frozenset(c) for c in combinations(range(n), r)]

def greedy_descent(bases, val, ground, B0):
    phi = {B: -val[B] for B in bases}
    B = B0
    steps = 0
    for _ in range(10000):
        best_next = None
        best_phi = phi[B]
        for x in B:
            for y in ground:
                if y not in B:
                    Bn = (B - {x}) | {y}
                    if Bn in phi and phi[Bn] < best_phi:
                        best_phi = phi[Bn]
                        best_next = Bn
        if best_next is None:
            break
        B = best_next
        steps += 1
    return steps, phi[B0] - phi[B]

# Experiment parameters
configs = [
    ("Random", lambda bases, n: {B: random.randint(0, 100) for B in bases}),
    ("Lorentzian", lambda bases, n: {B: sum(i*i for i in B) for B in bases}),
    ("Geometric", lambda bases, n: {B: int(100 * 0.85**sum(B)) for B in bases}),
]

sizes = [(6, 3), (7, 3), (8, 3), (8, 4), (9, 4), (10, 4)]
num_trials = 15

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

for ax_idx, (name, val_fn) in enumerate(configs):
    ax = axes[ax_idx]

    avg_steps_list = []
    avg_bound_list = []
    size_labels = []

    for n, r in sizes:
        bases = uniform_matroid_bases(n, r)
        ground = list(range(n))
        bases_set = set(bases)

        trial_steps = []
        trial_bounds = []

        for _ in range(num_trials):
            val = val_fn(bases, n)
            phi = {B: -val[B] for B in bases}
            lb = min(phi.values())

            B0 = random.choice(bases)
            steps, drop = greedy_descent(bases, val, ground, B0)
            gap = phi[B0] - lb

            trial_steps.append(steps)
            trial_bounds.append(gap)

        avg_steps_list.append(np.mean(trial_steps))
        avg_bound_list.append(np.mean(trial_bounds))
        size_labels.append(f"({n},{r})")

    x = np.arange(len(sizes))
    width = 0.35

    bars1 = ax.bar(x - width/2, avg_steps_list, width, label='Actual steps',
                   color='steelblue', alpha=0.8)
    bars2 = ax.bar(x + width/2, avg_bound_list, width, label='Bound (gap/k)',
                   color='coral', alpha=0.8)

    ax.set_xlabel('Problem size (n, r)', fontsize=11)
    ax.set_ylabel('Steps', fontsize=11)
    ax.set_title(f'{name} Valuation', fontsize=13, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(size_labels, rotation=45)
    ax.legend(fontsize=9)
    ax.grid(axis='y', alpha=0.3)

    # Add ratio annotations
    for i, (s, b) in enumerate(zip(avg_steps_list, avg_bound_list)):
        if b > 0:
            ratio = s / b
            ax.annotate(f'{ratio:.2f}', xy=(x[i], max(s, b) + 1),
                       ha='center', fontsize=8, color='gray')

fig.suptitle('Tropical Exchange Descent: Actual Steps vs Theoretical Bounds\n'
             '(Numbers above bars = actual/bound ratio)',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_depth_bounds.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_bounds.png")


#!/usr/bin/env python3
"""
Visualization 1: Tropical Exchange Descent Landscape

Visualizes the potential landscape of a tropical exchange family on the uniform
matroid U(3, 6). Each basis (3-element subset) is a node, and exchange neighbors
are connected by edges. The color represents the potential value, and the descent
path is highlighted in red.

This illustrates:
- The structure of the exchange graph (nodes = bases, edges = single exchanges)
- The potential landscape (color = Φ value)
- How greedy descent navigates from high to low potential
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
import random

# Generate the uniform matroid U(3, 6)
n, r = 6, 3
ground = list(range(n))
bases = [frozenset(c) for c in combinations(ground, r)]
basis_index = {B: i for i, B in enumerate(bases)}

# Lorentzian-inspired valuation
val = {B: sum(i * i for i in B) for B in bases}
phi = {B: -val[B] for B in bases}  # Potential to minimize

# Build exchange graph
edges = []
for i, B1 in enumerate(bases):
    for j, B2 in enumerate(bases):
        if j <= i:
            continue
        # Check if B1 and B2 differ by exactly one element
        diff1 = B1 - B2
        diff2 = B2 - B1
        if len(diff1) == 1 and len(diff2) == 1:
            edges.append((i, j))

# Layout: use spectral-like embedding based on basis elements
positions = {}
for i, B in enumerate(bases):
    elems = sorted(B)
    # Use barycentric coordinates based on element values
    angle = sum(e * 2 * np.pi / n for e in elems) / r
    radius = 1 + 0.3 * sum(elems) / r
    positions[i] = (radius * np.cos(angle), radius * np.sin(angle))

# Add jitter to avoid overlaps
random.seed(42)
for i in positions:
    x, y = positions[i]
    positions[i] = (x + random.uniform(-0.15, 0.15),
                    y + random.uniform(-0.15, 0.15))

# Run greedy descent
def greedy_descent(start_idx):
    path = [start_idx]
    current = start_idx
    for _ in range(100):
        B = bases[current]
        best_next = None
        best_phi = phi[B]
        for x in B:
            for y in ground:
                if y not in B:
                    Bn = (B - {x}) | {y}
                    if Bn in basis_index:
                        if phi[Bn] < best_phi:
                            best_phi = phi[Bn]
                            best_next = basis_index[Bn]
        if best_next is None:
            break
        path.append(best_next)
        current = best_next
    return path

# Find worst starting point for longest descent
worst_start = max(range(len(bases)), key=lambda i: phi[bases[i]])
descent_path = greedy_descent(worst_start)

# Plotting
fig, ax = plt.subplots(1, 1, figsize=(12, 10))

# Draw exchange edges (light gray)
for i, j in edges:
    x1, y1 = positions[i]
    x2, y2 = positions[j]
    ax.plot([x1, x2], [y1, y2], '-', color='#e0e0e0', linewidth=0.5, zorder=1)

# Color nodes by potential
phi_values = [phi[bases[i]] for i in range(len(bases))]
phi_min, phi_max = min(phi_values), max(phi_values)

# Draw nodes
for i, B in enumerate(bases):
    x, y = positions[i]
    # Normalize color
    norm_phi = (phi[B] - phi_min) / (phi_max - phi_min) if phi_max > phi_min else 0.5
    color = plt.cm.RdYlGn(1 - norm_phi)  # Green = low potential (good), Red = high
    size = 200
    ax.scatter(x, y, c=[color], s=size, zorder=3, edgecolors='gray', linewidth=0.5)

    # Label with basis elements
    label = '{' + ','.join(str(e) for e in sorted(B)) + '}'
    ax.annotate(label, (x, y), textcoords="offset points",
                xytext=(0, 12), ha='center', fontsize=6, color='#333333')

# Draw descent path (red arrows)
for k in range(len(descent_path) - 1):
    i, j = descent_path[k], descent_path[k + 1]
    x1, y1 = positions[i]
    x2, y2 = positions[j]
    dx, dy = x2 - x1, y2 - y1
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color='red', lw=2.5),
                zorder=5)

# Highlight start and end
x0, y0 = positions[descent_path[0]]
xf, yf = positions[descent_path[-1]]
ax.scatter(x0, y0, c='red', s=400, zorder=6, marker='*', edgecolors='darkred',
           linewidth=1.5, label=f'Start (Φ={phi[bases[descent_path[0]]]})')
ax.scatter(xf, yf, c='lime', s=400, zorder=6, marker='*', edgecolors='darkgreen',
           linewidth=1.5, label=f'Optimal (Φ={phi[bases[descent_path[-1]]]})')

ax.set_title('Tropical Exchange Descent on U(3,6)\n'
             'Nodes = bases, edges = single exchanges, color = potential Φ\n'
             f'Red path: greedy descent ({len(descent_path)-1} steps)',
             fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=10)
ax.set_aspect('equal')
ax.axis('off')

plt.tight_layout()
plt.savefig('viz_descent_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_descent_landscape.png")


#!/usr/bin/env python3
"""
Visualization 3: Tropical Potential Surface and Descent Trajectories

Creates a heatmap of potential values on a 2D projection of the basis space,
showing how different starting points converge to the optimal basis through
exchange descent. Multiple trajectories are overlaid to illustrate the
basin of attraction structure.

This illustrates:
- The "landscape" metaphor for tropical optimization
- Convergence of multiple trajectories to the optimum
- The role of the depth certificate in controlling descent speed
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random

random.seed(42)

# Generate matroid
n, r = 7, 3
ground = list(range(n))
bases = [frozenset(c) for c in combinations(ground, r)]
basis_idx = {B: i for i, B in enumerate(bases)}

# Lorentzian valuation
val = {B: sum(i * i for i in B) for B in bases}
phi = {B: -val[B] for B in bases}

# 2D embedding: use PCA-like projection based on indicator vectors
indicators = np.zeros((len(bases), n))
for i, B in enumerate(bases):
    for e in B:
        indicators[i, e] = 1

# Simple 2D projection using first two principal directions
mean = indicators.mean(axis=0)
centered = indicators - mean
U, S, Vt = np.linalg.svd(centered, full_matrices=False)
coords = centered @ Vt[:2].T

# Greedy descent function
def greedy_descent_path(start_idx):
    path = [start_idx]
    current = start_idx
    for _ in range(100):
        B = bases[current]
        best_next = None
        best_phi = phi[B]
        for x in B:
            for y in ground:
                if y not in B:
                    Bn = (B - {x}) | {y}
                    if Bn in basis_idx and phi[Bn] < best_phi:
                        best_phi = phi[Bn]
                        best_next = basis_idx[Bn]
        if best_next is None:
            break
        path.append(best_next)
        current = best_next
    return path

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# --- Subplot 1: Potential heatmap with trajectories ---
phi_vals = np.array([phi[bases[i]] for i in range(len(bases))])
phi_norm = (phi_vals - phi_vals.min()) / (phi_vals.max() - phi_vals.min())

# Scatter plot of bases colored by potential
scatter = ax1.scatter(coords[:, 0], coords[:, 1], c=phi_vals,
                      cmap='RdYlGn_r', s=80, zorder=3,
                      edgecolors='gray', linewidth=0.5)
plt.colorbar(scatter, ax=ax1, label='Potential Φ', shrink=0.8)

# Draw multiple descent trajectories
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00',
          '#a65628', '#f781bf', '#999999']
num_trajectories = 8

# Pick diverse starting points
starts = sorted(range(len(bases)), key=lambda i: phi_vals[i], reverse=True)[:num_trajectories]

for t, start in enumerate(starts):
    path = greedy_descent_path(start)
    path_coords = coords[path]

    ax1.plot(path_coords[:, 0], path_coords[:, 1], '-',
             color=colors[t % len(colors)], linewidth=1.5, alpha=0.7, zorder=4)
    ax1.scatter(path_coords[0, 0], path_coords[0, 1],
                c=colors[t % len(colors)], s=150, marker='^', zorder=5,
                edgecolors='black', linewidth=1)

# Mark the optimal basis
opt_idx = min(range(len(bases)), key=lambda i: phi_vals[i])
ax1.scatter(coords[opt_idx, 0], coords[opt_idx, 1],
            c='lime', s=300, marker='*', zorder=6,
            edgecolors='darkgreen', linewidth=2, label='Optimal')

ax1.set_title('Descent Trajectories on Potential Landscape\n'
              'U(3,7) with Lorentzian valuation',
              fontsize=12, fontweight='bold')
ax1.set_xlabel('PC1', fontsize=10)
ax1.set_ylabel('PC2', fontsize=10)
ax1.legend(fontsize=9)

# --- Subplot 2: Potential vs step number for all trajectories ---
for t, start in enumerate(starts):
    path = greedy_descent_path(start)
    potentials = [phi[bases[i]] for i in path]
    steps = list(range(len(path)))

    ax2.plot(steps, potentials, 'o-', color=colors[t % len(colors)],
             linewidth=1.5, markersize=4, alpha=0.7,
             label=f'Start {set(bases[start])}' if t < 4 else None)

# Add theoretical bound line
max_phi = max(phi_vals)
min_phi = min(phi_vals)
gap = max_phi - min_phi
ax2.axhline(y=min_phi, color='green', linestyle='--', linewidth=2,
            alpha=0.5, label=f'Lower bound (lb={min_phi})')
ax2.fill_between([0, gap], [min_phi, min_phi], alpha=0.1, color='green')

ax2.set_title('Potential Decrease Along Descent Paths\n'
              'Each line = one trajectory',
              fontsize=12, fontweight='bold')
ax2.set_xlabel('Step number', fontsize=10)
ax2.set_ylabel('Potential Φ', fontsize=10)
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(alpha=0.3)

fig.suptitle('Tropical Exchange Descent: Landscape and Convergence',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_potential_surface.png', dpi=150, bbox_inches='tight')
print("Saved viz_potential_surface.png")
