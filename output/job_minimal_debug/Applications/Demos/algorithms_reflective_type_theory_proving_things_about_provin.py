"""
Reflective Type Theory: Core Algorithms

Implements the type system, translations, depth computation,
and Kripke model evaluation for Reflective Type Theory.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional, Callable


# ─── Type Definitions ───────────────────────────────────────────────


class TyKind(Enum):
    BASE = auto()
    UNIT = auto()
    VOID = auto()
    ARROW = auto()
    PROD = auto()
    SUM = auto()
    BOX = auto()
    MU = auto()


@dataclass(frozen=True)
class ReflTy:
    """A type in Reflective Type Theory."""
    kind: TyKind
    index: int = 0  # for BASE
    left: Optional['ReflTy'] = None
    right: Optional['ReflTy'] = None
    body: Optional['ReflTy'] = None  # for BOX, MU

    @staticmethod
    def base(n: int) -> 'ReflTy':
        return ReflTy(TyKind.BASE, index=n)

    @staticmethod
    def unit() -> 'ReflTy':
        return ReflTy(TyKind.UNIT)

    @staticmethod
    def void() -> 'ReflTy':
        return ReflTy(TyKind.VOID)

    @staticmethod
    def arrow(a: 'ReflTy', b: 'ReflTy') -> 'ReflTy':
        return ReflTy(TyKind.ARROW, left=a, right=b)

    @staticmethod
    def prod(a: 'ReflTy', b: 'ReflTy') -> 'ReflTy':
        return ReflTy(TyKind.PROD, left=a, right=b)

    @staticmethod
    def sum_(a: 'ReflTy', b: 'ReflTy') -> 'ReflTy':
        return ReflTy(TyKind.SUM, left=a, right=b)

    @staticmethod
    def box(a: 'ReflTy') -> 'ReflTy':
        return ReflTy(TyKind.BOX, body=a)

    @staticmethod
    def mu(a: 'ReflTy') -> 'ReflTy':
        return ReflTy(TyKind.MU, body=a)

    def prov_depth(self) -> int:
        """Compute provability depth (max nesting of □)."""
        if self.kind in (TyKind.BASE, TyKind.UNIT, TyKind.VOID):
            return 0
        elif self.kind in (TyKind.ARROW, TyKind.PROD, TyKind.SUM):
            assert self.left and self.right
            return max(self.left.prov_depth(), self.right.prov_depth())
        elif self.kind == TyKind.BOX:
            assert self.body
            return 1 + self.body.prov_depth()
        elif self.kind == TyKind.MU:
            assert self.body
            return self.body.prov_depth()
        return 0

    def is_mltt(self) -> bool:
        """Check if type is in the MLTT fragment (no □ or μ)."""
        if self.kind in (TyKind.BASE, TyKind.UNIT, TyKind.VOID):
            return True
        elif self.kind in (TyKind.ARROW, TyKind.PROD, TyKind.SUM):
            assert self.left and self.right
            return self.left.is_mltt() and self.right.is_mltt()
        return False

    def size(self) -> int:
        """Total number of constructors."""
        if self.kind in (TyKind.BASE, TyKind.UNIT, TyKind.VOID):
            return 1
        elif self.kind in (TyKind.ARROW, TyKind.PROD, TyKind.SUM):
            assert self.left and self.right
            return 1 + self.left.size() + self.right.size()
        elif self.kind in (TyKind.BOX, TyKind.MU):
            assert self.body
            return 1 + self.body.size()
        return 1

    def box_count(self) -> int:
        """Count □ occurrences."""
        if self.kind in (TyKind.BASE, TyKind.UNIT, TyKind.VOID):
            return 0
        elif self.kind in (TyKind.ARROW, TyKind.PROD, TyKind.SUM):
            assert self.left and self.right
            return self.left.box_count() + self.right.box_count()
        elif self.kind == TyKind.BOX:
            assert self.body
            return 1 + self.body.box_count()
        elif self.kind == TyKind.MU:
            assert self.body
            return self.body.box_count()
        return 0

    def mu_count(self) -> int:
        """Count μ occurrences."""
        if self.kind in (TyKind.BASE, TyKind.UNIT, TyKind.VOID):
            return 0
        elif self.kind in (TyKind.ARROW, TyKind.PROD, TyKind.SUM):
            assert self.left and self.right
            return self.left.mu_count() + self.right.mu_count()
        elif self.kind == TyKind.BOX:
            assert self.body
            return self.body.mu_count()
        elif self.kind == TyKind.MU:
            assert self.body
            return 1 + self.body.mu_count()
        return 0

    def classify_strength(self) -> str:
        """Classify modal strength."""
        d = self.prov_depth()
        if d == 0:
            return "classical"
        elif d == 1:
            return "provable"
        elif d == 2:
            return "metaProvable"
        else:
            return "transfinite"

    def pretty(self) -> str:
        """Pretty-print the type."""
        if self.kind == TyKind.BASE:
            return f"P{self.index}"
        elif self.kind == TyKind.UNIT:
            return "⊤"
        elif self.kind == TyKind.VOID:
            return "⊥"
        elif self.kind == TyKind.ARROW:
            assert self.left and self.right
            l = self.left.pretty()
            r = self.right.pretty()
            if self.left.kind == TyKind.ARROW:
                l = f"({l})"
            return f"{l} → {r}"
        elif self.kind == TyKind.PROD:
            assert self.left and self.right
            return f"({self.left.pretty()} × {self.right.pretty()})"
        elif self.kind == TyKind.SUM:
            assert self.left and self.right
            return f"({self.left.pretty()} + {self.right.pretty()})"
        elif self.kind == TyKind.BOX:
            assert self.body
            return f"□{self.body.pretty()}"
        elif self.kind == TyKind.MU:
            assert self.body
            return f"μ{self.body.pretty()}"
        return "?"


# ─── Modal Mu-Calculus ──────────────────────────────────────────────


class FormulaKind(Enum):
    VAR = auto()
    TT = auto()
    FF = auto()
    CONJ = auto()
    DISJ = auto()
    IMPL = auto()
    BOXF = auto()
    MUF = auto()


@dataclass(frozen=True)
class ModalMuFormula:
    """A formula of the modal mu-calculus."""
    kind: FormulaKind
    index: int = 0
    left: Optional['ModalMuFormula'] = None
    right: Optional['ModalMuFormula'] = None
    body: Optional['ModalMuFormula'] = None

    def modal_depth(self) -> int:
        if self.kind in (FormulaKind.VAR, FormulaKind.TT, FormulaKind.FF):
            return 0
        elif self.kind in (FormulaKind.CONJ, FormulaKind.DISJ, FormulaKind.IMPL):
            assert self.left and self.right
            return max(self.left.modal_depth(), self.right.modal_depth())
        elif self.kind == FormulaKind.BOXF:
            assert self.body
            return 1 + self.body.modal_depth()
        elif self.kind == FormulaKind.MUF:
            assert self.body
            return self.body.modal_depth()
        return 0

    def pretty(self) -> str:
        if self.kind == FormulaKind.VAR:
            return f"x{self.index}"
        elif self.kind == FormulaKind.TT:
            return "⊤"
        elif self.kind == FormulaKind.FF:
            return "⊥"
        elif self.kind == FormulaKind.CONJ:
            assert self.left and self.right
            return f"({self.left.pretty()} ∧ {self.right.pretty()})"
        elif self.kind == FormulaKind.DISJ:
            assert self.left and self.right
            return f"({self.left.pretty()} ∨ {self.right.pretty()})"
        elif self.kind == FormulaKind.IMPL:
            assert self.left and self.right
            return f"({self.left.pretty()} → {self.right.pretty()})"
        elif self.kind == FormulaKind.BOXF:
            assert self.body
            return f"□{self.body.pretty()}"
        elif self.kind == FormulaKind.MUF:
            assert self.body
            return f"μ{self.body.pretty()}"
        return "?"


# ─── Translation ────────────────────────────────────────────────────


def refl_to_mu(ty: ReflTy) -> ModalMuFormula:
    """Translate ReflTy → ModalMuFormula."""
    if ty.kind == TyKind.BASE:
        return ModalMuFormula(FormulaKind.VAR, index=ty.index)
    elif ty.kind == TyKind.UNIT:
        return ModalMuFormula(FormulaKind.TT)
    elif ty.kind == TyKind.VOID:
        return ModalMuFormula(FormulaKind.FF)
    elif ty.kind == TyKind.ARROW:
        assert ty.left and ty.right
        return ModalMuFormula(FormulaKind.IMPL,
                              left=refl_to_mu(ty.left),
                              right=refl_to_mu(ty.right))
    elif ty.kind == TyKind.PROD:
        assert ty.left and ty.right
        return ModalMuFormula(FormulaKind.CONJ,
                              left=refl_to_mu(ty.left),
                              right=refl_to_mu(ty.right))
    elif ty.kind == TyKind.SUM:
        assert ty.left and ty.right
        return ModalMuFormula(FormulaKind.DISJ,
                              left=refl_to_mu(ty.left),
                              right=refl_to_mu(ty.right))
    elif ty.kind == TyKind.BOX:
        assert ty.body
        return ModalMuFormula(FormulaKind.BOXF, body=refl_to_mu(ty.body))
    elif ty.kind == TyKind.MU:
        assert ty.body
        return ModalMuFormula(FormulaKind.MUF, body=refl_to_mu(ty.body))
    raise ValueError(f"Unknown type kind: {ty.kind}")


def mu_to_refl(f: ModalMuFormula) -> ReflTy:
    """Translate ModalMuFormula → ReflTy."""
    if f.kind == FormulaKind.VAR:
        return ReflTy.base(f.index)
    elif f.kind == FormulaKind.TT:
        return ReflTy.unit()
    elif f.kind == FormulaKind.FF:
        return ReflTy.void()
    elif f.kind == FormulaKind.CONJ:
        assert f.left and f.right
        return ReflTy.prod(mu_to_refl(f.left), mu_to_refl(f.right))
    elif f.kind == FormulaKind.DISJ:
        assert f.left and f.right
        return ReflTy.sum_(mu_to_refl(f.left), mu_to_refl(f.right))
    elif f.kind == FormulaKind.IMPL:
        assert f.left and f.right
        return ReflTy.arrow(mu_to_refl(f.left), mu_to_refl(f.right))
    elif f.kind == FormulaKind.BOXF:
        assert f.body
        return ReflTy.box(mu_to_refl(f.body))
    elif f.kind == FormulaKind.MUF:
        assert f.body
        return ReflTy.mu(mu_to_refl(f.body))
    raise ValueError(f"Unknown formula kind: {f.kind}")


# ─── Notable Type Constructions ─────────────────────────────────────


def provable_not_provably_provable(p: ReflTy) -> ReflTy:
    """□P × (□□P → ⊥): 'P is provable but not provably provable'."""
    return ReflTy.prod(
        ReflTy.box(p),
        ReflTy.arrow(ReflTy.box(ReflTy.box(p)), ReflTy.void())
    )


def lob_type(p: ReflTy) -> ReflTy:
    """□(□P → P) → □P: Löb's axiom type."""
    return ReflTy.arrow(
        ReflTy.box(ReflTy.arrow(ReflTy.box(p), p)),
        ReflTy.box(p)
    )


def godel_sentence_type(p: ReflTy) -> ReflTy:
    """□P → ⊥: Gödel sentence type ('P is not provable')."""
    return ReflTy.arrow(ReflTy.box(p), ReflTy.void())


def k_axiom_type(a: ReflTy, b: ReflTy) -> ReflTy:
    """□(A → B) → □A → □B: Distribution axiom."""
    return ReflTy.arrow(
        ReflTy.box(ReflTy.arrow(a, b)),
        ReflTy.arrow(ReflTy.box(a), ReflTy.box(b))
    )


def four_axiom_type(a: ReflTy) -> ReflTy:
    """□A → □□A: Positive introspection."""
    return ReflTy.arrow(ReflTy.box(a), ReflTy.box(ReflTy.box(a)))


def iterated_box(n: int, a: ReflTy) -> ReflTy:
    """□^n A."""
    result = a
    for _ in range(n):
        result = ReflTy.box(result)
    return result


# ─── Proof Depth Algebra ────────────────────────────────────────────


@dataclass
class ProofDepthAlgebra:
    """Tracks depth, multiplicity, and fixed-point involvement."""
    level: int
    multiplicity: int
    has_fixpoint: bool

    @staticmethod
    def combine(a: 'ProofDepthAlgebra', b: 'ProofDepthAlgebra') -> 'ProofDepthAlgebra':
        if a.level > b.level:
            return ProofDepthAlgebra(a.level, a.multiplicity,
                                    a.has_fixpoint or b.has_fixpoint)
        elif a.level < b.level:
            return ProofDepthAlgebra(b.level, b.multiplicity,
                                    a.has_fixpoint or b.has_fixpoint)
        else:
            return ProofDepthAlgebra(a.level, a.multiplicity + b.multiplicity,
                                    a.has_fixpoint or b.has_fixpoint)

    def apply_box(self) -> 'ProofDepthAlgebra':
        return ProofDepthAlgebra(self.level + 1, self.multiplicity, self.has_fixpoint)


def compute_depth_algebra(ty: ReflTy) -> ProofDepthAlgebra:
    """Compute the depth algebra for a type."""
    if ty.kind in (TyKind.BASE, TyKind.UNIT, TyKind.VOID):
        return ProofDepthAlgebra(0, 1, False)
    elif ty.kind in (TyKind.ARROW, TyKind.PROD, TyKind.SUM):
        assert ty.left and ty.right
        return ProofDepthAlgebra.combine(
            compute_depth_algebra(ty.left),
            compute_depth_algebra(ty.right)
        )
    elif ty.kind == TyKind.BOX:
        assert ty.body
        return compute_depth_algebra(ty.body).apply_box()
    elif ty.kind == TyKind.MU:
        assert ty.body
        da = compute_depth_algebra(ty.body)
        return ProofDepthAlgebra(da.level, da.multiplicity, True)
    return ProofDepthAlgebra(0, 1, False)


# ─── Kripke Model Evaluation ────────────────────────────────────────


@dataclass
class KripkeModel:
    """A finite Kripke model."""
    worlds: list[int]
    accessibility: dict[int, list[int]]
    valuation: dict[tuple[int, int], bool]  # (world, prop_index) -> truth

    def is_transitive(self) -> bool:
        for w in self.worlds:
            for v in self.accessibility.get(w, []):
                for u in self.accessibility.get(v, []):
                    if u not in self.accessibility.get(w, []):
                        return False
        return True

    def evaluate(self, world: int, ty: ReflTy, max_mu_depth: int = 10) -> bool:
        """Evaluate satisfaction of a type at a world."""
        if ty.kind == TyKind.BASE:
            return self.valuation.get((world, ty.index), False)
        elif ty.kind == TyKind.UNIT:
            return True
        elif ty.kind == TyKind.VOID:
            return False
        elif ty.kind == TyKind.ARROW:
            assert ty.left and ty.right
            if self.evaluate(world, ty.left, max_mu_depth):
                return self.evaluate(world, ty.right, max_mu_depth)
            return True
        elif ty.kind == TyKind.PROD:
            assert ty.left and ty.right
            return (self.evaluate(world, ty.left, max_mu_depth) and
                    self.evaluate(world, ty.right, max_mu_depth))
        elif ty.kind == TyKind.SUM:
            assert ty.left and ty.right
            return (self.evaluate(world, ty.left, max_mu_depth) or
                    self.evaluate(world, ty.right, max_mu_depth))
        elif ty.kind == TyKind.BOX:
            assert ty.body
            return all(
                self.evaluate(v, ty.body, max_mu_depth)
                for v in self.accessibility.get(world, [])
            )
        elif ty.kind == TyKind.MU:
            assert ty.body
            if max_mu_depth <= 0:
                return False
            return self.evaluate(world, ty.body, max_mu_depth - 1)
        return False
