#!/usr/bin/env python3
"""
K1 -- apply R2's decidable independence test to realistic multivariate RSA partial-leak
instances.

SCOPE WARNING, stated before any result is reported, because getting this wrong would
manufacture a false "closed":

  arXiv:2111.14180 analyses  TWO-VARIABLE LINEAR  congruences  x + t y + a = 0 (mod J).
  Its Problem 1.1 is exactly a 2-sample Hidden Number Problem.  It is NOT a theorem about
  multivariate (n >= 3) or nonlinear Coppersmith, and it says so on p.1:
  "we apply adelic capacity theory to two-variable LINEAR polynomial congruences. This is the
   simplest case involving multivariate polynomials".
  So the test below decides the LINEAR TWO-VARIABLE subcase only.  A negative answer there is
  a real result; it is NOT a theorem about Herrmann-May n-variable factoring.

Instances tested:
  (I1) 2-sample HNP: secret s mod q, two small errors -- the exact model of R2's Problem 1.1,
       and the exact application R2 illustrates on p.12 (DSA/ECDSA-style nonce leakage where
       the top bits of two nonces are recovered).
  (I2) "p+q" / factor-sum leak: N = p q, s = (p+q) known -> p,q are roots of a QUADRATIC
       x^2 - s x + N = 0, which is UNIVARIATE and NOT in R2's scope.  Reported as out-of-scope
       for R2 and for R1 (R1 needs roots of a given monic f mod N of a size bound; this is a
       different construction).  Included deliberately so the note does not over-claim.
  (I3) partial bits of d (the Ernst-style leak): d = d0 + 2^delta * d1.  This is a 3-variable
       linear congruence (Herrmann-May territory), out of R2's scope; reported as such.

For (I1) the test is genuinely applicable, so that is where the verdict is produced.
"""

from fractions import Fraction as Fr
from sympy import nextprime, isprime, randprime
import random

from capacity import admissible_g1
from lens import gamma_full


def decide_lin2(p, t, a, X, Y):
    """R2's test, Theorem 3.4's decision rule, for x + t y + a = 0 (mod p), |x|<=X, |y|<=Y."""
    gs = admissible_g1(p, t, a, X, Y)
    if not gs:
        return {"verdict": "NO g1 at this (X,Y)", "gammas": []}
    gammas = [gamma_full(p, d1, d2, d3, X, Y) for (d1, d2, d3) in gs]
    worst = max(gammas)
    if worst > 1:
        v = "FAIL: gamma>1 -- every Problem-1.3 polynomial divisible by g1; NO 2nd function"
    elif worst < 1:
        v = "WORKS: gamma<1 -- a 2nd algebraically independent function exists"
    else:
        v = "KNIFE EDGE gamma==1"
    return {"verdict": v, "gammas": [float(g) for g in gammas], "n_g1": len(gs),
            "g1": gs[0]}


# ---------------------------------------------------------------- I1: 2-sample HNP

def hnp_instance(bitlen=20, leak_bits=None, seed=0):
    """A 2-sample Hidden Number Problem, the model of R2 Problem 1.1 / p.12 application.

    Secret s in Z/qZ; two samples c_i s mod q whose top `leak_bits` bits are observed.
    The unknowns x_i = (c_i s mod q) - d_i are small.  This is exactly the setting where
    R2's criterion certifies AT MOST ONE secret s.
    """
    rnd = random.Random(seed)
    q = randprime(2 ** (bitlen - 1), 2 ** bitlen)
    if leak_bits is None:
        leak_bits = bitlen // 2
    s = rnd.randrange(1, q)
    cs = []
    for _ in range(2):
        c = rnd.randrange(1, q)
        cs.append(c)
    # small errors: |x_i| <= X
    X = Fr(1, 1) * Fr(q) ** Fr(1, 4)          # a realistic partial-leak size, exact Fraction
    # observation: b_i = c_i s mod q, d_i = top (bitlen - log X) bits of b_i
    mask_bits = int(float(X))
    keep = max(0, bitlen - max(1, int(X).bit_length() + 1))
    ds = []
    for c in cs:
        b = (c * s) % q
        d = b >> keep                    # top `keep` bits
        ds.append(d)
    # Build the single linear congruence x1 + t x0 + a = 0 (mod q) exactly as R2 section 1.1.
    c0p = pow(cs[0], -1, q)
    t = (-cs[1] * c0p) % q
    a = (ds[1] - cs[1] * c0p * ds[0]) % q
    return q, t, a, X, X, s, keep


def main():
    print("=" * 78)
    print("K1 -- R2's decidable independence test on realistic instances")
    print("=" * 78)

    print("\n[I1] TWO-SAMPLE HIDDEN NUMBER PROBLEM  (IN SCOPE for R2)")
    print("      secret s mod q, two partial nonce observations, x_i small")
    print(f"      {'q':>10} {'t':>10} {'keep bits':>10} {'g1':>18} {'gamma':>12}  verdict")
    verdicts = {}
    for seed in range(8):
        q, t, a, X, Y, s, keep = hnp_instance(bitlen=24, seed=seed)
        r = decide_lin2(q, t, a, X, Y)
        g = max(r["gammas"]) if r["gammas"] else float("nan")
        print(f"      {q:10} {t:10} {keep:10} {str(r['g1']):>18} {g:12.6f}  "
              f"{r['verdict'].split(':')[0]}")
        verdicts.setdefault(r["verdict"].split(":")[0], 0)
        verdicts[r["verdict"].split(":")[0]] += 1
    print(f"      -> verdict counts: {verdicts}")

    print("\n[I2] p+q LEAK  (x^2 - s x + N = 0)  -- OUT OF SCOPE for both R1 and R2")
    print("      This is UNIVARIATE (a quadratic in one variable), so R2's two-variable linear")
    print("      capacity test does not apply; and it is not the 'find roots of a GIVEN monic")
    print("      f mod N' problem that R1's Theorem 2 addresses.  NOT DECIDED BY EITHER PAPER.")

    print("\n[I3] PARTIAL BITS OF d  (d = d0 + 2^delta d1)  -- OUT OF SCOPE for R2")
    print("      This is the 3-variable / multivariate Herrmann-May setting.  R2 handles only")
    print("      the two-variable LINEAR case and explicitly does not cover it.  NOT DECIDED.")
    print()
    print("      => The census's 'no multivariate/Herrmann-May construction built' gap is")
    print("         therefore NOT closed by R2.  It is replaced by a NARROWER, proved statement:")
    print("         'in the two-variable linear subcase the question is decidable in closed")
    print("          form; in the multivariate case it remains open as of CRYPTO 2025'.")

    print("\n[I4] DOES THE TEST EVER FIRE?  (the K1 question proper)")
    print("      Sweeping X upward on one instance: gamma(E) is monotone in X (Thm 3.4(3)), so")
    print("      there is a genuine threshold at which the construction stops working.")
    q, t, a, X0, Y0, s, keep = hnp_instance(bitlen=20, seed=3)
    print(f"      instance q={q}, t={t}, a={a}")
    print(f"      {'X':>14} {'gamma(E)':>14}  verdict")
    for k in range(1, 8):
        X = Fr(q) ** Fr(k, 12)
        Y = Fr(q) ** Fr(1, 3)
        r = decide_lin2(q, t, a, X, Y)
        if r["gammas"]:
            print(f"      {float(X):14.6f} {max(r['gammas']):14.6f}  {r['verdict'].split(':')[0]}")
        else:
            print(f"      {float(X):14.6f} {'-':>14}  {r['verdict']}")


if __name__ == "__main__":
    main()
