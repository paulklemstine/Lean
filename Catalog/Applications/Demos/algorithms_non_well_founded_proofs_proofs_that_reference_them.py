#!/usr/bin/env python3
"""
Non-Well-Founded Proof Algorithms

Implements the core algorithms from the research:
1. NWF Proof Tree construction and validation
2. Kleene fixed-point iteration for proof operators
3. Tropical proof height computation
4. Self-reference depth analysis
5. Proof tree minimization

All algorithms correspond to formally verified theorems in Lean 4.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Optional, Callable, Iterator
import math


# ============================================================
# Core Data Structures
# ============================================================

class NodeType(Enum):
    """Types of nodes in a non-well-founded proof tree."""
    AXIOM = auto()
    MODUS_PONENS = auto()
    SELF_REF = auto()
    BOTTOM = auto()


@dataclass
class ProofTree:
    """
    Non-well-founded proof tree.

    A proof tree where nodes can reference the conclusion being proved,
    creating circular dependencies resolved through fixed-point semantics.

    Corresponds to the Lean 4 type `NWFProofTree`.
    """
    node_type: NodeType
    conclusion: Optional[int] = None
    premise: Optional[int] = None
    children: tuple['ProofTree', ...] = ()

    @staticmethod
    def axiom_(p: int) -> 'ProofTree':
        """Create an axiom node proving proposition p."""
        return ProofTree(NodeType.AXIOM, conclusion=p)

    @staticmethod
    def modus_ponens(imp_proof: 'ProofTree', arg_proof: 'ProofTree',
                     premise: int, conclusion: int) -> 'ProofTree':
        """Create a modus ponens node: from (P → Q) and P, derive Q."""
        return ProofTree(NodeType.MODUS_PONENS, conclusion=conclusion,
                        premise=premise, children=(imp_proof, arg_proof))

    @staticmethod
    def self_ref(p: int, inner: 'ProofTree') -> 'ProofTree':
        """Create a self-referential node that assumes its own conclusion."""
        return ProofTree(NodeType.SELF_REF, conclusion=p, children=(inner,))

    @staticmethod
    def bottom() -> 'ProofTree':
        """Create an invalid/undefined proof node."""
        return ProofTree(NodeType.BOTTOM)


# ============================================================
# Algorithm 1: Ordinal Height Computation
# ============================================================

def ordinal_height(tree: ProofTree) -> int:
    """
    Compute the ordinal height of a proof tree.

    Time complexity: O(n) where n is the number of nodes.
    Space complexity: O(d) where d is the depth (stack frames).

    Corresponds to `proofOrdinalHeight` in Lean 4.

    >>> ordinal_height(ProofTree.axiom_(1))
    0
    >>> ordinal_height(ProofTree.self_ref(1, ProofTree.axiom_(1)))
    1
    """
    if tree.node_type == NodeType.AXIOM:
        return 0
    elif tree.node_type == NodeType.MODUS_PONENS:
        h1 = ordinal_height(tree.children[0])
        h2 = ordinal_height(tree.children[1])
        return max(h1, h2) + 1
    elif tree.node_type == NodeType.SELF_REF:
        return ordinal_height(tree.children[0]) + 1
    else:  # BOTTOM
        return 0


# ============================================================
# Algorithm 2: Validity Check
# ============================================================

def is_valid_nwf(tree: ProofTree) -> bool:
    """
    Check if a proof tree is a valid non-well-founded proof.

    Time complexity: O(n) where n is the number of nodes.

    Corresponds to `IsValidNWF` in Lean 4.

    >>> is_valid_nwf(ProofTree.self_ref(1, ProofTree.axiom_(1)))
    True
    >>> is_valid_nwf(ProofTree.self_ref(1, ProofTree.bottom()))
    False
    """
    if tree.node_type == NodeType.AXIOM:
        return True
    elif tree.node_type == NodeType.MODUS_PONENS:
        t1, t2 = tree.children
        return (t1.conclusion == tree.premise and
                t2.conclusion == tree.conclusion and
                is_valid_nwf(t1) and is_valid_nwf(t2))
    elif tree.node_type == NodeType.SELF_REF:
        inner = tree.children[0]
        return inner.conclusion == tree.conclusion and is_valid_nwf(inner)
    else:
        return False


# ============================================================
# Algorithm 3: Self-Reference Depth
# ============================================================

def self_ref_depth(tree: ProofTree) -> int:
    """
    Compute the self-reference depth of a proof tree.

    This measures how many nested levels of self-reference exist.
    Proved to be bounded by structural depth (selfRefDepth_le_depth).

    Time complexity: O(n)

    >>> self_ref_depth(ProofTree.axiom_(1))
    0
    >>> self_ref_depth(ProofTree.self_ref(1, ProofTree.axiom_(1)))
    1
    """
    if tree.node_type in (NodeType.AXIOM, NodeType.BOTTOM):
        return 0
    elif tree.node_type == NodeType.MODUS_PONENS:
        return max(self_ref_depth(c) for c in tree.children)
    elif tree.node_type == NodeType.SELF_REF:
        return 1 + self_ref_depth(tree.children[0])
    return 0


# ============================================================
# Algorithm 4: Kleene Fixed-Point Iteration
# ============================================================

ProofApprox = dict[int, int]


def kleene_iterate(
    step: Callable[[ProofApprox], ProofApprox],
    num_props: int,
    max_iterations: int = 100,
) -> tuple[ProofApprox, int]:
    """
    Compute the Kleene fixed point of a proof operator.

    Starting from the bottom element (all zeros), repeatedly apply
    the step function until stabilization.

    Time complexity: O(max_iterations × cost(step))
    Space complexity: O(num_props)

    Corresponds to `kleeneIterate` and `nwf_fixed_point_existence` in Lean 4.

    Args:
        step: Monotone proof operator
        num_props: Number of propositions
        max_iterations: Maximum iterations before declaring non-convergence

    Returns:
        Tuple of (fixed point approximation, number of iterations)
    """
    approx: ProofApprox = {p: 0 for p in range(num_props)}

    for i in range(max_iterations):
        new_approx = step(approx)
        if new_approx == approx:
            return approx, i + 1
        approx = new_approx

    return approx, max_iterations


# ============================================================
# Algorithm 5: Tropical Proof Height Operations
# ============================================================

INF = float('inf')


def tropical_add(a: float, b: float) -> float:
    """
    Tropical addition: take the minimum (shortest proof).

    Corresponds to `TropicalProofHeight.tropAdd`.

    >>> tropical_add(3, 5)
    3
    >>> tropical_add(2, float('inf'))
    2
    """
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """
    Tropical multiplication: add heights (compose proofs).

    Corresponds to `TropicalProofHeight.tropMul`.

    >>> tropical_mul(3, 5)
    8
    >>> tropical_mul(0, 7)
    7
    """
    return a + b


def tropical_proof_distance(
    heights_a: list[float],
    heights_b: list[float],
) -> float:
    """
    Compute the tropical distance between two proof height vectors.

    This measures how different two proof systems are in terms of
    the shortest proofs they can produce for each proposition.

    Time complexity: O(n) where n = len(heights)
    """
    assert len(heights_a) == len(heights_b)
    max_diff = 0.0
    for a, b in zip(heights_a, heights_b):
        if a == INF and b == INF:
            continue
        if a == INF or b == INF:
            return INF
        max_diff = max(max_diff, abs(a - b))
    return max_diff


# ============================================================
# Algorithm 6: Proof Tree Enumeration
# ============================================================

def enumerate_proof_trees(
    props: list[int],
    max_depth: int,
    allow_self_ref: bool = True,
) -> Iterator[ProofTree]:
    """
    Enumerate all proof trees up to a given depth.

    Used for testing conjectures about NWF proofs computationally.

    Time complexity: Exponential in max_depth (unavoidable)
    """
    if max_depth == 0:
        for p in props:
            yield ProofTree.axiom_(p)
        yield ProofTree.bottom()
        return

    # All trees of smaller depth
    for tree in enumerate_proof_trees(props, max_depth - 1, allow_self_ref):
        yield tree

    # New trees at this depth
    subtrees = list(enumerate_proof_trees(props, max_depth - 1, allow_self_ref))

    # Modus ponens combinations
    for t1 in subtrees:
        for t2 in subtrees:
            for p in props:
                for q in props:
                    yield ProofTree.modus_ponens(t1, t2, p, q)

    # Self-referential trees
    if allow_self_ref:
        for p in props:
            for inner in subtrees:
                yield ProofTree.self_ref(p, inner)


# ============================================================
# Algorithm 7: Conjecture Testing
# ============================================================

def test_self_ref_eliminability(max_depth: int = 3) -> dict:
    """
    Test the Self-Reference Eliminability Conjecture:
    Can every valid NWF proof of depth d be replaced by one of depth d-1?

    Returns statistics about the conjecture's status.
    """
    props = [0, 1, 2]
    results = {
        "tested_trees": 0,
        "valid_self_ref": 0,
        "eliminable": 0,
        "counterexamples": [],
    }

    # Build catalog of valid trees by self-ref depth
    valid_by_conclusion: dict[int, list[ProofTree]] = {}
    for tree in enumerate_proof_trees(props, max_depth):
        results["tested_trees"] += 1
        if is_valid_nwf(tree):
            conc = tree.conclusion
            if conc is not None:
                valid_by_conclusion.setdefault(conc, []).append(tree)

    # Check eliminability
    for tree in enumerate_proof_trees(props, max_depth):
        if not is_valid_nwf(tree):
            continue
        srd = self_ref_depth(tree)
        if srd == 0:
            continue
        results["valid_self_ref"] += 1

        # Can we find a valid tree with same conclusion but lower self-ref depth?
        conc = tree.conclusion
        found_lower = False
        if conc in valid_by_conclusion:
            for alt in valid_by_conclusion[conc]:
                if self_ref_depth(alt) < srd:
                    found_lower = True
                    break

        if found_lower:
            results["eliminable"] += 1
        else:
            results["counterexamples"].append({
                "tree": str(tree),
                "conclusion": conc,
                "self_ref_depth": srd,
            })

    return results


if __name__ == "__main__":
    import doctest
    doctest.testmod()

    print("=== Self-Reference Eliminability Conjecture Test ===")
    results = test_self_ref_eliminability(max_depth=2)
    print(f"Trees tested: {results['tested_trees']}")
    print(f"Valid self-referential: {results['valid_self_ref']}")
    print(f"Eliminable: {results['eliminable']}")
    print(f"Counterexamples: {len(results['counterexamples'])}")
    if results['counterexamples']:
        print("First counterexample:")
        print(f"  {results['counterexamples'][0]}")
    else:
        print("No counterexamples found — conjecture holds for tested depth!")
