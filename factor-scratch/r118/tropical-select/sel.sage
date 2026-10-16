# F1 (applied): tropical / p-adic size as an NFS polynomial-selection criterion
#
# The catalog formalised tropical algebra and the Newton-tropical bridge
# (Catalog/Cryptography/TropicalAlgebra, Newtontropicalbridge).  NFS polynomial selection
# picks phi(x) in Z[x] with small coefficients and good root properties; the classical
# (Kleinjung) criterion is an affine size/skewness combination.
#
# Tropicalising the problem replaces the coefficient SIZE by its p-adic VALUATION -- which
# is exactly what controls the smoothness of the values v = a + b*theta.
#
# EXPERIMENT (honest, ground-truthed): generate N = p*q with p,q KNOWN, build the classical
# base-m polynomials phi(x) = sum_i c_i x^i with phi(m) = N (so theta = m is a root mod N),
# and for each (d, m) measure
#     (a) the classical score  : sqrt(sum c_i^2) and the skewness ratio
#     (b) the tropical score   : sum_i v_p(c_i)
#     (c) the true payoff      : the B-smoothness rate of v = a + b*m mod N over |a|,|b| < X
# Then ask which criterion (a) or (b) better predicts (c).

import math

def base_m_coeffs(N, d, m):
    """c = base-m digits of N, so phi(x) = sum_i c_i x^i satisfies phi(m) = N."""
    N = ZZ(N); m = ZZ(m)
    c = []
    while N > 0:
        c.append(N % m)
        N = N // m
    while len(c) < d + 1:
        c.append(ZZ(0))
    return c[:d + 1]

PBOUND = 2**14
PRIMES = [int(x) for x in primes(2, PBOUND + 1)]

def is_B_smooth(v, B=PBOUND):
    """B-smooth in the integers, using PYTHON ints (Sage Integers are 10x slower here)."""
    v = int(v)
    if v <= 1: return True
    for p in PRIMES:
        if p > B: break
        if v % p == 0:
            while v % p == 0: v //= p
            if v == 1: return True
    return v == 1

def smooth_rate(N, m, X, B, trials, seed=0):
    set_random_seed(seed)
    good = 0
    for _ in range(trials):
        a = ZZ(randint(1, X)); b = ZZ(randint(1, X))
        v = (a + b * m) % N
        if is_B_smooth(v): good += 1
    return float(good) / float(trials)

def tropical_score(c, p=2):
    return sum(ZZ(x).valuation(p) for x in c if x != 0)

# ---- ground truth: N = p*q with KNOWN factors -------------------------------
p = ZZ(next_prime(2**49))
q = ZZ(next_prime(2**51))
N = p * q
print(f"N = p*q, p={p.nbits()}b q={q.nbits()}b, N={N.nbits()} bits (factors known to us)", flush=True)

X = ZZ(2**24)          # search-box side for (a,b)
B = PBOUND
TRIALS = 120

print()
print(f"measuring the true payoff: B-smoothness rate of v = a+b*m mod N, |a|,|b| < 2^24, B=2^20", flush=True)
print(f"{'d':>2} {'m bits':>7} {'max|c_i|':>10} {'l2':>9} {'skew':>6} {'trop(v2)':>9} "
      f"{'trop(v3)':>9} {'smooth rate':>12}", flush=True)
rows = []
for d in [3, 4, 5, 6]:
    for mb in range(N.nbits() // d - 6, N.nbits() // d + 7):
        m = ZZ(next_prime(2**mb))
        if m > N: continue
        c = base_m_coeffs(N, d, m)
        if any(ZZ(x) >= m for x in c): continue      # not a valid base-m digit vector
        mx = max(abs(ZZ(x)) for x in c)
        l2v = sqrt(QQ(sum(ZZ(x)**2 for x in c)))
        dg = d
        skew = max(float(abs(ZZ(c[i]))**(QQ(1)/(dg - i + 1))) for i in range(dg)) if dg else 1.0
        t2 = tropical_score(c, 2); t3 = tropical_score(c, 3)
        sr = smooth_rate(N, m, X, B, TRIALS, seed=1)
        rows.append((d, mb, mx, l2v, skew, t2, t3, sr))
        print(f"{d:>2} {mb:>7} {int(mx):>10} {float(l2v):>9.1f} {skew:>6.2f} {t2:>9} "
              f"{t3:>9} {float(sr):>12.4f}", flush=True)

# ---- which criterion predicts the payoff? ----------------------------------
print()
print("correlation of each criterion with the measured smoothness rate:", flush=True)
xs = [float(r[7]) for r in rows]
for name, vec in [("l2 size", [float(r[3]) for r in rows]),
                  ("max coefficient", [float(r[2]) for r in rows]),
                  ("skewness", [float(r[4]) for r in rows]),
                  ("tropical v2", [float(r[5]) for r in rows]),
                  ("tropical v3", [float(r[6]) for r in rows])]:
    n = len(xs)
    mx, my = sum(vec)/n, sum(xs)/n
    num = sum((vec[i]-mx)*(xs[i]-my) for i in range(n))
    den = sqrt(sum((vec[i]-mx)**2 for i in range(n)) * sum((xs[i]-my)**2 for i in range(n)))
    print(f"  {name:>16}: Pearson r = {float(num/den):+.4f}" if den else f"  {name}: degenerate", flush=True)

best = max(rows, key=lambda r: float(r[7]))
print()
print(f"best measured (smoothest): d={best[0]} m~2^{best[1]} rate={float(best[7]):.4f}", flush=True)
worst = min(rows, key=lambda r: float(r[7]))
print(f"worst measured          : d={worst[0]} m~2^{worst[1]} rate={float(worst[7]):.4f}", flush=True)
print()
print("What the criteria would have PICKED (best predicted) vs what was actually best:", flush=True)
for name, idx, higher_better in [("l2 size", 3, False), ("skewness", 4, False),
                                 ("tropical v2", 5, False), ("tropical v3", 6, False)]:
    pick = (min if not higher_better else max)(rows, key=lambda r: float(r[idx]))
    print(f"  {name:>16} picks d={pick[0]} m~2^{pick[1]} -> actual rate {float(pick[7]):.4f}"
          f"   (true best {float(best[7]):.4f})", flush=True)
