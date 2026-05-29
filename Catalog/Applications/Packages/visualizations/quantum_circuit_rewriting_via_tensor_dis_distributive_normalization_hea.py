#!/usr/bin/env python3
"""
Visualization: Distributive Normalization of Quantum Circuits

Visualizes how distributive rewriting transforms quantum circuit expressions
into canonical normal forms. Shows the matrix denotations before and after
normalization, demonstrating that semantics is preserved.

Uses matplotlib. Output: saved as PNG via plt.savefig().
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


# ═══════════════════════════════════════════════════════════════
# Self-contained expression types and normalization
# ═══════════════════════════════════════════════════════════════

class QExpr:
    pass

class Gate(QExpr):
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name

class Seq(QExpr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left};{self.right})"

class Par(QExpr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}⊗{self.right})"

class Add(QExpr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}+{self.right})"

def distribute_seq(a, b):
    if isinstance(a, Add):
        return Add(distribute_seq(a.left, b), distribute_seq(a.right, b))
    elif isinstance(b, Add):
        return Add(distribute_seq(a, b.left), distribute_seq(a, b.right))
    return Seq(a, b)

def distribute_par(a, b):
    if isinstance(a, Add):
        return Add(distribute_par(a.left, b), distribute_par(a.right, b))
    elif isinstance(b, Add):
        return Add(distribute_par(a, b.left), distribute_par(a, b.right))
    return Par(a, b)

def normalize(e):
    if isinstance(e, Gate): return e
    elif isinstance(e, Add): return Add(normalize(e.left), normalize(e.right))
    elif isinstance(e, Seq): return distribute_seq(normalize(e.left), normalize(e.right))
    elif isinstance(e, Par): return distribute_par(normalize(e.left), normalize(e.right))

def collect_summands(e):
    if isinstance(e, Add): return collect_summands(e.left) + collect_summands(e.right)
    return [e]

def summand_count(e):
    if isinstance(e, Gate): return 1
    elif isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    elif isinstance(e, (Seq, Par)): return summand_count(e.left) * summand_count(e.right)
    return 0

# Gate matrices
H = (1/np.sqrt(2)) * np.array([[1,1],[1,-1]], dtype=complex)
T_gate = np.array([[1,0],[0,np.exp(1j*np.pi/4)]], dtype=complex)
I2 = np.eye(2, dtype=complex)
CNOT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)

GATES = {
    'H': H, 'T': T_gate, 'I': I2, 'CNOT': CNOT,
    'H⊗I': np.kron(H, I2), 'I⊗H': np.kron(I2, H),
    'T⊗I': np.kron(T_gate, I2), 'I⊗T': np.kron(I2, T_gate),
    'H⊗H': np.kron(H, H),
}

def denote(e):
    if isinstance(e, Gate): return GATES[e.name]
    elif isinstance(e, Seq): return denote(e.left) @ denote(e.right)
    elif isinstance(e, Par): return np.kron(denote(e.left), denote(e.right))
    elif isinstance(e, Add): return denote(e.left) + denote(e.right)


# ═══════════════════════════════════════════════════════════════
# Visualization
# ═══════════════════════════════════════════════════════════════

def plot_matrix_heatmap(ax, mat, title, vmin=-2, vmax=2):
    """Plot a complex matrix as a heatmap (real part)."""
    im = ax.imshow(mat.real, cmap='RdBu_r', vmin=vmin, vmax=vmax,
                   interpolation='nearest', aspect='equal')
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.set_xticks(range(mat.shape[1]))
    ax.set_yticks(range(mat.shape[0]))
    for i in range(mat.shape[0]):
        for j in range(mat.shape[1]):
            val = mat[i, j]
            text = f"{val.real:.2f}"
            if abs(val.imag) > 0.01:
                text += f"\n{val.imag:+.2f}i"
            ax.text(j, i, text, ha='center', va='center', fontsize=6,
                   color='white' if abs(val.real) > 1 else 'black')
    return im


def main():
    fig = plt.figure(figsize=(16, 12))
    fig.suptitle('Quantum Circuit Rewriting: Distributive Normalization',
                 fontsize=14, fontweight='bold', y=0.98)

    # Define example circuits
    circuits = [
        ("H⊗I ; (CNOT + I⊗H)",
         Seq(Gate('H⊗I'), Add(Gate('CNOT'), Gate('I⊗H')))),
        ("(H⊗I + I⊗H) ; CNOT",
         Seq(Add(Gate('H⊗I'), Gate('I⊗H')), Gate('CNOT'))),
        ("(H⊗I + I⊗H) ; (CNOT + I⊗T)",
         Seq(Add(Gate('H⊗I'), Gate('I⊗H')), Add(Gate('CNOT'), Gate('I⊗T')))),
    ]

    gs = gridspec.GridSpec(3, 4, hspace=0.5, wspace=0.4,
                           left=0.05, right=0.95, top=0.92, bottom=0.05)

    for row, (name, circuit) in enumerate(circuits):
        nf = normalize(circuit)
        summands = collect_summands(nf)
        
        original_mat = denote(circuit)
        normal_mat = denote(nf)
        
        # Original matrix
        ax0 = fig.add_subplot(gs[row, 0])
        plot_matrix_heatmap(ax0, original_mat, f"Original\n{name}")
        
        # Normalized matrix
        ax1 = fig.add_subplot(gs[row, 1])
        plot_matrix_heatmap(ax1, normal_mat, f"Normalized\n(= sum of {len(summands)} terms)")
        
        # Difference (should be zero)
        ax2 = fig.add_subplot(gs[row, 2])
        diff = original_mat - normal_mat
        plot_matrix_heatmap(ax2, diff, f"Difference\n(max |Δ| = {np.max(np.abs(diff)):.1e})",
                          vmin=-0.1, vmax=0.1)
        
        # Summand count visualization
        ax3 = fig.add_subplot(gs[row, 3])
        summand_norms = [np.linalg.norm(denote(s), 'fro') for s in summands]
        bars = ax3.bar(range(len(summands)), summand_norms,
                      color=['#2196F3', '#4CAF50', '#FF9800', '#E91E63'][:len(summands)])
        ax3.set_title(f"Summand Frobenius norms\n({len(summands)} paths)", fontsize=10, fontweight='bold')
        ax3.set_xlabel('Summand index')
        ax3.set_ylabel('‖·‖_F')
        ax3.set_xticks(range(len(summands)))

    plt.savefig('viz_normalization.png', dpi=150, bbox_inches='tight')
    print("Saved visualization to viz_normalization.png")


if __name__ == '__main__':
    main()
