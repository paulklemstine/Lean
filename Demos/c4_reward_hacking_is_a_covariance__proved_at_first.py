"""
Reward Hacking Is a Covariance — numerical demonstrations.

This self-contained script verifies, numerically, every quantitative claim of the
accompanying paper for KL-regularized (Gibbs) policies.

Setting
-------
Omega is a finite set of responses.  A base ("reference") policy is a strictly
positive probability vector p on Omega.  A reward r : Omega -> R satisfies
|r| <= R.  The KL-regularized objective

        max_pi  E_pi[r] - beta * KL(pi || p)

has the exact optimum (the Gibbs / aligned policy)

        pi_beta(y) = p(y) exp(r(y)/beta) / Z_beta,
        Z_beta     = sum_y p(y) exp(r(y)/beta).

For an audit statistic f : Omega -> R the AUDIT GAP is

        G(beta) = E_{pi_beta}[f] - E_p[f].

Results demonstrated
--------------------
1.  Exact identity:      G(beta) = Cov_p(pi_beta/p, f)   (all beta).
2.  First-order law:     |G(beta) - Cov_p(r,f)/beta| <= 24 (R/beta)^2 sigma_p(f).
3.  Exact rate:          beta * G(beta) -> Cov_p(r,f).
4.  Safety:              Cov_p(r,f) = 0  =>  |G(beta)| = O(beta^-2).
5.  Sharp threshold:     eps * beta_c(eps) -> |Cov_p(r,f)| as eps -> 0,
                         where beta_c(eps) = sup{beta >= R : |G(beta)| >= eps}.
6.  Second order:        |G - Cov/beta - SkewCov/(2 beta^2)| <= 40 (R/beta)^3 sigma_p(f)
                         and beta^2 (G - Cov/beta) -> SkewCov/2.
7.  Two-point models:    G(beta) = tanh(R/beta) exactly (symmetric model);
                         SkewCov = 8 R^2 q (1-q)(1-2q) != 0 (biased model),
                         so the beta^-2 remainder is genuinely present.

Only the Python standard library is used.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

Vector = Sequence[float]

# ---------------------------------------------------------------------------
# 1.  Moments of the reference policy
# ---------------------------------------------------------------------------


def mean(p: Vector, f: Vector) -> float:
    """E_p[f] = sum_y p(y) f(y)."""
    return sum(pi * fi for pi, fi in zip(p, f))


def variance(p: Vector, f: Vector) -> float:
    """Var_p(f) = E_p[(f - E_p f)^2]."""
    m = mean(p, f)
    return sum(pi * (fi - m) ** 2 for pi, fi in zip(p, f))


def stdev(p: Vector, f: Vector) -> float:
    """sigma_p(f) = sqrt(Var_p(f))."""
    return math.sqrt(max(variance(p, f), 0.0))


def cov(p: Vector, f: Vector, g: Vector) -> float:
    """Cov_p(f,g) = E_p[(f - E_p f)(g - E_p g)]."""
    mf, mg = mean(p, f), mean(p, g)
    return sum(pi * (fi - mf) * (gi - mg) for pi, fi, gi in zip(p, f, g))


def skew_cov(p: Vector, r: Vector, f: Vector) -> float:
    """SkewCov_p(r,f) = E_p[(r - E_p r)^2 (f - E_p f)]."""
    mr, mf = mean(p, r), mean(p, f)
    return sum(pi * (ri - mr) ** 2 * (fi - mf) for pi, ri, fi in zip(p, r, f))


# ---------------------------------------------------------------------------
# 2.  The aligned (Gibbs) policy and the audit gap
# ---------------------------------------------------------------------------


def gibbs_policy(beta: float, r: Vector, p: Vector) -> List[float]:
    """pi_beta(y) = p(y) e^{r(y)/beta} / Z_beta, computed stably."""
    shift = max(r) / beta  # numerical stabilization; cancels in the ratio
    weights = [pi * math.exp(ri / beta - shift) for pi, ri in zip(p, r)]
    z = sum(weights)
    return [w / z for w in weights]


def partition(beta: float, r: Vector, p: Vector) -> float:
    """Z_beta = E_p[e^{r/beta}]."""
    return sum(pi * math.exp(ri / beta) for pi, ri in zip(p, r))


def tilt(beta: float, r: Vector, p: Vector) -> List[float]:
    """The likelihood ratio L_beta = pi_beta / p = e^{r/beta} / Z_beta."""
    z = partition(beta, r, p)
    return [math.exp(ri / beta) / z for ri in r]


def audit_gap(beta: float, r: Vector, p: Vector, f: Vector) -> float:
    """G(beta) = E_{pi_beta}[f] - E_p[f]."""
    return mean(gibbs_policy(beta, r, p), f) - mean(p, f)


# ---------------------------------------------------------------------------
# 3.  The critical regularization strength
# ---------------------------------------------------------------------------


def beta_critical(
    eps: float,
    reward_bound: float,
    r: Vector,
    p: Vector,
    f: Vector,
    tol: float = 1e-12,
) -> float:
    """beta_c(eps) = sup{beta >= R : |G(beta)| >= eps}.

    The theory certifies the bracket [(1-d)C/eps, (1+d)C/eps] with
    C = |Cov_p(r,f)|; we bisect on the outer bracket [R, 4C/eps + 4R], whose
    right endpoint is provably safe for small eps.  Bisection is valid because
    on the certified window the envelope forces a single sign change.
    """
    c = abs(cov(p, r, f))
    lo = reward_bound
    hi = 4.0 * c / eps + 4.0 * reward_bound
    if abs(audit_gap(lo, r, p, f)) < eps:
        return float("nan")  # not hacked anywhere in the perturbative regime
    while hi - lo > tol * max(1.0, hi):
        mid = 0.5 * (lo + hi)
        if abs(audit_gap(mid, r, p, f)) >= eps:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


# ---------------------------------------------------------------------------
# 4.  Example models
# ---------------------------------------------------------------------------


def symmetric_two_point(reward_bound: float) -> Tuple[List[float], List[float], List[float]]:
    """p = (1/2, 1/2), r = (+R, -R), f = (+1, -1).  Cov = R, G(beta) = tanh(R/beta)."""
    return [0.5, 0.5], [reward_bound, -reward_bound], [1.0, -1.0]


def biased_two_point(
    q: float, reward_bound: float
) -> Tuple[List[float], List[float], List[float]]:
    """p = (q, 1-q), r = (+R, -R), f = (+1, -1).

    Cov     = 4 R q (1-q)
    SkewCov = 8 R^2 q (1-q)(1-2q)
    """
    return [q, 1.0 - q], [reward_bound, -reward_bound], [1.0, -1.0]


def random_model(
    n: int, reward_bound: float, seed: int = 20260824
) -> Tuple[List[float], List[float], List[float]]:
    """A random positive base policy, bounded reward and statistic on n responses."""
    rng = random.Random(seed)
    raw = [rng.uniform(0.2, 1.0) for _ in range(n)]
    total = sum(raw)
    p = [x / total for x in raw]
    r = [rng.uniform(-reward_bound, reward_bound) for _ in range(n)]
    f = [rng.uniform(-3.0, 3.0) for _ in range(n)]
    return p, r, f


def orthogonalize(p: Vector, r: Vector, f: Vector) -> List[float]:
    """Return the first-order-safe projection  f - Cov(r,f)/Var(r) * r."""
    lam = cov(p, r, f) / variance(p, r)
    return [fi - lam * ri for fi, ri in zip(f, r)]


def orthogonalize_second(p: Vector, r: Vector, f: Vector) -> List[float]:
    """Gram-Schmidt f against span{r, (r - E r)^2}: makes Cov and SkewCov vanish."""
    mr = mean(p, r)
    s = [(ri - mr) ** 2 for ri in r]
    g = orthogonalize(p, r, f)
    # remove the component along the centred squared fluctuation, keeping Cov(r,.)=0
    s_perp = orthogonalize(p, r, s)
    denom = variance(p, s_perp)
    if denom <= 1e-15:
        return g
    mu = cov(p, s_perp, g) / denom
    return [gi - mu * si for gi, si in zip(g, s_perp)]


# ---------------------------------------------------------------------------
# 5.  Demonstrations
# ---------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_exact_identity() -> None:
    rule("1.  The audit gap is EXACTLY a covariance:  G(beta) = Cov_p(pi_beta/p, f)")
    reward_bound = 1.0
    p, r, f = random_model(8, reward_bound)
    print(f"{'beta':>10} {'G(beta)':>16} {'Cov(L_beta,f)':>18} {'difference':>14}")
    for beta in (0.25, 0.5, 1.0, 2.0, 5.0, 20.0):
        g = audit_gap(beta, r, p, f)
        c = cov(p, tilt(beta, r, p), f)
        print(f"{beta:10.4f} {g:16.10f} {c:18.10f} {abs(g - c):14.2e}")
    print("Identity holds at every beta, including outside the perturbative regime.")


def demo_first_order_law() -> None:
    rule("2.  First-order law:  |G - Cov/beta| <= 24 (R/beta)^2 sigma(f)")
    reward_bound = 1.0
    p, r, f = random_model(8, reward_bound)
    c, s = cov(p, r, f), stdev(p, f)
    print(f"Cov_p(r,f) = {c:.8f}   sigma_p(f) = {s:.8f}   R = {reward_bound}")
    print(f"\n{'beta':>8} {'G(beta)':>14} {'Cov/beta':>14} {'|error|':>12} {'bound':>12} {'slack':>10}")
    for beta in (1.0, 2.0, 4.0, 8.0, 16.0, 64.0, 256.0):
        g = audit_gap(beta, r, p, f)
        err = abs(g - c / beta)
        bound = 24.0 * (reward_bound / beta) ** 2 * s
        print(f"{beta:8.1f} {g:14.9f} {c / beta:14.9f} {err:12.3e} {bound:12.3e} {bound / max(err, 1e-300):10.1f}x")
    print("\nThe bound always holds; the error decays like beta^-2 while Cov/beta ~ beta^-1.")


def demo_exact_rate() -> None:
    rule("3.  The covariance is the EXACT drift rate:  beta * G(beta) -> Cov_p(r,f)")
    reward_bound = 1.0
    p, r, f = random_model(8, reward_bound)
    c = cov(p, r, f)
    print(f"{'beta':>10} {'beta*G(beta)':>18} {'Cov_p(r,f)':>16} {'|difference|':>14}")
    for beta in (1.0, 10.0, 100.0, 1_000.0, 10_000.0, 100_000.0):
        bg = beta * audit_gap(beta, r, p, f)
        print(f"{beta:10.0f} {bg:18.10f} {c:16.10f} {abs(bg - c):14.3e}")


def demo_safety() -> None:
    rule("4.  Safety: statistics orthogonal to the reward move only at order beta^-2")
    reward_bound = 1.0
    p, r, f = random_model(8, reward_bound)
    g1 = orthogonalize(p, r, f)          # Cov = 0
    g2 = orthogonalize_second(p, r, f)   # Cov = 0 and SkewCov = 0
    print(f"raw       f : Cov = {cov(p, r, f):+.6e}   SkewCov = {skew_cov(p, r, f):+.6e}")
    print(f"hardened  f : Cov = {cov(p, r, g1):+.6e}   SkewCov = {skew_cov(p, r, g1):+.6e}")
    print(f"hardened2 f : Cov = {cov(p, r, g2):+.6e}   SkewCov = {skew_cov(p, r, g2):+.6e}")
    print(f"\n{'beta':>8} {'|G| raw':>14} {'|G| Cov=0':>14} {'|G| both=0':>14}   observed decay exponents")
    prev = None
    for beta in (4.0, 8.0, 16.0, 32.0, 64.0, 128.0):
        a = abs(audit_gap(beta, r, p, f))
        b = abs(audit_gap(beta, r, p, g1))
        d = abs(audit_gap(beta, r, p, g2))
        line = f"{beta:8.0f} {a:14.6e} {b:14.6e} {d:14.6e}"
        if prev is not None:
            expo = tuple(
                -math.log(new / old) / math.log(2.0) if old > 0 and new > 0 else float("nan")
                for old, new in zip(prev, (a, b, d))
            )
            line += "   " + "  ".join(f"{e:5.2f}" for e in expo)
        prev = (a, b, d)
        print(line)
    print("\nExponents converge to 1 (raw), 2 (reward-orthogonal), 3 (also skew-orthogonal).")


def demo_sharp_threshold() -> None:
    rule("5.  Sharp threshold:  eps * beta_c(eps) -> |Cov_p(r,f)|")
    reward_bound = 1.0
    p, r, f = random_model(8, reward_bound)
    c = abs(cov(p, r, f))
    print(f"|Cov_p(r,f)| = {c:.10f}\n")
    print(f"{'eps':>12} {'beta_c(eps)':>16} {'eps*beta_c':>16} {'rel. error':>12}")
    for eps in (1e-1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6):
        bc = beta_critical(eps, reward_bound, r, p, f)
        print(f"{eps:12.0e} {bc:16.4f} {eps * bc:16.10f} {abs(eps * bc - c) / c:12.3e}")
    print("\nThe critical KL penalty is (1+o(1)) |Cov| / eps: halving the auditor's")
    print("tolerance exactly doubles the regularization needed to stay safe.")


def demo_second_order() -> None:
    rule("6.  Second order: the coefficient is the skew covariance")
    reward_bound = 1.0
    p, r, f = random_model(8, reward_bound)
    c, sk, s = cov(p, r, f), skew_cov(p, r, f), stdev(p, f)
    print(f"Cov = {c:.8f}   SkewCov = {sk:.8f}   sigma(f) = {s:.8f}\n")
    print(f"{'beta':>8} {'beta^2 (G - Cov/beta)':>24} {'SkewCov/2':>14} {'|err|':>12} {'bound':>12}")
    for beta in (2.0, 4.0, 8.0, 16.0, 64.0, 256.0, 1024.0):
        g = audit_gap(beta, r, p, f)
        lhs = beta**2 * (g - c / beta)
        err = abs(g - c / beta - sk / (2 * beta**2))
        bound = 40.0 * (reward_bound / beta) ** 3 * s
        print(f"{beta:8.0f} {lhs:24.10f} {sk / 2:14.8f} {err:12.3e} {bound:12.3e}")


def demo_two_point_models() -> None:
    rule("7.  Two-point models: closed forms, and optimality of the exponent 2")
    reward_bound = 0.7
    p, r, f = symmetric_two_point(reward_bound)
    print("(a) Symmetric model p = (1/2, 1/2), r = (+R,-R), f = (+1,-1), R = 0.7")
    print(f"    Cov = {cov(p, r, f):.10f}  (theory: R = {reward_bound})")
    print(f"    SkewCov = {skew_cov(p, r, f):.3e}  (theory: 0, by symmetry)\n")
    print(f"    {'beta':>8} {'G(beta)':>16} {'tanh(R/beta)':>16} {'difference':>12}")
    for beta in (0.7, 1.0, 3.0, 10.0):
        g = audit_gap(beta, r, p, f)
        t = math.tanh(reward_bound / beta)
        print(f"    {beta:8.2f} {g:16.12f} {t:16.12f} {abs(g - t):12.2e}")
    print("\n    Closed-form threshold: beta_c(eps) = R / artanh(eps).")
    print(f"    {'eps':>10} {'bisection beta_c':>18} {'R/artanh(eps)':>16}")
    for eps in (1e-2, 1e-3, 1e-4):
        bc = beta_critical(eps, reward_bound, r, p, f)
        exact = reward_bound / math.atanh(eps)
        print(f"    {eps:10.0e} {bc:18.6f} {exact:16.6f}")

    print("\n(b) Biased model p = (q, 1-q):  SkewCov = 8 R^2 q (1-q)(1-2q) != 0 for q != 1/2")
    print(f"    {'q':>6} {'Cov':>14} {'4Rq(1-q)':>14} {'SkewCov':>16} {'8R^2q(1-q)(1-2q)':>18}")
    for q in (0.1, 0.25, 0.5, 0.75, 0.9):
        pq, rq, fq = biased_two_point(q, reward_bound)
        theory_c = 4 * reward_bound * q * (1 - q)
        theory_s = 8 * reward_bound**2 * q * (1 - q) * (1 - 2 * q)
        print(
            f"    {q:6.2f} {cov(pq, rq, fq):14.8f} {theory_c:14.8f}"
            f" {skew_cov(pq, rq, fq):16.8f} {theory_s:18.8f}"
        )

    q = 0.2
    pq, rq, fq = biased_two_point(q, reward_bound)
    cq = cov(pq, rq, fq)
    limit = 4 * reward_bound**2 * q * (1 - q) * (1 - 2 * q)
    print(f"\n    Rescaled first-order remainder for q = {q} (limit should be {limit:.8f}):")
    print(f"    {'beta':>8} {'beta^2 (G - Cov/beta)':>24}")
    for beta in (2.0, 8.0, 32.0, 128.0, 512.0, 2048.0):
        print(f"    {beta:8.0f} {beta**2 * (audit_gap(beta, rq, pq, fq) - cq / beta):24.10f}")
    print("\n    The limit is nonzero: the beta^-2 remainder of the first-order law is real,")
    print("    so the exponent 2 cannot be improved to any o(beta^-2).")


def demo_penalty_budget() -> None:
    rule("8.  Application: choosing the KL penalty from base-model correlations alone")
    reward_bound = 1.0
    p, r, _ = random_model(12, reward_bound, seed=7)
    rng = random.Random(11)
    battery: List[Tuple[str, List[float]]] = []
    for k in range(4):
        battery.append((f"metric_{k}", [rng.uniform(-2.0, 2.0) for _ in p]))
    battery.append(("aligned", list(r)))
    battery.append(("hardened", orthogonalize(p, r, [rng.uniform(-2.0, 2.0) for _ in p])))

    eps = 1e-3
    print(f"auditor tolerance eps = {eps}\n")
    print(f"{'statistic':>12} {'Cov(r,f)':>14} {'predicted beta_c':>18} {'measured beta_c':>17}")
    for name, stat in battery:
        c = abs(cov(p, r, stat))
        pred = c / eps
        meas = beta_critical(eps, reward_bound, r, p, stat) if c > 1e-12 else float("nan")
        print(f"{name:>12} {c:14.8f} {pred:18.4f} {meas:17.4f}")
    print("\nThe required KL penalty is beta >= max_f |Cov(r,f)| / eps — a number computable")
    print("from base-model samples before any fine-tuning is performed.")


def main() -> None:
    print(__doc__)
    demo_exact_identity()
    demo_first_order_law()
    demo_exact_rate()
    demo_safety()
    demo_sharp_threshold()
    demo_second_order()
    demo_two_point_models()
    demo_penalty_budget()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
