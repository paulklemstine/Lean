import math, random, sys
from sympy import isprime, gcd, nextprime
def P(*a): print(*a); sys.stdout.flush()

P("=== TEST 3b: how often does E=N+1 beat E=N-1, and by how much? ===")
random.seed(11); win=0; tot=0; ex=[]
for _ in range(1500):
    p=int(nextprime(random.randint(100,10**6))); q=int(nextprime(random.randint(100,10**6)))
    if p==q: continue
    N=p*q; tot+=1
    a1,a2=int(gcd(N-1,p-1)),int(gcd(N-1,q-1)); b1,b2=int(gcd(N+1,p-1)),int(gcd(N+1,q-1))
    a_=a1*(q-1)+a2*(p-1)-2*a1*a2; b_=b1*(q-1)+b2*(p-1)-2*b1*b2
    if b_>a_:
        win+=1
        if len(ex)<4: ex.append((p,q,a_,b_))
P(f"  N+1 denser on {win}/{tot} random pairs ({100*win/tot:.1f}%)")
for p,q,a_,b_ in ex:
    P(f"    p={p:7d} q={q:7d}  R(N-1)={a_:7d}  R(N+1)={b_:7d}  ratio={b_/a_:.2f}  (phi~{(p-1)*(q-1):.3e})")

P("")
P("=== TEST 5: non-revealers = d_p*d_q exactly (E=N+1, crossed class) ===")
for p,q in [(101,199),(107,317),(109,431)]:
    N=p*q; E=N+1
    dp=int(gcd(E,p-1)); dq=int(gcd(E,q-1)); phi=(p-1)*(q-1)
    R=dp*(q-1)+dq*(p-1)-2*dp*dq
    P(f"  p={p} q={q}: dp={dp:4d} dq={dq:3d}  phi-R={phi-R:6d}  dp*dq={dp*dq:6d}  {'EXACT' if phi-R==dp*dq else 'NO'}")

P("")
P("=== TEST 6: MODERATE-g, c=1, E=N-1. p-1=g*A, q-1=g*B; trials=AB/(A+B-2)~A/2 ===")
for bits in [64,128]:
    p=2**bits
    for beta in [0.25,0.30,0.35,0.40,0.49]:
        A=p/p**beta
        P(f"   g=p^{beta:.2f}, p~2^{bits}: A=(p-1)/g ~ 2^{bits*(1-beta):6.1f} -> trials ~ 2^{bits*(1-beta)/2:6.1f} = N^{0.25*(1-beta):.4f}")

P("")
P("=== TEST 7: head-to-head, same M, Euler (M|p-1,M|q-1) vs Crossed (M|p-1,M|q+1) ===")
p=1019
for M in [2,4,10,20,50,100,1018]:
    q=None; c=M-1 if M>2 else 1
    c=int(nextprime(max(c,2)))
    while c<10**7:
        if c%M==M-1 and isprime(c): q=c; break
        c=int(nextprime(c))
    if q is None: P(f"   M={M}: no prime q = -1 mod M found"); continue
    N=p*q
    g1=int(gcd(p-1,q-1)); g2=int(gcd(p-1,q+1)); g2b=int(gcd(q-1,p+1))
    phi=(p-1)*(q-1)
    R_e=g1*(q-1)+g1*(p-1)-2*g1**2
    R_c=g2*(q-1)+g2b*(p-1)-2*g2*g2b
    P(f"   M={M:5d} p={p} q={q:7d} | Euler g1={g1:5d} trials={phi/max(R_e,1):11.1f}"
      f" | Cross g2={g2:5d} trials={phi/max(R_c,1):8.3f}")
