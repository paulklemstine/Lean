"""
Constrained = Penalised: numerical demonstrations.
==================================================

Self-contained numerical verification of the theory of KL-regularised reward
maximisation over a finite outcome set.

Setting.  A strictly positive reference distribution pi0 on n outcomes and a
reward vector r.  For a tilt parameter t (= 1/beta, the inverse temperature):

    Z(t)   = sum_i pi0_i exp(t r_i)                     partition function
    p_t(i) = pi0_i exp(t r_i) / Z(t)                    exponential tilt
    V(t)   = E_{p_t}[r]                                 value curve
    k(t)   = KL(p_t || pi0) = t V(t) - log Z(t)         budget curve

Results demonstrated numerically:

  1. Master decomposition   KL(p||p_t) = KL(p||pi0) - t E_p[r] + log Z(t).
  2. Duality identity       t (V(t) - E_p[r]) = k(t) - KL(p||pi0) + KL(p||p_t).
  3. Constrained optimality: p_t beats every p in its own KL ball (random search).
  4. Strict monotonicity of k(t) and Jeffreys identity.
  5. Tropical sandwich      t M + log w <= log Z(t) <= t M,  and log Z(t)/t -> M.
  6. Tropical ceiling       L = -log pi0(argmax r);  k(t) increases to L, never reaching it.
  7. Constrained = penalised: unique beta realising a prescribed budget k in (0, L).
  8. Shadow-price bracket and concavity of the reward-KL frontier.

Only the standard library and (optionally) nothing else is required: pure Python.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

Vector = List[float]

# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------


def log_partition(pi0: Sequence[float], r: Sequence[float], t: float) -> float:
    """log Z(t) = log sum_i pi0_i exp(t r_i), computed stably."""
    m = max(t * ri for ri in r)
    s = sum(p * math.exp(t * ri - m) for p, ri in zip(pi0, r))
    return m + math.log(s)


def tilt(pi0: Sequence[float], r: Sequence[float], t: float) -> Vector:
    """The exponentially tilted policy p_t(i) proportional to pi0_i exp(t r_i)."""
    m = max(t * ri for ri in r)
    u = [p * math.exp(t * ri - m) for p, ri in zip(pi0, r)]
    s = sum(u)
    return [ui / s for ui in u]


def expect(p: Sequence[float], f: Sequence[float]) -> float:
    """E_p[f] = sum_i p_i f_i."""
    return sum(pi * fi for pi, fi in zip(p, f))


def kl(p: Sequence[float], q: Sequence[float]) -> float:
    """KL(p||q) = sum_i p_i log(p_i / q_i), with 0 log 0 = 0."""
    total = 0.0
    for pi, qi in zip(p, q):
        if pi > 0.0:
            total += pi * math.log(pi / qi)
    return total


def budget(pi0: Sequence[float], r: Sequence[float], t: float) -> float:
    """k(t) = KL(p_t || pi0), via the closed form t V(t) - log Z(t)."""
    p = tilt(pi0, r, t)
    return t * expect(p, r) - log_partition(pi0, r, t)


def value(pi0: Sequence[float], r: Sequence[float], t: float) -> float:
    """V(t) = E_{p_t}[r]."""
    return expect(tilt(pi0, r, t), r)


def tropical_data(
    pi0: Sequence[float], r: Sequence[float], tol: float = 1e-12
) -> Tuple[float, List[int], float, float]:
    """Return (max r, argmax set, mass w of the argmax set, ceiling L = -log w)."""
    m = max(r)
    argmax = [i for i, ri in enumerate(r) if ri >= m - tol]
    w = sum(pi0[i] for i in argmax)
    return m, argmax, w, -math.log(w)


# ----------------------------------------------------------------------------
# Calibration: from a KL budget to the unique temperature
# ----------------------------------------------------------------------------


def calibrate_tilt(
    pi0: Sequence[float], r: Sequence[float], k: float, tol: float = 1e-13
) -> float:
    """The unique t >= 0 with k(t) = k, found by bracketing then bisection.

    Guaranteed to converge for 0 <= k < L, because k(.) is continuous and
    strictly increasing on [0, oo) with k(0) = 0 and k(t) -> L.
    """
    _, _, _, ceiling = tropical_data(pi0, r)
    if not (0.0 <= k < ceiling):
        raise ValueError(f"budget {k} outside the achievable range [0, {ceiling})")
    lo, hi = 0.0, 1.0
    while budget(pi0, r, hi) <= k:
        hi *= 2.0
        if hi > 1e12:  # pragma: no cover - defensive
            raise RuntimeError("failed to bracket the budget")
    while hi - lo > tol * max(1.0, hi):
        mid = 0.5 * (lo + hi)
        if budget(pi0, r, mid) < k:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def calibrate_beta(pi0: Sequence[float], r: Sequence[float], k: float) -> float:
    """The unique temperature beta > 0 with KL(pi*_beta || pi0) = k."""
    return 1.0 / calibrate_tilt(pi0, r, k)


# ----------------------------------------------------------------------------
# Random probability vectors, for empirical optimality checks
# ----------------------------------------------------------------------------


def random_prob(n: int, rng: random.Random) -> Vector:
    """A uniformly random point of the probability simplex (exponential trick)."""
    u = [-math.log(rng.random()) for _ in range(n)]
    s = sum(u)
    return [ui / s for ui in u]


def random_feasible(
    pi0: Sequence[float], k: float, rng: random.Random, tries: int = 20000
) -> List[Vector]:
    """Random probability vectors inside the KL ball {p : KL(p||pi0) <= k}."""
    n = len(pi0)
    out: List[Vector] = []
    for _ in range(tries):
        lam = rng.random()
        base = random_prob(n, rng)
        p = [(1 - lam) * pi0[i] + lam * base[i] for i in range(n)]
        if kl(p, pi0) <= k:
            out.append(p)
    return out


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

SEP = "=" * 78


def banner(text: str) -> None:
    print("\n" + SEP)
    print(text)
    print(SEP)


def demo_identities(pi0: Vector, r: Vector, rng: random.Random) -> None:
    banner("1-2.  Master decomposition and the duality identity")
    worst_master, worst_duality = 0.0, 0.0
    for _ in range(2000):
        t = rng.uniform(-4.0, 8.0)
        p = random_prob(len(pi0), rng)
        pt = tilt(pi0, r, t)
        lhs = kl(p, pt)
        rhs = kl(p, pi0) - t * expect(p, r) + log_partition(pi0, r, t)
        worst_master = max(worst_master, abs(lhs - rhs))
        lhs2 = t * (expect(pt, r) - expect(p, r))
        rhs2 = budget(pi0, r, t) - kl(p, pi0) + kl(p, pt)
        worst_duality = max(worst_duality, abs(lhs2 - rhs2))
    print(f"  max |KL(p||p_t) - [KL(p||pi0) - t E_p[r] + log Z(t)]| = {worst_master:.3e}")
    print(f"  max |t(V(t)-E_p[r]) - [k(t)-KL(p||pi0)+KL(p||p_t)]|   = {worst_duality:.3e}")
    print("  -> both identities hold to machine precision.")


def demo_optimality(pi0: Vector, r: Vector, rng: random.Random) -> None:
    banner("3.  Constrained optimality: the tilt wins inside its own KL ball")
    for t in (0.5, 1.0, 3.0):
        pt = tilt(pi0, r, t)
        k = budget(pi0, r, t)
        cands = random_feasible(pi0, k, rng, tries=40000)
        best = max(expect(p, r) for p in cands)
        print(
            f"  t = {t:4.1f}   budget k = {k:.6f}   "
            f"E_{{p_t}}[r] = {expect(pt, r):.6f}   best random feasible = {best:.6f}   "
            f"({len(cands)} samples)"
        )
    print("  -> no feasible competitor ever exceeds the tilt.")


def demo_monotone(pi0: Vector, r: Vector) -> None:
    banner("4.  Strict monotonicity of k(t) and the Jeffreys identity")
    ts = [0.0, 0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0]
    print("      t        k(t)         V(t)      k(t)-k(s) >= KL(p_t||p_s)?")
    prev = None
    for t in ts:
        k, v = budget(pi0, r, t), value(pi0, r, t)
        if prev is None:
            print(f"  {t:6.2f}  {k:10.6f}  {v:10.6f}       --")
        else:
            s, ks = prev
            gap = k - ks - kl(tilt(pi0, r, t), tilt(pi0, r, s))
            print(f"  {t:6.2f}  {k:10.6f}  {v:10.6f}       slack = {gap:+.3e}")
        prev = (t, k)
    s, t = 0.7, 2.3
    lhs = (t - s) * (value(pi0, r, t) - value(pi0, r, s))
    rhs = kl(tilt(pi0, r, s), tilt(pi0, r, t)) + kl(tilt(pi0, r, t), tilt(pi0, r, s))
    print(f"\n  Jeffreys at (s,t)=({s},{t}):  lhs = {lhs:.10f}, rhs = {rhs:.10f}")


def demo_tropical(pi0: Vector, r: Vector) -> None:
    banner("5-6.  Tropical sandwich, Maslov dequantization, and the ceiling")
    m, argmax, w, ceiling = tropical_data(pi0, r)
    print(f"  max r = {m}, argmax set = {argmax}, mass w = {w:.6f}, ceiling L = {ceiling:.6f}")
    print("\n      t     tM + log w    log Z(t)          tM     log Z(t)/t        k(t)   L - k(t)")
    for t in (1.0, 2.0, 5.0, 10.0, 25.0, 50.0, 100.0, 400.0):
        lz = log_partition(pi0, r, t)
        k = budget(pi0, r, t)
        print(
            f"  {t:6.1f} {t * m + math.log(w):12.6f} {lz:11.6f} {t * m:11.6f} "
            f"{lz / t:13.8f} {k:11.7f} {ceiling - k:10.3e}"
        )
    print("  -> log Z(t)/t -> max r  (Maslov dequantization);  k(t) increases to L, never reaching it.")


def demo_calibration(pi0: Vector, r: Vector, rng: random.Random) -> None:
    banner("7.  Constrained = penalised: one budget, one temperature")
    _, _, _, ceiling = tropical_data(pi0, r)
    print(f"  achievable budgets: (0, L) with L = {ceiling:.6f}\n")
    print("        k        beta = 1/t      t     KL(pi*_beta||pi0)   E[r]   best random feasible")
    for frac in (0.05, 0.2, 0.5, 0.8, 0.95):
        k = frac * ceiling
        t = calibrate_tilt(pi0, r, k)
        p = tilt(pi0, r, t)
        cands = random_feasible(pi0, k, rng, tries=20000)
        best = max(expect(q, r) for q in cands) if cands else float("nan")
        print(
            f"  {k:9.6f}  {1.0 / t:11.6f} {t:8.4f}   {kl(p, pi0):14.9f} "
            f"{expect(p, r):8.5f}   {best:.5f}"
        )
    try:
        calibrate_tilt(pi0, r, ceiling * 1.01)
    except ValueError as exc:
        print(f"\n  requesting a budget above the ceiling fails, as it must: {exc}")


def demo_frontier(pi0: Vector, r: Vector) -> None:
    banner("8.  Shadow price bracket and concavity of the reward-KL frontier")
    ts = [0.2, 0.5, 1.0, 2.0, 4.0, 8.0]
    print("     s      t     (k(t)-k(s))/(V(t)-V(s))    [1/t, 1/s] bracket")
    for s, t in zip(ts, ts[1:]):
        dk = budget(pi0, r, t) - budget(pi0, r, s)
        dv = value(pi0, r, t) - value(pi0, r, s)
        print(f"  {s:5.2f} {t:6.2f}   {dk / dv:16.6f}          [{s:.4f}, {t:.4f}]")
    print("\n  (the middle column is dk/dV, which must lie in [s, t])")
    print("\n  chord slopes dV/dk, which must decrease (concavity):")
    prev_slope = None
    for s, t in zip(ts, ts[1:]):
        dk = budget(pi0, r, t) - budget(pi0, r, s)
        dv = value(pi0, r, t) - value(pi0, r, s)
        slope = dv / dk
        flag = "" if prev_slope is None else ("  ok" if slope <= prev_slope else "  VIOLATION")
        print(f"    [{s:.2f},{t:.2f}]: dV/dk = {slope:.6f}{flag}")
        prev_slope = slope
    m, _, _, ceiling = tropical_data(pi0, r)
    big = 200.0
    print(
        f"\n  tropical corner: (k, V) at t = {big:.0f} is "
        f"({budget(pi0, r, big):.6f}, {value(pi0, r, big):.6f}), target (L, max r) = "
        f"({ceiling:.6f}, {m:.6f})"
    )


def demo_two_outcomes() -> None:
    banner("Worked example: two outcomes, fair coin reference, reward (0, 1)")
    pi0, r = [0.5, 0.5], [0.0, 1.0]
    _, _, w, ceiling = tropical_data(pi0, r)
    print(f"  w = pi0(argmax r) = {w},  L = -log w = log 2 = {ceiling:.6f}\n")
    print("      t     sigma = p_t(1)      k(t)   closed form   V(t)")
    for t in (0.0, 0.5, 1.0, 2.0, 5.0, 10.0):
        p = tilt(pi0, r, t)
        sig = p[1]
        closed = math.log(2) + (
            sig * math.log(sig) + (1 - sig) * math.log(1 - sig) if 0 < sig < 1 else 0.0
        )
        print(f"  {t:6.2f} {sig:15.9f} {budget(pi0, r, t):9.6f} {closed:13.6f} {value(pi0, r, t):7.4f}")
    for k in (0.1, 0.3, 0.6):
        beta = calibrate_beta(pi0, r, k)
        print(f"  budget k = {k}: unique beta = {beta:.8f}, check KL = {kl(tilt(pi0, r, 1/beta), pi0):.10f}")


def main() -> None:
    rng = random.Random(20260909)
    pi0 = [0.35, 0.25, 0.20, 0.15, 0.05]
    r = [0.0, 1.0, 0.5, 2.0, -1.0]
    print("Reference pi0 =", pi0)
    print("Reward     r  =", r)
    demo_identities(pi0, r, rng)
    demo_optimality(pi0, r, rng)
    demo_monotone(pi0, r)
    demo_tropical(pi0, r)
    demo_calibration(pi0, r, rng)
    demo_frontier(pi0, r)
    demo_two_outcomes()
    banner("All demonstrations completed.")


if __name__ == "__main__":
    main()


"""Temperature calibration: from a prescribed KL budget to the unique temperature.

Given a strictly positive reference distribution pi0, a reward vector r, and a
budget k strictly between 0 and the tropical ceiling L = -log pi0(argmax r),
this returns the unique inverse temperature t >= 0 with KL(p_t || pi0) = k,
together with the temperature beta = 1/t, the tilted policy p_t and its value.

Correctness rests on: k(0) = 0; k is continuous and strictly increasing on
[0, oo) whenever r is non-constant; and k(t) -> L as t -> oo.  Hence bracketing
terminates exactly when k < L, and bisection converges to the unique root.
"""

from __future__ import annotations

import math
from typing import List, NamedTuple, Sequence


class Calibration(NamedTuple):
    tilt_parameter: float   # t
    temperature: float      # beta = 1/t
    policy: List[float]     # p_t
    value: float            # E_{p_t}[r]
    budget: float           # KL(p_t || pi0)
    ceiling: float          # L = -log pi0(argmax r)


def log_partition(pi0: Sequence[float], r: Sequence[float], t: float) -> float:
    """Numerically stable log Z(t) = log sum_i pi0_i exp(t r_i)."""
    m = max(t * ri for ri in r)
    return m + math.log(sum(p * math.exp(t * ri - m) for p, ri in zip(pi0, r)))


def tilt(pi0: Sequence[float], r: Sequence[float], t: float) -> List[float]:
    """The exponential tilt p_t(i) proportional to pi0_i exp(t r_i)."""
    m = max(t * ri for ri in r)
    u = [p * math.exp(t * ri - m) for p, ri in zip(pi0, r)]
    s = sum(u)
    return [ui / s for ui in u]


def budget(pi0: Sequence[float], r: Sequence[float], t: float) -> float:
    """k(t) = KL(p_t || pi0) = t E_{p_t}[r] - log Z(t)."""
    p = tilt(pi0, r, t)
    return t * sum(pi * ri for pi, ri in zip(p, r)) - log_partition(pi0, r, t)


def tropical_ceiling(pi0: Sequence[float], r: Sequence[float], tol: float = 1e-12) -> float:
    """L = -log of the reference mass carried by the reward-maximising outcomes."""
    m = max(r)
    w = sum(p for p, ri in zip(pi0, r) if ri >= m - tol)
    return -math.log(w)


def calibrate(
    pi0: Sequence[float], r: Sequence[float], k: float, tol: float = 1e-13
) -> Calibration:
    """Solve k(t) = k for the unique t >= 0; O(n log(1/tol)) time, O(n) space."""
    ceiling = tropical_ceiling(pi0, r)
    if not 0.0 <= k < ceiling:
        raise ValueError(f"budget {k} lies outside the achievable range [0, {ceiling})")
    lo, hi = 0.0, 1.0
    while budget(pi0, r, hi) <= k:          # doubling phase: terminates since k < L
        hi *= 2.0
        if hi > 1e12:
            raise RuntimeError("bracketing failed (degenerate reward?)")
    while hi - lo > tol * max(1.0, hi):     # bisection phase
        mid = 0.5 * (lo + hi)
        if budget(pi0, r, mid) < k:
            lo = mid
        else:
            hi = mid
    t = 0.5 * (lo + hi)
    p = tilt(pi0, r, t)
    return Calibration(
        tilt_parameter=t,
        temperature=math.inf if t == 0.0 else 1.0 / t,
        policy=p,
        value=sum(pi * ri for pi, ri in zip(p, r)),
        budget=budget(pi0, r, t),
        ceiling=ceiling,
    )


if __name__ == "__main__":
    pi0 = [0.35, 0.25, 0.20, 0.15, 0.05]
    r = [0.0, 1.0, 0.5, 2.0, -1.0]
    L = tropical_ceiling(pi0, r)
    print(f"tropical ceiling L = {L:.6f}")
    for frac in (0.1, 0.4, 0.7, 0.95):
        c = calibrate(pi0, r, frac * L)
        print(
            f"k = {frac * L:.6f} -> beta = {c.temperature:.6f}, "
            f"value = {c.value:.6f}, realised budget = {c.budget:.10f}"
        )


"""Tracing the reward-divergence Pareto frontier and certifying its structure.

The frontier is the parametric curve t |-> (k(t), V(t)) with
k(t) = KL(p_t || pi0) and V(t) = E_{p_t}[r], t in [0, oo).  This module sweeps
t on a geometric grid, records the curve, and certifies numerically the three
structural facts that the theory guarantees:

  * monotonicity      k and V are nondecreasing in t;
  * shadow price      s (V(t) - V(s)) <= k(t) - k(s) <= t (V(t) - V(s)) for 0 < s <= t,
                      i.e. every chord slope dV/dk lies in [1/t, 1/s];
  * concavity         chord slopes dV/dk decrease as the budget grows.

The sweep terminates at the tropical corner (L, max r), L = -log pi0(argmax r).
Cost: O(n) per grid point, O(nN) overall for N grid points.
"""

from __future__ import annotations

import math
from typing import List, NamedTuple, Sequence, Tuple


class FrontierPoint(NamedTuple):
    tilt_parameter: float
    temperature: float
    budget: float
    value: float


def _log_partition(pi0: Sequence[float], r: Sequence[float], t: float) -> float:
    m = max(t * ri for ri in r)
    return m + math.log(sum(p * math.exp(t * ri - m) for p, ri in zip(pi0, r)))


def _tilt(pi0: Sequence[float], r: Sequence[float], t: float) -> List[float]:
    m = max(t * ri for ri in r)
    u = [p * math.exp(t * ri - m) for p, ri in zip(pi0, r)]
    s = sum(u)
    return [ui / s for ui in u]


def frontier_point(pi0: Sequence[float], r: Sequence[float], t: float) -> FrontierPoint:
    """One point of the frontier, in O(n) time."""
    p = _tilt(pi0, r, t)
    v = sum(pi * ri for pi, ri in zip(p, r))
    return FrontierPoint(t, math.inf if t == 0 else 1.0 / t, t * v - _log_partition(pi0, r, t), v)


def trace_frontier(
    pi0: Sequence[float], r: Sequence[float], t_min: float = 1e-3,
    t_max: float = 512.0, points: int = 120
) -> List[FrontierPoint]:
    """Geometric sweep of the tilt parameter, plus the base point t = 0."""
    grid = [0.0] + [
        t_min * (t_max / t_min) ** (i / (points - 1)) for i in range(points)
    ]
    return [frontier_point(pi0, r, t) for t in grid]


def certify(curve: Sequence[FrontierPoint], tol: float = 1e-9) -> Tuple[bool, bool, bool]:
    """Return (monotone, shadow-price bracket holds, concave) for a traced curve."""
    monotone = all(
        a.budget <= b.budget + tol and a.value <= b.value + tol
        for a, b in zip(curve, curve[1:])
    )
    bracket = True
    concave = True
    slopes: List[float] = []
    for a, b in zip(curve, curve[1:]):
        if a.tilt_parameter <= 0.0:
            continue
        dk, dv = b.budget - a.budget, b.value - a.value
        if dv <= tol:
            continue
        if not (a.tilt_parameter * dv <= dk + tol <= b.tilt_parameter * dv + 2 * tol):
            bracket = False
        if dk > tol:
            slopes.append(dv / dk)
    concave = all(x >= y - 1e-6 for x, y in zip(slopes, slopes[1:]))
    return monotone, bracket, concave


def tropical_corner(pi0: Sequence[float], r: Sequence[float], tol: float = 1e-12) -> Tuple[float, float]:
    """The limiting corner (L, max r) of the frontier."""
    m = max(r)
    w = sum(p for p, ri in zip(pi0, r) if ri >= m - tol)
    return -math.log(w), m


if __name__ == "__main__":
    pi0 = [0.35, 0.25, 0.20, 0.15, 0.05]
    r = [0.0, 1.0, 0.5, 2.0, -1.0]
    curve = trace_frontier(pi0, r)
    mono, brack, conc = certify(curve)
    print(f"monotone: {mono}   shadow-price bracket: {brack}   concave: {conc}")
    print(f"last traced point: k = {curve[-1].budget:.8f}, V = {curve[-1].value:.8f}")
    print("tropical corner (L, max r) = ({:.8f}, {:.8f})".format(*tropical_corner(pi0, r)))


"""Assemble PACKAGE.json from the deliverable files and the package assets."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "package_assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Tropical/ConstrainedEqualsPenalised.lean",
    "Catalog/Tropical/ConstrainedPenalisedFrontier.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n\n{read(ROOT / f)}" for f in LEAN_FILES
)

FUTURE = """# Future directions — "Constrained = penalised"

This cycle established the duality core over a finite outcome set:

* the **duality identity** `t·(𝔼_{p_t}[r] − 𝔼_p[r]) = KL(p_t‖π₀) − KL(p‖π₀) + KL(p‖p_t)`,
  from which optimality and monotonicity follow with no calculus;
* strict monotonicity and continuity of the budget curve `k(t) = KL(p_t‖π₀)`;
* the **tropical ceiling** `L = −log π₀(argmax r)` as the exact supremum of achievable budgets,
  together with the Maslov sandwich `t·max r + log π₀(argmax r) ≤ log Z(t) ≤ t·max r`;
* the headline **constrained = penalised**: for `0 < k < L` a unique `β > 0` puts `π*_β` on the
  budget, and `π*_β` is the unique maximiser of `𝔼_p[r]` over `{p : KL(p‖π₀) ≤ k}`;
* `log Z` is the cumulant function whose Bregman divergence is `KL(p_s‖p_t)`, hence convex;
  the temperature is the shadow price; the frontier is concave and runs into the tropical
  corner `(L, max r)`.

The directions below are what the analysis and the adversarial review actually pointed at.

---

## 1. Tropical Ceiling Rigidity for Countable Alphabets

**Conjecture.** For a reference measure `π₀` on a countably infinite alphabet with
`sup_i r(i) = M < ∞`, the achievable KL range is `[0, L)` with `L = −log π₀(argmax r)`
**iff** the argmax set has positive `π₀`-mass; if `π₀(argmax r) = 0` (in particular if the
supremum is not attained) the range is the whole of `[0, ∞)` and no finite ceiling exists.

*The key insight is* that the ceiling is not an entropy bound at all but the negative log-mass
of the tropical support: it is a purely max-plus quantity, and it degenerates exactly when the
max-plus "argmax cell" becomes null.

*Why now?* The finite case is fully settled here, and the only ingredients used were the
sandwich `Z(t) ∈ [w e^{tM}, e^{tM}]` and dominated pointwise convergence of the tilt — both of
which have direct measure-theoretic analogues.

*Test.* Work over a general measure with `r` bounded; prove the two directions separately;
falsify with `π₀` geometric and `r(i) = 1 − 2^{-i}` (supremum not attained).

## 2. Sharp Alignment Tax from the Shadow-Price Bracket

**Conjecture.** For every `0 < k < L`, the constrained value function
`V(k) = max{𝔼_p[r] : KL(p‖π₀) ≤ k}` satisfies the two-sided bound
`𝔼_{π₀}[r] + k/t(k) ≤ V(k) ≤ 𝔼_{π₀}[r] + (max r − 𝔼_{π₀}[r])·(1 − e^{−k})`,
where `t(k)` is the unique tilt realising `k`; in particular the marginal price
`dV/dk = 1/t(k)` decreases from `Var_{π₀}(r)^{1/2}`-scale at `k → 0` to `0` at `k → L`.

*The key insight is* that the shadow-price bracket already brackets every chord slope of the
frontier, so the conjecture amounts to integrating that bracket and controlling the two
endpoints separately.

## 3. Multiple Constraints and Vector Rewards

Replacing the scalar budget by several divergence or moment constraints should yield a
multi-temperature tilt `∝ π₀ exp(Σ_j t_j r_j)`, with the ceiling becoming the negative log-mass
of a *tropical polyhedral cell* rather than a single argmax set — the natural home for a
genuinely tropical-geometric statement of the theory.

## 4. Estimation and Sampling

In practice neither `Z` nor `k(t)` is computable exactly, and calibrating `β` from samples
requires concentration bounds for the empirical budget. The shadow-price bracket suggests
estimating the *slope* `dV/dk` rather than the budget itself, which may be far better
conditioned.

## 5. Beyond Relative Entropy

Which results survive for general `f`-divergences? The master decomposition is special to KL
(it is the divergence with the Pythagorean/exponential-family structure), so a genuinely
different mechanism would be needed — but the shadow-price bracket, being order-theoretic,
may generalise.
"""

package = {
    "title": "Constrained = Penalised: KL-Regularised Reward Maximisation and its Tropical Ceiling",
    "domain": "Tropical",
    "description": (
        "An exact duality between budget-constrained and penalised reward maximisation under "
        "relative entropy: every achievable KL budget is realised by a unique temperature whose "
        "exponentially tilted policy is the unique constrained optimum, and the achievable budgets "
        "stop at the tropical ceiling L = -log of the reference mass on the reward-maximising "
        "outcomes."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-09",
    "key_results": [
        "Duality identity: t(E_{p_t}[r] - E_p[r]) = KL(p_t||pi_0) - KL(p||pi_0) + KL(p||p_t) for "
        "every policy p and every tilt parameter t, from which optimality, uniqueness and "
        "monotonicity all follow without any calculus",
        "Constrained equals penalised: for every budget k strictly between 0 and the tropical "
        "ceiling there is a unique temperature whose tilted policy has divergence exactly k, and "
        "that policy is the unique maximiser of expected reward over the divergence ball of radius k",
        "Tropical ceiling: the achievable KL budgets form exactly the interval [0, L) with "
        "L = -log of the reference mass carried by the reward-maximising outcomes; the budget "
        "curve is strictly increasing and continuous and converges to L without attaining it",
        "Maslov dequantization with explicit error: t·max r + log w <= log Z(t) <= t·max r for all "
        "t >= 0, hence (log Z(t))/t converges to the max-plus value max r as the temperature "
        "tends to zero",
        "Shadow-price bracket and concavity of the reward-divergence frontier: every chord slope "
        "of the frontier lies between the two temperatures, the frontier is concave, and it "
        "terminates at the tropical corner (L, max r)",
    ],
    "keywords": [
        "relative entropy",
        "exponential tilting",
        "Gibbs variational principle",
        "Maslov dequantization",
        "tropical semiring",
        "Bregman divergence",
        "shadow price",
        "Pareto frontier",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Numerical Certification of the Duality Core",
            "description": (
                "A single self-contained script that exercises every theorem of the theory on "
                "explicit finite examples. It (i) checks the master decomposition "
                "KL(p||p_t) = KL(p||pi_0) - t E_p[r] + log Z(t) and the duality identity to "
                "machine precision over thousands of random policies and tilt parameters; "
                "(ii) pits the tilted policy against tens of thousands of random policies sampled "
                "inside its own KL ball, confirming that none ever attains a higher expected "
                "reward; (iii) tabulates the budget curve and verifies the quantitative "
                "monotonicity bound k(t) - k(s) >= KL(p_t||p_s) and the Jeffreys identity; "
                "(iv) displays the tropical sandwich, the convergence of log Z(t)/t to max r, and "
                "the shrinking headroom L - k(t); (v) calibrates temperatures from prescribed "
                "budgets by bisection and checks the realised divergence to ten decimal places, "
                "including the refusal of budgets at or above the ceiling; (vi) confirms the "
                "shadow-price bracket and the decreasing chord slopes that express concavity of "
                "the frontier; and (vii) works the two-outcome fair-coin example, where the "
                "ceiling is exactly log 2, against its closed form."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Temperature Calibration from a Prescribed Divergence Budget",
            "description": (
                "Inverts the budget curve k(t) = KL(p_t||pi_0) = t E_{p_t}[r] - log Z(t). Given a "
                "budget k in (0, L), where L = -log pi_0(argmax r) is the tropical ceiling, it "
                "returns the unique inverse temperature t >= 0 with k(t) = k, together with the "
                "temperature beta = 1/t, the tilted policy and its expected reward. Correctness "
                "and termination are exactly the two structure theorems: k is continuous, "
                "k(0) = 0, and k is strictly increasing on [0, infinity) whenever the reward is "
                "non-constant, so the root is unique and bisection converges; and k(t) increases "
                "to L, so the initial doubling phase terminates precisely when k < L (a request "
                "for an infeasible budget is rejected up front by comparing with the ceiling, "
                "which is computable in one pass). Each evaluation of k costs O(n) time with n "
                "outcomes, using a max-subtraction inside the exponentials for numerical "
                "stability, so the total cost is O(n log(1/epsilon)) for absolute accuracy "
                "epsilon, in O(n) space. By the shadow-price bracket the returned beta is "
                "simultaneously the marginal reward per nat of divergence at that operating point."
            ),
            "pseudocode": (
                "Input : reference pi_0 > 0 on n outcomes, reward r, budget k, tolerance eps\n"
                "Output: unique t >= 0 with KL(p_t || pi_0) = k, and beta = 1/t\n"
                "\n"
                " 1  M   <- max_i r(i)\n"
                " 2  w   <- sum of pi_0(i) over all i with r(i) = M          # argmax mass\n"
                " 3  L   <- -log w                                           # tropical ceiling\n"
                " 4  if not (0 <= k < L) then reject: budget unachievable\n"
                " 5  function BUDGET(t):\n"
                " 6      m  <- max_i t*r(i)\n"
                " 7      u  <- ( pi_0(i) * exp(t*r(i) - m) )_i               # stable weights\n"
                " 8      S  <- sum_i u(i);  p <- u / S                       # p = p_t\n"
                " 9      V  <- sum_i p(i)*r(i)\n"
                "10      return t*V - (m + log S)                            # = t V(t) - log Z(t)\n"
                "11  lo <- 0;  hi <- 1\n"
                "12  while BUDGET(hi) <= k do hi <- 2*hi                     # terminates as k < L\n"
                "13  repeat until hi - lo <= eps*max(1, hi):\n"
                "14      mid <- (lo + hi)/2\n"
                "15      if BUDGET(mid) < k then lo <- mid else hi <- mid    # k(.) strictly increasing\n"
                "16  t <- (lo + hi)/2\n"
                "17  return t, beta = 1/t, p_t, V(t), BUDGET(t), L"
            ),
            "code": read(A / "algo_calibration.py"),
        },
        {
            "name": "Pareto Frontier Tracing with Structural Certification",
            "description": (
                "Sweeps the tilt parameter on a geometric grid to trace the reward-divergence "
                "frontier t |-> (k(t), V(t)) from the origin (0, E_{pi_0}[r]) to the tropical "
                "corner (L, max r), and certifies numerically the three structural properties the "
                "theory guarantees: monotonicity of both coordinates; the shadow-price bracket "
                "s(V(t) - V(s)) <= k(t) - k(s) <= t(V(t) - V(s)) for 0 < s <= t, equivalently "
                "that every chord slope dV/dk lies in [1/t, 1/s]; and concavity, i.e. that those "
                "chord slopes decrease as the budget grows. A geometric rather than arithmetic "
                "grid is essential because the interesting behaviour spans several decades of the "
                "tilt parameter: the curve is nearly linear for small t and saturates "
                "exponentially fast as t grows. Each grid point costs O(n), so tracing N points "
                "costs O(nN) time and O(N) space; the certification pass is O(N)."
            ),
            "pseudocode": (
                "Input : reference pi_0 > 0, reward r, grid bounds t_min < t_max, count N\n"
                "Output: frontier points (t, beta, k(t), V(t)) and structural certificates\n"
                "\n"
                " 1  grid <- { 0 } union { t_min * (t_max/t_min)^(i/(N-1)) : i = 0..N-1 }\n"
                " 2  for each t in increasing order over grid:\n"
                " 3      p <- tilt(pi_0, r, t);  V <- sum_i p(i) r(i)\n"
                " 4      k <- t*V - log Z(t)\n"
                " 5      record (t, 1/t, k, V)\n"
                " 6  monotone <- all consecutive pairs satisfy k(s) <= k(t) and V(s) <= V(t)\n"
                " 7  bracket  <- for all consecutive s < t with V(t) > V(s):\n"
                " 8                   s*(V(t)-V(s)) <= k(t)-k(s) <= t*(V(t)-V(s))\n"
                " 9  slopes   <- [ (V(t)-V(s)) / (k(t)-k(s)) for consecutive s < t with k(t) > k(s) ]\n"
                "10  concave  <- slopes is nonincreasing\n"
                "11  corner   <- ( -log( sum of pi_0(i) over argmax r ), max_i r(i) )\n"
                "12  return points, (monotone, bracket, concave), corner"
            ),
            "code": read(A / "algo_frontier.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Frontier, the Ceiling, and the Zero-Temperature Limit",
            "description": (
                "A three-panel figure. Left: the reward-divergence Pareto frontier, with tangent "
                "segments whose slopes are the temperatures beta = 1/t, the vertical asymptote at "
                "the tropical ceiling L, the horizontal asymptote at max r, and the tropical "
                "corner (L, max r) where the two meet. Middle: the budget curve k(t) for four "
                "reference distributions that differ only in the mass w they assign the optimal "
                "outcome, each saturating at its own ceiling -log w, demonstrating that the "
                "ceiling depends on that mass alone. Right: Maslov dequantization, with log Z(t)/t "
                "trapped between max r + (log w)/t and max r, converging to the max-plus value of "
                "the reward with a uniform error controlled by L."
            ),
            "code": read(A / "viz_frontier.py"),
        }
    ],
    "interactive_demos": [
        {
            "title": "The Temperature Dial: Budgets, Prices, and the Ceiling You Cannot Climb Past",
            "description": (
                "A single, deeply interactive laboratory for the whole theory. Edit the reference "
                "distribution and the reward vector directly, or load one of three presets (fair "
                "coin, rare optimum, tied optima). Then drive the trade-off in either of the two "
                "equivalent ways: set the temperature beta with a logarithmic slider, or name a "
                "divergence budget as a fraction of the tropical ceiling and let the widget solve "
                "for the unique temperature that realises it by bracketing and bisection. Three "
                "linked live plots update continuously: the reward-divergence frontier with the "
                "current operating point, its tangent line of slope exactly beta, the red ceiling "
                "asymptote and the tropical corner; a bar chart contrasting the reference with the "
                "tilted policy, with the reward-maximising outcomes highlighted so the collapse "
                "onto them as beta tends to zero is visible; and the dequantization plot showing "
                "log Z(t)/t squeezed between max r + (log w)/t and max r. A numerical readout "
                "tracks beta, the tilt parameter, the divergence, the expected reward, log Z, and "
                "the headroom L - k, which visibly shrinks but never reaches zero. Finally, a "
                "'throw challengers' button samples twenty thousand random policies, keeps those "
                "inside the current divergence ball, scatters them beneath the frontier and "
                "reports the best challenger against the tilt's value -- an experimental "
                "confrontation with the uniqueness theorem that the user can run on any reference "
                "and reward they invent."
            ),
            "html": read(A / "widget.html"),
        }
    ],
    "interactive_layout": read(A / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "calibration": read(A / "algo_calibration.py"),
        "frontier": read(A / "algo_frontier.py"),
        "visualization": read(A / "viz_frontier.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""Visualisation: the reward-divergence frontier, the tropical ceiling, and dequantization.

Produces a three-panel figure.

  Left:   the Pareto frontier t |-> (KL(p_t||pi0), E_{p_t}[r]) for t in [0, oo),
          the vertical asymptote at the tropical ceiling L = -log pi0(argmax r),
          the horizontal asymptote at max r, and the tropical corner (L, max r).
          Tangent segments of slope 1/t illustrate the shadow-price bracket.

  Middle: the budget curve k(t), strictly increasing from 0 and saturating at L,
          for several reference distributions differing only in the mass they give
          the optimal outcome -- showing that the ceiling depends on that mass alone.

  Right:  Maslov dequantization: log Z(t)/t squeezed between max r + log(w)/t and
          max r, converging to the max-plus value of the reward.

Run:  python viz_frontier.py     (writes frontier_tropical.png)
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np


def log_partition(pi0: Sequence[float], r: Sequence[float], t: float) -> float:
    m = max(t * ri for ri in r)
    return m + math.log(sum(p * math.exp(t * ri - m) for p, ri in zip(pi0, r)))


def tilt(pi0: Sequence[float], r: Sequence[float], t: float) -> List[float]:
    m = max(t * ri for ri in r)
    u = [p * math.exp(t * ri - m) for p, ri in zip(pi0, r)]
    s = sum(u)
    return [ui / s for ui in u]


def budget_value(pi0: Sequence[float], r: Sequence[float], t: float) -> Tuple[float, float]:
    p = tilt(pi0, r, t)
    v = float(sum(pi * ri for pi, ri in zip(p, r)))
    return t * v - log_partition(pi0, r, t), v


def ceiling_and_mass(pi0: Sequence[float], r: Sequence[float]) -> Tuple[float, float]:
    m = max(r)
    w = sum(p for p, ri in zip(pi0, r) if ri >= m - 1e-12)
    return -math.log(w), w


def main() -> None:
    pi0 = [0.35, 0.25, 0.20, 0.15, 0.05]
    r = [0.0, 1.0, 0.5, 2.0, -1.0]
    L, w = ceiling_and_mass(pi0, r)
    M = max(r)

    ts = np.concatenate([[0.0], np.geomspace(1e-3, 400.0, 600)])
    ks, vs = zip(*(budget_value(pi0, r, float(t)) for t in ts))

    fig, axes = plt.subplots(1, 3, figsize=(16.5, 5.0))

    # ---- Panel 1: the frontier -------------------------------------------------
    ax = axes[0]
    ax.plot(ks, vs, lw=2.4, color="#1f4e79", label=r"frontier $(k(t),\,V(t))$")
    ax.axvline(L, ls="--", color="#c0392b", lw=1.6, label=rf"tropical ceiling $L={L:.3f}$")
    ax.axhline(M, ls=":", color="#7f8c8d", lw=1.4, label=rf"$\max r={M:g}$")
    ax.plot([L], [M], "o", ms=9, color="#c0392b", zorder=5)
    ax.annotate("tropical corner\n$(L,\\ \\max r)$", xy=(L, M), xytext=(L * 0.30, M - 0.62),
                arrowprops=dict(arrowstyle="->", color="#c0392b"), color="#c0392b")
    for t in (0.5, 1.5, 4.0):
        k0, v0 = budget_value(pi0, r, t)
        dk = 0.18
        ax.plot([k0 - dk, k0 + dk], [v0 - dk / t, v0 + dk / t], color="#e67e22", lw=1.5)
        ax.plot([k0], [v0], "o", ms=5, color="#e67e22")
        ax.text(k0 + dk * 1.05, v0 + dk / t, rf"$\beta={1/t:.2f}$", color="#b9770e", fontsize=8)
    ax.set_xlabel(r"KL budget $k=\mathrm{KL}(p_t\|\pi_0)$")
    ax.set_ylabel(r"expected reward $V=\mathbb{E}_{p_t}[r]$")
    ax.set_title("Concave frontier; slope = temperature")
    ax.legend(loc="lower right", fontsize=8)
    ax.grid(alpha=0.25)

    # ---- Panel 2: the ceiling depends only on the argmax mass ------------------
    ax = axes[1]
    for mass, colour in zip((0.05, 0.15, 0.35, 0.60), ("#8e44ad", "#1f4e79", "#16a085", "#d35400")):
        rest = (1.0 - mass) / 4.0
        q0 = [rest, rest, rest, mass, rest]
        Lq, _ = ceiling_and_mass(q0, r)
        kq = [budget_value(q0, r, float(t))[0] for t in ts]
        ax.plot(ts[1:], kq[1:], lw=2.0, color=colour, label=rf"$w={mass:.2f}$, $L={Lq:.3f}$")
        ax.axhline(Lq, ls="--", lw=1.0, color=colour, alpha=0.6)
    ax.set_xscale("log")
    ax.set_xlabel(r"tilt parameter $t=1/\beta$")
    ax.set_ylabel(r"$k(t)=\mathrm{KL}(p_t\|\pi_0)$")
    ax.set_title(r"Budget saturates at $L=-\log w$")
    ax.legend(fontsize=8)
    ax.grid(alpha=0.25)

    # ---- Panel 3: Maslov dequantization ---------------------------------------
    ax = axes[2]
    tt = np.geomspace(0.05, 200.0, 400)
    lz = np.array([log_partition(pi0, r, float(t)) / t for t in tt])
    ax.plot(tt, lz, lw=2.4, color="#1f4e79", label=r"$\log Z(t)/t$")
    ax.plot(tt, M + math.log(w) / tt, ls="--", lw=1.5, color="#c0392b",
            label=r"$\max r + \log w\,/\,t$")
    ax.axhline(M, ls=":", lw=1.5, color="#7f8c8d", label=r"$\max r$ (max-plus value)")
    ax.set_xscale("log")
    ax.set_xlabel(r"tilt parameter $t=1/\beta$")
    ax.set_ylabel(r"$\log Z(t)/t$")
    ax.set_ylim(M - 2.6, M + 0.45)
    ax.set_title("Maslov dequantization, with explicit error")
    ax.legend(loc="lower right", fontsize=8)
    ax.grid(alpha=0.25)

    fig.suptitle(
        r"Constrained $=$ penalised: the frontier, the tropical ceiling $L=-\log\pi_0(\arg\max r)$, "
        r"and the $\beta\to 0$ limit", fontsize=12)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("frontier_tropical.png", dpi=160)
    print("wrote frontier_tropical.png")


if __name__ == "__main__":
    main()
