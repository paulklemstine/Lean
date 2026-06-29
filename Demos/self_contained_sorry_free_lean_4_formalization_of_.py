"""
demo.py — Numerical demonstrations of the finite algebra of softmax policy
gradients: score identities, Fisher geometry, and optimal baselines.

This script is fully self-contained (Python standard library only). It
numerically verifies every theorem from the accompanying paper:

  * softmaxPolicy_pos          : softmax probabilities are strictly positive
  * softmaxPolicy_sum_one      : softmax probabilities sum to one
  * softmaxScore_expect_zero   : E_pi[psi_j] = 0   (REINFORCE / log-derivative)
  * fisherInfo_eq              : F_{jk} = pi_j*[j=k] - pi_j*pi_k
  * fisherInfo_symm            : F is symmetric
  * fisherInfo_psd             : v^T F v = E_pi[(<v,psi>)^2] >= 0
  * baseline_unbiased          : E_pi[(R-b)s] = E_pi[R s]
  * secondMoment_quadratic     : M(b) = A b^2 - 2B b + C
  * variance_reduction_amount  : M(b) - M(b*) = A (b - b*)^2
  * optimal_baseline_min       : b* = E_pi[R s^2]/E_pi[s^2] minimizes M
  * optimal_baseline_strict    : b* is the unique minimizer

Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, List


# ----------------------------------------------------------------------------
# Core definitions (everything inlined; no external dependencies)
# ----------------------------------------------------------------------------

def softmax_policy(z: List[float]) -> List[float]:
    """softmaxPolicy: pi_j = exp(z_j) / sum_k exp(z_k).

    Uses the standard max-shift for numerical stability (mathematically the
    identity transform, since exp(z_j - m)/sum exp(z_k - m) = exp(z_j)/sum exp(z_k)).
    """
    m = max(z)
    exps = [math.exp(zi - m) for zi in z]
    total = sum(exps)
    return [e / total for e in exps]


def expect_val(p: List[float], f: List[float]) -> float:
    """expectVal: E_p[f] = sum_a p_a * f_a (a finite weighted sum)."""
    return sum(pa * fa for pa, fa in zip(p, f))


def softmax_score(pi: List[float], j: int) -> List[float]:
    """softmaxScore: psi_j(a) = [a == j] - pi_j, as a vector over actions a."""
    return [(1.0 if a == j else 0.0) - pi[j] for a in range(len(pi))]


def fisher_info(pi: List[float]) -> List[List[float]]:
    """fisherInfo by definition: F_{jk} = E_pi[ psi_j * psi_k ]."""
    n = len(pi)
    F = [[0.0] * n for _ in range(n)]
    for j in range(n):
        psi_j = softmax_score(pi, j)
        for k in range(n):
            psi_k = softmax_score(pi, k)
            prod = [psi_j[a] * psi_k[a] for a in range(n)]
            F[j][k] = expect_val(pi, prod)
    return F


def fisher_info_closed_form(pi: List[float]) -> List[List[float]]:
    """fisherInfo_eq closed form: F_{jk} = pi_j*[j=k] - pi_j*pi_k."""
    n = len(pi)
    return [
        [pi[j] * (1.0 if j == k else 0.0) - pi[j] * pi[k] for k in range(n)]
        for j in range(n)
    ]


def quadratic_form(F: List[List[float]], v: List[float]) -> float:
    """v^T F v = sum_{j,k} v_j F_{jk} v_k."""
    n = len(v)
    return sum(v[j] * F[j][k] * v[k] for j in range(n) for k in range(n))


def fisher_quadratic_via_variance(pi: List[float], v: List[float]) -> float:
    """Algorithm A: v^T F v realized as E_pi[(<v, psi(a)>)^2], O(n).

    The directional score is X(a) = sum_j v_j psi_j(a) = v_a - <v, pi>.
    """
    vp = expect_val(pi, v)  # <v, pi>
    X = [v[a] - vp for a in range(len(pi))]
    return expect_val(pi, [xa * xa for xa in X])


def second_moment(pi: List[float], R: List[float], s: List[float], b: float) -> float:
    """secondMoment: M(b) = E_pi[((R - b) s)^2]."""
    g = [(R[a] - b) * s[a] for a in range(len(pi))]
    return expect_val(pi, [ga * ga for ga in g])


def abc_coefficients(pi: List[float], R: List[float], s: List[float]) -> tuple[float, float, float]:
    """A = E[s^2], B = E[R s^2], C = E[R^2 s^2]."""
    A = expect_val(pi, [s[a] ** 2 for a in range(len(pi))])
    B = expect_val(pi, [R[a] * s[a] ** 2 for a in range(len(pi))])
    C = expect_val(pi, [R[a] ** 2 * s[a] ** 2 for a in range(len(pi))])
    return A, B, C


def optimal_baseline(pi: List[float], R: List[float], s: List[float]) -> float:
    """Algorithm B: b* = E_pi[R s^2] / E_pi[s^2] = B / A."""
    A, B, _ = abc_coefficients(pi, R, s)
    return B / A


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def _approx(x: float, y: float, tol: float = 1e-9) -> bool:
    return abs(x - y) <= tol * (1.0 + abs(x) + abs(y))


def demo_foundations() -> None:
    print("=" * 70)
    print("FOUNDATIONS: positivity, normalization, score identity, Fisher")
    print("=" * 70)
    z = [1.3, -0.7, 2.1, 0.0, -1.5]
    pi = softmax_policy(z)
    n = len(pi)
    print(f"logits z = {z}")
    print(f"pi       = {[round(p, 5) for p in pi]}")

    # Theorem 3.1 / 3.2
    print(f"[softmaxPolicy_pos]      all pi_j > 0 : {all(p > 0 for p in pi)}")
    print(f"[softmaxPolicy_sum_one]  sum pi = 1   : {_approx(sum(pi), 1.0)} (={sum(pi):.12f})")

    # Theorem 3.3
    zeros = [expect_val(pi, softmax_score(pi, j)) for j in range(n)]
    print(f"[softmaxScore_expect_zero] max |E_pi[psi_j]| = {max(abs(z0) for z0 in zeros):.2e}")

    # Theorem 3.4 / 3.5
    F = fisher_info(pi)
    Fcf = fisher_info_closed_form(pi)
    max_err = max(abs(F[j][k] - Fcf[j][k]) for j in range(n) for k in range(n))
    print(f"[fisherInfo_eq]   max |F_def - F_closedform| = {max_err:.2e}")
    sym_err = max(abs(F[j][k] - F[k][j]) for j in range(n) for k in range(n))
    print(f"[fisherInfo_symm] max |F_jk - F_kj|          = {sym_err:.2e}")

    # Theorem 3.6 : PSD via variance realization, tested on random directions
    print("[fisherInfo_psd] testing v^T F v >= 0 and = E[(<v,psi>)^2] :")
    worst = math.inf
    for _ in range(5):
        v = [random.uniform(-3, 3) for _ in range(n)]
        qf = quadratic_form(F, v)
        var = fisher_quadratic_via_variance(pi, v)
        worst = min(worst, qf)
        print(f"    v^T F v = {qf:11.6f}   E[(<v,psi>)^2] = {var:11.6f}   match={_approx(qf, var)}")
    print(f"    minimum quadratic form observed = {worst:.6f}  (>= 0 confirms PSD)")
    print()


def demo_baselines() -> None:
    print("=" * 70)
    print("VARIANCE REDUCTION: baselines")
    print("=" * 70)
    z = [0.5, -0.2, 1.1, 0.3]
    pi = softmax_policy(z)
    n = len(pi)
    # A return that is strongly offset (a regime where baselines help most)
    R = [100.0 + 5.0 * a for a in range(n)]
    # A scalar score with zero mean under pi (e.g. score of parameter 0)
    s = softmax_score(pi, 0)
    print(f"pi = {[round(p, 4) for p in pi]}")
    print(f"R  = {R}")
    print(f"s  = psi_0 = {[round(si, 4) for si in s]}   (E_pi[s] = {expect_val(pi, s):.2e})")

    # Theorem 4.1 : baseline unbiased
    base = expect_val(pi, [R[a] * s[a] for a in range(n)])
    print("[baseline_unbiased] E_pi[(R - b)s] across baselines b:")
    for b in (-50.0, 0.0, 42.0, 105.0):
        val = expect_val(pi, [(R[a] - b) * s[a] for a in range(n)])
        print(f"    b = {b:7.1f} -> E[(R-b)s] = {val:.8f}   (target {base:.8f}, match={_approx(val, base)})")

    # Theorem 4.2 : quadratic second moment
    A, B, C = abc_coefficients(pi, R, s)
    print(f"[secondMoment_quadratic] A={A:.6f} B={B:.6f} C={C:.6f}")
    for b in (-10.0, 0.0, 30.0):
        lhs = second_moment(pi, R, s, b)
        rhs = A * b * b - 2 * B * b + C
        print(f"    b={b:6.1f}: M(b)={lhs:14.6f}  A b^2-2B b+C={rhs:14.6f}  match={_approx(lhs, rhs)}")

    # Theorem 4.3 + corollaries : optimal baseline and exact reduction
    bstar = optimal_baseline(pi, R, s)
    Mstar = second_moment(pi, R, s, bstar)
    print(f"[optimal_baseline] b* = B/A = {bstar:.6f}")
    print(f"    note: mean return E[R] = {expect_val(pi, R):.4f}  (b* differs: it is s^2-weighted)")
    print("[variance_reduction_amount] M(b) - M(b*) vs A (b - b*)^2 :")
    for b in (-10.0, 0.0, bstar, 30.0):
        gap = second_moment(pi, R, s, b) - Mstar
        pred = A * (b - bstar) ** 2
        print(f"    b={b:9.4f}: gap={gap:14.6f}  A(b-b*)^2={pred:14.6f}  match={_approx(gap, pred)}")

    # optimal_baseline_min / strict
    grid = [bstar + d for d in (-2, -1, -0.001, 0.0, 0.001, 1, 2)]
    mins = min(second_moment(pi, R, s, b) for b in grid)
    print(f"[optimal_baseline_min/strict] min over grid = {mins:.6f}, M(b*) = {Mstar:.6f}, "
          f"b* optimal = {_approx(mins, Mstar)}")
    print(f"    variance at b=0 : {second_moment(pi, R, s, 0.0):.4f}")
    print(f"    variance at b*  : {Mstar:.4f}  "
          f"(reduction factor {Mstar / second_moment(pi, R, s, 0.0):.4f})")
    print()


def main() -> None:
    random.seed(20260612)
    print("\nSoftmax Policy Gradients — Numerical Verification of the Theory\n")
    demo_foundations()
    demo_baselines()
    print("All numerical checks completed.")


if __name__ == "__main__":
    main()
