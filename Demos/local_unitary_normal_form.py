"""
Local-unitary normal form for maximally entangled two-qubit states
==================================================================

Numerical demonstrations of the results:

  1.  Sharp bound           2|det M| <= ||M||_F^2, hence concurrence C <= 1.
  2.  Row classification    C(M) = 1  <=>  M M^H = (1/2) I.
  3.  Unitary rescaling     sqrt(2) M is unitary for a maximizer.
  4.  Normal form           maximizers = { U Phi V^T }, Phi = diag(1/sqrt2, 1/sqrt2).
  5.  One-sided transitivity and explicit interconversion W = 2 N M^H.
  6.  Stabilizer            U Phi V^T = Phi  <=>  V = conj(U).
  7.  Flat maximizers       = diag(d) (F2/2) diag(e), with a dephasing algorithm.
  8.  Real count            exactly 8 of the 16 sign patterns are maximizers.
  9.  Bell basis            orthonormal basis of maximizers + expansion formula.
 10.  Linear entropy        C^2 = 2 (1 - tr rho^2), purity >= 1/2.
 11.  Schmidt spectrum      eigenvalues (1 +- sqrt(1 - C^2)) / 2.
 12.  Stability             ||rho - I/2||_F^2 = (1 - C^2)/2 <= 1 - C.

Self-contained: only numpy and the standard library are required.
"""

from __future__ import annotations

import itertools
from typing import Iterator, Tuple

import numpy as np

TOL: float = 1e-10
Matrix = np.ndarray

# ----------------------------------------------------------------------------
# Basic objects
# ----------------------------------------------------------------------------

SQRT2: float = float(np.sqrt(2.0))
PHI: Matrix = np.eye(2, dtype=complex) / SQRT2                 # the Bell state
F2: Matrix = np.array([[1, 1], [1, -1]], dtype=complex)        # Fourier / Hadamard
SIGMA = {
    "I": np.eye(2, dtype=complex),
    "X": np.array([[0, 1], [1, 0]], dtype=complex),
    "Y": np.array([[0, -1j], [1j, 0]], dtype=complex),
    "Z": np.array([[1, 0], [0, -1]], dtype=complex),
}


def frob_sq(M: Matrix) -> float:
    """Squared Frobenius norm = total probability of the state."""
    return float(np.sum(np.abs(M) ** 2))


def concurrence(M: Matrix) -> float:
    """Wootters concurrence C(M) = 2 |det M|."""
    return float(2.0 * abs(np.linalg.det(M)))


def marginal(M: Matrix) -> Matrix:
    """Reduced density matrix rho = M M^H of the first qubit."""
    return M @ M.conj().T


def purity(M: Matrix) -> float:
    """tr(rho^2) for rho = M M^H."""
    rho = marginal(M)
    return float(np.real(np.trace(rho @ rho)))


def is_normalized(M: Matrix) -> bool:
    return abs(frob_sq(M) - 1.0) < TOL


def is_sharp_maximizer(M: Matrix) -> bool:
    """Algorithm A: certify maximality in O(1) operations."""
    return is_normalized(M) and abs(concurrence(M) - 1.0) < TOL


def is_unitary(U: Matrix) -> bool:
    return bool(np.allclose(U @ U.conj().T, np.eye(2), atol=1e-9))


def is_flat(M: Matrix) -> bool:
    return bool(np.allclose(np.abs(M), 0.5, atol=1e-9))


def local_act(U: Matrix, V: Matrix, M: Matrix) -> Matrix:
    """The local action of U (x) V on amplitude matrices: M -> U M V^T."""
    return U @ M @ V.T


# ----------------------------------------------------------------------------
# Random generators
# ----------------------------------------------------------------------------


def random_unitary(rng: np.random.Generator) -> Matrix:
    """Haar-distributed 2x2 unitary via QR of a complex Ginibre matrix."""
    z = (rng.normal(size=(2, 2)) + 1j * rng.normal(size=(2, 2))) / np.sqrt(2.0)
    q, r = np.linalg.qr(z)
    return q @ np.diag(np.diag(r) / np.abs(np.diag(r)))


def random_state(rng: np.random.Generator) -> Matrix:
    """A uniformly random normalized amplitude matrix."""
    z = rng.normal(size=(2, 2)) + 1j * rng.normal(size=(2, 2))
    return z / np.sqrt(frob_sq(z))


def random_maximizer(rng: np.random.Generator) -> Matrix:
    """A random maximally entangled state: U Phi V^T with Haar U, V."""
    return local_act(random_unitary(rng), random_unitary(rng), PHI)


# ----------------------------------------------------------------------------
# Algorithms extracted from the theorems
# ----------------------------------------------------------------------------


def normal_form(M: Matrix) -> Tuple[Matrix, Matrix]:
    """Algorithm B. For a sharp maximizer return (U, V) with M = U Phi V^T."""
    if not is_sharp_maximizer(M):
        raise ValueError("normal_form requires a sharp maximizer")
    return SQRT2 * M, np.eye(2, dtype=complex)


def interconvert(M: Matrix, N: Matrix) -> Matrix:
    """Algorithm C. For maximizers M, N return the unitary W with W M = N."""
    return 2.0 * N @ M.conj().T


def dephase_flat(M: Matrix) -> Tuple[Matrix, Matrix]:
    """Algorithm D. For a flat maximizer return diagonal unitaries (D, E)
    with M = D (F2 / 2) E."""
    d = np.array([1.0 + 0j, M[1, 0] / M[0, 0]])
    e = np.array([2.0 * M[0, 0], 2.0 * M[0, 1]])
    return np.diag(d), np.diag(e)


def bell_basis() -> list[Matrix]:
    """The Pauli orbit of the Bell state: an orthonormal basis of maximizers."""
    return [SIGMA[k] / SQRT2 for k in ("I", "X", "Y", "Z")]


def hs_inner(M: Matrix, N: Matrix) -> complex:
    """Hilbert-Schmidt inner product <M, N> = sum conj(M_ij) N_ij."""
    return complex(np.sum(np.conj(M) * N))


def bell_coefficients(M: Matrix) -> np.ndarray:
    """Algorithm E. Coefficients of M in the Bell basis."""
    return np.array([hs_inner(B, M) for B in bell_basis()])


def schmidt_spectrum(M: Matrix) -> Tuple[float, float]:
    """Algorithm F. The eigenvalues (1 +- sqrt(1 - C^2)) / 2 of the marginal."""
    c = concurrence(M)
    root = float(np.sqrt(max(0.0, 1.0 - c * c)))
    return (1.0 + root) / 2.0, (1.0 - root) / 2.0


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_sharp_bound(rng: np.random.Generator, trials: int = 200_000) -> None:
    banner("1. Sharp bound  2 |det M| <= ||M||_F^2  and  C <= 1 on normalized states")
    worst = 0.0
    best_c = 0.0
    for _ in range(trials // 1000):
        z = rng.normal(size=(2, 2)) + 1j * rng.normal(size=(2, 2))
        slack = frob_sq(z) - 2.0 * abs(np.linalg.det(z))
        worst = min(worst, slack)
        best_c = max(best_c, concurrence(random_state(rng)))
    print(f"  minimum observed slack ||M||_F^2 - 2|det M| : {worst:+.12f}   (must be >= 0)")
    print(f"  largest concurrence among random states     : {best_c:.6f}   (<= 1)")
    print(f"  concurrence of the Bell state Phi           : {concurrence(PHI):.12f}")
    print(f"  equality holds for Phi, so the bound is sharp.")


def demo_row_classification(rng: np.random.Generator) -> None:
    banner("2-3. Row classification, maximally mixed marginal, unitary rescaling")
    M = random_maximizer(rng)
    rho = marginal(M)
    print("  a random maximally entangled state M =")
    print(np.array2string(M, precision=4, suppress_small=True, prefix="    "))
    print(f"  ||row0||^2 = {frob_sq(M[0]):.12f}   ||row1||^2 = {frob_sq(M[1]):.12f}   (both 1/2)")
    print(f"  <row0, row1> = {np.vdot(M[1], M[0]):+.2e}   (zero)")
    print("  rho = M M^H =")
    print(np.array2string(rho, precision=6, suppress_small=True, prefix="    "))
    print(f"  ||rho - I/2||_F = {np.sqrt(frob_sq(rho - np.eye(2) / 2)):.2e}")
    print(f"  sqrt(2) M is unitary : {is_unitary(SQRT2 * M)}")
    print("\n  Converse check: a matrix with maximally mixed marginal is a maximizer.")
    U = random_unitary(rng)
    N = U / SQRT2
    print(f"    N = U/sqrt2 with U Haar-random -> is_sharp_maximizer(N) = {is_sharp_maximizer(N)}")


def demo_normal_form(rng: np.random.Generator) -> None:
    banner("4-5. Normal form, one-sided transitivity and explicit interconversion")
    M = random_maximizer(rng)
    U, V = normal_form(M)
    print(f"  extracted U unitary : {is_unitary(U)}")
    print(f"  || M - U Phi V^T ||  = {np.sqrt(frob_sq(M - local_act(U, V, PHI))):.2e}")
    print("  (the right factor is the identity: the LEFT action alone is transitive)")

    N = random_maximizer(rng)
    W = interconvert(M, N)
    print(f"\n  W = 2 N M^H is unitary : {is_unitary(W)}")
    print(f"  || N - W M ||          = {np.sqrt(frob_sq(N - W @ M)):.2e}")
    print("  so one party, acting on their qubit alone, converts any maximizer into any other.")

    print("\n  Local invariance of the two invariants on a NON-maximal state:")
    R = random_state(rng)
    A, B = random_unitary(rng), random_unitary(rng)
    RA = local_act(A, B, R)
    print(f"    ||R||_F^2 = {frob_sq(R):.10f}  ->  {frob_sq(RA):.10f}")
    print(f"    C(R)      = {concurrence(R):.10f}  ->  {concurrence(RA):.10f}")


def demo_stabilizer(rng: np.random.Generator) -> None:
    banner("6. Stabilizer of the Bell state:  U Phi V^T = Phi  <=>  V = conj(U)")
    U = random_unitary(rng)
    V = U.conj()
    print(f"  || U Phi conj(U)^T - Phi ||   = {np.sqrt(frob_sq(local_act(U, V, PHI) - PHI)):.2e}")
    Vbad = random_unitary(rng)
    print(f"  || U Phi V^T - Phi ||, V Haar = {np.sqrt(frob_sq(local_act(U, Vbad, PHI) - PHI)):.4f}"
          "   (generically nonzero)")
    print("  Consequence: the maximizer orbit is (U(2) x U(2)) / U(2), of real dimension 4.")


def demo_flat_and_hadamard(rng: np.random.Generator) -> None:
    banner("7-8. Flat maximizers, dephasing to F2/2, and the count of real sign patterns")
    d = np.exp(1j * rng.uniform(0, 2 * np.pi, size=2))
    e = np.exp(1j * rng.uniform(0, 2 * np.pi, size=2))
    M = np.diag(d) @ (F2 / 2.0) @ np.diag(e)
    print(f"  built M = diag(d) (F2/2) diag(e):  sharp = {is_sharp_maximizer(M)}, "
          f"flat = {is_flat(M)}")
    D, E = dephase_flat(M)
    print(f"  recovered dephasing:  || M - D (F2/2) E || = "
          f"{np.sqrt(frob_sq(M - D @ (F2 / 2.0) @ E)):.2e}")
    print(f"  D, E diagonal unitary: {is_unitary(D)}, {is_unitary(E)}")

    print("\n  Real sign patterns (entries +-1/2):")
    good = []
    for signs in itertools.product([1, -1], repeat=4):
        a, b, c, dd = signs
        S = np.array([[a, b], [c, dd]], dtype=complex) / 2.0
        if is_sharp_maximizer(S):
            good.append(signs)
    print(f"    total patterns   : 16")
    print(f"    maximizers found : {len(good)}")
    for signs in good:
        a, b, c, dd = signs
        print(f"      [{a:+d} {b:+d}; {c:+d} {dd:+d}]   criterion (a==d) XOR (b==c) = "
              f"{(a == dd) != (b == c)}")


def demo_bell_basis() -> None:
    banner("9. The Bell basis: an orthonormal basis consisting of maximizers")
    basis = bell_basis()
    names = ["I", "X", "Y", "Z"]
    for name, B in zip(names, basis):
        print(f"  Phi_{name}: sharp maximizer = {is_sharp_maximizer(B)}, "
              f"||Phi_{name}||_F^2 = {frob_sq(B):.6f}")
    gram = np.array([[hs_inner(A, B) for B in basis] for A in basis])
    print("  Gram matrix of Hilbert-Schmidt inner products:")
    print(np.array2string(np.real_if_close(gram, tol=1e6), precision=6,
                          suppress_small=True, prefix="    "))
    rng = np.random.default_rng(7)
    M = random_state(rng)
    coeffs = bell_coefficients(M)
    recon = sum(c * B for c, B in zip(coeffs, basis))
    print(f"  expansion error for a random state : {np.sqrt(frob_sq(M - recon)):.2e}")
    print(f"  sum |c_k|^2 = {float(np.sum(np.abs(coeffs) ** 2)):.10f}  "
          f"(= ||M||_F^2 = {frob_sq(M):.10f})")


def demo_entropy_and_spectrum(rng: np.random.Generator) -> None:
    banner("10-11. Linear-entropy identity, minimal purity, and the Schmidt spectrum")
    print(f"  {'C(M)':>10} {'purity':>12} {'2(1-purity)':>14} {'C^2':>10} "
          f"{'s+':>10} {'s-':>10} {'eig err':>10}")
    samples = [random_state(rng) for _ in range(6)] + [PHI, F2 / 2.0]
    for M in samples:
        c = concurrence(M)
        p = purity(M)
        sp, sm = schmidt_spectrum(M)
        eigs = np.sort(np.real(np.linalg.eigvalsh(marginal(M))))[::-1]
        err = max(abs(eigs[0] - sp), abs(eigs[1] - sm))
        print(f"  {c:10.6f} {p:12.6f} {2 * (1 - p):14.6f} {c * c:10.6f} "
              f"{sp:10.6f} {sm:10.6f} {err:10.2e}")
    mins = min(purity(random_state(rng)) for _ in range(20000))
    print(f"\n  minimum purity over 20000 random normalized states : {mins:.6f}  (>= 0.5)")
    print(f"  purity of the Bell state                           : {purity(PHI):.6f}")


def demo_stability(rng: np.random.Generator) -> None:
    banner("12. Stability: ||rho - I/2||_F^2 = (1 - C^2)/2 <= 1 - C")
    print(f"  {'C(M)':>10} {'||rho-I/2||_F^2':>18} {'(1-C^2)/2':>14} "
          f"{'1-C':>10} {'identity err':>14}")
    # interpolate from a product state to the Bell state
    for t in np.linspace(0.0, 1.0, 9):
        raw = np.array([[np.cos(t * np.pi / 4), 0.0],
                        [0.0, np.sin(t * np.pi / 4)]], dtype=complex)
        if frob_sq(raw) < TOL:
            continue
        M = raw / np.sqrt(frob_sq(raw))
        c = concurrence(M)
        lhs = frob_sq(marginal(M) - np.eye(2) / 2.0)
        rhs = (1.0 - c * c) / 2.0
        print(f"  {c:10.6f} {lhs:18.10f} {rhs:14.10f} {1 - c:10.6f} {abs(lhs - rhs):14.2e}")
    worst = 0.0
    for _ in range(20000):
        M = random_state(rng)
        worst = max(worst, abs(frob_sq(marginal(M) - np.eye(2) / 2.0)
                               - (1 - concurrence(M) ** 2) / 2.0))
    print(f"\n  maximal deviation from the identity over 20000 random states: {worst:.2e}")


def demo_product_states(rng: np.random.Generator) -> None:
    banner("Bonus. Product states: the opposite extreme  (C = 0, smaller Schmidt value 0)")
    u = rng.normal(size=2) + 1j * rng.normal(size=2)
    w = rng.normal(size=2) + 1j * rng.normal(size=2)
    P = np.outer(u, w)
    P = P / np.sqrt(frob_sq(P))
    sp, sm = schmidt_spectrum(P)
    print(f"  outer-product state: C = {concurrence(P):.2e}, "
          f"Schmidt spectrum = ({sp:.6f}, {sm:.2e})")
    print(f"  is it a sharp maximizer? {is_sharp_maximizer(P)}   "
          "(maximizers and products are disjoint)")


def main() -> None:
    rng = np.random.default_rng(20260826)
    np.set_printoptions(linewidth=100)
    demo_sharp_bound(rng)
    demo_row_classification(rng)
    demo_normal_form(rng)
    demo_stabilizer(rng)
    demo_flat_and_hadamard(rng)
    demo_bell_basis()
    demo_entropy_and_spectrum(rng)
    demo_stability(rng)
    demo_product_states(rng)
    print("\nAll demonstrations completed.\n")


if __name__ == "__main__":
    main()
