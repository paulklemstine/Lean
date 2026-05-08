#!/usr/bin/env python3
"""
Hopf-Algebraic Causal Calculus: Numerical Demonstrations

Demonstrates the core algebraic structures connecting QFT renormalization
and Pearl's causal inference through concrete numerical examples.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Callable, Tuple


# ============================================================
# Part I: Cauchy Convolution Product
# ============================================================

def cauchy_conv(f: np.ndarray, g: np.ndarray, max_grade: int) -> np.ndarray:
    """Cauchy convolution product: (f * g)(n) = sum_{k=0}^{n} f(k)*g(n-k)"""
    result = np.zeros(max_grade + 1)
    for n in range(max_grade + 1):
        for k in range(n + 1):
            if k < len(f) and (n - k) < len(g):
                result[n] += f[k] * g[n - k]
    return result


def conv_unit(max_grade: int) -> np.ndarray:
    """The convolution unit delta_0"""
    u = np.zeros(max_grade + 1)
    u[0] = 1.0
    return u


def conv_inverse(f: np.ndarray, max_grade: int) -> np.ndarray:
    """Recursive convolution inverse (antipode) for augmented characters.
    
    Formula: g(0) = 1, g(n+1) = -f(n+1) - sum_{k=0}^{n-1} g(k+1)*f(n-k)
    """
    assert abs(f[0] - 1.0) < 1e-10, "f must be augmented (f(0) = 1)"
    g = np.zeros(max_grade + 1)
    g[0] = 1.0
    for n in range(max_grade):
        # g(n+1) = -f(n+1) - sum_{k<n} g(k+1)*f(n-k)
        g[n + 1] = -f[n + 1] if n + 1 < len(f) else 0
        for k in range(n):
            fval = f[n - k] if (n - k) < len(f) else 0
            g[n + 1] -= g[k + 1] * fval
    return g


# ============================================================
# Part II: Antipode Sign Pattern
# ============================================================

def antipode_sign(n: int) -> int:
    """(-1)^n: the alternating sign in the forest formula"""
    return (-1) ** n


def antipode_partial_sum(n: int) -> int:
    """Sum of antipode signs from 0 to n: 1 if n even, 0 if n odd"""
    return sum(antipode_sign(k) for k in range(n + 1))


# ============================================================
# Part III: Admissible Cut Counting
# ============================================================

def adm_cut_count(n: int) -> int:
    """Number of admissible cuts for a chain of length n: n+1"""
    return n + 1


# ============================================================
# Demonstrations
# ============================================================

def demo_convolution_algebra():
    """Demonstrate the convolution algebra axioms"""
    print("=" * 60)
    print("DEMO 1: Cauchy Convolution Algebra")
    print("=" * 60)
    
    N = 6  # max grade
    
    # Define two augmented characters
    f = np.array([1.0, 2.0, -1.0, 0.5, 0, 0, 0])
    g = np.array([1.0, -1.0, 3.0, 0, 0, 0, 0])
    u = conv_unit(N)
    
    # Test: f * unit = f
    fu = cauchy_conv(f, u, N)
    print(f"\nf = {f[:4]}")
    print(f"f * unit = {fu[:4]}")
    print(f"f * unit == f? {np.allclose(fu[:len(f)], f)}")
    
    # Test: unit * g = g
    ug = cauchy_conv(u, g, N)
    print(f"\ng = {g[:4]}")
    print(f"unit * g = {ug[:4]}")
    print(f"unit * g == g? {np.allclose(ug[:len(g)], g)}")
    
    # Test: f * g = g * f (commutativity)
    fg = cauchy_conv(f, g, N)
    gf = cauchy_conv(g, f, N)
    print(f"\nf * g = {fg[:5]}")
    print(f"g * f = {gf[:5]}")
    print(f"Commutative? {np.allclose(fg, gf)}")
    
    # Test: counit is multiplicative
    print(f"\ncounit(f * g) = {fg[0]}")
    print(f"counit(f) * counit(g) = {f[0] * g[0]}")
    print(f"Multiplicative? {np.isclose(fg[0], f[0] * g[0])}")


def demo_antipode():
    """Demonstrate the recursive antipode (convolution inverse)"""
    print("\n" + "=" * 60)
    print("DEMO 2: Recursive Antipode (Convolution Inverse)")
    print("=" * 60)
    
    N = 8
    
    # Define an augmented character
    f = np.zeros(N + 1)
    f[0] = 1.0
    f[1] = 2.0
    f[2] = -1.0
    f[3] = 0.5
    f[4] = 0.3
    
    # Compute convolution inverse
    g = conv_inverse(f, N)
    
    print(f"\nCharacter f: {f[:5]}")
    print(f"Antipode S(f): {g[:5]}")
    
    # Verify: S(f)(1) = -f(1)
    print(f"\nS(f)(1) = {g[1]}, -f(1) = {-f[1]}")
    print(f"Match? {np.isclose(g[1], -f[1])}")
    
    # Verify: S(f)(2) = f(1)^2 - f(2)
    expected_2 = f[1]**2 - f[2]
    print(f"S(f)(2) = {g[2]}, f(1)^2 - f(2) = {expected_2}")
    print(f"Match? {np.isclose(g[2], expected_2)}")
    
    # Verify: S(f) * f = unit
    product = cauchy_conv(g, f, N)
    print(f"\nS(f) * f = {product[:6]}")
    print(f"Unit?     = {conv_unit(N)[:6]}")
    print(f"S(f) * f == unit? {np.allclose(product, conv_unit(N))}")


def demo_stability():
    """Demonstrate Lipschitz stability of the convolution inverse"""
    print("\n" + "=" * 60)
    print("DEMO 3: Lipschitz Stability of Antipode")
    print("=" * 60)
    
    N = 10
    
    # Define base character
    f = np.zeros(N + 1)
    f[0] = 1.0
    f[1] = 2.0
    f[2] = -1.0
    f[3] = 0.5
    
    # Perturbed character (agrees with f up to grade 5)
    g = f.copy()
    g[6] = 0.1  # perturbation at grade 6
    g[7] = -0.2
    
    # Compute inverses
    Sf = conv_inverse(f, N)
    Sg = conv_inverse(g, N)
    
    print(f"\nBase character f: {f[:8]}")
    print(f"Perturbed char g: {g[:8]}")
    print(f"\nAntipode S(f): {Sf[:8]}")
    print(f"Antipode S(g): {Sg[:8]}")
    
    # Check agreement up to grade 5
    print(f"\nAgreement up to grade 5:")
    for n in range(6):
        print(f"  Grade {n}: S(f)={Sf[n]:.6f}, S(g)={Sg[n]:.6f}, "
              f"equal? {np.isclose(Sf[n], Sg[n])}")
    
    print(f"\nDivergence at grade 6+:")
    for n in range(6, 9):
        diff = abs(Sf[n] - Sg[n])
        print(f"  Grade {n}: |S(f)-S(g)| = {diff:.6f}")


def demo_chain_tree():
    """Demonstrate properties of chain characters (zero confounding)"""
    print("\n" + "=" * 60)
    print("DEMO 4: Chain Characters (Zero Confounding)")
    print("=" * 60)
    
    for c_val in [0.5, 1.0, 2.0, -1.0]:
        N = 6
        # Chain character: f(0) = 1, f(k) = c for k > 0
        f = np.zeros(N + 1)
        f[0] = 1.0
        f[1:] = c_val
        
        g = conv_inverse(f, N)
        print(f"\nChain character (c={c_val}):")
        print(f"  f = {f[:5]}")
        print(f"  S(f) = {g[:5]}")
        print(f"  S(f)(1) = {g[1]:.4f}, expected -c = {-c_val:.4f}")
        
        # Verify convolution inverse
        product = cauchy_conv(g, f, N)
        print(f"  S(f) * f = unit? {np.allclose(product, conv_unit(N))}")


def demo_admissible_cuts():
    """Demonstrate admissible cut counting and complexity bounds"""
    print("\n" + "=" * 60)
    print("DEMO 5: Admissible Cut Counting")
    print("=" * 60)
    
    print(f"\nChain length n | admCutCount(n) | Bound n+1")
    print("-" * 45)
    for n in range(11):
        count = adm_cut_count(n)
        bound = n + 1
        print(f"       {n:2d}      |      {count:3d}       |    {bound:3d}")
    
    print(f"\nForest formula bound for V=10 vertices:")
    V = 10
    for p in [1, 3, 5, 10]:
        cut_count = adm_cut_count(p)
        bound = V * (p + 1)
        print(f"  Path length {p}: cuts={cut_count}, "
              f"bound=|V|*(p+1)={bound}")


def demo_antipode_signs():
    """Demonstrate the alternating sign pattern and partial sums"""
    print("\n" + "=" * 60)
    print("DEMO 6: Antipode Sign Pattern")
    print("=" * 60)
    
    print(f"\nGrade n | (-1)^n | Partial sum | Even n?")
    print("-" * 50)
    for n in range(11):
        sign = antipode_sign(n)
        psum = antipode_partial_sum(n)
        even = n % 2 == 0
        expected = 1 if even else 0
        print(f"   {n:2d}   |  {sign:+2d}  |     {psum:2d}      | "
              f"{'Yes' if even else 'No ':3s} (expected {expected})")
    
    # Verify multiplicativity
    print(f"\nMultiplicativity: sign(m+n) = sign(m)*sign(n)")
    for m in range(5):
        for n in range(5):
            assert antipode_sign(m + n) == antipode_sign(m) * antipode_sign(n)
    print("  Verified for all 0 ≤ m,n ≤ 4 ✓")
    
    # Verify consecutive product
    print(f"\nConsecutive product: sign(n)*sign(n+1) = -1")
    for n in range(10):
        assert antipode_sign(n) * antipode_sign(n + 1) == -1
    print("  Verified for all 0 ≤ n ≤ 9 ✓")


def create_visualization():
    """Create visualization of key mathematical structures"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Hopf-Algebraic Causal Calculus: Key Structures",
                 fontsize=14, fontweight='bold')
    
    # Plot 1: Convolution inverse convergence
    ax = axes[0, 0]
    N = 15
    f = np.zeros(N + 1)
    f[0] = 1.0
    f[1] = 0.5
    f[2] = 0.2
    f[3] = 0.1
    g = conv_inverse(f, N)
    product = cauchy_conv(g, f, N)
    
    grades = np.arange(N + 1)
    ax.bar(grades - 0.15, g[:N+1], width=0.3, label='Antipode S(f)',
           color='steelblue', alpha=0.8)
    ax.bar(grades + 0.15, product[:N+1], width=0.3, label='S(f) ⋆ f',
           color='coral', alpha=0.8)
    ax.set_xlabel('Grade n')
    ax.set_ylabel('Value')
    ax.set_title('Antipode & Convolution Inverse Verification')
    ax.legend()
    ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
    
    # Plot 2: Stability under perturbation
    ax = axes[0, 1]
    N = 12
    f = np.zeros(N + 1)
    f[0] = 1.0
    f[1] = 1.5
    f[2] = -0.5
    f[3] = 0.3
    
    deltas = [0.01, 0.05, 0.1, 0.5]
    for delta in deltas:
        g = f.copy()
        g[4] += delta
        Sf = conv_inverse(f, N)
        Sg = conv_inverse(g, N)
        diffs = np.abs(Sf - Sg)
        ax.plot(grades[:N+1], diffs[:N+1], 'o-', label=f'δ={delta}',
                markersize=4, alpha=0.8)
    
    ax.set_xlabel('Grade n')
    ax.set_ylabel('|S(f) - S(g)|')
    ax.set_title('Lipschitz Stability of Antipode')
    ax.legend()
    ax.set_yscale('log')
    ax.set_ylim(bottom=1e-16)
    
    # Plot 3: Admissible cut counts
    ax = axes[1, 0]
    ns = np.arange(1, 16)
    cuts = [adm_cut_count(n) for n in ns]
    bounds_V5 = [5 * (n + 1) for n in ns]
    bounds_V10 = [10 * (n + 1) for n in ns]
    
    ax.plot(ns, cuts, 'o-', color='steelblue', label='admCutCount(n)',
            linewidth=2)
    ax.plot(ns, bounds_V5, '--', color='coral', label='|V|=5 bound',
            alpha=0.7)
    ax.plot(ns, bounds_V10, '--', color='green', label='|V|=10 bound',
            alpha=0.7)
    ax.set_xlabel('Chain length n')
    ax.set_ylabel('Count')
    ax.set_title('Admissible Cuts: O(|V|·h_max) Bound')
    ax.legend()
    
    # Plot 4: Antipode sign pattern and partial sums
    ax = axes[1, 1]
    ns = np.arange(0, 16)
    signs = [antipode_sign(n) for n in ns]
    psums = [antipode_partial_sum(n) for n in ns]
    
    ax.bar(ns - 0.15, signs, width=0.3, label='(-1)^n',
           color='steelblue', alpha=0.8)
    ax.bar(ns + 0.15, psums, width=0.3, label='Partial sum',
           color='coral', alpha=0.8)
    ax.set_xlabel('Grade n')
    ax.set_ylabel('Value')
    ax.set_title('Antipode Signs: Inclusion-Exclusion Pattern')
    ax.legend()
    ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
    
    plt.tight_layout()
    plt.savefig('hopf_causal_calculus.png', dpi=150, bbox_inches='tight')
    print("\nVisualization saved to hopf_causal_calculus.png")


if __name__ == "__main__":
    demo_convolution_algebra()
    demo_antipode()
    demo_stability()
    demo_chain_tree()
    demo_admissible_cuts()
    demo_antipode_signs()
    create_visualization()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)
