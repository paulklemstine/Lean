#!/usr/bin/env python3
"""
Demo: Galois Theory of Cellular Automata — Reversibility Group Computation

Computes the orbit structure of the shift action on binary configurations
and derives the centralizer (reversibility group) order for small n.
"""

import math
from collections import Counter
from itertools import product as cart_product


def binary_configs(n):
    """Generate all binary configurations of length n (as tuples)."""
    return list(cart_product([0, 1], repeat=n))


def shift(config, k=1):
    """Shift a configuration by k positions (mod n)."""
    n = len(config)
    return tuple(config[(i + k) % n] for i in range(n))


def shift_orbit(config):
    """Compute the shift orbit of a configuration."""
    orbit = set()
    c = config
    n = len(config)
    for _ in range(n):
        orbit.add(c)
        c = shift(c)
    return frozenset(orbit)


def orbit_decomposition(n):
    """Compute the orbit decomposition of {0,1}^n under the shift action."""
    configs = binary_configs(n)
    seen = set()
    orbits = []
    for c in configs:
        if c not in seen:
            orb = shift_orbit(c)
            seen |= orb
            orbits.append(orb)
    return orbits


def orbit_type(n):
    """Compute the orbit type: a Counter mapping orbit_size -> count."""
    orbits = orbit_decomposition(n)
    return Counter(len(orb) for orb in orbits)


def centralizer_order(orbit_counts):
    """Compute the centralizer order from orbit type data.
    
    Formula: prod_{d} d^{a_d} * a_d!
    where a_d = number of orbits of size d.
    """
    result = 1
    for d, a_d in orbit_counts.items():
        result *= (d ** a_d) * math.factorial(a_d)
    return result


def necklace_count(n, k=2):
    """Number of necklaces of length n with k colors (Burnside's lemma)."""
    if n == 0:
        return 0
    total = sum(k ** math.gcd(i, n) for i in range(n))
    return total // n


def main():
    print("=" * 70)
    print("GALOIS THEORY OF CELLULAR AUTOMATA: REVERSIBILITY GROUP")
    print("=" * 70)
    
    print("\n--- Orbit Decomposition for Binary CAs on Z/nZ ---\n")
    
    for n in range(1, 8):
        orbits = orbit_decomposition(n)
        ot = orbit_type(n)
        co = centralizer_order(ot)
        total = 2 ** n
        sym_order = math.factorial(total)
        
        print(f"n = {n}:")
        print(f"  Total configurations: 2^{n} = {total}")
        print(f"  Number of orbits: {len(orbits)}")
        print(f"  Orbit type: {dict(sorted(ot.items()))}")
        print(f"  Centralizer order |G| = {co}")
        print(f"  Full symmetric group |S_{total}| = {sym_order}")
        ratio = co / sym_order if sym_order > 0 else 0
        print(f"  Ratio |G|/|S_{total}| = {ratio:.2e}")
        print(f"  Necklace count (Burnside): {necklace_count(n)}")
        print()
    
    print("\n--- Reversibility Index (log ratio) ---\n")
    for n in range(1, 8):
        ot = orbit_type(n)
        co = centralizer_order(ot)
        total = 2 ** n
        sym_order = math.factorial(total)
        if co > 0 and sym_order > 0:
            log_ratio = math.log2(co) / math.log2(sym_order) if sym_order > 1 else 1.0
            print(f"  n={n}: log₂|G|/log₂|S_{total}| = {log_ratio:.6f}")
    
    print("\n--- Falsifiable Conjecture Test ---")
    print("For n prime, non-constant orbits = (2^n - 2) / n")
    for p in [2, 3, 5, 7, 11, 13]:
        from sympy import isprime
        if isprime(p):
            expected = (2**p - 2) // p
            actual = necklace_count(p) - 2  # subtract the 2 constant necklaces... 
            # Actually necklace_count already gives total necklaces including constants
            actual_nonconstant = necklace_count(p) - 2
            print(f"  p={p}: (2^p - 2)/p = {expected}, necklaces - 2 = {actual_nonconstant}, match: {expected == actual_nonconstant}")
    
    print("\n--- The 6 Reversible Elementary CA Rules (r=1) ---\n")
    reversible_rules = [15, 51, 85, 170, 204, 240]
    for rule_num in reversible_rules:
        # Rule number encodes f: {0,1}^3 -> {0,1}
        rule = [(rule_num >> i) & 1 for i in range(8)]
        print(f"  Rule {rule_num:3d}: {rule} (binary: {rule_num:08b})")
    
    print("\n  These are exactly the 6 rules where the local map is a")
    print("  permutation that commutes with cyclic shift of neighborhoods.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Reversibility Group Order vs Symmetric Group Order

Shows how the reversibility group becomes exponentially smaller than
the full symmetric group as the period n increases.
"""

import math
from collections import Counter
from itertools import product as cart_product

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def shift_config(config, k=1):
    n = len(config)
    return tuple(config[(i + k) % n] for i in range(n))


def compute_shift_orbit(config):
    orbit = set()
    c = config
    n = len(config)
    for _ in range(n):
        orbit.add(c)
        c = shift_config(c)
    return frozenset(orbit)


def orbit_type(n):
    configs = list(cart_product([0, 1], repeat=n))
    seen = set()
    size_counts = Counter()
    for c in configs:
        if c not in seen:
            orb = compute_shift_orbit(c)
            seen |= orb
            size_counts[len(orb)] += 1
    return dict(size_counts)


def centralizer_order(orbit_counts):
    result = 1
    for d, a_d in orbit_counts.items():
        if d > 0:
            result *= (d ** a_d) * math.factorial(a_d)
    return result


def main():
    ns = list(range(1, 10))
    log_G = []
    log_S = []
    ratios = []
    
    for n in ns:
        ot = orbit_type(n)
        co = centralizer_order(ot)
        total = 2 ** n
        sym = math.factorial(total)
        
        lg = math.log2(co) if co > 0 else 0
        ls = math.log2(sym) if sym > 1 else 1
        log_G.append(lg)
        log_S.append(ls)
        ratios.append(lg / ls if ls > 0 else 0)
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Plot 1: Log orders
    ax1 = axes[0]
    ax1.plot(ns, log_G, 'bo-', label='log₂|G(n)|', markersize=8)
    ax1.plot(ns, log_S, 'rs-', label='log₂|S_{2^n}|', markersize=8)
    ax1.set_xlabel('Period n')
    ax1.set_ylabel('log₂(group order)')
    ax1.set_title('Reversibility Group vs Full Symmetric Group')
    ax1.legend()
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Ratio
    ax2 = axes[1]
    ax2.plot(ns, ratios, 'g^-', markersize=10, linewidth=2)
    ax2.set_xlabel('Period n')
    ax2.set_ylabel('Reversibility Index')
    ax2.set_title('RI = log₂|G|/log₂|S| → 0')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1)
    
    # Plot 3: Orbit type decomposition
    ax3 = axes[2]
    max_d = max(max(orbit_type(n).keys()) for n in ns)
    for d in range(1, max_d + 1):
        counts = [orbit_type(n).get(d, 0) for n in ns]
        if any(c > 0 for c in counts):
            ax3.bar([x + d * 0.1 for x in ns], counts, width=0.1,
                    label=f'size {d}', alpha=0.8)
    ax3.set_xlabel('Period n')
    ax3.set_ylabel('Number of orbits')
    ax3.set_title('Orbit Size Distribution')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('reversibility_groups.png', dpi=150, bbox_inches='tight')
    print("Saved: reversibility_groups.png")


if __name__ == "__main__":
    main()
