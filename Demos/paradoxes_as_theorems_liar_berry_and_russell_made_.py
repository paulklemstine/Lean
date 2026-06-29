"""
demo.py — Paradoxes as Theorems: Liar, Berry, and Russell Made Consistent
=========================================================================

Self-contained numerical demonstrations of the four-valued (Belnap / FDE)
paraconsistent theory in which the Liar, Russell, and Berry paradoxes become
sound provable theorems instead of contradictions.

Every function is inlined; the file has no third-party dependencies and runs
with `python3 demo.py`.

The four Belnap values are:
    T = true only,  F = false only,  B = both (glut),  N = neither (gap).
Designated ("at-least-true") values are {T, B}.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from itertools import product
from typing import Callable, Dict, List, Tuple


# ---------------------------------------------------------------------------
# 1. The four-valued lattice (Belnap / First-Degree Entailment)
# ---------------------------------------------------------------------------

class Belnap(Enum):
    """Belnap's four truth values."""
    T = "T"  # true only
    F = "F"  # false only
    B = "B"  # both true and false (glut / dialetheia)
    N = "N"  # neither true nor false (gap)

    def __repr__(self) -> str:  # pragma: no cover - cosmetic
        return self.value


def neg(v: Belnap) -> Belnap:
    """Belnap negation: swaps T/F, fixes B and N."""
    return {Belnap.T: Belnap.F, Belnap.F: Belnap.T,
            Belnap.B: Belnap.B, Belnap.N: Belnap.N}[v]


# Truth ordering F < N,B < T (N and B incomparable).  conj = meet, disj = join.
_DISJ: Dict[Tuple[Belnap, Belnap], Belnap] = {}
_CONJ: Dict[Tuple[Belnap, Belnap], Belnap] = {}


def _build_tables() -> None:
    """Construct the FDE conjunction/disjunction tables via the truth lattice."""
    # Each value is a pair (is_true, is_false) of booleans.
    bits = {
        Belnap.T: (True, False),
        Belnap.F: (False, True),
        Belnap.B: (True, True),
        Belnap.N: (False, False),
    }
    inv = {b: v for v, b in bits.items()}
    for a, b in product(Belnap, Belnap):
        at, af = bits[a]
        bt, bf = bits[b]
        # disjunction: true if either is true, false if both are false
        _DISJ[(a, b)] = inv[(at or bt, af and bf)]
        # conjunction: true if both true, false if either false
        _CONJ[(a, b)] = inv[(at and bt, af or bf)]


_build_tables()


def disj(a: Belnap, b: Belnap) -> Belnap:
    """FDE disjunction (join in the truth order)."""
    return _DISJ[(a, b)]


def conj(a: Belnap, b: Belnap) -> Belnap:
    """FDE conjunction (meet in the truth order)."""
    return _CONJ[(a, b)]


def is_true(v: Belnap) -> bool:
    """Designation: a value is at-least-true iff it is T or B."""
    return v in (Belnap.T, Belnap.B)


# ---------------------------------------------------------------------------
# 2. Diagonal paradox engine (Liar / Russell)
# ---------------------------------------------------------------------------

def diagonal_value(apply: Callable[[int, int], Belnap], diag: int) -> Belnap:
    """
    Given a diagonal system whose diagonal element satisfies
        apply(diag, x) = neg(apply(x, x))   for all x,
    return apply(diag, diag).  By the diagonal value theorem this must be B or N.
    """
    return apply(diag, diag)


def liar_tower(n: int) -> Belnap:
    """Iterated negation starting from B: stays constant at B for all n."""
    v = Belnap.B
    for _ in range(n):
        v = neg(v)
    return v


# ---------------------------------------------------------------------------
# 3. Berry's paradox as a finite pigeonhole bound
# ---------------------------------------------------------------------------

def berry_collision(objects: List[int],
                    descriptions: List[int],
                    definability: Callable[[int], int]) -> Tuple[int, int]:
    """
    If |objects| > |descriptions| and definability maps each object into
    descriptions, return a pair of distinct objects sharing a description.
    Raises ValueError if no overflow (no collision guaranteed).
    """
    if len(objects) <= len(descriptions):
        raise ValueError("no Berry overflow: collision not guaranteed")
    seen: Dict[int, int] = {}
    for o in objects:
        d = definability(o)
        if d not in descriptions:
            raise ValueError(f"object {o} mapped outside descriptions")
        if d in seen:
            return (seen[d], o)
        seen[d] = o
    raise RuntimeError("unreachable by pigeonhole")  # pragma: no cover


# ---------------------------------------------------------------------------
# 4. Inconsistency spectrum
# ---------------------------------------------------------------------------

@dataclass
class Spectrum:
    """Counts of each Belnap value across a finite theory."""
    nT: int
    nF: int
    nB: int
    nN: int

    @property
    def inconsistency_degree(self) -> int:
        """Number of gluts (dialetheias)."""
        return self.nB

    @property
    def total(self) -> int:
        return self.nT + self.nF + self.nB + self.nN


def compute_spectrum(truth: Dict[int, Belnap]) -> Spectrum:
    """Tabulate the spectrum of a finite truth assignment."""
    counts = {v: 0 for v in Belnap}
    for val in truth.values():
        counts[val] += 1
    return Spectrum(counts[Belnap.T], counts[Belnap.F],
                    counts[Belnap.B], counts[Belnap.N])


def has_explosion(truth: Dict[int, Belnap]) -> bool:
    """Explosion: some glut forces every sentence to be at-least-true."""
    glut_exists = any(v == Belnap.B for v in truth.values())
    all_true = all(is_true(v) for v in truth.values())
    return glut_exists and all_true


# ---------------------------------------------------------------------------
# 5. FDE formula evaluation (for excluded middle / modus ponens / DNE)
# ---------------------------------------------------------------------------

@dataclass
class Atom:
    idx: int


@dataclass
class Neg:
    sub: "Formula"


@dataclass
class Disj:
    left: "Formula"
    right: "Formula"


@dataclass
class Conj:
    left: "Formula"
    right: "Formula"


Formula = object  # one of Atom | Neg | Disj | Conj


def evaluate(phi: Formula, assignment: Dict[int, Belnap]) -> Belnap:
    """Evaluate an FDE formula under an atom assignment."""
    if isinstance(phi, Atom):
        return assignment[phi.idx]
    if isinstance(phi, Neg):
        return neg(evaluate(phi.sub, assignment))
    if isinstance(phi, Disj):
        return disj(evaluate(phi.left, assignment), evaluate(phi.right, assignment))
    if isinstance(phi, Conj):
        return conj(evaluate(phi.left, assignment), evaluate(phi.right, assignment))
    raise TypeError(f"unknown formula node: {phi!r}")


def implies(phi: Formula, psi: Formula) -> Formula:
    """Material implication in FDE: neg(phi) or psi."""
    return Disj(Neg(phi), psi)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_negation_fixed_points() -> None:
    print("=" * 70)
    print("1. Negation fixes the non-classical values (Lemma 2.4)")
    print("=" * 70)
    for v in Belnap:
        print(f"   neg({v.value}) = {neg(v).value}"
              f"     fixed point of negation: {v == neg(v)}")
    fixed = [v.value for v in Belnap if v == neg(v)]
    print(f"   --> fixed points of negation: {fixed}  (exactly B and N)")
    print()


def demo_diagonal_value() -> None:
    print("=" * 70)
    print("2. Diagonal value theorem: the Liar/Russell value must be B or N")
    print("=" * 70)
    # A 2-element diagonal system: apply(diag, x) = neg(apply(x, x)).
    # We solve for apply(diag, diag) = neg(apply(diag, diag)).
    solutions = [v for v in Belnap if v == neg(v)]
    print("   Solving x = neg(x) over Belnap values:")
    for v in Belnap:
        print(f"      x = {v.value}: neg(x) = {neg(v).value}"
              f"  -> {'SOLUTION' if v == neg(v) else 'contradiction'}")
    print(f"   --> the Liar/Russell sentence is valued one of {[s.value for s in solutions]}")
    print()


def demo_liar_tower() -> None:
    print("=" * 70)
    print("3. The Liar tower is constant at B (Theorem 3.7)")
    print("=" * 70)
    seq = [liar_tower(n).value for n in range(8)]
    print(f"   iterated negation from B: {seq}")
    print(f"   --> stationary at B (classical oscillation T/F/T/F does NOT occur)")
    print()


def demo_berry() -> None:
    print("=" * 70)
    print("4. Berry's paradox as pigeonhole collision (Theorem 4.1)")
    print("=" * 70)
    objects = list(range(7))          # 7 objects
    descriptions = list(range(4))     # only 4 short descriptions
    # naming function: each object gets description (object mod 4)
    definability = lambda o: o % 4
    o1, o2 = berry_collision(objects, descriptions, definability)
    print(f"   {len(objects)} objects, {len(descriptions)} descriptions")
    print(f"   --> objects {o1} and {o2} both receive description "
          f"{definability(o1)} (under-described!)")
    print()


def demo_self_soundness() -> None:
    print("=" * 70)
    print("5. Self-soundness: the glut Liar passes the soundness test")
    print("=" * 70)
    # A tiny full paradox theory over sentences {0,1,2,3}:
    #   0 = Liar (B), 1 = soundness sentence (T), 2 = a truth (T), 3 = a falsehood (F)
    truth = {0: Belnap.B, 1: Belnap.T, 2: Belnap.T, 3: Belnap.F}
    provable = [0, 1, 2]              # Liar, soundness sentence, and a truth
    sound = all(is_true(truth[s]) for s in provable)
    print(f"   truth assignment: "
          f"{{ {', '.join(f'{k}:{v.value}' for k, v in truth.items())} }}")
    print(f"   provable set = {provable} (includes the Liar, sentence 0)")
    print(f"   every provable sentence at-least-true? {sound}")
    print(f"   Liar (sentence 0) value = {truth[0].value}, is_true = {is_true(truth[0])}")
    print(f"   --> the theory proves its own soundness while proving the Liar")
    print()


def demo_spectrum() -> None:
    print("=" * 70)
    print("6. Inconsistency spectrum, coexistence & tolerance bounds")
    print("=" * 70)
    # Liar (0) and Russell (1) both glut, plus a truth and a falsehood.
    truth = {0: Belnap.B, 1: Belnap.B, 2: Belnap.T, 3: Belnap.F, 4: Belnap.N}
    sp = compute_spectrum(truth)
    print(f"   spectrum: T={sp.nT}, F={sp.nF}, B={sp.nB}, N={sp.nN}")
    print(f"   conservation: T+F+B+N = {sp.total} = |S| = {len(truth)}")
    print(f"   inconsistency degree (gluts) = {sp.inconsistency_degree}  (>= 2: two distinct gluts)")
    print(f"   tolerance: degree {sp.nB} <= |S| - 2 = {len(truth) - 2}  "
          f"(has a T and an F)")
    print(f"   has explosion? {has_explosion(truth)}  (a glut does NOT make everything true)")
    print()


def demo_fde_failures() -> None:
    print("=" * 70)
    print("7. The cost: excluded middle & modus ponens fail; DNE survives")
    print("=" * 70)
    # Excluded middle: P or not-P with P = N gives N (not designated).
    P = Atom(0)
    lem = Disj(P, Neg(P))
    v_gap = {0: Belnap.N}
    print(f"   Excluded middle P v ~P under P=N: "
          f"{evaluate(lem, v_gap).value}  -> designated? {is_true(evaluate(lem, v_gap))}")
    # Modus ponens: P and (P -> Q) with P = B, Q = F.
    Q = Atom(1)
    premise = Conj(P, implies(P, Q))
    v_mp = {0: Belnap.B, 1: Belnap.F}
    prem = evaluate(premise, v_mp)
    concl = evaluate(Q, v_mp)
    print(f"   Modus ponens premise [P & (P->Q)] under P=B,Q=F: {prem.value} "
          f"(designated? {is_true(prem)}); conclusion Q={concl.value} "
          f"(designated? {is_true(concl)})  -> FAILS")
    # Double negation elimination holds for every value.
    dne_ok = all(neg(neg(v)) == v for v in Belnap)
    print(f"   Double negation elimination ~~P |= P holds for all values? {dne_ok}")
    print()


def main() -> None:
    print()
    print("#" * 70)
    print("#  PARADOXES AS THEOREMS  —  Liar, Berry, Russell Made Consistent")
    print("#" * 70)
    print()
    demo_negation_fixed_points()
    demo_diagonal_value()
    demo_liar_tower()
    demo_berry()
    demo_self_soundness()
    demo_spectrum()
    demo_fde_failures()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
