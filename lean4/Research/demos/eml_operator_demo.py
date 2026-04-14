#!/usr/bin/env python3
"""
EML Operator Demo: Fixed Points, Dynamics, and Pythagorean Connection
======================================================================

The EML (Exp-Minus-Log) operator: eml(x, y) = exp(x) - ln(y)

This demo explores:
1. EML as a universal generator of elementary functions
2. Fixed-point bifurcation analysis
3. Lambert W function connection
4. Iteration dynamics
5. The bridge to Pythagorean triples
"""

import math
from functools import lru_cache

def eml(x, y):
    """The EML operator: eml(x, y) = exp(x) - ln(y)"""
    return math.exp(x) - math.log(y)

def main():
    print("=" * 70)
    print("EML OPERATOR: exp(x) - ln(y)")
    print("Universal Generator of Elementary Functions")
    print("=" * 70)

    # §1. EML generates exp and log
    print("\n§1. EML Generates All Elementary Functions")
    print("-" * 55)
    print(f"  eml(x, 1) = exp(x) - ln(1) = exp(x)")
    for x in [-2, -1, 0, 1, 2, 3]:
        val = eml(x, 1)
        ref = math.exp(x)
        print(f"    eml({x}, 1) = {val:.6f} = exp({x}) = {ref:.6f}")

    print(f"\n  1 - eml(0, x) = 1 - (1 - ln(x)) = ln(x)")
    for x in [0.5, 1, 2, math.e, 10]:
        val = 1 - eml(0, x)
        ref = math.log(x)
        print(f"    1 - eml(0, {x:.3f}) = {val:.6f} = ln({x:.3f}) = {ref:.6f}")

    # §2. Fixed-point analysis
    print(f"\n\n§2. Fixed-Point Bifurcation Analysis")
    print("-" * 55)
    print("  Fixed points: eml(x*, y) = x*  ⟺  exp(x*) - x* = ln(y)")
    print("  g(x) = exp(x) - x has minimum g(0) = 1")
    print(f"  So g(x) = target has solutions iff target ≥ 1 iff y ≥ e")
    print()

    def find_fixed_points(y, num_starts=20):
        """Find all fixed points of eml(·, y) numerically."""
        target = math.log(y)
        fps = []
        for x0 in [i * 0.5 - 5 for i in range(num_starts)]:
            x = x0
            for _ in range(200):
                try:
                    f = math.exp(x) - x - target
                    fp = math.exp(x) - 1
                    if abs(fp) < 1e-15:
                        break
                    x = x - f / fp
                    if abs(x) > 100:
                        break
                except:
                    break
            try:
                if abs(math.exp(x) - x - target) < 1e-10:
                    if not any(abs(x - fp) < 1e-6 for fp in fps):
                        fps.append(x)
            except:
                pass
        fps.sort()
        return fps

    print(f"  {'y':>10} {'ln(y)':>10} {'FP_stable':>12} {'FP_unstable':>12} {'# FPs':>6}")
    print("  " + "-" * 55)

    for y in [0.5, 1.0, 2.0, 2.5, math.e - 0.01, math.e, math.e + 0.01, 4.0, 10.0, 50.0, 100.0]:
        fps = find_fixed_points(y)
        if len(fps) == 0:
            print(f"  {y:>10.4f} {math.log(y):>10.4f} {'—':>12} {'—':>12} {0:>6}")
        elif len(fps) == 1:
            print(f"  {y:>10.4f} {math.log(y):>10.4f} {fps[0]:>12.6f} {'—':>12} {1:>6}")
        else:
            stable = fps[0]  # lower one is stable (exp'(x*) < 1)
            unstable = fps[1]  # upper one is unstable
            print(f"  {y:>10.4f} {math.log(y):>10.4f} {stable:>12.6f} {unstable:>12.6f} {2:>6}")

    # §3. Lambert W connection
    print(f"\n\n§3. Lambert W Function Connection")
    print("-" * 55)
    print("  x* = -W_k(-1/y) - ln(y)")
    print("  W₀ branch → stable FP, W₋₁ branch → unstable FP")
    print()
    print("  The Lambert W function satisfies W(z)·exp(W(z)) = z")
    print("  It has two real branches for -1/e ≤ z < 0:")
    print("    W₀(z) ≥ -1 (principal branch)")
    print("    W₋₁(z) ≤ -1 (lower branch)")

    # §4. Iteration dynamics
    print(f"\n\n§4. Iteration Dynamics: z_{'{n+1}'} = eml(z_n, y)")
    print("-" * 55)

    for y in [1.0, math.e, 5.0, 10.0]:
        print(f"\n  y = {y:.4f}:")
        z = 0.0
        trajectory = [z]
        converged = False
        for i in range(20):
            try:
                z = eml(z, y)
                trajectory.append(z)
                if abs(z) > 1e10:
                    print(f"    Diverges to {'∞' if z > 0 else '-∞'} after {i+1} steps")
                    converged = True
                    break
                if i > 0 and abs(trajectory[-1] - trajectory[-2]) < 1e-10:
                    print(f"    Converges to x* = {z:.6f} after {i+1} steps")
                    converged = True
                    break
            except:
                print(f"    Overflow at step {i+1}")
                converged = True
                break
        if not converged:
            print(f"    After 20 steps: z = {z:.6f}")
        print(f"    First 8 values: {[f'{t:.4f}' for t in trajectory[:8]]}")

    # §5. EML encoding of arithmetic
    print(f"\n\n§5. EML Encoding of Integer Arithmetic")
    print("-" * 55)
    print("  Every integer computation can be expressed as an EML tree:")
    print()

    # Addition: a + b = ln(exp(a) · exp(b)) = ln(eml(a,1) · eml(b,1))
    a, b = 3, 4
    sum_val = math.log(eml(a, 1) * eml(b, 1))
    print(f"  {a} + {b} = ln(exp({a}) · exp({b})) = ln({eml(a,1):.4f} · {eml(b,1):.4f}) = {sum_val:.4f}")

    # Squaring: a² = (exp(ln(a)))² = exp(2·ln(a))
    for n in [3, 4, 5, 12, 13]:
        sq = eml(2 * math.log(n), 1)
        print(f"  {n}² = exp(2·ln({n})) = eml(2·ln({n}), 1) = {sq:.4f} ≈ {n**2}")

    # Pythagorean verification via EML
    print(f"\n  Pythagorean check via EML:")
    for a, b, c in [(3,4,5), (5,12,13), (8,15,17)]:
        a2 = eml(2 * math.log(a), 1)
        b2 = eml(2 * math.log(b), 1)
        c2 = eml(2 * math.log(c), 1)
        diff = abs(a2 + b2 - c2)
        print(f"  ({a},{b},{c}): {a}² + {b}² = {a2:.1f} + {b2:.1f} = {a2+b2:.1f} = {c2:.1f} = {c}² "
              f"(error: {diff:.2e})")

    # §6. EML tree size for Berggren
    print(f"\n\n§6. EML Tree Complexity for Berggren Transformations")
    print("-" * 55)
    print("  Each Berggren step is a linear transformation:")
    print("  B₁: (a,b,c) → (a-2b+2c, 2a-b+2c, 2a-2b+3c)")
    print()
    print("  In terms of EML nodes:")
    print("  • Each integer constant: 1 leaf")
    print("  • Each multiplication: 1 internal node (via exp(ln(a)+ln(b)))")
    print("  • Each addition: 1 internal node (via ln(exp(a)·exp(b)))")
    print("  • Each subtraction: 1 internal node")
    print()
    print("  Depth-d triple requires O(d) Berggren steps = O(d) EML nodes")
    print("  By the leaf counting theorem: #leaves = #internal_nodes + 1")
    print()

    # Count operations for one Berggren step
    # a' = a - 2b + 2c needs: 2 multiplications + 2 additions = ~4 internal nodes
    # Total for all three: ~12 internal nodes per step
    # So depth-d triple needs ~12d internal nodes
    print("  Estimated EML tree size per Berggren step: ~12 internal nodes")
    print("  For depth-d triple: ~12d + 13 total EML nodes")

    print(f"\n{'='*70}")
    print("  EML Demo Complete!")
    print(f"{'='*70}")

if __name__ == "__main__":
    main()
