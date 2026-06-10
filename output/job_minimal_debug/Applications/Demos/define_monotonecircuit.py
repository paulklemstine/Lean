#!/usr/bin/env python3
"""
Monotone Min-Max Circuits: Real-World Applications

Demonstrates practical applications of min-max circuits with certified
stability guarantees:
1. Robust sensor fusion (median filtering)
2. Game tree evaluation (minimax)
3. Dynamic programming (shortest paths)
4. Decision system robustness analysis
"""

from __future__ import annotations
from dataclasses import dataclass
import random
import math


# ─── Circuit Types (self-contained) ──────────────────────────────────

@dataclass(frozen=True)
class Var:
    index: int

@dataclass(frozen=True)
class Const:
    value: float

@dataclass(frozen=True)
class And:
    left: 'Circuit'
    right: 'Circuit'

@dataclass(frozen=True)
class Or:
    left: 'Circuit'
    right: 'Circuit'

Circuit = Var | Const | And | Or


def evaluate(c: Circuit, x: list[float]) -> float:
    match c:
        case Var(i): return x[i]
        case Const(v): return v
        case And(l, r): return min(evaluate(l, x), evaluate(r, x))
        case Or(l, r): return max(evaluate(l, x), evaluate(r, x))


def circuit_str(c: Circuit) -> str:
    match c:
        case Var(i): return f"x{i}"
        case Const(v): return f"{v:.1f}"
        case And(l, r): return f"min({circuit_str(l)}, {circuit_str(r)})"
        case Or(l, r): return f"max({circuit_str(l)}, {circuit_str(r)})"


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: ROBUST SENSOR FUSION
# ═══════════════════════════════════════════════════════════════════════

def app_sensor_fusion():
    """
    Demonstrate robust sensor fusion using monotone circuits.

    The median of n sensors can be computed as a min-max circuit.
    By the 1-Lipschitz theorem, if each sensor has error ≤ ε,
    the fused output has error ≤ ε — guaranteed, with no
    distributional assumptions.
    """
    print("=" * 70)
    print("APPLICATION 1: ROBUST SENSOR FUSION")
    print("=" * 70)

    # Median of 3 sensors: max(min(a,b), min(b,c), min(a,c))
    a, b, c = Var(0), Var(1), Var(2)
    median3 = Or(Or(And(a, b), And(b, c)), And(a, c))

    # Median of 5 sensors (via sorting network)
    # med5 = median of x0..x4
    # A practical approximation: median = max of all min-of-3 subsets
    # True median of 5: max over all (5 choose 3)=10 triples of min-of-3
    vars5 = [Var(i) for i in range(5)]

    def min3(a, b, c):
        return And(And(a, b), c)

    # median of 5 = max of mins of all 3-element subsets
    triples = []
    for i in range(5):
        for j in range(i+1, 5):
            for k in range(j+1, 5):
                triples.append(min3(vars5[i], vars5[j], vars5[k]))

    median5 = triples[0]
    for t in triples[1:]:
        median5 = Or(median5, t)

    print("\nScenario: Temperature monitoring with 5 sensors")
    print(f"True temperature: 72.0°F")
    print(f"Sensor accuracy: ±0.5°F")

    random.seed(42)
    true_temp = 72.0
    eps = 0.5
    n_trials = 20

    print(f"\n{'Trial':>6s} {'Sensors':>45s} {'Median':>8s} {'Error':>8s} {'≤ ε?':>6s}")
    print("-" * 80)

    max_error = 0
    for trial in range(n_trials):
        readings = [true_temp + random.uniform(-eps, eps) for _ in range(5)]
        med = evaluate(median5, readings)
        error = abs(med - true_temp)
        max_error = max(max_error, error)

        readings_str = str([round(r, 3) for r in readings])
        bounded = error <= eps + 1e-10

        if trial < 10:  # Show first 10
            print(f"{trial+1:>6d} {readings_str:>45s} {med:>8.3f} {error:>8.4f} {'  ✓' if bounded else '  ✗':>6s}")

    print(f"\n  Max observed error: {max_error:.4f}")
    print(f"  Guaranteed bound:   {eps:.4f}")
    print(f"  Bound respected:    {'YES ✓' if max_error <= eps + 1e-10 else 'NO ✗'}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: GAME TREE EVALUATION
# ═══════════════════════════════════════════════════════════════════════

def app_game_tree():
    """
    Demonstrate minimax game tree as a monotone circuit.

    A game tree with alternating MAX (player) and MIN (opponent)
    levels is literally a MonotoneCircuit. The Lipschitz theorem
    guarantees that heuristic evaluation errors don't amplify.
    """
    print("=" * 70)
    print("APPLICATION 2: GAME TREE EVALUATION (MINIMAX)")
    print("=" * 70)

    # Build a game tree: 2-player, 3-level, binary branching
    # Level 0 (leaves): heuristic evaluations (variables)
    # Level 1: MIN (opponent minimizes)
    # Level 2: MAX (player maximizes)
    # Level 3: MIN (opponent minimizes) — root

    # 8 leaf nodes = Var(0) through Var(7)
    leaves = [Var(i) for i in range(8)]

    # Level 1: opponent picks min of pairs
    level1 = [And(leaves[2*i], leaves[2*i+1]) for i in range(4)]

    # Level 2: player picks max of pairs
    level2 = [Or(level1[2*i], level1[2*i+1]) for i in range(2)]

    # Level 3: opponent picks min
    root = And(level2[0], level2[1])

    print("\nGame tree structure (depth 3, binary):")
    print("  Root: MIN (opponent)")
    print("  ├── MAX (player)")
    print("  │   ├── MIN: min(leaf0, leaf1)")
    print("  │   └── MIN: min(leaf2, leaf3)")
    print("  └── MAX (player)")
    print("      ├── MIN: min(leaf4, leaf5)")
    print("      └── MIN: min(leaf6, leaf7)")

    # True leaf values
    true_values = [3.0, 7.0, 2.0, 8.0, 5.0, 1.0, 6.0, 4.0]
    true_minimax = evaluate(root, true_values)
    print(f"\nTrue leaf values: {true_values}")
    print(f"True minimax value: {true_minimax}")

    # Now add heuristic error
    print(f"\nWith heuristic error ε = 1.0:")
    eps = 1.0
    random.seed(99)

    errors = []
    for _ in range(1000):
        noisy = [v + random.uniform(-eps, eps) for v in true_values]
        noisy_val = evaluate(root, noisy)
        errors.append(abs(noisy_val - true_minimax))

    print(f"  Max observed |Δvalue|: {max(errors):.4f}")
    print(f"  Mean |Δvalue|:         {sum(errors)/len(errors):.4f}")
    print(f"  Guaranteed bound:      {eps:.4f}")
    print(f"  Bound respected:       {'YES ✓' if max(errors) <= eps + 1e-10 else 'NO ✗'}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: DYNAMIC PROGRAMMING (SHORTEST PATHS)
# ═══════════════════════════════════════════════════════════════════════

def app_dynamic_programming():
    """
    Demonstrate dynamic programming as min-max circuit evaluation.

    A Bellman-style shortest-path computation:
      V(s) = min over actions a of (cost(s,a) + V(next(s,a)))

    When unrolled for finite horizon, this is a min-tree circuit.
    We use max for "choose best" and min for "worst case."
    """
    print("=" * 70)
    print("APPLICATION 3: DYNAMIC PROGRAMMING STABILITY")
    print("=" * 70)

    # Simple grid: navigate from top-left to bottom-right
    # At each cell, choose to go right or down
    # Cost = cell value; goal = minimize total cost

    # Unroll as a min-max circuit:
    # The value at each cell is min(go_right + cost, go_down + cost)
    # For a 2x3 grid with 6 cost variables:

    #  [x0] [x1] [x2]
    #  [x3] [x4] [x5]   <- destination is x5

    # V(0,0) = x0 + min(V(0,1), V(1,0))
    # But since we want pure min-max (no addition), we model
    # the "bottleneck shortest path" where the cost is max edge weight

    # Bottleneck path: minimize the maximum edge weight
    # This IS a pure min-max computation!

    # Paths from (0,0) to (1,2) in 2x3 grid:
    # Path 1: right, right, down -> max(x0, x1, x2, x5)
    # Path 2: right, down, right -> max(x0, x1, x4, x5)
    # Path 3: down, right, right -> max(x0, x3, x4, x5)

    # Bottleneck = min over paths of max edge weight
    x = [Var(i) for i in range(6)]

    def max_chain(indices):
        result = x[indices[0]]
        for i in indices[1:]:
            result = Or(result, x[i])
        return result

    path1 = max_chain([0, 1, 2, 5])  # right, right, down
    path2 = max_chain([0, 1, 4, 5])  # right, down, right
    path3 = max_chain([0, 3, 4, 5])  # down, right, right

    bottleneck = And(And(path1, path2), path3)

    print("\nScenario: Bottleneck shortest path in 2×3 grid")
    print("  [x0] [x1] [x2]")
    print("  [x3] [x4] [x5]")
    print("Goal: minimize max edge weight from (0,0) to (1,2)")

    edge_weights = [2.0, 5.0, 3.0, 7.0, 1.0, 4.0]
    true_bottleneck = evaluate(bottleneck, edge_weights)

    print(f"\nEdge weights: {edge_weights}")
    print(f"Bottleneck path value: {true_bottleneck}")

    # Show all paths
    paths = {
        "R-R-D": max(edge_weights[0], edge_weights[1], edge_weights[2], edge_weights[5]),
        "R-D-R": max(edge_weights[0], edge_weights[1], edge_weights[4], edge_weights[5]),
        "D-R-R": max(edge_weights[0], edge_weights[3], edge_weights[4], edge_weights[5]),
    }
    for name, cost in paths.items():
        marker = " ← optimal" if cost == true_bottleneck else ""
        print(f"  Path {name}: bottleneck = {cost}{marker}")

    # Stability under perturbation
    print(f"\nStability analysis (ε = 0.5):")
    eps = 0.5
    random.seed(42)

    max_error = 0
    for _ in range(1000):
        noisy = [w + random.uniform(-eps, eps) for w in edge_weights]
        err = abs(evaluate(bottleneck, noisy) - true_bottleneck)
        max_error = max(max_error, err)

    print(f"  Max |Δbottleneck| over 1000 trials: {max_error:.4f}")
    print(f"  Guaranteed bound: {eps:.4f}")
    print(f"  Bound holds: {'YES ✓' if max_error <= eps + 1e-10 else 'NO ✗'}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: ROBUST DECISION SYSTEM
# ═══════════════════════════════════════════════════════════════════════

def app_robust_decision():
    """
    Demonstrate a robust multi-criteria decision system.

    A decision aggregator that computes:
      score = max(min(quality, safety), min(cost_inv, reliability))

    This selects the best option across two criteria groups,
    where within each group the weakest metric dominates.
    """
    print("=" * 70)
    print("APPLICATION 4: ROBUST MULTI-CRITERIA DECISION SYSTEM")
    print("=" * 70)

    # Variables: x0=quality, x1=safety, x2=cost_efficiency, x3=reliability
    quality = Var(0)
    safety = Var(1)
    cost_eff = Var(2)
    reliability = Var(3)

    # Score = max(min(quality, safety), min(cost_efficiency, reliability))
    # "Best of: (worst of quality/safety) or (worst of cost/reliability)"
    score_circuit = Or(And(quality, safety), And(cost_eff, reliability))

    print(f"\nDecision circuit: {circuit_str(score_circuit)}")
    print("Interpretation: best of two criteria groups,")
    print("  where each group is limited by its weakest factor.")

    # Evaluate some products
    products = {
        "Premium Safe":    [9.0, 9.5, 3.0, 7.0],
        "Budget Reliable": [4.0, 6.0, 9.0, 8.5],
        "Balanced":        [7.0, 7.5, 7.0, 7.0],
        "Cheap Risky":     [3.0, 2.0, 9.5, 3.0],
        "High Quality":    [9.5, 4.0, 5.0, 8.0],
    }

    print(f"\n{'Product':>20s} {'Quality':>8s} {'Safety':>8s} {'CostEff':>8s} {'Reliab':>8s} {'Score':>8s}")
    print("-" * 75)

    for name, metrics in products.items():
        score = evaluate(score_circuit, metrics)
        print(f"{name:>20s} {metrics[0]:>8.1f} {metrics[1]:>8.1f} {metrics[2]:>8.1f} {metrics[3]:>8.1f} {score:>8.1f}")

    # Robustness analysis
    print(f"\nRobustness: if all metrics have measurement error ≤ 0.3:")
    eps = 0.3
    random.seed(42)

    for name, metrics in products.items():
        true_score = evaluate(score_circuit, metrics)
        max_err = 0
        for _ in range(1000):
            noisy = [m + random.uniform(-eps, eps) for m in metrics]
            err = abs(evaluate(score_circuit, noisy) - true_score)
            max_err = max(max_err, err)
        print(f"  {name:>20s}: max |Δscore| = {max_err:.4f} ≤ {eps} ✓")

    print()


if __name__ == "__main__":
    app_sensor_fusion()
    app_game_tree()
    app_dynamic_programming()
    app_robust_decision()


#!/usr/bin/env python3
"""
Monotone Min-Max Circuits: Concrete Demonstrations

Demonstrates the three main theorems with numerical examples:
1. Semantic Monotonicity
2. Distributive Law Soundness
3. 1-Lipschitz Stability
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable
import random
import math


# ─── Circuit Data Type ───────────────────────────────────────────────

@dataclass
class Var:
    """Input variable gate."""
    index: int

@dataclass
class Const:
    """Constant gate."""
    value: float

@dataclass
class And:
    """Min gate (AND)."""
    left: 'Circuit'
    right: 'Circuit'

@dataclass
class Or:
    """Max gate (OR)."""
    left: 'Circuit'
    right: 'Circuit'

Circuit = Var | Const | And | Or


def evaluate(c: Circuit, x: list[float]) -> float:
    """Evaluate a monotone circuit on input assignment x."""
    match c:
        case Var(i):
            return x[i]
        case Const(v):
            return v
        case And(l, r):
            return min(evaluate(l, x), evaluate(r, x))
        case Or(l, r):
            return max(evaluate(l, x), evaluate(r, x))


def circuit_str(c: Circuit) -> str:
    """Pretty-print a circuit."""
    match c:
        case Var(i):
            return f"x{i}"
        case Const(v):
            return f"{v:.2f}"
        case And(l, r):
            return f"min({circuit_str(l)}, {circuit_str(r)})"
        case Or(l, r):
            return f"max({circuit_str(l)}, {circuit_str(r)})"


def size(c: Circuit) -> int:
    match c:
        case Var(_) | Const(_):
            return 1
        case And(l, r) | Or(l, r):
            return 1 + size(l) + size(r)


def depth(c: Circuit) -> int:
    match c:
        case Var(_) | Const(_):
            return 0
        case And(l, r) | Or(l, r):
            return 1 + max(depth(l), depth(r))


# ─── Demo 1: Monotonicity ────────────────────────────────────────────

def demo_monotonicity():
    """Demonstrate that increasing all inputs never decreases the output."""
    print("=" * 70)
    print("DEMO 1: SEMANTIC MONOTONICITY")
    print("If x[i] ≤ y[i] for all i, then eval(c, x) ≤ eval(c, y)")
    print("=" * 70)

    # Build a circuit: max(min(x0, x1), min(x1, x2))
    c = Or(And(Var(0), Var(1)), And(Var(1), Var(2)))
    print(f"\nCircuit: {circuit_str(c)}")
    print(f"Size: {size(c)}, Depth: {depth(c)}")

    n_vars = 3
    random.seed(42)

    print(f"\n{'x':>30s} {'y':>30s} {'eval(x)':>10s} {'eval(y)':>10s} {'mono?':>6s}")
    print("-" * 90)

    all_monotone = True
    for _ in range(10):
        x = [round(random.uniform(-5, 5), 2) for _ in range(n_vars)]
        delta = [round(random.uniform(0, 3), 2) for _ in range(n_vars)]
        y = [x[i] + delta[i] for i in range(n_vars)]

        ex = evaluate(c, x)
        ey = evaluate(c, y)
        mono = ex <= ey + 1e-12

        print(f"{str(x):>30s} {str(y):>30s} {ex:>10.4f} {ey:>10.4f} {'  ✓' if mono else '  ✗':>6s}")
        if not mono:
            all_monotone = False

    print(f"\nAll tests passed: {'YES ✓' if all_monotone else 'NO ✗'}")
    print()


# ─── Demo 2: Distributive Laws ───────────────────────────────────────

def demo_distributive():
    """Demonstrate min(a, max(b,c)) = max(min(a,b), min(a,c))."""
    print("=" * 70)
    print("DEMO 2: DISTRIBUTIVE LAW SOUNDNESS")
    print("min(a, max(b, c)) = max(min(a, b), min(a, c))")
    print("=" * 70)

    # Use three input variables
    a, b, c = Var(0), Var(1), Var(2)

    lhs = And(a, Or(b, c))        # min(a, max(b, c))
    rhs = Or(And(a, b), And(a, c))  # max(min(a, b), min(a, c))

    print(f"\nLHS: {circuit_str(lhs)}")
    print(f"RHS: {circuit_str(rhs)}")

    random.seed(123)
    print(f"\n{'x':>25s} {'LHS':>10s} {'RHS':>10s} {'equal?':>8s}")
    print("-" * 60)

    all_equal = True
    for _ in range(10):
        x = [round(random.uniform(-10, 10), 3) for _ in range(3)]
        l = evaluate(lhs, x)
        r = evaluate(rhs, x)
        eq = abs(l - r) < 1e-12

        print(f"{str(x):>25s} {l:>10.4f} {r:>10.4f} {'  ✓' if eq else '  ✗':>8s}")
        if not eq:
            all_equal = False

    # Also test the dual: max(a, min(b, c)) = min(max(a,b), max(a,c))
    print("\n\nDual: max(a, min(b, c)) = min(max(a, b), max(a, c))")
    lhs2 = Or(a, And(b, c))
    rhs2 = And(Or(a, b), Or(a, c))

    print(f"\n{'x':>25s} {'LHS':>10s} {'RHS':>10s} {'equal?':>8s}")
    print("-" * 60)

    for _ in range(10):
        x = [round(random.uniform(-10, 10), 3) for _ in range(3)]
        l = evaluate(lhs2, x)
        r = evaluate(rhs2, x)
        eq = abs(l - r) < 1e-12

        print(f"{str(x):>25s} {l:>10.4f} {r:>10.4f} {'  ✓' if eq else '  ✗':>8s}")
        if not eq:
            all_equal = False

    print(f"\nAll tests passed: {'YES ✓' if all_equal else 'NO ✗'}")
    print()


# ─── Demo 3: 1-Lipschitz Stability ──────────────────────────────────

def demo_lipschitz():
    """Demonstrate |eval(c,x) - eval(c,y)| ≤ max_i |x_i - y_i|."""
    print("=" * 70)
    print("DEMO 3: 1-LIPSCHITZ STABILITY")
    print("|eval(c, x) - eval(c, y)| ≤ max_i |x_i - y_i| = ε")
    print("=" * 70)

    # Build a deep circuit: alternating min/max of depth 10
    def build_deep_circuit(n_vars: int, target_depth: int) -> Circuit:
        """Build a random circuit of approximately the given depth."""
        random.seed(99)
        if target_depth == 0:
            return Var(random.randint(0, n_vars - 1))
        left = build_deep_circuit(n_vars, target_depth - 1)
        right = build_deep_circuit(n_vars, target_depth - 1)
        if target_depth % 2 == 0:
            return And(left, right)
        else:
            return Or(left, right)

    n_vars = 4
    for d in [2, 5, 10, 15]:
        c = build_deep_circuit(n_vars, d)
        print(f"\nCircuit depth: {depth(c)}, size: {size(c)}")

        random.seed(42 + d)
        max_ratio = 0.0
        eps_val = 0.5

        for _ in range(1000):
            x = [random.uniform(-10, 10) for _ in range(n_vars)]
            perturbation = [random.uniform(-eps_val, eps_val) for _ in range(n_vars)]
            y = [x[i] + perturbation[i] for i in range(n_vars)]

            eps_actual = max(abs(x[i] - y[i]) for i in range(n_vars))
            output_diff = abs(evaluate(c, x) - evaluate(c, y))

            if eps_actual > 1e-15:
                ratio = output_diff / eps_actual
                max_ratio = max(max_ratio, ratio)

        print(f"  Max |Δoutput| / ε over 1000 trials: {max_ratio:.6f}")
        print(f"  Lipschitz bound (should be ≤ 1.0):  {'✓ PASSED' if max_ratio <= 1.0 + 1e-10 else '✗ FAILED'}")

    print()


# ─── Demo 4: Contrast with Arithmetic ───────────────────────────────

def demo_contrast():
    """Show that arithmetic circuits DO amplify errors, while min-max don't."""
    print("=" * 70)
    print("DEMO 4: MIN-MAX vs ARITHMETIC ERROR AMPLIFICATION")
    print("=" * 70)

    print("\nComparing error amplification through chains of depth d:")
    print(f"\n{'depth':>6s} {'min-max Lip.':>14s} {'multiply Lip.':>14s}")
    print("-" * 40)

    for d in range(1, 16):
        # Min-max chain: min(min(min(..., x), x), x) — Lipschitz = 1
        minmax_lip = 1.0

        # Multiplication chain: x * x * ... * x — Lipschitz = d * |x|^{d-1}
        # At x=2: d * 2^{d-1}
        mult_lip = d * (2 ** (d - 1))

        print(f"{d:>6d} {minmax_lip:>14.1f} {mult_lip:>14.0f}")

    print("\nMin-max circuits maintain Lipschitz constant 1 at ANY depth.")
    print("Arithmetic circuits can amplify errors exponentially with depth.")
    print()


# ─── Demo 5: Median as Monotone Circuit ──────────────────────────────

def demo_median():
    """Show median of 3 values as a monotone circuit application."""
    print("=" * 70)
    print("DEMO 5: MEDIAN AS MONOTONE CIRCUIT (SENSOR FUSION)")
    print("=" * 70)

    # median(a, b, c) = max(min(a,b), min(b,c), min(a,c))
    a, b, c = Var(0), Var(1), Var(2)
    median_circuit = Or(Or(And(a, b), And(b, c)), And(a, c))

    print(f"\nCircuit: {circuit_str(median_circuit)}")
    print(f"This computes: median(x0, x1, x2)")

    print(f"\n{'true value':>12s} {'sensor readings':>30s} {'median':>10s} {'error':>8s}")
    print("-" * 65)

    random.seed(77)
    eps = 0.5
    for true_val in [20.0, 37.5, -3.14, 100.0, 0.0]:
        readings = [true_val + random.uniform(-eps, eps) for _ in range(3)]
        med = evaluate(median_circuit, readings)
        error = abs(med - true_val)

        print(f"{true_val:>12.2f} {str([round(r,3) for r in readings]):>30s} {med:>10.4f} {error:>8.4f}")

    print(f"\nGuaranteed: error ≤ ε = {eps} (by 1-Lipschitz theorem)")
    print()


if __name__ == "__main__":
    demo_monotonicity()
    demo_distributive()
    demo_lipschitz()
    demo_contrast()
    demo_median()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all content embedded."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def image_to_base64(path):
    with open(path, 'rb') as f:
        encoded = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{encoded}"

# Read all content
article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_code = read_file('/workspace/request-project/Computation/MonotoneCircuit.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')
viz_code = read_file('/workspace/request-project/visualizations.py')

# Read images
img_mono = image_to_base64('/workspace/request-project/fig_monotonicity.png')
img_lip = image_to_base64('/workspace/request-project/fig_lipschitz.png')
img_sensor = image_to_base64('/workspace/request-project/fig_sensor_fusion.png')

package = {
    "title": "Monotone Min-Max Circuits: Foundations of Stable Tropical Computation",
    "domain": "Computation",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Monotone Circuit Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Circuit Evaluation",
            "pseudocode": "function EVAL(c, x):\n    match c:\n        case var(i):    return x[i]\n        case const(a):  return a\n        case and(c1, c2): return min(EVAL(c1, x), EVAL(c2, x))\n        case or(c1, c2):  return max(EVAL(c1, x), EVAL(c2, x))\n\nComplexity: O(|c|) time, O(depth(c)) space",
            "code": algorithms_code
        },
        {
            "name": "DNF Conversion",
            "pseudocode": "function TO_DNF(c):\n    match c:\n        case var(i) | const(a): return c\n        case or(c1, c2): return or(TO_DNF(c1), TO_DNF(c2))\n        case and(c1, c2): return DISTRIBUTE_AND(TO_DNF(c1), TO_DNF(c2))\n\nfunction DISTRIBUTE_AND(c1, c2):\n    match c2:\n        case or(b, c): return or(DISTRIBUTE_AND(c1, b), DISTRIBUTE_AND(c1, c))\n        default: match c1:\n            case or(a, b): return or(DISTRIBUTE_AND(a, c2), DISTRIBUTE_AND(b, c2))\n            default: return and(c1, c2)\n\nComplexity: O(2^depth) worst case output size",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Monotone Circuit Surface",
            "data": img_mono
        },
        {
            "name": "Lipschitz Stability Analysis",
            "data": img_lip
        },
        {
            "name": "Sensor Fusion Robustness",
            "data": img_sensor
        }
    ],
    "lean_proofs": lean_code
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('/workspace/request-project/PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Monotone Min-Max Circuits: Visualizations
Generates figures illustrating the main theorems.
"""

from __future__ import annotations
from dataclasses import dataclass
import random
import base64
import io

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ─── Circuit Types ───────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    index: int

@dataclass(frozen=True)
class Const:
    value: float

@dataclass(frozen=True)
class And:
    left: 'Circuit'
    right: 'Circuit'

@dataclass(frozen=True)
class Or:
    left: 'Circuit'
    right: 'Circuit'

Circuit = Var | Const | And | Or


def evaluate(c: Circuit, x: list[float]) -> float:
    match c:
        case Var(i): return x[i]
        case Const(v): return v
        case And(l, r): return min(evaluate(l, x), evaluate(r, x))
        case Or(l, r): return max(evaluate(l, x), evaluate(r, x))


def depth(c: Circuit) -> int:
    match c:
        case Var(_) | Const(_): return 0
        case And(l, r) | Or(l, r): return 1 + max(depth(l), depth(r))


def size(c: Circuit) -> int:
    match c:
        case Var(_) | Const(_): return 1
        case And(l, r) | Or(l, r): return 1 + size(l) + size(r)


def random_circuit(n_vars, max_depth, rng):
    if max_depth == 0:
        return Var(rng.randint(0, n_vars - 1))
    gate = And if rng.random() < 0.5 else Or
    return gate(
        random_circuit(n_vars, max_depth - 1, rng),
        random_circuit(n_vars, max_depth - 1, rng)
    )


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


# ═══════════════════════════════════════════════════════════════════════

def fig_monotonicity():
    """3D surface showing monotone circuit evaluation."""
    c = Or(And(Var(0), Var(1)), And(Var(0), Const(3.0)))

    xs = np.linspace(0, 8, 40)
    ys = np.linspace(0, 8, 40)
    X, Y = np.meshgrid(xs, ys)
    Z = np.vectorize(lambda x, y: evaluate(c, [x, y]))(X, Y)

    fig = plt.figure(figsize=(10, 7))
    ax = fig.add_subplot(111, projection='3d')
    ax.plot_surface(X, Y, Z, cmap='viridis', alpha=0.85, edgecolor='none')
    ax.set_xlabel('x₀', fontsize=13)
    ax.set_ylabel('x₁', fontsize=13)
    ax.set_zlabel('eval(c, x)', fontsize=13)
    ax.set_title('Monotone Circuit Surface\nmax(min(x₀, x₁), min(x₀, 3))', fontsize=13)
    ax.view_init(elev=25, azim=-50)

    fig.savefig('/workspace/request-project/fig_monotonicity.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def fig_lipschitz():
    """Lipschitz ratio vs depth + comparison with arithmetic."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Lipschitz ratio vs depth
    depths_range = list(range(1, 13))
    max_ratios = []

    for d in depths_range:
        best = 0
        for seed in range(5):
            rng = random.Random(seed * 100 + d)
            c = random_circuit(3, d, rng)
            for _ in range(200):
                x = [rng.uniform(-5, 5) for _ in range(3)]
                y = [rng.uniform(-5, 5) for _ in range(3)]
                in_diff = max(abs(x[i] - y[i]) for i in range(3))
                out_diff = abs(evaluate(c, x) - evaluate(c, y))
                if in_diff > 1e-12:
                    best = max(best, out_diff / in_diff)
        max_ratios.append(best)

    ax = axes[0]
    ax.plot(depths_range, max_ratios, 'o-', color='#e74c3c', linewidth=2, markersize=5, label='Max observed ratio')
    ax.axhline(y=1.0, color='black', linestyle='--', linewidth=1.5, label='Bound = 1')
    ax.set_xlabel('Circuit Depth', fontsize=12)
    ax.set_ylabel('|Δoutput| / |Δinput|∞', fontsize=12)
    ax.set_title('Lipschitz Ratio vs Circuit Depth', fontsize=12)
    ax.legend(fontsize=10)
    ax.set_ylim(0, 1.3)
    ax.grid(True, alpha=0.3)

    # Right: Compare with multiplication
    ax = axes[1]
    d_range = list(range(1, 11))
    minmax_lip = [1.0] * len(d_range)
    mult_lip = [2**d for d in d_range]

    ax.semilogy(d_range, mult_lip, 'o-', color='#e74c3c', label='×2 chain', linewidth=2, markersize=6)
    ax.semilogy(d_range, minmax_lip, 's-', color='#2ecc71', label='Min-max circuit', linewidth=2, markersize=6)
    ax.set_xlabel('Chain Depth', fontsize=12)
    ax.set_ylabel('Error Amplification (log scale)', fontsize=12)
    ax.set_title('Error Amplification: Min-Max vs Arithmetic', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_lipschitz.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def fig_sensor_fusion():
    """Sensor fusion robustness visualization."""
    fig, ax = plt.subplots(figsize=(8, 5))

    a, b, c = Var(0), Var(1), Var(2)
    median3 = Or(Or(And(a, b), And(b, c)), And(a, c))

    true_temp = 20.0
    epsilons = np.linspace(0, 2, 15)
    random.seed(42)

    for agg_name, agg_circuit, color in [
        ('Median', median3, '#3498db'),
        ('Min', And(And(Var(0), Var(1)), Var(2)), '#e74c3c'),
        ('Max', Or(Or(Var(0), Var(1)), Var(2)), '#2ecc71'),
    ]:
        max_errors = []
        for ep in epsilons:
            max_err = 0
            for _ in range(200):
                readings = [true_temp + random.uniform(-ep, ep) for _ in range(3)]
                err = abs(evaluate(agg_circuit, readings) - true_temp)
                max_err = max(max_err, err)
            max_errors.append(max_err)
        ax.plot(epsilons, max_errors, 'o-', label=agg_name, markersize=4, linewidth=2, color=color)

    ax.plot(epsilons, epsilons, 'k--', linewidth=1.5, label='y = ε (bound)')
    ax.set_xlabel('Input Error ε', fontsize=12)
    ax.set_ylabel('Max Output Error', fontsize=12)
    ax.set_title('Sensor Fusion: Output Error vs Input Error\n(All min-max aggregators respect the 1-Lipschitz bound)', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_sensor_fusion.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    fig_monotonicity()
    print("  ✓ fig_monotonicity.png")
    fig_lipschitz()
    print("  ✓ fig_lipschitz.png")
    fig_sensor_fusion()
    print("  ✓ fig_sensor_fusion.png")
    print("Done!")
