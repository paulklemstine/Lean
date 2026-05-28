"""
Visualization: Tropical Profile and Entropy Decomposition

Illustrates two cross-domain connections of Mahler measure:

1. The tropical (Newton polygon) profile of a polynomial, whose slopes
   encode root moduli. The tropicalization τ_f(t) = max_i(log|a_i| + it)
   creates a piecewise-linear convex function whose breakpoints reveal
   the root geometry that determines Mahler measure.

2. The entropy decomposition showing how individual root contributions
   sum to the total dynamical entropy (= Mahler measure), comparing
   Lehmer's polynomial to other famous polynomials.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def polynomial_roots(coeffs):
    return np.roots(list(reversed(coeffs)))

def log_mahler_measure(coeffs):
    if len(coeffs) <= 1:
        return 0.0
    roots = polynomial_roots(coeffs)
    lc = abs(coeffs[-1])
    M = lc * float(np.prod([max(1.0, abs(r)) for r in roots]))
    return float(np.log(M)) if M > 0 else 0.0

# Polynomials to compare
polys = {
    "Lehmer": [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1],
    "Golden (x²-x-1)": [-1, -1, 1],
    "Φ₅ (cyclotomic)": [1, 1, 1, 1, 1],
    "x⁴-x³-x²-x+1": [1, -1, -1, -1, 1],
    "x⁶-x⁴-x³-x²+1": [1, 0, -1, -1, -1, 0, 1],
}

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Panel 1: Tropical profiles ---
ax = axes[0]
t_vals = np.linspace(-2, 2, 500)

for name, coeffs in polys.items():
    tau_vals = np.full_like(t_vals, -np.inf)
    for i, a in enumerate(coeffs):
        if a != 0:
            contribution = np.log(abs(a)) + i * t_vals
            tau_vals = np.maximum(tau_vals, contribution)
    ax.plot(t_vals, tau_vals, linewidth=2, label=f'{name}')

ax.set_xlabel('t (tropicalization parameter)', fontsize=11)
ax.set_ylabel('τ_f(t) = max_i(log|a_i| + it)', fontsize=11)
ax.set_title('Tropical (Newton) Profiles', fontsize=12, fontweight='bold')
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.2)
ax.set_ylim(-3, 12)

# --- Panel 2: Entropy decomposition ---
ax = axes[1]
bar_width = 0.15
x_offset = 0

for idx, (name, coeffs) in enumerate(polys.items()):
    if len(coeffs) <= 1:
        continue
    roots = polynomial_roots(coeffs)
    moduli = sorted([abs(r) for r in roots], reverse=True)
    contribs = [max(0, np.log(m)) for m in moduli]
    
    x_pos = np.arange(len(contribs)) + idx * bar_width
    colors = ['#d62728' if c > 0.001 else '#999999' for c in contribs]
    ax.bar(x_pos, contribs, width=bar_width, alpha=0.7, label=name, edgecolor='black', linewidth=0.3)

ax.set_xlabel('Root index (sorted by modulus)', fontsize=11)
ax.set_ylabel('Entropy contribution: max(0, log|z|)', fontsize=11)
ax.set_title('Entropy Decomposition by Root', fontsize=12, fontweight='bold')
ax.legend(fontsize=7, loc='upper right')
ax.grid(True, alpha=0.2, axis='y')

# --- Panel 3: Comparative Mahler measures ---
ax = axes[2]
names = []
measures = []
colors = []

for name, coeffs in polys.items():
    m = log_mahler_measure(coeffs)
    names.append(name)
    measures.append(m)
    if m < 1e-10:
        colors.append('#2ca02c')  # Green for cyclotomic
    elif name == "Lehmer":
        colors.append('#d62728')  # Red for Lehmer
    else:
        colors.append('#1f77b4')  # Blue for others

bars = ax.barh(range(len(names)), measures, color=colors, alpha=0.8,
               edgecolor='black', linewidth=0.5)
ax.set_yticks(range(len(names)))
ax.set_yticklabels(names, fontsize=9)
ax.set_xlabel('Logarithmic Mahler measure m(f)', fontsize=11)
ax.set_title('Comparative Mahler Measures', fontsize=12, fontweight='bold')
ax.grid(True, alpha=0.2, axis='x')

# Annotate values
for i, (m, name) in enumerate(zip(measures, names)):
    if m > 0.001:
        ax.text(m + 0.01, i, f'{m:.6f}', va='center', fontsize=8, fontweight='bold')
    else:
        ax.text(0.005, i, f'≈ 0 (cyclotomic)', va='center', fontsize=8, color='green')

# Lehmer line
lehmer_m = log_mahler_measure([1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1])
ax.axvline(x=lehmer_m, color='red', linestyle='--', alpha=0.5, linewidth=1)

plt.suptitle("Tropical Geometry and Entropy Structure of Integer Polynomials",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_tropical_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_profile.png")
