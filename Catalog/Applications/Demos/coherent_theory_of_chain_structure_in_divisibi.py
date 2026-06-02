#!/usr/bin/env python3
"""
demo.py — Chain Invariants in Divisibility Lattices

Demonstrates the Chain Rank Theorem, Spectrum Rigidity, and related results
through concrete numerical examples.
"""

from collections import Counter
from itertools import permutations
from math import log2, prod
from typing import List, Dict, Tuple


def factorize(n: int) -> List[int]:
    """Return the list of prime factors of n with multiplicity, sorted."""
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def omega(n: int) -> int:
    """Ω(n): number of prime factors with multiplicity."""
    return len(factorize(n))


def sopfr(n: int) -> int:
    """sopfr(n): sum of prime factors with repetition."""
    return sum(factorize(n))


def find_maximal_chains(n: int) -> List[List[int]]:
    """Find all maximal divisibility chains from 1 to n."""
    factors = factorize(n)
    chains = set()
    
    # Each maximal chain corresponds to a distinct permutation of the factor list
    for perm in set(permutations(factors)):
        chain = [1]
        for p in perm:
            chain.append(chain[-1] * p)
        chains.add(tuple(chain))
    
    return [list(c) for c in sorted(chains)]


def chain_spectrum(chain: List[int]) -> List[int]:
    """Compute the spectrum (list of consecutive quotients) of a chain."""
    return [chain[i+1] // chain[i] for i in range(len(chain) - 1)]


def multinomial_coefficient(factors: List[int]) -> int:
    """Compute the multinomial coefficient Ω(n)! / ∏ eᵢ!."""
    from math import factorial
    total = len(factors)
    counts = Counter(factors)
    denom = prod(factorial(e) for e in counts.values())
    return factorial(total) // denom


def demo_chain_rank_theorem():
    """Demonstrate the Chain Rank Theorem for several values of n."""
    print("=" * 60)
    print("CHAIN RANK THEOREM: max chain length from 1 to n = Ω(n)")
    print("=" * 60)
    
    test_values = [12, 30, 60, 72, 360, 2310]
    
    for n in test_values:
        factors = factorize(n)
        om = omega(n)
        chains = find_maximal_chains(n)
        
        print(f"\nn = {n}")
        print(f"  Factorization: {' × '.join(map(str, factors))}")
        print(f"  Ω({n}) = {om}")
        print(f"  Number of maximal chains: {len(chains)}")
        print(f"  Multinomial prediction: {multinomial_coefficient(factors)}")
        
        if n <= 100:
            for chain in chains:
                spec = chain_spectrum(chain)
                print(f"  Chain: {' → '.join(map(str, chain))}")
                print(f"    Spectrum: {spec}, Sum = {sum(spec)}")


def demo_spectrum_rigidity():
    """Demonstrate Spectrum Sum Rigidity: all maximal chains have same sum."""
    print("\n" + "=" * 60)
    print("SPECTRUM SUM RIGIDITY: spectrum sum = sopfr(n) always")
    print("=" * 60)
    
    for n in [12, 30, 60, 120, 180]:
        chains = find_maximal_chains(n)
        sums = set()
        for chain in chains:
            spec = chain_spectrum(chain)
            sums.add(sum(spec))
        
        s = sopfr(n)
        status = "✓" if sums == {s} else "✗"
        print(f"\nn = {n}: sopfr = {s}, spectrum sums = {sums} {status}")
        
        # Show that the multiset of quotients is always the same
        multisets = set()
        for chain in chains:
            spec = chain_spectrum(chain)
            multisets.add(tuple(sorted(spec)))
        
        print(f"  All spectra (as sorted lists): {multisets}")
        print(f"  primeFactorsList({n}) = {factorize(n)}")
        print(f"  Match: {'✓' if multisets == {tuple(factorize(n))} else '✗'}")


def demo_exponential_growth():
    """Demonstrate that chain elements grow at least as fast as 2^k."""
    print("\n" + "=" * 60)
    print("EXPONENTIAL GROWTH: chain[k] ≥ 2^k")
    print("=" * 60)
    
    for n in [60, 360, 2520]:
        chains = find_maximal_chains(n)
        chain = chains[0]  # Take the first maximal chain
        
        print(f"\nn = {n}, chain = {' → '.join(map(str, chain))}")
        print(f"  {'k':>3} | {'chain[k]':>10} | {'2^k':>10} | {'chain[k] ≥ 2^k':>15}")
        print(f"  {'-'*3} | {'-'*10} | {'-'*10} | {'-'*15}")
        for k, val in enumerate(chain):
            bound = 2**k
            check = "✓" if val >= bound else "✗"
            print(f"  {k:>3} | {val:>10} | {bound:>10} | {check:>15}")


def demo_chain_defect():
    """Demonstrate chain defect for non-maximal chains."""
    print("\n" + "=" * 60)
    print("CHAIN DEFECT: Ω(n) - chain length")
    print("=" * 60)
    
    n = 60
    om = omega(n)
    
    # Non-maximal chains
    chains = [
        [1, 60],           # length 1, defect = 3
        [1, 2, 60],        # length 2, defect = 2
        [1, 4, 60],        # length 2, defect = 2
        [1, 2, 6, 60],     # length 3, defect = 1
        [1, 2, 4, 60],     # length 3, defect = 1
        [1, 2, 4, 12, 60], # length 4, defect = 0 (maximal)
    ]
    
    print(f"\nn = {n}, Ω(n) = {om}")
    for chain in chains:
        length = len(chain) - 1
        defect = om - length
        spec = chain_spectrum(chain)
        print(f"  Chain: {' → '.join(map(str, chain))}")
        print(f"    Length = {length}, Defect = {defect}, Spectrum = {spec}, Sum = {sum(spec)}")


def demo_chain_count_conjecture():
    """Test the Chain Count Conjecture for n up to 500."""
    print("\n" + "=" * 60)
    print("CHAIN COUNT CONJECTURE: #maximal chains = multinomial coeff")
    print("=" * 60)
    
    print(f"\n{'n':>6} | {'factorization':>20} | {'Ω(n)':>4} | {'#chains':>8} | {'predicted':>9} | {'match':>5}")
    print(f"{'-'*6} | {'-'*20} | {'-'*4} | {'-'*8} | {'-'*9} | {'-'*5}")
    
    test_values = [6, 8, 12, 18, 24, 30, 36, 48, 60, 72, 120, 180, 210, 360]
    
    for n in test_values:
        factors = factorize(n)
        om = omega(n)
        chains = find_maximal_chains(n)
        predicted = multinomial_coefficient(factors)
        match = "✓" if len(chains) == predicted else "✗"
        
        fact_str = ' × '.join(map(str, factors))
        print(f"{n:>6} | {fact_str:>20} | {om:>4} | {len(chains):>8} | {predicted:>9} | {match:>5}")


def demo_omega_vs_log2():
    """Demonstrate that Ω(n) ≤ log₂(n)."""
    print("\n" + "=" * 60)
    print("LOGARITHMIC BOUND: Ω(n) ≤ log₂(n)")
    print("=" * 60)
    
    # Find numbers where Ω(n) is close to log₂(n)
    print(f"\n{'n':>10} | {'Ω(n)':>5} | {'⌊log₂(n)⌋':>10} | {'ratio':>8}")
    print(f"{'-'*10} | {'-'*5} | {'-'*10} | {'-'*8}")
    
    # Powers of 2 maximize the ratio
    for k in range(1, 21):
        n = 2**k
        om = omega(n)
        lg = int(log2(n))
        ratio = om / lg if lg > 0 else 0
        print(f"{n:>10} | {om:>5} | {lg:>10} | {ratio:>8.3f}")


if __name__ == "__main__":
    demo_chain_rank_theorem()
    demo_spectrum_rigidity()
    demo_exponential_growth()
    demo_chain_defect()
    demo_chain_count_conjecture()
    demo_omega_vs_log2()


#!/usr/bin/env python3
"""
visualize_chains.py — Visualize divisibility chain structure.

Produces a matplotlib figure showing:
1. All maximal chains from 1 to n as paths in the divisibility lattice
2. The Hasse diagram of divisors of n
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
from itertools import permutations
from math import factorial, prod


def factorize(n):
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def big_omega(n):
    return len(factorize(n))


def divisors(n):
    divs = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs


def enumerate_maximal_chains(n):
    factors = factorize(n)
    if not factors:
        return [[1]] if n == 1 else []
    chains = set()
    for perm in set(permutations(factors)):
        chain = [1]
        for p in perm:
            chain.append(chain[-1] * p)
        chains.add(tuple(chain))
    return [list(c) for c in sorted(chains)]


def plot_divisibility_lattice(n, ax):
    """Plot the Hasse diagram of divisors of n with maximal chains highlighted."""
    divs = divisors(n)
    
    # Assign y-coordinate based on Omega
    y_pos = {d: big_omega(d) for d in divs}
    
    # Assign x-coordinate: spread elements at same level
    levels = {}
    for d in divs:
        lev = y_pos[d]
        if lev not in levels:
            levels[lev] = []
        levels[lev].append(d)
    
    x_pos = {}
    for lev, elements in levels.items():
        for i, d in enumerate(sorted(elements)):
            x_pos[d] = (i - (len(elements) - 1) / 2) * 1.5
    
    # Draw edges (Hasse diagram: d1 -> d2 if d1 | d2 and d2/d1 is prime)
    for d1 in divs:
        for d2 in divs:
            if d1 != d2 and d2 % d1 == 0:
                q = d2 // d1
                if len(factorize(q)) == 1:  # q is prime
                    ax.plot([x_pos[d1], x_pos[d2]], [y_pos[d1], y_pos[d2]], 
                           'k-', alpha=0.2, linewidth=1)
    
    # Highlight maximal chains
    chains = enumerate_maximal_chains(n)
    colors = plt.cm.Set1(np.linspace(0, 1, min(len(chains), 9)))
    
    for idx, chain in enumerate(chains[:9]):
        color = colors[idx % len(colors)]
        for i in range(len(chain) - 1):
            d1, d2 = chain[i], chain[i + 1]
            ax.plot([x_pos[d1], x_pos[d2]], [y_pos[d1], y_pos[d2]], 
                   '-', color=color, linewidth=2.5, alpha=0.7)
    
    # Draw nodes
    for d in divs:
        ax.plot(x_pos[d], y_pos[d], 'o', color='white', markersize=20, 
               markeredgecolor='black', markeredgewidth=1.5, zorder=5)
        ax.text(x_pos[d], y_pos[d], str(d), ha='center', va='center', 
               fontsize=8, fontweight='bold', zorder=6)
    
    ax.set_ylabel('Ω (chain depth)', fontsize=11)
    ax.set_title(f'Divisibility lattice of {n}\n'
                f'Ω({n}) = {big_omega(n)}, '
                f'{len(chains)} maximal chain{"s" if len(chains) > 1 else ""}',
                fontsize=12)
    ax.set_xlim(-4, 4)


fig, axes = plt.subplots(1, 3, figsize=(18, 7))

for ax, n in zip(axes, [12, 30, 60]):
    plot_divisibility_lattice(n, ax)

plt.tight_layout()
plt.savefig('divisibility_lattice.png', dpi=150, bbox_inches='tight')
print("Saved divisibility_lattice.png")


#!/usr/bin/env python3
"""
visualize_spectrum.py — Visualize spectrum sum rigidity and chain statistics.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
from itertools import permutations
from math import factorial, log2, prod


def factorize(n):
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def big_omega(n):
    return len(factorize(n))


def sopfr(n):
    return sum(factorize(n))


def count_maximal_chains(n):
    factors = factorize(n)
    total = len(factors)
    counts = Counter(factors)
    denom = prod(factorial(e) for e in counts.values())
    return factorial(total) // denom


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Ω(n) vs log₂(n)
ax = axes[0, 0]
ns = range(2, 501)
omegas = [big_omega(n) for n in ns]
logs = [log2(n) for n in ns]
ax.scatter(ns, omegas, s=3, alpha=0.5, label='Ω(n)', color='blue')
ax.plot(ns, logs, 'r-', linewidth=1.5, alpha=0.7, label='log₂(n)')
ax.set_xlabel('n')
ax.set_ylabel('Value')
ax.set_title('Chain Rank Theorem: Ω(n) ≤ log₂(n)')
ax.legend()

# Plot 2: sopfr(n) distribution
ax = axes[0, 1]
ns = range(2, 501)
sopfrs = [sopfr(n) for n in ns]
ax.scatter(ns, sopfrs, s=3, alpha=0.5, color='green')
ax.set_xlabel('n')
ax.set_ylabel('sopfr(n)')
ax.set_title('Spectrum Sum sopfr(n) = Sum of Prime Factors')

# Plot 3: Number of maximal chains
ax = axes[1, 0]
ns_small = range(2, 201)
chain_counts = [count_maximal_chains(n) for n in ns_small]
ax.bar(ns_small, chain_counts, width=1, alpha=0.7, color='purple')
ax.set_xlabel('n')
ax.set_ylabel('Number of maximal chains')
ax.set_title('Chain Count (Multinomial Coefficient)')
ax.set_yscale('log')

# Plot 4: Ω(n) / log₂(n) ratio
ax = axes[1, 1]
ns = range(2, 1001)
ratios = [big_omega(n) / log2(n) for n in ns]
ax.scatter(ns, ratios, s=2, alpha=0.3, color='orange')
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='upper bound')
ax.set_xlabel('n')
ax.set_ylabel('Ω(n) / log₂(n)')
ax.set_title('Relative Chain Depth: Ω(n) / log₂(n) ≤ 1')
ax.legend()
ax.set_ylim(0, 1.1)

plt.suptitle('Chain Invariants in Divisibility Lattices', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('chain_statistics.png', dpi=150, bbox_inches='tight')
print("Saved chain_statistics.png")
