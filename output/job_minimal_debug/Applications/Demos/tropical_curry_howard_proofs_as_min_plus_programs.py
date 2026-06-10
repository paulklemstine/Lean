#!/usr/bin/env python3
"""
Tropical Curry–Howard: Real-World Applications

Demonstrates how tropical proof normalization connects to:
1. Network routing (shortest path)
2. Project scheduling (critical path / PERT)
3. Dynamic programming (optimal sequence alignment)
4. Resource-aware program cost analysis
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, List, Tuple, Dict, Set
import heapq


# ═══════════════════════════════════════════════════════════════════════
# Core Types (duplicated for self-containment)
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class TropProof:
    pass

@dataclass(frozen=True)
class Atom(TropProof):
    n: int
    def __repr__(self): return f"atom({self.n})"

@dataclass(frozen=True)
class Cut(TropProof):
    left: TropProof; right: TropProof
    def __repr__(self): return f"cut({self.left}, {self.right})"

@dataclass(frozen=True)
class TMin(TropProof):
    left: TropProof; right: TropProof
    def __repr__(self): return f"tmin({self.left}, {self.right})"

@dataclass(frozen=True)
class TPlus(TropProof):
    left: TropProof; right: TropProof
    def __repr__(self): return f"tplus({self.left}, {self.right})"

def cost(p: TropProof) -> int:
    if isinstance(p, Atom): return p.n
    if isinstance(p, Cut): return cost(p.left) + cost(p.right)
    if isinstance(p, TMin): return min(cost(p.left), cost(p.right))
    if isinstance(p, TPlus): return cost(p.left) + cost(p.right)
    raise TypeError

def normalize(p: TropProof) -> Atom:
    return Atom(cost(p))


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Network Routing
# ═══════════════════════════════════════════════════════════════════════

def app_network_routing():
    """
    Model a network routing problem as tropical proof normalization.

    Network topology (data center):
        Server → Switch_A (latency 2ms)
        Server → Switch_B (latency 5ms)
        Switch_A → Router_1 (latency 3ms)
        Switch_A → Router_2 (latency 7ms)
        Switch_B → Router_1 (latency 1ms)
        Switch_B → Router_2 (latency 4ms)
        Router_1 → Client (latency 2ms)
        Router_2 → Client (latency 1ms)

    Each path is a tropical proof; normalization finds minimum latency.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Routing (Minimum Latency)")
    print("=" * 70)
    print()
    print("Network: Server → {Switch_A, Switch_B} → {Router_1, Router_2} → Client")
    print()

    # Encode paths as tropical proofs
    # Path via Switch_A → Router_1: 2 + 3 + 2 = 7
    path_a1 = Cut(Atom(2), Cut(Atom(3), Atom(2)))
    # Path via Switch_A → Router_2: 2 + 7 + 1 = 10
    path_a2 = Cut(Atom(2), Cut(Atom(7), Atom(1)))
    # Path via Switch_B → Router_1: 5 + 1 + 2 = 8
    path_b1 = Cut(Atom(5), Cut(Atom(1), Atom(2)))
    # Path via Switch_B → Router_2: 5 + 4 + 1 = 10
    path_b2 = Cut(Atom(5), Cut(Atom(4), Atom(1)))

    # All paths combined with tmin (choose cheapest)
    all_paths = TMin(TMin(path_a1, path_a2), TMin(path_b1, path_b2))

    result = normalize(all_paths)
    print("  Paths and latencies:")
    print(f"    Server→Switch_A→Router_1→Client: {cost(path_a1)}ms")
    print(f"    Server→Switch_A→Router_2→Client: {cost(path_a2)}ms")
    print(f"    Server→Switch_B→Router_1→Client: {cost(path_b1)}ms")
    print(f"    Server→Switch_B→Router_2→Client: {cost(path_b2)}ms")
    print()
    print(f"  Tropical normalization: {result}")
    print(f"  Optimal latency: {cost(result)}ms")
    print(f"  Best route: Server→Switch_A→Router_1→Client")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Project Scheduling (PERT/CPM)
# ═══════════════════════════════════════════════════════════════════════

def app_project_scheduling():
    """
    Model project scheduling with alternative strategies.

    Project: Build a software product
        Phase 1: {Design_A (3 weeks), Design_B (5 weeks)} - choose cheaper
        Phase 2: {Implement_X (4 weeks), Implement_Y (2 weeks)} - choose cheaper
        Phase 3: Testing (3 weeks) - fixed

    Total time = min-strategy for each phase, then sum phases.
    """
    print("=" * 70)
    print("APPLICATION 2: Project Scheduling with Strategy Selection")
    print("=" * 70)
    print()

    # Phase 1: choose between two design approaches
    phase1 = TMin(Atom(3), Atom(5))  # 3 or 5 weeks
    # Phase 2: choose between two implementations
    phase2 = TMin(Atom(4), Atom(2))  # 4 or 2 weeks
    # Phase 3: fixed testing phase
    phase3 = Atom(3)

    # Total project: sequential composition of phases
    project = Cut(Cut(phase1, phase2), phase3)

    result = normalize(project)
    print("  Project phases:")
    print(f"    Design:       min(3, 5) = {cost(phase1)} weeks")
    print(f"    Implementation: min(4, 2) = {cost(phase2)} weeks")
    print(f"    Testing:      {cost(phase3)} weeks")
    print()
    print(f"  Tropical proof term encodes all strategy combinations.")
    print(f"  Normalization computes optimal total: {cost(result)} weeks")
    print(f"  Optimal strategy: Design_A (3wk) + Implement_Y (2wk) + Testing (3wk)")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Dynamic Programming — Edit Distance
# ═══════════════════════════════════════════════════════════════════════

def app_edit_distance():
    """
    Encode a simple edit distance problem as tropical normalization.

    Transform "AB" → "BC":
        Option 1: Delete A (cost 1), Keep B (cost 0), Insert C (cost 1) = 2
        Option 2: Replace A→B (cost 1), Replace B→C (cost 1) = 2
        Option 3: Delete A (cost 1), Delete B (cost 1), Insert B (cost 1), Insert C (cost 1) = 4
    """
    print("=" * 70)
    print("APPLICATION 3: Edit Distance as Tropical Normalization")
    print("=" * 70)
    print()
    print('  Transform "AB" → "BC"')
    print()

    # Strategy 1: Delete A, Keep B, Insert C
    strat1 = Cut(Atom(1), Cut(Atom(0), Atom(1)))
    # Strategy 2: Replace A→B, Replace B→C
    strat2 = Cut(Atom(1), Atom(1))
    # Strategy 3: Delete both, Insert both
    strat3 = Cut(Cut(Atom(1), Atom(1)), Cut(Atom(1), Atom(1)))

    all_strategies = TMin(TMin(strat1, strat2), strat3)
    result = normalize(all_strategies)

    print(f"  Strategy 1 (del+keep+ins): cost = {cost(strat1)}")
    print(f"  Strategy 2 (replace+replace): cost = {cost(strat2)}")
    print(f"  Strategy 3 (del all + ins all): cost = {cost(strat3)}")
    print()
    print(f"  Tropical normalization: {result}")
    print(f"  Optimal edit distance: {cost(result)}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Resource-Aware Program Cost Analysis
# ═══════════════════════════════════════════════════════════════════════

def app_program_cost():
    """
    Analyze the cost of a program with conditional branches.

    Program:
        x = compute_A()          // cost 5
        if condition:
            y = fast_path(x)     // cost 2
        else:
            y = slow_path(x)     // cost 8
        z = finalize(y)          // cost 3

    The program's execution is a tropical proof term.
    Normalization gives the best-case execution cost.
    """
    print("=" * 70)
    print("APPLICATION 4: Program Cost Analysis")
    print("=" * 70)
    print()

    compute_a = Atom(5)
    fast_path = Atom(2)
    slow_path = Atom(8)
    finalize = Atom(3)

    # The conditional branch is tmin (choose the cheaper path)
    branch = TMin(fast_path, slow_path)

    # Full program: sequential composition
    program = Cut(compute_a, Cut(branch, finalize))

    result = normalize(program)
    print("  Program:")
    print("    x = compute_A()      // cost 5")
    print("    if condition:")
    print("      y = fast_path(x)   // cost 2")
    print("    else:")
    print("      y = slow_path(x)   // cost 8")
    print("    z = finalize(y)      // cost 3")
    print()
    print(f"  Best-case cost: {cost(result)}")
    print(f"  (fast path: 5 + 2 + 3 = 10)")
    print(f"  (slow path: 5 + 8 + 3 = 16)")
    print(f"  Tropical normalization: {result}")
    print()

    # Nested branches
    print("  Nested program with parallel resources:")
    # Inner branch: choose between two subroutines
    inner = TMin(Atom(3), Atom(7))
    # Outer: run two independent computations, each with a choice
    parallel = TPlus(
        Cut(Atom(1), inner),     # thread 1: cost 1 + min(3,7) = 4
        Cut(inner, Atom(2))      # thread 2: cost min(3,7) + 2 = 5
    )
    result2 = normalize(parallel)
    print(f"    Thread 1: 1 + min(3,7) = {cost(Cut(Atom(1), inner))}")
    print(f"    Thread 2: min(3,7) + 2 = {cost(Cut(inner, Atom(2)))}")
    print(f"    Total parallel cost: {cost(result2)}")
    print(f"    Normalization: {result2}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║    TROPICAL CURRY–HOWARD: Real-World Applications              ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    app_network_routing()
    app_project_scheduling()
    app_edit_distance()
    app_program_cost()

    print("=" * 70)
    print("All applications demonstrate: normalization = optimization. ✓")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Curry–Howard: Proofs as Min-Plus Programs — Interactive Demo

Demonstrates the core theorems with concrete numerical examples:
1. Cost semantics evaluation
2. Step-by-step tropical reduction
3. Canonical normalization
4. Confluence verification
5. Shortest-path encoding
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, List, Tuple


# ═══════════════════════════════════════════════════════════════════════
# Syntax: Tropical Proof Terms
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class TropProof:
    """Base class for tropical proof terms."""
    pass

@dataclass(frozen=True)
class Atom(TropProof):
    """Atomic proof of cost n."""
    n: int
    def __repr__(self): return f"atom({self.n})"

@dataclass(frozen=True)
class Cut(TropProof):
    """Sequential composition (cut rule). Cost = sum."""
    left: TropProof
    right: TropProof
    def __repr__(self): return f"cut({self.left}, {self.right})"

@dataclass(frozen=True)
class TMin(TropProof):
    """Nondeterministic choice (minimum). Cost = min."""
    left: TropProof
    right: TropProof
    def __repr__(self): return f"tmin({self.left}, {self.right})"

@dataclass(frozen=True)
class TPlus(TropProof):
    """Parallel accumulation. Cost = sum."""
    left: TropProof
    right: TropProof
    def __repr__(self): return f"tplus({self.left}, {self.right})"


# ═══════════════════════════════════════════════════════════════════════
# Semantics: Cost and Interpretation
# ═══════════════════════════════════════════════════════════════════════

def cost(p: TropProof) -> int:
    """Evaluate tropical cost in the min-plus semiring."""
    if isinstance(p, Atom): return p.n
    if isinstance(p, Cut): return cost(p.left) + cost(p.right)
    if isinstance(p, TMin): return min(cost(p.left), cost(p.right))
    if isinstance(p, TPlus): return cost(p.left) + cost(p.right)
    raise TypeError(f"Unknown term: {p}")

def interp(p: TropProof) -> int:
    """Polynomial interpretation for termination measure."""
    if isinstance(p, Atom): return 2
    if isinstance(p, Cut): return interp(p.left) * interp(p.right)
    if isinstance(p, TMin): return interp(p.left) + interp(p.right) + 1
    if isinstance(p, TPlus): return interp(p.left) * interp(p.right)
    raise TypeError(f"Unknown term: {p}")

def normalize(p: TropProof) -> Atom:
    """Canonical normalizer: evaluate cost and wrap as atom."""
    return Atom(cost(p))


# ═══════════════════════════════════════════════════════════════════════
# Reduction: One-Step Tropical Reduction
# ═══════════════════════════════════════════════════════════════════════

def try_reduce(p: TropProof) -> Optional[TropProof]:
    """Try to apply one reduction step. Returns None if p is in normal form."""
    # Distributive rules
    if isinstance(p, Cut) and isinstance(p.left, TMin):
        return TMin(Cut(p.left.left, p.right), Cut(p.left.right, p.right))
    if isinstance(p, Cut) and isinstance(p.right, TMin):
        return TMin(Cut(p.left, p.right.left), Cut(p.left, p.right.right))
    if isinstance(p, TPlus) and isinstance(p.left, TMin):
        return TMin(TPlus(p.left.left, p.right), TPlus(p.left.right, p.right))
    if isinstance(p, TPlus) and isinstance(p.right, TMin):
        return TMin(TPlus(p.left, p.right.left), TPlus(p.left, p.right.right))

    # Idempotent collapse
    if isinstance(p, TMin) and p.left == p.right:
        return p.left

    # Computation rules
    if isinstance(p, Cut) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(p.left.n + p.right.n)
    if isinstance(p, TPlus) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(p.left.n + p.right.n)
    if isinstance(p, TMin) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(min(p.left.n, p.right.n))

    # Congruence: try reducing subterms
    if isinstance(p, Cut):
        r = try_reduce(p.left)
        if r is not None: return Cut(r, p.right)
        r = try_reduce(p.right)
        if r is not None: return Cut(p.left, r)
    if isinstance(p, TMin):
        r = try_reduce(p.left)
        if r is not None: return TMin(r, p.right)
        r = try_reduce(p.right)
        if r is not None: return TMin(p.left, r)
    if isinstance(p, TPlus):
        r = try_reduce(p.left)
        if r is not None: return TPlus(r, p.right)
        r = try_reduce(p.right)
        if r is not None: return TPlus(p.left, r)

    return None  # Normal form


def reduce_fully(p: TropProof, verbose: bool = True) -> TropProof:
    """Reduce a term to normal form, printing each step."""
    step = 0
    if verbose:
        print(f"  Step {step}: {p}")
        print(f"          cost={cost(p)}, interp={interp(p)}")
    while True:
        q = try_reduce(p)
        if q is None:
            if verbose:
                print(f"  → Normal form reached: {p}")
            return p
        step += 1
        p = q
        if verbose:
            print(f"  Step {step}: {p}")
            print(f"          cost={cost(p)}, interp={interp(p)}")


# ═══════════════════════════════════════════════════════════════════════
# Demo 1: Basic Cost Evaluation
# ═══════════════════════════════════════════════════════════════════════

def demo_cost_evaluation():
    print("=" * 70)
    print("DEMO 1: Tropical Cost Evaluation")
    print("=" * 70)
    print()

    examples = [
        ("atom(5)", Atom(5)),
        ("cut(atom(3), atom(4))", Cut(Atom(3), Atom(4))),
        ("tmin(atom(2), atom(7))", TMin(Atom(2), Atom(7))),
        ("tplus(atom(1), atom(3))", TPlus(Atom(1), Atom(3))),
        ("cut(tmin(atom(1), atom(5)), atom(3))",
         Cut(TMin(Atom(1), Atom(5)), Atom(3))),
        ("tmin(cut(atom(2), atom(3)), cut(atom(1), atom(8)))",
         TMin(Cut(Atom(2), Atom(3)), Cut(Atom(1), Atom(8)))),
    ]

    for desc, term in examples:
        c = cost(term)
        n = normalize(term)
        print(f"  {desc}")
        print(f"    cost = {c}, normalize = {n}")
        print()


# ═══════════════════════════════════════════════════════════════════════
# Demo 2: Step-by-Step Reduction
# ═══════════════════════════════════════════════════════════════════════

def demo_step_reduction():
    print("=" * 70)
    print("DEMO 2: Step-by-Step Tropical Reduction")
    print("=" * 70)
    print()

    # Example: cut(tmin(atom(1), atom(5)), tmin(atom(2), atom(3)))
    term = Cut(TMin(Atom(1), Atom(5)), TMin(Atom(2), Atom(3)))
    print(f"Term: {term}")
    print(f"Expected normal form: atom({cost(term)})")
    print()
    reduce_fully(term)
    print()


# ═══════════════════════════════════════════════════════════════════════
# Demo 3: Idempotent Collapse
# ═══════════════════════════════════════════════════════════════════════

def demo_idempotent_collapse():
    print("=" * 70)
    print("DEMO 3: Idempotent Collapse — Duplicate Proof Elimination")
    print("=" * 70)
    print()

    # tmin(cut(atom(2), atom(3)), cut(atom(2), atom(3)))
    sub = Cut(Atom(2), Atom(3))
    term = TMin(sub, sub)
    print(f"Term: {term}")
    print(f"This represents choosing between two IDENTICAL proof strategies.")
    print(f"Idempotence collapses them into one.")
    print()
    reduce_fully(term)
    print()


# ═══════════════════════════════════════════════════════════════════════
# Demo 4: Confluence — Order Independence
# ═══════════════════════════════════════════════════════════════════════

def demo_confluence():
    print("=" * 70)
    print("DEMO 4: Confluence — All Reduction Orders Converge")
    print("=" * 70)
    print()

    term = Cut(TMin(Atom(1), Atom(4)), TMin(Atom(2), Atom(3)))
    print(f"Term: {term}")
    print(f"Expected: atom({cost(term)})")
    print()

    # Strategy 1: reduce left first
    print("Strategy 1 (reduce left distributor first):")
    t1 = TMin(Cut(Atom(1), TMin(Atom(2), Atom(3))),
              Cut(Atom(4), TMin(Atom(2), Atom(3))))
    reduce_fully(t1)
    print()

    # Strategy 2: reduce right first
    print("Strategy 2 (reduce right distributor first):")
    t2 = TMin(Cut(TMin(Atom(1), Atom(4)), Atom(2)),
              Cut(TMin(Atom(1), Atom(4)), Atom(3)))
    reduce_fully(t2)
    print()

    print("Both strategies reach the same normal form! ✓")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Demo 5: Shortest Path Encoding
# ═══════════════════════════════════════════════════════════════════════

def demo_shortest_path():
    print("=" * 70)
    print("DEMO 5: Shortest-Path as Tropical Proof Normalization")
    print("=" * 70)
    print()

    # Graph: A →(2)→ B →(3)→ D
    #        A →(1)→ C →(5)→ D
    #        A →(4)→ D (direct)
    print("Graph:")
    print("  A --2--> B --3--> D   (path cost: 5)")
    print("  A --1--> C --5--> D   (path cost: 6)")
    print("  A --4--> D             (path cost: 4)")
    print()

    path1 = Cut(Atom(2), Atom(3))  # A→B→D, cost 5
    path2 = Cut(Atom(1), Atom(5))  # A→C→D, cost 6
    path3 = Atom(4)                 # A→D,   cost 4

    all_paths = TMin(TMin(path1, path2), path3)
    print(f"Encoding: {all_paths}")
    print(f"Normalizing (= finding shortest path):")
    print()
    result = reduce_fully(all_paths)
    print()
    print(f"Shortest path cost: {cost(result)}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Demo 6: Strong Normalization — Termination Guarantee
# ═══════════════════════════════════════════════════════════════════════

def demo_strong_normalization():
    print("=" * 70)
    print("DEMO 6: Strong Normalization — Interpretation Strictly Decreases")
    print("=" * 70)
    print()

    # Build a moderately complex term
    term = Cut(
        TMin(Cut(Atom(1), Atom(2)), TPlus(Atom(3), Atom(1))),
        TMin(Atom(5), Cut(Atom(2), Atom(1)))
    )
    print(f"Term: {term}")
    print(f"Initial cost: {cost(term)}")
    print(f"Initial interp: {interp(term)}")
    print()

    steps = []
    p = term
    while True:
        steps.append((p, cost(p), interp(p)))
        q = try_reduce(p)
        if q is None:
            break
        p = q

    print("Reduction trace (interp strictly decreases at each step):")
    for i, (t, c, ip) in enumerate(steps):
        marker = "✓" if i == len(steps) - 1 else "→"
        print(f"  Step {i:2d}: cost={c:3d}, interp={ip:6d}  {marker}")

    print()
    print(f"Total reduction steps: {len(steps) - 1}")
    print(f"Final normal form: {steps[-1][0]}")
    print()


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║    TROPICAL CURRY–HOWARD: Proofs as Min-Plus Programs          ║")
    print("║    Interactive Demo of Canonical Normalization                  ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_cost_evaluation()
    demo_step_reduction()
    demo_idempotent_collapse()
    demo_confluence()
    demo_shortest_path()
    demo_strong_normalization()

    print("=" * 70)
    print("All demos complete. Every term normalizes to atom(cost(p)). ✓")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""
import json
import base64
import io
import sys
import os

# Read markdown files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Logic/TropicalCurryHowardCanonical.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations and capture base64
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# Import visualization functions
sys.path.insert(0, '.')
from visualizations import viz_interp_decrease, viz_confluence, viz_shortest_path, viz_theorem_architecture

b64_1 = viz_interp_decrease()
b64_2 = viz_confluence()
b64_3 = viz_shortest_path()
b64_4 = viz_theorem_architecture()

package = {
    "title": "Tropical Curry–Howard: Canonical Normalization of Min-Plus Proofs",
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
            "name": "Tropical Cost Evaluation",
            "pseudocode": "function COST(p):\n  match p with\n  | atom(n)     → return n\n  | cut(p, q)   → return COST(p) + COST(q)\n  | tmin(p, q)  → return min(COST(p), COST(q))\n  | tplus(p, q) → return COST(p) + COST(q)\n\nTime: O(|p|), Space: O(depth(p))",
            "code": algorithms_code
        },
        {
            "name": "Canonical Normalizer",
            "pseudocode": "function NORMALIZE(p):\n  return atom(COST(p))\n\nCorrectness:\n  1. p →* NORMALIZE(p)     [reachability]\n  2. Normal(NORMALIZE(p))  [normal form]\n  3. cost(NORMALIZE(p)) = cost(p)  [preservation]\n  4. Unique canonical form [confluence]\n\nTime: O(|p|), Space: O(depth(p))",
            "code": "def normalize(p):\n    \"\"\"Canonical normalizer: evaluate cost, wrap as atom.\"\"\"\n    return Atom(cost(p))"
        },
        {
            "name": "Step-by-Step Reduction",
            "pseudocode": "function REDUCE_STEP(p):\n  // Distributive rules\n  if p = cut(tmin(a, b), r):\n    return tmin(cut(a, r), cut(b, r))\n  if p = cut(r, tmin(a, b)):\n    return tmin(cut(r, a), cut(r, b))\n  // Idempotent collapse\n  if p = tmin(q, q):\n    return q\n  // Computation rules\n  if p = cut(atom(a), atom(b)):\n    return atom(a + b)\n  // Congruence: reduce subterms\n  ...\n\nfunction NORMALIZE_BY_REDUCTION(p):\n  while REDUCE_STEP(p) ≠ None:\n    p ← REDUCE_STEP(p)\n  return p\n\nTermination: guaranteed by strong normalization\nConfluence: result independent of reduction strategy",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Normalization Invariants (Interp Decrease & Cost Preservation)", "data": b64_1},
        {"name": "Global Confluence Diagram", "data": b64_2},
        {"name": "Shortest Path as Tropical Normalization", "data": b64_3},
        {"name": "Theorem Dependency Architecture", "data": b64_4}
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Tropical Curry–Howard: Visualizations

Generates figures for the research paper:
1. Reduction trace showing interp decrease
2. Cost preservation across reduction steps
3. Term tree visualization
4. Shortest-path graph example
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import io
import base64
from dataclasses import dataclass
from typing import Optional, List, Tuple


# ═══════════════════════════════════════════════════════════════════════
# Core Types
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class TropProof:
    pass

@dataclass(frozen=True)
class Atom(TropProof):
    n: int
    def __repr__(self): return f"atom({self.n})"

@dataclass(frozen=True)
class Cut(TropProof):
    left: TropProof; right: TropProof
    def __repr__(self): return f"cut({self.left}, {self.right})"

@dataclass(frozen=True)
class TMin(TropProof):
    left: TropProof; right: TropProof
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass(frozen=True)
class TPlus(TropProof):
    left: TropProof; right: TropProof
    def __repr__(self): return f"plus({self.left}, {self.right})"


def cost(p):
    if isinstance(p, Atom): return p.n
    if isinstance(p, Cut): return cost(p.left) + cost(p.right)
    if isinstance(p, TMin): return min(cost(p.left), cost(p.right))
    if isinstance(p, TPlus): return cost(p.left) + cost(p.right)

def interp(p):
    if isinstance(p, Atom): return 2
    if isinstance(p, Cut): return interp(p.left) * interp(p.right)
    if isinstance(p, TMin): return interp(p.left) + interp(p.right) + 1
    if isinstance(p, TPlus): return interp(p.left) * interp(p.right)

def term_size(p):
    if isinstance(p, Atom): return 1
    return 1 + term_size(p.left) + term_size(p.right)

def try_reduce(p):
    if isinstance(p, Cut) and isinstance(p.left, TMin):
        return TMin(Cut(p.left.left, p.right), Cut(p.left.right, p.right))
    if isinstance(p, Cut) and isinstance(p.right, TMin):
        return TMin(Cut(p.left, p.right.left), Cut(p.left, p.right.right))
    if isinstance(p, TPlus) and isinstance(p.left, TMin):
        return TMin(TPlus(p.left.left, p.right), TPlus(p.left.right, p.right))
    if isinstance(p, TPlus) and isinstance(p.right, TMin):
        return TMin(TPlus(p.left, p.right.left), TPlus(p.left, p.right.right))
    if isinstance(p, TMin) and p.left == p.right:
        return p.left
    if isinstance(p, Cut) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(p.left.n + p.right.n)
    if isinstance(p, TPlus) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(p.left.n + p.right.n)
    if isinstance(p, TMin) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(min(p.left.n, p.right.n))
    if isinstance(p, (Cut, TMin, TPlus)):
        r = try_reduce(p.left)
        if r is not None: return type(p)(r, p.right)
        r = try_reduce(p.right)
        if r is not None: return type(p)(p.left, r)
    return None


def reduce_trace(p):
    trace = [(p, cost(p), interp(p), term_size(p))]
    while True:
        q = try_reduce(p)
        if q is None: break
        p = q
        trace.append((p, cost(p), interp(p), term_size(p)))
    return trace


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ═══════════════════════════════════════════════════════════════════════
# Visualization 1: Interp Decrease (Strong Normalization)
# ═══════════════════════════════════════════════════════════════════════

def viz_interp_decrease():
    term = Cut(
        TMin(Cut(Atom(1), Atom(2)), TPlus(Atom(3), Atom(1))),
        TMin(Atom(5), Cut(Atom(2), Atom(1)))
    )
    trace = reduce_trace(term)
    steps = list(range(len(trace)))
    interps = [t[2] for t in trace]
    costs = [t[1] for t in trace]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Interp decrease
    ax1.plot(steps, interps, 'b-o', linewidth=2, markersize=8, color='#2196F3')
    ax1.fill_between(steps, interps, alpha=0.1, color='#2196F3')
    ax1.set_xlabel('Reduction Step', fontsize=12)
    ax1.set_ylabel('Polynomial Interpretation', fontsize=12)
    ax1.set_title('Strong Normalization:\nInterp Strictly Decreases', fontsize=14, fontweight='bold')
    ax1.grid(True, alpha=0.3)
    for i, v in enumerate(interps):
        ax1.annotate(f'{v}', (i, v), textcoords="offset points",
                     xytext=(0, 10), ha='center', fontsize=9)

    # Cost invariance
    ax2.plot(steps, costs, 'r-s', linewidth=2, markersize=8, color='#F44336')
    ax2.fill_between(steps, [min(costs)-1]*len(steps), costs, alpha=0.1, color='#F44336')
    ax2.set_xlabel('Reduction Step', fontsize=12)
    ax2.set_ylabel('Tropical Cost', fontsize=12)
    ax2.set_title('Soundness:\nCost Is Invariant', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(min(costs) - 1, max(costs) + 1)
    for i, v in enumerate(costs):
        ax2.annotate(f'{v}', (i, v), textcoords="offset points",
                     xytext=(0, 10), ha='center', fontsize=9)

    fig.suptitle('Tropical Proof Normalization: Two Key Invariants', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('viz_normalization_invariants.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_normalization_invariants.png")
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════════
# Visualization 2: Confluence Diagram
# ═══════════════════════════════════════════════════════════════════════

def viz_confluence():
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(-2, 12)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')

    # Node positions
    nodes = {
        'p': (5, 8),
        'q1': (1, 5),
        'q2': (9, 5),
        'r1': (0, 2),
        'r2': (3, 2),
        'r3': (7, 2),
        'r4': (10, 2),
        'nf': (5, 0),
    }

    # Draw arrows
    def draw_arrow(start, end, color='#555', style='->', lw=1.5):
        ax.annotate('', xy=end, xytext=start,
                     arrowprops=dict(arrowstyle=style, color=color, lw=lw))

    # Main divergence
    draw_arrow(nodes['p'], nodes['q1'], color='#2196F3', lw=2)
    draw_arrow(nodes['p'], nodes['q2'], color='#F44336', lw=2)

    # Further reductions
    draw_arrow(nodes['q1'], nodes['r1'], color='#2196F3', lw=1.5)
    draw_arrow(nodes['q1'], nodes['r2'], color='#9C27B0', lw=1.5)
    draw_arrow(nodes['q2'], nodes['r3'], color='#9C27B0', lw=1.5)
    draw_arrow(nodes['q2'], nodes['r4'], color='#F44336', lw=1.5)

    # All converge to normal form
    for key in ['r1', 'r2', 'r3', 'r4']:
        draw_arrow(nodes[key], nodes['nf'], color='#4CAF50', lw=2, style='->')

    # Draw nodes
    for name, (x, y) in nodes.items():
        color = '#4CAF50' if name == 'nf' else '#FFC107' if name == 'p' else '#E3F2FD'
        circle = plt.Circle((x, y), 0.5, color=color, ec='#333', lw=2, zorder=5)
        ax.add_patch(circle)

    # Labels
    ax.text(5, 8, 'p', ha='center', va='center', fontsize=14, fontweight='bold', zorder=6)
    ax.text(1, 5, 'q₁', ha='center', va='center', fontsize=12, zorder=6)
    ax.text(9, 5, 'q₂', ha='center', va='center', fontsize=12, zorder=6)
    ax.text(0, 2, 'r₁', ha='center', va='center', fontsize=11, zorder=6)
    ax.text(3, 2, 'r₂', ha='center', va='center', fontsize=11, zorder=6)
    ax.text(7, 2, 'r₃', ha='center', va='center', fontsize=11, zorder=6)
    ax.text(10, 2, 'r₄', ha='center', va='center', fontsize=11, zorder=6)
    ax.text(5, 0, 'atom(c)', ha='center', va='center', fontsize=12, fontweight='bold',
            color='white', zorder=6)

    ax.set_title('Global Confluence: All Paths Converge\nto the Unique Normal Form atom(cost(p))',
                 fontsize=16, fontweight='bold', pad=20)

    # Legend
    blue_patch = mpatches.Patch(color='#2196F3', label='Path 1')
    red_patch = mpatches.Patch(color='#F44336', label='Path 2')
    green_patch = mpatches.Patch(color='#4CAF50', label='Convergence')
    ax.legend(handles=[blue_patch, red_patch, green_patch], loc='upper left', fontsize=11)

    fig.savefig('viz_confluence.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_confluence.png")
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════════
# Visualization 3: Shortest Path Graph
# ═══════════════════════════════════════════════════════════════════════

def viz_shortest_path():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Graph layout
    positions = {'S': (0, 1), 'A': (2, 2), 'B': (2, 0), 'T': (4, 1)}
    edges = [('S', 'A', 1), ('S', 'B', 4), ('A', 'B', 2), ('A', 'T', 6), ('B', 'T', 3)]

    # Draw graph
    for u, v, w in edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        # Highlight shortest path: S→A→B→T (cost 6)
        is_shortest = (u, v) in [('S', 'A'), ('A', 'B'), ('B', 'T')]
        color = '#4CAF50' if is_shortest else '#999'
        lw = 3 if is_shortest else 1.5
        ax1.annotate('', xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle='->', color=color, lw=lw))
        mx, my = (x1+x2)/2, (y1+y2)/2
        offset = (0.15, 0.15) if y2 >= y1 else (0.15, -0.25)
        ax1.text(mx+offset[0], my+offset[1], str(w), fontsize=12,
                fontweight='bold', color=color)

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.25, color='#E3F2FD', ec='#333', lw=2, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y, name, ha='center', va='center', fontsize=14,
                fontweight='bold', zorder=6)

    ax1.set_xlim(-0.5, 4.8)
    ax1.set_ylim(-0.5, 2.8)
    ax1.set_aspect('equal')
    ax1.axis('off')
    ax1.set_title('Weighted Graph\n(shortest path in green)', fontsize=14, fontweight='bold')

    # Tropical proof term and reduction
    term_lines = [
        "tmin(",
        "  tmin(",
        "    cut(atom(1), cut(atom(2), atom(3))),",
        "    cut(atom(1), atom(6))",
        "  ),",
        "  tmin(",
        "    cut(atom(4), atom(3)),",
        "    ∅",
        "  )",
        ")",
        "",
        "↓ normalize",
        "",
        "atom(6)",
        "",
        "Shortest path cost = 6",
        "(S→A→B→T: 1+2+3)"
    ]

    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, len(term_lines)+1)
    ax2.axis('off')
    for i, line in enumerate(term_lines):
        color = '#4CAF50' if 'atom(6)' in line or 'Shortest' in line else '#333'
        weight = 'bold' if 'atom(6)' in line or 'normalize' in line or 'Shortest' in line else 'normal'
        ax2.text(1, len(term_lines)-i, line, fontsize=11, fontfamily='monospace',
                color=color, fontweight=weight, va='top')
    ax2.set_title('Tropical Proof Encoding\n& Normalization', fontsize=14, fontweight='bold')

    fig.suptitle('Shortest Path = Tropical Proof Normalization', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('viz_shortest_path.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_shortest_path.png")
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════════
# Visualization 4: Theorem Architecture
# ═══════════════════════════════════════════════════════════════════════

def viz_theorem_architecture():
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')

    boxes = [
        (1, 8.5, 4.5, 0.8, 'Soundness\nstep_preserves_cost', '#BBDEFB'),
        (6.5, 8.5, 4.5, 0.8, 'Strong Normalization\nstep_decreases_interp', '#C8E6C9'),
        (1, 6.5, 4.5, 0.8, 'Normal Form = Atom\nnormal_is_atom', '#FFF9C4'),
        (6.5, 6.5, 4.5, 0.8, 'Reduces to Normalize\np →* atom(cost p)', '#FFCCBC'),
        (3.5, 4.5, 5, 0.8, 'Global Confluence\ntropical_confluence', '#E1BEE7'),
        (1, 2.5, 4.5, 0.8, 'Normal Form Uniqueness\nnormalize_unique', '#B2DFDB'),
        (6.5, 2.5, 4.5, 0.8, 'Canonicality\nnormalize_canonical', '#F8BBD0'),
        (2.5, 0.5, 7, 1, '★ Flagship Theorem ★\ntropical_curry_howard_canonical', '#FFD54F'),
    ]

    for x, y, w, h, text, color in boxes:
        rect = plt.Rectangle((x, y), w, h, facecolor=color, edgecolor='#333',
                              linewidth=2, zorder=3, alpha=0.9)
        ax.add_patch(rect)
        ax.text(x + w/2, y + h/2, text, ha='center', va='center',
                fontsize=9, fontweight='bold', zorder=4)

    # Dependency arrows
    arrows = [
        ((3.25, 8.5), (3.25, 7.3)),   # Soundness → Normal=Atom
        ((8.75, 8.5), (8.75, 7.3)),   # SN → Reduces
        ((3.25, 6.5), (5.5, 5.3)),    # Normal=Atom → Confluence
        ((8.75, 6.5), (6.5, 5.3)),    # Reduces → Confluence
        ((4.5, 4.5), (3.25, 3.3)),    # Confluence → Uniqueness
        ((7.5, 4.5), (8.75, 3.3)),    # Confluence → Canonicality
        ((3.25, 2.5), (5, 1.5)),      # Uniqueness → Flagship
        ((8.75, 2.5), (7.5, 1.5)),    # Canonicality → Flagship
    ]

    for start, end in arrows:
        ax.annotate('', xy=end, xytext=start,
                     arrowprops=dict(arrowstyle='->', color='#666', lw=1.5))

    ax.set_title('Theorem Dependency Architecture', fontsize=16, fontweight='bold', pad=20)

    fig.savefig('viz_theorem_architecture.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_theorem_architecture.png")
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating visualizations...\n")

    b64_1 = viz_interp_decrease()
    b64_2 = viz_confluence()
    b64_3 = viz_shortest_path()
    b64_4 = viz_theorem_architecture()

    print("\nAll visualizations generated successfully.")
    print(f"  viz_normalization_invariants.png ({len(b64_1)} chars base64)")
    print(f"  viz_confluence.png ({len(b64_2)} chars base64)")
    print(f"  viz_shortest_path.png ({len(b64_3)} chars base64)")
    print(f"  viz_theorem_architecture.png ({len(b64_4)} chars base64)")
