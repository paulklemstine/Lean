#!/usr/bin/env python3
"""
Pathwidth-Guided SAT Solving: Applications

Demonstrates real-world applications of pathwidth-guided clause retention:
1. Bounded model checking formulas
2. Graph coloring CNF encodings
3. Pigeonhole principle formulas
4. Memory profiling comparison
"""

import itertools
import time
from typing import List, Set, FrozenSet, Tuple, Dict
from collections import defaultdict

Literal = Tuple[str, bool]
Clause = FrozenSet[Literal]


# ============================================================
# Formula Generators
# ============================================================

def pigeonhole_cnf(n_pigeons: int, n_holes: int) -> List[Clause]:
    """Generate the pigeonhole principle formula PHP(n, m).

    Encodes: n pigeons cannot fit into m < n holes (one per hole).

    Variables: p_{i,j} = pigeon i is in hole j.
    Clauses:
      - At-least-one: each pigeon is in some hole
      - At-most-one: no two pigeons share a hole

    Args:
        n_pigeons: Number of pigeons.
        n_holes: Number of holes.

    Returns:
        List of clauses encoding PHP.
    """
    cnf = []
    # Each pigeon in at least one hole
    for i in range(n_pigeons):
        clause = frozenset({(f"p{i}h{j}", True) for j in range(n_holes)})
        cnf.append(clause)
    # No two pigeons in same hole
    for j in range(n_holes):
        for i1, i2 in itertools.combinations(range(n_pigeons), 2):
            cnf.append(frozenset({(f"p{i1}h{j}", False), (f"p{i2}h{j}", False)}))
    return cnf


def chain_formula(n: int) -> List[Clause]:
    """Generate a chain formula with linear clause interaction structure.

    Each clause shares one variable with its neighbor.

    Args:
        n: Number of clauses.

    Returns:
        Chain CNF formula.
    """
    return [frozenset({(f"x{i}", True), (f"x{i+1}", False)}) for i in range(n)]


def grid_formula(rows: int, cols: int) -> List[Clause]:
    """Generate a grid-structured formula.

    Variables at grid points; clauses connect horizontal and vertical neighbors.

    Args:
        rows: Number of rows.
        cols: Number of columns.

    Returns:
        Grid CNF formula.
    """
    cnf = []
    def var(r, c):
        return f"g{r}_{c}"

    # Horizontal clauses
    for r in range(rows):
        for c in range(cols - 1):
            cnf.append(frozenset({(var(r, c), True), (var(r, c+1), False)}))

    # Vertical clauses
    for r in range(rows - 1):
        for c in range(cols):
            cnf.append(frozenset({(var(r, c), True), (var(r+1, c), False)}))

    return cnf


def star_formula(n_arms: int) -> List[Clause]:
    """Generate a star formula where all clauses share a central variable.

    Args:
        n_arms: Number of arms (clauses).

    Returns:
        Star CNF formula.
    """
    return [frozenset({("center", True), (f"arm{i}", False)}) for i in range(n_arms)]


# ============================================================
# Analysis Engine (self-contained, not importing algorithms.py)
# ============================================================

def clause_vars(clause: Clause) -> Set[str]:
    return {lit[0] for lit in clause}


def build_adj(cnf: List[Clause]) -> Dict[int, Set[int]]:
    adj: Dict[int, Set[int]] = defaultdict(set)
    var_map: Dict[str, Set[int]] = defaultdict(set)
    for i, c in enumerate(cnf):
        for v in clause_vars(c):
            var_map[v].add(i)
    for clauses in var_map.values():
        for a, b in itertools.combinations(clauses, 2):
            adj[a].add(b)
            adj[b].add(a)
    for i in range(len(cnf)):
        if i not in adj:
            adj[i] = set()
    return dict(adj)


def greedy_decomp(adj: Dict[int, Set[int]]) -> List[Set[int]]:
    vertices = set(adj.keys())
    if not vertices:
        return [set()]
    adj_c = {v: set(adj[v]) for v in vertices}
    rem = set(vertices)
    order = []
    while rem:
        v = min(rem, key=lambda x: len(adj_c[x] & rem))
        order.append(v)
        rem.remove(v)
        nbrs = adj_c[v] & rem
        for a, b in itertools.combinations(nbrs, 2):
            adj_c[a].add(b)
            adj_c[b].add(a)
    bags = []
    for v in order:
        later = {u for u in adj_c[v] if order.index(u) > order.index(v)}
        bags.append({v} | later)
    return bags


def frontier(bags, cut, n):
    f = set()
    for v in range(n):
        idxs = [i for i, b in enumerate(bags) if v in b]
        if idxs and min(idxs) <= cut <= max(idxs):
            f.add(v)
    return f


def check_interval(bags, vertices):
    """Check interval property of decomposition."""
    for v in vertices:
        idxs = [i for i, b in enumerate(bags) if v in b]
        if idxs:
            lo, hi = min(idxs), max(idxs)
            for k in range(lo, hi + 1):
                if v not in bags[k]:
                    return False
    return True


def analyze(name: str, cnf: List[Clause]):
    """Full analysis of a CNF formula."""
    adj = build_adj(cnf)
    bags = greedy_decomp(adj)
    n = len(cnf)
    w = max(len(b) for b in bags) - 1 if bags else 0
    mfs = max(len(frontier(bags, i, n)) for i in range(len(bags))) if bags else 0
    n_edges = sum(len(v) for v in adj.values()) // 2
    valid_interval = check_interval(bags, range(n))

    return {
        "name": name,
        "clauses": n,
        "edges": n_edges,
        "width": w,
        "max_frontier": mfs,
        "bound_ok": mfs <= w + 1,
        "valid_pd": valid_interval,
        "bags": len(bags),
    }


# ============================================================
# Application 1: Structure Comparison
# ============================================================

def app_structure_comparison():
    """Compare pathwidth across different formula families."""
    print("=" * 75)
    print("APPLICATION 1: Structural Comparison of Formula Families")
    print("=" * 75)
    print()
    print("Different SAT formula families exhibit fundamentally different")
    print("clause interaction structures, reflected in their pathwidth.")
    print()

    results = []

    # Chains (low pathwidth)
    for n in [5, 10, 20, 40]:
        results.append(analyze(f"Chain-{n}", chain_formula(n)))

    # Stars (high pathwidth)
    for n in [5, 10, 20]:
        results.append(analyze(f"Star-{n}", star_formula(n)))

    # Grids (moderate pathwidth)
    for r, c in [(2, 5), (3, 4), (4, 4), (3, 6)]:
        results.append(analyze(f"Grid-{r}x{c}", grid_formula(r, c)))

    # Pigeonhole (high pathwidth)
    for p, h in [(3, 2), (4, 3), (5, 4)]:
        results.append(analyze(f"PHP({p},{h})", pigeonhole_cnf(p, h)))

    print(f"{'Formula':>15} {'Clauses':>8} {'Edges':>7} {'Width':>6} "
          f"{'MaxFront':>9} {'Valid PD':>9} {'Bound':>6}")
    print("-" * 65)
    for r in results:
        print(f"{r['name']:>15} {r['clauses']:>8} {r['edges']:>7} "
              f"{r['width']:>6} {r['max_frontier']:>9} "
              f"{'✓' if r['valid_pd'] else '✗':>9} "
              f"{'✓' if r['bound_ok'] else '(*)':>6}")

    print()
    print("Key observations:")
    print("  • Chain formulas have pathwidth 1 regardless of length")
    print("  • Star formulas have pathwidth growing linearly with arms")
    print("  • Grid formulas have pathwidth growing with the shorter dimension")
    print("  • Pigeonhole formulas are highly interconnected")
    print("  (*) = greedy heuristic violates interval property; bound only")
    print("        holds for valid path decompositions (as proved in Theorem 2)")
    print()


# ============================================================
# Application 2: Memory Savings
# ============================================================

def app_memory_savings():
    """Demonstrate memory savings from path-guided retention."""
    print("=" * 75)
    print("APPLICATION 2: Memory Savings from Path-Guided Retention")
    print("=" * 75)
    print()

    formulas = [
        ("Chain-20", chain_formula(20)),
        ("Chain-50", chain_formula(50)),
        ("Grid-3x5", grid_formula(3, 5)),
        ("Grid-4x4", grid_formula(4, 4)),
        ("Star-10", star_formula(10)),
        ("PHP(4,3)", pigeonhole_cnf(4, 3)),
    ]

    print(f"{'Formula':>15} {'Clauses':>8} {'Width':>6} {'Naive Mem':>10} "
          f"{'Guided Mem':>11} {'Savings':>8}")
    print("-" * 62)

    for name, cnf in formulas:
        adj = build_adj(cnf)
        bags = greedy_decomp(adj)
        n = len(cnf)
        w = max(len(b) for b in bags) - 1 if bags else 0

        naive_total = n * len(bags)
        guided_total = sum(
            len(bags[i] | frontier(bags, i, n)) for i in range(len(bags))
        )
        savings = (1 - guided_total / naive_total) * 100 if naive_total > 0 else 0

        print(f"{name:>15} {n:>8} {w:>6} {naive_total:>10} "
              f"{guided_total:>11} {savings:>7.1f}%")

    print()
    print("Memory savings are most dramatic for low-pathwidth formulas")
    print("(chains, sparse graphs) where the structure is nearly linear.")
    print()


# ============================================================
# Application 3: Dynamic Programming Locality
# ============================================================

def app_dp_locality():
    """Demonstrate the dynamic programming locality property."""
    print("=" * 75)
    print("APPLICATION 3: Dynamic Programming Locality")
    print("=" * 75)
    print()
    print("The cut locality theorem says that clause evaluation depends only")
    print("on variables in the current bag. This enables DP-like propagation.")
    print()

    cnf = chain_formula(6)
    adj = build_adj(cnf)
    bags = greedy_decomp(adj)
    n = len(cnf)

    print("Chain-6 formula:")
    for i, c in enumerate(cnf):
        lits = " ∨ ".join(f"{'¬' if not p else ''}{v}" for v, p in sorted(c))
        print(f"  C{i}: ({lits})")

    print("\nPath decomposition bags and their variables:")
    for i, b in enumerate(bags):
        all_vars = set()
        for ci in b:
            all_vars |= clause_vars(cnf[ci])
        front = frontier(bags, i, n)
        print(f"  Bag {i}: clauses={sorted(b)}, vars={sorted(all_vars)}, "
              f"frontier={sorted(front)}")

    print()
    print("At each bag, evaluation of frontier clauses depends ONLY on the")
    print("variables listed above. This is the bag locality theorem:")
    print("  agreesOn(σ, τ, bagVars(bag[i])) → clauseEval(σ, C) = clauseEval(τ, C)")
    print("for all C in activeFrontier(i).")
    print()
    print("This means the state that must be propagated through the decomposition")
    print("is bounded by 2^(width+1) partial assignments — enabling efficient DP.")

    for i, b in enumerate(bags):
        all_vars = set()
        for ci in b:
            all_vars |= clause_vars(cnf[ci])
        n_states = 2 ** len(all_vars)
        print(f"  Bag {i}: {len(all_vars)} vars → {n_states} states")

    print()


# ============================================================
# Application 4: Scalability Analysis
# ============================================================

def app_scalability():
    """Measure how pathwidth scales with formula size."""
    print("=" * 75)
    print("APPLICATION 4: Scalability Analysis")
    print("=" * 75)
    print()

    print("Chain formulas (expected: constant pathwidth)")
    print(f"{'n':>6} {'Width':>6} {'Time (ms)':>10}")
    print("-" * 25)
    for n in [10, 50, 100, 200, 500]:
        cnf = chain_formula(n)
        t0 = time.time()
        adj = build_adj(cnf)
        bags = greedy_decomp(adj)
        dt = (time.time() - t0) * 1000
        w = max(len(b) for b in bags) - 1 if bags else 0
        print(f"{n:>6} {w:>6} {dt:>10.1f}")

    print()
    print("Grid formulas (expected: pathwidth ~ min dimension)")
    print(f"{'Grid':>8} {'Clauses':>8} {'Width':>6} {'Time (ms)':>10}")
    print("-" * 35)
    for r, c in [(2, 10), (3, 10), (4, 10), (5, 10), (2, 20), (3, 20)]:
        cnf = grid_formula(r, c)
        t0 = time.time()
        adj = build_adj(cnf)
        bags = greedy_decomp(adj)
        dt = (time.time() - t0) * 1000
        w = max(len(b) for b in bags) - 1 if bags else 0
        print(f"{f'{r}x{c}':>8} {len(cnf):>8} {w:>6} {dt:>10.1f}")

    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════════╗")
    print("║   Pathwidth-Guided SAT Solving: Applications                           ║")
    print("╚══════════════════════════════════════════════════════════════════════════╝")
    print()

    app_structure_comparison()
    app_memory_savings()
    app_dp_locality()
    app_scalability()

    print("All applications complete.")


#!/usr/bin/env python3
"""
Pathwidth-Guided SAT Solving: Interactive Demonstration

This demo constructs small CNF formulas, builds their clause interaction graphs,
computes path decompositions, and visualizes how the active frontier size is
controlled by the bag width — illustrating the formally verified theorems.
"""

import itertools
from typing import List, Set, Tuple, Dict, Optional


# ============================================================
# Core Data Structures
# ============================================================

Literal = Tuple[str, bool]   # (variable_name, polarity)
Clause = frozenset            # frozenset of Literals
CNF = List[Clause]


def clause_vars(clause: Clause) -> Set[str]:
    """Variables appearing in a clause."""
    return {lit[0] for lit in clause}


def clauses_adjacent(c1: Clause, c2: Clause) -> bool:
    """Two clauses interact if they share a variable."""
    return bool(clause_vars(c1) & clause_vars(c2))


# ============================================================
# Clause Interaction Graph
# ============================================================

class ClauseInteractionGraph:
    """The clause interaction graph of a CNF formula."""

    def __init__(self, cnf: CNF):
        self.cnf = cnf
        self.vertices = list(range(len(cnf)))
        self.adj: Dict[int, Set[int]] = {i: set() for i in self.vertices}
        for i, j in itertools.combinations(self.vertices, 2):
            if clauses_adjacent(cnf[i], cnf[j]):
                self.adj[i].add(j)
                self.adj[j].add(i)

    def edges(self) -> List[Tuple[int, int]]:
        seen = set()
        result = []
        for u in self.vertices:
            for v in self.adj[u]:
                if (v, u) not in seen:
                    seen.add((u, v))
                    result.append((u, v))
        return result

    def display(self):
        print("Clause Interaction Graph:")
        print(f"  Vertices (clauses): {len(self.vertices)}")
        print(f"  Edges: {len(self.edges())}")
        for u, v in self.edges():
            shared = clause_vars(self.cnf[u]) & clause_vars(self.cnf[v])
            print(f"    C{u} -- C{v}  (shared vars: {shared})")


# ============================================================
# Path Decomposition
# ============================================================

class PathDecomposition:
    """A path decomposition: a list of bags (sets of vertex indices)."""

    def __init__(self, bags: List[Set[int]], graph: ClauseInteractionGraph):
        self.bags = bags
        self.graph = graph

    @property
    def width(self) -> int:
        if not self.bags:
            return 0
        return max(len(b) for b in self.bags) - 1

    @property
    def max_bag_size(self) -> int:
        if not self.bags:
            return 0
        return max(len(b) for b in self.bags)

    def verify(self) -> bool:
        """Check all three path decomposition axioms."""
        g = self.graph

        # 1. Vertex coverage
        all_verts = set()
        for b in self.bags:
            all_verts |= b
        for v in g.vertices:
            if g.adj[v] and v not in all_verts:
                print(f"  FAIL: vertex {v} not covered")
                return False

        # 2. Edge coverage
        for u, v in g.edges():
            if not any(u in b and v in b for b in self.bags):
                print(f"  FAIL: edge ({u},{v}) not covered")
                return False

        # 3. Running intersection (interval property)
        for v in g.vertices:
            indices = [i for i, b in enumerate(self.bags) if v in b]
            if indices:
                lo, hi = min(indices), max(indices)
                for k in range(lo, hi + 1):
                    if v not in self.bags[k]:
                        print(f"  FAIL: vertex {v} violates interval at bag {k}")
                        return False

        return True

    def active_frontier(self, cut: int) -> Set[int]:
        """Clauses whose bag-support spans position `cut`."""
        frontier = set()
        for v in self.graph.vertices:
            indices = [i for i, b in enumerate(self.bags) if v in b]
            if indices and min(indices) <= cut <= max(indices):
                frontier.add(v)
        return frontier

    def display(self):
        print("Path Decomposition:")
        print(f"  Width: {self.width}")
        for i, b in enumerate(self.bags):
            clauses_str = ", ".join(f"C{v}" for v in sorted(b))
            frontier = self.active_frontier(i)
            print(f"  Bag {i}: {{{clauses_str}}}  |  frontier size: {len(frontier)}")


# ============================================================
# Greedy Path Decomposition Construction
# ============================================================

def greedy_path_decomposition(graph: ClauseInteractionGraph) -> PathDecomposition:
    """Construct a path decomposition using a greedy minimum-degree ordering."""
    n = len(graph.vertices)
    if n == 0:
        return PathDecomposition([set()], graph)

    # Greedy elimination ordering
    remaining = set(graph.vertices)
    adj_copy = {v: set(graph.adj[v]) for v in graph.vertices}
    order = []

    while remaining:
        # Pick vertex with minimum degree among remaining
        v = min(remaining, key=lambda x: len(adj_copy[x] & remaining))
        order.append(v)
        remaining.remove(v)
        # Connect neighbors (fill-in)
        neighbors = adj_copy[v] & remaining
        for a, b in itertools.combinations(neighbors, 2):
            adj_copy[a].add(b)
            adj_copy[b].add(a)

    # Build bags from elimination ordering
    bags = []
    for v in order:
        later_neighbors = {u for u in adj_copy[v] if order.index(u) > order.index(v)}
        bag = {v} | later_neighbors
        bags.append(bag)

    return PathDecomposition(bags, graph)


# ============================================================
# Retain-at-Cut Policy
# ============================================================

def retain_at_cut(pd: PathDecomposition, cut: int, cnf: CNF) -> Set[int]:
    """The retained clause set at a given cut position."""
    bag = pd.bags[cut] if cut < len(pd.bags) else set()
    frontier = pd.active_frontier(cut)
    # retainAtCut = (bag ∩ F) ∪ activeFrontier
    # Since all vertices ARE clauses in F, bag ∩ F = bag
    return bag | frontier


# ============================================================
# Clause Evaluation
# ============================================================

def clause_eval(assignment: Dict[str, bool], clause: Clause) -> Optional[bool]:
    """Evaluate a clause under a partial assignment."""
    has_unknown = False
    for var, pol in clause:
        if var in assignment:
            if assignment[var] == pol:
                return True  # satisfied
        else:
            has_unknown = True
    if not has_unknown:
        return False  # all literals falsified
    return None  # undetermined


# ============================================================
# Demonstrations
# ============================================================

def demo_1_small_formula():
    """Demo 1: A small structured CNF formula."""
    print("=" * 70)
    print("DEMO 1: Small Structured CNF Formula")
    print("=" * 70)

    # A chain-like formula: each clause shares a variable with the next
    cnf = [
        frozenset({("x1", True), ("x2", False)}),    # C0
        frozenset({("x2", True), ("x3", True)}),      # C1
        frozenset({("x3", False), ("x4", True)}),     # C2
        frozenset({("x4", False), ("x5", True)}),     # C3
        frozenset({("x5", False), ("x6", True)}),     # C4
    ]

    print("\nFormula:")
    for i, c in enumerate(cnf):
        lits = " ∨ ".join(f"{'¬' if not p else ''}{v}" for v, p in sorted(c))
        print(f"  C{i}: ({lits})")

    graph = ClauseInteractionGraph(cnf)
    graph.display()

    pd = greedy_path_decomposition(graph)
    print(f"\nDecomposition valid: {pd.verify()}")
    pd.display()

    print("\n--- Theorem Illustration: Frontier Size ≤ Width + 1 ---")
    for i in range(len(pd.bags)):
        frontier = pd.active_frontier(i)
        print(f"  Cut {i}: frontier_size={len(frontier)} ≤ width+1={pd.width + 1}  ✓"
              if len(frontier) <= pd.width + 1 else
              f"  Cut {i}: VIOLATION!")

    print("\n--- Theorem Illustration: Separator Property ---")
    # Show that for each cut, clauses before and after can only interact through the bag
    for cut in range(len(pd.bags)):
        bag = pd.bags[cut]
        before = set()
        after = set()
        for v in graph.vertices:
            indices = [j for j, b in enumerate(pd.bags) if v in b]
            if indices and max(indices) < cut:
                before.add(v)
            elif indices and min(indices) > cut:
                after.add(v)
        # Check: any edge between before and after must have an endpoint in the bag
        for u in before:
            for v in after:
                if v in graph.adj[u]:
                    assert u in bag or v in bag, "Separator property violated!"
                    print(f"  Cut {cut}: C{u}--C{v} cross-cut, "
                          f"separated by bag {{{', '.join(f'C{x}' for x in sorted(bag))}}}")

    print()


def demo_2_dense_formula():
    """Demo 2: A denser formula showing higher pathwidth."""
    print("=" * 70)
    print("DEMO 2: Dense Formula (Higher Pathwidth)")
    print("=" * 70)

    # A formula where many clauses share variables
    cnf = [
        frozenset({("a", True), ("b", True), ("c", False)}),    # C0
        frozenset({("a", False), ("d", True)}),                   # C1
        frozenset({("b", True), ("d", False), ("e", True)}),     # C2
        frozenset({("c", True), ("e", False), ("f", True)}),     # C3
        frozenset({("d", True), ("f", False)}),                   # C4
        frozenset({("a", True), ("e", True), ("f", False)}),     # C5
    ]

    print("\nFormula:")
    for i, c in enumerate(cnf):
        lits = " ∨ ".join(f"{'¬' if not p else ''}{v}" for v, p in sorted(c))
        print(f"  C{i}: ({lits})")

    graph = ClauseInteractionGraph(cnf)
    graph.display()

    pd = greedy_path_decomposition(graph)
    print(f"\nDecomposition valid: {pd.verify()}")
    pd.display()

    # Compute max frontier
    max_front = max(len(pd.active_frontier(i)) for i in range(len(pd.bags)))
    print(f"\nMax frontier size: {max_front}")
    print(f"Width + 1: {pd.width + 1}")
    print(f"Theorem verified: max_frontier ≤ width + 1: {max_front <= pd.width + 1}  ✓")

    print()


def demo_3_bag_locality():
    """Demo 3: Bag locality of clause evaluation."""
    print("=" * 70)
    print("DEMO 3: Bag Locality of Clause Evaluation")
    print("=" * 70)

    cnf = [
        frozenset({("x", True), ("y", False)}),   # C0
        frozenset({("y", True), ("z", True)}),     # C1
        frozenset({("z", False), ("w", True)}),    # C2
    ]

    graph = ClauseInteractionGraph(cnf)
    pd = greedy_path_decomposition(graph)
    pd.display()

    print("\n--- Demonstrating clause evaluation locality ---")
    # Two assignments that agree on the variables of C0 = {x, y}
    sigma = {"x": True, "y": False, "z": True, "w": False}
    tau   = {"x": True, "y": False, "z": False, "w": True}

    c0 = cnf[0]
    vars_c0 = clause_vars(c0)
    print(f"\n  Clause C0 vars: {vars_c0}")
    sigma_c0 = {v: sigma[v] for v in vars_c0}
    tau_c0 = {v: tau[v] for v in vars_c0}
    print(f"  σ restricted to C0 vars: {sigma_c0}")
    print(f"  τ restricted to C0 vars: {tau_c0}")
    agree = all(sigma[v] == tau[v] for v in vars_c0)
    print(f"  σ and τ agree on C0 vars: {agree}")
    print(f"  clauseEval(σ, C0) = {clause_eval(sigma, c0)}")
    print(f"  clauseEval(τ, C0) = {clause_eval(tau, c0)}")
    print(f"  Equal (as theorem predicts): {clause_eval(sigma, c0) == clause_eval(tau, c0)}  ✓")

    # Different variable: C2 = {z, w} — assignments differ here
    c2 = cnf[2]
    vars_c2 = clause_vars(c2)
    print(f"\n  Clause C2 vars: {vars_c2}")
    sigma_c2 = {v: sigma[v] for v in vars_c2}
    tau_c2 = {v: tau[v] for v in vars_c2}
    print(f"  σ restricted to C2 vars: {sigma_c2}")
    print(f"  τ restricted to C2 vars: {tau_c2}")
    agree2 = all(sigma[v] == tau[v] for v in vars_c2)
    print(f"  σ and τ agree on C2 vars: {agree2}")
    print(f"  clauseEval(σ, C2) = {clause_eval(sigma, c2)}")
    print(f"  clauseEval(τ, C2) = {clause_eval(tau, c2)}")
    if agree2:
        print(f"  Equal (as theorem predicts): {clause_eval(sigma, c2) == clause_eval(tau, c2)}  ✓")
    else:
        print(f"  (Assignments differ on C2 vars — theorem does not apply)")

    print()


def demo_4_retention_comparison():
    """Demo 4: Compare path-respecting retention vs naive retention."""
    print("=" * 70)
    print("DEMO 4: Path-Respecting vs Naive Retention")
    print("=" * 70)

    # Longer chain formula
    n = 8
    cnf = []
    for i in range(n):
        cnf.append(frozenset({(f"x{i}", True), (f"x{i+1}", False)}))

    print(f"\nChain formula with {n} clauses")
    graph = ClauseInteractionGraph(cnf)
    pd = greedy_path_decomposition(graph)
    print(f"Decomposition valid: {pd.verify()}")
    print(f"Width: {pd.width}")
    pd.display()

    print("\n--- Retention Comparison ---")
    print(f"{'Cut':>4} {'Naive (all)':>12} {'Path-Guided':>12} {'Savings':>10}")
    print("-" * 42)
    total_naive = 0
    total_guided = 0
    for i in range(len(pd.bags)):
        naive_size = len(cnf)  # naive: keep everything
        guided = retain_at_cut(pd, i, cnf)
        guided_size = len(guided)
        savings = naive_size - guided_size
        total_naive += naive_size
        total_guided += guided_size
        print(f"{i:>4} {naive_size:>12} {guided_size:>12} {savings:>10}")

    print("-" * 42)
    print(f"{'Total':>4} {total_naive:>12} {total_guided:>12} "
          f"{total_naive - total_guided:>10}")
    pct = (1 - total_guided / total_naive) * 100 if total_naive > 0 else 0
    print(f"\nMemory reduction: {pct:.1f}%")

    print()


def demo_5_width_vs_memory():
    """Demo 5: How pathwidth predicts memory requirements."""
    print("=" * 70)
    print("DEMO 5: Pathwidth Predicts Memory Requirements")
    print("=" * 70)

    print(f"\n{'Structure':>15} {'Clauses':>8} {'PW':>4} {'Max Frontier':>13} "
          f"{'Width+1':>8} {'Bound OK':>9}")
    print("-" * 62)

    # Test various formula structures
    structures = [
        ("Chain-4", 4),
        ("Chain-8", 8),
        ("Chain-16", 16),
        ("Chain-32", 32),
    ]

    for name, n in structures:
        cnf = [frozenset({(f"x{i}", True), (f"x{i+1}", False)}) for i in range(n)]
        graph = ClauseInteractionGraph(cnf)
        pd = greedy_path_decomposition(graph)
        max_front = max(len(pd.active_frontier(i)) for i in range(len(pd.bags)))
        ok = max_front <= pd.width + 1
        print(f"{name:>15} {len(cnf):>8} {pd.width:>4} {max_front:>13} "
              f"{pd.width + 1:>8} {'✓' if ok else '✗':>9}")

    # Star-like formula (one central variable)
    for k in [4, 8, 12]:
        cnf = [frozenset({("center", True), (f"y{i}", False)}) for i in range(k)]
        graph = ClauseInteractionGraph(cnf)
        pd = greedy_path_decomposition(graph)
        max_front = max(len(pd.active_frontier(i)) for i in range(len(pd.bags)))
        ok = max_front <= pd.width + 1
        print(f"{f'Star-{k}':>15} {len(cnf):>8} {pd.width:>4} {max_front:>13} "
              f"{pd.width + 1:>8} {'✓' if ok else '✗':>9}")

    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Pathwidth-Guided SAT Solving: Structural Memory Theory Demo      ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_1_small_formula()
    demo_2_dense_formula()
    demo_3_bag_locality()
    demo_4_retention_comparison()
    demo_5_width_vs_memory()

    print("All demonstrations complete.")
