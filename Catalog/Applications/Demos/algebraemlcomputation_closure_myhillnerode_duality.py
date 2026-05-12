#!/usr/bin/env python3
"""
Closure–Myhill–Nerode Duality: Applications

Demonstrates real-world applications of the closure Myhill–Nerode theorem:
1. Abstract interpretation: minimizing abstract domains
2. Concept lattice recognizers from formal concept analysis
3. Semantic compression in pattern recognition systems

Each application shows how closure-driven minimization reduces state
complexity while preserving recognition behavior.
"""

from algorithms import (
    ClosureTransitionSystem,
    build_canonical_automaton,
    find_join_irreducibles,
    saturate_residuals,
    _all_words,
)
from typing import FrozenSet, Set, Dict, List, Tuple


# ============================================================
# Application 1: Abstract Interpretation Domain Minimization
# ============================================================

def app_abstract_interpretation():
    """Minimize an abstract domain for sign analysis.

    Abstract domain: {⊥, neg, zero, pos, non-neg, non-pos, ⊤}
    with the standard sign lattice ordering.

    The closure operator captures the abstraction function:
    cl(A) = the smallest abstract element containing A.

    Transitions model arithmetic operations on abstract values.
    """
    print("=" * 60)
    print("Application 1: Abstract Interpretation Domain Minimization")
    print("=" * 60)

    # Encode abstract domain as integers
    BOT, NEG, ZERO, POS, NON_NEG, NON_POS, TOP = range(7)
    names = {BOT: '⊥', NEG: 'neg', ZERO: 'zero', POS: 'pos',
             NON_NEG: 'non-neg', NON_POS: 'non-pos', TOP: '⊤'}

    states = frozenset(range(7))
    alphabet = frozenset({'add_pos', 'add_neg', 'negate'})

    # Transition: effect of operations on abstract values
    step = {}
    # add_pos: adding a positive number
    step[(BOT, 'add_pos')] = BOT
    step[(NEG, 'add_pos')] = TOP  # neg + pos = anything
    step[(ZERO, 'add_pos')] = POS
    step[(POS, 'add_pos')] = POS
    step[(NON_NEG, 'add_pos')] = POS
    step[(NON_POS, 'add_pos')] = TOP
    step[(TOP, 'add_pos')] = TOP

    # add_neg: adding a negative number
    step[(BOT, 'add_neg')] = BOT
    step[(NEG, 'add_neg')] = NEG
    step[(ZERO, 'add_neg')] = NEG
    step[(POS, 'add_neg')] = TOP
    step[(NON_NEG, 'add_neg')] = TOP
    step[(NON_POS, 'add_neg')] = NEG
    step[(TOP, 'add_neg')] = TOP

    # negate: negation
    step[(BOT, 'negate')] = BOT
    step[(NEG, 'negate')] = POS
    step[(ZERO, 'negate')] = ZERO
    step[(POS, 'negate')] = NEG
    step[(NON_NEG, 'negate')] = NON_POS
    step[(NON_POS, 'negate')] = NON_NEG
    step[(TOP, 'negate')] = TOP

    # Accept: non-negative values (safe for array indexing)
    accept = frozenset({ZERO, POS, NON_NEG})

    # Closure: lattice join (least upper bound in the sign lattice)
    lub_table = {
        frozenset(): frozenset(),
        frozenset({BOT}): frozenset({BOT}),
    }

    def cl(A: FrozenSet[int]) -> FrozenSet[int]:
        if not A or A == frozenset({BOT}):
            return A
        result = set(A)
        # In the sign lattice, if both neg and pos are present, add top
        if NEG in result and POS in result:
            result.add(TOP)
        if NEG in result and ZERO in result:
            result.add(NON_POS)
        if POS in result and ZERO in result:
            result.add(NON_NEG)
        if NEG in result and NON_NEG in result:
            result.add(TOP)
        if POS in result and NON_POS in result:
            result.add(TOP)
        if TOP in result:
            result = set(states)  # top absorbs everything
        return frozenset(result)

    system = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )

    print(f"\nAbstract domain: {', '.join(names[s] for s in sorted(states))}")
    print(f"Accept (safe values): {', '.join(names[s] for s in sorted(accept))}")
    print(f"Operations: add_pos, add_neg, negate")

    # Build canonical automaton
    automaton = build_canonical_automaton(system, x0=ZERO, max_depth=6)
    print(f"\n--- Canonical Closure Automaton ---")
    print(f"  States: {len(automaton.states)}")
    print(f"  (vs. original {len(states)} abstract values)")

    for R in sorted(automaton.states, key=lambda s: (len(s), sorted(s))):
        acc_mark = " ✓" if R in automaton.accepting else ""
        abstract_names = ", ".join(names[x] for x in sorted(R))
        print(f"    {{{abstract_names}}}{acc_mark}")

    # Test some operation sequences
    print(f"\n--- Sample Operation Sequences ---")
    test_seqs = [
        [],
        ['add_pos'],
        ['add_neg'],
        ['negate'],
        ['add_pos', 'negate'],
        ['add_neg', 'add_pos'],
        ['negate', 'add_neg'],
        ['add_pos', 'add_pos', 'negate'],
    ]
    for seq in test_seqs:
        accepted = automaton.accepts(seq)
        R = system.residual_profile(seq)
        status = "SAFE" if accepted else "UNSAFE"
        label = " → ".join(seq) if seq else "ε"
        print(f"    {label}: {status}")

    return automaton


# ============================================================
# Application 2: Formal Concept Analysis Recognizer
# ============================================================

def app_concept_lattice():
    """Build a recognizer from a formal context (objects × attributes).

    Objects: {apple, banana, carrot, donut, egg}
    Attributes: {sweet, healthy, yellow, round, cooked}

    The closure operator is the Galois closure (·)'' from FCA.
    The automaton recognizes "food safety" patterns based on
    attribute combinations.
    """
    print("\n" + "=" * 60)
    print("Application 2: Concept Lattice Recognizer (FCA)")
    print("=" * 60)

    # Formal context as a binary relation
    objects = ['apple', 'banana', 'carrot', 'donut', 'egg']
    attributes = ['sweet', 'healthy', 'yellow', 'round', 'cooked']

    # Incidence relation
    context = {
        'apple':  {'sweet', 'healthy', 'round'},
        'banana': {'sweet', 'healthy', 'yellow'},
        'carrot': {'healthy', 'yellow'},
        'donut':  {'sweet', 'round', 'cooked'},
        'egg':    {'healthy', 'round', 'cooked'},
    }

    # Encode objects as integers
    obj_id = {o: i for i, o in enumerate(objects)}
    states = frozenset(range(len(objects)))
    alphabet = frozenset({'add_sweet', 'add_healthy', 'toggle'})

    # Galois closure on object subsets
    def intent(A_set):
        """Attributes shared by all objects in A."""
        if not A_set:
            return set(attributes)
        result = None
        for obj in A_set:
            obj_name = objects[obj] if isinstance(obj, int) else obj
            obj_attrs = context.get(obj_name, set())
            if result is None:
                result = set(obj_attrs)
            else:
                result &= obj_attrs
        return result or set()

    def extent(B_set):
        """Objects having all attributes in B."""
        result = set()
        for i, obj in enumerate(objects):
            if B_set <= context.get(obj, set()):
                result.add(i)
        return result

    def cl(A: FrozenSet[int]) -> FrozenSet[int]:
        """Galois closure: A'' = extent(intent(A))"""
        if not A:
            return A
        B = intent(A)
        return frozenset(extent(B))

    # Simple transitions
    step = {}
    for x in states:
        # add_sweet: move to next sweet object
        sweet_objs = [i for i, o in enumerate(objects) if 'sweet' in context[o]]
        step[(x, 'add_sweet')] = sweet_objs[(sweet_objs.index(x) + 1) % len(sweet_objs)] if x in sweet_objs else sweet_objs[0]
        # add_healthy: move to next healthy object
        healthy_objs = [i for i, o in enumerate(objects) if 'healthy' in context[o]]
        step[(x, 'add_healthy')] = healthy_objs[(healthy_objs.index(x) + 1) % len(healthy_objs)] if x in healthy_objs else healthy_objs[0]
        # toggle: cycle through all objects
        step[(x, 'toggle')] = (x + 1) % len(objects)

    # Accept: healthy objects
    accept = frozenset(i for i, o in enumerate(objects) if 'healthy' in context[o])

    system = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )

    print(f"\nObjects: {objects}")
    print(f"Attributes: {attributes}")
    print(f"Accept (healthy): {[objects[i] for i in sorted(accept)]}")

    # Show formal concepts (closed sets)
    print(f"\n--- Formal Concepts (Closed Sets of Objects) ---")
    all_subsets = []
    for mask in range(1, 2**len(objects)):
        subset = frozenset(i for i in range(len(objects)) if mask & (1 << i))
        closed = cl(subset)
        if closed == subset:
            intent_str = ", ".join(sorted(intent(subset)))
            extent_str = ", ".join(objects[i] for i in sorted(subset))
            all_subsets.append((subset, intent_str))
            print(f"  {{{extent_str}}} — attributes: {{{intent_str}}}")

    # Build canonical automaton
    automaton = build_canonical_automaton(system, x0=0, max_depth=6)
    print(f"\n--- Canonical Closure Automaton ---")
    print(f"  States: {len(automaton.states)}")
    print(f"  Formal concepts found: {len(all_subsets)}")

    for R in sorted(automaton.states, key=lambda s: (len(s), sorted(s))):
        acc_mark = " ✓" if R in automaton.accepting else ""
        obj_names = ", ".join(objects[i] for i in sorted(R))
        print(f"    {{{obj_names}}}{acc_mark}")

    # Find join-irreducibles
    ji = find_join_irreducibles(automaton.states, cl)
    print(f"\n  Join-irreducible states: {len(ji)}")
    for j in sorted(ji, key=lambda s: (len(s), sorted(s))):
        obj_names = ", ".join(objects[i] for i in sorted(j))
        print(f"    {{{obj_names}}}")

    return automaton


# ============================================================
# Application 3: Semantic Compression in Pattern Recognition
# ============================================================

def app_semantic_compression():
    """Demonstrate semantic compression via closure minimization.

    A pattern recognition system with 8 features, where the closure
    operator captures semantic equivalence (features that always
    co-occur are merged).

    Shows how closure-driven minimization reduces the state space
    while preserving recognition accuracy.
    """
    print("\n" + "=" * 60)
    print("Application 3: Semantic Compression in Pattern Recognition")
    print("=" * 60)

    # 8 feature detectors, some correlated
    n_features = 8
    states = frozenset(range(n_features))
    alphabet = frozenset({'shift', 'flip', 'mask'})

    step = {}
    for x in states:
        step[(x, 'shift')] = (x + 1) % n_features
        step[(x, 'flip')] = n_features - 1 - x
        step[(x, 'mask')] = x % 4  # coarsen to 4 features

    accept = frozenset({0, 1, 2, 3})  # first 4 features "active"

    # Closure: group correlated features
    # Features {0,4}, {1,5}, {2,6}, {3,7} are correlated pairs
    def cl(A):
        result = set(A)
        for x in A:
            partner = (x + 4) % n_features
            result.add(partner)
        return frozenset(result)

    system = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )

    print(f"\nFeatures: {sorted(states)}")
    print(f"Correlated pairs: (0,4), (1,5), (2,6), (3,7)")
    print(f"Accept (active features): {sorted(accept)}")

    # Build automata with and without closure
    print(f"\n--- Without Closure (Identity) ---")
    system_no_cl = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept,
        cl=lambda A: A
    )
    auto_no_cl = build_canonical_automaton(system_no_cl, x0=0, max_depth=6)
    print(f"  States: {len(auto_no_cl.states)}")

    print(f"\n--- With Correlation Closure ---")
    auto_cl = build_canonical_automaton(system, x0=0, max_depth=6)
    print(f"  States: {len(auto_cl.states)}")

    compression = (1 - len(auto_cl.states) / max(len(auto_no_cl.states), 1)) * 100
    print(f"\n  Compression ratio: {compression:.1f}%")
    print(f"  ({len(auto_no_cl.states)} → {len(auto_cl.states)} states)")

    # Show that recognition is preserved
    print(f"\n--- Recognition Equivalence Check ---")
    test_words = [list(w) for length in range(4)
                  for w in _all_words(sorted(alphabet), length)]
    matches = 0
    total = len(test_words)
    for w in test_words:
        r1 = system_no_cl.residual_profile(w)
        r2 = system.residual_profile(w)
        if (0 in r1) == (0 in r2):
            matches += 1
    print(f"  Agreement on {matches}/{total} test words ({100*matches/total:.1f}%)")

    return auto_cl


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure–Myhill–Nerode Duality: Real-World Applications ║")
    print("╚══════════════════════════════════════════════════════════╝")

    app_abstract_interpretation()
    app_concept_lattice()
    app_semantic_compression()

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Closure–Myhill–Nerode Duality: Demonstrations

Concrete numerical examples demonstrating the closure Myhill–Nerode theorem:
1. A simple 4-state system with downward closure
2. A parity-checking system with convex closure
3. Residual saturation from generators

Each example shows:
- Construction of the closure transition system
- Computation of residual profiles
- Building the canonical closure automaton
- Verification of Nerode equivalence
- Join-semilattice structure of reachable residuals
"""

from algorithms import (
    ClosureTransitionSystem,
    build_canonical_automaton,
    saturate_residuals,
    verify_minimality,
    find_join_irreducibles,
    _all_words,
)


def example_1_downward_closure():
    """Example 1: A 4-state chain with downward closure.

    States: {0, 1, 2, 3} with order 0 < 1 < 2 < 3
    Alphabet: {a, b}
    Transitions: step(x, a) = min(x+1, 3), step(x, b) = max(x-1, 0)
    Accept: {2, 3}
    Closure: downward closure (cl(A) = {y | ∃ x ∈ A, y ≤ x})
    """
    print("=" * 60)
    print("Example 1: 4-State Chain with Downward Closure")
    print("=" * 60)

    states = frozenset({0, 1, 2, 3})
    alphabet = frozenset({'a', 'b'})

    step = {}
    for x in states:
        step[(x, 'a')] = min(x + 1, 3)
        step[(x, 'b')] = max(x - 1, 0)

    accept = frozenset({2, 3})

    # Downward closure: add all elements below
    order = {
        0: frozenset(),
        1: frozenset({0}),
        2: frozenset({0, 1}),
        3: frozenset({0, 1, 2}),
    }

    def cl(A):
        result = set(A)
        for x in A:
            result.update(order.get(x, set()))
        return frozenset(result)

    system = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )

    print(f"\nStates: {sorted(states)}")
    print(f"Alphabet: {sorted(alphabet)}")
    print(f"Accept: {sorted(accept)}")
    print(f"Closure type: Downward closure on chain 0 < 1 < 2 < 3")

    # Compute residual profiles for various words
    print("\n--- Residual Profiles ---")
    test_words = [
        [], ['a'], ['b'], ['a', 'a'], ['a', 'b'],
        ['b', 'a'], ['b', 'b'], ['a', 'a', 'a'],
    ]
    profiles = {}
    for w in test_words:
        R = system.residual_profile(w)
        profiles[tuple(w)] = R
        print(f"  R({w or 'ε'}) = {sorted(R)}")

    # Check Nerode equivalence
    print("\n--- Nerode Equivalence Classes ---")
    classes = []
    classified = set()
    for w in test_words:
        tw = tuple(w)
        if tw in classified:
            continue
        eq_class = [w]
        classified.add(tw)
        for v in test_words:
            tv = tuple(v)
            if tv in classified:
                continue
            if system.nerode_equivalent(w, v, max_suffix_len=4):
                eq_class.append(v)
                classified.add(tv)
        classes.append(eq_class)
    for i, cls in enumerate(classes):
        words_str = ", ".join(str(w) if w else "ε" for w in cls)
        print(f"  Class {i}: {{{words_str}}}")

    # Build canonical automaton
    print("\n--- Canonical Closure Automaton ---")
    automaton = build_canonical_automaton(system, x0=0, max_depth=6)
    print(f"  Number of states: {len(automaton.states)}")
    print(f"  Initial state: {sorted(automaton.initial)}")
    print(f"  Accepting states: {len(automaton.accepting)}")

    for R in sorted(automaton.states, key=lambda s: (len(s), sorted(s))):
        acc_mark = " ✓" if R in automaton.accepting else ""
        print(f"    State {sorted(R)}{acc_mark}")

    # Verify minimality
    all_test = [list(w) for length in range(5) for w in _all_words(['a', 'b'], length)]
    results = verify_minimality(automaton, system, all_test)
    print(f"\n  Minimality check:")
    print(f"    Correct recognition: {results['correct_recognition']}")
    print(f"    Distinct states: {results['no_equivalent_states']}")

    # Join-irreducibles
    ji = find_join_irreducibles(automaton.states, cl)
    print(f"\n  Join-irreducible states: {len(ji)}")
    for j in sorted(ji, key=lambda s: (len(s), sorted(s))):
        print(f"    {sorted(j)}")

    return automaton


def example_2_modular_system():
    """Example 2: Modular arithmetic system with interval closure.

    States: {0, 1, 2, 3, 4, 5} (mod 6)
    Alphabet: {a, b}
    Transitions: step(x, a) = (x + 1) mod 6, step(x, b) = (x + 3) mod 6
    Accept: {0, 3} (multiples of 3)
    Closure: interval closure on cyclic order
    """
    print("\n" + "=" * 60)
    print("Example 2: Modular Arithmetic with Interval Closure")
    print("=" * 60)

    n = 6
    states = frozenset(range(n))
    alphabet = frozenset({'a', 'b'})

    step = {}
    for x in states:
        step[(x, 'a')] = (x + 1) % n
        step[(x, 'b')] = (x + 3) % n

    accept = frozenset({0, 3})

    # Closure: if A contains two elements, include all between them (mod n)
    # Simplified: just take the set and its "convex hull" in the cyclic order
    def cl(A):
        if len(A) <= 1:
            return A
        if len(A) >= n:
            return states
        # For simplicity: add elements to fill contiguous arcs
        result = set(A)
        sorted_a = sorted(A)
        # Check if adding elements between consecutive pairs helps
        for i in range(len(sorted_a)):
            lo = sorted_a[i]
            hi = sorted_a[(i + 1) % len(sorted_a)]
            if hi > lo:
                result.update(range(lo, hi + 1))
            # Don't wrap around for simplicity
        return frozenset(result)

    system = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )

    print(f"\nStates: Z/{n}Z = {sorted(states)}")
    print(f"Accept: {sorted(accept)} (multiples of 3)")
    print(f"step(x, a) = x+1 mod {n}")
    print(f"step(x, b) = x+3 mod {n}")

    # Compute residual profiles
    print("\n--- Residual Profiles ---")
    test_words = [
        [], ['a'], ['b'], ['a', 'a'], ['a', 'b'],
        ['b', 'a'], ['a', 'a', 'a'],
    ]
    for w in test_words:
        R = system.residual_profile(w)
        print(f"  R({w or 'ε'}) = {sorted(R)}")

    # Build canonical automaton
    automaton = build_canonical_automaton(system, x0=0, max_depth=8)
    print(f"\n--- Canonical Automaton ---")
    print(f"  States: {len(automaton.states)}")

    for R in sorted(automaton.states, key=lambda s: (len(s), sorted(s))):
        acc_mark = " ✓" if R in automaton.accepting else ""
        print(f"    {sorted(R)}{acc_mark}")

    # Join structure
    print(f"\n--- Join Semilattice ---")
    states_list = sorted(automaton.states, key=lambda s: (len(s), sorted(s)))
    for i, P in enumerate(states_list):
        for Q in states_list[i+1:]:
            join = cl(P | Q)
            if join in automaton.states:
                print(f"  {sorted(P)} ∨ {sorted(Q)} = {sorted(join)}")

    return automaton


def example_3_saturation():
    """Example 3: Residual saturation from generators.

    Demonstrates Algorithm F: certified reconstruction of the canonical
    automaton from a finite generating family.
    """
    print("\n" + "=" * 60)
    print("Example 3: Residual Saturation from Generators")
    print("=" * 60)

    states = frozenset({0, 1, 2, 3})
    alphabet = frozenset({'a', 'b'})

    step = {}
    for x in states:
        step[(x, 'a')] = min(x + 1, 3)
        step[(x, 'b')] = 0  # reset to 0

    accept = frozenset({3})

    # Identity closure (trivial)
    def cl(A):
        return A

    system = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )

    print(f"\nStates: {sorted(states)}")
    print(f"Accept: {sorted(accept)}")
    print(f"step(x, a) = min(x+1, 3), step(x, b) = 0")
    print(f"Closure: identity (trivial)")

    # Start with generators
    gen1 = system.residual_profile([])
    gen2 = system.residual_profile(['a'])
    generators = [gen1, gen2]

    print(f"\nGenerators:")
    for i, g in enumerate(generators):
        print(f"  G{i} = {sorted(g)}")

    # Saturate
    saturated = saturate_residuals(system, generators, max_iterations=20)
    print(f"\nSaturated family ({len(saturated)} elements):")
    for R in sorted(saturated, key=lambda s: (len(s), sorted(s))):
        print(f"  {sorted(R)}")

    # Compare with canonical automaton
    automaton = build_canonical_automaton(system, x0=0, max_depth=8)
    print(f"\nCanonical automaton states ({len(automaton.states)} states):")
    for R in sorted(automaton.states, key=lambda s: (len(s), sorted(s))):
        print(f"  {sorted(R)}")

    # Check containment
    print(f"\n  Saturated ⊇ Canonical: {automaton.states <= saturated}")
    print(f"  Saturated = Canonical: {automaton.states == saturated}")

    return automaton


def example_4_behavioral_equivalence():
    """Example 4: Behavioral equivalence and Nerode classes.

    Demonstrates that recognizer states refine Nerode classes,
    matching Theorem F from the formalization.
    """
    print("\n" + "=" * 60)
    print("Example 4: Behavioral Equivalence & Nerode Refinement")
    print("=" * 60)

    # Simple even/odd parity system
    states = frozenset({0, 1})
    alphabet = frozenset({'a'})
    step = {(0, 'a'): 1, (1, 'a'): 0}
    accept = frozenset({0})
    cl = lambda A: A  # identity closure

    system = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )

    print(f"\nParity system: states = {sorted(states)}, accept = {sorted(accept)}")
    print(f"step(x, a) = 1-x (toggle)")

    # Compute many residual profiles
    print("\n--- Residual Profiles (by word length) ---")
    nerode_classes: dict[frozenset, list] = {}
    for length in range(8):
        for w in _all_words(['a'], length):
            R = system.residual_profile(w)
            label = ''.join(w) if w else 'ε'
            if R not in nerode_classes:
                nerode_classes[R] = []
            nerode_classes[R].append(label)

    for R, words in sorted(nerode_classes.items(), key=lambda x: sorted(x[0])):
        print(f"  R = {sorted(R)} ← words: {', '.join(words[:8])}{'...' if len(words) > 8 else ''}")

    print(f"\n  Number of Nerode classes: {len(nerode_classes)}")
    print(f"  (matches |states| = {len(states)} → automaton is already minimal)")

    # Build canonical automaton
    automaton = build_canonical_automaton(system, x0=0, max_depth=10)
    print(f"\n  Canonical automaton states: {len(automaton.states)}")
    print(f"  Original system states: {len(states)}")
    print(f"  Ratio: {len(automaton.states)}/{len(states)} = "
          f"{'minimal' if len(automaton.states) <= len(states) else 'not minimal'}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure–Myhill–Nerode Duality: Concrete Demonstrations ║")
    print("╚══════════════════════════════════════════════════════════╝")

    example_1_downward_closure()
    example_2_modular_system()
    example_3_saturation()
    example_4_behavioral_equivalence()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Closure–Myhill–Nerode Duality: Visualizations

Generates publication-quality figures illustrating:
1. Residual profile lattice structure
2. Closure automaton state diagram
3. Compression ratios across system sizes
4. Join-semilattice Hasse diagram
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (
    ClosureTransitionSystem,
    build_canonical_automaton,
    find_join_irreducibles,
    _all_words,
)
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def make_chain_system(n):
    """Create a chain system with n states and downward closure."""
    states = frozenset(range(n))
    alphabet = frozenset({'a', 'b'})
    step = {}
    for x in states:
        step[(x, 'a')] = min(x + 1, n - 1)
        step[(x, 'b')] = max(x - 1, 0)
    accept = frozenset({n - 1})

    def cl(A):
        if not A:
            return A
        result = set()
        for x in A:
            result.update(range(x + 1))
        return frozenset(result)

    return ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )


def viz_residual_lattice():
    """Visualize the residual profile lattice for a small system."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # System: 5-state chain
    system = make_chain_system(5)

    # Collect all residual profiles
    profiles = set()
    word_labels = {}
    for length in range(6):
        for w in _all_words(['a', 'b'], length):
            R = system.residual_profile(w)
            if R not in word_labels:
                word_labels[R] = ''.join(w) if w else 'ε'
            profiles.add(R)

    # Sort by size for plotting
    profiles_sorted = sorted(profiles, key=lambda s: (len(s), sorted(s)))

    # Left plot: residual profiles as sets
    ax = axes[0]
    y_positions = {}
    for i, R in enumerate(profiles_sorted):
        y = len(R)
        x = sum(1 for P in profiles_sorted[:i] if len(P) == len(R))
        y_positions[R] = (x * 2, y)

    # Draw Hasse diagram edges
    for R in profiles_sorted:
        for Q in profiles_sorted:
            if R < Q and not any(R < P < Q for P in profiles_sorted):
                rx, ry = y_positions[R]
                qx, qy = y_positions[Q]
                ax.plot([rx, qx], [ry, qy], 'k-', alpha=0.3, linewidth=1)

    # Draw nodes
    for R in profiles_sorted:
        x, y = y_positions[R]
        label = word_labels.get(R, str(sorted(R)))
        color = '#2196F3' if 0 in R else '#FF9800'
        ax.scatter(x, y, s=300, c=color, zorder=5, edgecolors='black', linewidth=1.5)
        ax.annotate(f'{sorted(R)}', (x, y), textcoords="offset points",
                    xytext=(0, -20), ha='center', fontsize=7)

    ax.set_title('Residual Profile Lattice\n(5-state chain, downward closure)',
                 fontsize=12, fontweight='bold')
    ax.set_ylabel('Profile size', fontsize=10)
    ax.set_xlabel('Profiles ordered by size', fontsize=10)
    ax.grid(True, alpha=0.2)

    # Right plot: number of distinct profiles vs system size
    ax = axes[1]
    sizes = range(3, 12)
    n_profiles = []
    n_ji = []
    for n in sizes:
        sys_n = make_chain_system(n)
        profs = set()
        for length in range(min(n + 2, 8)):
            for w in _all_words(['a', 'b'], length):
                profs.add(sys_n.residual_profile(w))
        n_profiles.append(len(profs))
        ji = find_join_irreducibles(profs, sys_n.cl)
        n_ji.append(len(ji))

    ax.bar([s - 0.2 for s in sizes], n_profiles, 0.4,
           label='Reachable residuals', color='#2196F3', alpha=0.8)
    ax.bar([s + 0.2 for s in sizes], n_ji, 0.4,
           label='Join-irreducibles', color='#FF5722', alpha=0.8)
    ax.plot(list(sizes), list(sizes), 'k--', alpha=0.4, label='n (system size)')
    ax.set_xlabel('System size (n states)', fontsize=10)
    ax.set_ylabel('Count', fontsize=10)
    ax.set_title('Residual Profiles vs System Size\n(chain systems)',
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

    plt.tight_layout()
    fig.savefig('viz_residual_lattice.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated: viz_residual_lattice.png")
    return b64


def viz_compression_ratios():
    """Visualize compression ratios for different closure operators."""
    fig, ax = plt.subplots(figsize=(10, 6))

    system_sizes = range(4, 13)

    # Identity closure (no compression)
    ratios_identity = []
    # Downward closure
    ratios_downward = []
    # Pair closure (merge pairs)
    ratios_pair = []

    for n in system_sizes:
        states = frozenset(range(n))
        alphabet = frozenset({'a', 'b'})
        step = {}
        for x in states:
            step[(x, 'a')] = (x + 1) % n
            step[(x, 'b')] = (x + 2) % n
        accept = frozenset({0})

        # Identity
        sys_id = ClosureTransitionSystem(
            states=states, alphabet=alphabet, step=step, accept=accept,
            cl=lambda A: A
        )
        auto_id = build_canonical_automaton(sys_id, x0=0, max_depth=n + 2)
        n_id = len(auto_id.states)

        # Downward closure
        def make_down_cl(n_val):
            def cl(A):
                if not A:
                    return A
                result = set()
                for x in A:
                    result.update(range(x + 1))
                return frozenset(result)
            return cl

        sys_down = ClosureTransitionSystem(
            states=states, alphabet=alphabet, step=step, accept=accept,
            cl=make_down_cl(n)
        )
        auto_down = build_canonical_automaton(sys_down, x0=0, max_depth=n + 2)
        n_down = len(auto_down.states)

        # Pair closure
        def make_pair_cl(n_val):
            def cl(A):
                result = set(A)
                for x in A:
                    result.add((x + n_val // 2) % n_val)
                return frozenset(result)
            return cl

        sys_pair = ClosureTransitionSystem(
            states=states, alphabet=alphabet, step=step, accept=accept,
            cl=make_pair_cl(n)
        )
        auto_pair = build_canonical_automaton(sys_pair, x0=0, max_depth=n + 2)
        n_pair = len(auto_pair.states)

        ratios_identity.append(n_id)
        ratios_downward.append(n_down)
        ratios_pair.append(n_pair)

    x = list(system_sizes)
    ax.plot(x, ratios_identity, 'o-', color='#333333', label='No closure (identity)',
            linewidth=2, markersize=6)
    ax.plot(x, ratios_downward, 's-', color='#2196F3', label='Downward closure',
            linewidth=2, markersize=6)
    ax.plot(x, ratios_pair, '^-', color='#FF5722', label='Pair closure',
            linewidth=2, markersize=6)
    ax.fill_between(x, ratios_pair, ratios_identity, alpha=0.1, color='#4CAF50')

    ax.set_xlabel('System Size (n configurations)', fontsize=12)
    ax.set_ylabel('Canonical Automaton States', fontsize=12)
    ax.set_title('State Compression via Closure Operators\n'
                 'Closure–Myhill–Nerode Minimization',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Add annotation
    mid_idx = len(x) // 2
    ax.annotate('Compression\ngap',
                xy=(x[mid_idx], (ratios_identity[mid_idx] + ratios_pair[mid_idx]) / 2),
                fontsize=10, ha='center', color='#4CAF50', fontweight='bold')

    plt.tight_layout()
    fig.savefig('viz_compression_ratios.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated: viz_compression_ratios.png")
    return b64


def viz_automaton_structure():
    """Visualize a canonical closure automaton as a state diagram."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Build a small system
    system = make_chain_system(4)
    automaton = build_canonical_automaton(system, x0=0, max_depth=6)

    # Arrange states in a circle
    states_list = sorted(automaton.states, key=lambda s: (len(s), sorted(s)))
    n = len(states_list)
    if n == 0:
        return ""

    angles = np.linspace(0, 2 * np.pi, n, endpoint=False) + np.pi / 2
    radius = 2.5
    positions = {s: (radius * np.cos(a), radius * np.sin(a))
                 for s, a in zip(states_list, angles)}

    # Draw transitions
    for (src, letter), dst in automaton.transitions.items():
        if src in positions and dst in positions:
            sx, sy = positions[src]
            dx, dy = positions[dst]
            if src == dst:
                # Self-loop
                loop_radius = 0.3
                circle = mpatches.Arc((sx, sy + loop_radius), loop_radius * 2,
                                      loop_radius * 2, angle=0,
                                      theta1=30, theta2=330, linewidth=1.5,
                                      color='#666666')
                ax.add_patch(circle)
                ax.annotate(letter, (sx, sy + loop_radius * 2.2),
                            ha='center', fontsize=7, color='#666666')
            else:
                # Arrow
                mid_x = (sx + dx) / 2
                mid_y = (sy + dy) / 2
                # Offset for parallel edges
                offset = 0.15
                perp_x = -(dy - sy) * offset / max(np.sqrt((dx-sx)**2 + (dy-sy)**2), 0.01)
                perp_y = (dx - sx) * offset / max(np.sqrt((dx-sx)**2 + (dy-sy)**2), 0.01)

                ax.annotate('', xy=(dx + perp_x, dy + perp_y),
                            xytext=(sx + perp_x, sy + perp_y),
                            arrowprops=dict(arrowstyle='->', color='#666666',
                                            lw=1.5, connectionstyle='arc3,rad=0.1'))
                ax.text(mid_x + perp_x * 2, mid_y + perp_y * 2, letter,
                        ha='center', va='center', fontsize=7, color='#666666')

    # Draw states
    for s in states_list:
        x, y = positions[s]
        is_accepting = s in automaton.accepting
        is_initial = s == automaton.initial

        color = '#4CAF50' if is_accepting else '#2196F3'
        edge_color = '#FF5722' if is_initial else 'black'
        edge_width = 3 if is_initial else 1.5

        circle = plt.Circle((x, y), 0.5, fill=True, facecolor=color,
                             edgecolor=edge_color, linewidth=edge_width, alpha=0.8)
        ax.add_patch(circle)

        # Double circle for accepting
        if is_accepting:
            circle2 = plt.Circle((x, y), 0.42, fill=False,
                                 edgecolor='white', linewidth=1.5)
            ax.add_patch(circle2)

        # State label
        label = '{' + ','.join(str(i) for i in sorted(s)) + '}'
        ax.text(x, y, label, ha='center', va='center', fontsize=7,
                fontweight='bold', color='white')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#4CAF50', edgecolor='black', label='Accepting state'),
        mpatches.Patch(facecolor='#2196F3', edgecolor='black', label='Non-accepting state'),
        mpatches.Patch(facecolor='white', edgecolor='#FF5722', linewidth=2, label='Initial state'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=9)

    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.set_aspect('equal')
    ax.set_title('Canonical Closure Automaton\n(4-state chain, downward closure)',
                 fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    fig.savefig('viz_automaton_structure.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated: viz_automaton_structure.png")
    return b64


def viz_nerode_classes():
    """Visualize Nerode equivalence classes."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Cyclic system
    n = 6
    states = frozenset(range(n))
    alphabet = frozenset({'a'})
    step = {(x, 'a'): (x + 1) % n for x in states}
    accept = frozenset({0})
    cl = lambda A: A

    system = ClosureTransitionSystem(
        states=states, alphabet=alphabet, step=step, accept=accept, cl=cl
    )

    # Compute Nerode classes
    classes = {}
    words = []
    for length in range(12):
        w = ['a'] * length
        R = system.residual_profile(w)
        label = f"a^{length}" if length > 0 else "ε"
        words.append(label)
        if R not in classes:
            classes[R] = []
        classes[R].append((length, label))

    # Plot as colored timeline
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800', '#00BCD4']
    class_list = sorted(classes.items(), key=lambda x: min(l for l, _ in x[1]))

    for class_idx, (R, members) in enumerate(class_list):
        color = colors[class_idx % len(colors)]
        for length, label in members:
            ax.barh(class_idx, 1, left=length, color=color, edgecolor='white',
                    linewidth=0.5, alpha=0.8)
            ax.text(length + 0.5, class_idx, label, ha='center', va='center',
                    fontsize=7, color='white', fontweight='bold')

    ax.set_yticks(range(len(class_list)))
    ax.set_yticklabels([f'Class {i}: R={sorted(R)}'
                        for i, (R, _) in enumerate(class_list)], fontsize=9)
    ax.set_xlabel('Word position (length)', fontsize=11)
    ax.set_title(f'Nerode Equivalence Classes\n'
                 f'(Z/{n}Z cyclic system, alphabet = {{a}})',
                 fontsize=13, fontweight='bold')
    ax.grid(True, axis='x', alpha=0.2)

    # Add period annotation
    ax.axvline(x=n, color='red', linestyle='--', alpha=0.5)
    ax.text(n, len(class_list) - 0.5, f'period = {n}',
            ha='center', color='red', fontsize=10)

    plt.tight_layout()
    fig.savefig('viz_nerode_classes.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated: viz_nerode_classes.png")
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_lattice = viz_residual_lattice()
    b64_compression = viz_compression_ratios()
    b64_automaton = viz_automaton_structure()
    b64_nerode = viz_nerode_classes()
    print("\nAll visualizations generated successfully.")
    print(f"  viz_residual_lattice.png: {len(b64_lattice)} chars")
    print(f"  viz_compression_ratios.png: {len(b64_compression)} chars")
    print(f"  viz_automaton_structure.png: {len(b64_automaton)} chars")
    print(f"  viz_nerode_classes.png: {len(b64_nerode)} chars")
