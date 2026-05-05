"""
Ring Commutator Calculus — Interactive Demonstrations

This script demonstrates the key theorems from the formal Lean development
with concrete numerical examples using matrix rings, the most natural
setting for noncommutative algebra.

Demonstrations include:
1. Basic commutator properties (antisymmetry, additivity)
2. The Leibniz rule (derivation property)
3. The Jacobi identity
4. Power commutator formula
5. Double commutator and the BCH connection
6. Visualization of commutator structure in matrix rings
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.gridspec as gridspec
from itertools import product as cartesian_product

# ============================================================
# Core: Ring Commutator
# ============================================================

def rc(A, B):
    """Ring commutator: [A, B] = AB - BA"""
    return A @ B - B @ A


def random_matrix(n=3, seed=None):
    """Generate a random integer matrix for clean demonstrations."""
    rng = np.random.default_rng(seed)
    return rng.integers(-5, 6, size=(n, n)).astype(float)


# ============================================================
# Demo 1: Basic Properties
# ============================================================

def demo_basic_properties():
    """Verify antisymmetry, self-commutator, and additivity."""
    print("=" * 60)
    print("DEMO 1: Basic Commutator Properties")
    print("=" * 60)

    A = random_matrix(3, seed=42)
    B = random_matrix(3, seed=43)
    C = random_matrix(3, seed=44)

    # Antisymmetry: [A,B] = -[B,A]
    lhs = rc(A, B)
    rhs = -rc(B, A)
    print("\n1. Antisymmetry: [A,B] = -[B,A]")
    print(f"   ||[A,B] - (-[B,A])|| = {np.linalg.norm(lhs - rhs):.2e}")

    # Self-commutator: [A,A] = 0
    print(f"\n2. Self-commutator: ||[A,A]|| = {np.linalg.norm(rc(A, A)):.2e}")

    # Left additivity: [A+B, C] = [A,C] + [B,C]
    lhs = rc(A + B, C)
    rhs = rc(A, C) + rc(B, C)
    print(f"\n3. Left additivity: ||[A+B,C] - ([A,C]+[B,C])|| = {np.linalg.norm(lhs - rhs):.2e}")

    # Right additivity: [A, B+C] = [A,B] + [A,C]
    lhs = rc(A, B + C)
    rhs = rc(A, B) + rc(A, C)
    print(f"\n4. Right additivity: ||[A,B+C] - ([A,B]+[A,C])|| = {np.linalg.norm(lhs - rhs):.2e}")

    # Identity commutators
    I = np.eye(3)
    print(f"\n5. [I,A] = 0: ||[I,A]|| = {np.linalg.norm(rc(I, A)):.2e}")
    print(f"   [A,I] = 0: ||[A,I]|| = {np.linalg.norm(rc(A, I)):.2e}")

    # Trace identity
    print(f"\n6. Trace identity: [A,B]+[B,A] = 0")
    print(f"   ||[A,B]+[B,A]|| = {np.linalg.norm(rc(A, B) + rc(B, A)):.2e}")


# ============================================================
# Demo 2: Leibniz Rule (Derivation Property)
# ============================================================

def demo_leibniz_rule():
    """The commutator map ad(A): X ↦ [A,X] satisfies the Leibniz rule."""
    print("\n" + "=" * 60)
    print("DEMO 2: Leibniz Rule (Derivation Property)")
    print("=" * 60)

    A = random_matrix(3, seed=10)
    B = random_matrix(3, seed=11)
    C = random_matrix(3, seed=12)

    # Right Leibniz: [A, BC] = [A,B]C + B[A,C]
    lhs = rc(A, B @ C)
    rhs = rc(A, B) @ C + B @ rc(A, C)
    print(f"\nRight Leibniz: [A,BC] = [A,B]C + B[A,C]")
    print(f"  ||error|| = {np.linalg.norm(lhs - rhs):.2e}")

    # Left Leibniz: [AB, C] = A[B,C] + [A,C]B
    lhs = rc(A @ B, C)
    rhs = A @ rc(B, C) + rc(A, C) @ B
    print(f"\nLeft Leibniz: [AB,C] = A[B,C] + [A,C]B")
    print(f"  ||error|| = {np.linalg.norm(lhs - rhs):.2e}")

    print("\n  → The map X ↦ [A,X] is a DERIVATION on the ring!")
    print("  → This is the algebraic core of differential operators.")


# ============================================================
# Demo 3: The Jacobi Identity
# ============================================================

def demo_jacobi_identity():
    """Verify the Jacobi identity for several random matrices."""
    print("\n" + "=" * 60)
    print("DEMO 3: The Jacobi Identity")
    print("=" * 60)

    print("\n  [A,[B,C]] + [B,[C,A]] + [C,[A,B]] = 0")
    print()

    for trial in range(5):
        A = random_matrix(4, seed=100 + trial)
        B = random_matrix(4, seed=200 + trial)
        C = random_matrix(4, seed=300 + trial)

        jacobi = rc(A, rc(B, C)) + rc(B, rc(C, A)) + rc(C, rc(A, B))
        err = np.linalg.norm(jacobi)
        print(f"  Trial {trial + 1} (4×4 matrices): ||Jacobi|| = {err:.2e}")

    print("\n  → Every associative ring is a Lie ring under [·,·]!")


# ============================================================
# Demo 4: Power Commutator Formula
# ============================================================

def demo_power_commutator():
    """When [A,B] commutes with B: [A, B^n] = n·[A,B]·B^{n-1}."""
    print("\n" + "=" * 60)
    print("DEMO 4: Power Commutator Formula")
    print("=" * 60)

    # Construct a case where [A,B] commutes with B.
    # Use A = diagonal, B arbitrary → [A,B] has nice structure
    # Actually, let's use the Pauli-like setting where [A,B] is a scalar multiple of I
    A = np.array([[1, 0, 0], [0, 2, 0], [0, 0, 3]], dtype=float)
    B = np.array([[0, 1, 0], [0, 0, 1], [0, 0, 0]], dtype=float)

    comm_AB = rc(A, B)
    # Check if [A,B] commutes with B
    commutator_check = rc(comm_AB, B)
    print(f"\n  A = diag(1,2,3),  B = upper shift matrix")
    print(f"  [A,B] =\n{comm_AB}")
    print(f"  Does [A,B] commute with B? ||[[A,B],B]|| = {np.linalg.norm(commutator_check):.2e}")

    if np.linalg.norm(commutator_check) < 1e-10:
        print("\n  ✓ Hypothesis satisfied! Testing [A, B^n] = n·[A,B]·B^{n-1}:")
        for n in range(1, 6):
            lhs = rc(A, np.linalg.matrix_power(B, n))
            rhs = n * comm_AB @ np.linalg.matrix_power(B, n - 1)
            err = np.linalg.norm(lhs - rhs)
            print(f"    n={n}: ||error|| = {err:.2e}")
    else:
        # Find a case that works: A diagonal, B diagonal
        print("\n  Trying with A,B both diagonal (where they commute trivially)...")
        # More interesting: use A,B where [A,B] is scalar
        # Pauli matrices
        sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
        sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
        sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)

        A, B = sigma_z, sigma_x  # [σ_z, σ_x] = 2i·σ_y
        comm_AB = rc(A, B)
        print(f"\n  Using Pauli matrices: A = σ_z, B = σ_x")
        print(f"  [A,B] = {comm_AB}")


# ============================================================
# Demo 5: Double Commutator and BCH
# ============================================================

def demo_double_commutator():
    """Verify [A,[A,B]] = A²B - 2ABA + BA²."""
    print("\n" + "=" * 60)
    print("DEMO 5: Double Commutator (BCH Connection)")
    print("=" * 60)

    A = random_matrix(3, seed=77)
    B = random_matrix(3, seed=78)

    lhs = rc(A, rc(A, B))
    rhs = A @ A @ B - 2 * A @ B @ A + B @ A @ A
    err = np.linalg.norm(lhs - rhs)

    print(f"\n  [A,[A,B]] = A²B - 2·ABA + BA²")
    print(f"  ||error|| = {err:.2e}")

    print(f"\n  This identity appears in the Baker-Campbell-Hausdorff formula:")
    print(f"  exp(A)·exp(B) = exp(A + B + ½[A,B] + ¹⁄₁₂[A,[A,B]] - ¹⁄₁₂[B,[A,B]] + ...)")


# ============================================================
# Demo 6: Quantum Mechanics Application
# ============================================================

def demo_quantum_mechanics():
    """The commutator in quantum mechanics: Heisenberg's equation."""
    print("\n" + "=" * 60)
    print("DEMO 6: Quantum Mechanics — Heisenberg Commutation")
    print("=" * 60)

    # Position and momentum in truncated Hilbert space (Fock basis)
    n_dim = 6

    # Creation and annihilation operators
    a_dag = np.zeros((n_dim, n_dim))
    for i in range(n_dim - 1):
        a_dag[i, i + 1] = np.sqrt(i + 1)
    a = a_dag.T

    # x̂ ∝ (a + a†),  p̂ ∝ i(a† - a)
    x_hat = (a + a_dag) / np.sqrt(2)
    p_hat = 1j * (a_dag - a) / np.sqrt(2)

    # [x̂, p̂] should be iI (in natural units ℏ=1)
    # NOTE: The canonical commutation relation [x,p] = i has NO finite-dimensional
    # representation (since tr([A,B]) = 0 but tr(iI) = ni ≠ 0). This is a deep
    # consequence of our trace identity theorem rc_add_swap!
    comm_xp = rc(x_hat, p_hat)
    print(f"\n  [x̂, p̂] (truncated to {n_dim}×{n_dim}):")
    diag = np.diag(comm_xp)
    print(f"  Diagonal: {np.round(np.imag(diag), 4)}·i")
    print(f"  NOTE: tr([A,B]) = 0 always (our rc_add_swap theorem!),")
    print(f"  but tr(iI) = {n_dim}i ≠ 0. So the CCR has NO finite-dim representation.")
    print(f"  This is a deep consequence of the commutator calculus!")

    # Leibniz rule in QM: [x̂, p̂²] = [x̂,p̂]p̂ + p̂[x̂,p̂] = 2ip̂
    lhs = rc(x_hat, p_hat @ p_hat)
    rhs = rc(x_hat, p_hat) @ p_hat + p_hat @ rc(x_hat, p_hat)
    print(f"\n  Leibniz rule: [x̂, p̂²] = [x̂,p̂]p̂ + p̂[x̂,p̂]")
    print(f"  ||error|| = {np.linalg.norm(lhs - rhs):.2e}")


# ============================================================
# Visualization: Commutator Magnitude Landscape
# ============================================================

def visualize_commutator_landscape():
    """Visualize how the commutator varies over parameterized matrix families."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("Ring Commutator Calculus — Visualizations",
                 fontsize=14, fontweight='bold')

    # --- Panel 1: Commutator norm for rotation matrices ---
    ax = axes[0]
    thetas = np.linspace(0, 2 * np.pi, 100)
    phis = np.linspace(0, 2 * np.pi, 100)

    norms = np.zeros((len(thetas), len(phis)))
    for i, theta in enumerate(thetas):
        A = np.array([[np.cos(theta), -np.sin(theta)],
                       [np.sin(theta), np.cos(theta)]])
        for j, phi in enumerate(phis):
            B = np.array([[np.cos(phi), -np.sin(phi)],
                           [np.sin(phi), np.cos(phi)]])
            norms[i, j] = np.linalg.norm(rc(A, B))

    im = ax.imshow(norms, extent=[0, 360, 0, 360], origin='lower',
                   cmap='magma', aspect='equal')
    ax.set_xlabel('φ (degrees)')
    ax.set_ylabel('θ (degrees)')
    ax.set_title('||[R(θ), R(φ)]|| for 2D rotations\n(Always 0: rotations commute!)')
    plt.colorbar(im, ax=ax, shrink=0.8)

    # --- Panel 2: Commutator of Pauli-like matrices ---
    ax = axes[1]
    # Parameterize: A = cos(t)σ_x + sin(t)σ_z, B = σ_y
    # Plot ||[A(t), B]|| and tr([A(t), B])
    ts = np.linspace(0, 2 * np.pi, 200)
    sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
    sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
    sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)

    comm_norms = []
    comm_traces = []
    for t in ts:
        A = np.cos(t) * sigma_x + np.sin(t) * sigma_z
        C = rc(A, sigma_y)
        comm_norms.append(np.linalg.norm(C))
        comm_traces.append(np.abs(np.trace(C)))

    ax.plot(np.degrees(ts), comm_norms, 'b-', linewidth=2, label='||[A(t), σ_y]||')
    ax.plot(np.degrees(ts), comm_traces, 'r--', linewidth=2, label='|tr([A(t), σ_y])|')
    ax.set_xlabel('t (degrees)')
    ax.set_ylabel('Magnitude')
    ax.set_title('Commutator of Pauli combinations\nA(t) = cos(t)σ_x + sin(t)σ_z')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # --- Panel 3: Jacobi identity verification ---
    ax = axes[2]
    dims = range(2, 9)
    jacobi_norms = []
    for d in dims:
        errors = []
        for _ in range(50):
            A = np.random.randn(d, d)
            B = np.random.randn(d, d)
            C = np.random.randn(d, d)
            jacobi = rc(A, rc(B, C)) + rc(B, rc(C, A)) + rc(C, rc(A, B))
            errors.append(np.linalg.norm(jacobi))
        jacobi_norms.append(errors)

    bp = ax.boxplot(jacobi_norms, tick_labels=[str(d) for d in dims],
                    patch_artist=True)
    for patch in bp['boxes']:
        patch.set_facecolor('lightblue')
    ax.set_xlabel('Matrix dimension n')
    ax.set_ylabel('||Jacobi sum|| (should be ≈ 0)')
    ax.set_title('Jacobi Identity Verification\nacross matrix dimensions')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('python/commutator_visualizations.png', dpi=150, bbox_inches='tight')
    print(f"\n  [Saved: python/commutator_visualizations.png]")
    plt.close()


# ============================================================
# Visualization: Derivation Property
# ============================================================

def visualize_derivation():
    """Visualize how the commutator map acts as a derivation."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle("The Commutator as a Derivation",
                 fontsize=14, fontweight='bold')

    # Fix A, vary B along a path, show [A, B(t)] and d/dt(B(t))
    A = np.array([[0, 1], [-1, 0]], dtype=float)  # antisymmetric

    ts = np.linspace(0, 4 * np.pi, 200)

    # B(t) = exp(tC) for some C
    C_gen = np.array([[0, 1], [-1, 0]], dtype=float)

    # Track entries of [A, B(t)]
    comm_entries = [[], [], [], []]
    B_entries = [[], [], [], []]

    for t in ts:
        from scipy.linalg import expm
        Bt = expm(t * C_gen)
        comm = rc(A, Bt)
        for idx, (i, j) in enumerate([(0, 0), (0, 1), (1, 0), (1, 1)]):
            comm_entries[idx].append(comm[i, j])
            B_entries[idx].append(Bt[i, j])

    ax = axes[0]
    labels = ['(0,0)', '(0,1)', '(1,0)', '(1,1)']
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    for idx in range(4):
        ax.plot(ts, comm_entries[idx], color=colors[idx],
                label=f'[A,B(t)]_{labels[idx]}', linewidth=1.5)
    ax.set_xlabel('t')
    ax.set_ylabel('[A, B(t)] entries')
    ax.set_title('Commutator along a matrix curve')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Show Leibniz verification: [A, B(t)²] vs [A,B(t)]B(t) + B(t)[A,B(t)]
    ax = axes[1]
    leibniz_errors = []
    for t in ts:
        Bt = expm(t * C_gen)
        lhs = rc(A, Bt @ Bt)
        rhs = rc(A, Bt) @ Bt + Bt @ rc(A, Bt)
        leibniz_errors.append(np.linalg.norm(lhs - rhs))

    ax.semilogy(ts, leibniz_errors, 'b-', linewidth=1.5)
    ax.set_xlabel('t')
    ax.set_ylabel('||Leibniz error||')
    ax.set_title('Leibniz rule: [A, B²] = [A,B]B + B[A,B]\n(Error ≈ machine epsilon)')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('python/derivation_property.png', dpi=150, bbox_inches='tight')
    print(f"  [Saved: python/derivation_property.png]")
    plt.close()


# ============================================================
# Application: Commutator-based Matrix Decomposition
# ============================================================

def demo_application_decomposition():
    """Application: Decomposing matrices using commutator structure."""
    print("\n" + "=" * 60)
    print("APPLICATION: Commutator-Based Matrix Analysis")
    print("=" * 60)

    n = 4
    M = random_matrix(n, seed=999)

    # Any matrix M can be decomposed as M = S + K where
    # S = (M + M^T)/2 is symmetric and K = (M - M^T)/2 is skew-symmetric
    S = (M + M.T) / 2
    K = (M - M.T) / 2

    print(f"\n  Matrix M decomposed as M = S + K")
    print(f"  ||M - (S+K)|| = {np.linalg.norm(M - S - K):.2e}")
    print(f"  S is symmetric: ||S - S^T|| = {np.linalg.norm(S - S.T):.2e}")
    print(f"  K is skew-symmetric: ||K + K^T|| = {np.linalg.norm(K + K.T):.2e}")

    # Key identity: [K, S] tells us about the non-normality of M
    comm_KS = rc(K, S)
    print(f"\n  ||[K, S]|| = {np.linalg.norm(comm_KS):.4f}")
    print(f"  (measures how far M is from being normal)")

    # For a normal matrix, M commutes with M^T, which means [K,S] = 0
    # because M*M^T = M^T*M implies [M, M^T] = 0
    # which gives [S+K, S-K] = 0, hence 2[K,S] = 0
    normal_check = np.linalg.norm(rc(M, M.T))
    print(f"  ||[M, M^T]|| = {normal_check:.4f}")
    # [M, M^T] = [S+K, S-K] = -[S,K]+[K,S] = 2[K,S] (using antisymmetry)
    print(f"  Relation: [M, M^T] = 2[K, S]  (by antisymmetry of commutator)")
    print(f"  Verification: ||[M,M^T] - 2[K,S]|| = {np.linalg.norm(rc(M, M.T) - 2*comm_KS):.2e}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Ring Commutator Calculus — Interactive Demonstrations  ║")
    print("║   Formal proofs verified in Lean 4 + Mathlib            ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_basic_properties()
    demo_leibniz_rule()
    demo_jacobi_identity()
    demo_power_commutator()
    demo_double_commutator()
    demo_quantum_mechanics()
    demo_application_decomposition()

    print("\n\nGenerating visualizations...")
    visualize_commutator_landscape()
    visualize_derivation()

    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)
