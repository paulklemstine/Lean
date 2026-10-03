"""jlib.py -- function-field / torus arithmetic for the factoring axis.

Scope: everything here is *defined over Z* (or Z/NZ).  Nothing needs to know p.

Three structures:
  * EC:   elliptic curve E over Z/NZ.  Group order mod p is ~ p.
  * TOR:  norm-one torus T_D = {(a,b) : a^2 - D b^2 = 1} over Z/NZ.
          Group law (a,b)*(a',b') = (aa' + D b b', a b' + b a').  4 modmuls.
          Order mod p is exactly p - (D/p)  in {p-1, p+1}.
  * JAC:  Mumford/Cantor Jacobian over Z/NZ (genus g).  Order mod p ~ p^g.

Self-test rule (EARNED): a walk must verify f*f^{-1} = identity for many
random points before any number it produces is believed.
"""
import random
from math import gcd

import sympy
from cypari2 import Pari

pari = Pari()


# ---------------------------------------------------------------- utilities
def ecmiller_rabin(n, rounds=24):
    """Deterministic-enough PRIMALITY for our sizes (also sympy cross-checked)."""
    if n < 2:
        return False
    for sp in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % sp == 0:
            return n == sp
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for _ in range(rounds):
        a = random.randrange(2, n - 1)
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def is_smooth(n, B):
    """B-smooth: every prime factor <= B.  n>0."""
    if n <= 1:
        return True
    for p in sympy.primerange(2, B + 1):
        while n % p == 0:
            n //= p
        if n == 1:
            return True
    return n == 1


def dickman_rho(u):
    """Dickman rho(u) = P(random n <= x is B-smooth), x = B^u."""
    if u <= 0:
        return 1.0
    if u == 1:
        return 1.0 - 0.3068528194  # 1 - log(2)
    # Buchstab-based: rho(u) = 1 - int_1^u rho(t-1)/t dt ; solve by Simpson
    import math

    def f(t):
        if t <= 1:
            return math.log(2)
        return rho(t - 1) / t

    rho.cache = {1.0: 1.0 - math.log(2), 2.0: 1.0 - math.log(2) * (1 + math.log(2))}
    N = 4000
    h = (u - 1.0) / N
    tot = 0.0
    for i in range(N + 1):
        t = 1.0 + i * h
        w = 1 if i in (0, N) else (4 if i % 2 else 2)
        tot += w * f(t)
    return 1.0 - tot * h / 3.0


# ------------------------------------------------------------------- torus
class Torus:
    """Norm-one torus T_D over Z (or Z/NZ).  (a,b) with a^2 - D b^2 = 1."""

    __slots__ = ("D", "n")

    def __init__(self, D, n):
        self.D = D % n
        self.n = n

    def is_member(self, pt):
        a, b = pt
        return (a * a - self.D * b * b - 1) % self.n == 0

    def mul(self, p, q):
        """(a,b)*(a',b') = (aa' + D bb', ab' + ba')."""
        a, b = p
        c, d = q
        return ((a * c + self.D * b * d) % self.n, (a * d + b * c) % self.n)

    def neg(self, p):
        a, b = p
        return ((a * self.n - a) % self.n, (self.n - b) % self.n)

    def ident(self):
        return (1 % self.n, 0)

    def gen(self):
        while True:
            a, b = random.randrange(self.n), random.randrange(self.n)
            if self.is_member((a, b)) and (a, b) != self.ident():
                return (a, b)

    def pow(self, p, k):
        r = self.ident()
        b = p
        while k:
            if k & 1:
                r = self.mul(r, b)
            b = self.mul(b, b)
            k >>= 1
        return r

    def order(self, p):
        """Exact order of p in T(Z/nZ) = lcm of its orders mod each prime factor."""
        n = self.n
        fs = sympy.factorint(n)
        ans = 1
        for q, e in fs.items():
            sub = Torus(self.D, q)
            r = (p[0] % q, p[1] % q)
            if r == sub.ident():
                continue
            k = 1
            r2 = r
            # divide n by prime factors
            # generic: find order by baby search over factor structure
            M = q - 1  # order of T(F_q) divides q - (D/q) in {q-1,q+1}
            lg = sympy.ntheory.factor_.core(M, 2) if False else M
            o = None
            fM = sympy.factorint(M)
            cand = M
            for pr in fM:
                while cand % pr == 0:
                    cand //= pr
                    if sub.pow(r, cand) != sub.ident():
                        pass
                    else:
                        cand *= pr
                        o = cand
            o = o or cand
            ans = sympy.ilcm(ans, o)
        return ans


# --------------------------------------------------------- elliptic (genus 1)
def ec_curve(p):
    # NB: p must be a NATIVE python int -- sympy.Integer makes ellinit/ellcard
    # build a t_VEC model and PARI rejects it ("incorrect type in checkell").
    return pari.ellinit([0, 0, 0, -1, 1], int(p))  # y^2 = x^3 - x


def ec_random_point(E, p):
    p = int(p)
    if p % 4 != 3:
        raise ValueError("ec_random_point assumes p = 3 mod 4")
    while True:
        x = random.randrange(p)
        rhs = (x * x % p * x - x) % p
        y = pow(rhs, (p + 1) // 4, p)
        if y * y % p == rhs:
            return pari([x, y])


def ec_mul(E, P, k):
    return pari.ellmul(E, P, int(k))


def ec_neg(E, P):
    return pari.ellneg(E, P)


def ec_card(p):
    # ellcard takes an *initialised* curve here; the bare vector form errors
    # ("incorrect type in checkell (t_VEC)").  #E(F_p) = 100 for p=101, p=3 mod 4.
    return int(pari.ellcard(ec_curve(p)))