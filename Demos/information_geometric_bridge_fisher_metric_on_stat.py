"""
demo.py — Numerical demonstrations for:

    Information-Geometric Bridge: the Fisher Metric on Statistical Manifolds

This self-contained script illustrates, with concrete numbers, the main results
of the formal development:

  * Fisher information matrix  G[i][j] = sum_x p[x] * s[x][i] * s[x][j]
  * Symmetry of G                                  (Theorem: fisher_symm)
  * Quadratic-form = sum of squares identity       (Theorem: fisher_quadForm_eq)
  * Positive semidefiniteness                      (Theorem: fisher_posSemidef)
  * Positive definiteness under nondegeneracy      (Theorem: fisher_posDef)
  * Fisher = covariance of the (zero-mean) score   (Theorem: fisher_eq_score_cov)
  * Fisher = -E[Hessian of log-likelihood]         (Theorem: fisher_eq_neg_expected_hessian)
  * KL(p||p) = 0 and Gibbs' inequality KL >= 0     (Theorems: KL_self_zero, KL_nonneg)
  * Closed-form Bernoulli Fisher information        (bernoulli_fisher): 1/(s(1-s))

No external dependencies (pure Python standard library).
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence


# ----------------------------------------------------------------------------
# Core constructions
# ----------------------------------------------------------------------------

def fisher_matrix(
    p: Sequence[float],
    score: Sequence[Sequence[float]],
) -> List[List[float]]:
    """Fisher information matrix  G[i][j] = sum_x p[x] * score[x][i] * score[x][j].

    Args:
        p:     probability vector of length n (entries > 0, summing to 1).
        score: n-by-d table; score[x][i] is the i-th score component at outcome x.

    Returns:
        The d-by-d Fisher information matrix as a list of lists.
    """
    n = len(p)
    d = len(score[0]) if n > 0 else 0
    G = [[0.0 for _ in range(d)] for _ in range(d)]
    for i in range(d):
        for j in range(d):
            G[i][j] = sum(p[x] * score[x][i] * score[x][j] for x in range(n))
    return G


def quadratic_form(G: Sequence[Sequence[float]], v: Sequence[float]) -> float:
    """Evaluate the Fisher quadratic form  sum_i sum_j v[i] * G[i][j] * v[j]."""
    d = len(v)
    return sum(v[i] * G[i][j] * v[j] for i in range(d) for j in range(d))


def quadratic_form_sumsquares(
    p: Sequence[float],
    score: Sequence[Sequence[float]],
    v: Sequence[float],
) -> float:
    """Right-hand side of fisher_quadForm_eq:  sum_x p[x] * (sum_i v[i]*score[x][i])^2."""
    n = len(p)
    d = len(v)
    return sum(
        p[x] * (sum(v[i] * score[x][i] for i in range(d))) ** 2
        for x in range(n)
    )


def score_mean(p: Sequence[float], score: Sequence[Sequence[float]]) -> List[float]:
    """Mean score  E_p[score_i] = sum_x p[x]*score[x][i]  (should be ~0 for a model)."""
    n = len(p)
    d = len(score[0]) if n > 0 else 0
    return [sum(p[x] * score[x][i] for x in range(n)) for i in range(d)]


def score_covariance(
    p: Sequence[float],
    score: Sequence[Sequence[float]],
) -> List[List[float]]:
    """Covariance of the score:  E[s_i s_j] - E[s_i] E[s_j]  (fisher_eq_score_cov)."""
    n = len(p)
    d = len(score[0]) if n > 0 else 0
    m = score_mean(p, score)
    C = [[0.0 for _ in range(d)] for _ in range(d)]
    for i in range(d):
        for j in range(d):
            e_ij = sum(p[x] * score[x][i] * score[x][j] for x in range(n))
            C[i][j] = e_ij - m[i] * m[j]
    return C


def kl_divergence(p: Sequence[float], q: Sequence[float]) -> float:
    """Kullback-Leibler divergence  KL(p||q) = sum_x p[x] * log(p[x]/q[x])."""
    return sum(px * math.log(px / qx) for px, qx in zip(p, q))


def bernoulli_fisher(s: float) -> float:
    """Closed-form Fisher information of the Bernoulli(s) model: 1/(s*(1-s))."""
    return 1.0 / (s * (1.0 - s))


# ----------------------------------------------------------------------------
# A concrete model: a (re-parametrized) categorical / Bernoulli family
# ----------------------------------------------------------------------------

def bernoulli_scores(s: float) -> List[List[float]]:
    """Score table for the Bernoulli model with success probability s.

    Outcomes: x=0 (failure), x=1 (success). One parameter (d=1).
    With p(1)=s, p(0)=1-s, the score d/ds log p is:
        outcome 1: +1/s
        outcome 0: -1/(1-s)
    These have zero mean: s*(1/s) + (1-s)*(-1/(1-s)) = 1 - 1 = 0.
    """
    return [[-1.0 / (1.0 - s)], [1.0 / s]]


def bernoulli_probs(s: float) -> List[float]:
    """Probability vector [p(0), p(1)] = [1-s, s]."""
    return [1.0 - s, s]


# ----------------------------------------------------------------------------
# Numerical curvature check: Fisher = second derivative of KL at the diagonal
# ----------------------------------------------------------------------------

def kl_between_bernoulli(s: float, t: float) -> float:
    """KL( Bernoulli(s) || Bernoulli(t) )."""
    return kl_divergence(bernoulli_probs(s), bernoulli_probs(t))


def numeric_second_derivative(
    f: Callable[[float], float], x: float, h: float = 1e-4
) -> float:
    """Central second-difference approximation of f''(x)."""
    return (f(x + h) - 2.0 * f(x) + f(x - h)) / (h * h)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_metric_axioms() -> None:
    print("=" * 70)
    print("DEMO 1: Fisher matrix is a Riemannian metric tensor")
    print("=" * 70)
    # A 3-outcome, 2-parameter toy model with a hand-built zero-mean score.
    p = [0.2, 0.5, 0.3]
    # Build raw scores then center each component so E_p[score]=0 (model regularity).
    raw = [[1.0, -2.0], [0.5, 1.0], [-1.0, 0.4]]
    means = [sum(p[x] * raw[x][i] for x in range(3)) for i in range(2)]
    score = [[raw[x][i] - means[i] for i in range(2)] for x in range(3)]

    G = fisher_matrix(p, score)
    print(f"Fisher matrix G = {G}")
    print(f"Symmetry  G[0][1] == G[1][0]?  {math.isclose(G[0][1], G[1][0])}")

    for v in ([1.0, 0.0], [0.3, -0.7], [-1.2, 2.1]):
        qf = quadratic_form(G, v)
        ss = quadratic_form_sumsquares(p, score, v)
        print(f"  v={v}:  v^T G v = {qf:.6f}   sum_x p*(score.v)^2 = {ss:.6f}"
              f"   match={math.isclose(qf, ss)}   nonneg={qf >= -1e-12}")
    print()


def demo_score_covariance() -> None:
    print("=" * 70)
    print("DEMO 2: Fisher = covariance of the (zero-mean) score")
    print("=" * 70)
    p = [0.25, 0.4, 0.35]
    raw = [[2.0, 0.5], [-1.0, 1.5], [0.3, -2.0]]
    means = [sum(p[x] * raw[x][i] for x in range(3)) for i in range(2)]
    score = [[raw[x][i] - means[i] for i in range(2)] for x in range(3)]
    print(f"Mean score (should be ~0): {score_mean(p, score)}")
    G = fisher_matrix(p, score)
    C = score_covariance(p, score)
    print(f"Fisher matrix   G = {G}")
    print(f"Score covariance C = {C}")
    ok = all(math.isclose(G[i][j], C[i][j], abs_tol=1e-12)
             for i in range(2) for j in range(2))
    print(f"G == Cov(score)?  {ok}")
    print()


def demo_kl() -> None:
    print("=" * 70)
    print("DEMO 3: Kullback-Leibler divergence: self-zero and Gibbs (>= 0)")
    print("=" * 70)
    p = [0.1, 0.6, 0.3]
    print(f"KL(p||p) = {kl_divergence(p, p):.3e}   (Theorem KL_self_zero -> 0)")
    random.seed(0)
    worst = math.inf
    for _ in range(100000):
        a = [random.random() + 1e-3 for _ in range(3)]
        b = [random.random() + 1e-3 for _ in range(3)]
        a = [x / sum(a) for x in a]
        b = [x / sum(b) for x in b]
        worst = min(worst, kl_divergence(a, b))
    print(f"Minimum KL over 100000 random pairs = {worst:.3e}   (Gibbs: >= 0)")
    print()


def demo_bernoulli_curvature() -> None:
    print("=" * 70)
    print("DEMO 4: Bernoulli Fisher = curvature of KL = 1/(s(1-s))")
    print("=" * 70)
    print(f"{'s':>6} | {'1/(s(1-s))':>14} | {'d^2/dt^2 KL(s||t)|t=s':>22} | "
          f"{'E[score^2]':>12}")
    print("-" * 64)
    for s in (0.1, 0.25, 0.5, 0.75, 0.9, 0.98):
        closed = bernoulli_fisher(s)
        curv = numeric_second_derivative(lambda t: kl_between_bernoulli(s, t), s)
        e_sq = fisher_matrix(bernoulli_probs(s), bernoulli_scores(s))[0][0]
        print(f"{s:>6.2f} | {closed:>14.4f} | {curv:>22.4f} | {e_sq:>12.4f}")
    print("\nThe fair coin s=0.5 minimizes information (flattest point); the metric")
    print("diverges toward s->0 and s->1 (near-certain coins are far apart).")
    print()


def demo_neg_expected_hessian() -> None:
    print("=" * 70)
    print("DEMO 5: Fisher = -E[Hessian of log-likelihood] (two forms identity)")
    print("=" * 70)
    # For Bernoulli(s), parameter t, log-likelihoods:
    #   x=1: log t          -> d^2/dt^2 = -1/t^2
    #   x=0: log(1-t)       -> d^2/dt^2 = -1/(1-t)^2
    # -E[hess] = s*(1/s^2) + (1-s)*(1/(1-s)^2) = 1/s + 1/(1-s) = 1/(s(1-s)).
    for s in (0.2, 0.5, 0.8):
        neg_e_hess = s * (1.0 / s ** 2) + (1.0 - s) * (1.0 / (1.0 - s) ** 2)
        print(f"  s={s}:  -E[hess log p] = {neg_e_hess:.6f}   "
              f"1/(s(1-s)) = {bernoulli_fisher(s):.6f}   "
              f"match={math.isclose(neg_e_hess, bernoulli_fisher(s))}")
    print()


def main() -> None:
    demo_metric_axioms()
    demo_score_covariance()
    demo_kl()
    demo_bernoulli_curvature()
    demo_neg_expected_hessian()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
