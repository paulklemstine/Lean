#!/usr/bin/env python3
"""
The rough-semiprime wall (Factoring round 103c): a SECOND, INDEPENDENT route to
the gamma >= 1/2 barrier.

Round 103b identified the true obstruction: ~90% of [1,n] indices are
`n^gamma`-ROUGH (no prime factor <= n^gamma), i.e. semiprimes/prime-powers whose
ALL prime factors are large. Each such index i=p*q can only be covered by a
single difference divisible by i's ENTIRE factorization. So a divisor cover is a
PACKING of rough semiprimes, not a prime count.

This script counts RS(n, n^g) = #{ p<=q primes : p,q > n^g, pq <= n } and
compares to the difference budget k = n^(2g). It measures the EXPONENT
log RS / log n and finds it grows toward 1, so feasibility (k >= RS) needs
2g >= ~1, i.e. g -> 1/2.

THIS RECOVERS, by a completely different argument, the SAME gamma>=1/2 barrier
as the round-96b birthday obstruction -- a strong consistency/unification result.
"""
import math
from sympy import primerange

def count_rs(n, g):
    y = n ** g
    cnt = 0
    for p in primerange(int(y) + 1, int(math.isqrt(n)) + 1):
        cnt += len(list(primerange(p, n // p + 1)))
    return cnt

def main():
    print("Rough-semiprime packing: RS(n,n^g) vs budget k=n^(2g).")
    print("Feasibility (a cover could exist) requires k >= RS.")
    print("n | gamma | #RS | log(RS)/log n | 2g | feasible")
    for n in [10000, 30000, 100000, 300000]:
        for g in [0.34, 0.36, 0.38, 0.39, 0.40, 0.42]:
            rs = count_rs(n, g)
            if rs < 2: continue
            expo = math.log(rs) / math.log(n)
            k = int(n ** (2 * g))
            print(f"  {n:6d} | {g:.3f} | {rs:6d} | {expo:.4f} | {2*g:.4f} | {k >= rs}")
        print()
    print("Theory: RS(n, n^g) = n^(1-o(1)) for fixed g<1/2, so log(RS)/log n -> 1.")
    print("Feasibility then needs 2g >= ~1, i.e. gamma -> 1/2 -- the SAME barrier")
    print("as the round-96b birthday obstruction, recovered independently.")

if __name__ == "__main__":
    main()