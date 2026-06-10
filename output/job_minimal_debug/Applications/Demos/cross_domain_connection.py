#!/usr/bin/env python3
"""
Applications of Union-Closed Family Theory

Real-world applications demonstrating how the mathematical framework
connects to practical problems in:
1. Network reliability (monotone systems)
2. Feature selection (correlation structure)
3. Error-correcting codes (closure properties)
4. Database theory (functional dependencies)
"""

from itertools import combinations, chain
from fractions import Fraction
from collections import defaultdict
from typing import Set, List, FrozenSet, Dict, Tuple
import random

from algorithms import (
    is_union_closed, union_closure, member_count, joint_count,
    covariance, marginal_density, total_occupancy, powerset_list,
    find_popular_elements, correlation_matrix
)


# ============================================================
# APPLICATION 1: Network Reliability Analysis
# ============================================================

def network_reliability_demo():
    """
    Model a network where links can fail independently.
    The set of "working configurations" (subsets of links that
    maintain connectivity) forms an upset in the link powerset.

    By our theorems:
    - The upset is union-closed (upset_unionClosed)
    - Link occupancies are interpretable as marginal reliabilities
    - The double-counting identity gives total expected working links
    """
    print("=" * 60)
    print("APPLICATION 1: Network Reliability")
    print("=" * 60)

    # Simple network: 4 nodes, 5 links
    # Links: 1-2, 2-3, 3-4, 1-3, 2-4
    links = {1: (1,2), 2: (2,3), 3: (3,4), 4: (1,3), 5: (2,4)}
    print(f"\nNetwork: 4 nodes, 5 links")
    for lid, (u, v) in sorted(links.items()):
        print(f"  Link {lid}: {u}—{v}")

    # A configuration is "working" if nodes 1 and 4 are connected
    def is_connected_1_4(active_links: FrozenSet[int]) -> bool:
        """Check if nodes 1 and 4 are connected using active links."""
        if not active_links:
            return False
        adj = defaultdict(set)
        for lid in active_links:
            u, v = links[lid]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        queue = [1]
        while queue:
            node = queue.pop()
            if node == 4:
                return True
            if node in visited:
                continue
            visited.add(node)
            for nb in adj[node]:
                if nb not in visited:
                    queue.append(nb)
        return False

    # Generate upset of working configurations
    all_configs = powerset_list(set(links.keys()))
    working = [s for s in all_configs if is_connected_1_4(s)]

    print(f"\nTotal configurations: {len(all_configs)}")
    print(f"Working configurations (1↔4 connected): {len(working)}")
    print(f"System reliability = {len(working)}/{len(all_configs)} "
          f"= {Fraction(len(working), len(all_configs))}")

    # Verify upset property
    working_set = set(working)
    is_upset = all(
        frozenset(s | {extra}) in working_set
        for s in working
        for extra in set(links.keys()) - s
    )
    print(f"Is upset? {is_upset}")
    print(f"Is union-closed? {is_union_closed(working)} (by our theorem!)")

    # Marginal link importance
    print(f"\nLink importance (marginal reliability contribution):")
    for lid in sorted(links.keys()):
        density = marginal_density(lid, working)
        print(f"  Link {lid} ({links[lid][0]}—{links[lid][1]}): "
              f"density = {float(density):.4f}")

    # Most important link for maintenance
    popular = find_popular_elements(set(links.keys()), working)
    print(f"\nLinks appearing in ≥ 50% of working configs: {popular}")
    print("  → These are the most critical links for network reliability")


# ============================================================
# APPLICATION 2: Feature Selection via Correlation
# ============================================================

def feature_selection_demo():
    """
    In machine learning, features that are positively correlated
    under the data distribution provide redundant information.

    Model: feature subsets as a union-closed family (closed under
    combining feature sets). The covariance structure tells us
    which features carry independent information.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Feature Selection via Correlation")
    print("=" * 60)

    # Features: {color, shape, size, texture}
    features = {1: "color", 2: "shape", 3: "size", 4: "texture"}
    print(f"\nFeatures: {features}")

    # Observed feature co-occurrence patterns (union-closed family)
    # These represent which feature subsets appear together in data
    observations = [
        frozenset({1}),        # color alone
        frozenset({2}),        # shape alone
        frozenset({1, 2}),     # color + shape
        frozenset({3, 4}),     # size + texture
        frozenset({1, 2, 3, 4}),  # all features
        frozenset({1, 3, 4}),  # color + size + texture
        frozenset({2, 3, 4}),  # shape + size + texture
    ]

    print(f"Observation patterns: {len(observations)} feature subsets")
    print(f"Union-closed? {is_union_closed(observations)}")

    # Compute feature co-occurrence correlations
    print(f"\nFeature co-occurrence correlation matrix:")
    ground = set(features.keys())
    corr = correlation_matrix(ground, observations)
    elements = sorted(ground)

    # Print header
    print(f"{'':>10}", end="")
    for b in elements:
        print(f"{features[b]:>10}", end="")
    print()

    for a in elements:
        print(f"{features[a]:>10}", end="")
        for b in elements:
            cov = float(corr.get((a, b), 0))
            print(f"{cov:>10.4f}", end="")
        print()

    print(f"\nInterpretation:")
    for a in elements:
        for b in elements:
            if b <= a:
                continue
            cov = corr[(a, b)]
            if cov > 0:
                rel = "positively correlated (redundant)"
            elif cov < 0:
                rel = "negatively correlated (complementary)"
            else:
                rel = "uncorrelated (independent)"
            if abs(float(cov)) > 0.01:
                print(f"  {features[a]} ↔ {features[b]}: {rel} ({float(cov):.4f})")


# ============================================================
# APPLICATION 3: Database Closure & Functional Dependencies
# ============================================================

def database_closure_demo():
    """
    In database theory, the set of attribute closures under
    functional dependencies forms a union-closed family.

    Given functional dependencies, compute the closure of
    attribute sets and analyze the structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Database Functional Dependencies")
    print("=" * 60)

    # Attributes: {A, B, C, D}
    attrs = {1: "StudentID", 2: "Name", 3: "Department", 4: "GPA"}
    print(f"\nAttributes: {attrs}")

    # Functional dependencies: 1→2 (ID→Name), 1→4 (ID→GPA), 3→{} (Dept is independent)
    # Closed sets under these FDs:
    closed_sets = [
        frozenset(),
        frozenset({3}),
        frozenset({1, 2, 4}),
        frozenset({1, 2, 3, 4}),
    ]

    print(f"\nClosed attribute sets (under functional dependencies):")
    for s in closed_sets:
        names = [attrs[a] for a in sorted(s)] if s else ["∅"]
        print(f"  {{{', '.join(names)}}}")

    print(f"\nUnion-closed? {is_union_closed(closed_sets)}")

    # Union closure
    cl = union_closure(closed_sets)
    print(f"Union closure has {len(cl)} sets (was {len(closed_sets)})")

    # This shows the lattice of closed sets
    print(f"\nKey insight: The closed sets form a join-semilattice.")
    print(f"Theorem C guarantees: total attribute coverage can only")
    print(f"increase under closure (total occ: {total_occupancy(closed_sets)}"
          f" → {total_occupancy(cl)})")


# ============================================================
# APPLICATION 4: Error Detection Capability
# ============================================================

def error_detection_demo():
    """
    Model error-detecting codes: a codeword is a subset of
    positions where parity checks pass. The set of valid
    syndromes for a linear code is union-closed.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Error Detection Codes")
    print("=" * 60)

    # Positions: {1, 2, 3, 4, 5}
    # Valid syndrome patterns (union-closed)
    syndromes = [
        frozenset(),           # no errors
        frozenset({1, 2}),     # error pattern 1
        frozenset({3, 4}),     # error pattern 2
        frozenset({1, 2, 3, 4}),  # combined
        frozenset({5}),        # error pattern 3
        frozenset({1, 2, 5}),  # combined 1+3
        frozenset({3, 4, 5}),  # combined 2+3
        frozenset({1, 2, 3, 4, 5}),  # all
    ]

    print(f"\nSyndrome patterns: {len(syndromes)}")
    print(f"Union-closed? {is_union_closed(syndromes)}")

    ground = {1, 2, 3, 4, 5}
    print(f"\nPosition detection frequency (under uniform syndrome dist.):")
    for pos in sorted(ground):
        mc = member_count(pos, syndromes)
        density = marginal_density(pos, syndromes)
        print(f"  Position {pos}: detected in {mc}/{len(syndromes)} "
              f"= {float(density):.3f} of syndromes")

    # Average syndrome weight
    avg = Fraction(total_occupancy(syndromes), len(syndromes))
    print(f"\nAverage syndrome weight: {avg} = {float(avg):.3f}")
    print(f"Ground size / 2 = {len(ground)/2}")

    # Theorem B check
    if 2 * total_occupancy(syndromes) >= len(syndromes) * len(ground):
        popular = find_popular_elements(ground, syndromes)
        print(f"Theorem B applies! Popular positions: {popular}")
    else:
        print(f"Average below half — Theorem B hypothesis not met")


if __name__ == "__main__":
    network_reliability_demo()
    feature_selection_demo()
    database_closure_demo()
    error_detection_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Union-Closed Families as Positive-Correlation Systems

Concrete numerical examples demonstrating the formally verified theorems
connecting combinatorial set families to statistical mechanics observables.
"""

from itertools import combinations, chain
from collections import Counter
from fractions import Fraction
import math


def powerset(iterable):
    """All subsets of an iterable."""
    s = list(iterable)
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


def is_union_closed(family):
    """Check if a family (list of frozensets) is union-closed."""
    family_set = set(family)
    for A in family:
        for B in family:
            if A | B not in family_set:
                return False
    return True


def member_count(a, family):
    """Number of sets in family containing element a."""
    return sum(1 for s in family if a in s)


def joint_count(a, b, family):
    """Number of sets containing both a and b."""
    return sum(1 for s in family if a in s and b in s)


def union_count(a, b, family):
    """Number of sets containing a or b."""
    return sum(1 for s in family if a in s or b in s)


def union_closure(family):
    """Compute the union closure of a family."""
    family_set = set(family)
    changed = True
    while changed:
        changed = False
        new = set()
        for A in family_set:
            for B in family_set:
                C = A | B
                if C not in family_set:
                    new.add(C)
                    changed = True
        family_set |= new
    return sorted(family_set, key=lambda s: (len(s), sorted(s)))


# ============================================================
# DEMO 1: Theorem A — Double-counting identity
# ============================================================
print("=" * 60)
print("THEOREM A: Double-counting identity")
print("∑_a #{s ∈ F : a ∈ s} = ∑_{s ∈ F} |s|")
print("=" * 60)

ground = {1, 2, 3, 4}
family = [
    frozenset({1, 2}),
    frozenset({2, 3}),
    frozenset({1, 3, 4}),
    frozenset({2, 4}),
    frozenset({1, 2, 3, 4}),
]

lhs = sum(member_count(a, family) for a in ground)
rhs = sum(len(s) for s in family)
print(f"\nGround set: {sorted(ground)}")
print(f"Family F = {[sorted(s) for s in family]}")
print(f"\nElement frequencies:")
for a in sorted(ground):
    mc = member_count(a, family)
    print(f"  element {a}: appears in {mc} sets")
print(f"\nSet sizes: {[len(s) for s in family]}")
print(f"\nLHS = Σ memberCount(a) = {lhs}")
print(f"RHS = Σ |s|            = {rhs}")
print(f"Equal? {lhs == rhs}  ✓" if lhs == rhs else f"FAIL ✗")

# ============================================================
# DEMO 2: Theorem B — Majority-from-average principle
# ============================================================
print("\n" + "=" * 60)
print("THEOREM B: Majority-from-average principle")
print("If 2·Σ|s| ≥ |F|·|α|, then ∃a: 2·memberCount(a) ≥ |F|")
print("=" * 60)

ground = {1, 2, 3}
family = [
    frozenset({1, 2, 3}),
    frozenset({1, 2}),
    frozenset({2, 3}),
    frozenset({1, 3}),
]

n = len(ground)
F_card = len(family)
total_size = sum(len(s) for s in family)
avg_size = Fraction(total_size, F_card)

print(f"\nGround set: {sorted(ground)}, |α| = {n}")
print(f"Family F: {[sorted(s) for s in family]}")
print(f"|F| = {F_card}, Σ|s| = {total_size}, avg |s| = {avg_size}")
print(f"Condition: 2·{total_size} = {2*total_size} ≥ {F_card}·{n} = {F_card*n}?",
      "YES ✓" if 2*total_size >= F_card*n else "NO")

print(f"\nElement occupancies (marginal density = memberCount/|F|):")
popular = []
for a in sorted(ground):
    mc = member_count(a, family)
    density = Fraction(mc, F_card)
    is_pop = 2 * mc >= F_card
    if is_pop:
        popular.append(a)
    print(f"  element {a}: memberCount={mc}, density={density}"
          f"{'  ★ POPULAR (≥ 1/2)' if is_pop else ''}")

print(f"\nPopular elements (2·memberCount ≥ |F|): {popular}")
print(f"Theorem B guarantees at least one exists: ✓" if popular else "FAIL ✗")

# ============================================================
# DEMO 3: Union closure & Theorem C
# ============================================================
print("\n" + "=" * 60)
print("THEOREM C: Total occupancy monotone under union closure")
print("Σ_{s∈F} |s| ≤ Σ_{s∈cl(F)} |s|")
print("=" * 60)

ground = {1, 2, 3}
family_raw = [frozenset({1}), frozenset({2}), frozenset({3})]
closure = union_closure(family_raw)

print(f"\nOriginal family F: {[sorted(s) for s in family_raw]}")
print(f"Union closure cl(F): {[sorted(s) for s in closure]}")
print(f"F is union-closed? {is_union_closed(family_raw)}")
print(f"cl(F) is union-closed? {is_union_closed(closure)}")

total_F = sum(len(s) for s in family_raw)
total_cl = sum(len(s) for s in closure)
print(f"\nΣ|s| over F:    {total_F}")
print(f"Σ|s| over cl(F): {total_cl}")
print(f"Monotonicity: {total_F} ≤ {total_cl}?",
      "YES ✓" if total_F <= total_cl else "FAIL ✗")

# Another example
family_raw2 = [frozenset({1, 2}), frozenset({3})]
closure2 = union_closure(family_raw2)
total_F2 = sum(len(s) for s in family_raw2)
total_cl2 = sum(len(s) for s in closure2)
print(f"\nAnother example:")
print(f"F = {[sorted(s) for s in family_raw2]}")
print(f"cl(F) = {[sorted(s) for s in closure2]}")
print(f"Σ|s| over F: {total_F2}, over cl(F): {total_cl2}, monotone? "
      f"{'YES ✓' if total_F2 <= total_cl2 else 'FAIL ✗'}")

# ============================================================
# DEMO 4: Powerset correlation (Theorem D)
# ============================================================
print("\n" + "=" * 60)
print("THEOREM D: Nonneg correlation on full powerset")
print("|2^α|·jointCount(a,b) ≥ memberCount(a)·memberCount(b)")
print("=" * 60)

for n in range(1, 5):
    ground = set(range(1, n + 1))
    full_powerset = [frozenset(s) for s in powerset(ground)]
    P = len(full_powerset)
    print(f"\n|α| = {n}, |2^α| = {P}")
    for a in range(1, min(n, 3) + 1):
        for b in range(a, min(n, 3) + 1):
            mc_a = member_count(a, full_powerset)
            mc_b = member_count(b, full_powerset)
            jc = joint_count(a, b, full_powerset)
            lhs = P * jc
            rhs = mc_a * mc_b
            status = "= (indep)" if lhs == rhs else ("≥ ✓" if lhs >= rhs else "FAIL ✗")
            print(f"  a={a}, b={b}: {P}·{jc}={lhs} vs {mc_a}·{mc_b}={rhs}  {status}")

# ============================================================
# DEMO 5: Inclusion-exclusion (unionCount identity)
# ============================================================
print("\n" + "=" * 60)
print("INCLUSION-EXCLUSION: unionCount = memberCount_a + memberCount_b - jointCount")
print("=" * 60)

family = [
    frozenset({1, 2}), frozenset({2, 3}), frozenset({3, 4}),
    frozenset({1, 4}), frozenset({1, 2, 3, 4})
]
print(f"\nFamily: {[sorted(s) for s in family]}")
for a in [1, 2]:
    for b in [3, 4]:
        mc_a = member_count(a, family)
        mc_b = member_count(b, family)
        jc = joint_count(a, b, family)
        uc = union_count(a, b, family)
        check = mc_a + mc_b - jc
        print(f"  a={a}, b={b}: unionCount={uc}, "
              f"memberCount({a})+memberCount({b})-jointCount={mc_a}+{mc_b}-{jc}={check}  "
              f"{'✓' if uc == check else '✗'}")

# ============================================================
# DEMO 6: Statistical mechanics interpretation
# ============================================================
print("\n" + "=" * 60)
print("STATISTICAL MECHANICS INTERPRETATION")
print("=" * 60)

ground = {1, 2, 3, 4}
# A union-closed family representing a lattice gas
family = [
    frozenset(),
    frozenset({1}), frozenset({2}), frozenset({3}), frozenset({4}),
    frozenset({1, 2}), frozenset({1, 3}), frozenset({1, 4}),
    frozenset({2, 3}), frozenset({2, 4}), frozenset({3, 4}),
    frozenset({1, 2, 3}), frozenset({1, 2, 4}), frozenset({1, 3, 4}),
    frozenset({2, 3, 4}),
    frozenset({1, 2, 3, 4}),
]  # Full powerset — trivially union-closed

print(f"\nFull powerset of {{1,2,3,4}}: {len(family)} configurations")
print(f"This is the 'free lattice gas' — all configurations allowed.\n")

print("Site occupancy (marginal densities):")
for a in sorted(ground):
    mc = member_count(a, family)
    density = Fraction(mc, len(family))
    print(f"  Site {a}: ρ(a) = {mc}/{len(family)} = {float(density):.4f}")

print("\nTwo-point correlations (connected correlation function):")
for a in sorted(ground):
    for b in sorted(ground):
        if b <= a:
            continue
        mc_a = member_count(a, family)
        mc_b = member_count(b, family)
        jc = joint_count(a, b, family)
        # Covariance: E[X_a X_b] - E[X_a]E[X_b]
        # = jointCount/|F| - memberCount_a * memberCount_b / |F|^2
        N = len(family)
        cov = Fraction(jc, N) - Fraction(mc_a * mc_b, N * N)
        print(f"  Cov({a},{b}) = {float(cov):.4f}"
              f"  (jc={jc}, mc_a={mc_a}, mc_b={mc_b})")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Union-Closed Families as Positive-Correlation Systems

Generates figures showing:
1. Correlation heatmap for a union-closed family
2. Union closure growth diagram
3. Frankl density distribution
4. Double-counting identity visualization
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations, chain
from fractions import Fraction
from collections import defaultdict
import base64
import io

# Import our algorithms
from algorithms import (
    powerset_list, is_union_closed, union_closure,
    member_count, joint_count, covariance, marginal_density,
    total_occupancy, average_card, enumerate_union_closed_families,
    frankl_conjecture_check, correlation_matrix
)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_correlation_heatmap():
    """Plot covariance matrix for various families."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    ground = {1, 2, 3, 4}
    n = len(ground)
    elements = sorted(ground)

    families = {
        "Full Powerset\n(Free Lattice Gas)": powerset_list(ground),
        "Union-Closed Family\n(Constrained Gas)": [
            frozenset({1, 2}), frozenset({3, 4}),
            frozenset({1, 2, 3, 4}), frozenset({1, 2, 3}),
            frozenset({1, 2, 4}), frozenset({2, 3, 4}),
            frozenset({1, 3, 4}),
        ],
        "Principal Upset ↑{1}\n(Ordered Phase)": [
            frozenset(s) for s in powerset_list(ground)
            if 1 in s
        ],
    }

    for idx, (title, family) in enumerate(families.items()):
        ax = axes[idx]
        mat = np.zeros((n, n))
        for i, a in enumerate(elements):
            for j, b in enumerate(elements):
                cov = float(covariance(a, b, family))
                mat[i, j] = cov

        vmax = max(abs(mat.min()), abs(mat.max()), 0.01)
        im = ax.imshow(mat, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                       aspect='equal')
        ax.set_xticks(range(n))
        ax.set_xticklabels(elements)
        ax.set_yticks(range(n))
        ax.set_yticklabels(elements)
        ax.set_title(title, fontsize=10, fontweight='bold')
        ax.set_xlabel("Element")
        ax.set_ylabel("Element")

        # Annotate values
        for i in range(n):
            for j in range(n):
                color = 'white' if abs(mat[i,j]) > vmax*0.6 else 'black'
                ax.text(j, i, f"{mat[i,j]:.3f}", ha='center', va='center',
                        fontsize=8, color=color)

        fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04, label='Cov(Xₐ, Xᵦ)')

    fig.suptitle("Site-Site Covariance Under Uniform Measure",
                 fontsize=13, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def plot_closure_growth():
    """Show how union closure grows a family."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ground = {1, 2, 3, 4}
    # Start with singletons
    initial = [frozenset({i}) for i in sorted(ground)]

    # Track growth steps
    current = set(map(frozenset, initial))
    steps = [len(current)]
    total_sizes = [sum(len(s) for s in current)]
    labels = ["Initial"]

    for iteration in range(10):
        new = set()
        cl = list(current)
        for A in cl:
            for B in cl:
                C = A | B
                if C not in current:
                    new.add(C)
        if not new:
            break
        current |= new
        steps.append(len(current))
        total_sizes.append(sum(len(s) for s in current))
        labels.append(f"Iter {iteration + 1}")

    x = range(len(steps))
    ax.bar([i - 0.2 for i in x], steps, 0.35, label='|Family|',
           color='#2196F3', alpha=0.8)
    ax.bar([i + 0.2 for i in x], total_sizes, 0.35, label='Σ|s| (total occupancy)',
           color='#FF9800', alpha=0.8)

    ax.set_xticks(list(x))
    ax.set_xticklabels(labels)
    ax.set_xlabel("Closure Iteration", fontsize=12)
    ax.set_ylabel("Count", fontsize=12)
    ax.set_title("Union Closure Growth: Singletons → Full Join-Semilattice\n"
                 "(Theorem C: Total occupancy is monotonically increasing)",
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)

    # Annotate
    for i, (s, t) in enumerate(zip(steps, total_sizes)):
        ax.text(i - 0.2, s + 0.3, str(s), ha='center', fontsize=9, fontweight='bold')
        ax.text(i + 0.2, t + 0.3, str(t), ha='center', fontsize=9, fontweight='bold')

    fig.tight_layout()
    return fig


def plot_frankl_density_distribution():
    """Distribution of max element frequency across all union-closed families."""
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    for idx, n in enumerate([3, 4]):
        ax = axes[idx]
        ground = set(range(1, n + 1))
        families = enumerate_union_closed_families(ground)

        ratios = []
        for fam in families:
            if len(fam) < 2:
                continue
            max_ratio = max(
                Fraction(member_count(a, fam), len(fam))
                for a in ground
            )
            ratios.append(float(max_ratio))

        if ratios:
            ax.hist(ratios, bins=20, color='#4CAF50', alpha=0.8,
                    edgecolor='black', linewidth=0.5)
            ax.axvline(x=0.5, color='red', linestyle='--', linewidth=2,
                       label='Frankl threshold (1/2)')
            ax.set_xlabel("Max element frequency (max_a memberCount(a)/|F|)", fontsize=10)
            ax.set_ylabel("Number of families", fontsize=10)
            ax.set_title(f"|α| = {n}: {len(ratios)} union-closed families (|F| ≥ 2)\n"
                         f"Min ratio = {min(ratios):.3f}",
                         fontsize=11, fontweight='bold')
            ax.legend(fontsize=10)
            ax.grid(axis='y', alpha=0.3)

    fig.suptitle("Frankl's Conjecture: Maximum Element Frequency Distribution",
                 fontsize=13, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def plot_double_counting():
    """Visualize the double-counting identity as a bipartite graph."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ground = [1, 2, 3, 4]
    family = [
        frozenset({1, 2}),
        frozenset({2, 3}),
        frozenset({1, 3, 4}),
        frozenset({2, 4}),
    ]

    # Position elements on left, sets on right
    n_elem = len(ground)
    n_sets = len(family)

    elem_y = np.linspace(0.8, 0.2, n_elem)
    set_y = np.linspace(0.8, 0.2, n_sets)

    # Draw connections
    for i, a in enumerate(ground):
        for j, s in enumerate(family):
            if a in s:
                ax.plot([0.2, 0.8], [elem_y[i], set_y[j]],
                        color='#2196F3', alpha=0.4, linewidth=1.5)

    # Draw element nodes
    for i, a in enumerate(ground):
        mc = member_count(a, family)
        circle = plt.Circle((0.2, elem_y[i]), 0.03, color='#4CAF50',
                             zorder=5)
        ax.add_patch(circle)
        ax.text(0.08, elem_y[i], f"a={a}\nmc={mc}",
                ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw set nodes
    for j, s in enumerate(family):
        rect = mpatches.FancyBboxPatch((0.77, set_y[j] - 0.025), 0.06, 0.05,
                                        boxstyle="round,pad=0.01",
                                        facecolor='#FF9800', zorder=5)
        ax.add_patch(rect)
        ax.text(0.92, set_y[j], f"{sorted(s)}\n|s|={len(s)}",
                ha='center', va='center', fontsize=8, fontweight='bold')

    # Totals
    lhs = sum(member_count(a, family) for a in ground)
    rhs = sum(len(s) for s in family)
    ax.text(0.5, 0.95, f"Σ memberCount(a) = {lhs}  =  Σ |s| = {rhs}",
            ha='center', va='center', fontsize=14, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.text(0.2, 0.95, "Elements", ha='center', fontsize=11,
            fontweight='bold', color='#4CAF50')
    ax.text(0.8, 0.95, "Sets", ha='center', fontsize=11,
            fontweight='bold', color='#FF9800')

    ax.set_xlim(0, 1)
    ax.set_ylim(0.1, 1.0)
    ax.axis('off')
    ax.set_title("Theorem A: Double-Counting Identity\n"
                 "Each edge = (element, set) pair with a ∈ s",
                 fontsize=12, fontweight='bold')
    fig.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    fig1 = plot_correlation_heatmap()
    fig1.savefig("viz_correlation_heatmap.png", dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  Saved viz_correlation_heatmap.png")

    fig2 = plot_closure_growth()
    fig2.savefig("viz_closure_growth.png", dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  Saved viz_closure_growth.png")

    fig3 = plot_frankl_density_distribution()
    fig3.savefig("viz_frankl_density.png", dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  Saved viz_frankl_density.png")

    fig4 = plot_double_counting()
    fig4.savefig("viz_double_counting.png", dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  Saved viz_double_counting.png")

    print("All visualizations generated!")
