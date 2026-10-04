#!/usr/bin/env python3
"""
Q3: quantify Bernstein batch smoothness at realistic FB sizes.
Use pi(B) ARITHMETICALLY (primecount via sympy) -- enumerating 5.7M primes to
B=1e8 costs 117s and changes nothing: Q3 needs |FB|, not the primes.
Also: MAP the saving onto the constant honestly.
"""
import math, sys
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')

def pi_le(B):
    from sympy import primepi
    return int(primepi(B))

print("="*76)
print("Q3a -- where the cost of NFS relation-finding actually sits")
print("="*76)
print("  cost per candidate = GENERATE (3 mults) + TEST (|FB| trial divisions)")
print(f"{'lnB':>8} {'B':>12} {'|FB|':>10} {'test share':>12} {'gen share':>11}")
for B in [10**3,10**4,10**5,10**6,10**7,10**8,10**9,10**12]:
    fb=pi_le(B)
    ts=fb/(fb+3.0)
    print(f"{math.log(B):>8.3f} {B:>12} {fb:>10} {ts:>12.6f} {1-ts:>11.6f}")
print()
print("  => trial division IS ~the whole cost for any real FB. This CONTRADICTS")
print("     round 52's 0.1% figure, which was measured in the STANGE regime where")
print("     candidate GENERATION is 50-200 modular multiplications, not 3.")
print("     The brief's premise ('test is 0.1% of cost') is a Stange-regime number.")
print()
print("="*76)
print("Q3b -- Bernstein batch smoothness: what saving maps to what constant?")
print("="*76)
print("  Batch smoothness (Bernstein) amortises the smoothness TEST over a range")
print("  of candidates: it replaces |FB| trial divisions PER CANDIDATE with a")
print("  shared sieve.  Model: test cost per candidate  |FB|  ->  |FB|/f  where f")
print("  is the amortisation factor (best case f ~ ln|B|, since the batch sieve")
print("  divides out all primes <= sqrt(B) in one pass).")
print()
print(f"{'B':>12} {'lnB':>7} {'f=lnB':>10} {'speedup':>10} {'f=lnB^2':>11} {'speedup':>10}")
for B in [10**3,10**4,10**5,10**6,10**7,10**8,10**9,10**12]:
    fb=pi_le(B); lnb=math.log(B)
    base=1.0 + fb/3.0                 # cost ratio, gen=1 unit, test=fb/3
    out=[]
    for f in [lnb, lnb**2]:
        new=1.0 + fb/(3.0*f)
        out.append((f, base/new))
    print(f"{B:>12} {lnb:>7.3f} {out[0][0]:>10.2f} {out[0][1]:>10.4f}x {out[1][0]:>11.2f} {out[1][1]:>10.4f}x")
print()
print("="*76)
print("Q3c -- DOES IT MOVE THE CONSTANT?  (the honest mapping)")
print("="*76)
print("  The L[1/3,c] cost is  exp(c L^(1/3) (lnL)^(2/3)).  A saving that removes a")
print("  constant fraction of the PER-CANDIDATE cost divides the TOTAL cost by that")
print("  factor, i.e. c -> c / (factor).  It does NOT change the L^(1/3) EXPONENT.")
print("  So the question is purely: what factor does batching buy?")
print()
print("  From Q3b at NFS operating points (lnB ~ 20-40):")
for B in [10**8,10**9,10**12]:
    fb=pi_le(B); lnb=math.log(B)
    base=1.0+fb/3.0
    s1=base/(1.0+fb/(3.0*lnb)); s2=base/(1.0+fb/(3.0*lnb**2))
    print(f"    B={B:<10} lnB={lnb:5.2f}  f=lnB -> {s1:.4f}x (c: 1.9230 -> {1.9229994271/s1:.4f})"
          f"   f=lnB^2 -> {s2:.4f}x (c -> {1.9229994271/s2:.4f})")
print()
print("  CAVEAT THAT DOMINATES: a constant-factor saving in relation-finding does NOT")
print("  change the L[1/3] CLASS -- it stays L[1/3]. And the standard c already")
print("  assumes the optimal sieve; batching is a constant-factor engineering win,")
print("  exactly analogous to the 8.9x kernel-backend swing measured in PP_droptest.")
