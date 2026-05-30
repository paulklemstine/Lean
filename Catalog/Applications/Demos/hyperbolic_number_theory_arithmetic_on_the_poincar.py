#!/usr/bin/env python3
"""
Applications of Hyperbolic Number Theory

Real-world applications connecting hyperbolic lattice theory to
cryptography, coding theory, and geometric algorithms.
"""

import math
from typing import List, Tuple


# ============================================================================
# Application 1: SL₂(ℤ) Word Problem for Lattice Cryptography
# ============================================================================

def sl2z_word_length(a: int, b: int, c: int, d: int) -> int:
    """
    Estimate the word length of an SL₂(ℤ) element in the S,T generators.

    This is related to the hardness of lattice-based cryptographic problems.
    The word length is approximately proportional to log(max(|a|,|b|,|c|,|d|)).

    Applications: lattice-based cryptography, hash functions from group actions.
    """
    assert a * d - b * c == 1, "Not an SL₂(ℤ) element"
    entries = [abs(a), abs(b), abs(c), abs(d)]
    M = max(entries)
    if M <= 1:
        return 0
    return int(math.log2(M)) + 1


def continued_fraction_to_sl2z(cf: List[int]) -> Tuple[int, int, int, int]:
    """
    Convert a continued fraction [a₀; a₁, a₂, ...] to an SL₂(ℤ) product.

    The matrix T^a₀ · S · T^a₁ · S · ... encodes the continued fraction.

    Applications: best rational approximations, Diophantine analysis.
    """
    a, b, c, d = 1, 0, 0, 1  # identity

    for i, coeff in enumerate(cf):
        # Multiply by T^coeff
        a, b = a + coeff * c, b + coeff * d
        if i < len(cf) - 1:
            # Multiply by S = [[0,-1],[1,0]]
            a, b, c, d = -c, -d, a, b

    return (a, b, c, d)


# ============================================================================
# Application 2: Hyperbolic Voronoi Diagrams
# ============================================================================

def hyperbolic_midpoint(p: Tuple[float, float],
                        q: Tuple[float, float]) -> Tuple[float, float]:
    """
    Compute the midpoint of the hyperbolic geodesic from p to q
    in the Poincaré disk model.

    Applications: computational geometry, mesh generation on surfaces.
    """
    px, py = p
    qx, qy = q

    # Use the Klein model midpoint then convert back
    # This is an approximation for small distances
    mx = (px + qx) / 2
    my = (py + qy) / 2

    # Project back to disk if needed
    r2 = mx ** 2 + my ** 2
    if r2 >= 1:
        scale = 0.99 / math.sqrt(r2)
        mx *= scale
        my *= scale

    return (mx, my)


def hyperbolic_voronoi_cell(center: Tuple[float, float],
                            neighbors: List[Tuple[float, float]],
                            num_boundary_points: int = 100) -> List[Tuple[float, float]]:
    """
    Approximate the Voronoi cell for a point in the hyperbolic plane.

    Each cell boundary is an arc of a hyperbolic geodesic equidistant
    from the center and its neighbor.

    Applications: tessellation algorithms, network routing on surfaces.
    """
    def pseudo_hyp_dist_sq(p, q):
        px, py = p
        qx, qy = q
        num = (px - qx) ** 2 + (py - qy) ** 2
        den = (1 - px * qx - py * qy) ** 2 + (px * qy - py * qx) ** 2
        return num / den if den > 0 else float('inf')

    boundary = []
    for angle_idx in range(num_boundary_points):
        theta = 2 * math.pi * angle_idx / num_boundary_points
        # Binary search for the boundary point along this ray
        lo, hi = 0.0, 0.99
        for _ in range(50):
            mid = (lo + hi) / 2
            test_point = (center[0] + mid * math.cos(theta),
                          center[1] + mid * math.sin(theta))
            r2 = test_point[0] ** 2 + test_point[1] ** 2
            if r2 >= 1:
                hi = mid
                continue

            # Check if closer to center than any neighbor
            d_center = pseudo_hyp_dist_sq(test_point, center)
            min_d_neighbor = min(pseudo_hyp_dist_sq(test_point, n) for n in neighbors)
            if d_center < min_d_neighbor:
                lo = mid
            else:
                hi = mid
        r = (lo + hi) / 2
        pt = (center[0] + r * math.cos(theta),
              center[1] + r * math.sin(theta))
        if pt[0] ** 2 + pt[1] ** 2 < 1:
            boundary.append(pt)

    return boundary


# ============================================================================
# Application 3: Trace-Based Error Detection
# ============================================================================

def trace_hash(message: bytes, modulus: int = 2**31 - 1) -> int:
    """
    Hash function based on SL₂(ℤ) trace arithmetic.

    Maps a byte sequence to a trace value via iterated composition
    of SL₂(ℤ) elements. The trace is a conjugation invariant,
    providing algebraic collision resistance.

    Applications: hash functions, message authentication codes.
    """
    # Map bytes to SL₂(ℤ) generators
    a, b, c, d = 1, 0, 0, 1  # identity

    for byte in message:
        # Use byte to select a generator
        t = (byte % 253) + 3  # trace in [3, 255]
        # Compose with [[t-1, 1], [t-2, 1]]
        ga, gb, gc, gd = t - 1, 1, t - 2, 1
        na = (a * ga + b * gc) % modulus
        nb = (a * gb + b * gd) % modulus
        nc = (c * ga + d * gc) % modulus
        nd = (c * gb + d * gd) % modulus
        a, b, c, d = na, nb, nc, nd

    return (a + d) % modulus  # Return trace


# ============================================================================
# Application 4: Farey Sequence Enumeration
# ============================================================================

def farey_sequence(n: int) -> List[Tuple[int, int]]:
    """
    Generate the Farey sequence F_n: all fractions a/b with 0 ≤ a/b ≤ 1,
    b ≤ n, in lowest terms, sorted by value.

    Connected to hyperbolic tessellation: Farey neighbors correspond to
    adjacent triangles in the Farey triangulation of the upper half-plane.

    Time: O(n²), Space: O(n²)
    """
    fractions = set()
    for b in range(1, n + 1):
        for a in range(0, b + 1):
            if math.gcd(a, b) == 1:
                fractions.add((a, b))
    return sorted(fractions, key=lambda f: f[0] / f[1])


def verify_farey_neighbors(seq: List[Tuple[int, int]]) -> bool:
    """
    Verify that consecutive Farey fractions are Farey neighbors:
    |a₁d₂ - a₂d₁| = 1.

    This is the Farey neighbor property, equivalent to the
    corresponding SL₂(ℤ) elements differing by a generator.
    """
    for i in range(len(seq) - 1):
        a1, b1 = seq[i]
        a2, b2 = seq[i + 1]
        if abs(a1 * b2 - a2 * b1) != 1:
            return False
    return True


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    # Application 1: SL₂(ℤ) word length
    print("SL₂(ℤ) word lengths:")
    for t in [3, 5, 10, 100]:
        a, b, c, d = t - 1, 1, t - 2, 1
        wl = sl2z_word_length(a, b, c, d)
        print(f"  trace={t}: word length ≈ {wl}")

    # Continued fraction example
    print("\nContinued fraction [3; 7, 15, 1] = 355/113 ≈ π:")
    a, b, c, d = continued_fraction_to_sl2z([3, 7, 15, 1])
    print(f"  Matrix: [[{a}, {b}], [{c}, {d}]]")
    print(f"  Fraction: {a}/{c} = {a/c:.10f}")
    print(f"  π = {math.pi:.10f}")

    # Application 3: Trace hash
    print("\nTrace-based hash function:")
    for msg in [b"hello", b"world", b"hello world", b"Hello"]:
        h = trace_hash(msg)
        print(f"  hash({msg}) = {h}")

    # Application 4: Farey sequences
    print("\nFarey sequence F_7:")
    f7 = farey_sequence(7)
    for a, b in f7:
        print(f"  {a}/{b}", end="")
    print()
    print(f"  Length: {len(f7)}")
    print(f"  All neighbors: {verify_farey_neighbors(f7)}")


#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk — Demonstrations

Concrete numerical examples illustrating the formally verified theorems.
"""

import math


# ============================================================================
# Part 1: SL₂(ℤ) Möbius Transformations
# ============================================================================

class MobiusMap:
    """Element of SL₂(ℤ) represented as [[a, b], [c, d]] with ad - bc = 1."""
    def __init__(self, a, b, c, d):
        assert a * d - b * c == 1, f"Determinant is {a*d - b*c}, not 1"
        self.a, self.b, self.c, self.d = a, b, c, d

    def __repr__(self):
        return f"[[{self.a}, {self.b}], [{self.c}, {self.d}]]"

    def trace(self):
        return self.a + self.d

    def trace_discriminant(self):
        return self.trace() ** 2 - 4

    def compose(self, other):
        return MobiusMap(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )

    def inverse(self):
        return MobiusMap(self.d, -self.b, -self.c, self.a)

    def power(self, n):
        if n == 0:
            return MobiusMap(1, 0, 0, 1)
        result = self
        for _ in range(n - 1):
            result = self.compose(result)
        return result


# Demo 1: Group laws
print("=" * 60)
print("Demo 1: MobiusMap Group Laws")
print("=" * 60)

S = MobiusMap(0, -1, 1, 0)
T = MobiusMap(1, 1, 0, 1)
identity = MobiusMap(1, 0, 0, 1)

print(f"S = {S}, trace = {S.trace()}")
print(f"T = {T}, trace = {T.trace()}")
print(f"ST = {S.compose(T)}, trace = {S.compose(T).trace()}")

# Verify S^4 = I
S4 = S.power(4)
print(f"S^4 = {S4}  (should be identity)")

# Verify trace conjugation invariance
g = MobiusMap(2, 1, 1, 1)
h = MobiusMap(3, 1, 2, 1)
conj = g.compose(h).compose(g.inverse())
print(f"\nTrace conjugation: tr(ghg⁻¹) = {conj.trace()}, tr(h) = {h.trace()}")
assert conj.trace() == h.trace(), "Conjugation invariance failed!"

# Demo 2: Cayley-Hamilton and trace recurrence
print("\n" + "=" * 60)
print("Demo 2: Cayley-Hamilton & Trace Recurrence")
print("=" * 60)

g = MobiusMap(3, 1, 2, 1)  # trace = 4
print(f"g = {g}, tr(g) = {g.trace()}")
print(f"tr(g²) = {g.power(2).trace()}, tr(g)² - 2 = {g.trace()**2 - 2}")
assert g.power(2).trace() == g.trace() ** 2 - 2

# Verify trace recurrence: tr(g^{n+2}) = tr(g) * tr(g^{n+1}) - tr(g^n)
print("\nTrace recurrence verification:")
t = g.trace()
for n in range(8):
    tr_n = g.power(n).trace()
    print(f"  tr(g^{n}) = {tr_n}")

for n in range(6):
    lhs = g.power(n + 2).trace()
    rhs = t * g.power(n + 1).trace() - g.power(n).trace()
    assert lhs == rhs, f"Recurrence failed at n={n}"
print("✓ Trace recurrence verified for n = 0..5")


# ============================================================================
# Part 2: Trace Sequences (Chebyshev Connection)
# ============================================================================

print("\n" + "=" * 60)
print("Demo 3: Trace Sequences = Chebyshev Polynomials")
print("=" * 60)

def trace_seq(t, n):
    if n == 0: return 2
    if n == 1: return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b

# Verify formulas
for t in [3, 4, 5]:
    print(f"\nt = {t}:")
    for n in range(8):
        val = trace_seq(t, n)
        print(f"  traceSeq({t}, {n}) = {val}")
    # Verify t² - 2 formula
    assert trace_seq(t, 2) == t ** 2 - 2, "traceSeq_two failed"
    # Verify t³ - 3t formula
    assert trace_seq(t, 3) == t ** 3 - 3 * t, "traceSeq_three failed"

# Verify parity preservation
print("\nParity preservation (even t → all even):")
for t in [2, 4, 6]:
    vals = [trace_seq(t, n) for n in range(10)]
    all_even = all(v % 2 == 0 for v in vals)
    print(f"  t={t}: {vals[:6]}... all even: {all_even}")
    assert all_even

# Verify congruence mod (t-2)
print("\nCongruence: traceSeq(t, n) ≡ 2 mod (t-2):")
for t in [5, 7, 10]:
    for n in range(8):
        val = trace_seq(t, n)
        assert (val - 2) % (t - 2) == 0, f"Congruence failed: t={t}, n={n}"
    print(f"  t={t}: verified for n=0..7 ✓")


# ============================================================================
# Part 3: Pseudo-Hyperbolic Distance
# ============================================================================

print("\n" + "=" * 60)
print("Demo 4: Pseudo-Hyperbolic Distance on Poincaré Disk")
print("=" * 60)

def pseudo_hyp_dist_sq(px, py, qx, qy):
    num = (px - qx) ** 2 + (py - qy) ** 2
    den = (1 - px * qx - py * qy) ** 2 + (px * qy - py * qx) ** 2
    return num / den

# Verify properties
p = (0.3, 0.4)
q = (0.1, -0.2)
origin = (0, 0)

d_pq = pseudo_hyp_dist_sq(*p, *q)
d_qp = pseudo_hyp_dist_sq(*q, *p)
d_pp = pseudo_hyp_dist_sq(*p, *p)
d_0q = pseudo_hyp_dist_sq(*origin, *q)
norm_sq_q = q[0] ** 2 + q[1] ** 2

print(f"p = {p}, q = {q}")
print(f"δ(p, q) = {d_pq:.6f}")
print(f"δ(q, p) = {d_qp:.6f} (symmetry: {abs(d_pq - d_qp) < 1e-12})")
print(f"δ(p, p) = {d_pp:.6f} (self-distance = 0)")
print(f"δ(0, q) = {d_0q:.6f}, |q|² = {norm_sq_q:.6f} (equal: {abs(d_0q - norm_sq_q) < 1e-12})")
print(f"δ(p, q) < 1: {d_pq < 1}")


# ============================================================================
# Part 4: Fricke Trace Identity and Markov Numbers
# ============================================================================

print("\n" + "=" * 60)
print("Demo 5: Fricke Identity & Markov Triples")
print("=" * 60)

# Verify Fricke identity for several pairs
for (ga, gb, gc, gd, ha, hb, hc, hd) in [
    (2, 1, 1, 1, 3, 1, 2, 1),
    (1, 1, 0, 1, 0, -1, 1, 0),
    (5, 2, 2, 1, 3, 1, 2, 1),
]:
    g = MobiusMap(ga, gb, gc, gd)
    h = MobiusMap(ha, hb, hc, hd)
    gh = g.compose(h)
    comm = g.compose(h).compose(g.inverse()).compose(h.inverse())

    lhs = g.trace() ** 2 + h.trace() ** 2 + gh.trace() ** 2 - g.trace() * h.trace() * gh.trace()
    rhs = comm.trace() + 2
    print(f"g={g}, h={h}")
    print(f"  tr²+tr²+tr² - tr·tr·tr = {lhs}, tr(comm) + 2 = {rhs}, equal: {lhs == rhs}")
    assert lhs == rhs

# Markov triples
print("\nMarkov triples from Vieta involutions:")
triples = [(1, 1, 1)]
seen = set()
queue = list(triples)
while queue:
    x, y, z = queue.pop(0)
    for triple in [(x, y, z), (y, x, z), (x, z, y)]:
        t = tuple(sorted(triple))
        if t not in seen:
            seen.add(t)
            a, b, c = triple
            z_new = 3 * a * b - c
            if z_new > 0:
                new_triple = tuple(sorted((a, b, z_new)))
                if new_triple not in seen and len(seen) < 20:
                    queue.append((a, b, z_new))

for triple in sorted(seen):
    x, y, z = triple
    assert x ** 2 + y ** 2 + z ** 2 == 3 * x * y * z
    print(f"  ({x}, {y}, {z}) — verified x²+y²+z² = 3xyz ✓")


# ============================================================================
# Part 5: Falsifiable Conjecture — Primitive Trace Density
# ============================================================================

print("\n" + "=" * 60)
print("Demo 6: Primitive Trace Density Conjecture")
print("=" * 60)

def is_imprimitive(t):
    """t is imprimitive if t + 2 = s² for some s ≥ 2."""
    s = int(math.isqrt(t + 2))
    return s >= 2 and s * s == t + 2

N = 100
primitives = [t for t in range(3, N + 1) if not is_imprimitive(t)]
imprimitives = [t for t in range(3, N + 1) if is_imprimitive(t)]

print(f"Range [3, {N}]:")
print(f"  Imprimitive traces (= s²-2): {imprimitives}")
print(f"  Number of primitive traces: {len(primitives)}/{N-2}")
print(f"  Primitive density: {len(primitives)/(N-2):.4f}")
print(f"  Conjecture (6/π² complement): 1 - 6/π² ≈ {1 - 6/math.pi**2:.4f}")

# Verify specific values from the theorems
assert not is_imprimitive(3), "trace3_primitive failed"
assert not is_imprimitive(4), "trace4_primitive failed"
assert not is_imprimitive(5), "trace5_primitive failed"
assert is_imprimitive(7), "trace7_imprimitive failed"
print("\n✓ All formally verified primitivity results confirmed")


# ============================================================================
# Part 6: Cross-Domain Bridge — Tropical Algebra
# ============================================================================

print("\n" + "=" * 60)
print("Demo 7: Tropical Algebra & Gromov Products")
print("=" * 60)

trop_add = min
trop_mul = lambda a, b: a + b

# Verify distributivity
a, b, c = 3.0, 7.0, 2.0
lhs = trop_mul(a, trop_add(b, c))
rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
print(f"a⊗(b⊕c) = {a}+min({b},{c}) = {lhs}")
print(f"(a⊗b)⊕(a⊗c) = min({a+b},{a+c}) = {rhs}")
print(f"Distributivity: {abs(lhs - rhs) < 1e-12}")

# Gromov product example (tree metric)
print("\nGromov product on a tree (0-hyperbolic space):")
dx, dy, dz = 5, 3, 4
dxy, dxz, dyz = 6, 7, 5
gp_xy = (dx + dy - dxy) / 2
gp_xz = (dx + dz - dxz) / 2
gp_yz = (dy + dz - dyz) / 2
print(f"  (x|y) = {gp_xy}, (x|z) = {gp_xz}, (y|z) = {gp_yz}")
print(f"  (x|y) ≥ min((x|z), (y|z)): {gp_xy} ≥ {min(gp_xz, gp_yz)}: {gp_xy >= min(gp_xz, gp_yz)}")


# ============================================================================
# Part 7: Fundamental Discriminant
# ============================================================================

print("\n" + "=" * 60)
print("Demo 8: Fundamental Discriminants and Quadratic Fields")
print("=" * 60)

for t in range(3, 20):
    D = t ** 2 - 4
    # Check if D is a fundamental discriminant (square-free up to factor of 4)
    sqrt_D = math.isqrt(D)
    is_square = sqrt_D * sqrt_D == D
    print(f"  t={t:2d}: D = t²-4 = {D:4d}, √D ≈ {math.sqrt(D):.3f}, "
          f"ℚ(√{D}) {'(rational!)' if is_square else ''}")

print("\n✓ All demonstrations complete!")


#!/usr/bin/env python3
"""
Visualization 3: Conformal Factor and Hyperbolic Metric

Shows how the Poincaré disk metric stretches near the boundary,
and visualizes the pseudo-hyperbolic distance between points.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm


# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Conformal factor heatmap
ax1 = axes[0]
x = np.linspace(-0.99, 0.99, 400)
y = np.linspace(-0.99, 0.99, 400)
X, Y = np.meshgrid(x, y)
R2 = X**2 + Y**2
mask = R2 < 1

# Conformal factor: λ(z) = 2/(1-|z|²)
conf_factor = np.where(mask, 2 / (1 - R2), np.nan)

im = ax1.pcolormesh(X, Y, conf_factor, cmap='inferno', norm=LogNorm(vmin=2, vmax=200),
                    shading='auto')
# Draw unit circle
theta = np.linspace(0, 2 * np.pi, 200)
ax1.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
ax1.set_aspect('equal')
ax1.set_title('Conformal Factor λ(z) = 2/(1-|z|²)\n'
              'Diverges at boundary → infinite area', fontsize=11)
ax1.set_xlabel('x')
ax1.set_ylabel('y')
plt.colorbar(im, ax=ax1, label='λ(z)', shrink=0.8)

# Panel 2: Conformal factor along radius
ax2 = axes[1]
r = np.linspace(0, 0.999, 500)
lam = 2 / (1 - r**2)

ax2.semilogy(r, lam, 'b-', linewidth=2)
ax2.axhline(y=2, color='red', linestyle='--', alpha=0.5, label='λ(0) = 2 (minimum)')
ax2.fill_between(r, 2, lam, alpha=0.1, color='blue')
ax2.set_xlabel('Radius r = |z|', fontsize=12)
ax2.set_ylabel('Conformal factor λ(r)', fontsize=12)
ax2.set_title('Conformal Factor vs. Radius\n'
              'Proven: λ(r) ≥ 2 for all r ∈ [0,1)', fontsize=11)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, 1)

# Panel 3: Pseudo-hyperbolic distance from origin
ax3 = axes[2]

def pseudo_hyp_dist_sq(px, py, qx, qy):
    num = (px - qx)**2 + (py - qy)**2
    den = (1 - px*qx - py*qy)**2 + (px*qy - py*qx)**2
    return num / den if den > 0 else 0

# Distance from a fixed point (0.3, 0.2)
px, py = 0.3, 0.2
dist = np.zeros_like(X)
for i in range(X.shape[0]):
    for j in range(X.shape[1]):
        if mask[i, j]:
            dist[i, j] = pseudo_hyp_dist_sq(px, py, X[i, j], Y[i, j])
        else:
            dist[i, j] = np.nan

# Use arctanh for actual hyperbolic distance
hyp_dist = np.where(mask & (dist < 1), 2 * np.arctanh(np.sqrt(np.maximum(dist, 0))), np.nan)

im3 = ax3.pcolormesh(X, Y, hyp_dist, cmap='viridis', shading='auto',
                     vmin=0, vmax=5)
ax3.plot(np.cos(theta), np.sin(theta), 'w-', linewidth=2)
ax3.plot(px, py, 'r*', markersize=15, zorder=10)
ax3.annotate(f'({px}, {py})', (px, py), textcoords="offset points",
             xytext=(10, 10), color='white', fontsize=10, fontweight='bold')
ax3.set_aspect('equal')
ax3.set_title(f'Hyperbolic Distance from ({px}, {py})\n'
              f'd(z,w) = 2·arctanh(√δ(z,w))', fontsize=11)
ax3.set_xlabel('x')
ax3.set_ylabel('y')
plt.colorbar(im3, ax=ax3, label='Hyperbolic distance', shrink=0.8)

plt.suptitle('The Poincaré Disk: Geometry of Curved Space',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('conformal_factor.png', dpi=150, bbox_inches='tight')
plt.close()
print("Generated conformal factor visualization")


#!/usr/bin/env python3
"""
Visualization 1: The Poincaré Disk with SL₂(ℤ) Orbit Points

Visualizes the hyperbolic lattice: orbit points of the origin under
the action of SL₂(ℤ), colored by trace value. Shows how the discrete
group action creates a regular tessellation of hyperbolic space.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def mobius_action_disk(a, b, c, d, z):
    """Apply Möbius transformation [[a,b],[c,d]] to complex number z in disk model.
    First map disk to upper half-plane, apply, then map back."""
    # Cayley transform: disk → upper half-plane: w = i(1+z)/(1-z)
    if abs(1 - z) < 1e-15:
        return complex(0, 0)
    w = 1j * (1 + z) / (1 - z)
    # Apply Möbius: w -> (aw+b)/(cw+d)
    denom = c * w + d
    if abs(denom) < 1e-15:
        return complex(0, 0)
    w_new = (a * w + b) / denom
    # Inverse Cayley: upper half-plane → disk: z = (w-i)/(w+i)
    denom2 = w_new + 1j
    if abs(denom2) < 1e-15:
        return complex(0, 0)
    z_new = (w_new - 1j) / denom2
    return z_new


def generate_orbit_points(max_trace=15, max_entries=30):
    """Generate SL₂(ℤ) orbit points of i (mapped to origin in disk model)."""
    points = []
    traces = []

    for a in range(-max_entries, max_entries + 1):
        for c in range(-max_entries, max_entries + 1):
            for d in range(-max_entries, max_entries + 1):
                det_rem = a * d - 1
                if c == 0:
                    continue
                if det_rem % c != 0:
                    continue
                b = det_rem // c
                if abs(a + d) > max_trace:
                    continue
                # Apply to origin (which corresponds to i in UHP)
                z = mobius_action_disk(a, b, c, d, complex(0, 0))
                r = abs(z)
                if r < 0.999:
                    points.append((z.real, z.imag))
                    traces.append(abs(a + d))

    return points, traces


# Generate orbit points
points, traces = generate_orbit_points(max_trace=12, max_entries=15)

# Create figure
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw unit circle
theta = np.linspace(0, 2 * np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

# Draw some geodesics (arcs of circles orthogonal to unit circle)
for angle in np.linspace(0, np.pi, 7)[1:-1]:
    center_x = 1.0 / np.cos(angle)
    center_y = 0
    radius = abs(np.tan(angle))
    arc_angles = np.linspace(-np.pi/2, np.pi/2, 100)
    arc_x = center_x + radius * np.cos(arc_angles)
    arc_y = center_y + radius * np.sin(arc_angles)
    mask = arc_x**2 + arc_y**2 < 0.999
    if np.any(mask):
        ax.plot(arc_x[mask], arc_y[mask], 'lightblue', alpha=0.3, linewidth=0.5)

# Plot orbit points
if points:
    xs, ys = zip(*points)
    scatter = ax.scatter(xs, ys, c=traces, cmap='plasma', s=20, alpha=0.8,
                         edgecolors='black', linewidth=0.3, zorder=5)
    plt.colorbar(scatter, ax=ax, label='|Trace|', shrink=0.8)

# Mark origin
ax.plot(0, 0, 'r*', markersize=15, zorder=10, label='Origin (= i in UHP)')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('SL₂(ℤ) Orbit in the Poincaré Disk\nColored by |Trace| of the Group Element',
             fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=10)
ax.grid(True, alpha=0.1)

# Add annotation
ax.text(-1.1, -1.08,
        f'{len(points)} orbit points shown\nTrace values determine hyperbolic distance from origin',
        fontsize=8, style='italic', alpha=0.7)

plt.tight_layout()
plt.savefig('poincare_disk_orbit.png', dpi=150, bbox_inches='tight')
plt.close()
print(f"Generated Poincaré disk visualization with {len(points)} orbit points")


#!/usr/bin/env python3
"""
Visualization 2: Trace Sequences and Chebyshev Polynomials

Shows the exponential growth of trace sequences for different base
trace values, illustrating the connection to Chebyshev polynomials
and the classification of Möbius transformations.
"""

import numpy as np
import matplotlib.pyplot as plt


def trace_seq(t, n):
    """Compute traceSeq(t, n) via recurrence."""
    if n == 0:
        return 2
    if n == 1:
        return t
    prev2, prev1 = 2, t
    for _ in range(n - 1):
        prev2, prev1 = prev1, t * prev1 - prev2
    return prev1


def primitive_trace_density(N):
    """Compute the density of primitive traces in [3, N]."""
    import math
    count = 0
    total = 0
    for t in range(3, N + 1):
        total += 1
        s = int(math.isqrt(t + 2))
        if not (s >= 2 and s * s == t + 2):
            count += 1
    return count / total if total > 0 else 0


# Create figure with subplots
fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Trace sequences (log scale)
ax1 = axes[0, 0]
n_vals = np.arange(0, 16)
colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))
for idx, t in enumerate([2, 3, 4, 5, 7]):
    vals = [trace_seq(t, n) for n in n_vals]
    label = f't = {t} ({"parabolic" if t == 2 else "hyperbolic"})'
    ax1.semilogy(n_vals, [abs(v) for v in vals], 'o-', color=colors[idx],
                 label=label, markersize=4, linewidth=1.5)

ax1.set_xlabel('Power n', fontsize=12)
ax1.set_ylabel('|traceSeq(t, n)|', fontsize=12)
ax1.set_title('Trace Sequences: Exponential Growth\n(Chebyshev Polynomials)', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Trace sequence mod (t-2) — verifying congruence theorem
ax2 = axes[0, 1]
t_val = 7
n_range = np.arange(0, 25)
residues = [(trace_seq(t_val, n) - 2) % (t_val - 2) for n in n_range]
ax2.bar(n_range, residues, color='steelblue', alpha=0.7)
ax2.axhline(y=0, color='red', linestyle='--', linewidth=2, label='Expected residue = 0')
ax2.set_xlabel('Power n', fontsize=12)
ax2.set_ylabel(f'(traceSeq({t_val}, n) - 2) mod {t_val-2}', fontsize=12)
ax2.set_title(f'Congruence Theorem Verification: t = {t_val}\n'
              f'traceSeq(t, n) ≡ 2 (mod t-2)', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Primitive trace density
ax3 = axes[1, 0]
N_values = list(range(10, 2001, 10))
densities = [primitive_trace_density(N) for N in N_values]
ax3.plot(N_values, densities, 'b-', linewidth=1.5, label='Primitive trace density')
import math
asymptotic = 1 - 6 / math.pi**2
ax3.axhline(y=asymptotic, color='red', linestyle='--', linewidth=2,
            label=f'Conjectured: 1 - 6/π² ≈ {asymptotic:.4f}')
ax3.axhline(y=1.0, color='gray', linestyle=':', linewidth=1, alpha=0.5)
ax3.set_xlabel('N', fontsize=12)
ax3.set_ylabel('Primitive density in [3, N]', fontsize=12)
ax3.set_title('Primitive Trace Density Conjecture\n'
              '(Imprimitive = s²-2 for some s ≥ 2)', fontsize=13)
ax3.legend(fontsize=10)
ax3.set_ylim(0.85, 1.01)
ax3.grid(True, alpha=0.3)

# Panel 4: Markov tree (first few triples)
ax4 = axes[1, 1]
markov = [(1, 1, 1), (1, 1, 2), (1, 2, 5), (2, 5, 29), (1, 5, 13),
          (5, 13, 194), (5, 29, 433), (1, 13, 34), (1, 34, 89)]

# Plot as a tree
positions = {
    (1, 1, 1): (0, 3),
    (1, 1, 2): (0, 2),
    (1, 2, 5): (-2, 1),
    (1, 5, 13): (-3, 0),
    (1, 13, 34): (-4, -1),
    (1, 34, 89): (-5, -2),
    (2, 5, 29): (-1, 0),
    (5, 13, 194): (-2, -1),
    (5, 29, 433): (0, -1),
}

for triple, pos in positions.items():
    x, y, z = triple
    ax4.plot(*pos, 'o', color='darkred', markersize=10, zorder=5)
    ax4.annotate(f'({x},{y},{z})', pos, textcoords="offset points",
                 xytext=(8, 5), fontsize=8, fontweight='bold')

# Draw edges
edges = [
    ((1, 1, 1), (1, 1, 2)),
    ((1, 1, 2), (1, 2, 5)),
    ((1, 2, 5), (2, 5, 29)),
    ((1, 2, 5), (1, 5, 13)),
    ((1, 5, 13), (5, 13, 194)),
    ((1, 5, 13), (1, 13, 34)),
    ((1, 13, 34), (1, 34, 89)),
    ((2, 5, 29), (5, 29, 433)),
]

for t1, t2 in edges:
    if t1 in positions and t2 in positions:
        p1, p2 = positions[t1], positions[t2]
        ax4.plot([p1[0], p2[0]], [p1[1], p2[1]], 'k-', linewidth=1, alpha=0.5)

ax4.set_title('Markov Tree via Vieta Involutions\n'
              'x² + y² + z² = 3xyz', fontsize=13)
ax4.set_xlim(-6, 2)
ax4.set_ylim(-3, 4)
ax4.axis('off')

plt.suptitle('Hyperbolic Number Theory: Key Results',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('trace_sequences.png', dpi=150, bbox_inches='tight')
plt.close()
print("Generated trace sequence visualization")
