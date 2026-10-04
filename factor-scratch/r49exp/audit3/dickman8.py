import numpy as np
from math import log

def rho(u, h=1e-6):
    """rho(t)=1 for 0<=t<=1; 1-ln t for 1<=t<=2; rho'(t) = -rho(t-1)/t for t>2."""
    if u<=0: return 1.0
    N=int(round(u/h))
    g=np.ones(N+2)                    # g[i]=rho(i*h); rho=1 on [0,1]
    for i in range(1,N+1):
        t=i*h
        if t<=1.0: continue
        if t<=2.0: g[i]=1.0-log(t)
        else:
            j=(t-1)/h; k=int(j); f=j-k
            prev=g[k]*(1-f)+g[k+1]*f
            g[i]=g[i-1]-prev/t*h
    return g[N]

def Psi_ratio(u,y):
    """Psi(y^u,y)/y^u : n is y-smooth iff no prime in (y,x] divides it."""
    x=int(y**u)
    ok=np.ones(x+1, dtype=bool); ok[0]=False
    prime=np.ones(x+1, dtype=bool); prime[0]=prime[1]=False
    for i in range(2,int(x**0.5)+1):
        if prime[i]:
            prime[i*i::i]=False
            prime[2*i::i]=False
    for p in range(y+1, x+1):
        if prime[p]: ok[p::p]=False
    return ok.sum()/x

print("SELF-TEST FIRST (must return the null where null is correct):")
print(f"  rho(1)={rho(1.0):.10f} (must be 1)          {'PASS' if abs(rho(1.0)-1)<1e-12 else 'FAIL'}")
print(f"  rho(2)={rho(2.0):.8f} (must be {1-log(2):.8f})  {'PASS' if abs(rho(2.0)-(1-log(2)))<1e-6 else 'FAIL'}")
print(f"  Psi(y,y)/y (u=1,y=64)={Psi_ratio(1,64):.10f} (must be 1)  {'PASS' if abs(Psi_ratio(1,64)-1)<1e-12 else 'FAIL'}")
print()
print("EXACT Psi(y^u,y)/y^u  vs  rho(u):")
for y in [64,256]:
    for u in [2,3,4]:
        v=Psi_ratio(u,y); r=rho(u)
        print(f"  y={y:4d} u={u}: Psi/x={v:.8f}  rho={r:.8f}   Psi/rho = {v/r:8.3f}")
