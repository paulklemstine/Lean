#!/usr/bin/env python3
"""
SPB Number Theory Demo
========================
Explores number-theoretic aspects of the SPB operation:
- Pythagorean triple generation
- Brahmagupta-Fibonacci identity as SPB
- Finite field SPB groups
- The p±1 law
- Connection to Gaussian integers
"""

from fractions import Fraction
import math

def spb_frac(x, y):
    """SPB over exact rationals."""
    denom = 1 - x * y
    if denom == 0:
        return None  # pole
    return (x + y) / denom

def spb_mod(x, y, p):
    """SPB over F_p = Z/pZ."""
    denom = (1 - x * y) % p
    if denom == 0:
        return None  # pole
    # modular inverse
    return ((x + y) * pow(int(denom), -1, p)) % p

INF = 'inf'  # sentinel for projective infinity

def spb_step_mod(g, result, p):
    """One step of SPB iteration in F_p ∪ {∞}."""
    if result == INF:
        # spb(g, ∞) = -1/g
        if g == 0:
            return INF
        return (p - pow(int(g), p - 2, p)) % p
    num = (result + g) % p
    den = (1 - result * g) % p
    if den == 0:
        return INF
    return (num * pow(int(den), p - 2, p)) % p

def spb_iter_mod(g, n, p):
    """n-fold SPB iteration of g in F_p ∪ {∞}."""
    result = 0
    for _ in range(n):
        result = spb_step_mod(g, result, p)
    return result

print("=" * 70)
print("SPB NUMBER THEORY DEMO")
print("=" * 70)

# --- Pythagorean Triples ---
print("\n--- Pythagorean Triples from SPB ---")
print("Weierstrass parametrization: t = a/b → (b²-a², 2ab, b²+a²)")
print()
triples = []
for b in range(1, 8):
    for a in range(1, b):
        if math.gcd(a, b) == 1 and (a + b) % 2 == 1:  # primitive triples
            x = b**2 - a**2
            y = 2 * a * b
            z = a**2 + b**2
            triples.append((x, y, z, a, b))

print(f"{'a/b':>6} | {'Triple':>20} | {'x²+y²':>8} = {'z²':>8}")
print("-" * 55)
for x, y, z, a, b in sorted(triples, key=lambda t: t[2]):
    print(f"  {a}/{b}  |  ({x:3d}, {y:3d}, {z:3d})      | {x**2+y**2:8d} = {z**2:8d}")

# --- Brahmagupta-Fibonacci via SPB ---
print("\n--- Brahmagupta-Fibonacci Identity as SPB Composition ---")
print("(a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)²")
print("Equivalently: angles add via spb(b/a, d/c) = (ad+bc)/(ac-bd)")
examples = [(1, 2, 3, 4), (2, 1, 1, 3), (3, 2, 1, 1)]
for a, b, c, d in examples:
    lhs = (a**2 + b**2) * (c**2 + d**2)
    r1 = a*c - b*d
    r2 = a*d + b*c
    rhs = r1**2 + r2**2
    t1 = Fraction(b, a)
    t2 = Fraction(d, c)
    spb_result = spb_frac(t1, t2)
    print(f"  ({a}²+{b}²)({c}²+{d}²) = {lhs} = {r1}²+{r2}² = {rhs}")
    print(f"  spb({t1}, {t2}) = {spb_result} = {r2}/{r1}")

# --- Finite Field p±1 Law ---
print("\n--- The p±1 Law for SPB over F_p ---")
print("p ≡ 3 (mod 4): all orders divide p+1")
print("p ≡ 1 (mod 4): all orders divide p-1")
print()

primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
for p in primes:
    mod4 = p % 4
    expected_order = p + 1 if mod4 == 3 else p - 1
    
    # Check: does spb^{expected_order}(g) = 0 for all non-pole g?
    # For p ≡ 1 (mod 4), elements g with g² ≡ -1 (mod p) are poles
    all_satisfy = True
    max_order = 0
    n_poles = 0
    for g in range(1, p):
        # Check if g is a pole: g² ≡ -1 (mod p)
        if (g * g + 1) % p == 0:
            n_poles += 1
            continue
        result = spb_iter_mod(g, expected_order, p)
        if result != 0 and result != INF:
            all_satisfy = False
        # Find actual order
        for k in range(1, expected_order + 1):
            r = spb_iter_mod(g, k, p)
            if r == 0:
                max_order = max(max_order, k)
                break
    
    status = "✓" if all_satisfy else "✗"
    pole_note = f" ({n_poles} poles)" if n_poles > 0 else ""
    print(f"  p={p:2d} (≡{mod4} mod 4): orders | {expected_order:2d}? {status}{pole_note}  max = {max_order}")

# --- Group Structure ---
print("\n--- SPB Group Structure over F_p ---")
for p in [5, 7, 11, 13]:
    print(f"\n  F_{p} (p ≡ {p%4} mod 4):")
    order_counts = {}
    for g in range(p):
        for k in range(1, p + 2):
            r = spb_iter_mod(g, k, p)
            if r == 0:
                order_counts[k] = order_counts.get(k, 0) + 1
                break
    
    group_order = p + 1 if p % 4 == 3 else p - 1
    print(f"  Expected group order: {group_order}")
    print(f"  Element orders: ", end="")
    for order in sorted(order_counts.keys()):
        count = order_counts[order]
        divides = "✓" if group_order % order == 0 else "✗"
        print(f"{order}({count}×){divides} ", end="")
    print()

# --- Integer SPB ---
print("\n\n--- Integer SPB: When does spb(a,b) ∈ ℤ? ---")
print("Condition: (1-ab) | (a+b)")
count = 0
for a in range(-10, 11):
    for b in range(a, 11):
        d = 1 - a * b
        if d != 0 and (a + b) % d == 0:
            result = (a + b) // d
            if abs(a) <= 5 and abs(b) <= 5:
                count += 1
                if count <= 20:
                    print(f"  spb({a:3d}, {b:3d}) = {result:4d}  (denom = {d})")

# --- Connection to Sum of Two Squares ---
print("\n--- SPB and Sum of Two Squares ---")
print("n is a sum of two squares iff n has no prime factor p ≡ 3 (mod 4)")
print("to an odd power. This connects to the SPB group structure!")
print()
for n in range(1, 26):
    representations = []
    for a in range(int(math.sqrt(n)) + 1):
        b_sq = n - a**2
        if b_sq >= 0:
            b = int(math.sqrt(b_sq))
            if b * b == b_sq and a <= b:
                representations.append((a, b))
    if representations:
        reps = ", ".join(f"{a}²+{b}²" for a, b in representations)
        print(f"  {n:2d} = {reps}")

print("\n" + "=" * 70)
print("KEY INSIGHT: The p±1 law for SPB over F_p is controlled by")
print("quadratic reciprocity — whether -1 is a square mod p.")
print("This connects SPB to deep arithmetic via the Cayley transform.")
print("=" * 70)
