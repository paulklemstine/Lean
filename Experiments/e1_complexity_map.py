#!/usr/bin/env python3
"""Experiment E-1: Empirical complexity map of classical integer factoring.

Scientific method protocol:
  Hypotheses:
    H1  Pollard-Brent rho runs in O(sqrt(p)) w.r.t. the smaller factor p
        -> ~N^(1/4) wall-clock exponent 0.25 on balanced semiprimes.
    H2  ECM (GMP-ECM) finds a factor p in L_p[1/2, sqrt(2)] — depends on the
        SIZE OF THE FACTOR, not the modulus.
    H3  Crossover rho->ECM lands near p ~ 2^40-2^50 where ECM's curve count
        beats rho's quadratic cost.
  Method: random semiprimes at controlled bit sizes, k trials each, median
  wall-clock; log-log regression of time vs p gives empirical exponents to
  compare against theory. Fixed seed for reproducibility.
"""
import gmpy2
import json
import statistics
import subprocess
import time
from gmpy2 import mpz, next_prime, is_prime, mpz_urandomb, powmod, gcd
import random

random.seed(20260826)
RNG = gmpy2.random_state(20260826)

# ── semiprime generation ──────────────────────────────────────────────
def gen_semiprime(total_bits, balance=0.5):
    """N = p*q with p,q ~ balance*total_bits and (1-balance)*total_bits bits."""
    pb = max(16, int(total_bits * balance))
    qb = max(16, total_bits - pb)
    p = next_prime(mpz_urandomb(RNG, pb) | (mpz(1) << (pb - 1)))
    q = next_prime(mpz_urandomb(RNG, qb) | (mpz(1) << (qb - 1)))
    return p * q, min(p, q)


# ── algorithm 1: Pollard rho with Brent improvements ──────────────────
def brent_rho(N, max_steps=None):
    """Returns a nontrivial factor of composite odd N."""
    N = mpz(N)
    if N % 2 == 0:
        return mpz(2)
    y = mpz(random.randrange(1, int(N)))
    c = mpz(random.randrange(1, int(N)))
    m = mpz(128)
    g = r = q = mpz(1)
    x = ys = mpz(0)
    steps = 0
    while g == 1:
        x = y
        for _ in range(r):
            y = (y * y + c) % N
        k = mpz(0)
        while k < r and g == 1:
            ys = y
            for _ in range(min(m, r - k)):
                y = (y * y + c) % N
                q = q * abs(x - y) % N
            g = gcd(q, N)
            k += m
        r <<= 1
        steps += 1
        if max_steps and steps > max_steps:
            return None
    if g == N:
        g = mpz(1)
        while g == 1:
            ys = (ys * ys + c) % N
            g = gcd(abs(x - ys), N)
    return g if g != N else None


# ── algorithm 2: Pollard p-1 stage 1 ──────────────────────────────────
def pollard_pm1(N, B1=100_000):
    N = mpz(N)
    a = mpz(2)
    for j in range(2, B1):
        a = powmod(a, j, N)
        if j % 5000 == 0:
            g = gcd(a - 1, N)
            if 1 < g < N:
                return g
    return gcd(a - 1, N) if gcd(a - 1, N) != N else None


# ── algorithm 3: GMP-ECM binary ───────────────────────────────────────
def gmp_ecm(N, B1, curves=10):
    """Shell out to /usr/bin/ecm; returns found factor or None."""
    try:
        proc = subprocess.run(
            ["ecm", "-c", str(curves), "-q", str(B1)],
            input=str(N), capture_output=True, text=True, timeout=120)
        out = proc.stdout.strip().splitlines()
        for line in out:
            for tok in line.split():   # -q prints factors space-separated on one line
                if tok.isdigit():
                    f = mpz(tok)
                    if 1 < f < N:
                        return f
    except (subprocess.TimeoutExpired, Exception):
        return None
    return None


# ── measurement ───────────────────────────────────────────────────────
def timed(fn, *a, **kw):
    t0 = time.perf_counter()
    r = fn(*a, **kw)
    return time.perf_counter() - t0, r


def run():
    results = []
    # Balanced semiprimes: rho regime (p ~ sqrt(N))
    print("== H1: Pollard-Brent rho, balanced semiprimes ==")
    for bits in (30, 36, 42, 48, 54, 60, 66):
        times, ps = [], []
        for _ in range(5):
            N, p = gen_semiprime(bits, balance=0.5)
            dt, f = timed(brent_rho, N)
            assert f and N % f == 0 and 1 < f < N, f"rho failed on {bits}b"
            times.append(dt)
            ps.append(p)
        med = statistics.median(times)
        results.append({"alg": "rho", "bits": bits, "median_s": med,
                        "p_bits": int(ps[0]).bit_length()})
        print(f"  {bits:>4}b N: {med:8.4f}s  (smaller factor ~{int(ps[0]).bit_length()}b)")

    print("== H1b: rho vs SMALLER-FACTOR size (unbalanced, p fixed ~2^32) ==")
    for qb in (48, 64, 80, 96, 112, 128):
        times, ps = [], []
        for _ in range(3):
            N, p = gen_semiprime(qb + 32, balance=32 / (qb + 32))
            dt, f = timed(brent_rho, N)
            times.append(dt); ps.append(p)
        med = statistics.median(times)
        results.append({"alg": "rho_unbal", "qb": qb, "median_s": med,
                        "p_bits": int(ps[0]).bit_length()})
        print(f"  q={qb}b (p~2^32): {med:8.4f}s")

    print("== H2: GMP-ECM, factor size sweep (B1=11e3, 30 curves) ==")
    for pb in (25, 30, 35, 40, 45):
        times, ok = [], 0
        for _ in range(3):
            N, p = gen_semiprime(pb * 2, balance=0.5)
            dt, f = timed(gmp_ecm, N, 11000, 30)
            if f:
                ok += 1
                times.append(dt)
        if times:
            results.append({"alg": "ecm", "pb": pb,
                            "median_s": statistics.median(times), "ok": ok})
            print(f"  p~{pb}b: {statistics.median(times):8.3f}s ({ok}/3 found)")
        else:
            results.append({"alg": "ecm", "pb": pb, "median_s": None, "ok": 0})
            print(f"  p~{pb}b: no factor in budget")

    print("== H2b: GMP-ECM independence from modulus size (fixed p~2^30) ==")
    for qb in (64, 96, 128, 160):
        N, p = gen_semiprime(qb + 30, balance=30 / (qb + 30))
        dt, f = timed(gmp_ecm, N, 5000, 20)
        results.append({"alg": "ecm_fixed_p", "qb": qb, "median_s": dt,
                        "found": bool(f)})
        print(f"  N={qb+30}b: {dt:8.3f}s found={bool(f)}")

    with open("/tmp/e1_results.json", "w") as fh:
        json.dump(results, fh, indent=1)
    print(f"\n{len(results)} measurements written to /tmp/e1_results.json")


if __name__ == "__main__":
    run()
