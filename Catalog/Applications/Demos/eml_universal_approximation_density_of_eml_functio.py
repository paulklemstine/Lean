#!/usr/bin/env python3
"""
EML Universal Approximation: Numerical Demonstrations

Demonstrates that polynomials in exp(x) can uniformly approximate
continuous functions on [0,1], illustrating the density theorem.
"""

import numpy as np
from typing import Callable

def iterExp(k: int, x: np.ndarray) -> np.ndarray:
    """Iterated exponential: exp composed with itself k times."""
    result = x.copy()
    for _ in range(k):
        result = np.exp(result)
    return result

def fit_poly_in_exp(f: Callable, degree: int, n_points: int = 200) -> tuple:
    """
    Fit a polynomial of given degree in exp(x) to approximate f on [0,1].
    Returns (coefficients, sup_norm_error).
    """
    x = np.linspace(0, 1, n_points)
    ex = np.exp(x)
    # Build Vandermonde matrix in exp(x)
    V = np.vander(ex, degree + 1, increasing=True)
    y = f(x)
    # Least squares fit
    coeffs, _, _, _ = np.linalg.lstsq(V, y, rcond=None)
    approx = V @ coeffs
    error = np.max(np.abs(approx - y))
    return coeffs, error

def fit_poly_in_id(f: Callable, degree: int, n_points: int = 200) -> tuple:
    """
    Fit a standard polynomial of given degree to approximate f on [0,1].
    Returns (coefficients, sup_norm_error).
    """
    x = np.linspace(0, 1, n_points)
    V = np.vander(x, degree + 1, increasing=True)
    y = f(x)
    coeffs, _, _, _ = np.linalg.lstsq(V, y, rcond=None)
    approx = V @ coeffs
    error = np.max(np.abs(approx - y))
    return coeffs, error

def demo_exp_approximation():
    """Demonstrate polynomial-in-exp approximation of various functions."""
    print("=" * 60)
    print("EML UNIVERSAL APPROXIMATION DEMO")
    print("Approximating functions on [0,1] by polynomials in exp(x)")
    print("=" * 60)
    
    targets = {
        "sin(πx)": lambda x: np.sin(np.pi * x),
        "√x": lambda x: np.sqrt(x + 1e-10),
        "|x - 0.5|": lambda x: np.abs(x - 0.5),
        "x·log(x+1)": lambda x: x * np.log(x + 1),
        "cos(2πx)": lambda x: np.cos(2 * np.pi * x),
    }
    
    print("\n--- Approximation errors by degree ---\n")
    for name, f in targets.items():
        print(f"Target: {name}")
        for deg in [2, 5, 10, 15, 20]:
            _, err_exp = fit_poly_in_exp(f, deg)
            _, err_poly = fit_poly_in_id(f, deg)
            print(f"  Degree {deg:2d}: poly-in-exp error = {err_exp:.2e}, "
                  f"poly error = {err_poly:.2e}")
        print()

def demo_depth_comparison():
    """Compare approximation at different tower depths."""
    print("=" * 60)
    print("DEPTH TOWER COMPARISON")
    print("Comparing depth-0 (polynomials) vs depth-1 (poly in exp)")
    print("vs depth-2 (poly in exp(exp(x)))")
    print("=" * 60)
    
    # Target: exp(exp(x)) - should be trivial at depth 2
    f = lambda x: np.exp(np.exp(x))
    
    print("\nTarget: exp(exp(x)) on [0,1]")
    print(f"{'Degree':>8} {'Depth-0 err':>14} {'Depth-1 err':>14} {'Depth-2 err':>14}")
    print("-" * 54)
    
    x = np.linspace(0, 1, 200)
    y = f(x)
    
    for deg in [1, 2, 3, 5, 8, 10, 15]:
        # Depth 0: polynomial in x
        _, err0 = fit_poly_in_id(f, deg)
        
        # Depth 1: polynomial in exp(x)
        _, err1 = fit_poly_in_exp(f, deg)
        
        # Depth 2: polynomial in exp(exp(x))
        eex = np.exp(np.exp(x))
        V2 = np.vander(eex, deg + 1, increasing=True)
        c2, _, _, _ = np.linalg.lstsq(V2, y, rcond=None)
        err2 = np.max(np.abs(V2 @ c2 - y))
        
        print(f"{deg:8d} {err0:14.2e} {err1:14.2e} {err2:14.2e}")
    
    print("\n(Depth-2 error is ~0 because exp(exp(x)) is degree 1 in that basis)")

def demo_iterExp_growth():
    """Show the super-exponential growth of iterated exponentials."""
    print("\n" + "=" * 60)
    print("ITERATED EXPONENTIAL GROWTH")
    print("=" * 60)
    
    print(f"\n{'k':>3} {'iterExp(k, 0)':>20} {'iterExp(k, 1)':>20}")
    print("-" * 46)
    for k in range(6):
        val0 = iterExp(k, np.array([0.0]))[0]
        val1 = iterExp(k, np.array([1.0]))[0]
        if val0 < 1e15:
            print(f"{k:3d} {val0:20.6f} {val1:20.6f}")
        else:
            print(f"{k:3d} {'overflow':>20} {'overflow':>20}")

if __name__ == "__main__":
    demo_exp_approximation()
    demo_depth_comparison()
    demo_iterExp_growth()
