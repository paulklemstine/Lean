#!/usr/bin/env python3
"""
Visualization: Noise Robustness of the Tropical Partition Witness

Shows how the minimum tropical partition witness value degrades as
noise is added to GHZ and W states. The witness remains positive
for small noise, demonstrating the robustness of tropical
entanglement detection.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct, combinations


# ─── Self-contained core functions ───────────────────────────────────

def all_configs(n, d=2):
    return list(iterproduct(range(d), repeat=n))

def mix_config(A, s, t):
    return tuple(s[i] if i in A else t[i] for i in range(len(s)))

def tropical_partition_witness(n, A, psi, d=2):
    configs = all_configs(n, d)
    mags = {s: abs(psi(s)) for s in configs}
    witness = 0.0
    for s in configs:
        ms = mags[s]
        if ms < 1e-15:
            continue
        for t in configs:
            mt = mags[t]
            if mt < 1e-15:
                continue
            val = ms * mt - mags[mix_config(A, s, t)] * mags[mix_config(A, t, s)]
            if val > 0:
                witness += val
    return witness

def nontrivial_partitions(n):
    result = []
    for k in range(1, n):
        for combo in combinations(range(n), k):
            result.append(frozenset(combo))
    return result

def min_witness(n, psi):
    return min(tropical_partition_witness(n, A, psi) for A in nontrivial_partitions(n))

def ghz_state(n):
    def psi(s): return 1.0 if (all(x == 0 for x in s) or all(x == 1 for x in s)) else 0.0
    return psi

def w_state(n):
    def psi(s): return 1.0 if sum(s) == 1 else 0.0
    return psi

def noisy_state(n, pure_psi, noise_level, seed=0):
    rng = np.random.RandomState(seed)
    configs = all_configs(n)
    pure_amps = {s: pure_psi(s) for s in configs}
    noise = {s: complex(rng.randn(), rng.randn()) * noise_level for s in configs}
    noisy_amps = {s: pure_amps[s] + noise[s] for s in configs}
    norm_val = np.sqrt(sum(abs(a)**2 for a in noisy_amps.values()))
    if norm_val > 0:
        noisy_amps = {s: a / norm_val for s, a in noisy_amps.items()}
    def psi(s):
        return noisy_amps.get(s, 0.0)
    return psi


# ─── Compute noise robustness curves ────────────────────────────────

n = 3
noise_levels = np.linspace(0, 2.0, 40)

ghz_witnesses = []
w_witnesses = []

for eps in noise_levels:
    # Average over multiple noise realizations
    ghz_vals = []
    w_vals = []
    for seed in range(5):
        ghz_noisy = noisy_state(n, ghz_state(n), eps, seed)
        w_noisy = noisy_state(n, w_state(n), eps, seed)
        ghz_vals.append(min_witness(n, ghz_noisy))
        w_vals.append(min_witness(n, w_noisy))
    ghz_witnesses.append((np.mean(ghz_vals), np.std(ghz_vals)))
    w_witnesses.append((np.mean(w_vals), np.std(w_vals)))

ghz_mean = [x[0] for x in ghz_witnesses]
ghz_std = [x[1] for x in ghz_witnesses]
w_mean = [x[0] for x in w_witnesses]
w_std = [x[1] for x in w_witnesses]


# ─── Plot ────────────────────────────────────────────────────────────

fig, ax = plt.subplots(figsize=(10, 6))

ax.plot(noise_levels, ghz_mean, 'b-', linewidth=2, label='GHZ state')
ax.fill_between(noise_levels,
                [m - s for m, s in zip(ghz_mean, ghz_std)],
                [m + s for m, s in zip(ghz_mean, ghz_std)],
                alpha=0.2, color='blue')

ax.plot(noise_levels, w_mean, 'r-', linewidth=2, label='W state')
ax.fill_between(noise_levels,
                [m - s for m, s in zip(w_mean, w_std)],
                [m + s for m, s in zip(w_mean, w_std)],
                alpha=0.2, color='red')

ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel('Noise Level ε', fontsize=12)
ax.set_ylabel('Minimum Tropical Partition Witness', fontsize=12)
ax.set_title('Noise Robustness of Tropical Entanglement Witnesses\n(n = 3 qubits, averaged over 5 noise realizations)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=11, loc='upper right')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 2.0)

# Mark the critical noise threshold
for i, (vals, label, color) in enumerate([(ghz_mean, 'GHZ', 'blue'), (w_mean, 'W', 'red')]):
    threshold_idx = next((j for j in range(len(vals)) if vals[j] < 1e-10), len(vals)-1)
    if threshold_idx < len(noise_levels):
        ax.axvline(x=noise_levels[threshold_idx], color=color, linestyle=':', alpha=0.5)
        ax.annotate(f'{label} threshold ≈ {noise_levels[threshold_idx]:.2f}',
                   xy=(noise_levels[threshold_idx], 0),
                   xytext=(noise_levels[threshold_idx] + 0.1, max(ghz_mean) * (0.3 + 0.2*i)),
                   fontsize=9, color=color,
                   arrowprops=dict(arrowstyle='->', color=color, alpha=0.7))

plt.tight_layout()
plt.savefig('noise_robustness.png', dpi=150, bbox_inches='tight')
print("Saved noise_robustness.png")
