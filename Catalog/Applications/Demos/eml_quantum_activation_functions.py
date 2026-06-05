#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Demonstration

This script demonstrates the key results from the quantum EML research:
1. Phase surjectivity: any target angle is achievable
2. Classical-quantum bridge: exp-log cancellation lifts to phases
3. Gap bound: quantum error bounded by classical EML squared
4. Exact compilation: explicit formula for any U(1) rotation
"""

import numpy as np

def eml(x: float, y: float) -> float:
    """Classical EML activation: exp(x) - log(y)"""
    return np.exp(x) - np.log(y)

def quantum_eml_phase(x: float, y: float) -> complex:
    """Quantum EML phase map: exp(i * eml(x, y))"""
    return np.exp(1j * eml(x, y))

def quantum_eml_full(r: float, x: float, y: float) -> complex:
    """Full quantum EML with amplitude control"""
    return r * np.exp(1j * eml(x, y))

def quantum_eml_gap(x: float, y: float) -> float:
    """Gate error relative to identity: |exp(i*eml) - 1|^2"""
    z = quantum_eml_phase(x, y)
    return abs(z - 1) ** 2

def quantum_eml_fidelity(x: float, y: float, alpha: float) -> float:
    """Fidelity with target phase exp(i*alpha)"""
    return np.cos(eml(x, y) - alpha)

def compile_gate(alpha: float) -> tuple:
    """Compile U(1) rotation by angle alpha as quantum EML parameters.
    Returns (x, y) such that quantumEMLPhase(x, y) = exp(i*alpha)."""
    return (0.0, np.exp(1 - alpha))

def inverse_gate(x: float, y: float) -> tuple:
    """Find parameters for the inverse gate."""
    phase = eml(x, y)
    return compile_gate(-phase)

# ============================================================
# Demo 1: Phase Surjectivity
# ============================================================
print("=" * 60)
print("DEMO 1: Quantum EML Phase Surjectivity")
print("=" * 60)
print("\nFor any target angle α, we can find y > 0 such that")
print("quantumEMLPhase(0, y) = exp(iα)")
print()

targets = [0, np.pi/6, np.pi/4, np.pi/3, np.pi/2, np.pi, 3*np.pi/2, 2*np.pi]
labels = ["0", "π/6", "π/4", "π/3", "π/2", "π", "3π/2", "2π"]

for alpha, label in zip(targets, labels):
    x, y = compile_gate(alpha)
    z = quantum_eml_phase(x, y)
    target = np.exp(1j * alpha)
    error = abs(z - target)
    print(f"  α = {label:>5s}: y = {y:.6f}, phase = {z:.6f}, target = {target:.6f}, error = {error:.2e}")

# ============================================================
# Demo 2: Classical-Quantum Bridge
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Classical-Quantum Bridge")
print("=" * 60)
print("\neml(log(a), exp(b)) = a - b lifts to:")
print("quantumEMLPhase(log(a), exp(b)) = exp(i(a-b))")
print()

test_cases = [(2.0, 1.0), (3.0, 0.5), (np.e, np.pi), (10.0, 7.0)]
for a, b in test_cases:
    classical = eml(np.log(a), np.exp(b))
    quantum = quantum_eml_phase(np.log(a), np.exp(b))
    expected = np.exp(1j * (a - b))
    print(f"  a={a:.2f}, b={b:.2f}: eml={classical:.6f}, a-b={a-b:.6f}, "
          f"quantum={quantum:.4f}, expected={expected:.4f}, match={abs(quantum-expected)<1e-10}")

# ============================================================
# Demo 3: Gap Bound
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Quantum-Classical Gap Bound")
print("=" * 60)
print("\n|exp(i·eml(x,y)) - 1|² ≤ eml(x,y)²")
print()

test_params = [(0, 0.5), (0, 1), (0, 2), (1, 1), (0.5, 0.5), (2, 0.1)]
for x, y in test_params:
    gap = quantum_eml_gap(x, y)
    eml_val = eml(x, y)
    bound = eml_val ** 2
    ratio = gap / bound if bound > 0 else 0
    print(f"  eml({x},{y}) = {eml_val:>8.4f}: gap = {gap:>8.4f}, "
          f"bound = {bound:>10.4f}, ratio = {ratio:.4f}")

# ============================================================
# Demo 4: Phase Composition
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Phase Composition Law")
print("=" * 60)
print("\nquantumEMLPhase(x₁,y₁) · quantumEMLPhase(x₂,y₂)")
print("= exp(i · (eml(x₁,y₁) + eml(x₂,y₂)))")
print()

compositions = [((0, 1), (0, 2)), ((1, 1), (0, 0.5)), ((0.5, 2), (1.5, 3))]
for (x1, y1), (x2, y2) in compositions:
    product = quantum_eml_phase(x1, y1) * quantum_eml_phase(x2, y2)
    sum_eml = eml(x1, y1) + eml(x2, y2)
    expected = np.exp(1j * sum_eml)
    print(f"  ({x1},{y1}) ∘ ({x2},{y2}): product={product:.4f}, "
          f"expected={expected:.4f}, match={abs(product-expected)<1e-10}")

# ============================================================
# Demo 5: Gate Inversion
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Gate Inversion")
print("=" * 60)
print("\nEvery quantum EML gate has an inverse that is also a quantum EML gate")
print()

gate_params = [(0, 1), (1, 2), (0.5, 0.3)]
for x, y in gate_params:
    gate = quantum_eml_phase(x, y)
    x_inv, y_inv = inverse_gate(x, y)
    inv_gate = quantum_eml_phase(x_inv, y_inv)
    product = gate * inv_gate
    print(f"  gate({x},{y}) = {gate:.4f}, inv({x_inv:.2f},{y_inv:.4f}) = {inv_gate:.4f}, "
          f"product = {product:.4f} ≈ 1")

# ============================================================
# Demo 6: Full Coverage of ℂ\{0}
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Full Coverage of ℂ\\{0}")
print("=" * 60)
print("\nquantumEMLFull(r, x, y) = r · exp(i · eml(x,y)) covers all z ≠ 0")
print()

targets_c = [1+1j, -3+4j, 0.5-0.5j, 2j, -1]
for z in targets_c:
    r = abs(z)
    alpha = np.angle(z)
    x, y = compile_gate(alpha)
    result = quantum_eml_full(r, x, y)
    print(f"  target = {z:>10}, r = {r:.4f}, α = {alpha:.4f}, "
          f"result = {result:.4f}, error = {abs(result-z):.2e}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Classical-Quantum EML Bridge

Shows how classical EML identities lift to quantum phase identities,
and the fidelity landscape for gate compilation.
"""

import numpy as np
import matplotlib.pyplot as plt


def eml(x, y):
    return np.exp(x) - np.log(y)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Classical-Quantum Bridge
ax1 = axes[0]
a_vals = np.linspace(0.1, 5, 100)
b = 1.0

classical_eml = [eml(np.log(a), np.exp(b)) for a in a_vals]
quantum_phase_re = [np.cos(a - b) for a in a_vals]
quantum_phase_im = [np.sin(a - b) for a in a_vals]
simple_diff = a_vals - b

ax1.plot(a_vals, classical_eml, 'b-', linewidth=2, label='eml(log a, eᵇ)')
ax1.plot(a_vals, simple_diff, 'r--', linewidth=2, label='a - b')
ax1.set_xlabel('a', fontsize=12)
ax1.set_ylabel('Value', fontsize=12)
ax1.set_title('Classical Bridge: eml(log a, eᵇ) = a - b\n(b = 1)', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Panel 2: Fidelity landscape
ax2 = axes[1]
alphas = np.linspace(-np.pi, np.pi, 100)
y_vals = np.linspace(0.01, 6, 100)
A, Y = np.meshgrid(alphas, y_vals)

fidelity = np.cos(np.exp(0) - np.log(Y) - A)  # eml(0, y) = 1 - log(y)

contour = ax2.contourf(A, Y, fidelity, levels=20, cmap='RdYlGn')
plt.colorbar(contour, ax=ax2, label='Fidelity')

# Mark the optimal line: eml(0, y) = α → y = exp(1-α)
alpha_line = np.linspace(-np.pi, np.pi, 100)
y_optimal = np.exp(1 - alpha_line)
mask = (y_optimal > 0.01) & (y_optimal < 6)
ax2.plot(alpha_line[mask], y_optimal[mask], 'w-', linewidth=2, label='Perfect: y=exp(1-α)')
ax2.set_xlabel('Target α', fontsize=12)
ax2.set_ylabel('Parameter y', fontsize=12)
ax2.set_title('Fidelity Landscape\ncos(eml(0,y) - α)', fontsize=13)
ax2.legend(fontsize=10, loc='upper right')

# Panel 3: Phase composition
ax3 = axes[2]
theta = np.linspace(0, 2*np.pi, 200)
ax3.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.15, linewidth=3)

# Show composition: gate1 + gate2 = combined
gate_pairs = [
    ((0, 1), (0, 2), 'red', 'Gate 1 + Gate 2'),
    ((1, 1), (0.5, 0.5), 'blue', 'Gate 3 + Gate 4'),
]

for (x1, y1), (x2, y2), color, label in gate_pairs:
    z1 = np.exp(1j * eml(x1, y1))
    z2 = np.exp(1j * eml(x2, y2))
    z_prod = z1 * z2
    
    ax3.annotate('', xy=(z1.real, z1.imag), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5, alpha=0.5))
    ax3.annotate('', xy=(z2.real, z2.imag), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5, alpha=0.5, ls='--'))
    ax3.plot(z_prod.real, z_prod.imag, 'o', color=color, markersize=12, zorder=5)
    ax3.annotate(label, (z_prod.real + 0.1, z_prod.imag + 0.1), 
                fontsize=9, color=color)

ax3.set_xlim(-1.5, 1.5)
ax3.set_ylim(-1.5, 1.5)
ax3.set_aspect('equal')
ax3.set_title('Phase Composition\nGate₁ · Gate₂ = exp(i(eml₁+eml₂))', fontsize=13)
ax3.set_xlabel('Re(z)')
ax3.set_ylabel('Im(z)')
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/quantum_eml_bridge.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: quantum_eml_bridge.png")


#!/usr/bin/env python3
"""
Visualization: Quantum EML Phase Coverage on the Unit Circle

Shows how quantum EML parameters map to points on S¹,
demonstrating the surjectivity theorem.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def eml(x, y):
    return np.exp(x) - np.log(y)


def quantum_eml_phase(x, y):
    return np.exp(1j * eml(x, y))


def compile_gate(alpha):
    return (0.0, np.exp(1 - alpha))


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Phase coverage — many random parameters
ax1 = axes[0]
theta_circle = np.linspace(0, 2*np.pi, 100)
ax1.plot(np.cos(theta_circle), np.sin(theta_circle), 'k-', alpha=0.2, linewidth=2)

np.random.seed(42)
n_samples = 200
x_samples = np.random.uniform(-2, 2, n_samples)
y_samples = np.random.uniform(0.01, 5, n_samples)

phases = [quantum_eml_phase(x, y) for x, y in zip(x_samples, y_samples)]
real_parts = [z.real for z in phases]
imag_parts = [z.imag for z in phases]

scatter = ax1.scatter(real_parts, imag_parts, c=range(n_samples),
                       cmap='hsv', s=20, alpha=0.7, zorder=5)
ax1.set_xlim(-1.4, 1.4)
ax1.set_ylim(-1.4, 1.4)
ax1.set_aspect('equal')
ax1.set_title('Quantum EML Phase Coverage\n(random parameters)', fontsize=13)
ax1.set_xlabel('Re(z)')
ax1.set_ylabel('Im(z)')
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='k', linewidth=0.5)
ax1.axvline(x=0, color='k', linewidth=0.5)

# Panel 2: Exact compilation — target angles
ax2 = axes[1]
ax2.plot(np.cos(theta_circle), np.sin(theta_circle), 'k-', alpha=0.2, linewidth=2)

target_angles = np.linspace(0, 2*np.pi, 13)[:-1]  # 12 evenly spaced
for alpha in target_angles:
    x, y = compile_gate(alpha)
    z = quantum_eml_phase(x, y)
    ax2.plot([0, z.real], [0, z.imag], 'b-', alpha=0.3)
    ax2.plot(z.real, z.imag, 'ro', markersize=10, zorder=5)
    angle_deg = np.degrees(alpha)
    ax2.annotate(f'{angle_deg:.0f}°',
                 (1.15*z.real, 1.15*z.imag),
                 ha='center', va='center', fontsize=8)

ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.set_aspect('equal')
ax2.set_title('Exact Gate Compilation\ny = exp(1-α)', fontsize=13)
ax2.set_xlabel('Re(z)')
ax2.set_ylabel('Im(z)')
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0, color='k', linewidth=0.5)
ax2.axvline(x=0, color='k', linewidth=0.5)

# Panel 3: Gap bound — gap vs eml²
ax3 = axes[2]
eml_values = np.linspace(-4, 4, 500)
gaps = 2 - 2*np.cos(eml_values)
bounds = eml_values**2

ax3.fill_between(eml_values, gaps, bounds, alpha=0.2, color='green',
                  label='Margin (bound - gap)')
ax3.plot(eml_values, gaps, 'b-', linewidth=2, label='Gap: 2 - 2cos(eml)')
ax3.plot(eml_values, bounds, 'r--', linewidth=2, label='Bound: eml²')
ax3.set_xlabel('eml(x, y)', fontsize=12)
ax3.set_ylabel('Error', fontsize=12)
ax3.set_title('Quantum-Classical Gap Bound\n|exp(i·eml) - 1|² ≤ eml²', fontsize=13)
ax3.legend(fontsize=10)
ax3.set_ylim(-0.5, 16)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/quantum_eml_coverage.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: quantum_eml_coverage.png")
