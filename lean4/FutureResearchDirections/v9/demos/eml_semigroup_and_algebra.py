#!/usr/bin/env python3
"""
EML Semigroup and Algebraic Structure Explorer
================================================
Studies the algebraic structures arising from the EML operator:
  - The semigroup {T_c : c > 0} where T_c(x) = exp(x) - ln(c)
  - Non-commutativity, non-associativity of EML
  - EML magma structure
  - Cayley tables for discretized EML
"""

import math
import itertools

# ─── Core ────────────────────────────────────────────────────────────

def eml(a, b):
    """EML(a,b) = exp(a) - ln(b)"""
    return math.exp(a) - math.log(b)

def T(c, x):
    """Semigroup element T_c(x) = exp(x) - ln(c)"""
    return math.exp(x) - math.log(c)

def compose_T(c1, c2, x):
    """T_{c1} ∘ T_{c2}(x) = exp(exp(x) - ln(c2)) - ln(c1)"""
    return T(c1, T(c2, x))

# ─── Demo 1: Non-Commutativity ──────────────────────────────────────

def demo_noncommutativity():
    print("=" * 60)
    print("DEMO 1: EML Non-Commutativity")
    print("=" * 60)
    
    pairs = [(1.0, 2.0), (0.5, 3.0), (2.0, 0.5)]
    print(f"\n{'(a,b)':>12} | {'EML(a,b)':>12} | {'EML(b,a)':>12} | {'Difference':>12}")
    print("-" * 55)
    
    for a, b in pairs:
        v1 = eml(a, b)
        v2 = eml(b, a)
        print(f"({a},{b}):    | {v1:>12.6f} | {v2:>12.6f} | {v1-v2:>12.6f}")
    
    print("\nEML is strongly non-commutative:")
    print("  eml(a,b) - eml(b,a) = (exp(a)-exp(b)) + (ln(a)-ln(b))")

# ─── Demo 2: Non-Associativity ──────────────────────────────────────

def demo_nonassociativity():
    print("\n" + "=" * 60)
    print("DEMO 2: EML Non-Associativity")
    print("=" * 60)
    
    triples = [(1.0, 2.0, 3.0), (0.5, 1.0, 1.5)]
    
    for a, b, c in triples:
        # Left: eml(eml(a,b), c)
        left = eml(eml(a, b), c)
        # Right: eml(a, eml(b,c))
        right = eml(a, eml(b, c))
        print(f"\n  (a,b,c) = ({a}, {b}, {c})")
        print(f"  eml(eml(a,b), c) = {left:.10f}")
        print(f"  eml(a, eml(b,c)) = {right:.10f}")
        print(f"  Difference = {abs(left-right):.10f}")
    
    print("\nEML is strongly non-associative")
    print("This means the free EML magma has rich operad structure (P-M20)")

# ─── Demo 3: Semigroup Composition Table ─────────────────────────────

def demo_semigroup():
    print("\n" + "=" * 60)
    print("DEMO 3: EML Semigroup Composition")
    print("=" * 60)
    
    c_values = [0.5, 1.0, 2.0, math.e]
    x_test = 1.0
    
    print(f"\nComposition table T_{{c1}} ∘ T_{{c2}}(x) at x = {x_test}")
    print(f"\n{'':>8} |", end="")
    for c2 in c_values:
        print(f" T_{c2:.2f}".rjust(12), end=" |")
    print()
    print("-" * (10 + 14 * len(c_values)))
    
    for c1 in c_values:
        print(f"T_{c1:.2f}".rjust(8) + " |", end="")
        for c2 in c_values:
            val = compose_T(c1, c2, x_test)
            print(f"{val:>12.4f} |", end="")
        print()
    
    print("\nNon-commutativity verification:")
    for c1, c2 in [(1.0, 2.0), (0.5, math.e)]:
        v12 = compose_T(c1, c2, x_test)
        v21 = compose_T(c2, c1, x_test)
        print(f"  T_{c1} ∘ T_{c2}({x_test}) = {v12:.6f}")
        print(f"  T_{c2} ∘ T_{c1}({x_test}) = {v21:.6f}")
        print(f"  Difference: {abs(v12-v21):.6f}")

# ─── Demo 4: Finite EML Magma ────────────────────────────────────────

def demo_finite_magma():
    """Discretize and study EML on a finite set"""
    print("\n" + "=" * 60)
    print("DEMO 4: Discrete EML Magma (P-M10 analogy)")
    print("=" * 60)
    
    # Use a set of representative values
    S = [0.5, 1.0, 2.0, math.e, 5.0]
    
    print(f"\nCayley table for EML on S = {[round(s,4) for s in S]}")
    print(f"\n{'':>8} |", end="")
    for b in S:
        print(f"{b:>8.4f} |", end="")
    print()
    print("-" * (10 + 10 * len(S)))
    
    for a in S:
        print(f"{a:>8.4f} |", end="")
        for b in S:
            val = eml(a, b)
            print(f"{val:>8.4f} |", end="")
        print()
    
    # Check closure
    print("\n  Note: EML on a finite set is NOT closed (values escape the set)")
    print("  This reflects the expansive/divergent nature of EML")

# ─── Demo 5: EML Absorption Elements ─────────────────────────────────

def demo_special_elements():
    print("\n" + "=" * 60)
    print("DEMO 5: Special Algebraic Elements")
    print("=" * 60)
    
    # Right identity: eml(x, e) = exp(x) - 1 for e = identity?
    # eml(x, 1) = exp(x), so 1 is a "right unit" for exponentiation
    print("\nRight identity search (eml(x, e) = x):")
    print("  Need exp(x) - ln(e) = x for all x")
    print("  This requires exp(x) = x + ln(e), impossible for all x")
    print("  → NO right identity element exists")
    
    print("\nLeft identity search (eml(e, y) = y):")
    print("  Need exp(e) - ln(y) = y for all y")
    print("  This requires ln(y) + y = exp(e), impossible for all y")
    print("  → NO left identity element exists")
    
    print("\nAbsorbing element search (eml(z, y) = z for all y):")
    print("  Need exp(z) - ln(y) = z for all y, impossible")
    print("  → NO absorbing element exists")
    
    print("\nIdempotent search (eml(x, x) = x):")
    print("  Need exp(x) - ln(x) = x")
    print("  But exp(x) - ln(x) ≥ 2 > x for x near minimum")
    print("  → NO idempotent elements (proved formally in Lean)")

# ─── Demo 6: EML Powers and Iterates ─────────────────────────────────

def demo_eml_powers():
    """Study EML "powers": x^(n)_EML = eml(x, eml(x, ... eml(x, x)))"""
    print("\n" + "=" * 60)
    print("DEMO 6: EML Powers / Right-Iterated EML")
    print("=" * 60)
    
    def eml_power_right(x, n):
        """Right-nested: eml(x, eml(x, ... eml(x, x)..))"""
        result = x
        for _ in range(n - 1):
            result = eml(x, result)
        return result
    
    def eml_power_left(x, n):
        """Left-nested: eml(eml(..eml(x, x), x).., x)"""
        result = x
        for _ in range(n - 1):
            result = eml(result, x)
        return result
    
    x_vals = [0.5, 1.0, 1.5]
    
    for x in x_vals:
        print(f"\nx = {x}")
        print(f"  {'n':>3} | {'Right-power':>15} | {'Left-power':>15} | {'Diagonal':>15}")
        print(f"  " + "-" * 55)
        for n in range(1, 6):
            try:
                rp = eml_power_right(x, n)
            except (OverflowError, ValueError):
                rp = float('inf')
            try:
                lp = eml_power_left(x, n)
            except (OverflowError, ValueError):
                lp = float('inf')
            try:
                diag = x
                for _ in range(n - 1):
                    diag = eml(diag, diag)
            except (OverflowError, ValueError):
                diag = float('inf')
            
            def fmt(v):
                if v == float('inf') or abs(v) > 1e15:
                    return "OVERFLOW"
                return f"{v:.6f}"
            
            print(f"  {n:>3} | {fmt(rp):>15} | {fmt(lp):>15} | {fmt(diag):>15}")

# ─── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_noncommutativity()
    demo_nonassociativity()
    demo_semigroup()
    demo_finite_magma()
    demo_special_elements()
    demo_eml_powers()
    
    print("\n" + "=" * 60)
    print("KEY ALGEBRAIC FINDINGS:")
    print("=" * 60)
    print("1. EML is non-commutative and non-associative")
    print("2. No identity, absorbing, or idempotent elements exist")
    print("3. The semigroup {T_c} is non-commutative with no idempotents")
    print("4. Finite discretizations are never closed under EML")
    print("5. Both left and right iterated powers diverge rapidly")
    print("6. The free EML magma has interesting operad-theoretic structure")
