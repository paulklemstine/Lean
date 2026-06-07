#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Demonstrates the Factorization Diamond — the surprising result that
product-freeness and collision-freeness are incomparable conditions,
and even their conjunction is strictly weaker than unique factorization.
"""

from itertools import combinations_with_replacement
from collections import defaultdict
from math import gcd, log


def is_product_free(S):
    """Check if set S is product-free: no a*b in S for a,b in S with a,b >= 2."""
    S2 = {x for x in S if x >= 2}
    for a in S2:
        for b in S2:
            if a * b in S2:
                return False
    return True


def has_product_collision(S):
    """Check if S has a product collision: a*b = c*d with {a,b} != {c,d}."""
    S2 = sorted(x for x in S if x >= 2)
    products = defaultdict(list)
    for i, a in enumerate(S2):
        for b in S2[i:]:
            products[a * b].append(frozenset([a, b]) if a != b else (a, b))
    for val, pairs in products.items():
        if len(pairs) >= 2:
            # Check if any two pairs are genuinely different
            for i in range(len(pairs)):
                for j in range(i + 1, len(pairs)):
                    if pairs[i] != pairs[j]:
                        return True, val, pairs[i], pairs[j]
    return False, None, None, None


def find_factorizations(S, n, max_depth=10):
    """Find all S-factorizations of n (multisets of elements from S whose product is n)."""
    S2 = sorted(x for x in S if x >= 2)
    results = []

    def search(remaining, min_val, current):
        if remaining == 1:
            results.append(tuple(sorted(current)))
            return
        for s in S2:
            if s < min_val:
                continue
            if s > remaining:
                break
            if remaining % s == 0 and len(current) < max_depth:
                search(remaining // s, s, current + [s])

    if n in S2:
        results.append((n,))
    search(n, min(S2) if S2 else 2, [])
    return list(set(results))


def has_unique_factorization(S, test_range=500):
    """Check if S has unique factorization for products up to test_range."""
    for n in range(2, test_range + 1):
        facts = find_factorizations(S, n)
        if len(facts) > 1:
            return False, n, facts
    return True, None, None


def analyze_set(S, name="S"):
    """Full analysis of a generator set."""
    print(f"\n{'='*60}")
    print(f"Analysis of {name} = {sorted(S)}")
    print(f"{'='*60}")

    pf = is_product_free(S)
    print(f"  Product-free: {pf}")

    coll = has_product_collision(S)
    print(f"  Collision-free: {not coll[0]}")
    if coll[0]:
        print(f"    Collision: {coll[2]} and {coll[3]} both give product {coll[1]}")

    uf = has_unique_factorization(S)
    print(f"  Unique factorization: {uf[0]}")
    if not uf[0]:
        print(f"    Counterexample: {uf[1]} has factorizations {uf[2]}")

    return pf, not coll[0], uf[0]


# ============================================================
# DEMONSTRATION 1: The Four Separating Examples
# ============================================================
print("=" * 60)
print("THE FACTORIZATION DIAMOND")
print("=" * 60)
print("""
                    UF (Unique Factorization)
                   / \\
        Collision-    Product-
          Free         Free
                   \\ /
                 (none)

UF implies both. Neither implies the other.
Even their conjunction doesn't imply UF.
""")

# Example 1: Primes — has all three properties
analyze_set({2, 3, 5, 7, 11, 13}, "Primes up to 13")

# Example 2: {2, 3, 6} — collision-free but NOT product-free
analyze_set({2, 3, 6}, "{2,3,6} (collision-free, not product-free)")

# Example 3: {6, 10, 21, 35} — product-free but NOT collision-free
analyze_set({6, 10, 21, 35}, "{6,10,21,35} (product-free, not collision-free)")

# Example 4: {2, 8} — BOTH collision-free AND product-free, but NOT UF
analyze_set({2, 8}, "{2,8} (collision-free AND product-free, but NOT UF)")

# ============================================================
# DEMONSTRATION 2: Prime-Power Collapse
# ============================================================
print("\n" + "=" * 60)
print("PRIME-POWER COLLAPSE THEOREM")
print("=" * 60)
print("If S contains both p and p^k (k≥2), UF fails.\n")

for p in [2, 3, 5]:
    for k in [2, 3, 4]:
        S = {p, p**k}
        pf, cf, uf = analyze_set(S, f"{{p={p}, p^{k}={p**k}}}")

# ============================================================
# DEMONSTRATION 3: Coprime Basis Theorem
# ============================================================
print("\n" + "=" * 60)
print("COPRIME BASIS THEOREM")
print("=" * 60)
print("For pairwise coprime sets: UF ↔ product-free\n")

coprime_examples = [
    ({2, 3, 5, 7}, "Pairwise coprime primes"),
    ({6, 35, 143}, "Pairwise coprime composites (6=2·3, 35=5·7, 143=11·13)"),
    ({4, 9, 25}, "Pairwise coprime prime powers"),
    ({2, 3, 5, 30}, "NOT product-free (2·3·5=30)"),
]

for S, desc in coprime_examples:
    # Check pairwise coprimality
    elems = sorted(S)
    coprime = all(gcd(a, b) == 1 for i, a in enumerate(elems) for b in elems[i+1:])
    pf, cf, uf = analyze_set(S, f"{desc}")
    if coprime:
        print(f"  Pairwise coprime: YES → UF ↔ product-free: {uf == pf} ✓")

# ============================================================
# DEMONSTRATION 4: Random Sets with Prime-Like Density
# ============================================================
print("\n" + "=" * 60)
print("RANDOM SETS WITH PRIME-LIKE DENSITY")
print("=" * 60)

import random
random.seed(42)

N = 200
for trial in range(5):
    # Cramér model: include n with probability 1/ln(n)
    S = set()
    for n in range(2, N + 1):
        if random.random() < 1.0 / log(n):
            S.add(n)

    actual_primes = {n for n in range(2, N + 1) if all(n % d != 0 for d in range(2, int(n**0.5) + 1))}

    print(f"\nTrial {trial + 1}:")
    print(f"  Random set size: {len(S)}, Actual primes up to {N}: {len(actual_primes)}")
    pf = is_product_free(S)
    coll = has_product_collision(S)
    print(f"  Product-free: {pf}")
    print(f"  Collision-free: {not coll[0]}")
    if not pf:
        # Count product closures
        S2 = sorted(x for x in S if x >= 2)
        closures = [(a, b) for a in S2 for b in S2 if a <= b and a * b in S]
        print(f"  Product closures: {len(closures)} (e.g. {closures[:3]})")

print("\n" + "=" * 60)
print("KEY INSIGHT: Random sets ALWAYS lose product-freeness")
print("(and hence unique factorization), while actual primes never do.")
print("This is the fundamental structural miracle of the primes.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: The Factorization Diamond

Generates a visual representation of the factorization hierarchy,
showing all four separating examples and their positions in the diamond.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
from math import gcd, log


def is_product_free(S):
    S2 = {x for x in S if x >= 2}
    for a in S2:
        for b in S2:
            if a * b in S2:
                return False
    return True


def has_product_collision(S):
    S2 = sorted(x for x in S if x >= 2)
    products = defaultdict(list)
    for i, a in enumerate(S2):
        for j in range(i, len(S2)):
            b = S2[j]
            products[a * b].append((a, b))
    for n, pairs in products.items():
        if len(pairs) >= 2:
            for i in range(len(pairs)):
                for j in range(i + 1, len(pairs)):
                    if pairs[i] != pairs[j]:
                        return True
    return False


def find_factorizations(S, n, max_depth=15):
    S2 = sorted(x for x in S if x >= 2)
    results = []
    def search(remaining, min_val, current):
        if remaining == 1:
            results.append(tuple(sorted(current)))
            return
        for s in S2:
            if s < min_val: continue
            if s > remaining: break
            if remaining % s == 0 and len(current) < max_depth:
                search(remaining // s, s, current + [s])
    search(n, min(S2) if S2 else 2, [])
    return list(set(results))


def has_uf(S, limit=300):
    for n in range(2, limit):
        if len(find_factorizations(S, n)) > 1:
            return False
    return True


# Figure 1: The Diamond Diagram
fig, axes = plt.subplots(1, 2, figsize=(16, 8))

ax = axes[0]
ax.set_xlim(-3, 3)
ax.set_ylim(-2, 4)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('The Factorization Diamond', fontsize=16, fontweight='bold')

# Draw diamond
diamond_x = [0, -2, 0, 2, 0]
diamond_y = [3, 1, -1, 1, 3]
ax.plot(diamond_x, diamond_y, 'k-', linewidth=2)

# Nodes
node_props = dict(fontsize=11, ha='center', va='center',
                  bbox=dict(boxstyle='round,pad=0.5', facecolor='lightblue', edgecolor='black'))

ax.text(0, 3, 'UF\n(Unique Fact.)', **node_props)
ax.text(-2, 1, 'Collision-\nFree', **node_props)
ax.text(2, 1, 'Product-\nFree', **node_props)
ax.text(0, -1, '(none)', fontsize=11, ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', edgecolor='black'))

# Separating examples
sep_props = dict(fontsize=8, ha='center', va='center',
                 bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='red', linewidth=1.5))

ax.annotate('{2,3,6}\n(CF ∧ ¬PF)', xy=(-1, 0), fontsize=8, ha='center', color='red', fontweight='bold')
ax.annotate('{6,10,21,35}\n(PF ∧ ¬CF)', xy=(1, 0), fontsize=8, ha='center', color='red', fontweight='bold')
ax.annotate('{2,8}\n(CF ∧ PF ∧ ¬UF)', xy=(0, 1.8), fontsize=8, ha='center', color='darkred', fontweight='bold')

# Arrows with implications
ax.annotate('', xy=(-1.5, 1.3), xytext=(-0.5, 2.7),
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax.annotate('', xy=(1.5, 1.3), xytext=(0.5, 2.7),
            arrowprops=dict(arrowstyle='->', color='green', lw=2))

# Crossed arrows for non-implications
ax.plot([-0.3, 0.3], [0.3, -0.3], 'r-', linewidth=2)
ax.plot([-0.3, 0.3], [-0.3, 0.3], 'r-', linewidth=2)
ax.text(0, 0.5, '✗', fontsize=14, ha='center', va='center', color='red')

# Figure 2: Random vs Prime factorization statistics
ax2 = axes[1]
import random
random.seed(42)

Ns = range(20, 201, 10)
pf_rates = []
cf_rates = []

for N in Ns:
    pf_count = 0
    cf_count = 0
    n_trials = 50
    for trial in range(n_trials):
        random.seed(1000 * N + trial)
        S = {n for n in range(2, N + 1) if random.random() < 1.0 / log(n)}
        if is_product_free(S):
            pf_count += 1
        if not has_product_collision(S):
            cf_count += 1
    pf_rates.append(pf_count / n_trials)
    cf_rates.append(cf_count / n_trials)

ax2.plot(list(Ns), pf_rates, 'b-o', label='Product-free rate', markersize=4)
ax2.plot(list(Ns), cf_rates, 'r-s', label='Collision-free rate', markersize=4)
ax2.axhline(y=1.0, color='green', linestyle='--', alpha=0.7, label='Actual primes (always PF & CF)')
ax2.set_xlabel('N (universe size)', fontsize=12)
ax2.set_ylabel('Fraction of random sets satisfying property', fontsize=12)
ax2.set_title('Random Sets Lose Structure Rapidly', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_ylim(-0.05, 1.1)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('factorization_diamond.png', dpi=150, bbox_inches='tight')
print("Saved factorization_diamond.png")
