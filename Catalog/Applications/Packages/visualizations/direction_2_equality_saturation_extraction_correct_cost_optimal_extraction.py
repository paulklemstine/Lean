#!/usr/bin/env python3
"""
Equality Saturation Extraction: Real-World Applications

Demonstrates the theorems applied to concrete optimization domains:
1. Arithmetic Expression Optimization (compiler optimization)
2. Boolean Circuit Minimization (hardware synthesis)
3. Matrix Expression Optimization (scientific computing)
4. Cost-Pareto Analysis (multi-objective optimization)
"""

from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from algorithms import (
    Term, RewriteRule, UnionFindEGraph, CostModel,
    bounded_saturation, extract_cheapest, compute_normal_form,
    verify_extraction_semantics, verified_extraction_pipeline
)
import itertools


# ============================================================================
# Application 1: Arithmetic Expression Optimization
# ============================================================================

def arithmetic_optimization():
    """
    Demonstrates equality saturation for arithmetic expression optimization.

    This is the canonical application: a compiler wants to find the cheapest
    equivalent arithmetic expression. By Theorem 2, the extracted expression
    is both semantically equivalent and cost-optimal within the saturated
    equivalence class.
    """
    print("=" * 70)
    print("APPLICATION 1: Arithmetic Expression Optimization")
    print("=" * 70)
    print()

    x, y, z = Term("?x"), Term("?y"), Term("?z")

    # Algebraic rules (convergent for the identity/zero rules)
    rules = [
        # Identities
        RewriteRule(Term("add", (x, Term("0"))), x),
        RewriteRule(Term("mul", (x, Term("1"))), x),
        RewriteRule(Term("mul", (x, Term("0"))), Term("0")),
        # Commutativity
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),
        RewriteRule(Term("mul", (x, y)), Term("mul", (y, x))),
    ]

    # Test expressions of increasing complexity
    a, b, c = Term("a"), Term("b"), Term("c")
    expressions = [
        ("x+0",        Term("add", (a, Term("0")))),
        ("x*1",        Term("mul", (a, Term("1")))),
        ("(x+0)*1",    Term("mul", (Term("add", (a, Term("0"))), Term("1")))),
        ("x*0 + y*1",  Term("add", (Term("mul", (a, Term("0"))),
                                     Term("mul", (b, Term("1")))))),
        ("(x+0)*(y*1)+0", Term("add", (
            Term("mul", (Term("add", (a, Term("0"))),
                         Term("mul", (b, Term("1"))))),
            Term("0")))),
    ]

    print(f"{'Expression':<20} {'Original':>8} {'Extracted':>10} {'NF':>8} {'Saved':>6}")
    print("-" * 60)

    for name, expr in expressions:
        result = verified_extraction_pipeline(expr, rules, max_saturation_depth=10)
        nf, _ = compute_normal_form(expr, rules)

        print(f"{name:<20} {result.original_cost:>8} {result.extracted_cost:>10} "
              f"{nf.size():>8} {result.cost_reduction:>5.0%}")

    print()
    print("By Theorem 1: All extracted expressions preserve semantics.")
    print("By Theorem 2: Extracted cost ≤ cost of any equivalent expression.")
    print("By Theorem 3: Extracted and normal form have same denotation.")
    print()


# ============================================================================
# Application 2: Boolean Circuit Minimization
# ============================================================================

def boolean_circuit_minimization():
    """
    Demonstrates equality saturation for Boolean circuit optimization.

    Models Boolean gates as terms and applies algebraic identities
    to minimize gate count.
    """
    print("=" * 70)
    print("APPLICATION 2: Boolean Circuit Minimization")
    print("=" * 70)
    print()

    x, y = Term("?x"), Term("?y")

    rules = [
        # Identity
        RewriteRule(Term("and", (x, Term("T"))), x),
        RewriteRule(Term("or", (x, Term("F"))), x),
        # Annihilation
        RewriteRule(Term("and", (x, Term("F"))), Term("F")),
        RewriteRule(Term("or", (x, Term("T"))), Term("T")),
        # Idempotence
        RewriteRule(Term("and", (x, x)), x),
        RewriteRule(Term("or", (x, x)), x),
        # Commutativity
        RewriteRule(Term("and", (x, y)), Term("and", (y, x))),
        RewriteRule(Term("or", (x, y)), Term("or", (y, x))),
    ]

    a, b = Term("a"), Term("b")
    circuits = [
        ("a AND T",           Term("and", (a, Term("T")))),
        ("a OR F",            Term("or", (a, Term("F")))),
        ("a AND F",           Term("and", (a, Term("F")))),
        ("(a AND T) OR F",    Term("or", (Term("and", (a, Term("T"))), Term("F")))),
        ("(a OR a) AND T",    Term("and", (Term("or", (a, a)), Term("T")))),
        ("(a AND b) OR (b AND a)",
            Term("or", (Term("and", (a, b)), Term("and", (b, a))))),
    ]

    # Gate cost model: each gate costs 1, constants cost 0
    def gate_cost(t: Term) -> int:
        if t.symbol in ("T", "F", "a", "b", "c"):
            return 0
        return 1 + sum(gate_cost(c) for c in t.children)

    cost_model = CostModel(gate_cost)

    print(f"{'Circuit':<30} {'Gates':>5} {'Optimized':>10} {'Gates':>5}")
    print("-" * 55)

    for name, circuit in circuits:
        result = verified_extraction_pipeline(
            circuit, rules, cost_model=cost_model, max_saturation_depth=10
        )
        orig_gates = gate_cost(circuit)
        opt_gates = gate_cost(result.extracted)
        print(f"{name:<30} {orig_gates:>5} {'→ ' + repr(result.extracted):>10} {opt_gates:>5}")

    print()
    print("Cost model: number of logic gates (constants are free)")
    print("By Theorem 2: extracted circuit has minimum gate count in its e-class.")
    print()


# ============================================================================
# Application 3: Symbolic Expression Simplification
# ============================================================================

def symbolic_simplification():
    """
    Demonstrates equality saturation for symbolic mathematics.

    Shows how equality saturation can find simplifications that
    normalization-based systems miss.
    """
    print("=" * 70)
    print("APPLICATION 3: Symbolic Expression Simplification")
    print("=" * 70)
    print()

    x, y, z = Term("?x"), Term("?y"), Term("?z")

    rules = [
        # Additive identity
        RewriteRule(Term("add", (x, Term("0"))), x),
        # Multiplicative identity
        RewriteRule(Term("mul", (x, Term("1"))), x),
        # Multiplicative zero
        RewriteRule(Term("mul", (x, Term("0"))), Term("0")),
        # Commutativity
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),
        RewriteRule(Term("mul", (x, y)), Term("mul", (y, x))),
        # Double negation
        RewriteRule(Term("neg", (Term("neg", (x,)),)), x),
        # Additive inverse
        RewriteRule(Term("add", (x, Term("neg", (x,)))), Term("0")),
    ]

    a, b = Term("a"), Term("b")
    expressions = [
        ("--a",         Term("neg", (Term("neg", (a,)),))),
        ("a + (-a)",    Term("add", (a, Term("neg", (a,))))),
        ("a*1 + 0",     Term("add", (Term("mul", (a, Term("1"))), Term("0")))),
        ("-(-a) * 1",   Term("mul", (Term("neg", (Term("neg", (a,)),)), Term("1")))),
        ("(a+(-a))*b",  Term("mul", (Term("add", (a, Term("neg", (a,)))), b))),
    ]

    print(f"{'Expression':<20} {'Size':>5} {'Simplified':>15} {'Size':>5}")
    print("-" * 50)

    for name, expr in expressions:
        result = verified_extraction_pipeline(expr, rules, max_saturation_depth=15)
        print(f"{name:<20} {expr.size():>5} {'→ ' + repr(result.extracted):>15} "
              f"{result.extracted.size():>5}")

    print()
    print("Key insight: equality saturation explores ALL equivalent forms,")
    print("then selects the smallest. This finds simplifications that")
    print("fixed-strategy normalizers may miss.")
    print()


# ============================================================================
# Application 4: Cost-Pareto Analysis
# ============================================================================

def cost_pareto_analysis():
    """
    Analyzes the Pareto frontier of cost vs. different metrics
    within equivalence classes.

    Shows that different cost models lead to different optimal
    extractions from the same equivalence class.
    """
    print("=" * 70)
    print("APPLICATION 4: Multi-Objective Cost Analysis")
    print("=" * 70)
    print()

    x, y = Term("?x"), Term("?y")

    rules = [
        RewriteRule(Term("add", (x, Term("0"))), x),
        RewriteRule(Term("mul", (x, Term("1"))), x),
        RewriteRule(Term("add", (x, y)), Term("add", (y, x))),
        RewriteRule(Term("mul", (x, y)), Term("mul", (y, x))),
    ]

    a, b = Term("a"), Term("b")
    expr = Term("add", (Term("mul", (a, Term("1"))), Term("add", (b, Term("0")))))

    # Build saturated e-graph
    egraph = UnionFindEGraph()
    egraph.add(expr)
    result = bounded_saturation(egraph, rules, max_depth=10)

    eclass = egraph.get_class(expr)
    print(f"Expression: {expr}")
    print(f"E-class has {len(eclass)} members after saturation")
    print()

    # Define multiple cost models
    cost_models = {
        "Size (nodes)": CostModel(lambda t: t.size()),
        "Depth": CostModel(lambda t: t.depth()),
        "Multiplications": CostModel(
            lambda t: (1 if t.symbol == "mul" else 0) +
                      sum((1 if c.symbol == "mul" else 0) for c in t.children)
        ),
    }

    print(f"{'Member':<30} ", end="")
    for name in cost_models:
        print(f"{name:>15}", end="")
    print()
    print("-" * (30 + 15 * len(cost_models)))

    for member in sorted(eclass, key=lambda t: t.size()):
        print(f"{repr(member):<30} ", end="")
        for cm in cost_models.values():
            print(f"{cm.cost(member):>15}", end="")
        print()

    print()
    print("Optimal extractions by cost model:")
    for name, cm in cost_models.items():
        best = extract_cheapest(egraph, expr, cm)
        print(f"  {name}: {best} (cost={cm.cost(best)})")

    print()
    print("By Theorem 2: each extraction is optimal for its cost model.")
    print("By Theorem 1: ALL extractions preserve semantics.")
    print()


# ============================================================================
# Main
# ============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  EQUALITY SATURATION — REAL-WORLD APPLICATIONS                     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    arithmetic_optimization()
    boolean_circuit_minimization()
    symbolic_simplification()
    cost_pareto_analysis()

    print("=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()
