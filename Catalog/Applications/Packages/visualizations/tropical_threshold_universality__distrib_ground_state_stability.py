"""
Visualization: Ground State Stability Under Perturbation

This script visualizes the cross-domain theorem connecting tropical margin
theory to zero-temperature statistical mechanics. It shows how the ground
state (energy maximizer) is preserved under bounded perturbation when the
energy gap is sufficiently large.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def simulate_ground_state_stability(num_states, gap, delta, num_trials, rng):
    """Simulate ground state stability for given gap and delta."""
    preserved = 0
    for _ in range(num_trials):
        # Random energy landscape with state 0 as ground state
        E = rng.standard_normal(num_states)
        E[0] = np.max(E[1:]) + gap
        
        # Perturbation
        pert = rng.uniform(-delta, delta, num_states)
        E_prime = E + pert
        
        if np.argmax(E_prime) == 0:
            preserved += 1
    return preserved / num_trials


# Parameters
rng = np.random.default_rng(42)
num_states = 20
num_trials = 500
delta = 1.0

fig, axes = plt.subplots(1, 3, figsize=(17, 5.5))

# Panel 1: Stability probability vs gap/delta ratio
ratios = np.linspace(0, 5, 30)
gaps = ratios * delta

probs = []
for gap in gaps:
    p = simulate_ground_state_stability(num_states, gap, delta, num_trials, rng)
    probs.append(p)

axes[0].plot(ratios, probs, 'b-o', markersize=4, linewidth=2)
axes[0].axvline(x=2.0, color='red', linestyle='--', linewidth=2, 
                label='Theorem threshold\n(gap = 2δ)', alpha=0.8)
axes[0].fill_between(ratios, 0, 1, where=np.array(ratios) >= 2.0,
                      alpha=0.1, color='green', label='Certified region')
axes[0].set_xlabel('Gap / δ ratio', fontsize=12)
axes[0].set_ylabel('P(ground state preserved)', fontsize=12)
axes[0].set_title('Ground State Stability', fontsize=13, fontweight='bold')
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)
axes[0].set_ylim(-0.05, 1.05)

# Panel 2: Energy landscape illustration
E_example = np.array([8.0, 3.0, 4.5, 2.0, 5.0, 1.5, 3.5, 2.5])
delta_ex = 1.0
pert = rng.uniform(-delta_ex, delta_ex, len(E_example))
E_perturbed = E_example + pert

x = np.arange(len(E_example))
width = 0.35

axes[1].bar(x - width/2, E_example, width, label='Original E(a)', 
            color='steelblue', alpha=0.8, edgecolor='navy')
axes[1].bar(x + width/2, E_perturbed, width, label="Perturbed E'(a)",
            color='coral', alpha=0.8, edgecolor='darkred')

# Mark gap
max_non_star = max(E_example[1:])
axes[1].annotate('', xy=(0, max_non_star), xytext=(0, E_example[0]),
                arrowprops=dict(arrowstyle='<->', color='green', lw=2))
axes[1].text(0.4, (E_example[0] + max_non_star) / 2, f'gap = {E_example[0] - max_non_star:.1f}',
            fontsize=10, color='green', fontweight='bold')

# Mark perturbation band
axes[1].axhline(y=E_example[0] - delta_ex, color='gray', linestyle=':', alpha=0.5)
axes[1].axhline(y=E_example[0] + delta_ex, color='gray', linestyle=':', alpha=0.5)

axes[1].set_xlabel('State index a', fontsize=12)
axes[1].set_ylabel('Energy E(a)', fontsize=12)
axes[1].set_title('Energy Landscape + Perturbation', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=10)
axes[1].set_xticks(x)

# Panel 3: Scaling with number of states
state_counts = [5, 10, 20, 50, 100]
for gap_ratio in [1.0, 2.0, 3.0]:
    stability_probs = []
    for ns in state_counts:
        p = simulate_ground_state_stability(ns, gap_ratio * delta, delta, 
                                             num_trials, rng)
        stability_probs.append(p)
    axes[2].plot(state_counts, stability_probs, '-o', markersize=5, 
                 linewidth=2, label=f'gap/δ = {gap_ratio:.0f}')

axes[2].set_xlabel('Number of states', fontsize=12)
axes[2].set_ylabel('P(ground state preserved)', fontsize=12)
axes[2].set_title('Stability vs. Landscape Size', fontsize=13, fontweight='bold')
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)
axes[2].set_ylim(-0.05, 1.05)

plt.tight_layout()
plt.savefig('ground_state_stability.png', dpi=150, bbox_inches='tight')
print("Saved: ground_state_stability.png")
