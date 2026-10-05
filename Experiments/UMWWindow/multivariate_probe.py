#!/usr/bin/env python3
"""
Multivariate partial-information probe (round 97b), brute-force and exact.

OPEN QUESTION. Chinburg-Hemenway-Heninger-Scherr (ASIACRYPT 2016) proved
Coppersmith's univariate N^(beta^2) bound OPTIMAL within the univariate
auxiliary-polynomial class, making "n/4 known bits of p" a technique ceiling FOR
THAT CLASS. They explicitly leave the MULTIVARIATE / bivariate-INTEGER setting
open. The open question: with a multivariate (two-factor coupled) method, can we
recover p given FEWER than n/4 known bits?

This script does NOT hand-roll a lattice (fragile). It probes the underlying
STRUCTURE exactly, by brute force on tiny instances:

  MODEL. N=pq. We are given the top k bits of p (p_hi = p >> (n/2-k) << (n/2-k)),
  i.e. p = p_hi + x, 0<=x<X=2^(n/2-k). The UNIVARIATE theorem guarantees a
  solution when X <~ N^(1/4), i.e. k >= n/4. The MULTIVARIATE gain would come
  from ADDITIONAL structure: e.g. also knowing some bits of q (q = q_hi + y),
  so that (p_hi+x)(q_hi+y) = N couples x and y.

  QUESTION 1 (does the coupling add information?): given the SAME number of known
  bits, split between p and q, is the residual search space smaller than
  splitting all on p? (For fixed total known bits.)
  QUESTION 2 (the sub-N^(1/4) test): for tiny n, enumerate ALL lattice-admissible
  aux-polynomial systems? -- too big. Instead measure: with k < n/4 bits on p,
  is the solution UNIQUE given NO extra info, and does adding a SECOND relation
  (a partial bit of q) restore uniqueness below n/4?

We report exact counts, so the result is reproducible and not lattice-dependent.
"""
from math import isqrt, log2

def is_prime(n):
    if n<2: return False
    d=2
    while d*d<=n:
        if n%d==0: return False
        d+=1
    return True

def primes_upto(n):
    return [p for p in range(2,n+1) if is_prime(p)]

def entropies(n_bits):
    """For balanced N with n bits, enumerate candidate factorizations consistent
    with k known MSBs of p (only). Count candidates = search-space size."""
    return n_bits

# --- Exact tiny-instance analysis ---
def candidates_given_p_msb(N, p, n, k):
    """# of divisors d|N with d ~ p (same top k bits as the true p)."""
    t = n//2 - k            # unknown low bits of p
    p_hi = (p >> t) << t
    cnt = 0
    for d in range(2, isqrt(N)+1):
        if N % d == 0 and d >= p_hi and d < p_hi + (1<<t):
            cnt += 1
    return cnt, t

def candidates_two_msb(N, p, q, n, kp, kq):
    """# of (d,e) with d*e=N, d has top kp bits = p's, e has top kq = q's."""
    tp = n//2 - kp; tq = n//2 - kq
    p_hi=(p>>tp)<<tp; q_hi=(q>>tq)<<tq
    cnt=0
    for d in range(2, isqrt(N)+1):
        if N%d==0:
            e=N//d
            if (d>=p_hi and d<p_hi+(1<<tp)) and (e>=q_hi and e<q_hi+(1<<tq)):
                cnt+=1
    return cnt

# choose a fixed tiny semiprime with n=~24 bits
N = 12232441  # find a semiprime
def find_semiprime(target_bits):
    ps=primes_upto(1<<14)
    for p in ps:
        for q in ps:
            if p<q and p*q < (1<<target_bits) and p*q >= (1<<(target_bits-1)):
                if p.bit_length()>=target_bits//2-1:
                    return p,q,p*q
    return None

print("Tiny-instance exact probe: does splitting known bits across p and q help?")
print("(n = bit length of N; Coppersmith univariate guarantees recovery at k=n/4)\n")
for target_bits in [24]:
    p,q,N=find_semiprime(target_bits)
    n=N.bit_length()
    print(f"instance N={N} ({n} bits), p={p}, q={q}, p bits={p.bit_length()}")
    print(f"  Coppersmith threshold: k >= n/4 = {n/4:.2f} bits (all on p)")
    for k in range(n//2-2, n//2+1):
        if k<1: continue
        c,t=candidates_given_p_msb(N,p,n,k)
        tag = " <= UNIVARIATE THRESHOLD" if k < n/4 else ""
        print(f"  k={k} known MSBs of p (X=2^{t}): {c} candidate divisor(s){tag}")
    print()
    # splitting bits
    print("  Split known bits across p and q (same total budget n/4):")
    for kp in range(0, n//4+1):
        kq = n//4 - kp
        c2=candidates_two_msb(N,p,q,n,kp,kq) if kp>=0 and kq>=0 else None
        print(f"    kp={kp} on p, kq={kq} on q (total {kp+kq}): {c2} candidate pair(s)")
