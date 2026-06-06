#!/usr/bin/env python3
"""
Proof Complexity and Thermodynamic Cost — Numerical Demonstrations

This script demonstrates the key results from the thermodynamic proof
complexity framework with concrete numerical examples.
"""

import math

# Physical constants
k_B = 1.380649e-23  # Boltzmann constant (J/K)
ROOM_TEMP = 300      # Room temperature (K)
kT = k_B * ROOM_TEMP
LN2 = math.log(2)
LANDAUER_UNIT = kT * LN2  # ~2.87e-21 J at room temp


def proof_cost(proof_len: int, temperature: float = ROOM_TEMP) -> float:
    """Thermodynamic cost of a proof: |π| * kT * ln(2)."""
    return proof_len * k_B * temperature * LN2


def search_cost(alphabet_size: int, search_space_len: int,
                valid_count: int, temperature: float = ROOM_TEMP) -> float:
    """Thermodynamic cost of exhaustive proof search."""
    candidates = alphabet_size ** search_space_len // (valid_count + 1)
    return candidates * k_B * temperature * LN2


def geom_sum(b: int, n: int) -> int:
    """Sum of b^0 + b^1 + ... + b^(n-1)."""
    return sum(b**i for i in range(n))


def main():
    print("=" * 70)
    print("PROOF COMPLEXITY AND THERMODYNAMIC COST")
    print("Numerical Demonstrations")
    print("=" * 70)

    # Demo 1: Proof Cost Monotonicity
    print("\n--- Demo 1: Proof Cost Strict Monotonicity ---")
    print(f"Landauer unit at T={ROOM_TEMP}K: {LANDAUER_UNIT:.4e} J")
    print()
    for length in [1, 10, 100, 1000, 10**6]:
        cost = proof_cost(length)
        print(f"  Proof length {length:>10,d}: cost = {cost:.4e} J")

    # Demo 2: Incompressibility Barrier
    print("\n--- Demo 2: Incompressibility Barrier ---")
    print("Geometric sum vs b^n (shorter strings < total strings):")
    for b in [2, 3, 10]:
        for n in [1, 5, 10]:
            gs = geom_sum(b, n)
            total = b**n
            ratio = gs / total
            print(f"  b={b}, n={n}: sum={gs:>12,d}  b^n={total:>12,d}  "
                  f"ratio={ratio:.6f}  gap={total - gs:>12,d}")

    # Demo 3: Discovery-Verification Gap
    print("\n--- Demo 3: Discovery-Verification Thermodynamic Gap ---")
    print("Search cost vs verification cost for sparse proof spaces:")
    b = 2
    for n in [10, 20, 30, 40]:
        for k in [2, 5]:
            if k + 1 > n:
                continue
            search_candidates = b ** (n - k - 1)
            ver_cost = proof_cost(n)
            src_cost = search_cost(b, n, b**k)
            ratio = search_candidates
            print(f"  n={n:>2d}, k={k}: search_candidates={search_candidates:>15,d}  "
                  f"gap_factor={ratio:>15,d}")

    # Demo 4: Existence of Long Proofs
    print("\n--- Demo 4: Existence of Long Proofs ---")
    print("For b^n theorems with distinct proofs, max proof length >= n:")
    b = 2
    for n in [5, 10, 15, 20]:
        theorems = b**n
        short_strings = geom_sum(b, n)
        print(f"  n={n:>2d}: {theorems:>10,d} theorems, "
              f"{short_strings:>10,d} strings of length < n  "
              f"(deficit: {theorems - short_strings:>10,d})")

    # Demo 5: Complexity Class Separation
    print("\n--- Demo 5: Complexity Class Separation ---")
    print("Linear (c*n) vs Exponential (2^n) growth:")
    for c in [1, 5, 10]:
        threshold = 2 * c + 2
        print(f"\n  c = {c}, separation threshold n >= {threshold}:")
        for n in [threshold, threshold + 5, threshold + 10]:
            lin = c * n
            exp = 2**n
            print(f"    n={n:>3d}: c*n={lin:>15,d}  2^n={exp:>15,d}  "
                  f"ratio={exp/lin:.1f}x")

    # Demo 6: Real-world Scale
    print("\n--- Demo 6: Real-World Scale ---")
    print("Thermodynamic cost of proof search at different scales:")
    scenarios = [
        ("Simple theorem (n=20, k=10)", 2, 20, 2**10),
        ("Medium theorem (n=50, k=20)", 2, 50, 2**20),
        ("Hard theorem (n=100, k=30)", 2, 100, 2**30),
        ("Cryptographic (n=256, k=128)", 2, 256, 2**128),
    ]
    sun_energy_per_sec = 3.828e26  # watts
    for name, b, n, valid in scenarios:
        cost = search_cost(b, n, valid)
        sun_seconds = cost / sun_energy_per_sec if cost > 0 else 0
        print(f"  {name}:")
        print(f"    Search energy: {cost:.4e} J")
        if sun_seconds > 1:
            print(f"    Sun-seconds:   {sun_seconds:.4e}")
        print()

    print("=" * 70)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Thermodynamic Complexity Class Separation

Shows the strict separation between linear and exponential
thermodynamic complexity classes.
"""
import math

try:
    import matplotlib.pyplot as plt
    import numpy as np
except ImportError:
    print("matplotlib and numpy required")
    exit(1)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Thermodynamic Complexity Classes",
                 fontsize=16, fontweight='bold')

    # Plot 1: Linear vs Exponential separation
    ax1 = axes[0]
    n_values = np.arange(1, 25)

    for c in [1, 2, 5, 10]:
        linear = c * n_values
        threshold = 2 * c + 2
        ax1.semilogy(n_values, linear, '--', label=f'Linear (c={c})', alpha=0.7)
        ax1.axvline(x=threshold, color='gray', alpha=0.2, linestyle=':')

    exp_vals = np.array([2**n for n in n_values], dtype=float)
    ax1.semilogy(n_values, exp_vals, 'k-', linewidth=2.5, label='Exponential (2^n)')

    ax1.set_xlabel('Statement Length n', fontsize=12)
    ax1.set_ylabel('Proof Length Bound (log scale)', fontsize=12)
    ax1.set_title('Linear vs Exponential Classes\n(Theorem: c·n < 2^n for large n)', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(1, 1e7)

    # Plot 2: Hierarchy gap visualization
    ax2 = axes[1]
    K_B = 1.380649e-23
    T = 300
    LN2 = math.log(2)
    LANDAUER = K_B * T * LN2

    levels = np.arange(0, 21)
    costs = levels * LANDAUER * 1e21  # in units of 10^-21 J

    bars = ax2.bar(levels, costs, color=plt.cm.viridis(levels / 20), edgecolor='black',
                   linewidth=0.5)

    # Annotate the gap
    for i in range(1, min(6, len(levels))):
        ax2.annotate('', xy=(i, costs[i]),
                     xytext=(i, costs[i-1]),
                     arrowprops=dict(arrowstyle='<->', color='red', lw=1.5))

    ax2.text(3, costs[3] * 0.5, f'Gap = kT·ln(2)\n= {LANDAUER:.2e} J',
             fontsize=10, color='red', ha='center',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    ax2.set_xlabel('Hierarchy Level k', fontsize=12)
    ax2.set_ylabel('Proof Cost (×10⁻²¹ J)', fontsize=12)
    ax2.set_title('Proof Cost Hierarchy\n(Uniform Landauer Gap)', fontsize=13)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('complexity_classes.png', dpi=150, bbox_inches='tight')
    print("Saved: complexity_classes.png")
    plt.close()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Discovery-Verification Thermodynamic Gap

Shows how the energy cost of finding a proof grows exponentially
compared to the cost of checking it.
"""
import math

try:
    import matplotlib.pyplot as plt
    import matplotlib.ticker as ticker
    import numpy as np
except ImportError:
    print("matplotlib and numpy required. Install with: pip install matplotlib numpy")
    exit(1)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle("Thermodynamic Cost of Mathematical Proof",
                 fontsize=16, fontweight='bold')

    K_B = 1.380649e-23
    T = 300
    LN2 = math.log(2)
    LANDAUER = K_B * T * LN2

    # Plot 1: Proof cost vs length (strict monotonicity)
    ax1 = axes[0]
    lengths = np.arange(0, 101)
    costs = lengths * LANDAUER
    ax1.plot(lengths, costs * 1e21, 'b-', linewidth=2)
    ax1.set_xlabel('Proof Length (symbols)', fontsize=12)
    ax1.set_ylabel('Thermodynamic Cost (×10⁻²¹ J)', fontsize=12)
    ax1.set_title('Proof Cost Monotonicity\n(Theorem 1)', fontsize=13)
    ax1.grid(True, alpha=0.3)
    ax1.annotate('Slope = kT·ln(2)\n(Landauer unit)',
                 xy=(60, 60 * LANDAUER * 1e21),
                 xytext=(30, 80 * LANDAUER * 1e21),
                 arrowprops=dict(arrowstyle='->', color='red'),
                 fontsize=10, color='red')

    # Plot 2: Incompressibility barrier
    ax2 = axes[1]
    b = 2
    ns = np.arange(1, 21)
    total = np.array([b**n for n in ns], dtype=float)
    compressible = np.array([sum(b**i for i in range(n)) for n in ns], dtype=float)
    incompressible = total - compressible

    ax2.semilogy(ns, total, 'b-o', label='Total strings (b^n)', markersize=4)
    ax2.semilogy(ns, compressible, 'r--s', label='Compressible (<b^n)', markersize=4)
    ax2.semilogy(ns, incompressible, 'g-^', label='Incompressible', markersize=4)
    ax2.fill_between(ns, compressible, total, alpha=0.15, color='green',
                     label='Irreducible cost region')
    ax2.set_xlabel('String Length n', fontsize=12)
    ax2.set_ylabel('Count (log scale)', fontsize=12)
    ax2.set_title('Incompressibility Barrier\n(Chaitin Analog, b=2)', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Discovery vs Verification gap
    ax3 = axes[2]
    n_values = np.arange(5, 31)
    k = 3  # sparse proofs
    search_exp = n_values - k - 1
    search_cands = np.array([2**e for e in search_exp], dtype=float)
    verify_cost = n_values.astype(float)  # proportional to proof length

    ax3.semilogy(n_values, search_cands, 'r-o', label='Search candidates', markersize=4)
    ax3.semilogy(n_values, verify_cost, 'b-s', label='Verification cost (∝ n)', markersize=4)
    ax3.fill_between(n_values, verify_cost, search_cands, alpha=0.1, color='red',
                     label='Thermodynamic gap')
    ax3.set_xlabel('Search Space Size n', fontsize=12)
    ax3.set_ylabel('Cost (log scale, Landauer units)', fontsize=12)
    ax3.set_title(f'Discovery-Verification Gap\n(k={k}, b=2)', fontsize=13)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('thermodynamic_proof_cost.png', dpi=150, bbox_inches='tight')
    print("Saved: thermodynamic_proof_cost.png")
    plt.close()


if __name__ == "__main__":
    main()
