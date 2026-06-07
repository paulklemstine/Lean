#!/usr/bin/env python3
"""
Saturating Arithmetic: Numerical Demonstrations

Demonstrates the key theorems about saturating natural number arithmetic,
including the surprising preservation of distributivity.
"""

def sat_add(N: int, a: int, b: int) -> int:
    """Saturating addition: min(a + b, N)"""
    return min(a + b, N)

def sat_mul(N: int, a: int, b: int) -> int:
    """Saturating multiplication: min(a * b, N)"""
    return min(a * b, N)

def demo_distributivity():
    """Demonstrate that distributivity holds in saturating arithmetic."""
    print("=" * 60)
    print("THEOREM: Saturating Distributivity")
    print("sat_mul(N, a, sat_add(N, b, c)) = sat_add(N, sat_mul(N, a, b), sat_mul(N, a, c))")
    print("=" * 60)

    # Test for various N values
    for N in [5, 10, 20, 100]:
        violations = 0
        total = 0
        for a in range(N + 1):
            for b in range(N + 1):
                for c in range(N + 1):
                    lhs = sat_mul(N, a, sat_add(N, b, c))
                    rhs = sat_add(N, sat_mul(N, a, b), sat_mul(N, a, c))
                    total += 1
                    if lhs != rhs:
                        violations += 1
        print(f"  N = {N:3d}: tested {total:8d} triples, violations = {violations}")
    print()

def demo_associativity():
    """Demonstrate associativity of both operations."""
    print("=" * 60)
    print("THEOREM: Saturating Associativity")
    print("=" * 60)

    for N in [5, 10, 20]:
        add_violations = 0
        mul_violations = 0
        total = 0
        for a in range(N + 1):
            for b in range(N + 1):
                for c in range(N + 1):
                    total += 1
                    if sat_add(N, sat_add(N, a, b), c) != sat_add(N, a, sat_add(N, b, c)):
                        add_violations += 1
                    if sat_mul(N, sat_mul(N, a, b), c) != sat_mul(N, a, sat_mul(N, b, c)):
                        mul_violations += 1
        print(f"  N = {N:3d}: add violations = {add_violations}, mul violations = {mul_violations}")
    print()

def demo_idempotents():
    """Demonstrate idempotent classification."""
    print("=" * 60)
    print("THEOREM: Idempotent Classification")
    print("=" * 60)

    for N in [5, 10, 20]:
        add_idemp = [a for a in range(N + 1) if sat_add(N, a, a) == a]
        mul_idemp = [a for a in range(N + 1) if sat_mul(N, a, a) == a]
        print(f"  N = {N:3d}: additive idempotents = {add_idemp}")
        print(f"         multiplicative idempotents = {mul_idemp}")
    print()

def demo_cancellation_failure():
    """Demonstrate cancellation failure."""
    print("=" * 60)
    print("THEOREM: Cancellation Failure")
    print("=" * 60)

    N = 10
    print(f"  N = {N}")
    print(f"  Additive: sat_add({N}, 8, 5) = {sat_add(N, 8, 5)}, sat_add({N}, 9, 5) = {sat_add(N, 9, 5)}")
    print(f"  But 8 ≠ 9! Cancellation fails because both sums overflow to {N}")
    print()
    print(f"  Multiplicative: sat_mul({N}, 3, 4) = {sat_mul(N, 3, 4)}, sat_mul({N}, 4, 4) = {sat_mul(N, 4, 4)}")
    print(f"  But 3 ≠ 4! Both products overflow to {N}")
    print()

def demo_safe_region_density():
    """Compute the density of the safe region."""
    print("=" * 60)
    print("THEOREM: Safe Region Density")
    print("=" * 60)

    for N in [10, 50, 100, 500, 1000]:
        safe_add = sum(1 for a in range(N + 1) for b in range(N + 1) if a + b <= N)
        total = (N + 1) ** 2
        density = safe_add / total
        theoretical = (N + 1) * (N + 2) / 2 / total
        print(f"  N = {N:4d}: safe pairs = {safe_add:8d}/{total:8d}, "
              f"density = {density:.4f} (theoretical: {theoretical:.4f})")
    print(f"  Limit as N → ∞: density → 1/2 = 0.5000")
    print()

def demo_absorption():
    """Demonstrate the absorbing element N."""
    print("=" * 60)
    print("THEOREM: N is Absorbing ('Infinity')")
    print("=" * 60)

    N = 10
    print(f"  N = {N}")
    for a in range(N + 1):
        assert sat_add(N, N, a) == N, f"Absorption failed for a={a}"
    print(f"  ✓ sat_add({N}, {N}, a) = {N} for all a ∈ [0, {N}]")

    for a in range(1, N + 1):
        assert sat_mul(N, N, a) == N, f"Absorption failed for a={a}"
    print(f"  ✓ sat_mul({N}, {N}, a) = {N} for all a ∈ [1, {N}]")
    print(f"  ⚠ sat_mul({N}, {N}, 0) = {sat_mul(N, N, 0)} (zero annihilates)")
    print()

def demo_saturation_map():
    """Demonstrate the saturation map as semiring homomorphism."""
    print("=" * 60)
    print("THEOREM: Saturation Map Preserves Operations")
    print("=" * 60)

    N = 10
    print(f"  N = {N}")
    print(f"  σ_N(x) = min(x, N)")
    print()

    # Test additive preservation
    violations_add = 0
    violations_mul = 0
    for a in range(2 * N + 1):
        for b in range(2 * N + 1):
            sigma_sum = min(a + b, N)
            sum_sigma = sat_add(N, min(a, N), min(b, N))
            if sigma_sum != sum_sigma:
                violations_add += 1

            sigma_prod = min(a * b, N)
            prod_sigma = sat_mul(N, min(a, N), min(b, N))
            if sigma_prod != prod_sigma:
                violations_mul += 1

    print(f"  Additive preservation σ(a+b) = σ(a) ⊕ σ(b): violations = {violations_add}")
    print(f"  Multiplicative preservation σ(a·b) = σ(a) ⊗ σ(b): violations = {violations_mul}")
    print()

def demo_non_archimedean():
    """Demonstrate the non-Archimedean property."""
    print("=" * 60)
    print("THEOREM: Non-Archimedean Property")
    print("=" * 60)

    N = 100
    a = 7
    print(f"  N = {N}, a = {a}")
    print(f"  Standard ℕ: 7 + 7 + 7 + ... grows without bound")
    print(f"  SatNat {N}: repeated sat_add stays ≤ {N}")

    acc = 0
    for k in range(30):
        acc = sat_add(N, acc, a)
        std = a * (k + 1)
        print(f"    k = {k+1:2d}: sat = {acc:3d}, standard = {std:3d}")
        if acc == N:
            print(f"    ⟨saturated at k = {k+1}⟩")
            break
    print()

if __name__ == "__main__":
    demo_distributivity()
    demo_associativity()
    demo_idempotents()
    demo_cancellation_failure()
    demo_safe_region_density()
    demo_absorption()
    demo_saturation_map()
    demo_non_archimedean()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Saturating Arithmetic Phase Diagram

Generates heatmaps showing the safe/overflow regions for saturating operations,
demonstrating the sharp phase transition that underlies the distributivity proof.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def sat_add(N, a, b):
    return min(a + b, N)


def sat_mul(N, a, b):
    return min(a * b, N)


def plot_safe_region(N=20):
    """Plot the safe region for saturating addition."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Safe region for addition
    ax = axes[0]
    grid = np.zeros((N + 1, N + 1))
    for a in range(N + 1):
        for b in range(N + 1):
            grid[a, b] = 1 if a + b <= N else 0
    im = ax.imshow(grid, origin='lower', cmap='RdYlGn', vmin=0, vmax=1,
                   extent=[-0.5, N + 0.5, -0.5, N + 0.5])
    ax.set_xlabel('b', fontsize=12)
    ax.set_ylabel('a', fontsize=12)
    ax.set_title(f'Safe Region: Addition (N={N})\nGreen = a+b ≤ N', fontsize=13)
    ax.plot([0, N], [N, 0], 'k--', linewidth=2, label='a+b = N')
    ax.legend(fontsize=10)

    # Plot 2: Safe region for multiplication
    ax = axes[1]
    grid = np.zeros((N + 1, N + 1))
    for a in range(N + 1):
        for b in range(N + 1):
            grid[a, b] = 1 if a * b <= N else 0
    im = ax.imshow(grid, origin='lower', cmap='RdYlGn', vmin=0, vmax=1,
                   extent=[-0.5, N + 0.5, -0.5, N + 0.5])
    ax.set_xlabel('b', fontsize=12)
    ax.set_ylabel('a', fontsize=12)
    ax.set_title(f'Safe Region: Multiplication (N={N})\nGreen = a·b ≤ N', fontsize=13)
    # Hyperbola a*b = N
    b_vals = np.linspace(1, N, 200)
    a_vals = N / b_vals
    ax.plot(b_vals, a_vals, 'k--', linewidth=2, label='a·b = N')
    ax.set_xlim(-0.5, N + 0.5)
    ax.set_ylim(-0.5, N + 0.5)
    ax.legend(fontsize=10)

    # Plot 3: Distributivity verification
    ax = axes[2]
    # For fixed a, show |LHS - RHS| for distributivity
    a_fixed = N // 2
    grid = np.zeros((N + 1, N + 1))
    for b in range(N + 1):
        for c in range(N + 1):
            lhs = sat_mul(N, a_fixed, sat_add(N, b, c))
            rhs = sat_add(N, sat_mul(N, a_fixed, b), sat_mul(N, a_fixed, c))
            grid[b, c] = abs(lhs - rhs)
    im = ax.imshow(grid, origin='lower', cmap='hot_r', vmin=0, vmax=max(1, grid.max()),
                   extent=[-0.5, N + 0.5, -0.5, N + 0.5])
    ax.set_xlabel('c', fontsize=12)
    ax.set_ylabel('b', fontsize=12)
    ax.set_title(f'Distributivity Defect (a={a_fixed}, N={N})\n|a⊗(b⊕c) - (a⊗b)⊕(a⊗c)|', fontsize=13)
    plt.colorbar(im, ax=ax, label='Defect')

    plt.tight_layout()
    plt.savefig('sat_arith_phase_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved sat_arith_phase_diagram.png")


def plot_idempotent_landscape(N=15):
    """Visualize idempotent elements across different N values."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Additive idempotents
    ax = axes[0]
    max_N = N
    for n in range(1, max_N + 1):
        for a in range(n + 1):
            if sat_add(n, a, a) == a:
                ax.plot(n, a, 'go', markersize=8, alpha=0.7)
            else:
                ax.plot(n, a, 'r.', markersize=2, alpha=0.3)
    ax.set_xlabel('N (bound)', fontsize=12)
    ax.set_ylabel('a (element)', fontsize=12)
    ax.set_title('Additive Idempotents: a⊕a = a\nGreen = idempotent', fontsize=13)
    ax.plot(range(1, max_N + 1), range(1, max_N + 1), 'g--', alpha=0.5, label='a = N')
    ax.axhline(y=0, color='g', linestyle='--', alpha=0.5, label='a = 0')
    ax.legend(fontsize=10)

    # Multiplicative idempotents
    ax = axes[1]
    for n in range(1, max_N + 1):
        for a in range(n + 1):
            if sat_mul(n, a, a) == a:
                ax.plot(n, a, 'bo', markersize=8, alpha=0.7)
            else:
                ax.plot(n, a, 'r.', markersize=2, alpha=0.3)
    ax.set_xlabel('N (bound)', fontsize=12)
    ax.set_ylabel('a (element)', fontsize=12)
    ax.set_title('Multiplicative Idempotents: a⊗a = a\nBlue = idempotent', fontsize=13)
    ax.plot(range(1, max_N + 1), range(1, max_N + 1), 'b--', alpha=0.5, label='a = N')
    ax.axhline(y=0, color='b', linestyle='--', alpha=0.5, label='a = 0')
    ax.axhline(y=1, color='b', linestyle='--', alpha=0.5, label='a = 1')
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('sat_arith_idempotents.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved sat_arith_idempotents.png")


def plot_density_convergence():
    """Plot the convergence of safe region density to 1/2."""
    fig, ax = plt.subplots(figsize=(10, 6))

    Ns = list(range(1, 201))
    add_densities = []
    mul_densities = []

    for N in Ns:
        # Additive safe count: pairs (a,b) in [0,N]^2 with a+b <= N
        safe_add = (N + 1) * (N + 2) // 2
        total = (N + 1) ** 2
        add_densities.append(safe_add / total)

        # Multiplicative safe count
        safe_mul = sum(1 for a in range(N + 1) for b in range(N + 1) if a * b <= N)
        mul_densities.append(safe_mul / total)

    ax.plot(Ns, add_densities, 'b-', linewidth=2, label='Addition safe density')
    ax.plot(Ns, mul_densities, 'r-', linewidth=2, label='Multiplication safe density')
    ax.axhline(y=0.5, color='b', linestyle='--', alpha=0.5, label='Limit (add) = 1/2')
    ax.set_xlabel('N (bound)', fontsize=12)
    ax.set_ylabel('Density of safe region', fontsize=12)
    ax.set_title('Convergence of Safe Region Density\nas N → ∞', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('sat_arith_density.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved sat_arith_density.png")


if __name__ == "__main__":
    plot_safe_region(N=20)
    plot_idempotent_landscape(N=15)
    plot_density_convergence()
    print("All visualizations generated.")
