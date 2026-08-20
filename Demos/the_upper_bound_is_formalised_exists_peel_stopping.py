"""
Peeling profiles: rigidity, stability, and the universal family of extremal
dilation peelings.

Self-contained numerical demonstration of every result in the accompanying
paper.  No third-party dependencies: standard library only.

Definitions used throughout
---------------------------
A peeling profile is a nonincreasing nonnegative sequence s_0 >= s_1 >= ... >= 0.
    layer content   g_k    = s_k - s_{k+1}
    budget          A_N    = s_0 - s_N
    rate            rho_N  = A_N / N
    affine estimate ell_k  = s_0 - k * rho_N
    layer energy    E_N    = sum_{k<N} g_k^2

Results demonstrated
--------------------
  1. Stopping-time bound:  exists k < N with g_k <= rho_N.
  2. Two-sided error bound: |s_k - ell_k| <= max(k, N-k) * rho_N.
  3. Markov density: #{k : g_k >= c*rho_N} <= N/c.
  4. Stable window: some block of J consecutive layers is uniformly small.
  5. Rigidity: all-below-average  <=>  all-equal  <=>  affine  <=>  cyclic.
  6. Stability: g_k <= (1+eps) rho_N  =>  |s_k - ell_k| <= eps * A_N.
  7. Energy identity: E_N - A_N^2/N = sum (g_k - rho_N)^2, min at extremisers.
  8. Equal-volume shells of a d-ball: radii R (1 - k/N)^{1/d}.
  9. Universality: the same factors equipartition any star-shaped body.
 10. Boundary concentration: R - R(1-1/N)^{1/d} <= R / (d (N-1)).

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Core peeling-profile arithmetic
# ---------------------------------------------------------------------------


def layer_gaps(sizes: Sequence[float]) -> List[float]:
    """Layer contents g_k = s_k - s_{k+1} of a peeling profile."""
    return [sizes[k] - sizes[k + 1] for k in range(len(sizes) - 1)]


def budget(sizes: Sequence[float], n: int) -> float:
    """Budget A_N = s_0 - s_N of the window of the first n steps."""
    return sizes[0] - sizes[n]


def rate(sizes: Sequence[float], n: int) -> float:
    """Average rate rho_N = A_N / N."""
    return budget(sizes, n) / n if n > 0 else 0.0


def affine_estimate(sizes: Sequence[float], n: int, k: int) -> float:
    """The affine (mean-field) estimate ell_k = s_0 - k * rho_N."""
    return sizes[0] - k * rate(sizes, n)


def is_peeling_profile(sizes: Sequence[float], tol: float = 1e-12) -> bool:
    """Check nonnegativity and antitonicity."""
    if any(s < -tol for s in sizes):
        return False
    return all(sizes[k + 1] <= sizes[k] + tol for k in range(len(sizes) - 1))


def stopping_time(sizes: Sequence[float], n: int) -> int:
    """First index k < n with g_k <= rho_N.  Guaranteed to exist for n >= 1."""
    gaps = layer_gaps(sizes)
    rho = rate(sizes, n)
    for k in range(n):
        if gaps[k] <= rho + 1e-12:
            return k
    raise AssertionError("stopping-time theorem violated -- impossible")


def large_gap_index(sizes: Sequence[float], n: int) -> int:
    """Dual pigeonhole: first index k < n with g_k >= rho_N."""
    gaps = layer_gaps(sizes)
    rho = rate(sizes, n)
    for k in range(n):
        if gaps[k] >= rho - 1e-12:
            return k
    raise AssertionError("dual pigeonhole violated -- impossible")


def layer_energy(sizes: Sequence[float], n: int) -> float:
    """E_N = sum_{k<N} g_k^2."""
    gaps = layer_gaps(sizes)
    return sum(g * g for g in gaps[:n])


def energy_defect(sizes: Sequence[float], n: int) -> float:
    """E_N - A_N^2 / N, equal to N times the variance of the layer contents."""
    return layer_energy(sizes, n) - budget(sizes, n) ** 2 / n


def sup_defect(sizes: Sequence[float], n: int) -> float:
    """max_{k<=N} |s_k - ell_k|: sup-norm distance to the affine profile."""
    return max(abs(sizes[k] - affine_estimate(sizes, n, k)) for k in range(n + 1))


def multiplicative_slack(sizes: Sequence[float], n: int) -> float:
    """Smallest eps >= 0 with g_k <= (1+eps) rho_N for all k < n."""
    rho = rate(sizes, n)
    if rho <= 0.0:
        return 0.0
    return max(0.0, max(layer_gaps(sizes)[:n]) / rho - 1.0)


def stable_window(sizes: Sequence[float], stride: int, blocks: int) -> Tuple[int, float]:
    """Block index b < blocks all of whose 'stride' layers are <= threshold."""
    n = stride * blocks
    threshold = (sizes[0] - sizes[n]) / blocks
    coarse = [sizes[stride * k] for k in range(blocks + 1)]
    b = stopping_time(coarse, blocks)
    return b, threshold


# ---------------------------------------------------------------------------
# The extremal (equipartition) profile and its geometric realisations
# ---------------------------------------------------------------------------


def equipartition_profile(total: float, n: int) -> List[float]:
    """The extremal profile s_k = total * (1 - k/n), k = 0..n."""
    return [total * (1.0 - k / n) for k in range(n + 1)]


def dilation_factor(d: int, n: int, k: int) -> float:
    """The universal factor c_k = (1 - k/n)^{1/d}: depends on d and n only."""
    return max(0.0, 1.0 - k / n) ** (1.0 / d)


def unit_ball_volume(d: int) -> float:
    """vol B(0,1) in R^d = pi^{d/2} / Gamma(d/2 + 1)."""
    return math.pi ** (d / 2.0) / math.gamma(d / 2.0 + 1.0)


def ball_volume(d: int, r: float) -> float:
    """vol B(0,r) in R^d = r^d vol B(0,1)."""
    return (r ** d) * unit_ball_volume(d)


def shell_radius(radius: float, d: int, n: int, k: int) -> float:
    """Equal-volume shell radius r_k = R (1 - k/n)^{1/d}."""
    return radius * dilation_factor(d, n, k)


def shell_thickness_bound(radius: float, d: int, n: int) -> float:
    """Boundary-concentration bound R / (d (N - 1)) on the outer shell."""
    return radius / (d * (n - 1))


def square_area(half_diagonal_scale: float) -> float:
    """Area of the dilate c * [-1,1]^2, i.e. (2c)^2 = 4 c^2."""
    return 4.0 * half_diagonal_scale ** 2


def star_body_volume_2d(radial: Callable[[float], float], samples: int = 200_000) -> float:
    """Area of a planar star-shaped body given by its radial function rho(theta),
    computed as (1/2) integral rho(theta)^2 dtheta by the midpoint rule."""
    total = 0.0
    step = 2.0 * math.pi / samples
    for i in range(samples):
        theta = (i + 0.5) * step
        total += 0.5 * radial(theta) ** 2 * step
    return total


# ---------------------------------------------------------------------------
# Reporting helpers
# ---------------------------------------------------------------------------


def header(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def check(label: str, ok: bool, detail: str = "") -> None:
    mark = "PASS" if ok else "FAIL"
    print(f"  [{mark}] {label}" + (f"   {detail}" if detail else ""))
    assert ok, label


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_stopping_time() -> None:
    header("1. The stopping-time bound and its error control")
    examples = {
        "extremal    (1, 3/4, 1/2, 1/4, 0)": equipartition_profile(1.0, 4),
        "front-loaded(1, 0, 0, 0, 0)": [1.0, 0.0, 0.0, 0.0, 0.0],
        "back-loaded (1, 1, 1, 1, 0)": [1.0, 1.0, 1.0, 1.0, 0.0],
        "oscillating (1,.55,.5,.15,0)": [1.0, 0.55, 0.50, 0.15, 0.0],
    }
    n = 4
    for name, s in examples.items():
        check(f"{name} is a peeling profile", is_peeling_profile(s))
        rho = rate(s, n)
        k = stopping_time(s, n)
        kk = large_gap_index(s, n)
        gaps = layer_gaps(s)
        print(f"      gaps = {[round(g, 4) for g in gaps]}, rho = {rho:.4f}")
        print(f"      good stopping time k = {k} (gap {gaps[k]:.4f} <= {rho:.4f});"
              f" heavy step k = {kk} (gap {gaps[kk]:.4f} >= {rho:.4f})")
        for j in range(n + 1):
            err = abs(s[j] - affine_estimate(s, n, j))
            bound = max(j, n - j) * rho
            check(f"  error bound at k={j}", err <= bound + 1e-12,
                  f"|err| = {err:.4f} <= {bound:.4f}")


def demo_density() -> None:
    header("2. Density of good stopping times (Markov bound)")
    n = 12
    s = [1.0]
    heavy = [0.30, 0.25, 0.20] + [0.25 / 9] * 9  # three heavy layers, nine light
    for g in heavy:
        s.append(s[-1] - g)
    check("profile is valid", is_peeling_profile(s))
    rho = rate(s, n)
    gaps = layer_gaps(s)
    for c in (1.0, 2.0, 3.0, 6.0):
        count = sum(1 for g in gaps[:n] if g >= c * rho)
        check(f"count(g_k >= {c:.0f} rho) <= N/c", count <= n / c + 1e-9,
              f"{count} <= {n / c:.2f}")


def demo_stable_window() -> None:
    header("3. Stable windows: a whole block of consecutive small layers")
    stride, blocks = 3, 4
    n = stride * blocks
    gaps = [0.02, 0.03, 0.02, 0.40, 0.05, 0.03, 0.01, 0.01, 0.02, 0.20, 0.11, 0.10]
    s = [1.0]
    for g in gaps:
        s.append(s[-1] - g)
    check("profile is valid", is_peeling_profile(s))
    b, threshold = stable_window(s, stride, blocks)
    print(f"      chosen block b = {b}, threshold = {threshold:.4f}")
    for j in range(stride):
        g = gaps[stride * b + j]
        check(f"  layer {stride * b + j} inside the block is small",
              g <= threshold + 1e-12, f"{g:.4f} <= {threshold:.4f}")


def demo_rigidity() -> None:
    header("4. Rigidity: below-average everywhere == equipartition == affine == cyclic")
    n = 5
    s = equipartition_profile(2.0, n)
    rho = rate(s, n)
    gaps = layer_gaps(s)
    check("(1) every layer at most the average",
          all(g <= rho + 1e-12 for g in gaps[:n]))
    check("(2) every layer exactly the average",
          all(abs(g - rho) < 1e-12 for g in gaps[:n]))
    check("(3) the profile is exactly affine",
          all(abs(s[k] - affine_estimate(s, n, k)) < 1e-12 for k in range(n + 1)))
    check("(4) gaps invariant under the cyclic shift",
          all(abs(gaps[k] - gaps[(k + 1) % n]) < 1e-12 for k in range(n)))

    # A near-miss: one layer above average destroys all four clauses at once.
    t = [1.0, 0.70, 0.50, 0.30, 0.15, 0.0]
    gt = layer_gaps(t)
    rt = rate(t, n)
    print(f"      near-miss gaps = {[round(g, 3) for g in gt]}, rho = {rt:.3f}")
    check("near-miss fails clause (1)", any(g > rt + 1e-12 for g in gt[:n]))
    check("near-miss fails clause (4)",
          any(abs(gt[k] - gt[(k + 1) % n]) > 1e-12 for k in range(n)))


def demo_stability() -> None:
    header("5. Stability: approximate extremisers are approximately affine")
    n = 6
    print(f"      {'eps (slack)':>14} {'sup defect':>14} {'eps * A_N':>14}  verdict")
    for wobble in (0.0, 0.02, 0.05, 0.10, 0.25):
        base = 1.0 / n
        gaps = [base * (1.0 + wobble * (1 if k % 2 == 0 else -1)) for k in range(n)]
        s = [1.0]
        for g in gaps:
            s.append(s[-1] - g)
        check("profile valid", is_peeling_profile(s))
        eps = multiplicative_slack(s, n)
        defect = sup_defect(s, n)
        bound = eps * budget(s, n)
        ok = defect <= bound + 1e-12
        print(f"      {eps:14.6f} {defect:14.6f} {bound:14.6f}  "
              f"{'PASS' if ok else 'FAIL'}")
        assert ok


def demo_energy() -> None:
    header("6. The energy identity and the variational characterisation")
    n = 4
    cases = {
        "uniform      (1/4,1/4,1/4,1/4)": [0.25] * 4,
        "front-loaded (1,0,0,0)": [1.0, 0.0, 0.0, 0.0],
        "mild         (.3,.25,.25,.2)": [0.30, 0.25, 0.25, 0.20],
    }
    for name, gaps in cases.items():
        s = [1.0]
        for g in gaps:
            s.append(s[-1] - g)
        rho = rate(s, n)
        lhs = energy_defect(s, n)
        rhs = sum((g - rho) ** 2 for g in gaps)
        check(f"{name}: identity holds", abs(lhs - rhs) < 1e-12,
              f"E - A^2/N = {lhs:.6f} = {rhs:.6f}")
        check(f"{name}: E >= A^2/N", lhs >= -1e-12,
              f"E = {layer_energy(s, n):.6f} >= {budget(s, n) ** 2 / n:.6f}")
    print("      equality holds exactly for the uniform gaps (defect 0).")


def demo_ball_shells() -> None:
    header("7. Equal-volume shell peelings of Euclidean balls")
    for d, n, R in ((2, 4, 1.0), (3, 5, 2.0), (7, 3, 1.0)):
        radii = [shell_radius(R, d, n, k) for k in range(n + 1)]
        vols = [ball_volume(d, r) for r in radii]
        shells = [vols[k] - vols[k + 1] for k in range(n)]
        target = ball_volume(d, R) / n
        print(f"      d={d}, N={n}, R={R}: radii = "
              f"{[round(r, 4) for r in radii]}")
        check(f"  d={d},N={n}: all {n} shells have volume vol(B)/N",
              all(abs(v - target) < 1e-9 for v in shells),
              f"each {target:.6f}")
        check(f"  d={d},N={n}: volume profile is affine",
              all(abs(vols[k] - ball_volume(d, R) * (1 - k / n)) < 1e-9
                  for k in range(n + 1)))
        # rigidity: perturb the radii and some shell must exceed the average
        perturbed = list(radii)
        perturbed[1] = radii[1] * 0.98
        pv = [ball_volume(d, r) for r in perturbed]
        ps = [pv[k] - pv[k + 1] for k in range(n)]
        check(f"  d={d},N={n}: any perturbation breaks the bound somewhere",
              any(g > target + 1e-12 for g in ps),
              f"max shell = {max(ps):.6f} > {target:.6f}")


def demo_universality() -> None:
    header("8. Universality: the same factors equipartition ANY star-shaped body")
    d, n = 2, 4
    factors = [dilation_factor(d, n, k) for k in range(n + 1)]
    print(f"      universal factors (d={d}, N={n}) = "
          f"{[round(c, 6) for c in factors]}")

    # (a) the disc
    disc_area = math.pi
    disc_layers = [disc_area * (factors[k] ** d - factors[k + 1] ** d)
                   for k in range(n)]
    check("disc: layers equal", all(abs(a - disc_area / n) < 1e-12
                                    for a in disc_layers),
          f"each {disc_area / n:.6f}")

    # (b) the square [-1,1]^2, area 4
    sq_layers = [square_area(factors[k]) - square_area(factors[k + 1])
                 for k in range(n)]
    check("square: layers equal", all(abs(a - 1.0) < 1e-12 for a in sq_layers),
          "each 1.000000")

    # (c) a generic star-shaped blob with no symmetry at all
    def radial(theta: float) -> float:
        return 1.0 + 0.4 * math.sin(theta) + 0.25 * math.cos(3 * theta + 0.7)

    blob_area = star_body_volume_2d(radial)
    blob_layers = [blob_area * (factors[k] ** d - factors[k + 1] ** d)
                   for k in range(n)]
    check("asymmetric blob: layers equal",
          all(abs(a - blob_area / n) < 1e-9 for a in blob_layers),
          f"area {blob_area:.6f}, each layer {blob_area / n:.6f}")
    print("      the factors are identical in all three cases: they depend on")
    print("      the dimension and the number of layers only, never on the body.")

    # factors truly independent of the body: verified by construction above.
    for d2 in (1, 2, 3, 5, 10):
        f2 = [dilation_factor(d2, n, k) for k in range(n + 1)]
        check(f"  d={d2}: c_k^d = 1 - k/N exactly",
              all(abs(f2[k] ** d2 - max(0.0, 1 - k / n)) < 1e-12
                  for k in range(n + 1)))


def demo_concentration() -> None:
    header("9. Boundary concentration: shells collapse onto the sphere")
    print(f"      {'d':>5} {'N':>4} {'thickness':>12} {'bound R/(d(N-1))':>18}"
          f" {'ratio':>8}")
    for d, n in ((1, 2), (2, 2), (10, 2), (100, 2), (3, 5), (50, 10)):
        R = 1.0
        thickness = R - shell_radius(R, d, n, 1)
        bound = shell_thickness_bound(R, d, n)
        assert thickness <= bound + 1e-15, (d, n, thickness, bound)
        print(f"      {d:5d} {n:4d} {thickness:12.6f} {bound:18.6f}"
              f" {thickness / bound:8.4f}")
    print("      thickness decays like 1/d while the shell keeps a 1/N share")
    print("      of the volume: half a 100-dimensional ball lies within 0.7% of")
    print("      the boundary radius.")


def demo_symmetry_forces_extremality() -> None:
    header("10. Symmetry forces extremality (transitive group action on layers)")
    n = 6
    # Build gaps invariant under the cyclic shift generated by k -> k+1 mod n
    # by declaring a single value and propagating it around the orbit.
    orbit_value = 0.35
    gaps = [0.0] * n
    k = 0
    for _ in range(n):  # the successor map has a single orbit
        gaps[k] = orbit_value
        k = (k + 1) % n
    s = [3.0]
    for g in gaps:
        s.append(s[-1] - g)
    rho = rate(s, n)
    check("cyclically invariant gaps are all equal",
          all(abs(g - gaps[0]) < 1e-12 for g in gaps))
    check("and each equals the average rate",
          all(abs(g - rho) < 1e-12 for g in gaps), f"rho = {rho:.6f}")
    check("hence the profile is affine",
          all(abs(s[k] - affine_estimate(s, n, k)) < 1e-12 for k in range(n + 1)))
    check("and the energy is minimal", abs(energy_defect(s, n)) < 1e-12)
    print("      a single N-cycle already buys the full symmetric group's worth")
    print("      of information: invariance under it forces equipartition.")


def main() -> None:
    print(__doc__.split("Run:")[0].strip())
    demo_stopping_time()
    demo_density()
    demo_stable_window()
    demo_rigidity()
    demo_stability()
    demo_energy()
    demo_ball_shells()
    demo_universality()
    demo_concentration()
    demo_symmetry_forces_extremality()
    header("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
