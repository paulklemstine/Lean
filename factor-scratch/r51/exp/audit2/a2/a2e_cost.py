#!/usr/bin/env python3
"""
AXIS 2, decisive cost question.
If h(-kN) is B-smooth, the ORDER-FINDING on the class group is cheap.
Does total = (sieving cost over k) + (order-finding) beat N^{1/4} or L[1/2]?
"""
import math
def L(n): return n*math.log(2.0)
def Lhalf(n): return 0.5*math.sqrt(L(n)*math.log(L(n)))/math.log(2.0)     # log2
def Lthird(n,c=(64/9)**(1/3)): return c*L(n)**(1/3)*math.log(L(n))**(2/3)/math.log(2.0)

print("="*78)
print("MODEL.  To factor via a B-smooth h you need BOTH:")
print("  (S) h(-kN) is B-smooth      -- the ECM-style lottery, sieveable")
print("  (D) p | h(-kN)              -- the extraction (the paper's Q1)")
print("  (S) and (D) TOGETHER force   p <= B   (since p is then a prime factor of h)")
print()
print("So a single k cannot supply both.  Either the lottery is irrelevant or")
print("the divisibility fails.  The ECM mechanism needs them in the SAME group.")
print()
print("Compare: in ECM there is NO requirement (D).  ECM factors p because")
print("E(F_p) has order ~p and the curve ARITHMETIC reduces mod p -- the")
print("extraction is supplied by the group law, not by p | m.  The class group")
print("has no such supplied extraction: Cl(O_D) -> Cl(O_D/p) is trivial")
print("(axis A of the same round, A_classgroup.md S4).  THAT, not smoothness,")
print("is what blocks the route.")
print()
print("="*78)
print("COST OF THE SIEVE, for completeness (does it even matter?).")
print("Sieve over k for B-smooth h(-kN): probability a random h of size ~H is")
print("B-smooth is rho(u) with u = ln H / ln B, H ~ sqrt(kN).")
print(f"{'n':>7} {'B=L[1/2] ln B':>15} {'u=ln H/ln B':>13} {'ln rho(u)':>11} {'-ln rho':>9}")
for n in [256,1024,4096,16384]:
    Ln=L(n); lb=0.5*math.sqrt(Ln*math.log(Ln)); lH=0.5*Ln
    u=lH/lb
    # Dickman: ln rho(u) ~ -u(ln u + ln ln u - 1) + (u ln u + u)/ln u ...
    def ln_rho(u):
        if u<1: return 0.0
        return -u*(math.log(u)+math.log(math.log(u))-1.0) if u>1.0 else 0.0
    lr=ln_rho(u)
    print(f"{n:7d} {lb:15.3f} {u:13.3f} {lr:11.3f} {-lr:9.2f}")
print()
print("  Note -ln rho grows like sqrt(ln N / ln ln N): the sieve over k costs")
print("  MORE than L[1/2] itself.  So even ignoring (D), the ECM-style")
print("  'sieve for smooth order' on the class group is self-defeating:")
print("  it costs >= L[1/2] in log2 to even FIND the k, before any walking.")
print()
print("="*78)
print("SANITY: what fraction of h(-kN) are L[1/2]-smooth, measured?")
import random, sympy, cypari2, time
pari=cypari2.Pari(); pari.default("parisizemax",1<<30)
def h_of(D):
    if D%4 not in (0,1): D=D*4
    return int(pari.qfbclassno(D))
def is_smooth(x,B):
    x=int(x)
    if x<=1: return True
    for pr in sympy.primerange(2,int(B)+1):
        if pr*pr>x: return x<=B
        while x%pr==0: x//=pr
    return x==1
random.seed(1)
p=sympy.randprime(2**19,2**20); q=sympy.randprime(2**19,2**20); N=p*q
Ln=math.log(N); lb=math.exp(0.5*math.sqrt(Ln*math.log(Ln)))
B=int(min(lb,10**7))
ns=0;nt=0
for k in range(1,301):
    h=h_of(-4*k*N); nt+=1
    if is_smooth(h,B): ns+=1
print(f"  p~2^{p.bit_length()-1}, B={B} ({B.bit_length()} bits), p>B: {p>B}")
print(f"  h(-4kN) is B-smooth for {ns}/{nt} values of k  = {ns/nt:.3f}")
print("  -> the lottery is REACHABLE (many smooth h exist). It is only (D) that")
print("     fails.  So the paper's real kill is (D), not the smoothness.")
