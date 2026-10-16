import math
def base_m_coeffs(N, d, m):
    N = ZZ(N); m = ZZ(m); c = []
    while N > 0: c.append(N % m); N = N // m
    while len(c) < d + 1: c.append(ZZ(0))
    return c[:d+1]
PBOUND = 2**14
PRIMES = [int(x) for x in primes(2, PBOUND+1)]
def is_B_smooth(v, B=PBOUND):
    v = int(v)
    if v <= 1: return True
    for p in PRIMES:
        if p > B: break
        if v % p == 0:
            while v % p == 0: v //= p
            if v == 1: return True
    return v == 1
def smooth_rate(N, m, X, trials, seed=0):
    set_random_seed(seed); good = 0
    for _ in range(trials):
        a = ZZ(randint(1, X)); b = ZZ(randint(1, X))
        if is_B_smooth((a + b*m) % N): good += 1
    return float(good)/float(trials)
def trop(c, p): return sum(ZZ(x).valuation(p) for x in c if x != 0)
p = ZZ(next_prime(2**49)); q = ZZ(next_prime(2**51)); N = p*q
X = ZZ(2**24)
rows = []
for d in [3,4,5,6]:
    for mb in range(N.nbits()//d - 6, N.nbits()//d + 7):
        m = ZZ(next_prime(2**mb))
        if m > N: continue
        c = base_m_coeffs(N, d, m)
        if any(ZZ(x) >= m for x in c): continue
        rows.append((d, mb, trop(c,2), trop(c,3), smooth_rate(N, m, X, 120, seed=1)))
def pearson(x, y):
    n = len(x); mx, my = sum(x)/n, sum(y)/n
    num = sum((x[i]-mx)*(y[i]-my) for i in range(n))
    den = math.sqrt(sum((x[i]-mx)**2 for i in range(n))*sum((y[i]-my)**2 for i in range(n)))
    return float(num/den) if den else float('nan')
pay = [r[4] for r in rows]
print(f"POOLED (all {len(rows)} candidates): trop^2 r = {pearson([r[2] for r in rows], pay):+.4f}, "
      f"trop^3 r = {pearson([r[3] for r in rows], pay):+.4f}", flush=True)
print("CONDITIONED on degree:", flush=True)
for d in [3,4,5,6]:
    sub = [r for r in rows if r[0] == d]
    if len(sub) < 3: continue
    ys = [r[4] for r in sub]
    print(f"  d={d} (n={len(sub)}): trop^2 r = {pearson([r[2] for r in sub], ys):+.4f}"
          f"   |m| vs payoff r = {pearson([r[1] for r in sub], ys):+.4f}"
          f"   trop^3 r = {pearson([r[3] for r in sub], ys):+.4f}", flush=True)
print()
print("=> if the pooled r collapses within degrees, the tropical score was measuring", flush=True)
print("   the DEGREE, not the smoothness.  |m| is the classical predictor: smaller base", flush=True)
print("   => smaller values => smoother.", flush=True)
print(f"  pooled |m| vs payoff: r = {pearson([r[1] for r in rows], pay):+.4f}", flush=True)
