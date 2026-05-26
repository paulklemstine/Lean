"""
Phase Diagram Visualization: Quantum-Classical Transition

This script visualizes the phase transition between quantum advantage and
classical simulability as a function of noise level. The certified threshold
(from Theorem 1) marks the boundary below which quantum advantage is
geometrically guaranteed.

Visualizes: The Lorentzian gap degradation curve, certified threshold,
and empirical survival rate for K_n matching Hessians (n=3..7).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def compute_lorentzian_gap(A):
    eigenvalues = np.linalg.eigvalsh(A)
    eigenvalues = np.sort(eigenvalues)[::-1]
    return -eigenvalues[1] if A.shape[0] >= 2 else float('inf')


def simulate_survival(A, noise_levels, num_samples=80):
    n = A.shape[0]
    survival = []
    avg_gaps = []
    for eta in noise_levels:
        gaps = []
        for _ in range(num_samples):
            E = np.random.randn(n, n)
            E = (E + E.T) / 2
            norm = np.linalg.norm(E, ord=2)
            if norm > 0:
                E = E / norm * eta
            g = compute_lorentzian_gap(A + E)
            gaps.append(g)
        survival.append(np.mean([g > 0 for g in gaps]))
        avg_gaps.append(np.mean(gaps))
    return np.array(survival), np.array(avg_gaps)


np.random.seed(2025)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Gap degradation for K5
ax = axes[0]
n = 5
adj = np.ones((n, n)) - np.eye(n)
H = adj
gap = compute_lorentzian_gap(H)
threshold = gap / 2

noise = np.linspace(0, gap * 1.5, 100)
theory_gap = np.maximum(gap - noise, 0)
_, emp_gap = simulate_survival(H, noise, num_samples=60)

ax.plot(noise, theory_gap, 'b-', linewidth=2.5, label='Theoretical bound (ε − δ)')
ax.plot(noise, emp_gap, 'ro', markersize=3, alpha=0.6, label='Empirical average gap')
ax.axvline(threshold, color='green', linestyle='--', linewidth=2,
           label=f'Certified threshold (ε/2 = {threshold:.2f})')
ax.axvline(gap, color='red', linestyle=':', linewidth=2,
           label=f'Gap collapse (ε = {gap:.2f})')
ax.fill_between(noise, 0, theory_gap, alpha=0.1, color='blue')
ax.fill_betweenx([0, gap], 0, threshold, alpha=0.1, color='green',
                  label='Quantum advantage zone')
ax.set_xlabel('Noise level δ', fontsize=13)
ax.set_ylabel('Lorentzian gap', fontsize=13)
ax.set_title(f'Phase Diagram: K₅ Matching Hessian', fontsize=14, fontweight='bold')
ax.legend(fontsize=9, loc='upper right')
ax.set_ylim(bottom=-0.5)
ax.grid(True, alpha=0.3)

# Panel 2: Survival rate comparison across graph sizes
ax = axes[1]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))
for idx, n in enumerate(range(3, 8)):
    adj = np.ones((n, n)) - np.eye(n)
    H = adj
    gap = compute_lorentzian_gap(H)
    noise = np.linspace(0, gap * 1.5, 40)
    survival, _ = simulate_survival(H, noise, num_samples=40)
    ax.plot(noise / gap, survival, '-o', color=colors[idx], markersize=3,
            linewidth=2, label=f'K_{n} (gap={gap:.1f})')
    ax.axvline(0.5, color='gray', linestyle='--', alpha=0.3)

ax.set_xlabel('Normalized noise (δ / gap)', fontsize=13)
ax.set_ylabel('Survival rate', fontsize=13)
ax.set_title('Survival Rate vs Normalized Noise', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.set_xlim(0, 1.5)
ax.grid(True, alpha=0.3)

# Panel 3: Certified threshold scaling
ax = axes[2]
sizes = list(range(3, 12))
gaps_complete = []
gaps_cycle = []
gaps_path = []

for n in sizes:
    # Complete
    adj = np.ones((n, n)) - np.eye(n)
    gaps_complete.append(compute_lorentzian_gap(-adj) / 2)
    # Cycle
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i, (i+1) % n] = 1
        adj[(i+1) % n, i] = 1
    gaps_cycle.append(compute_lorentzian_gap(-adj) / 2)
    # Path
    adj = np.zeros((n, n))
    for i in range(n-1):
        adj[i, i+1] = 1
        adj[i+1, i] = 1
    gaps_path.append(compute_lorentzian_gap(-adj) / 2)

ax.plot(sizes, gaps_complete, 's-', color='#e74c3c', linewidth=2.5,
        markersize=8, label='Complete graph Kₙ')
ax.plot(sizes, gaps_cycle, 'D-', color='#3498db', linewidth=2.5,
        markersize=8, label='Cycle graph Cₙ')
ax.plot(sizes, gaps_path, 'o-', color='#2ecc71', linewidth=2.5,
        markersize=8, label='Path graph Pₙ')
ax.set_xlabel('Graph size n', fontsize=13)
ax.set_ylabel('Certified threshold (ε/2)', fontsize=13)
ax.set_title('Threshold Scaling by Graph Family', fontsize=14, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved phase_diagram.png")
