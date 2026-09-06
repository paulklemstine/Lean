"""
Moment Fingerprint Classification of Spectral Spacing Laws
==========================================================

Self-contained numerical demonstration of the results on moment fingerprints of
nearest-neighbour level-spacing laws.

The five regimes, all normalized to mean spacing one on (0, infinity):

    rigid  (picket fence)   delta_1                                  M_2 = 1
    GSE    (beta = 4)       (2^18 / (3^6 pi^3)) s^4 e^{-64 s^2/(9pi)} M_2 = 45 pi/128
    GUE    (beta = 2)       (32/pi^2) s^2 e^{-4 s^2/pi}               M_2 = 3 pi/8
    GOE    (beta = 1)       (pi/2) s e^{-pi s^2/4}                    M_2 = 4/pi
    Poisson                 e^{-s}                                    M_2 = 2

Everything below uses only the Python standard library.

Contents
--------
  1. Closed forms and the antiderivative recursion, checked against quadrature.
  2. The even/odd closed forms  M_{2m} = (2m+1)!!(pi/8)^m,
     M_{2m+1} = (m+1)!(pi/4)^m.
  3. Absence of a higher moment coincidence, and the geometric decay bound.
  4. The index-halving duality with the exponential law.
  5. The five-rung beta-ladder and its minimal gap 3 pi/128.
  6. The second-moment classifier, its separation constant and sample threshold,
     validated on synthetic spectra sampled from each regime.
  7. Exact and quantitative rigidity of the picket-fence bucket.
  8. Hankel determinants and positive semidefiniteness of the fingerprint.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

PI: float = math.pi

# --------------------------------------------------------------------------- #
# 1. Densities, moments, recursions
# --------------------------------------------------------------------------- #


def surmise_density(beta: int) -> Callable[[float], float]:
    """Mean-one Wigner surmise density of index beta in {1, 2, 4} on (0, inf)."""
    params: Dict[int, Tuple[float, float]] = {
        1: (PI / 2.0, PI / 4.0),
        2: (32.0 / PI**2, 4.0 / PI),
        4: (2.0**18 / (3.0**6 * PI**3), 64.0 / (9.0 * PI)),
    }
    a, b = params[beta]

    def p(s: float) -> float:
        return a * s**beta * math.exp(-b * s * s)

    return p


def poisson_density(s: float) -> float:
    """Exponential (Poisson-spectrum) spacing density of mean one."""
    return math.exp(-s)


def quad_moment(p: Callable[[float], float], k: int,
                upper: float = 25.0, nodes: int = 200_000) -> float:
    """Trapezoidal quadrature of the k-th moment of the density p on (0, upper)."""
    h = upper / nodes
    total = 0.5 * (0.0**k * p(0.0) if k > 0 else p(0.0)) + 0.5 * upper**k * p(upper)
    for i in range(1, nodes):
        s = i * h
        total += s**k * p(s)
    return total * h


def recursion_coefficient(regime: str) -> Callable[[int], float]:
    """The coefficient c(k) in the two-term recursion  M_{k+2} = c(k) M_k."""
    table: Dict[str, Callable[[int], float]] = {
        "rigid": lambda k: 1.0,
        "GSE": lambda k: 9.0 * PI * (k + 5) / 128.0,
        "GUE": lambda k: PI * (k + 3) / 8.0,
        "GOE": lambda k: 2.0 * (k + 2) / PI,
        "Poisson": lambda k: float((k + 1) * (k + 2)),
    }
    return table[regime]


def moments_by_recursion(regime: str, kmax: int) -> List[float]:
    """M_0, ..., M_kmax generated from M_0 = M_1 = 1 and the two-term recursion."""
    c = recursion_coefficient(regime)
    m: List[float] = [1.0] * (kmax + 1)
    for k in range(kmax - 1):
        m[k + 2] = c(k) * m[k]
    return m


def double_factorial(n: int) -> int:
    """n!! = n (n-2) (n-4) ... down to 1 or 2; 0!! = (-1)!! = 1."""
    result = 1
    while n > 1:
        result *= n
        n -= 2
    return result


def gue_moment_closed(k: int) -> float:
    """Closed forms M_{2m} = (2m+1)!!(pi/8)^m and M_{2m+1} = (m+1)!(pi/4)^m."""
    m = k // 2
    if k % 2 == 0:
        return double_factorial(2 * m + 1) * (PI / 8.0) ** m
    return math.factorial(m + 1) * (PI / 4.0) ** m


def log_gue_moment(k: int) -> float:
    """Natural logarithm of the k-th unitary surmise moment (overflow-free).

    log M_{2m}   = log((2m+1)!!) + m log(pi/8)
                 = log((2m+1)!) - m log 2 - log(m!) + m log(pi/8),
    log M_{2m+1} = log((m+1)!) + m log(pi/4).
    """
    m = k // 2
    if k % 2 == 0:
        return (math.lgamma(2 * m + 2) - m * math.log(2.0) - math.lgamma(m + 1)
                + m * math.log(PI / 8.0))
    return math.lgamma(m + 2) + m * math.log(PI / 4.0)


def log_factorial(k: int) -> float:
    """Natural logarithm of k! (overflow-free)."""
    return math.lgamma(k + 1)


# --------------------------------------------------------------------------- #
# 2. The ladder and the classifier
# --------------------------------------------------------------------------- #

LADDER_NAMES: List[str] = ["rigid", "GSE", "GUE", "GOE", "Poisson"]
LADDER_VALUES: List[float] = [1.0, 45.0 * PI / 128.0, 3.0 * PI / 8.0, 4.0 / PI, 2.0]
LADDER_GAP: float = 3.0 * PI / 128.0          # minimal adjacent gap, GSE/GUE
SEP_CONST: float = 3.0 * PI / 8.0 - 1.0       # minimal gap of the coarse ladder


def empirical_second_moment(spacings: Sequence[float]) -> float:
    """Mean of the squares of the (already mean-one normalized) spacings."""
    return sum(s * s for s in spacings) / len(spacings)


def classify5(x: float) -> int:
    """Nearest-rung classifier on the five-regime ladder; returns an index 0..4."""
    for i in range(4):
        if x < 0.5 * (LADDER_VALUES[i] + LADDER_VALUES[i + 1]):
            return i
    return 4


def classify3(x: float) -> int:
    """Coarse classifier on the rungs 1 (rigid), 3pi/8 (GUE), 2 (Poisson)."""
    if x < 0.5 * (1.0 + 3.0 * PI / 8.0):
        return 0
    if x < 0.5 * (3.0 * PI / 8.0 + 2.0):
        return 1
    return 2


def sample_threshold(gap: float, c: float = 1.0) -> int:
    """Smallest n with n > (2C/gap)^2: the provable-correctness sample size."""
    return int(math.floor((2.0 * c / gap) ** 2)) + 1


# --------------------------------------------------------------------------- #
# 3. Sampling from the regimes (for the classifier experiment)
# --------------------------------------------------------------------------- #


def sample_surmise(beta: int, rng: random.Random) -> float:
    """One draw from the mean-one Wigner surmise of index beta, by rejection."""
    p = surmise_density(beta)
    # sup of the density: maximum of a s^beta e^{-b s^2} at s = sqrt(beta/(2b)).
    params = {1: (PI / 2.0, PI / 4.0),
              2: (32.0 / PI**2, 4.0 / PI),
              4: (2.0**18 / (3.0**6 * PI**3), 64.0 / (9.0 * PI))}
    a, b = params[beta]
    s_star = math.sqrt(beta / (2.0 * b))
    ceiling = 1.05 * a * s_star**beta * math.exp(-b * s_star**2)
    while True:
        s = rng.uniform(0.0, 6.0)
        if rng.uniform(0.0, ceiling) <= p(s):
            return s


def sample_spacings(regime: str, n: int, rng: random.Random) -> List[float]:
    """n spacings from a regime, rescaled to have empirical mean exactly one."""
    if regime == "rigid":
        raw = [1.0] * n
    elif regime == "Poisson":
        raw = [rng.expovariate(1.0) for _ in range(n)]
    else:
        beta = {"GOE": 1, "GUE": 2, "GSE": 4}[regime]
        raw = [sample_surmise(beta, rng) for _ in range(n)]
    mean = sum(raw) / n
    return [s / mean for s in raw]


# --------------------------------------------------------------------------- #
# 4. Hankel machinery
# --------------------------------------------------------------------------- #


def hankel_matrix(moments: Sequence[float], size: int) -> List[List[float]]:
    """The Hankel matrix H_ij = M_{i+j} of the given order."""
    return [[moments[i + j] for j in range(size)] for i in range(size)]


def determinant(matrix: List[List[float]]) -> float:
    """Determinant by Gaussian elimination with partial pivoting."""
    a = [row[:] for row in matrix]
    n = len(a)
    det = 1.0
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(a[r][col]))
        if abs(a[pivot][col]) < 1e-300:
            return 0.0
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            det = -det
        det *= a[col][col]
        for r in range(col + 1, n):
            factor = a[r][col] / a[col][col]
            for c in range(col, n):
                a[r][c] -= factor * a[col][c]
    return det


def hankel_quadratic_form(moments: Sequence[float], c: Sequence[float]) -> float:
    """The Hankel quadratic form sum_{i,j} c_i c_j M_{i+j}."""
    return sum(c[i] * c[j] * moments[i + j]
               for i in range(len(c)) for j in range(len(c)))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #


def demo_closed_forms() -> None:
    print("=" * 78)
    print("1. CLOSED FORMS AND THE ANTIDERIVATIVE RECURSION (unitary class)")
    print("=" * 78)
    print("   M_{k+2} = (k+3) pi/8 * M_k,   M_0 = M_1 = 1")
    print("   M_{2m} = (2m+1)!!(pi/8)^m,    M_{2m+1} = (m+1)!(pi/4)^m")
    print()
    p2 = surmise_density(2)
    rec = moments_by_recursion("GUE", 10)
    header = f"{'k':>3} {'quadrature':>13} {'recursion':>13} {'closed form':>13}"
    header += f" {'k!':>10} {'M_k/k!':>11} {'bound':>9}"
    print(header)
    print("-" * len(header))
    for k in [0, 1, 2, 3, 4, 6, 8, 10]:
        q = quad_moment(p2, k)
        r = rec[k]
        cf = gue_moment_closed(k)
        fact = math.factorial(k)
        bound = 2.0 * 0.5 ** (k // 2)
        print(f"{k:>3} {q:>13.6f} {r:>13.6f} {cf:>13.6f}"
              f" {fact:>10} {cf / fact:>11.7f} {bound:>9.4f}")
    print()
    print("   Recursion, closed form and quadrature agree to quadrature accuracy.")
    print(f"   M_2 = 3pi/8  = {3 * PI / 8:.6f},   M_3 = pi/2 = {PI / 2:.6f},"
          f"   M_4 = 15pi^2/64 = {15 * PI**2 / 64:.6f}")
    print()


def demo_no_coincidence() -> None:
    print("=" * 78)
    print("2. NO HIGHER MOMENT COINCIDENCE  (M_k = k!  iff  k <= 1)")
    print("=" * 78)
    equal_indices: List[int] = []
    worst_log_violation = -math.inf
    for k in range(0, 10_001):
        log_ratio = log_gue_moment(k) - log_factorial(k)
        if abs(log_ratio) < 1e-12:
            equal_indices.append(k)
        if k >= 2:
            log_bound = math.log(2.0) - (k // 2) * math.log(2.0)
            worst_log_violation = max(worst_log_violation, log_ratio - log_bound)
    print(f"   indices k <= 10000 with M_k = k! exactly : {equal_indices}")
    print(f"   max of log(M_k/k!) - log(2*2^-floor(k/2)) : "
          f"{worst_log_violation:.3e}  (<= 0 means the bound holds)")
    print(f"   M_20/20!  = {math.exp(log_gue_moment(20) - log_factorial(20)):.3e}")
    print(f"   M_50/50!  = {math.exp(log_gue_moment(50) - log_factorial(50)):.3e}")
    print(f"   M_500/500!= {math.exp(log_gue_moment(500) - log_factorial(500)):.3e}")
    print("   The ratio decays geometrically to zero: the fingerprints separate")
    print("   permanently after the mean.")
    print()


def demo_duality() -> None:
    print("=" * 78)
    print("3. INDEX-HALVING DUALITY WITH THE EXPONENTIAL LAW")
    print("=" * 78)
    print("   odd :  M_{2m+1} / P_{m+1}  = (pi/4)^m")
    print("   even:  M_{2m} * m!         = P_{2m+1} * (pi/16)^m")
    print()
    print(f"{'m':>3} {'M_{2m+1}/P_{m+1}':>20} {'(pi/4)^m':>15}"
          f" {'M_{2m} m!':>18} {'P_{2m+1}(pi/16)^m':>20}")
    print("-" * 80)
    for m in range(0, 7):
        lhs_odd = gue_moment_closed(2 * m + 1) / math.factorial(m + 1)
        rhs_odd = (PI / 4.0) ** m
        lhs_even = gue_moment_closed(2 * m) * math.factorial(m)
        rhs_even = math.factorial(2 * m + 1) * (PI / 16.0) ** m
        print(f"{m:>3} {lhs_odd:>20.10f} {rhs_odd:>15.10f}"
              f" {lhs_even:>18.6f} {rhs_even:>20.6f}")
    print()
    print(f"   damping ratios: pi/4 = {PI / 4:.6f} < 1 and pi/16 = "
          f"{PI / 16:.6f} < 1")
    print("   These two ratios are the entire obstruction to a coincidence.")
    print()


def demo_ladder() -> None:
    print("=" * 78)
    print("4. THE BETA-LADDER AND ITS MINIMAL GAP")
    print("=" * 78)
    print(f"{'regime':>9} {'M_2 (exact)':>22} {'M_2 (value)':>13} {'gap to next':>13}")
    print("-" * 62)
    exact = ["1", "45 pi/128", "3 pi/8", "4/pi", "2"]
    for i, name in enumerate(LADDER_NAMES):
        gap = (f"{LADDER_VALUES[i + 1] - LADDER_VALUES[i]:>13.6f}"
               if i < 4 else f"{'-':>13}")
        print(f"{name:>9} {exact[i]:>22} {LADDER_VALUES[i]:>13.6f} {gap}")
    print()
    gaps = [LADDER_VALUES[i + 1] - LADDER_VALUES[i] for i in range(4)]
    print(f"   minimal adjacent gap  = {min(gaps):.9f}")
    print(f"   3 pi / 128            = {LADDER_GAP:.9f}   (attained by GSE/GUE)")
    print(f"   half-gap tolerance    = {LADDER_GAP / 2:.9f}")
    print()
    print("   The ordering persists at EVERY moment order k >= 2:")
    print(f"{'k':>3} {'GSE':>14} {'GUE':>14} {'GOE':>14} {'Poisson':>16} {'ordered?':>10}")
    print("-" * 76)
    kmax = 12
    seq = {r: moments_by_recursion(r, kmax) for r in ["GSE", "GUE", "GOE", "Poisson"]}
    for k in range(2, kmax + 1):
        a, b, c, d = (seq["GSE"][k], seq["GUE"][k], seq["GOE"][k], seq["Poisson"][k])
        ok = 1.0 < a < b < c < d
        print(f"{k:>3} {a:>14.6f} {b:>14.6f} {c:>14.6f} {d:>16.6f} {str(ok):>10}")
    print()


def demo_classifier() -> None:
    print("=" * 78)
    print("5. THE SECOND-MOMENT CLASSIFIER ON SYNTHETIC SPECTRA")
    print("=" * 78)
    n5 = sample_threshold(LADDER_GAP)
    n3 = sample_threshold(SEP_CONST)
    print(f"   five-regime separation constant : 3pi/128   = {LADDER_GAP:.6f}")
    print(f"   provable sample size (C = 1)    : n > (2/g)^2 = {n5}")
    print(f"   three-regime separation constant: 3pi/8 - 1 = {SEP_CONST:.6f}")
    print(f"   provable sample size (C = 1)    : n > (2/s)^2 = {n3}")
    print()

    rng = random.Random(20260906)
    trials = 200
    print(f"   {trials} independent spectra per regime, n = 4000 spacings each")
    print()
    print(f"{'true regime':>12} {'mean M_2':>11} {'model M_2':>11}"
          f" {'accuracy':>10} {'|err| mean':>12}")
    print("-" * 60)
    for i, regime in enumerate(LADDER_NAMES):
        hits = 0
        m2_sum = 0.0
        err_sum = 0.0
        for _ in range(trials):
            s = sample_spacings(regime, 4000, rng)
            m2 = empirical_second_moment(s)
            m2_sum += m2
            err_sum += abs(m2 - LADDER_VALUES[i])
            if classify5(m2) == i:
                hits += 1
        print(f"{regime:>12} {m2_sum / trials:>11.6f} {LADDER_VALUES[i]:>11.6f}"
              f" {hits / trials:>9.1%} {err_sum / trials:>12.6f}")
    print()
    print("   Note the hardest pair is GSE vs GUE: their rungs differ by only")
    print(f"   3pi/128 = {LADDER_GAP:.6f}, so they need the largest samples.")
    print()

    print("   Sample-size sweep, GSE vs GUE (the bottleneck pair):")
    print(f"{'n':>7} {'GSE accuracy':>14} {'GUE accuracy':>14}")
    print("-" * 37)
    for n in [100, 500, 738, 2000, 10000, 40000]:
        acc: Dict[str, float] = {}
        for regime, idx in [("GSE", 1), ("GUE", 2)]:
            hits = sum(1 for _ in range(60)
                       if classify5(empirical_second_moment(
                           sample_spacings(regime, n, rng))) == idx)
            acc[regime] = hits / 60
        print(f"{n:>7} {acc['GSE']:>13.1%} {acc['GUE']:>13.1%}")
    print()


def demo_rigidity() -> None:
    print("=" * 78)
    print("6. RIGIDITY OF THE PICKET-FENCE BUCKET")
    print("=" * 78)
    print("   For mean-one spacings:  sum_i (s_i - 1)^2 = n (M_2 - 1),")
    print("   so M_2 = 1 forces every spacing to equal 1 exactly, and")
    print("   (1/n) sum_i |s_i - 1| <= sqrt(M_2 - 1).")
    print()
    rng = random.Random(11235)
    print(f"{'perturbation t':>15} {'M_2 - 1':>12} {'mean |s-1|':>12}"
          f" {'sqrt(M_2-1)':>13} {'classify5':>10}")
    print("-" * 66)
    for t in [0.0, 0.01, 0.05, 0.15, 0.3, 0.6]:
        n = 2000
        raw = [1.0 + t * (2 * rng.random() - 1) for _ in range(n)]
        mean = sum(raw) / n
        s = [x / mean for x in raw]
        m2 = empirical_second_moment(s)
        mad = sum(abs(x - 1.0) for x in s) / n
        print(f"{t:>15.2f} {m2 - 1:>12.6f} {mad:>12.6f}"
              f" {math.sqrt(max(m2 - 1, 0.0)):>13.6f}"
              f" {LADDER_NAMES[classify5(m2)]:>10}")
    print()
    exact = [1.0] * 500
    print(f"   exact picket fence: M_2 - 1 = {empirical_second_moment(exact) - 1:.1e}"
          f"  ->  every spacing is 1, classified as "
          f"'{LADDER_NAMES[classify5(empirical_second_moment(exact))]}'")
    print()
    print("   Realizability: the two-point configuration (1+t, 1-t) has mean one")
    print("   and second moment 1 + t^2, so every value in [1,2] is attained:")
    for name, value in zip(LADDER_NAMES, LADDER_VALUES):
        t = math.sqrt(value - 1.0)
        pair = (1.0 + t, 1.0 - t)
        m2 = empirical_second_moment(pair)
        print(f"      target {value:.6f} ({name:>7}) -> spacings "
              f"({pair[0]:.6f}, {pair[1]:.6f}), M_2 = {m2:.6f}")
    print()


def demo_hankel() -> None:
    print("=" * 78)
    print("7. HANKEL FINGERPRINTS AND POSITIVITY")
    print("=" * 78)
    gue = moments_by_recursion("GUE", 20)
    poi = moments_by_recursion("Poisson", 20)
    rigid = [1.0] * 21

    h3_gue_closed = PI**2 * (9 * PI - 28) / 256.0
    print(f"   third Hankel determinant, rigid   : "
          f"{determinant(hankel_matrix(rigid, 3)):.6f}   (exactly 0)")
    print(f"   third Hankel determinant, GUE     : "
          f"{determinant(hankel_matrix(gue, 3)):.9f}")
    print(f"   closed form pi^2(9pi - 28)/256    : {h3_gue_closed:.9f}")
    print(f"   third Hankel determinant, Poisson : "
          f"{determinant(hankel_matrix(poi, 3)):.6f}   (exactly 4)")
    print()
    print(f"   positivity of the GUE determinant is equivalent to pi > 28/9 "
          f"= {28 / 9:.6f}")
    print(f"   pi = {PI:.6f}, margin 9pi - 28 = {9 * PI - 28:.6f} > 0")
    print()
    print(f"   order-2 Hankel determinant M_0 M_2 - M_1^2 = "
          f"{gue[0] * gue[2] - gue[1] ** 2:.6f}  (= 3pi/8 - 1, the variance gap)")
    print()
    print("   Every Hankel quadratic form of the fingerprint is nonnegative.")
    rng = random.Random(4242)
    worst = float("inf")
    for _ in range(20000):
        size = rng.randint(1, 6)
        c = [rng.uniform(-2.0, 2.0) for _ in range(size)]
        worst = min(worst, hankel_quadratic_form(gue, c))
    print(f"   minimum over 20000 random forms (order <= 6): {worst:.6e}")
    print()
    print("   Leading principal minors of the GUE Hankel matrix:")
    for size in range(1, 7):
        print(f"      order {size}: {determinant(hankel_matrix(gue, size)):.6e}")
    print()


def demo_generating_radii() -> None:
    print("=" * 78)
    print("8. ANALYTIC SEPARATION BY GENERATING RADII")
    print("=" * 78)
    print("   sum_k M_k t^k / k!  converges for t^2 < 2;")
    print("   sum_k k!  t^k / k! = sum_k t^k  diverges for t >= 1.")
    print()
    c = recursion_coefficient("GUE")
    print(f"{'t':>8} {'t^2':>8} {'GUE partial sum (400 terms)':>32} {'Poisson':>16}")
    print("-" * 68)
    for t in [0.5, 1.0, 1.2, 1.4, 1.41]:
        # term_{k+2} = term_k * c(k) t^2 / ((k+1)(k+2)) keeps everything finite.
        even_term, odd_term = 1.0, t
        gue_sum = even_term + odd_term
        for k in range(0, 399, 2):
            even_term *= c(k) * t * t / ((k + 1) * (k + 2))
            odd_term *= c(k + 1) * t * t / ((k + 2) * (k + 3))
            gue_sum += even_term + odd_term
        poi_sum = ("divergent" if t >= 1.0 else f"{1.0 / (1.0 - t):.6f}")
        print(f"{t:>8.2f} {t * t:>8.4f} {gue_sum:>32.6f} {poi_sum:>16}")
    print()
    print("   Every t with 1 <= t < sqrt(2) = 1.414214 separates the two laws:")
    print("   one generating function is finite there, the other is not.")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  MOMENT FINGERPRINT CLASSIFICATION OF SPECTRAL SPACING LAWS")
    print("#  Five regimes separated by one computable statistic")
    print("#" * 78)
    print()
    demo_closed_forms()
    demo_no_coincidence()
    demo_duality()
    demo_ladder()
    demo_classifier()
    demo_rigidity()
    demo_hankel()
    demo_generating_radii()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
