"""
Algorithms for Proof Dynamics as a Rewriting-Theoretic Dynamical System.

Implements the core algorithms from the research paper:
- Proof sketch representation and energy computation
- Greedy normalization with energy tracking
- Exhaustive normalization path enumeration
- Basin of attraction analysis
- Redundancy index computation

All algorithms operate on tree-structured proof sketches with semantic labels.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Optional, List, Tuple, Dict, Set, FrozenSet
from collections import defaultdict
import itertools


# ============================================================
# Core Data Structures
# ============================================================

class NodeType(Enum):
    """Types of proof sketch nodes."""
    AXIOM = auto()
    LEMMA = auto()
    TRANS = auto()
    CASES = auto()
    REDUNDANT = auto()
    DUPLICATE = auto()


@dataclass(frozen=True)
class ProofSketch:
    """
    A syntactic proof object (tree) over string-valued theorem labels.

    Each node has a type and optional children/label:
    - AXIOM(label): leaf node invoking an axiom
    - LEMMA(label, child): proves label using sub-proof child
    - TRANS(left, right): transitivity chain
    - CASES(left, right): case split
    - REDUNDANT(child): redundant wrapper (can be dropped)
    - DUPLICATE(child): duplicated copy (can be deduplicated)
    """
    node_type: NodeType
    label: Optional[str] = None
    left: Optional['ProofSketch'] = None
    right: Optional['ProofSketch'] = None

    # Convenience constructors
    @staticmethod
    def axiom(label: str) -> 'ProofSketch':
        return ProofSketch(NodeType.AXIOM, label=label)

    @staticmethod
    def lemma(label: str, child: 'ProofSketch') -> 'ProofSketch':
        return ProofSketch(NodeType.LEMMA, label=label, left=child)

    @staticmethod
    def trans(left: 'ProofSketch', right: 'ProofSketch') -> 'ProofSketch':
        return ProofSketch(NodeType.TRANS, left=left, right=right)

    @staticmethod
    def cases(left: 'ProofSketch', right: 'ProofSketch') -> 'ProofSketch':
        return ProofSketch(NodeType.CASES, left=left, right=right)

    @staticmethod
    def redundant(child: 'ProofSketch') -> 'ProofSketch':
        return ProofSketch(NodeType.REDUNDANT, left=child)

    @staticmethod
    def duplicate(child: 'ProofSketch') -> 'ProofSketch':
        return ProofSketch(NodeType.DUPLICATE, left=child)

    def __repr__(self):
        if self.node_type == NodeType.AXIOM:
            return f"ax({self.label})"
        elif self.node_type == NodeType.LEMMA:
            return f"lem({self.label},{self.left})"
        elif self.node_type == NodeType.TRANS:
            return f"tr({self.left},{self.right})"
        elif self.node_type == NodeType.CASES:
            return f"cs({self.left},{self.right})"
        elif self.node_type == NodeType.REDUNDANT:
            return f"red({self.left})"
        elif self.node_type == NodeType.DUPLICATE:
            return f"dup({self.left})"
        return "??"


# ============================================================
# Energy (Complexity) Computation
# ============================================================

def size(p: ProofSketch) -> int:
    """Total number of nodes in the proof tree."""
    if p.node_type == NodeType.AXIOM:
        return 1
    elif p.node_type in (NodeType.LEMMA, NodeType.REDUNDANT, NodeType.DUPLICATE):
        return 1 + size(p.left)
    elif p.node_type in (NodeType.TRANS, NodeType.CASES):
        return 1 + size(p.left) + size(p.right)
    return 0


def depth(p: ProofSketch) -> int:
    """Tree depth (longest root-to-leaf path)."""
    if p.node_type == NodeType.AXIOM:
        return 0
    elif p.node_type in (NodeType.LEMMA, NodeType.REDUNDANT, NodeType.DUPLICATE):
        return 1 + depth(p.left)
    elif p.node_type in (NodeType.TRANS, NodeType.CASES):
        return 1 + max(depth(p.left), depth(p.right))
    return 0


def lemma_count(p: ProofSketch) -> int:
    """Number of LEMMA nodes in the tree."""
    if p.node_type == NodeType.AXIOM:
        return 0
    elif p.node_type == NodeType.LEMMA:
        return 1 + lemma_count(p.left)
    elif p.node_type in (NodeType.REDUNDANT, NodeType.DUPLICATE):
        return lemma_count(p.left)
    elif p.node_type in (NodeType.TRANS, NodeType.CASES):
        return lemma_count(p.left) + lemma_count(p.right)
    return 0


def energy(p: ProofSketch) -> int:
    """
    Scalar energy (Lyapunov function): sum of size + depth + lemma_count.

    This is the discrete Lyapunov function for the refinement dynamics.
    Every refinement step strictly decreases this value.

    Complexity: O(n) where n = size(p).
    """
    return size(p) + depth(p) + lemma_count(p)


def sem(p: ProofSketch) -> str:
    """
    Semantic function: extracts the theorem label that a proof sketch establishes.

    Invariant under all refinement steps (proved formally in Lean).
    """
    if p.node_type == NodeType.AXIOM:
        return p.label
    elif p.node_type == NodeType.LEMMA:
        return p.label
    elif p.node_type in (NodeType.TRANS, NodeType.CASES):
        return sem(p.left)
    elif p.node_type in (NodeType.REDUNDANT, NodeType.DUPLICATE):
        return sem(p.left)
    return ""


# ============================================================
# Refinement Steps
# ============================================================

def one_step_reducts(p: ProofSketch) -> List[ProofSketch]:
    """
    Enumerate all one-step reducts of proof sketch p.

    Implements the six refinement rules:
    1. dropRedundant: redundant(q) → q
    2. dropDuplicate: duplicate(q) → q
    3. flattenRedundantRedundant: redundant(redundant(q)) → redundant(q)
    4. flattenDuplicateDuplicate: duplicate(duplicate(q)) → duplicate(q)
    5. simplifyLemmaRedundant: lemma(a, redundant(q)) → lemma(a, q)
    6. simplifyLemmaLeaf: lemma(a, axiom(b)) → axiom(a)

    Plus congruence closure (applying rules inside subterms).

    Complexity: O(n) per call where n = size(p).
    """
    results = []

    # Root-level reductions
    if p.node_type == NodeType.REDUNDANT:
        results.append(p.left)  # dropRedundant
        if p.left.node_type == NodeType.REDUNDANT:
            results.append(p.left)  # flattenRedundantRedundant (same result)

    elif p.node_type == NodeType.DUPLICATE:
        results.append(p.left)  # dropDuplicate
        if p.left.node_type == NodeType.DUPLICATE:
            results.append(p.left)  # flattenDuplicateDuplicate

    elif p.node_type == NodeType.LEMMA:
        if p.left.node_type == NodeType.REDUNDANT:
            results.append(ProofSketch.lemma(p.label, p.left.left))  # simplifyLemmaRedundant
        if p.left.node_type == NodeType.AXIOM:
            results.append(ProofSketch.axiom(p.label))  # simplifyLemmaLeaf

    # Congruence: reduce inside subterms
    if p.node_type == NodeType.LEMMA:
        for r in one_step_reducts(p.left):
            results.append(ProofSketch.lemma(p.label, r))

    elif p.node_type == NodeType.TRANS:
        for r in one_step_reducts(p.left):
            results.append(ProofSketch.trans(r, p.right))
        for r in one_step_reducts(p.right):
            results.append(ProofSketch.trans(p.left, r))

    elif p.node_type == NodeType.CASES:
        for r in one_step_reducts(p.left):
            results.append(ProofSketch.cases(r, p.right))
        for r in one_step_reducts(p.right):
            results.append(ProofSketch.cases(p.left, r))

    elif p.node_type == NodeType.REDUNDANT:
        for r in one_step_reducts(p.left):
            results.append(ProofSketch.redundant(r))

    elif p.node_type == NodeType.DUPLICATE:
        for r in one_step_reducts(p.left):
            results.append(ProofSketch.duplicate(r))

    # Deduplicate results
    seen = set()
    unique = []
    for r in results:
        key = repr(r)
        if key not in seen:
            seen.add(key)
            unique.append(r)

    return unique


def is_normal_form(p: ProofSketch) -> bool:
    """Check if p is in normal form (no further reductions apply)."""
    return len(one_step_reducts(p)) == 0


# ============================================================
# Greedy Normalization
# ============================================================

def normalize_greedy(p: ProofSketch, max_steps: int = 1000) -> Tuple[ProofSketch, List[Tuple[ProofSketch, int]]]:
    """
    Greedy normalization: at each step, choose the reduct with lowest energy.

    Returns (normal_form, trajectory) where trajectory is a list of
    (proof_sketch, energy) pairs showing the descent.

    This implements the verified normalization algorithm from the Lean development.
    Termination is guaranteed by the Lyapunov descent theorem (wellFounded_of_energy).
    The bound on steps is energy(p) (normalization_steps_le_energy).

    Complexity: O(E(p) * n) where E(p) = energy(p), n = size(p).
    """
    trajectory = [(p, energy(p))]
    current = p
    steps = 0

    while steps < max_steps:
        reducts = one_step_reducts(current)
        if not reducts:
            break

        # Greedy: pick reduct with minimum energy
        best = min(reducts, key=energy)
        current = best
        trajectory.append((current, energy(current)))
        steps += 1

    return current, trajectory


def normalize_max_drop(p: ProofSketch, max_steps: int = 1000) -> Tuple[ProofSketch, List[Tuple[ProofSketch, int]]]:
    """
    Alternative normalization: at each step, choose the reduct with the
    maximum immediate energy drop.

    Returns (normal_form, trajectory).
    """
    trajectory = [(p, energy(p))]
    current = p

    for _ in range(max_steps):
        reducts = one_step_reducts(current)
        if not reducts:
            break

        current_e = energy(current)
        best = max(reducts, key=lambda r: current_e - energy(r))
        current = best
        trajectory.append((current, energy(current)))

    return current, trajectory


# ============================================================
# Exhaustive Path Enumeration (BFS)
# ============================================================

def enumerate_all_paths(p: ProofSketch, max_depth: int = 20) -> List[List[ProofSketch]]:
    """
    Enumerate all reduction paths from p to any normal form.

    Uses BFS with depth limit. Returns list of paths, where each path
    is a sequence [p, p1, p2, ..., nf].

    Complexity: Potentially exponential in the number of paths.
    """
    paths = []
    queue = [[p]]

    while queue:
        path = queue.pop(0)
        current = path[-1]

        if is_normal_form(current):
            paths.append(path)
            continue

        if len(path) > max_depth:
            continue

        for r in one_step_reducts(current):
            queue.append(path + [r])

    return paths


def optimal_path_length(p: ProofSketch, max_depth: int = 20) -> int:
    """Find the shortest path from p to any normal form."""
    paths = enumerate_all_paths(p, max_depth)
    if not paths:
        return -1
    return min(len(path) - 1 for path in paths)


# ============================================================
# Basin of Attraction Analysis
# ============================================================

def compute_basins(sketches: List[ProofSketch]) -> Dict[str, List[ProofSketch]]:
    """
    Group proof sketches by their normal form (basin of attraction).

    Returns a dict mapping repr(normal_form) -> list of sketches that
    normalize to that form.
    """
    basins: Dict[str, List[ProofSketch]] = defaultdict(list)
    for p in sketches:
        nf, _ = normalize_greedy(p)
        basins[repr(nf)].append(p)
    return dict(basins)


# ============================================================
# Redundancy Index
# ============================================================

def redundancy_index(p: ProofSketch) -> int:
    """
    Compute the redundancy index: energy(p) - energy(nf(p)).

    This measures the compressible redundancy in the proof.
    By the redundancyIndex_eq_zero_iff_normalForm theorem,
    this is zero exactly when p is already in normal form.
    """
    nf, _ = normalize_greedy(p)
    return energy(p) - energy(nf)


# ============================================================
# Proof Sketch Enumeration (for testing conjectures)
# ============================================================

def enumerate_sketches(labels: List[str], max_energy: int) -> List[ProofSketch]:
    """
    Enumerate all proof sketches up to a given energy bound.

    Generates sketches using all constructors with the given labels.
    Uses BFS on the sketch grammar.

    Args:
        labels: Available theorem labels
        max_energy: Maximum allowed energy

    Returns:
        List of all proof sketches with energy ≤ max_energy
    """
    results = []
    # Start with axioms
    atoms = [ProofSketch.axiom(l) for l in labels]
    results.extend(a for a in atoms if energy(a) <= max_energy)

    # Build up by applying constructors
    prev_layer = list(results)
    seen = {repr(p) for p in results}

    for _ in range(max_energy):
        new_layer = []
        for p in prev_layer:
            # Unary constructors
            for constructor in [ProofSketch.redundant, ProofSketch.duplicate]:
                q = constructor(p)
                key = repr(q)
                if energy(q) <= max_energy and key not in seen:
                    seen.add(key)
                    new_layer.append(q)
                    results.append(q)

            # Lemma constructor
            for label in labels:
                q = ProofSketch.lemma(label, p)
                key = repr(q)
                if energy(q) <= max_energy and key not in seen:
                    seen.add(key)
                    new_layer.append(q)
                    results.append(q)

        # Binary constructors (expensive)
        for p1 in prev_layer:
            for p2 in prev_layer:
                for constructor in [ProofSketch.trans, ProofSketch.cases]:
                    q = constructor(p1, p2)
                    key = repr(q)
                    if energy(q) <= max_energy and key not in seen:
                        seen.add(key)
                        new_layer.append(q)
                        results.append(q)

        if not new_layer:
            break
        prev_layer = new_layer

    return results


# ============================================================
# Conjecture Testing
# ============================================================

def test_greedy_optimality(labels: List[str], max_energy: int = 8) -> Dict:
    """
    Test the conjecture: greedy normalization is length-optimal.

    For each proof sketch up to the given energy bound, compare the
    greedy path length with the optimal (shortest) path length.

    Returns a summary dict with statistics and any counterexamples.
    """
    sketches = enumerate_sketches(labels, max_energy)
    results = {
        "total_tested": len(sketches),
        "optimal_matches": 0,
        "suboptimal": 0,
        "counterexamples": [],
        "max_suboptimality": 0,
    }

    for p in sketches:
        if is_normal_form(p):
            results["optimal_matches"] += 1
            continue

        _, greedy_traj = normalize_greedy(p)
        greedy_len = len(greedy_traj) - 1
        opt_len = optimal_path_length(p, max_depth=greedy_len + 5)

        if opt_len < 0:
            continue

        if greedy_len == opt_len:
            results["optimal_matches"] += 1
        else:
            gap = greedy_len - opt_len
            results["suboptimal"] += 1
            results["max_suboptimality"] = max(results["max_suboptimality"], gap)
            if len(results["counterexamples"]) < 5:
                results["counterexamples"].append({
                    "sketch": repr(p),
                    "greedy_length": greedy_len,
                    "optimal_length": opt_len,
                    "energy": energy(p),
                })

    return results


def test_basin_growth(labels: List[str], max_n: int = 10) -> Dict:
    """
    Test the conjecture: basin sizes grow at most polynomially.

    For each energy bound n, count the number of sketches normalizing
    to each normal form, and track how the largest basin grows.

    Returns growth data for analysis.
    """
    growth_data = {"n_values": [], "max_basin_size": [], "total_sketches": []}

    for n in range(1, max_n + 1):
        sketches = enumerate_sketches(labels, n)
        basins = compute_basins(sketches)

        max_basin = max(len(v) for v in basins.values()) if basins else 0
        growth_data["n_values"].append(n)
        growth_data["max_basin_size"].append(max_basin)
        growth_data["total_sketches"].append(len(sketches))

    return growth_data


if __name__ == "__main__":
    # Example usage
    ax = ProofSketch.axiom
    lem = ProofSketch.lemma
    red = ProofSketch.redundant
    dup = ProofSketch.duplicate

    # Build a bloated proof sketch
    p = red(dup(red(ax("sqrt2_irrational"))))
    print(f"Original: {p}")
    print(f"Energy: {energy(p)}")
    print(f"Semantics: {sem(p)}")

    nf, traj = normalize_greedy(p)
    print(f"\nNormal form: {nf}")
    print(f"Energy trajectory: {[e for _, e in traj]}")
    print(f"Redundancy index: {redundancy_index(p)}")
    print(f"Steps: {len(traj) - 1}")
    print(f"Energy bound: {energy(p)}")
