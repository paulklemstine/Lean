"""
Transreal Arithmetic: Algorithms and Type-Hinted Implementations
================================================================

Provides a complete, type-hinted implementation of transreal arithmetic
following Anderson's system, plus algorithms for:
1. Expression evaluation with nullity propagation detection
2. Algebraic property checking (commutativity, associativity, distributivity)
3. Transreal interval arithmetic
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Callable, Optional, Sequence


class Kind(Enum):
    """Classification of a transreal number."""
    REAL = auto()
    POS_INF = auto()
    NEG_INF = auto()
    NULLITY = auto()


@dataclass(frozen=True)
class TR:
    """
    Transreal number: ℝ ∪ {+∞, -∞, Φ}.

    Immutable value type implementing Anderson's transreal arithmetic.
    All operations are total — no exceptions, no undefined results.
    """
    kind: Kind
    value: float = 0.0

    @staticmethod
    def real(x: float) -> TR:
        return TR(Kind.REAL, x)

    @staticmethod
    def pos_inf() -> TR:
        return TR(Kind.POS_INF)

    @staticmethod
    def neg_inf() -> TR:
        return TR(Kind.NEG_INF)

    @staticmethod
    def nullity() -> TR:
        return TR(Kind.NULLITY)

    @staticmethod
    def zero() -> TR:
        return TR.real(0.0)

    @staticmethod
    def one() -> TR:
        return TR.real(1.0)

    def is_finite(self) -> bool:
        return self.kind == Kind.REAL

    def is_infinite(self) -> bool:
        return self.kind in (Kind.POS_INF, Kind.NEG_INF)

    def is_nullity(self) -> bool:
        return self.kind == Kind.NULLITY

    def is_total(self) -> bool:
        """Total = not nullity (finite or infinite)."""
        return self.kind != Kind.NULLITY

    def __repr__(self) -> str:
        match self.kind:
            case Kind.REAL:
                v = self.value
                return str(int(v)) if v == int(v) else str(v)
            case Kind.POS_INF:
                return "+∞"
            case Kind.NEG_INF:
                return "-∞"
            case Kind.NULLITY:
                return "Φ"

    def __neg__(self) -> TR:
        match self.kind:
            case Kind.REAL:
                return TR.real(-self.value)
            case Kind.POS_INF:
                return TR.neg_inf()
            case Kind.NEG_INF:
                return TR.pos_inf()
            case Kind.NULLITY:
                return TR.nullity()

    def __add__(self, other: TR) -> TR:
        if self.is_nullity() or other.is_nullity():
            return TR.nullity()
        if self.is_finite() and other.is_finite():
            return TR.real(self.value + other.value)
        if self.is_finite():
            return other
        if other.is_finite():
            return self
        # Both infinite
        if self.kind == other.kind:
            return self
        return TR.nullity()  # ∞ + (-∞) = Φ

    def __sub__(self, other: TR) -> TR:
        return self + (-other)

    def __mul__(self, other: TR) -> TR:
        if self.is_nullity() or other.is_nullity():
            return TR.nullity()
        if self.is_finite() and other.is_finite():
            return TR.real(self.value * other.value)
        # Handle real × infinite
        if self.is_finite():
            if self.value > 0:
                return other
            elif self.value < 0:
                return -other
            else:
                return TR.nullity()  # 0 × ∞ = Φ
        if other.is_finite():
            if other.value > 0:
                return self
            elif other.value < 0:
                return -self
            else:
                return TR.nullity()
        # Both infinite
        same_sign = (self.kind == Kind.POS_INF) == (other.kind == Kind.POS_INF)
        return TR.pos_inf() if same_sign else TR.neg_inf()

    def recip(self) -> TR:
        """Transreal reciprocal: 1/0 = +∞, 1/∞ = 0, 1/Φ = Φ."""
        match self.kind:
            case Kind.NULLITY:
                return TR.nullity()
            case Kind.POS_INF | Kind.NEG_INF:
                return TR.zero()
            case Kind.REAL:
                if self.value == 0:
                    return TR.pos_inf()
                return TR.real(1.0 / self.value)

    def __truediv__(self, other: TR) -> TR:
        return self * other.recip()

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, TR):
            return NotImplemented
        if self.kind != other.kind:
            return False
        if self.kind == Kind.REAL:
            return self.value == other.value
        return True

    def __hash__(self) -> int:
        if self.kind == Kind.REAL:
            return hash((self.kind, self.value))
        return hash(self.kind)


# ─── Expression Tree Evaluator ───────────────────────────────────────────

@dataclass
class Expr:
    """Expression tree over transreals."""
    pass

@dataclass
class Lit(Expr):
    val: TR

@dataclass
class Add(Expr):
    left: Expr
    right: Expr

@dataclass
class Mul(Expr):
    left: Expr
    right: Expr

@dataclass
class Neg(Expr):
    inner: Expr

@dataclass
class Recip(Expr):
    inner: Expr


def evaluate(expr: Expr) -> TR:
    """Evaluate a transreal expression tree."""
    match expr:
        case Lit(v):
            return v
        case Add(l, r):
            return evaluate(l) + evaluate(r)
        case Mul(l, r):
            return evaluate(l) * evaluate(r)
        case Neg(e):
            return -evaluate(e)
        case Recip(e):
            return evaluate(e).recip()
    raise ValueError(f"Unknown expression type: {type(expr)}")


def contains_nullity(expr: Expr) -> bool:
    """Check if an expression tree contains a nullity literal."""
    match expr:
        case Lit(v):
            return v.is_nullity()
        case Add(l, r) | Mul(l, r):
            return contains_nullity(l) or contains_nullity(r)
        case Neg(e) | Recip(e):
            return contains_nullity(e)
    return False


def verify_nullity_collapse(expr: Expr) -> bool:
    """
    Verify the Nullity Collapse Conjecture for a given expression:
    If the expression contains nullity, it should evaluate to nullity.

    Note: This holds for add/mul trees but may fail for recip
    (since recip(Φ) = Φ, it still holds).
    """
    if contains_nullity(expr):
        result = evaluate(expr)
        return result.is_nullity()
    return True  # Vacuously true


# ─── Algebraic Property Checker ──────────────────────────────────────────

def check_commutativity(
    op: Callable[[TR, TR], TR],
    samples: Sequence[TR]
) -> tuple[bool, Optional[tuple[TR, TR]]]:
    """Check if a binary operation is commutative over given samples."""
    for a in samples:
        for b in samples:
            if op(a, b) != op(b, a):
                return False, (a, b)
    return True, None


def check_associativity(
    op: Callable[[TR, TR], TR],
    samples: Sequence[TR]
) -> tuple[bool, Optional[tuple[TR, TR, TR]]]:
    """Check if a binary operation is associative over given samples."""
    for a in samples:
        for b in samples:
            for c in samples:
                if op(op(a, b), c) != op(a, op(b, c)):
                    return False, (a, b, c)
    return True, None


def check_distributivity(
    mul_op: Callable[[TR, TR], TR],
    add_op: Callable[[TR, TR], TR],
    samples: Sequence[TR]
) -> tuple[bool, Optional[tuple[TR, TR, TR]]]:
    """Check left distributivity: a * (b + c) = a*b + a*c."""
    for a in samples:
        for b in samples:
            for c in samples:
                lhs = mul_op(a, add_op(b, c))
                rhs = add_op(mul_op(a, b), mul_op(a, c))
                if lhs != rhs:
                    return False, (a, b, c)
    return True, None


# ─── Transreal Interval Arithmetic ───────────────────────────────────────

@dataclass(frozen=True)
class TRInterval:
    """
    An interval [lo, hi] in the transreal numbers.
    If either endpoint is Φ, the interval is degenerate (= {Φ}).
    """
    lo: TR
    hi: TR

    def is_degenerate(self) -> bool:
        return self.lo.is_nullity() or self.hi.is_nullity()

    def __add__(self, other: TRInterval) -> TRInterval:
        if self.is_degenerate() or other.is_degenerate():
            return TRInterval(TR.nullity(), TR.nullity())
        return TRInterval(self.lo + other.lo, self.hi + other.hi)

    def contains(self, x: TR) -> bool:
        """Check if x is in the interval (for finite values)."""
        if x.is_nullity():
            return self.is_degenerate()
        if x.is_finite() and self.lo.is_finite() and self.hi.is_finite():
            return self.lo.value <= x.value <= self.hi.value
        return False

    def __repr__(self) -> str:
        if self.is_degenerate():
            return "{Φ}"
        return f"[{self.lo}, {self.hi}]"


if __name__ == "__main__":
    # Quick demo
    samples = [TR.zero(), TR.one(), TR.real(-1), TR.pos_inf(), TR.neg_inf(), TR.nullity()]

    print("=== Algebraic Property Check ===")
    comm_add, _ = check_commutativity(TR.__add__, samples)
    comm_mul, _ = check_commutativity(TR.__mul__, samples)
    assoc_add, cex_add = check_associativity(TR.__add__, samples)
    assoc_mul, cex_mul = check_associativity(TR.__mul__, samples)
    dist, cex_dist = check_distributivity(TR.__mul__, TR.__add__, samples)

    print(f"Addition commutative: {comm_add}")
    print(f"Multiplication commutative: {comm_mul}")
    print(f"Addition associative: {assoc_add}")
    if not assoc_add and cex_add:
        a, b, c = cex_add
        print(f"  Counterexample: ({a} + {b}) + {c} ≠ {a} + ({b} + {c})")
    print(f"Multiplication associative: {assoc_mul}")
    if not assoc_mul and cex_mul:
        a, b, c = cex_mul
        print(f"  Counterexample: ({a} × {b}) × {c} ≠ {a} × ({b} × {c})")
    print(f"Left distributivity: {dist}")
    if not dist and cex_dist:
        a, b, c = cex_dist
        lhs = a * (b + c)
        rhs = a * b + a * c
        print(f"  Counterexample: {a} × ({b} + {c}) = {lhs} ≠ {rhs} = {a}×{b} + {a}×{c}")

    print("\n=== Nullity Collapse Check ===")
    # Build random expression trees with nullity
    phi = Lit(TR.nullity())
    three = Lit(TR.real(3))
    inf_lit = Lit(TR.pos_inf())

    exprs = [
        Add(phi, three),
        Mul(Add(phi, inf_lit), three),
        Mul(three, Add(Neg(phi), inf_lit)),
        Add(Mul(phi, phi), Mul(three, inf_lit)),
    ]

    for e in exprs:
        result = evaluate(e)
        collapsed = verify_nullity_collapse(e)
        print(f"  Expression evaluates to {result}, collapse verified: {collapsed}")
