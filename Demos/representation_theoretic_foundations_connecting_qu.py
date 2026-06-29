#!/usr/bin/env python3
"""
Quantum Casimir Spectral Theory — Numerical Demonstrations

Demonstrates the key identities and spectral properties proved in the
Lean 4 formalization of quantum Casimir spectral theory.
"""

import numpy as np

def q_integer(n: int, theta: float) -> float:
    """Trigonometric q-integer [n]_q = sin(n*theta)/sin(theta)."""
    s = np.sin(theta)
    if abs(s) < 1e-15:
        return 0.0
    return np.sin(n * theta) / s

def spectral_numerator(n: int, theta: float) -> float:
    """Spectral numerator S(n, theta) = 2*sin(n*theta)*sin((n+1)*theta)."""
    return 2.0 * np.sin(n * theta) * np.sin((n + 1) * theta)

def spectral_decomposition_rhs(n: int, theta: float) -> float:
    """RHS of spectral decomposition: cos(theta) - cos((2n+1)*theta)."""
    return np.cos(theta) - np.cos((2 * n + 1) * theta)

def main():
    print("=" * 70)
    print("QUANTUM CASIMIR SPECTRAL THEORY — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Demo 1: Verify spectral decomposition identity
    print("\n--- Demo 1: Spectral Decomposition Identity ---")
    print("2*sin(n*θ)*sin((n+1)*θ) = cos(θ) - cos((2n+1)*θ)")
    print()
    theta = np.pi / 5
    print(f"θ = π/5 ≈ {theta:.6f}")
    print(f"{'n':>3} | {'LHS':>15} | {'RHS':>15} | {'Error':>12}")
    print("-" * 55)
    for n in range(1, 11):
        lhs = spectral_numerator(n, theta)
        rhs = spectral_decomposition_rhs(n, theta)
        print(f"{n:3d} | {lhs:15.10f} | {rhs:15.10f} | {abs(lhs-rhs):.2e}")

    # Demo 2: Chebyshev recurrence
    print("\n--- Demo 2: Chebyshev Three-Term Recurrence ---")
    print("sin((n+1)θ) + sin((n-1)θ) = 2*cos(θ)*sin(nθ)")
    print()
    for n in range(2, 8):
        lhs = np.sin((n + 1) * theta) + np.sin((n - 1) * theta)
        rhs = 2 * np.cos(theta) * np.sin(n * theta)
        print(f"n={n}: LHS={lhs:12.8f}, RHS={rhs:12.8f}, error={abs(lhs-rhs):.2e}")

    # Demo 3: Level-one factorization
    print("\n--- Demo 3: Level-One Factorization ---")
    print("cos(θ) - cos(3θ) = 4*cos(θ)*sin²(θ)")
    print()
    for theta_val in [np.pi/6, np.pi/4, np.pi/3, np.pi/5, 1.0, 2.0]:
        lhs = np.cos(theta_val) - np.cos(3 * theta_val)
        rhs = 4 * np.cos(theta_val) * np.sin(theta_val)**2
        print(f"θ={theta_val:6.3f}: LHS={lhs:10.6f}, RHS={rhs:10.6f}, error={abs(lhs-rhs):.2e}")

    # Demo 4: Dirichlet kernel (odd cosine sum)
    print("\n--- Demo 4: Odd Cosine Sum (Dirichlet Kernel) ---")
    print("Σ cos((2k+1)θ) = sin(2nθ) / (2*sin(θ))")
    print()
    theta = np.pi / 7
    print(f"θ = π/7 ≈ {theta:.6f}")
    for N in [5, 10, 20, 50]:
        lhs = sum(np.cos((2 * k + 1) * theta) for k in range(N))
        rhs = np.sin(2 * N * theta) / (2 * np.sin(theta))
        print(f"N={N:3d}: sum={lhs:12.8f}, formula={rhs:12.8f}, error={abs(lhs-rhs):.2e}")

    # Demo 5: Spectral boundedness
    print("\n--- Demo 5: Spectral Boundedness |S(n,θ)| ≤ 2 ---")
    print()
    max_val = 0.0
    for theta_val in np.linspace(0.01, np.pi - 0.01, 1000):
        for n in range(1, 100):
            val = abs(spectral_numerator(n, theta_val))
            max_val = max(max_val, val)
    print(f"Maximum |S(n,θ)| over grid: {max_val:.10f}")
    print(f"Bound:                       2.000000000")
    print(f"Margin:                      {2.0 - max_val:.10f}")

    # Demo 6: Spectral isospectrality constraint
    print("\n--- Demo 6: Isospectrality Constraint ---")
    print("cos((2n+1)θ₁) - cos((2n+1)θ₂) = cos(θ₁) - cos(θ₂) when spectra match")
    print()
    theta1 = np.pi / 5
    theta2 = -np.pi / 5  # Same cosine, so delta = 0
    delta = np.cos(theta1) - np.cos(theta2)
    print(f"θ₁ = π/5, θ₂ = -π/5 (cos(θ₁) = cos(θ₂), δ = {delta:.10f})")
    for n in range(6):
        diff = np.cos((2*n+1)*theta1) - np.cos((2*n+1)*theta2)
        print(f"  n={n}: cos((2n+1)θ₁) - cos((2n+1)θ₂) = {diff:.10f}")

    # Demo 7: Spectral consecutive differences
    print("\n--- Demo 7: Spectral Consecutive Differences ---")
    print("S(n+1,θ) - S(n,θ) = 2*sin(θ)*sin((2n+2)θ)")
    print()
    theta = 0.7
    for n in range(8):
        lhs = spectral_numerator(n+1, theta) - spectral_numerator(n, theta)
        rhs = 2 * np.sin(theta) * np.sin((2*n+2) * theta)
        print(f"n={n}: diff={lhs:10.6f}, formula={rhs:10.6f}, error={abs(lhs-rhs):.2e}")

    # Demo 8: q-integers approaching classical integers
    print("\n--- Demo 8: Quantum → Classical Limit ---")
    print("[n]_θ → n as θ → 0")
    print()
    for n in [1, 2, 3, 5, 10]:
        print(f"n={n:2d}:", end="")
        for theta_val in [1.0, 0.1, 0.01, 0.001]:
            qn = q_integer(n, theta_val)
            print(f"  θ={theta_val}: [n]={qn:.6f}", end="")
        print()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)

if __name__ == "__main__":
    main()
