#!/usr/bin/env python3
"""
Algorithms for Non-Well-Founded Proof Theory

Type-hinted implementations of the core algorithms from the convergence domain
theory for self-referential proofs.
"""

from dataclasses import dataclass, field
from typing import Optional, Callable, Dict, List, Tuple
from enum import Enum
import math


# ============================================================
# Core Data Structures
# ============================================================

class NodeType(Enum):
    """Types of proof tree nodes."""
    AXIOM = "axiom"
    MODUS_PONENS = "modus_ponens"
    SELF_REF = "self_ref"
    BOT = "bot"


@dataclass
class ProofTree:
    """Non-well-founded proof tree.

    Represents a proof that may contain self-referential nodes.
    Each node targets a proposition (identified by integer).
    """
    node_type: NodeType
    target_prop: Optional[int] = None
    premise_prop: Optional[int] = None
    children: List['ProofTree'] = field(default_factory=list)

    @staticmethod
    def axiom(p: int) -> 'ProofTree':
        return ProofTree(NodeType.AXIOM, target_prop=p)

    @staticmethod
    def modus_ponens(f: 'ProofTree', a: 'ProofTree', p: int, q: int) -> 'ProofTree':
        return ProofTree(NodeType.MODUS_PONENS, target_prop=q, premise_prop=p, children=[f, a])

    @staticmethod
    def self_ref(p: int, inner: 'ProofTree') -> 'ProofTree':
        return ProofTree(NodeType.SELF_REF, target_prop=p, children=[inner])

    @staticmethod
    def bot() -> 'ProofTree':
        return ProofTree(NodeType.BOT)


# ============================================================
# Algorithm 1: Consistency Metric
# ============================================================

def consistency_metric(tree: ProofTree) -> float:
    """Compute the consistency metric of a proof tree.

    The consistency metric CM satisfies:
    - CM(axiom) = 0
    - CM(mp(f, a)) = max(CM(f), CM(a))
    - CM(selfRef(p, inner)) = (1 + CM(inner)) / 2
    - CM(bot) = 1

    Returns a value in [0, 1].
    Valid proofs have CM < 1; the liar paradox has CM = 1.

    Time complexity: O(n) where n is the number of nodes.
    Space complexity: O(d) where d is the depth (stack space).
    """
    if tree.node_type == NodeType.AXIOM:
        return 0.0
    elif tree.node_type == NodeType.MODUS_PONENS:
        return max(consistency_metric(tree.children[0]),
                   consistency_metric(tree.children[1]))
    elif tree.node_type == NodeType.SELF_REF:
        return (1.0 + consistency_metric(tree.children[0])) / 2.0
    elif tree.node_type == NodeType.BOT:
        return 1.0
    return 0.0


# ============================================================
# Algorithm 2: Well-Founded Kernel Extraction
# ============================================================

def wf_kernel(tree: ProofTree) -> ProofTree:
    """Extract the well-founded kernel of a proof tree.

    Replaces every selfRef(p, inner) with axiom(p), yielding a
    traditional (well-founded) proof tree.

    Properties:
    - kernel is always valid if the original is valid
    - kernel has no self-referential nodes
    - kernel preserves the target proposition
    - depth(kernel) <= depth(original)

    Time complexity: O(n)
    Space complexity: O(d)
    """
    if tree.node_type == NodeType.AXIOM:
        return tree
    elif tree.node_type == NodeType.MODUS_PONENS:
        return ProofTree.modus_ponens(
            wf_kernel(tree.children[0]),
            wf_kernel(tree.children[1]),
            tree.premise_prop,
            tree.target_prop
        )
    elif tree.node_type == NodeType.SELF_REF:
        return ProofTree.axiom(tree.target_prop)
    elif tree.node_type == NodeType.BOT:
        return tree
    return tree


# ============================================================
# Algorithm 3: Convergence Domain Iteration
# ============================================================

def convergence_iterate(
    deduct: Callable[[Dict[int, float]], Dict[int, float]],
    propositions: List[int],
    max_steps: int = 100,
    tolerance: float = 1e-10
) -> Tuple[Dict[int, float], int, List[float]]:
    """Iterate a deduction operator to find its fixed point.

    Starting from the bottom element (all zeros), repeatedly applies
    the deduction operator until convergence.

    Args:
        deduct: The deduction operator (monotone, contractive)
        propositions: List of proposition IDs
        max_steps: Maximum iterations
        tolerance: Convergence threshold

    Returns:
        (fixed_point, steps_taken, error_history)

    The deduction operator should be contractive: for any two inputs
    x, y, the output satisfies dist(f(x), f(y)) <= c * dist(x, y)
    with c < 1.
    """
    current: Dict[int, float] = {p: 0.0 for p in propositions}
    errors: List[float] = []

    for step in range(max_steps):
        next_val = deduct(current)
        error = max(abs(next_val[p] - current[p]) for p in propositions)
        errors.append(error)

        if error < tolerance:
            return next_val, step + 1, errors

        current = next_val

    return current, max_steps, errors


# ============================================================
# Algorithm 4: k-Convergence Classification
# ============================================================

def classify_convergence(tree: ProofTree) -> Optional[int]:
    """Classify the convergence level of a proof tree.

    Returns the minimum k such that the tree is k-convergent,
    or None if the tree is invalid.

    A tree is k-convergent if:
    - Its self-reference depth is <= k
    - It is valid

    Time complexity: O(n)
    """
    if not is_valid(tree):
        return None
    return sr_depth(tree)


def sr_depth(tree: ProofTree) -> int:
    """Compute the self-reference depth."""
    if tree.node_type == NodeType.AXIOM:
        return 0
    elif tree.node_type == NodeType.MODUS_PONENS:
        return max(sr_depth(tree.children[0]), sr_depth(tree.children[1]))
    elif tree.node_type == NodeType.SELF_REF:
        return 1 + sr_depth(tree.children[0])
    elif tree.node_type == NodeType.BOT:
        return 0
    return 0


def is_valid(tree: ProofTree) -> bool:
    """Check if a proof tree is valid."""
    if tree.node_type == NodeType.AXIOM:
        return True
    elif tree.node_type == NodeType.MODUS_PONENS:
        return (len(tree.children) == 2 and
                is_valid(tree.children[0]) and
                is_valid(tree.children[1]))
    elif tree.node_type == NodeType.SELF_REF:
        return (len(tree.children) == 1 and
                tree.children[0].target_prop == tree.target_prop and
                is_valid(tree.children[0]))
    elif tree.node_type == NodeType.BOT:
        return False
    return False


# ============================================================
# Algorithm 5: Tropical Proof Height Operations
# ============================================================

class TropicalHeight:
    """Tropical proof height: ℕ ∪ {∞} with min-plus operations.

    Tropical addition = min (choose shorter proof)
    Tropical multiplication = + (compose proofs)
    """

    def __init__(self, value: Optional[int] = None):
        """Initialize. None represents infinity (no proof)."""
        self.value = value

    def __repr__(self) -> str:
        return "∞" if self.value is None else str(self.value)

    def __eq__(self, other: 'TropicalHeight') -> bool:
        return self.value == other.value

    @staticmethod
    def infinity() -> 'TropicalHeight':
        return TropicalHeight(None)

    @staticmethod
    def zero() -> 'TropicalHeight':
        return TropicalHeight(0)

    def tadd(self, other: 'TropicalHeight') -> 'TropicalHeight':
        """Tropical addition: min."""
        if self.value is None:
            return other
        if other.value is None:
            return self
        return TropicalHeight(min(self.value, other.value))

    def tmul(self, other: 'TropicalHeight') -> 'TropicalHeight':
        """Tropical multiplication: +."""
        if self.value is None or other.value is None:
            return TropicalHeight.infinity()
        return TropicalHeight(self.value + other.value)


def tropical_proof_search(
    axiom_heights: Dict[int, int],
    rules: List[Tuple[int, int, int]],  # (premise, conclusion, rule_cost)
    target: int,
    max_iterations: int = 100
) -> Optional[int]:
    """Find minimum proof height using tropical fixed-point iteration.

    Args:
        axiom_heights: proposition -> height for axioms
        rules: (premise_prop, conclusion_prop, cost)
        target: proposition to prove
        max_iterations: iteration limit

    Returns:
        Minimum proof height, or None if unprovable
    """
    heights: Dict[int, TropicalHeight] = {}

    # Initialize: axioms have their given heights, everything else is ∞
    all_props = set(axiom_heights.keys())
    for p, c, _ in rules:
        all_props.add(p)
        all_props.add(c)

    for p in all_props:
        if p in axiom_heights:
            heights[p] = TropicalHeight(axiom_heights[p])
        else:
            heights[p] = TropicalHeight.infinity()

    # Iterate: apply rules tropically
    for _ in range(max_iterations):
        changed = False
        for premise, conclusion, cost in rules:
            new_height = heights[premise].tmul(TropicalHeight(cost))
            old = heights[conclusion]
            heights[conclusion] = old.tadd(new_height)
            if heights[conclusion] != old:
                changed = True
        if not changed:
            break

    result = heights.get(target, TropicalHeight.infinity())
    return result.value


# ============================================================
# Demonstration
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Consistency metric
    identity = ProofTree.self_ref(0, ProofTree.axiom(0))
    liar = ProofTree.self_ref(0, ProofTree.bot())
    print(f"Identity proof CM: {consistency_metric(identity)}")
    print(f"Liar sentence CM: {consistency_metric(liar)}")

    # 2. Convergence classification
    print(f"\nIdentity convergence level: {classify_convergence(identity)}")
    nested = ProofTree.self_ref(0, ProofTree.self_ref(0, ProofTree.axiom(0)))
    print(f"Nested SR convergence level: {classify_convergence(nested)}")
    print(f"Liar convergence level: {classify_convergence(liar)}")

    # 3. Convergence iteration
    def simple_deduct(state: Dict[int, float]) -> Dict[int, float]:
        return {p: 0.5 * v + 0.25 for p, v in state.items()}

    fp, steps, errors = convergence_iterate(simple_deduct, [0, 1, 2])
    print(f"\nConvergence iteration: {steps} steps")
    print(f"Fixed point: {fp}")

    # 4. Tropical proof search
    heights = tropical_proof_search(
        axiom_heights={0: 0, 1: 0},
        rules=[(0, 2, 1), (1, 2, 2), (2, 3, 1)],
        target=3
    )
    print(f"\nTropical proof search for prop 3: height = {heights}")
