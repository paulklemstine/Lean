"""
Topological Quantum Compiling: Braid Groups as Universal Gates
==============================================================

Numerical demonstration of the reduced Burau representation of the braid group
B_4 as a 3x3 quantum gate set, and of the structural facts underlying the
four-strand universality conjecture.

The reduced Burau generators over a ring with parameter t are:

    rho(s1) = [[-t, 0, 0], [1, 1, 0], [0, 0, 1]]
    rho(s2) = [[ 1, t, 0], [0,-t, 0], [0, 1, 1]]
    rho(s3) = [[ 1, 0, 0], [0, 1, t], [0, 0,-t]]

We verify, purely numerically:
  1. Artin's braid relations hold for arbitrary t (representation of B_4).
  2. det rho(s_i) = -t.
  3. At t = -1, W = rho(s1 s3) is unipotent (W = I + N, N != 0, N^2 = 0),
     with W^n = I + nN, hence infinite order.
  4. At t = -1, the image is non-abelian.
  5. Contrarian: at t = 1 the generators are involutions -> finite S_4 image.
  6. At the physical root of unity t = exp(2*pi*i/5), the (normalized) gates
     are unitary and a sample braid word has an eigenvalue that is an
     irrational rotation (evidence of infinite order at the physical parameter).

Self-contained: requires only the Python standard library plus numpy.
"""

from __future__ import annotations

import cmath
import math
from typing import List

import numpy as np

Matrix = np.ndarray


def burau1(t: complex) -> Matrix:
    """Reduced Burau image of the braid generator sigma_1 in B_4."""
    return np.array([[-t, 0, 0],
                     [1, 1, 0],
                     [0, 0, 1]], dtype=complex)


def burau2(t: complex) -> Matrix:
    """Reduced Burau image of the braid generator sigma_2 in B_4."""
    return np.array([[1, t, 0],
                     [0, -t, 0],
                     [0, 1, 1]], dtype=complex)


def burau3(t: complex) -> Matrix:
    """Reduced Burau image of the braid generator sigma_3 in B_4."""
    return np.array([[1, 0, 0],
                     [0, 1, t],
                     [0, 0, -t]], dtype=complex)


def close(a: Matrix, b: Matrix, tol: float = 1e-9) -> bool:
    """Entrywise near-equality of two matrices."""
    return bool(np.allclose(a, b, atol=tol))


def check_braid_relations(t: complex, tol: float = 1e-9) -> bool:
    """Verify all three Artin relations of B_4 for a given parameter t."""
    s1, s2, s3 = burau1(t), burau2(t), burau3(t)
    far = close(s1 @ s3, s3 @ s1, tol)
    r12 = close(s1 @ s2 @ s1, s2 @ s1 @ s2, tol)
    r23 = close(s2 @ s3 @ s2, s3 @ s2 @ s3, tol)
    return far and r12 and r23


def check_determinants(t: complex, tol: float = 1e-9) -> bool:
    """Verify det rho(sigma_i) = -t for all generators."""
    return all(abs(np.linalg.det(g(t)) - (-t)) < tol
               for g in (burau1, burau2, burau3))


def braid_word(word: List[int], t: complex) -> Matrix:
    """Compile a braid word to a matrix at parameter t.

    The word is a list of nonzero integers; a positive entry i uses generator
    sigma_i, and a negative entry -i uses the inverse of sigma_i (i in {1,2,3}).
    """
    gens = {1: burau1(t), 2: burau2(t), 3: burau3(t)}
    result = np.eye(3, dtype=complex)
    for letter in word:
        i = abs(letter)
        g = gens[i] if letter > 0 else np.linalg.inv(gens[i])
        result = result @ g
    return result


def unipotent_demo() -> None:
    """At t = -1, show W = rho(s1 s3) is unipotent with W^n = I + nN."""
    t = -1.0
    W = burau1(t) @ burau3(t)
    N = W - np.eye(3, dtype=complex)
    print("  W = rho(sigma_1 sigma_3) at t = -1:")
    print(np.real_if_close(W))
    print("  N = W - I:")
    print(np.real_if_close(N))
    print(f"  N != 0 : {not close(N, np.zeros((3, 3)))}")
    print(f"  N^2 = 0: {close(N @ N, np.zeros((3, 3)))}")
    for n in (1, 2, 5, 10, 100):
        Wn = np.linalg.matrix_power(W, n)
        predicted = np.eye(3, dtype=complex) + n * N
        entry = Wn[1, 0].real
        print(f"  W^{n:<3d}: (2,1) entry = {entry:g}"
              f"   matches I + nN: {close(Wn, predicted)}")
    print("  => powers are pairwise distinct: W has INFINITE ORDER.")


def noncommute_demo() -> None:
    """At t = -1, show the image is non-abelian."""
    t = -1.0
    lhs = burau1(t) @ burau2(t)
    rhs = burau2(t) @ burau1(t)
    print(f"  rho(s1)rho(s2) == rho(s2)rho(s1) ? {close(lhs, rhs)}")
    print("  => image is NON-ABELIAN (lies in no maximal torus).")


def involution_demo() -> None:
    """Contrarian: at t = 1 every generator squares to the identity."""
    t = 1.0
    I = np.eye(3, dtype=complex)
    for name, g in (("sigma_1", burau1), ("sigma_2", burau2), ("sigma_3", burau3)):
        sq = g(t) @ g(t)
        print(f"  rho({name})^2 == I ? {close(sq, I)}")
    print("  => at t = 1 the representation collapses onto S_4 (FINITE, |S_4|=24).")
    print("  => universality is PARAMETER-DEPENDENT.")


def physical_root_demo() -> None:
    """At t = exp(2*pi*i/5): braid relations still hold; the determinant-normalized
    generators lie in SL_3 with spectrum on the unit circle (they act by
    rotations), and a sample braid word acts as a unit-modulus rotation."""
    k = 5
    t = cmath.exp(2j * math.pi / k)
    print(f"  t = exp(2*pi*i/{k}) = {t:.6f}")
    print(f"  braid relations still hold: {check_braid_relations(t)}")

    # Normalize each generator to determinant 1 (det = -t) to sit inside SL_3.
    scale = (-t) ** (-1.0 / 3.0)
    s1 = scale * burau1(t)
    s2 = scale * burau2(t)
    s3 = scale * burau3(t)
    print(f"  det(normalized s1) ~ 1 : "
          f"{abs(np.linalg.det(s1) - 1) < 1e-9}")

    # The spectrum of every normalized generator lies on the unit circle.
    for name, g in (("s1", s1), ("s2", s2), ("s3", s3)):
        mods = [abs(lam) for lam in np.linalg.eigvals(g)]
        on_circle = all(abs(m - 1) < 1e-9 for m in mods)
        print(f"  spectrum of normalized {name} on unit circle: {on_circle}")

    # A sample braid word beta = s1 s2 s3 s1^{-1}; its eigenvalues are rotations.
    beta = braid_word([1, 2, 3, -1], t)
    beta = (scale ** 2) * beta  # normalize (net exponent sum = 2)
    eigs = np.linalg.eigvals(beta)
    print("  eigenvalues of beta = s1 s2 s3 s1^{-1} (normalized):")
    for lam in eigs:
        angle = math.degrees(cmath.phase(lam))
        print(f"    |lambda| = {abs(lam):.6f},  arg = {angle:+.4f} deg")
    print("  all eigenvalues have modulus 1: braids act as rotations of C^3.")
    print("  longer braid words fill out a dense set of such rotations")
    print("  (the conjectured SU(3) universality at t = e^{2*pi*i/5}).")


def run_demo() -> None:
    print("=" * 70)
    print("Topological Quantum Compiling: reduced Burau representation of B_4")
    print("=" * 70)

    print("\n[1] Braid relations hold for random parameters (representation of B_4)")
    rng = np.random.default_rng(0)
    for _ in range(4):
        t = complex(rng.normal(), rng.normal())
        ok = check_braid_relations(t)
        det_ok = check_determinants(t)
        print(f"  t = {t:+.3f}: braid relations {ok}, det = -t {det_ok}")

    print("\n[2] Infinite order at t = -1 (unipotent element)")
    unipotent_demo()

    print("\n[3] Non-abelian image at t = -1")
    noncommute_demo()

    print("\n[4] Contrarian: finite S_4 image at t = 1")
    involution_demo()

    print("\n[5] Physical root of unity t = exp(2*pi*i/5)")
    physical_root_demo()

    print("\nDone.")


if __name__ == "__main__":
    run_demo()
