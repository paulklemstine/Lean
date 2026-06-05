#!/usr/bin/env python3
"""
Transreal Arithmetic Demo: Computing Beyond Plus-Minus Infinity

Demonstrates Anderson's transreal number system R ∪ {+∞, -∞, Φ} where Φ = 0/0.
Shows ring axiom failures and wheel structure emergence.
"""

from enum import Enum
from typing import Union


class TransrealType(Enum):
    REAL = "real"
    POS_INF = "+∞"
    NEG_INF = "-∞"
    NULLITY = "Φ"


class Transreal:
    """A transreal number: either a real number, ±∞, or nullity (Φ = 0/0)."""

    def __init__(self, value: Union[float, str]):
        if isinstance(value, str):
            if value in ("+inf", "posInf", "+∞"):
                self.type = TransrealType.POS_INF
                self.value = None
            elif value in ("-inf", "negInf", "-∞"):
                self.type = TransrealType.NEG_INF
                self.value = None
            elif value in ("nullity", "Φ", "phi"):
                self.type = TransrealType.NULLITY
                self.value = None
            else:
                self.type = TransrealType.REAL
                self.value = float(value)
        else:
            self.type = TransrealType.REAL
            self.value = float(value)

    def __repr__(self):
        if self.type == TransrealType.REAL:
            return f"real({self.value})"
        return self.type.value

    def __eq__(self, other):
        if not isinstance(other, Transreal):
            return False
        if self.type != other.type:
            return False
        if self.type == TransrealType.REAL:
            return self.value == other.value
        return True

    def __add__(self, other):
        # Nullity absorbs
        if self.type == TransrealType.NULLITY or other.type == TransrealType.NULLITY:
            return Transreal("Φ")
        # Infinity cases
        if self.type == TransrealType.POS_INF:
            if other.type == TransrealType.POS_INF:
                return Transreal("+∞")
            elif other.type == TransrealType.NEG_INF:
                return Transreal("Φ")
            else:
                return Transreal("+∞")
        if self.type == TransrealType.NEG_INF:
            if other.type == TransrealType.POS_INF:
                return Transreal("Φ")
            elif other.type == TransrealType.NEG_INF:
                return Transreal("-∞")
            else:
                return Transreal("-∞")
        if other.type == TransrealType.POS_INF:
            return Transreal("+∞")
        if other.type == TransrealType.NEG_INF:
            return Transreal("-∞")
        # Both real
        return Transreal(self.value + other.value)

    def __mul__(self, other):
        # Nullity absorbs
        if self.type == TransrealType.NULLITY or other.type == TransrealType.NULLITY:
            return Transreal("Φ")
        # Both real
        if self.type == TransrealType.REAL and other.type == TransrealType.REAL:
            return Transreal(self.value * other.value)
        # Infinity × Infinity
        if self.type in (TransrealType.POS_INF, TransrealType.NEG_INF) and \
           other.type in (TransrealType.POS_INF, TransrealType.NEG_INF):
            same_sign = (self.type == other.type)
            return Transreal("+∞") if same_sign else Transreal("-∞")
        # Infinity × Real (or reverse)
        if self.type == TransrealType.REAL:
            return other * self  # Use symmetry
        # self is ±∞, other is real
        r = other.value
        positive_inf = (self.type == TransrealType.POS_INF)
        if r > 0:
            return Transreal("+∞") if positive_inf else Transreal("-∞")
        elif r < 0:
            return Transreal("-∞") if positive_inf else Transreal("+∞")
        else:
            return Transreal("Φ")

    def __neg__(self):
        if self.type == TransrealType.REAL:
            return Transreal(-self.value)
        elif self.type == TransrealType.POS_INF:
            return Transreal("-∞")
        elif self.type == TransrealType.NEG_INF:
            return Transreal("+∞")
        else:
            return Transreal("Φ")

    def defect(self):
        """The defect function: 0 * x. Measures deviation from ring-like behavior."""
        return Transreal(0) * self


# Convenience constructors
R = Transreal
INF = Transreal("+∞")
NEG_INF = Transreal("-∞")
PHI = Transreal("Φ")
ZERO = Transreal(0)
ONE = Transreal(1)


def demo_ring_failure():
    """Demonstrate that the transreals are NOT a ring."""
    print("=" * 60)
    print("DEMO 1: Ring Axiom Failure")
    print("=" * 60)

    print("\n--- No additive inverse for +∞ ---")
    candidates = [INF, NEG_INF, PHI, R(0), R(1), R(-1)]
    for x in candidates:
        result = INF + x
        print(f"  +∞ + {x} = {result}  {'✓ = 0' if result == ZERO else '✗ ≠ 0'}")
    print("  → No x satisfies +∞ + x = 0. Ring axiom FAILS.")

    print("\n--- Distributivity failure ---")
    lhs = INF * (R(2) + R(-1))
    rhs = INF * R(2) + INF * R(-1)
    print(f"  +∞ · (2 + (-1)) = +∞ · 1 = {lhs}")
    print(f"  +∞ · 2 + +∞ · (-1) = +∞ + (-∞) = {rhs}")
    print(f"  {lhs} ≠ {rhs}  → Distributivity FAILS!")


def demo_wheel_structure():
    """Demonstrate the wheel algebraic structure."""
    print("\n" + "=" * 60)
    print("DEMO 2: Wheel Structure Emerges")
    print("=" * 60)

    print("\n--- Modified (wheel) distributivity: a(b+c) + 0·a = ab + ac + 0·a ---")
    test_cases = [
        (INF, R(2), R(-1)),
        (NEG_INF, R(3), R(-5)),
        (PHI, R(1), R(2)),
        (R(3), INF, NEG_INF),
        (R(0), INF, R(1)),
    ]
    for a, b, c in test_cases:
        d = a.defect()
        lhs = a * (b + c) + d
        rhs = a * b + (a * c + d)
        status = "✓" if lhs == rhs else "✗"
        print(f"  a={a}, b={b}, c={c}: LHS={lhs}, RHS={rhs} {status}")


def demo_defect_stratification():
    """Demonstrate the defect function and stratification."""
    print("\n" + "=" * 60)
    print("DEMO 3: Defect Stratification")
    print("=" * 60)

    elements = [R(0), R(1), R(-3.14), INF, NEG_INF, PHI]
    print("\n--- Defect function: 0 · x ---")
    for x in elements:
        d = x.defect()
        level = "Regular (Level 0)" if d == ZERO else "Singular (Level 1)"
        print(f"  defect({x}) = {d}  → {level}")


def demo_idempotent_proliferation():
    """Demonstrate additive idempotent proliferation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Additive Idempotent Proliferation")
    print("=" * 60)

    elements = [R(0), R(1), R(-2), INF, NEG_INF, PHI]
    print("\n--- x + x = x? ---")
    for x in elements:
        result = x + x
        is_idemp = result == x
        print(f"  {x} + {x} = {result}  {'✓ idempotent' if is_idemp else ''}")
    print("  → In a ring, only 0 is idempotent. Here: {0, +∞, -∞, Φ} — FOUR!")


def demo_cancellation_failure():
    """Demonstrate cancellation failure."""
    print("\n" + "=" * 60)
    print("DEMO 5: Cancellation Catastrophe")
    print("=" * 60)

    a, b, c = INF, NEG_INF, PHI
    print(f"\n  {a} + {c} = {a + c}")
    print(f"  {b} + {c} = {b + c}")
    print(f"  Equal results ({a + c} = {b + c}), but {a} ≠ {b}")
    print("  → Additive cancellation FAILS!")

    print("\n  More examples of cancellation failure:")
    pairs = [(R(1), R(2)), (R(0), R(100)), (INF, R(42))]
    for a, b in pairs:
        r1 = a + PHI
        r2 = b + PHI
        print(f"    {a} + Φ = {r1},  {b} + Φ = {r2}  → {a} ≠ {b} but sums equal!")


def demo_nullity_absorption():
    """Demonstrate nullity as unique absorber."""
    print("\n" + "=" * 60)
    print("DEMO 6: Nullity — The Universal Absorber")
    print("=" * 60)

    elements = [R(0), R(42), R(-1), INF, NEG_INF, PHI]
    print("\n--- Φ + x = Φ for all x (additive absorption) ---")
    for x in elements:
        print(f"  Φ + {x} = {PHI + x}")

    print("\n--- Φ · x = Φ for all x (multiplicative absorption) ---")
    for x in elements:
        print(f"  Φ · {x} = {PHI * x}")

    print("\n  Φ is the UNIQUE element with this property:")
    print(f"  +∞ + (-∞) = {INF + NEG_INF} ≠ +∞  → +∞ is NOT an absorber")


if __name__ == "__main__":
    print("TRANSREAL ARITHMETIC: Computing Beyond Plus-Minus Infinity")
    print("Anderson's System: ℝ ∪ {+∞, -∞, Φ} where Φ = 0/0\n")

    demo_ring_failure()
    demo_wheel_structure()
    demo_defect_stratification()
    demo_idempotent_proliferation()
    demo_cancellation_failure()
    demo_nullity_absorption()

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
The transreal numbers extend ℝ with three new elements:
  +∞ (positive infinity), -∞ (negative infinity), Φ (nullity = 0/0)

Key findings (all formally verified in Lean 4):
  1. Ring axioms FAIL: no additive inverse for ∞, distributivity breaks
  2. Wheel structure EMERGES: modified distributivity a(b+c)+0a = ab+ac+0a holds
  3. Defect stratification: elements split into regular (reals) and singular (∞, Φ)
  4. Idempotent proliferation: 4 additive idempotents vs. 1 in any ring
  5. Cancellation catastrophe: a+c = b+c does NOT imply a = b
  6. Nullity is the unique absorbing element for both + and ·
""")


#!/usr/bin/env python3
"""
Visualization: Transreal Arithmetic Multiplication Table

Creates a heatmap showing how transreal multiplication behaves,
with special attention to the sign-dependent infinity cases and
nullity absorption.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def transreal_mul_code(a_type, a_val, b_type, b_val):
    """Return (result_type, result_val) for transreal multiplication."""
    # Nullity absorbs
    if a_type == 'Φ' or b_type == 'Φ':
        return ('Φ', 0)
    # Both real
    if a_type == 'R' and b_type == 'R':
        return ('R', a_val * b_val)
    # Both infinity
    if a_type in ('+∞', '-∞') and b_type in ('+∞', '-∞'):
        same = (a_type == b_type)
        return ('+∞' if same else '-∞', 0)
    # Infinity × Real
    if a_type == 'R':
        return transreal_mul_code(b_type, b_val, a_type, a_val)
    # a is ±∞, b is real
    r = b_val
    pos = (a_type == '+∞')
    if r > 0:
        return ('+∞' if pos else '-∞', 0)
    elif r < 0:
        return ('-∞' if pos else '+∞', 0)
    else:
        return ('Φ', 0)


def encode_result(rtype, rval):
    """Encode result as a number for heatmap. Special elements get special codes."""
    if rtype == 'Φ':
        return 0  # nullity
    elif rtype == '+∞':
        return 3  # positive infinity
    elif rtype == '-∞':
        return -3  # negative infinity
    elif rtype == 'R':
        return max(-2.5, min(2.5, rval))  # clamp reals
    return 0


def main():
    # Elements to display
    labels = ['-∞', '-2', '-1', '0', '1', '2', '+∞', 'Φ']
    types =  ['-∞', 'R',  'R',  'R', 'R', 'R', '+∞', 'Φ']
    vals =   [0,    -2,   -1,   0,   1,   2,   0,    0]

    n = len(labels)
    mul_table = np.zeros((n, n))
    result_labels = [['' for _ in range(n)] for _ in range(n)]

    for i in range(n):
        for j in range(n):
            rt, rv = transreal_mul_code(types[i], vals[i], types[j], vals[j])
            mul_table[i, j] = encode_result(rt, rv)
            if rt == 'R':
                result_labels[i][j] = f'{rv:.0f}' if rv == int(rv) else f'{rv:.1f}'
            else:
                result_labels[i][j] = rt

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    cmap = plt.cm.RdBu_r
    im = ax.imshow(mul_table, cmap=cmap, vmin=-3.5, vmax=3.5, aspect='equal')

    # Add text annotations
    for i in range(n):
        for j in range(n):
            text = result_labels[i][j]
            color = 'white' if abs(mul_table[i, j]) > 2 else 'black'
            if text == 'Φ':
                color = 'gold'
            ax.text(j, i, text, ha='center', va='center', fontsize=11,
                    fontweight='bold' if text in ('+∞', '-∞', 'Φ') else 'normal',
                    color=color)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, fontsize=12)
    ax.set_yticklabels(labels, fontsize=12)
    ax.set_xlabel('b', fontsize=14)
    ax.set_ylabel('a', fontsize=14)
    ax.set_title('Transreal Multiplication Table: a × b\n'
                 '(Φ = nullity = 0/0, the wheel element)', fontsize=14)

    # Highlight the critical 0·∞ = Φ cases
    for i in range(n):
        for j in range(n):
            if result_labels[i][j] == 'Φ' and not (types[i] == 'Φ' and types[j] == 'Φ'):
                rect = mpatches.FancyBboxPatch((j - 0.45, i - 0.45), 0.9, 0.9,
                    boxstyle="round,pad=0.05", linewidth=2, edgecolor='gold',
                    facecolor='none')
                ax.add_patch(rect)

    plt.colorbar(im, ax=ax, label='Value encoding', shrink=0.8)
    plt.tight_layout()
    plt.savefig('transreal_multiplication_table.png', dpi=150, bbox_inches='tight')
    print("Saved: transreal_multiplication_table.png")


if __name__ == '__main__':
    main()
