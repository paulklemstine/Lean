"""
Visualization 2: Phase transition in Lorentzian signature under perturbation.

Shows the probability of Lorentzianity breaking as perturbation magnitude increases,
revealing the sharp phase transition at the spectral gap threshold.

The key insight: the transition occurs precisely at perturbation scale ~ 1/m,
matching the eigengap-to-dimension ratio predicted by the spectral theory.
"""

import numpy as np
import matplotlib.pyplot as plt


def leaf_hessian(m: int) -> np.ndarray:
    return np.ones((m, m)) - np.eye(m)


def check_lorentzian(H: np.ndarray, tol: float = 1e-10) -> bool:
    eigenvalues = np.linalg.eigvalsh(H)
    return np.sum(eigenvalues > tol) <= 1


def break_probability(m: int, scale: float, n_trials: int = 300) -> float:
    """Compute empirical probability that random perturbation breaks Lorentzianity."""
    H = leaf_hessian(m)
    n_breaks = 0
    for _ in range(n_trials):
        E = np.random.uniform(-scale, scale, (m, m))
        E = (E + E.T) / 2
        if not check_lorentzian(H + E):
            n_breaks += 1
    return n_breaks / n_trials


np.random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Phase transition curves for different m
ax1 = axes[0]
m_values = [3, 4, 5, 7, 10]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(m_values)))

for m, color in zip(m_values, colors):
    # Scale relative to 1/m (the natural scale)
    scales = np.linspace(0.01, 3.0 / m, 40)
    probs = [break_probability(m, s, n_trials=200) for s in scales]
    
    ax1.plot(scales * m, probs, '-o', color=color, markersize=3,
             linewidth=2, label=f'm = {m}')
    
    # Mark the certified safe region
    ax1.axvline(x=0.5, color='gray', linestyle=':', alpha=0.3)

ax1.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, linewidth=2,
            label='Spectral gap = 1')
ax1.axvline(x=0.5, color='blue', linestyle=':', alpha=0.5, linewidth=2,
            label='Certified safe (1/2)')

ax1.set_xlabel('Normalized perturbation scale (t × m)', fontsize=12)
ax1.set_ylabel('P(Lorentzianity breaks)', fontsize=12)
ax1.set_title('Phase Transition in Lorentzian Signature\nunder Random Perturbation', fontsize=14)
ax1.legend(fontsize=9, loc='center right')
ax1.set_xlim(0, 3)
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)

# Plot 2: Eigenvalue evolution under diagonal perturbation
ax2 = axes[1]
m = 5
H = leaf_hessian(m)
t_values = np.linspace(-0.5, 2.0, 100)

eigenvalue_traces = []
for t in t_values:
    E = t * np.eye(m)
    eigenvalues = np.sort(np.linalg.eigvalsh(H + E))[::-1]
    eigenvalue_traces.append(eigenvalues)

eigenvalue_traces = np.array(eigenvalue_traces)

for i in range(m):
    if i == 0:
        ax2.plot(t_values, eigenvalue_traces[:, i], 'b-', linewidth=2,
                label=f'λ₁ = {m-1}+t')
    elif i == 1:
        ax2.plot(t_values, eigenvalue_traces[:, i], 'r-', linewidth=2,
                label=f'λ₂=…=λ_{m} = -1+t')
    else:
        ax2.plot(t_values, eigenvalue_traces[:, i], 'r-', linewidth=2)

ax2.axhline(y=0, color='black', linewidth=1, alpha=0.5)
ax2.axvline(x=0, color='gray', linewidth=0.5, alpha=0.3)
ax2.axvline(x=1, color='green', linewidth=2, linestyle='--', alpha=0.7,
            label='Critical: t = 1 (gap)')

# Shade the Lorentzian region
ax2.fill_between(t_values, -3, 8,
                  where=eigenvalue_traces[:, 1] <= 0,
                  alpha=0.1, color='blue', label='Lorentzian region')

ax2.set_xlabel('Diagonal perturbation t', fontsize=12)
ax2.set_ylabel('Eigenvalue', fontsize=12)
ax2.set_title(f'Eigenvalue Evolution (m = {m})\nH + tI = (J-I) + tI', fontsize=14)
ax2.legend(fontsize=9)
ax2.set_ylim(-3, 8)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_perturbation_phase.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_phase.png")
