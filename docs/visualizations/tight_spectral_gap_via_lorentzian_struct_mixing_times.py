#!/usr/bin/env python3
"""
Visualization 3: Mixing Time and Convergence of Certificate-Guided Chains

Shows the convergence of the Markov chain to its stationary distribution,
comparing the theoretical mixing time bounds (log-concave vs Lorentzian).
Includes a heatmap of transition probabilities.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def build_chain(pi):
    n = len(pi) - 1
    P = np.zeros((n + 1, n + 1))
    for i in range(n + 1):
        if pi[i] == 0:
            P[i, i] = 1.0
            continue
        if i > 0 and pi[i - 1] > 0:
            P[i, i - 1] = 0.5 * min(1.0, pi[i - 1] / pi[i])
        if i < n and pi[i + 1] > 0:
            P[i, i + 1] = 0.5 * min(1.0, pi[i + 1] / pi[i])
        P[i, i] = 1.0 - np.sum(P[i, :])
    return P

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

n = 40

coeffs = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
pi = coeffs / np.sum(coeffs)
P = build_chain(pi)

# Panel 1: Convergence to stationarity
# Start from extreme distributions
starts = [
    (np.eye(n + 1)[0], 'Start at 0'),
    (np.eye(n + 1)[n], f'Start at {n}'),
    (np.eye(n + 1)[n // 2], f'Start at {n//2}'),
]

time_steps = [0, 5, 20, 50, 100, 500]
colors = plt.cm.viridis(np.linspace(0, 1, len(time_steps)))

for start_dist, start_name in starts[:1]:
    current = start_dist.copy()
    for t_idx, t in enumerate(time_steps):
        # Evolve to time t
        if t_idx == 0:
            axes[0, 0].plot(range(n + 1), current, '-', color=colors[t_idx],
                          alpha=0.7, label=f't={t}', linewidth=1.5)
        else:
            prev_t = time_steps[t_idx - 1]
            for _ in range(t - prev_t):
                current = current @ P
            axes[0, 0].plot(range(n + 1), current, '-', color=colors[t_idx],
                          alpha=0.7, label=f't={t}', linewidth=1.5)

axes[0, 0].plot(range(n + 1), pi, 'k--', linewidth=2, alpha=0.5, label='Stationary π')
axes[0, 0].set_xlabel('State k', fontsize=11)
axes[0, 0].set_ylabel('Probability', fontsize=11)
axes[0, 0].set_title('Convergence to Stationarity (start at 0)', fontsize=13)
axes[0, 0].legend(fontsize=9, loc='upper right')
axes[0, 0].grid(True, alpha=0.3)

# Panel 2: Total variation distance over time
max_t = 300
tv_distances = {name: [] for _, name in starts}

for start_dist, start_name in starts:
    current = start_dist.copy()
    for t in range(max_t):
        tv = 0.5 * np.sum(np.abs(current - pi))
        tv_distances[start_name].append(tv)
        current = current @ P

for start_name, tvs in tv_distances.items():
    axes[0, 1].semilogy(range(max_t), tvs, linewidth=1.5, label=start_name)

# Theoretical bounds
eigs = np.sort(np.abs(np.real(np.linalg.eigvals(P))))[::-1]
gap = 1.0 - eigs[1]
lor_bound = 1.0 / (2 * n)  # Lorentzian bound
lc_bound = 1.0 / (8 * (n + 1) ** 2)  # Log-concave bound

axes[0, 1].axvline(x=1/gap * np.log(n+1), color='green', linestyle='--',
                   alpha=0.5, label=f'Exact t_mix ≈ {1/gap * np.log(n+1):.0f}')
axes[0, 1].axvline(x=1/lor_bound * np.log(n+1), color='blue', linestyle=':',
                   alpha=0.5, label=f'Lorentzian bound ≈ {1/lor_bound * np.log(n+1):.0f}')

axes[0, 1].set_xlabel('Time steps t', fontsize=11)
axes[0, 1].set_ylabel('Total variation distance', fontsize=11)
axes[0, 1].set_title('Mixing: TV Distance Decay', fontsize=13)
axes[0, 1].legend(fontsize=8, loc='upper right')
axes[0, 1].grid(True, alpha=0.3)
axes[0, 1].set_ylim(1e-6, 1)

# Panel 3: Transition matrix heatmap
# Show a portion of the transition matrix
show_n = min(25, n + 1)
im = axes[1, 0].imshow(P[:show_n, :show_n], cmap='YlOrRd', aspect='auto',
                       interpolation='nearest')
plt.colorbar(im, ax=axes[1, 0], label='P(x,y)')
axes[1, 0].set_xlabel('State y', fontsize=11)
axes[1, 0].set_ylabel('State x', fontsize=11)
axes[1, 0].set_title(f'Transition Matrix (first {show_n} states)', fontsize=13)

# Panel 4: Mixing time scaling
n_values = list(range(5, 201, 5))
exact_mixing = []
lor_mixing = []
lc_mixing = []

for nn in n_values:
    coeffs = np.array([comb(nn, k) for k in range(nn + 1)], dtype=float)
    pi_n = coeffs / np.sum(coeffs)
    P_n = build_chain(pi_n)
    eigs = np.sort(np.abs(np.real(np.linalg.eigvals(P_n))))[::-1]
    gap = 1.0 - eigs[1]

    exact_mixing.append(1.0 / gap * np.log(nn + 1))
    lor_mixing.append(2 * nn * np.log(nn + 1))  # 1/(1/(2n)) * log(n+1)
    lc_mixing.append(8 * (nn + 1) ** 2 * np.log(nn + 1))

axes[1, 1].loglog(n_values, exact_mixing, 'b-', linewidth=2, label='Exact mixing time')
axes[1, 1].loglog(n_values, lor_mixing, 'g--', linewidth=1.5, label='Lorentzian bound O(n·log n)')
axes[1, 1].loglog(n_values, lc_mixing, 'r:', linewidth=1.5, label='Log-concave bound O(n²·log n)')

axes[1, 1].set_xlabel('n', fontsize=11)
axes[1, 1].set_ylabel('Mixing time (steps)', fontsize=11)
axes[1, 1].set_title('Mixing Time Scaling', fontsize=13)
axes[1, 1].legend(fontsize=10, loc='upper left')
axes[1, 1].grid(True, alpha=0.3)

plt.suptitle('Markov Chain Convergence and Mixing Times', fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('mixing_times.png', dpi=150, bbox_inches='tight')
print("Saved mixing_times.png")
