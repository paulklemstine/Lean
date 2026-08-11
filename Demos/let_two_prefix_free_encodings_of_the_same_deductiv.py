"""Numerical demonstrations for the critical geometry of counted proof spaces.

Self-contained: standard library only (math, typing).  Every function is
inlined so that the file can be run as a script:

    python3 demo.py

Contents
--------
1.  Ambient volume S_k(n) = sum_{i<=n} k^i, its exact shift identity and the
    distortion bound S_k(n+b) <= 2 k^b S_k(n).
2.  Radial quasi-invariance of count radii and exact invariance of the
    entropy dimension under a bounded recoding.
3.  A count of exact exponential order (3/2)^n inside the binary language:
    measured transition windows at levels from 1/2 down to 1e-6, compared
    against the certified level-independent bound log(2C/c)/log(k/a).
4.  The refutation of same-level stability: harmonic profiles p(n)=1/(n+1)
    and q(n)=1/(2n+2) satisfy the overhead-1 binary distortion inequalities
    yet have same-level critical indices differing by D+1.
5.  The dimension spectrum: realization of arbitrary rates, the union law
    (maximum) and the strict drop h1 + h2 - log k at independent
    intersections.
6.  Power laws from mixtures: the exact mixed tail (1 - e^{-x})/x, its
    regular variation of index -1, and the successive-ratio diagnostic that
    separates a mixture from a single geometric regime.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------
# 1. Ambient volume of the k-letter language
# --------------------------------------------------------------------------


def ambient_volume(k: int, n: int) -> int:
    """S_k(n) = sum_{i=0}^{n} k^i, the number of strings of length at most n."""
    return sum(k**i for i in range(n + 1))


def check_shift_identity(k: int, n: int, b: int) -> bool:
    """S_k(n+b) = (sum_{i<b} k^i) + k^b S_k(n)."""
    left = ambient_volume(k, n + b)
    right = sum(k**i for i in range(b)) + k**b * ambient_volume(k, n)
    return left == right


def check_distortion_bound(k: int, n: int, b: int) -> bool:
    """S_k(n+b) <= 2 k^b S_k(n) for k >= 2."""
    return ambient_volume(k, n + b) <= 2 * k**b * ambient_volume(k, n)


def demo_ambient() -> None:
    print("=" * 72)
    print("1. Ambient volume, shift identity, and the factor 2 k^b")
    print("=" * 72)
    for k in (2, 3):
        row = [ambient_volume(k, n) for n in range(6)]
        print(f"  S_{k}(0..5) = {row}")
    ok_id = all(
        check_shift_identity(k, n, b)
        for k in (2, 3, 5)
        for n in range(6)
        for b in range(5)
    )
    ok_bd = all(
        check_distortion_bound(k, n, b)
        for k in (2, 3, 5)
        for n in range(7)
        for b in range(5)
    )
    print(f"  exact shift identity holds on the test grid : {ok_id}")
    print(f"  bound  S_k(n+b) <= 2 k^b S_k(n)             : {ok_bd}")
    print("  interpretation: a radial shift of b multiplies the ambient")
    print("  volume by k^b, so it multiplies a DENSITY LEVEL, while it only")
    print("  shifts a RADIUS additively.  That mismatch drives everything.")
    print()


# --------------------------------------------------------------------------
# 2. Invariant observables: count radii and the entropy dimension
# --------------------------------------------------------------------------


def count_radius(counts: Sequence[int], m: int) -> Optional[int]:
    """r(m) = min { n : counts[n] >= m }, or None if never reached."""
    for n, value in enumerate(counts):
        if value >= m:
            return n
    return None


def entropy_dimension(counts: Sequence[int]) -> float:
    """Estimate lim log N(n) / n from the last available index."""
    n = len(counts) - 1
    return math.log(counts[n]) / n


def demo_invariants() -> None:
    print("=" * 72)
    print("2. Count radii are b-quasi-invariant; the entropy dimension is exact")
    print("=" * 72)
    horizon = 60
    b = 3
    # N1: a count of exponential order (3/2)^n.  N2: its overhead-b recoding,
    # modelled as N2(n) = N1(n - b') for a genuine shift b' <= b.
    n1: List[int] = [math.ceil((1.5) ** n) for n in range(horizon)]
    n2: List[int] = [n1[max(n - 2, 0)] for n in range(horizon)]

    ok_shift = all(
        n1[n] <= n2[min(n + b, horizon - 1)] and n2[n] <= n1[min(n + b, horizon - 1)]
        for n in range(horizon - b)
    )
    print(f"  radial-shift hypothesis N_i(n) <= N_j(n+b), b = {b}: {ok_shift}")

    gaps = []
    for m in (2, 5, 20, 100, 5000, 100000):
        r1, r2 = count_radius(n1, m), count_radius(n2, m)
        if r1 is not None and r2 is not None:
            gaps.append(abs(r1 - r2))
            print(f"    m = {m:>7}: r1 = {r1:>3}, r2 = {r2:>3}, |r1-r2| = {abs(r1-r2)}")
    print(f"  max |r1(m) - r2(m)| = {max(gaps)}  (theory: <= b = {b})")

    h1, h2 = entropy_dimension(n1), entropy_dimension(n2)
    print(f"  entropy dimensions: h1 = {h1:.6f}, h2 = {h2:.6f}, log(3/2) = "
          f"{math.log(1.5):.6f}")
    print("  the two rates agree in the limit: the dimension is EXACTLY invariant.")
    print()


# --------------------------------------------------------------------------
# 3. Transition windows for counts of exact exponential order
# --------------------------------------------------------------------------


def density(counts: Sequence[int], k: int, n: int) -> float:
    """d(n) = N(n) / S_k(n)."""
    return counts[n] / ambient_volume(k, n)


def transition_window(
    counts: Sequence[int], k: int, eps: float
) -> Tuple[Optional[int], Optional[int]]:
    """Return (n_minus, n_plus): first radius below level eps, last at level eps."""
    n_plus: Optional[int] = None
    n_minus: Optional[int] = None
    for n in range(len(counts)):
        d = density(counts, k, n)
        if d >= eps:
            n_plus = n
        elif n_minus is None:
            n_minus = n
    return n_minus, n_plus


def certified_window_width(k: int, a: float, c: float, cc: float) -> float:
    """log(2C/c) / log(k/a): the level-independent bound on the window width."""
    return math.log(2 * cc / c) / math.log(k / a)


def demo_window() -> None:
    print("=" * 72)
    print("3. Uniform transition windows under exact exponential order")
    print("=" * 72)
    k, a, horizon = 2, 1.5, 110
    counts = [math.ceil(a**n) for n in range(horizon)]
    # ceil(a^n) satisfies a^n <= N(n) <= 2 a^n, so c = 1, C = 2.
    c, cc = 1.0, 2.0
    width = certified_window_width(k, a, c, cc)
    print(f"  k = {k}, a = {a}, c = {c}, C = {cc}")
    print(f"  certified window width  log(2C/c)/log(k/a) = {width:.4f}")
    print("  n_+ = last radius still at level eps, n_- = first radius below it;")
    print("  theory bounds the worst-case separation n_+ - n_- by the width above.")
    print("    level eps      n_-   n_+   worst-case separation")
    for eps in (0.5, 0.25, 0.1, 1e-2, 1e-3, 1e-6, 1e-9):
        n_minus, n_plus = transition_window(counts, k, eps)
        if n_minus is None or n_plus is None:
            continue
        measured = n_plus - n_minus
        flag = "ok" if measured <= width else "VIOLATION"
        print(f"    {eps:<12.1e} {n_minus:>4}  {n_plus:>4}   {measured:>6}  [{flag}]")
    print("  the separation stays at -1 (a single sharp crossing) as the level")
    print("  falls by nine orders of magnitude: the window slides outward")
    print("  without smearing, well inside the certified bound.")
    print()


# --------------------------------------------------------------------------
# 4. Same-level critical indices are NOT recoding invariant
# --------------------------------------------------------------------------


def p_profile(n: int) -> float:
    """p(n) = 1/(n+1)."""
    return 1.0 / (n + 1)


def q_profile(n: int) -> float:
    """q(n) = 1/(2n+2) = p(n)/2."""
    return 1.0 / (2 * n + 2)


def critical_index(profile: Callable[[int], float], eps: float, horizon: int) -> int:
    """Last radius at which the profile is still at level eps."""
    last = 0
    for n in range(horizon):
        if profile(n) >= eps:
            last = n
    return last


def demo_gap() -> None:
    print("=" * 72)
    print("4. Refutation of same-level stability (unbounded critical-index gap)")
    print("=" * 72)
    horizon = 4000
    ok = all(
        p_profile(n) <= 4 * q_profile(n + 1) and q_profile(n) <= 4 * p_profile(n + 1)
        for n in range(500)
    )
    print("  p(n) = 1/(n+1),  q(n) = 1/(2n+2)")
    print(f"  overhead-1 binary distortion inequalities (factor 4) hold: {ok}")
    print("    D      eps = 1/(2D+2)      c_p     c_q    gap")
    for d in (0, 1, 2, 5, 10, 50, 200):
        eps = 1.0 / (2 * d + 2)
        cp = critical_index(p_profile, eps, horizon)
        cq = critical_index(q_profile, eps, horizon)
        print(f"    {d:<5}  {eps:<16.6g}  {cp:>5}   {cq:>5}   {cp - cq:>4}")
    print("  the gap grows without bound: at a FIXED level, a bounded recoding")
    print("  can move the critical index arbitrarily far.")
    print()


# --------------------------------------------------------------------------
# 5. The dimension spectrum
# --------------------------------------------------------------------------


def stratum_count(h: float, n: int) -> int:
    """Canonical stratum of rate h: N_h(n) = ceil(exp(h n))."""
    return math.ceil(math.exp(h * n))


def measured_dimension(counts: Sequence[int]) -> float:
    n = len(counts) - 1
    return math.log(counts[n]) / n


def demo_spectrum() -> None:
    print("=" * 72)
    print("5. The dimension spectrum of theorem families")
    print("=" * 72)
    k, horizon = 4, 400
    log_k = math.log(k)
    print(f"  ambient alphabet k = {k}, ambient entropy log k = {log_k:.6f}")
    print("    target h    measured   density at n=60")
    for h in (0.0, 0.2, 0.5, 0.9, 1.2):
        counts = [stratum_count(h, n) for n in range(horizon)]
        d60 = counts[60] / ambient_volume(k, 60)
        print(f"    {h:<10.3f}  {measured_dimension(counts):<9.6f}  {d60:.3e}")
    print("  every rate in [0, log k) is realized, and all of them have ambient")
    print("  density tending to zero: a continuum of strata invisible to the")
    print("  provable/unprovable ratio.")

    h1, h2 = 1.0, 1.2
    n1 = [stratum_count(h1, n) for n in range(horizon)]
    n2 = [stratum_count(h2, n) for n in range(horizon)]
    union = [x + y for x, y in zip(n1, n2)]
    print(f"  union law: dim(N1 + N2) = {measured_dimension(union):.6f} "
          f"(max(h1,h2) = {max(h1, h2)})")

    # Independent intersection: N_cap(n) * S_k(n) = N1(n) * N2(n).
    inter = [max(1, round(n1[n] * n2[n] / ambient_volume(k, n)))
             for n in range(1, horizon)]
    predicted = h1 + h2 - log_k
    print(f"  independent intersection: measured "
          f"{math.log(inter[-1]) / (horizon - 1):.6f}, predicted "
          f"h1 + h2 - log k = {predicted:.6f}")
    print(f"  strict drop: {predicted:.6f} < min(h1, h2) = {min(h1, h2)}")
    print("  equivalently, codimensions add: "
          f"({log_k - h1:.4f}) + ({log_k - h2:.4f}) = {2 * log_k - h1 - h2:.4f}")
    print()


# --------------------------------------------------------------------------
# 6. Power laws from mixtures of geometric proof regimes
# --------------------------------------------------------------------------


def regime_tail(s: float, x: float) -> float:
    """Length tail of a single proof regime of entropy parameter s."""
    return math.exp(-x * s)


def mixed_tail(x: float) -> float:
    """Uniform scale mixture over s in [0,1]: exactly (1 - e^{-x})/x."""
    return (1.0 - math.exp(-x)) / x


def mixed_tail_numeric(x: float, steps: int = 200000) -> float:
    """Midpoint-rule check of the integral definition int_0^1 e^{-x s} ds."""
    total = 0.0
    for i in range(steps):
        s = (i + 0.5) / steps
        total += math.exp(-x * s)
    return total / steps


def demo_mixture() -> None:
    print("=" * 72)
    print("6. Power laws from mixtures of geometric proof regimes")
    print("=" * 72)
    print("  single regime: T_s(x+1)/T_s(x) is the CONSTANT exp(-s)")
    for s in (0.3, 1.0, 2.0):
        ratios = [regime_tail(s, x + 1) / regime_tail(s, x) for x in (1, 5, 20)]
        print(f"    s = {s:<5}: ratios {['%.6f' % r for r in ratios]}  "
              f"exp(-s) = {math.exp(-s):.6f}")

    print("  closed form check  (1 - e^{-x})/x  versus numerical integration:")
    for x in (0.5, 1.0, 3.0, 10.0):
        print(f"    x = {x:<5}: closed {mixed_tail(x):.10f}, "
              f"numeric {mixed_tail_numeric(x):.10f}")

    print("  regular variation of index -1:  x * T(x) -> 1")
    print("     x       T(x)          x*T(x)      bounds  (1-1/e)/x .. 1/x")
    for x in (1, 2, 3, 5, 10, 20, 50, 100):
        t = mixed_tail(float(x))
        lo, hi = (1 - math.exp(-1)) / x, 1 / x
        print(f"    {x:>4}   {t:.8f}   {x * t:.8f}   [{lo:.8f}, {hi:.8f}]")

    print("  successive ratios of the MIXTURE climb to 1 (not geometric):")
    for n in (1, 2, 5, 10, 50, 200, 1000):
        r = mixed_tail(n + 1.0) / mixed_tail(float(n))
        print(f"    n = {n:>5}: T(n+1)/T(n) = {r:.6f}")

    print("  no geometric bound dominates: check C a^n < T(n) eventually")
    for a in (0.5, 0.9, 0.99):
        cc = 10.0
        witness = next(
            (n for n in range(1, 200000) if cc * a**n < mixed_tail(float(n))), None
        )
        print(f"    a = {a:<5}, C = {cc}: first n with C a^n < T(n) is {witness}")
    print("  diagnostic: ratios hovering below 1 -> single regime;")
    print("              ratios climbing to 1     -> scale mixture, power law.")
    print()


# --------------------------------------------------------------------------


def main() -> None:
    demo_ambient()
    demo_invariants()
    demo_window()
    demo_gap()
    demo_spectrum()
    demo_mixture()
    print("=" * 72)
    print("Summary")
    print("=" * 72)
    summary: Dict[str, str] = {
        "invariant under bounded recoding": "count radii (up to b), entropy dimension (exact)",
        "not invariant": "density level, and the critical index at a fixed level",
        "restores sharpness": "exact exponential order c a^n <= N(n) <= C a^n, a < k",
        "window width": "log(2C/c)/log(k/a), independent of the level",
        "spectrum": "every rate in [0, log k); unions take max; independent "
                    "intersections drop to h1 + h2 - log k",
        "power laws": "impossible in one regime (constant ratio e^{-s}); the "
                      "uniform mixture has tail (1 - e^{-x})/x",
    }
    for key, value in summary.items():
        print(f"  {key:<34}: {value}")


if __name__ == "__main__":
    main()
