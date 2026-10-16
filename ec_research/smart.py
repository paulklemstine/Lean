from __future__ import annotations
import random, math, time, sys

sys.path.insert(0, '/home/raver1975/lean/ec_research')


def _is_prime(n):
    if n < 2:
        return False
    for sp in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % sp == 0:
            return n == sp
    d = n - 1; r = 0
    while d % 2 == 0:
        d //= 2; r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
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


def modinv(a, m):
    return pow(a % m, -1, m)


def ec_add_fp(P, Q, a, b, p):
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P; x2, y2 = Q
    if x1 == x2:
        if (y1 + y2) % p == 0:
            return None
        lam = (3 * x1 * x1 + a) * modinv(2 * y1, p) % p
    else:
        lam = (y2 - y1) * modinv(x2 - x1, p) % p
    x3 = (lam * lam - x1 - x2) % p
    y3 = (lam * (x1 - x3) - y1) % p
    return (x3, y3)


def ec_mul_fp(k, P, a, b, p):
    k = int(k)
    R = None
    base = P
    while k:
        if k & 1:
            R = ec_add_fp(R, base, a, b, p)
        base = ec_add_fp(base, base, a, b, p)
        k >>= 1
    return R


def legendre(x, p):
    x %= p
    if x == 0:
        return 0
    lr = pow(x, (p - 1) // 2, p)
    if lr == p - 1:
        return -1
    return 1


def count_points(a, b, p):
    total = 1
    for x in range(p):
        rhs = (x * x * x + a * x + b) % p
        if rhs == 0:
            total += 1
        elif legendre(rhs, p) == 1:
            total += 2
    return total


def random_prime(rng, bits):
    while True:
        p = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if p % 2 == 0:
            p += 1
        if _is_prime(p):
            return p


def vp_int(x, p):
    if x == 0:
        return 10**9
    v = 0
    ax = abs(x)
    while ax % p == 0:
        ax //= p
        v += 1
    return v


# ================= p-adic numbers =================
class Padic:
    def __init__(self, p, prec, val, unit):
        self.p = p
        self.prec = prec
        self.mod = p ** prec
        if val is None:
            self.val = None
            self.unit = 0
        else:
            self.val = int(val)
            self.unit = unit % self.mod

    @staticmethod
    def zero(p, prec):
        return Padic(p, prec, None, 0)

    @staticmethod
    def from_int(x, p, prec):
        if x == 0:
            return Padic.zero(p, prec)
        v = vp_int(x, p)
        mod = p ** prec
        # exact division
        q = x // (p ** v)
        return Padic(p, prec, v, q % mod)

    def is_zero(self):
        return self.val is None

    def approx_zero(self):
        # valuation >= prec means congruent 0 mod p^prec
        return self.val is None or (self.val is not None and self.val >= self.prec)

    def neg(self):
        if self.is_zero():
            return self
        return Padic(self.p, self.prec, self.val, (-self.unit) % self.mod)

    def add(self, other):
        if not isinstance(other, Padic):
            other = Padic.from_int(other, self.p, self.prec)
        if self.is_zero():
            return Padic(self.p, self.prec, other.val, other.unit)
        if other.is_zero():
            return Padic(self.p, self.prec, self.val, self.unit)
        vmin = min(self.val, other.val)
        mod = self.mod
        # terms
        shift_s = self.val - vmin
        if shift_s >= self.prec:
            term_s = 0
        else:
            term_s = (self.unit * pow(self.p, shift_s, mod)) % mod
        shift_o = other.val - vmin
        if shift_o >= self.prec:
            term_o = 0
        else:
            term_o = (other.unit * pow(self.p, shift_o, mod)) % mod
        s = (term_s + term_o) % mod
        if s == 0:
            return Padic.zero(self.p, self.prec)
        r = vp_int(s, self.p)
        if r >= self.prec:
            return Padic.zero(self.p, self.prec)
        unit = (s // (self.p ** r)) % mod
        return Padic(self.p, self.prec, vmin + r, unit)

    def mul(self, other):
        if not isinstance(other, Padic):
            other = Padic.from_int(other, self.p, self.prec)
        if self.is_zero() or other.is_zero():
            return Padic.zero(self.p, self.prec)
        val = self.val + other.val
        unit = (self.unit * other.unit) % self.mod
        return Padic(self.p, self.prec, val, unit)

    def div(self, other):
        if not isinstance(other, Padic):
            other = Padic.from_int(other, self.p, self.prec)
        if other.is_zero():
            raise ZeroDivisionError("padic division by zero")
        if self.is_zero():
            return Padic.zero(self.p, self.prec)
        inv = pow(other.unit, -1, self.mod)
        val = self.val - other.val
        unit = (self.unit * inv) % self.mod
        return Padic(self.p, self.prec, val, unit)

    def eq_approx(self, other):
        # equality modulo p^prec
        if not isinstance(other, Padic):
            other = Padic.from_int(other, self.p, self.prec)
        diff = self.add(other.neg())
        return diff.approx_zero()


# ================= p-adic EC =================
def _P(x):
    return x  # identity passthrough for Padic


def ec_add_padic(P, Q, a_int, p, prec):
    if P is None:
        return Q
    if Q is None:
        return P
    x1, y1 = P; x2, y2 = Q
    # convert ints to Padic
    if not isinstance(x1, Padic):
        x1 = Padic.from_int(x1, p, prec)
    if not isinstance(y1, Padic):
        y1 = Padic.from_int(y1, p, prec)
    if not isinstance(x2, Padic):
        x2 = Padic.from_int(x2, p, prec)
    if not isinstance(y2, Padic):
        y2 = Padic.from_int(y2, p, prec)
    aP = Padic.from_int(a_int, p, prec)
    zero = Padic.zero(p, prec)
    one = Padic.from_int(1, p, prec)
    two = Padic.from_int(2, p, prec)
    three = Padic.from_int(3, p, prec)

    # check x equality
    if x1.eq_approx(x2):
        if (y1.add(y2)).approx_zero():
            return None  # negation -> identity (point at infinity)
        # doubling
        num = three.mul(x1).mul(x1).add(aP)
        den = two.mul(y1)
        lam = num.div(den)
    else:
        lam = (y2.add(y1.neg())).div(x2.add(x1.neg()))
    x3 = lam.mul(lam).add(x1.neg()).add(x2.neg())
    y3 = lam.mul(x1.add(x3.neg())).add(y1.neg())
    return (x3, y3)


def ec_mul_padic(k, P, a_int, p, prec):
    R = None
    base = P
    kk = int(k)
    while kk:
        if kk & 1:
            R = ec_add_padic(R, base, a_int, p, prec)
        base = ec_add_padic(base, base, a_int, p, prec)
        kk >>= 1
    return R


def hensel_sqrt(f_int, y0, p, n):
    r = y0 % p
    for step in range(1, n):
        mod = p ** (step + 1)
        fval = (r * r - f_int) % mod
        deriv = (2 * r) % mod
        inv_deriv = pow(deriv, -1, mod)
        r = (r - fval * inv_deriv) % mod
    return r


def _modsqrt(a, p):
    a %= p
    if a == 0:
        return 0
    if pow(a, (p - 1) // 2, p) != 1:
        return None
    if p % 4 == 3:
        return pow(a, (p + 1) // 4, p)
    Qv = p - 1; S = 0
    while Qv % 2 == 0:
        Qv //= 2; S += 1
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1
    M = S; c = pow(z, Qv, p); t = pow(a, Qv, p); R = pow(a, (Qv + 1) // 2, p)
    while True:
        if t == 1:
            return R
        i = 1; temp = t * t % p
        while temp != 1:
            temp = temp * temp % p; i += 1
        b = c
        for _ in range(M - i - 1):
            b = b * b % p
        M = i; c = b * b % p; t = t * c % p; R = R * b % p


# ---- curve generation ----
def gen_point_on_fp(a, b, p, rng):
    while True:
        x = rng.randrange(p)
        rhs = (x * x * x + a * x + b) % p
        if rhs == 0:
            return (x, 0)
        if legendre(rhs, p) == 1:
            y = _modsqrt(rhs, p)
            if y is not None:
                if rng.randrange(2):
                    y = p - y
                return (x, y)


def legendre(x, p):
    x %= p
    if x == 0:
        return 0
    lr = pow(x, (p - 1) // 2, p)
    if lr == p - 1:
        return -1
    return 1


def count_points(a, b, p):
    total = 1
    for x in range(p):
        rhs = (x * x * x + a * x + b) % p
        if rhs == 0:
            total += 1
        elif legendre(rhs, p) == 1:
            total += 2
    return total


def random_prime(rng, bits):
    while True:
        p = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if p % 2 == 0:
            p += 1
        if _is_prime(p):
            return p


def find_gen_fp(a, b, p, rng):
    for _ in range(1000):
        # inline gen_point
        while True:
            x = rng.randrange(p)
            rhs = (x * x * x + a * x + b) % p
            if rhs == 0:
                P = (x, 0); break
            if legendre(rhs, p) == 1:
                y = _modsqrt(rhs, p)
                if y is not None:
                    if rng.randrange(2):
                        y = p - y
                    P = (x, y); break
            else:
                continue
        if ec_mul_fp(p, P, a, b, p) is None:
            return P
    raise RuntimeError("no generator found")


def gen_anomalous(bits, rng, max_curve_tries=200000):
    attempts = 0
    while attempts < max_curve_tries:
        attempts += 1
        p = random_prime(rng, bits)
        is_qr = bytearray(p)
        for r in range(1, p):
            is_qr[(r * r) % p] = 1
        for _ in range(80):
            a = rng.randrange(p)
            b = rng.randrange(p)
            if (4 * a * a * a + 27 * b * b) % p == 0:
                continue
            total = 1
            for x in range(p):
                rhs = (x * x * x + a * x + b) % p
                if rhs == 0:
                    total += 1
                elif is_qr[rhs]:
                    total += 2
            if total == p:
                G = find_gen_fp(a, b, p, rng)
                return p, a, b, G
    raise RuntimeError(f"failed to find anomalous curve at {bits} bits after {attempts} primes")


def smart_phi_full(a, b, p, Pt, n_prec):
    x0 = int(Pt[0]) % p
    y0 = int(Pt[1]) % p
    Fint = x0**3 + a * x0 + b
    ylift = hensel_sqrt(Fint, y0, p, n_prec)
    prec = n_prec
    xpadic = Padic.from_int(x0, p, prec)
    ypadic = Padic.from_int(ylift, p, prec)
    Ppadic = (xpadic, ypadic)
    R = ec_mul_padic(p, Ppadic, a, p, prec)
    if R is None:
        raise RuntimeError("p*lift is None (infinity)")
    X, Y = R
    # t = -X / Y
    negX = X.neg() if hasattr(X, 'neg') else Padic(p, prec, X.val, (-X.unit) % X.mod)
    t = negX.div(Y)
    v = t.val if t.val is not None else 10**9
    if v is None or v < 1:
        raise RuntimeError(f"unexpected valuation {v} for t")
    # divide by p
    pP = Padic.from_int(p, p, prec)
    u = t.div(pP)
    if u.val != 0:
        raise RuntimeError(f"u not unit (valuation {u.val}) (v={v})")
    phi = u.unit % p
    return phi, v


def bsgs_ecdlp(G, Q, a, b, p):
    m = math.isqrt(p) + 1
    table = {}
    P = None
    for j in range(m):
        table.setdefault(P, j)
        P = ec_add_fp(P, G, a, b, p)
    mG = ec_mul_fp(m, G, a, b, p)
    neg_mG = (mG[0], p - mG[1]) if mG is not None else None
    R = Q
    for i in range(m):
        if R in table:
            d = (i * m + table[R]) % p
            if ec_mul_fp(d, G, a, b, p) == Q:
                return d, i
        R = ec_add_fp(R, neg_mG, a, b, p)
    return None, m


def run_one(bits, rng, n_prec=5, trials=1):
    results = []
    for t in range(trials):
        t0 = time.time()
        p, a, b, G = gen_anomalous(bits, rng)
        gentime = time.time() - t0
        d_true = rng.randrange(1, p)
        Q = ec_mul_fp(d_true, G, a, b, p)
        ts = time.time()
        failure = None
        d_rec = None
        vG = vQ = None
        try:
            phi_G, vG = smart_phi_full(a, b, p, G, n_prec)
            phi_Q, vQ = smart_phi_full(a, b, p, Q, n_prec)
            if phi_G % p == 0:
                raise RuntimeError("phi(G)==0")
            d_rec = (phi_Q * modinv(phi_G, p)) % p
            if not (ec_mul_fp(d_rec, G, a, b, p) == Q):
                failure = "verification dG != Q"
        except Exception as e:
            failure = f"exception: {e}"
        smart_time = time.time() - ts
        tb = time.time()
        d_bsgs, _ = bsgs_ecdlp(G, Q, a, b, p)
        bsgs_time = time.time() - tb
        bsgs_ok = (d_bsgs is not None and ec_mul_fp(d_bsgs, G, a, b, p) == Q)
        smart_ok = (failure is None and d_rec is not None and ec_mul_fp(d_rec, G, a, b, p) == Q)
        results.append({
            "bits": bits, "p": p, "a": a, "b": b, "d_true": d_true,
            "d_rec": d_rec, "smart_ok": smart_ok, "smart_fail": failure,
            "smart_time": smart_time, "bsgs_d": d_bsgs, "bsgs_ok": bsgs_ok,
            "bsgs_time": bsgs_time, "gen_time": gentime,
            "vG": vG, "vQ": vQ,
        })
        print(f"[bits={bits}] trial {t}: p={p} smart_ok={smart_ok} "
              f"smart_time={smart_time:.4f}s fail={failure} bsgs_time={bsgs_time:.4f}s "
              f"bsgs_ok={bsgs_ok} gen={gentime:.2f}s valG={vG} valQ={vQ}", flush=True)
    return results


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--bits", type=int, nargs="+", default=[12])
    ap.add_argument("--trials", type=int, default=1)
    ap.add_argument("--prec", type=int, default=5)
    args = ap.parse_args()
    rng = random.Random(20261016)
    allres = []
    for bits in args.bits:
        rs = run_one(bits, rng, trials=args.trials, n_prec=args.prec)
        allres.extend(rs)
    print("\n=== SUMMARY ===")
    for r in allres:
        print(r)
    with open('/home/raver1975/lean/ec_research/smart_results.txt', 'w') as f:
        for r in allres:
            f.write(repr(r) + "\n")


if __name__ == "__main__":
    main()
