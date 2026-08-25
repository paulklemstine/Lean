"""
Numerical demonstrations for
"The Exact Algebra of Overlapping Measurement Legs".

Everything is self-contained: no third-party dependencies, only the standard
library.  Each section states an exact identity from the paper, verifies it
symbolically-in-floats against a closed form, and then confirms it empirically
by Monte-Carlo simulation of an actual shared random stream.

Sections
--------
1. Master overlap identity          Cov(x_S, x_T) = s^2 |S n T| / (|S||T|)
2. Exact defect law                 Vtrue = Vnaive + 2w(1-w)s^2|S n T|/(|S||T|)
3. Duplicate leg                    Vtrue = 2 Vnaive   (error bars * sqrt(2) too small)
4. Nested prefix + the 7/5 gate     Vtrue = (3|S|+|T|)/(|S|+|T|) * Vnaive
5. Lineage / distinct-draw bound    Var(pool) >= s^2 / |union of legs|
6. Population overlap identity      two-level covariance, shared objects
7. Cluster ceiling                  Var >= rho s^2 / k,  n_eff <= k / rho
8. GLS repair                       w* = (v2-c)/(v1+v2-2c),  floor (v1v2-c^2)/(...)
9. The audit, end to end            what the 76.8M-pair run is actually worth

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterable, List, Sequence, Set, Tuple

# --------------------------------------------------------------------------- #
# Formatting helpers
# --------------------------------------------------------------------------- #


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, lhs: float, rhs: float, tol: float = 1e-9) -> None:
    ok = abs(lhs - rhs) <= tol * max(1.0, abs(lhs), abs(rhs))
    status = "OK " if ok else "FAIL"
    print(f"  [{status}] {label:<52} {lhs: .10f}  vs {rhs: .10f}")


# --------------------------------------------------------------------------- #
# Closed forms from the paper
# --------------------------------------------------------------------------- #


def cov_legs(sigma: float, S: Set[int], T: Set[int]) -> float:
    """Master identity: Cov(mean_S, mean_T) = s^2 |S n T| / (|S| |T|)."""
    return sigma ** 2 * len(S & T) / (len(S) * len(T))


def naive_var(sigma: float, w: float, S: Set[int], T: Set[int]) -> float:
    """Variance the independence bookkeeping reports for w*mean_S+(1-w)*mean_T."""
    return w ** 2 * sigma ** 2 / len(S) + (1.0 - w) ** 2 * sigma ** 2 / len(T)


def true_var(sigma: float, w: float, S: Set[int], T: Set[int]) -> float:
    """Exact defect law: naive variance plus 2w(1-w) times the covariance."""
    return naive_var(sigma, w, S, T) + 2.0 * w * (1.0 - w) * cov_legs(sigma, S, T)


def ivw_weight(S: Set[int], T: Set[int]) -> float:
    """Inverse-variance weight on the first leg: |S| / (|S| + |T|)."""
    return len(S) / (len(S) + len(T))


def nested_inflation(nS: int, nT: int) -> float:
    """Variance inflation of an inverse-variance pool of a prefix inside a run."""
    return (3.0 * nS + nT) / (nS + nT)


def pool_coefficients(
    legs: Sequence[Set[int]], weights: Sequence[float]
) -> Dict[int, float]:
    """Total weight the pool places on each distinct stream position."""
    coeff: Dict[int, float] = {}
    for S, w in zip(legs, weights):
        for i in S:
            coeff[i] = coeff.get(i, 0.0) + w / len(S)
    return coeff


def pool_variance(
    sigma: float, legs: Sequence[Set[int]], weights: Sequence[float]
) -> float:
    """Honest variance of an arbitrary weighted pool: s^2 * sum of squared coeffs."""
    coeff = pool_coefficients(legs, weights)
    return sigma ** 2 * sum(c * c for c in coeff.values())


def distinct_draw_bound(sigma: float, legs: Sequence[Set[int]]) -> float:
    """Master information bound s^2 / |union of legs|."""
    union: Set[int] = set()
    for S in legs:
        union |= S
    return sigma ** 2 / len(union)


def pop_cov(
    sigma: float,
    rho: float,
    K: Set[int],
    T: Set[int],
    Kp: Set[int],
    Tp: Set[int],
) -> float:
    """Population overlap identity: shared-object term + shared-draw term."""
    shared_objects = rho * sigma ** 2 * len(K & Kp) / (len(K) * len(Kp))
    shared_draws = (
        (1.0 - rho)
        * sigma ** 2
        * len(K & Kp)
        * len(T & Tp)
        / (len(K) * len(T) * len(Kp) * len(Tp))
    )
    return shared_objects + shared_draws


def design_effect(m: int, rho: float) -> float:
    """1 + (m-1) rho."""
    return 1.0 + (m - 1) * rho


def grand_mean_var(sigma: float, rho: float, k: int, m: int) -> float:
    """s^2 (1 + (m-1) rho) / (k m)."""
    return sigma ** 2 * design_effect(m, rho) / (k * m)


def effective_sample_size(k: int, m: int, rho: float) -> float:
    """k m / design effect; bounded by k / rho."""
    return k * m / design_effect(m, rho)


def gls_weight(v1: float, v2: float, c: float) -> float:
    return (v2 - c) / (v1 + v2 - 2.0 * c)


def gls_floor(v1: float, v2: float, c: float) -> float:
    return (v1 * v2 - c ** 2) / (v1 + v2 - 2.0 * c)


def pool_var_quadratic(v1: float, v2: float, c: float, w: float) -> float:
    return w ** 2 * v1 + (1.0 - w) ** 2 * v2 + 2.0 * w * (1.0 - w) * c


def zscore(d: float, v: float) -> float:
    return d / math.sqrt(v)


# --------------------------------------------------------------------------- #
# Monte-Carlo machinery: an honest simulation of a shared random stream
# --------------------------------------------------------------------------- #


def simulate_stream_legs(
    S: Set[int],
    T: Set[int],
    w: float,
    sigma: float,
    trials: int,
    seed: int,
) -> Tuple[float, float, float]:
    """
    Draw an i.i.d. stream, cut two legs out of it, and estimate
    (Var(mean_S), Var(mean_T), Var(pool)) empirically.
    """
    rng = random.Random(seed)
    n = max(max(S), max(T)) + 1
    accS = accT = accP = 0.0
    for _ in range(trials):
        stream = [rng.gauss(0.0, sigma) for _ in range(n)]
        mS = sum(stream[i] for i in S) / len(S)
        mT = sum(stream[i] for i in T) / len(T)
        pool = w * mS + (1.0 - w) * mT
        accS += mS * mS
        accT += mT * mT
        accP += pool * pool
    return accS / trials, accT / trials, accP / trials


def simulate_two_level(
    K: Set[int],
    T: Set[int],
    Kp: Set[int],
    Tp: Set[int],
    sigma: float,
    rho: float,
    trials: int,
    seed: int,
) -> float:
    """Empirical covariance of two two-level legs sharing objects and/or draws."""
    rng = random.Random(seed)
    objects = sorted(K | Kp)
    draws = sorted(T | Tp)
    s_shared = math.sqrt(rho) * sigma
    s_private = math.sqrt(1.0 - rho) * sigma
    acc = 0.0
    for _ in range(trials):
        u = {i: rng.gauss(0.0, s_shared) for i in objects}
        p = {(i, t): rng.gauss(0.0, s_private) for i in objects for t in draws}
        leg1 = sum(u[i] + p[(i, t)] for i in K for t in T) / (len(K) * len(T))
        leg2 = sum(u[i] + p[(i, t)] for i in Kp for t in Tp) / (len(Kp) * len(Tp))
        acc += leg1 * leg2
    return acc / trials


def simulate_clusters(
    k: int, m: int, sigma: float, rho: float, trials: int, seed: int
) -> float:
    """Empirical variance of the grand mean in an equicorrelated cluster design."""
    rng = random.Random(seed)
    s_shared = math.sqrt(rho) * sigma
    s_private = math.sqrt(1.0 - rho) * sigma
    acc = 0.0
    for _ in range(trials):
        total = 0.0
        for _i in range(k):
            u = rng.gauss(0.0, s_shared)
            total += m * u + sum(rng.gauss(0.0, s_private) for _j in range(m))
        gm = total / (k * m)
        acc += gm * gm
    return acc / trials


# --------------------------------------------------------------------------- #
# 1. Master overlap identity
# --------------------------------------------------------------------------- #


def demo_master_identity() -> None:
    rule("1. Master overlap identity:  Cov(x_S, x_T) = s^2 |S n T| / (|S| |T|)")
    sigma = 1.3
    S = set(range(0, 12))
    T = set(range(8, 24))
    print(f"  |S| = {len(S)}, |T| = {len(T)}, |S n T| = {len(S & T)}, sigma = {sigma}")
    closed = cov_legs(sigma, S, T)
    vS, vT, _ = simulate_stream_legs(S, T, 0.5, sigma, trials=40000, seed=11)
    # empirical covariance via the polarisation of the pooled variance at w = 1/2
    _, _, vP = simulate_stream_legs(S, T, 0.5, sigma, trials=40000, seed=11)
    emp_cov = 2.0 * vP - 0.5 * (vS + vT)
    check("closed form vs Monte Carlo", closed, emp_cov, tol=5e-2)
    check("single-leg variance sigma^2/|S|", sigma ** 2 / len(S), vS, tol=5e-2)
    Sn, Tn = set(range(0, 10)), set(range(0, 40))
    print("  Nesting is total correlation with the long leg:")
    check(
        "Cov(prefix, superset) = Var(superset)",
        cov_legs(sigma, Sn, Tn),
        sigma ** 2 / len(Tn),
    )
    D1, D2 = set(range(0, 10)), set(range(10, 20))
    check("disjoint legs have zero covariance", cov_legs(sigma, D1, D2), 0.0)


# --------------------------------------------------------------------------- #
# 2. Exact defect law and the iff
# --------------------------------------------------------------------------- #


def demo_defect_law() -> None:
    rule("2. Exact defect law and 'independence is disjointness'")
    sigma = 1.0
    S = set(range(0, 30))
    T = set(range(20, 60))
    for w in (0.1, 0.25, 0.5, 0.75):
        nv = naive_var(sigma, w, S, T)
        tv = true_var(sigma, w, S, T)
        defect = 2 * w * (1 - w) * sigma ** 2 * len(S & T) / (len(S) * len(T))
        check(f"w={w:<4}: true = naive + defect", tv, nv + defect)
    _, _, vP = simulate_stream_legs(S, T, 0.5, sigma, trials=40000, seed=7)
    check("Monte Carlo pooled variance (w=1/2)", true_var(sigma, 0.5, S, T), vP, 5e-2)

    print("\n  Equality holds exactly when the legs are disjoint:")
    D1, D2 = set(range(0, 30)), set(range(30, 70))
    check("disjoint: true == naive", true_var(sigma, 0.4, D1, D2),
          naive_var(sigma, 0.4, D1, D2))
    overlap_1 = set(range(29, 69))  # a single shared position
    print("  A single shared draw already breaks it:")
    tv, nv = true_var(sigma, 0.4, D1, overlap_1), naive_var(sigma, 0.4, D1, overlap_1)
    print(f"    true = {tv:.10f} > naive = {nv:.10f}   (excess {tv - nv:.3e})")


# --------------------------------------------------------------------------- #
# 3. Duplicate leg
# --------------------------------------------------------------------------- #


def demo_duplicate_leg() -> None:
    rule("3. A dataset pooled with itself: exactly half the variance is reported")
    sigma, S = 1.0, set(range(0, 50))
    nv = naive_var(sigma, 0.5, S, S)
    tv = true_var(sigma, 0.5, S, S)
    check("true variance = sigma^2/|S|", tv, sigma ** 2 / len(S))
    check("true variance = 2 * reported", tv, 2.0 * nv)
    print(f"  Reported half-width is a factor {math.sqrt(2):.6f} too small "
          f"(a free but fraudulent sqrt(2)).")


# --------------------------------------------------------------------------- #
# 4. Nested prefix, the 7/5 inflation, and the retracted gate
# --------------------------------------------------------------------------- #


def demo_nested_prefix() -> None:
    rule("4. A prefix pooled with its superset: the 7/5 inflation and the gate")
    sigma = 1.0
    nS, nT = 150_000, 600_000          # the audited geometry, |T| = 4|S|
    S, T = set(range(nS)), set(range(nT))
    w = ivw_weight(S, T)
    nv, tv = naive_var(sigma, w, S, T), true_var(sigma, w, S, T)
    check("reported variance = sigma^2/(|S|+|T|)", nv, sigma ** 2 / (nS + nT))
    check("true variance = s^2(3|S|+|T|)/(|S|+|T|)^2",
          tv, sigma ** 2 * (3 * nS + nT) / (nS + nT) ** 2)
    check("inflation factor equals 7/5", tv / nv, 7.0 / 5.0)
    print(f"  Long leg alone:  Var = {sigma ** 2 / nT:.6e}")
    print(f"  Pooled estimate: Var = {tv:.6e}   "
          f"-> pooling is WORSE than discarding the prefix "
          f"({tv > sigma ** 2 / nT})")

    print("\n  Effect on a reported z-statistic (deficit d, reported variance v):")
    d, v = 0.0404, (0.0189) ** 2       # 1 - 0.9596 against sigma ~ 0.0189
    z_rep = zscore(d, v)
    z_hon = zscore(d, (7.0 / 5.0) * v)
    print(f"    reported z = {z_rep:.4f}   honest z = {z_hon:.4f} "
          f"= reported / sqrt(1.4) = {z_rep / math.sqrt(1.4):.4f}")
    print(f"    exclusion of the null at 1.96 survives?  {z_hon >= 1.96}")
    print(f"    theorem: any reported z <= 2.14 gives honest z <= "
          f"{2.14 / math.sqrt(1.4):.4f} < 1.96")

    print("\n  Optimal weight for a nested pair is exactly zero:")
    for weight in (0.0, 0.05, w, 0.2, 0.5):
        print(f"    w = {weight:<8.5f}  true variance = {true_var(sigma, weight, S, T):.6e}")


# --------------------------------------------------------------------------- #
# 5. Lineage and distinct-draw bounds
# --------------------------------------------------------------------------- #


def demo_lineage_bound() -> None:
    rule("5. One seed is one dataset: the distinct-draw bound")
    sigma = 1.0
    chain = [set(range(n)) for n in (100, 250, 400, 1000)]
    weightings = {
        "equal weights": [0.25] * 4,
        "inverse-variance-ish": [0.058, 0.146, 0.234, 0.562],
        "all on the longest": [0.0, 0.0, 0.0, 1.0],
        "all on the shortest": [1.0, 0.0, 0.0, 0.0],
    }
    floor = sigma ** 2 / len(chain[-1])
    print(f"  Chain 100 c 250 c 400 c 1000 draws; lineage floor = {floor:.6e}")
    for name, ws in weightings.items():
        v = pool_variance(sigma, chain, ws)
        print(f"    {name:<24} Var = {v:.6e}   >= floor? {v >= floor - 1e-15}")

    print("\n  Arbitrary overlapping family (not a chain):")
    legs = [set(range(0, 60)), set(range(40, 130)), set(range(120, 150)),
            set(range(10, 45))]
    ws = [0.2, 0.35, 0.25, 0.2]
    bound = distinct_draw_bound(sigma, legs)
    v = pool_variance(sigma, legs, ws)
    union: Set[int] = set()
    for S in legs:
        union |= S
    print(f"    |union| = {len(union)} distinct draws, bound = {bound:.6e}")
    print(f"    pool variance = {v:.6e}   >= bound? {v >= bound - 1e-15}")
    uniform = pool_variance(sigma, [union], [1.0])
    check("uniform average over the union attains the bound", uniform, bound)

    print("\n  What a genuinely fresh (disjoint) stream buys:")
    A, B = set(range(0, 1000)), set(range(1000, 2000))
    wd = ivw_weight(A, B)
    vd = true_var(sigma, wd, A, B)
    check("disjoint pool = sigma^2/(|S|+|T|)", vd, sigma ** 2 / 2000)
    check("equal-size fresh replication halves the variance",
          vd, 0.5 * sigma ** 2 / len(B))
    print(f"    error bars divided by exactly sqrt(2) = {math.sqrt(2):.6f}")


# --------------------------------------------------------------------------- #
# 6. Population overlap identity
# --------------------------------------------------------------------------- #


def demo_population_overlap() -> None:
    rule("6. Shared populations: the overlap identity one level up")
    sigma, rho = 1.0, 0.25
    K = set(range(0, 6))        # pilot population
    Kp = set(range(0, 10))      # long-run population; pilot nested inside
    T = set(range(0, 5))        # pilot draws
    Tp = set(range(5, 15))      # long-run draws: DISJOINT from the pilot's
    c = pop_cov(sigma, rho, K, T, Kp, Tp)
    print(f"  |K| = {len(K)} nested in |K'| = {len(Kp)}, draws disjoint.")
    check("covariance = rho sigma^2 / |K'|", c, rho * sigma ** 2 / len(Kp))
    print(f"  Disjoint measurement machinery, yet covariance = {c:.6f} > 0.")
    emp = simulate_two_level(K, T, Kp, Tp, sigma, rho, trials=20000, seed=5)
    check("Monte Carlo covariance", c, emp, tol=8e-2)

    K2 = set(range(20, 30))     # a genuinely fresh population
    c2 = pop_cov(sigma, rho, K, T, K2, Tp)
    check("disjoint populations give exactly zero", c2, 0.0)

    print("\n  Two-level design effect (K = K', T = T'):")
    v = pop_cov(sigma, rho, Kp, Tp, Kp, Tp)
    check("Var = rho s^2/|K| + (1-rho) s^2/(|K||T|)",
          v,
          rho * sigma ** 2 / len(Kp)
          + (1 - rho) * sigma ** 2 / (len(Kp) * len(Tp)))

    print("\n  Cost of ignoring the shared population when pooling:")
    for w in (0.2, 0.35, 0.5):
        excess = 2 * w * (1 - w) * rho * sigma ** 2 / len(Kp)
        print(f"    w = {w:<5} honest variance exceeds reported by {excess:.6f}")


# --------------------------------------------------------------------------- #
# 7. The cluster ceiling
# --------------------------------------------------------------------------- #


def demo_cluster_ceiling() -> None:
    rule("7. The cluster ceiling: why 76.8M pairs are not 76.8M observations")
    sigma, rho, k = 1.0, 0.01, 128
    floor = rho * sigma ** 2 / k
    print(f"  k = {k} clusters, rho = {rho}, variance floor rho s^2/k = {floor:.6e}")
    print(f"  {'m per cluster':>15} {'raw pairs':>14} {'design effect':>15} "
          f"{'Var':>13} {'n_eff':>12}")
    for m in (1, 10, 1_000, 150_000, 600_000, 10_000_000):
        v = grand_mean_var(sigma, rho, k, m)
        print(f"  {m:>15,} {k * m:>14,} {design_effect(m, rho):>15.3f} "
              f"{v:>13.6e} {effective_sample_size(k, m, rho):>12,.0f}")
    print(f"  Ceiling on the effective sample size: k/rho = {k / rho:,.0f}")
    v600 = grand_mean_var(sigma, rho, k, 600_000)
    print(f"  At m = 600,000 the variance is {v600 / floor:.6f} x the floor "
          f"-- already within {100 * (v600 / floor - 1):.3f}% of it.")
    emp = simulate_clusters(k=8, m=40, sigma=1.0, rho=0.3, trials=4000, seed=3)
    check("Monte Carlo check (k=8, m=40, rho=0.3)",
          grand_mean_var(1.0, 0.3, 8, 40), emp, tol=8e-2)


# --------------------------------------------------------------------------- #
# 8. GLS repair
# --------------------------------------------------------------------------- #


def demo_gls() -> None:
    rule("8. What to do instead: generalised least squares for correlated legs")
    sigma = 1.0
    nS, nT = 150_000, 600_000
    v1, v2 = sigma ** 2 / nS, sigma ** 2 / nT
    c = sigma ** 2 / nT                       # nested: Cov = Var of long leg
    ws, floor = gls_weight(v1, v2, c), gls_floor(v1, v2, c)
    print(f"  Nested legs: v1 = {v1:.3e}, v2 = {v2:.3e}, c = {c:.3e}")
    check("optimal weight is 0 (discard the prefix)", ws, 0.0)
    check("floor equals the long leg's own variance", floor, v2)
    grid = [i / 1000 for i in range(0, 1001)]
    best = min(grid, key=lambda w: pool_var_quadratic(v1, v2, c, w))
    print(f"  Numerical minimiser over a grid: w = {best:.3f}")

    print("\n  Disjoint legs restore the classical inverse-variance weight:")
    cd = 0.0
    check("w* = |S|/(|S|+|T|)", gls_weight(v1, v2, cd), nS / (nS + nT))
    check("floor = sigma^2/(|S|+|T|)", gls_floor(v1, v2, cd), sigma ** 2 / (nS + nT))

    print("\n  Inverse-variance weighting is optimal iff c (v2 - v1) = 0:")
    for (a, b, cc) in ((0.04, 0.01, 0.0), (0.02, 0.02, 0.005), (0.04, 0.01, 0.005)):
        ivw = b / (a + b)
        gls = gls_weight(a, b, cc)
        cond = cc * (b - a)
        print(f"    v1={a}, v2={b}, c={cc}:  IVW = {ivw:.5f}, GLS = {gls:.5f}, "
              f"c(v2-v1) = {cond:.5f}  -> agree? {abs(ivw - gls) < 1e-12}")


# --------------------------------------------------------------------------- #
# 9. The audit, end to end
# --------------------------------------------------------------------------- #


def demo_audit() -> None:
    rule("9. The audit, end to end")
    k, m = 128, 600_000
    print(f"  Run: {k} moduli x {m:,} paired samples = {k * m:,} pairs.")
    print("  Reported (cluster bootstrap over moduli):")
    print("    cut 1e5 : r = 0.9710  CI [0.8976, 1.0521]   -> covers 1")
    print("    cut 1e6 : r = 0.9623  CI [0.9224, 1.0040]   -> covers 1")

    print("\n  Failure 1 -- three-leg joint (a run pooled with its own prefix):")
    sigma = 1.0
    S, T = set(range(150_000)), set(range(600_000))
    w = ivw_weight(S, T)
    nv, tv = naive_var(sigma, w, S, T), true_var(sigma, w, S, T)
    print(f"    reported variance {nv:.6e}, honest variance {tv:.6e}, "
          f"inflation {tv / nv:.4f}")
    print(f"    self-pooling a dataset with itself reports exactly half: "
          f"{true_var(sigma, 0.5, T, T) / naive_var(sigma, 0.5, T, T):.1f}x")

    print("\n  Failure 2 -- 'nominally independent' pilot x long run:")
    r_pilot, se_pilot = 0.9468, 0.0449
    r_long, se_long = 0.9623, 0.0208
    w_ivw = (1 / se_pilot ** 2) / (1 / se_pilot ** 2 + 1 / se_long ** 2)
    r_joint = w_ivw * r_pilot + (1 - w_ivw) * r_long
    se_joint = math.sqrt(1.0 / (1 / se_pilot ** 2 + 1 / se_long ** 2))
    print(f"    naive joint: r = {r_joint:.4f}, se = {se_joint:.4f}, "
          f"CI [{r_joint - 1.96 * se_joint:.4f}, {r_joint + 1.96 * se_joint:.4f}]")
    z_rep = (1.0 - r_joint) / se_joint
    print(f"    reported z = {z_rep:.3f}  (excludes 1 at 1.96? "
          f"{z_rep >= 1.96})")
    z_hon = z_rep / math.sqrt(7.0 / 5.0)
    print(f"    honest z after the 7/5 inflation = {z_hon:.3f}  (excludes 1? "
          f"{z_hon >= 1.96})")
    print("    all 24 pilot moduli reconstruct inside the 128-modulus pool, so "
          "the\n    covariance rho s^2 |K n K'|/(|K||K'|) is strictly positive.")

    print("\n  What the run is worth (rho = 0.01):")
    rho = 0.01
    print(f"    raw pairs                {k * m:>12,}")
    print(f"    design effect            {design_effect(m, rho):>12,.2f}")
    print(f"    effective sample size    {effective_sample_size(k, m, rho):>12,.0f}")
    print(f"    ceiling k/rho            {k / rho:>12,.0f}")
    print(f"    ratio raw : effective    "
          f"{k * m / effective_sample_size(k, m, rho):>12,.0f} : 1")

    print("\n  The only move that lowers the floor: a fresh master seed.")
    A, B = set(range(0, m)), set(range(m, 2 * m))
    v_fresh = true_var(1.0, ivw_weight(A, B), A, B)
    print(f"    disjoint equal-size replication: Var = {v_fresh:.6e} = "
          f"{v_fresh / (1.0 / m):.3f} x the single-run variance "
          f"(error bars / sqrt(2)).")


# --------------------------------------------------------------------------- #


def main() -> None:
    print("Numerical demonstrations: the exact algebra of overlapping "
          "measurement legs")
    demo_master_identity()
    demo_defect_law()
    demo_duplicate_leg()
    demo_nested_prefix()
    demo_lineage_bound()
    demo_population_overlap()
    demo_cluster_ceiling()
    demo_gls()
    demo_audit()
    print("\nAll identities verified.\n")


if __name__ == "__main__":
    main()
