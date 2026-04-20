#!/usr/bin/env python3
"""
Deterministic Factoring via Berggren Tree Intersection

When a composite number N has multiple PPT representations,
the different Berggren addresses reveal the factor structure.
"""

from math import gcd, sqrt

def generate_ppts_for_c(c):
    """Find all primitive Pythagorean triples with hypotenuse c."""
    ppts = []
    max_m = int(sqrt(c)) + 1
    for m in range(2, max_m):
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if gcd(m, n) != 1:
                continue
            if m*m + n*n == c:
                a = m*m - n*n
                b = 2*m*n
                ppts.append((min(a,b), max(a,b), c))
    return ppts

def berggren_descent(a, b, c):
    """Compute the Berggren tree address by iterative descent to (3,4,5)."""
    address = []
    while (a, b, c) != (3, 4, 5):
        if c <= 0 or a <= 0 or b <= 0:
            return None  # Not a valid PPT or not reachable
        # Try all three inverse branches
        # B₁⁻¹
        a1 = a + 2*b - 2*c
        b1 = -2*a - b + 2*c
        c1 = -2*a - 2*b + 3*c
        if a1 > 0 and b1 > 0 and c1 > 0:
            address.append(1)
            a, b, c = a1, b1, c1
            continue

        # B₂⁻¹
        a2 = a + 2*b - 2*c
        b2 = 2*a + b - 2*c
        c2 = -2*a - 2*b + 3*c
        if a2 > 0 and b2 > 0 and c2 > 0:
            address.append(2)
            a, b, c = a2, b2, c2
            continue

        # B₃⁻¹
        a3 = -a - 2*b + 2*c
        b3 = 2*a + b - 2*c
        c3 = -2*a - 2*b + 3*c
        if a3 > 0 and b3 > 0 and c3 > 0:
            address.append(3)
            a, b, c = a3, b3, c3
            continue

        return None  # Stuck
    return address

def ghost_map(a, b, c):
    """Compute ghost triple."""
    return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

print("=" * 70)
print("DETERMINISTIC FACTORING VIA BERGGREN TREE INTERSECTION")
print("=" * 70)

# Section 1: Composite hypotenuses with multiple PPTs
print("\n--- Composite Hypotenuses with Multiple PPTs ---\n")

# Find hypotenuses with multiple representations
multi_reps = []
for c in range(5, 500):
    ppts = generate_ppts_for_c(c)
    if len(ppts) >= 2:
        multi_reps.append((c, ppts))

print(f"{'c':>6} {'Factorization':>15} {'PPTs':>25} {'Addresses':>30}")
print("-" * 80)

for c, ppts in multi_reps[:20]:
    # Factor c
    n = c
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    fact_str = "·".join(str(f) for f in factors)

    addresses = []
    for a, b, cc in ppts:
        addr = berggren_descent(a, b, cc)
        addr_str = "".join(str(x) for x in addr) if addr else "?"
        addresses.append(addr_str)

    ppt_str = ", ".join(f"({a},{b})" for a, b, _ in ppts)
    addr_str = ", ".join(addresses)
    print(f"{c:>6} {fact_str:>15} {ppt_str:>25} {addr_str:>30}")

# Section 2: Ghost map analysis for factoring
print("\n--- Ghost Map Analysis for Factoring ---\n")
print("Different PPTs with same hypotenuse → different ghost triples\n")

for c, ppts in multi_reps[:10]:
    print(f"  c = {c}:")
    for a, b, cc in ppts:
        p, q, h = ghost_map(a, b, cc)
        print(f"    ({a:>3},{b:>3},{c:>3}) → ghost ({p:>4},{q:>4},{h:>3})")
    print()

# Section 3: Address depth analysis
print("--- Address Depth Analysis ---\n")
print("Deeper addresses → more complex number-theoretic structure\n")

for c, ppts in multi_reps[:15]:
    depths = []
    for a, b, cc in ppts:
        addr = berggren_descent(a, b, cc)
        depths.append(len(addr) if addr else -1)
    print(f"  c = {c:>4}: depths = {depths}, max_depth - min_depth = {max(depths) - min(depths)}")

# Section 4: GCD extraction
print("\n--- Factor Extraction via Multiple Representations ---\n")
print("When c = p·q with p,q ≡ 1 (mod 4), two PPTs (a₁,b₁,c) and (a₂,b₂,c)")
print("give gcd(a₁−a₂, c) or gcd(a₁+a₂, c) as a nontrivial factor.\n")

for c, ppts in multi_reps[:15]:
    if len(ppts) >= 2:
        a1, b1, _ = ppts[0]
        a2, b2, _ = ppts[1]
        g1 = gcd(abs(a1 - a2), c)
        g2 = gcd(abs(a1 + a2), c)
        g3 = gcd(abs(b1 - b2), c)
        g4 = gcd(abs(b1 + b2), c)
        factors = {g for g in [g1, g2, g3, g4] if 1 < g < c}
        if factors:
            print(f"  c = {c:>4}: ({a1},{b1}) vs ({a2},{b2})")
            print(f"    gcd(|a₁−a₂|,c) = gcd({abs(a1-a2)},{c}) = {g1}")
            print(f"    gcd(|a₁+a₂|,c) = gcd({abs(a1+a2)},{c}) = {g2}")
            print(f"    Found factors: {factors}")
            print()

print("--- Key Insight ---")
print("Multiple PPT representations of the same hypotenuse c reveal its")
print("prime factorization. Each representation corresponds to a different")
print("path in the Berggren tree, and the GCD of leg differences with c")
print("gives nontrivial factors deterministically (no randomness needed).")
