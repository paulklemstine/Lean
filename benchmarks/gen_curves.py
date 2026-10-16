#!/usr/bin/env python3
"""
One-time generation of the ECDLP/ECDSA benchmark curve ladder.

For each bit-size k in [16..64], constructs a j-invariant-0 curve
    E : y^2 = x^3 + b  over F_p,  p ≡ 1 (mod 3)
with a prime-order subgroup <G> of order n satisfying:
    - n >= 2^(k-6)          (full-scale DLP for the bit-size)
    - n ≡ 1 (mod 3)        (GLV endomorphism phi(G) = λG exists: λ^2+λ+1≡0 mod n)
    - cofactor h = #E/n <= 256
    - x(G) != 0            (phi acts non-trivially on <G>)

Point counting via PARI/GP (Schoof/SEA) through cypari2; factorization via sympy.
Output: benchmarks/_curve_data.py with frozen literals.
"""
import random
import sympy
from cypari2 import Pari

pari = Pari()
SEED = 20261015
KS = [16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64]
MAX_H = 2**8


def random_kbit_prime_1mod3(rng, k):
    while True:
        p = rng.randrange(1 << (k - 1), 1 << k) | 1
        if p % 3 == 1 and pari.isprime(p):
            return p


def cube_root_of_unity_mod_p(rng, p):
    """Return beta != 1 with beta^3 = 1 mod p (requires p = 1 mod 3)."""
    while True:
        beta = pow(rng.randrange(2, p - 1), (p - 1) // 3, p)
        if beta != 1:
            return beta


def cube_root_of_unity_mod_n(rng, n):
    """Return lam != 1 with lam^2 + lam + 1 = 0 mod n (requires n = 1 mod 3)."""
    while True:
        lam = pow(rng.randrange(2, n - 1), (n - 1) // 3, n)
        if lam != 1 and (lam * lam + lam + 1) % n == 0:
            return lam


def curve_order(p, b):
    E = pari.ellinit([0, 0, 0, 0, pari.Mod(b, p)], p)
    return int(pari.ellcard(E))


def find_generator(p, b, N, n, h):
    """Find G in E(F_p) with order exactly n: take random point R, G = h*R."""
    rng = random.Random((SEED * 31 + p) & 0xFFFFFFFF)
    while True:
        x = rng.randrange(0, p)
        rhs = (x * x * x + b) % p
        if rhs == 0:
            return (x, 0)
        y = pow(rhs, (p + 1) // 4, p) if p % 4 == 3 else None
        if y is None or (y * y) % p != rhs:
            # general Tonelli-Shanks fallback
            y = tonelli_shanks(rhs, p)
            if y is None:
                continue
        E = pari.ellinit([0, 0, 0, 0, pari.Mod(b, p)], p)
        R = pari.Mod(x, p), pari.Mod(y, p)
        G = pari.ellmul(E, R, h)
        if G != 0 and pari.ellorder(E, G) == n:
            return (int(G[0]), int(G[1]))


def tonelli_shanks(a, p):
    if pow(a, (p - 1) // 2, p) != 1:
        return None
    q, s = p - 1, 0
    while q % 2 == 0:
        q //= 2
        s += 1
    if s == 1:
        return pow(a, (p + 1) // 4, p)
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1
    m = s
    c = pow(z, q, p)
    t = pow(a, q, p)
    r = pow(a, (q + 1) // 2, p)
    while t != 1:
        i, t2 = 0, t
        while t2 != 1:
            t2 = (t2 * t2) % p
            i += 1
        b = pow(c, 1 << (m - i - 1), p)
        m = i
        c = (b * b) % p
        t = (t * c) % p
        r = (r * b) % p
    return r


def gen_curve(k):
    rng = random.Random(f"{SEED}-{k}")
    attempts = 0
    while True:
        attempts += 1
        p = random_kbit_prime_1mod3(rng, k)
        b = rng.randrange(2, p - 1)
        N = curve_order(p, b)
        fac = sympy.factorint(N)
        best = None
        for q, e in fac.items():
            if q % 3 == 1 and q >= (1 << (k - 6)) and N // q <= MAX_H:
                if best is None or q > best:
                    best = q
        if best is None:
            continue
        n = best
        h = N // n
        Gx, Gy = find_generator(p, b, N, n, h)
        if Gx == 0:
            continue
        lam = cube_root_of_unity_mod_n(rng, n)
        beta = cube_root_of_unity_mod_p(rng, p)
        # verify phi(G) = lam*G or lam^2*G  (PARI)
        E = pari.ellinit([0, 0, 0, 0, pari.Mod(b, p)], p)
        G = (pari.Mod(Gx, p), pari.Mod(Gy, p))
        phiG = (pari.Mod(int(beta) * Gx, p), pari.Mod(Gy, p))
        lamG = pari.ellmul(E, G, lam)
        lam2G = pari.ellmul(E, G, (lam * lam) % n)
        if phiG == lamG:
            lam_used = lam
        elif phiG == lam2G:
            lam_used = (lam * lam) % n
        else:
            raise RuntimeError(f"phi(G) not an eigenpoint?! k={k}")
        # ECDSA corpus: one key d, 64 signatures with random nonces
        d = rng.randrange(2, n - 1)
        Q = pari.ellmul(E, G, d)
        sigs = []
        for _ in range(64):
            z = rng.randrange(1, n)
            kk = rng.randrange(1, n - 1)
            kG = pari.ellmul(E, G, kk)
            r = int(kG[0]) % n
            s = int(pow(kk, -1, n) * (z + r * d) % n)
            sigs.append((z, r, s))
        assert all(0 < r < n and 0 < s < n for _, r, s in sigs)
        return dict(k=k, p=p, b=b, N=N, n=n, h=h, Gx=Gx, Gy=Gy,
                    lam=int(lam_used), beta=beta, d=d,
                    Qx=int(Q[0]), Qy=int(Q[1]), sigs=sigs,
                    gen_attempts=attempts)


def main():
    curves = []
    for k in KS:
        c = gen_curve(k)
        curves.append(c)
        print(f"k={k}: p={c['p']} N={c['N']} n={c['n']} h={c['h']} "
              f"attempts={c['gen_attempts']}")
    with open("/home/raver1975/lean/benchmarks/_curve_data.py", "w") as f:
        f.write('"""Auto-generated by gen_curves.py (PARI Schoof + sympy factor)."""\n')
        f.write("CURVES = [\n")
        for c in curves:
            f.write(f"    {c!r},\n")
        f.write("]\n")
    print("wrote benchmarks/_curve_data.py")


if __name__ == "__main__":
    main()
