#!/usr/bin/env python3
"""Hints compound or diminish, not both: numerical companion.

Uses exact rational arithmetic (fractions.Fraction) to demonstrate:
  1. the shape of the reported hint-value curve (S-shape, window compounding);
  2. the squeeze at k = 4 (compounding >= 4.86, diminishing <= 3.95);
  3. the Compounding Horizon Theorem: V(b) <= b * Delta(k) for compounding curves
     with diminishing returns, and its failure on the data (1.215 > 0.76);
  4. the Linearity Theorem on random compounding + concave curves;
  5. the two explicit continuations (diminishing-only and compounding-only);
  6. the bounded-collapse phenomenon (copying argument);
  7. the factor-residue model: saturation, one orientation bit per odd prime field.
Self-contained; standard library only.
"""
from __future__ import annotations

import math
import random
from collections import Counter
from fractions import Fraction as Fr
from typing import Callable, Dict, List, Sequence, Tuple

DATA: List[Fr] = [Fr(0), Fr(52, 100), Fr(243, 100), Fr(319, 100)]


# ---------------------------------------------------------------- calculus
def marginals(v: Sequence[Fr]) -> List[Fr]:
    """Delta(k) = V(k+1) - V(k)."""
    return [v[k + 1] - v[k] for k in range(len(v) - 1)]


def is_compounding(v: Sequence[Fr]) -> bool:
    """Superadditivity V(m)+V(n) <= V(m+n) on the available range."""
    n = len(v)
    return all(v[i] + v[j] <= v[i + j] for i in range(n) for j in range(n - i))


def is_diminishing_from(v: Sequence[Fr], a: int) -> bool:
    d = marginals(v)
    return all(d[k + 1] <= d[k] for k in range(a, len(d) - 1))


def locked_in_rate(v: Sequence[Fr]) -> Tuple[Fr, int]:
    """max_{b>=1} V(b)/b and its argmax: the floor for late marginal gains."""
    return max((v[b] / b, b) for b in range(1, len(v)))


def first_forced_contradiction(v: Sequence[Fr], horizon: int = 20) -> Tuple[int, Fr, Fr] | None:
    """Earliest N > n where compounding lower bound exceeds tangent upper bound.

    Known values are exact; for new indices we keep interval bounds [lo, hi]:
    lo from superadditivity, hi from the tangent cap at the last observed gain.
    """
    n = len(v) - 1
    slope = v[n] - v[n - 1]
    lo: Dict[int, Fr] = {i: v[i] for i in range(n + 1)}
    for N in range(n + 1, horizon + 1):
        lower = max(lo[m] + lo[N - m] for m in range(1, N))
        upper = v[n] + (N - n) * slope
        if lower > upper:
            return N, lower, upper
        lo[N] = lower
    return None


# ---------------------------------------------------------------- continuations
def diminishing_ext(k: int) -> Fr:
    return DATA[k] if k < 2 else Fr(243, 100) + Fr(76, 100) * (k - 2)


def compounding_ext(k: int) -> Fr:
    return DATA[k] if k < 4 else Fr(k * k)


def section(title: str) -> None:
    print("\n" + "=" * 72 + f"\n{title}\n" + "=" * 72)


def main() -> None:
    section("1. The reported curve")
    d = marginals(DATA)
    for k, val in enumerate(DATA):
        print(f"  V({k}) = {float(val):5.2f}" + (f"   gain {float(d[k-1]):+.2f}" if k else ""))
    print(f"  gains rise then fall (S-shape): {d[0] < d[1] and d[2] < d[1]}")
    print(f"  concave from k=0?               {is_diminishing_from(DATA, 0)}")
    print(f"  compounding on window?          {is_compounding(DATA)}")
    print(f"  margins: V2-2V1 = {float(DATA[2]-2*DATA[1]):.2f}, V3-V1-V2 = {float(DATA[3]-DATA[1]-DATA[2]):.2f}")

    section("2. The squeeze at k = 4")
    lo4, hi4 = 2 * DATA[2], DATA[3] + d[2]
    print(f"  compounding:  V(4) >= V(2)+V(2) = {float(lo4):.2f}")
    print(f"  diminishing:  V(4) <= V(3)+0.76 = {float(hi4):.2f}")
    print(f"  gap = {float(lo4 - hi4):.2f} bits  -> impossible")
    print(f"  automated search: {first_forced_contradiction(DATA)}")

    section("3. Compounding horizon")
    r, b = locked_in_rate(DATA)
    print(f"  best average rate V(b)/b = {float(r):.3f} at b = {b}")
    print(f"  last observed gain       = {float(d[2]):.3f}")
    print(f"  horizon demands gain >= rate: {d[2] >= r}  -> verdict refuted")
    # Check the theorem on random curves that DO satisfy both hypotheses.
    # The theorem is about curves on ALL of N, so each random curve is a free
    # prefix of gains followed by a non-increasing tail whose last gain is
    # repeated forever; compounding is then checked on a long range [0, 60].
    random.seed(1)
    tested, ok, window_violations = 0, True, 0
    while tested < 300:
        a = random.randint(0, 3)
        prefix = [Fr(random.randint(0, 12), 4) for _ in range(a)]
        tail = sorted((Fr(random.randint(0, 12), 4) for _ in range(6 - a)), reverse=True)
        gains = prefix + tail + [tail[-1]] * 54
        v = [Fr(0)]
        for g in gains:
            v.append(v[-1] + g)
        short = v[:7]
        if is_compounding(short) and is_diminishing_from(short, a):
            window_violations += not all(short[bb] <= bb * (short[kk + 1] - short[kk])
                                         for bb in range(7) for kk in range(a, 6))
        if not (is_compounding(v) and is_diminishing_from(v, a)):
            continue
        tested += 1
        ok &= all(v[bb] <= bb * (v[kk + 1] - v[kk]) for bb in range(len(v)) for kk in range(a, len(v) - 1))
    print(f"  horizon inequality V(b) <= b*Delta(k) on {tested} random admissible curves: {ok}")
    print(f"  (curves that look admissible on a short window yet violate it: {window_violations};")
    print("   the horizon is an asymptotic law -- exactly why the verdict fails as a LAW)")

    section("4. Linearity theorem: compounding + concave from 0 forces V(k)=k V(1)")
    random.seed(2)
    found_nonlinear = 0
    for _ in range(20000):
        gains = sorted((Fr(random.randint(0, 9), 4) for _ in range(6)), reverse=True)
        v = [Fr(0)]
        for g in gains:
            v.append(v[-1] + g)
        if is_compounding(v) and any(v[k] != k * v[1] for k in range(len(v))):
            found_nonlinear += 1
    print(f"  random concave curves that compound but are non-linear: {found_nonlinear} (expected 0)")

    section("5. Each half alone is consistent")
    dv = [diminishing_ext(k) for k in range(12)]
    cv = [compounding_ext(k) for k in range(40)]
    print(f"  diminishing ext: matches data {dv[:4] == DATA}, diminishing from 1: {is_diminishing_from(dv, 1)}, compounding: {is_compounding(dv)}")
    print(f"  compounding ext: matches data {cv[:4] == DATA}, compounding (k<40): {is_compounding(cv)}, diminishing from 2: {is_diminishing_from(cv, 2)}")

    section("6. Bounded collapse: copying a positive value breaks any ceiling")
    B = 10.0
    v1 = 0.52
    m = math.floor(B / v1) + 1
    print(f"  compounding forces V({m}) >= {m}*0.52 = {m*v1:.2f} > ceiling {B}")

    section("7. Factor-residue model over Z/p: one orientation bit")
    for p in (7, 11, 13):
        demo_residue_model(p)
    demo_two_fields(5, 7)


# ---------------------------------------------------------------- residue model
def entropy(xs: Sequence) -> float:
    n = len(xs)
    return -sum(c / n * math.log2(c / n) for c in Counter(xs).values())


def mi(labels: Sequence, view: Sequence) -> float:
    return entropy(labels) + entropy(view) - entropy(list(zip(labels, view)))


def demo_residue_model(p: int) -> None:
    """Battery over Z/p: population = ordered pairs of nonzero residues (P, Q),
    label = orientation bit [P < Q]. Views: product PQ, sum dial (PQ, P+Q),
    joint residues (P, Q), and a residue-derived third hint h(P, Q)."""
    pts = [(a, b) for a in range(1, p) for b in range(1, p)]
    L = [x[0] < x[1] for x in pts]
    I0 = mi(L, [x[0] * x[1] % p for x in pts])
    SH = mi(L, [(x[0] * x[1] % p, (x[0] + x[1]) % p) for x in pts]) - I0
    HV = mi(L, pts) - I0
    third = mi(L, [(x, (x[0] ** 2 + 3 * x[1]) % p) for x in pts]) - I0
    print(f"  p={p:2d}: SH={SH:.3f}  HV={HV:.3f}  jump={HV-SH:.3f} <= 1   third-hint gain={third-HV:+.3f}")


def demo_two_fields(p1: int, p2: int) -> None:
    pts = [((a1, a2), (b1, b2)) for a1 in range(1, p1) for a2 in range(1, p2)
           for b1 in range(1, p1) for b2 in range(1, p2)]
    lab = lambda x: (x[0][0] < x[1][0], x[0][1] < x[1][1])
    mul = lambda x: (x[0][0] * x[1][0] % p1, x[0][1] * x[1][1] % p2)
    add = lambda x: ((x[0][0] + x[1][0]) % p1, (x[0][1] + x[1][1]) % p2)
    L = [lab(x) for x in pts]
    I0 = mi(L, [mul(x) for x in pts])
    SH = mi(L, [(mul(x), add(x)) for x in pts]) - I0
    HV = mi(L, pts) - I0
    print(f"  Z/{p1} x Z/{p2}: SH={SH:.3f}  HV={HV:.3f}  jump={HV-SH:.3f} <= 2 (two orientation bits)")
    print("  -> the observed 1.91-bit jump is impossible over one field, admissible over two")


if __name__ == "__main__":
    main()
