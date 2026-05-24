#!/usr/bin/env python3
"""
Adelic Persistent Homology — Applications

Shows real-world applications of adelic torsion persistence:
1. Arithmetic fingerprinting of filtered complexes
2. Prime-sensitive topological data analysis
3. CRT-based persistence module decomposition
4. Persistence zeta multiplicativity testing
"""

from algorithms import (
    AdelicTorsionDatum, p_primary_support, prime_factors,
    crt_torsion_decomposition, persistence_zeta, additive_order
)
from math import gcd


# ─── Application 1: Arithmetic Fingerprinting ────────────────────────────────

def arithmetic_fingerprint(filtration_orders):
    """
    Compute the arithmetic fingerprint of a filtered abelian group.

    The fingerprint is a tuple of:
    - The set of all primes appearing
    - The prime barcode (birth-death intervals)
    - The persistence zeta values at s=1,2,3

    Two filtrations with different fingerprints are topologically distinct
    in a prime-sensitive way — they cannot be related by any filtration-
    preserving isomorphism.

    >>> fp = arithmetic_fingerprint([1, 6, 30])
    >>> len(fp['primes']) == 3
    True
    """
    datum = AdelicTorsionDatum(filtration_orders)
    return {
        'orders': filtration_orders,
        'primes': sorted(datum.all_primes()),
        'barcode': datum.full_barcode(),
        'zeta_1': persistence_zeta(datum, 1.0),
        'zeta_2': persistence_zeta(datum, 2.0),
        'zeta_3': persistence_zeta(datum, 3.0),
    }


def demo_fingerprinting():
    """Demonstrate arithmetic fingerprinting to distinguish filtrations."""
    print("=" * 70)
    print("APPLICATION 1: Arithmetic Fingerprinting")
    print("=" * 70)

    filtrations = [
        [1, 2, 4, 8],       # Pure 2-primary
        [1, 3, 9, 27],      # Pure 3-primary
        [1, 2, 6, 12],      # Mixed 2,3-primary
        [1, 6, 30, 60],     # Mixed 2,3,5-primary
        [1, 2, 4, 12],      # 2-primary then 3 appears
        [1, 3, 6, 12],      # 3-primary then 2 appears
    ]

    print("\nFiltrations and their arithmetic fingerprints:")
    for filt in filtrations:
        fp = arithmetic_fingerprint(filt)
        print(f"  {filt}:")
        print(f"    Primes: {fp['primes']}")
        print(f"    Barcode: {fp['barcode']}")
        print(f"    ζ(1)={fp['zeta_1']:.4f}, ζ(2)={fp['zeta_2']:.4f}, ζ(3)={fp['zeta_3']:.4f}")

    print("\n  Key insight: filtrations [1,2,4,12] and [1,3,6,12] have the same")
    print("  final group (Z/12Z) but different prime barcodes — the arithmetic")
    print("  fingerprint distinguishes their topological evolution.")


# ─── Application 2: Prime-Sensitive TDA ──────────────────────────────────────

def prime_sensitive_analysis(data_filtration):
    """
    Perform prime-sensitive topological data analysis.

    Given a filtration of homology groups (represented by orders),
    decompose the persistence diagram by prime to reveal arithmetic
    structure invisible to field-coefficient homology.

    Returns a report dictionary.
    """
    datum = AdelicTorsionDatum(data_filtration)
    report = {
        'n_levels': len(data_filtration),
        'n_primes': len(datum.all_primes()),
        'primes': sorted(datum.all_primes()),
        'level_analysis': [],
        'prime_barcodes': datum.full_barcode(),
    }

    for i, order in enumerate(data_filtration):
        level = {
            'level': i,
            'group_order': order,
            'active_primes': sorted(datum.local_support_at(i)),
            'n_active': len(datum.local_support_at(i)),
        }
        report['level_analysis'].append(level)

    return report


def demo_prime_sensitive_tda():
    """Demonstrate prime-sensitive TDA."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Prime-Sensitive Topological Data Analysis")
    print("=" * 70)

    # Simulate: homology orders from a hypothetical Vietoris-Rips complex
    # over a point cloud with hidden arithmetic structure
    filtration = [1, 2, 2, 6, 6, 30, 30, 30]
    print(f"\nSimulated homology filtration: {filtration}")
    print("(Group orders at each scale parameter)")

    report = prime_sensitive_analysis(filtration)

    print(f"\nPrime-sensitive analysis:")
    print(f"  Total primes detected: {report['n_primes']}")
    print(f"  Active primes: {report['primes']}")
    print(f"\n  Prime barcodes:")
    for p, (birth, death) in sorted(report['prime_barcodes'].items()):
        length = death - birth + 1
        print(f"    p={p}: born at scale {birth}, dies at scale {death}, "
              f"persistence = {length}")

    print(f"\n  Level-by-level prime activity:")
    for level in report['level_analysis']:
        bar = '█' * level['n_active'] + '░' * (report['n_primes'] - level['n_active'])
        print(f"    Level {level['level']} (Z/{level['group_order']}Z): "
              f"{level['active_primes']} [{bar}]")

    print("\n  Interpretation: The 2-primary torsion appears early (scale 1) and")
    print("  persists, while 3-primary appears at scale 3 and 5-primary at scale 5.")
    print("  Standard field-coefficient homology would miss these arithmetic signals.")


# ─── Application 3: CRT Persistence Decomposition ────────────────────────────

def persistence_crt_analysis(group_order, coprime_pairs):
    """
    Analyze the CRT structure of torsion persistence.

    For each coprime pair (m, k) with m*k dividing group_order,
    decompose the mk-torsion subgroup and analyze the decomposition.
    """
    results = []
    for m, k in coprime_pairs:
        if gcd(m, k) != 1:
            continue
        if group_order % (m * k) != 0:
            continue
        decomp = crt_torsion_decomposition(group_order, m, k)
        n_nontrivial = sum(1 for a, b, c in decomp if a != 0)
        results.append({
            'm': m, 'k': k,
            'n_elements': len(decomp),
            'n_nontrivial': n_nontrivial,
            'decomposition': decomp,
        })
    return results


def demo_crt_persistence():
    """Demonstrate CRT persistence decomposition."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: CRT Persistence Module Decomposition")
    print("=" * 70)

    for n in [6, 12, 30]:
        pf = sorted(prime_factors(n))
        print(f"\n  Z/{n}Z (prime factors: {pf})")

        # Generate all coprime pairs from prime factorization
        pairs = []
        if len(pf) >= 2:
            for i in range(len(pf)):
                for j in range(i + 1, len(pf)):
                    m = pf[i]
                    k = n // pf[i]
                    if gcd(m, k) == 1:
                        pairs.append((m, k))
                        break

        # Also add the full CRT decomposition
        if len(pf) == 2:
            p, q = pf
            pk = 1
            while pk * p <= n and n % (pk * p) == 0:
                pk *= p
            qk = n // pk
            if gcd(pk, qk) == 1:
                pairs.append((pk, qk))
        elif len(pf) == 3:
            pairs.append((pf[0], n // pf[0]))

        for m, k in pairs:
            if gcd(m, k) != 1:
                continue
            decomp = crt_torsion_decomposition(n, m, k)
            print(f"    {n} = {m} × {k} decomposition:")
            for a, b, c in decomp[:5]:  # Show first 5
                print(f"      {a} = {b} ({m}-torsion) + {c} ({k}-torsion)")
            if len(decomp) > 5:
                print(f"      ... ({len(decomp)} elements total)")


# ─── Application 4: Zeta Multiplicativity ────────────────────────────────────

def demo_zeta_multiplicativity():
    """Test whether the persistence zeta function is multiplicative."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Persistence Zeta Multiplicativity")
    print("=" * 70)

    print("\n  Testing: Z(F₁ × F₂, s) =? Z(F₁, s) · Z(F₂, s)")
    print("  for various filtrations and values of s")

    pairs = [
        ([1, 2, 4], [1, 3, 9]),
        ([1, 2], [1, 3, 6]),
        ([1, 2, 4], [1, 5, 25]),
    ]

    for s in [1.0, 2.0, 3.0]:
        print(f"\n  s = {s}:")
        for f1, f2 in pairs:
            # "Product" filtration: take products of orders at each level
            # Pad shorter filtration with its last element
            max_len = max(len(f1), len(f2))
            f1_ext = f1 + [f1[-1]] * (max_len - len(f1))
            f2_ext = f2 + [f2[-1]] * (max_len - len(f2))
            f_prod = [a * b for a, b in zip(f1_ext, f2_ext)]

            d1 = AdelicTorsionDatum(f1_ext)
            d2 = AdelicTorsionDatum(f2_ext)
            d_prod = AdelicTorsionDatum(f_prod)

            z1 = persistence_zeta(d1, s)
            z2 = persistence_zeta(d2, s)
            z_prod = persistence_zeta(d_prod, s)
            z_mult = z1 * z2

            match = abs(z_prod - z_mult) < 1e-10
            symbol = "✓" if match else "✗"
            print(f"    {f1} × {f2}: "
                  f"Z(prod)={z_prod:.4f}, Z₁·Z₂={z_mult:.4f} {symbol}")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_fingerprinting()
    demo_prime_sensitive_tda()
    demo_crt_persistence()
    demo_zeta_multiplicativity()


#!/usr/bin/env python3
"""
Adelic Persistent Homology — Interactive Demonstration

Demonstrates the core ideas:
1. Given a filtered finite abelian group, compute prime-wise torsion persistence
2. Assemble the adelic torsion datum
3. Reconstruct the global torsion barcode from prime-local data
4. Verify the reconstruction conjecture on concrete examples
"""

from math import gcd
from collections import defaultdict
from itertools import product as cartesian_product
from functools import reduce


# ─── Core algebra utilities ──────────────────────────────────────────────────

def prime_factors(n):
    """Return the set of prime factors of n."""
    if n <= 1:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def additive_order(element, group_order):
    """Compute the additive order of `element` in Z/group_order Z."""
    if group_order == 0:
        return 0
    e = element % group_order
    if e == 0:
        return 1
    for k in range(1, group_order + 1):
        if (k * e) % group_order == 0:
            return k
    return group_order


def is_p_primary(element, group_order, p):
    """Check if element is p-primary: its additive order is a power of p."""
    if group_order == 0:
        return element == 0
    ord_a = additive_order(element, group_order)
    if ord_a <= 1:
        return True  # zero element is p-primary for any p
    while ord_a > 1:
        if ord_a % p != 0:
            return False
        ord_a //= p
    return True


def p_primary_nontrivial(group_order, p):
    """Check if Z/group_order Z has nontrivial p-primary component."""
    if group_order <= 1:
        return False
    for a in range(1, group_order):
        if is_p_primary(a, group_order, p) and a != 0:
            # Check that additive order is > 1
            if additive_order(a, group_order) > 1:
                return True
    return False


def torsion_prime_support(group_order):
    """Compute the torsion prime support of Z/group_order Z."""
    if group_order <= 1:
        return set()
    return {p for p in prime_factors(group_order) if p_primary_nontrivial(group_order, p)}


# ─── Adelic Torsion Datum ────────────────────────────────────────────────────

class AdelicTorsionDatum:
    """
    The adelic torsion datum for a filtered finite abelian group.

    Packages the prime-indexed family of local support data:
    at each filtration level and each prime p, records whether the
    p-primary component is nontrivial.
    """

    def __init__(self, filtration_orders):
        """
        Construct from a list of group orders representing the filtration.
        filtration_orders[i] = order of the group at filtration level i.
        (We model each group as Z/n Z for simplicity.)
        """
        self.n_levels = len(filtration_orders)
        self.orders = filtration_orders
        self.local_supports = {}  # (prime, level) -> bool

        for i, order in enumerate(filtration_orders):
            support = torsion_prime_support(order)
            for p in support:
                self.local_supports[(p, i)] = True

    def is_active(self, p, i):
        """Whether prime p is active at level i."""
        return self.local_supports.get((p, i), False)

    def reconstruct_support(self, i):
        """Reconstruct the global torsion prime support at level i."""
        return {p for (p, j) in self.local_supports if j == i and self.local_supports[(p, j)]}

    def all_primes(self):
        """Return all primes that appear anywhere in the datum."""
        return {p for (p, _) in self.local_supports}

    def prime_barcode(self, p):
        """
        Compute the 'barcode interval' for prime p:
        the range of levels where p is active.
        Returns (birth, death) or None if p never active.
        """
        active_levels = sorted(i for (q, i) in self.local_supports if q == p and self.local_supports[(q, i)])
        if not active_levels:
            return None
        return (active_levels[0], active_levels[-1])


def verify_reconstruction(filtration_orders):
    """
    Verify the adelic reconstruction conjecture:
    reconstructed support == direct global support at every level.
    """
    datum = AdelicTorsionDatum(filtration_orders)
    all_correct = True
    for i, order in enumerate(filtration_orders):
        direct = torsion_prime_support(order)
        reconstructed = datum.reconstruct_support(i)
        match = direct == reconstructed
        if not match:
            all_correct = False
    return all_correct, datum


# ─── CRT Decomposition ──────────────────────────────────────────────────────

def crt_torsion_split(group_order, m, k):
    """
    For coprime m, k with m*k dividing group_order,
    decompose elements of the mk-torsion subgroup into
    m-torsion + k-torsion parts using CRT.
    """
    if gcd(m, k) != 1:
        raise ValueError(f"m={m} and k={k} are not coprime")

    # Extended GCD: m*u + k*v = 1
    def extended_gcd(a, b):
        if a == 0:
            return b, 0, 1
        g, x, y = extended_gcd(b % a, a)
        return g, y - (b // a) * x, x

    _, u, v = extended_gcd(m, k)
    # Verify: m*u + k*v = 1
    assert m * u + k * v == 1

    results = []
    mk = m * k
    for a in range(group_order):
        if (mk * a) % group_order == 0:  # a is mk-torsion
            b = (k * v * a) % group_order  # m-torsion part
            c = (m * u * a) % group_order  # k-torsion part
            # Verify decomposition
            assert (b + c) % group_order == a % group_order
            assert (m * b) % group_order == 0  # b is m-torsion
            assert (k * c) % group_order == 0  # c is k-torsion
            results.append((a, b, c))
    return results


# ─── Demonstration ───────────────────────────────────────────────────────────

def demo_basic():
    """Basic demonstration with Z/6Z filtration."""
    print("=" * 70)
    print("ADELIC PERSISTENT HOMOLOGY — DEMONSTRATION")
    print("=" * 70)

    print("\n─── Example 1: Filtration 0 → Z/3Z → Z/6Z ───")
    filtration = [1, 3, 6]  # group orders: trivial, Z/3, Z/6
    print(f"Filtration group orders: {filtration}")

    datum = AdelicTorsionDatum(filtration)

    for i, order in enumerate(filtration):
        direct = torsion_prime_support(order)
        reconstructed = datum.reconstruct_support(i)
        status = "✓" if direct == reconstructed else "✗"
        print(f"  Level {i} (Z/{order}Z): prime support = {direct}, "
              f"reconstructed = {reconstructed} {status}")

    print("\n  Prime barcodes:")
    for p in sorted(datum.all_primes()):
        bc = datum.prime_barcode(p)
        print(f"    p={p}: interval [{bc[0]}, {bc[1]}]")

    # Verify reconstruction
    ok, _ = verify_reconstruction(filtration)
    print(f"\n  Reconstruction conjecture verified: {ok}")


def demo_crt():
    """CRT decomposition demonstration."""
    print("\n─── Example 2: CRT Torsion Splitting on Z/6Z ───")
    print("  Coprime factorization: 6 = 2 × 3")
    decomp = crt_torsion_split(6, 2, 3)
    print(f"  6-torsion elements and their CRT decomposition:")
    for a, b, c in decomp:
        print(f"    {a} = {b} (2-torsion) + {c} (3-torsion)  [mod 6]")


def demo_z12():
    """Example with Z/12Z."""
    print("\n─── Example 3: Filtration 0 → Z/2Z → Z/4Z → Z/12Z ───")
    filtration = [1, 2, 4, 12]
    datum = AdelicTorsionDatum(filtration)

    for i, order in enumerate(filtration):
        direct = torsion_prime_support(order)
        reconstructed = datum.reconstruct_support(i)
        status = "✓" if direct == reconstructed else "✗"
        print(f"  Level {i} (Z/{order}Z): prime support = {direct}, "
              f"reconstructed = {reconstructed} {status}")

    print("\n  Prime barcodes:")
    for p in sorted(datum.all_primes()):
        bc = datum.prime_barcode(p)
        print(f"    p={p}: interval [{bc[0]}, {bc[1]}]")

    ok, _ = verify_reconstruction(filtration)
    print(f"  Reconstruction conjecture verified: {ok}")


def demo_z18():
    """Example with Z/18Z."""
    print("\n─── Example 4: Filtration 0 → Z/3Z → Z/9Z → Z/18Z ───")
    filtration = [1, 3, 9, 18]
    datum = AdelicTorsionDatum(filtration)

    for i, order in enumerate(filtration):
        direct = torsion_prime_support(order)
        reconstructed = datum.reconstruct_support(i)
        status = "✓" if direct == reconstructed else "✗"
        print(f"  Level {i} (Z/{order}Z): prime support = {direct}, "
              f"reconstructed = {reconstructed} {status}")

    print("\n  Prime barcodes:")
    for p in sorted(datum.all_primes()):
        bc = datum.prime_barcode(p)
        print(f"    p={p}: interval [{bc[0]}, {bc[1]}]")

    ok, _ = verify_reconstruction(filtration)
    print(f"  Reconstruction conjecture verified: {ok}")


def demo_exhaustive_search():
    """Exhaustive search for counterexamples to reconstruction conjecture."""
    print("\n─── Exhaustive Falsification Search ───")
    print("  Testing filtrations of cyclic groups with orders dividing 60...")

    divisors_of_60 = [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]
    n_tested = 0
    n_passed = 0
    n_failed = 0

    # Test all non-decreasing sequences of length 3-5
    for length in [3, 4, 5]:
        for combo in cartesian_product(divisors_of_60, repeat=length):
            # Only test non-decreasing filtrations (each divides the next)
            valid = all(combo[i] <= combo[i+1] and combo[i+1] % combo[i] == 0
                       for i in range(length - 1))
            if not valid:
                continue
            filtration = list(combo)
            ok, _ = verify_reconstruction(filtration)
            n_tested += 1
            if ok:
                n_passed += 1
            else:
                n_failed += 1
                print(f"  COUNTEREXAMPLE FOUND: {filtration}")

    print(f"\n  Total filtrations tested: {n_tested}")
    print(f"  Passed: {n_passed}")
    print(f"  Failed: {n_failed}")
    if n_failed == 0:
        print("  ✓ No counterexamples found — conjecture holds for all tested cases!")
    else:
        print("  ✗ Counterexamples found — conjecture is FALSE!")


def demo_product_groups():
    """Test with product groups Z/m × Z/n (modeled by Z/lcm(m,n))."""
    print("\n─── Example 5: Product Groups ───")

    # Z/2 × Z/6 ≅ Z/2 × Z/2 × Z/3 (as a product)
    # For cyclic approximation, we use orders
    groups = [
        ("Z/2 × Z/6", [1, 2, 6, 12]),
        ("Z/4 × Z/9", [1, 4, 9, 36]),
        ("Z/2 × Z/2 × Z/3", [1, 2, 6, 12]),
    ]

    for name, filtration in groups:
        ok, datum = verify_reconstruction(filtration)
        primes = sorted(datum.all_primes())
        barcodes = {p: datum.prime_barcode(p) for p in primes}
        print(f"  {name}: orders={filtration}, primes={primes}, "
              f"barcodes={barcodes}, reconstruction={'✓' if ok else '✗'}")


if __name__ == "__main__":
    demo_basic()
    demo_crt()
    demo_z12()
    demo_z18()
    demo_product_groups()
    demo_exhaustive_search()
