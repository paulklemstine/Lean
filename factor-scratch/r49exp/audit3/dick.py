"""Dickman rho, forward method-of-steps on a fine grid.
   u*rho'(u) = -rho(u-1)  =>  rho(u) = 1 - int_1^u rho(t-1)/t dt
   The delayed argument is u-1, i.e. 1/H grid steps back.
   NULL branch: rho(u) = 1 for 0 <= u <= 1.  test_dick.py asserts it."""
import numpy as np
H=1e-5; UMAX=40.0
DEL=int(round(1.0/H))
_n=int(UMAX/H)+3
U=np.arange(_n)*H
RHO=np.ones(_n)                # NULL: rho(u)=1 on [0,1]
k0=DEL                        # index of u=1
g=np.zeros(_n); g[k0]=1.0      # g(1)=rho(0)/1=1
for k in range(k0+1,_n):
    gk=RHO[k-DEL]/U[k]
    g[k]=gk
    RHO[k]=RHO[k-1]-0.5*H*(g[k-1]+gk)
def rho(u):
    u=float(u)
    if u<=1.0: return 1.0      # <-- NULL
    if u>UMAX: raise ValueError("outside built grid")
    x=u/H; i=int(x); f=x-i
    return RHO[i]*(1-f)+RHO[i+1]*f
