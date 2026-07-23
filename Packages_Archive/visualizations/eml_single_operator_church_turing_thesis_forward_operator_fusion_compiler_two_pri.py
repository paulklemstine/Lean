from __future__ import annotations
from dataclasses import dataclass
from typing import Union

# Two-operator AST nodes (EMLExpr)
@dataclass
class Const: c: float
@dataclass
class Var: i: int
@dataclass
class Add: a: "EMLExpr"; b: "EMLExpr"
@dataclass
class Mul: a: "EMLExpr"; b: "EMLExpr"
@dataclass
class Neg: a: "EMLExpr"
@dataclass
class Inv: a: "EMLExpr"
@dataclass
class Exp: a: "EMLExpr"
@dataclass
class Log: a: "EMLExpr"
EMLExpr = Union[Const, Var, Add, Mul, Neg, Inv, Exp, Log]

# One-operator AST nodes (EMLOnlyExpr): Eml replaces Exp and Log
@dataclass
class Eml: a: "EMLOnlyExpr"; b: "EMLOnlyExpr"
EMLOnlyExpr = Union[Const, Var, Add, Mul, Neg, Inv, Eml]

def compile_to_eml_only(e: EMLExpr) -> EMLOnlyExpr:
    """Forward compiler C: EMLExpr -> EMLOnlyExpr (size <= 5 * size)."""
    if isinstance(e, Const): return Const(e.c)
    if isinstance(e, Var):   return Var(e.i)
    if isinstance(e, Add):   return Add(compile_to_eml_only(e.a), compile_to_eml_only(e.b))
    if isinstance(e, Mul):   return Mul(compile_to_eml_only(e.a), compile_to_eml_only(e.b))
    if isinstance(e, Neg):   return Neg(compile_to_eml_only(e.a))
    if isinstance(e, Inv):   return Inv(compile_to_eml_only(e.a))
    if isinstance(e, Exp):   # exp(x) = eml(x, 1)
        return Eml(compile_to_eml_only(e.a), Const(1.0))
    if isinstance(e, Log):   # log(y) = 1 - eml(0, y)
        return Add(Const(1.0), Neg(Eml(Const(0.0), compile_to_eml_only(e.a))))
    raise TypeError(e)
