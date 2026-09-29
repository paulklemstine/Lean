import math, random
from sympy import nextprime, factorint

random.seed(7)
def semiprime(bits):
    p = nextprime(random.getrandbits(bits)); q = nextprime(random.getrandbits(bits))
    while q==p: q = nextprime(random.getrandbits(bits))
    return p*q, p, q

def ord_mod(a, p):                       # exact multiplicative order of a mod prime p
    if a % p == 0: return 0
    o = p-1
    for q,_ in factorint(o).items():
        while o % q == 0 and pow(a, o//q, p) == 1: o //= q
    return o

CAP = 4_000_000
for bits in (36, 44, 52):
    N, p, q = semiprime(bits)
    L = math.log2(N)
    rr = max(2, int(N**0.2)); mm = max(2, int(N**0.2 * L**1.2))
    alpha = random.randrange(2, N)
    while math.gcd(alpha, N) != 1: alpha += 1
    Dp = ord_mod(alpha, p)
    s_pred = N**0.5/(rr**0.5*mm) + rr*math.log2(max(rr,2))
    tot=0; hits=0
    for a in range(1, rr+1):
        for b in range(1, rr//a + 1):
            E0 = a*N + b - math.isqrt(4*a*b*N)
            J  = int(N**0.5/(4*rr*mm*math.sqrt(a*b)))
            if J <= 0: continue
            if tot + J > CAP:
                J = CAP - tot
                if J <= 0: break
            for j in range(J):
                tot += 1
                if (E0 - j*mm) % Dp < mm: hits += 1
            if tot >= CAP: break
        if tot >= CAP: break
    print(f"\nN = {N}  ({bits} bit semiprime)   p = {p}")
    print(f"  r = {rr}   m = {mm}   ord_p(alpha) = Dp = {Dp}   (~N^{math.log2(Dp)/L:.3f})")
    print(f"  predicted s = N^(1/2)/(r^(1/2) m) + r lg r = {s_pred:.1f}")
    print(f"  enumerated triples = {tot}   MATCHES = {hits}")
    if tot:
        obs, pred = hits/tot, mm/Dp
        print(f"  observed rate = {obs:.6f}   m/Dp = {pred:.6f}   ratio = {obs/pred:.3f}"
              f"   ==> RATE LAW {'HOLDS' if 0.5<obs/pred<2.0 else 'FAILS'}")
    print("  -- n_true = s*m/D as the order bound D varies (how much the product tree shrinks) --")
    for Dv,lbl in ((mm,"D = m            (order gate TIGHT, no slack)"),
                   (max(2,int(N**0.2)),"D = N^(1/5)"),
                   (max(2,int(N**0.4)),"D = N^(2/5)     <-- HARVEY'S CHOICE"),
                   (Dp,"D = Dp (MAXIMAL)")):
        if Dv < 1: continue
        print(f"     D = {Dv:>20d}  {lbl:42s}  n_true = s*m/D = {s_pred*mm/Dv:14.3f}")
    print(f"     => between Harvey's D=N^(2/5) and maximal Dp, n_true falls only by a factor "
          f"{Dp/max(2,int(N**0.4)):.3g}  (both are ~polylog)")
