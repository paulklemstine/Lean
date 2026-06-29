from dataclasses import dataclass
from typing import Union


@dataclass(frozen=True)
class Var: ...
@dataclass(frozen=True)
class Const:
    c: float
@dataclass(frozen=True)
class Add:
    a: "EMLExpr"; b: "EMLExpr"
@dataclass(frozen=True)
class Mul:
    a: "EMLExpr"; b: "EMLExpr"
@dataclass(frozen=True)
class Neg:
    a: "EMLExpr"
@dataclass(frozen=True)
class Inv:
    a: "EMLExpr"
@dataclass(frozen=True)
class Eml:
    a: "EMLExpr"; b: "EMLExpr"

EMLExpr = Union[Var, Const, Add, Mul, Neg, Inv, Eml]


def eml_depth(e: EMLExpr) -> int:
    """Maximum nesting of eml constructors (post-order traversal, Theta(|e|))."""
    if isinstance(e, (Var, Const)):
        return 0
    if isinstance(e, (Add, Mul)):
        return max(eml_depth(e.a), eml_depth(e.b))
    if isinstance(e, (Neg, Inv)):
        return eml_depth(e.a)
    if isinstance(e, Eml):
        return 1 + max(eml_depth(e.a), eml_depth(e.b))
    raise TypeError(e)


def growth_rank(e: EMLExpr) -> int:
    """Structural growth complexity; always satisfies growth_rank(e) <= eml_depth(e)."""
    if isinstance(e, (Var, Const)):
        return 0
    if isinstance(e, (Add, Mul)):
        return max(growth_rank(e.a), growth_rank(e.b))
    if isinstance(e, (Neg, Inv)):
        return growth_rank(e.a)
    if isinstance(e, Eml):
        return 1 + max(growth_rank(e.a), growth_rank(e.b))
    raise TypeError(e)
