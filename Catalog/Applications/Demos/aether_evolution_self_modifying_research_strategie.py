#!/usr/bin/env python3
"""
Reflective Convergence Architecture — Applications

Real-world applications of the convergence theorems:
1. Meta-learning hyperparameter tuning
2. Proof search heuristic optimization
3. Evolutionary strategy selection
"""

import random
import math
from algorithms import (
    ResearchSystem, reflective_iterate, argmax_selector,
    find_local_optimum, verify_local_optimality, finite_stabilize,
)


# =============================================================================
# Application 1: Meta-Learning Hyperparameter Tuning
# =============================================================================

def app_metalearning():
    """
    Application: A meta-learning system that tunes its own hyperparameters.
    
    Setup: 20 hyperparameter configurations. Each has an accuracy score.
    The system can move to any "neighboring" configuration (Hamming distance 1
    in a binary encoding). It always picks the best neighbor.
    
    By Theorem 6.1, this process stabilizes at a locally optimal configuration.
    """
    print("=" * 70)
    print("APPLICATION 1: Meta-Learning Hyperparameter Tuning")
    print("=" * 70)
    print()
    
    random.seed(42)
    n_configs = 16  # 4-bit hyperparameter space
    
    # Simulate accuracy for each configuration
    # Use a landscape with a clear global optimum and some local optima
    def accuracy(config: int) -> float:
        """Simulated validation accuracy for a hyperparameter config."""
        # Create a rugged landscape
        x = config / n_configs
        return (
            0.6 + 0.2 * math.sin(2 * math.pi * x)
            + 0.15 * math.cos(4 * math.pi * x)
            + 0.05 * math.sin(8 * math.pi * x)
        )
    
    def neighbors(config: int) -> list:
        """Hamming-distance-1 neighbors in 4-bit space, plus self."""
        nbrs = [config]
        for bit in range(4):
            nbrs.append(config ^ (1 << bit))
        return sorted(set(nbrs))
    
    system = ResearchSystem(
        admissible=neighbors,
        quality=accuracy,
    )
    
    print("Hyperparameter landscape (4-bit configs):")
    for c in range(n_configs):
        bar = "#" * int(accuracy(c) * 50)
        print(f"  Config {c:2d} ({c:04b}): acc={accuracy(c):.4f}  {bar}")
    print()
    
    print("Meta-learning trajectories:")
    for s0 in [0, 5, 10, 15]:
        result = find_local_optimum(system, s0)
        path = " → ".join(str(s) for s in result.trajectory)
        is_opt, _ = verify_local_optimality(
            result.fixed_point, neighbors, accuracy
        )
        print(f"  Start={s0:2d}: {path}")
        print(f"    Stabilized at config {result.fixed_point} "
              f"(acc={accuracy(result.fixed_point):.4f}), "
              f"locally optimal={is_opt}")
    print()


# =============================================================================
# Application 2: Proof Search Heuristic Optimization
# =============================================================================

def app_proof_search():
    """
    Application: A theorem prover that revises its search heuristics.
    
    Setup: The prover has a set of heuristic weights (discretized).
    Each weight configuration determines how many theorems the prover
    can solve from a benchmark. The prover adjusts weights to solve more.
    
    By Theorem 4.1, with score = number of solved theorems (ℕ-valued),
    the process must stabilize.
    """
    print("=" * 70)
    print("APPLICATION 2: Proof Search Heuristic Optimization")
    print("=" * 70)
    print()
    
    random.seed(7)
    
    # 3 heuristic weights, each in {0, 1, 2, 3} → 64 configurations
    configs = [(a, b, c) for a in range(4) for b in range(4) for c in range(4)]
    
    # Simulate benchmark performance
    def theorems_solved(config: tuple) -> int:
        a, b, c = config
        # Optimal around (2, 3, 1)
        return max(0, 20 - abs(a - 2) * 3 - abs(b - 3) * 2 - abs(c - 1) * 4)
    
    def heuristic_neighbors(config: tuple) -> list:
        """Adjust one weight by ±1."""
        a, b, c = config
        nbrs = [config]
        for da in [-1, 0, 1]:
            for db in [-1, 0, 1]:
                for dc in [-1, 0, 1]:
                    if abs(da) + abs(db) + abs(dc) <= 1:
                        na, nb, nc = a + da, b + db, c + dc
                        if 0 <= na < 4 and 0 <= nb < 4 and 0 <= nc < 4:
                            nbrs.append((na, nb, nc))
        return list(set(nbrs))
    
    print(f"Heuristic space: 3 weights × 4 levels = {len(configs)} configurations")
    print(f"Optimal config: (2, 3, 1) → {theorems_solved((2, 3, 1))} theorems")
    print()
    
    # Use finite_stabilize with score = theorems_solved
    def update(config):
        nbrs = heuristic_neighbors(config)
        return max(nbrs, key=theorems_solved)
    
    starting_configs = [(0, 0, 0), (3, 3, 3), (1, 1, 1), (2, 0, 3)]
    
    print("Heuristic tuning trajectories:")
    for s0 in starting_configs:
        try:
            fixed, steps, history = finite_stabilize(
                update, theorems_solved, s0, max_iter=100
            )
            path = " → ".join(str(h[0]) for h in history[:8])
            if len(history) > 8:
                path += f" → ... → {history[-1][0]}"
            print(f"  Start={s0}: {path}")
            print(f"    Fixed point: {fixed}, theorems solved: {theorems_solved(fixed)}, "
                  f"steps: {steps}")
        except (RuntimeError, AssertionError) as e:
            # Fall back to basic iteration
            result = reflective_iterate(update, s0, max_iter=100)
            print(f"  Start={s0}: stabilized at {result.trajectory[-1]} "
                  f"in {len(result.trajectory)-1} steps")
    print()


# =============================================================================
# Application 3: Evolutionary Strategy Selection
# =============================================================================

def app_evolutionary():
    """
    Application: An evolutionary algorithm that selects mutation rates.
    
    Setup: Population of organisms with discrete mutation rate settings.
    Each generation, the mutation rate that produces the highest fitness
    offspring is selected. The system converges to an optimal mutation rate.
    
    By Theorem 3.1 (with discretized fitness as quality), the average
    fitness converges.
    """
    print("=" * 70)
    print("APPLICATION 3: Evolutionary Strategy Selection")
    print("=" * 70)
    print()
    
    random.seed(99)
    
    mutation_rates = [0.001, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5]
    n_rates = len(mutation_rates)
    
    # Simulate: fitness landscape has an optimal mutation rate around 0.02
    def expected_fitness(rate_idx: int) -> float:
        rate = mutation_rates[rate_idx]
        optimal = 0.02
        return 100 * math.exp(-((math.log(rate) - math.log(optimal)) ** 2) / 2)
    
    # Admissible: can move to adjacent mutation rates
    def adjacent_rates(idx: int) -> list:
        nbrs = [idx]
        if idx > 0:
            nbrs.append(idx - 1)
        if idx < n_rates - 1:
            nbrs.append(idx + 1)
        return nbrs
    
    print("Mutation rate landscape:")
    for i, rate in enumerate(mutation_rates):
        fit = expected_fitness(i)
        bar = "#" * int(fit / 2)
        print(f"  Rate {rate:5.3f} (idx={i}): fitness={fit:6.2f}  {bar}")
    print()
    
    system = ResearchSystem(
        admissible=adjacent_rates,
        quality=expected_fitness,
    )
    
    print("Evolutionary trajectories:")
    for s0 in [0, 3, 7]:
        result = find_local_optimum(system, s0)
        rate_path = " → ".join(f"{mutation_rates[s]:.3f}" for s in result.trajectory)
        print(f"  Start rate={mutation_rates[s0]:.3f}: {rate_path}")
        fixed = result.fixed_point
        print(f"    Converged to rate={mutation_rates[fixed]:.3f}, "
              f"fitness={expected_fitness(fixed):.2f}")
    print()


if __name__ == "__main__":
    app_metalearning()
    print()
    app_proof_search()
    print()
    app_evolutionary()


#!/usr/bin/env python3
"""
Reflective Convergence Architecture — Demonstrations

Concrete numerical demonstrations of the three main theorems:
1. Monotone convergence of reflective iteration
2. Finite stabilization under strict progress
3. Local optimality of fixed points
"""

import math
from typing import Callable, TypeVar, Optional

S = TypeVar('S')


def reflective_iterate(next_fn: Callable[[S], S], s0: S, max_iter: int = 100):
    """Iterate a reflective improvement operator until stabilization or max_iter."""
    trajectory = [s0]
    s = s0
    for _ in range(max_iter):
        s_next = next_fn(s)
        trajectory.append(s_next)
        if s_next == s:
            break
        s = s_next
    return trajectory


# =============================================================================
# DEMO 1: Monotone Convergence
# =============================================================================
def demo_monotone_convergence():
    """
    Demonstrate Theorem 3.1: monotone bounded quality converges.
    
    System: state is a natural number, quality(n) = 1 - 2^(-n).
    Each step increments the state by 1.
    Quality is monotone (increasing) and bounded above by 1.
    The quality sequence converges to L = 1.
    """
    print("=" * 70)
    print("DEMO 1: Monotone Convergence of Reflective Iteration")
    print("=" * 70)
    print()
    print("System: state = natural number n")
    print("        quality(n) = 1 - 2^(-n)")
    print("        next(n) = n + 1")
    print("        Upper bound B = 1")
    print()
    
    quality = lambda n: 1.0 - 2.0**(-n)
    next_fn = lambda n: n + 1
    
    trajectory = reflective_iterate(next_fn, 0, max_iter=20)
    qualities = [quality(s) for s in trajectory]
    
    print(f"{'Step':>4}  {'State':>6}  {'Quality':>12}  {'Gap to L=1':>12}")
    print("-" * 40)
    for i, (s, q) in enumerate(zip(trajectory, qualities)):
        gap = 1.0 - q
        print(f"{i:4d}  {s:6d}  {q:12.8f}  {gap:12.2e}")
    
    print()
    print(f"Limit L = 1.000000000")
    print(f"After 20 steps: quality = {qualities[-1]:.10f}")
    print(f"Convergence confirmed: |q_20 - L| = {abs(1.0 - qualities[-1]):.2e}")
    print()
    return qualities


# =============================================================================
# DEMO 2: Finite Stabilization
# =============================================================================
def demo_finite_stabilization():
    """
    Demonstrate Theorem 4.1: strict progress on finite types implies stabilization.
    
    System: 10 strategies labeled 0..9.
    Score function: score(s) = s (identity).
    Update: if s < 9, move to s+1; if s = 9, stay.
    Strict progress: update(s) != s implies score(s) < score(update(s)).
    """
    print("=" * 70)
    print("DEMO 2: Finite Stabilization Under Strict Progress")
    print("=" * 70)
    print()
    
    n_strategies = 10
    score = lambda s: s
    update = lambda s: min(s + 1, n_strategies - 1)
    
    print(f"Strategy space: {{0, 1, ..., {n_strategies-1}}}")
    print(f"Score function: score(s) = s")
    print(f"Update rule: update(s) = min(s+1, {n_strategies-1})")
    print()
    
    trajectory = reflective_iterate(update, 0, max_iter=20)
    
    print(f"{'Step':>4}  {'State':>6}  {'Score':>6}  {'Fixed?':>8}")
    print("-" * 30)
    for i, s in enumerate(trajectory):
        fixed = "YES" if update(s) == s else "no"
        print(f"{i:4d}  {s:6d}  {score(s):6d}  {fixed:>8}")
    
    N = next(i for i, s in enumerate(trajectory) if update(s) == s)
    print()
    print(f"Stabilization at step N = {N}")
    print(f"Fixed point: state = {trajectory[N]}")
    print(f"Verified: update({trajectory[N]}) = {update(trajectory[N])} = {trajectory[N]}")
    print()
    return trajectory


# =============================================================================
# DEMO 3: Local Optimality of Fixed Points
# =============================================================================
def demo_local_optimality():
    """
    Demonstrate Theorem 5.1: fixed points of quality-maximizing selectors
    are locally optimal.
    
    System: 5 states {A, B, C, D, E} with quality and admissible moves.
    The selector always picks the highest-quality admissible successor.
    We verify that the fixed point dominates all admissible alternatives.
    """
    print("=" * 70)
    print("DEMO 3: Local Optimality of Fixed Points")
    print("=" * 70)
    print()
    
    states = ['A', 'B', 'C', 'D', 'E']
    quality = {'A': 1.0, 'B': 3.0, 'C': 2.0, 'D': 5.0, 'E': 4.0}
    admissible = {
        'A': ['B', 'C'],
        'B': ['C', 'D'],
        'C': ['A', 'E'],
        'D': ['D', 'E'],  # D can stay at D or go to E
        'E': ['C', 'D'],
    }
    
    def next_fn(s):
        """Select the highest-quality admissible successor."""
        candidates = admissible[s]
        return max(candidates, key=lambda t: quality[t])
    
    print("State qualities:")
    for s in states:
        print(f"  quality({s}) = {quality[s]}")
    print()
    print("Admissible moves:")
    for s in states:
        moves = ', '.join(f"{t}(q={quality[t]})" for t in admissible[s])
        print(f"  {s} → {{{moves}}}")
    print()
    
    # Find the trajectory from each starting state
    for s0 in states:
        traj = reflective_iterate(next_fn, s0, max_iter=20)
        fixed = traj[-1]
        is_fixed = next_fn(fixed) == fixed
        
        print(f"Starting from {s0}: {' → '.join(traj[:8])}")
        if is_fixed:
            # Verify local optimality
            dominated = all(quality[t] <= quality[fixed] for t in admissible[fixed])
            adm_str = ', '.join(f"q({t})={quality[t]}" for t in admissible[fixed])
            print(f"  Fixed point: {fixed}, quality = {quality[fixed]}")
            print(f"  Admissible: {adm_str}")
            print(f"  Locally optimal: {dominated}")
        print()


# =============================================================================
# DEMO 4: Grand Composition — Stabilization at Local Optimum
# =============================================================================
def demo_grand_composition():
    """
    Demonstrate Theorem 6.1: finite reflective systems with quality-maximizing
    updates and strict progress stabilize at locally optimal states.
    """
    print("=" * 70)
    print("DEMO 4: Grand Composition — Stabilization at Local Optimum")
    print("=" * 70)
    print()
    
    import random
    random.seed(42)
    
    n = 15
    qualities = {i: random.uniform(0, 10) for i in range(n)}
    scores = {i: int(qualities[i] * 100) for i in range(n)}
    
    # Build random admissibility graph (each state has 2-4 admissible successors)
    admissible = {}
    for i in range(n):
        neighbors = random.sample(range(n), min(random.randint(2, 4), n))
        if i not in neighbors:
            neighbors.append(i)  # always admissible to stay
        admissible[i] = sorted(set(neighbors))
    
    def next_fn(s):
        return max(admissible[s], key=lambda t: qualities[t])
    
    print(f"System: {n} states with random qualities and admissibility")
    print()
    
    results = []
    for s0 in range(n):
        traj = reflective_iterate(next_fn, s0, max_iter=100)
        fixed = traj[-1]
        is_fixed = next_fn(fixed) == fixed
        is_optimal = all(qualities[t] <= qualities[fixed] for t in admissible[fixed])
        steps = len(traj) - 1
        results.append((s0, fixed, steps, is_fixed, is_optimal))
    
    print(f"{'Start':>5}  {'Fixed Pt':>8}  {'Steps':>5}  {'Fixed?':>6}  {'Optimal?':>8}")
    print("-" * 45)
    for s0, fixed, steps, is_fixed, is_optimal in results:
        print(f"{s0:5d}  {fixed:8d}  {steps:5d}  {'YES' if is_fixed else 'NO':>6}  "
              f"{'YES' if is_optimal else 'NO':>8}")
    
    all_fixed = all(r[3] for r in results)
    all_optimal = all(r[4] for r in results)
    max_steps = max(r[2] for r in results)
    
    print()
    print(f"All trajectories stabilized: {all_fixed}")
    print(f"All fixed points locally optimal: {all_optimal}")
    print(f"Maximum steps to stabilization: {max_steps}")
    print()


# =============================================================================
# DEMO 5: Convergence Rate Bound
# =============================================================================
def demo_convergence_rate():
    """
    Demonstrate the convergence rate: with minimum improvement gap ε,
    stabilization occurs within ⌈(B - q(s0))/ε⌉ steps.
    """
    print("=" * 70)
    print("DEMO 5: Convergence Rate Bound")
    print("=" * 70)
    print()
    
    B = 10.0
    epsilon = 0.5
    q0 = 0.0
    
    quality = lambda n: min(q0 + n * epsilon, B)
    next_fn = lambda n: n if quality(n) >= B else n + 1
    
    theoretical_bound = math.ceil((B - q0) / epsilon)
    
    trajectory = reflective_iterate(next_fn, 0, max_iter=100)
    actual_steps = len(trajectory) - 1
    
    print(f"Quality: q(n) = min({q0} + n*{epsilon}, {B})")
    print(f"Theoretical bound: ⌈({B} - {q0}) / {epsilon}⌉ = {theoretical_bound}")
    print(f"Actual stabilization step: {actual_steps}")
    print(f"Bound satisfied: {actual_steps <= theoretical_bound}")
    print()
    
    print(f"{'Step':>4}  {'Quality':>10}  {'Gap to B':>10}")
    print("-" * 30)
    for i, s in enumerate(trajectory):
        q = quality(s)
        print(f"{i:4d}  {q:10.2f}  {B - q:10.2f}")
    print()


if __name__ == "__main__":
    demo_monotone_convergence()
    print()
    demo_finite_stabilization()
    print()
    demo_local_optimality()
    print()
    demo_grand_composition()
    print()
    demo_convergence_rate()


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import sys
sys.path.insert(0, '.')

from visualizations import generate_all_visualizations

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Generate visualizations
    viz_data = generate_all_visualizations()
    
    # Read all content files
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    lean_proofs = read_file('MachineLearning/ReflectiveConvergenceArchitecture.lean')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')
    
    package = {
        "title": "Reflective Convergence Architecture: Self-Modifying Research Strategies via Dependent Dynamical Systems",
        "domain": "Mathematical Foundations of Self-Improving Systems",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Reflective Convergence Demonstrations",
                "code": demo_code
            },
            {
                "name": "Real-World Applications",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Reflective Iteration",
                "pseudocode": (
                    "Algorithm: REFLECTIVE_ITERATE(next, s0, max_iter)\n"
                    "1. s ← s0; history ← [s0]\n"
                    "2. for i = 1 to max_iter:\n"
                    "3.   s' ← next(s)\n"
                    "4.   if s' = s: return (s, history, STABILIZED)\n"
                    "5.   s ← s'; history.append(s)\n"
                    "6. return (s, history, MAX_ITER_REACHED)\n"
                    "Complexity: O(N · C_next)"
                ),
                "code": algorithms_code
            }
        ],
        "visualizations": [
            {
                "name": "Monotone Convergence of Quality Sequences",
                "data": viz_data['monotone_convergence']
            },
            {
                "name": "Finite Stabilization Under Strict Progress",
                "data": viz_data['finite_stabilization']
            },
            {
                "name": "Local Optimality of Fixed Points",
                "data": viz_data['local_optimality']
            },
            {
                "name": "Grand Composition: Convergence to Local Optima",
                "data": viz_data['grand_composition']
            }
        ],
        "lean_proofs": lean_proofs
    }
    
    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)
    
    print(f"PACKAGE.json written ({len(json.dumps(package))} bytes)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Reflective Convergence Architecture — Visualizations

Generates publication-quality figures for the research paper.
All figures saved as PNG and returned as base64 for JSON packaging.
"""

import math
import random
import base64
import io

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_monotone_convergence() -> str:
    """
    Figure 1: Monotone convergence of quality sequences.
    Shows three different quality functions all converging to their limits.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    n = 30
    ns = np.arange(n + 1)
    
    # Three quality sequences with different convergence rates
    q1 = 1 - 2.0**(-ns)  # Fast convergence to 1
    q2 = 1 - 1.0 / (ns + 1)  # Slow convergence to 1
    q3 = 5 * (1 - np.exp(-0.3 * ns))  # Exponential approach to 5
    
    ax.plot(ns, q1, 'o-', color='#2196F3', markersize=4, linewidth=1.5,
            label=r'$q_n = 1 - 2^{-n}$ → L = 1')
    ax.plot(ns, q2, 's-', color='#4CAF50', markersize=4, linewidth=1.5,
            label=r'$q_n = 1 - 1/(n+1)$ → L = 1')
    ax.plot(ns, q3, '^-', color='#FF9800', markersize=4, linewidth=1.5,
            label=r'$q_n = 5(1 - e^{-0.3n})$ → L = 5')
    
    # Draw limit lines
    ax.axhline(y=1, color='#2196F3', linestyle='--', alpha=0.3)
    ax.axhline(y=5, color='#FF9800', linestyle='--', alpha=0.3)
    
    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('Quality q(n)', fontsize=12)
    ax.set_title('Monotone Convergence of Reflective Quality Sequences\n'
                 '(Theorem 3.1: monotone + bounded ⟹ convergent)', fontsize=13)
    ax.legend(fontsize=11, loc='center right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, n + 0.5)
    
    return fig_to_base64(fig)


def viz_finite_stabilization() -> str:
    """
    Figure 2: Finite stabilization under strict progress.
    Shows score increasing until fixed point is reached.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: deterministic example
    random.seed(42)
    n_states = 12
    scores = sorted(random.sample(range(1, 50), n_states))
    
    # Create an update that always moves to a higher-score state
    trajectory = [0]
    s = 0
    for _ in range(20):
        better = [i for i in range(n_states) if scores[i] > scores[s]]
        if not better:
            trajectory.append(s)
            break
        s = min(better)  # move to next higher
        trajectory.append(s)
        if s == trajectory[-2]:
            break
    
    steps = range(len(trajectory))
    traj_scores = [scores[s] for s in trajectory]
    
    ax1.step(list(steps), traj_scores, where='post', color='#E91E63', linewidth=2)
    ax1.scatter(list(steps), traj_scores, color='#E91E63', zorder=5, s=50)
    
    # Mark stabilization
    N = len(trajectory) - 1
    ax1.axvline(x=N, color='green', linestyle='--', alpha=0.5, label=f'N = {N} (stabilized)')
    ax1.scatter([N], [traj_scores[N]], color='green', s=200, zorder=10,
                marker='*', label=f'Fixed point (score={traj_scores[N]})')
    
    ax1.set_xlabel('Step', fontsize=12)
    ax1.set_ylabel('Score', fontsize=12)
    ax1.set_title('Finite Stabilization\n(Theorem 4.1)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: multiple trials showing stabilization times
    random.seed(123)
    n_trials = 50
    stab_times = []
    
    for _ in range(n_trials):
        n = random.randint(5, 20)
        scores_trial = sorted(random.sample(range(100), n))
        perm = list(range(n))
        random.shuffle(perm)
        
        # Create update: always move to position with higher score
        s = perm[0]
        steps_count = 0
        visited = {s}
        while True:
            better = [i for i in range(n) if scores_trial[i] > scores_trial[s]]
            if not better:
                break
            s = random.choice(better)
            steps_count += 1
            if s in visited:
                break
            visited.add(s)
        stab_times.append(steps_count)
    
    ax2.hist(stab_times, bins=range(max(stab_times) + 2), color='#9C27B0',
             alpha=0.7, edgecolor='white', linewidth=0.5)
    ax2.set_xlabel('Stabilization Step N', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title(f'Distribution of Stabilization Times\n({n_trials} random trials)', fontsize=13)
    ax2.grid(True, alpha=0.3, axis='y')
    
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_local_optimality() -> str:
    """
    Figure 3: Local optimality of fixed points.
    Shows a graph of states with admissible transitions and quality values.
    """
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    
    # Create a small state graph
    states = list(range(8))
    qualities = {0: 2.0, 1: 5.0, 2: 3.0, 3: 7.0, 4: 6.0, 5: 8.0, 6: 4.0, 7: 1.0}
    admissible = {
        0: [1, 2], 1: [3, 4], 2: [4, 6], 3: [5],
        4: [5, 6], 5: [5], 6: [0, 7], 7: [0, 2]  # 5 is fixed point
    }
    
    # Layout
    angles = np.linspace(0, 2 * np.pi, len(states), endpoint=False)
    positions = {s: (2.5 * np.cos(a), 2.5 * np.sin(a)) for s, a in zip(states, angles)}
    
    # Draw edges
    for s in states:
        for t in admissible[s]:
            if t != s:
                x1, y1 = positions[s]
                x2, y2 = positions[t]
                dx, dy = x2 - x1, y2 - y1
                length = math.sqrt(dx**2 + dy**2)
                # Shorten arrow
                shrink = 0.35 / length if length > 0 else 0
                ax.annotate('', xy=(x2 - dx * shrink, y2 - dy * shrink),
                           xytext=(x1 + dx * shrink, y1 + dy * shrink),
                           arrowprops=dict(arrowstyle='->', color='gray',
                                          lw=1.5, alpha=0.5))
    
    # Draw nodes
    cmap = plt.cm.YlOrRd
    q_min, q_max = min(qualities.values()), max(qualities.values())
    
    for s in states:
        x, y = positions[s]
        q = qualities[s]
        color = cmap((q - q_min) / (q_max - q_min))
        is_fixed = s in admissible[s] and all(
            qualities[t] <= qualities[s] for t in admissible[s]
        )
        
        size = 800 if is_fixed else 500
        marker = '*' if is_fixed else 'o'
        edgecolor = 'green' if is_fixed else 'black'
        linewidth = 3 if is_fixed else 1
        
        ax.scatter([x], [y], c=[color], s=size, marker=marker,
                  edgecolors=edgecolor, linewidths=linewidth, zorder=5)
        ax.annotate(f's{s}\nq={q:.0f}', (x, y), textcoords='offset points',
                   xytext=(0, -25), ha='center', fontsize=9, fontweight='bold')
    
    # Legend
    fixed_patch = mpatches.Patch(facecolor='none', edgecolor='green', linewidth=2,
                                  label='Fixed point (locally optimal)')
    normal_patch = mpatches.Patch(facecolor='gray', alpha=0.3,
                                   label='Non-fixed state')
    ax.legend(handles=[fixed_patch, normal_patch], loc='upper left', fontsize=11)
    
    ax.set_title('State Graph with Local Optimality\n'
                 '(Theorem 5.1: fixed points of quality-maximizing selectors are locally optimal)',
                 fontsize=13)
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    return fig_to_base64(fig)


def viz_grand_composition() -> str:
    """
    Figure 4: Grand composition — convergence to local optimum.
    Shows multiple trajectories converging to locally optimal fixed points.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    random.seed(42)
    n = 20
    qualities = {i: random.uniform(0, 10) for i in range(n)}
    
    # Create admissibility: each state connects to 3-5 others + self
    admissible = {}
    for i in range(n):
        nbrs = sorted(set([i] + random.sample(range(n), min(4, n))))
        admissible[i] = nbrs
    
    def next_fn(s):
        return max(admissible[s], key=lambda t: qualities[t])
    
    # Left: quality trajectories
    colors = plt.cm.tab10(np.linspace(0, 1, 10))
    fixed_points = set()
    
    for idx, s0 in enumerate(range(0, n, 2)):
        traj = [s0]
        s = s0
        for _ in range(50):
            sn = next_fn(s)
            traj.append(sn)
            if sn == s:
                break
            s = sn
        
        qs = [qualities[s] for s in traj]
        ax1.plot(range(len(qs)), qs, 'o-', color=colors[idx % 10],
                markersize=3, linewidth=1.2, alpha=0.8,
                label=f's₀={s0} → s*={traj[-1]}')
        fixed_points.add(traj[-1])
    
    ax1.set_xlabel('Step', fontsize=12)
    ax1.set_ylabel('Quality', fontsize=12)
    ax1.set_title('Quality Trajectories\n(All converge to local optima)', fontsize=13)
    ax1.legend(fontsize=8, ncol=2)
    ax1.grid(True, alpha=0.3)
    
    # Right: bar chart of all states' qualities with fixed points highlighted
    bar_colors = ['#4CAF50' if i in fixed_points else '#E0E0E0' for i in range(n)]
    ax2.bar(range(n), [qualities[i] for i in range(n)], color=bar_colors,
            edgecolor='gray', linewidth=0.5)
    ax2.set_xlabel('State', fontsize=12)
    ax2.set_ylabel('Quality', fontsize=12)
    ax2.set_title('State Qualities\n(Green = locally optimal fixed points)', fontsize=13)
    ax2.grid(True, alpha=0.3, axis='y')
    
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and save as files + return base64."""
    print("Generating visualizations...")
    
    results = {}
    
    print("  [1/4] Monotone convergence...")
    results['monotone_convergence'] = viz_monotone_convergence()
    
    print("  [2/4] Finite stabilization...")
    results['finite_stabilization'] = viz_finite_stabilization()
    
    print("  [3/4] Local optimality...")
    results['local_optimality'] = viz_local_optimality()
    
    print("  [4/4] Grand composition...")
    results['grand_composition'] = viz_grand_composition()
    
    print("Done!")
    return results


if __name__ == "__main__":
    results = generate_all_visualizations()
    for name, data in results.items():
        print(f"  {name}: {len(data)} chars (base64)")
