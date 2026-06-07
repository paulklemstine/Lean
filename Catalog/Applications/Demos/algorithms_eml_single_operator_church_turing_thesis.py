#!/usr/bin/env python3
"""
EML Single Operator Church-Turing Thesis: Algorithms

Type-hinted implementations of the EML compiler and related algorithms.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, Callable
import math


# ============================================================
# §1. Expression Types
# ============================================================

class UExpr:
    """Source expression with separate exp and log nodes."""
    pass

@dataclass
class Var(UExpr):
    """The variable x."""
    pass

@dataclass 
class Const(UExpr):
    """A real constant."""
    value: float

@dataclass
class Add(UExpr):
    left: UExpr
    right: UExpr

@dataclass
class Sub(UExpr):
    left: UExpr
    right: UExpr

@dataclass
class Mul(UExpr):
    left: UExpr
    right: UExpr

@dataclass
class Div(UExpr):
    left: UExpr
    right: UExpr

@dataclass
class Exp(UExpr):
    arg: UExpr

@dataclass
class Log(UExpr):
    arg: UExpr


class EMLExpr:
    """Target expression with eml as sole transcendental primitive."""
    pass

@dataclass
class EVar(EMLExpr):
    pass

@dataclass
class EConst(EMLExpr):
    value: float

@dataclass
class EAdd(EMLExpr):
    left: EMLExpr
    right: EMLExpr

@dataclass
class ESub(EMLExpr):
    left: EMLExpr
    right: EMLExpr

@dataclass
class EMul(EMLExpr):
    left: EMLExpr
    right: EMLExpr

@dataclass
class EDiv(EMLExpr):
    left: EMLExpr
    right: EMLExpr

@dataclass
class EML(EMLExpr):
    """eml(left, right) = exp(left) - log(right)"""
    left: EMLExpr
    right: EMLExpr


# ============================================================
# §2. The Compiler
# ============================================================

def compile_to_eml(expr: UExpr) -> EMLExpr:
    """
    Compile a UExpr to an equivalent EMLExpr.
    
    Translation rules:
    - exp(e) → eml(compile(e), const(1))        [since exp(x) = eml(x, 1)]
    - log(e) → sub(const(1), eml(const(0), compile(e)))  [since log(y) = 1 - eml(0, y)]
    - All other nodes preserved structurally.
    
    Time complexity: O(|expr|)
    Space complexity: O(|expr|)
    """
    if isinstance(expr, Var):
        return EVar()
    elif isinstance(expr, Const):
        return EConst(expr.value)
    elif isinstance(expr, Add):
        return EAdd(compile_to_eml(expr.left), compile_to_eml(expr.right))
    elif isinstance(expr, Sub):
        return ESub(compile_to_eml(expr.left), compile_to_eml(expr.right))
    elif isinstance(expr, Mul):
        return EMul(compile_to_eml(expr.left), compile_to_eml(expr.right))
    elif isinstance(expr, Div):
        return EDiv(compile_to_eml(expr.left), compile_to_eml(expr.right))
    elif isinstance(expr, Exp):
        # exp(e) = eml(e, 1)
        return EML(compile_to_eml(expr.arg), EConst(1.0))
    elif isinstance(expr, Log):
        # log(e) = 1 - eml(0, e)
        return ESub(EConst(1.0), EML(EConst(0.0), compile_to_eml(expr.arg)))
    else:
        raise ValueError(f"Unknown expression type: {type(expr)}")


# ============================================================
# §3. Evaluation
# ============================================================

def eval_uexpr(expr: UExpr, x: float) -> Optional[float]:
    """Evaluate a UExpr at x. Returns None on domain errors."""
    if isinstance(expr, Var):
        return x
    elif isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Add):
        l = eval_uexpr(expr.left, x)
        r = eval_uexpr(expr.right, x)
        return l + r if l is not None and r is not None else None
    elif isinstance(expr, Sub):
        l = eval_uexpr(expr.left, x)
        r = eval_uexpr(expr.right, x)
        return l - r if l is not None and r is not None else None
    elif isinstance(expr, Mul):
        l = eval_uexpr(expr.left, x)
        r = eval_uexpr(expr.right, x)
        return l * r if l is not None and r is not None else None
    elif isinstance(expr, Div):
        l = eval_uexpr(expr.left, x)
        r = eval_uexpr(expr.right, x)
        if l is None or r is None or r == 0:
            return None
        return l / r
    elif isinstance(expr, Exp):
        v = eval_uexpr(expr.arg, x)
        if v is None:
            return None
        try:
            return math.exp(v)
        except OverflowError:
            return None
    elif isinstance(expr, Log):
        v = eval_uexpr(expr.arg, x)
        if v is None or v <= 0:
            return None
        return math.log(v)
    return None


def eval_emlexpr(expr: EMLExpr, x: float) -> Optional[float]:
    """Evaluate an EMLExpr at x. Returns None on domain errors."""
    if isinstance(expr, EVar):
        return x
    elif isinstance(expr, EConst):
        return expr.value
    elif isinstance(expr, EAdd):
        l = eval_emlexpr(expr.left, x)
        r = eval_emlexpr(expr.right, x)
        return l + r if l is not None and r is not None else None
    elif isinstance(expr, ESub):
        l = eval_emlexpr(expr.left, x)
        r = eval_emlexpr(expr.right, x)
        return l - r if l is not None and r is not None else None
    elif isinstance(expr, EMul):
        l = eval_emlexpr(expr.left, x)
        r = eval_emlexpr(expr.right, x)
        return l * r if l is not None and r is not None else None
    elif isinstance(expr, EDiv):
        l = eval_emlexpr(expr.left, x)
        r = eval_emlexpr(expr.right, x)
        if l is None or r is None or r == 0:
            return None
        return l / r
    elif isinstance(expr, EML):
        l = eval_emlexpr(expr.left, x)
        r = eval_emlexpr(expr.right, x)
        if l is None or r is None or r <= 0:
            return None
        try:
            return math.exp(l) - math.log(r)
        except OverflowError:
            return None
    return None


# ============================================================
# §4. Complexity Measures
# ============================================================

def size_uexpr(expr: UExpr) -> int:
    """Count nodes in a UExpr."""
    if isinstance(expr, (Var, Const)):
        return 1
    elif isinstance(expr, (Add, Sub, Mul, Div)):
        return 1 + size_uexpr(expr.left) + size_uexpr(expr.right)
    elif isinstance(expr, (Exp, Log)):
        return 1 + size_uexpr(expr.arg)
    return 0

def size_emlexpr(expr: EMLExpr) -> int:
    """Count nodes in an EMLExpr."""
    if isinstance(expr, (EVar, EConst)):
        return 1
    elif isinstance(expr, (EAdd, ESub, EMul, EDiv, EML)):
        return 1 + size_emlexpr(expr.left) + size_emlexpr(expr.right)
    return 0

def transc_rank(expr: UExpr) -> int:
    """Count exp/log nodes in a UExpr."""
    if isinstance(expr, (Var, Const)):
        return 0
    elif isinstance(expr, (Add, Sub, Mul, Div)):
        return transc_rank(expr.left) + transc_rank(expr.right)
    elif isinstance(expr, (Exp, Log)):
        return 1 + transc_rank(expr.arg)
    return 0

def eml_rank(expr: EMLExpr) -> int:
    """Count eml nodes in an EMLExpr."""
    if isinstance(expr, (EVar, EConst)):
        return 0
    elif isinstance(expr, (EAdd, ESub, EMul, EDiv)):
        return eml_rank(expr.left) + eml_rank(expr.right)
    elif isinstance(expr, EML):
        return 1 + eml_rank(expr.left) + eml_rank(expr.right)
    return 0

def eml_depth(expr: EMLExpr) -> int:
    """Maximum nesting depth of eml nodes."""
    if isinstance(expr, (EVar, EConst)):
        return 0
    elif isinstance(expr, (EAdd, ESub, EMul, EDiv)):
        return max(eml_depth(expr.left), eml_depth(expr.right))
    elif isinstance(expr, EML):
        return 1 + max(eml_depth(expr.left), eml_depth(expr.right))
    return 0


# ============================================================
# §5. Pretty Printing
# ============================================================

def show_uexpr(expr: UExpr) -> str:
    if isinstance(expr, Var): return "x"
    elif isinstance(expr, Const): return f"{expr.value:.4g}"
    elif isinstance(expr, Add): return f"({show_uexpr(expr.left)} + {show_uexpr(expr.right)})"
    elif isinstance(expr, Sub): return f"({show_uexpr(expr.left)} - {show_uexpr(expr.right)})"
    elif isinstance(expr, Mul): return f"({show_uexpr(expr.left)} * {show_uexpr(expr.right)})"
    elif isinstance(expr, Div): return f"({show_uexpr(expr.left)} / {show_uexpr(expr.right)})"
    elif isinstance(expr, Exp): return f"exp({show_uexpr(expr.arg)})"
    elif isinstance(expr, Log): return f"log({show_uexpr(expr.arg)})"
    return "?"

def show_emlexpr(expr: EMLExpr) -> str:
    if isinstance(expr, EVar): return "x"
    elif isinstance(expr, EConst): return f"{expr.value:.4g}"
    elif isinstance(expr, EAdd): return f"({show_emlexpr(expr.left)} + {show_emlexpr(expr.right)})"
    elif isinstance(expr, ESub): return f"({show_emlexpr(expr.left)} - {show_emlexpr(expr.right)})"
    elif isinstance(expr, EMul): return f"({show_emlexpr(expr.left)} * {show_emlexpr(expr.right)})"
    elif isinstance(expr, EDiv): return f"({show_emlexpr(expr.left)} / {show_emlexpr(expr.right)})"
    elif isinstance(expr, EML): return f"eml({show_emlexpr(expr.left)}, {show_emlexpr(expr.right)})"
    return "?"


# ============================================================
# §6. Verification
# ============================================================

def verify_compilation(expr: UExpr, test_points: list[float]) -> bool:
    """Verify that compilation preserves semantics at test points."""
    compiled = compile_to_eml(expr)
    for x in test_points:
        orig = eval_uexpr(expr, x)
        comp = eval_emlexpr(compiled, x)
        if orig is None and comp is None:
            continue
        if orig is None or comp is None:
            return False
        if abs(orig - comp) > 1e-10:
            return False
    return True


if __name__ == "__main__":
    # Test the compiler
    test_exprs: list[tuple[str, UExpr]] = [
        ("exp(x)", Exp(Var())),
        ("log(x)", Log(Var())),
        ("exp(x) + log(x)", Add(Exp(Var()), Log(Var()))),
        ("exp(log(x))", Exp(Log(Var()))),
        ("x^2", Mul(Var(), Var())),
        ("sinh(x)", Div(Sub(Exp(Var()), Exp(Mul(Const(-1), Var()))), Const(2))),
    ]
    
    test_points = [0.5, 1.0, 1.5, 2.0, math.e]
    
    for name, expr in test_exprs:
        compiled = compile_to_eml(expr)
        src_size = size_uexpr(expr)
        cmp_size = size_emlexpr(compiled)
        src_rank = transc_rank(expr)
        cmp_rank = eml_rank(compiled)
        ok = verify_compilation(expr, test_points)
        
        print(f"  {name:<25} | size: {src_size} → {cmp_size} (ratio {cmp_size/src_size:.1f})")
        print(f"  {'':25} | rank: {src_rank} → {cmp_rank} (conserved: {src_rank == cmp_rank})")
        print(f"  {'':25} | correct: {ok}")
        print(f"  {'':25} | compiled: {show_emlexpr(compiled)}")
        print()
