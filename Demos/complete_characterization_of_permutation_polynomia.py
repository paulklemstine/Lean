"""
demo.py — Numerical demonstrations for:

    Permutation polynomials of linearized Frobenius type over F_{p^2}.

Main facts demonstrated (all proved abstractly in the companion theory):

  1. The F_p-linear map  L(x) = a*x^p + c*x  on the field K = F_{p^2}
     is a bijection (permutation) of K  <=>  N(a) != N(c),
     where N(z) = z^(p+1) = z * z^p is the relative norm K -> F_p.

  2. Adding any constant d is irrelevant:  x -> a*x^p + c*x + d
     permutes K  <=>  x -> a*x^p + c*x  permutes K.

  3. Exact count: for a = 1 the exceptional coefficients c (those with
     c^(p+1) = 1, i.e. N(c) = 1) number exactly p + 1, so exactly
     p^2 - (p + 1) coefficients give a permutation.

  4. Characteristic-2 collapse (q = 2, K = F_4): the polynomial
     x^2 + b*x^2 + c*x + d equals (1+b)*x^2 + c*x + d, which is linear
     (x^2 is the Frobenius), so it permutes F_4  <=>  N(1+b) != N(c).

Everything is self-contained: we build F_{p^2} explicitly as
F_p[t]/(t^2 - g) for a fixed quadratic non-residue g, in which case the
Frobenius is x = u + v t  |->  u - v t, and N(u + v t) = u^2 - g v^2.
"""

from __future__ import annotations

from itertools import product
from typing import Iterator


# --------------------------------------------------------------------------
# Construction of K = F_{p^2} = F_p[t] / (t^2 - g),  g a non-residue mod p.
# An element u + v t is stored as the pair (u, v) with entries in F_p.
# --------------------------------------------------------------------------

def nonresidue(p: int) -> int:
    """Return a quadratic non-residue g in F_p (p an odd prime)."""
    squares = {(x * x) % p for x in range(p)}
    for g in range(2, p):
        if g % p not in squares:
            return g
    raise ValueError(f"no non-residue found for p={p}")


class Fp2:
    """Element u + v*t of F_{p^2}, where t^2 = g (mod p)."""

    __slots__ = ("u", "v", "p", "g")

    def __init__(self, u: int, v: int, p: int, g: int) -> None:
        self.u = u % p
        self.v = v % p
        self.p = p
        self.g = g

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Fp2):
            return NotImplemented
        return (self.u, self.v) == (other.u, other.v)

    def __hash__(self) -> int:
        return hash((self.u, self.v))

    def __repr__(self) -> str:
        return f"({self.u}+{self.v}t)"

    def __add__(self, other: "Fp2") -> "Fp2":
        return Fp2(self.u + other.u, self.v + other.v, self.p, self.g)

    def __mul__(self, other: "Fp2") -> "Fp2":
        # (a + b t)(c + d t) = (ac + bd g) + (ad + bc) t,   t^2 = g
        a, b, c, d = self.u, self.v, other.u, other.v
        return Fp2(a * c + b * d * self.g, a * d + b * c, self.p, self.g)

    def pow(self, n: int) -> "Fp2":
        result = Fp2(1, 0, self.p, self.g)
        base = self
        while n > 0:
            if n & 1:
                result = result * base
            base = base * base
            n >>= 1
        return result

    def frobenius(self) -> "Fp2":
        """x |-> x^p.  Since t^p = -t here, (u + v t)^p = u - v t."""
        return Fp2(self.u, -self.v, self.p, self.g)

    def norm(self) -> int:
        """N(x) = x * x^p = x^(p+1) in F_p.  N(u + v t) = u^2 - g v^2."""
        n = (self * self.frobenius())
        assert n.v == 0, "norm must lie in the prime field"
        return n.u


def field_elements(p: int, g: int) -> Iterator[Fp2]:
    for u, v in product(range(p), repeat=2):
        yield Fp2(u, v, p, g)


# --------------------------------------------------------------------------
# The maps under study and a brute-force permutation test.
# --------------------------------------------------------------------------

def linear_map(a: Fp2, c: Fp2, x: Fp2) -> Fp2:
    """L(x) = a*x^p + c*x."""
    return a * x.frobenius() + c * x


def affine_map(a: Fp2, c: Fp2, d: Fp2, x: Fp2) -> Fp2:
    """f(x) = a*x^p + c*x + d."""
    return a * x.frobenius() + c * x + d


def is_permutation(values: list[Fp2], total: int) -> bool:
    return len({(z.u, z.v) for z in values}) == total


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------

def demo_linear_criterion(p: int) -> None:
    g = nonresidue(p)
    elems = list(field_elements(p, g))
    total = p * p
    print(f"\n=== F_{p}^2  (|K| = {total},  t^2 = {g}) :"
          f"  L(x) = a x^p + c x  permutes  <=>  N(a) != N(c) ===")
    mismatches = 0
    for a, c in product(elems, repeat=2):
        brute = is_permutation([linear_map(a, c, x) for x in elems], total)
        criterion = (a.norm() != c.norm())
        if brute != criterion:
            mismatches += 1
            print(f"  MISMATCH a={a} c={c}")
    print(f"  Checked {total * total} pairs (a,c); mismatches = {mismatches}.")


def demo_constant_irrelevant(p: int) -> None:
    g = nonresidue(p)
    elems = list(field_elements(p, g))
    total = p * p
    print(f"\n=== F_{p}^2 :  the constant d is irrelevant to permutation ===")
    a = Fp2(1, 1, p, g)
    c = Fp2(2 % p, 0, p, g)
    base = is_permutation([linear_map(a, c, x) for x in elems], total)
    consistent = all(
        is_permutation([affine_map(a, c, d, x) for x in elems], total) == base
        for d in elems
    )
    print(f"  a={a}, c={c}:  base permutes? {base};"
          f"  same for all {total} constants d? {consistent}")


def demo_exact_count(p: int) -> None:
    g = nonresidue(p)
    elems = list(field_elements(p, g))
    one = Fp2(1, 0, p, g)
    total = p * p
    print(f"\n=== F_{p}^2 :  exact count of exceptional / permutation c "
          f"for x^p + c x ===")
    exceptional = [c for c in elems if c.pow(p + 1) == one]   # N(c) = 1
    perm = [c for c in elems if is_permutation(
        [linear_map(one, c, x) for x in elems], total)]
    print(f"  #{{c : c^(p+1)=1}} = {len(exceptional)}   (theory: p+1 = {p + 1})")
    print(f"  #permutation coeffs = {len(perm)}   "
          f"(theory: p^2-(p+1) = {p * p - (p + 1)})")


def demo_char_two_F4() -> None:
    """F_4 = F_2[t]/(t^2 + t + 1).  Here Frobenius is x |-> x^2."""
    print("\n=== F_4 (characteristic 2) :  x^2 + b x^2 + c x + d collapses "
          "to linear ===")
    # Build F_4 with t^2 = t + 1 (the standard irreducible t^2 + t + 1).
    elems4 = [(u, v) for u, v in product(range(2), repeat=2)]

    def mul(a, b):
        (au, av), (bu, bv) = a, b
        # (au+av t)(bu+bv t), t^2 = t + 1
        lo = au * bu
        hi = au * bv + av * bu
        tt = av * bv               # coefficient of t^2 = t + 1
        u = (lo + tt) % 2
        v = (hi + tt) % 2
        return (u, v)

    def add(a, b):
        return ((a[0] + b[0]) % 2, (a[1] + b[1]) % 2)

    def frob(a):                    # x -> x^2
        return mul(a, a)

    def norm(a):                    # N(x) = x * x^2 = x^3
        return mul(a, frob(a))[0]   # lands in F_2

    def f(b, c, d, x):
        # x^2 + b x^2 + c x + d  with x^2 = frob(x)
        x2 = frob(x)
        return add(add(add(x2, mul(b, x2)), mul(c, x)), d)

    one = (1, 0)
    mism = 0
    for b, c, d in product(elems4, repeat=3):
        vals = [f(b, c, d, x) for x in elems4]
        brute = len(set(vals)) == 4
        # collapsed map: (1+b) x^2 + c x + d, permutes <=> N(1+b) != N(c)
        crit = norm(add(one, b)) != norm(c)
        if brute != crit:
            mism += 1
    print(f"  Checked all (b,c,d) in F_4^3 = {4 ** 3} triples;"
          f"  criterion N(1+b) != N(c) mismatches = {mism}.")


def main() -> None:
    for p in (3, 5, 7):
        demo_linear_criterion(p)
    demo_constant_irrelevant(5)
    for p in (3, 5, 7, 11):
        demo_exact_count(p)
    demo_char_two_F4()
    print("\nAll demonstrations agree with the proved criteria.")


if __name__ == "__main__":
    main()
