"""Numerical demonstrations for the tight cubic spectral gap of the
one-dimensional swap (path) reconfiguration chain.

We verify, purely numerically, the theoretical results:

  * Dirichlet energy of the position function on the length-n path:  2(n-1).
  * Pairwise variation of the position function:                      n^2(n^2-1)/6.
  * Rayleigh quotient of the position function:                       12 / (n^2(n+1)).
  * The Rayleigh window:                                              6/n^3 <= RQ <= 12/n^3.
  * The Poincare inequality  vr(f) <= n^3 * edge_energy(f)  for arbitrary f,
    equivalently  RQ(f) >= 2/n^3  for every non-constant f.
  * The true spectral gap (from the path-graph Laplacian) also lies in
    [2/n^3, 12/n^3] and is asymptotic to  pi^2 / n^3.

Everything is self-contained; only the standard library and `math`/`random`
are used, plus an optional dependence on `statistics` for clarity.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------
# Core combinatorial quantities of the abstract Rayleigh calculus.
# --------------------------------------------------------------------------
def dirichlet_energy(weight: Callable[[int, int], float], f: List[float]) -> float:
    """Dirichlet energy  sum_x sum_y Q(x,y) (f(x)-f(y))^2  over all ordered pairs."""
    n = len(f)
    total = 0.0
    for x in range(n):
        for y in range(n):
            total += weight(x, y) * (f[x] - f[y]) ** 2
    return total


def pairwise_variation(f: List[float]) -> float:
    """Pairwise variation  sum_x sum_y (f(x)-f(y))^2  over all ordered pairs."""
    n = len(f)
    total = 0.0
    for x in range(n):
        for y in range(n):
            total += (f[x] - f[y]) ** 2
    return total


def pairwise_variation_closed_form(f: List[float]) -> float:
    """Closed form  2 (N * sum f^2 - (sum f)^2)."""
    n = len(f)
    s1 = sum(f)
    s2 = sum(v * v for v in f)
    return 2.0 * (n * s2 - s1 * s1)


def path_weight(x: int, y: int) -> float:
    """Unit weight between consecutive positions of the path; 0 otherwise."""
    return 1.0 if abs(x - y) == 1 else 0.0


def rayleigh_quotient(weight: Callable[[int, int], float], f: List[float]) -> float:
    """Rayleigh quotient  dir(f) / vr(f)  for a non-constant f."""
    vr = pairwise_variation(f)
    if vr == 0.0:
        raise ValueError("Rayleigh quotient is undefined for a constant function.")
    return dirichlet_energy(weight, f) / vr


def edge_energy(f: List[float]) -> float:
    """Edge energy  sum_{i=0}^{n-2} (f(i+1)-f(i))^2."""
    return sum((f[i + 1] - f[i]) ** 2 for i in range(len(f) - 1))


# --------------------------------------------------------------------------
# The true spectral gap of the path-graph random walk (for comparison).
# --------------------------------------------------------------------------
def true_path_gap(n: int) -> float:
    """Second-smallest eigenvalue of the *normalized* combinatorial object whose
    Rayleigh quotient is dir/vr on the path.  We compute it via the closed-form
    eigenvalues of the path graph Laplacian, scaled to match the dir/vr ratio.

    The Rayleigh quotient dir_Q(f)/vr(f) equals (2 * f^T L f) / (2 N * f^T f_centered),
    whose minimum over non-constant f is  lambda_1(L) / N, where lambda_1(L) is the
    smallest non-zero eigenvalue of the path Laplacian,
        lambda_k(L) = 2 - 2 cos(pi k / n),  k = 0, ..., n-1.
    Hence the combinatorial gap equals (2 - 2 cos(pi / n)) / n.
    """
    lam1 = 2.0 - 2.0 * math.cos(math.pi / n)
    return lam1 / n


# --------------------------------------------------------------------------
# Demonstrations.
# --------------------------------------------------------------------------
def demo_position_witness(ns: List[int]) -> None:
    print("=" * 78)
    print("Position witness on the path:  dir = 2(n-1),  vr = n^2(n^2-1)/6,")
    print("RQ = 12/(n^2(n+1)),  window [6/n^3, 12/n^3].")
    print("=" * 78)
    header = f"{'n':>5} {'dir':>10} {'vr':>14} {'RQ':>14} {'6/n^3':>12} {'12/n^3':>12}"
    print(header)
    for n in ns:
        f = [float(i) for i in range(n)]
        d = dirichlet_energy(path_weight, f)
        v = pairwise_variation(f)
        rq = d / v
        lo, hi = 6.0 / n ** 3, 12.0 / n ** 3
        assert abs(d - 2 * (n - 1)) < 1e-9
        assert abs(v - n ** 2 * (n ** 2 - 1) / 6) < 1e-6
        assert abs(rq - 12.0 / (n ** 2 * (n + 1))) < 1e-12
        assert lo - 1e-12 <= rq <= hi + 1e-12
        print(f"{n:>5} {d:>10.1f} {v:>14.1f} {rq:>14.3e} {lo:>12.3e} {hi:>12.3e}")


def demo_poincare_random(n: int, trials: int, seed: int = 0) -> None:
    print("=" * 78)
    print(f"Poincare inequality for random test functions (n={n}, trials={trials}):")
    print("vr(f) <= n^3 * edge_energy(f)   and   RQ(f) >= 2/n^3.")
    print("=" * 78)
    rng = random.Random(seed)
    min_rq = math.inf
    worst_ratio = 0.0
    for _ in range(trials):
        f = [rng.uniform(-1.0, 1.0) for _ in range(n)]
        if len(set(f)) == 1:
            continue
        v = pairwise_variation(f)
        ee = edge_energy(f)
        rq = dirichlet_energy(path_weight, f) / v
        # Poincare:  vr <= n^3 * edge_energy.
        assert v <= n ** 3 * ee + 1e-6
        # Rayleigh lower bound:  RQ >= 2/n^3.
        assert rq >= 2.0 / n ** 3 - 1e-9
        min_rq = min(min_rq, rq)
        worst_ratio = max(worst_ratio, v / (n ** 3 * ee))
    print(f"minimum observed RQ over random f : {min_rq:.4e}")
    print(f"theoretical lower bound  2/n^3    : {2.0 / n ** 3:.4e}")
    print(f"worst-case vr / (n^3 * edge)      : {worst_ratio:.4f}  (must be <= 1)")


def demo_true_gap(ns: List[int]) -> None:
    print("=" * 78)
    print("True combinatorial gap vs. the cubic window [2/n^3, 12/n^3].")
    print("The true gap is asymptotic to pi^2 / n^3 ~ 9.87/n^3.")
    print("=" * 78)
    header = f"{'n':>5} {'2/n^3':>12} {'true gap':>14} {'12/n^3':>12} {'gap*n^3':>10}"
    print(header)
    for n in ns:
        lo, hi = 2.0 / n ** 3, 12.0 / n ** 3
        g = true_path_gap(n)
        assert lo - 1e-12 <= g <= hi + 1e-9
        print(f"{n:>5} {lo:>12.3e} {g:>14.3e} {hi:>12.3e} {g * n ** 3:>10.4f}")
    print(f"\npi^2 = {math.pi ** 2:.4f}  (limit of gap * n^3)")


def brute_force_gap(n: int) -> Tuple[float, List[float]]:
    """Estimate the gap by minimizing RQ over a fine grid of cosine-mode
    test functions f_k(i) = cos(pi k (i + 1/2) / n), the discrete eigenmodes.
    Returns the minimum Rayleigh quotient and the minimizing profile.
    """
    best_rq = math.inf
    best_f: List[float] = []
    for k in range(1, n):
        f = [math.cos(math.pi * k * (i + 0.5) / n) for i in range(n)]
        rq = rayleigh_quotient(path_weight, f)
        if rq < best_rq:
            best_rq, best_f = rq, f
    return best_rq, best_f


def demo_cosine_mode(ns: List[int]) -> None:
    print("=" * 78)
    print("Cosine mode beats the linear witness: it realizes the true bottom.")
    print("=" * 78)
    header = f"{'n':>5} {'linear RQ':>14} {'cosine RQ':>14} {'ratio':>8}"
    print(header)
    for n in ns:
        f_lin = [float(i) for i in range(n)]
        rq_lin = rayleigh_quotient(path_weight, f_lin)
        rq_cos, _ = brute_force_gap(n)
        print(f"{n:>5} {rq_lin:>14.4e} {rq_cos:>14.4e} {rq_lin / rq_cos:>8.3f}")


if __name__ == "__main__":
    demo_position_witness([2, 4, 8, 16, 32, 64])
    print()
    demo_poincare_random(n=20, trials=20000, seed=42)
    print()
    demo_true_gap([2, 4, 8, 16, 32, 64, 128])
    print()
    demo_cosine_mode([4, 8, 16, 32, 64])
    print("\nAll numerical checks passed.")
