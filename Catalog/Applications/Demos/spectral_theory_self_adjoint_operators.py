#!/usr/bin/env python3
"""
Applications of Spectral Theory
================================
Real-world applications of the spectral theorem, Rayleigh quotient,
and functional calculus to physics, data science, and optimization.
"""

import numpy as np
from numpy.linalg import eigh, norm
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def pca_demo():
    """
    Principal Component Analysis via Spectral Theorem.

    PCA finds the directions of maximum variance in data,
    which are exactly the eigenvectors of the covariance matrix.
    The spectral theorem guarantees these directions are orthogonal.
    """
    print("=" * 60)
    print("APPLICATION 1: Principal Component Analysis (PCA)")
    print("=" * 60)

    np.random.seed(42)
    n_samples = 500

    # Generate correlated 3D data
    mean = [0, 0, 0]
    cov = [[5, 3, 1], [3, 4, 2], [1, 2, 2]]
    data = np.random.multivariate_normal(mean, cov, n_samples)

    # Compute covariance matrix (symmetric!)
    C = np.cov(data.T)
    print(f"\nCovariance matrix (symmetric):\n{np.round(C, 3)}")

    # Spectral theorem: C = Q D Q^T
    eigenvalues, Q = eigh(C)
    eigenvalues = eigenvalues[::-1]  # Sort descending
    Q = Q[:, ::-1]

    print(f"\nPrincipal values (eigenvalues): {np.round(eigenvalues, 3)}")
    total_var = np.sum(eigenvalues)
    for i, ev in enumerate(eigenvalues):
        print(f"  PC{i+1}: {ev:.3f} ({100*ev/total_var:.1f}% of variance)")

    print(f"\nOrthogonality check Q^T Q = I: {np.max(np.abs(Q.T @ Q - np.eye(3))):.2e}")

    # Project to 2D
    data_2d = data @ Q[:, :2]
    print(f"Dimensionality reduction: 3D → 2D preserves "
          f"{100*np.sum(eigenvalues[:2])/total_var:.1f}% of variance")

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    ax = axes[0]
    ax.scatter(data[:, 0], data[:, 1], alpha=0.3, s=10, c='steelblue')
    for i in range(2):
        ax.arrow(0, 0, Q[0, i] * eigenvalues[i], Q[1, i] * eigenvalues[i],
                head_width=0.2, head_length=0.1, fc=['red', 'green'][i],
                ec=['red', 'green'][i], linewidth=2)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_title('Original Data with Principal Directions')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.scatter(data_2d[:, 0], data_2d[:, 1], alpha=0.3, s=10, c='coral')
    ax.set_xlabel('PC1')
    ax.set_ylabel('PC2')
    ax.set_title('PCA Projection (2D)')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('pca_application.png', dpi=150, bbox_inches='tight')
    print("✓ PCA visualization saved")


def graph_laplacian_demo():
    """
    Graph Laplacian Spectral Analysis.

    The spectral theorem applied to the graph Laplacian reveals
    community structure and connectivity properties.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Graph Laplacian and Community Detection")
    print("=" * 60)

    # Create a graph with two communities
    n = 20
    p_within = 0.6   # Edge probability within community
    p_between = 0.05  # Edge probability between communities

    np.random.seed(123)
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            same_community = (i < n // 2) == (j < n // 2)
            p = p_within if same_community else p_between
            if np.random.rand() < p:
                adj[i, j] = adj[j, i] = 1

    # Laplacian L = D - A (symmetric!)
    degree = np.diag(np.sum(adj, axis=1))
    L = degree - adj

    print(f"Graph: {n} nodes, {int(np.sum(adj)/2)} edges")
    print(f"Laplacian is symmetric: {np.allclose(L, L.T)}")

    eigenvalues, eigenvectors = eigh(L)
    print(f"\nSmallest eigenvalues: {np.round(eigenvalues[:5], 4)}")
    print(f"Algebraic connectivity (λ₂): {eigenvalues[1]:.4f}")

    # Fiedler vector (eigenvector of λ₂) reveals partition
    fiedler = eigenvectors[:, 1]
    community_pred = (fiedler > 0).astype(int)
    community_true = np.array([0] * (n // 2) + [1] * (n // 2))

    accuracy = max(
        np.mean(community_pred == community_true),
        np.mean(community_pred != community_true)
    )
    print(f"\nCommunity detection accuracy: {100*accuracy:.1f}%")

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    ax = axes[0]
    ax.bar(range(len(eigenvalues)), eigenvalues, color='steelblue')
    ax.set_xlabel('Index')
    ax.set_ylabel('Eigenvalue')
    ax.set_title('Laplacian Spectrum')
    ax.axhline(0, color='gray', linewidth=0.5)

    ax = axes[1]
    colors = ['steelblue' if f > 0 else 'coral' for f in fiedler]
    ax.bar(range(n), fiedler, color=colors)
    ax.axhline(0, color='black', linewidth=1)
    ax.axvline(n // 2 - 0.5, color='red', linestyle='--', linewidth=2,
               label='True boundary')
    ax.set_xlabel('Node')
    ax.set_ylabel('Fiedler Vector Value')
    ax.set_title('Community Detection via Fiedler Vector')
    ax.legend()

    plt.tight_layout()
    plt.savefig('graph_laplacian.png', dpi=150, bbox_inches='tight')
    print("✓ Graph Laplacian visualization saved")


def quantum_evolution_demo():
    """
    Quantum Time Evolution via Functional Calculus.

    For a Hamiltonian H (Hermitian), time evolution is U(t) = exp(-iHt),
    computed via functional calculus.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Quantum Time Evolution")
    print("=" * 60)

    # Two-level quantum system (qubit)
    omega = 1.0  # Energy gap
    H = np.array([[omega/2, 0], [0, -omega/2]], dtype=complex)

    eigenvalues, U = eigh(H)
    print(f"Hamiltonian eigenvalues (energy levels): {eigenvalues}")

    # Initial state: superposition
    psi_0 = np.array([1, 1], dtype=complex) / np.sqrt(2)

    times = np.linspace(0, 4 * np.pi / omega, 200)
    probs_0 = []  # Probability of being in state |0⟩
    probs_1 = []  # Probability of being in state |1⟩
    expectations = []  # Expectation of H

    for t in times:
        # Time evolution: U(t) = exp(-iHt) via functional calculus
        U_t = U @ np.diag(np.exp(-1j * eigenvalues * t)) @ U.conj().T

        # Check unitarity
        assert np.allclose(U_t @ U_t.conj().T, np.eye(2), atol=1e-10)

        psi_t = U_t @ psi_0
        probs_0.append(abs(psi_t[0]) ** 2)
        probs_1.append(abs(psi_t[1]) ** 2)
        expectations.append(np.real(psi_t.conj() @ H @ psi_t))

    print(f"Energy conservation check:")
    print(f"  Max |⟨H⟩(t) - ⟨H⟩(0)| = {max(abs(e - expectations[0]) for e in expectations):.2e}")

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    ax = axes[0]
    ax.plot(times * omega / (2 * np.pi), probs_0, label='P(|0⟩)', linewidth=2)
    ax.plot(times * omega / (2 * np.pi), probs_1, label='P(|1⟩)', linewidth=2)
    ax.set_xlabel('Time (periods)')
    ax.set_ylabel('Probability')
    ax.set_title('Quantum State Evolution (Rabi Oscillation)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(times * omega / (2 * np.pi), expectations, 'k-', linewidth=2)
    ax.axhline(eigenvalues[0], color='red', linestyle='--', alpha=0.5,
               label=f'E_min = {eigenvalues[0]:.2f}')
    ax.axhline(eigenvalues[1], color='green', linestyle='--', alpha=0.5,
               label=f'E_max = {eigenvalues[1]:.2f}')
    ax.set_xlabel('Time (periods)')
    ax.set_ylabel('⟨H⟩')
    ax.set_title('Energy Expectation (Conserved!)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('quantum_evolution.png', dpi=150, bbox_inches='tight')
    print("✓ Quantum evolution visualization saved")


def sdp_relaxation_demo():
    """
    Semidefinite Programming Relaxation via Spectral Theory.

    The spectral theorem is the engine behind certifying feasibility
    and optimality in semidefinite programs.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Semidefinite Optimization")
    print("=" * 60)

    # MAX-CUT relaxation for a small graph
    n = 5
    np.random.seed(42)
    W = np.random.randint(0, 3, (n, n))
    W = (W + W.T) / 2
    np.fill_diagonal(W, 0)

    print(f"Weight matrix W:\n{W.astype(int)}")

    # Laplacian for MAX-CUT: L = diag(W·1) - W
    L = np.diag(W.sum(axis=1)) - W
    eigenvalues = np.linalg.eigvalsh(L)

    print(f"\nLaplacian eigenvalues: {np.round(eigenvalues, 3)}")
    print(f"SDP upper bound on MAX-CUT: {n * eigenvalues[-1] / 4:.3f}")

    # Spectral bound: max-cut ≤ n λ_max(L) / 4
    # Find actual max-cut by brute force for small n
    best_cut = 0
    for mask in range(2**n):
        x = np.array([(mask >> i) & 1 for i in range(n)]) * 2 - 1  # ±1
        cut_value = 0.25 * x @ L @ x
        best_cut = max(best_cut, cut_value)

    print(f"Actual MAX-CUT value: {best_cut:.3f}")
    print(f"Spectral bound ratio: {best_cut / (n * eigenvalues[-1] / 4):.3f}")
    print("✓ SDP relaxation verified")


if __name__ == '__main__':
    pca_demo()
    graph_laplacian_demo()
    quantum_evolution_demo()
    sdp_relaxation_demo()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Spectral Theory Demonstrations
==============================
Concrete numerical demonstrations of the spectral theorem, Rayleigh quotient,
functional calculus, and quantum observable properties for Hermitian matrices.
"""

import numpy as np
from numpy.linalg import eigh, norm
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

np.random.seed(42)

def demo_spectral_theorem():
    """Demonstrate the spectral theorem: A = U D U^*."""
    print("=" * 60)
    print("DEMO 1: Spectral Theorem for Hermitian Matrices")
    print("=" * 60)

    # Create a random Hermitian matrix
    n = 4
    B = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    A = (B + B.conj().T) / 2  # Make it Hermitian

    print(f"\nHermitian matrix A ({n}x{n}):")
    print(np.round(A, 3))

    # Check Hermiticity
    print(f"\nA = A^*? Max deviation: {np.max(np.abs(A - A.conj().T)):.2e}")

    # Eigendecomposition
    eigenvalues, U = eigh(A)
    print(f"\nEigenvalues (all real): {np.round(eigenvalues, 6)}")

    # Verify U is unitary
    print(f"U^* U = I? Max deviation: {np.max(np.abs(U.conj().T @ U - np.eye(n))):.2e}")

    # Reconstruct A
    D = np.diag(eigenvalues)
    A_reconstructed = U @ D @ U.conj().T
    print(f"A = U D U^*? Max deviation: {np.max(np.abs(A - A_reconstructed)):.2e}")

    print("\n✓ Spectral theorem verified numerically!")
    return eigenvalues, U, A


def demo_real_symmetric():
    """Demonstrate spectral theorem for real symmetric matrices."""
    print("\n" + "=" * 60)
    print("DEMO 2: Real Symmetric Matrix Diagonalization")
    print("=" * 60)

    n = 3
    B = np.random.randn(n, n)
    A = (B + B.T) / 2

    print(f"\nSymmetric matrix A ({n}x{n}):")
    print(np.round(A, 4))

    eigenvalues, Q = eigh(A)
    print(f"\nEigenvalues: {np.round(eigenvalues, 6)}")
    print(f"Q * Q^T = I? Max deviation: {np.max(np.abs(Q @ Q.T - np.eye(n))):.2e}")

    A_reconstructed = Q @ np.diag(eigenvalues) @ Q.T
    print(f"A = Q D Q^T? Max deviation: {np.max(np.abs(A - A_reconstructed)):.2e}")
    print("\n✓ Real orthogonal diagonalization verified!")


def demo_rayleigh_quotient():
    """Demonstrate Rayleigh quotient bounds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Rayleigh Quotient and Eigenvalue Bounds")
    print("=" * 60)

    n = 5
    B = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    A = (B + B.conj().T) / 2

    eigenvalues, U = eigh(A)
    lambda_min = eigenvalues[0]
    lambda_max = eigenvalues[-1]

    print(f"\nEigenvalues: {np.round(eigenvalues, 4)}")
    print(f"Min eigenvalue: {lambda_min:.4f}")
    print(f"Max eigenvalue: {lambda_max:.4f}")

    # Test with random vectors
    num_tests = 1000
    rayleigh_values = []
    for _ in range(num_tests):
        x = np.random.randn(n) + 1j * np.random.randn(n)
        rq = np.real(x.conj() @ A @ x) / np.real(x.conj() @ x)
        rayleigh_values.append(rq)
        assert lambda_min - 1e-10 <= rq <= lambda_max + 1e-10, \
            f"Rayleigh quotient {rq} out of bounds [{lambda_min}, {lambda_max}]"

    print(f"\nTested {num_tests} random vectors:")
    print(f"  Min Rayleigh quotient: {min(rayleigh_values):.4f} (should be ≥ {lambda_min:.4f})")
    print(f"  Max Rayleigh quotient: {max(rayleigh_values):.4f} (should be ≤ {lambda_max:.4f})")

    # Verify eigenvectors achieve the bounds
    for i, ev in enumerate(U.T):
        rq = np.real(ev.conj() @ A @ ev) / np.real(ev.conj() @ ev)
        print(f"  Eigenvector {i}: R(A, v) = {rq:.6f}, eigenvalue = {eigenvalues[i]:.6f}")

    print("\n✓ Rayleigh quotient bounds verified!")
    return rayleigh_values, eigenvalues


def demo_functional_calculus():
    """Demonstrate functional calculus via diagonalization."""
    print("\n" + "=" * 60)
    print("DEMO 4: Functional Calculus f(A) = U f(D) U^*")
    print("=" * 60)

    n = 4
    B = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    A = (B + B.conj().T) / 2

    eigenvalues, U = eigh(A)

    # f(A) = A^2 via functional calculus vs direct computation
    A_sq_direct = A @ A
    A_sq_fc = U @ np.diag(eigenvalues ** 2) @ U.conj().T
    print(f"\nA² via direct: matches functional calculus? "
          f"Max dev: {np.max(np.abs(A_sq_direct - A_sq_fc)):.2e}")

    # f(A) = exp(A)
    exp_A_fc = U @ np.diag(np.exp(eigenvalues)) @ U.conj().T
    print(f"exp(A) is Hermitian? Max dev from A^*: "
          f"{np.max(np.abs(exp_A_fc - exp_A_fc.conj().T)):.2e}")

    # Spectral mapping: spectrum(f(A)) = f(spectrum(A))
    exp_eigenvalues = np.sort(np.linalg.eigvalsh(exp_A_fc))
    expected_exp_eigenvalues = np.sort(np.exp(eigenvalues))
    print(f"\nSpectral mapping for exp:")
    print(f"  Eigenvalues of exp(A):   {np.round(exp_eigenvalues, 6)}")
    print(f"  exp(eigenvalues of A):   {np.round(expected_exp_eigenvalues, 6)}")
    print(f"  Max deviation: {np.max(np.abs(exp_eigenvalues - expected_exp_eigenvalues)):.2e}")

    # Polynomial p(x) = 2x^2 - 3x + 1
    p = lambda x: 2 * x**2 - 3 * x + 1
    p_A_fc = U @ np.diag(p(eigenvalues)) @ U.conj().T
    p_A_direct = 2 * A @ A - 3 * A + np.eye(n)
    print(f"\np(A) = 2A² - 3A + I:")
    print(f"  Direct vs functional calculus: "
          f"Max dev: {np.max(np.abs(p_A_direct - p_A_fc)):.2e}")

    print("\n✓ Functional calculus verified!")


def demo_quantum_observables():
    """Demonstrate quantum observable properties."""
    print("\n" + "=" * 60)
    print("DEMO 5: Quantum Observables and Expectation Values")
    print("=" * 60)

    n = 3

    # Pauli-like observable (Hermitian)
    sigma_z = np.array([[1, 0, 0], [0, 0, 0], [0, 0, -1]], dtype=complex)
    print(f"\nObservable (energy levels):\n{sigma_z.real.astype(int)}")

    eigenvalues = np.linalg.eigvalsh(sigma_z)
    print(f"Eigenvalues (energy levels): {eigenvalues}")

    # Various quantum states
    states = {
        "|0⟩": np.array([1, 0, 0], dtype=complex),
        "|1⟩": np.array([0, 1, 0], dtype=complex),
        "|2⟩": np.array([0, 0, 1], dtype=complex),
        "superposition": np.array([1, 1, 1], dtype=complex) / np.sqrt(3),
    }

    print(f"\nExpectation values ⟨ψ|A|ψ⟩:")
    for name, psi in states.items():
        psi = psi / norm(psi)  # normalize
        expectation = np.real(psi.conj() @ sigma_z @ psi)
        print(f"  {name:15s}: ⟨A⟩ = {expectation:.4f}  "
              f"(in [{eigenvalues[0]:.1f}, {eigenvalues[-1]:.1f}])")
        assert eigenvalues[0] - 1e-10 <= expectation <= eigenvalues[-1] + 1e-10

    # PSD matrix: expectation always nonneg
    print(f"\nPositive semidefinite test:")
    B_rand = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    PSD = B_rand @ B_rand.conj().T  # B B^* is always PSD
    psd_eigenvalues = np.linalg.eigvalsh(PSD)
    print(f"  PSD eigenvalues: {np.round(psd_eigenvalues, 4)} (all ≥ 0)")

    for _ in range(100):
        v = np.random.randn(n) + 1j * np.random.randn(n)
        exp_val = np.real(v.conj() @ PSD @ v)
        assert exp_val >= -1e-10, f"PSD expectation negative: {exp_val}"
    print(f"  100 random state tests: all expectations ≥ 0 ✓")

    print("\n✓ Quantum observable properties verified!")


def create_visualizations(rayleigh_values, eigenvalues):
    """Create publication-quality visualizations."""

    # Figure 1: Rayleigh quotient distribution
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Histogram of Rayleigh quotient values
    ax = axes[0]
    ax.hist(rayleigh_values, bins=50, density=True, alpha=0.7, color='steelblue',
            edgecolor='white', linewidth=0.5)
    for ev in eigenvalues:
        ax.axvline(ev, color='red', linestyle='--', linewidth=1.5, alpha=0.8)
    ax.axvline(eigenvalues[0], color='red', linestyle='--', linewidth=2,
               label=f'λ_min = {eigenvalues[0]:.2f}')
    ax.axvline(eigenvalues[-1], color='red', linestyle='--', linewidth=2,
               label=f'λ_max = {eigenvalues[-1]:.2f}')
    ax.set_xlabel('Rayleigh Quotient R(A, x)', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title('Distribution of Rayleigh Quotients', fontsize=13)
    ax.legend(fontsize=10)

    # Panel 2: Eigenvalue spectrum
    ax = axes[1]
    ax.barh(range(len(eigenvalues)), eigenvalues, color='coral', edgecolor='darkred',
            height=0.6)
    ax.set_yticks(range(len(eigenvalues)))
    ax.set_yticklabels([f'λ_{i+1}' for i in range(len(eigenvalues))], fontsize=12)
    ax.set_xlabel('Eigenvalue', fontsize=12)
    ax.set_title('Eigenvalue Spectrum', fontsize=13)
    ax.axvline(0, color='gray', linewidth=0.5)

    # Panel 3: Functional calculus demo
    ax = axes[2]
    x = np.linspace(eigenvalues[0] - 1, eigenvalues[-1] + 1, 200)
    functions = {
        'x²': lambda t: t**2,
        'exp(x)': lambda t: np.exp(t),
        '|x|': lambda t: np.abs(t),
    }
    for name, f in functions.items():
        ax.plot(x, f(x), label=name, linewidth=2)
        for ev in eigenvalues:
            ax.plot(ev, f(ev), 'o', markersize=8)
    ax.set_xlabel('λ (eigenvalue)', fontsize=12)
    ax.set_ylabel('f(λ)', fontsize=12)
    ax.set_title('Functional Calculus: f maps eigenvalues', fontsize=13)
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('spectral_theory_demo.png', dpi=150, bbox_inches='tight')
    plt.savefig('spectral_theory_demo.svg', bbox_inches='tight')
    print("\n✓ Visualizations saved to spectral_theory_demo.png/svg")

    # Figure 2: Rayleigh quotient on unit sphere (2D projection)
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Create a 2x2 Hermitian matrix for visualization
    A_2d = np.array([[3, 1], [1, 1]], dtype=float)
    evals_2d, evecs_2d = eigh(A_2d)

    theta = np.linspace(0, 2 * np.pi, 500)
    rq_values = []
    for t in theta:
        x = np.array([np.cos(t), np.sin(t)])
        rq = x @ A_2d @ x  # x is unit vector, so denominator is 1
        rq_values.append(rq)

    ax.plot(theta / np.pi, rq_values, 'b-', linewidth=2, label='R(A, x(θ))')
    ax.axhline(evals_2d[0], color='red', linestyle='--', linewidth=1.5,
               label=f'λ_min = {evals_2d[0]:.2f}')
    ax.axhline(evals_2d[1], color='green', linestyle='--', linewidth=1.5,
               label=f'λ_max = {evals_2d[1]:.2f}')

    # Mark eigenvector angles
    for i, ev in enumerate(evecs_2d.T):
        angle = np.arctan2(ev[1], ev[0])
        if angle < 0:
            angle += 2 * np.pi
        ax.axvline(angle / np.pi, color=['red', 'green'][i], linestyle=':',
                   alpha=0.5, linewidth=1)

    ax.set_xlabel('θ / π', fontsize=12)
    ax.set_ylabel('Rayleigh Quotient', fontsize=12)
    ax.set_title('Rayleigh Quotient on Unit Circle\n'
                 f'A = [[3,1],[1,1]], eigenvalues: {evals_2d.round(3)}',
                 fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('rayleigh_quotient_circle.png', dpi=150, bbox_inches='tight')
    print("✓ Rayleigh quotient visualization saved")


if __name__ == '__main__':
    eigenvalues_main, U_main, A_main = demo_spectral_theorem()
    demo_real_symmetric()
    rq_vals, evals = demo_rayleigh_quotient()
    demo_functional_calculus()
    demo_quantum_observables()
    create_visualizations(rq_vals, evals)
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)
