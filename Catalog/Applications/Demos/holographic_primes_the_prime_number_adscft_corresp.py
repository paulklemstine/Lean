#!/usr/bin/env python3
"""
Holographic Primes: Numerical Demonstrations

Demonstrates the key concepts of the prime number AdS/CFT correspondence:
- Euler product convergence
- Chebyshev function vs prime counting function
- Holographic depth (p-adic valuation) distribution
- Total holographic weight computation
"""

import math
from typing import List, Tuple

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def primes_up_to(n: int) -> List[int]:
    return [p for p in range(2, n + 1) if is_prime(p)]

def prime_count(n: int) -> int:
    return len(primes_up_to(n))

def chebyshev_theta(n: int) -> float:
    return sum(math.log(p) for p in primes_up_to(n))

def chebyshev_theta_approx(n: int) -> int:
    """Integer approximation: sum of (floor(log2(p)) + 1) for primes p <= n."""
    return sum(int(math.log2(p)) + 1 for p in primes_up_to(n))

def holographic_depth(p: int, n: int) -> int:
    """p-adic valuation of n."""
    if n == 0 or p < 2:
        return 0
    depth = 0
    while n % p == 0:
        depth += 1
        n //= p
    return depth

def total_holographic_weight(n: int) -> int:
    """Sum of holographic depths across all primes <= n."""
    return sum(holographic_depth(p, n) for p in primes_up_to(n))

def euler_product_partial(s: float, N: int) -> float:
    """Partial Euler product: prod_{p<=N} (1 - p^{-s})^{-1}."""
    product = 1.0
    for p in primes_up_to(N):
        factor = 1.0 / (1.0 - p ** (-s))
        product *= factor
    return product

def partial_euler_numerator(n: int, s: int) -> int:
    """Product of p^s for primes p <= n."""
    result = 1
    for p in primes_up_to(n):
        result *= p ** s
    return result


def demo_euler_product_convergence():
    """Show how the Euler product converges to zeta(s)."""
    print("=" * 60)
    print("EULER PRODUCT CONVERGENCE TO ZETA(s)")
    print("=" * 60)
    print()
    for s in [2.0, 3.0, 4.0]:
        # Known values
        if s == 2.0:
            exact = math.pi ** 2 / 6
        elif s == 3.0:
            exact = 1.2020569  # Apery's constant
        elif s == 4.0:
            exact = math.pi ** 4 / 90
        else:
            exact = None

        print(f"s = {s}")
        for N in [10, 50, 100, 500, 1000]:
            approx = euler_product_partial(s, N)
            err = abs(approx - exact) if exact else float('nan')
            print(f"  N={N:>5}: prod = {approx:.10f}  |error| = {err:.2e}")
        if exact:
            print(f"  exact:         {exact:.10f}")
        print()


def demo_chebyshev_vs_primecount():
    """Compare Chebyshev theta with prime counting function."""
    print("=" * 60)
    print("CHEBYSHEV THETA vs PRIME COUNTING FUNCTION")
    print("=" * 60)
    print()
    print(f"{'n':>8} {'π(n)':>8} {'θ(n)':>12} {'θ_approx(n)':>14} {'n/ln(n)':>12} {'θ(n)/n':>10}")
    print("-" * 70)
    for n in [10, 50, 100, 500, 1000, 5000, 10000]:
        pc = prime_count(n)
        theta = chebyshev_theta(n)
        theta_a = chebyshev_theta_approx(n)
        nlogn = n / math.log(n) if n > 1 else 0
        ratio = theta / n if n > 0 else 0
        print(f"{n:>8} {pc:>8} {theta:>12.4f} {theta_a:>14} {nlogn:>12.4f} {ratio:>10.6f}")
    print()
    print("Note: θ(n) ~ n as n → ∞ (Prime Number Theorem)")
    print("      π(n) ~ n/log(n) as n → ∞")
    print()


def demo_holographic_depth():
    """Show holographic depth distribution."""
    print("=" * 60)
    print("HOLOGRAPHIC DEPTH (p-ADIC VALUATION) EXAMPLES")
    print("=" * 60)
    print()
    # Depth of various numbers at small primes
    for p in [2, 3, 5, 7]:
        print(f"Depths at prime p = {p}:")
        depths = []
        for n in range(1, 33):
            d = holographic_depth(p, n)
            depths.append((n, d))
        for n, d in depths:
            bar = "█" * d if d > 0 else "·"
            print(f"  n={n:>3}: depth={d}  {bar}")
        print()


def demo_total_weight():
    """Demonstrate total holographic weight."""
    print("=" * 60)
    print("TOTAL HOLOGRAPHIC WEIGHT")
    print("=" * 60)
    print()
    print("Weight of primes (should be 1):")
    for p in primes_up_to(30):
        w = total_holographic_weight(p)
        print(f"  p={p:>3}: weight = {w}")

    print()
    print("Weight of prime powers p^k (should be k for p > 2):")
    for p in [3, 5, 7]:
        for k in range(1, 5):
            n = p ** k
            w = total_holographic_weight(n)
            print(f"  {p}^{k} = {n:>6}: weight = {w}")
    print()

    print("Weight of composite numbers:")
    for n in [6, 12, 30, 60, 120, 210, 2310]:
        w = total_holographic_weight(n)
        # Compare with Omega(n) = sum of prime factor multiplicities
        omega = sum(holographic_depth(p, n) for p in primes_up_to(n) if n % p == 0)
        print(f"  n={n:>5}: weight = {w}  (Ω(n) = {omega})")
    print()


def demo_depth_additivity():
    """Verify depth additivity: depth(ab) = depth(a) + depth(b)."""
    print("=" * 60)
    print("DEPTH ADDITIVITY VERIFICATION")
    print("=" * 60)
    print()
    p = 2
    print(f"p = {p}: depth(a*b) = depth(a) + depth(b)")
    for a in [3, 4, 6, 8, 12]:
        for b in [5, 6, 10, 15]:
            da = holographic_depth(p, a)
            db = holographic_depth(p, b)
            dab = holographic_depth(p, a * b)
            check = "✓" if dab == da + db else "✗"
            print(f"  a={a:>3}, b={b:>3}: depth({a*b:>4}) = {dab} = {da} + {db} {check}")
    print()


def demo_boundary_projection():
    """Show boundary projection (mod p) as holographic projection."""
    print("=" * 60)
    print("BOUNDARY PROJECTION (HOLOGRAPHIC DICTIONARY)")
    print("=" * 60)
    print()
    for p in [5, 7]:
        print(f"Boundary at p = {p} (Z → Z/{p}Z):")
        for layer in range(4):
            elements = [n for n in range(1, 100) if holographic_depth(p, n) == layer][:8]
            residues = [n % p for n in elements]
            print(f"  Depth {layer}: {elements} → residues {residues}")
        print()


if __name__ == "__main__":
    demo_euler_product_convergence()
    demo_chebyshev_vs_primecount()
    demo_holographic_depth()
    demo_total_weight()
    demo_depth_additivity()
    demo_boundary_projection()


#!/usr/bin/env python3
"""
Visualization: Chebyshev Function and Prime Counting

Compares θ(n), π(n), and their asymptotic predictions from the
Prime Number Theorem, interpreted through the holographic lens.
"""

import math

def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    N = 5000
    ns = np.arange(2, N + 1)

    primes_list = sieve_of_eratosthenes(N)
    prime_set = set(primes_list)

    # Compute cumulative functions
    pi_vals = np.zeros(len(ns))
    theta_vals = np.zeros(len(ns))
    count = 0
    theta = 0.0
    for i, n in enumerate(ns):
        if n in prime_set:
            count += 1
            theta += math.log(n)
        pi_vals[i] = count
        theta_vals[i] = theta

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: π(n) vs n/ln(n)
    ax = axes[0, 0]
    ax.plot(ns, pi_vals, 'b-', linewidth=1, label='π(n) [bulk volume]')
    nlogn = ns / np.log(ns)
    ax.plot(ns, nlogn, 'r--', linewidth=1.5, label='n/ln(n) [asymptotic]')
    ax.set_xlabel('n')
    ax.set_ylabel('Count')
    ax.set_title('Prime Counting: Bulk Volume π(n)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: θ(n) vs n
    ax = axes[0, 1]
    ax.plot(ns, theta_vals, 'g-', linewidth=1, label='θ(n) [boundary area]')
    ax.plot(ns, ns.astype(float), 'r--', linewidth=1.5, label='n [asymptotic]')
    ax.set_xlabel('n')
    ax.set_ylabel('Value')
    ax.set_title('Chebyshev Theta: Boundary Area θ(n)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: θ(n)/n → 1 (PNT)
    ax = axes[1, 0]
    ratio = theta_vals / ns.astype(float)
    ax.plot(ns, ratio, 'purple', linewidth=1)
    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=1.5, label='y = 1')
    ax.set_xlabel('n')
    ax.set_ylabel('θ(n)/n')
    ax.set_title('Holographic Area-Volume Ratio θ(n)/n → 1')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0.8, 1.15)

    # Plot 4: π(n) ≤ θ_approx(n) verification
    ax = axes[1, 1]
    theta_approx = np.zeros(len(ns))
    ta = 0
    pc = 0
    for i, n in enumerate(ns):
        if n in prime_set:
            ta += int(math.log2(n)) + 1
            pc += 1
        theta_approx[i] = ta
    ax.plot(ns, theta_approx - pi_vals, 'orange', linewidth=1,
            label='θ_approx(n) - π(n) ≥ 0')
    ax.axhline(y=0, color='gray', linestyle='--')
    ax.set_xlabel('n')
    ax.set_ylabel('Difference')
    ax.set_title('Proved: π(n) ≤ θ_approx(n) (Theorem primeCount_le_chebyshev)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Holographic Primes: Boundary Area vs Bulk Volume', fontsize=14)
    plt.tight_layout()
    plt.savefig('chebyshev_prime_counting.png', dpi=150, bbox_inches='tight')
    print("Saved chebyshev_prime_counting.png")

except ImportError:
    print("matplotlib not available. Printing text output instead.")
    primes = sieve_of_eratosthenes(1000)
    prime_set = set(primes)
    print("n, π(n), θ(n), n/ln(n), θ(n)/n")
    count = 0
    theta = 0.0
    for n in range(2, 1001):
        if n in prime_set:
            count += 1
            theta += math.log(n)
        if n in [10, 50, 100, 200, 500, 1000]:
            print(f"{n}, {count}, {theta:.2f}, {n/math.log(n):.2f}, {theta/n:.4f}")


#!/usr/bin/env python3
"""
Visualization: Euler Product Convergence to Zeta Function

Shows how the partial Euler product converges to ζ(s) as more primes
are included, demonstrating the holographic partition function.
"""

import math

def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]

def euler_product_partial(s, N):
    product = 1.0
    for p in sieve_of_eratosthenes(N):
        product /= (1.0 - p ** (-s))
    return product

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, s in enumerate([2, 3, 4]):
        ax = axes[idx]
        exact_vals = {2: math.pi**2/6, 3: 1.2020569031595942, 4: math.pi**4/90}
        exact = exact_vals[s]

        Ns = list(range(2, 201))
        products = [euler_product_partial(s, N) for N in Ns]
        errors = [abs(p - exact) for p in products]

        ax.semilogy(Ns, errors, 'b-', linewidth=1.5, label=f'|Z_N({s}) - ζ({s})|')
        ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
        ax.set_xlabel('N (primes up to N)')
        ax.set_ylabel('|Error|')
        ax.set_title(f'Convergence for s = {s}\nζ({s}) = {exact:.6f}')
        ax.legend()
        ax.grid(True, alpha=0.3)

    plt.suptitle('Holographic Partition Function: Euler Product Convergence', fontsize=14)
    plt.tight_layout()
    plt.savefig('euler_product_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved euler_product_convergence.png")

except ImportError:
    print("matplotlib not available. Printing text output instead.")
    for s in [2, 3, 4]:
        exact_vals = {2: math.pi**2/6, 3: 1.2020569031595942, 4: math.pi**4/90}
        exact = exact_vals[s]
        print(f"\ns = {s}, ζ({s}) = {exact:.10f}")
        for N in [10, 50, 100, 500]:
            val = euler_product_partial(s, N)
            print(f"  N={N:>4}: product = {val:.10f}, error = {abs(val-exact):.2e}")


#!/usr/bin/env python3
"""
Visualization: Holographic Depth Landscape

Visualizes the p-adic valuation (holographic depth) of integers as a
heatmap across different primes, showing the "bulk geometry" of numbers.
"""

import math

def p_adic_valuation(p, n):
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        k += 1
        n //= p
    return k

def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    primes = sieve_of_eratosthenes(19)
    numbers = list(range(1, 101))

    depth_matrix = np.zeros((len(primes), len(numbers)))
    for i, p in enumerate(primes):
        for j, n in enumerate(numbers):
            depth_matrix[i, j] = p_adic_valuation(p, n)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(16, 10))

    im = ax1.imshow(depth_matrix, aspect='auto', cmap='YlOrRd',
                    interpolation='nearest')
    ax1.set_yticks(range(len(primes)))
    ax1.set_yticklabels([str(p) for p in primes])
    ax1.set_xlabel('n')
    ax1.set_ylabel('Prime p')
    ax1.set_title('Holographic Depth v_p(n): The Bulk Geometry of Numbers')
    plt.colorbar(im, ax=ax1, label='Depth (p-adic valuation)')

    # Total weight Omega(n) = sum of all valuations
    total_weights = [sum(p_adic_valuation(p, n) for p in sieve_of_eratosthenes(n))
                     for n in numbers]
    colors = ['red' if all(n % p != 0 for p in sieve_of_eratosthenes(n) if p < n)
              and n > 1 else 'steelblue' for n in numbers]

    ax2.bar(numbers, total_weights, color=colors, width=0.8)
    ax2.set_xlabel('n')
    ax2.set_ylabel('Total Holographic Weight Ω(n)')
    ax2.set_title('Total Holographic Weight (red = primes, weight 1)')
    ax2.set_xlim(0.5, 100.5)

    plt.tight_layout()
    plt.savefig('holographic_depth_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved holographic_depth_landscape.png")

except ImportError:
    print("matplotlib not available. Printing text output instead.")
    primes = [2, 3, 5, 7]
    print("Holographic depth v_p(n) for small primes:")
    header = "n  " + "  ".join(f"v_{p}" for p in primes)
    print(header)
    for n in range(1, 31):
        vals = "  ".join(f"{p_adic_valuation(p, n):>3}" for p in primes)
        print(f"{n:>2} {vals}")
