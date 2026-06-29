#!/usr/bin/env python3
"""
Markov-Trace Dynamics: Numerical Demonstrations

Demonstrates the key results connecting SL₂(ℤ) trace algebra to
Markov triple theory through Chebyshev polynomial recurrences.
"""

import math


def cheb_trace(t: int, n: int) -> int:
    """Compute the Chebyshev trace sequence chebTrace(t, n).

    Satisfies T(0) = 2, T(1) = t, T(n+2) = t*T(n+1) - T(n).
    Equals tr(A^n) for any A in SL₂(ℤ) with tr(A) = t.
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b


def markov_vieta(x: int, y: int, z: int) -> tuple[int, int, int]:
    """Apply the Markov-Vieta involution: (x,y,z) -> (x,y,3xy-z)."""
    return (x, y, 3 * x * y - z)


def is_markov_triple(x: int, y: int, z: int) -> bool:
    """Check if (x,y,z) satisfies the Markov equation x²+y²+z² = 3xyz."""
    return x**2 + y**2 + z**2 == 3 * x * y * z


def generate_markov_tree(depth: int = 5) -> list[tuple[int, int, int]]:
    """Generate Markov triples by BFS on the Markov tree from (1,1,1)."""
    triples = set()
    queue = [(1, 1, 1)]
    for _ in range(depth):
        new_queue = []
        for x, y, z in queue:
            triple = tuple(sorted([x, y, z]))
            if triple in triples:
                continue
            triples.add(triple)
            # Apply Vieta involution on each coordinate
            new_queue.append((3*y*z - x, y, z))
            new_queue.append((x, 3*x*z - y, z))
            new_queue.append((x, y, 3*x*y - z))
        queue = new_queue
    return sorted(triples)


def demo_chebyshev_trace():
    """Demonstrate the Chebyshev trace sequence and exponential growth."""
    print("=" * 60)
    print("DEMO 1: Chebyshev Trace Sequence")
    print("=" * 60)
    print()

    for t in [3, 4, 5]:
        print(f"  t = {t}: chebTrace(t, n) for n = 0..8:")
        values = [cheb_trace(t, n) for n in range(9)]
        print(f"    {values}")
        bounds = [(t - 1)**n for n in range(9)]
        print(f"    Lower bound (t-1)^n: {bounds}")
        print(f"    Ratio T(n+1)/T(n):")
        ratios = [values[i+1]/values[i] for i in range(8) if values[i] != 0]
        print(f"    {[f'{r:.4f}' for r in ratios]}")
        eigenval = (t + math.sqrt(t**2 - 4)) / 2
        print(f"    Dominant eigenvalue: {eigenval:.4f}")
        print()


def demo_doubling_formula():
    """Demonstrate the Chebyshev doubling formula: T(2n) = T(n)² - 2."""
    print("=" * 60)
    print("DEMO 2: Chebyshev Doubling Formula")
    print("=" * 60)
    print()

    for t in [3, 5, 7]:
        print(f"  t = {t}:")
        for n in range(1, 6):
            t2n = cheb_trace(t, 2 * n)
            tn_sq = cheb_trace(t, n)**2 - 2
            print(f"    T(2·{n}) = {t2n}, T({n})² - 2 = {tn_sq}  ✓" if t2n == tn_sq
                  else f"    T(2·{n}) = {t2n}, T({n})² - 2 = {tn_sq}  ✗")
        print()


def demo_markov_tree():
    """Demonstrate the Markov tree and Vieta involution."""
    print("=" * 60)
    print("DEMO 3: Markov Tree via Vieta Involution")
    print("=" * 60)
    print()

    triples = generate_markov_tree(6)
    print(f"  First {min(15, len(triples))} Markov triples:")
    for t in triples[:15]:
        assert is_markov_triple(*t), f"  {t} is NOT a Markov triple!"
        print(f"    {t}  (verified: {t[0]}²+{t[1]}²+{t[2]}² = "
              f"{t[0]**2+t[1]**2+t[2]**2} = 3·{t[0]}·{t[1]}·{t[2]} = "
              f"{3*t[0]*t[1]*t[2]})")
    print()

    # Demonstrate Vieta involution
    print("  Vieta involution examples:")
    for x, y, z in [(1, 1, 1), (1, 1, 2), (1, 2, 5)]:
        x2, y2, z2 = markov_vieta(x, y, z)
        print(f"    ({x},{y},{z}) → ({x2},{y2},{z2})  "
              f"(still Markov: {is_markov_triple(x2, y2, z2)})")
    print()


def demo_ascending_lemma():
    """Demonstrate the Markov Ascending Lemma."""
    print("=" * 60)
    print("DEMO 4: Markov Ascending Lemma")
    print("=" * 60)
    print()

    print("  Starting from (1,1,2), ascending via Vieta on smallest coordinate:")
    x, y, z = 1, 1, 2
    for step in range(8):
        a, b, c = sorted([x, y, z])
        new_a = 3 * b * c - a
        print(f"    Step {step}: ({a},{b},{c}) → new = 3·{b}·{c} - {a} = {new_a}")
        x, y, z = new_a, b, c
    print()


def demo_sl2_trace():
    """Demonstrate the SL₂ trace-power correspondence."""
    print("=" * 60)
    print("DEMO 5: SL₂(ℤ) Trace-Power Correspondence")
    print("=" * 60)
    print()

    import numpy as np

    # Example SL₂ matrices
    matrices = [
        ("A = [[2,1],[1,1]]", np.array([[2, 1], [1, 1]])),
        ("B = [[3,1],[2,1]]", np.array([[3, 1], [2, 1]])),
        ("C = [[5,2],[2,1]]", np.array([[5, 2], [2, 1]])),
    ]

    for name, A in matrices:
        det = int(np.round(np.linalg.det(A)))
        tr = int(np.trace(A))
        print(f"  {name}, det = {det}, tr = {tr}")
        print(f"    Power traces (matrix vs chebTrace):")
        An = np.eye(2, dtype=int)
        for n in range(8):
            tr_An = int(np.trace(An))
            ct = cheb_trace(tr, n)
            match = "✓" if tr_An == ct else "✗"
            print(f"      n={n}: tr(A^n) = {tr_An}, chebTrace({tr},{n}) = {ct}  {match}")
            An = An @ A
        print()


def demo_fricke_surface():
    """Demonstrate the Fricke surface and its symmetries."""
    print("=" * 60)
    print("DEMO 6: Fricke Surface x²+y²+z²-xyz = κ")
    print("=" * 60)
    print()

    for x, y, z in [(2, 2, 2), (3, 3, 3), (1, 1, 1)]:
        kappa = x**2 + y**2 + z**2 - x*y*z
        print(f"  ({x},{y},{z}): κ = {x}²+{y}²+{z}²-{x}·{y}·{z} = {kappa}")
        # Verify cyclic invariance
        kappa2 = y**2 + z**2 + x**2 - y*z*x
        print(f"    Cyclic ({y},{z},{x}): κ = {kappa2}  (same: {kappa == kappa2})")
        # Verify Vieta involution
        z2 = x*y - z
        kappa3 = x**2 + y**2 + z2**2 - x*y*z2
        print(f"    Vieta ({x},{y},{z2}): κ = {kappa3}  (same: {kappa == kappa3})")
    print()


if __name__ == "__main__":
    demo_chebyshev_trace()
    demo_doubling_formula()
    demo_markov_tree()
    demo_ascending_lemma()
    try:
        demo_sl2_trace()
    except ImportError:
        print("  (numpy not available, skipping SL₂ demo)")
    demo_fricke_surface()
