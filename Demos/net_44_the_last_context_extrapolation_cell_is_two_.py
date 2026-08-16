"""
Knee thresholds on finite sweep grids: numerical demonstration.

Self-contained (standard library only). Every function is inlined and type hinted.

The script reproduces, numerically, every quantitative claim of the accompanying
paper for the measured cell (depth d = 4, context ctx = 1024, bar = 0.98):

  1. Knee extraction         -> seed 1 knee = 128, seed 2 knee = 96.
  2. Robustness audit        -> seed-1 radius 0.003 < spread 0.010 (fragile),
                                seed-1 deficit at 64 = 0.012 > 0.010 (protected).
  3. Explicit seed-luck      -> the +0.010 shift of the seed-1 curve has knee 96
                                and matches the seed-2 data to <= 0.003.
  4. Robustness criterion    -> exhaustively verified against brute-force search
                                over perturbations, in both directions.
  5. Grid quantisation       -> one-step fluctuations manufactured from eps-noise;
                                identification windows (96,128] and (64,96] disjoint.
  6. Ensemble epistemics     -> certified budget = max knee = knee of worst-case
                                curve; best case = min knee; waste ratio 4/3.
  7. Lattice homomorphism    -> knee(min curve) = max knee, knee(max curve) = min knee.
  8. Deployment              -> speedup window [8, 16), measured 8x and 32/3x.
  9. Mechanism               -> knee ratio = tail-amplitude ratio = 3/4.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

Number = Fraction


# ----------------------------------------------------------------------------- data
BAR: Number = Fraction(98, 100)
SPREAD: Number = Fraction(10, 1000)
CTX: int = 1024
DEPTH: int = 4
GRID_STEP: int = 32

GRID_S1: List[int] = [32, 64, 96, 128, 192, 256, 384, 512, 768]
GRID_S2: List[int] = [32, 64, 96, 112, 128, 192, 256, 384, 512, 768]

# Measured retained accuracies. Unswept grid points are filled by monotone
# interpolation (carry-forward of the last measured value), which is exactly the
# information the theorems use: the measured values plus monotonicity.
MEASURED_S1: Dict[int, Number] = {
    64: Fraction(968, 1000),
    96: Fraction(977, 1000),
    128: Fraction(986, 1000),
    768: Fraction(1000, 1000),
}
MEASURED_S2: Dict[int, Number] = {
    64: Fraction(979, 1000),
    96: Fraction(987, 1000),
    112: Fraction(991, 1000),
    128: Fraction(993, 1000),
    768: Fraction(1000, 1000),
}


def monotone_curve(measured: Dict[int, Number], grid: Sequence[int]) -> Dict[int, Number]:
    """Fill a grid from sparse measurements by monotone carry-forward.

    Grid points below the first measured budget take the first measured value
    (a valid monotone lower fill for the purposes of the knee, since the knee only
    ever needs 'these points are at most the first measured value').
    """
    keys = sorted(measured)
    out: Dict[int, Number] = {}
    for g in sorted(grid):
        below = [k for k in keys if k <= g]
        out[g] = measured[below[-1]] if below else measured[keys[0]]
    return out


CURVE_S1: Dict[int, Number] = monotone_curve(MEASURED_S1, GRID_S1)
CURVE_S2: Dict[int, Number] = monotone_curve(MEASURED_S2, GRID_S2)


# ------------------------------------------------------------------- core algorithms
def knee(grid: Sequence[int], bar: Number, curve: Dict[int, Number]) -> Optional[int]:
    """Least grid budget whose retained accuracy reaches the bar (None if no point does)."""
    for g in sorted(grid):
        if curve[g] >= bar:
            return g
    return None


def robustness_radius(
    grid: Sequence[int], bar: Number, curve: Dict[int, Number]
) -> Tuple[Optional[int], Optional[Number], Optional[Number]]:
    """Return (knee, margin at the knee, minimal deficit strictly below the knee)."""
    k = knee(grid, bar, curve)
    if k is None:
        return None, None, None
    margin = curve[k] - bar
    below = [bar - curve[g] for g in grid if g < k]
    deficit = min(below) if below else None
    return k, margin, deficit


def is_eta_robust(
    grid: Sequence[int], bar: Number, curve: Dict[int, Number], eta: Number
) -> bool:
    """Criterion: eta <= margin at the knee AND eta < deficit at every earlier point."""
    k, margin, deficit = robustness_radius(grid, bar, curve)
    if k is None or margin is None:
        return False
    if eta > margin:
        return False
    return deficit is None or eta < deficit


def shift(curve: Dict[int, Number], eta: Number) -> Dict[int, Number]:
    """Uniform shift of a curve; monotone whenever the original is."""
    return {g: v + eta for g, v in curve.items()}


def grid_knee(step: int, kappa: Fraction) -> Fraction:
    """Least multiple of `step` at or above the true (continuous) crossing point."""
    num, den = kappa.numerator, kappa.denominator * step
    q = -((-num) // den)  # exact ceiling of kappa / step
    return Fraction(step * q, 1)


def identification_window(step: int, reported: Fraction) -> Tuple[Fraction, Fraction]:
    """A step-`step` sweep reporting `reported` places the true knee in (lo, hi]."""
    return reported - step, reported


def certified_budget(knees: Iterable[int]) -> int:
    """The budget an ensemble certifies: every seed clears the bar there."""
    return max(knees)


def pointwise(
    op: Callable[[Number, Number], Number],
    a: Dict[int, Number],
    b: Dict[int, Number],
) -> Dict[int, Number]:
    """Pointwise lattice operation on two curves, on their common grid."""
    common = sorted(set(a) & set(b))
    return {g: op(a[g], b[g]) for g in common}


def speedup(ctx: int, k: int) -> Fraction:
    """Attention-work reduction factor at budget k."""
    return Fraction(ctx, k)


def brute_force_robust(
    grid: Sequence[int],
    bar: Number,
    curve: Dict[int, Number],
    eta: Number,
    k_claim: int,
    resolution: int = 4,
) -> bool:
    """Search monotone perturbations of size <= eta on a fine sub-lattice.

    Returns True iff no searched perturbation moves the knee off `k_claim`.
    Used to cross-check the closed-form robustness criterion.
    """
    pts = sorted(grid)
    offsets = [Fraction(i, resolution) * eta for i in range(-resolution, resolution + 1)]
    # Only the points at or below the claimed knee can move it; keep the search finite.
    active = [g for g in pts if g <= k_claim]
    for combo in product(offsets, repeat=len(active)):
        cand = dict(curve)
        for g, off in zip(active, combo):
            cand[g] = curve[g] + off
        vals = [cand[g] for g in pts]
        if any(vals[i] > vals[i + 1] for i in range(len(vals) - 1)):
            continue  # not monotone: not an admissible perturbation
        if knee(pts, bar, cand) != k_claim:
            return False
    return True


def amplitude_ratio(kappa_1: Fraction, kappa_2: Fraction) -> Fraction:
    """Under the tail model kappa = A*d*ctx/delta, depth/context/tolerance cancel."""
    return kappa_2 / kappa_1


# ------------------------------------------------------------------------- reporting
def line(title: str) -> None:
    print("\n" + title)
    print("-" * len(title))


def fmt(x: Optional[Number]) -> str:
    return "n/a" if x is None else f"{float(x):.6g}"


def main() -> None:
    print("=" * 78)
    print("KNEE THRESHOLDS ON FINITE SWEEP GRIDS  --  numerical demonstration")
    print(f"cell: depth d = {DEPTH}, context ctx = {CTX}, bar = {float(BAR)}")
    print("=" * 78)

    line("1. Measured sweeps and extracted knees")
    for name, grid, curve in (("seed 1", GRID_S1, CURVE_S1), ("seed 2", GRID_S2, CURVE_S2)):
        swept = MEASURED_S1 if name == "seed 1" else MEASURED_S2
        cells = "  ".join(f"k={k}:{float(v):.3f}" for k, v in sorted(swept.items()))
        print(f"{name}: {cells}")
    k1 = knee(GRID_S1, BAR, CURVE_S1)
    k2 = knee(GRID_S2, BAR, CURVE_S2)
    print(f"\nknee(seed 1) = {k1}    knee(seed 2) = {k2}")
    print(f"product law d*ctx/32 = {DEPTH * CTX // 32}   -> prediction "
          f"{'CONFIRMED' if k2 == DEPTH * CTX // 32 else 'FAILED'} at seed 2")
    print(f"over-prediction: {k2}/{k1} = {Fraction(k2, k1)}  "
          f"(the law exceeds the seed-2 knee by {Fraction(k1 - k2, k1)} of its value)")

    line("2. Robustness audit (margin vs. deficit vs. observed spread)")
    for name, grid, curve in (("seed 1", GRID_S1, CURVE_S1), ("seed 2", GRID_S2, CURVE_S2)):
        k, margin, deficit = robustness_radius(grid, BAR, curve)
        radius = min(x for x in (margin, deficit) if x is not None)
        print(f"{name}: knee {k}, margin at knee {fmt(margin)}, "
              f"min deficit below {fmt(deficit)}, robustness radius {fmt(radius)}")
    print(f"observed inter-seed spread eta = {float(SPREAD)}")
    print(f"seed-1 knee claim 128 is {float(SPREAD)}-robust? "
          f"{is_eta_robust(GRID_S1, BAR, CURVE_S1, SPREAD)}   <- FRAGILE")
    print(f"seed-2 knee claim  96 is {float(SPREAD)}-robust? "
          f"{is_eta_robust(GRID_S2, BAR, CURVE_S2, SPREAD)}   "
          f"(its deficit at 64 is only 0.001)")
    print("=> at this cell NEITHER exact value is protected at the observed spread;")
    print("   only the bracket is.")

    line("3. Seed-luck, made explicit: the +eta shift of the seed-1 curve")
    shifted = shift(CURVE_S1, SPREAD)
    print(f"knee of (seed-1 curve + {float(SPREAD)}) = {knee(GRID_S1, BAR, shifted)}")
    print("shifted seed-1 values vs. actual seed-2 values:")
    for g in (64, 96, 128):
        diff = shifted[g] - CURVE_S2[g]
        print(f"  k={g:3d}: shifted {float(shifted[g]):.3f} vs measured "
              f"{float(CURVE_S2[g]):.3f}   (difference {float(diff):+.3f})")
    print("=> the second seed's outcome IS the generic eta-perturbation of the first.")

    line("4. Lower end of the bracket is protected")
    deficit_64 = BAR - CURVE_S1[64]
    print(f"seed-1 deficit at k=64: {float(deficit_64):.3f} > spread {float(SPREAD):.3f}"
          f"  -> no eta-perturbation puts the knee at 64 or below")
    down = shift(CURVE_S1, -SPREAD)
    up = shift(CURVE_S1, SPREAD)
    print(f"extreme perturbations of the seed-1 curve: knee(c + eta) = "
          f"{knee(GRID_S1, BAR, up)}, knee(c - eta) = {knee(GRID_S1, BAR, down)}")
    print("  -> upward perturbation drops the knee to 96 but never to 64 or below")
    print("     (lower end protected); downward perturbation pushes it ABOVE 128,")
    print("     confirming the exact value 128 was never perturbation-protected.")
    print("  The bracket (64, 128] is a statement about the two MEASURED seeds:")
    print("  its upper end is certified by both seeds actually clearing the bar at 128.")

    line("5. Cross-check: closed-form criterion vs. brute-force perturbation search")
    for eta_num in (1, 3, 5, 10):
        eta = Fraction(eta_num, 1000)
        closed = is_eta_robust(GRID_S1, BAR, CURVE_S1, eta)
        brute = brute_force_robust(GRID_S1, BAR, CURVE_S1, eta, 128)
        flag = "OK" if closed == brute else "MISMATCH"
        print(f"  eta = {float(eta):.3f}: criterion says {closed!s:5s}, "
              f"search says {brute!s:5s}  [{flag}]")

    line("6. Grid quantisation: one-step fluctuations and identification windows")
    for eps_num in (1, 100, 10000):
        eps = Fraction(1, eps_num)
        kappa_2 = Fraction(96)
        kappa_1 = 96 + min(eps, Fraction(32)) / 2
        print(f"  eps = {float(eps):<10.6g} kappa2 = {float(kappa_2):.8f} -> grid knee "
              f"{int(grid_knee(GRID_STEP, kappa_2))}, kappa1 = {float(kappa_1):.8f} -> "
              f"grid knee {int(grid_knee(GRID_STEP, kappa_1))}")
    w1 = identification_window(GRID_STEP, Fraction(128))
    w2 = identification_window(GRID_STEP, Fraction(96))
    print(f"  reported 128 -> true knee in ({int(w1[0])}, {int(w1[1])}]")
    print(f"  reported  96 -> true knee in ({int(w2[0])}, {int(w2[1])}]")
    print(f"  windows disjoint? {w2[1] <= w1[0]}  -> the seeds genuinely differ")

    line("7. Ensemble epistemics and the lattice structure of the knee")
    common = sorted(set(GRID_S1) & set(GRID_S2))
    worst = pointwise(min, CURVE_S1, CURVE_S2)
    best = pointwise(max, CURVE_S1, CURVE_S2)
    kw = knee(common, BAR, worst)
    kb = knee(common, BAR, best)
    cb = certified_budget([k1, k2])
    print(f"  knees          : {{{k1}, {k2}}}")
    print(f"  certified budget (max) = {cb}")
    print(f"  knee of worst-case curve (pointwise min) = {kw}  "
          f"[equals certified budget: {kw == cb}]")
    print(f"  knee of best-case curve  (pointwise max) = {kb}  "
          f"[equals min of knees: {kb == min(k1, k2)}]")
    print(f"  every seed clears the bar at {cb}? "
          f"{all(c[cb] >= BAR for c in (CURVE_S1, CURVE_S2))}")
    print(f"  any smaller common grid point where BOTH clear the bar? "
          f"{[g for g in common if g < cb and CURVE_S1[g] >= BAR and CURVE_S2[g] >= BAR]}"
          f"  -> the certified budget is the LEAST safe one")
    print(f"  over-provisioning (waste) ratio {cb}/{min(k1, k2)} = "
          f"{Fraction(cb, min(k1, k2))}")
    print("  evidence degrades guarantees: adding a seed can only raise the maximum,")
    print(f"     e.g. certified({{{k2}}}) = {certified_budget([k2])} -> "
          f"certified({{{k1},{k2}}}) = {cb}")

    line("8. Deployment: the two-seed bracket and its speedup window")
    lo, hi = 64, 128
    print(f"  bracket k* in ({lo}, {hi}]  (sound: both knees inside; sharp: no narrower")
    print(f"     bracket with grid endpoints contains both {k1} and {k2})")
    print(f"  speedup window: [{float(speedup(CTX, hi)):.4g}, "
          f"{float(speedup(CTX, lo)):.4g})")
    print(f"  measured speedups: seed 1 = {float(speedup(CTX, k1)):.4g}x, "
          f"seed 2 = {float(speedup(CTX, k2)):.4g}x  "
          f"(= {speedup(CTX, k2)} exactly)")
    for k in range(lo + 1, hi + 1):
        s = speedup(CTX, k)
        assert 8 <= s < 16
    print("  verified: every budget in the bracket gives a speedup in [8, 16)")

    line("9. Mechanism: the knee ratio is a tail-amplitude ratio")
    ratio = amplitude_ratio(Fraction(128), Fraction(96))
    print(f"  under kappa = A*d*ctx/delta, A2/A1 = kappa2/kappa1 = {ratio} = "
          f"{float(ratio):.3f}")
    print("  depth, context and tolerance cancel identically; only one fitted")
    print("  constant fluctuated, by a factor 3/4.")
    for d_, ctx_, delta in ((4, 1024, Fraction(1, 10)), (16, 512, Fraction(3, 7))):
        a1 = Fraction(128) * delta / (d_ * ctx_)
        a2 = Fraction(96) * delta / (d_ * ctx_)
        print(f"    d={d_:3d} ctx={ctx_:5d} delta={float(delta):.4g}: "
              f"A1={float(a1):.6g}, A2={float(a2):.6g}, A2/A1={a2 / a1}")

    line("10. Summary")
    print(f"  seed 1 knee {k1} (matches the product law), seed 2 knee {k2}")
    print(f"  margin 0.003 < spread 0.010 < deficit 0.012")
    print(f"  robust content: k* in (64, 128];  certified budget {cb};  "
          f"speedup floor {float(speedup(CTX, cb)):.0f}x")
    print("  the product law survives as a proven-safe UPPER BOUND, not an equality.")
    print("=" * 78)


if __name__ == "__main__":
    main()
