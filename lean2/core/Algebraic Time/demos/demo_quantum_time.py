#!/usr/bin/env python3
"""
Algebraic Theory of Time — Demo 5: Quantum Temporal Algebra
=============================================================

Visualizes:
  - Unitary evolution (reversible, GROUP) for pure quantum states
  - Decoherence (irreversible, MONOID) as the group→monoid transition
  - Von Neumann entropy increase during decoherence

The quantum-to-classical transition IS the group-to-monoid transition.

Run: python3 demo_quantum_time.py
Output: quantum_time.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ============================================================
# 1. Quantum system: Two-level system (qubit)
# ============================================================

def unitary_evolution(rho_0, H, t):
    """
    Pure unitary evolution: ρ(t) = U(t) ρ₀ U(t)†
    where U(t) = exp(-iHt)
    This is a TEMPORAL GROUP action.
    """
    U = np.linalg.matrix_power(
        np.eye(2) * np.cos(t) - 1j * H * np.sin(t) / np.linalg.norm(H), 1
    )
    # More accurate: eigendecomposition
    eigvals, eigvecs = np.linalg.eigh(H)
    U = eigvecs @ np.diag(np.exp(-1j * eigvals * t)) @ eigvecs.conj().T
    return U @ rho_0 @ U.conj().T

def decoherence_evolution(rho_0, H, t, gamma=0.3):
    """
    Evolution with decoherence (Lindblad dynamics):
    Off-diagonal elements decay as exp(-γt).
    This is a TEMPORAL MONOID action (not invertible).
    """
    rho_t = unitary_evolution(rho_0, H, t)
    # Apply decoherence: decay off-diagonal elements
    decay = np.exp(-gamma * t)
    rho_t[0, 1] *= decay
    rho_t[1, 0] *= decay
    # Ensure trace 1
    rho_t /= np.trace(rho_t)
    return rho_t

def von_neumann_entropy(rho):
    """S(ρ) = -Tr(ρ ln ρ)"""
    eigvals = np.linalg.eigvalsh(rho)
    eigvals = eigvals[eigvals > 1e-12]  # avoid log(0)
    return -np.sum(eigvals * np.log(eigvals))

def purity(rho):
    """Tr(ρ²) — equals 1 for pure states, < 1 for mixed states."""
    return np.real(np.trace(rho @ rho))

def bloch_vector(rho):
    """Extract Bloch vector (rx, ry, rz) from 2x2 density matrix."""
    rx = 2 * np.real(rho[0, 1])
    ry = 2 * np.imag(rho[1, 0])
    rz = np.real(rho[0, 0] - rho[1, 1])
    return rx, ry, rz

# ============================================================
# 2. Set up the quantum system
# ============================================================

# Hamiltonian (Pauli-X rotation)
omega = 1.0
H = omega * np.array([[0, 1], [1, 0]])  # σ_x

# Initial state: |0⟩ (pure state)
rho_0 = np.array([[1.0, 0.0], [0.0, 0.0]])

# Superposition state: (|0⟩ + |1⟩)/√2
rho_sup = np.array([[0.5, 0.5], [0.5, 0.5]])

# Time array
times = np.linspace(0, 15, 300)

# ============================================================
# 3. Compute evolution
# ============================================================

# Unitary evolution (GROUP)
unitary_entropies = []
unitary_purities = []
unitary_bloch = []
for t in times:
    rho_t = unitary_evolution(rho_sup, H, t)
    unitary_entropies.append(von_neumann_entropy(rho_t))
    unitary_purities.append(purity(rho_t))
    unitary_bloch.append(bloch_vector(rho_t))

# Decoherent evolution (MONOID)
decoherent_entropies = []
decoherent_purities = []
decoherent_bloch = []
for t in times:
    rho_t = decoherence_evolution(rho_sup, H, t, gamma=0.2)
    decoherent_entropies.append(von_neumann_entropy(rho_t))
    decoherent_purities.append(purity(rho_t))
    decoherent_bloch.append(bloch_vector(rho_t))

unitary_bloch = np.array(unitary_bloch)
decoherent_bloch = np.array(decoherent_bloch)

# ============================================================
# 4. Visualize
# ============================================================

fig = plt.figure(figsize=(16, 14))
gs = GridSpec(3, 3, figure=fig, hspace=0.4, wspace=0.35)
fig.suptitle('Quantum Temporal Algebra\n'
             'The Quantum-to-Classical Transition IS the Group-to-Monoid Transition',
             fontsize=15, fontweight='bold', y=0.98)

# --- Panel 1: Von Neumann entropy ---
ax1 = fig.add_subplot(gs[0, 0])
ax1.plot(times, unitary_entropies, color='#2166ac', linewidth=2.5,
         label='Unitary (GROUP)\nS = 0 (pure state)')
ax1.plot(times, decoherent_entropies, color='#b2182b', linewidth=2.5,
         label='Decoherent (MONOID)\nS → ln(2) (mixed)')
ax1.axhline(y=np.log(2), color='gray', linestyle='--', alpha=0.5,
            label=f'Maximum S = ln(2) ≈ {np.log(2):.3f}')
ax1.set_xlabel('Time (t)', fontsize=12)
ax1.set_ylabel('Von Neumann Entropy S(ρ)', fontsize=12)
ax1.set_title('Entropy: Pure vs Decohered',
              fontsize=12, fontweight='bold')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Purity ---
ax2 = fig.add_subplot(gs[0, 1])
ax2.plot(times, unitary_purities, color='#2166ac', linewidth=2.5,
         label='Unitary: Tr(ρ²) = 1 (pure)')
ax2.plot(times, decoherent_purities, color='#b2182b', linewidth=2.5,
         label='Decoherent: Tr(ρ²) → 0.5')
ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='Minimum (maximally mixed)')
ax2.set_xlabel('Time (t)', fontsize=12)
ax2.set_ylabel('Purity Tr(ρ²)', fontsize=12)
ax2.set_title('Purity: Quantum → Classical',
              fontsize=12, fontweight='bold')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.4, 1.1)

# --- Panel 3: The algebraic transition ---
ax3 = fig.add_subplot(gs[0, 2])
ax3.axis('off')

transition_text = (
    "THE TRANSITION\n"
    "━━━━━━━━━━━━━━━\n\n"
    "QUANTUM (pure states):\n"
    "  ρ(t) = U(t) ρ₀ U(t)†\n"
    "  U(t) = e^{-iHt}\n"
    "  U(t)† = U(-t) ← INVERSE!\n"
    "  ⟹ temporal GROUP\n"
    "  S(ρ) = 0 (constant)\n\n"
    "CLASSICAL (mixed states):\n"
    "  ρ(t) = Λ(t)[ρ₀]\n"
    "  Λ(t) is CPTP map\n"
    "  Λ(t)⁻¹ does NOT exist\n"
    "  ⟹ temporal MONOID\n"
    "  S(ρ) ↑ (increasing)\n\n"
    "DECOHERENCE is the\n"
    "algebraic degradation\n"
    "from GROUP → MONOID."
)
ax3.text(0.05, 0.95, transition_text, transform=ax3.transAxes,
         fontsize=9.5, va='top', family='monospace',
         bbox=dict(boxstyle='round', facecolor='#fff3e0',
                  edgecolor='orange', alpha=0.95))

# --- Panel 4: Bloch sphere (unitary) ---
ax4 = fig.add_subplot(gs[1, 0], projection='3d')

# Draw Bloch sphere wireframe
u = np.linspace(0, 2 * np.pi, 50)
v = np.linspace(0, np.pi, 30)
x_sphere = np.outer(np.cos(u), np.sin(v))
y_sphere = np.outer(np.sin(u), np.sin(v))
z_sphere = np.outer(np.ones(np.size(u)), np.cos(v))
ax4.plot_wireframe(x_sphere, y_sphere, z_sphere, alpha=0.08, color='gray')

# Plot unitary trajectory (stays on surface)
ax4.plot(unitary_bloch[:, 0], unitary_bloch[:, 1], unitary_bloch[:, 2],
         color='#2166ac', linewidth=2, label='Unitary (on surface)')
ax4.scatter([unitary_bloch[0, 0]], [unitary_bloch[0, 1]], [unitary_bloch[0, 2]],
            color='#2166ac', s=50, marker='o')

ax4.set_xlabel('r_x', fontsize=9)
ax4.set_ylabel('r_y', fontsize=9)
ax4.set_zlabel('r_z', fontsize=9)
ax4.set_title('Bloch Sphere: Unitary\n(stays on surface = pure)',
              fontsize=11, fontweight='bold', color='#2166ac')

# --- Panel 5: Bloch sphere (decoherent) ---
ax5 = fig.add_subplot(gs[1, 1], projection='3d')

ax5.plot_wireframe(x_sphere, y_sphere, z_sphere, alpha=0.08, color='gray')

# Plot decoherent trajectory (spirals inward)
ax5.plot(decoherent_bloch[:, 0], decoherent_bloch[:, 1], decoherent_bloch[:, 2],
         color='#b2182b', linewidth=2, label='Decoherent (spirals in)')
ax5.scatter([decoherent_bloch[0, 0]], [decoherent_bloch[0, 1]], [decoherent_bloch[0, 2]],
            color='#b2182b', s=50, marker='o')
ax5.scatter([0], [0], [0], color='black', s=80, marker='*', label='Maximally mixed')

ax5.set_xlabel('r_x', fontsize=9)
ax5.set_ylabel('r_y', fontsize=9)
ax5.set_zlabel('r_z', fontsize=9)
ax5.set_title('Bloch Sphere: Decoherent\n(spirals to center = mixed)',
              fontsize=11, fontweight='bold', color='#b2182b')

# --- Panel 6: Bloch vector magnitude ---
ax6 = fig.add_subplot(gs[1, 2])
bloch_mag_unitary = np.sqrt(unitary_bloch[:, 0]**2 + unitary_bloch[:, 1]**2 + unitary_bloch[:, 2]**2)
bloch_mag_decoherent = np.sqrt(decoherent_bloch[:, 0]**2 + decoherent_bloch[:, 1]**2 + decoherent_bloch[:, 2]**2)

ax6.plot(times, bloch_mag_unitary, color='#2166ac', linewidth=2.5,
         label='Unitary: |r| = 1 (pure)')
ax6.plot(times, bloch_mag_decoherent, color='#b2182b', linewidth=2.5,
         label='Decoherent: |r| → 0 (mixed)')
ax6.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax6.set_xlabel('Time (t)', fontsize=12)
ax6.set_ylabel('Bloch vector magnitude |r|', fontsize=12)
ax6.set_title('Quantum Coherence Decay',
              fontsize=12, fontweight='bold')
ax6.legend(fontsize=9)
ax6.grid(True, alpha=0.3)
ax6.set_ylim(-0.1, 1.2)

# --- Row 3: Density matrix elements ---
ax7 = fig.add_subplot(gs[2, :2])

# Track ρ₀₁ (off-diagonal = coherence)
rho_01_unitary = []
rho_01_decoherent = []
rho_00_unitary = []
rho_00_decoherent = []

for t in times:
    rho_u = unitary_evolution(rho_sup, H, t)
    rho_d = decoherence_evolution(rho_sup, H, t, gamma=0.2)
    rho_01_unitary.append(np.abs(rho_u[0, 1]))
    rho_01_decoherent.append(np.abs(rho_d[0, 1]))
    rho_00_unitary.append(np.real(rho_u[0, 0]))
    rho_00_decoherent.append(np.real(rho_d[0, 0]))

ax7.plot(times, rho_01_unitary, color='#2166ac', linewidth=2,
         label='|ρ₀₁| unitary (oscillates forever)')
ax7.plot(times, rho_01_decoherent, color='#b2182b', linewidth=2,
         label='|ρ₀₁| decoherent (→ 0)')
ax7.plot(times, rho_00_unitary, '--', color='#2166ac', linewidth=1.5,
         label='ρ₀₀ unitary (oscillates)', alpha=0.7)
ax7.plot(times, rho_00_decoherent, '--', color='#b2182b', linewidth=1.5,
         label='ρ₀₀ decoherent (→ 0.5)', alpha=0.7)

ax7.set_xlabel('Time (t)', fontsize=12)
ax7.set_ylabel('Matrix element magnitude', fontsize=12)
ax7.set_title('Density Matrix Elements: Coherence Death = Arrow of Time Birth',
              fontsize=12, fontweight='bold')
ax7.legend(fontsize=9, ncol=2, loc='upper right')
ax7.grid(True, alpha=0.3)

ax7.annotate('OFF-DIAGONAL → 0\n= decoherence\n= GROUP → MONOID\n= birth of arrow of time',
             xy=(12, 0.05), fontsize=10, fontweight='bold',
             ha='center', color='#b2182b',
             bbox=dict(boxstyle='round', facecolor='white',
                      edgecolor='#b2182b', alpha=0.9))

# --- Panel 8: Summary ---
ax8 = fig.add_subplot(gs[2, 2])
ax8.axis('off')

summary = (
    "QUANTUM TIME ALGEBRA\n"
    "━━━━━━━━━━━━━━━━━━━━\n\n"
    "Pure QM:\n"
    "  • Evolution: U(t) = e^{-iHt}\n"
    "  • U(t)⁻¹ = U(-t)  ✓ GROUP\n"
    "  • S(ρ) = 0 (constant)\n"
    "  • No arrow of time\n\n"
    "QM + Environment:\n"
    "  • Evolution: CPTP map Λ(t)\n"
    "  • Λ(t)⁻¹ ∄   ✗ MONOID\n"
    "  • S(ρ) ↑ (increases)\n"
    "  • Arrow of time emerges!\n\n"
    "Key insight:\n"
    "  Decoherence kills the\n"
    "  GROUP structure of time,\n"
    "  leaving only a MONOID.\n\n"
    "  classicality = monoid\n"
    "  quantumness = group"
)
ax8.text(0.05, 0.95, summary, transform=ax8.transAxes,
         fontsize=9, va='top', family='monospace',
         bbox=dict(boxstyle='round', facecolor='#e8f5e9',
                  edgecolor='green', alpha=0.95))

plt.savefig('/workspace/request-project/AlgebraicTime/demos/quantum_time.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: quantum_time.png")
