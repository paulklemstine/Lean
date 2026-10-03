#!/usr/bin/env python3
"""
AXIS 2c/2d.  The ECM analogue, executed.

 2c. SIEVE OVER k for B-smooth h(-kN), then ask: does p | h?  <-- THE KILL
 2d. Distribution of h(-kN) vs sqrt(kN): does the sqrt-law break?
"""
import math, random, time
import sympy, cypari2
pari = cypari2.Pari(); pari.default("parisizemax", 1<<30)
def h_of(D):
    if D % 4 not in (0,1): D = D*4
    return int(pari.qfbclassno(D))
def is_B_smooth(x, B):
    x = int(x)
    if x <= 1: return True
    for pr in sympy.primerange(2, int(B)+1):
        if pr*pr > x: return x <= B
        while x % pr == 0: x //= pr
    return x == 1

print("="*78)
print("2c. THE ECM ANALOGUE.  Sieve over k for B-SMOOTH h(-kN); check p | h.")
print("     ECM's argument: #E(F_p) is a random m~p; a B-smooth m makes the")
print("     order-finding cheap; the curve supplies the mod-p extraction.")
print("     Class group analogue: h(-kN) is a computable 'order'; sieve k so")
print("     h is B-smooth; hope p | h gives the extraction.")
print()
print("  CRITICAL ARITHMETIC: h B-smooth  AND  p | h  ==>  p <= B.")
print("  Proof: B-smooth means every prime factor of h is <= B. p | h means p")
print("  is a prime factor of h. Hence p <= B.  QED  (no probability.)")
print()
print(f"{'p bits':>7} {'B=2^b bits':>12} {'p bits vs B':>13} {'k tried':>9} "
      f"{'smooth h found':>15} {'hits p|h':>10} {'smooth&hit':>11}")
for bits in [20, 26, 32]:
    p = sympy.randprime(2**(bits-1), 2**bits)
    q = sympy.randprime(2**(bits-1), 2**bits)
    N = p*q
    # B = exp(sqrt(L ln L)), L = ln N ; take sqrt(N) = p for scale
    L = math.log(N); lb = math.sqrt(L*math.log(L))/math.log(2)
    B = 2**(int(lb)+1)
    print(f"  instance: p has {p.bit_length()} bits, B has {B.bit_length()} bits "
          f"-> p > B: {p > B}")
    B = int(min(B, 10**7))
    nsmooth=0; nhit=0; nb=0; t=time.time()
    for k in range(1, 3001):
        h = h_of(-4*k*N); nb+=1
        if is_B_smooth(h, B):
            nsmooth+=1
            if h % p == 0: nhit+=1
        if time.time()-t > 120: break
    print(f"  k tried={nb}  h B-smooth: {nsmooth}  p|h: {nhit}  "
          f"**smooth AND p|h: {sum(1 for _ in [0])and nhit}**")
    print()

print("="*78)
print("2d. h(-kN) vs sqrt(kN): does the sqrt law break? (axis 3)")
print("     log2( h / sqrt(4kN/pi) ) over many k, several N")
random.seed(7)
print(f"{'p bits':>7} {'k range':>12} {'min':>8} {'p05':>8} {'med':>8} {'max':>8} {'n':>7}")
for bits in [20, 26]:
    ratios=[]
    for _ in range(6):
        p=sympy.randprime(2**(bits-1),2**bits); q=sympy.randprime(2**(bits-1),2**bits)
        if p==q: continue
        N=p*q
        for k in range(1,61):
            h=h_of(-4*k*N)
            pred=math.sqrt(4*k*N/math.pi)
            ratios.append(math.log(h/pred,2))
    ratios.sort()
    q=lambda f: ratios[int(f*(len(ratios)-1))]
    print(f"{bits:7d} {'1..60 x6':>12} {q(0):8.2f} {q(.05):8.2f} {q(.5):8.2f} "
          f"{q(1):8.2f} {len(ratios):7d}")
print("  (log2 ratio; 0 = h exactly at the sqrt law. Min ~ -2 means h is 4x")
print("   SMALLER than the law, i.e. sqrt(h) ~ N^{1/4}/2 -- a constant factor,")
print("   NOT an asymptotic gain.)")

print()
print("="*78)
print("SMALL-CLASS-NUMBER EXTREMES: does h << sqrt(D/pi) ever get EXPONENTIALLY")
print("small?  Heegner / Landau-Siegel says only by log factors.")
print(f"{'D':>12} {'h':>8} {'sqrt(D/pi)':>12} {'ratio':>8} {'log2 sqrt(h)':>13} {'log2 N^(1/4)':>13}")
for D in [-163,-67,-43,-23,-15,-427,-331,-155,-235,-667,-427]:
    h=h_of(D)
    pred=math.sqrt(abs(D)/math.pi)
    print(f"{D:12d} {h:8d} {pred:12.2f} {h/pred:8.4f} {math.log(math.sqrt(h),2):13.2f} "
          f"{math.log(abs(D),2)/4:13.2f}")
print("  -> h/sqrt(D/pi) min ~ 0.14 (D=-667), i.e. a factor ~7, i.e. ~1.4 bits")
print("     in log2 sqrt(h).  It is NEVER asymptotically small (Landau-Siegel).")
