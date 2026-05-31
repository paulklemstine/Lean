#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================

Demonstrates:
1. Einstein addition on (-1,1) and its group properties
2. Rapidity isomorphism: artanh converts ⊕ to +
3. SL₂(ℤ) trace classification (elliptic/parabolic/hyperbolic)
4. Hyperbolic prime counting and comparison with PNT
5. Cross-ratio computation for Poincaré disk distance
"""

import math
from typing import List, Tuple


def einstein_add(a: float, b: float) -> float:
    """Einstein addition (relativistic velocity addition)."""
    return (a + b) / (1 + a * b)


def rapidity(x: float) -> float:
    """Rapidity map: artanh(x) = log((1+x)/(1-x))/2."""
    if abs(x) >= 1:
        raise ValueError(f"|x| = {abs(x)} >= 1, not subluminal")
    return math.log((1 + x) / (1 - x)) / 2


def classify_trace(t: int) -> str:
    """Classify SL₂(ℤ) element by trace."""
    if abs(t) < 2:
        return "elliptic"
    elif abs(t) == 2:
        return "parabolic"
    else:
        return "hyperbolic"


def hyp_prime_count(n: int) -> int:
    """Count primes p with 2 < p <= n."""
    count = 0
    for k in range(3, n + 1):
        if all(k % d != 0 for d in range(2, int(math.sqrt(k)) + 1)):
            count += 1
    return count


def poincare_distance(z: complex, w: complex) -> float:
    """Poincaré disk distance between z and w."""
    num = abs(z - w)
    den = abs(1 - w.conjugate() * z)
    return math.atanh(num / den) * 2


# ============================================================
# Demo 1: Einstein Addition Group Properties
# ============================================================
print("=" * 60)
print("DEMO 1: Einstein Addition on (-1, 1)")
print("=" * 60)

test_pairs = [(0.3, 0.5), (0.8, 0.9), (-0.4, 0.7), (0.99, 0.99)]

for a, b in test_pairs:
    result = einstein_add(a, b)
    print(f"  {a:6.2f} ⊕ {b:6.2f} = {result:8.5f}  (|result| < 1: {abs(result) < 1})")

# Verify associativity
a, b, c = 0.3, 0.5, 0.7
lhs = einstein_add(einstein_add(a, b), c)
rhs = einstein_add(a, einstein_add(b, c))
print(f"\n  Associativity: (a⊕b)⊕c = {lhs:.10f}")
print(f"                 a⊕(b⊕c) = {rhs:.10f}")
print(f"                 Diff = {abs(lhs - rhs):.2e}")

# ============================================================
# Demo 2: Rapidity Isomorphism
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Rapidity Isomorphism (artanh converts ⊕ to +)")
print("=" * 60)

for a, b in [(0.3, 0.5), (0.7, 0.2), (-0.4, 0.6)]:
    r_sum = rapidity(einstein_add(a, b))
    r_a_plus_r_b = rapidity(a) + rapidity(b)
    print(f"  rapidity({a} ⊕ {b}) = {r_sum:.8f}")
    print(f"  rapidity({a}) + rapidity({b}) = {r_a_plus_r_b:.8f}")
    print(f"  Diff = {abs(r_sum - r_a_plus_r_b):.2e}")
    print()

# ============================================================
# Demo 3: SL₂(ℤ) Trace Classification
# ============================================================
print("=" * 60)
print("DEMO 3: SL₂(ℤ) Trace Classification")
print("=" * 60)

for t in range(-5, 6):
    cls = classify_trace(t)
    print(f"  tr = {t:3d}  →  {cls}")

# ============================================================
# Demo 4: Hyperbolic Prime Counting
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Hyperbolic Prime Counting π_H(n)")
print("=" * 60)

for n in [10, 25, 50, 100, 200, 500, 1000]:
    count = hyp_prime_count(n)
    ratio = count * math.log(n) / n if n > 1 else 0
    print(f"  π_H({n:5d}) = {count:4d}   "
          f"π_H(n)·ln(n)/n = {ratio:.4f}  (PNT predicts → 1)")

# ============================================================
# Demo 5: Poincaré Disk Distance
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Poincaré Disk Distance")
print("=" * 60)

test_points = [
    (0.1 + 0.2j, 0.3 + 0.1j),
    (0.5 + 0.3j, -0.2 + 0.4j),
    (0.0 + 0.0j, 0.5 + 0.0j),
    (0.9 + 0.0j, 0.95 + 0.0j),
]

for z, w in test_points:
    d = poincare_distance(z, w)
    cross_denom = abs(1 - w.conjugate() * z)
    print(f"  d({z}, {w}) = {d:.4f}  "
          f"|1 - w̄z| = {cross_denom:.4f}")

# ============================================================
# Demo 6: Falsifiable Conjecture Test
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Hyperbolic Prime Density Conjecture")
print("=" * 60)
print("  Conjecture: π_H(N)·log(N)/N² → 1/2 as N → ∞")
print()

for N in [100, 500, 1000, 5000, 10000]:
    count = hyp_prime_count(N)
    ratio = count * math.log(N) / (N ** 2) if N > 1 else 0
    print(f"  N = {N:6d}:  π_H(N) = {count:5d},  "
          f"π_H(N)·ln(N)/N² = {ratio:.6f}")

print("\n  Note: The ratio does NOT converge to 1/2.")
print("  This REFUTES the naive conjecture π_H(N) ~ N²/(2 log N).")
print("  The correct asymptotic (prime number theorem) is π(N) ~ N/log(N),")
print("  which gives π_H(N)·log(N)/N → 1, not π_H(N)·log(N)/N² → 1/2.")
print("  The hyperbolic prime geodesic theorem has different asymptotics")
print("  involving the length spectrum, not the trace norm directly.")


#!/usr/bin/env python3
"""
Visualization 1: Einstein Addition on the Poincaré Disk
========================================================

Shows how Einstein addition maps pairs of subluminal velocities
to subluminal results, with the rapidity isomorphism overlay.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def einstein_add(a: float, b: float) -> float:
    return (a + b) / (1 + a * b)


def rapidity(x: float) -> float:
    if abs(x) >= 1:
        return float('inf') * np.sign(x)
    return math.log((1 + x) / (1 - x)) / 2


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Einstein addition surface
ax1 = axes[0]
a_vals = np.linspace(-0.95, 0.95, 200)
b_vals = np.linspace(-0.95, 0.95, 200)
A, B = np.meshgrid(a_vals, b_vals)
C = (A + B) / (1 + A * B)
contour = ax1.contourf(A, B, C, levels=20, cmap='RdBu_r')
plt.colorbar(contour, ax=ax1, label='a ⊕ b')
ax1.set_xlabel('a')
ax1.set_ylabel('b')
ax1.set_title('Einstein Addition a ⊕ b')
ax1.set_aspect('equal')

# Plot 2: Rapidity isomorphism
ax2 = axes[1]
x = np.linspace(-0.99, 0.99, 500)
r = [rapidity(xi) for xi in x]
ax2.plot(x, r, 'b-', linewidth=2, label='rapidity(x)')
ax2.plot(x, x, 'r--', alpha=0.5, label='y = x')
ax2.axhline(y=0, color='gray', linewidth=0.5)
ax2.axvline(x=0, color='gray', linewidth=0.5)
ax2.set_xlabel('x ∈ (-1, 1)')
ax2.set_ylabel('rapidity(x)')
ax2.set_title('Rapidity Map: artanh')
ax2.legend()
ax2.set_xlim(-1, 1)
ax2.set_ylim(-4, 4)

# Plot 3: Closure demonstration
ax3 = axes[2]
np.random.seed(42)
n_pairs = 500
a_samples = np.random.uniform(-0.99, 0.99, n_pairs)
b_samples = np.random.uniform(-0.99, 0.99, n_pairs)
results = [(a + b) / (1 + a * b) for a, b in zip(a_samples, b_samples)]

ax3.scatter(a_samples, b_samples, c=results, cmap='RdBu_r',
            alpha=0.6, s=10, vmin=-1, vmax=1)
ax3.set_xlabel('a')
ax3.set_ylabel('b')
ax3.set_title(f'Closure: all {n_pairs} results in (-1,1)')
ax3.set_aspect('equal')
ax3.set_xlim(-1, 1)
ax3.set_ylim(-1, 1)

# Annotate max |result|
max_abs = max(abs(r) for r in results)
ax3.text(0.02, 0.98, f'max |a⊕b| = {max_abs:.4f} < 1',
         transform=ax3.transAxes, va='top', fontsize=9,
         bbox=dict(boxstyle='round', facecolor='wheat'))

plt.suptitle('Hyperbolic Arithmetic: Einstein Addition Group', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('einstein_addition.png', dpi=150, bbox_inches='tight')
print("Saved: einstein_addition.png")


#!/usr/bin/env python3
"""
Visualization 2: Poincaré Disk with SL₂(ℤ) Orbit
===================================================

Visualizes the modular group tessellation on the Poincaré disk,
with points colored by trace classification.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def moebius_action(a: int, b: int, c: int, d: int, z: complex) -> complex:
    return (a * z + b) / (c * z + d)


def cayley_transform(z: complex) -> complex:
    return (z - 1j) / (z + 1j)


def classify_trace(t: int) -> str:
    if abs(t) < 2:
        return "elliptic"
    elif abs(t) == 2:
        return "parabolic"
    else:
        return "hyperbolic"


# Generate SL₂(ℤ) orbit
basepoint = 0.1 + 1.5j  # point in upper half-plane
max_depth = 7

orbit_points = []
visited = set()
queue = [(1, 0, 0, 1, 0)]  # (a, b, c, d, depth)

# Generators: T, T⁻¹, S
gens = [(1, 1, 0, 1), (1, -1, 0, 1), (0, -1, 1, 0)]

while queue:
    a, b, c, d, depth = queue.pop(0)
    key = (a, b, c, d)
    if key in visited or depth > max_depth:
        continue
    visited.add(key)

    z = moebius_action(a, b, c, d, basepoint)
    w = cayley_transform(z)
    trace = a + d

    if abs(w) < 0.999:
        orbit_points.append((w.real, w.imag, trace, classify_trace(trace)))

    if depth < max_depth:
        for ga, gb, gc, gd in gens:
            na = a * ga + b * gc
            nb = a * gb + b * gd
            nc = c * ga + d * gc
            nd = c * gb + d * gd
            queue.append((na, nb, nc, nd, depth + 1))

fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw unit circle
theta = np.linspace(0, 2 * np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Color by classification
colors = {'elliptic': '#e74c3c', 'parabolic': '#f39c12', 'hyperbolic': '#2ecc71'}
labels_added = set()

for x, y, trace, cls in orbit_points:
    label = cls if cls not in labels_added else None
    ax.scatter(x, y, c=colors[cls], s=15, alpha=0.7, label=label, zorder=3)
    labels_added.add(cls)

# Count by type
type_counts = {}
for _, _, _, cls in orbit_points:
    type_counts[cls] = type_counts.get(cls, 0) + 1

ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-1.1, 1.1)
ax.set_aspect('equal')
ax.legend(loc='upper right', fontsize=12)
ax.set_title(f'SL₂(ℤ) Orbit on the Poincaré Disk\n'
             f'({len(orbit_points)} points: '
             f'{type_counts.get("elliptic", 0)} elliptic, '
             f'{type_counts.get("parabolic", 0)} parabolic, '
             f'{type_counts.get("hyperbolic", 0)} hyperbolic)',
             fontsize=13)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('poincare_orbit.png', dpi=150, bbox_inches='tight')
print("Saved: poincare_orbit.png")


#!/usr/bin/env python3
"""
Visualization 3: Hyperbolic Prime Counting
============================================

Compares the hyperbolic prime counting function π_H(n) with
the prime number theorem prediction n/log(n).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


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


def hyp_prime_count(n: int) -> int:
    """Count primes p with 2 < p <= n."""
    return sum(1 for k in range(3, n + 1) if is_prime(k))


# Compute data
ns = list(range(5, 2001))
counts = [hyp_prime_count(n) for n in ns]
pnt_approx = [n / math.log(n) for n in ns]
li_approx = []
for n in ns:
    # li(n) approximation via numerical integration
    val = sum(1.0 / math.log(max(k, 2)) for k in range(2, n + 1))
    li_approx.append(val)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: π_H(n) vs n/log(n)
ax1 = axes[0, 0]
ax1.plot(ns, counts, 'b-', linewidth=1.5, label='π_H(n)')
ax1.plot(ns, pnt_approx, 'r--', linewidth=1.5, label='n/ln(n)')
ax1.plot(ns, li_approx, 'g-.', linewidth=1.5, label='li(n)')
ax1.set_xlabel('n')
ax1.set_ylabel('Count')
ax1.set_title('Hyperbolic Prime Counting Function')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Ratio π_H(n) / (n/log(n))
ax2 = axes[0, 1]
ratios = [c / (n / math.log(n)) for c, n in zip(counts, ns)]
ax2.plot(ns, ratios, 'b-', linewidth=1)
ax2.axhline(y=1, color='r', linestyle='--', alpha=0.7, label='PNT limit')
ax2.set_xlabel('n')
ax2.set_ylabel('π_H(n) / (n/ln n)')
ax2.set_title('Convergence to PNT')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.8, 1.5)

# Plot 3: Density ratio π_H(n) · log(n) / n²  (testing the false conjecture)
ax3 = axes[1, 0]
density = [c * math.log(n) / (n ** 2) for c, n in zip(counts, ns)]
ax3.plot(ns, density, 'purple', linewidth=1)
ax3.set_xlabel('n')
ax3.set_ylabel('π_H(n)·ln(n)/n²')
ax3.set_title('False Conjecture Test: π_H(n)~n²/(2ln n)?')
ax3.axhline(y=0.5, color='r', linestyle='--', alpha=0.7, label='Predicted limit 1/2')
ax3.legend()
ax3.grid(True, alpha=0.3)
ax3.annotate('Ratio → 0, not 1/2\n⟹ Conjecture REFUTED',
             xy=(1000, density[995]), fontsize=10,
             xytext=(1200, 0.3),
             arrowprops=dict(arrowstyle='->', color='red'),
             color='red', fontweight='bold')

# Plot 4: Hyperbolic prime gaps
ax4 = axes[1, 1]
primes_h = [k for k in range(3, 501) if is_prime(k)]
gaps = [primes_h[i + 1] - primes_h[i] for i in range(len(primes_h) - 1)]
ax4.scatter(primes_h[:-1], gaps, s=5, alpha=0.6, c='teal')
ax4.set_xlabel('Prime p')
ax4.set_ylabel('Gap to next prime')
ax4.set_title('Hyperbolic Prime Gaps (p > 2)')
ax4.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Number Theory: Prime Counting Analysis', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('hyp_primes.png', dpi=150, bbox_inches='tight')
print("Saved: hyp_primes.png")
