#!/usr/bin/env python3
"""
Tropical Curry-Howard: Algorithms

Implements the core algorithms of tropical proof theory:
1. Tropical term evaluation (min-plus semiring)
2. Polynomial interpretation (termination measure)
3. Normalizer (certified reduction engine)
4. Confluence analysis (critical pair detection)
5. Complexity analysis of normalization

All algorithms have been formally verified in Lean 4 (see Logic/TropicalCurryHoward.lean).
"""

from dataclasses import dataclass
from typing import Optional, List, Tuple, Set, Dict
from enum import Enum


# ============================================================
# Data Structures
# ============================================================

class NodeType(Enum):
    ATOM = "atom"
    CUT = "cut"
    PLUS = "plus"
    MIN = "min"

@dataclass(frozen=True)
class TropTerm:
    """Tropical proof term."""
    node_type: NodeType
    value: Optional[int] = None  # for atoms
    left: Optional['TropTerm'] = None
    right: Optional['TropTerm'] = None

    def __repr__(self):
        if self.node_type == NodeType.ATOM:
            return f"a({self.value})"
        return f"{self.node_type.value}({self.left}, {self.right})"

def atom(n: int) -> TropTerm:
    return TropTerm(NodeType.ATOM, value=n)

def cut(l: TropTerm, r: TropTerm) -> TropTerm:
    return TropTerm(NodeType.CUT, left=l, right=r)

def plus(l: TropTerm, r: TropTerm) -> TropTerm:
    return TropTerm(NodeType.PLUS, left=l, right=r)

def tmin(l: TropTerm, r: TropTerm) -> TropTerm:
    return TropTerm(NodeType.MIN, left=l, right=r)


# ============================================================
# Algorithm 1: Tropical Evaluation
# ============================================================
# Time: O(n) where n = term size
# Space: O(d) where d = tree depth (stack)

def evaluate(t: TropTerm) -> int:
    """
    Evaluate a tropical proof term in the min-plus semiring.

    Pseudocode:
        EVAL(atom(n)) = n
        EVAL(cut(t, s)) = EVAL(t) + EVAL(s)
        EVAL(plus(t, s)) = EVAL(t) + EVAL(s)
        EVAL(min(t, s)) = min(EVAL(t), EVAL(s))

    Complexity: O(n) time, O(depth) stack space.
    """
    if t.node_type == NodeType.ATOM:
        return t.value
    l = evaluate(t.left)
    r = evaluate(t.right)
    if t.node_type in (NodeType.CUT, NodeType.PLUS):
        return l + r
    return min(l, r)  # MIN


# ============================================================
# Algorithm 2: Polynomial Interpretation
# ============================================================
# Time: O(n)
# Space: O(d)

def polynomial_interp(t: TropTerm) -> int:
    """
    Compute the polynomial interpretation (termination measure).

    Pseudocode:
        INTERP(atom(_)) = 2
        INTERP(cut(t, s)) = INTERP(t) * INTERP(s)
        INTERP(plus(t, s)) = INTERP(t) + INTERP(s)
        INTERP(min(t, s)) = INTERP(t) + INTERP(s) + 1

    Property: INTERP(t) ≥ 2 for all t.
    Property: Step(t, u) implies INTERP(u) < INTERP(t).
    """
    if t.node_type == NodeType.ATOM:
        return 2
    l = polynomial_interp(t.left)
    r = polynomial_interp(t.right)
    if t.node_type == NodeType.CUT:
        return l * r
    elif t.node_type == NodeType.PLUS:
        return l + r
    else:  # MIN
        return l + r + 1


# ============================================================
# Algorithm 3: One-Step Reduction
# ============================================================
# Time: O(n) worst case (traverses to find leftmost redex)
# Space: O(d) stack

def reduce_step(t: TropTerm) -> Optional[TropTerm]:
    """
    Apply the leftmost-outermost reduction step.

    Pseudocode:
        STEP(min(t, t)) = t                    -- idempotence
        STEP(cut(min(t,u), s)) = min(cut(t,s), cut(u,s))  -- left dist.
        STEP(cut(s, min(t,u))) = min(cut(s,t), cut(s,u))  -- right dist.
        STEP(f(t, s)) = f(STEP(t), s) or f(t, STEP(s))    -- congruence

    Returns None if t is in normal form.
    """
    # Base rules
    if t.node_type == NodeType.MIN and t.left == t.right:
        return t.left

    if t.node_type == NodeType.CUT:
        if t.left.node_type == NodeType.MIN:
            return tmin(cut(t.left.left, t.right), cut(t.left.right, t.right))
        if t.right.node_type == NodeType.MIN:
            return tmin(cut(t.left, t.right.left), cut(t.left, t.right.right))

    # Congruence: try subterms
    if t.node_type != NodeType.ATOM:
        sl = reduce_step(t.left)
        if sl is not None:
            return TropTerm(t.node_type, left=sl, right=t.right)
        sr = reduce_step(t.right)
        if sr is not None:
            return TropTerm(t.node_type, left=t.left, right=sr)

    return None


# ============================================================
# Algorithm 4: Full Normalization
# ============================================================
# Time: O(interp(t)) worst case (each step decreases interp by ≥ 1)
# Space: O(n * interp(t)) for storing the term at each step

def normalize(t: TropTerm) -> Tuple[TropTerm, int]:
    """
    Normalize a term by exhaustive reduction.

    Pseudocode:
        NORMALIZE(t):
            steps = 0
            while STEP(t) is not None:
                t = STEP(t)
                steps += 1
            return (t, steps)

    Termination: Guaranteed by polynomial interpretation.
        Each step decreases INTERP(t), which is a natural number ≥ 2.
    Soundness: EVAL(result) = EVAL(input).
    """
    steps = 0
    current = t
    while True:
        next_t = reduce_step(current)
        if next_t is None:
            break
        current = next_t
        steps += 1
    return current, steps


# ============================================================
# Algorithm 5: Normal Form Detection
# ============================================================

def is_normal(t: TropTerm) -> bool:
    """Check if a term is in normal form (no reduction applies)."""
    return reduce_step(t) is None


def count_redexes(t: TropTerm) -> Dict[str, int]:
    """Count the number of each type of redex in a term."""
    counts = {"min_idem": 0, "cut_min_left": 0, "cut_min_right": 0}

    if t.node_type == NodeType.MIN and t.left == t.right:
        counts["min_idem"] += 1
    if t.node_type == NodeType.CUT:
        if t.left.node_type == NodeType.MIN:
            counts["cut_min_left"] += 1
        if t.right.node_type == NodeType.MIN:
            counts["cut_min_right"] += 1

    if t.node_type != NodeType.ATOM:
        for key, val in count_redexes(t.left).items():
            counts[key] += val
        for key, val in count_redexes(t.right).items():
            counts[key] += val

    return counts


# ============================================================
# Algorithm 6: Critical Pair Analysis
# ============================================================

def analyze_critical_pair():
    """
    Analyze the critical pair for confluence.

    The critical pair arises from: cut(min(a,b), min(c,d))
    - Left-first: cut_min_left then cut_min_right on each branch
    - Right-first: cut_min_right then cut_min_left on each branch

    These produce different trees that are semantically equivalent
    but not syntactically identical without AC rules for min.
    """
    a, b, c, d = atom(1), atom(2), atom(3), atom(4)
    t = cut(tmin(a, b), tmin(c, d))

    # Path 1: Apply cut_min_left first
    p1_step1 = tmin(cut(a, tmin(c, d)), cut(b, tmin(c, d)))
    p1_step2 = tmin(tmin(cut(a, c), cut(a, d)), cut(b, tmin(c, d)))
    p1_step3 = tmin(tmin(cut(a, c), cut(a, d)), tmin(cut(b, c), cut(b, d)))

    # Path 2: Apply cut_min_right first
    p2_step1 = tmin(cut(tmin(a, b), c), cut(tmin(a, b), d))
    p2_step2 = tmin(tmin(cut(a, c), cut(b, c)), cut(tmin(a, b), d))
    p2_step3 = tmin(tmin(cut(a, c), cut(b, c)), tmin(cut(a, d), cut(b, d)))

    return {
        "original": t,
        "path1_final": p1_step3,
        "path2_final": p2_step3,
        "syntactically_equal": p1_step3 == p2_step3,
        "semantically_equal": evaluate(p1_step3) == evaluate(p2_step3),
        "original_cost": evaluate(t),
        "path1_cost": evaluate(p1_step3),
        "path2_cost": evaluate(p2_step3),
    }


# ============================================================
# Algorithm 7: Complexity Statistics
# ============================================================

def term_size(t: TropTerm) -> int:
    """Count nodes in a term."""
    if t.node_type == NodeType.ATOM:
        return 1
    return 1 + term_size(t.left) + term_size(t.right)


def normalization_stats(t: TropTerm) -> Dict:
    """Compute statistics about the normalization process."""
    nf, steps = normalize(t)
    return {
        "input_size": term_size(t),
        "input_cost": evaluate(t),
        "input_interp": polynomial_interp(t),
        "output_size": term_size(nf),
        "output_cost": evaluate(nf),
        "output_interp": polynomial_interp(nf),
        "reduction_steps": steps,
        "is_normal": is_normal(nf),
        "cost_preserved": evaluate(t) == evaluate(nf),
        "interp_decreased": polynomial_interp(nf) < polynomial_interp(t) if steps > 0 else True,
    }


if __name__ == "__main__":
    print("Tropical Curry-Howard: Algorithm Demonstrations")
    print("=" * 50)

    # Test basic algorithms
    t = cut(tmin(atom(1), atom(3)), tmin(atom(2), atom(4)))
    stats = normalization_stats(t)
    print(f"\nInput: {t}")
    for k, v in stats.items():
        print(f"  {k}: {v}")

    # Critical pair analysis
    print(f"\nCritical Pair Analysis:")
    cp = analyze_critical_pair()
    for k, v in cp.items():
        print(f"  {k}: {v}")
