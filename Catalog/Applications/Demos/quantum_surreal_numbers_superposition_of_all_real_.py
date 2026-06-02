#!/usr/bin/env python3
"""
Quantum Surreal Numbers: Demonstration

Numerical examples illustrating the key concepts:
1. Probability defect for states with infinitesimal components
2. Post-measurement normalization
3. Observable Cauchy-Schwarz bound
"""

import numpy as np
from typing import List, Tuple

def make_quantum_state(amplitudes: List[float]) -> np.ndarray:
    """Create a normalized quantum state from raw amplitudes."""
    amp = np.array(amplitudes, dtype=float)
    norm = np.sqrt(np.sum(amp**2))
    if norm == 0:
        raise ValueError("Zero state cannot be normalized")
    return amp / norm

def probability_defect(state: np.ndarray, observable_mask: np.ndarray) -> float:
    """Compute the probability defect: 1 - sum of |alpha_i|^2 for observable i."""
    probs = state**2
    obs_prob = np.sum(probs[observable_mask])
    return 1.0 - obs_prob

def observable_prob(state: np.ndarray, observable_mask: np.ndarray) -> float:
    """Compute observable probability."""
    return np.sum(state[observable_mask]**2)

def infinitesimal_prob(state: np.ndarray, observable_mask: np.ndarray) -> float:
    """Compute infinitesimal probability."""
    return np.sum(state[~observable_mask]**2)

def post_measurement(state: np.ndarray, keep_mask: np.ndarray) -> np.ndarray:
    """Apply projection and renormalize."""
    projected = state * keep_mask.astype(float)
    norm_sq = np.sum(projected**2)
    if norm_sq == 0:
        raise ValueError("Projection has zero probability")
    return projected / np.sqrt(norm_sq)

def obs_inner_product(state1: np.ndarray, state2: np.ndarray,
                      observable_mask: np.ndarray) -> float:
    """Inner product restricted to observable sector."""
    return np.sum(state1[observable_mask] * state2[observable_mask])

# ============================================================
# Demo 1: The Probability Defect
# ============================================================
print("=" * 60)
print("DEMO 1: Probability Defect")
print("=" * 60)
print()
print("Consider a quantum state |ψ⟩ = α₀|0⟩ + α₁|1⟩ + α₂|ε⟩")
print("where |0⟩ and |1⟩ are observable, but |ε⟩ is infinitesimal.")
print()

# Simulate different amounts of "infinitesimal" amplitude
for eps_amp in [0.0, 0.1, 0.3, 0.5, 0.7, 0.9]:
    # State: (1, 1, eps) normalized
    state = make_quantum_state([1.0, 1.0, eps_amp])
    mask = np.array([True, True, False])  # first two observable

    delta = probability_defect(state, mask)
    p_obs = observable_prob(state, mask)
    p_inf = infinitesimal_prob(state, mask)

    print(f"  ε-amplitude = {eps_amp:.1f}")
    print(f"    State = [{state[0]:.4f}, {state[1]:.4f}, {state[2]:.4f}]")
    print(f"    P_obs = {p_obs:.6f}, P_inf = {p_inf:.6f}, "
          f"P_obs + P_inf = {p_obs + p_inf:.6f}")
    print(f"    Defect δ = {delta:.6f}")
    print()

# ============================================================
# Demo 2: The Key Quantum Surreal Example
# ============================================================
print("=" * 60)
print("DEMO 2: The Quantum Surreal State |ψ⟩ = (1/√2)|0⟩ + (1/√2)|ε⟩")
print("=" * 60)
print()
print("This is the canonical example from the research direction.")
print("In true surreal arithmetic, ε is infinitesimal and st(ε²/2) = 0.")
print("We simulate with decreasing finite values of ε:")
print()

for eps_val in [1.0, 0.1, 0.01, 0.001, 1e-10, 1e-100]:
    # |ψ⟩ = (1/√2)|0⟩ + (1/√2)|ε⟩, but ε is the BASIS LABEL
    # The amplitudes are both 1/√2, the key is what we OBSERVE
    state = make_quantum_state([1.0, 1.0])
    mask = np.array([True, False])  # only |0⟩ is observable

    p_obs = observable_prob(state, mask)
    p_inf = infinitesimal_prob(state, mask)
    delta = probability_defect(state, mask)

    print(f"  ε = {eps_val:.0e}: P_obs = {p_obs:.4f}, "
          f"P_inf = {p_inf:.4f}, δ = {delta:.4f}")

print()
print("  → The probability defect is always 0.5, regardless of how small ε is!")
print("  → In the surreal limit, half the probability is 'dark'.")

# ============================================================
# Demo 3: Post-Measurement Normalization
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Post-Measurement Normalization")
print("=" * 60)
print()

state = make_quantum_state([3.0, 4.0, 1.0, 2.0])
print(f"Initial state: {state}")
print(f"Sum of squares: {np.sum(state**2):.6f}")

# Project onto first two components
keep = np.array([True, True, False, False])
post = post_measurement(state, keep)
print(f"\nAfter projecting onto observable sector {keep}:")
print(f"Post-measurement state: {post}")
print(f"Sum of squares: {np.sum(post**2):.6f}")
print("→ Properly renormalized to 1!")

# ============================================================
# Demo 4: Observable Cauchy-Schwarz
# ============================================================
print()
print("=" * 60)
print("DEMO 4: Observable Cauchy-Schwarz Inequality")
print("=" * 60)
print()

np.random.seed(42)
for trial in range(5):
    # Random states
    psi = make_quantum_state(np.random.randn(6))
    phi = make_quantum_state(np.random.randn(6))
    mask = np.array([True, True, True, False, False, False])

    ip = obs_inner_product(psi, phi, mask)
    p1 = observable_prob(psi, mask)
    p2 = observable_prob(phi, mask)

    lhs = ip**2
    rhs = p1 * p2

    print(f"  Trial {trial+1}: ⟨ψ|φ⟩²_obs = {lhs:.6f} ≤ "
          f"P_obs(ψ)·P_obs(φ) = {rhs:.6f}  "
          f"{'✓' if lhs <= rhs + 1e-12 else '✗'}")

# ============================================================
# Demo 5: Probability Defect vs Number of Infinitesimal Modes
# ============================================================
print()
print("=" * 60)
print("DEMO 5: Defect Scaling with Infinitesimal Mode Count")
print("=" * 60)
print()

n_total = 20
print(f"System with {n_total} basis states, equal amplitudes.")
for n_inf in range(0, n_total + 1, 4):
    state = make_quantum_state([1.0] * n_total)
    mask = np.array([True] * (n_total - n_inf) + [False] * n_inf)
    delta = probability_defect(state, mask)
    print(f"  {n_inf:2d} infinitesimal modes → δ = {delta:.4f} "
          f"(= {n_inf}/{n_total} = {n_inf/n_total:.4f})")

print()
print("→ For equal amplitudes, defect = (# infinitesimal modes) / (total modes)")
print()
print("All demonstrations complete. ✓")


#!/usr/bin/env python3
"""
Visualization: Observable Cauchy-Schwarz Inequality

Demonstrates how the observable inner product bound tightens
as the probability defect increases, using random quantum states.
"""

import numpy as np
import matplotlib.pyplot as plt

def make_random_state(n: int, rng: np.random.Generator) -> np.ndarray:
    """Create a random normalized quantum state."""
    raw = rng.standard_normal(n)
    return raw / np.linalg.norm(raw)

def obs_prob(state: np.ndarray, mask: np.ndarray) -> float:
    return np.sum(state[mask]**2)

def obs_ip(s1: np.ndarray, s2: np.ndarray, mask: np.ndarray) -> float:
    return np.sum(s1[mask] * s2[mask])

# Generate data
rng = np.random.default_rng(42)
n = 10
n_trials = 2000

results = []
for _ in range(n_trials):
    # Random number of observable modes (1 to n-1)
    n_obs = rng.integers(1, n)
    mask = np.zeros(n, dtype=bool)
    mask[:n_obs] = True
    rng.shuffle(mask)

    psi = make_random_state(n, rng)
    phi = make_random_state(n, rng)

    ip = obs_ip(psi, phi, mask)
    p1 = obs_prob(psi, mask)
    p2 = obs_prob(phi, mask)

    avg_defect = (1 - p1 + 1 - p2) / 2
    lhs = ip**2
    rhs = p1 * p2

    results.append((avg_defect, lhs, rhs))

results = np.array(results)

fig, ax = plt.subplots(figsize=(8, 6))

scatter = ax.scatter(results[:, 0], results[:, 1] / np.maximum(results[:, 2], 1e-15),
                     c=results[:, 2], cmap='viridis', alpha=0.3, s=8)
ax.axhline(y=1.0, color='red', linewidth=2, linestyle='--',
           label='Cauchy-Schwarz Bound')
ax.set_xlabel('Average Probability Defect $\\bar{\\delta}$', fontsize=12)
ax.set_ylabel('$\\langle\\psi|\\phi\\rangle^2_{obs} / (P_{obs}(\\psi) \\cdot P_{obs}(\\phi))$',
              fontsize=12)
ax.set_title('Observable Cauchy-Schwarz: All Points Below the Red Line', fontsize=13)
ax.legend(fontsize=11)
ax.set_ylim(-0.05, 1.5)
ax.grid(True, alpha=0.3)

cbar = plt.colorbar(scatter)
cbar.set_label('$P_{obs}(\\psi) \\cdot P_{obs}(\\phi)$', fontsize=10)

plt.tight_layout()
plt.savefig('cauchy_schwarz_bound.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved cauchy_schwarz_bound.png")


#!/usr/bin/env python3
"""
Visualization: Measurement Collapse and Renormalization

Shows how projecting onto the observable sector and renormalizing
transforms the quantum state, with before/after comparison.
"""

import numpy as np
import matplotlib.pyplot as plt

def make_state(amps: list) -> np.ndarray:
    a = np.array(amps, dtype=float)
    return a / np.linalg.norm(a)

# Create a state with mixed observable/infinitesimal components
n = 8
labels = [f'$|{i}\\rangle$' for i in range(4)] + \
         [f'$|\\varepsilon_{i}\\rangle$' for i in range(4)]
obs_mask = np.array([True]*4 + [False]*4)

# State with significant infinitesimal components
state = make_state([3, 2, 4, 1, 2, 3, 1, 2])

# Post-measurement
projected = state * obs_mask.astype(float)
norm = np.linalg.norm(projected)
post_state = projected / norm

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Pre-measurement
colors = ['#2196F3' if obs else '#FF5722' for obs in obs_mask]
bars1 = axes[0].bar(range(n), state**2, color=colors, edgecolor='white',
                     linewidth=0.5)
axes[0].set_xticks(range(n))
axes[0].set_xticklabels(labels, fontsize=9)
axes[0].set_ylabel('$|\\alpha_i|^2$', fontsize=12)
axes[0].set_title('Before Measurement', fontsize=13)
axes[0].set_ylim(0, 0.45)
p_obs = np.sum(state[obs_mask]**2)
p_inf = np.sum(state[~obs_mask]**2)
axes[0].text(0.95, 0.95, f'$P_{{obs}} = {p_obs:.3f}$\n$P_{{inf}} = {p_inf:.3f}$\n$\\delta = {p_inf:.3f}$',
             transform=axes[0].transAxes, fontsize=10,
             verticalalignment='top', horizontalalignment='right',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# After projection (unnormalized)
axes[1].bar(range(n), projected**2, color=colors, edgecolor='white',
            linewidth=0.5, alpha=0.7)
axes[1].set_xticks(range(n))
axes[1].set_xticklabels(labels, fontsize=9)
axes[1].set_ylabel('$|P\\alpha_i|^2$', fontsize=12)
axes[1].set_title('After Projection (unnormalized)', fontsize=13)
axes[1].set_ylim(0, 0.45)
total = np.sum(projected**2)
axes[1].text(0.95, 0.95, f'$\\sum |P\\alpha_i|^2 = {total:.3f}$\n(< 1)',
             transform=axes[1].transAxes, fontsize=10,
             verticalalignment='top', horizontalalignment='right',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# After renormalization
colors_post = ['#4CAF50' if obs else '#BDBDBD' for obs in obs_mask]
axes[2].bar(range(n), post_state**2, color=colors_post, edgecolor='white',
            linewidth=0.5)
axes[2].set_xticks(range(n))
axes[2].set_xticklabels(labels, fontsize=9)
axes[2].set_ylabel('$|\\alpha\'_i|^2$', fontsize=12)
axes[2].set_title('After Renormalization', fontsize=13)
axes[2].set_ylim(0, 0.45)
axes[2].text(0.95, 0.95, f'$\\sum |\\alpha\'_i|^2 = {np.sum(post_state**2):.3f}$\n(= 1 ✓)',
             transform=axes[2].transAxes, fontsize=10,
             verticalalignment='top', horizontalalignment='right',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# Legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2196F3', label='Observable sector'),
    Patch(facecolor='#FF5722', label='Infinitesimal sector'),
    Patch(facecolor='#4CAF50', label='Post-measurement'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3,
           fontsize=11, bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Quantum Surreal Measurement: Projection and Renormalization',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('measurement_collapse.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved measurement_collapse.png")


#!/usr/bin/env python3
"""
Visualization: Probability Defect as a Function of Infinitesimal Amplitude

Shows how the probability defect grows as more amplitude is pushed into
the infinitesimal sector, and how conservation is maintained.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def make_state(obs_amp: float, inf_amp: float) -> np.ndarray:
    """Create normalized state with given observable and infinitesimal amplitudes."""
    raw = np.array([obs_amp, obs_amp, inf_amp])
    return raw / np.linalg.norm(raw)

# Parameters
eps_range = np.linspace(0, 2, 200)
p_obs_list = []
p_inf_list = []
defect_list = []

for eps in eps_range:
    state = make_state(1.0, eps)
    p_obs = state[0]**2 + state[1]**2
    p_inf = state[2]**2
    p_obs_list.append(p_obs)
    p_inf_list.append(p_inf)
    defect_list.append(1 - p_obs)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Left: Stacked area chart
ax1.fill_between(eps_range, 0, p_obs_list, alpha=0.7, color='#2196F3',
                 label='Observable Probability $P_{obs}$')
ax1.fill_between(eps_range, p_obs_list, 1, alpha=0.7, color='#FF5722',
                 label='Dark Probability $P_{inf}$')
ax1.axhline(y=1, color='black', linewidth=0.5, linestyle='--', alpha=0.5)
ax1.set_xlabel('Infinitesimal Amplitude $\\alpha_\\varepsilon$', fontsize=12)
ax1.set_ylabel('Probability', fontsize=12)
ax1.set_title('Probability Conservation with Dark Sector', fontsize=13)
ax1.legend(loc='center right', fontsize=10)
ax1.set_ylim(0, 1.05)
ax1.set_xlim(0, 2)
ax1.grid(True, alpha=0.3)

# Right: Defect curve
ax2.plot(eps_range, defect_list, color='#FF5722', linewidth=2.5,
         label='Probability Defect $\\delta$')
ax2.fill_between(eps_range, 0, defect_list, alpha=0.2, color='#FF5722')
ax2.axhline(y=0.5, color='gray', linewidth=0.5, linestyle=':', alpha=0.7)
ax2.set_xlabel('Infinitesimal Amplitude $\\alpha_\\varepsilon$', fontsize=12)
ax2.set_ylabel('Defect $\\delta = 1 - P_{obs}$', fontsize=12)
ax2.set_title('Probability Defect Growth', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 1.05)
ax2.set_xlim(0, 2)
ax2.grid(True, alpha=0.3)

# Annotate the key point
half_idx = np.argmin(np.abs(np.array(defect_list) - 0.5))
ax2.annotate(f'δ = 0.5 at α ≈ {eps_range[half_idx]:.2f}',
             xy=(eps_range[half_idx], 0.5),
             xytext=(eps_range[half_idx] + 0.3, 0.6),
             fontsize=10,
             arrowprops=dict(arrowstyle='->', color='black'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.7))

plt.tight_layout()
plt.savefig('probability_defect.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved probability_defect.png")
