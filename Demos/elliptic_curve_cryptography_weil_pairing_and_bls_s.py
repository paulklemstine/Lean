"""
Numerical demonstrations of bilinear pairings, BLS signatures, aggregation,
the MOV reduction, and the quantifier-boundary phenomenon of nondegeneracy.

All examples use the concrete determinant model of the Weil pairing on the
n-torsion E[n] = (Z/nZ)^2:

    e((a, b), (c, d)) = zeta ^ (a*d - b*c)   in   mu_n = Multiplicative(Z/nZ).

We represent target-group elements mu_n additively as integers mod n (the
exponent of zeta); group multiplication in mu_n is addition mod n, and powers
become multiplication mod n.

Self-contained: standard library only.
"""

from __future__ import annotations

from typing import Callable, List, Tuple

Point = Tuple[int, int]  # an element of (Z/nZ)^2


# --------------------------------------------------------------------------- #
# Group arithmetic in the source group G = (Z/nZ)^2 (written additively)
# --------------------------------------------------------------------------- #
def g_add(p: Point, q: Point, n: int) -> Point:
    """Add two torsion points coordinatewise mod n."""
    return ((p[0] + q[0]) % n, (p[1] + q[1]) % n)


def g_neg(p: Point, n: int) -> Point:
    """Additive inverse of a torsion point."""
    return ((-p[0]) % n, (-p[1]) % n)


def g_sub(p: Point, q: Point, n: int) -> Point:
    """Subtract torsion points."""
    return g_add(p, g_neg(q, n), n)


def g_smul(x: int, p: Point, n: int) -> Point:
    """Scalar multiplication x * p in the additive group (Z/nZ)^2."""
    return ((x * p[0]) % n, (x * p[1]) % n)


# --------------------------------------------------------------------------- #
# The Weil determinant pairing.  Target value returned as the EXPONENT of zeta,
# i.e. an element of mu_n represented additively in Z/nZ.
# --------------------------------------------------------------------------- #
def weil_pairing(p: Point, q: Point, n: int) -> int:
    """e(p, q) returned as the exponent of zeta: (a*d - b*c) mod n."""
    a, b = p
    c, d = q
    return (a * d - b * c) % n


def t_mul(u: int, v: int, n: int) -> int:
    """Multiplication in mu_n becomes addition of exponents mod n."""
    return (u + v) % n


def t_pow(u: int, k: int, n: int) -> int:
    """Raising to a power in mu_n becomes multiplication of the exponent mod n."""
    return (u * k) % n


def t_one(n: int) -> int:
    """Identity of mu_n: exponent 0."""
    return 0


# --------------------------------------------------------------------------- #
# Demo 1: bilinearity and the alternating law
# --------------------------------------------------------------------------- #
def demo_bilinearity(n: int = 17) -> None:
    print("=" * 70)
    print("Demo 1: bilinearity, alternation, antisymmetry")
    print("=" * 70)
    p, q, r = (3, 5), (7, 2), (4, 9)

    # additivity in the first slot
    lhs = weil_pairing(g_add(p, q, n), r, n)
    rhs = t_mul(weil_pairing(p, r, n), weil_pairing(q, r, n), n)
    print(f"  e(p+q, r) = {lhs},  e(p,r)*e(q,r) = {rhs}  -> {lhs == rhs}")

    # alternating: e(p, p) = 1
    print(f"  e(p, p) = {weil_pairing(p, p, n)}  (identity is 0) "
          f"-> {weil_pairing(p, p, n) == t_one(n)}")

    # antisymmetry: e(q, p) = e(p, q)^{-1}
    epq = weil_pairing(p, q, n)
    eqp = weil_pairing(q, p, n)
    print(f"  e(p,q) = {epq},  e(q,p) = {eqp},  sum mod n = {(epq + eqp) % n} "
          f"(should be 0) -> {(epq + eqp) % n == 0}")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: BLS sign / verify completeness
# --------------------------------------------------------------------------- #
def bls_sign(x: int, H: Point, n: int) -> Point:
    """BLS signature sigma = x * H."""
    return g_smul(x, H, n)


def bls_verify(sigma: Point, g: Point, H: Point, X: Point, n: int) -> bool:
    """Accept iff e(sigma, g) == e(H, X)."""
    return weil_pairing(sigma, g, n) == weil_pairing(H, X, n)


def demo_bls(n: int = 23) -> None:
    print("=" * 70)
    print("Demo 2: BLS signature completeness")
    print("=" * 70)
    g = (1, 0)
    x = 9                 # secret key
    X = g_smul(x, g, n)   # public key
    H = (5, 8)            # message hash-to-curve
    sigma = bls_sign(x, H, n)
    print(f"  public key X = {X}, signature sigma = {sigma}")
    print(f"  verify -> {bls_verify(sigma, g, H, X, n)}")
    forged = g_add(sigma, (0, 1), n)
    print(f"  tampered signature verifies -> {bls_verify(forged, g, H, X, n)} "
          f"(rejected)")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: aggregate BLS (short signatures) and batch verification
# --------------------------------------------------------------------------- #
def demo_aggregate(n: int = 29) -> None:
    print("=" * 70)
    print("Demo 3: aggregate BLS compression and batch verification")
    print("=" * 70)
    g = (1, 0)
    secrets = [4, 11, 7, 24]
    hashes: List[Point] = [(2, 3), (5, 1), (8, 6), (9, 9)]
    pubkeys = [g_smul(x, g, n) for x in secrets]
    sigs = [bls_sign(x, H, n) for x, H in zip(secrets, hashes)]

    # aggregate signature: a single group element
    agg = (0, 0)
    for s in sigs:
        agg = g_add(agg, s, n)

    lhs = weil_pairing(agg, g, n)
    rhs = t_one(n)
    for H, X in zip(hashes, pubkeys):
        rhs = t_mul(rhs, weil_pairing(H, X, n), n)
    print(f"  {len(secrets)} signers -> aggregate signature = {agg} "
          f"(one group element)")
    print(f"  e(agg, g) = {lhs},  product of per-signer pairings = {rhs} "
          f"-> {lhs == rhs}")
    print()


# --------------------------------------------------------------------------- #
# Demo 4: the rogue-key attack on naive same-message aggregation
# --------------------------------------------------------------------------- #
def demo_rogue_key(n: int = 31) -> None:
    print("=" * 70)
    print("Demo 4: rogue-key attack on naive same-message aggregation")
    print("=" * 70)
    g = (1, 0)
    X1 = g_smul(13, g, n)   # honest public key (secret unknown to adversary)
    H = (6, 5)              # shared message
    w = 20                  # adversary's chosen scalar
    X2 = g_sub(g_smul(w, g, n), X1, n)   # rogue key = w*g - X1
    sigma = g_smul(w, H, n)              # forged contribution, no honest secret

    combined = g_add(X1, X2, n)
    lhs = weil_pairing(sigma, g, n)
    rhs = weil_pairing(H, combined, n)
    print(f"  rogue key X2 = {X2}, combined key X1+X2 = {combined} = w*g")
    print(f"  forged aggregate verifies -> {lhs == rhs}  (attack succeeds!)")
    print("  defense: enforce DISTINCT messages so keys cannot telescope.")
    print()


# --------------------------------------------------------------------------- #
# Demo 5: the MOV reduction (ECDLP -> target-group DLP)
# --------------------------------------------------------------------------- #
def mov_recover(g: Point, h: Point, X: Point, n: int) -> int:
    """Recover the discrete log x with X = x*g via the pairing, by solving the
    target-group DLP base e(g, h) (here a small exhaustive search).

    Because the Weil determinant pairing is ALTERNATING, e(g, g) is always
    trivial, so the reduction must pair against an INDEPENDENT point h: this is
    exactly the asymmetric (two-generator) setting forced by the algebra.
    """
    from math import gcd
    base = weil_pairing(g, h, n)          # exponent of zeta; base * x mod n
    target = weil_pairing(X, h, n)        # equals base * x mod n
    order = n // gcd(base, n) if base != 0 else 1
    for k in range(order):
        if t_pow(base, k, n) == target:
            return k
    return -1


def demo_mov(n: int = 37) -> None:
    from math import gcd
    print("=" * 70)
    print("Demo 5: MOV reduction faithfulness (against an independent point)")
    print("=" * 70)
    g = (1, 0)
    h = (0, 1)                       # independent second generator
    base = weil_pairing(g, h, n)
    order = n // gcd(base, n) if base != 0 else 1
    print(f"  e(g, g) = {weil_pairing(g, g, n)} (alternating -> trivial); "
          f"e(g, h) = {base}, order {order}")
    for x in [3, 10, 22]:
        X = g_smul(x, g, n)
        rec = mov_recover(g, h, X, n)
        print(f"  secret x = {x:>2} -> recovered {rec:>2} (mod {order}) "
              f"-> match {rec % order == x % order}")
    print()


# --------------------------------------------------------------------------- #
# Demo 6: the quantifier boundary of nondegeneracy
# --------------------------------------------------------------------------- #
def demo_quantifier_boundary(n: int = 13) -> None:
    print("=" * 70)
    print("Demo 6: nondegeneracy 'for all q' vs 'against a fixed g'")
    print("=" * 70)

    # Full nondegeneracy: only p = 0 pairs trivially with EVERY q.
    def pairs_trivially_with_all(p: Point) -> bool:
        return all(weil_pairing(p, (c, d), n) == 0
                   for c in range(n) for d in range(n))

    witnesses = [p for p in ((a, b) for a in range(n) for b in range(n))
                 if pairs_trivially_with_all(p)]
    print(f"  points pairing trivially with ALL q: {witnesses} "
          f"-> only zero: {witnesses == [(0, 0)]}")

    # Fixed-generator degeneracy: for any g != 0, g itself pairs trivially.
    g = (3, 7)
    print(f"  for fixed g = {g}: e(g, g) = {weil_pairing(g, g, n)} "
          f"-> g != 0 collides with itself (alternating law)")
    print("  => no symmetric single-group pairing binds a fixed generator.")
    print()


if __name__ == "__main__":
    demo_bilinearity()
    demo_bls()
    demo_aggregate()
    demo_rogue_key()
    demo_mov()
    demo_quantifier_boundary()
