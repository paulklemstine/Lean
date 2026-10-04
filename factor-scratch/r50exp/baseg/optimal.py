"""
G4 -- THE OPTIMALITY BOUND.  IS 8/9 THE END, OR IS THERE MORE?

The question "is 20/27 optimal over cheaply-computable g?" has a sharp answer, but the answer
DIFFERS depending on what "cheaply-computable" means, and conflating the two versions of the
claim is precisely the signature error this programme keeps making.  So this script separates
them explicitly.

VERSION A (STRONG, AND FALSE): no g beats 8/9.
    FALSE, and trivially so.  Give the algorithm p and q and it can force ANY desired
    (k_p, k_q) pair -- e.g. pick g with k_p = 0 exactly and k_q = s_q.  Then success is
    certain.  So over all g the supremum is 1.0, and any claim that 8/9 is optimal over ALL g
    is refuted by an oracle.  This is why the qualifier matters.

VERSION B (THE ONE THAT CAN BE TRUE): no g beats 8/9 among choices computable from n WITHOUT
    factoring it.
    This is the meaningful claim and it is what this script tests.

THE ARGUMENT.  Let lam_p = s_p - k_p.  Success is k_p != k_q.

  (i)  The ONLY conditioning on g that is available without factoring n is the Jacobi symbol
       (g/n) = (g/p)(g/q).  [Justification below.]
  (ii) lam_p = 0 <=> (g/p) = -1.  [Verified by full enumeration, measure.py T2.]
       So conditioning on Jacobi = -1 says EXACTLY ONE of lam_p, lam_q is 0 -- it does not say
       which.  That asymmetry is the whole content of the mechanism.
  (iii) The Haar measure on the reachable family is therefore indexed only by
       eps = Jacobi(g/n) in {+1,-1}, plus the uniform mixture.  Three strategies exhaust the
       reachable family.  Their rates are 8/9, 8/15 and 20/27.

  => 8/9 is optimal WITHIN the reachable family, and 20/27 was the worst of the three.

WHY THE JACOBI SYMBOL IS THE ONLY HANDLE (this is the load-bearing claim of G4).
  A condition on g computable from n is a function of the residue class of g in (Z/nZ)*.
  The 2-adic part of k_p is determined by which 2-power subgroup g falls in.  Distinguishing
  "lam_p = 0" from "lam_q = 0" REQUIRES knowing which prime is which; any test that separates
  them computes a non-trivial factor.  Concretely: any computable condition that depends on
  (g/p) and (g/q) SEPARATELY is a factoring algorithm in disguise.  The Jacobi symbol is
  exactly the maximal such object -- it is the product, hence symmetric under p <-> q, hence
  free of that ability.  This is an argument, not a theorem about every conceivable model of
  computation; it is stated at the strength it deserves.

HONEST CAVEAT, stated because it is the whole difference between the two claims: a g chosen
by a NON-SYMMETRIC rule (e.g. one that depends on the numeric ordering of p and q) is not
excluded by (i) in full generality -- but computing such a g requires knowing the ordering of
p and q, which requires factoring.  Within polytime-without-factoring the family is the three
above.  This is the strongest form of the claim that I can actually defend.
"""

from __future__ import annotations

from fractions import Fraction as F

import laws
from laws import cell_jac_neg, cell_jac_pos, cell_uniform, avg

SMAX = 60
DROPPED = 1 - (1 - F(1, 2**SMAX)) ** 2


def report() -> None:
    ru = avg(cell_uniform, SMAX)
    rn = avg(cell_jac_neg, SMAX)
    rp = avg(cell_jac_pos, SMAX)

    print("=" * 78)
    print("VERSION A -- over ALL g (an oracle is allowed to know p and q)")
    print("=" * 78)
    print("  Supremum = 1, and it is attained: given p and q, pick g with")
    print("  k_p = 0 and k_q = s_q.  Then k_p != k_q with probability 1.")
    print("  => ANY claim that 8/9 is optimal over all g is FALSE.  Withheld deliberately.")
    print()

    print("=" * 78)
    print("VERSION B -- over g computable from n WITHOUT factoring it")
    print("=" * 78)
    print(f"  {'strategy':>34} {'exact rate':>14} {'closed form':>14}")
    print(f"  {'uniform g (the campaign baseline)':>34} {float(ru[0]):>14.9f} {'20/27':>14}")
    print(f"  {'Jacobi(g/n) = +1':>34} {float(rp[0]):>14.9f} {'8/15':>14}")
    print(f"  {'Jacobi(g/n) = -1  <-- OPTIMAL':>34} {float(rn[0]):>14.9f} {'8/9':>14}")
    print()
    for name, (val, _), target in (("uniform", ru, F(20, 27)), ("jac_pos", rp, F(8, 15)),
                                   ("jac_neg", rn, F(8, 9))):
        d = abs(val - target)
        assert d < DROPPED, (name, float(d), float(DROPPED))
        print(f"  [PASS] {name:>9} -> {target} exact to {float(d):.2e} "
              f"(truncation bound {float(DROPPED):.2e})")
    print()

    print("=" * 78)
    print("THE IMPROVEMENT, IN THE UNITS THAT MATTER")
    print("=" * 78)
    gain = F(8, 9) - F(20, 27)
    print(f"  per-attempt rate   20/27 = {float(F(20,27)):.6f}  ->  8/9 = {float(F(8,9)):.6f}")
    print(f"  absolute gain      {float(gain):.6f}   ({float(100*gain/F(20,27)):.1f}% relative)")
    print(f"  expected attempts  {float(27/20):.4f}  ->  {float(9/8):.4f}"
          f"   ({float(27/20 - 9/8):.4f} fewer attempts per factor)")
    print()

    print("=" * 78)
    print("COST")
    print("=" * 78)
    print("  Jacobi(g,n) is O(log n) bit operations (binary/Jacobi algorithm).  Rejection")
    print("  sampling needs E[2] draws.  A Stange attempt already costs b+c relation")
    print("  findings plus a rational nullspace over Q, so this is free by comparison.")
    print("  No change to the relation-finding, the kernel, or the linear algebra.")
    print()

    print("=" * 78)
    print("WHAT WOULD FALSIFY VERSION B")
    print("=" * 78)
    print("  A g rule computable without factoring, with a pooled rate exceeding 8/9 = 0.8889")
    print("  on fresh semiprimes, reported PER MODULUS against its own cell prediction.")
    print("  The two strategies already measured and rejected:")
    print("    g a perfect square      0.5217  (forces Jacobi = +1, the WORSE class)")
    print("    g a fixed small base    0.7033 (2), 0.7433 (3), 0.7333 (5)")
    print("  Note the fixed-base rows are measured against the WRONG null: a fixed g is not")
    print("  uniform mod p, so the geometric law -- and hence 20/27 -- does not apply to it.")
    print()


if __name__ == "__main__":
    report()