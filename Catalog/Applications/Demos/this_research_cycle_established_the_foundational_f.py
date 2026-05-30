"""
Applications of Heegner Number Theory

Demonstrates real-world applications:
1. Cryptographic key generation using prime-rich polynomials
2. Error-correcting codes from Heegner lattices
3. Integer approximation using the Ramanujan constant
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


# Application 1: Prime Generation for Cryptography
def generate_primes_euler(count: int = 10, start: int = 0) -> List[int]:
    """Generate primes using Euler's polynomial n²+n+41.

    For n < 40, every value is guaranteed prime by the Heegner theory.
    Beyond n = 39, primality is not guaranteed but the polynomial
    still has a high prime density.

    Args:
        count: Number of primes to generate
        start: Starting value of n

    Returns:
        List of primes generated
    """
    primes = []
    n = start
    while len(primes) < count:
        val = n * n + n + 41
        if is_prime(val):
            primes.append(val)
        n += 1
    return primes


# Application 2: Lattice-Based Error Correction
def heegner_lattice_points(radius: int) -> List[Tuple[int, int, int]]:
    """Find lattice points within a given norm bound.

    The Heegner lattice Q(x,y) = x² + xy + 41y² provides an optimal
    2D lattice for error correction with discriminant -163.

    Points are sorted by their form value (squared distance from origin).

    Args:
        radius: Maximum coordinate magnitude

    Returns:
        List of (x, y, Q(x,y)) sorted by distance
    """
    points = []
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            if x == 0 and y == 0:
                continue
            q = x * x + x * y + 41 * y * y
            points.append((x, y, q))
    points.sort(key=lambda t: t[2])
    return points


def lattice_packing_density_2d(det_4: int) -> float:
    """Compute the packing density of a 2D lattice.

    For a lattice with 4×det = det_4 and minimum norm 1,
    the packing density is π / (4 · √(det_4/4)).

    Args:
        det_4: Four times the Gram matrix determinant

    Returns:
        Packing density (fraction of space covered)
    """
    det = det_4 / 4.0
    return math.pi / (4 * math.sqrt(det))


# Application 3: Near-Integer Approximations
def ramanujan_near_integers() -> List[Tuple[int, float, float]]:
    """Compute near-integer values of e^(π√d) for Heegner numbers d.

    The class number 1 property causes e^(π√d) to be remarkably
    close to an integer for Heegner numbers d ≡ 3 (mod 4).

    Returns:
        List of (d, e^(π√d), distance_to_nearest_integer)
    """
    heegner_3mod4 = [3, 7, 11, 19, 43, 67, 163]
    results = []
    for d in heegner_3mod4:
        val = math.exp(math.pi * math.sqrt(d))
        nearest = round(val)
        dist = abs(val - nearest)
        results.append((d, val, dist))
    return results


# Application 4: Prime Density Comparison
def prime_density_comparison(poly_fn, label: str, n_range: int = 100) -> dict:
    """Compare the prime density of a polynomial against random expectation.

    By the prime number theorem, a random number near N has probability
    ~1/ln(N) of being prime. We compare the actual density of the polynomial.

    Args:
        poly_fn: Function mapping n to a value
        label: Name for the polynomial
        n_range: Range to test

    Returns:
        Dictionary with density statistics
    """
    prime_count = 0
    expected_density = 0.0
    for n in range(n_range):
        val = poly_fn(n)
        if is_prime(val):
            prime_count += 1
        if val > 1:
            expected_density += 1.0 / math.log(val)

    actual = prime_count / n_range
    expected = expected_density / n_range
    return {
        "polynomial": label,
        "range": n_range,
        "primes_found": prime_count,
        "actual_density": actual,
        "expected_density": expected,
        "ratio": actual / expected if expected > 0 else float('inf')
    }


def main():
    print("=" * 70)
    print("APPLICATIONS OF HEEGNER NUMBER THEORY")
    print("=" * 70)

    # App 1: Prime Generation
    print("\n--- Application 1: Prime Generation ---")
    primes = generate_primes_euler(20)
    print(f"First 20 primes from n²+n+41: {primes}")

    # App 2: Lattice Coding
    print("\n--- Application 2: Lattice Error Correction ---")
    points = heegner_lattice_points(3)
    print(f"Heegner lattice points (sorted by distance):")
    for x, y, q in points[:15]:
        print(f"  ({x:>2}, {y:>2}): Q = {q}")
    density = lattice_packing_density_2d(163)
    print(f"\nPacking density for Heegner lattice: {density:.6f}")
    print(f"Optimal hexagonal packing density: {math.pi / (2 * math.sqrt(3)):.6f}")

    # App 3: Near-Integers
    print("\n--- Application 3: Ramanujan Near-Integers ---")
    for d, val, dist in ramanujan_near_integers():
        print(f"  d = {d:>3}: e^(π√{d}) ≈ {val:.4f}, "
              f"distance to integer: {dist:.2e}")

    # App 4: Prime Density
    print("\n--- Application 4: Prime Density Comparison ---")
    polys = [
        (lambda n: n * n + n + 41, "n²+n+41 (Euler)"),
        (lambda n: n * n + n + 17, "n²+n+17 (d=67)"),
        (lambda n: n * n + n + 11, "n²+n+11 (d=43)"),
        (lambda n: n * n + 1, "n²+1 (baseline)"),
    ]
    for fn, label in polys:
        stats = prime_density_comparison(fn, label, 100)
        print(f"  {label}:")
        print(f"    Primes in [0,99]: {stats['primes_found']}/100")
        print(f"    Actual density: {stats['actual_density']:.3f}")
        print(f"    Expected (PNT): {stats['expected_density']:.3f}")
        print(f"    Ratio (actual/expected): {stats['ratio']:.2f}")


if __name__ == "__main__":
    main()


"""
Demonstration of the Number 163 and Heegner Number Theory

This script demonstrates the key mathematical results about the number 163,
Euler's prime-generating polynomial, and the Heegner quadratic form.
"""

import math
from typing import List, Tuple


def euler_poly(n: int) -> int:
    """Euler's prime-generating polynomial: f(n) = n² + n + 41"""
    return n * n + n + 41


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


def heegner_form(x: int, y: int) -> int:
    """The Heegner quadratic form: Q(x,y) = x² + xy + 41y²"""
    return x * x + x * y + 41 * y * y


def main():
    print("=" * 70)
    print("THE NUMBER 163: Heegner Numbers, Euler's Polynomial, and Beyond")
    print("=" * 70)

    # Demo 1: Euler's polynomial generates 40 consecutive primes
    print("\n--- Demo 1: Euler's Polynomial n² + n + 41 ---")
    print(f"{'n':>4} | {'f(n)':>8} | {'Prime?':>6}")
    print("-" * 25)
    all_prime = True
    for n in range(40):
        val = euler_poly(n)
        prime = is_prime(val)
        if not prime:
            all_prime = False
        print(f"{n:>4} | {val:>8} | {'YES' if prime else 'NO':>6}")
    print(f"\nAll 40 values prime: {all_prime}")
    print(f"First value: f(0) = {euler_poly(0)} (prime: {is_prime(euler_poly(0))})")
    print(f"Last value: f(39) = {euler_poly(39)} (prime: {is_prime(euler_poly(39))})")
    print(f"f(40) = {euler_poly(40)} = 41² (NOT prime, first composite!)")

    # Demo 2: Non-divisibility by small primes
    print("\n--- Demo 2: Non-Divisibility by Small Primes ---")
    primes_to_40 = [p for p in range(2, 41) if is_prime(p)]
    print(f"Primes ≤ 40: {primes_to_40}")
    for p in primes_to_40:
        # Check all residues mod p
        has_root = False
        for r in range(p):
            if (r * r + r + 41) % p == 0:
                has_root = True
                break
        print(f"  x² + x + 41 ≡ 0 (mod {p:>2}) has solution: {has_root}")

    # Demo 3: The Heegner quadratic form
    print("\n--- Demo 3: Heegner Quadratic Form Q(x,y) = x² + xy + 41y² ---")
    print("Completing the square: 4Q(x,y) = (2x+y)² + 163y²")
    for x, y in [(1, 0), (0, 1), (1, 1), (-1, 1), (2, 1), (1, 2)]:
        q = heegner_form(x, y)
        lhs = 4 * q
        rhs = (2 * x + y) ** 2 + 163 * y * y
        print(f"  Q({x:>2}, {y:>2}) = {q:>5}   "
              f"4Q = {lhs:>5} = {(2*x+y)}² + 163·{y}² = {rhs}")

    # Demo 4: Heegner numbers
    print("\n--- Demo 4: The Nine Heegner Numbers ---")
    heegner = [1, 2, 3, 7, 11, 19, 43, 67, 163]
    print(f"Heegner numbers: {heegner}")
    print(f"Sum: {sum(heegner)}")
    for d in heegner:
        if d > 3 and d % 4 == 3:
            p = (d + 1) // 4
            print(f"  d = {d:>3}: p = (d+1)/4 = {p:>2}, "
                  f"prime-generating radius = {p-1}")

    # Demo 5: Euler lucky primes
    print("\n--- Demo 5: Euler Lucky Primes ---")
    euler_lucky = [2, 3, 5, 11, 17, 41]
    for p in euler_lucky:
        count = 0
        for n in range(p - 1):
            if is_prime(n * n + n + p):
                count += 1
            else:
                break
        all_ok = count == p - 1
        print(f"  p = {p:>2}: n² + n + {p} prime for n = 0,...,{p-2}: {all_ok}")

    # Demo 6: The Ramanujan constant
    print("\n--- Demo 6: The Ramanujan Constant ---")
    val = math.exp(math.pi * math.sqrt(163))
    nearest = 262537412640768744
    print(f"  e^(π√163) ≈ {val:.6f}")
    print(f"  640320³ + 744 = {640320**3 + 744}")
    print(f"  Difference: ~{abs(val - nearest):.2e}")

    # Demo 7: Cross-Heegner coprimality test
    print("\n--- Demo 7: Cross-Heegner Coprimality Conjecture ---")
    max_gcd = 0
    for n in range(10):
        for m in range(40):
            g = math.gcd(n*n + n + 11, m*m + m + 41)
            if g > max_gcd:
                max_gcd = g
                if g > 1:
                    print(f"  COUNTEREXAMPLE: gcd(f₁({n}), f₂({m})) = {g}")
    if max_gcd == 1:
        print(f"  All 400 pairs coprime! Conjecture verified computationally.")
    print(f"  Maximum GCD found: {max_gcd}")


if __name__ == "__main__":
    main()


"""
Visualization 1: Euler's Prime-Generating Polynomial

Shows the values of n²+n+41 for n = 0,...,45, highlighting which values
are prime (green) and which are composite (red). The transition at n=40
is the dramatic boundary predicted by Heegner number theory.
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


def euler_poly(n):
    return n * n + n + 41


fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [3, 1]})

ns = list(range(46))
vals = [euler_poly(n) for n in ns]
primes = [is_prime(v) for v in vals]

# Top plot: polynomial values with prime/composite coloring
colors = ['#2ecc71' if p else '#e74c3c' for p in primes]
ax1.bar(ns, vals, color=colors, alpha=0.8, edgecolor='white', linewidth=0.5)
ax1.axvline(x=39.5, color='#f39c12', linewidth=2, linestyle='--',
            label='Boundary: n = 40')
ax1.set_xlabel('n', fontsize=14)
ax1.set_ylabel('f(n) = n² + n + 41', fontsize=14)
ax1.set_title("Euler's Prime-Generating Polynomial: 40 Consecutive Primes",
              fontsize=16, fontweight='bold')
ax1.legend(fontsize=12)

# Add text annotations
ax1.annotate('f(0) = 41', xy=(0, 41), xytext=(5, 200),
            fontsize=10, arrowprops=dict(arrowstyle='->', color='gray'))
ax1.annotate('f(39) = 1601', xy=(39, 1601), xytext=(30, 1400),
            fontsize=10, arrowprops=dict(arrowstyle='->', color='gray'))
ax1.annotate('f(40) = 1681 = 41²\n(COMPOSITE!)',
            xy=(40, 1681), xytext=(35, 1850),
            fontsize=10, color='#e74c3c', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#e74c3c'))

# Legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#2ecc71', label='Prime'),
                   Patch(facecolor='#e74c3c', label='Composite')]
ax1.legend(handles=legend_elements, fontsize=12, loc='upper left')

# Bottom plot: prime/composite indicator
ax2.bar(ns, [1 if p else -1 for p in primes], color=colors, alpha=0.8)
ax2.axvline(x=39.5, color='#f39c12', linewidth=2, linestyle='--')
ax2.set_xlabel('n', fontsize=14)
ax2.set_ylabel('Prime?', fontsize=14)
ax2.set_yticks([1, -1])
ax2.set_yticklabels(['Yes', 'No'])
ax2.set_title('Primality Pattern: Perfect Run of 40, Then Failure', fontsize=13)

plt.tight_layout()
plt.savefig('viz_euler_primes.png', dpi=150, bbox_inches='tight')
print("Saved viz_euler_primes.png")


"""
Visualization 2: The Heegner Lattice for d = 163

Plots the level curves of the quadratic form Q(x,y) = x² + xy + 41y²,
showing the elliptical contours that define the lattice geometry.
The lattice points and their form values are overlaid.
"""

import matplotlib.pyplot as plt
import numpy as np


def heegner_form(x, y):
    """Q(x,y) = x² + xy + 41y²"""
    return x**2 + x * y + 41 * y**2


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


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: Contour plot of the quadratic form
x = np.linspace(-8, 8, 400)
y = np.linspace(-2, 2, 400)
X, Y = np.meshgrid(x, y)
Z = X**2 + X * Y + 41 * Y**2

levels = [1, 5, 10, 20, 41, 43, 50, 80, 100, 150, 200]
cs = ax1.contour(X, Y, Z, levels=levels, cmap='viridis', linewidths=1.5)
ax1.clabel(cs, inline=True, fontsize=9, fmt='%d')
ax1.contourf(X, Y, Z, levels=50, cmap='viridis', alpha=0.3)

# Plot lattice points
lattice_points = []
for ix in range(-7, 8):
    for iy in range(-1, 2):
        if ix == 0 and iy == 0:
            continue
        q = heegner_form(ix, iy)
        if q <= 200:
            lattice_points.append((ix, iy, q))

for ix, iy, q in lattice_points:
    color = '#e74c3c' if is_prime(q) else '#3498db'
    marker = '*' if is_prime(q) else 'o'
    size = 100 if is_prime(q) else 50
    ax1.plot(ix, iy, marker, color=color, markersize=8,
             markeredgecolor='white', markeredgewidth=0.5)
    ax1.annotate(f'{q}', (ix, iy), textcoords="offset points",
                xytext=(5, 5), fontsize=7, color='white',
                bbox=dict(boxstyle='round,pad=0.2', facecolor=color, alpha=0.7))

ax1.plot(0, 0, 'w+', markersize=15, markeredgewidth=2)
ax1.set_xlabel('x', fontsize=14)
ax1.set_ylabel('y', fontsize=14)
ax1.set_title('Heegner Quadratic Form Q(x,y) = x² + xy + 41y²\n'
              'Lattice points colored by primality', fontsize=13, fontweight='bold')
ax1.set_facecolor('#1a1a2e')
ax1.set_xlim(-8, 8)
ax1.set_ylim(-1.5, 1.5)

# Right: The completing-the-square decomposition
# 4Q = (2x+y)² + 163y² — visualize as u-v plane
u = np.linspace(-10, 10, 400)
v = np.linspace(-2, 2, 400)
U, V = np.meshgrid(u, v)
Z2 = U**2 + 163 * V**2  # This is 4Q after change of variables

levels2 = [4, 20, 40, 80, 164, 172, 200, 400, 600, 800]
cs2 = ax2.contour(U, V, Z2, levels=levels2, cmap='plasma', linewidths=1.5)
ax2.clabel(cs2, inline=True, fontsize=9, fmt='%d')
ax2.contourf(U, V, Z2, levels=50, cmap='plasma', alpha=0.3)

# Key points in (u,v) = (2x+y, y) coordinates
key_pts = [
    (2, 0, "Q=1\n(1,0)"), (1, 1, "Q=41\n(0,1)"),
    (3, 1, "Q=43\n(1,1)"), (-1, 1, "Q=41\n(-1,1)")
]
for u_pt, v_pt, label in key_pts:
    val = u_pt**2 + 163 * v_pt**2
    ax2.plot(u_pt, v_pt, 'w*', markersize=12)
    ax2.annotate(label, (u_pt, v_pt), textcoords="offset points",
                xytext=(8, 8), fontsize=9, color='white',
                bbox=dict(boxstyle='round', facecolor='#8e44ad', alpha=0.8))

ax2.set_xlabel('u = 2x + y', fontsize=14)
ax2.set_ylabel('v = y', fontsize=14)
ax2.set_title('Completing the Square: 4Q = u² + 163v²\n'
              'Reveals circular symmetry scaled by √163', fontsize=13, fontweight='bold')
ax2.set_facecolor('#1a1a2e')

plt.tight_layout()
plt.savefig('viz_heegner_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_heegner_lattice.png")


"""
Visualization 3: The Ramanujan Constant and Near-Integer Phenomenon

Shows how e^(π√d) approaches integers for Heegner numbers d,
with the dramatic case d = 163 where the distance is ~7.5×10⁻¹³.
This visualization connects the algebraic (class number 1) property
to the transcendental (exponential) world.
"""

import matplotlib.pyplot as plt
import numpy as np
import math


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


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Distance to nearest integer for e^(π√d)
ax1 = axes[0, 0]
heegner_3mod4 = [3, 7, 11, 19, 43, 67, 163]
distances = []
for d in heegner_3mod4:
    val = math.exp(math.pi * math.sqrt(d))
    dist = abs(val - round(val))
    distances.append(dist)

ax1.semilogy(heegner_3mod4, distances, 'o-', color='#e74c3c',
             markersize=10, linewidth=2, markeredgecolor='white')
for d, dist in zip(heegner_3mod4, distances):
    ax1.annotate(f'd={d}\n{dist:.1e}', (d, dist),
                textcoords="offset points", xytext=(10, 5),
                fontsize=8, color='#ecf0f1')
ax1.set_xlabel('Heegner number d', fontsize=13)
ax1.set_ylabel('|e^(π√d) - nearest integer|', fontsize=13)
ax1.set_title('The Ramanujan Phenomenon:\ne^(π√d) Nearly Integer for Heegner Numbers',
              fontsize=13, fontweight='bold')
ax1.set_facecolor('#2c3e50')
ax1.grid(True, alpha=0.3)

# Plot 2: Non-Heegner comparison
ax2 = axes[0, 1]
all_d = list(range(3, 170, 4))  # d ≡ 3 mod 4
distances_all = []
is_heegner = []
for d in all_d:
    try:
        val = math.exp(math.pi * math.sqrt(d))
        dist = abs(val - round(val))
        distances_all.append(dist)
        is_heegner.append(d in heegner_3mod4)
    except OverflowError:
        distances_all.append(None)
        is_heegner.append(False)

colors = ['#e74c3c' if h else '#95a5a6' for h in is_heegner]
sizes = [80 if h else 20 for h in is_heegner]
valid = [(d, dist, c, s) for d, dist, c, s in zip(all_d, distances_all, colors, sizes)
         if dist is not None and dist > 0]
if valid:
    ds, dists, cs, ss = zip(*valid)
    ax2.scatter(ds, [math.log10(d) if d > 0 else -15 for d in dists],
                c=cs, s=ss, alpha=0.7, edgecolors='white', linewidths=0.5)
ax2.set_xlabel('d (≡ 3 mod 4)', fontsize=13)
ax2.set_ylabel('log₁₀(distance to integer)', fontsize=13)
ax2.set_title('Heegner vs Non-Heegner:\nOnly Class Number 1 Gives Near-Integers',
              fontsize=13, fontweight='bold')
ax2.set_facecolor('#2c3e50')
ax2.grid(True, alpha=0.3)
from matplotlib.patches import Patch
ax2.legend(handles=[Patch(facecolor='#e74c3c', label='Heegner'),
                     Patch(facecolor='#95a5a6', label='Non-Heegner')],
           fontsize=10)

# Plot 3: Prime density of Euler polynomials from different Heegner numbers
ax3 = axes[1, 0]
heegner_primes = {163: 41, 67: 17, 43: 11}
for d, p in heegner_primes.items():
    ns = list(range(50))
    prime_count = []
    total = 0
    for n in ns:
        val = n * n + n + p
        if is_prime(val):
            total += 1
        prime_count.append(total / (n + 1))
    label = f'd={d}, p={p}'
    ax3.plot(ns, prime_count, linewidth=2, label=label)

# Baseline: n²+1
ns = list(range(50))
baseline = []
total = 0
for n in ns:
    if is_prime(n * n + 1):
        total += 1
    baseline.append(total / (n + 1))
ax3.plot(ns, baseline, '--', linewidth=1.5, color='gray', label='n²+1 (baseline)')

ax3.set_xlabel('n', fontsize=13)
ax3.set_ylabel('Cumulative prime density', fontsize=13)
ax3.set_title('Prime Density: Heegner Polynomials\nvs Baseline', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.set_facecolor('#2c3e50')
ax3.grid(True, alpha=0.3)

# Plot 4: The six Euler lucky primes and their generating ranges
ax4 = axes[1, 1]
euler_lucky = [(2, 1), (3, 2), (5, 4), (11, 10), (17, 16), (41, 40)]
ps = [p for p, _ in euler_lucky]
ranges = [r for _, r in euler_lucky]

bars = ax4.barh(range(len(ps)), ranges, color=['#1abc9c', '#2ecc71', '#3498db',
                                                 '#9b59b6', '#e67e22', '#e74c3c'],
                alpha=0.8, edgecolor='white')
ax4.set_yticks(range(len(ps)))
ax4.set_yticklabels([f'p = {p}' for p in ps], fontsize=12)
ax4.set_xlabel('Prime-generating range (# consecutive primes)', fontsize=13)
ax4.set_title('The Six Euler Lucky Primes\nand Their Prime-Generating Power',
              fontsize=13, fontweight='bold')
ax4.set_facecolor('#2c3e50')

for i, (p, r) in enumerate(euler_lucky):
    d = 4 * p - 1
    ax4.text(r + 0.5, i, f'd = {d}', va='center', fontsize=10, color='#ecf0f1')

plt.tight_layout()
plt.savefig('viz_ramanujan.png', dpi=150, bbox_inches='tight')
print("Saved viz_ramanujan.png")
