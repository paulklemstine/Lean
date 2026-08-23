"""
Draw-Regime Invariance of Weighted Covariance Dials
===================================================

Numerical demonstration of the results on draw-regime invariance of weighted
covariance "dials".

Setting
-------
A finite population of `keys`, key i carrying a footprint x_i and a yield rate
y_i.  A *draw regime* is a probability weighting p (p_i >= 0, sum p_i = 1);
balanced/uniform and genuinely unbalanced draws are both instances.

The dial is the weighted covariance

    Cov_p(x, y) = sum_i p_i (x_i - mu_p(x)) (y_i - mu_p(y)).

Everything below rests on the weighted Hoeffding-Chebyshev pair identity

    2 Cov_p(x, y) = sum_{i,j} p_i p_j (x_i - x_j)(y_i - y_j),

whose right-hand side factors into a regime-free population part
D_ij = (x_i - x_j)(y_i - y_j) and nonnegative regime pair masses p_i p_j.

Demonstrations
--------------
1.  The pair identity holds to machine precision, on random data.
2.  Comonotone populations: the dial is positive in EVERY draw regime,
    including adversarially unbalanced ones (no dilution).
3.  Monotone re-encoding (ranks, logs, cubes) preserves the guarantee.
4.  The l1 stability bound |Cov_p - Cov_q| <= Mx*My*||p-q||_1.
5.  The exact quadratic law along a regime homotopy, and the (1/2)*min floor.
6.  The concordance budget and the kappa^2 < C/Delta triage rule.
7.  The worked four-key population: R^2 is NOT regime invariant, but the
    ordering of competing dials is.
8.  The augmentation gain identity <r,z>^2 / ||z||^2.

Run:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

Vec = Sequence[float]

# ----------------------------------------------------------------------------
# Core weighted moment machinery
# ----------------------------------------------------------------------------


def wmean(p: Vec, x: Vec) -> float:
    """Weighted mean sum_i p_i x_i under draw regime p."""
    return sum(pi * xi for pi, xi in zip(p, x))


def wcov(p: Vec, x: Vec, y: Vec) -> float:
    """Weighted covariance (the dial) of x and y under draw regime p."""
    mx = wmean(p, x)
    my = wmean(p, y)
    return sum(pi * (xi - mx) * (yi - my) for pi, xi, yi in zip(p, x, y))


def wvar(p: Vec, x: Vec) -> float:
    """Weighted variance of x under draw regime p."""
    return wcov(p, x, x)


def r2(p: Vec, x: Vec, y: Vec) -> float:
    """Variance share R^2 = Cov^2 / (Var x * Var y) under draw regime p."""
    return wcov(p, x, y) ** 2 / (wvar(p, x) * wvar(p, y))


def concordance_matrix(x: Vec, y: Vec) -> List[List[float]]:
    """The regime-free hollow symmetric matrix D_ij = (x_i-x_j)(y_i-y_j)."""
    n = len(x)
    return [[(x[i] - x[j]) * (y[i] - y[j]) for j in range(n)] for i in range(n)]


def pair_form(p: Vec, x: Vec, y: Vec) -> float:
    """Right-hand side of the pair identity, divided by 2."""
    d = concordance_matrix(x, y)
    n = len(x)
    return 0.5 * sum(p[i] * p[j] * d[i][j] for i in range(n) for j in range(n))


def cross_term(p: Vec, q: Vec, x: Vec, y: Vec) -> float:
    """K(p,q) = (1/2) sum_{i,j} p_i q_j D_ij, the homotopy cross term."""
    d = concordance_matrix(x, y)
    n = len(x)
    return 0.5 * sum(p[i] * q[j] * d[i][j] for i in range(n) for j in range(n))


def masses(x: Vec, y: Vec) -> Tuple[float, float]:
    """Concordance mass C and discordance mass Delta of the population."""
    d = concordance_matrix(x, y)
    c = sum(max(v, 0.0) for row in d for v in row)
    delta = sum(max(-v, 0.0) for row in d for v in row)
    return c, delta


def is_comonotone(x: Vec, y: Vec, tol: float = 1e-12) -> bool:
    """True iff no pair of keys is discordant."""
    d = concordance_matrix(x, y)
    return all(v >= -tol for row in d for v in row)


def mix(p: Vec, q: Vec, t: float) -> List[float]:
    """The regime homotopy p^t = (1-t)p + t q."""
    return [(1.0 - t) * a + t * b for a, b in zip(p, q)]


def l1(p: Vec, q: Vec) -> float:
    """l1 distance = twice the total-variation distance."""
    return sum(abs(a - b) for a, b in zip(p, q))


def ranks(v: Vec) -> List[float]:
    """Average ranks of v (a nondecreasing re-encoding)."""
    n = len(v)
    order = sorted(range(n), key=lambda i: v[i])
    out = [0.0] * n
    i = 0
    while i < n:
        j = i
        while j + 1 < n and v[order[j + 1]] == v[order[i]]:
            j += 1
        avg = (i + j) / 2.0 + 1.0
        for k in range(i, j + 1):
            out[order[k]] = avg
        i = j + 1
    return out


def random_regime(n: int, rng: random.Random, concentration: float = 1.0) -> List[float]:
    """A random draw regime; small concentration => very unbalanced."""
    raw = [rng.gammavariate(concentration, 1.0) + 1e-12 for _ in range(n)]
    s = sum(raw)
    return [v / s for v in raw]


def rule(title: str) -> None:
    print()
    print("=" * 76)
    print(title)
    print("=" * 76)


# ----------------------------------------------------------------------------
# 1. The pair identity
# ----------------------------------------------------------------------------


def demo_pair_identity(rng: random.Random) -> None:
    rule("1.  The pair identity:  2 Cov_p(x,y) = sum_ij p_i p_j (x_i-x_j)(y_i-y_j)")
    print("Random populations and random (often very unbalanced) regimes.\n")
    print(f"{'n':>4} {'conc':>6} {'Cov (moment form)':>20} {'Cov (pair form)':>18} {'abs diff':>12}")
    worst = 0.0
    for trial in range(8):
        n = rng.randint(3, 9)
        conc = [3.0, 1.0, 0.15][trial % 3]
        x = [rng.uniform(-5, 5) for _ in range(n)]
        y = [rng.uniform(-5, 5) for _ in range(n)]
        p = random_regime(n, rng, conc)
        a, b = wcov(p, x, y), pair_form(p, x, y)
        worst = max(worst, abs(a - b))
        print(f"{n:>4} {conc:>6.2f} {a:>20.12f} {b:>18.12f} {abs(a - b):>12.2e}")
    print(f"\nWorst discrepancy over all trials: {worst:.3e}  (machine precision)")


# ----------------------------------------------------------------------------
# 2. No dilution for comonotone populations
# ----------------------------------------------------------------------------


def demo_no_dilution(rng: random.Random) -> None:
    rule("2.  No dilution: a comonotone population reads positive in EVERY regime")
    x = [1.0, 2.0, 4.0, 8.0, 11.0, 17.0]
    y = [1.0, 2.0, 5.0, 9.0, 10.0, 20.0]
    n = len(x)
    c, delta = masses(x, y)
    print(f"footprint x = {x}")
    print(f"yield     y = {y}")
    print(f"comonotone: {is_comonotone(x, y)}   C = {c:.1f}   Delta = {delta:.1f}\n")

    named: List[Tuple[str, List[float]]] = [
        ("uniform / balanced", [1.0 / n] * n),
        ("mildly tilted", [0.30, 0.20, 0.15, 0.15, 0.10, 0.10]),
        ("severely unbalanced", [0.90, 0.02, 0.02, 0.02, 0.02, 0.02]),
        ("mass on the tail", [0.02, 0.02, 0.02, 0.02, 0.02, 0.90]),
        ("two-point support", [0.5, 0.0, 0.0, 0.0, 0.0, 0.5]),
    ]
    print(f"{'draw regime':>22} {'Cov_p(x,y)':>14} {'sign':>6}")
    for name, p in named:
        v = wcov(p, x, y)
        print(f"{name:>22} {v:>14.6f} {'+' if v > 0 else ('0' if v == 0 else '-'):>6}")

    print("\n2000 random regimes with concentration 0.05 (extremely lopsided):")
    lo = math.inf
    for _ in range(2000):
        p = random_regime(n, rng, 0.05)
        lo = min(lo, wcov(p, x, y))
    print(f"  minimum dial observed = {lo:.10f}   (theory guarantees >= 0)")
    print("  Not one regime out of 2000 flipped the sign.  This is Theorem 4.2:")
    print("  every summand p_i p_j D_ij is a product of nonnegative numbers.")


# ----------------------------------------------------------------------------
# 3. Monotone re-encoding / rank dials
# ----------------------------------------------------------------------------


def demo_monotone_reencoding(rng: random.Random) -> None:
    rule("3.  Monotone re-encoding: the guarantee survives ranks, logs, cubes")
    x = [0.5, 1.3, 2.9, 4.1, 9.7]
    y = [0.2, 0.9, 1.0, 6.6, 6.7]
    n = len(x)
    print(f"footprint x = {x}\nyield     y = {y}\ncomonotone: {is_comonotone(x, y)}\n")

    encodings: List[Tuple[str, Callable[[Vec], List[float]]]] = [
        ("identity", lambda v: list(v)),
        ("rank (Spearman)", lambda v: ranks(v)),
        ("log(1+v)", lambda v: [math.log1p(t) for t in v]),
        ("v^3", lambda v: [t ** 3 for t in v]),
        ("arctan", lambda v: [math.atan(t) for t in v]),
    ]
    p_bal = [1.0 / n] * n
    p_unb = [0.80, 0.05, 0.05, 0.05, 0.05]
    print(f"{'g = h =':>18} {'comonotone?':>12} {'Cov balanced':>15} {'Cov unbalanced':>16}")
    for name, f in encodings:
        gx, hy = f(x), f(y)
        print(
            f"{name:>18} {str(is_comonotone(gx, hy)):>12} "
            f"{wcov(p_bal, gx, hy):>15.6f} {wcov(p_unb, gx, hy):>16.6f}"
        )
    print("\nAll positive.  Comonotonicity is an ORDINAL property: a nondecreasing")
    print("map cannot create a discordant pair, so Theorem 4.6 applies verbatim.")


# ----------------------------------------------------------------------------
# 4. l1 stability
# ----------------------------------------------------------------------------


def demo_l1_stability(rng: random.Random) -> None:
    rule("4.  l1 stability:  |Cov_p - Cov_q|  <=  Mx * My * ||p - q||_1")
    n = 7
    x = [rng.uniform(-3, 3) for _ in range(n)]
    y = [rng.uniform(-3, 3) for _ in range(n)]
    mx = max(x) - min(x)
    my = max(y) - min(y)
    print(f"range Mx = {mx:.4f}   range My = {my:.4f}   product = {mx * my:.4f}\n")
    print(f"{'||p-q||_1':>12} {'|Cov_p - Cov_q|':>18} {'bound':>14} {'slack':>12} {'ok':>4}")
    ok = True
    for _ in range(10):
        p = random_regime(n, rng, rng.choice([0.1, 0.5, 2.0, 8.0]))
        q = random_regime(n, rng, rng.choice([0.1, 0.5, 2.0, 8.0]))
        d = l1(p, q)
        actual = abs(wcov(p, x, y) - wcov(q, x, y))
        bound = mx * my * d
        ok = ok and actual <= bound + 1e-12
        print(f"{d:>12.6f} {actual:>18.6f} {bound:>14.6f} {bound - actual:>12.6f} "
              f"{'yes' if actual <= bound + 1e-12 else 'NO':>4}")
    print(f"\nBound respected in every trial: {ok}")
    print("The bound is a worst case over all populations with those ranges, so")
    print("real populations sit comfortably inside it.  What matters is that the")
    print("dial is LIPSCHITZ in the sampling weights: l1-close regimes must agree.")


# ----------------------------------------------------------------------------
# 5. The exact quadratic homotopy law
# ----------------------------------------------------------------------------


def demo_homotopy() -> None:
    rule("5.  The exact quadratic law along a regime homotopy")
    x = [1.0, 2.0, 4.0, 8.0]
    y = [1.0, 2.0, 5.0, 9.0]
    p = [0.25, 0.25, 0.25, 0.25]
    q = [0.70, 0.10, 0.10, 0.10]
    cp, cq = wcov(p, x, y), wcov(q, x, y)
    k = cross_term(p, q, x, y)
    print(f"Cov_p = {cp:.6f}   Cov_q = {cq:.6f}   cross term K(p,q) = {k:.6f}")
    print(f"predicted curve:  Cov_(p^t) = (1-t)^2*{cp:.4f} + 2t(1-t)*{k:.4f} + t^2*{cq:.4f}\n")
    print(f"{'t':>6} {'direct':>14} {'quadratic law':>16} {'diff':>11} {'envelope':>11} {'floor':>9}")
    floor = 0.5 * min(cp, cq)
    for i in range(11):
        t = i / 10.0
        direct = wcov(mix(p, q, t), x, y)
        pred = (1 - t) ** 2 * cp + 2 * t * (1 - t) * k + t ** 2 * cq
        env = (1 - t) ** 2 * cp + t ** 2 * cq
        print(f"{t:>6.1f} {direct:>14.8f} {pred:>16.8f} {abs(direct - pred):>11.1e} "
              f"{env:>11.6f} {floor:>9.6f}")
    print("\nThe law is EXACT, not an approximation.  Since K >= 0 for comonotone")
    print("populations, the curve never drops below the pure envelope, and since")
    print("(1-t)^2 + t^2 >= 1/2 it never drops below half the smaller endpoint.")
    print("There is no 'interior collapse' where a mixture of regimes loses the signal.")


# ----------------------------------------------------------------------------
# 6. The concordance budget and the triage rule
# ----------------------------------------------------------------------------


def demo_triage() -> None:
    rule("6.  Concordance budget and the kappa^2 < C/Delta triage rule")
    # A population that is mostly monotone but has one genuine exception:
    # the largest key (footprint 12) underperforms badly.
    x = [1.0, 2.0, 4.0, 7.0, 12.0]
    y = [1.0, 3.0, 6.0, 10.0, 4.0]
    c, delta = masses(x, y)
    kappa_max = math.sqrt(c / delta)
    print(f"footprint x = {x}")
    print(f"yield     y = {y}   (the largest key is an exception: big but low yield)")
    print(f"comonotone: {is_comonotone(x, y)}")
    print(f"concordance mass C = {c:.1f}   discordance mass Delta = {delta:.1f}")
    print(f"threshold  C/Delta = {c / delta:.4f}   =>  kappa_max = {kappa_max:.4f}\n")

    print(f"{'kappa':>8} {'eps':>10} {'M':>10} {'budget bound':>15} {'certified?':>13}")
    n = len(x)
    for kappa in [1.0, 1.5, 1.8, 1.9, 2.0, 3.0, 5.0]:
        # a family of regimes with p_i in [eps, M], M/eps = kappa, sum = 1
        eps = 1.0 / (n - 1 + kappa)
        m = kappa * eps
        bound = eps ** 2 * c - m ** 2 * delta
        print(f"{kappa:>8.2f} {eps:>10.6f} {m:>10.6f} {bound:>15.6f} "
              f"{('YES' if bound > 0 else 'inconclusive'):>13}")

    print(f"\nThe certificate lapses exactly at kappa_max = {kappa_max:.4f}, as predicted.")
    print("Below it, EVERY admissible regime is certified positive without sampling")
    print("anything at all.  Above it the guarantee really does end - an adversarial")
    print("regime can concentrate its mass on the discordant pair and flip the sign:\n")
    for label, p_adv in [
        ("uniform (kappa = 1)", [1.0 / n] * n),
        ("tilted (kappa = 2)", [1.0 / 6, 1.0 / 6, 1.0 / 6, 1.0 / 6, 1.0 / 3]),
        ("adversarial (kappa = 98.5)", [0.005, 0.005, 0.005, 0.4925, 0.4925]),
    ]:
        print(f"  {label:>28}:  Cov = {wcov(p_adv, x, y):>10.6f}")
    print("\nThe triage rule is therefore not merely sufficient but genuinely")
    print("informative: it marks the boundary where the guarantee really ends.")


# ----------------------------------------------------------------------------
# 7. The worked four-key population: what is and is not invariant
# ----------------------------------------------------------------------------


def demo_worked_example() -> None:
    rule("7.  The worked four-key population: R^2 is NOT regime invariant")
    fw = [1.0, 2.0, 4.0, 8.0]   # footprint dial
    fc = [1.0, 1.0, 2.0, 2.0]   # plain count (rival predictor)
    fy = [1.0, 2.0, 5.0, 9.0]   # yield rate
    pu = [0.25, 0.25, 0.25, 0.25]
    pq = [0.70, 0.10, 0.10, 0.10]
    print(f"footprint  x = {fw}")
    print(f"count      z = {fc}")
    print(f"yield      y = {fy}")
    print(f"balanced   p = {pu}")
    print(f"unbalanced q = {pq}")
    print(f"l1 distance ||p-q||_1 = {l1(pu, pq):.4f}  (total variation {l1(pu, pq)/2:.4f})\n")

    c, delta = masses(fw, fy)
    print(f"C = {c:.0f}, Delta = {delta:.0f}  =>  comonotone, so both dials must be positive.")
    print(f"  Cov_p(x,y) = {wcov(pu, fw, fy):.6f}")
    print(f"  Cov_q(x,y) = {wcov(pq, fw, fy):.6f}\n")

    print(f"{'quantity':>28} {'balanced p':>14} {'unbalanced q':>15}")
    print(f"{'R^2 of footprint dial':>28} {r2(pu, fw, fy):>14.6f} {r2(pq, fw, fy):>15.6f}")
    print(f"{'R^2 of plain count':>28} {r2(pu, fc, fy):>14.6f} {r2(pq, fc, fy):>15.6f}")
    adv_u = r2(pu, fw, fy) - r2(pu, fc, fy)
    adv_q = r2(pq, fw, fy) - r2(pq, fc, fy)
    print(f"{'advantage of footprint':>28} {adv_u:>+14.6f} {adv_q:>+15.6f}")

    print("\nORDERING is stable  -> footprint beats count in both regimes.")
    print(f"MARGIN is not       -> it falls from {adv_u:.4f} to {adv_q:.4f}.")
    print("That is the honest boundary of 'identical within noise'.  R^2 is a ratio")
    print("of regime-dependent quantities; nothing forces it to be invariant.")

    print("\nThe exact-driver case, where the ordering IS forced:")
    exact = [3.0 + 1.5 * v for v in fw]     # y = 3 + 1.5 x, an exact affine driver
    for name, p in [("balanced", pu), ("unbalanced", pq)]:
        print(f"  {name:>10}:  R^2(footprint) = {r2(p, fw, exact):.12f}   "
              f"R^2(count) = {r2(p, fc, exact):.6f}")
    print("  R^2 = 1 in EVERY regime when the footprint is the exact mechanism, so")
    print("  no rival can ever beat it, whatever the draw (Theorem 8.14).")


# ----------------------------------------------------------------------------
# 8. Augmentation gain
# ----------------------------------------------------------------------------


def demo_augmentation(rng: random.Random) -> None:
    rule("8.  Augmentation gain:  the fit improves by exactly <r,z>^2 / ||z||^2")
    n = 6
    p = random_regime(n, rng, 0.6)
    r = [rng.uniform(-2, 2) for _ in range(n)]
    z = [rng.uniform(-2, 2) for _ in range(n)]
    ip = sum(pi * ri * zi for pi, ri, zi in zip(p, r, z))
    nz = sum(pi * zi ** 2 for pi, zi in zip(p, z))
    c_star = ip / nz
    before = sum(pi * ri ** 2 for pi, ri in zip(p, r))
    after = sum(pi * (ri - c_star * zi) ** 2 for pi, ri, zi in zip(p, r, z))
    predicted = before - ip ** 2 / nz
    print(f"residual norm before   ||r||^2_p        = {before:.10f}")
    print(f"optimal coefficient    c* = <r,z>/||z||^2 = {c_star:.10f}")
    print(f"residual norm after    ||r - c* z||^2_p  = {after:.10f}")
    print(f"predicted by identity                    = {predicted:.10f}")
    print(f"discrepancy                              = {abs(after - predicted):.3e}")
    print(f"gain  <r,z>^2 / ||z||^2                  = {ip ** 2 / nz:.10f}")
    print("\nThis is the Pythagorean theorem in the inner product the regime induces:")
    print("<r,z>_p = sum_i p_i r_i z_i.  The gain is strictly positive whenever the")
    print("residual is not orthogonal to the new regressor - a condition you can")
    print("check from the sample in hand, which is what justifies augmented-R^2")
    print("comparisons in the first place.")


# ----------------------------------------------------------------------------


def main() -> None:
    rng = random.Random(20260924)
    print(__doc__.split("Run:")[0].rstrip())
    demo_pair_identity(rng)
    demo_no_dilution(rng)
    demo_monotone_reencoding(rng)
    demo_l1_stability(rng)
    demo_homotopy()
    demo_triage()
    demo_worked_example()
    demo_augmentation(rng)
    rule("Summary")
    print("""
Always safe        : the SIGN of the dial, for comonotone populations, in every
                     draw regime, and after any monotone re-encoding of either
                     coordinate (so rank / Spearman dials inherit it).
Quantitatively safe: the covariance moves by at most (range x)*(range y) times
                     the l1 distance between regimes; along any path between two
                     regimes it never falls below half the smaller endpoint.
Conditionally safe : with discordance Delta > 0, positivity still holds for every
                     regime whose conditioning number kappa satisfies
                     kappa^2 < C / Delta.
Not safe           : the numerical variance share R^2.  It genuinely moves - in
                     the worked example the footprint's advantage over the plain
                     count fell from 0.2117 to 0.1337 - while the ordering held.
""".strip())


if __name__ == "__main__":
    main()
