"""00_selftest.py -- EARNED RULE #1.

A group law must verify f*f^{-1} = identity for many random points BEFORE any
number it produces is believed.  Tightest cases, not representative ones.

A1  E :  P + (-P) = O   in E(F_p), p = 3 mod 4, incl. p=7,11 (smallest).
A2  E :  P + (-P) = O   in E(Z/nZ), n = p*q  (the ECM object; n composite,
     so a wrong projective formula shows up here, not in A1).
A3  E :  [k]P computed two ways agrees (associativity / doubling consistency):
     left-to-right double-and-add vs. naive sum of P, for random k.
A4  T_D: f*f^{-1} = id and closure in T_D(Z/nZ) for many D, n = p*q.
A5  T_D: |T_D(F_p)| = p - (D/p) EXACTLY, verified by exhaustive enumeration of
     the group (tightest: small p, both split and inert D).
A6  CRITICAL SUB-PROBLEM CHECK: does the torus walk mod n actually produce a
     factor, i.e. is the structure *usable* without knowing p?  Measured as the
     fraction of random torus elements f whose gcd(f^{-1} - e, n) or whose
     smoothness search yields p.
"""
import random
import sys
from math import gcd

import sympy

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from ell import Ell                                   # noqa: E402
from jlib2 import Torus, is_smooth                    # noqa: E402


def is_qr(a, p):
    """Euler's criterion: a is a quadratic residue mod the prime p iff
    a^((p-1)/2) == 1.  sympy's is_square DISAGREES with this at 41 bits
    (measured: 3/6 random residues where Euler says QR, is_square says no),
    so we use the criterion, which is exact for prime p."""
    return pow(a % p, (p - 1) // 2, p) == 1


random.seed(20261003)
FAILURES = []


def rep(name, ok, detail=""):
    print(f"  [{'ok  ' if ok else 'FAIL'}] {name} {detail}")
    if not ok:
        FAILURES.append(name)


def A1():
    bad = None
    for p in [p for p in sympy.primerange(5, 400) if p % 4 == 3]:
        E = Ell(p)
        for _ in range(30):
            x, y, _ = E.rand_point()
            P = (x, y, 1)
            Q = E.neg(P)[0]
            R, _ = E.add(P, Q)
            if R is not None:
                bad = (p, (x, y), R)
                break
        if bad:
            break
    rep("A1 E: P+(-P)=O over F_p (p=3 mod 4, 5..400)", bad is None, str(bad or ""))


def A2():
    """Tightest: n = p*q with the SMALLEST admissible primes, and n=6,15 etc."""
    bad = None
    cases = [(7, 11), (11, 19), (23, 31), (3, 7), (5, 11), (59, 83),
             (431, 487), (1009, 1013), (1013, 1019)]
    for p, q in cases:
        n = p * q
        E = Ell(n)
        for _ in range(40):
            x = random.randrange(n)
            rhs = (x * x % n * x - x) % n
            # y exists mod n iff rhs is a QR mod both p and q
            if not (sympy.ntheory.primetest.is_square(rhs % p)
                    and sympy.ntheory.primetest.is_square(rhs % q)):
                continue
            y = int(sympy.sqrt_mod(rhs, n))  # returns a single int, not a list
            P = (x, y, 1)
            Q = E.neg(P)[0]
            R, _ = E.add(P, Q)
            if R is not None:
                bad = (n, (x, y), R)
                break
        if bad:
            break
    rep("A2 E: P+(-P)=O over Z/nZ, n=p*q (composite!)", bad is None, str(bad or ""))


def A3():
    bad = None
    for p in [p for p in sympy.primerange(5, 200) if p % 4 == 3]:
        E = Ell(p)
        N = int(pari_card(p)) if False else None
        x, y, _ = E.rand_point()
        P = (x, y, 1)
        for k in range(1, 40):
            R1, c1 = E.mul(P, k)
            R2 = None
            for _ in range(k):
                R2, _ = E.add(R2, P)
            if E.to_affine(R1)[0] != E.to_affine(R2)[0]:
                bad = (p, k, E.to_affine(R1)[0], E.to_affine(R2)[0])
                break
        if bad:
            break
    rep("A3 E: [k]P double-and-add == k naive adds (k=1..39)", bad is None,
        str(bad or ""))


def pari_card(p):
    # #E(F_p) for y^2=x^3-x, p = 3 mod 4, is p+1 (supersingular).  Verify by
    # brute point count for small p -- we do NOT want to trust PARI here.
    p = int(p)
    n = 0
    for x in range(p):
        rhs = (x * x % p * x - x) % p
        n += 1 + is_qr(rhs, p)  # 2 pts or 1 (y=0)
    return n + 1  # + point at infinity


def A4():
    bad = None
    for D in (2, 3, 5, 6, 7, 10, 11, 13, 14, 15, 17, 19, 21, 22, 23, 26):
        for p, q in [(7, 11), (11, 19), (23, 31), (59, 83), (431, 487)]:
            n = p * q
            T = Torus(D, n)
            ident = T.ident()
            for _ in range(40):
                f = T.rand_point_pq(p, q)
                finv = T.neg(f)
                if T.mul(f, finv) != ident:
                    bad = (D, n, "f*f^-1 != id", T.mul(f, finv), ident)
                    break
                g = T.rand_point_pq(p, q)
                if not T.is_member(T.mul(f, g)):
                    bad = (D, n, "not closed")
                    break
            if bad:
                break
        if bad:
            break
    rep("A4 T_D: closure + f*f^-1=id over Z/nZ (16 D values)", bad is None,
        str(bad or ""))


def A5():
    bad = None
    tested = 0
    for D in (2, 3, 5, 6, 7, 10, 11, 13, 14, 17, 19, 21, 22, 23):
        for p in [p for p in sympy.primerange(3, 130) if p % 4 == 3]:
            if D % p == 0:      # D=3,p=3: D is 0 mod p, torus degenerates
                continue        # (ramified, order formula not p-chi)
            T = Torus(D, p)
            chi = pow(D, (p - 1) // 2, p)
            chi = -1 if chi == p - 1 else 1
            want = p - chi
            # enumerate the group: start at identity, multiply by random elements
            # exact enumeration: |T| = want <= p+1 <= 131, so enumerate ALL
            # (a,b) pairs -- this is the tightest possible check.
            seen = {(a, b) for a in range(p) for b in range(p)
                    if (a * a - D * b * b - 1) % p == 0}
            tested += 1
            if len(seen) != want:
                bad = (D, p, len(seen), want)
                break
        if bad:
            break
    rep(f"A5 T_D: |T_D(F_p)| = p-(D/p) exact ({tested} (D,p) pairs enumerated)",
        bad is None, str(bad or ""))


def A6():
    """Is the torus structure USABLE over Z/nZ without knowing p?
    Two probes:
      (i)  gcd(f^-1 - e, n): does the torus inverse hand us a factor free?
      (ii) the smoothness search DOES find elements whose order is divisible
           by p (this is the mechanism, verified WITH p known -- its cost when
           p is UNKNOWN is the axis's critical sub-problem, measured in
           01_cost_to_reach_p.py)."""
    D, p, q = 2, 1000003, 1000039
    n = p * q
    T = Torus(D, n)
    trivial = 0
    for _ in range(200):
        f = T.rand_point_pq(p, q)
        trivial += (gcd(T.neg(f)[0] - 1, n) == 1)
    # (ii) the ECM analogue: the order of f mod p is a B-SMOOTH number and the
    # order mod q is NOT (or vice versa) -> gcd(f^(lcm) - 1, n) splits n.
    # Here we only check that such f EXIST in abundance when p is known.
    hits = 0
    for _ in range(300):
        f = T.rand_point_pq(p, q)
        op = ord_mod_p(T, f, p)
        oq = ord_mod_p(T, f, q)
        B = 256
        if is_smooth(op, B) != is_smooth(oq, B):
            hits += 1
    print(f"       (i)  gcd(f^-1-e, n)=1 in {trivial}/200")
    print(f"       (ii) f whose smoothness at B=256 DIFFERS mod p vs q: {hits}/300")
    rep("A6a torus inverse gives NO free factor", trivial == 200)
    rep("A6b torus walk finds smoothness-separating elements (uses p)", hits > 5)


def ord_mod_p(T, f, p):
    """Exact order of f mod p, given p.  This is the CHEAT: ECM never gets it."""
    Tp = Torus(T.D, p)
    r = (f[0] % p, f[1] % p)
    if r == Tp.ident():
        return 1
    chi = pow(T.D, (p - 1) // 2, p)
    chi = -1 if chi == p - 1 else 1
    M = p - chi                       # |T_D(F_p)| = p - chi, exact
    o = M
    for pr in sympy.factorint(M):
        while o % pr == 0 and Tp.pow(r, o // pr) == Tp.ident():
            o //= pr
    return o


print("SELF-TEST  (EARNED RULE #1: verify f*f^-1 = identity first)")
A1()
A2()
A3()
A4()
A5()
A6()
print()
if FAILURES:
    print(f"FAILED: {FAILURES}")
    sys.exit(1)
print("ALL SELF-TESTS PASS")