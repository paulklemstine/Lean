#!/usr/bin/env python3
"""
Spectral Walk Theory — Demonstration Script

Demonstrates the key results from the formal spectral gap theory:
1. Cycle graph spectral gap bounds
2. Mixing distance decay
3. Quantum vs classical speedup
4. Product walk gap computation
"""

import math

def spectral_gap_cycle(n: int) -> float:
    """Exact spectral gap of cycle graph C_n: 1 - cos(2π/n)."""
    return 1 - math.cos(2 * math.pi / n)

def spectral_gap_lower(n: int) -> float:
    """Lower bound: 8/n²."""
    return 8.0 / n**2

def spectral_gap_upper(n: int) -> float:
    """Upper bound: 2π²/n²."""
    return 2 * math.pi**2 / n**2

def mixing_distance(lam2: float, n: int, t: int) -> float:
    """L² mixing distance: λ₂^t · √n."""
    return lam2**t * math.sqrt(n)

def mixing_time(gamma: float, n: int, eps: float = 0.01) -> float:
    """Mixing time estimate: (1/γ) · ln(√n / ε)."""
    return (1 / gamma) * math.log(math.sqrt(n) / eps)

def quantum_relaxation_time(gamma: float) -> float:
    """Quantum relaxation time: 1/√γ."""
    return 1.0 / math.sqrt(gamma)

def classical_relaxation_time(gamma: float) -> float:
    """Classical relaxation time: 1/γ."""
    return 1.0 / gamma

def product_walk_gap(gamma1: float, gamma2: float) -> float:
    """Product walk spectral gap: 1 - (1-γ₁)(1-γ₂)."""
    return 1 - (1 - gamma1) * (1 - gamma2)


def main():
    print("=" * 70)
    print("SPECTRAL WALK THEORY — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Cycle graph spectral gap bounds
    print("\n--- Demo 1: Cycle Graph Spectral Gap Bounds ---")
    print(f"{'n':>5} | {'8/n²':>10} | {'1-cos(2π/n)':>12} | {'2π²/n²':>10} | {'Ratio':>8}")
    print("-" * 55)
    for n in [3, 5, 10, 20, 50, 100, 1000]:
        gap = spectral_gap_cycle(n)
        lb = spectral_gap_lower(n)
        ub = spectral_gap_upper(n)
        ratio = gap / (2 * math.pi**2 / n**2)
        print(f"{n:5d} | {lb:10.6f} | {gap:12.6f} | {ub:10.6f} | {ratio:8.4f}")
        # Verify our formal bounds
        assert lb <= gap + 1e-10, f"Lower bound violated at n={n}!"
        assert gap <= ub + 1e-10, f"Upper bound violated at n={n}!"
    print("✓ All bounds verified numerically.")

    # Demo 2: Mixing distance decay
    print("\n--- Demo 2: Mixing Distance Decay on C₅₀ ---")
    n = 50
    gap = spectral_gap_cycle(n)
    lam2 = 1 - gap
    print(f"C₅₀: spectral gap γ = {gap:.6f}, λ₂ = {lam2:.6f}")
    print(f"{'t':>6} | {'d(t)':>12} | {'d(t)/d(0)':>10}")
    print("-" * 35)
    d0 = mixing_distance(lam2, n, 0)
    for t in [0, 100, 500, 1000, 2000, 2500, 5000]:
        dt = mixing_distance(lam2, n, t)
        print(f"{t:6d} | {dt:12.6f} | {dt/d0:10.6f}")

    t_mix = mixing_time(gap, n)
    print(f"\nEstimated mixing time (ε=0.01): {t_mix:.0f} steps")

    # Demo 3: Quantum vs Classical speedup
    print("\n--- Demo 3: Quantum vs Classical Speedup ---")
    print(f"{'n':>5} | {'γ':>10} | {'1/γ (class.)':>13} | {'1/√γ (quant.)':>14} | {'Speedup':>8}")
    print("-" * 60)
    for n in [10, 50, 100, 500, 1000]:
        gap = spectral_gap_cycle(n)
        classical = classical_relaxation_time(gap)
        quantum = quantum_relaxation_time(gap)
        speedup = classical / quantum
        print(f"{n:5d} | {gap:10.6f} | {classical:13.1f} | {quantum:14.1f} | {speedup:8.1f}")
        assert quantum <= classical + 1e-10, f"Quantum speedup violated at n={n}!"
    print("✓ Quantum speedup 1/√γ ≤ 1/γ verified for all cases.")

    # Demo 4: Product walk spectral gap
    print("\n--- Demo 4: Product Walk Spectral Gap ---")
    pairs = [(0.1, 0.2), (0.3, 0.5), (0.01, 0.99), (0.5, 0.5)]
    print(f"{'γ₁':>6} | {'γ₂':>6} | {'Product gap':>12} | {'min(γ₁,γ₂)':>12} | {'≥ min?':>6}")
    print("-" * 55)
    for g1, g2 in pairs:
        prod_gap = product_walk_gap(g1, g2)
        min_gap = min(g1, g2)
        ok = prod_gap >= min_gap - 1e-10
        print(f"{g1:6.2f} | {g2:6.2f} | {prod_gap:12.6f} | {min_gap:12.6f} | {'✓' if ok else '✗':>6}")
        assert ok, f"Product gap bound violated for ({g1}, {g2})!"
    print("✓ Product walk gap ≥ min(γ₁, γ₂) verified for all pairs.")

    # Demo 5: Laplacian trace bound
    print("\n--- Demo 5: Laplacian Trace Bound ---")
    for n in [3, 5, 10, 20]:
        # Cycle graph eigenvalues: μ_k = 1 - cos(2πk/n) for k=0,...,n-1
        eigenvalues = [1 - math.cos(2 * math.pi * k / n) for k in range(n)]
        trace = sum(eigenvalues)
        bound = 2 * n
        gap = sorted(eigenvalues)[1]
        gap_bound = 2 * n / (n - 1)
        print(f"C_{n:2d}: trace = {trace:6.2f} ≤ {bound:5.0f}, "
              f"μ₂ = {gap:.6f} ≤ {gap_bound:.4f}")
        assert trace <= bound + 1e-10
        assert gap <= gap_bound + 1e-10

    print("\n" + "=" * 70)
    print("All demonstrations passed successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Mixing Distance Decay

Shows the exponential decay of mixing distance d(t) = (1-γ)^t · √n
for different cycle graph sizes.
"""

import math

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available.")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Mixing distance decay for different n
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
    for i, n in enumerate([10, 20, 50, 100, 200]):
        gamma = 1 - math.cos(2 * math.pi / n)
        lam2 = 1 - gamma
        max_t = int(3 * n**2)
        ts = np.linspace(0, max_t, 500)
        ds = np.array([lam2**t * math.sqrt(n) for t in ts])
        ax1.semilogy(ts / n**2, ds, color=colors[i], linewidth=1.5,
                     label=f'$C_{{{n}}}$')

    ax1.axhline(y=0.01, color='black', linestyle=':', alpha=0.5,
                label=r'$\epsilon = 0.01$')
    ax1.set_xlabel(r'$t / n^2$', fontsize=12)
    ax1.set_ylabel(r'Mixing distance $d(t)$', fontsize=12)
    ax1.set_title('Mixing Distance Decay (Normalized Time)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Classical vs Quantum relaxation time
    ns = np.arange(5, 501)
    classical = np.array([1.0 / (1 - math.cos(2 * math.pi / n)) for n in ns])
    quantum = np.array([1.0 / math.sqrt(1 - math.cos(2 * math.pi / n)) for n in ns])

    ax2.loglog(ns, classical, 'b-', linewidth=2, label=r'Classical: $1/\gamma$')
    ax2.loglog(ns, quantum, 'r-', linewidth=2, label=r'Quantum: $1/\sqrt{\gamma}$')
    ax2.loglog(ns, ns**2 / (2*np.pi**2), 'b--', alpha=0.4, label=r'$n^2/(2\pi^2)$')
    ax2.loglog(ns, ns / (np.sqrt(2)*np.pi), 'r--', alpha=0.4, label=r'$n/(\sqrt{2}\pi)$')
    ax2.fill_between(ns, quantum, classical, alpha=0.1, color='green')
    ax2.set_xlabel('Number of vertices n', fontsize=12)
    ax2.set_ylabel('Relaxation time', fontsize=12)
    ax2.set_title('Classical vs Quantum Relaxation', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('mixing_decay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved mixing_decay.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Product Walk Spectral Gap

Shows that the product walk gap satisfies 1-(1-γ₁)(1-γ₂) ≥ min(γ₁,γ₂).
"""

import math

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available.")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Product gap as a function of γ₂, with γ₁ fixed
    gamma1_values = [0.1, 0.3, 0.5, 0.7, 0.9]
    gamma2s = np.linspace(0.01, 0.99, 200)
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(gamma1_values)))

    for g1, color in zip(gamma1_values, colors):
        product_gaps = 1 - (1 - g1) * (1 - gamma2s)
        min_gaps = np.minimum(g1, gamma2s)
        ax1.plot(gamma2s, product_gaps, color=color, linewidth=1.5,
                 label=f'$\\gamma_1 = {g1}$')
        ax1.plot(gamma2s, min_gaps, color=color, linewidth=0.8, linestyle='--',
                 alpha=0.5)

    ax1.set_xlabel(r'$\gamma_2$', fontsize=12)
    ax1.set_ylabel('Spectral gap', fontsize=12)
    ax1.set_title(r'Product Gap vs $\min(\gamma_1, \gamma_2)$', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Heatmap of product gap / min gap ratio
    g1_range = np.linspace(0.05, 0.95, 100)
    g2_range = np.linspace(0.05, 0.95, 100)
    G1, G2 = np.meshgrid(g1_range, g2_range)
    product_gap = 1 - (1 - G1) * (1 - G2)
    min_gap = np.minimum(G1, G2)
    ratio = product_gap / min_gap

    im = ax2.imshow(ratio, extent=[0.05, 0.95, 0.05, 0.95], origin='lower',
                    cmap='RdYlGn', vmin=1.0, vmax=3.0, aspect='auto')
    ax2.set_xlabel(r'$\gamma_1$', fontsize=12)
    ax2.set_ylabel(r'$\gamma_2$', fontsize=12)
    ax2.set_title(r'$\frac{1-(1-\gamma_1)(1-\gamma_2)}{\min(\gamma_1,\gamma_2)}$ (always $\geq 1$)',
                  fontsize=14)
    plt.colorbar(im, ax=ax2, label='Ratio')

    plt.tight_layout()
    plt.savefig('product_walk_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved product_walk_gap.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Cycle Graph Spectral Gap Bounds

Shows the tight bounds 8/n² ≤ 1-cos(2π/n) ≤ 2π²/n² as functions of n.
"""

import math

def spectral_gap_cycle(n):
    return 1 - math.cos(2 * math.pi / n)

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available. Printing text output instead.")
        for n in range(3, 51):
            gap = spectral_gap_cycle(n)
            lb = 8.0 / n**2
            ub = 2 * math.pi**2 / n**2
            print(f"n={n:3d}: {lb:.6f} ≤ {gap:.6f} ≤ {ub:.6f}")
        return

    ns = np.arange(3, 201)
    gaps = np.array([spectral_gap_cycle(n) for n in ns])
    lbs = 8.0 / ns**2
    ubs = 2 * np.pi**2 / ns**2

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Spectral gap and bounds
    ax1.semilogy(ns, gaps, 'b-', linewidth=2, label=r'$1 - \cos(2\pi/n)$')
    ax1.semilogy(ns, lbs, 'r--', linewidth=1.5, label=r'$8/n^2$ (lower)')
    ax1.semilogy(ns, ubs, 'g--', linewidth=1.5, label=r'$2\pi^2/n^2$ (upper)')
    ax1.fill_between(ns, lbs, ubs, alpha=0.1, color='blue')
    ax1.set_xlabel('Number of vertices n', fontsize=12)
    ax1.set_ylabel('Spectral gap γ', fontsize=12)
    ax1.set_title('Cycle Graph Spectral Gap: Tight Bounds', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Ratio to asymptotic
    ratios = gaps / (2 * np.pi**2 / ns**2)
    ax2.plot(ns, ratios, 'b-', linewidth=2)
    ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax2.axhline(y=8/(2*np.pi**2), color='red', linestyle='--', alpha=0.5,
                label=f'Lower ratio = {8/(2*np.pi**2):.4f}')
    ax2.set_xlabel('Number of vertices n', fontsize=12)
    ax2.set_ylabel(r'$\gamma / (2\pi^2/n^2)$', fontsize=12)
    ax2.set_title('Convergence to Asymptotic', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1.1)

    plt.tight_layout()
    plt.savefig('spectral_gap_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spectral_gap_bounds.png")


if __name__ == "__main__":
    main()
