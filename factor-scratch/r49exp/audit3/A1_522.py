from math import log, exp
from scipy.optimize import brentq
# claimed: ln k = 4 sqrt(L ln L) - L  ;  boundary 16 ln L = L
f=lambda L: 4*log(L)-L
Lstar=brentq(f,10,1000)
print(f"L* solving 16 ln L = L : {Lstar:.6f}   paper says 67.361  -> {'MATCH' if abs(Lstar-67.361)<1e-3 else 'MISMATCH'}")
print(f"N* = e^L* = {exp(Lstar):.6e}   paper says 1.797e29 -> {'MATCH' if abs(exp(Lstar)-1.797e29)/1.797e29<1e-3 else 'MISMATCH'}")
print()
print("ln k values claimed: -436.7 at n=1024")
for bits in [1024]:
    L=bits*log(2)
    lk=4*(L*log(L))**0.5-L
    print(f"  n=2^{bits}: L={L:.4f}  ln k = {lk:.1f}   paper says -436.7 -> {'MATCH' if abs(lk+436.7)<1.0 else 'MISMATCH'}")
print()
print("L-table (s34 area) -- recompute 16 ln L vs L:")
for L in [10,20,30,50,67.361,100,200,500,1000]:
    print(f"  L={L:8.3f}  16 ln L={16*log(L):9.3f}  L={L:8.3f}  16lnL<L? {'YES(excluded)' if 16*log(L)<L else 'NO'}")
