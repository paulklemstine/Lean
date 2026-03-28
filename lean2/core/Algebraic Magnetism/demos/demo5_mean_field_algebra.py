#!/usr/bin/env python3
"""
Demo 5: Algebraic Mean Field Theory and Phase Transitions
==========================================================

This script demonstrates:
1. Mean field theory derived from algebraic projection
2. The Curie-Weiss law from 𝔰𝔲(2) representation theory
3. Phase transitions as representation changes
4. Exact diagonalization of small clusters for validation

Author: The Oracle Council
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import brentq
from demo1_spin_algebra import spin_operators

# ============================================================================
# Part 1: Algebraic Mean Field Theory
# ============================================================================

def brillouin_function(x, J):
    """
    Brillouin function B_J(x) — the algebraic mean field equation.
    
    This arises from the character of the spin-J representation of 𝔰𝔲(2):
        B_J(x) = [(2J+1)/(2J)] coth[(2J+1)x/(2J)] - [1/(2J)] coth[x/(2J)]
    
    The self-consistency equation m = B_J(βJzm) determines the magnetization.
    """
    if np.isscalar(x):
        if abs(x) < 1e-10:
            return (J + 1) * x / (3 * J) if J > 0 else 0
    
    a = (2*J + 1) / (2*J)
    b = 1 / (2*J)
    
    # Avoid overflow
    x = np.clip(x, -500, 500)
    
    term1 = a / np.tanh(a * x + 1e-30)
    term2 = b / np.tanh(b * x + 1e-30)
    
    return term1 - term2


def solve_mean_field(T, J_exchange=1.0, spin=0.5, z=6, h_ext=0.0):
    """
    Solve the mean field self-consistency equation.
    
    m = B_s(β(z·J·m + h))
    
    This is the algebraic mean field: projecting 𝔐_Λ → 𝔰𝔲(2)_eff.
    """
    if T < 1e-10:
        return 1.0
    
    beta = 1.0 / T
    
    def equation(m):
        x = beta * (z * J_exchange * m + h_ext)
        return m - brillouin_function(x, spin)
    
    # Try to find non-trivial solution
    try:
        m_solution = brentq(equation, 0.001, spin, xtol=1e-12)
        if m_solution > 1e-6:
            return m_solution
    except (ValueError, RuntimeError):
        pass
    
    return 0.0


def curie_weiss_temperature(J_exchange=1.0, spin=0.5, z=6):
    """
    Curie-Weiss temperature from algebraic mean field.
    
    Tc = z·J·s(s+1) / 3
    
    This follows from the Casimir eigenvalue s(s+1) of the 𝔰𝔲(2) representation.
    """
    return z * J_exchange * spin * (spin + 1) / 3


def susceptibility_curie_weiss(T, J_exchange=1.0, spin=0.5, z=6):
    """
    Curie-Weiss susceptibility: χ = C / (T - Tc)
    
    C = s(s+1)/3 is the Curie constant (from Casimir).
    """
    Tc = curie_weiss_temperature(J_exchange, spin, z)
    C = spin * (spin + 1) / 3
    
    denom = T - Tc
    if isinstance(denom, np.ndarray):
        result = np.where(np.abs(denom) > 0.01, C / denom, np.sign(denom) * C / 0.01)
    else:
        if abs(denom) < 0.01:
            return np.sign(denom) * C / 0.01
        result = C / denom
    
    return result


# ============================================================================
# Part 2: Exact Diagonalization for Validation
# ============================================================================

def exact_diag_chain(N, s, J, T_values, periodic=True):
    """
    Exact diagonalization of a spin chain for comparison with mean field.
    """
    dim1 = int(2*s + 1)
    dim_total = dim1**N
    
    Sx, Sy, Sz = spin_operators(s)
    S_ops = [Sx, Sy, Sz]
    I = np.eye(dim1)
    
    # Build Hamiltonian
    H = np.zeros((dim_total, dim_total), dtype=complex)
    
    n_bonds = N if periodic else N - 1
    for i in range(n_bonds):
        j = (i + 1) % N
        for alpha in range(3):
            # Build Sᵢ^α
            op_i = np.eye(1)
            op_j = np.eye(1)
            for k in range(N):
                if k == i:
                    op_i = np.kron(op_i, S_ops[alpha])
                else:
                    op_i = np.kron(op_i, I)
                if k == j:
                    op_j = np.kron(op_j, S_ops[alpha])
                else:
                    op_j = np.kron(op_j, I)
            H -= J * op_i @ op_j
    
    # Build total Sz operator
    Sz_total = np.zeros((dim_total, dim_total), dtype=complex)
    for i in range(N):
        op = np.eye(1)
        for k in range(N):
            if k == i:
                op = np.kron(op, Sz)
            else:
                op = np.kron(op, I)
        Sz_total += op
    
    # Diagonalize
    eigenvalues, eigenvectors = np.linalg.eigh(H.real)
    
    # Compute thermal averages
    magnetizations = []
    for T in T_values:
        if T < 1e-10:
            # Ground state
            gs = eigenvectors[:, 0]
            m = abs(np.real(gs.conj() @ Sz_total @ gs)) / N
        else:
            beta = 1.0 / T
            weights = np.exp(-beta * (eigenvalues - eigenvalues[0]))
            Z = np.sum(weights)
            
            # <|Sz_total|> / N
            Sz_diag = np.real(np.diag(eigenvectors.T.conj() @ Sz_total @ eigenvectors))
            m = np.sum(np.abs(Sz_diag) * weights) / (Z * N)
        
        magnetizations.append(m)
    
    return np.array(magnetizations)


# ============================================================================
# Part 3: Visualization
# ============================================================================

def plot_mean_field_phase_transition():
    """Visualize the ferromagnetic phase transition from algebraic mean field."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Algebraic Mean Field Theory — Phase Transitions\n'
                'Projection: 𝔐_Λ → 𝔰𝔲(2)_eff via mean field map',
                fontsize=14, fontweight='bold')
    
    # --- Magnetization vs Temperature for different spins ---
    ax = axes[0, 0]
    spin_values = [0.5, 1, 1.5, 2, 5]
    T_range = np.linspace(0.01, 3, 300)
    
    for s in spin_values:
        Tc = curie_weiss_temperature(spin=s)
        M = [solve_mean_field(T, spin=s) for T in T_range]
        ax.plot(T_range / Tc, np.array(M) / s, linewidth=2, label=f's = {s}')
    
    ax.set_xlabel('T / Tc', fontsize=12)
    ax.set_ylabel('M(T) / s', fontsize=12)
    ax.set_title('Magnetization vs Temperature\n(Universal scaling near Tc)', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.axvline(x=1, color='gray', linestyle='--', alpha=0.5)
    ax.text(1.02, 0.8, 'Tc', fontsize=12, color='gray')
    
    # --- Self-consistency equation ---
    ax = axes[0, 1]
    T_values = [0.3, 0.6, 1.0, 1.5, 2.0]
    m_range = np.linspace(0, 0.5, 200)
    s = 0.5
    z = 6
    J = 1.0
    Tc = curie_weiss_temperature(J_exchange=J, spin=s, z=z)
    
    ax.plot(m_range, m_range, 'k-', linewidth=2, label='y = m')
    
    colors = plt.cm.coolwarm(np.linspace(0, 1, len(T_values)))
    for T, color in zip(T_values, colors):
        T_actual = T * Tc
        rhs = [brillouin_function(m * z * J / T_actual, s) if T_actual > 0 else s for m in m_range]
        ax.plot(m_range, rhs, color=color, linewidth=2, 
               label=f'T/Tc = {T:.1f}')
    
    ax.set_xlabel('m (magnetization)', fontsize=12)
    ax.set_ylabel('B_s(βzJm)', fontsize=12)
    ax.set_title('Self-Consistency Equation\nm = B_s(βzJm)', fontsize=11)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 0.5)
    ax.set_ylim(0, 0.5)
    
    # --- Susceptibility (Curie-Weiss law) ---
    ax = axes[1, 0]
    T_range = np.linspace(0.5, 5, 300)
    
    for s in [0.5, 1, 2]:
        Tc = curie_weiss_temperature(spin=s)
        chi = susceptibility_curie_weiss(T_range, spin=s)
        chi_clipped = np.clip(chi, -5, 5)
        ax.plot(T_range, chi_clipped, linewidth=2, label=f's = {s}, Tc = {Tc:.2f}')
        ax.axvline(x=Tc, color='gray', linestyle=':', alpha=0.3)
    
    ax.set_xlabel('Temperature T', fontsize=12)
    ax.set_ylabel('Susceptibility χ', fontsize=12)
    ax.set_title('Curie-Weiss Law: χ = C/(T-Tc)\nC = s(s+1)/3 (Casimir eigenvalue)', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-1, 5)
    
    # --- Curie temperature vs spin ---
    ax = axes[1, 1]
    s_range = np.arange(0.5, 10.5, 0.5)
    Tc_values = [curie_weiss_temperature(spin=s) for s in s_range]
    casimir_values = s_range * (s_range + 1)
    
    ax.plot(s_range, Tc_values, 'bo-', linewidth=2, markersize=6, label='Tc = zJs(s+1)/3')
    ax.plot(s_range, casimir_values, 'r--', linewidth=2, alpha=0.5, 
           label='s(s+1) (Casimir)')
    
    ax.set_xlabel('Spin quantum number s', fontsize=12)
    ax.set_ylabel('Tc / J (z=6)', fontsize=12)
    ax.set_title('Curie Temperature from Casimir Eigenvalue\nTc ∝ s(s+1) — pure algebra!', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/mean_field_transition.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved mean_field_transition.png")


def plot_exact_vs_mean_field():
    """Compare exact diagonalization with algebraic mean field."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Validation: Exact Diagonalization vs Algebraic Mean Field',
                fontsize=14, fontweight='bold')
    
    # Small chains
    T_range = np.linspace(0.01, 5, 50)
    s = 0.5
    J = 1.0
    
    # Mean field (z=2 for chain)
    M_mf = [solve_mean_field(T, J_exchange=J, spin=s, z=2) for T in T_range]
    ax1.plot(T_range, M_mf, 'k--', linewidth=2, label='Mean field (z=2)')
    
    # Exact diag for small chains
    for N, color in [(4, '#e74c3c'), (6, '#3498db'), (8, '#2ecc71')]:
        try:
            M_exact = exact_diag_chain(N, s, J, T_range, periodic=True)
            ax1.plot(T_range, M_exact, '-', color=color, linewidth=2,
                    label=f'Exact (N={N})')
        except Exception as e:
            print(f"  Skipping N={N}: {e}")
    
    ax1.set_xlabel('Temperature T / J', fontsize=12)
    ax1.set_ylabel('⟨|M|⟩ / N', fontsize=12)
    ax1.set_title('Magnetization: Exact vs Mean Field\n(1D Heisenberg chain, s=1/2)', fontsize=11)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Energy levels of small clusters
    ax2_data = []
    for N in [2, 3, 4]:
        dim1 = int(2*s + 1)
        dim_total = dim1**N
        
        Sx, Sy, Sz = spin_operators(s)
        S_ops = [Sx, Sy, Sz]
        I_mat = np.eye(dim1)
        
        H = np.zeros((dim_total, dim_total), dtype=complex)
        for i in range(N):
            j = (i + 1) % N
            for alpha in range(3):
                op_i = np.eye(1)
                op_j = np.eye(1)
                for k in range(N):
                    if k == i:
                        op_i = np.kron(op_i, S_ops[alpha])
                    else:
                        op_i = np.kron(op_i, I_mat)
                    if k == j:
                        op_j = np.kron(op_j, S_ops[alpha])
                    else:
                        op_j = np.kron(op_j, I_mat)
                H -= J * op_i @ op_j
        
        eigenvalues = np.sort(np.linalg.eigvalsh(H.real))
        ax2_data.append((N, eigenvalues))
    
    for idx, (N, evals) in enumerate(ax2_data):
        # Group by degeneracy
        unique = []
        degs = []
        for E in evals:
            found = False
            for i, uE in enumerate(unique):
                if abs(E - uE) < 1e-10:
                    degs[i] += 1
                    found = True
                    break
            if not found:
                unique.append(E)
                degs.append(1)
        
        x_base = idx * 2.5
        for E, deg in zip(unique, degs):
            w = 0.15 * deg
            ax2.plot([x_base - w, x_base + w], [E, E], 'b-', linewidth=2)
            ax2.text(x_base + w + 0.1, E, f'{deg}', fontsize=8, va='center', color='red')
        
        ax2.text(x_base, min(evals) - 0.5, f'N={N}', fontsize=12, ha='center',
                fontweight='bold')
    
    ax2.set_ylabel('Energy / J', fontsize=12)
    ax2.set_title('Energy Spectra of Small Clusters\n(Degeneracies from 𝔰𝔲(2) representation theory)', 
                 fontsize=11)
    ax2.set_xticks([])
    ax2.grid(True, axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/exact_vs_mean_field.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved exact_vs_mean_field.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("=" * 70)
    print("ALGEBRAIC THEORY OF MAGNETISM — Demo 5: Mean Field & Phase Transitions")
    print("=" * 70)
    
    # Curie-Weiss temperatures
    print("\n--- Curie-Weiss Temperatures (Algebraic Prediction) ---")
    for s in [0.5, 1, 1.5, 2, 2.5, 5]:
        Tc = curie_weiss_temperature(spin=s)
        casimir = s * (s + 1)
        print(f"  s = {s:4.1f}: Tc/J = {Tc:.3f}  (Casimir = {casimir:.2f})")
    
    # Brillouin function values
    print("\n--- Brillouin Function (Character of Representation) ---")
    for s in [0.5, 1, 2]:
        print(f"  s = {s}: B_s(0) = {brillouin_function(0, s):.4f}, "
              f"B_s(1) = {brillouin_function(1, s):.4f}, "
              f"B_s(∞) → {s:.4f}")
    
    # Generate figures
    print("\n--- Generating Figures ---")
    plot_mean_field_phase_transition()
    plot_exact_vs_mean_field()
    
    print("\n✓ Demo 5 complete!")
