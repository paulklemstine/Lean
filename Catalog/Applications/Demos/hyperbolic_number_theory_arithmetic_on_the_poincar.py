"""
Hyperbolic Number Theory: Applications
=======================================
Real-world applications of hyperbolic lattice theory:
1. Network topology analysis (hyperbolic graphs)
2. Cryptographic key generation via SL₂(ℤ)
3. Signal processing on non-Euclidean manifolds
"""

import math
from typing import List, Tuple, Dict

# ============================================================
# Application 1: Hyperbolic Network Embedding
# ============================================================

def hyperbolic_embedding_distance(node_coords: Dict[str, Tuple[float, float]],
                                   src: str, dst: str) -> float:
    """
    Compute hyperbolic distance between network nodes embedded in the disk.
    
    Many real-world networks (internet, social, biological) have hyperbolic
    geometry — tree-like structure with exponential growth. Hyperbolic
    embeddings allow O(1) routing using only local geometric information.
    
    This uses the distance function proved non-negative and symmetric in Lean.
    """
    p, q = node_coords[src], node_coords[dst]
    dx, dy = p[0] - q[0], p[1] - q[1]
    delta_sq = dx**2 + dy**2
    p_sq = p[0]**2 + p[1]**2
    q_sq = q[0]**2 + q[1]**2
    denom = (1 - p_sq) * (1 - q_sq)
    if denom <= 0:
        return float('inf')
    return math.log(1 + 2 * delta_sq / denom)


def demo_network_routing():
    """Demonstrate hyperbolic routing in a tree-like network."""
    print("=" * 60)
    print("Application 1: Hyperbolic Network Routing")
    print("=" * 60)
    
    # Embed a small network in the Poincaré disk
    # Root at center, children spread radially
    nodes = {
        "root": (0.0, 0.0),
        "A": (0.3, 0.0),
        "B": (-0.3, 0.0),
        "C": (0.0, 0.3),
        "A1": (0.5, 0.1),
        "A2": (0.5, -0.1),
        "B1": (-0.5, 0.1),
        "C1": (0.1, 0.5),
    }
    
    print("\nNode positions in Poincaré disk:")
    for name, pos in nodes.items():
        print(f"  {name:>5}: ({pos[0]:+.2f}, {pos[1]:+.2f})")
    
    print("\nHyperbolic distances:")
    pairs = [("root", "A"), ("root", "B"), ("A", "A1"), ("A", "B"),
             ("A1", "B1"), ("A1", "C1")]
    for src, dst in pairs:
        d = hyperbolic_embedding_distance(nodes, src, dst)
        print(f"  d({src}, {dst}) = {d:.4f}")
    
    print("\nKey insight: distances to root grow slowly (logarithmically)")
    print("while lateral distances grow exponentially — perfect for trees!")


# ============================================================
# Application 2: SL₂(ℤ) Key Generation
# ============================================================

def sl2z_key_gen(seed_a: int, seed_b: int, word_length: int = 10) -> Tuple:
    """
    Generate cryptographic keys using random walks in SL₂(ℤ).
    
    The security relies on the word problem in SL₂(ℤ) being
    computationally hard for long words. The trace of the resulting
    matrix provides a one-way function.
    
    Uses properties proved in Lean:
    - det_eq: determinant is always 1
    - pow_add: group structure
    - trace discriminant classification
    """
    # Generators of SL₂(ℤ)
    # S = [[0,-1],[1,0]], T = [[1,1],[0,1]]
    
    # Start with identity
    a, b, c, d = 1, 0, 0, 1
    
    # Random walk using seed
    import hashlib
    state = hashlib.sha256(f"{seed_a}:{seed_b}".encode()).digest()
    
    for i in range(word_length):
        byte = state[i % len(state)]
        if byte % 3 == 0:  # Apply S
            a, b, c, d = -c, -d, a, b
        elif byte % 3 == 1:  # Apply T
            a, b, c, d = a + c, b + d, c, d
        else:  # Apply T⁻¹
            a, b, c, d = a - c, b - d, c, d
    
    return (a, b, c, d)


def demo_key_generation():
    """Demonstrate SL₂(ℤ) key generation."""
    print("\n" + "=" * 60)
    print("Application 2: SL₂(ℤ) Cryptographic Key Generation")
    print("=" * 60)
    
    for seed in [(42, 17), (100, 200), (7, 13)]:
        key = sl2z_key_gen(*seed, word_length=20)
        a, b, c, d = key
        det = a * d - b * c
        trace = a + d
        print(f"\n  Seed: {seed}")
        print(f"  Key matrix: [[{a}, {b}], [{c}, {d}]]")
        print(f"  Determinant: {det} (should be 1)")
        print(f"  Trace: {trace}")
        print(f"  Type: {'hyperbolic' if trace**2 > 4 else 'elliptic/parabolic'}")
        print(f"  Public key (trace): {trace}")


# ============================================================
# Application 3: Farey Mediant for Rational Approximation
# ============================================================

def farey_mediant(a: int, b: int, c: int, d: int) -> Tuple[int, int]:
    """
    Farey mediant of a/b and c/d is (a+c)/(b+d).
    
    Connected to SL₂(ℤ) via the matrix [[a,c],[b,d]]:
    if ad - bc = ±1, then a/b and c/d are adjacent Farey fractions.
    
    The totient sum theorem proved in Lean (totientSumH_ge)
    bounds the number of Farey fractions.
    """
    return (a + c, b + d)


def stern_brocot_tree(depth: int) -> List[Tuple[int, int]]:
    """
    Generate the Stern-Brocot tree to given depth.
    Each node is a fraction; the tree bijectively enumerates
    all positive rationals.
    
    Connected to hyperbolic lattice theory: the tree structure
    corresponds to the tessellation of ℍ by PSL(2,ℤ).
    """
    fractions = [(0, 1), (1, 1)]
    for _ in range(depth):
        new_fracs = [fractions[0]]
        for i in range(len(fractions) - 1):
            new_fracs.append(fractions[i])
            med = farey_mediant(fractions[i][0], fractions[i][1],
                              fractions[i+1][0], fractions[i+1][1])
            new_fracs.append(med)
        new_fracs.append(fractions[-1])
        fractions = new_fracs
    return fractions


def demo_farey_approximation():
    """Demonstrate rational approximation via Farey/Stern-Brocot."""
    print("\n" + "=" * 60)
    print("Application 3: Farey Mediant Rational Approximation")
    print("=" * 60)
    
    # Approximate π using Farey mediants
    target = math.pi
    a, b = 3, 1    # 3/1 = 3
    c, d = 4, 1    # 4/1 = 4
    
    print(f"\n  Approximating π = {target:.10f}")
    print(f"\n  {'Step':>5} | {'Fraction':>10} | {'Value':>12} | {'Error':>12}")
    print("  " + "-" * 50)
    
    for step in range(20):
        med_num, med_den = farey_mediant(a, b, c, d)
        med_val = med_num / med_den
        error = abs(med_val - target)
        
        if step < 15 or error < 1e-6:
            print(f"  {step:5d} | {med_num:>5}/{med_den:<4} | {med_val:12.8f} | {error:12.2e}")
        
        if med_val < target:
            a, b = med_num, med_den
        else:
            c, d = med_num, med_den
    
    print(f"\n  Best rational approximation: {a}/{b} ≤ π ≤ {c}/{d}")


# ============================================================
# Application 4: Modular Form Weight Estimation
# ============================================================

def demo_congruence_subgroup_index():
    """
    Compute indices of congruence subgroups Γ(p) in PSL(2,ℤ).
    
    The index [PSL(2,ℤ) : Γ(p)] = p(p²-1)/2 for prime p,
    which we proved divisible by 6 in Lean (index_divisible_by_six).
    This counts the number of copies of the fundamental domain
    needed to tile the modular curve X(p).
    """
    print("\n" + "=" * 60)
    print("Application 4: Congruence Subgroup Indices")
    print("=" * 60)
    
    def is_prime(n):
        if n < 2: return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0: return False
        return True
    
    print(f"\n  {'p':>4} | {'p(p²-1)':>10} | {'÷6':>8} | {'Genus':>6} | {'Cusps':>6}")
    print("  " + "-" * 45)
    
    for p in range(2, 20):
        if not is_prime(p):
            continue
        index = p * (p**2 - 1)
        # Genus of X(p) for prime p: g = 1 + (p-6)·index/(24p)
        # Number of cusps: (p²-1)/2 for Γ₀(p)
        genus = max(0, 1 + index * (p - 6) // (24 * p)) if p > 3 else 0
        cusps = 2  # For Γ₀(p), there are always 2 cusps
        print(f"  {p:4d} | {index:10d} | {index//6:8d} | {genus:6d} | {cusps:6d}")


if __name__ == "__main__":
    demo_network_routing()
    demo_key_generation()
    demo_farey_approximation()
    demo_congruence_subgroup_index()


"""
Hyperbolic Number Theory: Demonstrations
=========================================
Concrete numerical examples illustrating the theorems proved in Lean 4.
"""

import numpy as np
from typing import Tuple, List

# ============================================================
# 1. Poincaré Disk Points
# ============================================================

def is_in_disk(x: float, y: float) -> bool:
    """Check if (x,y) is in the Poincaré disk."""
    return x**2 + y**2 < 1.0

def norm_sq(x: float, y: float) -> float:
    """Squared Euclidean norm."""
    return x**2 + y**2

def hyp_dist(p: Tuple[float,float], q: Tuple[float,float]) -> float:
    """Hyperbolic distance (log-form) between two disk points."""
    dx, dy = p[0]-q[0], p[1]-q[1]
    delta_sq = dx**2 + dy**2
    denom = (1 - norm_sq(*p)) * (1 - norm_sq(*q))
    return np.log(1 + 2 * delta_sq / denom)

# ============================================================
# 2. SL₂(ℝ) Matrices
# ============================================================

class SL2R:
    """2x2 real matrix with determinant 1."""
    def __init__(self, a: float, b: float, c: float, d: float):
        self.a, self.b, self.c, self.d = a, b, c, d
        det = a*d - b*c
        assert abs(det - 1.0) < 1e-10, f"Determinant = {det}, expected 1"

    def __matmul__(self, other: 'SL2R') -> 'SL2R':
        return SL2R(
            self.a*other.a + self.b*other.c,
            self.a*other.b + self.b*other.d,
            self.c*other.a + self.d*other.c,
            self.c*other.b + self.d*other.d
        )

    @property
    def trace(self) -> float:
        return self.a + self.d

    @property
    def inv(self) -> 'SL2R':
        return SL2R(self.d, -self.b, -self.c, self.a)

    def power(self, n: int) -> 'SL2R':
        if n == 0:
            return SL2R(1, 0, 0, 1)
        result = self
        for _ in range(n - 1):
            result = result @ self
        return result

    def __repr__(self):
        return f"SL2R({self.a:.4f}, {self.b:.4f}, {self.c:.4f}, {self.d:.4f})"

# ============================================================
# 3. Demonstrations
# ============================================================

def demo_trace_chebyshev():
    """Demonstrate tr(g²) = tr(g)² - 2 (Chebyshev identity)."""
    print("=" * 60)
    print("Demo 1: Trace Chebyshev Identity  tr(g²) = tr(g)² - 2")
    print("=" * 60)

    # Hyperbolic element with trace > 2
    g = SL2R(2, 1, 1, 1)  # det = 2-1 = 1 ✓
    print(f"g = {g}")
    print(f"tr(g) = {g.trace}")

    g2 = g @ g
    print(f"tr(g²) = {g2.trace}")
    print(f"tr(g)² - 2 = {g.trace**2 - 2}")
    print(f"Match: {abs(g2.trace - (g.trace**2 - 2)) < 1e-10}")

    # Verify for several powers
    print("\nTrace growth for powers of g:")
    for n in range(1, 8):
        gn = g.power(n)
        print(f"  tr(g^{n}) = {gn.trace:.6f}")

def demo_trace_discriminant():
    """Demonstrate trace discriminant classification."""
    print("\n" + "=" * 60)
    print("Demo 2: Trace Discriminant Classification")
    print("=" * 60)

    examples = [
        (SL2R(0, -1, 1, 0), "Rotation (elliptic)"),     # tr = 0
        (SL2R(1, 1, 0, 1), "Translation (parabolic)"),   # tr = 2
        (SL2R(2, 1, 1, 1), "Dilation (hyperbolic)"),     # tr = 3
    ]

    for g, name in examples:
        disc = g.trace**2 - 4
        typ = "elliptic" if disc < 0 else ("parabolic" if abs(disc) < 1e-10 else "hyperbolic")
        print(f"  {name}: tr = {g.trace}, disc = {disc:.4f} → {typ}")

def demo_hyperbolic_distance():
    """Demonstrate hyperbolic distance properties."""
    print("\n" + "=" * 60)
    print("Demo 3: Hyperbolic Distance Properties")
    print("=" * 60)

    p = (0.0, 0.0)
    q = (0.3, 0.4)
    r = (0.5, 0.0)

    print(f"  d(p, p) = {hyp_dist(p, p):.6f}  (should be 0)")
    print(f"  d(p, q) = {hyp_dist(p, q):.6f}")
    print(f"  d(q, p) = {hyp_dist(q, p):.6f}  (symmetry)")
    print(f"  d(p, r) = {hyp_dist(p, r):.6f}")
    print(f"  d(p, q) + d(q, r) = {hyp_dist(p, q) + hyp_dist(q, r):.6f}  ≥ d(p, r) = {hyp_dist(p, r):.6f}")

def demo_totient_growth():
    """Demonstrate totient sum growth bound."""
    print("\n" + "=" * 60)
    print("Demo 4: Totient Sum Growth (Farey Connection)")
    print("=" * 60)

    def euler_totient(n):
        if n <= 1:
            return n
        result = n
        p = 2
        temp = n
        while p * p <= temp:
            if temp % p == 0:
                while temp % p == 0:
                    temp //= p
                result -= result // p
            p += 1
        if temp > 1:
            result -= result // temp
        return result

    cumsum = 0
    print(f"  {'n':>4} | {'φ(n)':>6} | {'Σφ(k)':>8} | {'n':>6} | {'Σφ ≥ n':>8}")
    print("  " + "-" * 45)
    for n in range(1, 21):
        cumsum += euler_totient(n)
        print(f"  {n:4d} | {euler_totient(n):6d} | {cumsum:8d} | {n:6d} | {'✓' if cumsum >= n else '✗':>8}")

def demo_index_divisibility():
    """Demonstrate p(p²-1) divisible by 6."""
    print("\n" + "=" * 60)
    print("Demo 5: p(p²-1) ≡ 0 (mod 6) — Congruence Subgroup Index")
    print("=" * 60)

    print(f"  {'p':>4} | {'p(p²-1)':>10} | {'÷6':>10} | {'Valid':>6}")
    print("  " + "-" * 40)
    for p in range(2, 16):
        val = p * (p**2 - 1)
        print(f"  {p:4d} | {val:10d} | {val//6:10d} | {'✓' if val % 6 == 0 else '✗':>6}")

def demo_orbit_growth():
    """Test the hyperbolic growth conjecture."""
    print("\n" + "=" * 60)
    print("Demo 6: Hyperbolic Growth Conjecture Test")
    print("=" * 60)

    # Generate orbit of (0,0) under PSL(2,Z) via Möbius transformations
    # on the upper half-plane, then map to disk
    S = SL2R(0, -1, 1, 0)   # z ↦ -1/z
    T = SL2R(1, 1, 0, 1)    # z ↦ z + 1

    # Generate words of length ≤ 4 in S, T, T⁻¹
    generators = [S, T, T.inv]
    orbit_matrices = {(1,0,0,1): SL2R(1,0,0,1)}

    def key(g):
        return (round(g.a, 8), round(g.b, 8), round(g.c, 8), round(g.d, 8))

    current = [SL2R(1,0,0,1)]
    for depth in range(6):
        next_gen = []
        for g in current:
            for gen in generators:
                h = g @ gen
                k = key(h)
                if k not in orbit_matrices:
                    orbit_matrices[k] = h
                    next_gen.append(h)
        current = next_gen
        print(f"  Depth {depth+1}: {len(orbit_matrices)} distinct matrices")

    # Map to disk: z = i maps to origin, use Cayley transform
    # w = (z - i)/(z + i) maps ℍ → 𝔻
    # g·i = (ai + b)/(ci + d) for g = [[a,b],[c,d]]
    disk_points = []
    for g in orbit_matrices.values():
        # g(i) = (a*i + b)/(c*i + d) = (b + ai)/(d + ci)
        # = (b + ai)(d - ci) / (d² + c²)
        denom = g.d**2 + g.c**2
        if denom < 1e-15:
            continue
        re_z = (g.b * g.d + g.a * g.c) / denom
        im_z = (g.a * g.d - g.b * g.c) / denom  # = 1/denom
        # Cayley: w = (z - i)/(z + i)
        # w = (re_z + (im_z - 1)i) / (re_z + (im_z + 1)i)
        num_re = re_z
        num_im = im_z - 1
        den_re = re_z
        den_im = im_z + 1
        den_sq = den_re**2 + den_im**2
        w_re = (num_re * den_re + num_im * den_im) / den_sq
        w_im = (num_im * den_re - num_re * den_im) / den_sq
        r = w_re**2 + w_im**2
        if r < 1 - 1e-10:
            disk_points.append((w_re, w_im, r))

    print(f"\n  Total disk points: {len(disk_points)}")

    # Count points within various radii
    print(f"\n  {'r':>6} | {'N(r)':>8} | {'N(r)·(1-r²)':>14}")
    print("  " + "-" * 35)
    for r_val in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95]:
        count = sum(1 for _, _, rsq in disk_points if rsq <= r_val**2)
        ratio = count * (1 - r_val**2)
        print(f"  {r_val:6.2f} | {count:8d} | {ratio:14.4f}")

if __name__ == "__main__":
    demo_trace_chebyshev()
    demo_trace_discriminant()
    demo_hyperbolic_distance()
    demo_totient_growth()
    demo_index_divisibility()
    demo_orbit_growth()


"""
Visualization 3: Hyperbolic Growth Conjecture Test
====================================================
Tests the conjecture that N(r) · (1-r²) converges to a constant
as r → 1, where N(r) counts orbit points within Euclidean radius r.
This is the hyperbolic analogue of the Gauss circle problem.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

# === Inline all functions ===

def sl2_mul(g, h):
    a1,b1,c1,d1 = g
    a2,b2,c2,d2 = h
    return (a1*a2+b1*c2, a1*b2+b1*d2, c1*a2+d1*c2, c1*b2+d1*d2)

def generate_orbit(max_depth):
    S = (0,-1,1,0)
    T = (1,1,0,1)
    Ti = (1,-1,0,1)
    gens = [S, T, Ti]
    orbit = {}
    identity = (1,0,0,1)
    key = lambda g: tuple(round(x, 6) for x in g)
    orbit[key(identity)] = identity
    frontier = [identity]
    for _ in range(max_depth):
        nf = []
        for g in frontier:
            for gen in gens:
                h = sl2_mul(g, gen)
                k = key(h)
                if k not in orbit:
                    orbit[k] = h
                    nf.append(h)
        frontier = nf
    return list(orbit.values())

def to_disk(g):
    a,b,c,d = g
    denom = c**2 + d**2
    if denom < 1e-15: return None
    re_z = (a*c + b*d) / denom
    im_z = (a*d - b*c) / denom
    num_re, num_im = re_z, im_z - 1
    den_re, den_im = re_z, im_z + 1
    den_sq = den_re**2 + den_im**2
    if den_sq < 1e-15: return None
    w_re = (num_re*den_re + num_im*den_im) / den_sq
    w_im = (num_im*den_re - num_re*den_im) / den_sq
    r_sq = w_re**2 + w_im**2
    return (w_re, w_im, r_sq) if r_sq < 1 - 1e-10 else None

# === Generate data ===
print("Generating orbit...")
matrices = generate_orbit(8)
points = []
for g in matrices:
    pt = to_disk(g)
    if pt:
        points.append(pt)

print(f"Total points: {len(points)}")

# Compute counting function
r_vals = np.linspace(0.05, 0.98, 200)
counts = []
for r in r_vals:
    r_sq = r**2
    count = sum(1 for _, _, rsq in points if rsq <= r_sq)
    counts.append(count)

counts = np.array(counts, dtype=float)
normalized = counts * (1 - r_vals**2)

# Also compute expected: N(r) ~ C/(1-r²)
# In hyperbolic radius R, the area of a disk is 4π sinh²(R/2)
# and r = tanh(R/2), so 1-r² = 1/cosh²(R/2)
# N(R) ~ cR for hyperbolic counting => N(r) ~ c/(1-r²)

# === Plot ===
fig, axes = plt.subplots(2, 2, figsize=(14, 10), facecolor='white')

# Top left: N(r) raw count
ax = axes[0, 0]
ax.plot(r_vals, counts, '-', color='#2c3e50', linewidth=1.5)
ax.set_xlabel('Euclidean radius r', fontsize=11)
ax.set_ylabel('N(r)', fontsize=11)
ax.set_title('Counting Function N(r)', fontsize=13)
ax.grid(True, alpha=0.3)

# Top right: N(r) on log scale
ax = axes[0, 1]
mask = counts > 0
ax.semilogy(r_vals[mask], counts[mask], '-', color='#e74c3c', linewidth=1.5)
# Fit: N(r) ~ C/(1-r²)
ax.semilogy(r_vals, 3 / (1 - r_vals**2), '--', color='#3498db', linewidth=1,
            alpha=0.7, label=r'$3/(1-r^2)$')
ax.set_xlabel('Euclidean radius r', fontsize=11)
ax.set_ylabel('N(r) (log scale)', fontsize=11)
ax.set_title('Growth Rate (log scale)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom left: Normalized N(r)·(1-r²)
ax = axes[1, 0]
mask2 = (r_vals > 0.3) & (counts > 0)
ax.plot(r_vals[mask2], normalized[mask2], '-', color='#2ecc71', linewidth=1.5)
ax.axhline(y=np.median(normalized[mask2 & (r_vals > 0.7)]), 
           color='#e74c3c', linestyle='--', linewidth=1, 
           label=f'Median = {np.median(normalized[mask2 & (r_vals > 0.7)]):.2f}')
ax.set_xlabel('Euclidean radius r', fontsize=11)
ax.set_ylabel(r'$N(r) \cdot (1-r^2)$', fontsize=11)
ax.set_title('Conjecture Test: Does N(r)·(1-r²) converge?', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom right: p(p²-1)/6 for primes
ax = axes[1, 1]
primes = [p for p in range(2, 50) if all(p % i != 0 for i in range(2, int(p**0.5)+1))]
indices = [p * (p**2 - 1) // 6 for p in primes]
ax.bar(range(len(primes)), indices, color='#9b59b6', alpha=0.7)
ax.set_xticks(range(len(primes)))
ax.set_xticklabels(primes, fontsize=8)
ax.set_xlabel('Prime p', fontsize=11)
ax.set_ylabel(r'$p(p^2-1)/6$', fontsize=11)
ax.set_title('Congruence Subgroup Index (proved ∈ ℤ)', fontsize=13)
ax.grid(True, alpha=0.3, axis='y')

plt.suptitle('Hyperbolic Number Theory: Growth Conjecture Analysis',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('growth_conjecture.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved growth_conjecture.png")


"""
Visualization 1: Poincaré Disk Tessellation
============================================
Visualizes the orbit of the origin under PSL(2,ℤ) in the Poincaré disk,
showing the hyperbolic lattice points that form the "hyperbolic integers."
The concentric circles show geodesic (hyperbolic) distance levels.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math

# === Inline all needed functions ===

def sl2_mul(g, h):
    a1,b1,c1,d1 = g
    a2,b2,c2,d2 = h
    return (a1*a2+b1*c2, a1*b2+b1*d2, c1*a2+d1*c2, c1*b2+d1*d2)

def sl2_inv(g):
    a,b,c,d = g
    return (d,-b,-c,a)

def generate_orbit(max_depth=7):
    S = (0,-1,1,0)
    T = (1,1,0,1)
    Ti = (1,-1,0,1)
    gens = [S, T, Ti]
    
    orbit = {}
    identity = (1,0,0,1)
    key = lambda g: tuple(round(x, 6) for x in g)
    orbit[key(identity)] = identity
    frontier = [identity]
    
    for _ in range(max_depth):
        nf = []
        for g in frontier:
            for gen in gens:
                h = sl2_mul(g, gen)
                k = key(h)
                if k not in orbit:
                    orbit[k] = h
                    nf.append(h)
        frontier = nf
    return list(orbit.values())

def to_disk(g):
    a,b,c,d = g
    denom = c**2 + d**2
    if denom < 1e-15:
        return None
    re_z = (a*c + b*d) / denom
    im_z = (a*d - b*c) / denom
    num_re, num_im = re_z, im_z - 1
    den_re, den_im = re_z, im_z + 1
    den_sq = den_re**2 + den_im**2
    if den_sq < 1e-15:
        return None
    w_re = (num_re*den_re + num_im*den_im) / den_sq
    w_im = (num_im*den_re - num_re*den_im) / den_sq
    r_sq = w_re**2 + w_im**2
    if r_sq >= 1 - 1e-10:
        return None
    return (w_re, w_im)

# === Generate data ===
matrices = generate_orbit(7)
points = []
for g in matrices:
    pt = to_disk(g)
    if pt:
        points.append(pt)

xs = [p[0] for p in points]
ys = [p[1] for p in points]
rs = [math.sqrt(p[0]**2 + p[1]**2) for p in points]

# === Plot ===
fig, ax = plt.subplots(1, 1, figsize=(10, 10), facecolor='#0a0a2e')
ax.set_facecolor('#0a0a2e')

# Draw the unit disk boundary
circle = plt.Circle((0, 0), 1, fill=False, color='white', linewidth=2)
ax.add_patch(circle)

# Draw hyperbolic distance circles (in Euclidean coords)
for hyp_r in [0.5, 1.0, 1.5, 2.0, 2.5]:
    # Euclidean radius for hyperbolic radius R: r = tanh(R/2)
    euc_r = math.tanh(hyp_r / 2)
    c = plt.Circle((0, 0), euc_r, fill=False, color='#334477', 
                    linewidth=0.5, linestyle='--', alpha=0.5)
    ax.add_patch(c)
    ax.text(euc_r + 0.02, 0.02, f'R={hyp_r}', color='#5577aa', fontsize=7, alpha=0.7)

# Color points by distance from origin
colors = plt.cm.plasma(np.array(rs) / max(rs) if rs else [0])
sizes = 20 / (1 + 5 * np.array(rs))

ax.scatter(xs, ys, c=rs, cmap='plasma', s=sizes * 10, alpha=0.8, 
           edgecolors='none', zorder=5)

# Mark origin
ax.plot(0, 0, 'o', color='#00ffaa', markersize=8, zorder=10)
ax.text(0.03, 0.03, 'O', color='#00ffaa', fontsize=12, fontweight='bold')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title(f'Hyperbolic Integers: PSL(2,ℤ) Orbit in the Poincaré Disk\n'
             f'({len(points)} lattice points, depth 7)',
             color='white', fontsize=14, pad=20)
ax.tick_params(colors='#666666')
for spine in ax.spines.values():
    spine.set_color('#333333')

plt.tight_layout()
plt.savefig('poincare_disk_orbit.png', dpi=150, bbox_inches='tight',
            facecolor='#0a0a2e')
plt.close()
print(f"Saved poincare_disk_orbit.png with {len(points)} points")


"""
Visualization 2: Trace Growth and Chebyshev Connection
=======================================================
Shows how the trace of SL₂(ℝ) powers follows the Chebyshev
recurrence, demonstrating exponential growth for hyperbolic elements.
This connects hyperbolic dynamics to polynomial algebra.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

# === Inline functions ===

def trace_sequence_chebyshev(t, n_terms):
    """Compute tr(g^k) using Chebyshev recurrence: T_{k+2} = t·T_{k+1} - T_k"""
    traces = [2.0, t]
    for _ in range(n_terms - 2):
        traces.append(t * traces[-1] - traces[-2])
    return traces

def euler_totient(n):
    if n <= 1:
        return n
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result

# === Generate data ===
n_terms = 15

# Different traces
traces_data = {}
for t in [2.0, 2.5, 3.0, 4.0]:
    seq = trace_sequence_chebyshev(t, n_terms)
    traces_data[t] = seq

# Totient sums
ns = list(range(1, 51))
tot_sums = []
cumsum = 0
for n in ns:
    cumsum += euler_totient(n)
    tot_sums.append(cumsum)

# === Plot ===
fig, axes = plt.subplots(1, 2, figsize=(14, 6), facecolor='white')

# Left: Trace growth
ax = axes[0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
for (t, seq), col in zip(traces_data.items(), colors):
    label = f'tr(g) = {t}'
    if t == 2.0:
        ax.plot(range(n_terms), seq, 'o-', color=col, label=label, 
                markersize=4, linewidth=1.5)
    else:
        ax.plot(range(n_terms), [abs(s) for s in seq], 'o-', color=col, 
                label=label, markersize=4, linewidth=1.5)

ax.set_yscale('log')
ax.set_xlabel('Power n', fontsize=12)
ax.set_ylabel('|tr(gⁿ)|', fontsize=12)
ax.set_title('Trace Growth: Chebyshev Recurrence\n'
             r'$\mathrm{tr}(g^{n+2}) = \mathrm{tr}(g) \cdot \mathrm{tr}(g^{n+1}) - \mathrm{tr}(g^n)$',
             fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.5, n_terms - 0.5)

# Right: Totient sum growth
ax = axes[1]
ax.fill_between(ns, tot_sums, alpha=0.3, color='#3498db')
ax.plot(ns, tot_sums, 'o-', color='#2c3e50', markersize=3, linewidth=1.5,
        label=r'$\sum_{k=1}^n \varphi(k)$')
ax.plot(ns, ns, '--', color='#e74c3c', linewidth=1.5, label='n (lower bound)')
ax.plot(ns, [3*n**2/(math.pi**2) for n in ns], ':', color='#2ecc71', 
        linewidth=2, label=r'$3n^2/\pi^2$ (asymptotic)')

ax.set_xlabel('n', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Totient Sum Growth (Farey Fraction Count)\n'
             'Proved: Σφ(k) ≥ n for all n ≥ 1',
             fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('trace_and_totient.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved trace_and_totient.png")
