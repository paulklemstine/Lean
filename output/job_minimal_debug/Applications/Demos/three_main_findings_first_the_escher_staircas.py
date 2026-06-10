#!/usr/bin/env python3
"""
Escher Staircases: Demonstrations of chain invariants and the anti-Escher property.

This module demonstrates the key results from the Escher Staircase theory:
1. The ascending chain intersection triviality
2. The big omega function and divisor chain lengths
3. The anti-Escher property for ℤ (descending chains converge to zero)
4. Chain defect computation
"""

from math import gcd
from collections import Counter
from typing import List, Tuple


def prime_factorization(n: int) -> Counter:
    """Return the prime factorization of n as a Counter {prime: exponent}."""
    if n <= 1:
        return Counter()
    factors = Counter()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] += 1
            n //= d
        d += 1
    if n > 1:
        factors[n] += 1
    return factors


def big_omega(n: int) -> int:
    """Compute Ω(n) = total number of prime factors with multiplicity."""
    return sum(prime_factorization(n).values())


def divisor_chain_max_length(n: int) -> int:
    """Maximum length of a strictly ascending divisor chain from 1 to n.
    This equals Ω(n)."""
    return big_omega(n)


def find_maximal_divisor_chains(n: int) -> List[List[int]]:
    """Find all maximal (longest) strictly ascending divisor chains from 1 to n."""
    target_len = big_omega(n)
    chains: List[List[int]] = []

    def backtrack(current: int, chain: List[int], remaining_factors: Counter):
        if current == n:
            if len(chain) - 1 == target_len:
                chains.append(chain[:])
            return
        for p in sorted(remaining_factors):
            if remaining_factors[p] > 0:
                next_val = current * p
                remaining_factors[p] -= 1
                chain.append(next_val)
                backtrack(next_val, chain, remaining_factors)
                chain.pop()
                remaining_factors[p] += 1

    factors = prime_factorization(n)
    backtrack(1, [1], factors)
    return chains


def chain_defect(seq: List[int]) -> int:
    """Compute the chain defect (stabilization index) of a sequence."""
    for i in range(len(seq)):
        if all(seq[j] == seq[i] for j in range(i, len(seq))):
            return i
    return len(seq) - 1


def descending_chain_demo(initial: int, factor: int, steps: int) -> Tuple[List[int], int]:
    """Demonstrate a descending chain of ideals in ℤ.
    Returns (generators, intersection element).
    The chain is (initial) ⊇ (initial*factor) ⊇ (initial*factor²) ⊇ ...
    The intersection is always {0} (anti-Escher property).
    """
    generators = [initial * (factor ** k) for k in range(steps)]
    # The intersection of all Span{g_k} consists of multiples of all generators
    # For x to be in all ideals, g_k | x for all k
    # Since |g_k| → ∞, only x = 0 works
    return generators, 0


def verify_anti_escher(generators: List[int], x: int) -> bool:
    """Verify that x is NOT in the intersection of Span{g} for all g in generators
    (unless x = 0)."""
    if x == 0:
        return True  # 0 is always in every ideal
    for g in generators:
        if g != 0 and x % g != 0:
            return True  # x is not in Span{g}, so not in intersection
    return False  # x is in all ideals — shouldn't happen for x ≠ 0 if chain is long enough


# ============================================================================
# DEMONSTRATIONS
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("ESCHER STAIRCASES: Chain Invariants and the Anti-Escher Property")
    print("=" * 70)

    # Demo 1: Big Omega function
    print("\n--- Demo 1: The Big Omega Function Ω(n) ---")
    test_values = [1, 2, 3, 4, 6, 8, 12, 24, 30, 60, 100, 360, 1000]
    print(f"{'n':>6} {'Ω(n)':>6} {'factorization':>20} {'max chain length':>16}")
    print("-" * 52)
    for n in test_values:
        factors = prime_factorization(n)
        factor_str = " · ".join(
            f"{p}^{e}" if e > 1 else str(p)
            for p, e in sorted(factors.items())
        ) if n > 1 else "1"
        print(f"{n:>6} {big_omega(n):>6} {factor_str:>20} {divisor_chain_max_length(n):>16}")

    # Demo 2: Maximal divisor chains
    print("\n--- Demo 2: All Maximal Divisor Chains ---")
    for n in [12, 30, 36]:
        chains = find_maximal_divisor_chains(n)
        print(f"\nn = {n}, Ω({n}) = {big_omega(n)}, "
              f"number of maximal chains = {len(chains)}")
        for i, chain in enumerate(chains):
            print(f"  Chain {i+1}: {' | '.join(map(str, chain))}")

    # Demo 3: Coprime additivity
    print("\n--- Demo 3: Coprime Additivity of Ω ---")
    pairs = [(6, 35), (4, 9), (8, 27), (15, 14), (100, 63)]
    for a, b in pairs:
        g = gcd(a, b)
        symbol = "✓" if g == 1 else "✗"
        result = f"Ω({a}·{b}) = Ω({a*b}) = {big_omega(a*b)}"
        check = f"Ω({a}) + Ω({b}) = {big_omega(a)} + {big_omega(b)} = {big_omega(a) + big_omega(b)}"
        match = "✓" if big_omega(a * b) == big_omega(a) + big_omega(b) else "✗"
        print(f"  gcd({a},{b})={g} {symbol}  {result}, {check} {match}")

    # Demo 4: Anti-Escher property
    print("\n--- Demo 4: Anti-Escher Property in ℤ ---")
    print("Strictly descending chain: (2) ⊋ (4) ⊋ (8) ⊋ (16) ⊋ ...")
    generators, _ = descending_chain_demo(2, 2, 20)
    print(f"Generators: {generators[:8]}...")
    print(f"|g_n| grows as: {[abs(g) for g in generators[:8]]}...")

    # Test various x values
    test_x = [0, 1, 2, 100, 1024, 2**20, 2**30]
    for x in test_x:
        # Check how many generators divide x
        divides = sum(1 for g in generators if g != 0 and x % g == 0)
        status = "IN all" if divides == len(generators) else f"fails at step {divides}"
        print(f"  x = {x:>12}: {status}")

    # Demo 5: Chain defect
    print("\n--- Demo 5: Chain Defect (Stabilization Index) ---")
    sequences = [
        ("constant", [5, 5, 5, 5, 5]),
        ("1 step", [1, 3, 3, 3, 3]),
        ("2 steps", [1, 2, 4, 4, 4]),
        ("3 steps", [1, 2, 3, 5, 5]),
        ("never (truncated)", [1, 2, 3, 4, 5]),
    ]
    for name, seq in sequences:
        cd = chain_defect(seq)
        print(f"  {name:>20}: {seq} → chain defect = {cd}")

    # Demo 6: Growth rate in descending chains
    print("\n--- Demo 6: Exponential Growth in Descending Chains ---")
    print("For chain (a₀) ⊋ (a₀·c₁) ⊋ (a₀·c₁·c₂) ⊋ ... where |cₙ| ≥ 2:")
    a0 = 3
    for n in range(10):
        gen = a0 * (2 ** n)
        bound = a0 * (2 ** n)
        print(f"  n={n:>2}: |f(n)| = {gen:>8}, lower bound |f(0)|·2^n = {bound:>8}")

    print("\n" + "=" * 70)
    print("All demonstrations complete. Key insight: descending chains in ℤ")
    print("always converge to {0} — the Anti-Escher Property holds.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Divisor lattice and maximal chain structure.
Standalone matplotlib script — no local imports.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import Counter
from math import factorial
from functools import reduce


def prime_factorization(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = 1
    return factors


def big_omega(n):
    return sum(prime_factorization(n).values())


def divisors(n):
    divs = set()
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            divs.add(d)
            divs.add(n // d)
    return sorted(divs)


def maximal_divisor_chains(n):
    target_len = big_omega(n)
    chains = []
    factors = Counter(prime_factorization(n))

    def backtrack(current, chain):
        if current == n:
            if len(chain) - 1 == target_len:
                chains.append(chain[:])
            return
        for p in sorted(factors):
            if factors[p] > 0:
                nv = current * p
                factors[p] -= 1
                chain.append(nv)
                backtrack(nv, chain)
                chain.pop()
                factors[p] += 1

    backtrack(1, [1])
    return chains


# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Plot 1: Big Omega function ---
ax1 = axes[0]
ns = list(range(2, 101))
omegas = [big_omega(n) for n in ns]
colors = ['#e74c3c' if len(prime_factorization(n)) == 1 else '#3498db' for n in ns]
ax1.scatter(ns, omegas, c=colors, s=15, alpha=0.7)
ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('Ω(n)', fontsize=12)
ax1.set_title('Big Omega Function Ω(n)', fontsize=14)
ax1.legend(handles=[
    mpatches.Patch(color='#e74c3c', label='Prime powers'),
    mpatches.Patch(color='#3498db', label='Composite')
], loc='upper left')
ax1.grid(True, alpha=0.3)

# --- Plot 2: Divisor lattice of 36 ---
ax2 = axes[1]
n = 36
divs = divisors(n)
# Arrange by big_omega value (layer)
layers = {}
for d in divs:
    bo = big_omega(d)
    layers.setdefault(bo, []).append(d)

positions = {}
for layer, elements in layers.items():
    for i, d in enumerate(elements):
        x = (i - (len(elements) - 1) / 2) * 1.5
        positions[d] = (x, layer)

# Draw edges
for d1 in divs:
    for d2 in divs:
        if d2 > d1 and d2 % d1 == 0 and big_omega(d2) == big_omega(d1) + 1:
            x1, y1 = positions[d1]
            x2, y2 = positions[d2]
            ax2.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

# Highlight one maximal chain
chains = maximal_divisor_chains(n)
if chains:
    chain = chains[0]
    for i in range(len(chain) - 1):
        x1, y1 = positions[chain[i]]
        x2, y2 = positions[chain[i + 1]]
        ax2.plot([x1, x2], [y1, y2], 'r-', alpha=0.8, linewidth=2.5)

# Draw nodes
for d in divs:
    x, y = positions[d]
    color = '#e74c3c' if d in chains[0] else '#3498db'
    ax2.plot(x, y, 'o', color=color, markersize=20, markeredgecolor='black',
             markeredgewidth=1)
    ax2.text(x, y, str(d), ha='center', va='center', fontsize=8, fontweight='bold')

ax2.set_title(f'Divisor Lattice of {n}\n(red = maximal chain)', fontsize=14)
ax2.set_ylabel('Ω(d)', fontsize=12)
ax2.set_xticks([])
ax2.grid(True, alpha=0.2, axis='y')

# --- Plot 3: Anti-Escher exponential growth ---
ax3 = axes[2]
steps = 15
generators_2 = [2 * (2**k) for k in range(steps)]
generators_3 = [3 * (3**k) for k in range(steps)]
generators_5 = [5 * (2**k) for k in range(steps)]

ax3.semilogy(range(steps), generators_2, 'ro-', label='(2)⊋(4)⊋(8)⊋...', markersize=5)
ax3.semilogy(range(steps), generators_3, 'bs-', label='(3)⊋(9)⊋(27)⊋...', markersize=5)
ax3.semilogy(range(steps), generators_5, 'g^-', label='(5)⊋(10)⊋(20)⊋...', markersize=5)
ax3.axhline(y=100, color='purple', linestyle='--', alpha=0.5, label='|x| = 100')
ax3.fill_between(range(steps), 0, 100, alpha=0.1, color='purple')
ax3.set_xlabel('Chain step n', fontsize=12)
ax3.set_ylabel('|generator| (log scale)', fontsize=12)
ax3.set_title('Anti-Escher: Generators Grow\nExponentially → ⋂ = {0}', fontsize=14)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.text(8, 50, 'x=100 can only\nsurvive this far →',
         fontsize=9, ha='center', color='purple', style='italic')

plt.tight_layout()
plt.savefig('/workspace/request-project/escher_staircase_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved escher_staircase_analysis.png")
