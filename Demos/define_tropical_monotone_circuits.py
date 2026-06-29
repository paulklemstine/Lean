#!/usr/bin/env python3
"""
Tropical Monotone Circuits — Applications
===========================================

Real-world applications demonstrating how tropical monotone circuits
connect to shortest paths, dynamic programming, and neural networks.
"""

import numpy as np
from typing import List, Dict, Tuple
from dataclasses import dataclass


# ─────────────────────────────────────────────────
# Reuse core types
# ─────────────────────────────────────────────────

class TropCircuit:
    pass

@dataclass
class Var(TropCircuit):
    index: int

@dataclass
class Const(TropCircuit):
    value: float

@dataclass
class Add(TropCircuit):
    left: TropCircuit
    right: TropCircuit

@dataclass
class Min(TropCircuit):
    left: TropCircuit
    right: TropCircuit


def evaluate(c: TropCircuit, x: List[float]) -> float:
    if isinstance(c, Var): return x[c.index]
    elif isinstance(c, Const): return c.value
    elif isinstance(c, Add): return evaluate(c.left, x) + evaluate(c.right, x)
    elif isinstance(c, Min): return min(evaluate(c.left, x), evaluate(c.right, x))
    raise TypeError


# ─────────────────────────────────────────────────
# Application 1: Shortest Path as Tropical Circuit
# ─────────────────────────────────────────────────

def shortest_path_circuit():
    """
    Model a shortest-path problem as a tropical circuit.

    Consider a directed graph with 4 nodes (s, a, b, t) and 5 edges:
        s→a (weight x0), s→b (weight x1),
        a→b (weight x2), a→t (weight x3), b→t (weight x4)

    The shortest s→t path has cost:
        min(x0 + x3,           # s→a→t
            x1 + x4,           # s→b→t
            x0 + x2 + x4)      # s→a→b→t

    This is exactly a tropical circuit!
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest Path as Tropical Circuit")
    print("=" * 60)
    print()
    print("Graph: s → a → t")
    print("       s → b → t")
    print("       a → b")
    print()
    print("Edge weights: x0=s→a, x1=s→b, x2=a→b, x3=a→t, x4=b→t")
    print()

    # Build the circuit
    path_sat = Add(Var(0), Var(3))          # s→a→t: x0 + x3
    path_sbt = Add(Var(1), Var(4))          # s→b→t: x1 + x4
    path_sabt = Add(Add(Var(0), Var(2)), Var(4))  # s→a→b→t: x0 + x2 + x4

    circuit = Min(Min(path_sat, path_sbt), path_sabt)

    # Test cases
    test_cases = [
        ("Equal weights", [1.0, 1.0, 1.0, 1.0, 1.0]),
        ("Direct a→t cheap", [1.0, 5.0, 5.0, 0.5, 5.0]),
        ("Via b cheap", [5.0, 1.0, 5.0, 5.0, 0.5]),
        ("Detour a→b→t cheap", [0.1, 5.0, 0.1, 5.0, 0.1]),
    ]

    for name, weights in test_cases:
        result = evaluate(circuit, weights)
        paths = {
            "s→a→t": weights[0] + weights[3],
            "s→b→t": weights[1] + weights[4],
            "s→a→b→t": weights[0] + weights[2] + weights[4],
        }
        best = min(paths, key=paths.get)
        print(f"  {name}: weights = {weights}")
        print(f"    Path costs: {paths}")
        print(f"    Circuit output: {result:.2f} (best path: {best})")
        print()


# ─────────────────────────────────────────────────
# Application 2: Dynamic Programming — Knapsack-like
# ─────────────────────────────────────────────────

def dp_scheduling():
    """
    Model a simple scheduling problem as a tropical circuit.

    Three tasks with variable durations x0, x1, x2.
    Two machines can run in parallel.
    Schedule: machine 1 runs tasks 0,1 sequentially; machine 2 runs task 2.
    Makespan = max(x0+x1, x2) — but in min-plus, this becomes the dual.

    We model the minimum total cost variant:
    Given costs x0, x1, x2 for three jobs, find the cheapest 2-job subset.
    Cost = min(x0+x1, x0+x2, x1+x2)
    """
    print("=" * 60)
    print("APPLICATION 2: Job Selection via Tropical Circuit")
    print("=" * 60)
    print()
    print("Problem: Select 2 of 3 jobs to minimize total cost.")
    print("Circuit: min(x₀+x₁, min(x₀+x₂, x₁+x₂))")
    print()

    circuit = Min(Add(Var(0), Var(1)),
                  Min(Add(Var(0), Var(2)), Add(Var(1), Var(2))))

    test_cases = [
        ("Balanced", [3.0, 4.0, 5.0]),
        ("One cheap", [1.0, 10.0, 10.0]),
        ("Two cheap", [1.0, 2.0, 100.0]),
    ]

    for name, costs in test_cases:
        result = evaluate(circuit, costs)
        pairs = {
            "jobs 0,1": costs[0] + costs[1],
            "jobs 0,2": costs[0] + costs[2],
            "jobs 1,2": costs[1] + costs[2],
        }
        best = min(pairs, key=pairs.get)
        print(f"  {name}: costs = {costs}")
        print(f"    Pair costs: {pairs}")
        print(f"    Optimal: {result:.1f} (select {best})")
        print()

    # Monotonicity in action
    print("  Monotonicity: increasing a cost can only increase the optimum")
    base = [3.0, 4.0, 5.0]
    base_val = evaluate(circuit, base)
    for i in range(3):
        modified = base.copy()
        modified[i] += 2.0
        mod_val = evaluate(circuit, modified)
        print(f"    Base costs {base} → {base_val:.1f}")
        print(f"    Increase x{i} by 2: {modified} → {mod_val:.1f}  "
              f"(Δ = {mod_val - base_val:+.1f})")
    print()


# ─────────────────────────────────────────────────
# Application 3: ReLU Network as Tropical Circuit
# ─────────────────────────────────────────────────

def relu_network_connection():
    """
    Demonstrate that single-layer ReLU networks with non-negative weights
    compute piecewise-linear monotone functions, like tropical circuits.

    A ReLU neuron: max(0, w·x + b) with w ≥ 0
    A min-of-ReLU: min over neurons

    In the dual (max-plus) view, tropical circuits compute exactly
    these piecewise-linear concave functions.
    """
    print("=" * 60)
    print("APPLICATION 3: Tropical Circuits and Piecewise-Linear Functions")
    print("=" * 60)
    print()
    print("Tropical circuits compute piecewise-linear concave functions.")
    print("These are the same functions computed by 'min-of-affine' models")
    print("used in robust optimization and interpretable ML.")
    print()

    # Circuit: min(2x₀ + x₁ + 1, x₀ + 2x₁ + 0.5, 3x₀ + 3)
    c = Min(
        Min(
            Add(Add(Var(0), Var(0)), Add(Var(1), Const(1.0))),
            Add(Add(Var(0), Var(1)), Add(Var(1), Const(0.5)))
        ),
        Add(Add(Add(Var(0), Var(0)), Var(0)), Const(3.0))
    )

    print("Circuit computes: min(2x₀ + x₁ + 1, x₀ + 2x₁ + 0.5, 3x₀ + 3)")
    print()

    # Evaluate on a grid
    print("  Evaluation on sample points:")
    for x0 in [0.0, 1.0, 2.0]:
        for x1 in [0.0, 1.0, 2.0]:
            val = evaluate(c, [x0, x1])
            # Determine which piece is active
            pieces = [
                2*x0 + x1 + 1,
                x0 + 2*x1 + 0.5,
                3*x0 + 3,
            ]
            active = pieces.index(min(pieces))
            piece_names = ["2x₀+x₁+1", "x₀+2x₁+0.5", "3x₀+3"]
            print(f"    f({x0:.0f}, {x1:.0f}) = {val:.1f}  "
                  f"[active piece: {piece_names[active]}]")
    print()
    print("  Each input activates one affine piece — the circuit computes")
    print("  a piecewise-linear concave landscape, just like tropical geometry predicts.")
    print()


# ─────────────────────────────────────────────────
# Application 4: Reliability Network
# ─────────────────────────────────────────────────

def reliability_network():
    """
    Model a series-parallel reliability network.

    In a series connection, both components must work (costs add).
    In a parallel connection, either suffices (min cost).

    This directly maps to tropical circuits:
    series = add, parallel = min.
    """
    print("=" * 60)
    print("APPLICATION 4: Series-Parallel Reliability Network")
    print("=" * 60)
    print()
    print("Network topology:")
    print("  Path 1: component 0 → component 1 (series)")
    print("  Path 2: component 2 (direct)")
    print("  System: Path 1 ∥ Path 2 (parallel)")
    print()
    print("Costs: x₀ = repair cost of comp 0, etc.")
    print("System cost = min(x₀ + x₁, x₂)")
    print()

    circuit = Min(Add(Var(0), Var(1)), Var(2))

    scenarios = [
        ("Cheap backup", [5.0, 5.0, 3.0]),
        ("Cheap main path", [1.0, 1.0, 10.0]),
        ("Balanced", [3.0, 3.0, 5.0]),
    ]

    for name, costs in scenarios:
        val = evaluate(circuit, costs)
        print(f"  {name}: costs = {costs}")
        print(f"    Main path: {costs[0]:.1f} + {costs[1]:.1f} = {costs[0]+costs[1]:.1f}")
        print(f"    Backup: {costs[2]:.1f}")
        print(f"    System cost: {val:.1f}")
        print()


# ─────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    shortest_path_circuit()
    dp_scheduling()
    relu_network_connection()
    reliability_network()

    print("=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Monotone Circuits — Demo
==================================

Concrete numerical demonstrations of the four main theorems:
1. Monotonicity
2. Boolean Embedding
3. Normal Form Decomposition
4. Min-Max Duality
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Callable, Union
from itertools import product as iterproduct


# ─────────────────────────────────────────────────
# Core Data Structures
# ─────────────────────────────────────────────────

class TropCircuit:
    """Base class for tropical monotone circuit nodes."""
    pass

@dataclass
class Var(TropCircuit):
    index: int

@dataclass
class Const(TropCircuit):
    value: float

@dataclass
class Add(TropCircuit):
    left: TropCircuit
    right: TropCircuit

@dataclass
class Min(TropCircuit):
    left: TropCircuit
    right: TropCircuit


def evaluate(c: TropCircuit, x: List[float]) -> float:
    """Evaluate a tropical circuit at input x."""
    if isinstance(c, Var):
        return x[c.index]
    elif isinstance(c, Const):
        return c.value
    elif isinstance(c, Add):
        return evaluate(c.left, x) + evaluate(c.right, x)
    elif isinstance(c, Min):
        return min(evaluate(c.left, x), evaluate(c.right, x))
    raise ValueError(f"Unknown node type: {type(c)}")


def size(c: TropCircuit) -> int:
    """Count nodes in the circuit."""
    if isinstance(c, (Var, Const)):
        return 1
    elif isinstance(c, (Add, Min)):
        return 1 + size(c.left) + size(c.right)
    raise ValueError


def depth(c: TropCircuit) -> int:
    """Depth of the circuit tree."""
    if isinstance(c, (Var, Const)):
        return 0
    elif isinstance(c, (Add, Min)):
        return 1 + max(depth(c.left), depth(c.right))
    raise ValueError


# ─────────────────────────────────────────────────
# Demo 1: Monotonicity
# ─────────────────────────────────────────────────

def demo_monotonicity():
    """Demonstrate that tropical circuits compute monotone functions."""
    print("=" * 60)
    print("DEMO 1: Monotonicity of Tropical Monotone Circuits")
    print("=" * 60)
    print()

    # Circuit: min(x0 + x1, x2 + 3)
    C = Min(Add(Var(0), Var(1)), Add(Var(2), Const(3.0)))
    print("Circuit: min(x₀ + x₁, x₂ + 3)")
    print()

    # Test with ordered inputs
    test_pairs = [
        ([1.0, 2.0, 0.5], [2.0, 3.0, 1.0]),
        ([0.0, 0.0, 0.0], [1.0, 1.0, 1.0]),
        ([-2.0, -1.0, 0.0], [-1.0, 0.0, 0.5]),
        ([5.0, 5.0, 5.0], [5.0, 5.0, 5.0]),  # equal inputs
    ]

    all_passed = True
    for x, y in test_pairs:
        ex = evaluate(C, x)
        ey = evaluate(C, y)
        ok = ex <= ey
        all_passed = all_passed and ok
        status = "✓" if ok else "✗"
        print(f"  x = {x}  →  eval = {ex:.2f}")
        print(f"  y = {y}  →  eval = {ey:.2f}")
        print(f"  x ≤ y componentwise? {all(xi <= yi for xi, yi in zip(x, y))}")
        print(f"  eval(x) ≤ eval(y)?   {ok}  {status}")
        print()

    # Random stress test
    np.random.seed(42)
    n_tests = 10000
    violations = 0
    for _ in range(n_tests):
        x = np.random.randn(3)
        delta = np.abs(np.random.randn(3))
        y = x + delta
        if evaluate(C, x.tolist()) > evaluate(C, y.tolist()) + 1e-12:
            violations += 1

    print(f"  Random stress test: {n_tests} pairs, {violations} violations")
    print(f"  Monotonicity {'CONFIRMED' if violations == 0 else 'VIOLATED'}!")
    print()


# ─────────────────────────────────────────────────
# Demo 2: Boolean Embedding
# ─────────────────────────────────────────────────

class BoolFormula:
    """Boolean monotone formula."""
    pass

@dataclass
class BVar(BoolFormula):
    index: int

@dataclass
class BTop(BoolFormula):
    pass

@dataclass
class BBot(BoolFormula):
    pass

@dataclass
class BAnd(BoolFormula):
    left: BoolFormula
    right: BoolFormula

@dataclass
class BOr(BoolFormula):
    left: BoolFormula
    right: BoolFormula


def bool_eval(f: BoolFormula, sigma: List[bool]) -> bool:
    if isinstance(f, BVar):
        return sigma[f.index]
    elif isinstance(f, BTop):
        return True
    elif isinstance(f, BBot):
        return False
    elif isinstance(f, BAnd):
        return bool_eval(f.left, sigma) and bool_eval(f.right, sigma)
    elif isinstance(f, BOr):
        return bool_eval(f.left, sigma) or bool_eval(f.right, sigma)
    raise ValueError


def encode_bool(b: bool) -> float:
    return 0.0 if b else 1.0


def decode_bool(r: float) -> bool:
    return r <= 0.0


def translate(f: BoolFormula) -> TropCircuit:
    """Translate Boolean formula to tropical circuit."""
    if isinstance(f, BVar):
        return Var(f.index)
    elif isinstance(f, BTop):
        return Const(0.0)
    elif isinstance(f, BBot):
        return Const(1.0)
    elif isinstance(f, BAnd):
        return Add(translate(f.left), translate(f.right))
    elif isinstance(f, BOr):
        return Min(translate(f.left), translate(f.right))
    raise ValueError


def demo_boolean_embedding():
    """Demonstrate that Boolean formulas embed into tropical circuits."""
    print("=" * 60)
    print("DEMO 2: Boolean Embedding into Tropical Circuits")
    print("=" * 60)
    print()

    # Formula: (x0 OR x1) AND (x1 OR x2)
    phi = BAnd(BOr(BVar(0), BVar(1)), BOr(BVar(1), BVar(2)))
    C = translate(phi)
    n_vars = 3

    print("Boolean formula: (x₀ ∨ x₁) ∧ (x₁ ∨ x₂)")
    print("Tropical circuit: add(min(x₀, x₁), min(x₁, x₂))")
    print()
    print(f"  {'σ':>12s}  {'Bool':>6s}  {'Trop':>6s}  {'Decoded':>8s}  {'Match':>5s}")
    print("  " + "-" * 45)

    all_match = True
    for bits in iterproduct([False, True], repeat=n_vars):
        sigma = list(bits)
        bool_result = bool_eval(phi, sigma)
        encoded_input = [encode_bool(b) for b in sigma]
        trop_result = evaluate(C, encoded_input)
        decoded = decode_bool(trop_result)
        match = decoded == bool_result
        all_match = all_match and match

        sigma_str = str([int(b) for b in sigma])
        print(f"  {sigma_str:>12s}  {str(bool_result):>6s}  {trop_result:>6.1f}  {str(decoded):>8s}  {'✓' if match else '✗':>5s}")

    print()
    print(f"  All assignments match: {all_match}")
    print()


# ─────────────────────────────────────────────────
# Demo 3: Normal Form Decomposition
# ─────────────────────────────────────────────────

@dataclass
class AffineForm:
    """Represents const + Σᵢ coeff[i] * xᵢ"""
    coeff: List[int]
    const: float

    def eval(self, x: List[float]) -> float:
        return self.const + sum(c * xi for c, xi in zip(self.coeff, x))

    def __repr__(self):
        terms = []
        if self.const != 0:
            terms.append(f"{self.const:.1f}")
        for i, c in enumerate(self.coeff):
            if c == 1:
                terms.append(f"x{i}")
            elif c > 1:
                terms.append(f"{c}x{i}")
        return " + ".join(terms) if terms else "0"


def normal_forms(c: TropCircuit, n_vars: int) -> List[AffineForm]:
    """Extract normal forms from a tropical circuit."""
    if isinstance(c, Var):
        coeff = [0] * n_vars
        coeff[c.index] = 1
        return [AffineForm(coeff, 0.0)]
    elif isinstance(c, Const):
        return [AffineForm([0] * n_vars, c.value)]
    elif isinstance(c, Min):
        return normal_forms(c.left, n_vars) + normal_forms(c.right, n_vars)
    elif isinstance(c, Add):
        nf_left = normal_forms(c.left, n_vars)
        nf_right = normal_forms(c.right, n_vars)
        result = []
        for a in nf_left:
            for b in nf_right:
                new_coeff = [ac + bc for ac, bc in zip(a.coeff, b.coeff)]
                result.append(AffineForm(new_coeff, a.const + b.const))
        return result
    raise ValueError


def demo_normal_form():
    """Demonstrate the normal form decomposition."""
    print("=" * 60)
    print("DEMO 3: Normal Form Decomposition")
    print("=" * 60)
    print()

    # Circuit: min(x0 + x1, x2 + 3.0)
    C = Min(Add(Var(0), Var(1)), Add(Var(2), Const(3.0)))
    n_vars = 3

    nf = normal_forms(C, n_vars)
    print("Circuit: min(x₀ + x₁, x₂ + 3)")
    print(f"Normal forms ({len(nf)} affine pieces):")
    for i, af in enumerate(nf):
        print(f"  a{i}: {af}")
    print()

    # Verify eval = min over normal forms
    np.random.seed(123)
    print("Verification: eval(C, x) = min{a.eval(x) | a ∈ NF(C)}")
    print()
    for _ in range(5):
        x = np.random.randn(n_vars).tolist()
        circuit_val = evaluate(C, x)
        nf_vals = [af.eval(x) for af in nf]
        nf_min = min(nf_vals)
        match = abs(circuit_val - nf_min) < 1e-10
        print(f"  x = [{', '.join(f'{xi:.3f}' for xi in x)}]")
        print(f"    Circuit eval: {circuit_val:.6f}")
        print(f"    NF minimum:   {nf_min:.6f}  {'✓' if match else '✗'}")
        print(f"    Achieving form: {nf[nf_vals.index(min(nf_vals))]}")
        print()

    # More complex circuit
    print("Complex circuit: min(min(x0+x1, x1+x2), min(x0+x2, x0+1))")
    C2 = Min(Min(Add(Var(0), Var(1)), Add(Var(1), Var(2))),
             Min(Add(Var(0), Var(2)), Add(Var(0), Const(1.0))))
    nf2 = normal_forms(C2, n_vars)
    print(f"Normal forms ({len(nf2)} affine pieces):")
    for i, af in enumerate(nf2):
        print(f"  a{i}: {af}")
    print()


# ─────────────────────────────────────────────────
# Demo 4: Min-Max Duality
# ─────────────────────────────────────────────────

class MaxTropCircuit:
    pass

@dataclass
class MaxVar(MaxTropCircuit):
    index: int

@dataclass
class MaxConst(MaxTropCircuit):
    value: float

@dataclass
class MaxAdd(MaxTropCircuit):
    left: MaxTropCircuit
    right: MaxTropCircuit

@dataclass
class MaxMax(MaxTropCircuit):
    left: MaxTropCircuit
    right: MaxTropCircuit


def max_evaluate(c: MaxTropCircuit, x: List[float]) -> float:
    if isinstance(c, MaxVar):
        return x[c.index]
    elif isinstance(c, MaxConst):
        return c.value
    elif isinstance(c, MaxAdd):
        return max_evaluate(c.left, x) + max_evaluate(c.right, x)
    elif isinstance(c, MaxMax):
        return max(max_evaluate(c.left, x), max_evaluate(c.right, x))
    raise ValueError


def dual(c: TropCircuit) -> MaxTropCircuit:
    """Compute the syntactic dual of a min-plus circuit."""
    if isinstance(c, Var):
        return MaxVar(c.index)
    elif isinstance(c, Const):
        return MaxConst(-c.value)
    elif isinstance(c, Add):
        return MaxAdd(dual(c.left), dual(c.right))
    elif isinstance(c, Min):
        return MaxMax(dual(c.left), dual(c.right))
    raise ValueError


def demo_duality():
    """Demonstrate min-max duality."""
    print("=" * 60)
    print("DEMO 4: Min-Max Duality")
    print("=" * 60)
    print()

    C = Min(Add(Var(0), Var(1)), Add(Var(2), Const(3.0)))
    D = dual(C)
    n_vars = 3

    print("Min-plus circuit C: min(x₀ + x₁, x₂ + 3)")
    print("Max-plus dual D:    max(x₀ + x₁, x₂ + (-3))")
    print()
    print("Theorem: eval(C, x) = -eval_max(D, -x)")
    print()

    np.random.seed(456)
    all_ok = True
    for _ in range(6):
        x = np.random.randn(n_vars).tolist()
        neg_x = [-xi for xi in x]
        lhs = evaluate(C, x)
        rhs = -max_evaluate(D, neg_x)
        ok = abs(lhs - rhs) < 1e-10
        all_ok = all_ok and ok
        print(f"  x = [{', '.join(f'{xi:+.3f}' for xi in x)}]")
        print(f"    eval(C, x)           = {lhs:+.6f}")
        print(f"    -eval_max(D, -x)     = {rhs:+.6f}")
        print(f"    Match: {'✓' if ok else '✗'}")
        print()

    print(f"  All tests passed: {all_ok}")
    print()


# ─────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    demo_monotonicity()
    demo_boolean_embedding()
    demo_normal_form()
    demo_duality()

    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Generate visualizations for tropical monotone circuits.
Saves figures as base64-encoded PNGs.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_piecewise_linear_2d():
    """Visualize a tropical circuit's piecewise-linear output in 1D."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    x = np.linspace(-2, 5, 500)

    # Circuit: min(x + 1, 2x - 1, -x + 4)
    f1 = x + 1
    f2 = 2 * x - 1
    f3 = -0.5 * x + 4

    circuit_out = np.minimum(np.minimum(f1, f2), f3)

    ax.plot(x, f1, '--', color='#e74c3c', alpha=0.5, linewidth=1.5, label='$x + 1$')
    ax.plot(x, f2, '--', color='#3498db', alpha=0.5, linewidth=1.5, label='$2x - 1$')
    ax.plot(x, f3, '--', color='#2ecc71', alpha=0.5, linewidth=1.5, label='$-0.5x + 4$')
    ax.plot(x, circuit_out, '-', color='#2c3e50', linewidth=3, label='Circuit output (minimum)')

    # Mark breakpoints
    # f1 = f2: x+1 = 2x-1 → x=2
    # f1 = f3: x+1 = -0.5x+4 → 1.5x=3 → x=2
    # f2 = f3: 2x-1 = -0.5x+4 → 2.5x=5 → x=2
    ax.axvline(x=2, color='gray', linestyle=':', alpha=0.5)

    ax.set_xlabel('Input x', fontsize=14)
    ax.set_ylabel('Output', fontsize=14)
    ax.set_title('Tropical Circuit as Piecewise-Linear Function\nmin(x+1, 2x-1, -0.5x+4)', fontsize=16)
    ax.legend(fontsize=12, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 8)

    return fig_to_base64(fig)


def viz_piecewise_linear_3d():
    """Visualize a tropical circuit's output as a 3D surface."""
    fig = plt.figure(figsize=(12, 8))
    ax = fig.add_subplot(111, projection='3d')

    x0 = np.linspace(-2, 4, 100)
    x1 = np.linspace(-2, 4, 100)
    X0, X1 = np.meshgrid(x0, x1)

    # Circuit: min(x0 + x1, 2*x0 + 1, x1 + 2)
    F1 = X0 + X1
    F2 = 2 * X0 + 1
    F3 = X1 + 2

    Z = np.minimum(np.minimum(F1, F2), F3)

    surf = ax.plot_surface(X0, X1, Z, cmap='viridis', alpha=0.8,
                            edgecolor='none', antialiased=True)

    ax.set_xlabel('$x_0$', fontsize=14)
    ax.set_ylabel('$x_1$', fontsize=14)
    ax.set_zlabel('Output', fontsize=14)
    ax.set_title('Tropical Circuit Surface\nmin($x_0+x_1$, $2x_0+1$, $x_1+2$)', fontsize=16)
    ax.view_init(elev=25, azim=-60)

    fig.colorbar(surf, shrink=0.5, aspect=10, label='Circuit value')
    return fig_to_base64(fig)


def viz_boolean_embedding():
    """Visualize the Boolean embedding truth table."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Formula: (x0 OR x1) AND (x1 OR x2)
    n_vars = 3
    inputs = []
    bool_outputs = []
    trop_outputs = []

    for b0 in [False, True]:
        for b1 in [False, True]:
            for b2 in [False, True]:
                inputs.append((b0, b1, b2))
                # Boolean eval
                bool_val = (b0 or b1) and (b1 or b2)
                bool_outputs.append(bool_val)
                # Tropical eval
                enc = [0.0 if b else 1.0 for b in (b0, b1, b2)]
                trop_val = min(enc[0], enc[1]) + min(enc[1], enc[2])
                trop_outputs.append(trop_val)

    x_pos = np.arange(8)
    labels = [f"{''.join(str(int(b)) for b in inp)}" for inp in inputs]

    colors_bool = ['#27ae60' if v else '#e74c3c' for v in bool_outputs]
    ax1.bar(x_pos, [1 if v else 0 for v in bool_outputs], color=colors_bool, edgecolor='white')
    ax1.set_xticks(x_pos)
    ax1.set_xticklabels(labels, fontsize=10)
    ax1.set_ylabel('Output', fontsize=12)
    ax1.set_title('Boolean: (x₀ ∨ x₁) ∧ (x₁ ∨ x₂)', fontsize=14)
    ax1.set_ylim(0, 1.3)

    colors_trop = ['#27ae60' if v <= 0 else '#e74c3c' for v in trop_outputs]
    bars = ax1.patches  # not used

    ax2.bar(x_pos, trop_outputs, color=colors_trop, edgecolor='white')
    ax2.axhline(y=0, color='black', linewidth=1, linestyle='-')
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels(labels, fontsize=10)
    ax2.set_ylabel('Tropical value', fontsize=12)
    ax2.set_title('Tropical: add(min(x₀,x₁), min(x₁,x₂))', fontsize=14)

    # Add decode annotations
    for i, (tv, bv) in enumerate(zip(trop_outputs, bool_outputs)):
        decoded = tv <= 0
        ax2.annotate(f'{"T" if decoded else "F"}',
                     (i, tv + 0.1), ha='center', fontsize=9,
                     color='#27ae60' if decoded == bv else '#e74c3c',
                     fontweight='bold')

    fig.suptitle('Boolean ↔ Tropical Embedding', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_normal_form_growth():
    """Visualize how normal form size grows with circuit depth."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # For a balanced tree of alternating min/add gates
    depths = list(range(1, 12))
    nf_sizes_min_tree = []  # All min: NF grows linearly
    nf_sizes_add_tree = []  # All add: NF stays 1
    nf_sizes_mixed = []     # Alternating: exponential

    for d in depths:
        # All min: each min doubles the NF set (union), so 2^(d-1) leaves → 2^d forms
        nf_sizes_min_tree.append(2**d)
        # All add: product keeps it as single combined form
        nf_sizes_add_tree.append(1)
        # Alternating min then add: complex growth
        # min at even levels, add at odd: roughly 2^(d//2)
        nf_sizes_mixed.append(2**(d // 2 + d % 2) if d > 0 else 1)

    ax.semilogy(depths, nf_sizes_min_tree, 'o-', color='#e74c3c',
                linewidth=2, markersize=8, label='All-min tree (exponential)')
    ax.semilogy(depths, nf_sizes_add_tree, 's-', color='#3498db',
                linewidth=2, markersize=8, label='All-add tree (constant)')
    ax.semilogy(depths, nf_sizes_mixed, 'D-', color='#2ecc71',
                linewidth=2, markersize=8, label='Alternating min/add')

    ax.set_xlabel('Circuit Depth', fontsize=14)
    ax.set_ylabel('Number of Affine Forms (log scale)', fontsize=14)
    ax.set_title('Normal Form Size vs. Circuit Structure', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def viz_duality():
    """Visualize min-max duality."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    x = np.linspace(-3, 3, 300)

    # Min-plus: min(x + 1, -x + 2)
    f1 = x + 1
    f2 = -x + 2
    min_plus = np.minimum(f1, f2)

    ax1.plot(x, f1, '--', color='#e74c3c', alpha=0.5, label='$x + 1$')
    ax1.plot(x, f2, '--', color='#3498db', alpha=0.5, label='$-x + 2$')
    ax1.plot(x, min_plus, '-', color='#2c3e50', linewidth=3, label='min (circuit)')
    ax1.fill_between(x, min_plus, -5, alpha=0.1, color='#2c3e50')
    ax1.set_title('Min-Plus Circuit', fontsize=14)
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('Output', fontsize=12)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-3, 5)

    # Dual (max-plus on negated input): max((-x) + (-1), -(-x) + (-2)) = max(-x-1, x-2)
    g1 = -x - 1
    g2 = x - 2
    max_plus = np.maximum(g1, g2)

    ax2.plot(x, g1, '--', color='#e74c3c', alpha=0.5, label='$-x - 1$')
    ax2.plot(x, g2, '--', color='#3498db', alpha=0.5, label='$x - 2$')
    ax2.plot(x, max_plus, '-', color='#8e44ad', linewidth=3, label='max (dual circuit)')
    ax2.plot(x, -max_plus, '-', color='#2c3e50', linewidth=3, alpha=0.5,
             linestyle=':', label='−max (= original)')
    ax2.fill_between(x, max_plus, 5, alpha=0.1, color='#8e44ad')
    ax2.set_title('Max-Plus Dual Circuit', fontsize=14)
    ax2.set_xlabel('−x', fontsize=12)
    ax2.set_ylabel('Output', fontsize=12)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-5, 3)

    fig.suptitle('Min-Max Duality: min(a,b)(x) = −max(−a,−b)(−x)', fontsize=16, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    vizzes = {}
    vizzes['piecewise_linear_2d'] = viz_piecewise_linear_2d()
    print("  ✓ Piecewise linear 2D")

    vizzes['piecewise_linear_3d'] = viz_piecewise_linear_3d()
    print("  ✓ Piecewise linear 3D surface")

    vizzes['boolean_embedding'] = viz_boolean_embedding()
    print("  ✓ Boolean embedding")

    vizzes['normal_form_growth'] = viz_normal_form_growth()
    print("  ✓ Normal form growth")

    vizzes['duality'] = viz_duality()
    print("  ✓ Min-max duality")

    # Save to JSON
    with open('viz_data.json', 'w') as f:
        json.dump(vizzes, f)

    print(f"\nAll {len(vizzes)} visualizations generated and saved to viz_data.json")
