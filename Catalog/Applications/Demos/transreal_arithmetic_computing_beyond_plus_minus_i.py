"""
Transreal Arithmetic Demo
========================
Demonstrates the key properties of Anderson's transreal number system:
- Total division (no undefined operations)
- Nullity (Φ) as an absorbing element
- Ring axiom failures
- Cancellation law collapse
"""

from enum import Enum
from typing import Union

class TransrealType(Enum):
    REAL = "real"
    POS_INF = "+∞"
    NEG_INF = "-∞"
    NULLITY = "Φ"

class Transreal:
    """A transreal number: either a real number, +∞, -∞, or Φ (nullity)."""

    def __init__(self, value: Union[float, str] = 0.0):
        if isinstance(value, str):
            if value in ("+inf", "inf", "+∞"):
                self.type = TransrealType.POS_INF
                self.value = float('inf')
            elif value in ("-inf", "-∞"):
                self.type = TransrealType.NEG_INF
                self.value = float('-inf')
            elif value in ("phi", "Φ", "nullity"):
                self.type = TransrealType.NULLITY
                self.value = None
            else:
                self.type = TransrealType.REAL
                self.value = float(value)
        elif value == float('inf'):
            self.type = TransrealType.POS_INF
            self.value = float('inf')
        elif value == float('-inf'):
            self.type = TransrealType.NEG_INF
            self.value = float('-inf')
        else:
            self.type = TransrealType.REAL
            self.value = float(value)

    def __repr__(self) -> str:
        if self.type == TransrealType.REAL:
            if self.value == int(self.value):
                return str(int(self.value))
            return str(self.value)
        return self.type.value

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Transreal):
            return NotImplemented
        if self.type != other.type:
            return False
        if self.type == TransrealType.REAL:
            return self.value == other.value
        return True

    def __neg__(self) -> "Transreal":
        if self.type == TransrealType.REAL:
            return Transreal(-self.value)
        if self.type == TransrealType.POS_INF:
            return Transreal("-inf")
        if self.type == TransrealType.NEG_INF:
            return Transreal("+inf")
        return Transreal("phi")

    def __add__(self, other: "Transreal") -> "Transreal":
        if self.type == TransrealType.NULLITY or other.type == TransrealType.NULLITY:
            return Transreal("phi")

        if self.type == TransrealType.REAL and other.type == TransrealType.REAL:
            return Transreal(self.value + other.value)

        if self.type == TransrealType.REAL:
            return Transreal(other.type.value)
        if other.type == TransrealType.REAL:
            return Transreal(self.type.value)

        # Both infinite
        if self.type == other.type:
            return Transreal(self.type.value)
        return Transreal("phi")  # ∞ + (-∞) = Φ

    def __mul__(self, other: "Transreal") -> "Transreal":
        if self.type == TransrealType.NULLITY or other.type == TransrealType.NULLITY:
            return Transreal("phi")

        if self.type == TransrealType.REAL and other.type == TransrealType.REAL:
            return Transreal(self.value * other.value)

        # One is real, other is infinite
        if self.type == TransrealType.REAL:
            if self.value > 0:
                return Transreal(other.type.value)
            elif self.value < 0:
                return -Transreal(other.type.value)
            else:
                return Transreal("phi")  # 0 × ∞ = Φ

        if other.type == TransrealType.REAL:
            if other.value > 0:
                return Transreal(self.type.value)
            elif other.value < 0:
                return -Transreal(self.type.value)
            else:
                return Transreal("phi")

        # Both infinite
        pos = (self.type == TransrealType.POS_INF) == (other.type == TransrealType.POS_INF)
        return Transreal("+inf") if pos else Transreal("-inf")

    def recip(self) -> "Transreal":
        if self.type == TransrealType.NULLITY:
            return Transreal("phi")
        if self.type in (TransrealType.POS_INF, TransrealType.NEG_INF):
            return Transreal(0)
        if self.value == 0:
            return Transreal("+inf")
        return Transreal(1.0 / self.value)

    def __truediv__(self, other: "Transreal") -> "Transreal":
        return self * other.recip()


def demo_basic_operations():
    """Demonstrate basic transreal arithmetic."""
    print("=" * 60)
    print("TRANSREAL ARITHMETIC DEMO")
    print("=" * 60)

    zero = Transreal(0)
    one = Transreal(1)
    two = Transreal(2)
    neg_one = Transreal(-1)
    inf = Transreal("+inf")
    neg_inf = Transreal("-inf")
    phi = Transreal("phi")

    print("\n--- Basic Arithmetic ---")
    print(f"1 + 2 = {one + two}")
    print(f"3 × 4 = {Transreal(3) * Transreal(4)}")
    print(f"-5 = {-Transreal(5)}")

    print("\n--- Infinity Arithmetic ---")
    print(f"∞ + ∞ = {inf + inf}")
    print(f"∞ + 1 = {inf + one}")
    print(f"∞ × 2 = {inf * two}")
    print(f"∞ × (-1) = {inf * neg_one}")
    print(f"∞ × ∞ = {inf * inf}")
    print(f"(-∞) × (-∞) = {neg_inf * neg_inf}")
    print(f"∞ × (-∞) = {inf * neg_inf}")

    print("\n--- The Birth of Nullity ---")
    print(f"∞ + (-∞) = {inf + neg_inf}  (not 0!)")
    print(f"0 × ∞ = {zero * inf}  (not 0!)")
    print(f"0 / 0 = {zero / zero}  (defined!)")
    print(f"∞ / ∞ = {inf / inf}")

    print("\n--- Nullity Absorption ---")
    print(f"Φ + 1 = {phi + one}")
    print(f"Φ × 5 = {phi * Transreal(5)}")
    print(f"Φ + ∞ = {phi + inf}")
    print(f"Φ × Φ = {phi * phi}")
    print(f"-Φ = {-phi}")
    print(f"1/Φ = {phi.recip()}")

    print("\n--- Total Division ---")
    print(f"1/0 = {one / zero}  (defined as +∞)")
    print(f"(-1)/0 = {neg_one / zero}")
    print(f"0/0 = {zero / zero}  (defined as Φ)")
    print(f"5/0 = {Transreal(5) / zero}")


def demo_ring_failures():
    """Demonstrate how ring axioms fail."""
    print("\n" + "=" * 60)
    print("RING AXIOM FAILURES")
    print("=" * 60)

    zero = Transreal(0)
    one = Transreal(1)
    inf = Transreal("+inf")
    neg_inf = Transreal("-inf")

    print("\n--- Failure 1: Additive Inverse ---")
    print(f"∞ + (-∞) = {inf + neg_inf}  (should be 0 for a ring)")
    print("→ posInf has no additive inverse!")

    print("\n--- Failure 2: Zero Absorption ---")
    print(f"0 × ∞ = {zero * inf}  (should be 0 for a ring)")
    print("→ The ring axiom 0 × x = 0 fails!")

    print("\n--- Failure 3: Left Distributivity ---")
    a, b, c = inf, one, neg_inf
    lhs = a * (b + c)
    rhs = a * b + a * c
    print(f"∞ × (1 + (-∞)) = ∞ × (-∞) = {lhs}")
    print(f"∞ × 1 + ∞ × (-∞) = ∞ + (-∞) = {rhs}")
    print(f"LHS ≠ RHS: {lhs} ≠ {rhs}")
    print("→ Left distributivity fails!")

    print("\n--- Failure 4: Cancellation ---")
    print(f"∞ + 1 = {inf + one}")
    print(f"∞ + 2 = {inf + Transreal(2)}")
    print(f"Both equal ∞, but 1 ≠ 2!")
    print("→ Additive cancellation fails!")


def demo_idempotents():
    """Show additive idempotent classification."""
    print("\n" + "=" * 60)
    print("ADDITIVE IDEMPOTENTS: x + x = x")
    print("=" * 60)

    candidates = [
        Transreal(0), Transreal(1), Transreal(-1), Transreal(0.5),
        Transreal("+inf"), Transreal("-inf"), Transreal("phi")
    ]

    for x in candidates:
        result = x + x
        is_idemp = result == x
        print(f"  {x} + {x} = {result}  {'✓ IDEMPOTENT' if is_idemp else ''}")

    print("\nExactly 4 idempotents: 0, +∞, -∞, Φ")


def demo_nullity_propagation():
    """Demonstrate nullity propagation through expressions."""
    print("\n" + "=" * 60)
    print("NULLITY PROPAGATION")
    print("=" * 60)

    phi = Transreal("phi")
    values = [Transreal(1), Transreal("+inf"), Transreal("-inf"), Transreal(0)]

    for v in values:
        expr1 = (phi + v) * Transreal(3)
        expr2 = (phi * v) + Transreal(5)
        expr3 = (v + phi) * (Transreal(2) + Transreal(7))
        print(f"  (Φ + {v}) × 3 = {expr1}")
        print(f"  (Φ × {v}) + 5 = {expr2}")
        print(f"  ({v} + Φ) × 9 = {expr3}")
        print()

    print("Conclusion: Nullity absorbs — any expression with Φ yields Φ")


if __name__ == "__main__":
    demo_basic_operations()
    demo_ring_failures()
    demo_idempotents()
    demo_nullity_propagation()


"""
Visualization: Transreal Multiplication Table
=============================================
Creates a heatmap showing the multiplication table for transreal numbers,
highlighting where nullity (Φ) appears — the "infection zones" where
standard arithmetic breaks down.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def transreal_mul(a_kind: str, a_val: float, b_kind: str, b_val: float) -> tuple[str, float]:
    """Compute a * b in transreal arithmetic. Returns (kind, value)."""
    if a_kind == "phi" or b_kind == "phi":
        return ("phi", 0)

    if a_kind == "real" and b_kind == "real":
        return ("real", a_val * b_val)

    if a_kind == "real":
        if a_val > 0:
            return (b_kind, 0)
        elif a_val < 0:
            return ("neg_inf" if b_kind == "pos_inf" else "pos_inf", 0)
        else:
            return ("phi", 0)

    if b_kind == "real":
        if b_val > 0:
            return (a_kind, 0)
        elif b_val < 0:
            return ("neg_inf" if a_kind == "pos_inf" else "pos_inf", 0)
        else:
            return ("phi", 0)

    # Both infinite
    same = (a_kind == "pos_inf") == (b_kind == "pos_inf")
    return ("pos_inf" if same else "neg_inf", 0)


def kind_to_color(kind: str, val: float) -> int:
    """Map transreal result to a color code."""
    if kind == "phi":
        return 0  # nullity - red
    elif kind == "pos_inf":
        return 1  # +∞ - blue
    elif kind == "neg_inf":
        return 2  # -∞ - purple
    elif val > 0:
        return 3  # positive real - green
    elif val < 0:
        return 4  # negative real - orange
    else:
        return 5  # zero - gray


def main():
    labels = ["-∞", "-2", "-1", "0", "1", "2", "+∞", "Φ"]
    elements = [
        ("neg_inf", 0), ("real", -2), ("real", -1), ("real", 0),
        ("real", 1), ("real", 2), ("pos_inf", 0), ("phi", 0)
    ]
    n = len(elements)

    grid = np.zeros((n, n), dtype=int)
    result_labels = [['' for _ in range(n)] for _ in range(n)]

    for i, (ak, av) in enumerate(elements):
        for j, (bk, bv) in enumerate(elements):
            rk, rv = transreal_mul(ak, av, bk, bv)
            grid[i, j] = kind_to_color(rk, rv)
            if rk == "phi":
                result_labels[i][j] = "Φ"
            elif rk == "pos_inf":
                result_labels[i][j] = "+∞"
            elif rk == "neg_inf":
                result_labels[i][j] = "-∞"
            else:
                v = rv
                result_labels[i][j] = str(int(v)) if v == int(v) else f"{v:.1f}"

    colors = ['#e74c3c', '#3498db', '#9b59b6', '#2ecc71', '#e67e22', '#95a5a6']
    cmap = plt.matplotlib.colors.ListedColormap(colors)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.imshow(grid, cmap=cmap, vmin=0, vmax=5, aspect='equal')

    for i in range(n):
        for j in range(n):
            color = 'white' if grid[i, j] in [0, 2] else 'black'
            ax.text(j, i, result_labels[i][j], ha='center', va='center',
                    fontsize=11, fontweight='bold', color=color)

    ax.set_xticks(range(n))
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_yticks(range(n))
    ax.set_yticklabels(labels, fontsize=12)
    ax.set_xlabel('b', fontsize=14)
    ax.set_ylabel('a', fontsize=14)
    ax.set_title('Transreal Multiplication Table: a × b\n'
                 '(Red = Nullity Φ — where ring axioms break)', fontsize=14)

    legend_items = [
        mpatches.Patch(color='#e74c3c', label='Φ (Nullity)'),
        mpatches.Patch(color='#3498db', label='+∞'),
        mpatches.Patch(color='#9b59b6', label='-∞'),
        mpatches.Patch(color='#2ecc71', label='Positive real'),
        mpatches.Patch(color='#e67e22', label='Negative real'),
        mpatches.Patch(color='#95a5a6', label='Zero'),
    ]
    ax.legend(handles=legend_items, loc='upper left', bbox_to_anchor=(1.02, 1),
              fontsize=10)

    plt.tight_layout()
    plt.savefig('transreal_multiplication_table.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: transreal_multiplication_table.png")


if __name__ == "__main__":
    main()
