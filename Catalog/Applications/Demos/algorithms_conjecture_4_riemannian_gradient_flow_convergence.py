#!/usr/bin/env python3
"""
Algorithms for SU(2) Optimization on the Principal Chart

This module implements the core algorithms for quantum gate synthesis
via gradient descent on the Frobenius loss landscape of SU(2).

All algorithms operate in Pauli coordinates (ℝ³), exploiting the
identification of traceless Hermitian 2×2 matrices with ℝ³.

Algorithms:
    1. principal_log         — O(1) closed-form principal logarithm
    2. qEMLnorm              — O(1) normalized quantum exponential map
    3. gradient_descent_su2  — O(N) certified gradient descent
    4. certified_convergence — Verified contraction checker
"""

import numpy as np
from typing import Tuple, Optional, List, NamedTuple


class ConvergenceResult(NamedTuple):
    """Result of a gradient descent run with convergence analysis."""
    trajectory: np.ndarray       # (N+1, 3) Pauli coordinates at each step
    losses: np.ndarray           # (N+1,) Frobenius loss at each step
    distances: np.ndarray        # (N+1,) distance to minimizer
    empirical_rate: float        # estimated contraction rate
    converged: bool              # whether final distance < tolerance
    n_steps: int                 # number of steps taken


def pauli_matrices() -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Return the three Pauli matrices σ₁, σ₂, σ₃.

    These form a basis for the Lie algebra su(2) ≅ ℝ³ of
    traceless Hermitian 2×2 matrices.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    s1 = np.array([[0, 1], [1, 0]], dtype=complex)
    s2 = np.array([[0, -1j], [1j, 0]], dtype=complex)
    s3 = np.array([[1, 0], [0, -1]], dtype=complex)
    return s1, s2, s3


def qEMLnorm(v: np.ndarray) -> np.ndarray:
    """
    Normalized quantum exponential map: ℝ³ → SU(2).

    Maps Pauli coordinates v = (x, y, z) to the SU(2) element:
        U = cos(‖v‖)·I + i·sinc(‖v‖)·(x·σ₁ + y·σ₂ + z·σ₃)

    This is the restriction of the matrix exponential exp(i·H) to
    traceless Hermitian matrices H, using the closed-form identity
    for 2×2 matrices.

    Args:
        v: Pauli coordinates, shape (3,)

    Returns:
        U: 2×2 unitary matrix in SU(2)

    Time complexity: O(1)
    Space complexity: O(1)
    """
    r = np.linalg.norm(v)
    I2 = np.eye(2, dtype=complex)
    s1, s2, s3 = pauli_matrices()

    if r < 1e-15:
        return I2

    sinc_r = np.sin(r) / r
    H = v[0] * s1 + v[1] * s2 + v[2] * s3
    return np.cos(r) * I2 + 1j * sinc_r * H


def principal_log(U: np.ndarray) -> np.ndarray:
    """
    Principal logarithm: SU(2)_{tr>0} → ℝ³.

    For a positive-trace SU(2) element U, computes the unique
    Pauli coordinate vector v with ‖v‖ < π such that qEMLnorm(v) = U.

    This is the inverse of qEMLnorm restricted to the principal ball.

    Mathematical identity:
        U = cos(r)·I + i·sin(r)·n̂·σ
        v = r·n̂  where r = arccos(tr(U)/2)

    Args:
        U: 2×2 unitary matrix with positive trace

    Returns:
        v: Pauli coordinates, shape (3,)

    Raises:
        ValueError: if tr(U) ≤ 0

    Time complexity: O(1)
    Space complexity: O(1)
    """
    a = np.real(np.trace(U)) / 2  # cos(r)
    if a <= 0:
        raise ValueError(f"Trace must be positive, got 2a = {2*a:.6f}")

    a = np.clip(a, -1, 1)
    r = np.arccos(a)

    if r < 1e-15:
        return np.zeros(3)

    s1, s2, s3 = pauli_matrices()
    sinc_r = np.sin(r) / r
    H = -1j * (U - a * np.eye(2, dtype=complex)) / sinc_r

    x = np.real(np.trace(H @ s1)) / 2
    y = np.real(np.trace(H @ s2)) / 2
    z = np.real(np.trace(H @ s3)) / 2

    return np.array([x, y, z])


def frobenius_loss(U_target: np.ndarray, v: np.ndarray) -> float:
    """
    Frobenius loss between qEMLnorm(v) and target.

    L(v) = ‖qEMLnorm(v) - U_target‖²_F

    In quaternion coordinates:
        L(v) = 4 - 4⟨q(v), q*⟩

    where ⟨·,·⟩ is the quaternion inner product.

    Args:
        U_target: target SU(2) element
        v: Pauli coordinates

    Returns:
        Non-negative real loss value

    Time complexity: O(1)
    Space complexity: O(1)
    """
    diff = qEMLnorm(v) - U_target
    return float(np.real(np.trace(diff.conj().T @ diff)))


def frobenius_gradient(U_target: np.ndarray, v: np.ndarray,
                       eps: float = 1e-7) -> np.ndarray:
    """
    Gradient of the Frobenius loss via central differences.

    Uses O(6) function evaluations for 3D gradient.

    Args:
        U_target: target SU(2) element
        v: Pauli coordinates
        eps: finite difference step size

    Returns:
        gradient vector, shape (3,)

    Time complexity: O(1)
    Space complexity: O(1)
    """
    grad = np.zeros(3)
    for i in range(3):
        v_plus = v.copy()
        v_minus = v.copy()
        v_plus[i] += eps
        v_minus[i] -= eps
        grad[i] = (frobenius_loss(U_target, v_plus) -
                   frobenius_loss(U_target, v_minus)) / (2 * eps)
    return grad


def gradient_descent_su2(
    U_target: np.ndarray,
    v0: Optional[np.ndarray] = None,
    eta: float = 0.05,
    n_steps: int = 1000,
    tol: float = 1e-12,
    verbose: bool = False
) -> ConvergenceResult:
    """
    Certified gradient descent on the SU(2) Frobenius loss.

    Runs gradient descent:
        v_{n+1} = v_n - η · ∇L(v_n)

    with convergence monitoring. By the radial contraction theorem
    (proved in Lean), for η < 1/4 and ‖v - v*‖ < π/2, each step
    contracts the distance to the minimizer.

    Args:
        U_target: target SU(2) element (must have positive trace)
        v0: initial Pauli coordinates (default: random near origin)
        eta: step size (must be < 1/4 for guaranteed contraction)
        n_steps: maximum number of gradient steps
        tol: convergence tolerance on distance to minimizer
        verbose: print progress every 100 steps

    Returns:
        ConvergenceResult with trajectory, losses, distances, and rate

    Time complexity: O(n_steps)
    Space complexity: O(n_steps) for trajectory storage
    """
    v_star = principal_log(U_target)

    if v0 is None:
        v0 = np.random.randn(3) * 0.3

    trajectory = np.zeros((n_steps + 1, 3))
    losses = np.zeros(n_steps + 1)
    distances = np.zeros(n_steps + 1)

    v = v0.copy()
    trajectory[0] = v
    losses[0] = frobenius_loss(U_target, v)
    distances[0] = np.linalg.norm(v - v_star)

    actual_steps = n_steps
    for step in range(n_steps):
        grad = frobenius_gradient(U_target, v)
        v = v - eta * grad

        trajectory[step + 1] = v
        losses[step + 1] = frobenius_loss(U_target, v)
        distances[step + 1] = np.linalg.norm(v - v_star)

        if verbose and (step + 1) % 100 == 0:
            print(f"  Step {step+1}: loss = {losses[step+1]:.2e}, "
                  f"dist = {distances[step+1]:.2e}")

        if distances[step + 1] < tol:
            actual_steps = step + 1
            trajectory = trajectory[:actual_steps + 1]
            losses = losses[:actual_steps + 1]
            distances = distances[:actual_steps + 1]
            break

    # Estimate convergence rate
    if actual_steps > 50:
        log_d = np.log(distances[-50:] + 1e-16)
        x = np.arange(len(log_d))
        slope, _ = np.polyfit(x, log_d, 1)
        rate = np.exp(slope)
    else:
        rate = 0.0

    converged = distances[-1] < tol

    return ConvergenceResult(
        trajectory=trajectory,
        losses=losses,
        distances=distances,
        empirical_rate=rate,
        converged=converged,
        n_steps=actual_steps
    )


def certified_convergence_check(
    U_target: np.ndarray,
    v: np.ndarray,
    eta: float
) -> Tuple[bool, str]:
    """
    Verify that a gradient descent step from v contracts toward
    the minimizer, using the certified radial contraction theorem.

    The theorem (proved in Lean) guarantees contraction when:
    1. 0 < η < 1/4
    2. |θ| < π/2 where θ = radial displacement from target

    Args:
        U_target: target SU(2) element
        v: current Pauli coordinates
        eta: step size

    Returns:
        (certified, message) where certified is True if the
        contraction theorem applies
    """
    v_star = principal_log(U_target)
    dist = np.linalg.norm(v - v_star)
    r_star = np.linalg.norm(v_star)

    checks = []

    # Check step size
    if not (0 < eta < 0.25):
        return False, f"Step size η = {eta} not in (0, 1/4)"
    checks.append(f"η = {eta:.4f} ∈ (0, 1/4) ✓")

    # Check principal ball
    r = np.linalg.norm(v)
    if r >= np.pi:
        return False, f"‖v‖ = {r:.4f} ≥ π, outside principal ball"
    checks.append(f"‖v‖ = {r:.4f} < π ✓")

    # Check positive-trace hemisphere
    if dist >= np.pi / 2:
        return False, f"Distance {dist:.4f} ≥ π/2, outside contraction region"
    checks.append(f"‖v - v*‖ = {dist:.4f} < π/2 ✓")

    msg = "Contraction certified:\n  " + "\n  ".join(checks)
    return True, msg


def conjectured_optimal_rate(r_star: float) -> float:
    """
    Compute the conjectured optimal convergence rate.

    Conjecture: For fixed-step gradient descent on the Frobenius loss,
    the optimal contraction factor is:
        ρ_opt = (1 - sinc(r*)) / (1 + sinc(r*))

    where r* = ‖v*‖ is the principal logarithm radius.

    Args:
        r_star: principal radius of target

    Returns:
        conjectured optimal rate ρ
    """
    if r_star < 1e-15:
        return 0.0
    sinc_r = np.sin(r_star) / r_star
    return abs((1 - sinc_r) / (1 + sinc_r))


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == '__main__':
    print("SU(2) Optimization Algorithms — Example Usage\n")

    # Create a random positive-trace target
    np.random.seed(42)
    r = 0.8
    n = np.array([1, 1, 1]) / np.sqrt(3)
    v_target = r * n
    U_target = qEMLnorm(v_target)

    print(f"Target: r* = {r:.4f}, n̂ = {n}")
    print(f"tr(U*) = {np.real(np.trace(U_target)):.4f}\n")

    # Run certified gradient descent
    result = gradient_descent_su2(
        U_target, eta=0.05, n_steps=500, verbose=True
    )

    print(f"\nConverged: {result.converged}")
    print(f"Steps: {result.n_steps}")
    print(f"Empirical rate: {result.empirical_rate:.6f}")
    print(f"Conjectured rate: {conjectured_optimal_rate(r):.6f}")

    # Check certification
    v_init = result.trajectory[0]
    certified, msg = certified_convergence_check(U_target, v_init, 0.05)
    print(f"\n{msg}")
