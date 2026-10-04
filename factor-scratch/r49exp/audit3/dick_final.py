import numpy as np
from math import log

def rho(u, h=1e-6):
    """Dickman rho: rho=1 on [0,1]; 1-ln t on [1,2]; rho'(t)=-rho(t-1)/t for t>2."""
    if u<=0: return 1.0
    N=int(round(u/h)); g=np.ones(N+2)
    for i in range(1,N+1):
        t=i*h
        if t<=1.0: continue
        if t<=2.0: g[i]=1.0-log(t)
        else:
            j=(t-1)/h; k=int(j); f=j-k
            prev=g[k]*(1-f)+g[k+1]*f
            g[i]=g[i-1]-prev/t*h
    return g[N]

def primes_upto(n):
    s=bytearray(b'\x01')*(n+1); s[0]=s[1]=0
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=b'\x00'*((n-i*i)//i+1)
    return [i for i in range(2,n+1) if s[i]]

def Psi_over_x(u,y):
    """n is y-smooth iff no prime in (y,x] divides it."""
    x=int(y**u)
    if x>3_000_000: return None
    ok=np.ones(x+1,dtype=bool); ok[0]=False
    for p in primes_upto(x):
        if p>y: ok[p::p]=False
    return ok.sum()/x

print("=== SELF-TESTS FIRST (null must return where null is correct) ===")
r1=rho(1.0); r2=rho(2.0)
v1=Psi_over_x(1,64)
print(f"  rho(1)      = {r1:.10f}  must be 1            {'PASS' if abs(r1-1)<1e-12 else 'FAIL'}")
print(f"  rho(2)      = {r2:.8f}   must be {1-log(2):.8f}    {'PASS' if abs(r2-(1-log(2)))<1e-6 else 'FAIL'}")
print(f"  Psi(y,y)/y  = {v1:.10f}  must be 1            {'PASS' if abs(v1-1)<1e-12 else 'FAIL'}")
print()
if abs(r1-1)>1e-12 or abs(r2-(1-log(2)))>1e-6 or abs(v1-1)>1e-12:
    print("SELF-TEST FAILED -- results below are NOT trustworthy, not reported as evidence.")
    raise SystemExit(1)
print("=== EXACT Psi(y^u,y)/y^u  vs  rho(u)  (self-tests passed) ===")
for y in [16,32,64]:
    for u in [2,3,4]:
        v=Psi_over_x(u,y)
        if v is None: continue
        r=rho(u)
        print(f"  y={y:3d} u={u}: Psi/x={v:.8f}  rho={r:.8f}   Psi/rho = {v/r:8.3f}")
