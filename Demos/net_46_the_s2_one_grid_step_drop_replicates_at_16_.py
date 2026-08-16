"""
Amplitude identifiability of a knee ladder — numerical demonstration.
=====================================================================

Self-contained numerical companion to the paper "Amplitude Identifiability of a
Knee Ladder".  Everything is exact rational arithmetic (``fractions.Fraction``)
so that the half-open interval endpoints -- which is where the whole argument
lives -- are never blurred by floating point.

Setting
-------
A pruned-attention model keeps, for each query, only its top-``k`` scored keys.
The retained-quality curve ``C(k)`` is the fraction of full-model held-out
accuracy that survives; it is monotone.  Fixing a bar ``b = 0.98``, the *knee*
is the least budget clearing the bar.  Knees are measured by a sweep over a
coarse grid of step ``s = 32`` at doubling contexts ``ctx = 128 * 2**i``.

The one-parameter law under test is ``kappa(i) = A * 2**i`` (the "product law"
``d*ctx/32`` at depth ``d = 4`` is the case ``A = 16``).

What is demonstrated
--------------------
1.  Knee extraction from the measured sweeps, with the *predecessor* budget.
2.  The Window Lemma:  reported knee ``k`` after predecessor ``p``  =>
    continuous crossing point in ``(p, k]``, hence amplitude in
    ``(p/2**i, k/2**i]``.
3.  The Amplitude Conflict: the two second-seed windows are disjoint, so no
    single amplitude explains both -- yet each rung alone is explainable.
4.  Sharp first-seed identifiability: the admissible set is exactly ``(14, 16]``.
5.  The decisive experiment at ``ctx = 4096``: three predicted knee ranges,
    pairwise separated by at least one full grid step.
6.  Certified band ``A in (8, 16]`` and the deployable speedup band 8x-16x.
7.  Adversarial checks: non-robustness of the reading at the round's own
    0.002 resolution; the shift artefact; the universal quantisation lemma.
8.  Asymptotics: knee ratio -> 1 and speedup -> 8x.
9.  Resolution rate: window width ``32/2**N`` versus the indistinguishability
    lower bound ``16/2**N``.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import ceil
from typing import Iterable, List, Optional, Sequence, Tuple

Rat = Fraction

# --------------------------------------------------------------------------- #
# 0.  The measured data                                                        #
# --------------------------------------------------------------------------- #

GRID_STEP: int = 32
BAR: Rat = Fraction(98, 100)  # 0.98 of full-model accuracy

# Seed-2 sweep at ctx = 2048 (rung 4): (budget, retained fraction).
SWEEP_2048_SEED2: List[Tuple[int, Rat]] = [
    (96, Fraction(956, 1000)),
    (128, Fraction(965, 1000)),
    (160, Fraction(971, 1000)),
    (192, Fraction(978, 1000)),
    (224, Fraction(982, 1000)),
    (256, Fraction(986, 1000)),
    (288, Fraction(987, 1000)),
    (384, Fraction(992, 1000)),
    (512, Fraction(993, 1000)),
    (768, Fraction(998, 1000)),
    (1024, Fraction(998, 1000)),
]

# Seed-1 values recorded at the same cell (only the deciding budgets).
SWEEP_2048_SEED1: List[Tuple[int, Rat]] = [
    (96, Fraction(939, 1000)),
    (224, Fraction(976, 1000)),
    (256, Fraction(986, 1000)),
]

# The full two-seed ladder: rung i -> (ctx, product prediction, seed1, seed2).
LADDER: List[Tuple[int, int, int, int, int]] = [
    # (i, ctx, prediction P_i, seed-1 knee, seed-2 knee)
    (0, 128, 16, 16, 16),
    (1, 256, 32, 32, 32),
    (2, 512, 64, 64, 64),
    (3, 1024, 128, 128, 96),
    (4, 2048, 256, 256, 224),
]

RESOLUTION: Rat = Fraction(2, 1000)  # 0.002: margin at 224 and deficit at 192
INTER_SEED_SPREAD: Rat = Fraction(6, 1000)  # 0.982 - 0.976 at k = 224


# --------------------------------------------------------------------------- #
# 1.  Knee extraction                                                          #
# --------------------------------------------------------------------------- #


def knee_with_predecessor(
    sweep: Sequence[Tuple[int, Rat]], bar: Rat
) -> Tuple[Optional[int], Optional[int]]:
    """Return ``(predecessor, knee)``: the first swept budget reaching ``bar``
    and the swept budget immediately below it.  The predecessor carries the
    lower end of the measurement window and must never be discarded."""
    previous: Optional[int] = None
    for budget, retained in sweep:
        if retained >= bar:
            return previous, budget
        previous = budget
    return previous, None


# --------------------------------------------------------------------------- #
# 2.  Windows                                                                  #
# --------------------------------------------------------------------------- #


def amplitude_window(p: int, k: int, i: int) -> Tuple[Rat, Rat]:
    """The half-open amplitude window ``(p/2**i, k/2**i]`` forced by a rung that
    reported knee ``k`` with predecessor ``p`` at rung index ``i``."""
    return Fraction(p, 2**i), Fraction(k, 2**i)


def explains_rung(amplitude: Rat, p: int, k: int, i: int) -> bool:
    """Does the law ``kappa(i) = A * 2**i`` reproduce this rung?"""
    value = amplitude * 2**i
    return p < value <= k


def intersect(w1: Tuple[Rat, Rat], w2: Tuple[Rat, Rat]) -> Optional[Tuple[Rat, Rat]]:
    """Intersection of two half-open windows ``(lo, hi]``; ``None`` if empty."""
    lo, hi = max(w1[0], w2[0]), min(w1[1], w2[1])
    return (lo, hi) if lo < hi else None


def show_window(w: Optional[Tuple[Rat, Rat]]) -> str:
    return "empty" if w is None else f"({w[0]}, {w[1]}]"


# --------------------------------------------------------------------------- #
# 3.  Quantisation                                                             #
# --------------------------------------------------------------------------- #


def grid_knee(step: Rat, kappa: Rat) -> Rat:
    """Reported knee on the grid ``step * N`` for a continuous crossing point:
    ``Q_s(kappa) = s * ceil(kappa / s)``."""
    return step * Fraction(ceil(kappa / step))


def predicted_report_range(
    window: Tuple[Rat, Rat], i: int, step: int = GRID_STEP
) -> Tuple[Rat, Rat]:
    """Range of reported knees at rung ``i`` compatible with an amplitude window.

    The lower end uses the open endpoint: an amplitude just above ``lo``
    produces a crossing point just above ``lo * 2**i``, which rounds up to the
    next grid multiple at or above it."""
    lo, hi = window
    s = Fraction(step)
    lo_value = lo * 2**i
    lo_report = s * Fraction(ceil(lo_value / s))
    if lo_report == lo_value:  # open endpoint: strictly above a grid multiple
        lo_report += s
    return lo_report, grid_knee(s, hi * 2**i)


# --------------------------------------------------------------------------- #
# 4.  Deployment quantities                                                    #
# --------------------------------------------------------------------------- #


def speedup(ctx: int, knee: int) -> Rat:
    """Attention-work speedup of a top-k model against full attention."""
    return Fraction(ctx, knee)


# --------------------------------------------------------------------------- #
# 5.  The demonstrations                                                       #
# --------------------------------------------------------------------------- #


def rule(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def demo_knee_extraction() -> None:
    rule("1.  Knee extraction from the measured sweeps")
    p2, k2 = knee_with_predecessor(SWEEP_2048_SEED2, BAR)
    p1, k1 = knee_with_predecessor(SWEEP_2048_SEED1, BAR)
    print(f"  seed 2 @ ctx=2048 : predecessor {p2}, knee {k2}   (prediction 256)")
    print(f"  seed 1 @ ctx=2048 : predecessor {p1}, knee {k1}   (prediction 256)")
    assert (p2, k2) == (192, 224) and (p1, k1) == (224, 256)
    print(f"  one-grid-step deficit at seed 2 : {256 - int(k2)} = grid step {GRID_STEP}")


def demo_windows() -> None:
    rule("2.  The Window Lemma turns each rung into an amplitude window")
    rows = [
        ("seed 1", 1024, 3, 96, 128),
        ("seed 1", 2048, 4, 224, 256),
        ("seed 2", 1024, 3, 64, 96),
        ("seed 2", 2048, 4, 192, 224),
    ]
    print(f"  {'seed':7}{'ctx':>7}{'rung':>6}{'prev':>7}{'knee':>7}   window")
    for seed, ctx, i, p, k in rows:
        w = amplitude_window(p, k, i)
        print(f"  {seed:7}{ctx:>7}{i:>6}{p:>7}{k:>7}   {show_window(w)}"
              f"   (width {w[1] - w[0]} = 32/2^{i})")


def demo_conflict() -> None:
    rule("3.  The Amplitude Conflict: no amplitude explains both seed-2 rungs")
    w3 = amplitude_window(64, 96, 3)
    w4 = amplitude_window(192, 224, 4)
    print(f"  seed-2 rung 3 window : {show_window(w3)}")
    print(f"  seed-2 rung 4 window : {show_window(w4)}")
    print(f"  intersection         : {show_window(intersect(w3, w4))}")
    assert intersect(w3, w4) is None
    print("  => no single amplitude reproduces both measurements.")

    # Exhaustive scan over a fine amplitude lattice confirms the obstruction.
    step = Fraction(1, 64)
    both = [
        Fraction(n, 64)
        for n in range(1, 64 * 32 + 1)
        if explains_rung(Fraction(n, 64), 64, 96, 3)
        and explains_rung(Fraction(n, 64), 192, 224, 4)
    ]
    print(f"  scan of A in (0, 32] at resolution {step}: "
          f"{len(both)} amplitudes explain both rungs.")
    assert both == []

    print("\n  But each broken rung alone IS explainable:")
    print(f"    A = 10 explains (64, 96, 3)   : {explains_rung(Fraction(10), 64, 96, 3)}"
          f"   since 64 < 10*8 = 80 <= 96")
    print(f"    A = 13 explains (192, 224, 4) : {explains_rung(Fraction(13), 192, 224, 4)}"
          f"   since 192 < 13*16 = 208 <= 224")
    print("  => the obstruction is a genuine two-point conflict: exactly one")
    print("     measurement away from consistency.")


def demo_seed1_identifiability() -> None:
    rule("4.  Sharp identifiability at seed 1: the admissible set is (14, 16]")
    w3 = amplitude_window(96, 128, 3)
    w4 = amplitude_window(224, 256, 4)
    inter = intersect(w3, w4)
    print(f"  rung 3 window {show_window(w3)}  and  rung 4 window {show_window(w4)}")
    print(f"  intersection : {show_window(inter)}")
    assert inter == (Fraction(14), Fraction(16))
    print(f"  product law's own amplitude A = 16 explains both rungs : "
          f"{explains_rung(Fraction(16), 96, 128, 3) and explains_rung(Fraction(16), 224, 256, 4)}")
    print("  relative precision : 2/16 = 12.5%, exactly the rung-4 resolution 32/2^4 = 2.")
    print("\n  Cross-seed check at ctx = 2048:")
    print(f"    (12,14] cap (14,16] = "
          f"{show_window(intersect(amplitude_window(192, 224, 4), w4))}")


def demo_decisive_experiment() -> None:
    rule("5.  The decisive experiment at ctx = 4096 (rung 5)")
    hypotheses = [
        ("seed-1 amplitude          ", (Fraction(14), Fraction(16))),
        ("seed-2, ctx=2048 is the law", (Fraction(12), Fraction(14))),
        ("seed-2, ctx=1024 is the law", (Fraction(8), Fraction(12))),
    ]
    ranges = []
    for name, w in hypotheses:
        lo, hi = predicted_report_range(w, 5)
        ranges.append((name, lo, hi))
        print(f"  {name} : window {show_window(w)} -> reported knee in [{lo}, {hi}]")
    ranges.sort(key=lambda t: t[1])
    for (n1, _, h1), (n2, l2, _) in zip(ranges, ranges[1:]):
        gap = l2 - h1
        print(f"  separation between '{n1.strip()}' and '{n2.strip()}' : {gap} "
              f"(>= one grid step {GRID_STEP}: {gap >= GRID_STEP})")
        assert gap >= GRID_STEP
    print("  => one run at ctx = 4096 adjudicates all three at the grid's resolution.")


def demo_certified_band() -> None:
    rule("6.  What the ladder certifies: A in (8, 16] and an 8x-16x speedup")
    windows = [
        amplitude_window(64, 96, 3),
        amplitude_window(192, 224, 4),
        amplitude_window(96, 128, 3),
        amplitude_window(224, 256, 4),
    ]
    lo = min(w[0] for w in windows)
    hi = max(w[1] for w in windows)
    print(f"  smallest lower endpoint over all measured rungs : {lo}")
    print(f"  largest upper endpoint  over all measured rungs : {hi}")
    assert (lo, hi) == (Fraction(8), Fraction(16))
    print("  => every amplitude compatible with any rung satisfies 8 < A <= 16;")
    print("     the product-law budget (A = 16) is never exceeded: safety is intact.")
    print(f"  guaranteed speedup at ctx=2048, k=256 : {speedup(2048, 256)}x")
    print(f"  measured  speedup at ctx=2048, k=224 : {speedup(2048, 224)} "
          f"= {float(speedup(2048, 224)):.3f}x  (< 9.15x)")


def demo_adversarial() -> None:
    rule("7.  Adversarial checks on the reported knee 224")
    c192 = dict(SWEEP_2048_SEED2)[192]
    c224 = dict(SWEEP_2048_SEED2)[224]
    print(f"  margin at the knee 224      : {c224} - {BAR} = {c224 - BAR}")
    print(f"  deficit at the predecessor  : {BAR} - {c192} = {BAR - c192}")
    print(f"  round's resolution          : {RESOLUTION}")
    perturbed = [(k, v + RESOLUTION if k == 192 else v) for k, v in SWEEP_2048_SEED2]
    _, k_pert = knee_with_predecessor(perturbed, BAR)
    print(f"  knee after a +{RESOLUTION} perturbation at k=192 : {k_pert}")
    assert k_pert == 192
    print("  => the reading 224 is NOT robust at the round's own resolution.")

    s1_224 = dict(SWEEP_2048_SEED1)[224]
    print(f"\n  seed-1 deficit at the deciding budget : {BAR} - {s1_224} = {BAR - s1_224}")
    print(f"  measured inter-seed spread there      : {INTER_SEED_SPREAD}")
    print(f"  deficit < spread : {BAR - s1_224 < INTER_SEED_SPREAD}")
    shifted = [(k, v + INTER_SEED_SPREAD) for k, v in SWEEP_2048_SEED1]
    _, k_shift = knee_with_predecessor(shifted, BAR)
    print(f"  knee of the seed-1 curve shifted by the observed spread : {k_shift}")
    assert k_shift == 224
    print("  => the 'replication' is exactly what the recorded noise predicts.")

    print("\n  Universal quantisation lemma (one-step drops at every grid multiple):")
    s = Fraction(GRID_STEP)
    for n, eps in ((3, Fraction(1, 1000)), (7, Fraction(1, 10**6))):
        k2 = s * n
        k1 = k2 + min(eps, s) / 2
        print(f"    n={n}: crossing points differ by {float(k1 - k2):.3e}, "
              f"reported {grid_knee(s, k2)} vs {grid_knee(s, k1)}")
        assert grid_knee(s, k2) == s * n and grid_knee(s, k1) == s * (n + 1)
    print("    (n=3 is the pair (96,128); n=7 is the pair (224,256).)")
    print(f"\n  null probability of a drop at both broken rungs : "
          f"{Fraction(1, 4)} = 0.25 > 0.05  -> not significant.")


def demo_asymptotics() -> None:
    rule("8.  Asymptotics: the deviation vanishes, the speedup collapses to 8x")
    print(f"  {'i':>3}{'ctx':>8}{'P_i':>7}{'K_i(s2)':>9}{'ratio':>10}{'speedup':>10}")
    for i in range(3, 13):
        ctx = 128 * 2**i
        p = 16 * 2**i
        k = p - GRID_STEP
        print(f"  {i:>3}{ctx:>8}{p:>7}{k:>9}{float(Fraction(k, p)):>10.5f}"
              f"{float(Fraction(ctx, k)):>10.5f}")
    print("  ratio  K_i/P_i = 1 - 2*(1/2)^i  ->  1")
    print("  speedup ctx/K_i = 8/(1 - 2*(1/2)^i) -> 8   (9.14x at i=4 is a transient)")

    print("\n  No affine law a*ctx + b fits the seed-2 knees:")
    a = Fraction(32 - 16, 256 - 128)
    b = Fraction(16) - a * 128
    print(f"    two shortest cells force a = {a}, b = {b}; "
          f"prediction at ctx=1024 is {a * 1024 + b}, measured 96.")
    assert a * 1024 + b != 96
    print("  No doubling law f(2n) = 2 f(n) fits either: pinned at 96 for ctx=1024 it")
    print("    predicts 192 at ctx=2048, measured 224.")


def demo_resolution_rate() -> None:
    rule("9.  How fast a doubling ladder learns the amplitude")
    print(f"  {'N':>3}{'upper bound 32/2^N':>22}{'lower bound 16/2^N':>22}"
          f"{'indistinguishable A':>22}")
    for n in range(0, 9):
        upper = Fraction(32, 2**n)
        lower = Fraction(16, 2**n)
        a = Fraction(16) - lower
        # a reproduces the product law's reported knee at every rung j < N
        for j in range(n):
            assert grid_knee(Fraction(32), a * 2 ** (j + 1)) == grid_knee(
                Fraction(32), Fraction(16) * 2 ** (j + 1)
            )
        print(f"  {n:>3}{str(upper):>22}{str(lower):>22}{str(a):>22}")
    print("  the two bounds match to a factor 2: identification is geometric, no faster.")
    print("  rung 4 resolution 32/2^4 = 2 -> the seed-1 window (14,16] is optimal;")
    print("  separating A = 16 from A = 15.5 needs 32/2^i < 1/2, i.e. i >= 6, ctx = 8192.")


def main() -> None:
    print(__doc__)
    demo_knee_extraction()
    demo_windows()
    demo_conflict()
    demo_seed1_identifiability()
    demo_decisive_experiment()
    demo_certified_band()
    demo_adversarial()
    demo_asymptotics()
    demo_resolution_rate()
    rule("All checks passed.")


if __name__ == "__main__":
    main()
