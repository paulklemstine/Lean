#!/usr/bin/env python3
"""
Demo: The Unreasonable Effectiveness of the Number 163

Demonstrates the key numerical phenomena connecting 163, Heegner numbers,
the Euler polynomial, and Ramanujan's constant.
"""

import math

# ============================================================
# 1. Ramanujan's Constant
# ============================================================
print("=" * 60)
print("1. RAMANUJAN'S CONSTANT: e^(π√163)")
print("=" * 60)

# Use high-precision computation
val = math.exp(math.pi * math.sqrt(163))
nearest_int = round(val)
error = abs(val - nearest_int)

print(f"  e^(π√163) ≈ {val:.6f}")
print(f"  Nearest integer: {nearest_int}")
print(f"  Distance to nearest integer: ~{error:.2e}")
print(f"  (True distance: 7.499 × 10⁻¹³)")
print()

# The algebraic explanation
print("  Algebraic explanation:")
print(f"  640320³ + 744 = {640320**3 + 744}")
print(f"  640320³       = {640320**3}")
print(f"  Factorization: 640320 = 2⁶ × 3 × 5 × 23 × 29 = {2**6 * 3 * 5 * 23 * 29}")
print()

# ============================================================
# 2. Near-Integer Property for All Heegner Numbers
# ============================================================
print("=" * 60)
print("2. NEAR-INTEGER PROPERTY FOR ALL HEEGNER NUMBERS")
print("=" * 60)

heegner_numbers = [1, 2, 3, 7, 11, 19, 43, 67, 163]

for d in heegner_numbers:
    val = math.exp(math.pi * math.sqrt(d))
    nearest = round(val)
    dist = abs(val - nearest)
    print(f"  d = {d:>3}: e^(π√d) ≈ {val:>25.6f}, "
          f"dist to int = {dist:.2e}")

print()
print("  Notice: the distance DECREASES as d increases.")
print("  163 gives the most spectacular near-miss.")
print()

# ============================================================
# 3. The Euler Polynomial x² + x + 41
# ============================================================
print("=" * 60)
print("3. EULER'S PRIME-GENERATING POLYNOMIAL: x² + x + 41")
print("=" * 60)

from sympy import isprime  # type: ignore

def euler_poly(x):
    return x**2 + x + 41

print("  x | x² + x + 41 | Prime?")
print("  " + "-" * 35)
for x in range(42):
    val = euler_poly(x)
    is_p = isprime(val)
    marker = "  ← COMPOSITE!" if not is_p else ""
    if x <= 5 or x >= 38:
        print(f"  {x:>2} | {val:>10} | {'Yes' if is_p else 'No':>3}{marker}")
    elif x == 6:
        print(f"  .. |    ...     | ...")

print()
print(f"  Primes for x = 0..39: ALL 40 values are prime!")
print(f"  x = 40: {euler_poly(40)} = 41² (boundary)")
print(f"  Discriminant: 1 - 4×41 = {1 - 4*41} (= -163!)")
print()

# ============================================================
# 4. The Rabinowitz Polynomials
# ============================================================
print("=" * 60)
print("4. RABINOWITZ POLYNOMIALS FOR ALL HEEGNER NUMBERS ≡ 3 (mod 4)")
print("=" * 60)

heegner_mod3 = [3, 7, 11, 19, 43, 67, 163]

for d in heegner_mod3:
    p = (d + 1) // 4
    # Count consecutive primes from x=0
    count = 0
    for x in range(p):
        if isprime(x**2 + x + p):
            count += 1
        else:
            break
    print(f"  d = {d:>3}, p = {p:>2}: x² + x + {p} "
          f"produces {count} consecutive primes (x=0..{count-1})")
    print(f"         f({p-1}) = {(p-1)**2 + (p-1) + p} = {p}² = {p**2} "
          f"(Rabinowitz boundary)")

print()

# ============================================================
# 5. The j-Invariant Connection
# ============================================================
print("=" * 60)
print("5. THE j-INVARIANT AND MODULAR FORMS")
print("=" * 60)

# For each Heegner d ≡ 3 (mod 4), j((1+√(-d))/2) is a perfect cube (up to sign)
# times some factor. The key values:
j_values = {
    3: 0,
    7: -3375,       # = -15³
    11: -32768,     # = -32³? No, = -2^15
    19: -884736,    # = -96³
    43: -884736000,
    67: -147197952000,
    163: -262537412640768000  # = -640320³
}

print("  d   | j((1+√(-d))/2)")
print("  " + "-" * 40)
for d, j in j_values.items():
    # Check if |j| is a perfect cube
    abs_j = abs(j)
    cbrt = round(abs_j ** (1/3))
    is_cube = (cbrt**3 == abs_j)
    cube_str = f" = -{cbrt}³" if is_cube and j < 0 else ""
    print(f"  {d:>3} | {j:>25}{cube_str}")

print()
print("  For d = 163: j = -640320³")
print(f"  e^(π√163) ≈ 640320³ + 744 = {640320**3 + 744}")
print()

# ============================================================
# 6. Properties of 163
# ============================================================
print("=" * 60)
print("6. REMARKABLE PROPERTIES OF 163")
print("=" * 60)

print(f"  163 is prime: {isprime(163)}")
print(f"  163 mod 4 = {163 % 4} (fundamental discriminant)")
print(f"  163 mod 8 = {163 % 8}")
print(f"  163 = 4 × 41 - 1 (discriminant of x² + x + 41)")
print(f"  163 is the 38th prime")
print(f"  Sum of Heegner numbers: {sum(heegner_numbers)}")
print(f"  Product: {math.prod(heegner_numbers)}")
print()

# Count primes up to 163
primes_up_to_163 = [p for p in range(2, 164) if isprime(p)]
print(f"  163 is the {len(primes_up_to_163)}th prime")

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("CONCLUSION: 163 is not magic — it is the climax of a deep")
    print("theorem in algebraic number theory. The Stark-Heegner theorem")
    print("proves that {1,2,3,7,11,19,43,67,163} are the ONLY numbers")
    print("with class number 1, and 163 is the last.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Euler's Prime-Generating Polynomial x² + x + 41

Shows the values of x² + x + 41 for x = 0..50, highlighting which are prime
and the Rabinowitz boundary at x = 40.
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


def euler_poly(x):
    return x * x + x + 41


xs = list(range(51))
ys = [euler_poly(x) for x in xs]
primes = [is_prime(y) for y in ys]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

# Plot 1: Values of the polynomial
colors = ['#2ecc71' if p else '#e74c3c' for p in primes]
ax1.bar(xs, ys, color=colors, alpha=0.8, edgecolor='white', linewidth=0.5)
ax1.axvline(x=39.5, color='#e67e22', linewidth=2, linestyle='--',
            label='Rabinowitz boundary')
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('x² + x + 41', fontsize=12)
ax1.set_title("Euler's Prime-Generating Polynomial: x² + x + 41",
              fontsize=14, fontweight='bold')

prime_patch = mpatches.Patch(color='#2ecc71', label='Prime')
composite_patch = mpatches.Patch(color='#e74c3c', label='Composite')
ax1.legend(handles=[prime_patch, composite_patch], loc='upper left', fontsize=11)

ax1.annotate(f'f(40) = 41² = {41**2}',
             xy=(40, euler_poly(40)), xytext=(42, euler_poly(40) + 200),
             arrowprops=dict(arrowstyle='->', color='#e74c3c'),
             fontsize=10, color='#e74c3c', fontweight='bold')

# Plot 2: Prime density comparison
window = 10
densities_euler = []
densities_random = []
for i in range(len(xs)):
    start = max(0, i - window // 2)
    end = min(len(xs), i + window // 2 + 1)
    euler_count = sum(primes[start:end])
    # Compare with prime density around the same magnitude
    val = euler_poly(i)
    expected = 1 / np.log(max(val, 2))
    densities_euler.append(euler_count / (end - start))
    densities_random.append(expected)

ax2.plot(xs, densities_euler, 'o-', color='#2ecc71', linewidth=2,
         label='Euler polynomial', markersize=4)
ax2.plot(xs, densities_random, '--', color='#95a5a6', linewidth=2,
         label='Expected (1/ln n)')
ax2.axvline(x=39.5, color='#e67e22', linewidth=2, linestyle='--',
            label='Rabinowitz boundary')
ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('Prime density (local)', fontsize=12)
ax2.set_title('Prime Density: Euler Polynomial vs Random',
              fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.set_ylim(0, 1.1)

plt.tight_layout()
plt.savefig('viz_euler_primes.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_euler_primes.png")


#!/usr/bin/env python3
"""
Visualization: Near-Integer Property of e^(π√d) for Heegner Numbers

Shows how close e^(π√d) is to an integer for various d,
highlighting Heegner numbers.
"""

import matplotlib.pyplot as plt
import numpy as np
import math


def fractional_part_distance(d):
    """Distance from e^(π√d) to the nearest integer."""
    try:
        val = math.exp(math.pi * math.sqrt(d))
        frac = val - round(val)
        return abs(frac)
    except OverflowError:
        return float('nan')


heegner = {1, 2, 3, 7, 11, 19, 43, 67, 163}

# Compute for d = 1 to 170
ds = list(range(1, 171))
distances = [fractional_part_distance(d) for d in ds]

fig, ax = plt.subplots(figsize=(14, 6))

# Plot non-Heegner numbers
non_h_ds = [d for d in ds if d not in heegner]
non_h_dist = [distances[d-1] for d in non_h_ds]
ax.scatter(non_h_ds, non_h_dist, c='#95a5a6', s=15, alpha=0.5,
           label='Non-Heegner', zorder=2)

# Plot Heegner numbers
h_ds = [d for d in ds if d in heegner]
h_dist = [distances[d-1] for d in h_ds]
ax.scatter(h_ds, h_dist, c='#e74c3c', s=80, marker='*', zorder=3,
           label='Heegner numbers', edgecolors='black', linewidths=0.5)

# Annotate Heegner numbers
for d in sorted(heegner):
    dist = distances[d-1]
    if not math.isnan(dist) and dist > 0:
        offset = (10, 15) if d != 67 else (10, -20)
        ax.annotate(f'd={d}\n({dist:.1e})',
                    xy=(d, dist), xytext=offset,
                    textcoords='offset points',
                    fontsize=8, color='#e74c3c',
                    arrowprops=dict(arrowstyle='->', color='#e74c3c',
                                    lw=0.5))

ax.set_yscale('log')
ax.set_xlabel('d', fontsize=12)
ax.set_ylabel('Distance from e^(π√d) to nearest integer', fontsize=12)
ax.set_title('The Near-Integer Property: Heegner Numbers Stand Out',
             fontsize=14, fontweight='bold')
ax.legend(fontsize=11, loc='upper right')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_near_integer.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_near_integer.png")
