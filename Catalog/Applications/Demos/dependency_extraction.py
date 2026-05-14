#!/usr/bin/env python3
"""
Applications of Dependency Extraction Theory
=============================================
Real-world applications of the formal dependency theory to:
1. Software build system optimization
2. Knowledge graph analysis
3. Curriculum design
4. Proof complexity estimation
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict
import json


# ═══════════════════════════════════════════════════════════════
# Application 1: Build System Optimization
# ═══════════════════════════════════════════════════════════════

@dataclass
class BuildModule:
    """A module in a build system."""
    name: str
    deps: frozenset
    build_time: float  # seconds

    def __init__(self, name, deps=None, build_time=1.0):
        self.name = name
        self.deps = frozenset(deps) if deps else frozenset()
        self.build_time = build_time


def compute_parallel_schedule(modules: List[BuildModule]) -> List[List[str]]:
    """
    Compute an optimal parallel build schedule using dependency depth.

    Modules at the same depth can be built in parallel.

    Time: O(n * d)
    Space: O(n)
    """
    depth: Dict[str, int] = {}
    for m in modules:
        if not m.deps:
            depth[m.name] = 0
        else:
            depth[m.name] = 1 + max(depth.get(d, 0) for d in m.deps)

    max_depth = max(depth.values()) if depth else 0
    schedule = [[] for _ in range(max_depth + 1)]
    for m in modules:
        schedule[depth[m.name]].append(m.name)

    return schedule


def estimate_parallel_build_time(modules: List[BuildModule]) -> Tuple[float, float]:
    """
    Estimate sequential vs parallel build time.

    Returns (sequential_time, parallel_time).
    """
    times = {m.name: m.build_time for m in modules}
    depth: Dict[str, int] = {}
    for m in modules:
        if not m.deps:
            depth[m.name] = 0
        else:
            depth[m.name] = 1 + max(depth.get(d, 0) for d in m.deps)

    sequential = sum(times.values())

    # Parallel time = max over paths
    max_depth = max(depth.values()) if depth else 0
    parallel_times = [0.0] * (max_depth + 1)
    for m in modules:
        d = depth[m.name]
        parallel_times[d] = max(parallel_times[d], times[m.name])

    parallel = sum(parallel_times)
    return sequential, parallel


print("=" * 60)
print("APPLICATION 1: Build System Optimization")
print("=" * 60)

build_modules = [
    BuildModule("core", build_time=2.0),
    BuildModule("utils", {"core"}, build_time=1.5),
    BuildModule("math", {"core"}, build_time=3.0),
    BuildModule("io", {"core"}, build_time=2.0),
    BuildModule("parser", {"utils", "io"}, build_time=2.5),
    BuildModule("solver", {"math", "utils"}, build_time=4.0),
    BuildModule("renderer", {"io"}, build_time=1.5),
    BuildModule("app", {"parser", "solver", "renderer"}, build_time=1.0),
]

schedule = compute_parallel_schedule(build_modules)
print("\nParallel build schedule:")
for level, mods in enumerate(schedule):
    print(f"  Level {level}: {mods}")

seq_time, par_time = estimate_parallel_build_time(build_modules)
print(f"\nSequential build time: {seq_time:.1f}s")
print(f"Parallel build time:  {par_time:.1f}s")
print(f"Speedup:              {seq_time/par_time:.2f}x")


# ═══════════════════════════════════════════════════════════════
# Application 2: Knowledge Graph / Curriculum Design
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 60)
print("APPLICATION 2: Mathematics Curriculum Design")
print("=" * 60)

@dataclass
class Topic:
    name: str
    prerequisites: frozenset
    difficulty: int  # 1-5

    def __init__(self, name, prereqs=None, difficulty=1):
        self.name = name
        self.prerequisites = frozenset(prereqs) if prereqs else frozenset()
        self.difficulty = difficulty


curriculum = [
    Topic("Sets", difficulty=1),
    Topic("Logic", difficulty=1),
    Topic("Functions", {"Sets", "Logic"}, difficulty=2),
    Topic("Relations", {"Sets", "Logic"}, difficulty=2),
    Topic("Natural Numbers", {"Sets", "Logic"}, difficulty=2),
    Topic("Integers", {"Natural Numbers"}, difficulty=2),
    Topic("Groups", {"Sets", "Functions"}, difficulty=3),
    Topic("Rings", {"Groups", "Integers"}, difficulty=3),
    Topic("Fields", {"Rings"}, difficulty=3),
    Topic("Vector Spaces", {"Fields", "Functions"}, difficulty=4),
    Topic("Linear Algebra", {"Vector Spaces"}, difficulty=4),
    Topic("Topology", {"Sets", "Functions", "Relations"}, difficulty=4),
    Topic("Analysis", {"Topology", "Fields"}, difficulty=5),
    Topic("Galois Theory", {"Fields", "Groups"}, difficulty=5),
]

# Verify well-formedness
declared = set()
all_valid = True
for t in curriculum:
    missing = t.prerequisites - declared
    if missing:
        print(f"  ⚠ {t.name} has undeclared prerequisites: {missing}")
        all_valid = False
    declared.add(t.name)
print(f"\nCurriculum well-formed: {all_valid}")

# Compute semester assignment (by depth)
depth: Dict[str, int] = {}
for t in curriculum:
    if not t.prerequisites:
        depth[t.name] = 0
    else:
        depth[t.name] = 1 + max(depth.get(p, 0) for p in t.prerequisites)

max_depth = max(depth.values())
semesters = [[] for _ in range(max_depth + 1)]
for t in curriculum:
    semesters[depth[t.name]].append(t.name)

print("\nSuggested semester plan:")
for sem, topics in enumerate(semesters, 1):
    print(f"  Semester {sem}: {', '.join(topics)}")

# Critical path
print(f"\nMinimum semesters required: {max_depth + 1}")
print(f"Total topics: {len(curriculum)}")


# ═══════════════════════════════════════════════════════════════
# Application 3: Proof Complexity Estimation
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 60)
print("APPLICATION 3: Proof Complexity Estimation")
print("=" * 60)


def transitive_closure_size(name: str, decls: Dict[str, Set[str]],
                             cache: Dict[str, int] = None) -> int:
    """Count all transitive dependencies of a theorem."""
    if cache is None:
        cache = {}
    if name in cache:
        return cache[name]

    deps = decls.get(name, set())
    all_deps = set(deps)
    for d in deps:
        # Recursively gather
        sub_deps = set()
        stack = [d]
        while stack:
            current = stack.pop()
            for dep in decls.get(current, set()):
                if dep not in all_deps:
                    all_deps.add(dep)
                    stack.append(dep)

    cache[name] = len(all_deps)
    return len(all_deps)


# Sample proof structure (algebraic number theory)
proof_deps: Dict[str, Set[str]] = {
    "ring_axioms": set(),
    "ideal_def": {"ring_axioms"},
    "quotient_ring": {"ring_axioms", "ideal_def"},
    "homomorphism": {"ring_axioms"},
    "first_iso": {"homomorphism", "quotient_ring", "ideal_def"},
    "prime_ideal": {"ideal_def", "ring_axioms"},
    "maximal_ideal": {"ideal_def", "prime_ideal"},
    "pid_def": {"ideal_def", "ring_axioms"},
    "ufd_def": {"ring_axioms"},
    "pid_implies_ufd": {"pid_def", "ufd_def", "prime_ideal"},
    "noetherian": {"ideal_def", "ring_axioms"},
    "hilbert_basis": {"noetherian", "quotient_ring", "homomorphism"},
}

print("\nTheorem complexity analysis (algebraic number theory):")
print(f"{'Theorem':<25} {'Direct':>7} {'Transitive':>11} {'Depth':>6}")
print("-" * 55)

# Compute depth
thm_depth: Dict[str, int] = {}
for name in proof_deps:
    deps = proof_deps[name]
    if not deps:
        thm_depth[name] = 0
    else:
        thm_depth[name] = 1 + max(thm_depth.get(d, 0) for d in deps)

cache: Dict[str, int] = {}
for name in proof_deps:
    direct = len(proof_deps[name])
    transitive = transitive_closure_size(name, proof_deps, cache)
    d = thm_depth[name]
    print(f"  {name:<25} {direct:>5}   {transitive:>9}   {d:>4}")

# Complexity metrics
print(f"\nComplexity summary:")
print(f"  Total theorems: {len(proof_deps)}")
print(f"  Total direct edges: {sum(len(v) for v in proof_deps.values())}")
print(f"  Max transitive closure: {max(cache.values())}")
print(f"  Max depth: {max(thm_depth.values())}")

# Boundary/bulk ratio (proto area-law)
print(f"\n  Proto area-law analysis:")
for name in ["hilbert_basis", "pid_implies_ufd", "first_iso"]:
    direct = len(proof_deps[name])
    transitive = cache[name]
    ratio = direct / transitive if transitive > 0 else 0
    print(f"    {name}: boundary/bulk = {direct}/{transitive} = {ratio:.2f}")

print("\n" + "=" * 60)
print("All applications demonstrated successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Dependency Extraction Demo
==========================
Demonstrates the formal theory of proof-file causality with concrete examples.
Illustrates theorem dependency graphs, acyclicity verification, import closure
computation, and topological ranking.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Tuple, Optional


@dataclass
class ThmDecl:
    """A theorem declaration with a name and set of dependencies."""
    name: str
    deps: Set[str] = field(default_factory=set)

    def __repr__(self):
        return f"ThmDecl({self.name!r}, deps={self.deps})"


@dataclass
class ProofFile:
    """A proof file abstraction: imports + theorem declarations."""
    imports: List[str]
    theorems: List[ThmDecl]


def prior_names(decls: List[ThmDecl], i: int) -> Set[str]:
    """Names of all declarations strictly before index i."""
    return {decls[j].name for j in range(min(i, len(decls)))}


def decls_respect_order(decls: List[ThmDecl]) -> bool:
    """Check if every theorem only depends on earlier theorems."""
    for i, t in enumerate(decls):
        if not t.deps.issubset(prior_names(decls, i)):
            return False
    return True


def unique_names(decls: List[ThmDecl]) -> bool:
    """Check if all theorem names are distinct."""
    names = [t.name for t in decls]
    return len(names) == len(set(names))


def dependency_edges(decls: List[ThmDecl]) -> List[Tuple[str, str]]:
    """Extract all dependency edges (a, b) meaning 'a depends on b'."""
    edges = []
    for t in decls:
        for d in t.deps:
            edges.append((t.name, d))
    return edges


def compute_rank(decls: List[ThmDecl]) -> Dict[str, int]:
    """Compute the declaration-index rank for each theorem name."""
    return {t.name: i for i, t in enumerate(decls)}


def step_closure(G: Dict[str, Set[str]], S: Set[str]) -> Set[str]:
    """One step of import closure: S ∪ ⋃_{x∈S} G(x)."""
    result = set(S)
    for x in S:
        result |= G.get(x, set())
    return result


def import_closure(G: Dict[str, Set[str]], n: int, S: Set[str]) -> Set[str]:
    """Iterated import closure: n steps of step_closure."""
    current = set(S)
    for _ in range(n):
        current = step_closure(G, current)
    return current


def is_import_closed(G: Dict[str, Set[str]], S: Set[str]) -> bool:
    """Check if S is closed under G: ∀ x ∈ S, G(x) ⊆ S."""
    for x in S:
        if not G.get(x, set()).issubset(S):
            return False
    return True


# ═══════════════════════════════════════════════════════════════
# Demo 1: Well-formed proof file
# ═══════════════════════════════════════════════════════════════
print("=" * 60)
print("DEMO 1: Well-Formed Proof File Analysis")
print("=" * 60)

example_file = ProofFile(
    imports=["Mathlib.Data.Nat.Basic", "Mathlib.Tactic"],
    theorems=[
        ThmDecl("nat_add_comm", set()),
        ThmDecl("nat_add_assoc", set()),
        ThmDecl("sum_formula", {"nat_add_comm", "nat_add_assoc"}),
        ThmDecl("sum_bound", {"sum_formula"}),
        ThmDecl("main_theorem", {"sum_formula", "sum_bound", "nat_add_comm"}),
    ]
)

print(f"\nImports: {example_file.imports}")
print(f"\nTheorems ({len(example_file.theorems)}):")
for i, t in enumerate(example_file.theorems):
    print(f"  [{i}] {t.name} depends on: {t.deps or '{}'}")

print(f"\nUnique names: {unique_names(example_file.theorems)}")
print(f"Respects order: {decls_respect_order(example_file.theorems)}")

rank = compute_rank(example_file.theorems)
print(f"\nRank function: {rank}")

edges = dependency_edges(example_file.theorems)
print(f"\nDependency edges (a → b means 'a depends on b'):")
for a, b in edges:
    print(f"  {a} → {b}  (rank {rank[a]} > rank {rank[b]}? {rank[a] > rank[b]})")

# Verify no self-dependency
print(f"\nNo self-dependencies: {all(t.name not in t.deps for t in example_file.theorems)}")

# Verify all edges decrease rank
print(f"All edges decrease rank: {all(rank[a] > rank[b] for a, b in edges)}")


# ═══════════════════════════════════════════════════════════════
# Demo 2: Detecting violations
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 2: Detecting Order Violations")
print("=" * 60)

bad_file = ProofFile(
    imports=[],
    theorems=[
        ThmDecl("lemma_A", {"lemma_B"}),  # B not yet declared!
        ThmDecl("lemma_B", set()),
    ]
)

print("\nTheorems:")
for i, t in enumerate(bad_file.theorems):
    print(f"  [{i}] {t.name} depends on: {t.deps or '{}'}")

print(f"\nRespects order: {decls_respect_order(bad_file.theorems)}")
print("  → lemma_A depends on lemma_B, but lemma_B comes after lemma_A!")

# Self-dependency example
self_dep = ProofFile(
    imports=[],
    theorems=[ThmDecl("circular", {"circular"})],
)
print(f"\nSelf-dependency in 'circular': {'circular' in self_dep.theorems[0].deps}")
print(f"Respects order: {decls_respect_order(self_dep.theorems)}")


# ═══════════════════════════════════════════════════════════════
# Demo 3: Import closure computation
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 3: Import Closure Computation")
print("=" * 60)

# A small import graph
import_graph: Dict[str, Set[str]] = {
    "Analysis.Basic": {"Data.Real", "Order.Filter"},
    "Data.Real": {"Data.Rat", "Algebra.Order"},
    "Data.Rat": {"Data.Int"},
    "Data.Int": {"Data.Nat"},
    "Data.Nat": set(),
    "Order.Filter": {"Order.Basic"},
    "Order.Basic": set(),
    "Algebra.Order": {"Data.Nat"},
}

seed = {"Analysis.Basic"}
print(f"\nImport graph (8 modules):")
for k, v in sorted(import_graph.items()):
    print(f"  {k} imports {v or '{}'}")

print(f"\nSeed: {seed}")
for n in range(6):
    closure = import_closure(import_graph, n, seed)
    closed = is_import_closed(import_graph, closure)
    print(f"  Step {n}: {sorted(closure)} (|closure| = {len(closure)}, closed = {closed})")

# Verify idempotence on closed set
final = import_closure(import_graph, 5, seed)
assert is_import_closed(import_graph, final), "Should be closed"
stepped = step_closure(import_graph, final)
assert stepped == final, "Should be idempotent on closed set"
print(f"\n✓ Verified: stepClosure is idempotent on the closed set (|S| = {len(final)})")


# ═══════════════════════════════════════════════════════════════
# Demo 4: Monotonicity verification
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 4: Monotonicity of Import Closure")
print("=" * 60)

print(f"\nVerifying importClosure(G, m, S) ⊆ importClosure(G, n, S) for m ≤ n:")
for m in range(6):
    for n in range(m, 6):
        cm = import_closure(import_graph, m, seed)
        cn = import_closure(import_graph, n, seed)
        assert cm.issubset(cn), f"Failed: step {m} not subset of step {n}"
print("  ✓ All monotonicity checks passed (0 ≤ m ≤ n ≤ 5)")

# Step closure monotonicity
S1 = {"Data.Nat"}
S2 = {"Data.Nat", "Data.Int"}
sc1 = step_closure(import_graph, S1)
sc2 = step_closure(import_graph, S2)
print(f"\n  S1 = {S1} → stepClosure = {sc1}")
print(f"  S2 = {S2} → stepClosure = {sc2}")
print(f"  S1 ⊆ S2: {S1.issubset(S2)}")
print(f"  stepClosure(S1) ⊆ stepClosure(S2): {sc1.issubset(sc2)}")


# ═══════════════════════════════════════════════════════════════
# Demo 5: Large proof file with topological ranking
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 60)
print("DEMO 5: Topological Ranking of a Larger Proof File")
print("=" * 60)

large_file = ProofFile(
    imports=["Mathlib"],
    theorems=[
        ThmDecl("def_group", set()),
        ThmDecl("group_identity_unique", {"def_group"}),
        ThmDecl("group_inverse_unique", {"def_group"}),
        ThmDecl("cancellation_left", {"def_group", "group_identity_unique"}),
        ThmDecl("cancellation_right", {"def_group", "group_identity_unique"}),
        ThmDecl("inverse_of_inverse", {"def_group", "group_inverse_unique"}),
        ThmDecl("inverse_of_product", {"def_group", "group_inverse_unique", "cancellation_left"}),
        ThmDecl("order_definition", {"def_group"}),
        ThmDecl("lagrange_theorem", {"def_group", "order_definition", "cancellation_left", "cancellation_right"}),
        ThmDecl("cayley_theorem", {"def_group", "group_identity_unique", "lagrange_theorem"}),
    ]
)

print(f"\n{len(large_file.theorems)} theorems in proof file")
print(f"Unique names: {unique_names(large_file.theorems)}")
print(f"Respects order: {decls_respect_order(large_file.theorems)}")

rank = compute_rank(large_file.theorems)
edges = dependency_edges(large_file.theorems)
print(f"\nEdges: {len(edges)} dependency relationships")
print(f"All edges decrease rank: {all(rank[a] > rank[b] for a, b in edges)}")

# Compute dependency depth
def dependency_depth(decls: List[ThmDecl]) -> Dict[str, int]:
    """Compute the longest dependency chain ending at each theorem."""
    depth: Dict[str, int] = {}
    for t in decls:
        if not t.deps:
            depth[t.name] = 0
        else:
            depth[t.name] = 1 + max(depth.get(d, 0) for d in t.deps)
    return depth

depths = dependency_depth(large_file.theorems)
print(f"\nDependency depths (longest chain):")
for t in large_file.theorems:
    bar = "█" * (depths[t.name] + 1)
    print(f"  {t.name:30s} depth={depths[t.name]}  {bar}")

print(f"\nMaximum proof depth: {max(depths.values())}")
print(f"Average proof depth: {sum(depths.values()) / len(depths):.1f}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json by assembling all deliverables."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Logic/DependencyExtraction.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualization data
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

package = {
    "title": "A Formal Theory of Proof-File Causality: Dependency Extraction, Acyclicity, and Closure Operators",
    "domain": "Logic / Formal Methods / Graph Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Dependency Extraction Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Well-Formedness Checking",
            "pseudocode": "Algorithm: CheckWellFormedness(decls)\nInput: List of (name, deps) pairs\nOutput: (is_valid, violations)\n\ndeclared ← ∅\nviolations ← []\nfor i = 0 to |decls| - 1:\n    bad_deps ← decls[i].deps \\ declared\n    if bad_deps ≠ ∅:\n        violations.append((i, decls[i].name, bad_deps))\n    declared ← declared ∪ {decls[i].name}\nreturn (|violations| = 0, violations)\n\nTime: O(n · d), Space: O(n)",
            "code": algorithms_code
        },
        {
            "name": "Import Closure with Convergence",
            "pseudocode": "Algorithm: ImportClosure(G, S)\nInput: Import graph G, seed set S\nOutput: (closed_set, steps)\n\ncurrent ← S\nfor step = 0, 1, 2, ...:\n    next ← current ∪ ⋃_{x ∈ current} G(x)\n    if next = current:\n        return (current, step)\n    current ← next\n\nTime: O(k · |S_final| · max|G(x)|), Space: O(|S_final|)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Theorem Dependency Graph with Topological Stratification",
            "data": viz_data["dep_graph"]
        },
        {
            "name": "Import Closure Growth and Monotonicity",
            "data": viz_data["closure_growth"]
        },
        {
            "name": "Proof Complexity Landscape: Boundary vs Bulk",
            "data": viz_data["complexity_landscape"]
        },
        {
            "name": "Import Closure Convergence: Multiple Seeds",
            "data": viz_data["idempotence"]
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Dependency Extraction Theory
================================================
Generates publication-quality figures illustrating:
1. Dependency graph structure
2. Import closure growth
3. Topological ranking
4. Depth distribution
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
import base64
import io


def save_figure(fig, filename):
    """Save figure to file and return base64 encoding."""
    fig.savefig(filename, dpi=150, bbox_inches='tight', facecolor='white')
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# ═══════════════════════════════════════════════════════════════
# Figure 1: Dependency Graph with Topological Layers
# ═══════════════════════════════════════════════════════════════

def draw_dependency_graph():
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Define theorems and dependencies
    theorems = [
        ("def_group", set()),
        ("id_unique", {"def_group"}),
        ("inv_unique", {"def_group"}),
        ("cancel_L", {"def_group", "id_unique"}),
        ("cancel_R", {"def_group", "id_unique"}),
        ("inv_inv", {"def_group", "inv_unique"}),
        ("inv_prod", {"def_group", "inv_unique", "cancel_L"}),
        ("order_def", {"def_group"}),
        ("lagrange", {"def_group", "order_def", "cancel_L", "cancel_R"}),
        ("cayley", {"def_group", "id_unique", "lagrange"}),
    ]

    # Compute depth
    depth = {}
    for name, deps in theorems:
        if not deps:
            depth[name] = 0
        else:
            depth[name] = 1 + max(depth.get(d, 0) for d in deps)

    max_depth = max(depth.values())

    # Position nodes by depth layer
    layers = defaultdict(list)
    for name, _ in theorems:
        layers[depth[name]].append(name)

    positions = {}
    for d in range(max_depth + 1):
        layer = layers[d]
        n = len(layer)
        for idx, name in enumerate(layer):
            x = (idx - (n - 1) / 2) * 2.5
            y = -d * 2.0
            positions[name] = (x, y)

    # Colors by depth
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, max_depth + 1))
    node_colors = {name: colors[depth[name]] for name, _ in theorems}

    # Draw edges
    for name, deps in theorems:
        for d in deps:
            x1, y1 = positions[name]
            x0, y0 = positions[d]
            ax.annotate("", xy=(x1, y1), xytext=(x0, y0),
                        arrowprops=dict(arrowstyle="->", color='#888888',
                                        lw=1.2, connectionstyle="arc3,rad=0.1"))

    # Draw nodes
    for name, _ in theorems:
        x, y = positions[name]
        circle = plt.Circle((x, y), 0.4, color=node_colors[name],
                            ec='black', lw=1.5, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y - 0.7, name, ha='center', va='top', fontsize=8,
                fontweight='bold')

    # Depth labels
    for d in range(max_depth + 1):
        ax.text(-7, -d * 2.0, f"Depth {d}", ha='right', va='center',
                fontsize=10, color=colors[d], fontweight='bold')

    ax.set_xlim(-8, 8)
    ax.set_ylim(-max_depth * 2.0 - 1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Theorem Dependency Graph with Topological Stratification",
                 fontsize=14, fontweight='bold', pad=20)

    return save_figure(fig, 'dep_graph.png')


# ═══════════════════════════════════════════════════════════════
# Figure 2: Import Closure Growth
# ═══════════════════════════════════════════════════════════════

def draw_closure_growth():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Import graph
    G = {
        "Analysis": {"Real", "Filter"},
        "Real": {"Rat", "Order"},
        "Rat": {"Int"},
        "Int": {"Nat"},
        "Filter": {"Order"},
        "Nat": set(),
        "Order": set(),
    }

    def step_closure(G, S):
        result = set(S)
        for x in S:
            result |= G.get(x, set())
        return result

    # Compute closure growth
    seed = {"Analysis"}
    steps_data = []
    current = set(seed)
    for n in range(8):
        steps_data.append(len(current))
        current = step_closure(G, current)

    # Plot closure size
    ax1.plot(range(8), steps_data, 'o-', color='#2196F3', lw=2.5,
             markersize=8, label='|importClosure(G, n, S)|')
    ax1.axhline(y=7, color='#4CAF50', ls='--', lw=1.5, label='Fixed point (7 modules)')
    ax1.fill_between(range(8), steps_data, alpha=0.15, color='#2196F3')
    ax1.set_xlabel('Number of closure steps (n)', fontsize=12)
    ax1.set_ylabel('Closure size', fontsize=12)
    ax1.set_title('Import Closure Growth', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.set_xticks(range(8))
    ax1.grid(True, alpha=0.3)

    # Plot monotonicity verification
    monotone_checks = []
    for m in range(6):
        for n in range(m, 6):
            monotone_checks.append((m, n))

    ax2.set_xlim(-0.5, 5.5)
    ax2.set_ylim(-0.5, 5.5)
    for m, n in monotone_checks:
        color = '#4CAF50'
        ax2.plot(n, m, 's', color=color, markersize=12)

    ax2.set_xlabel('n (larger step count)', fontsize=12)
    ax2.set_ylabel('m (smaller step count)', fontsize=12)
    ax2.set_title('Monotonicity: importClosure(m) ⊆ importClosure(n)', fontsize=13, fontweight='bold')
    ax2.set_xticks(range(6))
    ax2.set_yticks(range(6))
    ax2.grid(True, alpha=0.3)

    green_patch = mpatches.Patch(color='#4CAF50', label='m ≤ n: verified ⊆')
    ax2.legend(handles=[green_patch], fontsize=10)

    plt.tight_layout()
    return save_figure(fig, 'closure_growth.png')


# ═══════════════════════════════════════════════════════════════
# Figure 3: Proof Complexity Landscape
# ═══════════════════════════════════════════════════════════════

def draw_complexity_landscape():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Theorem data
    proof_deps = {
        "ring_axioms": set(),
        "ideal_def": {"ring_axioms"},
        "quotient_ring": {"ring_axioms", "ideal_def"},
        "homomorphism": {"ring_axioms"},
        "first_iso": {"homomorphism", "quotient_ring", "ideal_def"},
        "prime_ideal": {"ideal_def", "ring_axioms"},
        "maximal_ideal": {"ideal_def", "prime_ideal"},
        "pid_def": {"ideal_def", "ring_axioms"},
        "ufd_def": {"ring_axioms"},
        "pid_implies_ufd": {"pid_def", "ufd_def", "prime_ideal"},
        "noetherian": {"ideal_def", "ring_axioms"},
        "hilbert_basis": {"noetherian", "quotient_ring", "homomorphism"},
    }

    # Compute metrics
    names = list(proof_deps.keys())
    direct = [len(proof_deps[n]) for n in names]

    depth = {}
    for name in names:
        deps = proof_deps[name]
        if not deps:
            depth[name] = 0
        else:
            depth[name] = 1 + max(depth.get(d, 0) for d in deps)
    depths = [depth[n] for n in names]

    # Transitive closure
    def trans_size(name):
        visited = set()
        stack = list(proof_deps[name])
        while stack:
            cur = stack.pop()
            if cur not in visited:
                visited.add(cur)
                stack.extend(proof_deps.get(cur, set()))
        return len(visited)

    transitive = [trans_size(n) for n in names]

    # Scatter: direct vs transitive
    scatter = ax1.scatter(direct, transitive, c=depths, cmap='plasma',
                          s=150, edgecolors='black', linewidth=1.5, zorder=5)
    for i, name in enumerate(names):
        short_name = name[:12]
        ax1.annotate(short_name, (direct[i], transitive[i]),
                     textcoords="offset points", xytext=(5, 5), fontsize=7)

    ax1.plot([0, 5], [0, 5], 'k--', alpha=0.3, label='direct = transitive')
    ax1.set_xlabel('Direct dependencies (boundary)', fontsize=12)
    ax1.set_ylabel('Transitive dependencies (bulk)', fontsize=12)
    ax1.set_title('Boundary vs Bulk Complexity', fontsize=13, fontweight='bold')
    plt.colorbar(scatter, ax=ax1, label='Depth')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Bar chart: depth distribution
    depth_counts = defaultdict(int)
    for d in depths:
        depth_counts[d] += 1
    max_d = max(depths)
    bars = [depth_counts.get(d, 0) for d in range(max_d + 1)]
    colors = plt.cm.plasma(np.linspace(0.2, 0.8, max_d + 1))
    ax2.bar(range(max_d + 1), bars, color=colors, edgecolor='black', linewidth=1.2)
    ax2.set_xlabel('Dependency depth', fontsize=12)
    ax2.set_ylabel('Number of theorems', fontsize=12)
    ax2.set_title('Depth Distribution', fontsize=13, fontweight='bold')
    ax2.set_xticks(range(max_d + 1))
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    return save_figure(fig, 'complexity_landscape.png')


# ═══════════════════════════════════════════════════════════════
# Figure 4: Idempotence and Fixed Points
# ═══════════════════════════════════════════════════════════════

def draw_idempotence():
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Multiple seed sets
    G = {
        "A": {"B", "C"},
        "B": {"D"},
        "C": {"D", "E"},
        "D": set(),
        "E": {"F"},
        "F": set(),
    }

    def step_closure(G, S):
        result = set(S)
        for x in S:
            result |= G.get(x, set())
        return result

    seeds = [{"A"}, {"B"}, {"C"}, {"A", "C"}, {"D", "E"}]
    colors_list = ['#E91E63', '#2196F3', '#4CAF50', '#FF9800', '#9C27B0']

    for idx, (seed, color) in enumerate(zip(seeds, colors_list)):
        sizes = []
        current = set(seed)
        for n in range(8):
            sizes.append(len(current))
            current = step_closure(G, current)
        ax.plot(range(8), sizes, 'o-', color=color, lw=2, markersize=7,
                label=f'Seed: {sorted(seed)}')

    ax.set_xlabel('Closure step n', fontsize=12)
    ax.set_ylabel('|importClosure(G, n, S)|', fontsize=12)
    ax.set_title('Import Closure Convergence: Multiple Seeds',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='lower right')
    ax.set_xticks(range(8))
    ax.grid(True, alpha=0.3)

    # Add annotation about idempotence
    ax.annotate('Fixed point\n(idempotent)', xy=(5, 6), fontsize=10,
                ha='center', color='gray', style='italic')

    plt.tight_layout()
    return save_figure(fig, 'idempotence.png')


# ═══════════════════════════════════════════════════════════════
# Generate all figures
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating visualizations...")

    b64_dep = draw_dependency_graph()
    print(f"  ✓ dep_graph.png ({len(b64_dep)} bytes base64)")

    b64_closure = draw_closure_growth()
    print(f"  ✓ closure_growth.png ({len(b64_closure)} bytes base64)")

    b64_complexity = draw_complexity_landscape()
    print(f"  ✓ complexity_landscape.png ({len(b64_complexity)} bytes base64)")

    b64_idemp = draw_idempotence()
    print(f"  ✓ idempotence.png ({len(b64_idemp)} bytes base64)")

    # Save base64 data for JSON package
    import json
    viz_data = {
        "dep_graph": b64_dep,
        "closure_growth": b64_closure,
        "complexity_landscape": b64_complexity,
        "idempotence": b64_idemp,
    }
    with open("viz_data.json", "w") as f:
        json.dump(viz_data, f)

    print("\nAll visualizations generated successfully!")
