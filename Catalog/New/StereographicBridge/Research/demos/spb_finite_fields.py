#!/usr/bin/env python3
"""
SPB over Finite Fields: Deep Exploration of the p±1 Law

The SPB group over F_p lives on the projective line P¹(F_p) = F_p ∪ {∞}.
The group operation extends to ∞ as: spb(x, ∞) = -1/x, spb(∞, ∞) = 0.
The element ∞ has order 2 (corresponds to -1 on S¹).

This script verifies computationally that the SPB group has order:
  p+1 if p ≡ 3 (mod 4)
  p-1 if p ≡ 1 (mod 4)

Usage:
    python3 spb_finite_fields.py
"""

INF = 'inf'  # sentinel for ∞ in P¹(F_p)

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0: return False
    return True

def mod_inverse(a, p):
    return pow(a, p - 2, p)

def spb_fp(x, y, p):
    """SPB on P¹(F_p): handles ∞ properly.
    spb(x, y) = (x+y)/(1-xy) when defined
    spb(x, ∞) = -1/x for x ≠ 0
    spb(0, ∞) = ∞
    spb(∞, y) = -1/y for y ≠ 0
    spb(∞, 0) = ∞
    spb(∞, ∞) = 0
    """
    if x == INF and y == INF:
        return 0
    if x == INF:
        if y == 0:
            return INF
        return (-mod_inverse(y, p)) % p
    if y == INF:
        if x == 0:
            return INF
        return (-mod_inverse(x, p)) % p
    denom = (1 - x * y) % p
    numer = (x + y) % p
    if denom == 0:
        if numer == 0:
            # Both 0: this shouldn't happen for valid group elements
            return INF  # 0/0 case, treat as ∞
        return INF
    return (numer * mod_inverse(denom, p)) % p

def element_order(g, p):
    """Find the order of g in the SPB group over P¹(F_p).
    Computes smallest n>0 such that spb^n(0, g) = 0."""
    x = 0
    for step in range(1, 2 * p + 5):
        x = spb_fp(x, g, p)
        if x == 0:
            return step
    return None

def spb_group_order(p):
    """Find the order of the SPB group over P¹(F_p).
    Test all elements including ∞ to find the maximum order."""
    max_order = 1
    best_gen = None
    # Test all elements of P¹(F_p) = {0, 1, ..., p-1, ∞}
    candidates = list(range(p)) + [INF]
    for g in candidates:
        if g == 0:
            continue  # 0 is the identity
        ord_g = element_order(g, p)
        if ord_g is not None and ord_g > max_order:
            max_order = ord_g
            best_gen = g
    return max_order, best_gen

print("=" * 70)
print("SPB OVER FINITE FIELDS: THE p±1 LAW")
print("=" * 70)

print("\nThe SPB group lives on P¹(F_p) = F_p ∪ {∞}")
print("Group operation: spb(x,y) = (x+y)/(1-xy), extended to ∞")
print("Identity: 0, Inverse of x: -x, Element ∞ has order 2")

print("\n" + "=" * 70)
print("SECTION 1: Verification of the p±1 Law for primes 3..97")
print("=" * 70)

results = []
for p in range(3, 100):
    if not is_prime(p) or p == 2:
        continue
    order, gen = spb_group_order(p)
    predicted = p + 1 if p % 4 == 3 else p - 1
    match = order == predicted
    results.append((p, p % 4, predicted, order, gen, match))

print(f"\n{'p':>4} {'p%4':>4} {'predicted':>10} {'actual':>8} {'gen':>5} {'match':>6}")
print("-" * 45)
for p, mod4, pred, actual, gen, match in results:
    symbol = "✓" if match else "✗"
    gen_s = str(gen) if gen is not None else "?"
    if gen == INF:
        gen_s = "∞"
    print(f"{p:>4} {mod4:>4} {pred:>10} {actual:>8} {gen_s:>5} {symbol:>6}")

all_match = all(m for _, _, _, _, _, m in results)
print(f"\nAll primes 3..97 match prediction: {'YES ✓' if all_match else 'NO ✗'}")

print("\n" + "=" * 70)
print("SECTION 2: Cayley Transform Analysis")
print("=" * 70)

for p in [5, 7, 13]:
    print(f"\np = {p} ({'≡ 1' if p % 4 == 1 else '≡ 3'} mod 4)")

    i_val = None
    for a in range(p):
        if (a * a + 1) % p == 0:
            i_val = a
            break

    if i_val is not None:
        print(f"  √(-1) = {i_val} exists in F_{p}")
        # C'(x) = (1+ix)/(1-ix)
        images = {}
        for x in range(p):
            denom = (1 - i_val * x) % p
            if denom == 0:
                images[x] = INF
                continue
            numer = (1 + i_val * x) % p
            c = (numer * mod_inverse(denom, p)) % p
            images[x] = c
        images[INF] = (p - 1)  # C'(∞) = i/(-i) = -1 = p-1 mod p
        print(f"  Cayley images (in F_{p}*):")
        for x in sorted([k for k in images if k != INF]) + ([INF] if INF in images else []):
            x_str = str(x) if x != INF else "∞"
            v_str = str(images[x]) if images[x] != INF else "∞"
            print(f"    C'({x_str}) = {v_str}")
        img_set = set(v for v in images.values() if v != INF)
        print(f"  Distinct finite images: {sorted(img_set)}")
    else:
        print(f"  √(-1) does NOT exist in F_{p}")
        print(f"  Cayley images live in F_{{p²}} (as a + bi):")
        for x in range(p):
            norm = (1 + x * x) % p
            if norm == 0:
                print(f"    C'({x}) = ∞  (pole)")
                continue
            norm_inv = mod_inverse(norm, p)
            # C'(x) = (1+ix)/(1-ix) = ((1+ix)(1+ix)) / (1+x²)
            # Actually: (1+ix)/(1-ix) * conj/(conj) = (1+ix)(1+ix)/(1+x²) = (1-x²+2ix)/(1+x²)
            re = ((1 - x * x) * norm_inv) % p
            im = (2 * x * norm_inv) % p
            n_check = (re * re + im * im) % p
            print(f"    C'({x}) = {re} + {im}i  (norm mod p = {n_check})")
        print(f"  All norms = 1 mod p (norm-1 subgroup has order p+1)")

print("\n" + "=" * 70)
print("SECTION 3: Group Structure Details")
print("=" * 70)

for p in [5, 7, 11, 13, 17, 19, 23, 29]:
    order, gen = spb_group_order(p)
    predicted = p + 1 if p % 4 == 3 else p - 1

    # Find all element orders
    elem_orders = {}
    candidates = list(range(1, p)) + [INF]
    for g in candidates:
        eo = element_order(g, p)
        if eo is not None:
            key = str(g) if g != INF else "∞"
            elem_orders[key] = eo

    # Find generators
    generators = [g for g, o in elem_orders.items() if o == order]

    # Divisors of group order
    divisors = sorted(d for d in range(1, order + 1) if order % d == 0)

    print(f"\np = {p} (≡ {p%4} mod 4)")
    print(f"  Group order = {order} (predicted {predicted}) {'✓' if order == predicted else '✗'}")
    print(f"  Generators: {generators}")
    print(f"  All element orders: {sorted(set(elem_orders.values()))}")
    print(f"  Divisors of {order}: {divisors}")
    print(f"  #generators = {len(generators)}")

print("\n" + "=" * 70)
print("SECTION 4: Extended Verification (primes up to 200)")
print("=" * 70)

total = 0
matches = 0
failures = []
for p in range(3, 200):
    if not is_prime(p) or p == 2:
        continue
    total += 1
    order, _ = spb_group_order(p)
    predicted = p + 1 if p % 4 == 3 else p - 1
    if order == predicted:
        matches += 1
    else:
        failures.append((p, predicted, order))

print(f"\nVerified {matches}/{total} primes match the p±1 law")
if failures:
    print("Failures:")
    for p, pred, actual in failures:
        print(f"  p={p}: predicted {pred}, got {actual}")
else:
    print("No failures! The p±1 law holds for all odd primes < 200.")

print(f"\nSuccess rate: {100*matches/total:.1f}%")

print("\n" + "=" * 70)
print("SECTION 5: Orbit Visualization (p=7)")
print("=" * 70)

p = 7
order, gen = spb_group_order(p)
print(f"\np = {p}, generator g = {gen}, group order = {order}")
print(f"Full orbit of 0 under spb(·, {gen}):")
x = 0
for step in range(order + 1):
    x_str = str(x) if x != INF else "∞"
    print(f"  step {step}: {x_str}")
    if step < order:
        x = spb_fp(x, gen, p)

print("\n" + "=" * 70)
print("COMPLETE")
print("=" * 70)
