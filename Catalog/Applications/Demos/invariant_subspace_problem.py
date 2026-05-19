#!/usr/bin/env python3
"""
Applications of Invariant Subspace Theory

Demonstrates real-world applications across multiple domains:
1. Quantum mechanics: measurement subspaces and observable decomposition
2. Dynamical systems: Koopman operator mode decomposition
3. Control theory: controllability/observability decomposition
4. Signal processing: principal component analysis via compact operators
5. PDE spectral methods: eigenfunction expansion for the heat equation
"""

import numpy as np
from numpy.linalg import norm, eig, eigh, svd
from typing import Tuple, List


# =============================================================================
# Application 1: Quantum Mechanics
# =============================================================================

def quantum_measurement_subspaces():
    """
    Quantum observables are self-adjoint operators.
    Their eigenspaces are the measurement subspaces — the possible
    outcomes of a quantum measurement.
    
    Example: A spin-1 particle has observable S_z with eigenvalues -1, 0, +1.
    The eigenspaces decompose the Hilbert space into measurement outcomes.
    """
    print("=" * 70)
    print("APPLICATION 1: Quantum Measurement Subspaces")
    print("=" * 70)
    
    # Spin-1 operator S_z in the |+1⟩, |0⟩, |-1⟩ basis
    S_z = np.diag([1.0, 0.0, -1.0]).astype(complex)
    
    # S_x for spin-1
    S_x = np.array([
        [0, 1, 0],
        [1, 0, 1],
        [0, 1, 0]
    ], dtype=complex) / np.sqrt(2)
    
    # S_y for spin-1
    S_y = np.array([
        [0, -1j, 0],
        [1j, 0, -1j],
        [0, 1j, 0]
    ], dtype=complex) / np.sqrt(2)
    
    print("\nSpin-1 particle observables:")
    print(f"S_z eigenvalues: {np.sort(np.real(eigh(S_z)[0]))}")
    print(f"S_x eigenvalues: {np.sort(np.real(eigh(S_x)[0]))}")
    
    # Prepare a quantum state
    psi = np.array([1, 1, 1], dtype=complex) / np.sqrt(3)
    print(f"\nQuantum state |ψ⟩ = (1/√3)(|+1⟩ + |0⟩ + |-1⟩)")
    
    # Measurement probabilities = projections onto eigenspaces
    evals, evecs = eigh(S_z)
    print(f"\nS_z measurement probabilities:")
    for i, ev in enumerate(evals):
        proj = np.abs(np.vdot(evecs[:, i], psi))**2
        print(f"  P(S_z = {ev:+.0f}) = |⟨{ev:+.0f}|ψ⟩|² = {proj:.4f}")
    
    # After measurement: state collapses to eigenspace (invariant subspace)
    print(f"\nAfter measuring S_z = +1:")
    print(f"  State collapses to eigenspace span{{|+1⟩}}")
    print(f"  This eigenspace is INVARIANT under S_z")
    print(f"  Further S_z measurements always give +1")
    
    # Superselection sectors as reducing subspaces
    # Total spin S² = S_x² + S_y² + S_z²
    S_sq = S_x @ S_x + S_y @ S_y + S_z @ S_z
    print(f"\nTotal spin S² eigenvalues: {np.sort(np.real(eigh(S_sq)[0]))}")
    print(f"  (All = 2 for spin-1, confirming s(s+1) = 1·2 = 2)")
    print(f"  Each eigenspace of S² is a superselection sector")
    print(f"  = a REDUCING subspace invariant under all rotations")
    
    # Time evolution preserves invariant subspaces
    # H = ω·S_z (Zeeman Hamiltonian in magnetic field)
    omega = 2.0
    H = omega * S_z
    t = 1.0
    U = np.diag(np.exp(-1j * np.diag(H) * t))  # Time evolution
    
    print(f"\nTime evolution under H = ω·S_z:")
    print(f"  U(t) = exp(-iHt) preserves each S_z eigenspace")
    psi_t = U @ psi
    for i, ev in enumerate(evals):
        proj_0 = np.abs(np.vdot(evecs[:, i], psi))**2
        proj_t = np.abs(np.vdot(evecs[:, i], psi_t))**2
        print(f"  P(S_z={ev:+.0f}): t=0: {proj_0:.4f}, t={t}: {proj_t:.4f}")
    print(f"  Measurement probabilities unchanged ✓ (invariant subspaces)")


# =============================================================================
# Application 2: Koopman Operator / Dynamical Systems
# =============================================================================

def koopman_mode_decomposition():
    """
    The Koopman operator linearizes nonlinear dynamics by acting on
    observable functions. Its invariant subspaces correspond to
    coherent dynamical modes.
    
    Example: Linear rotation system x' = Ax, where A has complex eigenvalues.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Koopman Mode Decomposition")
    print("=" * 70)
    
    # Discrete-time linear system: x_{k+1} = A x_k
    # A represents a damped oscillation
    theta = 0.3  # rotation angle
    rho = 0.95   # damping factor
    A = rho * np.array([
        [np.cos(theta), -np.sin(theta)],
        [np.sin(theta),  np.cos(theta)]
    ])
    
    print(f"\nDynamical system: x_{{k+1}} = A x_k")
    print(f"A = {rho:.2f} × Rotation({theta:.2f} rad)")
    
    evals, evecs = eig(A)
    print(f"\nKoopman eigenvalues: {evals}")
    print(f"  |λ₁| = {abs(evals[0]):.4f} (damping rate)")
    print(f"  arg(λ₁) = {np.angle(evals[0]):.4f} rad (oscillation frequency)")
    
    # Simulate trajectory
    x0 = np.array([1.0, 0.5])
    n_steps = 50
    trajectory = np.zeros((n_steps, 2))
    trajectory[0] = x0
    for k in range(1, n_steps):
        trajectory[k] = A @ trajectory[k-1]
    
    # Koopman mode decomposition
    # Project initial condition onto eigenvectors
    coeffs = np.linalg.solve(evecs, x0)
    
    print(f"\nKoopman mode decomposition of trajectory:")
    print(f"  x(k) = Σᵢ cᵢ λᵢᵏ φᵢ")
    for i in range(2):
        print(f"  Mode {i+1}: c = {coeffs[i]:.4f}, λ = {evals[i]:.4f}")
        print(f"    φ = {evecs[:, i]}")
    
    # Verify reconstruction
    errors = []
    for k in range(n_steps):
        x_reconstructed = sum(
            coeffs[i] * evals[i]**k * evecs[:, i] for i in range(2)
        )
        errors.append(norm(trajectory[k] - np.real(x_reconstructed)))
    
    print(f"\n  Reconstruction error: max = {max(errors):.2e}")
    print(f"  Each Koopman eigenfunction spans a 1-d invariant subspace")
    print(f"  of the Koopman operator K: Kφ = λφ")


# =============================================================================
# Application 3: Control Theory
# =============================================================================

def controllability_decomposition():
    """
    The controllability decomposition splits the state space into
    controllable and uncontrollable subspaces — both invariant
    under the system dynamics.
    
    Example: A 4-state system where only 2 states are controllable.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Controllability/Observability Decomposition")
    print("=" * 70)
    
    # System: dx/dt = Ax + Bu, y = Cx
    A = np.array([
        [-1, 0, 0, 0],
        [0, -2, 0, 0],
        [1, 0, -3, 0],
        [0, 1, 0, -4]
    ], dtype=float)
    
    B = np.array([
        [1],
        [0],
        [0],
        [0]
    ], dtype=float)
    
    C = np.array([[1, 0, 1, 0]], dtype=float)
    
    print(f"\nLinear system: dx/dt = Ax + Bu, y = Cx")
    print(f"State dimension: n = {A.shape[0]}")
    print(f"Input dimension: m = {B.shape[1]}")
    print(f"Output dimension: p = {C.shape[0]}")
    
    # Controllability matrix: C = [B, AB, A²B, A³B]
    n = A.shape[0]
    ctrl_matrix = np.hstack([
        np.linalg.matrix_power(A, k) @ B for k in range(n)
    ])
    
    ctrl_rank = np.linalg.matrix_rank(ctrl_matrix, tol=1e-10)
    print(f"\nControllability matrix rank: {ctrl_rank} (out of {n})")
    
    # Controllable subspace (range of controllability matrix)
    U, S, Vt = svd(ctrl_matrix)
    ctrl_basis = U[:, :ctrl_rank]
    unctrl_basis = U[:, ctrl_rank:]
    
    print(f"Controllable subspace dimension: {ctrl_rank}")
    print(f"Uncontrollable subspace dimension: {n - ctrl_rank}")
    
    # Verify invariance: A maps controllable subspace to itself
    A_ctrl = ctrl_basis.T @ A @ ctrl_basis
    A_cross = unctrl_basis.T @ A @ ctrl_basis
    print(f"\nInvariance check:")
    print(f"  ‖A₂₁‖ (cross-coupling) = {norm(A_cross):.2e} ≈ 0")
    print(f"  Controllable subspace IS invariant under A ✓")
    
    # Observability matrix
    obs_matrix = np.vstack([
        C @ np.linalg.matrix_power(A, k) for k in range(n)
    ])
    obs_rank = np.linalg.matrix_rank(obs_matrix, tol=1e-10)
    print(f"\nObservability matrix rank: {obs_rank} (out of {n})")
    
    # Kalman decomposition: 4 invariant subspaces
    print(f"\nKalman canonical decomposition:")
    print(f"  Controllable + Observable:     dim ≈ {min(ctrl_rank, obs_rank)}")
    print(f"  Controllable + Unobservable:   dim ≈ {ctrl_rank - min(ctrl_rank, obs_rank)}")
    print(f"  Uncontrollable + Observable:   dim ≈ {obs_rank - min(ctrl_rank, obs_rank)}")
    print(f"  Uncontrollable + Unobservable: dim ≈ {n - ctrl_rank - obs_rank + min(ctrl_rank, obs_rank)}")
    print(f"\n  Each component is an INVARIANT subspace of the dynamics!")
    print(f"  This decomposition is the foundation of modern control theory.")


# =============================================================================
# Application 4: Principal Component Analysis (Kernel PCA)
# =============================================================================

def kernel_pca_demonstration():
    """
    In kernel methods, the covariance operator is a compact self-adjoint
    operator on the RKHS. Its eigenspaces (principal components) are
    the invariant subspaces that capture data variance.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Kernel PCA via Compact Operator Eigenspaces")
    print("=" * 70)
    
    np.random.seed(42)
    
    # Generate data with structure
    n_samples = 200
    t = np.linspace(0, 2*np.pi, n_samples)
    
    # 3 principal modes + noise
    X = np.column_stack([
        3.0 * np.cos(t),           # Mode 1 (strongest)
        2.0 * np.sin(t),           # Mode 2
        1.0 * np.cos(2*t),         # Mode 3 (weakest)
        0.5 * np.sin(3*t),         # Mode 4
        0.1 * np.random.randn(n_samples)  # Noise
    ])
    
    print(f"\nData matrix: {n_samples} samples × {X.shape[1]} features")
    
    # Covariance operator (compact self-adjoint)
    X_centered = X - X.mean(axis=0)
    C = X_centered.T @ X_centered / n_samples
    
    print(f"Covariance matrix C: {C.shape[0]}×{C.shape[1]} (self-adjoint)")
    print(f"‖C - C^T‖ = {norm(C - C.T):.2e} (symmetry check)")
    
    # Eigendecomposition (spectral theorem for self-adjoint operators)
    eigenvalues, eigenvectors = eigh(C)
    eigenvalues = eigenvalues[::-1]  # Descending order
    eigenvectors = eigenvectors[:, ::-1]
    
    print(f"\nEigenvalues (variance captured by each mode):")
    total_var = sum(eigenvalues)
    cumulative = 0
    for i, ev in enumerate(eigenvalues):
        cumulative += ev
        pct = 100 * ev / total_var
        cum_pct = 100 * cumulative / total_var
        print(f"  PC{i+1}: λ = {ev:.4f} ({pct:.1f}% variance, cumulative: {cum_pct:.1f}%)")
    
    print(f"\nEach principal component spans a 1-dimensional REDUCING subspace")
    print(f"of the covariance operator C.")
    print(f"These subspaces are mutually orthogonal (spectral theorem).")
    print(f"The projection onto the first k PCs gives the best rank-k approximation")
    print(f"(Eckart-Young theorem — directly from invariant subspace theory).")
    
    # Verify reducing subspace property
    for i in range(min(3, len(eigenvalues))):
        v = eigenvectors[:, i:i+1]
        Cv = C @ v
        expected = eigenvalues[i] * v
        print(f"\n  PC{i+1}: ‖Cv - λv‖ = {norm(Cv - expected):.2e}")
        # Orthogonal complement is also invariant
        complement = eigenvectors[:, np.arange(len(eigenvalues)) != i]
        C_comp = C @ complement
        proj_onto_v = v @ (v.T @ C_comp)
        print(f"  PC{i+1}: ‖P_v · C · P_⊥‖ = {norm(proj_onto_v):.2e} (reducing check)")


# =============================================================================
# Application 5: PDE Spectral Methods
# =============================================================================

def heat_equation_spectral():
    """
    The Laplacian is a self-adjoint operator whose eigenspaces are
    invariant under the heat semigroup. This gives the eigenfunction
    expansion solution to the heat equation.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Heat Equation — Spectral Decomposition")
    print("=" * 70)
    
    # Discretize -d²/dx² on [0, π] with Dirichlet BCs
    n = 50
    h = np.pi / (n + 1)
    x = np.linspace(h, np.pi - h, n)
    
    # Laplacian matrix (self-adjoint!)
    L = np.zeros((n, n))
    for i in range(n):
        L[i, i] = 2.0 / h**2
        if i > 0:
            L[i, i-1] = -1.0 / h**2
        if i < n-1:
            L[i, i+1] = -1.0 / h**2
    
    print(f"\nDiscretized Laplacian on [0, π] with {n} points")
    print(f"Grid spacing h = {h:.4f}")
    print(f"‖L - L^T‖ = {norm(L - L.T):.2e} (self-adjoint ✓)")
    
    # Eigenvalues should be k² for k = 1, 2, ...
    eigenvalues, eigenvectors = eigh(L)
    
    print(f"\nFirst 10 eigenvalues vs theoretical k²:")
    for k in range(1, 11):
        numerical = eigenvalues[k-1]
        theoretical = k**2
        error = abs(numerical - theoretical) / theoretical
        print(f"  k={k:2d}: numerical = {numerical:.4f}, "
              f"theoretical = {theoretical:.1f}, "
              f"relative error = {error:.2e}")
    
    # Solve heat equation: u_t = -Lu, u(0,x) = f(x)
    # Solution: u(t,x) = Σ_k c_k exp(-λ_k t) φ_k(x)
    
    # Initial condition: a bump
    f = np.sin(x) + 0.5 * np.sin(3*x)
    
    # Project onto eigenbasis (Fourier-like coefficients)
    coeffs = eigenvectors.T @ f
    
    print(f"\nHeat equation solution u(t,x) = Σ cₖ exp(-λₖt) φₖ(x)")
    print(f"Initial condition: f(x) = sin(x) + 0.5·sin(3x)")
    print(f"\nDominant coefficients:")
    for k in range(5):
        print(f"  c_{k+1} = {coeffs[k]:.4f}, λ_{k+1} = {eigenvalues[k]:.2f}")
    
    # Evolution at different times
    times = [0.0, 0.01, 0.05, 0.1, 0.5]
    print(f"\n{'Time':>8s} {'‖u(t)‖':>10s} {'Energy ratio':>14s}")
    print(f"{'-'*8:>8s} {'-'*10:>10s} {'-'*14:>14s}")
    
    energy_0 = norm(f)
    for t in times:
        # Each eigenspace evolves independently (INVARIANT under heat semigroup)
        u_t = sum(
            coeffs[k] * np.exp(-eigenvalues[k] * t) * eigenvectors[:, k]
            for k in range(n)
        )
        energy = norm(u_t)
        print(f"{t:8.3f} {energy:10.4f} {energy/energy_0:14.4f}")
    
    print(f"\nKey insight: Each eigenspace of the Laplacian is INVARIANT")
    print(f"under the heat semigroup exp(-Lt). The k-th mode decays")
    print(f"independently at rate exp(-k²t). This is the spectral theorem")
    print(f"applied to PDE solving — invariant subspaces enable mode-by-mode analysis.")


if __name__ == "__main__":
    quantum_measurement_subspaces()
    koopman_mode_decomposition()
    controllability_decomposition()
    kernel_pca_demonstration()
    heat_equation_spectral()
    
    print("\n" + "=" * 70)
    print("SUMMARY OF APPLICATIONS")
    print("=" * 70)
    print("""
Invariant subspace theory provides the mathematical foundation for:

1. QUANTUM MECHANICS: Measurement outcomes correspond to eigenspaces
   of observables. Superselection sectors are reducing subspaces.

2. DYNAMICAL SYSTEMS: Koopman eigenspaces decompose dynamics into
   independent coherent modes (DMD, spectral analysis).

3. CONTROL THEORY: Controllable/observable subspaces are invariant
   under system dynamics, enabling decomposition into accessible
   and inaccessible state components.

4. MACHINE LEARNING: Principal components are eigenspaces of the
   covariance operator — reducing subspaces that capture variance.

5. PDE METHODS: Eigenfunction expansions decompose solutions into
   independently evolving modes, each living in an invariant subspace.

In every case, the mathematical structure is the same:
an operator acting on a Hilbert space, and the identification of
subspaces that the operator preserves. This is the invariant
subspace theorem at work across science and engineering.
""")


#!/usr/bin/env python3
"""
Invariant Subspace Theorem — Demonstrations

Concrete numerical examples illustrating invariant subspaces for:
1. Finite-dimensional operators over ℂ
2. Compact (finite-rank) operators
3. Self-adjoint operators and their spectral decomposition
4. The unilateral shift (an operator with no eigenvalues of modulus > 1)
"""

import numpy as np
from numpy.linalg import eig, norm, svd

np.set_printoptions(precision=6, suppress=True)


def demo_finite_dimensional_invariant_subspace():
    """
    Demo 1: Finite-dimensional invariant subspace theorem.
    
    Every linear operator on a complex vector space of dimension ≥ 2
    has a nontrivial invariant subspace (namely, the span of any eigenvector).
    """
    print("=" * 70)
    print("DEMO 1: Finite-Dimensional Invariant Subspace Theorem")
    print("=" * 70)
    
    # A random 4x4 complex matrix
    np.random.seed(42)
    A = np.random.randn(4, 4) + 1j * np.random.randn(4, 4)
    
    print(f"\nOperator A (4×4 complex matrix):")
    print(A)
    
    # Compute eigenvalues and eigenvectors
    eigenvalues, eigenvectors = eig(A)
    
    print(f"\nEigenvalues: {eigenvalues}")
    
    # The span of each eigenvector is a 1-dimensional invariant subspace
    for i in range(len(eigenvalues)):
        v = eigenvectors[:, i]
        Av = A @ v
        lambda_v = eigenvalues[i] * v
        
        # Check: A*v = λ*v (up to numerical precision)
        residual = norm(Av - lambda_v)
        print(f"\nEigenvector {i+1}: v = {v}")
        print(f"  λ = {eigenvalues[i]:.6f}")
        print(f"  ‖Av - λv‖ = {residual:.2e}")
        print(f"  span{{v}} is a 1-dimensional invariant subspace ✓")
    
    # Verify: span(v) ≠ {0} and span(v) ≠ ℂ⁴ (since dim = 1 < 4)
    print(f"\nEach eigenspace is nontrivial: dim = 1, which is neither 0 nor 4.")
    print("This confirms the finite-dimensional invariant subspace theorem.")


def demo_compact_operator():
    """
    Demo 2: Compact operator invariant subspace theorem.
    
    Simulates a compact (finite-rank) operator on a large-dimensional space
    and finds its nontrivial eigenspace.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Compact Operator — Eigenvalue and Invariant Subspace")
    print("=" * 70)
    
    n = 100  # Simulate "large" dimensional space
    
    # Create a rank-3 operator (finite rank ⇒ compact)
    # T = sum of rank-1 operators: σ_i * u_i ⊗ v_i
    np.random.seed(123)
    singular_values = [5.0, 2.0, 0.5]
    U = np.linalg.qr(np.random.randn(n, 3) + 1j * np.random.randn(n, 3))[0]
    V = np.linalg.qr(np.random.randn(n, 3) + 1j * np.random.randn(n, 3))[0]
    
    T = sum(s * np.outer(U[:, i], V[:, i].conj()) for i, s in enumerate(singular_values))
    
    print(f"\nCompact operator T: rank-3 operator on ℂ^{n}")
    print(f"Singular values: {singular_values}")
    print(f"‖T‖ (operator norm) = {norm(T, ord=2):.6f}")
    
    # Eigenvalues of T (most will be 0)
    evals, evecs = eig(T)
    nonzero_evals = evals[np.abs(evals) > 1e-10]
    
    print(f"\nNonzero eigenvalues: {nonzero_evals}")
    print(f"Number of nonzero eigenvalues: {len(nonzero_evals)}")
    print(f"Number of zero eigenvalues: {len(evals) - len(nonzero_evals)}")
    
    # Each nonzero eigenvalue gives a nontrivial closed invariant subspace
    for i, ev in enumerate(nonzero_evals):
        idx = np.argmin(np.abs(evals - ev))
        v = evecs[:, idx]
        residual = norm(T @ v - ev * v)
        print(f"\nEigenvalue μ_{i+1} = {ev:.6f}")
        print(f"  ‖Tv - μv‖ = {residual:.2e}")
        print(f"  eigenspace(μ_{i+1}) is a nontrivial closed invariant subspace ✓")
    
    # The kernel is also an invariant subspace
    kernel_dim = n - len(nonzero_evals)
    print(f"\nker(T) has dimension ≈ {kernel_dim} (also an invariant subspace)")
    print(f"Since rank(T) = 3 < {n} = dim(H), ker(T) is nontrivial.")


def demo_self_adjoint_spectral():
    """
    Demo 3: Self-adjoint operator — spectral decomposition gives
    a complete family of reducing (invariant) subspaces.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Self-Adjoint Operator — Spectral Decomposition")
    print("=" * 70)
    
    n = 6
    np.random.seed(456)
    
    # Create a self-adjoint (Hermitian) matrix
    M = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    A = (M + M.conj().T) / 2  # Hermitian
    
    print(f"\nSelf-adjoint operator A ({n}×{n} Hermitian matrix):")
    print(A)
    
    # Verify self-adjointness
    print(f"\n‖A - A*‖ = {norm(A - A.conj().T):.2e} (should be ≈ 0)")
    
    # Eigenvalues are all real for self-adjoint operators
    evals, evecs = eig(A)
    evals_real = np.real(evals)
    
    print(f"\nEigenvalues (all real): {np.sort(evals_real)}")
    
    # Each eigenspace is a REDUCING subspace (invariant under both A and A*)
    print("\nEach eigenspace is a reducing subspace:")
    for i in range(n):
        v = evecs[:, i]
        Av = A @ v
        Astar_v = A.conj().T @ v
        
        # Both A and A* map v to a scalar multiple of v
        res_A = norm(Av - evals[i] * v)
        res_Astar = norm(Astar_v - np.conj(evals[i]) * v)
        print(f"  λ_{i+1} = {evals_real[i]:+.4f}: "
              f"‖Av - λv‖ = {res_A:.2e}, "
              f"‖A*v - λ̄v‖ = {res_Astar:.2e} ✓")
    
    # Orthogonality of eigenspaces
    gram = evecs.conj().T @ evecs
    off_diag = gram - np.diag(np.diag(gram))
    print(f"\nOrthogonality check: max off-diagonal |⟨vᵢ, vⱼ⟩| = {np.max(np.abs(off_diag)):.2e}")
    print("Eigenspaces are mutually orthogonal ✓")
    print("Each eigenspace is both invariant AND reducing (its ⊥ is also invariant).")


def demo_unilateral_shift():
    """
    Demo 4: The unilateral shift — an operator with invariant subspaces
    but NO eigenvalues (for |λ| ≥ 1).
    
    This illustrates that eigenvalue-based proofs do not capture all
    invariant subspaces, motivating the study of the general problem.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Unilateral Shift — Invariant Subspaces Without Eigenvalues")
    print("=" * 70)
    
    n = 20  # Truncated ℓ²(ℕ) approximation
    
    # Shift operator: S(e_0, e_1, ...) = (0, e_0, e_1, ...)
    S = np.zeros((n, n), dtype=complex)
    for i in range(1, n):
        S[i, i-1] = 1.0
    
    print(f"\nUnilateral shift S on ℓ²(ℕ) (truncated to {n} dimensions)")
    print(f"S maps eₖ → eₖ₊₁ (shifts basis vectors up by one index)")
    
    # Compute eigenvalues of truncated shift
    evals = np.linalg.eigvals(S)
    print(f"\nEigenvalues of truncated S: all ≈ 0")
    print(f"  max |λ| = {np.max(np.abs(evals)):.2e}")
    print(f"  (In infinite dimensions, S has NO eigenvalues at all)")
    
    # Show why: if S*v = λ*v, then v must satisfy v_{k+1} = λ*v_k
    # So v = (v_0, λ*v_0, λ²*v_0, ...) which is in ℓ² only if |λ| < 1
    print(f"\n  Proof sketch: If Sv = λv with v ≠ 0, then v = (c, λc, λ²c, ...)")
    print(f"  This is in ℓ² only if |λ| < 1. For |λ| ≥ 1, no eigenvectors exist.")
    print(f"  So the shift has no eigenvalues with |λ| ≥ 1.")
    
    # But it DOES have invariant subspaces
    # For example, span{e_k, e_{k+1}, ...} is invariant for each k
    print(f"\n  Yet S has many invariant subspaces:")
    for k in [0, 1, 3, 5]:
        # M_k = span{e_k, e_{k+1}, ...}
        # Check: S maps e_j (j ≥ k) to e_{j+1} (j+1 ≥ k+1 > k), so S(M_k) ⊂ M_k
        print(f"    M_{k} = span{{e_{k}, e_{k+1}, ...}} is invariant (S maps eⱼ → eⱼ₊₁ stays in M_{k})")
    
    print(f"\n  These invariant subspaces are NOT eigenspaces!")
    print(f"  This shows the invariant subspace problem goes beyond eigenvalue theory.")
    
    # The adjoint S* (backward shift) DOES have eigenvalues
    S_adj = S.conj().T
    print(f"\n  The adjoint S* (backward shift) has eigenvalues:")
    print(f"  S* maps e_0 → 0, e_k → e_{{k-1}} for k ≥ 1")
    print(f"  Every λ with |λ| < 1 is an eigenvalue of S* with eigenvector")
    print(f"  v = (1, λ, λ², ...) ∈ ℓ²")
    
    # Verify for a specific λ
    lam = 0.5 + 0.3j
    v = np.array([lam**k for k in range(n)])
    v = v / norm(v)
    Sadj_v = S_adj @ v
    res = norm(Sadj_v - lam * v)
    print(f"\n  Check: λ = {lam}, ‖S*v - λv‖ = {res:.2e} ✓")


def demo_spectral_projection():
    """
    Demo 5: Spectral projections for a self-adjoint operator.
    
    Shows how the spectral theorem decomposes the space into
    mutually orthogonal reducing subspaces.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Spectral Projections — Invariant Subspace Decomposition")
    print("=" * 70)
    
    n = 8
    np.random.seed(789)
    
    # Create a self-adjoint operator with known spectrum
    eigenvalues = np.array([-3.0, -1.5, -1.5, 0.5, 0.5, 0.5, 2.0, 4.0])
    Q = np.linalg.qr(np.random.randn(n, n))[0]  # Random orthogonal matrix
    A = Q @ np.diag(eigenvalues) @ Q.T
    
    print(f"\nSelf-adjoint operator A with prescribed spectrum:")
    print(f"  Eigenvalues: {eigenvalues}")
    
    # Spectral projections: P_S = projection onto eigenspaces for eigenvalues in S
    distinct_evals = sorted(set(eigenvalues))
    print(f"\nDistinct eigenvalues: {distinct_evals}")
    
    projections = {}
    for ev in distinct_evals:
        indices = [i for i, e in enumerate(eigenvalues) if np.abs(e - ev) < 1e-10]
        P = sum(np.outer(Q[:, i], Q[:, i]) for i in indices)
        projections[ev] = P
        mult = len(indices)
        print(f"\n  E({{λ={ev:+.1f}}}) = projection onto {mult}-dim eigenspace")
        
        # Verify: P² = P (idempotent)
        print(f"    ‖P² - P‖ = {norm(P @ P - P):.2e}")
        # Verify: P = P* (self-adjoint)
        print(f"    ‖P - P*‖ = {norm(P - P.conj().T):.2e}")
        # Verify: AP = PA = λP
        print(f"    ‖AP - λP‖ = {norm(A @ P - ev * P):.2e}")
    
    # Verify: projections sum to identity
    P_sum = sum(projections.values())
    print(f"\n  Σ P_λ = I check: ‖Σ P_λ - I‖ = {norm(P_sum - np.eye(n)):.2e}")
    
    # Verify: orthogonality of spectral projections
    print(f"\n  Orthogonality of projections:")
    for i, ev1 in enumerate(distinct_evals):
        for ev2 in distinct_evals[i+1:]:
            prod = norm(projections[ev1] @ projections[ev2])
            print(f"    P_{{{ev1:+.1f}}} · P_{{{ev2:+.1f}}} = 0 check: ‖product‖ = {prod:.2e}")
    
    # Each spectral subspace is a nontrivial reducing subspace
    print(f"\n  Summary: The spectral theorem decomposes ℂ^{n} into")
    print(f"  {len(distinct_evals)} mutually orthogonal reducing subspaces.")
    print(f"  Each is invariant under A AND under any operator commuting with A.")


if __name__ == "__main__":
    demo_finite_dimensional_invariant_subspace()
    demo_compact_operator()
    demo_self_adjoint_spectral()
    demo_unilateral_shift()
    demo_spectral_projection()
    
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
These demonstrations illustrate the key theorems:

1. FINITE-DIMENSIONAL: Every operator on ℂ^n (n ≥ 2) has a nontrivial
   invariant subspace — the span of any eigenvector.

2. COMPACT: Nonzero compact operators have nonzero eigenvalues,
   whose eigenspaces are nontrivial closed invariant subspaces.

3. SELF-ADJOINT: Self-adjoint operators decompose the space into
   mutually orthogonal reducing subspaces via the spectral theorem.

4. UNILATERAL SHIFT: Demonstrates that invariant subspaces exist
   even when eigenvalues don't — the general problem is deeper.

5. SPECTRAL PROJECTIONS: Shows the full spectral decomposition
   machinery that makes invariant subspaces computationally useful.

The general invariant subspace problem (for arbitrary bounded operators
on infinite-dimensional Hilbert spaces) remains one of the great open
questions in functional analysis.
""")
