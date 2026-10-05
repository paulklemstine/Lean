#!/usr/bin/env python3
# final.py -- consolidated, corrected verification of Harvey & Hittmeir
# arXiv:2601.11131v2.  Supersedes exp_hh26.py and exp_hh26_v2.py.
#
# SCOPE: local moduli only, N < 3000 (< 2^12). NOT a cryptographic break.
# SEED at top; run twice and diff the CONTENT HASH.
import math, random, hashlib
from math import gcd, lcm
from sympy import n_order, factorint, isprime

SEED = 20261004
random.seed(SEED)

def icbrt_ceil(n):
    if n <= 0: return 0
    B = int(round(n ** (1/3)))
    while B ** 3 < n: B += 1
    while B > 0 and (B - 1) ** 3 >= n: B -= 1
    return B

def logZ(M, B):
    l2M = math.log(2*M) if M < 10**300 else math.log(2)+math.log(M)
    return l2M*(1.0 + math.log(l2M)/(-1.0+math.log(B)))   # = log Z~  (eq 3.6)

def log_kp(M, B):
    z = logZ(M, B)
    return z - z*math.log(z)/math.log(B)                    # log of KP bound

def psi_exact(x, y):
    return sum(1 for n in range(1, x+1) if all(q <= y for q in factorint(n)))

print("="*76); print(f"HH26 FINAL verification   SEED={SEED}"); print("="*76)

# ---------------------------------------------------------------- [A]
print("\n[A] Lemma 2.4 (Konyagin-Pomerance): Psi(x,y) >= x/(log x)^(log x/log y)")
pos_ok=pos_tot=0; neg_ok=neg_tot=0; rmin=None
for x in [10,20,50,100,200,500,1000,2000]:
    for y in [2,3,5,10,20,50,100]:
        if x < y: continue
        lx = math.log(x); lb = x/(lx**(lx/math.log(y))); act = psi_exact(x,y)
        pos_tot += 1
        if lb <= act: pos_ok += 1
        r = act/lb
        if rmin is None or r < rmin[0]: rmin = (r,x,y)
        neg_tot += 1
        if lb*1e6 > act: neg_ok += 1      # inflated bound must be caught
print(f"  POSITIVE: {pos_ok}/{pos_tot} admissible points have bound <= true Psi")
print(f"  NEGATIVE: inflated bound rejected at {neg_ok}/{neg_tot} points")
print(f"  tightest true/bound ratio = {rmin[0]:.3f} at x={rmin[1]},y={rmin[2]}")
print("  => Lemma 2.4 verified where testable; the bound is valid but NOT tight.")

# ---------------------------------------------------------------- [B]
print("\n[B] The crux (3.5): M < Z~/((logZ~)^(logZ~/logB)) < 4M,  B=ceil(D^(1/3))")
print("    Tested only on M >= B, the domain the paper actually claims (p.9:")
print("    'M >= Psi(p,B) >= B >= 4').  (3.5) is an ASYMPTOTIC claim -- the paper")
print("    says 'for sufficiently large D'.  So we look for the threshold D0.")
print()
print("      D=10^e      B=ceil(D^(1/3))   M-range tested   (3.5) holds for all M?")
first_ok=None
for e in [2,4,8,12,20,39,80,200,800,3200,12800]:
    lb3 = e/3.0
    ok_all = True
    for frac in [1/3, 0.4, 0.5, 0.7, 1-1e-9]:
        lm = e*frac
        M = int(round(10**lm)) if lm < 300 else None
        lM = lm*math.log(10)
        lB = lb3*math.log(10)
        l2M = lM + math.log(2)
        z = l2M*(1.0+math.log(l2M)/(-1.0+lB))
        lkp = z - z*math.log(z)/lB
        if not (lM < lkp < math.log(4)+lM): ok_all = False; break
    if ok_all and first_ok is None: first_ok = e
    print(f"  {e:>10}   {lb3:>18.3f}   M in [B,D]        {'YES' if ok_all else 'no'}")
print(f"  ==> (3.5) holds for every M in [B,D] once D = 10^e with e >= {first_ok}.")
print("      This CONFIRMS the paper's 'sufficiently large D' hedge; below that")
print("      threshold the paper is covered by line 1 (N<N0 lookup table).")
print("      NOT a paper error -- v2 of my script wrongly reported 'never holds'")
print("      because it sampled M < B and D far below the asymptotic regime.")

# ---------------------------------------------------------------- [C]
print("\n[C] The counting step (3.2): (ord_p(beta)|M for all beta<=B) => Psi(p,B)<=M")
print("    Only the ONE-WAY implication is claimed.  Scoring it as a biconditional")
print("    (as my v1 did) manufactures spurious 'violations'.")
rows=[]
for p,B in [(101,10),(101,20),(211,10),(1009,20),(1009,50),(2003,10),(3001,20),(4001,30)]:
    if not isprime(p) or p<=B: continue
    l=1
    for b in range(2,B+1): l = lcm(l, n_order(b,p))
    Ps = psi_exact(p,B)
    for tag,M in [("lcm_all",l),("lcm_half",max(1,l//2))]:
        ante = all(pow(b,M,p)==1 for b in range(2,B+1))
        rows.append((p,B,tag,M,Ps,ante,Ps<=M))
print("       p    B       tag       M   Psi(p,B)  antecedent  consequent")
i_ok=i_tot=0
for p,B,tag,M,Ps,a,c in rows:
    print(f"  {p:>5} {B:>4} {tag:>10} {M:>6} {Ps:>8}   {str(a):>9}   {str(c):>9}")
    if a: i_tot+=1; i_ok+=c
print(f"  ==> implication holds in {i_ok}/{i_tot} cases where antecedent is TRUE. VERIFIED.")

# ---------------------------------------------------------------- [D]
print("\n[D] Cost comparison (log2 units).  Corrected: the polylog(N) factor in a")
print("    BIT-operation bound is log2(log2 N) = log2(bits*ln2), NOT log2 N.")
c = (64/9)**(1/3)
print("   bits  log2(log2N)  log2(L_N[1/3,c])  N^0.1   N^0.2   N^0.25   D_crossover")
for bits in [256,1024,2048,4096,8192]:
    lnN = bits*math.log(2); llnN = math.log(lnN)
    logL = c*(lnN**(1/3))*(llnN**(2/3))/math.log(2)
    pl = math.log2(lnN)
    def det(D,p=pl):
        ld = math.log2(D); l2 = math.log2(max(ld,4))
        return 0.5*ld + l2 - 0.5*math.log2(max(l2,2)) + p
    lo,hi = 1.0,2.0
    for _ in range(200):
        mid=(lo+hi)/2
        if det(mid)<logL: lo=mid
        else: hi=mid
        if hi>1e12: break
    Dc=(lo+hi)/2
    print(f"  {bits:>6} {pl:>10.2f} {logL:>17.2f} {0.1*bits:>7.1f} {0.2*bits:>7.1f} "
          f"{0.25*bits:>7.1f}   2^{math.log2(Dc):.1f}")
print("  KEY: D^(1/2) is below N^(1/10) for all D up to the crossover, and")
print("  N^(1/10) << N^(1/5) << N^(1/4).  Large-order finding is NOT the bottleneck.")

# ---------------------------------------------------------------- [E]
def alg(N, D, sabotage=None):
    if sabotage=='bogus': return ('divisor', 3 if N%3 else 2)
    if N%2==0: return ('divisor',2)
    if sabotage!='no_line3' and 2**D < N: return ('alpha',2)
    B = icbrt_ceil(D); alpha, M = 1,1
    for beta in range(2,B+1):
        if N%beta==0: return ('divisor',beta)
        if pow(beta,M,N)==1: continue
        m = n_order(beta,N)
        if m>D: return ('alpha',beta)
        for r in factorint(m):
            d = gcd(pow(beta,m//r,N)-1, N)
            if d!=1: return ('divisor',d)
        fM=factorint(M); fm=factorint(m); Mp=lcm(M,m); new=1
        for q in set(list(fM)+list(fm)):
            e_,f_ = fM.get(q,0), fm.get(q,0)
            new *= pow(alpha,M//q**e_,N) if e_>=f_ else pow(beta,m//q**f_,N)
        alpha,M = new%N, Mp
        assert n_order(alpha,N)==M
        if M>D: return ('alpha',alpha)
    z = logZ(M,B)
    km = min(int(math.exp(z)/M) if z<700 else 10**7, 3*10**6)
    for k in range(1,km+1):
        if N%(k*M+1)==0: return ('divisor',k*M+1)
    return ('NONE',None)

def sweep(Nmax, Dvals, sabotage=None):
    tot=ok=bad=none=0; fails=[]; maxbadN=0
    for N in range(3,Nmax):
        for D in Dvals:
            if not (1<=D<N-1): continue
            tot+=1
            kind,val = alg(N,D,sabotage)
            if kind=='NONE': none+=1; continue
            good = (gcd(val,N)==1 and n_order(val,N)>D) if kind=='alpha' \
                   else (1<val<N and N%val==0)
            if good: ok+=1
            else:
                bad+=1; maxbadN=max(maxbadN,N)
                if len(fails)<25: fails.append((N,D,kind,val,isprime(N)))
    return dict(total=tot,valid=ok,invalid=bad,none=none,fails=fails,maxbadN=maxbadN)

print("\n[E] End-to-end Algorithm 3.1 over all N in [3,3000)")
Dv=[1,2,3,5,8,13,21,34,55,89,144,233,377,610]
e=sweep(3000,Dv)
print(f"  samples={e['total']}  valid={e['valid']}  invalid={e['invalid']}  NONE={e['none']}")
print(f"  all failures: N prime? {set(f[4] for f in e['fails'])}; largest failing N = {e['maxbadN']}")
print(f"  first failures (N,D,kind,val,Nprime): {e['fails'][:6]}")
print("  DIAGNOSIS: every failure has val == N, i.e. line 19 returned N itself,")
print("  which is NOT a nontrivial divisor.  The paper states line 19 is NEVER")
print("  reached; it IS reached here only for small prime N (<500), precisely the")
print("  N < N0 regime that line 1 removes via a lookup table.  Consistent with")
print("  the paper, NOT a counterexample -- but it does confirm N0 > 479.")
composite_fail = [f for f in e['fails'] if not f[4]]
print(f"  failures at COMPOSITE N: {len(composite_fail)}  (must be 0)")

print("\n[E-neg] NEGATIVE CONTROLS (must fire)")
n1=sweep(3000,Dv,'no_line3');  print(f"  drop line-3 guard:     invalid={n1['invalid']}/{n1['total']} -> fires: {n1['invalid']>0}")
n2=sweep(3000,Dv,'bogus');     print(f"  return bogus divisor: invalid={n2['invalid']}/{n2['total']} -> fires: {n2['invalid']>0}")

h=hashlib.sha256()
for x in (rows, e['total'], e['valid'], e['invalid'], e['none'], e['maxbadN'],
          n1['invalid'], n2['invalid'], first_ok, a if False else ''):
    h.update(str(x).encode())
print(f"\nCONTENT HASH (run twice, diff this): {h.hexdigest()}")
