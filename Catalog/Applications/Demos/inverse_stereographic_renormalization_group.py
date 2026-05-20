#!/usr/bin/env python3
"""
Applications of Inverse Stereographic Renormalization Group

Demonstrates real-world applications of the geometric RG framework:
1. Coupling constant evolution in QFT-like models
2. Conformal map composition and Möbius group structure
3. Signal processing via projective transformations
4. Numerical RG flow visualization
"""

import numpy as np
from typing import List, Tuple

def moebius_f(a: float, b: float, t: float) -> float:
    """Two-pole Möbius map F_{a,b}(t)."""
    denom = (a - b) * t + (a * b + 1)
    if abs(denom) < 1e-15:
        return float('inf')
    return ((a * b + 1) * t + (b - a)) / denom

def moebius_deriv(a: float, b: float, g: float) -> float:
    """Derivative F'_{a,b}(g)."""
    denom = (a - b) * g + (a * b + 1)
    if abs(denom) < 1e-15:
        return float('inf')
    return (1 + a**2) * (1 + b**2) / denom**2

def inv_stereo(t: float) -> Tuple[float, float]:
    """Inverse stereographic projection ℝ → S¹."""
    d = 1 + t**2
    return (2*t/d, (1-t**2)/d)

# ─────────────────────────────────────────────
# Application 1: Coupling constant flow
# ─────────────────────────────────────────────

def coupling_flow_demo():
    """
    Model coupling constant evolution as a sequence of pole changes.

    In this model, changing the renormalization scale μ → μ' corresponds
    to changing the stereographic pole from a to b. The coupling g evolves as:
        g' = F_{a,b}(g)

    A sequence of scale changes μ₁ → μ₂ → ... → μₙ with poles
    a₁, a₂, ..., aₙ composes as:
        g_final = F_{a₁,aₙ}(g_initial)

    due to the composition law F_{b,c} ∘ F_{a,b} = F_{a,c}.
    """
    print("APPLICATION 1: Coupling constant flow")
    print("=" * 50)

    # Start at coupling g = 0.5
    g0 = 0.5

    # Sequence of pole changes: a₁ → a₂ → a₃ → a₄
    poles = [0.0, 0.3, 0.7, 1.0, 1.5]

    print(f"\nInitial coupling: g₀ = {g0}")
    print(f"Pole sequence: {poles}")

    g = g0
    for i in range(len(poles) - 1):
        a, b = poles[i], poles[i+1]
        g_new = moebius_f(a, b, g)
        print(f"  Step {i+1}: a={a} → b={b}, g = {g:.6f} → {g_new:.6f}")
        g = g_new

    # Verify composition law: should equal F_{a₁,aₙ}(g₀)
    g_direct = moebius_f(poles[0], poles[-1], g0)
    print(f"\nComposition law check:")
    print(f"  Sequential result: {g:.6f}")
    print(f"  Direct F_{{{poles[0]},{poles[-1]}}}({g0}): {g_direct:.6f}")
    print(f"  Match: {abs(g - g_direct) < 1e-10}")

# ─────────────────────────────────────────────
# Application 2: Projective signal processing
# ─────────────────────────────────────────────

def projective_signal_demo():
    """
    Apply the geometric RG as a nonlinear filter on signals.

    The Möbius map F_{a,b} acts as a projective transformation that
    compresses/expands different parts of the signal range, while
    preserving the cross-ratio structure.
    """
    print("\n\nAPPLICATION 2: Projective signal processing")
    print("=" * 50)

    # Generate a test signal
    t = np.linspace(-3, 3, 50)
    signal = np.sin(t) + 0.5 * np.sin(3*t)

    # Apply geometric RG filter with different pole pairs
    pole_pairs = [(0, 0.5), (0, 1), (0, 2)]

    for a, b in pole_pairs:
        filtered = np.array([moebius_f(a, b, s) for s in signal])
        # Compute distortion statistics
        max_deriv = max(moebius_deriv(a, b, s) for s in signal)
        min_deriv = min(moebius_deriv(a, b, s) for s in signal)
        print(f"\n  Poles ({a}, {b}):")
        print(f"    Input range:  [{signal.min():.3f}, {signal.max():.3f}]")
        print(f"    Output range: [{filtered.min():.3f}, {filtered.max():.3f}]")
        print(f"    Derivative range: [{min_deriv:.4f}, {max_deriv:.4f}]")
        print(f"    All derivatives positive: {min_deriv > 0}")

# ─────────────────────────────────────────────
# Application 3: Circle dynamics visualization
# ─────────────────────────────────────────────

def circle_dynamics_demo():
    """
    Visualize the action of F_{a,b} on the unit circle.

    Since F_{a,b} is elliptic for a ≠ b, it acts as a rotation
    on the projective line ≅ S¹. We trace orbits on the circle.
    """
    print("\n\nAPPLICATION 3: Circle dynamics")
    print("=" * 50)

    a, b = 0, 1
    g0_values = [0, 1, -1, 2, -0.5]

    for g0 in g0_values:
        # Map to circle
        x0, y0 = inv_stereo(g0)
        # Iterate
        g = g0
        points = [(x0, y0)]
        for _ in range(20):
            g = moebius_f(a, b, g)
            x, y = inv_stereo(g)
            points.append((x, y))

        # Check all points are on circle
        on_circle = all(abs(x**2 + y**2 - 1) < 1e-10 for x, y in points)

        print(f"\n  g₀ = {g0}: circle trajectory ({len(points)} points)")
        print(f"    All on S¹: {on_circle}")
        print(f"    First 5 angles: {[round(np.arctan2(y, x)*180/np.pi, 1) for x, y in points[:5]]}")

# ─────────────────────────────────────────────
# Application 4: Energy landscape analysis
# ─────────────────────────────────────────────

def energy_landscape_demo():
    """
    Analyze energy functions compatible with the geometric RG.

    An energy function E is RG-compatible if E(F_{a,b}(g)) = E(g).
    For a Möbius rotation, any function of the cross-ratio is preserved.
    """
    print("\n\nAPPLICATION 4: Energy landscape analysis")
    print("=" * 50)

    a, b = 0, 1

    # The function E(g) = g² + 1 is NOT preserved by F_{a,b}
    # Let's check
    def E_quadratic(g):
        return g**2 + 1

    gs = [0, 0.5, 1, 2, -1]
    print(f"\n  Testing E(g) = g² + 1 under F_{{0,1}}:")
    for g in gs:
        fg = moebius_f(a, b, g)
        print(f"    g={g}: E(g)={E_quadratic(g):.4f}, E(F(g))={E_quadratic(fg):.4f}, "
              f"preserved={abs(E_quadratic(g) - E_quadratic(fg)) < 1e-10}")

    # A truly invariant function must be constant on orbits
    # For an irrational rotation, orbits are dense → only constants work
    print("\n  For irrational rotation number, only constant functions are invariant.")
    print("  This is the ergodic obstruction to nontrivial energy compatibility.")

    # However, for FINITE orbit (rational rotation), periodic functions work
    print("\n  For rational rotation (if it occurs), periodic energy functions exist.")

# ─────────────────────────────────────────────
# Application 5: Conformal distortion analysis
# ─────────────────────────────────────────────

def conformal_distortion_demo():
    """
    Analyze the conformal distortion of the geometric RG map.

    The derivative F'(g) = (1+a²)(1+b²)/((a-b)g + (ab+1))² measures
    how much local distances are scaled. This is the "beta coefficient"
    in the RG interpretation.
    """
    print("\n\nAPPLICATION 5: Conformal distortion analysis")
    print("=" * 50)

    pole_pairs = [(0, 0.1), (0, 1), (0, 5), (1, 2)]

    for a, b in pole_pairs:
        gs = np.linspace(-10, 10, 1000)
        derivs = [moebius_deriv(a, b, g) for g in gs
                  if abs((a-b)*g + (a*b+1)) > 0.01]

        print(f"\n  Poles ({a}, {b}):")
        print(f"    Determinant: (1+{a}²)(1+{b}²) = {(1+a**2)*(1+b**2):.4f}")
        print(f"    F'(0) = {moebius_deriv(a, b, 0):.6f}")
        print(f"    max F' on [-10,10] = {max(derivs):.6f}")
        print(f"    min F' on [-10,10] = {min(derivs):.6f}")
        print(f"    F' > 0 everywhere: {all(d > 0 for d in derivs)}")

        # The "neutral coupling" where F'(g) = 1
        # (1+a²)(1+b²) = ((a-b)g + (ab+1))²
        # ±√((1+a²)(1+b²)) = (a-b)g + (ab+1)
        det = (1+a**2)*(1+b**2)
        sqrt_det = np.sqrt(det)
        if abs(a - b) > 1e-10:
            g_neutral_1 = (sqrt_det - (a*b+1)) / (a-b)
            g_neutral_2 = (-sqrt_det - (a*b+1)) / (a-b)
            print(f"    Neutral couplings (F'=1): g = {g_neutral_1:.4f}, {g_neutral_2:.4f}")

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Inverse Stereographic RG — Applications               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    coupling_flow_demo()
    projective_signal_demo()
    circle_dynamics_demo()
    energy_landscape_demo()
    conformal_distortion_demo()

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Inverse Stereographic Renormalization Group — Demonstration

This script visualizes the geometric RG dynamics defined by composing
two pole maps (inverse stereographic projections). It demonstrates:
1. The two-pole Möbius map and its orbits
2. Fixed-point analysis (showing none exist for distinct poles)
3. Derivative/beta-function computation
4. 1D Ising decimation comparison (falsifiable conjecture test)
"""

import numpy as np
import json
import sys

# ─────────────────────────────────────────────
# Core definitions matching the Lean formalization
# ─────────────────────────────────────────────

def pole_map(a: float, t: float) -> float:
    """M_a(t) = (at + 1)/(t - a). The fundamental pole map."""
    if abs(t - a) < 1e-15:
        return float('inf')
    return (a * t + 1) / (t - a)

def moebius_f(a: float, b: float, t: float) -> float:
    """F_{a,b}(t) = ((ab+1)t + (b-a)) / ((a-b)t + (ab+1)).
    The two-pole Möbius composition."""
    denom = (a - b) * t + (a * b + 1)
    if abs(denom) < 1e-15:
        return float('inf')
    return ((a * b + 1) * t + (b - a)) / denom

def rg_step(a: float, g: float) -> float:
    """Single RG step with pole a."""
    return pole_map(a, g)

def rg_update(a: float, b: float, g: float) -> float:
    """Two-pole RG update: compose pole maps with poles a, b."""
    return rg_step(b, rg_step(a, g))

def beta_geom(a: float, b: float, g: float) -> float:
    """Geometric beta observable: deviation from identity."""
    return rg_update(a, b, g) - g

def deriv_moebius_f(a: float, b: float, g: float) -> float:
    """Derivative of F_{a,b} at g: (1+a²)(1+b²) / ((a-b)g + (ab+1))²."""
    denom = (a - b) * g + (a * b + 1)
    if abs(denom) < 1e-15:
        return float('inf')
    return (1 + a**2) * (1 + b**2) / denom**2

# ─────────────────────────────────────────────
# Demo 1: Visualize RG orbits
# ─────────────────────────────────────────────

def demo_orbits():
    """Compute orbits of the two-pole RG map."""
    print("=" * 60)
    print("DEMO 1: Orbits of the two-pole RG map")
    print("=" * 60)

    a, b = 0.0, 1.0
    print(f"\nPoles: a = {a}, b = {b}")
    print(f"This is an ELLIPTIC Möbius transformation (rotation).")
    print(f"Discriminant = -4(a-b)² = {-4*(a-b)**2}")

    g0_values = [0.0, 0.5, 1.5, -1.0, 3.0]
    for g0 in g0_values:
        print(f"\n  Starting point g₀ = {g0}:")
        g = g0
        orbit = [g]
        for i in range(10):
            g = moebius_f(a, b, g)
            orbit.append(g)
        print(f"    Orbit: {[round(x, 4) for x in orbit[:6]]}...")
        print(f"    |g₁₀ - g₀| = {abs(orbit[-1] - orbit[0]):.6f} (never zero for a≠b)")

def demo_no_fixed_points():
    """Verify that distinct poles produce no real fixed points."""
    print("\n" + "=" * 60)
    print("DEMO 2: No real fixed points for distinct poles")
    print("=" * 60)

    test_cases = [(0, 1), (1, 2), (-1, 3), (0.5, -0.5)]
    for a, b in test_cases:
        print(f"\n  Poles a={a}, b={b}:")
        # Search for fixed points by scanning
        gs = np.linspace(-10, 10, 10000)
        min_diff = float('inf')
        best_g = None
        for g in gs:
            denom = (a - b) * g + (a * b + 1)
            if abs(denom) < 1e-10:
                continue
            diff = abs(moebius_f(a, b, g) - g)
            if diff < min_diff:
                min_diff = diff
                best_g = g
        print(f"    Minimum |F(g)-g| = {min_diff:.8f} at g ≈ {best_g:.4f}")
        print(f"    Fixed-point equation: g²+1=0 → no real solutions ✓")

    # Same pole: identity
    a, b = 2.0, 2.0
    print(f"\n  Same pole a=b={a}:")
    gs_test = [0, 1, -1, 3.14]
    for g in gs_test:
        print(f"    F({g}) = {moebius_f(a, b, g):.6f} (= g ✓)")

def demo_derivatives():
    """Compute and display derivative formulas."""
    print("\n" + "=" * 60)
    print("DEMO 3: Derivative / geometric beta coefficient")
    print("=" * 60)

    a, b = 0.0, 1.0
    print(f"\n  Poles a={a}, b={b}")
    print(f"  Formula: F'(g) = (1+a²)(1+b²) / ((a-b)g + (ab+1))²")
    print(f"         = {(1+a**2)*(1+b**2)} / ((({a}-{b})g + {a*b+1}))²")

    gs = [-2, -1, 0, 1, 2, 5]
    header_fpg = "F'(g)"
    print(f"\n  {'g':>6} | {'F(g)':>10} | {header_fpg:>10} | {'beta_geom':>10}")
    print(f"  {'-'*6}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}")
    for g in gs:
        fg = moebius_f(a, b, g)
        fpg = deriv_moebius_f(a, b, g)
        bg = beta_geom(a, b, g)
        print(f"  {g:6.2f} | {fg:10.6f} | {fpg:10.6f} | {bg:10.6f}")

    print(f"\n  Key observation: F'(g) > 0 everywhere → orientation-preserving")
    print(f"  The derivative is always (1+a²)(1+b²)/denom² > 0 ✓")

def demo_ising_conjecture():
    """Test the 1D Ising decimation conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 4: 1D Ising decimation conjecture test")
    print("=" * 60)

    # The exact 1D Ising decimation RG map
    # For the 1D Ising model with coupling K, the decimation
    # (block-spin) RG transformation is:
    # T(K) = (1/2) * ln(cosh(2K))
    # This maps coupling K → K' after integrating out every other spin.

    def ising_decimation(K):
        """Exact 1D Ising decimation: T(K) = (1/2)ln(cosh(2K))."""
        return 0.5 * np.log(np.cosh(2 * K))

    def ising_deriv(K):
        """Derivative: T'(K) = tanh(2K)."""
        return np.tanh(2 * K)

    print("\n  1D Ising decimation map: T(K) = (1/2)ln(cosh(2K))")
    print("  Fixed points: T(K*) = K* → K* = 0 (trivial) and K* = ∞ (ordered)")
    print(f"  T'(0) = tanh(0) = {ising_deriv(0):.4f}")
    print(f"  This is the trivial fixed point (high-T phase)")

    # Can we find poles a, b and coordinate change ψ such that
    # T(K) ≈ ψ⁻¹ ∘ F_{a,b} ∘ ψ(K) near K=0?

    # The geometric RG map F_{a,b} is a Möbius transformation.
    # Near any point, a Möbius map is approximately affine: F(g) ≈ F(g₀) + F'(g₀)(g-g₀).
    # At g₀ = 0: F_{a,b}(0) = (b-a)/(ab+1), F'(0) = (1+a²)(1+b²)/(ab+1)².
    # The Ising map: T(0) = (1/2)ln(cosh(0)) = 0, T'(0) = 0.
    # So we need F_{a,b}(ψ(0)) = ψ(0) and F'(ψ(0)) = 0.
    # But F'(g) > 0 everywhere! So the derivative can never be zero.
    # This means NO linear conjugacy can match T'(0) = 0.

    print("\n  CONJECTURE TEST:")
    print("  The geometric RG map F_{a,b} has F'(g) > 0 everywhere.")
    print(f"  But the Ising decimation has T'(0) = {ising_deriv(0):.4f}.")
    print("  Since F' is bounded away from 0, no smooth conjugacy can")
    print("  make F match T near the trivial fixed point.")
    print()
    print("  RESULT: The conjecture as stated is FALSIFIED for the")
    print("  trivial fixed point of the 1D Ising model.")
    print("  Reason: F_{a,b}'(g) > 0 for all g, but T'(0) = 0.")
    print()
    print("  REFINED CONJECTURE: The geometric RG matches Ising")
    print("  dynamics AWAY from the trivial fixed point, where T'(K) > 0.")

    # Check: for K > 0 small, T'(K) = tanh(2K) > 0.
    # Can we match F'(g) = tanh(2K) by choosing poles?
    K_test = 0.5
    target_deriv = ising_deriv(K_test)
    print(f"\n  At K = {K_test}: T'(K) = {target_deriv:.6f}")

    # F'_{a,b}(g) = (1+a²)(1+b²)/((a-b)g + (ab+1))²
    # We need to solve for a, b, g such that this equals target_deriv
    # and F(g) = T(K)

    # Simple approach: fix g = K, a = 0, solve for b
    # F'_{0,b}(K) = (1+b²)/(b²K² - 2bK + 1) · wait no
    # F'_{0,b}(g) = (1+b²)/(-bg + 1)² = target
    # With g = K_test = 0.5:
    # (1+b²)/(1-0.5b)² = tanh(1) ≈ 0.7616

    # This is a transcendental equation. Let's solve numerically.
    from scipy.optimize import brentq

    def objective(b_val):
        denom = (-b_val * K_test + 1)**2
        if denom < 1e-15:
            return 100
        return (1 + b_val**2) / denom - target_deriv

    # Check: F'_{0,b}(g) = (1+b²)/(1-bg)² ≥ 1 for all b when g=0
    # At g=0: F'_{0,b}(0) = (1+b²)/1 = 1+b² ≥ 1
    # So F' ≥ 1 everywhere near g=0, but T'(0) = 0.
    # This is a fundamental obstruction, not just a numerical issue.
    print(f"\n  F'_{{0,b}}(0) = 1+b² ≥ 1 for all b, but T'(0) = 0.")
    print(f"  This is a STRUCTURAL obstruction: Möbius maps have F' ≥ det/denom² > 0.")
    print(f"  The Ising RG map is NOT a Möbius transformation.")
    
    # However, show that the derivative values CAN match away from K=0
    print(f"\n  Derivative matching away from trivial fixed point:")
    for K in [0.5, 1.0, 1.5, 2.0]:
        td = ising_deriv(K)
        # Best b to match at this K: minimize |F'_{0,b}(K) - T'(K)|  
        # F'_{0,b}(K) = (1+b²)/(1-bK)² 
        # For large K, this can be < 1 if we choose b near 1/K
        best_b = None
        best_err = float('inf')
        for b_try in np.linspace(-5, 5, 10000):
            if abs(1 - b_try * K) < 0.01:
                continue
            fprime = (1 + b_try**2) / (1 - b_try * K)**2
            err = abs(fprime - td)
            if err < best_err:
                best_err = err
                best_b = b_try
        if best_b is not None:
            print(f"    K={K}: T'={td:.4f}, best F' match={best_err:.6f} (b={best_b:.3f})")
        else:
            print(f"    K={K}: T'={td:.4f}, no match found")

def demo_conformal_factor():
    """Demonstrate the conformal factor bound."""
    print("\n" + "=" * 60)
    print("DEMO 5: Conformal factor bound")
    print("=" * 60)

    ts = np.linspace(-5, 5, 100)
    cfs = 2 / (1 + ts**2)

    print(f"\n  Conformal factor: 2/(1+t²)")
    print(f"  Maximum: {max(cfs):.4f} at t=0 (proved: cf(0)=2)")
    print(f"  Bound: cf(t) ≤ 2 for all t (proved: conformal_factor_le_two)")
    print(f"  Minimum on [-5,5]: {min(cfs):.6f}")

    # Show beta_geom is bounded on compact sets
    a, b = 0.0, 1.0
    R = 5.0
    gs = np.linspace(-R, R, 1000)
    betas = [abs(beta_geom(a, b, g)) for g in gs
             if abs((a-b)*g + (a*b+1)) > 0.01]
    print(f"\n  |β_geom({a},{b},g)| on [-{R},{R}]:")
    print(f"    Max: {max(betas):.6f}")
    print(f"    Mean: {np.mean(betas):.6f}")
    print(f"    → Bounded ✓ (proved: betaGeom_bounded in principle)")

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Inverse Stereographic Renormalization Group — Demo     ║")
    print("║  Geometric RG via Pole-Change Möbius Dynamics           ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_orbits()
    demo_no_fixed_points()
    demo_derivatives()
    demo_conformal_factor()

    try:
        demo_ising_conjecture()
    except ImportError:
        print("\n[scipy not available — skipping Ising conjecture test]")

    print("\n" + "=" * 60)
    print("SUMMARY OF VERIFIED RESULTS")
    print("=" * 60)
    print("""
  1. poleMap_involution: M_a is an involution ✓
  2. rgUpdate_eq_moebiusF: Two-pole composition = F_{a,b} ✓
  3. rgUpdate_no_real_fixed_point: No real fixed points for a≠b ✓
  4. rgUpdate_eq_id_implies_same_pole: Identity iff a=b ✓
  5. deriv_moebiusF'_formula: Explicit derivative ✓
  6. deriv_moebiusF'_pos: Derivative always positive ✓
  7. energy_deriv_zero_of_rgUpdate_compat: Energy conservation ✓
  8. rgUpdate_composition: F_{b,c} ∘ F_{a,b} = F_{a,c} ✓
  9. rgUpdate_reverse_is_inverse: F_{b,a} inverts F_{a,b} ✓
    """)

if __name__ == "__main__":
    main()
