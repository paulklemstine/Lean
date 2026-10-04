#!/usr/bin/env python3
"""Where is NFS relation-finding actually RUNNABLE? u = ln(V)/ln(B) must be small."""
import math
from sympy import integer_nthroot
def icbrt(n): return integer_nthroot(n,3)[0]
for bits in [20,24,28,32,40,48,56,64,81,128]:
    L=bits*math.log(2)
    print(f"N=2^{bits:<4} lnN={L:6.2f}  ln(V)=lnN+3lnY  e.g. Y=2^4: {L+3*4*math.log(2):6.2f}")
print()
print("For u<=3 we need ln(V) <= 3 ln(B).  With B=e^lnB:")
for BB in [100,200,500,1000,5000]:
    lnB=math.log(BB)
    print(f"  B={BB:<6} lnB={lnB:5.2f}  max ln(V) for u=3: {3*lnB:6.2f} -> V<= {math.exp(3*lnB):.3g}")
print()
print("NFS optimal ln B ~ (lnN)^(2/3)(lnlnN)^(1/3) * c:")
for bits in [64,128,256,512,1024,2048,4096]:
    L=bits*math.log(2); lnL=math.log(L)
    print(f"  N=2^{bits:<5} lnN={L:7.2f}  ln B_opt ~ {L**(2/3)*lnL**(1/3):7.2f} -> pi(B) ~ {math.exp(L**(2/3)*lnL**(1/3))/ (L**(2/3)*lnL**(1/3)):.3g} primes")
