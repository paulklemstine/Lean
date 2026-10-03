#!/usr/bin/env python3
"""Compact end-to-end: matched-pair design, exact sieve smoothness, B-relative selftest."""
import random, math
from sympy import nextprime
random.seed(20261003)

def primes_upto(n):
    s=bytearray(b'\x01')*(n+1); s[0:2]=b'\x00\x00'
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(2,n+1) if s[i]]
P=primes_upto(2**26)

def is_smooth(n,B):
    if n<=1: return True
    m=n
    for p in P:
        if p>B: break
        if m%p==0:
            while m%p==0: m//=p
            if m==1: return True
    return m==1

q=nextprime(2**20)
assert not is_smooth(q,2**20) and not is_smooth(3*q,2**20) and is_smooth(2**10*3**5,2**20)
print("SELFTEST: predicate returns False on",q,"and 3*"+str(q),"; True on 2^10*3^5 -- OK")

def run(S,B,npairs=6000,K=150):
    h=t=u=0
    for _ in range(npairs):
        a=random.randrange(-S,S+1); b=random.randrange(-S,S+1)
        v=abs(a*a-b*b*b)
        if v==0: continue
        t+=1; h+=is_smooth(v,B)
        lo,hi=1<<(v.bit_length()-1),1<<v.bit_length()
        for _ in range(K): u+=is_smooth(random.randrange(lo,hi),B)
    return h,t,u

print(f"{'S':>6} {'B':>11} {'u':>7} {'nfs':>8} {'unif':>8} {'delta':>7} {'cost_red':>9}")
for S,B in [(6000,1000),(20000,2**16),(30000,2**20)]:
    h,t,u=run(S,B); r,ru=h/t,u/t; d=r/ru
    print(f"{S:>6} {B:>11} {math.log2(S*S)/math.log2(B):>7.3f} {r:>8.5f} {ru:>8.5f} {d:>7.4f} {(1-1/d)*100:>8.1f}%")
