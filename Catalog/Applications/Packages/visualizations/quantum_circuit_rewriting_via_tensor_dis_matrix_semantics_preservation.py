"""
Visualization: Distributive Normalization as Matrix Preservation

This script visualizes how the normalization process transforms quantum
circuit expressions while preserving their matrix semantics. It shows
the before/after matrices as heatmaps, demonstrating soundness visually.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from enum import Enum


# --- Inlined core types ---
class QGate(Enum):
    H = "H"; T = "T"; CNOT = "CNOT"

class QTE: pass

@dataclass(frozen=True)
class Gate(QTE):
    gate: QGate
    def __repr__(self): return self.gate.value

@dataclass(frozen=True)
class Ident(QTE):
    def __repr__(self): return "I"

@dataclass(frozen=True)
class Seq(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ; {self.right})"

@dataclass(frozen=True)
class Par(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ⊗ {self.right})"

@dataclass(frozen=True)
class Add(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} + {self.right})"


def norm_step(e):
    if isinstance(e, Par) and isinstance(e.left, Add):
        return Add(Par(e.left.left, e.right), Par(e.left.right, e.right))
    if isinstance(e, Par) and isinstance(e.right, Add):
        return Add(Par(e.left, e.right.left), Par(e.left, e.right.right))
    if isinstance(e, Seq) and isinstance(e.right, Add):
        return Add(Seq(e.left, e.right.left), Seq(e.left, e.right.right))
    return e

def norm_step_deep(e):
    if isinstance(e, (Gate, Ident)): return e
    if isinstance(e, Seq): return norm_step(Seq(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Par): return norm_step(Par(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Add): return Add(norm_step_deep(e.left), norm_step_deep(e.right))

def poly_interp(e):
    if isinstance(e, (Gate, Ident)): return 2
    if isinstance(e, (Seq, Par)): return poly_interp(e.left) * poly_interp(e.right)
    if isinstance(e, Add): return poly_interp(e.left) + poly_interp(e.right) + 1

def normalize(e):
    for _ in range(poly_interp(e)):
        e_new = norm_step_deep(e)
        if e_new == e: return e
        e = e_new
    return e

H_MAT = np.array([[1,1],[1,-1]], dtype=complex) / np.sqrt(2)
T_MAT = np.array([[1,0],[0,np.exp(1j*np.pi/4)]], dtype=complex)
I_MAT = np.eye(2, dtype=complex)
CNOT_MAT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)
GATE_MATS = {QGate.H: H_MAT, QGate.T: T_MAT, QGate.CNOT: CNOT_MAT}

def denote_matrix(e):
    if isinstance(e, Gate): return GATE_MATS[e.gate].copy()
    if isinstance(e, Ident): return I_MAT.copy()
    if isinstance(e, Seq): return denote_matrix(e.left) @ denote_matrix(e.right)
    if isinstance(e, Par): return np.kron(denote_matrix(e.left), denote_matrix(e.right))
    if isinstance(e, Add): return denote_matrix(e.left) + denote_matrix(e.right)


# --- Build examples ---
H = Gate(QGate.H)
T = Gate(QGate.T)
I = Ident()

examples = [
    ("(H+T) ⊗ (H+T)", Par(Add(H, T), Add(H, T))),
    ("H ⊗ (T+H)", Par(H, Add(T, H))),
    ("(H+T) ⊗ I", Par(Add(H, T), I)),
]

fig, axes = plt.subplots(len(examples), 4, figsize=(16, 4 * len(examples)))

for row, (name, expr) in enumerate(examples):
    nf = normalize(expr)
    m_orig = denote_matrix(expr)
    m_norm = denote_matrix(nf)
    diff = np.abs(m_orig - m_norm)
    
    # Original matrix (magnitude)
    ax = axes[row, 0]
    im = ax.imshow(np.abs(m_orig), cmap='viridis', aspect='equal')
    ax.set_title(f'|Original|\n{name}', fontsize=10)
    plt.colorbar(im, ax=ax, fraction=0.046)
    
    # Original matrix (phase)
    ax = axes[row, 1]
    im = ax.imshow(np.angle(m_orig), cmap='twilight', aspect='equal', 
                    vmin=-np.pi, vmax=np.pi)
    ax.set_title(f'Phase(Original)', fontsize=10)
    plt.colorbar(im, ax=ax, fraction=0.046)
    
    # Normalized matrix (magnitude)
    ax = axes[row, 2]
    im = ax.imshow(np.abs(m_norm), cmap='viridis', aspect='equal')
    ax.set_title(f'|Normal Form|\n{str(nf)[:40]}...', fontsize=10)
    plt.colorbar(im, ax=ax, fraction=0.046)
    
    # Difference (should be zero)
    ax = axes[row, 3]
    im = ax.imshow(diff, cmap='hot', aspect='equal')
    ax.set_title(f'|Difference|\nmax={np.max(diff):.2e}', fontsize=10)
    plt.colorbar(im, ax=ax, fraction=0.046)

plt.suptitle('Distributive Normalization Preserves Matrix Semantics\n(Soundness Theorem — Visual Verification)', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_normalization.png', dpi=150, bbox_inches='tight')
print("Saved viz_normalization.png")
