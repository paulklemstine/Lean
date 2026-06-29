"""
Numerical demonstrations of the Fisher information metric on finite statistical
manifolds.

This script accompanies the formally verified theorems:

  * Fisher matrix is symmetric, positive semidefinite, positive definite.
  * Fisher = covariance of the (mean-zero) score.
  * Tensorization: Fisher information is additive over independent data.
  * Cramer-Rao lower bound and its efficiency (equality) characterization.
  * Tensorial reparametrization law  G' = J^T G J.
  * KL sandwich:  (1/2) ||p - q||_1^2  <=  KL(p||q)  <=  chi^2(p||q).
  * Bernoulli Fisher information  G = sigma'^2 / (sigma (1 - sigma)).

Everything is self-contained: only the Python standard library is used.
Run with:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core finite-model utilities
# ---------------------------------------------------------------------------

def expect(p: Sequence[float], f: Sequence[float]) -> float:
    """Expectation E_p[f] = sum_x p[x] * f[x]."""
    return sum(px * fx for px, fx in zip(p, f))


def variance(p: Sequence[float], f: Sequence[float]) -> float:
    """Variance Var_p(f) = E_p[(f - E_p[f])^2]."""
    mean = expect(p, f)
    return sum(px * (fx - mean) ** 2 for px, fx in zip(p, f))


def fisher_matrix(p: Sequence[float], score: Sequence[Sequence[float]]) -> List[List[float]]:
    """Fisher information matrix  G_ij = sum_x p[x] * score[x][i] * score[x][j].

    `score[x]` is the score vector at outcome x (length d).
    Returns a d x d matrix.
    """
    n = len(p)
    d = len(score[0]) if n else 0
    G = [[0.0 for _ in range(d)] for _ in range(d)]
    for x in range(n):
        for i in range(d):
            for j in range(d):
                G[i][j] += p[x] * score[x][i] * score[x][j]
    return G


def quad_form(G: Sequence[Sequence[float]], v: Sequence[float]) -> float:
    """Quadratic form  v^T G v = sum_ij v[i] G[i][j] v[j]."""
    return sum(v[i] * G[i][j] * v[j] for i in range(len(v)) for j in range(len(v)))


def score_mean(p: Sequence[float], score: Sequence[Sequence[float]], i: int) -> float:
    """E_p[score_i] -- should be ~0 for a valid model (mean-zero score)."""
    return sum(px * sx[i] for px, sx in zip(p, score))


# ---------------------------------------------------------------------------
# Divergences
# ---------------------------------------------------------------------------

def kl_div(p: Sequence[float], q: Sequence[float]) -> float:
    """Kullback-Leibler divergence KL(p||q) = sum_i p_i log(p_i / q_i)."""
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))


def chi_squared(p: Sequence[float], q: Sequence[float]) -> float:
    """Pearson chi-squared divergence  sum_i (p_i - q_i)^2 / q_i."""
    return sum((pi - qi) ** 2 / qi for pi, qi in zip(p, q))


def total_variation_l1(p: Sequence[float], q: Sequence[float]) -> float:
    """L1 distance ||p - q||_1 = sum_i |p_i - q_i|."""
    return sum(abs(pi - qi) for pi, qi in zip(p, q))


def fisher_form(p: Sequence[float], v: Sequence[float], w: Sequence[float]) -> float:
    """Categorical Fisher form  g_p(v, w) = sum_i v_i w_i / p_i."""
    return sum(vi * wi / pi for pi, vi, wi in zip(p, v, w))


# ---------------------------------------------------------------------------
# Demo 1: Metric axioms (symmetry, PSD, PD) on a 3-outcome / 2-parameter model
# ---------------------------------------------------------------------------

def demo_metric_axioms() -> None:
    print("=" * 72)
    print("DEMO 1: The Fisher matrix is a Riemannian metric tensor")
    print("=" * 72)
    # A toy model on 3 outcomes with 2 parameters; scores chosen mean-zero.
    p = [0.2, 0.5, 0.3]
    # raw score directions, then center each component to enforce mean-zero score
    raw = [[1.0, 0.5], [-0.5, 1.0], [0.0, -2.0]]
    score: List[List[float]] = []
    means = [score_mean(p, raw, i) for i in range(2)]
    for sx in raw:
        score.append([sx[i] - means[i] for i in range(2)])

    for i in range(2):
        print(f"  mean-zero check: E[score_{i}] = {score_mean(p, score, i): .3e}")

    G = fisher_matrix(p, score)
    print(f"  Fisher matrix G = {G}")
    print(f"  Symmetry  G01 - G10 = {G[0][1] - G[1][0]: .3e}")

    # Positive semidefinite / definite: test the quadratic form on random-ish v's.
    test_vs = [[1.0, 0.0], [0.0, 1.0], [1.0, -1.0], [2.0, 3.0]]
    for v in test_vs:
        qf = quad_form(G, v)
        # Compare to the collapsed sum-of-squares form.
        collapsed = sum(p[x] * (sum(v[i] * score[x][i] for i in range(2))) ** 2
                        for x in range(3))
        print(f"  v={v}:  v^T G v = {qf: .5f}   sum p (v.s)^2 = {collapsed: .5f}   (>=0: {qf >= -1e-12})")
    print()


# ---------------------------------------------------------------------------
# Demo 2: Fisher = covariance of the score
# ---------------------------------------------------------------------------

def demo_score_covariance() -> None:
    print("=" * 72)
    print("DEMO 2: Fisher = covariance of the (mean-zero) score")
    print("=" * 72)
    p = [0.4, 0.35, 0.25]
    raw = [[1.0, -1.0], [-2.0, 0.5], [1.0, 1.0]]
    means = [score_mean(p, raw, i) for i in range(2)]
    score = [[sx[i] - means[i] for i in range(2)] for sx in raw]
    G = fisher_matrix(p, score)
    for i in range(2):
        for j in range(2):
            cov = (sum(p[x] * score[x][i] * score[x][j] for x in range(3))
                   - score_mean(p, score, i) * score_mean(p, score, j))
            print(f"  G[{i}][{j}] = {G[i][j]: .5f}   cov(s_{i}, s_{j}) = {cov: .5f}")
    print()


# ---------------------------------------------------------------------------
# Demo 3: Tensorization (additivity over independent data)
# ---------------------------------------------------------------------------

def product_model(
    p: Sequence[float], scoreP: Sequence[Sequence[float]],
    q: Sequence[float], scoreQ: Sequence[Sequence[float]],
) -> Tuple[List[float], List[List[float]]]:
    """Independent product of two models sharing a parameter vector."""
    d = len(scoreP[0])
    pr: List[float] = []
    sc: List[List[float]] = []
    for x in range(len(p)):
        for y in range(len(q)):
            pr.append(p[x] * q[y])
            sc.append([scoreP[x][i] + scoreQ[y][i] for i in range(d)])
    return pr, sc


def demo_tensorization() -> None:
    print("=" * 72)
    print("DEMO 3: Tensorization  G(M x N) = G(M) + G(N)")
    print("=" * 72)
    p = [0.3, 0.7]
    raw_p = [[1.5], [-0.5]]
    mp = [score_mean(p, raw_p, 0)]
    sp = [[r[0] - mp[0]] for r in raw_p]
    q = [0.25, 0.4, 0.35]
    raw_q = [[2.0], [-1.0], [0.5]]
    mq = [score_mean(q, raw_q, 0)]
    sq = [[r[0] - mq[0]] for r in raw_q]

    GM = fisher_matrix(p, sp)
    GN = fisher_matrix(q, sq)
    pr, sc = product_model(p, sp, q, sq)
    GMN = fisher_matrix(pr, sc)
    print(f"  G(M)       = {GM[0][0]: .5f}")
    print(f"  G(N)       = {GN[0][0]: .5f}")
    print(f"  G(M x N)   = {GMN[0][0]: .5f}")
    print(f"  G(M)+G(N)  = {GM[0][0] + GN[0][0]: .5f}")

    # i.i.d. (k = 2): two copies of M carry twice the information.
    pr2, sc2 = product_model(p, sp, p, sp)
    GMM = fisher_matrix(pr2, sc2)
    print(f"  i.i.d. k=2: G(M x M) = {GMM[0][0]: .5f}   2*G(M) = {2 * GM[0][0]: .5f}")
    print()


# ---------------------------------------------------------------------------
# Demo 4: Cramer-Rao bound and efficiency (equality case)
# ---------------------------------------------------------------------------

def demo_cramer_rao() -> None:
    print("=" * 72)
    print("DEMO 4: Cramer-Rao lower bound and efficiency")
    print("=" * 72)
    p = [0.2, 0.5, 0.3]
    raw = [[1.0], [-0.6], [0.4]]
    m = [score_mean(p, raw, 0)]
    s = [[r[0] - m[0]] for r in raw]   # mean-zero score (1 parameter)
    s0 = [sx[0] for sx in s]
    G00 = fisher_matrix(p, s)[0][0]

    # An *inefficient* statistic: arbitrary T.
    T = [0.0, 1.0, 4.0]
    psi_prime = expect(p, [T[x] * s0[x] for x in range(3)])  # E[T * score]
    var_T = variance(p, T)
    bound = psi_prime ** 2 / G00
    print("  Generic statistic T:")
    print(f"    psi' = E[T s] = {psi_prime: .5f},  Var(T) = {var_T: .5f},  G = {G00: .5f}")
    print(f"    CR bound psi'^2/G = {bound: .5f}  <=  Var(T) = {var_T: .5f}   "
          f"(holds: {bound <= var_T + 1e-12})")
    print(f"    efficiency residual Var - bound = {var_T - bound: .5f} (>= 0)")

    # An *efficient* statistic: T - E[T] proportional to the score => equality.
    c = 2.7
    meanT = 5.0
    T_eff = [meanT + c * s0[x] for x in range(3)]
    psi_prime_e = expect(p, [T_eff[x] * s0[x] for x in range(3)])
    var_Te = variance(p, T_eff)
    bound_e = psi_prime_e ** 2 / G00
    print("  Efficient statistic  T - E[T] = c * score:")
    print(f"    Var(T) = {var_Te: .5f},  CR bound = {bound_e: .5f},  "
          f"gap = {var_Te - bound_e: .3e}  (=> equality)")
    print()


# ---------------------------------------------------------------------------
# Demo 5: Tensorial reparametrization law  G' = J^T G J
# ---------------------------------------------------------------------------

def matmul(A: Sequence[Sequence[float]], B: Sequence[Sequence[float]]) -> List[List[float]]:
    return [[sum(A[i][k] * B[k][j] for k in range(len(B))) for j in range(len(B[0]))]
            for i in range(len(A))]


def transpose(A: Sequence[Sequence[float]]) -> List[List[float]]:
    return [[A[i][j] for i in range(len(A))] for j in range(len(A[0]))]


def demo_reparam() -> None:
    print("=" * 72)
    print("DEMO 5: Tensorial transformation law  G' = J^T G J")
    print("=" * 72)
    p = [0.3, 0.45, 0.25]
    raw = [[1.0, 0.0], [-1.0, 1.0], [0.5, -1.0]]
    means = [score_mean(p, raw, i) for i in range(2)]
    s = [[r[i] - means[i] for i in range(2)] for r in raw]
    G = fisher_matrix(p, s)

    # New coordinates eta in R^2 with Jacobian J (d' x d) = (2 x 2).
    J = [[2.0, 1.0], [0.0, 3.0]]
    # Transformed scores  s'[x][a] = sum_i J[a][i] s[x][i].
    s_new = [[sum(J[a][i] * s[x][i] for i in range(2)) for a in range(2)]
             for x in range(3)]
    G_new = fisher_matrix(p, s_new)
    JTGJ = matmul(matmul(J, G), transpose(J))
    print(f"  G          = {G}")
    print(f"  G' (direct)= {G_new}")
    print(f"  J G J^T     = {JTGJ}")
    maxdiff = max(abs(G_new[a][b] - JTGJ[a][b]) for a in range(2) for b in range(2))
    print(f"  max |G' - J G J^T| = {maxdiff: .3e}  (congruence law holds)")
    print()


# ---------------------------------------------------------------------------
# Demo 6: The KL sandwich  (1/2)||p-q||_1^2 <= KL(p||q) <= chi^2(p||q)
# ---------------------------------------------------------------------------

def demo_kl_sandwich() -> None:
    print("=" * 72)
    print("DEMO 6: KL sandwich  (1/2)||p-q||_1^2 <= KL <= chi^2 = Fisher form")
    print("=" * 72)
    pairs: List[Tuple[List[float], List[float]]] = [
        ([0.5, 0.3, 0.2], [0.4, 0.4, 0.2]),
        ([0.7, 0.2, 0.1], [0.5, 0.25, 0.25]),
        ([0.34, 0.33, 0.33], [0.30, 0.30, 0.40]),
    ]
    for p, q in pairs:
        tv = total_variation_l1(p, q)
        lower = 0.5 * tv ** 2
        kl = kl_div(p, q)
        chi2 = chi_squared(p, q)
        diff = [p[i] - q[i] for i in range(len(p))]
        gform = fisher_form(q, diff, diff)
        print(f"  p={p}  q={q}")
        print(f"    (1/2)||p-q||_1^2 = {lower: .6f}")
        print(f"    KL(p||q)         = {kl: .6f}")
        print(f"    chi^2(p||q)      = {chi2: .6f}   g_q(p-q,p-q) = {gform: .6f}")
        ok = lower <= kl + 1e-12 <= chi2 + 1e-12
        print(f"    sandwich holds: {ok}")
    print()


# ---------------------------------------------------------------------------
# Demo 7: Bernoulli Fisher information in closed form
# ---------------------------------------------------------------------------

def bernoulli_fisher(sigma: float, dsigma: float) -> float:
    """Closed-form Bernoulli Fisher information  sigma'^2 / (sigma (1 - sigma))."""
    return dsigma ** 2 / (sigma * (1.0 - sigma))


def demo_bernoulli() -> None:
    print("=" * 72)
    print("DEMO 7: Bernoulli Fisher information  G = sigma'^2 / (sigma(1-sigma))")
    print("=" * 72)
    for sigma in [0.1, 0.3, 0.5, 0.7, 0.9]:
        dsigma = 1.0  # natural parametrization sigma(theta) = theta
        # direct two-outcome computation:
        p = [sigma, 1.0 - sigma]
        s = [[dsigma / sigma], [-dsigma / (1.0 - sigma)]]
        G_direct = fisher_matrix(p, s)[0][0]
        G_closed = bernoulli_fisher(sigma, dsigma)
        print(f"  sigma={sigma:.2f}:  direct G = {G_direct: .5f}   "
              f"closed form = {G_closed: .5f}   "
              f"1/G (CR bound) = {1.0 / G_closed: .5f}")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_metric_axioms()
    demo_score_covariance()
    demo_tensorization()
    demo_cramer_rao()
    demo_reparam()
    demo_kl_sandwich()
    demo_bernoulli()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
