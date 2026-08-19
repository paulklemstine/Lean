"""
The Arithmetic of Alignment -- numerical demonstrations.

Self-contained (Python standard library only).  Every routine below illustrates
one of the theorems of the accompanying paper:

  1. Gibbs variational principle:  J(q) <= beta*log Z, equality at the Gibbs policy.
  2. Curvature identity:           d^2/dt^2 log Z(t) = Var_{pi_t}(r).
  3. Speed limit:                  Var <= (M-m)^2/4, sharp for a balanced binary reward.
  4. Variance-flow identity:       integral of the variance = drift of the mean reward.
  5. Schedule collapse:            an arbitrary schedule equals one rescaled step.
  6. Reward identifiability:       rewards differing by a constant align identically.
  7. Euler product:                the zeta policy factorizes; exponents are independent.
  8. Divisibility statistics:      P(p does not divide) -> 1 - p^{-s}.
  9. Prime discovery:              beta*log N <= log 2  ==>  prime-power mass >= 1/2.
 10. Spectral rigidity (sampled):  n known levels are recovered from n arbitrary probes.
 11. Prony counterexample:         three probes do not determine two unknown atoms.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from itertools import product
from typing import List, Sequence, Tuple

Vector = List[float]

# ----------------------------------------------------------------------------
# Core alignment primitives
# ----------------------------------------------------------------------------


def partition(reward: Sequence[float], ref: Sequence[float], beta: float) -> float:
    """Z(beta) = sum_y p(y) exp(r(y)/beta), computed with a max-shift for stability."""
    t = 1.0 / beta
    top = max(r * t for r in reward)
    acc = sum(p * math.exp(r * t - top) for r, p in zip(reward, ref))
    return math.exp(top) * acc


def free_energy(reward: Sequence[float], ref: Sequence[float], beta: float) -> float:
    """V(beta) = beta * log Z(beta), evaluated by log-sum-exp to avoid overflow."""
    return beta * log_partition_t(reward, ref, 1.0 / beta)


def gibbs_policy(reward: Sequence[float], ref: Sequence[float], beta: float) -> Vector:
    """pi_beta(y) proportional to p(y) exp(r(y)/beta)."""
    t = 1.0 / beta
    top = max(r * t for r in reward)
    w = [p * math.exp(r * t - top) for r, p in zip(reward, ref)]
    s = sum(w)
    return [x / s for x in w]


def kl(q: Sequence[float], g: Sequence[float]) -> float:
    """Kullback-Leibler divergence KL(q || g), with the convention 0*log0 = 0."""
    return sum(qi * math.log(qi / gi) for qi, gi in zip(q, g) if qi > 0.0)


def objective(
    reward: Sequence[float], ref: Sequence[float], beta: float, q: Sequence[float]
) -> float:
    """J_0(q) = E_q[r] - beta * KL(q || p)."""
    return sum(qi * r for qi, r in zip(q, reward)) - beta * kl(q, ref)


def tilt_mean(reward: Sequence[float], ref: Sequence[float], t: float) -> float:
    """E_{pi_t}[r] where pi_t(y) proportional to p(y) exp(r(y) t)."""
    pi = gibbs_policy(reward, ref, 1.0 / t) if t != 0.0 else list(ref)
    return sum(pi_i * r for pi_i, r in zip(pi, reward))


def tilt_var(reward: Sequence[float], ref: Sequence[float], t: float) -> float:
    """Var_{pi_t}(r)."""
    pi = gibbs_policy(reward, ref, 1.0 / t) if t != 0.0 else list(ref)
    mu = sum(pi_i * r for pi_i, r in zip(pi, reward))
    return sum(pi_i * (r - mu) ** 2 for pi_i, r in zip(pi, reward))


def log_partition_t(reward: Sequence[float], ref: Sequence[float], t: float) -> float:
    """log Z(t) in the inverse-temperature variable t = 1/beta."""
    top = max(r * t for r in reward)
    return top + math.log(sum(p * math.exp(r * t - top) for r, p in zip(reward, ref)))


# ----------------------------------------------------------------------------
# Arithmetic ingredients
# ----------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def von_mangoldt(n: int) -> float:
    """Lambda(n) = log p if n = p^k for a prime p, else 0."""
    if n < 2:
        return 0.0
    m, d = n, 2
    while d * d <= m:
        if m % d == 0:
            while m % d == 0:
                m //= d
            return math.log(d) if m == 1 else 0.0
        d += 1
    return math.log(n)


def is_prime_power(n: int) -> bool:
    return von_mangoldt(n) > 0.0


def local_zeta(s: float, p: int, cap: int) -> float:
    """The truncated Euler factor sum_{j<=cap} p^{-js}."""
    return sum(float(p) ** (-j * s) for j in range(cap + 1))


# ----------------------------------------------------------------------------
# Small dense linear algebra (Gaussian elimination with partial pivoting)
# ----------------------------------------------------------------------------


def solve_linear(matrix: List[Vector], rhs: Vector) -> Vector:
    """Solve A x = b for a square matrix A given as a list of rows."""
    n = len(rhs)
    a = [row[:] + [rhs[i]] for i, row in enumerate(matrix)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(a[r][col]))
        if abs(a[pivot][col]) < 1e-14:
            raise ValueError("singular system")
        a[col], a[pivot] = a[pivot], a[col]
        piv = a[col][col]
        for r in range(n):
            if r == col:
                continue
            factor = a[r][col] / piv
            for c in range(col, n + 1):
                a[r][c] -= factor * a[col][c]
    return [a[i][n] / a[i][i] for i in range(n)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_variational_principle() -> None:
    print("=" * 74)
    print("1. GIBBS VARIATIONAL PRINCIPLE:  J(q) <= beta log Z, equality at pi_beta")
    print("=" * 74)
    reward = [0.0, 1.0, 2.5, -0.5, 3.0]
    ref = [0.30, 0.25, 0.20, 0.15, 0.10]
    beta = 0.7
    v = free_energy(reward, ref, beta)
    pi = gibbs_policy(reward, ref, beta)
    print(f"  free energy V(beta)                 = {v:.10f}")
    print(f"  objective at the aligned policy     = {objective(reward, ref, beta, pi):.10f}")
    print(f"  objective at the reference policy   = {objective(reward, ref, beta, list(ref)):.10f}")
    perturbed = [0.10, 0.20, 0.30, 0.25, 0.15]
    print(f"  objective at an arbitrary policy    = "
          f"{objective(reward, ref, beta, perturbed):.10f}")
    gap = v - objective(reward, ref, beta, perturbed)
    print(f"  gap = beta * KL(q || pi_beta)       = {beta * kl(perturbed, pi):.10f}"
          f"   (observed {gap:.10f})")
    print(f"  reference mean reward E_p[r]        = {sum(p*r for p,r in zip(ref,reward)):.10f}")
    print(f"  reward ceiling max r                = {max(reward):.10f}")
    print()


def demo_curvature_is_variance() -> None:
    print("=" * 74)
    print("2. CURVATURE IDENTITY:  d^2/dt^2 log Z(t) = Var_{pi_t}(r)")
    print("=" * 74)
    reward = [0.0, 1.0, 2.5, -0.5, 3.0]
    ref = [0.30, 0.25, 0.20, 0.15, 0.10]
    h = 1e-4
    print(f"  {'t':>7} {'numeric d2/dt2 log Z':>24} {'Var_{pi_t}(r)':>20} {'abs err':>12}")
    for t in (-2.0, -0.5, 0.0, 0.5, 1.5, 3.0):
        second = (
            log_partition_t(reward, ref, t + h)
            - 2.0 * log_partition_t(reward, ref, t)
            + log_partition_t(reward, ref, t - h)
        ) / (h * h)
        var = tilt_var(reward, ref, t)
        print(f"  {t:7.2f} {second:24.10f} {var:20.10f} {abs(second-var):12.2e}")
    print()


def demo_speed_limit() -> None:
    print("=" * 74)
    print("3. SPEED LIMIT:  Var <= (M-m)^2/4, attained by the balanced binary reward")
    print("=" * 74)
    reward = [0.0, 1.0]
    ref = [0.5, 0.5]
    print("  balanced binary reward r in {0,1}:  Var_{pi_t}(r) = e^t/(1+e^t)^2")
    for t in (-2.0, -1.0, 0.0, 1.0, 2.0):
        closed = math.exp(t) / (1.0 + math.exp(t)) ** 2
        print(f"    t = {t:5.2f}   computed = {tilt_var(reward, ref, t):.10f}"
              f"   closed form = {closed:.10f}")
    print(f"  maximum over t is {tilt_var(reward, ref, 0.0):.10f} = 1/4 at t = 0.")
    reward2 = [0.0, 0.4, 1.0, 0.8, 0.2]
    ref2 = [0.2] * 5
    worst = max(tilt_var(reward2, ref2, t / 10.0) for t in range(-200, 201))
    print(f"  a five-response reward in [0,1]: sup_t Var = {worst:.10f} <= 0.25")
    print()


def demo_variance_flow() -> None:
    print("=" * 74)
    print("4. VARIANCE FLOW:  int_{t1}^{t2} Var dt = E_{pi_{t2}}[r] - E_{pi_{t1}}[r]")
    print("=" * 74)
    reward = [0.0, 1.0, 2.5, -0.5, 3.0]
    ref = [0.30, 0.25, 0.20, 0.15, 0.10]
    t1, t2, steps = -1.0, 2.0, 200000
    dt = (t2 - t1) / steps
    integral = sum(tilt_var(reward, ref, t1 + (k + 0.5) * dt) for k in range(steps)) * dt
    drift = tilt_mean(reward, ref, t2) - tilt_mean(reward, ref, t1)
    print(f"  integrated variance over [{t1}, {t2}] = {integral:.8f}")
    print(f"  drift of the aligned mean reward     = {drift:.8f}")
    print(f"  absolute difference                  = {abs(integral - drift):.2e}")
    print()


def demo_schedule_collapse() -> None:
    print("=" * 74)
    print("5. SCHEDULE COLLAPSE:  a multi-step schedule equals a single rescaled step")
    print("=" * 74)
    ref = [0.30, 0.25, 0.20, 0.15, 0.10]
    schedule: List[Tuple[float, Vector]] = [
        (0.5, [1.0, 0.0, -1.0, 2.0, 0.5]),
        (1.3, [0.0, 2.0, 1.0, -1.0, 0.0]),
        (0.2, [-0.5, 0.5, 0.0, 1.0, 3.0]),
    ]
    policy = list(ref)
    for b, r in schedule:
        policy = gibbs_policy(r, policy, b)
    beta = 0.9
    merged = [sum((beta / b) * r[i] for b, r in schedule) for i in range(len(ref))]
    collapsed = gibbs_policy(merged, ref, beta)
    print(f"  schedule temperatures     : {[b for b, _ in schedule]}")
    print(f"  compiled single-step beta : {beta}")
    print(f"  three-step policy   : {[round(x, 10) for x in policy]}")
    print(f"  one-step equivalent : {[round(x, 10) for x in collapsed]}")
    print(f"  max deviation       : {max(abs(a-b) for a, b in zip(policy, collapsed)):.2e}")
    print()


def demo_identifiability() -> None:
    print("=" * 74)
    print("6. IDENTIFIABILITY:  rewards are recoverable exactly up to an additive constant")
    print("=" * 74)
    ref = [0.30, 0.25, 0.20, 0.15, 0.10]
    beta = 0.6
    r1 = [0.0, 1.0, 2.5, -0.5, 3.0]
    shift = 4.2
    r2 = [r + shift for r in r1]
    p1, p2 = gibbs_policy(r1, ref, beta), gibbs_policy(r2, ref, beta)
    print(f"  max |pi(r) - pi(r + {shift})|  = {max(abs(a-b) for a,b in zip(p1,p2)):.2e}")
    implicit = [beta * math.log(q / p) for q, p in zip(p1, ref)]
    diff = [a - b for a, b in zip(implicit, r1)]
    print(f"  implicit reward beta*log(pi/p) minus r : "
          f"{[round(d, 8) for d in diff]}  (constant, as predicted)")
    print()


def demo_euler_product() -> None:
    print("=" * 74)
    print("7. EULER PRODUCT:  the aligned zeta policy factorizes over the primes")
    print("=" * 74)
    primes = [2, 3, 5]
    caps = [4, 3, 2]
    s = 1.4
    space = list(product(*[range(c + 1) for c in caps]))
    values = [math.prod(p**a for p, a in zip(primes, exps)) for exps in space]
    total = sum(float(n) ** (-s) for n in values)
    prod_local = math.prod(local_zeta(s, p, c) for p, c in zip(primes, caps))
    print(f"  primes {primes}, exponent caps {caps}, sharpness s = {s}")
    print(f"  sum over the response space of n^-s : {total:.12f}")
    print(f"  product of the local Euler factors  : {prod_local:.12f}")
    print(f"  difference                          : {abs(total - prod_local):.2e}")
    worst = 0.0
    for exps in space:
        joint = (math.prod(p**a for p, a in zip(primes, exps))) ** (-s) / total
        marginals = math.prod(
            float(p) ** (-a * s) / local_zeta(s, p, c)
            for p, a, c in zip(primes, exps, caps)
        )
        worst = max(worst, abs(joint - marginals))
    print(f"  max |joint - product of marginals|  : {worst:.2e}   (exponents independent)")
    euler = -sum(math.log(1.0 - float(p) ** (-s)) for p in primes)
    trunc = sum(math.log(local_zeta(s, p, c)) for p, c in zip(primes, caps))
    print(f"  truncated log-value {trunc:.10f} < Mertens ceiling {euler:.10f}")
    print()


def demo_divisibility() -> None:
    print("=" * 74)
    print("8. DIVISIBILITY STATISTICS:  P(p does not divide) -> 1 - p^-s")
    print("=" * 74)
    s, p = 1.3, 3
    print(f"  p = {p}, s = {s}, classical density 1 - p^-s = "
          f"{1.0 - float(p)**(-s):.10f}")
    for cap in (1, 2, 4, 8, 16, 40):
        prob = 1.0 / local_zeta(s, p, cap)
        print(f"    exponent cap A = {cap:3d}   P(p does not divide) = {prob:.10f}")
    print()


def demo_prime_discovery(N: int = 1000) -> None:
    print("=" * 74)
    print("9. PRIME DISCOVERY:  beta log N <= log 2  ==>  prime-power mass >= 1/2")
    print("=" * 74)
    lam = [von_mangoldt(n) for n in range(1, N + 1)]
    ref = [1.0 / N] * N
    pp = [i for i in range(N) if is_prime_power(i + 1)]
    threshold = math.log(2.0) / math.log(N)
    print(f"  N = {N};   threshold beta* = log 2 / log N = {threshold:.8f}")
    print(f"  prime powers up to N: {len(pp)} of {N} responses "
          f"({100.0*len(pp)/N:.2f}% of the space)")
    print(f"  {'beta':>12} {'prime-power mass':>20} {'>= 1/2?':>10}")
    for beta in (50.0, 10.0, 2.0, 0.5, threshold * 2, threshold, threshold / 2):
        pi = gibbs_policy(lam, ref, beta)
        mass = sum(pi[i] for i in pp)
        flag = "yes" if mass >= 0.5 else "no"
        star = "  <- threshold" if abs(beta - threshold) < 1e-12 else ""
        print(f"  {beta:12.8f} {mass:20.10f} {flag:>10}{star}")
    psi = sum(lam)
    biggest = max(p for p in primes_up_to(N))
    print(f"  value squeeze:  psi(N)/N = {psi/N:.8f}  <=  V(beta)  <=  log N = "
          f"{math.log(N):.8f}")
    print(f"  V(2.0) = {free_energy(lam, ref, 2.0):.8f},  "
          f"V(0.001) = {free_energy(lam, ref, 0.001):.8f}")
    print(f"  zero-temperature limit predicted: log(largest prime <= N) = "
          f"log {biggest} = {math.log(biggest):.8f}")
    print("  monotonicity check (prime-power mass must be nonincreasing in beta):")
    betas = [2.0, 1.0, 0.5, 0.25, 0.1, 0.05, 0.02]
    masses = [sum(gibbs_policy(lam, ref, b)[i] for i in pp) for b in betas]
    ok = all(masses[k] <= masses[k + 1] + 1e-12 for k in range(len(masses) - 1))
    print(f"    masses = {[round(m, 6) for m in masses]}   monotone: {ok}")
    print()


def demo_spectral_rigidity() -> None:
    print("=" * 74)
    print("10. SAMPLED SPECTRAL RIGIDITY:  n known levels from n arbitrary probes")
    print("=" * 74)
    levels = [-1.0, 0.0, 0.75, 2.0]
    masses = [0.15, 0.35, 0.30, 0.20]
    n = len(levels)

    def z_of(t: float) -> float:
        return sum(m * math.exp(v * t) for v, m in zip(levels, masses))

    for name, probes in (
        ("arithmetic grid", [0.0, 0.5, 1.0, 1.5]),
        ("arbitrary probes", [-1.7, 0.13, 0.9, 3.4]),
        ("clustered probes", [0.10, 0.11, 0.12, 0.13]),
    ):
        matrix = [[math.exp(v * t) for v in levels] for t in probes]
        rhs = [z_of(t) for t in probes]
        recovered = solve_linear(matrix, rhs)
        err = max(abs(a - b) for a, b in zip(recovered, masses))
        print(f"  {name:18s} probes = {probes}")
        print(f"  {'':18s} recovered masses = {[round(x, 8) for x in recovered]}")
        print(f"  {'':18s} max error = {err:.2e}")
    print("  (invertible for every choice of distinct probes; clustering only")
    print("   degrades conditioning, never solvability)")
    print()


def demo_prony_counterexample() -> None:
    print("=" * 74)
    print("11. THREE PROBES DO NOT DETERMINE TWO UNKNOWN ATOMS")
    print("=" * 74)
    support_a, mass_a = [3.0, 1.0], [0.5, 0.5]
    support_b, mass_b = [4.0, 1.5], [0.2, 0.8]

    def z(support: Sequence[float], mass: Sequence[float], t: float) -> float:
        return sum(m * x**t for m, x in zip(mass, support))

    print("  model A: reward levels {log 3, log 1 = 0} with masses (1/2, 1/2)")
    print("  model B: reward levels {log 4, log 3/2} with masses (1/5, 4/5)")
    print(f"  {'t':>4} {'Z_A(t)':>18} {'Z_B(t)':>18} {'difference':>14}")
    for t in (0.0, 1.0, 2.0):
        za, zb = z(support_a, mass_a, t), z(support_b, mass_b, t)
        print(f"  {t:4.1f} {za:18.12f} {zb:18.12f} {abs(za-zb):14.2e}")
    print("  the two spectra nonetheless differ: mass at level log 3 is 0.5 vs 0.0")
    for t in (0.5, 3.0):
        za, zb = z(support_a, mass_a, t), z(support_b, mass_b, t)
        print(f"  a fourth probe separates them: t = {t}: "
              f"Z_A = {za:.8f}, Z_B = {zb:.8f}, gap = {abs(za-zb):.6f}")
    print()


def main() -> None:
    demo_variational_principle()
    demo_curvature_is_variance()
    demo_speed_limit()
    demo_variance_flow()
    demo_schedule_collapse()
    demo_identifiability()
    demo_euler_product()
    demo_divisibility()
    demo_prime_discovery()
    demo_spectral_rigidity()
    demo_prony_counterexample()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
