#!/usr/bin/env python3
"""
Higher-Dimensional Pythagorean Extensions
==========================================
Explores generalizations of the Berggren tree to:
1. Pythagorean quadruples (a² + b² + c² = d²)
2. Higher k-tuples
3. Connections to Hurwitz composition algebras

Key discovery: The k=4 descent identity
  (d-b-c)² + (d-a-c)² + (d-a-b)² = (2d-a-b-c)²
provides a direct analog of the ghost map for quadruples.
"""

import math
from typing import List, Tuple, Optional
from itertools import product as iterproduct


def find_pythagorean_quadruples(max_d: int) -> List[Tuple[int, int, int, int]]:
    """Find all primitive Pythagorean quadruples with d ≤ max_d."""
    quads = []
    for d in range(3, max_d + 1):
        for a in range(1, d):
            for b in range(a, d):
                c2 = d * d - a * a - b * b
                if c2 <= 0:
                    continue
                c = int(math.isqrt(c2))
                if c * c == c2 and b <= c < d:
                    if math.gcd(math.gcd(a, b), math.gcd(c, d)) == 1:
                        quads.append((a, b, c, d))
    return quads


def k4_descent(a: int, b: int, c: int, d: int) -> Tuple[int, int, int, int]:
    """Apply the k=4 descent: (d-b-c, d-a-c, d-a-b, 2d-a-b-c)."""
    return (d - b - c, d - a - c, d - a - b, 2 * d - a - b - c)


def verify_quadruple(a, b, c, d) -> bool:
    return a * a + b * b + c * c == d * d


def demo_quadruples():
    """Explore Pythagorean quadruples and their descent."""
    print("=" * 70)
    print("  PYTHAGOREAN QUADRUPLES AND k=4 DESCENT")
    print("=" * 70)

    quads = find_pythagorean_quadruples(50)
    print(f"\n  Found {len(quads)} primitive Pythagorean quadruples with d ≤ 50")
    print(f"\n  {'(a,b,c,d)':>20s} {'a²+b²+c²':>12s} {'d²':>8s} {'descent':>25s} {'valid':>6s}")
    print(f"  {'─'*20} {'─'*12} {'─'*8} {'─'*25} {'─'*6}")

    for a, b, c, d in quads[:20]:
        desc = k4_descent(a, b, c, d)
        sum_sq = a*a + b*b + c*c
        is_valid = verify_quadruple(*desc)
        print(f"  ({a:2d},{b:2d},{c:2d},{d:2d}){' '*5} {sum_sq:12d} {d*d:8d} "
              f"({desc[0]:3d},{desc[1]:3d},{desc[2]:3d},{desc[3]:3d}) {'✓' if is_valid else '✗':>6s}")

    # Iterate descent
    print(f"\n  Iterated descent from (1, 2, 2, 3):")
    quad = (1, 2, 2, 3)
    for step in range(8):
        a, b, c, d = quad
        is_valid = verify_quadruple(a, b, c, d)
        print(f"    Step {step}: ({a}, {b}, {c}, {d})  valid={is_valid}")
        quad = k4_descent(a, b, c, d)
        if all(x == 0 for x in quad):
            print(f"    Step {step+1}: (0, 0, 0, 0) — TERMINATED")
            break

    # Check descent from larger quadruples
    print(f"\n  Descent chains from various quadruples:")
    for a0, b0, c0, d0 in quads[:10]:
        chain = [(a0, b0, c0, d0)]
        quad = k4_descent(a0, b0, c0, d0)
        for _ in range(20):
            if all(x == 0 for x in quad):
                break
            chain.append(quad)
            quad = k4_descent(*quad)
        hyp_seq = [d for _, _, _, d in chain]
        print(f"    ({a0},{b0},{c0},{d0}) → hypotenuse chain: {hyp_seq}")
    print()


def demo_hurwitz_channels():
    """Demonstrate the Hurwitz composition algebra channel counting."""
    print("=" * 70)
    print("  HURWITZ COMPOSITION ALGEBRA FACTORING CHANNELS")
    print("=" * 70)

    print(f"""
  For k-dimensional sum-of-squares representations:
    x₁² + x₂² + ... + x_k² = N

  Each representation gives:
    - k "direct" channels (one per component)
    - C(k,2) "cross" channels (from pairs of components)
    - Total: k + C(k,2) = k(k+1)/2 channels per representation

  Hurwitz's theorem: Bilinear sum-of-squares identities exist only for k = 1, 2, 4, 8.
  These give multiplicative closure: if m and n are k-fold sums, so is m·n.
    """)

    dims = [1, 2, 3, 4, 5, 6, 7, 8, 16, 32]
    print(f"  {'k':>4s} {'channels':>10s} {'bilinear?':>10s} {'algebra':>15s}")
    print(f"  {'─'*4} {'─'*10} {'─'*10} {'─'*15}")

    algebras = {1: "ℝ", 2: "ℂ (Gaussian)", 4: "ℍ (Quaternion)", 8: "𝕆 (Octonion)",
                16: "𝕊 (Sedenion)", 32: "Trigintaduonion"}

    for k in dims:
        channels = k + k * (k - 1) // 2
        bilinear = k in [1, 2, 4, 8]
        algebra = algebras.get(k, "—")
        print(f"  {k:4d} {channels:10d} {'✓' if bilinear else '✗':>10s} {algebra:>15s}")

    print(f"""
  Key insight: Even though k > 8 lacks bilinear identities, the cross-channel
  approach still works! For k = 16 (sedenions), we get 136 channels per
  representation, providing a massive advantage over k = 8 (36 channels).

  The trade-off: k > 8 representations lack multiplicative closure,
  so we can't always decompose N = p·q into k-fold sums by combining
  the factors' representations. However, Lagrange's theorem guarantees
  every positive integer is a sum of 4 squares, and every integer ≥ 0
  is a sum of k squares for k ≥ 5.
    """)

    # Demonstrate channel extraction for a specific semiprime
    N = 77  # = 7 × 11
    print(f"  Example: N = {N} = 7 × 11")
    print(f"  4-square representations of {N}:")

    reps = []
    for a in range(int(math.sqrt(N)) + 1):
        for b in range(a, int(math.sqrt(N - a*a)) + 1):
            for c in range(b, int(math.sqrt(N - a*a - b*b)) + 1):
                d2 = N - a*a - b*b - c*c
                if d2 >= c*c:
                    d = int(math.isqrt(d2))
                    if d*d == d2:
                        reps.append((a, b, c, d))

    print(f"  Found {len(reps)} representations (up to ordering):")
    for rep in reps[:10]:
        a, b, c, d = rep
        channels = []
        for i, x in enumerate(rep):
            g = math.gcd(x, N)
            if 1 < g < N:
                channels.append(f"x_{i+1}={x}→gcd={g}")
        for i in range(4):
            for j in range(i+1, 4):
                diff = abs(rep[i] - rep[j])
                summ = rep[i] + rep[j]
                g1 = math.gcd(diff, N)
                g2 = math.gcd(summ, N)
                if 1 < g1 < N:
                    channels.append(f"|x_{i+1}-x_{j+1}|={diff}→gcd={g1}")
                if 1 < g2 < N:
                    channels.append(f"x_{i+1}+x_{j+1}={summ}→gcd={g2}")
        print(f"    {rep}: {', '.join(channels) if channels else 'no direct factors'}")
    print()


def demo_zsqrt2_structure():
    """Explore the ℤ[√2] structure underlying Pell sequences."""
    print("=" * 70)
    print("  ℤ[√2] STRUCTURE AND PELL SEQUENCES")
    print("=" * 70)

    print(f"""
  The Pell sequences arise from powers of (1+√2) in ℤ[√2]:
    (1+√2)^n = H(n) + P(n)·√2

  The norm N(a+b√2) = a²-2b² is multiplicative:
    N((1+√2)^n) = N(1+√2)^n = (-1)^n

  Modulo a prime p:
    - If (2/p) = -1: ℤ[√2]/(p) ≅ F_{{p²}}, group order p²-1 = (p-1)(p+1)
    - If (2/p) = 1:  ℤ[√2]/(p) ≅ F_p × F_p, group order lcm(p-1, p-1) = p-1

  The Pell rank T(p) = order of (1+√2) in the norm-1 subgroup.
    """)

    # Compute and display the structure for small primes
    print(f"  {'p':>4s} {'(2/p)':>5s} {'F_p[√2]':>15s} {'|group×|':>10s} {'T(p)':>5s} "
          f"{'T|group':>8s}")
    print(f"  {'─'*4} {'─'*5} {'─'*15} {'─'*10} {'─'*5} {'─'*8}")

    def pell_rank_fn(p):
        H, P = 1, 1
        for T in range(1, 2*p+2):
            if P % p == 0:
                return T
            H, P = (H + 2*P) % p, (H + P) % p
        return -1

    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73]:
        leg = 1 if p % 8 in [1, 7] else -1
        if leg == -1:
            field = f"F_{p}²"
            group_order = p * p - 1
        else:
            field = f"F_{p} × F_{p}"
            group_order = p - 1
        T = pell_rank_fn(p)
        divides = group_order % T == 0

        # More precisely, T divides p - leg
        target = p - leg
        precise_div = target % T == 0

        print(f"  {p:4d} {leg:5d} {field:>15s} {group_order:10d} {T:5d} "
              f"{'✓' if precise_div else '✗':>8s}")

    print(f"""
  Theorem: T(p) | p - (2/p) for all primes p.

  Proof sketch:
    When (2/p) = -1, √2 ∉ F_p, so F_p[√2] ≅ F_{{p²}}.
    The Frobenius automorphism sends √2 → √2^p = -√2 (since 2^{{(p-1)/2}} ≡ -1).
    So (1+√2)^p = 1 + √2^p = 1 - √2, and
    (1+√2)^{{p+1}} = (1+√2)(1-√2) = -1.
    Thus (1+√2)^{{2(p+1)}} = 1, and T(p) | 2(p+1).
    Since P_{{p+1}} ≡ 0 (mod p) (provable by the above), T(p) | p+1.

    When (2/p) = 1, √2 ∈ F_p, and (1+√2)^{{p-1}} = 1 by Fermat.
    So T(p) | p-1.
    """)


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  HIGHER-DIMENSIONAL PYTHAGOREAN EXTENSIONS")
    print("=" * 70 + "\n")

    demo_quadruples()
    demo_hurwitz_channels()
    demo_zsqrt2_structure()

    print("=" * 70)
    print("  All demos complete!")
    print("=" * 70)
