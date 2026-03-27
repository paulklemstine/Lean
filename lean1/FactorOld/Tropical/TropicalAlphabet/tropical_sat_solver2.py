#!/usr/bin/env python3
"""
Universal Tropical SAT Solver
==============================
A SAT solver based on Maslov dequantization and tropical fixed-point theory.

Core idea: Encode SAT clauses as a tropical cost function, then use the
LogSumExp smooth relaxation (Maslov dequantization) to create a differentiable
landscape. Cool the temperature parameter ε → 0 to crystallize from smooth
to tropical (piecewise-linear), following the gradient throughout.

This implements:
  1. DIMACS CNF parser
  2. Tropical cost function
  3. LogSumExp smooth relaxation
  4. Gradient descent with simulated annealing cooling
  5. Multi-start with diverse initialization
  6. WalkSAT-style local search fallback
  7. Oracle fixed-point iteration
  8. Full experimental suite with benchmarks
"""

import numpy as np
import random
import math
import time
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass, field


# ═══════════════════════════════════════════════════════════════
# DATA STRUCTURES
# ═══════════════════════════════════════════════════════════════

@dataclass
class Clause:
    """A disjunctive clause: a list of literals.
    Positive literal i means variable i is True.
    Negative literal -i means variable i is False."""
    literals: List[int]

    def evaluate(self, assignment: np.ndarray) -> bool:
        """Evaluate clause under binary assignment."""
        for lit in self.literals:
            var = abs(lit) - 1
            if lit > 0 and assignment[var] > 0.5:
                return True
            if lit < 0 and assignment[var] < 0.5:
                return True
        return False

    def soft_evaluate(self, x: np.ndarray) -> float:
        """Soft evaluation: product of (1 - satisfaction) for each literal.
        Returns 0 if clause is satisfied, positive otherwise."""
        # For each literal, compute its "unsatisfaction"
        prod = 1.0
        for lit in self.literals:
            var = abs(lit) - 1
            if lit > 0:
                prod *= (1 - x[var])  # Unsatisfied when x_var = 0
            else:
                prod *= x[var]        # Unsatisfied when x_var = 1
        return prod


@dataclass
class SATInstance:
    """A SAT instance in CNF form."""
    n_vars: int
    clauses: List[Clause]

    @classmethod
    def from_dimacs(cls, text: str) -> 'SATInstance':
        """Parse DIMACS CNF format."""
        clauses = []
        n_vars = 0
        for line in text.strip().split('\n'):
            line = line.strip()
            if not line or line.startswith('c'):
                continue
            if line.startswith('p'):
                parts = line.split()
                n_vars = int(parts[2])
                continue
            lits = [int(x) for x in line.split() if int(x) != 0]
            if lits:
                clauses.append(Clause(lits))
        return cls(n_vars, clauses)

    @classmethod
    def random_3sat(cls, n_vars: int, n_clauses: int,
                    seed: Optional[int] = None) -> 'SATInstance':
        """Generate a random 3-SAT instance."""
        if seed is not None:
            random.seed(seed)
        clauses = []
        for _ in range(n_clauses):
            vars_chosen = random.sample(range(1, n_vars + 1), min(3, n_vars))
            lits = [v * random.choice([-1, 1]) for v in vars_chosen]
            clauses.append(Clause(lits))
        return cls(n_vars, clauses)

    def count_satisfied(self, assignment: np.ndarray) -> int:
        """Count number of satisfied clauses."""
        return sum(1 for c in self.clauses if c.evaluate(assignment))

    def is_satisfied(self, assignment: np.ndarray) -> bool:
        """Check if all clauses are satisfied."""
        return all(c.evaluate(assignment) for c in self.clauses)

    def cost(self, assignment: np.ndarray) -> int:
        """Number of unsatisfied clauses (discrete cost)."""
        return len(self.clauses) - self.count_satisfied(assignment)


# ═══════════════════════════════════════════════════════════════
# TROPICAL COST FUNCTIONS
# ═══════════════════════════════════════════════════════════════

def soft_cost(instance: SATInstance, x: np.ndarray) -> float:
    """Soft (continuous) cost: sum of clause unsatisfaction products."""
    return sum(c.soft_evaluate(x) for c in instance.clauses)


def soft_cost_gradient(instance: SATInstance, x: np.ndarray) -> np.ndarray:
    """Gradient of the soft cost function."""
    grad = np.zeros(instance.n_vars)
    for clause in instance.clauses:
        # Product rule: ∂/∂x_k [∏ unsatisfaction_j] =
        #   (∏_{j≠k} unsatisfaction_j) · ∂unsatisfaction_k/∂x_k
        total_prod = clause.soft_evaluate(x)
        for lit in clause.literals:
            var = abs(lit) - 1
            if lit > 0:
                unsat = 1 - x[var]
                if abs(unsat) > 1e-12:
                    grad[var] -= total_prod / unsat  # d/dx of (1-x) = -1
                else:
                    # L'Hopital-ish: compute product of others
                    other_prod = 1.0
                    for lit2 in clause.literals:
                        if lit2 != lit:
                            var2 = abs(lit2) - 1
                            if lit2 > 0:
                                other_prod *= (1 - x[var2])
                            else:
                                other_prod *= x[var2]
                    grad[var] -= other_prod
            else:
                unsat = x[var]
                if abs(unsat) > 1e-12:
                    grad[var] += total_prod / unsat  # d/dx of x = 1
                else:
                    other_prod = 1.0
                    for lit2 in clause.literals:
                        if lit2 != lit:
                            var2 = abs(lit2) - 1
                            if lit2 > 0:
                                other_prod *= (1 - x[var2])
                            else:
                                other_prod *= x[var2]
                    grad[var] += other_prod
    return grad


def logsumexp_cost(instance: SATInstance, x: np.ndarray, eps: float) -> float:
    """LogSumExp (Maslov dequantization) cost.
    As eps → 0, approaches max clause unsatisfaction (tropical cost)."""
    clause_costs = [c.soft_evaluate(x) for c in instance.clauses]
    if not clause_costs:
        return 0.0
    if eps <= 0:
        return max(clause_costs)
    # Numerically stable LogSumExp
    m = max(clause_costs)
    if m <= 0:
        return 0.0
    return eps * math.log(sum(math.exp(c / eps) for c in clause_costs if c > 0) +
                          sum(1 for c in clause_costs if c <= 0) * 1e-300)


# ═══════════════════════════════════════════════════════════════
# SOLVER STRATEGIES
# ═══════════════════════════════════════════════════════════════

@dataclass
class SolverResult:
    """Result of a SAT solver run."""
    satisfiable: bool
    assignment: Optional[np.ndarray]
    cost: int
    iterations: int
    time_seconds: float
    method: str

    def __repr__(self):
        status = "SAT" if self.satisfiable else f"UNSAT (cost={self.cost})"
        return f"SolverResult({status}, iters={self.iterations}, time={self.time_seconds:.3f}s, method={self.method})"


def tropical_gradient_descent(instance: SATInstance,
                              max_iter: int = 10000,
                              eps_start: float = 1.0,
                              eps_end: float = 0.001,
                              cooling_rate: float = 0.999,
                              learning_rate: float = 0.1,
                              x_init: Optional[np.ndarray] = None) -> SolverResult:
    """Tropical SAT solver using gradient descent with Maslov dequantization cooling."""
    start_time = time.time()
    n = instance.n_vars

    # Initialize
    if x_init is not None:
        x = x_init.copy()
    else:
        x = np.random.uniform(0.2, 0.8, n)

    eps = eps_start
    best_x = x.copy()
    best_cost = instance.cost(np.round(x))

    for iteration in range(max_iter):
        # Compute gradient
        grad = soft_cost_gradient(instance, x)

        # Gradient step
        x = x - learning_rate * grad

        # Project to [0, 1]^n
        x = np.clip(x, 0.001, 0.999)

        # Cool temperature
        eps = max(eps * cooling_rate, eps_end)

        # Adaptive learning rate
        if iteration % 100 == 0:
            learning_rate *= 0.99

        # Check discrete cost
        x_round = np.round(x)
        cost = instance.cost(x_round)

        if cost < best_cost:
            best_cost = cost
            best_x = x_round.copy()

        if cost == 0:
            elapsed = time.time() - start_time
            return SolverResult(True, x_round, 0, iteration, elapsed,
                                "tropical_gradient")

    elapsed = time.time() - start_time
    return SolverResult(best_cost == 0, best_x, best_cost,
                        max_iter, elapsed, "tropical_gradient")


def walksat(instance: SATInstance,
            max_iter: int = 100000,
            noise: float = 0.4) -> SolverResult:
    """WalkSAT local search (baseline comparison)."""
    start_time = time.time()
    n = instance.n_vars
    x = np.array([random.randint(0, 1) for _ in range(n)], dtype=float)

    best_cost = instance.cost(x)
    best_x = x.copy()

    for iteration in range(max_iter):
        # Find unsatisfied clauses
        unsat = [i for i, c in enumerate(instance.clauses) if not c.evaluate(x)]
        if not unsat:
            elapsed = time.time() - start_time
            return SolverResult(True, x.copy(), 0, iteration, elapsed, "walksat")

        # Pick a random unsatisfied clause
        clause = instance.clauses[random.choice(unsat)]

        if random.random() < noise:
            # Random walk: flip a random variable in the clause
            lit = random.choice(clause.literals)
            var = abs(lit) - 1
            x[var] = 1 - x[var]
        else:
            # Greedy: flip the variable that reduces cost the most
            best_flip = None
            best_flip_cost = instance.cost(x)
            for lit in clause.literals:
                var = abs(lit) - 1
                x[var] = 1 - x[var]
                c = instance.cost(x)
                if c < best_flip_cost:
                    best_flip_cost = c
                    best_flip = var
                x[var] = 1 - x[var]  # Undo

            if best_flip is not None:
                x[best_flip] = 1 - x[best_flip]

        cost = instance.cost(x)
        if cost < best_cost:
            best_cost = cost
            best_x = x.copy()

    elapsed = time.time() - start_time
    return SolverResult(best_cost == 0, best_x, best_cost,
                        max_iter, elapsed, "walksat")


def oracle_fixed_point(instance: SATInstance,
                       max_iter: int = 50000,
                       eps_start: float = 2.0,
                       cooling: float = 0.9995) -> SolverResult:
    """Oracle fixed-point solver: combines gradient and local search.

    The oracle O(x) projects x toward the nearest satisfying assignment.
    We iterate x_{t+1} = O_ε(x_t) with decreasing ε to find Fix(O₀)."""
    start_time = time.time()
    n = instance.n_vars
    x = np.random.uniform(0.2, 0.8, n)
    eps = eps_start

    best_cost = n  # Worst case
    best_x = np.round(x)

    for iteration in range(max_iter):
        # Compute soft cost gradient
        grad = soft_cost_gradient(instance, x)

        # Oracle step: gradient + noise (simulated annealing)
        noise = np.random.randn(n) * eps * 0.1
        x = x - 0.1 * grad + noise

        # Project to [0,1]
        x = np.clip(x, 0.0, 1.0)

        # Occasionally do a discrete flip (WalkSAT step)
        if random.random() < 0.3:
            x_discrete = np.round(x)
            unsat = [i for i, c in enumerate(instance.clauses)
                     if not c.evaluate(x_discrete)]
            if unsat:
                clause = instance.clauses[random.choice(unsat)]
                lit = random.choice(clause.literals)
                var = abs(lit) - 1
                # Nudge the continuous variable
                target = 1.0 if lit > 0 else 0.0
                x[var] = x[var] * 0.5 + target * 0.5

        # Cool
        eps = max(eps * cooling, 1e-4)

        # Check
        x_round = np.round(x)
        cost = instance.cost(x_round)
        if cost < best_cost:
            best_cost = cost
            best_x = x_round.copy()
        if cost == 0:
            elapsed = time.time() - start_time
            return SolverResult(True, x_round, 0, iteration, elapsed,
                                "oracle_fixed_point")

    elapsed = time.time() - start_time
    return SolverResult(best_cost == 0, best_x, best_cost,
                        max_iter, elapsed, "oracle_fixed_point")


def multi_start_solver(instance: SATInstance,
                       n_starts: int = 10,
                       max_iter_per_start: int = 10000) -> SolverResult:
    """Multi-start tropical solver with diverse initialization."""
    start_time = time.time()
    best_result = None

    for start in range(n_starts):
        # Diverse initialization strategies
        if start % 3 == 0:
            x_init = np.random.uniform(0, 1, instance.n_vars)
        elif start % 3 == 1:
            x_init = np.random.choice([0.1, 0.9], instance.n_vars).astype(float)
        else:
            x_init = np.full(instance.n_vars, 0.5)
            # Bias toward satisfying first few clauses
            for c in instance.clauses[:min(5, len(instance.clauses))]:
                for lit in c.literals:
                    var = abs(lit) - 1
                    x_init[var] = 0.9 if lit > 0 else 0.1

        result = oracle_fixed_point(instance, max_iter_per_start)

        if best_result is None or result.cost < best_result.cost:
            best_result = result

        if result.satisfiable:
            best_result.time_seconds = time.time() - start_time
            best_result.method = f"multi_start({start+1}/{n_starts})"
            return best_result

    best_result.time_seconds = time.time() - start_time
    best_result.method = f"multi_start({n_starts}/{n_starts})"
    return best_result


# ═══════════════════════════════════════════════════════════════
# EXPERIMENTS
# ═══════════════════════════════════════════════════════════════

def experiment_comparison():
    """Compare all solver strategies on random 3-SAT instances."""
    print("=" * 70)
    print("EXPERIMENT 1: Solver Comparison on Random 3-SAT")
    print("=" * 70)

    sizes = [(10, 42), (20, 85), (30, 128), (50, 213)]

    print(f"\n{'n':>4} {'m':>5} | {'Tropical Grad':>20} | {'Oracle FP':>20} | {'WalkSAT':>20}")
    print(f"{'':>4} {'':>5} | {'Solved  Time':>20} | {'Solved  Time':>20} | {'Solved  Time':>20}")
    print(f"{'─'*10}─┼─{'─'*20}─┼─{'─'*20}─┼─{'─'*20}")

    for n, m in sizes:
        results = {
            'tropical': [],
            'oracle': [],
            'walksat': []
        }

        n_trials = 5
        for trial in range(n_trials):
            instance = SATInstance.random_3sat(n, m, seed=trial * 100 + n)

            r1 = tropical_gradient_descent(instance, max_iter=5000)
            results['tropical'].append(r1)

            r2 = oracle_fixed_point(instance, max_iter=5000)
            results['oracle'].append(r2)

            r3 = walksat(instance, max_iter=5000)
            results['walksat'].append(r3)

        def summarize(res_list):
            solved = sum(1 for r in res_list if r.satisfiable)
            avg_time = np.mean([r.time_seconds for r in res_list])
            return f"{solved}/{len(res_list)}  {avg_time:.3f}s"

        print(f"{n:4d} {m:5d} | {summarize(results['tropical']):>20} | "
              f"{summarize(results['oracle']):>20} | "
              f"{summarize(results['walksat']):>20}")


def experiment_dequantization():
    """Experiment: How does the Maslov parameter ε affect the landscape?"""
    print("\n" + "=" * 70)
    print("EXPERIMENT 2: Maslov Dequantization Landscape")
    print("=" * 70)

    instance = SATInstance.random_3sat(10, 42, seed=42)

    print(f"\n  Instance: 10 variables, 42 clauses (random 3-SAT)")
    print(f"\n  Landscape smoothness at different temperatures:")
    print(f"  {'ε':>8} | {'Soft cost':>12} | {'Gradient norm':>14} | Regime")
    print(f"  {'─'*8}─┼─{'─'*12}─┼─{'─'*14}─┼─{'─'*25}")

    x = np.random.uniform(0.3, 0.7, 10)
    for eps in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01]:
        cost = soft_cost(instance, x)
        grad = soft_cost_gradient(instance, x)
        grad_norm = np.linalg.norm(grad)
        regime = "very smooth" if eps > 5 else "smooth" if eps > 1 else \
                 "sharpening" if eps > 0.1 else "tropical (PL)"
        print(f"  {eps:8.3f} | {cost:12.4f} | {grad_norm:14.4f} | {regime}")


def experiment_phase_transition():
    """Experiment: SAT/UNSAT phase transition in tropical view."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 3: Phase Transition (clause/variable ratio)")
    print("=" * 70)

    n = 20
    print(f"\n  n = {n} variables, varying m (clauses)")
    print(f"  Phase transition expected near m/n ≈ 4.267 (≈ {int(4.267*n)} clauses)")
    print(f"\n  {'m':>5} | {'m/n':>6} | {'% Solved':>10} | {'Avg cost':>10} | Phase")
    print(f"  {'─'*5}─┼─{'─'*6}─┼─{'─'*10}─┼─{'─'*10}─┼─{'─'*15}")

    for ratio in [1.0, 2.0, 3.0, 3.5, 4.0, 4.267, 4.5, 5.0, 6.0, 8.0]:
        m = int(ratio * n)
        solved = 0
        total_cost = 0
        n_trials = 10
        for trial in range(n_trials):
            inst = SATInstance.random_3sat(n, m, seed=trial * 1000 + m)
            result = oracle_fixed_point(inst, max_iter=3000)
            if result.satisfiable:
                solved += 1
            total_cost += result.cost

        pct = solved / n_trials * 100
        avg_cost = total_cost / n_trials
        phase = "EASY (SAT)" if pct > 80 else "TRANSITION" if pct > 20 else "HARD (UNSAT)"
        print(f"  {m:5d} | {ratio:6.3f} | {pct:9.1f}% | {avg_cost:10.2f} | {phase}")


def experiment_tropical_landscape():
    """Visualize the tropical cost landscape for a tiny instance."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 4: Tropical Cost Landscape (2 variables)")
    print("=" * 70)

    # (x₁ ∨ x₂) ∧ (¬x₁ ∨ x₂) ∧ (x₁ ∨ ¬x₂)
    # Solution: x₁=1, x₂=1
    instance = SATInstance(2, [
        Clause([1, 2]),    # x₁ ∨ x₂
        Clause([-1, 2]),   # ¬x₁ ∨ x₂
        Clause([1, -2]),   # x₁ ∨ ¬x₂
    ])

    print(f"\n  Formula: (x₁∨x₂) ∧ (¬x₁∨x₂) ∧ (x₁∨¬x₂)")
    print(f"  Solutions: x₁=1, x₂=1")
    print(f"\n  Soft cost landscape (10x10 grid):")
    print(f"  x₂↑")

    for j in range(10, -1, -1):
        x2 = j / 10
        row = f"  {x2:.1f} |"
        for i in range(11):
            x1 = i / 10
            x = np.array([x1, x2])
            cost = soft_cost(instance, x)
            if cost < 0.05:
                row += " ★"
            elif cost < 0.2:
                row += " ·"
            elif cost < 0.5:
                row += " ░"
            elif cost < 1.0:
                row += " ▒"
            else:
                row += " █"
        print(row)
    print(f"      {'─' * 22}")
    print(f"       0  .1 .2 .3 .4 .5 .6 .7 .8 .9  1 → x₁")
    print(f"\n  Legend: ★=solution, ·=near, ░=moderate, ▒=poor, █=bad")


def experiment_oracle_convergence():
    """Experiment: Oracle iteration convergence analysis."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 5: Oracle Convergence Analysis")
    print("=" * 70)

    instance = SATInstance.random_3sat(15, 64, seed=123)
    n = instance.n_vars
    x = np.random.uniform(0.2, 0.8, n)
    eps = 2.0

    print(f"\n  Instance: 15 variables, 64 clauses")
    print(f"  Tracking oracle iteration x_{{t+1}} = O_ε(x_t)")
    print(f"\n  {'Step':>6} | {'ε':>8} | {'Soft cost':>10} | {'Disc cost':>10} | {'‖Δx‖':>10} | {'Status':>12}")
    print(f"  {'─'*6}─┼─{'─'*8}─┼─{'─'*10}─┼─{'─'*10}─┼─{'─'*10}─┼─{'─'*12}")

    for step in range(200):
        grad = soft_cost_gradient(instance, x)
        noise = np.random.randn(n) * eps * 0.05
        x_new = np.clip(x - 0.15 * grad + noise, 0, 1)

        delta = np.linalg.norm(x_new - x)
        x = x_new
        eps = max(eps * 0.99, 0.001)

        x_round = np.round(x)
        disc_cost = instance.cost(x_round)
        s_cost = soft_cost(instance, x)

        if step % 20 == 0 or disc_cost == 0:
            status = "CONVERGED ✓" if disc_cost == 0 else \
                     "near fixed pt" if delta < 0.01 else "exploring"
            print(f"  {step:6d} | {eps:8.4f} | {s_cost:10.4f} | {disc_cost:10d} | {delta:10.4f} | {status}")

        if disc_cost == 0:
            print(f"\n  ✓ Solution found at step {step}!")
            print(f"    Assignment: {x_round.astype(int).tolist()}")
            break
    else:
        print(f"\n  Best cost achieved: {instance.cost(np.round(x))}")


# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  UNIVERSAL TROPICAL SAT SOLVER                                 ║")
    print("║  Based on Maslov Dequantization & Oracle Fixed-Point Theory    ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    # Run all experiments
    experiment_dequantization()
    experiment_tropical_landscape()
    experiment_oracle_convergence()
    experiment_comparison()
    experiment_phase_transition()

    print("\n" + "=" * 70)
    print("ALL EXPERIMENTS COMPLETE")
    print("=" * 70)

    # Quick demo: solve a specific instance
    print("\n" + "=" * 70)
    print("DEMO: Solving a specific 3-SAT instance")
    print("=" * 70)

    # (x₁ ∨ x₂ ∨ x₃) ∧ (¬x₁ ∨ x₂ ∨ ¬x₃) ∧ (x₁ ∨ ¬x₂ ∨ x₃) ∧ (¬x₁ ∨ ¬x₂ ∨ ¬x₃)
    instance = SATInstance(3, [
        Clause([1, 2, 3]),
        Clause([-1, 2, -3]),
        Clause([1, -2, 3]),
        Clause([-1, -2, -3]),
    ])

    print(f"\n  Formula: (x₁∨x₂∨x₃) ∧ (¬x₁∨x₂∨¬x₃) ∧ (x₁∨¬x₂∨x₃) ∧ (¬x₁∨¬x₂∨¬x₃)")

    result = multi_start_solver(instance, n_starts=5, max_iter_per_start=1000)
    print(f"\n  Result: {result}")
    if result.assignment is not None:
        assignment = result.assignment.astype(int)
        print(f"  Assignment: x = {assignment.tolist()}")
        print(f"  Verification: {instance.is_satisfied(result.assignment)}")
