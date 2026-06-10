#!/usr/bin/env python3
"""
Demonstration of Reflective Algebra Computations

Shows concrete numerical examples of:
1. Lawvere's fixed point theorem in finite systems
2. Reflective deficiency computation and 1/e convergence
3. Observation bands and consciousness kernels
4. Closure operator verification
"""

from algorithms import (
    find_fixed_points, reflective_deficiency, reflective_deficiency_ratio,
    observation_quotient, consciousness_kernel, is_idempotent,
    count_idempotents, enumerate_endomorphisms, is_observation_band,
    closure_operator_check, derangement_ratio_limit
)
from math import exp


def demo_lawvere():
    """Demonstrate Lawvere's fixed point theorem on small examples."""
    print("=" * 60)
    print("DEMO 1: Lawvere's Fixed Point Theorem")
    print("=" * 60)
    print()

    # Example: Fin(1) trivially has a surjection to its endomorphisms
    # (there's only one endomorphism: id)
    print("Fin(1): Every endomorphism has a fixed point (trivially).")
    n = 1
    f = lambda x: x  # identity
    fps = find_fixed_points(f, n)
    print(f"  id has fixed points: {fps}")
    print()

    # Example: Fin(3) has 27 endomorphisms, many without fixed points
    print("Fin(3): Some endomorphisms lack fixed points.")
    n = 3
    shift = lambda x: (x + 1) % 3  # cyclic shift
    fps = find_fixed_points(shift, n)
    print(f"  Cyclic shift (x -> x+1 mod 3) fixed points: {fps}")
    print(f"  (Empty! This is a derangement.)")
    print()

    const0 = lambda x: 0  # constant 0
    fps = find_fixed_points(const0, n)
    print(f"  Constant 0 fixed points: {fps}")
    print()


def demo_deficiency():
    """Demonstrate reflective deficiency and the 1/e convergence."""
    print("=" * 60)
    print("DEMO 2: Reflective Deficiency and 1/e Convergence")
    print("=" * 60)
    print()

    print(f"{'n':>3} | {'n^n':>8} | {'Deficiency':>10} | {'Ratio':>10} | {'1/e':>10}")
    print("-" * 55)

    limit = derangement_ratio_limit()
    for n in range(1, 11):
        d = reflective_deficiency(n)
        r = reflective_deficiency_ratio(n)
        print(f"{n:>3} | {n**n:>8} | {d:>10} | {r:>10.6f} | {limit:>10.6f}")

    print()
    print(f"Limit (1/e) = {limit:.10f}")
    print(f"Ratio at n=10: {reflective_deficiency_ratio(10):.10f}")
    print(f"Gap: {abs(reflective_deficiency_ratio(10) - limit):.2e}")
    print()


def demo_idempotents():
    """Demonstrate idempotent counting and observation bands."""
    print("=" * 60)
    print("DEMO 3: Idempotent Endomorphisms and Observation Bands")
    print("=" * 60)
    print()

    for n in range(1, 7):
        count = count_idempotents(n)
        total = n**n
        print(f"Fin({n}): {count} idempotents out of {total} endomorphisms "
              f"({100*count/total:.1f}%)")

    print()

    # Example observation band on Fin(3)
    n = 3
    # Idempotent: project to {0, 1} by clamping 2 -> 1
    f1 = lambda x: min(x, 1)
    # Idempotent: constant 0
    f2 = lambda x: 0
    # Their composition f1 ∘ f2 = const 0, f2 ∘ f1 = const 0
    ops = [f1, f2]

    print(f"Example observation band on Fin(3):")
    print(f"  f1: clamp to [0,1]: {[f1(x) for x in range(n)]}")
    print(f"  f2: constant 0:     {[f2(x) for x in range(n)]}")
    print(f"  f1 idempotent: {is_idempotent(f1, n)}")
    print(f"  f2 idempotent: {is_idempotent(f2, n)}")
    print()

    print(f"Consciousness kernels (fixed points):")
    print(f"  Kernel(f1) = {consciousness_kernel(f1, n)}")
    print(f"  Kernel(f2) = {consciousness_kernel(f2, n)}")
    print()

    print(f"Observation quotients:")
    q1 = observation_quotient(f1, n)
    print(f"  X/~_f1: {dict(q1)}")
    q2 = observation_quotient(f2, n)
    print(f"  X/~_f2: {dict(q2)}")
    print()


def demo_closure():
    """Demonstrate the closure operator characterization."""
    print("=" * 60)
    print("DEMO 4: Closure Operator Characterization")
    print("=" * 60)
    print()

    # On {0, 1, 2, 3} with natural order
    # Closure: round up to nearest even: 0->0, 1->2, 2->2, 3->4 (capped at 3)
    n = 4
    f = lambda x: x if x % 2 == 0 else min(x + 1, n - 1)
    order = lambda a, b: a <= b

    print(f"Domain: {{0, 1, 2, 3}} with natural order")
    print(f"Closure f: round up to even (capped): {[f(x) for x in range(n)]}")
    print(f"Idempotent: {is_idempotent(f, n)}")
    print(f"Inflationary: {all(x <= f(x) for x in range(n))}")
    print(f"Monotone: {all(f(a) <= f(b) for a in range(n) for b in range(n) if a <= b)}")
    print()

    result = closure_operator_check(f, n, order)
    print(f"Closure characterization (a ≤ f(b) ↔ f(a) ≤ f(b)): {result}")
    print()

    # Show specific examples
    print("Detailed check:")
    for a in range(n):
        for b in range(n):
            fb = f(b)
            fa = f(a)
            lhs = a <= fb
            rhs = fa <= fb
            if lhs or rhs:  # only show interesting cases
                print(f"  a={a}, b={b}: {a} ≤ f({b})={fb} is {lhs}, "
                      f"f({a})={fa} ≤ f({b})={fb} is {rhs} "
                      f"{'✓' if lhs == rhs else '✗'}")


def demo_finiteness_barrier():
    """Demonstrate the finiteness barrier theorem."""
    print()
    print("=" * 60)
    print("DEMO 5: Finiteness Barrier")
    print("=" * 60)
    print()

    print("No surjection Fin(n) -> (Fin(n) -> Fin(n)) for n ≥ 2:")
    print()
    print(f"{'n':>3} | {'|Fin(n)|':>8} | {'|Fin(n)^Fin(n)|':>15} | {'Surjection?':>12}")
    print("-" * 50)

    for n in range(1, 8):
        size_domain = n
        size_codomain = n**n
        possible = size_domain >= size_codomain
        print(f"{n:>3} | {size_domain:>8} | {size_codomain:>15} | "
              f"{'Possible' if possible else 'Impossible':>12}")

    print()
    print("For n=1: |Fin(1)| = 1 = 1^1 = |Fin(1)^Fin(1)|, surjection exists!")
    print("For n≥2: n < n^n, so no surjection can exist.")
    print("This proves: self-modeling requires infinity.")


if __name__ == "__main__":
    demo_lawvere()
    demo_deficiency()
    demo_idempotents()
    demo_closure()
    demo_finiteness_barrier()


#!/usr/bin/env python3
"""
Visualization: Reflective Deficiency Convergence to 1/e

Shows how the ratio of fixed-point-free endomorphisms on Fin(n)
converges to 1/e as n → ∞.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import comb, exp


def reflective_deficiency_ratio(n: int) -> float:
    if n == 0:
        return 0.0
    count = sum((-1)**k * comb(n, k) * n**(n - k) for k in range(n + 1))
    return count / n**n


def main():
    ns = list(range(1, 21))
    ratios = [reflective_deficiency_ratio(n) for n in ns]
    limit = 1.0 / exp(1)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: ratio convergence
    ax1.plot(ns, ratios, 'bo-', markersize=6, label='Deficiency ratio')
    ax1.axhline(y=limit, color='r', linestyle='--', linewidth=2,
                label=f'1/e ≈ {limit:.4f}')
    ax1.set_xlabel('n (size of Fin(n))', fontsize=12)
    ax1.set_ylabel('Fraction of fixed-point-free endomorphisms', fontsize=12)
    ax1.set_title('Reflective Deficiency Converges to 1/e', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 0.5)

    # Right: log gap
    gaps = [abs(r - limit) for r in ratios]
    ax2.semilogy(ns, gaps, 'gs-', markersize=6, label='|ratio - 1/e|')
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Gap from limit', fontsize=12)
    ax2.set_title('Convergence Rate (log scale)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('reflective_deficiency.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved reflective_deficiency.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Finiteness Barrier

Shows the exponential gap between n and n^n that prevents
finite types from being reflective.
"""

import matplotlib.pyplot as plt
import numpy as np


def main():
    ns = np.arange(1, 8)
    n_vals = ns.astype(float)
    nn_vals = ns.astype(float) ** ns

    fig, ax = plt.subplots(figsize=(10, 7))

    ax.bar(ns - 0.2, n_vals, 0.35, label='|Fin(n)| = n', color='steelblue', alpha=0.8)
    ax.bar(ns + 0.2, nn_vals, 0.35, label='|Fin(n)→Fin(n)| = nⁿ', color='coral', alpha=0.8)

    ax.set_yscale('log')
    ax.set_xlabel('n', fontsize=13)
    ax.set_ylabel('Cardinality (log scale)', fontsize=13)
    ax.set_title('The Finiteness Barrier: n vs nⁿ\n'
                 'No surjection Fin(n) → (Fin(n) → Fin(n)) for n ≥ 2',
                 fontsize=14)
    ax.legend(fontsize=12)
    ax.set_xticks(ns)
    ax.grid(True, alpha=0.3, axis='y')

    # Annotate the gap
    for n in [3, 5, 7]:
        ax.annotate(f'Gap: {n**n - n}',
                    xy=(n + 0.2, n**n),
                    xytext=(n + 0.6, n**n * 1.5),
                    fontsize=9, color='darkred',
                    arrowprops=dict(arrowstyle='->', color='darkred'))

    plt.tight_layout()
    plt.savefig('finiteness_barrier.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved finiteness_barrier.png")


if __name__ == "__main__":
    main()
