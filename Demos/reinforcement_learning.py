"""
Numerical demonstration of the drift, variance and covariance laws for the
KL-regularized preference-optimization objective

    J(q) = E_q[r] - beta * KL(q || p) + gamma * E_d[log q].

Everything is exact on a finite response space: the optimizer of the gamma = 0
objective is the exponential tilt

    pi_beta(y) = p(y) * exp(r(y)/beta) / Z,    Z = sum_y p(y) exp(r(y)/beta),

and every theorem below is checked numerically against that closed form.

Self-contained: standard library + math only (no numpy required).

Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
#  Basic finite-probability utilities
# --------------------------------------------------------------------------- #


def is_distribution(p: Sequence[float], tol: float = 1e-12) -> bool:
    """True if p is a probability vector (nonnegative, sums to one)."""
    return all(x >= -tol for x in p) and abs(sum(p) - 1.0) <= 1e-9


def mean(p: Sequence[float], f: Sequence[float]) -> float:
    """E_p[f] = sum_y p(y) f(y)."""
    return sum(pi * fi for pi, fi in zip(p, f))


def variance(p: Sequence[float], f: Sequence[float]) -> float:
    """Var_p(f) = E_p[(f - E_p f)^2]."""
    m = mean(p, f)
    return sum(pi * (fi - m) ** 2 for pi, fi in zip(p, f))


def stddev(p: Sequence[float], f: Sequence[float]) -> float:
    """sigma_p(f) = sqrt(Var_p(f))."""
    return math.sqrt(max(variance(p, f), 0.0))


def covariance(p: Sequence[float], f: Sequence[float], g: Sequence[float]) -> float:
    """Cov_p(f, g) = E_p[(f - E_p f)(g - E_p g)]."""
    mf, mg = mean(p, f), mean(p, g)
    return sum(pi * (fi - mf) * (gi - mg) for pi, fi, gi in zip(p, f, g))


def variance_pair_form(p: Sequence[float], f: Sequence[float]) -> float:
    """Pair representation Var_p(f) = 1/2 sum_{x,y} p(x)p(y)(f(x)-f(y))^2."""
    total = 0.0
    for px, fx in zip(p, f):
        for py, fy in zip(p, f):
            total += px * py * (fx - fy) ** 2
    return 0.5 * total


def kl_divergence(q: Sequence[float], p: Sequence[float]) -> float:
    """KL(q || p) = sum_y q(y) log(q(y)/p(y)); requires p > 0."""
    total = 0.0
    for qi, pi in zip(q, p):
        if qi > 0.0:
            total += qi * math.log(qi / pi)
    return total


def l1_distance(q: Sequence[float], p: Sequence[float]) -> float:
    """||q - p||_1 = sum_y |q(y) - p(y)| (twice the total variation distance)."""
    return sum(abs(qi - pi) for qi, pi in zip(q, p))


def reward_range(r: Sequence[float]) -> float:
    """range(r) = max r - min r."""
    return max(r) - min(r)


# --------------------------------------------------------------------------- #
#  The aligned (Gibbs) policy
# --------------------------------------------------------------------------- #


def tilt_and_policy(
    p: Sequence[float], r: Sequence[float], beta: float
) -> Tuple[List[float], List[float], float]:
    """Return (tilt T_beta, aligned policy pi_beta, partition function Z_beta).

    Uses the max-subtraction trick for numerical stability; the value of Z is
    reconstructed exactly afterwards.
    """
    u = [ri / beta for ri in r]
    umax = max(u)
    weights = [pi * math.exp(ui - umax) for pi, ui in zip(p, u)]
    s = sum(weights)
    z = s * math.exp(umax)  # = sum_y p(y) e^{r(y)/beta}
    pi_beta = [w / s for w in weights]
    tilt = [math.exp(ui) / z for ui in u]
    return tilt, pi_beta, z


def diagnostics(p: Sequence[float], r: Sequence[float], beta: float) -> Dict[str, float]:
    """All drift diagnostics for one temperature."""
    tilt, pi_beta, z = tilt_and_policy(p, r, beta)
    rng = reward_range(r)
    var_r = variance(p, r)
    kl = kl_divergence(pi_beta, p)
    l1 = l1_distance(pi_beta, p)
    return {
        "beta": beta,
        "Z": z,
        "KL": kl,
        "L1": l1,
        "gain": mean(pi_beta, r) - mean(p, r),
        # Theorem: self-limiting divergence
        "bound_KL_range": rng / beta,
        # Theorem: quadratic divergence bound
        "bound_KL_quadratic": rng**2 / (2 * beta**2) * math.exp(rng / beta),
        # Theorem: variance drift law
        "bound_KL_variance": math.exp(rng / beta) * var_r / beta**2,
        "bound_L1_pinsker": math.sqrt(2 * rng / beta),
        "bound_L1_quadratic": rng / beta * math.exp(rng / (2 * beta)),
        "bound_L1_variance": math.sqrt(2 * math.exp(rng / beta) * var_r) / beta,
        # Theorem: drift caps gain
        "bound_gain_upper": rng / 2 * l1,
        # Theorem: gain costs drift
        "bound_gain_lower": beta * kl,
    }


# --------------------------------------------------------------------------- #
#  Demo 1: the drift hierarchy on a rare-spike reward
# --------------------------------------------------------------------------- #


def demo_drift_hierarchy() -> None:
    """Range-based versus variance-based drift bounds on a rare-spike reward.

    The reference policy puts mass 1 - delta on responses with reward 0 and mass
    delta on a single 'exploit' response with reward R.  Then range(r) = R but
    Var_p(r) = delta(1-delta)R^2, which is far smaller.  The variance bound is
    correspondingly far tighter.
    """
    print("=" * 78)
    print("DEMO 1 — the drift hierarchy (rare-spike reward)")
    print("=" * 78)
    n_bulk = 8
    delta = 0.01
    big_r = 10.0
    p = [(1 - delta) / n_bulk] * n_bulk + [delta]
    r = [0.0] * n_bulk + [big_r]
    assert is_distribution(p)

    print(f"|Omega| = {len(p)},  range(r) = {reward_range(r):.3f},  "
          f"Var_p(r) = {variance(p, r):.4f},  sigma_p(r) = {stddev(p, r):.4f}")
    print(f"(Popoviciu: Var <= range^2/4 = {reward_range(r) ** 2 / 4:.4f})\n")

    header = f"{'beta':>8} {'||pi-p||_1':>12} {'sqrt-law':>12} {'range-law':>12} {'var-law':>12}"
    print(header)
    print("-" * len(header))
    for beta in (10.0, 20.0, 50.0, 100.0, 500.0):
        d = diagnostics(p, r, beta)
        print(f"{beta:>8.1f} {d['L1']:>12.6f} {d['bound_L1_pinsker']:>12.6f} "
              f"{d['bound_L1_quadratic']:>12.6f} {d['bound_L1_variance']:>12.6f}")
        assert d["L1"] <= d["bound_L1_pinsker"] + 1e-12
        assert d["L1"] <= d["bound_L1_quadratic"] + 1e-12
        assert d["L1"] <= d["bound_L1_variance"] + 1e-12
        assert d["KL"] <= d["bound_KL_range"] + 1e-12
        assert d["KL"] <= d["bound_KL_quadratic"] + 1e-12
        assert d["KL"] <= d["bound_KL_variance"] + 1e-12
    print("\nAll three bounds hold; the variance law is the tightest, and the")
    print("square-root law is loose by orders of magnitude at large beta.\n")


# --------------------------------------------------------------------------- #
#  Demo 2: exact two-point drift and sharpness of the sigma/beta law
# --------------------------------------------------------------------------- #


def demo_two_point_sharpness() -> None:
    """Closed-form drift tanh(a/2beta) on the two-point model, and its sandwich.

    Uniform reference on {t, f}, reward a on t and 0 on f.  Then
    ||pi_beta - p||_1 = tanh(a/(2 beta)) exactly, sigma_p(r) = a/2, and for
    0 < a <= beta the drift lies in [sigma/(2 beta), 3 sigma / beta].
    """
    print("=" * 78)
    print("DEMO 2 — exact two-point drift and Theta(sigma/beta) sharpness")
    print("=" * 78)
    p = [0.5, 0.5]
    header = (f"{'a':>6} {'beta':>7} {'drift':>12} {'tanh(a/2b)':>12} "
              f"{'sigma/(2b)':>12} {'3 sigma/b':>12}")
    print(header)
    print("-" * len(header))
    for a, beta in ((1.0, 1.0), (1.0, 4.0), (2.0, 5.0), (0.5, 20.0), (3.0, 100.0)):
        r = [a, 0.0]
        _, pi_beta, _ = tilt_and_policy(p, r, beta)
        drift = l1_distance(pi_beta, p)
        closed = math.tanh(a / (2 * beta))
        sigma = stddev(p, r)  # = a/2
        lo, hi = sigma / (2 * beta), 3 * sigma / beta
        print(f"{a:>6.2f} {beta:>7.2f} {drift:>12.8f} {closed:>12.8f} "
              f"{lo:>12.8f} {hi:>12.8f}")
        assert abs(drift - closed) < 1e-12
        assert abs(sigma - a / 2) < 1e-12
        assert lo - 1e-12 <= drift <= hi + 1e-12  # requires 0 < a <= beta
    print("\nThe drift matches tanh(a/2beta) to machine precision and is trapped")
    print("between sigma/(2 beta) and 3 sigma / beta: the law is Theta(sigma/beta).\n")


# --------------------------------------------------------------------------- #
#  Demo 3: the audit gap is a covariance
# --------------------------------------------------------------------------- #


def demo_audit_covariance(seed: int = 20260820) -> None:
    """First-order expansion of the audit gap, and second-order safety.

    For |r| <= R <= beta and any statistic f,
        | E_{pi_beta}[f] - E_p[f] - Cov_p(r,f)/beta |  <=  24 (R/beta)^2 sigma_p(f).
    We check this on a random reference policy for (i) a statistic strongly
    correlated with the reward, (ii) a statistic constructed to have exactly zero
    reference covariance with the reward, which then moves only at order beta^-2.
    """
    print("=" * 78)
    print("DEMO 3 — the audit gap is a covariance (first-order expansion)")
    print("=" * 78)
    rng = random.Random(seed)
    n = 12
    raw = [rng.random() + 0.05 for _ in range(n)]
    s = sum(raw)
    p = [x / s for x in raw]
    r = [rng.uniform(-1.0, 1.0) for _ in range(n)]
    big_r = max(abs(x) for x in r)

    f_corr = [2.0 * ri + 0.3 * rng.uniform(-1, 1) for ri in r]
    # Gram-Schmidt in L^2(p): remove the r-component from a random statistic.
    f_raw = [rng.uniform(-1.0, 1.0) for _ in range(n)]
    coef = covariance(p, r, f_raw) / variance(p, r)
    f_orth = [fi - coef * ri for fi, ri in zip(f_raw, r)]
    assert abs(covariance(p, r, f_orth)) < 1e-12

    for name, f in (("correlated", f_corr), ("uncorrelated", f_orth)):
        print(f"\naudit statistic: {name}   "
              f"Cov_p(r,f) = {covariance(p, r, f):+.6f}   "
              f"sigma_p(f) = {stddev(p, f):.4f}")
        header = (f"{'beta':>8} {'true gap':>14} {'Cov/beta':>14} "
                  f"{'|residual|':>14} {'24(R/b)^2 s_f':>16}")
        print(header)
        print("-" * len(header))
        for beta in (1.0, 2.0, 5.0, 20.0, 100.0):
            if beta < big_r:
                continue  # the theorem requires R <= beta
            _, pi_beta, _ = tilt_and_policy(p, r, beta)
            gap = mean(pi_beta, f) - mean(p, f)
            pred = covariance(p, r, f) / beta
            resid = abs(gap - pred)
            bound = 24 * (big_r / beta) ** 2 * stddev(p, f)
            print(f"{beta:>8.1f} {gap:>+14.8f} {pred:>+14.8f} "
                  f"{resid:>14.2e} {bound:>16.2e}")
            assert resid <= bound + 1e-12
    print("\nFor the correlated statistic the gap tracks Cov_p(r,f)/beta.")
    print("For the uncorrelated one the whole gap is the O(beta^-2) remainder:")
    print("first-order reward hacking requires correlation with the reward.\n")


# --------------------------------------------------------------------------- #
#  Demo 4: gain-drift budget and the PTX mix-in
# --------------------------------------------------------------------------- #


def objective_ptx(
    q: Sequence[float],
    p: Sequence[float],
    r: Sequence[float],
    d: Sequence[float],
    beta: float,
    gamma: float,
) -> float:
    """J_gamma(q) = E_q[r] - beta KL(q||p) + gamma E_d[log q]."""
    return (
        mean(q, r)
        - beta * kl_divergence(q, p)
        + gamma * sum(di * math.log(qi) for di, qi in zip(d, q))
    )


def demo_gain_and_ptx(seed: int = 7) -> None:
    """Two-sided gain-drift inequalities, and the pretraining budget inequality.

        beta KL(pi||p) <= gain <= (range r / 2) ||pi - p||_1,
        beta KL(q||p) + gamma KL(d||q) <= range(r) + gamma KL(d||p)
    for ANY policy q that beats the reference under the full objective.
    """
    print("=" * 78)
    print("DEMO 4 — gain-drift budget and the pretraining (PTX) budget")
    print("=" * 78)
    rng = random.Random(seed)
    n = 10
    raw = [rng.random() + 0.1 for _ in range(n)]
    p = [x / sum(raw) for x in raw]
    raw_d = [rng.random() + 0.1 for _ in range(n)]
    d = [x / sum(raw_d) for x in raw_d]
    r = [rng.uniform(0.0, 3.0) for _ in range(n)]
    rr = reward_range(r)

    print(f"range(r) = {rr:.4f},  KL(d||p) = {kl_divergence(d, p):.4f}\n")
    header = (f"{'beta':>8} {'gain':>12} {'beta*KL (lo)':>14} "
              f"{'(rng/2)*L1 (hi)':>16} {'rng^2/beta':>12}")
    print(header)
    print("-" * len(header))
    for beta in (1.0, 3.0, 10.0, 50.0):
        dg = diagnostics(p, r, beta)
        print(f"{beta:>8.1f} {dg['gain']:>12.6f} {dg['bound_gain_lower']:>14.6f} "
              f"{dg['bound_gain_upper']:>16.6f} "
              f"{rr ** 2 / beta if beta >= rr else float('nan'):>12.6f}")
        assert dg["bound_gain_lower"] <= dg["gain"] + 1e-12
        assert dg["gain"] <= dg["bound_gain_upper"] + 1e-12
        if beta >= rr:
            assert dg["gain"] <= rr**2 / beta + 1e-12

    print("\nPTX budget check on the exact PTX optimum found by mirror ascent:")
    beta, gamma = 2.0, 0.7
    q = ptx_optimize(p, r, d, beta, gamma)
    assert objective_ptx(p, p, r, d, beta, gamma) <= objective_ptx(q, p, r, d, beta, gamma) + 1e-12
    lhs = beta * kl_divergence(q, p) + gamma * kl_divergence(d, q)
    rhs = rr + gamma * kl_divergence(d, p)
    print(f"  beta KL(q||p) + gamma KL(d||q) = {lhs:.6f}")
    print(f"  range(r) + gamma KL(d||p)      = {rhs:.6f}")
    print(f"  budget satisfied: {lhs <= rhs + 1e-9}")
    print(f"  KL(q||p) = {kl_divergence(q, p):.6f} <= "
          f"{(rr + gamma * kl_divergence(d, p)) / beta:.6f}")
    print(f"  KL(d||q) = {kl_divergence(d, q):.6f} <= "
          f"{kl_divergence(d, p) + rr / gamma:.6f}\n")
    assert lhs <= rhs + 1e-9


def ptx_optimize(
    p: Sequence[float],
    r: Sequence[float],
    d: Sequence[float],
    beta: float,
    gamma: float,
    steps: int = 20000,
    lr: float = 0.02,
) -> List[float]:
    """Maximize J_gamma by exponentiated-gradient (mirror) ascent on the simplex.

    The objective is strictly concave in q, so the iteration converges to the
    unique maximizer; we only need a policy that beats the reference, so even a
    partially converged iterate is a valid witness for the budget inequality.
    """
    q = list(p)
    for _ in range(steps):
        grad = [
            ri - beta * (math.log(qi / pi) + 1.0) + gamma * di / qi
            for ri, qi, pi, di in zip(r, q, p, d)
        ]
        q = [qi * math.exp(lr * gi) for qi, gi in zip(q, grad)]
        s = sum(q)
        q = [qi / s for qi in q]
    return q


# --------------------------------------------------------------------------- #
#  Demo 5: the zero-temperature phase
# --------------------------------------------------------------------------- #


def demo_zero_temperature() -> None:
    """Laplace principle and total collapse as beta decreases to 0.

    max r + beta log(min p) <= beta log Z <= max r, every suboptimal response is
    suppressed like exp(-(max r - r(y))/beta), and in the two-point model the
    drift tends to its maximal value 1.
    """
    print("=" * 78)
    print("DEMO 5 — the low-temperature phase: Laplace estimate and collapse")
    print("=" * 78)
    p = [0.5, 0.3, 0.2]
    r = [0.0, 1.0, 2.5]
    rstar, pmin = max(r), min(p)
    header = (f"{'beta':>10} {'beta log Z':>14} {'lower':>12} {'upper':>10} "
              f"{'pi(worst)':>12} {'suppr. bd':>12}")
    print(header)
    print("-" * len(header))
    for beta in (2.0, 1.0, 0.5, 0.2, 0.05, 0.01):
        _, pi_beta, z = tilt_and_policy(p, r, beta)
        fe = beta * math.log(z)
        lower = rstar + beta * math.log(pmin)
        bd = (1 / pmin) * math.exp(-(rstar - r[0]) / beta)
        print(f"{beta:>10.3f} {fe:>14.8f} {lower:>12.6f} {rstar:>10.4f} "
              f"{pi_beta[0]:>12.3e} {min(bd, 1.0):>12.3e}")
        assert lower - 1e-12 <= fe <= rstar + 1e-12
        assert pi_beta[0] <= bd + 1e-12

    print("\nTwo-point collapse (uniform reference, unit spike reward):")
    p2 = [0.5, 0.5]
    r2 = [1.0, 0.0]
    for beta in (1.0, 0.3, 0.1, 0.03, 0.01):
        _, pi2, _ = tilt_and_policy(p2, r2, beta)
        print(f"   beta = {beta:>6.3f}   ||pi_beta - p||_1 = {l1_distance(pi2, p2):.8f}")
    print("   -> 1, the maximal possible value: total policy collapse.\n")


# --------------------------------------------------------------------------- #
#  Demo 6: structural identities
# --------------------------------------------------------------------------- #


def demo_identities(seed: int = 99) -> None:
    """Check the two identities that drive every proof.

    (i)  Pair representation:  Var_p(f) = 1/2 sum_{x,y} p(x)p(y)(f(x)-f(y))^2.
    (ii) Reweighting identity: E_{pi_beta}[f] - E_p[f] = Cov_p(T_beta, f).
    (iii) Divergence of the tilt: KL(pi_beta||p) = E_{pi_beta}[r]/beta - log Z.
    """
    print("=" * 78)
    print("DEMO 6 — the structural identities behind the proofs")
    print("=" * 78)
    rng = random.Random(seed)
    n = 9
    raw = [rng.random() + 0.05 for _ in range(n)]
    p = [x / sum(raw) for x in raw]
    r = [rng.uniform(-2, 2) for _ in range(n)]
    f = [rng.uniform(-5, 5) for _ in range(n)]
    beta = 3.0
    tilt, pi_beta, z = tilt_and_policy(p, r, beta)

    v1, v2 = variance(p, f), variance_pair_form(p, f)
    print(f"pair representation:      Var = {v1:.12f}  vs  {v2:.12f}")
    assert abs(v1 - v2) < 1e-10

    g1 = mean(pi_beta, f) - mean(p, f)
    g2 = covariance(p, tilt, f)
    print(f"reweighting identity:     gap = {g1:+.12f}  vs  {g2:+.12f}")
    assert abs(g1 - g2) < 1e-10

    k1 = kl_divergence(pi_beta, p)
    k2 = mean(pi_beta, r) / beta - math.log(z)
    print(f"divergence of the tilt:   KL  = {k1:.12f}  vs  {k2:.12f}")
    assert abs(k1 - k2) < 1e-10

    print(f"mean of the tilt (= 1):   {mean(p, tilt):.12f}")
    assert abs(mean(p, tilt) - 1.0) < 1e-10

    # Pinsker and its sharpness on the two-point family.
    print("\nPinsker ratio 2 KL / ||q-p||_1^2 on the two-point family (-> 1):")
    for eps in (0.2, 0.1, 0.05, 0.01, 0.001):
        q = [0.5 + eps, 0.5 - eps]
        u = [0.5, 0.5]
        ratio = 2 * kl_divergence(q, u) / l1_distance(q, u) ** 2
        print(f"   eps = {eps:<8} ratio = {ratio:.8f}")
        assert ratio >= 1.0 - 1e-12  # Pinsker
    print()


def main() -> None:
    demo_identities()
    demo_drift_hierarchy()
    demo_two_point_sharpness()
    demo_audit_covariance()
    demo_gain_and_ptx()
    demo_zero_temperature()
    print("=" * 78)
    print("All numerical checks passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
