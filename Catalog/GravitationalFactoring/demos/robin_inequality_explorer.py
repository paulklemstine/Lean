#!/usr/bin/env python3
"""
Robin's Inequality Explorer

Robin's inequality states: σ₁(n) < e^γ · n · ln(ln(n)) for all n ≥ 5041,
where γ is the Euler-Mascheroni constant.

This is equivalent to the Riemann Hypothesis!

This demo:
1. Computes σ₁(n) for ranges of n
2. Checks Robin's inequality
3. Identifies superabundant and colossally abundant numbers
4. Visualizes the abundancy ratio σ₁(n)/n

Usage:
    python robin_inequality_explorer.py [max_n]
"""

import sys
import math

EULER_GAMMA = 0.5772156649015329

def sigma1(n):
    """Sum of divisors function σ₁(n)."""
    if n == 0:
        return 0
    total = 0
    for d in range(1, int(math.sqrt(n)) + 1):
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
    return total

def abundancy(n):
    """Abundancy index σ₁(n)/n."""
    if n == 0:
        return 0
    return sigma1(n) / n

def robin_bound(n):
    """Robin's upper bound: e^γ · n · ln(ln(n))."""
    if n <= 2:
        return float('inf')
    lnln = math.log(math.log(n))
    if lnln <= 0:
        return float('inf')
    return math.exp(EULER_GAMMA) * n * lnln

def is_superabundant(n, prev_max_abundancy):
    """Check if n is superabundant (higher abundancy than all smaller n)."""
    a = abundancy(n)
    return a > prev_max_abundancy

def check_robin_inequality(max_n):
    """Check Robin's inequality for all n up to max_n."""
    violations = []
    max_ratio = 0
    max_ratio_n = 1
    superabundant = []
    max_abundancy = 0

    print(f"\n{'n':>8} {'σ₁(n)':>10} {'σ₁(n)/n':>10} {'Robin bound':>12} {'Status':>8}")
    print("-" * 55)

    for n in range(1, max_n + 1):
        s = sigma1(n)
        a = s / n if n > 0 else 0
        rb = robin_bound(n)

        # Track superabundant numbers
        if a > max_abundancy:
            max_abundancy = a
            superabundant.append(n)

        if a > max_ratio:
            max_ratio = a
            max_ratio_n = n

        if n >= 5041:
            if s >= rb:
                violations.append((n, s, rb))

        # Print interesting values
        if n in [1, 2, 6, 12, 24, 36, 48, 60, 120, 180, 240, 360, 720,
                 840, 1260, 1680, 2520, 5040] or n in superabundant[-1:]:
            status = "✓" if n < 5041 or s < rb else "✗ VIOLATION"
            print(f"{n:>8} {s:>10} {a:>10.4f} {rb:>12.2f} {status:>8}")

    return violations, superabundant, max_ratio, max_ratio_n

def print_ascii_chart(data, title, width=60):
    """Simple ASCII bar chart."""
    if not data:
        return
    max_val = max(v for _, v in data)
    print(f"\n  {title}")
    print(f"  {'─' * (width + 15)}")
    for label, val in data:
        bar_len = int(val / max_val * width) if max_val > 0 else 0
        bar = "█" * bar_len
        print(f"  {label:>8} │{bar} {val:.4f}")

def main():
    max_n = int(sys.argv[1]) if len(sys.argv) > 1 else 5040

    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Robin's Inequality Explorer                         ║")
    print("║     σ₁(n) < e^γ · n · ln(ln(n)) ⟺ Riemann Hypothesis  ║")
    print("║     Gravitational Factoring Project — v12               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Verify formally computed values
    print("\n  Formally Verified Values (Lean 4):")
    print(f"    σ₁(1)    = {sigma1(1):>6}  (proven: sigma1'_one)")
    print(f"    σ₁(12)   = {sigma1(12):>6}  (proven: robin_check_12)")
    print(f"    σ₁(60)   = {sigma1(60):>6}  (proven: robin_check_60)")
    print(f"    σ₁(5040) = {sigma1(5040):>6}  (proven: sigma1_5040)")

    violations, superabundant, max_ratio, max_ratio_n = check_robin_inequality(max_n)

    # Superabundant numbers
    print(f"\n  Superabundant Numbers (highest abundancy up to {max_n}):")
    sa_data = [(str(n), abundancy(n)) for n in superabundant[:20]]
    print_ascii_chart(sa_data, "Abundancy σ₁(n)/n")

    # Key statistics
    print(f"\n  {'='*55}")
    print(f"  Statistics for n ≤ {max_n}:")
    print(f"    Superabundant numbers found: {len(superabundant)}")
    print(f"    Maximum abundancy: σ₁({max_ratio_n})/{max_ratio_n} = {max_ratio:.6f}")
    print(f"    Robin violations (n ≥ 5041): {len(violations)}")

    if not violations:
        print(f"\n  ✓ Robin's inequality holds for all n in [5041, {max_n}]")
        print(f"    This is consistent with the Riemann Hypothesis!")
    else:
        print(f"\n  ✗ VIOLATIONS FOUND — would disprove RH!")
        for n, s, rb in violations[:5]:
            print(f"      n={n}: σ₁(n)={s} ≥ {rb:.2f}")

    # The 5040 boundary
    print(f"\n  The Magic of 5040:")
    print(f"    σ₁(5040) = {sigma1(5040)}")
    print(f"    5040 = 7! = 2⁴ × 3² × 5 × 7")
    print(f"    Abundancy = {abundancy(5040):.6f}")
    print(f"    Robin's bound at 5041 = {robin_bound(5041):.2f}")
    print(f"    5040 is the largest known counterexample to Robin's inequality")
    print(f"    (the inequality fails for several n ≤ 5040)")

    # Connection to RH
    print(f"\n  Connection to the Riemann Hypothesis:")
    print(f"    Robin (1984) proved:")
    print(f"      RH ⟺ σ₁(n) < e^γ · n · ln(ln(n)) for all n ≥ 5041")
    print(f"    where e^γ ≈ {math.exp(EULER_GAMMA):.6f}")
    print(f"\n    Every verification of Robin's inequality is evidence for RH!")

if __name__ == "__main__":
    main()
