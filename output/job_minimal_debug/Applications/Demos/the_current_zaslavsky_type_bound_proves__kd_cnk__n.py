#!/usr/bin/env python3
"""
Numerical demonstrations of PL Hodge Theory for Neural Networks.

Demonstrates:
  1. The Zaslavsky function Z(m,n) and its bounds
  2. Depth efficiency: deep vs. shallow region counts
  3. The Sauer-Shelah identity: shatter function = Zaslavsky function
  4. Polyhedral Euler characteristic bounds
  5. Network architecture comparison

All functions are self-contained — no external dependencies beyond the
Python standard library.
"""

from math import comb, factorial, log2
from typing import List, Tuple, Dict


# ──────────────────────────────────────────────────────────────────────
# Section 1: The Zaslavsky Function
# ──────────────────────────────────────────────────────────────────────

def zaslavsky(m: int, n: int) -> int:
    """
    Compute Z(m, n) = sum_{k=0}^{n} C(m, k).

    This counts the maximum number of regions created by m hyperplanes
    in general position in R^n.
    """
    return sum(comb(m, k) for k in range(n + 1))


def shatter_fn(m: int, n: int) -> int:
    """
    Compute the shatter function recursively.

    shatterFn(_, 0) = 1
    shatterFn(0, _) = 1
    shatterFn(m+1, n+1) = shatterFn(m, n+1) + shatterFn(m, n)
    """
    if m == 0 or n == 0:
        return 1
    return shatter_fn(m - 1, n) + shatter_fn(m - 1, n - 1)


def demo_zaslavsky_function() -> None:
    """Demonstrate the Zaslavsky function and verify key properties."""
    print("=" * 70)
    print("DEMO 1: The Zaslavsky Function Z(m, n)")
    print("=" * 70)

    # Table of Z(m, n) values
    print("\nZ(m, n) table (m = rows, n = columns):")
    header = 'm\\n'
    print(f"{header:>6}", end="")
    for n in range(8):
        print(f"{n:>8}", end="")
    print()
    print("-" * 70)

    for m in range(10):
        print(f"{m:>6}", end="")
        for n in range(8):
            print(f"{zaslavsky(m, n):>8}", end="")
        print()

    # Verify Pascal recurrence: Z(m+1, n+1) = Z(m, n+1) + Z(m, n)
    print("\nVerifying Pascal recurrence Z(m+1,n+1) = Z(m,n+1) + Z(m,n):")
    all_pass = True
    for m in range(15):
        for n in range(15):
            lhs = zaslavsky(m + 1, n + 1)
            rhs = zaslavsky(m, n + 1) + zaslavsky(m, n)
            if lhs != rhs:
                print(f"  FAIL: m={m}, n={n}: {lhs} != {rhs}")
                all_pass = False
    print(f"  All checks passed: {all_pass}")

    # Verify bounds
    print("\nVerifying bounds for m=0..20, n=0..10:")
    for m in range(21):
        for n in range(11):
            z = zaslavsky(m, n)
            assert z <= 2 ** m, f"Z({m},{n}) = {z} > 2^{m} = {2**m}"
            assert z <= (m + 1) ** n, f"Z({m},{n}) = {z} > ({m}+1)^{n} = {(m+1)**n}"
            if m <= n:
                assert z == 2 ** m, f"Z({m},{n}) = {z} != 2^{m} (saturation)"
    print("  All bounds verified ✓")

    # Show tightness examples
    print("\nBound tightness examples (fixed n=3):")
    print(f"{'m':>6} {'Z(m,3)':>10} {'(m+1)^3':>10} {'2^m':>10} {'ratio':>8}")
    for m in [5, 10, 20, 50, 100]:
        z = zaslavsky(m, 3)
        poly = (m + 1) ** 3
        expo = 2 ** m
        ratio = z / poly
        print(f"{m:>6} {z:>10} {poly:>10} {expo:>10} {ratio:>8.4f}")


# ──────────────────────────────────────────────────────────────────────
# Section 2: Depth Efficiency
# ──────────────────────────────────────────────────────────────────────

def deep_bound(w: int, d: int, L: int) -> int:
    """Deep network region bound: Z(w, d)^L."""
    return zaslavsky(w, d) ** L


def shallow_bound(N: int, d: int) -> int:
    """Shallow network region bound: Z(N, d)."""
    return zaslavsky(N, d)


def demo_depth_efficiency() -> None:
    """Demonstrate the exponential gap between deep and shallow networks."""
    print("\n" + "=" * 70)
    print("DEMO 2: Depth Efficiency Theorem")
    print("=" * 70)

    print("\nFor w ≤ d, deep bound = 2^(wL), shallow bound ≤ (wL+1)^d")
    print(f"\n{'w':>4} {'d':>4} {'L':>4} {'N=wL':>6} {'Deep 2^N':>14} "
          f"{'Shallow≤':>14} {'Ratio':>12}")
    print("-" * 70)

    configs = [
        (3, 5, 4),
        (5, 5, 5),
        (5, 10, 6),
        (10, 10, 5),
        (10, 10, 10),
        (8, 10, 8),
    ]

    for w, d, L in configs:
        N = w * L
        deep = deep_bound(w, d, L)
        shallow_ub = (N + 1) ** d
        if w <= d:
            assert deep == 2 ** (w * L), "Deep bound should equal 2^(wL)"
        ratio = deep / shallow_ub if shallow_ub > 0 else float('inf')
        print(f"{w:>4} {d:>4} {L:>4} {N:>6} {deep:>14.3e} "
              f"{shallow_ub:>14.3e} {ratio:>12.1e}")

    # Detailed example
    print("\nDetailed example: w=10, d=10, varying depth L")
    print(f"{'L':>4} {'N':>6} {'log2(deep)':>12} {'log2(shallow_ub)':>18} {'gap':>10}")
    print("-" * 55)
    for L in range(1, 11):
        w, d = 10, 10
        N = w * L
        deep_log = w * L  # log2(2^(wL))
        shallow_ub = (N + 1) ** d
        shallow_log = log2(shallow_ub) if shallow_ub > 0 else 0
        gap = deep_log - shallow_log
        print(f"{L:>4} {N:>6} {deep_log:>12.1f} {shallow_log:>18.1f} {gap:>10.1f}")


# ──────────────────────────────────────────────────────────────────────
# Section 3: Sauer-Shelah Identity
# ──────────────────────────────────────────────────────────────────────

def demo_sauer_shelah() -> None:
    """Verify that shatterFn(m, n) = Z(m, n) for small values."""
    print("\n" + "=" * 70)
    print("DEMO 3: Sauer-Shelah Identity (shatterFn = Z)")
    print("=" * 70)

    print("\nVerifying shatterFn(m, n) = Z(m, n) for m, n = 0..12:")
    all_pass = True
    count = 0
    for m in range(13):
        for n in range(13):
            sf = shatter_fn(m, n)
            zf = zaslavsky(m, n)
            if sf != zf:
                print(f"  FAIL: m={m}, n={n}: shatterFn={sf}, Z={zf}")
                all_pass = False
            count += 1
    print(f"  Checked {count} pairs. All equal: {all_pass}")

    print("\nInterpretation:")
    print("  Z(n, d) = max labelings of n points with VC-dim ≤ d classifiers")
    print("  = max regions from n hyperplanes in R^d")
    print()
    print("  Examples:")
    for n, d in [(10, 2), (20, 3), (50, 5), (100, 10)]:
        z = zaslavsky(n, d)
        total = 2 ** n
        frac = z / total * 100
        print(f"    n={n:>3}, d={d:>2}: Z = {z:>12,} out of 2^n = {total:>30,} "
              f"({frac:.4f}%)")


# ──────────────────────────────────────────────────────────────────────
# Section 4: Euler Characteristic Bounds
# ──────────────────────────────────────────────────────────────────────

def euler_characteristic(f_vector: List[int]) -> int:
    """Compute Euler characteristic χ = Σ (-1)^k f_k."""
    return sum((-1) ** k * f for k, f in enumerate(f_vector))


def total_faces(f_vector: List[int]) -> int:
    """Total face count."""
    return sum(f_vector)


def demo_euler_characteristic() -> None:
    """Demonstrate the Euler characteristic bound |χ| ≤ total faces."""
    print("\n" + "=" * 70)
    print("DEMO 4: Euler Characteristic Bounds")
    print("=" * 70)

    # Example polyhedral complexes
    examples: List[Tuple[str, List[int]]] = [
        ("Triangle (2-simplex)", [3, 3, 1]),
        ("Square", [4, 4, 1]),
        ("Tetrahedron surface", [4, 6, 4]),
        ("Cube surface", [8, 12, 6]),
        ("Octahedron surface", [6, 12, 8]),
        ("Torus triangulation", [7, 21, 14]),
        ("Klein bottle", [8, 24, 16]),
        ("ReLU net (2→4→1)", [9, 12, 4]),
        ("ReLU net (3→8→4→1)", [27, 54, 36, 8]),
    ]

    print(f"\n{'Complex':>30} {'f-vector':>25} {'χ':>6} {'|χ|':>6} "
          f"{'Σf_k':>8} {'|χ|≤Σf_k':>10}")
    print("-" * 90)

    for name, fvec in examples:
        chi = euler_characteristic(fvec)
        total = total_faces(fvec)
        check = abs(chi) <= total
        fvec_str = str(fvec)
        print(f"{name:>30} {fvec_str:>25} {chi:>6} {abs(chi):>6} "
              f"{total:>8} {'✓' if check else '✗':>10}")


# ──────────────────────────────────────────────────────────────────────
# Section 5: Network Architecture Comparison
# ──────────────────────────────────────────────────────────────────────

def network_region_bound(input_dim: int, hidden_widths: List[int]) -> int:
    """Compute the product-of-Zaslavsky region bound for a network."""
    result = 1
    for w in hidden_widths:
        result *= zaslavsky(w, input_dim)
    return result


def hodge_number_bound(w1: int, wL: int, p: int, q: int) -> int:
    """Upper bound on (p,q)-Hodge number: C(w1, p) * C(wL, q)."""
    return comb(w1, p) * comb(wL, q)


def demo_architecture_comparison() -> None:
    """Compare region bounds for different network architectures."""
    print("\n" + "=" * 70)
    print("DEMO 5: Network Architecture Comparison")
    print("=" * 70)

    input_dim = 5

    architectures: List[Tuple[str, int, List[int]]] = [
        ("Shallow-20", 5, [20]),
        ("2-layer (10,10)", 5, [10, 10]),
        ("4-layer (5,5,5,5)", 5, [5, 5, 5, 5]),
        ("5-layer (4,4,4,4,4)", 5, [4, 4, 4, 4, 4]),
        ("10-layer (2,2,2,2,2,2,2,2,2,2)", 5, [2] * 10),
        ("Bottleneck (10,3,10)", 5, [10, 3, 10]),
        ("Pyramid (16,8,4,2)", 5, [16, 8, 4, 2]),
    ]

    print(f"\nInput dimension d = {input_dim}")
    print(f"\n{'Architecture':>40} {'N':>5} {'Regions≤':>14} {'log2':>8} "
          f"{'2^N':>14} {'Efficiency':>10}")
    print("-" * 95)

    for name, d, widths in architectures:
        N = sum(widths)
        regions = network_region_bound(d, widths)
        log_regions = log2(regions) if regions > 0 else 0
        max_regions = 2 ** N
        efficiency = regions / max_regions * 100
        print(f"{name:>40} {N:>5} {regions:>14,} {log_regions:>8.1f} "
              f"{max_regions:>14,} {efficiency:>9.2f}%")

    # Hodge number bounds
    print("\n\nHodge number bounds C(w₁,p)·C(w_L,q) for w₁=w_L=8:")
    print(f"{'(p,q)':>10} {'h^{p,q} ≤':>12} {'2^w₁·2^w_L':>14}")
    print("-" * 40)
    w1, wL = 8, 8
    for p in range(5):
        for q in range(5):
            h = hodge_number_bound(w1, wL, p, q)
            if h > 0:
                print(f"({p},{q}):".rjust(10) + f"{h:>12}" + f"{2**w1 * 2**wL:>14}")


# ──────────────────────────────────────────────────────────────────────
# Section 6: Asymptotic Analysis
# ──────────────────────────────────────────────────────────────────────

def demo_asymptotics() -> None:
    """Demonstrate asymptotic behavior of Z(m, n) for fixed n."""
    print("\n" + "=" * 70)
    print("DEMO 6: Asymptotic Analysis — Z(m,n) ~ m^n/n! for fixed n")
    print("=" * 70)

    for n in [2, 3, 5]:
        print(f"\nFixed n = {n}:")
        print(f"{'m':>8} {'Z(m,n)':>14} {'m^n/n!':>14} {'ratio':>10} "
              f"{'(m+1)^n':>14}")
        print("-" * 65)
        for m in [10, 20, 50, 100, 500, 1000]:
            z = zaslavsky(m, n)
            asymp = m ** n / factorial(n)
            ratio = z / asymp if asymp > 0 else 0
            poly = (m + 1) ** n
            print(f"{m:>8} {z:>14,} {asymp:>14,.1f} {ratio:>10.6f} {poly:>14,}")


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_zaslavsky_function()
    demo_depth_efficiency()
    demo_sauer_shelah()
    demo_euler_characteristic()
    demo_architecture_comparison()
    demo_asymptotics()
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
