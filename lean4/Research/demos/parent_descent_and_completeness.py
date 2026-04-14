#!/usr/bin/env python3
"""
Parent Descent Algorithm and Completeness Evidence
====================================================
Demonstrates the inverse Berggren algorithm for finding the path from
any primitive Pythagorean triple back to (3,4,5).

This provides computational evidence for Berggren completeness (Direction #2).
"""

import math
from collections import defaultdict

def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

# Correct inverse matrices (B⁻¹ = Q·Bᵀ·Q)
def inv_A(a, b, c):
    return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def inv_B(a, b, c):
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def inv_C(a, b, c):
    return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def is_valid_ppt(a, b, c):
    """Check if (a,b,c) is a valid primitive Pythagorean triple with positive entries."""
    return a > 0 and b > 0 and c > 0 and a*a + b*b == c*c and math.gcd(a, b) == 1

def parent_descent(a, b, c, verbose=False):
    """
    Find the Berggren path from (3,4,5) to (a,b,c).
    Returns the path string, or None if not reachable.
    """
    if not is_valid_ppt(a, b, c):
        return None

    path = []
    current = (a, b, c)

    while current != (3, 4, 5):
        ca, cb, cc = current

        if verbose:
            print(f"  Current: ({ca}, {cb}, {cc}), hyp = {cc}")

        # Try all three inverses
        candidates = [
            ('A', inv_A(ca, cb, cc)),
            ('B', inv_B(ca, cb, cc)),
            ('C', inv_C(ca, cb, cc)),
        ]

        found = False
        for label, (pa, pb, pc) in candidates:
            if pa > 0 and pb > 0 and pc > 0 and pa*pa + pb*pb == pc*pc and pc < cc:
                path.append(label)
                current = (pa, pb, pc)
                found = True
                if verbose:
                    print(f"    → Parent via {label}: ({pa}, {pb}, {pc})")
                break

        if not found:
            return None

        if len(path) > 1000:
            return None  # Safety

    path.reverse()
    return ''.join(path)

def verify_path(path_str):
    """Given a path string, compute the resulting triple and verify."""
    triple = (3, 4, 5)
    for step in path_str:
        if step == 'A':
            triple = berggren_A(*triple)
        elif step == 'B':
            triple = berggren_B(*triple)
        elif step == 'C':
            triple = berggren_C(*triple)
    return triple

def generate_all_ppts(max_hyp):
    """Generate all primitive Pythagorean triples with hypotenuse ≤ max_hyp."""
    triples = set()
    for m in range(2, int(math.isqrt(max_hyp)) + 1):
        for n in range(1, m):
            if (m - n) % 2 == 1 and math.gcd(m, n) == 1:
                a = m*m - n*n
                b = 2*m*n
                c = m*m + n*n
                if c <= max_hyp:
                    # Ensure a < b for canonical form... actually we want both orderings
                    triples.add((a, b, c))
                    triples.add((b, a, c))
    return triples

def main():
    print("=" * 70)
    print("PARENT DESCENT AND BERGGREN COMPLETENESS")
    print("Direction #2: Computational Evidence")
    print("=" * 70)

    # Part 1: Demonstrate descent on specific triples
    print("\n§1. Parent Descent Examples")
    print("-" * 55)

    test_cases = [
        (5, 12, 13),
        (21, 20, 29),
        (15, 8, 17),
        (7, 24, 25),
        (119, 120, 169),
        (55, 48, 73),
        (697, 696, 985),
        (3, 4, 5),
    ]

    for triple in test_cases:
        a, b, c = triple
        path = parent_descent(a, b, c)
        if path is not None:
            # Verify roundtrip
            recovered = verify_path(path)
            ok = recovered == (a, b, c)
            print(f"  ({a:>4}, {b:>4}, {c:>4}) → path='{path}' depth={len(path)} roundtrip={'✓' if ok else '✗'}")
        else:
            # Try swapped
            path = parent_descent(b, a, c)
            if path is not None:
                recovered = verify_path(path)
                ok = recovered == (b, a, c)
                print(f"  ({a:>4}, {b:>4}, {c:>4}) → path='{path}' depth={len(path)} [swapped] "
                      f"roundtrip={'✓' if ok else '✗'}")
            else:
                print(f"  ({a:>4}, {b:>4}, {c:>4}) → root")

    # Part 2: Exhaustive completeness test
    print(f"\n\n§2. Exhaustive Completeness Test")
    print("-" * 55)

    max_hyp = 1000
    all_ppts = generate_all_ppts(max_hyp)

    # Group by canonical form (a ≤ b)
    canonical = set()
    for a, b, c in all_ppts:
        canonical.add((min(a,b), max(a,b), c))

    found = 0
    not_found = 0
    failed = []

    for a, b, c in sorted(canonical):
        # Try both orderings
        path = parent_descent(a, b, c)
        if path is None:
            path = parent_descent(b, a, c)
        if path is not None:
            found += 1
        else:
            not_found += 1
            failed.append((a, b, c))

    print(f"  Hypotenuse bound: {max_hyp}")
    print(f"  Total primitive triples: {len(canonical)}")
    print(f"  Successfully descended: {found}")
    print(f"  Failed to descend: {not_found}")

    if failed:
        print(f"\n  Failed triples:")
        for t in failed[:10]:
            print(f"    {t}")
    else:
        print(f"\n  ✓ ALL {found} primitive Pythagorean triples with c ≤ {max_hyp}")
        print(f"    successfully descended to (3,4,5)!")

    # Part 3: Uniqueness test
    print(f"\n\n§3. Uniqueness Test")
    print("-" * 55)

    # Generate tree triples and check no duplicates
    tree_triples = set()
    queue = [((3, 4, 5), 0)]
    duplicates = []

    while queue:
        triple, depth = queue.pop(0)
        if triple in tree_triples:
            duplicates.append(triple)
        tree_triples.add(triple)
        if depth < 6:  # depth 6 = 3^6 = 729 triples
            queue.append((berggren_A(*triple), depth + 1))
            queue.append((berggren_B(*triple), depth + 1))
            queue.append((berggren_C(*triple), depth + 1))

    print(f"  Tree depth: 6")
    print(f"  Triples generated: {len(tree_triples)}")
    print(f"  Duplicates found: {len(duplicates)}")
    if not duplicates:
        print(f"  ✓ All triples in the tree are unique!")

    # Part 4: Counting function
    print(f"\n\n§4. Counting Function")
    print("-" * 55)
    print(f"  Lehmer's formula: π_P(N) ~ N/(2π)")
    print()
    for N in [100, 500, 1000, 5000, 10000]:
        ppts = generate_all_ppts(N)
        canon = set()
        for a, b, c in ppts:
            canon.add((min(a,b), max(a,b), c))
        count = len(canon)
        predicted = N / (2 * math.pi)
        ratio = count / predicted if predicted > 0 else 0
        print(f"  N={N:>6}: π_P(N)={count:>5}, N/(2π)={predicted:>8.1f}, ratio={ratio:.4f}")

    print(f"\n  As N → ∞, the ratio → 1 (Lehmer's asymptotic formula)")

if __name__ == "__main__":
    main()
