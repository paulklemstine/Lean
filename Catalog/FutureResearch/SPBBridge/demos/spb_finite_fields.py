#!/usr/bin/env python3
"""
SPB over Finite Fields: The p±1 Law

Computes the SPB group over F_p correctly using projective arithmetic
(handling ∞ as a group element).

The SPB group over F_p is the set P^1(F_p) = F_p ∪ {∞} with the operation
spb(x, y) = (x + y) / (1 - x*y), extended to handle ∞.

Key result: |SPB(F_p)| = p + 1 if p ≡ 3 (mod 4), p - 1 if p ≡ 1 (mod 4).
"""

INF = 'inf'

def spb_fp(x, y, p):
    """SPB over F_p ∪ {∞}, returning element in F_p or 'inf'"""
    if x == INF and y == INF:
        return 0  # spb(∞, ∞) corresponds to angle addition: ∞ = tan(π/2), so 2·(π/2) = π → tan(π) = 0
    if x == INF:
        if y == 0:
            return INF
        return (-(pow(y, p - 2, p))) % p  # -1/y mod p
    if y == INF:
        if x == 0:
            return INF
        return (-(pow(x, p - 2, p))) % p  # -1/x mod p

    denom = (1 - x * y) % p
    if denom == 0:
        return INF
    return ((x + y) * pow(denom, p - 2, p)) % p

def spb_group_order(p):
    """
    Compute the order of the SPB group over F_p.

    Strategy: for each candidate generator g, compute the orbit
    {0, g, spb(g,g), spb(spb(g,g),g), ...} by iterating x ↦ spb(x, g).
    The order of g divides the group order. The group order is the LCM
    of all element orders, or equivalently the max cyclic subgroup size.
    """
    from math import gcd

    def lcm(a, b):
        return a * b // gcd(a, b)

    group_order = 1

    for g in list(range(p)) + [INF]:
        x = 0  # start from identity
        order = 0
        for step in range(1, p + 3):
            x = spb_fp(x, g, p)
            if x == 0:
                order = step
                break
        if order > 0:
            group_order = lcm(group_order, order)

    return group_order

def verify_p_pm1_law():
    """Verify the p±1 law for all odd primes up to 200"""
    from sympy import primerange

    print("The p±1 Law for SPB Groups over Finite Fields")
    print("=" * 65)
    print()
    print(f"  {'p':>5s}  {'p%4':>4s}  {'predicted':>10s}  {'computed':>10s}  {'match':>5s}")
    print(f"  {'─'*5}  {'─'*4}  {'─'*10}  {'─'*10}  {'─'*5}")

    all_match = True
    for p in primerange(3, 200):
        mod4 = p % 4
        predicted = p + 1 if mod4 == 3 else p - 1
        computed = spb_group_order(p)
        match = "✓" if computed == predicted else "✗"
        if computed != predicted:
            all_match = False
        print(f"  {p:5d}  {mod4:4d}  {predicted:10d}  {computed:10d}  {match:>5s}")

    print()
    print(f"  All primes match: {'YES ✓' if all_match else 'NO ✗'}")
    return all_match

def analyze_group_structure(p):
    """Analyze the detailed structure of the SPB group over F_p"""
    print(f"\nDetailed SPB Group Analysis for p = {p}")
    print("-" * 50)

    # Find all element orders
    orders = {}
    elements = list(range(p)) + [INF]

    for g in elements:
        x = 0
        for step in range(1, p + 3):
            x = spb_fp(x, g, p)
            if x == 0:
                orders[g] = step
                break
        else:
            orders[g] = 0  # didn't return (shouldn't happen)

    # Group elements by order
    by_order = {}
    for elem, order in orders.items():
        by_order.setdefault(order, []).append(elem)

    print(f"  Group elements: {len(elements)} = p + 1 = {p + 1}")
    print(f"  Element orders:")
    for order in sorted(by_order.keys()):
        elems = by_order[order]
        if len(elems) <= 10:
            print(f"    Order {order:4d}: {elems}")
        else:
            print(f"    Order {order:4d}: {len(elems)} elements")

    # Find generators (elements of maximal order)
    max_order = max(orders.values())
    generators = [g for g, o in orders.items() if o == max_order]
    print(f"  Maximal order: {max_order}")
    print(f"  Generators: {generators[:10]}{'...' if len(generators) > 10 else ''}")

    # Check if cyclic
    mod4 = p % 4
    expected = p + 1 if mod4 == 3 else p - 1
    is_cyclic = max_order == expected
    print(f"  Cyclic: {'YES ✓' if is_cyclic else 'NO ✗'} (max order = {max_order}, group order = {expected})")

    # Cayley table verification (small p only)
    if p <= 7:
        print(f"\n  Cayley table (spb mod {p}):")
        header = "  " + " "*6 + "".join(f"{str(e):>6s}" for e in elements)
        print(header)
        for x in elements:
            row = f"  {str(x):>5s}:"
            for y in elements:
                result = spb_fp(x, y, p)
                row += f"{str(result):>6s}"
            print(row)

if __name__ == "__main__":
    try:
        from sympy import primerange
        has_sympy = True
    except ImportError:
        has_sympy = False

    if has_sympy:
        verify_p_pm1_law()
    else:
        # Manual prime list
        primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
                  53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
        print("The p±1 Law for SPB Groups over Finite Fields")
        print("=" * 65)
        print()
        print(f"  {'p':>5s}  {'p%4':>4s}  {'predicted':>10s}  {'computed':>10s}  {'match':>5s}")
        print(f"  {'─'*5}  {'─'*4}  {'─'*10}  {'─'*10}  {'─'*5}")

        all_match = True
        for p in primes:
            mod4 = p % 4
            predicted = p + 1 if mod4 == 3 else p - 1
            computed = spb_group_order(p)
            match = "✓" if computed == predicted else "✗"
            if computed != predicted:
                all_match = False
            print(f"  {p:5d}  {mod4:4d}  {predicted:10d}  {computed:10d}  {match:>5s}")
        print(f"\n  All primes match: {'YES ✓' if all_match else 'NO ✗'}")

    # Detailed analysis for small primes
    for p in [3, 5, 7, 11, 13]:
        analyze_group_structure(p)
