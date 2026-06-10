#!/usr/bin/env python3
"""
Reflective Algebra: Numerical Demonstrations

Demonstrates key concepts from the self-modeling framework:
1. Reflective deficiency computation for finite types
2. Observation (idempotent) enumeration
3. Green's preorder computation
4. Fixed point analysis
5. Diagonal construction iteration (conjecture test)
"""

from itertools import product
from typing import Callable, Dict, List, Set, Tuple


def all_endomorphisms(n: int) -> List[Tuple[int, ...]]:
    """Generate all endomorphisms of {0, ..., n-1} as tuples."""
    return list(product(range(n), repeat=n))


def apply_endo(f: Tuple[int, ...], x: int) -> int:
    """Apply endomorphism f to element x."""
    return f[x]


def compose(f: Tuple[int, ...], g: Tuple[int, ...]) -> Tuple[int, ...]:
    """Compose endomorphisms: (f ∘ g)(x) = f(g(x))."""
    return tuple(f[g[i]] for i in range(len(f)))


def is_idempotent(f: Tuple[int, ...]) -> bool:
    """Check if f ∘ f = f."""
    return compose(f, f) == f


def fixed_points(f: Tuple[int, ...]) -> Set[int]:
    """Return the set of fixed points of f."""
    return {x for x in range(len(f)) if f[x] == x}


def image(f: Tuple[int, ...]) -> Set[int]:
    """Return the image (range) of f."""
    return set(f)


def reflective_deficiency(n: int, encode: Callable[[int], Tuple[int, ...]]) -> Set[Tuple[int, ...]]:
    """
    Compute the reflective deficiency: endomorphisms not in range(encode).
    """
    represented = {encode(x) for x in range(n)}
    all_endos = set(all_endomorphisms(n))
    return all_endos - represented


def demo_deficiency():
    """Demonstrate the reflective deficiency for small finite types."""
    print("=" * 60)
    print("DEMO 1: Reflective Deficiency for Fin(n)")
    print("=" * 60)

    for n in range(2, 5):
        # Use the "best" encoding: identity-like
        def encode(x: int, n=n) -> Tuple[int, ...]:
            """Map x to the constant-x function."""
            return tuple(x for _ in range(n))

        deficiency = reflective_deficiency(n, encode)
        total = n ** n
        represented = total - len(deficiency)

        print(f"\nn = {n}:")
        print(f"  Total endomorphisms: {total}")
        print(f"  Represented: {represented}")
        print(f"  Deficiency size: {len(deficiency)}")
        print(f"  Deficiency / Total: {len(deficiency)/total:.4f}")
        print(f"  Lower bound (n^n - n): {total - n}")

    # Try the optimal encoding (injective)
    print("\n--- Optimal (injective) encodings ---")
    for n in range(2, 5):
        all_endos = all_endomorphisms(n)
        min_deficiency = float('inf')
        best_encode = None

        # Try random injective encodings
        import random
        random.seed(42)
        for _ in range(min(1000, len(all_endos) ** n)):
            sample = random.sample(all_endos, min(n, len(all_endos)))
            if len(set(sample)) == n:
                encode_map = {i: sample[i] for i in range(n)}
                def_size = len(set(all_endos) - set(sample))
                if def_size < min_deficiency:
                    min_deficiency = def_size
                    best_encode = encode_map

        print(f"  n = {n}: min deficiency found = {min_deficiency}, "
              f"theoretical min = {n**n - n}")


def demo_observations():
    """Demonstrate observation (idempotent) enumeration and range=fixed pts."""
    print("\n" + "=" * 60)
    print("DEMO 2: Observations on Fin(n)")
    print("=" * 60)

    for n in range(1, 6):
        all_endos = all_endomorphisms(n)
        observations = [f for f in all_endos if is_idempotent(f)]

        print(f"\nn = {n}:")
        print(f"  Total endomorphisms: {n**n}")
        print(f"  Idempotent (observations): {len(observations)}")

        # Verify Range = Fixed Points for each observation
        all_match = True
        for obs in observations:
            fp = fixed_points(obs)
            rng = image(obs)
            if fp != rng:
                all_match = False
                print(f"  MISMATCH: obs={obs}, fp={fp}, range={rng}")

        print(f"  Range = Fixed Points verified: {all_match}")

        # Count by number of fixed points
        fp_counts: Dict[int, int] = {}
        for obs in observations:
            k = len(fixed_points(obs))
            fp_counts[k] = fp_counts.get(k, 0) + 1
        print(f"  Distribution by #fixed points: {dict(sorted(fp_counts.items()))}")


def demo_greens_preorder():
    """Demonstrate Green's L-preorder on observations."""
    print("\n" + "=" * 60)
    print("DEMO 3: Green's L-Preorder on Observations (n=3)")
    print("=" * 60)

    n = 3
    all_endos = all_endomorphisms(n)
    observations = [f for f in all_endos if is_idempotent(f)]

    def green_L_le(a: Tuple[int, ...], b: Tuple[int, ...]) -> bool:
        """Check if a ≤_L b: ∃f, a = f∘b."""
        # a(x) must be determined by b(x): if b(x1) = b(x2) then a(x1) = a(x2)
        mapping: Dict[int, int] = {}
        for x in range(n):
            bx = b[x]
            ax = a[x]
            if bx in mapping:
                if mapping[bx] != ax:
                    return False
            else:
                mapping[bx] = ax
        return True

    print(f"\nNumber of observations: {len(observations)}")

    # Compute equivalence classes
    classes: List[List[Tuple[int, ...]]] = []
    classified = set()
    for a in observations:
        if a in classified:
            continue
        cls = [a]
        classified.add(a)
        for b in observations:
            if b not in classified and green_L_le(a, b) and green_L_le(b, a):
                cls.append(b)
                classified.add(b)
        classes.append(cls)

    print(f"Green's L-equivalence classes: {len(classes)}")
    for i, cls in enumerate(classes):
        fp_sizes = [len(fixed_points(f)) for f in cls]
        print(f"  Class {i}: {len(cls)} observations, "
              f"fixed point sizes: {set(fp_sizes)}")


def demo_strange_loops():
    """Demonstrate strange loop construction and idempotence."""
    print("\n" + "=" * 60)
    print("DEMO 4: Strange Loops on Fin(4)")
    print("=" * 60)

    n = 4
    all_endos = all_endomorphisms(n)
    strange_loops = []

    for op in all_endos:
        for shift in all_endos:
            # Check tangle: op(op(x)) = op(shift(x))
            tangle = all(op[op[x]] == op[shift[x]] for x in range(n))
            # Check absorb: op(shift(x)) = op(x)
            absorb = all(op[shift[x]] == op[x] for x in range(n))
            if tangle and absorb:
                strange_loops.append((op, shift))

    print(f"Strange loops found: {len(strange_loops)}")

    # Verify all are idempotent
    all_idem = all(is_idempotent(op) for op, _ in strange_loops)
    print(f"All ops idempotent: {all_idem}")

    # Count unique ops
    unique_ops = set(op for op, _ in strange_loops)
    print(f"Unique op functions: {len(unique_ops)}")
    print(f"Of which are idempotent: {sum(1 for op in unique_ops if is_idempotent(op))}")


def demo_diagonal_conjecture():
    """Test the reflective index dichotomy conjecture on small examples."""
    print("\n" + "=" * 60)
    print("DEMO 5: Diagonal Construction (Conjecture Test)")
    print("=" * 60)

    # Use n=3 with a specific encoding
    n = 3
    # Encode: 0 -> id, 1 -> const(0), 2 -> const(1)
    encode_map = {
        0: (0, 1, 2),  # identity
        1: (0, 0, 0),  # constant 0
        2: (1, 1, 1),  # constant 1
    }

    def encode(x: int) -> Tuple[int, ...]:
        return encode_map[x]

    # Compute deficiency
    represented = set(encode_map.values())
    all_endos = set(all_endomorphisms(n))
    deficiency = all_endos - represented

    print(f"n = {n}")
    print(f"Represented: {represented}")
    print(f"Deficiency size: {len(deficiency)}")

    # Take a deficiency element and iterate the diagonal construction
    g = sorted(deficiency)[0]
    print(f"\nStarting deficiency element: {g}")

    # Diagonal iteration: g_{k+1}(x) = g_k(encode(x)(x))
    current = g
    iterates = [current]
    for step in range(5):
        next_g = tuple(current[encode(x)[x]] for x in range(n))
        iterates.append(next_g)
        in_range = next_g in represented
        in_deficiency = next_g in deficiency
        print(f"  Step {step+1}: {next_g}, in_range={in_range}, in_deficiency={in_deficiency}")
        current = next_g

    # Check distinctness of iterates
    unique_iterates = set(iterates)
    print(f"\nDistinct iterates: {len(unique_iterates)} out of {len(iterates)}")
    print(f"All in deficiency: {all(g in deficiency for g in iterates)}")

    if len(unique_iterates) < len(iterates):
        print("⚠ Iterates cycle — finite type limits the construction")
        print("  (This is expected for finite types; conjecture is about infinite types)")


if __name__ == "__main__":
    demo_deficiency()
    demo_observations()
    demo_greens_preorder()
    demo_strange_loops()
    demo_diagonal_conjecture()


#!/usr/bin/env python3
"""
Visualization: Reflective Deficiency Growth

Shows how the reflective deficiency grows with type size,
demonstrating the finiteness barrier theorem.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import comb


def idempotent_count(n: int) -> int:
    """Count idempotent functions on Fin(n): sum_{k=0}^{n} C(n,k)*k^(n-k)."""
    return sum(comb(n, k) * (k ** (n - k)) for k in range(n + 1))


def main():
    ns = list(range(1, 8))
    total_endos = [n ** n for n in ns]
    min_deficiency = [n ** n - n for n in ns]
    num_idempotents = [idempotent_count(n) for n in ns]
    deficiency_ratio = [1 - n / (n ** n) if n > 1 else 0 for n in ns]

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Reflective Algebra: Quantitative Analysis', fontsize=14, fontweight='bold')

    # Plot 1: Total endomorphisms vs representable
    ax = axes[0, 0]
    ax.bar(np.array(ns) - 0.2, total_endos, 0.4, label='Total endomorphisms (n^n)', color='steelblue')
    ax.bar(np.array(ns) + 0.2, ns, 0.4, label='Max representable (n)', color='coral')
    ax.set_xlabel('n (type size)')
    ax.set_ylabel('Count')
    ax.set_title('Endomorphisms vs Representation Capacity')
    ax.legend()
    ax.set_yscale('log')

    # Plot 2: Minimum deficiency
    ax = axes[0, 1]
    ax.plot(ns, min_deficiency, 'o-', color='crimson', linewidth=2, markersize=8)
    ax.fill_between(ns, 0, min_deficiency, alpha=0.2, color='crimson')
    ax.set_xlabel('n (type size)')
    ax.set_ylabel('Minimum deficiency (n^n - n)')
    ax.set_title('Finiteness Barrier: Minimum Blind Spots')
    ax.set_yscale('log')

    # Plot 3: Deficiency ratio
    ax = axes[1, 0]
    ax.plot(ns[1:], deficiency_ratio[1:], 's-', color='darkgreen', linewidth=2, markersize=8)
    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Complete blindness')
    ax.set_xlabel('n (type size)')
    ax.set_ylabel('Deficiency ratio (1 - n/n^n)')
    ax.set_title('Fraction of Unrepresentable Endomorphisms')
    ax.set_ylim(0, 1.1)
    ax.legend()

    # Plot 4: Observations (idempotents) count
    ax = axes[1, 1]
    ax.plot(ns, num_idempotents, 'D-', color='purple', linewidth=2, markersize=8, label='Idempotents')
    ax.plot(ns, total_endos, 'o--', color='steelblue', linewidth=1, markersize=6, label='All endomorphisms')
    ax.set_xlabel('n (type size)')
    ax.set_ylabel('Count')
    ax.set_title('Observations (Idempotents) vs All Endomorphisms')
    ax.legend()
    ax.set_yscale('log')

    plt.tight_layout()
    plt.savefig('reflective_deficiency.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: reflective_deficiency.png")


if __name__ == "__main__":
    main()
