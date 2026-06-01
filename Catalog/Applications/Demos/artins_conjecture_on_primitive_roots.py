#!/usr/bin/env python3
"""
Demo: Artin's Conjecture on Primitive Roots

Demonstrates the key results from our formalization:
1. The order formula: ord(g^k) = (p-1)/gcd(p-1, k)
2. Primitive root density and the Artin constant
3. Safe prime primitive root criterion
4. Product of primitive roots
"""

from algorithms import (
    is_prime, is_primitive_root, artin_counting_function,
    artin_sieve_weight, artin_constant_approximation,
    is_safe_prime, primitive_root_power_set, euler_totient,
    prime_factors, multiplicative_order, gcd
)


def demo_order_formula():
    """Demonstrate: ord(g^k) = (p-1)/gcd(p-1, k)"""
    print("=" * 60)
    print("THEOREM: Order of a Power (order_of_power_eq)")
    print("For generator g of (Z/pZ)*, ord(g^k) = (p-1)/gcd(p-1, k)")
    print("=" * 60)
    
    p = 13
    g = 2  # 2 is a primitive root mod 13
    n = p - 1
    
    print(f"\np = {p}, g = {g} (primitive root), p-1 = {n}")
    print(f"{'k':>4} {'g^k mod p':>10} {'ord(g^k)':>10} {'(p-1)/gcd':>10} {'Match':>8}")
    print("-" * 46)
    
    for k in range(n):
        gk = pow(g, k, p)
        if gk == 0:
            continue
        actual = multiplicative_order(gk, p)
        predicted = n // gcd(n, k) if k > 0 else 1
        match = "✓" if actual == predicted else "✗"
        print(f"{k:>4} {gk:>10} {actual:>10} {predicted:>10} {match:>8}")


def demo_coprime_criterion():
    """Demonstrate: g^k is primitive root iff gcd(k, p-1) = 1"""
    print("\n" + "=" * 60)
    print("THEOREM: Power is Primitive Root iff Coprime")
    print("g^k is a primitive root ⟺ gcd(k, p-1) = 1")
    print("=" * 60)
    
    p = 11
    g = 2  # primitive root mod 11
    n = p - 1  # = 10
    
    print(f"\np = {p}, g = {g}, p-1 = {n}")
    print(f"Prime factors of {n}: {prime_factors(n)}")
    
    prs = primitive_root_power_set(g, p)
    print(f"\nPrimitive root power set (k with gcd(k,{n})=1): {prs}")
    print(f"Cardinality: {len(prs)} = φ({n}) = {euler_totient(n)}")
    
    print(f"\nCorresponding primitive roots mod {p}:")
    for k in prs:
        print(f"  g^{k} = {g}^{k} ≡ {pow(g, k, p)} (mod {p})")


def demo_sq_not_primroot():
    """Demonstrate: g² is never a primitive root for p ≥ 3"""
    print("\n" + "=" * 60)
    print("THEOREM: g² is Never a Primitive Root (p ≥ 3)")
    print("Since p-1 is even, ord(g²) = (p-1)/2")
    print("=" * 60)
    
    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]
    print(f"\n{'p':>4} {'g':>4} {'g²':>5} {'ord(g²)':>8} {'(p-1)/2':>8} {'Match':>6}")
    print("-" * 40)
    
    for p in primes:
        for g in range(2, p):
            if is_primitive_root(g, p):
                g2 = pow(g, 2, p)
                ord_g2 = multiplicative_order(g2, p)
                half = (p - 1) // 2
                match = "✓" if ord_g2 == half else "✗"
                print(f"{p:>4} {g:>4} {g2:>5} {ord_g2:>8} {half:>8} {match:>6}")
                break


def demo_primroot_nonsquare():
    """Demonstrate: every primitive root is a quadratic non-residue"""
    print("\n" + "=" * 60)
    print("THEOREM: Primitive Roots are Quadratic Non-Residues")
    print("If ord(u) = p-1 then u is not a square mod p")
    print("=" * 60)
    
    p = 13
    squares = set()
    for a in range(1, p):
        squares.add(pow(a, 2, p))
    
    print(f"\np = {p}")
    print(f"Quadratic residues mod {p}: {sorted(squares)}")
    print(f"Primitive roots mod {p}: ", end="")
    prs = [a for a in range(1, p) if is_primitive_root(a, p)]
    print(prs)
    print(f"Intersection (should be empty): {sorted(set(prs) & squares)}")


def demo_product_of_primroots():
    """Demonstrate: product of all primitive roots ≡ 1 (mod p) for p ≥ 5"""
    print("\n" + "=" * 60)
    print("THEOREM: Product of Primitive Roots = 1 (mod p), p ≥ 5")
    print("Primitive roots pair as (u, u⁻¹) with product 1")
    print("=" * 60)
    
    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    
    print(f"\n{'p':>4} {'Primitive roots':>40} {'Product mod p':>14}")
    print("-" * 62)
    
    for p in primes:
        prs = [a for a in range(1, p) if is_primitive_root(a, p)]
        product = 1
        for a in prs:
            product = (product * a) % p
        print(f"{p:>4} {str(prs):>40} {product:>14}")


def demo_artin_density():
    """Demonstrate the Artin counting function and density"""
    print("\n" + "=" * 60)
    print("ARTIN DENSITY: π_2(x) / π(x) → C ≈ 0.3739558...")
    print("=" * 60)
    
    C = artin_constant_approximation(5000)
    print(f"\nArtin constant C ≈ {C:.10f}")
    
    bounds = [100, 500, 1000, 5000, 10000, 50000]
    
    print(f"\n{'x':>8} {'π_2(x)':>8} {'π(x)':>8} {'Ratio':>10} {'|Ratio - C|':>12}")
    print("-" * 52)
    
    for x in bounds:
        pi_2 = artin_counting_function(2, x)
        pi_x = sum(1 for p in range(2, x + 1) if is_prime(p))
        ratio = pi_2 / pi_x if pi_x > 0 else 0
        error = abs(ratio - C)
        print(f"{x:>8} {pi_2:>8} {pi_x:>8} {ratio:>10.6f} {error:>12.6f}")


def demo_safe_primes():
    """Demonstrate safe prime primitive root criterion"""
    print("\n" + "=" * 60)
    print("THEOREM: Safe Prime Criterion (2 checks suffice)")
    print("For p = 2q+1 (q prime): check u^q ≠ 1 and u² ≠ 1 mod p")
    print("=" * 60)
    
    safe_primes = []
    for p in range(5, 200):
        is_safe, q = is_safe_prime(p)
        if is_safe and q >= 3:
            safe_primes.append((p, q))
    
    print(f"\nSafe primes p = 2q+1 with q ≥ 3:")
    for p, q in safe_primes[:10]:
        prs = [a for a in range(2, p) if is_primitive_root(a, p)]
        nonsq_count = sum(1 for a in range(1, p)
                         if pow(a, (p-1)//2, p) != 1 and a != p-1)
        print(f"  p={p:>4}, q={q:>3}: {len(prs)} primitive roots, "
              f"non-trivial non-squares match primitive roots: "
              f"{len(prs) == nonsq_count}")


def demo_sieve_weights():
    """Demonstrate Artin sieve weights"""
    print("\n" + "=" * 60)
    print("ARTIN SIEVE WEIGHTS: φ(p-1)/(p-1)")
    print("=" * 60)
    
    primes = [p for p in range(3, 100) if is_prime(p)]
    
    print(f"\n{'p':>4} {'p-1':>5} {'φ(p-1)':>7} {'Weight':>10} {'Factorization of p-1':>25}")
    print("-" * 55)
    
    for p in primes[:20]:
        n = p - 1
        phi = euler_totient(n)
        weight = phi / n
        factors = prime_factors(n)
        print(f"{p:>4} {n:>5} {phi:>7} {weight:>10.4f} {str(factors):>25}")


if __name__ == "__main__":
    demo_order_formula()
    demo_coprime_criterion()
    demo_sq_not_primroot()
    demo_primroot_nonsquare()
    demo_product_of_primroots()
    demo_artin_density()
    demo_safe_primes()
    demo_sieve_weights()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Artin Density Convergence

Shows how π_a(x)/π(x) converges to the Artin constant as x → ∞.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import gcd, isqrt


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    r, d = 0, n - 1
    while d % 2 == 0: r += 1; d //= 2
    for a in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]:
        if a >= n: continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1: continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1: break
        else: return False
    return True


def prime_factors(n):
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0: n //= d
        d += 1
    if n > 1: factors.append(n)
    return factors


def is_primitive_root(a, p):
    if a % p == 0: return False
    n = p - 1
    for q in prime_factors(n):
        if pow(a, n // q, p) == 1: return False
    return True


def artin_constant(num_primes=5000):
    product = 1.0
    count = 0
    n = 2
    while count < num_primes:
        if is_prime(n):
            product *= (1 - 1 / (n * (n - 1)))
            count += 1
        n += 1
    return product


def compute_density_data(a, max_x=20000):
    xs = []
    ratios = []
    pi_a = 0
    pi_x = 0
    
    for p in range(2, max_x + 1):
        if is_prime(p):
            pi_x += 1
            if p >= 3 and is_primitive_root(a, p):
                pi_a += 1
            if pi_x > 0 and p > 10:
                xs.append(p)
                ratios.append(pi_a / pi_x)
    
    return xs, ratios


# Compute data
C = artin_constant()

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Density convergence for a=2
xs2, ratios2 = compute_density_data(2, 20000)
axes[0, 0].plot(xs2, ratios2, 'b-', alpha=0.7, linewidth=0.8, label='π₂(x)/π(x)')
axes[0, 0].axhline(y=C, color='r', linestyle='--', linewidth=1.5, label=f'Artin constant C ≈ {C:.6f}')
axes[0, 0].set_xlabel('x')
axes[0, 0].set_ylabel('π₂(x) / π(x)')
axes[0, 0].set_title('Artin Density for a = 2')
axes[0, 0].legend()
axes[0, 0].set_ylim(0.3, 0.45)
axes[0, 0].grid(True, alpha=0.3)

# Plot 2: Multiple values of a
for a, color, label in [(2, 'blue', 'a=2'), (3, 'green', 'a=3'), 
                         (5, 'orange', 'a=5'), (6, 'purple', 'a=6')]:
    xs, ratios = compute_density_data(a, 15000)
    axes[0, 1].plot(xs, ratios, color=color, alpha=0.6, linewidth=0.8, label=label)
axes[0, 1].axhline(y=C, color='r', linestyle='--', linewidth=1.5, label=f'C ≈ {C:.4f}')
axes[0, 1].set_xlabel('x')
axes[0, 1].set_ylabel('Density')
axes[0, 1].set_title('Artin Density for Multiple Candidates')
axes[0, 1].legend(fontsize=8)
axes[0, 1].set_ylim(0.25, 0.55)
axes[0, 1].grid(True, alpha=0.3)

# Plot 3: Sieve weights φ(p-1)/(p-1)
primes = [p for p in range(3, 500) if is_prime(p)]
def euler_totient(n):
    result = n
    for p in prime_factors(n):
        result -= result // p
    return result

weights = [euler_totient(p-1)/(p-1) for p in primes]
axes[1, 0].scatter(primes, weights, s=8, alpha=0.6, c='steelblue')
axes[1, 0].axhline(y=C, color='r', linestyle='--', linewidth=1.5, label=f'Artin constant ≈ {C:.4f}')
axes[1, 0].set_xlabel('Prime p')
axes[1, 0].set_ylabel('φ(p-1)/(p-1)')
axes[1, 0].set_title('Artin Sieve Weights')
axes[1, 0].legend()
axes[1, 0].grid(True, alpha=0.3)

# Plot 4: Primitive root power set visualization for p=37
p = 37
g = 2  # primitive root mod 37
n = p - 1

coprime_mask = [1 if gcd(k, n) == 1 else 0 for k in range(n)]
orders = []
for k in range(n):
    gk = pow(g, k, p)
    if gk == 0:
        orders.append(0)
    else:
        ord_k = 1
        cur = gk
        while cur != 1:
            cur = (cur * gk) % p
            ord_k += 1
        orders.append(ord_k)

colors = ['red' if c == 1 else 'lightgray' for c in coprime_mask]
axes[1, 1].bar(range(n), orders, color=colors, edgecolor='gray', linewidth=0.3)
axes[1, 1].axhline(y=n, color='darkred', linestyle='--', linewidth=1, label=f'p-1 = {n}')
axes[1, 1].set_xlabel('Exponent k')
axes[1, 1].set_ylabel('ord(g^k)')
axes[1, 1].set_title(f'Orders of Powers of g={g} mod p={p}\n(red = primitive root, gcd(k,{n})=1)')
axes[1, 1].legend()

plt.tight_layout()
plt.savefig('artin_density_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: artin_density_visualization.png")
