#!/usr/bin/env python3
"""
Closure-Circuit Duality: Numerical Demonstrations

Demonstrates the key results of the Closure-Circuit Duality theorem:
1. Closure operators from implication presentations
2. Minimal support computation
3. Canonical residual basis construction
4. Monotone DNF circuit reconstruction and correctness verification

All functions are self-contained with type hints.
"""

from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, Set


# =============================================================================
# Core Types
# =============================================================================

Element = str
RuleSet = list[tuple[frozenset[Element], Element]]
ResidualGenerator = tuple[Element, frozenset[Element]]


# =============================================================================
# Part 1: Closure Operators from Implication Presentations
# =============================================================================

def generated_closure(
    rules: RuleSet,
    seed: set[Element],
    universe: set[Element],
) -> set[Element]:
    """
    Compute the closure of `seed` under implication rules.

    Corresponds to `GeneratedClosure` in the Lean formalization.
    Iteratively applies rules until a fixpoint is reached.

    >>> rules = [(frozenset({'a', 'b'}), 'c'), (frozenset({'c'}), 'd')]
    >>> generated_closure(rules, {'a', 'b'}, {'a', 'b', 'c', 'd', 'e'})
    {'a', 'b', 'c', 'd'}
    """
    closed = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion in rules:
            if premises <= closed and conclusion not in closed:
                closed.add(conclusion)
                changed = True
    return closed


def verify_closure_axioms(
    rules: RuleSet,
    universe: set[Element],
) -> dict[str, bool]:
    """
    Verify that `generated_closure` satisfies the three closure operator axioms.

    Corresponds to `generatedClosure_isClosureOperator` in the Lean formalization.
    Tests extensiveness, monotonicity, and idempotence on all subsets.
    """
    all_subsets: list[set[Element]] = []
    elems = sorted(universe)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            all_subsets.append(set(combo))

    # Extensiveness: s ⊆ cl(s)
    extensive = all(
        s <= generated_closure(rules, s, universe)
        for s in all_subsets
    )

    # Monotonicity: s ⊆ t → cl(s) ⊆ cl(t)
    monotone = True
    for s in all_subsets:
        cl_s = generated_closure(rules, s, universe)
        for t in all_subsets:
            if s <= t:
                cl_t = generated_closure(rules, t, universe)
                if not cl_s <= cl_t:
                    monotone = False

    # Idempotence: cl(cl(s)) = cl(s)
    idempotent = all(
        generated_closure(rules, generated_closure(rules, s, universe), universe)
        == generated_closure(rules, s, universe)
        for s in all_subsets
    )

    return {
        "extensive": extensive,
        "monotone": monotone,
        "idempotent": idempotent,
    }


# =============================================================================
# Part 2: Minimal Support Computation
# =============================================================================

def find_minimal_supports(
    cl: callable,
    target: Element,
    universe: set[Element],
) -> list[frozenset[Element]]:
    """
    Find all minimal support sets for `target` under closure operator `cl`.

    A set A is a minimal support for x if x ∈ cl(A) and for every proper
    subset B ⊂ A, x ∉ cl(B).

    Corresponds to `minimalSupports` and `IsMinimalSupport` in the Lean formalization.

    >>> rules = [(frozenset({'a', 'b'}), 'c'), (frozenset({'a', 'd'}), 'c')]
    >>> universe = {'a', 'b', 'c', 'd'}
    >>> cl = lambda s: generated_closure(rules, s, universe)
    >>> sorted([sorted(s) for s in find_minimal_supports(cl, 'c', universe)])
    [['a', 'b'], ['a', 'd'], ['c']]
    """
    minimal_supports: list[frozenset[Element]] = []
    elems = sorted(universe)

    # Check all subsets in order of increasing size
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            A = frozenset(combo)
            if target not in cl(set(A)):
                continue
            # Check minimality: no proper subset should generate target
            is_minimal = True
            for k in range(len(combo)):
                B = frozenset(combo[:k] + combo[k + 1:])
                if target in cl(set(B)):
                    is_minimal = False
                    break
            if is_minimal:
                minimal_supports.append(A)

    return minimal_supports


# =============================================================================
# Part 3: Canonical Residual Basis
# =============================================================================

def compute_canonical_basis(
    cl: callable,
    universe: set[Element],
) -> list[ResidualGenerator]:
    """
    Compute the canonical residual basis for a closure operator.

    For each element x in the universe, finds all minimal supports and
    creates a residual generator (x, A) for each.

    Corresponds to `canonicalBasis` in the Lean formalization.
    """
    basis: list[ResidualGenerator] = []
    for x in sorted(universe):
        for support in find_minimal_supports(cl, x, universe):
            basis.append((x, support))
    return basis


def verify_basis_property(
    basis: list[ResidualGenerator],
    cl: callable,
    universe: set[Element],
) -> bool:
    """
    Verify that the basis satisfies IsCanonicalBasis:
    x ∈ cl(S) ↔ ∃ (x, A) ∈ basis with A ⊆ S.

    Corresponds to `canonical_basis_is_basis` in the Lean formalization.
    """
    elems = sorted(universe)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            S = set(combo)
            cl_S = cl(S)
            for x in universe:
                in_closure = x in cl_S
                has_support = any(
                    g_target == x and set(g_support) <= S
                    for g_target, g_support in basis
                )
                if in_closure != has_support:
                    return False
    return True


# =============================================================================
# Part 4: Monotone DNF Circuit Reconstruction
# =============================================================================

class MonotoneCircuit:
    """
    A monotone Boolean circuit over string-labeled inputs.

    Corresponds to `MonotoneCircuit` in the Lean formalization.
    """

    def eval(self, s: set[Element]) -> bool:
        raise NotImplementedError

    def size(self) -> int:
        raise NotImplementedError


class Input(MonotoneCircuit):
    def __init__(self, label: Element) -> None:
        self.label = label

    def eval(self, s: set[Element]) -> bool:
        return self.label in s

    def size(self) -> int:
        return 1

    def __repr__(self) -> str:
        return f"Input({self.label})"


class Top(MonotoneCircuit):
    def eval(self, s: set[Element]) -> bool:
        return True

    def size(self) -> int:
        return 1

    def __repr__(self) -> str:
        return "⊤"


class Bot(MonotoneCircuit):
    def eval(self, s: set[Element]) -> bool:
        return False

    def size(self) -> int:
        return 1

    def __repr__(self) -> str:
        return "⊥"


class Conj(MonotoneCircuit):
    def __init__(self, left: MonotoneCircuit, right: MonotoneCircuit) -> None:
        self.left = left
        self.right = right

    def eval(self, s: set[Element]) -> bool:
        return self.left.eval(s) and self.right.eval(s)

    def size(self) -> int:
        return 1 + self.left.size() + self.right.size()

    def __repr__(self) -> str:
        return f"({self.left} ∧ {self.right})"


class Disj(MonotoneCircuit):
    def __init__(self, left: MonotoneCircuit, right: MonotoneCircuit) -> None:
        self.left = left
        self.right = right

    def eval(self, s: set[Element]) -> bool:
        return self.left.eval(s) or self.right.eval(s)

    def size(self) -> int:
        return 1 + self.left.size() + self.right.size()

    def __repr__(self) -> str:
        return f"({self.left} ∨ {self.right})"


def conj_of_list(elems: list[Element]) -> MonotoneCircuit:
    """Build AND(input(a1), ..., input(ak)). Corresponds to `conjOfList`."""
    if not elems:
        return Top()
    circuit: MonotoneCircuit = Input(elems[0])
    for e in elems[1:]:
        circuit = Conj(circuit, Input(e))
    return circuit


def disj_of_list(circuits: list[MonotoneCircuit]) -> MonotoneCircuit:
    """Build OR(c1, ..., cm). Corresponds to `disjOfList`."""
    if not circuits:
        return Bot()
    result = circuits[0]
    for c in circuits[1:]:
        result = Disj(result, c)
    return result


def reconstruct_closure_circuit(
    cl: callable,
    universe: set[Element],
) -> dict[Element, MonotoneCircuit]:
    """
    Reconstruct a monotone DNF closure circuit from a closure operator.

    For each element x, builds: OR_{A ∈ minSupp(x)} AND_{a ∈ A} input(a)

    Corresponds to `reconstructClosureCircuit` in the Lean formalization.
    """
    circuits: dict[Element, MonotoneCircuit] = {}
    for x in sorted(universe):
        supports = find_minimal_supports(cl, x, universe)
        conjunctions = [conj_of_list(sorted(A)) for A in supports]
        circuits[x] = disj_of_list(conjunctions)
    return circuits


def verify_circuit_correctness(
    circuits: dict[Element, MonotoneCircuit],
    cl: callable,
    universe: set[Element],
) -> bool:
    """
    Verify that the reconstructed circuit correctly computes the closure.

    Corresponds to `reconstructed_circuit_correct` in the Lean formalization.
    """
    elems = sorted(universe)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            S = set(combo)
            cl_S = cl(S)
            for x in universe:
                circuit_says = circuits[x].eval(S)
                closure_says = x in cl_S
                if circuit_says != closure_says:
                    return False
    return True


# =============================================================================
# Part 5: Demonstrations
# =============================================================================

def demo_database_dependencies() -> None:
    """
    Demo 1: Functional dependencies in a relational database.

    Attributes: {A, B, C, D, E}
    Dependencies:
      {A, B} → C  (knowing A and B determines C)
      {C} → D     (knowing C determines D)
      {A, D} → E  (knowing A and D determines E)
      {B, E} → A  (knowing B and E determines A)
    """
    print("=" * 70)
    print("DEMO 1: Database Functional Dependencies")
    print("=" * 70)

    universe = {'A', 'B', 'C', 'D', 'E'}
    rules: RuleSet = [
        (frozenset({'A', 'B'}), 'C'),
        (frozenset({'C'}), 'D'),
        (frozenset({'A', 'D'}), 'E'),
        (frozenset({'B', 'E'}), 'A'),
    ]

    cl = lambda s: generated_closure(rules, s, universe)

    # Verify closure axioms
    axioms = verify_closure_axioms(rules, universe)
    print(f"\nClosure operator axioms verified:")
    for name, holds in axioms.items():
        print(f"  {name}: {'✓' if holds else '✗'}")

    # Show some closures
    print(f"\nExample closures:")
    test_sets = [{'A', 'B'}, {'C'}, {'A'}, {'B', 'E'}, {'A', 'B', 'C'}]
    for s in test_sets:
        print(f"  cl({sorted(s)}) = {sorted(cl(s))}")

    # Compute canonical basis
    basis = compute_canonical_basis(cl, universe)
    print(f"\nCanonical residual basis ({len(basis)} generators):")
    for target, support in basis:
        print(f"  {target} ← {{{', '.join(sorted(support))}}}")

    # Verify basis property
    basis_ok = verify_basis_property(basis, cl, universe)
    print(f"\nBasis property verified: {'✓' if basis_ok else '✗'}")

    # Reconstruct circuit
    circuits = reconstruct_closure_circuit(cl, universe)
    print(f"\nReconstructed DNF circuits:")
    for x in sorted(universe):
        print(f"  {x}: {circuits[x]}")

    # Verify circuit correctness
    circuit_ok = verify_circuit_correctness(circuits, cl, universe)
    print(f"\nCircuit correctness verified: {'✓' if circuit_ok else '✗'}")
    print()


def demo_supply_chain() -> None:
    """
    Demo 2: Supply chain dependencies.

    Products: {iron, coal, steel, wire, cable, chip, board}
    Rules model manufacturing dependencies.
    """
    print("=" * 70)
    print("DEMO 2: Supply Chain Manufacturing Dependencies")
    print("=" * 70)

    universe = {'iron', 'coal', 'steel', 'wire', 'cable', 'chip', 'board'}
    rules: RuleSet = [
        (frozenset({'iron', 'coal'}), 'steel'),
        (frozenset({'steel'}), 'wire'),
        (frozenset({'wire'}), 'cable'),
        (frozenset({'steel', 'chip'}), 'board'),
    ]

    cl = lambda s: generated_closure(rules, s, universe)

    # Show derivation chains
    print(f"\nWhat can we produce from raw materials?")
    test_sets = [
        {'iron', 'coal'},
        {'iron'},
        {'iron', 'coal', 'chip'},
        {'steel'},
    ]
    for s in test_sets:
        result = cl(s)
        derived = result - s
        print(f"  Starting with {sorted(s)}")
        print(f"    → can derive: {sorted(derived) if derived else '(nothing new)'}")

    # Canonical basis reveals essential dependencies
    basis = compute_canonical_basis(cl, universe)
    print(f"\nCanonical basis reveals {len(basis)} essential production rules:")
    for target, support in basis:
        if support != frozenset({target}):  # Skip trivial self-supports
            print(f"  To produce '{target}', minimally need: {{{', '.join(sorted(support))}}}")

    # Circuit
    circuits = reconstruct_closure_circuit(cl, universe)
    circuit_ok = verify_circuit_correctness(circuits, cl, universe)
    print(f"\nCircuit correctness: {'✓' if circuit_ok else '✗'}")
    print()


def demo_uniqueness() -> None:
    """
    Demo 3: Demonstrating basis uniqueness.

    Two different presentations of the same closure operator
    yield the same canonical basis.
    """
    print("=" * 70)
    print("DEMO 3: Canonical Basis Uniqueness")
    print("=" * 70)

    universe = {'a', 'b', 'c', 'd'}

    # Presentation 1: direct rules
    rules1: RuleSet = [
        (frozenset({'a'}), 'b'),
        (frozenset({'b'}), 'c'),
        (frozenset({'a'}), 'c'),  # redundant! derivable from first two
        (frozenset({'c', 'd'}), 'a'),
    ]

    # Presentation 2: different but equivalent
    rules2: RuleSet = [
        (frozenset({'a'}), 'b'),
        (frozenset({'a'}), 'c'),
        (frozenset({'b'}), 'c'),
        (frozenset({'c', 'd'}), 'b'),  # derivable differently
        (frozenset({'c', 'd'}), 'a'),
    ]

    cl1 = lambda s: generated_closure(rules1, s, universe)
    cl2 = lambda s: generated_closure(rules2, s, universe)

    # Verify they compute the same closure
    elems = sorted(universe)
    same_closure = True
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            if cl1(set(combo)) != cl2(set(combo)):
                same_closure = False
                break

    print(f"\nTwo different presentations compute the same closure: "
          f"{'✓' if same_closure else '✗'}")

    basis1 = compute_canonical_basis(cl1, universe)
    basis2 = compute_canonical_basis(cl2, universe)

    print(f"\nBasis from presentation 1 ({len(basis1)} generators):")
    for target, support in basis1:
        print(f"  {target} ← {{{', '.join(sorted(support))}}}")

    print(f"\nBasis from presentation 2 ({len(basis2)} generators):")
    for target, support in basis2:
        print(f"  {target} ← {{{', '.join(sorted(support))}}}")

    # Compare
    basis1_set = set(basis1)
    basis2_set = set(basis2)
    print(f"\nBases are identical: {'✓' if basis1_set == basis2_set else '✗'}")
    print("(This demonstrates Theorem: canonical_basis_unique)")
    print()


def demo_circuit_monotonicity() -> None:
    """
    Demo 4: Circuit evaluation monotonicity.

    Demonstrates that if S ⊆ T and the circuit fires on S,
    it also fires on T (Theorem: eval_mono).
    """
    print("=" * 70)
    print("DEMO 4: Circuit Evaluation Monotonicity")
    print("=" * 70)

    universe = {'p', 'q', 'r', 's'}
    rules: RuleSet = [
        (frozenset({'p', 'q'}), 'r'),
        (frozenset({'r'}), 's'),
    ]
    cl = lambda s: generated_closure(rules, s, universe)
    circuits = reconstruct_closure_circuit(cl, universe)

    print(f"\nRules: {{p, q}} → r, {{r}} → s")
    print(f"\nMonotonicity check: if circuit fires on S, it fires on all S ⊆ T")

    violations = 0
    checks = 0
    elems = sorted(universe)
    for r1 in range(len(elems) + 1):
        for combo1 in combinations(elems, r1):
            S = set(combo1)
            for r2 in range(len(elems) + 1):
                for combo2 in combinations(elems, r2):
                    T = set(combo2)
                    if S <= T:
                        for x in universe:
                            checks += 1
                            if circuits[x].eval(S) and not circuits[x].eval(T):
                                violations += 1

    print(f"  Checked {checks} (S ⊆ T, x) triples")
    print(f"  Monotonicity violations: {violations}")
    print(f"  Monotonicity holds: {'✓' if violations == 0 else '✗'}")
    print()


def demo_circuit_sizes() -> None:
    """
    Demo 5: Circuit size analysis.

    Shows how the canonical circuit size relates to the number of
    minimal supports.
    """
    print("=" * 70)
    print("DEMO 5: Circuit Size Analysis")
    print("=" * 70)

    universe = {'a', 'b', 'c', 'd', 'e'}

    # A closure with many alternative derivations
    rules: RuleSet = [
        (frozenset({'a'}), 'c'),
        (frozenset({'b'}), 'c'),
        (frozenset({'c', 'd'}), 'e'),
        (frozenset({'a', 'b'}), 'e'),
        (frozenset({'d'}), 'e'),
    ]

    cl = lambda s: generated_closure(rules, s, universe)
    circuits = reconstruct_closure_circuit(cl, universe)
    basis = compute_canonical_basis(cl, universe)

    print(f"\nElement | Minimal Supports | Circuit Size")
    print(f"--------|-----------------|-------------")
    for x in sorted(universe):
        supports = find_minimal_supports(cl, x, universe)
        n_supports = len(supports)
        ckt_size = circuits[x].size()
        support_strs = ['{' + ','.join(sorted(s)) + '}' for s in supports]
        print(f"   {x}    |       {n_supports:2d}        |     {ckt_size:3d}      "
              f"  supports: {', '.join(support_strs)}")

    total_basis = len(basis)
    total_gates = sum(c.size() for c in circuits.values())
    print(f"\nTotal basis size: {total_basis} generators")
    print(f"Total circuit gates: {total_gates}")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     CLOSURE-CIRCUIT DUALITY: Numerical Demonstrations              ║")
    print("║     Certified Monotone Circuit Reconstruction                      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_database_dependencies()
    demo_supply_chain()
    demo_uniqueness()
    demo_circuit_monotonicity()
    demo_circuit_sizes()

    print("All demonstrations complete.")
