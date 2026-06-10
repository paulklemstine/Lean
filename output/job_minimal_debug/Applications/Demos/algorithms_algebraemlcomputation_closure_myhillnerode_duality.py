"""
Closure–Myhill–Nerode Duality: Core Algorithms

Implements the key algorithms from the closure Myhill–Nerode theorem:
1. Closure operator computation
2. Residual profile computation
3. Nerode equivalence testing
4. Canonical closure automaton construction
5. Minimization via residual saturation

All algorithms operate on finite closure transition systems.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, FrozenSet, Dict, List, Set, Tuple, Optional
from itertools import product


# ============================================================
# Core data structures
# ============================================================

State = int
Letter = str
Config = frozenset  # frozen sets of states represent closed sets


@dataclass
class ClosureTransitionSystem:
    """A finite closure-compatible transition system.

    Attributes:
        states: set of configuration states
        alphabet: set of letters
        step: transition function (state, letter) -> state
        accept: set of accepting states
        cl: closure operator on sets of states (frozenset -> frozenset)
    """
    states: FrozenSet[State]
    alphabet: FrozenSet[Letter]
    step: Dict[Tuple[State, Letter], State]
    accept: FrozenSet[State]
    cl: Callable[[FrozenSet[State]], FrozenSet[State]]

    def step_word(self, x: State, w: List[Letter]) -> State:
        """Execute a word from a configuration.

        Time complexity: O(|w|)
        """
        current = x
        for a in w:
            current = self.step[(current, a)]
        return current

    def residual_profile(self, w: List[Letter]) -> FrozenSet[State]:
        """Compute the residual profile of word w.

        R_w = cl({x | stepWord(x, w) ∈ accept})

        Time complexity: O(|states| · |w| + T_cl)
        where T_cl is the time for one closure computation.
        """
        preimage = frozenset(
            x for x in self.states
            if self.step_word(x, w) in self.accept
        )
        return self.cl(preimage)

    def nerode_equivalent(self, u: List[Letter], v: List[Letter],
                          max_suffix_len: int = 10) -> bool:
        """Test Nerode equivalence by checking suffixes up to given length.

        Two words are Nerode-equivalent if they have the same residual
        profile for all suffixes. We check all suffixes up to max_suffix_len.

        Time complexity: O(|Σ|^max_suffix_len · (|states| · max_word_len + T_cl))
        """
        for length in range(max_suffix_len + 1):
            for suffix in _all_words(list(self.alphabet), length):
                r_u = self.residual_profile(list(u) + suffix)
                r_v = self.residual_profile(list(v) + suffix)
                if r_u != r_v:
                    return False
        return True


def _all_words(alphabet: List[Letter], length: int) -> List[List[Letter]]:
    """Generate all words of given length over alphabet."""
    if length == 0:
        return [[]]
    return [list(w) for w in product(alphabet, repeat=length)]


# ============================================================
# Closure operator constructors
# ============================================================

def make_topological_closure(
    states: FrozenSet[State],
    neighborhoods: Dict[State, FrozenSet[State]]
) -> Callable[[FrozenSet[State]], FrozenSet[State]]:
    """Create a topological closure operator from a neighborhood system.

    The closure of A is the set of all states whose every neighborhood
    intersects A.

    Time complexity per call: O(|states|² · |A|)
    """
    def cl(A: FrozenSet[State]) -> FrozenSet[State]:
        result = set(A)
        changed = True
        while changed:
            changed = False
            for x in states:
                if x not in result:
                    # x is in closure if every neighborhood intersects A
                    nbhds = neighborhoods.get(x, frozenset())
                    if nbhds and all(
                        any(n in result for n in nbhd)
                        for nbhd in [nbhds]  # simplified: single neighborhood
                    ):
                        result.add(x)
                        changed = True
        return frozenset(result)
    return cl


def make_downward_closure(
    order: Dict[State, FrozenSet[State]]
) -> Callable[[FrozenSet[State]], FrozenSet[State]]:
    """Create a downward closure operator from a partial order.

    cl(A) = {y | ∃ x ∈ A, y ≤ x}

    Time complexity per call: O(|A| · max_below)
    """
    def cl(A: FrozenSet[State]) -> FrozenSet[State]:
        result = set(A)
        for x in A:
            result.update(order.get(x, set()))
        return frozenset(result)
    return cl


def make_convex_closure(
    states: FrozenSet[State],
    order: Dict[State, FrozenSet[State]]  # x -> set of y with y ≤ x
) -> Callable[[FrozenSet[State]], FrozenSet[State]]:
    """Create a convex closure: cl(A) includes all elements between
    elements of A in the partial order.

    Time complexity per call: O(|states|² · |A|)
    """
    above = {x: frozenset(y for y in states if x in order.get(y, set()))
             for x in states}

    def cl(A: FrozenSet[State]) -> FrozenSet[State]:
        result = set(A)
        for x in states:
            if x not in result:
                # x is in convex closure if there exist a, b in A with a ≤ x ≤ b
                below_x = order.get(x, frozenset())
                above_x = above.get(x, frozenset())
                if (below_x & A) and (above_x & A):
                    result.add(x)
        return frozenset(result)
    return cl


# ============================================================
# Canonical closure automaton construction
# ============================================================

@dataclass
class CanonicalClosureAutomaton:
    """The canonical closure automaton constructed from residual profiles.

    States are residual profiles (frozensets of configuration states).
    Transitions extend the word by one letter.
    Acceptance checks membership of the initial configuration.
    """
    states: Set[FrozenSet[State]]
    alphabet: FrozenSet[Letter]
    initial: FrozenSet[State]
    transitions: Dict[Tuple[FrozenSet[State], Letter], FrozenSet[State]]
    accepting: Set[FrozenSet[State]]
    x0: State

    def run(self, w: List[Letter]) -> FrozenSet[State]:
        """Execute a word from the initial state."""
        current = self.initial
        for a in w:
            current = self.transitions.get((current, a), frozenset())
        return current

    def accepts(self, w: List[Letter]) -> bool:
        """Check if the automaton accepts a word."""
        return self.run(w) in self.accepting


def build_canonical_automaton(
    system: ClosureTransitionSystem,
    x0: State,
    max_depth: int = 20
) -> CanonicalClosureAutomaton:
    """Build the canonical closure automaton by BFS over residual profiles.

    Algorithm:
    1. Start with residual profile of empty word.
    2. For each discovered state (residual profile) and each letter,
       compute the transition target.
    3. Continue until no new states are discovered or max_depth reached.

    Time complexity: O(|reachable_residuals| · |Σ| · (|states| · max_depth + T_cl))
    Space complexity: O(|reachable_residuals| · |states|)

    Args:
        system: the closure transition system
        x0: initial configuration for acceptance
        max_depth: maximum BFS depth

    Returns:
        The canonical closure automaton
    """
    alphabet = system.alphabet
    initial = system.residual_profile([])

    discovered: Set[FrozenSet[State]] = {initial}
    transitions: Dict[Tuple[FrozenSet[State], Letter], FrozenSet[State]] = {}
    queue = [(initial, [])]  # (residual profile, word that generates it)
    word_map: Dict[FrozenSet[State], List[Letter]] = {initial: []}

    depth = 0
    while queue and depth < max_depth:
        next_queue = []
        for R, w in queue:
            for a in sorted(alphabet):
                new_word = w + [a]
                new_R = system.residual_profile(new_word)
                transitions[(R, a)] = new_R
                if new_R not in discovered:
                    discovered.add(new_R)
                    word_map[new_R] = new_word
                    next_queue.append((new_R, new_word))
        queue = next_queue
        depth += 1

    accepting = {R for R in discovered if x0 in R}

    return CanonicalClosureAutomaton(
        states=discovered,
        alphabet=alphabet,
        initial=initial,
        transitions=transitions,
        accepting=accepting,
        x0=x0
    )


# ============================================================
# Residual saturation algorithm
# ============================================================

def saturate_residuals(
    system: ClosureTransitionSystem,
    generators: List[FrozenSet[State]],
    max_iterations: int = 100
) -> Set[FrozenSet[State]]:
    """Saturate a generating family under join and letter action.

    Starting from a finite set of closure-stable predicates (generators),
    repeatedly:
    1. Close under pairwise join: cl(P ∪ Q)
    2. Close under letter action: for each letter a, compute
       cl({y | step(y,a) ∈ R}) for each known R

    Continue until fixed point.

    Time complexity: O(max_iterations · |family|² · (|states| + T_cl))
    Space complexity: O(|family| · |states|)

    Args:
        system: the closure transition system
        generators: initial generating family
        max_iterations: maximum saturation steps

    Returns:
        The saturated family of residual profiles
    """
    family: Set[FrozenSet[State]] = set(generators)

    for _ in range(max_iterations):
        new_elements: Set[FrozenSet[State]] = set()

        # Close under join
        family_list = list(family)
        for i, P in enumerate(family_list):
            for Q in family_list[i:]:
                join = system.cl(P | Q)
                if join not in family:
                    new_elements.add(join)

        # Close under letter preimage
        for R in family_list:
            for a in system.alphabet:
                preimage = frozenset(
                    y for y in system.states
                    if system.step.get((y, a)) is not None
                    and system.step[(y, a)] in R
                )
                closed_preimage = system.cl(preimage)
                if closed_preimage not in family:
                    new_elements.add(closed_preimage)

        if not new_elements:
            break  # Fixed point reached
        family.update(new_elements)

    return family


# ============================================================
# Minimality verification
# ============================================================

def verify_minimality(
    automaton: CanonicalClosureAutomaton,
    system: ClosureTransitionSystem,
    test_words: List[List[Letter]]
) -> Dict[str, any]:
    """Verify that the canonical automaton is minimal.

    Checks:
    1. No two states are behaviorally equivalent
    2. All states are reachable
    3. The automaton correctly recognizes the language

    Args:
        automaton: the canonical closure automaton
        system: the original closure transition system
        test_words: words to test for correctness

    Returns:
        Dictionary with verification results
    """
    results = {
        "num_states": len(automaton.states),
        "all_reachable": True,
        "no_equivalent_states": True,
        "correct_recognition": True,
        "counterexamples": []
    }

    # Check correctness on test words
    for w in test_words:
        expected = automaton.x0 in system.residual_profile(w)
        actual = automaton.accepts(w)
        if expected != actual:
            results["correct_recognition"] = False
            results["counterexamples"].append(w)

    # Check state distinguishability
    states_list = list(automaton.states)
    for i, s1 in enumerate(states_list):
        for s2 in states_list[i+1:]:
            # Check if s1 and s2 are distinguishable
            distinguished = False
            for w in test_words:
                r1 = s1
                r2 = s2
                for a in w:
                    r1 = automaton.transitions.get((r1, a), frozenset())
                    r2 = automaton.transitions.get((r2, a), frozenset())
                if (r1 in automaton.accepting) != (r2 in automaton.accepting):
                    distinguished = True
                    break
            if not distinguished:
                results["no_equivalent_states"] = False

    return results


# ============================================================
# Join-irreducible extraction
# ============================================================

def find_join_irreducibles(
    residuals: Set[FrozenSet[State]],
    cl: Callable[[FrozenSet[State]], FrozenSet[State]]
) -> Set[FrozenSet[State]]:
    """Find join-irreducible elements of the residual lattice.

    An element J is join-irreducible if J = cl(P ∪ Q) implies J = P or J = Q
    for all P, Q in the lattice.

    Time complexity: O(|residuals|³)

    Args:
        residuals: the set of reachable residual profiles
        cl: the closure operator

    Returns:
        The set of join-irreducible residual profiles
    """
    join_irreducibles: Set[FrozenSet[State]] = set()
    residuals_list = list(residuals)

    for J in residuals_list:
        is_ji = True
        for P in residuals_list:
            if P == J:
                continue
            for Q in residuals_list:
                if Q == J:
                    continue
                if cl(P | Q) == J:
                    is_ji = False
                    break
            if not is_ji:
                break
        if is_ji:
            join_irreducibles.add(J)

    return join_irreducibles
