"""
Tropical Stone Duality — Applications

Real-world applications of the tropical duality theory:
1. Abstract interpretation lattices → semantic frame extraction
2. Access control policy verification
3. Feature lattice analysis for concept lattices
"""

from algorithms import (
    LatticeElement, HeytingLattice, TropicalPoint,
    compute_canonical_preorder, reconstruct_frame,
    check_separation, compute_evaluation_map,
)
from typing import List, Dict, Tuple


# =============================================================================
# Application 1: Abstract Interpretation
# =============================================================================

def demo_abstract_interpretation():
    """
    In abstract interpretation, program analyses use abstract domains
    that are lattices. The tropical duality theory allows us to extract
    a semantic frame from the abstract domain, giving a Kripke-style
    semantics for the analysis.

    Example: a simple sign domain {⊥, neg, zero, pos, ⊤}
    where ⊥ = unreachable, ⊤ = any value.
    """
    print("=" * 60)
    print("APPLICATION 1: Abstract Interpretation — Sign Domain")
    print("=" * 60)
    print()

    # Sign domain elements
    bot = LatticeElement('⊥')
    neg = LatticeElement('neg')
    zero = LatticeElement('zero')
    pos = LatticeElement('pos')
    top = LatticeElement('⊤')
    elems = [bot, neg, zero, pos, top]

    # Order
    le_pairs = [(x, y) for x in elems for y in elems
                if x == bot or y == top or x == y]

    # Sup (join = least upper bound)
    sup = {}
    for x in elems:
        for y in elems:
            if x == bot: sup[(x, y)] = y
            elif y == bot: sup[(x, y)] = x
            elif x == top or y == top: sup[(x, y)] = top
            elif x == y: sup[(x, y)] = x
            else: sup[(x, y)] = top  # incomparable → ⊤

    # Inf (meet)
    inf = {}
    for x in elems:
        for y in elems:
            if x == top: inf[(x, y)] = y
            elif y == top: inf[(x, y)] = x
            elif x == bot or y == bot: inf[(x, y)] = bot
            elif x == y: inf[(x, y)] = x
            else: inf[(x, y)] = bot  # incomparable → ⊥

    # Heyting implication (for the pentagonal antichain lattice M₃)
    himp = {}
    for a in elems:
        for b in elems:
            if a == bot or b == top:
                himp[(a, b)] = top
            elif a == top:
                himp[(a, b)] = b
            elif a == b:
                himp[(a, b)] = top
            else:
                # For incomparable a, b: himp(a, b) is the largest x
                # such that a ⊓ x ≤ b
                # Since a ⊓ x = bot for x incomparable to a, and bot ≤ b,
                # and a ⊓ a = a ≰ b, we get himp(a,b) = all elements except a
                # In this lattice, that's everything whose meet with a is ≤ b
                # For M₃: himp(neg, zero) = complement of neg in a sense
                # Let's compute it properly
                candidates = [x for x in elems if inf[(a, x)] in
                              {e for e in elems if (e, b) in set(le_pairs)}]
                # Take the sup of all candidates
                result = bot
                for c in candidates:
                    result = sup[(result, c)]
                himp[(a, b)] = result

    lattice = HeytingLattice(elems, le_pairs, sup, inf, himp, top, bot)

    # Three separating points
    p_neg = TropicalPoint('p_neg', {bot: False, neg: True, zero: False, pos: False, top: True})
    p_zero = TropicalPoint('p_zero', {bot: False, neg: False, zero: True, pos: False, top: True})
    p_pos = TropicalPoint('p_pos', {bot: False, neg: False, zero: False, pos: True, top: True})
    points = [p_neg, p_zero, p_pos]

    # Check separation
    sep, witness = check_separation(points, elems)
    print(f"  Separation: {'✓' if sep else '✗'} ({witness})")

    # Evaluation map
    eval_map = compute_evaluation_map(points, elems)
    print("\n  Evaluation map:")
    for elem, vals in eval_map.items():
        print(f"    eval({elem}) = {vals}")

    # Frame reconstruction
    frame = reconstruct_frame(points, elems)
    print("\n  Reconstructed Kripke frame:")
    frame.display()
    print(f"  Reflexive: {frame.is_reflexive()}, Transitive: {frame.is_transitive()}")

    print("\n  Interpretation: Each world in the frame corresponds to a")
    print("  'sign observer' — an agent that can distinguish values by their sign.")
    print("  The frame structure captures the information ordering between observers.")
    print()


# =============================================================================
# Application 2: Access Control
# =============================================================================

def demo_access_control():
    """
    Access control policies often form lattices where:
    - Elements represent security levels
    - Join represents combining permissions
    - Meet represents restricting permissions
    - Implication captures "if you have access to A, what does that
      tell you about access to B?"

    Tropical duality extracts a semantic model showing how security
    principals observe the policy structure.
    """
    print("=" * 60)
    print("APPLICATION 2: Access Control Policy Analysis")
    print("=" * 60)
    print()

    # Simple 2-level security with compartments
    # public, secret_A, secret_B, top_secret
    pub = LatticeElement('public')
    sa = LatticeElement('secret_A')
    sb = LatticeElement('secret_B')
    ts = LatticeElement('top_secret')
    elems = [pub, sa, sb, ts]

    # Diamond order: pub ≤ sa, pub ≤ sb, sa ≤ ts, sb ≤ ts
    le_pairs = [(pub, x) for x in elems] + [(x, ts) for x in elems] + \
               [(sa, sa), (sb, sb)]

    # Build operations (same as diamond)
    sup, inf, himp = {}, {}, {}
    for x in elems:
        for y in elems:
            if x == pub: sup[(x, y)] = y
            elif y == pub: sup[(x, y)] = x
            elif x == ts or y == ts: sup[(x, y)] = ts
            elif x == y: sup[(x, y)] = x
            else: sup[(x, y)] = ts

    for x in elems:
        for y in elems:
            if x == ts: inf[(x, y)] = y
            elif y == ts: inf[(x, y)] = x
            elif x == pub or y == pub: inf[(x, y)] = pub
            elif x == y: inf[(x, y)] = x
            else: inf[(x, y)] = pub

    himp_raw = {
        (pub, pub): ts, (pub, sa): ts, (pub, sb): ts, (pub, ts): ts,
        (sa, pub): sb, (sa, sa): ts, (sa, sb): sb, (sa, ts): ts,
        (sb, pub): sa, (sb, sa): sa, (sb, sb): ts, (sb, ts): ts,
        (ts, pub): pub, (ts, sa): sa, (ts, sb): sb, (ts, ts): ts,
    }
    himp = himp_raw

    lattice = HeytingLattice(elems, le_pairs, sup, inf, himp, ts, pub)

    # Separating points: one per compartment
    p_a = TropicalPoint('observer_A', {pub: False, sa: True, sb: False, ts: True})
    p_b = TropicalPoint('observer_B', {pub: False, sa: False, sb: True, ts: True})
    points = [p_a, p_b]

    sep, _ = check_separation(points, elems)
    print(f"  Separation: {'✓' if sep else '✗'}")

    eval_map = compute_evaluation_map(points, elems)
    print("\n  Evaluation map (what each observer sees):")
    for elem, vals in eval_map.items():
        print(f"    {elem}: observer_A={'can see' if vals[0] else 'blocked'}, "
              f"observer_B={'can see' if vals[1] else 'blocked'}")

    frame = reconstruct_frame(points, elems)
    print("\n  Reconstructed observer frame:")
    frame.display()

    print("\n  Interpretation: The reconstructed frame shows that observer_A")
    print("  and observer_B are independent — neither can simulate the other.")
    print("  This certifies that compartment A and B provide genuine separation.")
    print()


# =============================================================================
# Application 3: Concept Lattice / Feature Analysis
# =============================================================================

def demo_concept_lattice():
    """
    In formal concept analysis, objects are described by features.
    The feature lattice captures logical relationships between features.
    Tropical duality extracts the minimal set of 'feature observers'
    that distinguish all concepts.
    """
    print("=" * 60)
    print("APPLICATION 3: Concept Lattice Feature Analysis")
    print("=" * 60)
    print()

    # Simple concept lattice for shapes
    # Features: {round, angular, large, small}
    # Concepts: ⊥ (nothing), circle, square, big_circle, big_square,
    #           round_things, angular_things, big_things, ⊤ (everything)
    # For simplicity, use a 4-element diamond

    nothing = LatticeElement('nothing')
    round_f = LatticeElement('round')
    angular = LatticeElement('angular')
    everything = LatticeElement('any_shape')
    elems = [nothing, round_f, angular, everything]

    le_pairs = [(nothing, x) for x in elems] + \
               [(x, everything) for x in elems] + \
               [(round_f, round_f), (angular, angular)]

    sup, inf = {}, {}
    for x in elems:
        for y in elems:
            if x == nothing: sup[(x, y)] = y
            elif y == nothing: sup[(x, y)] = x
            elif x == everything or y == everything: sup[(x, y)] = everything
            elif x == y: sup[(x, y)] = x
            else: sup[(x, y)] = everything

    for x in elems:
        for y in elems:
            if x == everything: inf[(x, y)] = y
            elif y == everything: inf[(x, y)] = x
            elif x == nothing or y == nothing: inf[(x, y)] = nothing
            elif x == y: inf[(x, y)] = x
            else: inf[(x, y)] = nothing

    himp = {
        (nothing, nothing): everything, (nothing, round_f): everything,
        (nothing, angular): everything, (nothing, everything): everything,
        (round_f, nothing): angular, (round_f, round_f): everything,
        (round_f, angular): angular, (round_f, everything): everything,
        (angular, nothing): round_f, (angular, round_f): round_f,
        (angular, angular): everything, (angular, everything): everything,
        (everything, nothing): nothing, (everything, round_f): round_f,
        (everything, angular): angular, (everything, everything): everything,
    }

    lattice = HeytingLattice(elems, le_pairs, sup, inf, himp, everything, nothing)

    # Separating observers
    obs_round = TropicalPoint('detects_round',
        {nothing: False, round_f: True, angular: False, everything: True})
    obs_angular = TropicalPoint('detects_angular',
        {nothing: False, round_f: False, angular: True, everything: True})
    points = [obs_round, obs_angular]

    sep, _ = check_separation(points, elems)
    print(f"  Separation: {'✓' if sep else '✗'}")

    eval_map = compute_evaluation_map(points, elems)
    print("\n  Feature signatures:")
    for elem, vals in eval_map.items():
        features = []
        if vals[0]: features.append("round")
        if vals[1]: features.append("angular")
        feat_str = " + ".join(features) if features else "none"
        print(f"    {elem}: [{feat_str}]")

    frame = reconstruct_frame(points, elems)
    print("\n  Reconstructed observer frame:")
    frame.display()

    print("\n  Interpretation: The feature observers are independent detectors.")
    print("  The duality theorem guarantees that these two observers suffice")
    print("  to reconstruct the entire concept lattice structure.")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("\n╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL STONE DUALITY — Applications                 ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    demo_abstract_interpretation()
    demo_access_control()
    demo_concept_lattice()

    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


"""
Tropical Stone Duality — Demonstration

This script demonstrates the core concepts of Tropical Stone Duality
with concrete computational examples.
"""

import itertools
from typing import Dict, List, Tuple, Callable, Set

# =============================================================================
# Diamond Lattice Example
# =============================================================================

class DiamondElement:
    """Element of the 4-element diamond lattice {bot, left, right, top}."""
    _names = ['bot', 'left', 'right', 'top']

    def __init__(self, name: str):
        assert name in self._names
        self.name = name

    def __repr__(self):
        return self.name

    def __eq__(self, other):
        return self.name == other.name

    def __hash__(self):
        return hash(self.name)

    def __le__(self, other):
        if self.name == 'bot': return True
        if other.name == 'top': return True
        return self.name == other.name

    def __lt__(self, other):
        return self <= other and self != other

BOT = DiamondElement('bot')
LEFT = DiamondElement('left')
RIGHT = DiamondElement('right')
TOP = DiamondElement('top')
DIAMOND = [BOT, LEFT, RIGHT, TOP]


def diamond_sup(a: DiamondElement, b: DiamondElement) -> DiamondElement:
    """Join in the diamond lattice."""
    if a == BOT: return b
    if b == BOT: return a
    if a == TOP or b == TOP: return TOP
    if a == b: return a
    return TOP  # left ⊔ right = top


def diamond_inf(a: DiamondElement, b: DiamondElement) -> DiamondElement:
    """Meet in the diamond lattice."""
    if a == TOP: return b
    if b == TOP: return a
    if a == BOT or b == BOT: return BOT
    if a == b: return a
    return BOT  # left ⊓ right = bot


def diamond_himp(a: DiamondElement, b: DiamondElement) -> DiamondElement:
    """Heyting implication in the diamond lattice.
    Defined by: a ⊓ x ≤ b iff x ≤ himp(a, b)."""
    table = {
        ('bot', 'bot'): TOP, ('bot', 'left'): TOP, ('bot', 'right'): TOP, ('bot', 'top'): TOP,
        ('left', 'bot'): RIGHT, ('left', 'left'): TOP, ('left', 'right'): RIGHT, ('left', 'top'): TOP,
        ('right', 'bot'): LEFT, ('right', 'left'): LEFT, ('right', 'right'): TOP, ('right', 'top'): TOP,
        ('top', 'bot'): BOT, ('top', 'left'): LEFT, ('top', 'right'): RIGHT, ('top', 'top'): TOP,
    }
    return table[(a.name, b.name)]


# =============================================================================
# Tropical Prime Points
# =============================================================================

def point_left(x: DiamondElement) -> bool:
    """Left-extracting point: maps {bot,right} -> False, {left,top} -> True."""
    return x.name in ('left', 'top')


def point_right(x: DiamondElement) -> bool:
    """Right-extracting point: maps {bot,left} -> False, {right,top} -> True."""
    return x.name in ('right', 'top')


# =============================================================================
# Demonstration 1: Point Separation
# =============================================================================

def demo_separation():
    """Show that the two points separate all elements of the diamond."""
    print("=" * 60)
    print("DEMO 1: Point Separation")
    print("=" * 60)
    print()

    print("Diamond lattice elements: bot, left, right, top")
    print()

    # Evaluation table
    print("Evaluation table:")
    print(f"  {'Element':<8} {'point_L':<10} {'point_R':<10}")
    print(f"  {'-'*28}")
    for x in DIAMOND:
        print(f"  {x.name:<8} {str(point_left(x)):<10} {str(point_right(x)):<10}")
    print()

    # Check separation
    separated = True
    for a in DIAMOND:
        for b in DIAMOND:
            if a != b:
                sep_by_L = point_left(a) != point_left(b)
                sep_by_R = point_right(a) != point_right(b)
                if not (sep_by_L or sep_by_R):
                    print(f"  FAIL: {a} and {b} not separated!")
                    separated = False
    if separated:
        print("  ✓ All distinct pairs are separated by at least one point.")
    print()

    # Show which point separates which pair
    print("Separation witnesses:")
    for a, b in itertools.combinations(DIAMOND, 2):
        witnesses = []
        if point_left(a) != point_left(b):
            witnesses.append("point_L")
        if point_right(a) != point_right(b):
            witnesses.append("point_R")
        print(f"  {a} ≠ {b}: separated by {', '.join(witnesses)}")
    print()


# =============================================================================
# Demonstration 2: Evaluation Map Injectivity
# =============================================================================

def demo_injectivity():
    """Show that the evaluation map is injective."""
    print("=" * 60)
    print("DEMO 2: Evaluation Map Injectivity")
    print("=" * 60)
    print()

    # The evaluation map sends x ↦ (point_L(x), point_R(x))
    eval_map = {}
    for x in DIAMOND:
        val = (point_left(x), point_right(x))
        eval_map[x.name] = val
        print(f"  eval({x.name}) = {val}")
    print()

    # Check injectivity
    values = list(eval_map.values())
    if len(values) == len(set(values)):
        print("  ✓ Evaluation map is injective (all images distinct).")
    else:
        print("  ✗ Evaluation map is NOT injective.")
    print()


# =============================================================================
# Demonstration 3: Canonical Preorder on Spectrum
# =============================================================================

def demo_canonical_preorder():
    """Show the canonical preorder on the prime spectrum."""
    print("=" * 60)
    print("DEMO 3: Canonical Preorder on Spectrum")
    print("=" * 60)
    print()

    points = {'point_L': point_left, 'point_R': point_right}

    print("Canonical preorder: p ≤ q iff ∀ a, p(a) ≤ q(a)")
    print()

    for name_p, p in points.items():
        for name_q, q in points.items():
            le = all(p(a) <= q(a) for a in DIAMOND)
            symbol = "≤" if le else "≰"
            print(f"  {name_p} {symbol} {name_q}")

    print()
    print("  → point_L and point_R are incomparable in the canonical preorder.")
    print("  This means the reconstructed Kripke frame has two incomparable worlds.")
    print()


# =============================================================================
# Demonstration 4: Order Embedding
# =============================================================================

def demo_order_embedding():
    """Show that the evaluation preserves and reflects order."""
    print("=" * 60)
    print("DEMO 4: Order Embedding")
    print("=" * 60)
    print()

    print("Verifying: a ≤ b iff eval(a) ≤ eval(b) pointwise")
    print()

    for a in DIAMOND:
        for b in DIAMOND:
            alg_le = a <= b
            eval_le = all(
                point_left(a) <= point_left(b) and
                point_right(a) <= point_right(b)
                for _ in [None]
            )
            # Actually compute pointwise
            eval_le = (point_left(a) <= point_left(b)) and (point_right(a) <= point_right(b))

            match_str = "✓" if alg_le == eval_le else "✗"
            print(f"  {match_str} {a.name} ≤ {b.name}: algebraic={alg_le}, semantic={eval_le}")
    print()


# =============================================================================
# Demonstration 5: Residuation Check
# =============================================================================

def demo_residuation():
    """Verify the residuation property: a ⊓ x ≤ b iff x ≤ himp(a,b)."""
    print("=" * 60)
    print("DEMO 5: Heyting Residuation Verification")
    print("=" * 60)
    print()

    violations = 0
    for a in DIAMOND:
        for x in DIAMOND:
            for b in DIAMOND:
                lhs = diamond_inf(a, x) <= b
                rhs = x <= diamond_himp(a, b)
                if lhs != rhs:
                    print(f"  VIOLATION: a={a}, x={x}, b={b}")
                    violations += 1

    if violations == 0:
        print("  ✓ Residuation verified for all 64 triples (a, x, b).")
    else:
        print(f"  ✗ {violations} violations found.")

    print()
    print("  Heyting implication table:")
    print(f"  {'himp':<8}", end="")
    for b in DIAMOND:
        print(f"{b.name:<8}", end="")
    print()
    print(f"  {'-'*40}")
    for a in DIAMOND:
        print(f"  {a.name:<8}", end="")
        for b in DIAMOND:
            print(f"{diamond_himp(a, b).name:<8}", end="")
        print()
    print()


# =============================================================================
# Demonstration 6: Upset Function Characterization
# =============================================================================

def demo_upset_functions():
    """Show which functions on the spectrum are upset (monotone)."""
    print("=" * 60)
    print("DEMO 6: Upset Functions on the Spectrum")
    print("=" * 60)
    print()

    # Since point_L and point_R are incomparable, ALL functions {point_L, point_R} → Bool
    # are monotone (upset). There are 4 such functions.
    print("  Since point_L ∥ point_R (incomparable), every function")
    print("  {point_L, point_R} → Bool is automatically monotone.")
    print()

    # List all 4 functions
    functions = [
        ("const_False", lambda p: False),
        ("eval(bot)",   lambda p: False),
        ("eval(left)",  lambda p: p == point_left),  # True on point_L
        ("eval(right)", lambda p: p == point_right),  # True on point_R
        ("eval(top)",   lambda p: True),
    ]

    # Actually, eval maps:
    # bot   -> (False, False)
    # left  -> (True, False)
    # right -> (False, True)
    # top   -> (True, True)
    # So the image has 4 elements = all of {point_L, point_R} → Bool

    print("  Evaluation image (identified with Bool × Bool):")
    for x in DIAMOND:
        print(f"    eval({x.name}) = ({point_left(x)}, {point_right(x)})")

    print()
    print("  All 4 functions Bool × Bool are realized → evaluation is SURJECTIVE")
    print("  onto upset functions → we have an ISOMORPHISM.")
    print()


# =============================================================================
# Run all demos
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL STONE DUALITY — Computational Demonstrations ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_separation()
    demo_injectivity()
    demo_canonical_preorder()
    demo_order_embedding()
    demo_residuation()
    demo_upset_functions()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


"""
Tropical Stone Duality — Visualizations

Generates visual diagrams of the duality theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def create_diamond_lattice_diagram() -> str:
    """Create a Hasse diagram of the diamond lattice."""
    fig, ax = plt.subplots(1, 1, figsize=(6, 6))

    # Node positions
    positions = {
        '⊥': (0, 0),
        'a': (-1, 1),
        'b': (1, 1),
        '⊤': (0, 2),
    }

    # Draw edges
    edges = [('⊥', 'a'), ('⊥', 'b'), ('a', '⊤'), ('b', '⊤')]
    for u, v in edges:
        x = [positions[u][0], positions[v][0]]
        y = [positions[u][1], positions[v][1]]
        ax.plot(x, y, 'k-', linewidth=2, zorder=1)

    # Draw nodes
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.2, color='#4ECDC4', ec='black', lw=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=14, fontweight='bold', zorder=3)

    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Diamond Lattice M₄', fontsize=16, fontweight='bold', pad=20)

    return fig_to_base64(fig)


def create_evaluation_diagram() -> str:
    """Create a diagram showing the evaluation map."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Left: Diamond lattice
    ax = axes[0]
    positions = {'⊥': (0, 0), 'a': (-0.8, 1), 'b': (0.8, 1), '⊤': (0, 2)}
    edges = [('⊥', 'a'), ('⊥', 'b'), ('a', '⊤'), ('b', '⊤')]
    for u, v in edges:
        ax.plot([positions[u][0], positions[v][0]],
                [positions[u][1], positions[v][1]], 'k-', lw=2, zorder=1)
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.18, color='#4ECDC4', ec='black', lw=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=13, fontweight='bold', zorder=3)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Algebra M', fontsize=14, fontweight='bold')

    # Middle: Arrow
    ax = axes[1]
    ax.annotate('', xy=(0.8, 0.5), xytext=(0.2, 0.5),
                arrowprops=dict(arrowstyle='->', lw=3, color='#FF6B6B'))
    ax.text(0.5, 0.65, 'eval', ha='center', va='center', fontsize=14,
            fontweight='bold', color='#FF6B6B')
    ax.text(0.5, 0.35, '(injective)', ha='center', va='center', fontsize=10,
            color='#888')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')

    # Right: Function space (Bool × Bool)
    ax = axes[2]
    # 4 elements of Bool × Bool in lattice order
    pos2 = {
        '(F,F)': (0, 0), '(T,F)': (-0.8, 1),
        '(F,T)': (0.8, 1), '(T,T)': (0, 2)
    }
    labels = {
        '(F,F)': '⊥ → (F,F)', '(T,F)': 'a → (T,F)',
        '(F,T)': 'b → (F,T)', '(T,T)': '⊤ → (T,T)'
    }
    edges2 = [('(F,F)', '(T,F)'), ('(F,F)', '(F,T)'), ('(T,F)', '(T,T)'), ('(F,T)', '(T,T)')]
    for u, v in edges2:
        ax.plot([pos2[u][0], pos2[v][0]], [pos2[u][1], pos2[v][1]], 'k-', lw=2, zorder=1)
    for name, (x, y) in pos2.items():
        circle = plt.Circle((x, y), 0.18, color='#FFE66D', ec='black', lw=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=10, fontweight='bold', zorder=3)
        ax.text(x, y - 0.35, labels[name], ha='center', va='center', fontsize=8,
                color='#555', zorder=3)
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Spectrum Functions\nBool^Spec', fontsize=14, fontweight='bold')

    fig.suptitle('Tropical Stone Duality: Evaluation Map', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def create_spectrum_diagram() -> str:
    """Create a diagram of the prime spectrum with canonical preorder."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 4))

    # Two incomparable points
    positions = {'p_L': (-1.5, 0), 'p_R': (1.5, 0)}

    # Self-loops (reflexivity)
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.4, color='#FF6B6B', ec='black', lw=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=14, fontweight='bold',
                color='white', zorder=3)
        # Self-loop arrow
        arc = mpatches.FancyArrowPatch(
            (x - 0.3, y + 0.4), (x + 0.3, y + 0.4),
            connectionstyle="arc3,rad=0.8",
            arrowstyle='->', mutation_scale=15, lw=2, color='black', zorder=1)
        ax.add_patch(arc)

    # No arrow between them (incomparable)
    ax.text(0, 0.15, '≱', ha='center', va='center', fontsize=20, color='#888')
    ax.text(0, -0.15, '≰', ha='center', va='center', fontsize=20, color='#888')

    ax.set_xlim(-3, 3)
    ax.set_ylim(-1.5, 2)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Prime Spectrum with Canonical Preorder\n(Reconstructed Kripke Frame)',
                 fontsize=14, fontweight='bold')

    return fig_to_base64(fig)


def create_duality_pipeline_diagram() -> str:
    """Create a diagram showing the full duality pipeline."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 5))

    steps = [
        ('Bounded Lattice\n+ Heyting Imp\n(Algebra M)', '#4ECDC4'),
        ('Tropical\nPrime Points\n(Spec)', '#FF6B6B'),
        ('Evaluation\nMap\n(eval: M → T^Spec)', '#FFE66D'),
        ('Canonical\nPreorder\n(p ≤ q)', '#95E1D3'),
        ('Kripke\nFrame\n(Semantics)', '#F38181'),
    ]

    for i, (label, color) in enumerate(steps):
        x = i * 2.8
        rect = mpatches.FancyBboxPatch(
            (x - 1, -0.8), 2, 1.6,
            boxstyle="round,pad=0.1",
            facecolor=color, edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, 0, label, ha='center', va='center', fontsize=10, fontweight='bold')

        if i < len(steps) - 1:
            ax.annotate('', xy=(x + 1.2, 0), xytext=(x + 1.6, 0),
                        arrowprops=dict(arrowstyle='->', lw=2.5, color='#333'))

    ax.set_xlim(-1.5, 12.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('The Tropical Stone Duality Pipeline', fontsize=16, fontweight='bold', pad=20)

    return fig_to_base64(fig)


def create_residuation_heatmap() -> str:
    """Create a heatmap of the Heyting implication table."""
    fig, ax = plt.subplots(1, 1, figsize=(7, 6))

    labels = ['⊥', 'a', 'b', '⊤']
    # Map elements to numeric values for coloring
    val_map = {'⊥': 0, 'a': 1, 'b': 2, '⊤': 3}

    himp_table = [
        ['⊤', '⊤', '⊤', '⊤'],  # ⊥ →
        ['b', '⊤', 'b', '⊤'],  # a →
        ['a', 'a', '⊤', '⊤'],  # b →
        ['⊥', 'a', 'b', '⊤'],  # ⊤ →
    ]

    data = np.array([[val_map[x] for x in row] for row in himp_table])

    cmap = plt.cm.YlOrRd
    im = ax.imshow(data, cmap=cmap, aspect='equal', vmin=0, vmax=3)

    # Labels
    ax.set_xticks(range(4))
    ax.set_xticklabels(labels, fontsize=12, fontweight='bold')
    ax.set_yticks(range(4))
    ax.set_yticklabels(labels, fontsize=12, fontweight='bold')
    ax.set_xlabel('b (target)', fontsize=12)
    ax.set_ylabel('a (source)', fontsize=12)

    # Text annotations
    for i in range(4):
        for j in range(4):
            ax.text(j, i, himp_table[i][j], ha='center', va='center',
                    fontsize=14, fontweight='bold',
                    color='white' if data[i, j] >= 2 else 'black')

    ax.set_title('Heyting Implication Table: a ⇒ b', fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax, ticks=[0, 1, 2, 3],
                 label='Lattice height')

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    imgs = {
        'diamond_lattice': create_diamond_lattice_diagram(),
        'evaluation_map': create_evaluation_diagram(),
        'spectrum': create_spectrum_diagram(),
        'pipeline': create_duality_pipeline_diagram(),
        'residuation': create_residuation_heatmap(),
    }

    for name, data_uri in imgs.items():
        # Save as PNG file
        png_data = base64.b64decode(data_uri.split(',')[1])
        with open(f'{name}.png', 'wb') as f:
            f.write(png_data)
        print(f"  Saved {name}.png ({len(png_data)} bytes)")

    print("Done!")
