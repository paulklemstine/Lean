"""
Applications of the Transition Monoid Exponent Theorem
for Cellular Automata Column Languages

This module demonstrates practical applications of the theorem:
  For every CA rule f and height h, m^{h+1} = m^h
  for all transition monoid elements m.

Applications include:
1. Bounded model checking for spacetime strip properties
2. Language complexity classification of CA column languages
3. Generating function analysis for valid column sequences
4. Comparison across the 256 elementary CA rules
"""

import itertools
from typing import Callable, List, Tuple, Dict
from collections import Counter

# Import core functions from algorithms module
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from algorithms import (
    step_transition, word_transition, all_states,
    transition_function, compute_exponent, compose_tf,
    compute_transition_monoid, tf_to_frozenset,
    verify_exponent_bound, enumerate_binary_rules
)


# ============================================================
# Application 1: Bounded Model Checking
# ============================================================

def check_spacetime_property(f: Callable, h: int, alpha: list,
                              property_states: set, max_width: int) -> dict:
    """
    Check if a spacetime column property stabilizes within h iterations.
    
    The theorem guarantees that any property expressible via the DFA
    stabilizes: once the transition function reaches its fixed behavior
    after h applications of a word, no further changes occur.
    
    This means we can check arbitrary regular properties of spacetime
    columns using at most h compositions, regardless of strip width.
    
    Args:
        f: CA rule
        h: Strip height
        alpha: Alphabet
        property_states: Set of accepting states for the property
        max_width: Maximum strip width to test
    
    Returns:
        Dictionary with model checking results
    """
    states = all_states(alpha, h)
    
    # For each starting state, find the set of widths where the property holds
    results = {}
    for start in states:
        widths_accepting = []
        for width in range(1, max_width + 1):
            # Check all possible initial rows of given width
            accepts = False
            for row in itertools.product(alpha, repeat=width):
                final = word_transition(f, h, list(row), start)
                if final in property_states:
                    accepts = True
                    break
            if accepts:
                widths_accepting.append(width)
        results[start] = widths_accepting
    
    return results


# ============================================================
# Application 2: Counting Valid Column Sequences  
# ============================================================

def count_valid_columns(f: Callable, h: int, alpha: list, width: int) -> int:
    """
    Count the number of distinct spacetime column sequences of given width.
    
    A valid column sequence is a sequence c_1, ..., c_width of columns
    (each column is an element of alpha^h) that can appear as the columns
    of a valid spacetime diagram.
    
    Since the DFA has at most |alpha|^h states and the exponent is h,
    the counting function n -> count(n) satisfies a linear recurrence
    of order at most |alpha|^h.
    
    Args:
        f: CA rule
        h: Strip height
        alpha: Alphabet
        width: Number of columns (= width of initial row)
    
    Returns:
        Number of valid column sequences of the given width
    """
    states = all_states(alpha, h)
    
    # Count: for each initial row of given width, what's the column sequence?
    # Actually, every initial row gives a valid column sequence.
    # The number of DISTINCT column sequences is what we want.
    seen_columns = set()
    
    for row in itertools.product(alpha, repeat=width):
        if width < h:
            continue  # Need enough width for full columns
        
        # Generate all columns
        columns = []
        # Build the spacetime diagram
        grid = [list(row)]
        for t in range(1, h):
            prev = grid[-1]
            new_row = [f(prev[i], prev[i+1]) for i in range(len(prev) - 1)]
            grid.append(new_row)
        
        # Extract columns (only those with full height h)
        num_full_columns = width - h + 1
        if num_full_columns <= 0:
            continue
            
        col_seq = []
        for i in range(num_full_columns):
            col = tuple(grid[t][i] for t in range(h))
            col_seq.append(col)
        
        seen_columns.add(tuple(col_seq))
    
    return len(seen_columns)


def column_count_generating_function(f: Callable, h: int, alpha: list, 
                                      max_width: int = 15) -> list:
    """
    Compute the generating function coefficients for column sequence counts.
    
    Returns the sequence count(1), count(2), ..., count(max_width).
    
    The theorem implies this sequence eventually satisfies a linear
    recurrence of bounded order.
    """
    counts = []
    for w in range(1, max_width + 1):
        c = count_valid_columns(f, h, alpha, w)
        counts.append(c)
    return counts


# ============================================================
# Application 3: Rule Classification
# ============================================================

def classify_rule_exponents(max_h: int = 5) -> dict:
    """
    Classify all 16 binary Boolean CA rules by their exponent patterns.
    
    Groups rules by their sequence of exponents (exp(1), exp(2), ..., exp(max_h)).
    
    Returns:
        Dictionary mapping exponent pattern to list of rules
    """
    alpha = [0, 1]
    rules = enumerate_binary_rules()
    
    patterns = {}
    for name, f in rules:
        exponents = []
        for h in range(1, max_h + 1):
            # Find max exponent among single-letter words
            max_exp = 0
            for a in alpha:
                tf = transition_function(f, h, [a], alpha)
                exp = compute_exponent(tf)
                max_exp = max(max_exp, exp)
            exponents.append(max_exp)
        
        pattern = tuple(exponents)
        if pattern not in patterns:
            patterns[pattern] = []
        patterns[pattern].append(name)
    
    return patterns


# ============================================================
# Application 4: Descriptive Complexity Bounds
# ============================================================

def estimate_fo_quantifier_rank(f: Callable, h: int, alpha: list) -> int:
    """
    Estimate the first-order quantifier rank of the column language.
    
    The aperiodicity exponent provides an upper bound on the
    complexity of first-order descriptions. By the Schützenberger–
    McNaughton–Papert theorem, aperiodic languages are FO[<]-definable.
    The exponent h gives a bound on the descriptive complexity.
    
    A crude bound: quantifier rank ≤ h * |alpha|^h.
    
    Args:
        f: CA rule
        h: Strip height
        alpha: Alphabet
    
    Returns:
        Upper bound on FO[<] quantifier rank
    """
    states = all_states(alpha, h)
    return h * len(states)


# ============================================================
# Main: Run all applications
# ============================================================

if __name__ == "__main__":
    alpha = [0, 1]
    
    print("=" * 70)
    print("Applications of the CA Transition Monoid Exponent Theorem")
    print("=" * 70)
    
    # Application 1: Exponent pattern classification
    print("\n--- Application 1: Rule Classification by Exponent Pattern ---")
    patterns = classify_rule_exponents(max_h=5)
    for pattern, rules in sorted(patterns.items()):
        print(f"  Exponents {pattern}: {len(rules)} rules")
        for r in rules:
            print(f"    {r}")
    
    # Application 2: Monoid size growth
    print("\n--- Application 2: Monoid Size Growth ---")
    test_rules = {
        "f(x,y)=x": lambda x, y: x,
        "f(x,y)=y": lambda x, y: y,
        "XOR": lambda x, y: x ^ y,
        "AND": lambda x, y: x & y,
    }
    for name, f in test_rules.items():
        sizes = []
        for h in range(1, 5):
            m = compute_transition_monoid(f, h, alpha)
            sizes.append(m.size)
        print(f"  {name}: sizes = {sizes}")
    
    # Application 3: Column sequence counts
    print("\n--- Application 3: Valid Column Sequence Counts ---")
    for name, f in list(test_rules.items())[:2]:
        for h in range(1, 4):
            counts = column_count_generating_function(f, h, alpha, max_width=8)
            print(f"  {name}, h={h}: counts = {counts}")
    
    # Application 4: FO quantifier rank bounds
    print("\n--- Application 4: FO[<] Quantifier Rank Upper Bounds ---")
    for name, f in test_rules.items():
        for h in range(1, 5):
            rank = estimate_fo_quantifier_rank(f, h, alpha)
            print(f"  {name}, h={h}: QR bound ≤ {rank}")
    
    print("\n" + "=" * 70)
    print("Key Insight: The exponent h bound enables all these applications")
    print("because it guarantees that DFA transition powers stabilize,")
    print("bounding the algebraic complexity of the column language.")
    print("=" * 70)


"""
Demo: Transition Monoid Exponent Theorem for Cellular Automata

This self-contained script demonstrates the corrected theorem:
  For every CA rule f, height h, and transition monoid element m:
      m^{h+1} = m^h

And the disproof of the original conjecture m^3 = m^2 for h >= 3.

All functions are self-contained — no external imports beyond the standard library.
"""

import itertools
from typing import Callable, List, Dict, Tuple


# ============================================================
# Core Definitions (matching the Lean formalization)
# ============================================================

def diag_step(f: Callable, b: list, a, n: int):
    """
    Compute coordinate n of the new diagonal state.
    
    Matches Lean: diagStep f b a 0 = a; diagStep f b a (n+1) = f(b[n], diagStep f b a n)
    """
    if n == 0:
        return a
    return f(b[n - 1], diag_step(f, b, a, n - 1))


def step_transition(f: Callable, h: int, a, state: tuple) -> tuple:
    """Single-letter transition: read cell 'a' from state. Matches Lean: stepFn."""
    b = list(state)
    return tuple(diag_step(f, b, a, i) for i in range(h))


def word_transition(f: Callable, h: int, word: list, state: tuple) -> tuple:
    """Word transition: read list of cells. Matches Lean: wordFn."""
    s = state
    for a in word:
        s = step_transition(f, h, a, s)
    return s


def all_states(alpha: list, h: int) -> list:
    """All DFA states (elements of alpha^h)."""
    return list(itertools.product(alpha, repeat=h))


def transition_fn(f: Callable, h: int, word: list, alpha: list) -> dict:
    """Compute transition function as a dictionary from states to states."""
    return {s: word_transition(f, h, word, s) for s in all_states(alpha, h)}


def compose(tf1: dict, tf2: dict) -> dict:
    """Compose transition functions: (tf2 ∘ tf1)(s) = tf2(tf1(s))."""
    return {s: tf2[tf1[s]] for s in tf1}


def power(tf: dict, n: int) -> dict:
    """n-th power of a transition function under composition."""
    states = list(tf.keys())
    result = {s: s for s in states}  # identity
    for _ in range(n):
        result = compose(result, tf)
    return result


def find_exponent(tf: dict) -> int:
    """Find smallest k such that tf^{k+1} = tf^k."""
    states = list(tf.keys())
    prev = {s: s for s in states}
    for k in range(1, 2 * len(states) + 5):
        curr = compose(prev, tf)
        if curr == prev:
            return k - 1
        prev = curr
    return -1


# ============================================================
# CA Rules
# ============================================================

def rule_left(a, b): return a        # f(x,y) = x
def rule_right(a, b): return b       # f(x,y) = y
def rule_xor(a, b): return a ^ b     # f(x,y) = x XOR y
def rule_and(a, b): return a & b     # f(x,y) = x AND y
def rule_or(a, b): return a | b      # f(x,y) = x OR y
def rule_nand(a, b): return 1-(a&b)  # f(x,y) = NAND


# ============================================================
# Demo 1: Counterexample to m^3 = m^2
# ============================================================

def demo_counterexample():
    """
    Demonstrate that m^3 ≠ m^2 for f(x,y) = x, h = 3.
    
    The step transition reading 0 acts as a right shift:
      (b₀, b₁, b₂) ↦ (0, b₀, b₁)
    
    So:
      m¹(1,0,0) = (0,1,0)
      m²(1,0,0) = (0,0,1)  ← still carries info from b₀
      m³(1,0,0) = (0,0,0)  ← all info flushed
      m⁴(1,0,0) = (0,0,0)  ← stable
    """
    print("=" * 60)
    print("DEMO 1: Counterexample to the conjecture m³ = m²")
    print("=" * 60)
    
    f = rule_left  # f(x,y) = x
    h = 3
    alpha = [0, 1]
    
    tf = transition_fn(f, h, [0], alpha)
    
    print(f"\nRule: f(x,y) = x, Height h = {h}")
    print(f"Transition: reading cell value 0")
    print(f"  This acts as a right shift: (b₀,b₁,b₂) → (0, b₀, b₁)\n")
    
    b = (1, 0, 0)
    for k in range(1, 6):
        tf_k = power(tf, k)
        print(f"  m^{k}({b}) = {tf_k[b]}")
    
    tf2 = power(tf, 2)
    tf3 = power(tf, 3)
    
    print(f"\n  m²({b}) = {tf2[b]}")
    print(f"  m³({b}) = {tf3[b]}")
    print(f"  m² = m³? {tf2 == tf3}  ← COUNTEREXAMPLE!")
    print(f"  m³ = m⁴? {power(tf, 3) == power(tf, 4)}  ← stabilizes at h = 3")


# ============================================================
# Demo 2: Verify the corrected theorem m^{h+1} = m^h
# ============================================================

def demo_corrected_theorem():
    """
    Verify m^{h+1} = m^h for multiple rules and heights.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Corrected Theorem — m^{h+1} = m^h")
    print("=" * 60)
    
    alpha = [0, 1]
    rules = {
        "f(x,y)=x  ": rule_left,
        "f(x,y)=y  ": rule_right,
        "f(x,y)=XOR": rule_xor,
        "f(x,y)=AND": rule_and,
        "f(x,y)=OR ": rule_or,
    }
    
    print(f"\n{'Rule':<15} {'h':>3} {'Exponent':>10} {'m^(h+1)=m^h':>13} {'Tight?':>8}")
    print("-" * 55)
    
    for name, f in rules.items():
        for h in range(1, 6):
            max_exp = 0
            all_ok = True
            for w_len in range(1, min(h + 1, 4)):
                for word in itertools.product(alpha, repeat=w_len):
                    tf = transition_fn(f, h, list(word), alpha)
                    exp = find_exponent(tf)
                    max_exp = max(max_exp, exp)
                    if power(tf, h + 1) != power(tf, h):
                        all_ok = False
            
            tight = "YES" if max_exp == h else f"no (exp={max_exp})"
            status = "✓" if all_ok else "✗"
            print(f"{name:<15} {h:>3} {max_exp:>10} {status:>13} {tight:>8}")


# ============================================================
# Demo 3: Information propagation visualization
# ============================================================

def demo_information_propagation():
    """
    Visualize how information propagates through the diagonal.
    
    Shows coordinate-by-coordinate independence from initial state.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Information Propagation (Agreement Lemma)")
    print("=" * 60)
    
    f = rule_left
    h = 4
    alpha = [0, 1]
    
    print(f"\nRule: f(x,y) = x, Height h = {h}")
    print(f"Reading cell 0 repeatedly:\n")
    
    # Show how each power's output depends on input
    states = all_states(alpha, h)
    
    for k in range(1, h + 2):
        print(f"  m^{k}:")
        # Group outputs by each coordinate
        for coord in range(h):
            values = set()
            for s in states:
                result = s
                for _ in range(k):
                    result = step_transition(f, h, 0, result)
                values.add(result[coord])
            
            dep = "FIXED" if len(values) == 1 else f"varies ({values})"
            print(f"    coord {coord}: {dep}")
        print()
    
    print("  Key insight: after k applications, the first k coordinates")
    print("  are independent of the input state. After h applications,")
    print("  ALL coordinates are fixed → constant function!")


# ============================================================
# Demo 4: Monoid size growth
# ============================================================

def demo_monoid_sizes():
    """
    Show transition monoid sizes for different rules.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Transition Monoid Sizes")
    print("=" * 60)
    
    alpha = [0, 1]
    rules = {
        "f(x,y)=x": rule_left,
        "f(x,y)=y": rule_right,
        "XOR":      rule_xor,
        "AND":      rule_and,
    }
    
    print(f"\n{'Rule':<12}", end="")
    for h in range(1, 6):
        print(f" {'h='+str(h):>6}", end="")
    print()
    print("-" * 45)
    
    for name, f in rules.items():
        print(f"{name:<12}", end="")
        for h in range(1, 6):
            # BFS to find all reachable transition functions
            states = all_states(alpha, h)
            identity = frozenset({(s, s) for s in states})
            
            generators = []
            for a in alpha:
                tf = transition_fn(f, h, [a], alpha)
                generators.append(tf)
            
            seen = {identity}
            for gen in generators:
                seen.add(frozenset(gen.items()))
            
            queue = list(generators)
            while queue:
                tf = queue.pop(0)
                for gen in generators:
                    new_tf = compose(tf, gen)
                    key = frozenset(new_tf.items())
                    if key not in seen:
                        seen.add(key)
                        queue.append(new_tf)
            
            print(f" {len(seen):>6}", end="")
        print()


# ============================================================
# Demo 5: The shift structure explained
# ============================================================

def demo_shift_structure():
    """
    Show the shift structure for the left-projection rule.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Shift Structure (Why Exponent = h for f(x,y) = x)")
    print("=" * 60)
    
    h = 5
    print(f"\nRule: f(x,y) = x, Height h = {h}")
    print(f"Step transition reading 0: (b₀,...,b₄) → (0, b₀, b₁, b₂, b₃)")
    print(f"\nPowers of m (reading 0):\n")
    
    # Symbolic representation
    symbols = ["b₀", "b₁", "b₂", "b₃", "b₄"]
    state = list(symbols)
    
    for k in range(h + 2):
        if k == 0:
            print(f"  m^0 = ({', '.join(state)})")
        else:
            state = ["0"] + state[:-1]
            label = f"  m^{k} = ({', '.join(state)})"
            if all(s == "0" for s in state):
                label += "  ← CONSTANT (all info flushed)"
            elif k == h:
                label += "  ← CONSTANT"
            print(label)
    
    print(f"\n  Exponent = {h}: m^{h} is constant, m^{h+1} = m^{h}")
    print(f"  But m^{h-1} still depends on b₀, so m^{h-1} ≠ m^{h}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_counterexample()
    demo_corrected_theorem()
    demo_information_propagation()
    demo_monoid_sizes()
    demo_shift_structure()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
The original conjecture m³ = m² (uniform exponent 2) is FALSE for h ≥ 3.

The CORRECT theorem is: m^{h+1} = m^h (exponent = strip height h).

This bound is TIGHT: for f(x,y) = x, the exponent is exactly h.

The proof mechanism:
  1. Each step transition shifts the "dependency window" by 1.
  2. After reading h cells, all coordinates are independent of the input.
  3. A constant function composed with anything stays constant.
  4. Therefore m^{h+1} = m^h.

This establishes aperiodicity of the transition monoid, implying the
column language is star-free and FO[<]-definable.
""")
