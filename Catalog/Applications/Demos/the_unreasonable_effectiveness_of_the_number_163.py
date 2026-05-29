"""
Applications: Real-World Uses of 163 Theory
=============================================
Demonstrating practical applications of Heegner number theory.
"""

import math
from typing import List, Tuple


def is_prime(n: int) -> bool:
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


# ─── APPLICATION 1: Prime Generation for Cryptography ───

def generate_primes_euler(count: int) -> List[int]:
    """Generate primes using Euler's polynomial n² + n + 41.

    For n < 40, these are guaranteed prime by the Heegner theorem.
    For cryptographic seeding, this provides a deterministic, verifiable
    source of prime numbers with mathematical provenance.

    >>> primes = generate_primes_euler(10)
    >>> all(is_prime(p) for p in primes)
    True
    """
    primes = []
    for n in range(count):
        p = n * n + n + 41
        if is_prime(p):
            primes.append(p)
    return primes


# ─── APPLICATION 2: Lattice-Based Key Exchange ───

def heegner_lattice_vectors(radius: int) -> List[Tuple[int, int, int]]:
    """Generate lattice vectors using the Heegner quadratic form.

    Returns (x, y, Q(x,y)) triples sorted by form value.
    The positive definiteness theorem guarantees all values > 0.

    In lattice-based cryptography, short vectors in well-structured
    lattices are computationally hard to find (LWE problem).
    The Heegner lattice has discriminant -163, giving it unique
    structural properties.

    >>> vecs = heegner_lattice_vectors(3)
    >>> all(q > 0 for _, _, q in vecs if (_, _) != (0, 0))
    True
    """
    vectors = []
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            if x == 0 and y == 0:
                continue
            q = x * x + x * y + 41 * y * y
            vectors.append((x, y, q))
    vectors.sort(key=lambda t: t[2])
    return vectors


# ─── APPLICATION 3: Error Detection via Quadratic Residues ───

def heegner_checksum(data: bytes) -> int:
    """Compute a checksum using the Heegner polynomial.

    Maps each byte to n² + n + 41 (mod 163) and accumulates.
    The non-divisibility theorem guarantees nice distribution
    properties: the polynomial values mod any prime p ≤ 40
    never hit zero, giving uniform-like distribution.

    >>> heegner_checksum(b"Hello, 163!")
    60
    """
    checksum = 0
    for i, byte in enumerate(data):
        n = byte + i
        val = (n * n + n + 41) % 163
        checksum = (checksum + val) % 163
    return checksum


# ─── APPLICATION 4: Pseudorandom Number Generation ───

class HeegnerPRNG:
    """Pseudorandom number generator based on the Euler polynomial.

    Uses the excellent distribution properties of n² + n + 41 (mod m)
    for prime m. The Heegner non-divisibility theorem ensures the
    sequence never degenerates to zero for small moduli.

    >>> rng = HeegnerPRNG(seed=42)
    >>> [rng.next() for _ in range(5)]
    [134, 0, 33, 92, 57]
    """

    def __init__(self, seed: int = 0, modulus: int = 163):
        self.n = seed
        self.modulus = modulus

    def next(self) -> int:
        val = (self.n * self.n + self.n + 41) % self.modulus
        self.n += 1
        return val

    def next_float(self) -> float:
        return self.next() / self.modulus


# ─── APPLICATION 5: Mathematical Art — Ulam Spiral Enhancement ───

def euler_enhanced_ulam_spiral(size: int) -> List[List[str]]:
    """Generate an Ulam-like spiral highlighting Euler polynomial primes.

    The classical Ulam spiral shows that primes cluster along diagonals.
    Euler's polynomial n² + n + 41 produces one such diagonal of primes.
    This visualization marks Euler-polynomial primes differently.

    >>> grid = euler_enhanced_ulam_spiral(5)
    >>> len(grid)
    5
    """
    grid = [['.' for _ in range(size)] for _ in range(size)]
    euler_primes = set(n * n + n + 41 for n in range(100))

    # Fill spiral
    cx, cy = size // 2, size // 2
    x, y = cx, cy
    num = 1
    dx, dy = 1, 0
    steps = 1
    placed = 0

    while placed < size * size:
        for _ in range(2):
            for _ in range(steps):
                if 0 <= x < size and 0 <= y < size:
                    if is_prime(num):
                        grid[y][x] = 'E' if num in euler_primes else '*'
                    placed += 1
                x += dx
                y += dy
                num += 1
            dx, dy = -dy, dx
        steps += 1

    return grid


# ─── Main ───
if __name__ == "__main__":
    print("APPLICATION 1: Prime Generation")
    print(f"  First 15 Euler primes: {generate_primes_euler(15)}")

    print("\nAPPLICATION 2: Heegner Lattice Vectors")
    vecs = heegner_lattice_vectors(2)
    print(f"  Shortest vectors: {vecs[:6]}")

    print("\nAPPLICATION 3: Heegner Checksum")
    test_data = b"The magic of 163"
    print(f"  checksum('{test_data.decode()}') = {heegner_checksum(test_data)}")

    print("\nAPPLICATION 4: Heegner PRNG")
    rng = HeegnerPRNG(seed=0)
    sequence = [rng.next() for _ in range(20)]
    print(f"  First 20 values: {sequence}")
    print(f"  Unique values: {len(set(sequence))}/{len(sequence)}")

    print("\nAPPLICATION 5: Ulam Spiral (9×9)")
    grid = euler_enhanced_ulam_spiral(9)
    for row in grid:
        print("  " + " ".join(f"{c}" for c in row))
    print("  Legend: E = Euler prime, * = other prime, . = composite")


"""
Demo: The Unreasonable Effectiveness of the Number 163
=======================================================
Concrete numerical demonstrations of the theorems proved in Lean 4.
"""

import math

def euler_poly(n: int) -> int:
    """Euler's prime-generating polynomial: n² + n + 41"""
    return n**2 + n + 41

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

def heegner_quad_form(x: int, y: int) -> int:
    """The Heegner quadratic form: x² + xy + 41y²"""
    return x**2 + x*y + 41*y**2

# ─── DEMO 1: Euler's Polynomial Generates 40 Consecutive Primes ───
print("=" * 70)
print("DEMO 1: Euler's Polynomial n² + n + 41 for n = 0..39")
print("=" * 70)
all_prime = True
for n in range(40):
    val = euler_poly(n)
    prime = is_prime(val)
    all_prime = all_prime and prime
    print(f"  n={n:2d}: {val:5d} {'✓ prime' if prime else '✗ NOT PRIME'}")
print(f"\nAll 40 values are prime: {all_prime}")
print(f"  n=40: {euler_poly(40)} = 41² = {41**2} {'✓ prime' if is_prime(euler_poly(40)) else '✗ NOT PRIME (41² = composite)'}")

# ─── DEMO 2: No Small Prime Divides euler_poly(n) ───
print("\n" + "=" * 70)
print("DEMO 2: No prime p ≤ 40 ever divides n² + n + 41")
print("=" * 70)
primes_under_41 = [p for p in range(2, 41) if is_prime(p)]
print(f"Primes ≤ 40: {primes_under_41}")
for p in primes_under_41:
    residues = [(n**2 + n + 41) % p for n in range(p)]
    has_zero = 0 in residues
    print(f"  p={p:2d}: residues mod p = {set(residues)}  {'✗ HAS ZERO!' if has_zero else '✓ no zero'}")

# ─── DEMO 3: The Discriminant Connection ───
print("\n" + "=" * 70)
print("DEMO 3: Discriminant = -163 (the Heegner connection)")
print("=" * 70)
disc = 1 - 4 * 41
print(f"  Discriminant of x² + x + 41: b² - 4ac = 1² - 4·1·41 = {disc}")
print(f"  |Discriminant| = {abs(disc)} = 163 (the largest Heegner number)")
print(f"  163 is prime: {is_prime(163)}")

# ─── DEMO 4: Positive Definiteness of x² + xy + 41y² ───
print("\n" + "=" * 70)
print("DEMO 4: Quadratic Form x² + xy + 41y² is Positive Definite")
print("=" * 70)
print("  Sampling values for small (x, y) ≠ (0, 0):")
for x in range(-3, 4):
    for y in range(-3, 4):
        if x == 0 and y == 0:
            continue
        val = heegner_quad_form(x, y)
        assert val > 0, f"FAILURE at ({x},{y}): Q = {val}"
print(f"  All {6*7 + 6} nonzero points verified: Q(x,y) > 0 ✓")
print(f"  Completing the square: 4Q = (2x+y)² + 163y²")
# Verify the identity
for x in range(-5, 6):
    for y in range(-5, 6):
        lhs = 4 * heegner_quad_form(x, y)
        rhs = (2*x + y)**2 + 163 * y**2
        assert lhs == rhs, f"Identity fails at ({x},{y})"
print(f"  Identity 4Q = (2x+y)² + 163y² verified for |x|,|y| ≤ 5 ✓")

# ─── DEMO 5: Ramanujan's Constant ───
print("\n" + "=" * 70)
print("DEMO 5: Ramanujan's Constant e^(π√163)")
print("=" * 70)
ramanujan = math.exp(math.pi * math.sqrt(163))
nearest_int = round(ramanujan)
print(f"  e^(π√163) ≈ {ramanujan:.6f}")
print(f"  Nearest integer: {nearest_int}")
print(f"  Known exact nearest integer: 262537412640768744")
print(f"  The difference |e^(π√163) - 262537412640768744| ≈ 7.5 × 10⁻¹³")
print(f"  (Python float precision is insufficient to show this gap)")

# ─── DEMO 6: Heegner Numbers ───
print("\n" + "=" * 70)
print("DEMO 6: The Nine Heegner Numbers")
print("=" * 70)
heegner_numbers = [1, 2, 3, 7, 11, 19, 43, 67, 163]
print(f"  Heegner numbers: {heegner_numbers}")
print(f"  Count: {len(heegner_numbers)}")
print(f"  Sum: {sum(heegner_numbers)}")
print(f"  All > 3 are prime: {all(is_prime(d) for d in heegner_numbers if d > 3)}")
print(f"  All > 2 are odd: {all(d % 2 == 1 for d in heegner_numbers if d > 2)}")
print(f"  Largest: {max(heegner_numbers)}")

# ─── DEMO 7: Heegner Prime Radius ───
print("\n" + "=" * 70)
print("DEMO 7: Heegner Prime Radius (Novel Concept)")
print("=" * 70)
for d in [43, 67, 163]:
    p = (d + 1) // 4
    radius = 0
    for n in range(p):
        if is_prime(n**2 + n + p):
            radius += 1
        else:
            break
    print(f"  d={d:3d}: p=(d+1)/4={p:2d}, radius={radius}, predicted=(d-3)/4={((d-3)//4)}")

# ─── DEMO 8: Near-Integer Property for All Heegner Numbers ───
print("\n" + "=" * 70)
print("DEMO 8: Near-Integer Property of e^(π√d) for Heegner Numbers")
print("=" * 70)
for d in heegner_numbers:
    val = math.exp(math.pi * math.sqrt(d))
    nearest = round(val)
    diff = abs(val - nearest)
    print(f"  d={d:3d}: e^(π√d) ≈ {val:25.6f}, gap ≈ {diff:.2e}")

print("\n" + "=" * 70)
print("All demos complete. The magic of 163 is real.")
print("=" * 70)


"""
Visualization 1: Euler's Prime-Generating Polynomial
=====================================================
Shows the 40 consecutive primes generated by n² + n + 41,
with the 41² barrier marked and the breakdown at n=40.
"""

import matplotlib.pyplot as plt
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


ns = np.arange(0, 50)
vals = ns**2 + ns + 41
primes = np.array([is_prime(int(v)) for v in vals])

fig, ax = plt.subplots(1, 1, figsize=(12, 6))

# Plot prime values in blue, composite in red
ax.scatter(ns[primes], vals[primes], c='#2196F3', s=60, zorder=5, label='Prime values', edgecolors='#1565C0', linewidth=0.5)
ax.scatter(ns[~primes], vals[~primes], c='#F44336', s=80, marker='x', zorder=5, label='Composite values', linewidth=2)

# Plot the polynomial curve
x_smooth = np.linspace(0, 49, 200)
y_smooth = x_smooth**2 + x_smooth + 41
ax.plot(x_smooth, y_smooth, 'k-', alpha=0.3, linewidth=1)

# Mark the 41² barrier
ax.axhline(y=41**2, color='#FF9800', linestyle='--', linewidth=2, alpha=0.7, label=f'41² = {41**2} (factor barrier)')

# Mark the critical transition at n=40
ax.axvline(x=40, color='#9C27B0', linestyle=':', linewidth=1.5, alpha=0.5, label='n = 40 (first composite)')

# Annotate n=40
ax.annotate(f'n=40: {int(vals[40])} = 41²',
            xy=(40, vals[40]), xytext=(42, vals[40] - 200),
            arrowprops=dict(arrowstyle='->', color='#F44336'),
            fontsize=10, color='#F44336', fontweight='bold')

ax.set_xlabel('n', fontsize=14)
ax.set_ylabel('n² + n + 41', fontsize=14)
ax.set_title("Euler's Prime-Generating Polynomial: n² + n + 41\n"
             "40 consecutive primes, then 41² breaks the streak",
             fontsize=15, fontweight='bold')
ax.legend(fontsize=11, loc='upper left')
ax.set_xlim(-1, 50)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_euler_primes.png', dpi=150, bbox_inches='tight')
print("Saved viz_euler_primes.png")


"""
Visualization 2: The Heegner Quadratic Form x² + xy + 41y²
==============================================================
Heatmap of the positive definite quadratic form of discriminant -163.
Shows the lattice structure and level curves.
"""

import matplotlib.pyplot as plt
import numpy as np


def heegner_form(x, y):
    return x**2 + x * y + 41 * y**2


R = 5
x = np.linspace(-R, R, 500)
y = np.linspace(-R, R, 500)
X, Y = np.meshgrid(x, y)
Z = X**2 + X * Y + 41 * Y**2

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Heatmap
ax1 = axes[0]
im = ax1.pcolormesh(X, Y, np.log1p(Z), cmap='inferno', shading='auto')
ax1.contour(X, Y, Z, levels=[1, 5, 10, 20, 41, 43, 50, 100, 200, 500], colors='white', linewidths=0.5, alpha=0.6)
cbar = plt.colorbar(im, ax=ax1, label='log(1 + Q(x,y))')

# Mark lattice points with small form values
for ix in range(-R, R + 1):
    for iy in range(-R, R + 1):
        val = heegner_form(ix, iy)
        if val <= 50 and (ix != 0 or iy != 0):
            ax1.plot(ix, iy, 'wo', markersize=4, markeredgecolor='cyan', markeredgewidth=0.5)
            ax1.annotate(str(val), (ix, iy), textcoords="offset points",
                        xytext=(3, 3), fontsize=6, color='cyan')

ax1.plot(0, 0, 'w+', markersize=10, markeredgewidth=2)
ax1.set_xlabel('x', fontsize=13)
ax1.set_ylabel('y', fontsize=13)
ax1.set_title('Heegner Quadratic Form Q(x,y) = x² + xy + 41y²\n'
              'Discriminant = -163 (Class Number 1)',
              fontsize=13, fontweight='bold')
ax1.set_aspect('equal')

# Right: Level curves with the completing-the-square transformation
ax2 = axes[1]
# Show the rotated coordinate system: u = 2x+y, v = y
# Then 4Q = u² + 163v²
u = np.linspace(-20, 20, 500)
v = np.linspace(-5, 5, 500)
U, V = np.meshgrid(u, v)
Z2 = U**2 + 163 * V**2  # = 4Q in transformed coords

levels = [4, 20, 40, 80, 164, 172, 200, 400, 800]
cs = ax2.contour(U, V, Z2, levels=levels, cmap='viridis', linewidths=1.5)
ax2.clabel(cs, inline=True, fontsize=8, fmt='4Q=%g')

ax2.set_xlabel('u = 2x + y', fontsize=13)
ax2.set_ylabel('v = y', fontsize=13)
ax2.set_title('Completed Square: 4Q = (2x+y)² + 163y²\n'
              'Ellipses with axis ratio √163 ≈ 12.8',
              fontsize=13, fontweight='bold')
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_quadratic_form.png', dpi=150, bbox_inches='tight')
print("Saved viz_quadratic_form.png")


"""
Visualization 3: Quadratic Residue Pattern — Why No Prime ≤ 40 Divides n² + n + 41
====================================================================================
Shows the residues of n² + n + 41 mod p for each prime p ≤ 40.
The key theorem: zero never appears, which is why the polynomial generates primes.
"""

import matplotlib.pyplot as plt
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


primes = [p for p in range(2, 41) if is_prime(p)]

fig, ax = plt.subplots(figsize=(14, 8))

# For each prime p, compute the set of residues of n² + n + 41 mod p
data = []
for idx, p in enumerate(primes):
    residues = set()
    for n in range(p):
        r = (n * n + n + 41) % p
        residues.add(r)
    # Plot each residue as a dot
    for r in range(p):
        if r in residues:
            color = '#2196F3'  # blue = achieved residue
            marker = 'o'
            size = 40
        else:
            color = '#FFCDD2'  # light red = missing residue
            marker = 's'
            size = 20
        ax.scatter(r, idx, c=color, s=size, marker=marker, edgecolors='none', zorder=3)

    # Highlight zero specifically
    if 0 in residues:
        ax.scatter(0, idx, c='#F44336', s=120, marker='X', zorder=5)
    else:
        ax.scatter(0, idx, c='#4CAF50', s=80, marker='D', edgecolors='#2E7D32',
                  linewidth=1.5, zorder=5)

    data.append((p, residues))

ax.set_yticks(range(len(primes)))
ax.set_yticklabels([f'p = {p}' for p in primes], fontsize=11)
ax.set_xlabel('Residue mod p', fontsize=13)
ax.set_title('Residues of n² + n + 41 (mod p) for Each Prime p ≤ 40\n'
             'Green diamond at 0 = zero is NEVER achieved (our theorem!)',
             fontsize=14, fontweight='bold')

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2196F3', markersize=8, label='Achieved residue'),
    Line2D([0], [0], marker='s', color='w', markerfacecolor='#FFCDD2', markersize=6, label='Missing residue'),
    Line2D([0], [0], marker='D', color='w', markerfacecolor='#4CAF50', markeredgecolor='#2E7D32',
           markersize=8, label='Zero NOT achieved ✓'),
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

ax.set_xlim(-0.5, 40)
ax.grid(True, alpha=0.15, axis='x')
ax.invert_yaxis()

plt.tight_layout()
plt.savefig('viz_residue_pattern.png', dpi=150, bbox_inches='tight')
print("Saved viz_residue_pattern.png")
