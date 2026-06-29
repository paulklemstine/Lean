"""Numerical demonstrations of the abstract bilinear pairing results.

This script realizes the abstract `Pairing` interface with two concrete,
fully computable models and exercises the main theorems numerically:

    * `bls_verify_correct`         e(x.H, g) = e(H, x.g)
    * `bls_aggregate_correct`      e(sum x_i.H_i, g) = prod e(H_i, x_i.g)
    * `mov_map`                    e(x.g, g) = e(g, g)^x
    * `mov_reduction`              e(a.g,g)=e(b.g,g) <=> a == b (mod ord(e g g))
    * `mov_recovers_dlog`          unique secret recovery for small embedding deg
    * AlternatingPairing antisym.  e(p,q) * e(q,p) = 1  and  e(p,q) = 1

Target-group elements (roots of unity in mu_n) are represented by their
*exponent* in Z_n: the root zeta^k is stored as the integer k mod n.  Under this
representation multiplication of roots of unity is addition of exponents mod n,
the k-th power multiplies the exponent by k, the identity 1 is the exponent 0,
and the order of zeta^c is n / gcd(c, n).
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# Target group T = mu_n, elements stored as exponents in Z_n.
# --------------------------------------------------------------------------- #

def t_mul(n: int, a: int, b: int) -> int:
    """Multiplication in mu_n: zeta^a * zeta^b = zeta^(a+b)."""
    return (a + b) % n


def t_pow(n: int, a: int, k: int) -> int:
    """k-th power in mu_n: (zeta^a)^k = zeta^(a*k)."""
    return (a * k) % n


def t_one(n: int) -> int:
    """Identity of mu_n (the root zeta^0 = 1)."""
    return 0


def t_order(n: int, a: int) -> int:
    """Order of zeta^a in mu_n, equal to n / gcd(a, n)."""
    return n // gcd(a % n, n) if (a % n) != 0 else 1


# --------------------------------------------------------------------------- #
# Model 1: symmetric pairing on G = Z_n,  e(a, b) = zeta^(a*b).
# Biadditive, NON-alternating (e(g,g) generates), used for BLS + MOV.
# --------------------------------------------------------------------------- #

@dataclass
class SymmetricPairing:
    """e : Z_n x Z_n -> mu_n,  e(a, b) = zeta^(a*b) (exponent a*b mod n)."""

    n: int

    def e(self, a: int, b: int) -> int:
        return (a * b) % self.n

    def add_left(self, a: int, b: int, q: int) -> bool:
        # e(a+b, q) = e(a,q) * e(b,q)
        return self.e(a + b, q) == t_mul(self.n, self.e(a, q), self.e(b, q))

    def add_right(self, p: int, a: int, b: int) -> bool:
        # e(p, a+b) = e(p,a) * e(p,b)
        return self.e(p, a + b) == t_mul(self.n, self.e(p, a), self.e(p, b))


# --------------------------------------------------------------------------- #
# Model 2: alternating (Weil) pairing on G = (Z_r)^2,
#   e((a1,a2),(b1,b2)) = zeta^(a1*b2 - a2*b1).
# This is the determinant pairing: bilinear, alternating, nondegenerate.
# --------------------------------------------------------------------------- #

Point = Tuple[int, int]


@dataclass
class WeilPairing:
    """Alternating pairing on the r-torsion model E[r] = (Z_r)^2."""

    r: int

    def e(self, p: Point, q: Point) -> int:
        # determinant of the 2x2 matrix [p | q], reduced mod r
        return (p[0] * q[1] - p[1] * q[0]) % self.r

    def add(self, p: Point, q: Point) -> Point:
        return ((p[0] + q[0]) % self.r, (p[1] + q[1]) % self.r)

    def smul(self, k: int, p: Point) -> Point:
        return ((k * p[0]) % self.r, (k * p[1]) % self.r)


# --------------------------------------------------------------------------- #
# BLS over the abstract interface (Model 1).
# --------------------------------------------------------------------------- #

def bls_verify_correct(P: SymmetricPairing, g: int, H: int, x: int) -> bool:
    """Theorem `bls_verify_correct`: e(x.H, g) = e(H, x.g).

    Here x.H denotes scalar multiplication in the additive group G = Z_n,
    i.e. (x * H) mod n."""
    lhs = P.e((x * H) % P.n, g)
    rhs = P.e(H, (x * g) % P.n)
    return lhs == rhs


def bls_aggregate_correct(
    P: SymmetricPairing, g: int, hashes: List[int], secrets: List[int]
) -> bool:
    """Theorem `bls_aggregate_correct`:
    e(sum_i sk_i . H_i, g) = prod_i e(H_i, sk_i . g)."""
    agg = 0
    for sk, H in zip(secrets, hashes):
        agg = (agg + sk * H) % P.n
    lhs = P.e(agg, g)
    rhs = t_one(P.n)
    for sk, H in zip(secrets, hashes):
        rhs = t_mul(P.n, rhs, P.e(H, (sk * g) % P.n))
    return lhs == rhs


# --------------------------------------------------------------------------- #
# MOV reduction (Model 1).
# --------------------------------------------------------------------------- #

def mov_map(P: SymmetricPairing, g: int, x: int) -> Tuple[int, int]:
    """Theorem `mov_map`: e(x.g, g) = e(g, g)^x. Returns (lhs, rhs)."""
    lhs = P.e((x * g) % P.n, g)
    rhs = t_pow(P.n, P.e(g, g), x)
    return lhs, rhs


def mov_reduction(P: SymmetricPairing, g: int, a: int, b: int) -> Tuple[bool, bool]:
    """Theorem `mov_reduction`:
    e(a.g,g) = e(b.g,g)  <=>  a == b (mod ord(e g g)).
    Returns (pairing_equal, congruent)."""
    pairing_equal = P.e((a * g) % P.n, g) == P.e((b * g) % P.n, g)
    m = t_order(P.n, P.e(g, g))
    congruent = (a % m) == (b % m)
    return pairing_equal, congruent


def mov_attack_recover(P: SymmetricPairing, g: int, X_exp: int, bound: int) -> int:
    """`mov_recovers_dlog` in action: brute-force the finite-field discrete log
    e(X, g) = e(g, g)^x for the unique 0 <= x < bound (small embedding degree)."""
    target = P.e(X_exp, g)            # e(X, g) with X the public key point
    base = P.e(g, g)
    for x in range(bound):
        if t_pow(P.n, base, x) == target:
            return x
    raise ValueError("no discrete log found in range")


# --------------------------------------------------------------------------- #
# Alternating / antisymmetry (Model 2).
# --------------------------------------------------------------------------- #

def alternating_self(P: WeilPairing, p: Point) -> bool:
    """Alternating axiom: e(p, p) = 1."""
    return P.e(p, p) == t_one(P.r)


def antisymmetry(P: WeilPairing, p: Point, q: Point) -> bool:
    """Theorem `mul_swap_eq_one`: e(p,q) * e(q,p) = 1."""
    return t_mul(P.r, P.e(p, q), P.e(q, p)) == t_one(P.r)


def swap_eq_inv(P: WeilPairing, p: Point, q: Point) -> bool:
    """Theorem `swap_eq_inv`: e(q,p) = (e(p,q))^{-1} (exponent negation mod r)."""
    return P.e(q, p) == (-P.e(p, q)) % P.r


# --------------------------------------------------------------------------- #
# Driver.
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 70)
    print("BLS completeness  (bls_verify_correct):  e(x.H, g) = e(H, x.g)")
    print("=" * 70)
    P = SymmetricPairing(n=101)  # mu_101, prime so every nonzero exponent generates
    g = 7
    for (H, x) in [(13, 5), (40, 22), (3, 100), (55, 49)]:
        ok = bls_verify_correct(P, g, H, x)
        lhs = P.e((x * H) % P.n, g)
        rhs = P.e(H, (x * g) % P.n)
        print(f"  H={H:3d} x={x:3d} : e(x.H,g)={lhs:3d}  e(H,x.g)={rhs:3d}  -> {ok}")

    print()
    print("=" * 70)
    print("Aggregate BLS  (bls_aggregate_correct):")
    print("  e(sum sk_i.H_i, g) = prod e(H_i, sk_i.g)")
    print("=" * 70)
    hashes = [13, 40, 3, 55, 88]
    secrets = [5, 22, 100, 49, 17]
    ok = bls_aggregate_correct(P, g, hashes, secrets)
    agg = sum(sk * H for sk, H in zip(secrets, hashes)) % P.n
    lhs = P.e(agg, g)
    rhs = t_one(P.n)
    for sk, H in zip(secrets, hashes):
        rhs = t_mul(P.n, rhs, P.e(H, (sk * g) % P.n))
    print(f"  {len(hashes)} signers; aggregate exponent sum.H = {agg}")
    print(f"  LHS e(agg,g) = {lhs}    RHS prod = {rhs}    -> {ok}")

    print()
    print("=" * 70)
    print("MOV map  (mov_map):  e(x.g, g) = e(g, g)^x")
    print("=" * 70)
    g = 1  # so e(g,g)=1*1=1 exponent => generator of mu_101 (order 101)
    print(f"  base e(g,g) has order {t_order(P.n, P.e(g, g))} in mu_{P.n}")
    for x in [2, 9, 50, 100]:
        lhs, rhs = mov_map(P, g, x)
        print(f"  x={x:3d} : e(x.g,g)={lhs:3d}  e(g,g)^x={rhs:3d}  -> {lhs == rhs}")

    print()
    print("=" * 70)
    print("MOV faithfulness  (mov_reduction):")
    print("  e(a.g,g)=e(b.g,g)  <=>  a == b (mod ord(e g g))")
    print("=" * 70)
    m = t_order(P.n, P.e(g, g))
    for (a, b) in [(3, 3 + m), (10, 12), (50, 50 + 2 * m), (7, 8)]:
        pe, cong = mov_reduction(P, g, a, b)
        print(f"  a={a:3d} b={b:3d} (ord={m}): pairing_equal={pe}  congruent={cong}"
              f"  -> consistent={pe == cong}")

    print()
    print("=" * 70)
    print("MOV attack  (mov_recovers_dlog): recover unique secret x")
    print("=" * 70)
    for secret in [2, 37, 73, 100]:
        X_exp = (secret * g) % P.n           # public key point exponent
        recovered = mov_attack_recover(P, g, X_exp, bound=t_order(P.n, P.e(g, g)))
        print(f"  true x={secret:3d} -> recovered x={recovered:3d}"
              f"  -> {secret == recovered}")

    print()
    print("=" * 70)
    print("Weil pairing alternation + antisymmetry on E[r] = (Z_r)^2")
    print("  e(p,p)=1   e(p,q)*e(q,p)=1   e(q,p)=e(p,q)^{-1}")
    print("=" * 70)
    W = WeilPairing(r=17)
    pts: List[Point] = [(1, 0), (0, 1), (3, 5), (9, 4), (12, 7)]
    for p in pts:
        for q in pts:
            assert antisymmetry(W, p, q), (p, q)
            assert swap_eq_inv(W, p, q), (p, q)
        assert alternating_self(W, p), p
    print("  all alternation/antisymmetry checks passed for the 5x5 grid")
    p, q = (3, 5), (9, 4)
    print(f"  example: e({p},{q})={W.e(p, q)}  e({q},{p})={W.e(q, p)}  "
          f"sum mod r = {(W.e(p, q) + W.e(q, p)) % W.r} (=0 means product=1)")


if __name__ == "__main__":
    main()
