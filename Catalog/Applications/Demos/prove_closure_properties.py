#!/usr/bin/env python3
"""
Applications of Tropical Tree Automata Closure Properties

Real-world applications demonstrating the practical impact of the
closure theorems for weighted tree automata.
"""

import math
import random
from typing import Dict, List, Tuple

from algorithms import RTree, TropicalWTA, product_automaton, union_automaton, family_inf_automaton


# ══════════════════════════════════════════════════════════════════
# Application 1: Multi-Objective Parse Tree Optimization
# ══════════════════════════════════════════════════════════════════

def app_parsing():
    """
    Natural language parsing with multiple cost criteria.
    
    Uses product automaton to simultaneously optimize:
    - Syntactic complexity (prefer simpler structures)
    - Semantic plausibility (prefer likely interpretations)
    
    The product theorem guarantees the combined automaton
    correctly adds both costs.
    """
    print("=" * 60)
    print("APPLICATION 1: Multi-Objective Parsing")
    print("=" * 60)

    arity = {'word': 0, 'NP': 2, 'VP': 2, 'PP': 2, 'S': 2}

    # Syntactic complexity automaton
    # Lower cost = simpler structure
    syntax_costs = {'word': 0, 'NP': 1, 'VP': 2, 'PP': 3, 'S': 1}
    A_syntax = TropicalWTA(
        states=['ok'],
        arity=arity,
        delta=lambda s, cs, q: syntax_costs.get(s, math.inf),
        final_cost=lambda q: 0
    )

    # Semantic plausibility automaton
    # Different cost model emphasizing VP
    sem_costs = {'word': 0, 'NP': 2, 'VP': 0.5, 'PP': 1, 'S': 1.5}
    A_semantic = TropicalWTA(
        states=['ok'],
        arity=arity,
        delta=lambda s, cs, q: sem_costs.get(s, math.inf),
        final_cost=lambda q: 0
    )

    # Three candidate parse trees for "the cat sat on the mat"
    # Parse 1: S(NP(word,word), VP(word, PP(word, NP(word,word))))
    parse1 = RTree('S', [
        RTree('NP', [RTree('word'), RTree('word')]),
        RTree('VP', [RTree('word'), RTree('PP', [
            RTree('word'), RTree('NP', [RTree('word'), RTree('word')])])])
    ])

    # Parse 2: S(NP(word,word), VP(VP(word,word), PP(word,word)))
    parse2 = RTree('S', [
        RTree('NP', [RTree('word'), RTree('word')]),
        RTree('VP', [
            RTree('VP', [RTree('word'), RTree('word')]),
            RTree('PP', [RTree('word'), RTree('word')])])
    ])

    A_combined = product_automaton(A_syntax, A_semantic)

    print("\nCandidate parse trees:")
    for i, parse in enumerate([parse1, parse2], 1):
        syn = A_syntax.eval(parse)
        sem = A_semantic.eval(parse)
        combined = A_combined.eval(parse)
        print(f"  Parse {i}: syntax={syn:.1f}, semantic={sem:.1f}, combined={combined:.1f}")
        assert abs(combined - (syn + sem)) < 1e-10

    print("\n  Product automaton correctly combines both objectives.")

    # Union: find the best parse under EITHER criterion
    A_best = union_automaton(A_syntax, A_semantic)
    for i, parse in enumerate([parse1, parse2], 1):
        best = A_best.eval(parse)
        expected = min(A_syntax.eval(parse), A_semantic.eval(parse))
        print(f"  Parse {i} best-of-either: {best:.1f} (min of {A_syntax.eval(parse):.1f}, {A_semantic.eval(parse):.1f})")
        assert abs(best - expected) < 1e-10

    print("  ✓ Union automaton correctly selects best criterion")


# ══════════════════════════════════════════════════════════════════
# Application 2: Circuit Cost Analysis
# ══════════════════════════════════════════════════════════════════

def app_circuits():
    """
    Analyzing costs of Boolean circuit (formula) evaluation.
    
    Trees represent circuits; automata assign costs to gates.
    Product automaton combines area cost and delay cost.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Circuit Cost Analysis")
    print("=" * 60)

    arity = {'input': 0, 'AND': 2, 'OR': 2, 'NOT': 1}

    # Area cost: each gate has unit area
    area_costs = {'input': 0, 'AND': 1, 'OR': 1, 'NOT': 0.5}
    A_area = TropicalWTA(
        states=[0],
        arity=arity,
        delta=lambda s, cs, q: area_costs.get(s, math.inf),
        final_cost=lambda q: 0
    )

    # Delay cost: critical path delay
    delay_costs = {'input': 0, 'AND': 2, 'OR': 2, 'NOT': 1}
    A_delay = TropicalWTA(
        states=[0],
        arity=arity,
        delta=lambda s, cs, q: delay_costs.get(s, math.inf),
        final_cost=lambda q: 0
    )

    # Circuit: OR(AND(input, NOT(input)), AND(input, input))
    circuit = RTree('OR', [
        RTree('AND', [RTree('input'), RTree('NOT', [RTree('input')])]),
        RTree('AND', [RTree('input'), RTree('input')])
    ])

    print(f"\nCircuit: {circuit}")
    area = A_area.eval(circuit)
    delay = A_delay.eval(circuit)
    print(f"  Area cost:  {area}")
    print(f"  Delay cost: {delay}")

    A_total = product_automaton(A_area, A_delay)
    total = A_total.eval(circuit)
    print(f"  Combined (area + delay): {total}")
    assert abs(total - (area + delay)) < 1e-10
    print("  ✓ Product closure gives combined area-delay metric")


# ══════════════════════════════════════════════════════════════════
# Application 3: Ensemble Model Selection
# ══════════════════════════════════════════════════════════════════

def app_ensemble():
    """
    Ensemble of hierarchical models selecting the best prediction.
    
    Multiple tree-structured models (each a WTA) assign costs.
    The union/family-inf construction selects the best model
    for each input tree.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Ensemble Model Selection")
    print("=" * 60)

    arity = {'x': 0, 'h1': 2, 'h2': 2, 'out': 1}

    # Create an ensemble of 4 models with different specializations
    models = []
    specializations = [
        {'x': 0, 'h1': 1, 'h2': 5, 'out': 0.5},  # Model 1: good at h1
        {'x': 0, 'h1': 4, 'h2': 1, 'out': 0.5},  # Model 2: good at h2
        {'x': 0, 'h1': 2, 'h2': 2, 'out': 3.0},  # Model 3: balanced
        {'x': 0, 'h1': 3, 'h2': 3, 'out': 0.1},  # Model 4: good output
    ]

    for spec in specializations:
        A = TropicalWTA(
            states=[0],
            arity=arity,
            delta=lambda s, cs, q, sp=spec: sp.get(s, math.inf),
            final_cost=lambda q: 0
        )
        models.append(A)

    # Test trees
    tree1 = RTree('out', [RTree('h1', [RTree('x'), RTree('x')])])
    tree2 = RTree('out', [RTree('h2', [RTree('x'), RTree('x')])])
    tree3 = RTree('out', [RTree('h1', [
        RTree('h2', [RTree('x'), RTree('x')]),
        RTree('x')])])

    print("\nIndividual model costs:")
    for j, tree in enumerate([tree1, tree2, tree3], 1):
        costs = [m.eval(tree) for m in models]
        print(f"  Tree {j} ({tree}): {costs}")

    # Family infimum
    ensemble = family_inf_automaton(models)
    print("\nEnsemble (family infimum) costs:")
    for j, tree in enumerate([tree1, tree2, tree3], 1):
        ens_cost = ensemble.eval(tree)
        ind_costs = [m.eval(tree) for m in models]
        expected = min(ind_costs)
        print(f"  Tree {j}: ensemble={ens_cost:.1f}, best_individual={expected:.1f}")
        assert abs(ens_cost - expected) < 1e-10

    print("  ✓ Family infimum correctly selects best model per input")


# ══════════════════════════════════════════════════════════════════
# Application 4: Dynamic Programming on Syntax Trees
# ══════════════════════════════════════════════════════════════════

def app_dynamic_programming():
    """
    Demonstrates how tree automata closure enables compositional
    dynamic programming: solving multiple optimization problems
    simultaneously over the same tree structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Compositional Dynamic Programming")
    print("=" * 60)

    arity = {'val': 0, 'add': 2, 'mul': 2, 'neg': 1}

    # Objective 1: minimize operation count
    A_ops = TropicalWTA(
        states=[0],
        arity=arity,
        delta=lambda s, cs, q: 0 if s == 'val' else 1,
        final_cost=lambda q: 0
    )

    # Objective 2: minimize depth
    A_depth = TropicalWTA(
        states=[0],
        arity=arity,
        delta=lambda s, cs, q: 0 if s == 'val' else 1,
        final_cost=lambda q: 0
    )

    # Objective 3: minimize "mul cost" (muls cost 3, adds cost 1)
    costs3 = {'val': 0, 'add': 1, 'mul': 3, 'neg': 0.5}
    A_weighted = TropicalWTA(
        states=[0],
        arity=arity,
        delta=lambda s, cs, q: costs3.get(s, math.inf),
        final_cost=lambda q: 0
    )

    # Expression tree: mul(add(val, neg(val)), mul(val, val))
    expr = RTree('mul', [
        RTree('add', [RTree('val'), RTree('neg', [RTree('val')])]),
        RTree('mul', [RTree('val'), RTree('val')])
    ])

    print(f"\nExpression tree: {expr}")
    print(f"  Operation count: {A_ops.eval(expr)}")
    print(f"  Depth:           {A_depth.eval(expr)}")
    print(f"  Weighted cost:   {A_weighted.eval(expr)}")

    # Combined objective via product
    A_combined = product_automaton(A_ops, product_automaton(A_depth, A_weighted))
    combined = A_combined.eval(expr)
    expected = A_ops.eval(expr) + A_depth.eval(expr) + A_weighted.eval(expr)
    print(f"\n  Triple product (all costs summed): {combined}")
    print(f"  Sum of individuals:               {expected}")
    assert abs(combined - expected) < 1e-10
    print("  ✓ Compositional DP combines three objectives correctly")

    # Best single objective via family infimum
    best = family_inf_automaton([A_ops, A_depth, A_weighted])
    best_cost = best.eval(expr)
    expected_best = min(A_ops.eval(expr), A_depth.eval(expr), A_weighted.eval(expr))
    print(f"\n  Best single objective: {best_cost}")
    print(f"  Expected minimum:     {expected_best}")
    assert abs(best_cost - expected_best) < 1e-10
    print("  ✓ Family infimum selects cheapest objective")


# ══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    app_parsing()
    app_circuits()
    app_ensemble()
    app_dynamic_programming()
    print("\n" + "=" * 60)
    print("All applications verified successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Weighted Tree Automata — Tropical Closure Properties

Demonstrates the core theorems with concrete numerical examples:
  1. Product automaton closure (eval_product): pointwise cost addition
  2. Union automaton closure (eval_union): pointwise cost minimization
  3. Finite family closure (eval_finset_inf): iterated infimum
"""

import math
from typing import Callable, Dict, List, Optional, Tuple

# ──────────────────────────────────────────────────────────────────
# Core data structures
# ──────────────────────────────────────────────────────────────────

class Tree:
    """A ranked tree: a symbol with children matching its arity."""
    def __init__(self, symbol: str, children: Optional[List['Tree']] = None):
        self.symbol = symbol
        self.children = children or []

    def __repr__(self):
        if not self.children:
            return self.symbol
        child_str = ", ".join(repr(c) for c in self.children)
        return f"{self.symbol}({child_str})"


class WTA:
    """
    Weighted Tree Automaton with tropical (min-plus) semantics.
    
    States: list of state labels (strings or ints)
    delta(symbol, child_states, target_state) -> cost (float, inf for impossible)
    final_cost(state) -> cost
    """
    def __init__(self, states, arity, delta, final_cost):
        self.states = states
        self.arity = arity  # symbol -> int
        self.delta = delta  # (symbol, tuple_of_child_states, target_state) -> float
        self.final_cost = final_cost  # state -> float

    def eval_state(self, tree: Tree, q) -> float:
        """Minimum cost of processing tree and arriving at state q."""
        ar = self.arity[tree.symbol]
        assert len(tree.children) == ar

        if ar == 0:
            # Leaf: only one assignment (empty tuple)
            return self.delta(tree.symbol, (), q)
        
        # Enumerate all child state assignments
        best = math.inf
        for assignment in _all_assignments(ar, self.states):
            cost = self.delta(tree.symbol, assignment, q)
            if cost == math.inf:
                continue
            for i in range(ar):
                cost += self.eval_state(tree.children[i], assignment[i])
                if cost == math.inf:
                    break
            best = min(best, cost)
        return best

    def eval(self, tree: Tree) -> float:
        """Minimum cost over all accepting runs."""
        return min(self.eval_state(tree, q) + self.final_cost(q)
                   for q in self.states)


def _all_assignments(n: int, states: list) -> list:
    """Generate all n-tuples of states."""
    if n == 0:
        return [()]
    sub = _all_assignments(n - 1, states)
    return [(s,) + rest for s in states for rest in sub]


# ──────────────────────────────────────────────────────────────────
# Product automaton construction
# ──────────────────────────────────────────────────────────────────

def product_automaton(A1: WTA, A2: WTA) -> WTA:
    """
    Construct the product automaton.
    States: (q1, q2) for q1 in A1.states, q2 in A2.states
    Theorem: eval(product) = eval(A1) + eval(A2)
    """
    states = [(q1, q2) for q1 in A1.states for q2 in A2.states]
    arity = A1.arity  # same signature

    def delta(sym, child_states, target):
        q1, q2 = target
        cs1 = tuple(c[0] for c in child_states)
        cs2 = tuple(c[1] for c in child_states)
        return A1.delta(sym, cs1, q1) + A2.delta(sym, cs2, q2)

    def final_cost(q):
        return A1.final_cost(q[0]) + A2.final_cost(q[1])

    return WTA(states, arity, delta, final_cost)


# ──────────────────────────────────────────────────────────────────
# Union automaton construction
# ──────────────────────────────────────────────────────────────────

def union_automaton(A1: WTA, A2: WTA) -> WTA:
    """
    Construct the union automaton.
    States: ('L', q1) or ('R', q2)
    Theorem: eval(union) = min(eval(A1), eval(A2))
    """
    states = [('L', q) for q in A1.states] + [('R', q) for q in A2.states]
    arity = A1.arity

    def delta(sym, child_states, target):
        side, tq = target
        if side == 'L':
            # All children must be 'L'
            if any(c[0] != 'L' for c in child_states):
                return math.inf
            cs = tuple(c[1] for c in child_states)
            return A1.delta(sym, cs, tq)
        else:
            # All children must be 'R'
            if any(c[0] != 'R' for c in child_states):
                return math.inf
            cs = tuple(c[1] for c in child_states)
            return A2.delta(sym, cs, tq)

    def final_cost(q):
        side, sq = q
        if side == 'L':
            return A1.final_cost(sq)
        else:
            return A2.final_cost(sq)

    return WTA(states, arity, delta, final_cost)


# ──────────────────────────────────────────────────────────────────
# Example 1: Arithmetic expression trees
# ──────────────────────────────────────────────────────────────────

def demo_arithmetic_expressions():
    """
    Two automata over arithmetic expression trees.
    A1 counts "depth of evaluation" (each operator adds 1).
    A2 counts "number of multiplications".
    Product automaton computes both costs simultaneously.
    """
    print("=" * 60)
    print("DEMO 1: Arithmetic Expression Trees")
    print("=" * 60)

    arity = {'num': 0, 'add': 2, 'mul': 2}

    # A1: depth automaton (counts max nesting depth)
    # States: 0 (processed)
    # Cost at each operator = 1, leaf = 0
    def delta1(sym, cs, q):
        if sym == 'num':
            return 0.0
        return 1.0  # each operation costs 1

    A1 = WTA([0], arity, delta1, lambda q: 0.0)

    # A2: multiplication counter
    # Cost = 1 for mul, 0 for add and num
    def delta2(sym, cs, q):
        if sym == 'mul':
            return 1.0
        return 0.0

    A2 = WTA([0], arity, delta2, lambda q: 0.0)

    # Tree: mul(add(num, num), num)  =  (a + b) * c
    tree = Tree('mul', [
        Tree('add', [Tree('num'), Tree('num')]),
        Tree('num')
    ])
    print(f"\nTree: {tree}")

    e1 = A1.eval(tree)
    e2 = A2.eval(tree)
    print(f"  A1 (depth count):           {e1}")
    print(f"  A2 (multiplication count):  {e2}")

    Aprod = product_automaton(A1, A2)
    ep = Aprod.eval(tree)
    print(f"  Product eval:               {ep}")
    print(f"  A1 + A2:                    {e1 + e2}")
    assert abs(ep - (e1 + e2)) < 1e-10, "Product theorem violated!"
    print("  ✓ Product theorem verified: eval(product) = eval(A1) + eval(A2)")

    Aunion = union_automaton(A1, A2)
    eu = Aunion.eval(tree)
    print(f"  Union eval:                 {eu}")
    print(f"  min(A1, A2):                {min(e1, e2)}")
    assert abs(eu - min(e1, e2)) < 1e-10, "Union theorem violated!"
    print("  ✓ Union theorem verified: eval(union) = min(eval(A1), eval(A2))")


# ──────────────────────────────────────────────────────────────────
# Example 2: Parse trees with weighted grammar
# ──────────────────────────────────────────────────────────────────

def demo_parse_trees():
    """
    Two weighted grammars assigning costs to parse trees.
    Demonstrates closure properties for tropical parsing.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Weighted Parse Trees")
    print("=" * 60)

    arity = {'word': 0, 'NP': 2, 'VP': 2, 'S': 2}

    # Grammar 1: prefers right-branching structures
    def delta_g1(sym, cs, q):
        costs = {'word': 0, 'NP': 1.5, 'VP': 2.0, 'S': 1.0}
        return costs.get(sym, math.inf)

    G1 = WTA(['accept'], arity, delta_g1, lambda q: 0)

    # Grammar 2: penalizes deep nesting
    def delta_g2(sym, cs, q):
        costs = {'word': 0, 'NP': 3.0, 'VP': 1.0, 'S': 2.5}
        return costs.get(sym, math.inf)

    G2 = WTA(['accept'], arity, delta_g2, lambda q: 0)

    # Parse tree: S(NP(word, word), VP(word, word))
    tree = Tree('S', [
        Tree('NP', [Tree('word'), Tree('word')]),
        Tree('VP', [Tree('word'), Tree('word')])
    ])
    print(f"\nParse tree: {tree}")

    e1 = G1.eval(tree)
    e2 = G2.eval(tree)
    print(f"  Grammar 1 cost: {e1}")
    print(f"  Grammar 2 cost: {e2}")

    Gprod = product_automaton(G1, G2)
    ep = Gprod.eval(tree)
    print(f"\n  Product (combined cost):  {ep}")
    print(f"  G1 + G2:                  {e1 + e2}")
    assert abs(ep - (e1 + e2)) < 1e-10
    print("  ✓ Product closure verified")

    Gunion = union_automaton(G1, G2)
    eu = Gunion.eval(tree)
    print(f"\n  Union (best grammar):     {eu}")
    print(f"  min(G1, G2):              {min(e1, e2)}")
    assert abs(eu - min(e1, e2)) < 1e-10
    print("  ✓ Union closure verified")


# ──────────────────────────────────────────────────────────────────
# Example 3: Multiple automata — finite family closure
# ──────────────────────────────────────────────────────────────────

def demo_finite_family():
    """
    Demonstrates finite family closure: the infimum over a family
    of automata is realized by an iterated union.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Finite Family Closure")
    print("=" * 60)

    arity = {'leaf': 0, 'branch': 2}

    # Create 5 automata with different cost functions
    automata = []
    for k in range(5):
        weight = (k + 1) * 0.5  # 0.5, 1.0, 1.5, 2.0, 2.5

        def make_delta(w):
            def delta(sym, cs, q):
                return 0 if sym == 'leaf' else w
            return delta

        A = WTA([0], arity, make_delta(weight), lambda q: 0)
        automata.append(A)

    tree = Tree('branch', [
        Tree('branch', [Tree('leaf'), Tree('leaf')]),
        Tree('leaf')
    ])
    print(f"\nTree: {tree}")

    individual_evals = [A.eval(tree) for A in automata]
    print(f"  Individual costs: {individual_evals}")

    # Build iterated union
    result = automata[0]
    for A in automata[1:]:
        result = union_automaton(result, A)

    union_eval = result.eval(tree)
    family_inf = min(individual_evals)
    print(f"  Iterated union eval: {union_eval}")
    print(f"  Family infimum:      {family_inf}")
    assert abs(union_eval - family_inf) < 1e-10
    print("  ✓ Finite family closure verified")


# ──────────────────────────────────────────────────────────────────
# Example 4: State complexity bounds
# ──────────────────────────────────────────────────────────────────

def demo_state_complexity():
    """
    Demonstrates state complexity: |Q1 × Q2| = |Q1| * |Q2|
    and |Q1 ⊕ Q2| = |Q1| + |Q2|.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: State Complexity Bounds")
    print("=" * 60)

    arity = {'a': 0, 'f': 1}

    A1 = WTA(list(range(3)), arity,
             lambda s, cs, q: 1.0, lambda q: 0.0)
    A2 = WTA(list(range(5)), arity,
             lambda s, cs, q: 2.0, lambda q: 0.0)

    Aprod = product_automaton(A1, A2)
    Aunion = union_automaton(A1, A2)

    print(f"\n  |Q1| = {len(A1.states)}")
    print(f"  |Q2| = {len(A2.states)}")
    print(f"  |Q1 × Q2| (product states) = {len(Aprod.states)}")
    print(f"  |Q1| * |Q2|                = {len(A1.states) * len(A2.states)}")
    assert len(Aprod.states) == len(A1.states) * len(A2.states)
    print("  ✓ Product state bound verified")

    print(f"  |Q1 ⊕ Q2| (union states)   = {len(Aunion.states)}")
    print(f"  |Q1| + |Q2|                = {len(A1.states) + len(A2.states)}")
    assert len(Aunion.states) == len(A1.states) + len(A2.states)
    print("  ✓ Union state bound verified")


# ──────────────────────────────────────────────────────────────────
# Example 5: Monotonicity
# ──────────────────────────────────────────────────────────────────

def demo_monotonicity():
    """
    Demonstrates monotonicity: if A1 ≤ A1' and A2 ≤ A2' pointwise,
    then product(A1,A2) ≤ product(A1',A2') pointwise.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Monotonicity of Product Construction")
    print("=" * 60)

    arity = {'a': 0, 'f': 2}

    def make_automaton(leaf_cost, branch_cost):
        return WTA([0], arity,
                   lambda s, cs, q, lc=leaf_cost, bc=branch_cost:
                       lc if s == 'a' else bc,
                   lambda q: 0.0)

    A1 = make_automaton(1.0, 2.0)
    A1_prime = make_automaton(2.0, 3.0)  # A1' ≥ A1 pointwise
    A2 = make_automaton(0.5, 1.5)
    A2_prime = make_automaton(1.0, 2.0)  # A2' ≥ A2 pointwise

    trees = [
        Tree('a'),
        Tree('f', [Tree('a'), Tree('a')]),
        Tree('f', [Tree('f', [Tree('a'), Tree('a')]), Tree('a')]),
    ]

    P1 = product_automaton(A1, A2)
    P2 = product_automaton(A1_prime, A2_prime)

    print()
    all_ok = True
    for t in trees:
        e1 = P1.eval(t)
        e2 = P2.eval(t)
        ok = e1 <= e2 + 1e-10
        print(f"  Tree {t!r:40s}: product(A,B)={e1:.1f}  product(A',B')={e2:.1f}  {'✓' if ok else '✗'}")
        all_ok = all_ok and ok

    assert all_ok, "Monotonicity violated!"
    print("  ✓ Monotonicity verified for all test trees")


# ──────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    demo_arithmetic_expressions()
    demo_parse_trees()
    demo_finite_family()
    demo_state_complexity()
    demo_monotonicity()
    print("\n" + "=" * 60)
    print("All demos passed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables bundled."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Tropical/TreeAutomata/Basic.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_code = read_file('visualizations.py')

# Read visualizations as base64
viz_product = read_binary_base64('fig_product.png')
viz_union = read_binary_base64('fig_union.png')
viz_complexity = read_binary_base64('fig_complexity.png')
viz_family = read_binary_base64('fig_family.png')

package = {
    "title": "Closure Properties of Weighted Tree Automata over the Tropical Semiring",
    "domain": "Tropical Algebra / Automata Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Tree Automata Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Bottom-Up Tropical Evaluation",
            "pseudocode": "EVAL-STATE(A, node(a, c₁,...,cₖ), q):\n  best ← ∞\n  for each (q₁,...,qₖ) ∈ Q^k:\n    cost ← δ(a, (q₁,...,qₖ), q)\n    for i = 1 to k:\n      cost ← cost + EVAL-STATE(A, cᵢ, qᵢ)\n    best ← min(best, cost)\n  return best\n\nEVAL(A, t):\n  return min_{q ∈ Q} EVAL-STATE(A, t, q) + final(q)",
            "code": algorithms_code
        },
        {
            "name": "Product Automaton Construction",
            "pseudocode": "PRODUCT(A₁, A₂):\n  States: Q₁ × Q₂\n  δ(a, f, (q₁,q₂)) = δ₁(a, fst∘f, q₁) + δ₂(a, snd∘f, q₂)\n  final(q₁,q₂) = final₁(q₁) + final₂(q₂)\n\nCorrectness: eval(PRODUCT(A₁,A₂), t) = eval(A₁,t) + eval(A₂,t)",
            "code": algorithms_code
        },
        {
            "name": "Union Automaton Construction",
            "pseudocode": "UNION(A₁, A₂):\n  States: Q₁ ⊕ Q₂\n  δ(a, f, inl(q₁)) = δ₁(a, extract(f), q₁) if all f(i) ∈ Q₁; else ⊤\n  δ(a, f, inr(q₂)) = δ₂(a, extract(f), q₂) if all f(i) ∈ Q₂; else ⊤\n  final(inl(q₁)) = final₁(q₁), final(inr(q₂)) = final₂(q₂)\n\nCorrectness: eval(UNION(A₁,A₂), t) = min(eval(A₁,t), eval(A₂,t))",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Product Automaton Cost Decomposition",
            "data": viz_product
        },
        {
            "name": "Union Automaton Infimum Behavior",
            "data": viz_union
        },
        {
            "name": "State Complexity Growth",
            "data": viz_complexity
        },
        {
            "name": "Family Infimum Convergence",
            "data": viz_family
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.0f} KB)")


#!/usr/bin/env python3
"""
Visualizations for Tropical Tree Automata Closure Properties

Generates figures showing:
1. Product automaton cost decomposition
2. Union automaton infimum behavior
3. State complexity growth
4. Family infimum convergence
"""

import math
import os
import base64
from io import BytesIO

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

from algorithms import RTree, TropicalWTA, product_automaton, union_automaton, family_inf_automaton


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64-encoded PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    buf.close()
    return f"data:image/png;base64,{data}"


# ──────────────────────────────────────────────────────────────────
# Figure 1: Product Automaton Cost Decomposition
# ──────────────────────────────────────────────────────────────────

def fig_product_decomposition():
    """Show eval(product) = eval(A1) + eval(A2) across many trees."""
    arity = {'a': 0, 'b': 0, 'f': 2, 'g': 1}

    def make_automaton(weights):
        return TropicalWTA(
            states=[0, 1],
            arity=arity,
            delta=lambda s, cs, q, w=weights: w.get(s, {}).get(q, math.inf),
            final_cost=lambda q: 0
        )

    w1 = {'a': {0: 1, 1: 3}, 'b': {0: 2, 1: 1}, 'f': {0: 2, 1: 3}, 'g': {0: 1, 1: 2}}
    w2 = {'a': {0: 3, 1: 1}, 'b': {0: 1, 1: 4}, 'f': {0: 1, 1: 2}, 'g': {0: 2, 1: 1}}

    A1 = make_automaton(w1)
    A2 = make_automaton(w2)
    Aprod = product_automaton(A1, A2)

    # Generate random trees
    def random_tree(max_depth=3):
        if max_depth <= 0:
            return RTree(np.random.choice(['a', 'b']))
        sym = np.random.choice(['a', 'b', 'f', 'g'], p=[0.2, 0.2, 0.4, 0.2])
        ar = arity[sym]
        children = [random_tree(max_depth - 1) for _ in range(ar)]
        return RTree(sym, children)

    np.random.seed(42)
    trees = [random_tree(d) for d in range(5) for _ in range(8)]

    e1_vals = [A1.eval(t) for t in trees]
    e2_vals = [A2.eval(t) for t in trees]
    ep_vals = [Aprod.eval(t) for t in trees]
    sum_vals = [a + b for a, b in zip(e1_vals, e2_vals)]

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: scatter plot
    ax = axes[0]
    ax.scatter(sum_vals, ep_vals, c='#2196F3', alpha=0.7, s=50, edgecolors='white', linewidth=0.5)
    lim = max(max(sum_vals), max(ep_vals)) * 1.1
    ax.plot([0, lim], [0, lim], 'k--', alpha=0.3, label='y = x')
    ax.set_xlabel('eval(A₁, t) + eval(A₂, t)', fontsize=12)
    ax.set_ylabel('eval(product(A₁, A₂), t)', fontsize=12)
    ax.set_title('Product Theorem Verification', fontsize=14)
    ax.legend()
    ax.set_aspect('equal')

    # Right: stacked bar chart
    ax = axes[1]
    indices = list(range(min(15, len(trees))))
    bar_width = 0.7
    e1_plot = [e1_vals[i] for i in indices]
    e2_plot = [e2_vals[i] for i in indices]
    ep_plot = [ep_vals[i] for i in indices]

    ax.bar(indices, e1_plot, bar_width, label='eval(A₁)', color='#4CAF50', alpha=0.8)
    ax.bar(indices, e2_plot, bar_width, bottom=e1_plot, label='eval(A₂)', color='#FF9800', alpha=0.8)
    ax.scatter(indices, ep_plot, color='red', zorder=5, s=30, label='eval(product)', marker='D')
    ax.set_xlabel('Tree index', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Cost Decomposition', fontsize=14)
    ax.legend()

    plt.tight_layout()
    data_uri = fig_to_base64(fig)
    fig.savefig('fig_product.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return data_uri


# ──────────────────────────────────────────────────────────────────
# Figure 2: Union Automaton Infimum Behavior
# ──────────────────────────────────────────────────────────────────

def fig_union_infimum():
    """Show eval(union) = min(eval(A1), eval(A2))."""
    arity = {'x': 0, 'f': 2}

    costs1 = {'x': {0: 2, 1: 1}, 'f': {0: 3, 1: 4}}
    costs2 = {'x': {0: 1, 1: 3}, 'f': {0: 1, 1: 5}}

    A1 = TropicalWTA([0, 1], arity,
        lambda s, cs, q: costs1[s][q], lambda q: 0)
    A2 = TropicalWTA([0, 1], arity,
        lambda s, cs, q: costs2[s][q], lambda q: 0)
    Au = union_automaton(A1, A2)

    def gen_trees(depth):
        if depth == 0:
            return [RTree('x')]
        sub = gen_trees(depth - 1)
        result = list(sub)
        for l in sub:
            for r in sub:
                result.append(RTree('f', [l, r]))
        return result

    trees = gen_trees(2)[:30]
    e1 = [A1.eval(t) for t in trees]
    e2 = [A2.eval(t) for t in trees]
    eu = [Au.eval(t) for t in trees]
    mn = [min(a, b) for a, b in zip(e1, e2)]

    fig, ax = plt.subplots(figsize=(10, 5))
    x = range(len(trees))
    ax.plot(x, e1, 'o-', color='#4CAF50', alpha=0.7, markersize=5, label='eval(A₁)')
    ax.plot(x, e2, 's-', color='#2196F3', alpha=0.7, markersize=5, label='eval(A₂)')
    ax.plot(x, eu, 'D-', color='#F44336', alpha=0.9, markersize=6, label='eval(union)')

    # Shade the "winner" regions
    for i in x:
        if e1[i] < e2[i]:
            ax.axvspan(i - 0.3, i + 0.3, alpha=0.1, color='#4CAF50')
        else:
            ax.axvspan(i - 0.3, i + 0.3, alpha=0.1, color='#2196F3')

    ax.set_xlabel('Tree index', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Union Theorem: eval(union) = min(eval(A₁), eval(A₂))', fontsize=14)
    ax.legend(fontsize=11)

    plt.tight_layout()
    data_uri = fig_to_base64(fig)
    fig.savefig('fig_union.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return data_uri


# ──────────────────────────────────────────────────────────────────
# Figure 3: State Complexity Growth
# ──────────────────────────────────────────────────────────────────

def fig_state_complexity():
    """State complexity of iterated product vs union."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Product: multiplicative growth
    n_iters = range(1, 8)
    base_sizes = [2, 3, 5]
    ax = axes[0]
    for base in base_sizes:
        sizes = [base ** n for n in n_iters]
        ax.semilogy(list(n_iters), sizes, 'o-', label=f'|Q| = {base}', linewidth=2)
    ax.set_xlabel('Number of products', fontsize=12)
    ax.set_ylabel('State space size (log)', fontsize=12)
    ax.set_title('Product: |Q₁ × ⋯ × Qₙ| = |Q|ⁿ', fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Union: additive growth
    ax = axes[1]
    for base in base_sizes:
        sizes = [base * n for n in n_iters]
        ax.plot(list(n_iters), sizes, 'o-', label=f'|Q| = {base}', linewidth=2)
    ax.set_xlabel('Number of unions', fontsize=12)
    ax.set_ylabel('State space size', fontsize=12)
    ax.set_title('Union: |Q₁ ⊕ ⋯ ⊕ Qₙ| = n · |Q|', fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    data_uri = fig_to_base64(fig)
    fig.savefig('fig_complexity.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return data_uri


# ──────────────────────────────────────────────────────────────────
# Figure 4: Family Infimum Convergence
# ──────────────────────────────────────────────────────────────────

def fig_family_convergence():
    """Adding more models to the ensemble improves (decreases) cost."""
    arity = {'x': 0, 'f': 2}

    np.random.seed(123)
    n_models = 20
    models = []
    for _ in range(n_models):
        cx = np.random.uniform(0.5, 5)
        cf = np.random.uniform(0.5, 5)
        A = TropicalWTA([0], arity,
            lambda s, cs, q, cx_=cx, cf_=cf: cx_ if s == 'x' else cf_,
            lambda q: 0)
        models.append(A)

    tree = RTree('f', [
        RTree('f', [RTree('x'), RTree('x')]),
        RTree('f', [RTree('x'), RTree('f', [RTree('x'), RTree('x')])])
    ])

    individual_costs = [m.eval(tree) for m in models]
    family_costs = []
    for k in range(1, n_models + 1):
        B = family_inf_automaton(models[:k])
        family_costs.append(B.eval(tree))

    fig, ax = plt.subplots(figsize=(10, 5))
    x = range(1, n_models + 1)
    ax.bar(x, individual_costs, alpha=0.4, color='#9E9E9E', label='Individual cost')
    ax.plot(x, family_costs, 'D-', color='#F44336', linewidth=2,
            markersize=6, label='Family infimum (first k models)')
    ax.axhline(y=min(individual_costs), color='#4CAF50', linestyle='--',
               linewidth=1.5, label=f'Global minimum = {min(individual_costs):.2f}')
    ax.set_xlabel('Number of models in ensemble (k)', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Family Infimum: Cost Decreases as Ensemble Grows', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    data_uri = fig_to_base64(fig)
    fig.savefig('fig_family.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return data_uri


# ──────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("Generating visualizations...")
    uri1 = fig_product_decomposition()
    print("  ✓ fig_product.png")
    uri2 = fig_union_infimum()
    print("  ✓ fig_union.png")
    uri3 = fig_state_complexity()
    print("  ✓ fig_complexity.png")
    uri4 = fig_family_convergence()
    print("  ✓ fig_family.png")
    print("\nAll visualizations generated successfully.")
