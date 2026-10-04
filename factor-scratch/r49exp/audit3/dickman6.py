from math import log
import numpy as np
def Psi_ratio(u, y):
    x=y**u
    isb=np.zeros(x+1, dtype=bool); isb[1]=True
    s=bytearray(b'\x01')*(x+1); s[0]=0
    for p in range(2,y+1):
        if all(p%q for q in range(2,int(p**0.5)+1)):
            pp=p
            while pp<=x:
                s[pp::pp]=b'\x00'*((x-pp)//pp+1); pp*=p
    cnt=sum(s)
    return cnt/x, cnt, x
def rho(u, h=2e-6):
    if u<=1: return 1-log(u) if u>0 else 1.0
    ys=[1.0]; n=int(u/h)+3
    for i in range(1,n+1):
        xv=i*h
        if xv>u: break
        def interp(xx):
            if xx<=0: return 1.0
            j=xx/h; k=int(j)
            if k>=len(ys)-1: return ys[-1]
            f=j-k; return ys[k]*(1-f)+ys[k+1]*f
        ys.append(ys[-1]-interp(xv-1)/xv*h)
    return ys[-1]
print("EXACT Psi(y^u,y)/y^u vs rho(u)  -- the ratio depends on y (finite-y effect):")
for y in [64,256]:
    for u in [2,3]:
        v,c,x=Psi_ratio(u,y)
        print(f"  y={y:4d} u={u}: Psi/x={v:.8f}  rho({u})={rho(u):.8f}  Psi/rho={v/rho(u):8.2f}   (x={x:.3g}, Psi={c})")
print()
print("SELF-TEST: at u=1 exactly, Psi(y,y)/y = 1 and rho(1)=1, so the ratio MUST be 1.000")
v,c,x=Psi_ratio(1,256); print(f"  y=256 u=1: Psi/x={v:.8f} rho(1)={rho(1.0):.8f} ratio={v/rho(1.0):.8f}  {'PASS (null returned)' if abs(v/rho(1.0)-1)<1e-9 else 'FAIL'}")
