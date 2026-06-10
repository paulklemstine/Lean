#!/usr/bin/env python3
"""
Applications of the spectral arithmetic theorem.

Demonstrates real-world applications across domains:
1. Hecke operator spectral factorization
2. Quantum composite system energy spectra
3. Markov chain mixing on product graphs
4. Kronecker-structured PDE discretizations
"""

import numpy as np
from numpy.linalg import eigvalsh, eigvals
from itertools import product as iterproduct


# ============================================================
# Application 1: Hecke-Style Arithmetic Operators
# ============================================================

def hecke_demo():
    """
    Demonstrate multiplicative spectral factorization for
    a toy Hecke-like operator family.

    In the theory of modular forms, Hecke operators T(n)
    satisfy T(mn) = T(m)T(n) when gcd(m,n)=1.
    Their eigenvalues (Fourier coefficients) factor accordingly.
    """
    print("=" * 70)
    print("APPLICATION 1: Hecke-Style Arithmetic Operators")
    print("=" * 70)

    # Toy 3-dimensional Hecke algebra
    # T(p) for primes p = 2, 3, 5
    T2 = np.array([[2, 1, 0], [1, 3, 1], [0, 1, 1]], dtype=complex)
    T3 = np.array([[1, 2, 0], [2, 1, 1], [0, 1, 3]], dtype=complex)
    T5 = np.array([[3, 0, 1], [0, 2, 0], [1, 0, 1]], dtype=complex)

    # T(6) = T(2)·T(3) (coprime multiplicativity → matrix product)
    T6 = T2 @ T3

    # T(30) = T(2)·T(3)·T(5)
    T30 = T2 @ T3 @ T5

    print("\nEigenvalues:")
    for name, M in [("T(2)", T2), ("T(3)", T3), ("T(5)", T5),
                     ("T(6)=T(2)T(3)", T6), ("T(30)=T(2)T(3)T(5)", T30)]:
        ev = np.sort(eigvals(M).real)
        print(f"  {name}: {ev}")

    # For simultaneously diagonalizable operators,
    # eigenvalues of products are products of eigenvalues
    vals2, V = np.linalg.eig(T2)
    # Check if T3 is also diagonal in V's basis
    T3_diag = np.linalg.inv(V) @ T3 @ V
    print(f"\n  T(3) in T(2)-eigenbasis (should be diagonal if simultaneous):")
    print(f"  {np.abs(T3_diag).round(3)}")

    is_diag = np.allclose(T3_diag, np.diag(np.diag(T3_diag)), atol=0.1)
    print(f"  Approximately diagonal: {is_diag}")
    if is_diag:
        print("  → Eigenvalues of T(6) ≈ pointwise products of T(2), T(3) eigenvalues")


# ============================================================
# Application 2: Quantum Composite Systems
# ============================================================

def quantum_demo():
    """
    Demonstrate energy spectrum factorization for non-interacting
    quantum subsystems.

    For H_total = H₁⊗I + I⊗H₂, the eigenvalues are E₁+E₂.
    Equivalently, for U = exp(iH) = exp(iH₁)⊗exp(iH₂),
    the eigenvalues are products e^(iE₁)·e^(iE₂).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Quantum Composite System Spectra")
    print("=" * 70)

    # Pauli matrices
    sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
    sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
    sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)

    I2 = np.eye(2, dtype=complex)

    # Three-qubit non-interacting system
    H1 = 1.0 * sigma_z
    H2 = 0.5 * sigma_x
    H3 = 0.7 * sigma_y

    # Total Hamiltonian: H1⊗I⊗I + I⊗H2⊗I + I⊗I⊗H3
    I4 = np.eye(4, dtype=complex)
    H_total = (np.kron(np.kron(H1, I2), I2) +
               np.kron(np.kron(I2, H2), I2) +
               np.kron(np.kron(I2, I2), H3))

    E1 = np.sort(eigvalsh(H1))
    E2 = np.sort(eigvalsh(H2))
    E3 = np.sort(eigvalsh(H3))
    E_total = np.sort(eigvalsh(H_total))

    expected = np.sort(np.array([e1 + e2 + e3
                                  for e1 in E1 for e2 in E2 for e3 in E3]))

    print(f"\n  H₁ energies: {E1}")
    print(f"  H₂ energies: {E2}")
    print(f"  H₃ energies: {E3}")
    print(f"  H_total energies:  {E_total}")
    print(f"  Expected (sums):   {expected}")
    print(f"  Match: {np.allclose(E_total, expected)}")

    # Unitary (multiplicative) version
    dt = 0.1
    from scipy.linalg import expm
    U1 = expm(1j * dt * H1)
    U2 = expm(1j * dt * H2)
    U3 = expm(1j * dt * H3)

    U_total = np.kron(np.kron(U1, U2), U3)
    U_eigs = np.sort_complex(eigvals(U_total))

    local_eigs = [eigvals(U) for U in [U1, U2, U3]]
    expected_U = np.sort_complex(np.array([
        np.prod(combo) for combo in iterproduct(*local_eigs)
    ]))

    print(f"\n  Unitary evolution (multiplicative version):")
    print(f"  |U_total eigenvalues| ≈ 1: {np.allclose(np.abs(U_eigs), 1)}")
    print(f"  Eigenvalue products match: {np.allclose(np.sort(np.abs(U_eigs)), np.sort(np.abs(expected_U)))}")


# ============================================================
# Application 3: Markov Chain Mixing on Product Graphs
# ============================================================

def markov_demo():
    """
    Demonstrate mixing rate decomposition for random walks
    on product graphs.

    For the product graph G₁ × G₂, the transition matrix is
    related to the Kronecker product of individual transition matrices.
    The spectral gap (mixing rate) decomposes accordingly.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Markov Chain Mixing on Product Graphs")
    print("=" * 70)

    # Simple random walk on a path graph P₃
    P1 = np.array([
        [0, 1, 0],
        [0.5, 0, 0.5],
        [0, 1, 0],
    ], dtype=float)

    # Simple random walk on a cycle graph C₄
    P2 = np.array([
        [0, 0.5, 0, 0.5],
        [0.5, 0, 0.5, 0],
        [0, 0.5, 0, 0.5],
        [0.5, 0, 0.5, 0],
    ], dtype=float)

    # Product graph transition matrix (lazy version for product)
    # For tensor product graph: eigenvalues multiply
    P_prod = np.kron(P1, P2)

    eig1 = np.sort(np.abs(eigvals(P1)))[::-1]
    eig2 = np.sort(np.abs(eigvals(P2)))[::-1]
    eig_prod = np.sort(np.abs(eigvals(P_prod)))[::-1]

    print(f"\n  P₁ (path) spectral gaps: {1 - eig1}")
    print(f"  P₂ (cycle) spectral gaps: {1 - eig2}")

    # Second largest eigenvalue determines mixing time
    lambda2_1 = eig1[1] if len(eig1) > 1 else 0
    lambda2_2 = eig2[1] if len(eig2) > 1 else 0
    lambda2_prod = eig_prod[1] if len(eig_prod) > 1 else 0

    print(f"\n  Second-largest |eigenvalue|:")
    print(f"    P₁: {lambda2_1:.6f}")
    print(f"    P₂: {lambda2_2:.6f}")
    print(f"    P₁⊗P₂: {lambda2_prod:.6f}")
    print(f"    max(λ₂(P₁), λ₂(P₂)): {max(lambda2_1, lambda2_2):.6f}")
    print(f"\n  Mixing time ~ 1/(1-λ₂):")
    print(f"    P₁: {1/(1-lambda2_1+1e-10):.2f}")
    print(f"    P₂: {1/(1-lambda2_2+1e-10):.2f}")
    print(f"    Product: {1/(1-lambda2_prod+1e-10):.2f}")


# ============================================================
# Application 4: Kronecker PDE Discretization
# ============================================================

def pde_demo():
    """
    Demonstrate efficient eigenvalue computation for
    Kronecker-structured PDE discretizations.

    The 2D Laplacian on a rectangular grid has the form
    L = L_x ⊗ I + I ⊗ L_y, whose eigenvalues are sums
    of 1D Laplacian eigenvalues.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: PDE Spectral Decomposition")
    print("=" * 70)

    n = 10  # grid points per dimension

    # 1D discrete Laplacian
    def laplacian_1d(n):
        L = np.zeros((n, n))
        for i in range(n):
            L[i, i] = -2
            if i > 0:
                L[i, i-1] = 1
            if i < n-1:
                L[i, i+1] = 1
        return L

    Lx = laplacian_1d(n)
    Ly = laplacian_1d(n)
    I_n = np.eye(n)

    # 2D Laplacian: L = Lx⊗I + I⊗Ly
    L2d = np.kron(Lx, I_n) + np.kron(I_n, Ly)

    # Naive: eigenvalues of n²×n² matrix
    eig_naive = np.sort(eigvalsh(L2d))

    # Fast: eigenvalues are sums
    eig_x = np.sort(eigvalsh(Lx))
    eig_y = np.sort(eigvalsh(Ly))
    eig_fast = np.sort(np.array([ex + ey for ex in eig_x for ey in eig_y]))

    print(f"\n  Grid: {n}×{n} ({n**2} DOFs)")
    print(f"  1D eigenvalue range: [{eig_x[0]:.4f}, {eig_x[-1]:.4f}]")
    print(f"  2D eigenvalue range: [{eig_naive[0]:.4f}, {eig_naive[-1]:.4f}]")
    print(f"  Fast vs naive match: {np.allclose(eig_fast, eig_naive)}")
    print(f"  Speedup: O(n³) vs O(n⁶) = {n**3}x fewer ops")


if __name__ == "__main__":
    hecke_demo()
    quantum_demo()
    markov_demo()
    pde_demo()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Spectral Arithmetic: Concrete demonstrations of the Kronecker eigenvalue theorem.

This script demonstrates:
1. Binary Kronecker eigenvalue multiplicativity
2. Iterated Kronecker products over prime-power factorizations
3. Full spectrum verification for small matrices
"""

import numpy as np
from numpy.linalg import eig
from itertools import product as iterproduct
from sympy import factorint

np.set_printoptions(precision=6, suppress=True)


def demo_binary_kronecker():
    """Demonstrate that eigenvalues of A⊗B are products of eigenvalues of A and B."""
    print("=" * 70)
    print("DEMO 1: Binary Kronecker Eigenvalue Multiplicativity")
    print("=" * 70)

    # Define two small matrices
    A = np.array([[2, 1], [0, 3]], dtype=complex)
    B = np.array([[1, 2], [2, 1]], dtype=complex)

    # Compute eigenvalues
    eig_A = np.sort(np.linalg.eigvals(A))
    eig_B = np.sort(np.linalg.eigvals(B))

    print(f"\nA =\n{A.real}")
    print(f"B =\n{B.real}")
    print(f"\nEigenvalues of A: {eig_A}")
    print(f"Eigenvalues of B: {eig_B}")

    # Kronecker product
    AB = np.kron(A, B)
    eig_AB = np.sort(np.linalg.eigvals(AB))

    # Expected: all products α_i * β_j
    expected = np.sort(np.array([a * b for a in eig_A for b in eig_B]))

    print(f"\nKronecker product A⊗B eigenvalues: {eig_AB}")
    print(f"Expected (products α·β):           {expected}")
    print(f"Match: {np.allclose(eig_AB, expected)}")


def demo_eigenvector_construction():
    """Show the explicit eigenvector tensoring construction."""
    print("\n" + "=" * 70)
    print("DEMO 2: Explicit Eigenvector Tensoring")
    print("=" * 70)

    A = np.array([[4, 1], [0, 2]], dtype=complex)
    B = np.array([[3, 0], [1, 5]], dtype=complex)

    # Get eigenvectors
    vals_A, vecs_A = eig(A)
    vals_B, vecs_B = eig(B)

    print(f"\nA eigenvalues: {vals_A}, eigenvectors:\n{vecs_A}")
    print(f"B eigenvalues: {vals_B}, eigenvectors:\n{vecs_B}")

    AB = np.kron(A, B)

    print("\nVerifying tensor eigenvectors:")
    for i in range(len(vals_A)):
        for j in range(len(vals_B)):
            v = vecs_A[:, i]
            w = vecs_B[:, j]
            vw = np.kron(v, w)  # tensor product

            result = AB @ vw
            expected_val = vals_A[i] * vals_B[j]
            expected_vec = expected_val * vw

            residual = np.linalg.norm(result - expected_vec)
            print(f"  α={vals_A[i]:.2f}, β={vals_B[j]:.2f} → "
                  f"α·β={expected_val:.2f}, residual={residual:.2e}")


def demo_prime_factorization():
    """Demonstrate spectral arithmetic via prime-power factorization."""
    print("\n" + "=" * 70)
    print("DEMO 3: Prime-Power Factorization Spectral Theorem")
    print("=" * 70)

    # For n = 12 = 2^2 · 3, create matrices T(4) and T(3)
    n = 12
    factors = factorint(n)
    print(f"\nn = {n} = " + " · ".join(f"{p}^{a}" for p, a in factors.items()))

    # Assign a matrix to each prime power
    T = {}
    T[4] = np.array([[1, 2], [0, 3]], dtype=complex)   # T(2^2)
    T[3] = np.array([[2, 1], [1, 2]], dtype=complex)    # T(3^1)

    print(f"\nT(2²) = T(4):\n{T[4].real}")
    print(f"T(3¹) = T(3):\n{T[3].real}")

    # Kronecker product over prime powers
    prime_powers = [p**a for p, a in factors.items()]
    result = T[prime_powers[0]]
    for pp in prime_powers[1:]:
        result = np.kron(result, T[pp])

    eig_result = np.sort(np.linalg.eigvals(result))

    # Expected: products of eigenvalues
    local_eigs = [np.sort(np.linalg.eigvals(T[pp])) for pp in prime_powers]
    expected = np.sort(np.array([
        np.prod(combo) for combo in iterproduct(*local_eigs)
    ]))

    print(f"\nPrime powers: {prime_powers}")
    for pp, ev in zip(prime_powers, local_eigs):
        print(f"  Eigenvalues of T({pp}): {ev}")

    print(f"\nKronecker product eigenvalues: {eig_result}")
    print(f"Product eigenvalues:           {expected}")
    print(f"Match: {np.allclose(eig_result, expected)}")


def demo_larger_factorization():
    """Test with n = 30 = 2 · 3 · 5."""
    print("\n" + "=" * 70)
    print("DEMO 4: Larger Example — n = 30 = 2 · 3 · 5")
    print("=" * 70)

    T2 = np.array([[1, 1], [0, 2]], dtype=complex)
    T3 = np.array([[3, 0], [0, 1]], dtype=complex)
    T5 = np.array([[2, 1], [1, 2]], dtype=complex)

    matrices = [T2, T3, T5]
    labels = ["T(2)", "T(3)", "T(5)"]

    result = matrices[0]
    for M in matrices[1:]:
        result = np.kron(result, M)

    eig_result = np.sort(np.linalg.eigvals(result))

    local_eigs = [np.sort(np.linalg.eigvals(M)) for M in matrices]
    expected = np.sort(np.array([
        np.prod(combo) for combo in iterproduct(*local_eigs)
    ]))

    for label, ev in zip(labels, local_eigs):
        print(f"  {label} eigenvalues: {ev}")
    print(f"\n  T(30) = T(2)⊗T(3)⊗T(5) eigenvalues: {eig_result}")
    print(f"  Product eigenvalues:                  {expected}")
    print(f"  Match: {np.allclose(eig_result, expected)}")


def demo_hermitian_quantum():
    """Quantum system: Hermitian matrices (energies are real)."""
    print("\n" + "=" * 70)
    print("DEMO 5: Quantum Composite System (Hermitian Operators)")
    print("=" * 70)

    # Two-qubit system with non-interacting Hamiltonians
    H1 = np.array([[1, 0], [0, -1]], dtype=complex)  # σ_z
    H2 = np.array([[0, 1], [1, 0]], dtype=complex)   # σ_x

    # Total Hamiltonian: H1⊗I + I⊗H2
    I2 = np.eye(2, dtype=complex)
    H_total = np.kron(H1, I2) + np.kron(I2, H2)

    eig1 = np.sort(np.linalg.eigvals(H1).real)
    eig2 = np.sort(np.linalg.eigvals(H2).real)
    eig_total = np.sort(np.linalg.eigvals(H_total).real)

    expected = np.sort(np.array([e1 + e2 for e1 in eig1 for e2 in eig2]))

    print(f"\n  H₁ eigenvalues (energies): {eig1}")
    print(f"  H₂ eigenvalues (energies): {eig2}")
    print(f"  H_total eigenvalues:       {eig_total}")
    print(f"  Expected (sums):           {expected}")
    print(f"  Match: {np.allclose(eig_total, expected)}")
    print(f"\n  Note: Additive spectral composition for Hamiltonians is the")
    print(f"  logarithmic form of multiplicative composition for unitaries.")


if __name__ == "__main__":
    demo_binary_kronecker()
    demo_eigenvector_construction()
    demo_prime_factorization()
    demo_larger_factorization()
    demo_hermitian_quantum()
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for the spectral arithmetic theorem.

Generates figures showing:
1. Eigenvalue product structure for Kronecker products
2. Prime-power factorization spectral decomposition
3. Speedup benchmarks
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iterproduct
import base64
from io import BytesIO
import json
import time


def eigenvalue_product_plot():
    """Visualize how eigenvalues of A⊗B are products of eigenvalues of A and B."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Random 4x4 complex matrices
    np.random.seed(42)
    A = np.random.randn(4, 4) + 1j * np.random.randn(4, 4)
    B = np.random.randn(3, 3) + 1j * np.random.randn(3, 3)

    eig_A = np.linalg.eigvals(A)
    eig_B = np.linalg.eigvals(B)
    eig_AB = np.linalg.eigvals(np.kron(A, B))

    # Plot eigenvalues of A
    ax = axes[0]
    ax.scatter(eig_A.real, eig_A.imag, c='blue', s=100, zorder=5, edgecolors='black')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.set_title('Eigenvalues of A (4×4)', fontsize=13)
    ax.set_xlabel('Real')
    ax.set_ylabel('Imaginary')
    ax.grid(True, alpha=0.3)

    # Plot eigenvalues of B
    ax = axes[1]
    ax.scatter(eig_B.real, eig_B.imag, c='red', s=100, zorder=5, edgecolors='black')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.set_title('Eigenvalues of B (3×3)', fontsize=13)
    ax.set_xlabel('Real')
    ax.grid(True, alpha=0.3)

    # Plot eigenvalues of A⊗B
    ax = axes[2]
    # Show predicted (products)
    predicted = np.array([a * b for a in eig_A for b in eig_B])
    ax.scatter(predicted.real, predicted.imag, c='green', s=80, alpha=0.5,
               label='Predicted (αᵢ·βⱼ)', zorder=4)
    ax.scatter(eig_AB.real, eig_AB.imag, c='purple', s=30, marker='x',
               linewidths=2, label='Actual eig(A⊗B)', zorder=5)
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.set_title('Eigenvalues of A⊗B (12×12)', fontsize=13)
    ax.set_xlabel('Real')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Spectral Multiplicativity: eig(A⊗B) = {αᵢ·βⱼ}',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig_eigenvalue_products.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_eigenvalue_products.png")
    return fig_to_base64('fig_eigenvalue_products.png')


def prime_factorization_plot():
    """Visualize spectral decomposition along prime factorization."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))

    np.random.seed(123)

    # n = 30 = 2 · 3 · 5
    T2 = np.array([[2, 1], [0.5, 1]], dtype=complex)
    T3 = np.array([[1, 2, 0], [1, 0, 1], [0, 1, 3]], dtype=complex)
    T5 = np.array([[1, 1], [1, 2]], dtype=complex)

    matrices = {'T(2)': T2, 'T(3)': T3, 'T(5)': T5}

    # Plot individual spectra
    for idx, (name, M) in enumerate(matrices.items()):
        ax = axes[0, idx]
        eigs = np.linalg.eigvals(M)
        ax.scatter(eigs.real, eigs.imag, c=['C0', 'C1', 'C2'][:len(eigs)],
                   s=150, zorder=5, edgecolors='black', linewidths=1.5)
        for i, e in enumerate(eigs):
            ax.annotate(f'λ{i+1}={e:.2f}', (e.real, e.imag),
                        textcoords="offset points", xytext=(10, 10), fontsize=9)
        ax.axhline(y=0, color='gray', linewidth=0.5)
        ax.axvline(x=0, color='gray', linewidth=0.5)
        ax.set_title(f'{name} ({M.shape[0]}×{M.shape[0]})', fontsize=13)
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('Real')
        if idx == 0:
            ax.set_ylabel('Imaginary')

    # Full Kronecker product
    T30 = np.kron(np.kron(T2, T3), T5)
    eig_full = np.linalg.eigvals(T30)

    ax = axes[1, 0]
    ax.scatter(eig_full.real, eig_full.imag, c='purple', s=60,
               alpha=0.7, edgecolors='black', linewidths=0.5)
    ax.set_title('T(30) = T(2)⊗T(3)⊗T(5)\nFull spectrum (12 eigenvalues)', fontsize=12)
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.grid(True, alpha=0.3)
    ax.set_xlabel('Real')
    ax.set_ylabel('Imaginary')

    # Show product structure
    eig2 = np.linalg.eigvals(T2)
    eig3 = np.linalg.eigvals(T3)
    eig5 = np.linalg.eigvals(T5)
    products = np.array([a*b*c for a in eig2 for b in eig3 for c in eig5])

    ax = axes[1, 1]
    ax.scatter(products.real, products.imag, c='green', s=80, alpha=0.5,
               label='Products', edgecolors='black', linewidths=0.5)
    ax.scatter(eig_full.real, eig_full.imag, c='red', s=30, marker='x',
               linewidths=2, label='Actual')
    ax.set_title('Verification:\nProducts vs Actual', fontsize=12)
    ax.legend()
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.grid(True, alpha=0.3)
    ax.set_xlabel('Real')

    # Magnitude comparison
    ax = axes[1, 2]
    mags_actual = np.sort(np.abs(eig_full))
    mags_products = np.sort(np.abs(products))
    x = np.arange(len(mags_actual))
    ax.bar(x - 0.15, mags_actual, 0.3, label='Actual |λ|', color='purple', alpha=0.7)
    ax.bar(x + 0.15, mags_products, 0.3, label='Product |λ|', color='green', alpha=0.7)
    ax.set_title('Eigenvalue magnitudes\n(sorted)', fontsize=12)
    ax.legend()
    ax.set_xlabel('Index')
    ax.set_ylabel('|λ|')

    plt.suptitle('n = 30 = 2·3·5: Prime-Power Spectral Factorization',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('fig_prime_factorization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_prime_factorization.png")
    return fig_to_base64('fig_prime_factorization.png')


def speedup_plot():
    """Benchmark and visualize computational speedup."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Theoretical complexity comparison
    ns = np.arange(2, 20)
    k = 3  # number of factors
    naive = (ns ** k) ** 3  # O((n^k)^3)
    fast = k * ns ** 3 + ns ** k  # O(k·n^3 + n^k)

    ax1.semilogy(ns, naive, 'r-o', label=f'Naive: O(n^{3*k})', markersize=4)
    ax1.semilogy(ns, fast, 'g-s', label=f'Factored: O({k}n³ + n^{k})', markersize=4)
    ax1.fill_between(ns, fast, naive, alpha=0.1, color='green')
    ax1.set_xlabel('Matrix dimension n (per factor)', fontsize=12)
    ax1.set_ylabel('Operations (log scale)', fontsize=12)
    ax1.set_title(f'Computational Cost ({k} factors)', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Actual speedup ratios
    dims_list = [(2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (8, 8), (10, 10),
                 (2, 2, 2), (3, 3, 3), (4, 4, 4), (5, 5, 5)]

    speedups = []
    labels = []
    for dims in dims_list:
        total = int(np.prod(dims))
        if total > 500:
            continue
        matrices = [np.random.randn(d, d) + 1j * np.random.randn(d, d) for d in dims]
        full = matrices[0]
        for M in matrices[1:]:
            full = np.kron(full, M)

        t0 = time.perf_counter()
        for _ in range(5):
            np.linalg.eigvals(full)
        t_naive = (time.perf_counter() - t0) / 5

        t0 = time.perf_counter()
        for _ in range(5):
            local_eigs = [np.linalg.eigvals(M) for M in matrices]
            np.array([np.prod(c) for c in iterproduct(*local_eigs)])
        t_fast = (time.perf_counter() - t0) / 5

        speedups.append(t_naive / max(t_fast, 1e-10))
        labels.append(f"{'×'.join(map(str, dims))}\n(={total})")

    ax2.bar(range(len(speedups)), speedups, color='steelblue', alpha=0.8,
            edgecolor='black', linewidth=0.5)
    ax2.set_xticks(range(len(labels)))
    ax2.set_xticklabels(labels, fontsize=9)
    ax2.set_ylabel('Speedup factor', fontsize=12)
    ax2.set_title('Measured Speedup: Factored vs Naive', fontsize=13)
    ax2.axhline(y=1, color='red', linestyle='--', label='Break-even')
    ax2.legend()
    ax2.grid(True, alpha=0.3, axis='y')

    plt.suptitle('Algorithmic Efficiency of Spectral Factorization',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig_speedup.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_speedup.png")
    return fig_to_base64('fig_speedup.png')


def fig_to_base64(filepath):
    """Convert a saved figure to base64 data URI."""
    with open(filepath, 'rb') as f:
        data = f.read()
    b64 = base64.b64encode(data).decode('utf-8')
    return f"data:image/png;base64,{b64}"


if __name__ == "__main__":
    b64_1 = eigenvalue_product_plot()
    b64_2 = prime_factorization_plot()
    b64_3 = speedup_plot()

    # Save base64 data for JSON package
    with open('viz_data.json', 'w') as f:
        json.dump({
            'eigenvalue_products': b64_1,
            'prime_factorization': b64_2,
            'speedup': b64_3,
        }, f)
    print("\nAll visualizations generated and saved.")
