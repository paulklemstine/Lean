"""
Numerical demonstration of the logarithmic negativity as an entanglement monotone.

This script is self-contained (NumPy only) and verifies, numerically, every
structural result of the accompanying paper:

  1.  The variational trace norm
          ||X||_1 = inf { tr P + tr Q : X = P - Q, P, Q >= 0 }
      equals the sum of the absolute values of the eigenvalues of a Hermitian X,
      with the infimum attained by the spectral Jordan pair.

  2.  Strong duality: the sign operator W = U diag(sign(lambda)) U^dagger is a
      Hermitian contraction (-1 <= W <= 1) with Re tr(X W) = ||X||_1, so the
      dual supremum is attained too and there is no duality gap.

  3.  Faithfulness on the PPT class: E_N(rho) = 0 exactly when the partial
      transpose of rho is positive semidefinite (illustrated on Werner states,
      whose PPT threshold is exact and analytically known).

  4.  Monotonicity: E_N never increases under local operations (local unitaries
      leave it invariant; local depolarising noise decreases it), and strong
      monotonicity holds for a local measurement instrument.

  5.  Exact additivity E_N(rho (x) sigma) = E_N(rho) + E_N(sigma), together with
      the *non*-additive law N(rho (x) sigma) = 2 N(rho) N(sigma) + N(rho) + N(sigma)
      for the un-logged negativity, and multiplicativity ||A (x) B||_1 = ||A||_1 ||B||_1.

  6.  The dimension bound E_N(rho) <= (1/2) log(d_A d_B), saturated exactly at
      the maximally entangled state, where E_N(Phi_d) = log d.

  7.  Convexity of the negativity under mixing.

Run with:  python demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, List, Sequence, Tuple

import numpy as np

Matrix = np.ndarray

TOL = 1e-9


# --------------------------------------------------------------------------- #
#  Core linear algebra: partial transpose, trace norm, Jordan pair, certificate
# --------------------------------------------------------------------------- #


def partial_transpose(rho: Matrix, dA: int, dB: int) -> Matrix:
    """Partial transpose on the second factor: (Gamma X)_{(i,j),(k,l)} = X_{(i,l),(k,j)}."""
    t = rho.reshape(dA, dB, dA, dB)
    t = t.transpose(0, 3, 2, 1)  # swap the two B-indices j and l
    return t.reshape(dA * dB, dA * dB)


def spectral_jordan_pair(x: Matrix) -> Tuple[Matrix, Matrix]:
    """Optimal primal solution: X = P - Q with P, Q >= 0 and tr P + tr Q = ||X||_1."""
    vals, vecs = np.linalg.eigh(x)
    pos = np.maximum(vals, 0.0)
    neg = np.maximum(-vals, 0.0)
    p = vecs @ np.diag(pos) @ vecs.conj().T
    q = vecs @ np.diag(neg) @ vecs.conj().T
    return p, q


def sign_operator(x: Matrix) -> Matrix:
    """Optimal dual certificate: W = U diag(sign(lambda)) U^dagger, a contraction."""
    vals, vecs = np.linalg.eigh(x)
    signs = np.where(vals >= 0.0, 1.0, -1.0)
    return vecs @ np.diag(signs) @ vecs.conj().T


def trace_norm(x: Matrix) -> float:
    """Trace norm of a Hermitian matrix: the sum of the absolute eigenvalues."""
    return float(np.sum(np.abs(np.linalg.eigvalsh(x))))


def is_psd(x: Matrix, tol: float = 1e-10) -> bool:
    """Positive semidefiniteness test, tolerant to floating-point noise."""
    return bool(np.min(np.linalg.eigvalsh(x)) >= -tol)


def is_contraction(w: Matrix, tol: float = 1e-10) -> bool:
    """Test -1 <= W <= 1 in the Loewner order."""
    n = w.shape[0]
    eye = np.eye(n, dtype=complex)
    return is_psd(eye - w, tol) and is_psd(eye + w, tol)


# --------------------------------------------------------------------------- #
#  Entanglement quantities
# --------------------------------------------------------------------------- #


def negativity(rho: Matrix, dA: int, dB: int) -> float:
    """N(rho) = (||Gamma rho||_1 - 1) / 2."""
    return (trace_norm(partial_transpose(rho, dA, dB)) - 1.0) / 2.0


def log_negativity(rho: Matrix, dA: int, dB: int) -> float:
    """E_N(rho) = log ||Gamma rho||_1."""
    return math.log(trace_norm(partial_transpose(rho, dA, dB)))


def is_ppt(rho: Matrix, dA: int, dB: int, tol: float = 1e-10) -> bool:
    return is_psd(partial_transpose(rho, dA, dB), tol)


# --------------------------------------------------------------------------- #
#  A small library of states
# --------------------------------------------------------------------------- #


def max_entangled(d: int) -> Matrix:
    """Projector onto (1/sqrt d) sum_i |ii>, a state on C^d (x) C^d."""
    vec = np.zeros(d * d, dtype=complex)
    for i in range(d):
        vec[i * d + i] = 1.0 / math.sqrt(d)
    return np.outer(vec, vec.conj())


def swap_matrix(d: int) -> Matrix:
    """The swap operator S|x>|y> = |y>|x>."""
    s = np.zeros((d * d, d * d), dtype=complex)
    for i, j in itertools.product(range(d), repeat=2):
        s[i * d + j, j * d + i] = 1.0
    return s


def werner_state(d: int, p: float) -> Matrix:
    """p * Phi_d + (1-p) * (maximally mixed state) on C^d (x) C^d."""
    n = d * d
    return p * max_entangled(d) + (1.0 - p) * np.eye(n, dtype=complex) / n


def product_state(rho_a: Matrix, rho_b: Matrix) -> Matrix:
    return np.kron(rho_a, rho_b)


def random_state(n: int, rank: int, rng: np.random.Generator) -> Matrix:
    """A random density matrix of given rank, drawn from a Ginibre ensemble."""
    g = rng.normal(size=(n, rank)) + 1j * rng.normal(size=(n, rank))
    rho = g @ g.conj().T
    return rho / np.trace(rho).real


def bell_diagonal(probs: Sequence[float]) -> Matrix:
    """Two-qubit Bell-diagonal state with the given weights on the four Bell states."""
    b = np.array(
        [
            [1, 0, 0, 1],
            [0, 1, 1, 0],
            [0, 1, -1, 0],
            [1, 0, 0, -1],
        ],
        dtype=complex,
    ) / math.sqrt(2.0)
    rho = np.zeros((4, 4), dtype=complex)
    for w, row in zip(probs, b):
        rho += w * np.outer(row, row.conj())
    return rho


# --------------------------------------------------------------------------- #
#  Regrouping of two bipartite systems: (A1 B1)(A2 B2) -> (A1 A2)(B1 B2)
# --------------------------------------------------------------------------- #


def tensor_bipartite(
    rho: Matrix, sigma: Matrix, dA1: int, dB1: int, dA2: int, dB2: int
) -> Matrix:
    """rho (x) sigma, regrouped so that A1 A2 face B1 B2 across the bipartite cut."""
    joint = np.kron(rho, sigma).reshape(dA1, dB1, dA2, dB2, dA1, dB1, dA2, dB2)
    joint = joint.transpose(0, 2, 1, 3, 4, 6, 5, 7)
    n = dA1 * dA2 * dB1 * dB2
    return joint.reshape(n, n)


# --------------------------------------------------------------------------- #
#  Channels and instruments
# --------------------------------------------------------------------------- #


def apply_local_unitary(rho: Matrix, ua: Matrix, ub: Matrix) -> Matrix:
    u = np.kron(ua, ub)
    return u @ rho @ u.conj().T


def haar_unitary(d: int, rng: np.random.Generator) -> Matrix:
    z = (rng.normal(size=(d, d)) + 1j * rng.normal(size=(d, d))) / math.sqrt(2.0)
    q, r = np.linalg.qr(z)
    return q @ np.diag(np.diag(r) / np.abs(np.diag(r)))


def local_depolarise(rho: Matrix, dA: int, dB: int, q: float) -> Matrix:
    """Depolarising noise of strength q applied to system B alone (a local channel)."""
    t = rho.reshape(dA, dB, dA, dB)
    reduced_a = np.einsum("ijkj->ik", t)  # partial trace over B
    return (1.0 - q) * rho + q * np.kron(reduced_a, np.eye(dB, dtype=complex) / dB)


def local_measurement_instrument(
    dA: int, dB: int, basis: Matrix
) -> List[Callable[[Matrix], Matrix]]:
    """A projective measurement on B in the given orthonormal basis (columns of `basis`)."""
    branches: List[Callable[[Matrix], Matrix]] = []
    for k in range(dB):
        proj = np.outer(basis[:, k], basis[:, k].conj())
        kraus = np.kron(np.eye(dA, dtype=complex), proj)

        def branch(x: Matrix, kraus: Matrix = kraus) -> Matrix:
            return kraus @ x @ kraus.conj().T

        branches.append(branch)
    return branches


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_variational_norm_and_duality(rng: np.random.Generator) -> None:
    banner("1. Variational trace norm, attainment, and strong duality")
    for n in (2, 4, 6):
        g = rng.normal(size=(n, n)) + 1j * rng.normal(size=(n, n))
        x = (g + g.conj().T) / 2.0
        p, q = spectral_jordan_pair(x)
        w = sign_operator(x)
        primal = float(np.trace(p).real + np.trace(q).real)
        dual = float(np.trace(x @ w).real)
        spectral = trace_norm(x)
        print(f"  size {n}:")
        print(f"    spectral value   sum |lambda_i| = {spectral: .10f}")
        print(f"    primal   tr P + tr Q            = {primal: .10f}   (P,Q >= 0: "
              f"{is_psd(p) and is_psd(q)},  X = P - Q: "
              f"{np.allclose(x, p - q)})")
        print(f"    dual     Re tr(X W)             = {dual: .10f}   "
              f"(W a contraction: {is_contraction(w)})")
        assert abs(primal - spectral) < 1e-8 and abs(dual - spectral) < 1e-8

        # Random suboptimal Jordan pairs never beat the optimum (primal feasibility).
        worst = -np.inf
        for _ in range(200):
            h = rng.normal(size=(n, n)) + 1j * rng.normal(size=(n, n))
            extra = h @ h.conj().T * rng.uniform(0.0, 0.5)
            p2, q2 = p + extra, q + extra
            cost = float(np.trace(p2).real + np.trace(q2).real)
            worst = max(worst, spectral - cost)
        print(f"    max( ||X||_1 - cost ) over 200 random feasible splittings "
              f"= {worst: .3e}  (must be <= 0)")
        assert worst <= 1e-9

        # Random contractions never beat the optimal certificate (dual feasibility).
        best = -np.inf
        for _ in range(200):
            m = rng.normal(size=(n, n)) + 1j * rng.normal(size=(n, n))
            herm = (m + m.conj().T) / 2.0
            scale = np.max(np.abs(np.linalg.eigvalsh(herm)))
            wr = herm / scale  # a contraction by construction
            best = max(best, float(np.trace(x @ wr).real) - spectral)
        print(f"    max( Re tr(X W) - ||X||_1 ) over 200 random contractions "
              f"= {best: .3e}  (must be <= 0)")
        assert best <= 1e-9


def demo_faithfulness() -> None:
    banner("2. Faithfulness: E_N(rho) = 0 exactly on PPT states (Werner family)")
    d = 3
    print("  Werner states  rho_p = p Phi_3 + (1-p) I/9  on C^3 (x) C^3.")
    print("  Theory: PPT exactly for p <= 1/(d+1) = 0.25.")
    print()
    print(f"  {'p':>8} {'||Gamma rho||_1':>17} {'N(rho)':>12} {'E_N(rho)':>12} {'PPT?':>7}")
    for p in [0.0, 0.1, 0.2, 0.25, 0.3, 0.5, 0.8, 1.0]:
        rho = werner_state(d, p)
        tn = trace_norm(partial_transpose(rho, d, d))
        neg = negativity(rho, d, d)
        en = log_negativity(rho, d, d)
        ppt = is_ppt(rho, d, d)
        print(f"  {p:8.3f} {tn:17.9f} {neg:12.6f} {en:12.6f} {str(ppt):>7}")
        assert ppt == (en < 1e-9)


def demo_max_entangled_and_dimension_bound(rng: np.random.Generator) -> None:
    banner("3. Dimension bound  E_N <= (1/2) log(d_A d_B),  saturated at Phi_d")
    for d in (2, 3, 4, 5):
        phi = max_entangled(d)
        s = swap_matrix(d)
        gamma_phi = partial_transpose(phi, d, d)
        print(f"  d = {d}:")
        print(f"    Gamma Phi_d = S/d ?                {np.allclose(gamma_phi, s / d)}")
        print(f"    ||S||_1 = d^2 ?                    {abs(trace_norm(s) - d * d) < 1e-9}"
              f"   (value {trace_norm(s):.6f})")
        print(f"    E_N(Phi_d)  = {log_negativity(phi, d, d):.9f}"
              f"   vs  log d = {math.log(d):.9f}")
        print(f"    bound (1/2) log(d^2) = {math.log(d * d) / 2:.9f}  -> saturated")
        assert abs(log_negativity(phi, d, d) - math.log(d)) < 1e-9

    print()
    print("  Random states never exceed the bound:")
    d = 3
    worst = -np.inf
    for _ in range(500):
        rank = int(rng.integers(1, d * d + 1))
        rho = random_state(d * d, rank, rng)
        worst = max(worst, log_negativity(rho, d, d) - math.log(d * d) / 2.0)
    print(f"    max( E_N - (1/2) log(d_A d_B) ) over 500 random 3x3 states "
          f"= {worst: .3e}  (must be <= 0)")
    assert worst <= 1e-9


def demo_monotonicity(rng: np.random.Generator) -> None:
    banner("4. Monotonicity under local operations, and strong monotonicity")
    d = 2
    rho = werner_state(d, 0.9)
    base = log_negativity(rho, d, d)
    print(f"  Start from a two-qubit Werner state with E_N = {base:.9f}")

    ua, ub = haar_unitary(d, rng), haar_unitary(d, rng)
    rotated = apply_local_unitary(rho, ua, ub)
    print(f"    after random local unitaries:      E_N = "
          f"{log_negativity(rotated, d, d):.9f}   (invariant)")
    assert abs(log_negativity(rotated, d, d) - base) < 1e-9

    print("    local depolarising noise on B (a local channel):")
    prev = base
    for q in [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0]:
        noisy = local_depolarise(rho, d, d, q)
        en = log_negativity(noisy, d, d)
        print(f"      q = {q:4.2f}:  E_N = {en:12.9f}   (non-increasing: {en <= prev + 1e-9})")
        assert en <= prev + 1e-9
        prev = en

    print()
    print("  Strong monotonicity for a local projective measurement on B:")
    basis = haar_unitary(d, rng)
    branches = local_measurement_instrument(d, d, basis)
    total = 0.0
    for k, branch in enumerate(branches):
        out = branch(rho)
        p_k = float(np.trace(out).real)
        if p_k < 1e-12:
            continue
        cond = out / p_k
        e_k = log_negativity(cond, d, d)
        total += p_k * e_k
        print(f"    outcome {k}: p = {p_k:.6f},  E_N(conditional state) = {e_k:.9f}")
    print(f"    sum_k p_k E_N(rho_k) = {total:.9f}   <=   E_N(rho) = {base:.9f}")
    assert total <= base + 1e-9


def demo_additivity(rng: np.random.Generator) -> None:
    banner("5. Multiplicativity of the trace norm and additivity of E_N")
    for n, m in [(2, 2), (2, 3), (3, 3), (4, 2)]:
        ga = rng.normal(size=(n, n)) + 1j * rng.normal(size=(n, n))
        gb = rng.normal(size=(m, m)) + 1j * rng.normal(size=(m, m))
        a = (ga + ga.conj().T) / 2.0
        b = (gb + gb.conj().T) / 2.0
        lhs = trace_norm(np.kron(a, b))
        rhs = trace_norm(a) * trace_norm(b)
        print(f"  Hermitian {n}x{n} (x) {m}x{m}:  ||A (x) B||_1 = {lhs:.10f}, "
              f"||A||_1 ||B||_1 = {rhs:.10f}")
        assert abs(lhs - rhs) < 1e-8

        # The tensor product of the two optimal certificates is again a contraction.
        w = np.kron(sign_operator(a), sign_operator(b))
        print(f"      W (x) V is a contraction: {is_contraction(w)};  "
              f"Re tr((A (x) B)(W (x) V)) = {float(np.trace(np.kron(a, b) @ w).real):.10f}")

    print()
    print("  Additivity of E_N and the product law for N:")
    cases = [
        ("Werner(0.9) (x) Werner(0.6), qubits", werner_state(2, 0.9), 2, 2,
         werner_state(2, 0.6), 2, 2),
        ("Phi_2 (x) Phi_3", max_entangled(2), 2, 2, max_entangled(3), 3, 3),
        ("Bell-diagonal (x) product state", bell_diagonal([0.7, 0.1, 0.1, 0.1]), 2, 2,
         product_state(np.eye(2) / 2, np.eye(2) / 2), 2, 2),
    ]
    for name, rho, da1, db1, sigma, da2, db2 in cases:
        joint = tensor_bipartite(rho, sigma, da1, db1, da2, db2)
        e1 = log_negativity(rho, da1, db1)
        e2 = log_negativity(sigma, da2, db2)
        e12 = log_negativity(joint, da1 * da2, db1 * db2)
        n1 = negativity(rho, da1, db1)
        n2 = negativity(sigma, da2, db2)
        n12 = negativity(joint, da1 * da2, db1 * db2)
        predicted = 2 * n1 * n2 + n1 + n2
        print(f"  {name}")
        print(f"    E_N(rho) + E_N(sigma) = {e1 + e2:.10f},   E_N(joint) = {e12:.10f}")
        print(f"    N law: 2 N1 N2 + N1 + N2 = {predicted:.10f},  N(joint) = {n12:.10f}")
        assert abs(e12 - (e1 + e2)) < 1e-8
        assert abs(n12 - predicted) < 1e-8


def demo_convexity(rng: np.random.Generator) -> None:
    banner("6. Convexity of the negativity under mixing")
    d = 2
    worst = -np.inf
    for _ in range(300):
        k = 3
        w = rng.dirichlet(np.ones(k))
        states = [random_state(d * d, int(rng.integers(1, d * d + 1)), rng) for _ in range(k)]
        mixed = sum(wi * s for wi, s in zip(w, states))
        lhs = negativity(mixed, d, d)
        rhs = sum(wi * negativity(s, d, d) for wi, s in zip(w, states))
        worst = max(worst, lhs - rhs)
    print(f"  max( N(mixture) - sum_i w_i N(rho_i) ) over 300 random mixtures "
          f"= {worst: .3e}  (must be <= 0)")
    assert worst <= 1e-9


def demo_distillation_bound() -> None:
    banner("7. Exact-distillation bounds and bound entanglement")
    d = 3
    ppt_werner = werner_state(d, 0.2)  # PPT since 0.2 < 1/(d+1) = 0.25
    print(f"  A PPT Werner state on C^3 (x) C^3 (p = 0.2):")
    print(f"    PPT?        {is_ppt(ppt_werner, d, d)}")
    print(f"    E_N(rho)  = {log_negativity(ppt_werner, d, d):.3e}")
    two_copies = tensor_bipartite(ppt_werner, ppt_werner, d, d, d, d)
    print(f"    E_N(rho (x) rho) = {log_negativity(two_copies, d * d, d * d):.3e}  "
          f"(still zero, by additivity)")
    print(f"    Target E_N(Phi_3) = {math.log(3):.6f} > 0, so no PPT (hence no LOCC) protocol")
    print(f"    can map rho (x) rho exactly to Phi_3.")
    assert log_negativity(two_copies, d * d, d * d) < 1e-9

    print()
    entangled = werner_state(d, 0.9)
    e = log_negativity(entangled, d, d)
    print(f"  A non-PPT Werner state (p = 0.9): E_N = {e:.6f}")
    for target_d in (2, 3):
        feasible = math.log(target_d) <= 2 * e + 1e-12
        print(f"    exact distillation of Phi_{target_d} from two copies requires "
              f"log {target_d} = {math.log(target_d):.6f} <= 2 E_N = {2 * e:.6f}: "
              f"{'not excluded' if feasible else 'EXCLUDED'}")


def main() -> None:
    rng = np.random.default_rng(20260813)
    print("Logarithmic negativity: numerical demonstration of the main results")
    demo_variational_norm_and_duality(rng)
    demo_faithfulness()
    demo_max_entangled_and_dimension_bound(rng)
    demo_monotonicity(rng)
    demo_additivity(rng)
    demo_convexity(rng)
    demo_distillation_bound()
    banner("All numerical checks passed.")


if __name__ == "__main__":
    main()
