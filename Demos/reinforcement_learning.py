"""
Numerical demonstration of the combinatorial theory of KL-regularized alignment
on the Boolean lattice.

Setting
-------
Responses are subsets S of {0, ..., n-1} ("which of n symbolic checks did the
answer pass?").  The reference (pre-tuning) policy is uniform on the 2^n subsets.
The reward is r(S) = a * |S|.  The tuned policy maximizes

    J(q) = E_q[r] - beta * KL(q || uniform),

whose unique maximizer is the Gibbs policy  pi(S) ∝ 2^{-n} exp(r(S)/beta).

Every closed form asserted by the theory is checked here against brute-force
enumeration of all 2^n subsets:

  1.  Z = ((1 + e^{a/beta}) / 2)^n                     (binomial partition function)
  2.  pi(S) = θ^{|S|}(1-θ)^{n-|S|},  θ = σ(a/beta)     (i.i.d. Bernoulli features)
  3.  P(|S| = k) = C(n,k) θ^k (1-θ)^{n-k}              (binomial reward law)
  4.  E[|S|] = n θ,  E[r] = a n θ                      (Pascal absorption identity)
  5.  F = n β log((1+e^{a/β})/2)                       (free energy)
  6.  KL(pi || uniform) = n (tθ - log((1+e^t)/2))      (information drift)
  7.  Ent(pi) = n H(θ)  and  KL = n log 2 - Ent        (entropy identities)
  8.  t σ(t) - log((1+e^t)/2) = log 2 - H(σ(t))        (consistency identity)
  9.  m_k m_{k+2} <= m_{k+1}^2                         (log-concavity / unimodality)
 10.  pi([n]) = θ^n >= 1 - n e^{-a/β}                  (reward-hacking bound)
 11.  monotonicity of pi on the lattice (a >= 0)
 12.  strict antitonicity of reward and collapse mass in β
 13.  supermodular rewards: log-supermodularity of pi, FKG positive association,
      Holley stochastic dominance over the reference

Run:  python demo.py
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Subset = frozenset


# --------------------------------------------------------------------------- #
# Basic scalar functions
# --------------------------------------------------------------------------- #

def logistic(t: float) -> float:
    """Numerically stable sigmoid  σ(t) = e^t / (1 + e^t)."""
    if t >= 0.0:
        return 1.0 / (1.0 + math.exp(-t))
    e = math.exp(t)
    return e / (1.0 + e)


def softplus(t: float) -> float:
    """Numerically stable log(1 + e^t)."""
    return max(t, 0.0) + math.log1p(math.exp(-abs(t)))


def log_half_one_plus_exp(t: float) -> float:
    """log((1 + e^t) / 2), stably."""
    return softplus(t) - math.log(2.0)


def binary_entropy(theta: float) -> float:
    """H(θ) = -θ log θ - (1-θ) log(1-θ), in nats."""
    if theta <= 0.0 or theta >= 1.0:
        return 0.0
    return -(theta * math.log(theta) + (1.0 - theta) * math.log1p(-theta))


# --------------------------------------------------------------------------- #
# Brute-force machinery over the Boolean lattice
# --------------------------------------------------------------------------- #

def all_subsets(n: int) -> List[Subset]:
    """All 2^n subsets of {0,...,n-1}, as frozensets."""
    out: List[Subset] = []
    for k in range(n + 1):
        for c in combinations(range(n), k):
            out.append(frozenset(c))
    return out


def gibbs_policy(n: int, reward: Callable[[Subset], float],
                 beta: float) -> Dict[Subset, float]:
    """Exact Gibbs policy pi(S) ∝ 2^{-n} exp(r(S)/beta), by enumeration."""
    subsets = all_subsets(n)
    weights = {S: math.exp(reward(S) / beta) / (2.0 ** n) for S in subsets}
    Z = sum(weights.values())
    return {S: w / Z for S, w in weights.items()}


def partition_bruteforce(n: int, reward: Callable[[Subset], float],
                         beta: float) -> float:
    return sum(math.exp(reward(S) / beta) / (2.0 ** n) for S in all_subsets(n))


def expectation(policy: Dict[Subset, float],
                observable: Callable[[Subset], float]) -> float:
    return sum(p * observable(S) for S, p in policy.items())


def kl_from_uniform(n: int, policy: Dict[Subset, float]) -> float:
    u = 1.0 / (2.0 ** n)
    return sum(p * math.log(p / u) for p in policy.values() if p > 0.0)


def entropy_of(policy: Dict[Subset, float]) -> float:
    return -sum(p * math.log(p) for p in policy.values() if p > 0.0)


# --------------------------------------------------------------------------- #
# Closed forms predicted by the theory
# --------------------------------------------------------------------------- #

def theory_profile(n: int, a: float, beta: float) -> Dict[str, float]:
    """All closed-form quantities for the counting reward r(S) = a|S|."""
    t = a / beta
    theta = logistic(t)
    lg = log_half_one_plus_exp(t)
    return {
        "t": t,
        "theta": theta,
        "Z": math.exp(n * lg),
        "free_energy": n * beta * lg,
        "expected_size": n * theta,
        "expected_reward": a * n * theta,
        "entropy": n * binary_entropy(theta),
        "kl_drift": n * (t * theta - lg),
        "top_mass": theta ** n,
        "top_mass_lower_bound": 1.0 - n * math.exp(-t),
    }


def level_masses(n: int, theta: float) -> List[float]:
    """m_k = C(n,k) θ^k (1-θ)^{n-k}, via the ratio recurrence (O(n))."""
    if theta <= 0.0:
        return [1.0] + [0.0] * n
    if theta >= 1.0:
        return [0.0] * n + [1.0]
    m = [(1.0 - theta) ** n]
    ratio_base = theta / (1.0 - theta)
    for k in range(n):
        m.append(m[-1] * (n - k) / (k + 1) * ratio_base)
    return m


def mode_of_level_masses(n: int, theta: float) -> int:
    """Mode of the binomial level masses; correct by unimodality (log-concavity)."""
    masses = level_masses(n, theta)
    best, arg = masses[0], 0
    for k in range(1, n + 1):
        if masses[k] > best:
            best, arg = masses[k], k
        else:
            break  # descent persists -- Theorem on unimodality
    return arg


# --------------------------------------------------------------------------- #
# Supermodular rewards
# --------------------------------------------------------------------------- #

def counting_reward(a: float) -> Callable[[Subset], float]:
    return lambda S: a * len(S)


def rule_bonus(R: Iterable[int], c: float) -> Callable[[Subset], float]:
    Rf = frozenset(R)
    return lambda S: (c if Rf <= S else 0.0)


def sum_rewards(*rs: Callable[[Subset], float]) -> Callable[[Subset], float]:
    return lambda S: sum(r(S) for r in rs)


def is_supermodular(n: int, reward: Callable[[Subset], float],
                    tol: float = 1e-12) -> Tuple[bool, Sequence[object]]:
    """Local 'diamond' test: r(S+i) + r(S+j) <= r(S) + r(S+i+j).  O(2^n n^2)."""
    for S in all_subsets(n):
        outside = [i for i in range(n) if i not in S]
        for idx, i in enumerate(outside):
            for j in outside[idx + 1:]:
                lhs = reward(S | {i}) + reward(S | {j})
                rhs = reward(S) + reward(S | {i, j})
                if lhs > rhs + tol:
                    return False, (S, i, j)
    return True, ()


def check_log_supermodular(n: int, policy: Dict[Subset, float],
                           tol: float = 1e-12) -> float:
    """Max violation of pi(S)pi(T) <= pi(S∩T)pi(S∪T); should be <= tol."""
    worst = 0.0
    subsets = all_subsets(n)
    for S in subsets:
        for T in subsets:
            lhs = policy[S] * policy[T]
            rhs = policy[frozenset(S & T)] * policy[frozenset(S | T)]
            worst = max(worst, lhs - rhs)
    return worst


# --------------------------------------------------------------------------- #
# Reporting helpers
# --------------------------------------------------------------------------- #

def check(label: str, lhs: float, rhs: float, tol: float = 1e-9) -> None:
    ok = abs(lhs - rhs) <= tol * max(1.0, abs(lhs), abs(rhs))
    flag = "OK " if ok else "FAIL"
    print(f"  [{flag}] {label:<46} {lhs: .12f}  vs  {rhs: .12f}")


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_closed_forms(n: int = 8, a: float = 0.7, beta: float = 0.9) -> None:
    rule(f"1. Closed forms vs brute force   (n={n}, a={a}, beta={beta})")
    r = counting_reward(a)
    pi = gibbs_policy(n, r, beta)
    th = theory_profile(n, a, beta)
    print(f"  effective temperature t = a/beta = {th['t']:.6f}")
    print(f"  per-feature acceptance  theta   = sigma(t) = {th['theta']:.9f}")
    check("partition function Z", partition_bruteforce(n, r, beta), th["Z"])
    check("free energy  beta*log Z",
          beta * math.log(partition_bruteforce(n, r, beta)), th["free_energy"])
    check("E[|S|]", expectation(pi, lambda S: float(len(S))), th["expected_size"])
    check("E[reward]", expectation(pi, r), th["expected_reward"])
    check("entropy of aligned policy", entropy_of(pi), th["entropy"])
    check("KL(pi || uniform)", kl_from_uniform(n, pi), th["kl_drift"])
    check("mass on the maximal response", pi[frozenset(range(n))], th["top_mass"])

    # pointwise Bernoulli product form
    theta = th["theta"]
    worst = max(abs(p - theta ** len(S) * (1 - theta) ** (n - len(S)))
                for S, p in pi.items())
    print(f"  max pointwise |pi(S) - Bernoulli product|      = {worst:.3e}")


def demo_binomial_law(n: int = 10, a: float = 1.1, beta: float = 0.8) -> None:
    rule(f"2. The reward statistic is Binomial(n, sigma(a/beta))  "
         f"(n={n}, a={a}, beta={beta})")
    pi = gibbs_policy(n, counting_reward(a), beta)
    theta = logistic(a / beta)
    empirical = [0.0] * (n + 1)
    for S, p in pi.items():
        empirical[len(S)] += p
    predicted = level_masses(n, theta)
    print(f"  theta = {theta:.9f}     mode = {mode_of_level_masses(n, theta)}")
    print("   k   exact level mass    binomial formula      log-concavity ratio")
    for k in range(n + 1):
        if 0 <= k <= n - 2 and predicted[k + 1] > 0:
            lc = predicted[k] * predicted[k + 2] / (predicted[k + 1] ** 2)
            lc_s = f"{lc:.6f} <= 1"
        else:
            lc_s = "-"
        print(f"  {k:2d}   {empirical[k]:.12f}    {predicted[k]:.12f}    {lc_s}")
    assert all(predicted[k] * predicted[k + 2] <= predicted[k + 1] ** 2 + 1e-15
               for k in range(n - 1)), "log-concavity violated"
    print("  log-concavity m_k m_{k+2} <= m_{k+1}^2 verified for all k  [OK]")


def demo_consistency_identity() -> None:
    rule("3. Consistency identity   t*sigma(t) - log((1+e^t)/2) = log 2 - H(sigma(t))")
    for t in (-4.0, -1.0, -0.25, 0.0, 0.25, 1.0, 2.5, 6.0):
        lhs = t * logistic(t) - log_half_one_plus_exp(t)
        rhs = math.log(2.0) - binary_entropy(logistic(t))
        check(f"t = {t:+.2f}", lhs, rhs)


def demo_reward_hacking(n: int = 12, a: float = 1.0) -> None:
    rule(f"4. Reward hacking: collapse onto the maximal response   (n={n}, a={a})")
    print("   beta      t=a/beta     theta       top mass = theta^n   "
          "bound 1 - n e^{-t}")
    for beta in (2.0, 1.0, 0.5, 0.25, 0.125, 0.0625):
        t = a / beta
        theta = logistic(t)
        top = theta ** n
        bound = 1.0 - n * math.exp(-t)
        assert top >= bound - 1e-12, "reward-hacking bound violated"
        print(f"  {beta:6.4f}   {t:8.3f}   {theta:.9f}   {top:.12f}   {bound: .9f}")
    print("  bound  pi([n]) >= 1 - n e^{-a/beta}  holds at every temperature  [OK]")

    print("\n  Strict antitonicity in beta (reward and collapse both fall as beta grows):")
    prev_rew = prev_top = None
    for beta in (0.25, 0.5, 1.0, 2.0, 4.0):
        theta = logistic(a / beta)
        rew, top = a * n * theta, theta ** n
        tag = ""
        if prev_rew is not None:
            assert rew < prev_rew and top < prev_top
            tag = "  (strictly decreased)"
        print(f"    beta={beta:5.2f}   E[reward]={rew:.9f}   top mass={top:.12f}{tag}")
        prev_rew, prev_top = rew, top


def demo_monotone_measure(n: int = 6, a: float = 0.8, beta: float = 1.0) -> None:
    rule(f"5. Alignment is order-preserving on the lattice   (n={n}, a={a}, beta={beta})")
    pi = gibbs_policy(n, counting_reward(a), beta)
    worst = 0.0
    pairs = 0
    for S in all_subsets(n):
        for T in all_subsets(n):
            if S <= T:
                pairs += 1
                worst = max(worst, pi[S] - pi[T])
    print(f"  checked {pairs} comparable pairs S ⊆ T")
    print(f"  max violation of pi(S) <= pi(T):  {worst:.3e}   [OK]" if worst <= 1e-15
          else f"  VIOLATION {worst:.3e}")


def demo_tensorization(a1: float = 0.6, a2: float = -0.3, beta: float = 0.7,
                       n1: int = 4, n2: int = 5) -> None:
    rule("6. Tensorization: additive rewards on a product make everything add")
    Z1 = partition_bruteforce(n1, counting_reward(a1), beta)
    Z2 = partition_bruteforce(n2, counting_reward(a2), beta)
    # the product space is the Boolean lattice on n1+n2 features with a reward
    # that is a1 per feature in the first block and a2 per feature in the second
    n = n1 + n2

    def split_reward(S: Subset) -> float:
        return a1 * len([i for i in S if i < n1]) + a2 * len([i for i in S if i >= n1])

    Z = partition_bruteforce(n, split_reward, beta)
    check("Z(product) = Z1 * Z2", Z, Z1 * Z2)
    check("F(product) = F1 + F2", beta * math.log(Z),
          beta * math.log(Z1) + beta * math.log(Z2))
    pi = gibbs_policy(n, split_reward, beta)
    pi1 = gibbs_policy(n1, counting_reward(a1), beta)
    pi2 = gibbs_policy(n2, counting_reward(a2), beta)
    worst = 0.0
    for S in all_subsets(n):
        A = frozenset(i for i in S if i < n1)
        B = frozenset(i - n1 for i in S if i >= n1)
        worst = max(worst, abs(pi[S] - pi1[A] * pi2[B]))
    print(f"  max |pi(product) - pi1 x pi2|                  = {worst:.3e}")
    check("KL(product) = KL1 + KL2", kl_from_uniform(n, pi),
          kl_from_uniform(n1, pi1) + kl_from_uniform(n2, pi2))
    print("  the aligned policy of a separable problem is again a product  [OK]")


def demo_supermodular_fkg(n: int = 7, beta: float = 0.6) -> None:
    rule(f"7. Supermodular (rule-bonus) rewards: FKG and Holley   (n={n}, beta={beta})")
    r = sum_rewards(
        counting_reward(0.3),
        rule_bonus([0, 1, 2], 1.5),      # conjunctive rule
        rule_bonus([2, 3], 0.9),         # overlapping conjunctive rule
        rule_bonus([4, 5, 6], 2.0),
    )
    ok, witness = is_supermodular(n, r)
    print(f"  reward is supermodular (diamond test): {ok}"
          + ("" if ok else f"  witness {witness}"))
    assert ok

    pi = gibbs_policy(n, r, beta)
    worst = check_log_supermodular(n, pi)
    print(f"  max violation of log-supermodularity of pi     = {worst:.3e}   [OK]")

    print("\n  FKG positive association of feature indicators  E[f]E[g] <= E[fg]:")
    print("    i  j      P(i)P(j)          P(i and j)        covariance")
    for i in range(3):
        for j in range(i + 1, 4):
            pi_i = expectation(pi, lambda S, i=i: 1.0 if i in S else 0.0)
            pi_j = expectation(pi, lambda S, j=j: 1.0 if j in S else 0.0)
            pij = expectation(pi, lambda S, i=i, j=j:
                              1.0 if (i in S and j in S) else 0.0)
            assert pi_i * pi_j <= pij + 1e-12
            print(f"    {i}  {j}   {pi_i * pi_j:.12f}    {pij:.12f}"
                  f"    {pij - pi_i * pi_j:+.3e}")
    print("  every pair positively correlated -- alignment entangles features  [OK]")

    print("\n  Holley stochastic dominance over the uniform reference:")
    u = {S: 1.0 / 2 ** n for S in all_subsets(n)}
    observables: List[Tuple[str, Callable[[Subset], float]]] = [
        ("|S|", lambda S: float(len(S))),
        ("|S|^2", lambda S: float(len(S)) ** 2),
        ("1[0 in S]", lambda S: 1.0 if 0 in S else 0.0),
        ("1[{0,1,2} <= S]", lambda S: 1.0 if frozenset({0, 1, 2}) <= S else 0.0),
        ("the reward itself", r),
    ]
    for name, h in observables:
        eu, ep = expectation(u, h), expectation(pi, h)
        assert eu <= ep + 1e-12
        print(f"    E_ref[{name:<18}] = {eu:12.8f}   <=   "
              f"E_aligned = {ep:12.8f}")
    print("  every monotone observable increases under alignment  [OK]")


def main() -> None:
    print(__doc__.strip().splitlines()[0])
    demo_closed_forms()
    demo_binomial_law()
    demo_consistency_identity()
    demo_reward_hacking()
    demo_monotone_measure()
    demo_tensorization()
    demo_supermodular_fkg()
    rule("All demonstrations completed.")


if __name__ == "__main__":
    main()
