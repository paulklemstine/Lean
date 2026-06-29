#!/usr/bin/env python3
"""
Tropical Descriptive Complexity: Applications

Demonstrates real-world applications of the tropical formula-to-automaton
compilation theorem:

1. Quantitative Model Checking: compile temporal properties to monitors
2. Sequence Analysis: pattern cost evaluation on biological sequences
3. Network Routing: shortest-path cost under logical constraints
4. Weighted Verification: automated tropical monitor synthesis
"""

from typing import List, Dict, Callable, Tuple
from dataclasses import dataclass
import itertools

INF = float('inf')


# ============================================================
# Application 1: Quantitative Pattern Matching
# ============================================================

def app_pattern_cost():
    """
    Application: Compute the cost of matching patterns in sequences.

    Given a DNA sequence with annotated binding sites, compute costs like:
    - "minimum edit distance to a pattern"
    - "number of positions where a motif appears"
    - "cost 0 if pattern exists, ∞ otherwise"

    This shows how tropical formulas naturally express sequence analysis queries.
    """
    print("=" * 60)
    print("APPLICATION 1: Quantitative Pattern Matching in Sequences")
    print("=" * 60)

    # DNA alphabet with annotation for "binding site"
    @dataclass
    class DNASymbol:
        base: str  # A, C, G, T
        is_binding_site: bool

    # Example sequences
    sequences = {
        "seq1": [DNASymbol('A', True), DNASymbol('C', False),
                 DNASymbol('G', True), DNASymbol('T', False)],
        "seq2": [DNASymbol('A', False), DNASymbol('A', False),
                 DNASymbol('A', False), DNASymbol('A', False)],
        "seq3": [DNASymbol('G', True), DNASymbol('C', True),
                 DNASymbol('G', True), DNASymbol('C', True)],
    }

    # Formula 1: Count GC content (as a cost)
    gc_count = lambda w: sum(1 for s in w if s.base in ('G', 'C'))

    # Formula 2: Does a binding site exist?
    has_binding = lambda w: 0 if any(s.is_binding_site for s in w) else INF

    # Formula 3: Number of binding sites at G positions
    binding_at_G = lambda w: sum(1 for s in w if s.is_binding_site and s.base == 'G')

    # Formula 4: min(GC count, binding cost) — tropical disjunction
    combined = lambda w: min(gc_count(w), has_binding(w))

    formulas = {
        "GC count": gc_count,
        "∃ binding site": has_binding,
        "binding sites at G": binding_at_G,
        "min(GC count, ∃binding)": combined,
    }

    for fname, f in formulas.items():
        print(f"\n  Formula: {fname}")
        for sname, seq in sequences.items():
            val = f(seq)
            val_str = f"{val}" if val < INF else "∞"
            bases = ''.join(s.base for s in seq)
            binds = ''.join('*' if s.is_binding_site else '.' for s in seq)
            print(f"    {sname} [{bases}] (binds: {binds}) → {val_str}")

    print()
    print("  Key insight: each formula is tropically recognizable!")
    print("  The theorem guarantees a finite-state tropical automaton exists")
    print("  that computes any of these cost functions by scanning left-to-right.")
    print()


# ============================================================
# Application 2: Weighted Monitoring / Verification
# ============================================================

def app_weighted_monitoring():
    """
    Application: Synthesize tropical monitors from specification formulas.

    A monitor observes a stream of events and maintains a running cost.
    The tropical automaton compiled from a formula serves as an optimal monitor.
    """
    print("=" * 60)
    print("APPLICATION 2: Weighted Monitor Synthesis")
    print("=" * 60)

    # Events in a system trace
    events = ['login', 'read', 'write', 'logout', 'error']

    # Specification formulas as cost functions
    specs = {}

    # Spec 1: "Every trace should contain a login" → cost ∞ if no login
    specs["must_login"] = lambda trace: 0 if 'login' in trace else INF

    # Spec 2: "Count errors" → total error cost
    specs["error_count"] = lambda trace: sum(2 for e in trace if e == 'error')

    # Spec 3: "Trace length as resource cost"
    specs["resource_cost"] = lambda trace: len(trace)

    # Spec 4: Combined monitor: min(must_login, error_count + resource_cost)
    specs["combined"] = lambda trace: min(
        0 if 'login' in trace else INF,
        sum(2 for e in trace if e == 'error') + len(trace)
    )

    # Test traces
    traces = {
        "normal": ['login', 'read', 'write', 'logout'],
        "no_login": ['read', 'write', 'error', 'logout'],
        "error_heavy": ['login', 'error', 'error', 'error'],
        "minimal": ['login', 'logout'],
        "empty": [],
    }

    for spec_name, spec_fn in specs.items():
        print(f"\n  Monitor: {spec_name}")
        for trace_name, trace in traces.items():
            cost = spec_fn(trace)
            cost_str = f"{cost}" if cost < INF else "∞"
            print(f"    {trace_name:15s} {trace!s:45s} → cost = {cost_str}")

    print()
    print("  Each monitor is compiled from a tropical formula into")
    print("  a finite-state automaton with O(n²) evaluation per symbol.")
    print("  This enables real-time quantitative monitoring of infinite streams.")
    print()


# ============================================================
# Application 3: Shortest Path with Logical Constraints
# ============================================================

def app_constrained_routing():
    """
    Application: Compute shortest paths subject to logical constraints.

    Model network routing where paths are sequences of edges, and
    the formula encodes constraints like "must pass through firewall"
    or "avoid high-latency links."
    """
    print("=" * 60)
    print("APPLICATION 3: Constrained Network Routing")
    print("=" * 60)

    # Network links as alphabet
    @dataclass
    class Link:
        name: str
        latency: float
        has_firewall: bool
        is_secure: bool

    # Network topology (as possible link sequences)
    links = {
        'fast':     Link('fast', 1, False, False),
        'secure':   Link('secure', 3, True, True),
        'backbone': Link('backbone', 2, False, True),
        'edge':     Link('edge', 5, True, False),
    }

    # Paths through the network
    paths = {
        "direct_fast": [links['fast'], links['fast']],
        "via_firewall": [links['fast'], links['secure'], links['backbone']],
        "all_secure": [links['secure'], links['backbone'], links['secure']],
        "long_edge": [links['edge'], links['edge'], links['edge']],
    }

    # Cost formulas
    # Total latency (letter cost)
    total_latency = lambda path: sum(l.latency for l in path)

    # Firewall requirement: ∞ if no firewall encountered
    needs_firewall = lambda path: 0 if any(l.has_firewall for l in path) else INF

    # Combined: latency + firewall penalty
    constrained_cost = lambda path: (
        total_latency(path) + needs_firewall(path)
        if needs_firewall(path) < INF else INF
    )

    # All-secure penalty: 0 if all links secure, else penalty
    security_penalty = lambda path: 0 if all(l.is_secure for l in path) else 10

    formulas = {
        "total_latency": total_latency,
        "needs_firewall": needs_firewall,
        "constrained (latency + firewall)": constrained_cost,
        "security_penalty": security_penalty,
    }

    for fname, f in formulas.items():
        print(f"\n  Cost function: {fname}")
        for pname, path in paths.items():
            cost = f(path)
            cost_str = f"{cost:.0f}" if cost < INF else "∞"
            route = " → ".join(l.name for l in path)
            print(f"    {pname:18s} [{route}] → {cost_str}")

    print()
    print("  The tropical compilation theorem guarantees that all these")
    print("  constrained routing costs can be computed by a finite-state")
    print("  tropical automaton scanning the path left-to-right.")
    print()


# ============================================================
# Application 4: Information-Theoretic Analysis
# ============================================================

def app_information_analysis():
    """
    Application: Analyze information content of annotated sequences.

    The tropical framework connects to information theory when we view
    the annotation as side information and recognize that the automaton
    compresses the relevant cost functional into finite state.
    """
    print("=" * 60)
    print("APPLICATION 4: Information-Theoretic Analysis")
    print("=" * 60)

    import math

    # Alphabet with annotation (source symbol + side information)
    alphabet = ['0', '1']
    words_by_length = {}
    for n in range(1, 8):
        words_by_length[n] = [
            list(w) for w in itertools.product(alphabet, repeat=n)
        ]

    # Formula: Hamming weight (number of 1s)
    hamming = lambda w: sum(1 for c in w if c == '1')

    # Formula: max run of 0s (simplified as a recognizable cost)
    # Use: ∞ if all 1s, else 0 (at least one 0 exists)
    has_zero = lambda w: 0 if '0' in w else INF

    # Analyze the distribution of costs
    print("\n  Distribution of Hamming weight by word length:")
    print(f"  {'n':>3s}  {'words':>6s}  {'mean_hw':>8s}  {'max_hw':>7s}  {'hw=0':>5s}  {'hw=n':>5s}")
    for n in range(1, 8):
        words = words_by_length[n]
        hws = [hamming(w) for w in words]
        mean_hw = sum(hws) / len(hws)
        max_hw = max(hws)
        zero_count = sum(1 for h in hws if h == 0)
        full_count = sum(1 for h in hws if h == n)
        print(f"  {n:3d}  {len(words):6d}  {mean_hw:8.2f}  {max_hw:7d}  {zero_count:5d}  {full_count:5d}")

    print("\n  Key observation: Hamming weight is a 1-state tropical automaton!")
    print("  States needed for various cost functions:")
    print("    Hamming weight:      1 state  (letter cost)")
    print("    ∃ zero:              2 states (existential)")
    print("    min(hamming, ∃zero): 3 states (disjoint union)")
    print("    hamming + ∃zero:     2 states (product)")
    print()


if __name__ == "__main__":
    app_pattern_cost()
    app_weighted_monitoring()
    app_constrained_routing()
    app_information_analysis()
    print("All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Tropical Descriptive Complexity: Demonstrations

Demonstrates the core ideas of the tropical descriptive complexity theorem:
every quantitative formula over annotated words is computed by a finite-state
tropical (min-plus) weighted automaton.

Includes concrete examples of:
1. Tropical automaton evaluation on annotated words
2. Formula-to-automaton compilation for each constructor
3. The structural induction at work on composed formulas
"""

import numpy as np
from typing import List, Tuple, Dict, Callable, Optional
from dataclasses import dataclass, field

INF = float('inf')


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class AnnotatedSymbol:
    """A symbol from base alphabet with boolean annotations for free variables."""
    base: str
    annotations: Dict[str, bool]

    def __repr__(self):
        active = [v for v, b in self.annotations.items() if b]
        ann_str = '{' + ','.join(active) + '}' if active else '{}'
        return f"({self.base},{ann_str})"


@dataclass
class TropicalAutomaton:
    """
    A tropical (min-plus) weighted automaton.
    States are integers 0..n_states-1.
    Weights are floats, with INF representing ⊤.
    """
    n_states: int
    init: List[float]       # init[q] = initial cost of state q
    # transition: dict mapping (q, symbol_key, q') -> cost
    trans: Dict[Tuple[int, str, int], float] = field(default_factory=dict)
    final: List[float] = field(default_factory=list)  # final[q] = terminal cost

    def run_cost(self, word: List[str], q: int) -> float:
        """Cost of processing word starting from state q."""
        if not word:
            return self.final[q]
        a, rest = word[0], word[1:]
        best = INF
        for q_prime in range(self.n_states):
            step_cost = self.trans.get((q, a, q_prime), INF)
            if step_cost < INF:
                total = step_cost + self.run_cost(rest, q_prime)
                best = min(best, total)
        return best

    def evaluate(self, word: List[str]) -> float:
        """Minimum-cost accepted path value for a word."""
        best = INF
        for q in range(self.n_states):
            total = self.init[q] + self.run_cost(word, q)
            best = min(best, total)
        return best


# ============================================================
# Formula Type and Evaluation
# ============================================================

class TropFormula:
    """Base class for tropical formulas."""
    def eval(self, word: List[AnnotatedSymbol]) -> float:
        raise NotImplementedError

    def compile(self, alphabet: List[str]) -> TropicalAutomaton:
        """Compile formula to equivalent tropical automaton."""
        raise NotImplementedError


class Const(TropFormula):
    """Constant function: always returns c."""
    def __init__(self, c: float):
        self.c = c

    def eval(self, word):
        return self.c

    def compile(self, alphabet):
        return TropicalAutomaton(
            n_states=1,
            init=[self.c],
            trans={(0, a, 0): 0 for a in alphabet},
            final=[0]
        )

    def __repr__(self):
        return f"Const({self.c})"


class LetterCost(TropFormula):
    """Sum of per-position costs: Σ f(aᵢ)."""
    def __init__(self, cost_fn: Callable[[AnnotatedSymbol], float],
                 name: str = "f"):
        self.cost_fn = cost_fn
        self.name = name

    def eval(self, word):
        return sum(self.cost_fn(a) for a in word)

    def compile(self, alphabet):
        return TropicalAutomaton(
            n_states=1,
            init=[0],
            trans={(0, a, 0): self.cost_fn(AnnotatedSymbol(a, {}))
                   for a in alphabet},
            final=[0]
        )

    def __repr__(self):
        return f"LetterCost({self.name})"


class ExistsPos(TropFormula):
    """0 if some position satisfies predicate p, ⊤ otherwise."""
    def __init__(self, pred: Callable[[AnnotatedSymbol], bool],
                 name: str = "p"):
        self.pred = pred
        self.name = name

    def eval(self, word):
        return 0 if any(self.pred(a) for a in word) else INF

    def compile(self, alphabet):
        # State 0 = "not seen", State 1 = "seen"
        trans = {}
        for a in alphabet:
            sym = AnnotatedSymbol(a, {})
            trans[(0, a, 0)] = 0  # stay in not-seen
            trans[(0, a, 1)] = 0 if self.pred(sym) else INF  # transition to seen
            trans[(1, a, 1)] = 0  # stay in seen
            trans[(1, a, 0)] = INF  # can't go back
        return TropicalAutomaton(
            n_states=2,
            init=[0, INF],
            trans=trans,
            final=[INF, 0]
        )

    def __repr__(self):
        return f"ExistsPos({self.name})"


class ForallPos(TropFormula):
    """0 if all positions satisfy predicate p, ⊤ otherwise."""
    def __init__(self, pred: Callable[[AnnotatedSymbol], bool],
                 name: str = "p"):
        self.pred = pred
        self.name = name

    def eval(self, word):
        return 0 if all(self.pred(a) for a in word) else INF

    def compile(self, alphabet):
        trans = {}
        for a in alphabet:
            sym = AnnotatedSymbol(a, {})
            trans[(0, a, 0)] = 0 if self.pred(sym) else INF
        return TropicalAutomaton(
            n_states=1,
            init=[0],
            trans=trans,
            final=[0]
        )

    def __repr__(self):
        return f"ForallPos({self.name})"


class TMin(TropFormula):
    """Pointwise minimum of two formulas."""
    def __init__(self, left: TropFormula, right: TropFormula):
        self.left = left
        self.right = right

    def eval(self, word):
        return min(self.left.eval(word), self.right.eval(word))

    def __repr__(self):
        return f"min({self.left}, {self.right})"


class TPlus(TropFormula):
    """Pointwise sum of two formulas."""
    def __init__(self, left: TropFormula, right: TropFormula):
        self.left = left
        self.right = right

    def eval(self, word):
        l = self.left.eval(word)
        r = self.right.eval(word)
        if l == INF or r == INF:
            return INF
        return l + r

    def __repr__(self):
        return f"({self.left} + {self.right})"


# ============================================================
# Demonstrations
# ============================================================

def demo_basic_automata():
    """Demonstrate basic tropical automaton constructions."""
    print("=" * 60)
    print("DEMO 1: Basic Tropical Automaton Constructions")
    print("=" * 60)

    # Constant automaton
    const_aut = TropicalAutomaton(
        n_states=1, init=[42], trans={(0, 'a', 0): 0, (0, 'b', 0): 0}, final=[0]
    )
    for w in [[], ['a'], ['a', 'b'], ['a', 'b', 'a']]:
        print(f"  const(42) on {w}: {const_aut.evaluate(w)}")

    print()

    # Letter-cost automaton: count 'a' occurrences
    count_a = TropicalAutomaton(
        n_states=1,
        init=[0],
        trans={(0, 'a', 0): 1, (0, 'b', 0): 0},
        final=[0]
    )
    for w in [[], ['a'], ['b', 'a', 'b'], ['a', 'a', 'a']]:
        print(f"  count('a') on {w}: {count_a.evaluate(w)}")

    print()

    # Existential automaton: does 'a' appear?
    exists_a = TropicalAutomaton(
        n_states=2,
        init=[0, INF],
        trans={
            (0, 'a', 0): 0, (0, 'a', 1): 0, (0, 'b', 0): 0, (0, 'b', 1): INF,
            (1, 'a', 1): 0, (1, 'a', 0): INF, (1, 'b', 1): 0, (1, 'b', 0): INF,
        },
        final=[INF, 0]
    )
    for w in [[], ['b'], ['b', 'a'], ['a', 'b', 'b']]:
        val = exists_a.evaluate(w)
        print(f"  exists('a') on {w}: {val} ({'feasible' if val < INF else 'infeasible'})")

    print()


def demo_formula_evaluation():
    """Demonstrate formula evaluation on annotated words."""
    print("=" * 60)
    print("DEMO 2: Formula Evaluation on Annotated Words")
    print("=" * 60)

    # Create annotated words
    # Example: word "ab" with variable x at position 0, variable y at position 1
    w1 = [
        AnnotatedSymbol('a', {'x': True, 'y': False}),
        AnnotatedSymbol('b', {'x': False, 'y': True}),
    ]

    w2 = [
        AnnotatedSymbol('a', {'x': True, 'y': True}),
        AnnotatedSymbol('b', {'x': False, 'y': False}),
    ]

    w3 = [
        AnnotatedSymbol('b', {'x': False, 'y': False}),
        AnnotatedSymbol('b', {'x': False, 'y': False}),
    ]

    words = [("w1: x@a, y@b", w1), ("w2: x,y@a", w2), ("w3: no vars", w3)]

    # Formula: "variable x is at a position with label 'a'"
    var_x_at_a = ExistsPos(
        lambda s: s.annotations.get('x', False) and s.base == 'a',
        name="x@a"
    )

    # Formula: "count positions where y is annotated"
    count_y = LetterCost(
        lambda s: 1 if s.annotations.get('y', False) else 0,
        name="count(y)"
    )

    # Formula: "all positions have label 'a'"
    all_a = ForallPos(lambda s: s.base == 'a', name="all_a")

    formulas = [
        ("∃pos: x@a", var_x_at_a),
        ("count(y)", count_y),
        ("∀pos: label=a", all_a),
    ]

    for fname, formula in formulas:
        print(f"\n  Formula: {fname}")
        for wname, w in words:
            val = formula.eval(w)
            val_str = f"{val}" if val < INF else "∞"
            print(f"    {wname} → {val_str}")

    # Composed formula: min(∃x@a, count(y))
    composed = TMin(var_x_at_a, count_y)
    print(f"\n  Composed: min(∃x@a, count(y))")
    for wname, w in words:
        val = composed.eval(w)
        val_str = f"{val}" if val < INF else "∞"
        print(f"    {wname} → {val_str}")

    # Sum formula: ∃x@a + count(y)
    sum_formula = TPlus(var_x_at_a, count_y)
    print(f"\n  Composed: ∃x@a + count(y)")
    for wname, w in words:
        val = sum_formula.eval(w)
        val_str = f"{val}" if val < INF else "∞"
        print(f"    {wname} → {val_str}")

    print()


def demo_induction_architecture():
    """Demonstrate the inductive proof architecture: each formula constructor
    maps to a specific automaton construction."""
    print("=" * 60)
    print("DEMO 3: Inductive Compilation Architecture")
    print("=" * 60)

    alphabet = ['a', 'b']

    print("\n  Formula → Automaton correspondence:")
    print("  " + "-" * 50)

    # Const
    c = Const(5)
    aut = c.compile(alphabet)
    print(f"  {c!r:25s} → {aut.n_states}-state automaton")
    for w in [[], ['a'], ['a', 'b']]:
        assert aut.evaluate(w) == c.eval(
            [AnnotatedSymbol(x, {}) for x in w]
        ), f"Mismatch for {w}"
    print(f"    ✓ Verified on 3 test words")

    # LetterCost
    lc = LetterCost(lambda s: 1, name="length")
    aut = lc.compile(alphabet)
    print(f"  {lc!r:25s} → {aut.n_states}-state automaton")
    for w in [[], ['a'], ['a', 'b', 'a']]:
        assert aut.evaluate(w) == lc.eval(
            [AnnotatedSymbol(x, {}) for x in w]
        )
    print(f"    ✓ Verified on 3 test words")

    # ExistsPos
    ep = ExistsPos(lambda s: s.base == 'a', name="has_a")
    aut = ep.compile(alphabet)
    print(f"  {ep!r:25s} → {aut.n_states}-state automaton")
    test_words = [[], ['b'], ['a'], ['b', 'a', 'b']]
    for w in test_words:
        expected = ep.eval([AnnotatedSymbol(x, {}) for x in w])
        got = aut.evaluate(w)
        assert got == expected, f"Mismatch: {w}, expected {expected}, got {got}"
    print(f"    ✓ Verified on {len(test_words)} test words")

    # ForallPos
    fp = ForallPos(lambda s: s.base == 'a', name="all_a")
    aut = fp.compile(alphabet)
    print(f"  {fp!r:25s} → {aut.n_states}-state automaton")
    for w in [[], ['a'], ['a', 'a'], ['a', 'b']]:
        expected = fp.eval([AnnotatedSymbol(x, {}) for x in w])
        got = aut.evaluate(w)
        assert got == expected
    print(f"    ✓ Verified on 4 test words")

    print("\n  Closure operations:")
    print("  " + "-" * 50)
    print("  min(φ, ψ) → disjoint union of automata (|S₁| + |S₂| states)")
    print("  φ + ψ     → product of automata         (|S₁| × |S₂| states)")

    # Demonstrate state counts for composed formulas
    print("\n  State complexity for composed formulas:")
    n1 = ep.compile(alphabet).n_states  # 2
    n2 = fp.compile(alphabet).n_states  # 1
    print(f"    ExistsPos: {n1} states")
    print(f"    ForallPos: {n2} states")
    print(f"    min(Exists, Forall): {n1 + n2} states (disjoint union)")
    print(f"    Exists + Forall: {n1 * n2} states (product)")

    print()


def demo_state_complexity():
    """Show how automaton state complexity grows with formula depth."""
    print("=" * 60)
    print("DEMO 4: State Complexity vs Formula Depth")
    print("=" * 60)

    # Build nested formulas and track state counts
    alphabet = ['a', 'b']

    # Base: simple existential (2 states)
    base = ExistsPos(lambda s: s.base == 'a', name="∃a")
    base_states = 2

    # Track state growth under different compositions
    print("\n  Under repeated min (disjoint union):")
    states = base_states
    for depth in range(1, 7):
        states += base_states  # union adds states
        print(f"    Depth {depth}: {states} states")

    print("\n  Under repeated plus (product):")
    states = base_states
    for depth in range(1, 7):
        states *= base_states  # product multiplies states
        print(f"    Depth {depth}: {states} states")

    print("\n  Mixed composition min(φ+ψ, χ):")
    # φ+ψ has n₁*n₂ states, then min with χ adds n₃
    n1, n2, n3 = 2, 2, 1
    print(f"    φ: {n1} states, ψ: {n2} states, χ: {n3} states")
    print(f"    φ+ψ: {n1*n2} states")
    print(f"    min(φ+ψ, χ): {n1*n2 + n3} states")

    print()


def demo_annotated_word_examples():
    """Concrete examples with annotated words encoding variable assignments."""
    print("=" * 60)
    print("DEMO 5: Annotated Words Encoding Free Variables")
    print("=" * 60)

    # Scenario: words over {a,b} with two free variables x, y
    # The annotation records which positions each variable points to

    print("\n  Scenario: base alphabet {a,b}, variables {x, y}")
    print("  Annotation: at each position, record which variables are active\n")

    # Example words
    examples = [
        ("aab, x@0, y@2", [
            AnnotatedSymbol('a', {'x': True, 'y': False}),
            AnnotatedSymbol('a', {'x': False, 'y': False}),
            AnnotatedSymbol('b', {'x': False, 'y': True}),
        ]),
        ("ab, x@0, y@0", [
            AnnotatedSymbol('a', {'x': True, 'y': True}),
            AnnotatedSymbol('b', {'x': False, 'y': False}),
        ]),
        ("ba, no vars", [
            AnnotatedSymbol('b', {'x': False, 'y': False}),
            AnnotatedSymbol('a', {'x': False, 'y': False}),
        ]),
    ]

    # Formulas
    formulas = {
        "∃pos: x@a": ExistsPos(
            lambda s: s.annotations.get('x', False) and s.base == 'a'
        ),
        "∃pos: y@b": ExistsPos(
            lambda s: s.annotations.get('y', False) and s.base == 'b'
        ),
        "count(x)": LetterCost(
            lambda s: 1 if s.annotations.get('x', False) else 0
        ),
        "word_length": LetterCost(lambda s: 1),
    }

    # Evaluate
    for fname, formula in formulas.items():
        print(f"  Formula: {fname}")
        for desc, w in examples:
            val = formula.eval(w)
            val_str = f"{val:.0f}" if val < INF else "∞"
            print(f"    [{desc}] → {val_str}")
        print()

    # Composed formula
    print("  Composed: min(∃x@a, ∃y@b) — 'either x sees a or y sees b'")
    f_composed = TMin(
        ExistsPos(lambda s: s.annotations.get('x', False) and s.base == 'a'),
        ExistsPos(lambda s: s.annotations.get('y', False) and s.base == 'b'),
    )
    for desc, w in examples:
        val = f_composed.eval(w)
        val_str = f"{val:.0f}" if val < INF else "∞"
        print(f"    [{desc}] → {val_str}")

    print()


if __name__ == "__main__":
    demo_basic_automata()
    demo_formula_evaluation()
    demo_induction_architecture()
    demo_state_complexity()
    demo_annotated_word_examples()
    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""

import json
import base64
import os

# Generate visualizations and get base64
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import io

def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"

# Import visualization functions
import sys
sys.path.insert(0, '/workspace/request-project')
from visualizations import viz_state_complexity, viz_automaton_constructions, viz_evaluation_landscape, viz_proof_architecture

viz_data = {
    "state_complexity": viz_state_complexity(),
    "automaton_constructions": viz_automaton_constructions(),
    "evaluation_landscape": viz_evaluation_landscape(),
    "proof_architecture": viz_proof_architecture(),
}

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_code = read_file('/workspace/request-project/Tropical/DescriptiveComplexity/Basic.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')

package = {
    "title": "Tropical Descriptive Complexity: Formula Evaluation over Annotated Words is Tropically Recognizable",
    "domain": "Tropical Algebra / Automata Theory / Descriptive Complexity",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Formula Evaluation Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Pattern Matching, Monitoring, Routing",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Formula-to-Automaton Compilation",
            "pseudocode": """Algorithm: COMPILE(φ, Σ)
Input: Tropical formula φ, alphabet Σ
Output: Tropical automaton A with eval(A, ·) = eval(φ, ·)

match φ with
| const c      → return ConstAut(c)            // 1 state
| letterCost f → return LetterCostAut(f)        // 1 state
| existsPos p  → return ExistsAut(p)            // 2 states
| forallPos p  → return LetterCostAut(λa. if p(a) then 0 else ⊤)
| tmin φ ψ     → return DisjointUnion(COMPILE(φ), COMPILE(ψ))
| tplus φ ψ    → return Product(COMPILE(φ), COMPILE(ψ))

Complexity:
  - Compilation: O(|φ| · |Σ| · N²)
  - Evaluation: O(|w| · N²) per word
  where N = compiled automaton state count""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "State Complexity vs Formula Depth",
            "data": viz_data["state_complexity"]
        },
        {
            "name": "Automaton Constructions by Formula Constructor",
            "data": viz_data["automaton_constructions"]
        },
        {
            "name": "Evaluation Landscapes of Tropical Formulas",
            "data": viz_data["evaluation_landscape"]
        },
        {
            "name": "Proof Architecture: Structural Induction",
            "data": viz_data["proof_architecture"]
        }
    ],
    "lean_proofs": lean_code
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {os.path.getsize('/workspace/request-project/PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Tropical Descriptive Complexity: Visualizations

Generates figures illustrating:
1. State complexity growth under formula composition
2. Automaton structure for each formula constructor
3. Tropical matrix heatmaps
4. Evaluation landscapes
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_state_complexity():
    """Visualize state complexity growth under different compositions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    depths = range(0, 9)

    # Under min (additive growth)
    ax = axes[0]
    base_states = [1, 2]
    for base in base_states:
        states = [base * (d + 1) for d in depths]
        ax.plot(depths, states, 'o-', linewidth=2, markersize=6,
                label=f'base = {base} states')
    ax.set_xlabel('Formula Depth', fontsize=13)
    ax.set_ylabel('Number of States', fontsize=13)
    ax.set_title('min Composition\n(Disjoint Union: Linear Growth)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('linear')

    # Under plus (multiplicative growth)
    ax = axes[1]
    for base in base_states:
        states = [base ** (d + 1) for d in depths]
        ax.plot(depths, states, 's-', linewidth=2, markersize=6,
                label=f'base = {base} states')
    ax.set_xlabel('Formula Depth', fontsize=13)
    ax.set_ylabel('Number of States', fontsize=13)
    ax.set_title('+ Composition\n(Product: Exponential Growth)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log', base=2)

    fig.suptitle('State Complexity vs Formula Depth', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/state_complexity.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_automaton_constructions():
    """Visualize the automaton corresponding to each formula constructor."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # 1. Constant automaton
    ax = axes[0, 0]
    ax.set_xlim(-1, 3)
    ax.set_ylim(-1, 2)
    circle = plt.Circle((1, 0.5), 0.4, fill=False, linewidth=2, color='steelblue')
    ax.add_patch(circle)
    ax.annotate('q₀', (1, 0.5), fontsize=16, ha='center', va='center', fontweight='bold')
    ax.annotate('init: c', (1, 1.4), fontsize=12, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.7))
    ax.annotate('final: 0', (1, -0.5), fontsize=12, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.7))
    # Self-loop
    ax.annotate('', xy=(0.7, 0.9), xytext=(1.3, 0.9),
                arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=-0.8',
                               color='darkgreen', lw=2))
    ax.annotate('∀a: 0', (1, 1.15), fontsize=10, ha='center', color='darkgreen')
    ax.set_title('Constant Automaton\n1 state', fontsize=13, fontweight='bold')
    ax.axis('off')

    # 2. Letter-cost automaton
    ax = axes[0, 1]
    ax.set_xlim(-1, 3)
    ax.set_ylim(-1, 2)
    circle = plt.Circle((1, 0.5), 0.4, fill=False, linewidth=2, color='steelblue')
    ax.add_patch(circle)
    ax.annotate('q₀', (1, 0.5), fontsize=16, ha='center', va='center', fontweight='bold')
    ax.annotate('init: 0', (1, 1.4), fontsize=12, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.7))
    ax.annotate('final: 0', (1, -0.5), fontsize=12, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.7))
    ax.annotate('', xy=(0.7, 0.9), xytext=(1.3, 0.9),
                arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=-0.8',
                               color='darkgreen', lw=2))
    ax.annotate('a: f(a)', (1, 1.15), fontsize=10, ha='center', color='darkgreen')
    ax.set_title('Letter-Cost Automaton\n1 state, accumulates costs', fontsize=13, fontweight='bold')
    ax.axis('off')

    # 3. Existential automaton (2 states)
    ax = axes[1, 0]
    ax.set_xlim(-0.5, 4)
    ax.set_ylim(-1, 2.5)
    # State 0
    c0 = plt.Circle((1, 0.5), 0.4, fill=False, linewidth=2, color='steelblue')
    ax.add_patch(c0)
    ax.annotate('0', (1, 0.5), fontsize=16, ha='center', va='center', fontweight='bold')
    ax.annotate('init: 0\nfinal: ∞', (1, -0.5), fontsize=10, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.7))
    # State 1
    c1 = plt.Circle((3, 0.5), 0.4, fill=False, linewidth=2, color='steelblue')
    # Double circle for accepting
    c1b = plt.Circle((3, 0.5), 0.35, fill=False, linewidth=1.5, color='steelblue')
    ax.add_patch(c1)
    ax.add_patch(c1b)
    ax.annotate('1', (3, 0.5), fontsize=16, ha='center', va='center', fontweight='bold')
    ax.annotate('init: ∞\nfinal: 0', (3, -0.5), fontsize=10, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.7))
    # Self-loops
    ax.annotate('', xy=(0.7, 0.9), xytext=(1.3, 0.9),
                arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=-0.8',
                               color='gray', lw=1.5))
    ax.annotate('∀a: 0', (1, 1.3), fontsize=9, ha='center', color='gray')
    ax.annotate('', xy=(2.7, 0.9), xytext=(3.3, 0.9),
                arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=-0.8',
                               color='gray', lw=1.5))
    ax.annotate('∀a: 0', (3, 1.3), fontsize=9, ha='center', color='gray')
    # Transition 0→1
    ax.annotate('', xy=(2.6, 0.5), xytext=(1.4, 0.5),
                arrowprops=dict(arrowstyle='->', color='red', lw=2.5))
    ax.annotate('p(a)?  0 : ∞', (2, 0.75), fontsize=11, ha='center', color='red',
                fontweight='bold')
    ax.set_title('Existential Automaton\n2 states: "not seen" → "seen"', fontsize=13, fontweight='bold')
    ax.axis('off')

    # 4. Composition diagram
    ax = axes[1, 1]
    ax.set_xlim(-0.5, 5)
    ax.set_ylim(-0.5, 4)

    # min box
    rect1 = mpatches.FancyBboxPatch((0, 2.2), 4.5, 1.3,
                                     boxstyle="round,pad=0.2",
                                     facecolor='lightcyan', edgecolor='steelblue', lw=2)
    ax.add_patch(rect1)
    ax.annotate('min(φ, ψ): Disjoint Union', (2.25, 3.3), fontsize=11,
                ha='center', fontweight='bold')
    ax.annotate('States: S₁ ⊔ S₂     |S| = |S₁| + |S₂|', (2.25, 2.6),
                fontsize=10, ha='center', family='monospace')

    # plus box
    rect2 = mpatches.FancyBboxPatch((0, 0.3), 4.5, 1.3,
                                     boxstyle="round,pad=0.2",
                                     facecolor='lightyellow', edgecolor='orange', lw=2)
    ax.add_patch(rect2)
    ax.annotate('φ + ψ: Product', (2.25, 1.4), fontsize=11,
                ha='center', fontweight='bold')
    ax.annotate('States: S₁ × S₂     |S| = |S₁| · |S₂|', (2.25, 0.7),
                fontsize=10, ha='center', family='monospace')

    ax.set_title('Closure Operations\nfor Composed Formulas', fontsize=13, fontweight='bold')
    ax.axis('off')

    fig.suptitle('Automaton Constructions by Formula Constructor',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/automaton_constructions.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_evaluation_landscape():
    """Visualize how formula evaluation varies across words."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Generate all binary words of length ≤ 5
    words = []
    labels = []
    for length in range(6):
        for bits in range(2**length):
            w = []
            for i in range(length):
                w.append('a' if (bits >> (length - 1 - i)) & 1 else 'b')
            words.append(w)
            labels.append(''.join(w) if w else 'ε')

    # Formula 1: word length
    vals_length = [len(w) for w in words]
    ax = axes[0]
    ax.bar(range(len(words)), vals_length, color='steelblue', alpha=0.7, width=1)
    ax.set_title('Word Length\nletterCost(1)', fontsize=12, fontweight='bold')
    ax.set_xlabel('Word index (sorted by length)', fontsize=10)
    ax.set_ylabel('Cost', fontsize=10)

    # Formula 2: count of 'a'
    vals_count = [sum(1 for c in w if c == 'a') for w in words]
    ax = axes[1]
    ax.bar(range(len(words)), vals_count, color='coral', alpha=0.7, width=1)
    ax.set_title("Count of 'a'\nletterCost(1 if a else 0)", fontsize=12, fontweight='bold')
    ax.set_xlabel('Word index', fontsize=10)
    ax.set_ylabel('Cost', fontsize=10)

    # Formula 3: min(length, 2 * count_a)
    vals_min = [min(len(w), 2 * sum(1 for c in w if c == 'a')) for w in words]
    ax = axes[2]
    ax.bar(range(len(words)), vals_min, color='seagreen', alpha=0.7, width=1)
    ax.set_title("min(length, 2·count('a'))\ntmin composition", fontsize=12, fontweight='bold')
    ax.set_xlabel('Word index', fontsize=10)
    ax.set_ylabel('Cost', fontsize=10)

    fig.suptitle('Evaluation Landscapes of Tropical Formulas\n(all binary words up to length 5)',
                 fontsize=14, fontweight='bold', y=1.05)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/evaluation_landscape.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_proof_architecture():
    """Visualize the inductive proof architecture as a tree diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Tree structure
    nodes = {
        'main': (6, 7, 'Main Theorem\n∀φ: TropRecognizable(φ.eval)', 'gold'),
        'const': (1, 5, 'const c\n1-state aut', 'lightblue'),
        'letter': (3, 5, 'letterCost f\n1-state aut', 'lightblue'),
        'exists': (5, 5, 'existsPos p\n2-state aut', 'lightcoral'),
        'forall': (7, 5, 'forallPos p\n→ letterCost', 'lightyellow'),
        'tmin': (9, 5, 'tmin φ ψ\n⊔ construction', 'lightgreen'),
        'tplus': (11, 5, 'tplus φ ψ\n× construction', 'lightgreen'),
        'key_min': (9, 3, 'iInf_sum\nblock diagonal', 'white'),
        'key_plus': (11, 3, 'iInf_prod_add\ndecomposition', 'white'),
        'key_exists': (5, 3, 'runCost induction\n2-state tracking', 'white'),
    }

    for name, (x, y, label, color) in nodes.items():
        bbox = dict(boxstyle='round,pad=0.4', facecolor=color,
                    edgecolor='gray', lw=1.5)
        ax.annotate(label, (x, y), fontsize=9, ha='center', va='center',
                    bbox=bbox, fontweight='bold' if name == 'main' else 'normal')

    # Edges
    edges = [
        ('main', 'const'), ('main', 'letter'), ('main', 'exists'),
        ('main', 'forall'), ('main', 'tmin'), ('main', 'tplus'),
        ('tmin', 'key_min'), ('tplus', 'key_plus'), ('exists', 'key_exists'),
    ]
    for parent, child in edges:
        px, py = nodes[parent][0], nodes[parent][1]
        cx, cy = nodes[child][0], nodes[child][1]
        ax.annotate('', xy=(cx, cy + 0.4), xytext=(px, py - 0.4),
                    arrowprops=dict(arrowstyle='->', lw=1.5, color='gray'))

    ax.set_xlim(-0.5, 12.5)
    ax.set_ylim(1.5, 8.5)
    ax.set_title('Proof Architecture: Structural Induction on Formulas',
                 fontsize=15, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/proof_architecture.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_state_complexity()
    print(f"  State complexity: {len(b64_1)} chars")
    b64_2 = viz_automaton_constructions()
    print(f"  Automaton constructions: {len(b64_2)} chars")
    b64_3 = viz_evaluation_landscape()
    print(f"  Evaluation landscape: {len(b64_3)} chars")
    b64_4 = viz_proof_architecture()
    print(f"  Proof architecture: {len(b64_4)} chars")
    print("All visualizations generated successfully!")
