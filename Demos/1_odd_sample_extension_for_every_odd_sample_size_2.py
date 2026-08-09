"""
Exact training dynamics of tropical L1 regression -- numerical demonstrations.

This self-contained script demonstrates, by direct computation, every headline
result of the accompanying paper:

  1. Tropical L1 loss and the counting (block-imbalance) growth mechanism.
  2. Odd samples: unique median minimizer, growth bound L(m) + |t-m| <= L(t),
     exact affine slabs.
  3. The clipped update: semigroup law, exact distance law, iterate = flow.
  4. Finite termination at exactly ceil(|x0 - m| / eta) steps, and no earlier.
  5. Even samples: the minimizer set is exactly the central closed interval;
     interval descent conserves the metric projection and halts on it.
  6. Perturbed descent: the bound max(eps, |u0-m| - n(eta-eps)) and the
     attained saturation radius eps.
  7. Separable multi-parameter models: coordinatewise medians, and the
     even-sample minimizer BOX; termination in max_i of coordinate times.
  8. Exact ReLU widths: 2 units realize the scalar clipped update, 4 units
     realize the interval update, and the discrete curvature test detects
     the corresponding numbers of kinks.

Run with:  python3 demo.py
No dependencies beyond the Python standard library.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. Tropical L1 loss
# ----------------------------------------------------------------------------


def l1_loss(xs: Sequence[float], theta: float) -> float:
    """Tropical L1 empirical loss L(theta) = sum_i |theta - x_i|."""
    return sum(abs(theta - x) for x in xs)


def block_imbalance(xs: Sequence[float], pivot: float) -> int:
    """(# samples <= pivot) - (# samples > pivot): the local growth rate to the right."""
    low = sum(1 for x in xs if x <= pivot)
    return low - (len(xs) - low)


def median_lo_hi(xs: Sequence[float]) -> Tuple[float, float]:
    """Endpoints [lo, hi] of the exact minimizer set of the tropical L1 loss.

    Odd size 2k+1 -> lo = hi = x_k (a point).
    Even size 2k+2 -> [x_k, x_{k+1}] (a segment, possibly degenerate).
    """
    s = sorted(xs)
    n = len(s)
    if n % 2 == 1:
        k = (n - 1) // 2
        return s[k], s[k]
    k = n // 2 - 1
    return s[k], s[k + 1]


# ----------------------------------------------------------------------------
# 2. The clipped tropical update (the flow) and interval descent
# ----------------------------------------------------------------------------


def tropical_flow(m: float, t: float, x: float) -> float:
    """Clipped update: move x by t toward m, stopping at m."""
    if x < m:
        return min(m, x + t)
    return max(m, x - t)


def proj_icc(lo: float, hi: float, theta: float) -> float:
    """Metric projection of theta onto [lo, hi]."""
    return max(lo, min(hi, theta))


def interval_step(lo: float, hi: float, eta: float, theta: float) -> float:
    """One clipped subgradient step of size eta toward the interval [lo, hi]."""
    return tropical_flow(proj_icc(lo, hi, theta), eta, theta)


def iterate(f: Callable[[float], float], n: int, x: float) -> float:
    """n-fold iterate of a scalar map."""
    for _ in range(n):
        x = f(x)
    return x


def stopping_time(x0: float, target: float, eta: float) -> int:
    """Exact number of clipped steps of size eta needed to reach the target."""
    return math.ceil(abs(x0 - target) / eta)


# ----------------------------------------------------------------------------
# 3. ReLU networks
# ----------------------------------------------------------------------------


def relu(x: float) -> float:
    return max(x, 0.0)


def relu_net(
    a: Sequence[float], b: Sequence[float], c: Sequence[float], p: float, q: float, x: float
) -> float:
    """Width-k rectified network with an affine skip: sum_j a_j relu(b_j x + c_j) + p x + q."""
    return sum(aj * relu(bj * x + cj) for aj, bj, cj in zip(a, b, c)) + p * x + q


def second_difference(f: Callable[[float], float], x: float, h: float) -> float:
    """Discrete curvature test D_h f(x) = f(x+h) + f(x-h) - 2 f(x)."""
    return f(x + h) + f(x - h) - 2.0 * f(x)


def count_curvature_sites(
    f: Callable[[float], float], lo: float, hi: float, h: float, tol: float = 1e-9
) -> int:
    """Count well-separated points in [lo, hi] with nonvanishing radius-h curvature.

    Sites closer than 2h are merged, matching the window-separation lemma: two
    windows of radius h that share a rectified unit must have centers < 2h apart.
    """
    grid = [lo + i * (hi - lo) / 4000.0 for i in range(4001)]
    hits = [x for x in grid if abs(second_difference(f, x, h)) > tol]
    sites: List[float] = []
    for x in hits:
        if not sites or x - sites[-1] >= 2.0 * h:
            sites.append(x)
    return len(sites)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

BAR = "=" * 78


def demo_counting_mechanism() -> None:
    print(BAR)
    print("1. THE COUNTING MECHANISM: loss slope = block imbalance")
    print(BAR)
    xs = [-3.0, -1.0, 0.0, 4.0, 9.0]
    print(f"sample x = {xs}")
    print("  slab           slope (measured)   imbalance (counted)")
    slabs = [(-5.0, -3.0), (-3.0, -1.0), (-1.0, 0.0), (0.0, 4.0), (4.0, 9.0), (9.0, 11.0)]
    for p, t in slabs:
        mid = 0.5 * (p + t)
        slope = (l1_loss(xs, t) - l1_loss(xs, p)) / (t - p)
        print(f"  [{p:5.1f},{t:5.1f}]      {slope:+6.1f}            {block_imbalance(xs, mid):+3d}")
    print("  -> measured slope equals the counted imbalance on every slab.\n")


def demo_odd_median() -> None:
    print(BAR)
    print("2. ODD SAMPLES: unique median minimizer and linear growth")
    print(BAR)
    xs = [-3.0, -1.0, 0.0, 4.0, 9.0]
    m = median_lo_hi(xs)[0]
    print(f"sample {xs},  median m = {m}")
    print(f"  L(m)  = {l1_loss(xs, m)}   L(1) = {l1_loss(xs, 1.0)}   L(-1) = {l1_loss(xs, -1.0)}")
    worst = 0.0
    for i in range(-500, 501):
        t = i / 25.0
        slack = l1_loss(xs, t) - (l1_loss(xs, m) + abs(t - m))
        worst = min(worst, slack)
    print(f"  min over a fine grid of  L(t) - [L(m) + |t-m|]  = {worst:.12f}  (>= 0, attained)")
    print("  -> L(m) + |t - m| <= L(t): the median is the unique minimizer.\n")


def demo_semigroup_and_termination() -> None:
    print(BAR)
    print("3-4. SEMIGROUP LAW, EXACT DISTANCE LAW, FINITE TERMINATION")
    print(BAR)
    m, eta, x0 = 0.0, 2.0, 5.0
    print(f"target m = {m}, step eta = {eta}, initialization x0 = {x0}")

    err = max(
        abs(tropical_flow(m, s, tropical_flow(m, t, x)) - tropical_flow(m, t + s, x))
        for x in [-7.3, -1.0, 0.0, 0.5, 4.4, 11.0]
        for t in [0.0, 0.7, 3.0]
        for s in [0.0, 1.1, 5.0]
    )
    print(f"  semigroup law   max |Phi_s(Phi_t(x)) - Phi_(t+s)(x)| = {err:.1e}")

    err2 = max(
        abs(abs(iterate(lambda z: tropical_flow(m, eta, z), n, x0) - m)
            - max(0.0, abs(x0 - m) - n * eta))
        for n in range(8)
    )
    print(f"  distance law    max |iterate dist - max(0,|x0-m|-n*eta)| = {err2:.1e}")

    traj = [x0]
    for _ in range(5):
        traj.append(tropical_flow(m, eta, traj[-1]))
    print(f"  trajectory      {traj}")
    N = stopping_time(x0, m, eta)
    reached = [n for n in range(10) if iterate(lambda z: tropical_flow(m, eta, z), n, x0) == m]
    print(f"  predicted stopping time ceil(|x0-m|/eta) = {N};  first n with iterate = m: {reached[0]}")
    print("  -> termination happens exactly at the predicted step, never earlier.\n")


def demo_excess_risk() -> None:
    print(BAR)
    print("5. EXCESS EMPIRICAL RISK ALONG THE TRAJECTORY")
    print(BAR)
    xs = [-3.0, -1.0, 0.0, 4.0, 9.0]
    m, eta, x0 = 0.0, 2.0, 5.0
    print("   n   theta_n   excess risk   bound n_samples*max(0,|x0-m|-n*eta)")
    for n in range(5):
        th = iterate(lambda z: tropical_flow(m, eta, z), n, x0)
        excess = l1_loss(xs, th) - l1_loss(xs, m)
        bound = len(xs) * max(0.0, abs(x0 - m) - n * eta)
        flag = "ok" if -1e-12 <= excess <= bound + 1e-12 else "VIOLATED"
        print(f"  {n:2d}   {th:7.2f}   {excess:11.4f}   {bound:11.4f}   {flag}")
    print()


def demo_even_interval() -> None:
    print(BAR)
    print("6. EVEN SAMPLES: the minimizer set is exactly the central interval")
    print(BAR)
    xs = [-3.0, -1.0, 2.0, 5.0]
    lo, hi = median_lo_hi(xs)
    print(f"sample {xs},  predicted minimizer set = [{lo}, {hi}]")
    inside = {round(l1_loss(xs, lo + i * (hi - lo) / 20.0), 10) for i in range(21)}
    print(f"  loss values on the interval: {inside}  (constant)")
    print(f"  L(3) = {l1_loss(xs, 3.0)} = {l1_loss(xs, hi)} + 2*(3 - {hi})  (slope 2 outside)")
    print(f"  L(-2) = {l1_loss(xs, -2.0)} = {l1_loss(xs, lo)} + 2*({lo} - (-2))")

    eta = 0.75
    for theta0 in (-6.0, 0.5, 7.0):
        pi = proj_icc(lo, hi, theta0)
        N = stopping_time(theta0, pi, eta)
        step = lambda z: interval_step(lo, hi, eta, z)
        after = iterate(step, N, theta0)
        far = iterate(step, N + 25, theta0)
        msg = (
            f"  start {theta0:5.2f}: projection {pi:5.2f}, predicted N = {N}, "
            f"iterate_{N} = {after:6.3f}, iterate_{N+25} = {far:6.3f}"
        )
        if N > 0:
            msg += f", iterate_{N-1} = {iterate(step, N - 1, theta0):6.3f} (not yet optimal)"
        print(msg)
    print("  -> descent halts exactly on the nearest optimal point (initialization selects it).\n")


def demo_perturbed() -> None:
    print(BAR)
    print("7. PERTURBED DESCENT: bound max(eps, |u0-m| - n(eta-eps)), radius eps attained")
    print(BAR)
    random.seed(20260809)
    m, eta, eps, u0 = 0.0, 1.0, 0.3, 9.0
    u = u0
    print("   n     u_n     |u_n - m|   bound max(eps, |u0-m|-n(eta-eps))")
    worst_violation = -1.0
    for n in range(16):
        bound = max(eps, abs(u0 - m) - n * (eta - eps))
        worst_violation = max(worst_violation, abs(u - m) - bound)
        if n < 8 or n % 4 == 0:
            print(f"  {n:3d}  {u:7.3f}   {abs(u - m):9.4f}   {bound:9.4f}")
        u = tropical_flow(m, eta, u) + random.uniform(-eps, eps)
    print(f"  maximal violation of the bound over the run: {worst_violation:.2e} (<= 0)")

    stuck = m + eps
    dev = abs(stuck - tropical_flow(m, eta, stuck))
    print(f"  attainment: u_n == m + eps == {stuck} forever; per-step deviation {dev} = eps")
    print("  -> the saturation radius eps is achieved; it cannot be replaced by 0.\n")


def demo_box() -> None:
    print(BAR)
    print("8. SEPARABLE MULTI-PARAMETER MODELS: the minimizer BOX")
    print(BAR)
    samples: List[List[float]] = [[-3.0, -1.0, 2.0, 5.0], [0.0, 1.0, 1.0, 4.0]]
    corners = [median_lo_hi(s) for s in samples]
    print(f"coordinate samples: {samples}")
    print(f"  minimizer box = " + " x ".join(f"[{lo}, {hi}]" for lo, hi in corners))

    def box_loss(theta: Sequence[float]) -> float:
        return sum(l1_loss(s, t) for s, t in zip(samples, theta))

    opt = [proj_icc(lo, hi, 0.0) for lo, hi in corners]
    best = box_loss(opt)
    worst_gap = 0.0
    for _ in range(20000):
        cand = [random.uniform(-8.0, 8.0) for _ in corners]
        worst_gap = min(worst_gap, box_loss(cand) - best)
    print(f"  random search over 20000 points: min(loss - box optimum) = {worst_gap:.6f} (>= 0)")

    eta = 0.6
    theta0 = [7.5, -4.25]
    times = [stopping_time(t, proj_icc(lo, hi, t), eta) for t, (lo, hi) in zip(theta0, corners)]
    N = max(times)
    theta = list(theta0)
    for _ in range(N):
        theta = [interval_step(lo, hi, eta, t) for t, (lo, hi) in zip(theta, corners)]
    target = [proj_icc(lo, hi, t) for t, (lo, hi) in zip(theta0, corners)]
    print(f"  start {theta0}: coordinate times {times}, predicted N = max = {N}")
    print(f"  iterate_N = {[round(t, 10) for t in theta]}, projection onto box = {target}")
    print("  -> the slowest coordinate sets the clock; the box projection is reached exactly.\n")


def demo_relu_width() -> None:
    print(BAR)
    print("9. EXACT ReLU WIDTHS: 2 for a point optimum, 4 for a segment optimum")
    print(BAR)
    m, t = 1.5, 0.8
    err2 = max(
        abs(tropical_flow(m, t, x) - (m + relu(x - m - t) - relu(m - x - t)))
        for x in [m + i / 37.0 for i in range(-200, 201)]
    )
    print(f"  scalar update = 2 units:  max error {err2:.1e}")
    net2 = lambda x: relu_net([1.0, -1.0], [1.0, -1.0], [-(m + t), m - t], 0.0, m, x)
    err2b = max(abs(tropical_flow(m, t, x) - net2(x)) for x in [m + i / 37.0 for i in range(-200, 201)])
    print(f"  ... in network form with an affine skip: max error {err2b:.1e}")

    lo, hi, eta = -1.0, 2.0, 0.75
    def four(theta: float) -> float:
        return (theta + eta - relu(theta - (lo - eta)) + relu(theta - lo)
                - relu(theta - hi) + relu(theta - (hi + eta)))
    err4 = max(
        abs(interval_step(lo, hi, eta, th) - four(th))
        for th in [-8.0 + i / 29.0 for i in range(0, 500)]
    )
    print(f"  interval update = 4 units: max error {err4:.1e}")
    net4 = lambda th: relu_net(
        [-1.0, 1.0, -1.0, 1.0], [1.0, 1.0, 1.0, 1.0],
        [eta - lo, -lo, -hi, -(hi + eta)], 1.0, eta, th)
    err4b = max(
        abs(interval_step(lo, hi, eta, th) - net4(th))
        for th in [-8.0 + i / 29.0 for i in range(0, 500)]
    )
    print(f"  ... in network form with an affine skip: max error {err4b:.1e}")

    h_scalar = t / 2.0
    n_scalar = count_curvature_sites(lambda x: tropical_flow(m, t, x), m - 5.0, m + 5.0, h_scalar)
    h_int = min(eta, hi - lo) / 2.0
    n_int = count_curvature_sites(lambda th: interval_step(lo, hi, eta, th), lo - 5.0, hi + 5.0, h_int)
    print(f"  curvature sites detected (window radius {h_scalar}): scalar update -> {n_scalar}")
    print(f"  curvature sites detected (window radius {h_int}): interval update -> {n_int}")
    print("  -> kink counting reproduces the width dichotomy 2 (point) vs 4 (segment).")

    print("  a single rectified unit cannot match the scalar update; best fits over a grid:")
    best_err = float("inf")
    for a in [-2.0, -1.0, -0.5, 0.5, 1.0, 2.0]:
        for b in [-2.0, -1.0, 1.0, 2.0]:
            for c in [-2.0, -1.0, 0.0, 1.0, 2.0]:
                for e in [-1.0, 0.0, m, m + t]:
                    err = max(
                        abs(a * relu(b * x + c) + e - tropical_flow(m, t, x))
                        for x in [m - 2 * t, m - t, m, m + t, m + 2 * t]
                    )
                    best_err = min(best_err, err)
    print(f"     minimal sup-error over the parameter grid: {best_err:.4f} (bounded away from 0)\n")


def main() -> None:
    demo_counting_mechanism()
    demo_odd_median()
    demo_semigroup_and_termination()
    demo_excess_risk()
    demo_even_interval()
    demo_perturbed()
    demo_box()
    demo_relu_width()
    print(BAR)
    print("All demonstrations completed.")
    print(BAR)


if __name__ == "__main__":
    main()
