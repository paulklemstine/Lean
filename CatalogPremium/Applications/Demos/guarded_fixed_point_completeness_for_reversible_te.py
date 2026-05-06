"""
Guarded Fixed-Point Iteration Demo
===================================

Demonstrates the Kleene iteration chain F^n(⊥) converging to the least
fixed point for several concrete monotone ω-continuous functions on
ordered domains. This is the computational heart of the guarded trace
construction formalized in Lean.

Key insight: For any monotone ω-continuous F on an ω-cpo with bottom,
the sequence ⊥, F(⊥), F²(⊥), ... converges to the least fixed point.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple

# ──────────────────────────────────────────────────────────────────────
# Example 1: Scalar fixed point on [0, 1] with ⊥ = 0
# ──────────────────────────────────────────────────────────────────────

def demo_scalar_fixpoint():
    """Demonstrate Kleene iteration for F(x) = (x + 1) / 2 on [0, 1]."""
    F = lambda x: (x + 1) / 2
    bot = 0.0
    
    iterates = [bot]
    for _ in range(20):
        iterates.append(F(iterates[-1]))
    
    fixed_point = 1.0  # The unique fixed point
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Plot the iteration chain
    ax1.plot(iterates, 'b.-', markersize=8, label='F^n(⊥)')
    ax1.axhline(y=fixed_point, color='r', linestyle='--', label=f'Fixed point = {fixed_point}')
    ax1.set_xlabel('Iteration n')
    ax1.set_ylabel('F^n(⊥)')
    ax1.set_title('Kleene Iteration: F(x) = (x+1)/2')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Plot convergence rate
    errors = [abs(x - fixed_point) for x in iterates]
    ax2.semilogy(errors, 'g.-', markersize=8)
    ax2.set_xlabel('Iteration n')
    ax2.set_ylabel('|F^n(⊥) - fixed point|')
    ax2.set_title('Convergence Rate (Exponential)')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/scalar_fixpoint.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Scalar fixed point demo:")
    print(f"  F(x) = (x+1)/2, ⊥ = 0")
    print(f"  Fixed point: {fixed_point}")
    print(f"  After 10 iterations: {iterates[10]:.10f}")
    print(f"  After 20 iterations: {iterates[20]:.15f}")
    print()

# ──────────────────────────────────────────────────────────────────────
# Example 2: Vector fixed point (feedback system)
# ──────────────────────────────────────────────────────────────────────

def demo_vector_fixpoint():
    """Demonstrate Kleene iteration for a 2D contractive system.
    
    This models a feedback circuit with 2 state variables:
      x_{n+1} = 0.3 * x_n + 0.1 * y_n + 0.5
      y_{n+1} = 0.1 * x_n + 0.4 * y_n + 0.3
    """
    A = np.array([[0.3, 0.1], [0.1, 0.4]])
    b = np.array([0.5, 0.3])
    F = lambda x: A @ x + b
    bot = np.array([0.0, 0.0])
    
    iterates = [bot.copy()]
    for _ in range(30):
        iterates.append(F(iterates[-1]))
    
    # Compute exact fixed point: x = Ax + b => x = (I - A)^{-1} b
    fixed_point = np.linalg.solve(np.eye(2) - A, b)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Component trajectories
    xs = [v[0] for v in iterates]
    ys = [v[1] for v in iterates]
    
    axes[0].plot(xs, 'b.-', label='x component')
    axes[0].plot(ys, 'r.-', label='y component')
    axes[0].axhline(y=fixed_point[0], color='b', linestyle='--', alpha=0.5)
    axes[0].axhline(y=fixed_point[1], color='r', linestyle='--', alpha=0.5)
    axes[0].set_xlabel('Iteration n')
    axes[0].set_ylabel('Value')
    axes[0].set_title('Vector Kleene Iteration')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Phase portrait
    axes[1].plot(xs, ys, 'g.-', markersize=6, alpha=0.7)
    axes[1].plot(xs[0], ys[0], 'ko', markersize=10, label='⊥ = (0,0)')
    axes[1].plot(fixed_point[0], fixed_point[1], 'r*', markersize=15, label='Fixed point')
    axes[1].set_xlabel('x')
    axes[1].set_ylabel('y')
    axes[1].set_title('Phase Portrait')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # Convergence
    errors = [np.linalg.norm(v - fixed_point) for v in iterates]
    axes[2].semilogy(errors, 'g.-', markersize=6)
    axes[2].set_xlabel('Iteration n')
    axes[2].set_ylabel('||F^n(⊥) - x*||')
    axes[2].set_title('Convergence Rate')
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/vector_fixpoint.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Vector fixed point demo:")
    print(f"  A = [[0.3, 0.1], [0.1, 0.4]], b = [0.5, 0.3]")
    print(f"  Fixed point: ({fixed_point[0]:.6f}, {fixed_point[1]:.6f})")
    print(f"  Spectral radius of A: {max(abs(np.linalg.eigvals(A))):.4f}")
    print()

# ──────────────────────────────────────────────────────────────────────
# Example 3: Feedback circuit simulation
# ──────────────────────────────────────────────────────────────────────

def demo_feedback_circuit():
    """Simulate a reversible feedback circuit and show finite unrolling.
    
    Circuit: f(s, a) = (s ⊕ a, s)  (XOR gate with state feedback)
    This is reversible: inv(s', b) = (s' ⊕ b, s')
    
    We demonstrate that finite unrollings converge to the traced output.
    """
    # For a simple binary example, work over integers mod 2^8
    MOD = 256
    
    def circuit_f(s: int, a: int) -> Tuple[int, int]:
        """Forward circuit: state XOR input, output = old state."""
        new_s = (s ^ a) % MOD
        out = s
        return (new_s, out)
    
    def circuit_inv(sp: int, b: int) -> Tuple[int, int]:
        """Inverse circuit."""
        s = b
        a = (sp ^ b) % MOD
        return (s, a)
    
    # Verify reversibility
    print("Feedback circuit demo (XOR with state feedback):")
    for s in range(10):
        for a in range(10):
            sp, b = circuit_f(s, a)
            s2, a2 = circuit_inv(sp, b)
            assert (s2, a2) == (s, a), f"Reversibility failed at s={s}, a={a}"
    print("  Reversibility verified for all test cases ✓")
    
    # Finite unrolling
    def unfoldn(f, n: int, s: int, a: int) -> Tuple[int, int]:
        """Finite unrolling at depth n."""
        if n == 0:
            return (s, f(s, a)[1])
        else:
            r = unfoldn(f, n - 1, s, a)
            return f(r[0], a)
    
    # Show unrollings for fixed input
    a_input = 42
    s_init = 0  # ⊥ = 0
    
    print(f"\n  Finite unrollings for input a={a_input}, initial state s={s_init}:")
    print(f"  {'n':>3} | {'state':>8} | {'output':>8}")
    print(f"  {'---':>3}-+-{'--------':>8}-+-{'--------':>8}")
    
    prev_state = None
    for n in range(12):
        s_n, b_n = unfoldn(circuit_f, n, s_init, a_input)
        marker = " ← stabilized" if s_n == prev_state else ""
        print(f"  {n:3d} | {s_n:8d} | {b_n:8d}{marker}")
        prev_state = s_n
    
    print()

# ──────────────────────────────────────────────────────────────────────
# Example 4: Bekič decomposition visualization
# ──────────────────────────────────────────────────────────────────────

def demo_bekic():
    """Demonstrate the Bekič decomposition theorem.
    
    For a product-valued fixed point F : (X × Y) → (X × Y),
    the fixed point decomposes as (x*, y*) where x* and y*
    can be computed by nested scalar fixed points.
    """
    # System: F(x, y) = (0.3x + 0.2y + 1, 0.1x + 0.5y + 0.5)
    def F_product(x, y):
        return (0.3*x + 0.2*y + 1, 0.1*x + 0.5*y + 0.5)
    
    # Joint iteration
    x, y = 0.0, 0.0
    joint_history = [(x, y)]
    for _ in range(30):
        x, y = F_product(x, y)
        joint_history.append((x, y))
    
    joint_fp = (x, y)
    
    # Bekič: first solve for x in terms of y, then solve for y
    # F_x(x, y) = 0.3x + 0.2y + 1  => x* = (0.2y + 1) / 0.7
    # Substitute into F_y: y = 0.1 * (0.2y + 1)/0.7 + 0.5y + 0.5
    # => y = 0.02y/0.7 + 0.1/0.7 + 0.5y + 0.5
    # => y(1 - 0.5 - 0.02/0.7) = 0.1/0.7 + 0.5
    
    # Nested iteration for x given y
    def Fx(x, y_val):
        return 0.3*x + 0.2*y_val + 1
    
    def Fy(y, x_func):
        """Given x as a function of y, iterate y."""
        x_val = x_func(y)
        return 0.1*x_val + 0.5*y + 0.5
    
    # Bekič nested iteration
    y_bekic = 0.0
    bekic_y_history = [y_bekic]
    for _ in range(30):
        # Inner: solve for x given current y
        x_inner = 0.0
        for _ in range(30):
            x_inner = Fx(x_inner, y_bekic)
        # Outer: update y
        y_bekic = 0.1*x_inner + 0.5*y_bekic + 0.5
        bekic_y_history.append(y_bekic)
    
    x_bekic = 0.0
    for _ in range(30):
        x_bekic = Fx(x_bekic, y_bekic)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Joint vs nested convergence
    xs_joint = [p[0] for p in joint_history]
    ys_joint = [p[1] for p in joint_history]
    
    axes[0].plot(xs_joint, 'b.-', label='x (joint iteration)')
    axes[0].plot(ys_joint, 'r.-', label='y (joint iteration)')
    axes[0].plot(bekic_y_history, 'g--', linewidth=2, label='y (Bekič nested)')
    axes[0].axhline(y=joint_fp[0], color='b', linestyle=':', alpha=0.5)
    axes[0].axhline(y=joint_fp[1], color='r', linestyle=':', alpha=0.5)
    axes[0].set_xlabel('Iteration')
    axes[0].set_ylabel('Value')
    axes[0].set_title('Joint vs Bekič Nested Iteration')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Final comparison
    methods = ['Joint', 'Bekič']
    x_vals = [joint_fp[0], x_bekic]
    y_vals = [joint_fp[1], y_bekic]
    
    x_pos = np.arange(len(methods))
    width = 0.35
    
    axes[1].bar(x_pos - width/2, x_vals, width, label='x component', color='steelblue')
    axes[1].bar(x_pos + width/2, y_vals, width, label='y component', color='salmon')
    axes[1].set_xticks(x_pos)
    axes[1].set_xticklabels(methods)
    axes[1].set_ylabel('Fixed Point Value')
    axes[1].set_title('Bekič Decomposition: Same Fixed Point')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('demos/bekic_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("Bekič decomposition demo:")
    print(f"  Joint fixed point:  ({joint_fp[0]:.8f}, {joint_fp[1]:.8f})")
    print(f"  Bekič fixed point:  ({x_bekic:.8f}, {y_bekic:.8f})")
    print(f"  Difference: ({abs(joint_fp[0]-x_bekic):.2e}, {abs(joint_fp[1]-y_bekic):.2e})")
    print()

# ──────────────────────────────────────────────────────────────────────
# Example 5: Finite unrolling invariance
# ──────────────────────────────────────────────────────────────────────

def demo_finite_unrolling_invariance():
    """Demonstrate that equal finite unrollings imply equal traces.
    
    This is the computational content of the main theorem:
    if all finite approximations of two feedback loops agree,
    then their denotational traces are identical.
    """
    # Two circuits that are identical (trivially equal unrollings)
    def f1(s, a):
        return ((s + a) % 100, (s * 2 + a) % 100)
    
    def f2(s, a):
        return ((s + a) % 100, (s * 2 + a) % 100)
    
    # A third circuit that differs
    def f3(s, a):
        return ((s + a + 1) % 100, (s * 2 + a) % 100)
    
    def unfoldn(f, n, s, a):
        if n == 0:
            return (s, f(s, a)[1])
        else:
            r = unfoldn(f, n-1, s, a)
            return f(r[0], a)
    
    # Compare unrollings
    print("Finite unrolling invariance demo:")
    print("\n  Comparing f1 vs f2 (identical circuits):")
    
    all_equal_12 = True
    all_equal_13 = True
    
    for n in range(8):
        for s in range(5):
            for a in range(5):
                r1 = unfoldn(f1, n, s, a)
                r2 = unfoldn(f2, n, s, a)
                r3 = unfoldn(f3, n, s, a)
                if r1 != r2:
                    all_equal_12 = False
                if r1 != r3:
                    all_equal_13 = False
    
    print(f"    All unrollings equal: {all_equal_12} → traces must be equal ✓")
    print(f"\n  Comparing f1 vs f3 (different circuits):")
    print(f"    All unrollings equal: {all_equal_13} → traces may differ")
    
    # Show where they diverge
    s, a = 0, 1
    print(f"\n  Unrollings at s={s}, a={a}:")
    print(f"  {'n':>3} | {'f1':>12} | {'f3':>12} | {'equal':>6}")
    print(f"  {'---':>3}-+-{'------------':>12}-+-{'------------':>12}-+-{'------':>6}")
    for n in range(8):
        r1 = unfoldn(f1, n, s, a)
        r3 = unfoldn(f3, n, s, a)
        eq = "✓" if r1 == r3 else "✗"
        print(f"  {n:3d} | {str(r1):>12} | {str(r3):>12} | {eq:>6}")
    print()


# ──────────────────────────────────────────────────────────────────────
# Run all demos
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 65)
    print("  GUARDED FIXED-POINT COMPLETENESS FOR REVERSIBLE")
    print("  TEMPORAL COMPUTATION — COMPUTATIONAL DEMONSTRATIONS")
    print("=" * 65)
    print()
    
    demo_scalar_fixpoint()
    demo_vector_fixpoint()
    demo_feedback_circuit()
    demo_bekic()
    demo_finite_unrolling_invariance()
    
    print("=" * 65)
    print("  All demos completed. Plots saved to demos/")
    print("=" * 65)
