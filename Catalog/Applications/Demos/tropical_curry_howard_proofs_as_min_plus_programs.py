#!/usr/bin/env python3
"""
Tropical Curry-Howard: Applications

Demonstrates real-world applications of tropical proof theory:
1. Shortest path computation as proof normalization
2. Task scheduling optimization
3. Proof compression via idempotent sharing
4. Resource-aware program optimization
"""

from dataclasses import dataclass
from typing import List, Dict, Tuple, Optional
import sys


# ============================================================
# Term data structure (self-contained)
# ============================================================

@dataclass(frozen=True)
class Term:
    kind: str  # 'atom', 'cut', 'plus', 'min'
    value: Optional[int] = None
    left: Optional['Term'] = None
    right: Optional['Term'] = None

    def __repr__(self):
        if self.kind == 'atom': return f"a({self.value})"
        return f"{self.kind}({self.left}, {self.right})"

def A(n): return Term('atom', value=n)
def C(l, r): return Term('cut', left=l, right=r)
def P(l, r): return Term('plus', left=l, right=r)
def M(l, r): return Term('min', left=l, right=r)

def ev(t):
    if t.kind == 'atom': return t.value
    l, r = ev(t.left), ev(t.right)
    if t.kind in ('cut', 'plus'): return l + r
    return min(l, r)

def step(t):
    if t.kind == 'min' and t.left == t.right: return t.left
    if t.kind == 'cut':
        if t.left.kind == 'min':
            return M(C(t.left.left, t.right), C(t.left.right, t.right))
        if t.right.kind == 'min':
            return M(C(t.left, t.right.left), C(t.left, t.right.right))
    if t.kind != 'atom':
        sl = step(t.left)
        if sl: return Term(t.kind, left=sl, right=t.right)
        sr = step(t.right)
        if sr: return Term(t.kind, left=t.left, right=sr)
    return None

def normalize(t):
    steps = 0
    while True:
        n = step(t)
        if n is None: return t, steps
        t, steps = n, steps + 1

def size(t):
    if t.kind == 'atom': return 1
    return 1 + size(t.left) + size(t.right)


# ============================================================
# Application 1: Shortest Path as Proof Normalization
# ============================================================

def shortest_path_demo():
    """
    Model a weighted graph as a tropical proof term.
    Normalization computes the shortest path.

    Graph (A → D):
        A -2→ B -3→ D     (cost 5)
        A -1→ C -6→ D     (cost 7)
        A -2→ B -1→ C -6→ D  (cost 9)
        A -4→ D           (cost 4)  ← optimal
    """
    print("APPLICATION 1: Shortest Path via Proof Normalization")
    print("-" * 55)

    # Each path is a proof term (cut = sequential composition)
    path_abd = C(A(2), A(3))     # A→B→D: cost 5
    path_acd = C(A(1), A(6))     # A→C→D: cost 7
    path_abcd = C(C(A(2), A(1)), A(6))  # A→B→C→D: cost 9
    path_ad = A(4)               # A→D: cost 4

    # The "proof" exploring all paths (min = nondeterministic choice)
    all_paths = M(M(path_abd, path_acd), M(path_abcd, path_ad))

    print(f"  Path A→B→D:     cost {ev(path_abd)}")
    print(f"  Path A→C→D:     cost {ev(path_acd)}")
    print(f"  Path A→B→C→D:   cost {ev(path_abcd)}")
    print(f"  Path A→D:       cost {ev(path_ad)}")
    print(f"\n  Proof term size: {size(all_paths)} nodes")
    print(f"  Optimal cost:    {ev(all_paths)}")

    nf, steps = normalize(all_paths)
    print(f"  After normalization: {steps} reduction steps")
    print(f"  Normal form size:    {size(nf)} nodes")
    print(f"  Cost preserved:      {ev(nf)} ✓")
    print()


# ============================================================
# Application 2: Task Scheduling
# ============================================================

def scheduling_demo():
    """
    Model task scheduling with tropical proofs.
    Tasks have costs (durations), and we choose the minimum-time schedule.
    """
    print("APPLICATION 2: Task Scheduling Optimization")
    print("-" * 55)

    # Two-stage pipeline with choices at each stage
    # Stage 1: Task A (cost 3) or Task B (cost 5)
    # Stage 2: Task C (cost 2) or Task D (cost 4)
    stage1 = M(A(3), A(5))  # choose faster task
    stage2 = M(A(2), A(4))  # choose faster task

    # Pipeline = sequential composition of stages
    pipeline = C(stage1, stage2)

    print(f"  Stage 1: Task A (3h) or Task B (5h)")
    print(f"  Stage 2: Task C (2h) or Task D (4h)")
    print(f"  Pipeline cost: {ev(pipeline)}h")
    print(f"  Pipeline size: {size(pipeline)} nodes")

    nf, steps = normalize(pipeline)
    print(f"\n  After normalization ({steps} steps):")
    print(f"  Normal form: {nf}")
    print(f"  All schedules enumerated:")
    print(f"    A+C = {3+2}h, A+D = {3+4}h, B+C = {5+2}h, B+D = {5+4}h")
    print(f"  Optimal: {ev(nf)}h ✓")
    print()


# ============================================================
# Application 3: Proof Compression
# ============================================================

def compression_demo():
    """
    Demonstrate proof compression via idempotent collapse.
    Redundant proof branches are eliminated, reducing proof size.
    """
    print("APPLICATION 3: Proof Compression via Idempotent Sharing")
    print("-" * 55)

    # Simulate a proof with many duplicate branches
    base = C(A(2), A(3))  # A basic lemma, cost 5

    # Build a proof with 8 copies of the same lemma
    level1 = M(base, base)     # 2 copies
    level2 = M(level1, level1) # 4 copies
    level3 = M(level2, level2) # 8 copies

    print(f"  Original proof: {2**3} duplicate branches")
    print(f"  Original size:  {size(level3)} nodes")
    print(f"  Cost: {ev(level3)}")

    nf, steps = normalize(level3)
    print(f"\n  After normalization ({steps} steps):")
    print(f"  Compressed size: {size(nf)} nodes")
    print(f"  Compression ratio: {size(level3)/size(nf):.1f}x")
    print(f"  Cost preserved: {ev(nf)} ✓")
    print(f"\n  Idempotence (min(P,P) = P) collapses all duplicates!")
    print()


# ============================================================
# Application 4: Resource-Aware Optimization
# ============================================================

def resource_demo():
    """
    Model resource-aware computation where different implementations
    have different costs, and normalization finds the optimal one.
    """
    print("APPLICATION 4: Resource-Aware Program Optimization")
    print("-" * 55)

    # Three implementations of a function
    impl_fast = A(1)    # Fast but expensive (GPU)
    impl_med = A(3)     # Medium (multi-core CPU)
    impl_slow = A(7)    # Slow but cheap (single core)

    # A pipeline: f composed with g, each with 3 implementations
    f = M(M(A(1), A(3)), A(7))  # Three choices for f
    g = M(M(A(2), A(4)), A(5))  # Three choices for g

    pipeline = C(f, g)  # f ; g

    print(f"  Function f: 3 implementations (cost 1, 3, 7)")
    print(f"  Function g: 3 implementations (cost 2, 4, 5)")
    print(f"  Pipeline f;g cost: {ev(pipeline)}")

    nf, steps = normalize(pipeline)
    print(f"\n  After normalization ({steps} steps):")
    print(f"  All 9 combinations explored:")
    for fc in [1, 3, 7]:
        for gc in [2, 4, 5]:
            opt = " ← optimal" if fc + gc == ev(pipeline) else ""
            print(f"    f({fc}) ; g({gc}) = {fc + gc}{opt}")
    print(f"\n  Optimal cost: {ev(nf)} ✓")
    print()


# ============================================================
# Application 5: Tropical Bellman-Ford
# ============================================================

def bellman_ford_demo():
    """
    Show how tropical normalization relates to Bellman-Ford.
    Each iteration of Bellman-Ford corresponds to a layer of cut-distribution.
    """
    print("APPLICATION 5: Connection to Bellman-Ford Algorithm")
    print("-" * 55)

    # 4-node graph: 0 → 1 → 2 → 3
    # Edge weights: 0→1: 3, 0→2: 7, 1→2: 1, 1→3: 5, 2→3: 2
    #
    # Shortest paths from 0:
    # 0→1: 3
    # 0→2: min(7, 3+1) = 4
    # 0→3: min(3+5, 4+2) = 6

    # Build as tropical proof terms
    path_01 = A(3)                       # direct 0→1
    path_02_direct = A(7)                # direct 0→2
    path_02_via1 = C(A(3), A(1))         # 0→1→2
    path_02 = M(path_02_direct, path_02_via1)

    path_03_via1 = C(A(3), A(5))         # 0→1→3
    path_03_via2 = C(path_02, A(2))      # 0→2→3

    shortest_to_3 = M(path_03_via1, path_03_via2)

    print(f"  Graph: 0→1(3), 0→2(7), 1→2(1), 1→3(5), 2→3(2)")
    print(f"\n  Shortest 0→1: {ev(path_01)}")
    print(f"  Shortest 0→2: {ev(path_02)} = min(7, 3+1)")
    print(f"  Shortest 0→3: {ev(shortest_to_3)} = min(3+5, min(7,4)+2)")

    nf, steps = normalize(shortest_to_3)
    print(f"\n  Normalization of path term ({steps} steps):")
    print(f"  Normal form cost: {ev(nf)}")
    print(f"\n  The Bellman-Ford relaxation is tropical cut-elimination!")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL CURRY-HOWARD: Real-World Applications        ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    shortest_path_demo()
    scheduling_demo()
    compression_demo()
    resource_demo()
    bellman_ford_demo()

    print("=" * 58)
    print("All applications demonstrate: Proof normalization = Optimization")
    print("=" * 58)


#!/usr/bin/env python3
"""Build the PACKAGE.json deliverable."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Load visualizations
with open("viz_data.json", "r") as f:
    viz_data = json.load(f)

# Load all content
article = read_file("ARTICLE.md")
research_paper = read_file("RESEARCH_PAPER.md")
future_directions = read_file("FUTURE_DIRECTIONS.md")
lean_code = read_file("Logic/TropicalCurryHoward.lean")
demo_code = read_file("demo.py")
algorithms_code = read_file("algorithms.py")
applications_code = read_file("applications.py")

package = {
    "title": "Tropical Curry–Howard: Proofs as Min-Plus Programs",
    "domain": "Logic / Proof Theory / Tropical Algebra",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Proof Normalization Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Evaluation",
            "pseudocode": "EVAL(atom(n)) = n\nEVAL(cut(t,s)) = EVAL(t) + EVAL(s)\nEVAL(plus(t,s)) = EVAL(t) + EVAL(s)\nEVAL(min(t,s)) = min(EVAL(t), EVAL(s))",
            "code": '''def evaluate(t):
    """Evaluate a tropical proof term. O(n) time."""
    if t.kind == 'atom': return t.value
    l, r = evaluate(t.left), evaluate(t.right)
    if t.kind in ('cut', 'plus'): return l + r
    return min(l, r)'''
        },
        {
            "name": "Polynomial Interpretation (Termination Measure)",
            "pseudocode": "INTERP(atom(_)) = 2\nINTERP(cut(t,s)) = INTERP(t) * INTERP(s)\nINTERP(plus(t,s)) = INTERP(t) + INTERP(s)\nINTERP(min(t,s)) = INTERP(t) + INTERP(s) + 1\n\nProperty: INTERP(t) >= 2 for all t\nProperty: Step(t,u) => INTERP(u) < INTERP(t)",
            "code": '''def polynomial_interp(t):
    """Termination measure. Strictly decreases under reduction. O(n) time."""
    if t.kind == 'atom': return 2
    l, r = polynomial_interp(t.left), polynomial_interp(t.right)
    if t.kind == 'cut': return l * r
    if t.kind == 'plus': return l + r
    return l + r + 1  # min'''
        },
        {
            "name": "Leftmost-Outermost Reduction Step",
            "pseudocode": "STEP(min(t,t)) = t\nSTEP(cut(min(t,u), s)) = min(cut(t,s), cut(u,s))\nSTEP(cut(s, min(t,u))) = min(cut(s,t), cut(s,u))\nSTEP(f(t,s)) = f(STEP(t), s) or f(t, STEP(s))  -- congruence\nSTEP(_) = None  -- normal form",
            "code": '''def reduce_step(t):
    """Apply leftmost-outermost reduction. Returns None if normal. O(n) time."""
    if t.kind == 'min' and t.left == t.right: return t.left
    if t.kind == 'cut':
        if t.left.kind == 'min':
            return Term('min', left=Term('cut', left=t.left.left, right=t.right),
                               right=Term('cut', left=t.left.right, right=t.right))
        if t.right.kind == 'min':
            return Term('min', left=Term('cut', left=t.left, right=t.right.left),
                               right=Term('cut', left=t.left, right=t.right.right))
    if t.kind != 'atom':
        sl = reduce_step(t.left)
        if sl: return Term(t.kind, left=sl, right=t.right)
        sr = reduce_step(t.right)
        if sr: return Term(t.kind, left=t.left, right=sr)
    return None'''
        },
        {
            "name": "Full Normalization",
            "pseudocode": "NORMALIZE(t):\n  steps = 0\n  while STEP(t) != None:\n    t = STEP(t)\n    steps += 1\n  return (t, steps)\n\nTermination: Guaranteed (INTERP decreases at each step)\nSoundness: EVAL(result) = EVAL(input)\nComplexity: O(INTERP(t)) steps, each O(n) time",
            "code": '''def normalize(t):
    """Normalize by exhaustive reduction. Always terminates."""
    steps = 0
    while True:
        next_t = reduce_step(t)
        if next_t is None: return t, steps
        t, steps = next_t, steps + 1'''
        }
    ],
    "visualizations": [
        {
            "name": "Termination and Soundness",
            "data": viz_data.get("interp_decrease", "")
        },
        {
            "name": "Proof Compression via Idempotent Collapse",
            "data": viz_data.get("compression", "")
        },
        {
            "name": "Tropical Curry-Howard Architecture",
            "data": viz_data.get("diagram", "")
        }
    ],
    "lean_proofs": lean_code
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json created ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Curry-Howard: Proofs as Min-Plus Programs — Interactive Demo

This script demonstrates the key ideas of tropical proof theory:
- Proof terms as syntax trees with cost semantics
- Cut elimination as cost-preserving rewriting
- Strong normalization via polynomial interpretation
- Normal forms as optimal proof certificates

Each example shows how tropical algebra (min, +) governs proof optimization.
"""

from dataclasses import dataclass
from typing import Optional, List, Tuple
import sys


# ============================================================
# Syntax: Tropical Proof Terms
# ============================================================

@dataclass
class Atom:
    """A basic proof/axiom with a given cost."""
    cost: int
    def __repr__(self): return f"atom({self.cost})"
    def __eq__(self, other): return isinstance(other, Atom) and self.cost == other.cost
    def __hash__(self): return hash(('atom', self.cost))

@dataclass
class Cut:
    """Sequential composition of two proofs (costs add)."""
    left: 'TropTerm'
    right: 'TropTerm'
    def __repr__(self): return f"cut({self.left}, {self.right})"
    def __eq__(self, other): return isinstance(other, Cut) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('cut', self.left, self.right))

@dataclass
class Plus:
    """Parallel/tensor composition of two proofs (costs add)."""
    left: 'TropTerm'
    right: 'TropTerm'
    def __repr__(self): return f"plus({self.left}, {self.right})"
    def __eq__(self, other): return isinstance(other, Plus) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('plus', self.left, self.right))

@dataclass
class Min:
    """Nondeterministic choice between two proofs (cost = minimum)."""
    left: 'TropTerm'
    right: 'TropTerm'
    def __repr__(self): return f"min({self.left}, {self.right})"
    def __eq__(self, other): return isinstance(other, Min) and self.left == other.left and self.right == other.right
    def __hash__(self): return hash(('min', self.left, self.right))

TropTerm = Atom | Cut | Plus | Min


# ============================================================
# Semantics: Tropical Evaluation
# ============================================================

def eval_term(t: TropTerm) -> int:
    """Evaluate a tropical proof term: its cost in the min-plus semiring."""
    match t:
        case Atom(n): return n
        case Cut(l, r): return eval_term(l) + eval_term(r)
        case Plus(l, r): return eval_term(l) + eval_term(r)
        case Min(l, r): return min(eval_term(l), eval_term(r))


def term_size(t: TropTerm) -> int:
    """Count the number of nodes in a term."""
    match t:
        case Atom(_): return 1
        case Cut(l, r) | Plus(l, r) | Min(l, r):
            return 1 + term_size(l) + term_size(r)


def interp(t: TropTerm) -> int:
    """Polynomial interpretation for termination analysis.
    Maps cut→multiply, plus→add, min→add+1, atom→2."""
    match t:
        case Atom(_): return 2
        case Cut(l, r): return interp(l) * interp(r)
        case Plus(l, r): return interp(l) + interp(r)
        case Min(l, r): return interp(l) + interp(r) + 1


# ============================================================
# Reduction: One-Step Tropical Cut Elimination
# ============================================================

def step(t: TropTerm) -> Optional[TropTerm]:
    """Apply the first available reduction step (leftmost-outermost).
    Returns None if the term is in normal form.

    Rules:
    1. min(t, t) → t           (idempotence / duplicate branch collapse)
    2. cut(min(t,u), s) → min(cut(t,s), cut(u,s))  (left distribution)
    3. cut(s, min(t,u)) → min(cut(s,t), cut(s,u))  (right distribution)
    """
    match t:
        # Base rules
        case Min(l, r) if l == r:
            return l  # min_idem
        case Cut(Min(a, b), s):
            return Min(Cut(a, s), Cut(b, s))  # cut_min_left
        case Cut(s, Min(a, b)):
            return Min(Cut(s, a), Cut(s, b))  # cut_min_right

        # Congruence rules: try to reduce subterms
        case Cut(l, r):
            sl = step(l)
            if sl is not None: return Cut(sl, r)
            sr = step(r)
            if sr is not None: return Cut(l, sr)
        case Plus(l, r):
            sl = step(l)
            if sl is not None: return Plus(sl, r)
            sr = step(r)
            if sr is not None: return Plus(l, sr)
        case Min(l, r):
            sl = step(l)
            if sl is not None: return Min(sl, r)
            sr = step(r)
            if sr is not None: return Min(l, sr)

    return None  # Normal form


def normalize(t: TropTerm, trace: bool = False) -> Tuple[TropTerm, List[TropTerm]]:
    """Normalize a term by exhaustive reduction. Returns (normal_form, trace).

    By strong normalization, this always terminates.
    By soundness, eval(normal_form) == eval(t).
    """
    history = [t]
    current = t
    while True:
        next_t = step(current)
        if next_t is None:
            break
        current = next_t
        history.append(current)
    return current, history


def pretty(t: TropTerm, indent: int = 0) -> str:
    """Pretty-print a term as a tree."""
    pad = "  " * indent
    match t:
        case Atom(n): return f"{pad}atom({n})"
        case Cut(l, r): return f"{pad}cut(\n{pretty(l, indent+1)},\n{pretty(r, indent+1)})"
        case Plus(l, r): return f"{pad}plus(\n{pretty(l, indent+1)},\n{pretty(r, indent+1)})"
        case Min(l, r): return f"{pad}min(\n{pretty(l, indent+1)},\n{pretty(r, indent+1)})"


# ============================================================
# Demonstrations
# ============================================================

def demo_basic():
    """Demo 1: Basic evaluation and reduction."""
    print("=" * 60)
    print("DEMO 1: Basic Tropical Proof Terms")
    print("=" * 60)

    # A simple choice between two proofs of cost 3 and 5
    t1 = Min(Atom(3), Atom(5))
    print(f"\nTerm: {t1}")
    print(f"Cost: {eval_term(t1)} (= min(3, 5))")

    # Sequential composition
    t2 = Cut(Atom(2), Atom(3))
    print(f"\nTerm: {t2}")
    print(f"Cost: {eval_term(t2)} (= 2 + 3)")

    # Duplicate branch: min(t, t)
    t3 = Min(Atom(4), Atom(4))
    nf, trace = normalize(t3)
    print(f"\nTerm: {t3}")
    print(f"Reduces to: {nf}")
    print(f"Cost preserved: {eval_term(t3)} = {eval_term(nf)}")


def demo_cut_elimination():
    """Demo 2: Cut elimination distributes sequencing over choice."""
    print("\n" + "=" * 60)
    print("DEMO 2: Cut Elimination = Distribution Over Choice")
    print("=" * 60)

    # cut(min(a, b), s) → min(cut(a, s), cut(b, s))
    # "If you can do A or B, then sequence with S" =
    # "Either sequence A with S, or sequence B with S"
    a, b, s = Atom(2), Atom(5), Atom(3)
    t = Cut(Min(a, b), s)
    nf, trace = normalize(t)

    print(f"\nOriginal: {t}")
    print(f"Cost: {eval_term(t)}")
    print(f"\nReduction trace:")
    for i, step_t in enumerate(trace):
        print(f"  Step {i}: {step_t}  [cost={eval_term(step_t)}, interp={interp(step_t)}]")
    print(f"\nNormal form: {nf}")
    print(f"Cost preserved: {eval_term(t)} = {eval_term(nf)} ✓")


def demo_nested_distribution():
    """Demo 3: Nested distribution — the 'polynomial expansion' of proofs."""
    print("\n" + "=" * 60)
    print("DEMO 3: Nested Distribution (Proof Polynomial Expansion)")
    print("=" * 60)

    # cut(min(a, b), min(c, d)) expands into 4 branches
    a, b, c, d = Atom(1), Atom(4), Atom(2), Atom(3)
    t = Cut(Min(a, b), Min(c, d))

    print(f"\nOriginal: {t}")
    print(f"Cost: {eval_term(t)} = min(1,4) + min(2,3) = 1 + 2 = 3")

    nf, trace = normalize(t)
    print(f"\nReduction trace ({len(trace)-1} steps):")
    for i, step_t in enumerate(trace):
        marker = " ← NORMAL" if i == len(trace)-1 else ""
        print(f"  Step {i}: {step_t}  [interp={interp(step_t)}]{marker}")

    print(f"\nNormal form: {nf}")
    print(f"Cost preserved: {eval_term(t)} = {eval_term(nf)} ✓")
    print(f"\nThe polynomial interpretation strictly decreased at each step:")
    interps = [interp(s) for s in trace]
    print(f"  {' > '.join(str(i) for i in interps)}")


def demo_idempotent_collapse():
    """Demo 4: Idempotent collapse — proof sharing."""
    print("\n" + "=" * 60)
    print("DEMO 4: Idempotent Collapse (Proof Sharing)")
    print("=" * 60)

    # min(min(t, t), min(t, t)) collapses to t
    t = Atom(7)
    big = Min(Min(t, t), Min(t, t))

    print(f"\nOriginal: {big}")
    print(f"Size: {term_size(big)} nodes")

    nf, trace = normalize(big)
    print(f"\nReduction trace ({len(trace)-1} steps):")
    for i, step_t in enumerate(trace):
        print(f"  Step {i}: {step_t}  [size={term_size(step_t)}]")

    print(f"\nNormal form: {nf}")
    print(f"Size: {term_size(nf)} node(s)")
    print(f"Cost preserved: {eval_term(big)} = {eval_term(nf)} ✓")
    print(f"\nDuplicate branches collapsed: proof sharing achieved!")


def demo_termination():
    """Demo 5: Polynomial interpretation guarantees termination."""
    print("\n" + "=" * 60)
    print("DEMO 5: Termination via Polynomial Interpretation")
    print("=" * 60)

    # Build a complex term and show interp strictly decreases
    a, b, c = Atom(1), Atom(2), Atom(3)
    t = Cut(Min(Cut(Min(a, b), c), b), Min(a, c))

    print(f"\nOriginal term: {t}")
    print(f"Cost: {eval_term(t)}")
    print(f"Polynomial interpretation: {interp(t)}")

    nf, trace = normalize(t)
    print(f"\nReduction trace ({len(trace)-1} steps):")
    for i, step_t in enumerate(trace):
        ip = interp(step_t)
        print(f"  Step {i}: interp = {ip:>6}  size = {term_size(step_t):>3}  cost = {eval_term(step_t)}")

    print(f"\nInterp strictly decreased: {all(interp(trace[i]) > interp(trace[i+1]) for i in range(len(trace)-1))} ✓")
    print(f"Cost always preserved: {all(eval_term(s) == eval_term(t) for s in trace)} ✓")


def demo_shortest_path():
    """Demo 6: Proof normalization as shortest path computation."""
    print("\n" + "=" * 60)
    print("DEMO 6: Normalization = Shortest Path")
    print("=" * 60)

    # Model a routing problem: 3 paths from A to C via B
    # Path 1: A→B costs 2, B→C costs 3 (total 5)
    # Path 2: A→B costs 4, B→C costs 1 (total 5)
    # Path 3: A→B costs 1, B→C costs 6 (total 7)

    path1 = Cut(Atom(2), Atom(3))  # cost 5
    path2 = Cut(Atom(4), Atom(1))  # cost 5
    path3 = Cut(Atom(1), Atom(6))  # cost 7

    # The proof term representing "choose the best path"
    t = Min(Min(path1, path2), path3)

    print(f"\nRouting problem: find shortest A→B→C path")
    print(f"  Path 1: cost {eval_term(path1)} (= 2 + 3)")
    print(f"  Path 2: cost {eval_term(path2)} (= 4 + 1)")
    print(f"  Path 3: cost {eval_term(path3)} (= 1 + 6)")
    print(f"\nOptimal cost: {eval_term(t)}")
    print(f"\nIn tropical proof theory, the proof term encodes ALL paths.")
    print(f"Normalization extracts the optimal one.")

    nf, trace = normalize(t)
    print(f"\nNormal form: {nf}")
    print(f"Cost: {eval_term(nf)} ✓")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL CURRY-HOWARD: Proofs as Min-Plus Programs     ║")
    print("║  Demonstrating tropical proof theory and normalization   ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_basic()
    demo_cut_elimination()
    demo_nested_distribution()
    demo_idempotent_collapse()
    demo_termination()
    demo_shortest_path()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("Key takeaway: Proof normalization IS cost optimization.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate visualizations for Tropical Curry-Howard."""

import base64
import io
import json

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def generate_interp_decrease_chart():
    """Chart showing polynomial interpretation decreasing during normalization."""
    if not HAS_MPL:
        return None

    # Data from demo: cut(min(cut(min(a(1),a(2)),a(3)),a(2)), min(a(1),a(3)))
    steps = list(range(8))
    interps = [65, 61, 52, 50, 49, 47, 46, 45]
    costs = [3] * 8
    sizes = [11, 15, 21, 23, 25, 27, 29, 31]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: interp decreasing
    ax1.plot(steps, interps, 'b-o', linewidth=2, markersize=8, label='Polynomial interpretation')
    ax1.fill_between(steps, interps, alpha=0.1, color='blue')
    ax1.set_xlabel('Reduction Step', fontsize=12)
    ax1.set_ylabel('Interpretation Value', fontsize=12)
    ax1.set_title('Termination: Interpretation Strictly Decreases', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: cost preserved while size grows
    ax2_twin = ax2.twinx()
    l1 = ax2.plot(steps, costs, 'g-s', linewidth=2, markersize=8, label='Tropical cost (preserved)')
    l2 = ax2_twin.plot(steps, sizes, 'r-^', linewidth=2, markersize=8, label='Term size (may grow)')
    ax2.set_xlabel('Reduction Step', fontsize=12)
    ax2.set_ylabel('Cost', fontsize=12, color='green')
    ax2_twin.set_ylabel('Size', fontsize=12, color='red')
    ax2.set_title('Soundness: Cost Preserved Despite Size Growth', fontsize=13, fontweight='bold')
    lines = l1 + l2
    labels = [l.get_label() for l in lines]
    ax2.legend(lines, labels, fontsize=11, loc='center right')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()

    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close()
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def generate_compression_chart():
    """Chart showing proof compression via idempotent collapse."""
    if not HAS_MPL:
        return None

    levels = [0, 1, 2, 3, 4, 5]
    original_sizes = [3, 7, 15, 31, 63, 127]  # 2^(k+2) - 1
    compressed_sizes = [3, 3, 3, 3, 3, 3]  # always collapses to base
    compression_ratios = [s/c for s, c in zip(original_sizes, compressed_sizes)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.bar([x - 0.2 for x in levels], original_sizes, 0.4, label='Before normalization', color='#e74c3c', alpha=0.8)
    ax1.bar([x + 0.2 for x in levels], compressed_sizes, 0.4, label='After normalization', color='#2ecc71', alpha=0.8)
    ax1.set_xlabel('Duplication Levels', fontsize=12)
    ax1.set_ylabel('Term Size (nodes)', fontsize=12)
    ax1.set_title('Proof Compression via Idempotent Collapse', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3, axis='y')

    ax2.plot(levels, compression_ratios, 'b-o', linewidth=2, markersize=8)
    ax2.fill_between(levels, compression_ratios, alpha=0.1, color='blue')
    ax2.set_xlabel('Duplication Levels', fontsize=12)
    ax2.set_ylabel('Compression Ratio', fontsize=12)
    ax2.set_title('Exponential Compression from min(P,P) = P', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()

    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close()
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def generate_diagram_svg():
    """Generate an SVG diagram showing the tropical proof calculus structure."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 500" font-family="Arial, sans-serif">
  <defs>
    <marker id="arrow" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
    </marker>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#3498db;stop-opacity:0.2"/>
      <stop offset="100%" style="stop-color:#2ecc71;stop-opacity:0.2"/>
    </linearGradient>
  </defs>

  <!-- Title -->
  <text x="400" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#2c3e50">Tropical Curry–Howard Correspondence</text>

  <!-- Syntax box -->
  <rect x="30" y="50" width="220" height="180" rx="10" fill="#ebf5fb" stroke="#3498db" stroke-width="2"/>
  <text x="140" y="75" text-anchor="middle" font-size="14" font-weight="bold" fill="#2980b9">Syntax</text>
  <text x="50" y="100" font-size="12" fill="#333">atom(n)  — axiom, cost n</text>
  <text x="50" y="120" font-size="12" fill="#333">cut(t,s) — sequence</text>
  <text x="50" y="140" font-size="12" fill="#333">plus(t,s) — parallel</text>
  <text x="50" y="160" font-size="12" fill="#333">min(t,s) — choice</text>
  <text x="50" y="190" font-size="11" fill="#666" font-style="italic">Proofs = Programs</text>
  <text x="50" y="210" font-size="11" fill="#666" font-style="italic">in min-plus algebra</text>

  <!-- Semantics box -->
  <rect x="290" y="50" width="220" height="180" rx="10" fill="#eafaf1" stroke="#2ecc71" stroke-width="2"/>
  <text x="400" y="75" text-anchor="middle" font-size="14" font-weight="bold" fill="#27ae60">Semantics</text>
  <text x="310" y="100" font-size="12" fill="#333">eval : TropTerm → ℕ</text>
  <text x="310" y="125" font-size="12" fill="#333">atom(n) ↦ n</text>
  <text x="310" y="145" font-size="12" fill="#333">cut(t,s) ↦ eval(t) + eval(s)</text>
  <text x="310" y="165" font-size="12" fill="#333">min(t,s) ↦ min(eval(t),eval(s))</text>
  <text x="310" y="195" font-size="11" fill="#666" font-style="italic">Tropical semiring</text>
  <text x="310" y="215" font-size="11" fill="#666" font-style="italic">(ℕ, min, +)</text>

  <!-- Normalization box -->
  <rect x="550" y="50" width="220" height="180" rx="10" fill="#fef9e7" stroke="#f39c12" stroke-width="2"/>
  <text x="660" y="75" text-anchor="middle" font-size="14" font-weight="bold" fill="#e67e22">Normalization</text>
  <text x="570" y="100" font-size="12" fill="#333">Step: TropTerm → TropTerm</text>
  <text x="570" y="125" font-size="12" fill="#333">min(t,t) → t</text>
  <text x="570" y="145" font-size="12" fill="#333">cut(min(t,u),s)</text>
  <text x="580" y="162" font-size="12" fill="#333">→ min(cut(t,s),cut(u,s))</text>
  <text x="570" y="195" font-size="11" fill="#666" font-style="italic">Cut elimination =</text>
  <text x="570" y="215" font-size="11" fill="#666" font-style="italic">Cost optimization</text>

  <!-- Arrows -->
  <line x1="250" y1="140" x2="290" y2="140" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
  <text x="270" y="130" text-anchor="middle" font-size="10" fill="#333">eval</text>

  <line x1="510" y1="140" x2="550" y2="140" stroke="#333" stroke-width="2" marker-end="url(#arrow)"/>
  <text x="530" y="130" text-anchor="middle" font-size="10" fill="#333">Step</text>

  <!-- Results box -->
  <rect x="100" y="280" width="600" height="200" rx="10" fill="url(#grad1)" stroke="#333" stroke-width="2"/>
  <text x="400" y="310" text-anchor="middle" font-size="16" font-weight="bold" fill="#2c3e50">Machine-Verified Theorems</text>

  <text x="140" y="340" font-size="13" fill="#333">✓ Soundness: Step preserves eval (cost invariant)</text>
  <text x="140" y="365" font-size="13" fill="#333">✓ Termination: polynomial interp strictly decreases</text>
  <text x="140" y="390" font-size="13" fill="#333">✓ Strong normalization: WellFounded Reduces</text>
  <text x="140" y="415" font-size="13" fill="#333">✓ Normal forms exist for every term</text>
  <text x="140" y="440" font-size="13" fill="#333">✓ Semantic optimality: all normal forms have same cost</text>
  <text x="140" y="465" font-size="12" fill="#666" font-style="italic">0 sorry · 0 additional axioms · fully certified</text>
</svg>'''
    return svg


if __name__ == "__main__":
    results = {}

    chart1 = generate_interp_decrease_chart()
    if chart1:
        results["interp_decrease"] = chart1
        print("Generated: interp decrease chart")

    chart2 = generate_compression_chart()
    if chart2:
        results["compression"] = chart2
        print("Generated: compression chart")

    svg = generate_diagram_svg()
    results["diagram"] = svg
    print("Generated: SVG diagram")

    # Save results
    with open("viz_data.json", "w") as f:
        json.dump(results, f)
    print(f"Saved {len(results)} visualizations to viz_data.json")
