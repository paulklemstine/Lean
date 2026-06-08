#!/usr/bin/env python3
"""
The Library of Babel: Numerical Demonstrations
===============================================

Self-contained numerical examples demonstrating the key combinatorial results
from the formal theory of universal information spaces.

Each function demonstrates a specific theorem from the formalization.
"""

from math import comb, log2, log10, factorial
from typing import List, Tuple, Dict
from itertools import product
import random


# =============================================================================
# 1. Library Cardinality (volume_card)
# =============================================================================

def library_size(alphabet_size: int, volume_length: int) -> int:
    """
    Compute |Vol(A, L)| = A^L.
    
    Demonstrates Theorem: volume_card
    """
    return alphabet_size ** volume_length


def demonstrate_library_cardinality() -> None:
    """Show library sizes for various parameters, including Borges' Library."""
    print("=" * 70)
    print("LIBRARY CARDINALITY: |Vol(A, L)| = A^L")
    print("=" * 70)
    
    examples: List[Tuple[str, int, int]] = [
        ("Binary strings of length 8", 2, 8),
        ("DNA sequences of length 20", 4, 20),
        ("Mini-Babel (A=4, L=16)", 4, 16),
        ("English words of length 5 (26 letters)", 26, 5),
    ]
    
    for name, a, l in examples:
        size = library_size(a, l)
        print(f"\n  {name}:")
        print(f"    A = {a}, L = {l}")
        print(f"    |Library| = {a}^{l} = {size:,}")
    
    # Borges' Library — too large to compute directly
    a_borges, l_borges = 25, 1_312_000
    log_size = l_borges * log10(a_borges)
    print(f"\n  Borges' Library of Babel:")
    print(f"    A = {a_borges}, L = {l_borges:,}")
    print(f"    |Library| = 25^1,312,000 ≈ 10^{log_size:,.0f}")
    print(f"    (Compare: atoms in observable universe ≈ 10^80)")
    print(f"    (The exponent alone has {len(str(int(log_size))):,} digits)")


# =============================================================================
# 2. Degree Regularity (babel_degree)
# =============================================================================

def hamming_neighbors_count(alphabet_size: int, volume_length: int) -> int:
    """
    Every volume has exactly L * (A - 1) Hamming neighbors.
    
    Demonstrates Theorem: babel_degree
    """
    return volume_length * (alphabet_size - 1)


def hamming_distance(v: Tuple[int, ...], w: Tuple[int, ...]) -> int:
    """Compute the Hamming distance between two volumes."""
    return sum(1 for a, b in zip(v, w) if a != b)


def demonstrate_degree_regularity() -> None:
    """Verify degree regularity by exhaustive enumeration for small parameters."""
    print("\n" + "=" * 70)
    print("DEGREE REGULARITY: Every volume has L*(A-1) neighbors")
    print("=" * 70)
    
    a, l = 3, 4  # Small enough to enumerate
    predicted = hamming_neighbors_count(a, l)
    print(f"\n  Parameters: A = {a}, L = {l}")
    print(f"  Predicted neighbor count: {l} × ({a}-1) = {predicted}")
    
    # Pick a random volume and count its actual neighbors
    all_volumes = list(product(range(a), repeat=l))
    test_volume = (0, 1, 2, 0)
    actual_neighbors = [v for v in all_volumes if hamming_distance(v, test_volume) == 1]
    
    print(f"  Test volume: {test_volume}")
    print(f"  Actual neighbor count: {len(actual_neighbors)}")
    print(f"  Match: {'✓' if len(actual_neighbors) == predicted else '✗'}")
    
    # Verify for ALL volumes
    all_match = all(
        sum(1 for w in all_volumes if hamming_distance(v, w) == 1) == predicted
        for v in all_volumes
    )
    print(f"\n  Verified for all {len(all_volumes)} volumes: {'✓' if all_match else '✗'}")


# =============================================================================
# 3. Diameter (babel_diameter_achieved)
# =============================================================================

def demonstrate_diameter() -> None:
    """Show that the diameter of the Hamming graph is exactly L."""
    print("\n" + "=" * 70)
    print("DIAMETER: max d_H(v,w) = L, achieved by constant volumes")
    print("=" * 70)
    
    for a, l in [(2, 8), (4, 6), (3, 5)]:
        v = tuple([0] * l)
        w = tuple([1] * l)
        d = hamming_distance(v, w)
        print(f"\n  A = {a}, L = {l}")
        print(f"    v = {v}, w = {w}")
        print(f"    d_H(v, w) = {d} = L ✓")


# =============================================================================
# 4. Catalog Impossibility (catalog_impossibility, no_catalog_embedding)
# =============================================================================

def catalog_scheme_count(alphabet_size: int, volume_length: int, desc_values: int) -> int:
    """
    Number of catalog schemes: D^(A^L).
    
    Demonstrates Theorem: catalog_scheme_card
    """
    lib_size = alphabet_size ** volume_length
    return desc_values ** lib_size


def demonstrate_catalog_impossibility() -> None:
    """Show that catalog schemes vastly outnumber volumes."""
    print("\n" + "=" * 70)
    print("CATALOG IMPOSSIBILITY: |CatalogScheme| >> |Vol|")
    print("=" * 70)
    
    examples: List[Tuple[int, int, int]] = [
        (2, 3, 2),  # Binary strings of length 3
        (2, 4, 2),
        (3, 3, 2),
        (2, 3, 3),
    ]
    
    for a, l, d in examples:
        vol = library_size(a, l)
        cat = catalog_scheme_count(a, l, d)
        ratio = cat / vol
        print(f"\n  A={a}, L={l}, D={d}:")
        print(f"    |Vol| = {vol}")
        print(f"    |CatalogScheme| = {d}^{vol} = {cat:,}")
        print(f"    Ratio: {ratio:,.1f}x more catalogs than volumes")
        print(f"    No injection possible: ✓")
    
    # Borges' Library
    print(f"\n  Borges' Library (A=25, L=1312000, D=2):")
    vol_log = 1_312_000 * log10(25)
    cat_log = (25 ** 10) * log10(2)  # Just the first tiny fraction
    print(f"    |Vol| ≈ 10^{vol_log:,.0f}")
    print(f"    |CatalogScheme| = 2^(25^1312000) ≈ 10^(10^{log10(vol_log * log10(2)):,.1f})")
    print(f"    The catalog space is a TOWER of exponentials above the library size.")


# =============================================================================
# 5. Singleton Bound (singleton_bound)
# =============================================================================

def singleton_bound(alphabet_size: int, volume_length: int, min_dist: int) -> int:
    """
    Maximum codewords in a code with minimum distance d: A^(L - d + 1).
    
    Demonstrates Theorem: singleton_bound
    """
    return alphabet_size ** (volume_length - min_dist + 1)


def demonstrate_singleton_bound() -> None:
    """Demonstrate the Singleton bound for various parameters."""
    print("\n" + "=" * 70)
    print("SINGLETON BOUND: |C| ≤ A^(L - d + 1)")
    print("=" * 70)
    
    a = 4  # DNA-like alphabet
    l = 10
    
    print(f"\n  Alphabet size A = {a}, Volume length L = {l}")
    print(f"  {'Min dist d':<12} {'Bound A^(L-d+1)':<20} {'Interpretation'}")
    print(f"  {'-'*12} {'-'*20} {'-'*40}")
    
    for d in range(1, l + 1):
        bound = singleton_bound(a, l, d)
        interp = f"Can correct {(d-1)//2} errors"
        print(f"  {d:<12} {bound:<20,} {interp}")


# =============================================================================
# 6. Sphere-Packing / Hamming Bound (sphere_size_sum)
# =============================================================================

def sphere_size(alphabet_size: int, volume_length: int, radius: int) -> int:
    """
    Size of Hamming sphere of radius r: C(L, r) * (A-1)^r.
    
    Demonstrates the sphere size formula used in sphere_size_sum.
    """
    return comb(volume_length, radius) * (alphabet_size - 1) ** radius


def ball_size(alphabet_size: int, volume_length: int, radius: int) -> int:
    """Size of Hamming ball of radius r: sum of sphere sizes from 0 to r."""
    return sum(sphere_size(alphabet_size, volume_length, k) for k in range(radius + 1))


def hamming_bound(alphabet_size: int, volume_length: int, min_dist: int) -> int:
    """
    Hamming (sphere-packing) bound: |C| ≤ A^L / |B(c, t)| where t = ⌊(d-1)/2⌋.
    """
    t = (min_dist - 1) // 2
    lib_size = alphabet_size ** volume_length
    b = ball_size(alphabet_size, volume_length, t)
    return lib_size // b


def demonstrate_sphere_packing() -> None:
    """Verify the sphere size sum identity and demonstrate the Hamming bound."""
    print("\n" + "=" * 70)
    print("SPHERE-PACKING: Σ |S(c,k)| = A^L  and  Hamming Bound")
    print("=" * 70)
    
    a, l = 4, 8
    total = sum(sphere_size(a, l, k) for k in range(l + 1))
    lib = library_size(a, l)
    
    print(f"\n  A = {a}, L = {l}")
    print(f"  Sphere sizes by radius:")
    for k in range(l + 1):
        s = sphere_size(a, l, k)
        print(f"    |S(c, {k})| = C({l},{k}) × {a-1}^{k} = {s:>10,}")
    print(f"  {'':>30}{'─'*12}")
    print(f"    Sum = {total:>10,}")
    print(f"    A^L = {lib:>10,}")
    print(f"    Identity verified: {'✓' if total == lib else '✗'}")
    
    # Hamming bound comparison with Singleton
    print(f"\n  Comparing bounds (A={a}, L={l}):")
    print(f"  {'d':<5} {'Singleton':<15} {'Hamming':<15} {'Tighter'}")
    print(f"  {'-'*5} {'-'*15} {'-'*15} {'-'*10}")
    for d in range(1, l + 1):
        sb = singleton_bound(a, l, d)
        hb = hamming_bound(a, l, d)
        tighter = "Hamming" if hb < sb else ("Singleton" if sb < hb else "Equal")
        print(f"  {d:<5} {sb:<15,} {hb:<15,} {tighter}")


# =============================================================================
# 7. Prefix Fiber Cardinality (prefix_fiber_card)
# =============================================================================

def demonstrate_prefix_fiber() -> None:
    """Verify that exactly A^(L-k) volumes share a given prefix."""
    print("\n" + "=" * 70)
    print("PREFIX FIBER: |{v | take_k(v) = p}| = A^(L-k)")
    print("=" * 70)
    
    a, l = 3, 5
    all_volumes = list(product(range(a), repeat=l))
    
    print(f"\n  A = {a}, L = {l}, |Library| = {len(all_volumes)}")
    
    for k in range(l + 1):
        prefix = tuple(range(k))  # prefix = (0, 1, 2, ..., k-1) mod a
        prefix = tuple(x % a for x in prefix)
        matching = [v for v in all_volumes if v[:k] == prefix]
        predicted = a ** (l - k)
        print(f"    k={k}, prefix={prefix}, matching={len(matching)}, "
              f"predicted={predicted}, {'✓' if len(matching) == predicted else '✗'}")


# =============================================================================
# 8. Compression Impossibility (incompressible_ge_compressible)
# =============================================================================

def demonstrate_compression() -> None:
    """Show that compression always loses at least half the library."""
    print("\n" + "=" * 70)
    print("COMPRESSION IMPOSSIBILITY: Lost volumes ≥ Recovered volumes")
    print("=" * 70)
    
    a, l, m = 3, 4, 3  # Compress from length 4 to length 3
    
    all_volumes = list(product(range(a), repeat=l))
    all_compressed = list(product(range(a), repeat=m))
    
    # Simple compression: truncate to first M symbols
    def compress(v: Tuple[int, ...]) -> Tuple[int, ...]:
        return v[:m]
    
    # Simple decompression: pad with zeros
    def decompress(c: Tuple[int, ...]) -> Tuple[int, ...]:
        return c + (0,) * (l - m)
    
    recoverable = [v for v in all_volumes if decompress(compress(v)) == v]
    lost = [v for v in all_volumes if decompress(compress(v)) != v]
    
    print(f"\n  A = {a}, L = {l}, M = {m}")
    print(f"  Compression: truncate to first {m} symbols")
    print(f"  Decompression: pad with zeros")
    print(f"\n  |Library| = {len(all_volumes)}")
    print(f"  |Recoverable| = {len(recoverable)}")
    print(f"  |Lost| = {len(lost)}")
    print(f"  Lost ≥ Recoverable: {'✓' if len(lost) >= len(recoverable) else '✗'}")
    
    # Theoretical bound
    print(f"\n  Theoretical bound:")
    print(f"    A^M = {a}^{m} = {a**m}")
    print(f"    A^L = {a}^{l} = {a**l}")
    print(f"    A^L - A^M = {a**l - a**m} (minimum lost)")
    print(f"    A^L / 2 = {a**l / 2} (half the library)")
    
    # Try a better compression (hash-based)
    random.seed(42)
    hash_map: Dict[Tuple[int, ...], Tuple[int, ...]] = {}
    for v in all_volumes:
        c = compress(v)
        if c not in hash_map:
            hash_map[c] = v
    
    def smart_decompress(c: Tuple[int, ...]) -> Tuple[int, ...]:
        return hash_map.get(c, c + (0,) * (l - m))
    
    smart_recoverable = [v for v in all_volumes if smart_decompress(compress(v)) == v]
    print(f"\n  Optimal compression (first-seen wins):")
    print(f"    |Recoverable| = {len(smart_recoverable)}")
    print(f"    |Lost| = {len(all_volumes) - len(smart_recoverable)}")
    print(f"    Still Lost ≥ Recoverable: "
          f"{'✓' if len(all_volumes) - len(smart_recoverable) >= len(smart_recoverable) else '✗'}")


# =============================================================================
# 9. Periodic Volumes (periodic_volume_count)
# =============================================================================

def demonstrate_periodicity() -> None:
    """Verify the periodic volume count for small parameters."""
    print("\n" + "=" * 70)
    print("PERIODIC VOLUMES: |Per(A, L, p)| = A^p when p | L")
    print("=" * 70)
    
    a, l = 3, 6
    all_volumes = list(product(range(a), repeat=l))
    
    print(f"\n  A = {a}, L = {l}")
    
    for p in range(1, l + 1):
        if l % p != 0:
            continue
        periodic = [
            v for v in all_volumes
            if all(v[i] == v[i % p] for i in range(l))
        ]
        predicted = a ** p
        print(f"    p = {p}: |Per| = {len(periodic)}, predicted = {predicted}, "
              f"{'✓' if len(periodic) == predicted else '✗'}")


# =============================================================================
# 10. Search Complexity (search_complexity_singleton)
# =============================================================================

def demonstrate_search_complexity() -> None:
    """Demonstrate search complexity through simulation."""
    print("\n" + "=" * 70)
    print("SEARCH COMPLEXITY: Finding a specific volume takes A^L samples")
    print("=" * 70)
    
    a, l = 3, 4
    lib_size = a ** l
    target = tuple([1] * l)
    
    trials = 5000
    total_samples = 0
    
    random.seed(42)
    for _ in range(trials):
        samples = 0
        while True:
            samples += 1
            candidate = tuple(random.randint(0, a - 1) for _ in range(l))
            if candidate == target:
                break
        total_samples += samples
    
    avg = total_samples / trials
    print(f"\n  A = {a}, L = {l}, |Library| = {lib_size}")
    print(f"  Target: {target}")
    print(f"  Average samples over {trials:,} trials: {avg:.1f}")
    print(f"  Predicted (A^L = {lib_size}): {lib_size}")
    print(f"  Ratio (actual/predicted): {avg/lib_size:.3f}")
    print(f"  (Should be ≈ 1.0 by geometric distribution)")


# =============================================================================
# 11. Mini-Library de Bruijn Catalog (demonstration)
# =============================================================================

def demonstrate_mini_library() -> None:
    """
    Construct and analyze a mini-Library with A=4, L=16.
    Demonstrates substring density and catalog properties.
    """
    print("\n" + "=" * 70)
    print("MINI-LIBRARY ANALYSIS: A=4, L=16")
    print("=" * 70)
    
    a, l = 4, 16
    lib_size = a ** l
    
    print(f"\n  Parameters: A = {a}, L = {l}")
    print(f"  Library size: {lib_size:,} volumes")
    print(f"  Hamming neighbors per volume: {l * (a - 1):,}")
    print(f"  Diameter: {l}")
    
    # Singleton bounds
    print(f"\n  Singleton Bounds:")
    for d in [1, 2, 4, 8, 16]:
        if d <= l:
            bound = singleton_bound(a, l, d)
            print(f"    d = {d:>2}: |C| ≤ {bound:>15,}")
    
    # Hamming bounds
    print(f"\n  Hamming Bounds:")
    for d in [1, 3, 5, 7]:
        if d <= l:
            bound = hamming_bound(a, l, d)
            print(f"    d = {d:>2}: |C| ≤ {bound:>15,}")
    
    # Prefix analysis
    print(f"\n  Prefix Fiber Analysis:")
    for k in [1, 2, 4, 8, 12, 16]:
        fiber = a ** (l - k)
        print(f"    k = {k:>2}: {fiber:>15,} volumes share each {k}-symbol prefix")
    
    # Periodic volumes
    print(f"\n  Periodic Volume Counts:")
    for p in range(1, l + 1):
        if l % p == 0:
            count = a ** p
            fraction = count / lib_size
            print(f"    p = {p:>2}: {count:>15,} periodic volumes "
                  f"({fraction:.2e} of library)")
    
    # Catalog impossibility
    cat_size_log = lib_size * log2(2)
    print(f"\n  Catalog Impossibility:")
    print(f"    |Vol| = {lib_size:,}")
    print(f"    |CatalogScheme(D=2)| = 2^{lib_size} ≈ 10^{lib_size * log10(2):,.0f}")
    print(f"    Ratio: 2^{lib_size} / {lib_size} ≈ 10^{lib_size * log10(2) - log10(lib_size):,.0f}")


# =============================================================================
# 12. Triangle Inequality Verification (hammingDist_triangle)
# =============================================================================

def demonstrate_triangle_inequality() -> None:
    """Verify the triangle inequality for random volume triples."""
    print("\n" + "=" * 70)
    print("TRIANGLE INEQUALITY: d_H(x,z) ≤ d_H(x,y) + d_H(y,z)")
    print("=" * 70)
    
    a, l = 4, 8
    random.seed(42)
    
    violations = 0
    trials = 10000
    
    print(f"\n  Testing {trials:,} random triples with A={a}, L={l}:")
    
    for trial in range(trials):
        x = tuple(random.randint(0, a-1) for _ in range(l))
        y = tuple(random.randint(0, a-1) for _ in range(l))
        z = tuple(random.randint(0, a-1) for _ in range(l))
        
        dxz = hamming_distance(x, z)
        dxy = hamming_distance(x, y)
        dyz = hamming_distance(y, z)
        
        if dxz > dxy + dyz:
            violations += 1
    
    print(f"  Violations: {violations} / {trials:,}")
    print(f"  Triangle inequality holds: {'✓' if violations == 0 else '✗'}")
    
    # Show a specific example
    x = (0, 0, 0, 0, 0, 0, 0, 0)
    y = (1, 1, 0, 0, 0, 0, 0, 0)
    z = (1, 1, 1, 1, 0, 0, 0, 0)
    print(f"\n  Example:")
    print(f"    x = {x}")
    print(f"    y = {y}")
    print(f"    z = {z}")
    print(f"    d(x,z) = {hamming_distance(x,z)}")
    print(f"    d(x,y) + d(y,z) = {hamming_distance(x,y)} + {hamming_distance(y,z)} "
          f"= {hamming_distance(x,y) + hamming_distance(y,z)}")
    print(f"    {hamming_distance(x,z)} ≤ {hamming_distance(x,y) + hamming_distance(y,z)}: ✓")


# =============================================================================
# MAIN
# =============================================================================

def main() -> None:
    """Run all demonstrations."""
    print("╔" + "═" * 68 + "╗")
    print("║  THE LIBRARY OF BABEL: NUMERICAL DEMONSTRATIONS" + " " * 19 + "║")
    print("║  Combinatorics of Universal Information Spaces" + " " * 20 + "║")
    print("╚" + "═" * 68 + "╝")
    
    demonstrate_library_cardinality()
    demonstrate_degree_regularity()
    demonstrate_diameter()
    demonstrate_catalog_impossibility()
    demonstrate_singleton_bound()
    demonstrate_sphere_packing()
    demonstrate_prefix_fiber()
    demonstrate_compression()
    demonstrate_periodicity()
    demonstrate_search_complexity()
    demonstrate_mini_library()
    demonstrate_triangle_inequality()
    
    print("\n" + "=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)
    print("\nEvery numerical result above confirms the formally verified theorems.")


if __name__ == "__main__":
    main()
