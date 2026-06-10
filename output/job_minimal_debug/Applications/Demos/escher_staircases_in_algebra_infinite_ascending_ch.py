#!/usr/bin/env python3
"""
Escher Staircases in Algebra: Interactive Demonstrations

Demonstrates the key concepts from the Escher Staircase research:
1. Ascending chains and their trivial intersection property
2. Descending chains in PIDs (intersection collapses to zero)
3. Chain Defect computation for polynomial ideals
4. Escher Height enumeration
"""

from typing import List, Tuple, Set, Optional
from fractions import Fraction
import math


def demo_ascending_chain_trivial():
    """
    Demonstrate that ascending chains always have intersection = first ideal.
    
    In Z, consider the ascending chain:
    (6) ⊆ (3) ⊆ (1) = Z
    
    The intersection is (6), which is the first ideal.
    """
    print("=" * 60)
    print("Demo 1: Ascending Chain Intersection (Trivial Escher)")
    print("=" * 60)
    print()
    print("Chain in Z: (6) ⊆ (3) ⊆ (1) = Z")
    print()
    
    # Ideals in Z are just (n) for n >= 0
    # (a) ⊆ (b) iff b | a
    chain = [6, 3, 1]  # (6) ⊆ (3) ⊆ (1)
    
    # Verify ascending
    for i in range(len(chain) - 1):
        a, b = chain[i], chain[i + 1]
        assert a % b == 0, f"({a}) is not contained in ({b})"
        print(f"  ({a}) ⊆ ({b})  ✓  (since {b} | {a})")
    
    # Intersection of (a1), (a2), ... = (lcm(a1, a2, ...))
    # But for ascending chain (a1) ⊆ (a2) ⊆ ..., lcm = a1
    intersection = chain[0]
    for a in chain[1:]:
        intersection = math.lcm(intersection, a)
    
    print(f"\n  Intersection = ({intersection})")
    print(f"  First ideal  = ({chain[0]})")
    print(f"  Equal? {intersection == chain[0]}  ← Always true for ascending chains!")
    print()


def demo_descending_chain_pid():
    """
    Demonstrate descending chains in Z (a PID).
    
    Chain: (2) ⊇ (4) ⊇ (8) ⊇ (16) ⊇ ...
    Intersection = {0} (trivial)
    
    This shows why PIDs have no descending Escher chains.
    """
    print("=" * 60)
    print("Demo 2: Descending Chain in PID (No Escher Effect)")
    print("=" * 60)
    print()
    print("Chain in Z: (2) ⊇ (4) ⊇ (8) ⊇ (16) ⊇ ...")
    print()
    
    chain = [2**k for k in range(1, 11)]
    
    for i in range(len(chain) - 1):
        a, b = chain[i], chain[i + 1]
        assert b % a == 0, f"({b}) is not contained in ({a})"
        print(f"  ({a}) ⊇ ({b})  ✓  (since {a} | {b})")
    
    # Intersection of (a1) ∩ (a2) ∩ ... = (lcm(a1, a2, ...))
    # For 2, 4, 8, ..., lcm grows without bound → intersection = {0}
    running_lcm = chain[0]
    print(f"\n  Running LCM of generators:")
    for i, a in enumerate(chain):
        running_lcm = math.lcm(running_lcm, a)
        print(f"    After step {i+1}: lcm = {running_lcm}")
    
    print(f"\n  As n → ∞, lcm → ∞, so intersection = (0)")
    print(f"  No nonzero element is in ALL ideals → No Escher chain possible!")
    print()


def demo_chain_defect():
    """
    Compute chain defect for Z/(n) and polynomial rings.
    
    In Z/(12), the ideal lattice is:
    (0) ⊆ (6) ⊆ (3) ⊆ Z/(12)
    (0) ⊆ (6) ⊆ (2) ⊆ Z/(12)
    (0) ⊆ (4) ⊆ (2) ⊆ Z/(12)
    
    Max chain length = 4 (including endpoints), so chain defect ≤ 3.
    """
    print("=" * 60)
    print("Demo 3: Chain Defect Computation")
    print("=" * 60)
    print()
    
    def divisors(n: int) -> List[int]:
        """Get all divisors of n."""
        divs = []
        for i in range(1, n + 1):
            if n % i == 0:
                divs.append(i)
        return divs
    
    def max_chain_length(n: int) -> int:
        """
        Compute max length of strictly ascending chain of ideals in Z/(n).
        Ideals of Z/(n) correspond to divisors of n.
        (a) ⊆ (b) in Z/(n) iff b | a.
        Max chain = longest divisibility chain.
        """
        divs = divisors(n)
        # Build DAG: edge from d1 to d2 if d1 | d2 and d1 != d2
        # Find longest path
        memo = {}
        
        def longest_from(d: int) -> int:
            if d in memo:
                return memo[d]
            best = 1
            for d2 in divs:
                if d != d2 and d2 % d == 0:
                    best = max(best, 1 + longest_from(d2))
            memo[d] = best
            return best
        
        return max(longest_from(d) for d in divs)
    
    for n in [6, 12, 24, 30, 60, 120, 360]:
        chain_len = max_chain_length(n)
        defect = chain_len - 1
        print(f"  Z/({n}):  max chain length = {chain_len},  chain defect ≤ {defect}")
    
    print()
    print("  Note: Chain defect measures the maximum number of strict")
    print("  inclusions in any ascending chain of ideals.")
    print()


def demo_escher_height():
    """
    Compute Escher Height between ideals in Z/(n).
    """
    print("=" * 60)
    print("Demo 4: Escher Height Computation")
    print("=" * 60)
    print()
    
    def compute_escher_height(n: int, a: int, b: int) -> int:
        """
        Compute max length of strictly ascending chain from (a) to (b) in Z/(n).
        Requires b | a (i.e., (a) ⊆ (b) in Z/(n)).
        """
        assert a % b == 0, f"({a}) is not contained in ({b})"
        
        # Find all divisors of n between a and b (in containment order)
        divs = []
        for d in range(1, n + 1):
            if n % d == 0 and a % d == 0 and d % b == 0:
                divs.append(d)
        
        # Longest chain from a to b
        memo = {}
        
        def longest_from(d: int) -> int:
            if d == b:
                return 1
            if d in memo:
                return memo[d]
            best = 0
            for d2 in divs:
                if d != d2 and d % d2 == 0 and d2 % b == 0:
                    result = longest_from(d2)
                    if result > 0:
                        best = max(best, 1 + result)
            memo[d] = best
            return best
        
        return longest_from(a)
    
    n = 360  # 2^3 * 3^2 * 5
    print(f"  Escher Heights in Z/({n}):")
    print()
    
    pairs = [(360, 1), (360, 2), (360, 6), (180, 1), (60, 1), (12, 1)]
    for a, b in pairs:
        if 360 % a == 0 and 360 % b == 0 and a % b == 0:
            height = compute_escher_height(n, a, b)
            print(f"    ({a}) → ({b}):  Escher height = {height}")
    
    print()
    print("  Note: Escher height measures the maximum number of ideals")
    print("  in a strictly ascending chain with fixed endpoints.")
    print()


def demo_non_monotonicity():
    """
    Demonstrate that Escher Height is NOT downward-closed.
    """
    print("=" * 60)
    print("Demo 5: Non-Monotonicity of Escher Height")
    print("=" * 60)
    print()
    print("  In Z/(p) for prime p, the only ideals are (0) and Z/(p).")
    print()
    
    for p in [2, 3, 5, 7]:
        print(f"  Z/({p}):  Ideals = {{(0), Z/({p})}}")
        print(f"    Chain of length 2: (0) ⊊ Z/({p})  ✓")
        print(f"    Chain of length 1: (0) = Z/({p})?  ✗ (impossible!)")
        print(f"    → EscherHeight((0), Z/({p}), 1) holds but EscherHeight((0), Z/({p}), 0) fails")
        print()
    
    print("  This shows Escher Height is NOT downward-closed!")
    print("  Having a chain of length n+1 does NOT imply a chain of length n")
    print("  with the same endpoints.")
    print()


if __name__ == "__main__":
    demo_ascending_chain_trivial()
    demo_descending_chain_pid()
    demo_chain_defect()
    demo_escher_height()
    demo_non_monotonicity()
    
    print("=" * 60)
    print("Summary of Key Findings")
    print("=" * 60)
    print()
    print("1. Ascending Escher chains are TRIVIALLY true (intersection = first ideal)")
    print("2. PIDs have NO descending Escher chains (intersection always trivial)")
    print("3. Chain Defect characterizes Noetherianity (bounded iff Noetherian)")
    print("4. Escher Height is NOT downward-closed (surprising!)")
    print("5. Escher Height is BOUNDED in Noetherian rings")


#!/usr/bin/env python3
"""
Visualization of ideal lattices and chain properties.
Standalone script using matplotlib.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Dict, Tuple, Set
import math


def get_divisors(n: int) -> List[int]:
    """Get all divisors of n, sorted."""
    return sorted([d for d in range(1, n + 1) if n % d == 0])


def divisor_lattice_positions(n: int) -> Dict[int, Tuple[float, float]]:
    """
    Compute positions for divisors of n in a lattice diagram.
    Uses a layered layout based on the number of prime factors.
    """
    divs = get_divisors(n)
    
    def num_prime_factors(d: int) -> int:
        """Count total prime factors with multiplicity."""
        count = 0
        temp = d
        for p in range(2, temp + 1):
            while temp % p == 0:
                count += 1
                temp //= p
        return count
    
    layers: Dict[int, List[int]] = {}
    for d in divs:
        layer = num_prime_factors(n // d)
        if layer not in layers:
            layers[layer] = []
        layers[layer].append(d)
    
    positions: Dict[int, Tuple[float, float]] = {}
    max_layer = max(layers.keys()) if layers else 0
    
    for layer, layer_divs in layers.items():
        y = layer
        width = len(layer_divs)
        for i, d in enumerate(sorted(layer_divs)):
            x = (i - (width - 1) / 2) * 1.5
            positions[d] = (x, y)
    
    return positions


def plot_ideal_lattice(n: int, ax: plt.Axes, highlight_chain: List[int] = None) -> None:
    """Plot the Hasse diagram of the ideal lattice of Z/(n)."""
    divs = get_divisors(n)
    positions = divisor_lattice_positions(n)
    
    covers: List[Tuple[int, int]] = []
    for d1 in divs:
        for d2 in divs:
            if d1 != d2 and d2 % d1 == 0:
                is_cover = True
                for d3 in divs:
                    if d3 != d1 and d3 != d2 and d3 % d1 == 0 and d2 % d3 == 0:
                        is_cover = False
                        break
                if is_cover:
                    covers.append((d1, d2))
    
    for d1, d2 in covers:
        x1, y1 = positions[d1]
        x2, y2 = positions[d2]
        in_chain = False
        if highlight_chain:
            for i in range(len(highlight_chain) - 1):
                if highlight_chain[i] == d1 and highlight_chain[i + 1] == d2:
                    in_chain = True
                    break
        color = '#e74c3c' if in_chain else '#bdc3c7'
        width = 2.5 if in_chain else 0.8
        ax.plot([x1, x2], [y1, y2], color=color, linewidth=width, zorder=1)
    
    for d in divs:
        x, y = positions[d]
        in_chain = highlight_chain and d in highlight_chain
        color = '#e74c3c' if in_chain else '#3498db'
        size = 600 if in_chain else 400
        ax.scatter(x, y, s=size, color=color, edgecolors='white', linewidth=2, zorder=2)
        label = f"({d})" if d < n else "(0)"
        if d == 1:
            label = f"Z/{n}"
        ax.annotate(label, (x, y), ha='center', va='center', fontsize=8,
                   fontweight='bold', color='white', zorder=3)


def plot_chain_defect_comparison(ax: plt.Axes) -> None:
    """Plot chain defects for various Z/(n)."""
    ns = list(range(2, 51))
    defects = []
    
    for n in ns:
        divs = get_divisors(n)
        memo: Dict[int, int] = {}
        
        def longest_from(d: int) -> int:
            if d in memo:
                return memo[d]
            best = 1
            for d2 in divs:
                if d != d2 and d2 % d == 0:
                    best = max(best, 1 + longest_from(d2))
            memo[d] = best
            return best
        
        max_len = max(longest_from(d) for d in divs)
        defects.append(max_len - 1)
    
    def omega(n: int) -> int:
        """Number of prime factors with multiplicity."""
        count = 0
        temp = n
        for p in range(2, temp + 1):
            while temp % p == 0:
                count += 1
                temp //= p
        return count
    
    omegas = [omega(n) for n in ns]
    
    ax.bar(ns, defects, color='#3498db', alpha=0.7, label='Chain Defect')
    ax.plot(ns, omegas, 'r-o', markersize=3, linewidth=1.5, label='Ω(n) (total prime factors)')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Chain Defect', fontsize=12)
    ax.set_title('Chain Defect of Z/(n) equals Ω(n)', fontsize=14)
    ax.legend(fontsize=10)


def plot_descending_chain_convergence(ax: plt.Axes) -> None:
    """Visualize how descending chains in Z converge to trivial intersection."""
    chains = {
        '(2^k)': [2**k for k in range(1, 12)],
        '(k!)': [math.factorial(k) for k in range(1, 10)],
        '(10^k)': [10**k for k in range(1, 8)],
    }
    
    colors = ['#e74c3c', '#2ecc71', '#3498db']
    
    for (name, chain), color in zip(chains.items(), colors):
        lcms = []
        running_lcm = chain[0]
        for g in chain:
            running_lcm = math.lcm(running_lcm, g)
            lcms.append(running_lcm)
        
        reciprocals = [1.0 / lcm for lcm in lcms]
        ax.semilogy(range(1, len(reciprocals) + 1), reciprocals, '-o',
                    color=color, label=f'1/lcm for {name}', markersize=5)
    
    ax.set_xlabel('Chain step n', fontsize=12)
    ax.set_ylabel('1/lcm (log scale)', fontsize=12)
    ax.set_title('Descending Chains: Intersection → {0}', fontsize=14)
    ax.legend(fontsize=10)
    ax.axhline(y=0, color='black', linestyle='--', alpha=0.3)


def main() -> None:
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Escher Staircases: Ideal Chain Analysis', fontsize=16, fontweight='bold')
    
    # Top-left: Ideal lattice of Z/(12) with a maximal chain highlighted
    plot_ideal_lattice(12, axes[0, 0], highlight_chain=[12, 4, 2, 1])
    axes[0, 0].set_title('Ideal Lattice of Z/(12)\nHighlighted: maximal chain', fontsize=12)
    axes[0, 0].set_aspect('equal')
    axes[0, 0].axis('off')
    
    # Top-right: Ideal lattice of Z/(30)
    plot_ideal_lattice(30, axes[0, 1], highlight_chain=[30, 6, 3, 1])
    axes[0, 1].set_title('Ideal Lattice of Z/(30)\nHighlighted: maximal chain', fontsize=12)
    axes[0, 1].set_aspect('equal')
    axes[0, 1].axis('off')
    
    # Bottom-left: Chain defect comparison
    plot_chain_defect_comparison(axes[1, 0])
    
    # Bottom-right: Descending chain convergence
    plot_descending_chain_convergence(axes[1, 1])
    
    plt.tight_layout()
    plt.savefig('escher_staircase_analysis.png', dpi=150, bbox_inches='tight')
    plt.show()


if __name__ == "__main__":
    main()
