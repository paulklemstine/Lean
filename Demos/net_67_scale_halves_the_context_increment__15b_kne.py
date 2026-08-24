"""
demo.py -- Numerical demonstration of the attention-budget increment law.

Self-contained: standard library only.  Every function is inlined and typed.

Contents
--------
1.  The two measured budget laws and their fit to the data.
2.  Non-affinity of the large-model law, and discrete convexity.
3.  Terminal versus window-average increments (halving vs. quartering).
4.  Uniform deployment budgets: the 20-key corollary fails; 24 is least.
5.  Divergence of the two laws and the asymptotic budget ratio 2.
6.  Retention curves, knees, and the no-go theorem for fixed profiles.
7.  The degrading-rate family that reproduces the additive law.
8.  Hinge identifiability: the slope is only bounded, not measured.
9.  Grid resolution: why a spacing-4 sweep reads 20 where the truth is 18.
10. The scale exponent theta = log2/log3 and the 4.5B context-free threshold.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. The two measured budget laws
# ----------------------------------------------------------------------------

MEASURED_SMALL: Tuple[int, int, int] = (16, 20, 24)   # 0.5B at ctx 512/1024/2048
MEASURED_LARGE: Tuple[int, int, int] = (16, 16, 18)   # 1.5B at ctx 512/1024/2048
BASE_CONTEXT: int = 512


def knee_small(j: int) -> int:
    """Small (0.5B) model budget law: exactly affine, 16 + 4j."""
    return 16 + 4 * j


def knee_large(j: int) -> int:
    """Large (1.5B) model budget law: the hinge max(16, 14 + 2j)."""
    return max(16, 14 + 2 * j)


def context_of(j: int) -> int:
    """Context length after j doublings above the base context."""
    return BASE_CONTEXT * 2 ** j


def section(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_data_fit() -> None:
    section("1. The measured grid and the two closed-form laws")
    print(f"{'j':>2} {'context':>8} {'small':>7} {'law':>5} {'large':>7} {'law':>5}")
    for j in range(3):
        print(
            f"{j:>2} {context_of(j):>8} {MEASURED_SMALL[j]:>7} {knee_small(j):>5} "
            f"{MEASURED_LARGE[j]:>7} {knee_large(j):>5}"
        )
    assert tuple(knee_small(j) for j in range(3)) == MEASURED_SMALL
    assert tuple(knee_large(j) for j in range(3)) == MEASURED_LARGE
    print("\nBoth closed forms reproduce the measured grid exactly.")


# ----------------------------------------------------------------------------
# 2. Non-affinity and convexity
# ----------------------------------------------------------------------------

def affine_fits(values: Sequence[int]) -> List[Tuple[int, int]]:
    """All (k0, d) with values[j] == k0 + d*j, searched over a generous box."""
    fits: List[Tuple[int, int]] = []
    for k0 in range(0, 64):
        for d in range(0, 32):
            if all(v == k0 + d * j for j, v in enumerate(values)):
                fits.append((k0, d))
    return fits


def demo_non_affinity() -> None:
    section("2. The large-model triple is not affine; the hinge is convex")
    small_fits = affine_fits([knee_small(j) for j in range(3)])
    large_fits = affine_fits([knee_large(j) for j in range(3)])
    print(f"affine fits to (16, 20, 24): {small_fits}")
    print(f"affine fits to (16, 16, 18): {large_fits}   <-- none exist")
    assert small_fits == [(16, 4)]
    assert large_fits == []

    print("\nincrements of the large-model law:")
    incs = [knee_large(j + 1) - knee_large(j) for j in range(6)]
    print(f"  {incs}   (0 at the hinge, then a constant 2)")
    for j in range(20):
        assert 2 * knee_large(j + 1) <= knee_large(j) + knee_large(j + 2)
    print("discrete convexity 2K(j+1) <= K(j) + K(j+2) verified for j < 20.")


# ----------------------------------------------------------------------------
# 3. Terminal versus average increments
# ----------------------------------------------------------------------------

def demo_terminal_vs_average() -> None:
    section("3. Halving (terminal) versus quartering (window average)")
    term_s = knee_small(2) - knee_small(1)
    term_l = knee_large(2) - knee_large(1)
    avg_s = (knee_small(2) - knee_small(0)) / 2
    avg_l = (knee_large(2) - knee_large(0)) / 2
    print(f"terminal increments : small {term_s}, large {term_l}  -> ratio {term_s / term_l:.2f}")
    print(f"average  increments : small {avg_s}, large {avg_l}  -> ratio {avg_s / avg_l:.2f}")
    print("\nThe affine consistency test 2*(terminal) == (two-step rise):")
    print(f"  small: 2*{term_s} == {knee_small(2) - knee_small(0)}  -> "
          f"{2 * term_s == knee_small(2) - knee_small(0)}")
    print(f"  large: 2*{term_l} == {knee_large(2) - knee_large(0)}  -> "
          f"{2 * term_l == knee_large(2) - knee_large(0)}   <-- the hinge shows up here")
    assert (term_s, term_l) == (4, 2)
    assert (avg_s, avg_l) == (4.0, 1.0)
    assert 2 * term_l != knee_large(2) - knee_large(0)


# ----------------------------------------------------------------------------
# 4-5. Deployment budgets, divergence, asymptotic ratio
# ----------------------------------------------------------------------------

def safe_at(budget: int, j: int) -> bool:
    """A budget is safe at horizon j when it covers both models there."""
    return knee_small(j) <= budget and knee_large(j) <= budget


def least_safe_budget(horizon: int) -> int:
    """Least budget safe at every horizon j <= J (brute force, checked against 16+4J)."""
    budget = 0
    while not all(safe_at(budget, j) for j in range(horizon + 1)):
        budget += 1
    return budget


def demo_budgets() -> None:
    section("4. Deployment budgets: the 20-key corollary fails")
    print(f"20 covers the large model at 2048 with margin {20 - knee_large(2)}")
    print(f"20 covers the small model at 2048?  {knee_small(2) <= 20}  "
          f"(needs {knee_small(2)})")
    print(f"safe_at(20, 2) = {safe_at(20, 2)}   <-- the advertised corollary is false")
    assert not safe_at(20, 2)

    print("\nleast uniform budget by horizon J:")
    print(f"{'J':>2} {'context':>8} {'brute force':>12} {'16 + 4J':>9}")
    for J in range(6):
        brute = least_safe_budget(J)
        print(f"{J:>2} {context_of(J):>8} {brute:>12} {16 + 4 * J:>9}")
        assert brute == 16 + 4 * J
    assert least_safe_budget(2) == 24


def demo_divergence() -> None:
    section("5. Divergence of the two laws and the asymptotic ratio 2")
    print(f"{'j':>3} {'small':>7} {'large':>7} {'gap':>5} {'2j+2':>6} {'ratio':>8}")
    for j in [1, 2, 3, 5, 10, 50, 500, 5000]:
        gap = knee_small(j) - knee_large(j)
        ratio = knee_small(j) / knee_large(j)
        print(f"{j:>3} {knee_small(j):>7} {knee_large(j):>7} {gap:>5} {2 * j + 2:>6} {ratio:>8.5f}")
        assert gap == 2 * j + 2
    print("\ngap -> infinity (no finite budget is universally safe); ratio -> 2.")
    assert knee_small(10 ** 6) / knee_large(10 ** 6) > 1.999


# ----------------------------------------------------------------------------
# 6. Retention curves, knees, and the no-go theorem
# ----------------------------------------------------------------------------

def retained(profile: Sequence[float], k: int) -> float:
    """Mass carried by the top k keys of a sorted attention profile."""
    return float(sum(profile[:k]))


def knee(profile: Sequence[float], tau: float) -> int:
    """Smallest k whose retained mass reaches tau (len(profile)+1 if unreachable)."""
    total = 0.0
    for k, w in enumerate(profile):
        if total >= tau:
            return k
        total += w
    return len(profile) if total >= tau else len(profile) + 1


def geometric_profile(r: float, n: int) -> List[float]:
    """Truncated geometric profile (1-r) r^i / (1 - r^n) on a context of n keys."""
    z = 1.0 - r ** n
    return [(1.0 - r) * r ** i / z for i in range(n)]


def demo_no_go() -> None:
    section("6. No fixed attention profile can produce an additive increment")
    tau = 0.95
    for r in (0.7, 0.8, 0.9):
        bound = math.ceil(math.log(1.0 - tau) / math.log(r))
        knees = [knee(geometric_profile(r, 2 ** j), tau) for j in range(4, 13)]
        print(f"r = {r}:  knees at contexts 2^4..2^12 = {knees}   "
              f"ceil bound = {bound}")
        assert max(knees) <= bound
        assert knees[-1] == knees[-2]        # eventually constant
    print("\nThe knee saturates: increments die out, so 16 + 4j is unreachable")
    print("for ANY fixed profile of finite mass (the obstruction is summability).")


# ----------------------------------------------------------------------------
# 7. The degrading-rate family that does work
# ----------------------------------------------------------------------------

def knee_cts(lam: float, delta: float) -> float:
    """Keys needed to push an exponential tail e^{-lam k} below the budget delta."""
    return math.log(1.0 / delta) / lam


def lam_at(lam0: float, j: int) -> float:
    """Decay rate after j context doublings when rate ~ 1 / log(context)."""
    return lam0 / (j + 1)


def demo_degrading_family() -> None:
    section("7. Degrading rate lam_j = lam0/(j+1) reproduces the additive law")
    delta = math.exp(-4.0)
    print(f"tail budget delta = e^-4, so log(1/delta) = {math.log(1 / delta):.1f}\n")
    print(f"{'j':>2} {'k(lam0=1)':>11} {'incr':>6} {'k(lam0=2)':>11} {'incr':>6}")
    for j in range(5):
        k1 = knee_cts(lam_at(1.0, j), delta)
        k2 = knee_cts(lam_at(2.0, j), delta)
        i1 = knee_cts(lam_at(1.0, j + 1), delta) - k1
        i2 = knee_cts(lam_at(2.0, j + 1), delta) - k2
        print(f"{j:>2} {k1:>11.3f} {i1:>6.2f} {k2:>11.3f} {i2:>6.2f}")
        assert abs(i1 - (knee_small(j + 1) - knee_small(j))) < 1e-9
        if j >= 1:
            assert abs(i2 - (knee_large(j + 1) - knee_large(j))) < 1e-9
        assert abs(i2 - i1 / 2) < 1e-12
    print("\nDoubling the peakedness lam0 exactly halves the per-doubling increment.")
    print("Converse check: an affine knee of slope s forces lam_j = (log(1/delta)/s)/(j+1).")
    s = 4.0
    for j in range(5):
        recovered = (math.log(1.0 / delta) / s) / (j + 1)
        assert abs(knee_cts(recovered, delta) - s * (j + 1)) < 1e-9
    print("  verified for s = 4 at j = 0..4.")


# ----------------------------------------------------------------------------
# 8. Hinge identifiability
# ----------------------------------------------------------------------------

def hinge(floor: int, base: int, slope: int, j: int) -> int:
    return max(floor, base + slope * j)


def hinge_fits(floor: int, data: Sequence[int], max_base: int = 40,
               max_slope: int = 40) -> List[Tuple[int, int]]:
    """All (base, slope) with the given floor passing through the measured data."""
    return [
        (b, s)
        for b in range(max_base + 1)
        for s in range(max_slope + 1)
        if all(hinge(floor, b, s, j) == v for j, v in enumerate(data))
    ]


def demo_identifiability() -> None:
    section("8. Three points bound the hinge slope but do not identify it")
    fits = hinge_fits(16, MEASURED_LARGE)
    print(f"all hinge fits with floor 16 through (16, 16, 18):")
    for b, s in fits:
        print(f"    base = {b:>2}, slope = {s}   "
              f"(check: base + 2*slope = {b + 2 * s}, base + slope = {b + s} <= 16)")
    slopes = sorted({s for _, s in fits})
    print(f"\nadmissible slopes: {slopes}  -> only the bound 2 <= s <= 9")
    assert min(slopes) == 2 and max(slopes) == 9
    assert (14, 2) in fits and (12, 3) in fits

    print("\npredictions at the next octave (j = 3, context 4096):")
    for b, s in [(14, 2), (12, 3)]:
        print(f"    base = {b}, slope = {s}  ->  {hinge(16, b, s, 3)} keys")
    assert hinge(16, 14, 2, 3) == 20 and hinge(16, 12, 3, 3) == 21
    print("One measurement at 4096 separates the fits by a single key.")


# ----------------------------------------------------------------------------
# 9. Grid resolution
# ----------------------------------------------------------------------------

def knee_on_grid(profile: Sequence[float], tau: float, d: int) -> int:
    """Knee as read off a sweep restricted to multiples of d."""
    k = 0
    while k <= len(profile):
        if retained(profile, k) >= tau:
            return k
        k += d
    return -1


def demo_grid_resolution() -> None:
    section("9. Grid resolution: a spacing-4 sweep reads 20 where the truth is 18")
    flat: List[float] = [1.0] * 64          # retained(k) = k
    true_knee = knee(flat, 18.0)
    for d in (1, 2, 3, 4, 8):
        grid = knee_on_grid(flat, 18.0, d)
        ok = true_knee <= grid < true_knee + d
        print(f"  spacing d = {d}:  grid knee = {grid:>2}, true = {true_knee}, "
              f"over-read = {grid - true_knee}, within bound: {ok}")
        assert ok
    assert knee_on_grid(flat, 18.0, 4) == 20
    print("\nThis is exactly the earlier coarse reading of 20 versus the fine reading of 18.")


# ----------------------------------------------------------------------------
# 10. The scale exponent and the context-free threshold
# ----------------------------------------------------------------------------

THETA: float = math.log(2.0) / math.log(3.0)


def lam0_of(n_billion: float) -> float:
    """Peakedness calibrated so lam0(0.5) = 1 and lam0(1.5) = 2."""
    return (2.0 * n_billion) ** THETA


def incr_at(n_billion: float) -> float:
    """Predicted keys-per-doubling increment at parameter count N (billions)."""
    return 4.0 * (2.0 * n_billion) ** (-THETA)


def solve_threshold(target: float, lo: float = 0.05, hi: float = 1e4,
                    iters: int = 200) -> float:
    """Bisection for the N with incr_at(N) == target (incr_at is strictly decreasing)."""
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        if incr_at(mid) > target:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def demo_scale_threshold() -> None:
    section("10. The scale exponent and the 4.5B context-free threshold")
    print(f"theta = log2/log3 = {THETA:.6f},  3^theta = {3.0 ** THETA:.6f}\n")
    print(f"{'N (B)':>7} {'lam0(N)':>9} {'incr(N)':>9}  note")
    notes: Dict[float, str] = {
        0.5: "measured: +4 keys per doubling",
        1.5: "measured: +2 keys per doubling",
        4.5: "exactly 1 key per doubling  <-- threshold",
        7.0: "predicted bracket 1/2 < incr < 1",
        13.5: "exactly 1/2 key per doubling",
        70.0: "effectively context-free",
    }
    for n in sorted(notes):
        print(f"{n:>7.1f} {lam0_of(n):>9.4f} {incr_at(n):>9.4f}  {notes[n]}")
    assert abs(incr_at(0.5) - 4.0) < 1e-12
    assert abs(incr_at(1.5) - 2.0) < 1e-12
    assert abs(incr_at(4.5) - 1.0) < 1e-12
    assert abs(incr_at(13.5) - 0.5) < 1e-12
    assert 0.5 < incr_at(7.0) < 1.0

    root = solve_threshold(1.0)
    print(f"\nnumerical solution of incr(N) = 1:  N = {root:.6f} B  (exact value 4.5)")
    assert abs(root - 4.5) < 1e-6

    print("\nfalsifiable 7B prediction: on an integer key grid the knee should move")
    print(f"by 0 or 1 key from 2048 to 4096 (predicted move {incr_at(7.0):.4f} keys).")


# ----------------------------------------------------------------------------

def main() -> None:
    demo_data_fit()
    demo_non_affinity()
    demo_terminal_vs_average()
    demo_budgets()
    demo_divergence()
    demo_no_go()
    demo_degrading_family()
    demo_identifiability()
    demo_grid_resolution()
    demo_scale_threshold()
    section("All demonstrations completed and all assertions passed.")


if __name__ == "__main__":
    main()
