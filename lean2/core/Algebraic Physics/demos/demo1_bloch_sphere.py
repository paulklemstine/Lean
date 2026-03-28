"""
Demo 1: The Bloch Sphere — States of the Qubit Algebra M₂(ℂ)

The algebra of a single qubit is M₂(ℂ), the algebra of 2×2 complex matrices.
States (density matrices) are parameterized by the Bloch sphere S².

This demonstrates Pillar I: Observable Algebras — how the state space of a 
C*-algebra has rich geometric structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import proj3d

# ============================================================
# The Qubit Algebra M₂(ℂ)
# ============================================================

# Pauli matrices — basis of the Lie algebra su(2)
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)

def density_matrix(theta, phi):
    """Construct density matrix for a pure state on the Bloch sphere.
    
    ρ = (1/2)(I + nx σx + ny σy + nz σz)
    where (nx, ny, nz) = (sin θ cos φ, sin θ sin φ, cos θ)
    """
    nx = np.sin(theta) * np.cos(phi)
    ny = np.sin(theta) * np.sin(phi)
    nz = np.cos(theta)
    return 0.5 * (I2 + nx * sigma_x + ny * sigma_y + nz * sigma_z)

def von_neumann_entropy(rho):
    """Compute von Neumann entropy S = -Tr(ρ ln ρ)."""
    eigenvalues = np.linalg.eigvalsh(rho)
    eigenvalues = eigenvalues[eigenvalues > 1e-12]  # avoid log(0)
    return -np.sum(eigenvalues * np.log2(eigenvalues))

def expectation(rho, observable):
    """Compute ⟨A⟩ = Tr(ρA) — the algebraic expectation value."""
    return np.real(np.trace(rho @ observable))

# ============================================================
# Figure 1: The Bloch Sphere
# ============================================================

fig = plt.figure(figsize=(16, 12))
fig.suptitle('The Algebraic Theory of Physics: Qubit as C*-Algebra M₂(ℂ)', 
             fontsize=16, fontweight='bold')

# --- Panel 1: Bloch Sphere with key states ---
ax1 = fig.add_subplot(221, projection='3d')

# Draw sphere wireframe
u = np.linspace(0, 2 * np.pi, 40)
v = np.linspace(0, np.pi, 20)
x_sphere = np.outer(np.cos(u), np.sin(v))
y_sphere = np.outer(np.sin(u), np.sin(v))
z_sphere = np.outer(np.ones(np.size(u)), np.cos(v))

ax1.plot_surface(x_sphere, y_sphere, z_sphere, alpha=0.08, color='cyan')
ax1.plot_wireframe(x_sphere, y_sphere, z_sphere, alpha=0.1, color='gray', linewidth=0.3)

# Draw axes
ax1.plot([-1.3, 1.3], [0, 0], [0, 0], 'k-', alpha=0.3, linewidth=0.5)
ax1.plot([0, 0], [-1.3, 1.3], [0, 0], 'k-', alpha=0.3, linewidth=0.5)
ax1.plot([0, 0], [0, 0], [-1.3, 1.3], 'k-', alpha=0.3, linewidth=0.5)

# Key quantum states
states = {
    '|0⟩': (0, 0, 1),          # spin up
    '|1⟩': (0, 0, -1),         # spin down
    '|+⟩': (1, 0, 0),          # superposition +
    '|−⟩': (-1, 0, 0),         # superposition -
    '|+i⟩': (0, 1, 0),         # +y eigenstate
    '|−i⟩': (0, -1, 0),        # -y eigenstate
}

colors = ['red', 'blue', 'green', 'orange', 'purple', 'brown']
for (name, (x, y, z)), color in zip(states.items(), colors):
    ax1.scatter([x], [y], [z], c=color, s=80, zorder=5)
    ax1.text(x*1.15, y*1.15, z*1.15, name, fontsize=10, fontweight='bold', color=color)

# Mixed state at origin
ax1.scatter([0], [0], [0], c='black', s=50, marker='x', zorder=5)
ax1.text(0.1, 0.1, 0.1, 'ρ=I/2\n(maximally\nmixed)', fontsize=8, color='black')

ax1.set_xlabel('⟨σx⟩')
ax1.set_ylabel('⟨σy⟩')
ax1.set_zlabel('⟨σz⟩')
ax1.set_title('Bloch Sphere: State Space S(M₂(ℂ))', fontweight='bold')
ax1.set_xlim([-1.4, 1.4])
ax1.set_ylim([-1.4, 1.4])
ax1.set_zlim([-1.4, 1.4])

# --- Panel 2: Entropy as function of Bloch vector radius ---
ax2 = fig.add_subplot(222)

radii = np.linspace(0, 1, 100)
entropies = []
for r in radii:
    # Density matrix with Bloch vector (0, 0, r)
    rho = 0.5 * (I2 + r * sigma_z)
    entropies.append(von_neumann_entropy(rho))

ax2.plot(radii, entropies, 'b-', linewidth=2.5)
ax2.fill_between(radii, entropies, alpha=0.15, color='blue')
ax2.set_xlabel('Bloch vector radius |r⃗|', fontsize=12)
ax2.set_ylabel('Von Neumann Entropy S(ρ) [bits]', fontsize=12)
ax2.set_title('Entropy: Pure States (r=1) vs Mixed States (r<1)', fontweight='bold')
ax2.axvline(x=1, color='red', linestyle='--', alpha=0.5, label='Pure states (S=0)')
ax2.axvline(x=0, color='green', linestyle='--', alpha=0.5, label='Maximally mixed (S=1)')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim([0, 1])
ax2.set_ylim([0, 1.1])

# --- Panel 3: Time evolution under Hamiltonian (algebra automorphism) ---
ax3 = fig.add_subplot(223)

# Hamiltonian H = ω σz / 2 (precession about z-axis)
omega = 2 * np.pi  # one full rotation
times = np.linspace(0, 2, 200)
theta_0 = np.pi / 3  # initial polar angle

# Initial state: |ψ⟩ at angle θ₀ from z-axis
exp_x = np.sin(theta_0) * np.cos(omega * times)
exp_y = np.sin(theta_0) * np.sin(omega * times)
exp_z = np.cos(theta_0) * np.ones_like(times)

ax3.plot(times, exp_x, 'r-', linewidth=2, label='⟨σx⟩(t)')
ax3.plot(times, exp_y, 'g-', linewidth=2, label='⟨σy⟩(t)')
ax3.plot(times, exp_z, 'b-', linewidth=2, label='⟨σz⟩(t) = const')
ax3.set_xlabel('Time t', fontsize=12)
ax3.set_ylabel('Expectation Value', fontsize=12)
ax3.set_title('Heisenberg Evolution: αₜ(a) = e^{iHt} a e^{-iHt}', fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.text(0.5, -0.7, '⟨σz⟩ is conserved: [H, σz] = 0\n(Algebraic Noether\'s theorem)', 
         fontsize=10, style='italic', 
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# --- Panel 4: Commutator structure ---
ax4 = fig.add_subplot(224)

# Show the Lie algebra structure [σi, σj] = 2i εijk σk
algebra_text = (
    "The Qubit Algebra M₂(ℂ)\n\n"
    "Basis: {I, σx, σy, σz}\n\n"
    "Commutation Relations:\n"
    "  [σx, σy] = 2i σz\n"
    "  [σy, σz] = 2i σx\n"
    "  [σz, σx] = 2i σy\n\n"
    "This is the Lie algebra su(2) ≅ so(3)\n\n"
    "Anticommutation Relations:\n"
    "  {σi, σj} = 2δij I\n\n"
    "Together: σi σj = δij I + i εijk σk\n\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    "Physical Meaning:\n"
    "• Noncommutativity ⟹ uncertainty principle\n"
    "• [σx, σz] ≠ 0 ⟹ ΔSx · ΔSz ≥ ½|⟨σy⟩|\n"
    "• Algebra determines ALL physics of spin"
)
ax4.text(0.05, 0.95, algebra_text, transform=ax4.transAxes, fontsize=11,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax4.axis('off')
ax4.set_title('Algebraic Structure', fontweight='bold')

plt.tight_layout()
plt.savefig('/workspace/request-project/figures/demo1_bloch_sphere.png', dpi=150, bbox_inches='tight')
plt.close()
print("✅ Figure saved: figures/demo1_bloch_sphere.png")

# ============================================================
# Verification: algebraic properties
# ============================================================
print("\n" + "="*60)
print("ALGEBRAIC VERIFICATION")
print("="*60)

# Verify Pauli algebra
print("\nPauli algebra relations:")
print(f"  σx² = I: {np.allclose(sigma_x @ sigma_x, I2)}")
print(f"  σy² = I: {np.allclose(sigma_y @ sigma_y, I2)}")
print(f"  σz² = I: {np.allclose(sigma_z @ sigma_z, I2)}")
print(f"  [σx,σy] = 2iσz: {np.allclose(sigma_x @ sigma_y - sigma_y @ sigma_x, 2j * sigma_z)}")

# Verify density matrix properties  
rho_pure = density_matrix(np.pi/4, np.pi/3)
rho_mixed = 0.5 * I2
print(f"\nPure state ρ:")
print(f"  Tr(ρ) = {np.real(np.trace(rho_pure)):.4f} (should be 1)")
print(f"  Tr(ρ²) = {np.real(np.trace(rho_pure @ rho_pure)):.4f} (should be 1 for pure)")
print(f"  S(ρ) = {von_neumann_entropy(rho_pure):.4f} bits (should be 0)")
print(f"\nMaximally mixed state ρ = I/2:")
print(f"  Tr(ρ) = {np.real(np.trace(rho_mixed)):.4f}")
print(f"  Tr(ρ²) = {np.real(np.trace(rho_mixed @ rho_mixed)):.4f} (should be 0.5)")
print(f"  S(ρ) = {von_neumann_entropy(rho_mixed):.4f} bits (should be 1)")
