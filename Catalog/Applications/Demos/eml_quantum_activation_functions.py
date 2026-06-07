#!/usr/bin/env python3
"""
Quantum EML Activation Functions — Numerical Demonstrations

Demonstrates the key properties of the Quantum EML (QEML) framework:
1. Classical embedding: QEML reduces to classical EML on real inputs
2. Phase generation: exp(iθ) covers the unit circle
3. Surjectivity: QEML can hit any complex target
4. Amplitude-phase separation in QEML neurons
"""

import numpy as np

# ─── Core Definitions ───

def qeml(z: complex, w: complex) -> complex:
    """Quantum EML activation: exp(z) - log(w)"""
    return np.exp(z) - np.log(w)

def qeml_phase(theta: float) -> complex:
    """Phase activation: exp(i·θ)"""
    return np.exp(1j * theta)

def qeml_log_activation(beta: float) -> complex:
    """Log-activation: log(1 + i·β)"""
    return np.log(1 + 1j * beta)

def qeml_neuron(alpha: float, beta: float) -> complex:
    """Full quantum EML neuron: exp(iα) · log(1 + iβ)"""
    return qeml_phase(alpha) * qeml_log_activation(beta)

# ─── Demo 1: Classical Embedding ───

print("=" * 60)
print("DEMO 1: Classical Embedding (Theorem qeml_classical_embedding)")
print("=" * 60)
print("\nVerifying: Re(qeml(x, y)) = exp(x) - log(y) for real inputs\n")

test_cases = [(0.0, 1.0), (1.0, 2.0), (-1.0, 0.5), (2.0, 3.0), (0.5, 10.0)]
for x, y in test_cases:
    qeml_val = qeml(complex(x), complex(y))
    classical = np.exp(x) - np.log(y)
    print(f"  x={x:5.1f}, y={y:5.1f}: Re(qeml) = {qeml_val.real:.10f}, "
          f"exp(x)-log(y) = {classical:.10f}, match = {np.isclose(qeml_val.real, classical)}")

# ─── Demo 2: Phase Generation (Unit Circle) ───

print("\n" + "=" * 60)
print("DEMO 2: Phase Generation (Theorem qemlPhase_surj_circle)")
print("=" * 60)
print("\nVerifying: |exp(iθ)| = 1 for all θ, and surjectivity onto S¹\n")

thetas = np.linspace(0, 2*np.pi, 13)[:-1]
for theta in thetas:
    phase = qeml_phase(theta)
    print(f"  θ = {theta:5.2f}: exp(iθ) = {phase.real:+.4f}{phase.imag:+.4f}i, "
          f"|exp(iθ)| = {abs(phase):.10f}")

# ─── Demo 3: Periodicity ───

print("\n" + "=" * 60)
print("DEMO 3: Periodicity (Theorem qemlPhase_periodic)")
print("=" * 60)
print("\nVerifying: exp(i(θ + 2π)) = exp(iθ)\n")

for theta in [0.0, 0.7, 1.5, np.pi, 2.3]:
    p1 = qeml_phase(theta)
    p2 = qeml_phase(theta + 2*np.pi)
    print(f"  θ = {theta:.2f}: exp(iθ) = {p1:.6f}, exp(i(θ+2π)) = {p2:.6f}, "
          f"match = {np.isclose(p1, p2)}")

# ─── Demo 4: Surjectivity ───

print("\n" + "=" * 60)
print("DEMO 4: Surjectivity (Theorem qeml_surjective)")
print("=" * 60)
print("\nFor any c ∈ ℂ, finding z,w such that qeml(z,w) = c\n")

targets = [0+0j, 1+0j, 0+1j, -1+0j, 3.14+2.72j, -5-3j]
for c in targets:
    # Construction: z = log(c+1), w = exp(1), unless c = -1
    if np.isclose(c, -1):
        z, w = 1j * np.pi, 1.0
    else:
        z = np.log(c + 1)
        w = np.exp(1.0)
    result = qeml(z, w)
    print(f"  target = {c:12s}: z = {z:.4f}, w = {w:.4f}, "
          f"qeml(z,w) = {result:.6f}, match = {np.isclose(result, c)}")

# ─── Demo 5: Amplitude-Phase Separation ───

print("\n" + "=" * 60)
print("DEMO 5: Amplitude-Phase Separation (Theorem qemlNeuron_norm_independent_of_phase)")
print("=" * 60)
print("\n|qemlNeuron(α, β)| is independent of α:\n")

for beta in [0.5, 1.0, 2.0, -1.5]:
    norms = [abs(qeml_neuron(alpha, beta)) for alpha in np.linspace(0, 2*np.pi, 8)]
    log_act_norm = abs(qeml_log_activation(beta))
    print(f"  β = {beta:5.1f}: |neuron| for 8 values of α = "
          f"{[f'{n:.6f}' for n in norms]}")
    print(f"          |log_activation(β)| = {log_act_norm:.6f}, "
          f"all match = {all(np.isclose(n, log_act_norm) for n in norms)}")

# ─── Demo 6: Phase Action (Group Structure) ───

print("\n" + "=" * 60)
print("DEMO 6: Phase Action (Theorem qemlNeuron_phase_action)")
print("=" * 60)
print("\nVerifying: neuron(α₁+α₂, β) = phase(α₁) · neuron(α₂, β)\n")

for alpha1, alpha2, beta in [(0.5, 1.0, 2.0), (np.pi, 0.3, -1.0), (1.2, 2.5, 0.7)]:
    lhs = qeml_neuron(alpha1 + alpha2, beta)
    rhs = qeml_phase(alpha1) * qeml_neuron(alpha2, beta)
    print(f"  α₁={alpha1:.1f}, α₂={alpha2:.1f}, β={beta:.1f}: "
          f"LHS = {lhs:.6f}, RHS = {rhs:.6f}, match = {np.isclose(lhs, rhs)}")

# ─── Demo 7: Derivative Structure ───

print("\n" + "=" * 60)
print("DEMO 7: Derivative (Theorem qeml_deriv_fst)")
print("=" * 60)
print("\n∂/∂z qeml(z, w) = exp(z), verified numerically:\n")

eps = 1e-8
w = 2.0 + 1j
for z in [0+0j, 1+0j, 0+1j, 1+1j]:
    numerical_deriv = (qeml(z + eps, w) - qeml(z - eps, w)) / (2 * eps)
    exact_deriv = np.exp(z)
    print(f"  z = {z}: numerical = {numerical_deriv:.6f}, "
          f"exp(z) = {exact_deriv:.6f}, match = {np.isclose(numerical_deriv, exact_deriv, rtol=1e-6)}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 3: Quantum EML Chain Depth and Composition

Demonstrates:
1. Chain composition theorem: eval(c1 ++ c2) = eval(c1, eval(c2, ·))
2. Depth subadditivity: depth(c1 ++ c2) ≤ depth(c1) + depth(c2)
3. Phase rotations are free (zero depth cost)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def cexp(z):
    return np.exp(z)

def clog(z):
    return np.log(z) if z != 0 else complex(float('-inf'))

def affine(a, b):
    return lambda z: a * z + b

def phase_rotate(theta):
    return lambda z: np.exp(1j * theta) * z

# Build chains
chain1 = [('cexp', cexp, 1), ('affine', affine(2, 1), 0)]
chain2 = [('phase_rotate', phase_rotate(np.pi/4), 0), ('clog', clog, 1)]

def eval_chain(chain, z):
    result = z
    for name, op, depth in reversed(chain):
        result = op(result)
    return result

def chain_depth(chain):
    return sum(d for _, _, d in chain)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: Chain composition
ax1 = axes[0]
# Sample points in complex plane
thetas = np.linspace(0, 2*np.pi, 100)
inputs = 0.5 * np.exp(1j * thetas) + 0.5  # Circle around 0.5

# Evaluate c1 ∘ c2 directly
combined = chain1 + chain2
outputs_combined = np.array([eval_chain(combined, z) for z in inputs])

# Evaluate c1(c2(·)) step by step
intermediate = np.array([eval_chain(chain2, z) for z in inputs])
outputs_composed = np.array([eval_chain(chain1, z) for z in intermediate])

ax1.plot(outputs_combined.real, outputs_combined.imag, 'b-', linewidth=2,
         label='eval(c₁ ++ c₂, z)')
ax1.plot(outputs_composed.real, outputs_composed.imag, 'r--', linewidth=2,
         label='eval(c₁, eval(c₂, z))')
ax1.plot(inputs.real, inputs.imag, 'g:', linewidth=1, label='Input circle')
ax1.set_xlabel('Re', fontsize=12)
ax1.set_ylabel('Im', fontsize=12)
ax1.set_title('Chain Composition Theorem\n'
              'eval(c₁++c₂) = eval(c₁)∘eval(c₂)', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_aspect('equal')

# Plot 2: Depth subadditivity
ax2 = axes[1]
# Create chains of varying depths
depths_1 = []
depths_2 = []
depths_combined = []
labels = []

chain_configs = [
    ([('cexp', cexp, 1)], [('clog', clog, 1)]),
    ([('cexp', cexp, 1), ('cexp', cexp, 1)], [('clog', clog, 1)]),
    ([('cexp', cexp, 1)], [('clog', clog, 1), ('clog', clog, 1)]),
    ([('phase_rotate', phase_rotate(0.5), 0), ('cexp', cexp, 1)],
     [('clog', clog, 1), ('phase_rotate', phase_rotate(1.0), 0)]),
    ([('cexp', cexp, 1), ('cexp', cexp, 1), ('cexp', cexp, 1)],
     [('clog', clog, 1), ('clog', clog, 1)]),
]

for i, (c1, c2) in enumerate(chain_configs):
    d1 = chain_depth(c1)
    d2 = chain_depth(c2)
    dc = chain_depth(c1 + c2)
    depths_1.append(d1)
    depths_2.append(d2)
    depths_combined.append(dc)
    labels.append(f'Config {i+1}')

x_pos = np.arange(len(labels))
width = 0.25
ax2.bar(x_pos - width, depths_1, width, label='depth(c₁)', color='steelblue')
ax2.bar(x_pos, depths_2, width, label='depth(c₂)', color='coral')
ax2.bar(x_pos + width, depths_combined, width, label='depth(c₁++c₂)', color='mediumseagreen')
ax2.plot(x_pos + width, [d1+d2 for d1, d2 in zip(depths_1, depths_2)],
         'k^', markersize=10, label='depth(c₁)+depth(c₂)')
ax2.set_xticks(x_pos)
ax2.set_xticklabels(labels, fontsize=9)
ax2.set_ylabel('Depth', fontsize=12)
ax2.set_title('Depth Subadditivity\n'
              'depth(c₁++c₂) ≤ depth(c₁)+depth(c₂)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3, axis='y')

# Plot 3: Phase rotations are free
ax3 = axes[2]
# Show that adding phase rotations doesn't change depth
base_chain = [('cexp', cexp, 1), ('clog', clog, 1)]
base_depth = chain_depth(base_chain)

num_phases = range(0, 8)
depths_with_phases = []
for n in num_phases:
    augmented = [('phase_rotate', phase_rotate(np.pi * k / 4), 0) for k in range(n)] + base_chain
    depths_with_phases.append(chain_depth(augmented))

ax3.bar(list(num_phases), depths_with_phases, color='mediumpurple', edgecolor='black')
ax3.axhline(y=base_depth, color='red', linestyle='--', linewidth=2,
            label=f'Base depth = {base_depth}')
ax3.set_xlabel('Number of phase rotations added', fontsize=12)
ax3.set_ylabel('Chain depth', fontsize=12)
ax3.set_title('Phase Rotations Are Free\n'
              '(Thm: qeml_phase_depth_free)', fontsize=13)
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('qeml_chains.png', dpi=150, bbox_inches='tight')
print("Saved qeml_chains.png")


#!/usr/bin/env python3
"""
Visualization 1: Quantum EML Phase Generation and Surjectivity

Produces three plots:
1. The unit circle generated by exp(iθ) — phase generation theorem
2. The spiral generated by log(1 + iβ) — log-activation curve
3. The quantum EML neuron output for varying (α, β) — amplitude-phase separation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

def qeml_phase(theta):
    return np.exp(1j * theta)

def qeml_log_activation(beta):
    return np.log(1 + 1j * beta)

def qeml_neuron(alpha, beta):
    return qeml_phase(alpha) * qeml_log_activation(beta)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: Phase generation (unit circle)
ax1 = axes[0]
thetas = np.linspace(0, 2*np.pi, 200)
phases = qeml_phase(thetas)
ax1.plot(phases.real, phases.imag, 'b-', linewidth=2, label=r'$e^{i\theta}$, $\theta \in [0, 2\pi)$')
# Mark specific points
for t, label in [(0, '1'), (np.pi/2, 'i'), (np.pi, '-1'), (3*np.pi/2, '-i')]:
    p = qeml_phase(t)
    ax1.plot(p.real, p.imag, 'ro', markersize=8)
    ax1.annotate(label, (p.real, p.imag), textcoords="offset points",
                xytext=(10, 10), fontsize=14)
ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)
ax1.set_xlabel('Re', fontsize=12)
ax1.set_ylabel('Im', fontsize=12)
ax1.set_title(r'Phase Generation: $e^{i\theta}$ covers $S^1$' + '\n(Thm: qemlPhase_surj_circle)', fontsize=13)
ax1.legend(fontsize=11)

# Plot 2: Log-activation spiral
ax2 = axes[1]
betas = np.linspace(-10, 10, 500)
log_acts = qeml_log_activation(betas)
colors = betas
scatter = ax2.scatter(log_acts.real, log_acts.imag, c=colors, cmap='coolwarm',
                      s=2, zorder=2)
plt.colorbar(scatter, ax=ax2, label=r'$\beta$')
# Mark β = 0 (origin)
ax2.plot(0, 0, 'k*', markersize=12, zorder=3)
ax2.annotate(r'$\beta=0$', (0, 0), textcoords="offset points",
            xytext=(10, -15), fontsize=12)
ax2.grid(True, alpha=0.3)
ax2.set_xlabel('Re', fontsize=12)
ax2.set_ylabel('Im', fontsize=12)
ax2.set_title(r'Log-Activation: $\log(1 + i\beta)$' + '\n(The logarithmic spiral)', fontsize=13)
ax2.set_aspect('equal')

# Plot 3: Full neuron output (amplitude-phase separation)
ax3 = axes[2]
alphas_grid = np.linspace(0, 2*np.pi, 50)
betas_grid = np.linspace(0.1, 3.0, 8)
for beta in betas_grid:
    outputs = qeml_neuron(alphas_grid, beta)
    ax3.plot(outputs.real, outputs.imag, '-', linewidth=1.5,
             label=rf'$\beta={beta:.1f}$' if beta in [0.1, 1.0, 2.0, 3.0] else None)
ax3.set_aspect('equal')
ax3.grid(True, alpha=0.3)
ax3.set_xlabel('Re', fontsize=12)
ax3.set_ylabel('Im', fontsize=12)
ax3.set_title(r'QEML Neuron: $e^{i\alpha} \cdot \log(1+i\beta)$' +
              '\n(Circles: amplitude indep. of phase)', fontsize=13)
ax3.legend(fontsize=9, loc='upper right')

plt.tight_layout()
plt.savefig('qeml_visualization.png', dpi=150, bbox_inches='tight')
print("Saved qeml_visualization.png")


#!/usr/bin/env python3
"""
Visualization 2: Quantum EML Surjectivity and Classical Embedding

Produces two plots:
1. Surjectivity: for a grid of complex targets, shows the preimage construction
2. Classical embedding: QEML on real inputs matches classical EML
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def qeml(z, w):
    return np.exp(z) - np.log(w)

def find_preimage(target):
    if np.isclose(target, -1.0):
        return (1j * np.pi, 1.0 + 0j)
    else:
        z = np.log(target + 1)
        w = complex(np.e)
        return (z, w)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Plot 1: Surjectivity demonstration
ax1 = axes[0]
# Grid of targets in the complex plane
re_targets = np.linspace(-3, 3, 15)
im_targets = np.linspace(-3, 3, 15)
errors = []
for re_t in re_targets:
    for im_t in im_targets:
        target = re_t + 1j * im_t
        z, w = find_preimage(target)
        result = qeml(z, w)
        error = abs(result - target)
        errors.append(error)
        if error < 1e-10:
            ax1.plot(re_t, im_t, 'g.', markersize=8)
        else:
            ax1.plot(re_t, im_t, 'rx', markersize=8)

ax1.set_xlabel('Re(target)', fontsize=12)
ax1.set_ylabel('Im(target)', fontsize=12)
ax1.set_title('QEML Surjectivity: Hitting Every Target\n'
              '(Green = exact preimage found, Thm: qeml_surjective)', fontsize=13)
ax1.grid(True, alpha=0.3)
ax1.set_aspect('equal')

# Annotate success rate
success = sum(1 for e in errors if e < 1e-10)
ax1.text(0.02, 0.98, f'Success: {success}/{len(errors)} targets hit exactly',
         transform=ax1.transAxes, fontsize=11, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

# Plot 2: Classical embedding
ax2 = axes[1]
xs = np.linspace(-2, 2, 100)
ys_list = [0.5, 1.0, 2.0, 5.0]
for y in ys_list:
    classical = np.exp(xs) - np.log(y)
    quantum_re = np.array([qeml(complex(x), complex(y)).real for x in xs])
    ax2.plot(xs, classical, '-', linewidth=2, label=rf'$y={y}$')
    ax2.plot(xs, quantum_re, 'k--', linewidth=1, alpha=0.5)

ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('EML value', fontsize=12)
ax2.set_title('Classical Embedding: Re(QEML) = EML on ℝ\n'
              '(Solid=classical, dashed=Re(quantum), Thm: qeml_classical_embedding)',
              fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-5, 10)

plt.tight_layout()
plt.savefig('qeml_surjectivity.png', dpi=150, bbox_inches='tight')
print("Saved qeml_surjectivity.png")
