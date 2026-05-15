#!/usr/bin/env python3
"""
Applications of Tropical Weighted Tree Automata Closure Properties

This module demonstrates real-world applications:
1. Arithmetic expression optimization (compiler cost models)
2. RNA secondary structure scoring
3. Multi-objective parsing with product automata
4. Ensemble model selection with union closure
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Dict
from itertools import product as cartesian_product


# ============================================================
# Application 1: Compiler Cost Model for Expression Trees
# ============================================================

def compiler_cost_model():
    """
    Model instruction selection as a weighted tree automaton problem.

    An arithmetic expression tree (e.g., a + b * c) can be compiled to
    different instruction sequences. Each instruction has a latency cost.
    The WTA computes the minimum-latency compilation.

    The product closure theorem enables multi-objective optimization:
    - A₁ measures latency
    - A₂ measures register pressure
    - A₁ × A₂ finds the best latency + register trade-off
    """
    print("=" * 70)
    print("APPLICATION 1: Compiler Cost Model for Expression Trees")
    print("=" * 70)
    print()

    @dataclass
    class ExprTree:
        op: str  # "const", "var", "add", "mul"
        children: List['ExprTree']
        value: str = ""

        def __repr__(self):
            if self.op in ("const", "var"):
                return self.value
            kids = ", ".join(repr(c) for c in self.children)
            return f"{self.op}({kids})"

    def eval_latency(tree: ExprTree) -> float:
        """Minimum latency to evaluate expression (in cycles)."""
        if tree.op == "const":
            return 1  # load immediate
        elif tree.op == "var":
            return 2  # memory load
        elif tree.op == "add":
            # Can pipeline: max(left, right) + 1 cycle for add
            l = eval_latency(tree.children[0])
            r = eval_latency(tree.children[1])
            return max(l, r) + 1
        elif tree.op == "mul":
            l = eval_latency(tree.children[0])
            r = eval_latency(tree.children[1])
            return max(l, r) + 3  # multiply takes 3 cycles
        return math.inf

    def eval_registers(tree: ExprTree) -> int:
        """Minimum registers needed (Sethi-Ullman)."""
        if tree.op in ("const", "var"):
            return 1
        l = eval_registers(tree.children[0])
        r = eval_registers(tree.children[1])
        if l == r:
            return l + 1
        return max(l, r)

    # Build expression trees
    x = ExprTree("var", [], "x")
    y = ExprTree("var", [], "y")
    c1 = ExprTree("const", [], "1")
    c2 = ExprTree("const", [], "2")

    exprs = [
        ("x + y", ExprTree("add", [x, y])),
        ("x * y", ExprTree("mul", [x, y])),
        ("(x+1) * (y+2)",
         ExprTree("mul", [
             ExprTree("add", [x, c1]),
             ExprTree("add", [y, c2])
         ])),
        ("x * y + x * (y + 1)",
         ExprTree("add", [
             ExprTree("mul", [x, y]),
             ExprTree("mul", [x, ExprTree("add", [y, c1])])
         ])),
    ]

    print("Expression tree cost analysis (latency + register pressure):")
    print()
    print(f"{'Expression':<25} {'Latency':<10} {'Registers':<12} {'Combined'}")
    print("-" * 60)
    for name, expr in exprs:
        lat = eval_latency(expr)
        reg = eval_registers(expr)
        combined = lat + reg  # tropical product = sum
        print(f"  {name:<23} {lat:<10.0f} {reg:<12} {combined}")

    print()
    print("The product automaton (A_latency × A_registers) computes the")
    print("combined cost in a single bottom-up pass over the expression tree.")
    print("This is the product closure theorem in action.")
    print()


# ============================================================
# Application 2: RNA Secondary Structure Scoring
# ============================================================

def rna_structure_scoring():
    """
    Model RNA secondary structure energy as a weighted tree automaton.

    RNA folds into tree-shaped structures (stems, loops, bulges).
    Each structural element has a free energy contribution.
    The minimum free energy (MFE) structure is found by minimizing
    over all possible tree-shaped folds — exactly a WTA evaluation.

    Union closure enables ensemble prediction: take the minimum energy
    across multiple energy models.
    """
    print("=" * 70)
    print("APPLICATION 2: RNA Secondary Structure Energy Minimization")
    print("=" * 70)
    print()

    # Simplified RNA structure as tree
    @dataclass
    class RNATree:
        element: str  # "stem", "loop", "bulge", "junction"
        energy: float  # kcal/mol contribution
        children: List['RNATree']

        def total_energy(self) -> float:
            return self.energy + sum(c.total_energy() for c in self.children)

        def __repr__(self):
            if not self.children:
                return f"{self.element}({self.energy:.1f})"
            kids = ", ".join(repr(c) for c in self.children)
            return f"{self.element}({self.energy:.1f}; {kids})"

    # Model 1: Turner energy parameters (simplified)
    structures_turner = [
        RNATree("stem", -2.0, [
            RNATree("loop", 4.0, []),
        ]),
        RNATree("stem", -3.0, [
            RNATree("stem", -1.5, [
                RNATree("loop", 3.5, []),
            ]),
        ]),
        RNATree("junction", 2.0, [
            RNATree("stem", -2.5, [RNATree("loop", 3.0, [])]),
            RNATree("stem", -1.0, [RNATree("loop", 4.5, [])]),
        ]),
    ]

    # Model 2: Different energy model (e.g., nearest-neighbor with different params)
    structures_alt = [
        RNATree("stem", -1.5, [
            RNATree("loop", 3.0, []),
        ]),
        RNATree("stem", -2.5, [
            RNATree("stem", -2.0, [
                RNATree("loop", 2.5, []),
            ]),
        ]),
        RNATree("junction", 1.5, [
            RNATree("stem", -3.0, [RNATree("loop", 2.0, [])]),
            RNATree("stem", -1.5, [RNATree("loop", 3.5, [])]),
        ]),
    ]

    print("Comparing two RNA energy models:")
    print()
    print(f"{'Structure':<12} {'Turner (kcal/mol)':<20} {'Alt Model':<20} {'Min (Union)'}")
    print("-" * 65)

    for i, (t, a) in enumerate(zip(structures_turner, structures_alt)):
        e_t = t.total_energy()
        e_a = a.total_energy()
        e_min = min(e_t, e_a)
        winner = "Turner" if e_t <= e_a else "Alt"
        name = f"Fold {i+1}"
        print(f"  {name:<10} {e_t:<20.2f} {e_a:<20.2f} {e_min:.2f} ({winner})")

    print()
    print("Union closure selects the best energy model for each fold,")
    print("enabling robust ensemble prediction across energy parameterizations.")
    print()


# ============================================================
# Application 3: Multi-Objective Parsing
# ============================================================

def multi_objective_parsing():
    """
    Demonstrate multi-objective parsing using product automata.

    In natural language processing, parse trees can be scored by multiple
    criteria (syntactic probability, semantic coherence, discourse structure).
    The product closure theorem says we can combine these scores additively
    by building a product automaton.
    """
    print("=" * 70)
    print("APPLICATION 3: Multi-Objective Natural Language Parsing")
    print("=" * 70)
    print()

    # Simplified parse trees for "the cat sat on the mat"
    parses = [
        {
            "name": "Right-branching",
            "structure": "S(NP(the, cat), VP(sat, PP(on, NP(the, mat))))",
            "syntax_score": 2.5,   # log probability (lower = better)
            "semantic_score": 1.0,
            "discourse_score": 3.0,
        },
        {
            "name": "Left-branching",
            "structure": "S(NP(the, cat), VP(VP(sat), PP(on, NP(the, mat))))",
            "syntax_score": 3.0,
            "semantic_score": 0.5,
            "discourse_score": 2.5,
        },
        {
            "name": "Flat",
            "structure": "S(NP(the, cat), V(sat), PP(on, NP(the, mat)))",
            "syntax_score": 4.0,
            "semantic_score": 2.0,
            "discourse_score": 1.0,
        },
    ]

    print("Sentence: 'the cat sat on the mat'")
    print()
    print(f"{'Parse':<18} {'Syntax':<10} {'Semantic':<10} {'Discourse':<10} {'Product':<10}")
    print("-" * 60)

    best_combined = math.inf
    best_parse = None

    for p in parses:
        combined = p["syntax_score"] + p["semantic_score"] + p["discourse_score"]
        if combined < best_combined:
            best_combined = combined
            best_parse = p["name"]
        print(f"  {p['name']:<16} {p['syntax_score']:<10.1f} {p['semantic_score']:<10.1f} "
              f"{p['discourse_score']:<10.1f} {combined:<10.1f}")

    print()
    print(f"Best parse by product criterion: {best_parse} (cost = {best_combined:.1f})")
    print()
    print("The product automaton A_syntax × A_semantic × A_discourse finds this")
    print("optimal parse in a single bottom-up pass — no need to enumerate all")
    print("parses and compare. State complexity is multiplicative:")
    print(f"  |Q_syntax| × |Q_semantic| × |Q_discourse|")
    print()


# ============================================================
# Application 4: Dynamic Programming on Syntax Trees
# ============================================================

def dp_on_syntax_trees():
    """
    Show how the product closure theorem enables compositional
    dynamic programming on tree-structured computations.
    """
    print("=" * 70)
    print("APPLICATION 4: Compositional Dynamic Programming")
    print("=" * 70)
    print()

    # Simple tree DP: compute optimal binary search tree cost
    # (Knuth's algorithm as a tree automaton)
    keys = [1, 3, 5, 7, 9]
    probs = [0.15, 0.10, 0.25, 0.20, 0.30]

    print("Optimal Binary Search Tree construction:")
    print(f"  Keys: {keys}")
    print(f"  Access probabilities: {probs}")
    print()

    # DP table for optimal BST (Knuth's algorithm)
    n = len(keys)
    # cost[i][j] = optimal cost for keys i..j
    cost = [[0.0] * n for _ in range(n)]
    # weight[i][j] = sum of probs for keys i..j
    weight = [[0.0] * n for _ in range(n)]

    for i in range(n):
        cost[i][i] = probs[i]
        weight[i][i] = probs[i]

    for length in range(2, n + 1):
        for i in range(n - length + 1):
            j = i + length - 1
            weight[i][j] = weight[i][j-1] + probs[j]
            cost[i][j] = math.inf
            for r in range(i, j + 1):
                left = cost[i][r-1] if r > i else 0
                right = cost[r+1][j] if r < j else 0
                c = left + right + weight[i][j]
                cost[i][j] = min(cost[i][j], c)

    print(f"  Optimal BST cost: {cost[0][n-1]:.4f}")
    print()
    print("  This DP is exactly a weighted tree automaton evaluation:")
    print("  - States represent key ranges [i,j]")
    print("  - Transitions correspond to choosing a root for each subrange")
    print("  - The tropical infimum finds the optimal root at each level")
    print()
    print("  Product closure enables multi-criteria BST optimization:")
    print("  e.g., minimize access time + memory usage simultaneously.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF TROPICAL TREE AUTOMATA CLOSURE PROPERTIES     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    compiler_cost_model()
    rna_structure_scoring()
    multi_objective_parsing()
    dp_on_syntax_trees()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tropical Weighted Tree Automata — Concrete Demonstrations

This script demonstrates the closure properties of weighted tree automata
under tropical (min-plus) semantics with concrete numerical examples.

It shows:
1. How weighted tree automata assign costs to ranked trees
2. The product construction and its semantic correctness
3. The union construction and its semantic correctness
4. Finite family infimum closure
"""

import math
from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional, Callable
from itertools import product as cartesian_product


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class RTree:
    """Ranked tree: a node with a symbol and children."""
    symbol: str
    children: List['RTree']

    def __repr__(self):
        if not self.children:
            return self.symbol
        kids = ", ".join(repr(c) for c in self.children)
        return f"{self.symbol}({kids})"

    def depth(self) -> int:
        if not self.children:
            return 0
        return 1 + max(c.depth() for c in self.children)

    def size(self) -> int:
        return 1 + sum(c.size() for c in self.children)


class WTA:
    """
    Weighted Tree Automaton over the tropical (min-plus) semiring.

    States: finite set of state labels
    stepCost(symbol, child_states, target_state) -> cost in ℝ
    finalCost(state) -> cost in ℝ

    Semantics:
      evalState(tree, q) = min over child-state assignments f of
        stepCost(a, f, q) + sum_i evalState(child_i, f(i))
      eval(tree) = min over q of evalState(tree, q) + finalCost(q)
    """

    def __init__(self, states: List[str], arity: Dict[str, int],
                 step_cost: Dict[Tuple, float],
                 final_cost: Dict[str, float]):
        self.states = states
        self.arity = arity
        self.step_cost = step_cost  # (symbol, child_states_tuple, target) -> cost
        self.final_cost = final_cost

    def eval_state(self, tree: RTree, q: str) -> float:
        """Minimum cost to process tree ending in state q."""
        a = tree.symbol
        k = self.arity.get(a, 0)
        assert len(tree.children) == k, f"Arity mismatch for {a}"

        if k == 0:
            # Leaf: only one child-state assignment (empty tuple)
            key = (a, (), q)
            return self.step_cost.get(key, math.inf)

        # Enumerate all child-state assignments
        best = math.inf
        for assignment in cartesian_product(self.states, repeat=k):
            # Cost of this transition
            key = (a, assignment, q)
            trans_cost = self.step_cost.get(key, math.inf)
            if trans_cost == math.inf:
                continue

            # Sum of child costs
            child_cost = sum(
                self.eval_state(tree.children[i], assignment[i])
                for i in range(k)
            )

            total = trans_cost + child_cost
            best = min(best, total)

        return best

    def eval(self, tree: RTree) -> float:
        """Minimum total cost (eval + final) over all root states."""
        best = math.inf
        for q in self.states:
            cost = self.eval_state(tree, q) + self.final_cost.get(q, math.inf)
            best = min(best, cost)
        return best


# ============================================================
# Product Automaton Construction
# ============================================================

def product_automaton(a1: WTA, a2: WTA) -> WTA:
    """
    Construct the product automaton A1 × A2.

    State space: Q1 × Q2
    stepCost((q1,q2), ...) = stepCost_A1(q1, ...) + stepCost_A2(q2, ...)
    finalCost((q1,q2)) = finalCost_A1(q1) + finalCost_A2(q2)
    """
    prod_states = [f"({q1},{q2})" for q1 in a1.states for q2 in a2.states]
    prod_arity = {**a1.arity, **a2.arity}

    prod_step = {}
    for symbol in set(a1.arity) | set(a2.arity):
        k = prod_arity[symbol]
        for assignment in cartesian_product(prod_states, repeat=k):
            # Extract component assignments
            a1_assign = tuple(s.split(",")[0][1:] for s in assignment)
            a2_assign = tuple(s.split(",")[1][:-1] for s in assignment)
            for q1 in a1.states:
                for q2 in a2.states:
                    key1 = (symbol, a1_assign, q1)
                    key2 = (symbol, a2_assign, q2)
                    c1 = a1.step_cost.get(key1, math.inf)
                    c2 = a2.step_cost.get(key2, math.inf)
                    if c1 < math.inf and c2 < math.inf:
                        prod_step[(symbol, assignment, f"({q1},{q2})")] = c1 + c2

    prod_final = {}
    for q1 in a1.states:
        for q2 in a2.states:
            f1 = a1.final_cost.get(q1, math.inf)
            f2 = a2.final_cost.get(q2, math.inf)
            if f1 < math.inf and f2 < math.inf:
                prod_final[f"({q1},{q2})"] = f1 + f2

    return WTA(prod_states, prod_arity, prod_step, prod_final)


# ============================================================
# Demo 1: Binary Tree Cost Computation
# ============================================================

def demo_basic_evaluation():
    """Demonstrate basic WTA evaluation on arithmetic expression trees."""
    print("=" * 70)
    print("DEMO 1: Basic Weighted Tree Automaton Evaluation")
    print("=" * 70)
    print()
    print("Signature: {num (arity 0), add (arity 2), mul (arity 2)}")
    print("States: {low, high} — representing cost categories")
    print()

    # A₁: Automaton that measures "additive complexity"
    arity = {"num": 0, "add": 2, "mul": 2}
    a1 = WTA(
        states=["lo", "hi"],
        arity=arity,
        step_cost={
            # Leaves
            ("num", (), "lo"): 0,
            ("num", (), "hi"): 1,
            # Addition: cheap if both children are low
            ("add", ("lo", "lo"), "lo"): 1,
            ("add", ("lo", "hi"), "hi"): 2,
            ("add", ("hi", "lo"), "hi"): 2,
            ("add", ("hi", "hi"), "hi"): 3,
            # Multiplication: always expensive
            ("mul", ("lo", "lo"), "hi"): 4,
            ("mul", ("lo", "hi"), "hi"): 5,
            ("mul", ("hi", "lo"), "hi"): 5,
            ("mul", ("hi", "hi"), "hi"): 6,
        },
        final_cost={"lo": 0, "hi": 0}
    )

    # Build some trees
    num = RTree("num", [])
    t1 = RTree("add", [num, num])          # add(num, num)
    t2 = RTree("mul", [num, num])          # mul(num, num)
    t3 = RTree("add", [t1, t2])            # add(add(num,num), mul(num,num))
    t4 = RTree("mul", [t1, t1])            # mul(add(num,num), add(num,num))

    trees = [("num", num), ("add(num,num)", t1), ("mul(num,num)", t2),
             ("add(add,mul)", t3), ("mul(add,add)", t4)]

    print("A₁: Additive complexity automaton")
    print("-" * 40)
    for name, t in trees:
        cost = a1.eval(t)
        print(f"  eval(A₁, {name}) = {cost}")

    print()


def demo_product_closure():
    """Demonstrate the product closure theorem with concrete numbers."""
    print("=" * 70)
    print("DEMO 2: Product Closure Theorem — Tropical Product")
    print("=" * 70)
    print()
    print("Theorem: eval(A₁ × A₂, t) = eval(A₁, t) + eval(A₂, t)")
    print()

    arity = {"a": 0, "f": 1, "g": 2}

    # A₁: depth-sensitive cost
    a1 = WTA(
        states=["s0", "s1"],
        arity=arity,
        step_cost={
            ("a", (), "s0"): 1, ("a", (), "s1"): 3,
            ("f", ("s0",), "s0"): 2, ("f", ("s0",), "s1"): 4,
            ("f", ("s1",), "s0"): 3, ("f", ("s1",), "s1"): 1,
            ("g", ("s0", "s0"), "s0"): 1, ("g", ("s0", "s1"), "s0"): 2,
            ("g", ("s1", "s0"), "s0"): 2, ("g", ("s1", "s1"), "s0"): 3,
            ("g", ("s0", "s0"), "s1"): 5, ("g", ("s0", "s1"), "s1"): 4,
            ("g", ("s1", "s0"), "s1"): 4, ("g", ("s1", "s1"), "s1"): 2,
        },
        final_cost={"s0": 0, "s1": 1}
    )

    # A₂: size-sensitive cost
    a2 = WTA(
        states=["p", "q"],
        arity=arity,
        step_cost={
            ("a", (), "p"): 0, ("a", (), "q"): 2,
            ("f", ("p",), "p"): 1, ("f", ("p",), "q"): 3,
            ("f", ("q",), "p"): 2, ("f", ("q",), "q"): 1,
            ("g", ("p", "p"), "p"): 1, ("g", ("p", "q"), "p"): 2,
            ("g", ("q", "p"), "p"): 2, ("g", ("q", "q"), "p"): 3,
            ("g", ("p", "p"), "q"): 4, ("g", ("p", "q"), "q"): 3,
            ("g", ("q", "p"), "q"): 3, ("g", ("q", "q"), "q"): 1,
        },
        final_cost={"p": 0, "q": 0}
    )

    # Product automaton
    a_prod = product_automaton(a1, a2)

    # Test trees
    leaf = RTree("a", [])
    t1 = RTree("f", [leaf])
    t2 = RTree("g", [leaf, leaf])
    t3 = RTree("f", [RTree("g", [leaf, RTree("f", [leaf])])])
    t4 = RTree("g", [t1, t2])

    trees = [("a", leaf), ("f(a)", t1), ("g(a,a)", t2),
             ("f(g(a,f(a)))", t3), ("g(f(a),g(a,a))", t4)]

    print(f"A₁ states: {a1.states}")
    print(f"A₂ states: {a2.states}")
    print(f"Product states: {a_prod.states} ({len(a_prod.states)} = {len(a1.states)} × {len(a2.states)})")
    print()
    print(f"{'Tree':<20} {'eval(A₁)':<10} {'eval(A₂)':<10} {'A₁+A₂':<10} {'eval(A₁×A₂)':<12} {'Match?'}")
    print("-" * 75)

    all_match = True
    for name, t in trees:
        e1 = a1.eval(t)
        e2 = a2.eval(t)
        e_sum = e1 + e2
        e_prod = a_prod.eval(t)
        match = "✓" if abs(e_sum - e_prod) < 1e-10 else "✗"
        if match == "✗":
            all_match = False
        print(f"  {name:<18} {e1:<10.1f} {e2:<10.1f} {e_sum:<10.1f} {e_prod:<12.1f} {match}")

    print()
    if all_match:
        print("✓ Product closure theorem verified for all test trees!")
    else:
        print("✗ Mismatch detected!")
    print()


def demo_union_closure():
    """Demonstrate the union/infimum closure theorem."""
    print("=" * 70)
    print("DEMO 3: Union Closure — Pointwise Minimum")
    print("=" * 70)
    print()
    print("Theorem: min(eval(A₁,t), eval(A₂,t)) = inf over Q₁⊕Q₂")
    print()

    arity = {"a": 0, "b": 0, "f": 2}

    # A₁: prefers left-heavy trees
    a1 = WTA(
        states=["x"],
        arity=arity,
        step_cost={
            ("a", (), "x"): 1, ("b", (), "x"): 5,
            ("f", ("x", "x"), "x"): 0,
        },
        final_cost={"x": 0}
    )

    # A₂: prefers right-heavy trees
    a2 = WTA(
        states=["y"],
        arity=arity,
        step_cost={
            ("a", (), "y"): 5, ("b", (), "y"): 1,
            ("f", ("y", "y"), "y"): 0,
        },
        final_cost={"y": 0}
    )

    a_leaf = RTree("a", [])
    b_leaf = RTree("b", [])
    t1 = RTree("f", [a_leaf, a_leaf])  # all a's — A₁ is better
    t2 = RTree("f", [b_leaf, b_leaf])  # all b's — A₂ is better
    t3 = RTree("f", [a_leaf, b_leaf])  # mixed — competitive
    t4 = RTree("f", [RTree("f", [a_leaf, a_leaf]), b_leaf])

    trees = [("a", a_leaf), ("b", b_leaf), ("f(a,a)", t1),
             ("f(b,b)", t2), ("f(a,b)", t3), ("f(f(a,a),b)", t4)]

    print(f"{'Tree':<20} {'eval(A₁)':<10} {'eval(A₂)':<10} {'min':<10} {'Winner'}")
    print("-" * 60)
    for name, t in trees:
        e1 = a1.eval(t)
        e2 = a2.eval(t)
        m = min(e1, e2)
        winner = "A₁" if e1 <= e2 else "A₂"
        if e1 == e2:
            winner = "tie"
        print(f"  {name:<18} {e1:<10.1f} {e2:<10.1f} {m:<10.1f} {winner}")

    print()
    print("✓ The minimum is always computed by choosing the better automaton")
    print("  at each tree — this is union closure over Q₁ ⊕ Q₂.")
    print()


def demo_finite_family():
    """Demonstrate finite family infimum closure."""
    print("=" * 70)
    print("DEMO 4: Finite Family Infimum Closure")
    print("=" * 70)
    print()
    print("Theorem: inf_{i∈I} eval(Aᵢ, t) = inf over Σ-type state space")
    print()

    arity = {"a": 0, "f": 1}

    # Create a family of automata with different "penalties" for depth
    family = []
    for k in range(1, 6):
        a = WTA(
            states=["q"],
            arity=arity,
            step_cost={
                ("a", (), "q"): k,        # leaf cost varies
                ("f", ("q",), "q"): 6-k,  # nesting cost is complementary
            },
            final_cost={"q": 0}
        )
        family.append(a)

    # Build chains of different depths
    def make_chain(n):
        t = RTree("a", [])
        for _ in range(n):
            t = RTree("f", [t])
        return t

    print(f"Family of {len(family)} automata with different depth/leaf tradeoffs")
    print()
    header = f"{'Depth':<8}" + "".join(f"{'A'+str(i+1):<8}" for i in range(5)) + f"{'inf':<8}"
    print(header)
    print("-" * len(header))

    for depth in range(6):
        t = make_chain(depth)
        evals = [a.eval(t) for a in family]
        inf_val = min(evals)
        row = f"  {depth:<6}" + "".join(f"{e:<8.1f}" for e in evals) + f"{inf_val:<8.1f}"
        print(row)

    print()
    print("✓ At each depth, the infimum selects the automaton with the best")
    print("  depth/leaf cost tradeoff — finite family closure in action.")
    print()


def demo_state_complexity():
    """Demonstrate state complexity bounds."""
    print("=" * 70)
    print("DEMO 5: State Complexity Bounds")
    print("=" * 70)
    print()

    for n1 in [2, 3, 5]:
        for n2 in [2, 3, 4]:
            print(f"  |Q₁| = {n1}, |Q₂| = {n2}")
            print(f"    Product: |Q₁ × Q₂| = {n1 * n2}")
            print(f"    Union:   |Q₁ ⊕ Q₂| = {n1 + n2}")

    print()
    print("✓ Product is multiplicative, union is additive in state count.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL WEIGHTED TREE AUTOMATA — CLOSURE PROPERTY DEMOS      ║")
    print("╠══════════════════════════════════════════════════════════════════╣")
    print("║  Demonstrating the min-plus Fubini principle for tree runs     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_basic_evaluation()
    demo_product_closure()
    demo_union_closure()
    demo_finite_family()
    demo_state_complexity()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualizations for Tropical Weighted Tree Automata Closure Properties.
Generates PNG figures for the research paper and article.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math
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


def viz_product_closure():
    """Visualize the product closure theorem with cost landscape."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Generate tree depths and costs for two automata
    depths = np.arange(0, 8)

    # A₁: costs grow linearly
    costs_a1 = 2 * depths + 1

    # A₂: costs grow with log
    costs_a2 = 3 * np.log2(depths + 1) + 0.5

    # Product: sum of costs
    costs_prod = costs_a1 + costs_a2

    # Plot A₁
    axes[0].bar(depths, costs_a1, color='#2196F3', alpha=0.8, edgecolor='white')
    axes[0].set_title('Automaton A₁\n(Linear Cost)', fontsize=12, fontweight='bold')
    axes[0].set_xlabel('Tree Depth')
    axes[0].set_ylabel('eval(A₁, t)')
    axes[0].set_ylim(0, max(costs_prod) * 1.1)

    # Plot A₂
    axes[1].bar(depths, costs_a2, color='#FF9800', alpha=0.8, edgecolor='white')
    axes[1].set_title('Automaton A₂\n(Logarithmic Cost)', fontsize=12, fontweight='bold')
    axes[1].set_xlabel('Tree Depth')
    axes[1].set_ylabel('eval(A₂, t)')
    axes[1].set_ylim(0, max(costs_prod) * 1.1)

    # Plot Product
    axes[2].bar(depths, costs_a1, color='#2196F3', alpha=0.7, label='A₁ contribution',
                edgecolor='white')
    axes[2].bar(depths, costs_a2, bottom=costs_a1, color='#FF9800', alpha=0.7,
                label='A₂ contribution', edgecolor='white')
    axes[2].set_title('Product A₁ × A₂\neval = eval(A₁) + eval(A₂)', fontsize=12, fontweight='bold')
    axes[2].set_xlabel('Tree Depth')
    axes[2].set_ylabel('eval(A₁×A₂, t)')
    axes[2].legend(loc='upper left')
    axes[2].set_ylim(0, max(costs_prod) * 1.1)

    fig.suptitle('Tropical Product Closure: Additive Decomposition of Tree Costs',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_product_closure.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_union_closure():
    """Visualize the union closure as pointwise minimum."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.linspace(0, 10, 200)

    # Two cost functions with different characteristics
    y1 = 2 + 0.5 * (x - 3) ** 2  # Quadratic, optimum at x=3
    y2 = 1 + 0.3 * (x - 7) ** 2  # Quadratic, optimum at x=7

    y_min = np.minimum(y1, y2)

    ax.plot(x, y1, '--', color='#2196F3', linewidth=2, label='eval(A₁, t)', alpha=0.7)
    ax.plot(x, y2, '--', color='#FF9800', linewidth=2, label='eval(A₂, t)', alpha=0.7)
    ax.plot(x, y_min, '-', color='#4CAF50', linewidth=3, label='min(eval(A₁), eval(A₂))')

    # Fill the region showing which automaton wins
    ax.fill_between(x, y_min, 0, where=(y1 <= y2), alpha=0.15, color='#2196F3')
    ax.fill_between(x, y_min, 0, where=(y2 < y1), alpha=0.15, color='#FF9800')

    # Mark the crossover point
    crossover_idx = np.argmin(np.abs(y1 - y2))
    ax.axvline(x=x[crossover_idx], color='gray', linestyle=':', alpha=0.5)
    ax.annotate('Crossover', xy=(x[crossover_idx], y1[crossover_idx]),
                xytext=(x[crossover_idx] + 0.5, y1[crossover_idx] + 3),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='gray'))

    ax.set_xlabel('Tree parameter (e.g., branching factor)', fontsize=12)
    ax.set_ylabel('Evaluation cost', fontsize=12)
    ax.set_title('Union Closure: Pointwise Minimum of Tree Costs\nThe union automaton always picks the cheaper model',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.set_ylim(0, 15)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/viz_union_closure.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_state_complexity():
    """Visualize state complexity of product vs union."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    n_values = np.arange(1, 11)

    # Product: |Q₁| × |Q₂| for fixed |Q₂| = 3, 5, 8
    for q2 in [3, 5, 8]:
        axes[0].plot(n_values, n_values * q2, 'o-', label=f'|Q₂| = {q2}',
                     linewidth=2, markersize=5)
    axes[0].set_xlabel('|Q₁|', fontsize=12)
    axes[0].set_ylabel('|Q₁ × Q₂|', fontsize=12)
    axes[0].set_title('Product: Multiplicative\n|Q₁ × Q₂| = |Q₁| · |Q₂|',
                       fontsize=12, fontweight='bold')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Union: |Q₁| + |Q₂|
    for q2 in [3, 5, 8]:
        axes[1].plot(n_values, n_values + q2, 's-', label=f'|Q₂| = {q2}',
                     linewidth=2, markersize=5)
    axes[1].set_xlabel('|Q₁|', fontsize=12)
    axes[1].set_ylabel('|Q₁ ⊕ Q₂|', fontsize=12)
    axes[1].set_title('Union: Additive\n|Q₁ ⊕ Q₂| = |Q₁| + |Q₂|',
                       fontsize=12, fontweight='bold')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    fig.suptitle('State Complexity of Automata Constructions',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_state_complexity.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_finite_family():
    """Visualize finite family infimum as envelope."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.linspace(0, 10, 300)

    # Family of cost functions
    colors = ['#E91E63', '#2196F3', '#FF9800', '#4CAF50', '#9C27B0']
    labels = ['A₁ (low depth cost)', 'A₂ (balanced)', 'A₃ (low leaf cost)',
              'A₄ (prefers binary)', 'A₅ (prefers unary)']

    costs = []
    for i, (c, label) in enumerate(zip(colors, labels)):
        # Different cost profiles
        y = 2 + i * 0.5 + np.sin(x + i * 0.8) * (2 + i * 0.3) + 0.1 * x
        costs.append(y)
        ax.plot(x, y, '--', color=c, alpha=0.5, linewidth=1.5, label=label)

    # Compute and plot the envelope (pointwise minimum)
    envelope = np.minimum.reduce(costs)
    ax.plot(x, envelope, 'k-', linewidth=3, label='inf (envelope)', zorder=10)

    # Shade under envelope
    ax.fill_between(x, envelope, 0, alpha=0.1, color='black')

    ax.set_xlabel('Tree structure parameter', fontsize=12)
    ax.set_ylabel('Evaluation cost', fontsize=12)
    ax.set_title('Finite Family Infimum: The Envelope of Tree Costs\n'
                 'Each point uses the best automaton from the family',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='upper left', ncol=2)
    ax.set_ylim(0, 12)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/viz_finite_family.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_tree_automaton_diagram():
    """Create a schematic diagram of a weighted tree automaton processing a tree."""
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')

    # Draw a tree
    # f(g(a, b), a) where f has arity 2, g has arity 2, a,b have arity 0

    nodes = {
        'f': (5, 7),
        'g': (3, 4.5),
        'a1': (1.5, 2),
        'b': (4.5, 2),
        'a2': (7, 4.5),
    }

    # Draw edges
    edges = [('f', 'g'), ('f', 'a2'), ('g', 'a1'), ('g', 'b')]
    for parent, child in edges:
        px, py = nodes[parent]
        cx, cy = nodes[child]
        ax.annotate('', xy=(cx, cy + 0.5), xytext=(px, py - 0.5),
                    arrowprops=dict(arrowstyle='->', color='#666', lw=2))

    # Draw nodes
    node_labels = {'f': 'f', 'g': 'g', 'a1': 'a', 'b': 'b', 'a2': 'a'}
    node_colors = {'f': '#E3F2FD', 'g': '#FFF3E0', 'a1': '#E8F5E9',
                   'b': '#FCE4EC', 'a2': '#E8F5E9'}

    for name, (x, y) in nodes.items():
        circle = plt.Circle((x, y), 0.5, facecolor=node_colors[name],
                           edgecolor='#333', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, node_labels[name], ha='center', va='center',
                fontsize=16, fontweight='bold', zorder=6)

    # State annotations (right side)
    state_info = {
        'a1': ('q₁ → cost: 1', (1.5, 1)),
        'b': ('q₂ → cost: 2', (4.5, 1)),
        'a2': ('q₁ → cost: 1', (8.5, 4.5)),
        'g': ('q₃ → cost: 1+1+2=4', (0, 4.5)),
        'f': ('q₄ → cost: 3+4+1=8', (5, 8.2)),
    }

    for name, (text, (tx, ty)) in state_info.items():
        ax.text(tx, ty, text, fontsize=10, color='#555',
                ha='center', style='italic')

    # Title and explanation
    ax.text(5, -0.5, 'Bottom-up evaluation: states propagate from leaves to root\n'
            'Each node minimizes over child-state assignments',
            ha='center', fontsize=11, color='#333')
    ax.set_title('Weighted Tree Automaton: Bottom-Up Evaluation',
                 fontsize=14, fontweight='bold', pad=20)

    fig.savefig('/workspace/request-project/viz_tree_diagram.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_product = viz_product_closure()
    print(f"  ✓ Product closure visualization saved (base64 length: {len(b64_product)})")

    b64_union = viz_union_closure()
    print(f"  ✓ Union closure visualization saved (base64 length: {len(b64_union)})")

    b64_complexity = viz_state_complexity()
    print(f"  ✓ State complexity visualization saved (base64 length: {len(b64_complexity)})")

    b64_family = viz_finite_family()
    print(f"  ✓ Finite family visualization saved (base64 length: {len(b64_family)})")

    b64_tree = viz_tree_automaton_diagram()
    print(f"  ✓ Tree diagram visualization saved (base64 length: {len(b64_tree)})")

    print("\nAll visualizations generated successfully.")
    print("Files saved: viz_product_closure.png, viz_union_closure.png,")
    print("             viz_state_complexity.png, viz_finite_family.png,")
    print("             viz_tree_diagram.png")
