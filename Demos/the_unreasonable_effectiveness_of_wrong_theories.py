"""
The Unreasonable Effectiveness of Wrong Theories -- Numerical Demonstrations.

Theory-space is modeled as a finite-dimensional real inner-product space R^d.
A theory is a vector T; the truth is a vector tau; wrongness is ||T - tau||.
A phenomenon is a direction u; a theory's prediction error on u is
    err(T, u) = |<T - tau, u>|.

This script demonstrates, with concrete numbers, the four headline results:
  1. Wrongness is 1-Lipschitz in corrections.
  2. Perturbative corrections summing to the truth-gap drive wrongness to 0.
  3. Geometrically decaying corrections give the exponential rate M r^n / (1-r).
  4. The meta-theorem: a globally worse theory can be EXACTLY right on a
     constructed phenomenon where a globally better rival errs.

Only the Python standard library is used.
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence


# ----------------------------------------------------------------------------
# Basic linear algebra in R^d (no numpy dependency).
# ----------------------------------------------------------------------------
def dot(a: Sequence[float], b: Sequence[float]) -> float:
    """Real inner product <a, b>."""
    return sum(x * y for x, y in zip(a, b))


def sub(a: Sequence[float], b: Sequence[float]) -> List[float]:
    """Vector difference a - b."""
    return [x - y for x, y in zip(a, b)]


def add(a: Sequence[float], b: Sequence[float]) -> List[float]:
    """Vector sum a + b."""
    return [x + y for x, y in zip(a, b)]


def scale(t: float, a: Sequence[float]) -> List[float]:
    """Scalar multiple t * a."""
    return [t * x for x in a]


def norm(a: Sequence[float]) -> float:
    """Euclidean norm ||a|| = sqrt(<a, a>)."""
    return math.sqrt(dot(a, a))


# ----------------------------------------------------------------------------
# Core definitions.
# ----------------------------------------------------------------------------
def wrongness(truth: Sequence[float], theory: Sequence[float]) -> float:
    """w(T) = ||T - truth||."""
    return norm(sub(theory, truth))


def pred_err(truth: Sequence[float], theory: Sequence[float],
             u: Sequence[float]) -> float:
    """err(T, u) = |<T - truth, u>|."""
    return abs(dot(sub(theory, truth), u))


def partial_theory(t0: Sequence[float], corrections: Sequence[Sequence[float]],
                   n: int) -> List[float]:
    """T_n = T0 + sum_{i<n} c_i."""
    result = list(t0)
    for i in range(n):
        result = add(result, corrections[i])
    return result


# ----------------------------------------------------------------------------
# Demo 1: Lipschitz stability of wrongness.
# ----------------------------------------------------------------------------
def demo_lipschitz() -> None:
    print("=" * 68)
    print("Demo 1: Wrongness is 1-Lipschitz in corrections")
    print("  |w(T + c) - w(T)| <= ||c||")
    print("=" * 68)
    random.seed(1)
    truth = [1.0, -2.0, 0.5, 3.0]
    theory = [0.2, -1.0, 1.5, 2.0]
    for _ in range(5):
        c = [random.uniform(-2, 2) for _ in range(4)]
        lhs = abs(wrongness(truth, add(theory, c)) - wrongness(truth, theory))
        rhs = norm(c)
        ok = "OK" if lhs <= rhs + 1e-12 else "VIOLATION"
        print(f"  |dw| = {lhs:.6f}  <=  ||c|| = {rhs:.6f}   [{ok}]")
    print()


# ----------------------------------------------------------------------------
# Demo 2: Convergence of perturbative corrections to the truth.
# ----------------------------------------------------------------------------
def demo_convergence() -> None:
    print("=" * 68)
    print("Demo 2: Corrections summing to (truth - T0) drive wrongness -> 0")
    print("=" * 68)
    truth = [2.0, 5.0, -1.0]
    t0 = [0.0, 0.0, 0.0]
    gap = sub(truth, t0)
    # Split the gap into geometrically shrinking pieces: c_i = gap * (1/2)^{i+1}.
    n_terms = 12
    corrections = [scale(0.5 ** (i + 1), gap) for i in range(n_terms)]
    print(f"  truth = {truth},  T0 = {t0}")
    for n in range(n_terms + 1):
        tn = partial_theory(t0, corrections, n)
        print(f"  n = {n:2d}   w(T_n) = {wrongness(truth, tn):.8f}")
    print()


# ----------------------------------------------------------------------------
# Demo 3: Explicit exponential rate M r^n / (1 - r).
# ----------------------------------------------------------------------------
def demo_geometric_rate() -> None:
    print("=" * 68)
    print("Demo 3: Geometric corrections => residual <= M r^n / (1 - r)")
    print("=" * 68)
    random.seed(7)
    d = 5
    r = 0.6
    M = 1.0
    # Build corrections with ||c_i|| = M r^i exactly, random directions.
    corrections: List[List[float]] = []
    for i in range(40):
        direction = [random.gauss(0, 1) for _ in range(d)]
        direction = scale(1.0 / norm(direction), direction)
        corrections.append(scale(M * r ** i, direction))
    t0 = [0.0] * d
    truth = partial_theory(t0, corrections, len(corrections))  # tau = T0 + sum c_i
    print(f"  M = {M}, r = {r}")
    for n in range(0, 21, 2):
        tn = partial_theory(t0, corrections, n)
        actual = wrongness(truth, tn)
        bound = M * r ** n / (1 - r)
        ok = "OK" if actual <= bound + 1e-9 else "VIOLATION"
        print(f"  n = {n:2d}   w(T_n) = {actual:.8f}  <=  {bound:.8f}   [{ok}]")
    print()


# ----------------------------------------------------------------------------
# Demo 4: The meta-theorem -- wrong beats better on a constructed phenomenon.
# ----------------------------------------------------------------------------
def winning_phenomenon(truth: Sequence[float], a_theory: Sequence[float],
                       b_theory: Sequence[float]) -> List[float]:
    """Gram-Schmidt step: u = b - (<b,a>/<a,a>) a, with a=A-truth, b=B-truth.
    Then err(A, u) = 0 and err(B, u) = ||u||^2 > 0 (if errors non-parallel)."""
    a = sub(a_theory, truth)
    b = sub(b_theory, truth)
    t = dot(b, a) / dot(a, a)
    return sub(b, scale(t, a))


def demo_meta_theorem() -> None:
    print("=" * 68)
    print("Demo 4: Meta-theorem -- a globally WORSE theory is EXACTLY right")
    print("        on a phenomenon where the globally BETTER rival errs")
    print("=" * 68)
    truth = [0.0, 0.0, 0.0]
    # A is far from truth (globally worse); B is close (globally better),
    # but their errors point in different (non-parallel) directions.
    a_theory = [3.0, 0.0, 0.0]          # error a = (3, 0, 0)
    b_theory = [0.1, 0.2, 0.0]          # error b = (0.1, 0.2, 0)
    print(f"  global wrongness:  w(A) = {wrongness(truth, a_theory):.4f}  "
          f"(worse),  w(B) = {wrongness(truth, b_theory):.4f}  (better)")
    u = winning_phenomenon(truth, a_theory, b_theory)
    ea = pred_err(truth, a_theory, u)
    eb = pred_err(truth, b_theory, u)
    print(f"  constructed phenomenon u = {[round(x, 4) for x in u]}")
    print(f"  err(A, u) = {ea:.10f}   (exactly right)")
    print(f"  err(B, u) = {eb:.10f}   (rival errs)")
    print(f"  => on phenomenon u, the WORSE theory A strictly out-predicts B: "
          f"{ea:.4f} < {eb:.4f}")
    print()


def main() -> None:
    demo_lipschitz()
    demo_convergence()
    demo_geometric_rate()
    demo_meta_theorem()


if __name__ == "__main__":
    main()
