#!/usr/bin/env python3
"""
Interval hints priced by coverage and width -- numerical companion.

An oracle names a window of W of the M candidate cells; the window contains the
hidden target J with probability alpha (the *coverage*).  The committed procedure
scans the window first, then the rest.  This script checks, with exact rational
arithmetic wherever possible, every headline result:

  1. Greedy (non-increasing posterior) order is Bayes-optimal (brute force).
  2. Exact law  S = (M+1) / ((1-alpha) M + W + 1).
  3. Window-first is Bayes-optimal  iff  alpha >= W/M  (sharp boundary).
  4. Coverage ceiling 1/(1-alpha), width ceiling (M+1)/(W+1), exchange rate.
  5. Continuum law S = 1/(1-alpha+w) and the 5.19x crossing calibration.
  6. Min-law prior P(J=j) = (2(M-j)+1)/M^2, blind cost and block-hint speedup.
  7. Concavity of the Bayes cost (information never hurts).
  8. Misspecified coverage regret (alpha-beta) M / 2.
  9. A Monte-Carlo sanity check of the exact formulas.

Only the Python standard library is used.
"""
from __future__ import annotations

import itertools
import random
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Num = Fraction


# ---------------------------------------------------------------- core model
def probe_cost(q: Sequence[Num], order: Sequence[int]) -> Num:
    """Expected probes when probe i (1-based) inspects cell order[i-1]."""
    return sum((Fraction(i + 1) * q[c] for i, c in enumerate(order)), Fraction(0))


def hint_posterior(M: int, W: int, alpha: Num) -> List[Num]:
    """Truthful posterior: alpha/W inside the window {0..W-1}, (1-alpha)/(M-W) outside."""
    return [alpha / W if j < W else (1 - alpha) / (M - W) for j in range(M)]


def hinted_cost(M: int, W: int, alpha: Num) -> Num:
    """Cost of the committed (window-first, then ascending) procedure."""
    return probe_cost(hint_posterior(M, W, alpha), range(M))


def blind_cost(M: int) -> Num:
    return probe_cost([Fraction(1, M)] * M, range(M))


def speedup_formula(M: int, W: int, alpha: Num) -> Num:
    return Fraction(M + 1) / ((1 - alpha) * M + W + 1)


def opt_cost_bruteforce(q: Sequence[Num]) -> Tuple[Num, Tuple[int, ...]]:
    """Minimum expected probes over all n! orders (small n only)."""
    best: Tuple[Num, Tuple[int, ...]] | None = None
    for perm in itertools.permutations(range(len(q))):
        c = probe_cost(q, perm)
        if best is None or c < best[0]:
            best = (c, perm)
    assert best is not None
    return best


def greedy_order(q: Sequence[Num]) -> List[int]:
    return sorted(range(len(q)), key=lambda j: (-q[j], j))


def continuum_speedup(alpha: float, w: float) -> float:
    return 1.0 / (1.0 - alpha + w)


# ---------------------------------------------------------------- min-law
def min_law(M: int) -> List[Num]:
    """P(J = i+1) for J = min(p, q), p, q iid uniform on {1..M}; index i = 0..M-1."""
    return [Fraction(2 * (M - 1 - i) + 1, M * M) for i in range(M)]


def min_law_block_cost(k: int, W: int) -> Num:
    """Perfect-coverage block hint: oracle names the width-W block containing J."""
    M = k * W
    q = min_law(M)
    return sum((Fraction(r + 1) * q[b * W + r] for b in range(k) for r in range(W)), Fraction(0))


# ---------------------------------------------------------------- demos
def section(title: str) -> None:
    print("\n" + "=" * 74 + f"\n{title}\n" + "=" * 74)


def demo_bruteforce() -> None:
    section("1-3. Bayes optimality by brute force over all 720 orders (M=6, W=2)")
    M, W = 6, 2
    for alpha in (Fraction(1, 2), Fraction(1, 3), Fraction(1, 4)):
        q = hint_posterior(M, W, alpha)
        committed = hinted_cost(M, W, alpha)
        opt, perm = opt_cost_bruteforce(q)
        greedy = probe_cost(q, greedy_order(q))
        tag = "alpha >= w" if alpha * M >= W else "alpha <  w"
        print(f"alpha={str(alpha):>4}  ({tag})  committed={str(committed):>5}  "
              f"optimum={str(opt):>5}  greedy={str(greedy):>5}  optimal order={perm}")
        assert greedy == opt
        assert (committed == opt) == (alpha * M >= W)


def demo_exact_law() -> None:
    section("2. Exact law S = (M+1)/((1-alpha)M + W + 1), checked for many (M, W, alpha)")
    count = 0
    for M in range(2, 30):
        for W in range(1, M):
            for alpha in (Fraction(0), Fraction(1, 3), Fraction(7, 10), Fraction(1)):
                assert hinted_cost(M, W, alpha) == (W + 1 + (1 - alpha) * M) / 2
                assert blind_cost(M) / hinted_cost(M, W, alpha) == speedup_formula(M, W, alpha)
                count += 1
    print(f"verified exactly in {count} cases")
    M = 1000
    print(f"\nUniform prior, M = {M}: speedup table (rows: w = W/M, columns: alpha)")
    alphas = [Fraction(1, 2), Fraction(3, 4), Fraction(9, 10), Fraction(1)]
    print("   w   | " + "  ".join(f"a={float(a):<5}" for a in alphas))
    for w in (Fraction(2, 100), Fraction(5, 100), Fraction(10, 100), Fraction(20, 100)):
        W = int(w * M)
        row = "  ".join(f"{float(speedup_formula(M, W, a)):7.2f}" for a in alphas)
        print(f" {float(w):.2f}  | {row}")


def demo_ceilings() -> None:
    section("4. Ceilings and the one-for-one exchange rate")
    M = 1000
    for W, alpha in ((1, Fraction(9, 10)), (20, Fraction(9, 10)), (20, Fraction(1)), (200, Fraction(99, 100))):
        S = speedup_formula(M, W, alpha)
        cov = 1 / (1 - alpha) if alpha < 1 else None
        wid = Fraction(M + 1, W + 1)
        print(f"W={W:>3} alpha={float(alpha):.2f}: S={float(S):7.3f}  coverage ceiling="
              f"{'inf' if cov is None else f'{float(cov):7.3f}'}  width ceiling={float(wid):7.3f}")
        assert S <= wid and (cov is None or S <= cov)
    # exchange rate: 30 cells of width trade for 30/M of coverage
    a1, W1 = Fraction(9, 10), 20
    W2 = 50
    a2 = a1 + Fraction(W2 - W1, M)
    print(f"\n(alpha={float(a1)}, W={W1}) and (alpha={float(a2)}, W={W2}) give "
          f"{float(speedup_formula(M, W1, a1)):.4f} and {float(speedup_formula(M, W2, a2)):.4f}")
    assert speedup_formula(M, W1, a1) == speedup_formula(M, W2, a2)


def demo_continuum_and_crossing() -> None:
    section("5. Continuum law S = 1/(1 - alpha + w) and the 5.19x crossing")
    for M in (10, 100, 1000, 10**5):
        W = M // 20
        print(f"M={M:>6}, w=0.05, alpha=0.9: exact {float(speedup_formula(M, W, Fraction(9, 10))):.5f}"
              f"  -> continuum {continuum_speedup(0.9, 0.05):.5f}")
    print()
    for w in (0.02, 0.03, 0.04, 0.05):
        alpha = 1 - 1 / 5.19 + w
        print(f"w={w:.2f}: a 5.19x gain needs alpha = {alpha:.4f};   "
              f"a 90% window would give {continuum_speedup(0.9, w):.2f}x")
        assert 0.82 < alpha < 0.86 and continuum_speedup(0.9, w) > 5.19


def demo_min_law() -> None:
    section("6. The min-law prior J = min(p, q)")
    M = 7
    for j in range(1, M + 1):
        cnt = sum(1 for p in range(1, M + 1) for r in range(1, M + 1) if min(p, r) == j)
        assert cnt == 2 * (M - j) + 1
    print(f"counting identity #{{(p,q): min = j}} = 2(M-j)+1 verified for M={M}")
    for M in (5, 50, 500):
        q = min_law(M)
        assert sum(q) == 1 and all(q[i] > q[i + 1] for i in range(M - 1))
        mean = probe_cost(q, range(M))
        assert mean == Fraction((M + 1) * (2 * M + 1), 6 * M)
        print(f"M={M:>3}: blind (ascending) cost = {float(mean):9.4f}  = (M+1)(2M+1)/(6M)")
    print("\nPerfect-coverage block hints: exact speedup vs continuum 2/(w(3-w))")
    for k, W in ((50, 4), (20, 10), (10, 20), (5, 40)):
        M = k * W
        cost = min_law_block_cost(k, W)
        assert cost == Fraction((W + 1) * (3 * M - W + 1), 6 * M)
        S = probe_cost(min_law(M), range(M)) / cost
        w = W / M
        print(f"M={M}, W={W:>2} (w={w:.2f}): exact S={float(S):7.3f}   continuum {2 / (w * (3 - w)):7.3f}")
    M = 10**4
    for w in (0.02, 0.05, 0.10, 0.20):
        W = round(w * M)
        S = Fraction((M + 1) * (2 * M + 1), (W + 1) * (3 * M - W + 1))
        print(f"M=10^4, w={w:.2f}: closed-form block speedup = {float(S):6.2f}")


def demo_concavity() -> None:
    section("7. Information never hurts: concavity of the Bayes cost")
    rng = random.Random(20260828)
    n = 5
    for _ in range(5):
        q1 = [Fraction(rng.randint(0, 9)) for _ in range(n)]
        q2 = [Fraction(rng.randint(0, 9)) for _ in range(n)]
        t = Fraction(rng.randint(0, 10), 10)
        mix = [t * a + (1 - t) * b for a, b in zip(q1, q2)]
        lhs = t * opt_cost_bruteforce(q1)[0] + (1 - t) * opt_cost_bruteforce(q2)[0]
        rhs = opt_cost_bruteforce(mix)[0]
        print(f"t={str(t):>4}:  t*opt(q1)+(1-t)*opt(q2) = {float(lhs):7.2f}  <=  opt(mix) = {float(rhs):7.2f}")
        assert lhs <= rhs


def demo_misspecified() -> None:
    section("8. Misspecified coverage: claimed alpha, true beta")
    M, W = 1000, 30
    for alpha, beta in ((Fraction(9, 10), Fraction(9, 10)), (Fraction(9, 10), Fraction(7, 10)),
                        (Fraction(9, 10), Fraction(1, 50))):
        realized = probe_cost(hint_posterior(M, W, beta), range(M))
        regret = realized - hinted_cost(M, W, alpha)
        assert regret == (alpha - beta) * M / 2
        opt = probe_cost(hint_posterior(M, W, beta), greedy_order(hint_posterior(M, W, beta)))
        print(f"claimed {float(alpha):.2f}, true {float(beta):.2f}: extra probes = {float(regret):6.1f}"
              f" = (a-b)M/2;  realized S = {float(blind_cost(M) / realized):5.2f};"
              f"  Bayes optimum under truth = {float(opt):6.1f} vs committed {float(realized):6.1f}")


def demo_monte_carlo(trials: int = 200_000) -> None:
    section("9. Monte-Carlo check (uniform prior, seed 20260828)")
    rng = random.Random(20260828)
    M, W, alpha = 200, 10, 0.9
    total = 0
    for _ in range(trials):
        if rng.random() < alpha:
            j = rng.randrange(W)
        else:
            j = rng.randrange(W, M)
        total += j + 1  # window-first ascending scan finds cell j at probe j+1
    mc = total / trials
    exact = float(hinted_cost(M, W, Fraction(9, 10)))
    print(f"M={M}, W={W}, alpha=0.9: MC mean probes {mc:.3f}  vs exact {exact:.3f};  "
          f"speedup MC {(M + 1) / 2 / mc:.3f} vs exact {float(speedup_formula(M, W, Fraction(9, 10))):.3f}")


def main() -> None:
    demo_bruteforce()
    demo_exact_law()
    demo_ceilings()
    demo_continuum_and_crossing()
    demo_min_law()
    demo_concavity()
    demo_misspecified()
    demo_monte_carlo()
    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
