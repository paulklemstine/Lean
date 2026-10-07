#!/usr/bin/env python3
"""
The real-model knee collapses and saturates -- numerical companion.

Self-contained demonstrations of the structural results behind the
measurement that, on a pretrained 0.5B-parameter transformer (24 layers),
the lossless top-k attention knee is k* = 16, 32, 24 at context lengths
512, 1024, 2048 -- 24x to 64x below the toy law d * ctx / 32.

Sections
  1. Depth sandwich:  1 - D <= prod(1 - delta_l) <= 1 / (1 + D).
  2. Toy depth multiplier (knee linear in depth d) and its collapse
     (knee bounded independently of d when only m layers carry a tail).
  3. Context monotonicity of the knee and saturation under geometric decay.
  4. Selection gap: top-k share >= k/n; band profiles have tiny gaps;
     a knee forces a gap >= tau - k*/n  (> 0.968 at the operating point).
  5. Depth map in mass units via effective support (Cauchy-Schwarz).
  6. The measured sweeps and the brackets they certify.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
import random
from typing import Callable, Sequence

# ---------------------------------------------------------------------------
# Core definitions
# ---------------------------------------------------------------------------


def head_mass(w: Sequence[float], n: int) -> float:
    """Total weight of the first n (largest) entries of a sorted profile."""
    return float(sum(w[:n]))


def retained(w: Sequence[float], n: int, k: int) -> float:
    """Fraction of the first-n mass kept by the top-min(k, n) entries."""
    return head_mass(w, min(k, n)) / head_mass(w, n)


def kstar(w: Sequence[float], n: int, tau: float) -> int:
    """Smallest key budget k whose retained fraction reaches tau."""
    for k in range(n + 1):
        if retained(w, n, k) >= tau:
            return k
    return n


def comp_retention(deltas: Sequence[float]) -> float:
    """Compounded retention prod_l (1 - delta_l) of a stack of layers."""
    r = 1.0
    for d in deltas:
        r *= 1.0 - d
    return r


def tail_deficit(c: float, k: int) -> float:
    """Toy power-law tail deficit c / (c + k) of a layer at budget k."""
    return c / (c + k)


def depth_knee(deficit: Callable[[int], Sequence[float]], g: float, kmax: int = 10**7) -> int:
    """Smallest k with prod(1 - delta_l(k)) >= g (binary search; deficits decrease in k)."""
    lo, hi = 0, kmax
    while lo < hi:
        mid = (lo + hi) // 2
        if comp_retention(deficit(mid)) >= g:
            hi = mid
        else:
            lo = mid + 1
    return lo


# ---------------------------------------------------------------------------
# 1. Depth sandwich
# ---------------------------------------------------------------------------


def demo_sandwich(trials: int = 5) -> None:
    print("=" * 72)
    print("1. DEPTH SANDWICH   1 - D  <=  prod(1 - delta)  <=  1/(1 + D)")
    print("=" * 72)
    rng = random.Random(49)
    print(f"{'layers':>6} {'D':>8} {'1-D':>9} {'R':>9} {'1/(1+D)':>9}  ok")
    for _ in range(trials):
        d = rng.randint(2, 24)
        deltas = [rng.random() * rng.choice([0.02, 0.1, 0.5]) for _ in range(d)]
        D = sum(deltas)
        R = comp_retention(deltas)
        ok = (1 - D) <= R + 1e-12 and R <= 1 / (1 + D) + 1e-12
        print(f"{d:>6} {D:>8.4f} {1-D:>9.4f} {R:>9.4f} {1/(1+D):>9.4f}  {ok}")
    g = 0.98
    print(f"\nGate g = {g}:  sufficient  D <= 1-g = {1-g:.4f};"
          f"  necessary  D <= (1-g)/g = {(1-g)/g:.4f}")


# ---------------------------------------------------------------------------
# 2. Toy depth multiplier and its collapse
# ---------------------------------------------------------------------------


def demo_depth_multiplier(c: float = 0.2, g: float = 0.98, m: int = 2) -> None:
    print("\n" + "=" * 72)
    print("2. TOY DEPTH MULTIPLIER  vs  COLLAPSED DEPTH MULTIPLIER")
    print("=" * 72)
    print(f"tail c = {c}, gate g = {g}, tail layers in collapsed model m = {m}, k0 = 12")
    print(f"{'d':>4} {'lower':>9} {'toy k*':>8} {'upper':>7} | {'collapsed k*':>12} {'bound':>6}")
    for d in (2, 4, 8, 12, 24, 48, 96):
        toy = depth_knee(lambda k: [tail_deficit(c, k)] * d, g)
        lower = g * d * c / (1 - g) - c
        upper = math.ceil(d * c / (1 - g))
        k0 = 12

        def collapsed(k: int) -> list[float]:
            other = 0.0 if k >= k0 else 0.5
            return [tail_deficit(c, k)] * m + [other] * (d - m)

        col = depth_knee(collapsed, g)
        bound = max(k0, math.ceil(m * c / (1 - g)))
        assert lower <= toy <= upper and col <= bound
        print(f"{d:>4} {lower:>9.1f} {toy:>8d} {upper:>7d} | {col:>12d} {bound:>6d}")
    print("Toy knee grows linearly in d; collapsed knee is flat in d.")


# ---------------------------------------------------------------------------
# 3. Monotonicity and saturation in context length
# ---------------------------------------------------------------------------


def demo_saturation(tau: float = 0.98) -> None:
    print("\n" + "=" * 72)
    print("3. CONTEXT MONOTONICITY AND SATURATION OF THE KNEE")
    print("=" * 72)
    N = 8192
    geo = [0.8 ** i for i in range(N)]
    power = [1.0 / (i + 1) ** 1.1 for i in range(N)]
    ctxs = [64, 128, 256, 512, 1024, 2048, 4096, 8192]
    print(f"{'ctx':>6} {'geometric r=0.8':>16} {'power-law a=1.1':>16}")
    prev_g = prev_p = -1
    for n in ctxs:
        kg, kp = kstar(geo, n, tau), kstar(power, n, tau)
        assert kg >= prev_g and kp >= prev_p
        prev_g, prev_p = kg, kp
        print(f"{n:>6} {kg:>16d} {kp:>16d}")
    print("Both monotone; geometric decay is eventually constant (saturation),")
    print("the heavy power-law tail keeps growing. A *declining* knee is impossible")
    print("for any single fixed positive profile.")


# ---------------------------------------------------------------------------
# 4. Selection gap
# ---------------------------------------------------------------------------


def demo_selection_gap() -> None:
    print("\n" + "=" * 72)
    print("4. SELECTION GAP  = retained top-k share  -  uniform share k/n")
    print("=" * 72)
    n, k, tau = 2048, 24, 0.98
    rng = random.Random(7)
    band = sorted((rng.uniform(1.0, 2.0) for _ in range(n)), reverse=True)
    gap_band = retained(band, n, k) - k / n
    bound_band = k * (2.0 - 1.0) / (n * 1.0)
    print(f"band profile in [1,2]: gap = {gap_band:.5f}  <= bound k(M-c)/(nc) = {bound_band:.5f}")
    # A concentrated profile with knee exactly 24.
    geo = [0.85 ** i for i in range(n)]
    ks = kstar(geo, n, tau)
    print(f"geometric r=0.85 profile: k* = {ks}, gap at knee = {retained(geo, n, ks) - ks/n:.5f}"
          f" >= tau - k*/n = {tau - ks/n:.5f}")
    print(f"operating point tau=0.98, k*=24, n=2048: tau - k*/n = {tau - 24/n:.6f} > 0.968")
    print(f"any band profile with M <= 2c: gap <= 24/2048 = {24/2048:.6f} < 0.012")


# ---------------------------------------------------------------------------
# 5. Depth map in mass units
# ---------------------------------------------------------------------------


def eff_support(p: Sequence[float]) -> float:
    return 1.0 / sum(x * x for x in p)


def demo_depth_map() -> None:
    print("\n" + "=" * 72)
    print("5. DEPTH MAP IN MASS UNITS  (mass of k keys)^2 <= k / N_eff")
    print("=" * 72)
    for N, k in ((128.5, 24), (12.0, 12), (12.0, 11), (83.0, 24), (2.9, 4)):
        print(f"N_eff = {N:>6}: any {k:>2}-key set keeps mass <= sqrt(k/N) = {math.sqrt(min(1, k/N)):.4f}")
    print(f"L22 @ 2048: sqrt(24/128.5) = {math.sqrt(24/128.5):.5f} < 0.433")
    print(f"median layer N_eff=12: 98% mass needs |T| >= 0.98^2*12 = {0.98**2*12:.3f} -> 12 keys")
    # Empirical check on a random distribution
    rng = random.Random(3)
    p = [rng.expovariate(1.0) ** 3 for _ in range(2048)]
    s = sum(p)
    p = sorted((x / s for x in p), reverse=True)
    N = eff_support(p)
    top = sum(p[:24])
    print(f"random heavy profile: N_eff = {N:.1f}, top-24 mass = {top:.4f} <= {math.sqrt(min(1, 24/N)):.4f}")


# ---------------------------------------------------------------------------
# 6. Measured data and brackets
# ---------------------------------------------------------------------------

SWEEPS: dict[int, list[tuple[int, float]]] = {
    512: [(8, 0.9617), (16, 0.9834), (192, 0.9997)],
    1024: [(16, 0.9771), (32, 0.9912), (384, 1.0003)],
    2048: [(4, 0.8762), (8, 0.9408), (16, 0.9708), (24, 0.9818), (32, 0.9867), (768, 0.9997)],
}


def bracket(sweep: list[tuple[int, float]], tau: float = 0.98) -> tuple[int, int]:
    fails = [k for k, r in sweep if r < tau]
    passes = [k for k, r in sweep if r >= tau]
    return (max(fails) if fails else 0, min(passes))


def demo_measurement() -> None:
    print("\n" + "=" * 72)
    print("6. MEASURED KNEES, TOY LAW, AND CERTIFIED BRACKETS (gate 0.98)")
    print("=" * 72)
    d = 24
    print(f"{'ctx':>5} {'bracket':>10} {'k*':>4} {'d*ctx/32':>9} {'ratio':>7} {'KV read cut':>11}")
    for ctx, sw in SWEEPS.items():
        lo, hi = bracket(sw)
        toy = d * ctx // 32
        print(f"{ctx:>5} {f'({lo},{hi}]':>10} {hi:>4} {toy:>9} {f'1/{toy//hi}':>7} {ctx/hi:>10.1f}x")
    b1, b2 = bracket(SWEEPS[1024]), bracket(SWEEPS[2048])
    overlap = [k for k in range(b1[0] + 1, b1[1] + 1) if b2[0] < k <= b2[1]]
    print(f"brackets (16,32] and (16,24] overlap on {overlap[0]}..{overlap[-1]}:"
          " the 32 -> 24 'decline' is not certified; flat saturation at 24 fits.")


if __name__ == "__main__":
    demo_sandwich()
    demo_depth_multiplier()
    demo_saturation()
    demo_selection_gap()
    demo_depth_map()
    demo_measurement()
