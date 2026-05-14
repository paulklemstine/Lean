#!/usr/bin/env python3
"""
Algorithms for Dependency Extraction
=====================================
Implements the core algorithms from the formal theory:
- Well-formedness checking
- Topological ranking
- Import closure with convergence detection
- Dependency graph analysis
"""

from dataclasses import dataclass, field
from typing import Dict, List, Set, Tuple, Optional, Iterator
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════
# Data Structures
# ═══════════════════════════════════════════════════════════════

@dataclass
class ThmDecl:
    """Theorem declaration: name + finite set of dependencies."""
    name: str
    deps: frozenset = field(default_factory=frozenset)

    def __init__(self, name: str, deps: Optional[set] = None):
        self.name = name
        self.deps = frozenset(deps) if deps else frozenset()


@dataclass
class ProofFile:
    """Proof file: imports + ordered list of theorem declarations."""
    imports: List[str]
    theorems: List[ThmDecl]


@dataclass
class DependencyAnalysis:
    """Complete analysis results for a proof file."""
    is_well_formed: bool
    is_unique_named: bool
    has_self_deps: List[str]
    violations: List[Tuple[int, str, Set[str]]]
    rank: Dict[str, int]
    depth: Dict[str, int]
    edges: List[Tuple[str, str]]
    connected_components: List[Set[str]]
    max_depth: int
    avg_depth: float


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Well-Formedness Checking
# ═══════════════════════════════════════════════════════════════

def check_well_formedness(decls: List[ThmDecl]) -> Tuple[bool, List[Tuple[int, str, Set[str]]]]:
    """
    Check if declarations respect order.

    Algorithm: Linear scan, maintaining running set of declared names.
    Time: O(n * d) where d is max dependency set size
    Space: O(n)

    Returns (is_well_formed, list_of_violations).
    Each violation is (index, theorem_name, offending_deps).
    """
    declared: Set[str] = set()
    violations = []

    for i, t in enumerate(decls):
        bad_deps = t.deps - declared
        if bad_deps:
            violations.append((i, t.name, bad_deps))
        declared.add(t.name)

    return len(violations) == 0, violations


def check_unique_names(decls: List[ThmDecl]) -> Tuple[bool, List[str]]:
    """
    Check name uniqueness.

    Time: O(n)
    Space: O(n)

    Returns (is_unique, list_of_duplicates).
    """
    seen: Dict[str, int] = {}
    duplicates = []
    for i, t in enumerate(decls):
        if t.name in seen:
            duplicates.append(t.name)
        seen[t.name] = i
    return len(duplicates) == 0, duplicates


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Topological Ranking
# ═══════════════════════════════════════════════════════════════

def compute_rank(decls: List[ThmDecl]) -> Dict[str, int]:
    """
    Compute declaration-index rank.

    The rank function r : String → ℕ assigns each theorem its
    declaration index. For well-formed files with unique names,
    this satisfies: if b ∈ deps(a), then r(b) < r(a).

    Time: O(n)
    Space: O(n)
    """
    return {t.name: i for i, t in enumerate(decls)}


def compute_depth(decls: List[ThmDecl]) -> Dict[str, int]:
    """
    Compute dependency depth (longest chain ending at each theorem).

    For well-formed files, this is computed in a single forward pass.
    depth(t) = 0 if t has no deps, else 1 + max(depth(d) for d in deps).

    Time: O(n * d)
    Space: O(n)
    """
    depth: Dict[str, int] = {}
    for t in decls:
        if not t.deps:
            depth[t.name] = 0
        else:
            depth[t.name] = 1 + max(depth.get(d, 0) for d in t.deps)
    return depth


def topological_sort(decls: List[ThmDecl]) -> Optional[List[str]]:
    """
    Kahn's algorithm for topological sorting of the dependency graph.

    Returns None if a cycle is detected.

    Time: O(n + e) where e = total number of dependency edges
    Space: O(n + e)
    """
    # Build adjacency lists
    in_degree: Dict[str, int] = defaultdict(int)
    dependents: Dict[str, List[str]] = defaultdict(list)
    all_names = set()

    for t in decls:
        all_names.add(t.name)
        for d in t.deps:
            dependents[d].append(t.name)
            in_degree[t.name] = in_degree.get(t.name, 0) + 1
            all_names.add(d)

    # Initialize queue with zero in-degree nodes
    queue = [name for name in all_names if in_degree.get(name, 0) == 0]
    result = []

    while queue:
        node = queue.pop(0)
        result.append(node)
        for dep in dependents.get(node, []):
            in_degree[dep] -= 1
            if in_degree[dep] == 0:
                queue.append(dep)

    if len(result) < len(all_names):
        return None  # Cycle detected
    return result


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Import Closure
# ═══════════════════════════════════════════════════════════════

def step_closure(G: Dict[str, Set[str]], S: Set[str]) -> Set[str]:
    """
    One step of import closure: S ∪ ⋃_{x∈S} G(x).

    Time: O(|S| * max|G(x)|)
    Space: O(|result|)
    """
    result = set(S)
    for x in S:
        result |= G.get(x, set())
    return result


def import_closure(G: Dict[str, Set[str]], S: Set[str],
                   max_steps: int = 100) -> Tuple[Set[str], int]:
    """
    Compute import closure with convergence detection.

    Iterates step_closure until fixpoint or max_steps reached.

    Time: O(steps * |S_final| * max|G(x)|)
    Space: O(|S_final|)

    Returns (closed_set, steps_to_convergence).
    """
    current = set(S)
    for step in range(max_steps):
        next_set = step_closure(G, current)
        if next_set == current:
            return current, step
        current = next_set
    return current, max_steps


def is_import_closed(G: Dict[str, Set[str]], S: Set[str]) -> bool:
    """Check if S is closed under G."""
    return all(G.get(x, set()).issubset(S) for x in S)


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Full Dependency Analysis
# ═══════════════════════════════════════════════════════════════

def analyze_proof_file(pf: ProofFile) -> DependencyAnalysis:
    """
    Complete dependency analysis of a proof file.

    Performs all checks and computations in a single pass.

    Time: O(n * d + e) where n = theorems, d = max deps, e = total edges
    Space: O(n + e)
    """
    decls = pf.theorems

    is_wf, violations = check_well_formedness(decls)
    is_unique, _ = check_unique_names(decls)

    self_deps = [t.name for t in decls if t.name in t.deps]
    rank = compute_rank(decls)
    depth = compute_depth(decls)
    edges = [(t.name, d) for t in decls for d in t.deps]

    # Connected components via union-find
    parent: Dict[str, str] = {}

    def find(x: str) -> str:
        if x not in parent:
            parent[x] = x
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: str, y: str):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for t in decls:
        find(t.name)
        for d in t.deps:
            union(t.name, d)

    components: Dict[str, Set[str]] = defaultdict(set)
    for name in parent:
        components[find(name)].add(name)

    max_d = max(depth.values()) if depth else 0
    avg_d = sum(depth.values()) / len(depth) if depth else 0.0

    return DependencyAnalysis(
        is_well_formed=is_wf,
        is_unique_named=is_unique,
        has_self_deps=self_deps,
        violations=violations,
        rank=rank,
        depth=depth,
        edges=edges,
        connected_components=list(components.values()),
        max_depth=max_d,
        avg_depth=avg_d,
    )


# ═══════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Build a sample proof file
    pf = ProofFile(
        imports=["Mathlib"],
        theorems=[
            ThmDecl("def_group"),
            ThmDecl("identity_unique", {"def_group"}),
            ThmDecl("inverse_unique", {"def_group"}),
            ThmDecl("cancel_left", {"def_group", "identity_unique"}),
            ThmDecl("cancel_right", {"def_group", "identity_unique"}),
            ThmDecl("inv_inv", {"def_group", "inverse_unique"}),
            ThmDecl("inv_product", {"def_group", "inverse_unique", "cancel_left"}),
            ThmDecl("order_def", {"def_group"}),
            ThmDecl("lagrange", {"def_group", "order_def", "cancel_left", "cancel_right"}),
            ThmDecl("cayley", {"def_group", "identity_unique", "lagrange"}),
        ]
    )

    analysis = analyze_proof_file(pf)

    print("Dependency Analysis Results")
    print("=" * 50)
    print(f"Well-formed:       {analysis.is_well_formed}")
    print(f"Unique names:      {analysis.is_unique_named}")
    print(f"Self-dependencies: {analysis.has_self_deps or 'None'}")
    print(f"Violations:        {analysis.violations or 'None'}")
    print(f"Total edges:       {len(analysis.edges)}")
    print(f"Components:        {len(analysis.connected_components)}")
    print(f"Max depth:         {analysis.max_depth}")
    print(f"Average depth:     {analysis.avg_depth:.2f}")

    print(f"\nRank function:")
    for name, r in sorted(analysis.rank.items(), key=lambda x: x[1]):
        d = analysis.depth[name]
        print(f"  rank={r:2d}  depth={d}  {name}")

    # Topological sort
    order = topological_sort(pf.theorems)
    print(f"\nTopological order: {order}")

    # Import closure demo
    G = {
        "Analysis": {"Real", "Filter"},
        "Real": {"Rat", "Order"},
        "Rat": {"Int"},
        "Int": {"Nat"},
        "Filter": {"Order"},
    }

    closed, steps = import_closure(G, {"Analysis"})
    print(f"\nImport closure of {{'Analysis'}}:")
    print(f"  Result: {sorted(closed)}")
    print(f"  Steps to convergence: {steps}")
    print(f"  Is closed: {is_import_closed(G, closed)}")
