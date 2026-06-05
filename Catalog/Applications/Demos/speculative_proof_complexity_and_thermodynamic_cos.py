#!/usr/bin/env python3
"""
Thermodynamic Proof Complexity — Demonstration Script

Demonstrates the key numerical results from the thermodynamic proof complexity framework:
1. Cost monotonicity: shorter proofs cost less energy
2. Incompressibility dominance: most proofs are expensive
3. Cost hierarchy: proof costs form an infinite ladder
4. Sparse search: exponential overhead for finding valid proofs
5. Sorting bridge: factorial growth implies positive proof cost
"""

import math

# Constants
kB = 1.380649e-23  # Boltzmann constant (J/K)
ROOM_TEMP = 300     # Room temperature (K)


def proof_cost(length: int, temperature: float = ROOM_TEMP) -> float:
    """Thermodynamic cost of a proof of given length at given temperature.
    
    cost(ℓ) = ℓ · kT · ln(2)
    
    In natural units (k=1), cost(ℓ) = ℓ · T · ln(2).
    Here we use SI units for physical interpretation.
    """
    return length * kB * temperature * math.log(2)


def incompressible_fraction(alphabet_size: int) -> float:
    """Fraction of strings that are incompressible (cannot be shortened).
    
    For alphabet size b, the incompressible fraction is (b-1)/b.
    """
    return (alphabet_size - 1) / alphabet_size


def search_overhead(total_candidates: int, valid_proofs: int) -> float:
    """Search overhead: expected number of candidates to examine."""
    return total_candidates / (valid_proofs + 1)


def ruggedness_ratio(local_minima: int, valid_minima: int) -> float:
    """Ruggedness ratio of the proof energy landscape."""
    return local_minima / (valid_minima + 1)


def main():
    print("=" * 70)
    print("THERMODYNAMIC PROOF COMPLEXITY — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)
    
    # Demo 1: Cost Monotonicity
    print("\n--- Demo 1: Cost Monotonicity ---")
    print("Shorter proofs have strictly lower thermodynamic cost.\n")
    for length in [1, 5, 10, 50, 100, 1000]:
        cost = proof_cost(length)
        print(f"  Proof length {length:>5d}: cost = {cost:.4e} J "
              f"({cost/kB/ROOM_TEMP/math.log(2):.1f} Landauer units)")
    
    # Demo 2: Incompressibility Dominance
    print("\n--- Demo 2: Incompressibility Dominance ---")
    print("Most proofs cannot be compressed to reduce their thermodynamic cost.\n")
    for b in [2, 3, 10, 26, 256]:
        frac = incompressible_fraction(b)
        print(f"  Alphabet size {b:>3d}: {frac*100:.1f}% of proofs are incompressible")
    
    # Demo 3: Cost Hierarchy
    print("\n--- Demo 3: Proof Cost Hierarchy ---")
    print("The cost gap between adjacent levels is exactly kT·ln(2).\n")
    landauer_unit = kB * ROOM_TEMP * math.log(2)
    print(f"  One Landauer unit at {ROOM_TEMP}K: {landauer_unit:.4e} J")
    print(f"  This is the minimum energy to erase one bit of proof information.\n")
    for k in range(1, 8):
        cost_k = proof_cost(k)
        cost_k1 = proof_cost(k + 1)
        gap = cost_k1 - cost_k
        print(f"  Level {k} → {k+1}: gap = {gap:.4e} J "
              f"(= {gap/landauer_unit:.6f} Landauer units)")
    
    # Demo 4: Sparse Search Exponential Bound
    print("\n--- Demo 4: Sparse Search Exponential Bound ---")
    print("When valid proofs are sparse, search overhead is exponential.\n")
    b = 2
    for n in [10, 20, 30, 50]:
        for k_frac in [0.5, 0.1]:
            k = int(n * k_frac)
            total = b ** n
            valid = b ** k
            overhead = search_overhead(total, valid)
            lower_bound = b ** (n - k - 1)
            print(f"  n={n:>2d}, k={k:>2d}: total={total:.2e}, valid={valid:.2e}, "
                  f"overhead ≥ {lower_bound:.2e}")
    
    # Demo 5: Sorting Bridge
    print("\n--- Demo 5: Sorting as Proof ---")
    print("Sorting n items requires log₂(n!) bits of information.\n")
    for n in [2, 5, 10, 20, 52, 100]:
        info_bits = math.log2(math.factorial(n))
        cost = info_bits * kB * ROOM_TEMP * math.log(2)
        print(f"  n={n:>3d}: log₂({n}!) = {info_bits:.1f} bits, "
              f"cost = {cost:.4e} J")
    
    # Demo 6: Energy Landscape
    print("\n--- Demo 6: Proof Energy Landscape ---")
    print("Rugged landscapes trap proof search.\n")
    scenarios = [
        ("Easy problem", 1000, 100, 150, 0.0, 0.5),
        ("Medium problem", 10000, 50, 500, 0.0, 2.0),
        ("Hard problem", 1000000, 10, 10000, 0.0, 5.0),
        ("Very hard", 10**9, 3, 10**6, 0.0, 10.0),
    ]
    for name, total, valid, local, e_global, e_local in scenarios:
        r = ruggedness_ratio(local, valid)
        trap_prob = 1 - valid / local if local > 0 else 0
        gap = e_local - e_global
        print(f"  {name:>15s}: ruggedness={r:>8.1f}, "
              f"trap_prob={trap_prob:.3f}, energy_gap={gap:.1f}")
    
    # Demo 7: Chaitin Cost Bound
    print("\n--- Demo 7: Chaitin Cost Bound ---")
    print("For any bound k, there exist proofs more expensive than k·T·ln(2).\n")
    b = 2
    for k in [10, 20, 50, 100]:
        threshold = b ** k + 1
        min_cost = k * kB * ROOM_TEMP * math.log(2)
        print(f"  k={k:>3d}: need >{threshold:.2e} statements, "
              f"min cost exceeds {min_cost:.4e} J")
    
    # Demo 8: Falsifiable Conjecture Test
    print("\n--- Demo 8: Falsifiable Conjecture ---")
    print("Conjecture: avg/min cost ratio ≥ b^(n/3).\n")
    b = 2
    for n in [6, 12, 18, 24, 30]:
        predicted_ratio = b ** (n // 3)
        print(f"  n={n:>2d}: predicted ratio ≥ {predicted_ratio:>10d}")
    print("\n  Any proof system with smaller ratios would refute the conjecture.")
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Proof Cost Hierarchy

Shows how thermodynamic proof costs form an infinite ladder,
with each step separated by exactly T·ln(2).
"""

import math

try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; generating text output instead.")


def generate_hierarchy_data(max_level: int = 20, temperature: float = 1.0):
    """Generate proof cost hierarchy data."""
    levels = list(range(max_level + 1))
    costs = [k * temperature * math.log(2) for k in levels]
    gaps = [temperature * math.log(2)] * max_level
    return levels, costs, gaps


def plot_hierarchy():
    """Plot the proof cost hierarchy."""
    if not HAS_MPL:
        levels, costs, gaps = generate_hierarchy_data()
        print("\nProof Cost Hierarchy (T=1, natural units):")
        print("-" * 40)
        for k, c in zip(levels, costs):
            bar = "█" * int(c * 5)
            print(f"  Level {k:>2d}: cost = {c:.3f}  {bar}")
        return

    fig, axes = plt.subplots(1, 3, figsize=(16, 6))

    # Plot 1: Cost ladder
    levels, costs, gaps = generate_hierarchy_data(15, 1.0)
    ax = axes[0]
    ax.barh(levels, costs, color='steelblue', edgecolor='navy', alpha=0.8)
    ax.set_xlabel('Thermodynamic Cost (T·ln(2) units)', fontsize=11)
    ax.set_ylabel('Proof Length Level k', fontsize=11)
    ax.set_title('Proof Cost Hierarchy', fontsize=13, fontweight='bold')
    for k, c in zip(levels, costs):
        ax.text(c + 0.1, k, f'{c:.2f}', va='center', fontsize=8)

    # Plot 2: Incompressibility by alphabet size
    ax = axes[1]
    bs = list(range(2, 21))
    fracs = [(b - 1) / b for b in bs]
    ax.plot(bs, fracs, 'o-', color='crimson', markersize=6)
    ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='50%')
    ax.set_xlabel('Alphabet Size b', fontsize=11)
    ax.set_ylabel('Incompressible Fraction (b-1)/b', fontsize=11)
    ax.set_title('Incompressibility Dominance', fontsize=13, fontweight='bold')
    ax.set_ylim(0.4, 1.05)
    ax.legend()

    # Plot 3: Search overhead (log scale)
    ax = axes[2]
    ns = list(range(5, 31))
    for k_frac, color, label in [(0.5, 'green', 'k=n/2'), (0.3, 'orange', 'k=0.3n'), (0.1, 'red', 'k=n/10')]:
        overheads = []
        for n in ns:
            k = max(0, int(n * k_frac))
            if n > k + 1:
                overheads.append(2 ** (n - k - 1))
            else:
                overheads.append(1)
        ax.semilogy(ns, overheads, 'o-', color=color, markersize=4, label=label)
    ax.set_xlabel('Proof Length n', fontsize=11)
    ax.set_ylabel('Search Overhead (log scale)', fontsize=11)
    ax.set_title('Exponential Search Cost', fontsize=13, fontweight='bold')
    ax.legend()

    plt.tight_layout()
    plt.savefig('proof_cost_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: proof_cost_hierarchy.png")
    plt.close()


if __name__ == "__main__":
    plot_hierarchy()


#!/usr/bin/env python3
"""
Visualization: Proof Energy Landscape

Visualizes the ruggedness of proof energy landscapes and
how trapping probability scales with landscape parameters.
"""

import math

try:
    import matplotlib.pyplot as plt
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; generating text output instead.")


def generate_landscape(n_points: int = 200, n_valid: int = 5, seed: int = 42):
    """Generate a synthetic proof energy landscape."""
    import random
    random.seed(seed)

    # Random energy values
    energies = [random.gauss(5, 2) for _ in range(n_points)]

    # Place valid proofs at low energy
    valid_indices = random.sample(range(n_points), n_valid)
    for i in valid_indices:
        energies[i] = random.uniform(0, 0.5)

    # Create some local minima (slightly higher than global)
    n_local = n_valid * 10
    local_indices = random.sample(
        [i for i in range(n_points) if i not in valid_indices],
        min(n_local, n_points - n_valid)
    )
    for i in local_indices:
        energies[i] = random.uniform(1, 3)

    return energies, valid_indices, local_indices


def plot_landscape():
    """Plot the proof energy landscape."""
    if not HAS_MPL:
        energies, valid, local = generate_landscape(100, 3)
        print("\nProof Energy Landscape (100 points, 3 valid proofs):")
        print("-" * 50)
        for i in range(min(50, len(energies))):
            bar = "█" * int(energies[i] * 3)
            marker = " ← VALID" if i in valid else (" ← local min" if i in local else "")
            print(f"  [{i:>3d}] E={energies[i]:>5.2f} {bar}{marker}")
        return

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Energy landscape cross-section
    ax = axes[0, 0]
    energies, valid, local = generate_landscape(200, 5)
    x = list(range(len(energies)))
    ax.fill_between(x, energies, alpha=0.3, color='steelblue')
    ax.plot(x, energies, color='steelblue', linewidth=0.5)
    ax.scatter(valid, [energies[i] for i in valid], color='gold',
               s=100, zorder=5, label='Valid proofs (global min)', edgecolors='black')
    ax.scatter(local[:20], [energies[i] for i in local[:20]], color='red',
               s=30, zorder=4, label='Local minima (traps)', alpha=0.7)
    ax.set_xlabel('Proof String Index', fontsize=11)
    ax.set_ylabel('Energy', fontsize=11)
    ax.set_title('Proof Energy Landscape', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)

    # Plot 2: Ruggedness ratio vs proof length
    ax = axes[0, 1]
    ns = list(range(5, 26))
    ratios = []
    for n in ns:
        total = 2 ** n
        valid = max(1, total // (2 ** (n // 2)))
        local = max(valid, int(math.sqrt(total)))
        ratios.append(local / (valid + 1))
    ax.semilogy(ns, ratios, 'o-', color='crimson', markersize=5)
    ax.set_xlabel('Proof Length n', fontsize=11)
    ax.set_ylabel('Ruggedness Ratio (log scale)', fontsize=11)
    ax.set_title('Landscape Ruggedness Growth', fontsize=13, fontweight='bold')

    # Plot 3: Trapping probability
    ax = axes[1, 0]
    valid_counts = list(range(1, 101))
    for local_count, color, label in [
        (200, 'red', 'V_l = 200'),
        (500, 'orange', 'V_l = 500'),
        (1000, 'green', 'V_l = 1000'),
    ]:
        probs = [1 - v / local_count for v in valid_counts if v <= local_count]
        ax.plot(valid_counts[:len(probs)], probs, color=color, label=label)
    ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='50% threshold')
    ax.set_xlabel('Valid Minima Count V_g', fontsize=11)
    ax.set_ylabel('Trapping Probability', fontsize=11)
    ax.set_title('Trapping vs Valid Proof Count', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)

    # Plot 4: Sorting cost (factorial bound)
    ax = axes[1, 1]
    ns = list(range(1, 21))
    factorials = [math.factorial(n) for n in ns]
    two_pows = [2 ** (n - 1) for n in ns]
    info_bits = [math.log2(f) for f in factorials]

    ax.semilogy(ns, factorials, 'o-', color='navy', label='n!', markersize=5)
    ax.semilogy(ns, two_pows, 's--', color='crimson', label='2^(n-1)', markersize=5)
    ax.set_xlabel('n (items to sort)', fontsize=11)
    ax.set_ylabel('Value (log scale)', fontsize=11)
    ax.set_title('Factorial ≥ 2^(n-1): Sorting Cost Bound', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved: energy_landscape.png")
    plt.close()


if __name__ == "__main__":
    plot_landscape()
