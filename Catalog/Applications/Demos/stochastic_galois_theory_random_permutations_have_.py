#!/usr/bin/env python3
"""
Stochastic Galois Theory: Demonstration Script

Demonstrates that random polynomials over finite fields have generic
Galois groups with probability approaching 1. Verifies the necklace
formula and computes splitting profile distributions.
"""

from algorithms import (
    count_irreducible_polynomials,
    is_irreducible_fp,
    get_factorization_degrees,
    galois_density_estimate,
    verify_necklace_formula,
)
from itertools import product as cartesian_product
from collections import Counter
import math


def demo_necklace_formula():
    """Verify the necklace formula for irreducible polynomial counts."""
    print("=" * 70)
    print("DEMO 1: Necklace Formula Verification")
    print("=" * 70)
    print()
    print("The number of monic irreducible polynomials of degree n over F_p is:")
    print("  N(n, p) = (1/n) Σ_{d|n} μ(n/d) p^d")
    print()

    results = verify_necklace_formula(max_n=5, max_p=7)

    all_match = True
    for r in results:
        status = "✓" if r["match"] else "✗"
        if not r["match"]:
            all_match = False
        print(f"  {status} degree {r['n']} over F_{r['p']}: "
              f"formula = {r['formula']}, enumeration = {r['direct']}, "
              f"fraction = {r['fraction']:.4f}")

    print()
    if all_match:
        print("  ✓ ALL CHECKS PASSED: Formula matches direct enumeration.")
    else:
        print("  ✗ SOME CHECKS FAILED!")
    print()


def demo_splitting_profiles():
    """Show the distribution of splitting profiles for small cases."""
    print("=" * 70)
    print("DEMO 2: Splitting Profile Distribution")
    print("=" * 70)
    print()
    print("A splitting profile records the degrees of irreducible factors.")
    print("E.g., profile (1,2) means the cubic splits as (linear)(quadratic).")
    print()

    for n in [2, 3, 4]:
        for p in [3, 5, 7]:
            if p ** n > 10000:
                continue

            print(f"  Degree {n} over F_{p} ({p**n} total monic polynomials):")

            profile_counts = Counter()
            for coeffs in cartesian_product(range(p), repeat=n):
                full_coeffs = list(coeffs) + [1]
                profile = tuple(get_factorization_degrees(full_coeffs, p))
                profile_counts[profile] += 1

            total = p ** n
            for profile in sorted(profile_counts.keys()):
                count = profile_counts[profile]
                frac = count / total
                label = ",".join(str(d) for d in profile) if profile else "∅"
                galois_info = ""
                if profile == (n,):
                    galois_info = " ← IRREDUCIBLE (Frobenius = n-cycle)"
                elif profile == tuple([1] * n):
                    galois_info = " ← COMPLETELY SPLIT (trivial Galois)"
                print(f"    [{label}]: {count:5d}  ({frac:.4f}){galois_info}")

            print()


def demo_irreducible_density_convergence():
    """Show that the irreducible fraction converges to 1/n as p → ∞."""
    print("=" * 70)
    print("DEMO 3: Irreducible Density Convergence")
    print("=" * 70)
    print()
    print("For degree n, the fraction of irreducible monic polynomials over F_p")
    print("converges to 1/n as p → ∞.")
    print()

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    for n in [2, 3, 5]:
        print(f"  Degree {n} (target: 1/{n} = {1/n:.6f}):")
        for p in primes:
            formula = count_irreducible_polynomials(n, p)
            total = p ** n
            frac = formula / total
            error = abs(frac - 1/n)
            bar = "█" * int(frac * 60)
            print(f"    p={p:3d}: {frac:.6f}  (error = {error:.6f})  {bar}")
        print()


def demo_quadratic_discriminant():
    """Show the discriminant criterion for quadratic splitting."""
    print("=" * 70)
    print("DEMO 4: Quadratic Discriminant Criterion")
    print("=" * 70)
    print()
    print("A monic quadratic X² + bX + c over F_p (p odd) is irreducible")
    print("iff its discriminant b² - 4c is NOT a square in F_p.")
    print()

    for p in [3, 5, 7, 11, 13]:
        squares = set()
        for x in range(p):
            squares.add((x * x) % p)

        irr_count = 0
        disc_nonsquare_count = 0
        total = 0

        for b in range(p):
            for c in range(p):
                total += 1
                disc = (b * b - 4 * c) % p
                is_nonsquare = disc not in squares

                # Check irreducibility directly
                has_root = any((r * r + b * r + c) % p == 0 for r in range(p))

                if is_nonsquare:
                    disc_nonsquare_count += 1
                if not has_root:
                    irr_count += 1

        match = irr_count == disc_nonsquare_count
        status = "✓" if match else "✗"
        print(f"  {status} F_{p}: irreducible = {irr_count}, "
              f"disc non-square = {disc_nonsquare_count}, "
              f"total = {total}, "
              f"fraction = {irr_count/total:.4f}")

    print()
    print("  The discriminant criterion perfectly predicts irreducibility!")
    print()


def demo_conjecture_test():
    """Test the main conjecture about Galois group genericity."""
    print("=" * 70)
    print("DEMO 5: Falsifiable Conjecture Test")
    print("=" * 70)
    print()
    print("CONJECTURE: For degree 3, the number of monic irreducible cubics")
    print("over F_p is exactly (p³ - p) / 3.")
    print()

    primes = [2, 3, 5, 7, 11, 13]
    all_pass = True

    for p in primes:
        formula = (p**3 - p) // 3
        computed = count_irreducible_polynomials(3, p)

        # Direct verification for small p
        if p <= 7:
            direct = 0
            for coeffs in cartesian_product(range(p), repeat=3):
                full_coeffs = list(coeffs) + [1]
                if is_irreducible_fp(full_coeffs, p):
                    direct += 1
            match = (formula == direct == computed)
        else:
            direct = computed
            match = (formula == computed)

        status = "✓" if match else "✗"
        if not match:
            all_pass = False
        print(f"  {status} p={p:3d}: formula=(p³-p)/3={formula}, "
              f"necklace={computed}, "
              + (f"enumeration={direct}, " if p <= 7 else "")
              + f"fraction={formula/(p**3):.4f}")

    print()
    if all_pass:
        print("  ✓ CONJECTURE CONFIRMED for all tested primes.")
    else:
        print("  ✗ CONJECTURE FAILED for some primes.")
    print()


def demo_galois_group_genericity():
    """Show that 'most' polynomials have the generic splitting pattern."""
    print("=" * 70)
    print("DEMO 6: Galois Group Genericity")
    print("=" * 70)
    print()
    print("Over F_p, the Galois group of f(x) is determined by the Frobenius")
    print("cycle type = splitting profile. The 'generic' case is irreducible.")
    print()
    print("As p grows, the fraction of polynomials with each splitting profile")
    print("approaches the fraction of permutations with the corresponding")
    print("cycle type in S_n (by equidistribution of Frobenius elements).")
    print()

    # For S_3, cycle types and their fractions:
    # (3): 2/6 = 1/3  (3-cycles)
    # (1,2): 3/6 = 1/2  (transpositions + fixed point)
    # (1,1,1): 1/6  (identity)
    print("  Theoretical S_3 cycle type fractions:")
    print("    (3):     2/6 = 0.3333  (n-cycle → irreducible)")
    print("    (1,2):   3/6 = 0.5000  (transposition + fixed point)")
    print("    (1,1,1): 1/6 = 0.1667  (identity → completely split)")
    print()

    for p in [5, 7, 11, 13, 17, 23, 29, 37, 41, 47]:
        irr = count_irreducible_polynomials(3, p) / p**3
        # Count degree pattern (1,2)
        mixed = 0
        split = 0
        for coeffs in cartesian_product(range(p), repeat=3):
            full_coeffs = list(coeffs) + [1]
            prof = tuple(get_factorization_degrees(full_coeffs, p))
            if prof == (1, 2):
                mixed += 1
            elif prof == (1, 1, 1):
                split += 1

        total = p**3
        print(f"    p={p:3d}: irreducible={irr:.4f}  "
              f"(1,2)={mixed/total:.4f}  "
              f"(1,1,1)={split/total:.4f}")
        if p > 20:
            break  # Too slow for larger primes

    print()
    print("  As p → ∞, the profile fractions approach the S_3 cycle type")
    print("  fractions, confirming equidistribution of Frobenius elements.")
    print()


if __name__ == "__main__":
    demo_necklace_formula()
    demo_splitting_profiles()
    demo_quadratic_discriminant()
    demo_conjecture_test()
    demo_irreducible_density_convergence()
    demo_galois_group_genericity()

    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Frobenius Equidistribution Convergence

Shows how splitting profile distributions converge to the uniform
distribution on conjugacy classes of S_n as p → ∞.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import factorial


def mobius(k):
    if k == 1:
        return 1
    factors = []
    temp = k
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def count_irreducible(n, p):
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * (p ** d)
    return total // n


def cycle_type_fraction(partition, n):
    """Fraction of permutations in S_n with given cycle type.

    The number of permutations with cycle type (1^a1, 2^a2, ..., n^an) is
    n! / (prod_k k^ak * ak!)
    """
    from collections import Counter
    counts = Counter(partition)

    denominator = 1
    for k, ak in counts.items():
        denominator *= (k ** ak) * factorial(ak)

    return factorial(n) / denominator / factorial(n)


def partitions(n, max_val=None):
    """Generate all partitions of n as sorted tuples."""
    if max_val is None:
        max_val = n
    if n == 0:
        yield ()
        return
    for first in range(min(n, max_val), 0, -1):
        for rest in partitions(n - first, first):
            yield (first,) + rest


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # --- Panel 1: S_4 equidistribution ---
    ax1 = axes[0]
    n = 4
    parts = list(partitions(n))
    parts_sorted = sorted(parts, key=lambda p: (len(p), p))

    # Theoretical fractions
    theoretical = {}
    for part in parts_sorted:
        theoretical[part] = cycle_type_fraction(part, n)

    # Empirical from necklace formula
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

    # For degree 4, compute splitting profile fractions using the formula
    # Number of polys with profile (d1,...,dk) over F_p:
    # = prod N(di, p) * correction for ordering
    # This is complex; use the simpler formula for irreducible + compute rest

    # Actually, let's compute the exact fractions for smaller primes
    # and use the formula for the irreducible fraction

    x_positions = np.arange(len(parts_sorted))
    width = 0.25

    # Theoretical bars
    theo_vals = [theoretical[p] for p in parts_sorted]
    bars1 = ax1.bar(x_positions - width, theo_vals, width, color='#2196F3',
                    alpha=0.8, label='Theoretical (S₄)')

    # Approximate empirical for p=97
    p_val = 97
    irr_frac = count_irreducible(4, p_val) / p_val**4

    # For other profiles, use the formula:
    # Profile (1,3): each comes from (root)(irr cubic), count = p * N(3,p) - overlaps
    # Profile (2,2): each comes from (irr quad)(irr quad)
    # Profile (1,1,2): root, root, irr quad
    # Profile (1,1,1,1): all roots

    irr2 = count_irreducible(2, p_val)
    irr3 = count_irreducible(3, p_val)

    # Exact counting formulas for degree 4 over F_p:
    total = p_val ** 4

    # (4): irreducible
    count_4 = count_irreducible(4, p_val)

    # (1,3): linear * irreducible cubic = p * irr3
    count_13 = p_val * irr3

    # (2,2): pairs of irreducible quadratics = C(irr2, 2) + irr2 (with repetition)
    # Actually: product of two irr quads (unordered) = irr2*(irr2+1)/2 for equal,
    # but since the pair is unordered and the quads are distinct:
    # If the two quadratic factors are distinct: irr2 * (irr2 - 1) / 2 ordered -> / 2
    # If equal: irr2 (the square of an irr quad)
    # Total monic degree-4 with profile (2,2) = irr2*(irr2-1)/2 + irr2 = irr2*(irr2+1)/2
    count_22 = irr2 * (irr2 + 1) // 2

    # (1,1,2): two linear factors * one irr quad
    # = C(p,2) * irr2 + p * irr2 (with/without repeated roots... actually)
    # Two roots (possibly equal) * irr quad = (p*(p+1)/2) * irr2... no
    # Two distinct roots: p*(p-1)/2 * irr2, Two equal roots: p * irr2
    # Wait: the polynomial factors as (x-a)(x-b)(irr quad).
    # (x-a)(x-b) is determined by {a,b} unordered.
    # Distinct a,b: C(p,2) choices. Equal a=b: p choices.
    # So: (p*(p-1)/2 + p) * irr2 = p*(p+1)/2 * irr2
    count_112 = p_val * (p_val + 1) // 2 * irr2

    # (1,1,1,1): four linear factors = products (x-a)(x-b)(x-c)(x-d)
    # = multinomial of p elements taken 4 with repetition, unordered
    # This is the number of multisets of size 4 from p elements
    # = C(p+3, 4) ... no, it's the number of monic degree-4 that split completely
    # = |{(a,b,c,d) : a≤b≤c≤d in F_p}| = C(p+3,4)
    from math import comb
    count_1111 = comb(p_val + 3, 4)

    empirical = {}
    for part in parts_sorted:
        if part == (4,):
            empirical[part] = count_4 / total
        elif part == (1, 3):
            empirical[part] = count_13 / total
        elif part == (2, 2):
            empirical[part] = count_22 / total
        elif part == (1, 1, 2):
            empirical[part] = count_112 / total
        elif part == (1, 1, 1, 1):
            empirical[part] = count_1111 / total
        else:
            empirical[part] = 0

    emp_vals = [empirical.get(p, 0) for p in parts_sorted]
    bars2 = ax1.bar(x_positions, emp_vals, width, color='#F44336',
                    alpha=0.8, label=f'Empirical (F_{{{p_val}}})')

    ax1.set_xticks(x_positions)
    ax1.set_xticklabels([str(p) for p in parts_sorted], rotation=45, fontsize=9)
    ax1.set_ylabel('Fraction', fontsize=12)
    ax1.set_title(f'Degree 4: Profile Distribution vs S₄ Cycle Types\n(p = {p_val})',
                  fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3, axis='y')

    # --- Panel 2: KL divergence decay ---
    ax2 = axes[1]

    # Compute KL divergence for degree 2 and 3
    for n, color, label in [(2, '#2196F3', 'n=2'), (3, '#F44336', 'n=3')]:
        kl_divs = []
        for p_val in primes:
            irr_frac = count_irreducible(n, p_val) / p_val**n
            split_frac = 1 - irr_frac  # Simplified

            if n == 2:
                theo_irr = 0.5  # S_2: half are transpositions
                theo_split = 0.5
                # KL divergence
                kl = 0
                if irr_frac > 0:
                    kl += irr_frac * np.log(irr_frac / theo_irr)
                if split_frac > 0:
                    kl += split_frac * np.log(split_frac / theo_split)
            elif n == 3:
                # For cubics, three profiles
                irr3 = count_irreducible(3, p_val) / p_val**3
                # split = roots only
                split3 = comb(p_val + 2, 3) / p_val**3
                mixed3 = 1 - irr3 - split3

                theo_vals_n3 = [1/3, 1/2, 1/6]
                emp_vals_n3 = [irr3, mixed3, split3]

                kl = sum(e * np.log(e / t) for e, t in
                        zip(emp_vals_n3, theo_vals_n3) if e > 0 and t > 0)

            kl_divs.append(max(kl, 1e-15))

        ax2.loglog(primes, kl_divs, 'o-', color=color, label=label,
                  markersize=5, linewidth=1.5)

    # Reference line
    ps = np.array(primes, dtype=float)
    ax2.loglog(ps, 1/ps, 'k--', alpha=0.4, label='O(1/p)')
    ax2.loglog(ps, 1/ps**2, 'k:', alpha=0.4, label='O(1/p²)')

    ax2.set_xlabel('Prime p', fontsize=12)
    ax2.set_ylabel('KL Divergence from S_n distribution', fontsize=12)
    ax2.set_title('Rate of Convergence to Equidistribution',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Frobenius Equidistribution in Stochastic Galois Theory',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('convergence_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: convergence_analysis.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quadratic Discriminant and Galois Groups

Shows the relationship between discriminant squares and reducibility
of quadratics over finite fields.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))

    primes = [5, 7, 11, 13, 17, 19]

    for idx, p in enumerate(primes):
        ax = axes[idx // 3][idx % 3]

        squares = set((x * x) % p for x in range(p))

        # Create grid of (b, c) pairs
        b_vals = list(range(p))
        c_vals = list(range(p))

        # Color: red = irreducible (disc is non-square), blue = reducible
        colors = np.zeros((p, p, 3))

        irr_count = 0
        red_count = 0

        for bi, b in enumerate(b_vals):
            for ci, c in enumerate(c_vals):
                disc = (b * b - 4 * c) % p
                if disc in squares:
                    colors[ci, bi] = [0.2, 0.4, 0.9]  # Blue = reducible
                    red_count += 1
                else:
                    colors[ci, bi] = [0.9, 0.2, 0.2]  # Red = irreducible
                    irr_count += 1

        ax.imshow(colors, origin='lower', extent=[-0.5, p-0.5, -0.5, p-0.5],
                  aspect='equal', interpolation='nearest')

        total = p * p
        ax.set_title(f'F_{{{p}}}: {irr_count}/{total} irreducible '
                    f'({irr_count/total:.1%})',
                    fontsize=12, fontweight='bold')
        ax.set_xlabel('b', fontsize=10)
        ax.set_ylabel('c', fontsize=10)

        # Add legend
        if idx == 0:
            from matplotlib.patches import Patch
            legend_elements = [
                Patch(facecolor=(0.9, 0.2, 0.2), label='Irreducible (disc ∉ □)'),
                Patch(facecolor=(0.2, 0.4, 0.9), label='Reducible (disc ∈ □)')
            ]
            ax.legend(handles=legend_elements, loc='upper right', fontsize=8)

    plt.suptitle('Quadratic Polynomials X² + bX + c over F_p:\n'
                 'Irreducibility Determined by Discriminant b² − 4c',
                 fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('discriminant_map.png', dpi=150, bbox_inches='tight')
    print("Saved: discriminant_map.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Splitting Profile Distribution as p grows

Shows how the distribution of factorization patterns of cubic polynomials
over F_p converges to the S_3 cycle type distribution as p → ∞.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as cartesian_product


def mobius(k):
    if k == 1:
        return 1
    factors = []
    temp = k
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def count_irreducible(n, p):
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius(n // d) * (p ** d)
    return total // n


def is_irreducible(coeffs, p):
    n = len(coeffs) - 1
    if n <= 0:
        return False
    if n == 1:
        return True

    def multiply(f, g):
        if f == [0] or g == [0]:
            return [0]
        result = [0] * (len(f) + len(g) - 1)
        for i, a in enumerate(f):
            for j, b in enumerate(g):
                result[i + j] = (result[i + j] + a * b) % p
        return result

    def divmod_p(f, g):
        if g == [0]:
            raise ValueError
        f = [c % p for c in f]
        g = [c % p for c in g]
        if len(f) < len(g):
            return [0], f
        inv_lead = pow(g[-1], p - 2, p)
        q = [0] * (len(f) - len(g) + 1)
        r = list(f)
        for i in range(len(f) - len(g), -1, -1):
            if len(r) >= len(g) + i:
                coeff = (r[len(g) + i - 1] * inv_lead) % p
                q[i] = coeff
                for j in range(len(g)):
                    r[i + j] = (r[i + j] - coeff * g[j]) % p
        while len(r) > 1 and r[-1] == 0:
            r = r[:-1]
        return q, r

    def gcd_p(f, g):
        def strip(poly):
            while len(poly) > 1 and poly[-1] == 0:
                poly = poly[:-1]
            return poly
        f = strip([c % p for c in f])
        g = strip([c % p for c in g])
        while g != [0]:
            _, r = divmod_p(f, g)
            f = g
            g = strip([c % p for c in r])
        if f == [0]:
            return [0]
        inv_lead = pow(f[-1], p - 2, p)
        return [(c * inv_lead) % p for c in f]

    def pow_x_mod(exp, mod_poly):
        result = [1]
        base = [0, 1]
        e = exp
        while e > 0:
            if e % 2 == 1:
                result = multiply(result, base)
                _, result = divmod_p(result, mod_poly)
            base = multiply(base, base)
            _, base = divmod_p(base, mod_poly)
            e //= 2
        return result

    for k in range(1, n // 2 + 1):
        xpk = pow_x_mod(p ** k, coeffs)
        diff = list(xpk)
        while len(diff) < 2:
            diff.append(0)
        diff[1] = (diff[1] - 1) % p
        while len(diff) > 1 and diff[-1] == 0:
            diff = diff[:-1]
        g = gcd_p(coeffs, diff)
        if g != [1]:
            return False
    return True


def get_profile(coeffs, p):
    n = len(coeffs) - 1
    remaining = list(coeffs)
    degrees = []

    for r in range(p):
        while True:
            val = sum(remaining[i] * pow(r, i, p) for i in range(len(remaining))) % p
            if val == 0 and len(remaining) > 1:
                new = [0] * (len(remaining) - 1)
                new[-1] = remaining[-1]
                for i in range(len(remaining) - 2, 0, -1):
                    new[i - 1] = (remaining[i] + r * new[i]) % p
                remaining = new
                degrees.append(1)
            else:
                break

    if len(remaining) > 1:
        deg = len(remaining) - 1
        if is_irreducible(remaining, p):
            degrees.append(deg)
        else:
            degrees.append(deg)  # Simplified

    degrees.sort()
    return tuple(degrees)


def compute_profile_distribution(n, p):
    from collections import Counter
    counts = Counter()
    for coeffs in cartesian_product(range(p), repeat=n):
        full = list(coeffs) + [1]
        prof = get_profile(full, p)
        counts[prof] += 1
    total = p ** n
    return {k: v / total for k, v in counts.items()}


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # --- Panel 1: Irreducible fraction convergence ---
    ax1 = axes[0]
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

    for n, color, marker in [(2, '#2196F3', 'o'), (3, '#F44336', 's'),
                              (4, '#4CAF50', '^'), (5, '#FF9800', 'D')]:
        fracs = [count_irreducible(n, p) / p**n for p in primes]
        ax1.plot(primes, fracs, f'{marker}-', color=color, label=f'n={n}',
                markersize=5, linewidth=1.5)
        ax1.axhline(y=1/n, color=color, linestyle='--', alpha=0.4)

    ax1.set_xlabel('Prime p', fontsize=12)
    ax1.set_ylabel('Fraction of irreducible polynomials', fontsize=12)
    ax1.set_title('Irreducible Density → 1/n', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # --- Panel 2: Cubic splitting profiles ---
    ax2 = axes[1]
    test_primes = [3, 5, 7, 11, 13, 17, 23]
    profiles_to_track = [(3,), (1, 2), (1, 1, 1)]
    profile_labels = ['Irreducible (3)', 'Mixed (1,2)', 'Split (1,1,1)']
    profile_colors = ['#2196F3', '#F44336', '#4CAF50']
    theoretical = [1/3, 1/2, 1/6]  # S_3 cycle type fractions

    profile_data = {p: {} for p in profiles_to_track}

    for p in test_primes:
        dist = compute_profile_distribution(3, p)
        for prof in profiles_to_track:
            profile_data[prof] = profile_data.get(prof, {})
            profile_data[prof][p] = dist.get(prof, 0)

    for prof, label, color, theo in zip(profiles_to_track, profile_labels,
                                         profile_colors, theoretical):
        vals = [profile_data[prof].get(p, 0) for p in test_primes]
        ax2.plot(test_primes, vals, 'o-', color=color, label=label,
                markersize=6, linewidth=1.5)
        ax2.axhline(y=theo, color=color, linestyle='--', alpha=0.4)

    ax2.set_xlabel('Prime p', fontsize=12)
    ax2.set_ylabel('Fraction', fontsize=12)
    ax2.set_title('Cubic Splitting Profiles → S₃ Cycle Types', fontsize=14,
                  fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # --- Panel 3: Error decay ---
    ax3 = axes[2]
    for n, color in [(2, '#2196F3'), (3, '#F44336'), (5, '#FF9800')]:
        errors = [abs(count_irreducible(n, p) / p**n - 1/n) for p in primes]
        ax3.loglog(primes, errors, 'o-', color=color, label=f'n={n}',
                  markersize=5, linewidth=1.5)

    # Reference lines
    ps = np.array(primes, dtype=float)
    ax3.loglog(ps, 1/ps, 'k--', alpha=0.3, label='O(1/p)')
    ax3.loglog(ps, 1/ps**2, 'k:', alpha=0.3, label='O(1/p²)')

    ax3.set_xlabel('Prime p', fontsize=12)
    ax3.set_ylabel('|fraction - 1/n|', fontsize=12)
    ax3.set_title('Convergence Rate', fontsize=14, fontweight='bold')
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.suptitle('Stochastic Galois Theory: Random Polynomials over Finite Fields',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('splitting_profiles.png', dpi=150, bbox_inches='tight')
    print("Saved: splitting_profiles.png")


if __name__ == "__main__":
    main()
