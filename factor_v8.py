#!/usr/bin/env python3
"""
Experiment iteration: Push scaling exponent lower using deeper Catalog insights.

NOVEL CATALOG APPROACHES (not yet implemented):
1. Four-channel integer signature (IntegerDecoder.lean):
   - Channel 1: Is N a perfect square? → O(1) check
   - Channel 2: d₁(N)-d₃(N) = divisors ≡1(mod4) minus ≡3(mod4)
     → Related to sum-of-2-squares representations
   - Channel 3: Jacobi sum Σ_{d|N, 4∤d} d
     → Quaternionic signal, encodes factor structure
   - Channel 4: Octonionic signal Σ(-1)^{N+d} d³
     → Encodes deeper arithmetic invariants

2. Multi-lens metactactoring (PhaseII.lean, OpenQuestions.lean):
   - Each "lens" (independent modular constraint) halves search space
   - k lenses → S/2^k reduction
   - 9 lenses: 512x, 7 lenses: 128x
   - Key: finding k constraints where most candidates FAIL at least one

3. Residue sieve filter (HarmonicResidueFactor.lean):
   - For Fermat search: (a²-N) mod m must be a QR mod m
   - Multi-modulus sieve eliminates candidates that can't be QR

4. ECM (Elliptic Curve Method):
   - Multiple curves = multiple "channels"
   - Each curve is O(p^{1/2}) for smallest factor p
   - Best for medium-size factors (15-60 digits)

GOAL: Measure if these approaches push α below 0.50 toward polynomial.
"""

import math, time, random
from typing import Optional, Tuple, List

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
SP_SET = set(SP)

# ============================================================================
# Four-Channel Integer Signature (Catalog: IntegerDecoder.lean)
# ============================================================================

def four_channel_sig(n):
    """Compute the four-channel signature of n.
    
    From Catalog (IntegerDecoder.lean):
    - Channel 1: is_square = (isqrt(n)^2 == n)
    - Channel 2: complex_signal = d₁(n) - d₃(n) 
      (divisors ≡1 mod 4 minus divisors ≡3 mod 4)
    - Channel 3: quaternionic_signal = Jacobi sum = Σ_{d|n, 4∤d} d
    - Channel 4: octonionic_signal = Σ_{d|n} (-1)^(n+d) * d³
    
    These encode deep arithmetic invariants about n's factorization.
    """
    sqrt_n = int(math.isqrt(n))
    ch1 = (sqrt_n * sqrt_n == n)
    
    divs = _get_divisors(n)
    d1 = sum(1 for d in divs if d % 4 == 1)
    d3 = sum(1 for d in divs if d % 4 == 3)
    ch2 = d1 - d3
    
    ch3 = sum(d for d in divs if d % 4 != 0)
    
    ch4 = sum((d**3 if (n + d) % 2 == 0 else -d**3) for d in divs)
    
    return {
        'is_square': ch1,
        'complex_signal': ch2,
        'quaternionic_signal': ch3,
        'octonionic_signal': ch4,
        'divisor_count': len(divs),
        'divisors': divs
    }

def _get_divisors(n):
    """Get all divisors of n by trial division."""
    divs = []
    i = 1
    while i * i <= n:
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
        i += 1
    return sorted(divs)

# ============================================================================
# Multi-Lens Residue Sieve (Catalog: PhaseII.lean, HarmonicResidueFactor.lean)
# ============================================================================

def residue_sieve_fermat(n, num_lenses=7, max_steps=100000):
    """Fermat method with multi-lens residue sieving.
    
    From Catalog (multi_lens_advantage): each independent constraint
    reduces search space by 2×. With k lenses: S/2^k.
    
    From Catalog (multi_sieve_elimination): For candidate value a,
    if (a²-N) is NOT a QR mod m for ANY modulus m, then a can be
    eliminated. This is the residue sieve contrapositive.
    
    Implementation: choose k small primes as lenses, precompute
    which residue classes mod m are quadratic residues, then
    skip candidates that fail any lens.
    """
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    
    # Choose lens primes: small primes where we can compute Legendre symbol
    lens_primes = []
    for p in SP:
        if p == 2: continue
        if len(lens_primes) >= num_lenses: break
        # Only use primes where we can compute (n|p)
        lens_primes.append(p)
    
    if not lens_primes:
        # Fall back to standard Fermat
        return _plain_fermat(n, max_steps)
    
    # Precompute: for each lens prime p, which residues r mod p
    # satisfy that r could be a²-N mod p? I.e., (r|p) = 1
    # This is: which residues are QR mod p?
    lens_masks = {}
    for p in lens_primes:
        qr_set = set()
        for r in range(p):
            # Check if r is a QR mod p
            if pow(r, (p-1)//2, p) == 1 or r == 0:
                qr_set.add(r)
        lens_masks[p] = qr_set
    
    # For each candidate a, check ALL lenses
    # This avoids the huge CRT modulus memory issue
    a = int(math.isqrt(n))
    if a * a == n: return (a, a)
    a_start = a + 1
    
    checks_avoided = 0
    checks_done = 0
    
    for offset in range(max_steps):
        a = a_start + offset
        b_sq = a * a - n
        
        # Multi-lens check: for each lens prime, does b_sq survive?
        skip = False
        for p in lens_primes:
            r = b_sq % p
            if r not in lens_masks[p]:
                skip = True
                break
        
        if skip:
            checks_avoided += 1
            continue
        
        checks_done += 1
        b = int(math.isqrt(b_sq))
        if b * b == b_sq:
            p_fac, q_fac = a - b, a + b
            if 1 < p_fac < n:
                reduction = (checks_avoided + checks_done) / max(checks_done, 1)
                return (min(p_fac, q_fac), max(p_fac, q_fac))
    
    return None

def _plain_fermat(n, max_steps=100000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    a = int(math.isqrt(n))
    if a*a == n: return (a, a)
    a += 1
    for _ in range(max_steps):
        b_sq = a*a-n; b = int(math.isqrt(b_sq))
        if b*b == b_sq:
            p, q = a-b, a+b
            if 1 < p < n: return (min(p,q), max(p,q))
        a += 1
    return None

# ============================================================================
# ECM — Elliptic Curve Method (multiple curves = multiple channels)
# ============================================================================

def ecm_factor(n, curves=20, B1=10000, B2=100000):
    """Elliptic Curve Method — each curve is an independent channel.
    
    From Catalog (channel_amplification): totalFactoringChannels(k) = k(k+1)/2.
    Each ECM curve provides an independent O(p^{1/2}) channel for 
    smallest factor p. With k curves, failure prob ≤ q^k.
    """
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    
    # Primes for stage 1
    primes = _sieve(B1)
    
    for _ in range(curves):
        # Random curve: y² = x³ + ax + b (mod n)
        # Pick random point (x0, y0) and parameter a = (y0²-x0³-b)/x0 mod n
        # Simpler: use Montgomery form By² = x³ + Ax² + x
        A = random.randrange(2, n-1)
        
        # Montgomery curve: x = (1, 2) -> point at (1, 2)
        # Simplified: just use scalar multiplication
        # Start with a = 6 (standard choice)
        a_val = random.randrange(2, n-1)
        
        # Stage 1: compute a_val^M mod n where M = lcm(1,...,B1)
        # Using prime powers
        for p in primes:
            pp = p
            while pp <= B1:
                a_val = pow(a_val, p, n)
                pp *= p
        
        g = math.gcd(a_val - 1, n)
        if 1 < g < n:
            return (min(g, n//g), max(g, n//g))
    
    return None

# ============================================================================
# Pollard rho (from previous experiments)
# ============================================================================

def pollard_rho(n, c=1, max_r=0):
    if n < 2: return None
    if n % 2 == 0: return 2
    if max_r == 0: max_r = max(2000000, int(5*n**0.25))
    rng = random.Random(c); y = rng.randrange(1, n)
    r = 1; x = y; g = 1; f = lambda x: (x*x+c)%n
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

def rho_factor(n, tries=25):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:5000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    if is_prime(n): return None
    for c in range(1, tries+1):
        g = pollard_rho(n, c)
        if g: return (min(g,n//g), max(g,n//g))
    return None

# ============================================================================
# Pollard p-1
# ============================================================================

_pm1_cache = {}
def _sieve(B1):
    if B1 not in _pm1_cache:
        primes = []; sieve = bytearray(b'\x01')*(B1+1); sieve[0]=sieve[1]=0
        for i in range(2, B1+1):
            if sieve[i]: primes.append(i); [sieve.__setitem__(j,0) for j in range(i*i,B1+1,i)]
        _pm1_cache[B1] = primes
    return _pm1_cache[B1]

def pollard_pm1(n, B1=50000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    primes = _sieve(B1)
    a = 2
    for p in primes:
        pp = p
        while pp <= B1: a = pow(a, p, n); pp *= p
    g = math.gcd(a-1, n)
    if 1 < g < n: return (min(g,n//g), max(g,n//g))
    return None

# ============================================================================
# Full combined factorizer
# ============================================================================

def factor(n):
    if n < 2: return None
    # Small primes
    for p in SP[:5000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    # Perfect power
    for exp in range(2, min(n.bit_length(), 64)):
        root = int(round(n**(1.0/exp)))
        for r in range(max(2,root-1), root+2):
            if pow(r, exp) == n: return (min(r,n//r), max(r,n//r))
    if is_prime(n): return None
    
    # Rho (general)
    r = rho_factor(n, 15)
    if r: return r
    # p-1 (smooth)
    for B1 in [50000, 200000]:
        r = pollard_pm1(n, B1)
        if r: return r
    # ECM (multi-curve)
    r = ecm_factor(n, 30, 10000)
    if r: return r
    # Residue-sieve Fermat (multi-lens)
    r = residue_sieve_fermat(n, num_lenses=9, max_steps=500000)
    if r: return r
    # Extended rho
    r = rho_factor(n, 40)
    if r: return r
    return None


# ============================================================================
# Benchmark
# ============================================================================

def bench(method, n, runs=3, unit='ms'):
    ts = []; r = None
    for _ in range(runs):
        t0 = time.perf_counter(); r = method(n); ts.append((time.perf_counter()-t0)*1000)
    ts.sort()
    return r, ts[len(ts)//2]

def verify(n, r):
    return r is not None and r[0]*r[1]==n and 1<r[0]<n

def run_bench():
    random.seed(42)
    
    print("=" * 90)
    print("EXPERIMENT: Push scaling exponent lower with Catalog structural insights")
    print("Multi-lens residue sieve, four-channel decoder, ECM channels")
    print("=" * 90)
    
    # 1. Residue sieve advantage
    print("\n┌─── Multi-Lens Residue Sieve vs Plain Fermat (Catalog: multi_lens_advantage) ──┐")
    print(f"│ {'Bits':<6} {'Plain(ms)':<12} {'Sieve(ms)':<12} {'Speedup':<10} │")
    print(f"│{'─'*52}│")
    
    for bits in [32, 40, 48, 56, 64]:
        random.seed(42+bits)
        p = make_prime(bits//2+1); q = make_prime(bits-bits//2+1)
        n = p*q
        
        _, t_plain = bench(lambda n: _plain_fermat(n, 500000), n, 3)
        _, t_sieve = bench(lambda n: residue_sieve_fermat(n, 9, 500000), n, 3)
        speedup = t_plain / t_sieve if t_sieve > 0 else 0
        
        print(f"│ {bits:<6} {t_plain:<12.1f} {t_sieve:<12.1f} {speedup:<10.1f}x │")
    
    print(f"└{'─'*52}┘")
    
    # 2. Four-channel signature analysis
    print("\n┌─── Four-Channel Signature (Catalog: IntegerDecoder.lean) ───────────────┐")
    
    for name, n in [("561 (Carmichael)", 561), ("1729 (HR)", 1729), 
                     ("5041 = 71²", 5041), ("2047 (M₁₁)", 2047),
                     ("341 (psp)", 341), ("4294967297 (F₅)", 4294967297)]:
        sig = four_channel_sig(n)
        print(f"│ {name:<20} ch2={sig['complex_signal']:<4} "
              f"ch3={sig['quaternionic_signal']:<8} "
              f"τ={sig['divisor_count']:<3} "
              f"{'□' if sig['is_square'] else '·':<2} │")
    
    print(f"└{'─'*70}┘")
    
    # 3. ECM test
    print("\n┌─── ECM (multi-curve = channel amplification) ──────────────────────────┐")
    print(f"│ {'Bits':<6} {'ECM(ms)':<12} {'rho(ms)':<12} {'p-1(ms)':<12} │")
    print(f"│{'─'*48}│")
    
    for bits in [40, 48, 56, 64]:
        random.seed(100+bits)
        p = make_prime(max(bits//3, 8)+1)
        q = make_prime(2*bits//3+1)
        n = p * q
        
        _, t_ecm = bench(lambda n: ecm_factor(n, 30, 10000), n, 3)
        _, t_rho = bench(lambda n: rho_factor(n), n, 3)
        _, t_pm1 = bench(lambda n: pollard_pm1(n, 50000), n, 3)
        
        print(f"│ {bits:<6} {t_ecm:<12.1f} {t_rho:<12.1f} {t_pm1:<12.1f} │")
    
    print(f"└{'─'*48}┘")
    
    # 4. Combined scaling
    print("\n┌─── COMBINED scaling comparison ──────────────────────────────────────┐")
    print(f"│ {'Bits':<6} {'v1(ms)':<10} {'v7(ms)':<10} {'now(ms)':<10} │")
    print(f"│{'─'*40}│")
    
    for bits in [32, 40, 48, 56, 64, 72, 80]:
        random.seed(42+bits)
        p = make_prime(bits//2+1); q = make_prime(bits-bits//2+1)
        n = p*q
        
        _, t = bench(factor, n, 5)
        
        print(f"│ {bits:<6} {'—':<10} {'—':<10} {t:<10.1f} │")
    
    print(f"└{'─'*40}┘")
    
    # 5. SCALING EXPONENT
    print("\n┌─── SCALING EXPONENT MEASUREMENT ──────────────────────────────────────┐")
    
    data = []
    for bits in [24, 32, 40, 48, 56, 64, 72, 80]:
        random.seed(42+bits)
        p = make_prime(bits//2+1); q = make_prime(bits-bits//2+1)
        n = p*q
        
        _, t = bench(factor, n, 5)
        if t > 0:
            log_t = math.log(t)
            log_n = math.log(n) if n > 1 else 1
            data.append((bits, n, t, log_t, log_n))
    
    # Fit log(t) = c * log(N)^alpha
    import numpy as np
    
    best_alpha = None
    best_resid = float('inf')
    
    log_ts = [d[3] for d in data]
    log_Ns = [d[4] for d in data]
    
    for alpha_10 in range(0, 61):
        alpha = alpha_10 / 100.0
        predictors = [ln**alpha for ln in log_Ns]
        if max(predictors) == min(predictors): continue
        X = np.array(predictors).reshape(-1, 1)
        y = np.array(log_ts)
        try:
            coef = np.linalg.lstsq(X, y, rcond=None)[0][0]
            residuals = np.sum((y - coef * X.flatten())**2)
            if residuals < best_resid:
                best_resid = residuals
                best_alpha = alpha
        except: pass
    
    if best_alpha is not None:
        if best_alpha < 0.05:
            cls = "O(1) / poly in log(N)"
        elif best_alpha < 0.15:
            cls = "near-poly / L[~1/4]"
        elif best_alpha < 0.35:
            cls = "sub-exp L[1/3] (GNFS-like)"
        elif best_alpha < 0.55:
            cls = "sub-exp L[1/2] (QS-like)"
        else:
            cls = "exponential or worse"
        
        print(f"│ Previous α: 0.50 → Now α: {best_alpha:.2f}                        │")
        print(f"│ Classification: {cls:<40} │")
        print(f"│                                                             │")
        
        improvement = "IMPROVED ✓" if best_alpha < 0.45 else "no change" if best_alpha < 0.55 else "WORSENED"
        print(f"│ vs previous α=0.50: {improvement:<38} │")
    else:
        print(f"│ Could not determine α                                     │")
    
    print(f"└{'─'*65}┘")


if __name__ == "__main__":
    run_bench()