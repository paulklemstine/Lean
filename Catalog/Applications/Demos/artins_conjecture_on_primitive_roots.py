"""
Artin's Conjecture on Primitive Roots — Computational Demonstrations

This script demonstrates key results about primitive roots and Artin's conjecture:
1. Computing Artin sets for small bases
2. Verifying the safe prime primitive root criterion
3. Comparing empirical densities with the Artin constant
4. Testing the index characterization of primitive roots
"""

from algorithms import (
    is_primitive_root, artin_set, artin_density, artin_constant_approx,
    safe_primes, primitive_root_index, count_primitive_roots,
    primitive_root_density_ratio, is_artin_candidate, euler_totient,
    is_prime, multiplicative_order
)


def demo_artin_sets():
    """Demonstrate Artin sets for small bases."""
    print("=" * 70)
    print("ARTIN SETS: Primes where a is a primitive root")
    print("=" * 70)

    for a in [2, 3, 5, 6, 7, 10]:
        primes = artin_set(a, 200)
        print(f"\na = {a} (candidate: {is_artin_candidate(a)})")
        print(f"  Artin set up to 200: {primes}")
        print(f"  Count: {len(primes)}")


def demo_artin_constant():
    """Compare empirical primitive root densities with the Artin constant."""
    print("\n" + "=" * 70)
    print("ARTIN CONSTANT COMPARISON")
    print("=" * 70)

    C = artin_constant_approx(1000)
    print(f"\nArtin constant C ≈ {C:.10f}")
    print(f"Expected value:    0.3739558136...")

    print(f"\n{'Base a':>8} {'Density(10^4)':>14} {'Density(10^5)':>14} {'Ratio to C':>12}")
    print("-" * 52)
    for a in [2, 3, 5, 6, 7]:
        d4 = artin_density(a, 10_000)
        d5 = artin_density(a, 100_000)
        print(f"{a:>8} {d4:>14.6f} {d5:>14.6f} {d5/C:>12.4f}")


def demo_safe_primes():
    """Demonstrate the safe prime primitive root criterion."""
    print("\n" + "=" * 70)
    print("SAFE PRIME PRIMITIVE ROOT CRITERION")
    print("=" * 70)

    sp = safe_primes(200)
    print(f"\nSafe primes p = 2q+1 up to 200:")
    for p, q in sp:
        print(f"  p = {p}, q = {q}")
        # For safe primes, non-squares that aren't ±1 are primitive roots
        primroots = []
        for a in range(2, p):
            if is_primitive_root(a, p):
                primroots.append(a)
        nonsquares = []
        for a in range(2, p - 1):  # exclude 1 and p-1 (which is -1)
            if pow(a, (p - 1) // 2, p) != 1:  # non-square by Euler
                nonsquares.append(a)
        print(f"    Primitive roots: {primroots[:10]}{'...' if len(primroots) > 10 else ''}")
        print(f"    Non-trivial non-squares: {nonsquares[:10]}{'...' if len(nonsquares) > 10 else ''}")
        # Verify they match (non-trivial non-squares should be primitive roots)
        match = all(a in primroots for a in nonsquares)
        print(f"    All non-trivial non-squares are primitive roots: {match}")


def demo_index_theory():
    """Demonstrate the primitive root index theory."""
    print("\n" + "=" * 70)
    print("PRIMITIVE ROOT INDEX THEORY")
    print("=" * 70)

    for p in [7, 11, 13, 23, 29]:
        if not is_prime(p):
            continue
        print(f"\np = {p}, φ(p-1) = {euler_totient(p-1)}, density = {primitive_root_density_ratio(p):.4f}")
        print(f"  {'a':>4} {'ord(a)':>8} {'index':>8} {'prim.root?':>12}")
        print(f"  {'-'*36}")
        for a in range(2, min(p, 20)):
            ord_a = multiplicative_order(a, p)
            idx = primitive_root_index(a, p)
            is_pr = is_primitive_root(a, p)
            print(f"  {a:>4} {ord_a:>8} {idx:>8} {'YES' if is_pr else 'no':>12}")
        # Verify: index = 1 iff primitive root
        all_match = all(
            (primitive_root_index(a, p) == 1) == is_primitive_root(a, p)
            for a in range(1, p)
        )
        print(f"  index=1 ⟺ primitive root: {all_match}")


def demo_quadratic_residue_connection():
    """Show that primitive roots are always quadratic non-residues."""
    print("\n" + "=" * 70)
    print("PRIMITIVE ROOTS ARE QUADRATIC NON-RESIDUES")
    print("=" * 70)

    for p in [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]:
        if not is_prime(p) or p == 2:
            continue
        primroots = [a for a in range(1, p) if is_primitive_root(a, p)]
        nonsquares = [a for a in range(1, p) if pow(a, (p - 1) // 2, p) != 1]
        all_nonsquare = all(a in nonsquares for a in primroots)
        print(f"p = {p:>3}: primroots ⊆ non-squares: {all_nonsquare}  "
              f"(#PR = {len(primroots)}, #NR = {len(nonsquares)})")


def demo_testable_conjecture():
    """Demonstrate the testable prediction of Artin's conjecture for a=2."""
    print("\n" + "=" * 70)
    print("TESTABLE CONJECTURE: ARTIN FOR a = 2")
    print("=" * 70)

    bounds = [100, 1000, 10000, 50000]
    C = artin_constant_approx(500)
    print(f"\nArtin constant C ≈ {C:.10f}")
    print(f"\n{'Bound':>10} {'π(B)':>8} {'|A(2)∩[2,B]|':>14} {'Density':>10} {'C':>10} {'Error':>10}")
    print("-" * 65)
    for B in bounds:
        primes = [p for p in range(3, B + 1) if is_prime(p)]
        artin_2 = [p for p in primes if is_primitive_root(2, p)]
        density = len(artin_2) / len(primes) if primes else 0
        error = abs(density - C) / C * 100
        print(f"{B:>10} {len(primes):>8} {len(artin_2):>14} {density:>10.6f} {C:>10.6f} {error:>9.2f}%")

    print(f"\nThe density converges to C as the bound increases,")
    print(f"consistent with Artin's conjecture for a = 2.")
    print(f"\nFalsification test: find a prime P beyond which 2 is NEVER")
    print(f"a primitive root. No such P has been found up to 10^12.")


if __name__ == "__main__":
    demo_artin_sets()
    demo_artin_constant()
    demo_safe_primes()
    demo_index_theory()
    demo_quadratic_residue_connection()
    demo_testable_conjecture()


"""
Visualization: Artin's Conjecture on Primitive Roots

Creates a figure showing primitive root density convergence to the Artin constant.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def prime_factors(n):
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0: n //= d
        d += 1
    if n > 1: factors.append(n)
    return factors


def is_primitive_root(a, p):
    a_mod = a % p
    if a_mod == 0: return False
    for q in prime_factors(p - 1):
        if pow(a_mod, (p - 1) // q, p) == 1: return False
    return True


def artin_constant_approx(num_primes=200):
    product = 1.0
    count, n = 0, 2
    while count < num_primes:
        if is_prime(n):
            product *= (1 - 1.0 / (n * (n - 1)))
            count += 1
        n += 1
    return product


def main():
    C = artin_constant_approx(500)
    bound = 20000
    primes = [p for p in range(3, bound + 1) if is_prime(p)]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Artin's Conjecture on Primitive Roots", fontsize=16, fontweight='bold')

    # Panel 1: Running density for a=2
    ax = axes[0, 0]
    cumulative_pr = 0
    xs, ys = [], []
    for i, p in enumerate(primes):
        if is_primitive_root(2, p):
            cumulative_pr += 1
        if (i + 1) % 10 == 0:
            xs.append(p)
            ys.append(cumulative_pr / (i + 1))
    ax.plot(xs, ys, 'b-', alpha=0.7, linewidth=0.8)
    ax.axhline(y=C, color='r', linestyle='--', label=f'Artin constant C ≈ {C:.6f}')
    ax.set_xlabel('Prime p')
    ax.set_ylabel('Density')
    ax.set_title('Density of primes where 2 is a primitive root')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Multiple bases
    ax = axes[0, 1]
    for a, color in [(2, 'blue'), (3, 'green'), (5, 'orange'), (7, 'purple')]:
        cumulative_pr = 0
        xs, ys = [], []
        for i, p in enumerate(primes):
            if p > a and is_primitive_root(a, p):
                cumulative_pr += 1
            if (i + 1) % 20 == 0:
                xs.append(p)
                ys.append(cumulative_pr / (i + 1))
        ax.plot(xs, ys, color=color, alpha=0.7, linewidth=0.8, label=f'a = {a}')
    ax.axhline(y=C, color='r', linestyle='--', alpha=0.5, label='C')
    ax.set_xlabel('Prime p')
    ax.set_ylabel('Density')
    ax.set_title('Primitive root density for multiple bases')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Primitive root index distribution
    ax = axes[1, 0]
    indices = {}
    test_primes = [p for p in primes if p < 5000]
    for p in test_primes:
        a_mod = 2 % p
        if a_mod == 0: continue
        # Compute order
        order = 1
        current = a_mod
        while current != 1:
            current = (current * a_mod) % p
            order += 1
        idx = (p - 1) // order
        indices[idx] = indices.get(idx, 0) + 1

    sorted_idx = sorted(indices.items())[:15]
    ax.bar([str(k) for k, _ in sorted_idx], [v for _, v in sorted_idx], color='steelblue')
    ax.set_xlabel('Index')
    ax.set_ylabel('Count')
    ax.set_title('Distribution of primitive root index for a=2')
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 4: φ(p-1)/(p-1) density ratio
    ax = axes[1, 1]
    def euler_totient(n):
        result = n
        p, temp = 2, n
        while p * p <= temp:
            if temp % p == 0:
                while temp % p == 0: temp //= p
                result -= result // p
            p += 1
        if temp > 1: result -= result // temp
        return result

    density_ratios = [(p, euler_totient(p - 1) / (p - 1)) for p in primes[:500]]
    ax.scatter([p for p, _ in density_ratios], [d for _, d in density_ratios],
              s=3, alpha=0.5, color='darkgreen')
    ax.axhline(y=C, color='r', linestyle='--', label=f'C ≈ {C:.4f}')
    ax.set_xlabel('Prime p')
    ax.set_ylabel('φ(p-1)/(p-1)')
    ax.set_title('Primitive root density ratio per prime')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('artin_conjecture_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved artin_conjecture_visualization.png")


if __name__ == "__main__":
    main()
