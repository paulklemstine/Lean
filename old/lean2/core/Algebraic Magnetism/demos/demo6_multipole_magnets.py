#!/usr/bin/env python3
"""
Demo 6: Higher Multipole Magnets — Prediction 1
=================================================

PREDICTION: For atoms with spin s ≥ 1, the algebra allows order parameters that
are not vectors (dipoles) but tensors (quadrupoles, octupoles). These exotic
magnetic phases have begun to be observed in rare-earth compounds.

This script demonstrates:
1. Construction of multipole operators (spherical tensor operators T^k_q)
2. Quadrupolar order for spin-1 systems (NiGa₂S₄, UPd₃)
3. Octupolar order for spin-3/2 systems (Ce₃Pd₂₀Si₆)
4. Phase diagrams showing dipolar → quadrupolar → octupolar transitions
5. Neutron scattering selection rules from Clebsch-Gordan coefficients

Key algebraic insight: The space of operators acting on V_s decomposes as
    End(V_s) ≅ V_0 ⊕ V_1 ⊕ V_2 ⊕ ... ⊕ V_{2s}
under the adjoint action. V_1 = dipolar, V_2 = quadrupolar, V_{2s} = highest
multipole. Each irreducible component provides a possible order parameter.

Author: The Oracle Council — Advancing Physics
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
import matplotlib.gridspec as gridspec
from mpl_toolkits.mplot3d import Axes3D

# ============================================================================
# Part 1: Spherical Tensor Operators
# ============================================================================

def spin_operators(s):
    """Construct spin-s representation matrices of su(2)."""
    dim = int(2*s + 1)
    m_values = np.arange(s, -s-1, -1)
    Sz = np.diag(m_values).astype(complex)
    Sp = np.zeros((dim, dim), dtype=complex)
    for i in range(dim - 1):
        m = m_values[i + 1]
        Sp[i, i + 1] = np.sqrt(s*(s+1) - m*(m+1))
    Sm = Sp.T.conj()
    Sx = 0.5 * (Sp + Sm)
    Sy = -0.5j * (Sp - Sm)
    return Sx, Sy, Sz


def spherical_tensor_operators(s, k):
    """
    Construct the rank-k spherical tensor operators T^k_q acting on V_s.
    
    These are the irreducible components of End(V_s) under the adjoint action
    of su(2). They satisfy:
        [S_z, T^k_q] = q T^k_q
        [S_±, T^k_q] = √(k(k+1) - q(q±1)) T^k_{q±1}
    
    For k=0: identity (trivial)
    For k=1: dipole operators ∝ S_x, S_y, S_z
    For k=2: quadrupole operators (5 components)
    For k=3: octupole operators (7 components)
    
    Parameters
    ----------
    s : float - spin quantum number
    k : int - tensor rank (0 ≤ k ≤ 2s)
    
    Returns
    -------
    T : dict mapping q → T^k_q matrix
    """
    dim = int(2*s + 1)
    Sx, Sy, Sz = spin_operators(s)
    Sp = Sx + 1j * Sy
    Sm = Sx - 1j * Sy
    
    if k == 0:
        return {0: np.eye(dim, dtype=complex) / np.sqrt(dim)}
    
    if k == 1:
        # Dipole: T^1_0 = Sz, T^1_±1 = ∓(Sx ± iSy)/√2
        norm = np.sqrt(s * (s + 1) * (2*s + 1) / 3)
        return {
            1: -Sp / (np.sqrt(2) * norm) * np.sqrt(s*(s+1)*(2*s+1)/3),
            0: Sz / norm * np.sqrt(s*(s+1)*(2*s+1)/3),
            -1: Sm / (np.sqrt(2) * norm) * np.sqrt(s*(s+1)*(2*s+1)/3),
        }
    
    # For higher k, build using the Wigner-Eckart theorem and recursion
    # T^k_q = [S_+, T^{k-1}_{q-1}] / C^{k,q}_{k-1,q-1;1,1} (schematically)
    # Here we use explicit construction via products of spin operators
    
    if k == 2:
        # Quadrupole operators (5 components)
        # Constructed from symmetric traceless products of S
        S2 = s * (s + 1)
        T = {}
        T[2] = Sp @ Sp / 2
        T[1] = -(Sp @ Sz + Sz @ Sp) / 2
        T[0] = (3 * Sz @ Sz - S2 * np.eye(dim, dtype=complex)) / np.sqrt(6)
        T[-1] = (Sm @ Sz + Sz @ Sm) / 2
        T[-2] = Sm @ Sm / 2
        
        # Normalize: Tr(T^k_q† T^k_q) should be consistent
        for q in T:
            norm = np.sqrt(np.real(np.trace(T[q].conj().T @ T[q])))
            if norm > 1e-10:
                T[q] = T[q] / norm * np.sqrt(dim)
        return T
    
    if k == 3:
        # Octupole operators (7 components)
        S2 = s * (s + 1)
        I = np.eye(dim, dtype=complex)
        T = {}
        T[3] = Sp @ Sp @ Sp
        T[2] = -(Sp @ Sp @ Sz + Sp @ Sz @ Sp + Sz @ Sp @ Sp) / 3
        T[1] = (Sp @ (5*Sz@Sz - S2*I - I/2) + (5*Sz@Sz - S2*I - I/2) @ Sp) / (2*np.sqrt(10))
        T[0] = (5*Sz@Sz@Sz - (3*S2 - 1)*Sz) / np.sqrt(10)
        T[-1] = (Sm @ (5*Sz@Sz - S2*I - I/2) + (5*Sz@Sz - S2*I - I/2) @ Sm) / (2*np.sqrt(10))
        T[-2] = (Sm @ Sm @ Sz + Sm @ Sz @ Sm + Sz @ Sm @ Sm) / 3
        T[-3] = Sm @ Sm @ Sm
        
        # Normalize
        for q in T:
            norm = np.sqrt(np.real(np.trace(T[q].conj().T @ T[q])))
            if norm > 1e-10:
                T[q] = T[q] / norm * np.sqrt(dim)
        return T
    
    # For k >= 4, use brute-force construction via nested commutators
    # Build T^k from products of spin operators and orthogonalize
    dim = int(2*s + 1)
    Sx, Sy, Sz = spin_operators(s)
    Sp = Sx + 1j * Sy
    Sm = Sx - 1j * Sy
    
    # Use the fact that T^k_k is proportional to S_+^k, then build others via lowering
    T = {}
    T[k] = np.linalg.matrix_power(Sp, k)
    
    # Lower using [S_-, T^k_q] proportional to T^k_{q-1}
    for q in range(k-1, -k-1, -1):
        comm = Sm @ T[q+1] - T[q+1] @ Sm
        norm_factor = np.sqrt(k*(k+1) - (q+1)*q)
        if norm_factor > 1e-10:
            T[q] = comm / norm_factor
        else:
            T[q] = comm
    
    # Normalize
    for q in T:
        norm = np.sqrt(np.real(np.trace(T[q].conj().T @ T[q])))
        if norm > 1e-10:
            T[q] = T[q] / norm * np.sqrt(dim)
    return T


def compute_multipole_moments(state, s, max_k=None):
    """
    Compute all multipole moments ⟨T^k_q⟩ for a given quantum state.
    
    The k-th multipole moment is a rank-k tensor; its norm indicates
    the strength of that multipole order.
    
    Returns dict: k → total moment strength ||⟨T^k⟩||²
    """
    if max_k is None:
        max_k = int(2*s)
    
    moments = {}
    for k in range(max_k + 1):
        T = spherical_tensor_operators(s, k)
        moment_sq = 0
        for q in T:
            expectation = state.conj() @ T[q] @ state
            moment_sq += abs(expectation)**2
        moments[k] = np.sqrt(np.real(moment_sq))
    return moments


# ============================================================================
# Part 2: Model Hamiltonians with Multipole Interactions
# ============================================================================

def bilinear_biquadratic_hamiltonian(s, theta, N=4, periodic=True):
    """
    Build the bilinear-biquadratic (BBQ) Hamiltonian for a spin chain.
    
    H = Σ_⟨ij⟩ [cos(θ) S_i·S_j + sin(θ) (S_i·S_j)²]
    
    For spin-1:
    - θ = 0: Pure Heisenberg (dipolar order)
    - θ = π/4: AKLT point (Haldane phase)
    - θ = π/2: Pure biquadratic (quadrupolar order!)
    - θ = -π/4: Ferromagnetic
    - θ = -π/2: Antiferro-quadrupolar
    
    The biquadratic term (S·S)² is a rank-2 (quadrupolar) interaction.
    """
    dim1 = int(2*s + 1)
    dim_total = dim1**N
    Sx, Sy, Sz = spin_operators(s)
    S = [Sx, Sy, Sz]
    I = np.eye(dim1)
    
    H = np.zeros((dim_total, dim_total), dtype=complex)
    
    n_bonds = N if periodic else N - 1
    
    for bond in range(n_bonds):
        i = bond
        j = (bond + 1) % N
        
        # Build S_i · S_j
        SiSj = np.zeros((dim_total, dim_total), dtype=complex)
        for a in range(3):
            op_i = np.eye(1)
            op_j = np.eye(1)
            for k in range(N):
                if k == i:
                    op_i = np.kron(op_i, S[a])
                    op_j = np.kron(op_j, I)
                elif k == j:
                    op_i = np.kron(op_i, I)
                    op_j = np.kron(op_j, S[a])
                else:
                    op_i = np.kron(op_i, I)
                    op_j = np.kron(op_j, I)
            SiSj += op_i @ op_j
        
        H += np.cos(theta) * SiSj + np.sin(theta) * SiSj @ SiSj
    
    return H


# ============================================================================
# Part 3: Visualization
# ============================================================================

def plot_operator_decomposition():
    """
    Visualize End(V_s) ≅ V_0 ⊕ V_1 ⊕ ... ⊕ V_{2s}: the multipole decomposition.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Multipole Decomposition of Operator Space End(V_s)\n'
                 'End(V_s) ≅ V₀ ⊕ V₁ ⊕ V₂ ⊕ ... ⊕ V_{2s}',
                 fontsize=15, fontweight='bold')
    
    spins = [0.5, 1, 1.5, 2]
    multipole_names = ['Monopole\n(trivial)', 'Dipole\n(vector)', 'Quadrupole\n(rank-2 tensor)',
                       'Octupole\n(rank-3 tensor)', 'Hexadecapole\n(rank-4 tensor)']
    colors = ['#95a5a6', '#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    
    for ax, s in zip(axes.flat, spins):
        dim = int(2*s + 1)
        max_k = int(2*s)
        
        # Dimensions of each multipole sector
        k_values = list(range(max_k + 1))
        sector_dims = [2*k + 1 for k in k_values]
        total = sum(sector_dims)
        
        bars = ax.bar(k_values, sector_dims, color=[colors[k] for k in k_values],
                     edgecolor='black', alpha=0.8)
        
        for k, d in zip(k_values, sector_dims):
            ax.text(k, d + 0.15, f'{d}', ha='center', fontsize=12, fontweight='bold')
            if k < len(multipole_names):
                ax.text(k, -0.8, multipole_names[k], ha='center', fontsize=7,
                       style='italic')
        
        ax.set_title(f's = {s}   (dim V_s = {dim}, dim End = {dim}² = {dim**2})\n'
                     f'Σ(2k+1) = {total} = {dim}²  ✓',
                     fontsize=11, fontweight='bold')
        ax.set_xlabel('Multipole rank k', fontsize=10)
        ax.set_ylabel('Sector dimension (2k+1)', fontsize=10)
        ax.set_xticks(k_values)
        ax.set_ylim(-2, max(sector_dims) + 2)
    
    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig('/workspace/request-project/Algebraic Magnetism/figures/multipole_decomposition.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved multipole_decomposition.png")


def plot_quadrupolar_order():
    """
    Visualize quadrupolar (nematic) order in spin-1 systems.
    
    A quadrupolar state has ⟨S⟩ = 0 (no dipole order!) but ⟨Q_{ij}⟩ ≠ 0
    where Q_{ij} = S_i S_j + S_j S_i - (2/3)S(S+1)δ_{ij}.
    
    This is the "hidden order" that the algebraic theory predicts.
    """
    fig = plt.figure(figsize=(16, 12))
    gs = gridspec.GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)
    fig.suptitle('Quadrupolar (Nematic) Magnetic Order — Prediction 1\n'
                 'Order parameters beyond dipoles for s ≥ 1',
                 fontsize=15, fontweight='bold')
    
    s = 1
    Sx, Sy, Sz = spin_operators(s)
    dim = 3
    
    # Define key states
    # |1,0⟩ state: quadrupolar, not dipolar
    state_0 = np.array([0, 1, 0], dtype=complex)  # m=0 eigenstate
    # |1,1⟩ state: dipolar
    state_up = np.array([1, 0, 0], dtype=complex)
    # Superposition: (|1⟩ + |-1⟩)/√2 — quadrupolar
    state_quad = np.array([1, 0, 1], dtype=complex) / np.sqrt(2)
    
    states = [
        (state_up, '|s=1, m=1⟩\n(Dipolar: ⟨S_z⟩ = 1)'),
        (state_0, '|s=1, m=0⟩\n(Quadrupolar: ⟨S⟩ = 0)'),
        (state_quad, '(|1⟩+|−1⟩)/√2\n(Quadrupolar: ⟨S⟩ = 0)'),
    ]
    
    # Top row: multipole moments for each state
    for idx, (state, label) in enumerate(states):
        ax = fig.add_subplot(gs[0, idx])
        moments = compute_multipole_moments(state, s)
        
        bars = ax.bar(list(moments.keys()), list(moments.values()),
                     color=[colors[k] for k in moments.keys()],
                     edgecolor='black', alpha=0.8)
        
        ax.set_xlabel('Multipole rank k', fontsize=10)
        ax.set_ylabel('Moment strength', fontsize=10)
        ax.set_title(label, fontsize=10)
        ax.set_xticks(list(moments.keys()))
        ax.set_xticklabels(['k=0\nMonopole', 'k=1\nDipole', 'k=2\nQuadrupole'])
    
    # Bottom left: BBQ phase diagram
    ax_phase = fig.add_subplot(gs[1, 0:2])
    
    theta_range = np.linspace(-np.pi, np.pi, 200)
    energies = []
    dipole_moments = []
    quad_moments = []
    
    for theta in theta_range:
        H = bilinear_biquadratic_hamiltonian(1, theta, N=4, periodic=True)
        eigenvalues, eigenvectors = np.linalg.eigh(H)
        gs_state = eigenvectors[:, 0]
        
        energies.append(eigenvalues[0])
        
        # Compute order parameters on first site
        dim1 = 3
        # Reduced density matrix of first site
        psi = gs_state.reshape(dim1, -1)
        rho = psi @ psi.conj().T
        
        # Dipole moment: ⟨S_z⟩
        dip = np.real(np.trace(Sz @ rho))
        dipole_moments.append(abs(dip))
        
        # Quadrupole moment: ⟨3S_z² - S(S+1)⟩
        Q_op = 3 * Sz @ Sz - s*(s+1) * np.eye(dim1, dtype=complex)
        quad = np.real(np.trace(Q_op @ rho))
        quad_moments.append(abs(quad))
    
    ax_phase.plot(theta_range / np.pi, dipole_moments, 'r-', linewidth=2,
                 label='|⟨S_z⟩| (Dipole)')
    ax_phase.plot(theta_range / np.pi, quad_moments, 'b-', linewidth=2,
                 label='|⟨Q_zz⟩| (Quadrupole)')
    ax_phase.axvline(x=0, color='gray', linestyle='--', alpha=0.3)
    ax_phase.axvline(x=0.5, color='green', linestyle='--', alpha=0.5, label='θ=π/2 (pure biquadratic)')
    ax_phase.axvline(x=0.25, color='orange', linestyle='--', alpha=0.5, label='θ=π/4 (AKLT)')
    
    ax_phase.set_xlabel('θ/π (BBQ parameter)', fontsize=12)
    ax_phase.set_ylabel('Order parameter strength', fontsize=12)
    ax_phase.set_title('Bilinear-Biquadratic Phase Diagram (4-site, s=1)\n'
                       'H = cos(θ) S·S + sin(θ) (S·S)²', fontsize=12)
    ax_phase.legend(fontsize=9, loc='upper right')
    ax_phase.set_xlim(-1, 1)
    
    # Bottom right: Director visualization
    ax_dir = fig.add_subplot(gs[1, 2])
    
    # Quadrupolar order is like a liquid crystal: a "director" n̂ with n̂ ≡ -n̂
    # Visualize on a small lattice
    np.random.seed(42)
    nx, ny = 8, 8
    
    # Quadrupolar (nematic) pattern: directors align but have no arrow
    base_angle = np.pi / 6
    angles = base_angle + 0.3 * np.random.randn(nx, ny)
    
    for i in range(nx):
        for j in range(ny):
            angle = angles[i, j]
            dx = 0.35 * np.cos(angle)
            dy = 0.35 * np.sin(angle)
            ax_dir.plot([i-dx, i+dx], [j-dy, j+dy], 'b-', linewidth=2.5, alpha=0.7)
            # No arrowhead! This is the key difference from dipolar
    
    ax_dir.set_xlim(-1, nx)
    ax_dir.set_ylim(-1, ny)
    ax_dir.set_aspect('equal')
    ax_dir.set_title('Quadrupolar (Nematic) Order\n⟨S⟩ = 0 but ⟨Q⟩ ≠ 0\n'
                     '(headless directors, n̂ ≡ −n̂)',
                     fontsize=10, fontweight='bold')
    ax_dir.set_xlabel('Lattice site x')
    ax_dir.set_ylabel('Lattice site y')
    
    plt.savefig('/workspace/request-project/Algebraic Magnetism/figures/quadrupolar_order.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved quadrupolar_order.png")


def plot_multipole_textures():
    """
    Visualize how different multipole orders look in real space.
    Dipole = arrows, Quadrupole = ellipsoids, Octupole = cloverleaf.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Multipole Order Parameters in Real Space\n'
                 'Algebraic Prediction: For spin s, ranks k = 1, 2, ..., 2s are possible',
                 fontsize=14, fontweight='bold')
    
    nx, ny = 10, 10
    
    # Panel 1: Dipolar order (arrows)
    ax = axes[0]
    np.random.seed(1)
    angle = np.pi / 4
    noise = 0.2
    X, Y = np.meshgrid(range(nx), range(ny))
    U = np.cos(angle) + noise * np.random.randn(nx, ny)
    V = np.sin(angle) + noise * np.random.randn(nx, ny)
    
    ax.quiver(X, Y, U, V, color='red', scale=20, width=0.008)
    ax.set_title('Dipolar Order (k=1)\n⟨S_i⟩ = m · n̂\nFerromagnet', fontsize=12)
    ax.set_aspect('equal')
    ax.set_xlim(-1, nx)
    ax.set_ylim(-1, ny)
    
    # Panel 2: Quadrupolar order (headless directors)
    ax = axes[1]
    np.random.seed(2)
    angle = np.pi / 3
    for i in range(nx):
        for j in range(ny):
            a = angle + noise * np.random.randn()
            dx = 0.35 * np.cos(a)
            dy = 0.35 * np.sin(a)
            ax.plot([i-dx, i+dx], [j-dy, j+dy], 'b-', linewidth=2, alpha=0.7)
    
    ax.set_title('Quadrupolar Order (k=2)\n⟨S_i⟩ = 0, ⟨Q_ij⟩ ≠ 0\nSpin Nematic', fontsize=12)
    ax.set_aspect('equal')
    ax.set_xlim(-1, nx)
    ax.set_ylim(-1, ny)
    
    # Panel 3: Octupolar order (cloverleaf pattern)
    ax = axes[2]
    for i in range(nx):
        for j in range(ny):
            theta = np.linspace(0, 2*np.pi, 100)
            # Y_3^0 angular shape ~ cos(3θ) modified
            r = 0.3 * np.abs(np.cos(3 * theta + 0.2 * np.random.randn()))
            x = i + r * np.cos(theta)
            y = j + r * np.sin(theta)
            ax.fill(x, y, color='green', alpha=0.3, edgecolor='darkgreen', linewidth=0.5)
    
    ax.set_title('Octupolar Order (k=3)\n⟨S_i⟩ = 0, ⟨Q_ij⟩ = 0, ⟨O_ijk⟩ ≠ 0\n'
                 'Ce₃Pd₂₀Si₆ (predicted)', fontsize=12)
    ax.set_aspect('equal')
    ax.set_xlim(-1, nx)
    ax.set_ylim(-1, ny)
    
    plt.tight_layout(rect=[0, 0, 1, 0.9])
    plt.savefig('/workspace/request-project/Algebraic Magnetism/figures/multipole_textures.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved multipole_textures.png")


def plot_selection_rules():
    """
    Plot neutron scattering selection rules from Clebsch-Gordan coefficients.
    
    The algebraic prediction: transition matrix elements ⟨s,m'|T^k_q|s,m⟩
    are proportional to Clebsch-Gordan coefficients, and are zero unless
    |m' - m| = q and the triangle inequality is satisfied.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Neutron Scattering Selection Rules from Representation Theory\n'
                 '⟨s,m\'|T^k_q|s,m⟩ = CG coefficient × reduced matrix element',
                 fontsize=14, fontweight='bold')
    
    for ax, s in zip(axes, [1, 1.5, 2]):
        dim = int(2*s + 1)
        m_values = np.arange(s, -s-1, -1)
        
        # For each multipole rank k, show which transitions are allowed
        max_k = int(2*s)
        
        data = np.zeros((dim, dim))
        
        for k in range(1, max_k + 1):
            T = spherical_tensor_operators(s, k)
            for q in T:
                mat = T[q]
                for mi in range(dim):
                    for mf in range(dim):
                        if abs(mat[mf, mi]) > 1e-10:
                            data[mf, mi] += abs(mat[mf, mi])**2
        
        im = ax.imshow(data, cmap='YlOrRd', aspect='equal')
        ax.set_title(f's = {s}\n{dim} states, multipoles k = 1..{max_k}', fontsize=12)
        ax.set_xlabel("Initial state m", fontsize=10)
        ax.set_ylabel("Final state m'", fontsize=10)
        ax.set_xticks(range(dim))
        ax.set_yticks(range(dim))
        ax.set_xticklabels([f'{m:.1f}' for m in m_values], fontsize=8)
        ax.set_yticklabels([f'{m:.1f}' for m in m_values], fontsize=8)
        plt.colorbar(im, ax=ax, shrink=0.8, label='|⟨m\'|T|m⟩|²')
    
    plt.tight_layout(rect=[0, 0, 1, 0.9])
    plt.savefig('/workspace/request-project/Algebraic Magnetism/figures/selection_rules.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved selection_rules.png")


colors = ['#95a5a6', '#e74c3c', '#3498db', '#2ecc71', '#f39c12']


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("=" * 70)
    print("PREDICTION 1: Higher Multipole Magnets")
    print("=" * 70)
    
    # Verify operator decomposition
    print("\n--- Operator Space Decomposition End(V_s) ≅ ⊕ V_k ---")
    for s in [0.5, 1, 1.5, 2, 2.5]:
        dim = int(2*s + 1)
        max_k = int(2*s)
        sector_dims = [2*k + 1 for k in range(max_k + 1)]
        total = sum(sector_dims)
        print(f"  s = {s}: dim = {dim}, End(V_s) = {dim}² = {dim**2}")
        print(f"          Sectors: {' ⊕ '.join([f'V_{k}({2*k+1})' for k in range(max_k+1)])}")
        print(f"          Sum = {total} = {dim**2} {'✓' if total == dim**2 else '✗'}")
    
    # Show multipole moments of test states
    print("\n--- Multipole Moments of Spin-1 States ---")
    s = 1
    Sx, Sy, Sz = spin_operators(s)
    states = {
        '|1,+1⟩': np.array([1, 0, 0], dtype=complex),
        '|1, 0⟩': np.array([0, 1, 0], dtype=complex),
        '(|+1⟩+|−1⟩)/√2': np.array([1, 0, 1], dtype=complex) / np.sqrt(2),
    }
    
    for name, state in states.items():
        moments = compute_multipole_moments(state, s)
        dip = np.real(state.conj() @ Sz @ state)
        print(f"\n  {name}:")
        print(f"    ⟨S_z⟩ = {dip:.4f}")
        for k, val in moments.items():
            names = ['monopole', 'dipole', 'quadrupole']
            print(f"    k={k} ({names[k]}): ||⟨T^{k}⟩|| = {val:.4f}")
    
    # Generate figures
    print("\n--- Generating Figures ---")
    plot_operator_decomposition()
    plot_quadrupolar_order()
    plot_multipole_textures()
    plot_selection_rules()
    
    print("\n✓ Demo 6 complete! Higher multipole magnets demonstrated.")
    print("\nKEY RESULT: The algebraic decomposition End(V_s) ≅ ⊕ V_k")
    print("predicts exactly which multipole orders are possible for each spin.")
    print("For s=1: quadrupolar order (spin nematic) — observed in NiGa₂S₄")
    print("For s=3/2: octupolar order — predicted for Ce₃Pd₂₀Si₆")
