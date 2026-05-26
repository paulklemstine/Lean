#!/usr/bin/env python3
"""
Visualize the spectral transference principle: how the building Hecke
gap and Cayley gap track each other across the Sp₄(𝔽_q) family.

Shows the comparison band c·gap_Hecke ≤ gap_Cayley ≤ C·gap_Hecke
and illustrates the convergence of both gaps to 1.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def building_hecke_gap(q):
    return 1.0 - 2.0 / np.sqrt(q)

def cayley_gap(q, C=2.0):
    return 1.0 - C / q

def gap_ratio(q, C=2.0):
    gh = building_hecke_gap(q)
    if gh <= 0:
        return float('nan')
    return cayley_gap(q, C) / gh

fig, axes = plt.subplots(2, 2, figsize=(13, 10))

qs = np.array([5, 7, 9, 11, 13, 17, 19, 23, 25, 29, 31, 37, 41,
               49, 53, 61, 67, 73, 79, 89, 97, 101, 121, 169,
               243, 343, 512, 729, 1024])

ghs = np.array([building_hecke_gap(q) for q in qs])
gcs = np.array([cayley_gap(q) for q in qs])
rs = np.array([gap_ratio(q) for q in qs])

# Plot 1: Transference band
ax = axes[0, 0]
q_smooth = np.linspace(5, 1100, 500)
gh_smooth = np.array([building_hecke_gap(q) for q in q_smooth])
gc_smooth = np.array([cayley_gap(q) for q in q_smooth])

# The comparison constants for each q
c_lower = gc_smooth / np.maximum(gh_smooth, 1e-10)
c_upper = c_lower + 1

ax.fill_between(q_smooth, c_lower * gh_smooth, c_upper * gh_smooth,
                alpha=0.15, color='blue', label='Comparison band')
ax.plot(q_smooth, gc_smooth, 'r-', linewidth=2, label='Cayley gap')
ax.plot(q_smooth, gh_smooth, 'b--', linewidth=2, label='Hecke gap')
ax.axhline(y=1.0, color='k', linestyle=':', alpha=0.3)
ax.set_xlabel('q', fontsize=11)
ax.set_ylabel('Spectral gap', fontsize=11)
ax.set_title('Spectral Transference Band', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2)

# Plot 2: Gap difference (Cayley - Hecke)
ax = axes[0, 1]
diffs = gcs - ghs
ax.bar(range(len(qs)), diffs, color=['steelblue' if d >= 0 else 'salmon' for d in diffs],
       alpha=0.8)
ax.set_xticks(range(0, len(qs), 4))
ax.set_xticklabels([str(qs[i]) for i in range(0, len(qs), 4)], rotation=45)
ax.set_xlabel('q', fontsize=11)
ax.set_ylabel('gap_Cayley − gap_Hecke', fontsize=11)
ax.set_title('Gap Difference', fontsize=12)
ax.axhline(y=0, color='k', linewidth=0.5)
ax.grid(True, alpha=0.2)

# Plot 3: Log-log plot of gap defects
ax = axes[1, 0]
defect_c = 1 - gcs  # = C/q
defect_h = 1 - ghs  # = 2/√q
ax.loglog(qs, defect_c, 'rs-', markersize=5, label='1 − gap_Cayley = C/q')
ax.loglog(qs, defect_h, 'bd-', markersize=5, label='1 − gap_Hecke = 2/√q')
# Reference lines
q_ref = np.logspace(np.log10(5), np.log10(1100), 100)
ax.loglog(q_ref, 2.0/q_ref, 'r:', alpha=0.5, label='O(1/q)')
ax.loglog(q_ref, 2.0/np.sqrt(q_ref), 'b:', alpha=0.5, label='O(1/√q)')
ax.set_xlabel('q', fontsize=11)
ax.set_ylabel('Gap defect (1 − gap)', fontsize=11)
ax.set_title('Gap Defect Scaling', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Plot 4: Mixing time comparison
ax = axes[1, 1]
def mixing_time(gap, G_size, eps=0.01):
    if gap <= 0:
        return float('nan')
    return np.log(np.sqrt(G_size) / eps) / gap

def sp4_order(q):
    return q**4 * (q**4 - 1) * (q**2 - 1)

mix_cayley = [mixing_time(cayley_gap(q), sp4_order(q)) for q in qs]
mix_hecke_based = [mixing_time(building_hecke_gap(q), sp4_order(q)) for q in qs]

ax.semilogy(qs, mix_cayley, 'rs-', markersize=5, label='From Cayley gap')
ax.semilogy(qs, mix_hecke_based, 'bd-', markersize=5, label='From Hecke gap')
ax.set_xlabel('q', fontsize=11)
ax.set_ylabel('Mixing time bound', fontsize=11)
ax.set_title('Mixing Time from Different Gap Sources', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2)

plt.suptitle('Spectral Transference: Cayley ↔ Building Hecke for Sp₄(𝔽_q)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('visualize_transference.png', dpi=150, bbox_inches='tight')
print("Saved: visualize_transference.png")
