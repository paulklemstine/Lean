import math, sys
sys.path.insert(0,'.')
from dick import rho
print("=== JOB 5: same cell (29-bit order, B=1000) -- #521 vs CENSUS on 'Dickman there' ===")
u=29.0/math.log2(1000)
print(f"  u = log2(2^29)/log2(1000) = 29/{math.log2(1000):.4f} = {u:.6f}")
print(f"  exact Dickman rho(u)  = {rho(u):.6f}")
print("  #521   line 471 prints : 0.0587")
print("  CENSUS line 429 prints : 0.0648   (used for 'ratio to Dickman 0.963' = 0.0624/0.0648)")
print(f"  discrepancy = {0.0648-rho(u):+.4f} ({100*(0.0648-rho(u))/rho(u):+.1f}%)")
lo,hi=1.5,4.0
for _ in range(200):
    m=(lo+hi)/2
    if rho(m)>0.0648: lo=m
    else: hi=m
print(f"  rho(u)=0.0648 requires u={lo:.4f}  -> B = 2^(29/{lo:.4f}) = 2^{29/lo:.3f} = {2**(29/lo):.1f}  (paper/census say B=1000)")
print(f"  census 0.0624/0.0587 = {0.0624/0.0587:.4f}  vs census's printed 'ratio to Dickman 0.963'")
print()
print("=== CENSUS: 'rho(2)=0.3069 is a lower bound at finite scale. Exact Psi gives 0.3327 at x=1e8' ===")
# rho(2) corresponds to y = x^(1/2) = 10^4
def psi(y,x):
    y=int(y); x=int(x)
    smooth=[0]*(x+1); smooth[0]=1
    for i in range(1,x+1):
        for p in P:
            pass
    return None
# direct count: numbers <= 1e8 that are 10^4-smooth
import sympy as sp
X=10**8; Y=10**4
ps=list(sp.primerange(2,Y+1))
cnt=0
def rec(i,val):
    global cnt
    if i==len(ps): cnt+=1; return
    p=ps[i]; v=val
    while v<=X:
        rec(i+1,v)
        v*=p
    return
rec(0,1)
print(f"  my exact count Psi(10^4, 10^8) = {cnt}  ->  Psi/x = {cnt/X:.6f}")
print(f"  census prints 0.3327 ; rho(2) = {rho(2):.6f}")
print(f"  so Psi/rho = {(cnt/X)/rho(2):.4f}  (Dickman is a LOWER bound here -> {cnt/X > rho(2)})")
print()
print("=== TENSION with #521 lines 79-80 / 482: 'null harness reproduces rho to within 1.43 sigma' ===")
print(f"  if the null harness's target is rho(2)=0.3069 and the exact value is {cnt/X:.4f},")
print(f"  the gap is {100*((cnt/X)-rho(2))/rho(2):.1f}%, which at 1.43 sigma needs a per-cell n of about")
r=(cnt/X-rho(2))/(math.sqrt(rho(2)*(1-rho(2))/n) if False else 1)
n=(( (cnt/X)-rho(2) )/ (1.43*math.sqrt(rho(2)*(1-rho(2)))) )**2
print(f"    n ~ {n:.3g}  -> i.e. the 1.43 sigma claim is only reachable at n of order {n:.0f}; at n<=10^4 it cannot hold")
