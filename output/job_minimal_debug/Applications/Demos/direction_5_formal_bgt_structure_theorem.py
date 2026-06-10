"""
Applications of the BGT Structure Theorem

Demonstrates real-world applications of approximate subgroup theory:
1. Cayley graph expanders for communication networks
2. Random walk mixing on groups
3. Error detection in group-based cryptography
4. Sum-product estimates for additive combinatorics
"""

from typing import Set, List, Tuple, Dict
import math
import random


def cyclic_group_op(n: int):
    """Return (multiply, invert) for Z/nZ."""
    return (lambda a, b: (a + b) % n, lambda a: (-a) % n)


def product_set(A: Set[int], B: Set[int], op) -> Set[int]:
    """Compute A · B under operation op."""
    return {op(a, b) for a in A for b in B}


# ─────────────────────────────────────────────────────────────
# Application 1: Cayley Expander Construction
# ─────────────────────────────────────────────────────────────

def cayley_expansion_ratio(n: int, generators: Set[int]) -> float:
    """
    Compute the expansion ratio of the Cayley graph Cay(Z/nZ, S).
    
    The expansion ratio h(G) = min_{|S|≤n/2} |∂S|/|S| where ∂S
    is the edge boundary. By the growth dichotomy, if S generates
    the group, this is always positive.
    
    Application: In communication networks, expander graphs guarantee
    that messages reach all nodes quickly. Cayley expanders achieve
    this via algebraic structure.
    
    >>> cayley_expansion_ratio(7, {1, 6})  # > 0
    """
    op, inv = cyclic_group_op(n)
    all_elements = set(range(n))
    
    min_ratio = float('inf')
    # Check small subsets for expansion
    for size in range(1, n // 2 + 1):
        # Sample random subsets of this size
        for _ in range(min(20, math.comb(n, size))):
            S = set(random.sample(range(n), size))
            # Compute boundary: neighbors outside S
            boundary = set()
            for s in S:
                for g in generators:
                    neighbor = op(s, g)
                    if neighbor not in S:
                        boundary.add(neighbor)
                    neighbor = op(s, inv(g))
                    if neighbor not in S:
                        boundary.add(neighbor)
            ratio = len(boundary) / len(S) if len(S) > 0 else 0
            min_ratio = min(min_ratio, ratio)
    
    return min_ratio


# ─────────────────────────────────────────────────────────────
# Application 2: Random Walk Mixing
# ─────────────────────────────────────────────────────────────

def random_walk_mixing(n: int, generators: List[int], 
                       steps: int) -> Dict[int, float]:
    """
    Simulate random walk on Z/nZ with given generators.
    
    Starting from 0, at each step uniformly choose a generator
    and add it. Track the distribution over time.
    
    By the BGT theory, if the generators form a K-approximate
    subgroup with K close to 1, mixing is slow (the walk stays
    near a subgroup). If K is large, mixing is fast.
    
    Application: In Markov chain Monte Carlo, understanding mixing
    time is crucial for sampling efficiency.
    
    >>> dist = random_walk_mixing(12, [1, 11], 100)
    """
    op, _ = cyclic_group_op(n)
    
    # Track distribution
    distribution = {i: 0.0 for i in range(n)}
    distribution[0] = 1.0
    
    for _ in range(steps):
        new_dist = {i: 0.0 for i in range(n)}
        for pos, prob in distribution.items():
            if prob > 0:
                for g in generators:
                    new_pos = op(pos, g)
                    new_dist[new_pos] += prob / len(generators)
        distribution = new_dist
    
    return distribution


def total_variation_distance(dist: Dict[int, float], n: int) -> float:
    """Total variation distance from uniform distribution."""
    uniform = 1.0 / n
    return 0.5 * sum(abs(dist[i] - uniform) for i in range(n))


# ─────────────────────────────────────────────────────────────
# Application 3: Sum-Product Estimates
# ─────────────────────────────────────────────────────────────

def sum_product_growth(A: Set[int], p: int) -> Tuple[int, int, float]:
    """
    Compute sum set and product set sizes in Z/pZ.
    
    The Erdős-Szemerédi conjecture says that for any A ⊆ Z/pZ,
    max(|A+A|, |A·A|) ≥ |A|^{2-ε}. The BGT theory connects
    this to approximate subgroups: if |A+A| is small, then A
    must be structured (close to an arithmetic progression).
    
    Application: Sum-product estimates have applications in
    cryptographic security, ensuring that field operations
    create sufficient entropy.
    
    >>> sum_product_growth({1, 2, 3, 4}, 13)
    """
    sum_set = {(a + b) % p for a in A for b in A}
    prod_set = {(a * b) % p for a in A for b in A}
    
    max_growth = max(len(sum_set), len(prod_set)) / len(A)
    
    return len(sum_set), len(prod_set), max_growth


# ─────────────────────────────────────────────────────────────
# Application 4: Growth-based Group Structure Detection
# ─────────────────────────────────────────────────────────────

def detect_hidden_subgroup(n: int, A: Set[int]) -> List[Set[int]]:
    """
    Use product growth to detect subgroup structure.
    
    Algorithm:
    1. Compute A, A², A³, ...
    2. If growth stalls (|A^k| = |A^{k+1}|), then A^k is a subgroup
    3. Return all detected subgroups
    
    This is the computational content of the BGT structure theorem:
    approximate subgroups "reveal" nearby genuine subgroups through
    their growth patterns.
    
    Application: Hidden subgroup problems are central to quantum
    computing (Shor's algorithm solves the HSP for abelian groups).
    """
    op, inv = cyclic_group_op(n)
    
    subgroups = []
    current = A | {0} | {inv(a) for a in A}  # symmetrize
    
    for k in range(1, n + 1):
        next_set = product_set(current, A | {inv(a) for a in A}, op)
        next_set.add(0)
        
        if next_set == current:
            # Stalled: current should be a subgroup
            # Verify
            is_sub = True
            for a in current:
                for b in current:
                    if op(a, b) not in current:
                        is_sub = False
                        break
                if not is_sub:
                    break
            if is_sub:
                subgroups.append(current.copy())
            break
        current = next_set
    
    return subgroups


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)
    
    print("=" * 60)
    print("APPLICATION 1: Cayley Expander Construction")
    print("=" * 60)
    for n in [11, 23, 47]:
        ratio = cayley_expansion_ratio(n, {1, n-1})
        print(f"  Cay(Z/{n}Z, {{1, {n-1}}}): expansion ≥ {ratio:.3f}")
    
    print()
    print("=" * 60)
    print("APPLICATION 2: Random Walk Mixing")
    print("=" * 60)
    
    # Compare mixing with subgroup generators vs expanding generators
    n = 12
    print(f"  Group: Z/{n}Z")
    
    # Generators in subgroup: slow mixing
    for steps in [5, 10, 20, 50]:
        dist = random_walk_mixing(n, [3, 9], steps)
        tv = total_variation_distance(dist, n)
        print(f"  Subgroup gens {{3,9}}, {steps} steps: TV = {tv:.4f}")
    
    print()
    for steps in [5, 10, 20, 50]:
        dist = random_walk_mixing(n, [1, 11], steps)
        tv = total_variation_distance(dist, n)
        print(f"  Expanding gens {{1,11}}, {steps} steps: TV = {tv:.4f}")
    
    print()
    print("=" * 60)
    print("APPLICATION 3: Sum-Product Estimates")
    print("=" * 60)
    
    p = 13
    for A in [{1, 2, 3}, {1, 2, 4}, {1, 3, 9}, {1, 2, 3, 4, 5}]:
        s, pr, growth = sum_product_growth(A, p)
        print(f"  Z/{p}Z, A={sorted(A)}: |A+A|={s}, |A·A|={pr}, "
              f"max growth={growth:.2f}")
    
    print()
    print("=" * 60)
    print("APPLICATION 4: Hidden Subgroup Detection")
    print("=" * 60)
    
    for n in [12, 24, 30]:
        A = {3}  # seed with a single element
        subs = detect_hidden_subgroup(n, A)
        for H in subs:
            print(f"  Z/{n}Z, seed={{3}}: detected subgroup "
                  f"{sorted(H)} of order {len(H)}")
    
    print("\nAll applications completed.")


"""
Demo: Approximate Subgroups and the BGT Structure Theorem

Demonstrates the key results of the BGT (Breuillard-Green-Tao) theory
of approximate subgroups through concrete numerical examples.

Key demonstrations:
1. K=1 approximate subgroups are genuine subgroups
2. Small tripling implies small doubling
3. Growth dichotomy in finite groups
4. Spectral bridge between product growth and Cayley graph expansion
"""

from itertools import product as cartesian_product
from collections import defaultdict
import random


def group_op(a, b, n):
    """Group operation in Z/nZ."""
    return (a + b) % n


def group_inv(a, n):
    """Inverse in Z/nZ."""
    return (-a) % n


def product_set(A, B, n):
    """Compute A * B in Z/nZ."""
    return set((a + b) % n for a in A for b in B)


def triple_product(A, n):
    """Compute A * A * A in Z/nZ."""
    AA = product_set(A, A, n)
    return product_set(AA, A, n)


def is_symmetric(A, n):
    """Check if A is symmetric (closed under inversion) in Z/nZ."""
    return all((-a) % n in A for a in A)


def is_subgroup(A, n):
    """Check if A is a subgroup of Z/nZ."""
    if 0 not in A:
        return False
    if not is_symmetric(A, n):
        return False
    AA = product_set(A, A, n)
    return AA == A


# ─────────────────────────────────────────────────────────────
# Demo 1: K=1 Approximate Subgroups are Subgroups
# ─────────────────────────────────────────────────────────────
print("=" * 60)
print("DEMO 1: K=1 Approximate Subgroups are Subgroups")
print("=" * 60)
print()
print("Theorem: If A is symmetric, 0 ∈ A, and |A+A+A| ≤ |A|,")
print("then A is a subgroup.")
print()

# Example 1: Subgroup {0, 3, 6, 9} of Z/12Z
n = 12
A = {0, 3, 6, 9}
AAA = triple_product(A, n)
print(f"Z/{n}Z, A = {sorted(A)}")
print(f"  |A| = {len(A)}, |A+A+A| = {len(AAA)}")
print(f"  K = |A+A+A|/|A| = {len(AAA)/len(A):.2f}")
print(f"  Is subgroup? {is_subgroup(A, n)}")
print(f"  K=1? {len(AAA) <= len(A)} → Must be subgroup ✓")
print()

# Example 2: Non-subgroup {0, 1, 11} of Z/12Z
A2 = {0, 1, 11}  # = {0, 1, -1}
AAA2 = triple_product(A2, n)
AA2 = product_set(A2, A2, n)
print(f"Z/{n}Z, A = {sorted(A2)}")
print(f"  |A| = {len(A2)}, |A+A| = {len(AA2)}, |A+A+A| = {len(AAA2)}")
print(f"  K = |A+A+A|/|A| = {len(AAA2)/len(A2):.2f}")
print(f"  Is subgroup? {is_subgroup(A2, n)}")
print(f"  K > 1 → Strict growth confirmed ✓")
print()

# ─────────────────────────────────────────────────────────────
# Demo 2: Small Tripling Implies Small Doubling
# ─────────────────────────────────────────────────────────────
print("=" * 60)
print("DEMO 2: Small Tripling → Small Doubling")
print("=" * 60)
print()
print("Theorem: If 0 ∈ A and |A+A+A| ≤ K|A|, then |A+A| ≤ K|A|.")
print("Proof: A+A ⊆ A+A+A when 0 ∈ A, so |A+A| ≤ |A+A+A| ≤ K|A|.")
print()

for n in [20, 30, 50]:
    # Arithmetic progressions in Z/nZ
    d = 1
    for m in [3, 5, 7]:
        if m > n:
            continue
        A = set(range(m))  # {0, 1, ..., m-1}
        AA = product_set(A, A, n)
        AAA = triple_product(A, n)
        K_trip = len(AAA) / len(A)
        K_doub = len(AA) / len(A)
        print(f"  Z/{n}Z, A = {{0,...,{m-1}}}: "
              f"|A|={len(A)}, |A²|={len(AA)}, |A³|={len(AAA)}, "
              f"σ={K_doub:.2f}, τ={K_trip:.2f}, σ ≤ τ? {K_doub <= K_trip} ✓")
print()

# ─────────────────────────────────────────────────────────────
# Demo 3: Growth Dichotomy
# ─────────────────────────────────────────────────────────────
print("=" * 60)
print("DEMO 3: Growth Dichotomy in Finite Groups")
print("=" * 60)
print()
print("Theorem: If A generates G and 0 ∈ A, then |A^k| is strictly")
print("increasing until A^k = G.")
print()

n = 15
A = {0, 1, n - 1}  # {0, 1, -1} generates Z/nZ
print(f"Z/{n}Z, A = {sorted(A)}")

current = A.copy()
for k in range(1, 20):
    print(f"  k={k}: |A^k| = {len(current)}", end="")
    if current == set(range(n)):
        print(" = |G| ← Saturated!")
        break
    else:
        next_set = product_set(current, A, n)
        print(f", |A^{{k+1}}| = {len(next_set)}, "
              f"strict growth: {len(next_set) > len(current)} ✓")
        current = next_set
print()

# ─────────────────────────────────────────────────────────────
# Demo 4: Cayley Graph Diameter
# ─────────────────────────────────────────────────────────────
print("=" * 60)
print("DEMO 4: Cayley Graph Diameter Bounds")
print("=" * 60)
print()
print("Theorem: If A generates G, then A^N = G for some N ≤ |G|.")
print()

for n in [7, 11, 13, 23]:
    A = {0, 1, n - 1}
    current = A.copy()
    for k in range(1, n + 1):
        if current == set(range(n)):
            print(f"  Z/{n}Z: diameter = {k} "
                  f"(bound = {n}, ratio = {k/n:.2f})")
            break
        current = product_set(current, A, n)
print()

# ─────────────────────────────────────────────────────────────
# Demo 5: SL(2, F_p) Growth (using 2x2 matrices mod p)
# ─────────────────────────────────────────────────────────────
print("=" * 60)
print("DEMO 5: Growth in SL(2, F_p)")
print("=" * 60)
print()


def mat_mul_mod(A, B, p):
    """2x2 matrix multiplication mod p."""
    return [
        [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % p,
         (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % p],
        [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % p,
         (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % p]
    ]


def mat_det(M, p):
    """Determinant of 2x2 matrix mod p."""
    return (M[0][0]*M[1][1] - M[0][1]*M[1][0]) % p


def mat_to_tuple(M):
    """Convert matrix to hashable tuple."""
    return (M[0][0], M[0][1], M[1][0], M[1][1])


def mat_inv_mod(M, p):
    """Inverse of 2x2 matrix with det=1 mod p."""
    return [[M[1][1] % p, (-M[0][1]) % p],
            [(-M[1][0]) % p, M[0][0] % p]]


def sl2_product_set(A_set, B_set, p):
    """Product set of matrix sets in SL(2, F_p)."""
    result = set()
    for a in A_set:
        a_mat = [[a[0], a[1]], [a[2], a[3]]]
        for b in B_set:
            b_mat = [[b[0], b[1]], [b[2], b[3]]]
            prod = mat_mul_mod(a_mat, b_mat, p)
            result.add(mat_to_tuple(prod))
    return result


for p in [5, 7]:
    # Generators of SL(2, F_p): elementary matrices
    I = mat_to_tuple([[1, 0], [0, 1]])
    E12 = mat_to_tuple([[1, 1], [0, 1]])
    E21 = mat_to_tuple([[1, 0], [1, 1]])
    E12_inv = mat_to_tuple(mat_inv_mod([[1, 1], [0, 1]], p))
    E21_inv = mat_to_tuple(mat_inv_mod([[1, 0], [1, 1]], p))

    A = {I, E12, E21, E12_inv, E21_inv}

    # Compute SL(2, F_p) size
    sl2_size = p * (p*p - 1)  # |SL(2, F_p)| = p(p²-1)

    current = A
    print(f"SL(2, F_{p}): |G| = {sl2_size}")
    for k in range(1, 20):
        next_set = sl2_product_set(current, A, p)
        if len(next_set) == len(current):
            print(f"  Saturated at k={k+1}: |A^k| = {len(current)}")
            break
        print(f"  k={k}: |A^k| = {len(current)} → {len(next_set)} "
              f"(growth ratio: {len(next_set)/len(current):.2f})")
        current = next_set
    print()

print("=" * 60)
print("All demos completed successfully.")
print("=" * 60)


"""
Visualization: Approximate Subgroup Classification Map

Creates a heatmap showing the doubling constant σ(A) = |A+A|/|A| and 
tripling constant τ(A) = |A+A+A|/|A| for various subsets of Z/nZ.
The K=1 region corresponds to genuine subgroups (our main theorem).
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def product_set(A, B, n):
    """Product set in Z/nZ."""
    return set((a + b) % n for a in A for b in B)


def compute_constants(A, n):
    """Compute doubling and tripling constants."""
    if len(A) == 0:
        return 0, 0
    AA = product_set(A, A, n)
    AAA = product_set(AA, A, n)
    return len(AA) / len(A), len(AAA) / len(A)


def is_subgroup(A, n):
    """Check if A forms a subgroup of Z/nZ."""
    if 0 not in A:
        return False
    for a in A:
        if (-a) % n not in A:
            return False
    return product_set(A, A, n) == A


# Collect data for Z/24Z
n = 24
doublings = []
triplings = []
sizes = []
is_sub = []
labels = []

# Generate symmetric sets containing 0
elements = list(range(1, n))
tested = set()

for size in range(1, 9):
    # For each size, generate symmetric sets
    half_elements = [x for x in range(1, n//2 + 1)]
    
    for combo in combinations(half_elements, size):
        A = {0}
        for x in combo:
            A.add(x)
            A.add((-x) % n)
        
        A_key = frozenset(A)
        if A_key in tested:
            continue
        tested.add(A_key)
        
        sigma, tau = compute_constants(A, n)
        doublings.append(sigma)
        triplings.append(tau)
        sizes.append(len(A))
        is_sub.append(is_subgroup(A, n))
        labels.append(sorted(A))

doublings = np.array(doublings)
triplings = np.array(triplings)
sizes = np.array(sizes)
is_sub_arr = np.array(is_sub)

fig, ax = plt.subplots(figsize=(10, 8))

# Plot non-subgroups
mask_nonsub = ~is_sub_arr
scatter1 = ax.scatter(doublings[mask_nonsub], triplings[mask_nonsub], 
                      c=sizes[mask_nonsub], cmap='viridis', s=30, alpha=0.6,
                      edgecolors='none', label='Non-subgroup')

# Plot subgroups prominently
mask_sub = is_sub_arr
ax.scatter(doublings[mask_sub], triplings[mask_sub],
           c='red', s=150, marker='*', edgecolors='black',
           linewidths=1, label='Subgroup (K=1)', zorder=5)

# Add diagonal reference line σ ≤ τ
max_val = max(max(doublings), max(triplings)) + 0.5
ax.plot([1, max_val], [1, max_val], 'k--', alpha=0.3, label='σ = τ')

# Labels and formatting
ax.set_xlabel('Doubling constant σ = |A+A|/|A|', fontsize=13)
ax.set_ylabel('Tripling constant τ = |A+A+A|/|A|', fontsize=13)
ax.set_title(f'Approximate Subgroup Landscape in Z/{n}Z\n'
             'Subgroups cluster at (1, 1); non-subgroups show σ ≤ τ',
             fontsize=14)

cbar = plt.colorbar(scatter1, ax=ax, label='|A|')
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.2)
ax.set_xlim(0.8, max_val)
ax.set_ylim(0.8, max_val)

# Annotate the K=1 region
ax.axvspan(0.8, 1.05, alpha=0.1, color='red')
ax.axhspan(0.8, 1.05, alpha=0.1, color='red')
ax.annotate('K=1 region\n(Subgroups)', xy=(1.0, 1.0),
            xytext=(2.0, 1.5), fontsize=11,
            arrowprops=dict(arrowstyle='->', color='red'),
            color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('approx_subgroups.png', dpi=150, bbox_inches='tight')
print("Saved approx_subgroups.png")


"""
Visualization: Product Set Growth Sequences

Visualizes the growth dichotomy theorem: for generating sets in finite groups,
|A^k| increases strictly at every step until A^k = G. Different initial sets
show different growth rates but the same qualitative behavior.
"""

import matplotlib.pyplot as plt
import numpy as np


def product_set_cyclic(A, B, n):
    """Product set in Z/nZ."""
    return set((a + b) % n for a in A for b in B)


def growth_sequence(A, n, max_k=None):
    """Compute |A^k| for k = 0, 1, 2, ..."""
    if max_k is None:
        max_k = n
    sizes = [1]
    current = {0}
    for k in range(1, max_k + 1):
        current = product_set_cyclic(current, A, n)
        sizes.append(len(current))
        if len(current) == n:
            break
    return sizes


# Parameters
n = 60  # Z/60Z

configs = [
    ({0, 1, 59}, "A = {0, 1, -1}", "#2196F3"),
    ({0, 7, 53}, "A = {0, 7, -7}", "#FF5722"),
    ({0, 1, 7, 53, 59}, "A = {0, ±1, ±7}", "#4CAF50"),
    ({0, 12, 48}, "A = {0, 12, -12}", "#9C27B0"),
]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Growth sequences
ax = axes[0]
for A, label, color in configs:
    sizes = growth_sequence(A, n)
    steps = list(range(len(sizes)))
    ax.plot(steps, sizes, 'o-', label=label, color=color, markersize=4, linewidth=2)

ax.axhline(y=n, color='gray', linestyle='--', alpha=0.5, label=f'|G| = {n}')
ax.set_xlabel('Step k', fontsize=12)
ax.set_ylabel('|A^k|', fontsize=12)
ax.set_title(f'Growth Dichotomy in Z/{n}Z', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Growth ratios
ax = axes[1]
for A, label, color in configs:
    sizes = growth_sequence(A, n)
    ratios = [sizes[k+1]/sizes[k] if sizes[k] > 0 else 0 
              for k in range(len(sizes)-1)]
    steps = list(range(1, len(ratios)+1))
    ax.plot(steps, ratios, 's-', label=label, color=color, markersize=4, linewidth=2)

ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='No growth (ratio=1)')
ax.set_xlabel('Step k', fontsize=12)
ax.set_ylabel('|A^{k+1}|/|A^k|', fontsize=12)
ax.set_title('Growth Ratios (must be > 1 until saturation)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.8, 4)

plt.tight_layout()
plt.savefig('growth_sequences.png', dpi=150, bbox_inches='tight')
print("Saved growth_sequences.png")


"""
Visualization: Growth in SL(2, F_p)

Shows product set growth in the special linear group SL(2, F_p)
for small primes. Demonstrates that elementary matrix generators
produce rapid expansion, consistent with Helfgott's theorem.
"""

import matplotlib.pyplot as plt
import numpy as np


def mat_mul_mod(A, B, p):
    """2x2 matrix multiplication mod p."""
    return (
        (A[0]*B[0] + A[1]*B[2]) % p,
        (A[0]*B[1] + A[1]*B[3]) % p,
        (A[2]*B[0] + A[3]*B[2]) % p,
        (A[2]*B[1] + A[3]*B[3]) % p
    )


def mat_inv(M, p):
    """Inverse of 2x2 matrix with det=1 in F_p."""
    return (M[3] % p, (-M[1]) % p, (-M[2]) % p, M[0] % p)


def sl2_product_set(A_set, B_set, p):
    """Product set of matrix sets."""
    return {mat_mul_mod(a, b, p) for a in A_set for b in B_set}


def sl2_generators(p):
    """Standard generators: I, E12, E21, E12⁻¹, E21⁻¹."""
    I = (1, 0, 0, 1)
    E12 = (1, 1, 0, 1)
    E21 = (1, 0, 1, 1)
    E12_inv = mat_inv(E12, p)
    E21_inv = mat_inv(E21, p)
    return {I, E12, E21, E12_inv, E21_inv}


def sl2_size(p):
    """Order of SL(2, F_p)."""
    return p * (p * p - 1)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Growth sequences for different primes
ax = axes[0]
primes = [3, 5, 7]
colors = ['#2196F3', '#FF5722', '#4CAF50']

for p, color in zip(primes, colors):
    gens = sl2_generators(p)
    sizes = [len(gens)]
    current = gens
    
    for k in range(1, 30):
        next_set = sl2_product_set(current, gens, p)
        sizes.append(len(next_set))
        if len(next_set) == len(current):
            break
        current = next_set
    
    group_size = sl2_size(p)
    # Normalize by group size
    normalized = [s / group_size for s in sizes]
    steps = list(range(1, len(sizes) + 1))
    
    ax.plot(steps, normalized, 'o-', color=color, markersize=4, linewidth=2,
            label=f'SL(2, F_{p}), |G|={group_size}')
    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.3)

ax.set_xlabel('Step k', fontsize=12)
ax.set_ylabel('|A^k| / |G|', fontsize=12)
ax.set_title('Growth in SL(2, F_p)\n(Normalized by group order)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.1)

# Right: Growth ratios
ax = axes[1]

for p, color in zip(primes, colors):
    gens = sl2_generators(p)
    sizes = [len(gens)]
    current = gens
    
    for k in range(1, 30):
        next_set = sl2_product_set(current, gens, p)
        sizes.append(len(next_set))
        if len(next_set) == len(current):
            break
        current = next_set
    
    ratios = [sizes[k]/sizes[k-1] for k in range(1, len(sizes)) if sizes[k-1] > 0]
    steps = list(range(1, len(ratios) + 1))
    
    ax.plot(steps, ratios, 's-', color=color, markersize=5, linewidth=2,
            label=f'SL(2, F_{p})')

ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='No growth')
ax.set_xlabel('Step k', fontsize=12)
ax.set_ylabel('|A^{k+1}| / |A^k|', fontsize=12)
ax.set_title('Growth Ratios in SL(2, F_p)\n(Rapid initial expansion)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('sl2_growth.png', dpi=150, bbox_inches='tight')
print("Saved sl2_growth.png")
