"""Numerical demonstrations of the AKS polynomial criterion for primality.

The central fact, formalized and proved in Lean 4, is the following.

    Theorem (AKS polynomial criterion).
    Let n >= 2 and let a be a unit in the ring Z/nZ.  Then

        n is prime   <=>   (X + a)^n == X^n + a   in (Z/nZ)[X].

This module gives fully self-contained, type-hinted Python that:

  1. multiplies polynomials over Z/nZ,
  2. tests the AKS identity for any n and any unit a,
  3. exhibits the "freshman's dream" collapse for primes,
  4. shows exactly which coefficient breaks the identity for composites,
  5. verifies the binomial identity  q * C(n, q) = n * C(n-1, q-1),
  6. verifies  C(n-1, q-1) == 1 (mod q)  when q is a prime divisor of n,
  7. demonstrates that the offending coefficient is C(n, q) with q = minFac(n).

Run `python demo.py` to see all demonstrations.
"""

from __future__ import annotations

from math import comb, gcd
from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# Polynomial arithmetic over Z/nZ.  A polynomial is a dict {exponent: coeff}.
# ---------------------------------------------------------------------------

Poly = Dict[int, int]


def poly_normalize(p: Poly, n: int) -> Poly:
    """Reduce all coefficients mod n and drop zero terms."""
    out: Poly = {}
    for e, c in p.items():
        c %= n
        if c != 0:
            out[e] = c
    return out


def poly_mul(p: Poly, q: Poly, n: int) -> Poly:
    """Multiply two polynomials modulo n."""
    out: Poly = {}
    for e1, c1 in p.items():
        for e2, c2 in q.items():
            out[e1 + e2] = (out.get(e1 + e2, 0) + c1 * c2) % n
    return poly_normalize(out, n)


def poly_pow(p: Poly, k: int, n: int) -> Poly:
    """Raise polynomial p to the power k modulo n by fast exponentiation."""
    result: Poly = {0: 1 % n}
    base = poly_normalize(dict(p), n)
    while k > 0:
        if k & 1:
            result = poly_mul(result, base, n)
        base = poly_mul(base, base, n)
        k >>= 1
    return poly_normalize(result, n)


def poly_eq(p: Poly, q: Poly, n: int) -> bool:
    """Test equality of two polynomials modulo n."""
    return poly_normalize(p, n) == poly_normalize(q, n)


def poly_str(p: Poly) -> str:
    """Human-readable rendering of a polynomial."""
    if not p:
        return "0"
    terms: List[str] = []
    for e in sorted(p, reverse=True):
        c = p[e]
        if e == 0:
            terms.append(f"{c}")
        elif e == 1:
            terms.append(f"{c}*X" if c != 1 else "X")
        else:
            terms.append(f"{c}*X^{e}" if c != 1 else f"X^{e}")
    return " + ".join(terms)


# ---------------------------------------------------------------------------
# The AKS identity test.
# ---------------------------------------------------------------------------

def aks_identity_holds(n: int, a: int) -> bool:
    """Return True iff (X + a)^n == X^n + a in (Z/nZ)[X]."""
    a %= n
    lhs = poly_pow({1: 1, 0: a}, n, n)        # (X + a)^n
    rhs = poly_normalize({n: 1, 0: a}, n)     # X^n + a
    return poly_eq(lhs, rhs, n)


def is_unit_mod(a: int, n: int) -> bool:
    """Return True iff a is a unit in Z/nZ, i.e. gcd(a, n) == 1."""
    return gcd(a % n, n) == 1


def min_fac(n: int) -> int:
    """Smallest prime factor of n (n >= 2)."""
    d = 2
    while d * d <= n:
        if n % d == 0:
            return d
        d += 1
    return n


def witnessing_coefficient(n: int) -> Tuple[int, int]:
    """For composite n, return (q, C(n,q) mod n) where q = minFac(n).

    The AKS proof shows this coefficient is nonzero mod n, hence the
    identity fails.  Returns the exponent q and the residue.
    """
    q = min_fac(n)
    return q, comb(n, q) % n


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------

def demo_freshmans_dream() -> None:
    """Show the identity collapsing for several primes."""
    print("=" * 70)
    print("1. Freshman's dream: primes satisfy (X + a)^n = X^n + a")
    print("=" * 70)
    for n in [2, 3, 5, 7, 11, 13]:
        ok = all(aks_identity_holds(n, a) for a in range(1, n) if is_unit_mod(a, n))
        print(f"  n = {n:>3} (prime): identity holds for every unit a?  {ok}")
    print()


def demo_composite_failure() -> None:
    """Show the identity failing for composites, and the witnessing coeff."""
    print("=" * 70)
    print("2. Composites break the identity; the X^q coefficient is the witness")
    print("=" * 70)
    for n in [4, 6, 8, 9, 12, 15, 21, 25]:
        a = next(b for b in range(1, n) if is_unit_mod(b, n))
        holds = aks_identity_holds(n, a)
        q, residue = witnessing_coefficient(n)
        print(
            f"  n = {n:>3} (composite): identity holds? {str(holds):>5} | "
            f"q = minFac = {q}, C({n},{q}) mod {n} = {residue}"
        )
    print()


def demo_carmichael() -> None:
    """561 = 3*11*17 fools Fermat but not AKS."""
    print("=" * 70)
    print("3. Carmichael number 561 fools Fermat yet is exposed by AKS")
    print("=" * 70)
    n = 561
    fermat_ok = all(pow(a, n, n) == a % n for a in range(2, 50) if is_unit_mod(a, n))
    print(f"  Fermat test a^n = a (mod {n}) for all tested units?  {fermat_ok}")
    a = 2
    aks_ok = aks_identity_holds(n, a)
    q, residue = witnessing_coefficient(n)
    print(f"  AKS identity with a = {a}?                          {aks_ok}")
    print(f"  Witnessing coefficient: q = {q}, C({n},{q}) mod {n} = {residue}")
    print()


def demo_binomial_identity() -> None:
    """Verify  q * C(n, q) = n * C(n-1, q-1)  (Lean: mul_choose_eq)."""
    print("=" * 70)
    print("4. Key binomial identity: q*C(n,q) = n*C(n-1,q-1)")
    print("=" * 70)
    for n, q in [(10, 3), (12, 4), (21, 3), (561, 3)]:
        lhs = q * comb(n, q)
        rhs = n * comb(n - 1, q - 1)
        print(f"  n={n:>4}, q={q}:  {lhs} = {rhs}   ->  {lhs == rhs}")
    print()


def demo_choose_mod() -> None:
    """Verify  C(n-1, q-1) = 1 (mod q)  for prime q dividing n."""
    print("=" * 70)
    print("5. C(n-1, q-1) == 1 (mod q) for a prime divisor q of n")
    print("=" * 70)
    for n in [6, 12, 15, 21, 561]:
        q = min_fac(n)
        val = comb(n - 1, q - 1) % q
        print(f"  n={n:>4}, q=minFac={q}:  C({n-1},{q-1}) mod {q} = {val}")
    print()


def main() -> None:
    demo_freshmans_dream()
    demo_composite_failure()
    demo_carmichael()
    demo_binomial_identity()
    demo_choose_mod()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
