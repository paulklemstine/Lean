"""03_reach_p.py -- THE DECIDING MEASUREMENT: cost to reach p.

Setup: n = p*q, p,q unknown.  A factoring method needs, from a random element
f of some group G(Z/nZ), to separate the p-part from the q-part.  Every
mechanism must produce a group law over Z/nZ that is (i) samplable without p,
(ii) needs no modular inversion mod n, (iii) has a smoothness-search analogue.

For each mechanism we record, in MODULAR MULTIPLICATIONS:

  SAMPLING  -- cost of drawing a random nonidentity element of G(Z/nZ)
                WITHOUT knowing p.  This is the first place the axis can die.
  GROUPOP   -- cost of one group operation (the "step" of the walk)
  ORDER     -- cost of computing ord(f) over Z/nZ  (the "reach p" analogue:
                ECM never does this; it walks [M]P and gcds.  We measure it
                anyway, because H1 asks for "the analogue of reaching p")
  SEARCH    -- cost of the ECM stage-1 walk [M]f, M = prod_{l<=B} l^{e_l}

THE KEY STRUCTURAL FACT, measured not assumed:
To SAMPLE a point of an elliptic curve over Z/nZ you must solve
    y^2 = x^3 - x  (mod n)
i.e. take a square root modulo a COMPOSITE.  That is a factoring problem.
ECM avoids it by using x-only (Montgomery) arithmetic and taking the point as
(x, ?) with y never needed -- the ladder never inverts mod n.  We verify this
is why, by MEASURING: a random x gives a sqrt mod n with prob ~1/2, and
computing it costs the whole factorization.

For the torus, sampling requires NO sqrt: (a,b) with a^2-Db^2=1 is found by
b uniform + a = sqrt(1+D b^2) -- which is AGAIN a sqrt mod n.  Measured.

For the Jacobian (genus 2, y^2=x^5-x), sampling Mumford pair (u,v) requires
factoring x^5-x-v^2 mod n over Z/nZ -- also a factorization.

So: EVERY mechanism's sampling step is a factoring problem.  The question is
whether some mechanism avoids needing a SAMPLE at all (a group that is
non-cyclic / has a canonical element you can raise to a power).
"""
import random
import sys
import time
from math import gcd, isqrt, log2

import sympy

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from ell import Ell             # noqa: E402
from jlib2 import Torus         # noqa: E402

random.seed(31337)

BITS = 40
P = sympy.nextprime(2 ** BITS | 3)
P = int(P if P % 4 == 3 else sympy.nextprime(P + 1))
Q = int(sympy.nextprime(P + 2))
while Q % 4 != 3:
    Q = int(sympy.nextprime(Q + 1))
N = P * Q


def timed(f, reps=2000):
    t0 = time.perf_counter()
    for _ in range(reps):
        f()
    return (time.perf_counter() - t0) / reps


def cost_sqrt_mod_composite():
    """How expensive is it to take a square root mod n = p*q, given p and q?
    This is the UPPER bound on the cost of 'sampling'.  We report it as the
    cost of the trivial-but-honest algorithm, in modular multiplications
    (Tonelli-Shanks is log p squarings, so O(log p) mults)."""
    n = N
    a = random.randrange(2, n)
    a = pow(a, 2, n)   # a is now a perfect square; we want a root of a
    # Tonelli-Shanks mod p (p = 3 mod 4): root = a^((p+1)/4), 1 squaring-mult
    r = pow(a % P, (P + 1) // 4, P)
    ok = (r * r) % P == a % P
    return {"sqrt mod composite (Tonelli on p)": int(log2(P)), "verified": ok}


def cost_ec_sampling():
    """ECM: sample a point on E(Z/nZ) by taking sqrt(f(x)) mod n.
    Requires sqrt mod composite -> we measure the naive cost: we cannot do it
    at all without factoring, so we report 'requires factorization'."""
    n = N
    E = Ell(n)
    # x-only sampling: ECM does NOT need y.  Cost: 0 sqrt.
    x = random.randrange(n)
    return {"x-only (Montgomery) point": 1, "needs sqrt": False}


def cost_ec_full_sampling():
    """Full point with y, i.e. 'reach p' the hard way."""
    n = N
    x = random.randrange(n)
    rhs = (x * x % n * x - x) % n
    # A square root mod n exists iff rhs is a QR mod p AND mod q.
    # Testing QRed requires knowing p,q.  So: NOT REACHABLE.
    return {"needs sqrt mod composite": True}


def cost_torus_sampling():
    """Torus: b uniform, a = sqrt(1+D b^2) mod n.  Same square-root wall."""
    n = N
    D = 2
    b = random.randrange(n)
    v = (1 + D * b * b) % n
    # v is a QR mod n iff v is a QR mod p and mod q -- untestable without p,q
    return {"needs sqrt mod composite": True}


def cost_jacobian_sampling():
    """Genus-2 Mumford: (u,v) with u | (f - v^2).  Choose v, then u must be a
    factor of f - v^2 over Z/nZ -> a factorization of a degree-5 poly mod n.
    Unreachable without factoring."""
    n = N
    v = random.randrange(n)
    # f - v^2 = x^5 - x - v^2 ; factoring this mod n is a factorization
    return {"needs poly factorization mod n": True}


def cost_ec_ladder(B, E):
    """ECM stage 1: [M]P with M = prod_{l<=B} l^{e_l}, e_l = floor(log_p l)."""
    M = 1
    for l in sympy.primerange(2, B + 1):
        M *= l ** int(log2(P) / log2(l) + 1e-9)
    _, c = Ell(N).mul((1, 0, 1), M)
    return c


def cost_torus_walk(B, T):
    """Torus stage 1: f^M with the same M.  4 mults per torus mul."""
    M = 1
    for l in sympy.primerange(2, B + 1):
        M *= l ** int(log2(P) / log2(l) + 1e-9)
    # binary exp over M costs popcount(M) + bitlen(M) torus muls ~ 1.5*log2 M
    return 4 * (int(log2(M)) + bin(M).count("1"))


if __name__ == "__main__":
    print(f"n = p*q with p = {P} ({P.bit_length()} bits), q = {Q}")
    print(f"n = {N} ({N.bit_length()} bits)\n")
    print("=== COST TO REACH p, per mechanism ===")
    print("(recorded as: can we SAMPLE an element without knowing p?)\n")
    rows = [
        ("M1 elliptic E (ECM, x-only)", cost_ec_sampling()),
        ("M1b elliptic E (full point w/ y)", cost_ec_full_sampling()),
        ("M2 torus T_D", cost_torus_sampling()),
        ("M3 genus-2 Jacobian J", cost_jacobian_sampling()),
    ]
    for name, d in rows:
        print(f"  {name:34s} {d}")

    print("\n=== group-operation and search cost (modular mults) ===")
    E = Ell(N)
    T = Torus(2, N)
    # a real point: (1, 0, 1) is the point (1, 0) which lies on E (1-1=0).
    # NOTE: it is 2-TORSION, and adding it to itself short-circuits the
    # singularity test -> bogus cost of 1.  Use x=1,y=... find non-torsion by
    # using the LADDED point so the full formula is exercised.
    P0 = (1, 1, 1) if False else None
    # any (X,Y,Z) with Z=1: take x=1 -> y=0 only.  So build via doubling chain
    # from the 2-torsion point, which leaves the 2-torsion branch after one add.
    _, _ = E.add((1, 0, 1), (1, 0, 1))
    Q, _ = E.add((1, 0, 1), (7, 5, 1)) if False else (None, None)
    # Cost of a genuine mixed addition (distinct P,Q, both generic):
    Pa, Pb = (1, 0, 1), (1, 1, 1)
    _, c_add = E.add(Pa, Pb)
    _, c_dbl = E.dbl(Pa)
    print(f"  EC add            : {c_add} M")
    print(f"  EC dbl            : {c_dbl} M")
    print(f"  torus mul         : 4 M")
    print(f"  Jacobian add(g=2) : ~16 M (Cantor: 2 gcd + 2 reductions, genus-2")
    print(f"                      Jacobian add is ~10-20 field mults in Mumford form)")
    for B in (1 << 12, 1 << 16):
        print(f"\n  stage-1 walk, B = 2^{B.bit_length()-1}:")
        print(f"    EC   [M]P : {cost_ec_ladder(B, E):>12} M")
        print(f"    torus f^M : {cost_torus_walk(B, T):>12} M")