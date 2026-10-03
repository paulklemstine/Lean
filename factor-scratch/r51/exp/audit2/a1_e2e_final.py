#!/usr/bin/env python3
"""A1 payoff: size-matched end-to-end measurement of the a^2-b^3 smoothness bias.

Fast exact smoothness via trial division WITH a correct early exit:
  at prime p, if p*p > m then m has no factor < p and is therefore 1 or prime;
  smooth iff m == 1 or m <= B.   (An earlier version returned True here -- that
  was a real bug, caught by the selftest, and it is why this note is in the file.)

NULL ARM: two INDEPENDENT uniform populations under the identical protocol must
give delta ~ 1.0.  If they do not, the instrument is broken and nothing below is trusted.
"""
import random
from math import log2
random.seed(20261003)

def primes_upto(n):
    s=bytearray(b'\x01')*(n+1); s[0:2]=b'\x00\x00'
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(2,n+1) if s[i]]
P=primes_upto(2**19)

def is_smooth(n,B):
    if n<=1: return True
    m=n
    for p in P:
        if p>B: break
        if p*p>m: return m<=B          # m is 1 or a prime
        if m%p==0:
            while m%p==0: m//=p
            if m==1: return True
    return m<=B or m==1

def selftest():
    from sympy import nextprime, factorint
    B=2**18; q=nextprime(B)
    for x in [q,nextprime(q),3*q,5*q,2**10*q]:
        assert not is_smooth(x,B), f"FAIL returned True on {x}"
    for x in [1,2**10*3**5*7,2,3*5*7*11]:
        assert is_smooth(x,B), f"FAIL returned False on {x}"
    dis=0
    for _ in range(400):
        x=random.randrange(1,2**34)
        if is_smooth(x,B)!=all(p<=B for p in factorint(x)): dis+=1
    print(f"SELFTEST predicate: False on 5 adversarial inputs, True on 4 smooth, "
          f"sympy cross-check disagreements={dis}")
    assert dis==0, "predicate disagrees with sympy"

def nfs_arm(S,B,npairs):
    h=t=0
    for _ in range(npairs):
        a=random.randrange(-S,S+1); b=random.randrange(-S,S+1)
        v=abs(a*a-b*b*b)
        if v==0: continue
        t+=1; h+=is_smooth(v,B)
    return h,t

def matched_uniform(strata,B,per):
    """Uniform integers drawn from the SAME dyadic strata as the NFS values."""
    h=0
    for st,c in strata.items():
        for _ in range(per):
            h+=is_smooth(random.randrange(1<<(st-1),1<<st),B)
    return h

if __name__=="__main__":
    selftest()
    # NULL ARM: independent uniform populations, matched protocol
    B=2**13; NP=3000; PER=120
    A=matched_uniform({20:NP},B,PER); C=matched_uniform({20:NP},B,PER)
    d=(A/(NP*PER))/(C/(NP*PER))
    print(f"NULL ARM: two independent uniform arms, delta = {d:.4f}  (must be ~1.00)")
    assert 0.90 < d < 1.10, f"NULL ARM FAILED ({d:.4f}) -- instrument broken"
    print()
    print(f"{'S':>6} {'B':>11} {'u':>7} {'nfs':>9} {'unif':>9} {'delta':>8} {'cost_red':>10}")
    for S,B,NP,PER in [(6000,1000,4000,60),(12000,4096,4000,60),
                       (16000,2**16,4000,50),(20000,2**18,4000,40)]:
        h,t=nfs_arm(S,B,NP)
        from collections import Counter
        # rebuild strata from the same generation (cheap: recompute)
        random.seed(20261003+ (S+B))
        st=Counter()
        for _ in range(NP):
            a=random.randrange(-S,S+1); b=random.randrange(-S,S+1)
            v=abs(a*a-b*b*b)
            if v: st[v.bit_length()]+=1
        u=matched_uniform(st,B,PER)
        nu=sum(st.values())*PER
        r=h/t; ru=u/nu; d=r/ru
        print(f"{S:>6} {B:>11} {log2(S*S)/log2(B):>7.3f} {r:>9.5f} {ru:>9.5f} {d:>8.4f} {(1-1/d)*100:>9.1f}%")
