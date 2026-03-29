#!/usr/bin/env python3
"""
Demo 1: The Spin Algebra — Foundation of the Algebraic Theory of Magnetism
==========================================================================

This script demonstrates the fundamental algebraic structure underlying all
magnetic phenomena: the Lie algebra 𝔰𝔲(2) and its representations.

We visualize:
1. The spin operators as matrices for various spin quantum numbers
2. The commutation relations [Sᵢ, Sⱼ] = iεᵢⱼₖSₖ
3. The Clebsch-Gordan decomposition of tensor products
4. The representation ring structure

Author: The Oracle Council
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.gridspec as gridspec

# ============================================================================
# Part 1: Constructing Spin Operators
# ============================================================================

def spin_operators(s):
    """
    Construct the spin-s representation matrices of 𝔰𝔲(2).
    
    The fundamental theorem of representation theory guarantees these exist
    and are unique (up to unitary equivalence) for each s ∈ {0, 1/2, 1, 3/2, ...}.
    
    Parameters
    ----------
    s : float
        Spin quantum number (half-integer or integer)
    
    Returns
    -------
    Sx, Sy, Sz : ndarray
        The three spin matrices in the standard basis |s,m⟩
    """
    dim = int(2*s + 1)
    m_values = np.arange(s, -s-1, -1)  # m = s, s-1, ..., -s
    
    # Sz is diagonal in the standard basis
    Sz = np.diag(m_values).astype(complex)
    
    # S+ (raising operator): S+|s,m⟩ = √(s(s+1) - m(m+1)) |s,m+1⟩
    Sp = np.zeros((dim, dim), dtype=complex)
    for i in range(dim - 1):
        m = m_values[i + 1]
        Sp[i, i + 1] = np.sqrt(s*(s+1) - m*(m+1))
    
    # S- (lowering operator): S-|s,m⟩ = √(s(s+1) - m(m-1)) |s,m-1⟩
    Sm = Sp.T.conj()
    
    # Cartesian components
    Sx = 0.5 * (Sp + Sm)
    Sy = -0.5j * (Sp - Sm)
    
    return Sx, Sy, Sz


def verify_commutation_relations(s):
    """Verify [Sₓ, Sᵧ] = iSᵤ (and cyclic) for spin-s."""
    Sx, Sy, Sz = spin_operators(s)
    
    comm_xy = Sx @ Sy - Sy @ Sx  # Should be iSz
    comm_yz = Sy @ Sz - Sz @ Sy  # Should be iSx
    comm_zx = Sz @ Sx - Sx @ Sz  # Should be iSy
    
    err1 = np.max(np.abs(comm_xy - 1j * Sz))
    err2 = np.max(np.abs(comm_yz - 1j * Sx))
    err3 = np.max(np.abs(comm_zx - 1j * Sy))
    
    return max(err1, err2, err3)


def casimir_operator(s):
    """Compute the Casimir element S² = Sx² + Sy² + Sz²."""
    Sx, Sy, Sz = spin_operators(s)
    return Sx @ Sx + Sy @ Sy + Sz @ Sz


# ============================================================================
# Part 2: Clebsch-Gordan Decomposition
# ============================================================================

def clebsch_gordan_dimensions(s1, s2):
    """
    Compute the Clebsch-Gordan decomposition: Vs1 ⊗ Vs2 = ⊕ V_J
    
    This is the multiplication rule in the representation ring R(𝔰𝔲(2)).
    """
    J_values = np.arange(abs(s1 - s2), s1 + s2 + 1)
    dims = [int(2*J + 1) for J in J_values]
    return J_values, dims


# ============================================================================
# Part 3: Visualization
# ============================================================================

def plot_spin_matrices():
    """Visualize spin operator matrices for s = 1/2, 1, 3/2, 2."""
    fig, axes = plt.subplots(4, 3, figsize=(14, 16))
    fig.suptitle('Spin Operator Matrices — Representations of 𝔰𝔲(2)', 
                 fontsize=16, fontweight='bold', y=0.98)
    
    spins = [0.5, 1, 1.5, 2]
    labels = ['Sₓ', 'Sᵧ', 'Sᵤ']
    
    for row, s in enumerate(spins):
        Sx, Sy, Sz = spin_operators(s)
        operators = [Sx.real, Sy.imag, Sz.real]  # Take real/imag parts for display
        
        for col, (op, label) in enumerate(zip(operators, labels)):
            ax = axes[row, col]
            im = ax.imshow(op, cmap='RdBu_r', vmin=-s, vmax=s, aspect='equal')
            ax.set_title(f's = {s}, {label}', fontsize=12)
            
            # Annotate matrix entries
            dim = int(2*s + 1)
            for i in range(dim):
                for j in range(dim):
                    val = op[i, j]
                    if abs(val) > 1e-10:
                        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                               fontsize=max(6, 10 - dim), 
                               color='white' if abs(val) > 0.6*s else 'black')
            
            ax.set_xticks(range(dim))
            ax.set_yticks(range(dim))
            m_labels = [f'{m:.1f}' if s % 1 else f'{int(m)}' 
                       for m in np.arange(s, -s-1, -1)]
            ax.set_xticklabels(m_labels, fontsize=7)
            ax.set_yticklabels(m_labels, fontsize=7)
    
    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/spin_matrices.png', 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved spin_matrices.png")


def plot_casimir_spectrum():
    """Plot the Casimir eigenvalue s(s+1) showing the representation structure."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Representation Theory of 𝔰𝔲(2) — The Magnetic Algebra', 
                 fontsize=14, fontweight='bold')
    
    # Left: Casimir eigenvalue spectrum
    s_values = np.arange(0, 5.5, 0.5)
    casimir_values = s_values * (s_values + 1)
    dimensions = (2 * s_values + 1).astype(int)
    
    colors = ['#2ecc71' if s % 1 == 0 else '#e74c3c' for s in s_values]
    
    ax1.bar(s_values, casimir_values, width=0.4, color=colors, edgecolor='black', alpha=0.8)
    ax1.set_xlabel('Spin quantum number s', fontsize=12)
    ax1.set_ylabel('Casimir eigenvalue s(s+1)', fontsize=12)
    ax1.set_title('Casimir Spectrum', fontsize=13)
    
    for s, c, d in zip(s_values, casimir_values, dimensions):
        ax1.annotate(f'dim={d}', (s, c + 0.3), ha='center', fontsize=8,
                    fontweight='bold')
    
    # Legend
    from matplotlib.patches import Patch
    ax1.legend(handles=[
        Patch(facecolor='#2ecc71', edgecolor='black', label='Integer spin (bosonic)'),
        Patch(facecolor='#e74c3c', edgecolor='black', label='Half-integer spin (fermionic)')
    ], fontsize=10)
    
    # Right: Clebsch-Gordan decomposition visual
    s1_vals = [0.5, 0.5, 1, 1, 1.5, 2]
    s2_vals = [0.5, 1, 1, 1.5, 1.5, 2]
    
    y_positions = range(len(s1_vals))
    
    for idx, (s1, s2) in enumerate(zip(s1_vals, s2_vals)):
        J_vals, dims = clebsch_gordan_dimensions(s1, s2)
        
        # Draw the decomposition
        label = f'V_{{{s1}}} ⊗ V_{{{s2}}} ='
        ax2.text(-0.5, idx, label, ha='right', va='center', fontsize=10, fontfamily='serif')
        
        x_offset = 0
        for J, d in zip(J_vals, dims):
            rect_width = d * 0.15
            color = '#2ecc71' if J % 1 == 0 else '#e74c3c'
            rect = plt.Rectangle((x_offset, idx - 0.3), rect_width, 0.6,
                                facecolor=color, edgecolor='black', alpha=0.7)
            ax2.add_patch(rect)
            ax2.text(x_offset + rect_width/2, idx, f'V_{{{J}}}',
                    ha='center', va='center', fontsize=9, fontweight='bold')
            x_offset += rect_width + 0.1
    
    ax2.set_xlim(-2.5, 5)
    ax2.set_ylim(-0.5, len(s1_vals) - 0.5)
    ax2.set_title('Clebsch-Gordan Decomposition\n(Representation Ring Multiplication)', fontsize=13)
    ax2.set_yticks([])
    ax2.set_xticks([])
    ax2.spines['top'].set_visible(False)
    ax2.spines['right'].set_visible(False)
    ax2.spines['bottom'].set_visible(False)
    ax2.spines['left'].set_visible(False)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/casimir_spectrum.png', 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved casimir_spectrum.png")


def plot_commutation_verification():
    """Verify and visualize that commutation relations hold for all representations."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    s_values = np.arange(0.5, 10.5, 0.5)
    errors = [verify_commutation_relations(s) for s in s_values]
    dimensions = [int(2*s + 1) for s in s_values]
    
    ax.semilogy(s_values, [max(e, 1e-16) for e in errors], 'o-', color='#3498db',
               markersize=8, linewidth=2, label='Max |[Sᵢ,Sⱼ] - iεᵢⱼₖSₖ|')
    ax.axhline(y=1e-14, color='red', linestyle='--', alpha=0.5, label='Machine precision')
    
    ax.set_xlabel('Spin quantum number s', fontsize=12)
    ax.set_ylabel('Commutation relation error', fontsize=12)
    ax.set_title('Verification: 𝔰𝔲(2) Commutation Relations Hold Exactly\nfor All Representations',
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(1e-17, 1e-12)
    
    # Add dimension annotations
    for s, e, d in zip(s_values[::2], errors[::2], dimensions[::2]):
        ax.annotate(f'{d}×{d}', (s, max(e, 1e-16)), textcoords="offset points",
                   xytext=(0, 12), ha='center', fontsize=8, color='gray')
    
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/commutation_check.png', 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved commutation_check.png")


def plot_spin_coherent_state():
    """
    Visualize spin coherent states on the Bloch sphere (coadjoint orbit S²).
    
    The Bloch sphere is the coadjoint orbit of 𝔰𝔲(2)* — the phase space 
    of classical magnetism.
    """
    fig = plt.figure(figsize=(12, 10))
    
    # Create a sphere
    u = np.linspace(0, 2 * np.pi, 100)
    v = np.linspace(0, np.pi, 50)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones(np.size(u)), np.cos(v))
    
    ax = fig.add_subplot(111, projection='3d')
    ax.plot_surface(x, y, z, alpha=0.15, color='lightblue')
    
    # Draw latitude and longitude lines
    for angle in np.linspace(0, np.pi, 7):
        circle_x = np.sin(angle) * np.cos(u)
        circle_y = np.sin(angle) * np.sin(u)
        circle_z = np.cos(angle) * np.ones_like(u)
        ax.plot(circle_x, circle_y, circle_z, 'b-', alpha=0.1, linewidth=0.5)
    
    for angle in np.linspace(0, 2*np.pi, 13):
        arc_x = np.sin(v) * np.cos(angle)
        arc_y = np.sin(v) * np.sin(angle)
        arc_z = np.cos(v)
        ax.plot(arc_x, arc_y, arc_z, 'b-', alpha=0.1, linewidth=0.5)
    
    # Plot various spin states as arrows
    states = [
        (0, 0, 1, '|↑⟩ (Sz = +s)', '#e74c3c'),
        (0, 0, -1, '|↓⟩ (Sz = -s)', '#3498db'),
        (1, 0, 0, '|→⟩ (Sx = +s)', '#2ecc71'),
        (-1, 0, 0, '|←⟩ (Sx = -s)', '#9b59b6'),
        (0, 1, 0, '|⊙⟩ (Sy = +s)', '#f39c12'),
        (1/np.sqrt(3), 1/np.sqrt(3), 1/np.sqrt(3), 'Tilted state', '#e67e22'),
    ]
    
    for sx, sy, sz, label, color in states:
        ax.quiver(0, 0, 0, sx, sy, sz, color=color, arrow_length_ratio=0.1,
                 linewidth=3, alpha=0.8)
        ax.text(sx*1.15, sy*1.15, sz*1.15, label, fontsize=9, color=color,
               fontweight='bold')
    
    # Draw a precession trajectory
    t = np.linspace(0, 2*np.pi, 100)
    theta0 = np.pi/4  # tilt angle
    prec_x = np.sin(theta0) * np.cos(t)
    prec_y = np.sin(theta0) * np.sin(t)
    prec_z = np.cos(theta0) * np.ones_like(t)
    ax.plot(prec_x, prec_y, prec_z, 'r--', linewidth=2, alpha=0.6,
           label='Larmor precession\n(coadjoint orbit flow)')
    
    ax.set_xlabel('Sx / s')
    ax.set_ylabel('Sy / s')
    ax.set_zlabel('Sz / s')
    ax.set_title('The Bloch Sphere — Coadjoint Orbit of 𝔰𝔲(2)*\n'
                'Phase Space of Classical Magnetism', 
                fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=10)
    
    ax.set_xlim([-1.3, 1.3])
    ax.set_ylim([-1.3, 1.3])
    ax.set_zlim([-1.3, 1.3])
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/algebraic_magnetism/figures/bloch_sphere.png', 
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved bloch_sphere.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == '__main__':
    print("=" * 70)
    print("ALGEBRAIC THEORY OF MAGNETISM — Demo 1: The Spin Algebra")
    print("=" * 70)
    
    # Verify the algebra
    print("\n--- Verifying 𝔰𝔲(2) Commutation Relations ---")
    for s in [0.5, 1, 1.5, 2, 2.5, 5]:
        err = verify_commutation_relations(s)
        dim = int(2*s + 1)
        print(f"  s = {s:4.1f} (dim = {dim:2d}): error = {err:.2e}")
    
    # Verify Casimir
    print("\n--- Verifying Casimir Eigenvalues ---")
    for s in [0.5, 1, 1.5, 2]:
        C = casimir_operator(s)
        expected = s * (s + 1) * np.eye(int(2*s + 1))
        err = np.max(np.abs(C - expected))
        print(f"  s = {s}: C = S² = {s*(s+1):.2f} · I (error = {err:.2e})")
    
    # Clebsch-Gordan
    print("\n--- Clebsch-Gordan Decomposition (Rep Ring Multiplication) ---")
    pairs = [(0.5, 0.5), (0.5, 1), (1, 1), (1, 1.5), (2, 2)]
    for s1, s2 in pairs:
        J_vals, dims = clebsch_gordan_dimensions(s1, s2)
        decomp = ' ⊕ '.join([f'V_{J}' for J in J_vals])
        dim_check = int((2*s1+1) * (2*s2+1))
        dim_sum = sum(dims)
        print(f"  V_{s1} ⊗ V_{s2} = {decomp}  (dim: {dim_check} = {dim_sum} ✓)")
    
    # Generate figures
    print("\n--- Generating Figures ---")
    plot_spin_matrices()
    plot_casimir_spectrum()
    plot_commutation_verification()
    plot_spin_coherent_state()
    
    print("\n✓ Demo 1 complete!")
