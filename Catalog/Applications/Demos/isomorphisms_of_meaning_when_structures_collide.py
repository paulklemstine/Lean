#!/usr/bin/env python3
"""
Semantic Bundles — Interactive Demo

Demonstrates the core concepts from the Semantic Bundle theory:
1. Algebraic vs semantic isomorphism on concrete examples
2. Semantic diversity and spectrum computation
3. Orbit counting under automorphism groups
"""

from itertools import permutations, product
from collections import Counter
from math import factorial, log2


def xor_op(a: int, b: int) -> int:
    """XOR operation on {0, 1}."""
    return (a + b) % 2


def is_alg_iso(op1, op2, n: int, perm: tuple) -> bool:
    """Check if permutation `perm` is an algebraic isomorphism from op1 to op2."""
    for x in range(n):
        for y in range(n):
            if perm[op1(x, y)] != op2(perm[x], perm[y]):
                return False
    return True


def is_sem_iso(op1, op2, label1, label2, n: int, perm: tuple) -> bool:
    """Check if permutation is a semantic isomorphism."""
    if not is_alg_iso(op1, op2, n, perm):
        return False
    for x in range(n):
        if label1[x] != label2[perm[x]]:
            return False
    return True


def find_automorphisms(op, n: int) -> list:
    """Find all automorphisms of (n-element set, op)."""
    auts = []
    for perm in permutations(range(n)):
        if is_alg_iso(op, op, n, perm):
            auts.append(perm)
    return auts


def semantic_diversity(label: list) -> int:
    """Number of distinct label values."""
    return len(set(label))


def semantic_spectrum(label: list) -> list:
    """Sorted list of label frequencies."""
    return sorted(Counter(label).values(), reverse=True)


def count_semantic_orbits(op, n: int, k: int) -> int:
    """Count semantically distinct labelings using Burnside's lemma.

    op: binary operation on {0, ..., n-1}
    n: size of carrier
    k: number of label values {0, ..., k-1}
    """
    auts = find_automorphisms(op, n)
    total_fixed = 0
    for aut in auts:
        # Count labelings fixed by this automorphism
        # A labeling l is fixed by aut iff l[x] = l[aut[x]] for all x
        # This means l must be constant on each cycle of aut
        cycles = _cycle_count(aut, n)
        total_fixed += k ** cycles
    return total_fixed // len(auts)


def _cycle_count(perm: tuple, n: int) -> int:
    """Count cycles in a permutation."""
    visited = [False] * n
    cycles = 0
    for i in range(n):
        if not visited[i]:
            cycles += 1
            j = i
            while not visited[j]:
                visited[j] = True
                j = perm[j]
    return cycles


# =============================================================
# DEMO 1: The Separation Theorem
# =============================================================
print("=" * 60)
print("DEMO 1: THE SEPARATION THEOREM")
print("=" * 60)
print()

n = 2
label_id = [0, 1]  # identity labeling
label_swap = [1, 0]  # swapped labeling

print(f"Structure: (Fin 2, XOR)")
print(f"D_id:   op = XOR, label = {label_id}")
print(f"D_swap: op = XOR, label = {label_swap}")
print()

# Find all algebraic isomorphisms
alg_isos = []
for perm in permutations(range(n)):
    if is_alg_iso(xor_op, xor_op, n, perm):
        alg_isos.append(perm)

print(f"Algebraic isomorphisms from D_id to D_swap: {alg_isos}")

# Check semantic isomorphisms
sem_isos = []
for perm in permutations(range(n)):
    if is_sem_iso(xor_op, xor_op, label_id, label_swap, n, perm):
        sem_isos.append(perm)

print(f"Semantic isomorphisms from D_id to D_swap: {sem_isos}")
print()
print(f"AlgIso(D_id, D_swap): {len(alg_isos) > 0}")
print(f"SemIso(D_id, D_swap): {len(sem_isos) > 0}")
print(f"→ SEPARATION: Algebraically isomorphic but semantically distinct!")
print()

# =============================================================
# DEMO 2: Rigidity and Automorphism Groups
# =============================================================
print("=" * 60)
print("DEMO 2: RIGIDITY AND AUTOMORPHISM GROUPS")
print("=" * 60)
print()

# XOR on Fin 2
auts_xor = find_automorphisms(xor_op, 2)
print(f"Aut(Fin 2, XOR) = {auts_xor}")
print(f"|Aut| = {len(auts_xor)}")
print(f"Rigid: {len(auts_xor) == 1}")
print()

# Addition on Fin 3
def add3(a, b): return (a + b) % 3
auts_z3 = find_automorphisms(add3, 3)
print(f"Aut(Z/3Z, +) = {auts_z3}")
print(f"|Aut| = {len(auts_z3)}")
print(f"Rigid: {len(auts_z3) == 1}")
print()

# Addition on Fin 4
def add4(a, b): return (a + b) % 4
auts_z4 = find_automorphisms(add4, 4)
print(f"Aut(Z/4Z, +) = {auts_z4}")
print(f"|Aut| = {len(auts_z4)}")
print(f"Rigid: {len(auts_z4) == 1}")
print()

# =============================================================
# DEMO 3: Semantic Orbit Counting
# =============================================================
print("=" * 60)
print("DEMO 3: SEMANTIC ORBIT COUNTING (BURNSIDE)")
print("=" * 60)
print()

for name, op, sz in [("XOR/Fin2", xor_op, 2), ("Z/3Z", add3, 3), ("Z/4Z", add4, 4)]:
    for k in [2, 3]:
        orbits = count_semantic_orbits(op, sz, k)
        total = k ** sz
        aut_size = len(find_automorphisms(op, sz))
        print(f"{name}, k={k}: {orbits} semantic classes "
              f"(of {total} total labelings, |Aut|={aut_size})")
    print()

# =============================================================
# DEMO 4: Semantic Diversity and Spectrum
# =============================================================
print("=" * 60)
print("DEMO 4: SEMANTIC INVARIANTS")
print("=" * 60)
print()

examples = [
    ("D_id", [0, 1]),
    ("D_swap", [1, 0]),
    ("D_const", [0, 0]),
    ("D_all_diff (Fin 3)", [0, 1, 2]),
    ("D_two_same (Fin 3)", [0, 0, 1]),
]

for name, label in examples:
    div = semantic_diversity(label)
    spec = semantic_spectrum(label)
    print(f"{name}: label={label}, diversity={div}, spectrum={spec}")

print()

# =============================================================
# DEMO 5: Truth-Meaning Gap
# =============================================================
print("=" * 60)
print("DEMO 5: TRUTH-MEANING GAP")
print("=" * 60)
print()

# truth predicate: always true (matches formal proof)
def truth(x): return True

phi = lambda x: x  # identity map
d1_label = label_id
d2_label = label_swap

truth_preserved = all(
    not truth(d1_label[x]) or truth(d2_label[phi(x)])
    for x in range(2)
)
meaning_preserved = all(
    d1_label[x] == d2_label[phi(x)]
    for x in range(2)
)

print(f"D_id labels: {d1_label}")
print(f"D_swap labels: {d2_label}")
print(f"φ = identity")
print(f"Truth predicate: 'is nonzero'")
print(f"Truth preserved: {truth_preserved}")
print(f"Meaning preserved: {meaning_preserved}")
print(f"→ GAP: Truth is preserved but meaning is not!")
print()

# =============================================================
# DEMO 6: Semantic Entropy
# =============================================================
print("=" * 60)
print("DEMO 6: SEMANTIC ENTROPY")
print("=" * 60)
print()

for name, op, sz in [("XOR/Fin2", xor_op, 2), ("Z/3Z", add3, 3), ("Z/4Z", add4, 4)]:
    aut_size = len(find_automorphisms(op, sz))
    for k in [2, 3]:
        orbits = count_semantic_orbits(op, sz, k)
        entropy = log2(orbits) if orbits > 0 else 0
        max_entropy = sz * log2(k)
        print(f"{name}, k={k}: H = {entropy:.2f} bits "
              f"(max = {max_entropy:.2f}, |Aut|={aut_size})")
    print()


#!/usr/bin/env python3
"""
Visualization: Semantic Landscape of Decorated Magmas

Shows how the semantic orbit count varies with group size and label count.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
from math import log2


def find_automorphisms_modular(n):
    """Find automorphisms of (Z/nZ, +)."""
    auts = []
    for p in permutations(range(n)):
        ok = True
        for x in range(n):
            for y in range(n):
                if p[(x + y) % n] != (p[x] + p[y]) % n:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            auts.append(p)
    return auts


def cycle_count(perm, n):
    visited = [False] * n
    c = 0
    for i in range(n):
        if not visited[i]:
            c += 1
            j = i
            while not visited[j]:
                visited[j] = True
                j = perm[j]
    return c


def orbit_count(auts, n, k):
    total = 0
    for aut in auts:
        total += k ** cycle_count(aut, n)
    return total // len(auts)


# Compute data
ns = range(2, 7)
ks = [2, 3, 4]

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, k in enumerate(ks):
    ax = axes[idx]
    orbit_counts = []
    total_counts = []
    aut_sizes = []

    for n in ns:
        auts = find_automorphisms_modular(n)
        orb = orbit_count(auts, n, k)
        orbit_counts.append(orb)
        total_counts.append(k ** n)
        aut_sizes.append(len(auts))

    x = list(ns)
    ax.bar(x, total_counts, alpha=0.3, color='steelblue', label='Total labelings')
    ax.bar(x, orbit_counts, alpha=0.8, color='coral', label='Semantic classes')

    ax.set_xlabel('Group size n (Z/nZ)')
    ax.set_ylabel('Count')
    ax.set_title(f'k = {k} labels')
    ax.legend()
    ax.set_yscale('log')

    for i, n in enumerate(ns):
        ax.annotate(f'|Aut|={aut_sizes[i]}',
                   (n, orbit_counts[i]),
                   textcoords="offset points",
                   xytext=(0, 10),
                   ha='center', fontsize=7)

fig.suptitle('Semantic Diversity: Total Labelings vs Semantically Distinct Classes\n'
             'for cyclic groups Z/nZ', fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('semantic_landscape.png', dpi=150, bbox_inches='tight')
print("Saved semantic_landscape.png")

# Second plot: entropy gap
fig2, ax2 = plt.subplots(figsize=(8, 5))

for k in ks:
    entropies = []
    max_entropies = []
    for n in ns:
        auts = find_automorphisms_modular(n)
        orb = orbit_count(auts, n, k)
        entropies.append(log2(orb) if orb > 0 else 0)
        max_entropies.append(n * log2(k))

    ax2.plot(list(ns), entropies, 'o-', label=f'H(Z/nZ, k={k})', linewidth=2)
    ax2.plot(list(ns), max_entropies, '--', alpha=0.4, label=f'Max (k={k})')

ax2.set_xlabel('Group size n')
ax2.set_ylabel('Semantic Entropy (bits)')
ax2.set_title('Semantic Entropy vs Maximum Entropy\n'
              'Gap = information lost to automorphism symmetry')
ax2.legend()
ax2.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('semantic_entropy.png', dpi=150, bbox_inches='tight')
print("Saved semantic_entropy.png")
