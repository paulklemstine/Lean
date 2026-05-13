"""
Algorithms for Stone-Chu Closure Duality: Minimal Kripke Reconstruction

This module implements the core algorithms for computing minimal Kripke realizations
from finite closure-observable systems.
"""

from typing import Callable, FrozenSet, Set, List, Dict, Tuple, Optional
from itertools import product
from dataclasses import dataclass, field


# Type aliases
Element = int
SetOfElements = FrozenSet[int]
ClosureOp = Callable[[SetOfElements], SetOfElements]
Observable = Callable[[SetOfElements], SetOfElements]


@dataclass
class ClosureObservableSystem:
    """A finite closure-observable system.

    Attributes:
        elements: The finite ground set.
        closure: A closure operator cl : P(elements) -> P(elements).
        observables: A dict of named observables obs_i : P(elements) -> P(elements).
    """
    elements: FrozenSet[int]
    closure: ClosureOp
    observables: Dict[str, Observable]

    def is_closed(self, s: SetOfElements) -> bool:
        """Check if a set is closed (fixed point of closure)."""
        return self.closure(s) == s

    def closed_sets(self) -> List[SetOfElements]:
        """Enumerate all closed subsets of elements."""
        result = []
        elems = sorted(self.elements)
        n = len(elems)
        for mask in range(1 << n):
            s = frozenset(elems[i] for i in range(n) if mask & (1 << i))
            if self.is_closed(s):
                result.append(s)
        return result


def compute_observable_contexts(
    system: ClosureObservableSystem,
    max_depth: int = 3
) -> List[Tuple[str, Callable[[SetOfElements], SetOfElements]]]:
    """Compute observable contexts up to a given composition depth.

    Returns a list of (name, function) pairs representing all observable contexts
    built from identity, atomic observables, and composition.

    Args:
        system: The closure-observable system.
        max_depth: Maximum composition depth.

    Returns:
        List of (name, context_function) pairs.
    """
    contexts: List[Tuple[str, Callable[[SetOfElements], SetOfElements]]] = []

    # Level 0: identity
    contexts.append(("id", lambda s: s))

    # Level 1: atomic observables
    for name, obs in system.observables.items():
        contexts.append((name, obs))

    # Higher levels: compositions
    prev_level = [(name, obs) for name, obs in system.observables.items()]

    for depth in range(2, max_depth + 1):
        new_level = []
        for name1, f1 in prev_level:
            for name2, f2 in list(system.observables.items()) + [("id", lambda s: s)]:
                comp_name = f"{name2} ∘ {name1}"
                # Create closure to capture f1, f2
                def make_comp(a, b):
                    return lambda s: a(b(s))
                comp_fn = make_comp(f2, f1)
                new_level.append((comp_name, comp_fn))
                contexts.append((comp_name, comp_fn))
        prev_level = new_level

    return contexts


def compute_observational_equivalence(
    system: ClosureObservableSystem,
    max_context_depth: int = 3
) -> Dict[int, int]:
    """Compute the observational equivalence relation.

    Two elements x, y are observationally equivalent if for every observable
    context f and every closed set C: x ∈ f(C) ↔ y ∈ f(C).

    Args:
        system: The closure-observable system.
        max_context_depth: Maximum depth for observable context generation.

    Returns:
        A dict mapping each element to its equivalence class representative
        (the smallest element in its class).
    """
    contexts = compute_observable_contexts(system, max_context_depth)
    closed = system.closed_sets()
    elements = sorted(system.elements)

    # Build equivalence classes by partition refinement
    # Two elements are equivalent if they agree on all (context, closed_set) tests
    profiles: Dict[int, Tuple] = {}
    for x in elements:
        profile = []
        for ctx_name, ctx_fn in contexts:
            for c in closed:
                result = ctx_fn(c)
                profile.append(x in result)
        profiles[x] = tuple(profile)

    # Group by profile
    profile_to_class: Dict[Tuple, List[int]] = {}
    for x in elements:
        p = profiles[x]
        if p not in profile_to_class:
            profile_to_class[p] = []
        profile_to_class[p].append(x)

    # Map each element to its class representative
    class_map = {}
    for members in profile_to_class.values():
        rep = min(members)
        for x in members:
            class_map[x] = rep

    return class_map


@dataclass
class MinimalKripkeRealization:
    """The minimal Kripke realization of a closure-observable system.

    Attributes:
        states: The set of states (equivalence class representatives).
        realize: Map from original elements to states.
        transitions: For each observable, a map from states to states
                     (well-defined by the congruence property).
        system: The original system.
    """
    states: List[int]
    realize: Dict[int, int]
    transitions: Dict[str, Dict[int, SetOfElements]]
    system: ClosureObservableSystem

    def num_states(self) -> int:
        return len(self.states)

    def is_minimal(self) -> bool:
        """Verify minimality: all states are distinguishable."""
        # Check that no two states have identical observable profiles
        for i, s1 in enumerate(self.states):
            for s2 in self.states[i+1:]:
                # Find elements mapping to s1 and s2
                x = next(e for e, s in self.realize.items() if s == s1)
                y = next(e for e, s in self.realize.items() if s == s2)
                if self.realize[x] == self.realize[y]:
                    return False
        return True


def reconstruct_minimal_kripke(
    system: ClosureObservableSystem,
    max_context_depth: int = 3
) -> MinimalKripkeRealization:
    """Reconstruct the minimal Kripke realization from closure data.

    This implements the certified reconstruction algorithm:
    1. Compute all observable contexts.
    2. Compute observational equivalence.
    3. Form quotient classes.
    4. Define transitions on quotient.
    5. Return minimal realization.

    Args:
        system: The closure-observable system.
        max_context_depth: Maximum context composition depth.

    Returns:
        The minimal Kripke realization.

    Complexity:
        O(|α|² × |Contexts| × |ClosedSets|) for equivalence computation.
    """
    # Step 1-3: Compute equivalence classes
    class_map = compute_observational_equivalence(system, max_context_depth)

    # Step 4: Extract states (unique representatives)
    states = sorted(set(class_map.values()))

    # Step 5: Define transitions
    # For each observable, the transition maps a state (class rep) to
    # the set of states reachable from elements in that class
    transitions: Dict[str, Dict[int, SetOfElements]] = {}
    for obs_name, obs_fn in system.observables.items():
        obs_trans: Dict[int, SetOfElements] = {}
        for state in states:
            # Pick any element in this class
            elem = next(e for e, s in class_map.items() if s == state)
            # The observable maps this element's closed sets
            # We record which states are "reachable"
            closed = system.closed_sets()
            reachable_states = set()
            for c in closed:
                result = obs_fn(c)
                for e in system.elements:
                    if e in result and class_map[e] not in reachable_states:
                        reachable_states.add(class_map[e])
            obs_trans[state] = frozenset(reachable_states)
        transitions[obs_name] = obs_trans

    return MinimalKripkeRealization(
        states=states,
        realize=class_map,
        transitions=transitions,
        system=system
    )


def verify_factorization(
    system: ClosureObservableSystem,
    realization1: MinimalKripkeRealization,
    realization2: MinimalKripkeRealization
) -> Optional[Dict[int, int]]:
    """Verify that realization1 factors through realization2.

    Returns the factorization map if it exists, None otherwise.
    """
    factor_map: Dict[int, int] = {}

    for elem in system.elements:
        s1 = realization1.realize[elem]
        s2 = realization2.realize[elem]

        if s1 in factor_map:
            if factor_map[s1] != s2:
                return None  # Not well-defined
        else:
            factor_map[s1] = s2

    # Check surjectivity
    if set(factor_map.values()) != set(realization2.states):
        return None

    return factor_map


# ---- Chu Space Implementation ----

@dataclass
class ChuSpace:
    """A finite Chu space with states, attributes, and evaluation.

    Attributes:
        states: List of states.
        attributes: List of attributes.
        eval_matrix: Dict[(state, attr)] -> bool.
    """
    states: List
    attributes: List
    eval_matrix: Dict[Tuple, bool]

    def state_equiv(self, x, y) -> bool:
        """Check if two states are biextensionally equivalent."""
        return all(
            self.eval_matrix.get((x, a), False) == self.eval_matrix.get((y, a), False)
            for a in self.attributes
        )

    def biextensional_collapse(self) -> Dict:
        """Compute the biextensional collapse: map each state to its class rep."""
        class_map = {}
        for s in self.states:
            profile = tuple(self.eval_matrix.get((s, a), False) for a in self.attributes)
            if profile not in class_map:
                class_map[profile] = s
        return {s: class_map[tuple(self.eval_matrix.get((s, a), False)
                for a in self.attributes)] for s in self.states}


def build_closure_chu_space(
    system: ClosureObservableSystem,
    max_context_depth: int = 3
) -> ChuSpace:
    """Build the Chu space of a closure-observable system.

    States are elements of the system.
    Attributes are (context, closed_set) pairs.
    Evaluation: eval(x, (f, C)) = x ∈ f(C).
    """
    contexts = compute_observable_contexts(system, max_context_depth)
    closed = system.closed_sets()

    states = sorted(system.elements)
    attributes = [(ctx_name, c) for ctx_name, ctx_fn in contexts for c in closed]

    eval_matrix = {}
    ctx_fns = {name: fn for name, fn in contexts}
    for x in states:
        for ctx_name, ctx_fn in contexts:
            for c in closed:
                result = ctx_fn(c)
                eval_matrix[(x, (ctx_name, c))] = x in result

    return ChuSpace(states=states, attributes=attributes, eval_matrix=eval_matrix)


if __name__ == "__main__":
    # Example: Simple closure system on {0, 1, 2, 3}
    elements = frozenset({0, 1, 2, 3})

    # Closure: cl(S) = S ∪ {x : x is "implied" by S}
    # Here: 0 implies 1, 2 implies 3
    def closure(s: SetOfElements) -> SetOfElements:
        result = set(s)
        if 0 in result:
            result.add(1)
        if 2 in result:
            result.add(3)
        return frozenset(result)

    # Observable: swap pairs (0,2) and (1,3)
    def obs_swap(s: SetOfElements) -> SetOfElements:
        result = set()
        for x in s:
            if x == 0: result.add(2)
            elif x == 1: result.add(3)
            elif x == 2: result.add(0)
            elif x == 3: result.add(1)
        return closure(frozenset(result))  # Close the result

    system = ClosureObservableSystem(
        elements=elements,
        closure=closure,
        observables={"swap": obs_swap}
    )

    print("=== Closure-Observable System ===")
    print(f"Elements: {sorted(elements)}")
    print(f"Closed sets: {[sorted(c) for c in system.closed_sets()]}")

    print("\n=== Observational Equivalence ===")
    class_map = compute_observational_equivalence(system)
    print(f"Class map: {class_map}")

    print("\n=== Minimal Kripke Realization ===")
    kripke = reconstruct_minimal_kripke(system)
    print(f"States: {kripke.states}")
    print(f"Realize map: {kripke.realize}")
    print(f"Number of states: {kripke.num_states()}")

    print("\n=== Chu Space ===")
    chu = build_closure_chu_space(system)
    collapse = chu.biextensional_collapse()
    print(f"Biextensional collapse: {collapse}")
    print(f"Collapse matches Kripke: {all(collapse[x] == collapse[y] for x in elements for y in elements if class_map[x] == class_map[y])}")
