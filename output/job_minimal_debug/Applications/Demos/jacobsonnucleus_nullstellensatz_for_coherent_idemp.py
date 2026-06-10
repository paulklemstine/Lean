#!/usr/bin/env python3
"""
Congruence Elimination for Idempotent Semirings — Interactive Demo

This script demonstrates:
1. The Boolean semiring and polynomial congruences
2. Why the classical Sylvester resultant fails in semirings
3. The counterexample to the linResultantPair conjecture
4. Correct results: four-products congruence and sandwich lemmas
5. Tropical semiring examples

Author: Generated as companion to the Lean 4 formalization
"""

import itertools
from collections import defaultdict
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# ═══════════════════════════════════════════════════════════════
# 1. Boolean Semiring Implementation
# ═══════════════════════════════════════════════════════════════

class BoolSemiring:
    """The two-element Boolean semiring {0, 1} with + = OR, * = AND.
    This is additively idempotent: a + a = a for all a."""

    def __init__(self, val):
        self.val = bool(val)

    def __add__(self, other):
        return BoolSemiring(self.val or other.val)

    def __mul__(self, other):
        return BoolSemiring(self.val and other.val)

    def __eq__(self, other):
        return self.val == other.val

    def __hash__(self):
        return hash(self.val)

    def __repr__(self):
        return "1" if self.val else "0"

    @staticmethod
    def zero():
        return BoolSemiring(False)

    @staticmethod
    def one():
        return BoolSemiring(True)


# ═══════════════════════════════════════════════════════════════
# 2. Polynomial over a Semiring
# ═══════════════════════════════════════════════════════════════

class SemiringPoly:
    """Univariate polynomial over a semiring.

    Represented as a list of coefficients: [a₀, a₁, a₂, ...]
    meaning a₀ + a₁·X + a₂·X² + ...
    """

    def __init__(self, coeffs, semiring_zero=None):
        self.coeffs = list(coeffs)
        self.zero = semiring_zero or (type(coeffs[0]).zero() if coeffs else BoolSemiring.zero())
        # Trim trailing zeros
        while self.coeffs and self.coeffs[-1] == self.zero:
            self.coeffs.pop()

    def degree(self):
        return max(0, len(self.coeffs) - 1)

    def coeff(self, n):
        return self.coeffs[n] if n < len(self.coeffs) else self.zero

    def __add__(self, other):
        n = max(len(self.coeffs), len(other.coeffs))
        result = [self.coeff(i) + other.coeff(i) for i in range(n)]
        return SemiringPoly(result if result else [self.zero], self.zero)

    def __mul__(self, other):
        if not self.coeffs or not other.coeffs:
            return SemiringPoly([self.zero], self.zero)
        n = len(self.coeffs) + len(other.coeffs) - 1
        result = [self.zero] * n
        for i, a in enumerate(self.coeffs):
            for j, b in enumerate(other.coeffs):
                result[i + j] = result[i + j] + a * b
        return SemiringPoly(result, self.zero)

    def __eq__(self, other):
        n = max(len(self.coeffs), len(other.coeffs))
        return all(self.coeff(i) == other.coeff(i) for i in range(n))

    def __hash__(self):
        return hash(tuple(self.coeffs))

    def __repr__(self):
        if not self.coeffs:
            return "0"
        terms = []
        for i, c in enumerate(self.coeffs):
            if c == self.zero:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}·X" if str(c) != "1" else "X")
            else:
                terms.append(f"{c}·X^{i}" if str(c) != "1" else f"X^{i}")
        return " + ".join(terms) if terms else "0"


# ═══════════════════════════════════════════════════════════════
# 3. Semiring Congruence
# ═══════════════════════════════════════════════════════════════

class SemiringCongruence:
    """Compute the smallest semiring congruence containing given pairs.

    Uses a union-find approach with saturation under +, * closure.
    Works for FINITE polynomial rings (bounded degree).
    """

    def __init__(self, elements, generators):
        """
        elements: list of all elements in the semiring
        generators: list of (a, b) pairs that should be congruent
        """
        self.elements = list(elements)
        self.elem_to_idx = {e: i for i, e in enumerate(self.elements)}
        self.parent = list(range(len(self.elements)))

        # Initialize with generators
        for a, b in generators:
            self._union(self.elem_to_idx[a], self.elem_to_idx[b])

        # Saturate: close under + and *
        self._saturate()

    def _find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def _union(self, x, y):
        rx, ry = self._find(x), self._find(y)
        if rx != ry:
            self.parent[rx] = ry
            return True
        return False

    def _saturate(self):
        changed = True
        while changed:
            changed = False
            n = len(self.elements)
            for i in range(n):
                for j in range(n):
                    if self._find(i) == self._find(j):
                        continue
                    # Check if i and j should be merged
                    ei, ej = self.elements[i], self.elements[j]

                    # For each pair (a, b) with a ≡ b, and each element c:
                    # a + c ≡ b + c and a * c ≡ b * c
                    for k in range(n):
                        if self._find(i) != self._find(j):
                            break
                    # Actually, let me do this more carefully
                    pass

            # Better approach: iterate over all congruent pairs
            # and close under + and *
            pairs_to_add = []
            for i in range(n):
                for j in range(i + 1, n):
                    if self._find(i) == self._find(j):
                        ei, ej = self.elements[i], self.elements[j]
                        for k in range(n):
                            ek = self.elements[k]
                            # ei + ek ≡ ej + ek
                            sum_i = ei + ek
                            sum_j = ej + ek
                            if sum_i in self.elem_to_idx and sum_j in self.elem_to_idx:
                                si, sj = self.elem_to_idx[sum_i], self.elem_to_idx[sum_j]
                                if self._find(si) != self._find(sj):
                                    pairs_to_add.append((si, sj))

                            # ei * ek ≡ ej * ek
                            prod_i = ei * ek
                            prod_j = ej * ek
                            if prod_i in self.elem_to_idx and prod_j in self.elem_to_idx:
                                pi, pj = self.elem_to_idx[prod_i], self.elem_to_idx[prod_j]
                                if self._find(pi) != self._find(pj):
                                    pairs_to_add.append((pi, pj))

            for a, b in pairs_to_add:
                if self._union(a, b):
                    changed = True

    def are_congruent(self, a, b):
        if a not in self.elem_to_idx or b not in self.elem_to_idx:
            return False
        return self._find(self.elem_to_idx[a]) == self._find(self.elem_to_idx[b])

    def equivalence_classes(self):
        classes = defaultdict(list)
        for i, e in enumerate(self.elements):
            classes[self._find(i)].append(e)
        return list(classes.values())


# ═══════════════════════════════════════════════════════════════
# 4. Generate Boolean Polynomial Ring (bounded degree)
# ═══════════════════════════════════════════════════════════════

def bool_polys(max_degree=3):
    """Generate all Boolean polynomials up to given degree."""
    B0, B1 = BoolSemiring.zero(), BoolSemiring.one()
    polys = set()
    # Each polynomial is determined by which coefficients are 1
    for bits in range(2 ** (max_degree + 1)):
        coeffs = []
        for i in range(max_degree + 1):
            coeffs.append(B1 if (bits >> i) & 1 else B0)
        p = SemiringPoly(coeffs, B0)
        polys.add(p)
    return list(polys)


# ═══════════════════════════════════════════════════════════════
# 5. Counterexample Demonstration
# ═══════════════════════════════════════════════════════════════

def demonstrate_counterexample():
    """Demonstrate the counterexample to linResultantPair_mem_elimination."""
    B0, B1 = BoolSemiring.zero(), BoolSemiring.one()

    print("=" * 70)
    print("COUNTEREXAMPLE: linResultantPair_mem_elimination is FALSE")
    print("=" * 70)
    print()
    print("Semiring: Boolean ({0, 1}, OR, AND)")
    print("  Additively idempotent: a + a = a (since a ∨ a = a)")
    print()

    # Define the polynomial pairs
    one = SemiringPoly([B1], B0)  # constant 1
    X = SemiringPoly([B0, B1], B0)  # the variable X

    p_lhs, p_rhs = one, X
    q_lhs, q_rhs = X, one

    print(f"  p.lhs = {p_lhs},  p.rhs = {p_rhs}")
    print(f"  q.lhs = {q_lhs},  q.rhs = {q_rhs}")
    print()

    # Extract coefficients
    a0, a1 = p_lhs.coeff(0), p_lhs.coeff(1)  # 1, 0
    b0, b1 = p_rhs.coeff(0), p_rhs.coeff(1)  # 0, 1
    c0, c1 = q_lhs.coeff(0), q_lhs.coeff(1)  # 0, 1
    d0, d1 = q_rhs.coeff(0), q_rhs.coeff(1)  # 1, 0

    print("  Coefficients:")
    print(f"    a₀ = {a0}, a₁ = {a1}  (p.lhs = {a0} + {a1}·X)")
    print(f"    b₀ = {b0}, b₁ = {b1}  (p.rhs = {b0} + {b1}·X)")
    print(f"    c₀ = {c0}, c₁ = {c1}  (q.lhs = {c0} + {c1}·X)")
    print(f"    d₀ = {d0}, d₁ = {d1}  (q.rhs = {d0} + {d1}·X)")
    print()

    # Compute linResultantPair
    fst = a1 * c0 + b0 * d1  # 0*0 + 0*0 = 0
    snd = a0 * c1 + b1 * d0  # 1*1 + 1*1 = 1+1 = 1 (idempotent)

    print(f"  linResultantPair:")
    print(f"    fst = a₁·c₀ + b₀·d₁ = {a1}·{c0} + {b0}·{d1} = {fst}")
    print(f"    snd = a₀·c₁ + b₁·d₀ = {a0}·{c1} + {b1}·{d0} = {snd}")
    print()
    print(f"  The conjecture claims: 0 ≡ 1 in the elimination congruence.")
    print()

    # Compute the actual congruence
    max_deg = 3
    all_polys = bool_polys(max_deg)

    cong = SemiringCongruence(all_polys, [(one, X)])
    classes = cong.equivalence_classes()

    print(f"  Congruence generated by (1, X) on Bool[X] (degree ≤ {max_deg}):")
    print(f"    Number of equivalence classes: {len(classes)}")
    for i, cls in enumerate(sorted(classes, key=lambda c: len(c))):
        if len(cls) <= 5:
            print(f"    Class {i+1}: {{{', '.join(str(p) for p in cls)}}}")
        else:
            print(f"    Class {i+1}: {{{', '.join(str(p) for p in list(cls)[:3])}, ...}} ({len(cls)} elements)")
    print()

    zero = SemiringPoly([B0], B0)
    result = cong.are_congruent(zero, one)
    print(f"  Is 0 ≡ 1?  {result}")
    print(f"  ⇒ The conjecture is {'TRUE' if result else 'FALSE'}!")
    print()

    if not result:
        print("  WHY: The class of 0 is {0} alone. In a semiring, 0·f = 0 and")
        print("  0 + f = f, so 0 can never be derived congruent to any non-zero")
        print("  element. The class of 1 includes {1, X, X², 1+X, ...} (all non-zero")
        print("  polynomials). Therefore 0 ≢ 1.")
    print()


# ═══════════════════════════════════════════════════════════════
# 6. Correct Results Demonstration
# ═══════════════════════════════════════════════════════════════

def demonstrate_correct_results():
    """Demonstrate the correct theorems that DO hold."""
    B0, B1 = BoolSemiring.zero(), BoolSemiring.one()

    print("=" * 70)
    print("CORRECT RESULTS (formally verified in Lean 4)")
    print("=" * 70)
    print()

    one = SemiringPoly([B1], B0)
    X = SemiringPoly([B0, B1], B0)
    oneX = SemiringPoly([B1, B1], B0)  # 1 + X

    # Example pairs
    p_lhs, p_rhs = oneX, X  # 1+X ≡ X
    q_lhs, q_rhs = one, oneX  # 1 ≡ 1+X

    print("Example: p = (1+X, X), q = (1, 1+X)")
    print(f"  p.lhs = {p_lhs}, p.rhs = {p_rhs}")
    print(f"  q.lhs = {q_lhs}, q.rhs = {q_rhs}")
    print()

    max_deg = 4
    all_polys = bool_polys(max_deg)
    cong = SemiringCongruence(all_polys, [(p_lhs, p_rhs), (q_lhs, q_rhs)])

    # Theorem 1: Four products congruent
    print("  Theorem: four_products_congruent")
    print("    All four products p.x * q.y are mutually congruent:")
    prods = {
        "p.lhs * q.lhs": p_lhs * q_lhs,
        "p.lhs * q.rhs": p_lhs * q_rhs,
        "p.rhs * q.lhs": p_rhs * q_lhs,
        "p.rhs * q.rhs": p_rhs * q_rhs,
    }
    for name, val in prods.items():
        print(f"      {name} = {val}")

    all_congruent = True
    prod_list = list(prods.values())
    for i in range(len(prod_list)):
        for j in range(i + 1, len(prod_list)):
            if not cong.are_congruent(prod_list[i], prod_list[j]):
                all_congruent = False
    print(f"    All mutually congruent? {all_congruent} ✓")
    print()

    # Theorem 2: Direct-cross sum congruent
    print("  Theorem: direct_cross_sum_congruent")
    S1 = p_lhs * q_lhs + p_rhs * q_rhs
    S2 = p_lhs * q_rhs + p_rhs * q_lhs
    print(f"    S₁ = p.lhs*q.lhs + p.rhs*q.rhs = {S1}")
    print(f"    S₂ = p.lhs*q.rhs + p.rhs*q.lhs = {S2}")
    print(f"    S₁ ≡ S₂? {cong.are_congruent(S1, S2)} ✓")
    print()

    # Theorem 3: Sandwich lemmas
    print("  Theorem: idempotent_sandwich_left/right")
    print(f"    p.lhs ≡ p.lhs + p.rhs? {cong.are_congruent(p_lhs, p_lhs + p_rhs)} ✓")
    print(f"    p.lhs + p.rhs ≡ p.rhs? {cong.are_congruent(p_lhs + p_rhs, p_rhs)} ✓")
    print()


# ═══════════════════════════════════════════════════════════════
# 7. Tropical Semiring Example
# ═══════════════════════════════════════════════════════════════

class TropicalElement:
    """Element of the tropical semiring (ℝ ∪ {-∞}, max, +).

    Addition = max, Multiplication = +, Zero = -∞, One = 0.
    This is additively idempotent: max(a, a) = a.
    """

    def __init__(self, val):
        self.val = val  # None represents -∞

    def __add__(self, other):
        if self.val is None:
            return other
        if other.val is None:
            return self
        return TropicalElement(max(self.val, other.val))

    def __mul__(self, other):
        if self.val is None or other.val is None:
            return TropicalElement(None)
        return TropicalElement(self.val + other.val)

    def __eq__(self, other):
        return self.val == other.val

    def __hash__(self):
        return hash(self.val)

    def __repr__(self):
        return str(self.val) if self.val is not None else "-∞"

    @staticmethod
    def zero():
        return TropicalElement(None)

    @staticmethod
    def one():
        return TropicalElement(0)


def demonstrate_tropical():
    """Demonstrate tropical polynomial congruences."""
    print("=" * 70)
    print("TROPICAL SEMIRING EXAMPLE")
    print("=" * 70)
    print()
    print("The tropical semiring (ℝ ∪ {-∞}, max, +) is additively idempotent.")
    print("Here, 'addition' is max and 'multiplication' is +.")
    print()

    T = TropicalElement

    # Tropical linear polynomial: max(a₀, a₁ + x)
    # Represented as [a₀, a₁]
    a0, a1 = T(3), T(1)
    b0, b1 = T(2), T(4)
    c0, c1 = T(5), T(0)
    d0, d1 = T(1), T(3)

    print("  p.lhs = max(3, 1+x),  p.rhs = max(2, 4+x)")
    print("  q.lhs = max(5, 0+x),  q.rhs = max(1, 3+x)")
    print()

    # Classical resultant of two linear polynomials max(a₀, a₁+x) and max(c₀, c₁+x)
    # is max(a₀+c₁, a₁+c₀)
    res_lhs = a0 * c1 + a1 * c0  # max(3+0, 1+5) = max(3, 6) = 6
    res_rhs = b0 * d1 + b1 * d0  # max(2+3, 4+1) = max(5, 5) = 5

    print("  Tropical resultant of (p.lhs, q.lhs):")
    print(f"    Res = max(a₀·c₁, a₁·c₀) = max({a0}+{c1}, {a1}+{c0}) = {res_lhs}")
    print(f"  Tropical resultant of (p.rhs, q.rhs):")
    print(f"    Res = max(b₀·d₁, b₁·d₀) = max({b0}+{d1}, {b1}+{d0}) = {res_rhs}")
    print()

    # linResultantPair
    fst = a1 * c0 + b0 * d1  # max(1+5, 2+3) = max(6, 5) = 6
    snd = a0 * c1 + b1 * d0  # max(3+0, 4+1) = max(3, 5) = 5

    print("  linResultantPair:")
    print(f"    fst = max(a₁·c₀, b₀·d₁) = max({a1}+{c0}, {b0}+{d1}) = {fst}")
    print(f"    snd = max(a₀·c₁, b₁·d₀) = max({a0}+{c1}, {b1}+{d0}) = {snd}")
    print()
    print(f"  The conjecture would require {fst} ≡ {snd} (i.e., 6 ≡ 5)")
    print("  in the elimination congruence. Whether this holds depends on")
    print("  the specific congruence C — it does NOT hold in general.")
    print()

    # Show the connection to classical determinant
    print("  Connection to classical algebra:")
    print(f"    Classical det = a₁c₀ - a₀c₁ = {a1.val}+{c0.val} - ({a0.val}+{c1.val}) = {a1.val+c0.val - (a0.val+c1.val)}")
    print(f"    This becomes: fst - snd in tropical = {fst.val} - {snd.val} = {fst.val - snd.val}")
    print("    The tropical resultant 'splits' the determinant into max and min parts.")
    print()


# ═══════════════════════════════════════════════════════════════
# 8. Visualization
# ═══════════════════════════════════════════════════════════════

def visualize_congruence_classes():
    """Create a visualization of congruence classes in Bool[X]."""
    B0, B1 = BoolSemiring.zero(), BoolSemiring.one()

    one = SemiringPoly([B1], B0)
    X = SemiringPoly([B0, B1], B0)

    max_deg = 3
    all_polys = bool_polys(max_deg)
    cong = SemiringCongruence(all_polys, [(one, X)])
    classes = cong.equivalence_classes()

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: congruence classes as a partition
    ax = axes[0]
    ax.set_title("Congruence Classes in Bool[X]\n(generated by 1 ≡ X)", fontsize=13)

    # Sort classes by size
    classes_sorted = sorted(classes, key=lambda c: len(c))

    colors = plt.cm.Set3(np.linspace(0, 1, len(classes_sorted)))
    y_pos = 0
    for i, cls in enumerate(classes_sorted):
        polys_str = [str(p) for p in sorted(cls, key=str)]
        for j, ps in enumerate(polys_str):
            ax.text(0.05, y_pos, ps, fontsize=9, fontfamily='monospace',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor=colors[i], alpha=0.7))
            y_pos += 1
        y_pos += 0.5

    ax.set_xlim(-0.1, 1)
    ax.set_ylim(-0.5, y_pos)
    ax.set_axis_off()

    # Add legend
    zero_patch = mpatches.Patch(color=colors[0], alpha=0.7, label='{0} — isolated')
    nonzero_patch = mpatches.Patch(color=colors[-1], alpha=0.7, label='Non-zero — all congruent')
    ax.legend(handles=[zero_patch, nonzero_patch], loc='upper right', fontsize=10)

    # Right: the four products theorem
    ax = axes[1]
    ax.set_title("Four Products Theorem\n(all products are congruent)", fontsize=13)

    products = [
        ("p.lhs × q.lhs", (0.2, 0.8)),
        ("p.lhs × q.rhs", (0.8, 0.8)),
        ("p.rhs × q.lhs", (0.2, 0.2)),
        ("p.rhs × q.rhs", (0.8, 0.2)),
    ]

    for name, (x, y) in products:
        circle = plt.Circle((x, y), 0.12, color='steelblue', alpha=0.3)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw congruence arrows
    for i in range(len(products)):
        for j in range(i + 1, len(products)):
            x1, y1 = products[i][1]
            x2, y2 = products[j][1]
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                        arrowprops=dict(arrowstyle="<->", color='red', lw=1.5, alpha=0.6))

    ax.text(0.5, 0.5, "≡", fontsize=24, ha='center', va='center', color='red',
            fontweight='bold')
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.1, 1.1)
    ax.set_axis_off()

    plt.tight_layout()
    plt.savefig("/workspace/request-project/Speculative/CongruenceElimination/congruence_visualization.png",
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Visualization saved to congruence_visualization.png")
    print()


def visualize_tropical_elimination():
    """Visualize the tropical elimination problem."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: tropical linear polynomials
    ax = axes[0]
    ax.set_title("Tropical Linear Polynomials\nmax(aᵢ, aᵢ₊₁ + x)", fontsize=12)

    x = np.linspace(-5, 8, 300)

    def trop_linear(a0, a1, x):
        return np.maximum(a0, a1 + x)

    # p.lhs = max(3, 1+x), p.rhs = max(2, 4+x)
    y_pl = trop_linear(3, 1, x)
    y_pr = trop_linear(2, 4, x)
    # q.lhs = max(5, 0+x), q.rhs = max(1, 3+x)
    y_ql = trop_linear(5, 0, x)
    y_qr = trop_linear(1, 3, x)

    ax.plot(x, y_pl, 'b-', linewidth=2, label='p.lhs = max(3, 1+x)')
    ax.plot(x, y_pr, 'b--', linewidth=2, label='p.rhs = max(2, 4+x)')
    ax.plot(x, y_ql, 'r-', linewidth=2, label='q.lhs = max(5, x)')
    ax.plot(x, y_qr, 'r--', linewidth=2, label='q.rhs = max(1, 3+x)')

    # Mark the "bend points" (tropical roots)
    ax.plot(2, 3, 'bo', markersize=8)  # p.lhs bend at x=2
    ax.plot(-2, 2, 'bs', markersize=8)  # p.rhs bend at x=-2
    ax.plot(5, 5, 'ro', markersize=8)  # q.lhs bend at x=5
    ax.plot(-2, 1, 'rs', markersize=8)  # q.rhs bend at x=-2

    ax.set_xlabel('x', fontsize=11)
    ax.set_ylabel('value', fontsize=11)
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Right: the elimination problem
    ax = axes[1]
    ax.set_title("Why Tropical Elimination Differs\nfrom Classical Elimination", fontsize=12)

    # Show the Sylvester matrix analogy
    table_data = [
        ["Classical", "Tropical (Idempotent)"],
        ["a₁c₀ − a₀c₁", "max(a₁+c₀, a₀+c₁)"],
        ["Subtraction ✓", "No subtraction ✗"],
        ["Exact elimination", "Partial information"],
        ["Resultant ∈ k", "No guaranteed elim."],
    ]

    row_labels = ["Setting", "Resultant", "Key operation", "Elimination", "Result"]

    ax.axis('off')
    table = ax.table(
        cellText=table_data,
        rowLabels=row_labels,
        cellLoc='center',
        rowLoc='center',
        loc='center',
        colWidths=[0.4, 0.4]
    )
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1.2, 1.8)

    # Color the header
    for j in range(2):
        table[0, j].set_facecolor('#E8E8E8')
        table[0, j].set_text_props(fontweight='bold')

    plt.tight_layout()
    plt.savefig("/workspace/request-project/Speculative/CongruenceElimination/tropical_elimination.png",
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Visualization saved to tropical_elimination.png")
    print()


# ═══════════════════════════════════════════════════════════════
# 9. Applications
# ═══════════════════════════════════════════════════════════════

def demonstrate_applications():
    """Show practical applications of the congruence elimination framework."""
    print("=" * 70)
    print("APPLICATIONS OF CONGRUENCE ELIMINATION")
    print("=" * 70)
    print()

    print("1. STATIC ANALYSIS (Abstract Interpretation)")
    print("   " + "-" * 50)
    print("   In program analysis, abstract domains are often idempotent semirings.")
    print("   The sign domain {⊥, -, 0, +, ⊤} with join (⊔) and meet (⊓)")
    print("   forms such a structure. Eliminating variables from polynomial")
    print("   constraints lets us derive program invariants.")
    print()
    print("   Example: Given constraints x·y ≡ x and x + y ≡ y,")
    print("   we can derive facts about x and y independently.")
    print()

    print("2. TROPICAL GEOMETRY (Combinatorial Optimization)")
    print("   " + "-" * 50)
    print("   Tropical polynomial congruences model systems of optimization")
    print("   constraints. The (max, +) semiring arises in:")
    print("   - Shortest path problems")
    print("   - Scheduling and project planning (PERT/CPM)")
    print("   - Network flow optimization")
    print()
    print("   Our results show that naive variable elimination (imitating")
    print("   Gaussian elimination) fails. Instead, one must use tropical")
    print("   geometry techniques (bend relations, tropical resultants).")
    print()

    print("3. DATABASE QUERY OPTIMIZATION")
    print("   " + "-" * 50)
    print("   Semiring-valued databases (provenance semirings) use congruences")
    print("   to express query equivalences. Eliminating variables corresponds")
    print("   to projecting out columns, and our framework characterizes when")
    print("   this preserves the congruence structure.")
    print()

    print("4. FORMAL VERIFICATION")
    print("   " + "-" * 50)
    print("   The Lean 4 formalization provides machine-checked guarantees:")
    print("   - Every proved theorem is correct (verified by Lean's kernel)")
    print("   - The counterexample is rigorous (no hand-waving)")
    print("   - The framework can be extended to more complex settings")
    print()


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Congruence Elimination for Idempotent Semirings            ║")
    print("║  Interactive Demonstration                                   ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demonstrate_counterexample()
    demonstrate_correct_results()
    demonstrate_tropical()
    demonstrate_applications()

    print("=" * 70)
    print("GENERATING VISUALIZATIONS...")
    print("=" * 70)
    print()
    visualize_congruence_classes()
    visualize_tropical_elimination()

    print("Done! All demonstrations complete.")
    print()
    print("Summary of findings:")
    print("  ✗ linResultantPair_mem_elimination is FALSE (counterexample in Bool[X])")
    print("  ✓ four_products_congruent — proved in Lean 4")
    print("  ✓ direct_cross_sum_congruent — proved in Lean 4")
    print("  ✓ idempotent_sandwich_left/right — proved in Lean 4")
    print("  ✓ full_expansion_congruent — proved in Lean 4")
    print("  ✓ All other framework lemmas — proved in Lean 4")
