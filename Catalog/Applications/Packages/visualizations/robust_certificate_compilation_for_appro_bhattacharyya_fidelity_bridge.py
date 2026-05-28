#!/usr/bin/env python3
"""
Visualization: Bhattacharyya–Fidelity Bridge

This script visualizes the cross-domain theorem connecting quantum fidelity
to classical statistical distance (Bhattacharyya coefficient), demonstrating
that the quantum overlap between coefficient states equals the squared
Bhattacharyya coefficient of the corresponding probability distributions.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

def l2_norm(w):
    return np.sqrt(np.sum(w**2))

def normalized_vec(w):
    norm = l2_norm(w)
    return w / norm if norm > 1e-15 else np.zeros_like(w)

def fidelity(w, v):
    return float(np.sum(normalized_vec(w) * normalized_vec(v))**2)

def bhattacharyya_coeff(p, q):
    """BC(p,q) = ∑ √(pᵢ qᵢ)"""
    return float(np.sum(np.sqrt(np.maximum(p * q, 0))))

def tv_dist(w, v):
    return 0.5 * np.sum(np.abs(w - v))

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# ─────────────────────────────────────────────────────────────
# Panel 1: Fidelity = BC² verification
# ─────────────────────────────────────────────────────────────
ax = axes[0, 0]
n = 10
exact = np.array([comb(n, k) for k in range(n + 1)], dtype=float)

fidelities = []
bc_squareds = []
perturbations = np.linspace(0, 5.0, 100)

for eps in perturbations:
    rng = np.random.RandomState(42)
    noise = rng.exponential(1.0, size=len(exact))
    noise = noise / np.sum(noise) * eps
    perturbed = exact + noise
    
    psi_w = normalized_vec(perturbed)
    psi_v = normalized_vec(exact)
    
    f = np.sum(psi_w * psi_v)**2
    p = psi_w**2
    q = psi_v**2
    bc = bhattacharyya_coeff(p, q)
    
    fidelities.append(f)
    bc_squareds.append(bc**2)

ax.plot(perturbations, fidelities, 'b-', linewidth=2, label='Fidelity F(w,v)')
ax.plot(perturbations, bc_squareds, 'r--', linewidth=2, label='BC(p,q)²')
ax.set_xlabel('Perturbation ε', fontsize=11)
ax.set_ylabel('Value', fontsize=11)
ax.set_title('Fidelity = Bhattacharyya²\n(Theorem Verification)', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# ─────────────────────────────────────────────────────────────
# Panel 2: TV distance vs Bhattacharyya for different families
# ─────────────────────────────────────────────────────────────
ax = axes[0, 1]

for n, color, label in [(5, 'blue', 'C(5,k)'), (10, 'red', 'C(10,k)'),
                         (20, 'green', 'C(20,k)')]:
    exact = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
    exact_prob = exact / np.sum(exact)
    
    tvs = []
    bcs = []
    
    for eps in np.linspace(0, 1.0, 80):
        rng = np.random.RandomState(42)
        noise = rng.exponential(1.0, size=len(exact_prob))
        noise = noise / np.sum(noise) * eps
        perturbed_prob = exact_prob + noise
        perturbed_prob = np.maximum(perturbed_prob, 0)
        perturbed_prob = perturbed_prob / np.sum(perturbed_prob)
        
        tvs.append(tv_dist(perturbed_prob, exact_prob))
        bcs.append(bhattacharyya_coeff(perturbed_prob, exact_prob))
    
    ax.plot(tvs, bcs, '-', color=color, linewidth=2, label=label)

# Reference: BC ≥ 1 - TV (Fano's inequality variant)
tv_ref = np.linspace(0, 0.5, 100)
ax.plot(tv_ref, 1 - tv_ref, 'k--', linewidth=1, label='BC = 1 - TV')
ax.set_xlabel('TV Distance', fontsize=11)
ax.set_ylabel('Bhattacharyya Coefficient', fontsize=11)
ax.set_title('TV Distance vs BC\n(Cross-Domain Bridge)', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ─────────────────────────────────────────────────────────────
# Panel 3: Probability landscapes
# ─────────────────────────────────────────────────────────────
ax = axes[1, 0]
n = 10
exact = np.array([comb(n, k) for k in range(n + 1)], dtype=float)
psi_exact = normalized_vec(exact)
p_exact = psi_exact**2

rng = np.random.RandomState(42)
noise = rng.exponential(1.0, size=len(exact))
noise = noise / np.sum(noise) * 2.0
perturbed = exact + noise
psi_perturbed = normalized_vec(perturbed)
p_perturbed = psi_perturbed**2

x = np.arange(n + 1)
width = 0.35
ax.bar(x - width/2, p_exact, width, color='steelblue', alpha=0.8, label='Exact p')
ax.bar(x + width/2, p_perturbed, width, color='salmon', alpha=0.8, label='Perturbed q')
ax.set_xlabel('Index k', fontsize=11)
ax.set_ylabel('Probability', fontsize=11)
ax.set_title(f'Amplitude Distributions\n(C({n},k), ε=2.0)', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

bc = bhattacharyya_coeff(p_exact, p_perturbed)
f = fidelity(perturbed, exact)
ax.text(0.02, 0.95, f'BC = {bc:.4f}\nF = BC² = {f:.4f}',
        transform=ax.transAxes, fontsize=10, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# ─────────────────────────────────────────────────────────────
# Panel 4: The triangle: TV → BC → Fidelity
# ─────────────────────────────────────────────────────────────
ax = axes[1, 1]
n = 10
exact = np.array([comb(n, k) for k in range(n + 1)], dtype=float)

tvs = []
fids = []

for eps in np.linspace(0, 10.0, 200):
    for trial in range(5):
        rng = np.random.RandomState(trial * 100 + int(eps * 10))
        noise = rng.exponential(1.0, size=len(exact))
        noise = noise / np.sum(noise) * eps
        perturbed = exact + noise
        
        tvs.append(tv_dist(perturbed, exact))
        fids.append(fidelity(perturbed, exact))

ax.scatter(tvs, fids, s=2, alpha=0.3, color='blue')

# Theorem bound
tv_range = np.linspace(0, max(tvs), 100)
min_norm = l2_norm(exact) * 0.95  # approximate
bound = np.maximum(1 - 16 * tv_range**2 / min_norm**2, 0)
ax.plot(tv_range, bound, 'r-', linewidth=2, label='Theorem bound')

ax.set_xlabel('TV Distance', fontsize=11)
ax.set_ylabel('Fidelity', fontsize=11)
ax.set_title('Fidelity vs TV Distance\n(Scatter + Bound)', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim([-0.05, 1.05])

plt.suptitle('Bhattacharyya–Fidelity Bridge: Quantum Meets Classical',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_bhattacharyya_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_bhattacharyya_bridge.png")
