"""
Harmonic bulk x steeper edge: numerical demonstrations.

Self-contained (standard library only). Every function is inlined and type hinted.

The objects
-----------
Power-law kernel on the index range {1, ..., n}:

    p_a(k) = k ** (-a)

Head sum and head mass (the fraction of the observed weight in the window {1,...,m}):

    H_a(m)      = sum_{k=1}^{m} p_a(k)
    M_a(n, m)   = H_a(m) / H_a(n)

Bulk x edge mixture with bulk exponent a, edge exponent b > a and weight 0 < w < 1:

    q(k) = (1 - w) * k ** (-a) + w * k ** (-b)

Demonstrations
--------------
1. Monotonicity / rigidity: M_a(n, m) is strictly increasing in a.
2. Local exponents of a mixture are strictly between a and b and converge to a.
3. The strict antitone window law: narrower windows report strictly steeper
   implied exponents.
4. Falsifiability: implied exponents of a *pure* power law agree across windows.
5. Universality: the same antitone law for a three-component kernel.
6. Weight identifiability: recovering w from a single head statistic.
7. Saturation rates: 1/log n at the harmonic exponent, n^(a-1) below it,
   a positive limit above it.
8. The recorded instance: no exponent <= 1.104 gives peak/end 2.54, but the
   harmonic-bulk / quadratic-edge mixture with w = 54/127 gives it exactly.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

# --------------------------------------------------------------------------------------
# Core kernels and statistics
# --------------------------------------------------------------------------------------


def pw(a: float, k: int) -> float:
    """Power-law weight k^(-a) (k >= 1)."""
    return float(k) ** (-a)


def head_sum(a: float, m: int) -> float:
    """H_a(m) = sum_{k=1}^{m} k^(-a)."""
    return math.fsum(pw(a, k) for k in range(1, m + 1))


def head_mass(a: float, n: int, m: int) -> float:
    """M_a(n, m) = H_a(m) / H_a(n)."""
    return head_sum(a, m) / head_sum(a, n)


def mix(w: float, a: float, b: float, k: int) -> float:
    """Bulk x edge mixture (1 - w) k^(-a) + w k^(-b)."""
    return (1.0 - w) * pw(a, k) + w * pw(b, k)


def mix_head_sum(w: float, a: float, b: float, m: int) -> float:
    return math.fsum(mix(w, a, b, k) for k in range(1, m + 1))


def mix_head_mass(w: float, a: float, b: float, n: int, m: int) -> float:
    return mix_head_sum(w, a, b, m) / mix_head_sum(w, a, b, n)


def gen_kernel(weights: Sequence[float], exponents: Sequence[float], k: int) -> float:
    """General heterogeneous kernel sum_i w_i k^(-e_i)."""
    return math.fsum(wi * pw(ei, k) for wi, ei in zip(weights, exponents))


def gen_head_mass(
    weights: Sequence[float], exponents: Sequence[float], n: int, m: int
) -> float:
    num = math.fsum(gen_kernel(weights, exponents, k) for k in range(1, m + 1))
    den = math.fsum(gen_kernel(weights, exponents, k) for k in range(1, n + 1))
    return num / den


def local_exponent(f: Callable[[int], float], k: int) -> float:
    """E_f(k) = log(f(k)/f(k+1)) / log((k+1)/k), the log-log chord slope."""
    return math.log(f(k) / f(k + 1)) / math.log((k + 1.0) / k)


def steep_share(w: float, a: float, b: float, k: int) -> float:
    """Local share of the steep (edge) component: w k^(-b) / q(k)."""
    return w * pw(b, k) / mix(w, a, b, k)


# --------------------------------------------------------------------------------------
# Inversion routines (bisection on strictly monotone maps)
# --------------------------------------------------------------------------------------


def implied_exponent(
    target: float,
    n: int,
    m: int,
    lo: float = -5.0,
    hi: float = 20.0,
    tol: float = 1e-12,
    max_iter: int = 200,
) -> float:
    """Solve M_c(n, m) = target for c.

    The map c |-> M_c(n, m) is continuous and strictly increasing, so bisection on a
    bracketing interval converges to the unique root.
    """
    f_lo, f_hi = head_mass(lo, n, m) - target, head_mass(hi, n, m) - target
    if f_lo > 0.0 or f_hi < 0.0:
        raise ValueError("target head mass is outside the bracketing interval")
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if head_mass(mid, n, m) - target < 0.0:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


def recover_weight(
    target: float,
    a: float,
    b: float,
    n: int,
    m: int,
    tol: float = 1e-14,
    max_iter: int = 200,
) -> float:
    """Solve M_w(n, m) = target for the mixture weight w in [0, 1] (strictly monotone)."""
    lo, hi = 0.0, 1.0
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if mix_head_mass(mid, a, b, n, m) < target:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------


def demo_monotonicity(n: int = 2000, m: int = 20) -> None:
    print("=" * 78)
    print("1. Monotonicity and rigidity:  a < b  =>  M_a(n,m) < M_b(n,m)")
    print("=" * 78)
    print(f"   truncation n = {n}, window m = {m}\n")
    print(f"   {'exponent a':>12}   {'head mass M_a(n,m)':>20}")
    values: List[float] = []
    for a in [0.0, 0.25, 0.5, 0.75, 1.0, 1.104, 1.5, 2.0]:
        v = head_mass(a, n, m)
        values.append(v)
        print(f"   {a:12.3f}   {v:20.10f}")
    strict = all(x < y for x, y in zip(values, values[1:]))
    print(f"\n   strictly increasing: {strict}")
    print(f"   equal-weight share m/n = {m / n:.10f} (this is exactly M_0(n,m))")
    print("   every decaying kernel is strictly head-biased relative to m/n.\n")


def demo_local_exponents(w: float = 54 / 127, a: float = 1.0, b: float = 2.0) -> None:
    print("=" * 78)
    print("2. Local exponents of a mixture lie strictly in (a, b) and converge to a")
    print("=" * 78)
    print(f"   mixture: w = {w:.6f}, bulk a = {a}, edge b = {b}\n")
    print(f"   {'k':>8} {'E_q(k)':>14} {'upper bound':>14} {'steep share':>14}")
    for k in [1, 2, 5, 10, 50, 200, 1000, 5000]:
        e = local_exponent(lambda j: mix(w, a, b, j), k)
        bound = a + (w / (1.0 - w)) * (b - a) * float(k) ** (-(b - a))
        s = steep_share(w, a, b, k)
        print(f"   {k:8d} {e:14.8f} {bound:14.8f} {s:14.8f}")
    print("\n   all local exponents satisfy a < E_q(k) <= a + (w/(1-w))(b-a) k^-(b-a)")
    print("   the steep share decreases strictly to 0: the edge is a local effect.\n")


def demo_window_law(
    w: float = 54 / 127, a: float = 1.0, b: float = 2.0, n: int = 4000
) -> None:
    print("=" * 78)
    print("3. Strict antitone window law: narrower windows report steeper exponents")
    print("=" * 78)
    print(f"   mixture: w = {w:.6f}, a = {a}, b = {b}, truncation n = {n}\n")
    print(f"   {'window m':>10} {'mixture head mass':>20} {'implied exponent':>20}")
    exps: List[float] = []
    for m in [1, 2, 5, 10, 25, 50, 100, 400, 1000, 2000]:
        v = mix_head_mass(w, a, b, n, m)
        c = implied_exponent(v, n, m)
        exps.append(c)
        print(f"   {m:10d} {v:20.10f} {c:20.10f}")
    antitone = all(x > y for x, y in zip(exps, exps[1:]))
    print(f"\n   strictly antitone in the window width: {antitone}")
    print(f"   all implied exponents inside (a, b) = ({a}, {b}): "
          f"{all(a < c < b for c in exps)}")
    print("   a bulk fit on a wide window and an edge reading on a narrow one MUST")
    print("   disagree, and the narrow one must be the steeper.\n")


def demo_falsifiability(a: float = 1.3, n: int = 4000) -> None:
    print("=" * 78)
    print("4. Falsifiability: a pure power law reports the SAME exponent everywhere")
    print("=" * 78)
    print(f"   pure kernel with exponent a = {a}, truncation n = {n}\n")
    print(f"   {'window m':>10} {'implied exponent':>20} {'deviation from a':>20}")
    for m in [1, 5, 20, 100, 500, 2000]:
        c = implied_exponent(head_mass(a, n, m), n, m)
        print(f"   {m:10d} {c:20.10f} {c - a:20.2e}")
    print("\n   equal implied exponents across two windows certify that the kernel is")
    print("   NOT a heterogeneous mixture -- the theory is refutable by data.\n")


def demo_universality(n: int = 4000) -> None:
    print("=" * 78)
    print("5. Universality: three components, same antitone law")
    print("=" * 78)
    weights = [0.55, 0.30, 0.15]
    exponents = [0.8, 1.6, 3.0]
    print(f"   kernel: {weights[0]} k^-{exponents[0]} + {weights[1]} k^-{exponents[1]}"
          f" + {weights[2]} k^-{exponents[2]},  n = {n}\n")
    print(f"   {'window m':>10} {'head mass':>20} {'implied exponent':>20}")
    exps: List[float] = []
    for m in [1, 3, 10, 40, 200, 1000, 2000]:
        v = gen_head_mass(weights, exponents, n, m)
        c = implied_exponent(v, n, m)
        exps.append(c)
        print(f"   {m:10d} {v:20.10f} {c:20.10f}")
    print(f"\n   strictly antitone: {all(x > y for x, y in zip(exps, exps[1:]))}")
    print("   exponent heterogeneity as such -- not the number two -- drives the law.\n")


def demo_weight_recovery(
    w_true: float = 54 / 127, a: float = 1.0, b: float = 2.0, n: int = 3000
) -> None:
    print("=" * 78)
    print("6. Weight identifiability: one window determines w, others become tests")
    print("=" * 78)
    m_fit = 10
    v = mix_head_mass(w_true, a, b, n, m_fit)
    w_hat = recover_weight(v, a, b, n, m_fit)
    print(f"   true weight        w = {w_true:.12f}")
    print(f"   fitted on window m = {m_fit}:  w_hat = {w_hat:.12f}")
    print(f"   absolute error         = {abs(w_hat - w_true):.3e}\n")
    print(f"   {'window m':>10} {'observed':>18} {'predicted':>18} {'abs error':>12}")
    for m in [1, 5, 50, 200, 1000]:
        obs = mix_head_mass(w_true, a, b, n, m)
        pred = mix_head_mass(w_hat, a, b, n, m)
        print(f"   {m:10d} {obs:18.12f} {pred:18.12f} {abs(obs - pred):12.2e}")
    print("\n   the model is over-determined: one statistic fixes w, the rest are")
    print("   genuine out-of-sample predictions.\n")


def demo_saturation_rates(m: int = 5) -> None:
    print("=" * 78)
    print("7. Saturation rates: only super-harmonic dials converge")
    print("=" * 78)
    print(f"   fixed window m = {m}\n")

    print("   (a) harmonic exponent a = 1: dial decays like H(m)/log n")
    hm = head_sum(1.0, m)
    print(f"       H(m) = {hm:.10f}")
    print(f"       {'n':>10} {'M_1(n,m)':>16} {'M_1(n,m)*log n':>18} "
          f"{'lower bound':>16}")
    for n in [10, 100, 1000, 10_000, 100_000]:
        v = head_mass(1.0, n, m)
        print(f"       {n:10d} {v:16.10f} {v * math.log(n):18.10f} "
              f"{hm / (1 + math.log(n)):16.10f}")
    n0 = 300
    ratio = head_mass(1.0, n0 * n0, m) / head_mass(1.0, n0, m)
    print(f"\n       squaring the truncation: M_1({n0}^2,m)/M_1({n0},m) = {ratio:.6f}"
          f"  (limit 1/2)")
    dbl = head_mass(1.0, 2 * 20000, m) / head_mass(1.0, 20000, m)
    print(f"       doubling the truncation: ratio = {dbl:.6f}  (limit 1: neutral)")
    print("       => a 1/log n dial looks 'saturated' over any feasible range.\n")

    print("   (b) sub-harmonic 0 <= a < 1: dial decays like (1-a) H_a(m) n^(a-1)")
    for a in [0.0, 0.5, 0.8]:
        target = (1.0 - a) * head_sum(a, m)
        print(f"       a = {a}:  limit of M_a(n,m) n^(1-a) is {target:.10f}")
        for n in [100, 1000, 10_000, 100_000]:
            v = head_mass(a, n, m) * float(n) ** (1.0 - a)
            print(f"         n = {n:7d}   scaled dial = {v:.10f}")
        dbl = head_mass(a, 2 * 50_000, m) / head_mass(a, 50_000, m)
        print(f"         doubling ratio = {dbl:.6f}   (limit 2^(a-1) = "
              f"{2.0 ** (a - 1.0):.6f})\n")

    print("   (c) super-harmonic a > 1: genuine saturation")
    for a in [1.2, 2.0]:
        limit = head_sum(a, m) / math.fsum(pw(a, k) for k in range(1, 2_000_000))
        print(f"       a = {a}: M_a(n,m) -> {limit:.10f}")
        for n in [100, 10_000, 1_000_000]:
            print(f"         n = {n:9d}   M_a(n,m) = {head_mass(a, n, m):.10f}")
    print()


def demo_recorded_instance() -> None:
    print("=" * 78)
    print("8. The recorded instance: bulk 1.104 versus peak/end 2.54")
    print("=" * 78)
    print("   For a pure power law, peak/end = p_a(1)/p_a(2) = 2^a.\n")
    print(f"   {'exponent a':>12} {'2^a':>14}")
    for a in [1.0, 1.05, 1.104, 1.125]:
        print(f"   {a:12.3f} {2.0 ** a:14.8f}")
    print(f"\n   observed peak/end ratio: 2.54")
    print(f"   largest ratio compatible with a <= 1.104: {2.0 ** 1.104:.8f} < 2.54")
    print("   => no power law respecting the fitted bulk exponent reproduces it.\n")

    w, a, b = 54 / 127, 1.0, 2.0
    ratio = mix(w, a, b, 1) / mix(w, a, b, 2)
    print(f"   harmonic bulk / quadratic edge mixture, w = 54/127:")
    print(f"     q(1)      = {mix(w, a, b, 1):.12f}")
    print(f"     q(2)      = {mix(w, a, b, 2):.12f}   (= 50/127)")
    print(f"     q(1)/q(2) = {ratio:.12f}   (exactly 127/50 = 2.54)")
    print(f"     local exponents in (1,2): "
          f"{all(1.0 < local_exponent(lambda j: mix(w, a, b, j), k) < 2.0 for k in range(1, 500))}")
    print(f"     E_q(1) = {local_exponent(lambda j: mix(w, a, b, j), 1):.8f}, "
          f"E_q(1000) = {local_exponent(lambda j: mix(w, a, b, j), 1000):.8f}")
    print("   the harmonic bulk survives; the edge statistic is reproduced exactly.\n")


def main() -> None:
    demo_monotonicity()
    demo_local_exponents()
    demo_window_law()
    demo_falsifiability()
    demo_universality()
    demo_weight_recovery()
    demo_saturation_rates()
    demo_recorded_instance()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
