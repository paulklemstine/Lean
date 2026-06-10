#!/usr/bin/env python3
"""
demo.py — Quantum de Finetti Theorem: Numerical Demonstrations

Demonstrates key results from the formalization:
1. Symmetric subspace dimension vs full Hilbert space
2. De Finetti bound convergence
3. Purity bounds for probability distributions
4. Classical-quantum roundtrip
"""

import numpy as np
from math import comb, factorial

def sym_dim(d: int, k: int) -> int:
    """Dimension of Sym^k(C^d) = C(d+k-1, k)."""
    return comb(d + k - 1, k)

def de_finetti_bound(d: int, k: int, n: int) -> float:
    """Standard de Finetti bound: 2kd²/n."""
    if n == 0:
        return float('inf')
    return 2 * k * d**2 / n

def conjectured_bound(d: int, k: int, n: int) -> float:
    """Conjectured tighter bound: kd(d-1)/n."""
    if n == 0:
        return float('inf')
    return k * d * (d - 1) / n

def purity(p: np.ndarray) -> float:
    """Purity (Herfindahl index) of a probability distribution."""
    return float(np.sum(p**2))

def linear_entropy(p: np.ndarray) -> float:
    """Linear entropy = 1 - purity (Gini-Simpson index)."""
    return 1.0 - purity(p)

def main():
    print("=" * 60)
    print("QUANTUM DE FINETTI THEOREM — NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Symmetric subspace dimension
    print("\n--- Demo 1: Symmetric Subspace Dimension ---")
    print(f"{'k':>4} {'symDim(2,k)':>12} {'2^k':>12} {'ratio':>10}")
    print("-" * 42)
    for k in range(1, 16):
        sd = sym_dim(2, k)
        full = 2**k
        print(f"{k:4d} {sd:12d} {full:12d} {sd/full:10.6f}")

    print("\nFor d=3 (qutrits):")
    print(f"{'k':>4} {'symDim(3,k)':>12} {'3^k':>12} {'ratio':>10}")
    print("-" * 42)
    for k in range(1, 11):
        sd = sym_dim(3, k)
        full = 3**k
        print(f"{k:4d} {sd:12d} {full:12d} {sd/full:10.6f}")

    # Demo 2: De Finetti bound convergence
    print("\n--- Demo 2: De Finetti Bound Convergence ---")
    d, k = 2, 5
    print(f"d={d}, k={k}")
    print(f"{'n':>6} {'standard':>12} {'conjectured':>12}")
    print("-" * 34)
    for n in [10, 50, 100, 500, 1000, 5000, 10000]:
        std = de_finetti_bound(d, k, n)
        conj = conjectured_bound(d, k, n)
        print(f"{n:6d} {std:12.6f} {conj:12.6f}")

    # Demo 3: Purity bounds
    print("\n--- Demo 3: Purity Bounds (1/d ≤ Σpᵢ² ≤ 1) ---")
    for d in [2, 3, 5, 10]:
        # Uniform distribution
        p_uniform = np.ones(d) / d
        # Point mass
        p_point = np.zeros(d)
        p_point[0] = 1.0
        # Random distribution
        rng = np.random.default_rng(42)
        p_random = rng.dirichlet(np.ones(d))

        print(f"\nd = {d}:")
        print(f"  Lower bound 1/d = {1/d:.6f}")
        print(f"  Uniform purity  = {purity(p_uniform):.6f} (= 1/d ✓)")
        print(f"  Random purity   = {purity(p_random):.6f}")
        print(f"  Point mass      = {purity(p_point):.6f} (= 1 ✓)")

    # Demo 4: Classical-quantum roundtrip
    print("\n--- Demo 4: Classical-Quantum Roundtrip ---")
    d = 4
    p = np.array([0.1, 0.3, 0.4, 0.2])
    # classicalEmbed: diagonal matrix
    rho = np.diag(p.astype(complex))
    # measureBasis: extract diagonal
    p_measured = np.real(np.diag(rho))
    print(f"Original p = {p}")
    print(f"Measured p = {p_measured}")
    print(f"Roundtrip exact: {np.allclose(p, p_measured)}")

    # Purity check
    purity_quantum = np.real(np.trace(rho @ rho))
    purity_classical = purity(p)
    print(f"Quantum purity Tr(ρ²) = {purity_quantum:.6f}")
    print(f"Classical HHI Σpᵢ²   = {purity_classical:.6f}")
    print(f"Equal: {np.isclose(purity_quantum, purity_classical)}")

    # Demo 5: Unitary invariance of purity
    print("\n--- Demo 5: Unitary Invariance of Purity ---")
    d = 3
    rho = np.diag([0.5, 0.3, 0.2]).astype(complex)
    # Random unitary (Haar-distributed)
    rng = np.random.default_rng(123)
    H = rng.standard_normal((d, d)) + 1j * rng.standard_normal((d, d))
    U, _ = np.linalg.qr(H)
    rho_rotated = U @ rho @ U.conj().T
    print(f"Original purity:  {np.real(np.trace(rho @ rho)):.10f}")
    print(f"Rotated purity:   {np.real(np.trace(rho_rotated @ rho_rotated)):.10f}")
    print(f"Invariant: {np.isclose(np.trace(rho @ rho), np.trace(rho_rotated @ rho_rotated))}")

    # Demo 6: Additivity of de Finetti bound
    print("\n--- Demo 6: Linearity of de Finetti Bound in k ---")
    d, n = 3, 100
    k1, k2 = 3, 7
    eps_sum = de_finetti_bound(d, k1 + k2, n)
    eps_parts = de_finetti_bound(d, k1, n) + de_finetti_bound(d, k2, n)
    print(f"ε(k₁+k₂) = {eps_sum:.6f}")
    print(f"ε(k₁) + ε(k₂) = {eps_parts:.6f}")
    print(f"Equal: {np.isclose(eps_sum, eps_parts)}")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: De Finetti bound convergence as n → ∞.
Shows how the approximation error decreases with more copies.
"""

import matplotlib.pyplot as plt
import numpy as np

def de_finetti_bound(d: int, k: int, n: int) -> float:
    return 2 * k * d**2 / n

def conjectured_bound(d: int, k: int, n: int) -> float:
    return k * d * (d - 1) / n

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Bound vs n for different (d, k)
ns = np.arange(10, 1001)
configs = [(2, 1, 'Qubit, k=1'), (2, 5, 'Qubit, k=5'),
           (3, 1, 'Qutrit, k=1'), (3, 5, 'Qutrit, k=5')]

for d, k, label in configs:
    bounds = [de_finetti_bound(d, k, n) for n in ns]
    axes[0].plot(ns, bounds, label=label, linewidth=2)

axes[0].axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='ε = 1')
axes[0].set_xlabel('Total copies n', fontsize=12)
axes[0].set_ylabel('De Finetti bound ε', fontsize=12)
axes[0].set_title('Finite de Finetti Bound\n$\\varepsilon \\leq 2kd^2/n$', fontsize=13)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)
axes[0].set_ylim(0, 3)

# Panel 2: Standard vs conjectured bound
d, k = 3, 3
ns2 = np.arange(20, 501)
std_bounds = [de_finetti_bound(d, k, n) for n in ns2]
conj_bounds = [conjectured_bound(d, k, n) for n in ns2]

axes[1].plot(ns2, std_bounds, 'b-', linewidth=2, label=f'Standard: 2kd²/n')
axes[1].plot(ns2, conj_bounds, 'r--', linewidth=2, label=f'Conjectured: kd(d-1)/n')
axes[1].fill_between(ns2, conj_bounds, std_bounds, alpha=0.15, color='purple',
                     label='Gap (potential improvement)')
axes[1].set_xlabel('Total copies n', fontsize=12)
axes[1].set_ylabel('Bound ε', fontsize=12)
axes[1].set_title(f'Standard vs Conjectured Bound\n(d={d}, k={k})', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_definetti_bound.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_definetti_bound.png")


#!/usr/bin/env python3
"""
Visualization: Purity landscape on the probability simplex.
Shows how purity (HHI / Simpson index) varies across distributions.
"""

import matplotlib.pyplot as plt
import numpy as np

def herfindahl(p: np.ndarray) -> float:
    return float(np.sum(p**2))

# For d=3: visualize on the 2-simplex using barycentric coordinates
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Histogram of purity values for random distributions
d_vals = [2, 3, 5, 10, 20]
rng = np.random.default_rng(42)

for d in d_vals:
    purities = [herfindahl(rng.dirichlet(np.ones(d))) for _ in range(10000)]
    axes[0].hist(purities, bins=50, alpha=0.5, density=True, label=f'd={d}')
    axes[0].axvline(x=1/d, linestyle='--', alpha=0.3, color='gray')

axes[0].set_xlabel('Purity (HHI) = Σpᵢ²', fontsize=12)
axes[0].set_ylabel('Density', fontsize=12)
axes[0].set_title('Distribution of Purity\nfor Random Probability Vectors', fontsize=13)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)

# Panel 2: Linear entropy vs purity
purities = np.linspace(0, 1, 200)
lin_ent = 1 - purities

axes[1].plot(purities, lin_ent, 'b-', linewidth=2)
axes[1].fill_between(purities, 0, lin_ent, alpha=0.1, color='blue')

# Mark special points for d=2
axes[1].plot(0.5, 0.5, 'ro', markersize=10, label='Maximally mixed (d=2)')
axes[1].plot(1.0, 0.0, 'gs', markersize=10, label='Pure state')

# Mark bounds for various d
for d in [2, 3, 5, 10]:
    p_min = 1/d
    axes[1].axvline(x=p_min, linestyle=':', alpha=0.4, color='red')
    axes[1].annotate(f'1/{d}', (p_min, 0.9), fontsize=9, color='red', alpha=0.7)

axes[1].set_xlabel('Purity Tr(ρ²)', fontsize=12)
axes[1].set_ylabel('Linear Entropy 1 - Tr(ρ²)', fontsize=12)
axes[1].set_title('Purity–Entropy Duality\n(Gini-Simpson Index)', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_purity_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_purity_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Symmetric subspace dimension vs full Hilbert space.
Shows the exponential compression that drives the de Finetti theorem.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import comb

def sym_dim(d: int, k: int) -> int:
    return comb(d + k - 1, k)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Log scale comparison
ks = list(range(1, 21))
for d in [2, 3, 4]:
    sym_dims = [sym_dim(d, k) for k in ks]
    full_dims = [d**k for k in ks]
    axes[0].semilogy(ks, full_dims, '--', label=f'd={d} full ($d^k$)', alpha=0.6)
    axes[0].semilogy(ks, sym_dims, 'o-', label=f'd={d} symmetric', markersize=4)

axes[0].set_xlabel('Number of copies k', fontsize=12)
axes[0].set_ylabel('Dimension (log scale)', fontsize=12)
axes[0].set_title('Exponential Compression:\nSymmetric vs Full Hilbert Space', fontsize=13)
axes[0].legend(fontsize=9, ncol=2)
axes[0].grid(True, alpha=0.3)

# Panel 2: Ratio sym_dim / full_dim
for d in [2, 3, 4, 5]:
    ratios = [sym_dim(d, k) / d**k for k in ks]
    axes[1].plot(ks, ratios, 'o-', label=f'd={d}', markersize=4)

axes[1].set_xlabel('Number of copies k', fontsize=12)
axes[1].set_ylabel('Ratio: sym_dim / d^k', fontsize=12)
axes[1].set_title('Fraction of Hilbert Space\nin Symmetric Subspace', fontsize=13)
axes[1].set_yscale('log')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_symmetric_subspace.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_symmetric_subspace.png")
