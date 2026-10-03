#!/usr/bin/env python3
"""
Implementation of the DECIDABLE TEST of

  T. Chinburg, B. Hemenway Falk, N. Heninger, Z. Scherr,
  "Two variable polynomial congruences and capacity theory", arXiv:2111.14180v1.

Restricted to the case the paper analyses in closed form with F = Q, J = pZ:
  x + t y + a = 0  (mod p),   |x| <= X,  |y| <= Y.

THE TEST (paper p.12, "we conclude this paper with ... a computable criterion"):
    "Using lattice basis reduction, find a polynomial b1 x + b2 y + b3 in J^{-1} O_F[x,y]
     with the properties in Theorem 2.1 for Y = X, t = -c1 c0' and a = 0.
     Calculate the capacity gamma(E) of the adelic set E associated to this adelic set in
     Definition 3.1, using Lemma 3.2 and Theorem 3.5. If gamma(E) < 1, then parts (2)
     and (3) of Theorem 4.1 show N(t,a,J,X/2,X/2) <= 1."

Theorem 3.4 (the decision rule):
    gamma(E) > 1  ->  alternative (2): EVERY polynomial with the Problem 1.3 properties is
                     divisible by g1; the common zero locus is infinite; Coppersmith's method
                     CANNOT solve the instance.
    gamma(E) < 1  ->  alternative (1): there is a g with finite common zero locus; finitely many
                     solutions; the method CAN work.
    gamma(E) == 1 ->  knife edge (both readings apply).

WHERE EACH PIECE COMES FROM (all read off the PDF page IMAGES, not pdftotext):
  * g1 from Thm 2.1: L = J^{-1}(x+ty+a) + O_F*y + O_F, Minkowski with d=(1/(3X),1/(3Y),1/3).
    With b = p^{-1}(d1 x + d2 y + d3) the Thm 2.1(i) bounds (paper eq. 3.13) are
        0 < d1 < p/(3X),  |d2| < p/(3Y),  |d3| < p/3
    and Thm 2.1(iii) requires (d1,d2,d3) = d1 (1,t,a)  (mod p).
  * E_infty, from Definition 3.1(ii):  E_v = { y : |y| <= Y  and  |b2 y + b3| <= |b1| X }.
  * gamma(E) = gamma_inf(E_inf) / d1  -- the d1^{-1} is the finite-place product
    gamma_v(E_v) = prod_{v finite} |d1|_v = d1^{-1} by the product formula (Lemma 3.11 proof).
  * capacity of a real interval [alpha,beta] relative to infinity is (beta-alpha)/4;
    0 if the interval is empty or a single point.
  * Lemma 3.11 (3.15)/(3.16) gives the same quantity in the paper's own variables; this file
    ALSO evaluates those closed forms and cross-checks them against the direct computation.
    See `capacity_paper_formula`.

All arithmetic is exact (fractions.Fraction on integer bounds). sqrt(p) is never floated:
bounds enter as exact Fractions.  (Hard lesson this repo has paid for twice:
 `int(n**(1/3))` understates floor(n^(1/3)) at every perfect cube.)
"""

from fractions import Fraction as Fr
from math import gcd, isqrt
import sys


# ---------------------------------------------------------------- lattice / Thm 2.1

def admissible_g1(p: int, t: int, a: int, X: Fr, Y: Fr):
    """Every polynomial g1 = p^{-1}(d1 x + d2 y + d3) with the properties of Theorem 2.1.

    Enumerated EXACTLY (no LLL needed, and so no dependence on a reducer behaving well):
    L = (1/p) Z (x + t y + a) + Z y + Z,  so
        d = m1 (1,t,a) + m2 (0,p,0) + m3 (0,0,p),
    hence d1 = m1 and d2,d3 are pinned by requiring |d2| < p/(3Y), |d3| < p/3.
    Returns list of (d1,d2,d3) with d1 > 0, gcd(d1,d2)=1, d1 minimal first.
    """
    b1max = Fr(p) / (3 * X)          # |d1| < p/(3X)   (3.13)
    b2max = Fr(p) / (3 * Y)
    b3max = Fr(p) / 3
    out = []
    for m1 in range(1, int(b1max) + 1):
        if Fr(m1) >= b1max:
            break
        # d2 = m1 t + m2 p  with |d2| < b2max  -> m2 is the unique integer taking m1 t
        # into the centred residue class mod p.
        r = (m1 * t) % p
        for d2 in {r, r - p}:
            if abs(d2) >= b2max:
                continue
            r3 = (m1 * a) % p
            for d3 in {r3, r3 - p}:
                if abs(d3) >= b3max:
                    continue
                if gcd(m1, abs(d2)) != 1:
                    continue
                out.append((m1, d2, d3))
    return out


# ---------------------------------------------------------------- capacity

def capacity_from_g1(p: int, d1: int, d2: int, d3: int, X: Fr, Y: Fr) -> Fr:
    """gamma(E) computed directly from Definition 3.1 + Lemma 3.11 (exact)."""
    assert d1 > 0
    # Definition 3.1(ii), archimedean place:  |y| <= Y  and  |b2 y + b3| <= |b1| X
    #   <=>  |y| <= Y  and  |d2 y + d3| <= d1 X
    lo = -Y
    hi = Y
    if d2 != 0:
        # d1 X / |d2|  is the half-length of the second interval
        half = Fr(d1) * X / abs(d2)
        centre = Fr(-d3, abs(d2))
        lo = max(lo, centre - half)
        hi = min(hi, centre + half)
    else:
        # |d3| <= d1 X required, else E_inf empty
        if abs(d3) > Fr(d1) * X:
            return Fr(0)
    if hi < lo:
        return Fr(0)                      # E_inf empty
    gamma_inf = (hi - lo) / 4             # real interval, capacity rel. to infinity
    return gamma_inf / d1                 # finite-place product is d1^{-1}


def capacity_paper_formula(p: int, d1: int, d2: int, d3: int, c: Fr) -> Fr:
    """Lemma 3.11 eqs (3.15)/(3.16) verbatim, in the paper's X = Y = c*sqrt(p) regime."""
    sp = isqrt(p)
    assert sp * sp == p, "paper formula written only for p a perfect square"
    d1c_over_d2 = Fr(d1) * c / d2
    d3_over = Fr(d3) / (sp * d2)
    delta1 = max(-c, -d1c_over_d2 - d3_over)
    delta2 = min(c, d1c_over_d2 - d3_over)
    if delta1 > delta2:
        return Fr(0)
    return sp * (delta2 - delta1) / (4 * d1)


def decide(p: int, t: int, a: int, X: Fr, Y: Fr):
    """The full test.  Returns dict with every admissible g1 and the verdicts."""
    gs = admissible_g1(p, t, a, X, Y)
    rows = []
    for (d1, d2, d3) in gs:
        g = capacity_from_g1(p, d1, d2, d3, X, Y)
        rows.append({"d": (d1, d2, d3), "gamma": g, "verdict": verdict_of(g)})
    if not rows:
        return {"p": p, "t": t, "a": a, "X": X, "Y": Y, "g1": [],
                "verdict": "NO g1 (Minkowski box empty at this X,Y)"}
    verdicts = {r["verdict"] for r in rows}
    overall = verdicts.pop() if len(verdicts) == 1 else "AMBIGUOUS (g1-dependent)"
    return {"p": p, "t": t, "a": a, "X": X, "Y": Y, "g1": rows, "verdict": overall}


def verdict_of(g: Fr) -> str:
    """Theorem 3.4 decision rule."""
    if g > 1:
        return "FAIL (gamma>1: every Problem-1.3 poly divisible by g1; no 2nd function)"
    if g < 1:
        return "WORKS (gamma<1: 2nd independent function exists)"
    return "KNIFE EDGE (gamma==1)"
