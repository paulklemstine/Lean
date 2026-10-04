#!/usr/bin/env python3
"""
RESOLUTION EXPERIMENT.

My first implementation used gamma_inf(E_inf) = (length of the real interval)/4 and the
paper's Lemma 3.11 lower bound, and the self-test found instances where it claimed
gamma < 1 (=> no solutions, per Thm 4.1(2)) while an explicit nonzero solution existed.
That is a genuine contradiction, so one of two things is true:

  (R1) my archimedean capacity is too small (I treated E_inf as an interval in R), or
  (R2) the g1 I enumerated is not the one the theorem is about.

This script settles it empirically: for many (p, t) it computes the two candidate
readings of gamma and checks each against BRUTE-FORCED ground truth (does a nonzero
solution exist?).  The reading that is 100% consistent is the correct one; the other
produces violations, and I report the violation count rather than quietly switching.

Reading A ("interval"): E_inf is the real interval [-Y,Y] n { |b2 y+b3| <= |b1| X };
         gamma_inf = (length)/4   [this is what Lemma 3.11 (3.16) lower-bounds]
Reading B ("lens/disk"): E_inf is the intersection of the two DISKS in C; for concentric
         disks its capacity is the radius, not radius/2.
"""

from fractions import Fraction as Fr
from math import gcd, isqrt
from capacity import admissible_g1


def gamma_reading(d1, d2, d3, X, Y, reading):
    assert d1 > 0
    lo, hi = -Y, Y
    if d2 != 0:
        half = Fr(d1) * X / abs(d2)
        centre = Fr(-d3, abs(d2))
        lo = max(lo, centre - half)
        hi = min(hi, centre + half)
    else:
        if abs(d3) > Fr(d1) * X:
            return Fr(0)
    if hi < lo:
        return Fr(0)
    if reading == "A":
        g_inf = (hi - lo) / 4          # real interval
    else:
        # radius of the effective disk: for two concentric real disks the intersection is
        # a disk of radius min(...); for the shifted case use the same disk radius the
        # second constraint imposes, capped by Y.
        r2 = Fr(d1) * X / abs(d2) if d2 != 0 else Fr(Y)
        g_inf = min(Y, r2)
    return g_inf / d1


def has_nonzero_solution(p, t, X, Y):
    Xi, Yi = int(X), int(Y)
    for x in range(-Xi, Xi + 1):
        for y in range(-Xi, Yi + 1):
            if (x, y) != (0, 0) and (x + t * y) % p == 0:
                return True
    return False


def main():
    primes = [101, 211, 307, 401, 509, 601, 701, 809, 907, 1009, 1103, 1201]
    cnum_cden = [(1, 4), (1, 3), (2, 5), (3, 8), (1, 2)]
    stats = {"A": {"viol": 0, "n": 0}, "B": {"viol": 0, "n": 0}}
    examples = {"A": [], "B": []}

    for p in primes:
        for cn, cd in cnum_cden:
            c = Fr(cn, cd)
            if c >= Fr(2, 3):
                continue
            X = Y = c * isqrt(p)
            for t in range(1, p, 3):
                ground = has_nonzero_solution(p, t, X, Y)
                gs = admissible_g1(p, t, 0, X, Y)
                if not gs:
                    continue
                for reading in ("A", "B"):
                    gammas = [gamma_reading(*g, X, Y, reading) for g in gs]
                    # Thm 3.4(2) contrapositive: if solutions exist => gamma >= 1
                    if ground and all(g < 1 for g in gammas):
                        stats[reading]["viol"] += 1
                        if len(examples[reading]) < 4:
                            examples[reading].append((p, t, str(X), str(X), gs[0],
                                                      float(min(gammas))))
                    stats[reading]["n"] += 1

    for reading in ("A", "B"):
        s = stats[reading]
        print(f"reading {reading}: {s['viol']} violations / {s['n']} instances")
        for e in examples[reading]:
            print(f"    e.g. p={e[0]} t={e[1]} X={e[2]} g1={e[4]} min gamma={e[5]:.4f}")


if __name__ == "__main__":
    main()
