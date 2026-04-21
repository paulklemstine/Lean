#!/usr/bin/env python3
"""
Quantum Advantage Analysis for Pell Factoring
==============================================
Analyzes the theoretical quantum speedup for Pell-sequence-based
factoring, comparing classical and quantum approaches.

Key insight: Grover's algorithm can search for the Pell rank T(p)
in O(√T(p)) ≈ O(N^{1/4}) queries for balanced semiprimes N = p·q.
"""

import math
from typing import List, Tuple, Dict

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def pell_rank(p: int) -> int:
    """Find smallest T > 0 with P_T ≡ 0 (mod p)."""
    H, P = 1, 1
    for T in range(1, 2 * p + 2):
        if P % p == 0:
            return T
        H, P = (H + 2 * P) % p, (H + P) % p
    return -1

def legendre_2(p: int) -> int:
    """Legendre symbol (2/p)."""
    return 1 if p % 8 in [1, 7] else -1

def factorize(n: int) -> List[int]:
    """Simple trial division factorization."""
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def rank_statistics():
    """Analyze Pell rank distribution and quantum advantage."""
    print("=" * 70)
    print("  PELL RANK STATISTICS AND QUANTUM ADVANTAGE")
    print("=" * 70)

    primes = [p for p in range(3, 500) if is_prime(p)]

    print(f"\n  Analyzing {len(primes)} odd primes from 3 to {primes[-1]}")
    print(f"\n  {'p':>5s} {'T(p)':>5s} {'p mod 8':>7s} {'(2/p)':>5s} {'p-(2/p)':>8s} "
          f"{'T|?':>4s} {'√T':>6s} {'speedup':>8s}")
    print(f"  {'─'*5} {'─'*5} {'─'*7} {'─'*5} {'─'*8} {'─'*4} {'─'*6} {'─'*8}")

    total_speedup = 0
    count = 0
    rank_le_20 = 0
    all_divide = True

    for p in primes[:50]:  # Show first 50
        T = pell_rank(p)
        leg = legendre_2(p)
        target = p - leg
        divides = target % T == 0
        if not divides:
            all_divide = False

        sqrt_T = math.sqrt(T)
        speedup = T / sqrt_T if T > 1 else 1

        total_speedup += speedup
        count += 1
        if T <= 20:
            rank_le_20 += 1

        print(f"  {p:5d} {T:5d} {p%8:7d} {leg:5d} {target:8d} "
              f"{'✓' if divides else '✗':>4s} {sqrt_T:6.1f} {speedup:8.1f}x")

    print(f"\n  Summary (first {count} primes):")
    print(f"    Rank divisibility holds for all: {'✓ YES' if all_divide else '✗ NO'}")
    print(f"    Primes with T(p) ≤ 20: {rank_le_20}/{count} ({100*rank_le_20/count:.1f}%)")
    print(f"    Average quantum speedup: {total_speedup/count:.1f}x")
    print()

    # Distribution analysis
    ranks = [pell_rank(p) for p in primes]
    print(f"  Full distribution (all {len(primes)} primes):")
    print(f"    Min rank: {min(ranks)}")
    print(f"    Max rank: {max(ranks)}")
    print(f"    Mean rank: {sum(ranks)/len(ranks):.1f}")
    print(f"    Median rank: {sorted(ranks)[len(ranks)//2]}")

    # Quantum advantage for balanced semiprimes
    print(f"\n  Quantum advantage for balanced semiprimes N = p·q:")
    print(f"    Classical Pell factoring: O(T(p)) ≈ O(p)")
    print(f"    BSGS Pell factoring: O(√T(p)) ≈ O(√p) ≈ O(N^{{1/4}})")
    print(f"    Grover + Pell: O(√T(p)) ≈ O(p^{{1/4}}) ≈ O(N^{{1/8}})")
    print(f"    Shor's algorithm: O((log N)^3) — polynomial")
    print()

    # Comparison table
    print(f"  {'Bit size':>10s} {'N':>15s} {'Trial':>12s} {'BSGS Pell':>12s} "
          f"{'Grover+Pell':>12s} {'Shor':>12s}")
    print(f"  {'─'*10} {'─'*15} {'─'*12} {'─'*12} {'─'*12} {'─'*12}")
    for bits in [20, 40, 80, 128, 256, 512, 1024]:
        N = 2 ** bits
        trial = N ** 0.5
        bsgs = N ** 0.25
        grover_pell = N ** 0.125
        shor = bits ** 3

        def fmt(x):
            if x < 1e6: return f"{x:.0f}"
            elif x < 1e15: return f"2^{math.log2(x):.1f}"
            else: return f"2^{math.log2(x):.0f}"

        print(f"  {bits:10d} {'2^'+str(bits):>15s} {fmt(trial):>12s} "
              f"{fmt(bsgs):>12s} {fmt(grover_pell):>12s} {fmt(shor):>12s}")
    print()


def rank_factorization_analysis():
    """Analyze the factorization structure of Pell ranks."""
    print("=" * 70)
    print("  PELL RANK FACTORIZATION STRUCTURE")
    print("=" * 70)

    primes = [p for p in range(3, 200) if is_prime(p)]

    print(f"\n  Analyzing smoothness of Pell ranks for factoring efficiency")
    print(f"\n  {'p':>4s} {'T(p)':>5s} {'factorization':>25s} {'B-smooth':>10s} {'quality':>10s}")
    print(f"  {'─'*4} {'─'*5} {'─'*25} {'─'*10} {'─'*10}")

    smooth_counts = {5: 0, 10: 0, 20: 0, 50: 0, 100: 0}
    total = len(primes)

    for p in primes:
        T = pell_rank(p)
        factors = factorize(T)
        largest = max(factors) if factors else 1
        factor_str = '·'.join(map(str, factors))

        # B-smoothness
        for B in smooth_counts:
            if largest <= B:
                smooth_counts[B] += 1

        quality = "excellent" if largest <= 5 else "good" if largest <= 20 else "fair" if largest <= 50 else "hard"

        print(f"  {p:4d} {T:5d} {factor_str:>25s} "
              f"{'≤5' if largest<=5 else '≤20' if largest<=20 else '≤50' if largest<=50 else '>50':>10s} "
              f"{quality:>10s}")

    print(f"\n  Smoothness distribution:")
    for B, count in sorted(smooth_counts.items()):
        print(f"    {B}-smooth: {count}/{total} ({100*count/total:.1f}%)")
    print()


def grover_oracle_complexity():
    """Analyze the complexity of implementing the Pell oracle for Grover's algorithm."""
    print("=" * 70)
    print("  QUANTUM ORACLE COMPLEXITY FOR PELL FACTORING")
    print("=" * 70)

    print(f"""
  The quantum oracle for Grover search needs to compute:
    f(G) = [gcd(P_G mod N, N) > 1]

  Implementation via fast-doubling:
    1. Compute P_G mod N using O(log G) modular multiplications
    2. Each modular multiplication needs O(n²) gates (n = bit length of N)
    3. Total oracle depth: O(n² log G)

  For N with n bits and expected rank T(p) ≈ O(N^{{1/2}}):
    - log G ≈ n/2 (since G ranges up to T(p))
    - Oracle depth: O(n³)
    - Grover iterations: O(√T) ≈ O(N^{{1/4}}) = O(2^{{n/4}})
    - Total circuit depth: O(n³ · 2^{{n/4}})

  Comparison with Shor:
    - Shor's circuit depth: O(n³) with O(n) qubits
    - Total: polynomial in n

  Verdict: Grover+Pell is still exponential (2^{{n/4}}) but provides
  a concrete quantum speedup over classical BSGS when Shor is unavailable.
    """)

    # Show concrete numbers
    print(f"  Concrete comparison for various key sizes:")
    print(f"  {'n bits':>8s} {'Classical BSGS':>15s} {'Grover+Pell':>15s} {'Shor':>15s}")
    print(f"  {'─'*8} {'─'*15} {'─'*15} {'─'*15}")

    for n in [64, 128, 256, 512, 1024, 2048]:
        classical = f"2^{n//4}"
        grover = f"2^{n//8}"
        shor = f"{n**3}"
        print(f"  {n:8d} {classical:>15s} {grover:>15s} {shor:>15s}")
    print()


def multi_path_advantage():
    """Analyze the advantage of multi-path ancestry for factoring."""
    print("=" * 70)
    print("  MULTI-PATH ANCESTRY FACTORING ADVANTAGE")
    print("=" * 70)

    # Berggren matrices
    B = {
        'A': ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
        'B': ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
        'C': ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
    }

    # Their inverses
    B_inv = {
        'A': ((1, 2, -2), (-2, -1, 2), (2, 2, -3)),
        'B': ((1, 2, -2), (2, 1, -2), (-2, -2, 3)),
        'C': ((-1, 2, -2), (-2, 1, -2), (-2, 2, -3)),
    }

    def mat_mul_vec(M, v):
        return tuple(sum(M[i][j] * v[j] for j in range(3)) for i in range(3))

    def apply_path(triple, path):
        """Apply a sequence of inverse Berggren matrices."""
        current = triple
        for ch in path:
            current = mat_mul_vec(B_inv[ch], current)
        return current

    # Generate all paths up to depth d
    from itertools import product as iterproduct

    print(f"\n  Exploring multi-path ghosts from (3,4,5) at depth 1-4:")
    root = (3, 4, 5)

    for depth in range(1, 5):
        paths = [''.join(p) for p in iterproduct('ABC', repeat=depth)]
        results = {}
        for path in paths:
            result = apply_path(root, path)
            a, b, c = result
            deficit = a**2 + b**2 - c**2
            results[path] = (result, deficit)

        # Count unique triples
        unique_triples = set(r[0] for r in results.values())
        zero_deficit = sum(1 for _, d in results.values() if d == 0)

        print(f"\n  Depth {depth}: {len(paths)} paths, {len(unique_triples)} unique triples, "
              f"{zero_deficit}/{len(paths)} Pythagorean")

        if depth <= 2:
            for path, (triple, deficit) in sorted(results.items()):
                print(f"    Path {path}: {triple}  deficit={deficit}")

    # Now test multi-path factoring on a specific semiprime
    print(f"\n  Multi-path factoring experiment on N=77 (=7×11):")
    N = 77
    # For each path type, iterate and check GCD of various components with N
    for branch in ['A', 'B', 'C']:
        inv = B_inv[branch]
        # Start from various triples (d, e, d*e) where d*e = N
        for d_start in range(2, 10):
            triple = (d_start, N, d_start * N)
            print(f"    Branch {branch}, start ({d_start}, {N}, {d_start*N}):")
            current = triple
            for step in range(5):
                current = mat_mul_vec(inv, current)
                a, b, c = current
                g1 = math.gcd(abs(a), N)
                g2 = math.gcd(abs(b), N)
                g3 = math.gcd(abs(c), N)
                if 1 < g1 < N or 1 < g2 < N:
                    print(f"      Step {step+1}: ({a},{b},{c}) "
                          f"gcd(a,N)={g1}, gcd(b,N)={g2} ← FACTOR!")
                    break
            else:
                print(f"      No factor in 5 steps")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  QUANTUM ADVANTAGE ANALYSIS FOR PELL FACTORING")
    print("=" * 70 + "\n")

    rank_statistics()
    rank_factorization_analysis()
    grover_oracle_complexity()
    multi_path_advantage()

    print("=" * 70)
    print("  Analysis complete!")
    print("=" * 70)
