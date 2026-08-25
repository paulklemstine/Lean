"""
demo.py -- Numerical demonstrations for the edge-kernel refinement of a
positional hit profile.

The object of study is the harmonic-type positional kernel on the normalised
window x in [0, 1]:

        ker(b, x) = (1 + x) ** (-b),

its cumulative head mass

        H(b, t) = int_0^t (1 + x)^(-b) dx = ((1+t)^(1-b) - 1) / (1 - b),

and the normalised *edge fraction*

        F(b, t) = H(b, t) / H(b, 1) = ((1+t)^(1-b) - 1) / (2^(1-b) - 1).

The demonstrations below illustrate, numerically, every theorem of the
accompanying paper:

  1. the closed form for H and F (against numerical quadrature);
  2. rigidity: b |-> F(b, t) is strictly increasing, hence injective;
  3. left over-weighting: F(b, t) > t for b > 0;
  4. the spike limit F(b, t) -> 1 as b -> infinity;
  5. non-falsifiability: any target edge fraction in (F(b0,t), 1) is attained
     by some exponent (solved by bisection);
  6. the mixture identity: the normalised two-component profile is the
     two-point mixture of normalised components with an explicit weight;
  7. effective-exponent inflation: b_bulk < b_eff < b_edge;
  8. window dependence: b_eff(t) is not constant, and steepens to the left;
  9. strict multiplicative (log-)convexity on geometric triples, and the
     resulting left-edge steepening of the measured log-log slope;
 10. an empirical calibration reproducing the observed left-decile mass.

Self-contained: standard library only.
"""

from __future__ import annotations

from typing import Callable, List, Tuple

# --------------------------------------------------------------------------
# Core analytic objects
# --------------------------------------------------------------------------


def ker(b: float, x: float) -> float:
    """The positional kernel (1 + x)^(-b)."""
    return (1.0 + x) ** (-b)


def head_mass(b: float, t: float) -> float:
    """Closed form for int_0^t (1+x)^(-b) dx (with the b = 1 logarithmic case)."""
    if abs(b - 1.0) < 1e-14:
        import math

        return math.log(1.0 + t)
    return ((1.0 + t) ** (1.0 - b) - 1.0) / (1.0 - b)


def edge_frac(b: float, t: float) -> float:
    """Normalised cumulative mass F(b, t) = H(b, t) / H(b, 1)."""
    return head_mass(b, t) / head_mass(b, 1.0)


def quad(f: Callable[[float], float], a: float, c: float, n: int = 200000) -> float:
    """Composite Simpson quadrature (n even), used only to check closed forms."""
    if n % 2 == 1:
        n += 1
    h = (c - a) / n
    total = f(a) + f(c)
    for i in range(1, n):
        total += (4.0 if i % 2 == 1 else 2.0) * f(a + i * h)
    return total * h / 3.0


def two_comp(A: float, K: float, b1: float, b2: float, x: float) -> float:
    """Two-component profile A (1+x)^(-b1) + K (1+x)^(-b2)."""
    return A * ker(b1, x) + K * ker(b2, x)


def mix_weight(A: float, K: float, b1: float, b2: float) -> float:
    """Relative total mass carried by the steep component."""
    m1 = A * head_mass(b1, 1.0)
    m2 = K * head_mass(b2, 1.0)
    return m2 / (m1 + m2)


def mix_frac(w: float, b1: float, b2: float, t: float) -> float:
    """Edge fraction of the two-point mixture."""
    return (1.0 - w) * edge_frac(b1, t) + w * edge_frac(b2, t)


def effective_exponent(target: float, t: float,
                       lo: float = -20.0, hi: float = 400.0,
                       tol: float = 1e-12) -> float:
    """Invert b |-> F(b, t) = target by bisection (well posed: F is strictly
    increasing in b, hence injective, for every interior t)."""
    for _ in range(400):
        mid = 0.5 * (lo + hi)
        if edge_frac(mid, t) < target:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


def local_exponent(f: Callable[[float], float], x: float, y: float) -> float:
    """Two-point log-log slope: -(log f(y) - log f(x)) / (log(1+y) - log(1+x))."""
    import math

    return -(math.log(f(y)) - math.log(f(x))) / (math.log(1.0 + y) - math.log(1.0 + x))


def geometric_triple(x0: float, x2: float) -> Tuple[float, float, float]:
    """Return (x0, x1, x2) with (1+x1)^2 = (1+x0)(1+x2)."""
    import math

    x1 = math.sqrt((1.0 + x0) * (1.0 + x2)) - 1.0
    return x0, x1, x2


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_closed_form() -> None:
    print("=" * 74)
    print("1. Closed form for the cumulative mass and the edge fraction")
    print("=" * 74)
    print(f"{'b':>8} {'t':>6} {'H closed':>14} {'H quadrature':>14} {'|diff|':>10}")
    for b in (0.0, 0.573, 1.104, 2.5, 10.6, 22.54):
        for t in (0.1, 0.5, 1.0):
            hc = head_mass(b, t)
            hq = quad(lambda x: ker(b, x), 0.0, t, 4000)
            print(f"{b:8.3f} {t:6.2f} {hc:14.9f} {hq:14.9f} {abs(hc - hq):10.2e}")
    print()


def demo_rigidity() -> None:
    print("=" * 74)
    print("2-3. Rigidity (F strictly increasing in b) and left over-weighting")
    print("=" * 74)
    t = 0.1
    print(f"left-decile window t = {t}")
    print(f"{'b':>8} {'F(b,t)':>12} {'F - t':>12}")
    prev = None
    for b in (0.0, 0.25, 0.573, 1.0, 1.104, 2.0, 5.0, 10.6, 22.54, 60.0):
        v = edge_frac(b, t)
        flag = "" if prev is None else ("  increasing" if v > prev else "  VIOLATION")
        print(f"{b:8.3f} {v:12.6f} {v - t:12.6f}{flag}")
        prev = v
    print("\nInjectivity check: distinct exponents give distinct edge fractions.")
    vals = [round(edge_frac(b, t), 12) for b in (0.1, 0.2, 0.3, 0.4, 0.5)]
    print(f"  distinct values: {len(set(vals)) == len(vals)}")
    print()


def demo_spike_limit() -> None:
    print("=" * 74)
    print("4. Spike limit: F(b, t) -> 1 as b -> infinity")
    print("=" * 74)
    for t in (0.05, 0.1, 0.5):
        row = "  ".join(f"b={b:>5.0f}: {edge_frac(b, t):.6f}"
                        for b in (10, 50, 200, 1000))
        print(f"t = {t:4.2f}   {row}")
    print()


def demo_non_falsifiability() -> None:
    print("=" * 74)
    print("5. A single edge-mass number cannot refute a power law")
    print("=" * 74)
    t, b0 = 0.1, 1.104
    base = edge_frac(b0, t)
    print(f"reference law b0 = {b0}: F = {base:.6f}")
    for alpha in (0.1620, 0.25, 0.40, 0.75, 0.95):
        if alpha <= base:
            continue
        b = effective_exponent(alpha, t)
        print(f"  target {alpha:.4f} attained at b = {b:10.5f} "
              f"(check F = {edge_frac(b, t):.6f})")
    print("  => a lone edge fraction is never evidence against a power law;")
    print("     only a shape comparison across windows can separate the families.")
    print()


def demo_mixture_identity() -> None:
    print("=" * 74)
    print("6. Mixture identity for the normalised two-component profile")
    print("=" * 74)
    A, K, b1, b2 = 1.0, 0.35, 0.573, 22.54
    w = mix_weight(A, K, b1, b2)
    print(f"A = {A}, K = {K}, b_bulk = {b1}, b_edge = {b2}  ->  w = {w:.6f}")
    print(f"{'t':>6} {'normalised T':>16} {'mixture':>16} {'|diff|':>10}")
    for t in (0.05, 0.1, 0.3, 0.65, 0.9):
        num = quad(lambda x: two_comp(A, K, b1, b2, x), 0.0, t, 4000)
        den = quad(lambda x: two_comp(A, K, b1, b2, x), 0.0, 1.0, 4000)
        lhs = num / den
        rhs = mix_frac(w, b1, b2, t)
        print(f"{t:6.2f} {lhs:16.9f} {rhs:16.9f} {abs(lhs - rhs):10.2e}")
    print()


def demo_effective_exponent() -> None:
    print("=" * 74)
    print("7-8. Effective-exponent inflation and window dependence")
    print("=" * 74)
    b1, b2, w = 0.573, 22.54, 0.086
    print(f"bulk b1 = {b1}, spike b2 = {b2}, spike weight w = {w}")
    print(f"{'t':>6} {'mixture F':>12} {'b_eff(t)':>12}  bracket b1 < b_eff < b2")
    effs: List[float] = []
    for t in (0.02, 0.05, 0.1, 0.2, 0.4, 0.65, 0.9, 0.98):
        target = mix_frac(w, b1, b2, t)
        beff = effective_exponent(target, t)
        effs.append(beff)
        ok = "yes" if b1 < beff < b2 else "NO"
        print(f"{t:6.2f} {target:12.6f} {beff:12.6f}  {ok}")
    strictly_decreasing = all(effs[i] > effs[i + 1] for i in range(len(effs) - 1))
    print(f"\n  b_eff(t) strictly decreasing in t on the sampled grid: "
          f"{strictly_decreasing}")
    print("  => no single exponent fits all windows; refitting on a narrower")
    print("     left window returns a strictly steeper law.")
    print()


def demo_log_convexity() -> None:
    print("=" * 74)
    print("9. Strict log-convexity on geometric triples; left-edge steepening")
    print("=" * 74)
    A, K, b1, b2 = 1.0, 0.35, 0.573, 22.54
    f = lambda x: two_comp(A, K, b1, b2, x)
    g = lambda x: 1.7 * ker(1.104, x)
    for (x0, x2) in ((0.0, 1.0), (0.0, 0.2), (0.25, 0.75)):
        x0, x1, x2 = geometric_triple(x0, x2)
        lhs = f(x1) ** 2
        rhs = f(x0) * f(x2)
        left = local_exponent(f, x0, x1)
        right = local_exponent(f, x1, x2)
        print(f"triple ({x0:.4f}, {x1:.4f}, {x2:.4f})")
        print(f"   two-component: f(x1)^2 = {lhs:.8f} < f(x0)f(x2) = {rhs:.8f} "
              f" -> {lhs < rhs}")
        print(f"   pure power law: g(x1)^2 = {g(x1)**2:.8f} vs "
              f"g(x0)g(x2) = {g(x0)*g(x2):.8f} (equal)")
        print(f"   measured slope left = {left:.5f}  >  right = {right:.5f}  "
              f"-> {left > right}")
    print()


def demo_empirical_calibration() -> None:
    print("=" * 74)
    print("10. Empirical calibration: the left-decile discrepancy")
    print("=" * 74)
    t = 0.1
    observed = 0.1620
    single_b = 1.104
    print(f"observed left-decile mass                : {observed:.4f}")
    print(f"single power law, b = {single_b:5.3f}          : "
          f"{edge_frac(single_b, t):.4f}  (misses low)")
    b1, b2, w = 0.573, 22.54, 0.086
    print(f"bulk+spike (b={b1}, b_edge={b2}, w={w}): "
          f"{mix_frac(w, b1, b2, t):.4f}  (overshoots high)")
    print()
    print("The single law can only miss the observation from below, because a")
    print("flat-bulk exponent under-weights the edge while the pooled exponent")
    print("that matches the bulk shape is too flat to reach the measured edge")
    print("mass; the mixture straddles the observation, so the observed value")
    print("is attained at an interior weight (computed at the end of this block).")
    print()
    print("Narrow-spike limit: as b_edge -> infinity the mixture edge fraction")
    print("tends to (1-w) F(b_bulk, t) + w, so the spike weight is exactly the")
    print("excess of the measured edge mass over the bulk prediction.")
    limit = (1.0 - w) * edge_frac(b1, t) + w
    for b2v in (10.0, 22.54, 50.0, 200.0, 2000.0):
        print(f"   b_edge = {b2v:8.2f}: F_mix = {mix_frac(w, b1, b2v, t):.6f}")
    print(f"   limit                 : {limit:.6f}")
    implied_w = (observed - edge_frac(b1, t)) / (1.0 - edge_frac(b1, t))
    print(f"\n  weight implied by the observed excess (narrow-spike limit): "
          f"w = {implied_w:.4f}")
    print("  (an idealised continuum calibration: the same order of magnitude")
    print("   as the few-percent spike weights seen in practice, with the exact")
    print("   value depending on the binning and normalisation convention used)")
    print()


def main() -> None:
    demo_closed_form()
    demo_rigidity()
    demo_spike_limit()
    demo_non_falsifiability()
    demo_mixture_identity()
    demo_effective_exponent()
    demo_log_convexity()
    demo_empirical_calibration()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
