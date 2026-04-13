#!/usr/bin/env python3
"""
Dickman Function Demo
=====================
Computes and visualizes the Dickman function ρ(u) on [0, 5],
demonstrates smooth number counting, and shows the L-notation
complexity curve for factoring algorithms.
"""

import math
from functools import lru_cache

# ============================================================
# §1. Dickman Function Computation
# ============================================================

def dickman_base(u):
    """Dickman ρ(u) on [0, 2] (closed form)."""
    if u <= 0:
        return 0.0
    elif u <= 1:
        return 1.0
    elif u <= 2:
        return 1.0 - math.log(u)
    else:
        return None  # Need numerical integration

def dickman_numerical(u, steps=1000):
    """
    Compute ρ(u) numerically using the integral equation:
        ρ(u) = 1 - ∫₁ᵘ ρ(t-1)/t dt    for u ≥ 1
    
    We use piece-wise computation on intervals [k, k+1].
    """
    if u <= 0:
        return 0.0
    if u <= 1:
        return 1.0
    if u <= 2:
        return 1.0 - math.log(u)
    
    # For u in [2, 3], ρ(u) = 1 - ∫₁ᵘ ρ(t-1)/t dt
    # On [1,2]: ρ(t-1)/t = 1/t since ρ(s) = 1 for s ∈ [0,1]
    # On [2,u]: ρ(t-1)/t = (1-ln(t-1))/t since ρ(s) = 1-ln(s) for s ∈ [1,2]
    
    # Build a lookup table
    dt = 0.001
    n_points = int(u / dt) + 2
    rho = [0.0] * n_points
    
    for i in range(n_points):
        t = i * dt
        if t <= 1:
            rho[i] = 1.0
        elif t <= 2:
            rho[i] = 1.0 - math.log(t)
        else:
            # ρ(t) = ρ(t - dt) - dt * ρ(t - 1) / t  (Euler method for the DDE)
            idx_prev = int((t - 1) / dt)
            if idx_prev >= 0 and idx_prev < len(rho):
                rho[i] = rho[i-1] - dt * rho[idx_prev] / t
            else:
                rho[i] = rho[i-1]
    
    idx = min(int(u / dt), n_points - 1)
    return rho[idx]


# ============================================================
# §2. Smooth Number Counting
# ============================================================

def is_smooth(n, B):
    """Check if n is B-smooth (all prime factors ≤ B)."""
    if n <= 1:
        return True
    temp = n
    for p in range(2, B + 1):
        while temp % p == 0:
            temp //= p
    return temp == 1

def smooth_count(x, y):
    """Count y-smooth numbers up to x: Ψ(x, y)."""
    return sum(1 for n in range(1, x + 1) if is_smooth(n, y))


# ============================================================
# §3. L-Notation
# ============================================================

def L_notation_log2(n, alpha, c):
    """log₂ of L_n[α, c] = c · n^α · (ln n)^{1-α} / ln 2."""
    if n <= 1:
        return 0.0
    ln_n = math.log(n)
    return c * (n ** alpha) * (ln_n ** (1 - alpha)) / math.log(2)


# ============================================================
# §4. Demo Output
# ============================================================

def main():
    print("=" * 70)
    print("DICKMAN FUNCTION DEMO")
    print("=" * 70)
    
    # Dickman function values
    print("\n§1. Dickman Function ρ(u) Values")
    print("-" * 40)
    print(f"{'u':>6} | {'ρ(u)':>12} | {'u^(-u) approx':>14}")
    print("-" * 40)
    
    test_values = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
    for u in test_values:
        rho = dickman_numerical(u)
        approx = u ** (-u) if u > 0 else 0
        print(f"{u:6.1f} | {rho:12.6f} | {approx:14.6f}")
    
    # Key values
    print(f"\nρ(1) = {dickman_numerical(1):.6f}  (exact: 1)")
    print(f"ρ(2) = {dickman_numerical(2):.6f}  (exact: 1 - ln 2 = {1 - math.log(2):.6f})")
    
    # Smooth number counting
    print("\n§2. Smooth Number Counting Ψ(x, y)")
    print("-" * 50)
    print(f"{'x':>8} | {'y':>4} | {'Ψ(x,y)':>8} | {'x·ρ(ln x/ln y)':>14} | {'Ratio':>8}")
    print("-" * 50)
    
    for x in [100, 1000, 10000]:
        for y in [5, 10, 20]:
            psi = smooth_count(x, y)
            u = math.log(x) / math.log(y) if y > 1 else 1
            rho = dickman_numerical(u)
            estimate = x * rho
            ratio = psi / estimate if estimate > 0 else 0
            print(f"{x:8d} | {y:4d} | {psi:8d} | {estimate:14.1f} | {ratio:8.3f}")
    
    # L-notation complexity
    print("\n§3. L-Notation Complexity for Factoring")
    print("-" * 60)
    print(f"{'Algorithm':>20} | {'α':>4} | {'c':>6} | {'log₂(L) for 2048-bit':>20}")
    print("-" * 60)
    
    n = 2048 * math.log(2)  # ln(N) for 2048-bit N
    
    algorithms = [
        ("Trial Division", 1.0, 0.5),
        ("Pollard rho", 1.0, 0.5),
        ("ECM", 0.5, 1.414),
        ("QS", 0.5, 1.0),
        ("GNFS", 1/3, 1.923),
        ("Brute Force", 1.0, 1.0),
    ]
    
    for name, alpha, c in algorithms:
        log2_L = L_notation_log2(n, alpha, c)
        print(f"{name:>20} | {alpha:4.2f} | {c:6.3f} | {log2_L:20.1f}")
    
    print("\n§4. GNFS Complexity: L[1/3, (64/9)^{1/3}]")
    c_gnfs = (64/9) ** (1/3)
    print(f"  c = (64/9)^(1/3) = {c_gnfs:.6f}")
    print(f"  For RSA-2048 (n ≈ {n:.1f}):")
    ln_n = math.log(n)
    exponent = c_gnfs * (n ** (1/3)) * (ln_n ** (2/3))
    print(f"  Exponent = {exponent:.1f}")
    print(f"  log₂(L) ≈ {exponent / math.log(2):.1f} bits of work")
    
    print("\n" + "=" * 70)
    print("CONCLUSION: The Dickman function connects smooth number")
    print("theory to factoring complexity via ρ(log x / log y).")
    print("=" * 70)

if __name__ == "__main__":
    main()
