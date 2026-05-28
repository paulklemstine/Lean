"""
Visualization 3: Discrete Semiconcavity and Shape Control
==========================================================

This script visualizes the discrete semiconcavity theorem:
bounded second differences confine a sequence within a parabolic
envelope around any linear interpolant.

Applied to log(e_k), bounded Newton ratios force the log-esymm
profile to be approximately affine — connecting algebraic
combinatorics to discrete convex analysis.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def esymm_from_spectrum(spectrum):
    n = len(spectrum)
    e = np.zeros(n + 1)
    e[0] = 1.0
    for i in range(n):
        for k in range(min(i + 1, n), 0, -1):
            e[k] += spectrum[i] * e[k - 1]
    return e


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Abstract semiconcavity illustration
N = 20
C = 0.3
np.random.seed(42)

# Generate a sequence with bounded second differences
f = np.zeros(N + 1)
f[0] = 0
increments = np.random.uniform(-0.5, 0.5, N)
for i in range(N):
    f[i + 1] = f[i] + increments[i]
    if i > 0:
        second_diff = f[i+1] - 2*f[i] + f[i-1]
        if second_diff > C:
            f[i+1] = 2*f[i] - f[i-1] + C
        elif second_diff < -C:
            f[i+1] = 2*f[i] - f[i-1] - C

# Linear interpolant
L = np.array([(N-j)/N * f[0] + j/N * f[N] for j in range(N+1)])

# Parabolic envelope
j_vals = np.arange(N+1)
upper_env = L + C * j_vals * (N - j_vals) / 2
lower_env = L - C * j_vals * (N - j_vals) / 2

axes[0, 0].fill_between(j_vals, lower_env, upper_env, alpha=0.15, color='blue', label='Parabolic envelope')
axes[0, 0].plot(j_vals, f, 'ko-', markersize=3, linewidth=1.5, label='f(j)')
axes[0, 0].plot(j_vals, L, 'r--', linewidth=1.5, label='Linear interpolant')
axes[0, 0].plot(j_vals, upper_env, 'b:', linewidth=1, alpha=0.7)
axes[0, 0].plot(j_vals, lower_env, 'b:', linewidth=1, alpha=0.7)
axes[0, 0].set_xlabel('j')
axes[0, 0].set_ylabel('f(j)')
axes[0, 0].set_title(f'Semiconcavity: |D²f| ≤ {C} → parabolic envelope')
axes[0, 0].legend(fontsize=8)
axes[0, 0].grid(True, alpha=0.2)

# Panel 2: Varying C values
for C_val, color, ls in [(0.1, '#2ecc71', '-'), (0.3, '#3498db', '--'),
                          (0.8, '#e74c3c', '-.')]:
    env_upper = L + C_val * j_vals * (N - j_vals) / 2
    env_lower = L - C_val * j_vals * (N - j_vals) / 2
    axes[0, 1].fill_between(j_vals, env_lower, env_upper, alpha=0.1, color=color)
    axes[0, 1].plot(j_vals, env_upper, color=color, linestyle=ls, linewidth=1.5,
                    label=f'C = {C_val}')
    axes[0, 1].plot(j_vals, env_lower, color=color, linestyle=ls, linewidth=1.5)

axes[0, 1].plot(j_vals, L, 'k-', linewidth=1, alpha=0.5, label='Interpolant')
axes[0, 1].set_xlabel('j')
axes[0, 1].set_ylabel('Envelope bounds')
axes[0, 1].set_title('Envelope Width Grows with C')
axes[0, 1].legend(fontsize=8)
axes[0, 1].grid(True, alpha=0.2)

# Panel 3: Application to log(e_k) profiles
n = 12
spectra = {
    'Pinched [0.4, 0.6]': np.random.RandomState(42).uniform(0.4, 0.6, n),
    'Moderate [0.2, 0.8]': np.random.RandomState(42).uniform(0.2, 0.8, n),
    'Wide [0.05, 0.95]': np.random.RandomState(42).uniform(0.05, 0.95, n),
}
colors = ['#2ecc71', '#3498db', '#e74c3c']

for (name, spec), color in zip(spectra.items(), colors):
    e = esymm_from_spectrum(spec)
    log_e = [np.log(e[k]) if e[k] > 0 else np.nan for k in range(n+1)]
    
    # Compute max |second difference| = max |log rho_k|
    max_C = 0
    for k in range(1, n):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            sd = abs(log_e[k+1] - 2*log_e[k] + log_e[k-1])
            max_C = max(max_C, sd)
    
    axes[1, 0].plot(range(n+1), log_e, 'o-', color=color, markersize=4,
                    label=f'{name} (C={max_C:.2f})')
    
    # Show interpolant
    if not np.isnan(log_e[0]) and not np.isnan(log_e[n]):
        interp = [(n-j)/n * log_e[0] + j/n * log_e[n] for j in range(n+1)]
        axes[1, 0].plot(range(n+1), interp, '--', color=color, alpha=0.3)

axes[1, 0].set_xlabel('Index k')
axes[1, 0].set_ylabel('log e_k')
axes[1, 0].set_title('Log-esymm Profiles (dashed = interpolants)')
axes[1, 0].legend(fontsize=7)
axes[1, 0].grid(True, alpha=0.2)

# Panel 4: Envelope tightness vs spectral pinching
pinching_ratios = np.linspace(1.0, 10.0, 30)
max_second_diffs = []

for ratio in pinching_ratios:
    a = 1.0
    b = ratio
    np.random.seed(42)
    spec = np.random.uniform(a, b, 10)
    e = esymm_from_spectrum(spec)
    max_sd = 0
    for k in range(1, 10):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            sd = abs(np.log(e[k+1]) - 2*np.log(e[k]) + np.log(e[k-1]))
            max_sd = max(max_sd, sd)
    max_second_diffs.append(max_sd)

axes[1, 1].plot(pinching_ratios, max_second_diffs, 'b-', linewidth=2)
axes[1, 1].set_xlabel('Pinching ratio b/a')
axes[1, 1].set_ylabel('max |D² log e_k|')
axes[1, 1].set_title('Wider Spectral Range → Larger Curvature Bound')
axes[1, 1].axhline(y=0, color='gray', alpha=0.3)
axes[1, 1].grid(True, alpha=0.2)

fig.suptitle('Discrete Semiconcavity: Bounded Curvature Controls Global Shape',
             fontsize=13, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_semiconcavity.png', dpi=150, bbox_inches='tight')
print("Saved: viz_semiconcavity.png")
