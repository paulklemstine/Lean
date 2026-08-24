"""
The Geometry of Advantage — numerical demonstrations.

Self-contained (standard library only) numerical verification of the results:

  Layer 1 — the chord law, the decorrelation budget, planar sharpness, the chord metric.
  Layer 2 — the master law, the capacity law k*rho^2 <= 1 + (k-1)*gamma, the equidistant
            realiser, the extremiser classification, and the capacity staircase.
  Layer 3 — rigidity of replication records under summary constraints, dispersion floors.
  Layer 4 — failure of budget averaging, its two repairs, and the meta-analytic floor.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Iterable, List, Sequence, Tuple

Vector = List[float]
Matrix = List[List[float]]

TOL = 1e-9


# --------------------------------------------------------------------------------------
# Linear algebra helpers
# --------------------------------------------------------------------------------------

def dot(u: Sequence[float], v: Sequence[float]) -> float:
    """Standard Euclidean inner product."""
    return sum(a * b for a, b in zip(u, v))


def norm(u: Sequence[float]) -> float:
    """Euclidean norm."""
    return math.sqrt(dot(u, u))


def normalise(u: Sequence[float]) -> Vector:
    """Unit vector in the direction of u."""
    n = norm(u)
    if n == 0.0:
        raise ValueError("cannot normalise the zero vector")
    return [x / n for x in u]


def corr(u: Sequence[float], v: Sequence[float]) -> float:
    """Correlation = cosine of the angle between u and v."""
    return dot(u, v) / (norm(u) * norm(v))


def chord_distance(u: Sequence[float], v: Sequence[float]) -> float:
    """The chord metric d(u,v) = sqrt(2 - 2 rho(u,v))."""
    return math.sqrt(max(0.0, 2.0 - 2.0 * corr(u, v)))


def gram(vectors: Sequence[Sequence[float]]) -> Matrix:
    """Gram matrix of a family of vectors."""
    return [[dot(u, v) for v in vectors] for u in vectors]


# --------------------------------------------------------------------------------------
# Layer 1 — chord law and decorrelation budget
# --------------------------------------------------------------------------------------

def gram_determinant(a: float, b: float, c: float) -> float:
    """det of [[1,c,a],[c,1,b],[a,b,1]] = 1 + 2abc - (a^2+b^2+c^2)."""
    return 1.0 + 2.0 * a * b * c - (a * a + b * b + c * c)


def chord_slack(a: float, b: float, c: float) -> float:
    """(1-c)(1+c-2ab) - (a-b)^2 : equals the Gram determinant identically."""
    return (1.0 - c) * (1.0 + c - 2.0 * a * b) - (a - b) ** 2


def decorrelation_budget_rhs(c: float, a: float, b: float) -> float:
    """The budget right-hand side 2 (1-c) (1 - ab)."""
    return 2.0 * (1.0 - c) * (1.0 - a * b)


def mutual_corr_ceiling(alpha: float, product_floor: float) -> float:
    """Largest mutual correlation compatible with advantage alpha at product >= M."""
    return 1.0 - alpha ** 2 / (2.0 * (1.0 - product_floor))


def demo_chord_law() -> None:
    print("=" * 78)
    print("LAYER 1 — the chord law: Gram positivity IS the advantage inequality")
    print("=" * 78)
    print("  identity check  (1-c)(1+c-2ab) - (a-b)^2 == 1 + 2abc - (a^2+b^2+c^2)")
    worst = 0.0
    for a in [-0.9, -0.3, 0.0, 0.44, 0.641, 0.97]:
        for b in [-0.7, 0.1, 0.597, 0.8]:
            for c in [-0.5, 0.0, 0.33, 0.9]:
                worst = max(worst, abs(chord_slack(a, b, c) - gram_determinant(a, b, c)))
    print(f"  max |difference| over a 6x4x4 grid : {worst:.2e}   (identity holds)\n")

    a, b = 0.641, 0.597
    alpha = a - b
    print(f"  recorded readings a = {a}, b = {b},  advantage alpha = {alpha:.3f}")
    print(f"  reading product ab = {a*b:.6f}")
    ceiling = mutual_corr_ceiling(0.044, 0.382)
    print(f"  budget ceiling with alpha = 0.044, M = 0.382 :  c <= {ceiling:.6f}")
    print(f"  i.e. the two statistics must be at least {1-ceiling:.6f} decorrelated")

    ceiling2 = mutual_corr_ceiling(0.086, 1.0 / 3.0)
    print(f"  outlier replication (alpha = 0.086, M = 1/3) :  c <= {ceiling2:.6f}")

    # lower bound from Gram positivity
    lower = a * b - math.sqrt((1 - a * a) * (1 - b * b))
    print(f"  Gram lower bound                            :  c >= {lower:.6f}")
    print()


def demo_planar_sharpness(trials: int = 20000) -> None:
    print("-" * 78)
    print("  sharpness: in the plane the chord law is an EQUALITY")
    print("-" * 78)
    rng_state = 123456789

    def rand() -> float:
        nonlocal rng_state
        rng_state = (1103515245 * rng_state + 12345) % (2 ** 31)
        return rng_state / (2 ** 31) * 2.0 - 1.0

    worst_plane = 0.0
    worst_general = math.inf
    for _ in range(trials // 2):
        u2 = [rand(), rand()]
        v2 = [rand(), rand()]
        w2 = [rand(), rand()]
        if min(norm(u2), norm(v2), norm(w2)) < 1e-6:
            continue
        a, b, c = corr(u2, w2), corr(v2, w2), corr(u2, v2)
        worst_plane = max(worst_plane, abs(chord_slack(a, b, c)))

        u3 = [rand(), rand(), rand()]
        v3 = [rand(), rand(), rand()]
        w3 = [rand(), rand(), rand()]
        if min(norm(u3), norm(v3), norm(w3)) < 1e-6:
            continue
        a, b, c = corr(u3, w3), corr(v3, w3), corr(u3, v3)
        worst_general = min(worst_general, chord_slack(a, b, c))

    print(f"  max |slack| for random planar triples   : {worst_plane:.2e}  (identity)")
    print(f"  min  slack  for random spatial triples  : {worst_general:.2e}  (>= 0)")
    print()


def demo_chord_metric() -> None:
    print("-" * 78)
    print("  the chord distance sqrt(2-2rho) is a metric: correlation is transitive")
    print("-" * 78)
    u = [1.0, 0.0, 0.0]
    v = normalise([1.0, 1.0, 0.0])
    w = normalise([1.0, 1.0, 1.0])
    duv, dvw, duw = chord_distance(u, v), chord_distance(v, w), chord_distance(u, w)
    print(f"  rho(u,v) = {corr(u,v):.4f}   rho(v,w) = {corr(v,w):.4f}   rho(u,w) = {corr(u,w):.4f}")
    print(f"  d(u,v) = {duv:.6f}, d(v,w) = {dvw:.6f}, d(u,w) = {duw:.6f}")
    print(f"  triangle inequality d(u,w) <= d(u,v) + d(v,w): "
          f"{duw:.6f} <= {duv + dvw:.6f}  -> {duw <= duv + dvw + TOL}")
    print()


# --------------------------------------------------------------------------------------
# Layer 2 — capacity, realisers, extremisers, staircase
# --------------------------------------------------------------------------------------

def equidistant_family(k: int, gamma: float) -> Tuple[List[Vector], Vector, float]:
    """
    The capacity extremiser in R^k: k unit vectors with every pairwise inner product
    exactly gamma, together with the unit response they all read at
    rho = sqrt((1 + (k-1) gamma)/k).
    """
    if not (1 + (k - 1) * gamma >= 0 and gamma <= 1):
        raise ValueError("inadmissible (k, gamma)")
    A = math.sqrt(1.0 - gamma)
    B = (math.sqrt(1.0 + (k - 1) * gamma) - A) / k
    u = [[A * (1.0 if i == x else 0.0) + B for x in range(k)] for i in range(k)]
    w = [1.0 / math.sqrt(k)] * k
    rho = math.sqrt((1.0 + (k - 1) * gamma) / k)
    return u, w, rho


def dial_threshold(rho: float, k: int) -> float:
    """The admissibility threshold theta(rho,k) = (k rho^2 - 1)/(k-1) for k >= 2."""
    if k < 2:
        raise ValueError("threshold defined for k >= 2")
    return (k * rho ** 2 - 1.0) / (k - 1)


def dial_capacity(rho: float, gamma: float) -> float:
    """Largest admissible family size: floor((1-gamma)/(rho^2-gamma)), or infinity."""
    if gamma >= rho ** 2:
        return math.inf
    return math.floor((1.0 - gamma) / (rho ** 2 - gamma))


def demo_capacity_law() -> None:
    print("=" * 78)
    print("LAYER 2 — capacity of a correlated family:  k rho^2 <= 1 + (k-1) gamma")
    print("=" * 78)
    for k, gamma in [(1, 0.0), (2, 0.0), (3, 0.1163215), (4, 0.214508), (5, 0.3)]:
        u, w, rho = equidistant_family(k, gamma)
        G = gram(u)
        diag_err = max(abs(G[i][i] - 1.0) for i in range(k))
        off_err = max((abs(G[i][j] - gamma) for i in range(k) for j in range(k) if i != j),
                      default=0.0)
        read_err = max(abs(dot(u[i], w) - rho) for i in range(k))
        lhs, rhs = k * rho ** 2, 1.0 + (k - 1) * gamma
        print(f"  k={k}, gamma={gamma:.7f} -> rho={rho:.6f}  "
              f"k*rho^2={lhs:.6f}  1+(k-1)gamma={rhs:.6f}  saturated={abs(lhs-rhs)<1e-9}")
        print(f"       Gram diag err {diag_err:.1e}, off-diag err {off_err:.1e}, "
              f"reading err {read_err:.1e}")
    print()


def demo_extremiser_classification() -> None:
    print("-" * 78)
    print("  extremiser classification: response = normalised sum, readings exact")
    print("-" * 78)
    k, gamma = 4, 0.25
    u, w, rho = equidistant_family(k, gamma)
    S = [sum(u[i][x] for i in range(k)) for x in range(k)]
    target = [k * rho * w[x] for x in range(k)]
    residual = max(abs(S[x] - target[x]) for x in range(k))
    print(f"  k = {k}, gamma = {gamma}, rho = {rho:.6f}")
    print(f"  || sum_i u_i  -  k rho w ||_inf = {residual:.2e}   (must be 0)")
    recon = [sum(u[i][x] for i in range(k)) / (k * rho) for x in range(k)]
    print(f"  w reconstructed as (k rho)^-1 sum_i u_i, max error "
          f"{max(abs(recon[x]-w[x]) for x in range(k)):.2e}")
    print(f"  all readings equal rho: "
          f"{max(abs(dot(u[i], w) - rho) for i in range(k)):.2e}")
    print()


def demo_random_family_bound(trials: int = 4000) -> None:
    print("-" * 78)
    print("  the capacity law is never violated by random families")
    print("-" * 78)
    rng_state = 987654321

    def rand() -> float:
        nonlocal rng_state
        rng_state = (1103515245 * rng_state + 12345) % (2 ** 31)
        return rng_state / (2 ** 31) * 2.0 - 1.0

    worst_gap = math.inf
    for _ in range(trials):
        k, n = 3, 5
        u = [normalise([rand() for _ in range(n)]) for _ in range(k)]
        w = normalise([rand() for _ in range(n)])
        rho = min(dot(u[i], w) for i in range(k))
        if rho < 0:
            continue
        gamma = max(dot(u[i], u[j]) for i, j in combinations(range(k), 2))
        worst_gap = min(worst_gap, (1.0 + (k - 1) * gamma) - k * rho ** 2)
    print(f"  min slack of 1+(k-1)gamma - k rho^2 over {trials} random triples: "
          f"{worst_gap:.6f}  (>= 0)")
    print()


def demo_staircase() -> None:
    print("-" * 78)
    print("  the capacity staircase at the replicated reading rho = 0.641")
    print("-" * 78)
    rho = 0.641
    for k in range(2, 7):
        print(f"    theta(rho,{k}) = {dial_threshold(rho, k):.7f}")
    print()
    for gamma in [0.0, 0.05, 0.10, 0.1163215, 0.15, 0.20, 0.214508, 0.30]:
        cap = dial_capacity(rho, gamma)
        cap_s = "inf" if cap == math.inf else str(int(cap))
        print(f"    gamma = {gamma:9.7f}  ->  capacity = {cap_s}")
    print("\n  phase check: at gamma = 0.10 a triple is impossible, at 0.20 it is possible")
    for gamma in (0.10, 0.20):
        k = 3
        ok = k * rho ** 2 <= 1.0 + (k - 1) * gamma + TOL
        print(f"    gamma = {gamma}:  3*rho^2 = {3*rho**2:.6f} vs 1+2gamma = "
              f"{1+2*gamma:.6f}  -> triple {'exists' if ok else 'IMPOSSIBLE'}")
    print()


# --------------------------------------------------------------------------------------
# Layer 3 — replication records
# --------------------------------------------------------------------------------------

RECORD: List[float] = [0.016, 0.100, 0.106, 0.016, 0.050, 0.066]
LEGACY = (0, 1, 2)
FRESH = (3, 4, 5)
BAR = 0.050
MEAN6 = 0.059
MEDIAN6 = 0.058
FRESH_MEAN = 0.044
FRESH_CI = (0.022, 0.066)


def record_summary(rec: Sequence[float]) -> dict:
    """All published summary statistics of a six-replication advantage record."""
    srt = sorted(rec)
    return {
        "total": sum(rec),
        "mean": sum(rec) / len(rec),
        "fresh_mean": sum(rec[i] for i in FRESH) / len(FRESH),
        "legacy_sum": sum(rec[i] for i in LEGACY),
        "above_bar": sum(1 for x in rec if x > BAR),
        "fresh_above_bar": sum(1 for i in FRESH if rec[i] > BAR),
        "median": (srt[2] + srt[3]) / 2.0,
        "legacy_max": max(rec[i] for i in LEGACY),
        "energy": sum(x * x for x in rec),
        "sorted": srt,
    }


def variance_floor(r: int, low_count: int, mu: float, tau: float) -> float:
    """r|L|/(r-|L|) (mu - tau)^2 — the forced squared dispersion."""
    return r * low_count / (r - low_count) * (mu - tau) ** 2


def demo_record_rigidity() -> None:
    print("=" * 78)
    print("LAYER 3 — rigidity of a count-parity replication record")
    print("=" * 78)
    s = record_summary(RECORD)
    print(f"  record            : {RECORD}")
    print(f"  total {s['total']:.3f} = 6 x {s['mean']:.3f}   (target 6 x {MEAN6})")
    print(f"  fresh mean        : {s['fresh_mean']:.3f}   (target {FRESH_MEAN})")
    print(f"  legacy block sum  : {s['legacy_sum']:.3f}   (= 6*0.059 - 3*0.044)")
    print(f"  above bar         : {s['above_bar']}/6, of which fresh: {s['fresh_above_bar']}/3")
    print(f"  sorted            : {s['sorted']}, median {s['median']:.3f} "
          f"(target {MEDIAN6})")
    print()
    forced = (s["legacy_sum"] - BAR) / 2.0
    print(f"  RIGIDITY: some legacy replication must carry advantage >= "
          f"({s['legacy_sum']:.3f} - {BAR})/2 = {forced:.3f}")
    print(f"           observed legacy maximum = {s['legacy_max']:.3f}  "
          f"-> constraint satisfied: {s['legacy_max'] >= forced - TOL}")
    print(f"           and {forced:.3f} lies OUTSIDE the fresh CI {FRESH_CI}: "
          f"{forced > FRESH_CI[1]}")
    print()
    above_mean_floor = 2 * MEAN6 - BAR
    print(f"  ABOVE-GROUP MEAN >= 2*{MEAN6} - {BAR} = {above_mean_floor:.3f} "
          f"> upper CI {FRESH_CI[1]}  -> no record can be 'flat'")
    srt = s["sorted"]
    print(f"  BIMODALITY GAP a(4) - a(3) = {srt[3]-srt[2]:.3f} >= 2*{MEDIAN6} - {BAR} - "
          f"{BAR} = {2*MEDIAN6 - 2*BAR:.3f}")
    disp = sum((x - MEAN6) ** 2 for x in RECORD)
    floor = variance_floor(6, 3, MEAN6, BAR)
    print(f"  DISPERSION  sum (a_i - mu)^2 = {disp:.6f} >= floor {floor:.6f}: "
          f"{disp >= floor - TOL}")
    print()


# --------------------------------------------------------------------------------------
# Layer 4 — aggregation: refutation and repairs
# --------------------------------------------------------------------------------------

def budget_mean_form(c: Sequence[float], a: Sequence[float], b: Sequence[float]) -> float:
    """The conjectured (false) mean-based aggregate budget."""
    r = len(c)
    cbar = sum(c) / r
    return 2.0 * (1.0 - cbar) * (r - sum(x * y for x, y in zip(a, b)))


def budget_min_form(cmin: float, a: Sequence[float], b: Sequence[float]) -> float:
    """The valid worst-case aggregate budget (minimum in place of mean)."""
    r = len(a)
    return 2.0 * (1.0 - cmin) * (r - sum(x * y for x, y in zip(a, b)))


def antivary(x: Sequence[float], y: Sequence[float]) -> bool:
    """True iff (x_i - x_j)(y_i - y_j) <= 0 for all i, j."""
    return all((x[i] - x[j]) * (y[i] - y[j]) <= TOL
               for i in range(len(x)) for j in range(len(x)))


def demo_aggregation_failure() -> None:
    print("=" * 78)
    print("LAYER 4 — budget averaging is FALSE, and how to repair it")
    print("=" * 78)
    a = [0.7, 1.0]
    b = [-0.7, 1.0]
    c = [0.0, 1.0]
    alpha = [1.4, 0.0]
    print(f"  two replications: a = {a}, b = {b}, c = {c}, alpha = {alpha}")
    for i in range(2):
        g = gram_determinant(a[i], b[i], c[i])
        print(f"    replication {i}: Gram determinant = {g:.4f} >= 0 -> "
              f"{'admissible' if g >= -TOL else 'INADMISSIBLE'}; "
              f"alpha <= a-b: {alpha[i] <= a[i]-b[i] + TOL}")
    energy = sum(x * x for x in alpha)
    conj = budget_mean_form(c, a, b)
    print(f"\n  pooled advantage energy      : {energy:.4f}")
    print(f"  conjectured mean-based budget: {conj:.4f}")
    print(f"  CONJECTURE FAILS: {energy:.2f} > {conj:.2f}  -> {energy > conj}")
    decorr = [1 - x for x in c]
    headroom = [1 - x * y for x, y in zip(a, b)]
    print(f"\n  diagnosis: decorrelation (1-c_i) = {decorr}")
    print(f"             headroom     (1-ab_i) = {[round(h,4) for h in headroom]}")
    print(f"             antivarying? {antivary(decorr, headroom)}  "
          f"(they MONOVARY — the missing hypothesis)")
    valid = budget_min_form(min(c), a, b)
    print(f"\n  REPAIR 1 (minimum form) : budget = {valid:.4f} >= energy {energy:.4f} -> "
          f"{valid >= energy - TOL}")
    # a well-ordered example where the mean form is legitimate
    a2 = [0.7, 0.6]
    b2 = [0.7, 0.2]
    c2 = [0.0, 0.9]
    alpha2 = [a2[0] - b2[0], a2[1] - b2[1]]
    d2 = [1 - x for x in c2]
    h2 = [1 - x * y for x, y in zip(a2, b2)]
    e2 = sum(x * x for x in alpha2)
    m2 = budget_mean_form(c2, a2, b2)
    print(f"\n  REPAIR 2 (Chebyshev form) on an antivarying record:")
    print(f"    a = {a2}, b = {b2}, c = {c2}")
    print(f"    decorrelation {d2}, headroom {[round(h,3) for h in h2]}, "
          f"antivarying? {antivary(d2, h2)}")
    print(f"    energy {e2:.5f} <= mean-based budget {m2:.5f} -> {e2 <= m2 + TOL}")
    print()


def demo_meta_analysis() -> None:
    print("-" * 78)
    print("  meta-analytic decorrelation floor from the six-replication record")
    print("-" * 78)
    energy = sum(x * x for x in RECORD)
    r, P = 6, 1.0 / 3.0
    floor = energy / (2.0 * r * (1.0 - P))
    print(f"  pooled advantage energy  sum alpha_i^2 = {energy:.6f}")
    print(f"  reading-product floor P = 1/3, so r - sum a_i b_i <= {r - r*P:.1f}")
    print(f"  hence 1 - c_min >= {energy:.6f} / {2*r*(1-P):.1f} = {floor:.7f}")
    print(f"  i.e. the MOST CORRELATED replication has c <= {1-floor:.7f}")
    print(f"  exact rational value: 1 - 7151/2000000 = {1 - 7151/2000000:.7f}")
    single = max(RECORD) ** 2 / (2 * (1 - P))
    print(f"\n  by comparison, the largest single advantage {max(RECORD)} constrains only")
    print(f"  its own replication: 1 - c >= {single:.7f}, and says nothing about the rest.")
    print()


# --------------------------------------------------------------------------------------

def main() -> None:
    demo_chord_law()
    demo_planar_sharpness()
    demo_chord_metric()
    demo_capacity_law()
    demo_extremiser_classification()
    demo_random_family_bound()
    demo_staircase()
    demo_record_rigidity()
    demo_aggregation_failure()
    demo_meta_analysis()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
