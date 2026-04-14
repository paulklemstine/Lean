#!/usr/bin/env python3
"""
Pell Recurrence and Growth Rate Analysis
==========================================
Demonstrates the Pell recurrence along the B-branch and growth rate
classification across all branches of the Berggren tree.
"""

import math

def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def main():
    print("=" * 70)
    print("PELL RECURRENCE AND GROWTH RATE ANALYSIS")
    print("=" * 70)

    # Part 1: Pell recurrence verification
    print("\n§1. B-Branch Pell Recurrence: c_{n+2} = 6·c_{n+1} - c_n")
    print("-" * 55)
    triple = (3, 4, 5)
    hyps = [5]
    triples_list = [(3, 4, 5)]
    for i in range(12):
        triple = berggren_B(*triple)
        hyps.append(triple[2])
        triples_list.append(triple)

    print(f"{'n':>3} {'c_n':>18} {'6c_{n-1}-c_{n-2}':>18} {'Ratio':>12}")
    print("-" * 55)
    for i, c in enumerate(hyps):
        if i >= 2:
            pred = 6 * hyps[i-1] - hyps[i-2]
            ratio = c / hyps[i-1]
            match = "✓" if pred == c else "✗"
            print(f"{i:>3} {c:>18} {pred:>18} {ratio:>12.8f} {match}")
        elif i == 1:
            print(f"{i:>3} {c:>18} {'—':>18} {c/hyps[0]:>12.8f}")
        else:
            print(f"{i:>3} {c:>18} {'—':>18} {'—':>12}")

    golden = 3 + 2 * math.sqrt(2)
    print(f"\nLimit ratio: 3 + 2√2 = {golden:.10f}")
    print(f"This is the larger root of x² - 6x + 1 = 0")

    # Part 2: All branch growth rates
    print(f"\n\n§2. Growth Rates by Branch")
    print("-" * 55)

    branches = {
        'A (left)': berggren_A,
        'B (middle)': berggren_B,
        'C (right)': berggren_C,
    }

    for name, func in branches.items():
        triple = (3, 4, 5)
        hyps = [5]
        for _ in range(20):
            triple = func(*triple)
            hyps.append(triple[2])
        ratios = [hyps[i] / hyps[i-1] for i in range(1, len(hyps))]
        print(f"\n  {name}:")
        print(f"    Limit ratio: {ratios[-1]:.10f}")
        print(f"    First 5 hypotenuses: {hyps[:5]}")
        print(f"    Ratio convergence: {' → '.join(f'{r:.4f}' for r in ratios[:6])}")

    # Part 3: Mixed paths
    print(f"\n\n§3. Mixed Path Growth Rates")
    print("-" * 55)

    patterns = [
        ("AB repeated", [berggren_A, berggren_B]),
        ("AC repeated", [berggren_A, berggren_C]),
        ("BC repeated", [berggren_B, berggren_C]),
        ("ABC repeated", [berggren_A, berggren_B, berggren_C]),
        ("AAB repeated", [berggren_A, berggren_A, berggren_B]),
    ]

    for name, funcs in patterns:
        triple = (3, 4, 5)
        hyps = [5]
        for i in range(30):
            f = funcs[i % len(funcs)]
            triple = f(*triple)
            hyps.append(triple[2])
        # Compute geometric mean growth rate
        geom_rate = (hyps[-1] / hyps[0]) ** (1.0 / len(hyps))
        period_rate = (hyps[-1] / hyps[-1-len(funcs)]) ** (1.0 / len(funcs)) if len(hyps) > len(funcs) else 0
        print(f"  {name:>20}: geometric mean rate ≈ {geom_rate:.6f}, "
              f"periodic rate ≈ {period_rate:.6f}")

    # Part 4: Eigenvalue analysis
    print(f"\n\n§4. Eigenvalue Analysis")
    print("-" * 55)

    try:
        import numpy as np

        B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=float)
        B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=float)
        B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=float)

        for name, B in [("B₁", B1), ("B₂", B2), ("B₃", B3)]:
            evals = np.linalg.eigvals(B)
            evals_sorted = sorted(evals, key=lambda x: abs(x), reverse=True)
            print(f"\n  {name} eigenvalues: {', '.join(f'{e:.6f}' for e in evals_sorted)}")
            print(f"      |eigenvalues|: {', '.join(f'{abs(e):.6f}' for e in evals_sorted)}")
            print(f"      spectral radius: {max(abs(e) for e in evals):.6f}")

        # Lyapunov exponent spectrum
        print(f"\n\n§5. Lyapunov Exponent Spectrum")
        print("-" * 55)
        print(f"  Pure A: log(spectral radius) = {math.log(max(abs(e) for e in np.linalg.eigvals(B1))):.6f}")
        print(f"  Pure B: log(spectral radius) = {math.log(max(abs(e) for e in np.linalg.eigvals(B2))):.6f}")
        print(f"  Pure C: log(spectral radius) = {math.log(max(abs(e) for e in np.linalg.eigvals(B3))):.6f}")

        # Mixed products
        for name, prod in [("AB", B1@B2), ("AC", B1@B3), ("BC", B2@B3), ("ABC", B1@B2@B3)]:
            sr = max(abs(e) for e in np.linalg.eigvals(prod))
            lyap = math.log(sr) / len(name)
            print(f"  {name}: Lyapunov exponent = {lyap:.6f}")

    except ImportError:
        print("  (NumPy not available)")

    print(f"\n\nConclusion: The Lyapunov exponent spectrum for mixed paths is")
    print(f"likely a Cantor-like set between the pure A/C value and the pure B value.")

if __name__ == "__main__":
    main()
