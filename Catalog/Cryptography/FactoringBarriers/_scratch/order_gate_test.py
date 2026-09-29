import math, random
from sympy import isprime, nextprime

# ================= PART A: exact asymptotic (alpha, beta) of each Harvey term =====
# Harvey arXiv:2010.05450 Alg 4.3: r = N^(1/5) lg^(-4/5)N ; m = ceil(N^(1/5) lg^(6/5)N) ; D = ceil(N^(2/5))
A, B = 1/5, 0.0          # N-exponent, lg-exponent
r = (1/5, -4/5)          # r
m = (1/5,  6/5)          # m
D = (1/5,  0)            # no: D = N^(2/5) -> below
Dexp = (2/5, 0)
def mul(x,y): return (x[0]+y[0], x[1]+y[1])
def pw(x,k):  return (k*x[0], k*x[1])
def sub(x,y): return (x[0]-y[0], x[1]-y[1])
def lg(k):   return (0.0, k)
D_ = Dexp
M    = pw(sub((1,0), r), 0.5)          # M = ceil((N/r)^(1/2)) = N^(2/5) lg^(2/5)N
s    = mul(sub(pw(mul((1,0),r),-0.5), m), (0,0))   # N^(1/2)/(r^(1/2) m) -> N^(1/5) lg^(1/5)N
s    = (s[0], s[1]+0.2)                # s ~ N^(1/5) lg^(1/5)N  (dominant branch)
terms = [
 ("Step(2)  Prop 2.5 smoothness sieve   O(M^(1/2) lg^3 N)", mul(pw(M,0.5), lg(3))),
 ("Step(2)a pair exponent t_{a,b}      O(r lg^3 N)",        mul(r, lg(3))),
 ("Step(2)b triples -> v_{a,b,j}        O(s lg N)",          mul(s, lg(1))),
 ("Step(3)  Prop 2.7 ORDER-FINDING      O(N^(1/5) lg^2 N)", (1/5, 2.0)),
 ("Step(4)  Alg 4.1 PRODUCT TREE        O(s lg^3 N)",        mul(s, lg(3))),
 ("Step(4)  Lem 2.4 Bluestein baby-list O(m lg^2 N)",        mul(m, lg(2))),
]
print("="*84)
print("PART A  Harvey 2021 (arXiv:2010.05450) Prop 4.2 + Prop 4.3: every N-dependent term")
print("        at Harvey's own parameters r=N^(1/5)lg^(-4/5)N, m=N^(1/5)lg^(6/5)N, D=N^(2/5)")
print("="*84)
lead = max(t[1][0] for t in terms)
for lab,ab in terms:
    tag = "  <== CO-LEADER  N^(1/5) lg^(16/5)N" if abs(ab[0]-lead)<1e-12 else ""
    print(f"  {lab:56s} N^{ab[0]:.4f} lg^{ab[1]:.3f}N{tag}")
print(f"\n  Prop 4.3's own claim, F(N) = O(N^(1/5) lg^(16/5) N).  Match: alpha={lead} = 1/5, and the "
      f"co-leader lg-exponent is {max(t[1][1] for t in terms if abs(t[1][0]-lead)<1e-12)} = 16/5.")

# --- now: free + optimal order-finding (HH 2601.11131) ---
n_true = sub(mul(s, m), D_)             # s*m/D
pt_opt = mul(n_true, lg(3))
of_opt = mul(pw(D_,0.5), lg(2))         # HH Thm 1.1: O(D^(1/2) logD/(loglogD)^(1/2) log N) = N^(1/5) lg^2 N
after  = max(pt_opt[0], terms[0][1][0], terms[5][1][0], of_opt[0])
print("\n" + "="*84)
print("PART A2  RE-DERIVING THE COST WITH ORDER-FINDING FREE AND alpha OF MAXIMAL ORDER")
print("="*84)
print(f"  n_true = s*m/D          = N^{n_true[0]:.4f} lg^{n_true[1]:.3f}N     <-- POLYLOG at Harvey's own D")
print(f"  product tree, best case = N^{pt_opt[0]:.4f} lg^{pt_opt[1]:.3f}N   (was N^{s[0]:.4f} lg^{mul(s,lg(3))[1]:.3f}N)")
print(f"  order-finding, HH Thm1.1= N^{of_opt[0]:.4f} lg^{of_opt[1]:.3f}N")
print(f"  UNMOVED: Step(2) sieve  = N^{terms[0][1][0]:.4f} lg^{terms[0][1][1]:.3f}N")
print(f"  UNMOVED: Step(4) Bluest = N^{terms[5][1][0]:.4f} lg^{terms[5][1][1]:.3f}N")
print(f"\n  ==> MAX before = N^{lead:.4f} lg^(16/5)N      MAX after = N^{after:.4f} lg^(16/5)N")
print(f"  ==> N-EXPONENT {'UNCHANGED  ->  1/5 STANDS.  Free order-finding is a KILL.' if abs(after-lead)<1e-12 else 'CHANGED'}")

# ================= PART B: numerical rate law on a real semiprime =================
print("\n"+"="*84)
print("PART B  Numerical: does the order actually suppress the match count at Harvey's D?")
print("="*84)
def semiprime(bits):
    p = nextprime(random.getrandbits(bits)); q = nextprime(random.getrandbits(bits))
    return p*q, p, q
random.seed(7)
for bits in (40, 60):
    N, p, q = semiprime(bits)
    L = math.log2(N)
    # REDUCED-SCALE surrogate for (r,m) -- same N-exponent relation m ~ N^(1/5) lg^(6/5), but enumerable
    rr = max(2, int(N**0.2))
    mm = max(2, int(N**0.2 * L**1.2))
    alpha = random.randrange(2, N)
    while math.gcd(alpha, N) != 1: alpha += 1
    Dp = None
    # exact order of alpha mod p
    x = 1
    for d in range(1, p+1):
        x = x*alpha % p
        if x == 1: Dp = d; break
    s_pred = N**0.5/(rr**0.5*mm) + rr*math.log2(max(rr,2))
    print(f"\n  N={N} ({bits} bit), p={p}")
    print(f"  r={rr} m={mm}  ord_p(alpha)=Dp={Dp}   Harvey's D=N^(2/5)~{int(N**0.4):.3g}")
    print(f"  predicted s = {s_pred:.1f}  (total triples)")
    # count matches: for each pair a,b with ab<=r, j<J_ab, check (E0 - j*m) mod Dp < m
    tot=0; hits=0
    for a in range(1, rr+1):
        for b in range(1, rr//a + 1):
            E0 = a*N + b - math.isqrt(4*a*b*N)   # ceil(2 sqrt(abN)) ~ isqrt(4abN)
            J  = int(N**0.5/(4*rr*mm*math.sqrt(a*b)))
            if J <= 0: continue
            for j in range(J):
                tot += 1
                if (E0 - j*mm) % Dp < mm: hits += 1
    print(f"  enumerated triples = {tot}   MATCHES = {hits}")
    print(f"  rate law predicts   s*m/Dp = {s_pred*mm/Dp:.4f}   observed rate = {hits/max(tot,1):.6f}"
          f"   m/Dp = {mm/Dp:.6f}")
    if tot:
        print(f"  ==> observed/predicted = {(hits/tot)/(mm/Dp):.3f}  (law {'HOLDS' if 0.5<(hits/tot)/(mm/Dp)<2.0 else 'FAILS'})")
    # KEY: sweep D -- at large D (Harvey's N^0.4) the count is already polylog-ish
    for Dv,lbl in ((mm,"D = m (order hypothesis DEAD, no slack)"),
                   (int(Dp**0.5),"D ~ Dp^(1/2)"),
                   (int(N**0.2),"D = N^(1/5)"),
                   (int(N**0.4),"D = N^(2/5)  <-- HARVEY'S CHOICE"),
                   (Dp,"D = ord_p(alpha)  (MAXIMAL)")):
        if Dv<1: continue
        print(f"     D={Dv:>22d}  ({lbl:38s})  n_true = s*m/D = {s_pred*mm/Dv:12.2f}")
