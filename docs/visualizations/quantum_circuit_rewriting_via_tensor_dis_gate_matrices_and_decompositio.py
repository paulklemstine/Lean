#!/usr/bin/env python3
"""
Visualization: Quantum Gate Matrices and Their Distributive Decomposition

Shows the 2-qubit gate matrices used in the rewriting system and how
distributive normalization decomposes composite circuits into sums
of elementary gate products.

Uses matplotlib. Output: saved as PNG via plt.savefig().
"""

import numpy as np
import matplotlib.pyplot as plt


# Gate matrices
H = (1/np.sqrt(2)) * np.array([[1,1],[1,-1]], dtype=complex)
T_gate = np.array([[1,0],[0,np.exp(1j*np.pi/4)]], dtype=complex)
I2 = np.eye(2, dtype=complex)
CNOT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)


def plot_complex_matrix(ax, mat, title, cmap='coolwarm'):
    """Plot complex matrix with magnitude as color and phase as annotation."""
    mag = np.abs(mat)
    phase = np.angle(mat)
    
    im = ax.imshow(mag, cmap='Blues', vmin=0, vmax=1.5,
                   interpolation='nearest', aspect='equal')
    
    n = mat.shape[0]
    for i in range(n):
        for j in range(n):
            val = mat[i, j]
            if abs(val) < 0.01:
                text = "0"
            elif abs(val.imag) < 0.01:
                text = f"{val.real:.2f}"
            else:
                text = f"{val.real:.1f}\n{val.imag:+.1f}i"
            
            ax.text(j, i, text, ha='center', va='center', fontsize=7,
                   color='white' if mag[i,j] > 0.8 else 'black')
    
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    return im


def main():
    fig = plt.figure(figsize=(16, 14))
    fig.suptitle('Quantum Gates and Distributive Decomposition',
                 fontsize=14, fontweight='bold', y=0.98)

    # Row 1: Single qubit gates
    ax1 = fig.add_subplot(4, 4, 1)
    plot_complex_matrix(ax1, H, 'Hadamard (H)')
    
    ax2 = fig.add_subplot(4, 4, 2)
    plot_complex_matrix(ax2, T_gate, 'T gate (π/4)')
    
    ax3 = fig.add_subplot(4, 4, 3)
    plot_complex_matrix(ax3, I2, 'Identity (I)')
    
    ax4 = fig.add_subplot(4, 4, 4)
    plot_complex_matrix(ax4, H @ T_gate, 'H·T')

    # Row 2: Two-qubit gates
    ax5 = fig.add_subplot(4, 4, 5)
    plot_complex_matrix(ax5, np.kron(H, I2), 'H ⊗ I')
    
    ax6 = fig.add_subplot(4, 4, 6)
    plot_complex_matrix(ax6, np.kron(I2, H), 'I ⊗ H')
    
    ax7 = fig.add_subplot(4, 4, 7)
    plot_complex_matrix(ax7, CNOT, 'CNOT')
    
    ax8 = fig.add_subplot(4, 4, 8)
    plot_complex_matrix(ax8, np.kron(H, H), 'H ⊗ H')

    # Row 3: Distributive decomposition example
    # (H⊗I + I⊗H) ; CNOT = (H⊗I;CNOT) + (I⊗H;CNOT)
    HI = np.kron(H, I2)
    IH = np.kron(I2, H)
    
    composite = (HI + IH) @ CNOT
    term1 = HI @ CNOT
    term2 = IH @ CNOT
    
    ax9 = fig.add_subplot(4, 4, 9)
    plot_complex_matrix(ax9, composite, '(H⊗I + I⊗H);CNOT\n[original]')
    
    ax10 = fig.add_subplot(4, 4, 10)
    plot_complex_matrix(ax10, term1, 'H⊗I ; CNOT\n[summand 1]')
    
    ax11 = fig.add_subplot(4, 4, 11)
    plot_complex_matrix(ax11, term2, 'I⊗H ; CNOT\n[summand 2]')
    
    ax12 = fig.add_subplot(4, 4, 12)
    diff = composite - (term1 + term2)
    plot_complex_matrix(ax12, diff, 'Difference\n(should be 0)')

    # Row 4: More complex decomposition
    # (H⊗I + I⊗H) ; (CNOT + I⊗T) = 4 summands
    IT = np.kron(I2, T_gate)
    
    full = (HI + IH) @ (CNOT + IT)
    s1 = HI @ CNOT
    s2 = HI @ IT
    s3 = IH @ CNOT
    s4 = IH @ IT
    
    ax13 = fig.add_subplot(4, 4, 13)
    plot_complex_matrix(ax13, full, '(H⊗I+I⊗H);(CNOT+I⊗T)\n[4 summands]')
    
    ax14 = fig.add_subplot(4, 4, 14)
    plot_complex_matrix(ax14, s1, 'H⊗I;CNOT')
    
    ax15 = fig.add_subplot(4, 4, 15)
    plot_complex_matrix(ax15, s2, 'H⊗I;I⊗T')
    
    ax16 = fig.add_subplot(4, 4, 16)
    reconstructed = s1 + s2 + s3 + s4
    plot_complex_matrix(ax16, full - reconstructed, 'Σ summands − original\n(= 0: soundness!)')

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('viz_gate_matrices.png', dpi=150, bbox_inches='tight')
    print("Saved visualization to viz_gate_matrices.png")


if __name__ == '__main__':
    main()
