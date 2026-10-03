"""jlib2.py -- self-contained arithmetic for the function-field factoring axis.

No PARI in the hot path: (a) cypari2's ellinit returns an empty vector at some
primes (p=23), (b) we must COUNT modular multiplications per group operation to
measure cost, which a library call hides.

Three Z-defined structures, so that NOTHING here needs to know p:
  E    y^2 = x^3 - x over Z/nZ                (elliptic, dim 1)
  T_D  {(a,b) : a^2 - D b^2 = 1} over Z/nZ     (norm-one torus, dim 1)
  J    y^2 = x^5 - x over Z/nZ                 (genus 2; J ~ E x E via CM j=1728)

EARNED RULE: self-test before any number is believed (00_selftest.py).
"""
import random
from math import gcd

import sympy

# ---------------------------------------------------------------- EC (Jacobian projective)
class EC:
    """y^2 = x^3 + ax + b over R = Z/nZ.  Jacobian coordinates (X:Y:Z),
    x = X/Z^2, y = Y/Z^3.  Returns (new curve, cost) where cost = #mults."""

    __slots__ = ("n", "a", "b")

    def __init__(self, a=-1, b=0, n=1):
        self.a, self.b, self.n = a % n, b % n, n

    # doubling: standard dbl-2007-b for a != 0 (dbl-2007-bl is a=0 only)
    def dbl(self, P):
        n = self.n
        if P is None:
            return None, 0
        X1, Y1, Z1 = P
        if Y1 % n == 0 or Z1 % n == 0:
            return None, 1
        m = 6
        c = 2
        X2, Y2, Z2 = X1, Y1, Z1
        cost = 0
        # t = X1^2; u = Y1^2; s = 4*X1*u; ...
        XX, YY, ZZ = X2, Y2, Z2
        # ZZ = ZZ^2 ; S = YY + c*ZZ ; M = 3*XX + a*ZZ^2 ... use unified add below
        # use the simple (unified) addition formula, valid for doubling too
        return self.add(P, P, count=True)

    def add(self, P, Q, count=False):
        """Unified Jacobian addition (handles P==Q, P=-Q, infinity)."""
        n = self.n
        c = 0
        if P is None:
            return Q, c
        if Q is None:
            return P, c
        X1, Y1, Z1 = P
        X2, Y2, Z2 = Q
        # Z1Z1, Z2Z2, U1, U2, S1, S2
        Z1Z1 = Z1 * Z1 % n; c += 1
        Z2Z2 = Z2 * Z2 % n; c += 1
        U1 = X1 * Z2Z2 % n; c += 1
        U2 = X2 * Z1Z1 % n; c += 1
        S1 = Y1 * Z2 % n * Z2 % n; c += 2
        S2 = Y2 * Z1 % n * Z1 % n; c += 2
        if U1 == U2:
            if S1 != S2:
                return None, c            # P + (-P) = O
            return self.dbl_generic(P, c)
        H = U2 - U1 % n; c += 1
        R = S2 - S1 % n; c += 1
        # H2, H3, ...  (Jacobian, cost ~ 12M)
        H2 = H * H % n; c += 1
        H3 = H * H2 % n; c += 1
        HH = H2 * 2 % n; c += 1
        I = 4 * HH % n; c += 1
        J = H * I % n; c += 1
        r = 2 * R % n; c += 1
        V = U1 * I % n; c += 1
        X3 = (r * r - J - 2 * V) % n; c += 2
        Y3 = (r * (V - X3) - 2 * S1 * J) % n; c += 2
        Z3 = ((Z1 + Z2) * (Z1 + Z2) - Z1Z1 - Z2Z2) % n * H % n; c += 3
        return (X3, Y3, Z3), c

    def dbl_generic(self, P, c=0):
        n = self.n
        X1, Y1, Z1 = P
        ZZ = Y1 * Y1 % n; c += 1
        S = 2 * ((X1 + ZZ) * (X1 + ZZ) % n - X1 * X1 % n - ZZ * ZZ) % n; c += 5
        M = 3 * X1 * X1 % n + self.a * pow(Z1, 4, n) % n; c += 4
        T = M * M % n - 2 * S % n; c += 2
        # X3 = T ; Y3 = M*(S-T) - 8*ZZ^2 ; Z3 = 2*Y1*Z1
        Y3 = (M * (S - T) % n - 8 * pow(ZZ, 2, n)) % n; c += 4
        Z3 = 2 * Y1 * Z1 % n; c += 2
        return (T, Y3, Z3), c

    def mul(self, P, k, count=False):
        """double-and-add.  returns (Q, cost)."""
        if k < 0:
            P2, c0 = self.neg(P)
            return self.mul(P2, -k, count)
        R, cost = None, 0
        Q, c = P, 0
        while k:
            if k & 1:
                R, c2 = self.add(R, Q)
                cost += c2
            k >>= 1
            if k:
                Q, c2 = self.dbl(Q)
                cost += c2
        return R, cost

    def neg(self, P):
        if P is None:
            return None, 0
        n = self.n
        return ((P[0]) % n, (-P[1]) % n, P[2] % n), 0

    def aff(self, P):
        if P is None:
            return None
        n = self.n
        zi = pow(P[2], -1, n) if gcd(P[2], n) == 1 else None
        if zi is None:
            # Z not a unit mod n  =>  THIS IS A FACTOR
            return ("FACTOR", gcd(P[2], n))
        zi2 = zi * zi % n
        return (P[0] * zi2 % n, P[1] * zi2 % n * zi % n), 0

    def on_curve(self, P):
        x, y = P
        return (y * y - (x * x * x + self.a * x + self.b)) % self.n == 0

    def rand_point_affine(self):
        n = self.n
        while True:
            x = random.randrange(n)
            rhs = (x * x % n * x + self.a * x + self.b) % n
            y = pow(rhs, (n + 1) // 4, n) if n % 4 == 3 else None
            if y is not None and y * y % n == rhs:
                return (x, y)
        return None


# ---------------------------------------------------------------- torus
class Torus:
    """Norm-one torus T_D = {(a,b): a^2 - D b^2 = 1} over Z/nZ."""

    __slots__ = ("D", "n")

    def __init__(self, D, n):
        self.D, self.n = D % n, n

    def ident(self):
        return (1 % self.n, 0)

    def is_member(self, pt):
        a, b = pt
        return (a * a - self.D * b * b - 1) % self.n == 0

    def mul(self, p, q):
        a, b = p
        c, d = q
        return ((a * c + self.D * b * d) % self.n, (a * d + b * c) % self.n)

    def neg(self, p):
        # (a,b)*(a,-b) = (a^2 - D b^2, 0) = (1,0) = identity.  NOT (-a,-b).
        a, b = p
        return (a, (self.n - b) % self.n)

    def rand_point(self):
        """Rejection sample T_D(Z/nZ).  |T_D(Z/nZ)| = n(1+O(1/sqrt n)) out of
        n^2 pairs, so this needs ~n tries -- TOO SLOW for n ~ 10^6.
        Use fast_point() in experiments; this is kept only for tiny n."""
        n = self.n
        while True:
            a, b = random.randrange(n), random.randrange(n)
            if self.is_member((a, b)):
                return (a, b)

    def rand_point_pp(self):
        """Fast sampler for T_D(F_p) with p prime, p = 3 mod 4.
        Pick b uniform, set a = sqrt(1 + D b^2) mod p.  Cost O(1) per
        candidate (expected 2 tries).  Rejection over (a,b) pairs costs O(p)
        tries -- that is what made the earlier run hang for minutes."""
        p = self.n
        if p % 4 != 3:
            raise ValueError("rand_point_pp needs p = 3 mod 4")
        while True:
            b = random.randrange(p)
            v = (1 + self.D * b * b) % p
            a = pow(v, (p + 1) // 4, p)
            if a * a % p == v:
                return (a, b)

    def rand_point_pq(self, p, q):
        """Sampler when the factorisation n=p*q is KNOWN (test harness only).
        Builds the element CRT-wise from random points in T_D(F_p)."""
        assert self.n == p * q
        Tp, Tq = Torus(self.D, p), Torus(self.D, q)
        xp, yp = Tp.rand_point_pp()
        xq, yq = Tq.rand_point_pp()
        a = (xp + p * (((xq - xp) * pow(p, -1, q)) % q)) % self.n
        b = (yp + p * (((yq - yp) * pow(p, -1, q)) % q)) % self.n
        assert self.is_member((a, b))
        return (a, b)

    def pow(self, p, k):
        r = self.ident()
        while k:
            if k & 1:
                r = self.mul(r, p)
            p = self.mul(p, p)
            k >>= 1
        return r


# ---------------------------------------------------------------- smoothness
_SMALL = list(sympy.primerange(2, 200000))


def smooth_factors(n, B):
    """Prime factorisation of n restricted to primes <= B.  Returns (ok, cofactor)."""
    n = int(n)
    if n <= 1:
        return True, 1
    for p in _SMALL:
        if p > B:
            break
        while n % p == 0:
            n //= p
        if n == 1:
            return True, 1
    return n == 1, n


def is_smooth(n, B):
    return smooth_factors(n, B)[0]


def trial_smooth_count(n, B):
    """Count of distinct prime factors of n that are <= B (for structure checks)."""
    return len(sympy.factorint(n, limit=B)) if n > 1 else 0