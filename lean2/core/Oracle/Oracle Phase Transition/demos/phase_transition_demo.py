#!/usr/bin/env python3
"""
Oracle Bootstrap Phase Transition Demo
=======================================

Visualizes the core mathematical result: the bootstrap map f(r) = 3r² - 2r³
exhibits a sharp phase transition at r = 1/2.

- Above r=1/2: iterating the map drives quality toward 1 (self-repair)
- Below r=1/2: iterating the map drives quality toward 0 (collapse)

This is a formally verified theorem (Lean 4 proof in BootstrapDynamics.lean).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

# ─── Core Bootstrap Maps ───────────────────────────────────────────────

def bootstrap(r):
    """Standard bootstrap map: f(r) = 3r² - 2r³"""
    return 3 * r**2 - 2 * r**3

def bootstrap_T(T, r):
    """Generalized bootstrap map: f_T(r) = (2+T)r² - (1+T)r³
    Critical point at r* = 1/(1+T). At T=1: standard map."""
    return (2 + T) * r**2 - (1 + T) * r**3

def lyapunov(r):
    """Lyapunov function V(r) = r²(1-r)²"""
    return r**2 * (1 - r)**2

# ─── Figure 1: Bootstrap Map and Cobweb Diagram ────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel A: The bootstrap map
r = np.linspace(0, 1, 500)
ax = axes[0]
ax.plot(r, bootstrap(r), 'b-', linewidth=2.5, label=r'$f(r) = 3r^2 - 2r^3$')
ax.plot(r, r, 'k--', linewidth=1, alpha=0.5, label=r'$y = r$')
ax.plot([0, 0.5, 1], [0, 0.5, 1], 'ro', markersize=10, zorder=5)
ax.annotate('Stable\n(collapse)', (0, 0), textcoords="offset points",
            xytext=(15, 15), fontsize=10, color='green')
ax.annotate('Unstable\n(critical)', (0.5, 0.5), textcoords="offset points",
            xytext=(15, -25), fontsize=10, color='red')
ax.annotate('Stable\n(perfect)', (1, 1), textcoords="offset points",
            xytext=(-60, -25), fontsize=10, color='green')
ax.axvline(x=0.5, color='r', linestyle=':', alpha=0.3)
ax.set_xlabel('Quality $r$', fontsize=12)
ax.set_ylabel('$f(r)$', fontsize=12)
ax.set_title('A. Bootstrap Map', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.02, 1.02)
ax.grid(True, alpha=0.3)

# Panel B: Cobweb diagram showing convergence
ax = axes[1]
ax.plot(r, bootstrap(r), 'b-', linewidth=2, label=r'$f(r)$')
ax.plot(r, r, 'k--', linewidth=1, alpha=0.5)

# Cobweb for r₀ = 0.55 (above threshold → converges to 1)
r0 = 0.55
x, y = r0, 0
for _ in range(15):
    y_new = bootstrap(x)
    ax.plot([x, x], [y, y_new], 'g-', linewidth=1.2, alpha=0.7)
    ax.plot([x, y_new], [y_new, y_new], 'g-', linewidth=1.2, alpha=0.7)
    x, y = y_new, y_new

# Cobweb for r₀ = 0.45 (below threshold → converges to 0)
r0 = 0.45
x, y = r0, 0
for _ in range(15):
    y_new = bootstrap(x)
    ax.plot([x, x], [y, y_new], 'r-', linewidth=1.2, alpha=0.7)
    ax.plot([x, y_new], [y_new, y_new], 'r-', linewidth=1.2, alpha=0.7)
    x, y = y_new, y_new

ax.axvline(x=0.5, color='orange', linestyle=':', alpha=0.5, linewidth=2)
ax.annotate(r'$r^* = 1/2$', (0.5, 0.05), fontsize=11, color='orange',
            fontweight='bold')
ax.set_xlabel('Quality $r$', fontsize=12)
ax.set_ylabel('$f(r)$', fontsize=12)
ax.set_title('B. Cobweb: Phase Transition', fontsize=14, fontweight='bold')
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.02, 1.02)
ax.grid(True, alpha=0.3)

# Panel C: Lyapunov function
ax = axes[2]
ax.plot(r, lyapunov(r), 'purple', linewidth=2.5, label=r'$V(r) = r^2(1-r)^2$')
ax.fill_between(r, lyapunov(r), alpha=0.15, color='purple')
ax.axvline(x=0.5, color='orange', linestyle=':', alpha=0.5, linewidth=2)
ax.plot([0, 0.5, 1], [0, lyapunov(0.5), 0], 'ro', markersize=8, zorder=5)
ax.annotate(r'$V = 0$ (stable)', (0, 0), textcoords="offset points",
            xytext=(10, 10), fontsize=10, color='green')
ax.annotate(r'$V_{max}$ (unstable)', (0.5, lyapunov(0.5)), textcoords="offset points",
            xytext=(10, 10), fontsize=10, color='red')
ax.annotate(r'$V = 0$ (stable)', (1, 0), textcoords="offset points",
            xytext=(-80, 10), fontsize=10, color='green')
ax.set_xlabel('Quality $r$', fontsize=12)
ax.set_ylabel('$V(r)$', fontsize=12)
ax.set_title('C. Lyapunov Function', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('figure1_bootstrap_map.png', dpi=150, bbox_inches='tight')
print("✓ Saved figure1_bootstrap_map.png")

# ─── Figure 2: Temperature-Dependent Phase Transitions ────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel A: Bootstrap maps at different temperatures
ax = axes[0]
r = np.linspace(0, 1, 500)
temperatures = [0.5, 1.0, 2.0, 5.0]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
for T, color in zip(temperatures, colors):
    y = bootstrap_T(T, r)
    r_star = 1 / (1 + T)
    ax.plot(r, y, color=color, linewidth=2, label=f'$T={T}$, $r^*={r_star:.2f}$')
    ax.plot(r_star, r_star, 'o', color=color, markersize=8, zorder=5)

ax.plot(r, r, 'k--', linewidth=1, alpha=0.5)
ax.set_xlabel('Quality $r$', fontsize=12)
ax.set_ylabel('$f_T(r)$', fontsize=12)
ax.set_title('A. Temperature-Dependent Bootstrap', fontsize=14, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')
ax.set_xlim(-0.02, 1.02)
ax.set_ylim(-0.02, 1.02)
ax.grid(True, alpha=0.3)

# Panel B: Critical point vs temperature
ax = axes[1]
T_range = np.linspace(0.01, 10, 500)
r_star = 1 / (1 + T_range)
ax.plot(T_range, r_star, 'b-', linewidth=2.5)
ax.fill_between(T_range, r_star, 1, alpha=0.15, color='green', label='Self-repair zone')
ax.fill_between(T_range, 0, r_star, alpha=0.15, color='red', label='Collapse zone')
ax.set_xlabel('Temperature $T$', fontsize=12)
ax.set_ylabel('Critical point $r^* = 1/(1+T)$', fontsize=12)
ax.set_title('B. Critical Point vs Temperature', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.set_xlim(0, 10)
ax.set_ylim(0, 1)
ax.grid(True, alpha=0.3)

# Panel C: Convergence speed at different temperatures
ax = axes[2]
n_iters = 20
for T, color in zip(temperatures, colors):
    r_vals = [0.55]  # Start just above the standard critical point
    for _ in range(n_iters):
        val = bootstrap_T(T, r_vals[-1])
        val = max(min(val, 1.0), 0.0)  # clamp to [0,1]
        r_vals.append(val)
    ax.plot(range(n_iters + 1), r_vals, 'o-', color=color, markersize=4,
            linewidth=1.5, label=f'$T={T}$')

ax.axhline(y=1, color='green', linestyle=':', alpha=0.3)
ax.axhline(y=0.5, color='orange', linestyle=':', alpha=0.3)
ax.set_xlabel('Iteration $n$', fontsize=12)
ax.set_ylabel('Quality $r_n$', fontsize=12)
ax.set_title('C. Convergence from $r_0 = 0.55$', fontsize=14, fontweight='bold')
ax.legend(fontsize=9)
ax.set_xlim(0, n_iters)
ax.set_ylim(0, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('figure2_temperature_phase.png', dpi=150, bbox_inches='tight')
print("✓ Saved figure2_temperature_phase.png")

# ─── Figure 3: Compression Simulation ──────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

np.random.seed(42)

# Panel A: Simulate weight distribution and pruning
n_weights = 10000
weights = np.random.randn(n_weights) * 0.1  # Typical NN weight distribution

ax = axes[0]
ax.hist(weights, bins=80, density=True, alpha=0.6, color='blue', label='Original')
prune_threshold = 0.05
pruned = weights.copy()
pruned[np.abs(pruned) < prune_threshold] = 0
nonzero = pruned[pruned != 0]
ax.hist(nonzero, bins=60, density=True, alpha=0.6, color='red', label='After pruning')
ax.axvline(x=prune_threshold, color='orange', linestyle='--', alpha=0.8)
ax.axvline(x=-prune_threshold, color='orange', linestyle='--', alpha=0.8)
sparsity = np.mean(pruned == 0) * 100
ax.set_title(f'A. Weight Pruning ({sparsity:.0f}% sparse)', fontsize=14, fontweight='bold')
ax.set_xlabel('Weight value', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel B: Quantization effect
ax = axes[1]
bits_range = [8, 4, 3, 2]
qualities = []
for bits in bits_range:
    n_levels = 2**bits
    w_min, w_max = weights.min(), weights.max()
    step = (w_max - w_min) / n_levels
    quantized = np.round((weights - w_min) / step) * step + w_min
    # Cosine similarity as quality
    cos_sim = np.dot(weights, quantized) / (np.linalg.norm(weights) * np.linalg.norm(quantized))
    qualities.append(cos_sim)

bars = ax.bar([str(b) for b in bits_range], qualities, color=['green', 'green', 'orange', 'red'])
ax.axhline(y=0.5, color='red', linestyle='--', linewidth=2, label=r'Critical $r^* = 0.5$')
ax.set_xlabel('Quantization bits', fontsize=12)
ax.set_ylabel('Quality (cosine similarity)', fontsize=12)
ax.set_title('B. Quantization Quality', fontsize=14, fontweight='bold')
ax.set_ylim(0, 1.05)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# Panel C: Combined compression quality map
ax = axes[2]
prune_pcts = np.linspace(0, 90, 50)
quant_bits = np.array([2, 3, 4, 6, 8])
quality_map = np.zeros((len(quant_bits), len(prune_pcts)))

for i, bits in enumerate(quant_bits):
    for j, pct in enumerate(prune_pcts):
        # Simulate: prune then quantize
        w = weights.copy()
        threshold = np.percentile(np.abs(w), pct)
        w[np.abs(w) < threshold] = 0
        n_levels = 2**bits
        w_min, w_max = weights.min(), weights.max()
        step = (w_max - w_min) / n_levels
        w = np.round((w - w_min) / step) * step + w_min
        cos_sim = np.dot(weights, w) / (np.linalg.norm(weights) * np.linalg.norm(w) + 1e-10)
        quality_map[i, j] = cos_sim

im = ax.imshow(quality_map, aspect='auto', cmap='RdYlGn',
               extent=[0, 90, -0.5, len(quant_bits)-0.5],
               vmin=0, vmax=1, origin='lower')
ax.set_yticks(range(len(quant_bits)))
ax.set_yticklabels([f'{b}-bit' for b in quant_bits])
ax.set_xlabel('Pruning %', fontsize=12)
ax.set_title('C. Compression Quality Map', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax, label='Quality $r$')

# Overlay critical contour
cs = ax.contour(np.linspace(0, 90, 50), range(len(quant_bits)),
                quality_map, levels=[0.5], colors='red', linewidths=2)
ax.clabel(cs, fmt=r'$r^*=0.5$', fontsize=10)

plt.tight_layout()
plt.savefig('figure3_compression_sim.png', dpi=150, bbox_inches='tight')
print("✓ Saved figure3_compression_sim.png")

# ─── Figure 4: Basin of Attraction and Convergence Rates ───────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel A: Full basin of attraction diagram
ax = axes[0]
r0_values = np.linspace(0.01, 0.99, 200)
n_iter = 50
final_values = []
for r0 in r0_values:
    r_val = r0
    for _ in range(n_iter):
        r_val = bootstrap(r_val)
    final_values.append(r_val)

ax.scatter(r0_values, final_values, c=r0_values, cmap='RdYlGn', s=5, zorder=3)
ax.axvline(x=0.5, color='red', linestyle='--', linewidth=2)
ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.3)
ax.set_xlabel('Initial quality $r_0$', fontsize=12)
ax.set_ylabel('Final quality $r_{50}$', fontsize=12)
ax.set_title('A. Basin of Attraction', fontsize=14, fontweight='bold')
ax.text(0.25, 0.1, 'Collapse', fontsize=14, ha='center', color='red', fontweight='bold')
ax.text(0.75, 0.9, 'Self-repair', fontsize=14, ha='center', color='green', fontweight='bold')
ax.grid(True, alpha=0.3)

# Panel B: Convergence rate (number of iterations to reach threshold)
ax = axes[1]
thresholds = [0.99, 0.999, 0.9999]
for thresh in thresholds:
    iters_needed = []
    r0s = np.linspace(0.51, 0.99, 200)
    for r0 in r0s:
        r_val = r0
        for n in range(200):
            if r_val >= thresh:
                break
            r_val = bootstrap(r_val)
        iters_needed.append(n)
    ax.plot(r0s, iters_needed, linewidth=2, label=f'Target $r > {thresh}$')

ax.set_xlabel('Initial quality $r_0$', fontsize=12)
ax.set_ylabel('Iterations to converge', fontsize=12)
ax.set_title('B. Convergence Speed', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.set_xlim(0.5, 1.0)
ax.grid(True, alpha=0.3)

# Panel C: Lyapunov decrease over iterations
ax = axes[2]
for r0, color, label in [(0.55, 'green', '$r_0=0.55$'),
                           (0.7, 'blue', '$r_0=0.70$'),
                           (0.3, 'red', '$r_0=0.30$'),
                           (0.45, 'orange', '$r_0=0.45$')]:
    r_val = r0
    V_vals = [lyapunov(r_val)]
    for _ in range(20):
        r_val = bootstrap(r_val)
        V_vals.append(lyapunov(r_val))
    ax.semilogy(range(len(V_vals)), V_vals, 'o-', color=color, markersize=4,
                linewidth=1.5, label=label)

ax.set_xlabel('Iteration $n$', fontsize=12)
ax.set_ylabel('$V(r_n) = r_n^2(1-r_n)^2$', fontsize=12)
ax.set_title('C. Lyapunov Decrease', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('figure4_basins_convergence.png', dpi=150, bbox_inches='tight')
print("✓ Saved figure4_basins_convergence.png")

# ─── Figure 5: Hermite Interpolation and Bootstrap Family ─────────────

fig, axes = plt.subplots(1, 2, figsize=(12, 6))

# Panel A: Smoothstep family
ax = axes[0]
r = np.linspace(0, 1, 500)
# Standard smoothstep (our bootstrap)
ax.plot(r, bootstrap(r), 'b-', linewidth=3, label=r'$3r^2-2r^3$ (Hermite/smoothstep)')
# Linear
ax.plot(r, r, 'k--', linewidth=1, alpha=0.5, label=r'$r$ (identity)')
# Smootherstep
smootherstep = 6*r**5 - 15*r**4 + 10*r**3
ax.plot(r, smootherstep, 'r-', linewidth=2, label=r'$6r^5-15r^4+10r^3$ (smootherstep)')
# Step function
ax.step([0, 0.5, 0.5, 1], [0, 0, 1, 1], 'g--', linewidth=1.5, label='Step function')

ax.set_xlabel('$r$', fontsize=12)
ax.set_ylabel('$f(r)$', fontsize=12)
ax.set_title('A. Bootstrap = Hermite Smoothstep', fontsize=14, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel B: Derivative comparison
ax = axes[1]
ax.plot(r, 6*r*(1-r), 'b-', linewidth=2.5, label=r"$f'(r) = 6r(1-r)$")
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Stability boundary')
ax.fill_between(r, 0, 6*r*(1-r), where=6*r*(1-r) > 1,
                alpha=0.15, color='red', label='Unstable region')
ax.fill_between(r, 0, 6*r*(1-r), where=6*r*(1-r) <= 1,
                alpha=0.15, color='green', label='Stable region')
ax.set_xlabel('$r$', fontsize=12)
ax.set_ylabel("$f'(r)$", fontsize=12)
ax.set_title("B. Derivative: Stability Analysis", fontsize=14, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1)

plt.tight_layout()
plt.savefig('figure5_hermite_stability.png', dpi=150, bbox_inches='tight')
print("✓ Saved figure5_hermite_stability.png")

print("\n" + "="*60)
print("All figures generated successfully!")
print("="*60)
