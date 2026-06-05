#!/usr/bin/env python3
"""
Counterfactual Number Theory: What If Primes Were Random?

Demonstrates key results from the formalized theory, including:
1. The {2,8} counterexample to the level-uniform conjecture
2. The {6,10,21,35} separation between mult-independence and UF
3. Collision density in random "pseudo-prime" sets
4. Dirichlet survival for dense subsets
"""
import random
import math
from collections import defaultdict


def is_product_free(S):
    """Check if S is product-free: no product of two elements lies in S."""
    S_set = set(S)
    for a in S:
        for b in S:
            if a >= 2 and b >= 2 and a * b in S_set:
                return False
    return True


def is_mult_independent(S):
    """Check if S is multiplicatively independent: no element is a product of others."""
    S_set = set(S)
    for s in S:
        # Check if s can be written as product of ≥2 elements from S
        # Simple check: is s a product of two elements?
        for a in S:
            for b in S:
                if a >= 2 and b >= 2 and a * b == s:
                    return False
    return True


def find_collisions(S, max_n=10000):
    """Find product collisions: distinct pairs with the same product."""
    products = defaultdict(list)
    S_list = sorted([x for x in S if x >= 2])
    for i, a in enumerate(S_list):
        for b in S_list[i:]:
            products[a * b].append((a, b))
    collisions = {n: pairs for n, pairs in products.items() if len(pairs) > 1 and n <= max_n}
    return collisions


def factorizations(n, S, min_factor=2):
    """Find all S-factorizations of n."""
    S_sorted = sorted([x for x in S if x >= min_factor and x <= n])
    if n == 1:
        return [()]
    results = []
    for s in S_sorted:
        if s > n:
            break
        if n % s == 0:
            for rest in factorizations(n // s, S, min_factor=s):
                results.append((s,) + rest)
    return results


def has_unique_factorization(S, test_range=1000):
    """Check if S has unique factorization up to test_range."""
    for n in range(2, test_range):
        facts = factorizations(n, S)
        if len(facts) > 1:
            return False, n, facts[:2]
    return True, None, None


def cramer_random_set(N, seed=42):
    """Generate a Cramér random model: each n ≥ 2 is included with probability 1/ln(n)."""
    random.seed(seed)
    S = set()
    for n in range(2, N + 1):
        if random.random() < 1.0 / math.log(n):
            S.add(n)
    return sorted(S)


# ============================================================
# DEMO 1: The {2, 8} Counterexample
# ============================================================
print("=" * 60)
print("DEMO 1: The {2, 8} Counterexample")
print("=" * 60)
print()
S1 = {2, 8}
print(f"Set S = {S1}")
print(f"Factorizations of 8 using S:")
for f in factorizations(8, S1):
    print(f"  8 = {'×'.join(map(str, f))}")
print(f"\nSame-level collisions exist? ", end="")
# Check: at each level k, is there a number with two distinct length-k factorizations?
has_same_level = False
for n in range(2, 100):
    facts = factorizations(n, S1)
    by_length = defaultdict(list)
    for f in facts:
        by_length[len(f)].append(f)
    for k, fs in by_length.items():
        if len(fs) > 1:
            has_same_level = True
print(has_same_level)
ufd, witness, _ = has_unique_factorization(S1, 200)
print(f"Has unique factorization? {ufd}")
if not ufd:
    facts = factorizations(witness, S1)
    print(f"  Witness: {witness} has {len(facts)} factorizations")
    for f in facts:
        print(f"    {witness} = {'×'.join(map(str, f))}")

# ============================================================
# DEMO 2: The {6, 10, 21, 35} Separation
# ============================================================
print()
print("=" * 60)
print("DEMO 2: The {6, 10, 21, 35} Separation")
print("=" * 60)
print()
S2 = {6, 10, 21, 35}
print(f"Set S = {S2}")
print(f"Product-free? {is_product_free(S2)}")
print(f"Multiplicatively independent? {is_mult_independent(S2)}")
ufd, witness, pair = has_unique_factorization(S2, 1000)
print(f"Has unique factorization? {ufd}")
if not ufd:
    print(f"  Witness: {witness}")
    facts = factorizations(witness, S2)
    for f in facts[:3]:
        print(f"    {witness} = {'×'.join(map(str, f))}")

collisions = find_collisions(S2)
print(f"\nProduct collisions:")
for n, pairs in sorted(collisions.items())[:5]:
    print(f"  {n} = " + " = ".join(f"{a}×{b}" for a, b in pairs))

# ============================================================
# DEMO 3: Cramér Random Model
# ============================================================
print()
print("=" * 60)
print("DEMO 3: Cramér Random Model Analysis")
print("=" * 60)
print()
for N in [100, 500, 1000]:
    S = cramer_random_set(N)
    actual_primes = [p for p in range(2, N + 1) if all(p % d != 0 for d in range(2, int(p**0.5) + 1))]
    pf = is_product_free(set(S))
    mi = is_mult_independent(set(S))
    ufd_result, _, _ = has_unique_factorization(set(S), min(N, 500))
    collisions = find_collisions(set(S), N)

    print(f"N = {N}:")
    print(f"  |S| = {len(S)}, expected ≈ {N / math.log(N):.1f}, actual π({N}) = {len(actual_primes)}")
    print(f"  Product-free? {pf}")
    print(f"  Mult-independent? {mi}")
    print(f"  Has UF? {ufd_result}")
    print(f"  Number of product collisions: {len(collisions)}")
    if collisions:
        first_collision = min(collisions.items())
        print(f"  First collision: {first_collision[0]} = " +
              " = ".join(f"{a}×{b}" for a, b in first_collision[1]))
    print()

# ============================================================
# DEMO 4: Dirichlet Survival
# ============================================================
print("=" * 60)
print("DEMO 4: Dirichlet Survival")
print("=" * 60)
print()
q, m = 7, 10
N_dir = q * m
S_dir = cramer_random_set(N_dir, seed=123)
S_dir = [x for x in S_dir if x < N_dir]
print(f"Universe [0, {N_dir}), modulus q = {q}, m = {m}")
print(f"|S| = {len(S_dir)}, threshold (q-1)*m = {(q-1)*m}")
residues_hit = set(x % q for x in S_dir)
print(f"Residue classes hit: {sorted(residues_hit)}")
print(f"All classes covered? {len(residues_hit) == q}")

# ============================================================
# DEMO 5: The Four-Level Hierarchy
# ============================================================
print()
print("=" * 60)
print("DEMO 5: The Four-Level Hierarchy")
print("=" * 60)
print()
examples = [
    ("Actual primes (2..30)", {2, 3, 5, 7, 11, 13, 17, 19, 23, 29}),
    ("{4, 9, 25} (prime squares)", {4, 9, 25}),
    ("{6, 10, 21, 35} (separation)", {6, 10, 21, 35}),
    ("{4, 6, 9} (product-free, no UF)", {4, 6, 9}),
    ("{2, 4, 8} (not product-free)", {2, 4, 8}),
]

print(f"{'Set':<35} {'ProdFree':>8} {'MultInd':>8} {'UF':>8} {'Coprime':>8}")
print("-" * 70)
for name, S in examples:
    pf = is_product_free(S)
    mi = is_mult_independent(S)
    ufd_result, _, _ = has_unique_factorization(S, 5000)
    # Check pairwise coprime
    S_list = sorted(S)
    coprime = all(
        math.gcd(S_list[i], S_list[j]) == 1
        for i in range(len(S_list))
        for j in range(i + 1, len(S_list))
    )
    print(f"{name:<35} {str(pf):>8} {str(mi):>8} {str(ufd_result):>8} {str(coprime):>8}")

print()
print("Hierarchy: Coprime ⟹ UF ⟹ MultInd ⟹ ProductFree")
print("All implications strict (proven in Lean 4).")


#!/usr/bin/env python3
"""
Visualization: The Four-Level Factorization Hierarchy

Generates a visual comparison of sets at different levels of the hierarchy:
  Pairwise coprime ⟹ UF ⟹ Mult-independent ⟹ Product-free
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math
import random
from collections import defaultdict


def is_product_free(S):
    S_set = set(S)
    for a in S:
        for b in S:
            if a >= 2 and b >= 2 and a * b in S_set:
                return False
    return True


def find_absorptions(S):
    elems = sorted(x for x in S if x >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            if a * b in S:
                return True
    return False


def factorize(n, S, min_f=2):
    gens = sorted(x for x in S if x >= min_f and x <= n)
    if n == 1:
        return [()]
    results = []
    for g in gens:
        if g > n:
            break
        if n % g == 0:
            for rest in factorize(n // g, S, min_f=g):
                results.append((g,) + rest)
    return results


def classify(S, max_n=2000):
    pf = is_product_free(S)
    mi = not find_absorptions(S)
    ufd = all(len(factorize(n, S)) <= 1 for n in range(2, max_n))
    elems = sorted(S)
    coprime = all(
        math.gcd(elems[i], elems[j]) == 1
        for i in range(len(elems)) for j in range(i+1, len(elems))
    )
    return coprime, ufd, mi, pf


# Sets to analyze
sets = {
    'Primes {2..29}': {2, 3, 5, 7, 11, 13, 17, 19, 23, 29},
    '{4, 9, 25, 49}': {4, 9, 25, 49},
    '{6, 10, 21, 35}': {6, 10, 21, 35},
    '{4, 6, 9}': {4, 6, 9},
    '{2, 4, 8}': {2, 4, 8},
    '{2, 8}': {2, 8},
}

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Hierarchy classification
ax1 = axes[0]
levels = ['Pairwise\nCoprime', 'Unique\nFactorization', 'Mult\nIndependent', 'Product\nFree']
colors_map = {True: '#2ecc71', False: '#e74c3c'}
y_positions = list(range(len(sets)))
bar_width = 0.18

for j, level_name in enumerate(levels):
    for i, (name, S) in enumerate(sets.items()):
        cop, ufd, mi, pf = classify(S)
        vals = [cop, ufd, mi, pf]
        color = colors_map[vals[j]]
        ax1.barh(i + j * bar_width - 0.27, 1, bar_width * 0.9,
                left=j, color=color, edgecolor='white', linewidth=0.5)

ax1.set_yticks(range(len(sets)))
ax1.set_yticklabels(list(sets.keys()), fontsize=10)
ax1.set_xticks([0.5, 1.5, 2.5, 3.5])
ax1.set_xticklabels(levels, fontsize=9)
ax1.set_title('Factorization Hierarchy Classification', fontsize=14, fontweight='bold')
green_patch = mpatches.Patch(color='#2ecc71', label='Satisfied')
red_patch = mpatches.Patch(color='#e74c3c', label='Violated')
ax1.legend(handles=[green_patch, red_patch], loc='lower right', fontsize=10)
ax1.invert_yaxis()

# Panel 2: Collision density in Cramér models
ax2 = axes[1]
Ns = list(range(20, 201, 10))
collision_counts = []
absorption_counts = []
random.seed(42)

for N in Ns:
    S = set()
    for k in range(2, N + 1):
        if random.random() < 1.0 / math.log(k):
            S.add(k)
    # Count collisions
    products = defaultdict(list)
    elems = sorted(x for x in S if x >= 2)
    for i, a in enumerate(elems):
        for b in elems[i:]:
            products[a * b].append((a, b))
    n_collisions = sum(1 for pairs in products.values() if len(pairs) >= 2)
    collision_counts.append(n_collisions)
    # Count absorptions
    n_abs = sum(1 for a in elems for b in elems if a * b in S)
    absorption_counts.append(n_abs)

ax2.plot(Ns, collision_counts, 'o-', color='#e74c3c', label='Product collisions', linewidth=2)
ax2.plot(Ns, absorption_counts, 's-', color='#3498db', label='Absorptions', linewidth=2)
ax2.set_xlabel('Universe size N', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Structural Defects in Cramér Models', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('hierarchy_visualization.png', dpi=150, bbox_inches='tight')
print("Saved hierarchy_visualization.png")
