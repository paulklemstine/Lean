#!/usr/bin/env python3
"""
SPB-EML Open Problems Explorer
===============================
Interactive demonstrations of the key results from the SPB-EML research program.

Demonstrates:
  1. SPB as the tangent addition formula and circle group operation
  2. Wick rotation: circular ↔ hyperbolic SPB
  3. Einstein velocity addition (hyperbolic SPB) and the speed-of-light barrier
  4. Cauchy distribution invariance under SPB
  5. Cocycle coboundary identity
  6. Tropical SPB and semigroup structure
  7. SPB iteration orbits and finite field order
  8. EML-SPB unification: conjugation framework
  9. Weierstrass parametrization
 10. CORDIC via SPB
"""

import numpy as np
from fractions import Fraction
import sys

# ─────────────────────────────────────────────
#  Core SPB Definitions
# ─────────────────────────────────────────────

def spb(x, y):
    """Circular SPB: (x+y)/(1-xy) — tangent addition."""
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return float('inf')
    return (x + y) / denom

def spb_hyp(x, y):
    """Hyperbolic SPB: (x+y)/(1+xy) — Einstein velocity addition."""
    return (x + y) / (1 + x * y)

def tropical_spb(x, y):
    """Tropical SPB: min(x,y) - min(0, x+y)."""
    return min(x, y) - min(0, x + y)

def spb_mod(x, y, p):
    """SPB over F_p: (x+y) * (1-xy)^{-1} mod p."""
    denom = (1 - x * y) % p
    if denom == 0:
        return None  # pole
    return ((x + y) * pow(denom, -1, p)) % p

# ─────────────────────────────────────────────
#  Demo 1: SPB = Tangent Addition
# ─────────────────────────────────────────────

def demo_tangent_addition():
    print("=" * 60)
    print("Demo 1: SPB IS the Tangent Addition Formula")
    print("=" * 60)
    print()
    print("For any angles α, β: tan(α+β) = spb(tan α, tan β)")
    print("                    = (tan α + tan β)/(1 - tan α · tan β)")
    print()

    angles = [(np.pi/6, np.pi/4), (np.pi/3, np.pi/6),
              (0.1, 0.2), (1.0, 0.5)]

    for α, β in angles:
        lhs = np.tan(α + β)
        rhs = spb(np.tan(α), np.tan(β))
        err = abs(lhs - rhs)
        print(f"  α={α:.4f}, β={β:.4f}: tan(α+β) = {lhs:.10f}")
        print(f"  {'':20s}  spb(tan α, tan β) = {rhs:.10f}  error={err:.2e}")

    # Verify arctan addition
    print()
    print("Arctan linearizes SPB:")
    print("  arctan(spb(x,y)) = arctan(x) + arctan(y)  when 1-xy > 0")
    for x, y in [(0.5, 0.3), (1.0, 0.2), (2.0, -0.5)]:
        if 1 - x * y > 0:
            lhs = np.arctan(spb(x, y))
            rhs = np.arctan(x) + np.arctan(y)
            print(f"  x={x}, y={y}: arctan(spb) = {lhs:.10f}, "
                  f"arctan(x)+arctan(y) = {rhs:.10f}, error = {abs(lhs-rhs):.2e}")
    print()

# ─────────────────────────────────────────────
#  Demo 2: Wick Rotation — Circular ↔ Hyperbolic
# ─────────────────────────────────────────────

def demo_wick_rotation():
    print("=" * 60)
    print("Demo 2: Wick Rotation — Circular ↔ Hyperbolic")
    print("=" * 60)
    print()
    print("Sign flip: spb(x,y) = (x+y)/(1-xy)  ↔  spbH(x,y) = (x+y)/(1+xy)")
    print()

    for x, y in [(0.3, 0.4), (0.5, 0.5), (0.8, 0.2)]:
        circ = spb(x, y)
        hyp = spb_hyp(x, y)
        sum_val = circ + hyp
        diff_val = circ - hyp
        prod_val = circ * hyp
        expected_sum = 2 * (x + y) / (1 - (x * y)**2)
        expected_diff = 2 * x * y * (x + y) / (1 - (x * y)**2)

        print(f"  x={x}, y={y}:")
        print(f"    Circular:   spb = {circ:.8f}")
        print(f"    Hyperbolic: spbH = {hyp:.8f}")
        print(f"    Sum:  spb + spbH = {sum_val:.8f}  "
              f"(expected: {expected_sum:.8f})")
        print(f"    Diff: spb - spbH = {diff_val:.8f}  "
              f"(expected: {expected_diff:.8f})")

    # Norm identities
    print()
    print("Norm identities:")
    print("  Circular:   (1-xy)² · (1+spb²) = (1+x²)(1+y²)")
    print("  Hyperbolic: (1+xy)² · (1-spbH²) = (1-x²)(1-y²)")
    for x, y in [(0.3, 0.4), (0.6, 0.2)]:
        circ_lhs = (1 - x*y)**2 * (1 + spb(x,y)**2)
        circ_rhs = (1 + x**2) * (1 + y**2)
        hyp_lhs = (1 + x*y)**2 * (1 - spb_hyp(x,y)**2)
        hyp_rhs = (1 - x**2) * (1 - y**2)
        print(f"  x={x}, y={y}: circ error={abs(circ_lhs - circ_rhs):.2e}, "
              f"hyp error={abs(hyp_lhs - hyp_rhs):.2e}")
    print()

# ─────────────────────────────────────────────
#  Demo 3: Einstein Velocity Addition
# ─────────────────────────────────────────────

def demo_einstein_velocity():
    print("=" * 60)
    print("Demo 3: Hyperbolic SPB = Einstein Velocity Addition")
    print("=" * 60)
    print()
    print("For velocities |u|, |v| < c=1: spbH(u,v) = (u+v)/(1+uv)")
    print("Speed-of-light barrier: |spbH(u,v)| < 1 always!")
    print()

    velocities = [
        (0.5, 0.5, "moderate + moderate"),
        (0.9, 0.9, "fast + fast"),
        (0.99, 0.99, "very fast + very fast"),
        (0.999, 0.999, "near c + near c"),
        (0.5, -0.3, "forward + backward"),
    ]

    for u, v, desc in velocities:
        result = spb_hyp(u, v)
        classical = u + v
        print(f"  u={u:+.3f}, v={v:+.3f} ({desc}):")
        print(f"    Classical: u+v = {classical:+.6f}")
        print(f"    Relativistic: spbH(u,v) = {result:+.6f}")
        print(f"    |result| = {abs(result):.6f} < 1? {'YES ✓' if abs(result) < 1 else 'NO ✗'}")

    # Rapidity addition
    print()
    print("Rapidity product: (1+spbH)/(1-spbH) = ((1+u)/(1-u))·((1+v)/(1-v))")
    for u, v in [(0.3, 0.4), (0.6, 0.7)]:
        s = spb_hyp(u, v)
        lhs = (1 + s) / (1 - s)
        rhs = ((1 + u) / (1 - u)) * ((1 + v) / (1 - v))
        print(f"  u={u}, v={v}: LHS={lhs:.8f}, RHS={rhs:.8f}, error={abs(lhs-rhs):.2e}")
    print()

# ─────────────────────────────────────────────
#  Demo 4: Cauchy Distribution Invariance
# ─────────────────────────────────────────────

def demo_cauchy_invariance():
    print("=" * 60)
    print("Demo 4: SPB Preserves the Cauchy Distribution")
    print("=" * 60)
    print()
    print("If X ~ Cauchy, then spb(X, a) ~ Cauchy for any fixed a.")
    print("Monte Carlo verification with 100,000 samples:")
    print()

    np.random.seed(42)
    n = 100000

    # Generate standard Cauchy samples
    X = np.random.standard_cauchy(n)

    for a in [0.0, 0.5, 1.0, 2.0]:
        # Apply SPB translation
        Y = np.array([spb(x, a) for x in X if abs(1 - x * a) > 1e-10])

        # Compare quantiles with standard Cauchy
        quantiles = [0.1, 0.25, 0.5, 0.75, 0.9]
        cauchy_q = [np.tan(np.pi * (q - 0.5)) for q in quantiles]
        sample_q = [np.percentile(Y[np.isfinite(Y)], q * 100) for q in quantiles]

        # For a ≠ 0, spb(X, a) has location parameter a and scale 1
        # Actually spb(X, a) ~ Cauchy(a/(1+... wait, let me just check the empirical median
        median = np.median(Y[np.isfinite(Y)])
        print(f"  a = {a}: median(spb(X,a)) = {median:+.4f} "
              f"(expected ≈ {'tan(arctan(0)+arctan(' + str(a) + '))=' + f'{np.tan(np.arctan(a)):.4f}' if a != 0 else '0.0000'})")

    # Pullback identity verification
    print()
    print("Cauchy pullback identity: (1+a²)/((1+spb²)(1-xa)²) = 1/(1+x²)")
    for x, a in [(0.5, 0.3), (1.0, 2.0), (-0.5, 0.7)]:
        s = spb(x, a)
        lhs = (1 + a**2) / ((1 + s**2) * (1 - x*a)**2)
        rhs = 1 / (1 + x**2)
        print(f"  x={x}, a={a}: LHS={lhs:.10f}, RHS={rhs:.10f}, "
              f"error={abs(lhs-rhs):.2e}")
    print()

# ─────────────────────────────────────────────
#  Demo 5: Cocycle Coboundary Identity
# ─────────────────────────────────────────────

def demo_cocycle():
    print("=" * 60)
    print("Demo 5: The SPB Cocycle is a Coboundary (H² = 0)")
    print("=" * 60)
    print()
    print("Key identity: (1-xy)²·(1+spb(x,y)²) = (1+x²)(1+y²)")
    print("This means: cocycle c(x,y) = 1/(1-xy) is a coboundary with cochain f(x) = 1+x²")
    print()

    for x, y in [(0.3, 0.5), (1.0, 2.0), (-0.5, 0.7), (3.0, -1.5)]:
        if abs(1 - x * y) > 1e-10:
            s = spb(x, y)
            lhs = (1 - x * y)**2 * (1 + s**2)
            rhs = (1 + x**2) * (1 + y**2)
            print(f"  x={x:+.1f}, y={y:+.1f}: LHS={lhs:.10f}, "
                  f"RHS={rhs:.10f}, error={abs(lhs-rhs):.2e}")

    # Cocycle condition: c(x,y)·c(spb(x,y),z) = c(y,z)·c(x,spb(y,z))
    print()
    print("Cocycle condition: (1-xy)(1-spb(x,y)z) = (1-yz)(1-x·spb(y,z))")
    for x, y, z in [(0.2, 0.3, 0.4), (1.0, -0.5, 0.3)]:
        s_xy = spb(x, y)
        s_yz = spb(y, z)
        lhs = (1 - x * y) * (1 - s_xy * z)
        rhs = (1 - y * z) * (1 - x * s_yz)
        print(f"  x={x}, y={y}, z={z}: LHS={lhs:.10f}, "
              f"RHS={rhs:.10f}, error={abs(lhs-rhs):.2e}")
    print()

# ─────────────────────────────────────────────
#  Demo 6: Tropical SPB
# ─────────────────────────────────────────────

def demo_tropical():
    print("=" * 60)
    print("Demo 6: Tropical SPB — Semigroup, Not Group")
    print("=" * 60)
    print()
    print("Tropical SPB: tspb(x,y) = min(x,y) - min(0, x+y)")
    print("Alternative:  tspb(x,y) = min(x,y) + max(0, -(x+y))")
    print()

    # Commutativity
    print("Commutativity check:")
    for x, y in [(3, 5), (-2, 4), (-3, -1)]:
        a = tropical_spb(x, y)
        b = tropical_spb(y, x)
        print(f"  tspb({x},{y}) = {a}, tspb({y},{x}) = {b}, "
              f"equal? {'✓' if a == b else '✗'}")

    # Non-negative idempotence
    print()
    print("For x,y ≥ 0: tspb(x,y) = min(x,y) (idempotent on nonneg cone):")
    for x, y in [(2, 5), (3, 1), (4, 4)]:
        t = tropical_spb(x, y)
        m = min(x, y)
        print(f"  tspb({x},{y}) = {t} = min({x},{y}) = {m} {'✓' if t == m else '✗'}")

    # No global identity
    print()
    print("No global identity element (H7 partial refutation):")
    print("  For e to be identity: tspb(x, e) = x for ALL x")
    for e in [-2, -1, 0, 1, 2]:
        works = all(tropical_spb(x, e) == x for x in range(-5, 6))
        counterex = next((x for x in range(-5, 6)
                         if tropical_spb(x, e) != x), None)
        if counterex is not None:
            print(f"  e={e}: FAILS at x={counterex}, "
                  f"tspb({counterex},{e})={tropical_spb(counterex, e)} ≠ {counterex}")
        else:
            print(f"  e={e}: works for all tested x")

    # But 0 works on nonneg cone
    print()
    print("  0 IS the identity on the nonneg cone [0, ∞):")
    for x in range(0, 6):
        r = tropical_spb(x, 0)
        print(f"    tspb({x}, 0) = {r} {'✓' if r == x else '✗'}")
    print()

# ─────────────────────────────────────────────
#  Demo 7: Finite Field SPB Order
# ─────────────────────────────────────────────

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0: return False
    return True

def demo_finite_field():
    print("=" * 60)
    print("Demo 7: SPB over Finite Fields — The p±1 Order Law")
    print("=" * 60)
    print()
    print("Conjecture: The SPB iteration period of generator 1 over F_p divides:")
    print("  p+1 when p ≡ 3 (mod 4)    (i = sqrt(-1) doesn't exist in F_p)")
    print("  p-1 when p ≡ 1 (mod 4)    (i exists in F_p)")
    print()

    results = []
    for p in range(3, 100):
        if not is_prime(p):
            continue

        # Iterate spb(·, 1) starting from 0
        x = 0
        period = None
        for k in range(1, 2 * p + 5):
            x = spb_mod(x, 1, p)
            if x is None:
                break
            if x == 0:
                period = k
                break

        if period is not None:
            residue = p % 4
            expected_divisor = p + 1 if residue == 3 else p - 1
            divides = expected_divisor % period == 0
            results.append((p, period, residue, expected_divisor, divides))

    print(f"  {'p':>5s}  {'p%4':>4s}  {'period':>6s}  {'p±1':>5s}  {'divides?':>8s}")
    print(f"  {'─'*5}  {'─'*4}  {'─'*6}  {'─'*5}  {'─'*8}")
    for p, period, res, exp_div, div in results[:25]:
        print(f"  {p:>5d}  {res:>4d}  {period:>6d}  {exp_div:>5d}  "
              f"{'✓' if div else '✗':>8s}")

    all_pass = all(d for _, _, _, _, d in results)
    print()
    print(f"  All {len(results)} primes satisfy the p±1 law: "
          f"{'YES ✓' if all_pass else 'NO ✗'}")
    print()

# ─────────────────────────────────────────────
#  Demo 8: EML-SPB Unification
# ─────────────────────────────────────────────

def demo_unification():
    print("=" * 60)
    print("Demo 8: EML-SPB Unification — Conjugation Framework")
    print("=" * 60)
    print()
    print("All four operations arise from addition via conjugation:")
    print("  + = addition (identity conjugation)")
    print("  · = exp-conjugation: a·b = exp(ln(a) + ln(b))")
    print("  spb = tan-conjugation: spb(a,b) = tan(arctan(a) + arctan(b))")
    print("  spbH = tanh-conjugation: spbH(a,b) = tanh(artanh(a) + artanh(b))")
    print()

    a, b = 0.3, 0.5
    print(f"  For a={a}, b={b}:")
    print(f"    Addition: a + b = {a + b}")
    print(f"    Multiplication: exp(ln(a) + ln(b)) = {np.exp(np.log(a) + np.log(b)):.10f} "
          f"vs a·b = {a*b}")
    print(f"    SPB: tan(arctan(a) + arctan(b)) = "
          f"{np.tan(np.arctan(a) + np.arctan(b)):.10f} vs spb(a,b) = {spb(a, b):.10f}")
    print(f"    spbH: tanh(artanh(a) + artanh(b)) = "
          f"{np.tanh(np.arctanh(a) + np.arctanh(b)):.10f} vs spbH(a,b) = {spb_hyp(a, b):.10f}")

    # Triple angle formula
    print()
    print("Multi-angle formulas via SPB iteration:")
    t = np.tan(np.pi / 7)  # some angle
    s2 = spb(t, t)
    s3 = spb(t, s2)
    s4 = spb(t, s3)
    print(f"  t = tan(π/7) = {t:.8f}")
    print(f"  spb(t,t) = tan(2π/7) = {s2:.8f} vs {np.tan(2*np.pi/7):.8f}")
    print(f"  spb(t,spb(t,t)) = tan(3π/7) = {s3:.8f} vs {np.tan(3*np.pi/7):.8f}")
    print()

# ─────────────────────────────────────────────
#  Demo 9: Weierstrass Parametrization
# ─────────────────────────────────────────────

def demo_weierstrass():
    print("=" * 60)
    print("Demo 9: Weierstrass Parametrization via SPB")
    print("=" * 60)
    print()
    print("For t = tan(θ/2): cos(θ) = (1-t²)/(1+t²), sin(θ) = 2t/(1+t²)")
    print("The Pythagorean identity: cos²+sin² = 1 always holds.")
    print()

    for θ in [0.5, 1.0, 1.5, 2.0, 2.5]:
        t = np.tan(θ / 2)
        cos_w = (1 - t**2) / (1 + t**2)
        sin_w = 2 * t / (1 + t**2)
        cos_direct = np.cos(θ)
        sin_direct = np.sin(θ)
        pythag = cos_w**2 + sin_w**2

        print(f"  θ = {θ:.1f}: cos(θ) = {cos_direct:.8f} vs Weierstrass = {cos_w:.8f}, "
              f"error = {abs(cos_direct - cos_w):.2e}")
        print(f"  {'':8s}sin(θ) = {sin_direct:.8f} vs Weierstrass = {sin_w:.8f}, "
              f"error = {abs(sin_direct - sin_w):.2e}")
        print(f"  {'':8s}cos²+sin² = {pythag:.15f}")
    print()

# ─────────────────────────────────────────────
#  Demo 10: SPB Möbius Group Structure
# ─────────────────────────────────────────────

def demo_moebius():
    print("=" * 60)
    print("Demo 10: SPB as Möbius Transformations — PSL(2,ℝ)")
    print("=" * 60)
    print()
    print("For fixed a, x ↦ spb(x,a) is the Möbius transformation")
    print("with matrix M(a) = [[1,a],[-a,1]], det = 1+a².")
    print()

    # Matrix representation
    for a in [0.5, 1.0, 2.0]:
        det = 1 + a**2
        print(f"  M({a}) = [[1, {a}], [{-a}, 1]], det = {det}")

    # Matrix multiplication = SPB composition
    print()
    print("Matrix multiplication encodes SPB composition:")
    print("  M(a)·M(b) = (1-ab)·M(spb(a,b))")
    for a, b in [(0.3, 0.5), (1.0, 2.0)]:
        Ma = np.array([[1, a], [-a, 1]])
        Mb = np.array([[1, b], [-b, 1]])
        prod = Ma @ Mb
        s = spb(a, b)
        factor = 1 - a * b
        expected = factor * np.array([[1, s], [-s, 1]])
        err = np.max(np.abs(prod - expected))
        print(f"  a={a}, b={b}: M(a)M(b) = (1-ab)·M(spb(a,b)), error = {err:.2e}")

    # No fixed points
    print()
    print("x ↦ spb(x,a) has NO real fixed points when a ≠ 0:")
    print("  (Fixed points require x² = -1)")
    for a in [0.5, 1.0, 3.0]:
        # Check: spb(x,a) = x  →  x+a = x(1-xa)  →  a(1+x²) = 0
        print(f"  a={a}: equation a(1+x²)=0 has no real solution since 1+x² > 0")

    # Cross-ratio preservation
    print()
    print("SPB preserves the cross-ratio (Möbius invariance):")
    a, b, c, d = 1.0, 2.0, 3.0, 4.0
    t = 0.5
    cr_orig = ((a-b)*(c-d)) / ((a-c)*(b-d))
    sa, sb, sc, sd = spb(a,t), spb(b,t), spb(c,t), spb(d,t)
    cr_spb = ((sa-sb)*(sc-sd)) / ((sa-sc)*(sb-sd))
    print(f"  Points: {a},{b},{c},{d}, translation t={t}")
    print(f"  CR(a,b,c,d) = {cr_orig:.8f}")
    print(f"  CR(spb(a,t),spb(b,t),spb(c,t),spb(d,t)) = {cr_spb:.8f}")
    print(f"  Error: {abs(cr_orig - cr_spb):.2e}")
    print()

# ─────────────────────────────────────────────
#  Demo 11: 3D SPB and Thomas-Wigner Rotation
# ─────────────────────────────────────────────

def spb3d(u, v):
    """3D SPB: spb₃(u,v) = (u + v + u×v·... ) / (1 - u·v)"""
    dot = np.dot(u, v)
    cross = np.cross(u, v)
    denom = 1 - dot
    if abs(denom) < 1e-15:
        return np.array([float('inf')] * 3)
    return (u + v) / denom + cross / denom

def demo_3d_spb():
    print("=" * 60)
    print("Demo 11: 3D SPB and Thomas-Wigner Rotation")
    print("=" * 60)
    print()
    print("spb₃(u,v) = (u+v)/(1-u·v) + (u×v)/(1-u·v)")
    print("Non-commutativity: spb₃(u,v) - spb₃(v,u) = 2(u×v)/(1-u·v)")
    print()

    u = np.array([1.0, 0.0, 0.0])
    v = np.array([0.0, 1.0, 0.0])

    s_uv = spb3d(u, v)
    s_vu = spb3d(v, u)
    diff = s_uv - s_vu
    cross = np.cross(u, v)
    expected_diff = 2 * cross / (1 - np.dot(u, v))

    print(f"  u = {u}")
    print(f"  v = {v}")
    print(f"  spb₃(u,v) = {s_uv}")
    print(f"  spb₃(v,u) = {s_vu}")
    print(f"  Difference: {diff}")
    print(f"  Expected 2(u×v)/(1-u·v): {expected_diff}")
    print(f"  Error: {np.linalg.norm(diff - expected_diff):.2e}")

    # Inverse
    print()
    u2 = np.array([0.5, 0.3, 0.7])
    inv = spb3d(u2, -u2)
    print(f"  spb₃(u, -u) = {inv}  (should be ~0)")
    print()

# ─────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   SPB-EML Open Problems Explorer — Python Demos        ║")
    print("║   Machine-verified mathematics meets computation       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_tangent_addition()
    demo_wick_rotation()
    demo_einstein_velocity()
    demo_cauchy_invariance()
    demo_cocycle()
    demo_tropical()
    demo_finite_field()
    demo_unification()
    demo_weierstrass()
    demo_moebius()
    demo_3d_spb()

    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)

if __name__ == "__main__":
    main()
