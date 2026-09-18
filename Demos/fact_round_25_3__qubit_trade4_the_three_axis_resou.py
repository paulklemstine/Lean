"""
The three-axis resource surface of repeated order finding
=========================================================

Numerical demonstration of the results of
"The Three-Axis Resource Surface of Repeated Order Finding:
 The Standard Corner Is Optimal".

The model
---------
A repeated order-finding attempt is described by three resources:

    t   register width (t = T - d, where T is the full width and d the shave)
    s   samples drawn per base
    k   independent base re-draws

and the model consists of three rules:

    P(q, n)   = 1 - (1 - q)^n            success of n = k*s independent shots
    q(q0, d)  = q0 / 2^d                 each shaved bit halves per-shot success
    G(n, t)   = n * t^2   (or n * t^3)   total gate cost

Everything demonstrated below is a consequence of these three rules.

Run with:   python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Iterable, List, Tuple

# --------------------------------------------------------------------------
# The model
# --------------------------------------------------------------------------


def succ_prob(q: float, n: int) -> float:
    """Probability that at least one of `n` independent shots succeeds."""
    return 1.0 - (1.0 - q) ** n


def shot_prob(q0: float, d: int) -> float:
    """Per-shot success probability at a register shaved by `d` bits."""
    return q0 / (2.0**d)


def gate_cost(n: int, t: int, exponent: int = 2) -> int:
    """Total gate cost of `n` shots on a width-`t` register."""
    return n * t**exponent


def shots_floor(p_target: float, q0: float, d: int) -> int:
    """Least integer shot count permitted by the union bound at shave `d`.

    Any configuration reaching probability `p_target` must use at least
    ceil(p_target * 2^d / q0) shots.  This is a lower bound over ALL
    configurations, not the cost of a particular schedule.
    """
    return math.ceil(p_target * (2.0**d) / q0)


def shots_exact(p_target: float, q: float) -> int:
    """Least n with 1 - (1-q)^n >= p_target (the true sufficient count)."""
    n = 0
    while succ_prob(q, n) < p_target - 1e-15:
        n += 1
    return n


# --------------------------------------------------------------------------
# 1. The cap-lift law:  1 - P(q, m*n) = (1 - P(q, m))^n
# --------------------------------------------------------------------------


def demo_cap_lift() -> None:
    print("=" * 74)
    print("1. THE CAP-LIFT LAW   1 - P(q, m*n) = (1 - P(q, m))^n")
    print("=" * 74)
    q = 0.137
    print(f"  per-shot q = {q}")
    print(f"  {'m':>3} {'k':>3} {'1 - P(q, m*k)':>16} {'(1 - P(q, m))^k':>18} "
          f"{'difference':>14}")
    for m in (1, 3, 5):
        for k in (1, 2, 4, 8):
            lhs = 1.0 - succ_prob(q, m * k)
            rhs = (1.0 - succ_prob(q, m)) ** k
            print(f"  {m:>3} {k:>3} {lhs:>16.12f} {rhs:>18.12f} "
                  f"{abs(lhs - rhs):>14.2e}")

    print("\n  Doubly exponential decay: after j doublings the failure")
    print("  probability is the 2^j-th power of the single-block failure.")
    base = 1.0 - succ_prob(q, 5)
    for j in range(5):
        lhs = 1.0 - succ_prob(q, (2**j) * 5)
        print(f"    j = {j}:  1 - P = {lhs:.12f}   "
              f"(1-P_block)^(2^{j}) = {base ** (2 ** j):.12f}")

    print("\n  Measured cells of the round (t = wall, s = 5):")
    measured = {1: 0.504, 2: 0.735, 4: 0.940}
    p1 = measured[1]
    for k in (2, 4):
        predicted = 1.0 - (1.0 - p1) ** k
        print(f"    k = {k}:  measured {measured[k]:.3f}   "
              f"law predicts {predicted:.6f}   "
              f"|deviation| = {abs(predicted - measured[k]):.2e}")
    print()


# --------------------------------------------------------------------------
# 2. Fungibility: the doubling gain is exactly the Bernoulli variance
# --------------------------------------------------------------------------


def demo_fungibility() -> None:
    print("=" * 74)
    print("2. FUNGIBILITY   P(q, 2n) - P(q, n) = P(1 - P),  capped at 1/4")
    print("=" * 74)
    q = 0.09
    print(f"  per-shot q = {q}")
    print(f"  {'n':>4} {'P(q,n)':>12} {'P(q,2n)':>12} {'gain':>12} "
          f"{'P(1-P)':>12} {'<= 1/4?':>9}")
    for n in (1, 2, 4, 8, 16, 32, 64, 128):
        p = succ_prob(q, n)
        gain = succ_prob(q, 2 * n) - p
        print(f"  {n:>4} {p:>12.8f} {succ_prob(q, 2*n):>12.8f} "
              f"{gain:>12.8f} {p * (1 - p):>12.8f} "
              f"{str(gain <= 0.25 + 1e-15):>9}")

    # the maximal gain occurs exactly at half saturation
    best_n = max(range(1, 200), key=lambda n: succ_prob(q, 2 * n)
                 - succ_prob(q, n))
    print(f"\n  Gain is maximised at n = {best_n}, where "
          f"P = {succ_prob(q, best_n):.6f} (theory: exactly at P = 1/2),")
    print(f"  with gain {succ_prob(q, 2*best_n) - succ_prob(q, best_n):.6f} "
          f"(ceiling 0.25).")

    # perfect fungibility of the s and k axes
    print("\n  Perfect fungibility of the samples and re-draw axes:")
    for (k, s) in ((2, 6), (6, 2), (3, 4), (4, 3), (12, 1), (1, 12)):
        print(f"    k = {k:>2}, s = {s:>2}:  P = {succ_prob(q, k * s):.12f}")
    print()


# --------------------------------------------------------------------------
# 3. The exponential shot floor and the trade-off inequality
# --------------------------------------------------------------------------


def demo_tradeoff_inequality(t_full_values: Iterable[int] = (8, 12, 20, 40,
                                                             64)) -> None:
    print("=" * 74)
    print("3. TRADE-OFF INEQUALITY   (5/4) T^2 < 2^d (T - d)^2   "
          "for T >= 8, 1 <= d <= T/2")
    print("=" * 74)
    all_ok = True
    for T in t_full_values:
        worst_ratio = math.inf
        worst_d = None
        for d in range(1, T // 2 + 1):
            lhs = 1.25 * T**2
            rhs = (2.0**d) * (T - d) ** 2
            if rhs / lhs < worst_ratio:
                worst_ratio, worst_d = rhs / lhs, d
            all_ok &= rhs > lhs
        print(f"  T = {T:>3}: holds for all 1 <= d <= {T//2}; "
              f"tightest at d = {worst_d} with ratio "
              f"rhs/lhs = {worst_ratio:.4f}")
    print(f"  All checks passed: {all_ok}")

    print("\n  The hypotheses are load-bearing:")
    for (T, d) in ((4, 2), (6, 3), (8, 8)):
        lhs, rhs = 1.25 * T**2, (2.0**d) * (T - d) ** 2
        verdict = "HOLDS" if rhs > lhs else "FAILS"
        print(f"    T = {T}, d = {d}:  (5/4)T^2 = {lhs:>8.2f}   "
              f"2^d (T-d)^2 = {rhs:>8.2f}   -> {verdict}")

    print("\n  Cubic version (5/4) T^3 < 2^d (T-d)^3:")
    ok_cubic = all(
        (2.0**d) * (T - d) ** 3 > 1.25 * T**3
        for T in t_full_values
        for d in range(1, T // 2 + 1)
    )
    print(f"    holds on the same range: {ok_cubic}")
    print()


# --------------------------------------------------------------------------
# 4. The cost surface and the corner optimum
# --------------------------------------------------------------------------


def surface_table(T: int, q0: float, p_target: float,
                  exponent: int = 2) -> List[Tuple[int, int, int, int]]:
    """Rows (d, t, minimum shots, minimum gate cost) over the shave axis."""
    rows: List[Tuple[int, int, int, int]] = []
    for d in range(0, T // 2 + 1):
        t = T - d
        n = shots_floor(p_target, q0, d)
        rows.append((d, t, n, gate_cost(n, t, exponent)))
    return rows


def demo_corner_optimum() -> None:
    print("=" * 74)
    print("4. THE STANDARD CORNER IS OPTIMAL   (q0 = 1/8, P* = 3/10, T = 40)")
    print("=" * 74)
    q0, p_target, T = 0.125, 0.3, 40

    n0 = shots_exact(p_target, shot_prob(q0, 0))
    print(f"  Corner: {n0} shots suffice at full width, since "
          f"P = 1 - (7/8)^{n0} = {succ_prob(q0, n0):.6f} >= {p_target}")
    print(f"  Efficiency hypothesis n0*q0 <= (5/4)P*:  "
          f"{n0 * q0:.4f} <= {1.25 * p_target:.4f}  -> "
          f"{n0 * q0 <= 1.25 * p_target} (equality)")
    corner_cost = gate_cost(n0, T)
    print(f"  Corner cost: {n0} * {T}^2 = {corner_cost}\n")

    print(f"  {'d':>3} {'t':>4} {'min shots':>10} {'min gate cost':>14} "
          f"{'vs corner':>11}")
    for (d, t, n, cost) in surface_table(T, q0, p_target):
        marker = "  <-- corner" if d == 0 else ""
        ratio = cost / corner_cost
        shown_n = n0 if d == 0 else n
        shown_cost = corner_cost if d == 0 else cost
        print(f"  {d:>3} {t:>4} {shown_n:>10} {shown_cost:>14} "
              f"{ratio if d else 1.0:>10.2f}x{marker}")

    print("\n  The three cells reported by the round:")
    for d in (0, 2, 4):
        t = T - d
        n = n0 if d == 0 else shots_floor(p_target, q0, d)
        word = "cost" if d == 0 else "floor"
        print(f"    d = {d} (t = {t}): {word} = {n} * {t}^2 = "
              f"{gate_cost(n, t)}")

    print("\n  The wall in comparative form: penalty factor >= 2^d / 4")
    for d in range(1, 9):
        print(f"    d = {d}:  guaranteed penalty >= {2**d / 4:>8.2f}x "
              f"the corner's union-bound floor")
    print()


# --------------------------------------------------------------------------
# 5. Exhaustive search over the full (k, s, t) grid
# --------------------------------------------------------------------------


def demo_full_grid_search() -> None:
    print("=" * 74)
    print("5. BRUTE-FORCE MINIMUM OVER THE FULL (k, s, t) GRID")
    print("=" * 74)
    q0, p_target, T = 0.125, 0.3, 40
    best: Tuple[int, int, int, int] | None = None
    feasible = 0
    for d in range(0, T // 2 + 1):
        t = T - d
        q = shot_prob(q0, d)
        for k in (1, 2, 4, 8, 16, 32, 64, 128):
            for s in (1, 2, 5, 10, 20, 50, 100):
                n = k * s
                if succ_prob(q, n) >= p_target:
                    feasible += 1
                    cost = gate_cost(n, t)
                    if best is None or cost < best[0]:
                        best = (cost, k, s, t)
    assert best is not None
    cost, k, s, t = best
    print(f"  Searched shaves d = 0..{T//2}, k in powers of two up to 128,")
    print(f"  s in (1,2,5,10,20,50,100): {feasible} feasible configurations.")
    print(f"  Cheapest feasible configuration: k = {k}, s = {s}, t = {t}, "
          f"cost = {cost}")
    print(f"  Is it at the full-register corner (t = {T})?  {t == T}")
    print()


# --------------------------------------------------------------------------
# 6. The cubic-versus-exponential separation 24 M^3 < 2^M
# --------------------------------------------------------------------------


def demo_cubic_vs_exponential() -> None:
    print("=" * 74)
    print("6. CUBIC VS EXPONENTIAL   24 M^3 < 2^M for M >= 20")
    print("=" * 74)
    print(f"  {'M':>4} {'24 M^3':>16} {'2^M':>24} {'holds?':>8}")
    for M in (16, 18, 19, 20, 21, 24, 32, 48, 64):
        lhs, rhs = 24 * M**3, 2**M
        print(f"  {M:>4} {lhs:>16} {rhs:>24} {str(lhs < rhs):>8}")

    first = next(M for M in range(1, 200)
                 if all(24 * m**3 < 2**m for m in range(M, 200)))
    print(f"\n  The inequality holds for every M >= {first} "
          f"(and fails for M = {first - 1}).")

    print("\n  Consequence: corner cost 3 T^3 with T = 2M is below "
          "square-root-scale search 2^M.")
    print(f"  {'M':>4} {'T = 2M':>8} {'3 T^3 (corner, cubic)':>24} "
          f"{'2^M (sqrt search)':>22} {'margin':>14}")
    for M in (20, 24, 32, 48, 64, 128):
        T = 2 * M
        corner, search = 3 * T**3, 2**M
        print(f"  {M:>4} {T:>8} {corner:>24} {search:>22} "
              f"{search / corner:>13.3g}x")
    print()


# --------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE THREE-AXIS RESOURCE SURFACE OF REPEATED ORDER FINDING")
    print("#  Numerical demonstration: the standard corner is optimal")
    print("#" * 74)
    print()
    demo_cap_lift()
    demo_fungibility()
    demo_tradeoff_inequality()
    demo_corner_optimum()
    demo_full_grid_search()
    demo_cubic_vs_exponential()
    print("=" * 74)
    print("Summary: the sample and re-draw axes are perfectly fungible and")
    print("saturate at a gain of 1/4 per doubling; the width axis charges an")
    print("exponential 2^d in shots for a merely quadratic rebate in circuit")
    print("size; so the minimum of the surface sits at the full-register")
    print("corner, whose cost stays polynomial and below square-root search.")
    print("=" * 74)


if __name__ == "__main__":
    main()
