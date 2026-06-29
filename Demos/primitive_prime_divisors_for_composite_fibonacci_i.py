"""
Carmichael's Theorem: Primitive Prime Divisors of Fibonacci Numbers
===================================================================

Demonstrates that for every composite n >= 13, F(n) has at least one
primitive prime divisor -- a prime p dividing F(n) that doesn't divide
F(k) for any 0 < k < n.
"""

import math
from functools import lru_cache
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def fib(n):
    if n <= 1: return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def proper_divisors(n):
    return [d for d in range(1, n) if n % d == 0]

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
    d = 5
    while d * d <= n:
        if n % d == 0 or (n + 2) % d == 0: return False
        d += 6
    return True

def entry_point(p):
    """Smallest k > 0 with p | F(k)."""
    for k in range(1, 2 * (p + 1) + 1):
        if fib(k) % p == 0:
            return k
    return None

def primitive_prime_divisors(n):
    fn = fib(n)
    if fn <= 1: return []
    primes = prime_factors(fn)
    divs = proper_divisors(n)
    return sorted(p for p in primes if all(fib(d) % p != 0 for d in divs))

def primitive_part(n):
    """Primitive residual via iterative GCD."""
    fn = fib(n)
    if fn <= 1: return fn
    divs = proper_divisors(n)
    rem = fn
    changed = True
    while changed:
        changed = False
        for d in divs:
            g = math.gcd(rem, fib(d))
            if g > 1:
                rem //= g
                changed = True
    return rem

def euler_totient(n):
    result, temp = n, n
    p = 2
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0: temp //= p
            result -= result // p
        p += 1
    if temp > 1: result -= result // temp
    return result

# ---- DEMONSTRATIONS ----

print("=" * 70)
print("CARMICHAEL'S THEOREM: PRIMITIVE PRIME DIVISORS OF FIBONACCI NUMBERS")
print("=" * 70)

print("\n--- Table of Fibonacci Numbers and Primitive Prime Divisors ---\n")
print(f"{'n':>4} {'F(n)':>12} {'Comp?':>6} {'Primitive Primes':>25}")
print("-" * 55)
for n in range(1, 31):
    fn = fib(n)
    if is_prime(n):
        print(f"{n:>4} {fn:>12} {'prime':>6} {'(n is prime)':>25}")
    elif n >= 4:
        pp = primitive_prime_divisors(n)
        pp_str = ", ".join(str(p) for p in pp) if pp else "NONE"
        print(f"{n:>4} {fn:>12} {'yes':>6} {pp_str:>25}")
    else:
        print(f"{n:>4} {fn:>12} {'':>6} {'':>25}")

print("\n--- Sharpness: n = 12 has NO primitive prime divisor ---\n")
n = 12
fn = fib(n)
print(f"F({n}) = {fn} = 2^4 * 3^2")
for p in [2, 3]:
    ep = entry_point(p)
    print(f"  p = {p}: z({p}) = {ep}, F({ep}) = {fib(ep)}, "
          f"so {p} | F({ep}) with {ep} < {n}")
print(f"  => Both prime factors have entry point < {n}: no primitive divisor!")

print(f"\nF(13) = {fib(13)} = 233 (prime), so the theorem applies from n = 14:")
pp14 = primitive_prime_divisors(14)
print(f"  F(14) = {fib(14)} = 13 * 29, primitive prime = {pp14}")

print("\n--- Growth of the Primitive Part ---\n")
print(f"{'n':>4} {'phi(n)':>7} {'Prim. Part':>15} {'Phi_n / n':>10}")
print("-" * 45)
for n in [14,15,16,18,20,24,25,30,35,40,50,60,80,100]:
    if is_prime(n): continue
    pp = primitive_part(n)
    phi = euler_totient(n)
    print(f"{n:>4} {phi:>7} {pp:>15} {pp/n:>10.1f}")

# ---- PLOTS ----

# Plot 1: Primitive Part Growth
ns = [n for n in range(4, 101) if not is_prime(n)]
parts = [primitive_part(n) for n in ns]
log_parts = [math.log2(p) if p > 0 else 0 for p in parts]
phi_ns = [euler_totient(n) for n in ns]
phi_bound = [phi * math.log2((1 + math.sqrt(5)) / 2) for phi in phi_ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
ax1.scatter(ns, log_parts, s=15, alpha=0.7, color='steelblue', label=r'$\log_2(\Phi_n)$')
ax1.plot(ns, phi_bound, 'r-', alpha=0.5, linewidth=1.5,
         label=r'$\varphi(n) \cdot \log_2 \varphi$')
ax1.plot(ns, [math.log2(n) for n in ns], 'g--', alpha=0.5, label=r'$\log_2(n)$')
ax1.set_xlabel('n (composite)')
ax1.set_ylabel(r'$\log_2$(primitive part)')
ax1.set_title(r'Growth of Fibonacci Primitive Part $\Phi_n$')
ax1.legend()
ax1.grid(True, alpha=0.3)

ratios = [parts[i] / ns[i] for i in range(len(ns))]
ax2.scatter(ns, ratios, s=15, alpha=0.7, color='darkorange')
ax2.set_xlabel('n (composite)')
ax2.set_ylabel(r'$\Phi_n / n$')
ax2.set_title(r'$\Phi_n$ Dominates $n$ (log scale)')
ax2.axhline(y=1, color='red', linestyle='--', alpha=0.5, label=r'$\Phi_n = n$')
ax2.set_yscale('log')
ax2.legend()
ax2.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('demos/primitive_parts_growth.png', dpi=150, bbox_inches='tight')
print("\nSaved: demos/primitive_parts_growth.png")

# Plot 2: Entry Points
max_p = 100
primes = [p for p in range(2, max_p) if is_prime(p)]
eps = [entry_point(p) for p in primes]
fig2, ax = plt.subplots(figsize=(10, 6))
ax.scatter(primes, eps, s=30, alpha=0.7, color='steelblue')
ax.plot([2, max_p], [2, max_p], 'r--', alpha=0.3, label='z(p) = p')
ax.set_xlabel('Prime p')
ax.set_ylabel('Entry point z(p)')
ax.set_title('Fibonacci Entry Points: z(p) = min{k > 0 : p | F(k)}')
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('demos/entry_points.png', dpi=150, bbox_inches='tight')
print("Saved: demos/entry_points.png")

print("\n--- Applications ---\n")
print("1. PRIMALITY TESTING: Primitive primes provide independence")
print("   certificates for Fibonacci numbers.")
print("2. LUCAS SEQUENCES: Carmichael's theorem extends to all")
print("   non-degenerate Lucas sequences U_n(P,Q).")
print("3. ALGEBRAIC NUMBER THEORY: Primitive divisors correspond to")
print("   primes with specific splitting behavior in Q(sqrt(5)).")
print("\nAll demonstrations complete!")
