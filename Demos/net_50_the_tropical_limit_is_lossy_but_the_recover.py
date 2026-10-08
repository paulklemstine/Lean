#!/usr/bin/env python3
"""
The tropical limit of attention is lossy, but the recovery is fast.

Numerical companion to the paper.  Pure Python standard library only.

Sections
  1. Gap = min-entropy: p_i = exp(-g_i).
  2. The Renyi crystallization sandwich 1 - e^{-g} <= sum p(1-p) <= 1 - e^{-2g}.
  3. Why the "crystallization <= 1/4" prediction failed.
  4. The log-domain truncation identity LSE - LSE_S = -log M(S).
  5. Key-count floors tau*e^g and tau^2/sum p^2, and the two calibrations (13 and 33 keys).
  6. The margin truncation bound (n-k) e^{-m} / k.
  7. The argmax floor 1/(1+(n-1)e^{-m}) decays with context.
  8. The measured recovery curve breaks the doubling inequality R(2k) <= 2 R(k).
  9. Weierstrass bounds for a layer-compounded readout.
 10. A synthetic "tropical core + soft tail" row and its top-k recovery curve.
"""
from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple

Row = List[float]


# ---------------------------------------------------------------- primitives
def lse(x: Sequence[float]) -> float:
    """Numerically stable log-sum-exp."""
    mu = max(x)
    return mu + math.log(sum(math.exp(v - mu) for v in x))


def softmax(x: Sequence[float]) -> Row:
    z = lse(x)
    return [math.exp(v - z) for v in x]


def maslov_gap(x: Sequence[float], i: int | None = None) -> float:
    """LSE(x) - x_i; at the argmax by default."""
    xi = max(x) if i is None else x[i]
    return lse(x) - xi


def collision(p: Sequence[float]) -> float:
    return sum(q * q for q in p)


def crystallization(p: Sequence[float]) -> float:
    return sum(q * (1.0 - q) for q in p)


def kept_mass(p: Sequence[float], S: Sequence[int]) -> float:
    return sum(p[j] for j in S)


def topk_indices(x: Sequence[float], k: int) -> List[int]:
    return sorted(range(len(x)), key=lambda j: -x[j])[:k]


def argmax_floor(m: float, n: int) -> float:
    return 1.0 / (1.0 + (n - 1) * math.exp(-m))


def random_row(n: int, scale: float, rng: random.Random) -> Row:
    return [rng.gauss(0.0, scale) for _ in range(n)]


def core_tail_row(n: int, core: int, margin: float, tail_sd: float,
                  rng: random.Random) -> Row:
    """`core` dominant keys, then a long tail `margin` nats lower."""
    row = [rng.gauss(0.0, 0.3) for _ in range(core)]
    row += [-margin + rng.gauss(0.0, tail_sd) for _ in range(n - core)]
    return row


def header(title: str) -> None:
    print("\n" + "=" * 78 + "\n" + title + "\n" + "=" * 78)


# ---------------------------------------------------------------- sections
def section_gap_is_min_entropy(rng: random.Random) -> None:
    header("1. Gap = min-entropy:  p_i = exp(-(LSE - x_i))")
    x = random_row(10, 1.5, rng)
    p = softmax(x)
    worst = max(abs(p[i] - math.exp(-maslov_gap(x, i))) for i in range(len(x)))
    g = maslov_gap(x)
    print(f"max |p_i - e^(-g_i)| over a random row : {worst:.2e}")
    print(f"argmax gap g = {g:.4f} nats  ->  argmax cache keeps e^(-g) = {math.exp(-g):.4f}"
          f"  (= max p = {max(p):.4f})")
    for g_med in (0.17, 1.46, 1.86, 2.33, 2.69):
        print(f"  median gap {g_med:4.2f} nats -> median argmax mass {math.exp(-g_med):.3f}")


def section_sandwich(rng: random.Random) -> None:
    header("2. Renyi sandwich  1 - e^{-g} <= K <= 1 - e^{-2g}")
    violations = 0
    trials = 20000
    for _ in range(trials):
        n = rng.randint(1, 64)
        x = random_row(n, rng.uniform(0.0, 5.0), rng)
        p = softmax(x)
        g = maslov_gap(x)
        K = crystallization(p)
        if not (1 - math.exp(-g) - 1e-12 <= K <= 1 - math.exp(-2 * g) + 1e-12):
            violations += 1
    print(f"random rows tested: {trials}, sandwich violations: {violations}")
    for n in (4, 8, 512):
        x = [0.0] * n
        p = softmax(x)
        g = maslov_gap(x)
        print(f"flat row n={n:4d}: g = log n = {g:.4f}, K = {crystallization(p):.6f}, "
              f"lower bound 1-e^-g = {1 - math.exp(-g):.6f}  (sharp)")


def section_p3() -> None:
    header("3. Why the prediction 'crystallization <= 1/4' failed")
    thr = math.log(4 / 3)
    print(f"K <= 1/4 forces g <= log(4/3) = {thr:.4f} nats; g > 1/3 forces K > 1/4")
    for g in (0.17, 0.5, 1.0, 1.46, 1.86, 2.69):
        print(f"  gap {g:4.2f}:  K in [{1 - math.exp(-g):.3f}, {1 - math.exp(-2 * g):.3f}]")


def section_truncation(rng: random.Random) -> None:
    header("4. Truncation identity  LSE(x) - LSE_S(x) = -log M(S)")
    x = random_row(50, 2.0, rng)
    p = softmax(x)
    for k in (1, 2, 4, 8, 16):
        S = topk_indices(x, k)
        lhs = lse(x) - lse([x[j] for j in S])
        rhs = -math.log(kept_mass(p, S))
        print(f"  k={k:2d}: LSE - LSE_S = {lhs:.6f}   -log M(S) = {rhs:.6f}")
    print(f"  (k=1 equals the Maslov gap {maslov_gap(x):.6f})")


def section_key_floors(rng: random.Random) -> None:
    header("5. Key-count floors: |S| >= tau e^g  and  |S| >= tau^2 / sum p^2")
    tau = 0.98
    for _ in range(4):
        x = core_tail_row(256, rng.randint(1, 6), rng.uniform(4.0, 7.0), 1.0, rng)
        p = softmax(x)
        order = sorted(p, reverse=True)
        acc, knee = 0.0, 0
        while acc < tau:
            acc += order[knee]
            knee += 1
        f1 = tau * math.exp(maslov_gap(x))
        f2 = tau ** 2 / collision(p)
        print(f"  true mass knee {knee:4d} >= gap floor {f1:7.2f}, collision floor {f2:7.2f}")
    print(f"Calibration: 0.98*e^2.69 = {tau * math.exp(2.69):.3f}  (certified >= 13)")
    print(f"             0.98^2/0.03 = {tau ** 2 / 0.03:.3f}  (certified >= 33)")


def section_margin(rng: random.Random) -> None:
    header("6. Margin bound  1 - M(S) <= (n-k) e^{-m} / k")
    for n, core, margin in ((512, 4, 9.0), (2048, 4, 10.0), (2048, 8, 11.0)):
        x = core_tail_row(n, core, margin, 0.5, rng)
        S = topk_indices(x, core)
        kept_min = min(x[j] for j in S)
        drop_max = max(x[j] for j in range(n) if j not in set(S))
        m = kept_min - drop_max
        loss = 1 - kept_mass(softmax(x), S)
        bound = (n - core) * math.exp(-m) / core
        print(f"  n={n:5d} k={core}: realized margin {m:5.2f}, loss {loss:.4f} <= bound {bound:.4f}")


def section_argmax_floor() -> None:
    header("7. Argmax floor F(m,n) = 1/(1+(n-1)e^{-m}) decays with context")
    for m in (4.0, 6.0, 8.0):
        vals = "  ".join(f"n={n}: {argmax_floor(m, n):.3f}" for n in (512, 1024, 2048, 65536))
        print(f"  m={m}: {vals}")


MEASURED: dict[int, dict[int, float]] = {
    512: {1: 0.3637, 2: 0.7865, 4: 0.9097, 8: 0.9617},
    1024: {1: 0.2885, 2: 0.7398, 4: 0.8906, 8: 0.9485},
    2048: {1: 0.2503, 2: 0.7002, 4: 0.8762, 8: 0.9408},
}
KNEES: dict[int, int] = {512: 16, 1024: 32, 2048: 24}


def section_doubling() -> None:
    header("8. Doubling inequality R(2k) <= 2R(k) vs the measured curve")
    for n, r in MEASURED.items():
        ratios = [r[2 * k] / r[k] for k in (1, 2, 4)]
        verdict = "VIOLATES" if ratios[0] > 2 else "ok"
        print(f"  n={n:5d}: R2/R1={ratios[0]:.3f} ({verdict}), R4/R2={ratios[1]:.3f}, "
              f"R8/R4={ratios[2]:.3f}; knee {KNEES[n]}")
    print("  -> measured retention is not a sorted kept-mass curve (nonlinear readout).")


def section_weierstrass(rng: random.Random) -> None:
    header("9. Weierstrass bounds  1 - sum eps <= prod(1-eps) <= exp(-sum eps)")
    eps = [rng.uniform(0.0, 0.05) for _ in range(24)]
    s = sum(eps)
    prod = math.prod(1 - e for e in eps)
    print(f"  24 random layers: {1 - s:.4f} <= {prod:.4f} <= {math.exp(-s):.4f}")
    R = 0.2503
    print(f"  argmax retention {R} at n=2048 => total layer loss in "
          f"[{1 - R:.4f}, {math.log(1 / R):.4f}] nats")


def section_core_tail_curve(rng: random.Random) -> None:
    header("10. Synthetic 'tropical core + soft tail': kept mass vs k")
    for n in (512, 1024, 2048):
        rows = [core_tail_row(n, 3, 6.5, 1.0, rng) for _ in range(50)]
        line = []
        for k in (1, 2, 4, 8, 16, 32):
            mean = sum(kept_mass(softmax(x), topk_indices(x, k)) for x in rows) / len(rows)
            line.append(f"k={k}:{mean:.3f}")
        print(f"  n={n:5d}  " + "  ".join(line))
    print("  (mass at k=1 falls with n, exactly as the argmax floor predicts)")


def main() -> None:
    rng = random.Random(50)
    section_gap_is_min_entropy(rng)
    section_sandwich(rng)
    section_p3()
    section_truncation(rng)
    section_key_floors(rng)
    section_margin(rng)
    section_argmax_floor()
    section_doubling()
    section_weierstrass(rng)
    section_core_tail_curve(rng)


if __name__ == "__main__":
    main()
