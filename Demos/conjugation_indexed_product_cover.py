#!/usr/bin/env python3
"""
Applications of Conjugation-Indexed Product Covering

Demonstrates real-world applications:
1. Cryptographic key-exchange group analysis
2. Error-correcting code coset structure
3. Random walk mixing on quotient spaces
"""

from itertools import permutations
from collections import defaultdict
import random

random.seed(42)


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def generate_subgroup(gens, n):
    e = identity(n)
    sg = {e}
    q = list(gens)
    while q:
        g = q.pop()
        if g not in sg:
            sg.add(g)
            for h in list(sg):
                for x in [compose(g, h), compose(h, g), inverse(g)]:
                    if x not in sg:
                        q.append(x)
    return frozenset(sg)

def left_coset(g, H):
    n = len(g)
    return frozenset(compose(g, h) for h in H)

def conjugation_index(H, g, n):
    g_inv = inverse(g)
    conj_H = frozenset(compose(compose(g_inv, h), g) for h in H)
    inter = H & conj_H
    return len(H) // len(inter) if inter else float('inf')


# ============================================================
# Application 1: Cryptographic Group Analysis
# ============================================================
def crypto_application():
    """
    In group-based cryptography (e.g., braid group protocols), the security
    relies on the difficulty of the conjugacy search problem. The conjugation
    index measures how 'tangled' conjugation makes the subgroup structure.

    Higher conjugation index → more cosets in double cosets → harder to
    decompose group elements → potentially stronger security.
    """
    print("=" * 60)
    print("APPLICATION 1: Cryptographic Group Structure Analysis")
    print("=" * 60)

    for n in [4, 5]:
        G = list(permutations(range(n)))
        print(f"\nAnalyzing S_{n} (|G| = {len(G)}):")

        # Try various subgroups
        if n == 4:
            subgroups = {
                "A_4 (normal)": generate_subgroup([(1, 2, 0, 3), (0, 2, 3, 1)], n),
                "<(01)>": generate_subgroup([(1, 0, 2, 3)], n),
                "<(0123)>": generate_subgroup([(1, 2, 3, 0)], n),
                "D_4": generate_subgroup([(1, 2, 3, 0), (1, 0, 3, 2)], n),
            }
        else:
            subgroups = {
                "A_5 (normal)": generate_subgroup([(1, 2, 0, 3, 4), (0, 2, 3, 4, 1)], n),
                "<(01)>": generate_subgroup([(1, 0, 2, 3, 4)], n),
                "<(01234)>": generate_subgroup([(1, 2, 3, 4, 0)], n),
            }

        for name, H in subgroups.items():
            max_ci = max(conjugation_index(H, g, n) for g in G)
            avg_ci = sum(conjugation_index(H, g, n) for g in G) / len(G)
            print(f"  {name}: |H|={len(H)}, max_conj_idx={max_ci}, "
                  f"avg_conj_idx={avg_ci:.2f}")
            if max_ci == 1:
                print(f"    → Normal subgroup (weak for conjugacy-based crypto)")
            else:
                print(f"    → Non-normal (conjugation index {max_ci}: "
                      f"good for crypto complexity)")


# ============================================================
# Application 2: Error-Correcting Code Coset Analysis
# ============================================================
def coding_application():
    """
    In algebraic coding theory, codewords form cosets of a subgroup.
    The product covering theorem bounds how errors compound:
    if single errors land in C cosets, double errors land in ≤ C²·L cosets.

    This gives a bound on the 'error amplification factor' for group codes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Error Amplification in Group Codes")
    print("=" * 60)

    n = 4
    G = list(permutations(range(n)))
    e = identity(n)

    # Subgroup = codeword space
    H = generate_subgroup([(1, 0, 3, 2), (2, 3, 0, 1)], n)  # V_4
    print(f"\nCode: V_4 ⊂ S_4, |code| = {len(H)}, |G| = {len(G)}")
    print(f"Number of cosets (codewords): {len(G) // len(H)}")

    # Single error: elements in a random coset
    error_set = frozenset(random.sample(G, 6))
    print(f"\nError set: {len(error_set)} elements")

    # Compute covering
    cosets_seen = set()
    for g in error_set:
        cosets_seen.add(left_coset(g, H))
    C_single = len(cosets_seen)

    # Double error: product set
    double_error = frozenset(compose(a, b) for a in error_set for b in error_set)
    double_cosets = set()
    for g in double_error:
        double_cosets.add(left_coset(g, H))
    C_double = len(double_cosets)

    L = max(conjugation_index(H, g, n) for g in error_set)

    print(f"Single-error cosets: C = {C_single}")
    print(f"Double-error cosets: C(A·A) = {C_double}")
    print(f"Max conjugation index: L = {L}")
    print(f"Bound C²·L = {C_single**2 * L}")
    print(f"Bound holds: {C_double <= C_single**2 * L}")
    print(f"Error amplification ratio: {C_double / C_single:.2f}x")


# ============================================================
# Application 3: Random Walk on Quotient Spaces
# ============================================================
def random_walk_application():
    """
    The covering bound implies constraints on random walk mixing:
    if a random walk visits C cosets in k steps, it visits ≤ C²·L
    cosets in 2k steps. This connects to expansion properties.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Random Walk Mixing on Coset Spaces")
    print("=" * 60)

    n = 4
    G = list(permutations(range(n)))
    e = identity(n)

    # Subgroup
    H = generate_subgroup([(1, 0, 2, 3)], n)  # <(01)>
    print(f"\nG = S_4, H = <(01)>, |H| = {len(H)}")
    num_cosets = len(G) // len(H)
    print(f"Number of cosets: {num_cosets}")

    # Random walk from identity
    generators = [(1, 0, 2, 3), (0, 2, 1, 3), (0, 1, 3, 2)]  # transpositions
    num_walks = 1000
    steps_list = [1, 2, 4, 8]

    print(f"\nRandom walk with {len(generators)} generators, {num_walks} trials:")
    print(f"{'Steps':>6} | {'Avg cosets visited':>20} | {'Max cosets':>12}")
    print("-" * 45)

    for steps in steps_list:
        coset_counts = []
        for _ in range(num_walks):
            pos = e
            visited_cosets = set()
            for _ in range(steps):
                gen = random.choice(generators + [inverse(g) for g in generators])
                pos = compose(pos, gen)
                visited_cosets.add(left_coset(pos, H))
            coset_counts.append(len(visited_cosets))

        avg = sum(coset_counts) / len(coset_counts)
        mx = max(coset_counts)
        print(f"{steps:>6} | {avg:>20.2f} | {mx:>12}")


if __name__ == "__main__":
    crypto_application()
    coding_application()
    random_walk_application()


#!/usr/bin/env python3
"""
Conjugation-Indexed Product Covering — Demonstration

Demonstrates the key concepts:
1. Conjugation index computation for symmetric groups
2. Product covering bounds verification
3. Comparison of normal vs non-normal subgroup cases
"""

from itertools import permutations, product as cartesian_product
from collections import defaultdict
from math import factorial


def symmetric_group(n):
    """Generate S_n as a list of permutations (tuples)."""
    return list(permutations(range(n)))


def compose(p, q):
    """Compose two permutations: (p∘q)(i) = p[q[i]]."""
    return tuple(p[q[i]] for i in range(len(p)))


def inverse(p):
    """Inverse of a permutation."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def identity(n):
    """Identity permutation of S_n."""
    return tuple(range(n))


def conjugate(g, h):
    """Compute g * h * g^{-1}."""
    return compose(compose(g, h), inverse(g))


def left_coset(g, H, n):
    """Compute the left coset gH = {g*h : h ∈ H}."""
    return frozenset(compose(g, h) for h in H)


def double_coset(H, g, n):
    """Compute the double coset HgH = {h1*g*h2 : h1,h2 ∈ H}."""
    result = set()
    for h1 in H:
        for h2 in H:
            result.add(compose(compose(h1, g), h2))
    return frozenset(result)


def conjugation_intersection(H_set, g, n):
    """Compute H ∩ g^{-1}Hg."""
    g_inv = inverse(g)
    conj_H = {compose(compose(g_inv, h), g) for h in H_set}
    return H_set & conj_H


def conjugation_index(H_set, g, n):
    """Compute [H : H ∩ g^{-1}Hg] = |H| / |H ∩ g^{-1}Hg|."""
    intersection = conjugation_intersection(H_set, g, n)
    if len(intersection) == 0:
        return float('inf')
    return len(H_set) // len(intersection)


def covering_number(A_set, H_set, G_list, n):
    """Find minimum number of left cosets of H needed to cover A.
    Returns (C, T) where C is the covering number and T is the covering set."""
    if not A_set:
        return 0, set()

    # Compute all distinct left cosets
    cosets = {}
    for g in G_list:
        coset = left_coset(g, H_set, n)
        if coset not in cosets.values():
            cosets[g] = coset

    # Greedy covering
    uncovered = set(A_set)
    cover_set = []
    while uncovered:
        best_g = None
        best_covered = 0
        for g, coset in cosets.items():
            covered = len(uncovered & coset)
            if covered > best_covered:
                best_covered = covered
                best_g = g
        if best_g is None:
            break
        cover_set.append(best_g)
        uncovered -= cosets[best_g]

    return len(cover_set), cover_set


def product_set(A_set, n):
    """Compute A·A = {a*b : a,b ∈ A}."""
    return frozenset(compose(a, b) for a in A_set for b in A_set)


def generate_subgroup(generators, n):
    """Generate the subgroup from a set of generators."""
    e = identity(n)
    subgroup = {e}
    queue = list(generators)
    while queue:
        g = queue.pop()
        if g not in subgroup:
            subgroup.add(g)
            for h in list(subgroup):
                for new in [compose(g, h), compose(h, g), inverse(g)]:
                    if new not in subgroup:
                        queue.append(new)
    return frozenset(subgroup)


def run_demo():
    print("=" * 70)
    print("CONJUGATION-INDEXED PRODUCT COVERING — DEMONSTRATION")
    print("=" * 70)

    for n in [3, 4]:
        print(f"\n{'='*60}")
        print(f"Testing in S_{n} (|S_{n}| = {factorial(n)})")
        print(f"{'='*60}")

        G = symmetric_group(n)
        e = identity(n)

        # Find interesting subgroups
        # For S_3: Use the cyclic subgroup generated by (1,2,0)
        # For S_4: Use the Klein four-group and a non-normal subgroup

        if n == 3:
            # Normal subgroup: A_3 = {e, (012), (021)} (alternating group)
            gen_normal = [(1, 2, 0)]
            H_normal = generate_subgroup(gen_normal, n)
            print(f"\nNormal subgroup A_3: |H| = {len(H_normal)}")
            print(f"  H is normal (alternating group)")

            # Non-normal subgroup: {e, (1,0,2)} (transposition)
            H_nonnormal = generate_subgroup([(1, 0, 2)], n)
            print(f"\nNon-normal subgroup <(01)>: |H| = {len(H_nonnormal)}")

            subgroups = [("A_3 (normal)", H_normal, True),
                         ("<(01)> (non-normal)", H_nonnormal, False)]
        else:
            # Normal subgroup: V_4 = {e, (01)(23), (02)(13), (03)(12)}
            v4_gens = [(1, 0, 3, 2), (2, 3, 0, 1)]
            H_normal = generate_subgroup(v4_gens, n)
            print(f"\nNormal subgroup V_4: |H| = {len(H_normal)}")

            # Non-normal subgroup: <(01)> = {e, (01)}
            H_nonnormal = generate_subgroup([(1, 0, 2, 3)], n)
            print(f"\nNon-normal subgroup <(01)>: |H| = {len(H_nonnormal)}")

            subgroups = [("V_4 (normal)", H_normal, True),
                         ("<(01)> (non-normal)", H_nonnormal, False)]

        for name, H_set, is_normal in subgroups:
            print(f"\n--- Subgroup: {name} ---")
            H_list = list(H_set)

            # Compute conjugation indices for all group elements
            conj_indices = {}
            for g in G:
                ci = conjugation_index(H_set, g, n)
                conj_indices[g] = ci

            max_ci = max(conj_indices.values())
            print(f"  Max conjugation index L = {max_ci}")
            if is_normal:
                assert max_ci == 1, "Normal subgroup should have L=1!"
                print(f"  ✓ Confirmed: L = 1 for normal subgroup")

            # Test with various subsets A
            import random
            random.seed(42)

            num_tests = 20
            all_pass = True
            for trial in range(num_tests):
                # Random subset of size between 2 and |G|//2
                k = random.randint(2, max(2, len(G) // 2))
                A = frozenset(random.sample(G, k))

                # Compute covering number
                C_A, T_A = covering_number(A, H_set, G, n)
                if C_A == 0:
                    continue

                # Compute max conjugation index over covering set
                L = max(conjugation_index(H_set, t, n) for t in T_A)

                # Compute product set
                AA = product_set(A, n)

                # Compute covering number of A*A
                C_AA, _ = covering_number(AA, H_set, G, n)

                # Check bound
                bound = C_A ** 2 * L
                passes = C_AA <= bound

                if not passes:
                    all_pass = False
                    print(f"  ✗ COUNTEREXAMPLE: |A|={len(A)}, C(A)={C_A}, "
                          f"C(A·A)={C_AA}, bound={bound}, L={L}")

            if all_pass:
                print(f"  ✓ All {num_tests} random tests passed: C(A·A) ≤ C(A)² · L")

    # Summary of double coset decomposition
    print(f"\n{'='*60}")
    print("DOUBLE COSET DECOMPOSITION IN S_3")
    print(f"{'='*60}")

    n = 3
    G = symmetric_group(n)
    H_set = generate_subgroup([(1, 0, 2)], n)  # <(01)>
    print(f"H = <(01)> = {set(H_set)}")

    for g in G:
        dc = double_coset(H_set, g, n)
        ci = conjugation_index(H_set, g, n)
        num_cosets = len(dc) // len(H_set)
        print(f"  HgH for g={g}: |HgH|={len(dc)}, "
              f"[H:H∩g⁻¹Hg]={ci}, #cosets={num_cosets}")


if __name__ == "__main__":
    run_demo()


"""
Conjugation Index Heatmap for S_4

Visualizes the conjugation index [H : H ∩ g⁻¹Hg] as a heatmap over
all pairs (H, g) in the symmetric group S_4. Reveals the algebraic
structure: normal subgroups have uniformly 1 index, while non-normal
subgroups show rich variation reflecting the conjugation geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def generate_subgroup(gens, n):
    e = identity(n)
    sg = {e}
    q = list(gens)
    while q:
        g = q.pop()
        if g not in sg:
            sg.add(g)
            for h in list(sg):
                for x in [compose(g, h), compose(h, g), inverse(g)]:
                    if x not in sg:
                        q.append(x)
    return frozenset(sg)

def conjugation_index(H, g, n):
    g_inv = inverse(g)
    conj_H = frozenset(compose(compose(g_inv, h), g) for h in H)
    inter = H & conj_H
    return len(H) // len(inter) if inter else 0


n = 4
G = list(permutations(range(n)))

# Define subgroups of S_4
subgroup_defs = {
    r"$\langle(01)\rangle$": [(1, 0, 2, 3)],
    r"$\langle(0123)\rangle$": [(1, 2, 3, 0)],
    r"$V_4$ (normal)": [(1, 0, 3, 2), (2, 3, 0, 1)],
    r"$D_4$": [(1, 2, 3, 0), (1, 0, 3, 2)],
    r"$A_4$ (normal)": [(1, 2, 0, 3), (0, 2, 3, 1)],
    r"$S_3$": [(1, 2, 0, 3), (1, 0, 2, 3)],
}

subgroups = {}
for name, gens in subgroup_defs.items():
    subgroups[name] = generate_subgroup(gens, n)

# Compute conjugation index distribution for each subgroup
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle(r"Conjugation Index $[H : H \cap g^{-1}Hg]$ in $S_4$",
             fontsize=16, fontweight='bold')

for idx, (name, H) in enumerate(subgroups.items()):
    ax = axes[idx // 3][idx % 3]

    # Compute index for each g
    indices = [conjugation_index(H, g, n) for g in G]

    # Group by conjugacy class for visualization
    # Sort G elements by cycle type
    def cycle_type(p):
        seen = set()
        cycles = []
        for i in range(len(p)):
            if i not in seen:
                cycle = []
                j = i
                while j not in seen:
                    seen.add(j)
                    cycle.append(j)
                    j = p[j]
                cycles.append(len(cycle))
        return tuple(sorted(cycles, reverse=True))

    # Sort by cycle type
    sorted_pairs = sorted(zip(G, indices), key=lambda x: cycle_type(x[0]))
    sorted_indices = [p[1] for p in sorted_pairs]

    # Create bar chart of index values
    unique_vals = sorted(set(indices))
    counts = {v: indices.count(v) for v in unique_vals}

    colors = ['#2ecc71' if v == 1 else '#e74c3c' if v > 1 else '#3498db'
              for v in unique_vals]
    ax.bar([str(v) for v in unique_vals],
           [counts[v] for v in unique_vals],
           color=colors, edgecolor='black', linewidth=0.5)

    ax.set_title(f"{name}\n|H| = {len(H)}", fontsize=12)
    ax.set_xlabel("Conjugation Index", fontsize=10)
    ax.set_ylabel("# of group elements", fontsize=10)

    max_idx = max(indices)
    ax.annotate(f"max L = {max_idx}",
                xy=(0.95, 0.95), xycoords='axes fraction',
                ha='right', va='top',
                fontsize=11, fontweight='bold',
                color='#e74c3c' if max_idx > 1 else '#2ecc71',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                         edgecolor='gray', alpha=0.8))

plt.tight_layout()
plt.savefig("conjugation_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved conjugation_heatmap.png")


"""
Product Covering Bound Verification

Scatter plot comparing actual covering numbers C(A·A) vs the
theoretical bound C(A)² · L for random subsets of S_4 with
various subgroup choices. Points below the diagonal confirm
the conjecture; the gap reveals tightness.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
import random

random.seed(42)


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def generate_subgroup(gens, n):
    e = identity(n)
    sg = {e}
    q = list(gens)
    while q:
        g = q.pop()
        if g not in sg:
            sg.add(g)
            for h in list(sg):
                for x in [compose(g, h), compose(h, g), inverse(g)]:
                    if x not in sg:
                        q.append(x)
    return frozenset(sg)

def left_coset(g, H):
    n = len(g)
    return frozenset(compose(g, h) for h in H)

def conjugation_index(H, g, n):
    g_inv = inverse(g)
    conj_H = frozenset(compose(compose(g_inv, h), g) for h in H)
    inter = H & conj_H
    return len(H) // len(inter) if inter else 0

def greedy_covering(A, H, G, n):
    if not A:
        return 0, []
    coset_map = {}
    seen = set()
    for g in G:
        c = left_coset(g, H)
        if c not in seen:
            coset_map[g] = c
            seen.add(c)
    uncov = set(A)
    cover = []
    while uncov:
        best_g, best_n = None, 0
        for g, c in coset_map.items():
            ct = len(uncov & c)
            if ct > best_n:
                best_n = ct
                best_g = g
        if best_g is None or best_n == 0:
            break
        cover.append(best_g)
        uncov -= coset_map[best_g]
    return len(cover), cover


n = 4
G = list(permutations(range(n)))

subgroup_configs = [
    (r"$\langle(01)\rangle$ (non-normal)", [(1, 0, 2, 3)], '#e74c3c'),
    (r"$\langle(0123)\rangle$", [(1, 2, 3, 0)], '#3498db'),
    (r"$V_4$ (normal)", [(1, 0, 3, 2), (2, 3, 0, 1)], '#2ecc71'),
]

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

max_bound = 0

for name, gens, color in subgroup_configs:
    H = generate_subgroup(gens, n)

    actuals = []
    bounds = []

    for trial in range(100):
        k = random.randint(2, len(G) // 2)
        A = frozenset(random.sample(G, k))

        C_A, T_A = greedy_covering(A, H, G, n)
        if C_A == 0:
            continue

        L = max(conjugation_index(H, t, n) for t in T_A)
        AA = frozenset(compose(a, b) for a in A for b in A)
        C_AA, _ = greedy_covering(AA, H, G, n)

        bound = C_A ** 2 * L
        actuals.append(C_AA)
        bounds.append(bound)
        max_bound = max(max_bound, bound, C_AA)

    ax.scatter(bounds, actuals, alpha=0.5, s=40, color=color,
              edgecolors='black', linewidth=0.3, label=name, zorder=3)

# Diagonal line
diag_max = max_bound + 2
ax.plot([0, diag_max], [0, diag_max], 'k--', alpha=0.4, linewidth=1.5,
        label=r'$C(A\cdot A) = C^2 \cdot L$')

# Fill the "conjecture holds" region
ax.fill_between([0, diag_max], [0, diag_max], [0, 0], alpha=0.05,
                color='green', zorder=1)
ax.fill_between([0, diag_max], [diag_max, diag_max], [0, diag_max],
                alpha=0.05, color='red', zorder=1)

ax.set_xlabel(r"Bound $C(A)^2 \cdot L$", fontsize=14)
ax.set_ylabel(r"Actual $C(A \cdot A)$", fontsize=14)
ax.set_title(r"Product Covering: $C(A \cdot A)$ vs $C(A)^2 \cdot L$ in $S_4$",
             fontsize=16, fontweight='bold')
ax.legend(fontsize=11, loc='upper left')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Annotation
ax.annotate("Conjecture holds\n(below diagonal)",
            xy=(diag_max * 0.7, diag_max * 0.3),
            fontsize=12, color='#27ae60', ha='center',
            fontweight='bold')

plt.tight_layout()
plt.savefig("covering_bound.png", dpi=150, bbox_inches='tight')
print("Saved covering_bound.png")


"""
Double Coset Decomposition Visualization

Shows how the double coset HgH decomposes into left cosets of H
for different group elements g in S_4. The number of cosets equals
the conjugation index, connecting covering theory to Hecke algebras.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from matplotlib.patches import FancyBboxPatch
import matplotlib.colors as mcolors


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def generate_subgroup(gens, n):
    e = identity(n)
    sg = {e}
    q = list(gens)
    while q:
        g = q.pop()
        if g not in sg:
            sg.add(g)
            for h in list(sg):
                for x in [compose(g, h), compose(h, g), inverse(g)]:
                    if x not in sg:
                        q.append(x)
    return frozenset(sg)

def left_coset(g, H):
    return frozenset(compose(g, h) for h in H)

def double_coset(H, g):
    result = set()
    for h1 in H:
        for h2 in H:
            result.add(compose(compose(h1, g), h2))
    return frozenset(result)

def conjugation_index(H, g, n):
    g_inv = inverse(g)
    conj_H = frozenset(compose(compose(g_inv, h), g) for h in H)
    inter = H & conj_H
    return len(H) // len(inter) if inter else 0

def perm_to_str(p):
    """Convert permutation to cycle notation string."""
    n = len(p)
    seen = set()
    cycles = []
    for i in range(n):
        if i not in seen and p[i] != i:
            cycle = []
            j = i
            while j not in seen:
                seen.add(j)
                cycle.append(j)
                j = p[j]
            if len(cycle) > 1:
                cycles.append(cycle)
    if not cycles:
        return "e"
    return "".join(f"({''.join(str(x) for x in c)})" for c in cycles)


n = 4
G = list(permutations(range(n)))
e = identity(n)

# Choose H = <(01)> (non-normal, order 2)
H = generate_subgroup([(1, 0, 2, 3)], n)

# Get representatives of different conjugation indices
representatives = {}
for g in G:
    ci = conjugation_index(H, g, n)
    if ci not in representatives:
        representatives[ci] = g

# Sort by conjugation index
sorted_reps = sorted(representatives.items())

fig, axes = plt.subplots(1, len(sorted_reps), figsize=(5 * len(sorted_reps), 8))
if len(sorted_reps) == 1:
    axes = [axes]

colors = plt.cm.Set2(np.linspace(0, 1, 8))

for plot_idx, (ci, g) in enumerate(sorted_reps):
    ax = axes[plot_idx]

    dc = double_coset(H, g)

    # Decompose into left cosets
    remaining = set(dc)
    cosets = []
    while remaining:
        rep = min(remaining)  # deterministic choice
        coset = left_coset(rep, H)
        cosets.append((rep, coset))
        remaining -= coset

    ax.set_xlim(-0.5, max(len(cosets), 1) + 0.5)
    ax.set_ylim(-0.5, len(H) + 1.5)
    ax.set_title(f"$Hg H$ for $g = {perm_to_str(g)}$\n"
                 f"Conj. Index = {ci}, |HgH| = {len(dc)}",
                 fontsize=12, fontweight='bold')

    for coset_idx, (rep, coset) in enumerate(cosets):
        x = coset_idx + 0.5
        sorted_elems = sorted(coset)

        # Draw coset box
        rect = FancyBboxPatch((x - 0.4, 0), 0.8, len(sorted_elems) + 0.5,
                              boxstyle="round,pad=0.1",
                              facecolor=colors[coset_idx % len(colors)],
                              edgecolor='black', linewidth=1.5, alpha=0.3)
        ax.add_patch(rect)

        # Label each element
        for elem_idx, elem in enumerate(sorted_elems):
            y = elem_idx + 0.5
            label = perm_to_str(elem)
            ax.text(x, y, label, ha='center', va='center', fontsize=8,
                   fontfamily='monospace')

        # Coset label
        ax.text(x, len(sorted_elems) + 0.3, f"{perm_to_str(rep)}·H",
                ha='center', va='bottom', fontsize=9, fontweight='bold',
                color=colors[coset_idx % len(colors)] * 0.6)

    ax.set_xlabel("Left Cosets", fontsize=11)
    if plot_idx == 0:
        ax.set_ylabel("Elements", fontsize=11)
    ax.set_xticks([])
    ax.set_yticks([])

fig.suptitle(r"Double Coset Decomposition $HgH$ in $S_4$, $H = \langle(01)\rangle$",
             fontsize=16, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("double_coset.png", dpi=150, bbox_inches='tight')
print("Saved double_coset.png")
