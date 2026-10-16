# FRONTIER LAW: t* = ln(n) / (2 (p - 1/2)^2)  for the maximum-likelihood / Fourier attack.
#
# The naive prediction t >> 1/(4(p-1/2)^2) IGNORED MULTIPLE TESTING: the ML score is
# computed for all n candidate keys, and the true key must beat the MAXIMUM of n-1
# Binomial(t, 1/2) counts, not a single rival.  The corrected condition is
#         t (p - 1/2) >> sqrt(t ln n / 2)      =>      t* = ln(n) / (2 (p-1/2)^2)
# which is LOGARITHMIC in n -- versus the plain HNP lattice, whose per-signature
# requirement is ~10 KNOWN bits (so t*l* grows LINEARLY in t at 10 bits per signature).
#
# In total information: t*(1 - H(p)) with 1-H(p) ~ (p-1/2)^2/(2 ln 2) gives
#         total information ~ ln(n)/(4 ln 2) = log2(n)/4 bits
# i.e. n/4 bits of BIAS INFORMATION suffice -- versus the lattice's 10t.

def tstar_once(p, nbits, t, seed):
    """does the ML argmax find the true key?"""
    set_random_seed(seed)
    n = ZZ(next_prime(2**nbits))
    d_true = ZZ(randint(1, n - 1))
    half = ZZ(1) << (nbits - 1)
    rs, ss, zs = [], [], []
    for _ in range(t):
        k = ZZ(randint(0, half - 1))
        if random() < (1 - p):
            k += half
        r = ZZ(randint(1, n - 1)); z = ZZ(randint(0, n - 1))
        s = (z + r * d_true) * inverse_mod(k, n) % n
        rs.append(r); ss.append(s); zs.append(z)
    sinv = [inverse_mod(ss[i], n) for i in range(t)]
    best, bestd = -1, None
    for d in range(1, n):
        cnt = 0
        for i in range(t):
            if (zs[i] + rs[i] * d) * sinv[i] % n < half:
                cnt += 1
        if cnt > best:
            best, bestd = cnt, d
    return bestd == d_true

def tstar(p, nbits, ts, seeds=3):
    for t in ts:
        if sum(tstar_once(p, nbits, t, sd) for sd in range(seeds)) >= 2:
            return t
    return None

import math
print("confirming  t* * (p-1/2)^2  ~  ln(n)/2   (slope 1/2 in log n)", flush=True)
print(f"{'p':>6} {'nbits':>6} {'ln n':>7} | {'t*':>6} {'t*(p-1/2)^2':>14} {'ln n /2':>9} {'ratio':>7}", flush=True)
for p in [0.65, 0.75, 0.85]:
    for nbits in [10, 12, 14]:
        n = float(next_prime(2**nbits))
        ln = math.log(n)
        ts = [8, 16, 24, 32, 48, 64, 96, 128, 192, 256, 384, 512]
        got = tstar(p, nbits, ts)
        lhs = got * (p - 0.5)**2 if got else None
        print(f"{p:>6.2f} {nbits:>6} {ln:>7.2f} | {str(got):>6} "
              f"{('%.1f' % lhs) if lhs else '>512':>14} {ln/2:>9.2f} "
              f"{('%.2f' % (lhs/(ln/2))) if lhs else '     -':>7}", flush=True)
print()
print("slope check: t*(p-1/2)^2 / (ln n / 2) should be ~1 (constant) across nbits", flush=True)
