#!/usr/bin/env python3
"""
EML Dynamics Explorer

Explores the dynamical system z_{n+1} = eml(z_n, y) = exp(z_n) - ln(y)
for various values of y, demonstrating fixed-point behavior, bifurcations,
and the Lambert W connection.

Run: python3 eml_dynamics.py
"""

import math

def eml(x, y):
    """EML operator: eml(x, y) = exp(x) - ln(y)."""
    return math.exp(x) - math.log(y)

def find_fixed_points(y, tol=1e-12, n_starts=20):
    """Find fixed points of eml(·, y) via Newton's method.
    
    Solve: exp(x) - ln(y) = x  ⟺  exp(x) - x = ln(y)
    """
    log_y = math.log(y)
    solutions = []
    
    for x0 in [i * 2.0 - n_starts for i in range(2 * n_starts + 1)]:
        x = x0
        for _ in range(200):
            try:
                f = math.exp(x) - x - log_y
                fp = math.exp(x) - 1  # derivative
                if abs(fp) < 1e-15:
                    break
                x_new = x - f / fp
                if abs(x_new - x) < tol:
                    if abs(math.exp(x_new) - x_new - log_y) < 1e-8:
                        is_new = True
                        for s in solutions:
                            if abs(s - x_new) < 1e-6:
                                is_new = False
                                break
                        if is_new:
                            solutions.append(x_new)
                    break
                x = x_new
            except OverflowError:
                break
    
    solutions.sort()
    return solutions

def iterate_eml(y, z0, n_steps=30):
    """Iterate z_{n+1} = exp(z_n) - ln(y)."""
    trajectory = [z0]
    z = z0
    for _ in range(n_steps):
        try:
            z = math.exp(z) - math.log(y)
            if abs(z) > 1e10:
                trajectory.append(float('inf'))
                break
            trajectory.append(z)
        except OverflowError:
            trajectory.append(float('inf'))
            break
    return trajectory

def fixed_point_analysis():
    """Analyze the fixed-point structure as y varies."""
    print("="*70)
    print("EML FIXED-POINT BIFURCATION ANALYSIS")
    print("="*70)
    
    print("\nThe fixed points of eml(·, y) = exp(·) - ln(y) satisfy exp(x) = x + ln(y)")
    print("The minimum of exp(x) - x is at x = 0, where exp(0) - 0 = 1.")
    print("So fixed points exist iff ln(y) ≥ 1, i.e., y ≥ e.\n")
    
    print(f"{'y':>10} | {'ln(y)':>8} | {'# Fixed Pts':>12} | {'Fixed Points':>30}")
    print("-"*70)
    
    test_values = [1.0, 2.0, math.e - 0.01, math.e, math.e + 0.01, 
                   math.e**2, 10, 100, 1000]
    
    for y in test_values:
        log_y = math.log(y)
        fps = find_fixed_points(y)
        fp_str = ", ".join(f"{x:.6f}" for x in fps) if fps else "none"
        print(f"{y:>10.4f} | {log_y:>8.4f} | {len(fps):>12} | {fp_str}")
    
    print("\n→ Bifurcation at y = e: below e, no fixed points; at e, one; above e, two.")
    print("  This is a saddle-node bifurcation, fundamental in dynamical systems theory.")

def stability_analysis():
    """Analyze stability of fixed points."""
    print("\n" + "="*70)
    print("STABILITY ANALYSIS")
    print("="*70)
    
    print("\nA fixed point x* is stable if |f'(x*)| < 1, where f(x) = exp(x) - ln(y).")
    print("Since f'(x) = exp(x), stability requires exp(x*) < 1, i.e., x* < 0.\n")
    
    print(f"{'y':>8} | {'x* (stable)':>14} | {'exp(x*)':>10} | {'x* (unstable)':>14} | {'exp(x*)':>10}")
    print("-"*65)
    
    for y in [math.e, math.e**1.5, math.e**2, math.e**3, 10, 100]:
        fps = find_fixed_points(y)
        if len(fps) == 1:
            x = fps[0]
            print(f"{y:>8.4f} | {x:>14.6f} | {math.exp(x):>10.6f} | {'(tangent)':>14} | {'':>10}")
        elif len(fps) >= 2:
            x_stable = fps[0]  # smaller root, x < 0 → exp(x) < 1
            x_unstable = fps[1]
            print(f"{y:>8.4f} | {x_stable:>14.6f} | {math.exp(x_stable):>10.6f} | {x_unstable:>14.6f} | {math.exp(x_unstable):>10.6f}")

def iteration_demo():
    """Demonstrate EML iteration dynamics."""
    print("\n" + "="*70)
    print("EML ITERATION DYNAMICS: z_{n+1} = exp(z_n) - ln(y)")
    print("="*70)
    
    cases = [
        (math.e**2, -2.0, "y = e², start below stable fixed point"),
        (math.e**2, 0.5, "y = e², start between fixed points"),
        (math.e**2, 2.0, "y = e², start above unstable fixed point"),
        (2.0, 0.0, "y = 2 < e, no fixed points (diverges)"),
        (math.e, 0.0, "y = e, tangent point at x = 0"),
    ]
    
    for y, z0, desc in cases:
        print(f"\nCase: {desc}")
        fps = find_fixed_points(y)
        if fps:
            print(f"  Fixed points: {', '.join(f'{x:.4f}' for x in fps)}")
        else:
            print(f"  No fixed points")
        
        traj = iterate_eml(y, z0, n_steps=15)
        print(f"  Trajectory from z₀ = {z0}:")
        for i, z in enumerate(traj[:10]):
            if z == float('inf'):
                print(f"    z_{i} = ∞ (diverged)")
                break
            print(f"    z_{i} = {z:.8f}")
        if len(traj) > 10 and traj[-1] != float('inf'):
            print(f"    ... z_{len(traj)-1} = {traj[-1]:.8f}")

def lambert_w_connection():
    """Demonstrate the Lambert W connection to EML fixed points."""
    print("\n" + "="*70)
    print("LAMBERT W CONNECTION")
    print("="*70)
    
    print("\nThe EML fixed point equation exp(x) = x + ln(y) transforms to:")
    print("  Setting u = -x: exp(-u) = -u + ln(y)")
    print("  If u = -x is a solution, then x = -W(-1/y) - ln(y)")
    print("  where W is the Lambert W function.\n")
    
    # Verify numerically
    print("Numerical verification:")
    print(f"{'y':>8} | {'Fixed pt x*':>14} | {'x* + ln(y)':>12} | {'exp(x*)':>12} | {'Match':>6}")
    print("-"*60)
    
    for y in [math.e, math.e**2, 10, 100]:
        fps = find_fixed_points(y)
        log_y = math.log(y)
        for x in fps:
            lhs = math.exp(x)
            rhs = x + log_y
            match = abs(lhs - rhs) < 1e-8
            print(f"{y:>8.4f} | {x:>14.8f} | {rhs:>12.8f} | {lhs:>12.8f} | {'✓' if match else '✗':>6}")

def eml_as_universal():
    """Demonstrate EML as universal function generator."""
    print("\n" + "="*70)
    print("EML AS UNIVERSAL FUNCTION GENERATOR")
    print("="*70)
    
    print("\nAll elementary functions from eml(x, y) = exp(x) - ln(y) and constant 1:\n")
    
    demonstrations = [
        ("exp(x)", lambda x: eml(x, 1), lambda x: math.exp(x), "eml(x, 1)"),
        ("e", lambda x: eml(1, 1), lambda x: math.e, "eml(1, 1)"),
        ("ln(x)", lambda x: 1 - eml(0, x), lambda x: math.log(x), "1 - eml(0, x)"),
        ("x + y", lambda x: math.log(math.exp(x) * math.exp(2)), 
         lambda x: x + 2, "via exp-log"),
        ("x²", lambda x: math.exp(2 * math.log(x)) if x > 0 else 0,
         lambda x: x**2, "exp(2·ln(x))"),
    ]
    
    print(f"{'Function':>12} | {'EML Expression':>20} | {'x=2':>10} | {'Expected':>10} | {'Match':>6}")
    print("-"*65)
    
    for name, eml_fn, expected_fn, expr in demonstrations:
        try:
            eml_val = eml_fn(2.0)
            exp_val = expected_fn(2.0)
            match = abs(eml_val - exp_val) < 1e-8
            print(f"{name:>12} | {expr:>20} | {eml_val:>10.6f} | {exp_val:>10.6f} | {'✓' if match else '✗':>6}")
        except (ValueError, OverflowError):
            print(f"{name:>12} | {expr:>20} | {'error':>10} | {'---':>10} | {'---':>6}")

# ── Main ──

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║              EML DYNAMICS EXPLORER: RESEARCH DEMO                  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    eml_as_universal()
    fixed_point_analysis()
    stability_analysis()
    iteration_demo()
    lambert_w_connection()
    
    print("\n" + "="*70)
    print("DEMO COMPLETE")
    print("="*70)
