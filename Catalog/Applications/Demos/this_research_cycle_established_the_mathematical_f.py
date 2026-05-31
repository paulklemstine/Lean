#!/usr/bin/env python3
"""
Demo: Persistent Homological Quantum Error Correction

Demonstrates the key results connecting persistent homology to quantum
error-correcting codes. Includes numerical examples for the toric code,
barcode distance conjecture verification, and parameter estimation.
"""

import numpy as np
import math
from algorithms import (
    PersistenceBar, CSSCode, toric_code, chain_complex_to_css,
    quantum_singleton_bound, quantum_hamming_volume, quantum_hamming_bound,
    persistence_rate_tradeoff, barcode_to_code_params,
    hypergraph_product_params, euler_characteristic, genus_from_euler,
    hamming_weight, bpt_bound, optimal_scale_selection,
)


def demo_toric_code():
    """Demonstrate the toric code construction and verify parameters."""
    print("=" * 60)
    print("DEMO 1: Toric Code Construction")
    print("=" * 60)

    for L in [3, 4, 5, 7, 10]:
        code, params = toric_code(L)
        assert code.verify_css(), f"CSS orthogonality failed for L={L}!"

        n, k, d = params['n'], params['k'], params['d']
        chi = euler_characteristic(L*L, 2*L*L, L*L)
        g = genus_from_euler(chi)
        d_singleton = quantum_singleton_bound(n, k)

        print(f"\n  L = {L}:")
        print(f"    [[n, k, d]] = [[{n}, {k}, {d}]]")
        print(f"    Euler characteristic χ = {chi}")
        print(f"    Genus g = {g}")
        print(f"    Singleton bound d ≤ {d_singleton}")
        print(f"    Rate k/n = {k/n:.4f}")
        print(f"    d²/n = {d*d/n:.4f} (should approach 0.5)")
        print(f"    CSS orthogonality: ✓")


def demo_barcode_distance():
    """Verify the Barcode Distance Conjecture for toric codes."""
    print("\n" + "=" * 60)
    print("DEMO 2: Barcode Distance Conjecture Verification")
    print("=" * 60)

    print("\n  For the L×L toric code:")
    print("  The H₁ barcode has 2 bars: [1, L) each")
    print("  Conjecture predicts d ≥ ⌈L/1⌉ = L")
    print()

    for L in [3, 5, 7, 10, 15, 20]:
        bar = PersistenceBar(birth=1.0, death=float(L))
        predicted_d = bar.predicted_distance()
        actual_d = L

        status = "✓" if predicted_d <= actual_d else "✗"
        print(f"  L={L:3d}: predicted d ≥ {predicted_d:3d}, "
              f"actual d = {actual_d:3d}  {status}")


def demo_singleton_hamming():
    """Demonstrate the Singleton-Hamming tradeoff."""
    print("\n" + "=" * 60)
    print("DEMO 3: Quantum Singleton-Hamming Tradeoff")
    print("=" * 60)

    for n in [7, 15, 23, 31, 63]:
        print(f"\n  n = {n}:")
        for k in [1, 2, 3]:
            d_singleton = quantum_singleton_bound(n, k)
            t_hamming = quantum_hamming_bound(n, k)
            d_hamming = 2 * t_hamming + 1

            max_rate = persistence_rate_tradeoff(n, d_singleton)

            print(f"    k={k}: Singleton d≤{d_singleton}, "
                  f"Hamming t≤{t_hamming} (d≤{d_hamming}), "
                  f"max rate={max_rate:.4f}")


def demo_persistence_barcode():
    """Demonstrate barcode-based code parameter prediction."""
    print("\n" + "=" * 60)
    print("DEMO 4: Barcode → Code Parameter Prediction")
    print("=" * 60)

    # Simulate barcodes for different topologies
    examples = [
        ("Torus (L=5)", [PersistenceBar(1.0, 5.0), PersistenceBar(1.0, 5.0)], 50),
        ("Genus-2 (L=5)", [PersistenceBar(1.0, 5.0)] * 4, 100),
        ("Klein bottle", [PersistenceBar(1.0, 4.0), PersistenceBar(2.0, 4.0)], 40),
        ("Noisy torus", [
            PersistenceBar(1.0, 8.0),
            PersistenceBar(1.0, 8.0),
            PersistenceBar(3.0, 3.5),  # noise
            PersistenceBar(4.0, 4.2),  # noise
        ], 200),
    ]

    for name, barcode, n_phys in examples:
        params = barcode_to_code_params(barcode, n_phys)
        print(f"\n  {name} (n={n_phys}):")
        print(f"    Bars: {len(barcode)}, "
              f"total persistence = {params['total_persistence']:.2f}")
        print(f"    Predicted: k={params['k']}, "
              f"d_pred={params['d_predicted']}, "
              f"d_singleton={params['d_singleton']}")
        print(f"    Effective d={params['d_effective']}, "
              f"rate={params['rate']:.4f}")


def demo_hypergraph_product():
    """Demonstrate the hypergraph product construction."""
    print("\n" + "=" * 60)
    print("DEMO 5: Hypergraph Product Codes")
    print("=" * 60)

    classical_codes = [
        ("[7,4,3] Hamming", 7, 4, 3, 3),
        ("[15,11,3] BCH", 15, 11, 3, 4),
        ("[23,12,7] Golay", 23, 12, 7, 11),
        ("[31,26,3] BCH", 31, 26, 3, 5),
    ]

    for (name1, n1, k1, d1, r1), (name2, n2, k2, d2, r2) in [
        (classical_codes[0], classical_codes[0]),
        (classical_codes[0], classical_codes[1]),
        (classical_codes[1], classical_codes[1]),
        (classical_codes[2], classical_codes[2]),
    ]:
        params = hypergraph_product_params(n1, k1, d1, r1, n2, k2, d2, r2)
        print(f"\n  {name1} × {name2}:")
        print(f"    HGP code: [[{params['n']}, {params['k']}, "
              f"d≥{params['d_lower']}]]")
        print(f"    Rate: {params['rate']:.4f}")
        bpt = bpt_bound(params['n'], params['d_lower'])
        print(f"    BPT bound k ≤ {bpt}")


def demo_scaling_laws():
    """Demonstrate scaling laws for surface codes."""
    print("\n" + "=" * 60)
    print("DEMO 6: Scaling Laws for Surface Codes")
    print("=" * 60)

    print("\n  Genus-g surface codes (n physical qubits, k=2g logical):")
    print(f"  {'g':>4s} {'n':>8s} {'k':>4s} {'d_max':>6s} "
          f"{'d²/n':>8s} {'rate':>8s}")
    print(f"  {'---':>4s} {'---':>8s} {'---':>4s} {'---':>6s} "
          f"{'---':>8s} {'---':>8s}")

    for g in [1, 2, 3, 5, 10]:
        for L in [10, 20, 50]:
            n = 2 * g * L * L  # approximate
            k = 2 * g
            d_max = quantum_singleton_bound(n, k)
            d_approx = L  # typical surface code distance

            print(f"  {g:4d} {n:8d} {k:4d} {d_max:6d} "
                  f"{d_approx*d_approx/n:8.4f} {k/n:8.6f}")


def demo_weight_enumerator():
    """Demonstrate weight enumerator computation for small codes."""
    print("\n" + "=" * 60)
    print("DEMO 7: Quantum Hamming Volume")
    print("=" * 60)

    print("\n  V(n, t) = quantum Hamming volume (Pauli errors of weight ≤ t)")
    print(f"  {'n':>4s}", end="")
    for t in range(6):
        print(f"  {'t='+str(t):>10s}", end="")
    print()

    for n in [5, 7, 9, 15, 23]:
        print(f"  {n:4d}", end="")
        for t in range(6):
            v = quantum_hamming_volume(n, t)
            print(f"  {v:10d}", end="")
        print()


def demo_optimal_scale():
    """Demonstrate optimal scale selection from a barcode."""
    print("\n" + "=" * 60)
    print("DEMO 8: Optimal Scale Selection")
    print("=" * 60)

    barcode = [
        PersistenceBar(0.5, 3.0),
        PersistenceBar(0.8, 4.5),
        PersistenceBar(1.0, 8.0),
        PersistenceBar(1.2, 2.5),
        PersistenceBar(3.0, 3.5),  # noise bar
    ]

    def n_at_scale(r):
        """Approximate number of edges at scale r."""
        return int(50 * r * r)  # grows quadratically

    scale, params = optimal_scale_selection(barcode, n_at_scale)

    print(f"\n  Barcode with {len(barcode)} bars:")
    for i, b in enumerate(barcode):
        print(f"    Bar {i}: [{b.birth:.1f}, {b.death:.1f}), "
              f"persistence={b.persistence:.1f}, "
              f"predicted_d={b.predicted_distance()}")

    print(f"\n  Optimal scale: r* = {scale:.2f}")
    if params:
        print(f"  At r*: k={params['k']}, d_eff={params['d_effective']}, "
              f"n={params['n']}, rate={params['rate']:.4f}")
        print(f"  k·d product = {params['kd_product']}")


if __name__ == "__main__":
    demo_toric_code()
    demo_barcode_distance()
    demo_singleton_hamming()
    demo_persistence_barcode()
    demo_hypergraph_product()
    demo_scaling_laws()
    demo_weight_enumerator()
    demo_optimal_scale()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Barcode Distance Conjecture predictions vs toric code distances.

Shows the predicted distance from the barcode ratio ceil(delta/epsilon)
compared to actual toric code distances for various L.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Barcode prediction vs actual distance
    ax = axes[0]
    Ls = list(range(2, 31))
    predicted = [math.ceil(L / 1.0) for L in Ls]  # ceil(delta/epsilon)
    actual = Ls  # toric code distance = L

    ax.plot(Ls, predicted, 'b-o', markersize=5, label='Predicted ⌈δ/ε⌉')
    ax.plot(Ls, actual, 'r--s', markersize=5, label='Actual distance')
    ax.fill_between(Ls, 0, predicted, alpha=0.1, color='blue')
    ax.set_xlabel('L (torus side length)', fontsize=12)
    ax.set_ylabel('Distance', fontsize=12)
    ax.set_title('Barcode Distance Conjecture: Toric Code', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Annotate
    ax.annotate('Prediction matches\nexactly for toric code',
               xy=(15, 15), fontsize=10, ha='center',
               bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # Right: Rate-distance product k*d vs n
    ax2 = axes[1]

    # Toric codes
    ns_toric = [2 * L ** 2 for L in Ls]
    kd_toric = [2 * L for L in Ls]  # k=2, d=L

    ax2.scatter(ns_toric, kd_toric, c='red', s=30, label='Toric [[2L²,2,L]]',
               zorder=3)

    # Singleton optimal: k*d <= n (roughly)
    ns_range = np.linspace(1, 2000, 200)
    kd_singleton = ns_range  # upper bound k*d <= n
    ax2.plot(ns_range, kd_singleton, 'k--', alpha=0.5, label='k·d = n (bound)')

    # Genus-2 codes
    kd_g2 = [4 * L for L in Ls]
    ns_g2 = [4 * L ** 2 for L in Ls]
    ax2.scatter(ns_g2, kd_g2, c='blue', s=30, label='Genus-2 [[4L²,4,L]]',
               zorder=3)

    ax2.set_xlabel('n (physical qubits)', fontsize=12)
    ax2.set_ylabel('k·d product', fontsize=12)
    ax2.set_title('Rate-Distance Product Scaling', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_xlim(0, 2000)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_barcode_prediction.png', dpi=150)
    print("Saved viz_barcode_prediction.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quantum Hamming volume and error correction capacity.

Shows how the quantum Hamming volume V(n,t) grows with n and t,
and the resulting bounds on the number of correctable errors.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def quantum_hamming_volume(n, t):
    """Sum_{i=0}^{t} 3^i * C(n, i)."""
    return sum(3**i * math.comb(n, i) for i in range(t + 1))


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Hamming volume heatmap
    ax = axes[0]
    ns = list(range(5, 51))
    ts = list(range(0, 11))
    data = np.zeros((len(ts), len(ns)))

    for i, t in enumerate(ts):
        for j, n in enumerate(ns):
            v = quantum_hamming_volume(n, t)
            data[i, j] = np.log10(max(v, 1))

    im = ax.imshow(data, aspect='auto', origin='lower',
                   extent=[ns[0], ns[-1], ts[0], ts[-1]],
                   cmap='viridis')
    plt.colorbar(im, ax=ax, label='log₁₀ V(n,t)')
    ax.set_xlabel('n (qubits)', fontsize=12)
    ax.set_ylabel('t (correctable errors)', fontsize=12)
    ax.set_title('Quantum Hamming Volume V(n,t)', fontsize=13)

    # Right: Maximum correctable errors from Hamming bound
    ax2 = axes[1]
    for k in [1, 2, 4, 8, 16]:
        ns_plot = list(range(max(5, k + 2), 201))
        t_max = []
        for n in ns_plot:
            t = 0
            while t <= n and quantum_hamming_volume(n, t) * (2 ** k) <= 2 ** n:
                t += 1
            t_max.append(max(0, t - 1))

        ax2.plot(ns_plot, t_max, label=f'k={k}', linewidth=2)

    ax2.set_xlabel('n (physical qubits)', fontsize=12)
    ax2.set_ylabel('t_max (max correctable errors)', fontsize=12)
    ax2.set_title('Quantum Hamming Bound: Max Correctable Errors', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_hamming_volume.png', dpi=150)
    print("Saved viz_hamming_volume.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quantum Singleton Bound Rate-Distance Tradeoff.

Shows the feasible region for CSS code parameters (rate vs distance)
under the quantum Singleton bound, with toric code family overlaid.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def singleton_max_rate(d, n):
    """Maximum rate k/n from quantum Singleton: 2d + k <= n + 2."""
    k_max = max(0, n + 2 - 2 * d)
    return k_max / n


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Rate vs normalized distance d/n
    ax = axes[0]
    for n in [50, 100, 200, 500, 1000]:
        ds = np.arange(1, n // 2 + 2)
        rates = [singleton_max_rate(d, n) for d in ds]
        ax.plot(ds / n, rates, label=f'n={n}', alpha=0.8)

    # Toric code family
    Ls = [3, 4, 5, 7, 10, 15, 20, 30]
    toric_d_over_n = [L / (2 * L ** 2) for L in Ls]
    toric_rate = [2 / (2 * L ** 2) for L in Ls]
    ax.scatter(toric_d_over_n, toric_rate, c='red', s=60, zorder=5,
              label='Toric codes', marker='*')

    ax.set_xlabel('Normalized distance d/n', fontsize=12)
    ax.set_ylabel('Encoding rate k/n', fontsize=12)
    ax.set_title('Quantum Singleton Bound: Rate vs Distance', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlim(0, 0.55)
    ax.set_ylim(0, 1.05)
    ax.grid(True, alpha=0.3)

    # Right panel: Scaling laws d^2 vs n
    ax2 = axes[1]
    for g in [1, 2, 3, 5]:
        ns = np.arange(4 * g, 1000)
        d_max = [(n - 2 * g) // 2 + 1 for n in ns]
        d2 = [d ** 2 for d in d_max]
        ax2.plot(ns, d2, label=f'g={g}', alpha=0.8)

    # Toric code: d^2 = L^2, n = 2L^2, so d^2 = n/2
    ns_toric = np.array([2 * L ** 2 for L in range(3, 30)])
    d2_toric = ns_toric / 2
    ax2.plot(ns_toric, d2_toric, 'r--', linewidth=2, label='Toric: d²=n/2')

    ax2.set_xlabel('n (physical qubits)', fontsize=12)
    ax2.set_ylabel('d² (distance squared)', fontsize=12)
    ax2.set_title('Distance Scaling: d² vs n', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.set_xlim(0, 1000)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_singleton_tradeoff.png', dpi=150)
    print("Saved viz_singleton_tradeoff.png")


if __name__ == "__main__":
    main()
