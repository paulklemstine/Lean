#!/usr/bin/env python3
"""
Transreal Arithmetic — Interactive Demo

Demonstrates the key theorems about transreal arithmetic:
1. Nullity absorption
2. Absorber uniqueness
3. Distributivity failure
4. Additive idempotent classification
5. Absorbing extension construction
"""

from algorithms import (
    Transreal, transreal_add, transreal_mul, transreal_div, transreal_neg,
    absorbing_extension, check_absorber_uniqueness, check_idempotents,
    verify_commutativity, verify_associativity, verify_distributivity
)
from typing import Optional


def banner(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_basic_arithmetic() -> None:
    banner("1. BASIC TRANSREAL ARITHMETIC")

    zero = Transreal.of_real(0)
    one = Transreal.of_real(1)
    two = Transreal.of_real(2)
    neg1 = Transreal.of_real(-1)
    pinf = Transreal.pos_inf()
    ninf = Transreal.neg_inf()
    phi = Transreal.nullity()

    print("Division by zero is now defined:")
    print(f"  1 / 0 = {transreal_div(one, zero)}")
    print(f"  -1 / 0 = {transreal_div(neg1, zero)}")
    print(f"  0 / 0 = {transreal_div(zero, zero)}")

    print("\nInfinity arithmetic:")
    print(f"  ∞ + ∞ = {transreal_add(pinf, pinf)}")
    print(f"  ∞ + (-∞) = {transreal_add(pinf, ninf)}")
    print(f"  ∞ × ∞ = {transreal_mul(pinf, pinf)}")
    print(f"  ∞ × (-∞) = {transreal_mul(pinf, ninf)}")
    print(f"  ∞ × 0 = {transreal_mul(pinf, zero)}")

    print("\nNullity propagation:")
    print(f"  Φ + 42 = {transreal_add(phi, Transreal.of_real(42))}")
    print(f"  Φ × 42 = {transreal_mul(phi, Transreal.of_real(42))}")
    print(f"  Φ + ∞ = {transreal_add(phi, pinf)}")
    print(f"  Φ × ∞ = {transreal_mul(phi, pinf)}")


def demo_absorber_uniqueness() -> None:
    banner("2. ABSORBER UNIQUENESS THEOREM")

    zero = Transreal.of_real(0)
    one = Transreal.of_real(1)
    neg1 = Transreal.of_real(-1)
    half = Transreal.of_real(0.5)
    pinf = Transreal.pos_inf()
    ninf = Transreal.neg_inf()
    phi = Transreal.nullity()

    candidates = [zero, one, neg1, half, pinf, ninf, phi]
    labels = ["0", "1", "-1", "0.5", "+∞", "-∞", "Φ"]

    print("Testing which elements absorb under addition (x + y = x for all y):")
    for x, label in zip(candidates, labels):
        absorbs = all(transreal_add(x, y) == x for y in candidates)
        if absorbs:
            print(f"  {label}: ✓ ABSORBS")
        else:
            # Find counterexample
            for y, ylabel in zip(candidates, labels):
                if transreal_add(x, y) != x:
                    print(f"  {label}: ✗ fails at {label} + {ylabel} = {transreal_add(x, y)} ≠ {x}")
                    break

    print("\nTesting which elements absorb under multiplication (x × y = x for all y):")
    for x, label in zip(candidates, labels):
        absorbs = all(transreal_mul(x, y) == x for y in candidates)
        if absorbs:
            print(f"  {label}: ✓ ABSORBS")
        else:
            for y, ylabel in zip(candidates, labels):
                if transreal_mul(x, y) != x:
                    print(f"  {label}: ✗ fails at {label} × {ylabel} = {transreal_mul(x, y)} ≠ {x}")
                    break

    print("\n→ THEOREM: Φ is the UNIQUE double absorber.")


def demo_distributivity_failure() -> None:
    banner("3. DISTRIBUTIVITY FAILURE")

    one = Transreal.of_real(1)
    pinf = Transreal.pos_inf()
    ninf = Transreal.neg_inf()

    a, b, c = pinf, one, ninf
    lhs = transreal_mul(a, transreal_add(b, c))
    rhs = transreal_add(transreal_mul(a, b), transreal_mul(a, c))

    print(f"Take a = +∞, b = 1, c = -∞:")
    print(f"  b + c = 1 + (-∞) = {transreal_add(b, c)}")
    print(f"  a × (b + c) = +∞ × (-∞) = {lhs}")
    print(f"  a × b = +∞ × 1 = {transreal_mul(a, b)}")
    print(f"  a × c = +∞ × (-∞) = {transreal_mul(a, c)}")
    print(f"  a × b + a × c = +∞ + (-∞) = {rhs}")
    print(f"\n  {lhs} ≠ {rhs}")
    print("\n→ THEOREM: Distributivity FAILS in transreal arithmetic.")


def demo_idempotent_classification() -> None:
    banner("4. ADDITIVE IDEMPOTENT CLASSIFICATION")

    import random
    test_reals = [Transreal.of_real(r) for r in
                  [0, 1, -1, 0.5, -0.5, 2, -2, 3.14, -100, 42]]
    specials = [Transreal.pos_inf(), Transreal.neg_inf(), Transreal.nullity()]
    all_elements = test_reals + specials

    print("Testing x + x = x for various elements:")
    idempotents = []
    for x in all_elements:
        result = transreal_add(x, x)
        is_idem = (result == x)
        symbol = "✓" if is_idem else "✗"
        if is_idem:
            idempotents.append(x)
        print(f"  {symbol} {x} + {x} = {result}")

    print(f"\nIdempotent elements: {[str(x) for x in idempotents]}")
    print("\n→ THEOREM: Exactly {0, +∞, -∞, Φ} are additively idempotent.")


def demo_absorbing_extension() -> None:
    banner("5. ABSORBING EXTENSION CONSTRUCTION")

    # Example: extend integer addition (always defined) with an absorber
    def int_add(a: int, b: int) -> Optional[int]:
        return a + b

    ext_add = absorbing_extension(int_add)

    print("Integer addition extended with absorber (None = Φ):")
    print(f"  3 + 5 = {ext_add(3, 5)}")
    print(f"  Φ + 5 = {ext_add(None, 5)}")
    print(f"  3 + Φ = {ext_add(3, None)}")
    print(f"  Φ + Φ = {ext_add(None, None)}")

    # Example: partial operation (division, undefined at 0)
    def safe_div(a: int, b: int) -> Optional[float]:
        if b == 0:
            return None  # undefined
        return a / b

    ext_div = absorbing_extension(safe_div)

    print("\nInteger division extended with absorber:")
    print(f"  6 / 3 = {ext_div(6, 3)}")
    print(f"  6 / 0 = {ext_div(6, 0)} (was undefined → absorber)")
    print(f"  0 / 0 = {ext_div(0, 0)} (was undefined → absorber)")
    print(f"  Φ / 3 = {ext_div(None, 3)}")

    print("\n→ THEOREM: The absorber (None) is the unique absorbing element")
    print("   in any absorbing extension of a non-trivial partial magma.")


def demo_verification() -> None:
    banner("6. ALGEBRAIC PROPERTY VERIFICATION")

    specials = [
        Transreal.of_real(0), Transreal.of_real(1), Transreal.of_real(-1),
        Transreal.pos_inf(), Transreal.neg_inf(), Transreal.nullity()
    ]

    comm_add, _ = verify_commutativity(transreal_add, specials)
    comm_mul, _ = verify_commutativity(transreal_mul, specials)
    assoc_add, counter = verify_associativity(transreal_add, specials)
    dist, counter_dist = verify_distributivity(transreal_add, transreal_mul, specials)

    print(f"Addition commutativity:    {'✓' if comm_add else '✗'}")
    print(f"Multiplication commutativity: {'✓' if comm_mul else '✗'}")
    print(f"Addition associativity:    {'✓' if assoc_add else '✗'}")
    if not assoc_add and counter:
        print(f"  Counterexample: ({counter[0]}, {counter[1]}, {counter[2]})")
    print(f"Distributivity:            {'✓' if dist else '✗'}")
    if not dist and counter_dist:
        a, b, c = counter_dist
        print(f"  Counterexample: ({a}, {b}, {c})")
        lhs = transreal_mul(a, transreal_add(b, c))
        rhs = transreal_add(transreal_mul(a, b), transreal_mul(a, c))
        print(f"  LHS = {lhs}, RHS = {rhs}")


if __name__ == "__main__":
    demo_basic_arithmetic()
    demo_absorber_uniqueness()
    demo_distributivity_failure()
    demo_idempotent_classification()
    demo_absorbing_extension()
    demo_verification()

    print(f"\n{'='*60}")
    print("  All demonstrations complete.")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
Visualization: Transreal Arithmetic Operation Tables

Generates heatmap-style tables showing the behavior of transreal
addition and multiplication, highlighting the absorber (Φ) and
the idempotent elements.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def make_transreal_table():
    """Generate and visualize the transreal addition and multiplication tables."""

    labels = ['−2', '−1', '0', '1', '2', '−∞', '+∞', 'Φ']
    n = len(labels)

    # Encode elements as (kind, value)
    # kind: 0=real, 1=+inf, 2=-inf, 3=nullity
    elements = [
        (0, -2), (0, -1), (0, 0), (0, 1), (0, 2),
        (2, 0), (1, 0), (3, 0)
    ]

    def real_sign(r):
        if r > 0: return (1, 0)
        elif r < 0: return (2, 0)
        else: return (3, 0)

    def neg_inf(t):
        if t[0] == 1: return (2, 0)
        elif t[0] == 2: return (1, 0)
        return t

    def add(a, b):
        if a[0] == 3 or b[0] == 3: return (3, 0)
        if a[0] == 1 and b[0] == 2: return (3, 0)
        if a[0] == 2 and b[0] == 1: return (3, 0)
        if a[0] == 1: return (1, 0)
        if b[0] == 1: return (1, 0)
        if a[0] == 2: return (2, 0)
        if b[0] == 2: return (2, 0)
        return (0, a[1] + b[1])

    def mul(a, b):
        if a[0] == 3 or b[0] == 3: return (3, 0)
        if a[0] == 1 and b[0] == 1: return (1, 0)
        if a[0] == 1 and b[0] == 2: return (2, 0)
        if a[0] == 2 and b[0] == 1: return (2, 0)
        if a[0] == 2 and b[0] == 2: return (1, 0)
        if a[0] == 1: return real_sign(b[1])
        if b[0] == 1: return real_sign(a[1])
        if a[0] == 2: return neg_inf(real_sign(b[1]))
        if b[0] == 2: return neg_inf(real_sign(a[1]))
        return (0, a[1] * b[1])

    def result_to_str(r):
        if r[0] == 3: return 'Φ'
        if r[0] == 1: return '+∞'
        if r[0] == 2: return '−∞'
        v = r[1]
        if v == int(v): return str(int(v))
        return str(v)

    def result_to_color(r):
        if r[0] == 3: return 3  # nullity = red
        if r[0] == 1: return 1  # +inf = blue
        if r[0] == 2: return 2  # -inf = orange
        if r[1] == 0: return 0  # zero = green
        return -1  # other real = white

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    for idx, (op, title) in enumerate([(add, 'Transreal Addition (a + b)'),
                                        (mul, 'Transreal Multiplication (a × b)')]):
        ax = axes[idx]

        # Compute table
        table_str = [['' for _ in range(n)] for _ in range(n)]
        table_color = np.zeros((n, n))

        for i in range(n):
            for j in range(n):
                r = op(elements[i], elements[j])
                table_str[i][j] = result_to_str(r)
                table_color[i][j] = result_to_color(r)

        # Color map: -1=white, 0=lightgreen, 1=lightblue, 2=lightsalmon, 3=lightcoral
        cmap = mcolors.ListedColormap(['white', '#c8e6c9', '#bbdefb', '#ffcc80', '#ef9a9a'])
        bounds = [-1.5, -0.5, 0.5, 1.5, 2.5, 3.5]
        norm = mcolors.BoundaryNorm(bounds, cmap.N)

        ax.imshow(table_color, cmap=cmap, norm=norm, aspect='equal')

        for i in range(n):
            for j in range(n):
                ax.text(j, i, table_str[i][j], ha='center', va='center',
                       fontsize=9, fontweight='bold' if table_color[i][j] == 3 else 'normal')

        ax.set_xticks(range(n))
        ax.set_yticks(range(n))
        ax.set_xticklabels(labels, fontsize=10)
        ax.set_yticklabels(labels, fontsize=10)
        ax.set_xlabel('b', fontsize=12)
        ax.set_ylabel('a', fontsize=12)
        ax.set_title(title, fontsize=13, fontweight='bold')

        # Grid
        for i in range(n + 1):
            ax.axhline(i - 0.5, color='gray', linewidth=0.5)
            ax.axvline(i - 0.5, color='gray', linewidth=0.5)

    # Legend
    legend_elements = [
        plt.Rectangle((0, 0), 1, 1, fc='#c8e6c9', ec='gray', label='Zero'),
        plt.Rectangle((0, 0), 1, 1, fc='#bbdefb', ec='gray', label='+∞'),
        plt.Rectangle((0, 0), 1, 1, fc='#ffcc80', ec='gray', label='−∞'),
        plt.Rectangle((0, 0), 1, 1, fc='#ef9a9a', ec='gray', label='Φ (Nullity)'),
        plt.Rectangle((0, 0), 1, 1, fc='white', ec='gray', label='Real'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=5,
              fontsize=10, frameon=True, fancybox=True)

    plt.suptitle('Transreal Arithmetic: Operation Tables', fontsize=15, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0.06, 1, 0.95])
    plt.savefig('transreal_tables.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved transreal_tables.png")


if __name__ == '__main__':
    make_transreal_table()
