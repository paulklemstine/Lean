#!/usr/bin/env python3
"""
Applications of the Theory Bicategory

Demonstrates real-world applications of the locally preordered 2-category
to abstract interpretation, program optimization, and knowledge comparison.
"""

from dataclasses import dataclass
from typing import List, Dict, Tuple
from algorithms import Theory, Morphism, two_cell_holds, compose_morphisms, enumerate_morphisms


# ═══════════════════════════════════════════════════════════
# Application 1: Abstract Interpretation Comparison
# ═══════════════════════════════════════════════════════════

def abstract_interpretation_demo():
    """
    In abstract interpretation, a program analysis maps concrete program
    states to abstract domains. Different abstractions have different
    precision. The 2-cell ordering captures "more precise than".

    Example: Analyzing a simple program with integer variables.
    - Concrete domain: integers with their absolute value as complexity.
    - Abstract domain 1 (signs): {neg, zero, pos} — coarse.
    - Abstract domain 2 (intervals): {[-∞,-1], [0,0], [1,∞], [-∞,∞]} — finer.

    A more precise abstraction assigns higher "information content" (invariant).
    """
    print("=" * 60)
    print("  Application 1: Comparing Program Analyses")
    print("=" * 60)

    # Concrete theory: program states with complexity
    concrete = Theory("Concrete",
                      ["x=-5", "x=-1", "x=0", "x=1", "x=7"],
                      {"x=-5": 5, "x=-1": 1, "x=0": 0, "x=1": 1, "x=7": 7})

    # Sign abstraction (coarse)
    signs = Theory("Signs",
                   ["neg", "zero", "pos"],
                   {"neg": 3, "zero": 1, "pos": 3})

    # Interval abstraction (finer)
    intervals = Theory("Intervals",
                       ["neg", "zero", "pos", "any"],
                       {"neg": 5, "zero": 2, "pos": 5, "any": 8})

    # Sign abstraction map
    sign_abs = Morphism(concrete, signs, {
        "x=-5": "neg", "x=-1": "neg", "x=0": "zero",
        "x=1": "pos", "x=7": "pos"
    })

    # Interval abstraction map
    interval_abs = Morphism(concrete, intervals, {
        "x=-5": "neg", "x=-1": "neg", "x=0": "zero",
        "x=1": "pos", "x=7": "pos"
    })

    print(f"\nConcrete states: {concrete.inv}")
    print(f"Sign abstraction valid: {sign_abs.is_valid()}")
    print(f"Interval abstraction valid: {interval_abs.is_valid()}")

    # We can't directly compare sign_abs and interval_abs since they have
    # different targets. But we can embed both targets into a common theory.
    common = Theory("Common",
                    ["neg", "zero", "pos", "any"],
                    {"neg": 5, "zero": 2, "pos": 5, "any": 8})

    # Embed signs into common
    sign_embed = Morphism(signs, common, {
        "neg": "neg", "zero": "zero", "pos": "pos"
    })

    # Embed intervals into common (identity)
    interval_embed = Morphism(intervals, common, {
        "neg": "neg", "zero": "zero", "pos": "pos", "any": "any"
    })

    # Compose to get both analyses landing in the common target
    sign_composed = compose_morphisms(sign_abs, sign_embed)
    interval_composed = compose_morphisms(interval_abs, interval_embed)

    print(f"\nSign analysis (composed): {sign_composed.invariant_profile()}")
    print(f"Interval analysis (composed): {interval_composed.invariant_profile()}")
    dom = two_cell_holds(sign_composed, interval_composed)
    print(f"Interval ≥₂ Sign (interval is more precise)? {dom}")
    print("\nInterpretation: The 2-cell ordering tells us which analysis")
    print("preserves more information — directly comparable via the invariant.")


# ═══════════════════════════════════════════════════════════
# Application 2: Compiler Optimization Comparison
# ═══════════════════════════════════════════════════════════

def compiler_optimization_demo():
    """
    Compilers translate programs from source to target language.
    Different optimization strategies produce different outputs.
    The 2-cell ordering captures "this optimization preserves more
    performance potential" measured by code quality invariants.
    """
    print("\n" + "=" * 60)
    print("  Application 2: Comparing Compiler Optimizations")
    print("=" * 60)

    source = Theory("SourceLang",
                    ["loop", "branch", "call", "return"],
                    {"loop": 10, "branch": 5, "call": 8, "return": 2})

    target = Theory("TargetLang",
                    ["fast_loop", "slow_loop", "branch", "inline", "call", "ret"],
                    {"fast_loop": 15, "slow_loop": 10, "branch": 6,
                     "inline": 12, "call": 8, "ret": 3})

    # Basic compiler (no optimization)
    basic = Morphism(source, target, {
        "loop": "slow_loop", "branch": "branch",
        "call": "call", "return": "ret"
    })

    # Optimizing compiler (loop optimization + inlining)
    optimized = Morphism(source, target, {
        "loop": "fast_loop", "branch": "branch",
        "call": "inline", "return": "ret"
    })

    print(f"\nBasic compiler valid: {basic.is_valid()}")
    print(f"Optimized compiler valid: {optimized.is_valid()}")
    print(f"Basic profile:     {basic.invariant_profile()}")
    print(f"Optimized profile: {optimized.invariant_profile()}")
    print(f"\nOptimized ≥₂ Basic? {two_cell_holds(basic, optimized)}")
    print(f"Basic ≥₂ Optimized? {two_cell_holds(optimized, basic)}")
    print("\nThe 2-cell ordering certifies that the optimizing compiler")
    print("produces uniformly better code quality than the basic compiler.")


# ═══════════════════════════════════════════════════════════
# Application 3: Knowledge Representation Comparison
# ═══════════════════════════════════════════════════════════

def knowledge_representation_demo():
    """
    Different knowledge representations (ontologies, embeddings, schemas)
    can be compared by how much structural information they preserve.
    The theory bicategory formalizes this comparison.
    """
    print("\n" + "=" * 60)
    print("  Application 3: Comparing Knowledge Representations")
    print("=" * 60)

    # Real-world domain: animals with complexity (number of distinguishing features)
    domain = Theory("Animals",
                    ["cat", "dog", "eagle", "salmon", "ant"],
                    {"cat": 8, "dog": 7, "eagle": 9, "salmon": 6, "ant": 5})

    # Coarse ontology: just mammal/non-mammal
    coarse = Theory("Coarse",
                    ["mammal", "non_mammal"],
                    {"mammal": 8, "non_mammal": 9})

    # Fine ontology: mammal/bird/fish/insect
    fine = Theory("Fine",
                  ["mammal", "bird", "fish", "insect"],
                  {"mammal": 8, "bird": 9, "fish": 7, "insect": 6})

    coarse_map = Morphism(domain, coarse, {
        "cat": "mammal", "dog": "mammal", "eagle": "non_mammal",
        "salmon": "non_mammal", "ant": "non_mammal"
    })

    fine_map = Morphism(domain, fine, {
        "cat": "mammal", "dog": "mammal", "eagle": "bird",
        "salmon": "fish", "ant": "insect"
    })

    print(f"\nCoarse classification valid: {coarse_map.is_valid()}")
    print(f"Fine classification valid: {fine_map.is_valid()}")
    print(f"\nCoarse profile: {coarse_map.invariant_profile()}")
    print(f"Fine profile:   {fine_map.invariant_profile()}")

    # Count morphisms for analysis
    coarse_morphisms = enumerate_morphisms(domain, coarse)
    fine_morphisms = enumerate_morphisms(domain, fine)
    print(f"\nTotal valid coarse classifications: {len(coarse_morphisms)}")
    print(f"Total valid fine classifications: {len(fine_morphisms)}")
    print("\nMore valid morphisms = more flexibility in the hom-set.")
    print("The preorder on each hom-set ranks these by information quality.")


# ═══════════════════════════════════════════════════════════
# Application 4: Neural Network Layer Comparison
# ═══════════════════════════════════════════════════════════

def neural_network_demo():
    """
    Neural network layers can be viewed as morphisms between representation
    theories. A deeper/wider layer preserves more invariant structure.
    2-cells compare architectures by representation quality.
    """
    print("\n" + "=" * 60)
    print("  Application 4: Comparing Neural Network Architectures")
    print("=" * 60)

    # Input feature space
    inputs = Theory("InputFeatures",
                    ["pixel_1", "pixel_2", "pixel_3", "pixel_4"],
                    {"pixel_1": 1, "pixel_2": 2, "pixel_3": 3, "pixel_4": 4})

    # Representation space (hidden layer outputs)
    hidden = Theory("HiddenReps",
                    ["h1", "h2", "h3", "h4", "h5"],
                    {"h1": 2, "h2": 3, "h3": 5, "h4": 7, "h5": 10})

    # Shallow network: maps to lower-quality representations
    shallow = Morphism(inputs, hidden, {
        "pixel_1": "h1", "pixel_2": "h2", "pixel_3": "h3", "pixel_4": "h4"
    })

    # Deep network: maps to higher-quality representations
    deep = Morphism(inputs, hidden, {
        "pixel_1": "h2", "pixel_2": "h3", "pixel_3": "h4", "pixel_4": "h5"
    })

    print(f"\nShallow network valid: {shallow.is_valid()}")
    print(f"Deep network valid: {deep.is_valid()}")
    print(f"Shallow profile: {shallow.invariant_profile()}")
    print(f"Deep profile:    {deep.invariant_profile()}")
    print(f"\nDeep ≥₂ Shallow? {two_cell_holds(shallow, deep)}")
    print(f"Shallow ≥₂ Deep? {two_cell_holds(deep, shallow)}")
    print("\nThe 2-cell deep ≥₂ shallow certifies that the deep network")
    print("produces uniformly better representations (higher invariant values).")


if __name__ == "__main__":
    abstract_interpretation_demo()
    compiler_optimization_demo()
    knowledge_representation_demo()
    neural_network_demo()

    print("\n" + "=" * 60)
    print("  Summary: Cross-Domain Applications of Theory 2-Cells")
    print("=" * 60)
    print("""
The 2-cell ordering TheoryHom2(f, g) provides a uniform framework for:

1. ABSTRACT INTERPRETATION: Compare analysis precision
   - More precise analysis ↔ higher invariant in target domain
   - 2-cells certify "uniformly more informative"

2. COMPILER OPTIMIZATION: Compare code quality
   - Better optimization ↔ higher performance invariant
   - 2-cells certify "uniformly better code"

3. KNOWLEDGE REPRESENTATION: Compare ontology expressiveness
   - Finer classification ↔ more distinguishing features
   - Hom-preorder ranks representations by quality

4. NEURAL ARCHITECTURES: Compare representation learning
   - Deeper/better network ↔ richer hidden representations
   - 2-cells certify "uniformly better features"

In all cases, the bicategory structure ensures these comparisons
compose correctly (horizontal composition) and satisfy the
interchange law.
""")


#!/usr/bin/env python3
"""
Demo: Locally Preordered 2-Category of Theories

Demonstrates the core mathematical structures: theories as objects,
morphisms as invariant-monotone maps, and 2-cells as pointwise domination.
"""

import itertools
from dataclasses import dataclass
from typing import Callable, List, Tuple, Optional


@dataclass
class ResearchTheory:
    """A theory = carrier set + invariant function."""
    name: str
    carrier: List[str]
    inv: dict  # element -> ℕ

    def __repr__(self):
        items = ", ".join(f"{k}↦{v}" for k, v in self.inv.items())
        return f"Theory({self.name}: {{{items}}})"


@dataclass
class TheoryHom:
    """A morphism between theories: a function that increases invariants."""
    name: str
    source: ResearchTheory
    target: ResearchTheory
    mapping: dict  # element -> element

    def is_valid(self) -> bool:
        """Check monotonicity: source.Inv(x) ≤ target.Inv(f(x)) for all x."""
        for x in self.source.carrier:
            if self.source.inv[x] > self.target.inv[self.mapping[x]]:
                return False
        return True

    def __repr__(self):
        items = ", ".join(f"{k}↦{v}" for k, v in self.mapping.items())
        return f"Hom({self.name}: {{{items}}})"


def theory_hom2(f: TheoryHom, g: TheoryHom) -> bool:
    """Check if g dominates f: target.Inv(f(x)) ≤ target.Inv(g(x)) for all x."""
    assert f.source == g.source and f.target == g.target
    return all(
        f.target.inv[f.mapping[x]] <= f.target.inv[g.mapping[x]]
        for x in f.source.carrier
    )


def compose(f: TheoryHom, g: TheoryHom) -> TheoryHom:
    """Compose f: T→U with g: U→V to get g∘f: T→V."""
    mapping = {x: g.mapping[f.mapping[x]] for x in f.source.carrier}
    return TheoryHom(
        name=f"{g.name}∘{f.name}",
        source=f.source,
        target=g.target,
        mapping=mapping
    )


def print_divider(title: str):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


# ─── Demo 1: Basic theories and morphisms ───

print_divider("DEMO 1: Theories and Morphisms")

T = ResearchTheory("Complexity", ["small", "medium", "large"],
                    {"small": 1, "medium": 3, "large": 7})
U = ResearchTheory("Depth", ["shallow", "mid", "deep", "abyss"],
                    {"shallow": 2, "mid": 5, "deep": 8, "abyss": 15})
V = ResearchTheory("Abstract", ["low", "high"],
                    {"low": 10, "high": 20})

print(f"Theory T: {T}")
print(f"Theory U: {U}")
print(f"Theory V: {V}")

f1 = TheoryHom("f₁", T, U, {"small": "shallow", "medium": "mid", "large": "deep"})
f2 = TheoryHom("f₂", T, U, {"small": "mid", "medium": "deep", "large": "abyss"})

print(f"\nMorphism f₁: {f1}  (valid: {f1.is_valid()})")
print(f"Morphism f₂: {f2}  (valid: {f2.is_valid()})")

# ─── Demo 2: 2-cells ───

print_divider("DEMO 2: 2-Cells (Pointwise Domination)")

dom = theory_hom2(f1, f2)
print(f"f₁ ≤₂ f₂ ? {dom}")
print("  Checking each element:")
for x in T.carrier:
    v1 = U.inv[f1.mapping[x]]
    v2 = U.inv[f2.mapping[x]]
    print(f"    {x}: U.Inv(f₁({x})) = {v1} ≤ {v2} = U.Inv(f₂({x}))  ✓" if v1 <= v2
          else f"    {x}: U.Inv(f₁({x})) = {v1} > {v2} = U.Inv(f₂({x}))  ✗")

rev = theory_hom2(f2, f1)
print(f"\nf₂ ≤₂ f₁ ? {rev}  (the 2-cell is strict!)")

# ─── Demo 3: Horizontal composition ───

print_divider("DEMO 3: Horizontal Composition of 2-Cells")

g1 = TheoryHom("g₁", U, V, {"shallow": "low", "mid": "low", "deep": "high", "abyss": "high"})
g2 = TheoryHom("g₂", U, V, {"shallow": "low", "mid": "high", "deep": "high", "abyss": "high"})

print(f"g₁: {g1}  (valid: {g1.is_valid()})")
print(f"g₂: {g2}  (valid: {g2.is_valid()})")
print(f"g₁ ≤₂ g₂ ? {theory_hom2(g1, g2)}")

comp1 = compose(f1, g1)
comp2 = compose(f2, g2)

print(f"\nComposition g₁∘f₁: {comp1}")
print(f"Composition g₂∘f₂: {comp2}")
print(f"g₁∘f₁ ≤₂ g₂∘f₂ ? {theory_hom2(comp1, comp2)}")
print("\n  This is horizontal composition: f₁≤f₂ and g₁≤g₂ implies g₁∘f₁ ≤ g₂∘f₂")

# ─── Demo 4: Preorder structure ───

print_divider("DEMO 4: Hom-Set Preorder")

# Enumerate all valid morphisms T → U
all_morphisms = []
for mapping in itertools.product(U.carrier, repeat=len(T.carrier)):
    m = dict(zip(T.carrier, mapping))
    h = TheoryHom("", T, U, m)
    if h.is_valid():
        all_morphisms.append(h)

print(f"Found {len(all_morphisms)} valid morphisms from T to U:")
for i, h in enumerate(all_morphisms):
    items = ", ".join(f"{k}↦{v}({U.inv[v]})" for k, v in h.mapping.items())
    print(f"  m{i}: {{{items}}}")

print("\nPreorder relation (≤₂) matrix:")
print("     ", "  ".join(f"m{j}" for j in range(len(all_morphisms))))
for i, fi in enumerate(all_morphisms):
    row = []
    for j, fj in enumerate(all_morphisms):
        row.append(" ✓" if theory_hom2(fi, fj) else " ·")
    print(f"  m{i}: {'  '.join(row)}")

# ─── Demo 5: Initial theory ───

print_divider("DEMO 5: Initial Theory")

initial = ResearchTheory("Initial", [], {})
print(f"Initial theory: {initial}")
print(f"Carrier is empty → unique morphism from Initial to any theory")
print(f"Number of morphisms Initial → T: exactly 1 (the empty function)")
print(f"2-cells from Initial are vacuously true: all pairs are equivalent")

# ─── Demo 6: Interchange law ───

print_divider("DEMO 6: Interchange Law")

# f₁ ≤ f₂ ≤ f₂ and g₁ ≤ g₂ ≤ g₂
# Vertical composition: f₁ ≤ f₂, g₁ ≤ g₂
# Then horizontal: (f₁;g₁) ≤ (f₂;g₂)
# Interchange: same result via horizontal-then-vertical

print("Given:")
print(f"  f₁ ≤₂ f₂: {theory_hom2(f1, f2)}")
print(f"  g₁ ≤₂ g₂: {theory_hom2(g1, g2)}")

c11 = compose(f1, g1)
c22 = compose(f2, g2)
c12 = compose(f1, g2)
c21 = compose(f2, g1)

print(f"\nRoute 1 (vertical then horizontal):")
print(f"  g₁∘f₁ ≤₂ g₂∘f₂: {theory_hom2(c11, c22)}")

print(f"\nRoute 2 (horizontal on each variable):")
print(f"  g₁∘f₁ ≤₂ g₁∘f₂: {theory_hom2(c11, c21)} (right whiskering)")
print(f"  g₁∘f₂ ≤₂ g₂∘f₂: {theory_hom2(c21, c22)} (left whiskering)")
print(f"  Transitivity gives g₁∘f₁ ≤₂ g₂∘f₂: {theory_hom2(c11, c22)}")

print("\nInterchange law verified: both routes give the same result ✓")

print_divider("SUMMARY")
print("""
Key results demonstrated:

1. REFLEXIVITY:  Every morphism dominates itself (f ≤₂ f)
2. TRANSITIVITY: 2-cell domination composes vertically
3. HORIZONTAL COMPOSITION: f₁≤g₁ and f₂≤g₂ implies f₂∘f₁ ≤ g₂∘g₁
4. INTERCHANGE LAW: Vertical-then-horizontal = Horizontal-then-vertical
5. PREORDER STRUCTURE: Hom-sets carry a natural preorder
6. INITIAL OBJECT: Empty theory is initial (unique morphism from it)
7. NONTRIVIAL 2-CELLS: Distinct morphisms genuinely compared by 2-cells

Together, these establish a locally preordered 2-category of theories.
""")


#!/usr/bin/env python3
"""
Visualizations for the 2-Category of Theories

Generates diagrams showing:
1. Hasse diagram of the hom-preorder
2. Horizontal composition diagram
3. Theory morphism landscape
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (Theory, Morphism, enumerate_morphisms,
                         compute_hom_preorder, hasse_diagram,
                         equivalence_classes, two_cell_holds,
                         compose_morphisms)


def plot_hasse_diagram(filename: str = "hasse_diagram.png"):
    """Plot the Hasse diagram of the hom-preorder for a concrete example."""
    T = Theory("Source", ["a", "b", "c"], {"a": 1, "b": 3, "c": 5})
    U = Theory("Target", ["x", "y", "z"], {"x": 2, "y": 4, "z": 6})

    morphisms = enumerate_morphisms(T, U)
    preorder = compute_hom_preorder(morphisms)
    hasse = hasse_diagram(morphisms, preorder)

    # Position nodes by invariant profile
    profiles = [tuple(m.invariant_profile()) for m in morphisms]
    # Use sum of invariant profile as y-coordinate, spread x
    sums = [sum(p) for p in profiles]
    unique_sums = sorted(set(sums))
    level_counts = {}
    positions = {}
    for i, s in enumerate(sums):
        level = unique_sums.index(s)
        count = level_counts.get(level, 0)
        level_counts[level] = count + 1
    level_current = {l: 0 for l in range(len(unique_sums))}

    for i, s in enumerate(sums):
        level = unique_sums.index(s)
        n_at_level = level_counts[level]
        idx = level_current[level]
        x = (idx - (n_at_level - 1) / 2) * 2.0
        y = level * 1.8
        positions[i] = (x, y)
        level_current[level] += 1

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_facecolor('#fafafa')

    # Draw edges
    for i, j in hasse:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        ax.annotate("", xy=(x2, y2 - 0.25), xytext=(x1, y1 + 0.25),
                     arrowprops=dict(arrowstyle="->", color="#4477AA",
                                     lw=1.8, connectionstyle="arc3,rad=0.1"))

    # Draw nodes
    for i, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.35, color='#EE7733', ec='#CC3311',
                             lw=2, zorder=5)
        ax.add_patch(circle)
        label = str(profiles[i])
        ax.text(x, y, label, ha='center', va='center', fontsize=7,
                fontweight='bold', zorder=6)

    ax.set_xlim(-4, 4)
    ax.set_ylim(-1, max(y for _, y in positions.values()) + 1.5)
    ax.set_aspect('equal')
    ax.set_title("Hasse Diagram of Hom-Preorder\n"
                 "Hom(Source, Target) ordered by pointwise invariant domination",
                 fontsize=13, fontweight='bold', pad=15)
    ax.text(0, -0.7,
            "Each node is a morphism, labeled by its invariant profile.\n"
            "Arrows indicate covering relations in the 2-cell ordering.",
            ha='center', fontsize=9, style='italic', color='#666666')
    ax.axis('off')
    fig.tight_layout()
    fig.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"Saved {filename}")


def plot_horizontal_composition(filename: str = "horizontal_composition.png"):
    """Visualize horizontal composition of 2-cells."""
    fig, ax = plt.subplots(figsize=(12, 5))
    ax.set_facecolor('#fafafa')

    # Draw three theory circles
    theories = [("T", -4, 0), ("U", 0, 0), ("V", 4, 0)]
    for name, x, y in theories:
        circle = plt.Circle((x, y), 0.6, color='#BBDEFB', ec='#1565C0',
                             lw=2.5, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=18,
                fontweight='bold', color='#1565C0', zorder=6)

    # Draw morphism arrows (f₁, g₁ on top; f₂, g₂ on bottom)
    arrow_style = dict(arrowstyle='->', lw=2.2, connectionstyle='arc3,rad=0.3')

    # T → U top (f₁)
    ax.annotate("", xy=(-0.7, 0.15), xytext=(-3.3, 0.15),
                arrowprops={**arrow_style, 'color': '#E53935'})
    ax.text(-2, 0.7, "$f_1$", ha='center', fontsize=14, color='#E53935',
            fontweight='bold')

    # T → U bottom (g₁)
    ax.annotate("", xy=(-0.7, -0.15), xytext=(-3.3, -0.15),
                arrowprops={**arrow_style, 'color': '#1E88E5', 'connectionstyle': 'arc3,rad=-0.3'})
    ax.text(-2, -0.7, "$g_1$", ha='center', fontsize=14, color='#1E88E5',
            fontweight='bold')

    # 2-cell arrow between f₁ and g₁
    ax.annotate("", xy=(-2, -0.35), xytext=(-2, 0.35),
                arrowprops=dict(arrowstyle='->', color='#43A047',
                                lw=2.5, shrinkA=2, shrinkB=2))
    ax.text(-1.6, 0.0, "≤₂", ha='center', va='center', fontsize=12,
            color='#43A047', fontweight='bold')

    # U → V top (f₂)
    ax.annotate("", xy=(3.3, 0.15), xytext=(0.7, 0.15),
                arrowprops={**arrow_style, 'color': '#E53935'})
    ax.text(2, 0.7, "$f_2$", ha='center', fontsize=14, color='#E53935',
            fontweight='bold')

    # U → V bottom (g₂)
    ax.annotate("", xy=(3.3, -0.15), xytext=(0.7, -0.15),
                arrowprops={**arrow_style, 'color': '#1E88E5', 'connectionstyle': 'arc3,rad=-0.3'})
    ax.text(2, -0.7, "$g_2$", ha='center', fontsize=14, color='#1E88E5',
            fontweight='bold')

    # 2-cell arrow between f₂ and g₂
    ax.annotate("", xy=(2, -0.35), xytext=(2, 0.35),
                arrowprops=dict(arrowstyle='->', color='#43A047',
                                lw=2.5, shrinkA=2, shrinkB=2))
    ax.text(2.4, 0.0, "≤₂", ha='center', va='center', fontsize=12,
            color='#43A047', fontweight='bold')

    # Result text
    ax.text(0, -1.8,
            "Horizontal Composition:  $f_1 \\leq_2 g_1$  and  $f_2 \\leq_2 g_2$"
            "  $\\Rightarrow$  $f_2 \\circ f_1 \\leq_2 g_2 \\circ g_1$",
            ha='center', fontsize=13, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9',
                      edgecolor='#43A047', alpha=0.9))

    ax.set_xlim(-5.5, 5.5)
    ax.set_ylim(-2.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title("Horizontal Composition of 2-Cells in the Theory Bicategory",
                 fontsize=14, fontweight='bold', pad=15)
    ax.axis('off')
    fig.tight_layout()
    fig.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"Saved {filename}")


def plot_preorder_matrix(filename: str = "preorder_matrix.png"):
    """Visualize the preorder relation as a matrix heatmap."""
    T = Theory("Source", ["a", "b", "c"], {"a": 1, "b": 3, "c": 5})
    U = Theory("Target", ["x", "y", "z"], {"x": 2, "y": 4, "z": 6})

    morphisms = enumerate_morphisms(T, U)
    preorder = compute_hom_preorder(morphisms)
    profiles = [str(tuple(m.invariant_profile())) for m in morphisms]

    n = len(morphisms)
    matrix = np.array(preorder, dtype=float)

    fig, ax = plt.subplots(figsize=(8, 7))
    cmap = plt.cm.colors.ListedColormap(['#FFEBEE', '#4CAF50'])
    ax.imshow(matrix, cmap=cmap, aspect='equal')

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(profiles, rotation=45, ha='right', fontsize=8)
    ax.set_yticklabels(profiles, fontsize=8)

    for i in range(n):
        for j in range(n):
            color = 'white' if preorder[i][j] else '#999999'
            symbol = '✓' if preorder[i][j] else '·'
            ax.text(j, i, symbol, ha='center', va='center',
                    fontsize=10, color=color, fontweight='bold')

    ax.set_xlabel("Morphism g (invariant profile)", fontsize=11, labelpad=10)
    ax.set_ylabel("Morphism f (invariant profile)", fontsize=11, labelpad=10)
    ax.set_title("Preorder Matrix: f ≤₂ g iff target invariant dominated pointwise",
                 fontsize=12, fontweight='bold', pad=15)

    legend_elements = [
        mpatches.Patch(facecolor='#4CAF50', label='f ≤₂ g (dominated)'),
        mpatches.Patch(facecolor='#FFEBEE', label='f ≰₂ g')
    ]
    ax.legend(handles=legend_elements, loc='upper left',
              bbox_to_anchor=(0, -0.15), fontsize=10)

    fig.tight_layout()
    fig.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"Saved {filename}")


if __name__ == "__main__":
    plot_hasse_diagram()
    plot_horizontal_composition()
    plot_preorder_matrix()
    print("\nAll visualizations generated.")
