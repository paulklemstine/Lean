"""
Demo: Causal Loops in Category Theory

Demonstrates the key mathematical results:
1. Associator defect computation
2. Pentagon obstruction
3. Twisted composition
4. Defect accumulation
5. Causal loop rotation invariance
"""

from algorithms import (
    assoc_defect, sub_defect, twisted_comp, twisted_defect,
    pentagon_check, iter_sub_left, iter_sub_right, catalan,
    is_loop, rotate, defect_scan, pentagon_scan, find_causal_operations
)


def demo_associator_defect():
    """Demonstrate that subtraction's defect is exactly -2c."""
    print("=" * 60)
    print("DEMO 1: Associator Defect for Subtraction")
    print("=" * 60)
    print()
    print("Theorem: AssocDefect(sub, a, b, c) = -2c")
    print("Verification across random values:")
    print()

    import random
    random.seed(42)
    all_match = True
    for _ in range(20):
        a, b, c = random.randint(-100, 100), random.randint(-100, 100), random.randint(-100, 100)
        d = sub_defect(a, b, c)
        expected = -2 * c
        match = "✓" if d == expected else "✗"
        if d != expected:
            all_match = False
        print(f"  a={a:4d}, b={b:4d}, c={c:4d}  →  defect={d:6d}  expected={expected:6d}  {match}")

    print(f"\nAll match: {all_match}")
    print()


def demo_causal_dependence():
    """Show that the defect depends ONLY on c."""
    print("=" * 60)
    print("DEMO 2: Causal Dependence — Defect Depends Only on c")
    print("=" * 60)
    print()

    c = 7
    defects = set()
    for a in range(-5, 6):
        for b in range(-5, 6):
            defects.add(sub_defect(a, b, c))

    print(f"For c = {c}, defect values across all a,b in [-5,5]: {defects}")
    print(f"Unique value: {defects.pop()} (expected: {-2*c})")
    print()


def demo_pentagon():
    """Demonstrate the pentagon obstruction."""
    print("=" * 60)
    print("DEMO 3: Pentagon Obstruction for Subtraction")
    print("=" * 60)
    print()
    print("Pentagon defect = LHS - RHS of pentagon identity")
    print("Theorem: pentagon_defect(a,b,c,d) = -4d")
    print()

    sub = lambda a, b: a - b
    for d in range(-5, 6):
        p = pentagon_check(sub, 3, 7, -2, d)
        expected = -4 * d
        match = "✓" if p == expected else "✗"
        print(f"  d={d:3d}  →  pentagon_defect={p:6d}  expected={expected:6d}  {match}")
    print()


def demo_twisted_composition():
    """Show the twisted composition and its properties."""
    print("=" * 60)
    print("DEMO 4: Twisted Composition on ℤ × ℤ")
    print("=" * 60)
    print()

    # Right identity
    p = (3, 5)
    print(f"Right identity: TwistedComp({p}, (0,0)) = {twisted_comp(p, (0, 0))}")

    # NOT left identity
    print(f"Not left identity: TwistedComp((0,0), {p}) = {twisted_comp((0, 0), p)} ≠ {p}")

    # Non-associativity
    q, r = (1, 2), (4, 3)
    lhs = twisted_comp(twisted_comp(p, q), r)
    rhs = twisted_comp(p, twisted_comp(q, r))
    print(f"\n(p∘q)∘r = {lhs}")
    print(f"p∘(q∘r) = {rhs}")
    print(f"Defect  = {(lhs[0]-rhs[0], lhs[1]-rhs[1])}")
    print(f"Expected defect = (0, {-2*r[1]})")
    print()


def demo_accumulation():
    """Show how non-associativity accumulates."""
    print("=" * 60)
    print("DEMO 5: Defect Accumulation in Iterated Subtraction")
    print("=" * 60)
    print()

    for n in range(2, 8):
        lst = list(range(1, n + 1))
        left = iter_sub_left(lst)
        right = iter_sub_right(lst)
        diff = left - right
        print(f"  {lst}: left={left:6d}, right={right:6d}, defect={diff:6d}")
    print()


def demo_catalan():
    """Show Catalan numbers as coherence dimensions."""
    print("=" * 60)
    print("DEMO 6: Coherence Dimensions (Catalan Numbers)")
    print("=" * 60)
    print()
    print("  n | C(n) | # parenthesizations of n+1 elements")
    print("  --+------+--------------------------------------")
    for n in range(12):
        c = catalan(n)
        print(f"  {n:2d} | {c:6d} | {'*' * min(c, 50)}")
    print()


def demo_loop_rotation():
    """Demonstrate loop rotation invariance."""
    print("=" * 60)
    print("DEMO 7: Loop Rotation Invariance")
    print("=" * 60)
    print()

    loop = [3, -1, 2, -4]  # sums to 0
    print(f"Original loop: {loop}, sum = {sum(loop)}")
    for k in range(len(loop)):
        rotated = rotate(loop, k)
        print(f"  Rotation by {k}: {rotated}, sum = {sum(rotated)}, is_loop = {is_loop(rotated)}")
    print()

    # Non-loop
    non_loop = [3, -1, 2, -3]
    print(f"Non-loop: {non_loop}, sum = {sum(non_loop)}")
    for k in range(len(non_loop)):
        rotated = rotate(non_loop, k)
        print(f"  Rotation by {k}: {rotated}, sum = {sum(rotated)}, is_loop = {is_loop(rotated)}")
    print()


def demo_causal_ops():
    """Find causal operations modulo small numbers."""
    print("=" * 60)
    print("DEMO 8: Causal Operations (mod n)")
    print("=" * 60)
    print()
    for n in [3, 5, 7]:
        causal = find_causal_operations(n)
        print(f"  mod {n}: {len(causal)} causal linear ops (α,β): {causal}")
    print()


if __name__ == "__main__":
    demo_associator_defect()
    demo_causal_dependence()
    demo_pentagon()
    demo_twisted_composition()
    demo_accumulation()
    demo_catalan()
    demo_loop_rotation()
    demo_causal_ops()


"""
Visualization: Defect Accumulation and Catalan Growth

Shows how non-associativity accumulates with sequence length,
and the super-exponential growth of coherence dimensions.
"""

import matplotlib.pyplot as plt
import numpy as np
from functools import reduce


def iter_sub_left(lst):
    if not lst:
        return 0
    return reduce(lambda a, b: a - b, lst)


def iter_sub_right(lst):
    if not lst:
        return 0
    if len(lst) == 1:
        return lst[0]
    return lst[0] - iter_sub_right(lst[1:])


def catalan(n):
    if n <= 0:
        return 1
    c = 1
    for i in range(n):
        c = c * 2 * (2 * i + 1) // (i + 2)
    return c


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Defect accumulation for constant sequences
    ns = list(range(2, 15))
    for val in [1, 2, 3, 5]:
        defects = []
        for n in ns:
            lst = [10] + [val] * (n - 1)
            d = abs(iter_sub_left(lst) - iter_sub_right(lst))
            defects.append(d)
        axes[0].plot(ns, defects, 'o-', label=f'val={val}')

    axes[0].set_xlabel('Sequence length n')
    axes[0].set_ylabel('|Left - Right| association defect')
    axes[0].set_title('Defect Accumulation vs Sequence Length')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    axes[0].set_yscale('log')

    # Plot 2: Catalan numbers vs exponentials
    ns2 = list(range(0, 15))
    catalans = [catalan(n) for n in ns2]
    twos = [2**n for n in ns2]
    threes = [3**n for n in ns2]

    axes[1].semilogy(ns2, catalans, 'bo-', linewidth=2, label='Catalan C(n)')
    axes[1].semilogy(ns2, twos, 'r--', label='2^n')
    axes[1].semilogy(ns2, threes, 'g--', label='3^n')
    axes[1].set_xlabel('n')
    axes[1].set_ylabel('Value (log scale)')
    axes[1].set_title('Catalan Numbers: Super-exponential Growth')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Left vs Right association for [1, 2, ..., n]
    ns3 = list(range(2, 12))
    lefts = [iter_sub_left(list(range(1, n+1))) for n in ns3]
    rights = [iter_sub_right(list(range(1, n+1))) for n in ns3]

    axes[2].plot(ns3, lefts, 'bs-', label='Left-associated')
    axes[2].plot(ns3, rights, 'r^-', label='Right-associated')
    axes[2].fill_between(ns3,
                         [min(l, r) for l, r in zip(lefts, rights)],
                         [max(l, r) for l, r in zip(lefts, rights)],
                         alpha=0.2, color='purple', label='Defect gap')
    axes[2].set_xlabel('n')
    axes[2].set_ylabel('Result of [1,2,...,n] subtraction')
    axes[2].set_title('Left vs Right Association: [1, 2, ..., n]')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('accumulation_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved accumulation_visualization.png")


if __name__ == "__main__":
    main()


"""
Visualization: Associator Defect Heatmap

Shows the associator defect for subtraction as a function of (a, c),
demonstrating that the defect depends only on c (horizontal bands).
"""

import matplotlib.pyplot as plt
import numpy as np


def assoc_defect_sub(a: int, b: int, c: int) -> int:
    return (a - b) - c - (a - (b - c))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Defect as function of (a, c) with fixed b
    b = 0
    a_range = np.arange(-20, 21)
    c_range = np.arange(-20, 21)
    A, C = np.meshgrid(a_range, c_range)
    D = np.vectorize(lambda a, c: assoc_defect_sub(a, b, c))(A, C)

    im1 = axes[0].imshow(D, extent=[-20, 20, -20, 20], aspect='auto',
                          cmap='RdBu_r', origin='lower')
    axes[0].set_xlabel('a')
    axes[0].set_ylabel('c')
    axes[0].set_title(f'AssocDefect(sub, a, {b}, c)\n= -2c (horizontal bands)')
    plt.colorbar(im1, ax=axes[0], label='Defect')

    # Plot 2: Defect vs c for different a values
    c_vals = np.arange(-20, 21)
    for a in [-10, -5, 0, 5, 10]:
        defects = [assoc_defect_sub(a, 0, c) for c in c_vals]
        axes[1].plot(c_vals, defects, label=f'a={a}', alpha=0.7)
    axes[1].plot(c_vals, -2 * c_vals, 'k--', linewidth=2, label='-2c (theory)')
    axes[1].set_xlabel('c')
    axes[1].set_ylabel('Defect')
    axes[1].set_title('Defect vs c (all curves overlap = causal)')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Pentagon defect
    d_vals = np.arange(-20, 21)
    pentagon_defects = []
    for d in d_vals:
        sub = lambda x, y: x - y
        lhs = (assoc_defect_sub(1, 2, 3) +
               assoc_defect_sub(1, 2 - 3, d) +
               assoc_defect_sub(2, 3, d))
        rhs = (assoc_defect_sub(1 - 2, 3, d) +
               assoc_defect_sub(1, 2, 3 - d))
        pentagon_defects.append(lhs - rhs)

    axes[2].plot(d_vals, pentagon_defects, 'b-', linewidth=2, label='Pentagon defect')
    axes[2].plot(d_vals, -4 * d_vals, 'r--', linewidth=2, label='-4d (theory)')
    axes[2].set_xlabel('d')
    axes[2].set_ylabel('Pentagon Defect')
    axes[2].set_title('Pentagon Obstruction = -4d')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('defect_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved defect_visualization.png")


if __name__ == "__main__":
    main()
