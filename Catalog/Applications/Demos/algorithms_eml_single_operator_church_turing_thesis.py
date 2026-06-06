#!/usr/bin/env python3
"""
EML Single-Operator Compilation: Core Algorithms

Type-hinted implementations of the compilation, decompilation,
and analysis algorithms for the EML Church-Turing thesis.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, Union
import math


# ============================================================
# Expression AST Types
# ============================================================

@dataclass(frozen=True)
class UVar:
    """Variable node in UExpr."""
    pass

@dataclass(frozen=True)
class UConst:
    """Constant node in UExpr."""
    value: float

@dataclass(frozen=True)
class UBinOp:
    """Binary operation in UExpr."""
    op: str  # 'add', 'sub', 'mul', 'div'
    left: UExpr
    right: UExpr

@dataclass(frozen=True)
class UExp:
    """Exponential node in UExpr."""
    arg: UExpr

@dataclass(frozen=True)
class ULog:
    """Logarithm node in UExpr."""
    arg: UExpr

UExpr = Union[UVar, UConst, UBinOp, UExp, ULog]


@dataclass(frozen=True)
class EVar:
    """Variable node in EMLExpr."""
    pass

@dataclass(frozen=True)
class EConst:
    """Constant node in EMLExpr."""
    value: float

@dataclass(frozen=True)
class EBinOp:
    """Binary operation in EMLExpr (add, sub, mul, div)."""
    op: str
    left: EMLExpr
    right: EMLExpr

@dataclass(frozen=True)
class EEML:
    """The eml primitive: eml(x, y) = exp(x) - log(y)."""
    left: EMLExpr
    right: EMLExpr

EMLExpr = Union[EVar, EConst, EBinOp, EEML]


# ============================================================
# Algorithm 1: Compilation (UExpr → EMLExpr)
# ============================================================

def compile_to_eml(expr: UExpr) -> EMLExpr:
    """
    Compile a UExpr to an EMLExpr using eml as the sole transcendental primitive.

    Key translations:
    - exp(e) → eml(compile(e), 1)     [since eml(x,1) = exp(x) - log(1) = exp(x)]
    - log(e) → 1 - eml(0, compile(e)) [since eml(0,y) = exp(0) - log(y) = 1 - log(y)]

    Complexity: O(n) time and space, where n = size of input expression.
    Size bound: output size ≤ 4 × input size.
    Rank: output eml_rank = input transcendence_rank (exact).
    """
    if isinstance(expr, UVar):
        return EVar()
    elif isinstance(expr, UConst):
        return EConst(expr.value)
    elif isinstance(expr, UBinOp):
        return EBinOp(expr.op, compile_to_eml(expr.left), compile_to_eml(expr.right))
    elif isinstance(expr, UExp):
        # exp(e) = eml(e, 1)
        return EEML(compile_to_eml(expr.arg), EConst(1.0))
    elif isinstance(expr, ULog):
        # log(e) = 1 - eml(0, e)
        return EBinOp('sub', EConst(1.0), EEML(EConst(0.0), compile_to_eml(expr.arg)))
    else:
        raise TypeError(f"Unknown UExpr type: {type(expr)}")


# ============================================================
# Algorithm 2: Decompilation (EMLExpr → UExpr)
# ============================================================

def decompile_from_eml(expr: EMLExpr) -> UExpr:
    """
    Decompile an EMLExpr back to a UExpr by expanding each eml node.

    Key translation:
    - eml(e1, e2) → exp(decompile(e1)) - log(decompile(e2))

    Complexity: O(n) time and space.
    Size bound: output size ≤ 3 × input size.
    Rank: output transcendence_rank = 2 × input eml_rank.
    """
    if isinstance(expr, EVar):
        return UVar()
    elif isinstance(expr, EConst):
        return UConst(expr.value)
    elif isinstance(expr, EBinOp):
        return UBinOp(expr.op, decompile_from_eml(expr.left), decompile_from_eml(expr.right))
    elif isinstance(expr, EEML):
        # eml(e1, e2) = exp(e1) - log(e2)
        return UBinOp('sub', UExp(decompile_from_eml(expr.left)),
                       ULog(decompile_from_eml(expr.right)))
    else:
        raise TypeError(f"Unknown EMLExpr type: {type(expr)}")


# ============================================================
# Algorithm 3: Partial Evaluation
# ============================================================

def eval_uexpr(expr: UExpr, x: float) -> Optional[float]:
    """Evaluate a UExpr at x, returning None for undefined operations."""
    if isinstance(expr, UVar):
        return x
    elif isinstance(expr, UConst):
        return expr.value
    elif isinstance(expr, UBinOp):
        v1 = eval_uexpr(expr.left, x)
        v2 = eval_uexpr(expr.right, x)
        if v1 is None or v2 is None:
            return None
        if expr.op == 'add': return v1 + v2
        if expr.op == 'sub': return v1 - v2
        if expr.op == 'mul': return v1 * v2
        if expr.op == 'div':
            return v1 / v2 if v2 != 0 else None
    elif isinstance(expr, UExp):
        v = eval_uexpr(expr.arg, x)
        if v is not None:
            try:
                return math.exp(v)
            except OverflowError:
                return float('inf')
        return None
    elif isinstance(expr, ULog):
        v = eval_uexpr(expr.arg, x)
        return math.log(v) if v is not None and v > 0 else None
    return None


def eval_emlexpr(expr: EMLExpr, x: float) -> Optional[float]:
    """Evaluate an EMLExpr at x, returning None for undefined operations."""
    if isinstance(expr, EVar):
        return x
    elif isinstance(expr, EConst):
        return expr.value
    elif isinstance(expr, EBinOp):
        v1 = eval_emlexpr(expr.left, x)
        v2 = eval_emlexpr(expr.right, x)
        if v1 is None or v2 is None:
            return None
        if expr.op == 'add': return v1 + v2
        if expr.op == 'sub': return v1 - v2
        if expr.op == 'mul': return v1 * v2
        if expr.op == 'div':
            return v1 / v2 if v2 != 0 else None
    elif isinstance(expr, EEML):
        v1 = eval_emlexpr(expr.left, x)
        v2 = eval_emlexpr(expr.right, x)
        if v1 is not None and v2 is not None and v2 > 0:
            try:
                return math.exp(v1) - math.log(v2)
            except OverflowError:
                return float('inf')
        return None
    return None


# ============================================================
# Algorithm 4: Expression Metrics
# ============================================================

def expr_size(expr: Union[UExpr, EMLExpr]) -> int:
    """Count nodes in expression tree."""
    if isinstance(expr, (UVar, EVar, UConst, EConst)):
        return 1
    elif isinstance(expr, UBinOp):
        return 1 + expr_size(expr.left) + expr_size(expr.right)
    elif isinstance(expr, EBinOp):
        return 1 + expr_size(expr.left) + expr_size(expr.right)
    elif isinstance(expr, (UExp, ULog)):
        return 1 + expr_size(expr.arg)
    elif isinstance(expr, EEML):
        return 1 + expr_size(expr.left) + expr_size(expr.right)
    return 0


def transcendence_rank(expr: UExpr) -> int:
    """Count exp/log nodes in UExpr."""
    if isinstance(expr, (UVar, UConst)):
        return 0
    elif isinstance(expr, UBinOp):
        return transcendence_rank(expr.left) + transcendence_rank(expr.right)
    elif isinstance(expr, (UExp, ULog)):
        return 1 + transcendence_rank(expr.arg)
    return 0


def eml_rank(expr: EMLExpr) -> int:
    """Count eml nodes in EMLExpr."""
    if isinstance(expr, (EVar, EConst)):
        return 0
    elif isinstance(expr, EBinOp):
        return eml_rank(expr.left) + eml_rank(expr.right)
    elif isinstance(expr, EEML):
        return 1 + eml_rank(expr.left) + eml_rank(expr.right)
    return 0


def expr_depth(expr: Union[UExpr, EMLExpr]) -> int:
    """Compute depth of expression tree."""
    if isinstance(expr, (UVar, EVar, UConst, EConst)):
        return 0
    elif isinstance(expr, UBinOp):
        return 1 + max(expr_depth(expr.left), expr_depth(expr.right))
    elif isinstance(expr, EBinOp):
        return 1 + max(expr_depth(expr.left), expr_depth(expr.right))
    elif isinstance(expr, (UExp, ULog)):
        return 1 + expr_depth(expr.arg)
    elif isinstance(expr, EEML):
        return 1 + max(expr_depth(expr.left), expr_depth(expr.right))
    return 0


# ============================================================
# Algorithm 5: Verification
# ============================================================

def verify_compilation_correctness(
    expr: UExpr,
    test_points: list[float],
    tolerance: float = 1e-10
) -> tuple[bool, list[str]]:
    """
    Verify that compile(expr) is semantically equivalent to expr
    at the given test points.

    Returns (success, messages).
    """
    compiled = compile_to_eml(expr)
    messages = []
    all_ok = True

    for x in test_points:
        v_orig = eval_uexpr(expr, x)
        v_comp = eval_emlexpr(compiled, x)

        if v_orig is None and v_comp is None:
            messages.append(f"  x={x}: both undefined ✓")
        elif v_orig is not None and v_comp is not None:
            if abs(v_orig - v_comp) <= tolerance:
                messages.append(f"  x={x}: {v_orig:.8f} == {v_comp:.8f} ✓")
            else:
                messages.append(f"  x={x}: {v_orig:.8f} != {v_comp:.8f} ✗")
                all_ok = False
        else:
            messages.append(f"  x={x}: orig={v_orig}, comp={v_comp} ✗ (definedness mismatch)")
            all_ok = False

    return all_ok, messages


if __name__ == "__main__":
    # Quick self-test
    expr = UBinOp('add', UExp(UVar()), ULog(UVar()))
    compiled = compile_to_eml(expr)
    decompiled = decompile_from_eml(compiled)

    print(f"Original:    {expr}")
    print(f"Compiled:    {compiled}")
    print(f"Decompiled:  {decompiled}")
    print(f"Size: {expr_size(expr)} → {expr_size(compiled)} → {expr_size(decompiled)}")
    print(f"Rank: {transcendence_rank(expr)} → {eml_rank(compiled)}")

    ok, msgs = verify_compilation_correctness(expr, [0.5, 1.0, 2.0, 5.0])
    print(f"\nVerification: {'PASS' if ok else 'FAIL'}")
    for m in msgs:
        print(m)
