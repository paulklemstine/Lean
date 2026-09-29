#!/usr/bin/env python3
"""THE MEASUREMENT THAT DECIDES IT -- now unblocked by the barrier-1 retraction.

Round47_PricingCorrection.md named this as "the single measurement that decides the
question and it is not made": how does the supply of relations scale with N?  It was not
runnable, because at 40+ bits I could not find a small Q.

But barrier 1 was RETRACTED: for m ~ N^(1/3), m^3 ~ N, so Q = -(m^3 - N) - P*m is
naturally of size N^(1/3), and NFS finds such m by lattice reduction anyway.  So the setup
is available and the measurement can be made.

METHOD, descent-free throughout:
  1. find (m, P, Q) with f(m) = 0 mod N and small P, Q
  2. find ONE rational point of the quartic by brute-force (u,v) search  -- no factorisation
  3. iterate the GROUP LAW alone (ellinit + ellmul; NEVER ellrank, which is the descent that
     needs p and q) to generate <P>
  4. map back and count points by rational height
  5. report the slope  #points(H<=H) / H  as a function of ln N

The audit's N=4189 row is the calibration: its witness sits at (u,v) = (788393, 51900),
so a non-descent search for that ONE relation is a 2.5e12-pair box.  This measures how that
box grows.
"""
from fractions import Fraction as F
from math import gcd, isqrt, log
import cypari2, time, random
PARI = cypari2.Pari(); PARI("default(parisize, 512<<20)")
from sympy import symbols, expand, nextprime
xx = symbols('x')

def gsq(g,P,Q):
    g0,g1,g2=g
    return (g0*g0-2*Q*g1*g2, 2*g0*g1-2*P*g1*g2-Q*g2*g2, 2*g0*g2+g1*g1-P*g2*g2)
def icbrt(n):
    lo,hi=0,1
    while hi**3<=n: hi*=2
    while lo+1<hi:
        mid=(lo+hi)//2
        if mid**3<=n: lo=mid
        else: hi=mid
    return lo
def WE(m,P,Q):
    m,P,Q = F(m),F(P),F(Q)
    return expand((m*xx+m*P/2+Q)**2 + (2*xx-2*m*m-P)*(xx**2/2-P**2/8+m*Q/2))
def to_E(t,y,m,P,Q):
    m,P,Q = F(m),F(P),F(Q)
    x = y+2*t*t+2*m*t
    return x, (2*x-2*m*m-P)*t + (m*x+m*P/2+Q)
def to_quartic(x,Y,m,P,Q):
    m,P,Q = F(m),F(P),F(Q)
    t = (Y-(m*x+m*P/2+Q))/(2*x-2*m*m-P)
    return t, x-2*t*t-2*m*t

def find_setup(N, Pcap=40, Qcap=300):
    """m ~ N^(1/3) with Q = -(m^3+Pm) mod N small.  Q is naturally ~N^(1/3), so this
    succeeds at every size -- that is the barrier-1 retraction in one function."""
    best = None
    for P in range(0, Pcap+1):
        for i in range(0, 4*N.bit_length()*2 + 200):
            m = icbrt(N) + i
            Q = (-(m**3) - P*m) % N
            if Q > N//2: Q -= N
            if abs(Q) <= Qcap:
                return (m, P, Q)
    return None

def one_point(m,P,Q,Hs):
    for v in range(1, Hs+1):
        for u in range(-Hs, Hs+1):
            if gcd(abs(u),v)!=1: continue
            g=(P*v*v-4*u*u,-4*u*v,2*v*v)
            c0,c1,c2=gsq(g,P,Q)
            if c2: continue
            lm=c1*m+c0
            if lm<=0: continue
            w=isqrt(lm)
            if w*w==lm: return F(u,v), F(w,v*v)
    return None,None

def semi(bits, seed):
    random.seed(seed); hp=bits//2
    for _ in range(400):
        p=int(nextprime(random.getrandbits(hp)|(1<<(hp-1))|3))
        q=int(nextprime(random.getrandbits(hp)|(1<<(hp-2))|3))
        if p%4==3 and q%4==3 and p!=q: return p*q
    return None

if __name__=="__main__":
    print(f"{'bits':>5} {'ln N':>7} {'m bits':>7} {'(m,P,Q)':>18} {'Hsearch':>8} "
          f"{'point found':>12} {'H0':>8} {'#<=1e3':>8} {'#<=1e4':>8} {'slope@1e4':>10} {'t':>7}")
    print("-"*112)
    for bits in (20, 32, 48, 64, 96, 128, 192, 256, 384, 512):
        N = semi(bits, 17+bits)
        if N is None: continue
        t0=time.time()
        st = find_setup(N)
        if st is None:
            print(f"{bits:>5} {log(N):>7.1f}   no (m,P,Q) with |Q|<=300"); continue
        m,P,Q = st
        Hs = max(20, min(400, 3*m.bit_length()))
        t_,y_ = one_point(m,P,Q,Hs)
        if t_ is None:
            print(f"{bits:>5} {log(N):>7.1f} {m.bit_length():>7} {str(st):>18} {Hs:>8} "
                  f"{'NONE':>12} {'':>8} {'':>8} {'':>8} {'':>10} {time.time()-t0:>7.1f}")
            continue
        H0 = max(abs(t_.numerator), t_.denominator)
        poly = WE(m,P,Q); a4=int(poly.coeff(xx,1)); a6=int(poly.coeff(xx,0))
        try:
            E = PARI.ellinit([0,0,0,a4,a6])
            x0,Y0 = to_E(t_,y_,m,P,Q)
            G0 = PARI(f"[{x0},{Y0}]")
            cnt = {1000:0, 10000:0}
            for n in range(1,600):
                g = PARI.ellmul(E, G0, n)
                if g==0: continue
                tt,_ = to_quartic(F(str(g[0])), F(str(g[1])), m,P,Q)
                h = max(abs(tt.numerator), tt.denominator)
                for cap in cnt:
                    if h <= cap: cnt[cap]+=1
            print(f"{bits:>5} {log(N):>7.1f} {m.bit_length():>7} {str(st):>18} {Hs:>8} "
                  f"{'yes':>12} {H0:>8} {cnt[1000]:>8} {cnt[10000]:>8} "
                  f"{cnt[10000]/10000:>10.5f} {time.time()-t0:>7.1f}")
        except Exception as e:
            print(f"{bits:>5} {log(N):>7.1f} {m.bit_length():>7} {str(st):>18} {Hs:>8} "
                  f"{'yes':>12} {H0:>8}  ERROR {str(e)[:30]:>8}")
