#!/usr/bin/env python3
"""
Visualization: Sheaf-Theoretic Stability via Interleaving

Visualizes the stability theorem: if two filtrations are ε-close, their
sheaf event profiles are ε-interleaved. Shows:
- Original and perturbed sheaf profiles
- The ε-shifted envelope demonstrating interleaving
- The stability corridor

This visualizes: sheafEvtProfile_stability
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def path_graph_edges(n):
    return [(i, i+1) for i in range(n-1)]

def degree(n, edges, v):
    return sum(1 for (a,b) in edges if a == v or b == v)

def sheaf_jump(n, edges, filt, c):
    entering = [v for v, fv in enumerate(filt) if abs(fv - c) < 1e-10]
    return sum(degree(n, edges, v) + 1 for v in entering)

def sheaf_event_profile(n, edges, filt, t):
    crit = sorted(set(filt))
    return sum(sheaf_jump(n, edges, filt, c) for c in crit if c <= t + 1e-10)


n = 7
edges = path_graph_edges(n)
filt1 = [float(i) for i in range(n)]
filt2 = [float(i) + 0.4 * math.sin(i * 1.5) for i in range(n)]
epsilon = max(abs(a - b) for a, b in zip(filt1, filt2))

t_range = np.linspace(-1, n + 1, 1000)

prof1 = [sheaf_event_profile(n, edges, filt1, t) for t in t_range]
prof2 = [sheaf_event_profile(n, edges, filt2, t) for t in t_range]
prof1_shifted = [sheaf_event_profile(n, edges, filt1, t + epsilon) for t in t_range]
prof2_shifted = [sheaf_event_profile(n, edges, filt2, t + epsilon) for t in t_range]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 9))

# Top plot: Both profiles with interleaving envelope
ax1.plot(t_range, prof1, color='#2c3e50', linewidth=2.5, label='Profile f₁ (original)')
ax1.plot(t_range, prof2, color='#e74c3c', linewidth=2.5, label='Profile f₂ (perturbed)')
ax1.plot(t_range, prof2_shifted, color='#e74c3c', linewidth=1.5, linestyle='--',
         alpha=0.6, label=f'Profile f₂(t+ε)')
ax1.fill_between(t_range, prof1, prof2_shifted, alpha=0.1, color='#27ae60',
                 label='Interleaving corridor')

for c in sorted(set(filt1)):
    ax1.axvline(x=c, color='#3498db', linestyle=':', alpha=0.2)
for c in sorted(set(filt2)):
    ax1.axvline(x=c, color='#e74c3c', linestyle=':', alpha=0.2)

ax1.set_ylabel('Sheaf Event Profile', fontsize=12)
ax1.set_xlabel('Threshold t', fontsize=11)
ax1.set_title(f'Sheaf-Theoretic Stability: ε-Interleaving (ε = {epsilon:.3f})',
             fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')

# Bottom plot: Profile difference and bound
diff = [abs(p1 - p2) for p1, p2 in zip(prof1, prof2)]
ax2.fill_between(t_range, diff, alpha=0.3, color='#e74c3c')
ax2.plot(t_range, diff, color='#e74c3c', linewidth=2, label='|P₁(t) - P₂(t)|')

# Show that the difference is bounded by the max possible shift
max_diff = max(diff)
ax2.axhline(y=max_diff, color='#2c3e50', linestyle='--', linewidth=1.5,
           label=f'Max difference = {max_diff}')

ax2.set_ylabel('Profile Difference', fontsize=12)
ax2.set_xlabel('Threshold t', fontsize=11)
ax2.set_title('Profile Difference Under Perturbation', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)

# Add annotation
ax2.annotate(f'Stability: profiles are\nε-interleaved with ε={epsilon:.3f}',
            xy=(n/2, max_diff * 0.7),
            fontsize=11, fontweight='bold', color='#27ae60',
            ha='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#eafaf1', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability.png")
