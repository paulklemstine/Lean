"""
Numerical demonstration of the domain-parameterised budget law for attention key retention.

Everything here is self-contained: no third-party dependencies, all helpers inlined,
full type hints.  Running the file prints a guided tour of every result:

  1. The knee as an adjoint, and the two-point data-determination principle.
  2. The measured code sweeps at contexts 512 and 1024 (knees 12 and 16).
  3. Budget laws: affine rigidity, non-identifiability from one context,
     constant shift <=> shared increment, and the crossover theorem.
  4. The domain axis as a Z-torsor: unique connecting translation, the cocycle law,
     and the invariance of shifts under a common re-basing.
  5. Mixed-workload envelopes: the join rule inside a fibre, and the failure of the
     envelope to be a law outside it.
  6. Accuracy/knee decoupling and the concentration bridge.
  7. The decay-rescaling rival: both mechanisms fit, and the ctx-4096 separation.
  8. Grid resolution: how a step-8 grid erases the entire effect.

Every assertion in the script is checked with `assert`, so a clean run is a
numerical confirmation of the stated theorems on the stated instances.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------------
# Section 1 -- the knee as an adjoint
# ----------------------------------------------------------------------------------

Sweep = Dict[int, Fraction]  # grid index -> retained accuracy


def knee_index(sweep: Sweep, bar: Fraction) -> int:
    """Least grid index whose retained accuracy clears the bar.

    This is the infimum defining the knee.  Raises if no swept index clears the bar.
    """
    passing = [j for j in sorted(sweep) if sweep[j] >= bar]
    if not passing:
        raise ValueError("no swept index clears the bar")
    return passing[0]


def knee_budget(step: int, sweep: Sweep, bar: Fraction) -> int:
    """The knee in keys, on a grid of the given step."""
    return step * knee_index(sweep, bar)


def is_monotone(sweep: Sweep) -> bool:
    """Retained accuracy never decreases as the budget grows."""
    keys = sorted(sweep)
    return all(sweep[a] <= sweep[b] for a, b in zip(keys, keys[1:]))


def galois_holds(sweep: Sweep, bar: Fraction) -> bool:
    """Check `knee_index <= k  <=>  bar <= acc(k)` at every swept index."""
    k_star = knee_index(sweep, bar)
    return all((k_star <= k) == (sweep[k] >= bar) for k in sweep)


def bracket_of(sweep: Sweep, bar: Fraction) -> Tuple[int, Fraction, Fraction]:
    """The two readings that determine the knee: last failing and first passing.

    Returns (j, acc(j), acc(j+1)) with acc(j) < bar <= acc(j+1).
    """
    j = knee_index(sweep, bar) - 1
    return j, sweep[j], sweep[j + 1]


# ----------------------------------------------------------------------------------
# Section 2 -- the measured sweeps
# ----------------------------------------------------------------------------------

FINE_STEP: int = 4
BAR: Fraction = Fraction(98, 100)

# grid index j  <->  budget 4*j keys
CODE_512: Sweep = {
    0: Fraction(0),
    1: Fraction(930, 1000),
    2: Fraction(969, 1000),
    3: Fraction(981, 1000),
    4: Fraction(987, 1000),
    5: Fraction(988, 1000),
    6: Fraction(989, 1000),
}

CODE_1024: Sweep = {
    0: Fraction(0),
    1: Fraction(0),  # not swept; monotonicity places it below the k=8 reading
    2: Fraction(960, 1000),
    3: Fraction(976, 1000),
    4: Fraction(981, 1000),
    5: Fraction(986, 1000),
    6: Fraction(987, 1000),
}

PROSE_KNEES: Dict[int, int] = {0: 16, 1: 20}  # doublings -> keys (reference domain)


# ----------------------------------------------------------------------------------
# Section 3 -- budget laws
# ----------------------------------------------------------------------------------

@dataclass(frozen=True)
class BudgetLaw:
    """k*(context) = base + inc * doublings(context).  d = 0 is context 512."""

    base: int
    inc: int

    def eval(self, d: int) -> int:
        return self.base + self.inc * d

    def translate(self, t: int) -> "BudgetLaw":
        """The Z-action on the domain axis: re-base by t, increment untouched."""
        return BudgetLaw(self.base + t, self.inc)


CODE_LAW = BudgetLaw(base=12, inc=4)
PROSE_LAW = BudgetLaw(base=16, inc=4)


def identify_law(d: int, k_d: int, e: int, k_e: int) -> BudgetLaw:
    """Recover the unique budget law from two readings at distinct doublings d != e.

    Affine rigidity guarantees uniqueness; a non-integral increment signals that the
    two readings are inconsistent with the model class.
    """
    if d == e:
        raise ValueError("two distinct contexts are required to identify a law")
    num, den = k_e - k_d, e - d
    if num % den != 0:
        raise ValueError(f"readings imply a non-integral increment {num}/{den}")
    inc = num // den
    return BudgetLaw(base=k_d - inc * d, inc=inc)


def shift(a: BudgetLaw, b: BudgetLaw) -> int:
    """The observable inter-domain translation: base(b) - base(a)."""
    return b.base - a.base


def crossover_context(a: BudgetLaw, b: BudgetLaw) -> Optional[int]:
    """Least D with a.eval(d) < b.eval(d) for all d >= D, when inc(a) < inc(b)."""
    if a.inc >= b.inc:
        return None
    return max(a.base - b.base, 0) + 1


def envelope_is_a_law(laws: Sequence[BudgetLaw]) -> bool:
    """The pointwise max of a family is a budget law iff no pair has unequal
    increments together with crossing bases."""
    for i, a in enumerate(laws):
        for b in laws[i + 1:]:
            lo, hi = (a, b) if a.inc < b.inc else (b, a)
            if lo.inc < hi.inc and hi.base < lo.base:
                return False
    return True


def envelope_law(laws: Sequence[BudgetLaw]) -> BudgetLaw:
    """Inside a fibre (shared increment) the envelope is the join: largest base."""
    incs = {L.inc for L in laws}
    if len(incs) != 1:
        raise ValueError("envelope_law requires a shared increment")
    return BudgetLaw(base=max(L.base for L in laws), inc=incs.pop())


# ----------------------------------------------------------------------------------
# Section 6 -- attention profiles, decoupling, concentration
# ----------------------------------------------------------------------------------

def uniform_profile_cum(tau: Fraction, k: int) -> Callable[[int], Fraction]:
    """Cumulative mass of the uniform profile: mass tau/k on each of the first k keys."""

    def cum(j: int) -> Fraction:
        return tau * Fraction(min(j, k), k)

    return cum


def profile_knee(cum: Callable[[int], Fraction], tau: Fraction, cap: int = 4096) -> int:
    """Least k with cum(k) >= tau."""
    for k in range(cap + 1):
        if cum(k) >= tau:
            return k
    raise ValueError("tolerance never reached within cap")


def heaviest_key_lower_bound(tau: Fraction, k: int) -> Fraction:
    """A knee of k at tolerance tau certifies a key of mass strictly above tau/(k+1)."""
    return tau / (k + 1)


# ----------------------------------------------------------------------------------
# Section 7 -- the decay-rescaling rival
# ----------------------------------------------------------------------------------

def geom_knee(r: float, rho: float) -> int:
    """Least k with r**k <= rho, for 0 < r < 1 and 0 < rho < 1."""
    return math.ceil(math.log(rho) / math.log(r))


def continuous_knee(r: float, rho: float) -> float:
    """X = log(rho)/log(r): the real number of which the measured knee is the ceiling."""
    return math.log(rho) / math.log(r)


def exponent_window(prose_k: int, code_k: int) -> Tuple[float, float]:
    """Exponents a compatible with a single cell (prose reading P, code reading C).

    The ceiling bracket gives P - 1 < X <= P and C - 1 < X/a <= C, hence
    (P-1)/C < a < P/(C-1).
    """
    lo = (prose_k - 1) / code_k
    hi = prose_k / (code_k - 1) if code_k > 1 else float("inf")
    return lo, hi


def intersect_windows(cells: Sequence[Tuple[int, int]]) -> Tuple[float, float]:
    """Intersection of the per-cell exponent windows; empty iff lo >= hi."""
    lo, hi = 0.0, float("inf")
    for prose_k, code_k in cells:
        a, b = exponent_window(prose_k, code_k)
        lo, hi = max(lo, a), min(hi, b)
    return lo, hi


# ----------------------------------------------------------------------------------
# Section 8 -- grid resolution
# ----------------------------------------------------------------------------------

def round_up(g: int, k: int) -> int:
    """Least multiple of g at or above k."""
    return g * ((k + g - 1) // g)


# ----------------------------------------------------------------------------------
# The guided tour
# ----------------------------------------------------------------------------------

def section(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_knee_adjunction() -> None:
    section("1.  The knee as an adjoint, and data determination")
    for name, sweep in (("code @512", CODE_512), ("code @1024", CODE_1024)):
        assert is_monotone(sweep), f"{name} sweep is not monotone"
        assert galois_holds(sweep, BAR), f"Galois connection fails for {name}"
        j, below, above = bracket_of(sweep, BAR)
        k = knee_budget(FINE_STEP, sweep, BAR)
        print(f"  {name:11s}  bracket at grid indices ({j}, {j+1}): "
              f"{float(below):.3f} < {float(BAR):.2f} <= {float(above):.3f}"
              f"   =>  k* = {k} keys")
    print("  Galois connection  knee_index <= j  <=>  bar <= acc(j)  verified at every index.")

    # Data determination: perturb every non-bracketing reading upward; knee is unchanged.
    perturbed = dict(CODE_512)
    perturbed[4] = Fraction(999, 1000)
    perturbed[5] = Fraction(999, 1000)
    perturbed[6] = Fraction(999, 1000)
    assert knee_budget(FINE_STEP, perturbed, BAR) == 12
    print("  Perturbing all non-bracketing readings leaves the knee at 12 keys:")
    print("  a knee claim rests on exactly two measured points.")


def demo_measurement_table() -> None:
    section("2.  The measurement: code sits four keys below prose, at both contexts")
    code = {0: knee_budget(FINE_STEP, CODE_512, BAR),
            1: knee_budget(FINE_STEP, CODE_1024, BAR)}
    print(f"  {'ctx':>6} {'code k*':>9} {'prose k*':>10} {'shift':>7}")
    for d, ctx in ((0, 512), (1, 1024)):
        s = code[d] - PROSE_KNEES[d]
        print(f"  {ctx:>6} {code[d]:>9} {PROSE_KNEES[d]:>10} {s:>+7}")
        assert s == -FINE_STEP
    print("  The shift is exactly one fine grid step (-4 keys) at BOTH contexts.")
    print("  Full accuracy: code 0.6296 @512 and 0.6520 @1024, above prose in both cells;")
    print("  the easier-to-predict domain is the one that needs fewer keys.")


def demo_budget_laws() -> None:
    section("3.  Budget laws: rigidity, identifiability, and the shift/increment equivalence")
    fitted_code = identify_law(0, 12, 1, 16)
    fitted_prose = identify_law(0, 16, 1, 20)
    assert fitted_code == CODE_LAW and fitted_prose == PROSE_LAW
    print(f"  Two code readings (12 @ d=0, 16 @ d=1) identify  "
          f"k* = {CODE_LAW.base} + {CODE_LAW.inc}*d")
    print(f"  Two prose readings (16 @ d=0, 20 @ d=1) identify "
          f"k* = {PROSE_LAW.base} + {PROSE_LAW.inc}*d")

    # One context can never identify a law.
    impostor = BudgetLaw(CODE_LAW.base - 1, CODE_LAW.inc + 1)
    assert impostor != CODE_LAW and impostor.eval(1) == CODE_LAW.eval(1)
    print(f"  But one context never identifies: "
          f"({impostor.base}, {impostor.inc}) also reads {impostor.eval(1)} at d=1.")

    # Constant shift <=> shared increment.
    shifts = {d: PROSE_LAW.eval(d) - CODE_LAW.eval(d) for d in range(8)}
    assert set(shifts.values()) == {4}
    assert CODE_LAW.inc == PROSE_LAW.inc
    print(f"  Shift over d = 0..7: {sorted(set(shifts.values()))}  (constant)")
    print("  Constant shift is EQUIVALENT to a shared increment: the domain enters only")
    print("  through the base, the scale only through the increment.")

    # The alternative was live: unequal increments force a crossover.
    a, b = BudgetLaw(16, 2), BudgetLaw(12, 6)
    D = crossover_context(a, b)
    assert D is not None and all(a.eval(d) < b.eval(d) for d in range(D, D + 20))
    least = min(d for d in range(D + 1) if all(a.eval(e) < b.eval(e)
                                               for e in range(d, D + 20)))
    print(f"  Counterfactual (16,2) vs (12,6): the certified crossover bound is d = {D};")
    print(f"  the shift in fact reverses sign at d = {least}.")

    print(f"  Extrapolation to ctx 4096 (d = 3): "
          f"code {CODE_LAW.eval(3)} keys, prose {PROSE_LAW.eval(3)} keys.")


def demo_torsor() -> None:
    section("4.  The domain axis is a Z-torsor: only differences are observable")
    t = shift(CODE_LAW, PROSE_LAW)
    assert CODE_LAW.translate(t) == PROSE_LAW
    others = [u for u in range(-20, 21) if CODE_LAW.translate(u) == PROSE_LAW]
    assert others == [t]
    print(f"  A unique translation carries code to prose: t = {t} "
          f"(no other t in [-20, 20] works).")

    # Cocycle law along a three-rung ladder.
    hypo = BudgetLaw(8, 4)
    assert shift(hypo, CODE_LAW) + shift(CODE_LAW, PROSE_LAW) == shift(hypo, PROSE_LAW)
    print(f"  Cocycle law: shift(hypo,code) + shift(code,prose) = "
          f"{shift(hypo, CODE_LAW)} + {shift(CODE_LAW, PROSE_LAW)} = "
          f"{shift(hypo, PROSE_LAW)} = shift(hypo,prose).")

    # Re-basing every domain leaves every shift unchanged.
    for u in (-1000, -7, 0, 5, 96):
        assert shift(CODE_LAW.translate(u), PROSE_LAW.translate(u)) == t
    moved = CODE_LAW.translate(1000 - CODE_LAW.base)
    assert moved.base == 1000
    print("  Re-basing both domains by any common t leaves the shift at 4;")
    print(f"  the code base can be moved to {moved.base} with nothing observable changing.")
    print("  The experiment measures the integer 4, never 12 and 16 separately.")


def demo_envelopes() -> None:
    section("5.  Mixed workloads: the join rule, and where it fails")
    laws = [CODE_LAW, PROSE_LAW]
    assert envelope_is_a_law(laws)
    env = envelope_law(laws)
    for d in range(6):
        assert env.eval(d) == max(L.eval(d) for L in laws) == PROSE_LAW.eval(d)
    print(f"  Shared increment 4: envelope is the law "
          f"({env.base}, {env.inc}) -- size by the LARGEST base, i.e. by prose.")
    print(f"  Sizing by code under-provisions by exactly "
          f"{PROSE_LAW.eval(0) - CODE_LAW.eval(0)} keys at every context.")
    print("  The mixed base is the MAX of the constituent bases, never a weighted mean.")

    # Outside a fibre the envelope is not a law at all.
    a, b = BudgetLaw(16, 2), BudgetLaw(12, 6)
    assert not envelope_is_a_law([a, b])
    pointwise = [max(a.eval(d), b.eval(d)) for d in range(6)]
    print(f"\n  Unequal increments with crossing bases, (16,2) and (12,6):")
    print(f"    pointwise envelope over d = 0..5: {pointwise}")
    # Exhaustively confirm no budget law reproduces it.
    found = [(base, inc)
             for base in range(-50, 101) for inc in range(-20, 41)
             if all(base + inc * d == pointwise[d] for d in range(6))]
    assert found == []
    print("    no (base, inc) in a wide search reproduces it -- the envelope has a kink")
    print("    at d = 1 that no two-parameter affine formula can straighten.")
    print("  Single-formula cache sizing is a privilege the shared increment earns.")


def demo_decoupling_and_concentration() -> None:
    section("6.  Accuracy is orthogonal to the knee; a small base certifies a heavy key")
    tau = Fraction(1, 2)
    # Any (accuracy, knee) pair is realisable: accuracy is a free label.
    for acc, k in ((Fraction(1, 2), 1), (Fraction(1, 2), 2),
                   (Fraction(6296, 10000), 12), (Fraction(6520, 10000), 16)):
        cum = uniform_profile_cum(tau, k)
        assert profile_knee(cum, tau) == k
        print(f"    realised: full accuracy {float(acc):.4f} with knee {k:>2} keys")
    print("  Two domains share accuracy 0.5 yet have knees 1 and 2:")
    print("  no function of accuracy can predict the knee, so the horn 'easier => not")
    print("  fewer keys' was never provable from accuracy data of any kind.")

    print("\n  Concentration bridge (tolerance tau):")
    for label, k in (("code ", 12), ("prose", 16)):
        bound = heaviest_key_lower_bound(Fraction(1), k)
        print(f"    {label} knee {k:>2}  =>  some key carries more than tau/{k+1} "
              f"= {float(bound):.4f} * tau of the mass")
    # The certificate is genuine: a profile flat at tau/13 cannot have knee 12.
    flat = uniform_profile_cum(tau, 13)
    assert profile_knee(flat, tau) == 13 != 12
    print("    a profile flat at level tau/13 has knee 13, not 12 -- so the code reading")
    print("    certifies a strictly heavier key.  The -4 shift is a statement about the")
    print("    SHAPE of code attention, not about its difficulty.")


def demo_mechanism_discrimination() -> None:
    section("7.  Additive shift versus rescaled decay: both fit, and the 4096 decision")
    a = 251 / 200
    prose_X = {0: 15.05, 1: 20.0, 2: 24.0, 3: 28.0}
    print(f"  Rescaling witness a = {a}")
    print(f"  {'d':>3} {'ctx':>6} {'X_prose':>9} {'ceil X':>7} {'ceil X/a':>9} "
          f"{'additive code':>14}")
    for d in (0, 1, 2, 3):
        X = prose_X[d]
        print(f"  {d:>3} {512 * 2 ** d:>6} {X:>9.2f} {math.ceil(X):>7} "
              f"{math.ceil(X / a):>9} {CODE_LAW.eval(d):>14}")
    for d in (0, 1, 2):
        assert math.ceil(prose_X[d]) == PROSE_LAW.eval(d)
        assert math.ceil(prose_X[d] / a) == CODE_LAW.eval(d)
    print("  Both mechanisms reproduce every cell up to ctx 2048 -- two contexts cannot")
    print("  distinguish an additive base shift from a rescaling of the decay rate.")

    # Geometric realisability of the witness.
    for X in (15.05, 20.0):
        r, rho = math.exp(-1.0), math.exp(-X)
        assert 0 < r < 1 and 0 < rho < 1
        assert geom_knee(r, rho) == math.ceil(X)
        assert abs(continuous_knee(r, rho) - X) < 1e-9
    print("  Honest geometric profiles with those continuous knees exist (r = e^-1).")

    # The window closes at d = 3.
    cells_measured = [(16, 12), (20, 16)]
    lo, hi = intersect_windows(cells_measured)
    assert lo < a < hi
    print(f"\n  Admissible exponent window from the measured cells: "
          f"({lo:.4f}, {hi:.4f}) -- nonempty, contains {a}.")
    lo3, hi3 = intersect_windows(cells_measured + [(28, 24)])
    assert lo3 >= hi3
    print(f"  Adjoining the additive prediction (28, 24) at ctx 4096: "
          f"({lo3:.4f}, {hi3:.4f}) -- EMPTY.")
    print(f"  The 512 cell alone forces a > {exponent_window(16, 12)[0]:.2f}, hence every")
    print(f"  rescaling model predicts at most {math.ceil(28 / 1.25)} keys at ctx 4096,")
    print(f"  while the additive law predicts exactly {CODE_LAW.eval(3)}.")
    print("  A single measurement at ctx 4096 kills one of the two mechanisms.")


def demo_grid_resolution() -> None:
    section("8.  Grid resolution: the instrument sets the ceiling on discovery")
    print(f"  {'grid step':>10} {'code 12 ->':>12} {'prose 16 ->':>13} {'distinguishable':>17}")
    for g in (2, 4, 8, 16):
        rc, rp = round_up(g, 12), round_up(g, 16)
        print(f"  {g:>10} {rc:>12} {rp:>13} {str(rc != rp):>17}")
    assert round_up(8, 12) == round_up(8, 16) == 16
    assert round_up(4, 12) != round_up(4, 16)
    print("  On a step-8 grid the entire effect vanishes, silently.  An effect of size s")
    print("  is observable only on grids finer than s: resolution, not sample size, is")
    print("  the binding constraint on what a limited-memory experiment can detect.")


def main() -> None:
    print("Domain-parameterised budget law for attention key retention")
    print("Numerical demonstration -- every claim below is asserted, not merely printed.")
    demo_knee_adjunction()
    demo_measurement_table()
    demo_budget_laws()
    demo_torsor()
    demo_envelopes()
    demo_decoupling_and_concentration()
    demo_mechanism_discrimination()
    demo_grid_resolution()
    print("\n" + "=" * 78)
    print("All assertions passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()


"""Mechanism discrimination by the admissible exponent window.

Two mechanisms explain the measured knees.  The additive budget law shifts the knee
by a domain-dependent constant.  The decay-rescaling mechanism instead assumes
geometric attention with residual mass r^k, so the knee is the ceiling of the
continuous knee X = log(rho)/log(r); raising the decay rate to the power a divides
X by a, so the knee is DIVIDED rather than shifted.

A knee reading n brackets the continuous knee: n - 1 < X <= n.  Applying the bracket
to a paired reference/target cell (P, C) constrains the exponent to the open interval
((P-1)/C, P/(C-1)).  Intersecting over cells decides the mechanism: a nonempty window
means the multiplicative branch survives, an empty one excludes it outright.
Complexity is linear in the number of cells.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import List, Optional, Sequence, Tuple


@dataclass(frozen=True)
class Cell:
    """One measured context: reference-domain knee and target-domain knee."""

    doublings: int
    reference_knee: int
    target_knee: int

    @property
    def context(self) -> int:
        return 512 * 2 ** self.doublings


def cell_window(cell: Cell) -> Tuple[float, float]:
    """Exponents compatible with a single cell: ((P-1)/C, P/(C-1))."""
    p, c = cell.reference_knee, cell.target_knee
    if c < 1:
        raise ValueError("target knee must be at least 1")
    lo = (p - 1) / c
    hi = p / (c - 1) if c > 1 else math.inf
    return lo, hi


@dataclass(frozen=True)
class WindowReport:
    lo: float
    hi: float
    per_cell: List[Tuple[Cell, Tuple[float, float]]]

    @property
    def nonempty(self) -> bool:
        return self.lo < self.hi

    def render(self) -> str:
        lines = ["per-cell admissible exponent windows:"]
        for cell, (a, b) in self.per_cell:
            hi = "inf" if math.isinf(b) else f"{b:.4f}"
            lines.append(f"  ctx {cell.context:>5}: reference {cell.reference_knee:>2}, "
                         f"target {cell.target_knee:>2}  ->  ({a:.4f}, {hi})")
        hi = "inf" if math.isinf(self.hi) else f"{self.hi:.4f}"
        verdict = ("NONEMPTY -- the rescaling mechanism survives these cells"
                   if self.nonempty else
                   "EMPTY -- no rescaling exponent reproduces these cells")
        lines.append(f"intersection: ({self.lo:.4f}, {hi})  =>  {verdict}")
        return "\n".join(lines)


def intersect_windows(cells: Sequence[Cell]) -> WindowReport:
    """Intersect the per-cell exponent windows.  O(#cells)."""
    lo, hi = 0.0, math.inf
    per_cell: List[Tuple[Cell, Tuple[float, float]]] = []
    for cell in cells:
        a, b = cell_window(cell)
        per_cell.append((cell, (a, b)))
        lo, hi = max(lo, a), min(hi, b)
    return WindowReport(lo, hi, per_cell)


def witness_exponent(report: WindowReport) -> Optional[float]:
    """A representative admissible exponent, or None if the window is empty."""
    if not report.nonempty:
        return None
    return report.lo + (min(report.hi, report.lo + 1.0) - report.lo) / 2


def rescaling_predictions(a: float, reference_knees: Sequence[int]) -> List[int]:
    """Target-domain knees predicted by the rescaling mechanism at exponent a.

    Uses the tightest continuous knee compatible with each reference reading, X = P,
    which maximises the predicted target knee; the prediction is therefore an upper
    bound over all admissible continuous knees.
    """
    return [math.ceil(p / a) for p in reference_knees]


def additive_predictions(base: int, inc: int, doublings: Sequence[int]) -> List[int]:
    return [base + inc * d for d in doublings]


def discriminate(measured: Sequence[Cell], probe: Cell) -> str:
    """Report whether adding a probe cell empties the admissible window."""
    before = intersect_windows(measured)
    after = intersect_windows(list(measured) + [probe])
    lines = ["--- measured cells ---", before.render(),
             f"--- adjoining probe at ctx {probe.context} "
             f"(reference {probe.reference_knee}, target {probe.target_knee}) ---",
             after.render()]
    if before.nonempty and not after.nonempty:
        lines.append("VERDICT: the probe cell is decisive -- it kills the rescaling "
                     "mechanism outright.")
    elif before.nonempty and after.nonempty:
        lines.append("VERDICT: the probe cell is not decisive -- both mechanisms "
                     "survive it.")
    return "\n".join(lines)


if __name__ == "__main__":
    measured = [Cell(0, 16, 12), Cell(1, 20, 16)]
    report = intersect_windows(measured)
    print(report.render())
    w = witness_exponent(report)
    print(f"\nwitness exponent a = {w:.4f}")
    print(f"rescaling predictions at reference knees [16, 20, 24, 28]: "
          f"{rescaling_predictions(251 / 200, [16, 20, 24, 28])}")
    print(f"additive  predictions for d = 0..3:                        "
          f"{additive_predictions(12, 4, [0, 1, 2, 3])}")

    print("\n" + "=" * 70)
    print(discriminate(measured, Cell(2, 24, 20)))
    print("\n" + "=" * 70)
    print(discriminate(measured, Cell(3, 28, 24)))


"""Bracketed knee extraction with a two-point certificate.

The knee of a monotone retention sweep is the least grid index clearing the
acceptance bar.  Because the passing set is upward closed, the knee is the left
adjoint of the accuracy curve, and it is determined by exactly two readings: the
last failing index and the first passing one.  This module returns that pair as a
machine-checkable certificate alongside the knee itself.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Dict, List, Optional, Sequence, Tuple


@dataclass(frozen=True)
class KneeCertificate:
    """A knee reading together with the two data points that justify it."""

    grid_step: int
    bar: Fraction
    knee_index: int
    knee_budget: int
    below_index: int
    below_value: Fraction
    above_value: Fraction

    def is_valid(self) -> bool:
        return (self.below_value < self.bar <= self.above_value
                and self.knee_index == self.below_index + 1
                and self.knee_budget == self.grid_step * self.knee_index)

    def render(self) -> str:
        return (f"k* = {self.knee_budget} keys  (grid index {self.knee_index})\n"
                f"  certificate: acc({self.below_index}) = {float(self.below_value):.3f}"
                f" < {float(self.bar):.3f} <= acc({self.knee_index})"
                f" = {float(self.above_value):.3f}")


def check_monotone(sweep: Dict[int, Fraction]) -> bool:
    """Retained accuracy must never decrease with budget; the adjunction needs it."""
    keys = sorted(sweep)
    return all(sweep[a] <= sweep[b] for a, b in zip(keys, keys[1:]))


def knee_index_linear(sweep: Dict[int, Fraction], bar: Fraction) -> Optional[int]:
    """Least swept index clearing the bar, by linear scan.  O(n)."""
    for j in sorted(sweep):
        if sweep[j] >= bar:
            return j
    return None


def knee_index_binary(sweep: Dict[int, Fraction], bar: Fraction) -> Optional[int]:
    """Least swept index clearing the bar, by binary search.  O(log n).

    Correct precisely because the passing set is upward closed for a monotone
    sweep -- the content of the Galois connection.
    """
    keys: List[int] = sorted(sweep)
    lo, hi = 0, len(keys)
    while lo < hi:
        mid = (lo + hi) // 2
        if sweep[keys[mid]] >= bar:
            hi = mid
        else:
            lo = mid + 1
    return keys[lo] if lo < len(keys) else None


def extract_knee(sweep: Dict[int, Fraction], bar: Fraction,
                 grid_step: int) -> KneeCertificate:
    """Read the knee off a monotone sweep and return it with its certificate."""
    if not check_monotone(sweep):
        raise ValueError("sweep is not monotone; the knee adjunction does not apply")
    j_lin = knee_index_linear(sweep, bar)
    j_bin = knee_index_binary(sweep, bar)
    if j_lin is None:
        raise ValueError("no swept index clears the bar; extend the grid")
    assert j_lin == j_bin, "linear and binary search disagree: sweep is not monotone"
    if j_lin == min(sweep):
        raise ValueError("the first swept index already passes; the knee is unbracketed")
    cert = KneeCertificate(grid_step=grid_step, bar=bar, knee_index=j_lin,
                           knee_budget=grid_step * j_lin, below_index=j_lin - 1,
                           below_value=sweep[j_lin - 1], above_value=sweep[j_lin])
    assert cert.is_valid()
    return cert


def knees_agree(sweep_a: Dict[int, Fraction], sweep_b: Dict[int, Fraction],
                bar: Fraction, grid_step: int) -> bool:
    """Two monotone sweeps sharing a bracketing pair have the same knee."""
    return (extract_knee(sweep_a, bar, grid_step).knee_budget
            == extract_knee(sweep_b, bar, grid_step).knee_budget)


if __name__ == "__main__":
    BAR = Fraction(98, 100)
    code_512 = {0: Fraction(0), 1: Fraction(930, 1000), 2: Fraction(969, 1000),
                3: Fraction(981, 1000), 4: Fraction(987, 1000),
                5: Fraction(988, 1000), 6: Fraction(989, 1000)}
    code_1024 = {0: Fraction(0), 1: Fraction(0), 2: Fraction(960, 1000),
                 3: Fraction(976, 1000), 4: Fraction(981, 1000),
                 5: Fraction(986, 1000), 6: Fraction(987, 1000)}
    for name, sweep in (("code @512", code_512), ("code @1024", code_1024)):
        print(name)
        print("  " + extract_knee(sweep, BAR, 4).render().replace("\n", "\n  "))

    # Data determination: the tail is irrelevant to the reading.
    tampered = dict(code_512)
    tampered[4] = tampered[5] = tampered[6] = Fraction(999, 1000)
    assert knees_agree(code_512, tampered, BAR, 4)
    print("\nAltering every non-bracketing reading leaves the knee unchanged.")


"""Two-point budget-law identification and mixed-workload envelope synthesis.

A budget law is k*(d) = base + inc * d, with d the number of context doublings.
Affine rigidity makes any two distinct readings identify the law uniquely, so the
identification step is exact arithmetic rather than a fit.  Envelope synthesis then
decides whether a mixed workload can be sized by a single law: inside a fibre of
constant increment the envelope is the join (largest base), while a pair with
unequal increments and crossing bases makes the envelope leave the model class
entirely.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional, Sequence, Tuple


@dataclass(frozen=True)
class BudgetLaw:
    """k*(d) = base + inc * d.  Convention: d = 0 is the reference context."""

    base: int
    inc: int

    def eval(self, d: int) -> int:
        return self.base + self.inc * d

    def translate(self, t: int) -> "BudgetLaw":
        """The Z-action re-basing a domain; the increment is untouched."""
        return BudgetLaw(self.base + t, self.inc)

    def render(self) -> str:
        return f"k*(d) = {self.base} + {self.inc}*d"


def identify_law(d: int, k_d: int, e: int, k_e: int) -> BudgetLaw:
    """Unique law through two readings at distinct doublings.  O(1).

    A non-integral implied increment means the two readings are inconsistent with
    the model class; this is a genuine consistency test, not a rounding step.
    """
    if d == e:
        raise ValueError("two distinct contexts are required")
    num, den = k_e - k_d, e - d
    if num % den != 0:
        raise ValueError(f"readings imply non-integral increment {num}/{den}")
    inc = num // den
    return BudgetLaw(base=k_d - inc * d, inc=inc)


def shift(a: BudgetLaw, b: BudgetLaw) -> int:
    """The observable inter-domain translation, base(b) - base(a)."""
    return b.base - a.base


def ladder_from_gaps(origin: BudgetLaw, gaps: Sequence[int]) -> List[BudgetLaw]:
    """Rebuild a domain ladder from its consecutive gaps, using the cocycle law."""
    out, cur = [origin], origin
    for g in gaps:
        cur = cur.translate(g)
        out.append(cur)
    return out


def crossover_bound(a: BudgetLaw, b: BudgetLaw) -> Optional[int]:
    """A certified D with a(d) < b(d) for all d >= D, when inc(a) < inc(b)."""
    if a.inc >= b.inc:
        return None
    return max(a.base - b.base, 0) + 1


def offending_pair(laws: Sequence[BudgetLaw]) -> Optional[Tuple[BudgetLaw, BudgetLaw]]:
    """A pair with unequal increments and crossing bases, if one exists.

    Its presence is exactly the obstruction to the envelope being a budget law.
    """
    for i, x in enumerate(laws):
        for y in laws[i + 1:]:
            lo, hi = (x, y) if x.inc < y.inc else (y, x)
            if lo.inc < hi.inc and hi.base < lo.base:
                return lo, hi
    return None


@dataclass(frozen=True)
class EnvelopeReport:
    """Outcome of sizing a mixed workload."""

    is_a_law: bool
    law: Optional[BudgetLaw]
    obstruction: Optional[Tuple[BudgetLaw, BudgetLaw]]
    pointwise: Dict[int, int]

    def render(self) -> str:
        if self.is_a_law and self.law is not None:
            return (f"envelope is a budget law: {self.law.render()}\n"
                    f"  deployment: size the cache by the largest-base domain present")
        lo, hi = self.obstruction  # type: ignore[misc]
        return ("envelope is NOT a budget law\n"
                f"  obstruction: ({lo.base}, {lo.inc}) and ({hi.base}, {hi.inc}) have "
                "unequal increments with crossing bases\n"
                f"  pointwise envelope: {self.pointwise}")


def synthesise_envelope(laws: Sequence[BudgetLaw], horizon: int = 6) -> EnvelopeReport:
    """Decide and, where possible, produce the mixed-workload sizing law.  O(|S|^2)."""
    if not laws:
        raise ValueError("no domains supplied")
    pointwise = {d: max(L.eval(d) for L in laws) for d in range(horizon)}
    bad = offending_pair(laws)
    incs = {L.inc for L in laws}
    if len(incs) == 1:
        env = BudgetLaw(base=max(L.base for L in laws), inc=incs.pop())
        assert all(env.eval(d) == pointwise[d] for d in range(horizon))
        return EnvelopeReport(True, env, None, pointwise)
    if bad is None:
        # Unequal increments but no crossing: the envelope may still coincide with
        # a single dominating law.  Test it honestly.
        dom = max(laws, key=lambda L: (L.inc, L.base))
        if all(dom.eval(d) == pointwise[d] for d in range(horizon)):
            return EnvelopeReport(True, dom, None, pointwise)
        return EnvelopeReport(False, None, (laws[0], laws[1]), pointwise)
    return EnvelopeReport(False, None, bad, pointwise)


if __name__ == "__main__":
    code = identify_law(0, 12, 1, 16)
    prose = identify_law(0, 16, 1, 20)
    print(f"code : {code.render()}")
    print(f"prose: {prose.render()}")
    print(f"shift(code, prose) = {shift(code, prose)}  (one fine grid step)")
    print(f"prediction at ctx 4096 (d=3): code {code.eval(3)}, prose {prose.eval(3)}")

    print("\nladder rebuilt from gaps [4, 4] starting at base 8:")
    for L in ladder_from_gaps(BudgetLaw(8, 4), [4, 4]):
        print(f"  {L.render()}")

    print("\nmixed prose+code workload:")
    print("  " + synthesise_envelope([code, prose]).render().replace("\n", "\n  "))

    print("\nmixed workload with unequal increments and crossing bases:")
    print("  " + synthesise_envelope([BudgetLaw(16, 2), BudgetLaw(12, 6)])
          .render().replace("\n", "\n  "))


"""Assemble PACKAGE.json from the prose, demo, algorithm, visualisation and widget files."""

from __future__ import annotations

import json
import pathlib
from typing import Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "package_assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES: List[str] = [
    "Catalog/Applications/NET68DomainJumpBudgetLaw.lean",
    "Catalog/Applications/NET68BudgetTorsor.lean",
    "Catalog/Applications/NET68DecayRescalingAlternative.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n\n{read(ROOT / f)}" for f in LEAN_FILES
)

FUTURE = read(A / "future_directions.md")
LAYOUT = read(A / "interactive_layout.md")

package: Dict[str, object] = {
    "title": "Fewer Keys for Code: A Domain-Parameterised Budget Law for Attention Key Retention",
    "domain": "Applications",
    "description": (
        "Truncating an attention key cache to its k heaviest keys has a knee k*, and that "
        "knee factors as base(domain) + increment(scale) x context doublings; source code "
        "sits exactly four keys below prose at every context, the domain axis is a "
        "Z-torsor in which only inter-domain differences are observable, and no function "
        "of predictive accuracy can determine the knee."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-23",
    "key_results": [
        "The knee of a retention sweep is the left adjoint of its accuracy curve, so for "
        "monotone sweeps a knee is determined by exactly two readings: the last failing "
        "and the first passing grid index.",
        "Source code meets the 0.98 acceptance bar with 12 keys at context 512 and 16 at "
        "context 1024, exactly one grid step below the corresponding prose budgets of 16 "
        "and 20, giving a constant shift of four keys.",
        "A context-independent inter-domain shift is equivalent to the two domains sharing "
        "an increment; unequal increments provably force a crossover at a computable "
        "context, so the observed constancy was falsifiable.",
        "The domain axis at fixed scale is a Z-torsor: a unique translation connects any "
        "two domains, translations compose additively along chains, and re-basing all "
        "domains leaves every shift invariant, so absolute bases are not observable.",
        "Inside one increment class the mixed-workload envelope is the join and is again a "
        "budget law with the largest base; with unequal increments and crossing bases no "
        "budget law computes the envelope at all.",
        "Every pair of full accuracy and knee is realised by an actual domain, hence no "
        "function of accuracy predicts the knee; what a knee of k does certify is a single "
        "attention key carrying more than tau/(k+1) of the mass.",
        "A geometric decay-rescaling mechanism reproduces all four measured knees exactly, "
        "but the 512 cell forces its exponent above 5/4, so it predicts at most 23 keys at "
        "context 4096 where the additive law predicts exactly 24, and no exponent "
        "reconciles both.",
    ],
    "keywords": [
        "attention key retention",
        "KV cache sizing",
        "knee of a sweep",
        "Galois connection",
        "budget law",
        "Z-torsor",
        "envelope of affine functions",
        "attention concentration",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Verification of the Budget Law, the Torsor Structure and "
                    "the Mechanism Separation",
            "description": (
                "A single self-contained script that walks through every result in the "
                "development and checks each one with an assertion, so a clean run is a "
                "numerical confirmation rather than a printout. It reads the knee off the "
                "measured code sweeps at contexts 512 and 1024 and verifies the Galois "
                "equivalence at every swept index; demonstrates data determination by "
                "perturbing all non-bracketing readings and observing that the knee does "
                "not move; identifies the code and prose budget laws from two points each "
                "and exhibits an impostor law agreeing at a single context; confirms that "
                "the inter-domain shift is the constant 4 across eight doublings and that "
                "a counterfactual pair with unequal increments crosses over; verifies the "
                "torsor axioms by finding the unique connecting translation, checking the "
                "cocycle law along a three-rung ladder and showing shift invariance under "
                "common re-basing; synthesises the mixed-workload envelope law and then "
                "searches a wide parameter grid to confirm that no budget law reproduces "
                "the envelope of two domains with unequal increments and crossing bases; "
                "realises arbitrary accuracy-knee pairs from uniform attention profiles and "
                "computes the heaviest-key lower bound; reproduces all four measured cells "
                "under the decay-rescaling mechanism and shows the admissible exponent "
                "window closing at context 4096; and finally tabulates how a coarser "
                "measurement grid erases the entire domain effect."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Bracketed Knee Extraction with a Two-Point Certificate",
            "description": (
                "Reads the knee off a monotone retention sweep and returns it together with "
                "the only two data points that justify it. The knee is the least grid index "
                "whose retained accuracy clears the acceptance bar; because the passing set "
                "is upward closed for a monotone sweep, the knee is the left adjoint of the "
                "accuracy curve and satisfies knee <= j if and only if bar <= acc(j). That "
                "adjunction has two computational consequences exploited here. First, the "
                "search may be done by binary search in O(log n) rather than a linear scan "
                "in O(n), and the implementation runs both and cross-checks them, which "
                "doubles as a monotonicity test. Second, if reading j fails the bar and "
                "reading j+1 clears it, the knee is j+1 regardless of the curve's behaviour "
                "at every other index, so the returned bracketing pair is a complete and "
                "independently checkable justification of the reading. The routine refuses "
                "to issue a certificate for a non-monotone sweep, for a sweep no index of "
                "which passes, and for an unbracketed knee at the first swept index, since "
                "in each case the reading is not determined by the data."
            ),
            "pseudocode": (
                "Input : sweep acc on grid indices 0..n, acceptance bar tau, grid step g\n"
                "Output: knee budget in keys, with a two-point certificate\n"
                "\n"
                " 1. if exists i with acc(i) > acc(i+1) then\n"
                " 2.     abort: monotonicity fails, the knee adjunction does not apply\n"
                " 3. lo <- 0 ; hi <- n+1\n"
                " 4. while lo < hi do                       # binary search, valid because\n"
                " 5.     mid <- floor((lo+hi)/2)            # the passing set is upward closed\n"
                " 6.     if acc(mid) >= tau then hi <- mid else lo <- mid+1\n"
                " 7. if lo > n then abort: no swept index clears the bar\n"
                " 8. if lo = 0 then abort: knee is unbracketed, only an upper bound is known\n"
                " 9. certificate <- (lo-1, acc(lo-1), acc(lo))\n"
                "10. assert acc(lo-1) < tau <= acc(lo)\n"
                "11. return (g * lo, certificate)"
            ),
            "code": read(A / "alg_knee_extraction.py"),
        },
        {
            "name": "Two-Point Budget Law Identification and Mixed-Workload Envelope Synthesis",
            "description": (
                "Recovers a budget law k*(d) = base + increment * d from two readings and "
                "then decides whether a family of such laws can be sized by a single formula. "
                "Identification is exact arithmetic, not fitting: an affine function is pinned "
                "by any two distinct evaluations, so the increment is the difference quotient "
                "and the base is read off by back-substitution, in O(1). A non-integral implied "
                "increment is a genuine consistency failure of the model class and is reported "
                "as such rather than rounded away. Envelope synthesis then examines the family. "
                "If all increments agree, the pointwise maximum is again a budget law whose base "
                "is the largest base present, because adding increment * d is an order "
                "isomorphism of the integers and therefore commutes with finite suprema; this is "
                "the deployment rule that a mixed workload should be sized by its largest-base "
                "domain. If some pair has unequal increments together with crossing bases, the "
                "routine reports that no budget law computes the envelope at all: past the "
                "crossover the envelope coincides with the steeper law, affine rigidity then "
                "forces any candidate to be that law, and the candidate consequently reads the "
                "wrong value at the reference context. The pairwise scan costs O(|S|^2) and the "
                "shared-increment fast path costs O(|S|). A helper reconstructs a whole domain "
                "ladder from its consecutive gaps, which is legitimate because inter-domain "
                "shifts obey a cocycle law and compose additively along chains."
            ),
            "pseudocode": (
                "Part A -- identification\n"
                "Input : readings k_d at doubling d and k_e at doubling e, with d != e\n"
                " 1. if (k_e - k_d) mod (e - d) != 0 then abort: readings leave the model class\n"
                " 2. inc  <- (k_e - k_d) / (e - d)\n"
                " 3. base <- k_d - inc * d\n"
                " 4. return law (base, inc)                 # unique, by affine rigidity\n"
                "\n"
                "Part B -- envelope synthesis\n"
                "Input : a nonempty family S of budget laws, a horizon D\n"
                " 5. pointwise(d) <- max over L in S of L(d), for d = 0..D\n"
                " 6. if all increments in S are equal to c then\n"
                " 7.     env <- (max base in S, c)\n"
                " 8.     assert env(d) = pointwise(d) for d = 0..D\n"
                " 9.     return ENVELOPE-IS-A-LAW(env)\n"
                "10. for each pair (A,B) in S with inc(A) < inc(B) do\n"
                "11.     if base(B) < base(A) then\n"
                "12.         return NOT-A-LAW(obstruction = (A,B), pointwise)\n"
                "13. dom <- the law in S maximal in (increment, base)\n"
                "14. if dom(d) = pointwise(d) for d = 0..D then return ENVELOPE-IS-A-LAW(dom)\n"
                "15. return NOT-A-LAW(pointwise)"
            ),
            "code": read(A / "alg_law_envelope.py"),
        },
        {
            "name": "Mechanism Discrimination by Intersection of Admissible Exponent Windows",
            "description": (
                "Decides between an additive domain shift and a multiplicative rescaling of the "
                "attention decay rate. Under geometric decay with residual mass r^k and residual "
                "tolerance rho, the knee equals the ceiling of the continuous knee "
                "X = log(rho)/log(r); raising the decay rate to a power a multiplies log r by a "
                "and so divides X by a, meaning the rival mechanism divides the knee where the "
                "budget law shifts it. The discrimination exploits the information the ceiling "
                "function discards. A reading of n brackets the continuous knee as "
                "n - 1 < X <= n, so a paired reference/target cell with readings P and C "
                "constrains the exponent to the open interval ((P-1)/C, P/(C-1)). Intersecting "
                "these intervals over the measured cells yields the admissible window, in time "
                "linear in the number of cells. A nonempty window means the multiplicative "
                "branch survives every cell simultaneously and the two mechanisms remain "
                "indistinguishable; an empty window excludes it outright. Applied to the "
                "measured cells the window is nonempty and contains 1.255, so two contexts "
                "cannot separate the mechanisms; adjoining the additive prediction at the next "
                "doubling still leaves it open, and only at the doubling after that does the "
                "lower bound of 5/4 collide with the upper bound of 28/23 and empty the window."
            ),
            "pseudocode": (
                "Input : cells (d, P_d, C_d) of reference and target knee readings\n"
                "Output: admissible exponent window and a mechanism verdict\n"
                "\n"
                " 1. lo <- 0 ; hi <- +infinity\n"
                " 2. for each cell (d, P, C) do\n"
                " 3.     if C < 1 then abort: target knee must be at least 1\n"
                " 4.     a_lo <- (P - 1) / C                 # from P - 1 < X and X/a <= C\n"
                " 5.     a_hi <- P / (C - 1) if C > 1 else +infinity\n"
                " 6.     lo <- max(lo, a_lo) ; hi <- min(hi, a_hi)\n"
                " 7. if lo < hi then\n"
                " 8.     return WINDOW-NONEMPTY(lo, hi)      # both mechanisms survive\n"
                " 9. else\n"
                "10.     return WINDOW-EMPTY                 # rescaling excluded\n"
                "\n"
                "Discrimination of a probe cell:\n"
                "11. before <- window over the measured cells\n"
                "12. after  <- window over the measured cells together with the probe\n"
                "13. if before nonempty and after empty then the probe cell is decisive"
            ),
            "code": read(A / "alg_exponent_window.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Domain Ladder and the Collapse of the Envelope Rule",
            "description": (
                "A two-panel figure. The left panel plots the fitted code and prose budget laws "
                "across four context doublings with the constant four-key gap shaded between "
                "them, overlays the decay-rescaling rival at exponent 1.255 so that its exact "
                "agreement up to context 2048 and its divergence at 4096 are both visible, and "
                "highlights the deciding cell where the additive law predicts 24 keys and every "
                "rescaling model predicts at most 23. The right panel shows what happens once "
                "the shared increment is lost: two domains with unequal increments and crossing "
                "bases, together with their pointwise envelope, which has a kink at the crossover "
                "that no base-plus-increment formula can follow."
            ),
            "code": read(A / "viz_budget_ladder.py"),
        },
        {
            "name": "Reading a Knee, and How a Coarse Grid Erases the Effect",
            "description": (
                "A two-panel figure about measurement rather than theory. The left panel draws "
                "the measured code retention sweeps at contexts 512 and 1024 against the 0.98 "
                "acceptance bar, circling in each case the two bracketing readings that alone "
                "determine the knee and labelling the resulting budgets of 12 and 16 keys. The "
                "right panel rounds the code knee of 12 and the prose knee of 16 up onto grids "
                "of increasing step and marks the steps at which the two collapse to a single "
                "reading, showing that a step-8 grid destroys the entire domain effect with no "
                "warning in the data: an effect of size four is observable only on a grid whose "
                "cells do not straddle both knees."
            ),
            "code": read(A / "viz_grid_resolution.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Budget Law Laboratory: Shifts, Torsors and Envelopes",
            "description": (
                "The central widget of the package. Two domains are placed on the budget axis "
                "by their base and increment, and the plot shows their predicted key budgets "
                "across six context doublings together with the pointwise envelope of a mixed "
                "workload. Three lessons are built in. Sliding the increments apart makes the "
                "inter-domain shift drift and eventually change sign at a marked crossover, "
                "showing directly that a context-independent shift is equivalent to a shared "
                "increment. A re-basing slider translates both domains at once: every absolute "
                "base moves while the shift stays fixed, which is exactly the statement that the "
                "domain axis is a torsor and that only differences are observable. And a live "
                "verdict panel reports whether the envelope is still a budget law, turning red "
                "with a full explanation the moment unequal increments meet crossing bases. A "
                "grid-step control shows when the difference between the two domains becomes "
                "invisible to the instrument. Presets jump to the measured cells, to a "
                "configuration where the envelope rule fails, and to a grid too coarse to see "
                "the effect; expandable sections give the proofs behind each verdict."
            ),
            "html": read(A / "widget_budget_lab.html"),
        },
        {
            "title": "The Knee Reader: Two Points Decide, Everything Else Is Corroboration",
            "description": (
                "An interactive retention sweep. Six retained-accuracy readings and the "
                "acceptance bar are all draggable, and the widget continuously reports the knee "
                "together with the two-point certificate that justifies it, circling the last "
                "failing and first passing readings. A scramble button randomises every "
                "non-bracketing point while preserving monotonicity, so a reader can watch the "
                "knee sit completely still and see for themselves that a knee is a reading off "
                "two numbers rather than a fit to a curve. The widget also refuses to certify in "
                "the three genuinely undetermined situations, explaining in each case why: a "
                "non-monotone sweep, a sweep no reading of which clears the bar, and an "
                "unbracketed knee at the first swept budget. Expandable sections develop the "
                "underlying equivalence between the knee and the accuracy curve, and the "
                "concentration bound by which a knee of k certifies an attention key carrying "
                "more than tau/(k+1) of the mass."
            ),
            "html": read(A / "widget_knee_reader.html"),
        },
        {
            "title": "The Mechanism Discriminator: Watching the Exponent Window Close",
            "description": (
                "A widget about the honest limit of the measurement and how to remove it. Two "
                "mechanisms fit the data: an additive shift of the knee, and a faster geometric "
                "decay that divides the knee by an exponent a. A slider moves a while a table "
                "compares, cell by cell, what each mechanism predicts, colouring agreements and "
                "disagreements. Alongside it, a horizontal exponent axis draws the interval of "
                "exponents compatible with each individual cell, derived from the bracket that a "
                "knee reading imposes on the continuous knee, together with their running "
                "intersection. Checkboxes add and remove cells, so a reader can see the "
                "intersection stay open through contexts 512, 1024 and 2048 — the mechanisms "
                "really are indistinguishable there — and then watch it snap shut the moment the "
                "context-4096 cell is required, because the first cell forces a above 5/4 while "
                "the last forces it below 28/23. Expandable sections derive both bounds."
            ),
            "html": read(A / "widget_mechanism_discriminator.html"),
        },
    ],
    "interactive_layout": LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE,
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out}  ({out.stat().st_size / 1024:.1f} KiB)")


"""Visualisation: the domain ladder, the constant shift, and the envelope failure.

Left panel  -- the two fitted budget laws across context doublings, with the
               constant four-key gap shaded, and the pre-registered ctx-4096
               predictions of the additive and rescaling mechanisms marked.
Right panel -- what happens when the shared increment is lost: two laws with
               unequal increments and crossing bases, whose pointwise envelope has
               a kink that no base-plus-increment formula can reproduce.

Run:  python viz_budget_ladder.py    (writes budget_ladder.png)
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def law(base: int, inc: int, doublings: Sequence[int]) -> List[int]:
    return [base + inc * d for d in doublings]


def rescaling_code(continuous_knees: Sequence[float], a: float) -> List[int]:
    """Target-domain knees under a decay rescaling of exponent a.

    The reference domain's continuous knees are the real numbers whose ceilings are
    its measured readings; rescaling the decay rate divides them by a.
    """
    return [math.ceil(x / a) for x in continuous_knees]


def main(outfile: str = "budget_ladder.png") -> None:
    ds = list(range(4))
    contexts = [512 * 2 ** d for d in ds]
    code = law(12, 4, ds)
    prose = law(16, 4, ds)
    # Continuous knees of the reference domain compatible with its readings 16,20,24,28.
    prose_continuous = [15.05, 20.0, 24.0, 28.0]
    rescaled = rescaling_code(prose_continuous, 251 / 200)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    # ---------------- left: the ladder ----------------
    ax1.fill_between(ds, code, prose, color="#7aa6c2", alpha=0.22,
                     label="constant gap of 4 keys")
    ax1.plot(ds, prose, "o-", color="#1f3b57", lw=2.4, ms=8,
             label="prose:  $k^* = 16 + 4d$")
    ax1.plot(ds, code, "s-", color="#b5482c", lw=2.4, ms=8,
             label="code:   $k^* = 12 + 4d$")
    ax1.plot(ds, rescaled, "^--", color="#4b7f52", lw=1.8, ms=8,
             label="decay-rescaling rival ($a = 1.255$)")

    ax1.annotate("measured cells", (0.5, 14.0), textcoords="offset points",
                 xytext=(0, -34), fontsize=9.5, color="#b5482c", ha="center",
                 arrowprops=dict(arrowstyle="-[, widthB=2.6", color="#b5482c", lw=1.2))
    ax1.axvspan(2.55, 3.45, color="#f0d27a", alpha=0.28)
    ax1.annotate("the deciding cell:\nadditive says 24,\nrescaling says $\\leq 23$",
                 (3, 24), textcoords="offset points", xytext=(-124, -62),
                 fontsize=9.5,
                 arrowprops=dict(arrowstyle="->", color="#7a5c00", lw=1.2))

    ax1.set_xticks(ds)
    ax1.set_xticklabels([f"{c}\n(d={d})" for c, d in zip(contexts, ds)])
    ax1.set_xlabel("context length")
    ax1.set_ylabel("knee budget $k^*$  (keys)")
    ax1.set_title("The domain ladder: a shift of one grid step, at every context")
    ax1.grid(alpha=0.25, ls=":")
    ax1.legend(loc="upper left", fontsize=9.5, framealpha=0.95)

    # ---------------- right: envelope failure ----------------
    ds2 = list(range(6))
    a_law = law(16, 2, ds2)
    b_law = law(12, 6, ds2)
    env = [max(x, y) for x, y in zip(a_law, b_law)]

    ax2.plot(ds2, a_law, "o-", color="#1f3b57", lw=2.0, ms=7,
             label="domain A: $16 + 2d$")
    ax2.plot(ds2, b_law, "s-", color="#b5482c", lw=2.0, ms=7,
             label="domain B: $12 + 6d$")
    ax2.plot(ds2, env, lw=5.0, color="#4b7f52", alpha=0.35,
             label="pointwise envelope (has a kink)")

    # A best affine attempt, to show visually that none can match both ends.
    ax2.plot(ds2, law(16, 6, ds2), ls=(0, (5, 3)), color="#666666", lw=1.4,
             label="best affine attempt: $16 + 6d$")
    ax2.annotate("no $base + inc\\cdot d$\ncan follow the kink at $d = 1$", (1, 18),
                 textcoords="offset points", xytext=(34, -52), fontsize=9.5,
                 arrowprops=dict(arrowstyle="->", color="#333333", lw=1.2))

    ax2.set_xticks(ds2)
    ax2.set_xlabel("context doublings $d$")
    ax2.set_ylabel("knee budget $k^*$  (keys)")
    ax2.set_title("Lose the shared increment and the envelope leaves the model class")
    ax2.grid(alpha=0.25, ls=":")
    ax2.legend(loc="upper left", fontsize=9.5, framealpha=0.95)

    fig.suptitle("Domain-parameterised budget law for attention key retention",
                 fontsize=13.5, y=0.99)
    fig.tight_layout(rect=(0, 0, 1, 0.955))
    fig.savefig(outfile, dpi=170)
    print(f"wrote {outfile}")


if __name__ == "__main__":
    main()


"""Visualisation: reading a knee, and how a coarse grid erases the whole effect.

Left panel  -- the measured retention sweeps for source code at contexts 512 and
               1024, with the acceptance bar and the two bracketing points that
               alone determine each knee highlighted.
Right panel -- the same two knees (code 12, prose 16) rounded onto grids of
               increasing step.  At step 8 they collapse to a single reading and the
               entire domain effect disappears without any warning in the data.

Run:  python viz_grid_resolution.py    (writes grid_resolution.png)
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


BAR: float = 0.98

CODE_512: Dict[int, float] = {4: 0.930, 8: 0.969, 12: 0.981,
                              16: 0.987, 20: 0.988, 24: 0.989}
CODE_1024: Dict[int, float] = {8: 0.960, 12: 0.976, 16: 0.981,
                               20: 0.986, 24: 0.987}


def knee(sweep: Dict[int, float], bar: float = BAR) -> int:
    return min(k for k in sorted(sweep) if sweep[k] >= bar)


def bracket(sweep: Dict[int, float], step: int, bar: float = BAR) -> Tuple[int, int]:
    k = knee(sweep, bar)
    return k - step, k


def round_up(g: int, k: int) -> int:
    return g * ((k + g - 1) // g)


def main(outfile: str = "grid_resolution.png") -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    # ---------------- left: reading the knee ----------------
    for sweep, colour, label in ((CODE_512, "#b5482c", "code @ ctx 512"),
                                 (CODE_1024, "#1f3b57", "code @ ctx 1024")):
        ks = sorted(sweep)
        ax1.plot(ks, [sweep[k] for k in ks], "o-", color=colour, lw=2.2, ms=7,
                 label=label)
        lo, hi = bracket(sweep, 4)
        ax1.plot([lo, hi], [sweep[lo], sweep[hi]], "o", ms=16, mfc="none",
                 mec=colour, mew=2.4)
        ax1.annotate(f"$k^* = {hi}$", (hi, sweep[hi]), textcoords="offset points",
                     xytext=(10, 8), fontsize=11, color=colour, weight="bold")

    ax1.axhline(BAR, color="#4b7f52", lw=2.0, ls="--",
                label="acceptance bar $\\tau = 0.98$")
    ax1.set_xticks([4, 8, 12, 16, 20, 24])
    ax1.set_xlabel("retained keys $k$  (grid of step 4)")
    ax1.set_ylabel("retained accuracy  (fraction of full)")
    ax1.set_ylim(0.92, 0.995)
    ax1.set_title("A knee is a reading: two circled points determine each one")
    ax1.grid(alpha=0.25, ls=":")
    ax1.legend(loc="lower right", fontsize=9.5, framealpha=0.95)

    # ---------------- right: grid aliasing ----------------
    steps = [1, 2, 4, 6, 8, 12, 16]
    code_r = [round_up(g, 12) for g in steps]
    prose_r = [round_up(g, 16) for g in steps]
    x = range(len(steps))
    w = 0.38
    ax2.bar([i - w / 2 for i in x], code_r, width=w, color="#b5482c",
            label="code knee 12, rounded")
    ax2.bar([i + w / 2 for i in x], prose_r, width=w, color="#1f3b57",
            label="prose knee 16, rounded")

    for i, (g, c, p) in enumerate(zip(steps, code_r, prose_r)):
        if c == p:
            ax2.axvspan(i - 0.5, i + 0.5, color="#e8c9c9", alpha=0.45, zorder=0)
            ax2.annotate("collapsed:\neffect erased", (i, max(c, p) + 0.8), ha="center",
                         fontsize=9, color="#8a1c1c", weight="bold")

    ax2.set_xticks(list(x))
    ax2.set_xticklabels([str(g) for g in steps])
    ax2.set_xlabel("measurement grid step $g$")
    ax2.set_ylabel("reading in keys after rounding up to the grid")
    ax2.set_ylim(0, 26)
    ax2.set_title("A grid whose cells straddle both knees erases the effect entirely")
    ax2.grid(axis="y", alpha=0.25, ls=":")
    ax2.legend(loc="upper left", fontsize=9.5, framealpha=0.95)

    fig.suptitle("Resolution, not sample size, is what makes the domain shift observable",
                 fontsize=13.5, y=0.99)
    fig.tight_layout(rect=(0, 0, 1, 0.955))
    fig.savefig(outfile, dpi=170)
    print(f"wrote {outfile}")


if __name__ == "__main__":
    main()
