import math, random
from sympy import isprime, gcd, nextprime, factorint

def count_revealing(p,q,E,cmap=False,c=1):
    """brute force over a in [1, phi) via residues: count a mod N coprime to N with
       gcd(a^E - c, N) in (p,q).  use CRT product over units (small p,q)."""
    R=[a for a in range(1,p*q) if math.gcd(a,p*q)==1]
    rev=0
    for a in R:
        v=(pow(a,E,p*q)-c)%(p*q)
        g=math.gcd(v,p*q)
        if g==p or g==q: rev+=1
    return rev,len(R)

def formula(p,q,E):
    dp=gcd(E,p-1); dq=gcd(E,q-1)
    return dp*(q-1)+dq*(p-1)-2*dp*dq, (p-1)*(q-1)

print("=== TEST 1: general-E formula R(E)=dp(q-1)+dq(p-1)-2 dp dq  (E=N-1 recovers file) ===")
cases=[(11,13),(23,47),(101,107),(251,419)]
for p,q in cases:
    assert isprime(p) and isprime(q)
    N=p*q
    for E in [N-1, N+1, 2*N+1, 3*N-1, 5*N+1, N]:
        br,phi=count_revealing(p,q,E); f,_=formula(p,q,E)
        f=int(f); br=int(br)
        tag=" <= FILE THEOREM" if E==N-1 else ""
        lbl='N-1' if E==N-1 else ('N+1' if E==N+1 else str(E))
        print(f"  p={p:4d} q={q:4d} E={lbl:8} brute={br:6d} formula={f:6d} {'OK' if br==f else 'MISMATCH'}{tag}")

print()
print("=== TEST 2: the c != 1 claim -- density of a^N - c is MAXIMISED at c = 1 ===")
for p,q in [(23,47),(101,107)]:
    N=p*q; g=gcd(p-1,q-1)
    R1,_=formula(p,q,N-1); R1=int(R1)
    # c in mod-p image of x->x^{N-1}, not in mod-q image: search small c
    best=0
    for c in range(2,40):
        if pow(c,gcd(N-1,p-1),p)!=1: continue   # c not an (N-1)-th power mod p
        if pow(c,gcd(N-1,q-1),q)==1: continue    # but is mod q -> no gain
        # count a with a^{N-1}=c mod p : = dp ; mod q image empty
        best=max(best, int(gcd(N-1,p-1)*(q-1)))
    print(f"  p={p} q={q} g={g}: c=1 reveals {R1}; best c!=1 (one-sided) reveals {best}; ratio c1/best={R1/best:.3f}")
