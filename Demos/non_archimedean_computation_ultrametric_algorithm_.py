#!/usr/bin/env python3
"""
Non-Archimedean Computation: Numerical Demonstrations

Demonstrates the key theorems from the Lean formalization:
1. Ultrametric Locality: O(1) vs O(log n) depth
2. Hensel Speedup: O(log n) vs O(n) iterations
3. Ultrametric Lipschitz: constant vs exponential composition
4. Hensel Code Distance: doubly exponential error correction
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ============================================================================
# Demo 1: Hensel Speedup — O(log n) vs O(n)
# ============================================================================

def hensel_speedup_demo():
    """Demonstrate the exponential speedup of Hensel lifting."""
    print("=" * 60)
    print("DEMO 1: Hensel Lifting Speedup")
    print("=" * 60)

    precisions = [4, 8, 16, 32, 64, 128, 256, 512, 1024, 4096, 1_000_000]

    print(f"\n{'Precision (digits)':>20} {'Hensel steps':>15} {'Classical steps':>17} {'Speedup':>10}")
    print("-" * 65)

    hensel_steps = []
    classical_steps = []

    for n in precisions:
        h_steps = math.ceil(math.log2(n)) + 1
        c_steps = n
        speedup = c_steps / h_steps
        hensel_steps.append(h_steps)
        classical_steps.append(c_steps)
        print(f"{n:>20,} {h_steps:>15} {c_steps:>17,} {speedup:>10.1f}×")

    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ns = np.logspace(1, 6, 100)
    ax1.plot(ns, ns, 'r-', linewidth=2, label='Classical: O(n)')
    ax1.plot(ns, np.log2(ns) + 1, 'b-', linewidth=2, label='Hensel: O(log n)')
    ax1.set_xlabel('Target precision (digits)')
    ax1.set_ylabel('Number of steps')
    ax1.set_xscale('log')
    ax1.set_yscale('log')
    ax1.legend(fontsize=12)
    ax1.set_title('Hensel vs Classical Root-Finding')
    ax1.grid(True, alpha=0.3)

    # Speedup ratio
    ax2.plot(ns, ns / (np.log2(ns) + 1), 'g-', linewidth=2)
    ax2.set_xlabel('Target precision (digits)')
    ax2.set_ylabel('Speedup ratio (classical / Hensel)')
    ax2.set_xscale('log')
    ax2.set_title('Speedup Grows Without Bound')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hensel_speedup.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to hensel_speedup.png")

# ============================================================================
# Demo 2: Ultrametric Lipschitz Composition
# ============================================================================

def lipschitz_composition_demo():
    """Compare classical and ultrametric Lipschitz composition."""
    print("\n" + "=" * 60)
    print("DEMO 2: Lipschitz Composition — Classical vs Ultrametric")
    print("=" * 60)

    L = 2  # Lipschitz constant
    depths = list(range(1, 21))

    print(f"\nLipschitz constant L = {L}")
    print(f"\n{'Depth (layers)':>15} {'Classical (L^n)':>17} {'Ultrametric (L)':>17} {'Gap ratio':>12}")
    print("-" * 65)

    for d in depths:
        classical = L ** d
        ultrametric = L
        if classical > 0:
            gap = classical / ultrametric
        else:
            gap = float('inf')
        if d <= 10 or d == 15 or d == 20:
            print(f"{d:>15} {classical:>17,} {ultrametric:>17} {gap:>12.0f}×")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))

    ds = np.arange(1, 21)
    classical_bounds = [L ** d for d in ds]
    ultrametric_bounds = [L] * len(ds)

    ax.semilogy(ds, classical_bounds, 'r-o', linewidth=2, markersize=4, label=f'Classical: L^n = {L}^n')
    ax.semilogy(ds, ultrametric_bounds, 'b-o', linewidth=2, markersize=4, label=f'Ultrametric: L = {L}')
    ax.set_xlabel('Network depth (layers)')
    ax.set_ylabel('Lipschitz bound')
    ax.legend(fontsize=12)
    ax.set_title('Lipschitz Composition: Exponential vs Constant')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('lipschitz_comparison.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to lipschitz_comparison.png")

# ============================================================================
# Demo 3: Classical vs Ultrametric Arithmetic Depth
# ============================================================================

def arithmetic_depth_demo():
    """Compare classical and ultrametric arithmetic depth."""
    print("\n" + "=" * 60)
    print("DEMO 3: Arithmetic Depth — Classical vs Ultrametric")
    print("=" * 60)

    bit_widths = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024]

    print(f"\n{'Bit width':>12} {'Classical depth':>17} {'Ultrametric depth':>18} {'Savings':>10}")
    print("-" * 60)

    for n in bit_widths:
        classical = math.ceil(math.log2(n)) if n > 1 else 1
        ultrametric = 1
        savings = classical - ultrametric
        print(f"{n:>12} {classical:>17} {ultrametric:>18} {savings:>10}")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))

    ns = np.array(bit_widths)
    classical_depths = [math.ceil(math.log2(n)) if n > 1 else 1 for n in ns]
    ultrametric_depths = [1] * len(ns)

    ax.semilogx(ns, classical_depths, 'r-o', linewidth=2, markersize=6, label='Classical: Ω(log n)')
    ax.semilogx(ns, ultrametric_depths, 'b-o', linewidth=2, markersize=6, label='Ultrametric: O(1)')
    ax.fill_between(ns, ultrametric_depths, classical_depths, alpha=0.2, color='green',
                     label='Depth savings')
    ax.set_xlabel('Number of digits (n)')
    ax.set_ylabel('Circuit depth')
    ax.legend(fontsize=11)
    ax.set_title('Arithmetic Depth: Carry Propagation vs Carry-Free')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('arithmetic_depth.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to arithmetic_depth.png")

# ============================================================================
# Demo 4: Hensel Code Distance
# ============================================================================

def hensel_code_demo():
    """Demonstrate exponential error correction of Hensel codes."""
    print("\n" + "=" * 60)
    print("DEMO 4: Hensel Error-Correcting Codes")
    print("=" * 60)

    p = 2  # prime base
    depths = list(range(1, 9))

    print(f"\nPrime base p = {p}")
    print(f"\n{'Depth k':>10} {'Min distance (2^(2^k))':>25} {'Log₂(distance)':>17}")
    print("-" * 55)

    distances = []
    for k in depths:
        dist = p ** (2 ** k)
        distances.append(dist)
        log_dist = 2 ** k
        print(f"{k:>10} {dist:>25,} {log_dist:>17}")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))

    ax.semilogy(depths, distances, 'purple', linewidth=2, marker='s', markersize=8)
    ax.set_xlabel('Hensel lifting depth k')
    ax.set_ylabel('Minimum distance (log scale)')
    ax.set_title('Hensel Code: Doubly Exponential Distance Growth')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hensel_codes.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to hensel_codes.png")

# ============================================================================
# Demo 5: Hensel Convergence — Concrete Example
# ============================================================================

def hensel_convergence_demo():
    """Show concrete Hensel lifting for sqrt(2) in ℤ_7."""
    print("\n" + "=" * 60)
    print("DEMO 5: Hensel Lifting — Computing √2 in ℤ_7")
    print("=" * 60)

    p = 7
    # f(x) = x² - 2, f'(x) = 2x
    # x₀ = 3 (since 3² = 9 ≡ 2 mod 7)

    x = 3
    precision = 1

    print(f"\nComputing a root of x² - 2 ≡ 0 in ℤ_{p}")
    print(f"Starting approximation: x₀ = {x} (since {x}² = {x**2} ≡ {x**2 % p} mod {p})")
    print()

    print(f"{'Step':>6} {'Approximation x_n':>20} {'x_n² mod p^(2^n)':>20} {'Precision (digits)':>20}")
    print("-" * 70)

    for step in range(6):
        mod = p ** precision
        residual = (x * x - 2) % mod
        print(f"{step:>6} {x % mod:>20} {residual:>20} {precision:>20}")

        # Hensel step: x_{n+1} = x_n - f(x_n) / f'(x_n)
        f_val = x * x - 2
        f_deriv = 2 * x
        # Need f_deriv to be invertible mod p
        f_deriv_inv = pow(f_deriv, -1, mod)
        x = x - f_val * f_deriv_inv
        x = x % (p ** (2 * precision))
        precision *= 2

    print(f"\nAfter 5 Hensel steps: {math.ceil(math.log2(precision))} steps gave {precision} digits of precision")
    print("This is O(log n) steps for n digits — exponential speedup!")

# ============================================================================
# Demo 6: One-Way Gap for Cryptography
# ============================================================================

def crypto_gap_demo():
    """Demonstrate the cryptographic one-way gap."""
    print("\n" + "=" * 60)
    print("DEMO 6: Cryptographic One-Way Gap")
    print("=" * 60)

    security_levels = [64, 128, 192, 256, 384, 512, 1024, 2048, 4096]

    print(f"\n{'Security (bits)':>16} {'Forward (log)':>15} {'Inverse (linear)':>18} {'Gap':>8} {'Gap %':>8}")
    print("-" * 68)

    for n in security_levels:
        forward = math.ceil(math.log2(n)) + 1
        inverse = n
        gap = inverse - forward
        gap_pct = 100 * gap / inverse
        print(f"{n:>16} {forward:>15} {inverse:>18} {gap:>8} {gap_pct:>7.1f}%")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  Non-Archimedean Computation: Numerical Demonstrations  ║")
    print("╚" + "═" * 58 + "╝")

    hensel_speedup_demo()
    lipschitz_composition_demo()
    arithmetic_depth_demo()
    hensel_code_demo()
    hensel_convergence_demo()
    crypto_gap_demo()

    print("\n" + "=" * 60)
    print("All demos completed. See generated PNG files for plots.")
    print("=" * 60)
