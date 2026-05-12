#!/usr/bin/env python3
"""
Applications of Berggren–Lattice Reduction Duality

Demonstrates practical applications:
1. Toy lattice-based key generation using Berggren paths as trapdoors
2. Triple classification via form invariants
3. Computational verification of form-theoretic invariants
"""

import math
import random
import hashlib
from typing import Tuple, List, Dict, Optional
from dataclasses import dataclass


# ─── Core Functions (self-contained) ──────────────────────────────────────────

def is_primitive_triple(a: int, b: int, c: int) -> bool:
    return a > 0 and b > 0 and c > 0 and a**2 + b**2 == c**2 and math.gcd(a, b) == 1 and (a + b) % 2 == 1

def triple_to_form(a: int, b: int, c: int) -> Tuple[int, int, int]:
    return (c, b - a, c)

def form_discriminant(A: int, B: int, C: int) -> int:
    return B**2 - 4*A*C

def berggren_L(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def berggren_M(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def berggren_R(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'L': berggren_L, 'M': berggren_M, 'R': berggren_R}


# ─── Application 1: Toy Trapdoor Key Generation ──────────────────────────────

@dataclass
class ToyPublicKey:
    """Public key: a binary quadratic form (A, B, C)."""
    A: int
    B: int
    C: int
    discriminant: int

@dataclass
class ToySecretKey:
    """Secret key: the Berggren path encoding the primitive triple."""
    triple: Tuple[int, int, int]
    path: str  # Sequence of L/M/R from root

def generate_random_triple(depth: int) -> Tuple[Tuple[int, int, int], str]:
    """Generate a random primitive triple by walking the Berggren tree.

    Args:
        depth: Number of random steps from root (3, 4, 5).

    Returns:
        (triple, path_string) where path_string encodes the generators used.
    """
    current = (3, 4, 5)
    path = ""
    for _ in range(depth):
        gen_name = random.choice(['L', 'M', 'R'])
        gen = GENERATORS[gen_name]
        current = gen(*current)
        path += gen_name
    return current, path

def toy_keygen(depth: int = 8) -> Tuple[ToyPublicKey, ToySecretKey]:
    """Generate a toy public/secret key pair.

    Public key: the binary quadratic form attached to a random triple.
    Secret key: the Berggren tree path (which enables reconstruction).

    The security assumption (in this toy model) is that recovering the
    Berggren path from the form is computationally hard.

    Args:
        depth: Tree depth for the random walk (larger = harder to invert).
    """
    triple, path = generate_random_triple(depth)
    a, b, c = triple
    A, B, C = triple_to_form(a, b, c)
    disc = form_discriminant(A, B, C)

    pk = ToyPublicKey(A=A, B=B, C=C, discriminant=disc)
    sk = ToySecretKey(triple=triple, path=path)
    return pk, sk

def toy_verify_keypair(pk: ToyPublicKey, sk: ToySecretKey) -> bool:
    """Verify that a secret key matches its public key."""
    a, b, c = sk.triple
    A, B, C = triple_to_form(a, b, c)
    return (pk.A == A and pk.B == B and pk.C == C)

def demo_toy_crypto():
    """Demonstrate the toy trapdoor key generation."""
    print("=" * 70)
    print("APPLICATION 1: Toy Lattice-Based Key Generation")
    print("=" * 70)
    print()
    print("  Paradigm: Public key = binary quadratic form")
    print("            Secret key = Berggren tree path")
    print()

    for depth in [4, 8, 12]:
        pk, sk = toy_keygen(depth)
        valid = toy_verify_keypair(pk, sk)
        a, b, c = sk.triple
        print(f"  Depth {depth:>2}:")
        print(f"    Triple: ({a}, {b}, {c}), hypotenuse = {c}")
        print(f"    Public key: Q(x,y) = {pk.A}x² + {pk.B:+d}xy + {pk.C}y²")
        print(f"    Discriminant: {pk.discriminant}")
        print(f"    Secret path: {sk.path}")
        print(f"    Path length: {len(sk.path)}")
        print(f"    Key pair valid: {'✓' if valid else '✗'}")
        print(f"    Berggren-reduced: {'Yes' if a <= b else 'No'}")
        print()


# ─── Application 2: Triple Classification by Form Invariants ────────────────

def classify_triple(a: int, b: int, c: int) -> Dict:
    """Classify a primitive triple using its form-theoretic invariants."""
    A, B, C = triple_to_form(a, b, c)
    disc = form_discriminant(A, B, C)
    pos_disc = 4*A*C - B**2

    return {
        'triple': (a, b, c),
        'form': (A, B, C),
        'discriminant': disc,
        'berggren_reduced': a <= b,
        'gauss_reduced': abs(B) <= A and A <= C and (A != C or B >= 0),
        'ambiguous': A == C,  # True for all forms in Berggren image
        'leg_ratio': b / a,
        'reduction_gap': c - abs(b - a),  # How far from the boundary
        'minkowski_ratio': 3 * A**2 / (4 * pos_disc) if pos_disc > 0 else float('inf'),
    }

def demo_classification():
    """Demonstrate triple classification."""
    print("=" * 70)
    print("APPLICATION 2: Triple Classification by Form Invariants")
    print("=" * 70)
    print()

    # Generate a collection of triples
    triples = []
    queue = [(3, 4, 5)]
    while queue:
        a, b, c = queue.pop(0)
        if c > 100:
            continue
        triples.append((a, b, c))
        for gen in [berggren_L, berggren_M, berggren_R]:
            child = gen(a, b, c)
            if child[2] <= 100:
                queue.append(child)

    triples.sort(key=lambda t: t[2])

    print(f"{'Triple':>15} │ {'B-Red':>5} │ {'Disc':>8} │ {'b/a':>6} │ {'Gap':>4} │ {'Mink':>6}")
    print("─" * 55)

    for a, b, c in triples[:20]:
        info = classify_triple(a, b, c)
        print(f"  ({a:>3},{b:>3},{c:>3}) │ "
              f"{'Yes' if info['berggren_reduced'] else 'No':>5} │ "
              f"{info['discriminant']:>8} │ "
              f"{info['leg_ratio']:>6.2f} │ "
              f"{info['reduction_gap']:>4} │ "
              f"{info['minkowski_ratio']:>6.3f}")

    # Statistics
    reduced = sum(1 for a, b, c in triples if a <= b)
    print(f"\n  Total: {len(triples)}, Reduced: {reduced} ({100*reduced/len(triples):.1f}%)")
    print(f"  All forms ambiguous (A=C): {all(classify_triple(*t)['ambiguous'] for t in triples)}")
    print()


# ─── Application 3: Form-Theoretic Fingerprinting ───────────────────────────

def form_fingerprint(a: int, b: int, c: int) -> str:
    """Create a compact fingerprint of a triple using form invariants.

    The fingerprint encodes:
    - Discriminant (determines the form class)
    - Reduction status
    - A hash of the form coefficients
    """
    A, B, C = triple_to_form(a, b, c)
    disc = form_discriminant(A, B, C)
    data = f"{A}:{B}:{C}:{disc}"
    h = hashlib.sha256(data.encode()).hexdigest()[:16]
    status = "R" if a <= b else "U"  # Reduced or Unreduced
    return f"BQF-{status}-{abs(disc)}-{h}"

def demo_fingerprinting():
    """Demonstrate form-theoretic fingerprinting."""
    print("=" * 70)
    print("APPLICATION 3: Form-Theoretic Fingerprinting")
    print("=" * 70)
    print()
    print("  Each triple gets a unique fingerprint from its form invariants.")
    print()

    triples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25), (21,20,29),
               (9,40,41), (11,60,61), (15,8,17), (45,28,53), (55,48,73)]

    for a, b, c in triples:
        fp = form_fingerprint(a, b, c)
        print(f"  ({a:>3},{b:>3},{c:>3}) → {fp}")

    # Verify uniqueness
    fps = [form_fingerprint(*t) for t in triples]
    print(f"\n  Unique fingerprints: {len(set(fps))}/{len(fps)}")
    print()


# ─── Application 4: Descent-Length Analysis ──────────────────────────────────

def berggren_parent(a: int, b: int, c: int) -> Optional[Tuple[str, Tuple[int,int,int]]]:
    """Find the parent of (a,b,c) in the Berggren tree."""
    if (a, b, c) == (3, 4, 5):
        return None
    c_p = 3*c - 2*a - 2*b
    candidates = [
        ('L', (a + 2*b - 2*c, -2*a - b + 2*c, c_p)),
        ('M', (a + 2*b - 2*c, 2*a + b - 2*c, c_p)),
        ('R', (-a - 2*b + 2*c, 2*a + b - 2*c, c_p)),
    ]
    for name, (pa, pb, pc) in candidates:
        if pa > 0 and pb > 0 and pc > 0 and pa**2 + pb**2 == pc**2:
            return (name, (pa, pb, pc))
    return None

def descent_length(a: int, b: int, c: int) -> int:
    """Compute the Berggren descent length from (a,b,c) to (3,4,5)."""
    length = 0
    current = (a, b, c)
    while current != (3, 4, 5):
        result = berggren_parent(*current)
        if result is None:
            return -1  # Should not happen
        current = result[1]
        length += 1
    return length

def demo_descent_analysis():
    """Analyze descent lengths and their relationship to form data."""
    print("=" * 70)
    print("APPLICATION 4: Descent-Length Analysis")
    print("=" * 70)
    print()

    # Generate triples
    triples = []
    queue = [(3, 4, 5)]
    while queue:
        a, b, c = queue.pop(0)
        if c > 500:
            continue
        triples.append((a, b, c))
        for gen in [berggren_L, berggren_M, berggren_R]:
            child = gen(a, b, c)
            if child[2] <= 500:
                queue.append(child)

    triples.sort(key=lambda t: t[2])

    print(f"{'Triple':>18} │ {'c':>6} │ {'Depth':>5} │ {'log₃(c)':>8} │ {'Ratio':>6}")
    print("─" * 55)

    for a, b, c in triples[:25]:
        depth = descent_length(a, b, c)
        log3_c = math.log(c, 3) if c > 1 else 0
        ratio = depth / log3_c if log3_c > 0 else 0
        print(f"  ({a:>4},{b:>4},{c:>4}) │ {c:>6} │ {depth:>5} │ {log3_c:>8.2f} │ {ratio:>6.2f}")

    # Statistics
    depths = [descent_length(*t) for t in triples]
    max_depth = max(depths)
    avg_depth = sum(depths) / len(depths)
    hyps = [t[2] for t in triples]

    print(f"\n  Total triples (c ≤ 500): {len(triples)}")
    print(f"  Max depth: {max_depth}")
    print(f"  Average depth: {avg_depth:.2f}")
    print(f"  Max hypotenuse: {max(hyps)}")
    print(f"  Depth/log₃(c) ratio range: [{min(d/math.log(c,3) for (a,b,c),d in zip(triples[1:], depths[1:])):.2f}, "
          f"{max(d/math.log(c,3) for (a,b,c),d in zip(triples[1:], depths[1:])):.2f}]")
    print()


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    random.seed(42)  # Reproducibility
    demo_toy_crypto()
    demo_classification()
    demo_fingerprinting()
    demo_descent_analysis()


#!/usr/bin/env python3
"""
Berggren–Lattice Reduction Duality: Interactive Demonstrations

Demonstrates the equivalence between Berggren-reducedness of primitive
Pythagorean triples and Gauss-reducedness of attached binary quadratic forms.
"""

import math
from typing import Tuple, List, Optional

# ─── Core Types ───────────────────────────────────────────────────────────────

Triple = Tuple[int, int, int]
Form = Tuple[int, int, int]  # (A, B, C)


def is_pythagorean(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a Pythagorean triple."""
    return a > 0 and b > 0 and c > 0 and a**2 + b**2 == c**2


def is_primitive(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a primitive Pythagorean triple."""
    return is_pythagorean(a, b, c) and math.gcd(a, b) == 1 and (a + b) % 2 == 1


# ─── Berggren Generators ─────────────────────────────────────────────────────

def berggren_L(a: int, b: int, c: int) -> Triple:
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_M(a: int, b: int, c: int) -> Triple:
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_R(a: int, b: int, c: int) -> Triple:
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


BERGGREN_GENERATORS = {'L': berggren_L, 'M': berggren_M, 'R': berggren_R}


# ─── Form Attachment ─────────────────────────────────────────────────────────

def triple_to_form(a: int, b: int, c: int) -> Form:
    """Canonical form attachment: (a,b,c) ↦ (c, b-a, c)."""
    return (c, b - a, c)


def form_discriminant(A: int, B: int, C: int) -> int:
    """Discriminant D = B² - 4AC."""
    return B**2 - 4*A*C


def form_pos_disc(A: int, B: int, C: int) -> int:
    """Positive-definiteness discriminant 4AC - B²."""
    return 4*A*C - B**2


# ─── Reducedness Conditions ──────────────────────────────────────────────────

def berggren_reduced(a: int, b: int, c: int) -> bool:
    """A triple is Berggren-reduced iff a ≤ b."""
    return a <= b


def gauss_reduced(A: int, B: int, C: int) -> bool:
    """A form is Gauss-reduced iff |B| ≤ A, A ≤ C, and A=C → B ≥ 0."""
    return abs(B) <= A and A <= C and (A != C or B >= 0)


# ─── Berggren Tree Generation ────────────────────────────────────────────────

def generate_berggren_tree(max_c: int) -> List[Triple]:
    """Generate all primitive triples with hypotenuse ≤ max_c."""
    triples = []
    queue = [(3, 4, 5)]
    while queue:
        a, b, c = queue.pop(0)
        if c > max_c:
            continue
        triples.append((a, b, c))
        for gen in [berggren_L, berggren_M, berggren_R]:
            child = gen(a, b, c)
            if child[2] <= max_c:
                queue.append(child)
    return sorted(triples, key=lambda t: (t[2], t[0]))


def berggren_descent(a: int, b: int, c: int) -> List[Tuple[str, Triple]]:
    """Find the descent path from (a,b,c) to (3,4,5) in the Berggren tree.

    Returns a list of (generator_name, parent_triple) pairs.
    """
    path = []
    current = (a, b, c)
    while current != (3, 4, 5):
        found = False
        for name, gen in BERGGREN_GENERATORS.items():
            # Try each inverse: check if current is a child via this generator
            # by testing all triples with smaller hypotenuse
            # Instead, use the known inverse formulas
            pass
        # Use the standard inverse determination
        a_c, b_c, c_c = current
        # The parent hypotenuse is always 3c - 2a - 2b
        c_parent = 3*c_c - 2*a_c - 2*b_c
        if c_parent <= 0 or c_parent >= c_c:
            break  # Should not happen for valid triples
        # Try each generator to find which one maps parent to current
        for name, gen in BERGGREN_GENERATORS.items():
            # We need to find the parent; try all inverse Berggren operations
            pass
        # Direct inverse computation
        # Inverse L: (a,b,c) → (a+2b-2c, -2a-b+2c, -2a-2b+3c) — wait, wrong
        # Let's just brute-force check
        for name, gen in BERGGREN_GENERATORS.items():
            # Check all triples with hypotenuse = c_parent
            # Actually, let's use the known inverse matrices
            pass

        # Simplified: use all three inverse transforms and check which gives valid triple
        inv1 = (a_c + 2*b_c - 2*c_c, -2*a_c - b_c + 2*c_c, c_parent)  # Inv of L
        inv2 = (a_c + 2*b_c - 2*c_c, 2*a_c + b_c - 2*c_c, c_parent)   # Inv of M (different sign pattern)
        inv3 = (-a_c - 2*b_c + 2*c_c, 2*a_c + b_c - 2*c_c, c_parent)  # Inv of R

        # Actually the correct inverse transforms:
        # If child = L(parent), then parent can be recovered
        # Let's verify by checking which inverse gives a valid Pythagorean triple
        for inv_name, inv_triple in [('L⁻¹', inv1), ('M⁻¹', inv2), ('R⁻¹', inv3)]:
            pa, pb, pc = inv_triple
            if pa > 0 and pb > 0 and pc > 0 and pa**2 + pb**2 == pc**2:
                path.append((inv_name, inv_triple))
                current = inv_triple
                found = True
                break

        if not found:
            break

    return path


# ─── Demonstrations ──────────────────────────────────────────────────────────

def demo_duality():
    """Demonstrate the Berggren-Gauss reduction duality."""
    print("=" * 70)
    print("DEMO 1: Berggren–Gauss Reduction Duality")
    print("=" * 70)
    print()
    print("For each primitive triple (a, b, c), we compute:")
    print("  • Berggren-reduced: a ≤ b")
    print("  • Attached form: Q(x,y) = cx² + (b-a)xy + cy²")
    print("  • Gauss-reduced: |B| ≤ A, A ≤ C, A=C → B ≥ 0")
    print()
    print(f"{'Triple':>15} │ {'Form (A,B,C)':>15} │ {'Berggren':>10} │ {'Gauss':>10} │ {'Match':>5}")
    print("─" * 70)

    triples = generate_berggren_tree(200)
    all_match = True
    for a, b, c in triples[:20]:
        form = triple_to_form(a, b, c)
        br = berggren_reduced(a, b, c)
        gr = gauss_reduced(*form)
        match = "✓" if br == gr else "✗"
        if br != gr:
            all_match = False
        print(f"  ({a:>3},{b:>3},{c:>3}) │ ({form[0]:>3},{form[1]:>3},{form[2]:>3}) │ "
              f"{'Yes':>10} │ {'Yes':>10} │ {match:>5}" if br else
              f"  ({a:>3},{b:>3},{c:>3}) │ ({form[0]:>3},{form[1]:>3},{form[2]:>3}) │ "
              f"{'No':>10} │ {'No':>10} │ {match:>5}")

    total = len(triples)
    reduced_count = sum(1 for a, b, c in triples if berggren_reduced(a, b, c))
    print(f"\n  Total triples with c ≤ 200: {total}")
    print(f"  Berggren-reduced: {reduced_count} ({100*reduced_count/total:.1f}%)")
    print(f"  Duality holds for ALL triples: {'YES ✓' if all_match else 'NO ✗'}")
    print()


def demo_descent():
    """Demonstrate Berggren descent paths."""
    print("=" * 70)
    print("DEMO 2: Berggren Descent (Height Strictly Decreases)")
    print("=" * 70)
    print()

    test_triples = [(3, 4, 5), (5, 12, 13), (21, 20, 29), (15, 8, 17),
                    (7, 24, 25), (55, 48, 73), (45, 28, 53)]

    for a, b, c in test_triples:
        if not is_primitive(a, b, c):
            continue
        print(f"  Triple ({a}, {b}, {c}), height = {c}")
        path = berggren_descent(a, b, c)
        for step_name, parent in path:
            pa, pb, pc = parent
            print(f"    → {step_name} → ({pa}, {pb}, {pc}), height = {pc}")
        if not path:
            print(f"    (already at root)")
        print()


def demo_discriminants():
    """Demonstrate discriminant computation."""
    print("=" * 70)
    print("DEMO 3: Form Discriminants and Positive Definiteness")
    print("=" * 70)
    print()
    print(f"{'Triple':>15} │ {'Disc = -(3c²+2ab)':>20} │ {'4AC-B² = 3c²+2ab':>20}")
    print("─" * 60)

    triples = generate_berggren_tree(100)
    for a, b, c in triples[:15]:
        form = triple_to_form(a, b, c)
        disc = form_discriminant(*form)
        pos_disc = form_pos_disc(*form)
        expected_disc = -(3*c**2 + 2*a*b)
        expected_pos = 3*c**2 + 2*a*b
        check_d = "✓" if disc == expected_disc else "✗"
        check_p = "✓" if pos_disc == expected_pos else "✗"
        print(f"  ({a:>3},{b:>3},{c:>3}) │ {disc:>16} {check_d} │ {pos_disc:>16} {check_p}")
    print()


def demo_reconstruction():
    """Demonstrate that the form attachment is injective."""
    print("=" * 70)
    print("DEMO 4: Certified Reconstruction (Injectivity)")
    print("=" * 70)
    print()
    print("  The map (a,b,c) ↦ (c, b-a, c) is injective.")
    print("  From (A, B, C) = (c, b-a, c), we recover:")
    print("    c = A")
    print("    b - a = B")
    print("    a² + b² = c²")
    print("    ⟹ a = (c² - B² - ... ) via quadratic formula")
    print()

    triples = generate_berggren_tree(200)
    forms_seen = {}
    collisions = 0
    for a, b, c in triples:
        form = triple_to_form(a, b, c)
        if form in forms_seen:
            collisions += 1
            print(f"  COLLISION: ({a},{b},{c}) and {forms_seen[form]} → same form {form}")
        else:
            forms_seen[form] = (a, b, c)

    print(f"  Tested {len(triples)} triples, found {collisions} collisions.")
    if collisions == 0:
        print("  Injectivity verified for all triples with c ≤ 200 ✓")
    print()


def demo_short_basis():
    """Demonstrate short-basis certificates for reduced triples."""
    print("=" * 70)
    print("DEMO 5: Short-Basis Certificates (Minkowski Bound)")
    print("=" * 70)
    print()
    print("  For Berggren-reduced triples, 3A² ≤ 4(4AC - B²).")
    print()
    print(f"{'Triple':>15} │ {'Reduced':>8} │ {'3A²':>10} │ {'4(4AC-B²)':>12} │ {'Bound':>6}")
    print("─" * 60)

    triples = generate_berggren_tree(200)
    for a, b, c in triples[:15]:
        form = triple_to_form(a, b, c)
        A, B, C = form
        red = berggren_reduced(a, b, c)
        lhs = 3 * A**2
        rhs = 4 * (4*A*C - B**2)
        holds = "✓" if lhs <= rhs else "✗"
        print(f"  ({a:>3},{b:>3},{c:>3}) │ {'Yes' if red else 'No':>8} │ "
              f"{lhs:>10} │ {rhs:>12} │ {holds:>6}")

    # Verify for all
    all_hold = all(
        3 * triple_to_form(a,b,c)[0]**2 <= 4 * form_pos_disc(*triple_to_form(a,b,c))
        for a, b, c in triples
    )
    print(f"\n  Minkowski bound holds for ALL {len(triples)} triples: {'YES ✓' if all_hold else 'NO ✗'}")
    print()


if __name__ == "__main__":
    demo_duality()
    demo_descent()
    demo_discriminants()
    demo_reconstruction()
    demo_short_basis()


#!/usr/bin/env python3
"""
Visualizations for Berggren–Lattice Reduction Duality

Generates publication-quality figures showing:
1. The Berggren tree with reduction coloring
2. Form-space view of the duality
3. Descent height profile
4. Distribution of reduced vs unreduced triples
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict


# ─── Core Functions ───────────────────────────────────────────────────────────

def berggren_L(a, b, c): return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def berggren_M(a, b, c): return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def berggren_R(a, b, c): return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_tree(max_c):
    triples = []
    edges = []
    queue = [(3, 4, 5, None)]
    while queue:
        a, b, c, parent = queue.pop(0)
        if c > max_c:
            continue
        triples.append((a, b, c))
        if parent is not None:
            edges.append((parent, (a, b, c)))
        for gen_name, gen in [('L', berggren_L), ('M', berggren_M), ('R', berggren_R)]:
            child = gen(a, b, c)
            if child[2] <= max_c:
                queue.append((*child, (a, b, c)))
    return triples, edges

def berggren_parent(a, b, c):
    if (a, b, c) == (3, 4, 5):
        return None
    c_p = 3*c - 2*a - 2*b
    for pa, pb, pc in [
        (a + 2*b - 2*c, -2*a - b + 2*c, c_p),
        (a + 2*b - 2*c, 2*a + b - 2*c, c_p),
        (-a - 2*b + 2*c, 2*a + b - 2*c, c_p),
    ]:
        if pa > 0 and pb > 0 and pc > 0 and pa**2 + pb**2 == pc**2:
            return (pa, pb, pc)
    return None


# ─── Visualization 1: Berggren Tree with Reduction Coloring ──────────────────

def viz_berggren_tree():
    """Berggren tree colored by reduction status."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    triples, edges = generate_tree(200)

    # Position nodes: x = a/c (angle parameter), y = c (height)
    pos = {}
    for a, b, c in triples:
        pos[(a, b, c)] = (a / c, c)

    # Draw edges
    for parent, child in edges:
        if parent in pos and child in pos:
            x0, y0 = pos[parent]
            x1, y1 = pos[child]
            ax.plot([x0, x1], [y0, y1], 'k-', alpha=0.15, linewidth=0.5)

    # Draw nodes
    for a, b, c in triples:
        x, y = pos[(a, b, c)]
        reduced = a <= b
        color = '#2ecc71' if reduced else '#e74c3c'
        size = max(8, 40 - c // 5)
        ax.scatter(x, y, c=color, s=size, zorder=5, edgecolors='white', linewidths=0.5)

    # Annotate root
    ax.annotate('(3,4,5)', xy=(3/5, 5), fontsize=9, ha='center', va='bottom',
                fontweight='bold')

    ax.set_xlabel('a/c (angle parameter)', fontsize=12)
    ax.set_ylabel('Hypotenuse c (Berggren height)', fontsize=12)
    ax.set_title('Berggren Tree: Green = Reduced (a ≤ b), Red = Unreduced (a > b)', fontsize=14)

    reduced_patch = mpatches.Patch(color='#2ecc71', label='Berggren-reduced (a ≤ b)')
    unreduced_patch = mpatches.Patch(color='#e74c3c', label='Not reduced (a > b)')
    ax.legend(handles=[reduced_patch, unreduced_patch], loc='upper right', fontsize=10)

    ax.set_xlim(-0.05, 1.05)
    ax.invert_yaxis()
    plt.tight_layout()
    plt.savefig('viz_berggren_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: viz_berggren_tree.png")


# ─── Visualization 2: Form Coefficients and Gauss Reduction ──────────────────

def viz_form_space():
    """Plot form coefficients with Gauss-reduction region."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    triples, _ = generate_tree(300)

    # Left: B vs A for attached forms
    for a, b, c in triples:
        A, B, C = c, b - a, c
        reduced = a <= b
        color = '#2ecc71' if reduced else '#e74c3c'
        ax1.scatter(A, B, c=color, s=15, alpha=0.7, edgecolors='none')

    # Draw Gauss-reduction boundaries: |B| ≤ A
    max_A = max(t[2] for t in triples)
    ax1.plot([0, max_A], [0, max_A], 'b--', alpha=0.5, label='B = A')
    ax1.plot([0, max_A], [0, -max_A], 'b--', alpha=0.5, label='B = -A')
    ax1.axhline(y=0, color='gray', linewidth=0.5)

    ax1.set_xlabel('A = c', fontsize=12)
    ax1.set_ylabel('B = b − a', fontsize=12)
    ax1.set_title('Form Coefficients (A, B)', fontsize=13)
    ax1.legend(fontsize=9)

    # Right: Discriminant vs hypotenuse
    discs = []
    hyps = []
    colors = []
    for a, b, c in triples:
        disc = -(3*c**2 + 2*a*b)
        discs.append(abs(disc))
        hyps.append(c)
        colors.append('#2ecc71' if a <= b else '#e74c3c')

    ax2.scatter(hyps, discs, c=colors, s=15, alpha=0.7, edgecolors='none')
    ax2.set_xlabel('Hypotenuse c', fontsize=12)
    ax2.set_ylabel('|Discriminant| = 3c² + 2ab', fontsize=12)
    ax2.set_title('Form Discriminant vs Hypotenuse', fontsize=13)

    # Fit envelope: |disc| ≈ 3c² (lower bound) and ≈ 5c² (upper approx)
    cs = np.linspace(5, max(hyps), 100)
    ax2.plot(cs, 3*cs**2, 'b--', alpha=0.5, label='3c² (lower envelope)')
    ax2.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('viz_form_space.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: viz_form_space.png")


# ─── Visualization 3: Descent Height Profile ─────────────────────────────────

def viz_descent_profile():
    """Show descent paths for several triples, with heights."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))

    # Choose diverse triples at various depths
    test_triples = []
    queue = [(3, 4, 5)]
    seen = set()
    while queue and len(test_triples) < 8:
        a, b, c = queue.pop(0)
        if c > 500:
            continue
        if (a, b, c) not in seen:
            seen.add((a, b, c))
            if c > 50:  # Only interesting ones
                test_triples.append((a, b, c))
            for gen in [berggren_L, berggren_M, berggren_R]:
                child = gen(a, b, c)
                if child[2] <= 500:
                    queue.append(child)

    cmap = plt.cm.viridis
    for i, start in enumerate(test_triples[:6]):
        path = [start]
        current = start
        while current != (3, 4, 5):
            parent = berggren_parent(*current)
            if parent is None:
                break
            path.append(parent)
            current = parent

        heights = [t[2] for t in path]
        steps = list(range(len(heights)))
        color = cmap(i / 6)
        label = f"({start[0]},{start[1]},{start[2]})"
        ax.plot(steps, heights, 'o-', color=color, markersize=5, linewidth=1.5,
                label=label, alpha=0.8)

    ax.set_xlabel('Descent Step', fontsize=12)
    ax.set_ylabel('Hypotenuse c (Berggren height)', fontsize=12)
    ax.set_title('Berggren Descent: Height Strictly Decreases at Each Step', fontsize=14)
    ax.legend(fontsize=8, ncol=2)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_descent_profile.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: viz_descent_profile.png")


# ─── Visualization 4: Reduction Statistics ────────────────────────────────────

def viz_reduction_stats():
    """Histogram and cumulative statistics of reduction."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    triples, _ = generate_tree(2000)
    triples.sort(key=lambda t: t[2])

    # Left: Running proportion of reduced triples
    n = len(triples)
    running_reduced = []
    count = 0
    for i, (a, b, c) in enumerate(triples):
        if a <= b:
            count += 1
        running_reduced.append(count / (i + 1))

    ax1.plot(range(1, n + 1), running_reduced, color='#3498db', linewidth=1)
    ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='50%')
    ax1.set_xlabel('Number of triples (ordered by hypotenuse)', fontsize=11)
    ax1.set_ylabel('Proportion Berggren-reduced', fontsize=11)
    ax1.set_title('Running Proportion of Reduced Triples', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 1)
    ax1.grid(True, alpha=0.3)

    # Right: Leg ratio distribution
    ratios_reduced = [b/a for a, b, c in triples if a <= b]
    ratios_unreduced = [a/b for a, b, c in triples if a > b]

    ax2.hist(ratios_reduced, bins=30, alpha=0.7, color='#2ecc71',
             label=f'Reduced (b/a), n={len(ratios_reduced)}', density=True)
    ax2.hist(ratios_unreduced, bins=30, alpha=0.7, color='#e74c3c',
             label=f'Unreduced (a/b), n={len(ratios_unreduced)}', density=True)

    ax2.set_xlabel('Leg ratio', fontsize=11)
    ax2.set_ylabel('Density', fontsize=11)
    ax2.set_title('Distribution of Leg Ratios', fontsize=13)
    ax2.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('viz_reduction_stats.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: viz_reduction_stats.png")


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")
    viz_berggren_tree()
    viz_form_space()
    viz_descent_profile()
    viz_reduction_stats()
    print("All visualizations generated successfully.")
