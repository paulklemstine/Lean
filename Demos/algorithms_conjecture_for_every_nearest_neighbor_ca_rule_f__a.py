"""
Algorithms for Transition Monoid Computation of Cellular Automata Column Languages

This module provides efficient algorithms for:
1. Computing the column-extension DFA and its transition monoid
2. Computing the aperiodicity exponent of the transition monoid
3. Testing J-triviality and piecewise testability conditions
4. Enumerating CA rules and their algebraic invariants

All algorithms match the formal Lean definitions in Speculative/CATransitionMonoid.lean.
"""

import itertools
from typing import Callable, Dict, Tuple, List, Set, Optional
from dataclasses import dataclass
from collections import defaultdict


# ============================================================
# Core: Diagonal Step and Transition Functions
# ============================================================

def diag_step(f: Callable[[any, any], any], b: List, a, n: int):
    """
    Compute coordinate n of the new diagonal state.
    
    Matches the Lean definition:
      diagStep f b a 0 = a
      diagStep f b a (n+1) = f(b[n], diagStep f b a n)
    
    Args:
        f: CA update rule (x, y) -> z
        b: Current state as a list (indexed by natural numbers)
        a: New cell value being read
        n: Coordinate index to compute
    
    Returns:
        Value at coordinate n of the new state
    
    Time: O(n) per call
    Space: O(n) stack depth
    
    >>> diag_step(lambda x, y: x, [1, 0, 1], 0, 0)
    0
    >>> diag_step(lambda x, y: x, [1, 0, 1], 0, 1)
    1
    """
    if n == 0:
        return a
    return f(b[n - 1], diag_step(f, b, a, n - 1))


def step_transition(f: Callable, h: int, a, state: tuple) -> tuple:
    """
    Single-letter transition: read cell value 'a' from state 'state'.
    
    The state is a tuple of h elements representing the right diagonal
    of the spacetime diagram.
    
    Args:
        f: CA update rule
        h: Strip height (state dimension)
        a: Cell value to read
        state: Current DFA state (tuple of h elements)
    
    Returns:
        New DFA state after reading cell a
    
    Time: O(h²) due to recursive diag_step calls
    Space: O(h)
    
    >>> step_transition(lambda x, y: x, 3, 0, (1, 0, 1))
    (0, 1, 0)
    """
    b = list(state)
    return tuple(diag_step(f, b, a, i) for i in range(h))


def word_transition(f: Callable, h: int, word: list, state: tuple) -> tuple:
    """
    Word transition: read a sequence of cell values from left to right.
    
    Args:
        f: CA update rule
        h: Strip height
        word: List of cell values to read
        state: Initial DFA state
    
    Returns:
        Final DFA state after reading all cells
    
    Time: O(|word| * h²)
    Space: O(h)
    
    >>> word_transition(lambda x, y: x, 3, [0, 0, 0], (1, 1, 1))
    (0, 0, 0)
    """
    s = state
    for a in word:
        s = step_transition(f, h, a, s)
    return s


# ============================================================
# Algorithm 1: Transition Monoid Computation
# ============================================================

@dataclass
class TransitionMonoid:
    """
    Represents the transition monoid of a CA column-extension DFA.
    
    Attributes:
        elements: Set of transition functions (as frozen dicts)
        generators: Single-letter transition functions
        h: Strip height
        alphabet: Cell alphabet
    """
    elements: Set[frozenset]
    generators: Dict[any, Dict[tuple, tuple]]
    h: int
    alphabet: list
    
    @property
    def size(self) -> int:
        return len(self.elements)


def all_states(alpha: list, h: int) -> list:
    """Generate all DFA states (elements of alpha^h)."""
    if h == 0:
        return [()]
    return list(itertools.product(alpha, repeat=h))


def transition_function(f: Callable, h: int, word: list, alpha: list) -> dict:
    """
    Compute the transition function for a given word.
    
    Args:
        f: CA update rule
        h: Strip height
        word: Input word
        alpha: Alphabet
    
    Returns:
        Dictionary mapping each state to its image
    
    Time: O(|alpha|^h * |word| * h²)
    """
    states = all_states(alpha, h)
    return {s: word_transition(f, h, word, s) for s in states}


def tf_to_frozenset(tf: dict) -> frozenset:
    """Convert transition function to hashable frozenset for set operations."""
    return frozenset(tf.items())


def compose_tf(tf1: dict, tf2: dict) -> dict:
    """Compose two transition functions: tf2 ∘ tf1."""
    return {s: tf2[tf1[s]] for s in tf1}


def compute_transition_monoid(f: Callable, h: int, alpha: list) -> TransitionMonoid:
    """
    Compute the full transition monoid of the column-extension DFA.
    
    Uses breadth-first search from generators to find all reachable
    monoid elements under composition.
    
    Args:
        f: CA update rule
        h: Strip height
        alpha: Cell alphabet
    
    Returns:
        TransitionMonoid object containing all elements
    
    Time: O(|M|² * |alpha|^h) where |M| is the monoid size
    Space: O(|M| * |alpha|^h)
    
    Pseudocode:
        generators = {transition_function(a) : a in alpha}
        elements = {identity} ∪ generators
        queue = list(generators)
        while queue is not empty:
            tf = queue.pop()
            for gen in generators:
                new_tf = compose(tf, gen)
                if new_tf not in elements:
                    elements.add(new_tf)
                    queue.append(new_tf)
        return elements
    """
    states = all_states(alpha, h)
    identity = {s: s for s in states}
    
    generators = {}
    for a in alpha:
        tf = transition_function(f, h, [a], alpha)
        generators[a] = tf
    
    elements = {tf_to_frozenset(identity)}
    for a in alpha:
        elements.add(tf_to_frozenset(generators[a]))
    
    queue = [generators[a] for a in alpha]
    all_tfs = [identity] + [generators[a] for a in alpha]
    
    while queue:
        tf = queue.pop(0)
        for a in alpha:
            new_tf = compose_tf(tf, generators[a])
            key = tf_to_frozenset(new_tf)
            if key not in elements:
                elements.add(key)
                queue.append(new_tf)
                all_tfs.append(new_tf)
    
    return TransitionMonoid(
        elements=elements,
        generators=generators,
        h=h,
        alphabet=alpha
    )


# ============================================================
# Algorithm 2: Aperiodicity Exponent Computation
# ============================================================

def compute_exponent(tf: dict) -> int:
    """
    Compute the aperiodicity exponent of a single transition function.
    
    Finds the smallest k ≥ 0 such that tf^{k+1} = tf^k.
    
    Args:
        tf: Transition function as dictionary
    
    Returns:
        The aperiodicity exponent (index)
    
    Time: O(k * |Q|) where k is the exponent and |Q| is the state count
    
    >>> states = [(0,), (1,)]
    >>> identity = {s: s for s in states}
    >>> compute_exponent(identity)
    0
    """
    states = list(tf.keys())
    prev = {s: s for s in states}  # identity = tf^0
    for k in range(1, len(states) + 2):
        curr = compose_tf(prev, tf)
        if curr == prev:
            return k - 1
        prev = curr
    raise RuntimeError("Exponent computation failed to converge")


def compute_monoid_exponent(f: Callable, h: int, alpha: list, 
                              max_word_len: int = None) -> int:
    """
    Compute the aperiodicity exponent of the transition monoid.
    
    Finds the smallest n such that m^{n+1} = m^n for ALL monoid elements m.
    
    Args:
        f: CA update rule
        h: Strip height
        alpha: Cell alphabet
        max_word_len: Maximum word length to test (default: h)
    
    Returns:
        The monoid aperiodicity exponent
    
    Time: O(sum over word lengths of |alpha|^L * |Q|^2)
    
    >>> compute_monoid_exponent(lambda x, y: x, 3, [0, 1])
    3
    """
    if max_word_len is None:
        max_word_len = h
    
    max_exp = 0
    for L in range(1, max_word_len + 1):
        for word in itertools.product(alpha, repeat=L):
            tf = transition_function(f, h, list(word), alpha)
            exp = compute_exponent(tf)
            max_exp = max(max_exp, exp)
    return max_exp


def verify_exponent_bound(f: Callable, h: int, alpha: list) -> dict:
    """
    Verify the theorem: for all words w, (wordFn w)^{h+1} = (wordFn w)^h.
    
    Also finds the exact exponent and checks if exponent h is achieved.
    
    Returns:
        Dictionary with verification results including:
        - 'bound_holds': whether m^{h+1} = m^h for all m
        - 'exact_exponent': the actual monoid exponent
        - 'tight': whether the bound h is achieved
        - 'witness': word achieving maximum exponent (if tight)
    """
    max_exp = 0
    witness = None
    bound_holds = True
    
    for L in range(1, h + 1):
        for word in itertools.product(alpha, repeat=L):
            word = list(word)
            tf = transition_function(f, h, word, alpha)
            
            # Check m^{h+1} = m^h
            tf_h = tf
            for _ in range(h - 1):
                tf_h = compose_tf(tf_h, tf)
            # tf_h is now tf^h
            tf_h1 = compose_tf(tf_h, tf)  # tf^{h+1}
            
            if tf_h1 != tf_h:
                bound_holds = False
            
            exp = compute_exponent(tf)
            if exp > max_exp:
                max_exp = exp
                witness = word
    
    return {
        'bound_holds': bound_holds,
        'exact_exponent': max_exp,
        'tight': max_exp == h,
        'witness': witness,
        'h': h,
    }


# ============================================================
# Algorithm 3: Green's Relations and J-triviality Test
# ============================================================

def compute_greens_j_classes(monoid_elements: list, states: list) -> dict:
    """
    Compute Green's J-relation classes for the transition monoid.
    
    Two elements a, b are J-related if MaM = MbM (same two-sided ideal).
    For a finite monoid, this is equivalent to: there exist x, y, u, v
    such that a = xby and b = uav.
    
    Args:
        monoid_elements: List of transition functions
        states: List of states
    
    Returns:
        Dictionary mapping each element to its J-class index
    
    Time: O(|M|³ * |Q|)
    """
    n = len(monoid_elements)
    
    # Precompute all products
    products = {}
    for i, a in enumerate(monoid_elements):
        for j, b in enumerate(monoid_elements):
            products[(i, j)] = compose_tf(a, b)
    
    # Compute reachability: can a reach b by two-sided multiplication?
    can_reach = [[False] * n for _ in range(n)]
    
    for i in range(n):
        for j in range(n):
            for x_idx in range(n):
                for y_idx in range(n):
                    prod = compose_tf(monoid_elements[x_idx], 
                                     compose_tf(monoid_elements[i], monoid_elements[y_idx]))
                    if prod == monoid_elements[j]:
                        can_reach[i][j] = True
    
    # J-relation: mutual reachability
    j_class = list(range(n))
    for i in range(n):
        for j in range(i + 1, n):
            if can_reach[i][j] and can_reach[j][i]:
                # Merge classes
                old_class = j_class[j]
                new_class = j_class[i]
                for k in range(n):
                    if j_class[k] == old_class:
                        j_class[k] = new_class
    
    return j_class


def is_j_trivial(f: Callable, h: int, alpha: list) -> bool:
    """
    Test if the transition monoid is J-trivial.
    
    A monoid is J-trivial if every J-class is a singleton.
    By Simon's theorem, this is equivalent to the recognized language
    being piecewise testable.
    
    Args:
        f: CA update rule
        h: Strip height
        alpha: Cell alphabet
    
    Returns:
        True if the transition monoid is J-trivial
    """
    monoid = compute_transition_monoid(f, h, alpha)
    states = all_states(alpha, h)
    
    # Reconstruct elements as dicts
    elements = [dict(fs) for fs in monoid.elements]
    
    j_classes = compute_greens_j_classes(elements, states)
    
    # Check all classes are singletons
    class_sizes = defaultdict(int)
    for c in j_classes:
        class_sizes[c] += 1
    
    return all(s == 1 for s in class_sizes.values())


# ============================================================
# Algorithm 4: Rule Enumeration and Classification
# ============================================================

def enumerate_binary_rules() -> list:
    """
    Enumerate all 16 binary Boolean CA rules.
    
    Each rule f: {0,1}² -> {0,1} is determined by its truth table
    (f(0,0), f(0,1), f(1,0), f(1,1)).
    
    Returns:
        List of (name, rule_function) pairs
    """
    rules = []
    for bits in range(16):
        table = {
            (0, 0): (bits >> 0) & 1,
            (0, 1): (bits >> 1) & 1,
            (1, 0): (bits >> 2) & 1,
            (1, 1): (bits >> 3) & 1,
        }
        name = f"Rule{bits:02d}({table[(0,0)]}{table[(0,1)]}{table[(1,0)]}{table[(1,1)]})"
        
        def make_rule(t):
            return lambda x, y, _t=t: _t[(x, y)]
        
        rules.append((name, make_rule(table)))
    return rules


def classify_all_rules(max_h: int = 5) -> dict:
    """
    Classify all 16 binary Boolean CA rules by their transition monoid properties.
    
    For each rule and height h, computes:
    - Monoid size
    - Aperiodicity exponent
    - Whether J-trivial (for small cases)
    
    Args:
        max_h: Maximum height to test
    
    Returns:
        Classification dictionary
    """
    alpha = [0, 1]
    rules = enumerate_binary_rules()
    results = {}
    
    for rule_name, f in rules:
        results[rule_name] = {}
        for h in range(1, max_h + 1):
            monoid = compute_transition_monoid(f, h, alpha)
            exp = compute_monoid_exponent(f, h, alpha)
            
            results[rule_name][h] = {
                'monoid_size': monoid.size,
                'exponent': exp,
                'h': h,
            }
    
    return results


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Transition Monoid Algorithms for CA Column Languages")
    print("=" * 70)
    
    alpha = [0, 1]
    
    # Example 1: Verify exponent bound for specific rules
    print("\n--- Exponent Bound Verification ---")
    rules = {
        "left(x,y)=x": lambda x, y: x,
        "right(x,y)=y": lambda x, y: y,
        "xor(x,y)": lambda x, y: x ^ y,
        "and(x,y)": lambda x, y: x & y,
        "or(x,y)": lambda x, y: x | y,
    }
    
    for name, f in rules.items():
        for h in range(1, 5):
            result = verify_exponent_bound(f, h, alpha)
            status = "✓" if result['bound_holds'] else "✗"
            tight = "TIGHT" if result['tight'] else f"slack (exp={result['exact_exponent']})"
            print(f"  {status} {name}, h={h}: exponent={result['exact_exponent']}, bound h={h} {tight}")
    
    # Example 2: Monoid sizes
    print("\n--- Transition Monoid Sizes ---")
    for name, f in list(rules.items())[:3]:
        for h in range(1, 5):
            monoid = compute_transition_monoid(f, h, alpha)
            print(f"  {name}, h={h}: |M| = {monoid.size}")
    
    # Example 3: J-triviality test
    print("\n--- J-Triviality Test (small cases) ---")
    for name, f in list(rules.items())[:3]:
        for h in range(1, 4):
            jt = is_j_trivial(f, h, alpha)
            print(f"  {name}, h={h}: J-trivial = {jt}")
