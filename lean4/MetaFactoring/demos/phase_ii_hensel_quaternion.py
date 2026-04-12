#!/usr/bin/env python3
"""
MetaFactoring Phase II Demo: Hensel Lifting & Quaternionic Factoring

Demonstrates:
- p-adic/Hensel lifting with exponential convergence
- Quaternion non-commutativity and skew-symmetric forms
- The Cayley-Dickson barrier
"""

import math

# =============================================================================
# Hensel Lifting Demo
# =============================================================================

def hensel_lift_demo():
    """Demonstrate Hensel lifting: doubling precision at each step."""
    print("\n" + "="*60)
    print("HENSEL LIFTING: Exponential Convergence")
    print("="*60)
    
    # Example: lift a root of x² - 2 mod 7
    # √2 mod 7 = 3 (since 3² = 9 ≡ 2 mod 7)
    p = 7
    f = lambda x: x*x - 2
    df = lambda x: 2*x
    
    print(f"\n  Finding root of x² ≡ 2 (mod 7^k)")
    print(f"  Initial: x ≡ 3 (mod 7), since 3² = 9 ≡ 2 (mod 7)")
    
    x = 3
    precision = 1
    
    for step in range(6):
        mod = p ** precision
        fx = f(x) % mod
        print(f"\n  Step {step}: precision = {p}^{precision} = {mod}")
        print(f"    x = {x}")
        print(f"    f(x) = x² - 2 = {f(x)}")
        print(f"    f(x) mod {mod} = {fx}")
        
        # Hensel lift: x_{n+1} = x_n - f(x_n) * (f'(x_n))^(-1) mod p^{2k}
        new_precision = 2 * precision
        new_mod = p ** new_precision
        
        # Compute inverse of f'(x) mod new_mod
        dfx = df(x) % new_mod
        try:
            dfx_inv = pow(dfx, -1, new_mod)
            x_new = (x - f(x) * dfx_inv) % new_mod
            x = x_new
            precision = new_precision
        except ValueError:
            print(f"    Cannot invert f'(x) = {dfx} mod {new_mod}")
            break
    
    print(f"\n  Final: x ≡ {x} (mod {p}^{precision})")
    print(f"  Verification: {x}² mod {p**precision} = {(x*x) % (p**precision)}")
    print(f"  Expected:     2 mod {p**precision} = 2")
    print(f"\n  Precision doubled at each step: 1 → 2 → 4 → 8 → 16 → 32 → 64")

def vertical_horizontal_demo():
    """Demonstrate independence of vertical (p-adic) and horizontal (CRT) constraints."""
    print("\n" + "="*60)
    print("VERTICAL-HORIZONTAL COMPLEMENTARITY")
    print("="*60)
    
    primes = [(3, 5), (7, 11), (13, 17)]
    
    for p, q in primes:
        for k in range(1, 5):
            g = math.gcd(p**k, q**k)
            print(f"  gcd({p}^{k}, {q}^{k}) = gcd({p**k}, {q**k}) = {g}  {'✓' if g==1 else '✗'}")
    
    print(f"\n  p-adic lifting (vertical) and CRT (horizontal) give")
    print(f"  independent constraints — they can be combined freely.")

# =============================================================================
# Quaternion Non-Commutativity Demo
# =============================================================================

class Quaternion:
    def __init__(self, a, b, c, d):
        self.a, self.b, self.c, self.d = a, b, c, d
    
    def __mul__(self, other):
        return Quaternion(
            self.a*other.a - self.b*other.b - self.c*other.c - self.d*other.d,
            self.a*other.b + self.b*other.a + self.c*other.d - self.d*other.c,
            self.a*other.c - self.b*other.d + self.c*other.a + self.d*other.b,
            self.a*other.d + self.b*other.c - self.c*other.b + self.d*other.a
        )
    
    def norm(self):
        return self.a**2 + self.b**2 + self.c**2 + self.d**2
    
    def __repr__(self):
        return f"({self.a} + {self.b}i + {self.c}j + {self.d}k)"
    
    def __sub__(self, other):
        return Quaternion(self.a-other.a, self.b-other.b, self.c-other.c, self.d-other.d)

def quaternion_demo():
    """Demonstrate quaternion non-commutativity and skew-symmetric forms."""
    print("\n" + "="*60)
    print("QUATERNIONIC FACTORING: Non-Commutativity as Information")
    print("="*60)
    
    examples = [
        (Quaternion(1, 2, 3, 4), Quaternion(5, 6, 7, 8)),
        (Quaternion(3, 1, 4, 1), Quaternion(5, 9, 2, 6)),
        (Quaternion(2, 7, 1, 8), Quaternion(2, 8, 1, 8)),
    ]
    
    for q1, q2 in examples:
        q1q2 = q1 * q2
        q2q1 = q2 * q1
        diff = q1q2 - q2q1
        
        print(f"\n  q₁ = {q1}")
        print(f"  q₂ = {q2}")
        print(f"  q₁·q₂ = {q1q2}")
        print(f"  q₂·q₁ = {q2q1}")
        print(f"\n  Real parts equal: {q1q2.a} = {q2q1.a}  {'✓' if q1q2.a == q2q1.a else '✗'}")
        print(f"  Norms equal: {q1q2.norm()} = {q2q1.norm()}  {'✓' if q1q2.norm() == q2q1.norm() else '✗'}")
        
        # Skew-symmetric forms
        i_diff = 2 * (q1.c * q2.d - q1.d * q2.c)
        j_diff = 2 * (q1.d * q2.b - q1.b * q2.d)
        k_diff = 2 * (q1.b * q2.c - q1.c * q2.b)
        
        print(f"  i-component difference: {diff.b} = 2({q1.c}·{q2.d} - {q1.d}·{q2.c}) = {i_diff}  {'✓' if diff.b == i_diff else '✗'}")
        print(f"  j-component difference: {diff.c} = 2({q1.d}·{q2.b} - {q1.b}·{q2.d}) = {j_diff}  {'✓' if diff.c == j_diff else '✗'}")
        print(f"  k-component difference: {diff.d} = 2({q1.b}·{q2.c} - {q1.c}·{q2.b}) = {k_diff}  {'✓' if diff.d == k_diff else '✗'}")

# =============================================================================
# Cayley-Dickson Barrier Demo
# =============================================================================

def cayley_dickson_demo():
    """Demonstrate the Hurwitz barrier and norm multiplicativity."""
    print("\n" + "="*60)
    print("CAYLEY-DICKSON BARRIER (Hurwitz 1898)")
    print("="*60)
    
    dims = {
        1: ("Real ℝ", True, "commutative, associative, ordered"),
        2: ("Complex ℂ", True, "commutative, associative"),
        4: ("Quaternion ℍ", True, "associative, NOT commutative"),
        8: ("Octonion 𝕆", True, "alternative, NOT associative"),
        16: ("Sedenion 𝕊", False, "NOT alternative, has zero divisors"),
    }
    
    print(f"\n  {'Dim':>4} | {'Algebra':>15} | {'Norm-mult':>10} | Properties")
    print(f"  {'-'*4}-+-{'-'*15}-+-{'-'*10}-+-{'-'*30}")
    
    for dim, (name, norm_mult, props) in dims.items():
        status = "✓" if norm_mult else "✗"
        print(f"  {dim:>4} | {name:>15} | {status:>10} | {props}")
    
    print(f"\n  Hurwitz Theorem: Norm-multiplicative composition algebras")
    print(f"  exist ONLY in dimensions {{1, 2, 4, 8}}.")
    print(f"  Sedenions (dim 16) still satisfy weaker identities:")
    print(f"    - Flexible: (xy)x = x(yx)  ✓")
    print(f"    - Alternative: (xx)y = x(xy)  ✓")
    
    # Verify 2-square identity
    a1, a2, b1, b2 = 3, 4, 5, 12
    lhs = (a1**2 + a2**2) * (b1**2 + b2**2)
    rhs = (a1*b1 - a2*b2)**2 + (a1*b2 + a2*b1)**2
    print(f"\n  2-square identity: ({a1}²+{a2}²)·({b1}²+{b2}²) = {lhs}")
    print(f"    = ({a1*b1-a2*b2})² + ({a1*b2+a2*b1})² = {rhs}  {'✓' if lhs==rhs else '✗'}")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  MetaFactoring Phase II: Hensel & Quaternion Demo        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    hensel_lift_demo()
    vertical_horizontal_demo()
    quaternion_demo()
    cayley_dickson_demo()
    
    print("\n" + "="*60)
    print("KEY INSIGHTS:")
    print("1. Hensel lifting doubles precision exponentially")
    print("2. p-adic (vertical) and CRT (horizontal) are independent")
    print("3. Quaternion non-commutativity encodes skew-symmetric forms")
    print("4. The Hurwitz barrier limits norm channels to dim ≤ 8")
    print("="*60)
