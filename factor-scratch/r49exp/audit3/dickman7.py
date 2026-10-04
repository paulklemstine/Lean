import numpy as np
from scipy.integrate import quad
from math import log

def rho(u, h=1e-6):
    """rho(1)=1, rho(u) = 1 - int_1^u rho(t-1)/t dt  (Dickman-de Bruijn)."""
    if u<=0: return 1.0
    N=int(round(u/h))
    g=np.zeros(N+2); g[0]=1.0          # g[i] = rho(i*h)
    for i in range(1,N+1):
        t=i*h
        if t<=1.0:
            g[i]=1.0-log(t)
        else:
            # rho(t-1) by linear interp
            j=(t-1)/h; k=int(j)
            f=j-k
            prev=g[k]*(1-f)+g[k+1]*f
            g[i]=g[i-1]-prev/t*h
    return g[N]

def Psi_ratio(u,y):
    x=y**u
    s=bytearray(b'\x01')*(x+1); s[0]=0
    for p in range(2,y+1):
        if all(p%q for q in range(2,int(p**0.5)+1)):
            pp=p
            while pp<=x:
                s[pp::pp]=b'\x00'*((x-pp)//pp+1); pp*=p
    nonsmooth=sum(s)
    return (x-nonsmooth)/x

print("SELF-TEST FIRST (must return the null where null is correct):")
print(f"  rho(1) = {rho(1.0):.8f}  (must be 1.0)      {'PASS' if abs(rho(1.0)-1)<1e-12 else 'FAIL'}")
print(f"  rho(2) = {rho(2.0):.8f}  (known: 1-ln2 = {1-log(2):.8f})  {'PASS' if abs(rho(2.0)-(1-log(2)))<1e-6 else 'FAIL'}")
v=Psi_ratio(1,256)
print(f"  Psi(y,y)/y at y=256,u=1 = {v:.8f}  (must be 1.0)  {'PASS' if abs(v-1)<1e-12 else 'FAIL'}")
print()
print("EXACT Psi(y^u,y)/y^u vs rho(u):")
for y in [64,256,1024]:
    for u in [2,3]:
        v=Psi_ratio(u,y); r=rho(u)
        print(f"  y={y:5d} u={u}: Psi/x={v:.8f}  rho={r:.8f}  Psi/rho={v/r:8.2f}")
