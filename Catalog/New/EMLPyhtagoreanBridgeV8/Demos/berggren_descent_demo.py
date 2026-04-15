#!/usr/bin/env python3
"""
Berggren Descent Algorithm — Interactive Demo

Given any primitive Pythagorean triple (a, b, c), this algorithm finds
its unique path in the Berggren tree by repeatedly computing the parent
until reaching the root (3, 4, 5).

The algorithm runs in O(log c) steps, and the path encodes a ternary
representation related to the Euclid parameters.
"""

from math import gcd, sqrt
import sys


def is_ppt(a, b, c):
    """Check if (a,b,c) is a primitive Pythagorean triple."""
    return a*a + b*b == c*c and gcd(a, b) == 1 and a > 0 and b > 0 and c > 0


def parent_A(a, b, c):
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def parent_B(a, b, c):
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def parent_C(a, b, c):
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


def descend(a, b, c, verbose=True):
    """
    Descend from (a,b,c) to the root (3,4,5), recording the path.

    Returns the path as a string like "ABCA" (reversed: root → node).
    """
    if not is_ppt(a, b, c):
        print(f"  ({a}, {b}, {c}) is not a primitive Pythagorean triple!")
        return None

    path = []
    steps = [(a, b, c)]

    while (a, b, c) != (3, 4, 5) and (a, b, c) != (4, 3, 5):
        pa = parent_A(a, b, c)
        pb = parent_B(a, b, c)
        pc = parent_C(a, b, c)

        if all(x > 0 for x in pa):
            branch = 'A'
            a, b, c = pa
        elif all(x > 0 for x in pb):
            branch = 'B'
            a, b, c = pb
        elif all(x > 0 for x in pc):
            branch = 'C'
            a, b, c = pc
        else:
            print(f"  ERROR: No valid parent for ({a}, {b}, {c})")
            return None

        path.append(branch)
        steps.append((a, b, c))

    path.reverse()
    forward_path = ''.join(path)

    if verbose:
        print(f"\n  Descent from ({steps[0][0]}, {steps[0][1]}, {steps[0][2]}):")
        for i, (step, (aa, bb, cc)) in enumerate(zip(['start'] + list(reversed(forward_path)), steps)):
            arrow = "  →  " if i > 0 else "     "
            label = f"[parent via {step}]" if i > 0 else "[start]"
            print(f"  {arrow}({aa:>6}, {bb:>6}, {cc:>6})  {label}")
        print(f"\n  Tree path (root → node): {forward_path}")
        print(f"  Depth: {len(forward_path)}")

    return forward_path


def generate_ppts(max_c=200):
    """Generate all PPTs with c ≤ max_c using Euclid's parametrization."""
    triples = []
    for m in range(2, int(sqrt(max_c)) + 2):
        for n in range(1, m):
            if gcd(m, n) == 1 and (m - n) % 2 == 1:
                a = m*m - n*n
                b = 2*m*n
                c = m*m + n*n
                if c <= max_c:
                    triples.append((a, b, c))
    return sorted(triples, key=lambda t: t[2])


def main():
    print()
    print("╔════════════════════════════════════════════════════════════════╗")
    print("║          BERGGREN DESCENT ALGORITHM — DEMO                   ║")
    print("╚════════════════════════════════════════════════════════════════╝")

    # Demo with specific triples
    demo_triples = [
        (5, 12, 13),
        (7, 24, 25),
        (20, 21, 29),
        (119, 120, 169),
        (9, 40, 41),
        (697, 696, 985),
    ]

    for triple in demo_triples:
        descend(*triple)
        print()

    # Summary table
    print("=" * 65)
    print("  COMPLETE PATH TABLE (all PPTs with c ≤ 100)")
    print("=" * 65)
    print(f"  {'Triple':>20}  {'Path':>12}  {'Depth':>5}  {'Angle':>7}")
    print("  " + "-" * 50)

    triples = generate_ppts(100)
    from math import atan2, degrees
    for a, b, c in triples:
        path = descend(a, b, c, verbose=False)
        angle = degrees(atan2(b, a))
        print(f"  ({a:>3}, {b:>3}, {c:>3})  {path:>12}  {len(path):>5}  {angle:>6.1f}°")

    print()
    print(f"  Total PPTs with c ≤ 100: {len(triples)}")
    print()


if __name__ == "__main__":
    main()
