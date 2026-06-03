#!/usr/bin/env python3
"""
Algorithms for Paraconsistent Logic: Four-Valued Reasoning Engine

Type-hinted implementations of the core algorithms for Belnap's FDE logic,
including formula evaluation, satisfiability checking, and inconsistency
spectrum computation.
"""

from enum import Enum
from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Set, Tuple


# ═══════════════════════════════════════════════════════════════
# Core Types
# ═══════════════════════════════════════════════════════════════

class BelnapVal(Enum):
    """The four truth values of Belnap's logic FDE."""
    T = 0  # True only
    F = 1  # False only
    B = 2  # Both true and false
    N = 3  # Neither true nor false

    def is_true(self) -> bool:
        """Is this value at-least-true?"""
        return self in (BelnapVal.T, BelnapVal.B)

    def is_false(self) -> bool:
        """Is this value at-least-false?"""
        return self in (BelnapVal.F, BelnapVal.B)

    def neg(self) -> 'BelnapVal':
        """Belnap negation."""
        return _NEG_TABLE[self]

    def conj(self, other: 'BelnapVal') -> 'BelnapVal':
        """Belnap conjunction."""
        return _CONJ_TABLE[(self, other)]

    def disj(self, other: 'BelnapVal') -> 'BelnapVal':
        """Belnap disjunction."""
        return _DISJ_TABLE[(self, other)]


# Lookup tables for efficient computation
_NEG_TABLE: Dict[BelnapVal, BelnapVal] = {
    BelnapVal.T: BelnapVal.F,
    BelnapVal.F: BelnapVal.T,
    BelnapVal.B: BelnapVal.B,
    BelnapVal.N: BelnapVal.N,
}

_CONJ_TABLE: Dict[Tuple[BelnapVal, BelnapVal], BelnapVal] = {
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

_DISJ_TABLE: Dict[Tuple[BelnapVal, BelnapVal], BelnapVal] = {
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


# ═══════════════════════════════════════════════════════════════
# Formula AST
# ═══════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class FDEFormula:
    """Base class for FDE formulas."""
    pass


@dataclass(frozen=True)
class Atom(FDEFormula):
    """Atomic proposition."""
    index: int


@dataclass(frozen=True)
class Neg(FDEFormula):
    """Negation."""
    sub: FDEFormula


@dataclass(frozen=True)
class Conj(FDEFormula):
    """Conjunction."""
    left: FDEFormula
    right: FDEFormula


@dataclass(frozen=True)
class Disj(FDEFormula):
    """Disjunction."""
    left: FDEFormula
    right: FDEFormula


Valuation = Callable[[int], BelnapVal]


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: FDE Formula Evaluation
# ═══════════════════════════════════════════════════════════════

def evaluate(formula: FDEFormula, valuation: Valuation) -> BelnapVal:
    """
    Evaluate an FDE formula under a given valuation.

    Time complexity: O(|formula|)
    Space complexity: O(depth(formula)) for recursion stack

    Args:
        formula: The FDE formula to evaluate
        valuation: Maps atom indices to Belnap values

    Returns:
        The Belnap truth value of the formula
    """
    if isinstance(formula, Atom):
        return valuation(formula.index)
    elif isinstance(formula, Neg):
        return evaluate(formula.sub, valuation).neg()
    elif isinstance(formula, Conj):
        return evaluate(formula.left, valuation).conj(
            evaluate(formula.right, valuation)
        )
    elif isinstance(formula, Disj):
        return evaluate(formula.left, valuation).disj(
            evaluate(formula.right, valuation)
        )
    else:
        raise ValueError(f"Unknown formula type: {type(formula)}")


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: FDE Satisfiability
# ═══════════════════════════════════════════════════════════════

def collect_atoms(formula: FDEFormula) -> Set[int]:
    """Collect all atom indices in a formula."""
    if isinstance(formula, Atom):
        return {formula.index}
    elif isinstance(formula, Neg):
        return collect_atoms(formula.sub)
    elif isinstance(formula, (Conj, Disj)):
        return collect_atoms(formula.left) | collect_atoms(formula.right)
    return set()


def fde_satisfiable(formula: FDEFormula) -> Optional[Dict[int, BelnapVal]]:
    """
    Check if an FDE formula is satisfiable (has a valuation making it at-least-true).

    Brute-force search over all 4^n valuations where n = number of atoms.

    Time complexity: O(4^n * |formula|) where n = number of atoms
    Space complexity: O(n + |formula|)

    Returns:
        A satisfying valuation dict, or None if unsatisfiable
    """
    atoms = sorted(collect_atoms(formula))
    n = len(atoms)

    # Iterate over all 4^n valuations
    for code in range(4 ** n):
        assignment: Dict[int, BelnapVal] = {}
        c = code
        for atom in atoms:
            assignment[atom] = BelnapVal(c % 4)
            c //= 4

        val = lambda idx, a=assignment: a.get(idx, BelnapVal.N)
        if evaluate(formula, val).is_true():
            return assignment

    return None


def is_fde_tautology(formula: FDEFormula) -> bool:
    """
    Check if a formula is an FDE tautology (true under all valuations).

    Time complexity: O(4^n * |formula|)
    """
    atoms = sorted(collect_atoms(formula))
    n = len(atoms)

    for code in range(4 ** n):
        assignment: Dict[int, BelnapVal] = {}
        c = code
        for atom in atoms:
            assignment[atom] = BelnapVal(c % 4)
            c //= 4

        val = lambda idx, a=assignment: a.get(idx, BelnapVal.N)
        if not evaluate(formula, val).is_true():
            return False

    return True


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Inconsistency Spectrum Computation
# ═══════════════════════════════════════════════════════════════

@dataclass
class InconsistencySpectrum:
    """The four-component inconsistency spectrum of a theory."""
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
        return self.n_both / self.total if self.total > 0 else 0.0

    def is_nontrivial(self) -> bool:
        return self.n_true > 0 and self.n_false > 0


def compute_spectrum(truth_values: List[BelnapVal]) -> InconsistencySpectrum:
    """
    Compute the inconsistency spectrum of a theory.

    Time complexity: O(n) where n = number of sentences

    Args:
        truth_values: List of truth values for each sentence

    Returns:
        The inconsistency spectrum
    """
    counts = {v: 0 for v in BelnapVal}
    for v in truth_values:
        counts[v] += 1
    return InconsistencySpectrum(
        n_true=counts[BelnapVal.T],
        n_false=counts[BelnapVal.F],
        n_both=counts[BelnapVal.B],
        n_neither=counts[BelnapVal.N],
    )


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Paradox Span Computation
# ═══════════════════════════════════════════════════════════════

def compute_paradox_span(
    truth: Callable[[int], BelnapVal],
    neg_fn: Callable[[int], int],
    conj_fn: Callable[[int, int], int],
    disj_fn: Callable[[int, int], int],
    seeds: Set[int],
    universe: Set[int],
) -> Set[int]:
    """
    Compute the paradox span: closure of seeds under neg, conj, disj.

    Uses a worklist algorithm (BFS-style closure).

    Time complexity: O(n^2) where n = |universe|
    Space complexity: O(n)

    Args:
        truth: Truth valuation function
        neg_fn: Sentence negation function
        conj_fn: Sentence conjunction function
        disj_fn: Sentence disjunction function
        seeds: Initial set of dialetheia sentence indices
        universe: All sentence indices

    Returns:
        The paradox span (closure of seeds under connectives)
    """
    span = set(seeds)
    worklist = list(seeds)

    while worklist:
        s = worklist.pop()

        # Apply negation
        ns = neg_fn(s)
        if ns in universe and ns not in span:
            span.add(ns)
            worklist.append(ns)

        # Apply conjunction and disjunction with all span elements
        for t in list(span):
            cs = conj_fn(s, t)
            if cs in universe and cs not in span:
                span.add(cs)
                worklist.append(cs)

            ds = disj_fn(s, t)
            if ds in universe and ds not in span:
                span.add(ds)
                worklist.append(ds)

    return span


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Negation Fixed Point Finder
# ═══════════════════════════════════════════════════════════════

def find_negation_fixed_points() -> List[BelnapVal]:
    """
    Find all Belnap values that are fixed points of negation.

    Returns: List of fixed points (should be [B, N])
    """
    return [v for v in BelnapVal if v.neg() == v]


def find_true_fixed_points() -> List[BelnapVal]:
    """
    Find all Belnap values that are both negation fixed points
    and at-least-true.

    Returns: List of true fixed points (should be [B] only)
    """
    return [v for v in BelnapVal if v.neg() == v and v.is_true()]


# ═══════════════════════════════════════════════════════════════
# Main: Run all algorithms
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Paraconsistent Logic Algorithms")
    print("=" * 50)

    # Test negation fixed points
    print("\n1. Negation Fixed Points:")
    fps = find_negation_fixed_points()
    print(f"   All fixed points: {[v.name for v in fps]}")
    tfps = find_true_fixed_points()
    print(f"   True fixed points: {[v.name for v in tfps]}")

    # Test FDE satisfiability
    print("\n2. FDE Satisfiability:")
    # p ∨ ¬p (excluded middle) — should be satisfiable but not a tautology
    em = Disj(Atom(0), Neg(Atom(0)))
    print(f"   p ∨ ¬p is tautology? {is_fde_tautology(em)}")
    sat = fde_satisfiable(em)
    print(f"   p ∨ ¬p is satisfiable? {sat is not None}")

    # p ∧ ¬p (contradiction) — satisfiable in FDE!
    contra = Conj(Atom(0), Neg(Atom(0)))
    sat = fde_satisfiable(contra)
    print(f"   p ∧ ¬p is satisfiable? {sat is not None} (assignment: {sat})")

    # Test inconsistency spectrum
    print("\n3. Inconsistency Spectrum:")
    vals = [BelnapVal.T, BelnapVal.B, BelnapVal.F, BelnapVal.B, BelnapVal.T, BelnapVal.N]
    spec = compute_spectrum(vals)
    print(f"   True: {spec.n_true}, False: {spec.n_false}, "
          f"Both: {spec.n_both}, Neither: {spec.n_neither}")
    print(f"   Inconsistency degree: {spec.inconsistency_degree}")
    print(f"   Inconsistency ratio: {spec.inconsistency_ratio:.1%}")
    print(f"   Non-trivial: {spec.is_nontrivial()}")
