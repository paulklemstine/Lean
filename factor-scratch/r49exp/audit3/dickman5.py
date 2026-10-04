import math
from math import log
def rho(u):
    if u<=1: return 1-log(u) if u>0 else 1.0
    h=1e-5; n=int(u/h)+3
    ys=[1.0]
    for i in range(1,n+1):
        xv=i*h
        if xv>u+1e-12: break
        def interp(xx):
            if xx<=0: return 1.0
            j=xx/h; k=int(j)
            if k>=len(ys)-1: return ys[-1]
            f=j-k
            return ys[k]*(1-f)+ys[k+1]*f
        ys.append(ys[-1]-interp(xv-1)/xv*h)
    return ys[-1]
def Psi_over_x(u):
    tot=0.0
    for k in range(0,80):
        if u<k: break
        Ik=1.0
        for i in range(1,k+1): Ik*=(u-i)
        tot+=(-1)**k/math.factorial(k)*Ik
    return tot
print("Dickman exact series Psi(x,y)/x with x=y^u  vs  rho(u):")
for u in [2,3,4,5,6,8]:
    v=Psi_over_x(u); r=rho(u)
    print(f"  u={u}: Psi/x={v:.8f}  rho={r:.8f}  Psi/rho={v/r:9.3f}")
