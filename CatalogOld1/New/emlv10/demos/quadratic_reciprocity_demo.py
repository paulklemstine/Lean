#!/usr/bin/env python3
"""
Quadratic Reciprocity and Legendre Symbol Explorer — v10
=========================================================
Visualizes quadratic reciprocity, Legendre symbols, and
the distribution of quadratic residues.
"""

import math

def is_prime(n):
    if n < 2: return False
    for p in range(2, int(math.sqrt(n)) + 1):
        if n % p == 0: return False
    return True

def legendre(a, p):
    """Compute Legendre symbol (a/p) for odd prime p."""
    a = a % p
    if a == 0: return 0
    result = pow(a, (p - 1) // 2, p)
    return result if result != p - 1 else -1

def jacobi(a, n):
    """Compute Jacobi symbol (a/n)."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be odd positive")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0

def demo_qr_reciprocity():
    """Verify quadratic reciprocity for small primes."""
    print("=" * 60)
    print("  QUADRATIC RECIPROCITY VERIFICATION")
    print("=" * 60)
    print()
    print("  Theorem: For distinct odd primes p, q:")
    print("  (p/q)(q/p) = (-1)^{(p-1)/2 · (q-1)/2}")
    print()

    primes = [p for p in range(3, 50) if is_prime(p)]

    verified = 0
    total = 0
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            lhs = legendre(p, q) * legendre(q, p)
            rhs = (-1) ** (((p-1)//2) * ((q-1)//2))
            total += 1
            if lhs == rhs:
                verified += 1
            if total <= 15:
                print(f"  ({p}/{q})·({q}/{p}) = {legendre(p,q):+d}·{legendre(q,p):+d} = {lhs:+d}"
                      f"  vs  (-1)^({(p-1)//2}·{(q-1)//2}) = {rhs:+d}  {'✓' if lhs == rhs else '✗'}")

    print(f"\n  Verified: {verified}/{total} pairs ✓")

def demo_qr_distribution():
    """Show distribution of quadratic residues."""
    print("\n" + "=" * 60)
    print("  QUADRATIC RESIDUE DISTRIBUTION")
    print("=" * 60)
    print()

    for p in [7, 11, 13, 17, 23, 29]:
        qrs = [a for a in range(1, p) if legendre(a, p) == 1]
        qnrs = [a for a in range(1, p) if legendre(a, p) == -1]
        sum_leg = sum(legendre(a, p) for a in range(1, p))

        print(f"  p = {p:2d}:")
        print(f"    QR  ({len(qrs):2d}): {qrs}")
        print(f"    QNR ({len(qnrs):2d}): {qnrs}")
        print(f"    Σ(a/p) = {sum_leg} (should be 0)")
        print(f"    -1 is QR: {'yes' if legendre(-1, p) == 1 else 'no'}"
              f" (p mod 4 = {p % 4})")
        print(f"     2 is QR: {'yes' if legendre(2, p) == 1 else 'no'}"
              f" (p mod 8 = {p % 8})")
        print()

def demo_legendre_table():
    """Show Legendre symbol table."""
    print("=" * 60)
    print("  LEGENDRE SYMBOL TABLE")
    print("=" * 60)
    print()

    primes = [3, 5, 7, 11, 13, 17, 19, 23]

    header = "  a\\p |" + "".join(f"{p:4d}" for p in primes)
    print(header)
    print("  " + "-" * (len(header) - 2))

    for a in range(-5, 11):
        row = f"  {a:3d} |"
        for p in primes:
            row += f"{legendre(a, p):4d}"
        print(row)

def demo_gauss_lemma():
    """Illustrate Gauss's lemma."""
    print("\n" + "=" * 60)
    print("  GAUSS'S LEMMA ILLUSTRATION")
    print("=" * 60)
    print()
    print("  (a/p) = (-1)^n where n = #{ka mod p > p/2 : k=1,...,(p-1)/2}")
    print()

    for p in [7, 11, 13]:
        for a in [2, 3, 5]:
            if a % p == 0: continue
            half = (p - 1) // 2
            residues = [(k * a) % p for k in range(1, half + 1)]
            count_gt = sum(1 for r in residues if r > p / 2)

            print(f"  p={p}, a={a}: residues of {a}·k mod {p} for k=1..{half}:")
            print(f"    {residues}")
            print(f"    #{'{'}r > {p}/2{'}'} = {count_gt}")
            print(f"    (-1)^{count_gt} = {(-1)**count_gt:+d} = (a/p) = {legendre(a, p):+d}")
            print()

def demo_supplements():
    """Demonstrate the supplements to quadratic reciprocity."""
    print("=" * 60)
    print("  SUPPLEMENTS TO QUADRATIC RECIPROCITY")
    print("=" * 60)
    print()

    print("  First supplement: (-1/p) = 1 ⟺ p ≡ 1 (mod 4)")
    print()
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        l = legendre(-1, p)
        print(f"    p = {p:2d}: (-1/{p}) = {l:+d}, p mod 4 = {p%4}"
              f"  {'✓' if (l == 1) == (p % 4 == 1) else '✗'}")

    print()
    print("  Second supplement: (2/p) = 1 ⟺ p ≡ ±1 (mod 8)")
    print()
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        l = legendre(2, p)
        expected = p % 8 in (1, 7)
        print(f"    p = {p:2d}: (2/{p}) = {l:+d}, p mod 8 = {p%8}"
              f"  {'✓' if (l == 1) == expected else '✗'}")

def main():
    print("\n" + "█" * 60)
    print("  QUADRATIC RECIPROCITY — v10 DEMO")
    print("█" * 60 + "\n")

    demo_qr_reciprocity()
    demo_qr_distribution()
    demo_legendre_table()
    demo_gauss_lemma()
    demo_supplements()

    print("\n" + "█" * 60)
    print("  DEMO COMPLETE")
    print("█" * 60 + "\n")

if __name__ == "__main__":
    main()
