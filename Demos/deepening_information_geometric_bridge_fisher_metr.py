"""
Numerical demonstrations of the Information-Geometric Bridge:
the Fisher information metric, tensorization (additivity over independent data),
the Cramer-Rao lower bound, and the tensorial reparametrization law.

All routines operate on finite statistical models given as plain Python lists.
A model is specified by:
  - p:     probabilities p[x]            (list of |S| positive floats summing to 1)
  - score: scores       s[x][i]          (list of |S| lists, each of length d)
such that the regularity condition  sum_x p[x] * s[x][i] = 0  holds for every i.

Everything is self-contained: no third-party dependencies.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Sequence, Tuple


# ----------------------------------------------------------------------------
# Core information-geometric quantities
# ----------------------------------------------------------------------------

def fisher_matrix(p: Sequence[float], score: Sequence[Sequence[float]]) -> List[List[float]]:
    """Fisher information matrix  G[i][j] = sum_x p[x] * s[x][i] * s[x][j]."""
    n = len(p)
    d = len(score[0]) if n else 0
    G = [[0.0 for _ in range(d)] for _ in range(d)]
    for x in range(n):
        for i in range(d):
            for j in range(d):
                G[i][j] += p[x] * score[x][i] * score[x][j]
    return G


def quad_form(G: Sequence[Sequence[float]], v: Sequence[float]) -> float:
    """The quadratic form v^T G v = sum_{i,j} v[i] G[i][j] v[j]."""
    return sum(v[i] * G[i][j] * v[j] for i in range(len(v)) for j in range(len(v)))


def expect(p: Sequence[float], f: Sequence[float]) -> float:
    """Expectation E[f] = sum_x p[x] f[x]."""
    return sum(p[x] * f[x] for x in range(len(p)))


def variance(p: Sequence[float], f: Sequence[float]) -> float:
    """Variance Var(f) = E[(f - E[f])^2]."""
    mu = expect(p, f)
    return sum(p[x] * (f[x] - mu) ** 2 for x in range(len(p)))


def score_mean(p: Sequence[float], score: Sequence[Sequence[float]], i: int) -> float:
    """E[score_i]; should be ~0 for a regular model."""
    return sum(p[x] * score[x][i] for x in range(len(p)))


# ----------------------------------------------------------------------------
# Tensorization: independent product of two models
# ----------------------------------------------------------------------------

def product_model(
    pM: Sequence[float], scoreM: Sequence[Sequence[float]],
    pN: Sequence[float], scoreN: Sequence[Sequence[float]],
) -> Tuple[List[float], List[List[float]]]:
    """Build the independent product model on S x S':
       p((x,y)) = pM[x]*pN[y],  score((x,y),i) = scoreM[x][i] + scoreN[y][i]."""
    d = len(scoreM[0])
    p: List[float] = []
    score: List[List[float]] = []
    for x in range(len(pM)):
        for y in range(len(pN)):
            p.append(pM[x] * pN[y])
            score.append([scoreM[x][i] + scoreN[y][i] for i in range(d)])
    return p, score


def matrix_add(A: Sequence[Sequence[float]], B: Sequence[Sequence[float]]) -> List[List[float]]:
    return [[A[i][j] + B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


# ----------------------------------------------------------------------------
# Cramer-Rao bound
# ----------------------------------------------------------------------------

def cramer_rao_report(
    p: Sequence[float], score: Sequence[Sequence[float]], T: Sequence[float], i: int = 0
) -> dict:
    """Single-parameter Cramer-Rao certificate for statistic T w.r.t. parameter i.

    Returns the mean psi = E[T], the derivative psi' = Cov(T, score_i),
    the variance, the Fisher information G_ii, the bound psi'^2 / G_ii,
    and the (nonnegative) slack."""
    psi = expect(p, T)
    centered = [T[x] - psi for x in range(len(p))]
    psi_prime = sum(p[x] * centered[x] * score[x][i] for x in range(len(p)))
    var = variance(p, T)
    G = fisher_matrix(p, score)
    Gii = G[i][i]
    bound = psi_prime ** 2 / Gii if Gii > 0 else float("inf")
    return {
        "psi": psi,
        "psi_prime": psi_prime,
        "variance": var,
        "fisher": Gii,
        "cr_bound": bound,
        "slack": var - bound,
    }


# ----------------------------------------------------------------------------
# Reparametrization congruence  G' = J^T G J
# ----------------------------------------------------------------------------

def congruence(J: Sequence[Sequence[float]], G: Sequence[Sequence[float]]) -> List[List[float]]:
    """Compute J^T G J  (J indexed J[a][i] = d phi_? ; here J[a][i] = dphi/ as in paper)."""
    d = len(G)
    # G'[a][b] = sum_{i,j} J[a][i] G[i][j] J[b][j]
    out = [[0.0 for _ in range(d)] for _ in range(d)]
    for a in range(d):
        for b in range(d):
            out[a][b] = sum(J[a][i] * G[i][j] * J[b][j] for i in range(d) for j in range(d))
    return out


# ----------------------------------------------------------------------------
# Model builders
# ----------------------------------------------------------------------------

def bernoulli_model(theta: float) -> Tuple[List[float], List[List[float]]]:
    """Bernoulli model with identity link sigma(theta)=theta, one parameter.
       p(0)=theta, p(1)=1-theta; score(0)=1/theta, score(1)=-1/(1-theta)."""
    p = [theta, 1.0 - theta]
    score = [[1.0 / theta], [-1.0 / (1.0 - theta)]]
    return p, score


def categorical_model(probs: Sequence[float]) -> Tuple[List[float], List[List[float]]]:
    """Full categorical model on k outcomes with the natural (mean-parameter) score.
       Using d = k-1 free parameters theta_i = p_i (i<k-1), p_{k-1}=1-sum.
       score_i(x) = [x==i]/p_i - [x==k-1]/p_{k-1}, which is mean-zero."""
    k = len(probs)
    d = k - 1
    last = probs[k - 1]
    score: List[List[float]] = []
    for x in range(k):
        row = []
        for i in range(d):
            val = (1.0 if x == i else 0.0) / probs[i] - (1.0 if x == k - 1 else 0.0) / last
            row.append(val)
        score.append(row)
    return list(probs), score


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_metric_axioms() -> None:
    print("=" * 70)
    print("DEMO 1:  The Fisher matrix is a Riemannian metric (symm + pos-def)")
    print("=" * 70)
    p, score = categorical_model([0.2, 0.3, 0.5])
    G = fisher_matrix(p, score)
    print("Categorical model p = [0.2, 0.3, 0.5], d = 2 free parameters")
    print("Fisher matrix G =")
    for row in G:
        print("   ", ["%.4f" % v for v in row])
    print("Symmetry  G[0][1]-G[1][0] = %.2e" % (G[0][1] - G[1][0]))
    for v in ([1.0, 0.0], [0.0, 1.0], [1.0, -1.0], [2.0, 3.0]):
        print("  v=%-9s  vᵀGv = %.5f  (must be > 0)" % (str(v), quad_form(G, v)))
    print()


def demo_tensorization() -> None:
    print("=" * 70)
    print("DEMO 2:  Tensorization — information adds over independent data")
    print("=" * 70)
    pM, sM = categorical_model([0.3, 0.7])
    pN, sN = categorical_model([0.3, 0.7])
    GM = fisher_matrix(pM, sM)
    GN = fisher_matrix(pN, sN)
    pP, sP = product_model(pM, sM, pN, sN)
    GP = fisher_matrix(pP, sP)
    Gsum = matrix_add(GM, GN)
    print("G_M       =", [["%.4f" % v for v in r] for r in GM])
    print("G_N       =", [["%.4f" % v for v in r] for r in GN])
    print("G_(M x N) =", [["%.4f" % v for v in r] for r in GP])
    print("G_M + G_N =", [["%.4f" % v for v in r] for r in Gsum])
    err = max(abs(GP[i][j] - Gsum[i][j]) for i in range(len(GP)) for j in range(len(GP)))
    print("max |G_(MxN) - (G_M+G_N)| = %.2e" % err)
    print("i.i.d. doubling: G_(MxM) = 2 G_M ?  ratio = %.4f" % (GP[0][0] / GM[0][0]))
    print()


def demo_cramer_rao() -> None:
    print("=" * 70)
    print("DEMO 3:  The Cramer-Rao lower bound and efficiency")
    print("=" * 70)
    theta = 0.3
    p, score = bernoulli_model(theta)
    # Unbiased estimator of theta from one draw: T(0)=1 (success), T(1)=0.
    T = [1.0, 0.0]
    rep = cramer_rao_report(p, score, T, i=0)
    print("Bernoulli(theta=%.2f), unbiased estimator T = [1, 0]" % theta)
    for k, v in rep.items():
        print("   %-10s = %.6f" % (k, v))
    print("   theoretical 1/G = theta(1-theta) = %.6f" % (theta * (1 - theta)))
    print("   -> variance EQUALS the bound: the estimator is EFFICIENT.")
    print()
    # N i.i.d. samples: variance should scale like theta(1-theta)/N.
    print("   N i.i.d. samples: optimal variance = theta(1-theta)/N")
    GM = fisher_matrix(p, score)[0][0]
    for N in (1, 2, 5, 10):
        print("     N=%2d   N*G = %.4f   1/(N*G) = %.6f   theta(1-theta)/N = %.6f"
              % (N, N * GM, 1.0 / (N * GM), theta * (1 - theta) / N))
    print()


def demo_reparam() -> None:
    print("=" * 70)
    print("DEMO 4:  Tensorial law  G' = Jᵀ G J  (G is a (0,2)-tensor)")
    print("=" * 70)
    p, score = categorical_model([0.25, 0.25, 0.5])
    G = fisher_matrix(p, score)
    # A change of coordinates with Jacobian J.
    J = [[2.0, 1.0], [0.0, 3.0]]
    # New scores: s'_a = sum_i J[a][i] s_i.
    score2 = [[sum(J[a][i] * score[x][i] for i in range(2)) for a in range(2)]
              for x in range(len(p))]
    G_direct = fisher_matrix(p, score2)
    G_congr = congruence(J, G)
    print("G          =", [["%.4f" % v for v in r] for r in G])
    print("Jᵀ G J     =", [["%.4f" % v for v in r] for r in G_congr])
    print("G' direct  =", [["%.4f" % v for v in r] for r in G_direct])
    err = max(abs(G_direct[i][j] - G_congr[i][j]) for i in range(2) for j in range(2))
    print("max |G'_direct - JᵀGJ| = %.2e" % err)
    print()


def main() -> None:
    demo_metric_axioms()
    demo_tensorization()
    demo_cramer_rao()
    demo_reparam()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()


"""
Visualization: the Fisher information of the Bernoulli family and the
Cramer-Rao precision floor it implies.

Produces a two-panel figure:
  (left)  Fisher information G(theta) = 1/(theta(1-theta)) over (0,1);
  (right) the Cramer-Rao floor on the variance of an unbiased estimator,
          1/(N*G(theta)) = theta(1-theta)/N, for several sample sizes N.

Requires matplotlib.  Run:  python visualize.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def bernoulli_fisher(theta: float) -> float:
    """Fisher information of the identity-link Bernoulli model."""
    return 1.0 / (theta * (1.0 - theta))


def main() -> None:
    thetas: List[float] = [i / 200.0 for i in range(1, 200)]
    G: List[float] = [bernoulli_fisher(t) for t in thetas]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(thetas, G, color="crimson", lw=2)
    ax1.set_title("Fisher information of Bernoulli(theta)")
    ax1.set_xlabel("theta")
    ax1.set_ylabel("G(theta) = 1 / (theta(1-theta))")
    ax1.set_ylim(0, 50)
    ax1.grid(alpha=0.3)
    ax1.annotate("information is largest\nnear theta=0 or 1",
                 xy=(0.05, 21), xytext=(0.25, 38),
                 arrowprops=dict(arrowstyle="->"))

    for N in (1, 2, 5, 20):
        floor = [t * (1.0 - t) / N for t in thetas]
        ax2.plot(thetas, floor, lw=2, label=f"N = {N}")
    ax2.set_title("Cramer-Rao floor: min Var = theta(1-theta)/N")
    ax2.set_xlabel("theta")
    ax2.set_ylabel("minimum achievable variance")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.suptitle("More data, more information, lower variance floor", fontsize=14)
    fig.tight_layout()
    fig.savefig("fisher_cramer_rao.png", dpi=140)
    print("Saved fisher_cramer_rao.png")


if __name__ == "__main__":
    main()
