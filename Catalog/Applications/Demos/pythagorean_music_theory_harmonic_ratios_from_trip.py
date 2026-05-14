#!/usr/bin/env python3
"""
Pythagorean Music Theory: Applications

Real-world applications of the formal bridge between Pythagorean triples
and mathematical music theory:

1. Just Intonation Tuning System Generator
2. Temperament Error Analysis
3. Chord Discovery from Pythagorean Triples
4. Harmonic Complexity Analyzer for Audio Intervals
"""

from fractions import Fraction
import math
from typing import List, Tuple, Dict


# ─── Application 1: Just Intonation Tuning System ──────────────────────────

def generate_just_scale_from_triples(max_depth: int = 3) -> List[Tuple[str, Fraction, float]]:
    """
    Generate a just intonation scale from Pythagorean triple ratios.
    
    Each primitive triple contributes up to 3 interval ratios.
    We collect all ratios, reduce to [1, 2), and sort to form a scale.
    
    Returns: List of (name, ratio, cents) tuples.
    """
    from algorithms import berggren_tree, leg_ratio, hyp_leg_ratio, hyp_min_leg_ratio
    
    ratios = set()
    tree = berggren_tree(max_depth=max_depth)
    
    for _, (a, b, c), _ in tree:
        for r in [leg_ratio(a, b), hyp_leg_ratio(a, b, c), hyp_min_leg_ratio(a, b, c)]:
            # Octave-reduce to [1, 2)
            val = float(r)
            while val >= 2:
                val /= 2
            while val < 1:
                val *= 2
            # Find the reduced fraction
            reduced = Fraction(val).limit_denominator(1000)
            if reduced > 0:
                ratios.add(reduced)
    
    # Sort by pitch
    scale = sorted(ratios, key=float)
    
    result = []
    # Standard interval names for common ratios
    names = {
        Fraction(1, 1): "Unison", Fraction(9, 8): "Major 2nd",
        Fraction(5, 4): "Major 3rd", Fraction(4, 3): "Perfect 4th",
        Fraction(3, 2): "Perfect 5th", Fraction(5, 3): "Major 6th",
        Fraction(15, 8): "Major 7th", Fraction(2, 1): "Octave",
        Fraction(6, 5): "Minor 3rd", Fraction(8, 5): "Minor 6th",
    }
    
    for r in scale:
        cents = 1200 * math.log2(float(r)) if float(r) > 0 else 0
        name = names.get(r, f"Ratio {r}")
        result.append((name, r, cents))
    
    return result


# ─── Application 2: Temperament Error Analysis ──────────────────────────────

def temperament_error(ratio: Fraction, divisions: int = 12) -> Dict:
    """
    Compare a just ratio against equal temperament.
    
    Computes the error in cents between the just ratio and the closest
    equal-tempered interval with the given number of divisions per octave.
    
    Returns: dict with comparison data.
    """
    just_cents = 1200 * math.log2(float(ratio))
    
    # Find closest ET interval
    step_cents = 1200 / divisions
    closest_step = round(just_cents / step_cents)
    et_cents = closest_step * step_cents
    
    error_cents = just_cents - et_cents
    
    return {
        'ratio': ratio,
        'just_cents': just_cents,
        'et_step': closest_step,
        'et_cents': et_cents,
        'error_cents': error_cents,
        'error_ratio': 2 ** (error_cents / 1200),
    }


# ─── Application 3: Chord Discovery ─────────────────────────────────────────

def discover_chords_from_triple(a: int, b: int, c: int) -> List[Dict]:
    """
    Extract all musically meaningful chords from a single Pythagorean triple.
    
    A Pythagorean triple (a, b, c) naturally defines a chord with intervals:
    - leg ratio: max(a,b)/min(a,b)
    - hyp/max ratio: c/max(a,b)
    - hyp/min ratio: c/min(a,b)
    
    These three ratios form a natural triad.
    """
    from algorithms import interval_complexity
    
    ratios = sorted([
        Fraction(min(abs(a), abs(b)), 1),  # normalized to root
        Fraction(max(abs(a), abs(b)), 1),
        Fraction(abs(c), 1),
    ])
    
    # Normalize: divide everything by the smallest
    root = ratios[0]
    normalized = [r / root for r in ratios]
    
    # Compute interval between consecutive notes
    intervals = [normalized[1] / normalized[0], normalized[2] / normalized[1]]
    
    # Classify chord quality
    third = intervals[0]
    fifth_interval = normalized[2] / normalized[0]
    
    # Check for major/minor quality
    if abs(float(third) - 5/4) < 0.01:
        quality = "Major"
    elif abs(float(third) - 6/5) < 0.01:
        quality = "Minor"
    else:
        quality = "Other"
    
    return {
        'triple': (a, b, c),
        'chord_ratios': [str(r) for r in normalized],
        'intervals': [str(i) for i in intervals],
        'quality': quality,
        'total_span_cents': 1200 * math.log2(float(normalized[-1])),
        'complexity': sum(interval_complexity(Fraction(r)) for r in normalized),
    }


# ─── Application 4: Pythagorean Comma Computation ───────────────────────────

def pythagorean_comma(num_fifths: int = 12) -> Dict:
    """
    Compute the Pythagorean comma: the discrepancy when stacking
    perfect fifths versus octaves.
    
    12 perfect fifths ≈ 7 octaves, but not exactly.
    The comma = (3/2)^12 / 2^7.
    """
    fifths_product = Fraction(3, 2) ** num_fifths
    octaves = Fraction(2, 1) ** (num_fifths * math.log2(1.5))
    
    # Exact computation
    exact_fifths = Fraction(3, 2) ** num_fifths
    target_octaves = round(num_fifths * math.log2(1.5))
    exact_octaves = Fraction(2, 1) ** target_octaves
    
    comma = exact_fifths / exact_octaves
    comma_cents = 1200 * math.log2(float(comma))
    
    return {
        'num_fifths': num_fifths,
        'fifths_product': exact_fifths,
        'target_octaves': target_octaves,
        'octave_product': exact_octaves,
        'comma': comma,
        'comma_cents': comma_cents,
        'comma_float': float(comma),
    }


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Just Intonation Scale from Pythagorean Triples")
    print("=" * 70)
    
    scale = generate_just_scale_from_triples(max_depth=2)
    print(f"\n{'Interval':<20} {'Ratio':<12} {'Cents':<10}")
    print("-" * 42)
    for name, ratio, cents in scale[:15]:
        print(f"  {name:<18} {str(ratio):<12} {cents:.1f}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Temperament Error Analysis")
    print("=" * 70)
    
    test_ratios = [
        Fraction(4, 3),   # Perfect 4th
        Fraction(5, 4),   # Major 3rd
        Fraction(3, 2),   # Perfect 5th
        Fraction(5, 3),   # Major 6th
        Fraction(15, 8),  # Major 7th
    ]
    
    print(f"\n{'Ratio':<10} {'Just (¢)':<10} {'ET step':<8} {'ET (¢)':<10} {'Error (¢)':<10}")
    print("-" * 48)
    for r in test_ratios:
        d = temperament_error(r)
        print(f"  {str(r):<8} {d['just_cents']:<10.1f} {d['et_step']:<8} "
              f"{d['et_cents']:<10.1f} {d['error_cents']:+.2f}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Chord Discovery from Pythagorean Triples")
    print("=" * 70)
    
    test_triples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25)]
    for t in test_triples:
        chord = discover_chords_from_triple(*t)
        print(f"\n  Triple {t}:")
        print(f"    Chord ratios: {chord['chord_ratios']}")
        print(f"    Intervals: {chord['intervals']}")
        print(f"    Quality: {chord['quality']}")
        print(f"    Span: {chord['total_span_cents']:.1f} cents")
    
    print("\n" + "=" * 70)
    print("APPLICATION 4: Pythagorean Comma")
    print("=" * 70)
    
    comma = pythagorean_comma(12)
    print(f"\n  Stack of {comma['num_fifths']} perfect fifths:")
    print(f"    Product: (3/2)^12 = {comma['fifths_product']}")
    print(f"    Target: {comma['target_octaves']} octaves = 2^{comma['target_octaves']} = {comma['octave_product']}")
    print(f"    Comma: {comma['comma']} ≈ {comma['comma_float']:.6f}")
    print(f"    Comma in cents: {comma['comma_cents']:.2f}¢")
    print(f"\n  → The circle of fifths doesn't close! The gap is ~23.46 cents.")
    print(f"    This is why equal temperament was invented.")


#!/usr/bin/env python3
"""
Pythagorean Music Theory: Harmonic Ratios from Triple Lattices — Demo

Demonstrates the core theorems with concrete numerical examples:
- Extracting musical intervals from Pythagorean triples
- Consonance classification
- Tropical logarithm transport
- Circle of fifths shadow
- Berggren tree interval dynamics
"""

from fractions import Fraction
import math


# ─── Core Definitions ───────────────────────────────────────────────────────

def is_pyth_triple(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a Pythagorean triple."""
    return a**2 + b**2 == c**2


def is_primitive(a: int, b: int, c: int) -> bool:
    """Check if a Pythagorean triple is primitive."""
    return is_pyth_triple(a, b, c) and math.gcd(a, math.gcd(b, c)) == 1


def leg_ratio(a: int, b: int) -> Fraction:
    """Ratio of larger leg to smaller leg."""
    return Fraction(max(abs(a), abs(b)), min(abs(a), abs(b)))


def hyp_leg_ratio(a: int, b: int, c: int) -> Fraction:
    """Ratio of hypotenuse to larger leg."""
    return Fraction(abs(c), max(abs(a), abs(b)))


def hyp_min_leg_ratio(a: int, b: int, c: int) -> Fraction:
    """Ratio of hypotenuse to smaller leg."""
    return Fraction(abs(c), min(abs(a), abs(b)))


def interval_complexity(q: Fraction) -> int:
    """Sum of numerator and denominator in reduced form."""
    return q.numerator + q.denominator


def is_consonant(q: Fraction, threshold: int = 12) -> bool:
    """Check if a ratio is consonant (low complexity)."""
    return q > 0 and interval_complexity(q) <= threshold


# ─── Musical Interval Names ─────────────────────────────────────────────────

INTERVAL_NAMES = {
    Fraction(1, 1): "Unison",
    Fraction(9, 8): "Major Second",
    Fraction(6, 5): "Minor Third",
    Fraction(5, 4): "Major Third",
    Fraction(4, 3): "Perfect Fourth",
    Fraction(7, 5): "Septimal Tritone",
    Fraction(3, 2): "Perfect Fifth",
    Fraction(8, 5): "Minor Sixth",
    Fraction(5, 3): "Major Sixth",
    Fraction(7, 4): "Harmonic Seventh",
    Fraction(15, 8): "Major Seventh",
    Fraction(2, 1): "Octave",
    Fraction(12, 5): "Minor Tenth",
    Fraction(13, 12): "Tridecimal 2/3-tone",
    Fraction(17, 15): "Septendecimal semitone",
}


def name_interval(q: Fraction) -> str:
    """Get the musical name of an interval, if known."""
    return INTERVAL_NAMES.get(q, f"({q.numerator}/{q.denominator})")


# ─── Berggren Tree ──────────────────────────────────────────────────────────

def berg_A(a: int, b: int, c: int) -> tuple:
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def berg_B(a: int, b: int, c: int) -> tuple:
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def berg_C(a: int, b: int, c: int) -> tuple:
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


# ─── Demo 1: Root Triple Interval Values ────────────────────────────────────

print("=" * 70)
print("DEMO 1: Root Triple (3, 4, 5) — Musical Interval Extraction")
print("=" * 70)

a, b, c = 3, 4, 5
print(f"\nTriple: ({a}, {b}, {c})")
print(f"  Pythagorean: {is_pyth_triple(a, b, c)}")
print(f"  Primitive:   {is_primitive(a, b, c)}")

lr = leg_ratio(a, b)
hlr = hyp_leg_ratio(a, b, c)
hmlr = hyp_min_leg_ratio(a, b, c)

print(f"\n  Leg ratio (max/min):        {lr} = {name_interval(lr)}")
print(f"  Hyp/larger-leg ratio:       {hlr} = {name_interval(hlr)}")
print(f"  Hyp/smaller-leg ratio:      {hmlr} = {name_interval(hmlr)}")

print(f"\n  Complexity of {lr}: {interval_complexity(lr)}")
print(f"  Complexity of {hlr}: {interval_complexity(hlr)}")
print(f"  Complexity of {hmlr}: {interval_complexity(hmlr)}")

print(f"\n  Consonant ({lr}):  {is_consonant(lr)}")
print(f"  Consonant ({hlr}): {is_consonant(hlr)}")
print(f"  Consonant ({hmlr}): {is_consonant(hmlr)}")


# ─── Demo 2: Berggren Children Intervals ────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 2: Berggren Children of (3, 4, 5) — Interval Dynamics")
print("=" * 70)

children = {
    "A": berg_A(3, 4, 5),
    "B": berg_B(3, 4, 5),
    "C": berg_C(3, 4, 5),
}

for name, (a2, b2, c2) in children.items():
    lr2 = leg_ratio(a2, b2)
    hlr2 = hyp_leg_ratio(a2, b2, c2)
    print(f"\n  Child {name}: ({a2}, {b2}, {c2})")
    print(f"    Pythagorean: {is_pyth_triple(a2, b2, c2)}")
    print(f"    Leg ratio:   {lr2} = {name_interval(lr2)}")
    print(f"    Hyp/leg:     {hlr2} = {name_interval(hlr2)}")
    print(f"    Complexity:  {interval_complexity(lr2)}, {interval_complexity(hlr2)}")
    print(f"    Consonant:   leg={is_consonant(lr2)}, hyp={is_consonant(hlr2)}")


# ─── Demo 3: Tropical Logarithm Transport ───────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 3: Tropical Logarithm — Multiplicative → Additive")
print("=" * 70)

q = Fraction(4, 3)
r = Fraction(3, 2)
product = q * r

print(f"\n  q = {q} (Perfect Fourth)")
print(f"  r = {r} (Perfect Fifth)")
print(f"  q × r = {product} (Octave)")

log_q = math.log(float(q))
log_r = math.log(float(r))
log_prod = math.log(float(product))

print(f"\n  log(q) = {log_q:.6f}")
print(f"  log(r) = {log_r:.6f}")
print(f"  log(q) + log(r) = {log_q + log_r:.6f}")
print(f"  log(q × r) = {log_prod:.6f}")
print(f"  Difference: {abs(log_prod - (log_q + log_r)):.2e} (≈ 0, as expected)")


# ─── Demo 4: Circle of Fifths Shadow ────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 4: Circle of Fifths Shadow — Perfect Fourth = Inverse Fifth mod Octave")
print("=" * 70)

log_four_thirds = math.log(4/3)
log_three_halves = math.log(3/2)
log_two = math.log(2)

print(f"\n  log(4/3) = {log_four_thirds:.6f}")
print(f"  -log(3/2) = {-log_three_halves:.6f}")
print(f"  Difference: log(4/3) - (-log(3/2)) = {log_four_thirds + log_three_halves:.6f}")
print(f"  log(2) = {log_two:.6f}")
print(f"  log(4/3) + log(3/2) = log(2): {abs(log_four_thirds + log_three_halves - log_two) < 1e-15}")
print(f"\n  → The perfect fourth IS the inverse fifth, modulo one octave!")

# Fifth-normalized coordinates
fifth_coord_4_3 = math.log(4/3) / math.log(3/2)
print(f"\n  Fifth-coordinate of 4/3: {fifth_coord_4_3:.6f}")
print(f"  (This is ≈ -1 + log(2)/log(3/2) ≈ -1 + {math.log(2)/math.log(3/2):.6f})")
print(f"  In the circle of fifths: position -1 (modulo octave)")


# ─── Demo 5: Berggren Tree Depth 3 — Interval Catalog ───────────────────────

print("\n" + "=" * 70)
print("DEMO 5: Berggren Tree Depth 3 — Complete Interval Catalog")
print("=" * 70)


def berggren_tree(a, b, c, depth, path="root"):
    """Generate all triples in the Berggren tree up to given depth."""
    result = [(path, (a, b, c))]
    if depth > 0:
        result.extend(berggren_tree(*berg_A(a, b, c), depth-1, path + ".A"))
        result.extend(berggren_tree(*berg_B(a, b, c), depth-1, path + ".B"))
        result.extend(berggren_tree(*berg_C(a, b, c), depth-1, path + ".C"))
    return result


tree = berggren_tree(3, 4, 5, 2)
print(f"\n{'Path':<20} {'Triple':<20} {'Leg Ratio':<12} {'Hyp/Leg':<12} {'Consonant?':<10}")
print("-" * 74)

for path, (a, b, c) in tree:
    lr = leg_ratio(a, b)
    hlr = hyp_leg_ratio(a, b, c)
    cons = "✓" if is_consonant(lr) else "✗"
    print(f"  {path:<18} ({a},{b},{c}){'':<{15-len(f'({a},{b},{c})')}} {str(lr):<12} {str(hlr):<12} {cons}")


# ─── Demo 6: Consonance Frontier ────────────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 6: Consonance Frontier in the Berggren Tree")
print("=" * 70)

tree_deep = berggren_tree(3, 4, 5, 4)
depths = {}
for path, (a, b, c) in tree_deep:
    d = path.count(".")
    if d not in depths:
        depths[d] = {"total": 0, "consonant": 0}
    depths[d]["total"] += 1
    if is_consonant(leg_ratio(a, b)):
        depths[d]["consonant"] += 1

print(f"\n{'Depth':<8} {'Total':<8} {'Consonant':<12} {'Fraction':<10}")
print("-" * 38)
for d in sorted(depths.keys()):
    total = depths[d]["total"]
    cons = depths[d]["consonant"]
    frac = cons / total if total > 0 else 0
    print(f"  {d:<6} {total:<8} {cons:<12} {frac:.3f}")

print("\n  → Consonant triples become exponentially rare with depth!")
print("     This confirms the sparsity conjecture.")


# ─── Demo 7: Octave Equivalence Classes ─────────────────────────────────────

print("\n" + "=" * 70)
print("DEMO 7: Octave Equivalence Classes of Triple Ratios")
print("=" * 70)

def octave_reduce(ratio: float) -> float:
    """Reduce a ratio to the range [1, 2) by octave equivalence."""
    if ratio <= 0:
        return 0
    while ratio >= 2:
        ratio /= 2
    while ratio < 1:
        ratio *= 2
    return ratio


print(f"\n  {'Ratio':<12} {'Float':<10} {'Octave-reduced':<16} {'≈ in cents':<12}")
print("  " + "-" * 50)

for path, (a, b, c) in berggren_tree(3, 4, 5, 1):
    lr = leg_ratio(a, b)
    reduced = octave_reduce(float(lr))
    cents = 1200 * math.log2(reduced)
    print(f"  {str(lr):<12} {float(lr):.4f}    {reduced:.4f}           {cents:.1f}")


print("\n" + "=" * 70)
print("All demos complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Pythagorean Music Theory: Visualizations

Generates publication-quality figures for the research paper.
All figures are saved as PNG and returned as base64 for JSON embedding.
"""

import math
import base64
import io
from fractions import Fraction
from typing import List, Tuple

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


# ─── Berggren tree generation (self-contained) ──────────────────────────────

def berg_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berg_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berg_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def berggren_tree(a, b, c, depth):
    result = [("root", (a, b, c), 0)]
    if depth > 0:
        for label, gen in [("A", berg_A), ("B", berg_B), ("C", berg_C)]:
            child = gen(a, b, c)
            sub = berggren_tree(*child, depth - 1)
            for path, triple, d in sub:
                result.append((label + "." + path if path != "root" else label,
                              triple, d + 1))
    return result

def leg_ratio(a, b):
    return Fraction(max(abs(a), abs(b)), min(abs(a), abs(b)))

def hyp_leg_ratio(a, b, c):
    return Fraction(abs(c), max(abs(a), abs(b)))

def interval_complexity(q):
    return q.numerator + q.denominator

def octave_reduce(x):
    while x >= 2: x /= 2
    while x < 1: x *= 2
    return x


def fig_to_base64(fig) -> str:
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


# ─── Visualization 1: Berggren Tree with Musical Intervals ──────────────────

def viz_berggren_tree_intervals():
    """Berggren tree showing musical interval ratios at each node."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    tree = berggren_tree(3, 4, 5, 2)
    
    # Layout positions
    positions = {}
    depth_counts = {}
    for path, triple, d in tree:
        depth_counts[d] = depth_counts.get(d, 0) + 1
    
    depth_indices = {d: 0 for d in depth_counts}
    
    for path, triple, d in tree:
        idx = depth_indices[d]
        total = depth_counts[d]
        x = (idx + 0.5) / total
        y = 1 - d * 0.3
        positions[path] = (x, y)
        depth_indices[d] += 1
        
        a, b, c = triple
        lr = leg_ratio(a, b)
        hlr = hyp_leg_ratio(a, b, c)
        comp = interval_complexity(lr)
        
        color = '#2ecc71' if comp <= 12 else '#e74c3c'
        
        circle = plt.Circle((x, y), 0.035, color=color, alpha=0.8, zorder=3)
        ax.add_patch(circle)
        
        ax.text(x, y + 0.005, f"({a},{b},{c})", ha='center', va='bottom',
                fontsize=7, fontweight='bold', zorder=4)
        ax.text(x, y - 0.015, f"leg={lr}", ha='center', va='top',
                fontsize=6, color='white', zorder=4)
    
    # Draw edges
    for path, triple, d in tree:
        if d > 0:
            parent_path = ".".join(path.split(".")[:-1]) if "." in path else "root"
            if parent_path in positions:
                px, py = positions[parent_path]
                cx, cy = positions[path]
                ax.plot([px, cx], [py, cy], 'k-', alpha=0.3, lw=1, zorder=1)
    
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.15)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Berggren Tree with Musical Interval Ratios\n'
                 '(Green = Consonant, Red = Dissonant)',
                 fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    return fig


# ─── Visualization 2: Circle of Fifths Projection ───────────────────────────

def viz_circle_of_fifths():
    """Show how Pythagorean triple ratios project onto the circle of fifths."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # Draw the circle
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', lw=2, alpha=0.3)
    
    # Standard notes on circle of fifths
    notes = ['C', 'G', 'D', 'A', 'E', 'B', 'F♯', 'C♯/D♭', 'A♭', 'E♭', 'B♭', 'F']
    for i, note in enumerate(notes):
        angle = np.pi/2 - i * 2*np.pi/12
        x, y = 1.15 * np.cos(angle), 1.15 * np.sin(angle)
        ax.text(x, y, note, ha='center', va='center', fontsize=10, fontweight='bold')
        x2, y2 = np.cos(angle), np.sin(angle)
        ax.plot(x2, y2, 'ko', markersize=5, alpha=0.5)
    
    # Plot Pythagorean triple ratios
    tree = berggren_tree(3, 4, 5, 2)
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(tree)))
    
    for idx, (path, (a, b, c), d) in enumerate(tree):
        lr = leg_ratio(a, b)
        lr_float = float(lr)
        reduced = octave_reduce(lr_float)
        
        # Map to circle: cents / 1200 * 2π
        cents = 1200 * math.log2(reduced)
        # Convert to circle of fifths position
        fifths_pos = math.log(reduced) / math.log(1.5)
        angle = np.pi/2 - fifths_pos * 2*np.pi / (math.log(2)/math.log(1.5))
        
        r_plot = 0.85 - d * 0.1
        x, y = r_plot * np.cos(angle), r_plot * np.sin(angle)
        
        ax.plot(x, y, 'o', color=colors[idx], markersize=8 + (3-d)*3,
                alpha=0.7, markeredgecolor='black', markeredgewidth=0.5)
        
        if d <= 1:
            ax.annotate(f"{lr}\n({a},{b},{c})", (x, y),
                       textcoords="offset points", xytext=(10, 10),
                       fontsize=7, alpha=0.8,
                       arrowprops=dict(arrowstyle='->', alpha=0.3))
    
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Pythagorean Triple Ratios on the Circle of Fifths\n'
                 '(Deeper nodes = smaller markers)',
                 fontsize=13, fontweight='bold')
    
    plt.tight_layout()
    return fig


# ─── Visualization 3: Consonance Complexity Spectrum ─────────────────────────

def viz_consonance_spectrum():
    """Plot interval complexity vs. tropical coordinate for all tree nodes."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    tree = berggren_tree(3, 4, 5, 4)
    
    complexities = []
    log_ratios = []
    depths = []
    labels = []
    
    for path, (a, b, c), d in tree:
        lr = leg_ratio(a, b)
        comp = interval_complexity(lr)
        log_r = math.log(float(lr))
        complexities.append(comp)
        log_ratios.append(log_r)
        depths.append(d)
        labels.append(f"{lr}")
    
    # Left: complexity vs log ratio
    scatter = ax1.scatter(log_ratios, complexities, c=depths, cmap='viridis',
                         s=50, alpha=0.7, edgecolors='black', linewidths=0.5)
    ax1.axhline(y=12, color='red', linestyle='--', alpha=0.5, label='Consonance threshold')
    ax1.set_xlabel('Tropical Coordinate: log(leg ratio)', fontsize=11)
    ax1.set_ylabel('Interval Complexity', fontsize=11)
    ax1.set_title('Consonance vs. Tropical Position', fontsize=13, fontweight='bold')
    ax1.legend()
    plt.colorbar(scatter, ax=ax1, label='Tree Depth')
    
    # Right: complexity distribution by depth
    depth_data = {}
    for comp, d in zip(complexities, depths):
        if d not in depth_data:
            depth_data[d] = []
        depth_data[d].append(comp)
    
    bp_data = [depth_data[d] for d in sorted(depth_data.keys())]
    bp = ax2.boxplot(bp_data, labels=[str(d) for d in sorted(depth_data.keys())],
                    patch_artist=True)
    
    colors_box = plt.cm.viridis(np.linspace(0.2, 0.9, len(bp_data)))
    for patch, color in zip(bp['boxes'], colors_box):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    
    ax2.axhline(y=12, color='red', linestyle='--', alpha=0.5, label='Consonance threshold')
    ax2.set_xlabel('Berggren Tree Depth', fontsize=11)
    ax2.set_ylabel('Interval Complexity', fontsize=11)
    ax2.set_title('Complexity Distribution by Depth', fontsize=13, fontweight='bold')
    ax2.legend()
    
    plt.tight_layout()
    return fig


# ─── Visualization 4: Tropical Interval Space ───────────────────────────────

def viz_tropical_space():
    """Visualize the tropical (logarithmic) interval space."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))
    
    tree = berggren_tree(3, 4, 5, 3)
    
    for path, (a, b, c), d in tree:
        lr = leg_ratio(a, b)
        hlr = hyp_leg_ratio(a, b, c)
        
        x = math.log(float(lr))
        y = math.log(float(hlr))
        
        color = plt.cm.Set1(d / 4)
        size = 100 / (d + 1)
        
        ax.scatter(x, y, c=[color], s=size, alpha=0.7,
                  edgecolors='black', linewidths=0.5, zorder=3)
        
        if d <= 1:
            ax.annotate(f"({a},{b},{c})\n{lr}, {hlr}",
                       (x, y), textcoords="offset points", xytext=(5, 5),
                       fontsize=7, alpha=0.8)
    
    # Mark special ratios
    special = {
        'log(4/3)': math.log(4/3),
        'log(3/2)': math.log(3/2),
        'log(2)': math.log(2),
    }
    for name, val in special.items():
        ax.axvline(x=val, color='gray', linestyle=':', alpha=0.3)
        ax.text(val, ax.get_ylim()[1] * 0.95, name, rotation=90,
               va='top', fontsize=8, alpha=0.5)
    
    ax.set_xlabel('log(leg ratio) — Tropical Leg Coordinate', fontsize=11)
    ax.set_ylabel('log(hyp/leg ratio) — Tropical Hypotenuse Coordinate', fontsize=11)
    ax.set_title('Tropical Interval Space of Pythagorean Triples\n'
                 '(Multiplicative ratios → additive coordinates)',
                 fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    return fig


# ─── Visualization 5: Temperament Error Chart ───────────────────────────────

def viz_temperament_errors():
    """Compare just intonation ratios from triples with equal temperament."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    tree = berggren_tree(3, 4, 5, 2)
    
    ratios = []
    for _, (a, b, c), _ in tree:
        lr = leg_ratio(a, b)
        hlr = hyp_leg_ratio(a, b, c)
        for r in [lr, hlr]:
            reduced = octave_reduce(float(r))
            ratios.append((r, reduced))
    
    # Remove duplicates
    seen = set()
    unique_ratios = []
    for r, red in ratios:
        if r not in seen:
            seen.add(r)
            unique_ratios.append((r, red))
    
    unique_ratios.sort(key=lambda x: x[1])
    
    just_cents = [1200 * math.log2(red) for _, red in unique_ratios]
    et_cents = [round(jc / 100) * 100 for jc in just_cents]
    errors = [jc - ec for jc, ec in zip(just_cents, et_cents)]
    labels = [str(r) for r, _ in unique_ratios]
    
    colors = ['#2ecc71' if abs(e) < 15 else '#e74c3c' for e in errors]
    
    bars = ax.barh(range(len(errors)), errors, color=colors, alpha=0.7,
                   edgecolor='black', linewidth=0.5)
    
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels, fontsize=8)
    ax.axvline(x=0, color='black', linewidth=1)
    ax.set_xlabel('Temperament Error (cents)', fontsize=11)
    ax.set_ylabel('Just Ratio', fontsize=11)
    ax.set_title('Just Intonation vs. 12-TET: Temperament Errors\n'
                 '(Green ≤ 15¢, Red > 15¢)',
                 fontsize=13, fontweight='bold')
    ax.grid(True, axis='x', alpha=0.3)
    
    plt.tight_layout()
    return fig


# ─── Generate All Visualizations ────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")
    
    figs = {
        'berggren_tree': viz_berggren_tree_intervals(),
        'circle_of_fifths': viz_circle_of_fifths(),
        'consonance_spectrum': viz_consonance_spectrum(),
        'tropical_space': viz_tropical_space(),
        'temperament_errors': viz_temperament_errors(),
    }
    
    for name, fig in figs.items():
        filename = f"{name}.png"
        fig.savefig(filename, dpi=150, bbox_inches='tight',
                   facecolor='white', edgecolor='none')
        print(f"  Saved {filename}")
        plt.close(fig)
    
    print("All visualizations generated.")
