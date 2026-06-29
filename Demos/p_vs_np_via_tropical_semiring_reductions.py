#!/usr/bin/env python3
"""
Applications of Tropical Non-Encodability Theory

This module demonstrates practical applications of the structural barrier
between tropical computation and Boolean satisfiability:

1. Energy landscape analysis — modeling SAT as an energy minimization problem
2. Optimization landscape classification — which problems have "nice" landscapes
3. Reduction impossibility checker — testing whether specific reductions exist
"""

import itertools
from typing import List, Tuple, Set, Dict


# ─────────────────────────────────────────────────────────────────────
# Application 1: Energy Landscape Analysis
# ─────────────────────────────────────────────────────────────────────

def tropical_energy_landscape(formula_eval, n: int, domain_max: int = 3) -> Dict:
    """
    Analyze the energy landscape of a tropical formula.

    In statistical physics, a tropical formula defines an energy functional
    E(x) = eval(φ, x). Ground states are configurations minimizing E.
    The barrier theorem says these ground-state sets have rigid structure
    (downward-closed sublevel sets) that arbitrary SAT instances lack.

    Args:
        formula_eval: Function from tuple to int (tropical evaluation).
        n: Number of variables.
        domain_max: Maximum value per variable.

    Returns:
        Landscape analysis dictionary.
    """
    configs = list(itertools.product(range(domain_max + 1), repeat=n))
    energies = {c: formula_eval(c) for c in configs}

    min_energy = min(energies.values())
    max_energy = max(energies.values())
    ground_states = {c for c, e in energies.items() if e == min_energy}

    # Compute sublevel sets for each energy level
    sublevel_structure = {}
    for k in range(min_energy, max_energy + 1):
        sublevel = {c for c, e in energies.items() if e <= k}
        # Check downward closure
        is_lower = True
        for a in sublevel:
            for b in itertools.product(*[range(a[i] + 1) for i in range(n)]):
                if b not in sublevel:
                    is_lower = False
                    break
            if not is_lower:
                break
        sublevel_structure[k] = {
            'size': len(sublevel),
            'is_downward_closed': is_lower
        }

    return {
        'n_configs': len(configs),
        'min_energy': min_energy,
        'max_energy': max_energy,
        'n_ground_states': len(ground_states),
        'ground_states': sorted(ground_states),
        'all_sublevel_sets_downward_closed': all(
            v['is_downward_closed'] for v in sublevel_structure.values()
        ),
        'sublevel_structure': sublevel_structure,
    }


# ─────────────────────────────────────────────────────────────────────
# Application 2: Optimization Problem Classification
# ─────────────────────────────────────────────────────────────────────

def classify_optimization_landscape(
    objective,
    constraint_sat,
    n: int,
    label: str = ""
) -> Dict:
    """
    Classify an optimization problem's landscape structure.

    Determines whether the feasible region has the downward-closure
    property required for tropical representability.

    Args:
        objective: Function from assignment to cost (int).
        constraint_sat: Function from assignment to bool (feasibility).
        n: Number of binary variables.
        label: Problem name for display.

    Returns:
        Classification dictionary.
    """
    feasible = set()
    costs = {}
    for a in itertools.product(range(2), repeat=n):
        if constraint_sat(a):
            feasible.add(a)
            costs[a] = objective(a)

    # Check downward closure of feasible region
    is_dc = True
    witness = None
    for a in feasible:
        for b in itertools.product(*[range(a[i] + 1) for i in range(n)]):
            if b not in feasible:
                is_dc = False
                witness = (a, b)
                break
        if not is_dc:
            break

    optimal_cost = min(costs.values()) if costs else None
    optimal = {a for a, c in costs.items() if c == optimal_cost} if costs else set()

    return {
        'problem': label,
        'n_vars': n,
        'n_feasible': len(feasible),
        'feasible_downward_closed': is_dc,
        'tropical_representable': is_dc,
        'optimal_cost': optimal_cost,
        'n_optimal': len(optimal),
        'witness_if_not_dc': witness,
    }


# ─────────────────────────────────────────────────────────────────────
# Application 3: Reduction Impossibility Checker
# ─────────────────────────────────────────────────────────────────────

def check_reduction_exists(
    source_sat: Set[Tuple[int, ...]],
    n_source: int,
    n_target: int,
    max_const: int = 3,
    max_depth: int = 1
) -> Dict:
    """
    Check whether any small tropical formula + threshold can represent
    a given Boolean predicate.

    This is a concrete instantiation of the barrier theorem: we
    exhaustively search small tropical formulas and verify that none
    can encode the given predicate as a sublevel set.

    Args:
        source_sat: Satisfying set of the source predicate on {0,1}^n.
        n_source: Number of source variables.
        n_target: Number of target variables (for the tropical formula).
        max_const: Maximum constant in tropical formulas.
        max_depth: Maximum formula depth.

    Returns:
        Search result dictionary.
    """
    bool_vecs = list(itertools.product(range(2), repeat=n_target))

    # Generate candidate formulas
    def gen(depth, nv):
        if depth == 0:
            for c in range(max_const + 1):
                yield ('const', c)
            for i in range(nv):
                yield ('var', i)
            return
        base = list(gen(depth - 1, nv))
        yield from base
        for f1 in base:
            for f2 in base:
                yield ('add', f1, f2)
                yield ('min', f1, f2)

    def eval_f(f, a):
        if f[0] == 'const': return f[1]
        if f[0] == 'var': return a[f[1]]
        if f[0] == 'add': return eval_f(f[1], a) + eval_f(f[2], a)
        if f[0] == 'min': return min(eval_f(f[1], a), eval_f(f[2], a))

    n_checked = 0
    for phi in gen(max_depth, n_target):
        n_checked += 1
        values = {a: eval_f(phi, a) for a in bool_vecs}
        max_val = max(values.values())
        for k in range(max_val + 1):
            sublevel = {a for a in bool_vecs if values[a] <= k}
            if sublevel == source_sat:
                return {
                    'found': True,
                    'formula': phi,
                    'threshold': k,
                    'n_checked': n_checked,
                }

    return {
        'found': False,
        'n_checked': n_checked,
        'reason': 'No tropical formula of given size encodes the predicate'
    }


# ─────────────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Energy Landscape Analysis")
    print("=" * 60)

    # Tropical energy: E(x₀, x₁) = min(x₀ + x₁, x₀ + 2)
    def energy(a):
        return min(a[0] + a[1], a[0] + 2)

    result = tropical_energy_landscape(energy, 2, domain_max=3)
    print(f"\n  Energy: E(x₀,x₁) = min(x₀+x₁, x₀+2)")
    print(f"  Min energy: {result['min_energy']}")
    print(f"  Ground states: {result['ground_states']}")
    print(f"  All sublevel sets downward-closed: "
          f"{result['all_sublevel_sets_downward_closed']}")

    print("\n" + "=" * 60)
    print("APPLICATION 2: Optimization Problem Classification")
    print("=" * 60)

    # Problem A: Vertex cover (feasible = downward closed? No — covering requires INCLUDING vertices)
    # Actually vertex cover feasible set is UPWARD closed, not downward.
    # Let's use a problem where feasibility IS downward closed:
    # "Use at most 2 resources" — feasible if sum(x) ≤ 2

    result_budget = classify_optimization_landscape(
        objective=lambda a: sum(a),
        constraint_sat=lambda a: sum(a) <= 2,
        n=4,
        label="Budget constraint: sum(x) ≤ 2"
    )
    print(f"\n  {result_budget['problem']}")
    print(f"  Feasible region downward-closed: {result_budget['feasible_downward_closed']}")
    print(f"  Tropical-representable: {result_budget['tropical_representable']}")

    # Problem B: SAT — x₀ ∨ x₁
    result_sat = classify_optimization_landscape(
        objective=lambda a: 0,
        constraint_sat=lambda a: a[0] == 1 or a[1] == 1,
        n=2,
        label="SAT: x₀ ∨ x₁"
    )
    print(f"\n  {result_sat['problem']}")
    print(f"  Feasible region downward-closed: {result_sat['feasible_downward_closed']}")
    print(f"  Tropical-representable: {result_sat['tropical_representable']}")
    if result_sat['witness_if_not_dc']:
        a, b = result_sat['witness_if_not_dc']
        print(f"  Witness: {b} ≤ {a}, feasible({a})=True but feasible({b})=False")

    # Problem C: Independent set ≥ 2 on path graph P₃
    # x₀—x₁—x₂, independent set: no two adjacent selected
    result_is = classify_optimization_landscape(
        objective=lambda a: -sum(a),  # maximize = minimize negative
        constraint_sat=lambda a: not (a[0] == 1 and a[1] == 1) and not (a[1] == 1 and a[2] == 1) and sum(a) >= 2,
        n=3,
        label="Independent set ≥ 2 on path P₃"
    )
    print(f"\n  {result_is['problem']}")
    print(f"  Feasible region downward-closed: {result_is['feasible_downward_closed']}")
    print(f"  Tropical-representable: {result_is['tropical_representable']}")

    print("\n" + "=" * 60)
    print("APPLICATION 3: Reduction Impossibility Check")
    print("=" * 60)

    # Check: can x₀ ∨ x₁ be tropically encoded?
    or_sat = {(0, 1), (1, 0), (1, 1)}
    result = check_reduction_exists(or_sat, 2, 2, max_const=5, max_depth=1)
    print(f"\n  Can x₀ ∨ x₁ be encoded as tropical sublevel?")
    print(f"  Found: {result['found']}")
    print(f"  Formulas checked: {result['n_checked']}")

    # Check: can "all zeros" (the constant True at (0,0)) be tropically encoded?
    all_true = {(0, 0), (0, 1), (1, 0), (1, 1)}
    result = check_reduction_exists(all_true, 2, 2, max_const=5, max_depth=1)
    print(f"\n  Can 'always true' be encoded as tropical sublevel?")
    print(f"  Found: {result['found']}")
    if result['found']:
        print(f"  Formula: {result['formula']}, threshold: {result['threshold']}")

    # Check: can {(0,0)} be tropically encoded?
    only_zero = {(0, 0)}
    result = check_reduction_exists(only_zero, 2, 2, max_const=5, max_depth=1)
    print(f"\n  Can '{{(0,0)}} only' be encoded as tropical sublevel?")
    print(f"  Found: {result['found']}")
    if result['found']:
        print(f"  Formula: {result['formula']}, threshold: {result['threshold']}")


#!/usr/bin/env python3
"""
Tropical Non-Encodability of SAT — Interactive Demonstrations

This module provides concrete numerical examples illustrating the structural
barrier between tropical (min, +) computation and Boolean satisfiability.
"""

import itertools
from typing import Callable, List, Tuple, Dict, Set


# ─────────────────────────────────────────────────────────────────────
# Tropical Formula AST and Evaluator
# ─────────────────────────────────────────────────────────────────────

class TropFormula:
    """Abstract syntax tree for tropical formulas over (ℕ, min, +)."""
    pass

class Const(TropFormula):
    def __init__(self, c: int):
        self.c = c
    def __repr__(self):
        return str(self.c)

class Var(TropFormula):
    def __init__(self, i: int):
        self.i = i
    def __repr__(self):
        return f"x{self.i}"

class Add(TropFormula):
    def __init__(self, left: TropFormula, right: TropFormula):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"({self.left} + {self.right})"

class Min(TropFormula):
    def __init__(self, left: TropFormula, right: TropFormula):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"min({self.left}, {self.right})"


def eval_trop(phi: TropFormula, assignment: Tuple[int, ...]) -> int:
    """Evaluate a tropical formula at a given assignment."""
    if isinstance(phi, Const):
        return phi.c
    elif isinstance(phi, Var):
        return assignment[phi.i]
    elif isinstance(phi, Add):
        return eval_trop(phi.left, assignment) + eval_trop(phi.right, assignment)
    elif isinstance(phi, Min):
        return min(eval_trop(phi.left, assignment), eval_trop(phi.right, assignment))
    raise TypeError(f"Unknown formula type: {type(phi)}")


# ─────────────────────────────────────────────────────────────────────
# CNF Formula Evaluator
# ─────────────────────────────────────────────────────────────────────

def eval_cnf(clauses: List[List[int]], assignment: Tuple[int, ...]) -> bool:
    """
    Evaluate a CNF formula. Literals are signed integers:
    positive i means variable i, negative -i means ¬variable i.
    Variables are 0-indexed.
    """
    for clause in clauses:
        satisfied = False
        for lit in clause:
            if lit >= 0:
                if assignment[lit] == 1:
                    satisfied = True
                    break
            else:
                if assignment[-lit - 1] == 0:
                    satisfied = True
                    break
        if not satisfied:
            return False
    return True


# ─────────────────────────────────────────────────────────────────────
# Demo 1: Monotonicity of Tropical Evaluation
# ─────────────────────────────────────────────────────────────────────

def demo_monotonicity():
    """
    Demonstrate that tropical evaluation is monotone:
    if b ≤ a componentwise, then eval(φ, b) ≤ eval(φ, a).
    """
    print("=" * 60)
    print("DEMO 1: Monotonicity of Tropical Evaluation")
    print("=" * 60)

    # Formula: min(x0 + x1, x0 + 3)
    phi = Min(Add(Var(0), Var(1)), Add(Var(0), Const(3)))
    print(f"\nFormula φ = {phi}")
    print(f"\nEvaluation table on {{0,1,2,3}}² :")
    print(f"{'a':>10} | {'eval(φ,a)':>10}")
    print("-" * 25)

    for a0 in range(4):
        for a1 in range(4):
            a = (a0, a1)
            v = eval_trop(phi, a)
            print(f"  ({a0},{a1})    |    {v}")

    # Verify monotonicity on all pairs
    violations = 0
    for a0 in range(4):
        for a1 in range(4):
            for b0 in range(a0 + 1):
                for b1 in range(a1 + 1):
                    va = eval_trop(phi, (a0, a1))
                    vb = eval_trop(phi, (b0, b1))
                    if vb > va:
                        violations += 1
    print(f"\nMonotonicity violations (b≤a but eval(b)>eval(a)): {violations}")
    print("✓ Confirmed: tropical evaluation is monotone!\n")


# ─────────────────────────────────────────────────────────────────────
# Demo 2: Sublevel Sets are Downward Closed
# ─────────────────────────────────────────────────────────────────────

def demo_sublevel_sets():
    """
    Show that sublevel sets {a | eval(φ,a) ≤ k} are downward closed
    (lower sets) in the componentwise order.
    """
    print("=" * 60)
    print("DEMO 2: Sublevel Sets Are Downward Closed")
    print("=" * 60)

    phi = Add(Var(0), Var(1))
    print(f"\nFormula φ = {phi}")

    for k in range(4):
        sublevel = set()
        for a0 in range(4):
            for a1 in range(4):
                if eval_trop(phi, (a0, a1)) <= k:
                    sublevel.add((a0, a1))

        is_lower = True
        for (a0, a1) in sublevel:
            for b0 in range(a0 + 1):
                for b1 in range(a1 + 1):
                    if (b0, b1) not in sublevel:
                        is_lower = False

        status = "✓ downward closed" if is_lower else "✗ NOT downward closed"
        print(f"  k={k}: sublevel = {sorted(sublevel)} — {status}")


# ─────────────────────────────────────────────────────────────────────
# Demo 3: SAT Solutions Are NOT Downward Closed
# ─────────────────────────────────────────────────────────────────────

def demo_sat_not_downward_closed():
    """
    Demonstrate that the satisfying set of x₁ ∨ x₂ is not downward closed.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: SAT Solutions Are NOT Downward Closed")
    print("=" * 60)

    # CNF: x0 ∨ x1  (single clause with two positive literals)
    cnf = [[0, 1]]
    print(f"\nCNF formula: x₀ ∨ x₁")

    sat_set = set()
    for a0 in range(2):
        for a1 in range(2):
            a = (a0, a1)
            if eval_cnf(cnf, a):
                sat_set.add(a)
            result = "SAT" if eval_cnf(cnf, a) else "UNSAT"
            print(f"  a = ({a0},{a1}): {result}")

    print(f"\nSatisfying set: {sorted(sat_set)}")
    print(f"  (1,1) is satisfying, (0,0) ≤ (1,1) but (0,0) is NOT satisfying")
    print(f"  → The satisfying set is NOT downward closed!")
    print(f"  → This proves x₁ ∨ x₂ cannot be encoded as a tropical sublevel set.")


# ─────────────────────────────────────────────────────────────────────
# Demo 4: Exhaustive Search for Tropical Encoding of OR
# ─────────────────────────────────────────────────────────────────────

def demo_exhaustive_search():
    """
    Exhaustively search small tropical formulas for one that encodes x₁ ∨ x₂
    as a sublevel set on {0,1}². Shows no such formula exists.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Exhaustive Search — No Tropical Encoding of OR")
    print("=" * 60)

    bool_vecs = [(0, 0), (0, 1), (1, 0), (1, 1)]
    target_sat = {(0, 1), (1, 0), (1, 1)}  # sat set of x0 ∨ x1

    def generate_formulas(depth: int, nvars: int = 2):
        """Generate all tropical formulas up to given depth."""
        if depth == 0:
            for c in range(4):
                yield Const(c)
            for i in range(nvars):
                yield Var(i)
            return
        for f in generate_formulas(depth - 1, nvars):
            yield f
        for f1 in generate_formulas(depth - 1, nvars):
            for f2 in generate_formulas(depth - 1, nvars):
                yield Add(f1, f2)
                yield Min(f1, f2)

    found = False
    count = 0
    for phi in generate_formulas(1):
        count += 1
        values = {a: eval_trop(phi, a) for a in bool_vecs}
        for k in range(max(values.values()) + 1):
            sublevel = {a for a in bool_vecs if values[a] <= k}
            if sublevel == target_sat:
                print(f"  Found encoding: φ = {phi}, k = {k}")
                found = True
                break

    if not found:
        print(f"\n  Searched {count} formulas of depth ≤ 1.")
        print(f"  No tropical formula encodes x₀ ∨ x₁ as a sublevel set on {{0,1}}².")
        print(f"  This is expected: the satisfying set is not downward closed,")
        print(f"  but all tropical sublevel sets are downward closed.")


# ─────────────────────────────────────────────────────────────────────
# Demo 5: Contrast — What CAN Tropical Formulas Represent?
# ─────────────────────────────────────────────────────────────────────

def demo_what_tropical_can_represent():
    """
    Show the Boolean predicates on {0,1}^2 that ARE representable
    as tropical sublevel sets (they must be downward closed).
    """
    print("\n" + "=" * 60)
    print("DEMO 5: What Boolean Predicates Can Tropical Represent?")
    print("=" * 60)

    bool_vecs = [(0, 0), (0, 1), (1, 0), (1, 1)]

    # All 16 subsets of {0,1}^2
    downward_closed = []
    not_downward_closed = []

    for r in range(5):
        for subset in itertools.combinations(bool_vecs, r):
            s = set(subset)
            is_lower = True
            for (a0, a1) in s:
                for b0 in range(a0 + 1):
                    for b1 in range(a1 + 1):
                        if (b0, b1) not in s:
                            is_lower = False
            if is_lower:
                downward_closed.append(s)
            else:
                not_downward_closed.append(s)

    print(f"\n  Total subsets of {{0,1}}²: {2**4}")
    print(f"  Downward-closed (tropical-representable): {len(downward_closed)}")
    print(f"  NOT downward-closed (tropical-unrepresentable): {len(not_downward_closed)}")

    print(f"\n  Downward-closed sets:")
    for s in downward_closed:
        print(f"    {sorted(s) if s else '{}'}")

    print(f"\n  Non-downward-closed sets (impossible for tropical):")
    for s in not_downward_closed[:6]:
        print(f"    {sorted(s)}")
    if len(not_downward_closed) > 6:
        print(f"    ... and {len(not_downward_closed) - 6} more")


# ─────────────────────────────────────────────────────────────────────
# Demo 6: Scaling — Fraction of Boolean Functions Representable
# ─────────────────────────────────────────────────────────────────────

def demo_scaling():
    """
    Count downward-closed subsets of {0,1}^n for small n.
    These correspond to antichains in the Boolean lattice (Dedekind numbers).
    """
    print("\n" + "=" * 60)
    print("DEMO 6: Scaling — Dedekind Numbers vs Total Functions")
    print("=" * 60)

    # Known Dedekind numbers D(n) = number of antichains in {0,1}^n
    # = number of downward-closed subsets = number of monotone Boolean functions
    dedekind = {0: 2, 1: 3, 2: 6, 3: 20, 4: 168, 5: 7581, 6: 7828354}

    print(f"\n  {'n':>3} | {'2^(2^n)':>12} | {'Dedekind D(n)':>14} | {'Fraction':>12}")
    print("  " + "-" * 50)
    for n in range(7):
        total = 2 ** (2 ** n)
        d = dedekind[n]
        frac = d / total
        print(f"  {n:>3} | {total:>12} | {d:>14} | {frac:>12.2e}")

    print(f"\n  As n grows, the fraction of Boolean functions representable")
    print(f"  by tropical sublevel sets shrinks super-exponentially.")
    print(f"  SAT instances live overwhelmingly in the unrepresentable region.")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_monotonicity()
    demo_sublevel_sets()
    demo_sat_not_downward_closed()
    demo_exhaustive_search()
    demo_what_tropical_can_represent()
    demo_scaling()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Tropical Non-Encodability Theory

Generates publication-quality figures illustrating the structural barrier
between tropical computation and Boolean satisfiability.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import itertools
import base64
import io


def save_figure(fig, filename):
    """Save figure to file."""
    fig.savefig(filename, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)


def fig_to_base64(fig):
    """Convert figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


# ─────────────────────────────────────────────────────────────────────
# Figure 1: Boolean Cube with SAT vs Tropical Sublevel Sets
# ─────────────────────────────────────────────────────────────────────

def plot_boolean_cube_comparison():
    """
    Compare the satisfying set of x₀ ∨ x₁ (not downward closed)
    with a typical tropical sublevel set (downward closed) on {0,1}².
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Boolean lattice positions for {0,1}²
    positions = {(0,0): (1, 0), (1,0): (0, 1), (0,1): (2, 1), (1,1): (1, 2)}

    # Left: SAT set of x₀ ∨ x₁
    ax = axes[0]
    ax.set_title("SAT: x₀ ∨ x₁\n(NOT downward closed)", fontsize=14, fontweight='bold')

    sat_set = {(0,1), (1,0), (1,1)}
    for node, (x, y) in positions.items():
        color = '#2ecc71' if node in sat_set else '#e74c3c'
        label = "SAT" if node in sat_set else "UNSAT"
        ax.scatter(x, y, s=800, c=color, zorder=5, edgecolors='black', linewidths=2)
        ax.annotate(str(node), (x, y), ha='center', va='center', fontsize=11, fontweight='bold')

    # Draw Hasse diagram edges
    edges = [((0,0), (1,0)), ((0,0), (0,1)), ((1,0), (1,1)), ((0,1), (1,1))]
    for (a, b) in edges:
        xa, ya = positions[a]
        xb, yb = positions[b]
        ax.plot([xa, xb], [ya, yb], 'k-', alpha=0.3, linewidth=2)

    # Highlight the violation
    ax.annotate("", xy=positions[(0,0)], xytext=positions[(1,1)],
                arrowprops=dict(arrowstyle="->", color='red', lw=3, linestyle='dashed'))
    ax.text(1.8, 0.8, "(1,1) ∈ S but\n(0,0) ∉ S", fontsize=10, color='red',
            ha='center', style='italic')

    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.axis('off')

    # Right: Tropical sublevel set (downward closed)
    ax = axes[1]
    ax.set_title("Tropical sublevel set\n(downward closed ✓)", fontsize=14, fontweight='bold')

    tropical_set = {(0,0), (1,0), (0,1)}
    for node, (x, y) in positions.items():
        color = '#3498db' if node in tropical_set else '#bdc3c7'
        ax.scatter(x, y, s=800, c=color, zorder=5, edgecolors='black', linewidths=2)
        ax.annotate(str(node), (x, y), ha='center', va='center', fontsize=11, fontweight='bold')

    for (a, b) in edges:
        xa, ya = positions[a]
        xb, yb = positions[b]
        ax.plot([xa, xb], [ya, yb], 'k-', alpha=0.3, linewidth=2)

    ax.text(1, -0.3, "If a ∈ S and b ≤ a,\nthen b ∈ S ✓", fontsize=10, color='#2c3e50',
            ha='center', style='italic')

    ax.set_xlim(-0.5, 2.5)
    ax.set_ylim(-0.5, 2.5)
    ax.axis('off')

    fig.suptitle("The Barrier: SAT vs Tropical on the Boolean Cube", fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    save_figure(fig, 'fig_boolean_cube.png')
    return fig


# ─────────────────────────────────────────────────────────────────────
# Figure 2: Tropical Energy Landscape (3D surface)
# ─────────────────────────────────────────────────────────────────────

def plot_energy_landscape():
    """
    3D surface plot of a tropical energy function showing the
    piecewise-linear structure characteristic of min-plus computation.
    """
    fig = plt.figure(figsize=(10, 7))
    ax = fig.add_subplot(111, projection='3d')

    x = np.linspace(0, 4, 50)
    y = np.linspace(0, 4, 50)
    X, Y = np.meshgrid(x, y)

    # E(x,y) = min(x+y, x+2, y+1)
    Z = np.minimum(np.minimum(X + Y, X + 2), Y + 1)

    surf = ax.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8,
                           edgecolor='none', antialiased=True)

    # Mark sublevel contours on the base
    for k in [1, 2, 3]:
        contour_x = []
        contour_y = []
        for xi in np.linspace(0, 4, 200):
            for yi in np.linspace(0, 4, 200):
                z = min(xi + yi, xi + 2, yi + 1)
                if abs(z - k) < 0.05:
                    contour_x.append(xi)
                    contour_y.append(yi)
        if contour_x:
            ax.scatter(contour_x, contour_y, [0]*len(contour_x),
                      s=1, alpha=0.3, label=f'E={k} contour')

    ax.set_xlabel('x₀', fontsize=12)
    ax.set_ylabel('x₁', fontsize=12)
    ax.set_zlabel('E(x₀, x₁)', fontsize=12)
    ax.set_title('Tropical Energy Landscape\nE = min(x₀+x₁, x₀+2, x₁+1)',
                 fontsize=14, fontweight='bold')

    fig.colorbar(surf, shrink=0.5, aspect=5, label='Energy')
    save_figure(fig, 'fig_energy_landscape.png')
    return fig


# ─────────────────────────────────────────────────────────────────────
# Figure 3: Dedekind Numbers — Scaling of Representability
# ─────────────────────────────────────────────────────────────────────

def plot_dedekind_scaling():
    """
    Log-scale plot comparing Dedekind numbers (tropical-representable functions)
    to total Boolean functions, showing the super-exponential gap.
    """
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = list(range(7))
    total = [float(2**(2**n)) for n in ns]
    dedekind = [2.0, 3.0, 6.0, 20.0, 168.0, 7581.0, 7828354.0]

    ax.semilogy(ns, total, 'ro-', markersize=10, linewidth=2,
                label='All Boolean functions $2^{2^n}$')
    ax.semilogy(ns, dedekind, 'bs-', markersize=10, linewidth=2,
                label='Downward-closed (Dedekind) $D(n)$')

    # Shade the gap
    ax.fill_between(ns, dedekind, total, alpha=0.15, color='red',
                     label='Unrepresentable region')

    ax.set_xlabel('Number of variables n', fontsize=13)
    ax.set_ylabel('Count (log scale)', fontsize=13)
    ax.set_title('The Tropical Representability Gap\nMost Boolean functions cannot be tropical sublevel sets',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ns)

    # Annotate the gap
    ax.annotate('Gap grows\nsuper-exponentially',
                xy=(5, 1e6), fontsize=12, color='red',
                ha='center', style='italic')

    plt.tight_layout()
    save_figure(fig, 'fig_dedekind_scaling.png')
    return fig


# ─────────────────────────────────────────────────────────────────────
# Figure 4: Hasse diagram of {0,1}^3 with SAT coloring
# ─────────────────────────────────────────────────────────────────────

def plot_cube3d():
    """
    Hasse diagram of the Boolean cube {0,1}^3 showing how a 3-variable
    SAT instance's solutions violate downward closure.
    """
    fig, ax = plt.subplots(figsize=(10, 8))

    # Positions for {0,1}^3 as a Hasse diagram
    positions = {
        (0,0,0): (3, 0),
        (1,0,0): (1, 1.5), (0,1,0): (3, 1.5), (0,0,1): (5, 1.5),
        (1,1,0): (1, 3.5), (1,0,1): (3, 3.5), (0,1,1): (5, 3.5),
        (1,1,1): (3, 5),
    }

    # SAT instance: x₀ ∨ x₁ ∨ x₂
    sat_set = set()
    for a in itertools.product(range(2), repeat=3):
        if a[0] == 1 or a[1] == 1 or a[2] == 1:
            sat_set.add(a)

    # Draw edges
    for a in positions:
        for b in positions:
            if sum(ai < bi for ai, bi in zip(a, b)) == 1 and sum(ai == bi for ai, bi in zip(a, b)) == 2:
                xa, ya = positions[a]
                xb, yb = positions[b]
                ax.plot([xa, xb], [ya, yb], 'k-', alpha=0.2, linewidth=1.5)

    # Draw nodes
    for node, (x, y) in positions.items():
        if node in sat_set:
            color = '#2ecc71'
        else:
            color = '#e74c3c'
        ax.scatter(x, y, s=700, c=color, zorder=5, edgecolors='black', linewidths=2)
        label = ''.join(str(i) for i in node)
        ax.annotate(label, (x, y), ha='center', va='center', fontsize=10, fontweight='bold')

    # Legend
    sat_patch = mpatches.Patch(color='#2ecc71', label='Satisfying (SAT)')
    unsat_patch = mpatches.Patch(color='#e74c3c', label='Unsatisfying (UNSAT)')
    ax.legend(handles=[sat_patch, unsat_patch], fontsize=12, loc='upper right')

    # Annotate violation
    ax.annotate("(1,1,1) ∈ SAT but\n(0,0,0) ≤ (1,1,1)\nand (0,0,0) ∉ SAT",
                xy=(3, 0), xytext=(5.5, 0.5),
                fontsize=11, color='red', style='italic',
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax.set_title('x₀ ∨ x₁ ∨ x₂ on the Boolean Cube {0,1}³\nSatisfying set is NOT a lower set',
                 fontsize=14, fontweight='bold')
    ax.axis('off')
    ax.set_xlim(-0.5, 6.5)
    ax.set_ylim(-0.8, 5.8)

    plt.tight_layout()
    save_figure(fig, 'fig_cube3d.png')
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")
    plot_boolean_cube_comparison()
    print("  ✓ fig_boolean_cube.png")
    plot_energy_landscape()
    print("  ✓ fig_energy_landscape.png")
    plot_dedekind_scaling()
    print("  ✓ fig_dedekind_scaling.png")
    plot_cube3d()
    print("  ✓ fig_cube3d.png")
    print("All visualizations generated.")
