"""
Arithmetic ceilings for phase features: numerical demonstrations.
=================================================================

Self-contained numerical verification of every quantitative claim in the
accompanying paper.  Pure standard library (``math``, ``cmath``, ``itertools``);
no third-party dependencies.

What is demonstrated
--------------------
1.  Exact character orthogonality of the trigonometric design over a full
    period:  <cos_k, cos_l> = (N/2)[k = +-l != 0],  <cos_k, sin_l> = 0 always.
2.  Cross-prime (Chinese Remainder) orthogonality of phase blocks.
3.  The Gauss-sum modulus |g_k|^2 = p and the normalised QR/phase coupling
    delta_p = sqrt(2/(p-1)).
4.  The Gauss-sign dichotomy: the quadratic-residue indicator is exactly
    orthogonal to the cosine channel when p = 3 (mod 4) and exactly orthogonal
    to the sine channel when p = 1 (mod 4), the coupling being exactly sqrt(p)
    in the other channel.
5.  Exactness of the block stability constant 1 - delta_p (explicit worst-case
    coefficient witness).
6.  The sub-threshold lift ceiling K eps^2 / (1 - delta), checked against a
    brute-force search over coefficient vectors.
7.  The nine-block certificate and the deterministic refutation of the
    registered R^2 >= 0.70 hypothesis.
8.  The full-frequency Bessel equality: the QR indicator is exactly a linear
    combination of the half-period phase features.
9.  The transported-coefficient parabola and the coefficient-miss certificates
    implied by the measured -0.077 and by the 0.600 -> 0.400 degradation.
10. The leakage identity and the model-free falsification threshold sqrt(0.6).

Run with:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple

Vector = List[float]

# ---------------------------------------------------------------------------
# 0.  Design calculus
# ---------------------------------------------------------------------------


def dot(x: Sequence[float], y: Sequence[float]) -> float:
    """Sample inner product <x, y> = sum_i x_i y_i."""
    return sum(a * b for a, b in zip(x, y))


def sqnorm(x: Sequence[float]) -> float:
    """Design energy ||x||^2."""
    return dot(x, x)


def gain(e: Sequence[float], f: Sequence[float]) -> float:
    """Residual energy removed by least-squares fitting of the feature f to e."""
    s = sqnorm(f)
    return 0.0 if s == 0.0 else dot(e, f) ** 2 / s


def combo(a: Sequence[float], f: Sequence[Sequence[float]]) -> Vector:
    """Linear combination sum_k a_k f_k."""
    n = len(f[0])
    return [sum(a[k] * f[k][i] for k in range(len(f))) for i in range(n)]


def correlation(x: Sequence[float], y: Sequence[float]) -> float:
    """Normalised inner product <x, y> / (||x|| ||y||)."""
    d = math.sqrt(sqnorm(x) * sqnorm(y))
    return 0.0 if d == 0.0 else dot(x, y) / d


# ---------------------------------------------------------------------------
# 1.  The phase features
# ---------------------------------------------------------------------------


def phase_cos(k: int, N: int) -> Vector:
    """cos(2 pi k r / N) for r = 0, ..., N-1."""
    return [math.cos(2.0 * math.pi * k * r / N) for r in range(N)]


def phase_sin(k: int, N: int) -> Vector:
    """sin(2 pi k r / N) for r = 0, ..., N-1."""
    return [math.sin(2.0 * math.pi * k * r / N) for r in range(N)]


def legendre_symbol(r: int, p: int) -> int:
    """(r/p) in {-1, 0, 1} by Euler's criterion."""
    r %= p
    if r == 0:
        return 0
    t = pow(r, (p - 1) // 2, p)
    return 1 if t == 1 else -1


def qr_feature(p: int) -> Vector:
    """The quadratic-residue indicator as a real feature vector over Z/p."""
    return [float(legendre_symbol(r, p)) for r in range(p)]


def gauss_sum(k: int, p: int) -> complex:
    """g_k = sum_r (r/p) exp(2 pi i k r / p)."""
    return sum(
        legendre_symbol(r, p) * cmath.exp(2j * math.pi * k * r / p) for r in range(p)
    )


def gauss_delta(p: int) -> float:
    """The normalised QR/phase coupling delta_p = sqrt(2/(p-1))."""
    return math.sqrt(2.0 / (p - 1))


# ---------------------------------------------------------------------------
# 2.  Demonstrations
# ---------------------------------------------------------------------------

TOL = 1e-9


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_trig_orthogonality(N: int = 24) -> None:
    banner(f"1.  Exact trigonometric Gram over a full period, N = {N}")
    print("   Predicted:  <cos_k,cos_l> = (N/2)([k=l] + [k=-l]),  <cos_k,sin_l> = 0.")
    worst_cc = 0.0
    worst_cs = 0.0
    for k, l in product(range(N), repeat=2):
        ck, cl = phase_cos(k, N), phase_cos(l, N)
        sl = phase_sin(l, N)
        pred_cc = 0.5 * (
            (N if (k - l) % N == 0 else 0) + (N if (k + l) % N == 0 else 0)
        )
        worst_cc = max(worst_cc, abs(dot(ck, cl) - pred_cc))
        worst_cs = max(worst_cs, abs(dot(ck, sl)))
    print(f"   max |<cos_k,cos_l> - predicted| = {worst_cc:.3e}")
    print(f"   max |<cos_k,sin_l>|             = {worst_cs:.3e}   (zero at every k,l)")
    assert worst_cc < 1e-8 and worst_cs < 1e-8
    print("   OK: the Fourier half of the design is exactly orthogonal, delta = 0.")


def demo_cross_prime(pairs: Sequence[Tuple[int, int]] = ((3, 5), (5, 7), (7, 11), (11, 13))) -> None:
    banner("2.  Cross-prime (CRT) orthogonality of phase blocks")
    print("   Over Z/(pq) the frequency-q phase and the frequency-p phase are")
    print("   exactly orthogonal, so the per-prime blocks add independently.\n")
    print(f"   {'p':>4} {'q':>4} {'N=pq':>7} {'<cos_q,cos_p>':>16} {'<sin_q,sin_p>':>16}")
    for p, q in pairs:
        N = p * q
        a = dot(phase_cos(q, N), phase_cos(p, N))
        b = dot(phase_sin(q, N), phase_sin(p, N))
        print(f"   {p:>4} {q:>4} {N:>7} {a:>16.2e} {b:>16.2e}")
        assert abs(a) < 1e-8 and abs(b) < 1e-8
    print("   OK: distinct prime blocks are mutually orthogonal.")


def demo_gauss(primes: Sequence[int] = (5, 7, 11, 13, 17, 19, 23, 29)) -> None:
    banner("3-4.  Gauss sums, the coupling delta_p, and the Gauss-sign dichotomy")
    print("   |g_k|^2 = p (Gauss);   normalised coupling delta_p = sqrt(2/(p-1));")
    print("   g_k is real for p = 1 (mod 4) and purely imaginary for p = 3 (mod 4).\n")
    header = (
        f"   {'p':>4} {'p%4':>4} {'|g_1|^2':>10} {'<QR,cos>':>11} {'<QR,sin>':>11} "
        f"{'delta_p':>9} {'corr(active)':>13}"
    )
    print(header)
    for p in primes:
        qr = qr_feature(p)
        ck, sk = phase_cos(1, p), phase_sin(1, p)
        g = gauss_sum(1, p)
        c_cos, c_sin = dot(qr, ck), dot(qr, sk)
        active = max(abs(correlation(qr, ck)), abs(correlation(qr, sk)))
        print(
            f"   {p:>4} {p % 4:>4} {abs(g) ** 2:>10.6f} {c_cos:>11.6f} "
            f"{c_sin:>11.6f} {gauss_delta(p):>9.6f} {active:>13.6f}"
        )
        assert abs(abs(g) ** 2 - p) < 1e-6
        assert abs(sqnorm(qr) - (p - 1)) < 1e-9
        if p % 4 == 3:
            assert abs(c_cos) < 1e-8, "cosine channel must vanish for p = 3 mod 4"
            assert abs(abs(c_sin) - math.sqrt(p)) < 1e-6
        else:
            assert abs(c_sin) < 1e-8, "sine channel must vanish for p = 1 mod 4"
            assert abs(abs(c_cos) - math.sqrt(p)) < 1e-6
        assert abs(active - gauss_delta(p)) < 1e-9
    print("   OK: one coupled pair per block; the bound delta_p is attained exactly.")


def block(p: int, k: int = 1) -> List[Vector]:
    """The three-feature prime block (cos_k, sin_k, QR) over Z/p."""
    return [phase_cos(k, p), phase_sin(k, p), qr_feature(p)]


def demo_block_constant_exact(primes: Sequence[int] = (5, 7, 11, 13, 29)) -> None:
    banner("5.  Exactness of the block stability constant 1 - delta_p")
    print("   Claim: min over unit-energy coefficient vectors of")
    print("      ||sum_j a_j f_j||^2 / sum_j a_j^2 ||f_j||^2   equals   1 - delta_p.\n")
    print(f"   {'p':>4} {'1-delta_p':>11} {'empirical min':>15} {'witness ratio':>15}")
    for p in primes:
        f = block(p)
        norms = [math.sqrt(sqnorm(v)) for v in f]
        # brute-force minimum over a fine grid on the unit sphere in R^3
        best = float("inf")
        steps = 90
        for i in range(steps):
            th = math.pi * i / steps
            for j in range(2 * steps):
                ph = math.pi * j / steps
                u = (
                    math.sin(th) * math.cos(ph),
                    math.sin(th) * math.sin(ph),
                    math.cos(th),
                )
                a = [u[m] / norms[m] for m in range(3)]
                den = sum(a[m] ** 2 * norms[m] ** 2 for m in range(3))
                if den < 1e-12:
                    continue
                best = min(best, sqnorm(combo(a, f)) / den)
        # explicit witness on the coupled pair
        idx = (1, 2) if p % 4 == 3 else (0, 2)
        s = 1.0 if dot(f[idx[0]], f[idx[1]]) > 0 else -1.0
        a = [0.0, 0.0, 0.0]
        a[idx[0]] = 1.0 / norms[idx[0]]
        a[idx[1]] = -s / norms[idx[1]]
        wit = sqnorm(combo(a, f)) / sum(a[m] ** 2 * norms[m] ** 2 for m in range(3))
        print(f"   {p:>4} {1 - gauss_delta(p):>11.6f} {best:>15.6f} {wit:>15.6f}")
        assert abs(wit - (1 - gauss_delta(p))) < 1e-8
        assert best >= 1 - gauss_delta(p) - 1e-6
    print("   OK: 1 - delta_p is attained, hence optimal; no Gram-based")
    print("       argument can improve the ceiling.")


def demo_lift_ceiling(p: int = 13, eps: float = 0.01, trials: int = 20000) -> None:
    banner(f"6.  The sub-threshold lift ceiling, p = {p}, eps = {eps}")
    f = block(p)
    n = p
    # A residual with a controlled per-feature correlation: an orthogonal core of
    # weight A plus a unit contribution from each block feature.  Bisect on A so
    # that the measured per-feature correlation lands on the target eps.
    base = [math.sin(3.1 * i + 0.7) for i in range(n)]
    # exact least-squares removal of the block from the core (the features are
    # not mutually orthogonal, so sequential projection would not suffice)
    G = [[dot(f[a], f[b]) for b in range(3)] for a in range(3)]
    coef = solve_symmetric(G, [dot(base, f[a]) for a in range(3)])
    proj = combo(coef, f)
    base = [base[i] - proj[i] for i in range(n)]
    scale = math.sqrt(sqnorm(base))
    core = [base[i] / scale for i in range(n)]

    def build(weight: float) -> Vector:
        out = [weight * core[i] for i in range(n)]
        for v in f:
            s = math.sqrt(sqnorm(v))
            out = [out[i] + v[i] / s for i in range(n)]
        return out

    lo, hi = 1.0, 1.0e6
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if max(abs(correlation(build(mid), v)) for v in f) > eps:
            lo = mid
        else:
            hi = mid
    e = build(hi)
    eps_meas = max(abs(correlation(e, v)) for v in f)

    K = 3
    delta = gauss_delta(p)
    ceiling_sharp = K * eps_meas ** 2 / (1 - delta)
    ceiling_crude = K * eps_meas ** 2 / (1 - 2 * delta)

    # Brute-force search for the best coefficient vector (relative gain).
    best = 0.0
    rng_state = 12345
    for _ in range(trials):
        rng_state = (1103515245 * rng_state + 12345) % (1 << 31)
        a = []
        for _m in range(3):
            rng_state = (1103515245 * rng_state + 12345) % (1 << 31)
            a.append((rng_state / (1 << 30)) - 1.0)
        if all(abs(x) < 1e-12 for x in a):
            continue
        g = combo(a, f)
        if sqnorm(g) < 1e-12:
            continue
        best = max(best, gain(e, g) / sqnorm(e))
    # Exact optimum: the full three-feature least-squares projection.
    exact = exact_projection_relative_gain(e, f)

    print(f"   measured per-feature residual correlation eps = {eps_meas:.6f}")
    print(f"   delta_p = {delta:.6f},  1 - delta_p = {1 - delta:.6f}")
    print(f"   best relative gain (random search, {trials} draws) = {best:.6f}")
    print(f"   exact best relative gain (full projection)         = {exact:.6f}")
    print(f"   sharp ceiling  K eps^2/(1-delta_p)                 = {ceiling_sharp:.6f}")
    print(f"   crude ceiling  K eps^2/(1-2 delta_p)               = {ceiling_crude:.6f}")
    assert exact <= ceiling_sharp + 1e-9
    assert best <= exact + 1e-9
    print("   OK: no coefficient vector whatsoever exceeds the ceiling.")


def exact_projection_relative_gain(e: Sequence[float], f: Sequence[Sequence[float]]) -> float:
    """Relative gain of the exact least-squares projection of e onto span(f)."""
    m = len(f)
    G = [[dot(f[i], f[j]) for j in range(m)] for i in range(m)]
    b = [dot(e, f[i]) for i in range(m)]
    a = solve_symmetric(G, b)
    g = combo(a, f)
    return gain(e, g) / sqnorm(e)


def solve_symmetric(G: List[List[float]], b: List[float]) -> List[float]:
    """Gaussian elimination with partial pivoting for a small dense system."""
    m = len(b)
    A = [row[:] + [b[i]] for i, row in enumerate(G)]
    for col in range(m):
        piv = max(range(col, m), key=lambda r: abs(A[r][col]))
        if abs(A[piv][col]) < 1e-14:
            continue
        A[col], A[piv] = A[piv], A[col]
        for r in range(m):
            if r == col:
                continue
            fac = A[r][col] / A[col][col]
            for c in range(col, m + 1):
                A[r][c] -= fac * A[col][c]
    return [
        (A[i][m] / A[i][i]) if abs(A[i][i]) > 1e-14 else 0.0 for i in range(m)
    ]


def demo_certificate(
    primes: Sequence[int] = (5, 7, 11, 13, 17, 19, 23, 29, 31), eps: float = 0.01
) -> None:
    banner("7.  The nine-block certificate and the deterministic refutation")
    print("   Per-block ceiling 3 eps^2 / (1 - delta_p), summed over orthogonal blocks.\n")
    print(f"   {'p':>4} {'delta_p':>10} {'1-delta_p':>11} {'block ceiling':>15}")
    total = 0.0
    for p in primes:
        d = gauss_delta(p)
        c = 3 * eps ** 2 / (1 - d)
        total += c
        print(f"   {p:>4} {d:>10.6f} {1 - d:>11.6f} {c:>15.8f}")
    worst = 3 * eps ** 2 / (1 - gauss_delta(min(primes)))
    uniform_total = len(primes) * worst
    base_r2 = 0.600
    residual = 1 - base_r2
    print()
    print(f"   exact summed ceiling                         = {total:.6f}")
    print(f"   uniform certificate {len(primes)} x worst block          = {uniform_total:.6f}")
    print(f"   baseline R^2 = {base_r2},  residual energy fraction = {residual}")
    best_score = base_r2 + uniform_total * residual
    print(f"   best achievable phase-augmented R^2          = {best_score:.6f}")
    print(f"   registered bar                               = 0.700")
    assert best_score < 0.70
    print("   => the registered hypothesis was unreachable a priori.")
    print()
    print("   Measured arms, for comparison:")
    print("     baseline 0.600  |  + phases 0.608 (+0.008)  |  extended 0.604 (+0.004)")
    lift_as_residual = 0.008 / residual
    print(f"     measured +0.008 = {lift_as_residual:.4f} of the residual energy")
    eps_crude = math.sqrt(lift_as_residual * 0.18 / (9 * 3))
    eps_sharp = math.sqrt(lift_as_residual * (1 - gauss_delta(13)) / (9 * 3))
    print(f"     eps needed to reach it, crude constant 0.18 = {eps_crude:.5f}")
    print(f"     eps needed to reach it, sharp constant 0.59 = {eps_sharp:.5f}")


def demo_full_frequency_degeneracy(primes: Sequence[int] = (5, 7, 11, 13, 17, 19, 29)) -> None:
    banner("8.  Full-frequency degeneracy: QR is a phase combination")
    print("   Over the half period k = 1..(p-1)/2, the cosine and sine channels")
    print("   jointly explain exactly 2 units of QR energy per frequency, so the")
    print("   total is p-1 = ||QR||^2 and the residual is exactly zero.\n")
    print(f"   {'p':>4} {'||QR||^2':>10} {'explained':>14} {'residual energy':>17}")
    for p in primes:
        qr = qr_feature(p)
        feats: List[Vector] = []
        for k in range(1, (p - 1) // 2 + 1):
            feats.append(phase_cos(k, p))
            feats.append(phase_sin(k, p))
        explained = sum(gain(qr, v) for v in feats)
        fitted = combo([dot(qr, v) / sqnorm(v) for v in feats], feats)
        resid = sqnorm([qr[i] - fitted[i] for i in range(p)])
        print(f"   {p:>4} {sqnorm(qr):>10.6f} {explained:>14.9f} {resid:>17.3e}")
        assert abs(explained - (p - 1)) < 1e-7
        assert resid < 1e-16 * max(1.0, p) or resid < 1e-12
    print("   OK: the quadratic-residue indicator adds no capacity whatsoever")
    print("       to a full-frequency phase design.")


def demo_window_locality() -> None:
    banner("9.  Window locality: what a negative out-of-sample score certifies")
    print("   Transported gain is the exact parabola")
    print("      gain_oos(b) = ||f||^2 ( beta*^2 - (b - beta*)^2 ).\n")
    n = 200
    e = [math.sin(0.37 * i) + 0.4 * math.cos(1.13 * i) for i in range(n)]
    f = [math.cos(0.29 * i + 0.5) for i in range(n)]
    beta_star = dot(e, f) / sqnorm(f)
    print(f"   test-window optimum beta* = {beta_star:.6f}")
    print(f"   {'b':>10} {'gain_oos(b)':>14} {'parabola':>14} {'|b-beta*|':>12}")
    for b in (beta_star, 0.5 * beta_star, 0.0, -beta_star, -3 * beta_star):
        g_direct = sqnorm(e) - sqnorm([e[i] - b * f[i] for i in range(n)])
        g_par = sqnorm(f) * (beta_star ** 2 - (b - beta_star) ** 2)
        print(f"   {b:>10.5f} {g_direct:>14.6f} {g_par:>14.6f} {abs(b - beta_star):>12.6f}")
        assert abs(g_direct - g_par) < 1e-8
    print("   OK: the identity is exact; the in-window fit b = beta* is the maximum,")
    print("       and gain_oos < 0 exactly when |b - beta*| > |beta*|.\n")
    for label, rho in (("phase-only arm  (-0.077)", 0.077), ("baseline 0.600 -> 0.400", 0.200)):
        print(f"   {label}: standardized coefficient miss >= sqrt({rho}) = {math.sqrt(rho):.4f}")
    print("   => the baseline is itself window-local, by a larger margin than the phases.")


def demo_leakage() -> None:
    banner("10.  Same-window leakage: identity, inversion, and a free falsification test")
    n = 400
    e = [math.sin(0.21 * i) for i in range(n)]
    g = [math.cos(0.77 * i) for i in range(n)]
    # orthogonalise g against e
    c = dot(e, g) / sqnorm(e)
    g = [g[i] - c * e[i] for i in range(n)]
    print(f"   {'alpha':>8} {'in-window R^2':>15} {'identity':>12} {'leak ratio':>12}")
    for alpha in (0.1, 0.3, 0.6, 1.0, 2.0):
        f = [alpha * e[i] + g[i] for i in range(n)]
        r2 = gain(e, f) / sqnorm(e)
        ident = alpha ** 2 * sqnorm(e) / (alpha ** 2 * sqnorm(e) + sqnorm(g))
        ratio = alpha ** 2 * sqnorm(e) / sqnorm(g)
        print(f"   {alpha:>8.2f} {r2:>15.6f} {ident:>12.6f} {ratio:>12.6f}")
        assert abs(r2 - ident) < 1e-9
        assert abs(ratio - r2 / (1 - r2)) < 1e-7
    print()
    print("   Inversion: an in-window R^2 of r pins the leaked/orthogonal energy")
    print("   ratio at r/(1-r);  r = 0.6 gives 1.5.")
    print(f"   Falsification threshold: any feature with in-window R^2 >= 0.6 must")
    print(f"   correlate with the REALIZED target at level >= sqrt(0.6) = {math.sqrt(0.6):.6f}.")
    # signature of leakage: transported coefficient on a fresh window
    alpha = 0.8
    f = [alpha * e[i] + g[i] for i in range(n)]
    beta = dot(e, f) / sqnorm(f)
    e2 = [math.sin(0.21 * i + 1.9) for i in range(n)]
    f2 = [g[i] for i in range(n)]
    c2 = dot(e2, f2) / sqnorm(e2)
    f2 = [f2[i] - c2 * e2[i] for i in range(n)]  # zero covariance on the fresh window
    oos = sqnorm(e2) - sqnorm([e2[i] - beta * f2[i] for i in range(n)])
    print(f"\n   transported coefficient beta = {beta:.6f} on a fresh window with zero")
    print(f"   covariance gives out-of-sample gain = {oos:.6f}  (< 0, as predicted)")
    assert oos < 0


def demo_higher_prime_cost() -> None:
    banner("11.  The cost of the higher-prime explanation")
    print("   Covering an excess Delta with blocks capped at 3 eps^2/0.18 requires")
    print("   n >= 0.06 Delta / eps^2 orthogonal prime blocks.\n")
    print(f"   {'Delta':>8} {'eps':>8} {'blocks needed':>15}")
    for delta_excess, eps in ((0.2, 0.01), (0.2, 0.02), (0.1, 0.01), (0.05, 0.01)):
        n = 0.06 * delta_excess / eps ** 2
        print(f"   {delta_excess:>8.2f} {eps:>8.3f} {n:>15.1f}")
    print("\n   The design supplied 9 blocks; Delta = 0.2 at eps = 0.01 needs >= 120.")
    assert 0.06 * 0.2 / 0.01 ** 2 >= 120.0


def main() -> None:
    print(__doc__)
    demo_trig_orthogonality()
    demo_cross_prime()
    demo_gauss()
    demo_block_constant_exact()
    demo_lift_ceiling()
    demo_certificate()
    demo_full_frequency_degeneracy()
    demo_window_locality()
    demo_leakage()
    demo_higher_prime_cost()
    banner("All numerical checks passed.")


if __name__ == "__main__":
    main()
