#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Interactive Demo

Demonstrates the Quantum EML Gate Algebra:
- BCH defect computation for 2x2 matrices
- Quantum EML channel action
- Comparison of quantum vs classical (commutative) EML
- Diagonal spectral bridge verification
"""

import numpy as np
from scipy.linalg import expm

# ─── Core Definitions ─────────────────────────────────────────────────

def qeml_eval(h1: np.ndarray, h2: np.ndarray) -> np.ndarray:
    """Quantum EML gate value: exp(h1) * exp(h2)."""
    return expm(h1) @ expm(h2)

def bch_defect(h1: np.ndarray, h2: np.ndarray) -> np.ndarray:
    """BCH defect: exp(h1)*exp(h2) - exp(h1+h2). Zero iff [h1,h2]=0."""
    return expm(h1) @ expm(h2) - expm(h1 + h2)

def qeml_channel(h: np.ndarray, rho: np.ndarray) -> np.ndarray:
    """Quantum EML channel: rho -> exp(h) * rho * exp(-h)."""
    E = expm(h)
    Em = expm(-h)
    return E @ rho @ Em

def qeml_neuron(h: np.ndarray, t: float, rho: np.ndarray) -> np.ndarray:
    """Full QEML neuron: exp(h)*rho*exp(-h) + t*I."""
    n = h.shape[0]
    return qeml_channel(h, rho) + t * np.eye(n)

def commutator(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Matrix commutator [A, B] = AB - BA."""
    return A @ B - B @ A

# ─── Pauli Matrices ───────────────────────────────────────────────────

sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)

# ─── Demo 1: BCH Defect as Noncommutativity Witness ──────────────────

print("=" * 60)
print("DEMO 1: BCH Defect — Noncommutativity Witness")
print("=" * 60)

# Commuting case: diagonal matrices
h1_comm = np.diag([1.0, 2.0]).astype(complex)
h2_comm = np.diag([3.0, 4.0]).astype(complex)
defect_comm = bch_defect(h1_comm, h2_comm)
print(f"\nCommuting case (diagonal matrices):")
print(f"  ||BCH defect|| = {np.linalg.norm(defect_comm):.2e}")
print(f"  (Expected: ~0, since diagonal matrices commute)")

# Non-commuting case: Pauli matrices
h1_nc = 0.5 * sigma_x
h2_nc = 0.3 * sigma_z
defect_nc = bch_defect(h1_nc, h2_nc)
print(f"\nNon-commuting case (Pauli matrices):")
print(f"  h1 = 0.5 * σ_x, h2 = 0.3 * σ_z")
print(f"  ||BCH defect|| = {np.linalg.norm(defect_nc):.6f}")
print(f"  ||[h1, h2]||   = {np.linalg.norm(commutator(h1_nc, h2_nc)):.6f}")
print(f"  (Nonzero defect ↔ nonzero commutator: quantum correction!)")

# Verify: defect(h, -h) = 0
defect_self = bch_defect(h1_nc, -h1_nc)
print(f"\nSelf-inverse: ||bchDefect(h, -h)|| = {np.linalg.norm(defect_self):.2e}")

# ─── Demo 2: BCH Defect Symmetry Relation ────────────────────────────

print("\n" + "=" * 60)
print("DEMO 2: BCH Defect Symmetry ↔ Exponential Commutator")
print("=" * 60)

h1 = 0.4 * sigma_x + 0.2 * sigma_y
h2 = 0.3 * sigma_z + 0.1 * sigma_y
d12 = bch_defect(h1, h2)
d21 = bch_defect(h2, h1)
exp_comm = expm(h1) @ expm(h2) - expm(h2) @ expm(h1)

print(f"\n  bchDefect(h1,h2) - bchDefect(h2,h1)  vs  [exp(h1), exp(h2)]")
print(f"  ||difference|| = {np.linalg.norm((d12 - d21) - exp_comm):.2e}")
print(f"  (Theorem: these are equal — verified!)")

# ─── Demo 3: Quantum EML Channel Properties ─────────────────────────

print("\n" + "=" * 60)
print("DEMO 3: Quantum EML Channel Properties")
print("=" * 60)

h = 0.7 * sigma_x + 0.3 * sigma_z

# Channel preserves identity
ch_id = qeml_channel(h, I2)
print(f"\nChannel preserves identity:")
print(f"  ||Φ_h(I) - I|| = {np.linalg.norm(ch_id - I2):.2e}")

# Channel is multiplicative
rho1 = np.array([[1, 0.5], [0.5, 1]], dtype=complex)
rho2 = np.array([[0.8, 0.2j], [-0.2j, 0.6]], dtype=complex)
lhs = qeml_channel(h, rho1 @ rho2)
rhs = qeml_channel(h, rho1) @ qeml_channel(h, rho2)
print(f"\nChannel multiplicativity:")
print(f"  ||Φ_h(ρ₁ρ₂) - Φ_h(ρ₁)Φ_h(ρ₂)|| = {np.linalg.norm(lhs - rhs):.2e}")

# Channel preserves trace (for trace-class operators)
print(f"\nTrace preservation:")
print(f"  tr(ρ₁)     = {np.trace(rho1):.4f}")
print(f"  tr(Φ_h(ρ₁)) = {np.trace(qeml_channel(h, rho1)):.4f}")

# ─── Demo 4: Diagonal Spectral Bridge ────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 4: Diagonal Spectral Bridge — Quantum ↔ Classical EML")
print("=" * 60)

a1, a2 = 1.0 + 0.5j, 0.3 - 0.2j
b1, b2 = 0.7 + 0.1j, -0.4 + 0.3j
D1 = np.diag([a1, a2])
D2 = np.diag([b1, b2])

# Quantum computation
quantum_result = expm(D1) @ expm(D2)

# Classical (scalar) computation applied to eigenvalues
classical_result = np.diag([np.exp(a1) * np.exp(b1), np.exp(a2) * np.exp(b2)])

print(f"\n  ||exp(D1)*exp(D2) - diag(exp(a₁)exp(b₁), exp(a₂)exp(b₂))|| = "
      f"{np.linalg.norm(quantum_result - classical_result):.2e}")
print(f"  → Diagonal case: quantum EML = scalar EML on eigenvalues!")

# ─── Demo 5: QEML Neuron Action ──────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 5: QEML Neuron = Rotation + Bias")
print("=" * 60)

h_rot = 0.5 * sigma_z  # Rotation around z-axis
rho = 0.5 * (I2 + 0.6 * sigma_x + 0.3 * sigma_y + 0.1 * sigma_z)  # Bloch vector state
bias = 0.2

neuron_out = qeml_neuron(h_rot, bias, rho)
channel_out = qeml_channel(h_rot, rho)

print(f"\n  Input state ρ: tr = {np.trace(rho):.4f}")
print(f"  Channel output Φ_h(ρ): tr = {np.trace(channel_out):.4f}")
print(f"  Neuron output (bias={bias}): tr = {np.trace(neuron_out):.4f}")
print(f"  Expected tr(neuron) = tr(Φ) + 2*bias = "
      f"{np.trace(channel_out).real + 2*bias:.4f}")

# ─── Demo 6: Gate Composition and Circuit Depth ──────────────────────

print("\n" + "=" * 60)
print("DEMO 6: QEML Circuit — Composing Gates")
print("=" * 60)

# Build a 3-layer QEML circuit
gates = [
    (0.3 * sigma_x, 0.2 * sigma_z),
    (0.1 * sigma_y, -0.4 * sigma_x),
    (0.5 * sigma_z, 0.1 * sigma_y),
]

circuit_value = I2
total_norm = 0
for h1, h2 in gates:
    gate_val = qeml_eval(h1, h2)
    circuit_value = circuit_value @ gate_val
    total_norm += np.linalg.norm(h1) + np.linalg.norm(h2)

print(f"\n  Circuit depth: {len(gates)}")
print(f"  Total parameter norm: {total_norm:.4f}")
print(f"  ||Circuit value||: {np.linalg.norm(circuit_value):.4f}")
print(f"  det(Circuit): {np.linalg.det(circuit_value):.4f}")

# ─── Demo 7: Scaling of BCH Defect ───────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 7: BCH Defect Scaling with Parameter Magnitude")
print("=" * 60)

scales = [0.01, 0.1, 0.5, 1.0, 2.0, 5.0]
h1_base = sigma_x
h2_base = sigma_z
print(f"\n  {'Scale ε':>10s}  {'||bchDefect(εσx, εσz)||':>25s}  {'||[εσx, εσz]||':>18s}  {'Ratio':>10s}")
print(f"  {'-'*10}  {'-'*25}  {'-'*18}  {'-'*10}")
for eps in scales:
    defect_norm = np.linalg.norm(bch_defect(eps * h1_base, eps * h2_base))
    comm_norm = np.linalg.norm(commutator(eps * h1_base, eps * h2_base))
    ratio = defect_norm / comm_norm if comm_norm > 1e-15 else float('inf')
    print(f"  {eps:10.3f}  {defect_norm:25.6e}  {comm_norm:18.6e}  {ratio:10.4f}")

print(f"\n  → At small ε, bchDefect ≈ ½[h1,h2] (BCH first-order correction)")
print(f"  → Ratio converges to ~0.5 as ε → 0")

print("\n" + "=" * 60)
print("All demos complete. Quantum EML Activation Functions verified.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: BCH Defect Scaling — Noncommutativity in Quantum EML

Plots how the BCH defect ||exp(εX)*exp(εY) - exp(ε(X+Y))|| scales
with the parameter magnitude ε, demonstrating the quantum correction.
"""

import numpy as np
from scipy.linalg import expm
import matplotlib.pyplot as plt

def bch_defect_norm(h1, h2):
    return np.linalg.norm(expm(h1) @ expm(h2) - expm(h1 + h2))

def commutator_norm(h1, h2):
    return np.linalg.norm(h1 @ h2 - h2 @ h1)

# Pauli matrices
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)

epsilons = np.linspace(0.01, 3.0, 200)

# Pair 1: σ_x, σ_z
defects_xz = [bch_defect_norm(eps * sigma_x, eps * sigma_z) for eps in epsilons]
comms_xz = [commutator_norm(eps * sigma_x, eps * sigma_z) for eps in epsilons]
half_comms_xz = [0.5 * c for c in comms_xz]

# Pair 2: σ_x, σ_y
defects_xy = [bch_defect_norm(eps * sigma_x, eps * sigma_y) for eps in epsilons]

# Pair 3: Commuting (both σ_z)
defects_comm = [bch_defect_norm(eps * sigma_z, eps * sigma_z) for eps in epsilons]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: BCH defect for different matrix pairs
ax1 = axes[0]
ax1.plot(epsilons, defects_xz, 'b-', linewidth=2, label=r'$\|D(\varepsilon\sigma_x, \varepsilon\sigma_z)\|$')
ax1.plot(epsilons, defects_xy, 'r-', linewidth=2, label=r'$\|D(\varepsilon\sigma_x, \varepsilon\sigma_y)\|$')
ax1.plot(epsilons, defects_comm, 'g--', linewidth=2, label=r'$\|D(\varepsilon\sigma_z, \varepsilon\sigma_z)\| = 0$')
ax1.plot(epsilons, half_comms_xz, 'b:', linewidth=1.5, alpha=0.7, label=r'$\frac{1}{2}\|[\varepsilon\sigma_x, \varepsilon\sigma_z]\|$ (BCH approx)')
ax1.set_xlabel(r'Parameter magnitude $\varepsilon$', fontsize=12)
ax1.set_ylabel('BCH defect norm', fontsize=12)
ax1.set_title('BCH Defect: Noncommutativity Witness', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Right panel: Ratio of defect to commutator (approaches 0.5)
ratios = [d / c if c > 1e-15 else np.nan for d, c in zip(defects_xz, comms_xz)]
ax2 = axes[1]
ax2.plot(epsilons, ratios, 'b-', linewidth=2)
ax2.axhline(y=0.5, color='r', linestyle='--', linewidth=1, alpha=0.7, label=r'$\frac{1}{2}$ (BCH prediction)')
ax2.set_xlabel(r'Parameter magnitude $\varepsilon$', fontsize=12)
ax2.set_ylabel(r'$\|D\| / \|[h_1, h_2]\|$', fontsize=12)
ax2.set_title('BCH Defect / Commutator Ratio', fontsize=14)
ax2.set_ylim(0, 1.5)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('bch_defect_scaling.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved bch_defect_scaling.png")


#!/usr/bin/env python3
"""
Visualization: Quantum EML Channel Action on the Bloch Sphere

Shows how the QEML channel ρ → exp(h)·ρ·exp(-h) rotates quantum states
on the Bloch sphere, with different generator matrices h.
"""

import numpy as np
from scipy.linalg import expm
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def bloch_vector(rho):
    """Extract Bloch vector (rx, ry, rz) from 2x2 density matrix."""
    sx = np.array([[0, 1], [1, 0]], dtype=complex)
    sy = np.array([[0, -1j], [1j, 0]], dtype=complex)
    sz = np.array([[1, 0], [0, -1]], dtype=complex)
    rx = np.real(np.trace(rho @ sx))
    ry = np.real(np.trace(rho @ sy))
    rz = np.real(np.trace(rho @ sz))
    return rx, ry, rz

def qeml_channel(h, rho):
    E = expm(h)
    Em = expm(-h)
    return E @ rho @ Em

sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)

# Generate initial states on the Bloch sphere
n_states = 50
phi = np.linspace(0, 2*np.pi, n_states)
theta = np.linspace(0, np.pi, n_states)
initial_bloch = []
for t in theta[1:-1:3]:
    for p in phi[::3]:
        rx = np.sin(t) * np.cos(p)
        ry = np.sin(t) * np.sin(p)
        rz = np.cos(t)
        initial_bloch.append((rx, ry, rz))

# Different QEML channels
channels = {
    r'$h = 0.5i\sigma_z$ (Z-rotation)': 0.5j * sigma_z,
    r'$h = 0.3i\sigma_x$ (X-rotation)': 0.3j * sigma_x,
    r'$h = 0.4i(\sigma_x + \sigma_z)$ (Mixed)': 0.4j * (sigma_x + sigma_z),
}

fig = plt.figure(figsize=(15, 5))

for idx, (label, h) in enumerate(channels.items()):
    ax = fig.add_subplot(1, 3, idx + 1, projection='3d')

    # Draw Bloch sphere wireframe
    u = np.linspace(0, 2 * np.pi, 30)
    v = np.linspace(0, np.pi, 20)
    xs = np.outer(np.cos(u), np.sin(v))
    ys = np.outer(np.sin(u), np.sin(v))
    zs = np.outer(np.ones_like(u), np.cos(v))
    ax.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')

    # Plot initial and transformed states
    for rx, ry, rz in initial_bloch:
        rho = 0.5 * (I2 + rx * sigma_x + ry * sigma_y + rz * sigma_z)
        rho_out = qeml_channel(h, rho)
        rx2, ry2, rz2 = bloch_vector(rho_out)

        ax.scatter(rx, ry, rz, c='blue', s=15, alpha=0.4)
        ax.scatter(rx2, ry2, rz2, c='red', s=15, alpha=0.6)
        ax.plot([rx, rx2], [ry, ry2], [rz, rz2], 'k-', alpha=0.1, linewidth=0.5)

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.set_title(label, fontsize=10)
    ax.set_xlim([-1.1, 1.1])
    ax.set_ylim([-1.1, 1.1])
    ax.set_zlim([-1.1, 1.1])

plt.suptitle('Quantum EML Channel: Bloch Sphere Rotations', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('channel_bloch_sphere.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved channel_bloch_sphere.png")
