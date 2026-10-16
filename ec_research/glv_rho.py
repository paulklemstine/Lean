"""
glv_rho.py — Self-contained Vector-C research: GLV-class Pollard's Rho.

Goal (Hypothesis #001):
  On a j=0 curve y^2 = x^3 + b over F_p (p ~ 1 mod 3) admitting the GLV
  endomorphism phi(x,y)=(beta*x,y) with phi(P)=lambda*P and
  lambda^2+lambda+1 == 0 (mod n), the quotient walk over the equivalence
  classes { +/- P, +/- phi(P), +/- phi^2(P) } reduces the distinguished-point
  Pollard rho collision time from ~sqrt(pi*n/2) group ops to ~sqrt(pi*n/12)
  group ops, i.e. a factor of sqrt(6) ~ 2.45, AFTER paying the small cost
  of canonical-representative computation (6 candidate points, one scalar
  inversion only at DP storage / collision solve, none per step).

This file is intentionally self-contained (does not import curve_ladder) so
that it survives concurrent workspace churn.  It reuses the Shanks-Mestre
point-counting that was validated in the earlier (now clobbered) harness.
"""

from __future__ import annotations
import random, math, time, sys, os

# ---------------------------------------------------------------------------
# Elliptic curve arithmetic on E: y^2 = x^3 + b   over F_p   (j = 0)
# ---------------------------------------------------------------------------
class Curve:
    def __init__(self, p, b, n, G, lam, beta):
        self.p = p; self.b = b; self.n = n; self.G = G
        self.lam = lam; self.beta = beta
        self.b2 = beta * beta % p  # beta^2

    def add(self, P, Q):
        if P is None: return Q
        if Q is None: return P
        p = self.p
        x1, y1 = P; x2, y2 = Q
        if x1 == x2:
            if (y1 + y2) % p == 0:
                return None
            lam = (3 * x1 * x1) * pow(2 * y1, p - 2, p) % p
        else:
            lam = (y2 - y1) * pow(x2 - x1, p - 2, p) % p
        x3 = (lam * lam - x1 - x2) % p
        y3 = (lam * (x1 - x3) - y1) % p
        return (x3, y3)

    def neg(self, P):
        if P is None: return None
        return (P[0], self.p - P[1])

    def mul(self, k, P):
        k = int(k)
        n = self.n
        if n and n > 1:
            k %= n
        R = None
        while k:
            if k & 1: R = self.add(R, P)
            P = self.add(P, P)
            k >>= 1
        return R

    def phi(self, P):       # endomorphism  phi(x,y) = (beta*x, y)
        if P is None: return None
        return (self.beta * P[0] % self.p, P[1])

    def phi2(self, P):
        if P is None: return None
        return (self.b2 * P[0] % self.p, P[1])

    def on_curve(self, P):
        if P is None: return True
        x, y = P
        return (y * y - x * x * x - self.b) % self.p == 0


# ---------------------------------------------------------------------------
# Field helpers
# ---------------------------------------------------------------------------
def is_prime(n):
    if n < 2: return False
    for sp in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % sp == 0: return n == sp
    d = n - 1; r = 0
    while d % 2 == 0: d //= 2; r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x == 1 or x == n - 1: continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1: break
        else: return False
    return True

def _modsqrt(a, p):
    a %= p
    if a == 0: return 0
    if pow(a, (p - 1) // 2, p) != 1: return None
    if p % 4 == 3: return pow(a, (p + 1) // 4, p)
    Q = p - 1; S = 0
    while Q % 2 == 0: Q //= 2; S += 1
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1: z += 1
    M = S; c = pow(z, Q, p); t = pow(a, Q, p); R = pow(a, (Q + 1) // 2, p)
    while True:
        if t == 1: return R
        i = 1; temp = t * t % p
        while temp != 1: temp = temp * temp % p; i += 1
        b = c
        for _ in range(M - i - 1): b = b * b % p
        M = i; c = b * b % p; t = t * c % p; R = R * b % p

def _random_point(C, rng):
    while True:
        x = rng.randrange(C.p)
        rhs = (x * x * x + C.b) % C.p
        y = _modsqrt(rhs, C.p)
        if y is not None:
            return (x, y)

def _factor_int(n):
    f = {}
    d = 2
    while d * d <= n:
        while n % d == 0: f[d] = f.get(d, 0) + 1; n //= d
        d += 1
    if n > 1: f[n] = f.get(n, 0) + 1
    return f

def shanks_mestre_order(C, rng, verify=6):
    p = C.p
    w = 2 * math.isqrt(p) + 2
    m = math.isqrt(w) + 1
    for _ in range(30):
        P = _random_point(C, rng)
        Qp = C.mul(p + 1, P)
        baby = {}
        cur = None
        for j in range(m + 1):
            baby[None if cur is None else cur] = j
            cur = C.add(cur, P)
        mP = C.mul(m, P)
        m2P = C.mul(m, mP)
        neg_mP = C.neg(mP)
        giant = C.add(Qp, m2P)
        delta = None
        for i in range(-m, m + 1):
            if giant in baby:
                delta = (baby[giant] + i * m); break
            giant = C.add(giant, neg_mP)
        if delta is None: continue
        n = p + 1 - delta
        if n < 2: continue
        ok = True
        for _ in range(verify):
            R = _random_point(C, rng)
            if C.mul(n, R) is not None: ok = False; break
        if ok: return n
    raise RuntimeError("Shanks-Mestre failed")

def find_generator(C, n, rng):
    fac = _factor_int(n)
    primes = list(fac.keys())
    for _ in range(200):
        P = _random_point(C, rng)
        if C.mul(n, P) is not None: continue
        good = True
        for q in primes:
            if C.mul(n // q, P) is None:
                good = False; break
        if good: return P
    raise RuntimeError("no generator")

def find_gen_order(C, n, N, rng):
    """Find point of exact prime order n: random P, accept if n*P==O and P!=O."""
    p = C.p
    for _ in range(2000):
        P = _random_point(C, rng)
        if P is None: continue
        if _mul_pt(p, n, P) is not None: continue
        return P
    return None

def _mul_pt(p, k, P):
    """Double-and-add over F_p; k can be huge; uses _add_pt."""
    R = None
    base = P
    kk = k
    while kk:
        if kk & 1:
            R = _add_pt(p, R, base)
        base = _add_pt(p, base, base)
        kk >>= 1
    return R

def _cuberoot_mod_p(p):
    """Primitive cube root of unity mod p (p ~ 1 mod 3)."""
    # find an element of order 3: try random g
    rng = random.Random(1)
    for _ in range(100):
        g = rng.randrange(2, p)
        # beta = g^((p-1)/3) should be a nontrivial cube root
        beta = pow(g, (p - 1) // 3, p)
        if beta != 1 and beta * beta % p != 1 or (beta != 1 and pow(beta, 3, p) == 1 and beta != 1):
            if pow(beta, 3, p) == 1 and beta != 1:
                return beta
    # fallback: explicit search
    for g in range(2, p):
        beta = pow(g, (p - 1) // 3, p)
        if beta != 1 and pow(beta, 3, p) == 1:
            return beta
    raise RuntimeError("cuberoot not found")

def _cuberoot_mod_n(n):
    """Primitive cube root of unity mod n (n ~ 1 mod 3): lambda with lambda^2+lambda+1==0."""
    # lambda = (-1 + sqrt(-3))/2 mod n
    # try random
    rng = random.Random(2)
    for _ in range(200):
        g = rng.randrange(2, n)
        # use Tonelli-Shanks-like for sqrt(-3) mod n (n prime)
        # n must be prime
        # sqrt(-3) exists if (-3)^((n-1)/2) == 1 mod n
        if pow(n - 3, (n - 1) // 2, n) != 1:
            return None
        s = _modsqrt(n - 3, n)
        if s is None: return None
        lam = (s - 1) * pow(2, -1, n) % n
        if (lam * lam + lam + 1) % n == 0:
            return lam
    return None

# ---------------------------------------------------------------------------
# Generate a GLV (j=0) curve of ~bits size with verified endomorphism.
# ---------------------------------------------------------------------------
def build_glv_curve(bits, seed=0):
    rng = random.Random(seed)
    attempts = 0
    while True:
        attempts += 1
        # p ~ 1 mod 3
        p = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        # ensure p ~ 1 mod 3
        while p % 3 != 1:
            p += 2
            if p.bit_length() > bits:
                p = (rng.getrandbits(bits) | (1 << (bits - 1))) | 1
                # adjust
        if not is_prime(p): continue
        beta = _cuberoot_mod_p(p)
        # try b=1..small
        b = None
        for bb in range(1, 200):
            # nonsingular: 27*b^2 != 0 (true) and need curve nonsingular (discriminant -2^4*3^3*b^2 != 0, fine)
            pass
        # pick random b
        for _ in range(50):
            bb = rng.randrange(1, p)
            # check curve has prime order ~ 1 mod 3
            C_tmp = None
            cur = None
            # build a throwaway curve object not needed; use temp
            # We'll compute order via Shanks-Mestre on a temp curve
            class _C:
                pass
            tc = _C()
            tc.p = p; tc.b = bb
            tc.add = lambda self, P, Q: _add_pt(p, P, Q)
            tc.mul = lambda self, k, P: _mul_pt(p, k, P)
            # simpler: use module-level functions
            # Use a proper Curve without n/G
            tc2 = Curve(p, bb, 0, None, 0, beta)  # n placeholder
            # but Curve.mul needs tc2.n ; set n large
            tc2.n = 0
            N = None
            try:
                N = shanks_mestre_order(tc2, rng)
            except RuntimeError:
                continue
            fac = _factor_int(N)
            n = None
            for prime in sorted(fac.keys(), reverse=True):
                if prime % 3 == 1 and prime > 100:
                    n = prime; break
            if n is None:
                for prime in sorted(fac.keys(), reverse=True):
                    if prime > 100: n = prime; break
            if n is None: continue
            if n < (1 << (bits - 3)): continue
            lam = _cuberoot_mod_n(n)
            if lam is None: continue
            G = find_gen_order(tc2, n, N, rng)
            if G is None: continue
            # verify phi(G) == lam*G
            phiG = (beta * G[0] % p, G[1])
            lamG = _mul_pt(p, lam, G)
            if phiG != lamG:
                continue
            # success
            C = Curve(p, bb, n, G, lam, beta)
            return C
        if attempts > 5000:
            raise RuntimeError(f"failed to build GLV curve at {bits} bits")

def _add_pt(p, P, Q):
    if P is None: return Q
    if Q is None: return P
    x1, y1 = P; x2, y2 = Q
    if x1 == x2:
        if (y1 + y2) % p == 0: return None
        lam = (3 * x1 * x1) * pow(2 * y1, p - 2, p) % p
    else:
        lam = (y2 - y1) * pow(x2 - x1, p - 2, p) % p
    x3 = (lam * lam - x1 - x2) % p
    y3 = (lam * (x1 - x3) - y1) % p
    return (x3, y3)

# (duplicate _mul_pt removed; use the (p, k, P) version above)

# patch Curve.mul to use the arithmetic (it already does). OK.

# ---------------------------------------------------------------------------
# Solvers
# ---------------------------------------------------------------------------
def make_step_table(curve, Q, W, rng):
    n = curve.n
    G = curve.G
    table = []
    for _ in range(W):
        a = rng.randrange(1, n); bj = rng.randrange(1, n)
        R = curve.add(curve.mul(a, G), curve.mul(bj, Q))
        table.append((R, a, bj))
    return table

def bsgs(curve, Q, rng=None):
    rng = rng or random.Random(0)
    n = curve.n; G = curve.G
    m = 1
    while m * m < n: m += 1
    table = {}
    P = None
    for j in range(m):
        if P is not None: table[P] = j
        P = curve.add(P, G)
    ops = m
    mG = curve.mul(m, G); neg_mG = curve.neg(mG)
    R = Q
    for i in range(m):
        if R is not None and R in table:
            d = (i * m + table[R]) % n
            ops += i
            if curve.mul(d, G) == Q: return d, ops
        R = curve.add(R, neg_mG); ops += 1
    return None, ops

def _try_collisions(curve, Q, entries):
    """Given a list of (point, a, b) distinguished collisions, try to solve d."""
    n = curve.n; G = curve.G
    lam = curve.lam
    lam2 = (lam * lam) % n
    # powers: lam^0=1, lam^1=lam, lam^2
    pows = [1, lam, lam2]
    for (X, a, b, jprev, sprev) in entries:
        pass
    return None

def pollard_rho(curve, Q, dp_bits=12, W=256, rng=None, max_ops=None, variant='vanilla'):
    """
    Birthday-hashing Pollard rho on distinguished points with quotient grouping.

    Stores EVERY visited distinguished point (no dp thresholding) in a hash table
    keyed on canon_key(X):
      'vanilla' : canon_key = (x, y)            (full point)            -> N = n
      'neg'     : canon_key = x                  (P ~ -P)              -> N = n/2
      'glv'     : canon_key = min eq-class rep   (6-point GLV class)    -> N = n/6

    Expected group ops (collision time) ~ sqrt(pi*N/2) (birthdays).
    On a hash collision, the transformation(s) for the variant are tried to
    solve d, and verified against Q before returning.
    """
    rng = rng or random.Random(0)
    n = curve.n; G = curve.G
    if max_ops is None:
        max_ops = 1 << 60
    steps = make_step_table(curve, Q, W, rng)
    table = {}
    w0 = rng.randrange(W)
    (x, y), a0, b0 = steps[w0]
    X = (x, y); a = a0; b = b0
    ops = 0

    def canon_key(P):
        if variant == 'vanilla':
            return (P[0], P[1])
        if variant == 'neg':
            return P[0]
        pts = []
        for pp in (P, curve.phi(P), curve.phi2(P)):
            pts.append(pp); pts.append((pp[0], (-pp[1]) % curve.p))
        return min(pts)

    # transformations P_current = s*phi^j(P_stored) allowed by the variant
    if variant == 'vanilla':
        transforms = [(1, 1)]
    elif variant == 'neg':
        transforms = [(1, 1), (-1, 1)]
    else:
        _p = [1, curve.lam % n, (curve.lam * curve.lam) % n]
        transforms = [(s, pj) for s in (1, -1) for pj in _p]

    def try_solve(ast2, bst2):
        for (s, pj) in transforms:
            denom = (s * pj * bst2 - b) % n
            if denom == 0:
                continue
            num = (a - s * pj * ast2) % n
            d = num * pow(denom, -1, n) % n
            if curve.mul(d, G) == Q:
                return d
        return None

    while ops < max_ops:
        w = X[0] % W
        entry = steps[w]
        if entry[0] is None:
            ops += 1
            continue
        (Rx, Ry), ca, cb = entry
        X = curve.add(X, (Rx, Ry))
        a = (a + ca) % n
        b = (b + cb) % n
        ops += 1
        if X is None:
            if b != 0:
                d = (-a) * pow(b, -1, n) % n
                if curve.mul(d, G) == Q:
                    return d, ops
            # sample a non-None starting point
            w0 = rng.randrange(W)
            while True:
                (x, y), a0, b0 = steps[w0]
                if (x, y) is not None:
                    break
                w0 = rng.randrange(W)
            X = (x, y); a = a0; b = b0
            continue
        key = canon_key(X)
        if key in table:
            sol = try_solve(*table[key])
            if sol is not None:
                return sol, ops
        else:
            table[key] = (a, b)
    return None, ops


# ---------------------------------------------------------------------------
# GLV curve generation with caching
# ---------------------------------------------------------------------------
def gen_curves(bits_list, seeds=(0,1,2)):
    out = {}
    for bits in bits_list:
        for s in seeds:
            try:
                C = build_glv_curve(bits, seed=1000*bits + s)
                out.setdefault(bits, []).append(C)
                print(f"  built GLV curve bits={bits} seed={s}: p={C.p} n={C.n}")
                break
            except Exception as e:
                print(f"  seed {s} bits {bits} failed: {e}")
                continue
    return out

# ---------------------------------------------------------------------------
# Experiment
# ---------------------------------------------------------------------------
def run_experiment(bits_list, instances=5, max_ops_scale=4.0):
    curves = gen_curves(bits_list)
    print("\n=== EXPERIMENT: Pollard Rho variants on GLV j=0 curves ===")
    for bits in bits_list:
        if bits not in curves or not curves[bits]:
            print(f"  no curve for {bits} bits, skipping")
            continue
        C = curves[bits][0]
        n = C.n
        results = {'vanilla': [], 'neg': [], 'glv': []}
        max_ops = int(max_ops_scale * math.sqrt(n)) + 100
        dp = max(2, min(10, n.bit_length() - 12))
        print(f"\n--- {bits} bit (n={n}, dp_bits={dp}, max_ops={max_ops}) ---")
        for inst in range(instances):
            rng = random.Random(9999 + inst)
            d = rng.randrange(1, n)
            Q = C.mul(d, C.G)
            for variant in ('vanilla', 'neg', 'glv'):
                rrng = random.Random(55555 + inst*3 + 'vanilla neg glv'.split().index(variant))
                dret, ops = pollard_rho(C, Q, dp_bits=dp, W=64, rng=rrng, max_ops=max_ops, variant=variant)
                ok = (dret == d)
                results[variant].append((ops, ok))
            line = "  inst %2d: " % inst + "  ".join(
                "v=%-8d%s" % (o, 'OK' if k else 'FAIL') for (o,k) in [results['vanilla'][-1]] ) + " | " + "  ".join(
                "n=%-8d%s" % (o, 'OK' if k else 'FAIL') for (o,k) in [results['neg'][-1]] ) + " | " + "  ".join(
                "g=%-8d%s" % (o, 'OK' if k else 'FAIL') for (o,k) in [results['glv'][-1]] )
            print(line)
        # summary
        for variant in ('vanilla', 'neg', 'glv'):
            oks = [1 for o,k in results[variant] if k]
            mean = sum(o for o,k in results[variant]) / len(results[variant])
            print(f"  {variant:8s}: success={sum(oks)}/{len(oks)}  mean_ops={mean:.0f}")

if __name__ == '__main__':
    bits = [16, 20, 24]
    if len(sys.argv) > 1:
        bits = [int(x) for x in sys.argv[1].split(',')]
    run_experiment(bits, instances=4)
