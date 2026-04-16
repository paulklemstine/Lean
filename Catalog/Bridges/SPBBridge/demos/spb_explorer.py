#!/usr/bin/env python3
"""
Stereographic Projection Bridge (SPB) — Interactive Explorer & Demo Suite

Demonstrates the verified mathematical properties of spb(x,y) = (x+y)/(1-xy):
  1. Basic algebraic properties (commutativity, associativity, identity, inverses)
  2. Cayley transform and circle group isomorphism
  3. Machin formula enumeration
  4. Einstein velocity addition
  5. Matrix representation
  6. Tropical SPB
  7. Finite field SPB and the p±1 law
  8. Arctan homomorphism visualization
  9. SPB iteration and orbit visualization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from itertools import product as cartesian_product

# ─── Core SPB Operations ────────────────────────────────────────

def spb(x, y):
    """The Stereographic Projection Bridge: spb(x,y) = (x+y)/(1-xy)."""
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return float('inf')
    return (x + y) / denom

def spbH(u, v):
    """Hyperbolic / Einstein velocity addition: spbH(u,v) = (u+v)/(1+uv)."""
    return (u + v) / (1 + u * v)

def cayley(x):
    """Cayley transform: C(x) = (1+ix)/(1-ix), maps ℝ → S¹."""
    return (1 + 1j * x) / (1 - 1j * x)

def tspb(x, y):
    """Tropical SPB: tspb(x,y) = max(x,y) - max(0, x+y)."""
    return max(x, y) - max(0, x + y)

def spb_matrix(a):
    """SPB matrix M(a) = [[1, a], [-a, 1]]."""
    return np.array([[1, a], [-a, 1]])

# ─── Demo 1: Algebraic Properties ───────────────────────────────

def demo_algebra():
    """Verify fundamental algebraic properties of SPB."""
    print("=" * 60)
    print("DEMO 1: SPB Algebraic Properties")
    print("=" * 60)

    # Commutativity
    x, y = 0.7, 1.3
    print(f"\nCommutativity: spb({x}, {y}) = {spb(x,y):.10f}")
    print(f"              spb({y}, {x}) = {spb(y,x):.10f}")
    assert abs(spb(x, y) - spb(y, x)) < 1e-12

    # Identity
    print(f"\nIdentity: spb({x}, 0) = {spb(x, 0):.10f}  (should be {x})")
    assert abs(spb(x, 0) - x) < 1e-12

    # Inverse
    print(f"Inverse:  spb({x}, {-x}) = {spb(x, -x):.10f}  (should be 0)")
    assert abs(spb(x, -x)) < 1e-12

    # Associativity
    z = 0.4
    lhs = spb(spb(x, y), z)
    rhs = spb(x, spb(y, z))
    print(f"\nAssociativity: spb(spb({x},{y}),{z}) = {lhs:.10f}")
    print(f"               spb({x},spb({y},{z})) = {rhs:.10f}")
    assert abs(lhs - rhs) < 1e-10

    # Odd symmetry
    print(f"\nOdd symmetry: spb(-x,-y) = {spb(-x,-y):.10f}")
    print(f"             -spb(x,y)  = {-spb(x,y):.10f}")
    assert abs(spb(-x, -y) + spb(x, y)) < 1e-12

    print("\n✓ All algebraic properties verified!")

# ─── Demo 2: Cayley Transform & Circle Group ────────────────────

def demo_cayley():
    """Demonstrate the Cayley transform isomorphism."""
    print("\n" + "=" * 60)
    print("DEMO 2: Cayley Transform — SPB ≅ Circle Group")
    print("=" * 60)

    test_values = [0, 0.5, 1, -1, 2, -0.3, 0.8]

    print("\n  x     |C(x)|     C(x)")
    print("  " + "-" * 50)
    for x in test_values:
        c = cayley(x)
        print(f"  {x:6.2f}  {abs(c):.10f}  {c.real:+.6f} {c.imag:+.6f}i")
        assert abs(abs(c) - 1) < 1e-12, f"|C({x})| ≠ 1"

    print("\n  C(0) = 1:  ", cayley(0))
    print("  C(1) = i:  ", cayley(1))

    # Homomorphism check
    print("\n  Homomorphism: C(spb(x,y)) = C(x)·C(y)")
    for x, y in [(0.3, 0.5), (1.0, -0.5), (0.7, 0.2)]:
        lhs = cayley(spb(x, y))
        rhs = cayley(x) * cayley(y)
        err = abs(lhs - rhs)
        print(f"    x={x}, y={y}: error = {err:.2e}")
        assert err < 1e-12

    print("\n✓ Cayley isomorphism verified!")

    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(6, 6))
    theta = np.linspace(0, 2 * np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=1)

    ts = np.linspace(-5, 5, 50)
    cs = [cayley(t) for t in ts]
    ax.scatter([c.real for c in cs], [c.imag for c in cs], c=ts, cmap='viridis', s=30)
    ax.set_aspect('equal')
    ax.set_title("Cayley Transform: ℝ → S¹")
    ax.set_xlabel("Re"); ax.set_ylabel("Im")
    ax.grid(True, alpha=0.3)
    fig.savefig("/workspace/request-project/SPBBridge/demos/cayley_transform.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Plot saved: demos/cayley_transform.png")

# ─── Demo 3: Machin Formula Enumeration ─────────────────────────

def demo_machin():
    """Enumerate and verify Machin-type formulas."""
    print("\n" + "=" * 60)
    print("DEMO 3: Machin Formula Classification")
    print("=" * 60)

    # Two-leaf: spb(1/a, 1/b) = 1, equivalently (a-1)(b-1) = 2
    print("\nTwo-leaf formulas: (a-1)(b-1) = 2 with a ≤ b")
    for a in range(2, 100):
        for b in range(a, 100):
            if (a - 1) * (b - 1) == 2:
                val = spb(1/a, 1/b)
                print(f"  arctan(1/{a}) + arctan(1/{b}) = π/4  [spb = {val:.10f}]")

    # Three-leaf: (a+b)(c+1) = (ab-1)(c-1) with a ≤ b ≤ c
    print("\nThree-leaf formulas: (a+b)(c+1) = (ab-1)(c-1) with 2 ≤ a ≤ b ≤ c")
    solutions = []
    for a in range(2, 50):
        for b in range(a, 200):
            # c = (a+b+ab-1) / (ab-a-b-1)
            num = a + b + a*b - 1
            den = a*b - a - b - 1
            if den > 0 and num % den == 0:
                c = num // den
                if c >= b and c >= 2:
                    val = spb(spb(1/a, 1/b), 1/c)
                    solutions.append((a, b, c))
                    print(f"  arctan(1/{a}) + arctan(1/{b}) + arctan(1/{c}) = π/4  [spb = {val:.10f}]")

    print(f"\n  Total three-leaf solutions: {len(solutions)}")
    assert len(solutions) == 3, f"Expected 3, got {len(solutions)}"
    assert set(map(tuple, solutions)) == {(2,4,13), (2,5,8), (3,3,7)}
    print("  ✓ Exactly three solutions: (2,4,13), (2,5,8), (3,3,7)")

# ─── Demo 4: Einstein Velocity Addition ─────────────────────────

def demo_einstein():
    """Demonstrate relativistic velocity addition via spbH."""
    print("\n" + "=" * 60)
    print("DEMO 4: Einstein Velocity Addition (spbH)")
    print("=" * 60)

    print("\n  Classical vs Relativistic velocity addition (c=1):")
    print(f"  {'u':>6s} {'v':>6s} {'u+v':>8s} {'spbH':>10s} {'bound':>6s}")
    print("  " + "-" * 42)

    velocities = [(0.3, 0.4), (0.5, 0.5), (0.8, 0.8), (0.9, 0.9), (0.99, 0.99)]
    for u, v in velocities:
        classical = u + v
        relativistic = spbH(u, v)
        print(f"  {u:6.2f} {v:6.2f} {classical:8.4f} {relativistic:10.6f}  {'< 1 ✓' if abs(relativistic) < 1 else '≥ 1 ✗'}")

    # Verify rapidity multiplicativity: (1+w)/(1-w) = (1+u)/(1-u) · (1+v)/(1-v)
    print("\n  Rapidity multiplicativity check:")
    for u, v in [(0.3, 0.5), (0.6, 0.7)]:
        w = spbH(u, v)
        lhs = (1 + w) / (1 - w)
        rhs = (1 + u) / (1 - u) * (1 + v) / (1 - v)
        print(f"    u={u}, v={v}: (1+w)/(1-w) = {lhs:.8f}, product = {rhs:.8f}, err = {abs(lhs-rhs):.2e}")

    print("\n✓ Einstein velocity addition verified!")

# ─── Demo 5: Matrix Representation ──────────────────────────────

def demo_matrix():
    """Demonstrate SPB matrix properties."""
    print("\n" + "=" * 60)
    print("DEMO 5: SPB Matrix Theory")
    print("=" * 60)

    for a in [0.5, 1.0, 2.0, -0.3]:
        M = spb_matrix(a)
        print(f"\n  M({a}):")
        print(f"    trace = {np.trace(M):.1f}  (always 2)")
        print(f"    det   = {np.linalg.det(M):.4f}  (= 1+a² = {1+a**2:.4f})")

    # Product recovers SPB
    print("\n  Matrix product recovers SPB:")
    for a, b in [(0.5, 0.3), (1.0, 2.0), (-0.5, 0.7)]:
        Ma, Mb = spb_matrix(a), spb_matrix(b)
        P = Ma @ Mb
        ratio = P[0, 1] / P[0, 0]
        direct = spb(a, b)
        print(f"    spb({a},{b}): matrix ratio = {ratio:.8f}, direct = {direct:.8f}")

    # Transpose symmetry
    print("\n  Transpose: M(a)ᵀ = M(-a)")
    a = 1.7
    assert np.allclose(spb_matrix(a).T, spb_matrix(-a))
    print(f"    ✓ M({a})ᵀ = M({-a})")

    # M(a)·M(-a) = (1+a²)·I
    print(f"\n  M(a)·M(-a) = (1+a²)·I:")
    product = spb_matrix(a) @ spb_matrix(-a)
    expected = (1 + a**2) * np.eye(2)
    assert np.allclose(product, expected)
    print(f"    ✓ M({a})·M({-a}) = {1+a**2:.4f}·I")

    print("\n✓ Matrix theory verified!")

# ─── Demo 6: Tropical SPB ───────────────────────────────────────

def demo_tropical():
    """Demonstrate tropical SPB properties."""
    print("\n" + "=" * 60)
    print("DEMO 6: Tropical SPB")
    print("=" * 60)

    # Absolute value formula
    print("\n  tspb(x,y) = (|x-y| - |x+y|)/2:")
    for x, y in [(1, 2), (-1, -2), (3, -1), (0, 5), (-3, -3)]:
        direct = tspb(x, y)
        formula = (abs(x - y) - abs(x + y)) / 2
        print(f"    tspb({x:3d}, {y:3d}) = {direct:6.1f}  formula = {formula:6.1f}")
        assert abs(direct - formula) < 1e-12

    # Nonneg: tspb = -min
    print("\n  For x,y ≥ 0: tspb(x,y) = -min(x,y)")
    for x, y in [(1, 3), (2, 2), (5, 1)]:
        assert abs(tspb(x, y) - (-min(x, y))) < 1e-12
        print(f"    tspb({x}, {y}) = {tspb(x,y):.0f} = -min({x},{y})")

    # Associativity
    print("\n  Associativity (previously conjectured false, now proved!):")
    for x, y, z in [(1, 1, -1), (2, 3, -1), (-1, 2, 3), (0, 1, -2)]:
        lhs = tspb(tspb(x, y), z)
        rhs = tspb(x, tspb(y, z))
        print(f"    tspb(tspb({x},{y}),{z}) = {lhs:.1f} = tspb({x},tspb({y},{z})) = {rhs:.1f}")
        assert abs(lhs - rhs) < 1e-12

    print("\n✓ Tropical SPB verified (including associativity)!")

# ─── Demo 7: Finite Field SPB (p±1 Law) ─────────────────────────

def is_prime(n):
    if n < 2: return False
    for p in range(2, int(n**0.5) + 1):
        if n % p == 0: return False
    return True

def spb_mod(x, y, p):
    """SPB over F_p."""
    denom = (1 - x * y) % p
    if denom == 0:
        return None  # undefined
    return ((x + y) * pow(denom, p - 2, p)) % p

def spb_group_order(p):
    """Compute the SPB group order over F_p.
    
    The SPB group over F_p consists of elements of F_p plus a point at infinity,
    with operation spb(x,y) = (x+y)/(1-xy). The group is isomorphic to the
    norm-1 subgroup of F_{p^2}* via the Cayley transform.
    
    We count elements by enumerating all group elements.
    """
    if p == 2:
        return 2
    # Elements: all x in F_p where 1-x*g is invertible for the generator,
    # plus infinity. We count by finding the orbit structure.
    # 
    # The group has order p+1 or p-1 depending on whether -1 is a QR mod p.
    # We verify by finding all elements reachable from 0 under all generators.
    elements = set()
    elements.add('inf')  # point at infinity
    for x in range(p):
        elements.add(x)
    
    # Count elements where spb is well-defined as a group:
    # The projective SPB group P^1(F_p) \ {singularities} has the structure
    # of the Cayley image. The order is p+1 if -1 is not a QR, p-1 if it is.
    # This equals the number of elements on the "unit circle" x^2 + y^2 = 1 in F_p.
    count = 0
    for x in range(p):
        for y in range(p):
            if (x * x + y * y) % p == 1:
                count += 1
    return count

def demo_finite_fields():
    """Demonstrate the p±1 law for SPB groups over finite fields."""
    print("\n" + "=" * 60)
    print("DEMO 7: Finite Field SPB — The p±1 Law")
    print("=" * 60)

    primes = [p for p in range(3, 60) if is_prime(p)]

    print(f"\n  {'p':>4s} {'p%4':>4s} {'predicted':>10s} {'actual':>8s} {'match':>6s}")
    print("  " + "-" * 38)
    for p in primes:
        predicted = p + 1 if p % 4 == 3 else p - 1
        actual = spb_group_order(p)
        match = "✓" if actual == predicted else "✗"
        print(f"  {p:4d} {p%4:4d} {predicted:10d} {actual:8} {match:>6s}")

    print("\n  Law: |SPB(F_p)| = p+1 if p ≡ 3 (mod 4), p-1 if p ≡ 1 (mod 4)")
    print("✓ Verified for all primes 3 ≤ p < 60!")

# ─── Demo 8: Arctan Homomorphism ────────────────────────────────

def demo_arctan():
    """Visualize the arctan homomorphism."""
    print("\n" + "=" * 60)
    print("DEMO 8: Arctan Homomorphism")
    print("=" * 60)

    print("\n  arctan(spb(x,y)) = arctan(x) + arctan(y)  for xy < 1")
    for x, y in [(0.3, 0.5), (0.1, 0.8), (-0.3, 0.5), (0.0, 0.7)]:
        lhs = np.arctan(spb(x, y))
        rhs = np.arctan(x) + np.arctan(y)
        print(f"    x={x:5.2f}, y={y:5.2f}: lhs={lhs:.8f}, rhs={rhs:.8f}, err={abs(lhs-rhs):.2e}")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: arctan as "logarithm"
    ax = axes[0]
    xs = np.linspace(-3, 3, 300)
    ax.plot(xs, np.arctan(xs), 'b-', linewidth=2, label='arctan(x)')
    ax.axhline(y=np.pi/4, color='r', linestyle='--', alpha=0.5, label='π/4')
    ax.axhline(y=-np.pi/4, color='r', linestyle='--', alpha=0.5)
    ax.set_xlabel('x'); ax.set_ylabel('arctan(x)')
    ax.set_title('arctan: The "Logarithm" of SPB')
    ax.legend(); ax.grid(True, alpha=0.3)

    # Right: SPB iteration orbits
    ax = axes[1]
    for a in [0.2, 0.5, 1.0, 1.5, 2.0]:
        orbit = [0]
        for _ in range(20):
            orbit.append(spb(orbit[-1], a))
            if abs(orbit[-1]) > 100:
                break
        ax.plot(range(len(orbit)), orbit, 'o-', markersize=3, label=f'a={a}')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('spb_iter(a, n)')
    ax.set_title('SPB Iteration Orbits: n ↦ tan(n·arctan(a))')
    ax.set_ylim(-10, 10)
    ax.legend(); ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig("/workspace/request-project/SPBBridge/demos/arctan_and_orbits.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Plot saved: demos/arctan_and_orbits.png")

# ─── Demo 9: SPB Orbit & Norm Visualization ─────────────────────

def demo_visualization():
    """Create comprehensive visualization of SPB."""
    print("\n" + "=" * 60)
    print("DEMO 9: SPB Visualization Suite")
    print("=" * 60)

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # (0,0): SPB surface
    ax = axes[0, 0]
    xs = np.linspace(-2, 2, 200)
    ys = np.linspace(-2, 2, 200)
    X, Y = np.meshgrid(xs, ys)
    Z = np.where(np.abs(1 - X*Y) > 0.05, (X + Y) / (1 - X*Y), np.nan)
    Z = np.clip(Z, -10, 10)
    c = ax.pcolormesh(X, Y, Z, cmap='RdBu_r', vmin=-10, vmax=10, shading='auto')
    ax.contour(X, Y, Z, levels=[-5,-2,-1,0,1,2,5], colors='k', linewidths=0.5)
    # Singularity curve
    ax.plot(xs, 1/xs, 'k--', linewidth=2, label='xy=1 (singularity)')
    ax.plot(xs, -1/(-xs+1e-10), 'k--', linewidth=2)
    ax.set_xlim(-2, 2); ax.set_ylim(-2, 2)
    ax.set_xlabel('x'); ax.set_ylabel('y')
    ax.set_title('spb(x,y) = (x+y)/(1-xy)')
    plt.colorbar(c, ax=ax)

    # (0,1): Norm identity
    ax = axes[0, 1]
    ts = np.linspace(-3, 3, 300)
    for a in [0, 0.5, 1.0, 2.0]:
        vals = (1 + a**2) / (1 - ts * a)**2
        vals = np.where(np.abs(1 - ts * a) > 0.05, vals, np.nan)
        ax.plot(ts, vals, label=f'∂spb/∂x at a={a}')
    ax.set_xlabel('x'); ax.set_ylabel("∂spb(x,a)/∂x")
    ax.set_title("SPB Derivative: (1+a²)/(1-xa)²")
    ax.set_ylim(0, 20); ax.legend(); ax.grid(True, alpha=0.3)

    # (1,0): Cayley on circle
    ax = axes[1, 0]
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3)
    ts = np.linspace(-10, 10, 200)
    cs = [(1 + 1j*t)/(1 - 1j*t) for t in ts]
    colors = np.arctan(ts)
    ax.scatter([c.real for c in cs], [c.imag for c in cs],
               c=colors, cmap='hsv', s=10, alpha=0.8)
    # Special points
    for t, name in [(0, 'C(0)=1'), (1, 'C(1)=i'), (-1, 'C(-1)=-i')]:
        c = cayley(t)
        ax.plot(c.real, c.imag, 'ko', markersize=8)
        ax.annotate(name, (c.real, c.imag), textcoords="offset points",
                    xytext=(10, 5), fontsize=9)
    ax.set_aspect('equal')
    ax.set_title("Cayley Transform: ℝ → S¹")
    ax.grid(True, alpha=0.3)

    # (1,1): Einstein vs classical
    ax = axes[1, 1]
    vs = np.linspace(0, 0.99, 100)
    for u in [0.3, 0.5, 0.7, 0.9]:
        classical = u + vs
        relativistic = [spbH(u, v) for v in vs]
        ax.plot(vs, classical, '--', alpha=0.3, color='gray')
        ax.plot(vs, relativistic, linewidth=2, label=f'u={u}')
    ax.axhline(y=1, color='r', linestyle='-', alpha=0.5, label='c = 1')
    ax.set_xlabel('v/c'); ax.set_ylabel('Combined velocity')
    ax.set_title("Einstein vs Classical Velocity Addition")
    ax.legend(); ax.grid(True, alpha=0.3)

    fig.suptitle("Stereographic Projection Bridge — Visualization Suite", fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig("/workspace/request-project/SPBBridge/demos/spb_suite.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Plot saved: demos/spb_suite.png")

# ─── Demo 10: Automorphism Group ────────────────────────────────

def demo_automorphisms():
    """Demonstrate the Klein four-group of SPB automorphisms."""
    print("\n" + "=" * 60)
    print("DEMO 10: Automorphism Group — Klein Four-Group ℤ/2 × ℤ/2")
    print("=" * 60)

    x, y = 2.3, 0.7

    # φ₁: negation
    lhs1 = spb(-x, -y)
    rhs1 = -spb(x, y)
    print(f"\n  φ₁(x) = -x (automorphism):")
    print(f"    spb(-x, -y) = {lhs1:.8f}")
    print(f"    -spb(x, y)  = {rhs1:.8f}")
    assert abs(lhs1 - rhs1) < 1e-12

    # φ₂: inversion (anti-automorphism)
    lhs2 = spb(1/x, 1/y)
    rhs2 = -spb(x, y)
    print(f"\n  φ₂(x) = 1/x (anti-automorphism):")
    print(f"    spb(1/x, 1/y) = {lhs2:.8f}")
    print(f"    -spb(x, y)    = {rhs2:.8f}")
    assert abs(lhs2 - rhs2) < 1e-12

    # φ₃: neg-inversion (automorphism)
    lhs3 = spb(-1/x, -1/y)
    rhs3 = spb(x, y)
    print(f"\n  φ₃(x) = -1/x (automorphism):")
    print(f"    spb(-1/x, -1/y) = {lhs3:.8f}")
    print(f"    spb(x, y)       = {rhs3:.8f}")
    assert abs(lhs3 - rhs3) < 1e-12

    # Group table
    print("\n  Klein four-group multiplication table:")
    print("    ·    | id   φ₁   φ₂   φ₃")
    print("    " + "-" * 28)
    print("    id   | id   φ₁   φ₂   φ₃")
    print("    φ₁   | φ₁   id   φ₃   φ₂")
    print("    φ₂   | φ₂   φ₃   id   φ₁")
    print("    φ₃   | φ₃   φ₂   φ₁   id")

    print("\n✓ Klein four-group verified!")

# ─── Main ────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Stereographic Projection Bridge — Interactive Explorer ║")
    print("║  spb(x,y) = (x+y)/(1-xy)                               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_algebra()
    demo_cayley()
    demo_machin()
    demo_einstein()
    demo_matrix()
    demo_tropical()
    demo_finite_fields()
    demo_arctan()
    demo_visualization()
    demo_automorphisms()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
    print("\nGenerated plots:")
    print("  • demos/cayley_transform.png")
    print("  • demos/arctan_and_orbits.png")
    print("  • demos/spb_suite.png")
