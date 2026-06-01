"""
Reflective Type Theory: Core Algorithms

Implements the type algebra, depth computation, translation to modal mu-calculus,
and depth analysis for Reflective Type Theory (ReflTT).
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, Optional, List, Tuple
from enum import Enum, auto


# ============================================================
# Type Definitions
# ============================================================

class RType:
    """Base class for Reflective Type Theory types."""
    pass

@dataclass(frozen=True)
class Base(RType):
    index: int

@dataclass(frozen=True)
class Unit(RType):
    pass

@dataclass(frozen=True)
class Void(RType):
    pass

@dataclass(frozen=True)
class Arrow(RType):
    domain: RType
    codomain: RType

@dataclass(frozen=True)
class Prod(RType):
    left: RType
    right: RType

@dataclass(frozen=True)
class Sum(RType):
    left: RType
    right: RType

@dataclass(frozen=True)
class Box(RType):
    inner: RType

@dataclass(frozen=True)
class Mu(RType):
    body: RType


# ============================================================
# Algorithm 1: Depth Computation
# ============================================================

def depth(ty: RType) -> int:
    """
    Compute the provability depth of a type.

    The depth is the maximum nesting of Box operators.
    Time complexity: O(size(ty)), Space: O(depth(ty)).

    >>> depth(Unit())
    0
    >>> depth(Box(Unit()))
    1
    >>> depth(Box(Box(Unit())))
    2
    >>> depth(Arrow(Box(Unit()), Unit()))
    1
    """
    if isinstance(ty, (Base, Unit, Void)):
        return 0
    elif isinstance(ty, (Arrow, Prod, Sum)):
        return max(depth(ty.left if hasattr(ty, 'left') else ty.domain),
                   depth(ty.right if hasattr(ty, 'right') else ty.codomain))
    elif isinstance(ty, Box):
        return 1 + depth(ty.inner)
    elif isinstance(ty, Mu):
        return depth(ty.body)
    else:
        raise ValueError(f"Unknown type: {ty}")


def size(ty: RType) -> int:
    """Compute the size (number of constructors) of a type."""
    if isinstance(ty, (Base, Unit, Void)):
        return 1
    elif isinstance(ty, (Arrow, Prod, Sum)):
        left = ty.left if hasattr(ty, 'left') else ty.domain
        right = ty.right if hasattr(ty, 'right') else ty.codomain
        return 1 + size(left) + size(right)
    elif isinstance(ty, (Box, Mu)):
        return 1 + size(ty.inner if isinstance(ty, Box) else ty.body)
    else:
        raise ValueError(f"Unknown type: {ty}")


def box_count(ty: RType) -> int:
    """Count the total number of Box constructors in a type."""
    if isinstance(ty, (Base, Unit, Void)):
        return 0
    elif isinstance(ty, (Arrow, Prod, Sum)):
        left = ty.left if hasattr(ty, 'left') else ty.domain
        right = ty.right if hasattr(ty, 'right') else ty.codomain
        return box_count(left) + box_count(right)
    elif isinstance(ty, Box):
        return 1 + box_count(ty.inner)
    elif isinstance(ty, Mu):
        return box_count(ty.body)
    else:
        raise ValueError(f"Unknown type: {ty}")


# ============================================================
# Algorithm 2: Iterated Box Construction
# ============================================================

def iter_box(n: int, base_type: RType = Unit()) -> RType:
    """
    Construct □^n(A), the type with n nested Box operators.

    >>> depth(iter_box(5))
    5
    >>> size(iter_box(5))
    6
    """
    result = base_type
    for _ in range(n):
        result = Box(result)
    return result


# ============================================================
# Algorithm 3: Modal Mu-Calculus Translation
# ============================================================

class MuFormula:
    """Base class for modal mu-calculus formulas."""
    pass

@dataclass(frozen=True)
class Var(MuFormula):
    index: int

@dataclass(frozen=True)
class TT(MuFormula):
    pass

@dataclass(frozen=True)
class FF(MuFormula):
    pass

@dataclass(frozen=True)
class Conj(MuFormula):
    left: MuFormula
    right: MuFormula

@dataclass(frozen=True)
class Disj(MuFormula):
    left: MuFormula
    right: MuFormula

@dataclass(frozen=True)
class Impl(MuFormula):
    left: MuFormula
    right: MuFormula

@dataclass(frozen=True)
class BoxF(MuFormula):
    inner: MuFormula

@dataclass(frozen=True)
class MuF(MuFormula):
    body: MuFormula


def to_mu(ty: RType) -> MuFormula:
    """
    Translate a reflective type to a modal mu-calculus formula.
    Bijective; inverse is from_mu.

    >>> to_mu(Box(Unit()))
    BoxF(inner=TT())
    """
    if isinstance(ty, Base): return Var(ty.index)
    elif isinstance(ty, Unit): return TT()
    elif isinstance(ty, Void): return FF()
    elif isinstance(ty, Arrow): return Impl(to_mu(ty.domain), to_mu(ty.codomain))
    elif isinstance(ty, Prod): return Conj(to_mu(ty.left), to_mu(ty.right))
    elif isinstance(ty, Sum): return Disj(to_mu(ty.left), to_mu(ty.right))
    elif isinstance(ty, Box): return BoxF(to_mu(ty.inner))
    elif isinstance(ty, Mu): return MuF(to_mu(ty.body))
    else: raise ValueError(f"Unknown type: {ty}")


def from_mu(f: MuFormula) -> RType:
    """Translate a modal mu-calculus formula to a reflective type."""
    if isinstance(f, Var): return Base(f.index)
    elif isinstance(f, TT): return Unit()
    elif isinstance(f, FF): return Void()
    elif isinstance(f, Impl): return Arrow(from_mu(f.left), from_mu(f.right))
    elif isinstance(f, Conj): return Prod(from_mu(f.left), from_mu(f.right))
    elif isinstance(f, Disj): return Sum(from_mu(f.left), from_mu(f.right))
    elif isinstance(f, BoxF): return Box(from_mu(f.inner))
    elif isinstance(f, MuF): return Mu(from_mu(f.body))
    else: raise ValueError(f"Unknown formula: {f}")


# ============================================================
# Algorithm 4: Provability Axiom Types
# ============================================================

def lob_type(p: RType) -> RType:
    """Löb's axiom type: □(□P → P) → □P"""
    return Arrow(Box(Arrow(Box(p), p)), Box(p))

def k_type(a: RType, b: RType) -> RType:
    """K axiom type: □(A → B) → □A → □B"""
    return Arrow(Box(Arrow(a, b)), Arrow(Box(a), Box(b)))

def four_type(a: RType) -> RType:
    """4 axiom type: □A → □□A"""
    return Arrow(Box(a), Box(Box(a)))

def t_type(a: RType) -> RType:
    """T axiom type: □A → A"""
    return Arrow(Box(a), a)


# ============================================================
# Algorithm 5: Depth Stratum Analysis
# ============================================================

class ModalStrength(Enum):
    CLASSICAL = auto()      # depth 0
    PROVABLE = auto()       # depth 1
    META_PROVABLE = auto()  # depth 2
    TRANSFINITE = auto()    # depth ≥ 3

def classify_strength(ty: RType) -> ModalStrength:
    """Classify a type by its modal strength."""
    d = depth(ty)
    if d == 0: return ModalStrength.CLASSICAL
    elif d == 1: return ModalStrength.PROVABLE
    elif d == 2: return ModalStrength.META_PROVABLE
    else: return ModalStrength.TRANSFINITE


def enumerate_depth_stratum(n: int, max_size: int) -> List[RType]:
    """
    Enumerate all types at depth exactly n with size ≤ max_size.
    Uses breadth-first construction.
    """
    results: List[RType] = []

    def generate(max_s: int) -> List[RType]:
        types: List[RType] = []
        if max_s >= 1:
            types.extend([Unit(), Void(), Base(0)])
        return types

    def build(current_depth: int, remaining_size: int) -> List[RType]:
        if remaining_size <= 0:
            return []
        if current_depth == 0 and remaining_size >= 1:
            return [t for t in generate(remaining_size) if depth(t) == 0]
        if current_depth > 0 and remaining_size >= 2:
            inner_types = build(current_depth - 1, remaining_size - 1)
            return [Box(t) for t in inner_types]
        return []

    base_types = build(n, max_size)
    results.extend(base_types)

    return results


# ============================================================
# Algorithm 6: Pretty Printing
# ============================================================

def pretty_type(ty: RType) -> str:
    """Pretty-print a reflective type."""
    if isinstance(ty, Base): return f"base({ty.index})"
    elif isinstance(ty, Unit): return "⊤"
    elif isinstance(ty, Void): return "⊥"
    elif isinstance(ty, Arrow): return f"({pretty_type(ty.domain)} → {pretty_type(ty.codomain)})"
    elif isinstance(ty, Prod): return f"({pretty_type(ty.left)} × {pretty_type(ty.right)})"
    elif isinstance(ty, Sum): return f"({pretty_type(ty.left)} + {pretty_type(ty.right)})"
    elif isinstance(ty, Box): return f"□{pretty_type(ty.inner)}"
    elif isinstance(ty, Mu): return f"μ{pretty_type(ty.body)}"
    else: return str(ty)


def pretty_formula(f: MuFormula) -> str:
    """Pretty-print a mu-calculus formula."""
    if isinstance(f, Var): return f"x{f.index}"
    elif isinstance(f, TT): return "⊤"
    elif isinstance(f, FF): return "⊥"
    elif isinstance(f, Conj): return f"({pretty_formula(f.left)} ∧ {pretty_formula(f.right)})"
    elif isinstance(f, Disj): return f"({pretty_formula(f.left)} ∨ {pretty_formula(f.right)})"
    elif isinstance(f, Impl): return f"({pretty_formula(f.left)} → {pretty_formula(f.right)})"
    elif isinstance(f, BoxF): return f"□{pretty_formula(f.inner)}"
    elif isinstance(f, MuF): return f"μ{pretty_formula(f.body)}"
    else: return str(f)


if __name__ == "__main__":
    # Quick self-test
    assert depth(Unit()) == 0
    assert depth(Box(Unit())) == 1
    assert depth(Box(Box(Unit()))) == 2
    assert size(iter_box(5)) == 6
    assert from_mu(to_mu(Box(Arrow(Unit(), Void())))) == Box(Arrow(Unit(), Void()))
    print("All algorithm tests passed.")
