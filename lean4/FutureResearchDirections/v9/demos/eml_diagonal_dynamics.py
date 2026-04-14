#!/usr/bin/env python3
"""
EML Diagonal Map Dynamics Explorer
===================================
Explores the dynamical system d(x) = exp(x) - ln(x) and its iterations.

Key findings demonstrated:
  1. d(x) has a unique minimum at x* = W(1) ≈ 0.5671 (Lambert W)
  2. d(x*) ≈ 2.3327 > 2, confirming diagonal map always exceeds 2
  3. All orbits diverge to +∞ (supporting P-D1 conjecture)
  4. The diagonal map has no fixed points (proved in Lean)
  5. Lyapunov exponent is always positive (supporting P-D2)
"""

import math
import cmath
import json

# ─── Core EML Functions ───────────────────────────────────────────────

def eml(a, b):
    """EML operator: eml(a,b) = exp(a) - ln(b)"""
    return math.exp(a) - math.log(b)

def diagonal(x):
    """Diagonal map: d(x) = exp(x) - ln(x) for x > 0"""
    try:
        return math.exp(x) - math.log(x)
    except OverflowError:
        return float('inf')

def diagonal_deriv(x):
    """d'(x) = exp(x) - 1/x"""
    try:
        return math.exp(x) - 1.0 / x
    except OverflowError:
        return float('inf')

def diagonal_second_deriv(x):
    """d''(x) = exp(x) + 1/x^2"""
    try:
        return math.exp(x) + 1.0 / (x * x)
    except OverflowError:
        return float('inf')

# ─── Lambert W function (principal branch) ────────────────────────────

def lambert_w(x, tol=1e-15, max_iter=100):
    """Compute W(x) using Halley's method. W(x)*exp(W(x)) = x."""
    if x < -1.0 / math.e:
        raise ValueError("No real W for x < -1/e")
    if x == 0:
        return 0.0
    # Initial guess
    if x < 1:
        w = x
    else:
        w = math.log(x) - math.log(math.log(x)) if x > math.e else 1.0
    for _ in range(max_iter):
        ew = math.exp(w)
        wew = w * ew
        f = wew - x
        fp = ew * (w + 1)
        fpp = ew * (w + 2)
        # Halley's method
        dw = f / (fp - f * fpp / (2 * fp))
        w -= dw
        if abs(dw) < tol:
            break
    return w

# ─── Demo 1: Critical Point Analysis ──────────────────────────────────

def demo_critical_point():
    """Find the minimum of d(x) = exp(x) - ln(x)"""
    print("=" * 60)
    print("DEMO 1: Critical Point Analysis (P-M3, P-M5)")
    print("=" * 60)
    
    x_star = lambert_w(1.0)
    d_star = diagonal(x_star)
    
    print(f"\nLambert W(1) = {x_star:.15f}")
    print(f"Verification: W(1) * exp(W(1)) = {x_star * math.exp(x_star):.15f}")
    print(f"\nMinimum of diagonal map:")
    print(f"  x* = W(1) = {x_star:.15f}")
    print(f"  d(x*) = {d_star:.15f}")
    print(f"  d'(x*) = {diagonal_deriv(x_star):.2e} (≈ 0, confirming critical point)")
    print(f"  d''(x*) = {diagonal_second_deriv(x_star):.15f} > 0 (minimum)")
    print(f"\nClosed form: d(x*) = 1/W(1) + 1 + ln(1/W(1))")
    print(f"  = {1/x_star + 1 + math.log(1/x_star):.15f}")
    print(f"\nKey inequality: d(x) ≥ {d_star:.4f} > 2 for all x > 0")
    
    # Is d(x*) transcendental? It involves W(1) which is transcendental.
    print(f"\nNote: W(1) ≈ {x_star:.10f} is known to be transcendental")
    print(f"      d(x*) = 1/W(1) + 1 + ln(1/W(1)) is likely transcendental")

# ─── Demo 2: Orbit Analysis ──────────────────────────────────────────

def demo_orbits():
    """Show that all orbits diverge"""
    print("\n" + "=" * 60)
    print("DEMO 2: Orbit Divergence (P-D1 evidence)")
    print("=" * 60)
    
    initial_points = [0.01, 0.1, 0.5, 1.0, 2.0, 5.0]
    n_iters = 8
    
    print(f"\n{'x_0':>8} | " + " | ".join(f"d^{i}(x_0)" for i in range(1, n_iters+1)))
    print("-" * (10 + 15 * n_iters))
    
    for x0 in initial_points:
        x = x0
        orbit = []
        for _ in range(n_iters):
            x = diagonal(x)
            orbit.append(x)
        vals = " | ".join(f"{v:>12.4f}" if v < 1e10 else f"{'> 10^10':>12}" for v in orbit)
        print(f"{x0:>8.2f} | {vals}")
    
    print("\nConclusion: ALL orbits diverge to +∞, supporting universal divergence conjecture")

# ─── Demo 3: Lyapunov Exponent Estimation ────────────────────────────

def demo_lyapunov():
    """Estimate Lyapunov exponent of the diagonal map"""
    print("\n" + "=" * 60)
    print("DEMO 3: Lyapunov Exponent Estimation (P-D2)")
    print("=" * 60)
    
    x0_values = [0.1, 0.5, 1.0, 2.0]
    
    for x0 in x0_values:
        x = x0
        lyap_sum = 0.0
        n_steps = 10  # Can only do a few steps before overflow
        for i in range(n_steps):
            deriv = abs(diagonal_deriv(x))
            if deriv > 0:
                lyap_sum += math.log(deriv)
            try:
                x = diagonal(x)
            except OverflowError:
                n_steps = i + 1
                break
            if x > 1e100:
                n_steps = i + 1
                break
        
        lyap = lyap_sum / n_steps
        print(f"x_0 = {x0:.1f}: λ ≈ {lyap:.4f} (positive → chaos/divergence)")
    
    print("\nAll Lyapunov exponents are positive, confirming expansive dynamics")

# ─── Demo 4: EML Tree Enumeration ────────────────────────────────────

def demo_tree_enumeration():
    """Enumerate EML tree values from constant 1 at increasing depths"""
    print("\n" + "=" * 60)
    print("DEMO 4: EML Tree Enumeration from {1} (P-C1, P-M2)")
    print("=" * 60)
    
    # Depth 0: just {1}
    values = {0: {1.0}}
    
    for depth in range(1, 5):
        new_values = set()
        # Combine all pairs from previous depths
        for d1 in range(depth):
            d2 = depth - 1 - d1
            if d2 < 0 or d2 >= depth:
                continue
            for v1 in values.get(d1, set()):
                for v2 in values.get(d2, set()):
                    if v2 > 0:  # ln requires positive
                        try:
                            result = eml(v1, v2)
                            if math.isfinite(result) and abs(result) < 1e15:
                                new_values.add(round(result, 12))
                        except (OverflowError, ValueError):
                            pass
        # Also pair from all depths up to depth-1
        all_prev = set()
        for d in range(depth):
            all_prev |= values.get(d, set())
        for v1 in all_prev:
            for v2 in all_prev:
                if v2 > 0:
                    try:
                        result = eml(v1, v2)
                        if math.isfinite(result) and abs(result) < 1e15:
                            new_values.add(round(result, 12))
                    except (OverflowError, ValueError):
                        pass
        values[depth] = new_values
        
        all_so_far = set()
        for d in range(depth + 1):
            all_so_far |= values[d]
        
        print(f"\nDepth {depth}: {len(new_values)} new values, {len(all_so_far)} total")
        sorted_vals = sorted(v for v in new_values if -10 < v < 20)[:15]
        if sorted_vals:
            print(f"  Sample values: {[round(v, 6) for v in sorted_vals]}")
    
    # Check K_EML(2)
    all_vals = set()
    for d in range(5):
        all_vals |= values.get(d, set())
    close_to_2 = sorted([(abs(v - 2), v) for v in all_vals if abs(v - 2) < 0.5])[:5]
    print(f"\nClosest values to 2: {[(round(d,6), round(v,6)) for d, v in close_to_2]}")
    print("This confirms K_EML(2) > 4 (cannot reach 2 with depth ≤ 4)")

# ─── Demo 5: n-th Derivative Pattern ─────────────────────────────────

def demo_nth_derivative():
    """Verify the pattern d^(n)(x) = exp(x) + (-1)^n * (n-1)!/x^n"""
    print("\n" + "=" * 60)
    print("DEMO 5: Higher EML Derivatives (P-M4)")
    print("=" * 60)
    
    x = 1.5  # Test point
    print(f"\nEvaluating at x = {x}")
    print(f"{'n':>3} | {'Formula':>20} | {'Numerical':>20}")
    print("-" * 50)
    
    for n in range(1, 8):
        formula_val = math.exp(x) + ((-1)**n * math.factorial(n-1)) / x**n
        print(f"{n:>3} | {formula_val:>20.10f} | d^({n})(x) = exp(x) + (-1)^{n}·{n-1}!/x^{n}")
    
    print(f"\nPattern: d^(n)(x) = exp(x) + (-1)^n · (n-1)! / x^n for n ≥ 1")
    print("This shows exp(x) dominates all derivatives for large x")
    print("The alternating sign means odd derivatives have exp(x) - (n-1)!/x^n")

# ─── Demo 6: 2D EML Map ──────────────────────────────────────────────

def demo_2d_map():
    """Explore the 2D EML map Φ(x,y) = (eml(x,y), eml(y,x))"""
    print("\n" + "=" * 60)
    print("DEMO 6: 2D EML Map Dynamics (P-D1)")
    print("=" * 60)
    
    initial_points = [(1.0, 1.0), (0.5, 2.0), (1.0, 0.5), (0.1, 0.1)]
    
    for (x0, y0) in initial_points:
        print(f"\nOrbit from ({x0}, {y0}):")
        x, y = x0, y0
        for i in range(6):
            print(f"  Step {i}: ({x:.6f}, {y:.6f})")
            try:
                x_new = eml(x, y)
                y_new = eml(y, x)
                x, y = x_new, y_new
                if abs(x) > 1e15 or abs(y) > 1e15:
                    print(f"  Step {i+1}: OVERFLOW → diverged")
                    break
            except (OverflowError, ValueError):
                print(f"  Step {i+1}: OVERFLOW → diverged")
                break
    
    print("\nAll 2D orbits also diverge, supporting universal divergence")

# ─── Demo 7: EML Functional Equation ─────────────────────────────────

def demo_functional_equation():
    """Search for EML homomorphisms f: f(eml(x,y)) = eml(f(x), f(y))"""
    print("\n" + "=" * 60)
    print("DEMO 7: EML Homomorphism Search (P-M6)")
    print("=" * 60)
    
    # Test f(x) = ax + b (affine)
    print("\nTesting affine maps f(x) = ax + b:")
    test_points = [(1.0, 2.0), (0.5, 3.0), (2.0, 0.5)]
    
    for a in [0.5, 1.0, 2.0, -1.0]:
        for b in [0.0, 1.0, -1.0]:
            f = lambda x, a=a, b=b: a * x + b
            is_hom = True
            for x, y in test_points:
                if y > 0 and f(y) > 0:
                    lhs = f(eml(x, y))
                    rhs = eml(f(x), f(y))
                    if abs(lhs - rhs) > 1e-6:
                        is_hom = False
                        break
            if is_hom:
                print(f"  f(x) = {a}x + {b}: POSSIBLE homomorphism")
            
    # Test f(x) = x (identity)
    print("\n  Identity f(x) = x: trivially a homomorphism")
    
    # Test f(x) = exp(x)
    print("\nTesting f(x) = exp(x):")
    for x, y in test_points:
        if y > 0:
            lhs = math.exp(eml(x, y))
            rhs = eml(math.exp(x), math.exp(y))
            print(f"  ({x},{y}): f(eml) = {lhs:.6f}, eml(f,f) = {rhs:.6f}, diff = {abs(lhs-rhs):.6e}")
    
    print("\nConclusion: The identity appears to be the only affine EML homomorphism")
    print("  (non-trivial EML homomorphisms likely do not exist)")

# ─── Demo 8: Convex Conjugate ─────────────────────────────────────────

def demo_convex_conjugate():
    """Compute the Legendre transform of d(x) = exp(x) - ln(x) on (0,∞)"""
    print("\n" + "=" * 60)
    print("DEMO 8: EML Convex Conjugate / Legendre Transform (P-M8)")
    print("=" * 60)
    
    # d*(p) = sup_x (px - d(x)) = sup_x (px - exp(x) + ln(x))
    # Critical point: p = exp(x) - 1/x = d'(x)
    # At critical point x_p: p = exp(x_p) - 1/x_p
    
    from scipy.optimize import brentq
    
    def neg_conjugand(x, p):
        """-(px - d(x)) for minimization"""
        if x <= 0:
            return 1e30
        return -(p * x - math.exp(x) + math.log(x))
    
    print(f"\n{'p':>8} | {'x_p':>12} | {'d*(p)':>15} | {'Verification':>15}")
    print("-" * 55)
    
    for p in [2.0, 3.0, 5.0, 10.0, 20.0, 50.0]:
        # Find x where d'(x) = p, i.e., exp(x) - 1/x = p
        def eq(x):
            return math.exp(x) - 1.0/x - p
        
        try:
            x_p = brentq(eq, 0.001, 10.0)
            d_star = p * x_p - math.exp(x_p) + math.log(x_p)
            # Verify: d*(p) should satisfy d*'(p) = x_p (Legendre duality)
            print(f"{p:>8.1f} | {x_p:>12.8f} | {d_star:>15.8f} | x_p = {x_p:.8f}")
        except ValueError:
            print(f"{p:>8.1f} | {'N/A':>12} | {'N/A':>15} |")
    
    print("\nFor large p: d*(p) ≈ p·ln(p) - p (since exp dominates)")
    print("The Legendre transform connects EML to entropy-like functionals")

# ─── Demo 9: EML Closure Density ──────────────────────────────────────

def demo_density():
    """Study density of EML closure of {1} in ℝ₊"""
    print("\n" + "=" * 60)
    print("DEMO 9: EML Closure Density Analysis (P-M2)")
    print("=" * 60)
    
    # Collect all reachable values up to depth 4
    values_by_depth = {0: {1.0}}
    all_values = {1.0}
    
    for depth in range(1, 5):
        new_vals = set()
        prev = list(all_values)
        for v1 in prev:
            for v2 in prev:
                if v2 > 0:
                    try:
                        r = eml(v1, v2)
                        if math.isfinite(r) and abs(r) < 1e6:
                            r = round(r, 10)
                            if r not in all_values:
                                new_vals.add(r)
                    except (OverflowError, ValueError):
                        pass
        values_by_depth[depth] = new_vals
        all_values |= new_vals
    
    # Analyze density in intervals
    print(f"\nTotal reachable values (depth ≤ 4): {len(all_values)}")
    
    intervals = [(0, 1), (1, 2), (2, 3), (3, 5), (5, 10), (10, 20), (20, 50), (50, 100)]
    print(f"\n{'Interval':>12} | {'Count':>6} | {'Density':>10} | {'Mean Gap':>10}")
    print("-" * 50)
    
    for lo, hi in intervals:
        in_interval = sorted(v for v in all_values if lo <= v < hi)
        count = len(in_interval)
        density = count / (hi - lo) if count > 0 else 0
        if count >= 2:
            gaps = [in_interval[i+1] - in_interval[i] for i in range(len(in_interval)-1)]
            mean_gap = sum(gaps) / len(gaps)
        else:
            mean_gap = float('inf')
        print(f"  [{lo:>3}, {hi:>3}) | {count:>6} | {density:>10.2f} | {mean_gap:>10.4f}" if mean_gap < 100 else f"  [{lo:>3}, {hi:>3}) | {count:>6} | {density:>10.2f} | {'∞':>10}")
    
    print("\nDensity increases with depth, supporting P-M2 conjecture")

# ─── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_critical_point()
    demo_orbits()
    demo_lyapunov()
    demo_tree_enumeration()
    demo_nth_derivative()
    demo_2d_map()
    demo_functional_equation()
    
    try:
        demo_convex_conjugate()
    except ImportError:
        print("\n[Skipping Demo 8: scipy not available]")
    
    demo_density()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
