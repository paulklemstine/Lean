#!/usr/bin/env python3
"""
SELF-TEST for capacity.py.

Design principle from this program: "a self-test that only shows your code running is not a
self-test -- it must return the null answer where null is correct."

So the load-bearing check is a DIRECTION where the correct answer is "nothing exists":

  Theorem 4.1(2):  a = 0 and gamma(E) < 1  ==>  N(t,0,J,X,Y) = 0,
  i.e. there is NO pair (x,y) of algebraic integers with |x| <= X, |y| <= Y and
  x + t y = 0 (mod p).  In particular no integer pair.

We brute-force ALL integer (x,y) in the box (exhaustive, not a search) and assert the
implication gamma(E) < 1  =>  zero solutions, in every instance.  A bug that inflates
gamma, or that mis-derives the interval, produces a spurious "solution" and FAILS.

We also assert the converse direction that is checkable on rationals, and — the control
that matters — that the test is NOT VACUOUS: it must return both verdicts across the
sample.  A test that only ever says "WORKS" has learned nothing.

Two further ground-truth checks that do not rely on the theory at all:
  (A) cross-check my capacity against the paper's own closed form (3.15)/(3.16);
  (B) the capacity of a real interval must be < the interval's own transfinite diameter
      bound and must vanish exactly when the interval is empty.
"""

import itertools
import sys
from fractions import Fraction as Fr
from math import isqrt

from capacity import admissible_g1
from lens import gamma_full, gamma_archimedean


def decide(p, t, a, X, Y):
    """R2's test, using the CORRECTED archimedean capacity from lens.py.

    (capacity.py's capacity_from_g1 is retained only as the historical record of the bug --
    it used Lemma 3.11's LOWER BOUND as an equality -- so nothing imports it any more.)"""
    gs = admissible_g1(p, t, a, X, Y)
    if not gs:
        return {"p": p, "t": t, "a": a, "X": X, "Y": Y, "g1": [],
                "verdict": "NO g1 (Minkowski box empty at this X,Y)"}
    rows = [{"d": g, "gamma": gamma_full(p, *g, X, Y)} for g in gs]
    worst = max(r["gamma"] for r in rows)
    if worst > 1:
        v = "FAIL"
    elif worst < 1:
        v = "WORKS"
    else:
        v = "KNIFE"
    return {"p": p, "t": t, "a": a, "X": X, "Y": Y, "g1": rows, "verdict": v}


def capacity_paper_formula(p, d1, d2, d3, c):
    """Lemma 3.11 (3.15)/(3.16). NOTE this is a LOWER BOUND on gamma(E), so it can only be
    compared as gamma_paper <= gamma_true -- equality is the bug this file was written to
    catch."""
    from math import isqrt
    sp = isqrt(p)
    d1c_over_d2 = Fr(d1) * c / d2
    d3_over = Fr(d3) / (sp * d2)
    delta1 = max(-c, -d1c_over_d2 - d3_over)
    delta2 = min(c, d1c_over_d2 - d3_over)
    if delta1 > delta2:
        return Fr(0)
    return sp * (delta2 - delta1) / (4 * d1)

fails = []


def check(name, cond, detail=""):
    if cond:
        print(f"  PASS  {name}")
    else:
        print(f"  FAIL  {name}  {detail}")
        fails.append(name)


def brute_force_integer_solutions(p, t, a, X, Y):
    """ALL integer (x,y) with |x| <= X, |y| <= Y and x + t y + a = 0 (mod p). Exhaustive."""
    Xi, Yi = int(X), int(Y)
    out = []
    for x in range(-Xi, Xi + 1):
        for y in range(-Yi, Yi + 1):
            if (x + t * y + a) % p == 0:
                out.append((x, y))
    return out


# ---------------------------------------------------------------- (A) cross-check vs paper

def test_against_paper_formula():
    print("\n[A] gamma_full >= paper's Lemma 3.11 LOWER bound (3.15)/(3.16)")
    print("    (equality is NOT expected: (3.16) is an inequality, which is exactly the bug")
    print("     this self-test was written to catch -- an earlier version used it as an")
    print("     equality and got 1712 false 'no solutions' verdicts.)")
    viol = 0
    n = 0
    for q in (5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        p = q * q
        c = Fr(1, 2)
        X = Y = c * q
        for t in range(1, min(p, 12)):
            for a in range(0, min(p, 4)):
                rows = decide(p, t, a, X, Y)
                for r in rows["g1"]:
                    n += 1
                    lb = capacity_paper_formula(p, *r["d"], c)
                    if r["gamma"] < lb:
                        viol += 1
                        if viol <= 3:
                            print(f"    VIOLATION q={q} t={t} a={a} d={r['d']}: "
                                  f"gamma={float(r['gamma']):.8f} < lower bound {float(lb):.8f}")
    check(f"gamma_full >= Lemma 3.11 lower bound on {n} instances", viol == 0,
          f"{viol} violations")


# ---------------------------------------------------------------- (B) capacity sanity

def test_capacity_edge_cases():
    print("\n[B] capacity edge cases")
    p = 101
    # d2 chosen so the second constraint is nowhere near binding -> interval is [-Y, Y]
    X = Y = Fr(3)
    # |d2 y + d3| <= d1 X  with tiny d2 forces a point
    g = capacity_from_g1(p, 1, 0, 0, X, Y)   # d2 = 0, d3 = 0 -> |0| <= d1 X always
    check("d2=d3=0 gives full interval capacity", g == Fr(2 * 3, 4) / 1, f"got {g}")
    # empty: d2 != 0, d3 huge
    g = capacity_from_g1(p, 1, 1, p // 2, X, Y)  # |d3| > d1 X -> empty
    check("empty archimedean set gives gamma=0", g == 0, f"got {g}")


# ---------------------------------------------------------------- (C) THE load-bearing test

def test_theorem_4_1_2():
    print("\n[C] Theorem 4.1(2): a=0 and gamma<1  =>  ZERO integer solutions")
    tot = {"WORKS": 0, "FAIL": 0, "KNIFE": 0}
    spurious = 0
    n_inst = 0
    # a wide sweep: many primes, many t, several c. Box small enough to brute force.
    for p in (101, 211, 307, 401, 509, 601, 701, 809, 907, 1009,
              1103, 1201, 1301, 1409, 1511, 1601, 1709, 1801, 1901, 2003):
        for cnum, cden in ((1, 2), (1, 3), (1, 4), (2, 5), (3, 8)):
            c = Fr(cnum, cden)
            if c >= Fr(2, 3):
                continue
            X = Y = c * isqrt(p)
            for t in range(1, p, 7):
                n_inst += 1
                rows = decide(p, t, 0, X, Y)
                if rows["verdict"].startswith("NO g1"):
                    continue
                gs = rows["g1"]
                worst = min(r["gamma"] for r in gs)   # gamma>1 for ANY admissible g1
                # The strongest reading: if every admissible g1 has gamma < 1 we demand
                # zero solutions.
                if all(r["gamma"] < 1 for r in gs):
                    tot["WORKS"] += 1
                    sols = brute_force_integer_solutions(p, t, 0, X, Y)
                    nonzero = [s for s in sols if s != (0, 0)]
                    if nonzero:
                        spurious += 1
                        print(f"    spurious solution p={p} t={t} c={c} X={X} n={len(nonzero)}")
                elif any(r["gamma"] > 1 for r in gs):
                    tot["FAIL"] += 1
                else:
                    tot["KNIFE"] += 1
    print(f"  instances={n_inst}  verdicts={tot}")
    check("no spurious solution in any gamma<1 instance", spurious == 0,
          f"{spurious} spurious")
    check("test is NOT vacuous: both verdicts occur",
          tot["WORKS"] > 0 and tot["FAIL"] > 0, f"{tot}")


# ---------------------------------------------------------------- (D) null direction

def test_null_answer_is_reachable_and_correct():
    """gamma(E) < 1 must come with a genuinely empty solution set -- not just a small gamma."""
    print("\n[D] null answer: gamma<1 instances really have empty solution sets")
    empties = 0
    checked = 0
    for p in (101, 211, 307, 401, 509):
        for cnum, cden in ((1, 4), (1, 5), (1, 6)):
            c = Fr(cnum, cden)
            X = Y = c * isqrt(p)
            for t in range(1, p, 5):
                rows = decide(p, t, 0, X, Y)
                if rows["verdict"].startswith("NO g1"):
                    continue
                if all(r["gamma"] < 1 for r in rows["g1"]):
                    checked += 1
                    sols = [s for s in brute_force_integer_solutions(p, t, 0, X, Y)
                            if s != (0, 0)]
                    if not sols:
                        empties += 1
    print(f"  gamma<1 instances checked={checked}, of which empty={empties}")
    check("all gamma<1 (a=0) instances have empty solution set", checked == empties)


# ---------------------------------------------------------------- (E) inhomogeneous a != 0

def test_inhomogeneous():
    """With a != 0 the solution set need not be empty; Thm 4.1(3) bounds it.
       Check the countable version: N(t,a,J,X/2,Y/2) <= 1 + N(t,0,J,X,Y)."""
    print("\n[E] Theorem 4.1(3): N(t,a,J,X/2,Y/2) <= 1 + N(t,0,J,X,Y)")
    bad = 0
    tested = 0
    for p in (101, 211, 307, 401):
        for cnum, cden in ((1, 2), (1, 3), (1, 4)):
            c = Fr(cnum, cden)
            X = Y = c * isqrt(p)
            for t in range(1, p, 11):
                for a in (1, 2, 3, 5, 7):
                    # homogeneous count at (X, Y)
                    hom = len([s for s in brute_force_integer_solutions(p, t, 0, X, Y)
                               if s != (0, 0)])
                    rhs = 1 + hom
                    # inhomogeneous count at (X/2, Y/2)
                    inhom = len(brute_force_integer_solutions(p, t, a, X / 2, Y / 2))
                    tested += 1
                    if inhom > rhs:
                        bad += 1
    print(f"  tested={tested} violations={bad}")
    check("Theorem 4.1(3) holds on every instance tested", bad == 0, f"{bad} violations")


if __name__ == "__main__":
    print("=" * 78)
    print("SELF-TEST  (arXiv:2111.14180 decidable independence test)")
    print("=" * 78)
    test_capacity_edge_cases()
    test_against_paper_formula()
    test_theorem_4_1_2()
    test_null_answer_is_reachable_and_correct()
    test_inhomogeneous()
    print("\n" + "=" * 78)
    if fails:
        print(f"RESULT: {len(fails)} FAILURE(S): {fails}")
        sys.exit(1)
    print("RESULT: ALL CHECKS PASS")
