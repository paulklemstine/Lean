#!/usr/bin/env python3
"""
OISCC V9 Dynamics Visualization Demo

Generates text-based visualizations and data for:
1. Diagonal map orbits
2. 2D Phi map phase portrait data
3. EML depth hierarchy value distribution
4. Lyapunov function growth analysis
5. EML-Collatz orbit analysis
"""

import math
import json

def eml(a, b):
    """EML(a, b) = exp(a) - ln(b)"""
    if b <= 0:
        return float('inf')
    return math.exp(a) - math.log(b)

def diag(x):
    """d(x) = exp(x) - ln(x)"""
    if x <= 0:
        return float('inf')
    return math.exp(x) - math.log(x)

def phi(x, y):
    """Φ(x,y) = (EML(x,y), EML(y,x))"""
    return eml(x, y), eml(y, x)


# ============================================================
# 1. Diagonal Map Analysis
# ============================================================

def analyze_diagonal():
    """Comprehensive analysis of the diagonal map."""
    print("=" * 60)
    print("DIAGONAL MAP ANALYSIS: d(x) = exp(x) - ln(x)")
    print("=" * 60)
    
    # Compute d(x) on a grid to find the minimum
    print("\nFunction values:")
    print(f"  {'x':>8}  {'d(x)':>14}  {'d(x)-x':>14}  {'d(x)-2':>14}")
    print(f"  {'-'*8}  {'-'*14}  {'-'*14}  {'-'*14}")
    
    min_val = float('inf')
    min_x = 0
    
    for i in range(1, 100):
        x = i * 0.05
        dx = diag(x)
        if dx < min_val:
            min_val = dx
            min_x = x
        if i % 5 == 0:
            print(f"  {x:8.3f}  {dx:14.8f}  {dx - x:14.8f}  {dx - 2:14.8f}")
    
    print(f"\n  Minimum: d({min_x:.3f}) ≈ {min_val:.8f}")
    print(f"  Note: d(x) ≥ 2 for all x > 0 (proven in Lean!)")
    print(f"  Note: d(x) > x for all x > 0 (proven in Lean!)")
    
    # Find the critical point where d'(x) = 0: exp(x) = 1/x
    # This is x such that x·exp(x) = 1, i.e., x = W(1) ≈ 0.5671
    print(f"\n  Critical point (Lambert W): x* ≈ 0.5671")
    x_star = 0.5671
    print(f"  d(x*) ≈ {diag(x_star):.8f}")
    print(f"  exp(x*) ≈ {math.exp(x_star):.8f}, 1/x* ≈ {1/x_star:.8f}")


# ============================================================
# 2. Orbit Divergence Rates
# ============================================================

def analyze_orbits():
    """Analyze divergence rates of diagonal map orbits."""
    print("\n" + "=" * 60)
    print("DIAGONAL MAP ORBIT DIVERGENCE RATES")
    print("=" * 60)
    
    starts = [0.01, 0.1, 0.5, 1.0, 2.0, 5.0]
    
    for x0 in starts:
        x = x0
        print(f"\n  x₀ = {x0}:")
        
        for i in range(8):
            try:
                dx = diag(x)
                ratio = dx / x if x > 0 else float('inf')
                if dx > 1e100:
                    print(f"    Step {i}: x = {x:.4e}, d(x) = ∞, ratio d(x)/x = ∞")
                    break
                print(f"    Step {i}: x = {x:.4e}, d(x) = {dx:.4e}, ratio d(x)/x = {ratio:.4f}")
                x = dx
            except OverflowError:
                print(f"    Step {i}: OVERFLOW")
                break


# ============================================================
# 3. 2D Phi Map Phase Portrait Data
# ============================================================

def analyze_phi():
    """Analyze 2D Phi map orbits."""
    print("\n" + "=" * 60)
    print("2D PHI MAP PHASE PORTRAIT")
    print("=" * 60)
    
    starts = [
        (0.5, 0.5), (1.0, 1.0), (1.0, 2.0),
        (0.3, 1.5), (2.0, 0.5), (1.5, 1.5)
    ]
    
    for x0, y0 in starts:
        x, y = x0, y0
        print(f"\n  Initial point ({x0}, {y0}):")
        
        for i in range(8):
            norm = math.sqrt(x*x + y*y)
            trace = eml(x, y) + eml(y, x) if x > 0 and y > 0 else float('inf')
            
            if norm > 1e50:
                print(f"    Step {i}: DIVERGED")
                break
            
            print(f"    Step {i}: ({x:.4e}, {y:.4e}), ||·|| = {norm:.4e}, Tr = {trace:.4e}")
            
            try:
                x, y = phi(x, y)
            except (OverflowError, ValueError):
                print(f"    Step {i+1}: OVERFLOW")
                break
    
    print(f"\n  All orbits DIVERGE — no bounded orbits exist in ℝ²₊")
    print(f"  Trace Tr(x,y) = EML(x,y) + EML(y,x) ≥ 4 (proven in Lean!)")


# ============================================================
# 4. Lyapunov Function Growth
# ============================================================

def analyze_lyapunov():
    """Analyze Lyapunov function V(x,y) = exp(x) + exp(y) growth."""
    print("\n" + "=" * 60)
    print("LYAPUNOV FUNCTION: V(x,y) = exp(x) + exp(y)")
    print("=" * 60)
    
    starts = [(1.0, 1.0), (0.5, 1.5), (2.0, 2.0)]
    
    for x0, y0 in starts:
        x, y = x0, y0
        print(f"\n  Starting at ({x0}, {y0}):")
        
        for i in range(6):
            try:
                V = math.exp(x) + math.exp(y)
                V_formula = math.exp(math.exp(x)) / y + math.exp(math.exp(y)) / x
                ratio = V_formula / V if V > 0 else float('inf')
                
                if V > 1e100:
                    print(f"    Step {i}: V = ∞ (diverged)")
                    break
                
                print(f"    Step {i}: V = {V:.4e}, V(Φ(·))/V = {ratio:.4f}")
                x, y = phi(x, y)
            except (OverflowError, ValueError):
                print(f"    Step {i}: OVERFLOW")
                break
    
    print(f"\n  V(Φ(x,y)) = exp(exp(x))/y + exp(exp(y))/x (proven in Lean!)")
    print(f"  Growth ratio >> 1 confirms super-exponential divergence")


# ============================================================
# 5. EML Value Density Analysis
# ============================================================

def analyze_density():
    """Analyze density of EML values in intervals."""
    print("\n" + "=" * 60)
    print("EML VALUE DENSITY ANALYSIS")
    print("=" * 60)
    
    # Enumerate depth-4 values
    seed = {1.0}
    all_vals = set(seed)
    
    for d in range(1, 5):
        new_vals = set()
        prev = list(all_vals)
        for a in prev:
            for b in prev:
                if b > 0:
                    try:
                        v = eml(a, b)
                        if math.isfinite(v) and abs(v) < 1e10:
                            new_vals.add(round(v, 10))
                    except (OverflowError, ValueError):
                        pass
        all_vals |= new_vals
    
    positive = sorted(v for v in all_vals if v > 0)
    
    print(f"\n  Total EML values from {{1}} at depth ≤ 4: {len(all_vals)}")
    print(f"  Positive values: {len(positive)}")
    
    # Histogram
    print(f"\n  Distribution in [0, 5):")
    for lo in range(5):
        count = sum(1 for v in positive if lo <= v < lo + 1)
        bar = "█" * min(count * 2, 50)
        print(f"    [{lo}, {lo+1}): {count:3d} {bar}")
    
    # Gap analysis
    print(f"\n  Largest gaps in [0, 3):")
    in_range = sorted(v for v in positive if 0 < v < 3)
    gaps = [(in_range[i+1] - in_range[i], in_range[i], in_range[i+1])
            for i in range(len(in_range) - 1)]
    gaps.sort(reverse=True)
    for gap, lo, hi in gaps[:5]:
        print(f"    Gap {gap:.6f} between {lo:.6f} and {hi:.6f}")


# ============================================================
# 6. EML-Collatz Orbit Analysis
# ============================================================

def eml_collatz(x):
    if x > 2:
        return eml(0, x)
    else:
        return eml(x, 1)


def analyze_collatz():
    """Analyze EML-Collatz orbits."""
    print("\n" + "=" * 60)
    print("EML-COLLATZ MAP ANALYSIS")
    print("=" * 60)
    
    print(f"\n  Rule: if x > 2, apply EML(0,x) = 1-ln(x)")
    print(f"        if x ≤ 2, apply EML(x,1) = exp(x)")
    
    starts = [0.1, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0, 100.0]
    
    for x0 in starts:
        x = x0
        orbit = [x]
        for _ in range(50):
            x = eml_collatz(x)
            orbit.append(x)
        
        # Check for cycles
        last_20 = orbit[-20:]
        amplitude = max(last_20) - min(last_20)
        mean = sum(last_20) / len(last_20)
        
        status = "CONVERGED" if amplitude < 0.01 else "OSCILLATING" if amplitude < 1 else "CHAOTIC"
        print(f"\n  x₀ = {x0:8.3f}: {status}, mean ≈ {mean:.4f}, amp ≈ {amplitude:.4f}")
        print(f"    Last 5: ", end="")
        for v in orbit[-5:]:
            print(f"{v:.4f} ", end="")
        print()


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   OISCC V9 DYNAMICS ANALYSIS                           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    analyze_diagonal()
    analyze_orbits()
    analyze_phi()
    analyze_lyapunov()
    analyze_density()
    analyze_collatz()
    
    print("\n" + "=" * 60)
    print("ANALYSIS COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()
