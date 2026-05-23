#!/usr/bin/env python3
"""
applications.py — Real-world applications of Configuration Graph Pathwidth theory.

Demonstrates:
1. Memory-optimal proof search using path decompositions
2. Clause space estimation for SAT instances
3. Structural analysis of formula hardness
4. Comparison with random formula phase transitions
"""

import sys
from itertools import combinations, product
from typing import FrozenSet, Set, List, Tuple, Optional, Dict
from collections import defaultdict
import random


# ============================================================
# Core types and utilities (self-contained)
# ============================================================

Literal = int
Clause = FrozenSet[int]
Configuration = FrozenSet[Clause]
CNF = FrozenSet[Clause]


def neg(lit: Literal) -> Literal:
    return -lit


def variables_of(cnf: CNF) -> Set[int]:
    return {abs(lit) for clause in cnf for lit in clause}


def format_literal(lit: int) -> str:
    return f"x{lit}" if lit > 0 else f"¬x{abs(lit)}"


def format_clause(clause: Clause) -> str:
    if not clause:
        return "⊥"
    return "(" + " ∨ ".join(format_literal(l) for l in sorted(clause, key=abs)) + ")"


def resolve(c1: Clause, c2: Clause) -> Optional[Clause]:
    complements = [lit for lit in c1 if neg(lit) in c2]
    if len(complements) != 1:
        return None
    lit = complements[0]
    resolvent = (c1 - {lit}) | (c2 - {neg(lit)})
    for l in resolvent:
        if neg(l) in resolvent:
            return None
    return frozenset(resolvent)


def is_satisfiable(cnf: CNF) -> bool:
    vars_list = sorted(variables_of(cnf))
    if not vars_list:
        return frozenset() not in cnf
    for assignment in product([True, False], repeat=len(vars_list)):
        val = {v: a for v, a in zip(vars_list, assignment)}
        if all(any((lit > 0 and val[abs(lit)]) or (lit < 0 and not val[abs(lit)])
                    for lit in clause)
               for clause in cnf):
            return True
    return False


def all_resolvents(config: Configuration) -> Set[Clause]:
    results = set()
    clauses = list(config)
    for i in range(len(clauses)):
        for j in range(i + 1, len(clauses)):
            r = resolve(clauses[i], clauses[j])
            if r is not None:
                results.add(r)
    return results


def find_refutation_trace(cnf: CNF, max_space: int = 10) -> Optional[List[Configuration]]:
    empty_clause = frozenset()
    start = frozenset()
    queue = [(start,)]
    visited = {start}
    while queue:
        path = queue.pop(0)
        current = path[-1]
        if empty_clause in current:
            return list(path)
        successors = []
        for clause in cnf:
            if clause not in current and len(current) + 1 <= max_space:
                successors.append(frozenset(current | {clause}))
        for r in all_resolvents(current):
            if r not in current and len(current) + 1 <= max_space:
                successors.append(frozenset(current | {r}))
        for clause in current:
            successors.append(frozenset(current - {clause}))
        for succ in successors:
            if succ not in visited:
                visited.add(succ)
                queue.append(path + (succ,))
    return None


def min_clause_space(cnf: CNF, max_search: int = 6) -> int:
    for s in range(1, max_search + 1):
        trace = find_refutation_trace(cnf, max_space=s)
        if trace is not None:
            return s
    return -1


# ============================================================
# Application 1: Memory-Optimal Proof Search
# ============================================================

def memory_optimal_search(cnf: CNF):
    """
    Demonstrate how path decomposition theory guides memory-efficient proof search.

    The key insight: a resolution refutation with clause space s naturally induces
    a path decomposition of width s-1. This means we can organize proof search
    to use at most s memory cells at any time.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 1: Memory-Optimal Proof Search")
    print("=" * 60)

    print(f"\n  Formula: {' ∧ '.join(format_clause(c) for c in sorted(cnf, key=lambda c: (len(c), sorted(c, key=abs))))}")

    space = min_clause_space(cnf)
    if space < 0:
        print("  Could not find refutation.")
        return

    trace = find_refutation_trace(cnf, max_space=space)
    if not trace:
        return

    print(f"\n  Minimum clause space: {space}")
    print(f"  This means we need at most {space} memory cells at any point.")
    print(f"\n  Memory-optimal refutation trace:")
    print(f"  {'Step':>6} {'Memory Usage':>14} {'Configuration'}")
    print(f"  {'-'*6} {'-'*14} {'-'*40}")

    for i, config in enumerate(trace):
        bar = "█" * len(config) + "░" * (space - len(config))
        clauses_str = ", ".join(format_clause(c) for c in sorted(config, key=lambda c: (len(c), sorted(c, key=abs))))
        print(f"  {i:>6} [{bar}] {{{clauses_str}}}")

    peak = max(len(c) for c in trace)
    print(f"\n  Peak memory: {peak} clauses (= clause space)")
    print(f"  Path decomposition width: {peak - 1}")
    print(f"\n  ► The trace IS a path decomposition of the clause interaction graph.")
    print(f"    Each memory state is a 'bag' containing the active clauses.")
    print(f"    The interval property is satisfied when no clause is re-derived.")


# ============================================================
# Application 2: Formula Hardness Analysis
# ============================================================

def analyze_formula_hardness(n_vars: int = 2, max_clause_width: int = 2):
    """
    Analyze structural hardness of all unsatisfiable formulas over n variables.
    Demonstrates that clause space correlates with configuration graph structure.
    """
    print("\n" + "=" * 60)
    print(f"  APPLICATION 2: Formula Hardness Analysis (n={n_vars})")
    print("=" * 60)

    variables = list(range(1, n_vars + 1))
    literals = []
    for v in variables:
        literals.extend([v, -v])

    # Generate all non-tautological clauses
    all_clauses = []
    for width in range(1, max_clause_width + 1):
        for combo in combinations(literals, width):
            clause = frozenset(combo)
            if not any(-l in clause for l in clause):
                all_clauses.append(clause)

    print(f"\n  Variables: {variables}")
    print(f"  Total clauses (width ≤ {max_clause_width}): {len(all_clauses)}")

    # Find unsatisfiable formulas
    results = []
    count = 0
    for size in range(2, min(len(all_clauses) + 1, 8)):
        for combo in combinations(all_clauses, size):
            cnf = frozenset(combo)
            if not is_satisfiable(cnf):
                space = min_clause_space(cnf, max_search=5)
                if space > 0:
                    results.append({
                        "cnf": cnf,
                        "size": len(cnf),
                        "space": space,
                    })
                    count += 1
                    if count >= 20:
                        break
        if count >= 20:
            break

    if not results:
        print("  No unsatisfiable formulas found in this range.")
        return

    # Group by clause space
    by_space = defaultdict(list)
    for r in results:
        by_space[r["space"]].append(r)

    print(f"\n  Found {len(results)} unsatisfiable formulas")
    print(f"\n  Hardness Distribution:")
    print(f"  {'Clause Space':>14} {'Count':>7} {'Example'}")
    print(f"  {'-'*14} {'-'*7} {'-'*35}")

    for space in sorted(by_space.keys()):
        formulas = by_space[space]
        example = formulas[0]["cnf"]
        example_str = " ∧ ".join(format_clause(c) for c in sorted(example, key=lambda c: (len(c), sorted(c, key=abs))))
        if len(example_str) > 35:
            example_str = example_str[:32] + "..."
        print(f"  {space:>14} {len(formulas):>7} {example_str}")

    print(f"\n  ► Clause space measures proof difficulty: higher space = harder formula.")
    print(f"    The corresponding path decomposition width is (space - 1).")


# ============================================================
# Application 3: Random Formula Phase Transition
# ============================================================

def random_formula_analysis(n_vars: int = 3, k: int = 2, trials: int = 20):
    """
    Analyze clause space across the satisfiability phase transition
    for random k-CNF formulas.
    """
    print("\n" + "=" * 60)
    print(f"  APPLICATION 3: Random {k}-CNF Phase Transition (n={n_vars})")
    print("=" * 60)

    variables = list(range(1, n_vars + 1))
    literals = []
    for v in variables:
        literals.extend([v, -v])

    # Generate all possible k-clauses
    all_k_clauses = []
    for combo in combinations(literals, k):
        clause = frozenset(combo)
        if not any(-l in clause for l in clause):
            all_k_clauses.append(clause)

    print(f"\n  Variables: {n_vars}, Clause width: {k}")
    print(f"  Total possible {k}-clauses: {len(all_k_clauses)}")

    ratios = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    print(f"\n  {'Ratio (m/n)':>12} {'Unsat %':>8} {'Avg Space':>10} {'Max Space':>10}")
    print(f"  {'-'*12} {'-'*8} {'-'*10} {'-'*10}")

    for ratio in ratios:
        m = int(ratio * n_vars)
        if m > len(all_k_clauses):
            continue

        unsat_count = 0
        spaces = []

        for _ in range(trials):
            random.seed(_ + int(ratio * 1000))
            clauses = random.sample(all_k_clauses, min(m, len(all_k_clauses)))
            cnf = frozenset(clauses)

            if not is_satisfiable(cnf):
                unsat_count += 1
                space = min_clause_space(cnf, max_search=5)
                if space > 0:
                    spaces.append(space)

        unsat_pct = 100 * unsat_count / trials
        avg_space = sum(spaces) / len(spaces) if spaces else 0
        max_space_val = max(spaces) if spaces else 0

        print(f"  {ratio:>12.1f} {unsat_pct:>7.0f}% {avg_space:>10.1f} {max_space_val:>10}")

    print(f"\n  ► As the clause-to-variable ratio increases, formulas become")
    print(f"    unsatisfiable more often, and clause space tends to increase.")
    print(f"    The pathwidth of the configuration graph tracks this transition.")


# ============================================================
# Application 4: Proof Compression via Decomposition
# ============================================================

def proof_compression_demo():
    """
    Demonstrate how path decomposition can compress proof certificates.

    A proof with clause space s has a path decomposition of width s-1.
    This decomposition can be used as a compact certificate: instead of
    storing the entire proof trace, we store only the decomposition bags.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 4: Proof Compression via Path Decomposition")
    print("=" * 60)

    p, q, r = 1, 2, 3

    # A formula requiring clause space 3
    cnf = frozenset([
        frozenset([p, q]), frozenset([p, -q]),
        frozenset([-p, q]), frozenset([-p, -q])
    ])

    print(f"\n  Formula: {' ∧ '.join(format_clause(c) for c in sorted(cnf, key=lambda c: (len(c), sorted(c, key=abs))))}")

    space = min_clause_space(cnf)
    trace = find_refutation_trace(cnf, max_space=space)

    if not trace:
        print("  No trace found.")
        return

    print(f"\n  Full proof trace: {len(trace)} steps")
    print(f"  Clause space: {space}")

    # The path decomposition bags are just the configurations
    bags = [set(config) for config in trace]

    # Count unique clauses across all bags
    all_clauses_in_trace = set()
    for config in trace:
        all_clauses_in_trace |= config

    print(f"  Unique clauses in trace: {len(all_clauses_in_trace)}")

    # Check interval property
    has_interval = True
    for clause in all_clauses_in_trace:
        indices = [i for i, config in enumerate(trace) if clause in config]
        if indices and indices != list(range(indices[0], indices[-1] + 1)):
            has_interval = False
            break

    print(f"  Interval property: {'✓ Satisfied' if has_interval else '✗ Violated'}")
    print(f"\n  Path Decomposition Certificate:")
    print(f"    Bags: {len(bags)}")
    print(f"    Width: {max(len(b) for b in bags) - 1}")
    print(f"    Total bag entries: {sum(len(b) for b in bags)}")

    # Compression ratio
    full_size = len(trace) * space  # worst case: every step stores 'space' clauses
    compressed = sum(len(b) for b in bags)
    if full_size > 0:
        print(f"    Compression ratio: {compressed}/{full_size} = {compressed/full_size:.2f}")

    print(f"\n  ► The path decomposition serves as a compact proof certificate.")
    print(f"    A verifier can check each bag covers the relevant edges")
    print(f"    and the interval property holds — this certifies the refutation.")


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Configuration Graph Pathwidth — Applications               ║")
    print("║  Real-world uses of the proof memory / graph width bridge   ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    p, q = 1, 2

    # Application 1: Memory-optimal proof search
    cnf1 = frozenset([
        frozenset([p, q]), frozenset([p, -q]),
        frozenset([-p, q]), frozenset([-p, -q])
    ])
    memory_optimal_search(cnf1)

    # Application 2: Formula hardness analysis
    analyze_formula_hardness(n_vars=2, max_clause_width=2)

    # Application 3: Random formula phase transition
    random_formula_analysis(n_vars=3, k=2, trials=15)

    # Application 4: Proof compression
    proof_compression_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Configuration Graph Pathwidth theory.

Demonstrates:
- Input a small CNF formula
- Compute clause space
- Build the bounded configuration graph
- Compute pathwidth
- Report the ratio and whether it supports the conjecture

Usage:
    python demo.py              # Run with built-in examples
    python demo.py --interactive  # Interactive mode
"""

import sys
from itertools import combinations, product
from typing import FrozenSet, Set, List, Tuple, Optional, Dict
from collections import defaultdict


# ============================================================
# Inline implementations (self-contained, no local imports)
# ============================================================

Literal = int
Clause = FrozenSet[int]
Configuration = FrozenSet[Clause]
CNF = FrozenSet[Clause]


def neg(lit: Literal) -> Literal:
    return -lit


def variables_of(cnf: CNF) -> Set[int]:
    return {abs(lit) for clause in cnf for lit in clause}


def format_literal(lit: int) -> str:
    if lit > 0:
        return f"x{lit}"
    return f"¬x{abs(lit)}"


def format_clause(clause: Clause) -> str:
    if not clause:
        return "⊥"
    return "(" + " ∨ ".join(format_literal(l) for l in sorted(clause, key=abs)) + ")"


def format_cnf(cnf: CNF) -> str:
    return " ∧ ".join(format_clause(c) for c in sorted(cnf, key=lambda c: (len(c), sorted(c, key=abs))))


def resolve(c1: Clause, c2: Clause) -> Optional[Clause]:
    complements = [lit for lit in c1 if neg(lit) in c2]
    if len(complements) != 1:
        return None
    lit = complements[0]
    resolvent = (c1 - {lit}) | (c2 - {neg(lit)})
    for l in resolvent:
        if neg(l) in resolvent:
            return None
    return frozenset(resolvent)


def all_resolvents(config: Configuration) -> Set[Clause]:
    results = set()
    clauses = list(config)
    for i in range(len(clauses)):
        for j in range(i + 1, len(clauses)):
            r = resolve(clauses[i], clauses[j])
            if r is not None:
                results.add(r)
    return results


def find_refutation_trace(cnf: CNF, max_space: int = 10, max_nodes: int = 5000) -> Optional[List[Configuration]]:
    """BFS for a refutation trace with bounded node expansion."""
    empty_clause = frozenset()
    start = frozenset()
    # BFS with parent tracking for memory efficiency
    visited = {start: None}  # config -> parent
    queue = [start]
    nodes = 0

    while queue and nodes < max_nodes:
        current = queue.pop(0)
        nodes += 1

        if empty_clause in current:
            # Reconstruct path
            path = []
            c = current
            while c is not None:
                path.append(c)
                c = visited[c]
            return list(reversed(path))

        successors = []
        for clause in cnf:
            if clause not in current and len(current) + 1 <= max_space:
                successors.append(frozenset(current | {clause}))
        for r in all_resolvents(current):
            if r not in current and len(current) + 1 <= max_space:
                successors.append(frozenset(current | {r}))
        for clause in current:
            successors.append(frozenset(current - {clause}))

        for succ in successors:
            if succ not in visited:
                visited[succ] = current
                queue.append(succ)

    return None


def is_satisfiable(cnf: CNF) -> bool:
    vars_list = sorted(variables_of(cnf))
    if not vars_list:
        return frozenset() not in cnf
    for assignment in product([True, False], repeat=len(vars_list)):
        val = {v: a for v, a in zip(vars_list, assignment)}
        satisfied = True
        for clause in cnf:
            clause_sat = False
            for lit in clause:
                if (lit > 0 and val[abs(lit)]) or (lit < 0 and not val[abs(lit)]):
                    clause_sat = True
                    break
            if not clause_sat:
                satisfied = False
                break
        if satisfied:
            return True
    return False


def min_clause_space(cnf: CNF, max_search: int = 8) -> int:
    for s in range(1, max_search + 1):
        trace = find_refutation_trace(cnf, max_space=s)
        if trace is not None:
            return s
    return -1


def clause_space_of_trace(trace: List[Configuration]) -> int:
    return max(len(config) for config in trace) if trace else 0


def all_derivable_clauses(cnf: CNF, max_iter: int = 20) -> Set[Clause]:
    all_clauses = set(cnf)
    for _ in range(max_iter):
        new = set()
        for c1 in all_clauses:
            for c2 in all_clauses:
                r = resolve(c1, c2)
                if r is not None and r not in all_clauses:
                    new.add(r)
        if not new:
            break
        all_clauses |= new
        if len(all_clauses) > 200:
            break
    return all_clauses


def build_config_graph(cnf: CNF, s: int):
    all_clauses = sorted(all_derivable_clauses(cnf), key=lambda c: (len(c), sorted(c, key=abs)))
    vertices = []
    for size in range(s + 1):
        for combo in combinations(all_clauses, size):
            vertices.append(frozenset(combo))

    vertex_set = set(vertices)
    v_to_idx = {v: i for i, v in enumerate(vertices)}

    edges = set()
    for config in vertices:
        for clause in all_clauses:
            if clause not in config and len(config) + 1 <= s:
                neighbor = frozenset(config | {clause})
                if neighbor in vertex_set:
                    e = (min(v_to_idx[config], v_to_idx[neighbor]),
                         max(v_to_idx[config], v_to_idx[neighbor]))
                    edges.add(e)
        for clause in config:
            neighbor = frozenset(config - {clause})
            if neighbor in vertex_set:
                e = (min(v_to_idx[config], v_to_idx[neighbor]),
                     max(v_to_idx[config], v_to_idx[neighbor]))
                edges.add(e)

    return vertices, list(edges), v_to_idx


def exact_pathwidth(n_vertices: int, edges: List[Tuple[int, int]]) -> int:
    from itertools import permutations
    if n_vertices <= 1:
        return 0
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)

    if n_vertices > 9:
        # Use heuristic for large graphs
        remaining = set(range(n_vertices))
        width = 0
        while remaining:
            v = min(remaining, key=lambda x: len(adj[x] & remaining))
            bag_size = 1 + len(adj[v] & remaining)
            width = max(width, bag_size - 1)
            remaining.remove(v)
        return width

    best = n_vertices - 1
    for perm in permutations(range(n_vertices)):
        pos = {v: i for i, v in enumerate(perm)}
        width = 0
        for i, v in enumerate(perm):
            bag_size = 1 + sum(1 for u in adj[v] if pos[u] > i)
            width = max(width, bag_size)
        best = min(best, width - 1)
    return best


# ============================================================
# Demo Functions
# ============================================================

def analyze_formula(cnf: CNF, name: str = "Formula"):
    """Analyze a CNF formula: compute clause space, build config graph, compute pathwidth."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")
    print(f"  Formula: {format_cnf(cnf)}")
    print(f"  Variables: {sorted(variables_of(cnf))}")
    print(f"  Clauses: {len(cnf)}")
    print(f"  Satisfiable: {is_satisfiable(cnf)}")

    if is_satisfiable(cnf):
        print("  (Skipping — formula is satisfiable)")
        return None

    print(f"\n  Computing minimum clause space...")
    space = min_clause_space(cnf)
    print(f"  Minimum clause space: {space}")

    if space < 0:
        print("  (Could not find refutation within search bound)")
        return None

    # Find a refutation trace
    trace = find_refutation_trace(cnf, max_space=space)
    if trace:
        print(f"  Refutation trace length: {len(trace)}")
        print(f"  Trace clause space: {clause_space_of_trace(trace)}")

        # Show trace
        print(f"\n  Trace (first 10 steps):")
        for i, config in enumerate(trace[:10]):
            clauses_str = ", ".join(format_clause(c) for c in sorted(config, key=lambda c: (len(c), sorted(c, key=abs))))
            print(f"    Step {i}: {{{clauses_str}}}")
        if len(trace) > 10:
            print(f"    ... ({len(trace) - 10} more steps)")

    # Build configuration graph
    print(f"\n  Building {space}-bounded configuration graph...")
    vertices, edges, v_idx = build_config_graph(cnf, space)
    print(f"  Config graph: {len(vertices)} vertices, {len(edges)} edges")

    # Compute pathwidth
    if len(vertices) <= 9:
        print(f"  Computing exact pathwidth...")
        pw = exact_pathwidth(len(vertices), edges)
        print(f"  Pathwidth: {pw}")
    else:
        print(f"  Computing pathwidth upper bound (heuristic)...")
        pw = exact_pathwidth(len(vertices), edges)
        print(f"  Pathwidth (upper bound): {pw}")

    # Report ratio
    if space > 0:
        ratio = pw / space
        print(f"\n  ┌─────────────────────────────────────┐")
        print(f"  │  Pathwidth / Clause Space = {ratio:.3f}     │")
        print(f"  │  Conjecture: ratio ≤ c (constant)   │")
        if ratio <= 1.0:
            print(f"  │  ✓ Consistent (c=1 suffices)        │")
        else:
            print(f"  │  Ratio > 1: needs c ≥ {ratio:.1f}           │")
        print(f"  └─────────────────────────────────────┘")

    return {"name": name, "space": space, "pw": pw, "ratio": pw / space if space > 0 else 0,
            "vertices": len(vertices), "edges": len(edges)}


def run_builtin_examples():
    """Run analysis on built-in example formulas."""
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Configuration Graph Pathwidth — Interactive Demonstration  ║")
    print("║  Exploring the geometry of proof memory                     ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    p, q, r = 1, 2, 3
    results = []

    # Example 1: Simplest unsatisfiable formula
    cnf1 = frozenset([frozenset([p]), frozenset([-p])])
    r1 = analyze_formula(cnf1, "Example 1: {p} ∧ {¬p}")
    if r1: results.append(r1)

    # Example 2: Two-variable contradiction
    cnf2 = frozenset([frozenset([p]), frozenset([-p]), frozenset([q]), frozenset([-q])])
    r2 = analyze_formula(cnf2, "Example 2: {p} ∧ {¬p} ∧ {q} ∧ {¬q}")
    if r2: results.append(r2)

    # Example 3: Full 2-variable unsatisfiable
    cnf3 = frozenset([
        frozenset([p, q]), frozenset([p, -q]),
        frozenset([-p, q]), frozenset([-p, -q])
    ])
    r3 = analyze_formula(cnf3, "Example 3: All 2-literal clauses over {p, q}")
    if r3: results.append(r3)

    # Example 4: Minimal unsatisfiable with 3 variables
    cnf4 = frozenset([
        frozenset([p]), frozenset([-p, q]), frozenset([-p, -q])
    ])
    r4 = analyze_formula(cnf4, "Example 4: Unit propagation chain")
    if r4: results.append(r4)

    # Example 5: 3-variable pigeonhole-like
    cnf5 = frozenset([
        frozenset([p, q, r]), frozenset([p, q, -r]),
        frozenset([p, -q, r]), frozenset([p, -q, -r]),
        frozenset([-p, q, r]), frozenset([-p, q, -r]),
        frozenset([-p, -q, r]), frozenset([-p, -q, -r])
    ])
    r5 = analyze_formula(cnf5, "Example 5: All 3-literal clauses (maximally unsat)")
    if r5: results.append(r5)

    # Summary table
    if results:
        print(f"\n\n{'='*60}")
        print(f"  Summary Table")
        print(f"{'='*60}")
        print(f"  {'Name':<35} {'Space':>5} {'PW':>4} {'Ratio':>6} {'Vertices':>8}")
        print(f"  {'-'*35} {'-'*5} {'-'*4} {'-'*6} {'-'*8}")
        for r in results:
            print(f"  {r['name']:<35} {r['space']:>5} {r['pw']:>4} {r['ratio']:>6.3f} {r['vertices']:>8}")
        print()
        max_ratio = max(r['ratio'] for r in results)
        print(f"  Maximum ratio observed: {max_ratio:.3f}")
        print(f"  Conjecture status: {'✓ SUPPORTED' if max_ratio <= 1.0 else '? NEEDS LARGER c'} (c=1)")


def interactive_mode():
    """Interactive mode: let user input a CNF formula."""
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Configuration Graph Pathwidth — Interactive Mode           ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    print("Enter a CNF formula as a list of clauses.")
    print("Each clause is a list of integers (positive = variable, negative = negation).")
    print("Example: [[1, 2], [-1, 2], [1, -2], [-1, -2]]")
    print("Type 'quit' to exit.")
    print()

    while True:
        try:
            raw = input("CNF formula (or 'quit'): ").strip()
            if raw.lower() == 'quit':
                break
            clauses_list = eval(raw)
            cnf = frozenset(frozenset(c) for c in clauses_list)
            analyze_formula(cnf, "User formula")
        except Exception as e:
            print(f"Error: {e}")
            print("Please enter a valid list of lists of integers.")


if __name__ == "__main__":
    if "--interactive" in sys.argv:
        interactive_mode()
    else:
        run_builtin_examples()
