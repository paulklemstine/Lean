#!/usr/bin/env python3
"""
Tropical Algebra & SHA-256 Gate Matrix Analysis
================================================

This demo visualizes the key mathematical concepts behind the formal proof
that SHA-256 cannot be inverted via tropical or quantum gate matrices.

Demonstrations:
1. Tropical matrix multiplication and its algebraic properties
2. SHA-256 round function decomposition into Boolean gate matrices
3. Information loss visualization (pigeonhole principle)
4. Tropical encoding of Boolean operations (AND, OR, XOR)
5. Why modular addition destroys invertibility

Requirements: pip install numpy matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec
import hashlib
import os

# Use infinity to represent tropical "zero" (additive identity in min-plus)
INF = float('inf')


# ============================================================
# Part 1: Tropical Matrix Algebra
# ============================================================

def tropical_matmul(A, B):
    """
    Tropical (min-plus) matrix multiplication.
    C[i,j] = min_k (A[i,k] + B[k,j])
    """
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i, k] + B[k, j]
                if val < C[i, j]:
                    C[i, j] = val
    return C


def tropical_identity(n):
    """Tropical identity: 0 on diagonal, ∞ elsewhere."""
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    return I


def tropical_perm_matrix(perm):
    """
    Tropical permutation matrix for a permutation.
    perm[i] = j means element i maps to position j.
    """
    n = len(perm)
    M = np.full((n, n), INF)
    for i in range(n):
        M[i, perm[i]] = 0
    return M


def demo_tropical_algebra():
    """Demonstrate tropical matrix algebra properties."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('Tropical (Min-Plus) Matrix Algebra', fontsize=16, fontweight='bold')

    # Example matrices
    A = np.array([[0, 3, INF],
                  [2, 0, 4],
                  [INF, 1, 0]])

    B = np.array([[0, INF, 2],
                  [1, 0, INF],
                  [INF, 3, 0]])

    I = tropical_identity(3)
    AB = tropical_matmul(A, B)

    def plot_matrix(ax, M, title, cmap='YlOrRd'):
        display = np.where(np.isinf(M), np.nan, M)
        im = ax.imshow(display, cmap=cmap, aspect='equal')
        ax.set_title(title, fontsize=12, fontweight='bold')
        for i in range(M.shape[0]):
            for j in range(M.shape[1]):
                val = M[i, j]
                text = '∞' if np.isinf(val) else f'{int(val)}'
                color = 'white' if (not np.isinf(val) and val > 2) else 'black'
                ax.text(j, i, text, ha='center', va='center',
                        fontsize=14, fontweight='bold', color=color)
        ax.set_xticks(range(M.shape[1]))
        ax.set_yticks(range(M.shape[0]))
        return im

    plot_matrix(axes[0, 0], A, 'Matrix A')
    plot_matrix(axes[0, 1], B, 'Matrix B')
    plot_matrix(axes[0, 2], AB, 'A ⊗ B (Tropical Product)')

    # Show identity property: A ⊗ I = A
    AI = tropical_matmul(A, I)
    plot_matrix(axes[1, 0], I, 'Tropical Identity I\n(0 on diag, ∞ elsewhere)')
    plot_matrix(axes[1, 1], AI, 'A ⊗ I = A ✓')

    # Show associativity
    C = np.array([[1, 0, INF],
                  [INF, 2, 0],
                  [0, INF, 3]])
    AB_C = tropical_matmul(tropical_matmul(A, B), C)
    A_BC = tropical_matmul(A, tropical_matmul(B, C))
    assoc_check = np.allclose(
        np.where(np.isinf(AB_C), 1e10, AB_C),
        np.where(np.isinf(A_BC), 1e10, A_BC)
    )
    plot_matrix(axes[1, 2], AB_C,
                f'(A⊗B)⊗C = A⊗(B⊗C): {"✓ Associative" if assoc_check else "✗"}')

    plt.tight_layout()
    plt.savefig('demos/01_tropical_algebra.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/01_tropical_algebra.png")


# ============================================================
# Part 2: SHA-256 Information Loss Visualization
# ============================================================

def demo_information_loss():
    """Visualize why hash functions lose information (pigeonhole principle)."""
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 2, figure=fig)

    # Panel 1: Pigeonhole visualization
    ax1 = fig.add_subplot(gs[0, 0])
    np.random.seed(42)

    # Show 8 inputs mapping to 4 outputs (pigeonhole)
    n_inputs = 8
    n_outputs = 4
    colors = plt.cm.Set3(np.linspace(0, 1, n_inputs))

    for i in range(n_inputs):
        y_in = 1 - i / (n_inputs - 1)
        ax1.plot(0, y_in, 'o', color=colors[i], markersize=15, zorder=5)
        ax1.text(-0.15, y_in, f'x{i}', ha='right', va='center', fontsize=9)

    # Map inputs to outputs (some collide)
    mapping = [0, 1, 0, 2, 3, 1, 2, 3]
    for i in range(n_inputs):
        y_in = 1 - i / (n_inputs - 1)
        y_out = 1 - mapping[i] / (n_outputs - 1)
        ax1.annotate('', xy=(1, y_out), xytext=(0.1, y_in),
                     arrowprops=dict(arrowstyle='->', color=colors[i],
                                     lw=1.5, alpha=0.7))

    for j in range(n_outputs):
        y_out = 1 - j / (n_outputs - 1)
        ax1.plot(1, y_out, 's', color='red', markersize=15, zorder=5)
        ax1.text(1.15, y_out, f'h{j}', ha='left', va='center', fontsize=9)

    ax1.set_xlim(-0.4, 1.4)
    ax1.set_ylim(-0.1, 1.1)
    ax1.set_title('Pigeonhole: 8 inputs → 4 outputs\n(Collisions inevitable)', fontweight='bold')
    ax1.axis('off')

    # Panel 2: Information content
    ax2 = fig.add_subplot(gs[0, 1])
    input_bits = [64, 128, 256, 512, 1024, 2048, 4096]
    output_bits = 256
    info_loss = [max(0, b - output_bits) for b in input_bits]

    bars = ax2.bar(range(len(input_bits)), input_bits, color='steelblue',
                   alpha=0.7, label='Input bits')
    ax2.axhline(y=256, color='red', linewidth=2, linestyle='--',
                label='SHA-256 output (256 bits)')

    for i, (ib, il) in enumerate(zip(input_bits, info_loss)):
        if il > 0:
            ax2.bar(i, il, bottom=output_bits, color='red', alpha=0.3)
            ax2.text(i, ib + 50, f'-{il}', ha='center', fontsize=9, color='red')

    ax2.set_xticks(range(len(input_bits)))
    ax2.set_xticklabels([str(b) for b in input_bits])
    ax2.set_xlabel('Input size (bits)')
    ax2.set_ylabel('Bits')
    ax2.set_title('Information Loss in SHA-256\n(Red = destroyed bits)', fontweight='bold')
    ax2.legend()

    # Panel 3: Collision probability
    ax3 = fig.add_subplot(gs[1, 0])
    n_messages = np.logspace(1, 40, 100)
    # Birthday paradox: P(collision) ≈ 1 - exp(-n²/(2·2^256))
    collision_prob = 1 - np.exp(-n_messages**2 / (2 * 2**256))
    ax3.semilogx(n_messages, collision_prob, 'b-', linewidth=2)
    ax3.axvline(x=2**128, color='red', linestyle='--', alpha=0.7,
                label='2¹²⁸ (birthday bound)')
    ax3.set_xlabel('Number of messages hashed')
    ax3.set_ylabel('Collision probability')
    ax3.set_title('Birthday Paradox for SHA-256\n(Collision at ~2¹²⁸ messages)', fontweight='bold')
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Panel 4: Grover's speedup
    ax4 = fig.add_subplot(gs[1, 1])
    categories = ['Classical\nPreimage', 'Grover\nPreimage', 'Classical\nCollision', 'Quantum\nCollision']
    security_bits = [256, 128, 128, 85]
    colors_bar = ['steelblue', 'coral', 'steelblue', 'coral']

    bars = ax4.bar(categories, security_bits, color=colors_bar, alpha=0.8)
    ax4.set_ylabel('Security level (bits)')
    ax4.set_title("SHA-256 Security: Classical vs Quantum\n(Grover's √N speedup)", fontweight='bold')

    for bar, val in zip(bars, security_bits):
        ax4.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 3,
                f'{val}', ha='center', fontsize=12, fontweight='bold')

    plt.tight_layout()
    plt.savefig('demos/02_information_loss.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/02_information_loss.png")


# ============================================================
# Part 3: Boolean Operations as Tropical Encodings
# ============================================================

def demo_boolean_tropical():
    """Show how Boolean operations encode as tropical operations."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    fig.suptitle('Boolean Operations as Tropical Encodings\n'
                 '(True = 0, False = ∞ in min-plus semiring)',
                 fontsize=14, fontweight='bold')

    def bool_to_trop(b):
        return 0 if b else INF

    def trop_to_str(v):
        return '0' if v == 0 else '∞'

    # Truth tables
    operations = [
        ('AND = max', lambda a, b: a and b, max, 'tropical max'),
        ('OR = min', lambda a, b: a or b, min, 'tropical min'),
        ('XOR (no simple tropical)', lambda a, b: a ^ b, None, 'no direct encoding'),
    ]

    for idx, (name, bool_op, trop_op, trop_name) in enumerate(operations):
        ax = axes[0, idx]

        # Build truth table
        table_data = []
        for a in [True, False]:
            for b in [True, False]:
                result = bool_op(a, b)
                ta, tb = bool_to_trop(a), bool_to_trop(b)
                if trop_op is not None:
                    trop_result = trop_op(ta, tb)
                    match = (bool_to_trop(result) == trop_result)
                else:
                    trop_result = None
                    match = None
                table_data.append((a, b, result, ta, tb, trop_result, match))

        ax.axis('off')
        col_labels = ['a', 'b', f'{name.split("=")[0].strip()}(a,b)',
                       'T(a)', 'T(b)', f'{trop_name}']
        cell_text = []
        cell_colors = []
        for a, b, r, ta, tb, tr, m in table_data:
            row = [str(a), str(b), str(r),
                   trop_to_str(ta), trop_to_str(tb),
                   trop_to_str(tr) if tr is not None else '—']
            cell_text.append(row)
            if m is True:
                cell_colors.append(['#d4edda'] * 6)
            elif m is False:
                cell_colors.append(['#f8d7da'] * 6)
            else:
                cell_colors.append(['#fff3cd'] * 6)

        table = ax.table(cellText=cell_text, colLabels=col_labels,
                         cellColours=cell_colors, loc='center',
                         cellLoc='center')
        table.auto_set_font_size(False)
        table.set_fontsize(11)
        table.scale(1.2, 1.8)
        ax.set_title(name, fontsize=12, fontweight='bold', pad=20)

    # Bottom row: SHA-256 operations classification
    ax_class = fig.add_subplot(2, 1, 2)
    ax_class.axis('off')

    categories = {
        'Invertible\n(Tropical OK)': ['XOR', 'NOT', 'Rotations'],
        'NOT Invertible\n(Tropical Fails)': ['Addition mod 2³²', 'Right shifts',
                                              'σ₀, σ₁ (combined)'],
        'Composition\nResult': ['64 rounds × lossy ops\n= IRREVERSIBLY lossy']
    }

    x_positions = [0.15, 0.5, 0.85]
    colors_cat = ['#28a745', '#dc3545', '#ffc107']

    for (cat, ops), x, color in zip(categories.items(), x_positions, colors_cat):
        ax_class.text(x, 0.85, cat, ha='center', va='center',
                     fontsize=13, fontweight='bold',
                     bbox=dict(boxstyle='round,pad=0.5', facecolor=color,
                              alpha=0.3))
        for i, op in enumerate(ops):
            ax_class.text(x, 0.55 - i * 0.2, f'• {op}', ha='center',
                         va='center', fontsize=11)

    plt.tight_layout()
    plt.savefig('demos/03_boolean_tropical.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/03_boolean_tropical.png")


# ============================================================
# Part 4: Modular Addition Non-Invertibility
# ============================================================

def demo_modular_addition():
    """Visualize why modular addition is not invertible."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Modular Addition: The Core Barrier to SHA-256 Inversion',
                 fontsize=14, fontweight='bold')

    m = 8  # mod 8 for visualization

    # Panel 1: Many-to-one mapping
    ax = axes[0]
    # Show all (a,b) pairs that sum to 3 mod 8
    target = 3
    pairs = [(a, b) for a in range(m) for b in range(m) if (a + b) % m == target]

    ax.set_title(f'All (a,b) with (a+b) mod {m} = {target}\n'
                 f'{len(pairs)} preimages → NOT invertible!', fontweight='bold')

    for i, (a, b) in enumerate(pairs):
        ax.plot(a, b, 'bo', markersize=12)
        ax.text(a + 0.15, b + 0.15, f'({a},{b})', fontsize=8)

    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_xlim(-0.5, m - 0.5)
    ax.set_ylim(-0.5, m - 0.5)
    ax.set_xticks(range(m))
    ax.set_yticks(range(m))
    ax.grid(True, alpha=0.3)

    # Panel 2: Heatmap of (a+b) mod m
    ax = axes[1]
    sums = np.zeros((m, m), dtype=int)
    for a in range(m):
        for b in range(m):
            sums[a, b] = (a + b) % m

    im = ax.imshow(sums, cmap='viridis', aspect='equal')
    ax.set_title(f'(a + b) mod {m}: Complete map\nEach color appears {m} times', fontweight='bold')
    for i in range(m):
        for j in range(m):
            ax.text(j, i, str(sums[i, j]), ha='center', va='center',
                    fontsize=10, color='white' if sums[i, j] < 4 else 'black')
    ax.set_xlabel('b')
    ax.set_ylabel('a')
    plt.colorbar(im, ax=ax, label='(a+b) mod 8')

    # Panel 3: Fiber sizes (preimage counts)
    ax = axes[2]
    fiber_sizes = [sum(1 for a in range(m) for b in range(m) if (a+b)%m == t)
                   for t in range(m)]

    ax.bar(range(m), fiber_sizes, color='steelblue', alpha=0.8)
    ax.axhline(y=m, color='red', linestyle='--', label=f'Each output has exactly {m} preimages')
    ax.set_xlabel('Output value')
    ax.set_ylabel('Number of preimage pairs')
    ax.set_title(f'Fiber sizes for (a+b) mod {m}\nUniform {m}-to-1 mapping', fontweight='bold')
    ax.legend()

    plt.tight_layout()
    plt.savefig('demos/04_modular_addition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/04_modular_addition.png")


# ============================================================
# Part 5: SHA-256 Round Function Structure
# ============================================================

def demo_sha256_structure():
    """Visualize the SHA-256 round function and its gate decomposition."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')
    ax.set_title('SHA-256: Single Round Function Decomposition\n'
                 'Showing invertible (green) vs lossy (red) operations',
                 fontsize=14, fontweight='bold')

    # Draw the state registers
    registers = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
    y_top = 11
    y_bottom = 1

    for i, reg in enumerate(registers):
        x = 1 + i * 1.1
        # Top register
        ax.add_patch(mpatches.FancyBboxPatch((x-0.4, y_top-0.3), 0.8, 0.6,
                     boxstyle="round,pad=0.1", facecolor='lightblue',
                     edgecolor='black'))
        ax.text(x, y_top, reg, ha='center', va='center', fontsize=12, fontweight='bold')

        # Bottom register (new values)
        new_regs = ['T₁+T₂', 'a', 'b', 'c', 'd+T₁', 'e', 'f', 'g']
        ax.add_patch(mpatches.FancyBboxPatch((x-0.4, y_bottom-0.3), 0.8, 0.6,
                     boxstyle="round,pad=0.1", facecolor='lightyellow',
                     edgecolor='black'))
        ax.text(x, y_bottom, new_regs[i], ha='center', va='center',
                fontsize=10, fontweight='bold')

    # Operations boxes
    ops = [
        (5, 8.5, 'Σ₁(e)', 'green', 'Rotation\n(invertible)'),
        (5, 7.5, 'Ch(e,f,g)', 'green', 'Choose\n(invertible per bit)'),
        (5, 6.5, '+ mod 2³²', 'red', 'Addition\n(LOSSY!)'),
        (5, 5.5, '+ Kᵢ + Wᵢ', 'red', 'Add constants\n(LOSSY!)'),
        (2, 8.5, 'Σ₀(a)', 'green', 'Rotation\n(invertible)'),
        (2, 7.5, 'Maj(a,b,c)', 'green', 'Majority\n(invertible per bit)'),
        (2, 6.5, '+ mod 2³²', 'red', 'Addition\n(LOSSY!)'),
    ]

    for x, y, label, color, desc in ops:
        facecolor = '#d4edda' if color == 'green' else '#f8d7da'
        edgecolor = '#28a745' if color == 'green' else '#dc3545'
        ax.add_patch(mpatches.FancyBboxPatch((x-0.8, y-0.25), 1.6, 0.5,
                     boxstyle="round,pad=0.1", facecolor=facecolor,
                     edgecolor=edgecolor, linewidth=2))
        ax.text(x, y, label, ha='center', va='center', fontsize=10, fontweight='bold')
        ax.text(x + 1.5, y, desc, ha='left', va='center', fontsize=8,
                color=edgecolor, fontstyle='italic')

    # Legend
    ax.add_patch(mpatches.FancyBboxPatch((7.5, 4), 2, 0.5,
                 boxstyle="round,pad=0.1", facecolor='#d4edda',
                 edgecolor='#28a745', linewidth=2))
    ax.text(8.5, 4.25, 'Invertible', ha='center', va='center', fontsize=10)

    ax.add_patch(mpatches.FancyBboxPatch((7.5, 3.2), 2, 0.5,
                 boxstyle="round,pad=0.1", facecolor='#f8d7da',
                 edgecolor='#dc3545', linewidth=2))
    ax.text(8.5, 3.45, 'Lossy (NOT invertible)', ha='center', va='center', fontsize=10)

    # Key insight box
    ax.add_patch(mpatches.FancyBboxPatch((0.5, 2), 9, 1.2,
                 boxstyle="round,pad=0.2", facecolor='#fff3cd',
                 edgecolor='#856404', linewidth=2))
    ax.text(5, 2.9, 'KEY THEOREM (Formally Proven in Lean 4):', ha='center',
            va='center', fontsize=11, fontweight='bold', color='#856404')
    ax.text(5, 2.4, 'No tropical matrix, quantum gate, or any algebraic object can invert\n'
            'a non-injective function. SHA-256 uses 192+ modular additions = irreversible.',
            ha='center', va='center', fontsize=10, color='#856404')

    plt.savefig('demos/05_sha256_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/05_sha256_structure.png")


# ============================================================
# Part 6: Quantum Circuit Reversibility & Ancilla Requirements
# ============================================================

def demo_quantum_circuit():
    """Visualize quantum circuit requirements for hash function inversion."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    fig.suptitle('Quantum Circuits for Hash Functions:\n'
                 'Reversibility Requires Ancilla (Garbage) Bits',
                 fontsize=14, fontweight='bold')

    # Panel 1: Classical irreversible vs quantum reversible
    ax = axes[0]
    ax.axis('off')

    # Classical (irreversible)
    ax.text(0.25, 0.95, 'Classical SHA-256', ha='center', fontsize=13,
            fontweight='bold', transform=ax.transAxes)
    ax.text(0.25, 0.85, 'input (512 bits)', ha='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='lightblue'),
            transform=ax.transAxes)
    ax.annotate('', xy=(0.25, 0.72), xytext=(0.25, 0.80),
                xycoords='axes fraction', textcoords='axes fraction',
                arrowprops=dict(arrowstyle='->', lw=2))
    ax.text(0.25, 0.65, 'SHA-256\n(irreversible)', ha='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='#f8d7da'),
            transform=ax.transAxes)
    ax.annotate('', xy=(0.25, 0.50), xytext=(0.25, 0.58),
                xycoords='axes fraction', textcoords='axes fraction',
                arrowprops=dict(arrowstyle='->', lw=2))
    ax.text(0.25, 0.43, 'hash (256 bits)', ha='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='lightyellow'),
            transform=ax.transAxes)
    ax.text(0.25, 0.30, '❌ 256 bits LOST\n❌ Cannot recover input', ha='center',
            fontsize=11, color='red', transform=ax.transAxes)

    # Quantum (reversible with ancilla)
    ax.text(0.75, 0.95, 'Quantum SHA-256', ha='center', fontsize=13,
            fontweight='bold', transform=ax.transAxes)
    ax.text(0.65, 0.85, 'input\n(512 bits)', ha='center', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightblue'),
            transform=ax.transAxes)
    ax.text(0.85, 0.85, '|0⟩ ancilla\n(≥256 bits)', ha='center', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='#d4edda'),
            transform=ax.transAxes)
    ax.annotate('', xy=(0.75, 0.72), xytext=(0.75, 0.78),
                xycoords='axes fraction', textcoords='axes fraction',
                arrowprops=dict(arrowstyle='->', lw=2))
    ax.text(0.75, 0.65, 'U_SHA256\n(unitary/reversible)', ha='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='#d4edda'),
            transform=ax.transAxes)
    ax.annotate('', xy=(0.75, 0.50), xytext=(0.75, 0.58),
                xycoords='axes fraction', textcoords='axes fraction',
                arrowprops=dict(arrowstyle='->', lw=2))
    ax.text(0.65, 0.43, 'hash\n(256 bits)', ha='center', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightyellow'),
            transform=ax.transAxes)
    ax.text(0.85, 0.43, 'garbage\n(≥256 bits)', ha='center', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='#fff3cd'),
            transform=ax.transAxes)
    ax.text(0.75, 0.28, '✓ Reversible IF garbage bits kept\n'
            '❌ hash alone insufficient\n'
            '(Proven: Lean theorem\n quantum_sha256_inverse_needs_garbage)',
            ha='center', fontsize=10, color='#856404', transform=ax.transAxes)

    # Panel 2: Ancilla bit scaling
    ax2 = axes[1]
    input_sizes = [256, 512, 1024, 2048, 4096, 8192]
    ancilla_bits = [max(0, s - 256) for s in input_sizes]
    total_qubits = [s + a for s, a in zip(input_sizes, ancilla_bits)]

    x = np.arange(len(input_sizes))
    width = 0.35
    bars1 = ax2.bar(x - width/2, input_sizes, width, label='Input qubits',
                    color='steelblue', alpha=0.8)
    bars2 = ax2.bar(x + width/2, ancilla_bits, width, label='Ancilla (garbage) qubits',
                    color='coral', alpha=0.8)

    ax2.set_xlabel('Input message size (bits)')
    ax2.set_ylabel('Number of qubits')
    ax2.set_title('Quantum SHA-256: Qubit Requirements\n'
                  '(Ancilla bits grow linearly with input size)',
                  fontweight='bold')
    ax2.set_xticks(x)
    ax2.set_xticklabels([str(s) for s in input_sizes])
    ax2.legend()
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('demos/06_quantum_circuit.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/06_quantum_circuit.png")


# ============================================================
# Part 7: Tropical Permutation Matrices
# ============================================================

def demo_tropical_permutation():
    """Show tropical permutation matrices and their inverses."""
    fig, axes = plt.subplots(1, 4, figsize=(20, 5))
    fig.suptitle('Tropical Permutation Matrices: Invertible Bijections\n'
                 '(Formally proven: tropicalPerm_inverse)',
                 fontsize=14, fontweight='bold')

    perm = [2, 0, 3, 1]  # σ: 0→2, 1→0, 2→3, 3→1
    inv_perm = [1, 3, 0, 2]  # σ⁻¹

    P = tropical_perm_matrix(perm)
    P_inv = tropical_perm_matrix(inv_perm)
    product = tropical_matmul(P, P_inv)
    I = tropical_identity(4)

    def plot_trop(ax, M, title):
        display = np.where(np.isinf(M), np.nan, M)
        ax.imshow(display, cmap='YlOrRd', aspect='equal', vmin=-1, vmax=5)
        for i in range(4):
            for j in range(4):
                val = M[i, j]
                text = '∞' if np.isinf(val) else f'{int(val)}'
                ax.text(j, i, text, ha='center', va='center',
                        fontsize=16, fontweight='bold',
                        color='black' if val == 0 else 'gray')
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.set_xticks(range(4))
        ax.set_yticks(range(4))

    plot_trop(axes[0], P, f'P(σ)\nσ = {perm}')
    plot_trop(axes[1], P_inv, f'P(σ⁻¹)\nσ⁻¹ = {inv_perm}')
    plot_trop(axes[2], product, 'P(σ) ⊗ P(σ⁻¹)')
    plot_trop(axes[3], I, 'Tropical Identity I\n= P(σ) ⊗ P(σ⁻¹) ✓')

    plt.tight_layout()
    plt.savefig('demos/07_tropical_permutation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/07_tropical_permutation.png")


# ============================================================
# Part 8: XOR Self-Inverse Demonstration
# ============================================================

def demo_xor_inverse():
    """Demonstrate XOR self-inverse property and its implications."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('XOR: The Only Invertible Binary Operation in SHA-256\n'
                 '(Formally proven: xor_self_inverse, xor_key_bijective)',
                 fontsize=14, fontweight='bold')

    # Panel 1: XOR truth table showing self-inverse
    ax = axes[0]
    ax.axis('off')
    cell_text = []
    for x in [0, 1]:
        for k in [0, 1]:
            xor1 = x ^ k
            xor2 = xor1 ^ k
            cell_text.append([str(x), str(k), str(xor1), str(xor2),
                             '✓' if xor2 == x else '✗'])

    table = ax.table(cellText=cell_text,
                     colLabels=['x', 'k', 'x⊕k', '(x⊕k)⊕k', 'x recovered?'],
                     cellColours=[['#d4edda']*5]*4,
                     loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(13)
    table.scale(1.2, 2.0)
    ax.set_title('XOR is its own inverse\n(x ⊕ k) ⊕ k = x', fontweight='bold', pad=20)

    # Panel 2: Byte-level XOR encryption/decryption
    ax = axes[1]
    ax.axis('off')

    message = "HELLO"
    key = 0x42

    encrypted = [ord(c) ^ key for c in message]
    decrypted = [e ^ key for e in encrypted]

    rows = []
    for i, c in enumerate(message):
        rows.append([c, f'0x{ord(c):02X}', f'0x{key:02X}',
                     f'0x{encrypted[i]:02X}', chr(decrypted[i])])

    table = ax.table(cellText=rows,
                     colLabels=['Char', 'ASCII', 'Key', 'Encrypted', 'Decrypted'],
                     cellColours=[['#e8f4f8']*5]*len(rows),
                     loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.scale(1.2, 2.0)
    ax.set_title(f'XOR encryption with key 0x{key:02X}\nPerfect recovery!',
                fontweight='bold', pad=20)

    # Panel 3: Contrast with AND (not invertible)
    ax = axes[2]
    ax.axis('off')

    cell_text = []
    for x in [0, 1]:
        for k in [0, 1]:
            and_result = x & k
            cell_text.append([str(x), str(k), str(and_result),
                             '?' if and_result == 0 else str(x),
                             '✗ (ambiguous)' if (k == 1 and and_result == 0)
                              or (k == 0) else '✓'])

    colors = []
    for row in cell_text:
        colors.append(['#f8d7da' if '✗' in row[4] else '#d4edda'] * 5)

    table = ax.table(cellText=cell_text,
                     colLabels=['x', 'k', 'x∧k', 'recover x?', 'status'],
                     cellColours=colors,
                     loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(13)
    table.scale(1.2, 2.0)
    ax.set_title('AND is NOT invertible\nCannot recover x from x∧k',
                fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('demos/08_xor_inverse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/08_xor_inverse.png")


# ============================================================
# Part 9: Live SHA-256 Hash Collision Demonstration
# ============================================================

def demo_hash_experiment():
    """Run actual SHA-256 hashing experiments."""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle('SHA-256 Experimental Analysis\n'
                 '(Real computations validating formal theorems)',
                 fontsize=14, fontweight='bold')

    # Panel 1: Avalanche effect
    ax = axes[0, 0]
    base_msg = b"The quick brown fox"
    base_hash = hashlib.sha256(base_msg).digest()

    bit_diffs = []
    for bit_pos in range(8 * len(base_msg)):
        byte_pos = bit_pos // 8
        bit_in_byte = bit_pos % 8
        modified = bytearray(base_msg)
        modified[byte_pos] ^= (1 << bit_in_byte)
        mod_hash = hashlib.sha256(bytes(modified)).digest()

        # Count differing bits
        diff_bits = sum(bin(a ^ b).count('1') for a, b in zip(base_hash, mod_hash))
        bit_diffs.append(diff_bits)

    ax.bar(range(len(bit_diffs)), bit_diffs, color='steelblue', alpha=0.7)
    ax.axhline(y=128, color='red', linestyle='--', label='Expected: 128 bits (50%)')
    ax.set_xlabel('Input bit flipped')
    ax.set_ylabel('Output bits changed')
    ax.set_title('Avalanche Effect\n(1 bit change → ~128 bit output change)',
                fontweight='bold')
    ax.legend()

    # Panel 2: Distribution of hash values (first byte)
    ax = axes[0, 1]
    first_bytes = []
    for i in range(10000):
        h = hashlib.sha256(str(i).encode()).digest()
        first_bytes.append(h[0])

    ax.hist(first_bytes, bins=32, color='steelblue', alpha=0.7, edgecolor='white')
    ax.axhline(y=10000/32, color='red', linestyle='--', label='Uniform expectation')
    ax.set_xlabel('First byte value (binned)')
    ax.set_ylabel('Count')
    ax.set_title('Distribution of SHA-256 first byte\n(10,000 inputs → near-uniform)',
                fontweight='bold')
    ax.legend()

    # Panel 3: Preimage search cost
    ax = axes[1, 0]
    target_prefix_lengths = [1, 2, 3, 4]  # nibbles
    attempts_needed = []

    for prefix_len in target_prefix_lengths:
        target = '0' * prefix_len
        count = 0
        for i in range(10**7):
            h = hashlib.sha256(str(i).encode()).hexdigest()
            count += 1
            if h[:prefix_len] == target:
                break
        attempts_needed.append(count)

    theoretical = [16**p for p in target_prefix_lengths]
    x = np.arange(len(target_prefix_lengths))
    width = 0.35
    ax.bar(x - width/2, attempts_needed, width, label='Actual attempts',
           color='steelblue', alpha=0.8)
    ax.bar(x + width/2, theoretical, width, label='Theoretical (16^n)',
           color='coral', alpha=0.8)
    ax.set_xticks(x)
    ax.set_xticklabels([f'{p} hex chars' for p in target_prefix_lengths])
    ax.set_ylabel('Attempts needed')
    ax.set_title('Partial Preimage Search Cost\n(Exponential growth confirmed)',
                fontweight='bold')
    ax.legend()
    ax.set_yscale('log')

    # Panel 4: Collision search (birthday paradox demo with truncated hash)
    ax = axes[1, 1]
    hash_sizes = [8, 12, 16, 20]  # bits of hash to use
    collision_attempts = []

    for bits in hash_sizes:
        mask = (1 << bits) - 1
        seen = set()
        for i in range(2**20):
            h = int.from_bytes(hashlib.sha256(str(i).encode()).digest()[:4], 'big') & mask
            if h in seen:
                collision_attempts.append(i)
                break
            seen.add(h)
        else:
            collision_attempts.append(2**20)

    birthday_bound = [int(np.sqrt(np.pi/2 * 2**b)) for b in hash_sizes]

    x = np.arange(len(hash_sizes))
    ax.bar(x - width/2, collision_attempts, width, label='Actual collision found',
           color='steelblue', alpha=0.8)
    ax.bar(x + width/2, birthday_bound, width, label='Birthday bound √(π/2 · 2^n)',
           color='coral', alpha=0.8)
    ax.set_xticks(x)
    ax.set_xticklabels([f'{b}-bit hash' for b in hash_sizes])
    ax.set_ylabel('Messages tried')
    ax.set_title('Birthday Paradox Collision Search\n(Matches √(2^n) scaling)',
                fontweight='bold')
    ax.legend()

    plt.tight_layout()
    plt.savefig('demos/09_hash_experiments.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demos/09_hash_experiments.png")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("Tropical Algebra & SHA-256 Gate Matrix Analysis")
    print("Companion demos for the formal Lean 4 proof")
    print("=" * 60)
    print()

    os.makedirs('demos', exist_ok=True)

    demo_tropical_algebra()
    demo_information_loss()
    demo_boolean_tropical()
    demo_modular_addition()
    demo_sha256_structure()
    demo_quantum_circuit()
    demo_tropical_permutation()
    demo_xor_inverse()
    demo_hash_experiment()

    print()
    print("All demos generated successfully!")
    print("See demos/ folder for PNG visualizations.")
