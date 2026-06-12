from dataclasses import dataclass
from typing import Union


@dataclass(frozen=True)
class Var: ...
@dataclass(frozen=True)
class Const:
    c: float
@dataclass(frozen=True)
class Eml:
    a: "EMLExpr"
    b: "EMLExpr"

EMLExpr = Union[Var, Const, Eml]


def build_canonical_tower(n: int) -> EMLExpr:
    """Construct emlExprIterExp n: the depth-n EML expression for iterExp n.

    emlExprIterExp 0     = var
    emlExprIterExp (n+1) = eml (const 1) (emlExprIterExp n)
    Runs in Theta(n) time and space; the result has eml-depth exactly n.
    """
    e: EMLExpr = Var()
    for _ in range(n):
        e = Eml(Const(1.0), e)
    return e
