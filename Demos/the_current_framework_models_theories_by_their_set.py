"""
demo.py — Numerical demonstration of the abstract order geometry of
proof-theoretic ordinals.

This is a self-contained, dependency-free illustration of the results in
RESEARCH_PAPER.md / ARTICLE.md:

  * OrdinalTheory modeled by a bounded, downward-closed set of ordinals,
    presented here by its supremum (the proof-theoretic ordinal, PTO).
  * PTO of canonical theories ofOrdinal(alpha):
        - limit / zero alpha  ->  PTO = alpha
        - successor alpha+1   ->  PTO = alpha
  * join PTO = max, meet PTO = min  (lattice homomorphism)
  * depthDist symmetric, zero on the diagonal, additive along chains
  * FAILURE of the symmetric triangle inequality at (omega+1, omega, 0),
    driven by the non-commutativity  1 + omega = omega.

Ordinals are represented in Cantor normal form (CNF) with NATURAL-NUMBER
exponents, i.e. ordinals below omega^omega. That range already contains every
ordinal used in the paper's theorems (0, 1, omega, omega+1, omega*2, omega^2, ...).

Run:  python3 demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple


# ----------------------------------------------------------------------------
# Ordinals below omega^omega in Cantor normal form.
#
# An ordinal is stored as a list of (exponent, coefficient) terms with strictly
# decreasing natural-number exponents and positive natural coefficients:
#     omega^e1 * c1 + omega^e2 * c2 + ...   with  e1 > e2 > ... and ci >= 1.
# The empty list is the ordinal 0.
# ----------------------------------------------------------------------------
@dataclass(frozen=True)
class Ordinal:
    terms: Tuple[Tuple[int, int], ...]  # ((exp, coeff), ...) decreasing exps

    # ---- constructors -------------------------------------------------------
    @staticmethod
    def zero() -> "Ordinal":
        return Ordinal(())

    @staticmethod
    def nat(n: int) -> "Ordinal":
        """The finite ordinal n."""
        if n < 0:
            raise ValueError("ordinals are non-negative")
        return Ordinal(()) if n == 0 else Ordinal(((0, n),))

    @staticmethod
    def from_terms(terms: List[Tuple[int, int]]) -> "Ordinal":
        """Normalize a list of (exp, coeff) terms into valid CNF."""
        merged: dict[int, int] = {}
        for e, c in terms:
            if c > 0:
                merged[e] = merged.get(e, 0) + c
        ordered = sorted(((e, c) for e, c in merged.items()), reverse=True)
        return Ordinal(tuple(ordered))

    # ---- display ------------------------------------------------------------
    def __str__(self) -> str:
        if not self.terms:
            return "0"
        pieces: List[str] = []
        for e, c in self.terms:
            if e == 0:
                pieces.append(str(c))
            elif e == 1:
                pieces.append("w" if c == 1 else f"w*{c}")
            else:
                pieces.append(f"w^{e}" if c == 1 else f"w^{e}*{c}")
        return " + ".join(pieces)

    __repr__ = __str__

    def __format__(self, spec: str) -> str:
        return format(str(self), spec)

    # ---- comparison ---------------------------------------------------------
    def _key(self) -> Tuple[Tuple[int, int], ...]:
        return self.terms

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Ordinal) and self.terms == other.terms

    def __hash__(self) -> int:
        return hash(self.terms)

    def __lt__(self, other: "Ordinal") -> bool:
        # Lexicographic on the (exp, coeff) term sequence is the correct
        # ordinal order for CNF with decreasing exponents.
        return list(self.terms) < list(other.terms)

    def __le__(self, other: "Ordinal") -> bool:
        return self == other or self < other

    # ---- arithmetic ---------------------------------------------------------
    def __add__(self, other: "Ordinal") -> "Ordinal":
        """Ordinal addition (non-commutative)."""
        if not other.terms:
            return self
        lead_exp = other.terms[0][0]
        kept = [(e, c) for (e, c) in self.terms if e > lead_exp]
        same = [(e, c) for (e, c) in self.terms if e == lead_exp]
        rest_other = list(other.terms)
        if same:
            # merge the matching-exponent term into other's leading term
            merged_coeff = same[0][1] + rest_other[0][1]
            rest_other = [(lead_exp, merged_coeff)] + rest_other[1:]
        return Ordinal(tuple(kept + rest_other))

    def __sub__(self, other: "Ordinal") -> "Ordinal":
        """Ordinal left-subtraction: the unique c with other + c = self when
        other <= self; 0 otherwise (matching Mathlib's Ordinal.sub)."""
        if self <= other:
            return Ordinal.zero()
        a = list(self.terms)
        b = list(other.terms)
        i = 0
        while i < len(b):
            ea, ca = a[i]
            eb, cb = b[i]
            if ea > eb:
                # b absorbed: remaining a is the answer
                return Ordinal(tuple(a[i:]))
            # ea == eb here (ea < eb impossible since other <= self)
            if ca > cb:
                return Ordinal(tuple([(ea, ca - cb)] + a[i + 1:]))
            # ca == cb: terms cancel, advance
            i += 1
        return Ordinal(tuple(a[i:]))


# convenient constants
ZERO = Ordinal.zero()
ONE = Ordinal.nat(1)
OMEGA = Ordinal(((1, 1),))
OMEGA_PLUS_1 = Ordinal(((1, 1), (0, 1)))


# ----------------------------------------------------------------------------
# OrdinalTheory layer.
#
# A theory is presented by its proof-theoretic ordinal (PTO). The "canonical"
# theory ofOrdinal(alpha) certifies every ordinal < alpha; its PTO is sSup(Iio
# alpha): alpha for limits/zero, the predecessor for successors.
# ----------------------------------------------------------------------------
def is_successor(a: Ordinal) -> bool:
    return bool(a.terms) and a.terms[-1][0] == 0


def predecessor(a: Ordinal) -> Ordinal:
    """For a successor ordinal a = b + 1, return b.

    Note: this is the *right* predecessor (decrement the finite tail), NOT the
    ordinal left-subtraction a - 1, which would give a back when a is a limit
    plus a finite part (because 1 + omega = omega absorbs on the left)."""
    if not is_successor(a):
        raise ValueError("predecessor only defined for successor ordinals")
    e, c = a.terms[-1]  # e == 0
    if c == 1:
        return Ordinal(a.terms[:-1])
    return Ordinal(a.terms[:-1] + ((0, c - 1),))


def pto_of_ofOrdinal(alpha: Ordinal) -> Ordinal:
    """PTO of the canonical theory ofOrdinal(alpha) = sSup (Iio alpha)."""
    if alpha == ZERO:
        return ZERO
    if is_successor(alpha):
        return predecessor(alpha)
    return alpha  # limit ordinal


def depth_dist(p: Ordinal, q: Ordinal) -> Ordinal:
    """depthDist on two theories given by their PTOs p, q."""
    return (p - q) + (q - p)


def pto_join(p: Ordinal, q: Ordinal) -> Ordinal:
    return p if q <= p else q          # max


def pto_meet(p: Ordinal, q: Ordinal) -> Ordinal:
    return q if q <= p else p          # min


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------
def demo_non_commutativity() -> None:
    print("== Non-commutativity of ordinal addition (the engine) ==")
    print(f"  1 + w  = {ONE + OMEGA}        (absorbed)")
    print(f"  w + 1  = {OMEGA + ONE}      (genuinely new)")
    print(f"  equal? {(ONE + OMEGA) == (OMEGA + ONE)}")
    print()


def demo_pto_canonical() -> None:
    print("== PTO of canonical theories ofOrdinal(alpha) ==")
    for alpha in [ZERO, ONE, OMEGA, OMEGA_PLUS_1, OMEGA + OMEGA]:
        kind = ("zero" if alpha == ZERO
                else "successor" if is_successor(alpha) else "limit")
        print(f"  alpha = {alpha:<8} ({kind:9}) -> PTO = {pto_of_ofOrdinal(alpha)}")
    print("  Note: PTO(ofOrdinal(w+1)) = w, NOT w+1  (source of non-injectivity)")
    print()


def demo_lattice_homomorphism() -> None:
    print("== PTO is a lattice homomorphism: join->max, meet->min ==")
    pairs = [(OMEGA, OMEGA_PLUS_1), (ONE, OMEGA), (OMEGA + OMEGA, OMEGA)]
    for p, q in pairs:
        print(f"  p={p:<8} q={q:<8} | join->{pto_join(p,q):<8} meet->{pto_meet(p,q)}")
    print()


def demo_chain_additivity() -> None:
    print("== Exact additivity of depthDist along a chain p <= q <= r ==")
    # PTOs along an increasing chain
    chains = [
        (ZERO, OMEGA, OMEGA + OMEGA),
        (ONE, OMEGA, OMEGA_PLUS_1),
        (ZERO, ONE, OMEGA),
    ]
    for p, q, r in chains:
        lhs = depth_dist(p, r)
        rhs = depth_dist(p, q) + depth_dist(q, r)
        print(f"  p={p:<6} q={q:<8} r={r:<10} | "
              f"d(p,r)={lhs:<8} d(p,q)+d(q,r)={rhs:<8} equal? {lhs == rhs}")
    print()


def demo_triangle_failure() -> None:
    print("== FAILURE of the symmetric triangle inequality ==")
    # The counterexample of Theorem 6.5: PTOs (w+1, w, 0).
    p, q, r = OMEGA_PLUS_1, OMEGA, ZERO
    direct = depth_dist(p, r)
    detour = depth_dist(p, q) + depth_dist(q, r)
    print(f"  PTOs: T1={p}, T2={q}, T3={r}")
    print(f"  depthDist(T1,T3)            = {direct}")
    print(f"  depthDist(T1,T2)            = {depth_dist(p, q)}")
    print(f"  depthDist(T2,T3)            = {depth_dist(q, r)}")
    print(f"  depthDist(T1,T2)+depthDist(T2,T3) = {detour}   (= 1 + w = w)")
    print(f"  triangle inequality d(T1,T3) <= detour ?  {direct <= detour}")
    print(f"  ==> VIOLATED: {direct} > {detour}")
    print()


def demo_symmetry_and_zero() -> None:
    print("== depthDist symmetry and vanishing on the diagonal ==")
    p, q = OMEGA_PLUS_1, OMEGA
    print(f"  depthDist(p,q) = {depth_dist(p,q)}, depthDist(q,p) = {depth_dist(q,p)}, "
          f"symmetric? {depth_dist(p,q) == depth_dist(q,p)}")
    print(f"  depthDist(p,p) = {depth_dist(p,p)}")
    print()


def main() -> None:
    print("=" * 70)
    print(" Abstract order geometry of proof-theoretic ordinals — numerical demo")
    print("=" * 70)
    print()
    demo_non_commutativity()
    demo_pto_canonical()
    demo_lattice_homomorphism()
    demo_chain_additivity()
    demo_symmetry_and_zero()
    demo_triangle_failure()
    print("All demonstrations reflect the machine-checked theorems.")


if __name__ == "__main__":
    main()
