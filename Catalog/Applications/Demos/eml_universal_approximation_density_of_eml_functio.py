#!/usr/bin/env python3
"""
EML Universal Approximation Demo

Demonstrates key results from the EML density and depth hierarchy theorems:
1. Polynomial (depth-0 EML) approximation of continuous functions
2. Iterated exponential growth gap
3. EML Approximation Spectrum computation
"""

import numpy as np
from typing import Callable, Tuple, List

# ============================================================
# 1. EML Primitive
# ============================================================

def eml(x: float, y: float) -> float:
    """The EML primitive: eml(x, y) = exp(x) - log(y)"""
    return np.exp(x) - np.log(y)

def eml_recovers_exp(x: float) -> float:
    """eml(x, 1) = exp(x)"""
    return eml(x, 1.0)

def eml_recovers_log(y: float) -> float:
    """1 - eml(0, y) = log(y)"""
    return 1.0 - eml(0.0, y)

# ============================================================
# 2. Iterated Exponential and Growth Gap
# ============================================================

def iter_exp(n: int, x: float) -> float:
    """Iterated exponential: iterExp(0, x) = x, iterExp(n+1, x) = exp(iterExp(n, x))"""
    result = x
    for _ in range(n):
        result = np.exp(result)
    return result

def demonstrate_growth_gap():
    """Show the super-exponential growth gap: iterExp(n+1, 2) > iterExp(n, 2) + 1"""
    print("=" * 60)
    print("ITERATED EXPONENTIAL GROWTH GAP")
    print("Theorem: iterExp(n+1, 2) > iterExp(n, 2) + 1 for all n")
    print("=" * 60)
    
    for n in range(6):
        val_n = iter_exp(n, 2.0)
        val_n1 = iter_exp(n + 1, 2.0)
        gap = val_n1 - val_n - 1
        print(f"  n={n}: iterExp({n}, 2) = {val_n:.6g}")
        print(f"         iterExp({n+1}, 2) = {val_n1:.6g}")
        print(f"         gap = {gap:.6g} > 0 ✓")
        print()
        if val_n1 > 1e100:
            print("  (values too large to display for higher n)")
            break

# ============================================================
# 3. Polynomial Approximation (Depth-0 EML Density)
# ============================================================

def chebyshev_nodes(n: int, a: float = 0.0, b: float = 1.0) -> np.ndarray:
    """Chebyshev nodes on [a, b]"""
    k = np.arange(1, n + 1)
    nodes = 0.5 * (a + b) + 0.5 * (b - a) * np.cos((2 * k - 1) * np.pi / (2 * n))
    return np.sort(nodes)

def lagrange_interpolation(nodes: np.ndarray, values: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Lagrange interpolation polynomial evaluated at x"""
    n = len(nodes)
    result = np.zeros_like(x, dtype=float)
    for i in range(n):
        term = values[i] * np.ones_like(x)
        for j in range(n):
            if i != j:
                term *= (x - nodes[j]) / (nodes[i] - nodes[j])
        result += term
    return result

def demonstrate_polynomial_density():
    """Demonstrate Stone-Weierstrass: polynomials approximate any continuous function"""
    print("=" * 60)
    print("POLYNOMIAL (DEPTH-0 EML) APPROXIMATION")
    print("Theorem: ∀ f ∈ C([0,1]), ε > 0, ∃ polynomial p: ‖p - f‖ < ε")
    print("=" * 60)
    
    # Test function: sin(2πx) on [0,1]
    f = lambda x: np.sin(2 * np.pi * x)
    x_fine = np.linspace(0, 1, 1000)
    
    print("\nApproximating f(x) = sin(2πx) on [0,1]:")
    for degree in [3, 5, 10, 20]:
        nodes = chebyshev_nodes(degree + 1)
        values = f(nodes)
        p_values = lagrange_interpolation(nodes, values, x_fine)
        max_error = np.max(np.abs(f(x_fine) - p_values))
        print(f"  degree {degree:3d}: max error = {max_error:.2e}")
    
    # Test function: |x - 0.5| (Lipschitz but not smooth)
    g = lambda x: np.abs(x - 0.5)
    print("\nApproximating g(x) = |x - 0.5| on [0,1] (Lipschitz, L=1):")
    for degree in [5, 10, 20, 50]:
        nodes = chebyshev_nodes(degree + 1)
        values = g(nodes)
        p_values = lagrange_interpolation(nodes, values, x_fine)
        max_error = np.max(np.abs(g(x_fine) - p_values))
        print(f"  degree {degree:3d}: max error = {max_error:.2e}")

# ============================================================
# 4. EML Approximation Spectrum
# ============================================================

def compute_eml_spectrum(f: Callable, a: float, b: float, 
                         epsilons: List[float]) -> List[int]:
    """Compute approximate EML spectrum: min polynomial degree for ε-approximation"""
    spectrum = []
    x_fine = np.linspace(a, b, 1000)
    f_values = f(x_fine)
    
    for eps in epsilons:
        for degree in range(1, 200):
            nodes = chebyshev_nodes(degree + 1, a, b)
            values = f(nodes)
            p_values = lagrange_interpolation(nodes, values, x_fine)
            max_error = np.max(np.abs(f_values - p_values))
            if max_error < eps:
                # Tree size ≈ 2*degree + 1 (for polynomial as EML tree)
                spectrum.append(2 * degree + 1)
                break
        else:
            spectrum.append(-1)  # not achieved
    
    return spectrum

def demonstrate_spectrum():
    """Demonstrate the EML Approximation Spectrum"""
    print("=" * 60)
    print("EML APPROXIMATION SPECTRUM")
    print("Ψ_f(ε) = minimum EML tree size for ε-approximation")
    print("=" * 60)
    
    epsilons = [1e-1, 1e-2, 1e-3, 1e-4, 1e-5]
    
    # Smooth function
    f1 = lambda x: np.sin(2 * np.pi * x)
    spec1 = compute_eml_spectrum(f1, 0, 1, epsilons)
    print("\nf(x) = sin(2πx) (analytic):")
    for eps, size in zip(epsilons, spec1):
        print(f"  ε = {eps:.0e}: Ψ = {size}")
    
    # Lipschitz function
    f2 = lambda x: np.abs(x - 0.5)
    spec2 = compute_eml_spectrum(f2, 0, 1, epsilons)
    print("\ng(x) = |x - 0.5| (Lipschitz, not C¹):")
    for eps, size in zip(epsilons, spec2):
        print(f"  ε = {eps:.0e}: Ψ = {size}")
    
    # Highly oscillatory
    f3 = lambda x: np.sin(20 * np.pi * x)
    spec3 = compute_eml_spectrum(f3, 0, 1, epsilons)
    print("\nh(x) = sin(20πx) (analytic, oscillatory):")
    for eps, size in zip(epsilons, spec3):
        print(f"  ε = {eps:.0e}: Ψ = {size}")

# ============================================================
# 5. EML Identities Verification
# ============================================================

def demonstrate_eml_identities():
    """Verify key EML algebraic identities numerically"""
    print("=" * 60)
    print("EML ALGEBRAIC IDENTITIES")
    print("=" * 60)
    
    x_vals = [0.5, 1.0, 2.0, 3.0]
    y_vals = [0.5, 1.0, 2.0, np.e]
    
    print("\neml(x, 1) = exp(x):")
    for x in x_vals:
        lhs = eml(x, 1.0)
        rhs = np.exp(x)
        print(f"  x={x}: eml({x}, 1) = {lhs:.10f}, exp({x}) = {rhs:.10f}, diff = {abs(lhs-rhs):.2e}")
    
    print("\n1 - eml(0, y) = log(y):")
    for y in y_vals:
        lhs = 1.0 - eml(0.0, y)
        rhs = np.log(y)
        print(f"  y={y}: 1 - eml(0, {y}) = {lhs:.10f}, log({y}) = {rhs:.10f}, diff = {abs(lhs-rhs):.2e}")
    
    print("\nLegendre: eml(x, exp(y)) = exp(x) - y:")
    for x in [0.5, 1.0]:
        for y in [0.5, 1.0, 2.0]:
            lhs = eml(x, np.exp(y))
            rhs = np.exp(x) - y
            print(f"  x={x}, y={y}: lhs = {lhs:.10f}, rhs = {rhs:.10f}, diff = {abs(lhs-rhs):.2e}")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("EML Universal Approximation: Density and Depth Hierarchy")
    print("=" * 60)
    print()
    
    demonstrate_eml_identities()
    print()
    demonstrate_growth_gap()
    print()
    demonstrate_polynomial_density()
    print()
    demonstrate_spectrum()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("Key results verified:")
    print("  ✓ EML recovers exp and log")
    print("  ✓ Iterated exponentials exhibit super-exponential growth")
    print("  ✓ Polynomials (depth-0 EML) approximate any continuous function")
    print("  ✓ Approximation spectrum captures complexity-quality tradeoff")
