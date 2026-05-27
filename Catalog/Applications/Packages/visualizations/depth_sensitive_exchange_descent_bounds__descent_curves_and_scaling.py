"""
Visualization: Depth-Sensitive Exchange Descent Curves
========================================================

Plots the descent trajectories and theoretical bounds for exchange
descent at different certificate depths. Illustrates the core prediction:
deeper certificates → faster convergence.

Creates a 2x2 figure:
  Top-left: Descent curves at different depths
  Top-right: Step count vs dimension (log scale)
  Bottom-left: Steps/D ratio showing linear regime at k=d
  Bottom-right: Theoretical bound d^{d-k} as function of depth k
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


# ================================================================
# Self-contained implementations
# ================================================================

def exchange_move(x, i, j):
    y = x.copy()
    y[i] += 1
    y[j] -= 1
    return y

def is_in_set(x, S):
    return any(np.array_equal(x, s) for s in S)

def generate_exchange_family(d, radius=2):
    target_sum = 0
    points = []
    for _ in range(min(400, (2*radius+1)**d)):
        x = np.random.randint(-radius, radius+1, size=d)
        x[-1] = target_sum - np.sum(x[:-1])
        if abs(x[-1]) <= radius:
            points.append(x.copy())
    if not points:
        points = [np.zeros(d, dtype=int)]
    unique = []
    for p in points:
        if not any(np.array_equal(p, u) for u in unique):
            unique.append(p)
    return np.array(unique)

def exchange_diameter(S):
    n = len(S)
    mx = 0
    for i in range(n):
        for j in range(i+1, n):
            mx = max(mx, int(np.sum(np.abs(S[i] - S[j]))))
    return mx

def run_descent_trace(S, f, x0, max_steps=5000):
    d = len(x0)
    x = x0.copy()
    fx = f(x)
    trace = [fx]
    for _ in range(max_steps):
        best_y, best_fy = None, fx
        for i in range(d):
            for j in range(d):
                if i == j: continue
                y = exchange_move(x, i, j)
                if is_in_set(y, S):
                    fy = f(y)
                    if fy < best_fy:
                        best_y, best_fy = y.copy(), fy
        if best_y is None:
            break
        x, fx = best_y, best_fy
        trace.append(fx)
    return trace


# ================================================================
# Generate data
# ================================================================

np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Depth-Sensitive Exchange Descent: Certificate Depth Controls Complexity',
             fontsize=14, fontweight='bold', y=0.98)

# --- Panel 1: Descent curves ---
ax = axes[0, 0]
d = 6
radius = 2
S = generate_exchange_family(d, radius)

colors = ['#e74c3c', '#f39c12', '#27ae60', '#2980b9']
labels = ['Low depth (k≈1)', 'Medium (k≈2)', 'High (k≈d-1)', 'Max depth (k=d)']
alphas_list = [0.02, 0.1, 0.3, 0.8]

for idx, (alpha, color, label) in enumerate(zip(alphas_list, colors, labels)):
    centers = np.random.uniform(-1, 1, size=d)
    weights = [lambda v, c=c, a=alpha: np.exp(-a*(v-c)**2) for c in centers]
    f = lambda x, w=weights: -int(sum(w[i](int(x[i]))*1000 for i in range(d)))
    
    x0 = S[np.random.randint(len(S))]
    trace = run_descent_trace(S, f, x0)
    
    # Normalize
    if len(trace) > 1:
        t0, tf = trace[0], trace[-1]
        if t0 != tf:
            normalized = [(t - tf) / (t0 - tf) for t in trace]
        else:
            normalized = [1.0] * len(trace)
    else:
        normalized = [1.0]
    
    ax.plot(range(len(normalized)), normalized, color=color, linewidth=2.5,
            label=label, alpha=0.9)

ax.set_xlabel('Exchange Steps', fontsize=11)
ax.set_ylabel('Normalized Objective Gap', fontsize=11)
ax.set_title('Descent Curves at Different Certificate Depths', fontsize=12)
ax.legend(fontsize=9, loc='upper right')
ax.set_ylim(-0.1, 1.1)
ax.grid(True, alpha=0.3)

# --- Panel 2: Step count vs dimension ---
ax = axes[0, 1]
dims = list(range(4, 9))
steps_high = []
steps_low = []

for dd in dims:
    S = generate_exchange_family(dd, 2)
    if len(S) < 3:
        steps_high.append(0)
        steps_low.append(0)
        continue
    
    # High depth
    centers = np.random.uniform(-0.5, 0.5, size=dd)
    w_h = [lambda v, c=c: np.exp(-0.5*(v-c)**2) for c in centers]
    f_h = lambda x, w=w_h: -int(sum(w[i](int(x[i]))*1000 for i in range(dd)))
    
    # Low depth
    w_l = [lambda v: np.exp(-0.03*v**2 + 0.2*v) for _ in range(dd)]
    f_l = lambda x, w=w_l: -int(sum(w[i](int(x[i]))*1000 for i in range(dd)))
    
    total_h, total_l = 0, 0
    trials = 5
    for _ in range(trials):
        x0 = S[np.random.randint(len(S))]
        total_h += len(run_descent_trace(S, f_h, x0)) - 1
        total_l += len(run_descent_trace(S, f_l, x0)) - 1
    
    steps_high.append(total_h / trials)
    steps_low.append(total_l / trials)

ax.semilogy(dims, [max(s, 0.5) for s in steps_low], 'o-', color='#e74c3c',
            linewidth=2, markersize=8, label='Low depth (k≈1)')
ax.semilogy(dims, [max(s, 0.5) for s in steps_high], 's-', color='#2980b9',
            linewidth=2, markersize=8, label='High depth (k≈d)')
ax.set_xlabel('Dimension d', fontsize=11)
ax.set_ylabel('Average Steps (log scale)', fontsize=11)
ax.set_title('Step Count Scaling with Dimension', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# --- Panel 3: Steps/D ratio ---
ax = axes[1, 0]
dims2 = list(range(4, 9))
ratios = []
for dd in dims2:
    S = generate_exchange_family(dd, 2)
    if len(S) < 3:
        ratios.append(1)
        continue
    D = exchange_diameter(S)
    if D == 0:
        ratios.append(1)
        continue
    
    centers = np.random.uniform(-0.5, 0.5, size=dd)
    w = [lambda v, c=c: np.exp(-0.5*(v-c)**2) for c in centers]
    f = lambda x, ww=w: -int(sum(ww[i](int(x[i]))*1000 for i in range(dd)))
    
    total = 0
    trials = 5
    for _ in range(trials):
        x0 = S[np.random.randint(len(S))]
        total += len(run_descent_trace(S, f, x0)) - 1
    ratios.append((total / trials) / D)

ax.bar(dims2, ratios, color='#2980b9', alpha=0.7, edgecolor='#1a5276')
ax.axhline(y=np.mean(ratios), color='#e74c3c', linestyle='--', linewidth=2,
           label=f'Mean = {np.mean(ratios):.2f}')
ax.set_xlabel('Dimension d', fontsize=11)
ax.set_ylabel('Steps / Diameter', fontsize=11)
ax.set_title('Maximal Depth: Steps/D Ratio (should be ~constant)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# --- Panel 4: Theoretical bound landscape ---
ax = axes[1, 1]
d_vals = np.arange(3, 13)
for k in [1, 2, 3, 5, 8]:
    bounds = []
    for dd in d_vals:
        kk = min(k, dd)
        bounds.append(dd ** max(dd - kk, 0))
    ax.semilogy(d_vals, bounds, 'o-', linewidth=2, markersize=6,
                label=f'k = {k}')

# k = d line
ax.semilogy(d_vals, [1]*len(d_vals), 'k--', linewidth=2.5, label='k = d (LINEAR)')

ax.set_xlabel('Dimension d', fontsize=11)
ax.set_ylabel('Complexity Factor d^{d-k}', fontsize=11)
ax.set_title('Theoretical Bound: d^{d-k} vs Dimension', fontsize=12)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('depth_sensitive_descent.png', dpi=150, bbox_inches='tight')
print("Saved: depth_sensitive_descent.png")
