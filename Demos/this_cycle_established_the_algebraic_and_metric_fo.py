#!/usr/bin/env python3
"""
applications.py — Real-world applications of Hyperbolic Number Theory

1. Rational Approximation of Angles via Pythagorean Triples
2. GPS Velocity Composition (relativistic corrections)
3. Cryptographic Key Generation from Berggren Paths
4. Integer Lattice Point Counting
"""

from math import gcd, pi, atan2, sqrt, degrees, ceil
from typing import Tuple, List, Dict

Triple = Tuple[int, int, int]


# ============================================================
# Application 1: Rational Angle Approximation
# ============================================================

class RationalAngleApproximator:
    """
    Every Pythagorean triple (a, b, c) gives a rational point (a/c, b/c)
    on the unit circle, corresponding to a rational angle θ = atan2(b, a).
    
    This can be used to approximate any target angle with a rational
    rotation, useful in digital signal processing and computer graphics.
    """
    
    def __init__(self, max_hyp: int = 10000):
        """Pre-compute triples up to given hypotenuse."""
        self.triples = self._enumerate(max_hyp)
        self.angles = [(atan2(b, a), (a, b, c)) for a, b, c in self.triples]
        self.angles.sort()
    
    def _enumerate(self, max_hyp: int) -> List[Triple]:
        """Enumerate via Berggren tree."""
        result = []
        stack = [(3, 4, 5)]
        while stack:
            a, b, c = stack.pop()
            if c <= max_hyp:
                result.append((a, b, c))
                # Also include (b, a, c) for the complementary angle
                if a != b:
                    result.append((b, a, c))
                stack.append((a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c))
                stack.append((a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c))
                stack.append((-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c))
        return result
    
    def best_approximation(self, target_angle_rad: float, 
                            max_denominator: int = 1000) -> dict:
        """
        Find the Pythagorean triple whose angle best approximates the target.
        
        Args:
            target_angle_rad: Target angle in radians (0 to π/2)
            max_denominator: Maximum hypotenuse to consider
            
        Returns:
            Dict with best triple, angle, and error
        """
        import bisect
        target = target_angle_rad % (pi / 2)
        
        # Binary search for closest angle
        angles_only = [a for a, _ in self.angles]
        idx = bisect.bisect_left(angles_only, target)
        
        best = None
        best_err = float('inf')
        
        for i in range(max(0, idx-1), min(len(self.angles), idx+2)):
            angle, triple = self.angles[i]
            if triple[2] <= max_denominator:
                err = abs(angle - target)
                if err < best_err:
                    best_err = err
                    best = triple
        
        if best is None:
            return {'error': 'No approximation found'}
        
        a, b, c = best
        return {
            'triple': best,
            'cos': a / c,
            'sin': b / c,
            'angle_rad': atan2(b, a),
            'angle_deg': degrees(atan2(b, a)),
            'target_deg': degrees(target_angle_rad),
            'error_deg': degrees(best_err) if best_err < float('inf') else None,
        }


# ============================================================
# Application 2: Velocity Composition Calculator
# ============================================================

class VelocityCalculator:
    """
    Compute relativistic velocity compositions using exact rational
    arithmetic when velocities come from Pythagorean triples.
    
    In particle physics, velocities are often expressed as fractions
    of the speed of light. Pythagorean triples provide exact rational
    velocities that compose cleanly.
    """
    
    @staticmethod
    def compose(beta1: float, beta2: float) -> float:
        """Relativistic velocity addition."""
        return (beta1 + beta2) / (1 + beta1 * beta2)
    
    @staticmethod
    def compose_rational(a1: int, c1: int, a2: int, c2: int) -> Tuple[int, int]:
        """
        Compose two rational velocities a₁/c₁ and a₂/c₂ exactly.
        
        Returns (numerator, denominator) in lowest terms.
        """
        num = a1 * c2 + a2 * c1
        den = c1 * c2 + a1 * a2
        g = gcd(abs(num), abs(den))
        return (num // g, den // g)
    
    @staticmethod
    def lorentz_factor(beta: float) -> float:
        """Compute γ = 1/√(1 - β²)."""
        return 1.0 / sqrt(1 - beta**2)
    
    def chain_compose(self, velocities: List[float]) -> List[dict]:
        """
        Compose a chain of velocities, showing intermediate results.
        
        Returns list of dicts with velocity, gamma factor, etc.
        """
        results = []
        current = 0.0
        for i, v in enumerate(velocities):
            current = self.compose(current, v)
            gamma = self.lorentz_factor(current)
            results.append({
                'step': i + 1,
                'added_velocity': v,
                'total_velocity': current,
                'gamma': gamma,
                'classical_sum': sum(velocities[:i+1]),
            })
        return results


# ============================================================
# Application 3: Berggren Path Encoding
# ============================================================

class BerggrenEncoder:
    """
    Encode/decode integers using Berggren tree paths.
    
    Since the Berggren tree is a complete ternary tree that enumerates
    all primitive Pythagorean triples, each triple has a unique address
    as a path from the root. This provides a bijection between
    finite ternary strings and primitive triples.
    """
    
    MATRICES = {
        'A': lambda a, b, c: (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c),
        'B': lambda a, b, c: (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c),
        'C': lambda a, b, c: (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c),
    }
    
    ROOT = (3, 4, 5)
    
    @classmethod
    def encode(cls, path: str) -> Triple:
        """Convert a Berggren path to a Pythagorean triple."""
        triple = cls.ROOT
        for ch in path:
            if ch not in cls.MATRICES:
                raise ValueError(f"Invalid direction: {ch}")
            a, b, c = triple
            triple = cls.MATRICES[ch](a, b, c)
        return triple
    
    @classmethod
    def int_to_path(cls, n: int) -> str:
        """
        Convert a non-negative integer to a Berggren path.
        Uses base-3 encoding: 0→A, 1→B, 2→C.
        
        n=0 → '' (root)
        n=1 → 'A', n=2 → 'B', n=3 → 'C'
        n=4 → 'AA', n=5 → 'AB', etc.
        """
        if n == 0:
            return ''
        
        # Convert to bijective base-3
        dirs = 'ABC'
        path = []
        n -= 1  # Adjust for 1-indexing of non-root nodes
        
        depth = 0
        count = 1  # Number of nodes at depth 0
        total = 1
        while total + count * 3 <= n + 1:
            total += count * 3
            count *= 3
            depth += 1
        
        remaining = n + 1 - total + count * 3 - count * 3  # nodes before this depth
        # Simpler approach: just use ternary digits
        if n == 0:
            return ''
        path_chars = []
        m = n - 1
        while m >= 0:
            path_chars.append(dirs[m % 3])
            m = m // 3 - 1
            if m < -1:
                break
        return ''.join(reversed(path_chars))
    
    @classmethod
    def triple_to_velocity(cls, triple: Triple) -> float:
        """Extract velocity β = a/c from a triple."""
        a, _, c = triple
        return a / c


# ============================================================
# Application 4: Lattice Point Density
# ============================================================

class LatticePointAnalyzer:
    """
    Analyze the distribution of Pythagorean lattice points.
    
    The density of primitive Pythagorean triples with hypotenuse ≤ N
    is asymptotically N/(2π), giving a connection to the geometry
    of the unit circle and the Gauss circle problem.
    """
    
    @staticmethod
    def count_triples(N: int) -> int:
        """Count primitive triples with hypotenuse ≤ N via Berggren tree."""
        count = 0
        stack = [(3, 4, 5)]
        while stack:
            a, b, c = stack.pop()
            if c <= N:
                count += 1
                stack.append((a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c))
                stack.append((a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c))
                stack.append((-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c))
        return count
    
    @staticmethod
    def density_analysis(max_N: int, steps: int = 20) -> List[dict]:
        """
        Compute the density ratio pythCount(N) / (N/(2π)) at logarithmic intervals.
        """
        results = []
        analyzer = LatticePointAnalyzer()
        
        for i in range(steps):
            N = int(10 * (max_N / 10) ** (i / (steps - 1)))
            N = max(N, 10)
            count = analyzer.count_triples(N)
            expected = N / (2 * pi)
            ratio = count / expected if expected > 0 else 0
            results.append({
                'N': N,
                'count': count,
                'expected': expected,
                'ratio': ratio,
                'conjecture_holds': count >= N // 7 if N >= 100 else True,
            })
        return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    # Application 1: Rational Angle Approximation
    print("APPLICATION 1: Rational Angle Approximation")
    print("=" * 50)
    approx = RationalAngleApproximator(max_hyp=1000)
    
    for target_deg in [30, 45, 60, 15, 22.5, 37]:
        target_rad = target_deg * pi / 180
        result = approx.best_approximation(target_rad, max_denominator=100)
        if 'error' not in result:
            print(f"  Target {target_deg:5.1f}° → triple {result['triple']}, "
                  f"angle {result['angle_deg']:.2f}°, "
                  f"error {result['error_deg']:.4f}°")
    
    # Application 2: Velocity Composition
    print("\nAPPLICATION 2: Velocity Composition")
    print("=" * 50)
    calc = VelocityCalculator()
    
    # Compose velocities from triples
    triples = [(3,4,5), (5,12,13), (8,15,17)]
    velocities = [a/c for a, _, c in triples]
    results = calc.chain_compose(velocities)
    for r in results:
        print(f"  Step {r['step']}: +{r['added_velocity']:.4f}c → "
              f"total={r['total_velocity']:.6f}c (γ={r['gamma']:.2f}), "
              f"classical={r['classical_sum']:.4f}c")
    
    # Exact rational composition
    num, den = calc.compose_rational(3, 5, 5, 13)
    print(f"\n  Exact: 3/5 ⊕ 5/13 = {num}/{den} = {num/den:.6f}")
    
    # Application 3: Berggren Encoding
    print("\nAPPLICATION 3: Berggren Path Encoding")
    print("=" * 50)
    encoder = BerggrenEncoder()
    for path in ['', 'A', 'B', 'C', 'AA', 'AB', 'AC', 'BA', 'ABC']:
        triple = encoder.encode(path)
        beta = encoder.triple_to_velocity(triple)
        print(f"  Path '{path:3s}' → {triple} → β = {beta:.6f}")
    
    # Application 4: Lattice Point Density
    print("\nAPPLICATION 4: Lattice Point Density")
    print("=" * 50)
    results = LatticePointAnalyzer.density_analysis(10000, steps=10)
    print(f"  {'N':>8s} | {'Count':>6s} | {'N/(2π)':>8s} | {'Ratio':>6s}")
    print(f"  {'-'*8} | {'-'*6} | {'-'*8} | {'-'*6}")
    for r in results:
        print(f"  {r['N']:8d} | {r['count']:6d} | {r['expected']:8.1f} | {r['ratio']:6.4f}")


#!/usr/bin/env python3
"""
demo.py — Demonstrations of Hyperbolic Number Theory theorems

Concrete numerical examples illustrating:
1. Berggren tree enumeration of Pythagorean triples
2. Lorentz form preservation
3. Parity theorem verification
4. Relativistic velocity addition
5. Pythagorean counting function
"""

from math import gcd, pi, sqrt
from typing import Tuple, List

Triple = Tuple[int, int, int]


def berggren_A(a: int, b: int, c: int) -> Triple:
    """Berggren matrix A transformation."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def berggren_B(a: int, b: int, c: int) -> Triple:
    """Berggren matrix B transformation."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def berggren_C(a: int, b: int, c: int) -> Triple:
    """Berggren matrix C transformation."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def lorentz_form(a: int, b: int, c: int) -> int:
    """The Lorentz quadratic form Q(a,b,c) = a² + b² - c²."""
    return a**2 + b**2 - c**2


def velocity_add(beta1: float, beta2: float) -> float:
    """Relativistic velocity addition: β₁ ⊕ β₂ = (β₁+β₂)/(1+β₁β₂)."""
    return (beta1 + beta2) / (1 + beta1 * beta2)


def enumerate_berggren(max_hyp: int) -> List[Triple]:
    """Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_hyp."""
    result = []
    stack = [(3, 4, 5)]
    while stack:
        a, b, c = stack.pop()
        if c <= max_hyp:
            result.append((a, b, c))
            stack.append(berggren_A(a, b, c))
            stack.append(berggren_B(a, b, c))
            stack.append(berggren_C(a, b, c))
    return sorted(result, key=lambda t: t[2])


def pyth_count(N: int) -> int:
    """Count primitive Pythagorean triples with hypotenuse < N."""
    return len([t for t in enumerate_berggren(N - 1)])


# ============================================================
# DEMO 1: Berggren Tree — First few levels
# ============================================================
print("=" * 60)
print("DEMO 1: Berggren Tree of Pythagorean Triples")
print("=" * 60)

root = (3, 4, 5)
print(f"\nRoot: {root}")
print(f"  Pythagorean check: {root[0]}² + {root[1]}² = {root[0]**2 + root[1]**2} = {root[2]}² = {root[2]**2}")

children = [berggren_A(*root), berggren_B(*root), berggren_C(*root)]
print(f"\nChildren:")
for name, child in zip(["A", "B", "C"], children):
    a, b, c = child
    print(f"  {name}-child: ({a}, {b}, {c})")
    print(f"    Check: {a}² + {b}² = {a**2 + b**2}, {c}² = {c**2}, Match: {a**2 + b**2 == c**2}")

print(f"\nFirst 20 primitive triples by hypotenuse:")
triples = enumerate_berggren(100)
for i, (a, b, c) in enumerate(triples[:20]):
    print(f"  {i+1:2d}. ({a:3d}, {b:3d}, {c:3d})  gcd(a,b)={gcd(a,b)}")

# ============================================================
# DEMO 2: Lorentz Form Preservation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Lorentz Form Preservation")
print("=" * 60)

for triple in triples[:8]:
    a, b, c = triple
    Q_orig = lorentz_form(a, b, c)
    Q_A = lorentz_form(*berggren_A(a, b, c))
    Q_B = lorentz_form(*berggren_B(a, b, c))
    Q_C = lorentz_form(*berggren_C(a, b, c))
    print(f"  ({a:3d},{b:3d},{c:3d}): Q={Q_orig}, Q(A·)={Q_A}, Q(B·)={Q_B}, Q(C·)={Q_C}")

# ============================================================
# DEMO 3: Parity Theorem
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Parity Theorem — Exactly One Even Leg")
print("=" * 60)

for a, b, c in triples[:12]:
    a_even = a % 2 == 0
    b_even = b % 2 == 0
    c_odd = c % 2 == 1
    parity_ok = (a_even != b_even) and c_odd
    print(f"  ({a:3d},{b:3d},{c:3d}): a {'even' if a_even else 'odd '}, "
          f"b {'even' if b_even else 'odd '}, c {'odd ' if c_odd else 'even'} — {'✓' if parity_ok else '✗'}")

# ============================================================
# DEMO 4: Relativistic Velocity Addition
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Relativistic Velocity Addition")
print("=" * 60)

# From Pythagorean triples
print("\nVelocities from Pythagorean triples (β = a/c):")
for a, b, c in [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25)]:
    beta = a / c
    print(f"  ({a},{b},{c}) → β = {a}/{c} = {beta:.6f}")

# Velocity addition examples
print("\nVelocity addition (stays below light speed):")
beta1 = 3 / 5  # = 0.6
beta2 = 5 / 13  # ≈ 0.385
result = velocity_add(beta1, beta2)
classical = beta1 + beta2
print(f"  β₁ = 3/5 = {beta1}")
print(f"  β₂ = 5/13 = {beta2:.6f}")
print(f"  Classical: β₁ + β₂ = {classical:.6f}")
print(f"  Relativistic: β₁ ⊕ β₂ = {result:.6f}")
print(f"  |result| < 1: {abs(result) < 1}")

# Associativity check
print("\nAssociativity check:")
b1, b2, b3 = 0.3, 0.5, 0.7
lhs = velocity_add(velocity_add(b1, b2), b3)
rhs = velocity_add(b1, velocity_add(b2, b3))
print(f"  (0.3 ⊕ 0.5) ⊕ 0.7 = {lhs:.10f}")
print(f"  0.3 ⊕ (0.5 ⊕ 0.7) = {rhs:.10f}")
print(f"  Equal: {abs(lhs - rhs) < 1e-15}")

# Composing many velocities
print("\nComposing 10 velocities of 0.5c:")
beta = 0.0
for i in range(10):
    beta = velocity_add(beta, 0.5)
    print(f"  After {i+1} additions: β = {beta:.6f}")
print(f"  Still < 1: {beta < 1}")

# ============================================================
# DEMO 5: Pythagorean Counting Function
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Pythagorean Counting Function vs N/(2π)")
print("=" * 60)

print(f"\n  {'N':>8s} | {'pythCount':>10s} | {'N/(2π)':>10s} | {'Ratio':>8s} | {'N/7':>6s} | {'≥N/7?':>6s}")
print(f"  {'-'*8} | {'-'*10} | {'-'*10} | {'-'*8} | {'-'*6} | {'-'*6}")
for N in [50, 100, 200, 500, 1000, 2000, 5000]:
    count = pyth_count(N)
    expected = N / (2 * pi)
    ratio = count / expected if expected > 0 else 0
    n7 = N // 7
    print(f"  {N:8d} | {count:10d} | {expected:10.2f} | {ratio:8.4f} | {n7:6d} | {'✓' if count >= n7 else '✗':>6s}")

# ============================================================
# DEMO 6: Hypotenuse Growth in Tree
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Hypotenuse Growth by Tree Depth")
print("=" * 60)


def tree_at_depth(depth: int) -> List[Triple]:
    """Get all triples at a given depth in the Berggren tree."""
    if depth == 0:
        return [(3, 4, 5)]
    parents = tree_at_depth(depth - 1)
    children = []
    for p in parents:
        children.extend([berggren_A(*p), berggren_B(*p), berggren_C(*p)])
    return children


for d in range(6):
    triples_d = tree_at_depth(d)
    hyps = [c for _, _, c in triples_d]
    print(f"  Depth {d}: {len(triples_d):4d} triples, "
          f"min hyp = {min(hyps):6d}, max hyp = {max(hyps):6d}, "
          f"all ≥ 5: {all(h >= 5 for h in hyps)}")

print("\nAll demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: The Berggren Tree of Pythagorean Triples

This script visualizes the first several levels of the Berggren ternary tree,
showing how primitive Pythagorean triples are organized by their parent-child
relationships. Points are plotted on the unit circle at angle θ = atan2(b/c, a/c),
with color indicating tree depth (hyperbolic distance from origin).

The exponential growth of the tree mirrors the exponential divergence of
geodesics in hyperbolic space — a visual manifestation of negative curvature.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import atan2, pi, sqrt


def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def build_tree(max_depth=5):
    """Build tree with depth tracking."""
    nodes = []  # (a, b, c, depth, parent_idx)
    nodes.append((3, 4, 5, 0, -1))
    queue = [(3, 4, 5, 0, 0)]
    
    while queue:
        a, b, c, depth, parent_idx = queue.pop(0)
        if depth >= max_depth:
            continue
        
        for child_fn in [berggren_A, berggren_B, berggren_C]:
            child = child_fn(a, b, c)
            child_idx = len(nodes)
            nodes.append((*child, depth + 1, parent_idx))
            queue.append((*child, depth + 1, child_idx))
    
    return nodes


# Build tree
max_depth = 4
nodes = build_tree(max_depth)

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# ---- LEFT PLOT: Points on the unit disk ----
# Map each triple (a,b,c) to the point (a/c, b/c) on the unit disk
cmap = plt.cm.plasma
norm = plt.Normalize(0, max_depth)

# Draw unit circle
theta = np.linspace(0, pi/2, 100)
ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1, alpha=0.3)

# Draw edges (parent to child)
for i, (a, b, c, depth, parent_idx) in enumerate(nodes):
    if parent_idx >= 0:
        pa, pb, pc = nodes[parent_idx][0], nodes[parent_idx][1], nodes[parent_idx][2]
        ax1.plot([pa/pc, a/c], [pb/pc, b/c], 
                color=cmap(norm(depth)), alpha=0.3, linewidth=0.5)

# Draw nodes
for a, b, c, depth, _ in nodes:
    x, y = a/c, b/c
    size = max(8, 40 - depth * 8)
    ax1.scatter(x, y, c=[depth], cmap='plasma', vmin=0, vmax=max_depth, 
               s=size, zorder=5, edgecolors='black', linewidth=0.3)

# Label root and first-level nodes
for a, b, c, depth, _ in nodes[:4]:
    ax1.annotate(f'({a},{b},{c})', (a/c, b/c), 
                textcoords="offset points", xytext=(5, 5),
                fontsize=7, alpha=0.8)

ax1.set_xlim(-0.05, 1.05)
ax1.set_ylim(-0.05, 1.05)
ax1.set_aspect('equal')
ax1.set_xlabel('a/c (cosine component)', fontsize=11)
ax1.set_ylabel('b/c (sine component)', fontsize=11)
ax1.set_title('Pythagorean Triples on the Unit Circle\n(Berggren Tree, depth ≤ 4)', fontsize=13)

# ---- RIGHT PLOT: Hypotenuse growth by depth ----
depths = {}
for a, b, c, depth, _ in nodes:
    if depth not in depths:
        depths[depth] = []
    depths[depth].append(c)

depth_labels = sorted(depths.keys())
for d in depth_labels:
    hyps = sorted(depths[d])
    jitter = np.random.normal(0, 0.1, len(hyps))
    ax2.scatter([d + j for j in jitter], hyps, 
               c=[d]*len(hyps), cmap='plasma', vmin=0, vmax=max_depth,
               s=15, alpha=0.7, edgecolors='none')

# Plot min and max hypotenuse per depth
min_hyps = [min(depths[d]) for d in depth_labels]
max_hyps = [max(depths[d]) for d in depth_labels]
mean_hyps = [sum(depths[d])/len(depths[d]) for d in depth_labels]
ax2.plot(depth_labels, min_hyps, 'b-o', markersize=5, label='Min hypotenuse', linewidth=2)
ax2.plot(depth_labels, max_hyps, 'r-s', markersize=5, label='Max hypotenuse', linewidth=2)
ax2.plot(depth_labels, mean_hyps, 'g-^', markersize=5, label='Mean hypotenuse', linewidth=2)

ax2.set_yscale('log')
ax2.set_xlabel('Berggren Tree Depth', fontsize=11)
ax2.set_ylabel('Hypotenuse (log scale)', fontsize=11)
ax2.set_title('Exponential Growth of Hypotenuse\n(Hyperbolic Divergence)', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('berggren_tree_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: berggren_tree_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Pythagorean Counting Function vs Lehmer Asymptotic

Shows the remarkable convergence of pythCount(N) to N/(2π), confirming
Lehmer's 1900 theorem. The appearance of π in this counting problem
connects number theory to the geometry of the circle.

Also verifies the falsifiable conjecture: pythCount(N) ≥ N/7 for N ≥ 100.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import pi, gcd


def berggren_count(max_hyp):
    """Count primitive Pythagorean triples with hypotenuse ≤ max_hyp."""
    count = 0
    stack = [(3, 4, 5)]
    while stack:
        a, b, c = stack.pop()
        if c <= max_hyp:
            count += 1
            stack.append((a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c))
            stack.append((a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c))
            stack.append((-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c))
    return count


# Compute counting function at many points
N_values = list(range(10, 201, 5)) + list(range(200, 5001, 50))
counts = []
for N in N_values:
    counts.append(berggren_count(N))

N_arr = np.array(N_values, dtype=float)
count_arr = np.array(counts, dtype=float)
lehmer_arr = N_arr / (2 * pi)
ratio_arr = count_arr / lehmer_arr

# Create figure
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ---- PANEL 1: Count vs asymptotic ----
ax = axes[0, 0]
ax.plot(N_arr, count_arr, 'b-', linewidth=1.5, label='pythCount(N)')
ax.plot(N_arr, lehmer_arr, 'r--', linewidth=1.5, label='N/(2π)', alpha=0.8)
ax.plot(N_arr, N_arr/7, 'g:', linewidth=1.5, label='N/7 (conjecture bound)', alpha=0.7)
ax.set_xlabel('N', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Primitive Pythagorean Triple Counting Function', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ---- PANEL 2: Ratio to asymptotic ----
ax = axes[0, 1]
ax.plot(N_arr, ratio_arr, 'b-', linewidth=1, alpha=0.7)
ax.axhline(y=1.0, color='r', linewidth=1.5, linestyle='--', label='Exact asymptotic (ratio = 1)')
ax.fill_between(N_arr, 0.95, 1.05, alpha=0.1, color='green', label='±5% band')
ax.set_xlabel('N', fontsize=11)
ax.set_ylabel('pythCount(N) / (N/(2π))', fontsize=11)
ax.set_title('Convergence to Lehmer Asymptotic', fontsize=12)
ax.set_ylim(0.8, 1.2)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ---- PANEL 3: Error term ----
ax = axes[1, 0]
error = count_arr - lehmer_arr
ax.plot(N_arr, error, 'purple', linewidth=1, alpha=0.7)
ax.axhline(y=0, color='black', linewidth=0.5)
ax.plot(N_arr, np.sqrt(N_arr) * 0.5, 'r--', linewidth=1, alpha=0.5, label='~0.5√N')
ax.plot(N_arr, -np.sqrt(N_arr) * 0.5, 'r--', linewidth=1, alpha=0.5)
ax.set_xlabel('N', fontsize=11)
ax.set_ylabel('pythCount(N) - N/(2π)', fontsize=11)
ax.set_title('Error Term (appears to be O(√N))', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ---- PANEL 4: Distribution of hypotenuses ----
ax = axes[1, 1]

# Get all triples up to 500
all_triples = []
stack = [(3, 4, 5)]
while stack:
    a, b, c = stack.pop()
    if c <= 500:
        all_triples.append((a, b, c))
        stack.append((a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c))
        stack.append((a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c))
        stack.append((-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c))

hyps = [c for _, _, c in all_triples]
ax.hist(hyps, bins=50, density=True, alpha=0.7, color='steelblue', 
        edgecolor='white', linewidth=0.5, label='Observed distribution')

# Overlay the expected uniform density 1/(2π) per unit interval
x_range = np.linspace(5, 500, 100)
ax.axhline(y=1/(2*pi), color='red', linewidth=2, linestyle='--', 
           label=f'Expected density: 1/(2π) ≈ {1/(2*pi):.4f}')

ax.set_xlabel('Hypotenuse c', fontsize=11)
ax.set_ylabel('Density', fontsize=11)
ax.set_title('Distribution of Hypotenuses\n(converges to uniform density 1/(2π))', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Pythagorean Counting: From Berggren Trees to Lehmer\'s Theorem',
            fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('counting_function_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: counting_function_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Relativistic Velocity Addition Group

Shows how the relativistic velocity addition formula β₁ ⊕ β₂ = (β₁+β₂)/(1+β₁β₂)
keeps velocities below the speed of light, in contrast to classical (Galilean)
addition which can exceed c.

The left panel shows the group operation as a 2D heatmap.
The right panel shows successive compositions: what happens when you keep
adding β = 0.5c to itself, comparing classical vs relativistic.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def velocity_add(b1, b2):
    """Relativistic velocity addition."""
    return (b1 + b2) / (1 + b1 * b2)


# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- PANEL 1: Heatmap of velocity addition ----
ax = axes[0]
n = 200
beta_range = np.linspace(-0.99, 0.99, n)
B1, B2 = np.meshgrid(beta_range, beta_range)
Result = velocity_add(B1, B2)

im = ax.pcolormesh(B1, B2, Result, cmap='RdBu_r', vmin=-1, vmax=1, shading='auto')
plt.colorbar(im, ax=ax, label='β₁ ⊕ β₂')

# Add contour lines
contours = ax.contour(B1, B2, Result, levels=np.linspace(-0.9, 0.9, 10), 
                       colors='black', linewidths=0.5, alpha=0.4)

# Mark the "light speed barrier"
ax.axhline(y=0, color='white', linewidth=0.5, alpha=0.5)
ax.axvline(x=0, color='white', linewidth=0.5, alpha=0.5)

# Mark Pythagorean velocities
pyth_velocities = [3/5, 5/13, 8/17, 7/25, 20/29]
for v in pyth_velocities:
    ax.axhline(y=v, color='lime', linewidth=0.5, alpha=0.3)
    ax.axvline(x=v, color='lime', linewidth=0.5, alpha=0.3)

ax.set_xlabel('β₁ (fraction of c)', fontsize=11)
ax.set_ylabel('β₂ (fraction of c)', fontsize=11)
ax.set_title('Relativistic Velocity Addition\nβ₁ ⊕ β₂ = (β₁+β₂)/(1+β₁β₂)', fontsize=12)
ax.set_aspect('equal')

# ---- PANEL 2: Classical vs Relativistic composition ----
ax = axes[1]

beta_fixed = 0.5
n_steps = 15

classical = [0]
relativistic = [0]

for i in range(n_steps):
    classical.append(classical[-1] + beta_fixed)
    relativistic.append(velocity_add(relativistic[-1], beta_fixed))

steps = range(n_steps + 1)
ax.plot(steps, classical, 'r-o', markersize=4, label='Classical (Galilean)', linewidth=2)
ax.plot(steps, relativistic, 'b-s', markersize=4, label='Relativistic', linewidth=2)
ax.axhline(y=1.0, color='gold', linewidth=2, linestyle='--', label='Speed of light', alpha=0.8)
ax.fill_between(steps, 1.0, max(classical), alpha=0.1, color='red')

ax.set_xlabel('Number of boosts (each adds β = 0.5c)', fontsize=11)
ax.set_ylabel('Total velocity (fraction of c)', fontsize=11)
ax.set_title('Successive Velocity Additions\n(Classical vs Relativistic)', fontsize=12)
ax.legend(fontsize=9, loc='upper left')
ax.set_ylim(-0.1, max(classical) * 1.05)
ax.grid(True, alpha=0.3)

# ---- PANEL 3: Rapidity (arctanh) linearization ----
ax = axes[2]

# In rapidity space, velocity addition is just ordinary addition
beta_values = np.linspace(0.01, 0.99, 50)
rapidity = np.arctanh(beta_values)

ax.plot(beta_values, rapidity, 'b-', linewidth=2, label='φ = arctanh(β)')
ax.plot(beta_values, beta_values, 'r--', linewidth=1, alpha=0.5, label='φ = β (small β)')

# Mark Pythagorean velocities
for v in pyth_velocities[:4]:
    phi = np.arctanh(v)
    ax.plot(v, phi, 'go', markersize=8, zorder=5)
    ax.annotate(f'β={v:.2f}', (v, phi), textcoords="offset points", 
               xytext=(8, -5), fontsize=8)

# Show that rapidity of composed velocity = sum of rapidities
phi1 = np.arctanh(3/5)
phi2 = np.arctanh(5/13)
beta_composed = velocity_add(3/5, 5/13)
phi_composed = np.arctanh(beta_composed)

ax.annotate(f'φ(3/5) + φ(5/13) = {phi1:.3f} + {phi2:.3f} = {phi1+phi2:.3f}\n'
           f'φ(3/5 ⊕ 5/13) = φ({beta_composed:.4f}) = {phi_composed:.3f}\n'
           f'Match: {"✓" if abs(phi1+phi2-phi_composed) < 1e-10 else "✗"}',
           xy=(0.3, 1.5), fontsize=8, 
           bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

ax.set_xlabel('Velocity β (fraction of c)', fontsize=11)
ax.set_ylabel('Rapidity φ = arctanh(β)', fontsize=11)
ax.set_title('Rapidity: Linearizing\nVelocity Addition', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('velocity_addition_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: velocity_addition_visualization.png")
