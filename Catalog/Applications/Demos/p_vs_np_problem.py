#!/usr/bin/env python3
"""
Circuit Complexity Barriers — Interactive Demonstration

This script demonstrates the key mathematical results formalized
in our Lean 4 development:

1. Shannon's counting argument for circuit lower bounds
2. Parity function sensitivity analysis
3. Complexity barrier composition
4. Monotone circuit order preservation
5. Pigeonhole principle CNF unsatisfiability
"""

from algorithms import (
    parity, flip_bit, sensitivity_at, max_sensitivity, avg_sensitivity,
    shannon_lower_bound, circuit_count_upper_bound, count_boolean_functions,
    enumerate_inputs, truth_table,
    ComplexityBarrier, create_relativization_barrier,
    create_natural_proofs_barrier, create_algebrization_barrier,
    BoolCircuit, pigeonhole_cnf, is_satisfiable
)


def demo_shannon_counting():
    """Demonstrate Shannon's counting argument."""
    print("=" * 70)
    print("DEMO 1: Shannon's Counting Argument")
    print("=" * 70)
    print()
    print("Shannon (1949) showed that most Boolean functions require")
    print("exponentially large circuits, by a counting argument.")
    print()
    print(f"{'n':>4} | {'# Functions':>15} | {'Shannon LB':>12} | {'Circuit UB (s=LB)':>18}")
    print("-" * 60)
    for n in range(2, 9):
        num_fn = count_boolean_functions(n)
        lb = shannon_lower_bound(n)
        s = int(lb)
        ub = circuit_count_upper_bound(n, s) if s < 50 else float('inf')
        num_fn_str = f"{num_fn}" if num_fn < 10**15 else f"2^{2**n}"
        ub_str = f"{ub}" if ub < 10**15 else ">10^15"
        print(f"{n:>4} | {num_fn_str:>15} | {lb:>12.1f} | {ub_str:>18}")
    print()
    print("The lower bound grows as 2^n/(2n), confirming that most functions")
    print("require circuits of nearly maximum size.")
    print()


def demo_parity_sensitivity():
    """Demonstrate parity function sensitivity."""
    print("=" * 70)
    print("DEMO 2: Parity Function — Maximum Sensitivity")
    print("=" * 70)
    print()
    print("The parity function has sensitivity exactly n at EVERY input.")
    print("This is our theorem parity_sensitivity, proved by showing that")
    print("flipping ANY bit changes the output (theorem parity_flip).")
    print()
    for n in range(1, 7):
        ms = max_sensitivity(parity, n)
        avgs = avg_sensitivity(parity, n)
        print(f"n = {n}: max_sensitivity = {ms}, avg_sensitivity = {avgs:.2f}")

    print()
    print("Verification of parity_flip theorem:")
    n = 4
    x = (True, False, True, False)
    print(f"  x = {x}, parity(x) = {parity(x)}")
    for i in range(n):
        x_flip = flip_bit(x, i)
        print(f"  flip bit {i}: {x_flip}, parity = {parity(x_flip)} "
              f"({'≠' if parity(x) != parity(x_flip) else '='} original)")
    print()


def demo_barrier_composition():
    """Demonstrate complexity barrier composition."""
    print("=" * 70)
    print("DEMO 3: Complexity Barrier Algebra")
    print("=" * 70)
    print()
    print("Each barrier has a 'ceiling' — the maximum lower bound provable")
    print("by techniques in its scope. Composition takes the max of ceilings.")
    print()

    b_rel = create_relativization_barrier()
    b_nat = create_natural_proofs_barrier()
    b_alg = create_algebrization_barrier()

    barriers = [b_rel, b_nat, b_alg]
    target = 10  # represents superpolynomial

    for b in barriers:
        status = "BLOCKS" if b.blocks(target) else "does not block"
        tight = "tight" if b.is_tight() else "not tight"
        print(f"  {b.name:20s}: ceiling = {b.ceiling}, {status} target {target}, {tight}")

    print()

    # Compose all three
    composed_12 = ComplexityBarrier.compose(b_rel, b_nat)
    composed_all = ComplexityBarrier.compose(composed_12, b_alg)

    print(f"Composed barrier ceiling: {composed_all.ceiling}")
    print(f"Composed barrier blocks target {target}: {composed_all.blocks(target)}")
    print(f"Number of composed techniques: {len(composed_all.technique_strengths)}")

    # Verify commutativity
    composed_21 = ComplexityBarrier.compose(b_nat, b_rel)
    print(f"\nCommutativity check:")
    print(f"  ceiling(Rel + Nat) = {composed_12.ceiling}")
    print(f"  ceiling(Nat + Rel) = {composed_21.ceiling}")
    print(f"  Equal: {composed_12.ceiling == composed_21.ceiling} ✓")
    print()


def demo_monotone_circuits():
    """Demonstrate monotone circuit order preservation."""
    print("=" * 70)
    print("DEMO 4: Monotone Circuit Order Preservation")
    print("=" * 70)
    print()
    print("Theorem: If C is monotone and x ≤ y pointwise,")
    print("then C(x) = True implies C(y) = True.")
    print()

    # Build a monotone circuit: (x₀ AND x₁) OR x₂
    x0 = BoolCircuit('INPUT', inputs=0)
    x1 = BoolCircuit('INPUT', inputs=1)
    x2 = BoolCircuit('INPUT', inputs=2)
    c_and = BoolCircuit('AND', children=[x0, x1])
    c_or = BoolCircuit('OR', children=[c_and, x2])

    print(f"Circuit: (x₀ AND x₁) OR x₂")
    print(f"Size: {c_or.size}, Depth: {c_or.depth}, Monotone: {c_or.is_monotone}")
    print()

    # Test order preservation
    print(f"{'x':>15} | {'C(x)':>5} | {'y ≥ x':>15} | {'C(y)':>5} | {'Preserved':>10}")
    print("-" * 65)

    inputs = enumerate_inputs(3)
    violations = 0
    for x in inputs:
        if not c_or.eval(x):
            continue
        for y in inputs:
            if all(x[i] <= y[i] for i in range(3)):
                preserved = c_or.eval(y)
                if not preserved:
                    violations += 1
                print(f"{str(x):>15} | {c_or.eval(x)!s:>5} | {str(y):>15} | "
                      f"{c_or.eval(y)!s:>5} | {'✓' if preserved else '✗':>10}")

    print(f"\nViolations: {violations} (expected: 0)")
    print()


def demo_php_unsat():
    """Demonstrate pigeonhole principle unsatisfiability."""
    print("=" * 70)
    print("DEMO 5: Pigeonhole Principle CNF")
    print("=" * 70)
    print()
    print("PHP(n+1, n): n+1 pigeons, n holes — always unsatisfiable.")
    print("This connects to proof complexity: resolution proofs of PHP")
    print("require exponential size (Haken, 1985).")
    print()

    for n in range(2, 6):
        php, num_vars = pigeonhole_cnf(n)
        result = is_satisfiable(php, num_vars)
        num_clauses = len(php)
        status = "UNSAT ✓" if result is None else f"SAT at {result}"
        print(f"  PHP({n+1},{n}): {num_vars} vars, {num_clauses} clauses → {status}")

    print()
    print("The exponential resolution proof size aligns with our")
    print("natural proofs barrier: efficiently checking unsatisfiability")
    print("would violate cryptographic hardness assumptions.")
    print()


def demo_depth_zero_classification():
    """Demonstrate depth-0 circuit classification."""
    print("=" * 70)
    print("DEMO 6: Depth-0 Circuit Classification")
    print("=" * 70)
    print()
    print("Theorem: Depth-0 circuits compute only constant functions")
    print("or projections x_i. This is proved by case analysis.")
    print()

    n = 3
    # All depth-0 circuits on 3 variables
    depth0_circuits = []

    # Constants
    depth0_circuits.append(("True", BoolCircuit('TRUE')))
    depth0_circuits.append(("False", BoolCircuit('FALSE')))

    # Projections
    for i in range(n):
        depth0_circuits.append((f"x_{i}", BoolCircuit('INPUT', inputs=i)))

    print(f"All depth-0 circuits on {n} variables:")
    for name, c in depth0_circuits:
        tt = tuple(c.eval(x) for x in enumerate_inputs(n))
        print(f"  {name:>8}: truth table = {tt}, depth = {c.depth}")

    print(f"\nTotal depth-0 functions: {len(depth0_circuits)} (= n + 2 = {n + 2})")
    print(f"Total Boolean functions on {n} vars: {count_boolean_functions(n)}")
    print(f"Fraction computable at depth 0: {len(depth0_circuits)}/{count_boolean_functions(n)}")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     CIRCUIT COMPLEXITY BARRIERS — DEMONSTRATION                     ║")
    print("║     Formalized P vs NP Barrier Theory                               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_shannon_counting()
    demo_parity_sensitivity()
    demo_barrier_composition()
    demo_monotone_circuits()
    demo_php_unsat()
    demo_depth_zero_classification()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
