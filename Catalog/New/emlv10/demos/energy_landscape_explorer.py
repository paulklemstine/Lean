#!/usr/bin/env python3
"""
Energy Landscape Explorer — v10
================================
Interactive visualization of the energy function E(N, x) = N mod x
and its connection to factoring.

Demonstrates:
- Energy landscape as a "gravitational" field where divisors sit at zero-energy wells
- Sublevel set filtration: how divisors emerge as threshold increases
- Gradient descent paths converging to divisors
- Morse-theoretic critical point analysis
"""

import math
import sys

def energy(N, x):
    """E(N, x) = N mod x"""
    if x == 0:
        return float('inf')
    return N % x

def divisors(N):
    """Return sorted list of divisors of N."""
    divs = []
    for i in range(1, int(math.isqrt(N)) + 1):
        if N % i == 0:
            divs.append(i)
            if i != N // i:
                divs.append(N // i)
    return sorted(divs)

def sublevel_set(N, t):
    """Return {x in [1,N] : E(N,x) ≤ t}."""
    return [x for x in range(1, N + 1) if energy(N, x) <= t]

def gradient_descent(N, x, max_steps=1000):
    """Perform discrete gradient descent on the energy landscape."""
    path = [x]
    for _ in range(max_steps):
        if energy(N, x) == 0:
            break
        # Check neighbors
        left = x - 1 if x > 1 else x
        right = x + 1 if x <= N else x
        e_left = energy(N, left) if left > 0 else float('inf')
        e_right = energy(N, right)
        if e_left <= e_right and e_left < energy(N, x):
            x = left
        elif e_right < energy(N, x):
            x = right
        else:
            break
        path.append(x)
    return path

def display_landscape(N, width=80):
    """Display ASCII art of the energy landscape."""
    print(f"\n{'='*width}")
    print(f"  ENERGY LANDSCAPE for N = {N}")
    print(f"  Divisors: {divisors(N)}")
    print(f"{'='*width}\n")

    max_x = min(N, width)
    max_e = max(energy(N, x) for x in range(1, max_x + 1))

    if max_e == 0:
        print("  N = 1, trivial landscape")
        return

    height = 20
    for row in range(height, -1, -1):
        threshold = row * max_e / height
        line = "  "
        for x in range(1, max_x + 1):
            e = energy(N, x)
            if abs(e - threshold) < max_e / height / 2:
                if e == 0:
                    line += "●"  # Divisor (zero energy)
                else:
                    line += "█"
            elif e > threshold:
                line += " "
            else:
                line += " "
        if row == height:
            line += f"  ← E = {max_e}"
        elif row == 0:
            line += f"  ← E = 0 (divisors)"
        print(line)

    print("  " + "─" * max_x)
    print(f"  1{'─' * (max_x - 2)}{max_x}")
    print(f"  x →\n")

def demo_sublevel_filtration(N):
    """Demonstrate how sublevel sets grow as threshold increases."""
    print(f"\n{'='*60}")
    print(f"  SUBLEVEL SET FILTRATION for N = {N}")
    print(f"{'='*60}\n")

    divs = divisors(N)
    max_t = max(energy(N, x) for x in range(1, N + 1))

    thresholds = sorted(set(energy(N, x) for x in range(1, N + 1)))

    for t in thresholds[:15]:  # Show first 15 thresholds
        sl = sublevel_set(N, t)
        new_points = [x for x in sl if x not in sublevel_set(N, t - 1)] if t > 0 else sl
        div_count = sum(1 for x in sl if N % x == 0)
        print(f"  t = {t:3d}: |sublevel| = {len(sl):3d}, "
              f"divisors found = {div_count}/{len(divs)}, "
              f"new: {new_points[:8]}{'...' if len(new_points) > 8 else ''}")

def demo_gradient_descent(N, starts=None):
    """Demonstrate gradient descent finding divisors."""
    print(f"\n{'='*60}")
    print(f"  GRADIENT DESCENT FACTORING for N = {N}")
    print(f"  Divisors: {divisors(N)}")
    print(f"{'='*60}\n")

    if starts is None:
        starts = [N // 3, N // 4, N // 5, int(math.sqrt(N)), N // 2 + 1]
        starts = [s for s in starts if 1 <= s <= N]

    for x0 in starts:
        path = gradient_descent(N, x0)
        final = path[-1]
        found_factor = N % final == 0
        print(f"  Start x = {x0:4d} → path length {len(path):3d} → "
              f"landed at {final:4d} (E = {energy(N, final)})"
              f"{'  ✓ DIVISOR!' if found_factor else ''}")

def demo_fibonacci_pseudoprime():
    """Demonstrate Fibonacci pseudoprime detection."""
    print(f"\n{'='*60}")
    print(f"  FIBONACCI PSEUDOPRIME ANALYSIS")
    print(f"{'='*60}\n")

    def fib_mod(n, m):
        """Compute F(n) mod m efficiently."""
        if n == 0: return 0
        if n == 1: return 1
        a, b = 0, 1
        for _ in range(2, n + 1):
            a, b = b, (a + b) % m
        return b

    print("  Checking composites for Fibonacci pseudoprimality:")
    print("  n is Fib-pseudoprime if composite and F(n±1) ≡ 0 (mod n)\n")

    pseudoprimes = []
    for n in range(4, 1000):
        if all(n % p != 0 for p in range(2, int(math.sqrt(n)) + 1)):
            continue  # n is prime
        if fib_mod(n - 1, n) == 0 or fib_mod(n + 1, n) == 0:
            pseudoprimes.append(n)
            if len(pseudoprimes) <= 10:
                print(f"  n = {n}: F({n-1}) mod {n} = {fib_mod(n-1, n)}, "
                      f"F({n+1}) mod {n} = {fib_mod(n+1, n)}")

    print(f"\n  Found {len(pseudoprimes)} Fibonacci pseudoprimes below 1000:")
    print(f"  {pseudoprimes}")
    print(f"\n  Density: {len(pseudoprimes)}/1000 = {len(pseudoprimes)/1000:.4f}")

def demo_quadratic_sieve_concept(N):
    """Demonstrate the quadratic sieve concept."""
    print(f"\n{'='*60}")
    print(f"  QUADRATIC SIEVE CONCEPT for N = {N}")
    print(f"{'='*60}\n")

    s = int(math.isqrt(N))
    print(f"  √N ≈ {s}")
    print(f"  Q(x) = (x + {s})² - {N}\n")

    # Find smooth values
    factor_base = [p for p in range(2, 20) if all(p % q != 0 for q in range(2, p))]
    print(f"  Factor base: {factor_base}\n")

    smooth_relations = []
    for x in range(-10, 20):
        val = (x + s) ** 2 - N
        if val == 0:
            continue
        abs_val = abs(val)

        # Try to factor over factor base
        remaining = abs_val
        factorization = {}
        for p in factor_base:
            while remaining % p == 0:
                factorization[p] = factorization.get(p, 0) + 1
                remaining //= p

        if remaining == 1:
            sign = "-" if val < 0 else "+"
            factors_str = " × ".join(f"{p}^{e}" for p, e in sorted(factorization.items()))
            print(f"  x = {x:3d}: Q(x) = {val:8d} = {sign}{factors_str}  ← SMOOTH!")
            smooth_relations.append((x, val, factorization))
        elif abs_val < 1000:
            pass  # Skip non-smooth

    print(f"\n  Found {len(smooth_relations)} smooth relations")
    if len(smooth_relations) > len(factor_base):
        print(f"  Need > {len(factor_base)} relations to guarantee a dependency")
        print(f"  → Can find x² ≡ y² (mod N) and extract factor!")

def demo_wieferich():
    """Demonstrate Wieferich prime testing."""
    print(f"\n{'='*60}")
    print(f"  WIEFERICH PRIME VERIFICATION")
    print(f"{'='*60}\n")

    primes = [p for p in range(3, 250) if all(p % q != 0 for q in range(2, int(math.sqrt(p)) + 1))]

    print(f"  Testing primes up to 250:")
    print(f"  Wieferich: 2^(p-1) ≡ 1 (mod p²)\n")

    for p in primes:
        result = pow(2, p - 1, p * p)
        is_wieferich = (result == 1)
        if is_wieferich or p <= 50:
            status = "✓ WIEFERICH!" if is_wieferich else "  not Wieferich"
            fermat_quot = (pow(2, p - 1) - 1) // p
            print(f"  p = {p:4d}: 2^{p-1:3d} mod {p*p:8d} = {result:8d}  {status}"
                  f"  q_p(2) mod p = {fermat_quot % p}")

    print(f"\n  Known Wieferich primes: 1093, 3511")
    print(f"  No others known below 6.7 × 10^15!")

def demo_perfect_numbers():
    """Demonstrate perfect number properties."""
    print(f"\n{'='*60}")
    print(f"  PERFECT NUMBER THEORY")
    print(f"{'='*60}\n")

    def sigma1(n):
        return sum(d for d in range(1, n + 1) if n % d == 0)

    print("  Checking Euclid-Euler theorem:")
    print("  n is even perfect ⟺ n = 2^(p-1) · (2^p - 1) with 2^p - 1 prime\n")

    mersenne_primes = []
    for p in range(2, 32):
        mp = 2**p - 1
        if all(mp % q != 0 for q in range(2, int(math.sqrt(mp)) + 1)):
            mersenne_primes.append(p)
            n = 2**(p-1) * mp
            s = sigma1(n) if n < 100000 else "—"
            verified = s == 2*n if isinstance(s, int) else "large"
            print(f"  p = {p:2d}: M_p = 2^{p}-1 = {mp:10d} (prime), "
                  f"n = {n:12d}, σ₁(n) = {s}, perfect: {verified}")

    print(f"\n  Mersenne prime exponents found: {mersenne_primes}")
    print(f"\n  Odd perfect numbers: NONE known (verified < 10^1500)")

def main():
    print("\n" + "█" * 60)
    print("  GRAVITATIONAL FACTORING — v10 DEMO SUITE")
    print("█" * 60)

    # Demo 1: Energy Landscape
    display_landscape(60)

    # Demo 2: Sublevel filtration
    demo_sublevel_filtration(60)

    # Demo 3: Gradient descent
    demo_gradient_descent(1001)  # 1001 = 7 × 11 × 13

    # Demo 4: Fibonacci pseudoprimes
    demo_fibonacci_pseudoprime()

    # Demo 5: Quadratic sieve
    demo_quadratic_sieve_concept(1073)  # 1073 = 29 × 37

    # Demo 6: Wieferich primes
    demo_wieferich()

    # Demo 7: Perfect numbers
    demo_perfect_numbers()

    print("\n" + "█" * 60)
    print("  ALL DEMOS COMPLETE")
    print("█" * 60 + "\n")

if __name__ == "__main__":
    main()
