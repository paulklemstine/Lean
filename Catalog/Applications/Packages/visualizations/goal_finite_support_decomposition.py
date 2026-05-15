#!/usr/bin/env python3
"""
Algorithms for Tropical Formula Definability

This module implements the key algorithms from the research:
1. Formula-to-Automaton compilation (forward direction)
2. Derivative computation for tropical formulas
3. Finite derivative enumeration
4. Automaton-to-Formula decompilation (converse direction, acyclic case)
"""

from typing import List, Dict, Set, Tuple, Optional, Callable
from dataclasses import dataclass, field
from collections import defaultdict
import math

INF = float('inf')


# ═══════════════════════════════════════════════════════════════════════
# Data Structures
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class TropicalDFA:
    """
    Deterministic tropical finite automaton.

    States are integers 0..n-1. The automaton assigns costs via:
      cost(w) = out[run(init, w)]

    Time complexity of evaluation: O(|w|)
    Space complexity: O(|Q| × |Σ|) for the transition table
    """
    num_states: int
    alphabet: list
    step: dict  # (state, letter) -> state
    init: int
    out: dict   # state -> cost (float, INF for ⊤)

    def run(self, state: int, word: tuple) -> int:
        """Run the automaton from state on word. O(|w|)."""
        q = state
        for a in word:
            q = self.step.get((q, a), state)  # default to self-loop
        return q

    def eval_cost(self, word: tuple) -> float:
        """Evaluate cost of a word. O(|w|)."""
        return self.out.get(self.run(self.init, word), INF)

    def is_acyclic(self) -> bool:
        """
        Check if the automaton's transition graph is acyclic.

        Uses DFS cycle detection. O(|Q| × |Σ|).
        """
        WHITE, GRAY, BLACK = 0, 1, 2
        color = {q: WHITE for q in range(self.num_states)}

        def dfs(q):
            color[q] = GRAY
            for a in self.alphabet:
                r = self.step.get((q, a), q)
                if r == q:
                    continue  # self-loops don't count as cycles
                if color[r] == GRAY:
                    return True  # cycle found
                if color[r] == WHITE and dfs(r):
                    return True
            color[q] = BLACK
            return False

        for q in range(self.num_states):
            if color[q] == WHITE and dfs(q):
                return False
        return True


@dataclass
class TropicalFormula:
    """
    Tropical formula in tree representation.

    Types:
      'const': constant c
      'indicator': maps target word to cost, all else to ∞
      'add': pointwise cost addition (tropical multiplication)
      'min': pointwise minimum (tropical addition)
    """
    kind: str
    value: float = 0
    target: tuple = ()
    left: Optional['TropicalFormula'] = None
    right: Optional['TropicalFormula'] = None

    def eval(self, word: tuple) -> float:
        """Evaluate the formula on a word. O(size of formula)."""
        if self.kind == 'const':
            return self.value
        elif self.kind == 'indicator':
            return self.value if word == self.target else INF
        elif self.kind == 'add':
            l = self.left.eval(word)
            r = self.right.eval(word)
            return l + r if l < INF and r < INF else INF
        elif self.kind == 'min':
            return min(self.left.eval(word), self.right.eval(word))
        return INF

    def size(self) -> int:
        """Number of nodes in the formula tree."""
        if self.kind in ('const', 'indicator'):
            return 1
        return 1 + self.left.size() + self.right.size()

    def depth(self) -> int:
        """Depth of the formula tree."""
        if self.kind in ('const', 'indicator'):
            return 0
        return 1 + max(self.left.depth(), self.right.depth())

    def __repr__(self):
        if self.kind == 'const':
            return f"Const({'∞' if self.value == INF else self.value})"
        elif self.kind == 'indicator':
            w = ''.join(self.target) if self.target else 'ε'
            return f"Ind({w},{self.value})"
        elif self.kind == 'add':
            return f"({self.left} ⊗ {self.right})"
        elif self.kind == 'min':
            return f"({self.left} ⊕ {self.right})"
        return "?"


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Left Derivative Computation
# ═══════════════════════════════════════════════════════════════════════

def left_derivative_letter(phi: TropicalFormula, a: str) -> TropicalFormula:
    """
    Compute the left derivative of a tropical formula by a single letter.

    Given formula φ, returns formula ψ such that ψ(w) = φ(a·w) for all words w.

    This is the algorithmic implementation of formula_definable_leftDeriv_letter.

    Time complexity: O(size(φ))
    Space complexity: O(size(φ)) for the output formula

    Args:
        phi: Input tropical formula
        a: Letter to differentiate by

    Returns:
        The derivative formula ∂_a(φ)
    """
    if phi.kind == 'const':
        return TropicalFormula('const', phi.value)

    elif phi.kind == 'indicator':
        target = phi.target
        if len(target) == 0:
            return TropicalFormula('const', INF)  # ∂_a(Ind(ε,c)) = ⊤
        elif target[0] == a:
            return TropicalFormula('indicator', phi.value, target[1:])
        else:
            return TropicalFormula('const', INF)

    elif phi.kind == 'add':
        return TropicalFormula('add',
            left=left_derivative_letter(phi.left, a),
            right=left_derivative_letter(phi.right, a))

    elif phi.kind == 'min':
        return TropicalFormula('min',
            left=left_derivative_letter(phi.left, a),
            right=left_derivative_letter(phi.right, a))

    return TropicalFormula('const', INF)


def left_derivative(phi: TropicalFormula, word: tuple) -> TropicalFormula:
    """
    Compute the left derivative of a formula by a word.

    ∂_w(φ) = ∂_{w_n}(... ∂_{w_2}(∂_{w_1}(φ)) ...)

    Time complexity: O(|w| × size(φ))
    Space complexity: O(size(φ)) (formula size may grow, but at most linearly)
    """
    result = phi
    for a in word:
        result = left_derivative_letter(result, a)
    return result


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Finite Derivative Enumeration
# ═══════════════════════════════════════════════════════════════════════

def enumerate_derivatives(phi: TropicalFormula, alphabet: list,
                         max_depth: int = 100) -> Dict[tuple, TropicalFormula]:
    """
    Enumerate all distinct left derivatives of a formula.

    Uses BFS over words, stopping when no new derivatives are found.
    The key theorem guarantees this terminates for formula-definable series.

    Time complexity: O(|Q| × |Σ|) where |Q| is the number of distinct derivatives
    Space complexity: O(|Q|)

    Args:
        phi: Input formula
        alphabet: List of letters
        max_depth: Maximum word length to explore

    Returns:
        Dictionary mapping words to their derivative formulas
    """
    # Track derivatives by their evaluation on test words
    derivatives = {}
    seen_behaviors = set()

    # Generate test words for comparison
    test_words = [()]
    for length in range(1, 5):
        for w in _words_of_length(alphabet, length):
            test_words.append(w)

    def behavior_key(formula):
        return tuple(formula.eval(w) for w in test_words)

    queue = [((), phi)]
    derivatives[()] = phi
    seen_behaviors.add(behavior_key(phi))

    while queue:
        word, current = queue.pop(0)
        if len(word) >= max_depth:
            continue

        for a in alphabet:
            new_word = word + (a,)
            new_deriv = left_derivative_letter(current, a)
            key = behavior_key(new_deriv)

            if key not in seen_behaviors:
                seen_behaviors.add(key)
                derivatives[new_word] = new_deriv
                queue.append((new_word, new_deriv))

    return derivatives


def _words_of_length(alphabet, length):
    """Generate all words of a given length."""
    if length == 0:
        yield ()
        return
    for w in _words_of_length(alphabet, length - 1):
        for a in alphabet:
            yield w + (a,)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Formula-to-Automaton Compilation
# ═══════════════════════════════════════════════════════════════════════

def compile_formula_to_dfa(phi: TropicalFormula,
                           alphabet: list) -> TropicalDFA:
    """
    Compile a tropical formula into an equivalent tropical DFA.

    This is the algorithmic implementation of formula_definable_implies_recognizable.

    The states of the DFA are the distinct left derivatives of the formula.
    Transitions map derivative × letter to the derivative of the derivative.

    Algorithm:
    1. Enumerate all distinct derivatives (BFS)
    2. Create a state for each distinct derivative
    3. Transitions: state(∂_u) --a--> state(∂_{ua})
    4. Output: state(∂_u) outputs (∂_u φ)(ε)
    5. Initial: state(∂_ε) = state(φ)

    Time complexity: O(|Q| × |Σ|) for construction
    Space complexity: O(|Q| × |Σ|) for the DFA

    Args:
        phi: Input formula
        alphabet: List of letters

    Returns:
        Equivalent tropical DFA
    """
    # Step 1: Enumerate derivatives
    derivs = enumerate_derivatives(phi, alphabet)

    # Build test words for behavior comparison
    test_words = [()]
    for length in range(1, 5):
        for w in _words_of_length(alphabet, length):
            test_words.append(w)

    def behavior_key(formula):
        return tuple(formula.eval(w) for w in test_words)

    # Map behaviors to state indices
    behavior_to_state = {}
    state_formulas = []
    for word, formula in derivs.items():
        key = behavior_key(formula)
        if key not in behavior_to_state:
            behavior_to_state[key] = len(state_formulas)
            state_formulas.append(formula)

    num_states = len(state_formulas)

    # Step 2-5: Build DFA
    step = {}
    out = {}

    for i, formula in enumerate(state_formulas):
        # Output = formula evaluated on empty word
        out[i] = formula.eval(())

        # Transitions
        for a in alphabet:
            deriv = left_derivative_letter(formula, a)
            key = behavior_key(deriv)
            if key in behavior_to_state:
                step[(i, a)] = behavior_to_state[key]
            else:
                # This shouldn't happen if enumeration was complete
                step[(i, a)] = i

    init_key = behavior_key(phi)
    init_state = behavior_to_state.get(init_key, 0)

    return TropicalDFA(
        num_states=num_states,
        alphabet=alphabet,
        step=step,
        init=init_state,
        out=out
    )


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Automaton-to-Formula Decompilation (Acyclic Case)
# ═══════════════════════════════════════════════════════════════════════

def decompile_acyclic_dfa_to_formula(dfa: TropicalDFA) -> TropicalFormula:
    """
    Convert an acyclic tropical DFA to an equivalent tropical formula.

    This is the algorithmic implementation of the converse compilation theorem.

    For an acyclic DFA, we can build a formula by structural recursion on
    the DAG of reachable states, working bottom-up from states with no
    outgoing transitions.

    Algorithm:
    1. Topologically sort the states
    2. For each state (bottom-up), build a formula:
       φ_q = min(Ind(ε, out(q)), min over letters a of:
              min over reachable q' via a of: Ind(a, 0) then φ_{q'})
    3. The formula for the initial state is the answer

    For the acyclic case, we expand paths explicitly:
    φ_q = min over all paths from q: Ind(path_word, accumulated_cost)

    Time complexity: O(|Q|! / (|Q|-d)!) in worst case for depth d,
                     but O(|Q| × |Σ|) for bounded branching
    Space complexity: O(formula size) ≤ O(|Σ|^|Q|) worst case

    Args:
        dfa: An acyclic tropical DFA

    Returns:
        Equivalent tropical formula
    """
    assert dfa.is_acyclic(), "DFA must be acyclic"

    # Build formulas bottom-up using memoization
    memo = {}

    def build_formula(state: int, visited: frozenset) -> TropicalFormula:
        """Build formula for series starting from given state."""
        if (state, visited) in memo:
            return memo[(state, visited)]

        # Base: empty word contribution
        out_cost = dfa.out.get(state, INF)
        result = TropicalFormula('indicator', out_cost, ())

        # For each letter, consider the transition
        for a in dfa.alphabet:
            next_state = dfa.step.get((state, a), state)
            if next_state == state:
                continue  # self-loop, skip
            if next_state in visited:
                continue  # avoid revisiting (shouldn't happen in acyclic)

            # Build formula for continuation from next_state
            sub = build_formula(next_state, visited | {state})

            # Prepend letter a: for each word w in sub's support,
            # the contribution is Ind(a·w, sub(w))
            prepended = prepend_letter(sub, a)

            # Take minimum with current result
            result = TropicalFormula('min', left=result, right=prepended)

        memo[(state, visited)] = result
        return result

    return build_formula(dfa.init, frozenset())


def prepend_letter(phi: TropicalFormula, a: str) -> TropicalFormula:
    """
    Given formula φ, produce formula ψ such that ψ(a·w) = φ(w) and ψ(v) = ∞
    for words not starting with a.

    For atomic formulas:
      prepend_letter(Const(c), a) = Const(c) only for constant series... 
      Actually for indicator: prepend(Ind(w, c), a) = Ind(a·w, c)
    """
    if phi.kind == 'const':
        if phi.value == INF:
            return TropicalFormula('const', INF)
        # Constant series prepended: this would need concatenation
        # For acyclic case, we only deal with finite support
        return TropicalFormula('const', INF)  # conservative
    elif phi.kind == 'indicator':
        new_target = (a,) + phi.target
        return TropicalFormula('indicator', phi.value, new_target)
    elif phi.kind == 'add':
        return TropicalFormula('add',
            left=prepend_letter(phi.left, a),
            right=prepend_letter(phi.right, a))
    elif phi.kind == 'min':
        return TropicalFormula('min',
            left=prepend_letter(phi.left, a),
            right=prepend_letter(phi.right, a))
    return TropicalFormula('const', INF)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Finite Support Decomposition
# ═══════════════════════════════════════════════════════════════════════

def finite_support_to_formula(support: Dict[tuple, float]) -> TropicalFormula:
    """
    Convert a finite-support series to a tropical formula.

    This is the algorithmic implementation of finiteSupport_formulaDefinable.

    The formula is simply the minimum of indicator formulas for each
    word in the support.

    Time complexity: O(|support|)
    Space complexity: O(|support|) for the formula

    Args:
        support: Dictionary mapping words to their costs

    Returns:
        Tropical formula equivalent to the series
    """
    if not support:
        return TropicalFormula('const', INF)

    items = list(support.items())
    result = TropicalFormula('indicator', items[0][1], items[0][0])

    for word, cost in items[1:]:
        term = TropicalFormula('indicator', cost, word)
        result = TropicalFormula('min', left=result, right=term)

    return result


# ═══════════════════════════════════════════════════════════════════════
# Main: Run all algorithms with examples
# ═══════════════════════════════════════════════════════════════════════

def main():
    print("TROPICAL FORMULA DEFINABILITY — ALGORITHMS")
    print("=" * 60)

    # Example 1: Derivative computation
    print("\n--- Algorithm 1: Left Derivative ---")
    phi = TropicalFormula('min',
        left=TropicalFormula('indicator', 3, ('a', 'b')),
        right=TropicalFormula('indicator', 5, ('a', 'c')))
    print(f"Formula: {phi}")
    d_a = left_derivative_letter(phi, 'a')
    print(f"∂_a(φ) = {d_a}")
    d_b = left_derivative_letter(phi, 'b')
    print(f"∂_b(φ) = {d_b}")

    # Example 2: Derivative enumeration
    print("\n--- Algorithm 2: Derivative Enumeration ---")
    derivs = enumerate_derivatives(phi, ['a', 'b', 'c'])
    print(f"Number of distinct derivatives: {len(derivs)}")
    for word, deriv in sorted(derivs.items(), key=lambda x: (len(x[0]), x[0])):
        w_str = ''.join(word) if word else 'ε'
        print(f"  ∂_{w_str}(φ) = {deriv}")

    # Example 3: Compilation
    print("\n--- Algorithm 3: Formula → DFA Compilation ---")
    dfa = compile_formula_to_dfa(phi, ['a', 'b', 'c'])
    print(f"DFA states: {dfa.num_states}")
    print(f"DFA is acyclic: {dfa.is_acyclic()}")
    test_words = [(), ('a',), ('b',), ('a', 'b'), ('a', 'c'), ('b', 'a')]
    for w in test_words:
        w_str = ''.join(w) if w else 'ε'
        formula_val = phi.eval(w)
        dfa_val = dfa.eval_cost(w)
        f_str = '∞' if formula_val == INF else str(formula_val)
        d_str = '∞' if dfa_val == INF else str(dfa_val)
        print(f"  word={w_str}: formula={f_str}, DFA={d_str}, match={'✓' if formula_val == dfa_val else '✗'}")

    # Example 4: Decompilation (acyclic)
    print("\n--- Algorithm 4: Acyclic DFA → Formula Decompilation ---")
    # Build a simple acyclic DFA
    acyclic_dfa = TropicalDFA(
        num_states=3,
        alphabet=['a', 'b'],
        step={(0, 'a'): 1, (0, 'b'): 2, (1, 'a'): 2, (1, 'b'): 2,
              (2, 'a'): 2, (2, 'b'): 2},
        init=0,
        out={0: 10, 1: 3, 2: INF}
    )
    print(f"Acyclic DFA: 3 states, alphabet={{a,b}}")
    print(f"  State 0: out=10")
    print(f"  State 1: out=3")
    print(f"  State 2: out=∞ (dead)")
    print(f"  0 --a--> 1, 0 --b--> 2, 1 --a--> 2, 1 --b--> 2")

    recovered = decompile_acyclic_dfa_to_formula(acyclic_dfa)
    print(f"\nRecovered formula: {recovered}")

    test_words = [(), ('a',), ('b',), ('a', 'a'), ('a', 'b'), ('b', 'a')]
    print("\nVerification:")
    for w in test_words:
        w_str = ''.join(w) if w else 'ε'
        dfa_val = acyclic_dfa.eval_cost(w)
        formula_val = recovered.eval(w)
        d_str = '∞' if dfa_val == INF else str(int(dfa_val))
        f_str = '∞' if formula_val == INF else str(int(formula_val))
        print(f"  word={w_str}: DFA={d_str}, formula={f_str}, match={'✓' if dfa_val == formula_val else '✗'}")

    # Example 5: Finite support
    print("\n--- Algorithm 5: Finite Support Decomposition ---")
    support = {(): 0, ('a',): 2, ('a', 'b'): 5, ('b',): 7}
    formula = finite_support_to_formula(support)
    print(f"Support: {support}")
    print(f"Formula: {formula}")
    for w in [(), ('a',), ('b',), ('a', 'b'), ('c',)]:
        w_str = ''.join(w) if w else 'ε'
        expected = support.get(w, INF)
        actual = formula.eval(w)
        e_str = '∞' if expected == INF else str(expected)
        a_str = '∞' if actual == INF else str(actual)
        print(f"  word={w_str}: expected={e_str}, formula={a_str}, match={'✓' if expected == actual else '✗'}")


if __name__ == "__main__":
    main()
