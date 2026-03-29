#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════╗
║  INTERACTIVE GAUSSIAN GPS DEMO                                          ║
║                                                                        ║
║  Usage:                                                                ║
║    python3 05_interactive_gps.py               # Demo with examples    ║
║    python3 05_interactive_gps.py 1009          # Navigate to prime     ║
║    python3 05_interactive_gps.py 10403         # Factor a composite    ║
╚══════════════════════════════════════════════════════════════════════════╝
"""

import sys
from math import gcd, isqrt
from typing import Optional, Tuple, List

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def cornacchia(p: int) -> Optional[Tuple[int, int]]:
    if p == 2: return (1, 1)
    if p % 4 != 1: return None
    x0 = None
    for a in range(2, min(p, 200)):
        r = pow(a, (p - 1) // 4, p)
        if (r * r) % p == p - 1:
            x0 = r
            break
    if x0 is None: return None
    a, b = p, x0
    limit = isqrt(p)
    while b > limit:
        a, b = b, a % b
    c2 = p - b * b
    c = isqrt(c2)
    if c * c == c2:
        return (max(b, c), min(b, c))
    return None

def continued_fraction(a: int, b: int) -> List[int]:
    cf = []
    while b != 0:
        q, r = divmod(a, b)
        cf.append(q)
        a, b = b, r
    return cf

def berggren_path(m: int, n: int) -> str:
    path = []
    while (m, n) != (2, 1):
        if n == 0: break
        if m < 2 * n:
            path.append('A')
            m, n = n, 2*n - m
        elif m < 3 * n:
            path.append('B')
            m, n = n, m - 2*n
        else:
            path.append('C')
            m, n = m - 2*n, n
        if m <= 0 or n <= 0: break
        if len(path) > 10000: break
    return ''.join(reversed(path))

def display_tree_descent(m: int, n: int, max_show: int = 20):
    """Show the descent step by step."""
    steps = []
    while (m, n) != (2, 1):
        if n == 0: break
        ratio = m / n
        if m < 2 * n:
            zone = 'A'
            new_m, new_n = n, 2*n - m
        elif m < 3 * n:
            zone = 'B'
            new_m, new_n = n, m - 2*n
        else:
            zone = 'C'
            new_m, new_n = m - 2*n, n

        a = abs(m*m - n*n)
        b = 2*m*n
        c = m*m + n*n
        steps.append((m, n, zone, a, b, c))

        m, n = new_m, new_n
        if m <= 0 or n <= 0: break
        if len(steps) > 10000: break

    # Root step
    steps.append((2, 1, '-', 3, 4, 5))

    # Display
    shown = min(len(steps), max_show)
    if shown < len(steps):
        # Show first few and last few
        half = max_show // 2
        for i, (m, n, z, a, b, c) in enumerate(steps[:half]):
            arrow = f"  --[{z}]-->" if z != '-' else "  (ROOT)"
            print(f"    Step {i}: ({m},{n}) → ({a}, {b}, {c}){arrow}")
        print(f"    ... ({len(steps) - max_show} steps omitted) ...")
        for i in range(max(half, len(steps) - half), len(steps)):
            m, n, z, a, b, c = steps[i]
            arrow = f"  --[{z}]-->" if z != '-' else "  (ROOT)"
            print(f"    Step {i}: ({m},{n}) → ({a}, {b}, {c}){arrow}")
    else:
        for i, (m, n, z, a, b, c) in enumerate(steps):
            arrow = f"  --[{z}]-->" if z != '-' else "  (ROOT)"
            print(f"    Step {i}: ({m},{n}) → ({a}, {b}, {c}){arrow}")

def navigate_to_prime(p: int):
    """Full GPS navigation to a prime."""
    print(f"\n{'═' * 60}")
    print(f"  GAUSSIAN GPS: NAVIGATING TO PRIME p = {p}")
    print(f"{'═' * 60}")

    if not is_prime(p):
        print(f"  {p} is NOT prime!")
        # Factor it
        factors = []
        n = p
        d = 2
        while d * d <= n:
            while n % d == 0:
                factors.append(d)
                n //= d
            d += 1
        if n > 1:
            factors.append(n)
        print(f"  Factorization: {' × '.join(map(str, factors))}")
        return

    if p == 2:
        print("  p = 2 = 1² + 1², the root triple (3, 4, 5).")
        return

    # Hypotenuse triple (p ≡ 1 mod 4)
    if p % 4 == 1:
        print(f"\n  p ≡ 1 (mod 4): Hypotenuse navigation available!")
        result = cornacchia(p)
        if result:
            a, b = result
            print(f"  Cornacchia: {p} = {a}² + {b}² = {a**2} + {b**2}")
            print(f"  Gaussian factorization: {p} = ({a} + {b}i)({a} - {b}i)")

            m, n = max(a, b), min(a, b)
            cf = continued_fraction(m, n)
            path = berggren_path(m, n)
            triple = (abs(m*m - n*n), 2*m*n, m*m + n*n)

            print(f"\n  Euclid parameters: (m, n) = ({m}, {n})")
            print(f"  Continued fraction: CF({m}/{n}) = {cf}")
            print(f"  Berggren path: {path}")
            print(f"  Tree depth: {len(path)}")
            print(f"  Target triple: ({triple[0]}, {triple[1]}, {triple[2]})")
            print(f"  Verification: {triple[0]}² + {triple[1]}² = {triple[0]**2} + {triple[1]**2} = {triple[0]**2 + triple[1]**2}")
            print(f"               {triple[2]}² = {triple[2]**2}")

            print(f"\n  Descent trace:")
            display_tree_descent(m, n)

    # Leg triple (always available for odd p)
    if p > 2 and p % 2 == 1:
        print(f"\n  Odd prime: Leg navigation (trivial triple)")
        m = (p + 1) // 2
        n = (p - 1) // 2
        depth = (p - 3) // 2
        triple = (p, (p*p - 1) // 2, (p*p + 1) // 2)

        print(f"  Euclid parameters: (m, n) = ({m}, {n})")
        print(f"  CF({m}/{n}) = [1; {p-2}]")
        print(f"  Path: {'A' * min(depth, 50)}{'...' if depth > 50 else ''}")
        print(f"  Depth: {depth} (= (p-3)/2)")
        print(f"  Triple: ({triple[0]}, {triple[1]}, {triple[2]})")

def demo_factoring(N: int):
    """Demonstrate the factoring connection for composites."""
    print(f"\n{'═' * 60}")
    print(f"  BERGGREN TREE ANALYSIS OF N = {N}")
    print(f"{'═' * 60}")

    if is_prime(N):
        print(f"  {N} is prime!")
        navigate_to_prime(N)
        return

    # Factor
    factors = []
    n = N
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    print(f"  Factorization: {N} = {' × '.join(map(str, factors))}")

    # Find all Pythagorean triples with leg N
    if N % 2 == 1:
        print(f"\n  Pythagorean triples with odd leg {N}:")
        count = 0
        for d in range(1, isqrt(N*N) + 1):
            if (N*N) % d != 0:
                continue
            e = (N*N) // d
            if d >= e:
                continue
            if (d + e) % 2 != 0:
                continue
            b = (e - d) // 2
            c = (e + d) // 2
            if b > 0 and N*N + b*b == c*c:
                g = gcd(N, b)
                count += 1
                if count <= 15:
                    print(f"    ({N}, {b}, {c})  d={d}, e={e}  gcd({N},{b})={g}")
        if count > 15:
            print(f"    ... ({count - 15} more)")
        print(f"  Total triples: {count}")

    # Sum-of-squares representations (if relevant)
    reps = []
    for a in range(1, isqrt(N) + 1):
        b2 = N - a*a
        b = isqrt(b2)
        if b*b == b2 and a >= b and b > 0:
            reps.append((a, b))

    if reps:
        print(f"\n  Sum-of-squares representations of {N}:")
        for a, b in reps:
            g1 = gcd(a, factors[0]) if factors else 1
            print(f"    {N} = {a}² + {b}² = {a**2} + {b**2}")

def main():
    if len(sys.argv) > 1:
        try:
            n = int(sys.argv[1])
            if is_prime(n):
                navigate_to_prime(n)
            else:
                demo_factoring(n)
        except ValueError:
            print(f"Invalid number: {sys.argv[1]}")
        return

    # Default demo
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║           THE GAUSSIAN GPS — INTERACTIVE DEMO              ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # Small primes
    for p in [5, 13, 29, 41, 97, 197]:
        navigate_to_prime(p)

    # A large prime
    navigate_to_prime(10009)

    # A semiprime
    demo_factoring(10403)

    print(f"\n{'═' * 60}")
    print("  Usage: python3 05_interactive_gps.py <number>")
    print("  Provide any number to see its Berggren tree analysis.")
    print(f"{'═' * 60}")

if __name__ == '__main__':
    main()
