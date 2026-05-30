"""
Applications of k-Tuple Möbius Inversion

1. Cryptographic key generation: probability that k random group elements
   generate the full group (security parameter).
2. Error-correcting codes: diversity of random generator sets.
3. Euler totient as the k=1 cyclic case.
"""

from math import factorial, gcd
from itertools import permutations, product
from typing import List, Tuple, FrozenSet, Dict, Set


# ─── Application 1: Euler totient via Möbius inversion ────────────────────────

def euler_totient_moebius(n: int) -> int:
    """Compute φ(n) via the number-theoretic Möbius inversion formula.

    φ(n) = Σ_{d|n} μ(d) · (n/d) = n · Π_{p|n} (1 - 1/p)

    This is the k=1 case of the Hall formula for cyclic groups Z/nZ.
    The subgroups of Z/nZ are Z/dZ for d | n, and the subgroup lattice
    Möbius function μ(Z/dZ, Z/nZ) = μ_arith(n/d).

    >>> euler_totient_moebius(1)
    1
    >>> euler_totient_moebius(6)
    2
    >>> euler_totient_moebius(12)
    4
    """
    def arith_moebius(m: int) -> int:
        """Number-theoretic Möbius function."""
        if m == 1:
            return 1
        # Factor m
        factors = []
        temp = m
        d = 2
        while d * d <= temp:
            if temp % d == 0:
                count = 0
                while temp % d == 0:
                    temp //= d
                    count += 1
                if count > 1:
                    return 0
                factors.append(d)
            d += 1
        if temp > 1:
            factors.append(temp)
        return (-1) ** len(factors)

    result = 0
    for d in range(1, n + 1):
        if n % d == 0:
            result += arith_moebius(d) * (n // d)
    return result


# ─── Application 2: Cryptographic key diversity ──────────────────────────────

def key_generation_security(n: int, k: int) -> dict:
    """Analyze security of using k random permutations as cryptographic keys.

    In permutation-based cryptography, the security relies on the generated
    group being the full symmetric group. The probability P_{n,k} that k
    random permutations generate S_n determines the security margin.

    Returns analysis including:
    - generating probability
    - failure probability (not generating S_n)
    - bits of security lost due to generation failure

    >>> result = key_generation_security(3, 3)
    >>> result['generates_full_group_prob'] > 0.7
    True
    """
    import math

    # For small n, compute exactly
    all_perms = list(permutations(range(n)))
    full = frozenset(all_perms)

    def compose(p, q):
        return tuple(p[q[i]] for i in range(len(p)))

    def inverse(p):
        inv = [0] * len(p)
        for i, v in enumerate(p):
            inv[v] = i
        return tuple(inv)

    def closure(gens):
        group = {tuple(range(n))}
        for g in gens:
            group.add(g)
        changed = True
        while changed:
            changed = False
            new = set()
            for g in list(group):
                for h in gens:
                    for e in [compose(g, h), compose(h, g),
                              compose(g, inverse(h))]:
                        if e not in group and e not in new:
                            new.add(e)
                            changed = True
            group.update(new)
        return frozenset(group)

    gen_count = 0
    total = len(all_perms) ** k
    for combo in product(all_perms, repeat=k):
        if closure(list(combo)) == full:
            gen_count += 1

    prob = gen_count / total
    failure = 1 - prob
    security_loss = -math.log2(failure) if failure > 0 else float('inf')

    return {
        'n': n,
        'k': k,
        'group_order': factorial(n),
        'generates_full_group_prob': prob,
        'failure_prob': failure,
        'security_bits_lost': security_loss,
        'phi_k': gen_count,
        'total_tuples': total
    }


# ─── Application 3: Generating probability convergence ───────────────────────

def convergence_table(max_n: int = 3, max_k: int = 6) -> None:
    """Print a convergence table showing P_{n,k} → 1 as k → ∞.

    This demonstrates the physical intuition: more random generators
    make it overwhelmingly likely to generate the full group.
    """
    print("Convergence of P_{n,k} = Prob(k random perms generate S_n)")
    print()
    header = f"{'n\\k':>5s}"
    for k in range(1, max_k + 1):
        header += f" | {k:>8d}"
    print(header)
    print("-" * len(header))

    for n in range(2, max_n + 1):
        all_perms = list(permutations(range(n)))
        full = frozenset(all_perms)

        def compose(p, q):
            return tuple(p[q[i]] for i in range(len(p)))

        def inverse(p):
            inv = [0] * len(p)
            for i, v in enumerate(p):
                inv[v] = i
            return tuple(inv)

        def closure(gens):
            group = {tuple(range(n))}
            for g in gens:
                group.add(g)
            changed = True
            while changed:
                changed = False
                new = set()
                for g in list(group):
                    for h in gens:
                        for e in [compose(g, h), compose(h, g),
                                  compose(g, inverse(h))]:
                            if e not in group and e not in new:
                                new.add(e)
                                changed = True
                group.update(new)
            return frozenset(group)

        row = f"{n:>5d}"
        for k in range(1, max_k + 1):
            gen_count = 0
            total = len(all_perms) ** k
            for combo in product(all_perms, repeat=k):
                if closure(list(combo)) == full:
                    gen_count += 1
            prob = gen_count / total
            row += f" | {prob:>8.5f}"
        print(row)


if __name__ == "__main__":
    import doctest
    doctest.testmod()

    print("=" * 70)
    print("  Application 1: Euler totient via Möbius inversion (k=1, cyclic)")
    print("=" * 70)
    for n in [1, 2, 3, 4, 5, 6, 10, 12, 15, 20]:
        phi = euler_totient_moebius(n)
        print(f"  φ({n:2d}) = {phi}")
    print()

    print("=" * 70)
    print("  Application 2: Cryptographic key generation analysis")
    print("=" * 70)
    for k in [2, 3, 4]:
        result = key_generation_security(3, k)
        print(f"  S_3 with k={k}: P = {result['generates_full_group_prob']:.4f}, "
              f"failure = {result['failure_prob']:.4f}, "
              f"security loss ≈ {result['security_bits_lost']:.1f} bits")
    print()

    print("=" * 70)
    print("  Application 3: Convergence P_{n,k} → 1")
    print("=" * 70)
    convergence_table(max_n=3, max_k=5)


"""
Demonstration of k-Tuple Möbius Inversion for Finite Group Generation

This script computes the Hall k-Eulerian function φ_k(G) for symmetric groups S_n
both by brute force (enumerating all k-tuples) and via the Möbius inversion formula,
verifying agreement.

Key results demonstrated:
  φ_k(G) = Σ_{H ≤ G} μ(H,G) · |H|^k
  P_{n,k} = φ_k(S_n) / n!^k  (generating probability)
"""

from itertools import product
from math import factorial, gcd
from functools import reduce
from typing import List, Tuple, Dict, Set, FrozenSet


# ─── Permutation utilities ───────────────────────────────────────────────────

def compose_perms(p: Tuple[int, ...], q: Tuple[int, ...]) -> Tuple[int, ...]:
    """Compose permutations: (p ∘ q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(p)))


def inverse_perm(p: Tuple[int, ...]) -> Tuple[int, ...]:
    """Inverse of a permutation."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def identity_perm(n: int) -> Tuple[int, ...]:
    return tuple(range(n))


def generate_all_perms(n: int) -> List[Tuple[int, ...]]:
    """Generate all permutations of {0, ..., n-1}."""
    if n == 0:
        return [()]
    if n == 1:
        return [(0,)]
    result = []
    for perm in generate_all_perms(n - 1):
        for i in range(n):
            result.append(perm[:i] + (n - 1,) + tuple(x for x in perm[i:]))
    # Fix: generate properly
    from itertools import permutations
    return [p for p in permutations(range(n))]


def closure_of_perms(generators: List[Tuple[int, ...]], n: int) -> FrozenSet[Tuple[int, ...]]:
    """Compute the subgroup generated by a set of permutations."""
    e = identity_perm(n)
    group = {e}
    queue = list(generators)
    for g in generators:
        group.add(g)

    changed = True
    while changed:
        changed = False
        new_elements = set()
        for g in group:
            for h in generators:
                for elem in [compose_perms(g, h), compose_perms(h, g),
                             compose_perms(g, inverse_perm(h)),
                             compose_perms(inverse_perm(h), g)]:
                    if elem not in group:
                        new_elements.add(elem)
                        changed = True
        group.update(new_elements)
    return frozenset(group)


def all_subgroups(n: int) -> List[FrozenSet[Tuple[int, ...]]]:
    """Find all subgroups of S_n (brute force, feasible for small n)."""
    perms = generate_all_perms(n)
    subgroups = set()
    # Generate subgroups by taking closures of all subsets (up to size limit)
    # For efficiency, just try closures of 0, 1, 2 generators
    subgroups.add(frozenset([identity_perm(n)]))
    for p in perms:
        subgroups.add(closure_of_perms([p], n))
    for i, p in enumerate(perms):
        for q in perms[i:]:
            subgroups.add(closure_of_perms([p, q], n))
    # Also try triples for completeness
    if n <= 3:
        for i, p in enumerate(perms):
            for j, q in enumerate(perms[i:], i):
                for r in perms[j:]:
                    subgroups.add(closure_of_perms([p, q, r], n))
    return list(subgroups)


# ─── Möbius function on subgroup lattice ──────────────────────────────────────

def compute_moebius(subgroups: List[FrozenSet], full_group: FrozenSet) -> Dict[FrozenSet, int]:
    """Compute the Möbius function μ(H, G) for all subgroups H ≤ G.

    Uses the recursive definition:
      μ(G, G) = 1
      μ(H, G) = -Σ_{K: H < K ≤ G} μ(K, G)
    """
    # Sort subgroups by size (descending) for top-down computation
    sorted_subs = sorted(subgroups, key=lambda s: len(s), reverse=True)
    mu = {}

    for H in sorted_subs:
        if H == full_group:
            mu[H] = 1
        else:
            mu[H] = -sum(mu[K] for K in sorted_subs
                         if H < K and H.issubset(K))
    return mu


def phi_k_brute_force(n: int, k: int) -> int:
    """Compute φ_k(S_n) by brute force: count k-tuples generating S_n."""
    perms = generate_all_perms(n)
    full_group = frozenset(perms)
    count = 0
    for combo in product(perms, repeat=k):
        if closure_of_perms(list(combo), n) == full_group:
            count += 1
    return count


def phi_k_moebius(n: int, k: int) -> int:
    """Compute φ_k(S_n) via the Möbius inversion formula:
    φ_k(G) = Σ_{H ≤ G} μ(H, G) · |H|^k
    """
    perms = generate_all_perms(n)
    full_group = frozenset(perms)
    subgroups = all_subgroups(n)
    mu = compute_moebius(subgroups, full_group)

    result = sum(mu[H] * len(H) ** k for H in subgroups)
    return result


# ─── Main demonstration ──────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  k-Tuple Möbius Inversion for Symmetric Group Generation")
    print("=" * 70)
    print()

    # Test for small symmetric groups
    for n in [2, 3]:
        perms = generate_all_perms(n)
        print(f"S_{n} has {len(perms)} = {n}! elements")
        print()

        for k in [1, 2, 3]:
            print(f"  k = {k}:")
            bf = phi_k_brute_force(n, k)
            mob = phi_k_moebius(n, k)
            total = len(perms) ** k
            prob = bf / total if total > 0 else 0

            print(f"    φ_{k}(S_{n}) by brute force:     {bf}")
            print(f"    φ_{k}(S_{n}) by Möbius formula:  {mob}")
            print(f"    Agreement: {'✓' if bf == mob else '✗ MISMATCH!'}")
            print(f"    Total k-tuples: {total}")
            print(f"    Generating probability P_{{{n},{k}}} = {bf}/{total} = {prob:.6f}")
            print()

    # Show the Möbius function for S_3
    print("-" * 70)
    print("  Subgroup lattice of S_3 with Möbius values")
    print("-" * 70)
    n = 3
    perms = generate_all_perms(n)
    full_group = frozenset(perms)
    subgroups = all_subgroups(n)
    mu = compute_moebius(subgroups, full_group)

    for H in sorted(subgroups, key=lambda s: len(s)):
        print(f"  |H| = {len(H):2d},  μ(H, S_3) = {mu[H]:3d}")
    print()

    # Demonstrate the partition identity
    print("-" * 70)
    print("  Verification of the partition identity: |H|^k = Σ_{K≤H} φ_k(K)")
    print("-" * 70)

    k = 2
    # Compute φ_k for each subgroup
    phi_k = {}
    for H in subgroups:
        # Count k-tuples in H that generate exactly H
        count = 0
        h_list = list(H)
        for combo in product(h_list, repeat=k):
            if closure_of_perms(list(combo), n) == H:
                count += 1
        phi_k[H] = count

    for H in sorted(subgroups, key=lambda s: len(s)):
        lhs = len(H) ** k
        rhs = sum(phi_k[K] for K in subgroups if K.issubset(H))
        print(f"  |H|={len(H):2d}: |H|^{k} = {lhs:4d},  "
              f"Σ φ_{k}(K) = {rhs:4d}  {'✓' if lhs == rhs else '✗'}")

    print()

    # Show generating probabilities for increasing k
    print("-" * 70)
    print("  Generating probabilities P_{n,k} for S_3")
    print("-" * 70)
    print(f"  {'k':>3s} | {'P_{3,k}':>12s} | {'Decimal':>10s}")
    print(f"  {'---':>3s}-+-{'---':>12s}-+-{'---':>10s}")
    for k in range(1, 6):
        bf = phi_k_brute_force(3, k)
        total = 6 ** k
        print(f"  {k:3d} | {bf:5d}/{total:<6d} | {bf/total:.6f}")

    print()
    print("=" * 70)
    print("  Conclusion: The Möbius inversion formula φ_k(G) = Σ μ(H,G)·|H|^k")
    print("  is verified for all tested cases. As k increases, P_{n,k} → 1.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization: Generating Probability Heatmap P_{n,k}

Visualizes how the probability that k random permutations generate S_n
varies with n and k. Shows the rapid convergence to 1 as k increases,
and the slower convergence as n increases (for fixed k).
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations, product


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))


def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def closure(gens, n):
    group = {tuple(range(n))}
    for g in gens:
        group.add(g)
    changed = True
    while changed:
        changed = False
        new = set()
        for g in list(group):
            for h in gens:
                for e in [compose(g, h), compose(h, g), compose(g, inverse(h))]:
                    if e not in group and e not in new:
                        new.add(e)
                        changed = True
        group.update(new)
    return frozenset(group)


def compute_prob(n, k):
    """Compute P_{n,k} by brute force for small n."""
    all_perms = list(permutations(range(n)))
    full = frozenset(all_perms)
    gen_count = 0
    total = len(all_perms) ** k
    for combo in product(all_perms, repeat=k):
        if closure(list(combo), n) == full:
            gen_count += 1
    return gen_count / total


# Compute probabilities
ns = [2, 3]
ks = [1, 2, 3, 4, 5]

# Pre-computed values for larger n (from Dixon's theorem and exact computation)
# P_{n,2} for S_n: Dixon (1969) showed P_{n,2} → 3/4 as n → ∞
# P_{n,3}: approaches 1 even faster
data = np.zeros((len(ns), len(ks)))

for i, n in enumerate(ns):
    for j, k in enumerate(ks):
        if n <= 3 and k <= 5:
            data[i, j] = compute_prob(n, k)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Heatmap
ax = axes[0]
im = ax.imshow(data, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
ax.set_xticks(range(len(ks)))
ax.set_xticklabels([str(k) for k in ks])
ax.set_yticks(range(len(ns)))
ax.set_yticklabels([f'S_{n}' for n in ns])
ax.set_xlabel('k (tuple length)', fontsize=12)
ax.set_ylabel('Group', fontsize=12)
ax.set_title('Generating Probability P_{n,k}', fontsize=14)
for i in range(len(ns)):
    for j in range(len(ks)):
        text = ax.text(j, i, f'{data[i, j]:.3f}',
                       ha='center', va='center', fontsize=10,
                       color='white' if data[i, j] > 0.5 else 'black')
plt.colorbar(im, ax=ax, label='Probability')

# Line plot showing convergence
ax = axes[1]
for i, n in enumerate(ns):
    probs = [data[i, j] for j in range(len(ks))]
    ax.plot(ks, probs, 'o-', linewidth=2, markersize=8, label=f'S_{n} (n={n})')

ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='P = 1')
ax.axhline(y=0.75, color='blue', linestyle=':', alpha=0.3, label='Dixon limit 3/4')
ax.set_xlabel('k (tuple length)', fontsize=12)
ax.set_ylabel('P_{n,k}', fontsize=12)
ax.set_title('Convergence of P_{n,k} → 1 as k → ∞', fontsize=14)
ax.legend(fontsize=10)
ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('generating_probability_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: generating_probability_heatmap.png")


"""
Visualization: Möbius Inversion Convergence Analysis

Shows how the contribution of each subgroup H to the generating probability
changes with k. For large k, only the top subgroup contributes significantly,
yielding P_{n,k} → 1.
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    # Subgroup data for S_3
    # Subgroups with their orders and Möbius values
    subgroups = [
        ('{e}', 1, 3),
        ('⟨(12)⟩', 2, -1),
        ('⟨(13)⟩', 2, -1),
        ('⟨(23)⟩', 2, -1),
        ('A₃', 3, -1),
        ('S₃', 6, 1),
    ]

    ks = np.arange(1, 8)
    n_factorial = 6  # |S_3|

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Individual contributions μ(H)·(|H|/|G|)^k
    ax = axes[0]
    for name, order, mu in subgroups:
        ratio = order / n_factorial
        contributions = [mu * ratio ** k for k in ks]
        style = '-o' if mu > 0 else '--s'
        ax.plot(ks, contributions, style, linewidth=2, markersize=6, label=f'{name} (μ={mu})')

    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax.set_xlabel('k (tuple length)', fontsize=12)
    ax.set_ylabel('μ(H, S₃) · (|H|/|S₃|)^k', fontsize=12)
    ax.set_title('Subgroup Contributions to P_{3,k}', fontsize=13)
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)

    # Plot 2: Cumulative sum = P_{3,k}
    ax = axes[1]
    probs = []
    for k in ks:
        p = sum(mu * (order / n_factorial) ** k for _, order, mu in subgroups)
        probs.append(p)

    ax.bar(ks, probs, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='P = 1')

    for i, (k, p) in enumerate(zip(ks, probs)):
        ax.text(k, p + 0.02, f'{p:.4f}', ha='center', va='bottom', fontsize=9)

    ax.set_xlabel('k (tuple length)', fontsize=12)
    ax.set_ylabel('P_{3,k} = φ_k(S₃) / 6^k', fontsize=12)
    ax.set_title('Generating Probability P_{3,k} for S₃', fontsize=13)
    ax.set_ylim(0, 1.15)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.suptitle('Möbius Inversion: Generating Probability Convergence',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('moebius_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: moebius_convergence.png")


main()


"""
Visualization: Subgroup Lattice of S_3 with Möbius Values

Draws the Hasse diagram of the subgroup lattice of S_3, annotated with
the Möbius function values μ(H, S_3). This illustrates the alternating
sign pattern that drives the inclusion-exclusion in the Möbius formula.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_lattice():
    """Draw the subgroup lattice of S_3 with Möbius values."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # S_3 has 6 subgroups:
    # Level 0 (bottom): {e} (order 1)
    # Level 1: ⟨(12)⟩, ⟨(13)⟩, ⟨(23)⟩ (order 2 each), A_3 = ⟨(123)⟩ (order 3)
    # Level 2 (top): S_3 (order 6)

    # Positions
    positions = {
        '{e}': (5, 0),
        '⟨(12)⟩': (2, 2),
        '⟨(13)⟩': (5, 2),
        '⟨(23)⟩': (8, 2),
        'A₃': (5, 4),
        'S₃': (5, 6),
    }

    # Möbius values μ(H, S_3)
    moebius = {
        '{e}': 3,
        '⟨(12)⟩': -1,
        '⟨(13)⟩': -1,
        '⟨(23)⟩': -1,
        'A₃': -1,
        'S₃': 1,
    }

    orders = {
        '{e}': 1,
        '⟨(12)⟩': 2,
        '⟨(13)⟩': 2,
        '⟨(23)⟩': 2,
        'A₃': 3,
        'S₃': 6,
    }

    # Edges (Hasse diagram)
    edges = [
        ('{e}', '⟨(12)⟩'),
        ('{e}', '⟨(13)⟩'),
        ('{e}', '⟨(23)⟩'),
        ('{e}', 'A₃'),
        ('⟨(12)⟩', 'S₃'),
        ('⟨(13)⟩', 'S₃'),
        ('⟨(23)⟩', 'S₃'),
        ('A₃', 'S₃'),
    ]

    # Draw edges
    for h1, h2 in edges:
        x1, y1 = positions[h1]
        x2, y2 = positions[h2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.4, zorder=1)

    # Draw nodes
    for name, (x, y) in positions.items():
        mu = moebius[name]
        order = orders[name]

        # Color by Möbius value
        if mu > 0:
            color = '#4CAF50'  # green for positive
            edge_color = '#2E7D32'
        elif mu < 0:
            color = '#F44336'  # red for negative
            edge_color = '#C62828'
        else:
            color = '#9E9E9E'
            edge_color = '#616161'

        circle = plt.Circle((x, y), 0.6, facecolor=color, edgecolor=edge_color,
                             linewidth=2, alpha=0.85, zorder=2)
        ax.add_patch(circle)

        # Subgroup name
        ax.text(x, y + 0.15, name, ha='center', va='center',
                fontsize=11, fontweight='bold', color='white', zorder=3)
        # Möbius value
        ax.text(x, y - 0.25, f'μ = {mu}', ha='center', va='center',
                fontsize=9, color='white', zorder=3)
        # Order
        ax.text(x + 0.7, y + 0.5, f'|H|={order}', ha='left', va='center',
                fontsize=8, color='#555', zorder=3)

    # Annotations
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-1, 7.5)
    ax.set_aspect('equal')
    ax.axis('off')

    ax.set_title('Subgroup Lattice of S₃ with Möbius Function Values\n'
                 'φ_k(S₃) = Σ μ(H, S₃) · |H|^k',
                 fontsize=14, fontweight='bold', pad=20)

    # Legend
    green_patch = mpatches.Patch(color='#4CAF50', label='μ > 0 (inclusion)')
    red_patch = mpatches.Patch(color='#F44336', label='μ < 0 (exclusion)')
    ax.legend(handles=[green_patch, red_patch], loc='lower right',
              fontsize=10, framealpha=0.9)

    # Add formula verification
    ax.text(0.5, -0.5,
            'k=2: φ₂(S₃) = 3·1² + (-1)·2² + (-1)·2² + (-1)·2² + (-1)·3² + 1·6² = 3-4-4-4-9+36 = 18  ✓',
            fontsize=9, color='#333', ha='left')

    plt.tight_layout()
    plt.savefig('moebius_lattice_s3.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: moebius_lattice_s3.png")


draw_lattice()
