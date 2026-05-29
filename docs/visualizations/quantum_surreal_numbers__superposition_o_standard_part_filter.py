"""
Visualization: Standard Part Filter and Infinitesimal Collapse
===============================================================

Visualizes the standard-part filtering mechanism that models
infinitesimal probability collapse in quantum surreal numbers.

Shows how sub-threshold probabilities are mapped to zero,
demonstrating the proved properties:
- stdPart_zero_of_small: values below ε map to 0
- stdPart_eq_of_large: values above ε are preserved
- stdPart_idempotent: applying twice = applying once
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Standard part function for various ε
ax = axes[0, 0]
p = np.linspace(0, 1, 500)
for eps in [0.05, 0.1, 0.2, 0.3]:
    sp = np.where(p < eps, 0.0, p)
    ax.plot(p, sp, label=f'ε = {eps}', linewidth=2)
ax.plot(p, p, '--', color='gray', alpha=0.5, label='Identity')
ax.set_xlabel('Input probability p', fontsize=12)
ax.set_ylabel('stdPart(p, ε)', fontsize=12)
ax.set_title('Standard Part Filter\n(Infinitesimal Collapse)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: A quantum state before and after filtering
ax = axes[0, 1]
n = 8
np.random.seed(42)
raw_probs = np.random.exponential(0.3, n)
raw_probs = raw_probs / raw_probs.sum()

epsilon = 0.08
filtered = np.where(raw_probs < epsilon, 0.0, raw_probs)

x = np.arange(n)
width = 0.35
ax.bar(x - width/2, raw_probs, width, label='Original P(i)', color='steelblue', alpha=0.8)
ax.bar(x + width/2, filtered, width, label=f'Filtered (ε={epsilon})', color='coral', alpha=0.8)
ax.axhline(y=epsilon, color='red', linestyle='--', alpha=0.7, label=f'Threshold ε={epsilon}')
ax.set_xlabel('Basis state index', fontsize=12)
ax.set_ylabel('Probability', fontsize=12)
ax.set_title('Probability Filtering\n(Infinitesimal Outcomes Removed)', fontsize=13)
ax.legend(fontsize=10)
ax.set_xticks(x)

# Plot 3: Idempotency demonstration
ax = axes[1, 0]
epsilons = np.linspace(0.01, 0.5, 50)
p_test = 0.15

values = []
for eps in epsilons:
    sp1 = 0.0 if p_test < eps else p_test
    sp2 = 0.0 if sp1 < eps else sp1
    values.append((sp1, sp2))

sp1_vals = [v[0] for v in values]
sp2_vals = [v[1] for v in values]

ax.plot(epsilons, sp1_vals, 'b-', linewidth=2.5, label='stdPart(p, ε)')
ax.plot(epsilons, sp2_vals, 'r--', linewidth=2, label='stdPart(stdPart(p, ε), ε)')
ax.axhline(y=p_test, color='green', linestyle=':', alpha=0.7, label=f'p = {p_test}')
ax.set_xlabel('Threshold ε', fontsize=12)
ax.set_ylabel('Filtered value', fontsize=12)
ax.set_title(f'Idempotency: stdPart ∘ stdPart = stdPart\n(p = {p_test})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 4: Entropy before and after filtering
ax = axes[1, 1]
n_states = 20
np.random.seed(123)
amplitudes = np.random.randn(n_states) + 1j * np.random.randn(n_states)
amplitudes = amplitudes / np.linalg.norm(amplitudes)
probs = np.abs(amplitudes) ** 2

eps_range = np.linspace(0, 0.15, 100)
entropies = []
n_surviving = []

for eps in eps_range:
    filtered_p = np.where(probs < eps, 0.0, probs)
    total = filtered_p.sum()
    if total > 0:
        normalized = filtered_p / total
        H = 0.0
        for p_val in normalized:
            if p_val > 1e-15:
                H -= p_val * np.log(p_val)
        entropies.append(H)
    else:
        entropies.append(0.0)
    n_surviving.append(np.sum(filtered_p > 0))

ax2 = ax.twinx()
ax.plot(eps_range, entropies, 'b-', linewidth=2, label='Entropy')
ax2.plot(eps_range, n_surviving, 'r--', linewidth=2, label='# surviving states')
ax.set_xlabel('Threshold ε', fontsize=12)
ax.set_ylabel('Shannon Entropy H', color='blue', fontsize=12)
ax2.set_ylabel('Surviving states', color='red', fontsize=12)
ax.set_title(f'Entropy vs. Filtering Threshold\n({n_states}-state system)', fontsize=13)
lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax.legend(lines1 + lines2, labels1 + labels2, fontsize=10, loc='center right')
ax.grid(True, alpha=0.3)

fig.suptitle('Standard Part Filter: Infinitesimal Probability Collapse',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_standard_part.png', dpi=150, bbox_inches='tight')
print("Saved viz_standard_part.png")
