"""
Numerical demonstrations for
"What a Null R^2 Certifies: Margin Ceilings, Contrast Inequalities, and
 Sign-Blindness in a Quadratic-Character Effectivity Sweep".

Self-contained: standard library only (math, random, itertools, typing).

The script demonstrates, numerically, every theorem of the paper:

  1. The arithmetic setting: primes in residue classes, the deviation readout
     D(m) = max_a |pi(x;m,a) - E| / sqrt(E), the quadratic-character L-mass
     P(m) = sum_chi |L(1,chi)|, and the recorded null: the L-mass explains
     almost nothing, while log m explains most of the variance.
  2. The exact ANOVA identity TSS = withinSS + betweenSS, and the fact that
     the explained energy of the class of ALL functions of a feature is
     exactly the between-cell energy.
  3. The margin ceiling: no threshold criterion on the feature can separate
     the response by more than sqrt(rho) sample standard deviations.
  4. The cell-gap, contrast, and group ceilings, plus their sharpness.
  5. Size domination: near-affinity in a size covariate is by itself enough
     to force a high R^2, with no arithmetic content.
  6. The vacuous permutation control (p == 1 identically) and its additive
     repair (two-point p-value == 1/2 exactly).
  7. Sign-blindness: two count fields mod p = 3 (mod 4) with identical
     readouts and exactly opposite maximal character alignments.
  8. Verification of the exact L-value anchor L(1, chi_{-3}) = pi/(3 sqrt 3).

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

random.seed(566)

Vec = List[float]

# --------------------------------------------------------------------------
# 0. Elementary number theory
# --------------------------------------------------------------------------


def sieve_primes(limit: int) -> List[int]:
    """All primes <= limit by a simple sieve of Eratosthenes."""
    if limit < 2:
        return []
    flags: List[bool] = [True] * (limit + 1)
    flags[0] = flags[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if flags[i]:
            for j in range(i * i, limit + 1, i):
                flags[j] = False
    return [i for i, ok in enumerate(flags) if ok]


def euler_phi(n: int) -> int:
    """Euler's totient function."""
    result, m = n, n
    p = 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


def kronecker_symbol(d: int, n: int) -> int:
    """Kronecker symbol (d/n) for n >= 1; the real character attached to d."""
    if n == 0:
        return 1 if d in (1, -1) else 0
    if math.gcd(d, n) != 1:
        return 0
    result = 1
    m = n
    # factor out 2s: (d/2) = 0, 1, -1 according to d mod 8
    while m % 2 == 0:
        m //= 2
        r = d % 8
        if r in (3, 5):
            result = -result
    # Jacobi symbol (d/m) for odd m by quadratic reciprocity
    a = d % m
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if m % 8 in (3, 5):
                result = -result
        a, m = m, a
        if a % 4 == 3 and m % 4 == 3:
            result = -result
        a %= m
    return result if m == 1 else 0


def l_value_at_one(d: int, terms: int = 200_000) -> float:
    """Truncated Dirichlet series for L(1, chi_d) = sum_{n>=1} (d/n)/n.

    Uses averaging of consecutive partial sums (Cesaro smoothing) to damp the
    oscillation of the alternating tail; adequate for demonstration accuracy.
    """
    total = 0.0
    partials: List[float] = []
    for n in range(1, terms + 1):
        c = kronecker_symbol(d, n)
        if c:
            total += c / n
        if n > terms - 64:
            partials.append(total)
    return sum(partials) / len(partials)


def exact_l_value_imaginary(d: int, h: int, w: int) -> float:
    """Class-number formula for a negative fundamental discriminant d < 0:
        L(1, chi_d) = 2*pi*h / (w * sqrt(|d|)).
    """
    return 2.0 * math.pi * h / (w * math.sqrt(abs(d)))


def real_characters_mod(m: int) -> List[int]:
    """Fundamental discriminants d with |d| dividing m, giving the nontrivial
    real characters modulo m (a standard enumeration for squarefree-ish m)."""
    out: List[int] = []
    for k in range(2, m + 1):
        if m % k:
            continue
        for d in (k, -k):
            if is_fundamental_discriminant(d):
                out.append(d)
    return out


def is_fundamental_discriminant(d: int) -> bool:
    """Test whether d is a fundamental discriminant."""
    if d in (0, 1):
        return False
    if d % 4 == 1:
        return squarefree(d)
    if d % 4 == 0:
        e = d // 4
        return (e % 4 in (2, 3)) and squarefree(e)
    return False


def squarefree(n: int) -> bool:
    n = abs(n)
    if n == 0:
        return False
    i = 2
    while i * i <= n:
        if n % (i * i) == 0:
            return False
        i += 1
    return True


# --------------------------------------------------------------------------
# 1. The arithmetic sweep in miniature
# --------------------------------------------------------------------------


def deviation_readout(primes: Sequence[int], m: int) -> float:
    """D(m) = max_a |pi(x;m,a) - E| / sqrt(E) over admissible classes."""
    counts: Dict[int, int] = {}
    for p in primes:
        if p == m or m % p == 0:
            continue
        counts[p % m] = counts.get(p % m, 0) + 1
    admissible = [a for a in range(m) if math.gcd(a, m) == 1]
    total = sum(counts.get(a, 0) for a in admissible)
    if not admissible or total == 0:
        return 0.0
    e = total / len(admissible)
    return max(abs(counts.get(a, 0) - e) for a in admissible) / math.sqrt(e)


def l_mass(m: int) -> float:
    """P(m) = sum over nontrivial real characters mod m of |L(1, chi)|."""
    return sum(abs(l_value_at_one(d, terms=20_000)) for d in real_characters_mod(m))


# --------------------------------------------------------------------------
# 2. Finite-sample regression primitives
# --------------------------------------------------------------------------


def mean(v: Sequence[float]) -> float:
    return sum(v) / len(v)


def tss(y: Sequence[float]) -> float:
    m = mean(y)
    return sum((yi - m) ** 2 for yi in y)


def r2_affine(y: Sequence[float], x: Sequence[float]) -> float:
    """R^2 of the class of affine functions of x (ordinary least squares)."""
    mx, my = mean(x), mean(y)
    sxx = sum((xi - mx) ** 2 for xi in x)
    if sxx == 0.0:
        return 0.0
    sxy = sum((xi - mx) * (yi - my) for xi, yi in zip(x, y))
    b = sxy / sxx
    rss = sum((yi - (my + b * (xi - mx))) ** 2 for xi, yi in zip(x, y))
    t = tss(y)
    return 0.0 if t == 0.0 else 1.0 - rss / t


def cells(feature: Sequence[float]) -> Dict[float, List[int]]:
    """Level sets of a feature: value -> list of sample indices."""
    out: Dict[float, List[int]] = {}
    for i, f in enumerate(feature):
        out.setdefault(f, []).append(i)
    return out


def within_ss(y: Sequence[float], feature: Sequence[float]) -> float:
    total = 0.0
    for idx in cells(feature).values():
        mc = sum(y[i] for i in idx) / len(idx)
        total += sum((y[i] - mc) ** 2 for i in idx)
    return total


def between_ss(y: Sequence[float], feature: Sequence[float]) -> float:
    my = mean(y)
    total = 0.0
    for idx in cells(feature).values():
        mc = sum(y[i] for i in idx) / len(idx)
        total += len(idx) * (mc - my) ** 2
    return total


def r2_measurable(y: Sequence[float], feature: Sequence[float]) -> float:
    """R^2 of the class of ALL functions of the feature: the cell-mean fit."""
    t = tss(y)
    return 0.0 if t == 0.0 else between_ss(y, feature) / t


def discretize(x: Sequence[float], bins: int) -> List[float]:
    """Coarsen a continuous feature into `bins` equal-width levels."""
    lo, hi = min(x), max(x)
    if hi == lo:
        return [0.0] * len(x)
    return [float(min(bins - 1, int(bins * (xi - lo) / (hi - lo)))) for xi in x]


# --------------------------------------------------------------------------
# 3. The readouts, the alignment, and the controls
# --------------------------------------------------------------------------


def max_dev(c: Sequence[float], e: float) -> float:
    return max(abs(ci - e) for ci in c) / math.sqrt(e)


def chi_sq(c: Sequence[float], e: float) -> float:
    return sum((ci - e) ** 2 for ci in c) / e


def align(c: Sequence[float], w: Sequence[float]) -> float:
    return sum(ci * wi for ci, wi in zip(c, w))


def perm_p_value(stat: Callable[[Sequence[float]], float],
                 c: Sequence[float],
                 max_perms: int = 5040) -> float:
    """One-sided permutation p-value: fraction of relabelings with T(c) <= T(c o sigma)."""
    n = len(c)
    if math.factorial(n) <= max_perms:
        perms = list(itertools.permutations(range(n)))
    else:
        perms = [tuple(random.sample(range(n), n)) for _ in range(max_perms)]
    observed = stat(c)
    hits = sum(1 for s in perms if observed <= stat([c[s[i]] for i in range(n)]))
    return hits / len(perms)


def two_point_p_value(stat: Callable[[Sequence[float]], float],
                      c: Sequence[float],
                      w: Sequence[float],
                      t: float) -> float:
    """p-value under the symmetric additive randomization c -> c +/- t*w."""
    observed = stat(c)
    up = [ci + t * wi for ci, wi in zip(c, w)]
    down = [ci - t * wi for ci, wi in zip(c, w)]
    return ((1.0 if observed <= stat(up) else 0.0)
            + (1.0 if observed <= stat(down) else 0.0)) / 2.0


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_exact_l_value() -> None:
    print("=" * 74)
    print("1. Verification of the L-value path: the exact anchor")
    print("=" * 74)
    exact = exact_l_value_imaginary(-3, h=1, w=6)     # = pi / (3 sqrt 3)
    closed = math.pi / (3.0 * math.sqrt(3.0))
    approx = l_value_at_one(-3, terms=200_000)
    print(f"  class-number formula 2*pi*h/(w*sqrt|d|)  = {exact:.9f}")
    print(f"  closed form pi/(3 sqrt 3)                = {closed:.9f}")
    print(f"  truncated Dirichlet series               = {approx:.9f}")
    print(f"  relative error of the series             = {abs(approx-exact)/exact:.3e}")
    print(f"  spot check L(1, chi_5)                   = {l_value_at_one(5, 200_000):.6f}"
          "   (the true value ~0.4304; the corrupted run gave 0.127)")
    print()


def demo_sweep() -> None:
    print("=" * 74)
    print("2. The sweep in miniature: L-mass explains nothing, size explains a lot")
    print("=" * 74)
    x = 200_000
    primes = sieve_primes(x)
    moduli = [m for m in range(3, 121) if squarefree(m)]
    y = [deviation_readout(primes, m) for m in moduli]
    p_feat = [l_mass(m) for m in moduli]
    log_y = [math.log(v) for v in y]
    log_p = [math.log(v) if v > 0 else 0.0 for v in p_feat]
    log_m = [math.log(m) for m in moduli]

    r2_lmass = r2_affine(log_y, log_p)
    r2_size = r2_affine(log_y, log_m)
    print(f"  pi(x) = {len(primes)} primes below x = {x}, {len(moduli)} moduli")
    print(f"  R^2 of log D on log P (the L-mass carrier)   = {r2_lmass:.4f}")
    print(f"  R^2 of log D on log m (the size baseline)    = {r2_size:.4f}")
    print("  Recorded at scale:  L-mass 0.0187 (x=2^26) / 0.0785 (x=2^28);"
          "  size baseline 0.790.")
    print("  The toy sweep reproduces the qualitative verdict: size dominates.")
    print()


def demo_anova() -> None:
    print("=" * 74)
    print("3. Exact ANOVA, and R^2 of ALL functions of a feature")
    print("=" * 74)
    n = 400
    feat = [float(random.randrange(7)) for _ in range(n)]
    y = [0.4 * feat[i] + random.gauss(0.0, 1.0) for i in range(n)]
    t, w, b = tss(y), within_ss(y, feat), between_ss(y, feat)
    print(f"  TSS        = {t:.9f}")
    print(f"  withinSS   = {w:.9f}")
    print(f"  betweenSS  = {b:.9f}")
    print(f"  within + between - TSS = {w + b - t:.3e}   (exact identity)")
    print(f"  R^2(all functions of the feature)      = {r2_measurable(y, feat):.6f}")
    print(f"  betweenSS / TSS                        = {b / t:.6f}   (equal, as proved)")
    print(f"  R^2(affine in the feature)             = {r2_affine(y, feat):.6f}"
          "   (<= the nonlinear class)")
    print()


def demo_margin_ceiling() -> None:
    print("=" * 74)
    print("4. The margin ceiling: no threshold criterion can separate")
    print("=" * 74)
    rho = 0.0785
    n = 2489                      # the stage-B sample size
    y = [random.gauss(0.0, 1.0) for _ in range(n)]
    t = tss(y)
    s = math.sqrt(t / n)
    delta_max = math.sqrt(rho * t / n)
    print(f"  recorded ceiling rho                   = {rho}")
    print(f"  sample size n                          = {n}")
    print(f"  sample standard deviation s            = {s:.6f}")
    print(f"  certified balanced margin delta <= sqrt(rho)*s")
    print(f"                                         = {delta_max:.6f}")
    print(f"  in standard-deviation units            = {delta_max / s:.6f}"
          f"   (= sqrt({rho}) = {math.sqrt(rho):.6f})")

    # Empirical check of the LOWER bound: a genuinely separating feature must
    # push R^2 above 4 delta^2 n1 n2 / (n TSS).
    delta = 0.6
    feature = [1.0 if i % 2 == 0 else 0.0 for i in range(n)]
    yy = [(delta + abs(random.gauss(0, .1))) if feature[i] == 1.0
          else (-delta - abs(random.gauss(0, .1))) for i in range(n)]
    n1 = sum(1 for f in feature if f == 1.0)
    n2 = n - n1
    lower = 4 * delta**2 * n1 * n2 / n
    print(f"\n  A feature that DOES separate with margin delta = {delta}:")
    print(f"    certified lower bound 4*delta^2*n1*n2/n = {lower:.4f}")
    print(f"    observed R^2 * TSS                      = "
          f"{r2_measurable(yy, feature) * tss(yy):.4f}   (>= the bound)")
    print()


def demo_cell_and_group_ceilings() -> None:
    print("=" * 74)
    print("5. Cell-gap, contrast, and group ceilings, and their sharpness")
    print("=" * 74)
    n = 1200
    feat = [float(random.randrange(6)) for _ in range(n)]
    y = [0.12 * feat[i] + random.gauss(0.0, 1.0) for i in range(n)]
    t = tss(y)
    rho = r2_measurable(y, feat)
    lv = cells(feat)
    cm = {c: sum(y[i] for i in idx) / len(idx) for c, idx in lv.items()}

    print(f"  R^2 of the whole nonlinear class: rho = {rho:.6f}")
    worst = 0.0
    for a, b in itertools.combinations(sorted(lv), 2):
        gap2 = (cm[a] - cm[b]) ** 2
        cap = rho * t * (1 / len(lv[a]) + 1 / len(lv[b]))
        worst = max(worst, gap2 / cap)
    print(f"  pairwise cell-gap ceiling: max over pairs of (gap^2 / cap) "
          f"= {worst:.4f}  (<= 1)")

    # group form: split the levels into two arbitrary groups
    levels = sorted(lv)
    a_grp, b_grp = levels[: len(levels) // 2], levels[len(levels) // 2:]
    na = sum(len(lv[c]) for c in a_grp)
    nb = sum(len(lv[c]) for c in b_grp)
    ma = sum(len(lv[c]) * cm[c] for c in a_grp) / na
    mb = sum(len(lv[c]) * cm[c] for c in b_grp) / nb
    cap = rho * t * (1 / na + 1 / nb)
    print(f"  group gap^2 = {(ma-mb)**2:.6f}   group ceiling = {cap:.6f}"
          f"   ratio = {(ma-mb)**2 / cap:.4f}  (<= 1)")

    # sharpness: response an exact function of the feature => equality, rho = 1
    g = {c: 3.0 * c - 1.0 for c in levels}
    ys = [g[f] for f in feat]
    ts = tss(ys)
    cms = {c: g[c] for c in levels}
    my = mean(ys)
    w = {c: len(lv[c]) * (cms[c] - my) for c in levels}
    lhs = sum(w[c] * (cms[c] - my) for c in levels) ** 2
    rhs = 1.0 * ts * sum(w[c] ** 2 / len(lv[c]) for c in levels)
    print(f"\n  Sharpness with {len(levels)} cells and y an exact function of the feature:")
    print(f"    sum of the optimal weights   = {sum(w.values()):.3e}   (a genuine contrast)")
    print(f"    R^2 of the nonlinear class   = {r2_measurable(ys, feat):.6f}")
    print(f"    contrast^2                   = {lhs:.6f}")
    print(f"    ceiling with rho = 1         = {rhs:.6f}")
    print(f"    relative difference          = {abs(lhs-rhs)/rhs:.3e}   (equality)")
    print()


def demo_size_domination() -> None:
    print("=" * 74)
    print("6. Size domination: a near-affine covariate reaches a high R^2 for free")
    print("=" * 74)
    n = 800
    x = [random.uniform(1.0, 8.0) for _ in range(n)]
    b = 1.0
    r = [random.gauss(0.0, 0.55) for _ in range(n)]
    r = [ri - mean(r) for ri in r]
    mx = mean(x)
    y = [b * (xi - mx) + ri for xi, ri in zip(x, r)]
    eta = sum(ri**2 for ri in r)
    spread = b**2 * sum((xi - mx) ** 2 for xi in x)
    bound = 1.0 - eta / (spread / 2.0 - eta)
    print(f"  residual energy eta                    = {eta:.4f}")
    print(f"  b^2 * ||x centred||^2                  = {spread:.4f}"
          f"   (2*eta = {2*eta:.4f} < spread, as required)")
    print(f"  certified lower bound on R^2           = {bound:.6f}")
    print(f"  actual R^2 of the affine class         = {r2_affine(y, x):.6f}"
          "   (>= the bound)")
    print("  Moral: an R^2 of ~0.79 for a size covariate needs no arithmetic content.")
    print()


def demo_controls() -> None:
    print("=" * 74)
    print("7. The vacuous permutation control, and its additive repair")
    print("=" * 74)
    e = 40.0
    c = [42.0, 37.0, 45.0, 33.0, 41.0, 39.0, 44.0]
    print(f"  count field {c}, expectation E = {e}")
    print(f"  maxDev = {max_dev(c, e):.6f},   chi^2 = {chi_sq(c, e):.6f}")
    p_max = perm_p_value(lambda v: max_dev(v, e), c)
    p_chi = perm_p_value(lambda v: chi_sq(v, e), c)
    print(f"  within-modulus permutation p-value (maxDev) = {p_max:.6f}")
    print(f"  within-modulus permutation p-value (chi^2)  = {p_chi:.6f}")
    print("  Both are exactly 1: the registered control has power exactly zero.")

    w = [1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0]
    a_coef = sum(wi**2 for wi in w)
    b_coef = sum((ci - e) * wi for ci, wi in zip(c, w))
    t_crit = 2 * abs(b_coef) / a_coef
    t = 0.5 * t_crit
    print(f"\n  additive direction w = {w}")
    print(f"  A = sum w^2 = {a_coef:.4f},  B = <c - E, w> = {b_coef:.4f},"
          f"  critical amplitude 2|B|/A = {t_crit:.4f}")
    print(f"  two-point p-value of chi^2 at t = {t:.4f}  ->  "
          f"{two_point_p_value(lambda v: chi_sq(v, e), c, w, t):.6f}   (exactly 1/2)")
    up = chi_sq([ci + t * wi for ci, wi in zip(c, w)], e)
    dn = chi_sq([ci - t * wi for ci, wi in zip(c, w)], e)
    print(f"  symmetric identity: chi2(+t) + chi2(-t) - 2*chi2(c) = {up + dn - 2*chi_sq(c,e):.6f}")
    print(f"                      2*t^2*A/E                       = {2*t*t*a_coef/e:.6f}")
    print(f"  rejection at every nonzero amplitude: max(chi2(+t), chi2(-t)) = "
          f"{max(up, dn):.6f} > {chi_sq(c, e):.6f}")

    # convexity of the maxDev amplitude profile
    ts = [-2.0, -1.0, 0.0, 1.0, 2.0]
    prof = [max_dev([ci + tt * wi for ci, wi in zip(c, w)], e) for tt in ts]
    second = [prof[i - 1] - 2 * prof[i] + prof[i + 1] for i in range(1, len(ts) - 1)]
    print(f"  maxDev amplitude profile at t = {ts}:")
    print("    " + ", ".join(f"{v:.4f}" for v in prof))
    print(f"    discrete second differences = "
          + ", ".join(f"{v:.4f}" for v in second) + "   (>= 0: convex)")
    print()


def demo_sign_blindness() -> None:
    print("=" * 74)
    print("8. Sign-blindness: identical readouts, opposite maximal alignments")
    print("=" * 74)
    for p in (7, 11, 19, 23):
        assert p % 4 == 3
        chi = [0.0] + [1.0 if pow(a, (p - 1) // 2, p) == 1 else -1.0
                       for a in range(1, p)]
        e = 100.0
        c1 = [e + chi[a] for a in range(p)]
        c2 = [c1[(-a) % p] for a in range(p)]      # reflection a -> -a
        print(f"  p = {p}:  maxDev {max_dev(c1,e):.6f} vs {max_dev(c2,e):.6f}"
              f" | chi^2 {chi_sq(c1,e):.6f} vs {chi_sq(c2,e):.6f}"
              f" | align {align(c1,chi):+.1f} vs {align(c2,chi):+.1f}"
              f"  (max = {p-1})")
    print("  The two fields are indistinguishable to every symmetric readout,")
    print("  yet their signed character alignments are exactly opposite.")
    print("  Hence: every prescribed pattern of signs across a sweep is compatible")
    print("  with one and the same response vector -- and the same R^2 in every")
    print("  model class. The magnitude null constrains the signed route not at all.")
    print()


def main() -> None:
    demo_exact_l_value()
    demo_sweep()
    demo_anova()
    demo_margin_ceiling()
    demo_cell_and_group_ceilings()
    demo_size_domination()
    demo_controls()
    demo_sign_blindness()
    print("=" * 74)
    print("All demonstrations complete.")
    print("=" * 74)


if __name__ == "__main__":
    main()
