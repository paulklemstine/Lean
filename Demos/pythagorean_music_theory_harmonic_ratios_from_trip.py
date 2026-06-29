#!/usr/bin/env python3
"""
Applications of Pythagorean Harmonic-Tropical Theory
=====================================================

Demonstrates real-world applications:
1. Scale generation from Pythagorean triple ratios
2. Tuning system comparison
3. Interval network / Tonnetz construction
4. Tropical coordinate visualization for music information retrieval
"""

import math
from fractions import Fraction
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Scale Generation from Pythagorean Triples
# ============================================================

def triple_to_intervals(a: int, b: int, c: int) -> List[Tuple[str, float]]:
    """
    Extract musical intervals from a Pythagorean triple as cents values.
    1200 cents = 1 octave.
    """
    ratios = [
        ("c/a", Fraction(c, a)),
        ("c/b", Fraction(c, b)),
        ("b/a", Fraction(b, a)),
    ]
    return [(name, 1200 * math.log2(float(r))) for name, r in ratios]


def generate_scale_from_triples(triples: List[Tuple[int, int, int]]) -> List[float]:
    """
    Generate a scale (in cents) by collecting all intervals from a set of
    Pythagorean triples, reduced to within one octave [0, 1200).
    """
    intervals = set()
    intervals.add(0.0)  # unison
    
    for triple in triples:
        for _, cents in triple_to_intervals(*triple):
            # Reduce to within one octave
            reduced = cents % 1200
            intervals.add(round(reduced, 2))
    
    return sorted(intervals)


print("=" * 70)
print("APPLICATION 1: Scale Generation from Pythagorean Triples")
print("=" * 70)

# Scale from root triple (3,4,5) alone
root_scale = generate_scale_from_triples([(3, 4, 5)])
print(f"\nScale from (3,4,5) alone:")
print(f"  Intervals (cents): {root_scale}")
print(f"  Number of distinct pitch classes: {len(root_scale)}")

# Scale from first-generation Berggren children
gen1_triples = [(3, 4, 5), (5, 12, 13), (21, 20, 29), (15, 8, 17)]
gen1_scale = generate_scale_from_triples(gen1_triples)
print(f"\nScale from root + depth-1 Berggren children:")
print(f"  Intervals (cents): {gen1_scale}")
print(f"  Number of distinct pitch classes: {len(gen1_scale)}")

# Compare with standard intervals
standard = {
    "perfect fourth": 498.04,
    "major third": 386.31,
    "major sixth": 884.36,
    "perfect fifth": 701.96,
}
print(f"\nStandard just intonation intervals for comparison:")
for name, cents in sorted(standard.items(), key=lambda x: x[1]):
    print(f"  {name}: {cents:.2f} cents")


# ============================================================
# Application 2: Tuning System Comparison
# ============================================================

print("\n" + "=" * 70)
print("APPLICATION 2: Tuning System Comparison")
print("=" * 70)

def equal_temperament_cents(n: int) -> float:
    """n-th semitone in 12-TET."""
    return 100.0 * n

def pythagorean_tuning_cents() -> Dict[str, float]:
    """Standard Pythagorean tuning intervals."""
    return {
        "unison": 0,
        "minor second": 1200 * math.log2(256/243),
        "major second": 1200 * math.log2(9/8),
        "minor third": 1200 * math.log2(32/27),
        "major third": 1200 * math.log2(81/64),
        "perfect fourth": 1200 * math.log2(4/3),
        "tritone": 1200 * math.log2(729/512),
        "perfect fifth": 1200 * math.log2(3/2),
        "minor sixth": 1200 * math.log2(128/81),
        "major sixth": 1200 * math.log2(27/16),
        "minor seventh": 1200 * math.log2(16/9),
        "major seventh": 1200 * math.log2(243/128),
    }

def just_intonation_cents() -> Dict[str, float]:
    """5-limit just intonation intervals."""
    return {
        "unison": 0,
        "minor second": 1200 * math.log2(16/15),
        "major second": 1200 * math.log2(9/8),
        "minor third": 1200 * math.log2(6/5),
        "major third": 1200 * math.log2(5/4),
        "perfect fourth": 1200 * math.log2(4/3),
        "tritone": 1200 * math.log2(45/32),
        "perfect fifth": 1200 * math.log2(3/2),
        "minor sixth": 1200 * math.log2(8/5),
        "major sixth": 1200 * math.log2(5/3),
        "minor seventh": 1200 * math.log2(9/5),
        "major seventh": 1200 * math.log2(15/8),
    }

pyth = pythagorean_tuning_cents()
just = just_intonation_cents()

print(f"\n{'Interval':<18} {'12-TET':<10} {'Pythagorean':<14} {'Just':<10} {'Pyth-12TET':<12}")
print("-" * 64)
for i, name in enumerate(["unison", "minor second", "major second", "minor third",
                           "major third", "perfect fourth", "tritone", "perfect fifth",
                           "minor sixth", "major sixth", "minor seventh", "major seventh"]):
    et = equal_temperament_cents(i)
    p = pyth.get(name, 0)
    j = just.get(name, 0)
    diff = p - et
    print(f"{name:<18} {et:<10.2f} {p:<14.2f} {j:<10.2f} {diff:+.2f}")

print(f"\nThe (3,4,5) triple naturally produces:")
print(f"  b/a = 4/3 → {1200*math.log2(4/3):.2f} cents (perfect fourth)")
print(f"  c/b = 5/4 → {1200*math.log2(5/4):.2f} cents (just major third)")
print(f"  c/a = 5/3 → {1200*math.log2(5/3):.2f} cents (just major sixth)")
print(f"\nThese are 5-limit just intonation intervals, NOT Pythagorean tuning.")
print(f"The (3,4,5) triple bridges Pythagorean number theory with just intonation!")


# ============================================================
# Application 3: Interval Network from Berggren Tree
# ============================================================

print("\n" + "=" * 70)
print("APPLICATION 3: Interval Network from Berggren Tree")
print("=" * 70)

def berggren_A(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def berggren_B(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def berggren_C(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def collect_intervals(max_depth: int) -> Dict[Fraction, List[Tuple[int, int, int]]]:
    """Collect all distinct side-ratios produced by Berggren tree."""
    intervals = {}
    queue = [(0, (3, 4, 5))]
    while queue:
        d, (a, b, c) = queue.pop(0)
        for num, den in [(c, a), (c, b), (b, a)]:
            r = Fraction(num, den)
            if r not in intervals:
                intervals[r] = []
            intervals[r].append((a, b, c))
        if d < max_depth:
            queue.append((d+1, berggren_A(a, b, c)))
            queue.append((d+1, berggren_B(a, b, c)))
            queue.append((d+1, berggren_C(a, b, c)))
    return intervals

intervals = collect_intervals(3)
print(f"\nDistinct intervals from depth ≤ 3: {len(intervals)}")
print(f"\nClosest to standard just intervals:")

targets = {
    "perfect fourth (4/3)": Fraction(4, 3),
    "perfect fifth (3/2)": Fraction(3, 2),
    "major third (5/4)": Fraction(5, 4),
    "minor third (6/5)": Fraction(6, 5),
    "major sixth (5/3)": Fraction(5, 3),
}

for name, target in targets.items():
    target_cents = 1200 * math.log2(float(target))
    closest = min(intervals.keys(),
                  key=lambda r: abs(1200 * math.log2(float(r)) - target_cents))
    closest_cents = 1200 * math.log2(float(closest))
    diff = closest_cents - target_cents
    triples = intervals[closest][:3]
    exact = "EXACT" if closest == target else f"off by {diff:+.1f}¢"
    print(f"  {name}: closest = {closest} ({exact})")
    print(f"    From triples: {triples}")


# ============================================================
# Application 4: Complexity Ranking of Intervals
# ============================================================

print("\n" + "=" * 70)
print("APPLICATION 4: Interval Complexity Ranking")
print("=" * 70)

def interval_complexity(r: Fraction) -> int:
    """Complexity = numerator + denominator (in lowest terms)."""
    return r.numerator + r.denominator

print(f"\nAll intervals from depth ≤ 2, sorted by complexity:")
intervals_d2 = collect_intervals(2)
sorted_intervals = sorted(intervals_d2.keys(), key=lambda r: (interval_complexity(r), float(r)))

print(f"{'Ratio':<12} {'Cents':<10} {'Complexity':<12} {'# Triples'}")
print("-" * 44)
for r in sorted_intervals[:20]:
    cents = 1200 * math.log2(float(r))
    cx = interval_complexity(r)
    count = len(intervals_d2[r])
    print(f"{str(r):<12} {cents:<10.2f} {cx:<12} {count}")

print(f"\nNote: The root triple (3,4,5) produces ALL intervals with complexity ≤ 8:")
for r in sorted_intervals:
    if interval_complexity(r) <= 8:
        cents = 1200 * math.log2(float(r))
        cx = interval_complexity(r)
        print(f"  {r} = {float(r):.4f} ({cents:.1f}¢, complexity {cx})")


#!/usr/bin/env python3
"""
Pythagorean Music Theory: Harmonic Ratios from Triple Lattices
==============================================================

Demonstrates the formally verified theorems connecting Pythagorean triples
to musical interval theory via the Berggren tree and tropical geometry.
"""

import math
from fractions import Fraction

# ============================================================
# Core definitions (matching the Lean formalization)
# ============================================================

def interval_log2(x: float) -> float:
    """Base-2 logarithm: intervalLog2(x) = log(x) / log(2)."""
    return math.log(x) / math.log(2)

def tropical_interval(x: float) -> float:
    """Tropical interval coordinate: τ(x) = -log₂(x). Positive for x ∈ (0,1)."""
    return -interval_log2(x)

def harmonic_embedding(a: int, b: int, c: int) -> tuple:
    """Embed a triple (a,b,c) into the tropical plane: (τ(a/c), τ(b/c))."""
    return (tropical_interval(a / c), tropical_interval(b / c))

def tropical_height(a: int, b: int, c: int) -> float:
    """Tropical height: min of the two tropical coordinates."""
    return min(tropical_interval(a / c), tropical_interval(b / c))

def fifth_coord(a: int, b: int) -> float:
    """Fifth coordinate: log₂(b/a)."""
    return interval_log2(b / a)

# ============================================================
# Berggren generators
# ============================================================

def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

# ============================================================
# Consonance classification
# ============================================================

CONSONANT_RATIOS = {
    Fraction(1, 1): "unison",
    Fraction(6, 5): "minor third",
    Fraction(5, 4): "major third",
    Fraction(4, 3): "perfect fourth",
    Fraction(3, 2): "perfect fifth",
    Fraction(5, 3): "major sixth",
    Fraction(2, 1): "octave",
}

def classify_ratios(a: int, b: int, c: int):
    """Extract and classify all six pairwise ratios of a triple."""
    pairs = [
        (c, a, "c/a"), (c, b, "c/b"), (b, a, "b/a"),
        (a, c, "a/c"), (b, c, "b/c"), (a, b, "a/b"),
    ]
    results = []
    for num, den, label in pairs:
        if den == 0:
            continue
        r = Fraction(num, den)
        name = CONSONANT_RATIOS.get(r, None)
        results.append((label, r, name))
    return results

def is_consonant(a: int, b: int, c: int) -> bool:
    """Check if any side-ratio is a simple consonant ratio."""
    for _, r, name in classify_ratios(a, b, c):
        if name is not None:
            return True
    return False

# ============================================================
# Berggren tree generation
# ============================================================

def berggren_tree(root, max_depth):
    """Generate the Berggren tree up to max_depth, yielding (depth, triple)."""
    queue = [(0, root)]
    while queue:
        depth, triple = queue.pop(0)
        yield depth, triple
        if depth < max_depth:
            a, b, c = triple
            queue.append((depth + 1, berggren_A(a, b, c)))
            queue.append((depth + 1, berggren_B(a, b, c)))
            queue.append((depth + 1, berggren_C(a, b, c)))

# ============================================================
# DEMO 1: Root triple interval analysis
# ============================================================

print("=" * 70)
print("DEMO 1: Root Triple (3, 4, 5) — Musical Interval Analysis")
print("=" * 70)

root = (3, 4, 5)
print(f"\nTriple: {root}")
print(f"Pythagorean check: {root[0]**2 + root[1]**2} = {root[2]**2} ✓\n")

print("Side ratios and musical intervals:")
for label, ratio, name in classify_ratios(*root):
    interval_name = name if name else "—"
    log2_val = interval_log2(float(ratio))
    print(f"  {label} = {ratio} = {float(ratio):.6f}  "
          f"log₂ = {log2_val:+.6f}  "
          f"interval: {interval_name}")

print(f"\nHarmonic embedding (tropical): {harmonic_embedding(*root)}")
print(f"Tropical height: {tropical_height(*root):.6f}")
print(f"Fifth coordinate: {fifth_coord(3, 4):.6f}")

# ============================================================
# DEMO 2: Berggren tree — first two levels
# ============================================================

print("\n" + "=" * 70)
print("DEMO 2: Berggren Tree — Harmonic Coordinates (depth ≤ 2)")
print("=" * 70)

print(f"\n{'Depth':<6} {'Triple':<20} {'Consonant?':<12} "
      f"{'τ(a/c)':<12} {'τ(b/c)':<12} {'Height':<12}")
print("-" * 74)

for depth, triple in berggren_tree((3, 4, 5), max_depth=2):
    a, b, c = triple
    cons = "YES" if is_consonant(a, b, c) else "no"
    emb = harmonic_embedding(a, b, c)
    h = tropical_height(a, b, c)
    print(f"{depth:<6} ({a},{b},{c}){'':<{15-len(f'({a},{b},{c})')}} "
          f"{cons:<12} {emb[0]:<12.6f} {emb[1]:<12.6f} {h:<12.6f}")

# ============================================================
# DEMO 3: Consonance sparsity in the Berggren tree
# ============================================================

print("\n" + "=" * 70)
print("DEMO 3: Consonance Sparsity in the Berggren Tree")
print("=" * 70)

for max_d in [3, 4, 5]:
    total = 0
    consonant_count = 0
    for depth, triple in berggren_tree((3, 4, 5), max_depth=max_d):
        total += 1
        if is_consonant(*triple):
            consonant_count += 1
    print(f"  Depth ≤ {max_d}: {consonant_count}/{total} triples are consonant "
          f"({100*consonant_count/total:.1f}%)")

# ============================================================
# DEMO 4: Tropical height growth
# ============================================================

print("\n" + "=" * 70)
print("DEMO 4: Tropical Height Along Berggren Paths")
print("=" * 70)

# Follow the A-path
print("\nA-path (successive childA applications):")
triple = (3, 4, 5)
for i in range(6):
    a, b, c = triple
    h = tropical_height(a, b, c)
    print(f"  Depth {i}: ({a},{b},{c})  height = {h:.6f}")
    triple = berggren_A(a, b, c)

# Follow the B-path
print("\nB-path (successive childB applications):")
triple = (3, 4, 5)
for i in range(6):
    a, b, c = triple
    h = tropical_height(a, b, c)
    print(f"  Depth {i}: ({a},{b},{c})  height = {h:.6f}")
    triple = berggren_B(a, b, c)

# ============================================================
# DEMO 5: Interval complexity and the uniqueness of (3,4,5)
# ============================================================

print("\n" + "=" * 70)
print("DEMO 5: Uniqueness of (3,4,5) — Minimal Consonant Primitive Triple")
print("=" * 70)

print("\nAll primitive Pythagorean triples with c ≤ 50:")
print(f"{'Triple':<20} {'Consonant?':<12} {'Consonant ratios'}")
print("-" * 60)

for c in range(1, 51):
    for a in range(1, c):
        for b in range(a, c):
            if a*a + b*b == c*c:
                if math.gcd(a, math.gcd(b, c)) == 1:
                    cons = is_consonant(a, b, c)
                    ratios_str = ""
                    if cons:
                        for label, ratio, name in classify_ratios(a, b, c):
                            if name:
                                ratios_str += f"{label}={ratio} ({name}) "
                    print(f"({a},{b},{c}){'':<{15-len(f'({a},{b},{c})')}} "
                          f"{'YES' if cons else 'no':<12} {ratios_str}")

print("\n✓ Formally verified: (3,4,5) is the UNIQUE primitive Pythagorean triple")
print("  with c ≤ 5 that is consonant under our classification.")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import base64
import json

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Catalog/Pythagorean/BerggrenHarmonicTropical.lean')

# Read images as base64
visualizations = []
for name in ['fig1_tropical_plane', 'fig2_consonance_sparsity', 'fig3_tropical_height', 'fig4_interval_circle']:
    with open(f'{name}.png', 'rb') as f:
        data = base64.b64encode(f.read()).decode('ascii')
        vis_name = name.replace('fig1_', '').replace('fig2_', '').replace('fig3_', '').replace('fig4_', '')
        visualizations.append({
            "name": name,
            "data": f"data:image/png;base64,{data}"
        })

package = {
    "title": "Pythagorean Music Theory: Harmonic Ratios from Triple Lattices",
    "domain": "Number Theory / Mathematical Music Theory / Tropical Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Pythagorean Harmonic Theory Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Scale Generation and Tuning Systems",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Berggren Tree BFS with Harmonic Annotation",
            "pseudocode": """Algorithm: BerggrenBFS(max_depth)
Input: max_depth (integer)
Output: Sequence of (depth, triple, tropical_coords, is_consonant)

1. Initialize queue ← [(0, (3,4,5))]
2. While queue is not empty:
   a. (d, (a,b,c)) ← dequeue
   b. Compute τ₁ = -log₂(a/c), τ₂ = -log₂(b/c)
   c. Check consonance: any of c/a, c/b, b/a in {1, 6/5, 5/4, 4/3, 3/2}
   d. Yield (d, (a,b,c), (τ₁,τ₂), consonant)
   e. If d < max_depth:
      i.   Enqueue (d+1, A(a,b,c))
      ii.  Enqueue (d+1, B(a,b,c))
      iii. Enqueue (d+1, C(a,b,c))

Time: O(3^max_depth)
Space: O(3^max_depth)""",
            "code": algorithms_code
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Visualizations for Pythagorean Harmonic-Tropical Theory
========================================================

Generates publication-quality figures as PNG files.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction
from collections import defaultdict

# ============================================================
# Berggren tree utilities
# ============================================================

def berggren_A(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def berggren_B(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def berggren_C(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def berggren_tree(max_depth):
    queue = [(0, (3, 4, 5), '', None)]
    while queue:
        d, triple, word, gen = queue.pop(0)
        yield d, triple, word, gen
        if d < max_depth:
            a, b, c = triple
            queue.append((d+1, berggren_A(a, b, c), word+'A', 'A'))
            queue.append((d+1, berggren_B(a, b, c), word+'B', 'B'))
            queue.append((d+1, berggren_C(a, b, c), word+'C', 'C'))

SIMPLE_CONSONANCES = {
    Fraction(1, 1), Fraction(6, 5), Fraction(5, 4),
    Fraction(4, 3), Fraction(3, 2), Fraction(5, 3),
}

def is_consonant(a, b, c):
    for num, den in [(c, a), (c, b), (b, a)]:
        if Fraction(num, den) in SIMPLE_CONSONANCES:
            return True
    return False


# ============================================================
# Figure 1: Tropical Plane Embedding
# ============================================================

def fig1_tropical_plane():
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    
    colors = {0: '#e74c3c', 1: '#3498db', 2: '#2ecc71', 3: '#9b59b6', 4: '#f39c12'}
    markers = {0: 'o', 1: 's', 2: '^', 3: 'D', 4: 'v'}
    
    for d, (a, b, c), word, gen in berggren_tree(4):
        tau_a = -math.log2(a / c)
        tau_b = -math.log2(b / c)
        color = colors.get(d, '#95a5a6')
        marker = markers.get(d, 'o')
        size = 120 if d == 0 else 60
        edge = 'black' if is_consonant(a, b, c) else 'none'
        linewidth = 2 if is_consonant(a, b, c) else 0
        
        ax.scatter(tau_a, tau_b, c=color, marker=marker, s=size,
                  edgecolors=edge, linewidths=linewidth, zorder=5)
        
        if d <= 1:
            ax.annotate(f'({a},{b},{c})', (tau_a, tau_b),
                       textcoords="offset points", xytext=(8, 8),
                       fontsize=8, color=color)
    
    # Draw the diagonal (τ_a = τ_b line)
    lim = ax.get_xlim()[1]
    ax.plot([0, lim], [0, lim], 'k--', alpha=0.3, label='τ₁ = τ₂')
    
    ax.set_xlabel('τ(a/c) = -log₂(a/c)', fontsize=12)
    ax.set_ylabel('τ(b/c) = -log₂(b/c)', fontsize=12)
    ax.set_title('Tropical Harmonic Plane: Berggren Tree Embedding', fontsize=14)
    
    legend_elements = [mpatches.Patch(facecolor=colors[d], label=f'Depth {d}')
                      for d in range(5)]
    legend_elements.append(mpatches.Patch(facecolor='white', edgecolor='black',
                                          linewidth=2, label='Consonant'))
    ax.legend(handles=legend_elements, loc='upper left')
    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('fig1_tropical_plane.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved fig1_tropical_plane.png")


# ============================================================
# Figure 2: Consonance Sparsity
# ============================================================

def fig2_consonance_sparsity():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    max_d = 7
    counts = defaultdict(lambda: [0, 0])
    for d, (a, b, c), word, gen in berggren_tree(max_d):
        counts[d][1] += 1
        if is_consonant(a, b, c):
            counts[d][0] += 1
    
    depths = sorted(counts.keys())
    consonant = [counts[d][0] for d in depths]
    total = [counts[d][1] for d in depths]
    density = [c/t if t > 0 else 0 for c, t in zip(consonant, total)]
    
    # Left panel: counts
    ax1.bar(depths, total, color='#3498db', alpha=0.6, label='Total triples')
    ax1.bar(depths, consonant, color='#e74c3c', alpha=0.8, label='Consonant')
    ax1.set_xlabel('Berggren Tree Depth', fontsize=12)
    ax1.set_ylabel('Number of Triples', fontsize=12)
    ax1.set_title('Triple Count by Depth', fontsize=13)
    ax1.legend()
    ax1.set_yscale('log')
    
    # Right panel: density
    ax2.plot(depths, density, 'ro-', markersize=8, linewidth=2)
    ax2.set_xlabel('Berggren Tree Depth', fontsize=12)
    ax2.set_ylabel('Consonance Density', fontsize=12)
    ax2.set_title('Consonance Density (fraction consonant)', fontsize=13)
    ax2.set_ylim(bottom=-0.05, top=max(density) + 0.1)
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Consonance Sparsity in the Berggren Tree', fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig('fig2_consonance_sparsity.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved fig2_consonance_sparsity.png")


# ============================================================
# Figure 3: Tropical Height Along Paths
# ============================================================

def fig3_tropical_height():
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    paths = {
        'A-path': 'A',
        'B-path': 'B',
        'C-path': 'C',
        'ABC-cycle': 'ABC',
    }
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
    generators = {
        'A': berggren_A,
        'B': berggren_B,
        'C': berggren_C,
    }
    
    for (name, path), color in zip(paths.items(), colors):
        triple = (3, 4, 5)
        heights = [min(-math.log2(triple[0]/triple[2]),
                       -math.log2(triple[1]/triple[2]))]
        
        for i in range(10):
            gen = path[i % len(path)]
            triple = generators[gen](*triple)
            h = min(-math.log2(triple[0]/triple[2]),
                    -math.log2(triple[1]/triple[2]))
            heights.append(h)
        
        ax.plot(range(len(heights)), heights, 'o-', color=color,
                label=name, markersize=6, linewidth=2)
    
    ax.set_xlabel('Generation Step', fontsize=12)
    ax.set_ylabel('Tropical Height', fontsize=12)
    ax.set_title('Tropical Height Evolution Along Berggren Paths', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('fig3_tropical_height.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved fig3_tropical_height.png")


# ============================================================
# Figure 4: Interval Circle (Tonnetz-like)
# ============================================================

def fig4_interval_circle():
    fig, ax = plt.subplots(1, 1, figsize=(9, 9))
    
    # Collect all distinct interval cents from depth ≤ 3
    intervals = set()
    for d, (a, b, c), word, gen in berggren_tree(3):
        for num, den in [(c, a), (c, b), (b, a)]:
            cents = 1200 * math.log2(num / den) % 1200
            intervals.add(round(cents, 1))
    
    intervals = sorted(intervals)
    
    # Standard consonances for reference
    consonant_cents = {
        0: "unison", 
        round(1200*math.log2(6/5), 1): "m3",
        round(1200*math.log2(5/4), 1): "M3",
        round(1200*math.log2(4/3), 1): "P4",
        round(1200*math.log2(3/2), 1): "P5",
        round(1200*math.log2(5/3), 1): "M6",
    }
    
    # Plot on a circle
    for cents in intervals:
        angle = 2 * math.pi * cents / 1200 - math.pi/2
        x = math.cos(angle)
        y = math.sin(angle)
        
        # Check if close to a consonance
        is_cons = any(abs(cents - cc) < 1 for cc in consonant_cents.keys())
        
        if is_cons:
            ax.plot(x, y, 'ro', markersize=12, zorder=5)
            name = ""
            for cc, n in consonant_cents.items():
                if abs(cents - cc) < 1:
                    name = n
            ax.annotate(f'{name}\n{cents:.0f}¢', (x, y),
                       textcoords="offset points", xytext=(15, 10),
                       fontsize=10, fontweight='bold', color='red')
        else:
            ax.plot(x, y, 'b.', markersize=4, alpha=0.5, zorder=3)
    
    # Draw circle
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2)
    
    # Draw 12-TET reference
    for i in range(12):
        angle = 2 * math.pi * i / 12 - math.pi/2
        x = 1.15 * math.cos(angle)
        y = 1.15 * math.sin(angle)
        ax.plot(1.05*math.cos(angle), 1.05*math.sin(angle), 'k+', 
                markersize=8, alpha=0.3)
    
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Interval Circle: Berggren Triple Intervals\n(red = consonant, blue = all others)',
                fontsize=13)
    ax.axis('off')
    
    fig.tight_layout()
    fig.savefig('fig4_interval_circle.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    print("Saved fig4_interval_circle.png")


# ============================================================
# Generate all figures
# ============================================================

if __name__ == "__main__":
    fig1_tropical_plane()
    fig2_consonance_sparsity()
    fig3_tropical_height()
    fig4_interval_circle()
    print("\nAll figures generated successfully.")
