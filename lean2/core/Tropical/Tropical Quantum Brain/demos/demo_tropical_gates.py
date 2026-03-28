#!/usr/bin/env python3
"""
Tropical Quantum Gates: Visualization Demo
==========================================

Demonstrates the tropicalization of quantum gates and their neural interpretations.
Shows how quantum Hadamard, CNOT, and Phase gates map to tropical (max-plus) operations.

The key insight: quantum superposition → tropical winner-take-all under decoherence.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import FancyArrowPatch
import os

# ============================================================================
# TROPICAL SEMIRING OPERATIONS
# ============================================================================

NEG_INF = -1e10  # Practical -∞ for the tropical semiring

def trop_add(a, b):
    """Tropical addition: max(a, b)"""
    return np.maximum(a, b)

def trop_mul(a, b):
    """Tropical multiplication: a + b"""
    return a + b

def trop_matmul(A, x):
    """Tropical matrix-vector product: (A ⊗ x)_i = max_j(A_ij + x_j)"""
    n = A.shape[0]
    result = np.full(n, NEG_INF)
    for i in range(n):
        for j in range(A.shape[1]):
            result[i] = max(result[i], A[i, j] + x[j])
    return result

# ============================================================================
# TROPICAL QUANTUM GATES
# ============================================================================

def tropical_hadamard(a, b):
    """Tropical Hadamard: H_T(a,b) = (max(a,b), max(a,b))
    
    Tropicalization of quantum Hadamard H = (1/√2)[[1,1],[1,-1]]
    Neural interpretation: Winner-Take-All broadcast
    """
    m = max(a, b)
    return m, m

def tropical_cnot(a, b):
    """Tropical CNOT: CNOT_T(a,b) = (a, a+b)
    
    Tropicalization of quantum CNOT [[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]]
    Neural interpretation: Synaptic integration (control adds to target)
    """
    return a, a + b

def tropical_phase(a, phi):
    """Tropical Phase Gate: P_T(φ)(a) = a + φ
    
    Tropicalization of quantum phase gate [[1,0],[0,e^{iφ}]]
    Neural interpretation: Synaptic weight modification
    """
    return a + phi

# ============================================================================
# QUANTUM GATES (for comparison)
# ============================================================================

def quantum_hadamard(state):
    """Standard quantum Hadamard gate"""
    H = np.array([[1, 1], [1, -1]]) / np.sqrt(2)
    return H @ state

def quantum_cnot(state):
    """Standard quantum CNOT gate (on 2-qubit state)"""
    CNOT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]])
    return CNOT @ state

# ============================================================================
# VISUALIZATIONS
# ============================================================================

def plot_tropical_vs_quantum_hadamard():
    """Compare quantum and tropical Hadamard gates"""
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    fig.suptitle('Quantum vs Tropical Hadamard Gate', fontsize=16, fontweight='bold')
    
    # Test inputs
    inputs = [
        (1.0, 0.0, "|0⟩ = (1, 0)"),
        (0.0, 1.0, "|1⟩ = (0, 1)"),
        (1/np.sqrt(2), 1/np.sqrt(2), "|+⟩ = (1/√2, 1/√2)")
    ]
    
    trop_inputs = [
        (3.0, 1.0, "(3, 1)"),
        (1.0, 5.0, "(1, 5)"),
        (4.0, 4.0, "(4, 4)")
    ]
    
    colors_in = ['#3498db', '#e74c3c']
    colors_out = ['#2ecc71', '#f39c12']
    
    # Quantum Hadamard
    for idx, (a, b, label) in enumerate(inputs):
        ax = axes[0, idx]
        state = np.array([a, b])
        result = quantum_hadamard(state)
        
        bars = ax.bar(['|0⟩ in', '|1⟩ in', '|0⟩ out', '|1⟩ out'], 
                      [a, b, result[0], result[1]],
                      color=colors_in + colors_out, edgecolor='black', linewidth=1.2)
        ax.set_title(f'Quantum H · {label}', fontsize=11)
        ax.set_ylabel('Amplitude')
        ax.axhline(y=0, color='gray', linewidth=0.5)
        ax.set_ylim(-1.2, 1.2)
        ax.grid(axis='y', alpha=0.3)
    
    # Tropical Hadamard
    for idx, (a, b, label) in enumerate(trop_inputs):
        ax = axes[1, idx]
        r1, r2 = tropical_hadamard(a, b)
        
        bars = ax.bar(['a in', 'b in', 'a out', 'b out'],
                      [a, b, r1, r2],
                      color=colors_in + colors_out, edgecolor='black', linewidth=1.2)
        ax.set_title(f'Tropical H_T · {label}', fontsize=11)
        ax.set_ylabel('Tropical Value')
        ax.grid(axis='y', alpha=0.3)
        
        # Annotate the max
        ax.annotate(f'max = {max(a,b)}', xy=(2.5, r1), fontsize=10,
                   ha='center', va='bottom', color='darkgreen', fontweight='bold')
    
    axes[0, 0].set_ylabel('Quantum\nAmplitude', fontsize=12, fontweight='bold')
    axes[1, 0].set_ylabel('Tropical\nValue', fontsize=12, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_vs_quantum_hadamard.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: tropical_vs_quantum_hadamard.png")

def plot_tropical_cnot():
    """Visualize tropical CNOT gate behavior"""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Tropical CNOT Gate: Synaptic Integration', fontsize=16, fontweight='bold')
    
    # Show CNOT composition: CNOT² ≠ I (unlike quantum)
    a_vals = np.linspace(-3, 3, 50)
    b_fixed = 1.0
    
    # Single CNOT
    ax = axes[0]
    results_1 = [tropical_cnot(a, b_fixed) for a in a_vals]
    ax.plot(a_vals, [r[0] for r in results_1], 'b-', linewidth=2, label='output a')
    ax.plot(a_vals, [r[1] for r in results_1], 'r-', linewidth=2, label='output b = a+b')
    ax.axhline(y=b_fixed, color='gray', linestyle='--', alpha=0.5, label=f'b = {b_fixed}')
    ax.set_xlabel('Input a')
    ax.set_ylabel('Output')
    ax.set_title('CNOT_T(a, 1.0)')
    ax.legend()
    ax.grid(alpha=0.3)
    
    # Double CNOT
    ax = axes[1]
    results_2 = [tropical_cnot(*tropical_cnot(a, b_fixed)) for a in a_vals]
    ax.plot(a_vals, [r[0] for r in results_2], 'b-', linewidth=2, label='output a')
    ax.plot(a_vals, [r[1] for r in results_2], 'r-', linewidth=2, label='output b = 2a+b')
    ax.plot(a_vals, a_vals, 'g--', alpha=0.5, label='y = a (identity)')
    ax.set_xlabel('Input a')
    ax.set_ylabel('Output')
    ax.set_title('CNOT_T²(a, 1.0) ≠ (a, 1.0)')
    ax.legend()
    ax.grid(alpha=0.3)
    
    # 2D heatmap
    ax = axes[2]
    a_grid = np.linspace(-3, 3, 100)
    b_grid = np.linspace(-3, 3, 100)
    A, B = np.meshgrid(a_grid, b_grid)
    # Output b channel of CNOT
    Z = A + B  # tropical CNOT output_b
    im = ax.contourf(A, B, Z, levels=20, cmap='RdYlBu_r')
    ax.set_xlabel('Input a (control)')
    ax.set_ylabel('Input b (target)')
    ax.set_title('CNOT_T output b = a + b')
    plt.colorbar(im, ax=ax, label='Output b value')
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_cnot.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: tropical_cnot.png")

def plot_tropical_gate_composition():
    """Show how tropical gates compose into neural circuits"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Tropical Gate Circuits = Neural Circuits', fontsize=16, fontweight='bold')
    
    # Circuit 1: H_T is idempotent (H_T² = H_T)
    ax = axes[0, 0]
    test_pairs = [(1, 5), (3, 2), (4, 4), (0, -1), (7, 3)]
    x_pos = np.arange(len(test_pairs))
    
    single_results = [tropical_hadamard(a, b) for a, b in test_pairs]
    double_results = [tropical_hadamard(*tropical_hadamard(a, b)) for a, b in test_pairs]
    
    width = 0.35
    ax.bar(x_pos - width/2, [r[0] for r in single_results], width, 
           label='H_T(a,b)', color='#3498db', edgecolor='black')
    ax.bar(x_pos + width/2, [r[0] for r in double_results], width,
           label='H_T(H_T(a,b))', color='#e74c3c', edgecolor='black', alpha=0.7)
    ax.set_xticks(x_pos)
    ax.set_xticklabels([f'({a},{b})' for a,b in test_pairs])
    ax.set_title('H_T² = H_T (Idempotent)', fontsize=13)
    ax.legend()
    ax.grid(axis='y', alpha=0.3)
    
    # Circuit 2: Phase gate shifts
    ax = axes[0, 1]
    a_vals = np.linspace(-5, 5, 100)
    for phi in [-2, -1, 0, 1, 2]:
        ax.plot(a_vals, [tropical_phase(a, phi) for a in a_vals], 
                linewidth=2, label=f'P_T(φ={phi})')
    ax.plot(a_vals, a_vals, 'k--', alpha=0.3, label='identity')
    ax.set_xlabel('Input a')
    ax.set_ylabel('Output a + φ')
    ax.set_title('Phase Gates = Synaptic Weights', fontsize=13)
    ax.legend(loc='lower right')
    ax.grid(alpha=0.3)
    
    # Circuit 3: Full tropical circuit
    ax = axes[1, 0]
    # Simulate a 3-neuron tropical circuit
    n_steps = 20
    state = np.array([3.0, 1.0, 2.0])
    W = np.array([[0, -0.5, 0.3],
                  [0.2, 0, -0.1],
                  [-0.3, 0.4, 0]])  # tropical weight matrix
    
    history = [state.copy()]
    for t in range(n_steps):
        # Tropical matrix multiplication (max-plus)
        new_state = trop_matmul(W, state)
        # Apply tropical threshold (ReLU-like)
        new_state = trop_add(new_state, np.zeros(3))
        state = new_state
        history.append(state.copy())
    
    history = np.array(history)
    for i in range(3):
        ax.plot(history[:, i], linewidth=2, label=f'Neuron {i+1}', marker='o', markersize=3)
    ax.set_xlabel('Time Step')
    ax.set_ylabel('Tropical Potential')
    ax.set_title('3-Neuron Tropical Circuit Evolution', fontsize=13)
    ax.legend()
    ax.grid(alpha=0.3)
    
    # Circuit 4: Tropical vs quantum composition counts
    ax = axes[1, 1]
    categories = ['Hadamard\n(H²)', 'CNOT\n(CNOT²)', 'Phase\n(P²)']
    quantum_vals = [1, 1, 0]  # H²=I, CNOT²=I, P² depends on φ
    tropical_vals = [0, 0, 0]  # H_T²=H_T, CNOT_T² ≠ I, P_T² = P_T(2φ)
    
    # Show involutive vs idempotent
    labels_q = ['H²=I\n(involutive)', 'CNOT²=I\n(involutive)', 'P(φ)²=P(2φ)\n(rotation)']
    labels_t = ['H_T²=H_T\n(idempotent)', 'CNOT_T²≠I\n(irreversible)', 'P_T(φ)²=P_T(2φ)\n(shift)']
    
    ax.text(0.5, 0.9, 'QUANTUM', fontsize=14, fontweight='bold', color='#3498db',
            ha='center', transform=ax.transAxes)
    ax.text(0.5, 0.45, 'TROPICAL', fontsize=14, fontweight='bold', color='#e74c3c',
            ha='center', transform=ax.transAxes)
    
    for i, (lq, lt) in enumerate(zip(labels_q, labels_t)):
        ax.text(0.15 + 0.35*i, 0.72, lq, fontsize=10, ha='center',
               va='center', transform=ax.transAxes,
               bbox=dict(boxstyle='round,pad=0.3', facecolor='#3498db', alpha=0.2))
        ax.text(0.15 + 0.35*i, 0.27, lt, fontsize=10, ha='center',
               va='center', transform=ax.transAxes,
               bbox=dict(boxstyle='round,pad=0.3', facecolor='#e74c3c', alpha=0.2))
    
    # Arrow
    ax.annotate('', xy=(0.5, 0.5), xytext=(0.5, 0.62),
               arrowprops=dict(arrowstyle='->', lw=2, color='green'),
               transform=ax.transAxes)
    ax.text(0.72, 0.56, 'tropicalization\n(ℏ → 0)', fontsize=10, color='green',
           ha='center', transform=ax.transAxes)
    
    ax.set_title('Gate Composition: Quantum vs Tropical', fontsize=13)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_gate_composition.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: tropical_gate_composition.png")

def plot_tropical_dictionary():
    """Visualize the quantum-tropical-neural correspondence dictionary"""
    fig, ax = plt.subplots(figsize=(16, 10))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    ax.set_title('The Tropical-Quantum-Neural Rosetta Stone', 
                fontsize=18, fontweight='bold', pad=20)
    
    # Column headers
    headers = ['QUANTUM', 'TROPICAL', 'NEURAL']
    header_colors = ['#3498db', '#e74c3c', '#2ecc71']
    header_x = [2.5, 8, 13.5]
    
    for x, h, c in zip(header_x, headers, header_colors):
        ax.text(x, 11, h, fontsize=16, fontweight='bold', ha='center',
               color='white', bbox=dict(boxstyle='round,pad=0.5', facecolor=c))
    
    # Rows
    rows = [
        ('Amplitude ψ ∈ ℂ', 'Log-potential a ∈ ℝ∪{-∞}', 'Membrane potential V'),
        ('Superposition ψ₁+ψ₂', 'Winner-take-all max(a,b)', 'Lateral inhibition'),
        ('Phase e^{iφ}', 'Weight shift a + φ', 'Synaptic weight'),
        ('Entanglement', 'Tropical tensor ⊗', 'Hebbian binding'),
        ('Measurement', 'argmax (tropical proj.)', 'Spike decision'),
        ('Hadamard H', 'Broadcast H_T', 'Cortical fan-out'),
        ('CNOT', 'Accumulation a+b', 'Synaptic integration'),
        ('Decoherence', 'Tropicalization', 'Neural noise'),
        ('Born rule |ψ|²', 'Softmax σ(a)', 'Firing rate'),
    ]
    
    for i, (q, t, n) in enumerate(rows):
        y = 9.5 - i * 1.0
        bg_color = '#f0f0f0' if i % 2 == 0 else '#ffffff'
        ax.fill_between([0.3, 15.7], y-0.4, y+0.4, color=bg_color, alpha=0.5)
        
        ax.text(2.5, y, q, fontsize=11, ha='center', va='center', color='#2c3e50')
        ax.text(8, y, t, fontsize=11, ha='center', va='center', color='#2c3e50',
               fontweight='bold')
        ax.text(13.5, y, n, fontsize=11, ha='center', va='center', color='#2c3e50')
        
        # Arrows between columns
        ax.annotate('', xy=(5.3, y), xytext=(4.7, y),
                   arrowprops=dict(arrowstyle='->', color='gray', lw=1))
        ax.annotate('', xy=(10.8, y), xytext=(10.2, y),
                   arrowprops=dict(arrowstyle='->', color='gray', lw=1))
    
    # Bottom label
    ax.text(8, 0.3, 'Tropicalization (Maslov Dequantization): ℏ → 0, β → ∞',
           fontsize=13, ha='center', va='center', style='italic', color='#7f8c8d')
    
    plt.savefig(os.path.join(os.path.dirname(__file__), 'tropical_dictionary.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: tropical_dictionary.png")

if __name__ == '__main__':
    print("=" * 60)
    print("TROPICAL QUANTUM GATES: Visualization Demo")
    print("=" * 60)
    print()
    
    plot_tropical_vs_quantum_hadamard()
    plot_tropical_cnot()
    plot_tropical_gate_composition()
    plot_tropical_dictionary()
    
    print()
    print("All visualizations saved successfully!")
    print("Key insight: Quantum gates TROPICALIZE into neural operations.")
    print("  Superposition → Winner-Take-All")
    print("  Entanglement  → Synaptic Integration")
    print("  Phase         → Synaptic Weight")
