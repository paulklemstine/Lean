"""
The Unreasonable Effectiveness of Wrong Theories -- numerical demonstrations.

Theory-space is modeled as R^d with the standard Euclidean inner product.
A theory is a vector; `truth` is a distinguished vector. Wrongness is the
distance to the truth; a phenomenon is a direction u, and a theory's
prediction error on u is |<T - truth, u>|.

This script demonstrates, purely numerically:

  1. Prediction error is dominated by wrongness (Cauchy-Schwarz bound).
  2. Convergent perturbative corrections drive prediction error to zero
     on every fixed phenomenon.
  3. A wrong theory beats a single rival exactly on the orthogonalized
     residue of the rival's error, with gap ||q||^2.
  4. A single phenomenon on which a wrong theory beats a whole finite
     field of rivals at once (hyperplane avoidance).

Self-contained; requires only the Python standard library.
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence

Vector = List[float]


# --------------------------------------------------------------------------
# Core linear-algebra helpers (standard Euclidean inner product on R^d).
# --------------------------------------------------------------------------
def inner(x: Sequence[float], y: Sequence[float]) -> float:
    """Standard inner product <x, y> on R^d."""
    return sum(xi * yi for xi, yi in zip(x, y))


def norm(x: Sequence[float]) -> float:
    """Induced Euclidean norm ||x|| = sqrt(<x, x>)."""
    return math.sqrt(inner(x, x))


def sub(x: Sequence[float], y: Sequence[float]) -> Vector:
    """Vector difference x - y."""
    return [xi - yi for xi, yi in zip(x, y)]


def add(x: Sequence[float], y: Sequence[float]) -> Vector:
    """Vector sum x + y."""
    return [xi + yi for xi, yi in zip(x, y)]


def smul(t: float, x: Sequence[float]) -> Vector:
    """Scalar multiple t * x."""
    return [t * xi for xi in x]


# --------------------------------------------------------------------------
# Meta-theory quantities.
# --------------------------------------------------------------------------
def wrongness(truth: Sequence[float], theory: Sequence[float]) -> float:
    """Wrongness of a theory: its distance ||theory - truth|| from the truth."""
    return norm(sub(theory, truth))


def pred_err(truth: Sequence[float], theory: Sequence[float],
             u: Sequence[float]) -> float:
    """Prediction error of `theory` on phenomenon `u`: |<theory - truth, u>|."""
    return abs(inner(sub(theory, truth), u))


def orth_residue(truth: Sequence[float], a_theory: Sequence[float],
                 b_theory: Sequence[float]) -> Vector:
    """Component of B's error orthogonal to A's error (Gram-Schmidt residue).

    Returns q = b - (<b, a>/<a, a>) a with a = A - truth, b = B - truth.
    """
    a = sub(a_theory, truth)
    b = sub(b_theory, truth)
    coeff = inner(b, a) / inner(a, a)
    return sub(b, smul(coeff, a))


# --------------------------------------------------------------------------
# Demo 1: prediction error is bounded by wrongness (Cauchy-Schwarz).
# --------------------------------------------------------------------------
def demo_cauchy_schwarz(seed: int = 1, trials: int = 6) -> None:
    print("=" * 70)
    print("Demo 1: prediction error <= wrongness * ||u||  (Cauchy-Schwarz)")
    print("=" * 70)
    rng = random.Random(seed)
    d = 5
    truth = [rng.uniform(-1, 1) for _ in range(d)]
    for _ in range(trials):
        theory = [rng.uniform(-3, 3) for _ in range(d)]
        u = [rng.uniform(-2, 2) for _ in range(d)]
        pe = pred_err(truth, theory, u)
        bound = wrongness(truth, theory) * norm(u)
        ok = pe <= bound + 1e-9
        print(f"  predErr={pe:8.4f}  bound={bound:8.4f}  holds={ok}")
    print()


# --------------------------------------------------------------------------
# Demo 2: convergent corrections -> prediction error tends to zero.
# --------------------------------------------------------------------------
def demo_perturbative_convergence(seed: int = 2) -> None:
    print("=" * 70)
    print("Demo 2: convergent corrections drive prediction error to 0")
    print("=" * 70)
    rng = random.Random(seed)
    d = 4
    truth = [rng.uniform(-1, 1) for _ in range(d)]
    base = [rng.uniform(-2, 2) for _ in range(d)]
    gap = sub(truth, base)  # corrections must sum to truth - base
    # Geometric split of the gap: c_i = gap * (1/2^{i+1}); sum_i c_i = gap.
    u = [rng.uniform(-1, 1) for _ in range(d)]
    partial = list(base)
    print("   n |  wrongness | predErr(P_n, u)")
    for n in range(11):
        c_n = smul(0.5 ** (n + 1), gap)
        if n > 0:
            partial = add(partial, smul(0.5 ** n, gap))  # add previous c_{n-1}
        w = wrongness(truth, partial)
        pe = pred_err(truth, partial, u)
        print(f"  {n:2d} | {w:9.5f}  | {pe:12.8f}")
        _ = c_n
    print()


# --------------------------------------------------------------------------
# Demo 3: a wrong theory beats a single rival, with explicit gap ||q||^2.
# --------------------------------------------------------------------------
def demo_single_rival(seed: int = 3) -> None:
    print("=" * 70)
    print("Demo 3: wrong theory A is EXACT on q; rival B errs by ||q||^2")
    print("=" * 70)
    rng = random.Random(seed)
    d = 4
    truth = [rng.uniform(-1, 1) for _ in range(d)]
    a_theory = [rng.uniform(-2, 2) for _ in range(d)]  # our wrong theory A
    b_theory = [rng.uniform(-2, 2) for _ in range(d)]  # rival B
    q = orth_residue(truth, a_theory, b_theory)
    err_a = pred_err(truth, a_theory, q)
    err_b = pred_err(truth, b_theory, q)
    print(f"  wrongness(A) = {wrongness(truth, a_theory):.4f}")
    print(f"  wrongness(B) = {wrongness(truth, b_theory):.4f}")
    print(f"  phenomenon q = orthogonal residue of B's error vs A's error")
    print(f"  predErr(A, q) = {err_a:.3e}   (should be ~0)")
    print(f"  predErr(B, q) = {err_b:.6f}")
    print(f"  ||q||^2       = {norm(q) ** 2:.6f}   (should equal predErr(B, q))")
    print()


# --------------------------------------------------------------------------
# Demo 4: one phenomenon beating a whole finite field of rivals.
# --------------------------------------------------------------------------
def common_non_annihilating(vectors: List[Vector]) -> Vector:
    """Hyperplane-avoidance: a single u with <q, u> != 0 for every q in list.

    Built incrementally: u <- u + t*q with t chosen outside the finite
    forbidden set that would zero any earlier pairing.
    """
    if not vectors:
        return []
    d = len(vectors[0])
    u = [0.0] * d
    rng = random.Random(0)
    for q in vectors:
        # Forbidden t make some <q_i, u + t q> = 0 for already-handled q_i.
        # Pick t avoiding them; random draws almost surely work, verify.
        for _ in range(1000):
            t = rng.uniform(0.5, 5.0)
            cand = add(u, smul(t, q))
            if all(abs(inner(v, cand)) > 1e-9 for v in vectors[:vectors.index(q) + 1]):
                u = cand
                break
    return u


def demo_multi_rival(seed: int = 4, num_rivals: int = 5) -> None:
    print("=" * 70)
    print("Demo 4: ONE phenomenon on which A beats a whole field of rivals")
    print("=" * 70)
    rng = random.Random(seed)
    d = 6
    truth = [rng.uniform(-1, 1) for _ in range(d)]
    a_theory = [rng.uniform(-2, 2) for _ in range(d)]
    rivals = [[rng.uniform(-2, 2) for _ in range(d)] for _ in range(num_rivals)]
    residues = [orth_residue(truth, a_theory, b) for b in rivals]
    u = common_non_annihilating(residues)
    print(f"  predErr(A, u) = {pred_err(truth, a_theory, u):.3e}   (should be ~0)")
    for j, b in enumerate(rivals):
        print(f"  predErr(B_{j+1}, u) = {pred_err(truth, b, u):.6f}   (should be > 0)")
    print()


if __name__ == "__main__":
    demo_cauchy_schwarz()
    demo_perturbative_convergence()
    demo_single_rival()
    demo_multi_rival()
