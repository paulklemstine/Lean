"""
Reflective Type Theory: Core Algorithms

Implements the type theory, modal mu-calculus, translations, and
depth analysis from the formal Lean development.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Union


# ─────────────────────────────────────────────
# ReflTy: Types in Reflective Type Theory
# ─────────────────────────────────────────────

class ReflTy:
    """Base class for reflective type theory types."""
    pass

@dataclass(frozen=True)
class Base(ReflTy):
    index: int

@dataclass(frozen=True)
class Unit(ReflTy):
    pass

@dataclass(frozen=True)
class Void(ReflTy):
    pass

@dataclass(frozen=True)
class Arrow(ReflTy):
    domain: ReflTy
    codomain: ReflTy

@dataclass(frozen=True)
class Prod(ReflTy):
    left: ReflTy
    right: ReflTy

@dataclass(frozen=True)
class Sum(ReflTy):
    left: ReflTy
    right: ReflTy

@dataclass(frozen=True)
class Box(ReflTy):
    inner: ReflTy

@dataclass(frozen=True)
class Mu(ReflTy):
    body: ReflTy


# ─────────────────────────────────────────────
# ModalMuFormula: Modal Mu-Calculus Formulas
# ─────────────────────────────────────────────

class ModalMuFormula:
    """Base class for modal mu-calculus formulas."""
    pass

@dataclass(frozen=True)
class Var(ModalMuFormula):
    index: int

@dataclass(frozen=True)
class Tt(ModalMuFormula):
    pass

@dataclass(frozen=True)
class Ff(ModalMuFormula):
    pass

@dataclass(frozen=True)
class Conj(ModalMuFormula):
    left: ModalMuFormula
    right: ModalMuFormula

@dataclass(frozen=True)
class Disj(ModalMuFormula):
    left: ModalMuFormula
    right: ModalMuFormula

@dataclass(frozen=True)
class Impl(ModalMuFormula):
    antecedent: ModalMuFormula
    consequent: ModalMuFormula

@dataclass(frozen=True)
class BoxF(ModalMuFormula):
    inner: ModalMuFormula

@dataclass(frozen=True)
class MuF(ModalMuFormula):
    body: ModalMuFormula


# ─────────────────────────────────────────────
# Provability Depth
# ─────────────────────────────────────────────

def prov_depth(ty: ReflTy) -> int:
    """Compute the provability depth of a reflective type.

    Time complexity: O(n) where n is the size of the type tree.

    Args:
        ty: A reflective type.

    Returns:
        The maximum nesting depth of Box constructors.
    """
    if isinstance(ty, (Base, Unit, Void)):
        return 0
    elif isinstance(ty, (Arrow, Prod, Sum)):
        return max(prov_depth(ty.left if hasattr(ty, 'left') else ty.domain),
                   prov_depth(ty.right if hasattr(ty, 'right') else ty.codomain))
    elif isinstance(ty, Box):
        return 1 + prov_depth(ty.inner)
    elif isinstance(ty, Mu):
        return prov_depth(ty.body)
    else:
        raise ValueError(f"Unknown type: {ty}")


def is_mltt(ty: ReflTy) -> bool:
    """Check if a type belongs to the MLTT fragment.

    A type is MLTT if it uses no Box or Mu constructors.

    Args:
        ty: A reflective type.

    Returns:
        True if the type is in the MLTT fragment.
    """
    if isinstance(ty, (Base, Unit, Void)):
        return True
    elif isinstance(ty, Arrow):
        return is_mltt(ty.domain) and is_mltt(ty.codomain)
    elif isinstance(ty, Prod):
        return is_mltt(ty.left) and is_mltt(ty.right)
    elif isinstance(ty, Sum):
        return is_mltt(ty.left) and is_mltt(ty.right)
    elif isinstance(ty, (Box, Mu)):
        return False
    else:
        raise ValueError(f"Unknown type: {ty}")


# ─────────────────────────────────────────────
# Modal Depth for Mu-Calculus
# ─────────────────────────────────────────────

def modal_depth(phi: ModalMuFormula) -> int:
    """Compute the modal depth of a mu-calculus formula.

    Args:
        phi: A modal mu-calculus formula.

    Returns:
        The maximum nesting depth of BoxF constructors.
    """
    if isinstance(phi, (Var, Tt, Ff)):
        return 0
    elif isinstance(phi, (Conj, Disj, Impl)):
        return max(modal_depth(phi.left if hasattr(phi, 'left') else phi.antecedent),
                   modal_depth(phi.right if hasattr(phi, 'right') else phi.consequent))
    elif isinstance(phi, BoxF):
        return 1 + modal_depth(phi.inner)
    elif isinstance(phi, MuF):
        return modal_depth(phi.body)
    else:
        raise ValueError(f"Unknown formula: {phi}")


# ─────────────────────────────────────────────
# Translations
# ─────────────────────────────────────────────

def refl_to_mu(ty: ReflTy) -> ModalMuFormula:
    """Translate a reflective type to a modal mu-calculus formula.

    Args:
        ty: A reflective type.

    Returns:
        The corresponding modal mu-calculus formula.
    """
    if isinstance(ty, Base):
        return Var(ty.index)
    elif isinstance(ty, Unit):
        return Tt()
    elif isinstance(ty, Void):
        return Ff()
    elif isinstance(ty, Arrow):
        return Impl(refl_to_mu(ty.domain), refl_to_mu(ty.codomain))
    elif isinstance(ty, Prod):
        return Conj(refl_to_mu(ty.left), refl_to_mu(ty.right))
    elif isinstance(ty, Sum):
        return Disj(refl_to_mu(ty.left), refl_to_mu(ty.right))
    elif isinstance(ty, Box):
        return BoxF(refl_to_mu(ty.inner))
    elif isinstance(ty, Mu):
        return MuF(refl_to_mu(ty.body))
    else:
        raise ValueError(f"Unknown type: {ty}")


def mu_to_refl(phi: ModalMuFormula) -> ReflTy:
    """Translate a modal mu-calculus formula to a reflective type.

    Args:
        phi: A modal mu-calculus formula.

    Returns:
        The corresponding reflective type.
    """
    if isinstance(phi, Var):
        return Base(phi.index)
    elif isinstance(phi, Tt):
        return Unit()
    elif isinstance(phi, Ff):
        return Void()
    elif isinstance(phi, Conj):
        return Prod(mu_to_refl(phi.left), mu_to_refl(phi.right))
    elif isinstance(phi, Disj):
        return Sum(mu_to_refl(phi.left), mu_to_refl(phi.right))
    elif isinstance(phi, Impl):
        return Arrow(mu_to_refl(phi.antecedent), mu_to_refl(phi.consequent))
    elif isinstance(phi, BoxF):
        return Box(mu_to_refl(phi.inner))
    elif isinstance(phi, MuF):
        return Mu(mu_to_refl(phi.body))
    else:
        raise ValueError(f"Unknown formula: {phi}")


# ─────────────────────────────────────────────
# Modal Strength Classification
# ─────────────────────────────────────────────

class ModalStrength(Enum):
    CLASSICAL = auto()      # depth 0
    PROVABLE = auto()       # depth 1
    META_PROVABLE = auto()  # depth 2
    TRANSFINITE = auto()    # depth ≥ 3


def classify_strength(ty: ReflTy) -> ModalStrength:
    """Classify a type by its modal strength.

    Args:
        ty: A reflective type.

    Returns:
        The modal strength classification.
    """
    d = prov_depth(ty)
    if d == 0:
        return ModalStrength.CLASSICAL
    elif d == 1:
        return ModalStrength.PROVABLE
    elif d == 2:
        return ModalStrength.META_PROVABLE
    else:
        return ModalStrength.TRANSFINITE


# ─────────────────────────────────────────────
# Named Type Constructors
# ─────────────────────────────────────────────

def provable_not_provably_provable(p: ReflTy) -> ReflTy:
    """Construct the type □P × (□□P → ⊥)."""
    return Prod(Box(p), Arrow(Box(Box(p)), Void()))


def loeb_type(p: ReflTy) -> ReflTy:
    """Construct Löb's axiom type: □(□P → P) → □P."""
    return Arrow(Box(Arrow(Box(p), p)), Box(p))


def goedel_sentence_type(p: ReflTy) -> ReflTy:
    """Construct the Gödel sentence type: □P → ⊥."""
    return Arrow(Box(p), Void())


def k_axiom_type(a: ReflTy, b: ReflTy) -> ReflTy:
    """K axiom: □(A → B) → □A → □B."""
    return Arrow(Box(Arrow(a, b)), Arrow(Box(a), Box(b)))


def four_axiom_type(a: ReflTy) -> ReflTy:
    """4 axiom (positive introspection): □A → □□A."""
    return Arrow(Box(a), Box(Box(a)))


def t_axiom_type(a: ReflTy) -> ReflTy:
    """T axiom (reflection): □A → A."""
    return Arrow(Box(a), a)


def iterated_box(n: int, a: ReflTy) -> ReflTy:
    """Apply □ n times to a type."""
    result = a
    for _ in range(n):
        result = Box(result)
    return result


# ─────────────────────────────────────────────
# Pretty Printing
# ─────────────────────────────────────────────

def pretty_type(ty: ReflTy) -> str:
    """Pretty-print a reflective type."""
    if isinstance(ty, Base):
        return f"P{ty.index}"
    elif isinstance(ty, Unit):
        return "⊤"
    elif isinstance(ty, Void):
        return "⊥"
    elif isinstance(ty, Arrow):
        d = pretty_type(ty.domain)
        c = pretty_type(ty.codomain)
        if isinstance(ty.domain, (Arrow, Prod, Sum)):
            d = f"({d})"
        return f"{d} → {c}"
    elif isinstance(ty, Prod):
        l = pretty_type(ty.left)
        r = pretty_type(ty.right)
        return f"{l} × {r}"
    elif isinstance(ty, Sum):
        l = pretty_type(ty.left)
        r = pretty_type(ty.right)
        return f"{l} + {r}"
    elif isinstance(ty, Box):
        inner = pretty_type(ty.inner)
        if isinstance(ty.inner, (Arrow, Prod, Sum)):
            inner = f"({inner})"
        return f"□{inner}"
    elif isinstance(ty, Mu):
        return f"μ.{pretty_type(ty.body)}"
    else:
        return str(ty)


def pretty_formula(phi: ModalMuFormula) -> str:
    """Pretty-print a modal mu-calculus formula."""
    if isinstance(phi, Var):
        return f"x{phi.index}"
    elif isinstance(phi, Tt):
        return "⊤"
    elif isinstance(phi, Ff):
        return "⊥"
    elif isinstance(phi, Conj):
        return f"{pretty_formula(phi.left)} ∧ {pretty_formula(phi.right)}"
    elif isinstance(phi, Disj):
        return f"{pretty_formula(phi.left)} ∨ {pretty_formula(phi.right)}"
    elif isinstance(phi, Impl):
        return f"{pretty_formula(phi.antecedent)} → {pretty_formula(phi.consequent)}"
    elif isinstance(phi, BoxF):
        return f"□{pretty_formula(phi.inner)}"
    elif isinstance(phi, MuF):
        return f"μ.{pretty_formula(phi.body)}"
    else:
        return str(phi)
