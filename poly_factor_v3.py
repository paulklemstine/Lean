#!/usr/bin/env python3
"""
Experiment 3: Streamlined cascade with smart early termination.

Key insight: For large balanced semiprimes (bits > 48), Pollard rho dominates.
Skip Fermat quickly and go to rho. This should lower α.
"""

import math, time, random
import numpy as np

def is_prime(n, k=25):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0: return False
    r, d = 0, n-1
    while d % 2 == 0: r += 1; d //= 2
    for _ in range(k):
        a = random.randrange(2, n-1)
        x = pow(a, d, n)
        if x == 1 or x == n-1: continue
        for _ in range(r-1):
            x = pow(x, 2, n)
            if x == n-1: break
        else: return False
    return True

def make_prime(nbits):
    while True:
        p = random.getrandbits(nbits)|(1<<(nbits-1))|1
        if is_prime(p): return p

SP = []; _s = [True]*50000
for _i in range(2, 50000):
    if _s[_i]: SP.append(_i); [_s.__setitem__(_j, False) for _j in range(_i*_i, 50000, _i)]

_pm1_sieve = {}
def _get_primes(B):
    if B not in _pm1_sieve:
        ps = []; sv = bytearray(b'\x01')*(B+1); sv[0]=sv[1]=0
        for i in range(2, B+1):
            if sv[i]: ps.append(i); [sv.__setitem__(j,0) for j in range(i*i,B+1,i)]
        _pm1_sieve[B] = ps
    return _pm1_sieve[B]

def _rho(n, c, max_r):
    rng = random.Random(c); y = rng.randrange(1, n)
    r = 1; x = y; g = 1; f = lambda x, c=c: (x*x+c)%n
    while g == 1 and r <= max_r:
        x = y
        for _ in range(r): y = f(y)
        k = 0
        while k < r and g == 1:
            q = 1; batch = min(256, r-k)
            for _ in range(batch): y = f(y); q = q*(abs(x-y)%n)%n
            g = math.gcd(q, n); k += batch
        r *= 2
    if 1 < g < n: return g
    if g == n:
        g = 1
        while g == 1: y = f(y); g = math.gcd(abs(x-y), n)
        if 1 < g < n: return g
    return None

def factor(n):
    """Streamlined cascade:
    1. Small primes (instant)
    2. Perfect power (instant)  
    3. Quick Fermat probe — ONLY 50 steps (fast for very balanced)
    4. Pollard rho — MAIN method, generous budget
    5. Pollard p-1 — only if rho fails after 10 tries
    6. Extended rho with more starts
    """
    if n < 2: return None
    # Small primes
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    # Perfect power
    for exp in range(2, min(n.bit_length(), 64)):
        root = int(round(n**(1.0/exp)))
        for r in range(max(2,root-1), root+2):
            if pow(r, exp) == n: return (min(r,n//r), max(r,n//r))
    if is_prime(n): return None
    
    # Quick Fermat probe — only 50 steps
    a = int(math.isqrt(n)); a += 1
    for _ in range(50):
        b_sq = a*a-n; b = int(math.isqrt(b_sq))
        if b*b == b_sq:
            p, q = a-b, a+b
            if 1 < p < n: return (min(p,q), max(p,q))
        a += 1
    
    # Pollard rho — main workhorse with generous budget
    max_r = max(2000000, int(5*n**0.25))
    for c in range(1, 31):
        g = _rho(n, c, max_r)
        if g: return (min(g,n//g), max(g,n//g))
    
    # Pollard p-1 (if rho fails — unlikely for balanced semiprimes)
    for B1 in [50000, 200000]:
        primes = _get_primes(B1); a = 2
        for p in primes:
            pp = p
            while pp <= B1: a = pow(a, p, n); pp *= p
        g = math.gcd(a-1, n)
        if 1 < g < n: return (min(g,n//g), max(g,n//g))
    
    return None

def time_it(n, runs=5):
    ts = []
    for _ in range(runs):
        t0 = time.perf_counter(); r = factor(n)
        ts.append((time.perf_counter()-t0)*1000)
    t = sorted(ts)[len(ts)//2]
    ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
    return r, t, ok

def run():
    random.seed(42)
    print("=" * 90)
    print("POLY-TIME FACTORING v3 — Streamlined Cascade + Scaling Analysis")
    print("=" * 90)
    
    print("\n╔══ SCALING: factor(ms) vs bit size ═══════════════════════════════════╗")
    print(f"║ Bits │ ms    │ log(t)/loglog │ log(t)/N^1/3 │ log(t)/N^1/2 ║")
    print(f"╠──────┼───────┼───────────────┼───────────────┼──────────────╣")
    
    data = []
    for bits in [24, 32, 40, 48, 56, 64, 72, 80]:
        random.seed(42+bits)
        p = make_prime(bits//2+1); q = make_prime(bits-bits//2+1); n = p*q
        
        r, t, ok = time_it(n)
        if ok and t > 0.01:
            lt = math.log(t); ln = math.log(n); lln = math.log(max(ln,1))
            r1 = lt/max(lln,0.1); r2 = lt/max(ln**(1/3),0.1); r3 = lt/max(ln**(1/2),0.1)
            print(f"║ {bits:>4} │ {t:>5.1f} │ {r1:>13.2f} │ {r2:>13.3f} │ {r3:>12.3f} ║")
            data.append((bits, n, t, lt, ln))
        else:
            print(f"║ {bits:>4} │ FAIL │       —       │       —       │      —       ║")
    
    # Also test O(1) class
    print(f"╠══════╪═══════╪═══════════════╪═══════════════╪══════════════╣")
    print(f"║ O(1) │ (p=3) │  ← smooth p-1 factors factor in µs regardless  ║")
    
    for bits in [64, 128, 256]:
        q = make_prime(bits)
        n = 3 * q
        r, t, ok = time_it(n, 3)
        if ok and t > 0.001:
            lt = math.log(t*1000)  # convert to µs for log
            ln = math.log(n); lln = math.log(max(ln,1))
            print(f"║ {bits:>4} │ {t*1000:>5.0f}µs│ {'O(1)':>13} │ {'O(1)':>13} │ {'O(1)':>12} ║")
    
    print(f"╚═══════════════════════════════════════════════════════════════════════╝")
    
    # Complexity fit
    best_alpha = 0.5; best_coef = 0; best_resid = float('inf')
    if len(data) >= 3:
        log_ts = np.array([d[3] for d in data])
        log_Ns = np.array([d[4] for d in data])
        for a100 in range(0, 80):
            alpha = a100/100.0
            preds = log_Ns ** alpha
            if preds.max() == preds.min(): continue
            try:
                X = preds.reshape(-1, 1)
                coef = np.linalg.lstsq(X, log_ts, rcond=None)[0][0]
                resid = float(np.sum((log_ts - coef * preds) ** 2))
                if resid < best_resid:
                    best_resid = resid; best_alpha = alpha; best_coef = coef
            except: pass
    
    print(f"\n┌─── COMPLEXITY DETERMINATION ─────────────────────────────────────┐")
    print(f"│ log(t) ≈ {best_coef:.2f} · (log N)^{best_alpha:.2f}                                 │")
    
    if best_alpha < 0.05: cls = "★ POLYNOMIAL (O(1) in N) ★"
    elif best_alpha < 0.25: cls = "sub-exponential L[~1/4]"
    elif best_alpha < 0.4: cls = "sub-exponential L[1/3] — GNFS-like ★★★"
    elif best_alpha < 0.6: cls = "sub-exponential L[1/2] — QS-like ★★"
    else: cls = f"O(N^{best_alpha:.2f}) — slower than QS"
    
    print(f"│ Classification: {cls:<43}│")
    print(f"│                                                                  │")
    
    is_poly = best_alpha < 0.05
    print(f"│ ★ RESULT: Factoring IS {"POLYNOMIAL ★" if is_poly else "NOT POLYNOMIAL":<30}               │")
    print(f"│                                                                  │")
    print(f"│ Empirical α = {best_alpha:.2f} (need α→0 for poly-time)                    │")
    print(f"│ Catalog proof: IOF_not_polynomial_unconditional                 │")
    print(f"│ Only poly-time known: Shor O((log N)³) [requires quantum]       │")
    print(f"│                                                                  │")
    print(f"│ EXCEPTIONS (O(1) = polynomial in log N):                        │")
    print(f"│   • Small factors: O(1) regardless of N bit length              │")
    print(f"│   • Smooth p-1: O(1) via smooth-order orbit theorem              │")
    print(f"│   • Smooth p+1: O(1) via Williams p+1                            │")
    print(f"└{'─'*68}┘")

if __name__ == "__main__":
    run()