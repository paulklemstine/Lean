#!/usr/bin/env python3
"""A2 CORRECTED: the paper's table column 'n' is in BITS (N^{1/4}=64.00 at n=256
implies log2 N = 256).  Redo everything with that convention."""
from math import log, log2, sqrt, exp
import scipy.optimize as so

def Lhalf(N): return exp(sqrt(log(N)*log(log(N))))
def Lthird(N): return exp((log(N)*log(log(N)))**(1/3))

print("=== A2.1  L[1/2] / L[1/3] table of #522 s2.2, n in BITS (all log2) ===")
print(f"{'n(bits)':>8} {'log2 N^1/4':>12} {'paper':>7} {'log2 L[1/2]':>13} {'paper':>8} {'log2 L[1/3]':>13} {'paper':>8}")
for n,p4,ph,pt in [(256,64.00,21.87,46.66),(1024,256.00,49.24,86.77),
                   (4096,1024.00,108.38,156.50),(16384,4096.00,234.90,276.52)]:
    N=2**n
    print(f"{n:>8} {log2(N)/4:>12.2f} {p4:>7} {log2(Lhalf(N)):>13.2f} {ph:>8} {log2(Lthird(N)):>13.2f} {pt:>8}")

print()
print("=== A2.2  ln k = 2 sqrt(L ln L) - L   vs paper's -573/-1217/-2539 ===")
for n,claim in [(1024,-573),(2048,-1217),(4096,-2539)]:
    N=2**n; L=log(N)
    print(f"  n={n:>5} bits: L=ln N={L:>9.3f}  2 sqrt(L ln L)-L = {2*sqrt(L*log(L))-L:>10.2f}   paper says {claim}")

print()
print("=== A2.3  root of L = 4 ln L ===")
roots=[]
xs=[i*1e-4 for i in range(1,40001)]
prev=None
for x in xs:
    f=x-4*log(x)
    if prev is not None and prev*f<0: roots.append(so.brentq(lambda t:t-4*log(t),min(prev,x),max(prev,x)))
    prev=f
print("  roots of L=4 ln L:", [f"{r:.6f}" for r in roots])
r=max(roots)
print(f"  upper root L* = {r:.6f}   (paper says 8.6)")
print(f"  => N < exp(L*) = {exp(r):.2f}      (paper says 5400)")
print(f"  => 2^(L*)      = {2**r:.2f}")

print()
print("=== A2.4  DIRECT check of the boundary: is (kN)^(1/4) > L[1/2] for all k>=1? ===")
print(f"{'n(bits)':>9} {'k=1: N^1/4':>12} {'L[1/2]':>10} {'margin(bits)':>13}")
for n in [5400,4096,1024,256,128,64,32,16]:
    N=2**n
    print(f"{n:>9} {log2(N)/4:>12.2f} {log2(Lhalf(N)):>10.2f} {log2(N)/4-log2(Lhalf(N)):>13.2f}")

print()
print("=== A2.5  the sqrt(pi) constant the paper omits ===")
print("  h(-kN) ~ sqrt(kN)/pi * L(1,chi)  =>  sqrt(h) ~ (kN)^(1/4)/sqrt(pi)")
print("  The omitted 1/sqrt(pi) HELPS the method by log2(sqrt(pi)) = 0.825 bits.")
for n in [256,1024,4096]:
    N=2**n; m=log2(N)/4-log2(Lhalf(N))
    print(f"    n={n:>5}: margin {m:8.2f} -> {m-log2(sqrt(3.141592653589793)):8.2f} after 1/sqrt(pi)")
