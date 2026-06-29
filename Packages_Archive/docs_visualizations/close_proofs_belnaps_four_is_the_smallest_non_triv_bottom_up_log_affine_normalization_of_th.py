from __future__ import annotations
import math
from dataclasses import dataclass
from typing import List, Tuple, Union


@dataclass(frozen=True)
class Coord:
    i: int


@dataclass(frozen=True)
class PosConst:
    c: float


@dataclass(frozen=True)
class Mul:
    e1: "Expr"
    e2: "Expr"


@dataclass(frozen=True)
class RPow:
    e: "Expr"
    r: float


Expr = Union[Coord, PosConst, Mul, RPow]


def to_log_affine_form(e: Expr, n: int) -> Tuple[List[float], float]:
    """Normalize a multiplicative-positive expression to (weights, constant)
    so that eval(e)(x) = exp(sum_i w_i*log x_i + c). One bottom-up pass."""
    if isinstance(e, Coord):
        w = [0.0] * n
        w[e.i] = 1.0
        return w, 0.0
    if isinstance(e, PosConst):
        return [0.0] * n, math.log(e.c)
    if isinstance(e, Mul):
        w1, c1 = to_log_affine_form(e.e1, n)
        w2, c2 = to_log_affine_form(e.e2, n)
        return [a + b for a, b in zip(w1, w2)], c1 + c2
    if isinstance(e, RPow):
        w, c = to_log_affine_form(e.e, n)
        return [e.r * a for a in w], e.r * c
    raise TypeError(e)


def equal_as_functions(e1: Expr, e2: Expr, n: int, tol: float = 1e-12) -> bool:
    """Decide equality of denotations via normal forms (sound & complete)."""
    w1, c1 = to_log_affine_form(e1, n)
    w2, c2 = to_log_affine_form(e2, n)
    return all(abs(a - b) < tol for a, b in zip(w1, w2)) and abs(c1 - c2) < tol
