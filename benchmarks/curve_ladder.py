"""
curve_ladder.py — Standardized ECDLP/ECDSA benchmark harness.

Contents
--------
1. Frozen curve ladder (j-invariant-0 curves, 16..64 bit) with known ground truth.
2. Affine point arithmetic on gmpy2.mpz (inversion via gmpy2.invert).
3. Baselines: Baby-Step Giant-Step (BSGS) and vanilla Pollard's Rho
   (distinguished-point method).  These are the reference implementations
   against which all new algorithms are compared.
4. ECDSA sign/verify + per-curve signature corpora (for HNP/lattice vectors).

Conventions
-----------
* One "group operation" = one point addition/doubling on E(F_p).
  Precomputation of step tables is excluded (identical for all solvers).
* Solvers receive ONLY (curve, Q, n) — never the secret d (oracle-leak guard).
"""
import random

import gmpy2
from gmpy2 import mpz

from _curve_data import CURVES


# ---------------------------------------------------------------------------
# Curve class
# ---------------------------------------------------------------------------
class Curve:
    """E: y^2 = x^3 + b over F_p, with distinguished subgroup <G> of order n.

    Field elements are gmpy2.mpz.  Points are (x, y) mpz tuples; None = O.
    """

    def __init__(self, p, b, n, h, Gx, Gy, lam, beta, N=None, k=None):
        self.k = k
        self.p = mpz(p)
        self.b = mpz(b)
        self.n = int(n)
        self.h = int(h)
        self.N = int(N) if N is not None else self.n * self.h   # #E(F_p)
        self.G = (mpz(Gx), mpz(Gy))
        self.lam = int(lam)      # eigenvalue of phi on <G>: phi(G) = lam*G
        self.beta = mpz(beta)    # primitive cube root of unity mod p

    # -- arithmetic ------------------------------------------------------
    def add(self, P, Q):
        """Affine point addition. None denotes the point at infinity."""
        if P is None:
            return Q
        if Q is None:
            return P
        p = self.p
        x1, y1 = P
        x2, y2 = Q
        if x1 == x2:
            if (y1 + y2) % p == 0:
                return None
            lam = (3 * x1 * x1) * gmpy2.invert(2 * y1, p) % p
        else:
            lam = (y2 - y1) * gmpy2.invert(x2 - x1, p) % p
        x3 = (lam * lam - x1 - x2) % p
        y3 = (lam * (x1 - x3) - y1) % p
        return (x3, y3)

    def neg(self, P):
        if P is None:
            return None
        return (P[0], self.p - P[1])

    def mul(self, k, P):
        """Double-and-add scalar multiplication."""
        k = int(k) % self.n
        R = None
        while k:
            if k & 1:
                R = self.add(R, P)
            P = self.add(P, P)
            k >>= 1
        return R

    def on_curve(self, P):
        if P is None:
            return True
        x, y = P
        return (y * y - x * x * x - self.b) % self.p == 0

    def phi(self, P):
        """GLV automorphism (beta*x, y), beta^3 = 1 mod p."""
        if P is None:
            return None
        return (self.beta * P[0] % self.p, P[1])

    # -- factories --------------------------------------------------------
    @classmethod
    def from_record(cls, rec):
        return cls(rec["p"], rec["b"], rec["n"], rec["h"], rec["Gx"], rec["Gy"],
                   rec["lam"], rec["beta"], N=rec["N"], k=rec["k"])


def get_curve(bits):
    for rec in CURVES:
        if rec["k"] == bits:
            return Curve.from_record(rec)
    raise KeyError(f"no curve with bits={bits}")


def all_curves():
    return [Curve.from_record(rec) for rec in CURVES]


# ---------------------------------------------------------------------------
# Baseline 1: Baby-Step Giant-Step
# ---------------------------------------------------------------------------
def bsgs(curve, Q, rng=None):
    """BSGS for Q = d*G, d in [0, n). Returns (d, group_ops)."""
    n = curve.n
    G = curve.G
    m = 1
    while m * m < n:
        m += 1
    # baby steps: j*G for j in [0, m)
    table = {}
    P = None
    for j in range(m):
        if P is not None:
            table[P] = j
        P = curve.add(P, G)
    ops = m
    # giant step: -(m)*G
    neg_mG = curve.neg(curve.mul(m, G))
    R = Q
    for i in range(m):
        if R is not None and R in table:
            d = (i * m + table[R]) % n
            ops += i
            if curve.mul(d, G) == Q:
                return d, ops
        R = curve.add(R, neg_mG)
        ops += 1
    return None, ops


# ---------------------------------------------------------------------------
# Shared step-table construction (used by vanilla AND quotient walks so that
# all algorithms on the same instance see identical step points)
# ---------------------------------------------------------------------------
def make_step_table(curve, Q, W, rng):
    """W step points R_w = a_w*G + b_w*Q (a_w, b_w random in [1, n))."""
    n = curve.n
    G = curve.G
    table = []
    for _ in range(W):
        a = rng.randrange(1, n)
        b = rng.randrange(1, n)
        R = curve.add(curve.mul(a, G), curve.mul(b, Q))
        table.append((R, a, b))
    return table


# ---------------------------------------------------------------------------
# Baseline 2: vanilla Pollard's Rho (distinguished points)
# ---------------------------------------------------------------------------
def pollard_rho(curve, Q, dp_bits=14, W=256, rng=None, max_ops=None):
    """
    Vanilla Pollard rho with distinguished-point collision detection.

    Walk: X <- X + R_{w(X)} with w(X) = x(X) mod W.
    DP predicate: x(X) mod 2^dp_bits == 0.
    Collision X_i = X_j  =>  d = (a_i - a_j) / (b_j - b_i) mod n.

    Returns (d or None, group_ops).
    """
    if rng is None:
        rng = random.Random(0)
    n = curve.n
    if max_ops is None:
        max_ops = 1 << 40
    steps = make_step_table(curve, Q, W, rng)
    table = {}
    w0 = rng.randrange(W)
    (x, y), a, b = steps[w0]
    X = (x, y)
    ops = 0
    mask = (1 << dp_bits) - 1
    while ops < max_ops:
        w = int(X[0]) % W
        (Rx, Ry), ca, cb = steps[w]
        X = curve.add(X, (Rx, Ry))
        a = (a + ca) % n
        b = (b + cb) % n
        ops += 1
        if X is None:
            # a*G + b*Q = O  =>  d = -a/b
            if b != 0:
                d = (-a) * pow(b, -1, n) % n
                if curve.mul(d, curve.G) == Q:
                    return d, ops
            w = rng.randrange(W)
            X = steps[w][0]
            a, b = steps[w][1], steps[w][2]
            continue
        if (int(X[0]) & mask) == 0:
            if X in table:
                a0, b0 = table[X]
                num = (a0 - a) % n
                den = (b - b0) % n
                if den != 0:
                    d = num * pow(den, -1, n) % n
                    if curve.mul(d, curve.G) == Q:
                        return d, ops
            else:
                table[X] = (a, b)
    return None, ops


# ---------------------------------------------------------------------------
# ECDSA (corpus generation + verification)
# ---------------------------------------------------------------------------
def ecdsa_sign(curve, d, z, k, rng=None):
    """Sign hash z with nonce k. Returns (r, s)."""
    n = curve.n
    kG = curve.mul(k, curve.G)
    r = int(kG[0]) % n
    s = pow(k, -1, n) * (z + r * d) % n
    return r, s


def ecdsa_verify(curve, Q, z, r, s):
    n = curve.n
    w = pow(s, -1, n)
    u1, u2 = z * w % n, r * w % n
    P = curve.add(curve.mul(u1, curve.G), curve.mul(u2, Q))
    return P is not None and int(P[0]) % n == r


# ---------------------------------------------------------------------------
# Self-test: independently verify all frozen curve data (pure Python)
# ---------------------------------------------------------------------------
def self_test(curves=None):
    curves = curves or all_curves()
    for c in curves:
        assert c.on_curve(c.G), f"G not on curve k={c.k}"
        assert c.mul(c.n, c.G) is None, f"n*G != O k={c.k}"
        assert c.mul(c.N, c.G) is None, f"N*G != O k={c.k}"
        assert c.n * c.h == c.N, f"n*h != N k={c.k}"
        assert (c.lam * c.lam + c.lam + 1) % c.n == 0, f"lambda bad k={c.k}"
        assert c.lam % c.n != 1, f"lambda == 1 k={c.k}"
        # phi(G) = lam*G  (pure-Python check of the frozen eigenrelation)
        assert c.phi(c.G) == c.mul(c.lam, c.G), f"phi(G) != lam*G k={c.k}"
        assert pow(c.beta, 3, c.p) == 1 and c.beta % c.p != 1, f"beta bad k={c.k}"
        # ground-truth test vector
        d = None
        Q = None
        for rec in CURVES:
            if rec["k"] == c.k:
                d = rec["d"]
                Q = (rec["Qx"], rec["Qy"])
        assert c.mul(d, c.G) == (mpz(Q[0]), mpz(Q[1])), f"test vector bad k={c.k}"
        # verify a sample of the ECDSA corpus
        for rec in CURVES:
            if rec["k"] == c.k:
                for z, r, s in rec["sigs"][:4]:
                    assert ecdsa_verify(c, (mpz(Q[0]), mpz(Q[1])), z, r, s), \
                        f"sig invalid k={c.k}"
        # brute-force group order cross-check for the smallest curves
        if c.k <= 20:
            cnt = 1
            for x in range(c.p):
                rhs = (x * x * x + c.b) % c.p
                if rhs == 0:
                    cnt += 1
                elif pow(rhs, (c.p - 1) // 2, c.p) == 1:
                    cnt += 2
            assert cnt == c.N, f"brute-force count {cnt} != N {c.N} (k={c.k})"
    print(f"self-test OK: {len(curves)} curves verified")


if __name__ == "__main__":
    self_test()
