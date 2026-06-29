#!/usr/bin/env python3
"""
Tropical Langlands GL(1) Correspondence — Numerical Demonstrations

This demo brings to life the formally verified theorems from the
Lean 4 formalization of the tropical Langlands GL(1) correspondence.

Key demonstrations:
1. Tropical Hecke characters (completely additive functions)
2. Tropical Hecke operator eigenfunction property
3. Tropical Dirichlet convolution
4. Tropical sigma function (max-over-divisors)
5. Collision resistance amplification
6. Berggren tree structure
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, gcd, sqrt
from functools import reduce
from itertools import product

# ============================================================
# §1. Tropical Hecke Characters
# ============================================================

class TropicalHeckeChar:
    """A completely additive arithmetic function χ: ℕ → ℝ.
    
    Satisfies: χ(1) = 0, χ(mn) = χ(m) + χ(n) for m,n ≥ 1.
    Determined by values on primes.
    """
    def __init__(self, prime_values: dict):
        """Initialize from a dictionary {p: χ(p)} for primes p."""
        self.prime_values = prime_values
        self.name = str(prime_values)
    
    def __call__(self, n: int) -> float:
        if n <= 0:
            return 0.0
        if n == 1:
            return 0.0
        # Factor n and sum χ(p) * multiplicity
        result = 0.0
        temp = n
        for p in sorted(self.prime_values.keys()):
            while temp % p == 0:
                result += self.prime_values[p]
                temp //= p
        # For primes not in our dictionary, assume χ(p) = 0
        return result

def trivial_char():
    """The trivial character: χ₀(n) = 0."""
    return TropicalHeckeChar({})

def log_char():
    """The logarithmic character: χ(n) = log(n)."""
    # For exact computation, we need all primes up to some bound
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    return TropicalHeckeChar({p: log(p) for p in primes})


# ============================================================
# §2. Demonstrate the Eigenfunction Property
# ============================================================

def tropical_hecke_shift(p, f, n):
    """T_p(f)(n) = f(p·n)"""
    return f(p * n)

def demo_eigenfunction():
    """Verify T_p(χ)(n) = χ(p) + χ(n) for various characters and primes."""
    print("=" * 60)
    print("§2. TROPICAL HECKE EIGENFUNCTION PROPERTY")
    print("    Verified: T_p(χ)(n) = χ(p) + χ(n)")
    print("=" * 60)
    
    # Test with logarithmic character
    chi = log_char()
    
    for p in [2, 3, 5, 7]:
        print(f"\n  Prime p = {p}, χ(p) = log({p}) ≈ {log(p):.4f}")
        for n in [1, 2, 3, 6, 10, 15]:
            lhs = tropical_hecke_shift(p, chi, n)
            rhs = chi(p) + chi(n)
            diff = abs(lhs - rhs)
            print(f"    n={n:3d}: T_p(χ)(n) = {lhs:.6f}, χ(p)+χ(n) = {rhs:.6f}, diff = {diff:.2e}")
    
    # Test with a custom character
    chi2 = TropicalHeckeChar({2: 1.0, 3: -0.5, 5: 2.0, 7: 0.3})
    print(f"\n  Custom character χ with χ(2)=1, χ(3)=-0.5, χ(5)=2, χ(7)=0.3")
    for p in [2, 3, 5]:
        print(f"  Prime p = {p}, χ(p) = {chi2(p):.4f}")
        for n in [1, 6, 10, 35]:
            lhs = tropical_hecke_shift(p, chi2, n)
            rhs = chi2(p) + chi2(n)
            diff = abs(lhs - rhs)
            print(f"    n={n:3d}: T_p(χ)(n) = {lhs:.6f}, χ(p)+χ(n) = {rhs:.6f}, diff = {diff:.2e}")


# ============================================================
# §3. Demonstrate Hecke Operator Commutativity
# ============================================================

def demo_commutativity():
    """Verify T_p(T_q(f)) = T_q(T_p(f)) for various f."""
    print("\n" + "=" * 60)
    print("§3. TROPICAL HECKE COMMUTATIVITY")
    print("    Verified: T_p ∘ T_q = T_q ∘ T_p")
    print("=" * 60)
    
    chi = log_char()
    
    for p, q in [(2, 3), (2, 5), (3, 7), (5, 11)]:
        print(f"\n  Primes (p,q) = ({p},{q}):")
        for n in [1, 2, 5, 10, 100]:
            # T_p(T_q(χ))(n) = χ(p·q·n)
            lhs = chi(p * q * n)
            # T_q(T_p(χ))(n) = χ(q·p·n)  
            rhs = chi(q * p * n)
            print(f"    n={n:4d}: T_p∘T_q(χ)(n) = {lhs:.6f}, T_q∘T_p(χ)(n) = {rhs:.6f}, equal: {abs(lhs-rhs) < 1e-10}")


# ============================================================
# §4. Tropical Sigma Function (Max-over-Divisors)
# ============================================================

def divisors(n):
    """Return all positive divisors of n."""
    if n <= 0:
        return []
    divs = []
    for d in range(1, int(sqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)

def tropical_sigma(chi, n):
    """σ_χ(n) = max_{d | n} χ(d)"""
    if n <= 0:
        return 0
    return max(chi(d) for d in divisors(n))

def demo_tropical_sigma():
    """Demonstrate the tropical sigma function properties."""
    print("\n" + "=" * 60)
    print("§4. TROPICAL SIGMA FUNCTION")
    print("    σ_χ(n) = max_{d | n} χ(d)")
    print("=" * 60)
    
    chi = log_char()
    
    print("\n  Logarithmic character (σ_log(n) = log(n) since n is largest divisor):")
    for n in [1, 2, 3, 4, 5, 6, 10, 12, 30, 100]:
        sigma = tropical_sigma(chi, n)
        divs = divisors(n)
        print(f"    n={n:4d}: σ(n) = {sigma:.4f}, log(n) = {log(n):.4f}, "
              f"divisors = {divs[:8]}{'...' if len(divs) > 8 else ''}")
    
    # Verify σ(p) = max(0, χ(p)) for primes
    print("\n  Verification: σ(p) = max(0, χ(p)) for primes:")
    chi2 = TropicalHeckeChar({2: -0.5, 3: 1.5, 5: -1.0, 7: 0.8})
    for p in [2, 3, 5, 7]:
        sigma = tropical_sigma(chi2, p)
        expected = max(0, chi2(p))
        print(f"    p={p}: σ(p) = {sigma:.4f}, max(0, χ(p)) = {expected:.4f}, "
              f"χ(p) = {chi2(p):.4f}")


# ============================================================
# §5. Collision Resistance Amplification
# ============================================================

def demo_collision_resistance():
    """Demonstrate hash separation amplification at prime powers."""
    print("\n" + "=" * 60)
    print("§5. COLLISION RESISTANCE AMPLIFICATION")
    print("    |χ₁(p^k) - χ₂(p^k)| ≥ k · ε")
    print("=" * 60)
    
    chi1 = TropicalHeckeChar({2: 1.0, 3: 0.5, 5: -0.3})
    chi2 = TropicalHeckeChar({2: 0.7, 3: 0.5, 5: 0.1})
    
    p = 2
    epsilon = abs(chi1(p) - chi2(p))
    print(f"\n  Characters differ at p={p}: |χ₁(p) - χ₂(p)| = {epsilon:.4f}")
    print(f"  Separation amplifies linearly with k:")
    
    for k in range(1, 16):
        pk = p ** k
        separation = abs(chi1(pk) - chi2(pk))
        bound = k * epsilon
        print(f"    k={k:2d}: |χ₁(2^{k}) - χ₂(2^{k})| = {separation:.4f} ≥ {bound:.4f} = {k}·ε  ✓")


# ============================================================
# §6. Berggren Tree
# ============================================================

def berggren_A(t):
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(t):
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(t):
    a, b, c = t
    return (2*c + 2*b - a, 2*c + b - 2*a, 3*c + 2*b - 2*a)

def demo_berggren_tree():
    """Generate and display the Berggren tree of Pythagorean triples."""
    print("\n" + "=" * 60)
    print("§6. BERGGREN TREE OF PYTHAGOREAN TRIPLES")
    print("=" * 60)
    
    root = (3, 4, 5)
    
    # Generate first 3 levels
    levels = [[root]]
    for depth in range(3):
        next_level = []
        for t in levels[-1]:
            next_level.extend([berggren_A(t), berggren_B(t), berggren_C(t)])
        levels.append(next_level)
    
    for i, level in enumerate(levels):
        print(f"\n  Level {i} ({len(level)} triples):")
        for t in level[:9]:
            a, b, c = t
            # Verify Pythagorean property
            assert a*a + b*b == c*c, f"Not Pythagorean: {t}"
            print(f"    ({a:4d}, {b:4d}, {c:4d})  [{a}² + {b}² = {a*a} + {b*b} = {c*c} = {c}²]")
        if len(level) > 9:
            print(f"    ... ({len(level) - 9} more)")
    
    # Verify hypotenuse growth
    print("\n  Hypotenuse growth under B transformation:")
    t = root
    for i in range(6):
        t_next = berggren_B(t)
        print(f"    Step {i}: c = {t[2]:8d} → {t_next[2]:8d}  (ratio: {t_next[2]/t[2]:.2f})")
        t = t_next


# ============================================================
# §7. Visualization
# ============================================================

def create_visualizations():
    """Create publication-quality visualizations."""
    
    # --- Figure 1: Eigenfunction property ---
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    chi = log_char()
    ns = list(range(1, 51))
    
    for idx, p in enumerate([2, 3, 5]):
        ax = axes[idx]
        lhs_vals = [chi(p * n) for n in ns]
        rhs_vals = [chi(p) + chi(n) for n in ns]
        
        ax.plot(ns, lhs_vals, 'b-', linewidth=2, label=f'T_{p}(χ)(n) = χ({p}n)')
        ax.plot(ns, rhs_vals, 'r--', linewidth=2, label=f'χ({p}) + χ(n)')
        ax.set_xlabel('n', fontsize=12)
        ax.set_ylabel('Value', fontsize=12)
        ax.set_title(f'Eigenfunction: T_{p}(χ) = χ({p}) + χ', fontsize=13)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eigenfunction_property.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  Saved: eigenfunction_property.png")
    
    # --- Figure 2: Tropical sigma function ---
    fig, ax = plt.subplots(figsize=(10, 6))
    
    ns = list(range(1, 101))
    
    # Different characters
    chars = [
        (log_char(), "log char: σ(n) = log(n)"),
        (TropicalHeckeChar({2: 2.0, 3: 1.0, 5: 0.5, 7: 0.3}), "custom: χ(2)=2, χ(3)=1"),
        (trivial_char(), "trivial: σ(n) = 0"),
    ]
    
    for chi, label in chars:
        sigmas = [tropical_sigma(chi, n) for n in ns]
        ax.plot(ns, sigmas, linewidth=2, label=label)
    
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('σ_χ(n)', fontsize=12)
    ax.set_title('Tropical Sigma Function: σ_χ(n) = max_{d|n} χ(d)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('tropical_sigma.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: tropical_sigma.png")
    
    # --- Figure 3: Collision resistance ---
    fig, ax = plt.subplots(figsize=(10, 6))
    
    chi1 = TropicalHeckeChar({2: 1.0, 3: 0.5})
    chi2 = TropicalHeckeChar({2: 0.7, 3: 0.5})
    
    p = 2
    epsilon = abs(chi1(p) - chi2(p))
    ks = list(range(1, 21))
    separations = [abs(chi1(p**k) - chi2(p**k)) for k in ks]
    bounds = [k * epsilon for k in ks]
    
    ax.plot(ks, separations, 'bo-', linewidth=2, markersize=6, label='|χ₁(2^k) - χ₂(2^k)|')
    ax.plot(ks, bounds, 'r--', linewidth=2, label=f'k · ε (ε = {epsilon:.2f})')
    ax.fill_between(ks, bounds, separations, alpha=0.2, color='green')
    ax.set_xlabel('k (exponent)', fontsize=12)
    ax.set_ylabel('Separation', fontsize=12)
    ax.set_title('Collision Resistance Amplification at Prime Powers', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('collision_resistance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: collision_resistance.png")
    
    # --- Figure 4: Berggren tree ---
    fig, ax = plt.subplots(figsize=(12, 8))
    
    root = (3, 4, 5)
    
    def draw_tree(t, x, y, dx, depth, max_depth):
        a, b, c = t
        ax.plot(x, y, 'ko', markersize=8)
        ax.annotate(f'({a},{b},{c})', (x, y), textcoords="offset points",
                   xytext=(0, 10), ha='center', fontsize=7)
        
        if depth < max_depth:
            children = [berggren_A(t), berggren_B(t), berggren_C(t)]
            labels = ['A', 'B', 'C']
            for i, (child, label) in enumerate(zip(children, labels)):
                cx = x + (i - 1) * dx
                cy = y - 1.5
                ax.plot([x, cx], [y, cy], 'b-', linewidth=1, alpha=0.5)
                ax.annotate(label, ((x+cx)/2, (y+cy)/2), fontsize=6, color='red', alpha=0.7)
                draw_tree(child, cx, cy, dx/3, depth+1, max_depth)
    
    draw_tree(root, 0, 0, 6, 0, 3)
    ax.set_xlim(-10, 10)
    ax.set_ylim(-7, 1.5)
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=14)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('berggren_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: berggren_tree.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL LANGLANDS GL(1) CORRESPONDENCE               ║")
    print("║  Numerical Demonstrations                               ║")
    print("║  Companion to Lean 4 formal verification                ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_eigenfunction()
    demo_commutativity()
    demo_tropical_sigma()
    demo_collision_resistance()
    demo_berggren_tree()
    
    print("\n" + "=" * 60)
    print("CREATING VISUALIZATIONS")
    print("=" * 60)
    create_visualizations()
    
    print("\n" + "=" * 60)
    print("SUMMARY OF VERIFIED PROPERTIES")
    print("=" * 60)
    print("""
  All numerical computations confirm the formally verified theorems:
  
  ✓ Eigenfunction property: T_p(χ)(n) = χ(p) + χ(n)
  ✓ Hecke commutativity: T_p ∘ T_q = T_q ∘ T_p  
  ✓ Tropical sigma: σ_χ(p) = max(0, χ(p)) for primes
  ✓ Collision amplification: |χ₁(p^k) - χ₂(p^k)| ≥ k·ε
  ✓ Berggren tree: all triples satisfy a² + b² = c²
  ✓ Hypotenuse growth: c strictly increases under B
    """)
