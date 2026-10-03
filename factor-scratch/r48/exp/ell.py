"""ell.py -- Jacobian-projective elliptic curve group law over Z/nZ, with a
modular-multiplication counter.

y^2 = x^3 + a*x + b,  a = -1, b = 0  (j = 1728; supersingular at p = 3 mod 4,
so #E(F_p) = p+1 for p = 3 mod 4 -- a fact we exploit to KNOW the group order
without a Schoof step).

Representation: Jacobian coordinates (X:Y:Z) with x = X/Z^2, y = Y/Z^3.
Identity O = None.
Cost: each method returns (result, nmult) with nmult = # modular multiplications,
so the ECM-vs-function-field comparison is measured in the same unit.
"""
from math import gcd


class Ell:
    __slots__ = ("a", "b", "n")

    def __init__(self, n, a=-1, b=0):
        self.a, self.b, self.n = a % n, b % n, n

    # ---------------------------------------------------------- doubling
    def dbl(self, P):
        """dbl-2007-b (works for any a).  Returns (Q, nmult)."""
        n = self.n
        if P is None:          # O + O = O
            return None, 0
        X1, Y1, Z1 = P
        if Y1 % n == 0:
            return None, 1
        XX = X1 * X1 % n              # 1
        YY = Y1 * Y1 % n              # 1
        YYYY = YY * YY % n           # 1
        ZZ = Z1 * Z1 % n              # 1
        S = 2 * ((X1 + YY) % n * (X1 + YY) - XX - YYYY) % n   # 1
        M = (3 * XX + self.a * ZZ % n * ZZ) % n               # 2
        T = (M * M - 2 * S) % n                                # 1
        # X3 = T
        Y3 = (M * (S - T) - 8 * YYYY) % n                     # 2
        Z3 = ((Y1 + Z1) * (Y1 + Z1) - YY - ZZ) % n            # 1
        return (T, Y3, Z3), 11

    # ---------------------------------------------------------- addition
    def add(self, P, Q):
        """add-2007-bl (a1=a2=a3=0).  Returns (R, nmult)."""
        n = self.n
        if P is None:
            return Q, 0
        if Q is None:
            return P, 0
        X1, Y1, Z1 = P
        X2, Y2, Z2 = Q
        Z1Z1 = Z1 * Z1 % n                     # 1
        Z2Z2 = Z2 * Z2 % n                     # 1
        U1 = X1 * Z2Z2 % n                     # 1
        U2 = X2 * Z1Z1 % n                     # 1
        S1 = Y1 * Z2 % n * Z2Z2 % n            # 2   = Y1*Z2^3
        S2 = Y2 * Z1 % n * Z1Z1 % n            # 2   = Y2*Z1^3
        H = (U2 - U1) % n                      # -
        if H == 0:
            if (S2 - S1) % n == 0:
                return self.dbl(P)             # P == Q
            return None, 9                     # P == -Q
        r = 2 * ((S2 - S1) % n) % n            # -   r = 2(S2-S1)
        I = (2 * H) * (2 * H) % n              # 1   I = 4H^2
        J = H * I % n                           # 1   J = 4H^3
        V = U1 * I % n                          # 1
        X3 = (r * r - J - 2 * V) % n           # 2
        Y3 = (r * (V - X3) - 2 * S1 * J) % n   # 3
        Z3 = ((Z1 + Z2) * (Z1 + Z2) - Z1Z1 - Z2Z2) % n * H % n   # 3
        return (X3, Y3, Z3), 15

    # ---------------------------------------------------------- negation
    def neg(self, P):
        if P is None:
            return None, 0
        return (P[0], (-P[1]) % self.n, P[2]), 0

    # ---------------------------------------------------------- scalar mult
    def mul(self, P, k):
        """left-to-right double-and-add.  Returns (Q, nmult)."""
        if k == 0:
            return None, 0
        neg = k < 0
        if neg:
            P = self.neg(P)[0]
            k = -k
        R, cost = P, 0          # left-to-right: seed with the top bit set
        for i in range(k.bit_length() - 2, -1, -1):
            R, c = self.dbl(R)
            cost += c
            if (k >> i) & 1:
                R, c = self.add(R, P)
                cost += c
        return (self.neg(R)[0], cost) if neg else (R, cost)

    # ---------------------------------------------------------- conversion
    def to_affine(self, P):
        """Return (x, y) or ('FACTOR', g) if Z is not a unit mod n."""
        if P is None:
            return None, 0
        n = self.n
        g = gcd(P[2], n)
        if g != 1:
            return ("FACTOR", g), 0
        zi = pow(P[2], -1, n)      # 1 inversion
        zi2 = zi * zi % n           # 1
        zi3 = zi2 * zi % n          # 1
        return (P[0] * zi2 % n, P[1] * zi3 % n), 3

    # ---------------------------------------------------------- sampling
    def rand_point(self):
        """Uniform-ish sample from E(Z/nZ): x uniform, y a square root mod p if
        n is prime and =3 mod 4.  For composite n we sample per-factor and CRT.
        """
        n = self.n
        if gcd(n, 2) == 1 and n % 4 == 3:
            while True:
                x = random.randrange(n)
                rhs = (x * x % n * x + self.a * x + self.b) % n
                y = pow(rhs, (n + 1) // 4, n)
                if y * y % n == rhs:
                    return (x, y, 1)
        raise ValueError("rand_point: composite or p=1 mod 4; use rand_point_crt")

    def on_curve_aff(self, x, y):
        return (y * y - (x * x * x + self.a * x + self.b)) % self.n == 0


import random  # noqa: E402  (used by rand_point)