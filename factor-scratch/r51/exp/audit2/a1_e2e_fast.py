#!/usr/bin/env python3
"""Fast end-to-end, sieve-based EXACT smoothness.
SELF-TEST: (a) must return False where false is correct; (b) must agree with sympy."""
import random, math, sys
from sympy import factorint

random.seed(20261003)

def primes_upto(n):
    s=bytearray(b'\x01')*(n+1); s[0:2]=b'\x00\x00'
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(2,n+1) if s[i]]

P=primes_upto(2**26+1000)

def is_smooth(n,B):
    """True iff every prime factor <= B. Trial division by ALL primes <= B."""
    if n<=1: return True
    m=n
    for p in P:
        if p>B: break
        if m%p==0:
            while m%p==0: m//=p
            if m==1: return True
    return m==1

def selftest(B):
    # Adversarial inputs must have a prime factor genuinely > B.
    from sympy import nextprime
    q=nextprime(B)
    bad=[q, nextprime(q), 7*nextprime(B), 2**10*3**5*nextprime(B), q*3*5]
    for x in bad:
        assert not is_smooth(x,B), f"returned True on {x} (q={q})"
    assert is_smooth(2**10*3**5,B) and is_smooth(1,B)
    dis=0
    for _ in range(500):
        x=random.randrange(1,2**34)
        mine=is_smooth(x,B); ref=all(p<=B for p in factorint(x))
        if mine!=ref: dis+=1
    print(f"SELFTEST B=2^{B.bit_length()-1}: returns False on all {len(bad)} adversarial inputs; "
          f"sympy cross-check disagreements = {dis}")
    assert dis==0, "predicate disagrees with sympy -- do not trust below"

def run(S,B,npairs=20000,K=200):
    h=t=u=0
    for _ in range(npairs):
        a=random.randrange(-S,S+1); b=random.randrange(-S,S+1)
        v=abs(a*a-b*b*b)
        if v==0: continue
        t+=1; h+=is_smooth(v,B)
        lo,hi=1<<(v.bit_length()-1),1<<v.bit_length()
        for _ in range(K): u+=is_smooth(random.randrange(lo,hi),B)
    return h,t,u

if __name__=="__main__":
    selftest(2**20); print()
    print(f"{'S':>7} {'B':>11} {'u=log2(V)/log2(B)':>18} {'nfs':>8} {'unif':>8} {'delta':>8} {'cost_red':>9}")
    for S,B in [(6000,1000),(20000,1000),(20000,2**16),(30000,2**20),(30000,2**25)]:
        h,t,u=run(S,B); r,ru=h/t,u/t; d=r/ru
        uty=math.log2(S*S)/math.log2(B)
        print(f"{S:>7} {B:>11} {uty:>18.3f} {r:>8.5f} {ru:>8.5f} {d:>8.4f} {(1-1/d)*100:>8.1f}%")
