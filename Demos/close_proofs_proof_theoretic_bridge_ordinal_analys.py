"""
demo.py — Numerical demonstrations for
"A Proof-Theoretic Bridge: Ordinal Analysis Across Systems"

This script is fully self-contained (standard library only). It implements a
finite, computable model of ordinals below epsilon_0 in Cantor Normal Form (CNF)
and uses it to witness, numerically, the main results of the accompanying paper:

  * Definition 3.1  : the finite omega-towers  0, 1, w, w^w, w^w^w, ...
  * Lemma 3.2       : tower(n+1) = w ^ tower(n)
  * Theorem 3.4     : epsilon_0 = sup_n tower(n)   (the towers converge to e0)
  * Theorem 3.5     : the tower is strictly increasing
  * Section 4       : each tower has a FINITE notation, hence is countable
  * Section 7       : a strictly monotone map f satisfies a <= f(a) (inflationary)
  * Section 8       : the Goodstein descent terminates (ordinal below e0 decreases)

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import total_ordering
from typing import List, Tuple


# ----------------------------------------------------------------------------
# Ordinals below epsilon_0 in Cantor Normal Form.
#
# Every ordinal a < e0 has a unique CNF
#     a = w^{b_1} * c_1 + ... + w^{b_k} * c_k ,   b_1 > ... > b_k,  c_i >= 1,
# where each exponent b_i is itself an ordinal < e0 (and < a).  We store this as
# a list of (exponent, coefficient) terms in strictly decreasing exponent order.
# The natural number 0 is the empty list; finite n>0 is [(ZERO, n)].
# ----------------------------------------------------------------------------
@total_ordering
@dataclass(frozen=True)
class Ord:
    """An ordinal < epsilon_0 in Cantor Normal Form (base omega)."""
    terms: Tuple[Tuple["Ord", int], ...]  # ((exponent, coeff), ...) descending

    # -- constructors -------------------------------------------------------
    @staticmethod
    def zero() -> "Ord":
        return Ord(())

    @staticmethod
    def nat(n: int) -> "Ord":
        if n < 0:
            raise ValueError("ordinals are non-negative")
        return Ord(()) if n == 0 else Ord(((Ord.zero(), n),))

    @staticmethod
    def omega() -> "Ord":
        """w = w^1."""
        return Ord(((Ord.nat(1), 1),))

    # -- predicates ---------------------------------------------------------
    def is_zero(self) -> bool:
        return len(self.terms) == 0

    # -- ordering (lexicographic on CNF terms) ------------------------------
    def __lt__(self, other: "Ord") -> bool:
        a, b = self.terms, other.terms
        for (ea, ca), (eb, cb) in zip(a, b):
            if ea != eb:
                return ea < eb
            if ca != cb:
                return ca < cb
        return len(a) < len(b)

    # __eq__ is provided by the frozen dataclass (structural equality).

    # -- arithmetic ---------------------------------------------------------
    def __add__(self, other: "Ord") -> "Ord":
        """Ordinal addition (non-commutative): absorb our tail below other's head."""
        if other.is_zero():
            return self
        if self.is_zero():
            return other
        head_exp = other.terms[0][0]
        kept = [(e, c) for (e, c) in self.terms if e > head_exp]
        # If our smallest kept exponent equals other's head exponent, merge.
        merged: List[Tuple["Ord", int]] = list(kept)
        for (e, c) in self.terms:
            if e == head_exp:
                # same leading exponent: coefficients add
                eb, cb = other.terms[0]
                merged.append((eb, c + cb))
                merged.extend(other.terms[1:])
                return Ord(tuple(merged))
        merged.extend(other.terms)
        return Ord(tuple(merged))

    def omega_pow(self) -> "Ord":
        """Return w ^ self  (omega to the power of this ordinal)."""
        if self.is_zero():
            return Ord.nat(1)  # w^0 = 1
        return Ord(((self, 1),))

    # -- display ------------------------------------------------------------
    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        parts: List[str] = []
        for (e, c) in self.terms:
            if e.is_zero():
                parts.append(str(c))
            else:
                base = "w" if e == Ord.nat(1) else f"w^({e!r})"
                parts.append(base if c == 1 else f"{base}*{c}")
        return " + ".join(parts)


# ----------------------------------------------------------------------------
# Definition 3.1 / Lemma 3.2 : the finite omega-towers.
# ----------------------------------------------------------------------------
def tower(n: int) -> Ord:
    """tower(0)=0, tower(k+1) = w ^ tower(k).  Sequence: 0,1,w,w^w,w^w^w,..."""
    acc = Ord.zero()
    for _ in range(n):
        acc = acc.omega_pow()  # one application of  a |-> w^a
    return acc


def cnf_size(a: Ord) -> int:
    """A crude finite measure of a notation's syntax tree (witnesses finiteness)."""
    return 1 + sum(cnf_size(e) + 1 for (e, _c) in a.terms)


# ----------------------------------------------------------------------------
# Section 7 : strictly monotone => inflationary  (a <= f(a)).
# We illustrate on the order type of N: any strictly increasing f: N->N has
# n <= f(n).  This is the finite shadow of  no_monotone_collapse.
# ----------------------------------------------------------------------------
def is_inflationary_on_nat(f, bound: int) -> bool:
    return all(n <= f(n) for n in range(bound))


# ----------------------------------------------------------------------------
# Section 8 : the Goodstein descent.
#
# Hereditary base-b representation of m, with every base replaced by w, gives an
# ordinal < e0.  The Goodstein step (bump base b -> b+1, then subtract 1) leaves
# the integer possibly exploding, but the associated ordinal strictly DECREASES.
# We compute the ordinal of each Goodstein state and confirm strict descent.
# ----------------------------------------------------------------------------
def hereditary_base(m: int, b: int) -> List[Tuple[int, int]]:
    """Return [(exp, digit), ...] of m in base b, exponents themselves base-b."""
    out: List[Tuple[int, int]] = []
    e = 0
    while m > 0:
        d = m % b
        if d:
            out.append((e, d))
        m //= b
        e += 1
    return list(reversed(out))


def to_ordinal(m: int, b: int) -> Ord:
    """Map m, written hereditarily in base b, to an ordinal by base b -> w."""
    if m == 0:
        return Ord.zero()
    acc = Ord.zero()
    for (e, d) in hereditary_base(m, b):
        exp_ord = to_ordinal(e, b)  # recurse on the exponent (heredity)
        term = exp_ord.omega_pow()
        for _ in range(d):
            acc = acc + term
    return acc


def goodstein_prefix(start: int, steps: int) -> List[Tuple[int, int, Ord]]:
    """Return [(base, value, ordinal)] for the first `steps` Goodstein states."""
    out: List[Tuple[int, int, Ord]] = []
    m, b = start, 2
    for _ in range(steps):
        out.append((b, m, to_ordinal(m, b)))
        if m == 0:
            break
        # bump base then subtract one
        digits = hereditary_base(m, b)
        m = 0
        for (e, d) in digits:
            m += d * (b + 1) ** _rebase_exp(e, b)
        m -= 1
        b += 1
    return out


def _rebase_exp(e: int, b: int) -> int:
    """Re-evaluate a (small) exponent written in base b at base b+1.

    For the modest seeds used in this demo the exponents are < b, so they are
    digits and the value is unchanged; we keep this helper explicit for clarity.
    """
    if e < b:
        return e
    val = 0
    for (ee, dd) in hereditary_base(e, b):
        val += dd * (b + 1) ** _rebase_exp(ee, b)
    return val


# ----------------------------------------------------------------------------
# Driver.
# ----------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("ORDINAL ANALYSIS BRIDGE — numerical demonstrations")
    print("=" * 70)

    print("\n[Definition 3.1 / Lemma 3.2] The finite omega-towers:")
    prev = None
    for n in range(5):
        t = tower(n)
        check = "" if prev is None else (
            "  (strictly greater than previous: %s)" % (prev < t))
        print(f"  tower({n}) = {t!r}{check}")
        prev = t
    print("  ... the supremum of this sequence is epsilon_0  [Theorem 3.4].")

    print("\n[Theorem 3.5] Strict monotonicity of the tower:")
    pairs = [(tower(n), tower(n + 1)) for n in range(5)]
    print("  tower(n) < tower(n+1) for n=0..4 :",
          all(a < b for a, b in pairs))

    print("\n[Section 4] Each tower has a FINITE notation (hence countable):")
    for n in range(5):
        print(f"  |tower({n})|_syntax = {cnf_size(tower(n))} nodes")
    print("  Finite syntax => each tower(n) is a countable ordinal;")
    print("  a countable sup of countable ordinals stays < omega_1")
    print("  => epsilon_0 < omega_1  [Theorem 4.2].")

    print("\n[Section 7] Strictly monotone => inflationary (a <= f(a)):")
    f = lambda n: 2 * n + 3           # a strictly increasing map on N
    print("  f(n) = 2n+3 strictly increasing; n <= f(n) for n=0..99 :",
          is_inflationary_on_nat(f, 100))
    print("  This is the finite shadow of `no_monotone_collapse`:")
    print("  no strictly monotone map can send omega_1 below itself.")

    print("\n[Section 8] Goodstein descent (integer explodes, ordinal descends):")
    print("  seed = 3, hereditary base 2:")
    states = goodstein_prefix(3, 7)
    prev_ord = None
    for (b, m, o) in states:
        rel = ""
        if prev_ord is not None:
            rel = "  ordinal strictly DECREASED: %s" % (o < prev_ord)
        print(f"  base={b:<3} value={m:<6} ordinal={o!r}{rel}")
        prev_ord = o
    print("  The ordinals form a strictly decreasing sequence below epsilon_0,")
    print("  so by well-foundedness the Goodstein sequence must reach 0.")

    print("\n" + "=" * 70)
    print("All demonstrations completed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
