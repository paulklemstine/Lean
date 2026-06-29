"""
Numerical demonstrations for:

    "A Sharp Deterministic Approximate Caratheodory Theorem and Its Bridge
     to Iterated Delaunay Refinement"

This file is fully self-contained (standard library only) and uses explicit
type hints. It demonstrates the MAIN theorem numerically:

    Greedy arg-min selection of k vertices (with repetition) approximates the
    convex point  x = sum_i p_i V_i  with squared error

        || x - (1/k) sum_j V(idx j) ||^2  <=  tau/k  <=  R^2/k,

    where  tau = sum_i p_i ||V_i - x||^2 = sum_i p_i ||V_i||^2 - ||x||^2.

It also demonstrates the contraction calculus for iterated refinement
(d_k <= (1/lambda)^k d_0, total budget D*lambda/(lambda-1)) and the 1D
minicenter (midpoint) base case lambda = 2.
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple

Vector = List[float]


# --------------------------------------------------------------------------
# Minimal real inner-product-space helpers
# --------------------------------------------------------------------------
def vadd(a: Vector, b: Vector) -> Vector:
    return [x + y for x, y in zip(a, b)]


def vsub(a: Vector, b: Vector) -> Vector:
    return [x - y for x, y in zip(a, b)]


def vscale(c: float, a: Vector) -> Vector:
    return [c * x for x in a]


def vzero(dim: int) -> Vector:
    return [0.0] * dim


def dot(a: Vector, b: Vector) -> float:
    return sum(x * y for x, y in zip(a, b))


def norm_sq(a: Vector) -> float:
    return dot(a, a)


def norm(a: Vector) -> float:
    return math.sqrt(norm_sq(a))


# --------------------------------------------------------------------------
# Core quantities from the paper
# --------------------------------------------------------------------------
def centroid(p: Sequence[float], V: Sequence[Vector]) -> Vector:
    """x = sum_i p_i V_i  (the target convex point)."""
    dim = len(V[0])
    x = vzero(dim)
    for pi, Vi in zip(p, V):
        x = vadd(x, vscale(pi, Vi))
    return x


def dev(p: Sequence[float], V: Sequence[Vector], i: int) -> Vector:
    """dev(i) = V_i - x  (Lean: `dev`)."""
    return vsub(V[i], centroid(p, V))


def tau(p: Sequence[float], V: Sequence[Vector]) -> float:
    """tau = sum_i p_i ||V_i - x||^2  (Lean: `tau`, `tau_eq`)."""
    x = centroid(p, V)
    return sum(pi * norm_sq(vsub(Vi, x)) for pi, Vi in zip(p, V))


# --------------------------------------------------------------------------
# The greedy procedure (Lean: bestIdx / greedySum / greedyIdx)
# --------------------------------------------------------------------------
def best_idx(p: Sequence[float], V: Sequence[Vector], s: Vector) -> int:
    """arg min_i || s + dev(i) ||^2  (Lean: `bestIdx`, `bestIdx_spec`)."""
    x = centroid(p, V)
    best_i, best_val = 0, math.inf
    for i in range(len(V)):
        d = vsub(V[i], x)
        val = norm_sq(vadd(s, d))
        if val < best_val:
            best_i, best_val = i, val
    return best_i


def greedy_indices(p: Sequence[float], V: Sequence[Vector], k: int) -> List[int]:
    """Run k greedy steps; return the chosen indices idx(0..k-1)."""
    x = centroid(p, V)
    dim = len(V[0])
    s = vzero(dim)
    idx: List[int] = []
    for _ in range(k):
        i = best_idx(p, V, s)
        idx.append(i)
        s = vadd(s, vsub(V[i], x))  # s_{t+1} = s_t + dev(i)
    return idx


def greedy_error_sq(p: Sequence[float], V: Sequence[Vector], k: int) -> float:
    """|| x - (1/k) sum_j V(idx j) ||^2 for the greedy list."""
    x = centroid(p, V)
    dim = len(V[0])
    idx = greedy_indices(p, V, k)
    avg = vzero(dim)
    for i in idx:
        avg = vadd(avg, V[i])
    avg = vscale(1.0 / k, avg)
    return norm_sq(vsub(x, avg))


# --------------------------------------------------------------------------
# Demo 1: the main theorem on the unit square (and a perturbed, off-center set)
# --------------------------------------------------------------------------
def demo_main_theorem() -> None:
    print("=" * 72)
    print("DEMO 1: Sharp deterministic approximate Caratheodory (main theorem)")
    print("=" * 72)

    # (a) Symmetric unit square: x = origin, so tau/k = R^2/k.
    V_sq: List[Vector] = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    p_sq: List[float] = [0.25, 0.25, 0.25, 0.25]
    R_sq = max(norm(Vi) for Vi in V_sq)
    print(f"\n(a) Unit square, R = {R_sq:.4f}, x = {centroid(p_sq, V_sq)}")
    print(f"    tau = {tau(p_sq, V_sq):.4f}  (= R^2 - ||x||^2)")
    print(f"    {'k':>3} | {'realized err^2':>16} | {'tau/k':>10} | {'R^2/k':>10}")
    for k in (1, 2, 3, 4, 8, 16):
        err = greedy_error_sq(p_sq, V_sq, k)
        t_over_k = tau(p_sq, V_sq) / k
        R_over_k = R_sq ** 2 / k
        ok = err <= t_over_k + 1e-9 <= R_over_k + 1e-9
        print(f"    {k:>3} | {err:>16.8f} | {t_over_k:>10.5f} | "
              f"{R_over_k:>10.5f}  [{'OK' if ok else 'FAIL'}]")

    # (b) Off-center, unequal weights: here tau/k is STRICTLY below R^2/k.
    V_oc: List[Vector] = [[2, 0], [0, 1], [-1, -1], [0.5, 2]]
    p_oc: List[float] = [0.4, 0.3, 0.2, 0.1]
    R_oc = max(norm(Vi) for Vi in V_oc)
    x_oc = centroid(p_oc, V_oc)
    print(f"\n(b) Off-center set, R = {R_oc:.4f}, ||x||^2 = {norm_sq(x_oc):.4f}")
    print(f"    tau = {tau(p_oc, V_oc):.4f}  (sharper than R^2 = {R_oc**2:.4f})")
    print(f"    {'k':>3} | {'realized err^2':>16} | {'tau/k':>10} | {'R^2/k':>10}")
    for k in (1, 2, 4, 8, 16, 32):
        err = greedy_error_sq(p_oc, V_oc, k)
        t_over_k = tau(p_oc, V_oc) / k
        R_over_k = R_oc ** 2 / k
        ok = err <= t_over_k + 1e-9 <= R_over_k + 1e-9
        print(f"    {k:>3} | {err:>16.8f} | {t_over_k:>10.5f} | "
              f"{R_over_k:>10.5f}  [{'OK' if ok else 'FAIL'}]")


# --------------------------------------------------------------------------
# Demo 2: greedy (deterministic) vs random (Maurey's empirical method)
# --------------------------------------------------------------------------
def random_error_sq(p: Sequence[float], V: Sequence[Vector], k: int,
                    trials: int, rng: random.Random) -> float:
    """Average squared error of k i.i.d. p-weighted draws over `trials` runs."""
    x = centroid(p, V)
    dim = len(V[0])
    n = len(V)
    cum = [0.0]
    total = 0.0
    for pi in p:
        cum.append(cum[-1] + pi)

    def sample() -> int:
        u = rng.random()
        for i in range(n):
            if cum[i] <= u < cum[i + 1]:
                return i
        return n - 1

    for _ in range(trials):
        avg = vzero(dim)
        for _ in range(k):
            avg = vadd(avg, V[sample()])
        avg = vscale(1.0 / k, avg)
        total += norm_sq(vsub(x, avg))
    return total / trials


def demo_greedy_vs_random() -> None:
    print("\n" + "=" * 72)
    print("DEMO 2: Deterministic greedy vs probabilistic (Maurey) sampling")
    print("=" * 72)
    rng = random.Random(2026)
    V: List[Vector] = [[2, 0], [0, 1], [-1, -1], [0.5, 2], [1.5, -0.5]]
    p: List[float] = [0.30, 0.25, 0.20, 0.15, 0.10]
    t = tau(p, V)
    print(f"\n    tau = {t:.5f}; guaranteed greedy bound is tau/k.")
    print(f"    {'k':>3} | {'greedy err^2':>14} | {'random mean err^2':>18} | "
          f"{'tau/k bound':>12}")
    for k in (1, 2, 4, 8, 16, 32, 64):
        g = greedy_error_sq(p, V, k)
        r = random_error_sq(p, V, k, trials=4000, rng=rng)
        print(f"    {k:>3} | {g:>14.8f} | {r:>18.8f} | {t / k:>12.6f}")
    print("\n    The greedy list is deterministic and never exceeds tau/k;")
    print("    random sampling only matches it in expectation.")


# --------------------------------------------------------------------------
# Demo 3: refinement contraction + 1D minicenter base case
# --------------------------------------------------------------------------
def contraction_trajectory(d0: float, lam: float, k: int) -> List[float]:
    """A worst-case contraction process d_k = (1/lam)^k * d0."""
    return [(1.0 / lam) ** j * d0 for j in range(k + 1)]


def total_budget(d0: float, lam: float) -> float:
    """Closed-form geometric budget D*lambda/(lambda-1)  (Lean: `total_budget`)."""
    return d0 * lam / (lam - 1.0)


def steps_to_tolerance(d0: float, lam: float, eps: float) -> int:
    """Smallest N with (1/lam)^N d0 < eps  (Lean: `exists_steps_below`)."""
    return max(0, math.ceil(math.log(d0 / eps) / math.log(lam)))


def demo_refinement() -> None:
    print("\n" + "=" * 72)
    print("DEMO 3: Iterated refinement contraction & 1D minicenter (lambda = 2)")
    print("=" * 72)

    # 1D minicenter base case: midpoint halves the edge -> lambda = 2 exactly.
    a: Vector = [0.0, 0.0]
    b: Vector = [3.0, 4.0]            # length 5
    m: Vector = vscale(0.5, vadd(a, b))
    print(f"\n  Edge [a,b] length = {norm(vsub(a, b)):.4f}")
    print(f"  dist(a,m) = {norm(vsub(a, m)):.4f}, "
          f"dist(m,b) = {norm(vsub(m, b)):.4f}  (both = length/2)")

    d0, lam, eps = 5.0, 2.0, 1e-2
    traj = contraction_trajectory(d0, lam, 12)
    print(f"\n  Contraction d_k <= (1/{lam:.0f})^k * {d0} :")
    for k in (0, 1, 2, 4, 8, 12):
        print(f"    d_{k:<2} <= {traj[k]:.6f}")
    print(f"\n  Steps to reach tolerance {eps}: N = "
          f"{steps_to_tolerance(d0, lam, eps)}")
    print(f"  Total refinement budget  sum_k d_k <= D*lam/(lam-1) = "
          f"{total_budget(d0, lam):.4f}")


def main() -> None:
    demo_main_theorem()
    demo_greedy_vs_random()
    demo_refinement()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
