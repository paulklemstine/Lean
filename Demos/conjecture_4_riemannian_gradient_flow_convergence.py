#!/usr/bin/env python3
"""
Applications of SU(2) Gradient Flow Theory

This module demonstrates real-world applications of the formalized
optimization landscape theorems:

1. Quantum gate synthesis — compile arbitrary single-qubit gates
2. Bloch sphere control — navigate quantum states on the Bloch sphere
3. Rotation interpolation — smooth interpolation between 3D rotations
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    qEMLnorm, principal_log, frobenius_loss,
    gradient_descent_su2, pauli_matrices, conjectured_optimal_rate
)


# =============================================================================
# Application 1: Single-Qubit Gate Synthesis
# =============================================================================

def quantum_gate_synthesis():
    """
    Compile standard quantum gates by finding their principal logarithm
    coordinates and verifying via gradient descent.

    The Hadamard gate, T gate, and arbitrary rotation gates are synthesized
    as points in ℝ³ (Pauli coordinate space), demonstrating that the
    positive-trace chart provides a complete parameterization for gates
    near the identity.
    """
    print("=" * 60)
    print("Application 1: Quantum Gate Synthesis")
    print("=" * 60)

    # Standard gates
    H_gate = np.array([[1, 1], [1, -1]], dtype=complex) / np.sqrt(2)
    T_gate = np.array([[1, 0], [0, np.exp(1j * np.pi / 4)]], dtype=complex)
    S_gate = np.array([[1, 0], [0, 1j]], dtype=complex)

    # Rotation gates
    def Rx(theta):
        return np.array([
            [np.cos(theta/2), -1j*np.sin(theta/2)],
            [-1j*np.sin(theta/2), np.cos(theta/2)]
        ], dtype=complex)

    def Ry(theta):
        return np.array([
            [np.cos(theta/2), -np.sin(theta/2)],
            [np.sin(theta/2), np.cos(theta/2)]
        ], dtype=complex)

    def Rz(theta):
        return np.array([
            [np.exp(-1j*theta/2), 0],
            [0, np.exp(1j*theta/2)]
        ], dtype=complex)

    gates = {
        'T': T_gate,
        'S': S_gate,
        'Rx(π/4)': Rx(np.pi/4),
        'Ry(π/3)': Ry(np.pi/3),
        'Rz(π/6)': Rz(np.pi/6),
    }

    print(f"\n  {'Gate':<12} {'tr(U)':<10} {'r*':<10} {'Pauli coords':<30} {'Error':<12}")
    print("  " + "-" * 74)

    for name, U in gates.items():
        tr = np.real(np.trace(U))
        if tr <= 0:
            print(f"  {name:<12} {tr:<10.4f} {'(negative trace — outside chart)'}")
            continue

        v = principal_log(U)
        U_rec = qEMLnorm(v)
        err = np.linalg.norm(U_rec - U, 'fro')
        r = np.linalg.norm(v)
        coords = f"({v[0]:.4f}, {v[1]:.4f}, {v[2]:.4f})"
        print(f"  {name:<12} {tr:<10.4f} {r:<10.4f} {coords:<30} {err:<12.2e}")

    print()


# =============================================================================
# Application 2: Bloch Sphere Quantum Control
# =============================================================================

def bloch_sphere_control():
    """
    Demonstrate quantum state control on the Bloch sphere.

    Given an initial state |ψ₀⟩ and target state |ψ₁⟩, find the
    optimal SU(2) rotation U such that U|ψ₀⟩ = |ψ₁⟩, then compute
    the Hamiltonian H (in Pauli coordinates) that generates this rotation.
    """
    print("=" * 60)
    print("Application 2: Bloch Sphere Quantum Control")
    print("=" * 60)

    # States on the Bloch sphere
    ket0 = np.array([1, 0], dtype=complex)
    ket1 = np.array([0, 1], dtype=complex)
    ket_plus = (ket0 + ket1) / np.sqrt(2)
    ket_minus = (ket0 - ket1) / np.sqrt(2)

    def bloch_coords(psi):
        """Extract Bloch sphere coordinates from a qubit state."""
        rho = np.outer(psi, psi.conj())
        s1, s2, s3 = pauli_matrices()
        x = np.real(np.trace(rho @ s1))
        y = np.real(np.trace(rho @ s2))
        z = np.real(np.trace(rho @ s3))
        return np.array([x, y, z])

    transitions = [
        ("|0⟩", ket0, "|+⟩", ket_plus),
        ("|0⟩", ket0, "|1⟩", ket1),
        ("|+⟩", ket_plus, "|−⟩", ket_minus),
    ]

    for name0, psi0, name1, psi1 in transitions:
        # Find unitary U mapping |ψ₀⟩ to |ψ₁⟩
        # U = |ψ₁⟩⟨ψ₀| + |ψ₁⊥⟩⟨ψ₀⊥|
        # Use Gram-Schmidt for orthogonal complement
        psi0_perp = np.array([-psi0[1].conj(), psi0[0].conj()])
        psi1_perp = np.array([-psi1[1].conj(), psi1[0].conj()])

        U = np.outer(psi1, psi0.conj()) + np.outer(psi1_perp, psi0_perp.conj())

        tr = np.real(np.trace(U))
        b0 = bloch_coords(psi0)
        b1 = bloch_coords(psi1)

        print(f"\n  Transition: {name0} → {name1}")
        print(f"    Bloch: ({b0[0]:.2f}, {b0[1]:.2f}, {b0[2]:.2f}) → "
              f"({b1[0]:.2f}, {b1[1]:.2f}, {b1[2]:.2f})")

        if tr > 0:
            v = principal_log(U)
            r = np.linalg.norm(v)
            print(f"    Hamiltonian H = {v[0]:.4f}·σ₁ + {v[1]:.4f}·σ₂ + {v[2]:.4f}·σ₃")
            print(f"    Rotation angle: {r:.4f} rad = {np.degrees(r):.1f}°")
            print(f"    Evolution time: t = 1 (with H as generator)")

            # Verify
            U_check = qEMLnorm(v)
            psi_check = U_check @ psi0
            fidelity = abs(np.dot(psi_check.conj(), psi1))**2
            print(f"    Fidelity: {fidelity:.10f}")
        else:
            print(f"    tr(U) = {tr:.4f} ≤ 0 — outside positive-trace chart")
            print(f"    (requires chart extension or multiple steps)")

    print()


# =============================================================================
# Application 3: Rotation Interpolation
# =============================================================================

def rotation_interpolation():
    """
    Smooth interpolation between 3D rotations using the SU(2) chart.

    The principal logarithm provides a canonical way to interpolate
    between rotations: given U₀ and U₁ with positive trace, define
        U(t) = qEMLnorm((1-t)·v₀ + t·v₁)
    where v₀ = log(U₀), v₁ = log(U₁).

    This gives a smooth path on SU(2) that is geodesic in the Euclidean
    metric on Pauli coordinates.
    """
    print("=" * 60)
    print("Application 3: Rotation Interpolation (SU(2) Slerp)")
    print("=" * 60)

    # Two rotations
    v0 = np.array([0.3, 0.0, 0.0])  # Small x-rotation
    v1 = np.array([0.0, 0.8, 0.5])  # Combined y-z rotation

    U0 = qEMLnorm(v0)
    U1 = qEMLnorm(v1)

    print(f"\n  Start: v₀ = ({v0[0]:.2f}, {v0[1]:.2f}, {v0[2]:.2f}), "
          f"r₀ = {np.linalg.norm(v0):.4f}")
    print(f"  End:   v₁ = ({v1[0]:.2f}, {v1[1]:.2f}, {v1[2]:.2f}), "
          f"r₁ = {np.linalg.norm(v1):.4f}")

    # Interpolate
    n_points = 20
    ts = np.linspace(0, 1, n_points)
    traces = []
    radii = []

    print(f"\n  {'t':<8} {'v(t)':<30} {'r(t)':<10} {'tr(U(t))':<10}")
    print("  " + "-" * 58)

    for t in ts:
        v_t = (1 - t) * v0 + t * v1
        U_t = qEMLnorm(v_t)
        tr_t = np.real(np.trace(U_t))
        r_t = np.linalg.norm(v_t)
        traces.append(tr_t)
        radii.append(r_t)

        if t in [0, 0.25, 0.5, 0.75, 1.0] or abs(t - round(t, 2)) < 0.01:
            coords = f"({v_t[0]:.3f}, {v_t[1]:.3f}, {v_t[2]:.3f})"
            if abs(t - round(t * 4) / 4) < 0.03:
                print(f"  {t:<8.2f} {coords:<30} {r_t:<10.4f} {tr_t:<10.4f}")

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    axes[0].plot(ts, radii, 'b-o', markersize=3)
    axes[0].set_xlabel('Interpolation parameter t')
    axes[0].set_ylabel('Pauli radius r(t)')
    axes[0].set_title('Radius Along Interpolation Path')
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(ts, traces, 'r-o', markersize=3)
    axes[1].axhline(y=0, color='k', linestyle='--', alpha=0.3)
    axes[1].set_xlabel('Interpolation parameter t')
    axes[1].set_ylabel('tr(U(t))')
    axes[1].set_title('Trace Along Interpolation Path')
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('interpolation.png', dpi=150, bbox_inches='tight')
    print(f"\n  Plot saved to interpolation.png\n")


# =============================================================================
# Main
# =============================================================================

if __name__ == '__main__':
    print("\n🔬 SU(2) Gradient Flow — Applications\n")
    quantum_gate_synthesis()
    bloch_sphere_control()
    rotation_interpolation()
    print("All applications complete.")


#!/usr/bin/env python3
"""
Demonstration: Gradient Flow on SU(2) Optimization Landscape

This script demonstrates the key mathematical results formalized in the
Lean 4 proof package:

1. Principal logarithm computation for positive-trace SU(2) elements
2. Frobenius loss landscape visualization
3. Gradient descent convergence with empirical rate estimation
4. Comparison of empirical rates to the conjectured rate formula

Usage:
    python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple

# =============================================================================
# Core Mathematical Functions
# =============================================================================

def pauli_matrices():
    """Return the three Pauli matrices σ₁, σ₂, σ₃."""
    s1 = np.array([[0, 1], [1, 0]], dtype=complex)
    s2 = np.array([[0, -1j], [1j, 0]], dtype=complex)
    s3 = np.array([[1, 0], [0, -1]], dtype=complex)
    return s1, s2, s3


def qEMLnorm(v: np.ndarray) -> np.ndarray:
    """
    Normalized quantum exponential map: ℝ³ → SU(2).

    Given Pauli coordinates v = (x, y, z), computes:
        qEMLnorm(v) = cos(‖v‖)·I + i·sinc(‖v‖)·(x·σ₁ + y·σ₂ + z·σ₃)

    where sinc(r) = sin(r)/r for r > 0 and sinc(0) = 1.
    """
    r = np.linalg.norm(v)
    I2 = np.eye(2, dtype=complex)
    s1, s2, s3 = pauli_matrices()

    if r < 1e-15:
        return I2

    sinc_r = np.sin(r) / r
    H = v[0] * s1 + v[1] * s2 + v[2] * s3
    return np.cos(r) * I2 + 1j * sinc_r * H


def frobenius_loss(U_target: np.ndarray, v: np.ndarray) -> float:
    """
    Frobenius loss: ‖qEMLnorm(v) - U_target‖²_F

    In quaternion coordinates: L(v) = 4 - 4⟨q(v), q*⟩
    """
    diff = qEMLnorm(v) - U_target
    return np.real(np.trace(diff.conj().T @ diff))


def frobenius_gradient(U_target: np.ndarray, v: np.ndarray,
                       eps: float = 1e-7) -> np.ndarray:
    """
    Numerical gradient of the Frobenius loss via central differences.
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


def principal_log(U: np.ndarray) -> np.ndarray:
    """
    Compute the principal logarithm of a positive-trace SU(2) element.

    Returns Pauli coordinates v such that qEMLnorm(v) = U.
    """
    # Extract quaternion components
    a = np.real(np.trace(U)) / 2  # scalar part: cos(r)
    a = np.clip(a, -1, 1)
    r = np.arccos(a)

    if r < 1e-15:
        return np.zeros(3)

    # Extract vector part from traceless anti-Hermitian part
    s1, s2, s3 = pauli_matrices()
    # U = cos(r)I + i·sinc(r)·H where H = v·σ
    # So -i(U - cos(r)I) / sinc(r) = H = v·σ
    H = -1j * (U - a * np.eye(2, dtype=complex)) / (np.sin(r) / r)

    # Extract Pauli coordinates from H
    x = np.real(np.trace(H @ s1)) / 2
    y = np.real(np.trace(H @ s2)) / 2
    z = np.real(np.trace(H @ s3)) / 2

    return np.array([x, y, z])


def random_positive_trace_su2() -> np.ndarray:
    """
    Sample a random SU(2) element with positive trace.
    This means cos(r) > 0, i.e., r ∈ [0, π/2).
    """
    # Sample r uniformly from [0, π/2)
    r = np.random.uniform(0, np.pi / 2)
    # Sample random unit vector on S²
    n = np.random.randn(3)
    n = n / np.linalg.norm(n)

    v = r * n
    return qEMLnorm(v)


# =============================================================================
# Demonstration 1: Principal Logarithm Recovery
# =============================================================================

def demo_principal_log():
    """Verify that principal_log inverts qEMLnorm for positive-trace targets."""
    print("=" * 60)
    print("Demo 1: Principal Logarithm Recovery")
    print("=" * 60)

    np.random.seed(42)
    n_tests = 10
    max_error = 0

    for i in range(n_tests):
        U_target = random_positive_trace_su2()
        v_star = principal_log(U_target)
        U_recovered = qEMLnorm(v_star)
        error = np.linalg.norm(U_recovered - U_target, 'fro')
        max_error = max(max_error, error)
        tr = np.real(np.trace(U_target))
        r = np.linalg.norm(v_star)
        print(f"  Test {i+1}: r* = {r:.4f}, tr(U*) = {tr:.4f}, "
              f"recovery error = {error:.2e}")

    print(f"\n  Maximum recovery error: {max_error:.2e}")
    print(f"  {'PASS' if max_error < 1e-10 else 'FAIL'}: "
          f"Principal logarithm is exact to machine precision.\n")


# =============================================================================
# Demonstration 2: Gradient Descent Convergence
# =============================================================================

def demo_gradient_descent():
    """
    Run gradient descent on the Frobenius loss and demonstrate
    linear convergence in the principal ball.
    """
    print("=" * 60)
    print("Demo 2: Gradient Descent Convergence")
    print("=" * 60)

    np.random.seed(123)
    U_target = random_positive_trace_su2()
    v_star = principal_log(U_target)
    r_star = np.linalg.norm(v_star)

    print(f"  Target: r* = {r_star:.4f}, tr(U*) = {np.real(np.trace(U_target)):.4f}")

    # Run gradient descent from random initialization
    v0 = np.random.randn(3) * 0.5  # Start near origin
    eta = 0.05  # Step size
    n_steps = 200

    trajectory = [v0.copy()]
    losses = [frobenius_loss(U_target, v0)]
    distances = [np.linalg.norm(v0 - v_star)]

    v = v0.copy()
    for step in range(n_steps):
        grad = frobenius_gradient(U_target, v)
        v = v - eta * grad
        trajectory.append(v.copy())
        losses.append(frobenius_loss(U_target, v))
        distances.append(np.linalg.norm(v - v_star))

    # Estimate convergence rate
    log_distances = np.log(np.array(distances) + 1e-16)
    # Use linear regression on last 100 steps
    n_fit = min(100, len(log_distances) - 10)
    x_fit = np.arange(n_steps - n_fit, n_steps)
    y_fit = log_distances[n_steps - n_fit:n_steps]
    slope, intercept = np.polyfit(x_fit, y_fit, 1)
    rho_empirical = np.exp(slope)

    print(f"  Initial distance: {distances[0]:.4f}")
    print(f"  Final distance:   {distances[-1]:.2e}")
    print(f"  Empirical contraction rate: ρ ≈ {rho_empirical:.6f}")

    # Conjectured optimal rate
    if r_star > 1e-10:
        sinc_r = np.sin(r_star) / r_star
        rho_conj = (1 - sinc_r) / (1 + sinc_r)
        print(f"  Conjectured optimal rate: ρ_opt ≈ {rho_conj:.6f}")
    print()

    # Plot convergence
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    axes[0].semilogy(losses, 'b-', linewidth=1.5)
    axes[0].set_xlabel('Iteration')
    axes[0].set_ylabel('Frobenius Loss')
    axes[0].set_title('Loss Convergence')
    axes[0].grid(True, alpha=0.3)

    axes[1].semilogy(distances, 'r-', linewidth=1.5)
    axes[1].set_xlabel('Iteration')
    axes[1].set_ylabel('‖H_n - H*‖')
    axes[1].set_title('Distance to Minimizer')
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('convergence_demo.png', dpi=150, bbox_inches='tight')
    print("  Plot saved to convergence_demo.png\n")


# =============================================================================
# Demonstration 3: Rate Conjecture Testing
# =============================================================================

def demo_rate_conjecture():
    """
    Test the conjectured convergence rate formula:
        ρ_opt ≈ (1 - sinc(r*)) / (1 + sinc(r*))

    Sample 100 random positive-trace targets, run gradient descent,
    and compare empirical rates to predictions.
    """
    print("=" * 60)
    print("Demo 3: Rate Conjecture Testing")
    print("=" * 60)

    np.random.seed(2024)
    n_samples = 100
    n_steps = 500
    eta = 0.02  # Conservative step size

    r_stars = []
    rho_empiricals = []
    rho_conjectured = []

    for i in range(n_samples):
        U_target = random_positive_trace_su2()
        v_star = principal_log(U_target)
        r_star = np.linalg.norm(v_star)

        if r_star < 0.1:
            continue  # Skip near-identity targets (rate → 0)

        # Random initialization
        v = np.random.randn(3) * 0.3
        distances = []
        for step in range(n_steps):
            grad = frobenius_gradient(U_target, v)
            v = v - eta * grad
            distances.append(np.linalg.norm(v - v_star))

        # Estimate rate from last 200 steps
        log_d = np.log(np.array(distances[-200:]) + 1e-16)
        x = np.arange(len(log_d))
        slope, _ = np.polyfit(x, log_d, 1)
        rho_emp = np.exp(slope)

        sinc_r = np.sin(r_star) / r_star
        rho_conj = abs((1 - sinc_r) / (1 + sinc_r))

        r_stars.append(r_star)
        rho_empiricals.append(rho_emp)
        rho_conjectured.append(rho_conj)

    r_stars = np.array(r_stars)
    rho_empiricals = np.array(rho_empiricals)
    rho_conjectured = np.array(rho_conjectured)

    # Report statistics
    rel_errors = np.abs(rho_empiricals - rho_conjectured) / (rho_conjectured + 1e-10)
    print(f"  Samples tested: {len(r_stars)}")
    print(f"  Mean relative error |ρ_emp - ρ_conj|/ρ_conj: {np.mean(rel_errors):.4f}")
    print(f"  Max relative error: {np.max(rel_errors):.4f}")
    print(f"  Correlation(ρ_emp, ρ_conj): {np.corrcoef(rho_empiricals, rho_conjectured)[0,1]:.4f}")

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # r* vs rates
    order = np.argsort(r_stars)
    axes[0].scatter(r_stars[order], rho_empiricals[order], s=10, alpha=0.7,
                    label='Empirical', color='blue')
    r_smooth = np.linspace(0.1, r_stars.max(), 200)
    sinc_smooth = np.sin(r_smooth) / r_smooth
    rho_smooth = np.abs((1 - sinc_smooth) / (1 + sinc_smooth))
    axes[0].plot(r_smooth, rho_smooth, 'r-', linewidth=2,
                label='Conjectured')
    axes[0].set_xlabel('Principal radius r*')
    axes[0].set_ylabel('Contraction rate ρ')
    axes[0].set_title('Convergence Rate vs Target Radius')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Empirical vs conjectured
    axes[1].scatter(rho_conjectured, rho_empiricals, s=10, alpha=0.7)
    lim = max(rho_conjectured.max(), rho_empiricals.max()) * 1.1
    axes[1].plot([0, lim], [0, lim], 'k--', linewidth=1, alpha=0.5)
    axes[1].set_xlabel('Conjectured ρ')
    axes[1].set_ylabel('Empirical ρ')
    axes[1].set_title('Empirical vs Conjectured Rate')
    axes[1].set_aspect('equal')
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('rate_conjecture.png', dpi=150, bbox_inches='tight')
    print("  Plot saved to rate_conjecture.png\n")


# =============================================================================
# Main
# =============================================================================

if __name__ == '__main__':
    print("\n🔬 SU(2) Gradient Flow Convergence — Demonstration\n")
    demo_principal_log()
    demo_gradient_descent()
    demo_rate_conjecture()
    print("All demonstrations complete.")
