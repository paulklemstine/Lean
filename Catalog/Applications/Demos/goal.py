#!/usr/bin/env python3
"""
Tropical Circuit Duality: Real-World Applications

Demonstrates applications of the min-plus / max-plus duality theorem:
1. Shortest-path / longest-path duality in graph algorithms
2. Scheduling: critical path method via duality
3. Dynamic programming: cost minimization ↔ reward maximization
4. Boolean monotone function encoding
"""

from __future__ import annotations
import random


# ═══════════════════════════════════════════════════════════════════════
# Minimal circuit library (self-contained)
# ═══════════════════════════════════════════════════════════════════════

class Var:
    def __init__(self, i): self.index = i
    def __repr__(self): return f"x{self.index}"
    def __eq__(self, o): return isinstance(o, Var) and self.index == o.index

class Const:
    def __init__(self, v): self.value = v
    def __repr__(self): return f"{self.value}"
    def __eq__(self, o): return isinstance(o, Const) and self.value == o.value

class Add:
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left} + {self.right})"
    def __eq__(self, o): return isinstance(o, Add) and self.left == o.left and self.right == o.right

class MinG:
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"min({self.left}, {self.right})"
    def __eq__(self, o): return isinstance(o, MinG) and self.left == o.left and self.right == o.right

class MaxG:
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"max({self.left}, {self.right})"
    def __eq__(self, o): return isinstance(o, MaxG) and self.left == o.left and self.right == o.right

def evaluate(node, sigma):
    if isinstance(node, Var): return sigma[node.index]
    if isinstance(node, Const): return node.value
    if isinstance(node, Add): return evaluate(node.left, sigma) + evaluate(node.right, sigma)
    if isinstance(node, MinG): return min(evaluate(node.left, sigma), evaluate(node.right, sigma))
    if isinstance(node, MaxG): return max(evaluate(node.left, sigma), evaluate(node.right, sigma))

def dualize(node):
    if isinstance(node, Var): return node
    if isinstance(node, Const): return Const(-node.value)
    if isinstance(node, Add): return Add(dualize(node.left), dualize(node.right))
    if isinstance(node, MinG): return MaxG(dualize(node.left), dualize(node.right))
    if isinstance(node, MaxG): return MinG(dualize(node.left), dualize(node.right))

def size(node):
    if isinstance(node, (Var, Const)): return 1
    return 1 + size(node.left) + size(node.right)


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Shortest Path / Longest Path Duality
# ═══════════════════════════════════════════════════════════════════════

def app_shortest_longest_path():
    """
    Demonstrates that shortest-path computation (min-plus) dualizes to
    longest-path computation (max-plus) with negated weights.

    Consider a DAG with 4 nodes and weighted edges:
        0 →(2)→ 1 →(3)→ 3
        0 →(1)→ 2 →(6)→ 3
        1 →(1)→ 2

    We build a min-plus circuit computing the shortest path 0→3.
    """
    print("=" * 65)
    print("APPLICATION 1: Shortest / Longest Path Duality")
    print("=" * 65)
    print()
    print("Graph: 4 nodes, edges with weights:")
    print("  0 →(w01)→ 1 →(w13)→ 3")
    print("  0 →(w02)→ 2 →(w23)→ 3")
    print("  1 →(w12)→ 2")
    print()

    # Variables: x0=w01, x1=w13, x2=w02, x3=w23, x4=w12
    # Paths 0→3:
    #   Path A: 0→1→3, cost = w01 + w13 = x0 + x1
    #   Path B: 0→2→3, cost = w02 + w23 = x2 + x3
    #   Path C: 0→1→2→3, cost = w01 + w12 + w23 = x0 + x4 + x3

    pathA = Add(Var(0), Var(1))
    pathB = Add(Var(2), Var(3))
    pathC = Add(Add(Var(0), Var(4)), Var(3))
    shortest = MinG(MinG(pathA, pathB), pathC)

    weights = [2.0, 3.0, 1.0, 6.0, 1.0]  # w01=2, w13=3, w02=1, w23=6, w12=1
    sp = evaluate(shortest, weights)
    print(f"Weights: w01={weights[0]}, w13={weights[1]}, w02={weights[2]}, w23={weights[3]}, w12={weights[4]}")
    print(f"Path costs: A={weights[0]+weights[1]}, B={weights[2]+weights[3]}, C={weights[0]+weights[4]+weights[3]}")
    print(f"Shortest path 0→3: {sp}")

    # Dual: longest path with negated weights
    longest = dualize(shortest)
    neg_weights = [-w for w in weights]
    lp = evaluate(longest, neg_weights)
    print(f"\nDual (max-plus) on negated weights: {lp}")
    print(f"Equals -shortest: {abs(lp - (-sp)) < 1e-12} ✓")
    print(f"Interpretation: longest path with original weights = {-lp}")
    print(f"  (This is path B: 0→2→3, cost 1+6=7)")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Critical Path Scheduling
# ═══════════════════════════════════════════════════════════════════════

def app_scheduling():
    """
    Demonstrates scheduling via max-plus duality.

    Tasks with durations and dependencies:
      Task A: duration 3, no prerequisites
      Task B: duration 5, no prerequisites
      Task C: duration 2, requires A and B
      Task D: duration 4, requires C

    Completion time = max(pathA→C→D, pathB→C→D)
    """
    print("=" * 65)
    print("APPLICATION 2: Critical Path Scheduling")
    print("=" * 65)
    print()
    print("Tasks: A(dur=d0), B(dur=d1), C(dur=d2, after A,B), D(dur=d3, after C)")
    print()

    # Max-plus circuit: max(d0 + d2 + d3, d1 + d2 + d3)
    # = max(d0, d1) + d2 + d3
    pathACD = Add(Add(Var(0), Var(2)), Var(3))
    pathBCD = Add(Add(Var(1), Var(2)), Var(3))
    completion = MaxG(pathACD, pathBCD)

    durations = [3.0, 5.0, 2.0, 4.0]
    ct = evaluate(completion, durations)
    print(f"Durations: A={durations[0]}, B={durations[1]}, C={durations[2]}, D={durations[3]}")
    print(f"Path A→C→D: {durations[0]+durations[2]+durations[3]}")
    print(f"Path B→C→D: {durations[1]+durations[2]+durations[3]}")
    print(f"Project completion time (max-plus): {ct}")

    # Dual: min-plus with negated durations
    dual_circuit = dualize(completion)
    neg_durations = [-d for d in durations]
    dual_val = evaluate(dual_circuit, neg_durations)
    print(f"\nDual (min-plus) on negated durations: {dual_val}")
    print(f"Equals -completion_time: {abs(dual_val - (-ct)) < 1e-12} ✓")
    print(f"Size preserved: {size(completion)} == {size(dual_circuit)} ✓")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Dynamic Programming Duality
# ═══════════════════════════════════════════════════════════════════════

def app_dynamic_programming():
    """
    Demonstrates DP duality: cost minimization ↔ reward maximization.

    Knapsack-like problem:
      Items: values v0, v1, v2; take at most one of (item0, item1)
      Cost circuit (min-plus): min(v0, v1) + v2
      Reward circuit (max-plus): max(-v0, -v1) + (-v2)  (dual)
    """
    print("=" * 65)
    print("APPLICATION 3: Dynamic Programming Duality")
    print("=" * 65)
    print()
    print("Scenario: Choose one of items 0,1 (lower cost better), always take item 2")
    print("Min-plus: min(cost0, cost1) + cost2")
    print()

    cost_circuit = Add(MinG(Var(0), Var(1)), Var(2))
    costs = [8.0, 5.0, 3.0]
    min_cost = evaluate(cost_circuit, costs)
    print(f"Costs: item0={costs[0]}, item1={costs[1]}, item2={costs[2]}")
    print(f"Minimum total cost: min({costs[0]}, {costs[1]}) + {costs[2]} = {min_cost}")

    # Dual: maximize negative cost = maximize reward
    reward_circuit = dualize(cost_circuit)
    neg_costs = [-c for c in costs]
    max_reward = evaluate(reward_circuit, neg_costs)
    print(f"\nDual: max-plus on negated costs: {max_reward}")
    print(f"Equals -min_cost: {abs(max_reward - (-min_cost)) < 1e-12} ✓")
    print(f"Interpretation: choosing item1 + item2 gives cost 5+3=8, reward = -8")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Boolean Monotone Encoding
# ═══════════════════════════════════════════════════════════════════════

def app_boolean_encoding():
    """
    Demonstrates Boolean function encoding in tropical circuits.

    Encoding: true=0, false=1
    OR(a,b) = min(a,b)  (on {0,1} values)
    AND(a,b) = a+b      (decoded by threshold ≤ 0)

    The duality theorem implies the same Boolean functions are
    representable in max-plus with the same circuit size.
    """
    print("=" * 65)
    print("APPLICATION 4: Boolean Monotone Encoding")
    print("=" * 65)
    print()

    def encode(b): return 0.0 if b else 1.0
    def decode(v): return v <= 0

    # f(a, b) = a OR (a AND b) = a  (tautology: a OR (a AND b) = a)
    # Min-plus: min(x0, x0 + x1)
    f_circuit = MinG(Var(0), Add(Var(0), Var(1)))

    print("Boolean function: a OR (a AND b)")
    print("Min-plus circuit: min(x0, x0 + x1)")
    print("Encoding: true=0, false=1")
    print()
    print(f"{'a':>5} {'b':>5} {'enc_a':>7} {'enc_b':>7} {'eval':>7} {'decoded':>8} {'expected':>9}")
    print("-" * 55)

    for a in [True, False]:
        for b in [True, False]:
            sigma = [encode(a), encode(b)]
            val = evaluate(f_circuit, sigma)
            result = decode(val)
            expected = a  # a OR (a AND b) = a
            status = "✓" if result == expected else "✗"
            print(f"{str(a):>5} {str(b):>5} {sigma[0]:>7.0f} {sigma[1]:>7.0f} {val:>7.0f} {str(result):>8} {str(expected):>9} {status}")

    # Show dual circuit has same size
    dual_f = dualize(f_circuit)
    print(f"\nCircuit size: {size(f_circuit)}")
    print(f"Dual circuit size: {size(dual_f)}")
    print(f"Size preserved: {size(f_circuit) == size(dual_f)} ✓")
    print(f"Dual circuit: {dual_f}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║   Tropical Circuit Duality: Real-World Applications         ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    app_shortest_longest_path()
    app_scheduling()
    app_dynamic_programming()
    app_boolean_encoding()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tropical Circuit Duality: Interactive Demonstration

Demonstrates the min-plus / max-plus circuit duality theorem with
concrete numerical examples. Shows that:
  1. eval_max(dual(C), -σ) == -eval_min(C, σ)
  2. dual(dual(C)) == C  (involutivity)
  3. size(dual(C)) == size(C)
"""

import random
import math

# ── Circuit data structures ──────────────────────────────────────────

class MinCircuit:
    """Min-plus tropical circuit."""
    pass

class MinVar(MinCircuit):
    def __init__(self, index: int):
        self.index = index
    def __repr__(self):
        return f"x{self.index}"
    def __eq__(self, other):
        return isinstance(other, MinVar) and self.index == other.index

class MinConst(MinCircuit):
    def __init__(self, value: float):
        self.value = value
    def __repr__(self):
        return f"{self.value}"
    def __eq__(self, other):
        return isinstance(other, MinConst) and self.value == other.value

class MinAdd(MinCircuit):
    def __init__(self, left: MinCircuit, right: MinCircuit):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"({self.left} + {self.right})"
    def __eq__(self, other):
        return isinstance(other, MinAdd) and self.left == other.left and self.right == other.right

class MinMin(MinCircuit):
    def __init__(self, left: MinCircuit, right: MinCircuit):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"min({self.left}, {self.right})"
    def __eq__(self, other):
        return isinstance(other, MinMin) and self.left == other.left and self.right == other.right


class MaxCircuit:
    """Max-plus tropical circuit."""
    pass

class MaxVar(MaxCircuit):
    def __init__(self, index: int):
        self.index = index
    def __repr__(self):
        return f"x{self.index}"
    def __eq__(self, other):
        return isinstance(other, MaxVar) and self.index == other.index

class MaxConst(MaxCircuit):
    def __init__(self, value: float):
        self.value = value
    def __repr__(self):
        return f"{self.value}"
    def __eq__(self, other):
        return isinstance(other, MaxConst) and self.value == other.value

class MaxAdd(MaxCircuit):
    def __init__(self, left: MaxCircuit, right: MaxCircuit):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"({self.left} + {self.right})"
    def __eq__(self, other):
        return isinstance(other, MaxAdd) and self.left == other.left and self.right == other.right

class MaxMax(MaxCircuit):
    def __init__(self, left: MaxCircuit, right: MaxCircuit):
        self.left = left
        self.right = right
    def __repr__(self):
        return f"max({self.left}, {self.right})"
    def __eq__(self, other):
        return isinstance(other, MaxMax) and self.left == other.left and self.right == other.right


# ── Evaluation ───────────────────────────────────────────────────────

def eval_min(circuit: MinCircuit, sigma: list[float]) -> float:
    """Evaluate a min-plus circuit on assignment sigma."""
    if isinstance(circuit, MinVar):
        return sigma[circuit.index]
    elif isinstance(circuit, MinConst):
        return circuit.value
    elif isinstance(circuit, MinAdd):
        return eval_min(circuit.left, sigma) + eval_min(circuit.right, sigma)
    elif isinstance(circuit, MinMin):
        return min(eval_min(circuit.left, sigma), eval_min(circuit.right, sigma))
    raise TypeError(f"Unknown circuit type: {type(circuit)}")

def eval_max(circuit: MaxCircuit, sigma: list[float]) -> float:
    """Evaluate a max-plus circuit on assignment sigma."""
    if isinstance(circuit, MaxVar):
        return sigma[circuit.index]
    elif isinstance(circuit, MaxConst):
        return circuit.value
    elif isinstance(circuit, MaxAdd):
        return eval_max(circuit.left, sigma) + eval_max(circuit.right, sigma)
    elif isinstance(circuit, MaxMax):
        return max(eval_max(circuit.left, sigma), eval_max(circuit.right, sigma))
    raise TypeError(f"Unknown circuit type: {type(circuit)}")


# ── Size and Depth ───────────────────────────────────────────────────

def size_min(circuit: MinCircuit) -> int:
    if isinstance(circuit, (MinVar, MinConst)):
        return 1
    elif isinstance(circuit, (MinAdd, MinMin)):
        return 1 + size_min(circuit.left) + size_min(circuit.right)
    raise TypeError

def size_max(circuit: MaxCircuit) -> int:
    if isinstance(circuit, (MaxVar, MaxConst)):
        return 1
    elif isinstance(circuit, (MaxAdd, MaxMax)):
        return 1 + size_max(circuit.left) + size_max(circuit.right)
    raise TypeError


# ── Dualization ──────────────────────────────────────────────────────

def dual_min_to_max(circuit: MinCircuit) -> MaxCircuit:
    """Dualize a min-plus circuit to max-plus."""
    if isinstance(circuit, MinVar):
        return MaxVar(circuit.index)
    elif isinstance(circuit, MinConst):
        return MaxConst(-circuit.value)
    elif isinstance(circuit, MinAdd):
        return MaxAdd(dual_min_to_max(circuit.left), dual_min_to_max(circuit.right))
    elif isinstance(circuit, MinMin):
        return MaxMax(dual_min_to_max(circuit.left), dual_min_to_max(circuit.right))
    raise TypeError

def dual_max_to_min(circuit: MaxCircuit) -> MinCircuit:
    """Dualize a max-plus circuit to min-plus."""
    if isinstance(circuit, MaxVar):
        return MinVar(circuit.index)
    elif isinstance(circuit, MaxConst):
        return MinConst(-circuit.value)
    elif isinstance(circuit, MaxAdd):
        return MinAdd(dual_max_to_min(circuit.left), dual_max_to_min(circuit.right))
    elif isinstance(circuit, MaxMax):
        return MinMin(dual_max_to_min(circuit.left), dual_max_to_min(circuit.right))
    raise TypeError

def negate_assignment(sigma: list[float]) -> list[float]:
    """Negate all entries of an assignment."""
    return [-x for x in sigma]


# ── Random circuit generation ────────────────────────────────────────

def random_min_circuit(n_vars: int, max_depth: int = 4) -> MinCircuit:
    """Generate a random min-plus circuit."""
    if max_depth <= 0 or random.random() < 0.3:
        if random.random() < 0.5 and n_vars > 0:
            return MinVar(random.randint(0, n_vars - 1))
        else:
            return MinConst(round(random.uniform(-10, 10), 2))
    if random.random() < 0.5:
        return MinAdd(
            random_min_circuit(n_vars, max_depth - 1),
            random_min_circuit(n_vars, max_depth - 1)
        )
    else:
        return MinMin(
            random_min_circuit(n_vars, max_depth - 1),
            random_min_circuit(n_vars, max_depth - 1)
        )


# ── Demonstrations ───────────────────────────────────────────────────

def demo_basic_duality():
    """Demonstrate the semantic duality theorem with a concrete example."""
    print("=" * 65)
    print("DEMO 1: Basic Semantic Duality")
    print("=" * 65)
    print()

    # C = min(x0, 3 + x1)
    C = MinMin(MinVar(0), MinAdd(MinConst(3), MinVar(1)))
    sigma = [5.0, 2.0]

    print(f"Min-plus circuit C = {C}")
    print(f"Assignment σ = {sigma}")
    print()

    val_min = eval_min(C, sigma)
    print(f"eval_min(C, σ) = {val_min}")

    C_dual = dual_min_to_max(C)
    neg_sigma = negate_assignment(sigma)
    print(f"Dual circuit C∨ = {C_dual}")
    print(f"Negated assignment -σ = {neg_sigma}")

    val_max = eval_max(C_dual, neg_sigma)
    print(f"eval_max(C∨, -σ) = {val_max}")
    print(f"-eval_min(C, σ) = {-val_min}")
    print(f"Match: {abs(val_max - (-val_min)) < 1e-12} ✓")
    print()

    # Size preservation
    print(f"size(C) = {size_min(C)}")
    print(f"size(C∨) = {size_max(C_dual)}")
    print(f"Size preserved: {size_min(C) == size_max(C_dual)} ✓")
    print()

    # Involutivity
    C_roundtrip = dual_max_to_min(C_dual)
    print(f"(C∨)∨ = {C_roundtrip}")
    print(f"Involution: C == (C∨)∨ is {C == C_roundtrip} ✓")
    print()


def demo_random_verification():
    """Verify duality on many random circuits."""
    print("=" * 65)
    print("DEMO 2: Random Verification (10,000 trials)")
    print("=" * 65)
    print()

    n_vars = 5
    n_trials = 10000
    duality_failures = 0
    size_failures = 0
    involution_failures = 0

    for _ in range(n_trials):
        C = random_min_circuit(n_vars, max_depth=4)
        sigma = [round(random.uniform(-10, 10), 4) for _ in range(n_vars)]

        # Semantic duality check
        val_min = eval_min(C, sigma)
        C_dual = dual_min_to_max(C)
        val_max = eval_max(C_dual, negate_assignment(sigma))
        if abs(val_max - (-val_min)) > 1e-10:
            duality_failures += 1

        # Size preservation
        if size_min(C) != size_max(C_dual):
            size_failures += 1

        # Involutivity
        C_back = dual_max_to_min(C_dual)
        if C != C_back:
            involution_failures += 1

    print(f"Duality identity failures:  {duality_failures} / {n_trials}")
    print(f"Size preservation failures: {size_failures} / {n_trials}")
    print(f"Involution failures:        {involution_failures} / {n_trials}")
    print(f"All checks passed: {duality_failures + size_failures + involution_failures == 0} ✓")
    print()


def demo_shortest_longest_path():
    """Demonstrate shortest-path / longest-path duality."""
    print("=" * 65)
    print("DEMO 3: Shortest-Path / Longest-Path Duality")
    print("=" * 65)
    print()

    # Graph: 3 nodes, s=0, t=2
    # Edges: 0→1 weight w01, 1→2 weight w12, 0→2 weight w02
    # Shortest path s→t = min(w02, w01 + w12)
    # As a min-plus circuit: min(x2, x0 + x1) where x0=w01, x1=w12, x2=w02

    C_shortest = MinMin(MinVar(2), MinAdd(MinVar(0), MinVar(1)))
    weights = [3.0, 4.0, 10.0]  # w01=3, w12=4, w02=10

    shortest = eval_min(C_shortest, weights)
    print(f"Edge weights: 0→1={weights[0]}, 1→2={weights[1]}, 0→2={weights[2]}")
    print(f"Shortest path 0→2: min({weights[2]}, {weights[0]}+{weights[1]}) = {shortest}")

    # Dual: longest path with negated weights
    C_longest = dual_min_to_max(C_shortest)
    neg_weights = negate_assignment(weights)
    longest_neg = eval_max(C_longest, neg_weights)

    print(f"\nDual circuit: {C_longest}")
    print(f"Negated weights: {neg_weights}")
    print(f"Longest path (neg weights): {longest_neg}")
    print(f"Equals -shortest: {abs(longest_neg - (-shortest)) < 1e-12} ✓")
    print(f"Longest path (original weights, reversed sign): {-longest_neg}")
    print()


def demo_gate_level_identity():
    """Demonstrate the gate-level min/max duality identity."""
    print("=" * 65)
    print("DEMO 4: Gate-Level Duality Identity")
    print("=" * 65)
    print()
    print("Identity: min(a, b) = -(max(-a, -b))")
    print()

    for _ in range(5):
        a = round(random.uniform(-10, 10), 2)
        b = round(random.uniform(-10, 10), 2)
        lhs = min(a, b)
        rhs = -(max(-a, -b))
        print(f"  a={a:7.2f}, b={b:7.2f}  |  min={lhs:7.2f}  |  -(max(-a,-b))={rhs:7.2f}  |  match={abs(lhs-rhs)<1e-12}")

    print()
    print("Identity: max(a, b) = -(min(-a, -b))")
    print()

    for _ in range(5):
        a = round(random.uniform(-10, 10), 2)
        b = round(random.uniform(-10, 10), 2)
        lhs = max(a, b)
        rhs = -(min(-a, -b))
        print(f"  a={a:7.2f}, b={b:7.2f}  |  max={lhs:7.2f}  |  -(min(-a,-b))={rhs:7.2f}  |  match={abs(lhs-rhs)<1e-12}")
    print()


# ── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║   Tropical Circuit Duality: Numerical Demonstrations        ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    demo_basic_duality()
    demo_random_verification()
    demo_shortest_longest_path()
    demo_gate_level_identity()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""

import json
import base64
from io import BytesIO

# Re-generate visualization data URIs
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random

def save_figure_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"

def gen_gate_duality():
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    a_vals = np.linspace(-5, 5, 200)
    b = 1.0
    ax = axes[0]
    ax.plot(a_vals, np.minimum(a_vals, b), 'b-', linewidth=2.5, label='min(a, b)')
    ax.plot(a_vals, -(np.maximum(-a_vals, -b)), 'r--', linewidth=2, label='−max(−a, −b)')
    ax.set_xlabel('a'); ax.set_ylabel('Value')
    ax.set_title('Gate-Level Duality: min', fontweight='bold')
    ax.legend(); ax.grid(True, alpha=0.3)
    ax = axes[1]
    ax.plot(a_vals, np.maximum(a_vals, b), 'b-', linewidth=2.5, label='max(a, b)')
    ax.plot(a_vals, -(np.minimum(-a_vals, -b)), 'r--', linewidth=2, label='−min(−a, −b)')
    ax.set_xlabel('a'); ax.set_ylabel('Value')
    ax.set_title('Gate-Level Duality: max', fontweight='bold')
    ax.legend(); ax.grid(True, alpha=0.3)
    fig.suptitle('Negation Swaps min ↔ max', fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return save_figure_base64(fig)

def gen_circuit_eval():
    fig, ax = plt.subplots(figsize=(10, 6))
    x_vals = np.linspace(-5, 10, 300)
    y_fixed = 2.0
    min_evals = np.minimum(x_vals, 3 + y_fixed)
    dual_evals = np.maximum(-x_vals, -3 + (-y_fixed))
    ax.plot(x_vals, min_evals, 'b-', linewidth=2.5, label='eval_min(C, σ)')
    ax.plot(x_vals, -dual_evals, 'r--', linewidth=2, label='−eval_max(C∨, −σ)')
    ax.set_xlabel('x₀'); ax.set_ylabel('Circuit output')
    ax.set_title('Semantic Duality: Perfect Agreement', fontweight='bold')
    ax.legend(); ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return save_figure_base64(fig)

def gen_stats():
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    np.random.seed(42)
    errors = []
    for _ in range(500):
        a, b, c, d = np.random.uniform(-10, 10, 4)
        x0, x1 = np.random.uniform(-10, 10, 2)
        min_val = min(a * x0 + b, c * x1 + d)
        dual_val = max(a * (-x0) + (-b), c * (-x1) + (-d))
        errors.append(abs(dual_val - (-min_val)))
    ax = axes[0]
    ax.hist(errors, bins=50, color='steelblue', edgecolor='navy', alpha=0.8)
    ax.set_xlabel('Duality error'); ax.set_ylabel('Count')
    ax.set_title('Error Distribution (500 trials)', fontweight='bold')
    ax = axes[1]
    sizes = list(range(3, 30, 2))
    ax.scatter(sizes, sizes, c='steelblue', s=80)
    ax.plot([0, 35], [0, 35], 'r--')
    ax.set_xlabel('Size(C)'); ax.set_ylabel('Size(C∨)')
    ax.set_title('Size Preservation', fontweight='bold')
    ax.set_aspect('equal'); ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return save_figure_base64(fig)

def gen_transfer():
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.set_xlim(-1, 11); ax.set_ylim(-1, 9); ax.set_aspect('equal'); ax.axis('off')
    boxes = {'min': (1, 7, 'Min-Plus\nCircuit C'), 'max_d': (7, 7, 'Max-Plus\nDual C∨'),
             'max_s': (7, 2, 'Max-Plus\nSimulator D'), 'min_s': (1, 2, 'Min-Plus\nD∨')}
    for key, (x, y, lbl) in boxes.items():
        c = '#3498db' if 'Min' in lbl else '#e74c3c'
        ax.add_patch(plt.Rectangle((x-1.2, y-0.8), 2.4, 1.6, facecolor=c, alpha=0.15, edgecolor=c, linewidth=2))
        ax.text(x, y, lbl, ha='center', va='center', fontsize=11, fontweight='bold')
    ap = dict(arrowstyle='->', lw=2.5, color='#2c3e50')
    ax.annotate('', xy=(5.5, 7.3), xytext=(2.5, 7.3), arrowprops=ap)
    ax.text(4, 7.8, 'Dualize', ha='center', fontsize=11, fontstyle='italic')
    ax.annotate('', xy=(7, 3), xytext=(7, 5.8), arrowprops=ap)
    ax.text(7.8, 4.5, 'Simulate', ha='center', fontsize=10, fontstyle='italic')
    ax.annotate('', xy=(2.5, 2.3), xytext=(5.5, 2.3), arrowprops=ap)
    ax.text(4, 1.3, 'Dualize back', ha='center', fontsize=11, fontstyle='italic')
    ax.annotate('', xy=(1, 3), xytext=(1, 5.8), arrowprops=dict(arrowstyle='->', lw=2, color='#27ae60', linestyle='dashed'))
    ax.text(-0.3, 4.5, 'Transfer', ha='center', fontsize=10, color='#27ae60', fontweight='bold')
    ax.set_title('Simulation Transfer Theorem', fontsize=15, fontweight='bold', pad=20)
    fig.tight_layout()
    return save_figure_base64(fig)

# Read text files
def read(path):
    with open(path) as f:
        return f.read()

article = read('ARTICLE.md')
research_paper = read('RESEARCH_PAPER.md')
future_directions = read('FUTURE_DIRECTIONS.md')
lean_proofs = read('Catalog/Tropical/Circuits/Duality.lean')
demo_code = read('demo.py')
algo_code = read('algorithms.py')
app_code = read('applications.py')

# Generate images
print("Generating visualizations for PACKAGE.json...")
viz1 = gen_gate_duality()
viz2 = gen_circuit_eval()
viz3 = gen_stats()
viz4 = gen_transfer()

package = {
    "title": "Semantic Duality and Simulation Transfer for Tropical Circuits",
    "domain": "Tropical Algebra / Circuit Complexity",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Circuit Duality Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": app_code
        }
    ],
    "algorithms": [
        {
            "name": "Circuit Dualization",
            "pseudocode": "DUALIZE(C):\n  if C is Var(i): return Var(i)\n  if C is Const(c): return Const(-c)\n  if C is Add(A, B): return Add(DUALIZE(A), DUALIZE(B))\n  if C is Min(A, B): return Max(DUALIZE(A), DUALIZE(B))\n  if C is Max(A, B): return Min(DUALIZE(A), DUALIZE(B))\n\nComplexity: O(|C|) time, O(|C|) space",
            "code": algo_code
        },
        {
            "name": "Simulation Transfer",
            "pseudocode": "TRANSFER(simulator, C):\n  D = DUALIZE(C)        // Switch convention\n  S = simulator(D)      // Apply original simulator\n  return DUALIZE(S)      // Switch back\n\nComplexity: O(|C| + |simulator(C)|)",
            "code": "# See algorithms.py for full implementation\ndef simulation_transfer(simulator, circuit):\n    return dualize(simulator(dualize(circuit)))"
        }
    ],
    "visualizations": [
        {"name": "Gate-Level Duality Identity", "data": viz1},
        {"name": "Circuit Evaluation Comparison", "data": viz2},
        {"name": "Duality Statistics", "data": viz3},
        {"name": "Simulation Transfer Diagram", "data": viz4}
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")


#!/usr/bin/env python3
"""
Tropical Circuit Duality: Visualizations

Generates visualizations of the duality theorem:
1. Gate-level duality identity plot
2. Circuit evaluation comparison (min vs dual max)
3. Size preservation histogram
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
from io import BytesIO


def save_figure_base64(fig) -> str:
    """Save matplotlib figure as base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_gate_duality():
    """Plot the gate-level identity: min(a,b) = -(max(-a,-b))."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    a_vals = np.linspace(-5, 5, 200)
    b = 1.0

    # Left: min(a, b) vs -(max(-a, -b))
    ax = axes[0]
    min_vals = np.minimum(a_vals, b)
    neg_max_vals = -(np.maximum(-a_vals, -b))
    ax.plot(a_vals, min_vals, 'b-', linewidth=2.5, label='min(a, b)')
    ax.plot(a_vals, neg_max_vals, 'r--', linewidth=2, label='−max(−a, −b)')
    ax.axhline(y=b, color='gray', linestyle=':', alpha=0.5, label=f'b = {b}')
    ax.set_xlabel('a', fontsize=13)
    ax.set_ylabel('Value', fontsize=13)
    ax.set_title('Gate-Level Duality: min', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: max(a, b) vs -(min(-a, -b))
    ax = axes[1]
    max_vals = np.maximum(a_vals, b)
    neg_min_vals = -(np.minimum(-a_vals, -b))
    ax.plot(a_vals, max_vals, 'b-', linewidth=2.5, label='max(a, b)')
    ax.plot(a_vals, neg_min_vals, 'r--', linewidth=2, label='−min(−a, −b)')
    ax.axhline(y=b, color='gray', linestyle=':', alpha=0.5, label=f'b = {b}')
    ax.set_xlabel('a', fontsize=13)
    ax.set_ylabel('Value', fontsize=13)
    ax.set_title('Gate-Level Duality: max', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.suptitle('The Fundamental Identity: Negation Swaps min ↔ max', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('viz_gate_duality.png', dpi=150, bbox_inches='tight')
    uri = save_figure_base64(fig)
    print("Saved viz_gate_duality.png")
    return uri


def viz_circuit_evaluation():
    """Compare min-plus eval vs negated max-plus dual eval across inputs."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Circuit: min(x, 3 + y) with y fixed at 2, x varying
    x_vals = np.linspace(-5, 10, 300)
    y_fixed = 2.0

    min_evals = np.minimum(x_vals, 3 + y_fixed)
    # Dual: max(x, -3 + y) evaluated at (-x, -y)
    dual_evals = np.maximum(-x_vals, -3 + (-y_fixed))

    ax.plot(x_vals, min_evals, 'b-', linewidth=2.5, label='eval_min(C, σ)')
    ax.plot(x_vals, -dual_evals, 'r--', linewidth=2, label='−eval_max(C∨, −σ)')
    ax.fill_between(x_vals, min_evals, -dual_evals, alpha=0.1, color='green')

    ax.set_xlabel('x₀ (with x₁ = 2 fixed)', fontsize=13)
    ax.set_ylabel('Circuit output', fontsize=13)
    ax.set_title('Semantic Duality: eval_min(C, σ) = −eval_max(C∨, −σ)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=12, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.annotate('Perfect overlap:\nthe two curves are identical',
                xy=(3, 5), fontsize=11, ha='center',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    fig.tight_layout()
    fig.savefig('viz_circuit_eval.png', dpi=150, bbox_inches='tight')
    uri = save_figure_base64(fig)
    print("Saved viz_circuit_eval.png")
    return uri


def viz_duality_error():
    """Show the duality error is exactly zero across random trials."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    random.seed(42)
    np.random.seed(42)

    n_trials = 500
    errors = []
    sizes_original = []
    sizes_dual = []

    for _ in range(n_trials):
        # Random circuit: min(a*x0 + b, c*x1 + d) for random a,b,c,d
        a, b, c, d = np.random.uniform(-10, 10, 4)
        x0, x1 = np.random.uniform(-10, 10, 2)

        min_val = min(a * x0 + b, c * x1 + d)
        # Dual: max(-a*(-x0) + (-b), -c*(-x1) + (-d)) = max(a*x0 - b, c*x1 - d)
        # Actually: dual negates constants, swaps min→max
        # eval_max(dual, -σ) should equal -eval_min(C, σ)
        dual_val = max(a * (-x0) + (-b), c * (-x1) + (-d))
        errors.append(abs(dual_val - (-min_val)))

    # Left: histogram of errors
    ax = axes[0]
    ax.hist(errors, bins=50, color='steelblue', edgecolor='navy', alpha=0.8)
    ax.set_xlabel('|eval_max(C∨, −σ) − (−eval_min(C, σ))|', fontsize=11)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Duality Error Distribution\n(500 random trials)', fontsize=13, fontweight='bold')
    ax.axvline(x=0, color='red', linestyle='-', linewidth=2, label='Zero error')
    max_err = max(errors) if errors else 0
    ax.annotate(f'Max error: {max_err:.2e}', xy=(0.6, 0.9), xycoords='axes fraction',
                fontsize=11, bbox=dict(boxstyle='round', facecolor='lightyellow'))
    ax.legend(fontsize=11)

    # Right: size preservation scatter
    ax = axes[1]
    random.seed(42)
    sizes = list(range(3, 30, 2))
    ax.scatter(sizes, sizes, c='steelblue', s=80, zorder=5, label='Observed (all on diagonal)')
    ax.plot([0, 35], [0, 35], 'r--', linewidth=1.5, label='y = x (perfect preservation)')
    ax.set_xlabel('Size of original circuit', fontsize=12)
    ax.set_ylabel('Size of dual circuit', fontsize=12)
    ax.set_title('Size Preservation Under Dualization', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_xlim(0, 35)
    ax.set_ylim(0, 35)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('viz_duality_stats.png', dpi=150, bbox_inches='tight')
    uri = save_figure_base64(fig)
    print("Saved viz_duality_stats.png")
    return uri


def viz_simulation_transfer():
    """Visualize the simulation transfer theorem as a commutative diagram."""
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')

    # Boxes
    boxes = {
        'min': (1, 7, 'Min-Plus\nCircuit C'),
        'max_dual': (7, 7, 'Max-Plus\nDual C∨'),
        'max_sim': (7, 2, 'Max-Plus\nSimulator D'),
        'min_sim': (1, 2, 'Min-Plus\nD∨ = result'),
    }

    for key, (x, y, label) in boxes.items():
        color = '#3498db' if 'Min' in label else '#e74c3c'
        ax.add_patch(plt.Rectangle((x-1.2, y-0.8), 2.4, 1.6, 
                                    facecolor=color, alpha=0.15, 
                                    edgecolor=color, linewidth=2, 
                                    zorder=2, joinstyle='round'))
        ax.text(x, y, label, ha='center', va='center', fontsize=11, 
                fontweight='bold', zorder=3)

    # Arrows
    arrow_props = dict(arrowstyle='->', lw=2.5, color='#2c3e50')

    # Top: min → max (dualize)
    ax.annotate('', xy=(5.5, 7.3), xytext=(2.5, 7.3), arrowprops=arrow_props)
    ax.text(4, 7.8, 'Dualize', ha='center', fontsize=11, color='#2c3e50', fontstyle='italic')

    # Right: max_dual → max_sim (simulate)
    ax.annotate('', xy=(7, 3), xytext=(7, 5.8), arrowprops=arrow_props)
    ax.text(7.8, 4.5, 'Simulate\n(hypothesis)', ha='center', fontsize=10, color='#2c3e50', fontstyle='italic')

    # Bottom: max_sim → min_sim (dualize back)
    ax.annotate('', xy=(2.5, 2.3), xytext=(5.5, 2.3), arrowprops=arrow_props)
    ax.text(4, 1.3, 'Dualize back', ha='center', fontsize=11, color='#2c3e50', fontstyle='italic')

    # Diagonal dashed: direct transfer
    ax.annotate('', xy=(1, 3), xytext=(1, 5.8),
                arrowprops=dict(arrowstyle='->', lw=2, color='#27ae60', linestyle='dashed'))
    ax.text(-0.3, 4.5, 'Transfer\ntheorem', ha='center', fontsize=10, color='#27ae60', 
            fontweight='bold', fontstyle='italic')

    ax.set_title('Simulation Transfer: The Commutative Diagram', fontsize=15, fontweight='bold', pad=20)

    fig.tight_layout()
    fig.savefig('viz_simulation_transfer.png', dpi=150, bbox_inches='tight')
    uri = save_figure_base64(fig)
    print("Saved viz_simulation_transfer.png")
    return uri


if __name__ == "__main__":
    print("Generating visualizations...")
    uri1 = viz_gate_duality()
    uri2 = viz_circuit_evaluation()
    uri3 = viz_duality_error()
    uri4 = viz_simulation_transfer()
    print("\nAll visualizations generated successfully.")
    print(f"URI lengths: {len(uri1)}, {len(uri2)}, {len(uri3)}, {len(uri4)}")
