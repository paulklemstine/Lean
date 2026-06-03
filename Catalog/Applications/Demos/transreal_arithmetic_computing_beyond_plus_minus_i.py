#!/usr/bin/env python3
"""
Transreal Arithmetic Demo
========================
Numerical demonstration of transreal number operations.
Shows how the four elements {reals, +∞, -∞, Φ} interact.
"""

from enum import Enum
from typing import Union

class TransrealType(Enum):
    REAL = "real"
    POS_INF = "+∞"
    NEG_INF = "-∞"
    NULLITY = "Φ"

class Transreal:
    """A transreal number: either a real, +∞, -∞, or Φ (nullity)."""

    def __init__(self, value=None, kind=TransrealType.REAL):
        if kind == TransrealType.REAL:
            self.value = float(value) if value is not None else 0.0
            self.kind = TransrealType.REAL
        else:
            self.value = None
            self.kind = kind

    @staticmethod
    def pos_inf():
        return Transreal(kind=TransrealType.POS_INF)

    @staticmethod
    def neg_inf():
        return Transreal(kind=TransrealType.NEG_INF)

    @staticmethod
    def nullity():
        return Transreal(kind=TransrealType.NULLITY)

    def __repr__(self):
        if self.kind == TransrealType.REAL:
            return f"T({self.value})"
        return self.kind.value

    def _sign(self):
        if self.kind != TransrealType.REAL:
            return None
        if self.value > 0: return 1
        if self.value < 0: return -1
        return 0

    def __add__(self, other):
        if self.kind == TransrealType.NULLITY or other.kind == TransrealType.NULLITY:
            return Transreal.nullity()
        if self.kind == TransrealType.REAL and other.kind == TransrealType.REAL:
            return Transreal(self.value + other.value)
        if self.kind == TransrealType.POS_INF:
            if other.kind == TransrealType.POS_INF: return Transreal.pos_inf()
            if other.kind == TransrealType.NEG_INF: return Transreal.nullity()
            return Transreal.pos_inf()
        if self.kind == TransrealType.NEG_INF:
            if other.kind == TransrealType.NEG_INF: return Transreal.neg_inf()
            if other.kind == TransrealType.POS_INF: return Transreal.nullity()
            return Transreal.neg_inf()
        if other.kind == TransrealType.POS_INF: return Transreal.pos_inf()
        if other.kind == TransrealType.NEG_INF: return Transreal.neg_inf()
        return Transreal.nullity()

    def __neg__(self):
        if self.kind == TransrealType.REAL: return Transreal(-self.value)
        if self.kind == TransrealType.POS_INF: return Transreal.neg_inf()
        if self.kind == TransrealType.NEG_INF: return Transreal.pos_inf()
        return Transreal.nullity()

    def __mul__(self, other):
        if self.kind == TransrealType.NULLITY or other.kind == TransrealType.NULLITY:
            return Transreal.nullity()
        if self.kind == TransrealType.REAL and other.kind == TransrealType.REAL:
            return Transreal(self.value * other.value)

        # Handle infinity × real
        def inf_times_sign(inf_pos, sign):
            if sign == 0: return Transreal.nullity()
            if (sign > 0) == inf_pos: return Transreal.pos_inf()
            return Transreal.neg_inf()

        if self.kind == TransrealType.POS_INF and other.kind == TransrealType.REAL:
            return inf_times_sign(True, other._sign())
        if self.kind == TransrealType.NEG_INF and other.kind == TransrealType.REAL:
            return inf_times_sign(False, other._sign())
        if other.kind == TransrealType.POS_INF and self.kind == TransrealType.REAL:
            return inf_times_sign(True, self._sign())
        if other.kind == TransrealType.NEG_INF and self.kind == TransrealType.REAL:
            return inf_times_sign(False, self._sign())

        # infinity × infinity
        if self.kind == other.kind: return Transreal.pos_inf()
        return Transreal.neg_inf()

    def inv(self):
        if self.kind == TransrealType.NULLITY: return Transreal.nullity()
        if self.kind in (TransrealType.POS_INF, TransrealType.NEG_INF):
            return Transreal(0.0)
        if self.value == 0: return Transreal.pos_inf()
        return Transreal(1.0 / self.value)

    def __truediv__(self, other):
        return self * other.inv()

    def __eq__(self, other):
        if not isinstance(other, Transreal): return False
        if self.kind != other.kind: return False
        if self.kind == TransrealType.REAL: return self.value == other.value
        return True


def main():
    # Aliases
    T = Transreal
    pinf = T.pos_inf()
    ninf = T.neg_inf()
    phi = T.nullity()
    zero = T(0)
    one = T(1)
    two = T(2)
    neg_one = T(-1)

    print("=" * 60)
    print("TRANSREAL ARITHMETIC DEMONSTRATION")
    print("=" * 60)

    print("\n--- Nullity Absorption ---")
    print(f"Φ + 5      = {phi + T(5)}")
    print(f"Φ + (+∞)   = {phi + pinf}")
    print(f"Φ × 3      = {phi * T(3)}")
    print(f"Φ × Φ      = {phi * phi}")

    print("\n--- Ring Axiom Failures ---")
    print(f"+∞ + (-∞)  = {pinf + ninf}  (not 0!)")
    print(f"0 × (+∞)   = {zero * pinf}  (not 0!)")
    print(f"Φ + (-Φ)   = {phi + (-phi)}  (not 0!)")

    print("\n--- Additive Cancellation Failure ---")
    print(f"1 + (+∞)   = {one + pinf}")
    print(f"+∞ + (+∞)  = {pinf + pinf}")
    print(f"Both equal +∞, but 1 ≠ +∞")

    print("\n--- Distributivity Failure ---")
    lhs = pinf * (zero + one)
    rhs = pinf * zero + pinf * one
    print(f"+∞ × (0 + 1) = {lhs}")
    print(f"+∞×0 + +∞×1  = {rhs}")
    print(f"LHS ≠ RHS: {lhs} ≠ {rhs}")

    print("\n--- Division by Zero ---")
    print(f"1 / 0  = {one / zero}")
    print(f"-3 / 0 = {T(-3) / zero}")
    print(f"0 / 0  = {zero / zero}  (defining equation of nullity)")

    print("\n--- Idempotent Elements ---")
    for x, name in [(zero, "0"), (pinf, "+∞"), (ninf, "-∞"), (phi, "Φ"),
                     (one, "1"), (two, "2")]:
        result = x + x
        is_idemp = result == x
        print(f"{name} + {name} = {result}  idempotent: {is_idemp}")

    print("\n--- Negation Fixed Points ---")
    for x, name in [(zero, "0"), (phi, "Φ"), (pinf, "+∞"), (one, "1")]:
        neg_x = -x
        is_fixed = neg_x == x
        print(f"-({name}) = {neg_x}  fixed point: {is_fixed}")

    print("\n--- Wheel Identity x + 0·x = x ---")
    for x, name in [(T(3), "3"), (pinf, "+∞"), (ninf, "-∞"), (phi, "Φ")]:
        result = x + (zero * x)
        holds = result == x
        print(f"{name} + 0·{name} = {result}  holds: {holds}")

    print("\n--- Multiplication Table (special elements) ---")
    elements = [(zero, "0"), (one, "1"), (neg_one, "-1"),
                (pinf, "+∞"), (ninf, "-∞"), (phi, "Φ")]
    header = "×".ljust(6) + "".join(n.rjust(6) for _, n in elements)
    print(header)
    print("-" * len(header))
    for a, aname in elements:
        row = aname.ljust(6) + "".join(str(a * b).rjust(6) for b, _ in elements)
        print(row)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Transreal Arithmetic Visualization
===================================
Generates a heatmap of the transreal multiplication table,
highlighting where ring axioms fail (0×∞ = Φ, etc.)
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Encoding: 0=real_zero, 1=real_pos, 2=real_neg, 3=posInf, 4=negInf, 5=nullity
NAMES = ['0', '1', '-1', '2', '-2', '+∞', '-∞', 'Φ']

def sign(x):
    if x > 0: return 'pos'
    if x < 0: return 'neg'
    return 'zero'

def transreal_mul(a, b):
    """Returns (result_label, result_code) for the multiplication table."""
    reals = {'0': 0, '1': 1, '-1': -1, '2': 2, '-2': -2}

    if a == 'Φ' or b == 'Φ':
        return 'Φ', 3

    if a in reals and b in reals:
        r = reals[a] * reals[b]
        return str(r), 0 if r == 0 else (1 if r > 0 else 2)

    def inf_real(inf_pos, r):
        s = sign(r)
        if s == 'zero': return 'Φ', 3
        if (s == 'pos') == inf_pos: return '+∞', 4
        return '-∞', 5

    if a == '+∞' and b in reals: return inf_real(True, reals[b])
    if a == '-∞' and b in reals: return inf_real(False, reals[b])
    if b == '+∞' and a in reals: return inf_real(True, reals[a])
    if b == '-∞' and a in reals: return inf_real(False, reals[a])

    # Both infinite
    if a == b or (a in ('+∞','-∞') and b in ('+∞','-∞') and a == b):
        return '+∞', 4
    if (a == '+∞' and b == '-∞') or (a == '-∞' and b == '+∞'):
        return '-∞', 5
    if a == '+∞' and b == '+∞': return '+∞', 4
    if a == '-∞' and b == '-∞': return '+∞', 4
    return '-∞', 5


def main():
    n = len(NAMES)
    grid = np.zeros((n, n), dtype=int)
    labels = [['' for _ in range(n)] for _ in range(n)]

    # Color coding: 0=real_zero(white), 1=real_pos(blue), 2=real_neg(red),
    # 3=nullity(yellow), 4=posInf(green), 5=negInf(orange)
    for i, a in enumerate(NAMES):
        for j, b in enumerate(NAMES):
            lbl, code = transreal_mul(a, b)
            grid[i][j] = code
            labels[i][j] = lbl

    # Custom colormap
    from matplotlib.colors import ListedColormap
    colors = ['#ffffff', '#a8d5f2', '#f2a8a8', '#f2e8a8', '#a8f2c0', '#f2c8a8']
    cmap = ListedColormap(colors)

    fig, ax = plt.subplots(figsize=(10, 8))
    ax.imshow(grid, cmap=cmap, vmin=0, vmax=5)

    for i in range(n):
        for j in range(n):
            color = 'red' if labels[i][j] == 'Φ' and (
                NAMES[i] in ('0','1','-1','2','-2') or NAMES[j] in ('0','1','-1','2','-2')
            ) else 'black'
            weight = 'bold' if labels[i][j] == 'Φ' else 'normal'
            ax.text(j, i, labels[i][j], ha='center', va='center',
                    fontsize=12, color=color, fontweight=weight)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(NAMES, fontsize=12)
    ax.set_yticklabels(NAMES, fontsize=12)
    ax.set_xlabel('b', fontsize=14)
    ax.set_ylabel('a', fontsize=14)
    ax.set_title('Transreal Multiplication Table  a × b\n'
                 '(Φ entries in red show ring axiom violations)',
                 fontsize=14, pad=15)

    # Legend
    legend_items = [
        ('Real zero', '#ffffff'),
        ('Real positive', '#a8d5f2'),
        ('Real negative', '#f2a8a8'),
        ('Nullity (Φ)', '#f2e8a8'),
        ('+∞', '#a8f2c0'),
        ('-∞', '#f2c8a8'),
    ]
    for idx, (label, color) in enumerate(legend_items):
        ax.plot([], [], 's', color=color, markersize=12, label=label)
    ax.legend(loc='upper left', bbox_to_anchor=(1.02, 1), fontsize=10)

    plt.tight_layout()
    plt.savefig('transreal_multiplication.png', dpi=150, bbox_inches='tight')
    print("Saved transreal_multiplication.png")


if __name__ == '__main__':
    main()
