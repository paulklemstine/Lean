"""
Numerical demonstrations for
"The Geometry of a Fading Dial: Decorrelation Certificates, Plateau
Identifiability, and Rapidity Pooling".

All routines are self-contained (standard library only) and use type hints.
Run with:  python3 demo.py

Sections
--------
1. The measured ladder, the band floor, and certified band loss.
2. Gram vs. advantage decorrelation certificates and the exact AM-GM gap.
3. Deceleration, the plateau localisation window, and exact identifiability.
4. Rapidity (Fisher-z) pooling: mean <= pool <= max, and the composition
   dichotomy (Einstein velocity addition).
5. Capacity of a family of weak dials.
"""

from __future__ import annotations

import math
from typing import Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Recorded data
# ----------------------------------------------------------------------------

BITLENS: Tuple[int, ...] = (96, 100, 104, 108, 112, 116, 120)
RHO: Tuple[float, ...] = (0.5739, 0.5436, 0.5005, 0.4880, 0.4621, 0.4847, 0.43636)
BAND_FLOOR: float = 0.55
CI_U108: Tuple[float, float] = (0.445, 0.534)
A_U108: float = 0.488          # corr(dial, rate)   at bit length 108
B_U108: float = 0.396          # corr(count, rate)  at bit length 108
ADV_U108: float = 0.092        # paired advantage
ADV_CI_U108: Tuple[float, float] = (0.043, 0.139)


# ----------------------------------------------------------------------------
# 1. The ladder
# ----------------------------------------------------------------------------

def ladder_steps(rho: Sequence[float]) -> List[float]:
    """Consecutive differences rho[i+1] - rho[i] of the measured ladder."""
    return [rho[i + 1] - rho[i] for i in range(len(rho) - 1)]


def band_history(rho: Sequence[float], floor: float) -> List[bool]:
    """True at rungs whose point estimate is at or above the band floor."""
    return [r >= floor for r in rho]


def ci_separated_below(ci: Tuple[float, float], floor: float) -> Tuple[bool, float]:
    """Is the whole confidence interval below the floor, and by what margin?"""
    return ci[1] < floor, floor - ci[1]


def is_antitone(rho: Sequence[float]) -> bool:
    """Is the raw ladder non-increasing?  (It is not: the 116 rung rebounds.)"""
    return all(rho[i + 1] <= rho[i] for i in range(len(rho) - 1))


def section_1() -> None:
    print("=" * 78)
    print("1.  THE MEASURED LADDER")
    print("=" * 78)
    steps = ladder_steps(RHO)
    print(f"{'bitlen':>8} {'rho':>10} {'step':>10}   in band?")
    for i, (b, r) in enumerate(zip(BITLENS, RHO)):
        s = "" if i == 0 else f"{steps[i-1]:+.4f}"
        flag = "yes" if r >= BAND_FLOOR else "no"
        print(f"{b:>8} {r:>10.5f} {s:>10}   {flag}")
    sep, margin = ci_separated_below(CI_U108, BAND_FLOOR)
    print(f"\nbit length 108 CI = {CI_U108}, floor = {BAND_FLOOR}")
    print(f"  entire CI below floor : {sep}   (margin {margin:.4f} >= 0.016)")
    print(f"  reading inside its CI : {CI_U108[0] <= RHO[3] <= CI_U108[1]}")
    print(f"\ndeceleration into 108:  |{steps[2]:.4f}| < |{steps[1]:.4f}|"
          f" and |{steps[2]:.4f}| < |{steps[0]:.4f}|"
          f"  -> {abs(steps[2]) < min(abs(steps[0]), abs(steps[1]))}")
    print(f"raw ladder antitone?    {is_antitone(RHO)}   "
          f"(116 rebounds: {RHO[5]:.4f} > {RHO[4]:.4f})")


# ----------------------------------------------------------------------------
# 2. Decorrelation certificates
# ----------------------------------------------------------------------------

def gram_bound(a: float, b: float) -> float:
    """Upper bound on corr(dial, baseline) from Gram positive semidefiniteness."""
    return a * b + math.sqrt((1.0 - a * a) * (1.0 - b * b))


def advantage_bound(a: float, b: float) -> float:
    """The AM-GM relaxed certificate 1 - (a-b)^2 / 2."""
    return 1.0 - (a - b) ** 2 / 2.0


def certificate_gap(a: float, b: float) -> float:
    """Exact gap: half the squared difference of the two residual lengths."""
    p = math.sqrt(1.0 - a * a)
    q = math.sqrt(1.0 - b * b)
    return (p - q) ** 2 / 2.0


def gram_determinant(a: float, b: float, c: float) -> float:
    """Scalar form of the 3x3 correlation-matrix determinant."""
    return 1.0 + 2.0 * a * b * c - a * a - b * b - c * c


def section_2() -> None:
    print()
    print("=" * 78)
    print("2.  DECORRELATION CERTIFICATES AND THE EXACT AM-GM GAP")
    print("=" * 78)
    a, b = A_U108, B_U108
    g, adv, gap = gram_bound(a, b), advantage_bound(a, b), certificate_gap(a, b)
    print(f"a = corr(dial,rate)     = {a}")
    print(f"b = corr(count,rate)    = {b}   (advantage delta = {a-b:.3f})")
    print(f"Gram certificate        c <= {g:.6f}")
    print(f"Advantage certificate   c <= {adv:.6f}")
    print(f"gap (identity)            = {gap:.8f}")
    print(f"gap (direct difference)   = {adv - g:.8f}")
    print(f"identity verified         : {abs((adv - g) - gap) < 1e-12}")
    print(f"published rounded bound 0.9949 dominates advantage bound: "
          f"{0.9949 < adv}")

    print("\nGap identity checked on a grid of (a, b):")
    worst = 0.0
    for ai in range(-9, 10):
        for bi in range(-9, 10):
            x, y = ai / 10.0, bi / 10.0
            worst = max(worst, abs(advantage_bound(x, y) - gram_bound(x, y)
                                   - certificate_gap(x, y)))
    print(f"  max |Adv - Gram - gap| over 361 pairs = {worst:.2e}")

    print("\nStrict domination fails only on the diagonal a^2 = b^2:")
    for x, y in [(0.488, 0.396), (0.5, 0.5), (0.5, -0.5), (0.7, 0.2)]:
        print(f"  a={x:+.3f} b={y:+.3f}   gap = {certificate_gap(x, y):.6f}"
              f"   strict = {certificate_gap(x, y) > 0}")

    print("\nSanity: the Gram bound is exactly where the determinant vanishes.")
    c_star = gram_bound(a, b)
    print(f"  det at c = Gram bound      = {gram_determinant(a, b, c_star):.2e}")
    print(f"  det at c = Gram bound+1e-3 = "
          f"{gram_determinant(a, b, c_star + 1e-3):.6f}  (negative => inadmissible)")

    print("\nLimit form: a persistent advantage delta >= 0.043 forces")
    print(f"  C <= 1 - 0.043^2/2 = {advantage_bound(0.043, 0.0):.7f}")


# ----------------------------------------------------------------------------
# 3. Plateau localisation and exact identifiability
# ----------------------------------------------------------------------------

def one_rung_window(s0: float, s1: float, r: float) -> Tuple[float, float]:
    """Localisation of the plateau from one rung: [s0 - d0/(1-r), s0]."""
    d0 = s0 - s1
    return s0 - d0 / (1.0 - r), s0


def exact_plateau_set(s0: float, s1: float, r: float) -> Tuple[float, float]:
    """Exactly attainable plateaus: [s0 - d0/(1-r), s0 - d0]."""
    d0 = s0 - s1
    return s0 - d0 / (1.0 - r), s0 - d0


def geometric_fade(s0: float, d0: float, r: float, n: int) -> float:
    """The extremal fade attaining the lower edge of the window."""
    tail = d0 / (1.0 - r)
    return (s0 - tail) + tail * (r ** n)


def section_3() -> None:
    print()
    print("=" * 78)
    print("3.  DECELERATION, PLATEAU WINDOW, EXACT IDENTIFIABILITY")
    print("=" * 78)
    s0, s1, r = RHO[3], RHO[4], 0.5
    d0 = s0 - s1
    lo_coarse, hi_coarse = one_rung_window(s0, s1, r)
    lo_exact, hi_exact = exact_plateau_set(s0, s1, r)
    print(f"s0 = {s0} (bitlen 108), s1 = {s1} (bitlen 112), d0 = {d0:.4f}, r <= {r}")
    print(f"one-rung localisation : [{lo_coarse:.4f}, {hi_coarse:.4f}]")
    print(f"exact attainable set  : [{lo_exact:.4f}, {hi_exact:.4f}]"
          f"   (length {hi_exact - lo_exact:.4f} = d0*r/(1-r))")
    print(f"whole window below floor by at least "
          f"{BAND_FLOOR - hi_coarse:.4f} >= 0.062")

    print("\nScoring the forecast against rungs measured afterwards:")
    for idx in (5, 6):
        val = RHO[idx]
        print(f"  bitlen {BITLENS[idx]}: rho = {val:.5f}"
              f"   in coarse window: {lo_coarse <= val <= hi_coarse}"
              f"   in exact window: {lo_exact <= val <= hi_exact}")
    print(f"  the 120 rung clears the lower edge by {RHO[6] - lo_coarse:.6f}")

    print("\nThe extremal geometric fade attaining the lower edge:")
    for n in (0, 1, 2, 3, 5, 10, 20, 40):
        print(f"  n={n:>2}   s_n = {geometric_fade(s0, d0, r, n):.8f}")
    print(f"  limit  = {s0 - d0/(1.0-r):.8f}")

    print("\nEvery interior point of the exact set is attained by some fade:")
    for L in (lo_exact, 0.4450, 0.4550, hi_exact):
        D = s0 - L
        q = 1.0 - d0 / D
        realised = s0 - d0 / (1.0 - q)
        print(f"  target L = {L:.4f}  ->  ratio q = {q:.4f} (<= {r}: "
              f"{q <= r + 1e-12}),  realised limit = {realised:.6f}")


# ----------------------------------------------------------------------------
# 4. Rapidity pooling
# ----------------------------------------------------------------------------

def fisher_add(x: float, y: float) -> float:
    """Einstein / Fisher composition (x + y) / (1 + x y)."""
    return (x + y) / (1.0 + x * y)


def fisher_pool(seeds: Sequence[float]) -> float:
    """Fisher-z pooled correlation: tanh of the mean rapidity."""
    return math.tanh(sum(math.atanh(s) for s in seeds) / len(seeds))


def pooling_report(seeds: Sequence[float]) -> Dict[str, float]:
    """Arithmetic mean, Fisher pool, maximum, and the inflation."""
    mean = sum(seeds) / len(seeds)
    pool = fisher_pool(seeds)
    return {"mean": mean, "pool": pool, "max": max(seeds),
            "inflation": pool - mean}


def section_4() -> None:
    print()
    print("=" * 78)
    print("4.  RAPIDITY POOLING: mean <= pool <= max")
    print("=" * 78)
    print("Fisher-z addition IS Einstein velocity composition:")
    for x, y in [(0.3, 0.4), (0.488, 0.396), (0.9, 0.9)]:
        lhs = math.tanh(math.atanh(x) + math.atanh(y))
        rhs = fisher_add(x, y)
        print(f"  x={x}, y={y}:  tanh(atanh x + atanh y) = {lhs:.10f},"
              f"  (x+y)/(1+xy) = {rhs:.10f},  equal: {abs(lhs-rhs) < 1e-12}")
    print("  no superluminal pooling: composition of admissible values stays"
          " in (-1,1).")

    print("\nHeterogeneous seed sets (all below the 0.55 floor):")
    seed_sets: List[Tuple[float, ...]] = [
        (0.488, 0.488, 0.488),
        (0.470, 0.488, 0.506),
        (0.380, 0.488, 0.548),
        (0.100, 0.500, 0.549),
    ]
    print(f"{'seeds':>26} {'mean':>10} {'pool':>10} {'max':>8} {'inflation':>11}"
          "  pool<floor")
    for seeds in seed_sets:
        rep = pooling_report(seeds)
        label = "(" + ", ".join(f"{s:.3f}" for s in seeds) + ")"
        print(f"{label:>26} {rep['mean']:>10.6f} {rep['pool']:>10.6f}"
              f" {rep['max']:>8.3f} {rep['inflation']:>11.2e}"
              f"   {rep['pool'] < BAND_FLOOR}")
    print("  inflation is 0 exactly for homogeneous seeds and > 0 otherwise;")
    print("  the pool never exceeds the largest seed, so a sub-floor set of"
          " seeds\n  can never pool back into the band.")

    print("\nThe dichotomy: averaging preserves the floor, composition does not.")
    print(f"  pool(0.4, 0.4)    = {fisher_pool((0.4, 0.4)):.6f}  < 0.55")
    print(f"  0.4 (+) 0.4       = {fisher_add(0.4, 0.4):.6f}  > 0.55")


# ----------------------------------------------------------------------------
# 5. Capacity of a weak-dial family
# ----------------------------------------------------------------------------

def dial_capacity(rho: float, c: float) -> float:
    """(1 - c) / (rho^2 - c) when c < rho^2; math.inf (vacuous) otherwise."""
    if c >= rho * rho:
        return math.inf
    return (1.0 - c) / (rho * rho - c)


def section_5() -> None:
    print()
    print("=" * 78)
    print("5.  CAPACITY OF A FAMILY OF WEAK DIALS")
    print("=" * 78)
    print(f"{'rho':>8} {'c':>8} {'(1-c)/(rho^2-c)':>18} {'max dials':>11}")
    for rho, c in [(0.55, 0.10), (0.55, 0.00), (0.55, 0.20), (0.60, 0.10),
                   (0.488, 0.10), (0.488, 0.9949)]:
        cap = dial_capacity(rho, c)
        cap_s = "vacuous" if math.isinf(cap) else f"{cap:.4f}"
        k_s = "unbounded" if math.isinf(cap) else str(int(math.floor(cap)))
        print(f"{rho:>8.3f} {c:>8.4f} {cap_s:>18} {k_s:>11}")
    print("\nAt the band floor with genuinely weak pairwise alignment (c <= 0.1)")
    print("an ensemble is capped at four dials; at the measured configuration")
    print("the certified pairwise bound (c <= 0.9949) exceeds rho^2 and the")
    print("capacity bound is vacuous.")

    print("\nEmpirical check of the packing bound (deterministic construction):")
    print("  k unit vectors at angle arccos(rho) from the rate, spread"
          " symmetrically,")
    print("  have pairwise inner product rho^2 + (1-rho^2)*cos(2*pi*j/k):")
    rho = 0.55
    for k in range(2, 8):
        # symmetric "cone" configuration: pairwise inner products are
        # rho^2 + (1 - rho^2) * cos(2*pi*j/k) for j = 1..k-1
        worst = max(rho * rho + (1 - rho * rho) * math.cos(2 * math.pi * j / k)
                    for j in range(1, k))
        cap = dial_capacity(rho, worst)
        ok = "" if math.isinf(cap) else f"bound allows k <= {math.floor(cap):.0f}"
        print(f"    k={k}: max pairwise = {worst:+.4f}   "
              f"{'vacuous (c >= rho^2)' if math.isinf(cap) else ok}"
              f"   consistent: {math.isinf(cap) or k <= cap + 1e-9}")


def main() -> None:
    section_1()
    section_2()
    section_3()
    section_4()
    section_5()
    print()
    print("=" * 78)
    print("All numerical checks completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
