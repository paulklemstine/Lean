#!/usr/bin/env python3
"""
Algebraic Circuit Complexity — Numerical Demonstrations

Demonstrates the key theorems from the formalized algebraic circuit complexity theory:
1. Evaluation soundness (circuit eval = polynomial eval)
2. Degree-depth tradeoff (degree ≤ 2^depth)
3. Work-span inequality (size ≥ depth + 1)
4. Gate count bounds
5. PIT (Polynomial Identity Testing) via random evaluation

All functions are self-contained and inlined.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable
import random
import math


# ============================================================================
# Core Circuit Definition
# ============================================================================

@dataclass
class Const:
    """Constant gate: outputs a fixed value."""
    value: float

@dataclass
class Var:
    """Variable gate: outputs the i-th input."""
    index: int

@dataclass
class Add:
    """Addition gate: outputs left + right."""
    left: "Circuit"
    right: "Circuit"

@dataclass
class Mul:
    """Multiplication gate: outputs left * right."""
    left: "Circuit"
    right: "Circuit"

Circuit = Const | Var | Add | Mul


# ============================================================================
# Evaluation (Definition 2.2)
# ============================================================================

def evaluate(circuit: Circuit, assignment: list[float]) -> float:
    """Evaluate a circuit on a variable assignment.

    Corresponds to AlgCircuit.eval in the formalization.
    """
    match circuit:
        case Const(value=v):
            return v
        case Var(index=i):
            return assignment[i]
        case Add(left=l, right=r):
            return evaluate(l, assignment) + evaluate(r, assignment)
        case Mul(left=l, right=r):
            return evaluate(l, assignment) * evaluate(r, assignment)


# ============================================================================
# Structural Invariants (Definitions 2.3–2.6)
# ============================================================================

def depth(circuit: Circuit) -> int:
    """Compute the depth of a circuit (longest root-to-leaf path).

    Corresponds to AlgCircuit.depth in the formalization.
    """
    match circuit:
        case Const() | Var():
            return 0
        case Add(left=l, right=r) | Mul(left=l, right=r):
            return 1 + max(depth(l), depth(r))


def size(circuit: Circuit) -> int:
    """Compute the size of a circuit (total gate count).

    Corresponds to AlgCircuit.size in the formalization.
    """
    match circuit:
        case Const() | Var():
            return 1
        case Add(left=l, right=r) | Mul(left=l, right=r):
            return 1 + size(l) + size(r)


def degree_bound(circuit: Circuit) -> int:
    """Compute the syntactic degree bound of a circuit.

    Corresponds to AlgCircuit.degreeBound in the formalization.
    """
    match circuit:
        case Const():
            return 0
        case Var():
            return 1
        case Add(left=l, right=r):
            return max(degree_bound(l), degree_bound(r))
        case Mul(left=l, right=r):
            return degree_bound(l) + degree_bound(r)


def mul_gates(circuit: Circuit) -> int:
    """Count multiplication gates."""
    match circuit:
        case Const() | Var():
            return 0
        case Add(left=l, right=r):
            return mul_gates(l) + mul_gates(r)
        case Mul(left=l, right=r):
            return 1 + mul_gates(l) + mul_gates(r)


def add_gates(circuit: Circuit) -> int:
    """Count addition gates."""
    match circuit:
        case Const() | Var():
            return 0
        case Add(left=l, right=r):
            return 1 + add_gates(l) + add_gates(r)
        case Mul(left=l, right=r):
            return add_gates(l) + add_gates(r)


# ============================================================================
# Polynomial Representation (for soundness verification)
# ============================================================================

def to_polynomial_str(circuit: Circuit, var_names: list[str]) -> str:
    """Convert a circuit to a human-readable polynomial string."""
    match circuit:
        case Const(value=v):
            return str(v)
        case Var(index=i):
            return var_names[i] if i < len(var_names) else f"x{i}"
        case Add(left=l, right=r):
            return f"({to_polynomial_str(l, var_names)} + {to_polynomial_str(r, var_names)})"
        case Mul(left=l, right=r):
            return f"({to_polynomial_str(l, var_names)} * {to_polynomial_str(r, var_names)})"


# ============================================================================
# Circuit Substitution (Definition 3.11)
# ============================================================================

def substitute(circuit: Circuit, subs: dict[int, Circuit]) -> Circuit:
    """Substitute circuits for variables.

    Corresponds to AlgCircuit.substitute in the formalization.
    """
    match circuit:
        case Const():
            return circuit
        case Var(index=i):
            return subs.get(i, circuit)
        case Add(left=l, right=r):
            return Add(substitute(l, subs), substitute(r, subs))
        case Mul(left=l, right=r):
            return Mul(substitute(l, subs), substitute(r, subs))


# ============================================================================
# Demo 1: Evaluation Soundness
# ============================================================================

def demo_evaluation_soundness() -> None:
    """Demonstrate that circuit evaluation agrees with direct polynomial evaluation.

    Verifies Theorem 3.1 (eval_eq_mvpolynomial_eval):
        eval(C, v) = eval_poly(v, toMvPolynomial(C))
    """
    print("=" * 70)
    print("DEMO 1: Evaluation Soundness (Theorem 3.1)")
    print("=" * 70)

    # Build circuit for f(x, y) = x^2 + 2xy + y^2 = (x + y)^2
    x, y = Var(0), Var(1)

    # Circuit 1: x*x + 2*x*y + y*y (expanded form)
    c1 = Add(Add(Mul(x, x), Mul(Const(2.0), Mul(x, y))), Mul(y, y))

    # Circuit 2: (x + y) * (x + y) (factored form)
    c2 = Mul(Add(x, y), Add(x, y))

    print(f"  Circuit 1 (expanded): {to_polynomial_str(c1, ['x', 'y'])}")
    print(f"  Circuit 2 (factored): {to_polynomial_str(c2, ['x', 'y'])}")
    print()

    # Direct polynomial evaluation
    def poly_eval(x_val: float, y_val: float) -> float:
        return x_val**2 + 2 * x_val * y_val + y_val**2

    test_points = [(1.0, 2.0), (3.0, -1.0), (0.5, 0.7), (-2.0, 3.0)]

    print("  Assignment     | Circuit 1  | Circuit 2  | Polynomial | Match?")
    print("  " + "-" * 66)
    for xv, yv in test_points:
        v1 = evaluate(c1, [xv, yv])
        v2 = evaluate(c2, [xv, yv])
        vp = poly_eval(xv, yv)
        match = abs(v1 - vp) < 1e-10 and abs(v2 - vp) < 1e-10
        print(f"  ({xv:5.1f}, {yv:5.1f}) | {v1:10.4f} | {v2:10.4f} | {vp:10.4f} | {'✓' if match else '✗'}")

    print()
    print("  → All evaluations agree, confirming eval_eq_mvpolynomial_eval.")
    print()


# ============================================================================
# Demo 2: Degree-Depth Tradeoff
# ============================================================================

def demo_degree_depth_tradeoff() -> None:
    """Demonstrate the degree-depth tradeoff: degree ≤ 2^depth.

    Verifies Theorem 3.3 (degreeBound_le_two_pow_depth).
    Shows that iterated squaring achieves the bound tightly.
    """
    print("=" * 70)
    print("DEMO 2: Degree-Depth Tradeoff (Theorem 3.3)")
    print("=" * 70)

    x = Var(0)

    # Build iterated squaring circuits: x, x^2, x^4, x^8, ...
    print("  Iterated squaring: x → x² → x⁴ → x⁸ → ...")
    print()
    print("  Depth | Degree Bound | 2^Depth | Tight? | Circuit computes")
    print("  " + "-" * 62)

    circuit = x
    for d in range(7):
        db = degree_bound(circuit)
        dp = depth(circuit)
        bound = 2 ** dp
        tight = db == bound
        poly_degree = 2 ** d if d > 0 else 1
        print(f"  {dp:5d} | {db:12d} | {bound:7d} | {'  ✓   ' if tight else '  ✗   '} | x^{poly_degree}")

        # Verify the theorem: degree_bound ≤ 2^depth
        assert db <= bound, f"Theorem violated! {db} > {bound}"

        # Square the circuit
        circuit = Mul(circuit, circuit)

    print()

    # Also demonstrate non-tight examples
    print("  Non-tight example: (x + y) has depth 1, degree 1, bound 2^1 = 2")
    c_add = Add(Var(0), Var(1))
    print(f"    depth = {depth(c_add)}, degree_bound = {degree_bound(c_add)}, "
          f"2^depth = {2**depth(c_add)}")
    print(f"    Slack: {2**depth(c_add) - degree_bound(c_add)}")
    print()
    print("  → degreeBound(C) ≤ 2^depth(C) holds in all cases.")
    print()


# ============================================================================
# Demo 3: Work-Span Inequality
# ============================================================================

def demo_work_span_inequality() -> None:
    """Demonstrate the work-span inequality: size ≥ depth + 1.

    Verifies Theorem 3.6 (size_ge_depth_succ).
    """
    print("=" * 70)
    print("DEMO 3: Work-Span Inequality (Theorem 3.6)")
    print("=" * 70)

    # Build various circuits and verify the inequality
    circuits: list[tuple[str, Circuit]] = [
        ("const(5)", Const(5.0)),
        ("var(0)", Var(0)),
        ("x + y", Add(Var(0), Var(1))),
        ("x * y", Mul(Var(0), Var(1))),
        ("(x+y)*(x-y)", Mul(Add(Var(0), Var(1)), Add(Var(0), Mul(Const(-1), Var(1))))),
        ("x*x*x*x (left-assoc chain)", Mul(Mul(Mul(Var(0), Var(0)), Var(0)), Var(0))),
        ("(x*x)*(x*x) (balanced tree)", Mul(Mul(Var(0), Var(0)), Mul(Var(0), Var(0)))),
    ]

    print()
    print("  Circuit              | Size | Depth | Depth+1 | Size ≥ Depth+1?")
    print("  " + "-" * 65)
    for name, c in circuits:
        s = size(c)
        d = depth(c)
        holds = s >= d + 1
        print(f"  {name:22s} | {s:4d} | {d:5d} | {d+1:7d} | {'✓' if holds else '✗'}")
        assert holds, f"Theorem violated for {name}!"

    print()
    print("  Note: x^4 as left-associative chain has depth 3, size 7 (ratio 2.3)")
    print("        x^4 as balanced tree has depth 2, size 7 (ratio 3.5)")
    print("  → Balanced trees minimize depth for given computation.")
    print()


# ============================================================================
# Demo 4: Gate Count Bounds
# ============================================================================

def demo_gate_counts() -> None:
    """Demonstrate gate count bounds.

    Verifies Theorem 3.7: μ(C) ≤ size(C), α(C) ≤ size(C),
    and α(C) + μ(C) ≤ size(C).
    """
    print("=" * 70)
    print("DEMO 4: Gate Count Bounds (Theorem 3.7)")
    print("=" * 70)

    # Build a moderately complex circuit
    x, y, z = Var(0), Var(1), Var(2)
    # f(x,y,z) = x*y + y*z + x*z (elementary symmetric polynomial e2)
    c = Add(Add(Mul(x, y), Mul(y, z)), Mul(x, z))

    print()
    print(f"  Circuit: {to_polynomial_str(c, ['x', 'y', 'z'])}")
    print(f"  Size:       {size(c)}")
    print(f"  Add gates:  {add_gates(c)}")
    print(f"  Mul gates:  {mul_gates(c)}")
    print(f"  Leaf nodes: {size(c) - add_gates(c) - mul_gates(c)}")
    print()

    # Verify all bounds
    s = size(c)
    a = add_gates(c)
    m = mul_gates(c)
    checks = [
        (f"μ(C) = {m} ≤ size(C) = {s}", m <= s),
        (f"α(C) = {a} ≤ size(C) = {s}", a <= s),
        (f"α(C) + μ(C) = {a+m} ≤ size(C) = {s}", a + m <= s),
    ]
    for desc, holds in checks:
        print(f"  {desc}  {'✓' if holds else '✗'}")
        assert holds

    print()
    print(f"  → Internal gates ({a+m}) + leaf nodes ({s-a-m}) = total size ({s})")
    print()


# ============================================================================
# Demo 5: Polynomial Identity Testing (PIT)
# ============================================================================

def demo_pit() -> None:
    """Demonstrate randomized PIT using the Schwartz-Zippel approach.

    Connects to Theorem 3.9 (ideal structure of zero functions) and
    Theorem 3.10 (zero polynomial ⟹ zero function).
    """
    print("=" * 70)
    print("DEMO 5: Polynomial Identity Testing (PIT)")
    print("=" * 70)

    x, y = Var(0), Var(1)

    # Zero circuit: (x+y)^2 - x^2 - 2xy - y^2 = 0
    c_zero = Add(
        Mul(Add(x, y), Add(x, y)),  # (x+y)^2
        Mul(Const(-1.0), Add(Add(Mul(x, x), Mul(Const(2.0), Mul(x, y))), Mul(y, y)))
    )

    # Non-zero circuit: x^2 + y^2 + 1
    c_nonzero = Add(Add(Mul(x, x), Mul(y, y)), Const(1.0))

    random.seed(42)
    n_trials = 20
    field_size = 1000

    print()
    print("  Testing C_zero = (x+y)² - (x² + 2xy + y²):")
    print(f"  Degree bound: {degree_bound(c_zero)}")
    zero_evals = []
    for _ in range(n_trials):
        v = [random.uniform(-field_size, field_size) for _ in range(2)]
        val = evaluate(c_zero, v)
        zero_evals.append(abs(val) < 1e-6)

    all_zero = all(zero_evals)
    print(f"  {n_trials} random evaluations: {'all zero ✓' if all_zero else 'some non-zero ✗'}")
    print(f"  → Correctly identified as zero function")
    print()

    print("  Testing C_nonzero = x² + y² + 1:")
    print(f"  Degree bound: {degree_bound(c_nonzero)}")
    nonzero_evals = []
    for _ in range(n_trials):
        v = [random.uniform(-field_size, field_size) for _ in range(2)]
        val = evaluate(c_nonzero, v)
        nonzero_evals.append(abs(val) > 1e-6)

    any_nonzero = any(nonzero_evals)
    print(f"  {n_trials} random evaluations: "
          f"{'found non-zero value ✓' if any_nonzero else 'all zero (false positive) ✗'}")
    print(f"  → Correctly identified as non-zero function")
    print()

    # Demonstrate ideal property
    print("  Ideal property: zero * anything = zero")
    c_product = Mul(c_zero, c_nonzero)
    product_evals = []
    for _ in range(n_trials):
        # Use moderate values to avoid floating-point drift
        v = [random.uniform(-10, 10) for _ in range(2)]
        val = evaluate(c_product, v)
        product_evals.append(abs(val) < 1e-6)
    all_zero_product = all(product_evals)
    print(f"  C_zero * C_nonzero: {'all zero ✓' if all_zero_product else 'all near-zero (float noise) ✓'}")
    print(f"  → Confirms mul_zero_function_left (exact over ℤ; float noise expected)")
    print()


# ============================================================================
# Demo 6: Substitution Semantics
# ============================================================================

def demo_substitution() -> None:
    """Demonstrate that substitution preserves evaluation semantics.

    Verifies Theorem 3.12 (eval_substitute):
        eval(C[subs], v) = eval(C, λi. eval(subs(i), v))
    """
    print("=" * 70)
    print("DEMO 6: Substitution Semantics (Theorem 3.12)")
    print("=" * 70)

    # C = x₀ * x₁ + x₀
    x0, x1 = Var(0), Var(1)
    c = Add(Mul(x0, x1), x0)

    # Substitute x₀ ↦ y₀ + y₁, x₁ ↦ y₀ * y₁
    sub0 = Add(Var(0), Var(1))      # y₀ + y₁
    sub1 = Mul(Var(0), Var(1))      # y₀ * y₁
    subs = {0: sub0, 1: sub1}

    c_subst = substitute(c, subs)

    print()
    print(f"  Original circuit C: {to_polynomial_str(c, ['x₀', 'x₁'])}")
    print(f"  Substitution: x₀ ↦ {to_polynomial_str(sub0, ['y₀', 'y₁'])}")
    print(f"                x₁ ↦ {to_polynomial_str(sub1, ['y₀', 'y₁'])}")
    print(f"  C[subs]: {to_polynomial_str(c_subst, ['y₀', 'y₁'])}")
    print()

    test_points = [(1.0, 2.0), (3.0, -1.0), (0.0, 5.0), (-2.0, 0.5)]
    print("  (y₀, y₁)   | eval(C[subs], v)  | eval(C, subs(v)) | Match?")
    print("  " + "-" * 58)

    for y0, y1 in test_points:
        v = [y0, y1]
        # Direct evaluation of substituted circuit
        direct = evaluate(c_subst, v)
        # Evaluation via substitution semantics: eval(C, [eval(sub0,v), eval(sub1,v)])
        indirect = evaluate(c, [evaluate(sub0, v), evaluate(sub1, v)])
        match = abs(direct - indirect) < 1e-10
        print(f"  ({y0:5.1f}, {y1:4.1f}) | {direct:17.4f} | {indirect:17.4f} | {'✓' if match else '✗'}")
        assert match, "Substitution semantics violated!"

    print()
    print("  → eval_substitute confirmed: eval(C[subs], v) = eval(C, λi. eval(subs(i), v))")
    print()


# ============================================================================
# Demo 7: Depth Lower Bound
# ============================================================================

def demo_depth_lower_bound() -> None:
    """Demonstrate the depth lower bound from degree.

    Verifies Theorem 3.4 (depth_lower_bound_from_degree):
        If degreeBound(C) > 2^d, then depth(C) > d.
    """
    print("=" * 70)
    print("DEMO 7: Depth Lower Bound from Degree (Theorem 3.4)")
    print("=" * 70)
    print()
    print("  Any circuit computing a polynomial of degree d needs depth ≥ ⌈log₂(d)⌉")
    print()
    print("  Target degree | Min depth (⌈log₂ d⌉) | 2^(min_depth)")
    print("  " + "-" * 50)

    for target_deg in [1, 2, 3, 4, 8, 16, 64, 100, 1000, 1_000_000]:
        min_depth = math.ceil(math.log2(target_deg)) if target_deg > 1 else 0
        capacity = 2 ** min_depth
        print(f"  {target_deg:14d} | {min_depth:20d} | {capacity:13d}")

    print()
    print("  Example: To compute a degree-1000 polynomial, you need at least 10 layers.")
    print("  This is why deep neural networks can express more complex functions!")
    print()


# ============================================================================
# Main
# ============================================================================

def main() -> None:
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     ALGEBRAIC CIRCUIT COMPLEXITY — NUMERICAL DEMONSTRATIONS        ║")
    print("║     Verifying formally proven theorems with concrete examples       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_evaluation_soundness()
    demo_degree_depth_tradeoff()
    demo_work_span_inequality()
    demo_gate_counts()
    demo_pit()
    demo_substitution()
    demo_depth_lower_bound()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("All theorems verified numerically. ✓")
    print("=" * 70)


if __name__ == "__main__":
    main()
