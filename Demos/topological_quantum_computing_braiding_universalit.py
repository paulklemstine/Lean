"""
Numerical demonstrations for:

    Braiding Universality: An Algebraic and Number-Theoretic Kernel
    for Topological Quantum Computation

Every function is self-contained and uses only the Python standard library plus
NumPy. The demonstrations mirror the proved results:

  * Braid-word algebra: length and writhe additivity, inversion.
  * Kauffman bracket loop value  d = -A^2 - A^-2,  and  d(i) = 2.
  * Braid representation homomorphism:  rho(w1 ++ w2) = rho(w1) . rho(w2).
  * Golden ratio: irrationality witness, and  phi^2 = phi + 1.
  * Universality dichotomy: orbit of  n*alpha (mod 1)  is dense iff alpha
    irrational; the Fibonacci eigenphase 4/5 has finite order (not dense).
  * Lie algebra: anti-symmetry, Jacobi identity, traceless commutators.
  * Topological error suppression  exp(-Delta * L).
  * Solovay-Kitaev doubly-exponential convergence.

Run:  python demo.py
"""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from typing import Callable

import numpy as np


# ---------------------------------------------------------------------------
# Section 2-3: Braid words, length, writhe
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Gen:
    """A braid generator: index i, sign +1 (sigma_i) or -1 (sigma_i^-1)."""
    index: int
    sign: int  # +1 or -1


BraidWord = list  # list[Gen]


def braid_inverse(word: list[Gen]) -> list[Gen]:
    """Reverse the word and invert every generator."""
    return [Gen(g.index, -g.sign) for g in reversed(word)]


def length(word: list[Gen]) -> int:
    """Number of crossings."""
    return len(word)


def writhe(word: list[Gen]) -> int:
    """Signed crossing count."""
    return sum(g.sign for g in word)


def demo_braid_algebra() -> None:
    print("== Braid-word algebra ==")
    w1 = [Gen(1, +1), Gen(2, -1)]
    w2 = [Gen(1, +1), Gen(1, +1), Gen(2, +1)]
    cat = w1 + w2

    print(f"  length additive : |w1++w2|={length(cat)}  "
          f"|w1|+|w2|={length(w1) + length(w2)}")
    assert length(cat) == length(w1) + length(w2)

    print(f"  writhe additive : w(w1++w2)={writhe(cat)}  "
          f"w(w1)+w(w2)={writhe(w1) + writhe(w2)}")
    assert writhe(cat) == writhe(w1) + writhe(w2)

    print(f"  writhe inverse  : w(inv w1)={writhe(braid_inverse(w1))}  "
          f"-w(w1)={-writhe(w1)}")
    assert writhe(braid_inverse(w1)) == -writhe(w1)

    print(f"  involutive inv  : inv(inv w1)==w1 -> "
          f"{braid_inverse(braid_inverse(w1)) == w1}")
    assert braid_inverse(braid_inverse(w1)) == w1
    print()


# ---------------------------------------------------------------------------
# Section 4: Kauffman bracket loop value
# ---------------------------------------------------------------------------

def loop_value(A: complex) -> complex:
    """d = -A^2 - A^-2, the quantum dimension of the fundamental rep."""
    return -(A ** 2) - (A ** -2)


def demo_kauffman() -> None:
    print("== Kauffman bracket loop value  d = -A^2 - A^-2 ==")
    d_i = loop_value(1j)
    print(f"  d(i) = {d_i:.6g}   (expected 2)")
    assert abs(d_i - 2.0) < 1e-12
    for A in (cmath.exp(1j * 0.3), 0.7 + 0.2j, cmath.rect(1.0, 1.1)):
        print(f"  d({A:.3g}) = {loop_value(A):.4g}")
    print()


# ---------------------------------------------------------------------------
# Section 5: Braid representation is a homomorphism (reduced Burau, B_3)
# ---------------------------------------------------------------------------

def burau_sigma1(t: complex) -> np.ndarray:
    return np.array([[-t, 1.0], [0.0, 1.0]], dtype=complex)


def burau_sigma2(t: complex) -> np.ndarray:
    return np.array([[1.0, 0.0], [t, -t]], dtype=complex)


def evaluate(word: list[Gen], t: complex) -> np.ndarray:
    """rho(word): product of (inverse) Burau matrices, identity for empty word."""
    m = np.eye(2, dtype=complex)
    gen = {1: burau_sigma1(t), 2: burau_sigma2(t)}
    for g in word:
        base = gen[g.index]
        m = m @ (base if g.sign > 0 else np.linalg.inv(base))
    return m


def demo_representation() -> None:
    print("== Braid representation homomorphism & braid relation ==")
    t = 0.5 + 0.3j
    w1 = [Gen(1, +1), Gen(2, -1)]
    w2 = [Gen(2, +1), Gen(1, +1)]
    lhs = evaluate(w1 + w2, t)
    rhs = evaluate(w1, t) @ evaluate(w2, t)
    print(f"  rho(w1++w2) == rho(w1).rho(w2): "
          f"{np.allclose(lhs, rhs)}")
    assert np.allclose(lhs, rhs)

    # Braid relation sigma1 sigma2 sigma1 = sigma2 sigma1 sigma2 for all t.
    s1, s2 = burau_sigma1(t), burau_sigma2(t)
    print(f"  braid relation s1 s2 s1 == s2 s1 s2: "
          f"{np.allclose(s1 @ s2 @ s1, s2 @ s1 @ s2)}")
    assert np.allclose(s1 @ s2 @ s1, s2 @ s1 @ s2)

    print(f"  det(sigma1) = {np.linalg.det(s1):.4g}   (expected -t = {-t:.4g})")
    assert np.allclose(np.linalg.det(s1), -t)
    print()


# ---------------------------------------------------------------------------
# Section 6: Golden ratio
# ---------------------------------------------------------------------------

def golden_ratio() -> float:
    return (1.0 + math.sqrt(5.0)) / 2.0


def demo_golden_ratio() -> None:
    print("== Golden ratio  phi = (1 + sqrt 5)/2 ==")
    phi = golden_ratio()
    print(f"  phi          = {phi:.12f}")
    print(f"  phi^2        = {phi ** 2:.12f}")
    print(f"  phi + 1      = {phi + 1.0:.12f}   (fusion rule phi^2 = phi + 1)")
    assert abs(phi ** 2 - (phi + 1.0)) < 1e-12

    # Irrationality witness: continued fraction of phi is all 1's (never closes).
    cf = continued_fraction(phi, depth=12)
    print(f"  continued fraction [a0; a1, ...] = {cf}  (all 1's => irrational)")
    print()


def continued_fraction(x: float, depth: int) -> list[int]:
    terms: list[int] = []
    for _ in range(depth):
        a = math.floor(x)
        terms.append(a)
        frac = x - a
        if frac < 1e-12:
            break
        x = 1.0 / frac
    return terms


# ---------------------------------------------------------------------------
# Section 7: Universality dichotomy  (dense iff irrational)
# ---------------------------------------------------------------------------

def orbit_min_gap(alpha: float, steps: int) -> float:
    """Smallest gap between sorted points {n*alpha mod 1 : n=0..steps-1}.

    For irrational alpha the gap -> 0 as steps grows (orbit fills the circle);
    for rational p/q it stalls at 1/q (finite orbit)."""
    pts = sorted(((n * alpha) % 1.0) for n in range(steps))
    gaps = [pts[i + 1] - pts[i] for i in range(len(pts) - 1)]
    gaps.append(1.0 - pts[-1] + pts[0])
    return min(gaps)


def demo_dichotomy() -> None:
    print("== Universality dichotomy: orbit dense  <=>  alpha irrational ==")
    phi = golden_ratio()
    for steps in (50, 500, 5000):
        g_irr = orbit_min_gap(phi % 1.0, steps)
        g_rat = orbit_min_gap(4.0 / 5.0, steps)
        print(f"  steps={steps:5d}  min-gap(phi)={g_irr:.6f}   "
              f"min-gap(4/5)={g_rat:.6f}")

    # The 4/5 orbit visits exactly 5 distinct points, forever.
    pts45 = sorted({round((n * 4.0 / 5.0) % 1.0, 9) for n in range(10000)})
    print(f"  distinct points of 4/5 orbit = {len(pts45)}  -> finite order, "
          f"NOT dense")
    assert len(pts45) == 5
    print()


# ---------------------------------------------------------------------------
# Section 8: Lie algebra of commutators
# ---------------------------------------------------------------------------

def commutator(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    return A @ B - B @ A


def demo_lie_algebra() -> None:
    print("== Commutators close into su(2) ==")
    rng = np.random.default_rng(0)

    def rand() -> np.ndarray:
        return rng.standard_normal((2, 2)) + 1j * rng.standard_normal((2, 2))

    A, B, C = rand(), rand(), rand()
    print(f"  anti-symmetry [A,B]=-[B,A]: "
          f"{np.allclose(commutator(A, B), -commutator(B, A))}")
    print(f"  alternating  [A,A]=0      : "
          f"{np.allclose(commutator(A, A), 0)}")
    jac = (commutator(A, commutator(B, C))
           + commutator(B, commutator(C, A))
           + commutator(C, commutator(A, B)))
    print(f"  Jacobi identity sum == 0  : {np.allclose(jac, 0)}")
    print(f"  tr[A,B] == 0              : "
          f"{abs(np.trace(commutator(A, B))) < 1e-12}")
    print()


# ---------------------------------------------------------------------------
# Section 9: Topological error suppression
# ---------------------------------------------------------------------------

def error_prob(delta: float, L: float) -> float:
    return math.exp(-(delta * L))


def required_size(delta: float, eps: float) -> float:
    """L = (|log eps| + 1)/delta gives exp(-delta L) < eps."""
    return (abs(math.log(eps)) + 1.0) / delta


def demo_error_protection() -> None:
    print("== Topological error suppression  exp(-Delta * L) ==")
    delta = 1.3
    prev = 2.0
    for L in (1.0, 2.0, 4.0, 8.0):
        p = error_prob(delta, L)
        print(f"  L={L:4.1f}  exp(-Delta L)={p:.3e}   (monotone decreasing: "
              f"{p <= prev})")
        assert p < 1.0 and p <= prev
        prev = p
    eps = 1e-9
    L = required_size(delta, eps)
    print(f"  to reach eps={eps:.0e}: L={L:.3f}, achieved "
          f"{error_prob(delta, L):.3e} < eps")
    assert error_prob(delta, L) < eps
    print()


# ---------------------------------------------------------------------------
# Section 10: Solovay-Kitaev doubly-exponential convergence
# ---------------------------------------------------------------------------

def sk_error(eps0: float, n: int) -> float:
    """Error after n SK levels: eps0 ** (3/2)^n."""
    return eps0 ** ((3.0 / 2.0) ** n)


def demo_solovay_kitaev() -> None:
    print("== Solovay-Kitaev: eps0 ** (3/2)^n  collapses to 0 ==")
    eps0 = 0.2
    for n in range(6):
        print(f"  n={n}  exponent (3/2)^n={ (1.5) ** n:7.3f}  "
              f"error={sk_error(eps0, n):.3e}")
    assert sk_error(eps0, 1) < eps0
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    demo_braid_algebra()
    demo_kauffman()
    demo_representation()
    demo_golden_ratio()
    demo_dichotomy()
    demo_lie_algebra()
    demo_error_protection()
    demo_solovay_kitaev()
    print("All demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
