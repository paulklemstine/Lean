#!/usr/bin/env python3
"""A1 part 2: (a) fix the null harness; (b) decompose zero/nonzero subspace;
(c) identify the extra family appearing at k=7; (d) WHICH k DOMINATES in practice."""
from collections import Counter
import math

def count_pairs(p,k):
    M=p**k; ctr=Counter()
    for a in range(M): ctr[(a*a)%M]+=1
    return sum(ctr[(b*b*b)%M] for b in range(M))

def null_ratio(p,k):
    """Independent uniform residues on the b side. MUST be 1.0."""
    M=p**k; ctr=Counter()
    for a in range(M): ctr[(a*a)%M]+=1
    tot=sum(ctr[(b*7+3)%M] for b in range(M))
    return tot/M                     # ratio = count/M ; uniform gives M -> 1.0

def zero_count(p,k):
    """a^2 = b^3 = 0 mod p^k : a divisible by p^ceil(k/2), b by p^ceil(k/3)."""
    M=p**k
    na = M//(p**math.ceil(k/2)); nb = M//(p**math.ceil(k/3))
    return na*nb

def unit_count(p,k):
    """a,b both coprime to p, a^2 = b^3 mod p^k.  For p odd = phi(p^k)."""
    M=p**k
    return sum(1 for a in range(M) if a%p and (a*a)%M in
               {(b*b*b)%M for b in range(M) if b%p})

print("=== NULL HARNESS (must be 1.0; a broken null = broken instrument) ===")
for p in [2,3,5,7,11,13]:
    for k in range(2,7):
        M=p**k
        if M>1_000_000: continue
        print(f"  p={p:3d} k={k}  null_ratio={null_ratio(p,k):.10f}")
    break
for p in [2,3,5,7]:
    vals=[f"{null_ratio(p,k):.9f}" for k in range(2,6)]
    print(f"  p={p}: k=2..5 null = {vals}")

print()
print("=== DECOMPOSITION: total = zero-subspace + units + (mixed) ===")
print("p  k   total   zero      units    mixed    ratio   (2-1/p)+[p^e-1]  paper-predict")
for p in [3,5,7,11,13]:
    for k in range(2,7):
        M=p**k
        if M>6_000_000: continue
        tot=count_pairs(p,k); z=zero_count(p,k)
        # units count analytically for odd p: phi(p^k)=(p-1)p^(k-1)
        u=(p-1)*p**(k-1)
        r=tot/M
        e=k-math.ceil(k/2)-math.ceil(k/3)
        pred=(1-1.0/p)+p**e
        print(f"{p:3d} {k:3d} {tot:9d} {z:9d} {u:9d} {tot-z-u:7d} {r:9.4f}  {pred:10.4f}   {(2-1.0/p)+(p**e-1):10.4f}")
    print()

print("=== k=7 EXTRA FAMILY: 2i = 3j = 6 with a=p^3 u, b=p^2 v, u,v units, p | u^2-v^3 ===")
for p in [3,5,7]:
    M=p**7; ctr=Counter()
    for a in range(M): ctr[(a*a)%M]+=1
    tot=sum(ctr[(b*b*b)%M] for b in range(M))
    z=zero_count(p,7); u=(p-1)*p**6
    print(f"  p={p}: total={tot} zero={z} units={u} mixed={tot-z-u}  ratio={tot/M:.4f}")
