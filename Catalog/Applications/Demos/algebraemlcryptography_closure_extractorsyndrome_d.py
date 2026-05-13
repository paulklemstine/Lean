"""
Applications of Closure-Extractor-Syndrome Duality

Demonstrates real-world applications:
1. Error detection in communication
2. Feature dependency analysis
3. Secret sharing access structure analysis
"""

import itertools
from typing import Dict, FrozenSet, List, Set, Tuple

from algorithms import (
    forward_chaining_closure,
    capacity,
    capacity_increment,
    parity_check_to_rules,
    syndrome_classes,
    check_submodularity,
)


def error_detection_demo():
    """
    Application: Error Detection via Syndrome Analysis

    Shows how the closure-capacity framework identifies which
    bit positions are determined (and thus error-detectable)
    given partial observations.
    """
    print("=" * 70)
    print("APPLICATION 1: Error Detection via Syndrome Analysis")
    print("=" * 70)

    # Simple repetition-like code
    # Parity check: positions {0,1,2} must have even parity
    #               positions {2,3,4} must have even parity
    H = [
        [1, 1, 1, 0, 0],
        [0, 0, 1, 1, 1],
    ]
    n = 5
    universe = set(range(n))
    rules = parity_check_to_rules(H)

    print(f"\nCode: {n} positions, {len(H)} parity checks")
    print(f"Generated {len(rules)} implication rules\n")

    # Show which positions are determined by observing subsets
    print("Determination analysis:")
    for size in range(1, n):
        for subset in itertools.combinations(range(n), size):
            observed = set(subset)
            determined = forward_chaining_closure(rules, observed, universe)
            extra = determined - observed
            if extra:
                cap_val = capacity(rules, observed, universe)
                print(f"  Observing {observed} → determines {extra} "
                      f"(capacity = {cap_val})")

    # Syndrome analysis
    print("\nSyndrome classes (sets with identical error signatures):")
    classes = syndrome_classes(H, universe)
    for s, members in sorted(classes.items()):
        if len(members) <= 6:  # Only show small classes
            print(f"  Syndrome {s}: {[set(m) for m in members[:4]]}...")


def feature_dependency_demo():
    """
    Application: Feature Dependency Analysis

    Given a dataset where some features determine others,
    use the closure-capacity framework to find minimal
    feature sets and measure redundancy.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Feature Dependency Analysis")
    print("=" * 70)

    # Simulate: 6 features with dependency rules
    # Feature 0, 1 together determine feature 2
    # Feature 2, 3 together determine feature 4
    # Feature 0 alone determines feature 5
    universe = set(range(6))
    rules: List[Tuple[FrozenSet[int], int]] = [
        (frozenset({0, 1}), 2),
        (frozenset({2, 3}), 4),
        (frozenset({0}), 5),
    ]

    print(f"\n{len(universe)} features, {len(rules)} dependency rules:")
    for premises, conclusion in rules:
        print(f"  Features {set(premises)} → Feature {conclusion}")

    # Find closure of each individual feature
    print("\nClosure of individual features:")
    for x in sorted(universe):
        cl = forward_chaining_closure(rules, {x}, universe)
        print(f"  cl({{{x}}}) = {cl}")

    # Find minimal feature sets that determine everything
    print("\nMinimal feature sets determining ALL features:")
    for size in range(1, len(universe) + 1):
        found = False
        for subset in itertools.combinations(universe, size):
            observed = set(subset)
            cl = forward_chaining_closure(rules, observed, universe)
            if cl == universe:
                cap_val = capacity(rules, observed, universe)
                print(f"  {observed} (size {size}, capacity {cap_val})")
                found = True
        if found:
            break

    # Capacity increments show "information value" of each feature
    print("\nFeature information value (capacity increment when added to ∅):")
    for x in sorted(universe):
        inc = capacity_increment(rules, set(), x, universe)
        print(f"  Feature {x}: increment = {inc}")


def secret_sharing_demo():
    """
    Application: Secret Sharing Access Structure Analysis

    Model a secret sharing scheme where the capacity measures
    how much information a coalition of shareholders has about
    the secret.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Secret Sharing Access Structure")
    print("=" * 70)

    # 5 shareholders, secret is "position 0"
    # Shares at positions 1-4
    # Access structure: any 2 of {1,2,3} can reconstruct, or {4} alone
    universe = {0, 1, 2, 3, 4}
    rules: List[Tuple[FrozenSet[int], int]] = [
        (frozenset({1, 2}), 0),  # shareholders 1,2 → secret
        (frozenset({1, 3}), 0),  # shareholders 1,3 → secret
        (frozenset({2, 3}), 0),  # shareholders 2,3 → secret
        (frozenset({4}), 0),     # shareholder 4 → secret (trusted dealer)
    ]

    print(f"\nSecret sharing: secret at position 0, {len(universe)-1} shareholders")
    print(f"Access rules:")
    for premises, conclusion in rules:
        shareholders = set(premises)
        print(f"  Shareholders {shareholders} → can reconstruct secret")

    # Analyze coalitions
    print("\nCoalition analysis:")
    for size in range(1, len(universe)):
        for subset in itertools.combinations(range(1, 5), size):
            coalition = set(subset)
            cl = forward_chaining_closure(rules, coalition, universe)
            can_reconstruct = 0 in cl
            cap_val = capacity(rules, coalition, universe)
            status = "✓ AUTHORIZED" if can_reconstruct else "✗ unauthorized"
            print(f"  Coalition {coalition}: {status} (capacity = {cap_val})")

    # Submodularity check
    print("\nSubmodularity check for this scheme:")
    is_sub, counter = check_submodularity(rules, universe)
    if is_sub:
        print("  ✓ Capacity is submodular — information leakage has diminishing returns")
    else:
        A, B = counter
        print(f"  ✗ Not submodular (A={A}, B={B})")


if __name__ == "__main__":
    error_detection_demo()
    feature_dependency_demo()
    secret_sharing_demo()
    print("\n" + "=" * 70)
    print("All applications complete.")
    print("=" * 70)


"""
Closure-Extractor-Syndrome Duality: Demonstrations

This script demonstrates the core mathematical structures of the
closure-capacity-syndrome duality, showing how:
1. Implication rules generate closure operators
2. Capacity functions satisfy submodularity
3. Parity-check matrices yield closure-capacity objects
4. Syndrome spaces partition the power set
"""

import itertools
from typing import Dict, FrozenSet, List, Set, Tuple

# Type aliases
Element = int
RuleSet = List[Tuple[FrozenSet[Element], Element]]


def forward_chaining_closure(rules: RuleSet, seed: Set[Element],
                              universe: Set[Element]) -> Set[Element]:
    """
    Compute the closure of `seed` under implication rules.
    Each rule (premises, conclusion) fires when premises ⊆ current set.
    """
    current = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion in rules:
            if premises <= current and conclusion not in current:
                current.add(conclusion)
                changed = True
    return current & universe


def rule_count(rules: RuleSet, A: Set[Element]) -> int:
    """Count rules whose premises and conclusion are all in A."""
    return sum(1 for premises, conclusion in rules
               if premises <= A and conclusion in A)


def capacity_increment(rules: RuleSet, A: Set[Element], x: Element,
                        universe: Set[Element]) -> int:
    """Capacity increment of adding x to A (after closure)."""
    cl_A = forward_chaining_closure(rules, A, universe)
    cl_Ax = forward_chaining_closure(rules, A | {x}, universe)
    return rule_count(rules, cl_Ax) - rule_count(rules, cl_A)


def parity_check_to_rules(H: List[List[int]]) -> RuleSet:
    """
    Convert a binary parity-check matrix to implication rules.
    Each row with support S generates rules: for each x in S, (S\\{x}) -> x.
    """
    rules = []
    for row in H:
        support = frozenset(i for i, v in enumerate(row) if v == 1)
        for x in support:
            premises = support - {x}
            rules.append((premises, x))
    return rules


def syndrome(H: List[List[int]], A: Set[Element]) -> Tuple[int, ...]:
    """Compute the syndrome of set A under parity-check matrix H."""
    result = []
    for row in H:
        support = set(i for i, v in enumerate(row) if v == 1)
        result.append(len(support & A) % 2)
    return tuple(result)


def demonstrate_closure_operator():
    """Demonstrate that forward-chaining closure is a closure operator."""
    print("=" * 70)
    print("DEMO 1: Forward-Chaining Closure Operator")
    print("=" * 70)

    universe = {0, 1, 2, 3}
    # Rules: {0,1} -> 2, {1,2} -> 3, {0} -> 1
    rules = [
        (frozenset({0, 1}), 2),
        (frozenset({1, 2}), 3),
        (frozenset({0}), 1),
    ]

    print(f"\nUniverse: {universe}")
    print(f"Rules: {[(set(p), c) for p, c in rules]}")

    # Show closure of various sets
    for seed_list in [[], [0], [1], [0, 1], [2], [0, 2]]:
        seed = set(seed_list)
        cl = forward_chaining_closure(rules, seed, universe)
        print(f"  cl({seed}) = {cl}")

    # Verify extensivity
    print("\nVerifying extensivity (A ⊆ cl(A)):")
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            A = set(subset)
            cl_A = forward_chaining_closure(rules, A, universe)
            assert A <= cl_A, f"Extensivity failed: {A} ⊄ {cl_A}"
    print("  ✓ All subsets satisfy A ⊆ cl(A)")

    # Verify idempotence
    print("\nVerifying idempotence (cl(cl(A)) = cl(A)):")
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            A = set(subset)
            cl_A = forward_chaining_closure(rules, A, universe)
            cl_cl_A = forward_chaining_closure(rules, cl_A, universe)
            assert cl_A == cl_cl_A, f"Idempotence failed: cl({A})"
    print("  ✓ All subsets satisfy cl(cl(A)) = cl(A)")

    # Verify monotonicity
    print("\nVerifying monotonicity (A ⊆ B ⟹ cl(A) ⊆ cl(B)):")
    all_subsets = []
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            all_subsets.append(set(subset))
    for A in all_subsets:
        for B in all_subsets:
            if A <= B:
                cl_A = forward_chaining_closure(rules, A, universe)
                cl_B = forward_chaining_closure(rules, B, universe)
                assert cl_A <= cl_B, f"Monotonicity failed: {A} ⊆ {B}"
    print("  ✓ All pairs satisfy A ⊆ B ⟹ cl(A) ⊆ cl(B)")


def demonstrate_capacity_submodularity():
    """Demonstrate capacity properties including submodularity."""
    print("\n" + "=" * 70)
    print("DEMO 2: Capacity Function Properties")
    print("=" * 70)

    universe = {0, 1, 2, 3}
    rules = [
        (frozenset({0, 1}), 2),
        (frozenset({1, 2}), 3),
        (frozenset({0}), 1),
    ]

    print(f"\nUniverse: {universe}")
    print(f"Rules: {[(set(p), c) for p, c in rules]}")

    # Show capacity of various sets
    print("\nCapacity of closed sets (rule count after closure):")
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            A = set(subset)
            cl_A = forward_chaining_closure(rules, A, universe)
            cap = rule_count(rules, cl_A)
            print(f"  cap({A}) = {cap}  [cl({A}) = {cl_A}]")

    # Check submodularity: cap(A∪B) + cap(A∩B) ≤ cap(A) + cap(B)
    print("\nChecking submodularity (cap(A∪B) + cap(A∩B) ≤ cap(A) + cap(B)):")
    violations = 0
    for A in itertools.chain.from_iterable(
        itertools.combinations(universe, r) for r in range(len(universe) + 1)):
        for B in itertools.chain.from_iterable(
            itertools.combinations(universe, r) for r in range(len(universe) + 1)):
            A_set, B_set = set(A), set(B)
            cl_A = forward_chaining_closure(rules, A_set, universe)
            cl_B = forward_chaining_closure(rules, B_set, universe)
            cl_AB = forward_chaining_closure(rules, A_set | B_set, universe)
            cl_AnB = forward_chaining_closure(rules, A_set & B_set, universe)

            cap_A = rule_count(rules, cl_A)
            cap_B = rule_count(rules, cl_B)
            cap_AB = rule_count(rules, cl_AB)
            cap_AnB = rule_count(rules, cl_AnB)

            if cap_AB + cap_AnB > cap_A + cap_B:
                violations += 1
                print(f"  VIOLATION: A={A_set}, B={B_set}: "
                      f"{cap_AB}+{cap_AnB} > {cap_A}+{cap_B}")

    if violations == 0:
        print("  ✓ Submodularity holds for all pairs (for this example)")
    else:
        print(f"  ✗ {violations} violations found")
        print("  (Submodularity may not hold for general rule sets)")


def demonstrate_parity_check():
    """Demonstrate parity-check matrix to closure-capacity conversion."""
    print("\n" + "=" * 70)
    print("DEMO 3: Parity-Check Matrix → Closure-Capacity Object")
    print("=" * 70)

    # [7,4] Hamming code parity-check matrix
    H = [
        [1, 1, 0, 1, 1, 0, 0],
        [1, 0, 1, 1, 0, 1, 0],
        [0, 1, 1, 1, 0, 0, 1],
    ]
    n = len(H[0])
    universe = set(range(n))

    print(f"\n[7,4] Hamming code parity-check matrix H:")
    for i, row in enumerate(H):
        print(f"  Row {i}: {row}  (support: {set(j for j, v in enumerate(row) if v)})")

    rules = parity_check_to_rules(H)
    print(f"\nGenerated {len(rules)} implication rules")

    # Show some closures
    print("\nClosure examples:")
    test_sets = [{0}, {1}, {0, 1}, {0, 1, 2}, {4, 5, 6}]
    for seed in test_sets:
        cl = forward_chaining_closure(rules, seed, universe)
        cap = rule_count(rules, cl)
        print(f"  cl({seed}) = {cl}, cap = {cap}")

    # Syndrome computation
    print("\nSyndrome examples:")
    for A_list in [[0], [1], [0, 1], [3], [0, 3]]:
        A = set(A_list)
        s = syndrome(H, A)
        print(f"  syndrome({A}) = {s}")


def demonstrate_capacity_increment():
    """Demonstrate the capacity increment characterization of closure."""
    print("\n" + "=" * 70)
    print("DEMO 4: Capacity Increment ↔ Closure Membership")
    print("=" * 70)

    universe = {0, 1, 2, 3}
    rules = [
        (frozenset({0, 1}), 2),
        (frozenset({1, 2}), 3),
        (frozenset({0}), 1),
    ]

    print(f"\nUniverse: {universe}")
    print(f"Rules: {[(set(p), c) for p, c in rules]}")
    print("\nKey theorem: x ∈ cl(A) ⟹ capIncrement(A, x) = 0")
    print("Testing all (A, x) pairs:\n")

    all_correct = True
    for r in range(len(universe) + 1):
        for subset in itertools.combinations(universe, r):
            A = set(subset)
            cl_A = forward_chaining_closure(rules, A, universe)
            for x in universe:
                inc = capacity_increment(rules, A, x, universe)
                in_closure = x in cl_A
                if in_closure and inc != 0:
                    print(f"  FAILURE: x={x} ∈ cl({A}) but increment = {inc}")
                    all_correct = False
                elif in_closure:
                    print(f"  ✓ x={x} ∈ cl({A}), increment = 0")

    if all_correct:
        print("\n  ✓ All cases confirm: x ∈ cl(A) ⟹ increment = 0")


def demonstrate_syndrome_classes():
    """Show syndrome equivalence classes."""
    print("\n" + "=" * 70)
    print("DEMO 5: Syndrome Equivalence Classes")
    print("=" * 70)

    # Simple 2-row parity check on 4 elements
    H = [
        [1, 1, 0, 0],
        [0, 0, 1, 1],
    ]
    n = len(H[0])
    universe = set(range(n))

    print(f"\nParity-check matrix:")
    for row in H:
        print(f"  {row}")

    # Compute syndrome classes
    classes: Dict[Tuple[int, ...], List[Set[int]]] = {}
    for r in range(n + 1):
        for subset in itertools.combinations(universe, r):
            A = set(subset)
            s = syndrome(H, A)
            classes.setdefault(s, []).append(A)

    print(f"\nSyndrome equivalence classes ({len(classes)} classes):")
    for s, members in sorted(classes.items()):
        print(f"  Syndrome {s}: {[set(m) for m in members]}")

    print("\nKey insight: syndrome classes partition P(X)")
    total = sum(len(v) for v in classes.values())
    print(f"  Total subsets: {total} = 2^{n} = {2**n} ✓")


if __name__ == "__main__":
    demonstrate_closure_operator()
    demonstrate_capacity_submodularity()
    demonstrate_parity_check()
    demonstrate_capacity_increment()
    demonstrate_syndrome_classes()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
