#!/usr/bin/env python3
"""
Residue-redundancy experiment (Factoring round 101): two prime-residue leaks
are not two leaks.

Round 100 raised the frontier question for ResiduePartialFactor: knowing BOTH
p mod M and q mod M (independent per-factor info), can a bivariate lattice break
N^(1/4)? This script shows the two residues are NOT independent -- knowing q mod M
adds no information about p beyond what (p mod M, N) already forces.

CLAIM. Given N=pq and a = p mod M, the second residue b = q mod M is forced:
  N ≡ a*b (mod M)  -- a condition involving ONLY the residues, never the
  unknown quotients x, y in p=a+Mx, q=b+My.
Therefore the set of divisors P|N with P ≡ a (mod M) is UNCHANGED by also
requiring N/P ≡ b (mod M). (Verified directly below, and machine-checked in
ResidueRedundancy.lean.)

We test:
  (1) q mod M is determined by (p mod M, N)  [the forcing];
  (2) the b-filter removes ZERO candidate divisors (no extra information);
  (3) the compatibility condition M | (a*b - N) is automatic for the true pair.
"""
import random
from math import gcd

def is_prime(n):
    if n < 2: return False
    for p in [2,3,5,7,11,13,17,19,23,29,31,37]:
        if n % p == 0: return n == p
    d = n-1; r = 0
    while d % 2 == 0: d //= 2; r += 1
    for a in [2,3,5,7,11,13,17,19,23,29,31,37]:
        x = pow(a, d, n)
        if x in (1, n-1): continue
        for _ in range(r-1):
            x = x*x % n
            if x == n-1: break
        else: return False
    return True
def gen_prime(bits):
    while True:
        p = random.getrandbits(bits) | (1 << (bits-1)) | 1
        if is_prime(p): return p
def divisors(N):
    d = []; i = 1
    while i*i <= N:
        if N % i == 0:
            d.append(i)
            if i != N//i: d.append(N//i)
        i += 1
    return d

def main():
    random.seed(101)
    # (1) q mod M forced by (a, N) when gcd(a,M)=1
    forced = 0; tot = 0
    for _ in range(3000):
        p = gen_prime(14); q = gen_prime(14); N = p*q
        M = random.choice([6,10,12,15,30,210,2310,5,7,11])
        a = p % M
        if gcd(a, M) == 1:
            b_pred = (N * pow(a, -1, M)) % M
            tot += 1; forced += (b_pred == q % M)
    print(f"(1) q mod M determined by (p mod M, N) [gcd=1]: {forced}/{tot}")

    # (2) b-filter removes ZERO candidate divisors (works for ALL M, incl gcd>1)
    same = 0; tot = 0
    for _ in range(3000):
        p = gen_prime(14); q = gen_prime(14); N = p*q
        M = random.choice([6,10,12,15,30,210,2310])
        a = p % M; b = q % M
        candA  = set(P for P in divisors(N) if 1 < P < N and P % M == a)
        candAB = set(P for P in candA if (N//P) % M == b)
        tot += 1; same += (candA == candAB)
    print(f"(2) b-filter removes ZERO candidate divisors: {same}/{tot}")

    # (3) compatibility M | (a*b - N) is automatic
    comp = 0; tot = 0
    for _ in range(3000):
        p = gen_prime(14); q = gen_prime(14); N = p*q
        M = random.choice([6,10,30,210,2310])
        a = p % M; b = q % M
        tot += 1; comp += ((a*b - N) % M == 0)
    print(f"(3) compatibility M | (a*b - N) automatic: {comp}/{tot}")

    print("\nCONCLUSION: knowing BOTH p mod M and q mod M adds ZERO information")
    print("about p beyond p mod M and N alone. The two-residue bivariate attack")
    print("(the open frontier question of round 100) is CLOSED -- not blocked by")
    print("lattice isolation, but by a pure redundancy theorem (machine-checked in")
    print("ResidueRedundancy.lean).")

if __name__ == "__main__":
    main()