"""
Boolean Rings and the Algebra of Idempotents — Interactive Demonstration

This script demonstrates the key theorems about Boolean rings with concrete
numerical examples, visualizations, and applications.

A Boolean ring is a ring where every element satisfies x² = x (idempotency).
The central surprise: this single axiom forces commutativity and characteristic 2.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import product


# ============================================================================
# Part 1: Boolean Ring Structures
# ============================================================================

class BooleanRing:
    """
    A Boolean ring over a finite set with addition (XOR) and multiplication (AND).
    Elements are subsets of a universe, represented as bitmasks.
    """
    def __init__(self, n_bits):
        self.n_bits = n_bits
        self.size = 2 ** n_bits
        self.elements = list(range(self.size))

    def add(self, a, b):
        """Addition = symmetric difference (XOR)"""
        return a ^ b

    def mul(self, a, b):
        """Multiplication = intersection (AND)"""
        return a & b

    def zero(self):
        return 0

    def one(self):
        return self.size - 1  # all bits set = universe

    def neg(self, a):
        """In a Boolean ring, -a = a (characteristic 2)"""
        return a

    def complement(self, a):
        """1 - a = bitwise complement"""
        return self.one() ^ a

    def to_set(self, a):
        """Convert bitmask to set representation"""
        return {i for i in range(self.n_bits) if a & (1 << i)}

    def from_set(self, s):
        """Convert set to bitmask"""
        return sum(1 << i for i in s)

    def __repr__(self):
        return f"BooleanRing(2^{self.n_bits} = {self.size} elements)"


def verify_boolean_axiom(ring):
    """Verify that x² = x for all elements."""
    violations = []
    for x in ring.elements:
        if ring.mul(x, x) != x:
            violations.append(x)
    return len(violations) == 0, violations


def verify_commutativity(ring):
    """Verify that xy = yx for all elements."""
    violations = []
    for x in ring.elements:
        for y in ring.elements:
            if ring.mul(x, y) != ring.mul(y, x):
                violations.append((x, y))
    return len(violations) == 0, violations


def verify_characteristic_2(ring):
    """Verify that x + x = 0 for all elements."""
    violations = []
    for x in ring.elements:
        if ring.add(x, x) != ring.zero():
            violations.append(x)
    return len(violations) == 0, violations


def verify_idempotent_complement(ring):
    """Verify that if e is idempotent, so is 1 - e."""
    results = []
    for e in ring.elements:
        e_sq = ring.mul(e, e)
        comp = ring.complement(e)
        comp_sq = ring.mul(comp, comp)
        results.append({
            'e': e, 'e_idem': e_sq == e,
            'comp': comp, 'comp_idem': comp_sq == comp
        })
    return results


# ============================================================================
# Part 2: Demonstrations
# ============================================================================

def demo_basic_properties():
    """Demonstrate the fundamental Boolean ring properties."""
    print("=" * 70)
    print("BOOLEAN RINGS: FUNDAMENTAL PROPERTIES")
    print("=" * 70)

    for n in [1, 2, 3]:
        ring = BooleanRing(n)
        print(f"\n{'─' * 50}")
        print(f"  {ring}")
        print(f"{'─' * 50}")

        ok, _ = verify_boolean_axiom(ring)
        print(f"  ✓ Boolean axiom (x² = x):     {'VERIFIED' if ok else 'FAILED'}")

        ok, _ = verify_commutativity(ring)
        print(f"  ✓ Commutativity (xy = yx):     {'VERIFIED' if ok else 'FAILED'}")

        ok, _ = verify_characteristic_2(ring)
        print(f"  ✓ Characteristic 2 (x+x = 0): {'VERIFIED' if ok else 'FAILED'}")

        results = verify_idempotent_complement(ring)
        all_ok = all(r['e_idem'] and r['comp_idem'] for r in results)
        print(f"  ✓ Complement idempotency:      {'VERIFIED' if all_ok else 'FAILED'}")

    print()


def demo_proof_walkthrough():
    """Walk through the proof that Boolean rings are commutative."""
    print("=" * 70)
    print("PROOF WALKTHROUGH: WHY BOOLEAN RINGS ARE COMMUTATIVE")
    print("=" * 70)

    ring = BooleanRing(3)

    print("\nUniverse: {0, 1, 2}")
    print("Elements are subsets, represented as bitmasks.\n")

    print("Step 1: Every element has additive order 2 (x + x = 0)")
    print("─" * 50)
    for x in ring.elements[:4]:
        s = ring.to_set(x)
        result = ring.add(x, x)
        print(f"  {s} ⊕ {s} = {ring.to_set(result)}  (XOR with self = ∅)")

    print(f"\n  Key insight: x + x = (x+x)² = x+x+x+x = 2(x+x)")
    print(f"  So x + x = 0 for all x. Every element is its own negative!\n")

    print("Step 2: Expand (x + y)² = x + y")
    print("─" * 50)
    x, y = 0b011, 0b101
    sx, sy = ring.to_set(x), ring.to_set(y)
    xy = ring.mul(x, y)
    yx = ring.mul(y, x)
    x_plus_y = ring.add(x, y)

    print(f"  x = {sx}, y = {sy}")
    print(f"  x + y = {ring.to_set(x_plus_y)} = {sx} Δ {sy}")
    print(f"  (x+y)² = x² + xy + yx + y²   (expanding)")
    print(f"         = x + xy + yx + y       (using x²=x, y²=y)")
    print(f"  But (x+y)² = x+y               (Boolean axiom)")
    print(f"  So: x + xy + yx + y = x + y")
    print(f"  Therefore: xy + yx = 0")
    print(f"  Since -a = a: xy = yx")
    print(f"\n  Verification: xy = {ring.to_set(xy)}, yx = {ring.to_set(yx)}")
    print(f"  xy = yx? {xy == yx} ✓\n")


def demo_partial_order():
    """Demonstrate the Boolean ring partial order."""
    print("=" * 70)
    print("THE BOOLEAN RING PARTIAL ORDER: a ≤ b iff a·b = a")
    print("=" * 70)

    ring = BooleanRing(3)

    print("\nIn a Boolean ring, a·b = a means 'a is contained in b'")
    print("(intersection with b recovers a ↔ a ⊆ b)\n")

    pairs = [(0b001, 0b011), (0b010, 0b111), (0b011, 0b011),
             (0b001, 0b110), (0b101, 0b111)]
    for a, b in pairs:
        sa, sb = ring.to_set(a), ring.to_set(b)
        ab = ring.mul(a, b)
        le = ab == a
        symbol = "≤" if le else "≰"
        print(f"  {sa} {symbol} {sb}  "
              f"(a·b = {ring.to_set(ab)} {'= a ✓' if le else '≠ a ✗'})")

    print("\nPartial order axioms:")
    refl_ok = all(ring.mul(a, a) == a for a in ring.elements)
    print(f"  Reflexivity  (a ≤ a):           {'VERIFIED' if refl_ok else 'FAILED'} ✓")

    antisym_ok = True
    for a in ring.elements:
        for b in ring.elements:
            if ring.mul(a, b) == a and ring.mul(b, a) == b and a != b:
                antisym_ok = False
    print(f"  Antisymmetry (a≤b, b≤a → a=b): {'VERIFIED' if antisym_ok else 'FAILED'} ✓")

    trans_ok = True
    for a in ring.elements:
        for b in ring.elements:
            for c in ring.elements:
                if (ring.mul(a, b) == a and ring.mul(b, c) == b
                        and ring.mul(a, c) != a):
                    trans_ok = False
    print(f"  Transitivity (a≤b, b≤c → a≤c): {'VERIFIED' if trans_ok else 'FAILED'} ✓")
    print()


# ============================================================================
# Part 3: Visualizations
# ============================================================================

def plot_multiplication_table():
    """Plot the multiplication and addition tables of a small Boolean ring."""
    ring = BooleanRing(2)
    n = ring.size
    labels = [str(ring.to_set(i)) if i > 0 else "∅" for i in range(n)]

    table = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            table[i, j] = ring.mul(ring.elements[i], ring.elements[j])

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax = axes[0]
    ax.imshow(table, cmap='Blues', aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, fontsize=10)
    ax.set_yticklabels(labels, fontsize=10)
    ax.set_xlabel('y', fontsize=12)
    ax.set_ylabel('x', fontsize=12)
    ax.set_title('Multiplication (x · y = x ∩ y)', fontsize=14, fontweight='bold')
    for i in range(n):
        for j in range(n):
            val = table[i, j]
            label = labels[val]
            ax.text(j, i, label, ha='center', va='center', fontsize=9,
                    color='white' if val > n // 2 else 'black')

    add_table = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            add_table[i, j] = ring.add(ring.elements[i], ring.elements[j])

    ax = axes[1]
    ax.imshow(add_table, cmap='Oranges', aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, fontsize=10)
    ax.set_yticklabels(labels, fontsize=10)
    ax.set_xlabel('y', fontsize=12)
    ax.set_ylabel('x', fontsize=12)
    ax.set_title('Addition (x ⊕ y = x Δ y)', fontsize=14, fontweight='bold')
    for i in range(n):
        for j in range(n):
            val = add_table[i, j]
            label = labels[val]
            ax.text(j, i, label, ha='center', va='center', fontsize=9,
                    color='white' if val > n // 2 else 'black')

    plt.suptitle('Boolean Ring P({0,1}): Cayley Tables',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('demos/boolean_ring_tables.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/boolean_ring_tables.png")


def plot_hasse_diagram():
    """Plot the Hasse diagram of the Boolean ring partial order."""
    ring = BooleanRing(3)

    positions = {
        0b000: (3, 0),
        0b001: (1, 1),
        0b010: (3, 1),
        0b100: (5, 1),
        0b011: (0, 2),
        0b101: (3, 2),
        0b110: (6, 2),
        0b111: (3, 3),
    }

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    for a in ring.elements:
        for b in ring.elements:
            if a != b and (a & b) == a:
                diff = b ^ a
                if diff & (diff - 1) == 0:
                    xa, ya = positions[a]
                    xb, yb = positions[b]
                    ax.plot([xa, xb], [ya, yb], 'b-', linewidth=2, alpha=0.4)

    for elem in ring.elements:
        x, y = positions[elem]
        s = ring.to_set(elem)
        label = str(s) if s else "∅"

        level = bin(elem).count('1')
        colors = ['#ff6b6b', '#ffd93d', '#6bcb77', '#4d96ff']
        color = colors[level]

        circle = plt.Circle((x, y), 0.35, color=color, ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=9,
                fontweight='bold', zorder=6)

    for level, name in enumerate(['0 (zero)', '1 (atoms)', '2 (coatoms)', '3 (one)']):
        ax.text(-1.5, level, f'Level {name}', fontsize=10, va='center',
                fontstyle='italic', color='gray')

    ax.set_xlim(-2, 7.5)
    ax.set_ylim(-0.7, 3.7)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Hasse Diagram: Boolean Ring P({0,1,2})\n'
                 'Partial Order: a <= b iff a * b = a (i.e., a subset of b)',
                 fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('demos/boolean_ring_hasse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/boolean_ring_hasse.png")


def plot_idempotent_decomposition():
    """Visualize the idempotent decomposition R = eR + (1-e)R."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    ring = BooleanRing(3)

    for idx, e_val in enumerate([0b001, 0b011, 0b101]):
        ax = axes[idx]
        e = e_val
        comp = ring.complement(e)

        eR = set()
        compR = set()

        for a in ring.elements:
            if ring.mul(a, e) == a:
                eR.add(a)
            if ring.mul(a, comp) == a:
                compR.add(a)

        e_set = ring.to_set(e)

        theta = np.linspace(0, 2 * np.pi, 100)

        cx1, cy1 = -0.5, 0
        r = 1.5
        ax.plot(cx1 + r * np.cos(theta), cy1 + r * np.sin(theta),
                'b-', linewidth=2)
        ax.fill(cx1 + r * np.cos(theta), cy1 + r * np.sin(theta),
                alpha=0.15, color='blue')

        cx2, cy2 = 0.5, 0
        ax.plot(cx2 + r * np.cos(theta), cy2 + r * np.sin(theta),
                'r-', linewidth=2)
        ax.fill(cx2 + r * np.cos(theta), cy2 + r * np.sin(theta),
                alpha=0.15, color='red')

        ax.text(cx1 - 0.3, 1.0, f'eR (e={e_set})', fontsize=10,
                fontweight='bold', color='blue', ha='center')
        ax.text(cx2 + 0.3, 1.0, '(1-e)R', fontsize=10,
                fontweight='bold', color='red', ha='center')

        eR_only = eR - compR
        compR_only = compR - eR
        both = eR & compR

        y_pos = 0.5
        for a in sorted(eR_only):
            label = str(ring.to_set(a)) if a else "∅"
            ax.text(cx1 - 0.5, y_pos, label, fontsize=8, ha='center', color='blue')
            y_pos -= 0.4

        y_pos = 0.5
        for a in sorted(compR_only):
            label = str(ring.to_set(a)) if a else "∅"
            ax.text(cx2 + 0.5, y_pos, label, fontsize=8, ha='center', color='red')
            y_pos -= 0.4

        if both:
            y_pos = -0.8
            for a in sorted(both):
                label = str(ring.to_set(a)) if a else "∅"
                ax.text(0, y_pos, label, fontsize=8, ha='center', color='purple')
                y_pos -= 0.3

        ax.set_xlim(-2.5, 2.5)
        ax.set_ylim(-2.2, 1.8)
        ax.set_aspect('equal')
        ax.axis('off')

    plt.suptitle('Idempotent Decomposition: R = eR x (1-e)R\n'
                 'Every idempotent e splits the ring into orthogonal parts',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/idempotent_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/idempotent_decomposition.png")


# ============================================================================
# Part 4: Applications
# ============================================================================

def demo_circuit_application():
    """Show how Boolean rings model digital circuits."""
    print("=" * 70)
    print("APPLICATION: DIGITAL CIRCUIT OPTIMIZATION")
    print("=" * 70)
    print()
    print("Boolean ring operations directly model logic gates:")
    print("  * Multiplication (AND) = series connection")
    print("  * Addition (XOR)       = exclusive-or gate")
    print("  * Idempotency (x^2=x)  = connecting a wire to itself changes nothing")
    print()

    print("Example: Simplify the expression f(a,b) = a*b + a*(a+b)")
    print()
    print("Using Boolean ring laws:")
    print("  f(a,b) = a*b + a*(a+b)")
    print("         = a*b + a*a + a*b     (distributivity)")
    print("         = a*b + a + a*b        (idempotency: a*a = a)")
    print("         = a                     (characteristic 2: x+x = 0)")
    print()

    print("Verification (truth table):")
    print("  a  b  | a*b  a+b  a*(a+b)  a*b+a*(a+b)  | result = a?")
    print("  ------+------------------------------------+------------")
    for a in [0, 1]:
        for b in [0, 1]:
            ab = a & b
            a_xor_b = a ^ b
            a_and_axorb = a & a_xor_b
            result = ab ^ a_and_axorb
            print(f"  {a}  {b}  |  {ab}    {a_xor_b}      {a_and_axorb}"
                  f"           {result}        |    {'Y' if result == a else 'N'}")
    print()


def demo_set_theory_application():
    """Show how Boolean rings formalize set operations."""
    print("=" * 70)
    print("APPLICATION: SET ALGEBRA AS BOOLEAN RING")
    print("=" * 70)
    print()

    ring = BooleanRing(4)
    U = ring.to_set(ring.one())
    print(f"Universe U = {U}")
    print()

    A = ring.from_set({0, 1, 2})
    B = ring.from_set({1, 2, 3})
    C = ring.from_set({0, 3})

    print("Sets:")
    print(f"  A = {ring.to_set(A)}")
    print(f"  B = {ring.to_set(B)}")
    print(f"  C = {ring.to_set(C)}")
    print()

    print("Boolean ring operations on sets:")
    print(f"  A * B (intersection)     = {ring.to_set(ring.mul(A, B))}")
    print(f"  A + B (symmetric diff)   = {ring.to_set(ring.add(A, B))}")
    print(f"  1 - A (complement)       = {ring.to_set(ring.complement(A))}")
    print(f"  A * (1-A) (orthogonality) = {ring.to_set(ring.mul(A, ring.complement(A)))}")
    print()

    print("Partial order (a*b = a iff a is a subset of b):")
    AB_inter = ring.mul(A, B)
    print(f"  A <= B? A*B = {ring.to_set(ring.mul(A, B))} {'= A YES' if ring.mul(A, B) == A else '!= A NO'}")
    print(f"  A*B <= A? (A*B)*A = {ring.to_set(ring.mul(AB_inter, A))} "
          f"{'= A*B YES' if ring.mul(AB_inter, A) == AB_inter else '!= A*B NO'}")
    print()


def demo_error_detection():
    """Show application to simple error detection codes."""
    print("=" * 70)
    print("APPLICATION: ERROR DETECTION WITH BOOLEAN RING STRUCTURE")
    print("=" * 70)
    print()
    print("Boolean rings over GF(2) underlie all linear error-detecting codes.")
    print("The ring structure of Z/2Z (a Boolean ring!) is the foundation.")
    print()

    print("Example: Parity Check Code")
    print("The fact that Z/2Z is a Boolean ring (x^2 = x) means:")
    print("  * XOR is its own inverse (x + x = 0)")
    print("  * This gives us free error detection!")
    print()

    message = [1, 0, 1, 1, 0, 1]
    parity = sum(message) % 2
    print(f"  Message:  {message}")
    print(f"  Parity bit: {parity}")
    print(f"  Transmitted: {message + [parity]}")

    received = message + [parity]
    received_err = received.copy()
    received_err[2] = 1 - received_err[2]
    parity_check = sum(received_err) % 2
    print(f"\n  Received (with error at position 2): {received_err}")
    print(f"  Parity check: {parity_check} {'-> ERROR DETECTED' if parity_check != 0 else '-> OK'}")

    received_ok = received.copy()
    parity_check_ok = sum(received_ok) % 2
    print(f"\n  Received (no error): {received_ok}")
    print(f"  Parity check: {parity_check_ok} {'-> ERROR DETECTED' if parity_check_ok != 0 else '-> OK'}")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("=" * 70)
    print("  BOOLEAN RINGS AND THE ALGEBRA OF IDEMPOTENTS")
    print("  Interactive Demonstration")
    print("=" * 70)
    print()

    demo_basic_properties()
    demo_proof_walkthrough()
    demo_partial_order()

    print("=" * 70)
    print("GENERATING VISUALIZATIONS")
    print("=" * 70)
    plot_multiplication_table()
    plot_hasse_diagram()
    plot_idempotent_decomposition()
    print()

    demo_circuit_application()
    demo_set_theory_application()
    demo_error_detection()

    print("=" * 70)
    print("SUMMARY OF FORMALLY VERIFIED RESULTS (Lean 4)")
    print("=" * 70)
    print()
    print("All of the following have been formally verified in Lean 4 with Mathlib:")
    print()
    print("  1. Idempotent Complement:  e^2 = e  =>  (1-e)^2 = 1-e")
    print("  2. Idempotent Product:     e^2=e, f^2=f, ef=fe  =>  (ef)^2=ef")
    print("  3. Orthogonal Sum:         e^2=e, f^2=f, ef=fe=0  =>  (e+f)^2=e+f")
    print("  4. Orthogonality:          e^2=e  =>  e(1-e) = (1-e)e = 0")
    print("  5. Characteristic 2:       (forall x, x^2=x)  =>  x+x = 0")
    print("  6. Self-Negation:          (forall x, x^2=x)  =>  -x = x")
    print("  7. * COMMUTATIVITY:        (forall x, x^2=x)  =>  xy = yx")
    print("  8. Partial Order:          a*b=a defines a partial order")
    print("  9. Concrete Example:       Z/2Z is a Boolean ring")
    print()
    print("The key insight: a single algebraic axiom (idempotency) forces")
    print("both characteristic 2 AND commutativity. This is one of algebra's")
    print("most elegant derivations of structure from minimal assumptions.")
    print()
