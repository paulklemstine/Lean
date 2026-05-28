#!/usr/bin/env python3
"""
Applications of Primewise Birth Spectra

Demonstrates real-world applications of the primewise birth spectrum theory:
1. Persistent homology torsion analysis
2. Signal classification via spectral signatures
3. Filtration comparison and distance metrics
"""

from typing import Dict, List, Set, Tuple
from math import log2, sqrt


# ---------- Inline core functions ----------

def prime_factors(n: int) -> Set[int]:
    if n <= 1:
        return set()
    factors = set()
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors.add(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.add(temp)
    return factors


class BirthProfile:
    def __init__(self, orders_at: Dict[int, Set[int]]):
        self.orders_at = {k: set(v) for k, v in orders_at.items()}

    def __repr__(self):
        nonempty = {k: v for k, v in sorted(self.orders_at.items()) if v}
        return f"BirthProfile({nonempty})"


def global_torsion_birth_set(F: BirthProfile) -> Set[int]:
    return {level for level, orders in F.orders_at.items()
            if any(m > 1 for m in orders)}


def p_torsion_birth_set(p: int, F: BirthProfile) -> Set[int]:
    return {level for level, orders in F.orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}


# ---------- Application 1: Persistent Homology Torsion Fingerprinting ----------

class TorsionFingerprint:
    """A prime-resolved fingerprint for filtered chain complexes.

    In persistent homology, torsion in homology groups carries algebraic
    information beyond Betti numbers. This fingerprint captures WHEN
    each prime appears in the torsion, providing a finer invariant
    than merely recording which torsion groups are present.
    """

    def __init__(self, profile: BirthProfile, primes: List[int]):
        self.profile = profile
        self.primes = primes
        self.spectrum = {p: p_torsion_birth_set(p, profile) for p in primes}
        self.global_set = global_torsion_birth_set(profile)

    def signature_vector(self) -> List[int]:
        """Encode the fingerprint as a fixed-length integer vector.

        Each prime contributes a bitmask of birth levels.
        """
        max_level = max(max(self.profile.orders_at.keys(), default=0), 0)
        vec = []
        for p in self.primes:
            bits = 0
            for level in self.spectrum[p]:
                if level <= max_level:
                    bits |= (1 << level)
            vec.append(bits)
        return vec

    def distance(self, other: 'TorsionFingerprint') -> float:
        """Hamming-style distance between two fingerprints."""
        v1 = self.signature_vector()
        v2 = other.signature_vector()
        assert len(v1) == len(v2)
        d = sum(bin(a ^ b).count('1') for a, b in zip(v1, v2))
        return d

    def __repr__(self):
        return f"TorsionFingerprint(global={sorted(self.global_set)}, spectrum={self.spectrum})"


def demo_fingerprinting():
    """Demonstrate torsion fingerprinting for space classification."""
    print("=" * 70)
    print("APPLICATION 1: Persistent Homology Torsion Fingerprinting")
    print("=" * 70)
    print()

    # Three filtered spaces with different torsion chronologies
    spaces = {
        "Space A (lens space L(6,1))": BirthProfile({0: set(), 1: {2}, 2: set(), 3: {6}}),
        "Space B (lens space L(6,2))": BirthProfile({0: set(), 1: {3}, 2: set(), 3: {6}}),
        "Space C (product)": BirthProfile({0: set(), 1: {6}, 2: set(), 3: {6}}),
    }

    primes = [2, 3, 5]
    fingerprints = {}

    for name, profile in spaces.items():
        fp = TorsionFingerprint(profile, primes)
        fingerprints[name] = fp
        print(f"{name}:")
        print(f"  Global birth set: {sorted(fp.global_set)}")
        for p in primes:
            bs = sorted(fp.spectrum[p])
            if bs:
                print(f"  p={p} birth set: {bs}")
        print()

    # Compute distances
    names = list(fingerprints.keys())
    print("Pairwise distances:")
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            d = fingerprints[names[i]].distance(fingerprints[names[j]])
            label_i = names[i].split("(")[1].rstrip(")")
            label_j = names[j].split("(")[1].rstrip(")")
            print(f"  d({label_i}, {label_j}) = {d}")

    print()
    print("Note: Spaces A and B have IDENTICAL global birth sets {1,3}")
    print("but are distinguished by their primewise fingerprints.")
    print("The primewise distance is nonzero while the global distance is zero.")
    print()


# ---------- Application 2: Signal Classification ----------

def demo_signal_classification():
    """Demonstrate signal classification via spectral birth signatures."""
    print("=" * 70)
    print("APPLICATION 2: Signal Classification via Spectral Signatures")
    print("=" * 70)
    print()

    print("Analogy: The global birth set is like time-domain support.")
    print("The primewise spectrum is like a time-frequency decomposition.")
    print()

    # Simulated signals with cyclic structure
    signals = {
        "Signal 1 (low-freq start)": BirthProfile({
            0: set(), 1: {2}, 2: {4}, 3: {6}, 4: {12}
        }),
        "Signal 2 (high-freq start)": BirthProfile({
            0: set(), 1: {3}, 2: {9}, 3: {6}, 4: {12}
        }),
        "Signal 3 (mixed start)": BirthProfile({
            0: set(), 1: {6}, 2: {4}, 3: {9}, 4: {12}
        }),
    }

    primes = [2, 3]

    for name, profile in signals.items():
        gs = sorted(global_torsion_birth_set(profile))
        print(f"{name}:")
        print(f"  Global activity levels: {gs}")
        for p in primes:
            ps = sorted(p_torsion_birth_set(p, profile))
            print(f"  p={p} channel active at: {ps}")
        print()

    # All three have the same global birth set
    global_sets = [global_torsion_birth_set(p) for p in signals.values()]
    all_same = all(g == global_sets[0] for g in global_sets)
    print(f"All signals have same global birth set? {all_same}")
    if all_same:
        print(f"Global birth set: {sorted(global_sets[0])}")
    print()
    print("Yet their primewise spectra differ — different 'frequency content'")
    print("appears at different times, analogous to a spectrogram distinguishing")
    print("signals that a simple amplitude envelope cannot.")
    print()


# ---------- Application 3: Filtration Distance ----------

def primewise_hausdorff_distance(
    F: BirthProfile, G: BirthProfile, primes: List[int]
) -> Dict[int, float]:
    """Compute the Hausdorff distance between primewise birth sets.

    Returns a dict mapping each prime to the Hausdorff distance
    between the corresponding birth sets.
    """
    distances = {}
    for p in primes:
        sF = p_torsion_birth_set(p, F)
        sG = p_torsion_birth_set(p, G)
        if not sF and not sG:
            distances[p] = 0.0
        elif not sF or not sG:
            distances[p] = float('inf')
        else:
            d1 = max(min(abs(a - b) for b in sG) for a in sF)
            d2 = max(min(abs(a - b) for a in sF) for b in sG)
            distances[p] = float(max(d1, d2))
    return distances


def demo_filtration_distance():
    """Demonstrate primewise filtration distance metrics."""
    print("=" * 70)
    print("APPLICATION 3: Primewise Filtration Distance")
    print("=" * 70)
    print()

    F = BirthProfile({0: set(), 1: {2}, 3: {6}})
    G = BirthProfile({0: set(), 1: {3}, 3: {6}})
    H = BirthProfile({0: set(), 2: {2}, 3: {6}})

    profiles = {"F": F, "G": G, "H": H}
    primes = [2, 3]

    print("Profiles:")
    for name, p in profiles.items():
        print(f"  {name} = {p}")
    print()

    # Compute pairwise distances
    pairs = [("F", "G"), ("F", "H"), ("G", "H")]
    for n1, n2 in pairs:
        p1, p2 = profiles[n1], profiles[n2]
        dists = primewise_hausdorff_distance(p1, p2, primes)
        max_dist = max(dists.values())
        print(f"  d_primewise({n1}, {n2}):")
        for p in primes:
            print(f"    p={p}: Hausdorff distance = {dists[p]}")
        print(f"    Max primewise distance = {max_dist}")
        print()

    print("Key insight: F and G have global distance 0 (same global birth set)")
    print("but primewise distance > 0. The primewise metric detects structure")
    print("invisible to the global metric.")
    print()


# ---------- Main ----------

if __name__ == "__main__":
    demo_fingerprinting()
    demo_signal_classification()
    demo_filtration_distance()


#!/usr/bin/env python3
"""
Primewise Birth Spectra — Demonstration Script

Constructs the explicit witness pair (F, G) showing that two filtrations
can share the same global torsion birth set yet differ in their primewise
birth spectra. Optionally searches all small profiles for separating pairs.
"""

from typing import Dict, List, Set, Tuple
from itertools import product


# ---------- Core data model ----------

class BirthProfile:
    """A finite birth profile: torsion orders born at each filtration level."""

    def __init__(self, orders_at: Dict[int, Set[int]]):
        """
        Parameters
        ----------
        orders_at : dict mapping level (int) -> set of torsion orders (ints)
        """
        self.orders_at = {k: set(v) for k, v in orders_at.items()}

    def __repr__(self):
        nonempty = {k: v for k, v in sorted(self.orders_at.items()) if v}
        return f"BirthProfile({nonempty})"


def global_torsion_birth_set(F: BirthProfile) -> Set[int]:
    """Levels where some torsion order > 1 is born."""
    return {level for level, orders in F.orders_at.items()
            if any(m > 1 for m in orders)}


def p_torsion_birth_set(p: int, F: BirthProfile) -> Set[int]:
    """Levels where some torsion order > 1 and divisible by p is born."""
    return {level for level, orders in F.orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}


def primewise_birth_spectrum(F: BirthProfile, primes: List[int]) -> Dict[int, Set[int]]:
    """The full primewise birth spectrum for a list of primes."""
    return {p: p_torsion_birth_set(p, F) for p in primes}


# ---------- Explicit witness pair ----------

def demonstrate_witness_pair():
    """Construct and display the canonical separating pair."""
    print("=" * 70)
    print("PRIMEWISE BIRTH SPECTRA — SEPARATION THEOREM DEMONSTRATION")
    print("=" * 70)
    print()

    # Profile F: order 2 at level 1, order 6 at level 3
    F = BirthProfile({0: set(), 1: {2}, 2: set(), 3: {6}})
    # Profile G: order 3 at level 1, order 6 at level 3
    G = BirthProfile({0: set(), 1: {3}, 2: set(), 3: {6}})

    print(f"Profile F: {F}")
    print(f"Profile G: {G}")
    print()

    # Compute global birth sets
    gF = global_torsion_birth_set(F)
    gG = global_torsion_birth_set(G)

    print(f"Global birth set of F: {sorted(gF)}")
    print(f"Global birth set of G: {sorted(gG)}")
    print(f"Global birth sets equal? {gF == gG}")
    print()

    # Compute primewise birth sets
    primes = [2, 3, 5]
    for p in primes:
        pF = p_torsion_birth_set(p, F)
        pG = p_torsion_birth_set(p, G)
        marker = " ← DIFFERENT!" if pF != pG else ""
        print(f"  p={p}: pTorsionBirthSet(F) = {sorted(pF)},  "
              f"pTorsionBirthSet(G) = {sorted(pG)}{marker}")

    print()
    print("CONCLUSION: Same global birth set {1, 3}, but different primewise")
    print("spectra. The primewise invariant is strictly finer.")
    print()


# ---------- Exhaustive search ----------

def find_all_separating_pairs(max_level: int = 4, divisor_bound: int = 30,
                               primes: List[int] = None):
    """
    Exhaustively search for profile pairs with equal global birth sets
    but different primewise spectra.

    Parameters
    ----------
    max_level : maximum filtration level
    divisor_bound : all torsion orders must divide this number
    primes : primes to test (defaults to primes dividing divisor_bound)
    """
    if primes is None:
        primes = [p for p in range(2, divisor_bound + 1)
                  if all(p % d != 0 for d in range(2, p))]
        primes = [p for p in primes if divisor_bound % p == 0]

    # Generate all divisors of divisor_bound that are > 1
    divisors = [d for d in range(2, divisor_bound + 1) if divisor_bound % d == 0]

    print(f"Searching profiles with max_level ≤ {max_level}")
    print(f"Torsion orders from divisors of {divisor_bound}: {divisors}")
    print(f"Testing primes: {primes}")
    print()

    # Generate all possible order sets at a single level (subsets of divisors)
    # Use small subsets for tractability
    order_subsets = [frozenset()]  # empty
    for d in divisors:
        order_subsets.append(frozenset([d]))
    # Add a few two-element subsets
    for i, d1 in enumerate(divisors):
        for d2 in divisors[i+1:]:
            order_subsets.append(frozenset([d1, d2]))

    # Generate profiles with exactly 2 nonempty levels for tractability
    profiles = []
    levels = list(range(max_level + 1))
    for l1 in levels:
        for l2 in levels:
            if l1 >= l2:
                continue
            for s1 in order_subsets:
                if not s1:
                    continue
                for s2 in order_subsets:
                    if not s2:
                        continue
                    orders = {l: set() for l in levels}
                    orders[l1] = set(s1)
                    orders[l2] = set(s2)
                    profiles.append(BirthProfile(orders))

    print(f"Generated {len(profiles)} candidate profiles")

    # Find separating pairs
    separating = []
    seen = set()
    for i, F in enumerate(profiles):
        gF = global_torsion_birth_set(F)
        for j, G in enumerate(profiles):
            if i >= j:
                continue
            gG = global_torsion_birth_set(G)
            if gF != gG:
                continue
            for p in primes:
                pF = p_torsion_birth_set(p, F)
                pG = p_torsion_birth_set(p, G)
                if pF != pG:
                    key = (frozenset(gF), p)
                    if key not in seen:
                        seen.add(key)
                        separating.append((F, G, p))
                    break

    print(f"Found {len(separating)} distinct separating pairs (by global set and prime)")
    print()

    # Display results
    for idx, (F, G, p) in enumerate(separating[:10]):
        gF = global_torsion_birth_set(F)
        pF = p_torsion_birth_set(p, F)
        pG = p_torsion_birth_set(p, G)
        nonempty_F = {k: v for k, v in F.orders_at.items() if v}
        nonempty_G = {k: v for k, v in G.orders_at.items() if v}
        print(f"  Pair {idx+1}: F={nonempty_F}, G={nonempty_G}")
        print(f"    Global={sorted(gF)}, p={p}: "
              f"pBS(F)={sorted(pF)}, pBS(G)={sorted(pG)}")

    # Check minimality
    if separating:
        min_pair = min(separating,
                       key=lambda x: sum(len(v) for v in x[0].orders_at.values()) +
                                     sum(len(v) for v in x[1].orders_at.values()))
        F, G, p = min_pair
        nonempty_F = {k: v for k, v in F.orders_at.items() if v}
        nonempty_G = {k: v for k, v in G.orders_at.items() if v}
        print(f"\n  Minimal pair (by total born summands):")
        print(f"    F={nonempty_F}, G={nonempty_G}, separating prime p={p}")

    return separating


# ---------- Main ----------

if __name__ == "__main__":
    demonstrate_witness_pair()

    print("=" * 70)
    print("EXHAUSTIVE SEARCH FOR SEPARATING PAIRS")
    print("=" * 70)
    print()
    find_all_separating_pairs(max_level=4, divisor_bound=30)


#!/usr/bin/env python3
"""
Visualization: Prime Decomposition of the Global Birth Set

Shows how the global torsion birth set decomposes as a union of primewise
birth sets. Illustrates the structural theorem: globalTorsionBirthSet =
⋃_p pTorsionBirthSet(p, F), and how two profiles can have the same union
but different individual components.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ---------- Inline functions ----------

def p_birth_set(p, orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}

def global_birth_set(orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 for m in orders)}


# ---------- Data ----------

F_orders = {0: set(), 1: {2}, 2: set(), 3: {6}}
G_orders = {0: set(), 1: {3}, 2: set(), 3: {6}}

primes = [2, 3]
levels = list(range(5))  # 0 through 4 for display

profiles = {
    'Profile F\n(2 at level 1, 6 at level 3)': F_orders,
    'Profile G\n(3 at level 1, 6 at level 3)': G_orders,
}

colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71'}  # prime colors
prime_names = {2: 'p=2', 3: 'p=3', 5: 'p=5'}

# ---------- Plot ----------

fig, axes = plt.subplots(2, 1, figsize=(12, 7), gridspec_kw={'hspace': 0.4})

for idx, (name, orders) in enumerate(profiles.items()):
    ax = axes[idx]

    # Draw level axis
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, len(primes) + 1.5)
    ax.set_xticks(levels)
    ax.set_xticklabels([str(l) for l in levels], fontsize=11)
    ax.set_xlabel('Filtration Level', fontsize=11)

    # Global birth set row
    gbs = global_birth_set(orders)
    y_global = len(primes) + 0.5
    for l in levels:
        if l in gbs:
            ax.add_patch(plt.Rectangle((l - 0.35, y_global - 0.3), 0.7, 0.6,
                                        facecolor='#f39c12', edgecolor='black',
                                        linewidth=1.5, zorder=3))
            ax.text(l, y_global, '✓', ha='center', va='center',
                    fontsize=14, fontweight='bold', zorder=4)
        else:
            ax.add_patch(plt.Rectangle((l - 0.35, y_global - 0.3), 0.7, 0.6,
                                        facecolor='#ecf0f1', edgecolor='gray',
                                        linewidth=0.5, zorder=3))

    ax.text(-0.45, y_global, 'Global', ha='right', va='center',
            fontsize=10, fontweight='bold', color='#f39c12')

    # Prime rows
    for pi, p in enumerate(primes):
        y = len(primes) - pi - 0.5
        pbs = p_birth_set(p, orders)
        for l in levels:
            if l in pbs:
                ax.add_patch(plt.Rectangle((l - 0.35, y - 0.3), 0.7, 0.6,
                                            facecolor=colors[p], edgecolor='black',
                                            linewidth=1.5, alpha=0.8, zorder=3))
                ax.text(l, y, '●', ha='center', va='center',
                        fontsize=16, color='white', zorder=4)
            else:
                ax.add_patch(plt.Rectangle((l - 0.35, y - 0.3), 0.7, 0.6,
                                            facecolor='#ecf0f1', edgecolor='gray',
                                            linewidth=0.5, zorder=3))
                ax.text(l, y, '○', ha='center', va='center',
                        fontsize=12, color='lightgray', zorder=4)

        ax.text(-0.45, y, prime_names[p], ha='right', va='center',
                fontsize=10, fontweight='bold', color=colors[p])

    # Draw union arrows
    for l in levels:
        if l in gbs:
            # Draw arrow from prime rows to global row
            active_primes = [pi for pi, p in enumerate(primes)
                             if l in p_birth_set(p, orders)]
            if active_primes:
                y_from = len(primes) - active_primes[0] - 0.5 + 0.35
                y_to = y_global - 0.35
                ax.annotate('', xy=(l, y_to), xytext=(l, y_from),
                            arrowprops=dict(arrowstyle='->', color='gray',
                                            lw=1, alpha=0.5))

    ax.set_title(name, fontsize=12, fontweight='bold', pad=10)
    ax.set_yticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)

# Add annotation
fig.text(0.5, -0.02,
         'The global row (union of prime rows) is identical for F and G,\n'
         'but the prime-by-prime decomposition differs — '
         'this is the separation theorem.',
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.4', facecolor='lightyellow',
                   edgecolor='orange', alpha=0.9))

plt.suptitle('Prime Decomposition of the Global Birth Set',
             fontsize=14, fontweight='bold')
plt.savefig('prime_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved: prime_decomposition.png")


#!/usr/bin/env python3
"""
Visualization: Information Loss in the Global Projection

Shows how the map from primewise birth spectrum to global birth set
loses information. Plots the spectral entropy of various profiles
versus their global entropy, illustrating that many different primewise
spectra can collapse to the same global signature.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log2
from itertools import combinations


# ---------- Inline functions ----------

def prime_factors(n):
    if n <= 1:
        return set()
    factors = set()
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors.add(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.add(temp)
    return factors


def global_birth_set(orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 for m in orders)}


def p_birth_set(p, orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}


def spectral_entropy(orders_at, primes):
    counts = {}
    total = 0
    for p in primes:
        c = len(p_birth_set(p, orders_at))
        if c > 0:
            counts[p] = c
            total += c
    if total == 0:
        return 0.0
    entropy = 0.0
    for c in counts.values():
        prob = c / total
        entropy -= prob * log2(prob)
    return entropy


def global_entropy(orders_at):
    g = global_birth_set(orders_at)
    n = len(g)
    if n <= 1:
        return 0.0
    return log2(n)


# ---------- Generate profiles ----------

primes = [2, 3, 5]
divisors = [2, 3, 5, 6, 10, 15, 30]
levels = [0, 1, 2, 3]

profiles = []
labels = []

# Generate profiles with 1-2 nonempty levels, single orders
for l1 in levels:
    for d1 in divisors:
        orders = {l: set() for l in levels}
        orders[l1] = {d1}
        profiles.append(orders)
        labels.append(f"L{l1}:{d1}")

        for l2 in levels:
            if l2 <= l1:
                continue
            for d2 in divisors:
                orders2 = {l: set() for l in levels}
                orders2[l1] = {d1}
                orders2[l2] = {d2}
                profiles.append(orders2)
                labels.append(f"L{l1}:{d1},L{l2}:{d2}")

# Compute entropies
global_ents = [global_entropy(p) for p in profiles]
spectral_ents = [spectral_entropy(p, primes) for p in profiles]
global_sets = [frozenset(global_birth_set(p)) for p in profiles]

# Color by global birth set
unique_globals = sorted(set(global_sets), key=lambda x: (len(x), sorted(x)))
color_map = {}
colors_list = plt.cm.Set2(np.linspace(0, 1, max(len(unique_globals), 1)))
for i, gs in enumerate(unique_globals):
    color_map[gs] = colors_list[i % len(colors_list)]

point_colors = [color_map[gs] for gs in global_sets]

# ---------- Plot ----------

fig, ax = plt.subplots(figsize=(10, 7))

scatter = ax.scatter(global_ents, spectral_ents, c=point_colors,
                     s=40, alpha=0.7, edgecolors='gray', linewidth=0.3)

# Identity line
max_val = max(max(global_ents, default=0), max(spectral_ents, default=0)) + 0.2
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='H_spectral = H_global')

# Highlight the witness pair
F_orders = {0: set(), 1: {2}, 2: set(), 3: {6}}
G_orders = {0: set(), 1: {3}, 2: set(), 3: {6}}
for name, orders, marker in [("F ({2}@1, {6}@3)", F_orders, 's'),
                               ("G ({3}@1, {6}@3)", G_orders, 'D')]:
    ge = global_entropy(orders)
    se = spectral_entropy(orders, primes)
    ax.scatter([ge], [se], marker=marker, s=200, edgecolors='red',
               facecolors='yellow', linewidth=2.5, zorder=5)
    ax.annotate(name, (ge, se), textcoords='offset points',
                xytext=(10, 10), fontsize=9, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='red'))

ax.set_xlabel('Global Entropy  H(global birth set)', fontsize=12)
ax.set_ylabel('Spectral Entropy  H(primewise spectrum)', fontsize=12)
ax.set_title('Information Content: Global vs Primewise\n'
             'Points above the diagonal carry information lost by the global projection',
             fontsize=13, fontweight='bold')

# Add legend for global birth set classes
legend_elements = []
for gs in unique_globals[:8]:
    import matplotlib.patches as mpatches
    patch = mpatches.Patch(color=color_map[gs],
                           label=f'global = {{{", ".join(map(str, sorted(gs)))}}}')
    legend_elements.append(patch)
ax.legend(handles=legend_elements, loc='upper left', fontsize=8, title='Global birth set')

ax.set_xlim(-0.1, max_val)
ax.set_ylim(-0.1, max_val)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('information_loss_plot.png', dpi=150, bbox_inches='tight')
print("Saved: information_loss_plot.png")


#!/usr/bin/env python3
"""
Visualization: Primewise Birth Spectra Heatmap

Visualizes the key separation result: two filtrations F and G have identical
global birth sets but different primewise birth spectra. The heatmap shows
which primes are "active" at which filtration levels, revealing the hidden
chromatic structure that the global invariant discards.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ---------- Inline data ----------

def p_torsion_birth_set(p, orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 and m % p == 0 for m in orders)}

def global_torsion_birth_set(orders_at):
    return {level for level, orders in orders_at.items()
            if any(m > 1 for m in orders)}

# Profile F: order 2 at level 1, order 6 at level 3
F_orders = {0: set(), 1: {2}, 2: set(), 3: {6}}
# Profile G: order 3 at level 1, order 6 at level 3
G_orders = {0: set(), 1: {3}, 2: set(), 3: {6}}

primes = [2, 3, 5, 7]
levels = [0, 1, 2, 3]

# Build heatmap matrices
def build_matrix(orders_at):
    mat = np.zeros((len(primes), len(levels)))
    for pi, p in enumerate(primes):
        bs = p_torsion_birth_set(p, orders_at)
        for li, l in enumerate(levels):
            if l in bs:
                mat[pi, li] = 1.0
    return mat

mat_F = build_matrix(F_orders)
mat_G = build_matrix(G_orders)
mat_diff = mat_F - mat_G  # +1 = only in F, -1 = only in G

# ---------- Plot ----------

fig, axes = plt.subplots(1, 3, figsize=(15, 4.5), gridspec_kw={'wspace': 0.35})

# Common settings
prime_labels = [f'p = {p}' for p in primes]
level_labels = [str(l) for l in levels]

# Profile F
im0 = axes[0].imshow(mat_F, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
axes[0].set_title('Profile F\n(orders: {1: {2}, 3: {6}})', fontsize=11, fontweight='bold')
axes[0].set_xlabel('Filtration Level')
axes[0].set_ylabel('Prime')
axes[0].set_xticks(range(len(levels)))
axes[0].set_xticklabels(level_labels)
axes[0].set_yticks(range(len(primes)))
axes[0].set_yticklabels(prime_labels)
for pi in range(len(primes)):
    for li in range(len(levels)):
        val = mat_F[pi, li]
        color = 'white' if val > 0.5 else 'black'
        axes[0].text(li, pi, '●' if val > 0 else '○',
                     ha='center', va='center', color=color, fontsize=14)

# Profile G
im1 = axes[1].imshow(mat_G, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
axes[1].set_title('Profile G\n(orders: {1: {3}, 3: {6}})', fontsize=11, fontweight='bold')
axes[1].set_xlabel('Filtration Level')
axes[1].set_xticks(range(len(levels)))
axes[1].set_xticklabels(level_labels)
axes[1].set_yticks(range(len(primes)))
axes[1].set_yticklabels(prime_labels)
for pi in range(len(primes)):
    for li in range(len(levels)):
        val = mat_G[pi, li]
        color = 'white' if val > 0.5 else 'black'
        axes[1].text(li, pi, '●' if val > 0 else '○',
                     ha='center', va='center', color=color, fontsize=14)

# Difference
cmap_diff = plt.cm.RdBu_r
im2 = axes[2].imshow(mat_diff, cmap=cmap_diff, aspect='auto', vmin=-1, vmax=1)
axes[2].set_title('Difference (F − G)\nSame global, different spectra', fontsize=11, fontweight='bold')
axes[2].set_xlabel('Filtration Level')
axes[2].set_xticks(range(len(levels)))
axes[2].set_xticklabels(level_labels)
axes[2].set_yticks(range(len(primes)))
axes[2].set_yticklabels(prime_labels)
for pi in range(len(primes)):
    for li in range(len(levels)):
        val = mat_diff[pi, li]
        if val > 0:
            axes[2].text(li, pi, '+F', ha='center', va='center',
                         color='white', fontsize=10, fontweight='bold')
        elif val < 0:
            axes[2].text(li, pi, '+G', ha='center', va='center',
                         color='white', fontsize=10, fontweight='bold')
        else:
            axes[2].text(li, pi, '=', ha='center', va='center',
                         color='gray', fontsize=10)

# Add global birth set annotation
gF = sorted(global_torsion_birth_set(F_orders))
gG = sorted(global_torsion_birth_set(G_orders))
fig.text(0.5, 0.01,
         f'Global birth sets:  F → {{{", ".join(map(str, gF))}}}  =  '
         f'G → {{{", ".join(map(str, gG))}}}   (identical!)',
         ha='center', fontsize=12, style='italic',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='orange'))

plt.suptitle('Primewise Birth Spectra: The Separation Theorem',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('primewise_spectra_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: primewise_spectra_heatmap.png")
