"""
The Half-Amplitude Floor: numerical demonstrations.
===================================================

Self-contained numerical companion to the paper
"The Half-Amplitude Floor: Sharp Limits of Block-Balanced Estimation for
Rebound Ladders".

Setting.  A fading ladder of readings rho_k = L + s_k approaches an unknown
floor L.  The residuals are *bounded*, |s_k| <= eta, and their signs alternate
block by block: block i (of length n_i) carries residuals of sign (-1)^i (with
zero allowed on either side).  The block-balanced estimator gives each rung of
block i the weight 1/n_i, so each of the m blocks carries total weight 1, and
returns the mean of the m block means.

What is demonstrated:

  1. The sharp block-balanced law  |error| <= eta * ceil(m/2) / m, attained by
     the extremal ladder (positive blocks saturate, negative blocks vanish).
  2. The refutation of the conjectured 2*eta/m rate, from m = 5 onwards.
  3. No decay: the worst case never drops below eta/2.
  4. The salvage: exact-amplitude residuals give |error| <= eta/m.
  5. No nonnegative weighting of the blocks beats eta/2 (random search).
  6. The information-theoretic collision: one ladder, two floors eta apart.
  7. The midrange attains the eta/2 barrier -- and every averaging estimator
     tested does not.
  8. The recorded dial: eta = 0.0226 forces a floor resolution of +/- 0.0113.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------


def ceil_half(m: int) -> int:
    """ceil(m/2), the number of even indices among 0, 1, ..., m-1."""
    return (m + 1) // 2


def block_balanced_bound(eta: float, m: int) -> float:
    """The sharp worst-case error eta * ceil(m/2) / m of the block-balanced
    estimator for residuals merely bounded by eta in m alternating blocks."""
    if m <= 0:
        raise ValueError("m must be positive")
    return eta * ceil_half(m) / m


def conjectured_bound(eta: float, m: int) -> float:
    """The (false) conjectured rate 2*eta/m."""
    return 2.0 * eta / m


def block_sums(blocks: Sequence[Sequence[float]]) -> List[float]:
    """Sum of the residuals inside each block."""
    return [float(sum(b)) for b in blocks]


def block_means(blocks: Sequence[Sequence[float]]) -> List[float]:
    """Mean of the residuals inside each block (the block-balanced summary)."""
    return [float(sum(b)) / len(b) for b in blocks]


def block_balanced_error(blocks: Sequence[Sequence[float]]) -> float:
    """Error of the block-balanced estimator: the mean of the block means."""
    means = block_means(blocks)
    return sum(means) / len(means)


def weighted_block_error(blocks: Sequence[Sequence[float]],
                         weights: Sequence[float]) -> float:
    """Error of a general weighted estimator sum_i w_i * (block mean of i)."""
    means = block_means(blocks)
    return sum(w * mu for w, mu in zip(weights, means))


def plain_mean_error(blocks: Sequence[Sequence[float]]) -> float:
    """Error of the unweighted mean of all rungs (the estimator that block
    balancing was designed to repair)."""
    flat = [x for b in blocks for x in b]
    return sum(flat) / len(flat)


def extremal_ladder_positive(eta: float, m: int,
                             lengths: Sequence[int] | None = None
                             ) -> List[List[float]]:
    """Positive blocks saturate at +eta, negative blocks are silenced (0).
    Admissible: every entry has modulus <= eta and lies weakly on the side
    prescribed by the parity of its block index."""
    lens = list(lengths) if lengths is not None else [1] * m
    return [[eta if i % 2 == 0 else 0.0] * lens[i] for i in range(m)]


def extremal_ladder_negative(eta: float, m: int,
                             lengths: Sequence[int] | None = None
                             ) -> List[List[float]]:
    """The mirror image: negative blocks saturate at -eta, positive vanish."""
    lens = list(lengths) if lengths is not None else [1] * m
    return [[0.0 if i % 2 == 0 else -eta] * lens[i] for i in range(m)]


def saturated_ladder(eta: float, m: int,
                     lengths: Sequence[int] | None = None) -> List[List[float]]:
    """Exact amplitude: every residual equals (-1)^i * eta."""
    lens = list(lengths) if lengths is not None else [1] * m
    return [[(-1.0) ** i * eta] * lens[i] for i in range(m)]


def colliding_observation(floor: float, eta: float, n: int) -> List[float]:
    """The ladder x_k = floor + eta (k even), floor (k odd).  It is an exact
    realisation of the floor `floor` with saturating positive blocks AND of the
    floor `floor + eta` with saturating negative blocks."""
    return [floor + eta if k % 2 == 0 else floor for k in range(n)]


def midrange(x: Sequence[float]) -> float:
    """The minimax-optimal floor estimator: half the sum of the extremes."""
    return 0.5 * (max(x) + min(x))


# ----------------------------------------------------------------------------
# Demonstration 1: the sharp law, and the death of the 2*eta/m conjecture
# ----------------------------------------------------------------------------


def demo_sharp_law(eta: float = 1.0) -> None:
    print("=" * 78)
    print("1. THE SHARP BLOCK-BALANCED LAW AND THE FALSE CONJECTURE (eta = %g)"
          % eta)
    print("=" * 78)
    print(f"{'m':>4} {'attained error':>16} {'bound eta*ceil(m/2)/m':>24}"
          f" {'conjectured 2eta/m':>20}  verdict")
    for m in [1, 2, 3, 4, 5, 6, 7, 10, 20, 50, 101, 1000]:
        blocks = extremal_ladder_positive(eta, m)
        attained = block_balanced_error(blocks)
        bound = block_balanced_bound(eta, m)
        conj = conjectured_bound(eta, m)
        assert abs(attained - bound) < 1e-12, "bound must be attained exactly"
        verdict = "CONJECTURE FALSE" if attained > conj + 1e-15 else "holds"
        print(f"{m:>4} {attained:>16.6f} {bound:>24.6f} {conj:>20.6f}  {verdict}")
    print()
    print("The attained value equals the bound in every row: the law is sharp.")
    print("It never drops below eta/2 = %.6f, so there is no decay at all."
          % (eta / 2))
    print()


# ----------------------------------------------------------------------------
# Demonstration 2: block lengths are irrelevant; the salvage under saturation
# ----------------------------------------------------------------------------


def demo_lengths_and_salvage(eta: float = 1.0, m: int = 9) -> None:
    print("=" * 78)
    print("2. BLOCK LENGTHS DROP OUT; EXACT AMPLITUDE RESTORES THE DECAY")
    print("=" * 78)
    rng = random.Random(20261210)
    print("Random block-length profiles, m = %d blocks, eta = %g:" % (m, eta))
    print(f"{'lengths':>34} {'bounded worst case':>20} {'saturated':>12}"
          f" {'plain mean':>12}")
    for _ in range(5):
        lengths = [rng.randint(1, 12) for _ in range(m)]
        bounded = extremal_ladder_positive(eta, m, lengths)
        exact = saturated_ladder(eta, m, lengths)
        print(f"{str(lengths):>34} {block_balanced_error(bounded):>20.6f}"
              f" {block_balanced_error(exact):>12.6f}"
              f" {plain_mean_error(bounded):>12.6f}")
    print()
    print("Bounded column is constant = eta*ceil(m/2)/m = %.6f regardless of"
          % block_balanced_bound(eta, m))
    print("the lengths, exactly as the law predicts; the saturated column obeys")
    print("the eta/m = %.6f decay; the plain mean varies wildly with the"
          % (eta / m))
    print("length profile -- which is precisely what block balancing repairs.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 3: no nonnegative weighting beats eta/2
# ----------------------------------------------------------------------------


def demo_no_weighting_beats_half(eta: float = 1.0, m: int = 12,
                                 trials: int = 20000) -> None:
    print("=" * 78)
    print("3. NO NONNEGATIVE WEIGHTING OF THE BLOCKS BEATS eta/2")
    print("=" * 78)
    rng = random.Random(20261211)
    pos = extremal_ladder_positive(eta, m)
    neg = extremal_ladder_negative(eta, m)

    named: List[Tuple[str, List[float]]] = [
        ("uniform (block balanced)", [1.0 / m] * m),
        ("front loaded", [(m - i) for i in range(m)]),
        ("back loaded (recency)", [(i + 1) for i in range(m)]),
        ("geometric discount 0.6", [0.6 ** i for i in range(m)]),
        ("last block only", [1.0 if i == m - 1 else 0.0 for i in range(m)]),
        ("first and last", [0.5 if i in (0, m - 1) else 0.0 for i in range(m)]),
    ]
    print(f"{'weighting scheme':>26} {'error on P':>12} {'error on N':>12}"
          f" {'worst':>10}")
    best = math.inf
    for name, w in named:
        total = sum(w)
        w = [wi / total for wi in w]
        ep = abs(weighted_block_error(pos, w))
        en = abs(weighted_block_error(neg, w))
        worst = max(ep, en)
        best = min(best, worst)
        print(f"{name:>26} {ep:>12.6f} {en:>12.6f} {worst:>10.6f}")

    for _ in range(trials):
        w = [rng.random() for _ in range(m)]
        total = sum(w)
        w = [wi / total for wi in w]
        worst = max(abs(weighted_block_error(pos, w)),
                    abs(weighted_block_error(neg, w)))
        best = min(best, worst)
    print()
    print("Best worst-case over the named schemes and %d random weightings: %.6f"
          % (trials, best))
    print("Theoretical barrier eta/2 = %.6f -- never breached." % (eta / 2))
    assert best >= eta / 2 - 1e-12
    print()


# ----------------------------------------------------------------------------
# Demonstration 4: the collision, and the optimality of the midrange
# ----------------------------------------------------------------------------


def demo_collision_and_midrange(eta: float = 1.0, floor: float = 0.47,
                                n: int = 13) -> None:
    print("=" * 78)
    print("4. THE COLLISION: ONE LADDER, TWO FLOORS eta APART")
    print("=" * 78)
    x = colliding_observation(floor, eta, n)
    print("readings:", " ".join("%.3f" % v for v in x))
    print()
    print("Reading 1: floor L = %.4f, residuals" % floor,
          " ".join("%+.3f" % (v - floor) for v in x[:6]), "...  (bounded, alternating)")
    print("Reading 2: floor L' = %.4f, residuals" % (floor + eta),
          " ".join("%+.3f" % (v - floor - eta) for v in x[:6]),
          "...  (bounded, alternating)")
    print()

    estimators: List[Tuple[str, Callable[[Sequence[float]], float]]] = [
        ("plain mean", lambda v: sum(v) / len(v)),
        ("median", lambda v: sorted(v)[len(v) // 2]),
        ("midrange (max+min)/2", midrange),
        ("last reading", lambda v: v[-1]),
        ("min reading", lambda v: min(v)),
        ("trimmed mean 20%", lambda v: (lambda s: sum(s[len(s)//5:len(s)-len(s)//5])
                                        / len(s[len(s)//5:len(s)-len(s)//5]))(sorted(v))),
    ]
    print(f"{'estimator':>24} {'output':>10} {'|err vs L|':>12}"
          f" {'|err vs L+eta|':>16} {'worst':>10}")
    for name, est in estimators:
        y = est(x)
        e1 = abs(y - floor)
        e2 = abs(y - (floor + eta))
        print(f"{name:>24} {y:>10.4f} {e1:>12.4f} {e2:>16.4f} {max(e1, e2):>10.4f}")
        assert max(e1, e2) >= eta / 2 - 1e-12, "barrier violated -- impossible"
    print()
    print("Every estimator errs by at least eta/2 = %.4f on one of the two"
          % (eta / 2))
    print("worlds -- and the midrange errs by exactly that, hence is optimal.")
    print()


def demo_midrange_uniform_optimality(eta: float = 1.0, floor: float = 0.47,
                                     trials: int = 20000, n: int = 15) -> None:
    print("=" * 78)
    print("5. THE MIDRANGE IS WITHIN eta/2 ON EVERY ADMISSIBLE LADDER")
    print("=" * 78)
    rng = random.Random(20261212)
    worst_mid = 0.0
    worst_mean = 0.0
    # Random admissible ladders, plus the two adversarial extremal ones.
    families: List[List[float]] = [
        [((-1.0) ** k) * rng.uniform(0.0, eta) for k in range(n)]
        for _ in range(trials)
    ]
    families.append([eta if k % 2 == 0 else 0.0 for k in range(n)])
    families.append([0.0 if k % 2 == 0 else -eta for k in range(n)])
    for s in families:
        x = [floor + sk for sk in s]
        worst_mid = max(worst_mid, abs(midrange(x) - floor))
        worst_mean = max(worst_mean, abs(sum(x) / len(x) - floor))
    print("random admissible ladders: %d (plus 2 adversarial), window %d rungs"
          % (trials, n))
    print("worst midrange error   : %.6f   (barrier eta/2 = %.6f)"
          % (worst_mid, eta / 2))
    print("worst plain-mean error : %.6f" % worst_mean)
    assert worst_mid <= eta / 2 + 1e-12
    print()


# ----------------------------------------------------------------------------
# Demonstration 5: the recorded dial
# ----------------------------------------------------------------------------


def demo_recorded_dial() -> None:
    print("=" * 78)
    print("6. THE RECORDED DIAL: A REBOUND OF +0.0226 CAPS RESOLUTION AT 0.0113")
    print("=" * 78)
    ladder = [0.5739, 0.5436, 0.5005, 0.4880, 0.4621, 0.4847]
    steps = [b - a for a, b in zip(ladder, ladder[1:])]
    print("ladder :", " ".join("%.4f" % v for v in ladder))
    print("steps  :", " ".join("%+.4f" % v for v in steps))
    positive = [d for d in steps if d > 0]
    print()
    print("Positive steps: %s -> a multiplicative fade rho_{k+1} <= q rho_k with"
          % ", ".join("%+.4f" % d for d in positive))
    print("q <= 1 and rho_k >= 0 admits NO positive step, so that story is out.")
    eta = max(positive)
    print()
    print("A positive step of size delta in a non-expanding affine floor model")
    print("above its floor forces eta >= delta, so eta >= %.4f." % eta)
    print()
    print(f"{'blocks m':>10} {'worst-case block-balanced error':>34}")
    for m in [1, 2, 5, 10, 100, 10000]:
        print(f"{m:>10} {block_balanced_bound(eta, m):>34.6f}")
    print()
    print("floor resolution (combinatorial route) : +/- %.4f" % (eta / 2))
    lam = -226.0 / 259.0
    print("fitted contraction ratio lambda        : %.6f  (oscillatory branch)"
          % lam)
    print("floor resolution (analytic route, |lambda| <= 1): +/- %.4f"
          % (eta / 2))
    print()
    # Two point estimates of the floor.
    a, b, c = ladder[3], ladder[4], ladder[5]
    aitken = a - (b - a) ** 2 / (c - 2 * b + a)
    three_rung = (a + b + c) / 3
    print("three-point extrapolation floor estimate : %.6f" % aitken)
    print("plain mean of the last three rungs       : %.6f" % three_rung)
    print("they agree to within                     : %.6f"
          % abs(aitken - three_rung))
    print("pre-registered window [0.46, 0.49], width 0.030; theoretical")
    print("minimum honest width 2 * eta/2 = %.4f -- pre-registration was" % eta)
    print("conservative, not over-precise.")
    print()
    midr = midrange(ladder[3:])
    print("midrange of the last three rungs         : %.6f  (bar +/- %.4f)"
          % (midr, eta / 2))
    print()


def main() -> None:
    demo_sharp_law()
    demo_lengths_and_salvage()
    demo_no_weighting_beats_half()
    demo_collision_and_midrange()
    demo_midrange_uniform_optimality()
    demo_recorded_dial()
    print("All assertions passed: every numerical check agrees with the theory.")


if __name__ == "__main__":
    main()
