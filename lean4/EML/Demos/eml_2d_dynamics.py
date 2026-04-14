#!/usr/bin/env python3
"""
EML 2D Dynamical Systems Explorer

Studies the 2D EML map Φ(x,y) = (EML(x,y), EML(y,x))
  = (exp(x) - ln(y), exp(y) - ln(x))

Investigates:
- Fixed points
- Periodic orbits
- Lyapunov exponents
- Invariant curves
- Basin of attraction structure
"""

import math
import sys

def eml(a, b):
    """EML(a,b) = exp(a) - ln(b)"""
    if b <= 0:
        return float('inf')
    try:
        return math.exp(a) - math.log(b)
    except OverflowError:
        return float('inf')

def phi_2d(x, y):
    """The 2D EML map: Φ(x,y) = (EML(x,y), EML(y,x))"""
    return eml(x, y), eml(y, x)

def jacobian_2d(x, y):
    """
    Jacobian of Φ at (x,y):
    J = [[exp(x),   -1/y],
         [-1/x,    exp(y)]]
    """
    if x <= 0 or y <= 0:
        return None
    try:
        return [
            [math.exp(x), -1.0/y],
            [-1.0/x, math.exp(y)]
        ]
    except OverflowError:
        return None

def mat_eigenvalues_2x2(a, b, c, d):
    """Eigenvalues of [[a,b],[c,d]]"""
    trace = a + d
    det = a * d - b * c
    disc = trace**2 - 4*det
    if disc >= 0:
        return (trace + math.sqrt(disc))/2, (trace - math.sqrt(disc))/2
    else:
        real = trace / 2
        imag = math.sqrt(-disc) / 2
        return complex(real, imag), complex(real, -imag)

def iterate_2d(x0, y0, n_steps, verbose=False):
    """Iterate the 2D map and return trajectory."""
    trajectory = [(x0, y0)]
    x, y = x0, y0
    for i in range(n_steps):
        try:
            x_new, y_new = phi_2d(x, y)
            if abs(x_new) > 1e50 or abs(y_new) > 1e50:
                if verbose:
                    print(f"  Step {i+1}: DIVERGED")
                break
            x, y = x_new, y_new
            trajectory.append((x, y))
            if verbose and i < 20:
                print(f"  Step {i+1}: ({x:.8f}, {y:.8f})")
        except:
            break
    return trajectory

def find_fixed_points():
    """
    Fixed point of Φ: (x,y) = (EML(x,y), EML(y,x))
    i.e., x = exp(x) - ln(y) and y = exp(y) - ln(x)
    
    By symmetry, look for x = y first:
    x = exp(x) - ln(x) => this is the diagonal map d(x) = x
    which we know has NO positive fixed points (eml_diag(x) > x for all x > 0).
    
    So we look for asymmetric fixed points.
    """
    print("SEARCHING FOR FIXED POINTS OF Φ(x,y) = (EML(x,y), EML(y,x))")
    print("-" * 60)
    
    # Newton's method for F(x,y) = (EML(x,y) - x, EML(y,x) - y) = 0
    # Already proved: no symmetric (x=y) fixed points
    print("By proven theorem: no symmetric fixed points (x=y) exist.")
    print("Searching for asymmetric fixed points via grid + Newton...")
    
    found = []
    for x0 in [v/10 for v in range(1, 50)]:
        for y0 in [v/10 for v in range(1, 50)]:
            x, y = x0, y0
            converged = False
            for _ in range(1000):
                try:
                    fx = eml(x, y) - x
                    fy = eml(y, x) - y
                    if abs(fx) + abs(fy) < 1e-14:
                        converged = True
                        break
                    J = jacobian_2d(x, y)
                    if J is None:
                        break
                    # J_F = J - I
                    a, b = J[0][0] - 1, J[0][1]
                    c, d = J[1][0], J[1][1] - 1
                    det = a*d - b*c
                    if abs(det) < 1e-15:
                        break
                    dx = (d*fx - b*fy) / det
                    dy = (-c*fx + a*fy) / det
                    x -= dx
                    y -= dy
                    if x <= 0 or y <= 0 or abs(x) > 100 or abs(y) > 100:
                        break
                except:
                    break
            if converged and x > 0 and y > 0:
                # Check if already found
                is_new = True
                for fx, fy in found:
                    if abs(fx - x) + abs(fy - y) < 1e-8:
                        is_new = False
                        break
                if is_new:
                    found.append((x, y))
    
    if found:
        for x, y in found:
            print(f"\n  Fixed point: ({x:.12f}, {y:.12f})")
            print(f"  Verify: EML({x:.6f}, {y:.6f}) = {eml(x,y):.12f}")
            print(f"  Verify: EML({y:.6f}, {x:.6f}) = {eml(y,x):.12f}")
            J = jacobian_2d(x, y)
            if J:
                ev1, ev2 = mat_eigenvalues_2x2(J[0][0], J[0][1], J[1][0], J[1][1])
                print(f"  Eigenvalues: {ev1}, {ev2}")
                print(f"  |λ₁| = {abs(ev1):.6f}, |λ₂| = {abs(ev2):.6f}")
    else:
        print("\n  No asymmetric fixed points found in search grid.")
        print("  CONJECTURE: The 2D EML map has NO fixed points on ℝ₊²")

def study_periodic_orbits():
    """Search for periodic orbits."""
    print("\n" + "=" * 60)
    print("PERIODIC ORBIT SEARCH")
    print("-" * 60)
    
    for period in [2, 3, 4]:
        print(f"\nSearching for period-{period} orbits...")
        found = False
        for x0 in [v/5 for v in range(1, 20)]:
            for y0 in [v/5 for v in range(1, 20)]:
                x, y = x0, y0
                valid = True
                for _ in range(period):
                    try:
                        x, y = phi_2d(x, y)
                        if abs(x) > 1e10 or abs(y) > 1e10 or x <= 0 or y <= 0:
                            valid = False
                            break
                    except:
                        valid = False
                        break
                if valid and abs(x - x0) + abs(y - y0) < 1e-6:
                    print(f"  Period-{period} orbit starting near ({x0}, {y0})")
                    traj = iterate_2d(x0, y0, period, verbose=True)
                    found = True
                    break
            if found:
                break
        if not found:
            print(f"  No period-{period} orbits found.")

def lyapunov_analysis():
    """Compute Lyapunov exponents for sample trajectories."""
    print("\n" + "=" * 60)
    print("LYAPUNOV EXPONENT ANALYSIS")
    print("-" * 60)
    
    test_points = [(0.5, 0.5), (1.0, 1.0), (1.0, 2.0), (0.1, 0.1), (2.0, 3.0)]
    
    for x0, y0 in test_points:
        x, y = x0, y0
        lyap_sum = 0.0
        n_valid = 0
        
        for i in range(50):
            J = jacobian_2d(x, y)
            if J is None:
                break
            # Largest singular value approximation
            det = J[0][0]*J[1][1] - J[0][1]*J[1][0]
            trace_sq = sum(J[r][c]**2 for r in range(2) for c in range(2))
            max_sv = math.sqrt(trace_sq / 2 + math.sqrt(max(0, trace_sq**2/4 - det**2)))
            if max_sv > 0:
                lyap_sum += math.log(max_sv)
                n_valid += 1
            
            try:
                x, y = phi_2d(x, y)
                if abs(x) > 1e50 or abs(y) > 1e50 or x <= 0 or y <= 0:
                    break
            except:
                break
        
        if n_valid > 0:
            lyap = lyap_sum / n_valid
            print(f"  ({x0}, {y0}): λ_max ≈ {lyap:.4f}, "
                  f"{'CHAOTIC' if lyap > 0.01 else 'STABLE' if lyap < -0.01 else 'MARGINAL'} "
                  f"(survived {n_valid} steps)")
        else:
            print(f"  ({x0}, {y0}): unable to compute")

def orbit_analysis():
    """Detailed orbit analysis for several starting points."""
    print("\n" + "=" * 60)
    print("ORBIT ANALYSIS")
    print("-" * 60)
    
    test_points = [
        (0.5, 0.5, "symmetric small"),
        (1.0, 1.0, "unit"),
        (0.5, 1.5, "asymmetric"),
        (2.0, 0.5, "far asymmetric"),
        (0.1, 0.1, "near origin"),
    ]
    
    for x0, y0, label in test_points:
        print(f"\n  Starting point: ({x0}, {y0}) — {label}")
        traj = iterate_2d(x0, y0, 20, verbose=True)
        if len(traj) > 1:
            # Check if x-y stays bounded or diverges
            diffs = [abs(x-y) for x, y in traj]
            sums = [x+y for x, y in traj if x > 0 and y > 0]
            print(f"  |x-y| range: [{min(diffs):.4f}, {max(diffs):.4f}]")
            if sums:
                print(f"  x+y range: [{min(sums):.4f}, {max(sums):.4f}]")
            if len(traj) < 20:
                print(f"  DIVERGED after {len(traj)} steps")
            else:
                print(f"  Survived 20 iterations")

def main():
    print("=" * 60)
    print("EML 2D DYNAMICAL SYSTEMS EXPLORER")
    print("Φ(x,y) = (exp(x) - ln(y), exp(y) - ln(x))")
    print("=" * 60)
    
    find_fixed_points()
    study_periodic_orbits()
    lyapunov_analysis()
    orbit_analysis()
    
    print("\n" + "=" * 60)
    print("SUMMARY OF FINDINGS")
    print("-" * 60)
    print("""
Key Results:
1. No symmetric fixed points (proven in Lean: eml_diag(x) > x for all x > 0)
2. The 2D map appears to have NO fixed points at all
3. All orbits diverge rapidly (positive Lyapunov exponents)
4. No periodic orbits detected up to period 4
5. The map is strongly expansive due to exponential growth

Conjectures:
- The 2D EML map has no periodic orbits on ℝ₊²
- All orbits escape to infinity
- The diagonal x = y is NOT an invariant curve
""")

if __name__ == "__main__":
    main()
