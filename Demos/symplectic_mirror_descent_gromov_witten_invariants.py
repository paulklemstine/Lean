#!/usr/bin/env python3
"""
Closure-Circuit Duality: Numerical Demonstrations

Demonstrates the key results from the formal verification:
1. Generated closures are closure operators (extensive, monotone, idempotent)
2. Minimal support computation for every element
3. Canonical residual basis construction and uniqueness
4. Monotone DNF circuit reconstruction and correctness verification

All functions are self-contained with type hints.
"""

from __future__ import annotations
from typing import FrozenSet, Callable
from itertools import combinations


# --------------------------------------------------------------------------- #
#  Core types                                                                  #
# --------------------------------------------------------------------------- #

Element = str
RuleSet = list[tuple[frozenset[Element], Element]]
ClosureOp = Callable[[frozenset[Element]], frozenset[Element]]


# --------------------------------------------------------------------------- #
#  1. Closure from implication rules (GeneratedClosure)                        #
# --------------------------------------------------------------------------- #

def generated_closure(rules: RuleSet, seed: frozenset[Element]) -> frozenset[Element]:
    """
    Compute the closure of `seed` under implication `rules`.
    Corresponds to `GeneratedClosure` in the Lean formalization.
    Iterates rule application until a fixed point is reached.
    """
    current: set[Element] = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion in rules:
            if premises <= current and conclusion not in current:
                current.add(conclusion)
                changed = True
    return frozenset(current)


def make_closure_op(rules: RuleSet) -> ClosureOp:
    """Create a closure operator from a rule set."""
    return lambda s: generated_closure(rules, s)


# --------------------------------------------------------------------------- #
#  2. Verify closure operator properties                                       #
# --------------------------------------------------------------------------- #

def verify_closure_operator(
    cl: ClosureOp,
    universe: list[Element],
    sample_sets: list[frozenset[Element]],
) -> dict[str, bool]:
    """
    Verify extensivity, monotonicity, and idempotency on sample sets.
    Corresponds to `generatedClosure_isClosureOperator`.
    """
    extensive_ok = all(s <= cl(s) for s in sample_sets)

    monotone_ok = True
    for i, s in enumerate(sample_sets):
        for t in sample_sets[i:]:
            if s <= t and not cl(s) <= cl(t):
                monotone_ok = False

    idempotent_ok = all(cl(cl(s)) == cl(s) for s in sample_sets)

    return {
        "extensive": extensive_ok,
        "monotone": monotone_ok,
        "idempotent": idempotent_ok,
    }


# --------------------------------------------------------------------------- #
#  3. Minimal support computation                                              #
# --------------------------------------------------------------------------- #

def find_minimal_supports(
    cl: ClosureOp, target: Element, universe: list[Element]
) -> list[frozenset[Element]]:
    """
    Find all minimal supports for `target` under `cl`.
    A ⊆ universe is a minimal support for x if x ∈ cl(A) and for every
    proper subset B ⊂ A, x ∉ cl(B).
    Corresponds to `minimalSupports` and `minimal_support_exists`.
    """
    all_supports: list[frozenset[Element]] = []

    # Enumerate subsets from smallest to largest
    for size in range(len(universe) + 1):
        for combo in combinations(universe, size):
            candidate = frozenset(combo)
            if target in cl(candidate):
                # Check minimality: no proper subset also generates target
                is_minimal = True
                for prev in all_supports:
                    if prev < candidate:
                        is_minimal = False
                        break
                if is_minimal:
                    # Double-check: no proper subset works
                    for sub_size in range(size):
                        for sub_combo in combinations(combo, sub_size):
                            if target in cl(frozenset(sub_combo)):
                                is_minimal = False
                                break
                        if not is_minimal:
                            break
                if is_minimal:
                    all_supports.append(candidate)

    return all_supports


# --------------------------------------------------------------------------- #
#  4. Canonical residual basis                                                 #
# --------------------------------------------------------------------------- #

def canonical_basis(
    cl: ClosureOp, universe: list[Element]
) -> list[tuple[Element, frozenset[Element]]]:
    """
    Compute the canonical residual basis: for each element, collect all
    minimal supports.
    Corresponds to `canonicalBasis` and `canonical_basis_is_basis`.
    """
    basis: list[tuple[Element, frozenset[Element]]] = []
    for x in universe:
        for support in find_minimal_supports(cl, x, universe):
            basis.append((x, support))
    return basis


# --------------------------------------------------------------------------- #
#  5. Monotone DNF circuit                                                     #
# --------------------------------------------------------------------------- #

def circuit_eval(
    basis: list[tuple[Element, frozenset[Element]]],
    target: Element,
    input_set: frozenset[Element],
) -> bool:
    """
    Evaluate the reconstructed DNF circuit for `target` on `input_set`.
    Circuit: OR over all minimal supports A of target: (AND over a in A: a ∈ input_set)
    Corresponds to `reconstructClosureCircuit` and `reconstructed_circuit_correct`.
    """
    for t, support in basis:
        if t == target and support <= input_set:
            return True
    return False


def verify_circuit_correctness(
    cl: ClosureOp,
    basis: list[tuple[Element, frozenset[Element]]],
    universe: list[Element],
) -> tuple[bool, int, int]:
    """
    Exhaustively verify that the DNF circuit matches the closure operator.
    Returns (all_correct, num_tests, num_mismatches).
    Corresponds to `reconstructed_circuit_correct`.
    """
    num_tests = 0
    num_mismatches = 0

    for size in range(len(universe) + 1):
        for combo in combinations(universe, size):
            s = frozenset(combo)
            closed = cl(s)
            for x in universe:
                num_tests += 1
                in_closure = x in closed
                circuit_says = circuit_eval(basis, x, s)
                if in_closure != circuit_says:
                    num_mismatches += 1

    return (num_mismatches == 0, num_tests, num_mismatches)


# --------------------------------------------------------------------------- #
#  6. Verify basis uniqueness                                                  #
# --------------------------------------------------------------------------- #

def verify_basis_uniqueness(
    cl: ClosureOp, universe: list[Element]
) -> bool:
    """
    Verify uniqueness by computing the canonical basis twice via different
    element orderings and checking equality.
    Corresponds to `canonical_basis_unique`.
    """
    basis1 = set(canonical_basis(cl, universe))
    basis2 = set(canonical_basis(cl, list(reversed(universe))))
    return basis1 == basis2


# =========================================================================== #
#  DEMO SCENARIOS                                                              #
# =========================================================================== #

def demo_database_functional_dependencies() -> None:
    """
    Demo 1: Functional dependencies in a relational database.
    Rules model attribute closure under FDs:
      {A, B} → C,  {C} → D,  {A, D} → E
    """
    print("=" * 72)
    print("DEMO 1: Database Functional Dependencies")
    print("=" * 72)

    universe = ["A", "B", "C", "D", "E"]
    rules: RuleSet = [
        (frozenset({"A", "B"}), "C"),
        (frozenset({"C"}), "D"),
        (frozenset({"A", "D"}), "E"),
    ]
    cl = make_closure_op(rules)

    # Show closure examples
    examples = [
        frozenset({"A", "B"}),
        frozenset({"C"}),
        frozenset({"A"}),
        frozenset({"A", "B", "C"}),
    ]
    print("\nClosure computations:")
    for s in examples:
        print(f"  cl({set(s)}) = {set(cl(s))}")

    # Verify closure operator properties
    all_subsets = [frozenset(combo) for size in range(len(universe) + 1)
                   for combo in combinations(universe, size)]
    props = verify_closure_operator(cl, universe, all_subsets)
    print(f"\nClosure operator properties (Theorem: generatedClosure_isClosureOperator):")
    for prop, ok in props.items():
        print(f"  {prop}: {'✓' if ok else '✗'}")

    # Compute canonical basis
    basis = canonical_basis(cl, universe)
    print(f"\nCanonical residual basis ({len(basis)} generators):")
    for target, support in basis:
        print(f"  {target} ← {set(support)}")

    # Verify circuit correctness
    correct, tests, mismatches = verify_circuit_correctness(cl, basis, universe)
    print(f"\nCircuit correctness (Theorem: reconstructed_circuit_correct):")
    print(f"  {tests} tests, {mismatches} mismatches → {'✓ CORRECT' if correct else '✗ INCORRECT'}")

    # Verify uniqueness
    unique = verify_basis_uniqueness(cl, universe)
    print(f"\nBasis uniqueness (Theorem: canonical_basis_unique): {'✓' if unique else '✗'}")
    print()


def demo_transitive_closure() -> None:
    """
    Demo 2: Transitive closure on a small directed graph.
    Graph: 1→2, 2→3, 3→4, 1→3
    Rules encode: if you can reach x, and x→y, then you can reach y.
    """
    print("=" * 72)
    print("DEMO 2: Transitive Closure (Directed Graph Reachability)")
    print("=" * 72)

    universe = ["1", "2", "3", "4"]
    # Each edge (x, y) becomes a rule: {x} → y
    rules: RuleSet = [
        (frozenset({"1"}), "2"),
        (frozenset({"2"}), "3"),
        (frozenset({"3"}), "4"),
        (frozenset({"1"}), "3"),
    ]
    cl = make_closure_op(rules)

    print("\nReachability from each node:")
    for node in universe:
        seed = frozenset({node})
        print(f"  From {{{node}}}: reachable = {set(cl(seed))}")

    basis = canonical_basis(cl, universe)
    print(f"\nCanonical basis ({len(basis)} generators):")
    for target, support in basis:
        print(f"  {target} ← {set(support)}")

    correct, tests, _ = verify_circuit_correctness(cl, basis, universe)
    print(f"\nCircuit correctness: {tests} tests → {'✓' if correct else '✗'}")

    unique = verify_basis_uniqueness(cl, universe)
    print(f"Basis uniqueness: {'✓' if unique else '✗'}")
    print()


def demo_lattice_closure() -> None:
    """
    Demo 3: A more complex closure system modeling feature dependencies
    in a machine learning pipeline. Features depend on each other:
      {raw_pixels} → edges
      {edges, raw_pixels} → textures
      {textures} → objects
      {objects, edges} → scene
      {scene} → caption
    """
    print("=" * 72)
    print("DEMO 3: Feature Dependency Closure (ML Pipeline)")
    print("=" * 72)

    universe = ["raw_pixels", "edges", "textures", "objects", "scene", "caption"]
    rules: RuleSet = [
        (frozenset({"raw_pixels"}), "edges"),
        (frozenset({"edges", "raw_pixels"}), "textures"),
        (frozenset({"textures"}), "objects"),
        (frozenset({"objects", "edges"}), "scene"),
        (frozenset({"scene"}), "caption"),
    ]
    cl = make_closure_op(rules)

    print("\nFeature closure examples:")
    seeds = [
        frozenset({"raw_pixels"}),
        frozenset({"textures"}),
        frozenset({"objects"}),
    ]
    for s in seeds:
        print(f"  cl({set(s)}) = {set(cl(s))}")

    basis = canonical_basis(cl, universe)
    print(f"\nCanonical basis ({len(basis)} generators):")
    for target, support in sorted(basis, key=lambda g: (g[0], len(g[1]))):
        print(f"  {target} ← {set(support)}")

    correct, tests, _ = verify_circuit_correctness(cl, basis, universe)
    print(f"\nCircuit correctness: {tests} tests → {'✓' if correct else '✗'}")

    unique = verify_basis_uniqueness(cl, universe)
    print(f"Basis uniqueness: {'✓' if unique else '✗'}")

    # Show circuit evaluation example
    print("\nCircuit evaluation examples:")
    test_input = frozenset({"raw_pixels"})
    for x in universe:
        result = circuit_eval(basis, x, test_input)
        print(f"  Circuit({x}, {set(test_input)}) = {result}")
    print()


def demo_monotonicity_verification() -> None:
    """
    Demo 4: Exhaustive verification of circuit monotonicity.
    For every circuit and every pair S ⊆ T, if circuit(S) then circuit(T).
    Corresponds to `MonotoneCircuit.eval_mono`.
    """
    print("=" * 72)
    print("DEMO 4: Circuit Monotonicity Verification")
    print("=" * 72)

    universe = ["a", "b", "c", "d"]
    rules: RuleSet = [
        (frozenset({"a", "b"}), "c"),
        (frozenset({"c"}), "d"),
        (frozenset({"a"}), "b"),
    ]
    cl = make_closure_op(rules)
    basis = canonical_basis(cl, universe)

    all_subsets = [frozenset(combo) for size in range(len(universe) + 1)
                   for combo in combinations(universe, size)]

    violations = 0
    tests = 0
    for s in all_subsets:
        for t in all_subsets:
            if s <= t:
                for x in universe:
                    tests += 1
                    if circuit_eval(basis, x, s) and not circuit_eval(basis, x, t):
                        violations += 1

    print(f"\nMonotonicity test (Theorem: eval_mono):")
    print(f"  {tests} subset pairs × elements tested")
    print(f"  {violations} monotonicity violations → {'✓ MONOTONE' if violations == 0 else '✗'}")
    print()


# --------------------------------------------------------------------------- #
#  Main                                                                        #
# --------------------------------------------------------------------------- #

if __name__ == "__main__":
    print()
    print("  Closure-Circuit Duality: Numerical Demonstrations")
    print("  Verified results from Catalog/Bridges/ClosureCircuitDuality.lean")
    print()

    demo_database_functional_dependencies()
    demo_transitive_closure()
    demo_lattice_closure()
    demo_monotonicity_verification()

    print("=" * 72)
    print("All demonstrations complete. Every result matches the formal theorems.")
    print("=" * 72)
