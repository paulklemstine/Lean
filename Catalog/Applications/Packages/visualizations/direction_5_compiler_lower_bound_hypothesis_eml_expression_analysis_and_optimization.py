#!/usr/bin/env python3
"""
Compiler Lower Bound Theory — Algorithms

Implements the core algorithms for EML expression analysis and optimization:
1. EML expression construction and evaluation
2. Depth and rank computation
3. Optimization passes (CSE, constant folding, algebraic simplification)
4. Pipeline composition and execution
5. Growth bound verification

These algorithms correspond directly to the formal definitions in
CompilerLowerBound/Defs.lean and CompilerLowerBound/Theorems.lean.
"""

import math
from dataclasses import dataclass, field
from typing import List, Optional, Callable, Tuple, Dict
from enum import Enum, auto


# ============================================================
# Core Data Structures
# ============================================================

class NodeType(Enum):
    """EML expression node types."""
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EML = auto()


@dataclass
class EMLExpr:
    """EML expression tree.

    Represents expressions in the EML language where transcendence enters
    only through eml(a, b) = a * exp(b).

    Attributes:
        node_type: The type of this node
        value: For CONST nodes, the constant value
        left: Left child (or only child for unary ops)
        right: Right child (for binary ops)
    """
    node_type: NodeType
    value: Optional[float] = None
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None

    def eval(self, x: float) -> float:
        """Evaluate the expression at point x.

        Time complexity: O(size) where size is the number of nodes.
        Space complexity: O(depth) for the recursion stack.
        """
        if self.node_type == NodeType.VAR:
            return x
        elif self.node_type == NodeType.CONST:
            return self.value
        elif self.node_type == NodeType.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.node_type == NodeType.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.node_type == NodeType.NEG:
            return -self.left.eval(x)
        elif self.node_type == NodeType.INV:
            v = self.left.eval(x)
            return 1.0 / v if v != 0 else float('inf')
        elif self.node_type == NodeType.EML:
            a = self.left.eval(x)
            b = self.right.eval(x)
            try:
                return a * math.exp(b)
            except OverflowError:
                return float('inf')
        raise ValueError(f"Unknown node type: {self.node_type}")

    def eml_depth(self) -> int:
        """Compute EML depth: max nesting of eml operations.

        This is the key complexity measure. Field operations (add, mul, neg, inv)
        do not increase it; only eml nodes do.

        Time complexity: O(size)
        """
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 0
        elif self.node_type in (NodeType.ADD, NodeType.MUL):
            return max(self.left.eml_depth(), self.right.eml_depth())
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return self.left.eml_depth()
        elif self.node_type == NodeType.EML:
            return 1 + max(self.left.eml_depth(), self.right.eml_depth())
        return 0

    def exp_rank(self) -> int:
        """Compute exponential rank: syntactic growth rate invariant.

        For eml(a, b) = a * exp(b), the rank is max(rank(a), rank(b) + 1)
        because b is inside an exponential. This bounds how fast the
        expression can grow.

        Invariant: exp_rank(e) <= eml_depth(e) for all e.

        Time complexity: O(size)
        """
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 0
        elif self.node_type in (NodeType.ADD, NodeType.MUL):
            return max(self.left.exp_rank(), self.right.exp_rank())
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return self.left.exp_rank()
        elif self.node_type == NodeType.EML:
            return max(self.left.exp_rank(), self.right.exp_rank() + 1)
        return 0

    def size(self) -> int:
        """Total node count. Time: O(size)."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 1
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return 1 + self.left.size()
        else:
            return 1 + self.left.size() + self.right.size()

    def is_inverse_free(self) -> bool:
        """Check if expression contains no INV nodes. Time: O(size)."""
        if self.node_type == NodeType.INV:
            return False
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return True
        if self.node_type == NodeType.NEG:
            return self.left.is_inverse_free()
        return (self.left.is_inverse_free() and
                self.right.is_inverse_free())


# ============================================================
# Algorithm 1: Canonical iterExp Construction
# ============================================================

def iter_exp_value(n: int, x: float) -> float:
    """Compute iterExp(n, x) = exp^n(x).

    Args:
        n: Number of exponential layers
        x: Input value

    Returns:
        exp(exp(...exp(x)...)) with n layers

    Time complexity: O(n)
    Space complexity: O(1)
    """
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def build_canonical_iter_exp(n: int) -> EMLExpr:
    """Build the canonical EML expression for iterExp(n).

    Constructs eml(1, eml(1, ... eml(1, x)...)) with n nested eml layers.
    This has eml_depth = n and size = 2n + 1.

    Args:
        n: Nesting depth

    Returns:
        Canonical EMLExpr with eml_depth = n

    Time complexity: O(n)
    Space complexity: O(n)
    """
    if n == 0:
        return EMLExpr(NodeType.VAR)
    return EMLExpr(NodeType.EML,
                   left=EMLExpr(NodeType.CONST, value=1.0),
                   right=build_canonical_iter_exp(n - 1))


# ============================================================
# Algorithm 2: CSE (Common Subexpression Elimination)
# ============================================================

def cse_transform(e: EMLExpr) -> EMLExpr:
    """Common Subexpression Elimination.

    In a tree representation, CSE is the identity since there's no
    sharing to exploit. In a DAG representation, it would identify
    structurally equal subtrees and merge them.

    Preserves: semantics, inverse-freeness, eml_depth
    May reduce: size (in DAG representation)

    Time complexity: O(1) for trees, O(size * log(size)) for DAGs
    """
    return e


# ============================================================
# Algorithm 3: Constant Folding
# ============================================================

def const_fold_transform(e: EMLExpr) -> EMLExpr:
    """Constant Folding: evaluate constant subexpressions at compile time.

    Recursively simplifies expressions where both operands are constants.
    For example: add(const(2), const(3)) → const(5).

    Preserves: semantics, inverse-freeness
    May reduce: size, eml_depth (by collapsing constant chains)
    Cannot reduce: eml_depth below n for iterExp(n) programs

    Time complexity: O(size)
    Space complexity: O(depth) for recursion
    """
    if e.node_type in (NodeType.VAR, NodeType.CONST):
        return e

    if e.node_type == NodeType.NEG:
        child = const_fold_transform(e.left)
        if child.node_type == NodeType.CONST:
            return EMLExpr(NodeType.CONST, value=-child.value)
        return EMLExpr(NodeType.NEG, left=child)

    if e.node_type == NodeType.INV:
        child = const_fold_transform(e.left)
        if child.node_type == NodeType.CONST and child.value != 0:
            return EMLExpr(NodeType.CONST, value=1.0 / child.value)
        return EMLExpr(NodeType.INV, left=child)

    left = const_fold_transform(e.left)
    right = const_fold_transform(e.right)

    if (left.node_type == NodeType.CONST and
            right.node_type == NodeType.CONST):
        if e.node_type == NodeType.ADD:
            return EMLExpr(NodeType.CONST,
                           value=left.value + right.value)
        elif e.node_type == NodeType.MUL:
            return EMLExpr(NodeType.CONST,
                           value=left.value * right.value)
        elif e.node_type == NodeType.EML:
            try:
                val = left.value * math.exp(right.value)
                return EMLExpr(NodeType.CONST, value=val)
            except OverflowError:
                pass

    return EMLExpr(e.node_type, left=left, right=right)


# ============================================================
# Algorithm 4: Algebraic Simplification
# ============================================================

def alg_simp_transform(e: EMLExpr) -> EMLExpr:
    """Algebraic Simplification: apply basic algebraic identities.

    Currently implements:
    - Double negation elimination: neg(neg(a)) → a

    Preserves: semantics, inverse-freeness
    May reduce: size, depth
    Cannot reduce: eml_depth below n for iterExp(n) programs

    Time complexity: O(size)
    Space complexity: O(depth) for recursion
    """
    if e.node_type in (NodeType.VAR, NodeType.CONST):
        return e

    if e.node_type == NodeType.NEG:
        child = alg_simp_transform(e.left)
        if child.node_type == NodeType.NEG:
            return child.left
        return EMLExpr(NodeType.NEG, left=child)

    if e.node_type == NodeType.INV:
        return EMLExpr(NodeType.INV, left=alg_simp_transform(e.left))

    left = alg_simp_transform(e.left)
    right = alg_simp_transform(e.right)
    return EMLExpr(e.node_type, left=left, right=right)


# ============================================================
# Algorithm 5: Pipeline Composition
# ============================================================

@dataclass
class OptPass:
    """An optimization pass with name and transform function.

    The formal version (in Lean) also bundles proofs of:
    - semantics preservation
    - inverse-freeness preservation
    """
    name: str
    transform: Callable[[EMLExpr], EMLExpr]

    def apply(self, e: EMLExpr) -> EMLExpr:
        return self.transform(e)


def run_pipeline(expr: EMLExpr,
                 passes: List[OptPass]) -> Tuple[EMLExpr, List[Dict]]:
    """Run a pipeline of optimization passes, tracking metrics.

    Args:
        expr: Input expression
        passes: List of optimization passes to apply

    Returns:
        Tuple of (final expression, list of per-step metrics)

    Time complexity: O(sum of pass complexities)
    """
    metrics = []
    current = expr
    metrics.append({
        'step': 'input',
        'eml_depth': current.eml_depth(),
        'size': current.size(),
        'exp_rank': current.exp_rank(),
        'inverse_free': current.is_inverse_free(),
    })

    for p in passes:
        current = p.apply(current)
        metrics.append({
            'step': p.name,
            'eml_depth': current.eml_depth(),
            'size': current.size(),
            'exp_rank': current.exp_rank(),
            'inverse_free': current.is_inverse_free(),
        })

    return current, metrics


# ============================================================
# Standard Pass Instances
# ============================================================

CSE_PASS = OptPass("CSE", cse_transform)
CONST_FOLD_PASS = OptPass("ConstFold", const_fold_transform)
ALG_SIMP_PASS = OptPass("AlgSimp", alg_simp_transform)

STANDARD_PIPELINE = [CSE_PASS, CONST_FOLD_PASS, ALG_SIMP_PASS]


# ============================================================
# Verification Utilities
# ============================================================

def verify_semantics(original: EMLExpr, transformed: EMLExpr,
                     test_points: List[float] = None,
                     tolerance: float = 1e-10) -> bool:
    """Verify that two expressions agree on test points.

    Args:
        original: Original expression
        transformed: Transformed expression
        test_points: Points to test (default: [0.1, 0.5, 1.0, 2.0])
        tolerance: Relative tolerance for comparison

    Returns:
        True if expressions agree on all test points
    """
    if test_points is None:
        test_points = [0.1, 0.5, 1.0, 2.0]

    for x in test_points:
        orig_val = original.eval(x)
        trans_val = transformed.eval(x)
        if orig_val == float('inf') and trans_val == float('inf'):
            continue
        if abs(orig_val - trans_val) > tolerance * max(abs(orig_val), 1):
            return False
    return True


def verify_lower_bound(n: int, expr: EMLExpr) -> bool:
    """Verify that an expression computing iterExp(n) has eml_depth ≥ n.

    This is the computational check corresponding to the formal theorem
    optPass_iterExp_depth_lower_bound.
    """
    return expr.eml_depth() >= n


if __name__ == "__main__":
    # Example usage
    print("Building canonical iterExp expressions:")
    for n in range(6):
        e = build_canonical_iter_exp(n)
        print(f"  n={n}: depth={e.eml_depth()}, rank={e.exp_rank()}, "
              f"size={e.size()}, inv_free={e.is_inverse_free()}")

    print("\nRunning standard pipeline on iterExp(3):")
    expr = build_canonical_iter_exp(3)
    result, metrics = run_pipeline(expr, STANDARD_PIPELINE)
    for m in metrics:
        print(f"  {m['step']:>12}: depth={m['eml_depth']}, "
              f"size={m['size']}, rank={m['exp_rank']}")

    print(f"\nLower bound verified: {verify_lower_bound(3, result)}")
    print(f"Semantics preserved: {verify_semantics(expr, result)}")
