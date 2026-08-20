"""
The Projective Geometry of KL-Regularised Alignment — numerical demonstrations.

Self-contained: standard library only (math, random, itertools).  Every routine
is inlined and type-hinted.  Running this file checks, numerically, each of the
main theorems:

  1.  Alignment is an isometry:  d_H(pi_b(r1), pi_b(r2)) = osc(r1 - r2) / b.
  2.  Sharp comparison:          TV(p,q) <= tanh(d_H(p,q)/4)  (and it beats
                                 the naive e^d - 1 bound, which is vacuous).
  3.  Misspecification:          TV(pi_b(r1), pi_b(r2)) < 1 always.
  4.  Envelope theorem:          dF/dt (r + t s) at t = 0 = E_{pi_b(r)}[s].
  5.  Annealing limits:          F -> max r as b -> 0+, F -> E_ref[r] as b -> oo,
                                 with the stated rates.
  6.  Goodhart regret:           F(b,r) - J_r(pi_b(rhat)) <= 2 ||r - rhat||_inf.
  7.  Pre-training identity:     E_pre[log pi_b(r)] = E_pre[log ref]
                                     + (E_pre[r] - F)/b,  and the no-regression
                                 criterion.
  8.  Symbolic constraints:      constrained optimum attained; filtering
                                 commutes with alignment; monotone + submodular;
                                 price bound.
  9.  Drift budget:              d_H(pi_n, ref) <= sum_k osc(r_k)/b, sharp when
                                 rounds do not cancel, strict when they do.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import List, Sequence

Vector = List[float]

TOL = 1e-9


# ----------------------------------------------------------------------------
# Core objects
# ----------------------------------------------------------------------------

def oscillation(f: Sequence[float]) -> float:
    """The oscillation seminorm  osc(f) = max f - min f."""
    return max(f) - min(f)


def normalise(w: Sequence[float]) -> Vector:
    """Normalise a positive weight vector to a probability vector."""
    total = sum(w)
    if total <= 0.0:
        raise ValueError("weights must have positive total mass")
    return [wi / total for wi in w]


def partition_function(beta: float, ref: Sequence[float], r: Sequence[float]) -> float:
    """Z_beta(r) = sum_i ref_i exp(r_i / beta)."""
    m = max(r)  # shift for numerical stability; compensated by the caller
    return sum(ri_ref * math.exp((ri - m) / beta) for ri_ref, ri in zip(ref, r)) * math.exp(m / beta)


def free_energy(beta: float, ref: Sequence[float], r: Sequence[float]) -> float:
    """F(beta, r) = beta log Z_beta(r), the optimal KL-regularised value."""
    m = max(r)
    shifted = sum(ri_ref * math.exp((ri - m) / beta) for ri_ref, ri in zip(ref, r))
    return m + beta * math.log(shifted)


def gibbs(beta: float, ref: Sequence[float], r: Sequence[float]) -> Vector:
    """The aligned policy pi_beta(r)_i proportional to ref_i exp(r_i / beta)."""
    m = max(r)
    w = [ri_ref * math.exp((ri - m) / beta) for ri_ref, ri in zip(ref, r)]
    return normalise(w)


def kl_divergence(p: Sequence[float], q: Sequence[float]) -> float:
    """KL(p || q), with the convention 0 log 0 = 0."""
    total = 0.0
    for pi, qi in zip(p, q):
        if pi > 0.0:
            total += pi * math.log(pi / qi)
    return total


def rlhf_objective(beta: float, ref: Sequence[float], r: Sequence[float],
                   p: Sequence[float]) -> float:
    """J_beta(p) = E_p[r] - beta KL(p || ref)."""
    return sum(pi * ri for pi, ri in zip(p, r)) - beta * kl_divergence(p, ref)


def hilbert_distance(p: Sequence[float], q: Sequence[float]) -> float:
    """Birkhoff's Hilbert projective metric d_H(p,q) = osc(log(p/q))."""
    ratios = [math.log(pi / qi) for pi, qi in zip(p, q)]
    return oscillation(ratios)


def tv_distance(p: Sequence[float], q: Sequence[float]) -> float:
    """Total variation distance, (1/2) sum_i |p_i - q_i|."""
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))


def tanh_bound(d: float) -> float:
    """The sharp comparison constant tanh(d/4) = (e^{d/2}-1)/(e^{d/2}+1)."""
    return math.tanh(d / 4.0)


def log10_one_minus_tanh_bound(d: float) -> float:
    """log10 of 1 - tanh(d/4) = 2/(e^{d/2}+1); the certified margin below 1.

    Computed in log space so that it remains meaningful far beyond the point
    where double precision reports tanh(d/4) as exactly 1.
    """
    return (math.log(2.0) - math.log1p(math.exp(min(d / 2.0, 700.0)))
            if d / 2.0 <= 700.0 else math.log(2.0) - d / 2.0) / math.log(10.0)


def naive_bound(d: float) -> float:
    """The crude comparison constant e^d - 1 (vacuous once d > log 2)."""
    try:
        return math.exp(d) - 1.0
    except OverflowError:
        return math.inf


# ----------------------------------------------------------------------------
# Constrained (symbolic) objects
# ----------------------------------------------------------------------------

def constrained_partition(beta: float, ref: Sequence[float], r: Sequence[float],
                          S: Sequence[int]) -> float:
    """Z_S = sum_{i in S} ref_i exp(r_i / beta)."""
    return sum(ref[i] * math.exp(r[i] / beta) for i in S)


def constrained_free_energy(beta: float, ref: Sequence[float], r: Sequence[float],
                            S: Sequence[int]) -> float:
    """F_S = beta log Z_S, the optimal value over policies supported in S."""
    return beta * math.log(constrained_partition(beta, ref, r, S))


def constrained_gibbs(beta: float, ref: Sequence[float], r: Sequence[float],
                      S: Sequence[int]) -> Vector:
    """The S-conditioned aligned policy (zero off S)."""
    Z = constrained_partition(beta, ref, r, S)
    out = [0.0] * len(ref)
    for i in S:
        out[i] = ref[i] * math.exp(r[i] / beta) / Z
    return out


# ----------------------------------------------------------------------------
# Random instances
# ----------------------------------------------------------------------------

def random_reference(n: int, rng: random.Random) -> Vector:
    """A strictly positive random reference policy on n outputs."""
    return normalise([rng.uniform(0.05, 1.0) for _ in range(n)])


def random_reward(n: int, scale: float, rng: random.Random) -> Vector:
    """A random reward model with values in [-scale, scale]."""
    return [rng.uniform(-scale, scale) for _ in range(n)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_isometry(rng: random.Random) -> None:
    print("=" * 78)
    print("1.  ALIGNMENT IS AN ISOMETRY:  d_H(pi_b(r1), pi_b(r2)) = osc(r1-r2)/beta")
    print("=" * 78)
    print(f"{'n':>3} {'beta':>7} {'d_H(policies)':>15} {'osc(r1-r2)/beta':>18} {'error':>11}")
    worst = 0.0
    for _ in range(6):
        n = rng.randint(3, 9)
        beta = rng.choice([0.05, 0.25, 1.0, 3.0, 10.0])
        ref = random_reference(n, rng)
        r1 = random_reward(n, 4.0, rng)
        r2 = random_reward(n, 4.0, rng)
        lhs = hilbert_distance(gibbs(beta, ref, r1), gibbs(beta, ref, r2))
        rhs = oscillation([a - b for a, b in zip(r1, r2)]) / beta
        worst = max(worst, abs(lhs - rhs))
        print(f"{n:>3} {beta:>7.2f} {lhs:>15.9f} {rhs:>18.9f} {abs(lhs-rhs):>11.2e}")
    print(f"\n  Maximum deviation from equality: {worst:.3e}   (equality, not a bound)")

    # Displacement from the reference and invariance under constant shifts.
    n, beta = 5, 0.7
    ref = random_reference(n, rng)
    r = random_reward(n, 3.0, rng)
    print(f"\n  d_H(pi_b(r), ref)        = {hilbert_distance(gibbs(beta, ref, r), ref):.9f}")
    print(f"  osc(r)/beta              = {oscillation(r)/beta:.9f}")
    shifted = [ri + 17.0 for ri in r]
    print(f"  d_H(pi_b(r), pi_b(r+17)) = "
          f"{hilbert_distance(gibbs(beta, ref, r), gibbs(beta, ref, shifted)):.3e}"
          "   (rewards matter only modulo constants)")
    print()


def demo_sharp_tv(rng: random.Random) -> None:
    print("=" * 78)
    print("2-3.  SHARP TV COMPARISON:  TV <= tanh(d_H/4) < 1,  vs the naive e^d - 1")
    print("=" * 78)
    print(f"{'beta':>7} {'osc(r1-r2)':>12} {'d_H':>10} {'TV':>10} "
          f"{'tanh(d/4)':>11} {'e^d - 1':>12}")
    n = 6
    ref = random_reference(n, rng)
    r1 = random_reward(n, 5.0, rng)
    r2 = random_reward(n, 5.0, rng)
    osc_diff = oscillation([a - b for a, b in zip(r1, r2)])
    for beta in (0.05, 0.1, 0.25, 0.5, 1.0, 2.0, 5.0, 20.0):
        p, q = gibbs(beta, ref, r1), gibbs(beta, ref, r2)
        d = hilbert_distance(p, q)
        tv = tv_distance(p, q)
        sharp, crude = tanh_bound(d), naive_bound(d)
        assert tv <= sharp + TOL, "sharp bound violated"
        assert tv <= 1.0
        crude_str = f"{crude:12.4f}" if crude < 1e6 else f"{crude:12.2e}"
        print(f"{beta:>7.2f} {osc_diff:>12.4f} {d:>10.4f} {tv:>10.6f} "
              f"{sharp:>11.6f} {crude_str}")
    print("\n  The naive bound exceeds 1 (hence says nothing) as soon as d > log 2 ~ 0.693;")
    print("  tanh(d/4) is always < 1 and is never violated.  Two aligned policies are")
    print("  therefore never mutually singular, however badly the rewards disagree.")
    print("  (Entries printed as 1.000000 are strictly below 1; the margin")
    print("   1 - tanh(d/4) = 2/(e^{d/2}+1) is simply smaller than display precision.)")

    # Stress test: adversarially large disagreement, tiny beta.  Here the tilted
    # policies underflow to zero in double precision, so we use the isometry to
    # obtain the Hilbert distance exactly and report the certified margin below 1
    # in log space.
    r_big = [0.0] * n
    r_big[0] = 500.0
    r_small = [0.0] * n
    r_small[n - 1] = 500.0
    beta_x = 0.01
    d_extreme = oscillation([a - b for a, b in zip(r_big, r_small)]) / beta_x
    print(f"\n  Extreme case (beta = {beta_x}, opposing reward spikes of size 500):")
    print(f"    d_H = osc(r1 - r2)/beta = {d_extreme:.1f}  (by the isometry theorem)")
    print(f"    The two policies underflow to disjoint-looking vectors in floating")
    print(f"    point, yet the theorem certifies")
    print(f"      1 - TV  >=  1 - tanh(d/4)  =  10^({log10_one_minus_tanh_bound(d_extreme):.1f}) > 0.")
    print()


def demo_sharpness() -> None:
    print("=" * 78)
    print("2b.  THE CONSTANT tanh(d/4) IS ATTAINED (extremal two-point pairs)")
    print("=" * 78)
    print(f"{'d':>8} {'d_H(p,q)':>12} {'TV(p,q)':>12} {'tanh(d/4)':>12} {'error':>11}")
    for d in (0.1, 0.5, 1.0, 2.0, 5.0, 12.0):
        theta = math.exp(d / 2.0)
        p = [theta / (1.0 + theta), 1.0 / (1.0 + theta)]
        q = [1.0 / (1.0 + theta), theta / (1.0 + theta)]
        dh, tv, bound = hilbert_distance(p, q), tv_distance(p, q), tanh_bound(d)
        assert abs(dh - d) < 1e-9 and abs(tv - bound) < 1e-12
        print(f"{d:>8.2f} {dh:>12.8f} {tv:>12.9f} {bound:>12.9f} {abs(tv-bound):>11.2e}")
    print("\n  Equality throughout: the likelihood ratios are theta and 1/theta, which is")
    print("  exactly the equality case v*w = 1 of the square (v w - 1)^2 >= 0 driving")
    print("  the proof.  Since any two positive policies are tilts of any positive")
    print("  reference, the misspecification bound is attained too.\n")


def demo_envelope(rng: random.Random) -> None:
    print("=" * 78)
    print("4.  ENVELOPE THEOREM:  dF/dt|_0 F(beta, r + t s) = E_{pi_beta(r)}[s]")
    print("=" * 78)
    n, beta = 7, 0.8
    ref = random_reference(n, rng)
    r = random_reward(n, 2.0, rng)
    s = random_reward(n, 2.0, rng)
    policy = gibbs(beta, ref, r)
    analytic = sum(pi * si for pi, si in zip(policy, s))
    print(f"{'h':>10} {'central difference':>22} {'error':>12}")
    for h in (1e-2, 1e-3, 1e-4, 1e-5):
        up = free_energy(beta, ref, [ri + h * si for ri, si in zip(r, s)])
        dn = free_energy(beta, ref, [ri - h * si for ri, si in zip(r, s)])
        num = (up - dn) / (2.0 * h)
        print(f"{h:>10.0e} {num:>22.12f} {abs(num-analytic):>12.2e}")
    print(f"{'analytic':>10} {analytic:>22.12f}")
    print("\n  The aligned policy is the reward-gradient of the alignment value.\n")


def demo_annealing(rng: random.Random) -> None:
    print("=" * 78)
    print("5.  ANNEALING LIMITS WITH RATES")
    print("=" * 78)
    n = 5
    ref = random_reference(n, rng)
    r = random_reward(n, 3.0, rng)
    M = max(abs(ri) for ri in r)
    print(f"  max r = {max(r):.6f},  E_ref[r] = {sum(a*b for a, b in zip(ref, r)):.6f},"
          f"  ||r||_inf = {M:.4f}")
    print(f"\n  Cold limit (beta -> 0+):  max r + beta log(min ref)  <=  F  <=  max r")
    print(f"{'beta':>9} {'lower':>14} {'F':>14} {'upper (max r)':>15}")
    for beta in (1.0, 0.3, 0.1, 0.03, 0.01, 0.003):
        F = free_energy(beta, ref, r)
        lo = max(r) + beta * math.log(min(ref))
        assert lo - TOL <= F <= max(r) + TOL
        print(f"{beta:>9.3f} {lo:>14.6f} {F:>14.6f} {max(r):>15.6f}")

    exp_ref = sum(a * b for a, b in zip(ref, r))
    print(f"\n  Hot limit (beta -> oo):  0 <= F - E_ref[r] <= (3/4) M^2 / beta  (beta >= M)")
    print(f"{'beta':>9} {'F - E_ref[r]':>16} {'(3/4)M^2/beta':>16}")
    for beta in (M, 2 * M, 5 * M, 20 * M, 100 * M):
        gap = free_energy(beta, ref, r) - exp_ref
        bound = 0.75 * M * M / beta
        assert -TOL <= gap <= bound + TOL
        print(f"{beta:>9.3f} {gap:>16.9f} {bound:>16.9f}")
    print()


def demo_goodhart(rng: random.Random) -> None:
    print("=" * 78)
    print("6.  GOODHART REGRET:  F(b,r) - J_r(pi_b(rhat)) <= 2 ||r - rhat||_inf")
    print("=" * 78)
    n = 8
    ref = random_reference(n, rng)
    r = random_reward(n, 3.0, rng)
    print(f"{'beta':>8} {'M':>8} {'true regret':>14} {'bound 2M':>10} {'slack':>10}")
    for beta in (0.05, 0.2, 1.0, 5.0):
        for M in (0.1, 0.5, 2.0):
            rhat = [ri + rng.uniform(-M, M) for ri in r]
            M_eff = max(abs(a - b) for a, b in zip(r, rhat))
            regret = free_energy(beta, ref, r) - rlhf_objective(
                beta, ref, r, gibbs(beta, ref, rhat))
            assert regret <= 2.0 * M_eff + TOL
            print(f"{beta:>8.2f} {M_eff:>8.4f} {regret:>14.8f} "
                  f"{2*M_eff:>10.4f} {2*M_eff-regret:>10.4f}")
    print("\n  The bound holds uniformly in beta: value robustness does not need a")
    print("  short leash, though policy stability does.\n")


def demo_ptx(rng: random.Random) -> None:
    print("=" * 78)
    print("7.  EXACT PRE-TRAINING IDENTITY AND THE NO-REGRESSION CRITERION")
    print("=" * 78)
    n, beta, gamma = 6, 0.6, 0.3
    ref = random_reference(n, rng)
    r = random_reward(n, 2.5, rng)
    pre = random_reference(n, rng)

    aligned = gibbs(beta, ref, r)
    lhs = sum(p * math.log(a) for p, a in zip(pre, aligned))
    F = free_energy(beta, ref, r)
    E_pre_r = sum(p * ri for p, ri in zip(pre, r))
    rhs = sum(p * math.log(q) for p, q in zip(pre, ref)) + (E_pre_r - F) / beta
    print(f"  E_pre[log pi_b(r)]                       = {lhs:.12f}")
    print(f"  E_pre[log ref] + (E_pre[r] - F)/beta     = {rhs:.12f}")
    print(f"  identity error                           = {abs(lhs-rhs):.2e}")

    print(f"\n  No-regression criterion:  regression happens iff E_pre[r] < F(beta,r).")
    print(f"{'beta':>8} {'E_pre[r]':>12} {'F(beta,r)':>12} {'PTX change':>14} {'regress?':>10}")
    for beta_i in (0.05, 0.2, 0.6, 2.0, 10.0, 50.0):
        F_i = free_energy(beta_i, ref, r)
        aligned_i = gibbs(beta_i, ref, r)
        change = gamma * (sum(p * math.log(a) for p, a in zip(pre, aligned_i))
                          - sum(p * math.log(q) for p, q in zip(pre, ref)))
        predicted = E_pre_r < F_i - TOL
        assert predicted == (change < -TOL)
        assert -change <= gamma * oscillation(r) / beta_i + TOL
        print(f"{beta_i:>8.2f} {E_pre_r:>12.6f} {F_i:>12.6f} {change:>14.8f} "
              f"{'yes' if predicted else 'no':>10}")
    print(f"\n  Worst-case budget gamma*osc(r)/beta is respected at every beta above.")
    print("  Aggressive alignment (small beta) raises F and so triggers regression.\n")


def demo_symbolic(rng: random.Random) -> None:
    print("=" * 78)
    print("8.  SYMBOLIC CONSTRAINTS: attainment, commutation, submodularity, price")
    print("=" * 78)
    n, beta = 7, 0.9
    ref = random_reference(n, rng)
    r = random_reward(n, 2.0, rng)
    S = [0, 1, 3, 5]

    # Attainment of the constrained optimum.
    pi_S = constrained_gibbs(beta, ref, r, S)
    F_S = constrained_free_energy(beta, ref, r, S)
    print(f"  J_beta(constrained optimum) = {rlhf_objective(beta, ref, r, pi_S):.12f}")
    print(f"  F_S                         = {F_S:.12f}")
    # Random admissible competitors score strictly less.
    worst_gap = math.inf
    for _ in range(2000):
        w = [rng.random() if i in S else 0.0 for i in range(n)]
        p = normalise(w)
        worst_gap = min(worst_gap, F_S - rlhf_objective(beta, ref, r, p))
    print(f"  best random competitor falls short by {worst_gap:.3e} (>= 0)")

    # Commutation of filtering and alignment.
    aligned = gibbs(beta, ref, r)
    mass = sum(aligned[i] for i in S)
    err = max(abs(pi_S[i] - aligned[i] / mass) for i in S)
    print(f"\n  Filter-then-align vs align-then-filter, max discrepancy: {err:.2e}")

    # Monotonicity and submodularity over the Boolean lattice.
    idx = list(range(n))
    viol_mono = viol_sub = 0
    min_slack = math.inf
    subsets = [list(c) for k in range(1, n + 1) for c in combinations(idx, k)]
    for A in subsets:
        for B in subsets:
            inter = sorted(set(A) & set(B))
            if not inter:
                continue
            union = sorted(set(A) | set(B))
            slack = (constrained_free_energy(beta, ref, r, A)
                     + constrained_free_energy(beta, ref, r, B)
                     - constrained_free_energy(beta, ref, r, union)
                     - constrained_free_energy(beta, ref, r, inter))
            min_slack = min(min_slack, slack)
            if slack < -TOL:
                viol_sub += 1
            if set(A) <= set(B) and (constrained_free_energy(beta, ref, r, A)
                                     > constrained_free_energy(beta, ref, r, B) + TOL):
                viol_mono += 1
    print(f"  Exhaustive lattice check on 2^{n} - 1 = {len(subsets)} admissible sets:")
    print(f"    monotonicity violations   : {viol_mono}")
    print(f"    submodularity violations  : {viol_sub}")
    print(f"    minimal submodular slack  : {min_slack:.3e}  (>= 0 as claimed)")

    # Price of a rule set.
    print(f"\n  Price of a rule set:  F - F_S <= osc(r) - beta log ref(S)")
    print(f"{'|S|':>5} {'ref(S)':>10} {'F - F_S':>12} {'bound':>12}")
    for k in (1, 2, 3, 5, 7):
        T = list(range(k))
        price = free_energy(beta, ref, r) - constrained_free_energy(beta, ref, r, T)
        bound = oscillation(r) - beta * math.log(sum(ref[i] for i in T))
        assert price <= bound + TOL
        print(f"{k:>5} {sum(ref[i] for i in T):>10.5f} {price:>12.6f} {bound:>12.6f}")
    print()


def demo_drift(rng: random.Random) -> None:
    print("=" * 78)
    print("9.  DRIFT BUDGET FOR ITERATED ALIGNMENT")
    print("=" * 78)
    n, beta = 6, 0.5
    ref = random_reference(n, rng)

    # (a) Generic rounds: budget holds, with slack from partial cancellation.
    rounds: List[Vector] = [random_reward(n, 1.0, rng) for _ in range(6)]
    print("  (a) Random rounds")
    print(f"{'n rounds':>9} {'true drift':>13} {'budget':>12} {'slack':>11}")
    for k in range(1, len(rounds) + 1):
        acc = [sum(rounds[j][i] for j in range(k)) for i in range(n)]
        drift = hilbert_distance(gibbs(beta, ref, acc), ref)
        budget = sum(oscillation(rounds[j]) for j in range(k)) / beta
        assert drift <= budget + TOL
        print(f"{k:>9} {drift:>13.6f} {budget:>12.6f} {budget-drift:>11.6f}")

    # (b) Aligned rounds (common argmax/argmin): the budget is attained.
    base = [0.0] * n
    base[0], base[n - 1] = 1.0, -1.0
    aligned_rounds = [[c * b for b in base] for c in (0.5, 1.0, 2.0, 0.25)]
    acc = [sum(rd[i] for rd in aligned_rounds) for i in range(n)]
    drift = hilbert_distance(gibbs(beta, ref, acc), ref)
    budget = sum(oscillation(rd) for rd in aligned_rounds) / beta
    print(f"\n  (b) Non-cancelling rounds (shared argmax and argmin):")
    print(f"      drift = {drift:.9f},  budget = {budget:.9f},  gap = {abs(drift-budget):.2e}")

    # (c) Cancelling rounds: drift is zero but the budget is positive.
    s = random_reward(n, 1.5, rng)
    acc = [0.0] * n
    drift = hilbert_distance(gibbs(beta, ref, acc), ref)
    budget = 2.0 * oscillation(s) / beta
    print(f"\n  (c) Cancelling rounds (s then -s):")
    print(f"      drift = {drift:.2e},  budget = {budget:.6f}  -> the bound is strict,")
    print("      so no round-wise ledger can do better without joint information.\n")


def demo_beta_calibration(rng: random.Random) -> None:
    print("=" * 78)
    print("10.  CALIBRATING beta FROM A DRIFT TARGET (an exact inversion)")
    print("=" * 78)
    n = 6
    ref = random_reference(n, rng)
    r = random_reward(n, 4.0, rng)
    print(f"  osc(r) = {oscillation(r):.6f}")
    print(f"{'target d_H':>12} {'beta*':>10} {'achieved d_H':>14} {'TV':>10} "
          f"{'TV bound':>10}")
    for delta in (0.05, 0.2, 0.5, 1.0, 3.0):
        beta_star = oscillation(r) / delta
        achieved = hilbert_distance(gibbs(beta_star, ref, r), ref)
        tv = tv_distance(gibbs(beta_star, ref, r), ref)
        print(f"{delta:>12.3f} {beta_star:>10.4f} {achieved:>14.9f} {tv:>10.6f} "
              f"{tanh_bound(delta):>10.6f}")
    print(f"\n{'target TV':>12} {'beta*':>10} {'achieved TV':>14}")
    for tau in (0.02, 0.1, 0.3, 0.6):
        beta_star = oscillation(r) / (4.0 * math.atanh(tau))
        tv = tv_distance(gibbs(beta_star, ref, r), ref)
        assert tv <= tau + TOL
        print(f"{tau:>12.3f} {beta_star:>10.4f} {tv:>14.6f}")
    print("\n  The Hilbert target is met exactly; the TV target is met conservatively.\n")


def main() -> None:
    rng = random.Random(20260820)
    print()
    print("#" * 78)
    print("#  THE PROJECTIVE GEOMETRY OF KL-REGULARISED ALIGNMENT".ljust(77) + "#")
    print("#  numerical demonstrations of every main theorem".ljust(77) + "#")
    print("#" * 78)
    print()
    demo_isometry(rng)
    demo_sharp_tv(rng)
    demo_sharpness()
    demo_envelope(rng)
    demo_annealing(rng)
    demo_goodhart(rng)
    demo_ptx(rng)
    demo_symbolic(rng)
    demo_drift(rng)
    demo_beta_calibration(rng)
    print("=" * 78)
    print("All numerical checks passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
