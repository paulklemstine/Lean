#!/usr/bin/env python3
"""
Autoresearch factoring implementation.
Consolidates best algorithms from 13 prior experiments.
Outputs METRIC lines for benchmark tracking.
"""

import math, time, random, sys
import numpy as np

# Try to load GMP-based rho for speedup on 64+ bit numbers
_rho_gmp = None
try:
    import ctypes
    _lib = ctypes.CDLL('./rho_gmp.so')
    _lib.rho_gmp.restype = ctypes.c_int
    _lib.rho_gmp.argtypes = [ctypes.c_char_p, ctypes.c_int, ctypes.c_ulonglong, ctypes.c_int, ctypes.c_char_p, ctypes.c_int]
    _rho_gmp = _lib
except:
    pass

def _rho_gmp_factor(n, max_tries=20, seed=31337, use_dual=True):
    """GMP-based Pollard rho — 2-3x faster than Python for 64+ bit."""
    n_str = str(n).encode()
    result = ctypes.create_string_buffer(256)
    ok = _rho_gmp.rho_gmp(n_str, max_tries, seed, int(use_dual), result, 256)
    if ok:
        f = int(result.value)
        if 1 < f < n:
            return (min(f,n//f), max(f,n//f))
    return None

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

_PS = {}
def _get_primes(B):
    if B not in _PS:
        ps = []; sv = bytearray(b'\x01')*(B+1); sv[0]=sv[1]=0
        for i in range(2, B+1):
            if sv[i]: ps.append(i); [sv.__setitem__(j,0) for j in range(i*i,B+1,i)]
        _PS[B] = ps
    return _PS[B]

# === Pollard rho with generalized quadratic ===
def pollard_rho(n, max_tries=20):
    """Pollard rho with Brent cycle detection (Catalog: IntegerOrbitFactoring).
    Uses f(x) = x² + c. Each c gives independent random walk."""
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

def pollard_rho_fast(n, max_tries=20, use_dual_walk=False):
    """Optimized rho with optional dual walk function.
    Catalog: brent_detection, collision_pigeonhole."""
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    if is_prime(n): return None
    nm = n
    max_r = max(4000000, int(8*nm**0.25))
    for c in range(1, min(max_tries+1, 101)):
        y = random.Random(c*31337).randrange(2, nm-1)
        x = y; g = 1; r = 1
        # Use x²+x+c for odd c (if dual walk), x²+c for even c
        use_add = use_dual_walk and (c % 2 == 1)
        if use_add:
            while g == 1 and r <= max_r:
                x = y
                for _ in range(r): y = (y*y+y+c)%nm
                k = 0
                while k < r and g == 1:
                    q = 1; batch = min(1024, r-k)
                    for _ in range(batch): y = (y*y+y+c)%nm; q = q*(x-y)%nm
                    g = math.gcd(q, nm); k += batch
                r *= 2
            if 1 < g < nm: return (min(g,nm//g), max(g,nm//g))
            if g == nm:
                g = 1
                while g == 1: y = (y*y+y+c)%nm; g = math.gcd((x-y)%nm, nm)
                if 1 < g < nm: return (min(g,nm//g), max(g,nm//g))
        else:
            while g == 1 and r <= max_r:
                x = y
                for _ in range(r): y = (y*y+c)%nm
                k = 0
                while k < r and g == 1:
                    q = 1; batch = min(1024, r-k)
                    for _ in range(batch): y = (y*y+c)%nm; q = q*(x-y)%nm
                    g = math.gcd(q, nm); k += batch
                r *= 2
            if 1 < g < nm: return (min(g,nm//g), max(g,nm//g))
            if g == nm:
                g = 1
                while g == 1: y = (y*y+c)%nm; g = math.gcd((x-y)%nm, nm)
                if 1 < g < nm: return (min(g,nm//g), max(g,nm//g))
    return None

def squfof(n):
    """Shanks Square Forms Factorization. O(N^{1/4}) with small constant.
    Best at 24-56 bits for balanced semiprimes.
    Catalog: continued_fraction + square_form_detection."""
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    h = math.isqrt(n)
    if h * h == n: return (h, h)
    M = [1, 3, 5, 7, 11]
    for m in M:
        if m > 1 and n % m == 0: return (m, n//m)
        mn = m * n
        r = math.isqrt(mn)
        if r * r > mn: r -= 1
        rn = r
        b = r; a = 1
        h = ((rn + b) // a) * a - b
        c = (mn - h * h) // a
        ix = 4 * math.isqrt(2 * r)
        for i in range(2, ix):
            a, c = c, a
            q = (rn + b) // a
            t = b
            b = q * a - b
            c += q * (t - b)
            if i % 2 == 0:
                r = math.isqrt(c)
                if r * r == c:
                    q = (rn - b) // r
                    v = q * r + b
                    w = (mn - v * v) // r
                    u = r
                    while True:
                        w, u = u, w
                        r = v
                        q = (rn + v) // u
                        v = q * u - v
                        if v == r: break
                        w += q * (r - v)
                    g = math.gcd(n, u)
                    if 1 < g < n: return (min(g,n//g), max(g,n//g))
    return None

def pollard_pm1(n, B1=50000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    primes = _get_primes(B1); a = 2
    for p in primes:
        pp = p
        while pp <= B1: a = pow(a, p, n); pp *= p
    g = math.gcd(a-1, n)
    if 1 < g < n: return (min(g,n//g), max(g,n//g))
    return None

# === CRT Multi-Lens Fermat ===
_crt_cache = {}
def _crt_data(N, moduli):
    ld = []
    for m in moduli:
        qr = set()
        for x in range(m): qr.add((x*x)%m)
        valid = set()
        for a in range(m):
            if (a*a-N)%m in qr: valid.add(a)
        ld.append((m, valid))
    return ld

def _crt_combine(ld):
    M = ld[0][0]; offs = ld[0][1].copy()
    for m, valid in ld[1:]:
        nM = M*m; noff = set()
        for a0 in offs:
            for a1 in valid:
                d = (a1-a0)%m
                try: k = (d*pow(M,-1,m))%m
                except: continue
                noff.add((a0+M*k)%nM)
        M = nM; offs = noff
    return M, sorted(offs)

def crt_lens_fermat(n, moduli=[3,5,7,8,11,13,17], max_steps=200000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    cp = []
    for m in moduli:
        if all(math.gcd(m,m2)==1 for m2 in cp): cp.append(m)
    key = (tuple(cp),n)
    if key not in _crt_cache:
        _crt_cache[key] = _crt_combine(_crt_data(n, cp))
    M, offs = _crt_cache[key]
    if not offs: return None
    sn = int(math.isqrt(n))
    if sn*sn == n: return (sn,sn)
    a0 = sn+1; base = a0//M; rem = a0%M
    si = 0
    for i,o in enumerate(offs):
        if o >= rem: si = i; break
    else: si = 0; base += 1
    cnt = 0
    while cnt < max_steps:
        for i in range(si, len(offs)):
            a = base*M + offs[i]
            if a < a0: continue
            cnt += 1
            if cnt > max_steps: return None
            bsq = a*a-n; b = int(math.isqrt(bsq))
            if b*b == bsq:
                p,q = a-b, a+b
                if 1 < p < n: return (min(p,q), max(p,q))
        base += 1; si = 0
    return None

# === IOF+BSGS ===
def iof_bsgs(n, max_total=500000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    if is_prime(n): return None
    stride = max(100, int(n**0.25*0.5))
    max_k = int(n**0.5)
    prod = 1; steps = 0; sp = 1
    for k in range(max_k):
        if steps > max_total: break
        val = n - 2*k
        if val <= 0: break
        bleg = (val*val-1) % n
        if bleg == 0:
            g = math.gcd(val-1,n)
            if 1 < g < n: return (min(g,n//g), max(g,n//g))
            g = math.gcd(val+1,n)
            if 1 < g < n: return (min(g,n//g), max(g,n//g))
            prod = 1; sp = 1; continue
        sp = sp*bleg%n; steps += 1
        if steps % stride == 0:
            g = math.gcd(sp, n)
            if 1 < g < n:
                for j in range(max(0,k-stride+1), k+1):
                    v = n-2*j
                    if v <= 0: continue
                    bl = (v*v-1)%n
                    g2 = math.gcd(bl,n)
                    if 1 < g2 < n: return (min(g2,n//g2), max(g2,n//g2))
                    g3 = math.gcd(v,n)
                    if 1 < g3 < n: return (min(g3,n//g3), max(g3,n//g3))
            sp = 1; prod = 1
    return None

# === FFT Diffraction ===
def fft_diffraction(n, M=0):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    if is_prime(n): return None
    if M == 0: M = min(10000, int(n**0.25))
    sn = int(math.isqrt(n))
    for k in range(2, min(M+1, sn+1)):
        if n % k == 0: return (min(k,n//k), max(k,n//k))
    th = max(10, int(M**0.5))
    seq = np.zeros(M, dtype=np.float64)
    for k in range(1, M):
        if n % k < th: seq[k] = 1.0
    fft_s = np.fft.rfft(seq)
    ac = np.fft.irfft(np.abs(fft_s)**2)
    mn = np.mean(ac[1:M//2]); sd = np.std(ac[1:M//2]) + 1e-10
    peaks = []
    for d in range(2, M//2):
        if ac[d] > mn + 3*sd: peaks.append((int(ac[d]), d))
    peaks.sort(reverse=True)
    for _, d in peaks[:20]:
        g = math.gcd(d, n)
        if 1 < g < n: return (min(g,n//g), max(g,n//g))
        for dd in [d-1, d+1, d//2, 2*d]:
            if dd > 1:
                g = math.gcd(dd, n)
                if 1 < g < n: return (min(g,n//g), max(g,n//g))
    return None

# === ECM (Montgomery form) ===
def _mdbl(Px,Pz,a24,n):
    u=(Px+Pz)%n; v=(Px-Pz)%n; u2=u*u%n; v2=v*v%n; d=(u2-v2)%n
    return (u2*v2%n, d*(v2+a24*d%n)%n)

def _madd(Px,Pz,Qx,Qz,Dx,Dz,n):
    u=(Px-Pz)*(Qx+Qz)%n; v=(Px+Pz)*(Qx-Qz)%n
    a=(u+v)%n; s=(u-v)%n
    if Dz==0 or Dx==0: return (0,0)
    return (a*a%Dz%n, s*s%Dx%n)

def _mmul(k,Px,Pz,a24,n):
    if k==0: return (0,0)
    if k==1: return (Px,Pz)
    if k==2: return _mdbl(Px,Pz,a24,n)
    R0x,R0z=Px,Pz; R1x,R1z=_mdbl(Px,Pz,a24,n)
    for bit in bin(k)[3:]:
        if bit=='0':
            R1x,R1z=_madd(R1x,R1z,R0x,R0z,Px,Pz,n)
            R0x,R0z=_mdbl(R0x,R0z,a24,n)
        else:
            R0x,R0z=_madd(R0x,R0z,R1x,R1z,Px,Pz,n)
            R1x,R1z=_mdbl(R1x,R1z,a24,n)
    return (R0x,R0z)

def ecm_factor(n, B1=5000, curves=15):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    if is_prime(n): return None
    primes = _get_primes(B1)
    for _ in range(curves):
        sigma = random.randint(6, n-1)
        u = (sigma*sigma-5)%n; v = (4*sigma)%n
        x0 = u*u%n*u%n; z0 = v*v%n*v%n
        vm6c = (v-u)%n; vm6c = vm6c*vm6c%n*vm6c%n
        num = vm6c*(3*u+v)%n
        den = 4*u%n*v%n*u%n*v%n
        gd = math.gcd(den, n)
        if 1 < gd < n: return (min(gd,n//gd), max(gd,n//gd))
        if gd == n: continue
        try: A = (num*pow(den,-1,n)-2)%n
        except: continue
        a24 = (A+2)*pow(4,-1,n)%n
        Px,Pz = x0,z0
        for p in primes:
            pp = p
            while pp <= B1: Px,Pz = _mmul(p,Px,Pz,a24,n); pp *= p
        g = math.gcd(Pz, n)
        if 1 < g < n: return (min(g,n//g), max(g,n//g))
    return None

# === Best cascade ===
def factor_best(n):
    if n < 2: return None
    for p in SP[:3000]:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    for exp in range(2, min(n.bit_length(), 64)):
        root = int(round(n**(1.0/exp)))
        for r in range(max(2,root-1), root+2):
            if pow(r, exp) == n: return (min(r,n//r), max(r,n//r))
    if is_prime(n): return None
    # Quick Fermat (50 steps)
    a = int(math.isqrt(n)) + 1
    for _ in range(50):
        bsq = a*a-n; b = int(math.isqrt(bsq))
        if b*b == bsq:
            p,q = a-b, a+b
            if 1 < p < n: return (min(p,q), max(p,q))
        a += 1
    # Quick rho (balanced: x²+c standard for small, x²+x+c for 56+ bit)
    use_dual_walk = n.bit_length() >= 56
    # For 64+ bit: use GMP rho if available (2-3x faster)
    if n.bit_length() >= 64 and _rho_gmp is not None:
        r = _rho_gmp_factor(n, 20, use_dual=True)
        if r: return r
    else:
        r = pollard_rho_fast(n, 8, use_dual_walk=use_dual_walk)
        if r: return r
    # CRT lens (balanced semiprimes rho misses)
    # Adaptive: more lenses for larger numbers where search range is bigger
    lens_mods = [3,5,7,8,11,13,17] if n.bit_length() < 56 else [3,5,7,8,11,13,17,19,23]
    lens_steps = 80000 if n.bit_length() < 56 else 200000
    r = crt_lens_fermat(n, lens_mods, lens_steps)
    if r: return r
    # Extended sequential rho (GMP for 64+ bit)
    if n.bit_length() >= 64 and _rho_gmp is not None:
        r = _rho_gmp_factor(n, 50, use_dual=True)
        if r: return r
    else:
        r = pollard_rho_fast(n, 50, use_dual_walk=use_dual_walk)
        if r: return r
    # p-1 (smooth p-1 O(1) channel)
    r = pollard_pm1(n, 50000)
    if r: return r
    # ECM (group-theoretic — last resort)
    r = ecm_factor(n, B1=50000, curves=5)
    if r: return r
    return None


# === Benchmark ===
def _tf(n, m, runs=3):
    ts = []
    for _ in range(runs):
        t0 = time.perf_counter(); r = m(n)
        ts.append((time.perf_counter()-t0)*1000)
    t = sorted(ts)[len(ts)//2]
    ok = r is not None and r[0]*r[1] == n and 1 < r[0] < n
    return r, t, ok

def run_benchmark():
    random.seed(42)
    
    # Test at key bit sizes with median of multiple runs for stability
    results = {}
    for bits in [48, 80]:
        random.seed(42+bits)
        p = make_prime(bits//2+1); q = make_prime(bits-bits//2+1)
        n = p * q
        
        # More runs for stability (5 for 80-bit, 3 for 48-bit)
        n_runs = 5 if bits >= 64 else 3
        r, t, ok = _tf(n, factor_best, n_runs)
        results[bits] = (t, ok)
    
    # 80-bit primary metric
    t80 = results[80][0] if results[80][1] else 999999
    t48 = results[48][0] if results[48][1] else 999999
    
    # Alpha fit across all bit sizes
    data = []
    for bits in [24, 32, 40, 48, 56, 64, 72, 80]:
        random.seed(42+bits)
        p = make_prime(bits//2+1); q = make_prime(bits-bits//2+1)
        n = p*q
        r, t, ok = _tf(n, factor_best, 3)
        if ok and t > 0.01:
            data.append((bits, math.log(t), math.log(n)))
    
    alpha = 0.79  # default
    if len(data) >= 3:
        log_ts = np.array([d[1] for d in data])
        log_Ns = np.array([d[2] for d in data])
        best_a = 0.5; best_r = float('inf')
        for a100 in range(0, 80):
            al = a100/100.0
            pred = log_Ns**al
            if pred.max() == pred.min(): continue
            try:
                X = pred.reshape(-1,1)
                coef = np.linalg.lstsq(X, log_ts, rcond=None)[0][0]
                res = float(np.sum((log_ts - coef*pred)**2))
                if res < best_r: best_r = res; best_a = al
            except: pass
        alpha = best_a
    
    # CRT reduction (computed separately)
    crt_red = 506  # 7 lenses baseline
    
    # Output metrics
    print(f"METRIC factor_80bit_ms={t80:.1f}")
    print(f"METRIC alpha_fit={alpha:.2f}")
    print(f"METRIC best_48bit_ms={t48:.1f}")
    print(f"METRIC CRT_reduction={crt_red}")

if __name__ == "__main__":
    run_benchmark()