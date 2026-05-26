"""
Certificate-Based Quantum Expanders — Applications

Demonstrates real-world applications of quantum expander theory:
1. Quantum state mixing / thermalization simulation
2. Quantum randomness extraction
3. Quantum error channel analysis
"""

import numpy as np


def quantum_channel(U, V, rho):
    """Quantum averaging channel."""
    Ud, Vd = U.conj().T, V.conj().T
    return 0.25 * (U @ rho @ Ud + Ud @ rho @ U + V @ rho @ Vd + Vd @ rho @ V)


def construct_clock_shift(n):
    """Clock-shift pair."""
    omega = np.exp(2j * np.pi / n)
    U = np.diag([omega**k for k in range(n)])
    V = np.zeros((n, n), dtype=complex)
    for i in range(n):
        V[i, (i + 1) % n] = 1.0
    return U, V


# =============================================================================
# Application 1: Quantum State Thermalization
# =============================================================================
def demonstrate_thermalization():
    """Show how quantum expanders drive arbitrary states to the maximally mixed state."""
    print("Application 1: Quantum State Thermalization")
    print("-" * 50)
    
    n = 4
    U, V = construct_clock_shift(n)
    target = np.eye(n, dtype=complex) / n
    
    # Start from a pure state |0⟩⟨0|
    rho_pure = np.zeros((n, n), dtype=complex)
    rho_pure[0, 0] = 1.0
    
    # Start from a random state
    np.random.seed(123)
    A = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    rho_random = A @ A.conj().T
    rho_random /= np.trace(rho_random)
    
    print(f"n = {n}, Clock-Shift expander")
    print(f"\nPure state |0⟩⟨0| convergence:")
    rho = rho_pure.copy()
    for k in range(12):
        dist = np.real(np.trace((rho - target).conj().T @ (rho - target)))
        print(f"  k={k:2d}: distance = {dist:.8f}")
        rho = quantum_channel(U, V, rho)
    
    print(f"\nRandom state convergence:")
    rho = rho_random.copy()
    for k in range(12):
        dist = np.real(np.trace((rho - target).conj().T @ (rho - target)))
        print(f"  k={k:2d}: distance = {dist:.8f}")
        rho = quantum_channel(U, V, rho)
    print()


# =============================================================================
# Application 2: Quantum Randomness Extraction
# =============================================================================
def demonstrate_randomness_extraction():
    """Quantum expanders as randomness extractors: extract uniform randomness from weak sources."""
    print("Application 2: Quantum Randomness Extraction")
    print("-" * 50)
    
    n = 3
    U, V = construct_clock_shift(n)
    
    # A "weak" quantum source: biased density matrix
    rho_biased = np.diag([0.7, 0.2, 0.1]).astype(complex)
    target = np.eye(n, dtype=complex) / n
    
    print(f"Input state (biased): diag({np.diag(rho_biased).real})")
    print(f"Target (uniform): I/{n}")
    print(f"\nExtraction via iterated channel application:")
    
    rho = rho_biased.copy()
    for k in range(15):
        eigenvalues = np.sort(np.real(np.linalg.eigvals(rho)))[::-1]
        max_dev = max(abs(eigenvalues - 1/n))
        print(f"  k={k:2d}: eigenvalues = {np.round(eigenvalues, 6)}, max deviation = {max_dev:.6f}")
        rho = quantum_channel(U, V, rho)
    print()


# =============================================================================
# Application 3: Quantum Error Analysis
# =============================================================================
def demonstrate_error_analysis():
    """Analyze how quantum expander channels interact with error channels."""
    print("Application 3: Quantum Error Channel Analysis")
    print("-" * 50)
    
    n = 2
    omega = np.exp(2j * np.pi / 3)
    U = (1/np.sqrt(2)) * np.array([[1, 1], [1, -1]], dtype=complex)
    V = np.array([[1, 0], [0, 1j]], dtype=complex)
    
    # Depolarizing channel: Δ_p(ρ) = (1-p)ρ + p·I/n
    def depolarizing(rho, p):
        n = rho.shape[0]
        return (1 - p) * rho + p * np.eye(n, dtype=complex) / n
    
    # Composition: Φ ∘ Δ_p
    # If Φ has gap γ, then Φ ∘ Δ_p has gap γ + p(1-γ)
    print(f"Expander gap γ for (Hadamard, Phase): ", end="")
    
    # Compute gap
    dim = n * n
    S = np.zeros((dim, dim), dtype=complex)
    basis = [np.zeros((n, n), dtype=complex) for _ in range(dim)]
    for i in range(n):
        for j in range(n):
            basis[i*n+j][i, j] = 1.0
    
    for idx, E in enumerate(basis):
        PhiE = quantum_channel(U, V, E)
        for jdx, F in enumerate(basis):
            S[jdx, idx] = np.trace(F.conj().T @ PhiE)
    
    evals = np.sort(np.real(np.linalg.eigvals(S)))[::-1]
    gap = 1 - evals[1]
    print(f"{gap:.4f}")
    
    for p in [0.0, 0.1, 0.2, 0.5]:
        # Effective gap of composition
        effective_gap = 1 - (1 - p) * (1 - gap)
        print(f"  Depolarizing p={p:.1f}: effective gap = {effective_gap:.4f}")
    print()


if __name__ == "__main__":
    print("=" * 60)
    print("Certificate-Based Quantum Expanders — Applications")
    print("=" * 60)
    print()
    demonstrate_thermalization()
    demonstrate_randomness_extraction()
    demonstrate_error_analysis()


"""
Certificate-Based Quantum Expanders — Numerical Demonstrations

Constructs certified quantum expanders for n = 2, 3, computes spectral gaps
numerically, and visualizes convergence Φ^k(ρ) → I/n for random initial ρ.

Usage:
    python demo.py
"""

import numpy as np
from numpy.linalg import eigh, norm

# =============================================================================
# Core definitions
# =============================================================================

def quantum_channel(U, V, rho):
    """Compute Φ_{U,V}(ρ) = ¼(UρU† + U†ρU + VρV† + V†ρV)."""
    Ud = U.conj().T
    Vd = V.conj().T
    return 0.25 * (U @ rho @ Ud + Ud @ rho @ U + V @ rho @ Vd + Vd @ rho @ V)

def frobenius_norm_sq(M):
    """Frobenius norm squared: Tr(M†M)."""
    return np.real(np.trace(M.conj().T @ M))

def hs_inner(A, B):
    """Hilbert-Schmidt inner product: Tr(A†B)."""
    return np.trace(A.conj().T @ B)

def is_irreducible(U, V, n, tol=1e-10):
    """Check if (U, V) is an irreducible pair by checking dim(commutant) = 1."""
    # Build the commutant equations: [M, U] = 0 and [M, V] = 0
    # M is n×n complex, so 2n² real parameters
    # MU - UM = 0 gives n² complex equations = 2n² real equations
    # MV - VM = 0 gives another 2n² real equations
    dim = n * n
    # Real representation: M = X + iY, equations become real linear system
    A_real = []
    for gen in [U, V]:
        for i in range(n):
            for j in range(n):
                # (MG - GM)_{ij} = 0
                # real part and imaginary part
                row_re = np.zeros(2 * dim)
                row_im = np.zeros(2 * dim)
                for k in range(n):
                    # M_{ik} G_{kj} contribution
                    idx_re = i * n + k          # real part of M_{ik}
                    idx_im = dim + i * n + k    # imag part of M_{ik}
                    g_re = gen[k, j].real
                    g_im = gen[k, j].imag
                    row_re[idx_re] += g_re
                    row_re[idx_im] -= g_im
                    row_im[idx_re] += g_im
                    row_im[idx_im] += g_re
                    # -G_{ik} M_{kj} contribution
                    idx_re2 = k * n + j
                    idx_im2 = dim + k * n + j
                    g_re2 = gen[i, k].real
                    g_im2 = gen[i, k].imag
                    row_re[idx_re2] -= g_re2
                    row_re[idx_im2] += g_im2
                    row_im[idx_re2] -= g_im2
                    row_im[idx_im2] -= g_re2
                A_real.append(row_re)
                A_real.append(row_im)
    A_mat = np.array(A_real)
    _, s, _ = np.linalg.svd(A_mat)
    # Dimension of kernel = number of singular values < tol
    kernel_dim = np.sum(s < tol)
    # Irreducible iff commutant is 1-dimensional (scalar matrices)
    # Scalar matrices have 2 real dimensions (c = a + bi)
    return kernel_dim == 2

def spectral_gap(U, V, n):
    """Compute the spectral gap of the quantum channel on the traceless subspace."""
    # Build Φ as a superoperator matrix on n² dimensional space
    dim = n * n
    Phi = np.zeros((dim, dim), dtype=complex)
    basis = []
    for i in range(n):
        for j in range(n):
            E = np.zeros((n, n), dtype=complex)
            E[i, j] = 1.0
            basis.append(E)
    
    for idx, E in enumerate(basis):
        PhiE = quantum_channel(U, V, E)
        for jdx, F in enumerate(basis):
            Phi[jdx, idx] = hs_inner(F, PhiE)
    
    # Find eigenvalues of Phi
    eigenvalues = np.linalg.eigvals(Phi)
    eigenvalues = np.sort(np.real(eigenvalues))[::-1]
    
    # The largest eigenvalue should be 1 (corresponding to the identity)
    # The spectral gap is 1 - second_largest_eigenvalue
    lambda_2 = eigenvalues[1] if len(eigenvalues) > 1 else 0
    gap = 1 - lambda_2
    
    return gap, eigenvalues

# =============================================================================
# Example 1: n = 2 — Pauli matrices
# =============================================================================
print("=" * 60)
print("Example 1: n = 2 — Pauli-based quantum expander")
print("=" * 60)

# Hadamard-like unitary
U2 = (1 / np.sqrt(2)) * np.array([[1, 1], [1, -1]], dtype=complex)
# Phase gate
V2 = np.array([[1, 0], [0, 1j]], dtype=complex)

print(f"U = (1/√2) [[1,1],[1,-1]]  (Hadamard)")
print(f"V = [[1,0],[0,i]]  (Phase gate)")
print(f"Irreducible: {is_irreducible(U2, V2, 2)}")

gap2, evals2 = spectral_gap(U2, V2, 2)
print(f"Eigenvalues of Φ: {np.round(evals2, 6)}")
print(f"Spectral gap γ = {gap2:.6f}")
print()

# Convergence demo
print("Convergence of Φ^k(ρ) → I/2:")
rho = np.array([[0.8, 0.3 + 0.1j], [0.3 - 0.1j, 0.2]], dtype=complex)
target = np.eye(2) / 2
for k in range(15):
    dist = frobenius_norm_sq(rho - target)
    print(f"  k={k:2d}: ‖ρ - I/2‖²_F = {dist:.8f}")
    rho = quantum_channel(U2, V2, rho)
print()

# =============================================================================
# Example 2: n = 3 — DFT-based quantum expander
# =============================================================================
print("=" * 60)
print("Example 2: n = 3 — DFT-based quantum expander")
print("=" * 60)

omega = np.exp(2j * np.pi / 3)
U3 = np.diag([1, omega, omega**2])  # Clock matrix
F3 = (1 / np.sqrt(3)) * np.array([[1, 1, 1],
                                     [1, omega, omega**2],
                                     [1, omega**2, omega**4]], dtype=complex)
V3 = F3  # Fourier transform (shift matrix in Fourier basis)

print("U = diag(1, ω, ω²)  (Clock matrix, ω = e^(2πi/3))")
print(f"V = F₃  (3×3 DFT matrix)")
print(f"Irreducible: {is_irreducible(U3, V3, 3)}")

gap3, evals3 = spectral_gap(U3, V3, 3)
print(f"Eigenvalues of Φ: {np.round(evals3, 6)}")
print(f"Spectral gap γ = {gap3:.6f}")
print()

# Convergence demo
print("Convergence of Φ^k(ρ) → I/3:")
np.random.seed(42)
A = np.random.randn(3, 3) + 1j * np.random.randn(3, 3)
rho3 = A @ A.conj().T
rho3 = rho3 / np.trace(rho3)  # Normalize to trace 1
target3 = np.eye(3) / 3
for k in range(20):
    dist = frobenius_norm_sq(rho3 - target3)
    print(f"  k={k:2d}: ‖ρ - I/3‖²_F = {dist:.8f}")
    rho3 = quantum_channel(U3, V3, rho3)
print()

# =============================================================================
# Example 3: Quantum Singer condition check
# =============================================================================
print("=" * 60)
print("Example 3: Quantum Singer Condition Analysis")
print("=" * 60)

def check_singer_condition(U, V, n):
    """Check the quantum Singer condition and compute δ."""
    # Get eigenspaces of U
    evals_U, evecs_U = eigh(U @ U.conj().T)  # For general unitary, use Schur
    evals_U_actual, evecs_U_actual = np.linalg.eig(U)
    evals_V_actual, evecs_V_actual = np.linalg.eig(V)
    
    min_ratio = 1.0
    
    # For each pair of eigenvalues of U and V
    unique_evals_U = np.unique(np.round(evals_U_actual, 10))
    unique_evals_V = np.unique(np.round(evals_V_actual, 10))
    
    for eu in unique_evals_U:
        # Projection onto eigenspace of U for eigenvalue eu
        mask_U = np.abs(evals_U_actual - eu) < 1e-8
        eigvecs_U = evecs_U_actual[:, mask_U]
        P = eigvecs_U @ eigvecs_U.conj().T
        
        for ev in unique_evals_V:
            mask_V = np.abs(evals_V_actual - ev) < 1e-8
            eigvecs_V = evecs_V_actual[:, mask_V]
            Q = eigvecs_V @ eigvecs_V.conj().T
            
            tr_P = np.real(np.trace(P))
            tr_Q = np.real(np.trace(Q))
            tr_PQ = np.trace(P @ Q)
            
            if tr_P > 0.5 and tr_Q > 0.5:  # Both non-trivial
                ratio = np.abs(tr_PQ)**2 / (tr_P * tr_Q)
                min_ratio = min(min_ratio, 1 - ratio)
    
    return min_ratio

delta2 = check_singer_condition(U2, V2, 2)
print(f"n=2: Quantum Singer parameter δ ≈ {delta2:.6f}")
print(f"     Predicted gap bound δ/4 ≈ {delta2/4:.6f}")
print(f"     Actual spectral gap      = {gap2:.6f}")
print()

delta3 = check_singer_condition(U3, V3, 3)
print(f"n=3: Quantum Singer parameter δ ≈ {delta3:.6f}")
print(f"     Predicted gap bound δ/4 ≈ {delta3/4:.6f}")
print(f"     Actual spectral gap      = {gap3:.6f}")
print()

# =============================================================================
# Summary
# =============================================================================
print("=" * 60)
print("Summary of Certified Quantum Expanders")
print("=" * 60)
print(f"  n=2: γ = {gap2:.4f} (Hadamard + Phase gate)")
print(f"  n=3: γ = {gap3:.4f} (Clock + DFT)")
print()
print("Key insight: Algebraic irreducibility of the pair (U, V)")
print("guarantees a positive spectral gap, providing deterministic")
print("certification of quantum expansion without probabilistic methods.")


"""
Visualization: Quantum Expander Convergence

Shows how the quantum averaging channel drives arbitrary quantum states
toward the maximally mixed state. Plots the Frobenius distance ‖ρ_k - I/n‖²
as a function of iteration k for multiple dimensions and initial states.

CRITICAL: This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


def quantum_channel(U, V, rho):
    Ud, Vd = U.conj().T, V.conj().T
    return 0.25 * (U @ rho @ Ud + Ud @ rho @ U + V @ rho @ Vd + Vd @ rho @ V)


def construct_clock_shift(n):
    omega = np.exp(2j * np.pi / n)
    U = np.diag([omega**k for k in range(n)])
    V = np.zeros((n, n), dtype=complex)
    for i in range(n):
        V[i, (i + 1) % n] = 1.0
    return U, V


def frobenius_dist_sq(A, B):
    D = A - B
    return np.real(np.trace(D.conj().T @ D))


fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: convergence for different dimensions
ax1 = axes[0]
for n in [2, 3, 4, 5, 8]:
    U, V = construct_clock_shift(n)
    target = np.eye(n, dtype=complex) / n
    
    # Pure state |0⟩⟨0|
    rho = np.zeros((n, n), dtype=complex)
    rho[0, 0] = 1.0
    
    dists = []
    K = 30
    for k in range(K):
        dists.append(frobenius_dist_sq(rho, target))
        rho = quantum_channel(U, V, rho)
    
    ax1.semilogy(range(K), dists, 'o-', markersize=3, label=f'n = {n}')

ax1.set_xlabel('Iteration k', fontsize=12)
ax1.set_ylabel('‖ρ_k - I/n‖²_F', fontsize=12)
ax1.set_title('Convergence to Maximally Mixed State', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right panel: eigenvalue spectrum for n=4
ax2 = axes[1]
n = 4
U, V = construct_clock_shift(n)
dim = n * n
S = np.zeros((dim, dim), dtype=complex)
for i in range(n):
    for j in range(n):
        E = np.zeros((n, n), dtype=complex)
        E[i, j] = 1.0
        PhiE = quantum_channel(U, V, E)
        S[:, i*n+j] = PhiE.flatten()

evals = np.sort(np.real(np.linalg.eigvals(S)))[::-1]
colors = ['#2ecc71' if abs(e - 1.0) < 0.01 else '#3498db' if e > 0 else '#e74c3c' for e in evals]
ax2.bar(range(len(evals)), evals, color=colors, alpha=0.8)
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.axhline(y=1, color='green', linewidth=1, linestyle='--', alpha=0.5, label='Fixed point λ=1')
gap = 1 - evals[1]
ax2.axhline(y=evals[1], color='orange', linewidth=1, linestyle='--', alpha=0.7, 
            label=f'λ₂ = {evals[1]:.3f} (gap γ = {gap:.3f})')
ax2.set_xlabel('Eigenvalue index', fontsize=12)
ax2.set_ylabel('Eigenvalue', fontsize=12)
ax2.set_title(f'Spectrum of Φ (n={n}, Clock-Shift)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('visualization_convergence.png', dpi=150, bbox_inches='tight')
print("Saved visualization_convergence.png")


"""
Visualization: Spectral Gaps Across Dimensions

Computes and plots the spectral gap γ(n) for clock-shift quantum expanders
as a function of dimension n. Shows how the gap varies and compares with
the Singer condition bound δ/4.

CRITICAL: This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


def quantum_channel(U, V, rho):
    Ud, Vd = U.conj().T, V.conj().T
    return 0.25 * (U @ rho @ Ud + Ud @ rho @ U + V @ rho @ Vd + Vd @ rho @ V)


def construct_clock_shift(n):
    omega = np.exp(2j * np.pi / n)
    U = np.diag([omega**k for k in range(n)])
    V = np.zeros((n, n), dtype=complex)
    for i in range(n):
        V[i, (i + 1) % n] = 1.0
    return U, V


def compute_spectral_gap(U, V, n):
    dim = n * n
    S = np.zeros((dim, dim), dtype=complex)
    for i in range(n):
        for j in range(n):
            E = np.zeros((n, n), dtype=complex)
            E[i, j] = 1.0
            PhiE = quantum_channel(U, V, E)
            S[:, i*n+j] = PhiE.flatten()
    evals = np.sort(np.real(np.linalg.eigvals(S)))[::-1]
    return 1 - evals[1], evals


dims = list(range(2, 16))
gaps = []
min_abs_evals = []

for n in dims:
    U, V = construct_clock_shift(n)
    gap, evals = compute_spectral_gap(U, V, n)
    gaps.append(gap)
    # Maximum absolute eigenvalue on traceless subspace
    abs_evals = np.abs(evals[1:])
    min_abs_evals.append(1 - max(abs_evals))

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: spectral gap vs dimension
ax1 = axes[0]
ax1.plot(dims, gaps, 'bo-', markersize=6, linewidth=2, label='Spectral gap γ')
ax1.plot(dims, min_abs_evals, 'rs--', markersize=5, linewidth=1.5, 
         label='1 - max|λ| (norm gap)')
ax1.set_xlabel('Dimension n', fontsize=12)
ax1.set_ylabel('Gap', fontsize=12)
ax1.set_title('Quantum Expander Spectral Gap vs Dimension', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0)

# Right panel: full spectrum for several dimensions
ax2 = axes[1]
for n in [2, 3, 5, 8]:
    U, V = construct_clock_shift(n)
    _, evals = compute_spectral_gap(U, V, n)
    y_pos = [n] * len(evals)
    ax2.scatter(evals, y_pos, s=30, alpha=0.7, label=f'n={n}')

ax2.axvline(x=1, color='green', linewidth=1, linestyle='--', alpha=0.5)
ax2.axvline(x=-1, color='red', linewidth=1, linestyle='--', alpha=0.5)
ax2.axvline(x=0, color='gray', linewidth=0.5, linestyle='-', alpha=0.3)
ax2.set_xlabel('Eigenvalue', fontsize=12)
ax2.set_ylabel('Dimension n', fontsize=12)
ax2.set_title('Eigenvalue Spectra of Φ', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('visualization_spectral_gaps.png', dpi=150, bbox_inches='tight')
print("Saved visualization_spectral_gaps.png")
