#!/usr/bin/env python3
"""
Applications of Carmichael's Theorem for Fibonacci Numbers

1. Primality testing via Fibonacci primitive divisors
2. Fibonacci factorization using entry points  
3. Pisano period computation
"""
import math

def fib(n):
    if n <= 0: return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

def fib_mod(n, m):
    """Compute F(n) mod m efficiently."""
    if n <= 0: return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, (a + b) % m
    return b

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True

def entry_point(p):
    """Find alpha(p): smallest k > 0 with p | F(k)."""
    a, b = 0, 1
    for k in range(1, p * p + 10):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

# ============================================================
# Application 1: Primality Certificate
# ============================================================
print("=" * 60)
print("APPLICATION 1: Fibonacci-based Compositeness Test")
print("=" * 60)
print()
print("Carmichael's theorem implies: if n >= 13 is composite,")
print("then F(n) has a prime factor p with entry point alpha(p) = n.")
print("Contrapositive: if F(n) has NO primitive divisor, n is prime")
print("(or n in {1,2,6,12}).")
print()
print("Testing: does F(n) have a divisor with entry point n?")
print()

for n in [13, 14, 15, 16, 17, 23, 29, 30, 31, 37]:
    fn = fib(n)
    # Check small primes for entry point = n
    has_primitive = False
    for p in range(2, min(fn + 1, 10000)):
        if not is_prime(p): continue
        if fn % p != 0: continue
        if entry_point(p) == n:
            has_primitive = True
            break
    
    prime_status = "PRIME" if is_prime(n) else "COMPOSITE"
    prim_status = "has primitive" if has_primitive else "no primitive found"
    print(f"n={n:3d} [{prime_status:>9}]: F(n)={fn:>10}, {prim_status}")

# ============================================================
# Application 2: Fibonacci Factorization via Entry Points
# ============================================================
print()
print("=" * 60)
print("APPLICATION 2: Fibonacci Factorization via Entry Points")
print("=" * 60)
print()
print("The factorization F(n) = prod_{d|n} Psi(d) decomposes")
print("each Fibonacci number into contributions from each divisor level.")
print()

def divisors(n):
    divs = []
    for d in range(1, n + 1):
        if n % d == 0:
            divs.append(d)
    return divs

def primitive_part(n):
    fn = fib(n)
    if fn <= 1: return fn
    result = fn
    for d in range(1, n):
        if n % d == 0 and d > 0:
            fd = fib(d)
            while True:
                g = math.gcd(result, fd)
                if g <= 1: break
                result //= g
    return result

for n in [15, 20, 30]:
    fn = fib(n)
    pp = primitive_part(n)
    divs = divisors(n)
    print(f"F({n}) = {fn}")
    print(f"  Proper divisors: {[d for d in divs if d < n]}")
    print(f"  Radical primitive part (coprime to all F(d)): {pp}")
    if pp > 1:
        print(f"  -> Primitive primes exist! (Carmichael confirmed)")
    else:
        print(f"  -> No primitive prime (known exception)")
    print()

# ============================================================
# Application 3: Pisano Period Lower Bounds
# ============================================================
print("=" * 60)
print("APPLICATION 3: Pisano Periods and Entry Points")
print("=" * 60)
print()
print("The Pisano period pi(m) is the period of F(n) mod m.")
print("Entry points give divisibility: alpha(p) | pi(p).")
print()

for p in [2, 3, 5, 7, 11, 13, 29, 89, 97]:
    if not is_prime(p): continue
    ep = entry_point(p)
    # Compute Pisano period
    a, b = 0, 1
    for pi in range(1, 6 * p + 10):
        a, b = b, (a + b) % p
        if a == 0 and b == 1:
            break
    print(f"p={p:3d}: alpha(p)={ep:4d}, pi(p)={pi:4d}, pi/alpha={pi/ep:.1f}")

print()
print("Note: pi(p) | p^2 - 1 (for p != 5), and alpha(p) | pi(p).")
print("For p = 5: pi(5) = 20 = 4*5.")
print()
print("All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Carmichael's Theorem for Fibonacci Numbers — Demo

For every composite n >= 13, F(n) has a primitive prime divisor:
a prime p dividing F(n) but not dividing F(k) for any 0 < k < n.
"""
import math
import sys

def fib(n):
    """Compute F(n) using iterative method."""
    if n <= 0: return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

def prime_factors(n):
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True

def proper_divisors(n):
    divs = set()
    for d in range(1, n):
        if n % d == 0:
            divs.add(d)
    return divs

def entry_point(p, max_k=None):
    """Smallest k > 0 with p | F(k)."""
    if max_k is None:
        max_k = p * p + 10
    a, b = 0, 1
    for k in range(1, max_k + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

def primitive_part(n):
    """Remove from F(n) all factors shared with F(d) for proper d | n."""
    fn = fib(n)
    if fn <= 1: return fn
    result = fn
    for d in proper_divisors(n):
        fd = fib(d)
        while True:
            g = math.gcd(result, fd)
            if g <= 1: break
            result //= g
    return result

def find_primitive_primes(n):
    fn = fib(n)
    if fn == 0: return []
    primes_fn = prime_factors(fn)
    prop_divs = proper_divisors(n)
    prims = []
    for p in sorted(primes_fn):
        ok = True
        for d in prop_divs:
            if d > 0 and fib(d) % p == 0:
                ok = False
                break
        if ok:
            prims.append(p)
    return prims

# ============================================================
# Demo 1: Verify Carmichael's theorem for small composites
# ============================================================
print("=" * 60)
print("Carmichael's Theorem: Verification for n = 4 to 50")
print("=" * 60)
print()

for n in range(4, 51):
    if is_prime(n): continue
    prims = find_primitive_primes(n)
    pp = primitive_part(n)
    fn = fib(n)
    tag = "OK" if prims else "EXCEPTION"
    print(f"n={n:3d}: F(n)={fn:>15}, primitive={prims}, Psi={pp:>10}  [{tag}]")

exceptions = [n for n in range(4, 101) if not is_prime(n) and not find_primitive_primes(n)]
print(f"\nExceptions in [4,100]: {exceptions}")
print("(Carmichael's theorem: all composite n >= 13 have primitive divisors)")

# ============================================================
# Demo 2: Entry points of small primes
# ============================================================
print("\n" + "=" * 60)
print("Fibonacci Entry Points (Rank of Apparition)")
print("=" * 60)
print()

print(f"{'Prime p':>8} {'alpha(p)':>10} {'p mod 5':>8} {'Note':>20}")
print("-" * 50)
for p in range(2, 100):
    if not is_prime(p): continue
    ep = entry_point(p)
    note = ""
    if ep == p - 1: note = "alpha = p-1"
    elif ep == p + 1: note = "alpha = p+1"
    elif ep == p: note = "alpha = p"
    elif ep and p % ep == 0: note = f"alpha | p"
    print(f"{p:8d} {ep:10d} {p%5:8d} {note:>20}")

# ============================================================
# Demo 3: Factorization example
# ============================================================
print("\n" + "=" * 60)
print("Fibonacci Factorization Examples")
print("=" * 60)
print()

for n in [14, 15, 20, 21, 30]:
    fn = fib(n)
    pf = sorted(prime_factors(fn))
    print(f"F({n}) = {fn}")
    for p in pf:
        ep = entry_point(p)
        tag = " *** PRIMITIVE ***" if ep == n else f" (inherited from F({ep}))"
        print(f"  prime {p:>6}: entry point = {ep}{tag}")
    print(f"  Primitive part Psi({n}) = {primitive_part(n)}")
    print()

# ============================================================  
# Demo 4: Applications
# ============================================================
print("=" * 60)
print("Applications of Carmichael's Theorem")
print("=" * 60)
print()
print("1. CRYPTOGRAPHY: The entry point structure of Fibonacci numbers")
print("   is used in Fibonacci-based pseudorandom generators and")
print("   the analysis of Fibonacci-linear-congruential hybrids.")
print()
print("2. PRIMALITY TESTING: If F(n) has no primitive divisor,")
print("   then n must be 1, 2, 6, or 12. This gives a necessary")
print("   condition for primality of Fibonacci numbers.")
print()
print("3. NUMBER THEORY: Carmichael's theorem is the Fibonacci")
print("   case of Zsygmondy's theorem, and extends to all Lucas")
print("   sequences. It underpins the arithmetic of algebraic")
print("   number fields Q(sqrt(5)).")
print()

print("All demos completed successfully!")
