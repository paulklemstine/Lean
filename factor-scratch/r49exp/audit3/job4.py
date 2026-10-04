import math
from mpmath import mp, mpf
mp.dps=40
LN2=math.log(2)
print("=== #522 sec 1.1 table: log2 pi(y) [verify] vs log2 [algorithm] ===")
print("Shoup: y=exp[(1/sqrt2)(ln n lnln n)^{1/2}], runtime=exp[(2 sqrt2)(ln n lnln n)^{1/2}]")
paper={256:(26.5,123.7),1024:(64.0,278.5),2048:(97.4,414.2),4096:(146.5,613.1)}
for bits,(pv,pa) in paper.items():
    L=mpf(bits)*mpf(LN2); S=mpf(math.sqrt(float(L*mp.log(L))))
    ly = S/mpf(math.sqrt(2))/LN2                       # log2 y
    lalg = 2*mpf(math.sqrt(2))*S/LN2                   # log2 runtime
    lpi = ly - math.log2(float(LN2*S/mpf(math.sqrt(2))))  # log2 pi(y) ~ log2(y/ln y)
    print(f"  n={bits:>5}  log2 pi(y): paper={pv:>6} mine={float(lpi):>7.2f} {'OK' if abs(float(lpi)-pv)<0.06 else '**MISMATCH**'}"
          f"   | log2 runtime: paper={pa:>6} mine={float(lalg):>7.2f} {'OK' if abs(float(lalg)-pa)<0.06 else '**MISMATCH**'}")

print()
print("=== #522 sec 3.4: p = 1099511627791 ; paper: p+1 = 2^4*17*241*433*38737 ===")
p=1099511627791
print("  2^40 - 1 =", 2**40-1, " (paper's p is", p, "-> p = 2^40+15, NOT 2^40-1)")
def fac(n):
    d={};m=n
    f=2
    while f*f<=m:
        while m%f==0: d[f]=d.get(f,0)+1; m//=f
        f+=1
    if m>1: d[m]=d.get(m,0)+1
    return d
claim={2:4,17:1,241:1,433:1,38737:1}
pr=1
for k,v in claim.items(): pr*=k**v
print(f"  2^4*17*241*433*38737 = {pr}")
print(f"  p+1 = {p+1}   claimed product = {pr}   match: {pr==p+1}   ratio (p+1)/product = {(p+1)/pr:.9f}")
print("  actual factorisation of p+1:", {k:v for k,v in fac(p+1).items()})
print("  actual factorisation of p-1:", {k:v for k,v in fac(p-1).items()})
print("  paper: 'p-1 carries a 3.7e10 prime factor'. largest prime factor of p-1 =", max(fac(p-1)))
print("  is p prime?", fac(p))

print()
print("=== #522 sec 6: 'The 2*sqrt2 constant in Shoup vs the heuristic sqrt2 is a factor ~2.8' ===")
print("  2*sqrt2 / sqrt2 =", 2*math.sqrt(2)/math.sqrt(2), " <-- the RATIO is exactly 2.0")
print("  2*sqrt2 =", 2*math.sqrt(2), " <-- 2.8 is the VALUE of Shoup's constant, not a factor")
