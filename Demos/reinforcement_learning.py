"""
Numerical demonstrations for the alignment-torsor / Legendre-duality theory of the
KL-regularized alignment objective with a pretraining mix-in.

Setting
-------
Finite response space Omega = {0, ..., n-1}.

    J_gamma(q) = sum_y q[y] r[y]  -  beta * KL(q || p)  +  gamma * sum_y d[y] log q[y]

with p a strictly positive reference policy, r a reward model, d a pretraining
distribution, beta > 0 the KL temperature, gamma >= 0 the mix-in coefficient.

Everything below is pure Python + NumPy, self-contained, with type hints.

Demonstrated results
--------------------
1.  Gibbs policy pi_r(y) ∝ p(y) exp(r(y)/beta) maximizes J_0, with optimal value
    the free energy F(r) = beta log sum_y p(y) exp(r(y)/beta).
2.  Torsor structure: tilting composes additively; the implicit reward
    beta log(q/p) inverts tilting; two rewards give the same policy iff they
    differ by a constant.
3.  Bregman identity  F(s) - F(r) - E_{pi_r}[s - r] = beta KL(pi_r || pi_s).
4.  Legendre duality: F(r) = max_q (E_q[r] - beta KL(q||p)) and
    beta KL(q||p) = max_r (E_q[r] - F(r)), the latter attained at the implicit reward.
5.  Sharpness of the reward-hacking budget: |F(r)-F(s)| -> K as beta -> 0 on a
    two-response space; and failure of the reference-weighted L^2(p) bound.
6.  Mix-in optimum: computed by the self-consistent tilting iteration
    q = pi_{r + gamma d / q}; verified against projected ascent and against the
    score-constancy certificate.
7.  Anti-starvation floor, Pythagorean drift bound, comparative statics in gamma,
    and the two-sided KL stability band under reward perturbation.
"""

from __future__ import annotations

from typing import Callable, Tuple

import numpy as np

Array = np.ndarray

# --------------------------------------------------------------------------- #
# Core quantities
# --------------------------------------------------------------------------- #


def kl(q: Array, p: Array) -> float:
    """Kullback-Leibler divergence KL(q || p) for strictly positive p."""
    mask = q > 0.0
    return float(np.sum(q[mask] * np.log(q[mask] / p[mask])))


def free_energy(beta: float, r: Array, p: Array) -> float:
    """F(r) = beta * log sum_y p(y) exp(r(y)/beta), computed stably."""
    z = np.log(p) + r / beta
    m = float(np.max(z))
    return float(beta * (m + np.log(np.sum(np.exp(z - m)))))


def gibbs_policy(beta: float, r: Array, p: Array) -> Array:
    """pi_r(y) = p(y) exp(r(y)/beta) / Z, computed stably."""
    z = np.log(p) + r / beta
    z -= float(np.max(z))
    w = np.exp(z)
    return w / float(np.sum(w))


def implicit_reward(beta: float, p: Array, q: Array) -> Array:
    """The implicit reward beta * log(q / p): the inverse of exponential tilting."""
    return beta * np.log(q / p)


def objective_rlhf(beta: float, r: Array, p: Array, q: Array) -> float:
    """J_0(q) = E_q[r] - beta KL(q || p)."""
    return float(np.dot(q, r) - beta * kl(q, p))


def objective_ptx(
    beta: float, gamma: float, r: Array, p: Array, d: Array, q: Array
) -> float:
    """J_gamma(q) = E_q[r] - beta KL(q||p) + gamma sum_y d(y) log q(y)."""
    return objective_rlhf(beta, r, p, q) + gamma * float(np.dot(d, np.log(q)))


def ptx_score(
    beta: float, gamma: float, r: Array, p: Array, d: Array, q: Array
) -> Array:
    """Coordinatewise score S_q(y) = r - beta(log(q/p) + 1) + gamma d/q."""
    return r - beta * (np.log(q / p) + 1.0) + gamma * d / q


# --------------------------------------------------------------------------- #
# Algorithms
# --------------------------------------------------------------------------- #


def ptx_optimum_fixed_point(
    beta: float,
    gamma: float,
    r: Array,
    p: Array,
    d: Array,
    damping: float = 0.1,
    iters: int = 200000,
    tol: float = 1e-15,
) -> Array:
    """Self-consistent tilting: q <- (1-l) q + l * pi_{r + gamma d / q}.

    The fixed points of this map are exactly the optima, but the undamped map is
    not a contraction in general; heavy damping is needed, and convergence should
    always be certified by the score-constancy test.  For a solver with a
    guaranteed bracket, use `ptx_optimum_dual_bisection`.
    """
    q = gibbs_policy(beta, r, p)
    for _ in range(iters):
        q_new = gibbs_policy(beta, r + gamma * d / q, p)
        q_next = (1.0 - damping) * q + damping * q_new
        if float(np.max(np.abs(q_next - q))) < tol:
            return q_next
        q = q_next
    return q


def _coord_from_score(
    beta: float, gamma: float, r_y: float, p_y: float, d_y: float, c: float
) -> float:
    """Solve  r_y - beta(log(t/p_y)+1) + gamma d_y/t = c  for t > 0.

    The left-hand side is strictly decreasing in t (both -beta log t and
    gamma d_y / t are), so the root is unique and bisection on log t converges.
    """

    def f(log_t: float) -> float:
        t = np.exp(log_t)
        return r_y - beta * (log_t - np.log(p_y) + 1.0) + gamma * d_y / t - c

    lo, hi = -700.0, 50.0
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if f(mid) > 0.0:
            lo = mid
        else:
            hi = mid
    return float(np.exp(0.5 * (lo + hi)))


def ptx_optimum_dual_bisection(
    beta: float, gamma: float, r: Array, p: Array, d: Array
) -> Array:
    """Certified solver for the mix-in optimum.

    By the stationarity characterization, the optimum is the unique positive
    policy whose coordinatewise score is constant.  For a trial value c of that
    constant each coordinate is determined uniquely and is decreasing in c, so the
    total mass is strictly decreasing in c; bisect on c until the mass equals 1.
    Cost O(|Omega| * iterations), with each iteration a bracketed bisection.
    """

    def mass(c: float) -> float:
        return float(
            sum(
                _coord_from_score(beta, gamma, float(r[y]), float(p[y]), float(d[y]), c)
                for y in range(p.size)
            )
        )

    lo, hi = -1.0e6, 1.0e6
    for _ in range(300):
        mid = 0.5 * (lo + hi)
        if mass(mid) > 1.0:
            lo = mid
        else:
            hi = mid
    c = 0.5 * (lo + hi)
    q = np.array(
        [
            _coord_from_score(beta, gamma, float(r[y]), float(p[y]), float(d[y]), c)
            for y in range(p.size)
        ]
    )
    return q / float(np.sum(q))


def ptx_optimum_projected_ascent(
    beta: float,
    gamma: float,
    r: Array,
    p: Array,
    d: Array,
    step: float = 1e-3,
    iters: int = 400000,
) -> Array:
    """Independent check: exponentiated-gradient ascent on the simplex interior."""
    q = np.full_like(p, 1.0 / p.size)
    for _ in range(iters):
        grad = ptx_score(beta, gamma, r, p, d, q)
        log_q = np.log(q) + step * grad
        log_q -= float(np.max(log_q))
        q = np.exp(log_q)
        q /= float(np.sum(q))
    return q


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_gibbs_optimality(rng: np.random.Generator) -> None:
    banner("1.  Gibbs policy attains the free energy (variational principle)")
    n, beta = 6, 0.7
    p = rng.dirichlet(np.ones(n))
    r = rng.normal(size=n)
    pi = gibbs_policy(beta, r, p)
    f = free_energy(beta, r, p)
    print(f"  F(r)                      = {f: .10f}")
    print(f"  J_0(pi_r)                 = {objective_rlhf(beta, r, p, pi): .10f}")
    best_random = max(
        objective_rlhf(beta, r, p, rng.dirichlet(np.ones(n))) for _ in range(20000)
    )
    print(f"  best of 20000 random q    = {best_random: .10f}   (must be <= F(r))")
    print("  identity J_0(q) = F(r) - beta KL(q || pi_r):")
    for _ in range(3):
        q = rng.dirichlet(np.ones(n))
        lhs = objective_rlhf(beta, r, p, q)
        rhs = f - beta * kl(q, pi)
        print(f"    lhs = {lhs: .10f}   rhs = {rhs: .10f}   gap = {lhs - rhs: .2e}")


def demo_torsor(rng: np.random.Generator) -> None:
    banner("2.  The alignment torsor: composition, inversion, gauge")
    n, beta = 5, 1.3
    p = rng.dirichlet(np.ones(n))
    r1, r2 = rng.normal(size=n), rng.normal(size=n)

    lhs = gibbs_policy(beta, r2, gibbs_policy(beta, r1, p))
    rhs = gibbs_policy(beta, r1 + r2, p)
    print(f"  composition  ||pi_{{r2}}(pi_{{r1}}(p)) - pi_{{r1+r2}}(p)||_inf = "
          f"{np.max(np.abs(lhs - rhs)):.2e}")

    q = rng.dirichlet(np.ones(n))
    rho = implicit_reward(beta, p, q)
    print(f"  inversion    ||pi_{{beta log(q/p)}} - q||_inf              = "
          f"{np.max(np.abs(gibbs_policy(beta, rho, p) - q)):.2e}")

    c = 2.71
    print(f"  gauge        ||pi_{{r+c}} - pi_r||_inf                     = "
          f"{np.max(np.abs(gibbs_policy(beta, r1 + c, p) - gibbs_policy(beta, r1, p))):.2e}")
    print(f"  gauge        F(r+c) - F(r) - c                        = "
          f"{free_energy(beta, r1 + c, p) - free_energy(beta, r1, p) - c:.2e}")

    # simple transitivity: the centered reward carrying p to q is unique
    centered = rho - float(np.mean(rho))
    print(f"  centered representative sums to                       = "
          f"{float(np.sum(centered)):.2e}")


def demo_bregman_and_duality(rng: np.random.Generator) -> None:
    banner("3-4.  Bregman identity, Fenchel-Young, and both Legendre conjugates")
    n, beta = 7, 0.9
    p = rng.dirichlet(np.ones(n))
    r, s = rng.normal(size=n), rng.normal(size=n)
    pi_r, pi_s = gibbs_policy(beta, r, p), gibbs_policy(beta, s, p)

    bregman = free_energy(beta, s, p) - free_energy(beta, r, p) - float(np.dot(pi_r, s - r))
    print(f"  F(s)-F(r)-E_{{pi_r}}[s-r] = {bregman: .10f}")
    print(f"  beta * KL(pi_r || pi_s)  = {beta * kl(pi_r, pi_s): .10f}")

    q = rng.dirichlet(np.ones(n))
    gap = free_energy(beta, r, p) + beta * kl(q, p) - float(np.dot(q, r))
    print(f"\n  Fenchel-Young gap at a random q          = {gap: .10f}  (>= 0)")
    print(f"  Fenchel-Young gap at q = pi_r            = "
          f"{free_energy(beta, r, p) + beta * kl(pi_r, p) - float(np.dot(pi_r, r)): .2e}")

    # dual attainment: beta KL(q||p) = max_r (E_q[r] - F(r)), attained at beta log(q/p)
    rho = implicit_reward(beta, p, q)
    attained = float(np.dot(q, rho)) - free_energy(beta, rho, p)
    print(f"\n  beta * KL(q || p)                        = {beta * kl(q, p): .10f}")
    print(f"  E_q[rho] - F(rho)  (rho = implicit reward)= {attained: .10f}")
    best = max(
        float(np.dot(q, rr)) - free_energy(beta, rr, p)
        for rr in (rng.normal(scale=3.0, size=n) for _ in range(50000))
    )
    print(f"  best of 50000 random rewards             = {best: .10f}  (must be <=)")


def demo_reward_hacking_sharpness() -> None:
    banner("5.  The reward-hacking budget is sharp; reference weighting fails")
    p = np.array([0.5, 0.5])
    k = 1.0
    print("  Two responses, uniform reference, rewards (0,0) vs (K,0), K = 1.")
    print("   beta      |F(r)-F(s)|     lower bound K - beta log 2")
    for beta in (1.0, 0.5, 0.2, 0.05, 0.01, 0.001):
        r = np.zeros(2)
        s = np.array([k, 0.0])
        gap = abs(free_energy(beta, r, p) - free_energy(beta, s, p))
        print(f"  {beta:7.4f}   {gap: .8f}      {k - beta * np.log(2): .8f}")
    print("  -> the entire sup-norm budget K is realized as beta -> 0:")
    print("     no Lipschitz constant c < 1 can hold.")

    print("\n  Reference-weighted L2(p) distance cannot bound the value gap:")
    print("    delta        ||r-s||_{L2(p)}    |F(r)-F(s)|        ratio")
    for delta in (1e-1, 1e-2, 1e-4, 1e-6, 1e-8):
        p_b = np.array([delta, 1.0 - delta])
        beta = 1.0 / (2.0 * np.log(1.0 / delta) + 2.0)
        r = np.zeros(2)
        s = np.array([1.0, 0.0])
        weighted = float(np.sqrt(np.sum(p_b * (r - s) ** 2)))
        gap = abs(free_energy(beta, r, p_b) - free_energy(beta, s, p_b))
        print(f"   {delta:8.1e}     {weighted:.8f}        {gap:.8f}     {gap / weighted:12.2f}")
    print("  -> the ratio diverges: no constant C works.")


def demo_ptx_optimum(rng: np.random.Generator) -> None:
    banner("6.  The mix-in optimum: certified solver, fixed point, cross-check")
    n, beta, gamma = 5, 0.6, 0.35
    p = rng.dirichlet(np.ones(n))
    d = rng.dirichlet(np.ones(n))
    r = rng.normal(size=n)

    q_fp = ptx_optimum_dual_bisection(beta, gamma, r, p, d)
    q_it = ptx_optimum_fixed_point(beta, gamma, r, p, d)
    q_pa = ptx_optimum_projected_ascent(beta, gamma, r, p, d)
    score = ptx_score(beta, gamma, r, p, d, q_fp)

    print(f"  dual bisection        q* = {np.array2string(q_fp, precision=6)}")
    print(f"  damped tilting        q  = {np.array2string(q_it, precision=6)}")
    print(f"  projected ascent      q  = {np.array2string(q_pa, precision=6)}")
    print(f"  ||q_bis - q_iter||_inf                   = {np.max(np.abs(q_fp - q_it)):.2e}")
    print(f"  ||q_bis - q_ascent||_inf                 = {np.max(np.abs(q_fp - q_pa)):.2e}")
    print(f"  score spread max S - min S (certificate) = "
          f"{float(np.max(score) - np.min(score)):.2e}")
    print(f"  J_gamma(q*)                              = "
          f"{objective_ptx(beta, gamma, r, p, d, q_fp): .10f}")
    best_random = max(
        objective_ptx(beta, gamma, r, p, d, rng.dirichlet(np.ones(n)))
        for _ in range(50000)
    )
    print(f"  best of 50000 random policies            = {best_random: .10f}")

    print("\n  self-consistent Gibbs equation q = pi_{r + gamma d / q}:")
    resid = np.max(np.abs(q_fp - gibbs_policy(beta, r + gamma * d / q_fp, p)))
    print(f"    ||q* - pi_{{r + gamma d/q*}}||_inf         = {resid:.2e}")

    print("\n  anti-starvation floor  q(y) >= gamma d(y)/(beta log(1/p) + M + gamma - r):")
    m = float(np.max(r))
    floor = gamma * d / (beta * np.log(1.0 / p) + m + gamma - r)
    for y in range(n):
        ok = "ok" if q_fp[y] >= floor[y] - 1e-12 else "VIOLATED"
        print(f"    y={y}:  q*={q_fp[y]:.6f}   floor={floor[y]:.6f}   {ok}")


def demo_drift_and_comparative_statics(rng: np.random.Generator) -> None:
    banner("7.  Pythagorean drift, comparative statics, and the stability band")
    n, beta = 5, 0.6
    p = rng.dirichlet(np.ones(n))
    d = rng.dirichlet(np.ones(n))
    r = rng.normal(size=n)
    pi = gibbs_policy(beta, r, p)

    print("   gamma    KL(q*||pi)   Pythag. LHS   Pythag. RHS   linear bound   "
          "ptx fit      J_0(q*)")
    prev_fit, prev_rlhf = -np.inf, np.inf
    for gamma in (0.02, 0.05, 0.1, 0.25, 0.5, 1.0, 2.0):
        q = ptx_optimum_dual_bisection(beta, gamma, r, p, d)
        lhs = beta * kl(q, pi) + gamma * kl(d, q)
        rhs = gamma * kl(d, pi)
        fit = float(np.dot(d, np.log(q)))
        rlhf = objective_rlhf(beta, r, p, q)
        assert lhs <= rhs + 1e-9, "Pythagorean inequality violated"
        assert fit >= prev_fit - 1e-9, "pretraining fit not monotone"
        assert rlhf <= prev_rlhf + 1e-9, "alignment tax not monotone"
        prev_fit, prev_rlhf = fit, rlhf
        print(f"  {gamma:6.3f}   {kl(q, pi):10.6f}   {lhs:11.6f}   {rhs:11.6f}   "
              f"{(gamma / beta) * kl(d, pi):12.6f}   {fit:9.6f}   {rlhf:9.6f}")
    print("  -> Pythagorean inequality holds; pretraining fit increases and the")
    print("     reward-minus-KL part decreases monotonically (the alignment tax).")

    print("\n  Convexity of the optimal value in gamma (envelope theorem):")
    gammas = np.linspace(0.05, 1.5, 9)
    values = [
        objective_ptx(beta, g, r, p, d, ptx_optimum_dual_bisection(beta, g, r, p, d))
        for g in gammas
    ]
    second_diffs = [
        values[i - 1] - 2.0 * values[i] + values[i + 1] for i in range(1, len(values) - 1)
    ]
    print(f"    second differences (should be >= 0): "
          f"{np.array2string(np.array(second_diffs), precision=6)}")

    print("\n  Reward-hacking immunity band  beta (KL(q1||q2)+KL(q2||q1)) <= 2K:")
    gamma = 0.3
    for k in (1.0, 0.5, 0.1, 0.01):
        s = r + k * rng.uniform(-1.0, 1.0, size=n)
        q1 = ptx_optimum_dual_bisection(beta, gamma, r, p, d)
        q2 = ptx_optimum_dual_bisection(beta, gamma, s, p, d)
        sym = beta * (kl(q1, q2) + kl(q2, q1))
        pairing = float(np.dot(q1 - q2, r - s))
        print(f"    K={k:5.2f}:  beta*symKL = {sym:.8f}  <=  pairing = {pairing:.8f} "
              f" <=  2K = {2 * k:.2f}")


def main() -> None:
    rng = np.random.default_rng(20260820)
    demo_gibbs_optimality(rng)
    demo_torsor(rng)
    demo_bregman_and_duality(rng)
    demo_reward_hacking_sharpness()
    demo_ptx_optimum(rng)
    demo_drift_and_comparative_statics(rng)
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
