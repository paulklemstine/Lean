#!/usr/bin/env python3
"""
Fibonacci Anyon Fusion System — Numerical Demonstrations

This script demonstrates the key mathematical results from our formalization
of topological quantum computing with Fibonacci anyons:

1. Fibonacci fusion path counting
2. Golden ratio as quantum dimension
3. Topological entanglement entropy
4. Braid representation matrices (Jones representation at k=5)
"""

import numpy as np
from typing import Tuple, List

# ============================================================
# 1. Fibonacci Fusion Path Counting
# ============================================================

def fusion_path_count(n: int, outcome: int) -> int:
    """Count fusion paths for n τ-anyons to outcome (0=vacuum, 1=τ).
    
    This implements the recurrence:
      D(0,0) = 1, D(0,1) = 0
      D(1,0) = 0, D(1,1) = 1  
      D(n+2, 0) = D(n+1, 1)
      D(n+2, 1) = D(n+1, 0) + D(n+1, 1)
    """
    if n == 0:
        return 1 if outcome == 0 else 0
    if n == 1:
        return 0 if outcome == 0 else 1
    # Iterative computation
    d0_prev, d1_prev = 1, 0  # n=0
    d0_curr, d1_curr = 0, 1  # n=1
    for _ in range(n - 1):
        d0_next = d1_curr
        d1_next = d0_curr + d1_curr
        d0_prev, d1_prev = d0_curr, d1_curr
        d0_curr, d1_curr = d0_next, d1_next
    return d0_curr if outcome == 0 else d1_curr


def total_fusion_dim(n: int) -> int:
    """Total fusion space dimension for n τ-anyons."""
    return fusion_path_count(n, 0) + fusion_path_count(n, 1)


def fibonacci(n: int) -> int:
    """Compute the n-th Fibonacci number (F(0)=0, F(1)=1, F(2)=1, ...)."""
    if n <= 0:
        return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


print("=" * 60)
print("FIBONACCI FUSION DIMENSION THEOREM")
print("totalFusionDim(n) = Fib(n+1)")
print("=" * 60)
print(f"{'n':>3} | {'totalFusionDim(n)':>18} | {'Fib(n+1)':>10} | {'Match':>5}")
print("-" * 50)
for n in range(1, 16):
    td = total_fusion_dim(n)
    fib = fibonacci(n + 1)
    print(f"{n:>3} | {td:>18} | {fib:>10} | {'✓' if td == fib else '✗':>5}")

print()
print(f"fusionPathCount(n, τ) = Fib(n) for n ≥ 1:")
for n in range(1, 11):
    print(f"  n={n}: D(n,τ) = {fusion_path_count(n, 1)}, Fib({n}) = {fibonacci(n)}")

# ============================================================
# 2. Golden Ratio as Quantum Dimension
# ============================================================

phi = (1 + np.sqrt(5)) / 2

print()
print("=" * 60)
print("GOLDEN RATIO QUANTUM DIMENSION")
print("φ² = φ + 1  (quantum dimension equation)")
print("=" * 60)
print(f"φ = {phi:.15f}")
print(f"φ² = {phi**2:.15f}")
print(f"φ + 1 = {phi + 1:.15f}")
print(f"|φ² - (φ+1)| = {abs(phi**2 - (phi + 1)):.2e}")
print()
print(f"D² = 1 + φ² = {1 + phi**2:.15f}")
print(f"2 + φ = {2 + phi:.15f}")
print(f"|D² - (2+φ)| = {abs(1 + phi**2 - (2 + phi)):.2e}")

# ============================================================
# 3. Information Capacity
# ============================================================

print()
print("=" * 60)
print("QUANTUM INFORMATION CAPACITY")
print("n anyons encode ≤ n·log₂(φ) ≈ 0.694n qubits")
print("=" * 60)
log2_phi = np.log2(phi)
print(f"log₂(φ) = {log2_phi:.6f}")
print()
print(f"{'n':>3} | {'Dim':>8} | {'log₂(Dim)':>10} | {'n·log₂(φ)':>10} | {'Efficiency':>10}")
print("-" * 55)
for n in range(2, 21):
    dim = total_fusion_dim(n)
    actual_bits = np.log2(dim) if dim > 0 else 0
    capacity = n * log2_phi
    efficiency = actual_bits / capacity if capacity > 0 else 0
    print(f"{n:>3} | {dim:>8} | {actual_bits:>10.4f} | {capacity:>10.4f} | {efficiency:>10.4f}")

# ============================================================
# 4. Topological Entanglement Entropy
# ============================================================

print()
print("=" * 60)
print("TOPOLOGICAL ENTANGLEMENT ENTROPY")
print("S_topo = ln(D) where D² = 2 + φ")
print("=" * 60)
D_sq = 2 + phi
D = np.sqrt(D_sq)
S_topo = np.log(D)
print(f"D² = 2 + φ = {D_sq:.10f}")
print(f"D = √(2+φ) = {D:.10f}")
print(f"S_topo = ln(D) = {S_topo:.10f}")
print(f"S_topo > 0: {S_topo > 0}")

# ============================================================
# 5. Jones Representation Matrices (k=5, B_4)
# ============================================================

print()
print("=" * 60)
print("JONES REPRESENTATION AT k=5 (FIBONACCI ANYONS)")
print("Braid generators σ₁, σ₂, σ₃ for B₄")
print("=" * 60)

# At level k=5, root of unity q = e^{2πi/5}
q = np.exp(2j * np.pi / 5)
# The quantum parameter A = q^{1/2}
A = np.exp(1j * np.pi / 5)

# For the Fibonacci anyon representation, the R-matrix eigenvalues are:
# R_1 = e^{-4πi/5} (vacuum channel)
# R_τ = e^{3πi/5}  (τ channel)
R_vac = np.exp(-4j * np.pi / 5)  
R_tau = np.exp(3j * np.pi / 5)

print(f"q = e^(2πi/5) = {q:.6f}")
print(f"A = e^(πi/5) = {A:.6f}")
print(f"R(vacuum channel) = e^(-4πi/5) = {R_vac:.6f}")
print(f"R(τ channel) = e^(3πi/5) = {R_tau:.6f}")

# F-matrix for Fibonacci anyons (6j symbol):
# F[τ,τ,τ,τ] = [[φ⁻¹, φ^{-1/2}], [φ^{-1/2}, -φ⁻¹]]
phi_inv = 1 / phi
phi_sqrt_inv = 1 / np.sqrt(phi)

F = np.array([
    [phi_inv, phi_sqrt_inv],
    [phi_sqrt_inv, -phi_inv]
])

print(f"\nF-matrix (Fibonacci 6j symbol):")
print(f"F = [[φ⁻¹, φ^(-1/2)], [φ^(-1/2), -φ⁻¹]]")
print(f"  = {F}")

# Verify F is unitary
print(f"F is unitary: {np.allclose(F @ F.conj().T, np.eye(2))}")
print(f"F² = I: {np.allclose(F @ F, np.eye(2))}")

# Braid matrices in 2D (for 3 anyons):
R = np.diag([R_vac, R_tau])
sigma1_3strand = R
sigma2_3strand = F @ R @ F

print(f"\nσ₁ (3-strand) =\n{sigma1_3strand}")
print(f"\nσ₂ (3-strand) =\n{sigma2_3strand}")

# Verify unitarity
print(f"\n|det(σ₁)| = {abs(np.linalg.det(sigma1_3strand)):.10f}")
print(f"|det(σ₂)| = {abs(np.linalg.det(sigma2_3strand)):.10f}")

# Check if σ₁σ₂σ₁ = σ₂σ₁σ₂ (Yang-Baxter)
lhs = sigma1_3strand @ sigma2_3strand @ sigma1_3strand
rhs = sigma2_3strand @ sigma1_3strand @ sigma2_3strand
print(f"\nYang-Baxter check: σ₁σ₂σ₁ = σ₂σ₁σ₂: {np.allclose(lhs, rhs)}")

# ============================================================
# 6. Growth Rate Convergence
# ============================================================

print()
print("=" * 60)
print("FUSION GROWTH RATIO → φ")
print("totalFusionDim(n+1) / totalFusionDim(n) → φ")
print("=" * 60)
print(f"{'n':>3} | {'ratio':>15} | {'φ':>15} | {'|error|':>12}")
print("-" * 55)
for n in range(2, 21):
    ratio = total_fusion_dim(n + 1) / total_fusion_dim(n)
    error = abs(ratio - phi)
    print(f"{n:>3} | {ratio:>15.12f} | {phi:>15.12f} | {error:>12.2e}")

print()
print("=" * 60)
print("DEMO COMPLETE — All key theorems numerically verified")
print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Jones Representation Braid Matrices for Fibonacci Anyons"""

import matplotlib.pyplot as plt
import numpy as np


def fibonacci_f_matrix():
    phi = (1 + np.sqrt(5)) / 2
    phi_inv = 1 / phi
    phi_sqrt_inv = 1 / np.sqrt(phi)
    return np.array([[phi_inv, phi_sqrt_inv], [phi_sqrt_inv, -phi_inv]])


def fibonacci_r_matrix():
    R_vac = np.exp(-4j * np.pi / 5)
    R_tau = np.exp(3j * np.pi / 5)
    return np.diag([R_vac, R_tau])


def braid_generators_3strand():
    F = fibonacci_f_matrix()
    R = fibonacci_r_matrix()
    sigma1 = R
    sigma2 = F @ R @ F
    return sigma1, sigma2


fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Jones Representation at k=5 (Fibonacci Anyons, 3 Strands)', 
             fontsize=14, fontweight='bold')

sigma1, sigma2 = braid_generators_3strand()

# Plot braid generator matrices
for idx, (mat, name) in enumerate([(sigma1, 'σ₁'), (sigma2, 'σ₂'), 
                                     (sigma1 @ sigma2, 'σ₁σ₂')]):
    # Real part
    ax_re = axes[0, idx]
    im = ax_re.imshow(np.real(mat), cmap='RdBu', vmin=-1, vmax=1, aspect='equal')
    ax_re.set_title(f'Re({name})')
    for i in range(2):
        for j in range(2):
            ax_re.text(j, i, f'{np.real(mat[i,j]):.3f}', ha='center', va='center', fontsize=10)
    plt.colorbar(im, ax=ax_re, shrink=0.6)
    
    # Imaginary part
    ax_im = axes[1, idx]
    im2 = ax_im.imshow(np.imag(mat), cmap='PiYG', vmin=-1, vmax=1, aspect='equal')
    ax_im.set_title(f'Im({name})')
    for i in range(2):
        for j in range(2):
            ax_im.text(j, i, f'{np.imag(mat[i,j]):.3f}', ha='center', va='center', fontsize=10)
    plt.colorbar(im2, ax=ax_im, shrink=0.6)

plt.tight_layout()
plt.savefig('braid_matrices.png', dpi=150, bbox_inches='tight')
plt.close()

# Second figure: dense coverage of SU(2) by braid words
fig2, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig2.suptitle('Dense Generation: Braid Words Cover SU(2)', fontsize=14, fontweight='bold')

sigma1, sigma2 = braid_generators_3strand()
generators = [sigma1, sigma2, np.linalg.inv(sigma1), np.linalg.inv(sigma2)]

# Generate braid words up to length L and plot their trace
traces_re = []
traces_im = []
lengths = []

identity = np.eye(2, dtype=complex)
current_set = [(identity, 0)]

for length in range(1, 9):
    next_set = []
    for mat, _ in current_set:
        for gen in generators:
            new_mat = mat @ gen
            tr = np.trace(new_mat)
            traces_re.append(np.real(tr))
            traces_im.append(np.imag(tr))
            lengths.append(length)
            next_set.append((new_mat, length))
    current_set = next_set
    if len(current_set) > 5000:
        indices = np.random.choice(len(current_set), 5000, replace=False)
        current_set = [current_set[i] for i in indices]

ax1.scatter(traces_re, traces_im, c=lengths, cmap='viridis', s=1, alpha=0.5)
ax1.set_xlabel('Re(Tr(σ))')
ax1.set_ylabel('Im(Tr(σ))')
ax1.set_title('Traces of Braid Words (colored by length)')
ax1.set_xlim([-2.5, 2.5])
ax1.set_ylim([-2.5, 2.5])

# Theoretical boundary: trace of SU(2) lies in [-2, 2]
theta = np.linspace(0, 2*np.pi, 100)
ax1.plot(2*np.cos(theta), 2*np.sin(theta), 'r-', linewidth=1.5, label='|Tr| = 2')
ax1.legend()
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.2)

# Plot density of traces vs length
for L in [3, 5, 7]:
    mask = np.array(lengths) <= L
    subset_re = np.array(traces_re)[mask]
    if len(subset_re) > 0:
        ax2.hist(subset_re, bins=50, alpha=0.4, label=f'Length ≤ {L}', density=True)

ax2.set_xlabel('Re(Tr(σ))')
ax2.set_ylabel('Density')
ax2.set_title('Trace Distribution (approaches uniform)')
ax2.legend()
ax2.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('braid_density.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved braid_matrices.png and braid_density.png")


#!/usr/bin/env python3
"""Visualization: Fibonacci Anyon Fusion Trees and Dimension Growth"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def fibonacci(n):
    if n <= 0: return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def fusion_path_count(n, outcome):
    if n == 0: return 1 if outcome == 0 else 0
    if n == 1: return 0 if outcome == 0 else 1
    d0, d1 = 0, 1
    for _ in range(n - 1):
        d0, d1 = d1, d0 + d1
    return d0 if outcome == 0 else d1


def total_fusion_dim(n):
    return fusion_path_count(n, 0) + fusion_path_count(n, 1)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Fibonacci Anyon Fusion System: Key Properties', fontsize=16, fontweight='bold')

# Plot 1: Fusion dimension vs Fibonacci numbers
ax1 = axes[0, 0]
ns = list(range(1, 16))
dims = [total_fusion_dim(n) for n in ns]
fibs = [fibonacci(n + 1) for n in ns]
ax1.semilogy(ns, dims, 'bo-', markersize=8, label='totalFusionDim(n)')
ax1.semilogy(ns, fibs, 'rx--', markersize=8, label='Fib(n+1)')
ax1.set_xlabel('Number of anyons (n)')
ax1.set_ylabel('Dimension')
ax1.set_title('Theorem: totalFusionDim(n) = Fib(n+1)')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Growth ratio convergence to φ
ax2 = axes[0, 1]
phi = (1 + np.sqrt(5)) / 2
ratios = [total_fusion_dim(n + 1) / total_fusion_dim(n) for n in range(2, 25)]
ns_ratio = list(range(2, 25))
ax2.plot(ns_ratio, ratios, 'go-', markersize=6, label='Dim(n+1)/Dim(n)')
ax2.axhline(y=phi, color='r', linestyle='--', linewidth=2, label=f'φ = {phi:.6f}')
ax2.set_xlabel('Number of anyons (n)')
ax2.set_ylabel('Growth ratio')
ax2.set_title('Theorem: Growth ratio → φ (golden ratio)')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_ylim([1.5, 1.8])

# Plot 3: Vacuum vs τ fusion paths
ax3 = axes[1, 0]
ns3 = list(range(1, 16))
vac = [fusion_path_count(n, 0) for n in ns3]
tau = [fusion_path_count(n, 1) for n in ns3]
width = 0.35
x = np.arange(len(ns3))
ax3.bar(x - width/2, vac, width, color='steelblue', label='To vacuum (Fib(n-1))')
ax3.bar(x + width/2, tau, width, color='coral', label='To τ (Fib(n))')
ax3.set_xlabel('Number of anyons (n)')
ax3.set_ylabel('Number of paths')
ax3.set_title('Fusion Paths by Outcome')
ax3.set_xticks(x)
ax3.set_xticklabels(ns3)
ax3.legend()
ax3.grid(True, alpha=0.3, axis='y')

# Plot 4: Information capacity
ax4 = axes[1, 1]
ns4 = list(range(2, 25))
log2_phi = np.log2(phi)
actual_bits = [np.log2(total_fusion_dim(n)) for n in ns4]
capacity = [n * log2_phi for n in ns4]
ax4.plot(ns4, actual_bits, 'b^-', markersize=6, label='log₂(totalFusionDim(n))')
ax4.plot(ns4, capacity, 'r--', linewidth=2, label=f'n · log₂(φ) ≈ {log2_phi:.3f}n')
ax4.fill_between(ns4, actual_bits, capacity, alpha=0.1, color='blue')
ax4.set_xlabel('Number of anyons (n)')
ax4.set_ylabel('Qubits')
ax4.set_title('Quantum Information Capacity')
ax4.legend()
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('fusion_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved fusion_visualization.png")
