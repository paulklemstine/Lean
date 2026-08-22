#!/usr/bin/env python3
"""
Numerical demonstrations for
"The Arithmetic of Round-to-Nearest Quantization: Sharp Mesh Constants,
 Sawtooth Bias, and the Non-Existence of a Bit-Only Damage Floor".

Everything is self-contained: standard library only, all helpers inlined,
full type hints.  Run with

    python3 demo.py

Each section prints a check of one theorem from the paper.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 0.  Core primitives
# ----------------------------------------------------------------------------


def round_half_up(x: float) -> int:
    """Nearest integer to `x`, breaking ties upwards (matches the paper's
    convention; Python's built-in `round` uses banker's rounding)."""
    return math.floor(x + 0.5)


def rtn(delta: float, x: float) -> float:
    """Round-to-nearest quantization of `x` onto the mesh `delta * Z`."""
    return delta * round_half_up(x / delta)


def mesh(amplitude: float, bits: int) -> float:
    """Mesh of a `bits`-bit absmax quantizer for a tensor of given amplitude."""
    return amplitude / 2.0 ** bits


def sawtooth(x: float) -> float:
    """Signed round-to-nearest error at unit mesh: round(x) - x."""
    return round_half_up(x) - x


def quantize_vector(weights: Sequence[float], bits: int) -> List[float]:
    """Absmax RTN quantization of a whole vector (one shared scale)."""
    amplitude = max(abs(w) for w in weights) if weights else 0.0
    if amplitude == 0.0:
        return list(weights)
    d = mesh(amplitude, bits)
    return [rtn(d, w) for w in weights]


def quantize_grouped(weights: Sequence[float], bits: int, group: int) -> List[float]:
    """Absmax RTN quantization with one scale per block of `group` weights."""
    out: List[float] = []
    for start in range(0, len(weights), group):
        out.extend(quantize_vector(weights[start:start + group], bits))
    return out


def l1_defect(u: Sequence[float], v: Sequence[float]) -> float:
    return sum(abs(a - b) for a, b in zip(u, v))


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# ----------------------------------------------------------------------------
# 1.  The sharp mesh constant
# ----------------------------------------------------------------------------


def demo_mesh_sharpness() -> None:
    banner("1.  Mesh bound |rtn(x) - x| <= Delta/2, and its exact attainment")
    delta = 0.375
    worst = 0.0
    rng = random.Random(20260822)
    for _ in range(200_000):
        x = rng.uniform(-50.0, 50.0)
        worst = max(worst, abs(rtn(delta, x) - x))
    print(f"  Delta                       = {delta}")
    print(f"  Delta/2                     = {delta / 2}")
    print(f"  max |rtn(x)-x| over 2e5 x   = {worst:.12f}   (<= Delta/2)")
    at_mid = rtn(delta, delta / 2) - delta / 2
    print(f"  error exactly at x=Delta/2  = {at_mid:.12f}   (= Delta/2 exactly)")
    print("  => no constant smaller than 1/2 can work.")

    print("\n  One extra bit halves the mesh (amplitude A = 3.0):")
    for b in range(0, 9):
        print(f"    b = {b}:  Delta = A/2^b = {mesh(3.0, b):.8f}")


# ----------------------------------------------------------------------------
# 2.  No bits-only damage floor
# ----------------------------------------------------------------------------


def no_floor_witness(bits: int, budget: float) -> Tuple[float, List[float], float]:
    """Construct the counterexample of the non-transfer theorem.

    Returns (amplitude, weights, damage) with damage > budget for the given
    bit budget, using the 1-Lipschitz functional f(u) = sum(u)."""
    amplitude = (abs(budget) + 1.0) * 2.0 ** (bits + 1)
    d = mesh(amplitude, bits)
    weights = [d / 2.0]                      # a single midpoint weight
    damage = abs(sum(rtn(d, w) for w in weights) - sum(weights))
    return amplitude, weights, damage


def demo_no_bit_floor() -> None:
    banner("2.  No bits-only floor: for every (bits, budget) there is a witness")
    print(f"  {'bits':>5} {'claimed budget c':>18} {'amplitude A':>16} {'actual damage':>16}")
    for bits, budget in [(4, 0.05), (4, 1.0), (8, 10.0), (16, 1000.0), (32, 1e6)]:
        amplitude, weights, damage = no_floor_witness(bits, budget)
        ok = "OK" if damage > budget else "FAIL"
        print(f"  {bits:5d} {budget:18.4g} {amplitude:16.4g} {damage:16.4g}  {ok}")
    print("  Any statement 'b bits cost at most c' is refuted by an amplitude.")


# ----------------------------------------------------------------------------
# 3.  Grouping: the exact gain, and a synthetic outlier channel
# ----------------------------------------------------------------------------


def demo_grouping() -> None:
    banner("3.  Grouping: exact gain = half the amplitude deficit")
    group_meshes = [0.4, 0.9, 0.15, 1.0, 0.25, 0.8]
    global_mesh = 1.0
    n = len(group_meshes)
    grouped_bound = sum(d / 2 for d in group_meshes)
    global_bound = n * global_mesh / 2
    gain = sum(global_mesh - d for d in group_meshes) / 2
    print(f"  global bound  n*D/2          = {global_bound:.6f}")
    print(f"  grouped bound sum Delta_i/2  = {grouped_bound:.6f}")
    print(f"  difference                   = {global_bound - grouped_bound:.6f}")
    print(f"  predicted gain (deficit)/2   = {gain:.6f}")
    print(f"  predicted repair fraction    = "
          f"{1 - (sum(group_meshes) / n) / global_mesh:.4f}"
          "   (= 1 - mean/max)")

    print("\n  Synthetic outlier channel (bulk N(0,1), one weight of size 30):")
    rng = random.Random(7)
    width = 1024
    channel = [rng.gauss(0.0, 1.0) for _ in range(width)]
    channel[137] = 30.0                      # the outlier that sets the scale
    for bits in (8, 6, 5, 4, 3):
        plain = l1_defect(quantize_vector(channel, bits), channel) / width
        g128 = l1_defect(quantize_grouped(channel, bits, 128), channel) / width
        repair = 1.0 - g128 / plain if plain else 0.0
        print(f"    {bits}-bit: mean |err| per-channel = {plain:.5f}, "
              f"group-128 = {g128:.5f}, repaired {100 * repair:5.1f}%")


# ----------------------------------------------------------------------------
# 4.  Signed error: the parity dichotomy and multiplier rigidity
# ----------------------------------------------------------------------------


def period_signed_sum(q: int, multiplier: int = 1) -> float:
    return sum(sawtooth((k * multiplier) / q) for k in range(q))


def demo_signed_bias() -> None:
    banner("4.  Signed period sum = floor(q/2) - (q-1)/2  (0 if q odd, 1/2 if q even)")
    print(f"  {'q':>5} {'sum s(j/q)':>14} {'floor(q/2)-(q-1)/2':>22}")
    for q in [1, 2, 3, 4, 5, 6, 7, 8, 15, 16, 17, 64, 127, 128, 256]:
        predicted = q // 2 - (q - 1) / 2
        print(f"  {q:5d} {period_signed_sum(q):14.10f} {predicted:22.10f}")

    print("\n  Dyadic (hardware) grids q = 2^b are always biased by exactly 1/2:")
    for b in range(1, 13):
        print(f"    b = {b:2d} (q = {2 ** b:5d}):  bias = {period_signed_sum(2 ** b):.10f}"
              f"   mean bias = {period_signed_sum(2 ** b) / 2 ** b:.3e}")

    print("\n  Multiplier invariance: sum over the progression k*p/q, gcd(p,q)=1:")
    for q in (16, 17, 30, 31):
        units = [p for p in range(1, q) if math.gcd(p, q) == 1][:6]
        vals = [period_signed_sum(q, p) for p in units]
        print(f"    q = {q:3d}, p in {units}: sums = "
              + ", ".join(f"{v:.6f}" for v in vals))


# ----------------------------------------------------------------------------
# 5.  Absolute error: the Mantel-Turan bridge
# ----------------------------------------------------------------------------


def turan_max_triangle_free_edges(q: int) -> int:
    """Brute-force-free formula check target: ex(q; K_3) = floor(q^2/4),
    attained by the balanced complete bipartite graph."""
    return (q // 2) * (q - q // 2)


def demo_turan_bridge() -> None:
    banner("5.  L1 rounding energy = Mantel-Turan number floor(q^2/4)")
    print(f"  {'q':>5} {'sum min(j,q-j)':>16} {'floor(q^2/4)':>14} "
          f"{'K_{a,b} edges':>14} {'sum|s(j/q)|':>14} {'q/4':>10}")
    for q in [1, 2, 3, 4, 5, 8, 9, 16, 17, 32, 64, 128]:
        s_min = sum(min(j, q - j) for j in range(q))
        s_abs = sum(abs(sawtooth(j / q)) for j in range(q))
        print(f"  {q:5d} {s_min:16d} {q * q // 4:14d} "
              f"{turan_max_triangle_free_edges(q):14d} {s_abs:14.8f} {q / 4:10.4f}")
    print("  The integer column is the max number of edges of a triangle-free")
    print("  graph on q vertices; the mean absolute error is a quarter mesh unit.")


# ----------------------------------------------------------------------------
# 6.  Depth compounding and layer sensitivity
# ----------------------------------------------------------------------------


def product(xs: Iterable[float]) -> float:
    p = 1.0
    for x in xs:
        p *= x
    return p


def demo_depth() -> None:
    banner("6.  Depth: compounding bound (M+delta)^n - M^n, attained; sensitivity")
    M, delta = 1.05, 0.02
    rng = random.Random(11)
    print(f"  M = {M}, delta = {delta}")
    print(f"  {'n':>4} {'random defect':>16} {'worst-case bound':>18} {'attained':>12}")
    for n in (4, 8, 12, 24, 48):
        w = [rng.uniform(-M, M) for _ in range(n)]
        e = [rng.uniform(-delta, delta) for _ in range(n)]
        actual = abs(product(a + b for a, b in zip(w, e)) - product(w))
        bound = (M + delta) ** n - M ** n
        attained = abs(product([M + delta] * n) - product([M] * n))
        print(f"  {n:4d} {actual:16.8f} {bound:18.8f} {attained:12.8f}")

    print("\n  Exact single-layer sensitivity: perturbing layer k by t moves the")
    print("  product by exactly t * prod_{i != k} w_i.")
    w = [0.5, 2.0, 1.5, 0.25, 3.0]
    t = 0.01
    for k in range(len(w)):
        pert = list(w)
        pert[k] += t
        lhs = product(pert) - product(w)
        rhs = t * product(w[i] for i in range(len(w)) if i != k)
        print(f"    k = {k} (w_k = {w[k]:4.2f}): exact = {lhs: .10f}, "
              f"formula = {rhs: .10f}, |sensitivity| = {abs(rhs / t):8.4f}")
    print("  Sensitivity is ANTITONE in the layer's own weight: the smallest")
    print("  weight (0.25) is the most sensitive layer, the largest (3.0) the least.")


# ----------------------------------------------------------------------------
# 7.  Water-filling: optimal mixed-precision bit allocation
# ----------------------------------------------------------------------------


def bit_cost(amplitudes: Sequence[float], bits: Sequence[float]) -> float:
    return sum(a * 2.0 ** (-b) for a, b in zip(amplitudes, bits))


def waterfill(amplitudes: Sequence[float], budget: float) -> List[float]:
    n = len(amplitudes)
    mean_log = sum(math.log2(a) for a in amplitudes) / n
    return [budget / n + math.log2(a) - mean_log for a in amplitudes]


def demo_waterfilling() -> None:
    banner("7.  Water-filling: optimal bit allocation across unequal amplitudes")
    amplitudes = [1.0, 4.0, 0.5, 16.0, 2.0]
    n = len(amplitudes)
    budget = 20.0
    opt = waterfill(amplitudes, budget)
    uniform = [budget / n] * n
    geo = product(amplitudes) ** (1.0 / n)
    lower = n * geo * 2.0 ** (-budget / n)
    print(f"  amplitudes           = {amplitudes}")
    print(f"  total budget B       = {budget}  ({n} tensors)")
    print(f"  water-filling bits   = " + ", ".join(f"{b:.4f}" for b in opt))
    print(f"  spent                = {sum(opt):.10f}  (= B)")
    print(f"  cost(optimal)        = {bit_cost(amplitudes, opt):.10f}")
    print(f"  AM-GM lower bound    = {lower:.10f}")
    print(f"  cost(uniform)        = {bit_cost(amplitudes, uniform):.10f}")

    rng = random.Random(3)
    best_random = min(
        bit_cost(amplitudes, perturbed)
        for perturbed in (
            [b + d for b, d in zip(opt, deltas)]
            for deltas in (
                (lambda ds: ds + [-sum(ds)])([rng.uniform(-2, 2) for _ in range(n - 1)])
                for _ in range(200_000)
            )
        )
    )
    print(f"  best of 2e5 random budget-preserving perturbations = {best_random:.10f}")
    print("  (never below the optimum: the water-filling allocation is optimal)")

    print("\n  Minimal witness that uniform precision is strictly suboptimal:")
    print(f"    A = (1, 4), B = 0:  uniform (0,0) costs "
          f"{bit_cost([1.0, 4.0], [0.0, 0.0]):.1f}, "
          f"(-1, +1) costs {bit_cost([1.0, 4.0], [-1.0, 1.0]):.1f}")


# ----------------------------------------------------------------------------
# 8.  The measured cliff, reproduced qualitatively on a synthetic checkpoint
# ----------------------------------------------------------------------------


def demo_cliff() -> None:
    banner("8.  The bit cliff on a synthetic heavy-tailed weight matrix")
    rng = random.Random(2026)
    rows, cols = 64, 512
    matrix: List[List[float]] = []
    for _ in range(rows):
        row = [rng.gauss(0.0, 0.02) for _ in range(cols)]
        for _ in range(3):                      # a few per-channel outliers
            row[rng.randrange(cols)] = rng.choice([-1.0, 1.0]) * rng.uniform(0.4, 0.9)
        matrix.append(row)

    measured = {8: 0.0044, 6: 0.0353, 5: 0.1281, 4: 0.7879, 3: 9.2262, 2: 14.0588}
    print(f"  {'bits':>5} {'rel L2 error (per-ch)':>24} {'group-128':>12} "
          f"{'repair':>8} {'measured dCE':>14}")
    for bits in (8, 6, 5, 4, 3, 2):
        def rel(quant: Callable[[Sequence[float]], List[float]]) -> float:
            num = 0.0
            den = 0.0
            for row in matrix:
                q = quant(row)
                num += sum((a - b) ** 2 for a, b in zip(q, row))
                den += sum(a * a for a in row)
            return math.sqrt(num / den)

        per_channel = rel(lambda r: quantize_vector(r, bits))
        grouped = rel(lambda r: quantize_grouped(r, bits, 128))
        repair = 1.0 - grouped / per_channel if per_channel else 0.0
        print(f"  {bits:5d} {per_channel:24.6f} {grouped:12.6f} "
              f"{100 * repair:7.1f}% {measured[bits]:14.4f}")
    print("  In the fine-mesh regime the relative weight error doubles per bit")
    print("  removed (one bit = one halving of the mesh); it saturates once the")
    print("  mesh exceeds the bulk scale, while the measured loss damage keeps")
    print("  accelerating -- compounding turns a bounded weight error into a")
    print("  cliff in cross-entropy.")


# ----------------------------------------------------------------------------


def main() -> None:
    print("Round-to-nearest quantization: numerical companion to the paper")
    demo_mesh_sharpness()
    demo_no_bit_floor()
    demo_grouping()
    demo_signed_bias()
    demo_turan_bridge()
    demo_depth()
    demo_waterfilling()
    demo_cliff()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
