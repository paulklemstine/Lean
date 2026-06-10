#!/usr/bin/env python3
"""
Stone Duality for Ultrametric Proof Semirings — Demonstrations

This module demonstrates the core constructions of the proof semiring
Stone duality theory with concrete numerical examples:
1. Observer families and CodeEq on Z/nZ
2. Spectral evaluation and injectivity
3. Ultrametric distance from agreement depth
4. Visualization of spectral trees
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations
from typing import List, Tuple, Set, Dict, Callable
import json
import base64
from io import BytesIO


# ============================================================
# Section 1: Ring Congruences on Z/nZ
# ============================================================

class RingCongruence:
    """A ring congruence on Z/nZ, represented by its modulus divisor."""

    def __init__(self, n: int, divisor: int):
        """
        Create a congruence on Z/nZ that identifies a ≡ b iff a ≡ b (mod divisor).
        The divisor must divide n.
        """
        assert n % divisor == 0, f"{divisor} does not divide {n}"
        self.n = n
        self.divisor = divisor

    def equiv(self, a: int, b: int) -> bool:
        """Check if a and b are equivalent under this congruence."""
        return (a - b) % self.divisor == 0

    def quotient_class(self, a: int) -> int:
        """Return the equivalence class of a."""
        return a % self.divisor

    def num_classes(self) -> int:
        """Number of equivalence classes."""
        return self.divisor

    def is_nontrivial(self) -> bool:
        """A congruence is nontrivial if it doesn't identify everything."""
        return self.divisor > 1

    def __repr__(self):
        return f"RingCon(Z/{self.n}Z, mod {self.divisor})"


class ObserverFamily:
    """A finite family of ring congruences acting as observers."""

    def __init__(self, n: int, divisors: List[int]):
        self.n = n
        self.observers = [RingCongruence(n, d) for d in divisors]

    def code_eq(self, a: int, b: int) -> bool:
        """Check if all observers identify a with b."""
        return all(obs.equiv(a, b) for obs in self.observers)

    def spectral_eval(self, a: int) -> Tuple[int, ...]:
        """Compute the spectral evaluation: tuple of quotient classes."""
        return tuple(obs.quotient_class(a) for obs in self.observers)

    def separates(self, a: int, b: int) -> bool:
        """Check if some observer distinguishes a from b."""
        return any(not obs.equiv(a, b) for obs in self.observers)

    def diagonal_avoids(self, T: Set[int]) -> bool:
        """Check diagonal avoidance on T."""
        for a, b in combinations(T, 2):
            if not self.separates(a, b):
                return False
        return True


def demo_observer_families():
    """Demonstrate observer families on Z/12Z."""
    print("=" * 60)
    print("Demo 1: Observer Families on Z/12Z")
    print("=" * 60)

    n = 12
    # Divisors of 12: 1, 2, 3, 4, 6, 12
    # Nontrivial congruences: mod 2, mod 3, mod 4, mod 6
    family = ObserverFamily(n, [2, 3, 4])
    T = set(range(n))

    print(f"\nSemiring: Z/{n}Z")
    print(f"Observers: mod 2, mod 3, mod 4")
    print(f"Number of observers: {len(family.observers)}")

    print(f"\nDiagonal avoidance on {{0,...,11}}: {family.diagonal_avoids(T)}")

    print("\nSpectral evaluation (a → quotient tuple):")
    for a in range(n):
        profile = family.spectral_eval(a)
        print(f"  {a:2d} → {profile}")

    # Check injectivity
    profiles = {}
    for a in range(n):
        p = family.spectral_eval(a)
        if p in profiles:
            print(f"\n  Collision: {a} and {profiles[p]} have same profile {p}")
            print(f"  CodeEq({a}, {profiles[p]}) = {family.code_eq(a, profiles[p])}")
        else:
            profiles[p] = a

    distinct = len(set(family.spectral_eval(a) for a in range(n)))
    print(f"\nDistinct profiles: {distinct} (= elements mod CodeEq)")
    print(f"Injective: {distinct == n}")

    # Try with full separation
    family_full = ObserverFamily(n, [2, 3, 4, 6])
    distinct_full = len(set(family_full.spectral_eval(a) for a in range(n)))
    print(f"\nWith observers mod 2,3,4,6:")
    print(f"  Distinct profiles: {distinct_full}")
    print(f"  Injective: {distinct_full == n}")

    return family


# ============================================================
# Section 2: Ultrametric Distance
# ============================================================

def agreement_depth(profile1: Tuple, profile2: Tuple) -> int:
    """Compute the first index of disagreement between two profiles."""
    for i in range(len(profile1)):
        if profile1[i] != profile2[i]:
            return i
    return len(profile1)


def observer_dist(profile1: Tuple, profile2: Tuple) -> float:
    """Compute the ultrametric distance between two observer profiles."""
    depth = agreement_depth(profile1, profile2)
    if depth == len(profile1):
        return 0.0
    return 0.5 ** depth


def demo_ultrametric():
    """Demonstrate the ultrametric distance on the spectrum."""
    print("\n" + "=" * 60)
    print("Demo 2: Ultrametric Distance on Proof Spectrum")
    print("=" * 60)

    n = 12
    family = ObserverFamily(n, [2, 3, 4])

    profiles = [family.spectral_eval(a) for a in range(n)]

    # Compute distance matrix
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = observer_dist(profiles[i], profiles[j])

    print("\nDistance matrix (first 6 elements):")
    print("     ", "  ".join(f"{i:5d}" for i in range(6)))
    for i in range(6):
        row = " ".join(f"{dist_matrix[i,j]:5.3f}" for j in range(6))
        print(f"  {i}: {row}")

    # Verify ultrametric inequality
    violations = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if dist_matrix[i, k] > max(dist_matrix[i, j], dist_matrix[j, k]) + 1e-10:
                    violations += 1

    print(f"\nUltrametric inequality violations: {violations}")
    print(f"Ultrametric verified: {violations == 0}")

    # Show isosceles triangles
    print("\nIsosceles triangle examples:")
    count = 0
    for i, j, k in combinations(range(n), 3):
        d_ij = dist_matrix[i, j]
        d_jk = dist_matrix[j, k]
        d_ik = dist_matrix[i, k]
        sides = sorted([d_ij, d_jk, d_ik])
        if sides[0] < sides[1] == sides[2] and count < 5:
            print(f"  d({i},{j})={d_ij:.3f}, d({j},{k})={d_jk:.3f}, d({i},{k})={d_ik:.3f}")
            count += 1

    return dist_matrix, profiles


# ============================================================
# Section 3: Spectral Evaluation Injectivity
# ============================================================

def demo_reconstruction():
    """Demonstrate the reconstruction theorem."""
    print("\n" + "=" * 60)
    print("Demo 3: Reconstruction Theorem")
    print("=" * 60)

    # Example: Z/30Z with observers mod 2, 3, 5
    n = 30
    family = ObserverFamily(n, [2, 3, 5])

    profiles = {a: family.spectral_eval(a) for a in range(n)}

    # Check injectivity
    profile_to_elements: Dict[Tuple, List[int]] = {}
    for a, p in profiles.items():
        profile_to_elements.setdefault(p, []).append(a)

    print(f"\nSemiring: Z/{n}Z")
    print(f"Observers: mod 2, mod 3, mod 5")
    print(f"Product size: 2 × 3 × 5 = {2*3*5}")
    print(f"Semiring size: {n}")
    print(f"Distinct profiles: {len(profile_to_elements)}")
    print(f"Injective (mod CodeEq): {all(len(v) == 1 for v in profile_to_elements.values())}")

    # Show the CodeEq classes (fibers of the evaluation map)
    multi_element_classes = {k: v for k, v in profile_to_elements.items() if len(v) > 1}
    if multi_element_classes:
        print(f"\nCodeEq classes (non-singleton):")
        for profile, elements in multi_element_classes.items():
            print(f"  Profile {profile}: elements {elements}")
    else:
        print(f"\nAll CodeEq classes are singletons — evaluation is fully injective!")

    # Now try with CRT-complete family
    # For Z/30Z = Z/2Z × Z/3Z × Z/5Z, observers mod 2,3,5 give CRT isomorphism
    print(f"\nBy CRT: Z/30Z ≅ Z/2Z × Z/3Z × Z/5Z")
    print(f"The spectral evaluation IS the CRT isomorphism!")


# ============================================================
# Section 4: Functoriality (specMap)
# ============================================================

def demo_functoriality():
    """Demonstrate the specMap construction."""
    print("\n" + "=" * 60)
    print("Demo 4: Functoriality — specMap")
    print("=" * 60)

    # Ring homomorphism Z/12Z → Z/6Z (reduction mod 6)
    print("\nRing homomorphism φ: Z/12Z → Z/6Z (reduce mod 6)")
    print("This is surjective.")

    # Observers on Z/6Z: mod 2, mod 3
    # Pullback: observers on Z/12Z: mod 2, mod 3 (same divisors)
    print("\nObservers on Z/6Z: mod 2, mod 3")
    print("Pullback observers on Z/12Z: mod 2, mod 3")
    print("(Pullback: c.comap(φ)(a,b) = c(φ(a), φ(b)) = c(a mod 6, b mod 6))")

    # Verify the pullback preserves separation
    source_family = ObserverFamily(12, [2, 3])
    target_family = ObserverFamily(6, [2, 3])

    print(f"\nSpectra:")
    print(f"  ProofSpectrum(Z/6Z): {len([d for d in [2, 3] if d > 1])} observers")
    print(f"  ProofSpectrum(Z/12Z): same 2 observers (via pullback)")

    # Show that specMap preserves basic opens
    print(f"\nPreimage of D(1,0) in Z/12Z-spectrum = D(φ(1), φ(0)) in Z/6Z-spectrum")
    print(f"  = D(1, 0) in Z/6Z-spectrum")
    print(f"  Both are {{obs | obs doesn't identify 1 with 0}}")


# ============================================================
# Section 5: Visualizations
# ============================================================

def create_spectral_tree_visualization(n: int, divisors: List[int]) -> str:
    """Create a tree visualization of the ultrametric spectrum."""
    family = ObserverFamily(n, divisors)
    profiles = [family.spectral_eval(a) for a in range(n)]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Distance matrix heatmap
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = observer_dist(profiles[i], profiles[j])

    im = axes[0].imshow(dist_matrix, cmap='viridis_r', interpolation='nearest')
    axes[0].set_title(f'Ultrametric Distance Matrix\nZ/{n}Z with observers mod {divisors}')
    axes[0].set_xlabel('Element')
    axes[0].set_ylabel('Element')
    plt.colorbar(im, ax=axes[0], label='Distance')

    # Right: Profile distribution
    unique_profiles = list(set(profiles))
    unique_profiles.sort()
    profile_counts = [profiles.count(p) for p in unique_profiles]

    x_pos = range(len(unique_profiles))
    axes[1].bar(x_pos, profile_counts, color='steelblue', edgecolor='navy')
    axes[1].set_title('Spectral Profile Distribution')
    axes[1].set_xlabel('Profile Index')
    axes[1].set_ylabel('Number of Elements')
    axes[1].set_xticks(x_pos)
    axes[1].set_xticklabels([str(p) for p in unique_profiles], rotation=45, ha='right', fontsize=7)

    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=100, bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def create_ultrametric_tree_plot(n: int, divisors: List[int]) -> str:
    """Create a dendrogram-style plot of the ultrametric clustering."""
    family = ObserverFamily(n, divisors)
    profiles = [family.spectral_eval(a) for a in range(n)]

    # Build hierarchical clustering from ultrametric
    from scipy.cluster.hierarchy import linkage, dendrogram

    # Compute condensed distance matrix
    dist_condensed = []
    for i in range(n):
        for j in range(i+1, n):
            dist_condensed.append(observer_dist(profiles[i], profiles[j]))

    dist_condensed = np.array(dist_condensed)

    fig, ax = plt.subplots(1, 1, figsize=(12, 5))

    if len(dist_condensed) > 0 and np.any(dist_condensed > 0):
        Z = linkage(dist_condensed, method='complete')
        dendrogram(Z, labels=list(range(n)), ax=ax, leaf_font_size=8)
        ax.set_title(f'Ultrametric Dendrogram of Z/{n}Z\nObservers: mod {divisors}')
        ax.set_ylabel('Observer Distance')
        ax.set_xlabel('Semiring Element')
    else:
        ax.text(0.5, 0.5, 'All distances zero\n(perfect identification)',
                ha='center', va='center', transform=ax.transAxes, fontsize=14)

    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=100, bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


def create_separation_diagram(n: int, divisors: List[int]) -> str:
    """Visualize which pairs are separated by each observer."""
    family = ObserverFamily(n, divisors)

    fig, axes = plt.subplots(1, len(divisors), figsize=(5*len(divisors), 4))
    if len(divisors) == 1:
        axes = [axes]

    for idx, (obs, div) in enumerate(zip(family.observers, divisors)):
        separation = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                separation[i, j] = 0 if obs.equiv(i, j) else 1

        axes[idx].imshow(separation, cmap='RdYlGn_r', interpolation='nearest',
                        vmin=0, vmax=1)
        axes[idx].set_title(f'Observer mod {div}\n(red = separated)')
        axes[idx].set_xlabel('Element')
        axes[idx].set_ylabel('Element')

    plt.suptitle(f'Separation by Individual Observers on Z/{n}Z', fontsize=13)
    plt.tight_layout()

    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=100, bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("Stone Duality for Ultrametric Proof Semirings")
    print("Concrete Demonstrations")
    print("=" * 60)

    family = demo_observer_families()
    dist_matrix, profiles = demo_ultrametric()
    demo_reconstruction()
    demo_functoriality()

    # Generate visualizations
    print("\n" + "=" * 60)
    print("Generating visualizations...")

    img1 = create_spectral_tree_visualization(12, [2, 3, 4])
    print("  ✓ Spectral tree visualization (Z/12Z)")

    img2 = create_ultrametric_tree_plot(12, [2, 3, 4])
    print("  ✓ Ultrametric dendrogram (Z/12Z)")

    img3 = create_separation_diagram(12, [2, 3, 4])
    print("  ✓ Observer separation diagram")

    img4 = create_spectral_tree_visualization(30, [2, 3, 5])
    print("  ✓ CRT reconstruction visualization (Z/30Z)")

    # Save visualization data
    viz_data = {
        'spectral_tree_z12': img1,
        'dendrogram_z12': img2,
        'separation_z12': img3,
        'spectral_tree_z30': img4,
    }

    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)

    print("\nAll demonstrations complete.")
    print("Visualization data saved to viz_data.json")
