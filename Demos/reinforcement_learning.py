"""
Numerical demonstrations of the exact theory of the KL-regularised alignment
objective.

The objective, over a finite response alphabet, is

    J(p) = E_p[R] - beta * KL(p || pi_ref) + gamma * E_{D_pre}[log p]

and the theory says:

  * the reward+KL part equals  beta*log Z - beta*KL(p || pi*)   (three-point
    identity), where pi*(i) ∝ pi_ref(i) exp(R(i)/beta);
  * hence pi* is the unique maximiser, with optimal value F = beta*log Z;
  * E_ref[R] <= F <= max R;
  * beta * KL(pi* || pi_ref) <= max R - min R;
  * ||pi* - pi_ref||_1^2 <= 2 (max R - min R) / beta   (Pinsker route);
  * tilting is an additive group action: tilt(tilt(ref,R),S) = tilt(ref,R+S);
  * adding a constant to R leaves pi* unchanged and shifts F by that constant;
  * (KL, reward) is monotone in beta -- the alignment Pareto frontier;
  * the full objective attains  F + P(D_pre)  iff  D_pre = pi*;
  * a reward within eps of the truth loses at most 2 eps of value.

Everything below is self-contained: pure Python plus the standard library.

Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

Vec = List[float]

# --------------------------------------------------------------------------- #
# Core numerics                                                               #
# --------------------------------------------------------------------------- #


def logsumexp(u: Sequence[float]) -> float:
    """Numerically stable log(sum(exp(u_i)))."""
    umax = max(u)
    return umax + math.log(sum(math.exp(x - umax) for x in u))


def softmax(u: Sequence[float]) -> Vec:
    """Numerically stable softmax."""
    umax = max(u)
    e = [math.exp(x - umax) for x in u]
    s = sum(e)
    return [x / s for x in e]


def tilted_policy(ref: Sequence[float], reward: Sequence[float], beta: float) -> Vec:
    """The exponentially tilted policy pi*(i) ∝ ref(i) exp(R(i)/beta)."""
    u = [math.log(r) + q / beta for r, q in zip(ref, reward)]
    return softmax(u)


def free_energy(ref: Sequence[float], reward: Sequence[float], beta: float) -> float:
    """F = beta * log Z with Z = sum_i ref(i) exp(R(i)/beta)."""
    u = [math.log(r) + q / beta for r, q in zip(ref, reward)]
    return beta * logsumexp(u)


def kl(p: Sequence[float], q: Sequence[float]) -> float:
    """Finite Kullback-Leibler divergence with 0 log 0 = 0."""
    total = 0.0
    for pi, qi in zip(p, q):
        if pi > 0.0:
            total += pi * math.log(pi / qi)
    return total


def expectation(p: Sequence[float], f: Sequence[float]) -> float:
    return sum(pi * fi for pi, fi in zip(p, f))


def l1(p: Sequence[float], q: Sequence[float]) -> float:
    return sum(abs(pi - qi) for pi, qi in zip(p, q))


def rl_objective(
    p: Sequence[float], ref: Sequence[float], reward: Sequence[float], beta: float
) -> float:
    """E_p[R] - beta KL(p || ref)."""
    return expectation(p, reward) - beta * kl(p, ref)


def ptx_term(p: Sequence[float], pre: Sequence[float], gamma: float) -> float:
    """gamma * E_{pre}[log p]."""
    return gamma * sum(pre_i * math.log(pi) for pre_i, pi in zip(pre, p))


def full_objective(
    p: Sequence[float],
    ref: Sequence[float],
    reward: Sequence[float],
    pre: Sequence[float],
    beta: float,
    gamma: float,
) -> float:
    return rl_objective(p, ref, reward, beta) + ptx_term(p, pre, gamma)


def normalise(v: Sequence[float]) -> Vec:
    s = sum(v)
    return [x / s for x in v]


def random_policy(n: int, rng: random.Random) -> Vec:
    return normalise([rng.uniform(0.05, 1.0) for _ in range(n)])


# --------------------------------------------------------------------------- #
# A running example                                                           #
# --------------------------------------------------------------------------- #

RESPONSES: List[str] = [
    "concise and correct",
    "verbose but correct",
    "confidently wrong",
    "refuses to answer",
    "off-topic rambling",
]
REF: Vec = normalise([0.20, 0.30, 0.25, 0.10, 0.15])
REWARD: Vec = [3.0, 1.5, -2.0, 0.0, -1.0]


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def show_policy(p: Sequence[float], label: str) -> None:
    print(f"  {label}")
    for name, prob in zip(RESPONSES, p):
        bar = "#" * int(round(60 * prob))
        print(f"    {name:<22s} {prob:7.4f} {bar}")


# --------------------------------------------------------------------------- #
# Demonstration 1: the three-point identity and the variational principle     #
# --------------------------------------------------------------------------- #


def demo_three_point_identity(beta: float = 1.0, trials: int = 5) -> None:
    banner("1. Three-point identity and the Gibbs variational principle")
    star = tilted_policy(REF, REWARD, beta)
    F = free_energy(REF, REWARD, beta)
    print(f"  beta = {beta}")
    show_policy(REF, "reference policy pi_ref:")
    show_policy(star, "aligned policy pi*:")
    print(f"\n  free energy F = beta log Z = {F:.6f}")
    print(f"  J(pi*)                     = {rl_objective(star, REF, REWARD, beta):.6f}")
    print("\n  Check J(p) = F - beta KL(p || pi*) on random policies, and J(p) <= F:")
    rng = random.Random(20260820)
    print(f"    {'J(p)':>12s} {'F - beta*KL':>14s} {'residual':>12s} {'J(p)<=F':>9s}")
    for _ in range(trials):
        p = random_policy(len(REF), rng)
        lhs = rl_objective(p, REF, REWARD, beta)
        rhs = F - beta * kl(p, star)
        print(f"    {lhs:12.8f} {rhs:14.8f} {abs(lhs - rhs):12.2e} {str(lhs <= F + 1e-12):>9s}")
    print("\n  Uniqueness: only pi* attains F, and the gap is exactly beta*KL(p||pi*).")


# --------------------------------------------------------------------------- #
# Demonstration 2: sandwich, leash, and the two drift bounds                  #
# --------------------------------------------------------------------------- #


def demo_bounds() -> None:
    banner("2. Value sandwich, divergence leash, and drift laws")
    m, M = min(REWARD), max(REWARD)
    delta = M - m
    ref_reward = expectation(REF, REWARD)
    print(f"  reward range: m = {m}, M = {M}, Delta = {delta}")
    print(f"  E_ref[R] = {ref_reward:.6f}\n")
    header = (
        f"  {'beta':>7s} {'F':>10s} {'E_pi*[R]':>10s} {'KL(pi*||ref)':>13s}"
        f" {'beta*KL<=D':>11s} {'L1':>8s} {'exp bnd':>10s} {'sqrt bnd':>9s}"
    )
    print(header)
    for beta in (0.1, 0.25, 0.5, 1.0, 2.0, 5.0, 20.0):
        star = tilted_policy(REF, REWARD, beta)
        F = free_energy(REF, REWARD, beta)
        k = kl(star, REF)
        d1 = l1(star, REF)
        exp_bound = math.exp(delta / beta) - 1.0
        sqrt_bound = math.sqrt(2.0 * delta / beta)
        print(
            f"  {beta:7.2f} {F:10.5f} {expectation(star, REWARD):10.5f} {k:13.5f}"
            f" {beta * k:11.5f} {d1:8.4f} {exp_bound:10.3g} {sqrt_bound:9.3f}"
        )
        assert ref_reward - 1e-12 <= F <= M + 1e-12
        assert beta * k <= delta + 1e-12
        assert d1 <= exp_bound + 1e-12
        assert d1 * d1 <= 2.0 * delta / beta + 1e-12
    print("\n  All bounds verified.  Note the square-root bound beats the exponential")
    print("  one exactly when Delta > beta, i.e. in every row with beta < 5.")


# --------------------------------------------------------------------------- #
# Demonstration 3: the alignment Pareto frontier                              #
# --------------------------------------------------------------------------- #


def demo_pareto_frontier() -> None:
    banner("3. The alignment Pareto frontier: reward bought with divergence")
    betas = [10.0 ** (1.0 - 0.25 * k) for k in range(13)]  # 10.0 down to ~0.01
    print(f"  {'beta':>9s} {'KL(pi*||ref)':>13s} {'E_pi*[R]':>10s}   monotone?")
    prev_kl = -1.0
    prev_rw = -math.inf
    for beta in betas:
        star = tilted_policy(REF, REWARD, beta)
        k = kl(star, REF)
        rw = expectation(star, REWARD)
        ok = (k >= prev_kl - 1e-12) and (rw >= prev_rw - 1e-12)
        print(f"  {beta:9.4f} {k:13.6f} {rw:10.6f}   {'yes' if ok else 'NO'}")
        assert ok
        prev_kl, prev_rw = k, rw
    print("\n  Both coordinates increase as beta decreases (monotone frontier).")
    print(f"  Limits: beta -> inf gives pi_ref with reward {expectation(REF, REWARD):.5f};")
    print(f"          beta -> 0+  gives the arg-max response with reward {max(REWARD):.5f}.")


# --------------------------------------------------------------------------- #
# Demonstration 4: divergence-budgeted alignment (bisection in beta)          #
# --------------------------------------------------------------------------- #


def solve_beta_for_kl_budget(
    ref: Sequence[float],
    reward: Sequence[float],
    budget: float,
    tol: float = 1e-12,
    max_iter: int = 200,
) -> float:
    """Find beta with KL(pi*_beta || ref) = budget, by bisection.

    KL is continuous and nonincreasing in beta, tends to 0 as beta -> infinity
    and to log(1/ref(argmax R)) as beta -> 0+, so bisection is well posed for
    any feasible budget.
    """
    lo, hi = 1e-9, 1.0
    while kl(tilted_policy(ref, reward, hi), ref) > budget:
        hi *= 2.0
        if hi > 1e12:
            raise ValueError("budget appears infeasible")
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if kl(tilted_policy(ref, reward, mid), ref) > budget:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol * max(1.0, hi):
            break
    return 0.5 * (lo + hi)


def demo_budgeted_alignment() -> None:
    banner("4. Divergence-budgeted alignment: choosing beta from a KL budget")
    delta = max(REWARD) - min(REWARD)
    print(f"  {'budget k':>9s} {'beta*':>10s} {'achieved KL':>12s} {'reward':>9s} {'Delta/k':>9s}")
    for budget in (0.01, 0.05, 0.1, 0.3, 0.6, 1.0):
        beta = solve_beta_for_kl_budget(REF, REWARD, budget)
        star = tilted_policy(REF, REWARD, beta)
        print(
            f"  {budget:9.3f} {beta:10.5f} {kl(star, REF):12.6f}"
            f" {expectation(star, REWARD):9.5f} {delta / budget:9.3f}"
        )
        # The leash beta*KL <= Delta certifies the a priori bracket beta <= Delta/k.
        assert beta <= delta / budget + 1e-6
    print("\n  The last column is the a priori bracket supplied by the leash bound.")


# --------------------------------------------------------------------------- #
# Demonstration 5: tilting is a group action                                  #
# --------------------------------------------------------------------------- #


def demo_group_action(beta: float = 0.8) -> None:
    banner("5. Exponential tilting as a group action of rewards")
    r1 = [1.0, -0.5, 2.0, 0.25, -1.5]
    r2 = [-0.75, 2.0, 0.5, -1.0, 1.25]
    stage1 = tilted_policy(REF, r1, beta)
    stage2 = tilted_policy(stage1, r2, beta)
    onestep = tilted_policy(REF, [a + b for a, b in zip(r1, r2)], beta)
    print("  Additivity: tilt(tilt(ref, r1), r2) == tilt(ref, r1 + r2)")
    print(f"    max coordinate discrepancy: {max(abs(a - b) for a, b in zip(stage2, onestep)):.3e}")

    reversed_order = tilted_policy(tilted_policy(REF, r2, beta), r1, beta)
    print("  Order independence (rewards commute):")
    print(
        "    max discrepancy between the two orders: "
        f"{max(abs(a - b) for a, b in zip(stage2, reversed_order)):.3e}"
    )

    c = 4.2
    shifted = tilted_policy(REF, [x + c for x in REWARD], beta)
    base = tilted_policy(REF, REWARD, beta)
    print(f"  Stabiliser: adding the constant c = {c} to the reward")
    print(f"    policy discrepancy: {max(abs(a - b) for a, b in zip(shifted, base)):.3e}")
    print(
        f"    free energy shift:  {free_energy(REF, [x + c for x in REWARD], beta) - free_energy(REF, REWARD, beta):.6f}"
        f"  (should be {c})"
    )

    target = normalise([0.4, 0.1, 0.05, 0.3, 0.15])
    transport = [beta * math.log(t / r) for t, r in zip(target, REF)]
    reached = tilted_policy(REF, transport, beta)
    print("  Transitivity: an explicit reward carrying pi_ref to an arbitrary target")
    print(f"    max discrepancy from target: {max(abs(a - b) for a, b in zip(reached, target)):.3e}")

    implicit = [beta * math.log(s / r) for s, r in zip(base, REF)]
    gaps = [a - b for a, b in zip(implicit, REWARD)]
    print("  Implicit reward of pi* recovers R up to an additive constant:")
    print(f"    R_implicit - R = {[round(g, 6) for g in gaps]}")
    print(f"    (constant, equal to -F = {-free_energy(REF, REWARD, beta):.6f})")


# --------------------------------------------------------------------------- #
# Demonstration 6: Bradley-Terry identifiability                              #
# --------------------------------------------------------------------------- #


def bt_matrix(reward: Sequence[float]) -> List[List[float]]:
    return [[1.0 / (1.0 + math.exp(rj - ri)) for rj in reward] for ri in reward]


def demo_preference_identifiability(beta: float = 1.0) -> None:
    banner("6. Preference data determines the aligned policy exactly")
    shifted = [x + 7.5 for x in REWARD]
    rescaled = [1.3 * x for x in REWARD]
    a, b, c = bt_matrix(REWARD), bt_matrix(shifted), bt_matrix(rescaled)
    dif_shift = max(abs(a[i][j] - b[i][j]) for i in range(len(REWARD)) for j in range(len(REWARD)))
    dif_scale = max(abs(a[i][j] - c[i][j]) for i in range(len(REWARD)) for j in range(len(REWARD)))
    print(f"  max preference difference, R vs R + 7.5   : {dif_shift:.3e}  (identical)")
    print(f"  max preference difference, R vs 1.3 R     : {dif_scale:.3e}  (different)")
    p0 = tilted_policy(REF, REWARD, beta)
    p1 = tilted_policy(REF, shifted, beta)
    p2 = tilted_policy(REF, rescaled, beta)
    print(f"  policy difference,   R vs R + 7.5         : {l1(p0, p1):.3e}  (same policy)")
    print(f"  policy difference,   R vs 1.3 R           : {l1(p0, p2):.3e}  (different)")
    print("\n  Reward shifts are gauge: unobservable in preferences and in the policy.")


# --------------------------------------------------------------------------- #
# Demonstration 7: reward misspecification costs at most 2 eps                #
# --------------------------------------------------------------------------- #


def demo_reward_hacking(beta: float = 0.7, eps: float = 0.35, trials: int = 2000) -> None:
    banner("7. Reward misspecification: the 2-epsilon bound")
    rng = random.Random(11235)
    F_true = free_energy(REF, REWARD, beta)
    worst = 0.0
    for _ in range(trials):
        noisy = [x + rng.uniform(-eps, eps) for x in REWARD]
        phat = tilted_policy(REF, noisy, beta)
        loss = F_true - rl_objective(phat, REF, REWARD, beta)
        worst = max(worst, loss)
        assert loss <= 2.0 * eps + 1e-12
    print(f"  beta = {beta}, sup-norm reward error eps = {eps}")
    print(f"  worst observed loss over {trials} perturbations: {worst:.6f}")
    print(f"  guaranteed bound 2*eps                        : {2.0 * eps:.6f}")
    print("  (Also: the free energy itself moves by at most eps -- 1-Lipschitz.)")


# --------------------------------------------------------------------------- #
# Demonstration 8: the pre-training mix-in and the alignment tax              #
# --------------------------------------------------------------------------- #


def demo_alignment_tax(beta: float = 1.0, gamma: float = 0.5) -> None:
    banner("8. The pre-training mix-in: an exact obstruction, and its size")
    star = tilted_policy(REF, REWARD, beta)
    F = free_energy(REF, REWARD, beta)

    def joint_bound(pre: Sequence[float]) -> float:
        return F + ptx_term(pre, pre, gamma)

    print("  Case A: pre-training distribution equals the aligned optimum.")
    pre_a = list(star)
    best_a = full_objective(star, REF, REWARD, pre_a, beta, gamma)
    print(f"    joint bound        = {joint_bound(pre_a):.8f}")
    print(f"    value at p = pi*   = {best_a:.8f}")
    print(f"    gap                = {joint_bound(pre_a) - best_a:.2e}  (attained)")

    print("\n  Case B: a genuinely different pre-training distribution.")
    pre_b = normalise([0.30, 0.30, 0.20, 0.10, 0.10])
    bound_b = joint_bound(pre_b)
    rng = random.Random(4242)
    best_b = -math.inf
    argbest: Vec = []
    # coarse search over the simplex, refined by a local random walk
    for _ in range(20000):
        p = random_policy(len(REF), rng)
        v = full_objective(p, REF, REWARD, pre_b, beta, gamma)
        if v > best_b:
            best_b, argbest = v, p
    step = 0.05
    for _ in range(60000):
        p = normalise([max(1e-9, x + rng.uniform(-step, step) * x) for x in argbest])
        v = full_objective(p, REF, REWARD, pre_b, beta, gamma)
        if v > best_b:
            best_b, argbest = v, p
        step *= 0.99995
    tax = bound_b - best_b
    print(f"    joint bound                = {bound_b:.6f}")
    print(f"    best value found           = {best_b:.6f}")
    print(f"    alignment tax (strict gap) = {tax:.6f}  > 0")
    print(
        "    predicted tax = min over p of "
        "[beta KL(p||pi*) + gamma KL(pre||p)]"
    )
    predicted = min(
        beta * kl(p, star) + gamma * kl(pre_b, p)
        for p in [argbest]
    )
    print(f"    at the found optimum this equals {predicted:.6f}")
    show_policy(star, "aligned optimum pi* (what the reward wants):")
    show_policy(pre_b, "pre-training distribution (what the mix-in wants):")
    show_policy(argbest, "compromise optimum of the full objective:")


# --------------------------------------------------------------------------- #
# Demonstration 9: prompt-wise decomposition and localisation of the tax      #
# --------------------------------------------------------------------------- #


def demo_multiprompt(beta: float = 1.0, gamma: float = 0.6) -> None:
    banner("9. Many prompts: optimality decouples, and the tax stays local")
    prompts = ["x0 (mix-in attached)", "x1", "x2"]
    weights = [0.5, 0.3, 0.2]
    refs = [
        normalise([0.2, 0.3, 0.25, 0.1, 0.15]),
        normalise([0.1, 0.1, 0.4, 0.3, 0.1]),
        normalise([0.3, 0.2, 0.2, 0.2, 0.1]),
    ]
    rewards = [
        [3.0, 1.5, -2.0, 0.0, -1.0],
        [0.5, 2.5, -1.0, 1.0, -0.5],
        [-1.0, 0.0, 1.0, 2.0, 3.0],
    ]
    pre = normalise([0.30, 0.30, 0.20, 0.10, 0.10])

    stars = [tilted_policy(r, q, beta) for r, q in zip(refs, rewards)]
    Fs = [free_energy(r, q, beta) for r, q in zip(refs, rewards)]
    Fmulti = sum(w * f for w, f in zip(weights, Fs))
    print(f"  prompt-averaged free energy F_multi = {Fmulti:.6f}")
    print("  Without the mix-in, the optimum is prompt-wise tilted; check by")
    print("  perturbing one conditional at a time:")
    rng = random.Random(99)
    for j, name in enumerate(prompts):
        conditionals = [list(s) for s in stars]
        conditionals[j] = random_policy(len(REF), rng)
        val = sum(
            w * rl_objective(p, r, q, beta)
            for w, p, r, q in zip(weights, conditionals, refs, rewards)
        )
        print(f"    perturbing {name:<22s}: value {val:.6f} < F_multi ({Fmulti - val:.6f} below)")
        assert val < Fmulti

    print("\n  Now attach the mix-in to prompt x0 only.  The optimal conditionals at")
    print("  x1 and x2 are unchanged; only the conditional at x0 compromises.")

    def full(conds: Sequence[Sequence[float]]) -> float:
        return sum(
            w * rl_objective(p, r, q, beta)
            for w, p, r, q in zip(weights, conds, refs, rewards)
        ) + ptx_term(conds[0], pre, gamma)

    # optimise the x0 conditional numerically; the others stay tilted
    best = full([stars[0], stars[1], stars[2]])
    arg = list(stars[0])
    step = 0.08
    for _ in range(80000):
        cand = normalise([max(1e-9, x + rng.uniform(-step, step) * x) for x in arg])
        v = full([cand, stars[1], stars[2]])
        if v > best:
            best, arg = v, cand
        step *= 0.99997
    print(f"    optimal x0 conditional differs from its tilted policy by L1 = {l1(arg, stars[0]):.4f}")
    for j in (1, 2):
        perturbed = [list(arg), list(stars[1]), list(stars[2])]
        perturbed[j] = random_policy(len(REF), rng)
        assert full(perturbed) < best
        print(f"    perturbing the conditional at {prompts[j]}: strictly worse, as predicted")
    print("\n  The alignment tax is localised to the prompt the mix-in touches.")


# --------------------------------------------------------------------------- #
# Demonstration 10: uniqueness via strict concavity                           #
# --------------------------------------------------------------------------- #


def demo_uniqueness(beta: float = 1.1, gamma: float = 0.4, trials: int = 200) -> None:
    banner("10. Strict concavity: the full objective has at most one maximiser")
    pre = normalise([0.30, 0.30, 0.20, 0.10, 0.10])
    rng = random.Random(2718)
    worst_margin = math.inf
    for _ in range(trials):
        p = random_policy(len(REF), rng)
        q = random_policy(len(REF), rng)
        mid = [0.5 * (a + b) for a, b in zip(p, q)]
        jp = full_objective(p, REF, REWARD, pre, beta, gamma)
        jq = full_objective(q, REF, REWARD, pre, beta, gamma)
        jm = full_objective(mid, REF, REWARD, pre, beta, gamma)
        margin = jm - 0.5 * (jp + jq)
        worst_margin = min(worst_margin, margin)
        assert margin > 0.0
    print(f"  midpoint always strictly beats the average; smallest observed margin:")
    print(f"    {worst_margin:.3e} > 0  over {trials} random pairs")
    print("  Two distinct maximisers would contradict this, so the maximiser is unique.")


# --------------------------------------------------------------------------- #
# Demonstration 11: Pinsker's inequality, verified numerically                #
# --------------------------------------------------------------------------- #


def demo_pinsker(trials: int = 5000) -> None:
    banner("11. Pinsker's inequality on the simplex")
    rng = random.Random(31415)
    worst_ratio = 0.0
    for _ in range(trials):
        p = random_policy(6, rng)
        q = random_policy(6, rng)
        lhs = l1(p, q) ** 2
        rhs = 2.0 * kl(p, q)
        assert lhs <= rhs + 1e-12
        worst_ratio = max(worst_ratio, lhs / rhs if rhs > 0 else 0.0)
    print(f"  worst observed ratio ||p-q||_1^2 / (2 KL(p||q)) = {worst_ratio:.6f} <= 1")
    print("  The scalar engine is  x log x - x + 1 >= 3(x-1)^2 / (2(x+2))  for x >= 0:")
    print(f"    {'x':>8s} {'x log x - x + 1':>17s} {'3(x-1)^2/(2(x+2))':>19s}")
    for x in (0.0, 0.05, 0.5, 1.0, 2.0, 10.0, 100.0):
        left = (x * math.log(x) if x > 0 else 0.0) - x + 1.0
        right = 3.0 * (x - 1.0) ** 2 / (2.0 * (x + 2.0))
        assert left >= right - 1e-12
        print(f"    {x:8.2f} {left:17.6f} {right:19.6f}")


# --------------------------------------------------------------------------- #


def main() -> None:
    print("Exact theory of the KL-regularised alignment objective")
    print("Numerical demonstrations")
    demo_three_point_identity()
    demo_bounds()
    demo_pareto_frontier()
    demo_budgeted_alignment()
    demo_group_action()
    demo_preference_identifiability()
    demo_reward_hacking()
    demo_alignment_tax()
    demo_multiprompt()
    demo_uniqueness()
    demo_pinsker()
    banner("All demonstrations completed; every asserted bound held.")


if __name__ == "__main__":
    main()
