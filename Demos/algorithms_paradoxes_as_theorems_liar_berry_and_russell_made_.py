"""
Dialectical Algebra: Algorithms
================================
Type-hinted implementations of key algorithms from the dialectical algebra framework.
"""

from enum import Enum
from typing import List, Tuple, Dict, Set, Optional, Callable
from dataclasses import dataclass


class DVal(Enum):
    """Four-valued truth space for dialectical logic."""
    T = "true"
    F = "false"
    B = "both"
    N = "neither"


def neg(v: DVal) -> DVal:
    """Negation involution on DVal."""
    return {DVal.T: DVal.F, DVal.F: DVal.T, DVal.B: DVal.B, DVal.N: DVal.N}[v]


def is_true(v: DVal) -> bool:
    """Truth projection: at-least-true."""
    return v in (DVal.T, DVal.B)


def is_false(v: DVal) -> bool:
    """Falsity projection: at-least-false."""
    return v in (DVal.F, DVal.B)


def meet(a: DVal, b: DVal) -> DVal:
    """Conjunction (truth-ordering meet)."""
    if a == DVal.T:
        return b
    if b == DVal.T:
        return a
    if a == DVal.F or b == DVal.F:
        return DVal.F
    if a == DVal.B and b == DVal.B:
        return DVal.B
    if (a == DVal.B and b == DVal.N) or (a == DVal.N and b == DVal.B):
        return DVal.F
    return DVal.N  # N, N


def join(a: DVal, b: DVal) -> DVal:
    """Disjunction (truth-ordering join)."""
    if a == DVal.F:
        return b
    if b == DVal.F:
        return a
    if a == DVal.T or b == DVal.T:
        return DVal.T
    if a == DVal.B and b == DVal.B:
        return DVal.B
    if (a == DVal.B and b == DVal.N) or (a == DVal.N and b == DVal.B):
        return DVal.T
    return DVal.N  # N, N


@dataclass
class DialecticalAlgebra:
    """A dialectical algebra over sentences indexed by integers."""
    n: int
    val: Callable[[int], DVal]
    sent_neg: Callable[[int], int]
    sent_conj: Callable[[int, int], int]
    sent_disj: Callable[[int, int], int]
    tau: Callable[[int], int]


def classify_fixed_point(v: DVal) -> str:
    """
    Algorithm 1: Classify a negation fixed point.

    Given a value v with v = neg(v), classify it as:
    - "dialetheia" if v = B (both true and false)
    - "gap" if v = N (neither true nor false)
    - "not_fixed" if v ≠ neg(v)
    """
    if v != neg(v):
        return "not_fixed"
    if is_true(v):
        return "dialetheia"
    return "gap"


def verify_soundness(algebra: DialecticalAlgebra,
                     provable: Set[int]) -> Tuple[bool, Optional[int]]:
    """
    Algorithm 2: Verify self-soundness of a dialectical algebra.

    Returns (is_sound, counterexample).
    - If sound, returns (True, None).
    - If unsound, returns (False, offending_sentence).
    """
    for s in provable:
        if not is_true(algebra.val(s)):
            return (False, s)
    return (True, None)


def compute_spectrum(algebra: DialecticalAlgebra) -> Dict[DVal, int]:
    """
    Algorithm 3: Compute the dialectical spectrum.

    Returns counts of each truth value.
    """
    counts = {v: 0 for v in DVal}
    for i in range(algebra.n):
        counts[algebra.val(i)] += 1
    return counts


def inconsistency_degree(algebra: DialecticalAlgebra) -> int:
    """
    Algorithm 4: Compute the inconsistency degree.

    Returns the number of B-valued sentences.
    """
    return sum(1 for i in range(algebra.n) if algebra.val(i) == DVal.B)


def is_nontrivial(algebra: DialecticalAlgebra) -> bool:
    """
    Algorithm 5: Check if an algebra is non-trivial.

    An algebra is non-trivial if it has both T and F valued sentences.
    """
    has_t = any(algebra.val(i) == DVal.T for i in range(algebra.n))
    has_f = any(algebra.val(i) == DVal.F for i in range(algebra.n))
    return has_t and has_f


def paradox_set(algebra: DialecticalAlgebra) -> Set[int]:
    """
    Algorithm 6: Compute the paradox set.

    Returns the set of sentence indices with value B.
    """
    return {i for i in range(algebra.n) if algebra.val(i) == DVal.B}


def gap_set(algebra: DialecticalAlgebra) -> Set[int]:
    """
    Algorithm 7: Compute the gap set.

    Returns the set of sentence indices with value N.
    """
    return {i for i in range(algebra.n) if algebra.val(i) == DVal.N}


def fixed_point_set(algebra: DialecticalAlgebra) -> Set[int]:
    """
    Algorithm 8: Compute the negation fixed-point set.

    Returns paradox_set ∪ gap_set.
    """
    return paradox_set(algebra) | gap_set(algebra)


def verify_sublattice_closure(algebra: DialecticalAlgebra) -> bool:
    """
    Algorithm 9: Verify paradox sublattice closure.

    Checks that the paradox set is closed under neg, conj, disj.
    """
    ps = paradox_set(algebra)
    # Check neg closure
    for s in ps:
        if algebra.sent_neg(s) not in range(algebra.n):
            return False
        if algebra.val(algebra.sent_neg(s)) != DVal.B:
            return False
    # Check conj closure
    for s in ps:
        for u in ps:
            c = algebra.sent_conj(s, u)
            if c not in range(algebra.n) or algebra.val(c) != DVal.B:
                return False
    # Check disj closure
    for s in ps:
        for u in ps:
            d = algebra.sent_disj(s, u)
            if d not in range(algebra.n) or algebra.val(d) != DVal.B:
                return False
    return True


def find_dialectical_ramsey_triple(
    algebra: DialecticalAlgebra
) -> Optional[Tuple[int, int, int]]:
    """
    Algorithm 10: Find three distinct paradoxical sentences (Dialectical Ramsey).

    Returns a triple (s1, s2, s3) of distinct B-valued sentences, or None.
    """
    ps = sorted(paradox_set(algebra))
    if len(ps) >= 3:
        return (ps[0], ps[1], ps[2])
    return None


# ============================================================
# Example: Construct the minimal dialectical algebra
# ============================================================
def make_minimal_algebra() -> DialecticalAlgebra:
    """Construct the minimal dialectical algebra on 4 sentences."""
    vals = [DVal.T, DVal.F, DVal.B, DVal.N]
    neg_map = [1, 0, 2, 3]  # T↔F, B→B, N→N

    return DialecticalAlgebra(
        n=4,
        val=lambda i: vals[i],
        sent_neg=lambda i: neg_map[i],
        sent_conj=lambda i, j: i,  # trivial for demo
        sent_disj=lambda i, j: i,  # trivial for demo
        tau=lambda i: i,
    )


if __name__ == "__main__":
    algebra = make_minimal_algebra()

    print("Minimal Dialectical Algebra")
    print("=" * 40)

    spectrum = compute_spectrum(algebra)
    print(f"Spectrum: {spectrum}")
    print(f"Inconsistency degree: {inconsistency_degree(algebra)}")
    print(f"Non-trivial: {is_nontrivial(algebra)}")
    print(f"Paradox set: {paradox_set(algebra)}")
    print(f"Gap set: {gap_set(algebra)}")
    print(f"Fixed-point set: {fixed_point_set(algebra)}")

    provable = {0, 2}  # T and B sentences
    sound, cex = verify_soundness(algebra, provable)
    print(f"\nSoundness of {{T, B}}: {sound}")

    for v in DVal:
        print(f"  classify({v.name}) = {classify_fixed_point(v)}")
