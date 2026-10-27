#!/usr/bin/env python3
"""
Multi-window crossing law -- numerical companion.

An oracle hides a target in one of M cells and announces nested windows
[0, B_1) < [0, B_2) < ... < [0, B_{n-1}) together with cumulative reliabilities
A_1 <= ... <= A_{n-1}  (A_0 = 0, B_0 = 0, A_n = 1, B_n = M).  The step posterior
spreads the block mass A_{i+1} - A_i uniformly over the block [B_i, B_{i+1}).

This script checks, with exact rational arithmetic wherever possible:
  1. the committed-cost block formula and its normalised form  M*Phi + 1/2;
  2. Bayes-optimality of committed search for calibrated oracles (brute force
     over all 6! = 720 orders in the worked instance);
  3. the anti-calibrated witness showing calibration cannot be dropped;
  4. the identity Phi = 1 - AUC and the single-window crossing law;
  5. the refinement (chord) identity;
  6. the exact finite gate and its continuum limit 1/(3 Phi);
  7. the failure of the "naive" gate that forgets the complement block;
  8. the outer-reliability gate.

Only the Python standard library is used.
"""
from __future__ import annotations

from fractions import Fraction as Fr
from itertools import permutations
from typing import Callable, List, Sequence, Tuple

Number = Fr


# ---------------------------------------------------------------------------
# Core objects
# ---------------------------------------------------------------------------

def step_posterior(B: Sequence[int], A: Sequence[Number]) -> List[Number]:
    """Posterior on cells 0..M-1, M = B[-1]: block i = [B[i], B[i+1]) gets mass A[i+1]-A[i]."""
    M = B[-1]
    p: List[Number] = [Fr(0)] * M
    for i in range(len(B) - 1):
        width = B[i + 1] - B[i]
        dens = (A[i + 1] - A[i]) / width
        for j in range(B[i], B[i + 1]):
            p[j] = dens
    return p


def probe_cost(p: Sequence[Number], slot: Sequence[int]) -> Number:
    """Expected number of probes: cell j is probed at (0-based) slot[j]."""
    return sum(((slot[j] + 1) * p[j] for j in range(len(p))), Fr(0))


def committed_cost_blocks(B: Sequence[int], A: Sequence[Number]) -> Number:
    """Sum_i (A_{i+1}-A_i) * (B_i + B_{i+1} + 1)/2 : block mass times mean 1-based slot."""
    return sum(((A[i + 1] - A[i]) * Fr(B[i] + B[i + 1] + 1, 2)
                for i in range(len(B) - 1)), Fr(0))


def gate_functional(x: Sequence[Number], A: Sequence[Number]) -> Number:
    """Phi(x, A) = Sum_i (A_{i+1}-A_i)(x_i + x_{i+1})/2  (x = normalised boundaries)."""
    return sum(((A[i + 1] - A[i]) * (x[i] + x[i + 1]) / 2
                for i in range(len(x) - 1)), Fr(0))


def auc(x: Sequence[Number], A: Sequence[Number]) -> Number:
    """Area under the piecewise-linear reliability curve through (x_i, A_i)."""
    return sum(((x[i + 1] - x[i]) * (A[i] + A[i + 1]) / 2
                for i in range(len(x) - 1)), Fr(0))


def min_blind(M: int) -> Number:
    """Stipulated reference price beta_M = (M+1)(2M+1)/(6M) = (1/M^2) Sum_{k<=M} k^2."""
    return Fr((M + 1) * (2 * M + 1), 6 * M)


def is_calibrated(B: Sequence[int], A: Sequence[Number]) -> bool:
    d = [(A[i + 1] - A[i]) / (B[i + 1] - B[i]) for i in range(len(B) - 1)]
    return all(d[i] >= d[i + 1] for i in range(len(d) - 1))


def bayes_cost(p: Sequence[Number]) -> Number:
    """Optimal cost: probe cells in order of decreasing posterior weight."""
    return sum(((k + 1) * w for k, w in enumerate(sorted(p, reverse=True))), Fr(0))


def banner(title: str) -> None:
    print("\n" + "=" * 72 + "\n" + title + "\n" + "=" * 72)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_worked_example() -> None:
    banner("1. Worked instance: M = 6, windows of widths 1 and 3, reliabilities 1/2, 5/6")
    B = [0, 1, 3, 6]
    A = [Fr(0), Fr(1, 2), Fr(5, 6), Fr(1)]
    p = step_posterior(B, A)
    print("posterior          :", [str(w) for w in p])
    print("calibrated?        :", is_calibrated(B, A))
    c = probe_cost(p, list(range(6)))
    print("committed cost     :", c, " (block formula:", committed_cost_blocks(B, A), ")")
    costs = [probe_cost(p, list(s)) for s in permutations(range(6))]
    print("orders examined    :", len(costs))
    print("minimum over orders:", min(costs), " maximum:", max(costs))
    print("orders achieving min:", sum(1 for v in costs if v == min(costs)))
    assert c == Fr(13, 6) and min(costs) == c
    x = [Fr(b, 6) for b in B]
    phi = gate_functional(x, A)
    print("Phi                :", phi, "   AUC:", auc(x, A), "   Phi + AUC =", phi + auc(x, A))
    print("M*Phi + 1/2        :", 6 * phi + Fr(1, 2))
    s_star = min_blind(6) / c
    print("best finite speedup beta_6 / cost =", s_star, "=", float(s_star))
    print("continuum speedup 1/(3 Phi)        =", 1 / (3 * phi), "=", float(1 / (3 * phi)))


def demo_calibration_needed() -> None:
    banner("2. Calibration is load-bearing (M = 6, masses 1/10 on [0,3), 9/10 on [3,6))")
    B = [0, 3, 6]
    A = [Fr(0), Fr(1, 10), Fr(1)]
    p = step_posterior(B, A)
    committed = probe_cost(p, list(range(6)))
    reversed_ = probe_cost(p, [5 - j for j in range(6)])
    print("calibrated?     :", is_calibrated(B, A))
    print("committed cost  :", committed)
    print("reversed cost   :", reversed_)
    assert reversed_ < committed == Fr(47, 10) and reversed_ == Fr(23, 10)


def demo_single_window(alpha: Number = Fr(4, 5), w: Number = Fr(1, 5)) -> None:
    banner("3. Single window = classical crossing law  w <= alpha - alpha_min(s)")
    x = [Fr(0), w, Fr(1)]
    A = [Fr(0), alpha, Fr(1)]
    phi = gate_functional(x, A)
    print(f"alpha = {alpha}, w = {w}:  Phi = {phi} = (w + 1 - alpha)/2 = {(w + 1 - alpha) / 2}")
    for s in [Fr(1), Fr(5, 4), Fr(3, 2), Fr(2)]:
        amin = 1 - Fr(2, 1) / (3 * s)
        gate = phi <= 1 / (3 * s)
        crossing = w <= alpha - amin
        print(f"  s = {str(s):>4}: alpha_min = {str(amin):>5}  gate {gate!s:>5}  crossing {crossing!s:>5}")
        assert gate == crossing


def demo_refinement() -> None:
    banner("4. Refinement identity: inserting (x', a') changes Phi by -(x_r-x_l)(a' - chord)/2")
    x = [Fr(0), Fr(1, 5), Fr(3, 5), Fr(1)]
    A = [Fr(0), Fr(1, 2), Fr(4, 5), Fr(1)]
    xl, xr, al, ar = x[1], x[2], A[1], A[2]
    for xp, ap in [(Fr(2, 5), Fr(3, 4)), (Fr(2, 5), Fr(13, 20)), (Fr(2, 5), Fr(3, 5))]:
        chord = al + (ar - al) * (xp - xl) / (xr - xl)
        x2 = x[:2] + [xp] + x[2:]
        A2 = A[:2] + [ap] + A[2:]
        delta = gate_functional(x2, A2) - gate_functional(x, A)
        pred = -(xr - xl) * (ap - chord) / 2
        verdict = "helps" if delta < 0 else ("neutral" if delta == 0 else "hurts")
        print(f"  x'={xp}, a'={ap}, chord={chord}:  dPhi = {delta}  predicted = {pred}  -> {verdict}")
        assert delta == pred


def demo_naive_gate_fails() -> None:
    banner("5. The naive gate (no complement block) is false")
    w, alpha, s = Fr(1, 2), Fr(1, 10), Fr(1)
    naive = alpha * w / 2
    true_phi = gate_functional([Fr(0), w, Fr(1)], [Fr(0), alpha, Fr(1)])
    print(f"window [0,{w}) with reliability {alpha}, target speedup s = {s}, threshold 1/(3s) = {Fr(1, 3)}")
    print(f"  naive sum over named windows only : {naive}  -> predicts reachable: {naive <= Fr(1, 3)}")
    print(f"  true gate functional (with complement): {true_phi} -> reachable: {true_phi <= Fr(1, 3)}")


def demo_finite_gate_and_limit() -> None:
    banner("6. Exact finite gate  s (M Phi + 1/2) <= beta_M  and its continuum limit")
    xs = [Fr(0), Fr(1, 6), Fr(1, 2), Fr(1)]
    A = [Fr(0), Fr(1, 2), Fr(5, 6), Fr(1)]
    phi = gate_functional(xs, A)
    for M in [6, 12, 60, 600, 6000]:
        B = [M * b.numerator // b.denominator for b in xs]
        p = step_posterior(B, A)
        opt = bayes_cost(p) if M <= 600 else committed_cost_blocks(B, A)
        assert opt == M * phi + Fr(1, 2) == committed_cost_blocks(B, A)
        s_max = min_blind(M) / opt
        print(f"  M = {M:>5}: optimal cost = {str(opt):>8}  max speedup = {float(s_max):.6f}")
    print(f"  continuum limit 1/(3 Phi) = {float(1 / (3 * phi)):.6f}")


def demo_outer_gate() -> None:
    banner("7. Outer-reliability gate: alpha_k >= alpha_min(s) + w_k (1 - alpha_k)")
    import random
    rng = random.Random(1)
    worst = Fr(10)
    for _ in range(2000):
        k = rng.randint(1, 4)
        xs = sorted(rng.sample(range(1, 100), k))
        x = [Fr(0)] + [Fr(v, 100) for v in xs] + [Fr(1)]
        al = sorted(rng.sample(range(1, 100), k))
        A = [Fr(0)] + [Fr(v, 100) for v in al] + [Fr(1)]
        phi = gate_functional(x, A)
        s = 1 / (3 * phi)                      # the largest reachable speedup
        amin = 1 - Fr(2) / (3 * s)
        slack = A[-2] - amin - x[-2] * (1 - A[-2])
        worst = min(worst, slack)
    print("  minimum slack over 2000 random menus (must be >= 0):", float(worst))
    assert worst >= 0


if __name__ == "__main__":
    demo_worked_example()
    demo_calibration_needed()
    demo_single_window()
    demo_refinement()
    demo_naive_gate_fails()
    demo_finite_gate_and_limit()
    demo_outer_gate()
    print("\nAll checks passed.")
