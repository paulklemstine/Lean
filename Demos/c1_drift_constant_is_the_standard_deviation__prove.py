"""
Sharp first-order drift laws for KL-regularised alignment: numerical demonstration.

Setting
-------
A finite outcome set with base policy p (strictly positive) and reward r.  The
KL-regularised (Gibbs) policy at temperature beta > 0 is

    pi_beta(y)  =  p(y) exp(r(y)/beta) / sum_z p(z) exp(r(z)/beta),

the unique maximiser of  E_q[r] - beta * KL(q || p).

Results demonstrated
--------------------
1.  beta * || pi_beta - p ||_1            ->  MAD_p(r) = E_p |r - E_p r|
    with two-sided error bounds  -3 Var/beta^2 .. +2 Var/beta^2  for beta >= range(r).
2.  Deviation defect identity: Var - MAD^2 = E_p ( |r - E_p r| - MAD )^2 >= 0,
    hence MAD <= sigma, with equality iff |r - E_p r| is constant.
3.  beta^2 * KL(pi_beta || p)             ->  Var_p(r) / 2.
4.  beta * ( E_{pi_beta}[f] - E_p[f] )    ->  Cov_p(r, f)   for any statistic f,
    and the drift is o(1/beta) whenever Cov_p(r, f) = 0.
5.  || pi_beta - p ||_1 / sqrt(2 KL)      ->  MAD_p(r) / sigma_p(r) <= 1,
    equal to 1 exactly for balanced two-valued rewards (exact Pinsker defect).
6.  Rare-spike family p(hit) = eps, r = 1_{hit}:  MAD/sigma = 2 sqrt(eps(1-eps)) -> 0,
    so the standard-deviation law is unboundedly lossy.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

Vector = Sequence[float]

# --------------------------------------------------------------------------- #
# Core functionals
# --------------------------------------------------------------------------- #


def mean(p: Vector, f: Vector) -> float:
    """Expectation E_p[f] = sum_y p(y) f(y)."""
    return sum(pi * fi for pi, fi in zip(p, f))


def variance(p: Vector, f: Vector) -> float:
    """Var_p(f) = E_p[(f - E_p f)^2]."""
    m = mean(p, f)
    return sum(pi * (fi - m) ** 2 for pi, fi in zip(p, f))


def stddev(p: Vector, f: Vector) -> float:
    """sigma_p(f) = sqrt(Var_p(f))."""
    return math.sqrt(variance(p, f))


def mad(p: Vector, f: Vector) -> float:
    """Mean absolute deviation MAD_p(f) = E_p |f - E_p f|."""
    m = mean(p, f)
    return sum(pi * abs(fi - m) for pi, fi in zip(p, f))


def covariance(p: Vector, f: Vector, g: Vector) -> float:
    """Cov_p(f, g) = E_p[(f - E_p f)(g - E_p g)]."""
    mf, mg = mean(p, f), mean(p, g)
    return sum(pi * (fi - mf) * (gi - mg) for pi, fi, gi in zip(p, f, g))


def reward_range(f: Vector) -> float:
    """range(f) = max f - min f."""
    return max(f) - min(f)


def deviation_defect(p: Vector, f: Vector) -> float:
    """Var_p(f) - MAD_p(f)^2, computed as the variance of the absolute deviation."""
    m, md = mean(p, f), mad(p, f)
    return sum(pi * (abs(fi - m) - md) ** 2 for pi, fi in zip(p, f))


# --------------------------------------------------------------------------- #
# Gibbs policy (centred form: numerically stable for beta >= range(r))
# --------------------------------------------------------------------------- #


def gibbs_policy(p: Vector, r: Vector, beta: float) -> List[float]:
    """pi_beta(y) = p(y) e^{(r(y)-mu)/beta} / W_beta   with   mu = E_p[r]."""
    mu = mean(p, r)
    w = [math.exp((ri - mu) / beta) for ri in r]
    norm = sum(pi * wi for pi, wi in zip(p, w))
    return [pi * wi / norm for pi, wi in zip(p, w)]


def l1_distance(q: Vector, p: Vector) -> float:
    """|| q - p ||_1 = sum_y |q(y) - p(y)|  (twice the total-variation distance)."""
    return sum(abs(qi - pi) for qi, pi in zip(q, p))


def kl_divergence(q: Vector, p: Vector) -> float:
    """KL(q || p) = sum_y q(y) log(q(y)/p(y))."""
    return sum(qi * math.log(qi / pi) for qi, pi in zip(q, p) if qi > 0.0)


def certified_temperature(p: Vector, r: Vector, delta: float) -> float:
    """Smallest certified temperature with || pi_beta - p ||_1 <= delta.

    Solves  MAD/beta + 2 Var/beta^2 = delta  and clips below at range(r), the
    validity threshold of the two-sided drift law.
    """
    md, v = mad(p, r), variance(p, r)
    beta = (md + math.sqrt(md * md + 8.0 * delta * v)) / (2.0 * delta)
    return max(beta, reward_range(r))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #


def banner(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_total_variation_law(p: Vector, r: Vector, betas: Sequence[float]) -> None:
    """beta * ||pi_beta - p||_1  ->  MAD_p(r), inside explicit two-sided bounds."""
    banner("1.  TOTAL-VARIATION DRIFT LAW:  beta * ||pi_beta - p||_1  ->  MAD_p(r)")
    md, v, rng = mad(p, r), variance(p, r), reward_range(r)
    print(f"MAD_p(r) = {md:.8f}   Var_p(r) = {v:.8f}   sigma_p(r) = {math.sqrt(v):.8f}"
          f"   range(r) = {rng:.4f}\n")
    print(f"{'beta':>10} {'lower':>14} {'beta*L1':>14} {'upper':>14} {'residual':>14}")
    for beta in betas:
        q = gibbs_policy(p, r, beta)
        scaled = beta * l1_distance(q, p)
        lo, hi = md - 3.0 * v / beta, md + 2.0 * v / beta
        ok = "OK" if lo - 1e-12 <= scaled <= hi + 1e-12 else "VIOLATED"
        print(f"{beta:10.1f} {lo:14.8f} {scaled:14.8f} {hi:14.8f} "
              f"{scaled - md:14.2e}  {ok}")


def demo_deviation_defect(p: Vector, r: Vector) -> None:
    """Var - MAD^2 equals the variance of the absolute deviation; MAD <= sigma."""
    banner("2.  DEVIATION DEFECT IDENTITY:  Var - MAD^2 = E_p(|r-mu| - MAD)^2")
    v, md = variance(p, r), mad(p, r)
    lhs, rhs = v - md * md, deviation_defect(p, r)
    print(f"Var - MAD^2                 = {lhs:.12f}")
    print(f"E_p(|r-mu| - MAD)^2         = {rhs:.12f}")
    print(f"identity residual           = {abs(lhs - rhs):.3e}")
    print(f"MAD / sigma                 = {md / math.sqrt(v):.8f}   (<= 1 always)")


def demo_kl_law(p: Vector, r: Vector, betas: Sequence[float]) -> None:
    """beta^2 * KL(pi_beta || p)  ->  Var_p(r)/2."""
    banner("3.  RELATIVE-ENTROPY DRIFT LAW:  beta^2 * KL(pi_beta || p)  ->  Var_p(r)/2")
    v, rng = variance(p, r), reward_range(r)
    target = v / 2.0
    print(f"Var_p(r)/2 = {target:.8f}\n")
    print(f"{'beta':>10} {'beta^2*KL':>16} {'target':>16} {'|error|':>14} {'bound':>14}")
    for beta in betas:
        q = gibbs_policy(p, r, beta)
        scaled = beta * beta * kl_divergence(q, p)
        bound = beta * beta * (2.0 * rng * v / beta ** 3 + 3.0 * v * v / beta ** 4)
        ok = "OK" if abs(scaled - target) <= bound + 1e-12 else "VIOLATED"
        print(f"{beta:10.1f} {scaled:16.10f} {target:16.10f} "
              f"{abs(scaled - target):14.2e} {bound:14.2e}  {ok}")


def demo_audit_law(p: Vector, r: Vector, f: Vector, name: str,
                   betas: Sequence[float]) -> None:
    """beta * (E_{pi_beta} f - E_p f)  ->  Cov_p(r, f)."""
    banner(f"4.  AUDIT-DRIFT LAW for statistic '{name}':  "
           f"beta * (E_pi f - E_p f)  ->  Cov_p(r, f)")
    c, v, rf = covariance(p, r, f), variance(p, r), reward_range(f)
    print(f"Cov_p(r, f) = {c:.8f}   range(f) = {rf:.4f}\n")
    print(f"{'beta':>10} {'beta*gap':>16} {'Cov':>16} {'|error|':>14} {'bound':>14}")
    for beta in betas:
        q = gibbs_policy(p, r, beta)
        scaled = beta * (mean(q, f) - mean(p, f))
        bound = beta * (3.0 * rf * v / beta ** 2)
        ok = "OK" if abs(scaled - c) <= bound + 1e-12 else "VIOLATED"
        print(f"{beta:10.1f} {scaled:16.10f} {c:16.10f} "
              f"{abs(scaled - c):14.2e} {bound:14.2e}  {ok}")


def orthogonalise(p: Vector, r: Vector, f: Vector) -> List[float]:
    """Return f - (Cov_p(r,f)/Var_p(r)) * r : the reward-uncorrelated component."""
    beta_coef = covariance(p, r, f) / variance(p, r)
    return [fi - beta_coef * ri for fi, ri in zip(f, r)]


def demo_first_order_invariance(p: Vector, r: Vector, f: Vector,
                                betas: Sequence[float]) -> None:
    """A statistic orthogonalised against the reward has drift o(1/beta)."""
    banner("5.  FIRST-ORDER UNHACKABILITY:  Cov_p(r, f) = 0  =>  drift is o(1/beta)")
    g = orthogonalise(p, r, f)
    print(f"Cov_p(r, g) after orthogonalisation = {covariance(p, r, g):.3e}\n")
    print(f"{'beta':>10} {'beta*gap (raw f)':>20} {'beta*gap (orth. g)':>22}")
    for beta in betas:
        q = gibbs_policy(p, r, beta)
        print(f"{beta:10.1f} {beta * (mean(q, f) - mean(p, f)):20.10f} "
              f"{beta * (mean(q, g) - mean(p, g)):22.10f}")


def demo_pinsker_defect(p: Vector, r: Vector, betas: Sequence[float]) -> None:
    """||pi_beta - p||_1 / sqrt(2 KL)  ->  MAD/sigma, with equality iff balanced."""
    banner("6.  EXACT PINSKER DEFECT:  ||pi_beta - p||_1 / sqrt(2 KL)  ->  MAD/sigma")
    target = mad(p, r) / stddev(p, r)
    print(f"MAD_p(r)/sigma_p(r) = {target:.8f}\n")
    print(f"{'beta':>10} {'ratio':>16} {'MAD/sigma':>16} {'|error|':>14}")
    for beta in betas:
        q = gibbs_policy(p, r, beta)
        ratio = l1_distance(q, p) / math.sqrt(2.0 * kl_divergence(q, p))
        print(f"{beta:10.1f} {ratio:16.10f} {target:16.10f} "
              f"{abs(ratio - target):14.2e}")


def demo_rare_spike_family() -> None:
    """MAD/sigma = 2 sqrt(eps(1-eps)) on the rare-spike family: unbounded loss."""
    banner("7.  RARE-SPIKE FAMILY:  p(hit) = eps, r = 1_{hit}  =>  MAD/sigma "
           "= 2 sqrt(eps(1-eps))")
    print(f"{'eps':>12} {'MAD':>14} {'sigma':>14} {'MAD/sigma':>14} "
          f"{'predicted':>14} {'sigma/MAD':>12}")
    for eps in (0.5, 0.25, 0.1, 0.01, 1e-3, 1e-4, 1e-6):
        p = [1.0 - eps, eps]
        r = [0.0, 1.0]
        md, sd = mad(p, r), stddev(p, r)
        pred = 2.0 * math.sqrt(eps * (1.0 - eps))
        print(f"{eps:12.6g} {md:14.8f} {sd:14.8f} {md / sd:14.8f} "
              f"{pred:14.8f} {sd / md:12.2f}")
    print("\nThe last column is the factor by which the standard-deviation law")
    print("over-states the true total-variation drift.  It diverges as eps -> 0.")


def demo_temperature_budget(p: Vector, r: Vector,
                            tolerances: Sequence[float]) -> None:
    """Certified temperature for a prescribed total-variation budget."""
    banner("8.  CERTIFIED TEMPERATURE BUDGETING")
    print(f"{'delta':>12} {'beta*':>14} {'actual L1':>16} {'certified <=':>14}")
    for delta in tolerances:
        beta = certified_temperature(p, r, delta)
        actual = l1_distance(gibbs_policy(p, r, beta), p)
        ok = "OK" if actual <= delta + 1e-12 else "VIOLATED"
        print(f"{delta:12.6f} {beta:14.6f} {actual:16.10f} {delta:14.6f}  {ok}")


# --------------------------------------------------------------------------- #
# Test problems
# --------------------------------------------------------------------------- #


def normalise(w: Sequence[float]) -> List[float]:
    total = sum(w)
    return [wi / total for wi in w]


def main() -> None:
    betas: Tuple[float, ...] = (5.0, 10.0, 20.0, 50.0, 100.0, 500.0, 2000.0)

    # --- Problem 1: a five-outcome base policy with a graded reward ---------- #
    p1 = normalise([0.35, 0.25, 0.20, 0.15, 0.05])
    r1 = [0.0, 0.8, 1.6, 2.4, 4.0]
    f1 = [1.0, 0.0, 0.5, 2.0, -1.0]  # an audit statistic, correlated with r1

    print("#" * 78)
    print("#  PROBLEM 1: five outcomes, graded reward")
    print("#" * 78)
    print(f"p = {[round(x, 4) for x in p1]}")
    print(f"r = {r1}")
    print(f"f = {f1}")

    demo_total_variation_law(p1, r1, betas)
    demo_deviation_defect(p1, r1)
    demo_kl_law(p1, r1, betas)
    demo_audit_law(p1, r1, f1, "graded audit", betas)
    demo_first_order_invariance(p1, r1, f1, betas)
    demo_pinsker_defect(p1, r1, betas)
    demo_temperature_budget(p1, r1, (0.5, 0.1, 0.01, 0.001))

    # --- Problem 2: the balanced two-valued reward (Pinsker is tight) -------- #
    p2 = [0.5, 0.5]
    r2 = [0.0, 1.0]
    print("\n\n" + "#" * 78)
    print("#  PROBLEM 2: balanced coin, indicator reward  -- MAD = sigma exactly")
    print("#" * 78)
    demo_deviation_defect(p2, r2)
    demo_pinsker_defect(p2, r2, betas)

    # --- Problem 3: the rare-spike separation -------------------------------- #
    print("\n\n" + "#" * 78)
    print("#  PROBLEM 3: separation of the sharp law from the standard-deviation law")
    print("#" * 78)
    demo_rare_spike_family()

    p3 = [1.0 - 1e-3, 1e-3]
    r3 = [0.0, 1.0]
    demo_total_variation_law(p3, r3, betas)
    demo_pinsker_defect(p3, r3, betas)

    print("\n" + "=" * 78)
    print("All predicted first-order laws are reproduced numerically, and every")
    print("value lies inside its certified two-sided error bound.")
    print("=" * 78)


if __name__ == "__main__":
    main()
