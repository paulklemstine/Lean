"""
Visualization: Newton Polygon and Tropical Persistence

Shows the Newton polygon of characteristic polynomials and how
tropical slopes (p-adic valuations) create a bridge between
arithmetic geometry and tropical geometry.
"""

import numpy as np
import matplotlib.pyplot as plt

def padic_val(n, p):
    """Compute the p-adic valuation of n."""
    if n == 0:
        return float('inf')
    v = 0
    n = abs(n)
    while n % p == 0:
        v += 1
        n //= p
    return v

def newton_polygon(coeffs, p):
    """Compute the Newton polygon of a polynomial at prime p.
    
    coeffs[i] is the coefficient of x^i.
    Returns the lower convex hull points.
    """
    points = [(i, padic_val(int(round(c.real)) if isinstance(c, complex) else c, p))
              for i, c in enumerate(coeffs) if c != 0 and padic_val(int(round(c.real)) if isinstance(c, complex) else c, p) != float('inf')]
    
    if len(points) < 2:
        return points
    
    # Compute lower convex hull
    points.sort()
    hull = [points[0]]
    for pt in points[1:]:
        while len(hull) >= 2:
            # Check if turning right (remove middle point)
            x1, y1 = hull[-2]
            x2, y2 = hull[-1]
            x3, y3 = pt
            cross = (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1)
            if cross <= 0:
                hull.pop()
            else:
                break
        hull.append(pt)
    
    return hull

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Example polynomials (characteristic polynomials of Frobenius)
# For an elliptic curve over F_p: t^2 - a_p * t + p
primes = [2, 3, 5, 7, 11, 13]
p_curve = 30030  # = 2*3*5*7*11*13, to have interesting valuations

examples = [
    ("Elliptic (tr=0, p=7)", [7, 0, 1]),
    ("Elliptic (tr=2, p=7)", [7, -2, 1]),
    ("Genus 2 (p=5)", [25, -10, 11, -3, 1]),
    ("Genus 2 (p=7)", [49, -14, 15, -4, 1]),
    ("K3 surface H² sample", [49, -7, 22, -7, 49, 0, 1]),
    ("Abelian surface (p=3)", [9, -6, 10, -6, 9, 0, 0, 0, 1]),
]

prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71', 7: '#9b59b6', 11: '#e67e22', 13: '#1abc9c'}

for idx, (name, coeffs) in enumerate(examples):
    row, col = idx // 3, idx % 3
    ax = axes[row, col]
    
    # Plot Newton polygon for each prime
    for prime in [2, 3, 5, 7]:
        vals = [(i, padic_val(c, prime)) for i, c in enumerate(coeffs) if c != 0]
        vals = [(x, y) for x, y in vals if y != float('inf')]
        
        if vals:
            hull = newton_polygon(coeffs, prime)
            xs, ys = zip(*hull) if hull else ([], [])
            ax.plot(xs, ys, 'o-', color=prime_colors[prime], linewidth=2,
                    markersize=6, label=f'p={prime}', alpha=0.8)
    
    # Plot all points (not just convex hull)
    for i, c in enumerate(coeffs):
        if c != 0:
            ax.plot(i, 0, 'k.', markersize=3, alpha=0.3)
    
    ax.set_xlabel('Degree')
    ax.set_ylabel('p-adic valuation')
    ax.set_title(name, fontsize=10)
    ax.grid(True, alpha=0.2)
    ax.set_ylim(-0.5, max(4, max(padic_val(c, 2) for c in coeffs if c != 0 and padic_val(c, 2) != float('inf')) + 1))
    
    if idx == 0:
        ax.legend(fontsize=7, loc='upper right')

plt.suptitle('Newton Polygons: Tropical Persistence Slopes\n'
             'The slopes encode p-adic information about Frobenius eigenvalues',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('newton_polygon.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved newton_polygon.png")
