#!/usr/bin/env python3
"""
Goldilocks Theorem — Numerical Demonstrations

Demonstrates the key results:
1. Apsidal ratio computation for various dimensions
2. Bertrand classification for integer exponents
3. Orbit simulation showing closure/precession
"""

import math
from fractions import Fraction


def apsidal_ratio(n: int) -> float | None:
    """Gravitational apsidal ratio in n spatial dimensions: sqrt(4-n)."""
    val = 4 - n
    if val < 0:
        return None  # Unstable
    return math.sqrt(val)


def bertrand_apsidal(alpha: float) -> float | None:
    """Apsidal ratio for force law F(r) = -k*r^alpha: sqrt(3+alpha)."""
    val = 3 + alpha
    if val < 0:
        return None
    return math.sqrt(val)


def is_perfect_rational_square(p: int, q: int) -> bool:
    """Check if p/q is a perfect square of a rational number."""
    # p/q = (a/b)^2 iff p*q is a perfect square (when gcd(p,q)=1)
    g = math.gcd(abs(p), abs(q))
    p2, q2 = abs(p) // g, abs(q) // g
    # Need p2*q2 to be a perfect square? No, need p2 and q2 each to be perfect squares
    def is_perfect_sq(n):
        if n < 0:
            return False
        s = int(math.isqrt(n))
        return s * s == n
    return p >= 0 and is_perfect_sq(p2) and is_perfect_sq(q2)


def classify_dimension(n: int) -> str:
    """Classify spatial dimension into orbit regime."""
    if n < 2:
        return "INVALID (need n >= 2)"
    if n >= 4:
        return "UNSTABLE (no stable circular orbits)"
    if n == 3:
        return "GOLDILOCKS (stable, closed orbits, finite escape velocity)"
    if n == 2:
        return "PRECESSING (stable but orbits never close)"
    return "UNKNOWN"


def simulate_orbit(n: int, num_revolutions: int = 20, steps_per_rev: int = 1000):
    """
    Simulate a nearly circular orbit in n dimensions.
    Returns list of (x, y) coordinates.
    """
    if 4 - n <= 0:
        return []  # No stable orbit

    rho = math.sqrt(4 - n)
    r0 = 1.0
    epsilon = 0.05  # Small perturbation

    coords = []
    for i in range(num_revolutions * steps_per_rev):
        theta = 2 * math.pi * i / steps_per_rev
        # r(theta) = r0 * (1 + epsilon * cos(rho * theta))
        r = r0 * (1 + epsilon * math.cos(rho * theta))
        x = r * math.cos(theta)
        y = r * math.sin(theta)
        coords.append((x, y))

    return coords


def main():
    print("=" * 60)
    print("THE GOLDILOCKS THEOREM")
    print("Dimension 3 is unique for gravitational orbits")
    print("=" * 60)

    # 1. Dimensional classification
    print("\n--- Dimension Classification ---")
    for n in range(1, 8):
        rho = apsidal_ratio(n)
        rho_str = f"sqrt({4-n}) = {rho:.4f}" if rho is not None else "imaginary"
        print(f"  n={n}: rho = {rho_str:>25s}  =>  {classify_dimension(n)}")

    # 2. Bertrand classification
    print("\n--- Discrete Bertrand Classification ---")
    print("  Force law F(r) = -k*r^alpha, apsidal ratio = sqrt(3+alpha)")
    print(f"  {'alpha':>6s}  {'3+alpha':>8s}  {'rho':>10s}  {'rational?':>10s}")
    print(f"  {'-'*6}  {'-'*8}  {'-'*10}  {'-'*10}")
    for alpha in range(-2, 3):
        val = 3 + alpha
        rho = bertrand_apsidal(alpha)
        # Check if val is a perfect square
        is_sq = int(math.isqrt(val)) ** 2 == val if val >= 0 else False
        rational_str = "YES" if is_sq else "NO"
        print(f"  {alpha:>6d}  {val:>8d}  {rho:>10.4f}  {rational_str:>10s}")

    # 3. Number theory bridge
    print("\n--- Number Theory <-> Physics Bridge ---")
    print("  Closed orbits in dim n  <=>  sqrt(4-n) is rational")
    print("  Irrational sqrt(2) [proved ~500 BCE] => 2D orbits precess")
    print("  sqrt(1) = 1 [trivially rational] => 3D orbits close")

    # 4. General Bertrand test
    print("\n--- General Bertrand Rationality Test ---")
    print("  Testing rational exponents alpha = p/q for q <= 10:")
    rational_alphas = []
    for q in range(1, 11):
        for p in range(-3 * q + 1, 10 * q):
            alpha_num = p
            alpha_den = q
            # 3 + p/q = (3q + p) / q
            val_num = 3 * q + p
            val_den = q
            if val_num <= 0:
                continue
            if is_perfect_rational_square(val_num, val_den):
                alpha_frac = Fraction(p, q)
                val_frac = Fraction(val_num, val_den)
                sq_root = Fraction(int(math.isqrt(val_num * val_den)), val_den)
                # More careful: sqrt(val_num/val_den) rational
                rational_alphas.append((float(alpha_frac), alpha_frac, val_frac))

    # Deduplicate
    seen = set()
    for val, frac, v in sorted(set(rational_alphas))[:20]:
        if frac not in seen:
            seen.add(frac)
            print(f"    alpha = {str(frac):>8s}  =>  3+alpha = {str(v):>8s} = perfect rational square")

    # 5. Orbit visualization data
    print("\n--- Orbit Characteristics ---")
    for n in [2, 3]:
        coords = simulate_orbit(n, num_revolutions=10)
        if coords:
            xs, ys = zip(*coords)
            # Check how close the orbit comes to closing
            start = coords[0]
            min_dist = float('inf')
            for i in range(len(coords) // 2, len(coords)):
                d = math.sqrt((coords[i][0] - start[0])**2 + (coords[i][1] - start[1])**2)
                if d < min_dist and i > 100:
                    min_dist = d
            print(f"  Dim {n}: orbit {'closes' if min_dist < 0.001 else 'precesses'} "
                  f"(min return distance = {min_dist:.6f})")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Bertrand Classification
Shows which integer force-law exponents produce closed vs precessing orbits.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: sqrt(3+alpha) for alpha in [-2.5, 3]
alphas = np.linspace(-2.9, 5, 1000)
vals = 3 + alphas
rhos = np.where(vals >= 0, np.sqrt(vals), np.nan)

ax1.plot(alphas, rhos, 'b-', linewidth=2, label='ρ(α) = √(3+α)')
ax1.axhline(y=0, color='gray', linewidth=0.5)
ax1.axvline(x=-3, color='red', linewidth=1, linestyle='--', alpha=0.5, label='α = −3 (stability boundary)')

# Mark integer exponents
for alpha in range(-2, 3):
    val = 3 + alpha
    rho = math.sqrt(val) if val >= 0 else 0
    is_rational = int(math.isqrt(val)) ** 2 == val if val >= 0 else False
    color = '#27ae60' if is_rational else '#e74c3c'
    marker = '★' if is_rational else '✗'
    ax1.plot(alpha, rho, 'o', color=color, markersize=12, zorder=5)
    label = f'α={alpha}: ρ={rho:.3f}'
    if is_rational:
        label += ' ✓'
    ax1.annotate(f'α={alpha}\nρ={"√"+str(val) if not is_rational else str(int(rho))}',
                 (alpha, rho), textcoords="offset points", xytext=(15, 10),
                 fontsize=8, color=color, fontweight='bold')

ax1.set_xlabel('Force-law exponent α', fontsize=12)
ax1.set_ylabel('Apsidal ratio ρ = √(3+α)', fontsize=12)
ax1.set_title('Apsidal Ratio vs Force-Law Exponent\n(Green = rational = closed orbits)', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-3.5, 5.5)
ax1.set_ylim(-0.5, 3.5)

# Right: Number line showing irrationality
primes_in_range = [2, 3, 5]
ax2.set_xlim(-0.5, 6.5)
ax2.set_ylim(-1, 4)

for i, val in enumerate(range(0, 6)):
    y = 2.5
    sqrt_val = math.sqrt(val)
    is_perfect_sq = int(math.isqrt(val)) ** 2 == val

    # Draw the number
    color = '#27ae60' if is_perfect_sq else '#e74c3c'
    ax2.add_patch(plt.Circle((val, y), 0.3, color=color, alpha=0.3))
    ax2.text(val, y, str(val), ha='center', va='center', fontsize=14, fontweight='bold')

    # Label
    if is_perfect_sq:
        ax2.text(val, y - 0.6, f'√{val} = {int(sqrt_val)}\n∈ ℚ ✓',
                 ha='center', va='top', fontsize=9, color='#27ae60')
    else:
        reason = f'{val} prime' if val in primes_in_range else ''
        ax2.text(val, y - 0.6, f'√{val} ≈ {sqrt_val:.3f}\n∉ ℚ ✗\n({reason})',
                 ha='center', va='top', fontsize=9, color='#e74c3c')

ax2.set_title('Rationality of √n: The Number-Theoretic Sieve\n'
              'Primes → irrational roots → no closed orbits', fontsize=12)
ax2.axis('off')

plt.suptitle('Discrete Bertrand Classification',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('bertrand_classification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: bertrand_classification.png")


#!/usr/bin/env python3
"""
Visualization: Orbital trajectories in dimensions 2, 3, and 4.
Shows how orbits close in 3D but precess in 2D and are unstable in 4D+.
"""

import math
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def compute_orbit(n, eccentricity=0.08, num_points=50000, num_revolutions=30):
    """Compute orbit trajectory in n dimensions using linearized radial equation."""
    val = 4 - n
    if val <= 0:
        return None, None
    rho = math.sqrt(val)
    thetas = np.linspace(0, 2 * np.pi * num_revolutions, num_points)
    r = 1.0 + eccentricity * np.cos(rho * thetas)
    x = r * np.cos(thetas)
    y = r * np.sin(thetas)
    return x, y


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Dimension 2: Precessing orbit
x, y = compute_orbit(2)
axes[0].plot(x, y, linewidth=0.3, color='#e74c3c', alpha=0.6)
axes[0].plot(0, 0, 'ko', markersize=5)
axes[0].set_title('n = 2: Precessing Orbit\nρ = √2 ≈ 1.414 (irrational)',
                   fontsize=11, fontweight='bold')
axes[0].set_aspect('equal')
axes[0].set_xlim(-1.3, 1.3)
axes[0].set_ylim(-1.3, 1.3)
axes[0].grid(True, alpha=0.3)

# Dimension 3: Closed orbit (ellipse)
x, y = compute_orbit(3, eccentricity=0.3)
axes[1].plot(x, y, linewidth=1.5, color='#27ae60')
axes[1].plot(0, 0, 'ko', markersize=5)
axes[1].set_title('n = 3: Closed Orbit (Ellipse)\nρ = 1 (rational) ★ GOLDILOCKS',
                   fontsize=11, fontweight='bold')
axes[1].set_aspect('equal')
axes[1].set_xlim(-1.5, 1.5)
axes[1].set_ylim(-1.5, 1.5)
axes[1].grid(True, alpha=0.3)

# Dimension 4: Unstable
axes[2].text(0.5, 0.5, 'NO STABLE\nORBITS',
             transform=axes[2].transAxes, fontsize=20,
             ha='center', va='center', color='#95a5a6',
             fontweight='bold')
axes[2].text(0.5, 0.25, '4 − n = 0\nρ = 0 (degenerate)',
             transform=axes[2].transAxes, fontsize=10,
             ha='center', va='center', color='#bdc3c7')
axes[2].plot(0, 0, 'ko', markersize=5)
# Draw a spiral falling in
theta = np.linspace(0, 6 * np.pi, 1000)
r_spiral = 1.0 * np.exp(-0.08 * theta)
axes[2].plot(r_spiral * np.cos(theta), r_spiral * np.sin(theta),
             linewidth=0.8, color='#bdc3c7', alpha=0.5, linestyle='--')
axes[2].set_title('n = 4: Unstable\nρ = 0 (no oscillation)',
                   fontsize=11, fontweight='bold')
axes[2].set_aspect('equal')
axes[2].set_xlim(-1.3, 1.3)
axes[2].set_ylim(-1.3, 1.3)
axes[2].grid(True, alpha=0.3)

plt.suptitle('The Goldilocks Theorem: Orbital Behavior by Spatial Dimension',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('orbits_by_dimension.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: orbits_by_dimension.png")
