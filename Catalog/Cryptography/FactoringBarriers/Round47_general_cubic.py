#!/usr/bin/env python3
"""Round 47 part 5 -- the reduction extends to the FULL cubic f = X^3 + P X + Q.

All arithmetic in exact Fractions.  Python's P*P/4 is FLOAT division and it silently
contaminated an entire verification run before it was caught; use F() for every coefficient.

  CONE:  g1^2 + 2 g0 g2 - P g2^2 = 0        (a plane conic, rational point (P/2:0:1))
  g     = ( P v^2 - 4u^2 ,  -4uv ,  2v^2 ),   t = u/v
  l(m)  = 4 v^4 A_P(t),  A_P(t) = 4t^4 + 8mt^3 - 2Pt^2 + (2mP+4Q)t + (P^2/4 - mQ)
  -->  A_P is still a QUARTIC, so the relations are still a genus-1 curve.
  Jacobian:  U = 2x-2m^2-P,  V = mx+mP/2+Q,  W = x^2/2 - P^2/8 + mQ/2,   Y^2 = V^2 + U W
  At P = 0, Q = -c this is EXACTLY  Y^2 = x^3 - 3mc x + c^2 + m^3 c.
"""
from fractions import Fraction as F
from math import isqrt
from sympy import symbols, expand
xx = symbols('x')

def gsq(g, P, Q):
    g0, g1, g2 = g
    return (g0*g0 - 2*Q*g1*g2, 2*g0*g1 - 2*P*g1*g2 - Q*g2*g2,
            2*g0*g2 + g1*g1 - P*g2*g2)

def Ap(t, m, P, Q):
    m, P, Q, t = F(m), F(P), F(Q), F(t)
    return 4*t**4 + 8*m*t**3 - 2*P*t**2 + (2*m*P + 4*Q)*t + (P**2/4 - m*Q)

def gpar(u, v, P):
    return (P*v*v - 4*u*u, -4*u*v, 2*v*v)

def WE(m, P, Q):
    """The cubic Y^2 = V^2 + U W, as a sympy polynomial in x."""
    m, P, Q = F(m), F(P), F(Q)
    U = 2*xx - 2*m*m - P
    V = m*xx + m*P/2 + Q
    W = xx**2/2 - P**2/8 + m*Q/2
    return expand(V**2 + U*W)

def isq(x):
    x = F(x)
    if x < 0: return False
    return (isqrt(x.numerator)**2 == x.numerator and
            isqrt(x.denominator)**2 == x.denominator)

CASES = [(20,2,-2),(20,6,5),(14,11,-207),(19,4,256),(28,108,371),(13,7,368),
         (22,3,263),(5,2,-1),(37,9,385),(12,1,-395),(18,4,-345)]

if __name__ == "__main__":
    ok = bad = 0
    for (m,P,Q) in CASES:
        for v in range(1,8):
            for u in range(-7,8):
                g = gpar(u,v,P); c0,c1,c2 = gsq(g,P,Q)
                assert c2 == 0, "gpar left the cone"
                lm = c1*m + c0
                ok += 1
                if lm != 4*(v**4)*Ap(F(u,v),m,P,Q): bad += 1
    print(f"ID1  l(m) == 4 v^4 A_P(u/v):        {ok} cases, {bad} mismatches")

    ok = bad = 0
    for (m,P,Q) in CASES:
        for v in range(1,8):
            for u in range(-7,8):
                g = gpar(u,v,P); c0,c1,c2 = gsq(g,P,Q); lm = c1*m + c0
                A = Ap(F(u,v),m,P,Q)
                if lm < 0 or A < 0: continue
                ok += 1
                if isq(lm) != isq(A): bad += 1
    print(f"ID2  l(m) square <=> A_P(t) square:  {ok} cases, {bad} mismatches")

    tot = onj = 0
    for (m,P,Q) in CASES:
        mF,Pf,Qf = F(m),F(P),F(Q)
        for v in range(1,9):
            for u in range(-8,9):
                A = Ap(F(u,v),m,P,Q)
                if A < 0: continue
                yn,yd = isqrt(A.numerator), isqrt(A.denominator)
                if yn*yn != A.numerator or yd*yd != A.denominator: continue
                y = F(yn,yd); t = F(u,v)
                xw = y + 2*t*t + 2*mF*t
                U = 2*xw - 2*mF*mF - Pf; V = mF*xw + mF*Pf/2 + Qf
                W = xw*xw/2 - Pf*Pf/8 + mF*Qf/2
                Y = U*t + V
                tot += 1
                if Y*Y == V*V + U*W: onj += 1
    print(f"ID3  quartic points land on the cubic: {onj}/{tot}")

    for (m,c) in [(20,2),(14,207),(19,256),(28,108),(13,368),(22,263)]:
        poly = WE(m, 0, -c)
        cs = {k: poly.coeff(xx,k) for k in (3,2,1,0)}
        good = (cs[3]==1 and cs[2]==0 and cs[1]==-3*m*c and cs[0]==c*c+m**3*c)
        print(f"ID4  m={m:>3} c={c:>4}: == round 47's Y^2=x^3-3mcx+c^2+m^3c ?  {good}")
