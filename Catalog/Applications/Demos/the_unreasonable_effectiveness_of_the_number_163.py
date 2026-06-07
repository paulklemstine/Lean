#!/usr/bin/env python3
"""
Demo: The Unreasonable Effectiveness of 163
============================================
Numerical demonstrations of Heegner number properties,
Ramanujan's constant, and prime-generating polynomials.
"""

import math


def euler_polynomial(x: int, c: int = 41) -> int:
    """Evaluate x² + x + c (Rabinowitz polynomial)."""
    return x * x + x + c


def is_prime(n: int) -> bool:
    """Simple primality test."""
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


def demo_euler_polynomial():
    """Show Euler's polynomial x²+x+41 generating 40 consecutive primes."""
    print("=" * 70)
    print("EULER'S PRIME-GENERATING POLYNOMIAL: x² + x + 41")
    print("=" * 70)
    for x in range(42):
        val = euler_polynomial(x)
        prime = is_prime(val)
        status = "PRIME" if prime else f"COMPOSITE ({factorize(val)})"
        marker = "  ✓" if prime else "  ✗ ← FIRST FAILURE" if x == 40 else "  ✗"
        print(f"  x = {x:2d}:  {x}² + {x} + 41 = {val:5d}  {marker} {status}")
    print()


def factorize(n: int) -> str:
    """Simple factorization for display."""
    if n < 2:
        return str(n)
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        while temp % d == 0:
            factors.append(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    return " × ".join(str(f) for f in factors)


def demo_all_rabinowitz():
    """Show prime generation for ALL Heegner numbers."""
    print("=" * 70)
    print("RABINOWITZ CRITERION: ALL HEEGNER NUMBERS")
    print("=" * 70)
    heegner_odd = [(3, 1), (7, 2), (11, 3), (19, 5), (43, 11), (67, 17), (163, 41)]

    for d, c in heegner_odd:
        primes_generated = 0
        first_failure = None
        for x in range(c + 1):
            val = euler_polynomial(x, c)
            if is_prime(val):
                primes_generated += 1
            elif first_failure is None:
                first_failure = (x, val)

        failure_str = f"fails at x={first_failure[0]}: {first_failure[1]} = {factorize(first_failure[1])}" if first_failure else "no failure in range"
        print(f"  d = {d:3d}, c = {c:2d}: {primes_generated:2d} primes in range [0, {c-1}], {failure_str}")

    print()


def demo_ramanujan_constant():
    """Compute e^{π√d} for Heegner numbers."""
    print("=" * 70)
    print("RAMANUJAN'S CONSTANT AND NEAR-INTEGERS")
    print("=" * 70)

    heegner_numbers = [1, 2, 3, 7, 11, 19, 43, 67, 163]
    j_cubes = {43: 960, 67: 5280, 163: 640320}

    for d in heegner_numbers:
        val = math.exp(math.pi * math.sqrt(d))
        nearest = round(val)
        error = abs(val - nearest)
        print(f"  d = {d:3d}:  e^(π√{d:3d}) ≈ {val:30.6f}  error: {error:.2e}")

    print()
    print("  j-invariant cube roots and near-integer targets:")
    for d in [43, 67, 163]:
        A = j_cubes[d]
        target = A**3 + 744
        actual = math.exp(math.pi * math.sqrt(d))
        print(f"  d = {d:3d}:  A = {A:>6d},  A³ + 744 = {target:>24d},  error = {abs(actual - target):.2e}")
    print()


def demo_quadratic_residues():
    """Show -163 is a QNR mod every odd prime < 41."""
    print("=" * 70)
    print("QUADRATIC NON-RESIDUE PROPERTY OF -163")
    print("=" * 70)

    primes_lt_41 = [p for p in range(3, 41) if is_prime(p)]
    for p in primes_lt_41:
        residues = set()
        for x in range(p):
            residues.add((x * x) % p)
        neg163_mod_p = (-163) % p
        is_qr = neg163_mod_p in residues
        status = "QR" if is_qr else "QNR"
        print(f"  p = {p:2d}: -163 ≡ {neg163_mod_p:2d} (mod {p:2d}), QRs mod {p} = {sorted(residues)}, -163 is {status}")

    print()


def demo_lucky_primes():
    """Classify Euler lucky primes."""
    print("=" * 70)
    print("EULER LUCKY PRIME CLASSIFICATION")
    print("=" * 70)

    primes = [p for p in range(2, 50) if is_prime(p)]
    lucky = []
    not_lucky = []

    for p in primes:
        all_prime = True
        failure = None
        for x in range(p - 1):
            val = x * x + x + p
            if not is_prime(val):
                all_prime = False
                failure = (x, val)
                break
        if all_prime:
            lucky.append(p)
            print(f"  p = {p:2d}: LUCKY (all {p-1} values prime)")
        else:
            not_lucky.append(p)
            print(f"  p = {p:2d}: NOT lucky (x={failure[0]}: {failure[1]} = {factorize(failure[1])})")

    print(f"\n  Lucky primes: {lucky}")
    print(f"  Not lucky:    {not_lucky}")
    print()


def demo_heegner_form():
    """Show values of the Heegner form Q(x,y) = x² + xy + 41y²."""
    print("=" * 70)
    print("HEEGNER FORM Q(x,y) = x² + xy + 41y²")
    print("=" * 70)
    print("  Values for small (x,y):")
    for y in range(-2, 3):
        for x in range(-3, 4):
            if x == 0 and y == 0:
                print(f"  Q({x:2d},{y:2d}) = {0:4d}  (origin)", end="")
            else:
                val = x*x + x*y + 41*y*y
                prime_str = "P" if is_prime(val) else " "
                print(f"  Q({x:2d},{y:2d}) = {val:4d} {prime_str}", end="")
            print()
    print()

    # Show symmetry Q(-x-y, y) = Q(x, y)
    print("  Symmetry Q(-x-y, y) = Q(x, y):")
    for x, y in [(1, 1), (2, 1), (3, 2), (5, 3)]:
        v1 = x*x + x*y + 41*y*y
        x2 = -x - y
        v2 = x2*x2 + x2*y + 41*y*y
        print(f"  Q({x},{y}) = {v1}, Q({x2},{y}) = {v2}, equal: {v1 == v2}")
    print()


def demo_gcd_structure():
    """Show GCD relationships between j-invariant cube roots."""
    print("=" * 70)
    print("j-INVARIANT CUBE ROOT GCD STRUCTURE")
    print("=" * 70)
    A = {43: 960, 67: 5280, 163: 640320}

    for d1 in [43, 67, 163]:
        for d2 in [43, 67, 163]:
            if d1 < d2:
                g = math.gcd(A[d1], A[d2])
                print(f"  gcd(A_{d1}, A_{d2}) = gcd({A[d1]}, {A[d2]}) = {g}")
                print(f"    A_{d1}/{g} = {A[d1]//g}, A_{d2}/{g} = {A[d2]//g}")

    print(f"\n  All divisible by 12: {A[43]//12}, {A[67]//12}, {A[163]//12}")
    print(f"  Factorizations:")
    print(f"    960   = 2⁶ · 3 · 5")
    print(f"    5280  = 2⁵ · 3 · 5 · 11")
    print(f"    640320 = 2⁶ · 3 · 5 · 23 · 29")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     THE UNREASONABLE EFFECTIVENESS OF THE NUMBER 163              ║")
    print("║     Heegner Numbers, Quadratic Forms, and Ramanujan's Constant    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_euler_polynomial()
    demo_all_rabinowitz()
    demo_ramanujan_constant()
    demo_quadratic_residues()
    demo_lucky_primes()
    demo_heegner_form()
    demo_gcd_structure()


#!/usr/bin/env python3
"""
Visualization: Level curves of the Heegner form Q(x,y) = x² + xy + 41y².
"""

import matplotlib.pyplot as plt
import numpy as np


def heegner_form(x, y):
    return x**2 + x*y + 41*y**2


def is_prime(n):
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


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Level curves
x = np.linspace(-5, 5, 400)
y = np.linspace(-3, 3, 400)
X, Y = np.meshgrid(x, y)
Z = X**2 + X*Y + 41*Y**2

levels = [1, 5, 10, 20, 41, 43, 47, 100, 163, 200, 400]
cs = ax1.contour(X, Y, Z, levels=levels, cmap='viridis')
ax1.clabel(cs, inline=True, fontsize=8)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('y', fontsize=12)
ax1.set_title('Level Curves: Q(x,y) = x² + xy + 41y²', fontsize=13, fontweight='bold')
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Mark lattice points with prime values
for ix in range(-5, 6):
    for iy in range(-3, 4):
        if ix == 0 and iy == 0:
            continue
        val = heegner_form(ix, iy)
        if is_prime(val):
            ax1.plot(ix, iy, 'r.', markersize=8)
        else:
            ax1.plot(ix, iy, 'k.', markersize=3)

# Completing the square visualization
u_range = np.linspace(-10, 10, 200)
v_range = np.linspace(-3, 3, 200)
U, V = np.meshgrid(u_range, v_range)
# 4Q = u² + 163v² where u = 2x+y, v = y
Z2 = U**2 + 163*V**2

levels2 = [4, 20, 100, 200, 400, 800, 1600]
cs2 = ax2.contour(U, V, Z2, levels=levels2, cmap='magma')
ax2.clabel(cs2, inline=True, fontsize=8)
ax2.set_xlabel('u = 2x + y', fontsize=12)
ax2.set_ylabel('v = y', fontsize=12)
ax2.set_title('After Completing the Square:\n4Q = u² + 163v²', fontsize=13, fontweight='bold')
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("viz_heegner_form.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_heegner_form.png")


#!/usr/bin/env python3
"""
Visualization: Near-integer quality of e^(π√d) for Heegner numbers.
"""

import matplotlib.pyplot as plt
import numpy as np
import math


def near_integer_error(d):
    val = math.exp(math.pi * math.sqrt(d))
    return abs(val - round(val))


heegner = [1, 2, 3, 7, 11, 19, 43, 67, 163]
errors = [near_integer_error(d) for d in heegner]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Log-scale error plot
ax1.semilogy(heegner, errors, 'bo-', markersize=10, linewidth=2)
for d, e in zip(heegner, errors):
    ax1.annotate(f'd={d}', (d, e), textcoords="offset points",
                 xytext=(5, 10), fontsize=9)
ax1.set_xlabel('Heegner number d', fontsize=12)
ax1.set_ylabel('|e^(π√d) - nearest integer|', fontsize=12)
ax1.set_title('Near-Integer Quality (log scale)', fontsize=14, fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.axhline(y=1e-6, color='red', linestyle='--', alpha=0.5, label='10⁻⁶ threshold')
ax1.legend()

# Rabinowitz constant vs prime streak
rab_constants = [1, 2, 3, 5, 11, 17, 41]
prime_streaks = [c - 1 for c in rab_constants]
heegner_odd = [3, 7, 11, 19, 43, 67, 163]

ax2.plot(heegner_odd, prime_streaks, 'rs-', markersize=10, linewidth=2)
ax2.fill_between(heegner_odd, prime_streaks, alpha=0.2, color='red')
for d, s, c in zip(heegner_odd, prime_streaks, rab_constants):
    ax2.annotate(f'c={c}, streak={s}', (d, s), textcoords="offset points",
                 xytext=(5, 5), fontsize=9)
ax2.set_xlabel('Heegner number d', fontsize=12)
ax2.set_ylabel('Prime streak length', fontsize=12)
ax2.set_title('Rabinowitz Prime Generation Streaks', fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("viz_near_integer.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_near_integer.png")


#!/usr/bin/env python3
"""
Visualization: Prime generation streaks for all Heegner Rabinowitz polynomials.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def is_prime(n):
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


def rabinowitz_eval(c, x):
    return x * x + x + c


fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle("Prime Generation by Heegner-Rabinowitz Polynomials x² + x + c",
             fontsize=16, fontweight='bold')

heegner_data = [
    (7, 2), (11, 3), (19, 5),
    (43, 11), (67, 17), (163, 41)
]

for idx, (d, c) in enumerate(heegner_data):
    ax = axes[idx // 3][idx % 3]

    x_vals = list(range(c + 2))
    y_vals = [rabinowitz_eval(c, x) for x in x_vals]
    colors = ['green' if is_prime(v) else 'red' for v in y_vals]

    ax.bar(x_vals, y_vals, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.set_title(f"d = {d}, c = {c}\n(Streak: {c-1} primes)", fontsize=12)
    ax.set_xlabel("x")
    ax.set_ylabel("x² + x + " + str(c))

    # Mark the boundary
    boundary_x = c - 1
    ax.axvline(x=boundary_x + 0.5, color='orange', linestyle='--', linewidth=2,
               label=f'x={boundary_x}: c² = {c}²')

green_patch = mpatches.Patch(color='green', alpha=0.7, label='Prime')
red_patch = mpatches.Patch(color='red', alpha=0.7, label='Composite')
fig.legend(handles=[green_patch, red_patch], loc='lower center', ncol=2, fontsize=12)

plt.tight_layout(rect=[0, 0.05, 1, 0.95])
plt.savefig("viz_prime_streak.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_prime_streak.png")
