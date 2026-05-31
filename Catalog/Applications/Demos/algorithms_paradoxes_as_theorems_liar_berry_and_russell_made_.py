"""
Paraconsistent Logic Algorithms
===============================

Type-hinted implementations of the Belnap four-valued logic system,
FDE formula evaluation, and paradox detection.
"""

from enum import Enum
from typing import Callable, Optional
from dataclasses import dataclass


class BelnapVal(Enum):
    """Belnap's four truth values."""
    T = "true"       # true only
    F = "false"      # false only
    B = "both"       # both true and false (dialetheia)
    N = "neither"    # neither true nor false (gap)

    @property
    def is_true(self) -> bool:
        """Value is at-least-true."""
        return self in (BelnapVal.T, BelnapVal.B)

    @property
    def is_false(self) -> bool:
        """Value is at-least-false."""
        return self in (BelnapVal.F, BelnapVal.B)

    def neg(self) -> 'BelnapVal':
        """Belnap negation: T↔F, B↔B, N↔N."""
        return {
            BelnapVal.T: BelnapVal.F,
            BelnapVal.F: BelnapVal.T,
            BelnapVal.B: BelnapVal.B,
            BelnapVal.N: BelnapVal.N,
        }[self]

    def conj(self, other: 'BelnapVal') -> 'BelnapVal':
        """Belnap conjunction (truth-order meet)."""
        table = {
            (BelnapVal.T, BelnapVal.T): BelnapVal.T,
            (BelnapVal.T, BelnapVal.F): BelnapVal.F,
            (BelnapVal.T, BelnapVal.B): BelnapVal.B,
            (BelnapVal.T, BelnapVal.N): BelnapVal.N,
            (BelnapVal.F, BelnapVal.T): BelnapVal.F,
            (BelnapVal.F, BelnapVal.F): BelnapVal.F,
            (BelnapVal.F, BelnapVal.B): BelnapVal.F,
            (BelnapVal.F, BelnapVal.N): BelnapVal.F,
            (BelnapVal.B, BelnapVal.T): BelnapVal.B,
            (BelnapVal.B, BelnapVal.F): BelnapVal.F,
            (BelnapVal.B, BelnapVal.B): BelnapVal.B,
            (BelnapVal.B, BelnapVal.N): BelnapVal.F,
            (BelnapVal.N, BelnapVal.T): BelnapVal.N,
            (BelnapVal.N, BelnapVal.F): BelnapVal.F,
            (BelnapVal.N, BelnapVal.B): BelnapVal.F,
            (BelnapVal.N, BelnapVal.N): BelnapVal.N,
        }
        return table[(self, other)]

    def disj(self, other: 'BelnapVal') -> 'BelnapVal':
        """Belnap disjunction (truth-order join)."""
        table = {
            (BelnapVal.T, BelnapVal.T): BelnapVal.T,
            (BelnapVal.T, BelnapVal.F): BelnapVal.T,
            (BelnapVal.T, BelnapVal.B): BelnapVal.T,
            (BelnapVal.T, BelnapVal.N): BelnapVal.T,
            (BelnapVal.F, BelnapVal.T): BelnapVal.T,
            (BelnapVal.F, BelnapVal.F): BelnapVal.F,
            (BelnapVal.F, BelnapVal.B): BelnapVal.B,
            (BelnapVal.F, BelnapVal.N): BelnapVal.N,
            (BelnapVal.B, BelnapVal.T): BelnapVal.T,
            (BelnapVal.B, BelnapVal.F): BelnapVal.B,
            (BelnapVal.B, BelnapVal.B): BelnapVal.B,
            (BelnapVal.B, BelnapVal.N): BelnapVal.T,
            (BelnapVal.N, BelnapVal.T): BelnapVal.T,
            (BelnapVal.N, BelnapVal.F): BelnapVal.N,
            (BelnapVal.N, BelnapVal.B): BelnapVal.T,
            (BelnapVal.N, BelnapVal.N): BelnapVal.N,
        }
        return table[(self, other)]


@dataclass
class FDEFormula:
    """First-Degree Entailment formula."""
    kind: str  # 'atom', 'neg', 'conj', 'disj'
    index: Optional[int] = None
    left: Optional['FDEFormula'] = None
    right: Optional['FDEFormula'] = None

    @staticmethod
    def atom(n: int) -> 'FDEFormula':
        return FDEFormula(kind='atom', index=n)

    @staticmethod
    def neg(phi: 'FDEFormula') -> 'FDEFormula':
        return FDEFormula(kind='neg', left=phi)

    @staticmethod
    def conj(phi: 'FDEFormula', psi: 'FDEFormula') -> 'FDEFormula':
        return FDEFormula(kind='conj', left=phi, right=psi)

    @staticmethod
    def disj(phi: 'FDEFormula', psi: 'FDEFormula') -> 'FDEFormula':
        return FDEFormula(kind='disj', left=phi, right=psi)

    @staticmethod
    def impl(phi: 'FDEFormula', psi: 'FDEFormula') -> 'FDEFormula':
        """Material conditional: ¬φ ∨ ψ."""
        return FDEFormula.disj(FDEFormula.neg(phi), psi)

    def eval(self, v: Callable[[int], BelnapVal]) -> BelnapVal:
        """Evaluate formula under valuation v."""
        if self.kind == 'atom':
            return v(self.index)
        elif self.kind == 'neg':
            return self.left.eval(v).neg()
        elif self.kind == 'conj':
            return self.left.eval(v).conj(self.right.eval(v))
        elif self.kind == 'disj':
            return self.left.eval(v).disj(self.right.eval(v))
        raise ValueError(f"Unknown formula kind: {self.kind}")


def check_fde_tautology(phi: FDEFormula, atoms: list[int]) -> bool:
    """Check if phi is an FDE tautology by exhaustive search over all 4^n valuations."""
    import itertools
    vals = list(BelnapVal)
    for assignment in itertools.product(vals, repeat=len(atoms)):
        v_dict = dict(zip(atoms, assignment))
        v = lambda n, d=v_dict: d.get(n, BelnapVal.N)
        if not phi.eval(v).is_true:
            return False
    return True


def find_counterexample(phi: FDEFormula, atoms: list[int]) -> Optional[dict[int, BelnapVal]]:
    """Find a counterexample to phi being an FDE tautology."""
    import itertools
    vals = list(BelnapVal)
    for assignment in itertools.product(vals, repeat=len(atoms)):
        v_dict = dict(zip(atoms, assignment))
        v = lambda n, d=v_dict: d.get(n, BelnapVal.N)
        if not phi.eval(v).is_true:
            return v_dict
    return None


def inconsistency_degree(truth_values: list[BelnapVal]) -> int:
    """Count the number of dialetheias (B-valued sentences)."""
    return sum(1 for v in truth_values if v == BelnapVal.B)


def berry_pigeonhole(n_objects: int, n_descriptions: int) -> tuple[bool, str]:
    """
    Demonstrate Berry's paradox: if n_objects > n_descriptions,
    some object must be undefinable (or share a description).
    """
    if n_objects > n_descriptions:
        return True, (
            f"With {n_objects} objects and only {n_descriptions} descriptions, "
            f"at least {n_objects - n_descriptions} objects must share descriptions "
            f"(pigeonhole principle)."
        )
    return False, "Sufficient descriptions available."


def liar_tower(n: int) -> list[BelnapVal]:
    """Compute the Liar tower: iterated negation starting from B."""
    tower = [BelnapVal.B]
    for _ in range(n):
        tower.append(tower[-1].neg())
    return tower
