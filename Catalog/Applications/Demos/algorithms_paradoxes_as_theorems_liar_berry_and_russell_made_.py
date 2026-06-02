#!/usr/bin/env python3
"""
Algorithms for Paraconsistent Logic and the Inconsistency Spectrum.

Type-hinted implementations of core algorithms for Belnap's four-valued logic,
FDE formula evaluation, inconsistency spectrum computation, and paradox detection.
"""

from enum import Enum
from dataclasses import dataclass
from typing import Dict, List, Tuple, Set, Optional, Callable


class BelnapVal(Enum):
    """Belnap's four truth values with associated operations."""
    T = 0  # True only
    F = 1  # False only
    B = 2  # Both true and false
    N = 3  # Neither true nor false

    def is_true(self) -> bool:
        return self in (BelnapVal.T, BelnapVal.B)

    def is_false(self) -> bool:
        return self in (BelnapVal.F, BelnapVal.B)

    def neg(self) -> 'BelnapVal':
        return _NEG_TABLE[self]

    def conj(self, other: 'BelnapVal') -> 'BelnapVal':
        return _CONJ_TABLE[(self, other)]

    def disj(self, other: 'BelnapVal') -> 'BelnapVal':
        return _DISJ_TABLE[(self, other)]

    def info_le(self, other: 'BelnapVal') -> bool:
        """Information ordering: N ≤ everything, T,F ≤ B."""
        return _INFO_LE[(self, other)]


# Precomputed tables for O(1) operations
_NEG_TABLE = {
    BelnapVal.T: BelnapVal.F, BelnapVal.F: BelnapVal.T,
    BelnapVal.B: BelnapVal.B, BelnapVal.N: BelnapVal.N,
}

_CONJ_TABLE = {}
_DISJ_TABLE = {}
_INFO_LE = {}

def _init_tables():
    T, F, B, N = BelnapVal.T, BelnapVal.F, BelnapVal.B, BelnapVal.N
    conj_raw = {
        (T,T):T, (T,F):F, (T,B):B, (T,N):N,
        (F,T):F, (F,F):F, (F,B):F, (F,N):F,
        (B,T):B, (B,F):F, (B,B):B, (B,N):F,
        (N,T):N, (N,F):F, (N,B):F, (N,N):N,
    }
    disj_raw = {
        (T,T):T, (T,F):T, (T,B):T, (T,N):T,
        (F,T):T, (F,F):F, (F,B):B, (F,N):N,
        (B,T):T, (B,F):B, (B,B):B, (B,N):T,
        (N,T):T, (N,F):N, (N,B):T, (N,N):N,
    }
    info_le_raw = {
        (N,N):True,(N,T):True,(N,F):True,(N,B):True,
        (T,N):False,(T,T):True,(T,F):False,(T,B):True,
        (F,N):False,(F,T):False,(F,F):True,(F,B):True,
        (B,N):False,(B,T):False,(B,F):False,(B,B):True,
    }
    _CONJ_TABLE.update(conj_raw)
    _DISJ_TABLE.update(disj_raw)
    _INFO_LE.update(info_le_raw)

_init_tables()


# ─── FDE Formula AST ──────────────────────────────────────────

@dataclass(frozen=True)
class Atom:
    """Propositional atom."""
    index: int

@dataclass(frozen=True)
class Neg:
    """Negation."""
    sub: 'FDEFormula'

@dataclass(frozen=True)
class Conj:
    """Conjunction."""
    left: 'FDEFormula'
    right: 'FDEFormula'

@dataclass(frozen=True)
class Disj:
    """Disjunction."""
    left: 'FDEFormula'
    right: 'FDEFormula'

FDEFormula = Atom | Neg | Conj | Disj


def eval_formula(v: Callable[[int], BelnapVal], phi: FDEFormula) -> BelnapVal:
    """Evaluate an FDE formula under a valuation."""
    match phi:
        case Atom(i):
            return v(i)
        case Neg(sub):
            return eval_formula(v, sub).neg()
        case Conj(left, right):
            return eval_formula(v, left).conj(eval_formula(v, right))
        case Disj(left, right):
            return eval_formula(v, left).disj(eval_formula(v, right))


def is_fde_tautology(phi: FDEFormula, n_vars: int) -> bool:
    """Check if a formula is an FDE tautology (at-least-true under all valuations).

    Exhaustive check over all 4^n_vars valuations.
    Complexity: O(4^n_vars × |phi|)
    """
    vals = list(BelnapVal)
    for assignment in _all_assignments(n_vars, vals):
        v = lambda i, a=assignment: a.get(i, BelnapVal.N)
        if not eval_formula(v, phi).is_true():
            return False
    return True


def check_entailment(phi: FDEFormula, psi: FDEFormula, n_vars: int) -> bool:
    """Check if phi FDE-entails psi (truth-preserving).

    φ ⊨ ψ iff for all v: isTrue(φ(v)) → isTrue(ψ(v))
    """
    vals = list(BelnapVal)
    for assignment in _all_assignments(n_vars, vals):
        v = lambda i, a=assignment: a.get(i, BelnapVal.N)
        if eval_formula(v, phi).is_true() and not eval_formula(v, psi).is_true():
            return False
    return True


def _all_assignments(n: int, vals: List[BelnapVal]) -> List[Dict[int, BelnapVal]]:
    """Generate all possible assignments for n variables."""
    if n == 0:
        return [{}]
    rest = _all_assignments(n - 1, vals)
    result = []
    for v in vals:
        for a in rest:
            new_a = dict(a)
            new_a[n - 1] = v
            result.append(new_a)
    return result


# ─── Inconsistency Spectrum ──────────────────────────────────

@dataclass
class InconsistencySpectrum:
    """The distribution of truth values in a finite theory."""
    n_true: int
    n_false: int
    n_both: int
    n_neither: int

    @property
    def total(self) -> int:
        return self.n_true + self.n_false + self.n_both + self.n_neither

    @property
    def inconsistency_degree(self) -> int:
        return self.n_both

    @property
    def inconsistency_ratio(self) -> float:
        return self.n_both / max(1, self.total)

    def is_nontrivial(self) -> bool:
        return self.n_true > 0 and self.n_false > 0

    def satisfies_tolerance(self) -> bool:
        """Check: n_both ≤ total - 2 when non-trivial."""
        if not self.is_nontrivial():
            return True
        return self.n_both <= self.total - 2


def compute_spectrum(truth_values: List[BelnapVal]) -> InconsistencySpectrum:
    """Compute the inconsistency spectrum of a list of truth values."""
    return InconsistencySpectrum(
        n_true=sum(1 for v in truth_values if v == BelnapVal.T),
        n_false=sum(1 for v in truth_values if v == BelnapVal.F),
        n_both=sum(1 for v in truth_values if v == BelnapVal.B),
        n_neither=sum(1 for v in truth_values if v == BelnapVal.N),
    )


# ─── Paradox Detection ──────────────────────────────────────

def find_negation_fixed_points(vals: List[BelnapVal]) -> List[int]:
    """Find indices where val == neg(val) (Liar-type fixed points)."""
    return [i for i, v in enumerate(vals) if v == v.neg()]


def detect_berry_collision(
    objects: List[int],
    descriptions: List[int],
    assignment: Dict[int, int]
) -> Optional[Tuple[int, int]]:
    """Detect a Berry-type collision: two objects mapped to the same description.

    Returns a pair (o1, o2) with o1 ≠ o2 and assignment[o1] == assignment[o2],
    or None if no collision exists.
    """
    desc_to_obj: Dict[int, int] = {}
    for obj in objects:
        desc = assignment.get(obj)
        if desc is not None and desc in desc_to_obj:
            return (desc_to_obj[desc], obj)
        if desc is not None:
            desc_to_obj[desc] = obj
    return None


# ─── Self-Soundness Check ──────────────────────────────────

def check_self_soundness(
    truth_values: Dict[str, BelnapVal],
    provable: Set[str],
    soundness_sentence: str
) -> Tuple[bool, str]:
    """Check if a theory is self-sound.

    Returns (is_sound, explanation).
    """
    # Check all provable sentences are at-least-true
    for s in provable:
        if s not in truth_values:
            return False, f"Provable sentence '{s}' has no truth value"
        if not truth_values[s].is_true():
            return False, f"Provable sentence '{s}' has value {truth_values[s].name}, not at-least-true"

    # Check soundness sentence is provable and at-least-true
    if soundness_sentence not in provable:
        return False, f"Soundness sentence '{soundness_sentence}' is not provable"
    if not truth_values[soundness_sentence].is_true():
        return False, f"Soundness sentence has value {truth_values[soundness_sentence].name}"

    return True, "Theory is self-sound"


# ─── Paradox Endomorphism ──────────────────────────────────

@dataclass
class ParadoxEndomorphism:
    """A function BelnapVal → BelnapVal preserving B and N."""
    fn: Callable[[BelnapVal], BelnapVal]
    name: str

    def __call__(self, v: BelnapVal) -> BelnapVal:
        return self.fn(v)

    def compose(self, other: 'ParadoxEndomorphism') -> 'ParadoxEndomorphism':
        return ParadoxEndomorphism(
            fn=lambda v, f=self.fn, g=other.fn: f(g(v)),
            name=f"{self.name} ∘ {other.name}"
        )

    def is_valid(self) -> bool:
        return self.fn(BelnapVal.B) == BelnapVal.B and self.fn(BelnapVal.N) == BelnapVal.N


# Standard paradox endomorphisms
IDENTITY = ParadoxEndomorphism(lambda v: v, "id")
NEGATION = ParadoxEndomorphism(lambda v: v.neg(), "neg")


if __name__ == "__main__":
    # Quick test
    print("FDE Tautology check: p ∨ ¬p?",
          is_fde_tautology(Disj(Atom(0), Neg(Atom(0))), 1))
    print("FDE Tautology check: ¬¬p → p?",
          check_entailment(Neg(Neg(Atom(0))), Atom(0), 1))

    # Inconsistency spectrum
    spec = compute_spectrum([BelnapVal.T, BelnapVal.T, BelnapVal.F, BelnapVal.B, BelnapVal.N])
    print(f"Spectrum: T={spec.n_true}, F={spec.n_false}, B={spec.n_both}, N={spec.n_neither}")
    print(f"Satisfies tolerance: {spec.satisfies_tolerance()}")

    # Self-soundness
    tv = {"axiom": BelnapVal.T, "liar": BelnapVal.B, "soundness": BelnapVal.T}
    prov = {"axiom", "liar", "soundness"}
    ok, msg = check_self_soundness(tv, prov, "soundness")
    print(f"Self-sound: {ok} — {msg}")
