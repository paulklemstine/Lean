#!/usr/bin/env python3
"""
Visualization 2: Variance Scaling and KPZ Signature Detection

Analyzes the variance scaling of tagged-card displacement to test
for TASEP/KPZ universality signatures. Key questions:
1. Does Var/t converge to a constant (diffusive) or decay (subdiffusive)?
2. Does the fluctuation distribution deviate from Gaussian?
3. Is there a scaling collapse consistent with KPZ exponents?
"""
import numpy as np
import matplotlib.pyplot as plt

def identity_perm(n):
    return list(range(n))

def swap_step(perm):
    n = len(perm)
    i = np.random.randint(0, n - 1)
    p = perm[:]
    p[i], p[i+1] = p[i+1], p[i]
    return p

np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Var/t ratio vs t for multiple n
ax = axes[0, 0]
num_trials = 3000
for n in [5, 7, 10, 15]:
    j = n // 2
    times = [10, 20, 50, 100, 200, 400]
    ratios = []
    for t in times:
        disps = []
        for _ in range(num_trials):
            perm = identity_perm(n)
            for _ in range(t):
                perm = swap_step(perm)
            disps.append(perm.index(j) - j)
        var = np.var(disps)
        ratios.append(var / t)
    ax.plot(times, ratios, 'o-', markersize=4, linewidth=1.5, label=f'n={n}')

ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Var / t', fontsize=11)
ax.set_title('Variance Scaling: Var(Δ)/t vs t', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_xscale('log')

# Panel 2: Histogram vs Gaussian for n=10
ax = axes[0, 1]
n = 10
j = n // 2
t = n * n
disps = []
for _ in range(8000):
    perm = identity_perm(n)
    for _ in range(t):
        perm = swap_step(perm)
    disps.append(perm.index(j))

disps = np.array(disps, dtype=float)
mean, std = np.mean(disps), np.std(disps)

ax.hist(disps, bins=n, density=True, alpha=0.7, color='#3498db', 
        edgecolor='black', linewidth=0.5, label='Empirical')
x_gauss = np.linspace(0, n-1, 200)
gauss = np.exp(-0.5 * ((x_gauss - mean) / std)**2) / (std * np.sqrt(2 * np.pi))
ax.plot(x_gauss, gauss, 'r-', linewidth=2, label='Gaussian fit')
ax.set_xlabel('Position of tagged card', fontsize=11)
ax.set_ylabel('Density', fontsize=11)
ax.set_title(f'Position Distribution (n={n}, t={t})', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 3: Skewness and excess kurtosis vs n
ax = axes[1, 0]
ns = [5, 6, 7, 8, 10, 12, 15]
skewnesses = []
kurtoses = []
for n in ns:
    j = n // 2
    t = n * n
    disps = []
    for _ in range(5000):
        perm = identity_perm(n)
        for _ in range(t):
            perm = swap_step(perm)
        disps.append(perm.index(j))
    
    data = np.array(disps, dtype=float)
    m, s = np.mean(data), np.std(data)
    if s > 0:
        centered = (data - m) / s
        skewnesses.append(np.mean(centered**3))
        kurtoses.append(np.mean(centered**4) - 3)
    else:
        skewnesses.append(0)
        kurtoses.append(0)

ax.plot(ns, skewnesses, 'o-', color='#e74c3c', markersize=5, linewidth=1.5, label='Skewness')
ax.plot(ns, kurtoses, 's-', color='#2ecc71', markersize=5, linewidth=1.5, label='Excess kurtosis')
ax.axhline(y=0, color='black', linestyle='--', alpha=0.3, label='Gaussian value')
ax.set_xlabel('n', fontsize=11)
ax.set_ylabel('Moment', fontsize=11)
ax.set_title('Non-Gaussianity vs n (at t = n²)', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 4: Var * n² vs t (testing TASEP scaling Var ~ t/n²)
ax = axes[1, 1]
num_trials = 2000
for n in [6, 8, 10, 12]:
    j = n // 2
    times = [5, 10, 20, 50, 100, 150, 200]
    scaled_vars = []
    for t in times:
        disps = []
        for _ in range(num_trials):
            perm = identity_perm(n)
            for _ in range(t):
                perm = swap_step(perm)
            disps.append(perm.index(j) - j)
        var = np.var(disps)
        scaled_vars.append(var * n * n / t if t > 0 else 0)
    ax.plot(times, scaled_vars, 'o-', markersize=4, linewidth=1.5, label=f'n={n}')

ax.set_xlabel('Time t', fontsize=11)
ax.set_ylabel('Var · n² / t', fontsize=11)
ax.set_title('TASEP Scaling Test: Var·n²/t vs t', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

plt.suptitle('KPZ/TASEP Scaling Signatures in Tagged-Card Dynamics', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")
