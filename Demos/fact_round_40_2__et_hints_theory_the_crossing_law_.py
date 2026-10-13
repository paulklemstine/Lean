"""
The crossing law for interval hints: numerical demonstrations.

Setting.  A target hides in one of M cells (numbered 0..M-1).  An oracle names a
window of W cells and says "the target is in here with probability alpha".
A searcher probes cells one at a time in some order sigma; the cost of an order
is the expected number of probes until the target is found.

This script checks, with exact rational arithmetic wherever possible:

  1. the displacement law and Bayes = Committed (brute force over all M! orders);
  2. the closed form for the interleaved order and its strict domination;
  3. the exact Bayes cost  min((W+1+(1-a)M)/2, (M-W+1+aM)/2);
  4. the crossing law  s <= S(alpha, w)  <=>  w <= alpha - alpha_min(s);
  5. the numbers for a measured 5.19x speedup (gate 0.87155, width 0.02845);
  6. the finite-M gate and its convergence;
  7. the two-sided Bayes gate (the anti-reliable witness M=4, W=2, alpha=0);
  8. conservative pricing: random posteriors always do at least as well
     as the stipulated price.

Self-contained: standard library only.
"""

from __future__ import annotations

import itertools
import random
from fractions import Fraction as F
from typing import Callable, Sequence

Weights = Sequence[F]
Order = Sequence[int]


# ---------------------------------------------------------------------------
# Core cost model
# ---------------------------------------------------------------------------

def probe_cost(q: Weights, order: Order) -> F:
    """Expected probes: the cell probed in slot i (0-based) costs i+1 probes."""
    return sum((F(i + 1) * q[cell] for i, cell in enumerate(order)), F(0))


def two_level(M: int, W: int, a: F, b: F) -> list[F]:
    """Weight a on the window cells 0..W-1 and weight b on the other cells."""
    return [a if j < W else b for j in range(M)]


def hint_posterior(M: int, W: int, alpha: F) -> list[F]:
    """Window mass alpha spread uniformly; mass 1-alpha spread over the rest."""
    return two_level(M, W, alpha / W, (1 - alpha) / (M - W))


def opt_cost_bruteforce(q: Weights) -> F:
    """Bayes-optimal cost by exhaustive search over all M! orders."""
    return min(probe_cost(q, p) for p in itertools.permutations(range(len(q))))


def opt_cost_sorted(q: Weights) -> F:
    """Bayes-optimal cost by the rearrangement inequality (probe heaviest first)."""
    order = sorted(range(len(q)), key=lambda j: -q[j])
    return probe_cost(q, order)


def min_blind(M: int) -> F:
    """Blind cost under the min-law prior: (M+1)(2M+1)/(6M)."""
    return F((M + 1) * (2 * M + 1), 6 * M)


def hinted_cost(M: int, W: int, alpha: F) -> F:
    """Stipulated two-number cost of the committed scan: (W+1+(1-alpha)M)/2."""
    return (W + 1 + (1 - alpha) * M) / 2


def priced_speedup_M(M: int, W: int, alpha: F) -> F:
    """S_M(W, alpha) = (M+1)(2M+1) / (3M((1-alpha)M + W + 1))."""
    return min_blind(M) / hinted_cost(M, W, alpha)


def alpha_min(s: F) -> F:
    """The continuum reliability gate 1 - 2/(3s)."""
    return 1 - F(2) / (3 * s)


def alpha_min_M(M: int, s: F) -> F:
    """The finite gate 1 - (M+1)(2M+1)/(3 M^2 s)."""
    return 1 - F((M + 1) * (2 * M + 1)) / (3 * M * M * s)


def priced_speedup(alpha: F, w: F) -> F:
    """Continuum priced speedup S(alpha, w) = 2 / (3(1 - alpha + w))."""
    return F(2) / (3 * (1 - alpha + w))


def window_slot_sum(order: Order, W: int) -> int:
    """Sum of (slot index + 1) over slots in which a window cell is probed."""
    return sum(i + 1 for i, cell in enumerate(order) if cell < W)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def header(title: str) -> None:
    print("\n" + "=" * 72 + f"\n{title}\n" + "=" * 72)


def demo_displacement_and_bayes() -> None:
    header("1. Displacement law and Bayes = Committed (M = 6, all 720 orders)")
    M = 6
    cells_ok = 0
    total = 0
    disp_ok = True
    for W in range(1, M):
        for k in range(11):
            alpha = F(k, 10)
            q = hint_posterior(M, W, alpha)
            a, b = q[0], q[-1]
            committed = probe_cost(q, range(M))
            best = None
            for p in itertools.permutations(range(M)):
                c = probe_cost(q, p)
                pred = committed + (a - b) * (window_slot_sum(p, W) - F(W * (W + 1), 2))
                disp_ok &= (c == pred)
                best = c if best is None else min(best, c)
            outside_first = probe_cost(q, list(range(W, M)) + list(range(W)))
            total += 1
            cells_ok += (best == min(committed, outside_first))
    print(f"displacement law exact for every order and cell: {disp_ok}")
    print(f"Bayes cost = min(committed, outside-first) in {cells_ok}/{total} cells")
    W, alpha = 2, F(7, 10)
    q = hint_posterior(M, W, alpha)
    best = opt_cost_bruteforce(q)
    opt_orders = [p for p in itertools.permutations(range(M)) if probe_cost(q, p) == best]
    window_first = all(set(p[:W]) == set(range(W)) for p in opt_orders)
    print(f"W=2, alpha=0.7: {len(opt_orders)} optimal orders "
          f"(= 2!*4! = {2 * 24}); all window-first: {window_first}")


def demo_interleaved() -> None:
    header("2. Interleaved order: closed-form excess (a-b) W(W-1)/2")
    M, W, a, b = 8, 3, F(1, 5), F(1, 25)
    q = two_level(M, W, a, b)
    committed = probe_cost(q, range(M))
    interleaved = [0, 3, 1, 4, 2, 5, 6, 7]  # window cells in slots 0, 2, 4
    excess = probe_cost(q, interleaved) - committed
    print(f"M=8, W=3, a=1/5, b=1/25: excess = {excess}  "
          f"(formula {(a - b) * W * (W - 1) / 2})")


def demo_bayes_exact() -> None:
    header("3. Exact Bayes cost of the hint posterior")
    rng = random.Random(20260828)
    ok = True
    for _ in range(200):
        M = rng.randint(3, 40)
        W = rng.randint(1, M - 1)
        alpha = F(rng.randint(0, 100), 100)
        q = hint_posterior(M, W, alpha)
        formula = min((W + 1 + (1 - alpha) * M) / 2, (M - W + 1 + alpha * M) / 2)
        ok &= (opt_cost_sorted(q) == formula)
    print(f"min((W+1+(1-a)M)/2, (M-W+1+aM)/2) matches the sorted optimum "
          f"in 200/200 random cases: {ok}")


def demo_crossing_law() -> None:
    header("4. The crossing law  s <= S(alpha,w)  <=>  w <= alpha - alpha_min(s)")
    rng = random.Random(1)
    agree = 0
    N = 10000
    for _ in range(N):
        s = F(rng.randint(101, 1000), 100)
        alpha = F(rng.randint(0, 1000), 1000)
        w = F(rng.randint(1, 1000), 1000)
        lhs = s <= priced_speedup(alpha, w)
        rhs = w <= alpha - alpha_min(s)
        agree += (lhs == rhs)
    print(f"both sides agree on {agree}/{N} random (s, alpha, w)")
    print("width cannot substitute: alpha = alpha_min(5) exactly, tiny widths:")
    for w in [F(1, 10), F(1, 1000), F(1, 10 ** 6)]:
        print(f"   w = {float(w):<8g} S = {float(priced_speedup(alpha_min(F(5)), w)):.6f} < 5")


def demo_paper_numbers() -> None:
    header("5. A measured 5.19x speedup")
    s = F(519, 100)
    g = alpha_min(s)
    print(f"alpha_min(5.19) = {float(g):.7f}  (strictly between 0.87154 and 0.87155)")
    print(f"crossing width at alpha = 0.90: mu/M = {float(F(9, 10) - g):.7f}")
    print(f"check: S(0.9, 0.9 - alpha_min) = {float(priced_speedup(F(9, 10), F(9, 10) - g))}")
    print(f"M=300, W=9, alpha=0.9: S_M = {float(priced_speedup_M(300, 9, F(9, 10))):.5f}")
    q = hint_posterior(300, 9, F(9, 10))
    brute = min_blind(300) / probe_cost(q, range(300))
    print(f"   brute-force sum gives exactly the same: "
          f"{brute == priced_speedup_M(300, 9, F(9, 10))}")


def demo_finite_gate() -> None:
    header("6. Finite gate alpha_min^M(5.19) -> alpha_min(5.19)")
    s = F(519, 100)
    for M in [10, 100, 300, 1000, 10 ** 4, 10 ** 6]:
        print(f"   M = {M:<8d} alpha_min^M = {float(alpha_min_M(M, s)):.6f}")
    print(f"   limit       alpha_min   = {float(alpha_min(s)):.6f}")


def demo_two_sided() -> None:
    header("7. The Bayes gate is two-sided (anti-reliable hints)")
    M, W, alpha = 4, 2, F(0)
    q = hint_posterior(M, W, alpha)
    S = min_blind(M) / opt_cost_bruteforce(q)
    print(f"M=4, W=2, alpha=0: Bayes speedup = {S} >= 5/4, "
          f"yet alpha_min^4(5/4) = {alpha_min_M(M, F(5, 4))} > alpha = 0")
    print("   (an alpha=0 hint is a perfect hint for the complement)")


def demo_conservative() -> None:
    header("8. Conservative pricing: true Bayes speedup >= stipulated speedup")
    rng = random.Random(20260828)
    M = 6
    worst = F(0)
    for _ in range(300):
        raw = [F(rng.randint(1, 1000)) for _ in range(M)]
        tot = sum(raw)
        q = [x / tot for x in raw]
        W = rng.randint(1, M - 1)
        alpha = sum(q[:W])
        ratio = opt_cost_bruteforce(q) / hinted_cost(M, W, alpha)
        worst = max(worst, ratio)
        refl = probe_cost(q, range(M))
        rev = probe_cost(q, list(range(W - 1, -1, -1)) + list(range(M - 1, W - 1, -1)))
        assert refl + rev == W + 1 + (1 - alpha) * M  # pairing identity
    print(f"300 random posteriors: max Bayes/stipulated cost = {float(worst):.4f} (<= 1)")
    print("pairing identity (scan + block reversal = W+1+(1-alpha)M) held every time")


def main() -> None:
    demo_displacement_and_bayes()
    demo_interleaved()
    demo_bayes_exact()
    demo_crossing_law()
    demo_paper_numbers()
    demo_finite_gate()
    demo_two_sided()
    demo_conservative()


if __name__ == "__main__":
    main()
