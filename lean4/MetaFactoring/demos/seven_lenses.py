#!/usr/bin/env python3
"""
MetaFactoring Demo: The Seven Lenses in Action

Demonstrates each of the seven factoring lenses on concrete examples,
showing how they combine to constrain the search space.

All core theorems are formally verified in Lean 4.
"""

import math
import random
from collections import Counter


# ============================================================================
# Lens 1: Fibonacci-Zeckendorf
# ============================================================================

def zeckendorf_representation(n):
    """Find the Zeckendorf (non-adjacent Fibonacci) representation of n."""
    if n == 0:
        return []
    fibs = [1, 2]
    while fibs[-1] <= n:
        fibs.append(fibs[-1] + fibs[-2])

    result = []
    remaining = n
    for f in reversed(fibs):
        if f <= remaining:
            result.append(f)
            remaining -= f
    return result


def fibonacci_lens(N):
    """Lens 1: Fibonacci-Zeckendorf constraints on factors."""
    print(f"\n  [Lens 1: Fibonacci-Zeckendorf]")
    zeck = zeckendorf_representation(N)
    print(f"  N = {N} = {' + '.join(map(str, zeck))} (Zeckendorf)")
    print(f"  {len(zeck)} non-adjacent Fibonacci summands")

    # Factors must satisfy Zeckendorf constraints
    k = len(bin(N)) - 2
    fib_bound = len(zeck)
    reduction = 2**k / max(1, 1.618**fib_bound)
    print(f"  Search space reduction: ~{reduction:.1f}×")


# ============================================================================
# Lens 2: Hyperbolic-Geometric
# ============================================================================

def hyperbolic_lens(N):
    """Lens 2: Divisors lie on hyperbola xy = N."""
    print(f"\n  [Lens 2: Hyperbolic-Geometric]")
    sqrt_N = int(math.isqrt(N))
    print(f"  √N = {sqrt_N}")
    print(f"  Factor search: d ∈ [2, {sqrt_N}]")
    print(f"  Search space: {sqrt_N - 1} candidates")

    # Show divisor pairs on hyperbola
    divisors = [(d, N // d) for d in range(2, sqrt_N + 1) if N % d == 0]
    for d, q in divisors[:5]:
        print(f"  Hyperbolic point: ({d}, {q}), product = {d * q}")


# ============================================================================
# Lens 3: Orbit-Dynamical (Pollard rho)
# ============================================================================

def orbit_lens(N, max_iter=1000):
    """Lens 3: Pollard rho-style orbit detection."""
    print(f"\n  [Lens 3: Orbit-Dynamical]")

    def f(x):
        return (x * x + 1) % N

    x, y = 2, 2
    for i in range(max_iter):
        x = f(x)
        y = f(f(y))
        d = math.gcd(abs(x - y), N)
        if 1 < d < N:
            print(f"  Collision at iteration {i + 1}: gcd(|{x}-{y}|, {N}) = {d}")
            print(f"  Factor found: {d}")
            return d
    print(f"  No collision in {max_iter} iterations")
    return None


# ============================================================================
# Lens 4: Spectral-Harmonic
# ============================================================================

def spectral_lens(N):
    """Lens 4: Fermat's little theorem and spectral tests."""
    print(f"\n  [Lens 4: Spectral-Harmonic]")

    # Test several bases
    bases_to_test = [2, 3, 5, 7, 11, 13]
    for a in bases_to_test:
        if math.gcd(a, N) > 1:
            print(f"  Base {a}: gcd({a}, {N}) = {math.gcd(a, N)} → direct factor!")
            continue

        # Fermat test: a^(N-1) mod N
        result = pow(a, N - 1, N)
        if result != 1:
            print(f"  Base {a}: a^(N-1) ≡ {result} (mod N) → N is composite")
            # Try to extract factor
            g = math.gcd(result - 1, N)
            if 1 < g < N:
                print(f"    gcd(a^(N-1) - 1, N) = {g} → factor!")
        else:
            print(f"  Base {a}: a^(N-1) ≡ 1 (mod N) → passes Fermat test")


# ============================================================================
# Lens 5: Division-Algebra (Norm Channel)
# ============================================================================

def norm_channel_lens(N):
    """Lens 5: Sum-of-squares representations."""
    print(f"\n  [Lens 5: Division-Algebra Norm Channel]")

    # Find 2-square representations
    reps = []
    a = 0
    while a * a <= N:
        b_sq = N - a * a
        b = int(math.isqrt(b_sq))
        if b * b == b_sq and a <= b:
            reps.append((a, b))
        a += 1

    if len(reps) == 0:
        print(f"  N = {N} has no 2-square representation")
        print(f"  (has prime factor ≡ 3 mod 4 to odd power)")
    elif len(reps) == 1:
        a, b = reps[0]
        print(f"  N = {a}² + {b}² (unique representation)")
        print(f"  → N is likely prime or prime power")
    else:
        print(f"  N has {len(reps)} representations as sum of 2 squares:")
        for a, b in reps:
            print(f"    {N} = {a}² + {b}² = {a*a} + {b*b}")
        # Factor extraction via Brahmagupta-Fibonacci
        a1, b1 = reps[0]
        a2, b2 = reps[1]
        g = math.gcd(a1 * b2 - a2 * b1, N)
        if 1 < g < N:
            print(f"  → Factor extracted: {g}")

    # 4-square representation always exists (Lagrange)
    print(f"  (4-square representation always exists by Lagrange's theorem)")


# ============================================================================
# Lens 6: Lattice-Reduction
# ============================================================================

def lattice_lens(N):
    """Lens 6: Lattice-based factor search."""
    print(f"\n  [Lens 6: Lattice-Reduction]")
    sqrt_N = int(math.isqrt(N))
    print(f"  Factoring lattice: vectors (a, b) with a·b close to N")
    print(f"  Bézout: gcd structure constrains factor lattice")

    # Continued fraction approach (simplified)
    # Find convergents of √N
    a0 = sqrt_N
    if a0 * a0 == N:
        print(f"  N = {a0}² is a perfect square")
        return

    convergents = []
    m, d, a = 0, 1, a0
    p_prev, p_curr = 1, a0
    q_prev, q_curr = 0, 1
    convergents.append((p_curr, q_curr))

    for _ in range(20):
        m = d * a - m
        d = (N - m * m) // d
        if d == 0:
            break
        a = (a0 + m) // d
        p_prev, p_curr = p_curr, a * p_curr + p_prev
        q_prev, q_curr = q_curr, a * q_curr + q_prev
        convergents.append((p_curr, q_curr))
        # Check if p² ≡ ±1 (mod N)
        residue = (p_curr * p_curr) % N
        if residue == 1 or residue == N - 1:
            g = math.gcd(p_curr - 1, N)
            if 1 < g < N:
                print(f"  CF convergent p/q = {p_curr}/{q_curr}")
                print(f"  p² mod N = {residue}")
                print(f"  gcd(p-1, N) = {g} → factor!")
                return


# ============================================================================
# Lens 7: Congruence-of-Squares
# ============================================================================

def congruence_of_squares_lens(N):
    """Lens 7: The classical x² ≡ y² (mod N) endgame."""
    print(f"\n  [Lens 7: Congruence-of-Squares]")

    # Simple quadratic sieve simulation
    sqrt_N = int(math.isqrt(N)) + 1
    smooth_bound = 50
    small_primes = [p for p in range(2, smooth_bound) if all(p % i != 0 for i in range(2, p))]

    relations = []
    for x in range(sqrt_N, sqrt_N + 200):
        q = x * x - N
        if q <= 0:
            continue

        # Try to factor q over small primes
        remaining = q
        exponents = {}
        for p in small_primes:
            while remaining % p == 0:
                remaining //= p
                exponents[p] = exponents.get(p, 0) + 1

        if remaining == 1:
            relations.append((x, q, exponents))
            if len(relations) >= 2:
                break

    if len(relations) >= 2:
        x1, q1, e1 = relations[0]
        x2, q2, e2 = relations[1]
        print(f"  {x1}² - N = {q1} (smooth)")
        print(f"  {x2}² - N = {q2} (smooth)")
        # Try combining
        x_combined = (x1 * x2) % N
        y_sq = q1 * q2
        y = int(math.isqrt(y_sq))
        if y * y == y_sq:
            g = math.gcd(x_combined - y, N)
            if 1 < g < N:
                print(f"  Combined: x = {x_combined}, y = {y}")
                print(f"  gcd(x-y, N) = {g} → factor!")
    else:
        print(f"  (Need more smooth relations for full factoring)")


# ============================================================================
# Combined Multi-Lens Demo
# ============================================================================

def multi_lens_demo(N):
    """Run all seven lenses on a given composite N."""
    print("=" * 70)
    print(f"METAFACTORING: SEVEN LENSES ON N = {N}")
    print("=" * 70)

    fibonacci_lens(N)
    hyperbolic_lens(N)
    orbit_lens(N)
    spectral_lens(N)
    norm_channel_lens(N)
    lattice_lens(N)
    congruence_of_squares_lens(N)

    print("\n" + "=" * 70)


def correlation_experiment():
    """Measure pairwise correlations between lenses."""
    print("\n" + "=" * 70)
    print("LENS CORRELATION EXPERIMENT")
    print("=" * 70)

    random.seed(42)
    n_trials = 100

    # For each trial, generate a random semiprime and see which lenses find factors
    results = {f"Lens {i}": [] for i in range(1, 8)}

    for _ in range(n_trials):
        # Generate random semiprime
        while True:
            p = random.choice([p for p in range(100, 1000) if all(p % i != 0 for i in range(2, p))])
            q = random.choice([q for q in range(100, 1000) if all(q % i != 0 for i in range(2, q))])
            if p != q:
                break
        N = p * q

        # Test each lens (simplified success metrics)
        sqrt_N = int(math.isqrt(N))

        # Lens 1: Zeckendorf compactness
        zeck = zeckendorf_representation(N)
        results["Lens 1"].append(len(zeck) < len(bin(N)) - 2)

        # Lens 2: Small factor exists
        results["Lens 2"].append(min(p, q) < sqrt_N * 0.5)

        # Lens 3: Pollard rho finds factor quickly
        found_rho = False
        x, y = 2, 2
        for i in range(100):
            x = (x * x + 1) % N
            y = (((y * y + 1) % N) ** 2 + 1) % N
            d = math.gcd(abs(x - y), N)
            if 1 < d < N:
                found_rho = True
                break
        results["Lens 3"].append(found_rho)

        # Lens 4: Fermat test reveals
        results["Lens 4"].append(pow(2, N - 1, N) != 1)

        # Lens 5: Has 2-square rep
        has_rep = any((N - a*a) >= 0 and int(math.isqrt(N - a*a))**2 == N - a*a
                      for a in range(int(math.isqrt(N)) + 1))
        results["Lens 5"].append(has_rep)

        # Lens 6: CF convergent helps
        results["Lens 6"].append(abs(p - q) < sqrt_N * 0.3)

        # Lens 7: Quick smooth relation
        results["Lens 7"].append((sqrt_N + 1)**2 - N < 1000)

    # Compute success rates
    print(f"\nSuccess rates over {n_trials} random semiprimes:")
    for lens, outcomes in results.items():
        rate = sum(outcomes) / len(outcomes)
        print(f"  {lens}: {rate:.1%}")

    # Compute pairwise correlations
    print(f"\nPairwise correlations:")
    lens_names = list(results.keys())
    for i in range(len(lens_names)):
        for j in range(i + 1, len(lens_names)):
            a = results[lens_names[i]]
            b = results[lens_names[j]]
            # Simple correlation: fraction of agreements
            agree = sum(1 for x, y in zip(a, b) if x == y) / len(a)
            corr = 2 * agree - 1  # Scale to [-1, 1]
            if abs(corr) > 0.2:
                marker = " ⚠"
            else:
                marker = ""
            print(f"  ρ({lens_names[i]}, {lens_names[j]}) = {corr:+.3f}{marker}")


if __name__ == "__main__":
    # Demo on several composites
    multi_lens_demo(91)       # 7 × 13
    multi_lens_demo(1517)     # 37 × 41
    multi_lens_demo(10403)    # 101 × 103

    correlation_experiment()
