#!/usr/bin/env python3
"""
The CORRECT semiprime obstruction: a PAIR-COVERING DESIGN (audit of r103c).
Factoring round 105.

Round 103c concluded "gamma -> 1/2" but with a WRONG premise ("each rough
semiprime needs its own difference"). The correct argument is a covering-design
one, and it reaches the SAME threshold via a cleaner mechanism.

SETUP. A divisor cover has b = n^(2g) differences, each d <= M = exp(n^g).
  - Let P = primes in (n^g, n], v = |P| ~ n/ln n.
  - A difference d contains at most k ~ n^g/ln n primes of P (product of r
    such primes ~ n^r <= exp(n^g) => r <= n^g/ln n).
  - To cover a rough semiprime target i = p*q (p,q in P, pq<=n), the difference
    must contain BOTH p and q. So the prime set of each difference is a BLOCK
    of size ~k, and the collection of blocks must COVER every relevant PAIR.
  => a set-pair-covering design C(v, k, 2).

BLOCKS NEEDED. The standard pair-covering (Schonheim) lower bound:
  b >= C(v,2) / C(k,2)  ~  (v/k)^2  =  (n^{1-g})^2 = n^{2-2g}.
BUDGET. b <= n^{2g}. Feasibility requires  n^{2g} >= n^{2-2g}, i.e. 4g >= 2,
  g >= 1/2.

So the semiprime obstruction is a PAIR-COVERING bound, giving the same g>=1/2 as
r103c but for the right reason: a difference absorbs MANY semiprimes (all pairs in
its block), yet covering ALL pairs of v ~ n/ln n primes still needs (v/k)^2 blocks.

This closes the audit: r103c's CONCLUSION holds, its PREMISE did not. The wall is
the covering-design (v/k)^2 vs budget n^{2g}.
"""
import math

def design_feasible(g, n=10**12):
    v = n / math.log(n)          # |P|, primes in (n^g, n]
    k = n**g / math.log(n)        # primes per difference
    need = (v / k)**2             # (v/k)^2 = n^(2-2g)  (Schonheim pair bound)
    budget = n**(2*g)             # n^(2g) differences available
    return need, budget, budget >= need

def main():
    print("Pair-covering (Schonheim) obstruction: blocks (v/k)^2 vs budget n^(2g).")
    print("g | (v/k)^2 needed | n^(2g) budget | feasible")
    for g in [0.36, 0.40, 0.45, 0.4999, 0.50, 0.55]:
        need, budget, ok = design_feasible(g)
        print("  %.4f | %.3e | %.3e | %s" % (g, need, budget, ok))
    print()
    print("Feasibility iff 2g >= 2-2g, i.e. g >= 1/2. Same wall as r103c,")
    print(" correct reason (pair-covering design, not one-block-per-semiprime).")

if __name__ == "__main__":
    main()
