"""
Thin-Shell Counting under a Thickness Budget — numerical demonstrations.

Setting
-------
The equal-volume peeling of the ball B(0, R) in R^d into N shells is the family of
radii

    r_k = R (1 - k/N)^{1/d},    k = 0, 1, ..., N,

so that r_0 = R, r_N = 0, and each of the N shells {r_{k+1} <= |x| <= r_k} carries
exactly a 1/N fraction of the volume of the ball.  The k-th shell has *geometric
thickness*

    t_k = r_k - r_{k+1}.

Fix a thickness budget delta > 0.  A shell is called *thick* if t_k > delta, and

    T(R, d, N, delta) = #{ k < N : t_k > delta }.

This script verifies, numerically, all the quantitative statements of the theory:

  1. two-sided per-shell bounds        R/(dN) <= t_k <= R/(d(N-k-1))
  2. monotonicity: thicknesses increase towards the centre, so the thick shells
     form a terminal block [k0, N)
  3. innermost shell is the thickest, with t_{N-1} = R N^{-1/d} exactly
  4. all shells thin  <=>  N >= (R/delta)^d ; least admissible N = ceil((R/delta)^d)
  5. uniform counting bound            T <= 1 + R/(d delta)
  6. sharpness: sup over N of T is Theta(R/(d delta))
  7. decay in N: if T >= 2 then (T-1)^{d-1} N <= (R/(d delta))^d
  8. pinning: T is determined to within one by (R/(d delta))^d / N
  9. bit cost: log2 of the least admissible N lies in [d log2(R/delta), +1]
 10. refutation of the conjecture T = O(d log(R/delta))

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import List, Tuple


# ----------------------------------------------------------------------------- core
def shell_radius(R: float, d: int, N: int, k: int) -> float:
    """Radius of the k-th sphere of the equal-volume peeling: R (1 - k/N)^{1/d}."""
    base = max(0.0, 1.0 - k / N)
    return R * base ** (1.0 / d)


def shell_thickness(R: float, d: int, N: int, k: int) -> float:
    """Geometric thickness t_k = r_k - r_{k+1} of the k-th shell."""
    return shell_radius(R, d, N, k) - shell_radius(R, d, N, k + 1)


def thickness_profile(R: float, d: int, N: int) -> List[float]:
    """All N thicknesses, from the outermost shell (k = 0) inwards."""
    return [shell_thickness(R, d, N, k) for k in range(N)]


def thick_count(R: float, d: int, N: int, delta: float) -> int:
    """Number of shells whose thickness exceeds the budget delta."""
    return sum(1 for k in range(N) if shell_thickness(R, d, N, k) > delta)


def least_thin_N(R: float, d: int, delta: float) -> int:
    """Least N such that every shell of the N-shell peeling is at most delta thick."""
    return max(1, math.ceil((R / delta) ** d))


# ------------------------------------------------------------------- demonstrations
def demo_two_sided_bounds(R: float = 1.0, d: int = 4, N: int = 12) -> None:
    print(f"\n[1] Two-sided per-shell bounds   (R={R}, d={d}, N={N})")
    print("     k        t_k      R/(dN)   R/(d(N-k-1))")
    lower = R / (d * N)
    for k in range(N):
        t = shell_thickness(R, d, N, k)
        upper = R / (d * (N - k - 1)) if k + 1 < N else float("inf")
        ok = lower <= t + 1e-12 and t <= upper + 1e-12
        assert ok, (k, t, lower, upper)
        up_s = f"{upper:10.6f}" if math.isfinite(upper) else "       inf"
        print(f"  {k:4d} {t:10.6f} {lower:10.6f} {up_s}")
    print("     all shells satisfy R/(dN) <= t_k <= R/(d(N-k-1)):  OK")


def demo_monotone_and_innermost(R: float = 1.0, d: int = 5, N: int = 30) -> None:
    print(f"\n[2] Monotonicity inwards and the innermost shell (R={R}, d={d}, N={N})")
    ts = thickness_profile(R, d, N)
    assert all(ts[k] <= ts[k + 1] + 1e-12 for k in range(N - 1))
    print("     t_0 <= t_1 <= ... <= t_{N-1}:  OK  (thick shells form a terminal block)")
    exact = R * N ** (-1.0 / d)
    print(f"     t_(N-1) = {ts[-1]:.10f}   R N^(-1/d) = {exact:.10f}")
    assert abs(ts[-1] - exact) < 1e-12


def demo_threshold(R: float = 1.0) -> None:
    print("\n[3] Exact thin-shell threshold:  all shells thin  <=>  N >= (R/delta)^d")
    print("      d   delta    (R/delta)^d   least admissible N   brute-force N")
    for d, delta in [(3, 0.25), (4, 0.5), (2, 0.2), (5, 0.5)]:
        predicted = least_thin_N(R, d, delta)
        found = next(
            N for N in range(1, 20000) if max(thickness_profile(R, d, N)) <= delta + 1e-12
        )
        print(f"   {d:4d} {delta:7.3f} {(R/delta)**d:13.3f} {predicted:20d} {found:15d}")
        assert predicted == found


def demo_counting_bound(R: float = 1.0) -> None:
    print("\n[4] Uniform counting bound  T <= 1 + R/(d delta), and its sharpness")
    delta = 0.01
    print("      d   max_N T   R/(d delta)   1 + R/(d delta)")
    for d in (2, 5, 10):
        best = max(thick_count(R, d, N, delta) for N in range(1, 3000))
        print(f"   {d:4d} {best:9d} {R/(d*delta):13.2f} {1 + R/(d*delta):17.2f}")
        assert best <= 1 + R / (d * delta) + 1e-9
        assert best >= R / (2 * d * delta) - 1


def demo_profile_in_N(R: float = 1.0, d: int = 2, delta: float = 0.01) -> None:
    print(f"\n[5] Profile of the thick-shell count in N (R={R}, d={d}, delta={delta})")
    print("        N      T   (T-1)^(d-1) N   (R/(d delta))^d")
    cap = (R / (d * delta)) ** d
    for N in (10, 25, 50, 100, 200, 400, 1000):
        m = thick_count(R, d, N, delta)
        lhs = (m - 1) ** (d - 1) * N if m >= 2 else 0.0
        print(f"   {N:8d} {m:6d} {lhs:15.1f} {cap:17.1f}")
        if m >= 2:
            assert lhs <= cap + 1e-6


def demo_pinning(R: float = 1.0, d: int = 3, delta: float = 0.02) -> None:
    print(f"\n[6] Pinning to within one (R={R}, d={d}, delta={delta})")
    cap = (R / (d * delta)) ** d
    print("        N      T   window {j, j+1} from (R/(d delta))^d / N")
    for N in (50, 100, 200, 500, 1000, 5000):
        m = thick_count(R, d, N, delta)
        j = 1
        while (j + 1) ** (d - 1) * N < cap:
            j += 1
        print(f"   {N:8d} {m:6d}   {{{j}, {j+1}}}")
        if m >= 1:
            assert j <= m <= j + 1 or m == 0


def demo_bitcost(R: float = 1.0) -> None:
    print("\n[7] Bit cost of indexing a budget-respecting peeling")
    print("      d   delta   d log2(R/delta)   log2(least N)   gap")
    for d, delta in [(2, 0.1), (5, 0.05), (8, 0.01), (16, 0.001)]:
        target = d * math.log2(R / delta)
        actual = math.log2(least_thin_N(R, d, delta))
        print(f"   {d:4d} {delta:7.4f} {target:17.4f} {actual:15.4f} {actual-target:7.4f}")
        assert -1e-9 <= actual - target <= 1.0 + 1e-9


def demo_refutation(R: float = 1.0) -> None:
    print("\n[8] The conjecture  T = O(d log(R/delta))  fails")
    print("      d      N      delta        T    d ln(R/delta)   ratio")
    for d in (2, 5, 10):
        for N in (200, 2000):
            delta = R / (2 * d * N)
            m = thick_count(R, d, N, delta)
            conj = d * math.log(R / delta)
            print(f"   {d:4d} {N:6d} {delta:10.3e} {m:8d} {conj:14.2f} {m/conj:8.2f}")
            assert m == N


def demo_dimension_one(R: float = 1.0, N: int = 7) -> None:
    print(f"\n[9] Dimension one is all-or-nothing (R={R}, N={N})")
    ts = thickness_profile(R, 1, N)
    assert all(abs(t - R / N) < 1e-12 for t in ts)
    for delta in (R / N - 1e-6, R / N + 1e-6):
        print(f"     delta = {delta:.6f}  ->  T = {thick_count(R, 1, N, delta)}")


def demo_self_similarity(R: float = 1.0, d: int = 4, N: int = 9) -> None:
    print(f"\n[10] Renormalisation: the tail of a peeling is a peeling (R={R}, d={d}, N={N})")
    for k in range(N):
        lhs = shell_radius(R, d, N, k + 1)
        rhs = shell_radius(shell_radius(R, d, N, k), d, N - k, 1)
        assert abs(lhs - rhs) < 1e-12, (k, lhs, rhs)
    print("     r_{k+1} = shellRadius(r_k, d, N-k, 1) for every k:  OK")


def main() -> None:
    print("=" * 78)
    print("Thin-Shell Counting under a Thickness Budget — numerical verification")
    print("=" * 78)
    demo_two_sided_bounds()
    demo_monotone_and_innermost()
    demo_threshold()
    demo_counting_bound()
    demo_profile_in_N()
    demo_pinning()
    demo_bitcost()
    demo_refutation()
    demo_dimension_one()
    demo_self_similarity()
    print("\nAll numerical checks passed.")


if __name__ == "__main__":
    main()
