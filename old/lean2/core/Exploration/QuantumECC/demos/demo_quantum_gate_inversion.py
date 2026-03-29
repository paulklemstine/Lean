#!/usr/bin/env python3
"""
Quantum Gate Inversion Demo
============================

Demonstrates:
1. Quantum gates as unitary matrices
2. Composing adjoint (inverse) gates to run computation in reverse
3. Shor's algorithm structure for ECDLP
4. Uncomputation via circuit inversion

Usage: python demo_quantum_gate_inversion.py
Outputs: quantum_gate_inversion.png, shor_ecdlp_circuit.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from typing import List, Tuple

# --- Quantum Gates ---

I = np.eye(2)
X = np.array([[0, 1], [1, 0]], dtype=complex)  # Pauli X (NOT)
Y = np.array([[0, -1j], [1j, 0]], dtype=complex)  # Pauli Y
Z = np.array([[1, 0], [0, -1]], dtype=complex)  # Pauli Z
H = np.array([[1, 1], [1, -1]], dtype=complex) / np.sqrt(2)  # Hadamard
S = np.array([[1, 0], [0, 1j]], dtype=complex)  # Phase
T = np.array([[1, 0], [0, np.exp(1j * np.pi / 4)]], dtype=complex)  # T gate

# 2-qubit gates
CNOT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)
SWAP = np.array([[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]], dtype=complex)

# Gate names and their adjoints
GATES = {
    'I': I, 'X': X, 'Y': Y, 'Z': Z, 'H': H, 'S': S, 'T': T,
}

GATE_NAMES = {
    'I': 'Identity', 'X': 'Pauli X', 'Y': 'Pauli Y', 'Z': 'Pauli Z',
    'H': 'Hadamard', 'S': 'Phase S', 'T': 'T gate',
}

def adjoint(U: np.ndarray) -> np.ndarray:
    """Compute U† (conjugate transpose)."""
    return U.conj().T

def is_unitary(U: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if U†U = I."""
    return np.allclose(U.conj().T @ U, np.eye(U.shape[0]), atol=tol)

def is_self_adjoint(U: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if U† = U (Hermitian/self-inverse)."""
    return np.allclose(adjoint(U), U, atol=tol)

def compose_circuit(gates: List[np.ndarray]) -> np.ndarray:
    """Compose a sequence of gates: C = G_n ... G_2 G_1."""
    result = np.eye(gates[0].shape[0], dtype=complex)
    for g in gates:
        result = g @ result
    return result

def invert_circuit(gates: List[np.ndarray]) -> List[np.ndarray]:
    """Invert a circuit: reverse order, adjoint each gate."""
    return [adjoint(g) for g in reversed(gates)]

# --- Demonstrations ---

def demo_unitarity():
    """Verify all standard gates are unitary."""
    print("=" * 50)
    print("§1: Unitarity Verification")
    print("=" * 50)
    
    for name, gate in GATES.items():
        u = is_unitary(gate)
        sa = is_self_adjoint(gate)
        symbol = "✓ self-inverse" if sa else "✗ not self-inverse"
        print(f"  {GATE_NAMES[name]:12s} ({name}): unitary={u}  {symbol}")
    
    print(f"\n  CNOT (2-qubit): unitary={is_unitary(CNOT)}  "
          f"{'✓ self-inverse' if is_self_adjoint(CNOT) else '✗'}")
    print(f"  SWAP (2-qubit): unitary={is_unitary(SWAP)}  "
          f"{'✓ self-inverse' if is_self_adjoint(SWAP) else '✗'}")

def demo_circuit_inversion():
    """Build a circuit and verify its inverse."""
    print("\n" + "=" * 50)
    print("§2: Circuit Inversion")
    print("=" * 50)
    
    # Build a non-trivial circuit
    circuit = [H, T, S, X, H, Z]
    circuit_names = ['H', 'T', 'S', 'X', 'H', 'Z']
    
    print(f"  Forward circuit:  {' → '.join(circuit_names)}")
    
    inv_circuit = invert_circuit(circuit)
    inv_names = [f"{n}†" if not is_self_adjoint(GATES[n]) else n 
                 for n in reversed(circuit_names)]
    print(f"  Inverse circuit:  {' → '.join(inv_names)}")
    
    # Verify
    C = compose_circuit(circuit)
    C_inv = compose_circuit(inv_circuit)
    product = C @ C_inv
    
    is_identity = np.allclose(product, np.eye(2), atol=1e-10)
    print(f"\n  C · C⁻¹ = I? {is_identity}")
    print(f"  Max deviation from identity: {np.max(np.abs(product - np.eye(2))):.2e}")
    
    # Apply to a state and recover
    psi = np.array([1, 0], dtype=complex)  # |0⟩
    encoded = C @ psi
    recovered = C_inv @ encoded
    print(f"\n  |0⟩ → C|0⟩ → C⁻¹C|0⟩")
    print(f"  Original:  {psi}")
    print(f"  Encoded:   {np.round(encoded, 4)}")
    print(f"  Recovered: {np.round(recovered, 4)}")
    print(f"  Recovery fidelity: {np.abs(np.vdot(psi, recovered))**2:.10f}")

def demo_uncomputation():
    """Demonstrate uncomputation — erasing ancilla via inverse circuit."""
    print("\n" + "=" * 50)
    print("§3: Uncomputation (used in Shor's algorithm)")
    print("=" * 50)
    
    # Simulate: |x⟩|0⟩ → |x⟩|f(x)⟩ → |x⟩|f(x)⟩|result⟩ → |x⟩|0⟩|result⟩
    # (simplified to single-qubit for illustration)
    
    print("  Uncomputation is the key technique in Shor's algorithm.")
    print("  It 'erases' intermediate computations stored in ancilla qubits.")
    print()
    print("  Step 1: Compute f(x) into ancilla")
    print("    |x⟩|0⟩  →  |x⟩|f(x)⟩")
    print("  Step 2: Copy result to output register")
    print("    |x⟩|f(x)⟩|0⟩  →  |x⟩|f(x)⟩|result⟩")
    print("  Step 3: UNCOMPUTE by running Step 1 in REVERSE")
    print("    |x⟩|f(x)⟩|result⟩  →  |x⟩|0⟩|result⟩")
    print()
    print("  This is essential because measuring ancilla qubits would")
    print("  collapse the superposition needed for the QFT!")
    
    # Numerical example
    compute_gates = [H, T, S]
    uncompute_gates = invert_circuit(compute_gates)
    
    # Full cycle: compute then uncompute
    full = compose_circuit(uncompute_gates + compute_gates)  # Note: reversed order
    print(f"\n  Compute then uncompute = Identity? {np.allclose(full, np.eye(2), atol=1e-10)}")

def plot_gate_inversion():
    """Create a visual showing circuit inversion."""
    fig, axes = plt.subplots(3, 1, figsize=(14, 10))
    fig.suptitle('Quantum Circuit Inversion: Running Computation Backwards', 
                 fontsize=16, fontweight='bold')
    
    # Circuit diagram helper
    def draw_gate(ax, x, y, name, color='lightblue', width=0.8):
        rect = patches.FancyBboxPatch((x - width/2, y - 0.3), width, 0.6,
                                       boxstyle="round,pad=0.1",
                                       facecolor=color, edgecolor='black', linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x, y, name, ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Forward circuit
    ax1 = axes[0]
    ax1.set_xlim(-0.5, 8)
    ax1.set_ylim(-1, 1)
    ax1.set_title('Forward Circuit C', fontsize=13)
    ax1.axhline(y=0, color='black', linewidth=2, xmin=0.05, xmax=0.95)
    
    gates_fwd = ['H', 'T', 'S', 'X', 'H', 'Z']
    colors_fwd = ['#3498db', '#e74c3c', '#e74c3c', '#3498db', '#3498db', '#3498db']
    for i, (g, c) in enumerate(zip(gates_fwd, colors_fwd)):
        draw_gate(ax1, i + 1, 0, g, color=c)
    
    ax1.text(0.3, 0, '|ψ⟩', fontsize=14, ha='center', va='bottom')
    ax1.text(7.5, 0, 'C|ψ⟩', fontsize=14, ha='center', va='bottom')
    ax1.arrow(7, 0, 0.3, 0, head_width=0.1, head_length=0.1, fc='black')
    ax1.axis('off')
    
    # Legend for colors
    ax1.text(0.5, -0.7, '🔵 = self-inverse (G† = G)', fontsize=10, color='#3498db')
    ax1.text(4.0, -0.7, '🔴 = NOT self-inverse (G† ≠ G)', fontsize=10, color='#e74c3c')
    
    # Inverse circuit
    ax2 = axes[1]
    ax2.set_xlim(-0.5, 8)
    ax2.set_ylim(-1, 1)
    ax2.set_title('Inverse Circuit C⁻¹ (reversed order, adjoint gates)', fontsize=13)
    ax2.axhline(y=0, color='black', linewidth=2, xmin=0.05, xmax=0.95)
    
    gates_inv = ['Z', 'H', 'X', 'S†', 'T†', 'H']
    colors_inv = ['#3498db', '#3498db', '#3498db', '#f39c12', '#f39c12', '#3498db']
    for i, (g, c) in enumerate(zip(gates_inv, colors_inv)):
        draw_gate(ax2, i + 1, 0, g, color=c)
    
    ax2.text(0.3, 0, 'C|ψ⟩', fontsize=14, ha='center', va='bottom')
    ax2.text(7.5, 0, '|ψ⟩', fontsize=14, ha='center', va='bottom')
    ax2.arrow(7, 0, 0.3, 0, head_width=0.1, head_length=0.1, fc='black')
    ax2.axis('off')
    ax2.text(0.5, -0.7, '🟡 = adjoint gate (G† ≠ G, so we use the inverse)', fontsize=10, color='#f39c12')
    
    # Composition = Identity
    ax3 = axes[2]
    ax3.set_xlim(-0.5, 8)
    ax3.set_ylim(-1.5, 1)
    ax3.set_title('C⁻¹ ∘ C = Identity (perfect recovery)', fontsize=13)
    
    # Show matrix computation
    result_text = """
    Verification (numerical):
    
    C   = Z · H · X · S · T · H
    C⁻¹ = H · T† · S† · X · H · Z
    
    C⁻¹ · C = I₂  ✅  (max error: < 10⁻¹⁵)
    
    Key insight: This works because EVERY quantum gate is unitary (U†U = I).
    Quantum mechanics guarantees perfect reversibility!
    """
    ax3.text(0.5, 0.5, result_text, transform=ax3.transAxes,
             fontsize=11, verticalalignment='center', horizontalalignment='center',
             fontfamily='monospace',
             bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.3))
    ax3.axis('off')
    
    plt.tight_layout()
    plt.savefig('quantum_gate_inversion.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved: quantum_gate_inversion.png")

def plot_shor_structure():
    """Visualize the structure of Shor's algorithm for ECDLP."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 9))
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 14)
    ax.set_title("Shor's Algorithm for ECDLP on secp256k1\n(Quantum Circuit Structure)", 
                 fontsize=16, fontweight='bold')
    
    def draw_box(x, y, w, h, label, color, sublabel=''):
        rect = patches.FancyBboxPatch((x, y), w, h,
                                       boxstyle="round,pad=0.2",
                                       facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(x + w/2, y + h/2 + 0.15, label, ha='center', va='center', 
                fontsize=11, fontweight='bold')
        if sublabel:
            ax.text(x + w/2, y + h/2 - 0.25, sublabel, ha='center', va='center', 
                    fontsize=8, style='italic')
    
    # Quantum registers
    y_reg1 = 11
    y_reg2 = 8
    y_reg3 = 5
    y_reg4 = 2
    
    # Register labels
    ax.text(0.5, y_reg1 + 0.5, '|0⟩⊗²⁵⁶', fontsize=12, fontweight='bold', color='blue')
    ax.text(0.5, y_reg2 + 0.5, '|0⟩⊗²⁵⁶', fontsize=12, fontweight='bold', color='blue')
    ax.text(0.5, y_reg3 + 0.5, '|P⟩', fontsize=12, fontweight='bold', color='green')
    ax.text(0.5, y_reg4 + 0.5, '|0⟩ ancilla', fontsize=12, fontweight='bold', color='gray')
    
    # Wires
    for y in [y_reg1 + 0.5, y_reg2 + 0.5, y_reg3 + 0.5, y_reg4 + 0.5]:
        ax.plot([2, 18], [y, y], 'k-', linewidth=1.5)
    
    # Step 1: Hadamard
    draw_box(3, y_reg1, 2, 1.2, 'H⊗²⁵⁶', '#3498db', 'superposition')
    draw_box(3, y_reg2, 2, 1.2, 'H⊗²⁵⁶', '#3498db', 'superposition')
    
    # Step 2: Controlled point multiplication
    draw_box(6, y_reg4 - 0.5, 3, y_reg1 - y_reg4 + 2.2, 
             'Controlled\naP + bQ', '#e74c3c', 'EC arithmetic')
    
    # Step 3: Measure ancilla / uncompute
    draw_box(10, y_reg3, 2.5, 1.2, 'Uncompute†', '#f39c12', 'inverse circuit')
    draw_box(10, y_reg4, 2.5, 1.2, 'Uncompute†', '#f39c12', 'inverse circuit')
    
    # Step 4: QFT
    draw_box(13.5, y_reg1, 2, 1.2, 'QFT†', '#9b59b6', '2D Fourier')
    draw_box(13.5, y_reg2, 2, 1.2, 'QFT†', '#9b59b6', '2D Fourier')
    
    # Step 5: Measure
    draw_box(16.5, y_reg1, 1.5, 1.2, '📏', '#2ecc71', 'measure')
    draw_box(16.5, y_reg2, 1.5, 1.2, '📏', '#2ecc71', 'measure')
    
    # Annotations
    ax.annotate('Quantum\nparallelism', xy=(4, y_reg1), xytext=(4, 13.5),
                fontsize=9, ha='center', arrowprops=dict(arrowstyle='->', color='blue'),
                color='blue')
    
    ax.annotate('Period\nextraction', xy=(14.5, y_reg1), xytext=(14.5, 13.5),
                fontsize=9, ha='center', arrowprops=dict(arrowstyle='->', color='purple'),
                color='purple')
    
    # Resource estimates box
    resources = """
    Resource Estimates (secp256k1):
    ─────────────────────────────
    Logical qubits:  ~2,330
    T-gates:         ~2.58 × 10¹¹
    Toffoli gates:   ~8.19 × 10¹⁰
    Circuit depth:   ~2.97 × 10¹⁰
    Physical qubits: ~20 million
    
    Current hardware: ~1,000 qubits
    Gap: ~20,000× ⚠️
    """
    ax.text(0.02, 0.02, resources, transform=ax.transAxes,
            fontsize=9, verticalalignment='bottom', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='orange', alpha=0.9))
    
    ax.axis('off')
    plt.tight_layout()
    plt.savefig('shor_ecdlp_circuit.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved: shor_ecdlp_circuit.png")

def plot_quantum_vs_classical():
    """Compare quantum vs classical attack complexity."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Plot 1: Complexity comparison
    ax1 = axes[0]
    bits = np.arange(32, 521, 8)
    classical = 2.0**(bits / 2)  # Pollard's rho: O(√n)
    quantum = bits.astype(float)**3  # Shor: O(n³)
    
    ax1.semilogy(bits, classical, 'r-', linewidth=2, label="Classical (Pollard's ρ): O(2^(n/2))")
    ax1.semilogy(bits, quantum, 'b-', linewidth=2, label="Quantum (Shor): O(n³)")
    
    # Mark secp256k1
    ax1.axvline(x=256, color='green', linestyle='--', alpha=0.7, label='secp256k1 (256-bit)')
    ax1.semilogy(256, 2**128, 'rv', markersize=15, label=f'Classical: 2¹²⁸ ≈ 3.4×10³⁸')
    ax1.semilogy(256, 256**3, 'b^', markersize=15, label=f'Quantum: 256³ ≈ 1.7×10⁷')
    
    ax1.set_xlabel('Key size (bits)', fontsize=12)
    ax1.set_ylabel('Operations required', fontsize=12)
    ax1.set_title('ECDLP: Classical vs Quantum Complexity', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=9, loc='upper left')
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(32, 520)
    
    # Plot 2: Timeline to quantum threat
    ax2 = axes[1]
    years = np.arange(2020, 2055)
    qubits_optimistic = 100 * 2**((years - 2020) / 2)  # Doubling every 2 years
    qubits_moderate = 100 * 2**((years - 2020) / 3)    # Doubling every 3 years
    qubits_pessimistic = 100 * 2**((years - 2020) / 5)  # Doubling every 5 years
    
    ax2.semilogy(years, qubits_optimistic, 'r-', linewidth=2, label='Optimistic (2yr doubling)')
    ax2.semilogy(years, qubits_moderate, 'orange', linewidth=2, label='Moderate (3yr doubling)')
    ax2.semilogy(years, qubits_pessimistic, 'b-', linewidth=2, label='Pessimistic (5yr doubling)')
    
    ax2.axhline(y=2330, color='red', linestyle='--', alpha=0.7)
    ax2.text(2021, 2330 * 1.5, 'Logical qubits needed: 2,330', fontsize=10, color='red')
    
    ax2.axhline(y=20_000_000, color='darkred', linestyle=':', alpha=0.7)
    ax2.text(2021, 20_000_000 * 1.5, 'Physical qubits needed: ~20M', fontsize=10, color='darkred')
    
    ax2.set_xlabel('Year', fontsize=12)
    ax2.set_ylabel('Available qubits', fontsize=12)
    ax2.set_title('When Can Quantum Computers Break secp256k1?', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(2020, 2054)
    
    plt.tight_layout()
    plt.savefig('quantum_vs_classical_ecdlp.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved: quantum_vs_classical_ecdlp.png")

if __name__ == '__main__':
    print("=" * 60)
    print("Quantum Gate Inversion Demo")
    print("=" * 60)
    
    demo_unitarity()
    demo_circuit_inversion()
    demo_uncomputation()
    
    print("\n📊 Generating visualizations...")
    plot_gate_inversion()
    plot_shor_structure()
    plot_quantum_vs_classical()
    
    print("\n✅ All quantum demos complete!")
