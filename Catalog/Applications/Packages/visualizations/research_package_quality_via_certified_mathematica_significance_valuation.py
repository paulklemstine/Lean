#!/usr/bin/env python3
"""
Algorithms for Certified Mathematical Significance Metrics.

Implements the core algorithms from the research paper with full
type hints, docstrings, and complexity analysis.
"""

from typing import Dict, Set, FrozenSet, List, Tuple, Optional, Callable
from dataclasses import dataclass
from enum import Enum


# ============================================================
# Algorithm 1: Significance Valuation
# ============================================================

def compute_significance(w: Dict[str, int], K: Set[str]) -> int:
    """
    Compute significance of knowledge state K under weight function w.

    Algorithm: Sum weights of all atoms in K.
    Time complexity: O(|K|)
    Space complexity: O(1)

    Args:
        w: Weight function mapping atom names to non-negative integers
        K: Knowledge state (finite set of atom identifiers)

    Returns:
        Total significance score

    >>> compute_significance({"A": 3, "B": 5}, {"A", "B"})
    8
    >>> compute_significance({"A": 3, "B": 5}, {"A"})
    3
    """
    return sum(w.get(a, 0) for a in K)


# ============================================================
# Algorithm 2: Threshold-Based Quality Gate
# ============================================================

@dataclass
class QualityGateResult:
    """Result of a quality gate evaluation."""
    passes: bool
    significance_old: int
    significance_new: int
    threshold: int
    new_atoms: Set[str]
    advances_field: bool


def quality_gate(
    w: Dict[str, int],
    tau: int,
    K_old: Set[str],
    K_new: Set[str]
) -> QualityGateResult:
    """
    Evaluate whether a knowledge transition passes the quality gate.

    The gate checks:
    1. K_old ⊆ K_new (no knowledge loss)
    2. σ(K_old) < τ (old state below threshold)
    3. τ ≤ σ(K_new) (new state meets threshold)
    4. ∃ a ∈ K_new, a ∉ K_old (genuine novelty)

    Time complexity: O(|K_new|)
    Space complexity: O(|K_new - K_old|)

    Args:
        w: Weight function
        tau: Significance threshold
        K_old: Previous knowledge state
        K_new: Proposed new knowledge state

    Returns:
        QualityGateResult with detailed evaluation
    """
    sig_old = compute_significance(w, K_old)
    sig_new = compute_significance(w, K_new)
    new_atoms = K_new - K_old

    is_superset = K_old <= K_new
    below_before = sig_old < tau
    meets_after = tau <= sig_new
    has_novelty = len(new_atoms) > 0

    advances = is_superset and below_before and meets_after and has_novelty

    return QualityGateResult(
        passes=meets_after and is_superset,
        significance_old=sig_old,
        significance_new=sig_new,
        threshold=tau,
        new_atoms=new_atoms,
        advances_field=advances
    )


# ============================================================
# Algorithm 3: ProofShape Feature Extraction
# ============================================================

class NodeType(Enum):
    AX = "axiom"
    APP = "application"
    LAM = "lambda"
    PAIR = "pair"


@dataclass
class ProofNode:
    """A node in a proof shape tree."""
    node_type: NodeType
    tag: Optional[str] = None  # Only for AX nodes
    children: Tuple = ()

    @staticmethod
    def ax(tag: str) -> 'ProofNode':
        return ProofNode(NodeType.AX, tag=tag)

    @staticmethod
    def app(p: 'ProofNode', q: 'ProofNode') -> 'ProofNode':
        return ProofNode(NodeType.APP, children=(p, q))

    @staticmethod
    def lam(p: 'ProofNode') -> 'ProofNode':
        return ProofNode(NodeType.LAM, children=(p,))

    @staticmethod
    def pair(p: 'ProofNode', q: 'ProofNode') -> 'ProofNode':
        return ProofNode(NodeType.PAIR, children=(p, q))


def extract_features(p: ProofNode) -> Set[str]:
    """
    Extract the set of atomic features from a proof shape.

    Recursively collects all axiom tags referenced in the proof tree.

    Time complexity: O(|p|) where |p| is the number of nodes
    Space complexity: O(depth(p)) for recursion stack + O(|features|)

    Args:
        p: Root of the proof shape tree

    Returns:
        Set of axiom tag strings
    """
    if p.node_type == NodeType.AX:
        return {p.tag} if p.tag else set()
    result: Set[str] = set()
    for child in p.children:
        result |= extract_features(child)
    return result


def proof_size(p: ProofNode) -> int:
    """
    Compute structural size of a proof shape.

    Time complexity: O(|p|)
    """
    if p.node_type == NodeType.AX:
        return 1
    return sum(proof_size(c) for c in p.children) + 1


def proof_height(p: ProofNode) -> int:
    """
    Compute height (depth) of a proof shape.

    Time complexity: O(|p|)
    """
    if p.node_type == NodeType.AX:
        return 1
    return max((proof_height(c) for c in p.children), default=0) + 1


def significance_from_proof(w: Dict[str, int], p: ProofNode) -> int:
    """
    Compute significance directly from a proof shape.

    Time complexity: O(|p|) for feature extraction + O(|features|) for summing
    """
    return compute_significance(w, extract_features(p))


# ============================================================
# Algorithm 4: Domain Coverage Analysis
# ============================================================

def domain_coverage(
    tag: Dict[str, str],
    K: Set[str]
) -> Set[str]:
    """
    Compute the set of domains covered by a knowledge state.

    Time complexity: O(|K|)

    Args:
        tag: Maps atom names to domain names
        K: Knowledge state

    Returns:
        Set of covered domain names
    """
    return {tag[a] for a in K if a in tag}


def coverage_lower_bound_check(
    w: Dict[str, int],
    tag: Dict[str, str],
    K: Set[str]
) -> Tuple[int, int, bool]:
    """
    Verify the domain coverage lower bound: |domains| ≤ σ(K).

    Returns (domain_count, significance, bound_holds).
    """
    domains = domain_coverage(tag, K)
    sig = compute_significance(w, K)
    return len(domains), sig, len(domains) <= sig


# ============================================================
# Algorithm 5: Triple Significance Evaluator
# ============================================================

@dataclass
class TripleSignificanceResult:
    """Breakdown of triple significance into components."""
    depth: int
    novelty: int
    bridge: int
    total: int
    is_masterclass: bool
    threshold: int


def evaluate_triple_significance(
    depth_w: Dict[str, int],
    novelty_w: Dict[str, int],
    bridge_w: Dict[str, int],
    tau: int,
    K: Set[str]
) -> TripleSignificanceResult:
    """
    Evaluate triple significance and MasterClass status.

    Time complexity: O(|K|)
    """
    d = compute_significance(depth_w, K)
    n = compute_significance(novelty_w, K)
    b = compute_significance(bridge_w, K)
    total = d + n + b
    return TripleSignificanceResult(
        depth=d, novelty=n, bridge=b,
        total=total,
        is_masterclass=tau <= total,
        threshold=tau
    )


# ============================================================
# Algorithm 6: Greedy Significance Maximizer
# ============================================================

def greedy_maximize_significance(
    w: Dict[str, int],
    universe: Set[str],
    budget: int
) -> Tuple[Set[str], int]:
    """
    Greedily select atoms to maximize significance within a budget.

    The budget limits the number of atoms that can be selected.
    Since significance is modular (additive), the greedy algorithm
    is optimal: select the highest-weight atoms first.

    Time complexity: O(n log n) where n = |universe|
    Space complexity: O(n)

    Args:
        w: Weight function
        universe: Available atoms
        budget: Maximum number of atoms to select

    Returns:
        (selected_set, total_significance)

    Note: Optimality of greedy for modular functions is a consequence
    of the valuation property proved in the formal theory.
    """
    sorted_atoms = sorted(universe, key=lambda a: w.get(a, 0), reverse=True)
    selected = set(sorted_atoms[:budget])
    return selected, compute_significance(w, selected)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Setup
    weights = {"A": 5, "B": 3, "C": 8, "D": 2, "E": 11, "F": 7}

    # Algorithm 1
    K = {"A", "C", "E"}
    print(f"Significance of {K}: {compute_significance(weights, K)}")

    # Algorithm 2
    result = quality_gate(weights, 15, {"A", "B"}, {"A", "B", "C", "E"})
    print(f"\nQuality gate result:")
    print(f"  Passes: {result.passes}")
    print(f"  Advances field: {result.advances_field}")
    print(f"  New atoms: {result.new_atoms}")

    # Algorithm 3
    proof = ProofNode.app(
        ProofNode.lam(ProofNode.pair(ProofNode.ax("A"), ProofNode.ax("B"))),
        ProofNode.ax("C")
    )
    print(f"\nProof features: {extract_features(proof)}")
    print(f"Proof size: {proof_size(proof)}")
    print(f"Proof significance: {significance_from_proof(weights, proof)}")

    # Algorithm 6
    selected, sig = greedy_maximize_significance(weights, set(weights.keys()), 3)
    print(f"\nGreedy selection (budget=3): {selected}, significance={sig}")
