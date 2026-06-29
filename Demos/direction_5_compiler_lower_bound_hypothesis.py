#!/usr/bin/env python3
"""
Compiler Lower Bound Theory — Applications

Demonstrates real-world applications of the compiler impossibility theorem:

1. Compiler Optimization Auditing: Check whether a proposed optimization
   pass could violate the depth lower bound.

2. Critical Path Analysis: Use EML depth as a lower bound on parallel
   execution time for transcendental computations.

3. Circuit Depth Estimation: Estimate minimum circuit depth for
   algebraic computations involving iterated exponentiation.

4. Optimization Budget Analysis: Quantify what optimizations CAN achieve
   (size reduction, constant folding) vs what they CANNOT (depth reduction).
"""

import math
from algorithms import (
    EMLExpr, NodeType, OptPass,
    build_canonical_iter_exp, iter_exp_value,
    cse_transform, const_fold_transform, alg_simp_transform,
    run_pipeline, verify_semantics, verify_lower_bound,
    STANDARD_PIPELINE, CSE_PASS, CONST_FOLD_PASS, ALG_SIMP_PASS,
)


# ============================================================
# Application 1: Compiler Optimization Auditing
# ============================================================

def audit_optimization_pass(pass_obj: OptPass, max_n: int = 8):
    """Audit an optimization pass against the depth lower bound.

    For each n from 1 to max_n, constructs the canonical iterExp(n)
    expression, applies the pass, and checks:
    1. Semantics are preserved
    2. Inverse-freeness is preserved
    3. EML depth remains ≥ n

    This is the computational counterpart of the formal theorem
    optPass_iterExp_depth_lower_bound.
    """
    print(f"\n  Auditing pass: {pass_obj.name}")
    print(f"  {'n':>4} {'orig_depth':>11} {'new_depth':>10} {'sem_ok':>7} "
          f"{'inv_free':>9} {'bound_ok':>9}")
    print(f"  {'─'*4} {'─'*11} {'─'*10} {'─'*7} {'─'*9} {'─'*9}")

    all_ok = True
    for n in range(1, max_n + 1):
        expr = build_canonical_iter_exp(n)
        result = pass_obj.apply(expr)

        sem_ok = verify_semantics(expr, result, [0.1, 0.5, 1.0])
        inv_ok = result.is_inverse_free()
        bound_ok = verify_lower_bound(n, result)
        all_ok = all_ok and sem_ok and inv_ok and bound_ok

        print(f"  {n:4d} {expr.eml_depth():11d} {result.eml_depth():10d} "
              f"{'✓' if sem_ok else '✗':>7} "
              f"{'✓' if inv_ok else '✗':>9} "
              f"{'✓' if bound_ok else '✗':>9}")

    print(f"\n  Overall: {'ALL CHECKS PASSED' if all_ok else 'SOME CHECKS FAILED'}")
    return all_ok


# ============================================================
# Application 2: Critical Path Analysis
# ============================================================

def critical_path_analysis(n: int):
    """Analyze the critical path for computing iterExp(n).

    The EML depth is a lower bound on the number of sequential
    transcendental operations required, regardless of:
    - Available parallelism
    - Memory/register allocation
    - Algebraic rewrites

    This has direct implications for parallel computation scheduling.
    """
    print(f"\n  Critical Path Analysis for iterExp({n})")
    print(f"  {'─' * 50}")

    expr = build_canonical_iter_exp(n)
    depth = expr.eml_depth()
    size = expr.size()

    print(f"  Minimum sequential transcendental ops: {depth}")
    print(f"  Total operations (tree): {size}")
    print(f"  Maximum parallelism ratio: {size / max(depth, 1):.2f}x")
    print()

    # Apply all optimizations
    result, metrics = run_pipeline(expr, STANDARD_PIPELINE)
    print(f"  After full optimization pipeline:")
    print(f"    EML depth: {result.eml_depth()} (lower bound: {n})")
    print(f"    Size: {result.size()}")
    print(f"    Depth reduction: {depth - result.eml_depth()}")
    print()

    # Theoretical minimum parallel time
    print(f"  Theoretical minimum parallel time:")
    print(f"    With P processors: ≥ {n} sequential exp operations")
    print(f"    This is provably optimal by the depth lower bound.")
    print(f"    No compiler optimization can reduce this below {n}.")


# ============================================================
# Application 3: Optimization Budget Analysis
# ============================================================

def optimization_budget_analysis():
    """Analyze what optimizations CAN vs CANNOT achieve.

    This demonstrates the fundamental asymmetry:
    - Size, sharing, constants: CAN be optimized
    - EML depth for iterExp: CANNOT be reduced below n
    """
    print("\n  Optimization Budget Analysis")
    print(f"  {'─' * 60}")
    print()

    # Build expressions with redundancy for optimization
    print("  Test: iterExp(3) with added redundancy")
    base = build_canonical_iter_exp(3)

    # Add some redundancy: wrap in neg(neg(...))
    redundant = EMLExpr(NodeType.NEG,
                        left=EMLExpr(NodeType.NEG, left=base))
    print(f"    Original:    depth={base.eml_depth()}, size={base.size()}")
    print(f"    With --:     depth={redundant.eml_depth()}, "
          f"size={redundant.size()}")

    # Apply algebraic simplification
    simplified = alg_simp_transform(redundant)
    print(f"    After simp:  depth={simplified.eml_depth()}, "
          f"size={simplified.size()}")
    print(f"    Size reduced: {redundant.size() - simplified.size()} nodes")
    print(f"    Depth maintained ≥ 3: {simplified.eml_depth() >= 3}")
    print()

    # Summary table
    print("  Summary: What CAN vs CANNOT change")
    print(f"  {'Metric':<25} {'Optimizable?':<15} {'Lower Bound':<15}")
    print(f"  {'─'*25} {'─'*15} {'─'*15}")
    print(f"  {'Node count (size)':<25} {'YES':<15} {'None fixed':<15}")
    print(f"  {'Constant expressions':<25} {'YES (fold)':<15} {'None fixed':<15}")
    print(f"  {'Double negations':<25} {'YES (simplify)':<15} {'None fixed':<15}")
    print(f"  {'DAG sharing':<25} {'YES (CSE)':<15} {'None fixed':<15}")
    print(f"  {'EML depth (iterExp n)':<25} {'NO':<15} {'n (proven)':<15}")


# ============================================================
# Application 4: Growth Rate Comparison
# ============================================================

def growth_rate_comparison():
    """Compare growth rates at different iterExp levels.

    Illustrates why depth separation is possible: each level of
    iterExp grows incomparably faster than the previous.
    """
    print("\n  Growth Rate Comparison")
    print(f"  {'─' * 60}")
    print()

    x_values = [0.1, 0.5, 1.0, 1.5, 2.0]
    max_n = 5

    print(f"  {'x':>6}", end="")
    for n in range(max_n + 1):
        print(f"  {'iterExp(' + str(n) + ')':>15}", end="")
    print()
    print(f"  {'─'*6}", end="")
    for _ in range(max_n + 1):
        print(f"  {'─'*15}", end="")
    print()

    for x in x_values:
        print(f"  {x:6.1f}", end="")
        for n in range(max_n + 1):
            val = iter_exp_value(n, x)
            if val < 1e10:
                print(f"  {val:15.4f}", end="")
            elif val < float('inf'):
                print(f"  {val:15.2e}", end="")
            else:
                print(f"  {'∞':>15}", end="")
        print()

    print()
    print("  Key insight: Each row shows that higher iterExp levels")
    print("  grow astronomically faster. This growth separation is")
    print("  the mathematical foundation of the depth lower bound.")


# ============================================================
# Main
# ============================================================

def main():
    print("=" * 70)
    print("COMPILER LOWER BOUND THEORY — APPLICATIONS")
    print("=" * 70)

    # Application 1
    print()
    print("─" * 70)
    print("APPLICATION 1: Compiler Optimization Auditing")
    print("─" * 70)
    for p in [CSE_PASS, CONST_FOLD_PASS, ALG_SIMP_PASS]:
        audit_optimization_pass(p)

    # Application 2
    print()
    print("─" * 70)
    print("APPLICATION 2: Critical Path Analysis")
    print("─" * 70)
    for n in [3, 5, 10]:
        critical_path_analysis(n)

    # Application 3
    print()
    print("─" * 70)
    print("APPLICATION 3: Optimization Budget Analysis")
    print("─" * 70)
    optimization_budget_analysis()

    # Application 4
    print()
    print("─" * 70)
    print("APPLICATION 4: Growth Rate Comparison")
    print("─" * 70)
    growth_rate_comparison()

    print()
    print("=" * 70)
    print("All applications demonstrate the central theorem:")
    print("Semantics-preserving, inverse-free-preserving optimization")
    print("passes CANNOT reduce EML depth below n for iterExp(n).")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Compiler Lower Bound Theory — Demonstration

This script demonstrates the formal impossibility theorem for compiler
optimization of iterated exponentials in the EML (Exp-Mul-Log) language.

Key finding: Semantics-preserving optimization passes that maintain
inverse-freeness CANNOT reduce the EML depth of programs computing
iterated exponentials below the inherent lower bound.
"""

import math
from dataclasses import dataclass
from typing import List, Optional, Callable
from enum import Enum, auto


# ============================================================
# EML Expression Tree
# ============================================================

class NodeType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EML = auto()  # eml(a, b) = a * exp(b)


@dataclass
class EMLExpr:
    """EML expression tree node."""
    node_type: NodeType
    value: Optional[float] = None  # For CONST nodes
    left: Optional['EMLExpr'] = None
    right: Optional['EMLExpr'] = None

    def eval(self, x: float) -> float:
        """Evaluate the expression at point x."""
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

    @property
    def eml_depth(self) -> int:
        """EML depth: counts maximum nesting of eml operations."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 0
        elif self.node_type in (NodeType.ADD, NodeType.MUL):
            return max(self.left.eml_depth, self.right.eml_depth)
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return self.left.eml_depth
        elif self.node_type == NodeType.EML:
            return 1 + max(self.left.eml_depth, self.right.eml_depth)
        return 0

    @property
    def exp_rank(self) -> int:
        """Exponential rank: syntactic invariant bounding growth rate."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 0
        elif self.node_type in (NodeType.ADD, NodeType.MUL):
            return max(self.left.exp_rank, self.right.exp_rank)
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return self.left.exp_rank
        elif self.node_type == NodeType.EML:
            return max(self.left.exp_rank, self.right.exp_rank + 1)
        return 0

    @property
    def size(self) -> int:
        """Total node count."""
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return 1
        elif self.node_type in (NodeType.NEG, NodeType.INV):
            return 1 + self.left.size
        else:
            return 1 + self.left.size + self.right.size

    @property
    def is_inverse_free(self) -> bool:
        """Check if expression contains no INV nodes."""
        if self.node_type == NodeType.INV:
            return False
        if self.node_type in (NodeType.VAR, NodeType.CONST):
            return True
        if self.node_type in (NodeType.NEG,):
            return self.left.is_inverse_free
        return self.left.is_inverse_free and self.right.is_inverse_free

    def __repr__(self):
        if self.node_type == NodeType.VAR:
            return "x"
        elif self.node_type == NodeType.CONST:
            return f"{self.value}"
        elif self.node_type == NodeType.ADD:
            return f"({self.left} + {self.right})"
        elif self.node_type == NodeType.MUL:
            return f"({self.left} * {self.right})"
        elif self.node_type == NodeType.NEG:
            return f"(-{self.left})"
        elif self.node_type == NodeType.INV:
            return f"(1/{self.left})"
        elif self.node_type == NodeType.EML:
            return f"eml({self.left}, {self.right})"
        return "?"


# ============================================================
# Canonical Construction
# ============================================================

def iter_exp(n: int, x: float) -> float:
    """Compute iterExp n x = exp^n(x)."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def canonical_iter_exp_expr(n: int) -> EMLExpr:
    """Build the canonical EML expression for iterExp n:
    eml(1, eml(1, ... eml(1, x)...)) with n nested eml layers."""
    if n == 0:
        return EMLExpr(NodeType.VAR)
    return EMLExpr(NodeType.EML,
                   left=EMLExpr(NodeType.CONST, value=1.0),
                   right=canonical_iter_exp_expr(n - 1))


# ============================================================
# Optimization Passes
# ============================================================

def cse_transform(e: EMLExpr) -> EMLExpr:
    """Common Subexpression Elimination (identity on trees)."""
    return e


def const_fold_transform(e: EMLExpr) -> EMLExpr:
    """Constant folding: fold constant subexpressions."""
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
            return EMLExpr(NodeType.CONST, value=1.0/child.value)
        return EMLExpr(NodeType.INV, left=child)
    left = const_fold_transform(e.left)
    right = const_fold_transform(e.right)
    if left.node_type == NodeType.CONST and right.node_type == NodeType.CONST:
        if e.node_type == NodeType.ADD:
            return EMLExpr(NodeType.CONST, value=left.value + right.value)
        elif e.node_type == NodeType.MUL:
            return EMLExpr(NodeType.CONST, value=left.value * right.value)
        elif e.node_type == NodeType.EML:
            try:
                return EMLExpr(NodeType.CONST,
                               value=left.value * math.exp(right.value))
            except OverflowError:
                pass
    return EMLExpr(e.node_type, left=left, right=right)


def alg_simp_transform(e: EMLExpr) -> EMLExpr:
    """Algebraic simplification: eliminate double negation."""
    if e.node_type in (NodeType.VAR, NodeType.CONST):
        return e
    if e.node_type == NodeType.NEG:
        child = alg_simp_transform(e.left)
        if child.node_type == NodeType.NEG:
            return child.left  # --a = a
        return EMLExpr(NodeType.NEG, left=child)
    if e.node_type in (NodeType.INV,):
        return EMLExpr(e.node_type, left=alg_simp_transform(e.left))
    left = alg_simp_transform(e.left)
    right = alg_simp_transform(e.right)
    return EMLExpr(e.node_type, left=left, right=right)


def run_pipeline(expr: EMLExpr, passes: List[Callable]) -> EMLExpr:
    """Run a pipeline of optimization passes."""
    result = expr
    for p in passes:
        result = p(result)
    return result


# ============================================================
# Demonstration
# ============================================================

def demonstrate_single_pass(n: int, pass_name: str, transform: Callable):
    """Show the effect of a single pass on iterExp n."""
    expr = canonical_iter_exp_expr(n)
    transformed = transform(expr)

    print(f"\n  {pass_name}:")
    print(f"    Original:    depth={expr.eml_depth}, size={expr.size}, "
          f"inv_free={expr.is_inverse_free}")
    print(f"    Transformed: depth={transformed.eml_depth}, "
          f"size={transformed.size}, inv_free={transformed.is_inverse_free}")

    # Verify semantics on sample inputs
    test_points = [0.1, 0.5, 1.0]
    all_match = True
    for x in test_points:
        orig_val = expr.eval(x)
        trans_val = transformed.eval(x)
        if abs(orig_val - trans_val) > 1e-10 * max(abs(orig_val), 1):
            all_match = False
            break
    print(f"    Semantics preserved: {all_match}")
    print(f"    Depth ≥ n = {n}: {transformed.eml_depth >= n} "
          f"(depth = {transformed.eml_depth})")


def main():
    print("=" * 70)
    print("COMPILER LOWER BOUND THEORY — DEMONSTRATION")
    print("=" * 70)
    print()
    print("Theorem: For any semantics-preserving optimization pass that")
    print("preserves inverse-freeness, the transformed output of an")
    print("iterExp(n) program has EML depth at least n.")
    print()

    # Part 1: Canonical constructions
    print("-" * 70)
    print("Part 1: Canonical iterExp constructions")
    print("-" * 70)
    for n in range(6):
        expr = canonical_iter_exp_expr(n)
        val_at_1 = expr.eval(0.5)
        print(f"  iterExp({n}): depth={expr.eml_depth}, "
              f"size={expr.size}, expRank={expr.exp_rank}, "
              f"eval(0.5)={val_at_1:.6f}")

    # Part 2: Individual passes
    print()
    print("-" * 70)
    print("Part 2: Individual optimization passes on iterExp(n)")
    print("-" * 70)

    passes = [
        ("CSE", cse_transform),
        ("Constant Folding", const_fold_transform),
        ("Algebraic Simplification", alg_simp_transform),
    ]

    for n in [1, 2, 3, 4, 5]:
        print(f"\n  === iterExp({n}) ===")
        for name, transform in passes:
            demonstrate_single_pass(n, name, transform)

    # Part 3: Pipeline
    print()
    print("-" * 70)
    print("Part 3: Full pipeline (CSE → ConstFold → AlgSimp)")
    print("-" * 70)

    pipeline = [cse_transform, const_fold_transform, alg_simp_transform]

    for n in range(1, 8):
        expr = canonical_iter_exp_expr(n)
        result = run_pipeline(expr, pipeline)
        print(f"  iterExp({n}): "
              f"orig_depth={expr.eml_depth}, "
              f"pipeline_depth={result.eml_depth}, "
              f"orig_size={expr.size}, "
              f"pipeline_size={result.size}, "
              f"depth ≥ n: {result.eml_depth >= n}")

    # Part 4: Asymmetry demonstration
    print()
    print("-" * 70)
    print("Part 4: The key asymmetry — what CAN vs CANNOT change")
    print("-" * 70)
    print()
    print("  Size can decrease:        YES (constant folding, CSE)")
    print("  Sharing can increase:     YES (CSE on DAGs)")
    print("  Constants can fold:       YES (constant folding)")
    print("  Double negation removed:  YES (algebraic simplification)")
    print("  EML depth reduced below n: NO! (proven impossible)")
    print()
    print("This is the fundamental asymmetry: optimization passes can")
    print("improve many structural metrics, but CANNOT break the")
    print("intrinsic depth barrier for iterated exponentials.")

    # Part 5: Growth rate illustration
    print()
    print("-" * 70)
    print("Part 5: Growth rates of iterExp (why depth matters)")
    print("-" * 70)
    x = 1.0
    print(f"\n  Values at x = {x}:")
    for n in range(7):
        val = iter_exp(n, x)
        if val < 1e20:
            print(f"    iterExp({n}, {x}) = {val:.6f}")
        else:
            print(f"    iterExp({n}, {x}) = {val:.2e}")

    print()
    print("  Each level of iterExp grows incomparably faster than the")
    print("  previous. This growth separation is what makes the depth")
    print("  lower bound possible — and why no optimizer can beat it.")

    # Part 6: Pipeline composition
    print()
    print("-" * 70)
    print("Part 6: Repeated pipeline application")
    print("-" * 70)
    n = 4
    expr = canonical_iter_exp_expr(n)
    print(f"\n  Starting with iterExp({n}), depth = {expr.eml_depth}")
    current = expr
    for iteration in range(1, 6):
        current = run_pipeline(current, pipeline)
        print(f"  After {iteration} pipeline iterations: "
              f"depth = {current.eml_depth}, size = {current.size}")
    print(f"\n  No matter how many times we apply the pipeline,")
    print(f"  depth stays ≥ {n}. This is the composition theorem in action.")

    print()
    print("=" * 70)
    print("CONCLUSION: The depth barrier is provably unbreakable.")
    print("=" * 70)


if __name__ == "__main__":
    main()
