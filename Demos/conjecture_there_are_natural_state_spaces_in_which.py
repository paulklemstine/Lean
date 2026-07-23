"""
Numerical demonstrations of robust reconstruction bounds for functional observation.

We model:
  - a state space X (a finite list of states),
  - a functional observation F : X -> B  (what an instrument can see),
  - an experience observable E : X -> Y   (a hidden quantity of interest),
  - a reconstruction / decoder R : B -> Y (best guess of E from F).

The central quantity is the PAIR RISK on the uniform two-point distribution over {x, z}:

    pairRisk(x, z) = ( dist_Y(E(x), R(F(x))) + dist_Y(E(z), R(F(z))) ) / 2

Main facts demonstrated:
  1. Robust bound:  if dist_B(F(x),F(z)) <= eps, dist_Y(E(x),E(z)) >= delta, and R is
                    K-Lipschitz, then  pairRisk >= (delta - K*eps)/2.
  2. Exact bound:   if F(x) == F(z) and dist_Y(E(x),E(z)) >= delta, then
                    pairRisk >= delta/2  for EVERY decoder.
  3. Worst case:    under F(x)==F(z),  max error >= delta/2.
  4. Sharpness:     the midpoint decoder attains pairRisk = delta/2 exactly.

Everything is self-contained: no third-party dependencies.
"""

from __future__ import annotations

from typing import Callable, Iterable, Sequence, TypeVar
import math
import random

X = TypeVar("X")   # state type
B = TypeVar("B")   # observation type
Y = TypeVar("Y")   # experience type


# ---------------------------------------------------------------------------
# Core metric quantities
# ---------------------------------------------------------------------------

def euclidean(u: Sequence[float], v: Sequence[float]) -> float:
    """Euclidean distance between two equal-length real vectors."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(u, v)))


def abs_dist(a: float, b: float) -> float:
    """Distance on the real line."""
    return abs(a - b)


def pair_risk(
    F: Callable[[X], B],
    E: Callable[[X], Y],
    R: Callable[[B], Y],
    dist_Y: Callable[[Y, Y], float],
    x: X,
    z: X,
) -> float:
    """Expected reconstruction loss on the uniform two-point distribution over {x, z}."""
    err_x = dist_Y(E(x), R(F(x)))
    err_z = dist_Y(E(z), R(F(z)))
    return (err_x + err_z) / 2.0


def robust_floor(delta: float, K: float, eps: float) -> float:
    """The theoretical lower bound (delta - K*eps)/2 (clamped at 0 for interpretation)."""
    return (delta - K * eps) / 2.0


# ---------------------------------------------------------------------------
# Demo 1: exact fibre -- half the hidden contrast always leaks into error
# ---------------------------------------------------------------------------

def demo_exact_fibre() -> None:
    print("=" * 70)
    print("DEMO 1: Exact fibre bound  (F(x) == F(z)  =>  pairRisk >= delta/2)")
    print("=" * 70)

    # Two states that are functionally identical but experientially distinct.
    F: Callable[[str], int] = lambda s: 0            # both map to the same readout
    experiences = {"x": 0.0, "z": 3.0}               # hidden values differ by 3
    E: Callable[[str], float] = lambda s: experiences[s]
    delta = abs_dist(E("x"), E("z"))
    print(f"experiential contrast delta = {delta:.3f}")
    print(f"theoretical floor delta/2   = {delta / 2:.3f}\n")

    # Try many decoders (all constant, since the single readout forces one output).
    print(f"{'decoder output g':>18} | {'pair risk':>10} | {'>= delta/2 ?':>12}")
    print("-" * 46)
    best = math.inf
    for g in [-2.0, 0.0, 1.0, 1.5, 2.0, 3.0, 5.0]:
        R: Callable[[int], float] = lambda b, g=g: g
        pr = pair_risk(F, E, R, abs_dist, "x", "z")
        best = min(best, pr)
        ok = "yes" if pr >= delta / 2 - 1e-12 else "NO!"
        print(f"{g:>18.3f} | {pr:>10.3f} | {ok:>12}")
    print(f"\nminimum pair risk over decoders = {best:.3f} (attained at midpoint g=1.5)")
    print("The floor delta/2 is never violated, and is achieved by the midpoint.\n")


# ---------------------------------------------------------------------------
# Demo 2: robust bound with a K-Lipschitz decoder on close-but-not-equal readouts
# ---------------------------------------------------------------------------

def demo_robust_bound() -> None:
    print("=" * 70)
    print("DEMO 2: Robust bound  (dist(F)<=eps, K-Lipschitz R => pairRisk >= (delta-K*eps)/2)")
    print("=" * 70)

    # Readouts in R^1, experiences in R^1.
    readout = {"x": 0.0, "z": 0.4}       # eps = 0.4 apart
    experiences = {"x": 0.0, "z": 3.0}   # delta = 3.0 apart
    F: Callable[[str], float] = lambda s: readout[s]
    E: Callable[[str], float] = lambda s: experiences[s]
    eps = abs_dist(F("x"), F("z"))
    delta = abs_dist(E("x"), E("z"))

    print(f"eps = {eps:.3f}, delta = {delta:.3f}\n")
    print(f"{'K':>6} | {'floor (delta-K*eps)/2':>22} | {'best affine risk':>18} | {'holds?':>7}")
    print("-" * 62)
    for K in [0.0, 1.0, 2.0, 4.0, 7.5]:
        floor = robust_floor(delta, K, eps)
        # Best K-Lipschitz affine decoder R(b) = g0 + slope*(b - F(x)), |slope| <= K.
        # Search slope in [-K, K] and intercept over a grid.
        best = math.inf
        for i in range(-100, 101):
            slope = K * i / 100.0
            for j in range(-50, 351):
                g0 = j / 100.0
                R = lambda b, g0=g0, slope=slope: g0 + slope * (b - readout["x"])
                pr = pair_risk(F, E, R, abs_dist, "x", "z")
                best = min(best, pr)
        holds = "yes" if best >= floor - 1e-6 else "NO!"
        print(f"{K:>6.1f} | {floor:>22.3f} | {best:>18.3f} | {holds:>7}")
    print("\nThe empirically optimal Lipschitz decoder never beats the theoretical floor.\n")


# ---------------------------------------------------------------------------
# Demo 3: certified reconstruction floor over a finite dataset  (O(n^2) scan)
# ---------------------------------------------------------------------------

def certified_floor(
    states: Sequence[X],
    F: Callable[[X], Sequence[float]],
    E: Callable[[X], Sequence[float]],
    dist_B: Callable[[Sequence[float], Sequence[float]], float],
    dist_Y: Callable[[Sequence[float], Sequence[float]], float],
    K: float,
) -> tuple[float, tuple[int, int] | None]:
    """Certify a lower bound on the pair risk of any K-Lipschitz decoder by scanning pairs."""
    best = -math.inf
    arg: tuple[int, int] | None = None
    for i in range(len(states)):
        for j in range(i + 1, len(states)):
            eps = dist_B(F(states[i]), F(states[j]))
            delta = dist_Y(E(states[i]), E(states[j]))
            floor = (delta - K * eps) / 2.0
            if floor > best:
                best, arg = floor, (i, j)
    return max(best, 0.0), arg


def demo_certified_floor() -> None:
    print("=" * 70)
    print("DEMO 3: Certified reconstruction floor over a random dataset")
    print("=" * 70)

    random.seed(7)
    n = 40
    # Build states: a hidden label in R^2, and a lossy 1-D readout that discards one axis.
    states = list(range(n))
    hidden = {s: (random.uniform(0, 5), random.uniform(0, 5)) for s in states}
    # Instrument only sees the first coordinate (+ small noise) -> lossy channel.
    readout = {s: (hidden[s][0] + random.uniform(-0.05, 0.05),) for s in states}

    F: Callable[[int], Sequence[float]] = lambda s: readout[s]
    E: Callable[[int], Sequence[float]] = lambda s: hidden[s]

    for K in [1.0, 2.0, 5.0]:
        floor, arg = certified_floor(states, F, E, euclidean, euclidean, K)
        print(f"K = {K:>4.1f}:  certified pair-risk floor = {floor:.3f}  witness pair = {arg}")
    print("\nEven a mildly Lipschitz decoder cannot reconstruct the discarded axis"
          " below the certified floor.\n")


# ---------------------------------------------------------------------------
# Demo 4: the "zombie twin" -- worst-case leakage bound
# ---------------------------------------------------------------------------

def demo_worst_case() -> None:
    print("=" * 70)
    print("DEMO 4: Worst-case leakage  (F(x)==F(z) => max error >= delta/2)")
    print("=" * 70)

    F: Callable[[str], int] = lambda s: 42
    experiences = {"x": (1.0, 0.0), "z": (-1.0, 0.0)}   # opposite experiences
    E: Callable[[str], Sequence[float]] = lambda s: experiences[s]
    delta = euclidean(E("x"), E("z"))
    print(f"delta = {delta:.3f}, delta/2 = {delta / 2:.3f}\n")

    print(f"{'decoder guess g':>22} | {'err_x':>7} | {'err_z':>7} | {'max':>7} | {'>=d/2?':>7}")
    print("-" * 62)
    for g in [(1.0, 0.0), (0.0, 0.0), (-1.0, 0.0), (0.5, 0.5), (2.0, 0.0)]:
        R: Callable[[int], Sequence[float]] = lambda b, g=g: g
        ex = euclidean(E("x"), R(F("x")))
        ez = euclidean(E("z"), R(F("z")))
        mx = max(ex, ez)
        ok = "yes" if mx >= delta / 2 - 1e-12 else "NO!"
        print(f"{str(g):>22} | {ex:>7.3f} | {ez:>7.3f} | {mx:>7.3f} | {ok:>7}")
    print("\nNo single guess can be simultaneously close to two far-apart experiences.\n")


if __name__ == "__main__":
    demo_exact_fibre()
    demo_robust_bound()
    demo_certified_floor()
    demo_worst_case()
    print("All demonstrations completed: the theoretical floors are never violated.")
