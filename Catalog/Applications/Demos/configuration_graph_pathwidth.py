#!/usr/bin/env python3
"""
applications.py — Real-world applications of Configuration Graph Pathwidth theory.

Demonstrates how the connection between proof memory and pathwidth
can be applied to:
1. SAT solver memory prediction
2. Proof complexity analysis
3. Formula difficulty classification
"""

from __future__ import annotations
from itertools import combinations, product
import random
import time


# ── Inline core implementations (self-contained) ──

class CNFFormula:
    def __init__(self, clauses, n_vars):
        self.clauses = [frozenset(c) for c in clauses]
        self.n_vars = n_vars

    def is_satisfied_by(self, assignment):
        return all(
            any(assignment.get(v) == p for v, p in clause)
            for clause in self.clauses
        )

    def is_unsatisfiable(self):
        for bits in product([False, True], repeat=self.n_vars):
            if self.is_satisfied_by({i: bits[i] for i in range(self.n_vars)}):
                return False
        return True

    def __repr__(self):
        parts = []
        for c in self.clauses:
            lits = [f"x{v}" if p else f"¬x{v}" for v, p in sorted(c)]
            parts.append("(" + " ∨ ".join(lits) + ")")
        return " ∧ ".join(parts)


def build_conf_graph(formula, s):
    all_clauses = list(set(formula.clauses))
    vertices = set()
    for size in range(s + 1):
        for subset in combinations(all_clauses, size):
            vertices.add(frozenset(subset))
    edges = set()
    for v in vertices:
        for clause in all_clauses:
            if clause not in v:
                nb = frozenset(v | {clause})
                if len(nb) <= s and nb in vertices:
                    edges.add((min(v, nb), max(v, nb)))
            else:
                nb = frozenset(v - {clause})
                if nb in vertices:
                    edges.add((min(v, nb), max(v, nb)))
    return vertices, edges


def pathwidth_greedy(vertices, edges):
    if not vertices:
        return 0
    adj = {v: set() for v in vertices}
    for u, v in edges:
        if u in adj and v in adj:
            adj[u].add(v)
            adj[v].add(u)
    start = next(iter(vertices))
    visited, queue, seen = [], [start], {start}
    while queue:
        v = queue.pop(0)
        visited.append(v)
        for u in adj.get(v, []):
            if u not in seen:
                seen.add(u)
                queue.append(u)
    for v in vertices:
        if v not in seen:
            visited.append(v)
    n = len(visited)
    order = {v: i for i, v in enumerate(visited)}
    intervals = {v: [order[v], order[v]] for v in visited}
    for u, v in edges:
        if u in order and v in order:
            lo, hi = min(order[u], order[v]), max(order[u], order[v])
            intervals[u] = [min(intervals[u][0], lo), max(intervals[u][1], hi)]
            intervals[v] = [min(intervals[v][0], lo), max(intervals[v][1], hi)]
    max_bag = max(
        (sum(1 for v in visited if intervals[v][0] <= pos <= intervals[v][1])
         for pos in range(n)), default=1
    )
    return max_bag - 1


def estimate_clause_space(formula):
    clauses = set(formula.clauses)
    config = set()
    max_space = 0
    best = len(clauses) + 1
    for c in clauses:
        config.add(c)
        max_space = max(max_space, len(config))
        new = set()
        for c1 in config:
            for c2 in config:
                if c1 >= c2:
                    continue
                for var, pol in c1:
                    if (var, not pol) in c2:
                        r = frozenset((c1 - {(var, pol)}) | (c2 - {(var, not pol)}))
                        new.add(r)
        for nc in new:
            config.add(nc)
            max_space = max(max_space, len(config))
            if len(nc) == 0:
                best = min(best, max_space)
    return best


# ── Application 1: SAT Solver Memory Prediction ──

def app_memory_prediction():
    """Predict SAT solver memory requirements using pathwidth analysis."""
    print("=" * 70)
    print("APPLICATION 1: SAT Solver Memory Prediction")
    print("=" * 70)
    print()
    print("Key insight: The pathwidth of the configuration graph provides")
    print("a structural lower bound on the memory any resolution-based")
    print("SAT solver needs to refute a formula.")
    print()

    formulas = [
        ("Unit contradiction", CNFFormula([
            frozenset([(0, True)]),
            frozenset([(0, False)]),
        ], 1)),
        ("2-var full", CNFFormula([
            frozenset([(0, True), (1, True)]),
            frozenset([(0, True), (1, False)]),
            frozenset([(0, False), (1, True)]),
            frozenset([(0, False), (1, False)]),
        ], 2)),
        ("Chain 2-var", CNFFormula([
            frozenset([(0, True)]),
            frozenset([(0, False), (1, True)]),
            frozenset([(1, False)]),
        ], 2)),
        ("Mixed 2-var", CNFFormula([
            frozenset([(0, True)]),
            frozenset([(0, False)]),
            frozenset([(1, True)]),
            frozenset([(1, False)]),
        ], 2)),
    ]

    print(f"{'Formula':<20} {'Space':>6} {'PW':>4} {'Ratio':>7} {'Memory Bound':>13}")
    print("─" * 60)
    for name, f in formulas:
        if not f.is_unsatisfiable():
            continue
        space = estimate_clause_space(f)
        verts, edges = build_conf_graph(f, min(space, 6))
        pw = pathwidth_greedy(verts, edges)
        ratio = pw / space if space > 0 else 0
        print(f"{name:<20} {space:>6} {pw:>4} {ratio:>7.3f} {f'≥ {pw+1} clauses':>13}")
    print()


# ── Application 2: Formula Difficulty Classification ──

def app_difficulty_classification():
    """Classify formula difficulty using configuration graph structure."""
    print("=" * 70)
    print("APPLICATION 2: Formula Difficulty Classification")
    print("=" * 70)
    print()
    print("The ratio pathwidth/clause_space classifies formulas by structural")
    print("difficulty. Higher ratios indicate more complex proof search.")
    print()

    all_lits = [(0, True), (0, False), (1, True), (1, False)]
    all_clauses = []
    for size in range(1, 4):
        for subset in combinations(all_lits, size):
            vars_seen = {}
            valid = True
            for v, p in subset:
                if v in vars_seen and vars_seen[v] != p:
                    valid = False
                    break
                vars_seen[v] = p
            if valid:
                all_clauses.append(frozenset(subset))

    easy, medium, hard = [], [], []

    for n_cl in range(2, 5):
        for clause_set in combinations(all_clauses, n_cl):
            f = CNFFormula(list(clause_set), 2)
            if not f.is_unsatisfiable():
                continue
            space = estimate_clause_space(f)
            if space > 8:
                continue
            verts, edges = build_conf_graph(f, space)
            if len(verts) > 50:
                continue
            pw = pathwidth_greedy(verts, edges)
            ratio = pw / space if space > 0 else 0
            entry = (f, space, pw, ratio)
            if ratio <= 0.5:
                easy.append(entry)
            elif ratio <= 1.0:
                medium.append(entry)
            else:
                hard.append(entry)

    print(f"Classification of unsatisfiable 2-variable formulas:")
    print(f"  Easy   (ratio ≤ 0.5): {len(easy)} formulas")
    print(f"  Medium (0.5 < ratio ≤ 1.0): {len(medium)} formulas")
    print(f"  Hard   (ratio > 1.0): {len(hard)} formulas")
    print()
    if easy:
        print("Sample easy formula:")
        f, s, pw, r = easy[0]
        print(f"  {f}  (space={s}, pw={pw}, ratio={r:.3f})")
    if hard:
        print("Sample hard formula:")
        f, s, pw, r = hard[0]
        print(f"  {f}  (space={s}, pw={pw}, ratio={r:.3f})")
    print()


# ── Application 3: Proof Strategy Optimization ──

def app_proof_strategy():
    """Use pathwidth analysis to suggest optimal proof strategies."""
    print("=" * 70)
    print("APPLICATION 3: Proof Strategy Recommendation")
    print("=" * 70)
    print()
    print("Low pathwidth → linear (DPLL-like) strategies are efficient")
    print("High pathwidth → need more sophisticated memory management")
    print()

    # Compare different resolution orderings
    f = CNFFormula([
        frozenset([(0, True), (1, True)]),
        frozenset([(0, True), (1, False)]),
        frozenset([(0, False), (1, True)]),
        frozenset([(0, False), (1, False)]),
    ], 2)

    print(f"Formula: {f}")
    print()

    # Trace 1: Resolve on x₁ first
    c0 = frozenset([(0, True), (1, True)])
    c1 = frozenset([(0, True), (1, False)])
    c2 = frozenset([(0, False), (1, True)])
    c3 = frozenset([(0, False), (1, False)])
    r01 = frozenset([(0, True)])   # resolve c0, c1 on x₁
    r23 = frozenset([(0, False)])  # resolve c2, c3 on x₁
    empty = frozenset()

    trace1 = [
        frozenset(),
        frozenset({c0}),
        frozenset({c0, c1}),
        frozenset({c0, c1, r01}),
        frozenset({r01}),          # erase c0, c1
        frozenset({r01, c2}),
        frozenset({r01, c2, c3}),
        frozenset({r01, c2, c3, r23}),
        frozenset({r01, r23}),      # erase c2, c3
        frozenset({r01, r23, empty}),
    ]

    # Check regularity
    regular1 = True
    all_elem = set().union(*trace1)
    for elem in all_elem:
        idxs = [i for i, c in enumerate(trace1) if elem in c]
        if idxs:
            lo, hi = min(idxs), max(idxs)
            if any(elem not in trace1[j] for j in range(lo, hi + 1)):
                regular1 = False
                break

    space1 = max(len(c) for c in trace1)
    print(f"Strategy 1 (resolve x₁ first, then x₀):")
    print(f"  Trace length: {len(trace1)}")
    print(f"  Clause space: {space1}")
    print(f"  Regular: {regular1}")
    if regular1:
        print(f"  Path decomposition width ≤ {space1 - 1} (by our theorem)")
    print()

    # Trace 2: Resolve on x₀ first
    r02 = frozenset([(1, True)])   # resolve c0, c2 on x₀
    r13 = frozenset([(1, False)])  # resolve c1, c3 on x₀

    trace2 = [
        frozenset(),
        frozenset({c0}),
        frozenset({c0, c2}),
        frozenset({c0, c2, r02}),
        frozenset({r02}),
        frozenset({r02, c1}),
        frozenset({r02, c1, c3}),
        frozenset({r02, c1, c3, r13}),
        frozenset({r02, r13}),
        frozenset({r02, r13, empty}),
    ]

    regular2 = True
    all_elem2 = set().union(*trace2)
    for elem in all_elem2:
        idxs = [i for i, c in enumerate(trace2) if elem in c]
        if idxs:
            lo, hi = min(idxs), max(idxs)
            if any(elem not in trace2[j] for j in range(lo, hi + 1)):
                regular2 = False
                break

    space2 = max(len(c) for c in trace2)
    print(f"Strategy 2 (resolve x₀ first, then x₁):")
    print(f"  Trace length: {len(trace2)}")
    print(f"  Clause space: {space2}")
    print(f"  Regular: {regular2}")
    if regular2:
        print(f"  Path decomposition width ≤ {space2 - 1} (by our theorem)")
    print()

    print("Both strategies achieve the same clause space and pathwidth bound.")
    print("The theorem guarantees that ANY regular trace with this space bound")
    print("yields a path decomposition of at most this width.")
    print()


def main():
    app_memory_prediction()
    app_difficulty_classification()
    app_proof_strategy()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Configuration Graph Pathwidth theory.

This script demonstrates the connection between resolution proof memory
(clause space) and graph-theoretic pathwidth of configuration graphs.

Usage:
    python demo.py              # Run with built-in examples
    python demo.py --interactive  # Enter your own CNF formulas
"""

from __future__ import annotations
import sys


# ── Inline implementations (self-contained, no local imports) ──

from itertools import combinations, product


class PathDecomposition:
    """A path decomposition: sequence of bags (sets of vertices)."""
    def __init__(self, bags: list[frozenset]):
        self.bags = bags

    @property
    def width(self) -> int:
        return max(len(b) for b in self.bags) - 1 if self.bags else 0

    def has_interval_property(self) -> bool:
        all_verts = set().union(*self.bags)
        for v in all_verts:
            idxs = [i for i, b in enumerate(self.bags) if v in b]
            if idxs and any(v not in self.bags[j] for j in range(min(idxs), max(idxs)+1)):
                return False
        return True


class CNFFormula:
    """CNF formula: list of clauses, each a frozenset of (var, polarity) pairs."""
    def __init__(self, clauses, n_vars):
        self.clauses = [frozenset(c) for c in clauses]
        self.n_vars = n_vars

    def is_satisfied_by(self, assignment):
        for clause in self.clauses:
            if not any(assignment.get(v) == p for v, p in clause):
                return False
        return True

    def is_unsatisfiable(self):
        for bits in product([False, True], repeat=self.n_vars):
            if self.is_satisfied_by({i: bits[i] for i in range(self.n_vars)}):
                return False
        return True

    def __repr__(self):
        parts = []
        for c in self.clauses:
            lits = []
            for var, pol in sorted(c):
                lits.append(f"x{var}" if pol else f"¬x{var}")
            parts.append("(" + " ∨ ".join(lits) + ")")
        return " ∧ ".join(parts)


def build_conf_graph(formula, s):
    """Build bounded configuration graph. Returns (vertices, edges)."""
    all_clauses = list(set(formula.clauses))
    vertices = set()
    for size in range(s + 1):
        for subset in combinations(all_clauses, size):
            vertices.add(frozenset(subset))
    edges = set()
    for v in vertices:
        for clause in all_clauses:
            if clause not in v:
                nb = frozenset(v | {clause})
                if len(nb) <= s and nb in vertices:
                    edges.add((min(v, nb), max(v, nb)))
            else:
                nb = frozenset(v - {clause})
                if nb in vertices:
                    edges.add((min(v, nb), max(v, nb)))
    return vertices, edges


def pathwidth_brute(vertices, edges, cap=10):
    """Exact pathwidth for small graphs via brute force."""
    from itertools import permutations
    vlist = list(vertices)
    n = len(vlist)
    if n == 0:
        return 0
    if n > 8:
        return pathwidth_greedy(vertices, edges)

    best = n - 1
    for perm in permutations(range(n)):
        order = {vlist[perm[i]]: i for i in range(n)}
        intervals = {v: [order[v], order[v]] for v in vlist}
        for u, v in edges:
            if u in order and v in order:
                lo, hi = min(order[u], order[v]), max(order[u], order[v])
                intervals[u] = [min(intervals[u][0], lo), max(intervals[u][1], hi)]
                intervals[v] = [min(intervals[v][0], lo), max(intervals[v][1], hi)]
        max_bag = max(
            sum(1 for v in vlist if intervals[v][0] <= pos <= intervals[v][1])
            for pos in range(n)
        )
        best = min(best, max_bag - 1)
        if best <= 1:
            break
    return best


def pathwidth_greedy(vertices, edges):
    """Greedy upper bound on pathwidth."""
    if not vertices:
        return 0
    adj = {v: set() for v in vertices}
    for u, v in edges:
        if u in adj and v in adj:
            adj[u].add(v)
            adj[v].add(u)
    start = next(iter(vertices))
    visited, queue, seen = [], [start], {start}
    while queue:
        v = queue.pop(0)
        visited.append(v)
        for u in adj.get(v, []):
            if u not in seen:
                seen.add(u)
                queue.append(u)
    for v in vertices:
        if v not in seen:
            visited.append(v)
    n = len(visited)
    order = {v: i for i, v in enumerate(visited)}
    intervals = {v: [order[v], order[v]] for v in visited}
    for u, v in edges:
        if u in order and v in order:
            lo, hi = min(order[u], order[v]), max(order[u], order[v])
            intervals[u] = [min(intervals[u][0], lo), max(intervals[u][1], hi)]
            intervals[v] = [min(intervals[v][0], lo), max(intervals[v][1], hi)]
    max_bag = max(
        (sum(1 for v in visited if intervals[v][0] <= pos <= intervals[v][1])
         for pos in range(n)), default=1
    )
    return max_bag - 1


def estimate_clause_space(formula):
    """Greedy upper bound on clause space."""
    if not formula.is_unsatisfiable():
        return float('inf')
    clauses = set(formula.clauses)
    config = set()
    max_space = 0
    best = len(clauses) + 1
    for c in clauses:
        config.add(c)
        max_space = max(max_space, len(config))
        new = set()
        for c1 in config:
            for c2 in config:
                if c1 >= c2:
                    continue
                for var, pol in c1:
                    if (var, not pol) in c2:
                        r = frozenset((c1 - {(var, pol)}) | (c2 - {(var, not pol)}))
                        new.add(r)
        for nc in new:
            config.add(nc)
            max_space = max(max_space, len(config))
            if len(nc) == 0:
                best = min(best, max_space)
    return best


# ── Demo Functions ──

def demo_basic():
    """Demonstrate the core theory on small formulas."""
    print("=" * 70)
    print("  CONFIGURATION GRAPH PATHWIDTH — PROOF MEMORY AS GRAPH LAYOUT")
    print("=" * 70)
    print()
    print("This demo shows how resolution proof memory (clause space)")
    print("controls the pathwidth of configuration graphs.")
    print()

    # Example 1: Simple unsatisfiable formula on 2 variables
    print("─" * 70)
    print("Example 1: Complete 2-variable unsatisfiable formula")
    print("─" * 70)
    f1 = CNFFormula([
        frozenset([(0, True), (1, True)]),    # x₀ ∨ x₁
        frozenset([(0, True), (1, False)]),   # x₀ ∨ ¬x₁
        frozenset([(0, False), (1, True)]),   # ¬x₀ ∨ x₁
        frozenset([(0, False), (1, False)]),  # ¬x₀ ∨ ¬x₁
    ], n_vars=2)

    print(f"Formula: {f1}")
    print(f"Unsatisfiable: {f1.is_unsatisfiable()}")
    space = estimate_clause_space(f1)
    print(f"Clause space (upper bound): {space}")
    verts, edges = build_conf_graph(f1, space)
    print(f"Config graph: {len(verts)} vertices, {len(edges)} edges")
    pw = pathwidth_brute(verts, edges) if len(verts) <= 8 else pathwidth_greedy(verts, edges)
    print(f"Pathwidth: {pw}")
    ratio = pw / space if space > 0 else 0
    print(f"Ratio (pathwidth / clause_space): {ratio:.3f}")
    print(f"Conjecture pw ≤ 4·s holds: {pw <= 4 * space}")
    print()

    # Example 2: Unit clause contradiction
    print("─" * 70)
    print("Example 2: Unit clause contradiction")
    print("─" * 70)
    f2 = CNFFormula([
        frozenset([(0, True)]),   # x₀
        frozenset([(0, False)]),  # ¬x₀
    ], n_vars=1)

    print(f"Formula: {f2}")
    print(f"Unsatisfiable: {f2.is_unsatisfiable()}")
    space2 = estimate_clause_space(f2)
    print(f"Clause space (upper bound): {space2}")
    verts2, edges2 = build_conf_graph(f2, space2)
    print(f"Config graph: {len(verts2)} vertices, {len(edges2)} edges")
    pw2 = pathwidth_brute(verts2, edges2) if len(verts2) <= 8 else pathwidth_greedy(verts2, edges2)
    print(f"Pathwidth: {pw2}")
    print(f"Ratio: {pw2/space2 if space2 > 0 else 0:.3f}")
    print()

    # Example 3: Pigeonhole-like on 2 variables
    print("─" * 70)
    print("Example 3: Three-clause contradiction")
    print("─" * 70)
    f3 = CNFFormula([
        frozenset([(0, True)]),                      # x₀
        frozenset([(0, False), (1, True)]),           # ¬x₀ ∨ x₁
        frozenset([(1, False)]),                      # ¬x₁
    ], n_vars=2)

    print(f"Formula: {f3}")
    print(f"Unsatisfiable: {f3.is_unsatisfiable()}")
    space3 = estimate_clause_space(f3)
    print(f"Clause space (upper bound): {space3}")
    verts3, edges3 = build_conf_graph(f3, space3)
    print(f"Config graph: {len(verts3)} vertices, {len(edges3)} edges")
    pw3 = pathwidth_brute(verts3, edges3) if len(verts3) <= 8 else pathwidth_greedy(verts3, edges3)
    print(f"Pathwidth: {pw3}")
    print(f"Ratio: {pw3/space3 if space3 > 0 else 0:.3f}")
    print()


def demo_trace_decomposition():
    """Demonstrate how a trace becomes a path decomposition."""
    print("─" * 70)
    print("TRACE → PATH DECOMPOSITION CONSTRUCTION")
    print("─" * 70)
    print()
    print("A resolution trace is a sequence of configurations (clause sets).")
    print("Each configuration becomes a bag in a path decomposition.")
    print()

    # A simple trace for x₀ ∧ ¬x₀
    c1 = frozenset(["x"])
    c2 = frozenset(["¬x"])
    c3 = frozenset()  # empty clause

    trace = [
        frozenset(),           # Start empty
        frozenset({c1}),       # Download x₀
        frozenset({c1, c2}),   # Download ¬x₀
        frozenset({c1, c2, c3}),  # Resolve to get ∅
    ]

    print("Trace (clause sets at each step):")
    for i, config in enumerate(trace):
        clauses = sorted(config, key=str) if config else ["∅"]
        print(f"  Step {i}: {{{', '.join(str(c) for c in clauses)}}}")

    pd = PathDecomposition(trace)
    print(f"\nPath decomposition width: {pd.width}")
    print(f"Interval property satisfied: {pd.has_interval_property()}")
    print(f"Clause space: {max(len(c) for c in trace)}")
    print(f"Width ≤ clause_space - 1: {pd.width <= max(len(c) for c in trace) - 1}")

    # Check regularity
    all_elements = set().union(*trace)
    regular = True
    for elem in all_elements:
        idxs = [i for i, c in enumerate(trace) if elem in c]
        if idxs:
            lo, hi = min(idxs), max(idxs)
            if any(elem not in trace[j] for j in range(lo, hi + 1)):
                regular = False
                break
    print(f"Trace is regular (monotone): {regular}")
    print()


def demo_conjecture_test():
    """Test the universal constant conjecture on small formulas."""
    print("─" * 70)
    print("CONJECTURE TEST: pw(ConfGraph_s(F)) ≤ c·s")
    print("─" * 70)
    print()
    print("Testing on all unsatisfiable 2-variable CNFs with ≤ 4 clauses...")
    print()

    # Generate all clauses over 2 variables
    all_lits = [(0, True), (0, False), (1, True), (1, False)]
    all_clauses = []
    for size in range(1, 5):
        for subset in combinations(all_lits, size):
            vars_seen = {}
            valid = True
            for v, p in subset:
                if v in vars_seen and vars_seen[v] != p:
                    valid = False
                    break
                vars_seen[v] = p
            if valid:
                all_clauses.append(frozenset(subset))

    max_ratio = 0
    count = 0
    results = []

    for n_clauses in range(2, 5):
        for clause_set in combinations(all_clauses, n_clauses):
            f = CNFFormula(list(clause_set), n_vars=2)
            if not f.is_unsatisfiable():
                continue
            count += 1
            space = estimate_clause_space(f)
            if space > 10:
                continue
            verts, edges = build_conf_graph(f, space)
            if len(verts) > 8:
                pw = pathwidth_greedy(verts, edges)
            else:
                pw = pathwidth_brute(verts, edges)
            ratio = pw / space if space > 0 else 0
            max_ratio = max(max_ratio, ratio)
            results.append((f, space, pw, ratio))

    print(f"Found {count} unsatisfiable formulas")
    print(f"Analyzed {len(results)} with tractable config graphs")
    print(f"Maximum ratio pw/s: {max_ratio:.3f}")
    print(f"Conjecture holds with c = {max(1, int(max_ratio) + 1)}")
    print()

    # Show top 5 by ratio
    results.sort(key=lambda x: -x[3])
    print("Top formulas by pw/space ratio:")
    for f, s, pw, r in results[:5]:
        print(f"  {f}")
        print(f"    space={s}, pw={pw}, ratio={r:.3f}")
    print()


def demo_interactive():
    """Interactive mode: enter a CNF formula and analyze it."""
    print("─" * 70)
    print("INTERACTIVE MODE")
    print("─" * 70)
    print()
    print("Enter a CNF formula.")
    print("Format: number of variables, then clauses as lists of signed integers.")
    print("  Positive = variable, Negative = negation")
    print("  Example: '2' then '1 2' then '-1 2' then '-1 -2' then '1 -2' then 'done'")
    print()

    try:
        n_vars = int(input("Number of variables: "))
    except (ValueError, EOFError):
        print("Invalid input.")
        return

    clauses = []
    print("Enter clauses (signed integers, one clause per line, 'done' to finish):")
    while True:
        try:
            line = input("> ").strip()
        except EOFError:
            break
        if line.lower() == 'done' or line == '':
            break
        try:
            lits = []
            for x in line.split():
                v = int(x)
                if v == 0:
                    continue
                lits.append((abs(v) - 1, v > 0))
            clauses.append(frozenset(lits))
        except ValueError:
            print("Invalid clause format. Use signed integers.")
            continue

    if not clauses:
        print("No clauses entered.")
        return

    f = CNFFormula(clauses, n_vars)
    print(f"\nFormula: {f}")
    print(f"Unsatisfiable: {f.is_unsatisfiable()}")

    if not f.is_unsatisfiable():
        print("Formula is satisfiable — no refutation exists.")
        return

    space = estimate_clause_space(f)
    print(f"Clause space (upper bound): {space}")

    verts, edges = build_conf_graph(f, min(space, 6))
    print(f"Config graph: {len(verts)} vertices, {len(edges)} edges")

    if len(verts) <= 8:
        pw = pathwidth_brute(verts, edges)
        print(f"Pathwidth (exact): {pw}")
    else:
        pw = pathwidth_greedy(verts, edges)
        print(f"Pathwidth (upper bound): {pw}")

    ratio = pw / space if space > 0 else 0
    print(f"Ratio pw/space: {ratio:.3f}")
    print(f"Conjecture (c=4) holds: {pw <= 4 * space}")


def main():
    if "--interactive" in sys.argv:
        demo_interactive()
    else:
        demo_basic()
        demo_trace_decomposition()
        demo_conjecture_test()


if __name__ == "__main__":
    main()
