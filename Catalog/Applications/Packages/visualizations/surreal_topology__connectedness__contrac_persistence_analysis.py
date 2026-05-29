"""
Visualization: Persistence Analysis of Surreal Approximants

Visualizes the persistent homology (Betti-0) of bounded-day dyadic
approximants at increasing precision levels. This tests the conjecture
that Vietoris-Rips complexes on surreal approximants converge to a
contractible limit.

The key insight: at each fixed day level, the dyadic approximants form
a finite metric space. As we increase the connectivity radius ε, connected
components merge. The persistence diagram reveals the multi-scale structure.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Persistent Homology of Dyadic Approximants',
             fontsize=16, fontweight='bold', y=0.98)

def bounded_day_dyadics(n):
    """Generate sorted dyadic rationals k/2^n for |k| ≤ 2^n."""
    denom = 2 ** n
    return sorted(set(k / denom for k in range(-denom, denom + 1)))

def compute_merge_events(points):
    """Compute the epsilon values at which components merge.

    Returns list of gap sizes (sorted), which are the critical
    epsilon values in the persistence diagram.
    """
    gaps = [points[i+1] - points[i] for i in range(len(points) - 1)]
    return sorted(gaps)

def betti_curve(points, eps_range):
    """Compute Betti-0 as function of epsilon."""
    n = len(points)
    gaps = sorted(points[i+1] - points[i] for i in range(n-1))
    result = []
    for eps in eps_range:
        components = n
        for g in gaps:
            if g <= eps:
                components -= 1
        result.append(max(1, components))
    return result

# --- Panel 1: Betti-0 curves for different days ---
ax1 = axes[0, 0]
eps_range = np.linspace(0.001, 0.5, 200)

for day in range(1, 6):
    pts = bounded_day_dyadics(day)
    b0 = betti_curve(pts, eps_range)
    ax1.plot(eps_range, b0, linewidth=2, label=f'Day {day} ({len(pts)} pts)')

ax1.set_xlabel('ε (connectivity radius)', fontsize=11)
ax1.set_ylabel('β₀ (connected components)', fontsize=11)
ax1.set_title('Betti-0 Curves by Day', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_yscale('log')
ax1.set_ylim(0.8, 600)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Persistence diagram (birth-death) ---
ax2 = axes[0, 1]

for day in [2, 3, 4]:
    pts = bounded_day_dyadics(day)
    gaps = compute_merge_events(pts)

    # Each gap is a death time; all births are at 0
    births = [0] * len(gaps)
    deaths = gaps

    color = plt.cm.Set1(day / 6)
    ax2.scatter(births, deaths, s=30, alpha=0.6, color=color,
                label=f'Day {day}', zorder=5)

# Diagonal line (trivial features)
max_d = 0.6
ax2.plot([0, max_d], [0, max_d], 'k--', alpha=0.3, linewidth=1)

ax2.set_xlabel('Birth (ε)', fontsize=11)
ax2.set_ylabel('Death (ε)', fontsize=11)
ax2.set_title('Persistence Diagram (H₀)', fontsize=13)
ax2.legend(fontsize=9)
ax2.set_xlim(-0.02, max_d)
ax2.set_ylim(-0.02, max_d)
ax2.grid(True, alpha=0.3)
ax2.set_aspect('equal')

# --- Panel 3: Gap distribution ---
ax3 = axes[1, 0]

for day in [2, 3, 4, 5]:
    pts = bounded_day_dyadics(day)
    gaps = [pts[i+1] - pts[i] for i in range(len(pts)-1)]
    unique_gaps = sorted(set(gaps))
    counts = [gaps.count(g) for g in unique_gaps]

    ax3.bar([g + day * 0.002 for g in unique_gaps], counts,
            width=0.005, alpha=0.7, label=f'Day {day}')

ax3.set_xlabel('Gap size', fontsize=11)
ax3.set_ylabel('Frequency', fontsize=11)
ax3.set_title('Gap Distribution by Day', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_xlim(0, 0.35)
ax3.grid(True, alpha=0.3)

# --- Panel 4: Convergence of critical epsilon ---
ax4 = axes[1, 1]

days = range(1, 8)
min_gaps = []
max_gaps = []
mean_gaps = []

for day in days:
    pts = bounded_day_dyadics(day)
    gaps = [pts[i+1] - pts[i] for i in range(len(pts)-1)]
    min_gaps.append(min(gaps))
    max_gaps.append(max(gaps))
    mean_gaps.append(sum(gaps) / len(gaps))

ax4.semilogy(list(days), min_gaps, 'o-', color='red', linewidth=2,
             label='Min gap', markersize=6)
ax4.semilogy(list(days), max_gaps, 's-', color='blue', linewidth=2,
             label='Max gap', markersize=6)
ax4.semilogy(list(days), mean_gaps, 'D-', color='green', linewidth=2,
             label='Mean gap', markersize=6)

# Theoretical: min gap = 1/2^n
theory_min = [1 / 2**d for d in days]
ax4.semilogy(list(days), theory_min, '--', color='gray',
             linewidth=1, label='1/2ⁿ (theory)')

ax4.set_xlabel('Day n', fontsize=11)
ax4.set_ylabel('Gap size', fontsize=11)
ax4.set_title('Gap Statistics Convergence', fontsize=13)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_persistence.png', dpi=150, bbox_inches='tight')
print("Saved viz_persistence.png")
