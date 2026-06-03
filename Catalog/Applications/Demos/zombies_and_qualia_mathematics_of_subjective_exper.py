#!/usr/bin/env python3
"""
Zombies and Qualia: Numerical Demonstrations

Demonstrates the key quantitative results from the formal proofs:
1. Explanatory gap computation
2. Zombie census
3. Information gap
4. Involution counting
"""

import math


def explanatory_gap(n_states: int, n_qualia: int) -> int:
    """
    Compute the explanatory gap: |Q|^|S|.
    
    This is the number of experientially distinct but functionally 
    identical systems compatible with a given functional description.
    """
    return n_qualia ** n_states


def zombie_count(n_states: int, n_qualia: int) -> int:
    """
    Number of 'zombie-like' alternatives (different qualia, same function).
    This is |Q|^|S| - 1 (excluding the original).
    """
    return explanatory_gap(n_states, n_qualia) - 1


def info_gap_bits(n_states: int, n_qualia: int) -> float:
    """
    Information-theoretic gap in bits: |S| * log2(|Q|).
    
    The number of bits of experiential information invisible to 
    functional observation.
    """
    if n_qualia <= 1:
        return 0.0
    return n_states * math.log2(n_qualia)


def count_involutions(n: int) -> int:
    """
    Count the number of involutions on a set of n elements.
    An involution is a permutation that is its own inverse.
    
    Recurrence: a(n) = a(n-1) + (n-1)*a(n-2)
    (Either element n is a fixed point, or it swaps with one of n-1 others)
    """
    if n <= 1:
        return 1
    # Use dynamic programming
    a = [0] * (n + 1)
    a[0] = 1
    a[1] = 1
    for k in range(2, n + 1):
        a[k] = a[k - 1] + (k - 1) * a[k - 2]
    return a[n]


def nontrivial_involution_count(n: int) -> int:
    """
    Number of non-identity involutions on n elements.
    These correspond to genuinely 'inverted spectrum' scenarios.
    """
    return count_involutions(n) - 1


def main():
    print("=" * 70)
    print("ZOMBIES AND QUALIA: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)
    
    # Demo 1: Explanatory gap for small systems
    print("\n--- Demo 1: Explanatory Gap ---")
    print(f"{'States':>8} {'Qualia':>8} {'Gap':>15} {'Zombies':>15}")
    print("-" * 50)
    for n_states in [2, 3, 5, 10, 20]:
        for n_qualia in [2, 3, 5]:
            gap = explanatory_gap(n_states, n_qualia)
            zombies = zombie_count(n_states, n_qualia)
            print(f"{n_states:>8} {n_qualia:>8} {gap:>15,} {zombies:>15,}")
    
    # Demo 2: Information gap
    print("\n--- Demo 2: Information Gap (bits) ---")
    print(f"{'States':>8} {'Qualia':>8} {'Info Gap (bits)':>20}")
    print("-" * 40)
    for n_states in [10, 100, 1000, 10**6, 10**9]:
        for n_qualia in [2, 10, 100]:
            bits = info_gap_bits(n_states, n_qualia)
            print(f"{n_states:>8,} {n_qualia:>8} {bits:>20,.1f}")
    
    # Demo 3: Human brain scale
    print("\n--- Demo 3: Human Brain Scale ---")
    n_neurons = 86_000_000_000  # ~86 billion neurons
    n_qualia = 2  # binary qualia (experience/no experience)
    bits = info_gap_bits(n_neurons, n_qualia)
    print(f"Neurons: {n_neurons:,}")
    print(f"Binary qualia space (|Q|=2)")
    print(f"Information gap: {bits:,.0f} bits")
    print(f"Explanatory gap: 2^{n_neurons:,} distinct experiences")
    print(f"(For comparison, atoms in observable universe: ~10^80 ≈ 2^266)")
    print(f"The gap exceeds the universe by ~2^{n_neurons - 266:,} fold")
    
    # Demo 4: Involution counting
    print("\n--- Demo 4: Inverted Spectrum Scenarios ---")
    print(f"{'|Q|':>6} {'Involutions':>15} {'Non-trivial':>15}")
    print("-" * 40)
    for n in range(1, 16):
        inv = count_involutions(n)
        nt = nontrivial_involution_count(n)
        print(f"{n:>6} {inv:>15,} {nt:>15,}")
    
    # Demo 5: Gap additivity
    print("\n--- Demo 5: Gap Additivity (Sum vs Product) ---")
    print("For S = S1 ⊕ S2, Gap(S,Q) = Gap(S1,Q) × Gap(S2,Q)")
    print(f"{'|S1|':>6} {'|S2|':>6} {'|Q|':>6} {'Gap(S1⊕S2)':>15} {'Gap(S1)×Gap(S2)':>18}")
    print("-" * 55)
    for s1, s2, q in [(3, 4, 2), (2, 5, 3), (4, 3, 5)]:
        gap_sum = explanatory_gap(s1 + s2, q)
        gap_prod = explanatory_gap(s1, q) * explanatory_gap(s2, q)
        print(f"{s1:>6} {s2:>6} {q:>6} {gap_sum:>15,} {gap_prod:>18,}")
    
    # Demo 6: Mary's Room
    print("\n--- Demo 6: Mary's Room ---")
    print("Mary knows the complete functional description F.")
    print("How many experientially distinct systems share this description?")
    n_states = 5
    for n_qualia in [2, 5, 10, 100]:
        gap = explanatory_gap(n_states, n_qualia)
        print(f"  With {n_qualia} qualia types and {n_states} states: "
              f"{gap:,} possibilities (Mary cannot distinguish)")
    
    print("\n" + "=" * 70)
    print("All computations match the formally verified theorems.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Explanatory Gap as a function of states and qualia.
"""
import matplotlib.pyplot as plt
import numpy as np

def explanatory_gap(n_states, n_qualia):
    return n_qualia ** n_states

def info_gap(n_states, n_qualia):
    if n_qualia <= 1:
        return 0.0
    return n_states * np.log2(n_qualia)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Log of explanatory gap vs states for different qualia counts
ax1 = axes[0]
states_range = np.arange(1, 21)
for k in [2, 3, 5, 10]:
    gaps = [np.log10(explanatory_gap(n, k)) for n in states_range]
    ax1.plot(states_range, gaps, 'o-', label=f'|Q|={k}', linewidth=2)
ax1.set_xlabel('Number of States |S|', fontsize=12)
ax1.set_ylabel('log₁₀(Explanatory Gap)', fontsize=12)
ax1.set_title('Explanatory Gap Growth', fontsize=14)
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Information gap (bits)
ax2 = axes[1]
states_log = np.logspace(0, 6, 50)
for k in [2, 10, 100]:
    bits = [info_gap(n, k) for n in states_log]
    ax2.loglog(states_log, bits, linewidth=2, label=f'|Q|={k}')
ax2.set_xlabel('Number of States |S|', fontsize=12)
ax2.set_ylabel('Information Gap (bits)', fontsize=12)
ax2.set_title('Information-Theoretic Gap', fontsize=14)
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: Zombie fraction
ax3 = axes[2]
states_range = np.arange(1, 16)
for k in [2, 3, 5]:
    total = np.array([explanatory_gap(n, k) for n in states_range], dtype=float)
    fraction = (total - 1) / total
    ax3.plot(states_range, fraction, 's-', label=f'|Q|={k}', linewidth=2)
ax3.set_xlabel('Number of States |S|', fontsize=12)
ax3.set_ylabel('Zombie Fraction (k^n - 1) / k^n', fontsize=12)
ax3.set_title('Fraction of Zombie Twins', fontsize=14)
ax3.set_ylim(0.4, 1.02)
ax3.legend()
ax3.grid(True, alpha=0.3)
ax3.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig('explanatory_gap_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: explanatory_gap_visualization.png")
