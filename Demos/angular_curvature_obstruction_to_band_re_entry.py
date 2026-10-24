#!/usr/bin/env python3
"""
Angular Curvature Obstruction to Band Re-entry -- numerical companion.

Standard library only.  Every function used is defined in this file.

The correlation ladder rho_n is indexed by n = 0..6, corresponding to bit
lengths 96, 100, ..., 120 (bitlen = 96 + 4n).  The angle coordinate is
theta_n = arccos(rho_n).  The anchors rho_108 = 0.488 and rho_116 = 0.4847 are
the values the analysis is built on; the other five entries form a
*representative* ladder that reproduces every qualitative property established
in the paper (sign alternation of curvature in both coordinates, monotone and
angularly concave parity sub-ladders, the 116 rebound, the 120 drop, and a
convexity excess above 0.079 at the 112 window).

Sections
  1. The ladder in both coordinates
  2. Curvature: alternating second differences, convexity excess at 112
  3. Parity sub-ladders: monotone and angularly concave
  4. The mechanism: bounded concave sequences cannot step down
  5. The conjecture as a theorem: concave angle => no re-entry
  6. The collapse: concave angle => antitone correlation; data refute both
  7. Concavity + rebound forces re-entry; lifetime bound
  8. The arccos mean-value sandwich
  9. Plateau localisation in angle, checked against rungs 112/116/120
 10. A falsifiable prediction for rung 124
"""
from __future__ import annotations

import math
from typing import List, Sequence, Tuple

CAP: float = 0.55                     # the spherical cap rho >= 0.55
RHO_108: float = 0.488
BITLENS: List[int] = [96 + 4 * n for n in range(7)]
LADDER: List[float] = [0.575, 0.555, 0.510, 0.488, 0.462, 0.4847, 0.436]


# ----------------------------------------------------------------------------
# Basic tools
# ----------------------------------------------------------------------------
def angles(rho: Sequence[float]) -> List[float]:
    """theta_n = arccos(rho_n), clipped to the domain [-1, 1]."""
    return [math.acos(max(-1.0, min(1.0, r))) for r in rho]


def second_differences(s: Sequence[float]) -> List[float]:
    """Delta^2 s_n = s_{n+2} - 2 s_{n+1} + s_n, based at n = 0..len-3."""
    return [s[n + 2] - 2.0 * s[n + 1] + s[n] for n in range(len(s) - 2)]


def strictly_alternating(v: Sequence[float]) -> bool:
    return all(v[i] * v[i + 1] < 0 for i in range(len(v) - 1))


def is_concave_from(s: Sequence[float], start: int) -> bool:
    return all(d <= 0 for d in second_differences(s)[start:])


def strictly_decreasing(s: Sequence[float]) -> bool:
    return all(s[i + 1] < s[i] for i in range(len(s) - 1))


def header(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


# ----------------------------------------------------------------------------
# 1. The ladder
# ----------------------------------------------------------------------------
def section_ladder() -> None:
    header("1. The ladder in both coordinates")
    th = angles(LADDER)
    print(f"{'n':>2} {'bitlen':>6} {'rho':>8} {'theta=arccos(rho)':>18} {'in cap?':>8}")
    for n, (b, r, t) in enumerate(zip(BITLENS, LADDER, th)):
        print(f"{n:>2} {b:>6} {r:>8.4f} {t:>18.5f} {str(r >= CAP):>8}")
    print(f"cap boundary angle arccos(0.55) = {math.acos(CAP):.5f}")
    print(f"angle at bitlen 108, arccos(0.488) = {math.acos(RHO_108):.5f}")
    ups = [BITLENS[i + 1] for i in range(6) if LADDER[i + 1] > LADDER[i]]
    print(f"rungs where rho rises (antitonicity fails): {ups}")


# ----------------------------------------------------------------------------
# 2. Curvature
# ----------------------------------------------------------------------------
def section_curvature() -> None:
    header("2. Curvature alternates in BOTH coordinates")
    d2r = second_differences(LADDER)
    d2t = second_differences(angles(LADDER))
    print(f"{'window':>8} {'D2 rho':>10} {'D2 theta':>10}")
    for n in range(5):
        print(f"{BITLENS[n]:>8} {d2r[n]:>+10.5f} {d2t[n]:>+10.5f}")
    print(f"rho curvature strictly alternates:   {strictly_alternating(d2r)}")
    print(f"theta curvature strictly alternates: {strictly_alternating(d2t)}")
    print(f"108 window concave in angle: {d2t[3] < 0}")
    print(f"112 window convexity excess = {d2t[4]:.5f}  (> 0.079: {d2t[4] > 0.079})")


# ----------------------------------------------------------------------------
# 3. Parity sub-ladders
# ----------------------------------------------------------------------------
def section_parity() -> None:
    header("3. Parity sub-ladders are monotone and angularly concave")
    for name, idx in (("even (96,104,112,120)", [0, 2, 4, 6]),
                      ("odd  (100,108,116)", [1, 3, 5])):
        sub = [LADDER[i] for i in idx]
        th = angles(sub)
        print(f"{name}: rho = {sub}")
        print(f"   strictly decreasing: {strictly_decreasing(sub)}; "
              f"angle second differences = {[round(x, 5) for x in second_differences(th)]}; "
              f"concave: {is_concave_from(th, 0)}")


# ----------------------------------------------------------------------------
# 4. Mechanism
# ----------------------------------------------------------------------------
def chord_extension(s0: float, s1: float, k: int) -> float:
    """Upper chord bound for a concave sequence: s_{m+k} <= s_m + k (s_{m+1} - s_m)."""
    return s0 + k * (s1 - s0)


def first_exit_below(s0: float, s1: float, floor: float) -> int:
    """Smallest k with s0 + k(s1 - s0) < floor (requires s1 < s0)."""
    k = 0
    while chord_extension(s0, s1, k) >= floor:
        k += 1
    return k


def section_mechanism() -> None:
    header("4. A bounded concave sequence cannot take a downward step")
    s0, s1 = 1.20, 1.19   # a tiny downward step of 0.01 in angle
    k = first_exit_below(s0, s1, 0.0)
    print(f"Downward step {s0} -> {s1}: concavity forces s_(m+k) <= {s0} - 0.01 k,")
    print(f"which is negative (impossible for an angle) by k = {k}.")
    print("Formal bound: k > (s_m - B)/(s_m - s_(m+1)) gives the contradiction.")
    print("Lifetime of a concave angle path after a downward step of size delta from 1.2:")
    for delta in (0.1, 0.03, 0.01, 0.001):
        print(f"  delta = {delta:<6}: leaves [0, pi] after at most {first_exit_below(1.2, 1.2 - delta, 0.0)} steps")
    print("Every downward step, however small, is fatal for an infinite bounded concave sequence.")


# ----------------------------------------------------------------------------
# 5. The conjecture is a theorem
# ----------------------------------------------------------------------------
def section_theorem() -> None:
    header("5. Concave angle from bitlen 108 => convergence and no re-entry")
    t3 = math.acos(RHO_108)
    # a concave, bounded angle path starting at arccos(0.488): increments halve
    th = [t3]
    inc = 0.02
    for _ in range(30):
        th.append(th[-1] + inc)
        inc *= 0.5
    rho = [math.cos(t) for t in th]
    print(f"concave angle path: theta_3 = {th[0]:.5f} -> limit ~ {th[-1]:.5f}")
    print(f"max rho after bitlen 108 = {max(rho):.5f}  (<= 0.488 < 0.55)")
    print(f"concave: {is_concave_from(th, 0)}")


# ----------------------------------------------------------------------------
# 6. Collapse and refutation
# ----------------------------------------------------------------------------
def section_refutation() -> None:
    header("6. Angular concavity implies antitone rho; the data refute both")
    th = angles(LADDER)
    for start in range(5):
        print(f"concave from index {start}: possible? "
              f"{all(th[i + 1] >= th[i] for i in range(start, 6)) and is_concave_from(th, start)}")
    print(f"angle step at 112->116: {th[5] - th[4]:+.5f} (downward => concavity from <=4 impossible)")
    print(f"angle step at 116->120: {th[6] - th[5]:+.5f} (upward   => convexity from <=5 impossible)")


# ----------------------------------------------------------------------------
# 7. Concavity + rebound forces re-entry
# ----------------------------------------------------------------------------
def section_reentry() -> None:
    header("7. A concave continuation of the rebound re-enters the cap")
    th = angles(LADDER)
    t4, t5 = th[4], th[5]
    cap_angle = math.acos(CAP)
    print(f"theta_112 = {t4:.5f}, theta_116 = {t5:.5f}, drop = {t4 - t5:.5f}")
    for k in range(0, 7):
        bound = chord_extension(t4, t5, k)
        print(f"  bitlen {112 + 4 * k}: theta <= {bound:.5f}  => rho >= {math.cos(min(bound, math.pi)):.4f}"
              f"{'  (inside cap)' if bound < cap_angle else ''}")
    delta_lb = (LADDER[5] - LADDER[4]) / math.sqrt(1 - LADDER[4] ** 2)
    k_star = math.floor((math.pi / 2) / delta_lb) + 1
    print(f"certified drop lower bound (sandwich) = {delta_lb:.6f}")
    print(f"pi/2 - 62 * drop = {math.pi / 2 - 62 * delta_lb:.5f} < 0  -> concavity dies within 62 windows "
          f"(first k = {k_star})")


# ----------------------------------------------------------------------------
# 8. Sandwich
# ----------------------------------------------------------------------------
def sandwich(a: float, b: float) -> Tuple[float, float, float]:
    """(b-a)/sqrt(1-a^2) <= arccos a - arccos b <= (b-a)/sqrt(1-b^2), 0<=a<b<1."""
    return ((b - a) / math.sqrt(1 - a * a), math.acos(a) - math.acos(b),
            (b - a) / math.sqrt(1 - b * b))


def section_sandwich() -> None:
    header("8. Arccos mean-value sandwich")
    for a, b in [(0.462, 0.488), (0.462, 0.4847), (0.4847, 0.488), (0.488, 0.55)]:
        lo, mid, hi = sandwich(a, b)
        print(f"a={a:.4f} b={b:.4f}: {lo:.6f} <= {mid:.6f} <= {hi:.6f}  ok={lo <= mid <= hi}")


# ----------------------------------------------------------------------------
# 9. Plateau localisation
# ----------------------------------------------------------------------------
def plateau_window(theta_m: float, first_inc: float, ratio: float) -> Tuple[float, float]:
    """Nondecreasing sequence with increments d_{n+1} <= r d_n: limit in [theta_m, theta_m + d/(1-r)]."""
    return theta_m, theta_m + first_inc / (1.0 - ratio)


def section_plateau() -> None:
    header("9. Plateau localisation in angle (ratio 1/2)")
    th = angles(LADDER)
    t3 = th[3]
    inc_upper = sandwich(LADDER[4], RHO_108)[2]     # certified upper bound on theta_112-theta_108
    lo, hi = plateau_window(t3, inc_upper, 0.5)
    print(f"one-step sandwich bound: limit angle in [{lo:.5f}, {hi:.5f}]  (width {hi - lo:.5f})")
    print(f"exact width 2(theta_112 - theta_108) = {2 * (th[4] - t3):.5f} <= 0.0595: {2 * (th[4] - t3) <= 0.0595}")
    print(f"cap angle {math.acos(CAP):.5f} < {lo:.5f}: the plateau lies outside the cap")
    rho_band = (math.cos(t3 + 0.0595), RHO_108)
    print(f"predicted band for later readings: rho in [{rho_band[0]:.4f}, {rho_band[1]:.4f}]")
    for n in (4, 5, 6):
        r = LADDER[n]
        print(f"  rung {BITLENS[n]}: rho = {r:.4f}  in band: {rho_band[0] <= r <= rho_band[1]}; "
              f"angle step vs previous {th[n] - th[n - 1]:+.5f}")


# ----------------------------------------------------------------------------
# 10. Prediction
# ----------------------------------------------------------------------------
def section_prediction() -> None:
    header("10. Prediction for rung 124 (odd sub-ladder persistence)")
    t108, t116 = math.acos(RHO_108), math.acos(LADDER[5])
    lower = math.cos(2 * t116 - t108)
    print(f"odd class decreasing   => rho_124 < {LADDER[5]:.4f}")
    print(f"odd class concave angle => theta_124 <= 2 theta_116 - theta_108 => rho_124 >= {lower:.4f}")
    print(f"predicted window: [{lower:.4f}, {LADDER[5]:.4f})")


def main() -> None:
    for f in (section_ladder, section_curvature, section_parity, section_mechanism,
              section_theorem, section_refutation, section_reentry, section_sandwich,
              section_plateau, section_prediction):
        f()


if __name__ == "__main__":
    main()
