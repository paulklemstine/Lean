#!/usr/bin/env python3
"""
Chaos Analysis of EML Dynamical Systems

Studies the dynamical systems arising from iterating the EML operator:
1. The diagonal map d(x) = exp(x) - ln(x)
2. The one-minus-log map g(x) = 1 - ln(x)
3. The 2D EML map Φ(x,y) = (eml(x,y), eml(y,x))
4. Lyapunov exponent computation
5. NIST-inspired randomness tests on EML sequences
"""

import math
import numpy as np
from collections import Counter

# ============================================================
# Core EML Operations
# ============================================================

def eml(a, b):
    """eml(a, b) = exp(a) - ln(b)"""
    return np.exp(a) - np.log(b)

# ============================================================
# 1. Diagonal Map: d(x) = exp(x) - ln(x)
# ============================================================

def diagonal_map(x):
    """d(x) = exp(x) - ln(x) for x > 0."""
    return np.exp(x) - np.log(x)

def diagonal_orbit(x0, n_steps):
    """Compute orbit of the diagonal map."""
    orbit = [x0]
    x = x0
    for _ in range(n_steps):
        x = diagonal_map(x)
        if np.isinf(x) or np.isnan(x):
            break
        orbit.append(x)
    return orbit

# ============================================================
# 2. One-Minus-Log Map: g(x) = 1 - ln(x)
# ============================================================

def one_minus_log(x):
    """g(x) = 1 - ln(x)."""
    return 1 - np.log(x)

def oml_orbit(x0, n_steps):
    """Compute orbit of the one-minus-log map."""
    orbit = [x0]
    x = x0
    for _ in range(n_steps):
        x = one_minus_log(x)
        if x <= 0 or np.isnan(x):
            break
        orbit.append(x)
    return orbit

# ============================================================
# 3. 2D EML Map
# ============================================================

def eml_2d_map(x, y):
    """Φ(x, y) = (eml(x, y), eml(y, x))."""
    return eml(x, y), eml(y, x)

def eml_2d_orbit(x0, y0, n_steps):
    """Compute orbit of the 2D EML map."""
    orbit = [(x0, y0)]
    x, y = x0, y0
    for _ in range(n_steps):
        x_new, y_new = eml_2d_map(x, y)
        if any(np.isnan(v) or np.isinf(v) for v in [x_new, y_new]):
            break
        x, y = x_new, y_new
        orbit.append((x, y))
    return orbit

# ============================================================
# 4. Lyapunov Exponent
# ============================================================

def lyapunov_exponent_oml(x0, n_steps=10000):
    """Compute Lyapunov exponent of the one-minus-log map.
    
    λ = lim (1/n) Σ ln|g'(x_i)| where g'(x) = -1/x.
    """
    x = x0
    lyap_sum = 0.0
    valid_steps = 0
    
    for _ in range(n_steps):
        if x <= 0 or np.isnan(x):
            break
        # g'(x) = -1/x, so |g'(x)| = 1/x
        lyap_sum += np.log(1.0 / abs(x))
        x = one_minus_log(x)
        valid_steps += 1
    
    return lyap_sum / valid_steps if valid_steps > 0 else float('nan')

def lyapunov_exponent_diagonal(x0, n_steps=100):
    """Compute Lyapunov exponent of the diagonal map.
    
    d'(x) = exp(x) - 1/x, so |d'(x)| for the Lyapunov sum.
    Note: the diagonal map diverges rapidly, so we use few steps.
    """
    x = x0
    lyap_sum = 0.0
    valid_steps = 0
    
    for _ in range(n_steps):
        if x <= 0 or np.isnan(x) or np.isinf(x) or x > 1e10:
            break
        deriv = np.exp(x) - 1.0/x
        if abs(deriv) > 0:
            lyap_sum += np.log(abs(deriv))
        x = diagonal_map(x)
        valid_steps += 1
    
    return lyap_sum / valid_steps if valid_steps > 0 else float('nan')

# ============================================================
# 5. Statistical Tests
# ============================================================

def frequency_test(bits, alpha=0.01):
    """Monobit frequency test (simplified NIST SP 800-22)."""
    n = len(bits)
    s = sum(2 * b - 1 for b in bits)
    s_obs = abs(s) / np.sqrt(n)
    from scipy.special import erfc
    p_value = erfc(s_obs / np.sqrt(2))
    return p_value > alpha, p_value

def runs_test(bits, alpha=0.01):
    """Runs test: counts consecutive sequences of identical bits."""
    n = len(bits)
    pi = sum(bits) / n
    if abs(pi - 0.5) >= 2 / np.sqrt(n):
        return False, 0.0
    
    runs = 1
    for i in range(1, n):
        if bits[i] != bits[i-1]:
            runs += 1
    
    from scipy.special import erfc
    num = abs(runs - 2 * n * pi * (1 - pi))
    den = 2 * np.sqrt(2 * n) * pi * (1 - pi)
    p_value = erfc(num / den) if den > 0 else 0.0
    return p_value > alpha, p_value

def generate_eml_bits(x0, n_bits, map_func):
    """Generate pseudo-random bits from EML iteration."""
    x = x0
    bits = []
    for _ in range(n_bits):
        x = map_func(x)
        if np.isnan(x) or np.isinf(x) or x <= 0:
            break
        # Extract bit from fractional part
        frac = x - math.floor(x)
        bits.append(1 if frac >= 0.5 else 0)
    return bits

# ============================================================
# Demonstrations
# ============================================================

def demo_diagonal_orbit():
    """Show how the diagonal map diverges."""
    print("=" * 70)
    print("DIAGONAL MAP ORBITS: d(x) = exp(x) - ln(x)")
    print("=" * 70)
    
    starting_points = [0.1, 0.5, 1.0, 2.0]
    
    for x0 in starting_points:
        orbit = diagonal_orbit(x0, 8)
        print(f"\nx₀ = {x0}:")
        for i, x in enumerate(orbit):
            if x < 1e15:
                print(f"  d^{i}(x₀) = {x:.6f}")
            else:
                print(f"  d^{i}(x₀) = {x:.3e}")
    
    print("\n→ The diagonal map diverges super-exponentially for all x₀ > 0")
    print("  This is proved formally: exp(x) - ln(x) > x for all x > 0")

def demo_oml_orbit():
    """Show the one-minus-log orbit near the fixed point."""
    print("\n" + "=" * 70)
    print("ONE-MINUS-LOG MAP: g(x) = 1 - ln(x)")
    print("=" * 70)
    
    print("\nFixed point: g(1) = 1 - ln(1) = 1 ✓")
    print("Derivative at fixed point: g'(1) = -1/1 = -1 (neutral!)")
    
    starting_points = [0.5, 0.9, 1.1, 2.0, math.e]
    
    for x0 in starting_points:
        orbit = oml_orbit(x0, 20)
        print(f"\nx₀ = {x0:.4f}:")
        for i, x in enumerate(orbit[:10]):
            dist = abs(x - 1.0)
            print(f"  g^{i:2d}(x₀) = {x:.8f}  (|x-1| = {dist:.2e})")
    
    # Lyapunov exponent
    lyap = lyapunov_exponent_oml(0.5, 10000)
    print(f"\nLyapunov exponent (x₀=0.5): λ ≈ {lyap:.6f}")
    print(f"  λ = 0 indicates neutral (marginally stable) dynamics")

def demo_2d_eml():
    """Show the 2D EML dynamical system."""
    print("\n" + "=" * 70)
    print("2D EML MAP: Φ(x,y) = (eml(x,y), eml(y,x))")
    print("=" * 70)
    
    x0, y0 = 0.5, 0.8
    orbit = eml_2d_orbit(x0, y0, 10)
    
    print(f"\n(x₀, y₀) = ({x0}, {y0})")
    for i, (x, y) in enumerate(orbit):
        if abs(x) < 1e10 and abs(y) < 1e10:
            print(f"  Φ^{i:2d} = ({x:.6f}, {y:.6f})")
        else:
            print(f"  Φ^{i:2d} = ({x:.3e}, {y:.3e})")
    
    print("\n→ The 2D map diverges due to exp domination")
    print("  Jacobian det = exp(x)exp(y) - 1/(xy) > 0 for x,y > 0")

def demo_randomness():
    """Test randomness of EML-generated sequences."""
    print("\n" + "=" * 70)
    print("RANDOMNESS ANALYSIS OF EML SEQUENCES")
    print("=" * 70)
    
    try:
        from scipy.special import erfc
        
        # Generate bits from one-minus-log iteration
        bits = generate_eml_bits(0.3, 10000, one_minus_log)
        
        if len(bits) >= 100:
            # Frequency test
            freq_pass, freq_p = frequency_test(bits)
            print(f"\nOne-minus-log map (x₀=0.3, {len(bits)} bits):")
            print(f"  Frequency test: {'PASS' if freq_pass else 'FAIL'} (p={freq_p:.6f})")
            
            # Runs test
            runs_pass, runs_p = runs_test(bits)
            print(f"  Runs test:      {'PASS' if runs_pass else 'FAIL'} (p={runs_p:.6f})")
            
            # Bit distribution
            ones = sum(bits)
            zeros = len(bits) - ones
            print(f"  Bit distribution: {ones} ones, {zeros} zeros ({ones/len(bits)*100:.1f}% ones)")
        else:
            print(f"  Only {len(bits)} valid bits generated (sequence collapsed)")
        
    except ImportError:
        print("\n(scipy not available for statistical tests)")
        bits = generate_eml_bits(0.3, 1000, one_minus_log)
        if bits:
            ones = sum(bits)
            print(f"\nBit distribution ({len(bits)} bits): {ones} ones ({ones/len(bits)*100:.1f}%)")

def demo_constant_complexity():
    """Explore EML complexity of mathematical constants."""
    print("\n" + "=" * 70)
    print("EML COMPLEXITY OF MATHEMATICAL CONSTANTS")
    print("=" * 70)
    
    # Known exact representations
    constants = {
        "1": (1.0, 0, "leaf"),
        "e": (math.e, 1, "eml(1,1)"),
        "e^e": (math.e**math.e, 2, "eml(eml(1,1), 1)"),
        "0": (0.0, 3, "eml(1, eml(eml(1,1), 1))"),
        "e-1": (math.e - 1, 2, "eml(1, eml(1,1))"),
        "e^(e^e)": (math.exp(math.e**math.e), 3, "eml(eml(eml(1,1),1),1)"),
        "1-e": (1 - math.e, 2, "eml(1, eml(1,1)) — wait, that's e-1"),
    }
    
    print(f"\n{'Constant':<12} {'Value':<20} {'EML nodes':<12} {'Expression'}")
    print("-" * 65)
    for name, (val, nodes, expr) in constants.items():
        if abs(val) < 1e10:
            print(f"{name:<12} {val:<20.10f} {nodes:<12} {expr}")
        else:
            print(f"{name:<12} {val:<20.3e} {nodes:<12} {expr}")
    
    # Search for pi approximation
    print(f"\nSearching for π in low-depth EML trees...")
    best_pi_approx = None
    best_pi_error = float('inf')
    
    # Level 2 values (all eml(a,b) where a,b ∈ {1, e, e^e, 0, e-1, ...})
    level_1_vals = {
        "1": 1.0,
        "e": math.e,
    }
    
    level_2_vals = {}
    for na, a in level_1_vals.items():
        for nb, b in level_1_vals.items():
            if b > 0:
                val = eml(a, b)
                name = f"eml({na},{nb})"
                level_2_vals[name] = val
    
    # Level 3: search all
    all_vals = {**level_1_vals, **level_2_vals}
    for na, a in all_vals.items():
        for nb, b in all_vals.items():
            if b > 0 and not np.isnan(b) and not np.isinf(b):
                try:
                    val = eml(a, b)
                    if not np.isnan(val) and not np.isinf(val):
                        err = abs(val - math.pi)
                        if err < best_pi_error:
                            best_pi_error = err
                            best_pi_approx = f"eml({na}, {nb}) = {val:.10f}"
                except:
                    pass
    
    print(f"  Best π approximation at depth ≤ 3:")
    print(f"    {best_pi_approx}")
    print(f"    Error: {best_pi_error:.6f}")
    print(f"    (π = {math.pi:.10f})")
    print(f"\n  Note: Computing π exactly requires deeper trees.")
    print(f"  Conjecture: K_EML(π) ≤ 40 nodes")

if __name__ == "__main__":
    demo_diagonal_orbit()
    demo_oml_orbit()
    demo_2d_eml()
    demo_randomness()
    demo_constant_complexity()
