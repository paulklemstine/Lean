#!/usr/bin/env python3
"""
Closure-Circuit Duality: Numerical Demonstrations

This module demonstrates the key results of the Closure-Circuit Duality theorem
through concrete examples:

1. Building closure operators from implication rules
2. Computing minimal supports for elements
3. Constructing the canonical residual basis
4. Reconstructing monotone DNF circuits
5. Verifying circuit correctness against the closure operator

All functions are self-contained with type hints.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Callable


# ── Types ──────────────────────────────────────────────────────────────────

Element = str
SetOfElements = FrozenSet[Element]
Rule = tuple[FrozenSet[Element], Element]  # (premises, conclusion)
ClosureOp = Callable[[SetOfElements], SetOfElements]


# ── Part 1: Closure Operators from Presentations ──────────────────────────

def make_closure_from_rules(
    universe: set[Element],
    rules: list[Rule],
) -> ClosureOp:
    """
    Build a closure operator from a set of implication rules.

    Corresponds to `GeneratedClosure` in the Lean formalization:
    iterate rules until a fixed point is reached.
    """
    def closure(seed: SetOfElements) -> SetOfElements:
        current: set[Element] = set(seed)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in rules:
                if premises <= current and conclusion not in current:
                    current.add(conclusion)
                    changed = True
        return frozenset(current)
    return closure


def verify_closure_operator(
    cl: ClosureOp,
    universe: set[Element],
    sample_sets: list[SetOfElements],
) -> dict[str, bool]:
    """
    Verify the three closure operator axioms on sample sets.

    Corresponds to `IsClosureOperator` in the Lean formalization:
    - extensive: S ⊆ cl(S)
    - monotone: S ⊆ T → cl(S) ⊆ cl(T)
    - idempotent: cl(cl(S)) = cl(S)
    """
    extensive = all(s <= cl(s) for s in sample_sets)

    monotone = all(
        cl(s1) <= cl(s2)
        for s1 in sample_sets
        for s2 in sample_sets
        if s1 <= s2
    )

    idempotent = all(cl(cl(s)) == cl(s) for s in sample_sets)

    return {
        "extensive": extensive,
        "monotone": monotone,
        "idempotent": idempotent,
    }


# ── Part 2: Minimal Support Computation ──────────────────────────────────

def find_minimal_supports(
    cl: ClosureOp,
    target: Element,
    universe: set[Element],
) -> list[FrozenSet[Element]]:
    """
    Find all minimal supports for a target element under a closure operator.

    Corresponds to `minimalSupports` and `IsMinimalSupport` in the Lean formalization.

    A set A is a minimal support for x if:
      1. x ∈ cl(A)
      2. For every proper subset B ⊊ A, x ∉ cl(B)
    """
    minimal: list[FrozenSet[Element]] = []
    elements = sorted(universe)

    # Check all subsets, smallest first, to find minimal supports
    for size in range(len(elements) + 1):
        for combo in combinations(elements, size):
            candidate = frozenset(combo)
            if target in cl(candidate):
                # Check minimality: no proper subset also generates target
                is_minimal = True
                for sub_size in range(size):
                    for sub_combo in combinations(list(candidate), sub_size):
                        if target in cl(frozenset(sub_combo)):
                            is_minimal = False
                            break
                    if not is_minimal:
                        break
                if is_minimal:
                    # Also check it's not a superset of an already-found minimal
                    if not any(m < candidate for m in minimal):
                        minimal.append(candidate)

    return minimal


# ── Part 3: Canonical Residual Basis ──────────────────────────────────────

def compute_canonical_basis(
    cl: ClosureOp,
    universe: set[Element],
) -> list[tuple[Element, FrozenSet[Element]]]:
    """
    Compute the canonical residual basis of a closure operator.

    Corresponds to `canonicalBasis` and `IsCanonicalBasis` in the Lean formalization.

    Returns a list of (target, support) pairs representing all minimal generators.
    """
    basis: list[tuple[Element, FrozenSet[Element]]] = []
    for x in sorted(universe):
        for support in find_minimal_supports(cl, x, universe):
            basis.append((x, support))
    return basis


def verify_basis_property(
    cl: ClosureOp,
    basis: list[tuple[Element, FrozenSet[Element]]],
    universe: set[Element],
    sample_sets: list[SetOfElements],
) -> dict[str, bool]:
    """
    Verify the canonical basis property on sample sets.

    Corresponds to `IsCanonicalBasis` in the Lean formalization:
    x ∈ cl(S) ↔ ∃ (x, A) ∈ B such that A ⊆ S
    """
    correct = True
    for s in sample_sets:
        closed = cl(s)
        for x in universe:
            in_closure = x in closed
            has_support = any(
                target == x and support <= s
                for target, support in basis
            )
            if in_closure != has_support:
                correct = False
                break
    return {"basis_characterization_holds": correct}


# ── Part 4: Monotone DNF Circuit Reconstruction ──────────────────────────

class MonotoneCircuit:
    """
    A monotone Boolean circuit (no negation).

    Corresponds to `MonotoneCircuit` in the Lean formalization.
    """
    pass

class InputGate(MonotoneCircuit):
    def __init__(self, element: Element):
        self.element = element

    def eval(self, s: SetOfElements) -> bool:
        return self.element in s

    def size(self) -> int:
        return 1

    def __repr__(self) -> str:
        return f"Input({self.element})"

class TopGate(MonotoneCircuit):
    def eval(self, s: SetOfElements) -> bool:
        return True

    def size(self) -> int:
        return 1

    def __repr__(self) -> str:
        return "⊤"

class BotGate(MonotoneCircuit):
    def eval(self, s: SetOfElements) -> bool:
        return False

    def size(self) -> int:
        return 1

    def __repr__(self) -> str:
        return "⊥"

class ConjGate(MonotoneCircuit):
    def __init__(self, left: MonotoneCircuit, right: MonotoneCircuit):
        self.left = left
        self.right = right

    def eval(self, s: SetOfElements) -> bool:
        return self.left.eval(s) and self.right.eval(s)

    def size(self) -> int:
        return 1 + self.left.size() + self.right.size()

    def __repr__(self) -> str:
        return f"({self.left} ∧ {self.right})"

class DisjGate(MonotoneCircuit):
    def __init__(self, left: MonotoneCircuit, right: MonotoneCircuit):
        self.left = left
        self.right = right

    def eval(self, s: SetOfElements) -> bool:
        return self.left.eval(s) or self.right.eval(s)

    def size(self) -> int:
        return 1 + self.left.size() + self.right.size()

    def __repr__(self) -> str:
        return f"({self.left} ∨ {self.right})"


def conj_of_list(elements: list[Element]) -> MonotoneCircuit:
    """Build ⋀ᵢ input(aᵢ). Corresponds to `conjOfList`."""
    if not elements:
        return TopGate()
    circuit: MonotoneCircuit = InputGate(elements[0])
    for e in elements[1:]:
        circuit = ConjGate(circuit, InputGate(e))
    return circuit


def disj_of_list(circuits: list[MonotoneCircuit]) -> MonotoneCircuit:
    """Build ⋁ᵢ cᵢ. Corresponds to `disjOfList`."""
    if not circuits:
        return BotGate()
    result = circuits[0]
    for c in circuits[1:]:
        result = DisjGate(result, c)
    return result


def reconstruct_closure_circuit(
    cl: ClosureOp,
    universe: set[Element],
) -> dict[Element, MonotoneCircuit]:
    """
    Reconstruct a monotone DNF circuit from a closure operator.

    Corresponds to `reconstructClosureCircuit` in the Lean formalization.

    For each target x, builds: ⋁_{A ∈ minSupp(x)} ⋀_{a ∈ A} input(a)
    """
    circuits: dict[Element, MonotoneCircuit] = {}
    for x in sorted(universe):
        supports = find_minimal_supports(cl, x, universe)
        conjunctions = [conj_of_list(sorted(support)) for support in supports]
        circuits[x] = disj_of_list(conjunctions)
    return circuits


def verify_circuit_correctness(
    cl: ClosureOp,
    circuits: dict[Element, MonotoneCircuit],
    universe: set[Element],
    sample_sets: list[SetOfElements],
) -> dict[str, bool | int]:
    """
    Verify that the reconstructed circuit computes the closure exactly.

    Corresponds to `reconstructed_circuit_correct` in the Lean formalization.
    """
    total_checks = 0
    all_correct = True

    for s in sample_sets:
        closed = cl(s)
        for x in universe:
            in_closure = x in closed
            circuit_says = circuits[x].eval(s)
            if in_closure != circuit_says:
                all_correct = False
            total_checks += 1

    return {
        "all_correct": all_correct,
        "total_checks": total_checks,
    }


def verify_circuit_monotonicity(
    circuits: dict[Element, MonotoneCircuit],
    sample_sets: list[SetOfElements],
) -> bool:
    """
    Verify that circuit evaluation is monotone: S ⊆ T → eval(c, S) → eval(c, T).

    Corresponds to `MonotoneCircuit.eval_mono` in the Lean formalization.
    """
    for x, circuit in circuits.items():
        for s1 in sample_sets:
            if circuit.eval(s1):
                for s2 in sample_sets:
                    if s1 <= s2 and not circuit.eval(s2):
                        return False
    return True


# ── Part 5: Uniqueness Demonstration ─────────────────────────────────────

def demonstrate_basis_uniqueness(
    cl: ClosureOp,
    universe: set[Element],
) -> dict[str, object]:
    """
    Demonstrate that the canonical basis is unique by computing it
    via two different methods and verifying equality.

    Corresponds to `canonical_basis_unique` / `closure_basis_canonical`
    in the Lean formalization.
    """
    # Method 1: Direct computation
    basis1 = compute_canonical_basis(cl, universe)

    # Method 2: Filter from all possible generators
    basis2: list[tuple[Element, FrozenSet[Element]]] = []
    elements = sorted(universe)
    for x in elements:
        for size in range(len(elements) + 1):
            for combo in combinations(elements, size):
                candidate = frozenset(combo)
                if x in cl(candidate):
                    # Check minimality independently
                    is_min = all(
                        x not in cl(frozenset(sub))
                        for sub_size in range(size)
                        for sub in combinations(list(candidate), sub_size)
                    )
                    if is_min:
                        basis2.append((x, candidate))

    return {
        "basis_method_1": basis1,
        "basis_method_2": basis2,
        "are_equal": set((t, s) for t, s in basis1) == set((t, s) for t, s in basis2),
    }


# ── Demo Scenarios ────────────────────────────────────────────────────────

def demo_database_dependencies() -> None:
    """
    Demo 1: Database functional dependencies as a closure system.

    Consider a relation with attributes {A, B, C, D, E} and functional
    dependencies: {A} → B, {B, C} → D, {A, C} → E.
    """
    print("=" * 70)
    print("DEMO 1: Database Functional Dependencies")
    print("=" * 70)

    universe = {"A", "B", "C", "D", "E"}

    rules: list[Rule] = [
        (frozenset({"A"}), "B"),       # A → B
        (frozenset({"B", "C"}), "D"),  # B, C → D
        (frozenset({"A", "C"}), "E"),  # A, C → E
    ]

    cl = make_closure_from_rules(universe, rules)

    # Test closure computation
    test_sets = [
        frozenset({"A"}),
        frozenset({"A", "C"}),
        frozenset({"B", "C"}),
        frozenset({"A", "B", "C"}),
        frozenset(),
    ]

    print("\nClosure computations:")
    for s in test_sets:
        print(f"  cl({set(s) or '∅'}) = {set(cl(s))}")

    # Verify closure axioms
    all_subsets = [frozenset(combo) for size in range(len(universe) + 1)
                   for combo in combinations(sorted(universe), size)]
    axioms = verify_closure_operator(cl, universe, all_subsets)
    print(f"\nClosure axioms verified: {axioms}")

    # Compute canonical basis
    basis = compute_canonical_basis(cl, universe)
    print(f"\nCanonical residual basis ({len(basis)} generators):")
    for target, support in basis:
        print(f"  {target} ← {set(support) or '∅'}")

    # Verify basis property
    bp = verify_basis_property(cl, basis, universe, all_subsets)
    print(f"Basis characterization holds: {bp['basis_characterization_holds']}")

    # Reconstruct circuit
    circuits = reconstruct_closure_circuit(cl, universe)
    print("\nReconstructed DNF circuits:")
    for x in sorted(universe):
        print(f"  C({x}) = {circuits[x]}")
        print(f"         size = {circuits[x].size()}")

    # Verify circuit correctness
    cc = verify_circuit_correctness(cl, circuits, universe, all_subsets)
    print(f"\nCircuit correctness: {cc['all_correct']} ({cc['total_checks']} checks)")

    # Verify monotonicity
    mono = verify_circuit_monotonicity(circuits, all_subsets)
    print(f"Circuit monotonicity: {mono}")

    # Verify uniqueness
    uniq = demonstrate_basis_uniqueness(cl, universe)
    print(f"Basis uniqueness verified: {uniq['are_equal']}")


def demo_social_influence() -> None:
    """
    Demo 2: Social influence propagation as a closure system.

    Model: person is influenced if ≥ 2 of their contacts are influenced.
    Network: A-B, A-C, B-C, B-D, C-D, D-E
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Social Influence Propagation")
    print("=" * 70)

    universe = {"A", "B", "C", "D", "E"}

    # Threshold rules: each person is influenced if ≥ 2 contacts are
    # In this network, the contacts are:
    # A: {B, C}, B: {A, C, D}, C: {A, B, D}, D: {B, C, E}, E: {D}
    rules: list[Rule] = [
        # A is influenced if B and C are (A's only two contacts)
        (frozenset({"B", "C"}), "A"),
        # B is influenced if any 2 of {A, C, D} are
        (frozenset({"A", "C"}), "B"),
        (frozenset({"A", "D"}), "B"),
        (frozenset({"C", "D"}), "B"),
        # C is influenced if any 2 of {A, B, D} are
        (frozenset({"A", "B"}), "C"),
        (frozenset({"A", "D"}), "C"),
        (frozenset({"B", "D"}), "C"),
        # D is influenced if any 2 of {B, C, E} are
        (frozenset({"B", "C"}), "D"),
        (frozenset({"B", "E"}), "D"),
        (frozenset({"C", "E"}), "D"),
        # E has only 1 contact (D), so threshold = 1
        (frozenset({"D"}), "E"),
    ]

    cl = make_closure_from_rules(universe, rules)

    seeds = [
        frozenset({"A", "B"}),
        frozenset({"B", "C"}),
        frozenset({"A", "D"}),
        frozenset({"C"}),
    ]

    print("\nInfluence cascades:")
    for s in seeds:
        result = cl(s)
        cascade = result - s
        print(f"  Seed {set(s)} → Influenced: {set(cascade)}, Total: {set(result)}")

    # Canonical basis
    basis = compute_canonical_basis(cl, universe)
    print(f"\nCanonical basis ({len(basis)} generators):")
    for target, support in basis:
        print(f"  {target} ← {set(support)}")

    # Circuit
    circuits = reconstruct_closure_circuit(cl, universe)
    all_subsets = [frozenset(combo) for size in range(len(universe) + 1)
                   for combo in combinations(sorted(universe), size)]
    cc = verify_circuit_correctness(cl, circuits, universe, all_subsets)
    print(f"\nCircuit correctness: {cc['all_correct']} ({cc['total_checks']} checks)")


def demo_logic_inference() -> None:
    """
    Demo 3: Propositional logic inference as a closure system.

    Axioms: p → q, q → r, (p ∧ r) → s
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Propositional Logic Inference")
    print("=" * 70)

    universe = {"p", "q", "r", "s"}

    rules: list[Rule] = [
        (frozenset({"p"}), "q"),          # p → q
        (frozenset({"q"}), "r"),          # q → r
        (frozenset({"p", "r"}), "s"),     # p ∧ r → s
    ]

    cl = make_closure_from_rules(universe, rules)

    # Show derivation chains
    test_sets = [
        frozenset({"p"}),
        frozenset({"q"}),
        frozenset({"r"}),
        frozenset({"p", "r"}),
    ]

    print("\nDeductive closures:")
    for s in test_sets:
        print(f"  cl({set(s)}) = {set(cl(s))}")

    print(f"\n  Note: cl({{p}}) = {set(cl(frozenset({'p'})))}")
    print(f"  Because p → q → r, and p ∧ r → s, so everything follows from p.")

    # Canonical basis
    basis = compute_canonical_basis(cl, universe)
    print(f"\nCanonical basis ({len(basis)} generators):")
    for target, support in basis:
        print(f"  {target} ← {set(support) or '∅'}")

    # Circuit size comparison
    circuits = reconstruct_closure_circuit(cl, universe)
    total_size = sum(c.size() for c in circuits.values())
    print(f"\nTotal circuit size: {total_size} gates")
    for x in sorted(universe):
        print(f"  C({x}) = {circuits[x]}")

    # Uniqueness
    uniq = demonstrate_basis_uniqueness(cl, universe)
    print(f"\nBasis uniqueness: {uniq['are_equal']}")


def demo_circuit_size_analysis() -> None:
    """
    Demo 4: Circuit size as a function of closure complexity.

    Demonstrates that the DNF circuit size is determined by the number
    and size of minimal supports.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Circuit Complexity Analysis")
    print("=" * 70)

    # Create closure systems of increasing complexity
    for n in range(3, 7):
        elements = [chr(ord('a') + i) for i in range(n)]
        universe = set(elements)

        # Chain closure: a₀ → a₁ → ... → aₙ₋₁
        rules: list[Rule] = [
            (frozenset({elements[i]}), elements[i + 1])
            for i in range(n - 1)
        ]

        cl = make_closure_from_rules(universe, rules)
        basis = compute_canonical_basis(cl, universe)
        circuits = reconstruct_closure_circuit(cl, universe)
        total_size = sum(c.size() for c in circuits.values())

        print(f"  n={n}: {len(basis)} generators, "
              f"total circuit size = {total_size} gates")

    print()

    # Dense closure: every pair generates everything
    for n in range(3, 7):
        elements = [chr(ord('a') + i) for i in range(n)]
        universe = set(elements)

        rules: list[Rule] = []
        for i in range(n):
            for j in range(n):
                if i != j:
                    for k in range(n):
                        if k != i and k != j:
                            rules.append(
                                (frozenset({elements[i], elements[j]}), elements[k])
                            )

        cl = make_closure_from_rules(universe, rules)
        basis = compute_canonical_basis(cl, universe)
        circuits = reconstruct_closure_circuit(cl, universe)
        total_size = sum(c.size() for c in circuits.values())

        print(f"  n={n} (dense): {len(basis)} generators, "
              f"total circuit size = {total_size} gates")


# ── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Closure-Circuit Duality: Numerical Demonstrations")
    print("Verifying the main theorems through concrete computation\n")

    demo_database_dependencies()
    demo_social_influence()
    demo_logic_inference()
    demo_circuit_size_analysis()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)
