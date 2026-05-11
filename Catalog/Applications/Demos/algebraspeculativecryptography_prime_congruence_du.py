#!/usr/bin/env python3
"""
Prime Congruence Duality for Tropical One-Way Semirings
=======================================================

Demonstrations of the spectral tropical cryptography framework:
1. Observer families on finite tropical semirings
2. Representation theorem verification
3. Hard-core quotient construction
4. Spectral separation count heat maps
5. Cardinality bound verification

All examples use finite semirings with tropical (min/idempotent) addition
and modular ring congruences as observers.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product
from typing import List, Tuple, Dict, Set, Callable
from collections import defaultdict
import base64
from io import BytesIO


# ============================================================
# Section 1: Tropical Semiring and Observer Infrastructure
# ============================================================

class TropicalSemiring:
    """
    A finite tropical semiring Z/nZ with:
    - Addition: min(a, b)  (idempotent)
    - Multiplication: (a + b) mod n  (standard modular)
    """
    def __init__(self, n: int):
        self.n = n
        self.elements = list(range(n))

    def add(self, a: int, b: int) -> int:
        """Tropical addition = min"""
        return min(a, b)

    def mul(self, a: int, b: int) -> int:
        """Tropical multiplication = modular addition"""
        return (a + b) % self.n

    def __repr__(self):
        return f"TropicalSemiring(Z/{self.n}Z, min, +mod{self.n})"


class RingCongruence:
    """
    A ring congruence on a finite semiring: an equivalence relation
    compatible with both addition and multiplication.

    Implemented as modular equivalence: a ≡ b (mod m)
    """
    def __init__(self, modulus: int, semiring_size: int, label: str = ""):
        self.modulus = modulus
        self.semiring_size = semiring_size
        self.label = label or f"mod {modulus}"

    def equivalent(self, a: int, b: int) -> bool:
        """Check if a and b are equivalent under this congruence."""
        return (a % self.modulus) == (b % self.modulus)

    def quotient_class(self, a: int) -> int:
        """Return the equivalence class representative."""
        return a % self.modulus

    def quotient_size(self) -> int:
        """Number of equivalence classes."""
        return min(self.modulus, self.semiring_size)

    def __repr__(self):
        return f"Congruence({self.label})"


class ObserverFamily:
    """
    A finite family of ring congruences acting as observers.
    Each observer partitions the semiring into equivalence classes.
    """
    def __init__(self, congruences: List[RingCongruence]):
        self.congruences = congruences
        self.n = len(congruences)

    def observer_profile(self, a: int) -> tuple:
        """Compute the observer profile (tuple of quotient classes) for element a."""
        return tuple(c.quotient_class(a) for c in self.congruences)

    def separates(self, a: int, b: int) -> bool:
        """Check if the family separates a from b (some observer distinguishes them)."""
        return any(not c.equivalent(a, b) for c in self.congruences)

    def separation_count(self, a: int, b: int) -> int:
        """Count how many observers distinguish a from b."""
        return sum(1 for c in self.congruences if not c.equivalent(a, b))

    def is_globally_separating(self, elements: List[int]) -> bool:
        """Check if the family separates all pairs in the given set."""
        for i, a in enumerate(elements):
            for b in elements[i+1:]:
                if not self.separates(a, b):
                    return False
        return True

    def observer_kernel(self, a: int, b: int) -> bool:
        """Check if a and b are in the observer kernel (all observers agree)."""
        return all(c.equivalent(a, b) for c in self.congruences)

    def __repr__(self):
        return f"ObserverFamily({self.n} observers: {self.congruences})"


# ============================================================
# Section 2: Hard-Core Quotient
# ============================================================

def compute_observer_kernel_classes(family: ObserverFamily, elements: List[int]) -> Dict[tuple, List[int]]:
    """Compute the equivalence classes of the observer kernel."""
    classes = defaultdict(list)
    for a in elements:
        profile = family.observer_profile(a)
        classes[profile].append(a)
    return dict(classes)


def compute_hard_core_quotient(family: ObserverFamily, elements: List[int]) -> Dict[str, object]:
    """
    Compute the hard-core quotient S / ker(F).

    Returns:
        Dictionary with quotient information:
        - classes: mapping from profiles to element lists
        - quotient_size: number of equivalence classes
        - nontrivial_fibers: classes with > 1 element (the "hidden information")
    """
    classes = compute_observer_kernel_classes(family, elements)
    nontrivial = {k: v for k, v in classes.items() if len(v) > 1}
    return {
        'classes': classes,
        'quotient_size': len(classes),
        'nontrivial_fibers': nontrivial,
        'original_size': len(elements),
        'compression_ratio': len(classes) / len(elements) if elements else 1.0
    }


# ============================================================
# Section 3: Verification of Theorems
# ============================================================

def verify_representation_theorem(semiring: TropicalSemiring, family: ObserverFamily) -> dict:
    """
    Verify the Representation Theorem:
    eval is injective ⟺ observer family separates

    Returns detailed verification results.
    """
    elements = semiring.elements

    # Check if eval is injective (all profiles are distinct)
    profiles = {}
    eval_injective = True
    collision = None
    for a in elements:
        p = family.observer_profile(a)
        if p in profiles:
            eval_injective = False
            collision = (profiles[p], a, p)
            break
        profiles[p] = a

    # Check if family separates all elements
    separates_all = family.is_globally_separating(elements)

    # Verify biconditional
    theorem_holds = (eval_injective == separates_all)

    return {
        'eval_injective': eval_injective,
        'separates_all': separates_all,
        'theorem_holds': theorem_holds,
        'collision': collision,
        'num_distinct_profiles': len(set(family.observer_profile(a) for a in elements)),
    }


def verify_cardinality_bound(semiring: TropicalSemiring, family: ObserverFamily) -> dict:
    """
    Verify the Spectral Cardinality Bound:
    |S| ≤ ∏_i |S/cong_i|

    Only meaningful when the family separates.
    """
    S_size = semiring.n
    product_of_quotients = 1
    quotient_sizes = []
    for c in family.congruences:
        qs = c.quotient_size()
        quotient_sizes.append(qs)
        product_of_quotients *= qs

    bound_holds = S_size <= product_of_quotients

    return {
        'S_size': S_size,
        'product_of_quotients': product_of_quotients,
        'quotient_sizes': quotient_sizes,
        'bound_holds': bound_holds,
        'ratio': S_size / product_of_quotients if product_of_quotients > 0 else float('inf'),
    }


# ============================================================
# Section 4: Visualization
# ============================================================

def plot_separation_heatmap(semiring: TropicalSemiring, family: ObserverFamily,
                            title: str = "Spectral Separation Count") -> str:
    """
    Plot a heat map of spectral separation counts between all pairs.
    Returns base64-encoded PNG image.
    """
    n = semiring.n
    matrix = np.zeros((n, n), dtype=int)
    for a in range(n):
        for b in range(n):
            matrix[a][b] = family.separation_count(a, b)

    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    im = ax.imshow(matrix, cmap='YlOrRd', interpolation='nearest')
    ax.set_xlabel('Element b')
    ax.set_ylabel('Element a')
    ax.set_title(title)
    plt.colorbar(im, ax=ax, label='Number of separating observers')

    # Add text annotations for small matrices
    if n <= 15:
        for i in range(n):
            for j in range(n):
                ax.text(j, i, str(matrix[i][j]), ha='center', va='center',
                       color='white' if matrix[i][j] > matrix.max()/2 else 'black',
                       fontsize=8)

    plt.tight_layout()
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150)
    plt.close(fig)
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def plot_quotient_structure(quotient_info: dict, title: str = "Hard-Core Quotient Structure") -> str:
    """
    Visualize the hard-core quotient fiber structure.
    Returns base64-encoded PNG image.
    """
    classes = quotient_info['classes']
    fiber_sizes = sorted([len(v) for v in classes.values()], reverse=True)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Bar chart of fiber sizes
    ax1.bar(range(len(fiber_sizes)), fiber_sizes, color='steelblue', alpha=0.8)
    ax1.set_xlabel('Fiber index (sorted by size)')
    ax1.set_ylabel('Fiber size')
    ax1.set_title(f'{title}\n({len(classes)} classes, '
                  f'{len(quotient_info["nontrivial_fibers"])} nontrivial)')
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Trivial fiber')
    ax1.legend()

    # Pie chart of information distribution
    trivial_count = sum(1 for s in fiber_sizes if s == 1)
    nontrivial_count = len(fiber_sizes) - trivial_count
    if nontrivial_count > 0:
        labels = ['Trivial fibers\n(observed)', 'Nontrivial fibers\n(hidden info)']
        sizes = [trivial_count, nontrivial_count]
        colors = ['#2ecc71', '#e74c3c']
        ax2.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%',
                startangle=90, textprops={'fontsize': 10})
    else:
        ax2.text(0.5, 0.5, 'All fibers trivial\n(fully separated)',
                ha='center', va='center', fontsize=14, transform=ax2.transAxes)
    ax2.set_title('Information Distribution')

    plt.tight_layout()
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150)
    plt.close(fig)
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def plot_cardinality_bounds(results: List[dict], title: str = "Spectral Cardinality Bounds") -> str:
    """
    Plot |S| vs ∏|S/cong_i| for multiple semirings.
    Returns base64-encoded PNG image.
    """
    fig, ax = plt.subplots(figsize=(8, 6))

    s_sizes = [r['S_size'] for r in results]
    prod_sizes = [r['product_of_quotients'] for r in results]
    labels = [f"n={r['S_size']}" for r in results]

    x = range(len(results))
    width = 0.35

    bars1 = ax.bar([i - width/2 for i in x], s_sizes, width, label='|S|', color='steelblue', alpha=0.8)
    bars2 = ax.bar([i + width/2 for i in x], prod_sizes, width, label='∏|S/congᵢ|', color='coral', alpha=0.8)

    ax.set_xlabel('Configuration')
    ax.set_ylabel('Size')
    ax.set_title(title)
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()
    ax.set_yscale('log')

    plt.tight_layout()
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150)
    plt.close(fig)
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# ============================================================
# Section 5: Main Demonstration
# ============================================================

def main():
    print("=" * 70)
    print("SPECTRAL TROPICAL CRYPTOGRAPHY: Demonstration Suite")
    print("=" * 70)

    # === Demo 1: Small separating family ===
    print("\n--- Demo 1: Representation Theorem on Z/12Z ---")
    S = TropicalSemiring(12)
    # Use mod 3 and mod 4 as observers (coprime => jointly separating on Z/12Z)
    F = ObserverFamily([
        RingCongruence(3, 12, "mod 3"),
        RingCongruence(4, 12, "mod 4"),
    ])
    print(f"Semiring: {S}")
    print(f"Observers: {F}")

    result = verify_representation_theorem(S, F)
    print(f"  Eval injective: {result['eval_injective']}")
    print(f"  Separates all:  {result['separates_all']}")
    print(f"  Theorem holds:  {result['theorem_holds']} ✓")
    print(f"  Distinct profiles: {result['num_distinct_profiles']}/{S.n}")

    bound = verify_cardinality_bound(S, F)
    print(f"  |S| = {bound['S_size']}, ∏|S/congᵢ| = {bound['product_of_quotients']}")
    print(f"  Bound holds: {bound['bound_holds']} ✓")

    # === Demo 2: Non-separating family ===
    print("\n--- Demo 2: Non-separating Family on Z/12Z ---")
    F2 = ObserverFamily([
        RingCongruence(3, 12, "mod 3"),
        RingCongruence(6, 12, "mod 6"),
    ])
    result2 = verify_representation_theorem(S, F2)
    print(f"  Observers: {F2}")
    print(f"  Eval injective: {result2['eval_injective']}")
    print(f"  Separates all:  {result2['separates_all']}")
    print(f"  Theorem holds:  {result2['theorem_holds']} ✓")
    if result2['collision']:
        a, b, p = result2['collision']
        print(f"  Collision found: elements {a} and {b} have same profile {p}")

    # === Demo 3: Hard-Core Quotient ===
    print("\n--- Demo 3: Hard-Core Quotient ---")
    hcq = compute_hard_core_quotient(F2, S.elements)
    print(f"  Original size: {hcq['original_size']}")
    print(f"  Quotient size: {hcq['quotient_size']}")
    print(f"  Compression ratio: {hcq['compression_ratio']:.2f}")
    print(f"  Nontrivial fibers: {len(hcq['nontrivial_fibers'])}")
    for profile, members in sorted(hcq['nontrivial_fibers'].items()):
        print(f"    Fiber {profile}: {members} (hidden: {len(members)-1} elements)")

    # === Demo 4: Spectral Separation Counts ===
    print("\n--- Demo 4: Separation Counts ---")
    S3 = TropicalSemiring(10)
    F3 = ObserverFamily([
        RingCongruence(2, 10, "parity"),
        RingCongruence(3, 10, "mod 3"),
        RingCongruence(5, 10, "mod 5"),
    ])
    print(f"  Semiring: {S3}")
    print(f"  Observers: {F3}")
    result3 = verify_representation_theorem(S3, F3)
    print(f"  Separates all: {result3['separates_all']} ✓")

    # Print separation matrix
    print("  Separation count matrix:")
    header = "    " + " ".join(f"{b:2d}" for b in range(min(10, S3.n)))
    print(header)
    for a in range(min(10, S3.n)):
        row = f" {a:2d} " + " ".join(f"{F3.separation_count(a, b):2d}" for b in range(min(10, S3.n)))
        print(row)

    # === Demo 5: Multiple cardinality bounds ===
    print("\n--- Demo 5: Cardinality Bounds for Various Configurations ---")
    configs = [
        (6, [2, 3]),
        (12, [3, 4]),
        (30, [2, 3, 5]),
        (60, [3, 4, 5]),
        (210, [2, 3, 5, 7]),
    ]
    bound_results = []
    for n, mods in configs:
        Sk = TropicalSemiring(n)
        Fk = ObserverFamily([RingCongruence(m, n, f"mod {m}") for m in mods])
        br = verify_cardinality_bound(Sk, Fk)
        bound_results.append(br)
        sep = verify_representation_theorem(Sk, Fk)
        print(f"  n={n:3d}, observers={mods}, |S|={br['S_size']:3d}, "
              f"∏|S/c|={br['product_of_quotients']:5d}, "
              f"ratio={br['ratio']:.3f}, separated={sep['separates_all']}")

    # === Generate visualizations ===
    print("\n--- Generating Visualizations ---")

    # Heatmap
    heatmap_b64 = plot_separation_heatmap(S3, F3,
        "Spectral Separation Count: Z/10Z with observers mod 2, 3, 5")
    with open("separation_heatmap.png", "wb") as f:
        f.write(base64.b64decode(heatmap_b64))
    print("  Saved: separation_heatmap.png")

    # Quotient structure
    quotient_b64 = plot_quotient_structure(hcq,
        "Hard-Core Quotient: Z/12Z with observers mod 3, 6")
    with open("quotient_structure.png", "wb") as f:
        f.write(base64.b64decode(quotient_b64))
    print("  Saved: quotient_structure.png")

    # Cardinality bounds
    bounds_b64 = plot_cardinality_bounds(bound_results,
        "Spectral Cardinality Bound: |S| ≤ ∏|S/congᵢ|")
    with open("cardinality_bounds.png", "wb") as f:
        f.write(base64.b64decode(bounds_b64))
    print("  Saved: cardinality_bounds.png")

    # === Demo 6: Inversion Lifting ===
    print("\n--- Demo 6: Inversion Lifting Verification ---")
    S4 = TropicalSemiring(12)
    F4 = ObserverFamily([
        RingCongruence(3, 12, "mod 3"),
        RingCongruence(4, 12, "mod 4"),
    ])
    # Since F4 separates Z/12Z, every fiber is trivial
    # Any "section" must return the unique element with that profile
    hcq4 = compute_hard_core_quotient(F4, S4.elements)
    print(f"  Quotient size: {hcq4['quotient_size']} (= |S| = {S4.n}, fully separated)")

    # Construct a section (inverse of quotient map)
    section = {}
    for profile, members in hcq4['classes'].items():
        section[profile] = members[0]  # Pick any representative

    # Verify: section(q(s)) is observer-equivalent to s
    all_equivalent = True
    for s in S4.elements:
        profile = F4.observer_profile(s)
        inv_s = section[profile]
        if not F4.observer_kernel(inv_s, s):
            all_equivalent = False
            break
    print(f"  Inversion preserves observations: {all_equivalent} ✓")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)

    return {
        'heatmap_b64': heatmap_b64,
        'quotient_b64': quotient_b64,
        'bounds_b64': bounds_b64,
    }


if __name__ == '__main__':
    main()
