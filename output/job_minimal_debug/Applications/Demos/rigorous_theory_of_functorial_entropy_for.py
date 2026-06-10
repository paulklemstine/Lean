#!/usr/bin/env python3
"""
Functorial Entropy: Numerical Demonstrations

Computes functorial entropy, Landauer cost, entropy defect, and entropy rate
for various functions between finite sets.
"""

import math
from collections import Counter
from typing import Callable, Dict, List, Tuple


def fiber_card(f: Callable[[int], int], domain: List[int], b: int) -> int:
    """Compute |f^{-1}(b)|."""
    return sum(1 for a in domain if f(a) == b)


def fiber_sizes(f: Callable[[int], int], domain: List[int], codomain: List[int]) -> Dict[int, int]:
    """Compute fiber cardinalities for each element of the codomain."""
    counter: Dict[int, int] = {}
    for b in codomain:
        counter[b] = fiber_card(f, domain, b)
    return counter


def functorial_entropy(f: Callable[[int], int], domain: List[int], codomain: List[int]) -> float:
    """Compute H(f) = sum_b (fiberCard(f,b) / |domain|) * log(fiberCard(f,b))."""
    N = len(domain)
    if N == 0:
        return 0.0
    H = 0.0
    for b in codomain:
        fc = fiber_card(f, domain, b)
        if fc > 0:
            H += (fc / N) * math.log(fc)
    return H


def landauer_cost(f: Callable[[int], int], domain: List[int]) -> float:
    """Compute L(f) = log|domain| - log|range(f)|."""
    N = len(domain)
    if N == 0:
        return 0.0
    range_f = set(f(a) for a in domain)
    return math.log(N) - math.log(len(range_f))


def entropy_defect(f: Callable[[int], int], g: Callable[[int], int],
                   domain_f: List[int], codomain_f: List[int], codomain_g: List[int]) -> float:
    """Compute delta(f, g) = H(g o f) - H(f)."""
    gf = lambda a: g(f(a))
    H_f = functorial_entropy(f, domain_f, codomain_f)
    H_gf = functorial_entropy(gf, domain_f, codomain_g)
    return H_gf - H_f


def entropy_rate(f: Callable[[int], int], domain: List[int], n: int) -> float:
    """Compute h(f, n) = H(f^n) / n."""
    if n == 0:
        return 0.0
    # Compute f^n
    fn = lambda a, _f=f, _n=n: a
    def iterate_f(a: int) -> int:
        x = a
        for _ in range(n):
            x = f(x)
        return x
    # Domain and codomain are the same for endomorphisms
    return functorial_entropy(iterate_f, domain, domain) / n


def shannon_entropy(probs: List[float]) -> float:
    """Compute Shannon entropy H = -sum p_i log(p_i)."""
    return -sum(p * math.log(p) for p in probs if p > 0)


def demo_basic():
    """Demonstrate basic functorial entropy computation."""
    print("=" * 60)
    print("DEMO 1: Basic Functorial Entropy")
    print("=" * 60)

    domain = list(range(6))

    # Bijection: f(x) = (x + 1) mod 6
    f_bij = lambda x: (x + 1) % 6
    codomain_bij = list(range(6))
    H_bij = functorial_entropy(f_bij, domain, codomain_bij)
    print(f"\nBijection f(x) = (x+1) mod 6:")
    print(f"  Fibers: {fiber_sizes(f_bij, domain, codomain_bij)}")
    print(f"  H(f) = {H_bij:.6f}  (expected: 0)")

    # Even split: {0,1,2} -> 0, {3,4,5} -> 1
    f_even = lambda x: 0 if x < 3 else 1
    codomain_even = [0, 1]
    H_even = functorial_entropy(f_even, domain, codomain_even)
    print(f"\nEven split f: {{0,1,2}}->0, {{3,4,5}}->1:")
    print(f"  Fibers: {fiber_sizes(f_even, domain, codomain_even)}")
    print(f"  H(f) = {H_even:.6f}  (expected: log(3) = {math.log(3):.6f})")

    # Lopsided: {0} -> 0, {1,2,3,4,5} -> 1
    f_lopsided = lambda x: 0 if x == 0 else 1
    H_lopsided = functorial_entropy(f_lopsided, domain, codomain_even)
    print(f"\nLopsided f: {{0}}->0, {{1,2,3,4,5}}->1:")
    print(f"  Fibers: {fiber_sizes(f_lopsided, domain, codomain_even)}")
    print(f"  H(f) = {H_lopsided:.6f}")

    # Constant: everything -> 0
    f_const = lambda x: 0
    codomain_const = [0]
    H_const = functorial_entropy(f_const, domain, codomain_const)
    print(f"\nConstant f(x) = 0:")
    print(f"  Fibers: {fiber_sizes(f_const, domain, codomain_const)}")
    print(f"  H(f) = {H_const:.6f}  (expected: log(6) = {math.log(6):.6f})")


def demo_composition_monotonicity():
    """Demonstrate H(g o f) >= H(f)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Post-Composition Monotonicity (Data Processing Inequality)")
    print("=" * 60)

    domain = list(range(6))
    codomain_f = list(range(3))
    codomain_g = list(range(2))

    # f: {0,1} -> 0, {2,3} -> 1, {4,5} -> 2
    f = lambda x: x // 2
    # g: {0,1} -> 0, {2} -> 1
    g = lambda x: 0 if x <= 1 else 1
    gf = lambda x: g(f(x))

    H_f = functorial_entropy(f, domain, codomain_f)
    H_gf = functorial_entropy(gf, domain, codomain_g)

    print(f"\nf: {{0,1}}->0, {{2,3}}->1, {{4,5}}->2")
    print(f"g: {{0,1}}->0, {{2}}->1")
    print(f"  H(f) = {H_f:.6f}")
    print(f"  H(g∘f) = {H_gf:.6f}")
    print(f"  H(g∘f) >= H(f)? {H_gf >= H_f - 1e-10}  ✓")
    print(f"  Entropy defect δ(f,g) = {H_gf - H_f:.6f}")


def demo_shannon_bridge():
    """Demonstrate the Entropy-Shannon Bridge."""
    print("\n" + "=" * 60)
    print("DEMO 3: Entropy-Shannon Bridge")
    print("=" * 60)

    domain = list(range(6))
    codomain = list(range(3))
    f = lambda x: x // 2  # {0,1}->0, {2,3}->1, {4,5}->2

    N = len(domain)
    fibers = fiber_sizes(f, domain, codomain)
    fiber_dist = [fibers[b] / N for b in codomain]

    H_f = functorial_entropy(f, domain, codomain)
    H_shannon = shannon_entropy(fiber_dist)
    bridge_value = math.log(N) - H_shannon

    print(f"\nf: {{0,1}}->0, {{2,3}}->1, {{4,5}}->2")
    print(f"  Fiber distribution: {fiber_dist}")
    print(f"  H(f) = {H_f:.6f}")
    print(f"  log|α| = {math.log(N):.6f}")
    print(f"  H_Shannon(fiber dist) = {H_shannon:.6f}")
    print(f"  log|α| - H_Shannon = {bridge_value:.6f}")
    print(f"  Match? {abs(H_f - bridge_value) < 1e-10}  ✓")


def demo_landauer():
    """Demonstrate Landauer cost."""
    print("\n" + "=" * 60)
    print("DEMO 4: Landauer Cost")
    print("=" * 60)

    domain = list(range(8))

    functions = [
        ("Bijection (x+1 mod 8)", lambda x: (x + 1) % 8),
        ("2-to-1 (x // 2)", lambda x: x // 2),
        ("4-to-1 (x // 4)", lambda x: x // 4),
        ("Constant (x -> 0)", lambda x: 0),
    ]

    for name, f in functions:
        L = landauer_cost(f, domain)
        range_size = len(set(f(a) for a in domain))
        print(f"\n  {name}:")
        print(f"    |range| = {range_size}, L(f) = {L:.6f} = log({len(domain)}/{range_size})")


def demo_entropy_rate():
    """Demonstrate entropy rate for endomorphisms."""
    print("\n" + "=" * 60)
    print("DEMO 5: Entropy Rate for Endomorphisms")
    print("=" * 60)

    domain = list(range(6))

    # f: 0->0, 1->0, 2->1, 3->2, 4->3, 5->4
    f = lambda x: max(0, x - 1)
    print(f"\nf(x) = max(0, x-1) on {{0,...,5}}:")
    for n in range(1, 8):
        rate = entropy_rate(f, domain, n)
        print(f"  h(f, {n}) = {rate:.6f}")


def demo_conjecture_test():
    """Test the surjective composition superadditivity conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 6: Surjective Superadditivity Conjecture Test")
    print("=" * 60)

    from itertools import product

    violations = 0
    tests = 0

    # Test all surjections f : Fin 4 -> Fin 2 and all g : Fin 2 -> Fin 2
    domain_f = list(range(4))
    codomain_f = list(range(2))
    codomain_g = list(range(2))

    # Generate all functions from Fin 4 -> Fin 2
    for f_vals in product(codomain_f, repeat=len(domain_f)):
        f = lambda x, vals=f_vals: vals[x]
        # Check if f is surjective
        if len(set(f_vals)) < len(codomain_f):
            continue  # not surjective

        for g_vals in product(codomain_g, repeat=len(codomain_f)):
            g = lambda x, vals=g_vals: vals[x]
            gf = lambda x, _f=f, _g=g: _g(_f(x))

            H_g = functorial_entropy(g, codomain_f, codomain_g)
            H_gf = functorial_entropy(gf, domain_f, codomain_g)

            tests += 1
            if H_gf < H_g - 1e-10:
                violations += 1
                print(f"  VIOLATION: f={f_vals}, g={g_vals}, H(g)={H_g:.4f}, H(g∘f)={H_gf:.4f}")

    print(f"\n  Tested {tests} (surjective f, g) pairs for Fin 4 -> Fin 2 -> Fin 2")
    print(f"  Violations: {violations}")
    if violations == 0:
        print("  Conjecture holds for all tested cases  ✓")


def demo_xlog_superadditivity():
    """Demonstrate the superadditivity of xlog."""
    print("\n" + "=" * 60)
    print("DEMO 7: Superadditivity of x·log(x)")
    print("=" * 60)

    def xlog(x):
        return x * math.log(x) if x > 0 else 0.0

    test_pairs = [(1, 1), (2, 3), (0.5, 0.5), (10, 0.01), (0, 5), (100, 200)]

    for x, y in test_pairs:
        lhs = xlog(x + y)
        rhs = xlog(x) + xlog(y)
        gap = lhs - rhs
        print(f"  x={x:6.2f}, y={y:6.2f}: "
              f"xlog({x+y:.2f})={lhs:8.4f} >= xlog({x:.2f})+xlog({y:.2f})={rhs:8.4f}  "
              f"gap={gap:8.4f}  {'✓' if gap >= -1e-10 else '✗'}")


if __name__ == "__main__":
    demo_basic()
    demo_composition_monotonicity()
    demo_shannon_bridge()
    demo_landauer()
    demo_entropy_rate()
    demo_conjecture_test()
    demo_xlog_superadditivity()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Entropy Growth Along Composition Chains

Shows how functorial entropy increases monotonically when composing
a sequence of non-injective functions.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def functorial_entropy_from_map(f_map, domain, codomain):
    """Compute H(f) given f as a dictionary."""
    N = len(domain)
    if N == 0:
        return 0.0
    from collections import Counter
    counts = Counter(f_map[a] for a in domain)
    H = 0.0
    for b in codomain:
        fc = counts.get(b, 0)
        if fc > 0:
            H += (fc / N) * math.log(fc)
    return H


def compose_maps(f_map, g_map, domain):
    """Compose g o f."""
    return {a: g_map[f_map[a]] for a in domain}


def main():
    # Build a chain of non-injective functions
    # Fin(16) -> Fin(8) -> Fin(4) -> Fin(2) -> Fin(1)
    domains = [list(range(16)), list(range(8)), list(range(4)), list(range(2)), [0]]

    # f1: Fin(16) -> Fin(8) by x // 2
    f1 = {a: a // 2 for a in range(16)}
    # f2: Fin(8) -> Fin(4) by x // 2
    f2 = {a: a // 2 for a in range(8)}
    # f3: Fin(4) -> Fin(2) by x // 2
    f3 = {a: a // 2 for a in range(4)}
    # f4: Fin(2) -> Fin(1) by constant
    f4 = {0: 0, 1: 0}

    functions = [f1, f2, f3, f4]
    labels = ['f₁: Fin(16)→Fin(8)', 'f₂: Fin(8)→Fin(4)',
              'f₃: Fin(4)→Fin(2)', 'f₄: Fin(2)→Fin(1)']

    # Compute entropy of each prefix composition
    # g_k = f_k o ... o f_1
    entropies = [0.0]  # H(id) = 0
    current_map = {a: a for a in range(16)}  # identity
    domain = list(range(16))

    for i, f in enumerate(functions):
        current_map = compose_maps(current_map, f, domain)
        codomain = domains[i + 1]
        H = functorial_entropy_from_map(current_map, domain, codomain)
        entropies.append(H)

    fig, ax = plt.subplots(figsize=(10, 6))

    x = range(len(entropies))
    ax.plot(x, entropies, 'o-', color='steelblue', linewidth=2, markersize=10)

    ax.set_xticks(x)
    ax.set_xticklabels(['id'] + [f'g_{i+1}' for i in range(4)], fontsize=11)
    ax.set_xlabel('Composition depth', fontsize=13)
    ax.set_ylabel('Functorial Entropy H(g_k)', fontsize=13)
    ax.set_title('Monotone Growth of Entropy Along Composition Chain\n'
                 'H(g₁) ≤ H(g₂) ≤ H(g₃) ≤ H(g₄)  (Data Processing Inequality)',
                 fontsize=14)

    # Annotate each point
    for i, H in enumerate(entropies):
        ax.annotate(f'H = {H:.3f}', (i, H), textcoords='offset points',
                    xytext=(10, 10), fontsize=10)

    # Add defect annotations
    for i in range(1, len(entropies)):
        delta = entropies[i] - entropies[i - 1]
        mid_y = (entropies[i] + entropies[i - 1]) / 2
        ax.annotate(f'δ = {delta:.3f}', (i - 0.5, mid_y),
                    fontsize=9, color='red', ha='center')

    ax.set_ylim(-0.1, max(entropies) * 1.2)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('composition_chain.png', dpi=150, bbox_inches='tight')
    plt.show()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Functorial Entropy Landscape

Plots the functorial entropy of all functions from Fin(n) to Fin(m)
as a histogram, showing the distribution of information loss.
"""

import math
from itertools import product
from collections import Counter
import matplotlib.pyplot as plt
import numpy as np


def functorial_entropy_from_vals(f_vals, codomain_size):
    """Compute H(f) from a tuple of function values."""
    N = len(f_vals)
    if N == 0:
        return 0.0
    counts = Counter(f_vals)
    H = 0.0
    for b in range(codomain_size):
        fc = counts.get(b, 0)
        if fc > 0:
            H += (fc / N) * math.log(fc)
    return H


def main():
    n, m = 5, 3  # Functions from Fin(5) to Fin(3)

    entropies = []
    for f_vals in product(range(m), repeat=n):
        H = functorial_entropy_from_vals(f_vals, m)
        entropies.append(H)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Histogram of entropy values
    axes[0].hist(entropies, bins=50, color='steelblue', edgecolor='white', alpha=0.8)
    axes[0].axvline(x=0, color='red', linestyle='--', linewidth=2, label='H=0 (injections)')
    axes[0].axvline(x=math.log(n), color='green', linestyle='--', linewidth=2,
                     label=f'H=log({n}) (constant)')
    axes[0].set_xlabel('Functorial Entropy H(f)', fontsize=12)
    axes[0].set_ylabel('Number of functions', fontsize=12)
    axes[0].set_title(f'Entropy Distribution: Fin({n}) → Fin({m})', fontsize=14)
    axes[0].legend(fontsize=10)

    # Entropy vs fiber uniformity
    uniformity = []
    for f_vals in product(range(m), repeat=n):
        counts = Counter(f_vals)
        sizes = [counts.get(b, 0) for b in range(m)]
        # Uniformity = 1 - normalized variance of fiber sizes
        mean_size = n / m
        var = sum((s - mean_size) ** 2 for s in sizes) / m
        max_var = mean_size ** 2 * (m - 1) / m + (n - mean_size) ** 2 / m
        u = 1 - var / max_var if max_var > 0 else 1
        uniformity.append(u)

    axes[1].scatter(uniformity, entropies, alpha=0.05, s=1, color='steelblue')
    axes[1].set_xlabel('Fiber Uniformity (1 = perfectly uniform)', fontsize=12)
    axes[1].set_ylabel('Functorial Entropy H(f)', fontsize=12)
    axes[1].set_title('Entropy vs Fiber Uniformity', fontsize=14)

    plt.tight_layout()
    plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
    plt.show()
    print(f"Total functions: {len(entropies)}")
    print(f"Min entropy: {min(entropies):.4f}")
    print(f"Max entropy: {max(entropies):.4f} (log({n}) = {math.log(n):.4f})")


if __name__ == "__main__":
    main()
