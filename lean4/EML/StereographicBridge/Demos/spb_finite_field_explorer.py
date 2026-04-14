#!/usr/bin/env python3
"""
SPB over Finite Fields — Detailed Explorer

Explores the group structure of (𝔽_p, spb) where spb(x,y) = (x+y)/(1-xy) mod p.

Key discoveries:
1. The SPB group over 𝔽_p is isomorphic to the multiplicative group of
   norm-1 elements in 𝔽_{p²}.
2. For p ≡ 3 (mod 4): |SPB group| = p + 1 (non-split case)
   For p ≡ 1 (mod 4): |SPB group| = p - 1 (split case)
3. The discrete logarithm in the SPB group reduces to DLP in 𝔽_{p²}*.

This has implications for:
- Cryptographic applications (or lack thereof — see analysis)
- Computational number theory
- Coding theory
"""

import numpy as np
from collections import defaultdict
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


def mod_inv(a, p):
    """Modular inverse via Fermat's little theorem"""
    if a % p == 0:
        return None
    return pow(a, p - 2, p)


def spb_mod(x, y, p):
    """SPB operation over Z/pZ"""
    denom = (1 - x * y) % p
    inv = mod_inv(denom, p)
    if inv is None:
        return None  # pole
    return ((x + y) * inv) % p


def find_spb_group(p):
    """Find all elements and structure of the SPB group over 𝔽_p"""
    # Elements: all x ∈ 𝔽_p such that for all y in the group, 1-xy ≠ 0 mod p
    # In practice, we include all elements and track where poles occur.

    elements = set()
    poles = set()

    # Start with 0 (identity) and build up by closing under spb
    frontier = {0}
    elements = {0}

    # Add all generators and close
    for g in range(p):
        # Check if g has finite order
        val = 0
        order = 0
        valid = True
        for k in range(1, 2 * p + 3):
            result = spb_mod(g, val, p)
            if result is None:
                valid = False
                break
            val = result
            if val == 0:
                order = k
                break

        if valid and order > 0:
            # Add all powers
            val = 0
            for k in range(order):
                val = spb_mod(g, val, p) if k > 0 else g
                if val is not None:
                    elements.add(val)

    return elements


def analyze_group(p):
    """Full analysis of the SPB group over 𝔽_p"""
    print(f"\n{'='*50}")
    print(f"  SPB Group Analysis: 𝔽_{p}")
    print(f"{'='*50}")

    # Find orders of all elements
    orders = {}
    for g in range(p):
        val = 0
        order = None
        for k in range(1, 2 * p + 3):
            result = spb_mod(g, val, p)
            if result is None:
                order = None
                break
            val = result
            if val == 0:
                order = k
                break
        orders[g] = order

    # Report
    valid_elements = [g for g, o in orders.items() if o is not None]
    max_order = max(o for o in orders.values() if o is not None)

    print(f"\n  p mod 4 = {p % 4}")
    print(f"  Number of elements with finite order: {len(valid_elements)}")
    print(f"  Maximum element order: {max_order}")
    print(f"  Expected group order: {'p+1=' + str(p+1) if p % 4 == 3 else 'p-1=' + str(p-1)}")

    # Find generators (elements of maximum order)
    generators = [g for g, o in orders.items() if o == max_order]
    print(f"  Generators (elements of max order): {generators[:10]}{'...' if len(generators) > 10 else ''}")
    print(f"  Number of generators: {len(generators)}")
    print(f"  Euler φ({max_order}) = {euler_phi(max_order)} (should match)")

    # Order distribution
    order_dist = defaultdict(int)
    for g, o in orders.items():
        if o is not None:
            order_dist[o] += 1

    print(f"\n  Order distribution:")
    for order in sorted(order_dist.keys()):
        count = order_dist[order]
        print(f"    Order {order:>4}: {count:>4} elements")

    # Is it cyclic?
    is_cyclic = max_order == len(valid_elements)
    print(f"\n  Cyclic group? {'YES' if is_cyclic else 'NO'}")
    if is_cyclic:
        print(f"  ≅ ℤ/{max_order}ℤ")

    return orders, valid_elements, max_order


def euler_phi(n):
    """Euler's totient function"""
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def spb_cayley_table(p):
    """Print the Cayley table for the SPB group over 𝔽_p"""
    print(f"\n  Cayley table for SPB over 𝔽_{p}:")
    elements = list(range(p))

    # Header
    print(f"  spb |", end="")
    for y in elements:
        print(f" {y:>3}", end="")
    print()
    print(f"  ----+" + "----" * p)

    for x in elements:
        print(f"  {x:>3} |", end="")
        for y in elements:
            r = spb_mod(x, y, p)
            print(f" {str(r) if r is not None else '∞':>3}", end="")
        print()


def cryptographic_analysis(p):
    """Analyze SPB group for cryptographic potential"""
    print(f"\n{'='*50}")
    print(f"  Cryptographic Analysis: 𝔽_{p}")
    print(f"{'='*50}")

    # Find a generator
    for g in range(1, p):
        val = 0
        order = None
        for k in range(1, 2 * p + 3):
            result = spb_mod(g, val, p)
            if result is None:
                break
            val = result
            if val == 0:
                order = k
                break
        if order is not None and order > p // 2:
            break

    if order is None:
        print("  No suitable generator found.")
        return

    print(f"\n  Generator g = {g}, order = {order}")
    print(f"\n  Diffie-Hellman analogue:")
    print(f"    Public: p = {p}, g = {g}")

    # Alice picks secret a
    a = 7 % (order - 1) + 1
    alice_public = 0
    val = 0
    for _ in range(a):
        val = spb_mod(g, val, p)
    alice_public = val
    print(f"    Alice: secret a = {a}, public A = spb^{a}(g) = {alice_public}")

    # Bob picks secret b
    b = 11 % (order - 1) + 1
    val = 0
    for _ in range(b):
        val = spb_mod(g, val, p)
    bob_public = val
    print(f"    Bob:   secret b = {b}, public B = spb^{b}(g) = {bob_public}")

    # Shared secret
    val = 0
    for _ in range(a * b):
        val = spb_mod(g, val, p)
    shared = val
    print(f"    Shared secret: spb^{a*b}(g) = {shared}")

    # Verify via Alice's path
    val = 0
    for _ in range(a):
        val = spb_mod(bob_public, val, p)
        if val is None:
            print("    ⚠ Verification failed (pole encountered)")
            return
    print(f"    Alice computes spb^a(B) = {val} {'✓' if val == shared else '✗'}")

    print(f"\n  Security note:")
    print(f"    The SPB DLP reduces to the standard DLP in 𝔽_{{p²}}*")
    print(f"    via the Cayley transform. Therefore SPB-DH offers no")
    print(f"    additional security over standard DH — but the")
    print(f"    geometric interpretation is more natural.")


if __name__ == '__main__':
    print("╔" + "═" * 48 + "╗")
    print("║  SPB OVER FINITE FIELDS — DETAILED EXPLORER   ║")
    print("╚" + "═" * 48 + "╝")

    # Small primes: detailed analysis
    for p in [5, 7]:
        spb_cayley_table(p)

    # Analysis for several primes
    for p in [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        analyze_group(p)

    # Cryptographic demo
    cryptographic_analysis(47)

    print("\n\nDone!")
