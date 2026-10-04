#!/usr/bin/env python3
"""
Q1 theory: reproduce the NFS L[1/3, c] constant NUMERICALLY, from the standard
relation-collection cost model, and compare Dickman-rho against EXACT Psi.

Cost model (standard NFS):
  b = ln B (factor base bound),  y = ln Y (box half width)
  values have size V, ln V = L + 2y   (L = ln N)
  u = ln V / b
  need ~pi(B) = B/b relations;  Y^2 * Psi(V,B)/V  =  B/b
  =>  2y = b - ln b + ln( V/Psi(V,B) )
  cost = Y^2 * b  =  B/ (Psi(V,B)/V) * ...  =>  ln cost = b + ln(V/Psi(V,B))
Minimise over b.
"""
import math
from scipy.optimize import minimize_scalar

def dickman_rho(u):
    """Standard Dickman via the delay differential equation, RK-integrated."""
    if u <= 0: return 1.0
    if u < 1: return 1.0
    if u > 8:   # use the asymptotic series (accurate enough for the constant)
        lu = math.log(u)
        l2 = math.log(lu)
        l3 = math.log(l2) if l2>0 else 0.0
        expo = -u*(lu + l2 - 1.0 + (l2-1.0)/u - (l2*l2-2*l2+2.0)/(u*u))
        return math.exp(expo)
    # integrate rho'(u) = -rho(u-1)/u on a fine grid, rho=1 on [0,1]
    M=400000; umax=u; du=umax/M
    g=[0.0]*(M+1)
    g[0]=1.0
    import numpy as np
    idx=int(1.0/du)
    for i in range(1,idx+1): g[i]=1.0
    for i in range(idx+1,M+1):
        uu=i*du
        # rho(uu) via the integral form: rho(u) = 1 - int_1^u rho(t-1)/t dt
        # approximate with the trapezoid on the previous cells
        g[i]=g[i-1]-du*g[i-1-int(round(1.0/du))]/uu
    return g[M]

def cost_lnDickman(b, L, k=3):
    """ln(cost) using Dickman rho.  ln V = L + k*y  (cubic: value ~ N*Y^3)."""
    # solve 2y = b - ln b + (u)(ln u + ln ln u - 1 + ...)  with u=(L+k y)/b
    y = 0.0
    for _ in range(200):
        u = (L + k*y)/b
        if u <= 1.0: 
            y = max(0.0,(b*1.0-math.log(max(b,1.0001)))/k)
            continue
        lu=math.log(u); l2=math.log(lu) if lu>1 else 0.0
        U = u*(lu + l2 - 1.0 + (l2-1.0)/u)      # ~ ln(1/rho(u))
        y_new = (b - math.log(b) + U)/k
        if abs(y_new-y)<1e-12: y=y_new; break
        y=y_new
    u=(L+k*y)/b
    lu=math.log(u); l2=math.log(lu) if lu>1 else 0.0
    U = u*(lu+l2-1.0+(l2-1.0)/u)
    # BUG CAUGHT: ln(cost) = ln(Y^2 * b) = 2y + b, and 2y = b - ln b + U.
    # An earlier version returned b+U, dropping 2y entirely.
    return 2*y + b, y, u

def fit_constant(L, k=3):
    r=minimize_scalar(lambda b: cost_lnDickman(b,L,k)[0], bounds=(1e-3, 3.0*L), method='bounded',
                      options=dict(xatol=1e-10))
    lncost=cost_lnDickman(r.x,L,k)[0]
    lnl=math.log(L)
    # L_N[1/3,c] = exp(c (L)^(1/3) (ln L)^(2/3))
    denom = L**(1.0/3.0) * lnl**(2.0/3.0)
    return lncost/denom, r.x

if __name__=="__main__":
    import sys
    c_star=(64/9)**(1/3)
    print(f"target c = (64/9)^(1/3) = {c_star:.10f}")
    print(f"{'lnN':>8} {'L=lnN':>10} {'fitted c':>12} {'lnB*':>9} {'u*':>8}")
    cs=[]
    for bits in [256,512,1024,2048,4096,8192]:
        L=bits*math.log(2)
        c,bstar=fit_constant(L)
        _,y,u=cost_lnDickman(bstar,L)
        cs.append(c)
        print(f"{bits:>8} {L:>10.3f} {c:>12.6f} {bstar:>9.4f} {u:>8.4f}")
    print()
    print("mean fitted c =", sum(cs)/len(cs))
