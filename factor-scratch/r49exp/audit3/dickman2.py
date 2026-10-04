import math
from math import log, exp
from scipy.integrate import quad
# Dickman rho by solving u*rho'(u) + rho(u-1) = 0 numerically via the standard series/ODE
def rho(u, N=4000, du=0.001):
    # integrate ODE from 0 to u with fine steps
    n=int(u/du)+2
    h=du
    f=[1.0]
    x=0.0
    vals={0.0:1.0}
    def R(xv):
        if xv<=1: return 1.0-log(xv)
        return vals.get(round(xv,6))
    # simple RK-free Euler on y' = -y(u-1)/u with interpolation
    import bisect
    xs=[0.0]; ys=[1.0]
    for i in range(1,n+1):
        xv=i*h
        if xv>u: break
        def interp(xx):
            j=xx/h
            k=int(j)
            if k>=len(xs): return ys[-1]
            f=j-k
            return ys[k]*(1-f)+ys[k+1]*f
        if xv<=1:
            y=1-log(xv)
        else:
            dydx=-interp(xv-1)/xv
            y=ys[-1]+dydx*h
        xs.append(xv); ys.append(y)
    return ys[-1]
def Psi(x,y):
    # count y-smooth <= x
    isb=bytearray(int(x)+1)
    for p in range(2,y+1):
        if all(p%q for q in range(2,int(p**0.5)+1)):
            pp=p
            while pp<=x:
                isb[pp::pp]=b'\x01'*((x-pp)//pp+1)
                pp*=p
    return sum(isb)
for u in [3,4,5,6,8]:
    y=4096; x=y**u
    if x> 4e7: 
        print(f"u={u}: x={x:.3e} too large for exact sieve here"); continue
    P=Psi(x,y); r=rho(u)
    print(f"u={u}: y={y} x={x:.4g} Psi={P} rho={r:.6f} Psi/x={P/x:.6f}  Psi/rho={P/x/r:.2f}")
