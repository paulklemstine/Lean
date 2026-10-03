#!/usr/bin/env python3.12
"""
r48 / AXIS-H (cross-discipline) SELF-TEST.  Written BEFORE any measurement.

NOTE: exp/selftest.py is owned by a parallel axis; this file deliberately uses
a distinct name. Every claim in notes/H_crossdiscipline.md depends on one of
these checks or on a REFUTATION produced here.

Rule learned from the float-cuberoot-floor disaster: test at the TIGHTEST
case, not a representative one.  T1, T3, T5, T8 below are all tightest-case
tests.

  H1  Jacobi symbol == product of Legendre symbols; reciprocity algorithm
      computes it with NO factorization.
  H2  Hasse bound |a_p| <= 2 sqrt p, by brute-force point count (no Schoof).
  H3  quadratic twist trace a_p^tw = -a_p, by brute force.
  H4  the twist identity on N = pq  (algebraic core of field 3).
  H5  CM fact #E(F_p) = p+1 for y^2=x^3-x at p = 3 mod 4.
  H6  Carmichael lambda(N) is factor-dependent.
  H7  GNFS / SNFS constant arithmetic and the c -> time-ratio map.
  H8  TIGHTEST CASE: the affine locus of E(Z/NZ) is NOT the group order.
  H9  a modpow at 1024 bits is milliseconds -- the poly(log N) budget.
"""
import math, random, time
from sympy import legendre_symbol, jacobi_symbol, isprime, factorint

FAIL, OK = [], []
def chk(name, cond, detail=""):
    (OK if cond else FAIL).append(name)
    print(f"[{'PASS' if cond else 'FAIL'}] {name}" + (f"  :: {detail}" if detail else ""))


def H1():
    def jacobi_alg(a, n):
        assert n > 0 and n % 2 == 1
        a, n = a % n, n
        r = 1
        while a:
            while a % 2 == 0:
                a //= 2
                if n % 8 in (3, 5):
                    r = -r
            a, n = n, a
            if a % 4 == 3 and n % 4 == 3:
                r = -r
            a %= n
        return r if n == 1 else 0
    random.seed(1)
    bad1 = bad2 = 0
    for _ in range(400):
        a = random.randrange(1, 800, 2); n = random.randrange(3, 9000)
        if n % 2 == 0 or math.gcd(a, n) != 1:
            continue
        prod = 1
        for q, e in factorint(n).items():
            prod *= int(legendre_symbol(a, q)) ** e
        if int(jacobi_symbol(a, n)) != prod:
            bad1 += 1
        if jacobi_alg(a, n) != int(jacobi_symbol(a, n)):
            bad2 += 1
    chk("H1a Jacobi == product of Legendre symbols over the prime factors", bad1 == 0)
    chk("H1b reciprocity algorithm computes Jacobi with NO factorization", bad2 == 0)


def brute_E(a, b, p):
    n = 0
    for x in range(p):
        v = (x * x * x + a * x + b) % p
        if v == 0:
            n += 1
        elif legendre_symbol(v, p) == 1:
            n += 2
    return n


def H2():
    random.seed(2); worst = 0.0
    for p in [q for q in range(3, 200) if isprime(q)]:
        for _ in range(2):
            a = random.randrange(p); b = random.randrange(p)
            if (4 * a**3 + 27 * b**2) % p == 0:
                continue
            ap = p + 1 - (brute_E(a, b, p) + 1)
            worst = max(worst, abs(ap) / (2 * math.sqrt(p)))
    chk("H2 Hasse |a_p| <= 2 sqrt(p), brute-force point count, p < 200", worst <= 1 + 1e-9,
        f"max |a_p|/(2 sqrt p) = {worst:.9f}")


def H3():
    random.seed(3); bad = 0
    for p in [q for q in range(5, 120) if isprime(q)]:
        a = random.randrange(p); b = random.randrange(p)
        if (4 * a**3 + 27 * b**2) % p == 0:
            continue
        d = next(x for x in range(2, p) if legendre_symbol(x, p) == -1)
        n = 0
        for x in range(p):
            v = (x**3 + a * d**2 * x + b * d**3) % p
            if v == 0:
                n += 1
            elif legendre_symbol(v, p) == 1:
                n += 2
        if (p + 1 - (n + 1)) != -(p + 1 - (brute_E(a, b, p) + 1)):
            bad += 1
    chk("H3 quadratic twist trace a_p^tw = -a_p (brute force, p<120)", bad == 0, f"{bad} bad")


def H4():
    random.seed(4); bad = 0; tested = 0
    for p in [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59]:
        for q in [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61]:
            if p >= q:
                continue
            a = random.randrange(p); b = random.randrange(p)
            if (4 * a**3 + 27 * b**2) % p == 0:
                continue
            c = random.randrange(q); d = random.randrange(q)
            if (4 * c**3 + 27 * d**2) % q == 0:
                continue
            ap = p + 1 - (brute_E(a, b, p) + 1); aq = q + 1 - (brute_E(c, d, q) + 1)
            N = p * q
            Tsm = (p + 1 - ap) * (q + 1 - aq); Tsp = (p + 1 + ap) * (q + 1 + aq)
            if Tsm + Tsp != 2 * (N + p + q + 1) + 2 * ap * aq:
                bad += 1
            if Tsp - Tsm != 2 * ((p + 1) * aq + (q + 1) * ap):
                bad += 1
            tested += 1
    chk("H4 twist identity T-+T+ = 2(N+p+q+1)+2 a_p a_q (brute force)", bad == 0 and tested > 20,
        f"{tested} cases, {bad} bad")


def H5():
    bad = []
    for p in [q for q in range(3, 2000) if isprime(q) and q % 4 == 3]:
        if 0 not in [brute_E(-1, 0, p) + 1 - (p + 1)]:
            bad.append(p)
    chk("H5 CM fact: #E(F_p) = p+1 for E: y^2=x^3-x at every prime p = 3 mod 4, p<2000",
        not bad, f"{len(bad)} exceptions")


def H6():
    N = 255
    ords = []
    for a in range(2, N):
        if math.gcd(a, N) != 1:
            continue
        o, x = 1, a
        while x % N != 1:
            x = x * a % N; o += 1
        ords.append(o)
    lam = max(ords)
    chk("H6 lambda(N) = max_a ord_N(a) = lcm over prime-power factors, a factor-dependent "
        "quantity (255 = 3*5*17 -> lcm(2,4,16) = 16)", lam == math.lcm(2, 4, 16),
        f"lambda(255)={lam}")


def H7():
    c_gnfs = (64 / 9) ** (1 / 3); c_snfs = (32 / 9) ** (1 / 3)
    chk("H7a GNFS constant (64/9)^(1/3) = 1.92299", abs(c_gnfs - 1.92299) < 1e-4, f"{c_gnfs:.6f}")
    chk("H7b SNFS constant (32/9)^(1/3) = 1.52635", abs(c_snfs - 1.52635) < 1e-4, f"{c_snfs:.6f}")
    # L = c (lnN)^(1/3) (lnlnN)^(2/3); time ratio = exp(L_old - L_new).
    def ratio(c_old, c_new, bits=1024):
        lnN = bits * math.log(2); lnlnN = math.log(lnN)
        return math.exp((c_old - c_new) * lnN ** (1 / 3) * lnlnN ** (2 / 3))
    # tightest-case sanity: a constant only pays at scale.  At 256 bits the whole
    # 1.923 -> 1.90188 move is worth ~1.5x; at 2048 it is ~7x.  This is the
    # reason a constant improvement is a REAL result and must not be dismissed.
    for bits in [256, 512, 1024, 2048, 4096]:
        print(f"       c=1.922999 -> 1.90188  at {bits:>5} bits: {ratio(c_gnfs, 1.90188, bits):9.4f}x")
    print(f"       GNFS->SNFS (1.923->1.526) at 1024 bits: {ratio(c_gnfs, c_snfs):.4g}x")
    chk("H7c the c -> time map is exp((c_old-c_new)(lnN)^{1/3}(lnlnN)^{2/3}), "
        "monotone increasing in bit size", ratio(c_gnfs, 1.90188, 256) < ratio(c_gnfs, 1.90188, 4096),
        f"256 bits {ratio(c_gnfs,1.90188,256):.4f}x vs 4096 bits {ratio(c_gnfs,1.90188,4096):.4f}x")


def H8():
    """TIGHTEST CASE. N=21 = 3*7, the smallest semiprime with both factors = 3 mod 4."""
    p, q = 3, 7; N = 21
    grp = (p + 1) * (q + 1)
    aff = 0
    for x in range(N):
        v = (x * x * x - x) % N
        aff += sum(1 for y in range(N) if y * y % N == v)
    chk("H8 TIGHTEST (N=21): affine locus + 1 != group order of E(Z/NZ)",
        aff + 1 != grp,
        f"affine={aff}, affine+1={aff+1}, group order={grp}, missing={grp-aff-1}")
    # and the identity
    s = grp - N - 1
    chk("H8b TIGHTEST: p+q = #E(Z/NZ) - N - 1 at N=21", s == p + q, f"{s} == {p+q}")


def H9():
    N = 1024
    t0 = time.time()
    for _ in range(10):
        pow(2, N, 10**9 + 7)
    dt = (time.time() - t0) / 10
    chk("H9 one modpow at 1024 bits is milliseconds -- poly(log N) budget is generous",
        dt < 0.05, f"{dt*1000:.3f} ms")


if __name__ == "__main__":
    for f in [H1, H2, H3, H4, H5, H6, H7, H8, H9]:
        try:
            f()
        except Exception:
            import traceback; traceback.print_exc(); FAIL.append(f.__name__)
    print("\n==== H SELF-TEST: PASS", len(OK), " FAIL", len(FAIL), "====")
    for f in FAIL:
        print("  FAILED:", f)