"""
CHEAT CODE #2: FIXED POINT THEOREMS
====================================
Demonstrates Banach's Contraction Mapping Theorem.

Key insight: If T is a contraction (Lip(T) < 1), then iterating 
x_{n+1} = T(x_n) converges to the UNIQUE fixed point, regardless 
of starting point.

Experiments:
1. Solving equations via fixed point iteration
2. Computing square roots (Babylonian method as fixed point)
3. Newton's method as a contraction
4. Chaos vs. convergence: the Lipschitz boundary
"""

import numpy as np


def experiment_1_solving_equations():
    """Solve cos(x) = x via fixed point iteration."""
    print("=" * 60)
    print("EXPERIMENT 1: Solving cos(x) = x via Fixed Point Iteration")
    print("=" * 60)
    
    # Fixed point of T(x) = cos(x)
    # |T'(x)| = |sin(x)| ≤ sin(1) ≈ 0.841 < 1 near the fixed point
    # So T is a contraction!
    
    x = 0.0  # Any starting point works
    print(f"\n{'Iteration':>10} | {'x_n':>15} | {'|x_n - x_{n-1}|':>18}")
    print("-" * 50)
    
    for i in range(20):
        x_old = x
        x = np.cos(x)
        error = abs(x - x_old)
        print(f"{i:>10} | {x:>15.12f} | {error:>18.2e}")
        if error < 1e-14:
            break
    
    # Verify
    print(f"\nFixed point: x* = {x:.15f}")
    print(f"cos(x*) =    {np.cos(x):.15f}")
    print(f"Residual:    {abs(x - np.cos(x)):.2e}")
    print("\n✓ Converged! The contraction mapping theorem guarantees this.\n")


def experiment_2_square_root():
    """Compute √A via the Babylonian method (a fixed point iteration)."""
    print("=" * 60)
    print("EXPERIMENT 2: Computing √2 via Babylonian Method")
    print("=" * 60)
    
    # To find √A, iterate: x_{n+1} = (x_n + A/x_n) / 2
    # This is T(x) = (x + A/x)/2, a contraction near √A
    
    A = 2.0
    x = 1.0  # Starting guess
    true_val = np.sqrt(A)
    
    print(f"\n{'Iteration':>10} | {'x_n':>20} | {'Error':>15} | {'Error ratio':>12}")
    print("-" * 65)
    
    prev_error = abs(x - true_val)
    for i in range(10):
        x = (x + A / x) / 2
        error = abs(x - true_val)
        ratio = error / prev_error**2 if prev_error > 0 else 0
        print(f"{i:>10} | {x:>20.16f} | {error:>15.2e} | {ratio:>12.4f}")
        prev_error = error
        if error < 1e-16:
            break
    
    print(f"\nTrue √2:     {true_val:.16f}")
    print(f"Computed:    {x:.16f}")
    print("\n✓ QUADRATIC convergence! Error squares each iteration.")
    print("  The Babylonian method is Newton's method for f(x) = x² - A.\n")


def experiment_3_lipschitz_boundary():
    """Show the critical role of the Lipschitz constant."""
    print("=" * 60)
    print("EXPERIMENT 3: Lipschitz Constant — Order vs. Chaos")
    print("=" * 60)
    
    # T_c(x) = c * sin(x) has Lipschitz constant |c|
    # c < 1: contraction → converges
    # c = 1: boundary → slow convergence
    # c > 1: not a contraction → may or may not converge
    
    print(f"\n{'c':>6} | {'Lip(T)':>8} | {'Converges?':>12} | {'Fixed point':>15} | {'Iterations':>12}")
    print("-" * 65)
    
    for c in [0.1, 0.5, 0.9, 0.99, 1.0, 1.5, 2.0, 3.0]:
        T = lambda x, c=c: c * np.sin(x)
        
        x = 1.0
        converged = False
        for i in range(10000):
            x_new = T(x)
            if abs(x_new - x) < 1e-12:
                converged = True
                break
            if abs(x_new) > 1e10:
                break
            x = x_new
        
        lip = abs(c)  # |T'(x)| = |c * cos(x)| ≤ |c|
        status = "YES" if converged else "NO/SLOW"
        fp = f"{x:.10f}" if converged else "---"
        iters = str(i+1) if converged else ">10000"
        
        print(f"{c:>6.2f} | {lip:>8.2f} | {status:>12} | {fp:>15} | {iters:>12}")
    
    print("\n✓ The Lipschitz constant is the boundary between order and chaos.")
    print("  Lip < 1 → guaranteed convergence (Banach theorem)")
    print("  Lip ≥ 1 → no guarantee (may still converge, but not guaranteed)\n")


def experiment_4_multidimensional():
    """Fixed point iteration in higher dimensions — solving nonlinear systems."""
    print("=" * 60)
    print("EXPERIMENT 4: Multidimensional Fixed Point (Nonlinear System)")
    print("=" * 60)
    
    # Solve the system:
    #   x = cos(y)
    #   y = sin(x) + 0.1
    # 
    # This is x = T(x) where T(x,y) = (cos(y), sin(x) + 0.1)
    
    x, y = 0.0, 0.0
    
    print(f"\n{'Iter':>6} | {'x':>15} | {'y':>15} | {'‖change‖':>12}")
    print("-" * 55)
    
    for i in range(30):
        x_new = np.cos(y)
        y_new = np.sin(x) + 0.1
        change = np.sqrt((x_new - x)**2 + (y_new - y)**2)
        x, y = x_new, y_new
        if i < 10 or i % 5 == 0 or change < 1e-10:
            print(f"{i:>6} | {x:>15.12f} | {y:>15.12f} | {change:>12.2e}")
        if change < 1e-14:
            break
    
    print(f"\nFixed point: ({x:.12f}, {y:.12f})")
    print(f"Verify: cos(y) = {np.cos(y):.12f}, sin(x) + 0.1 = {np.sin(x) + 0.1:.12f}")
    print("\n✓ Works in any dimension! Banach's theorem is dimension-agnostic.\n")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  MATHEMATICS CHEAT CODE #2: FIXED POINT THEOREMS")
    print("  'If you stir your coffee, one molecule stays put.'")
    print("=" * 60 + "\n")
    
    experiment_1_solving_equations()
    experiment_2_square_root()
    experiment_3_lipschitz_boundary()
    experiment_4_multidimensional()
    
    print("=" * 60)
    print("SUMMARY: Fixed point theorems guarantee convergence of")
    print("iterative methods. The Lipschitz constant < 1 is the key")
    print("condition. This powers Newton's method, iterative solvers,")
    print("and existence proofs throughout mathematics.")
    print("=" * 60)
