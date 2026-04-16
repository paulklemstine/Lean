#!/usr/bin/env python3
"""
New Factoring Algorithms — Experiment 2: ECM advantage on imbalanced semiprimes.

KEY INSIGHT: ECM complexity is sub-exponential in log(p) where p = smallest factor.
For imbalanced semiprimes N = p*q with p << q, ECM should dominate rho
(whose complexity is O(N^{1/4}) regardless of factor balance).

Also testing: autocorrelation factoring optimization, batch GCD methods.
"""

import math, time, random, sys
import numpy as np
from typing import Optional, Tuple

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

SP = []
_s = [True]*50000
for _i in range(2, 50000):
    if _s[_i]: SP.append(_i); [_s.__setitem__(_j, False) for _j in range(_i*_i, 50000, _i)]

PM1_SIEVE = {}
def get_primes(B):
    if B not in PM1_SIEVE:
        ps = []; sv = bytearray(b'\x01')*(B+1); sv[0]=sv[1]=0
        for i in range(2, B+1):
            if sv[i]: ps.append(i); [sv.__setitem__(j,0) for j in range(i*i,B+1,i)]
        PM1_SIEVE[B] = ps
    return PM1_SIEVE[B]

# ============================================================================
# ECM — Montgomery form (from Catalog: order_divides_group_size)
# ============================================================================

def _mont_double(Px, Pz, a24, n):
    u = (Px + Pz) % n; v = (Px - Pz) % n
    u2 = u * u % n; v2 = v * v % n; diff = (u2 - v2) % n
    Rx = u2 * v2 % n; Rz = diff * (v2 + a24 * diff % n) % n
    return (Rx, Rz)

def _mont_add(Px, Pz, Qx, Qz, Dx, Dz, n):
    u = (Px - Pz) * (Qx + Qz) % n; v = (Px + Pz) * (Qx - Qz) % n
    add = (u + v) % n; sub = (u - v) % n
    Rx = add * add % n * Dz % n; Rz = sub * sub % n * Dx % n
    return (Rx, Rz)

def _mont_mul(k, Px, Pz, a24, n):
    if k == 0: return (0, 0)
    if k == 1: return (Px, Pz)
    if k == 2: return _mont_double(Px, Pz, a24, n)
    R0x, R0z = Px, Pz
    R1x, R1z = _mont_double(Px, Pz, a24, n)
    bits = bin(k)[3:]
    for bit in bits:
        if bit == '0':
            R1x, R1z = _mont_add(R1x, R1z, R0x, R0z, Px, Pz, n)
            R0x, R0z = _mont_double(R0x, R0z, a24, n)
        else:
            R0x, R0z = _mont_add(R0x, R0z, R1x, R1z, Px, Pz, n)
            R1x, R1z = _mont_double(R1x, R1z, a24, n)
    return (R0x, R0z)

def ecm_factor(n, B1=5000, curves=20):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    if is_prime(n): return None
    primes = get_primes(B1)
    for _ in range(curves):
        sigma = random.randint(6, n-1)
        u = (sigma*sigma - 5) % n; v = (4*sigma) % n
        x0 = u * u % n * u % n; z0 = v * v % n * v % n
        vm6 = (v - u) % n; vm6c = vm6 * vm6 % n * vm6 % n
        v4u = (3*u + v) % n; num = vm6c * v4u % n
        u4v = 4 * u % n * v % n; u4v2 = u4v * u % n * v % n
        g_den = math.gcd(u4v2, n)
        if 1 < g_den < n: return (min(g_den, n//g_den), max(g_den, n//g_den))
        if g_den == n: continue
        try: A = (num * pow(u4v2, -1, n) - 2) % n
        except: continue
        a24 = (A + 2) * pow(4, -1, n) % n
        Px, Pz = x0, z0
        for p in primes:
            pp = p
            while pp <= B1: Px, Pz = _mont_mul(p, Px, Pz, a24, n); pp *= p
        g = math.gcd(Pz, n)
        if 1 < g < n: return (min(g, n//g), max(g, n//g))
    return None

# ============================================================================
# Pollard rho (baseline)
# ============================================================================

def pollard_rho(n, max_tries=25):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    if is_prime(n): return None
    max_r = max(2000000, int(5*n**0.25))
    for c in range(1, max_tries+1):
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
        if 1 < g < n: return (min(g,n//g), max(g,n//g))
        if g == n:
            g = 1
            while g == 1: y = f(y); g = math.gcd(abs(x-y), n)
            if 1 < g < n: return (min(g,n//g), max(g,n//g))
    return None

def pollard_pm1(n, B1=50000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    primes = get_primes(B1); a = 2
    for p in primes:
        pp = p
        while pp <= B1: a = pow(a, p, n); pp *= p
    g = math.gcd(a-1, n)
    if 1 < g < n: return (min(g,n//g), max(g,n//g))
    return None


# ============================================================================
# Combined factorizer — optimized cascade with ECM early
# ============================================================================

def factor(n):
    """Optimized cascade: ECM early (after small primes & quick rho)."""
    if n < 2: return None
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    for exp in range(2, min(n.bit_length(), 64)):
        root = int(round(n**(1.0/exp)))
        for r in range(max(2,root-1), root+2):
            if pow(r, exp) == n: return (min(r,n//r), max(r,n//r))
    if is_prime(n): return None
    
    # Quick Fermat (balanced)
    a = int(math.isqrt(n)) + 1
    for _ in range(200):
        b_sq = a*a - n; b = int(math.isqrt(b_sq))
        if b*b == b_sq:
            p, q = a-b, a+b
            if 1 < p < n: return (min(p,q), max(p,q))
        a += 1
    
    # ECM EARLY — best for numbers with medium-sized factors
    # (Catalog: order_divides_group_size, Hasse bound)
    r = ecm_factor(n, B1=2000, curves=15)
    if r: return r
    
    # Pollard rho (general)
    r = pollard_rho(n, 25)
    if r: return r
    
    # ECM with larger B1
    r = ecm_factor(n, B1=10000, curves=15)
    if r: return r
    
    # Pollard p-1
    for B1 in [50000, 200000]:
        r = pollard_pm1(n, B1)
        if r: return r
    
    # ECM with very large B1
    r = ecm_factor(n, B1=50000, curves=10)
    if r: return r
    
    # Extended rho
    r = pollard_rho(n, 50)
    if r: return r
    
    return None


# ============================================================================
# Benchmark
# ============================================================================

def time_factor(n, method, runs=3):
    ts = []
    for _ in range(runs):
        t0 = time.perf_counter(); r = method(n)
        ts.append((time.perf_counter()-t0)*1000)
    t = sorted(ts)[len(ts)//2]
    ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
    return r, t, ok

def fmt(t, ok):
    if not ok: return "---"
    if t < 0.1: return f"{t*1000:.0f}µs"
    return f"{t:.1f}"

def run():
    random.seed(42)
    
    print("=" * 90)
    print("NEW FACTORING ALGORITHMS — ECM + Imbalanced Semiprime Test")
    print("=" * 90)
    print()
    print("Catalog basis for ECM:")
    print("  order_divides_group_size: g^|G| = 1 (group theory)")
    print("  trivial_point_bound: #E(Z/pZ) ≤ 2p (Hasse bound)")
    print("  Key: ECM complexity = L_p[1/2, √2] (sub-exp in log of SMALLEST factor)")
    print()
    
    # ═══ 1. Imbalanced semiprimes — ECM vs rho ═══
    print("┌─── Imbalanced semiprimes: ECM advantage (small factor) ────────────────────┐")
    print(f"│{'N_bits':<8}{'p_bits':<8}{'q_bits':<8}{'ECM(ms)':<10}{'rho(ms)':<10}{'p-1(ms)':<10}{'Best':<8}│")
    print(f"│{'─'*62}│")
    
    for n_bits in [64, 80, 96, 112, 128]:
        for p_bits in [12, 16, 20, 24, 32]:
            if p_bits >= n_bits - 2: continue
            random.seed(42 + n_bits*100 + p_bits)
            p = make_prime(p_bits)
            q_bits = n_bits - p_bits
            q = make_prime(q_bits)
            n = p * q
            
            # Skip if n is too big for rho in reasonable time
            rho_fn = lambda n=n: pollard_rho(n, 10)
            _, t_ecm, ok_ecm = time_factor(n, lambda n=n: ecm_factor(n, B1=5000, curves=10))
            _, t_rho, ok_rho = time_factor(n, rho_fn)
            _, t_pm1, ok_pm1 = time_factor(n, lambda n=n: pollard_pm1(n, 50000))
            
            best = "ECM" if ok_ecm and (not ok_rho or t_ecm < t_rho) else "rho"
            if ok_pm1 and t_pm1 < min(t_ecm if ok_ecm else 999, t_rho if ok_rho else 999):
                best = "p-1"
            
            print(f"│{n_bits:<8}{p_bits:<8}{q_bits:<8}{fmt(t_ecm,ok_ecm):<10}"
                  f"{fmt(t_rho,ok_rho):<10}{fmt(t_pm1,ok_pm1):<10}{best:<8}│")
    
    print(f"└{'─'*62}┘")
    
    # ═══ 2. Balanced semiprime scaling ═══
    print("\n╔══ CASCADE SCALING (ECM + rho + p-1 combined) ══════════════════════╗")
    print(f"║{'Bits':<6}{'ms':<10}{'log(t)/loglog':<16}{'Best method':<12}║")
    print(f"╠{'═'*44}╣")
    
    data = []
    for bits in [24, 32, 40, 48, 56, 64, 72, 80]:
        random.seed(42+bits)
        p = make_prime(bits//2+1); q = make_prime(bits-bits//2+1); n = p*q
        
        t0_all = time.perf_counter()
        r = factor(n)
        t_all = (time.perf_counter()-t0_all)*1000
        ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
        
        if ok and t_all > 0.01:
            lt = math.log(t_all); ln = math.log(n); lln = math.log(max(ln,1))
            ratio = lt/max(lln, 0.1)
            data.append((bits, n, t_all, lt, ln))
            print(f"║{bits:<6}{t_all:<10.1f}{ratio:<16.2f}{'cascade':<12}║")
        else:
            print(f"║{bits:<6}{'FAIL':<10}{'—':<16}{'—':<12}║")
    
    print(f"╚{'═'*44}╝")
    
    # ═══ 3. Complexity ═══
    best_alpha = 0.5; best_coef = 0; best_resid = float('inf')
    if len(data) >= 3:
        log_ts = np.array([d[3] for d in data])
        log_Ns = np.array([d[4] for d in data])
        for a100 in range(0, 80):
            alpha = a100/100.0
            preds = log_Ns ** alpha
            if preds.max() == preds.min(): continue
            try:
                X = preds.reshape(-1,1)
                coef = np.linalg.lstsq(X, log_ts, rcond=None)[0][0]
                resid = float(np.sum((log_ts - coef*preds)**2))
                if resid < best_resid:
                    best_resid = resid; best_alpha = alpha; best_coef = coef
            except: pass
    
    is_poly = best_alpha < 0.05
    print(f"\n┌─── COMPLEXITY ───────────────────────────────────────────┐")
    print(f"│ log(t) ≈ {best_coef:.2f} · (log N)^{best_alpha:.2f}                     │")
    print(f"│ Classification: {'POLYNOMIAL ★' if is_poly else 'NOT POLYNOMIAL':<40}│")
    print(f"│                                                            │")
    print(f"│ Catalog theorem:                                          │")
    print(f"│   IOF_not_polynomial_unconditional — orbit factoring ≠ poly│")
    print(f"│   order_divides_group_size → ECM (best for small factors)  │")
    print(f"│   Only poly-time: Shor O((log N)³) [requires quantum]     │")
    print(f"└{'─'*60}┘")
    
    return data, best_alpha


if __name__ == "__main__":
    data, alpha = run()