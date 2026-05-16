#!/usr/bin/env python3
"""
Applications of the Spectral Theorem
=====================================
Real-world applications demonstrating the spectral theorem in action:
- Principal Component Analysis (PCA) for dimensionality reduction
- Vibration mode analysis (structural engineering)
- Quantum measurement simulation
- Image compression via SVD (spectral theorem for AᵀA)
"""

import numpy as np
from numpy.linalg import eigh, norm, svd
from typing import Tuple


def pca_analysis(data: np.ndarray, n_components: int = 2) -> dict:
    """
    Principal Component Analysis using the spectral theorem.

    The covariance matrix C = XᵀX/n is symmetric, so by our theorem
    `exists_orthogonal_diagonalization`, C = Q D Qᵀ where Q's columns
    are the principal directions and D's diagonal entries are the variances.

    Args:
        data: n_samples × n_features matrix
        n_components: number of principal components to keep

    Returns:
        dict with eigenvalues, eigenvectors, projected data, explained variance
    """
    # Center the data
    mean = data.mean(axis=0)
    X = data - mean

    # Covariance matrix (symmetric!)
    n = X.shape[0]
    C = X.T @ X / n

    # Spectral decomposition
    eigenvalues, eigenvectors = eigh(C)

    # Sort by decreasing eigenvalue
    idx = eigenvalues.argsort()[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    # Project onto top components
    projection = X @ eigenvectors[:, :n_components]
    explained_variance = eigenvalues[:n_components].sum() / eigenvalues.sum()

    return {
        'eigenvalues': eigenvalues,
        'eigenvectors': eigenvectors,
        'projection': projection,
        'explained_variance': explained_variance,
        'n_components': n_components,
        'mean': mean
    }


def vibration_modes(stiffness: np.ndarray, mass: np.ndarray) -> dict:
    """
    Normal mode analysis for a mechanical system.

    The generalized eigenvalue problem K φ = ω² M φ is solved by
    reducing to M^{-1/2} K M^{-1/2} ψ = ω² ψ, which is a standard
    symmetric eigenvalue problem (the spectral theorem applies!).

    Natural frequencies are ω_i = √λ_i and mode shapes are the eigenvectors.

    Args:
        stiffness: n×n symmetric positive definite stiffness matrix K
        mass: n×n symmetric positive definite mass matrix M

    Returns:
        dict with natural frequencies, mode shapes, and modal masses
    """
    # Cholesky factorization of mass matrix
    L = np.linalg.cholesky(mass)
    L_inv = np.linalg.inv(L)

    # Transform to standard eigenvalue problem
    A = L_inv @ stiffness @ L_inv.T  # symmetric!

    eigenvalues, eigenvectors = eigh(A)

    # Natural frequencies
    frequencies = np.sqrt(np.maximum(eigenvalues, 0)) / (2 * np.pi)

    # Transform back to physical coordinates
    mode_shapes = L_inv.T @ eigenvectors

    # Modal masses
    modal_masses = np.array([
        mode_shapes[:, i] @ mass @ mode_shapes[:, i]
        for i in range(len(eigenvalues))
    ])

    return {
        'frequencies': frequencies,
        'eigenvalues': eigenvalues,
        'mode_shapes': mode_shapes,
        'modal_masses': modal_masses
    }


def quantum_measurement_simulation(
    hamiltonian: np.ndarray,
    state: np.ndarray,
    n_measurements: int = 10000
) -> dict:
    """
    Simulate quantum measurement of an observable.

    A quantum observable is a Hermitian (self-adjoint) operator H.
    By the spectral theorem, H = Σ λ_i |e_i⟩⟨e_i|.
    Measurement yields eigenvalue λ_i with probability |⟨e_i|ψ⟩|².

    For real symmetric H on ℝⁿ, this is exactly our formalized theorem.

    Args:
        hamiltonian: n×n real symmetric matrix (observable)
        state: n-dim state vector (will be normalized)
        n_measurements: number of simulated measurements

    Returns:
        dict with eigenvalues, probabilities, measurement statistics
    """
    state = state / norm(state)

    # Spectral decomposition
    eigenvalues, eigenvectors = eigh(hamiltonian)

    # Born probabilities: P(λ_i) = |⟨e_i|ψ⟩|²
    amplitudes = eigenvectors.T @ state
    probabilities = np.abs(amplitudes) ** 2

    # Simulate measurements
    measurements = np.random.choice(
        eigenvalues,
        size=n_measurements,
        p=probabilities
    )

    return {
        'eigenvalues': eigenvalues,
        'eigenvectors': eigenvectors,
        'probabilities': probabilities,
        'measurements': measurements,
        'expected_value': eigenvalues @ probabilities,
        'variance': (eigenvalues**2) @ probabilities - (eigenvalues @ probabilities)**2,
        'measured_mean': measurements.mean(),
        'measured_std': measurements.std()
    }


if __name__ == "__main__":
    np.random.seed(42)

    # ========================================
    # Application 1: PCA
    # ========================================
    print("=" * 60)
    print("APPLICATION 1: Principal Component Analysis")
    print("=" * 60)

    # Generate 3D data with clear 2D structure
    n = 500
    t = np.random.randn(n)
    s = np.random.randn(n) * 0.5
    noise = np.random.randn(n) * 0.05
    data = np.column_stack([
        3*t + s,
        2*t - s + noise,
        t + 2*s + noise
    ])

    result = pca_analysis(data, n_components=2)
    print(f"\nData shape: {data.shape}")
    print(f"Eigenvalues: {result['eigenvalues']}")
    print(f"Explained variance (2 components): {result['explained_variance']:.4f}")
    print(f"Principal directions:")
    for i in range(3):
        print(f"  PC{i+1}: {result['eigenvectors'][:, i]}")

    # ========================================
    # Application 2: Vibration Modes
    # ========================================
    print("\n" + "=" * 60)
    print("APPLICATION 2: Vibration Mode Analysis (3-DOF Spring-Mass)")
    print("=" * 60)

    # 3 masses connected by springs
    k1, k2, k3 = 100, 200, 150  # spring constants (N/m)
    m1, m2, m3 = 1, 2, 1.5     # masses (kg)

    K = np.array([
        [k1 + k2, -k2,     0],
        [-k2,     k2 + k3, -k3],
        [0,       -k3,     k3]
    ], dtype=float)

    M = np.diag([m1, m2, m3]).astype(float)

    result = vibration_modes(K, M)
    print(f"\nStiffness matrix K =\n{K}")
    print(f"Mass matrix M = diag({[m1, m2, m3]})")
    print(f"\nNatural frequencies: {result['frequencies']} Hz")
    print(f"Mode shapes:")
    for i, f in enumerate(result['frequencies']):
        shape = result['mode_shapes'][:, i]
        print(f"  Mode {i+1} ({f:.2f} Hz): {shape / max(abs(shape))}")

    # ========================================
    # Application 3: Quantum Measurement
    # ========================================
    print("\n" + "=" * 60)
    print("APPLICATION 3: Quantum Measurement Simulation")
    print("=" * 60)

    # Spin-1 observable (symmetric 3x3)
    Sz = np.array([
        [1,  0,  0],
        [0,  0,  0],
        [0,  0, -1]
    ], dtype=float)

    # Superposition state
    psi = np.array([1, 1, 1], dtype=float) / np.sqrt(3)

    result = quantum_measurement_simulation(Sz, psi)
    print(f"\nObservable (Sz for spin-1):\n{Sz}")
    print(f"State: |ψ⟩ = {psi}")
    print(f"\nPossible outcomes (eigenvalues): {result['eigenvalues']}")
    print(f"Born probabilities: {result['probabilities']}")
    print(f"\nTheoretical ⟨Sz⟩ = {result['expected_value']:.6f}")
    print(f"Measured mean ({len(result['measurements'])} trials) = {result['measured_mean']:.6f}")
    print(f"Theoretical σ = {np.sqrt(result['variance']):.6f}")
    print(f"Measured σ = {result['measured_std']:.6f}")

    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Spectral Theorem Demonstration
==============================
Concrete numerical examples illustrating the finite-dimensional spectral theorem
for real symmetric matrices: eigenvalue reality, eigenvector orthogonality,
orthogonal diagonalization, and the Rayleigh quotient.
"""

import numpy as np
from numpy.linalg import eigh, norm

np.set_printoptions(precision=6, suppress=True)


def demo_orthogonal_diagonalization():
    """Demonstrate A = Q D Qᵀ for a symmetric matrix."""
    print("=" * 60)
    print("DEMO 1: Orthogonal Diagonalization of a Symmetric Matrix")
    print("=" * 60)

    # A symmetric 4x4 matrix
    A = np.array([
        [4, 1, 2, 0],
        [1, 3, 0, 1],
        [2, 0, 5, 2],
        [0, 1, 2, 6]
    ], dtype=float)

    print(f"\nA =\n{A}")
    print(f"\nA is symmetric: {np.allclose(A, A.T)}")

    # Compute eigendecomposition
    eigenvalues, Q = eigh(A)  # eigh guarantees real eigenvalues + orthogonal Q
    D = np.diag(eigenvalues)

    print(f"\nEigenvalues (all real): {eigenvalues}")
    print(f"\nQ (orthogonal matrix) =\n{Q}")
    print(f"\nQᵀQ =\n{Q.T @ Q}")
    print(f"QQᵀ =\n{Q @ Q.T}")
    print(f"\nD (diagonal) =\n{D}")

    # Verify A = Q D Qᵀ
    reconstructed = Q @ D @ Q.T
    print(f"\nQ D Qᵀ =\n{reconstructed}")
    print(f"\n‖A - Q D Qᵀ‖ = {norm(A - reconstructed):.2e}")


def demo_eigenvector_orthogonality():
    """Show eigenvectors for distinct eigenvalues are orthogonal."""
    print("\n" + "=" * 60)
    print("DEMO 2: Eigenvector Orthogonality for Distinct Eigenvalues")
    print("=" * 60)

    A = np.array([
        [2, 1, 0],
        [1, 3, 1],
        [0, 1, 2]
    ], dtype=float)

    eigenvalues, eigenvectors = eigh(A)

    print(f"\nA =\n{A}")
    print(f"\nEigenvalues: {eigenvalues}")

    for i in range(len(eigenvalues)):
        for j in range(i + 1, len(eigenvalues)):
            dot = np.dot(eigenvectors[:, i], eigenvectors[:, j])
            print(f"  ⟪v_{i+1}, v_{j+1}⟫ = {dot:.2e}  "
                  f"(λ_{i+1}={eigenvalues[i]:.4f}, λ_{j+1}={eigenvalues[j]:.4f})")


def demo_rayleigh_quotient():
    """Show the Rayleigh quotient equals the eigenvalue at eigenvectors."""
    print("\n" + "=" * 60)
    print("DEMO 3: Rayleigh Quotient R(v) = ⟪v, Av⟫ / ⟪v, v⟫")
    print("=" * 60)

    A = np.array([
        [5, 2],
        [2, 3]
    ], dtype=float)

    eigenvalues, eigenvectors = eigh(A)

    print(f"\nA =\n{A}")

    for i, (lam, v) in enumerate(zip(eigenvalues, eigenvectors.T)):
        R = (v @ A @ v) / (v @ v)
        print(f"\n  Eigenvector v_{i+1} = {v}")
        print(f"  Eigenvalue λ_{i+1}  = {lam:.6f}")
        print(f"  R_A(v_{i+1})        = {R:.6f}")
        print(f"  |R_A(v) - λ|       = {abs(R - lam):.2e}")

    # Show R(v) for random vectors stays between min and max eigenvalue
    print(f"\n  Rayleigh quotient bounds: [{eigenvalues[0]:.4f}, {eigenvalues[-1]:.4f}]")
    for _ in range(5):
        v = np.random.randn(2)
        R = (v @ A @ v) / (v @ v)
        print(f"  Random v: R_A(v) = {R:.4f}")


def demo_graph_spectrum():
    """Spectral decomposition of a graph adjacency matrix."""
    print("\n" + "=" * 60)
    print("DEMO 4: Graph Spectral Decomposition")
    print("=" * 60)

    # Complete graph K4
    n = 4
    A_K4 = np.ones((n, n)) - np.eye(n)
    print(f"\nAdjacency matrix of K₄ (complete graph on 4 vertices):")
    print(A_K4)

    eigenvalues, Q = eigh(A_K4)
    print(f"\nEigenvalues: {eigenvalues}")
    print(f"(Theory predicts: one eigenvalue {n-1}, rest are -1)")

    # Cycle graph C5
    n = 5
    A_C5 = np.zeros((n, n))
    for i in range(n):
        A_C5[i, (i + 1) % n] = 1
        A_C5[(i + 1) % n, i] = 1
    print(f"\nAdjacency matrix of C₅ (cycle on 5 vertices):")
    print(A_C5)
    print(f"Symmetric: {np.allclose(A_C5, A_C5.T)}")

    eigenvalues, Q = eigh(A_C5)
    print(f"Eigenvalues: {eigenvalues}")
    print(f"Qᵀ Q ≈ I: {np.allclose(Q.T @ Q, np.eye(n))}")


def demo_pca_application():
    """PCA as an application of the spectral theorem."""
    print("\n" + "=" * 60)
    print("DEMO 5: PCA via the Spectral Theorem")
    print("=" * 60)

    np.random.seed(42)
    # Generate correlated 3D data
    n_samples = 1000
    true_directions = np.array([[3, 1, 0.5], [0, 2, 1], [0, 0, 0.1]])
    data = np.random.randn(n_samples, 3) @ true_directions
    data -= data.mean(axis=0)

    # Covariance matrix (symmetric!)
    C = data.T @ data / n_samples
    print(f"\nCovariance matrix (symmetric by construction):")
    print(f"{C}")
    print(f"\nSymmetric: {np.allclose(C, C.T)}")

    eigenvalues, eigenvectors = eigh(C)
    # Sort by decreasing eigenvalue
    idx = eigenvalues.argsort()[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    print(f"\nPrincipal component eigenvalues (variance explained):")
    total_var = eigenvalues.sum()
    for i, lam in enumerate(eigenvalues):
        print(f"  PC{i+1}: λ = {lam:.4f} ({100*lam/total_var:.1f}% of variance)")

    print(f"\nPrincipal directions (orthonormal by spectral theorem):")
    for i in range(3):
        print(f"  PC{i+1}: {eigenvectors[:, i]}")

    # Verify orthonormality
    print(f"\nOrthonormality check:")
    for i in range(3):
        for j in range(i, 3):
            dot = np.dot(eigenvectors[:, i], eigenvectors[:, j])
            print(f"  ⟪PC{i+1}, PC{j+1}⟫ = {dot:.6f}")


if __name__ == "__main__":
    demo_orthogonal_diagonalization()
    demo_eigenvector_orthogonality()
    demo_rayleigh_quotient()
    demo_graph_spectrum()
    demo_pca_application()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for the Spectral Theorem
========================================
Generate publication-quality figures illustrating key concepts.
"""

import numpy as np
from numpy.linalg import eigh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_eigenvector_orthogonality():
    """Visualize orthogonal eigenvectors of a 2D symmetric matrix."""
    A = np.array([[3, 1], [1, 2]], dtype=float)
    eigenvalues, eigenvectors = eigh(A)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: show how A transforms vectors
    ax = axes[0]
    theta = np.linspace(0, 2*np.pi, 100)
    circle = np.array([np.cos(theta), np.sin(theta)])
    ellipse = A @ circle

    ax.plot(circle[0], circle[1], 'b--', alpha=0.3, label='Unit circle')
    ax.plot(ellipse[0], ellipse[1], 'r-', linewidth=2, label='A · (unit circle)')

    for i, (lam, v) in enumerate(zip(eigenvalues, eigenvectors.T)):
        color = ['#2196F3', '#FF5722'][i]
        ax.annotate('', xy=v*1.5, xytext=(0, 0),
                     arrowprops=dict(arrowstyle='->', color=color, lw=2.5))
        ax.annotate('', xy=A @ v * 0.5, xytext=(0, 0),
                     arrowprops=dict(arrowstyle='->', color=color, lw=1.5, ls='--'))
        ax.text(v[0]*1.7, v[1]*1.7, f'$v_{i+1}$ (λ={lam:.2f})',
                fontsize=12, color=color, fontweight='bold')

    ax.set_xlim(-4, 4)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_title('Symmetric Matrix Action on Unit Circle', fontsize=14)
    ax.legend(fontsize=11)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    # Right: orthogonality verification
    ax = axes[1]
    v1, v2 = eigenvectors[:, 0], eigenvectors[:, 1]

    ax.annotate('', xy=v1, xytext=(0, 0),
                 arrowprops=dict(arrowstyle='->', color='#2196F3', lw=3))
    ax.annotate('', xy=v2, xytext=(0, 0),
                 arrowprops=dict(arrowstyle='->', color='#FF5722', lw=3))

    # Draw right angle marker
    scale = 0.15
    corner = scale * (v1/np.linalg.norm(v1) + v2/np.linalg.norm(v2))
    p1 = scale * v1/np.linalg.norm(v1)
    p2 = scale * v2/np.linalg.norm(v2)
    ax.plot([p1[0], corner[0]], [p1[1], corner[1]], 'k-', lw=1.5)
    ax.plot([p2[0], corner[0]], [p2[1], corner[1]], 'k-', lw=1.5)

    ax.text(v1[0]*1.15, v1[1]*1.15, f'$v_1$ (λ₁={eigenvalues[0]:.2f})',
            fontsize=13, color='#2196F3', fontweight='bold')
    ax.text(v2[0]*1.15, v2[1]*1.15, f'$v_2$ (λ₂={eigenvalues[1]:.2f})',
            fontsize=13, color='#FF5722', fontweight='bold')

    dot = np.dot(v1, v2)
    ax.text(0.05, -0.4, f'⟨v₁, v₂⟩ = {dot:.2e}\n(orthogonal!)',
            fontsize=13, style='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_title('Orthogonal Eigenvectors', fontsize=14)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    fig.suptitle('The Spectral Theorem: Eigenvectors of Symmetric Matrices Are Orthogonal',
                 fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_rayleigh_quotient():
    """Visualize the Rayleigh quotient as a function on the unit circle."""
    A = np.array([[4, 1], [1, 2]], dtype=float)
    eigenvalues, eigenvectors = eigh(A)

    theta = np.linspace(0, 2*np.pi, 500)
    rayleigh = np.array([
        np.array([np.cos(t), np.sin(t)]) @ A @ np.array([np.cos(t), np.sin(t)])
        for t in theta
    ])

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(np.degrees(theta), rayleigh, 'b-', linewidth=2.5, label='R_A(v(θ))')
    ax.axhline(y=eigenvalues[0], color='#FF5722', linestyle='--', linewidth=2,
               label=f'λ_min = {eigenvalues[0]:.3f}')
    ax.axhline(y=eigenvalues[1], color='#2196F3', linestyle='--', linewidth=2,
               label=f'λ_max = {eigenvalues[1]:.3f}')

    # Mark eigenvector positions
    for i, (lam, v) in enumerate(zip(eigenvalues, eigenvectors.T)):
        angle = np.degrees(np.arctan2(v[1], v[0]))
        if angle < 0:
            angle += 360
        ax.plot(angle, lam, 'o', markersize=12, color=['#FF5722', '#2196F3'][i],
                zorder=5)
        ax.annotate(f'v_{i+1}', (angle, lam), textcoords="offset points",
                    xytext=(10, 10), fontsize=12, fontweight='bold',
                    color=['#FF5722', '#2196F3'][i])

    ax.fill_between(np.degrees(theta), eigenvalues[0], rayleigh,
                     alpha=0.1, color='blue')

    ax.set_xlabel('Angle θ (degrees)', fontsize=13)
    ax.set_ylabel('Rayleigh Quotient R_A(v)', fontsize=13)
    ax.set_title('Rayleigh Quotient: Eigenvalues as Extrema\n'
                 'R_A(v) = ⟨v, Av⟩/⟨v, v⟩ on the unit circle',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12, loc='center right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 360)

    fig.tight_layout()
    return fig_to_base64(fig)


def viz_convergence_comparison():
    """Compare convergence of power iteration vs Rayleigh quotient iteration."""
    A = np.array([[5, 2, 1], [2, 4, 2], [1, 2, 3]], dtype=float)
    true_eigenvalues = sorted(eigh(A)[0], reverse=True)
    true_max = true_eigenvalues[0]

    np.random.seed(42)
    v0 = np.random.randn(3)
    v0 /= np.linalg.norm(v0)

    # Power iteration
    v = v0.copy()
    power_hist = []
    for _ in range(30):
        w = A @ v
        lam = v @ w
        power_hist.append(abs(lam - true_max))
        v = w / np.linalg.norm(w)

    # Rayleigh quotient iteration
    v = v0.copy()
    sigma = v @ A @ v
    rqi_hist = []
    I = np.eye(3)
    for _ in range(10):
        rqi_hist.append(abs(sigma - true_max))
        if abs(sigma - true_max) < 1e-15:
            break
        try:
            w = np.linalg.solve(A - sigma * I, v)
        except np.linalg.LinAlgError:
            break
        v = w / np.linalg.norm(w)
        sigma = v @ A @ v

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.semilogy(range(len(power_hist)), power_hist, 'bo-', linewidth=2,
                markersize=6, label='Power Iteration (linear)')
    ax.semilogy(range(len(rqi_hist)), rqi_hist, 'rs-', linewidth=2,
                markersize=8, label='Rayleigh Quotient Iteration (cubic)')

    ax.set_xlabel('Iteration', fontsize=13)
    ax.set_ylabel('|λ_k - λ_true|', fontsize=13)
    ax.set_title('Convergence Comparison: Power vs Rayleigh Quotient Iteration\n'
                 'The spectral theorem guarantees convergence to an eigenvalue',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-16)

    fig.tight_layout()
    return fig_to_base64(fig)


def viz_graph_spectrum():
    """Visualize the spectrum of different graph types."""
    graphs = {}

    # Complete graph K5
    n = 5
    A = np.ones((n, n)) - np.eye(n)
    graphs['K₅ (Complete)'] = A

    # Cycle C6
    n = 6
    A = np.zeros((n, n))
    for i in range(n):
        A[i, (i+1) % n] = A[(i+1) % n, i] = 1
    graphs['C₆ (Cycle)'] = A

    # Path P6
    n = 6
    A = np.zeros((n, n))
    for i in range(n-1):
        A[i, i+1] = A[i+1, i] = 1
    graphs['P₆ (Path)'] = A

    # Star S5
    n = 6
    A = np.zeros((n, n))
    for i in range(1, n):
        A[0, i] = A[i, 0] = 1
    graphs['S₆ (Star)'] = A

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    for ax, (name, adj) in zip(axes.flat, graphs.items()):
        eigenvalues = eigh(adj)[0]
        n = len(eigenvalues)

        ax.bar(range(n), sorted(eigenvalues), color='steelblue',
               edgecolor='navy', alpha=0.8)
        ax.set_xlabel('Index', fontsize=11)
        ax.set_ylabel('Eigenvalue', fontsize=11)
        ax.set_title(f'{name}', fontsize=13, fontweight='bold')
        ax.grid(True, alpha=0.3, axis='y')
        ax.axhline(y=0, color='k', linewidth=0.5)

        # Annotate
        evals_str = ', '.join(f'{e:.2f}' for e in sorted(eigenvalues))
        ax.text(0.02, 0.98, f'λ: {evals_str}', transform=ax.transAxes,
                fontsize=9, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    fig.suptitle('Graph Spectra: Eigenvalues of Adjacency Matrices\n'
                 '(All real, by the spectral theorem for symmetric matrices)',
                 fontsize=14, fontweight='bold')
    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_ortho = viz_eigenvector_orthogonality()
    print(f"1. Eigenvector orthogonality: {len(b64_ortho)} chars")

    b64_rayleigh = viz_rayleigh_quotient()
    print(f"2. Rayleigh quotient: {len(b64_rayleigh)} chars")

    b64_convergence = viz_convergence_comparison()
    print(f"3. Convergence comparison: {len(b64_convergence)} chars")

    b64_graph = viz_graph_spectrum()
    print(f"4. Graph spectra: {len(b64_graph)} chars")

    print("All visualizations generated successfully.")
