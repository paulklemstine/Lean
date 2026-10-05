#!/usr/bin/env python3
"""A2b -- THE chi_P CROSS-TAB.  My A2 measured chi_P only for v=1 (the Fraction
denominator was 1 only then), so FRAC chi-1 there was meaningless.

The RIGHT chi_P is  chi_P = Jacobi(w * g(m), N):
    t = w * g(m)^{-1} (mod N), t^2 = 1 (mod N), and Jacobi is multiplicative on
    units, so Jacobi(t,N) = Jacobi(w,N)*Jacobi(g,N) = Jacobi(w*g, N).
    (The campaign's val = g(m)*w/v^2 gives the same value: v^2 is a square.)
Cross-tabulate against p mod 4, q mod 4 and gcd-nontriviality.
"""
import math, random, json, time
from math import gcd, isqrt
import multiprocessing as mp

CPOOL = (2, 3, 5, 6, 7, 10, 11, 13, 14, 17, 19, 22, 23, 26, 29, 31)
H = 40
def _icbrt_floor(n):
    x = 1 << ((n.bit_length() + 2) // 3)
    while True:
        y = (2 * x + n // (x * x)) // 3
        if y >= x: break
        x = y
    while x ** 3 > n: x -= 1
    while (x + 1) ** 3 <= n: x += 1
    return x
def m_window(bits):
    lo, hi = 1 << (bits - 1), 1 << bits
    m0 = _icbrt_floor(lo + min(CPOOL)); m1 = _icbrt_floor(hi + max(CPOOL))
    while (m1 + 1) ** 3 - max(CPOOL) < hi: m1 += 1
    return m0, m1
def coprime_pairs(H):
    return [(u, v) for v in range(1, H+1) for u in range(-H, H+1)
            if not (u == 0 and v == 1) and gcd(abs(u), v) == 1]
PAIRS = coprime_pairs(H)
def jacobi(a, n):
    a, n = int(a) % n, int(n); r = 1
    while a:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5): r = -r
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3: r = -r
        a %= n
    return r if n == 1 else 0
def rels_of(m, c):
    out = []
    for (u, v) in PAIRS:
        lm = 8*u*u*u*v*m + c*v**4*m + 4*u**4 - 4*c*u*v**3
        if lm <= 0: continue
        w = isqrt(lm)
        if w*w == lm: out.append((u, v, w))
    return out

def worker(job):
    import cypari2
    bits, shard, seed, nsamp = job
    P = cypari2.Pari(); P("default(parisize,256<<20)")
    m0, m1 = m_window(bits); span = m1 - m0 + 1
    rng = random.Random(seed)
    cell = {}   # (pm4,qm4) -> [nrel, nchi1, ngood, nchi1_and_good, nchi1_and_nogood]
    for _ in range(nsamp):
        m = m0 + rng.randrange(span); c = CPOOL[rng.randrange(len(CPOOL))]
        N = m*m*m - c
        if not ((1 << (bits-1)) <= N < (1 << bits)): continue
        r = P.factor(N)
        fac = [(int(r[0][i]), int(r[1][i])) for i in range(len(r[0]))]
        if len(fac) != 2: continue
        (p, e1), (q, e2) = fac
        if e1 != 1 or e2 != 1 or p == q: continue
        k = (p % 4 == 3, q % 4 == 3)
        a = cell.setdefault(k, [0, 0, 0, 0, 0])
        for (u, v, w) in rels_of(m, c):
            gmv = -2*u*u + (-2*u*v)*m + v*v*m*m
            ch = jacobi(w * gmv, N)
            good = gcd(w - gmv, N) not in (1, N)
            a[0] += 1
            a[1] += (ch == -1)
            a[2] += good
            a[3] += (ch == -1 and good)
            a[4] += (ch == -1 and not good)
    return bits, cell

if __name__ == "__main__":
    PLAN = {26: 120000, 40: 300000, 48: 700000, 56: 2200000, 64: 6000000}
    jobs = [(b, s, 1000*b + 7919*s + 13, ns // 12) for b, ns in PLAN.items() for s in range(12)]
    t0 = time.time()
    with mp.get_context("fork").Pool(12) as pool:
        res = pool.map(worker, jobs)
    cells = {}
    for b, c in res:
        d = cells.setdefault(b, {})
        for k, v in c.items():
            t = d.setdefault(k, [0, 0, 0, 0, 0])
            for i in range(5): t[i] += v[i]
    print("=" * 126)
    print("A2b  chi_P = Jacobi(w*g(m), N)   vs   gcd(w-g(m), N) nontrivial.   H=40, CPOOL")
    print("=" * 126)
    print("%5s %-13s %8s %9s %9s %11s %13s %11s"
          % ("bits","(p%4==3,q%4==3)","nrel","FRAC chi-1","FRAC GOOD","chi-1&good","chi-1&NOTgood","frac chi-1|good"))
    tot = {}
    for b in sorted(cells):
        for k in sorted(cells[b]):
            nrel, nchi1, ngood, both, onlychi = cells[b][k]
            if not nrel: continue
            print("%5d %-13s %8d %9.4f %9.4f %11d %13d %11.4f"
                  % (b, str(k), nrel, nchi1/nrel, ngood/nrel, both, onlychi,
                     nchi1/ngood if ngood else 0))
            t = tot.setdefault(k, [0, 0, 0, 0, 0])
            for i, x in enumerate((nrel, nchi1, ngood, both, onlychi)): t[i] += x
    print()
    print("POOLED over all sizes:")
    for k in sorted(tot):
        nrel, nchi1, ngood, both, onlychi = tot[k]
        print("  (p%%4==3,q%%4==3)=%-13s nrel=%7d  FRAC chi-1=%.4f  FRAC GOOD=%.4f  "
              "P(good | chi=-1)=%.4f  P(good | chi=+1)=%.4f"
              % (str(k), nrel, nchi1/nrel, ngood/nrel,
                 both/nchi1 if nchi1 else 0, (ngood-both)/(nrel-nchi1) if nrel > nchi1 else 0))
    print("  %.0f s" % (time.time()-t0))
