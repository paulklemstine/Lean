#!/usr/bin/env python3
"""
Nilpotent Algebra: Geometric Series Inverses — Interactive Demonstrations

This module demonstrates the key theorems from the formal Lean 4 development:
1. The geometric series inverse for (1 - x) when x is nilpotent
2. Nilpotency bounds for sums
3. The truncated binomial expansion
4. Application: Automatic differentiation via dual numbers
5. Application: Matrix perturbation theory

Requirements: numpy, matplotlib (pip install numpy matplotlib)
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


# =============================================================================
# Demo 1: Geometric Series Inverse for Nilpotent Matrices
# =============================================================================

def demo_geometric_series_inverse():
    """
    Demonstrate: If X^n = 0, then (I - X)^{-1} = I + X + X^2 + ... + X^{n-1}.

    We construct a strictly upper triangular 4x4 matrix (which is nilpotent
    with X^4 = 0) and verify the geometric series formula.
    """
    print("=" * 70)
    print("DEMO 1: Geometric Series Inverse for Nilpotent Matrices")
    print("=" * 70)

    # A strictly upper triangular matrix is nilpotent
    X = np.array([
        [0, 2, 1, 3],
        [0, 0, 4, 1],
        [0, 0, 0, 5],
        [0, 0, 0, 0]
    ], dtype=float)

    print("\nNilpotent matrix X (strictly upper triangular):")
    print(X)

    # Verify nilpotency
    n = 4
    for k in range(1, n + 1):
        Xk = np.linalg.matrix_power(X, k)
        print(f"  X^{k} = 0? {np.allclose(Xk, 0)}")

    # Compute geometric series: I + X + X^2 + X^3
    I = np.eye(n)
    geom_sum = sum(np.linalg.matrix_power(X, k) for k in range(n))

    print(f"\nGeometric sum S = I + X + X² + X³:")
    print(np.round(geom_sum, 4))

    # Verify (I - X) * S = I
    IminusX = I - X
    product = IminusX @ geom_sum

    print(f"\n(I - X) × S = I? {np.allclose(product, I)}")
    print(f"Product:\n{np.round(product, 10)}")

    # Compare with numpy's built-in inverse
    numpy_inv = np.linalg.inv(IminusX)
    print(f"\nMatches np.linalg.inv(I-X)? {np.allclose(geom_sum, numpy_inv)}")


# =============================================================================
# Demo 2: Nilpotency Bound for Sums
# =============================================================================

def demo_nilpotency_bound():
    """
    Demonstrate: If X^m = 0 and Y^n = 0 (commuting), then (X+Y)^{m+n-1} = 0.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Nilpotency Index Bound for Sums")
    print("=" * 70)

    def poly_mul(a, b, n=6):
        result = np.zeros(n)
        for i in range(n):
            for j in range(n):
                if i + j < n:
                    result[i + j] += a[i] * b[j]
        return result

    def poly_pow(a, k, n=6):
        result = np.zeros(n)
        result[0] = 1
        for _ in range(k):
            result = poly_mul(result, a, n)
        return result

    # x = t (nilpotent of index 4 in Z[t]/(t^6))
    x = np.zeros(6); x[1] = 1  # t
    # y = t^2 (nilpotent of index 3)
    y = np.zeros(6); y[2] = 1  # t^2

    m, n_val = 6, 3
    bound = m + n_val - 1

    print(f"\nx = t in Z[t]/(t^6), nilpotency index m = {m}")
    print(f"y = t² in Z[t]/(t^6), nilpotency index n = {n_val}")
    print(f"Predicted bound: (x+y)^(m+n-1) = (x+y)^{bound} = 0")

    x_plus_y = x + y
    print(f"\nx + y = t + t² (in truncated polynomial ring)")

    for k in range(1, bound + 1):
        pk = poly_pow(x_plus_y, k)
        is_zero = np.allclose(pk, 0)
        print(f"  (x+y)^{k} = {pk[:6]}  {'= 0 ✓' if is_zero else '≠ 0'}")


# =============================================================================
# Demo 3: Truncated Binomial Expansion
# =============================================================================

def demo_truncated_binomial():
    """
    Demonstrate: If x^n = 0, then (1+x)^k = Σ_{i=0}^{n-1} C(k,i) x^i.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Truncated Binomial Expansion")
    print("=" * 70)

    X = np.array([
        [0, 1, 0],
        [0, 0, 1],
        [0, 0, 0]
    ], dtype=float)

    n = 3
    I = np.eye(n)

    print(f"\nX = shift matrix (X³ = 0, nilpotency index n = {n})")

    for k in [2, 5, 10, 100]:
        direct = np.linalg.matrix_power(I + X, k)
        truncated = sum(comb(k, i) * np.linalg.matrix_power(X, i)
                        for i in range(n))

        match = np.allclose(direct, truncated)
        print(f"\n  k = {k}:")
        print(f"    (I+X)^{k} via matrix power: {direct[0].tolist()}")
        print(f"    Truncated binomial (3 terms): {truncated[0].tolist()}")
        print(f"    Match: {'✓' if match else '✗'}")

    k = 100
    print(f"\n  Key insight for k={k}: (I+X)^{k} = I + {k}·X + {comb(k,2)}·X²")
    print(f"  Only 3 terms needed despite k={k}!")


# =============================================================================
# Demo 4: Automatic Differentiation via Dual Numbers
# =============================================================================

class DualNumber:
    """
    Dual number a + bε where ε² = 0.
    The simplest nilpotent extension — foundation of forward-mode autodiff.
    """

    def __init__(self, real, dual=0.0):
        self.real = real
        self.dual = dual

    def __repr__(self):
        return f"{self.real:.6f} + {self.dual:.6f}ε"

    def __add__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real + other, self.dual)
        return DualNumber(self.real + other.real, self.dual + other.dual)

    def __radd__(self, other):
        return self.__add__(other)

    def __sub__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real - other, self.dual)
        return DualNumber(self.real - other.real, self.dual - other.dual)

    def __rsub__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(other - self.real, -self.dual)
        return other.__sub__(self)

    def __mul__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real * other, self.dual * other)
        return DualNumber(
            self.real * other.real,
            self.real * other.dual + self.dual * other.real
        )

    def __rmul__(self, other):
        return self.__mul__(other)

    def __truediv__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real / other, self.dual / other)
        inv_real = 1.0 / other.real
        return DualNumber(
            self.real * inv_real,
            (self.dual * other.real - self.real * other.dual) * inv_real**2
        )

    def __pow__(self, n):
        if n == 0:
            return DualNumber(1, 0)
        result = DualNumber(1, 0)
        for _ in range(n):
            result = result * self
        return result

    @staticmethod
    def sin(d):
        return DualNumber(np.sin(d.real), d.dual * np.cos(d.real))

    @staticmethod
    def cos(d):
        return DualNumber(np.cos(d.real), -d.dual * np.sin(d.real))

    @staticmethod
    def exp(d):
        ea = np.exp(d.real)
        return DualNumber(ea, d.dual * ea)


def demo_automatic_differentiation():
    """
    Demonstrate automatic differentiation using dual numbers.
    f(a + ε) = f(a) + f'(a)·ε — exact derivative computation.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Automatic Differentiation via Dual Numbers")
    print("=" * 70)
    print("\nThe dual number ε satisfies ε² = 0 (nilpotent of index 2).")
    print("By the truncated binomial theorem: f(a + ε) = f(a) + f'(a)·ε")

    test_cases = [
        ("f(x) = x³",           lambda d: d**3,                     lambda x: 3*x**2,          2.0),
        ("f(x) = x⁴ - 3x² + 2x", lambda d: d**4 - 3*d**2 + 2*d,   lambda x: 4*x**3 - 6*x + 2, 1.5),
        ("f(x) = 1/(1-x)",      lambda d: DualNumber(1,0) / (DualNumber(1,0) - d),
                                                                     lambda x: 1/(1-x)**2,      0.3),
        ("f(x) = sin(x)",       lambda d: DualNumber.sin(d),        lambda x: np.cos(x),       np.pi/4),
        ("f(x) = exp(x)",       lambda d: DualNumber.exp(d),        lambda x: np.exp(x),       1.0),
    ]

    for name, f_dual, f_prime, a in test_cases:
        x = DualNumber(a, 1.0)
        result = f_dual(x)
        auto_deriv = result.dual
        exact_deriv = f_prime(a)

        print(f"\n  {name} at x = {a}:")
        print(f"    f({a} + ε) = {result}")
        print(f"    Auto derivative:  {auto_deriv:.10f}")
        print(f"    Exact derivative: {exact_deriv:.10f}")
        print(f"    Error: {abs(auto_deriv - exact_deriv):.2e}")


# =============================================================================
# Demo 5: Perturbation Theory Visualization
# =============================================================================

def demo_perturbation_theory():
    """
    Demonstrate: (A + εE)^{-1} via geometric/Neumann series.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Matrix Perturbation Theory (Neumann Series)")
    print("=" * 70)

    A = np.array([[4, 1], [1, 3]], dtype=float)
    E = np.array([[1, -1], [2, 1]], dtype=float)
    A_inv = np.linalg.inv(A)

    epsilons = np.linspace(0.001, 0.5, 100)
    errors = {k: [] for k in range(5)}

    for eps in epsilons:
        exact_inv = np.linalg.inv(A + eps * E)
        approx = np.eye(2).copy()
        for k in range(5):
            neumann_inv = approx @ A_inv
            error = np.linalg.norm(neumann_inv - exact_inv) / np.linalg.norm(exact_inv)
            errors[k].append(error)
            approx = approx + ((-eps) ** (k + 1)) * np.linalg.matrix_power(A_inv @ E, k + 1)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    for k in range(5):
        ax1.semilogy(epsilons, errors[k], label=f'Order {k}', linewidth=2)

    ax1.set_xlabel('Perturbation ε', fontsize=12)
    ax1.set_ylabel('Relative Error', fontsize=12)
    ax1.set_title('Neumann Series Convergence\n(Geometric Series for Matrix Inverses)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    n_terms = 6
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, n_terms))
    eps_val = 0.3
    X = A_inv @ E
    bar_data = [(eps_val ** k) * np.linalg.norm(np.linalg.matrix_power(X, k))
                for k in range(n_terms)]

    ax2.bar(range(n_terms), bar_data, color=colors, edgecolor='black', linewidth=0.5)
    ax2.set_xlabel('Term k', fontsize=12)
    ax2.set_ylabel('||εᵏ(A⁻¹E)ᵏ||', fontsize=12)
    ax2.set_title(f'Geometric Series Terms (ε = {eps_val})', fontsize=13)
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('demos/perturbation_theory.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Plot saved to demos/perturbation_theory.png")


# =============================================================================
# Demo 6: Visualization of Nilpotent Structure
# =============================================================================

def demo_nilpotent_visualization():
    """
    Visualize the 'decay' of powers of a nilpotent matrix
    and how the geometric series builds the inverse.
    """
    print("\n" + "=" * 70)
    print("DEMO 6: Visualizing Nilpotent Power Decay and Inverse Construction")
    print("=" * 70)

    n = 5
    X = np.zeros((n, n))
    X[0, 1] = 1; X[0, 3] = 2
    X[1, 2] = 3; X[1, 4] = 1
    X[2, 3] = 2
    X[3, 4] = 4

    fig, axes = plt.subplots(2, n, figsize=(16, 7))
    I = np.eye(n)

    for k in range(n):
        Xk = np.linalg.matrix_power(X, k)
        axes[0, k].imshow(np.abs(Xk), cmap='YlOrRd', vmin=0,
                          vmax=np.max(np.abs(X)) * 2)
        axes[0, k].set_title(f'|X^{k}|', fontsize=11)
        axes[0, k].set_xticks([]); axes[0, k].set_yticks([])

    for k in range(n):
        partial_sum = sum(np.linalg.matrix_power(X, j) for j in range(k + 1))
        exact_inv = np.linalg.inv(I - X)
        error = np.linalg.norm(partial_sum - exact_inv)

        axes[1, k].imshow(np.abs(partial_sum), cmap='YlGnBu', vmin=0,
                          vmax=np.max(np.abs(exact_inv)))
        axes[1, k].set_title(f'Σ X^j (j≤{k})\nerr={error:.1f}', fontsize=10)
        axes[1, k].set_xticks([]); axes[1, k].set_yticks([])

    axes[0, 0].set_ylabel('Powers of X\n(decay to 0)', fontsize=11)
    axes[1, 0].set_ylabel('Partial Inverse\n(converges!)', fontsize=11)

    fig.suptitle('Nilpotent Matrix: Power Decay and Geometric Series Inverse',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/nilpotent_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Plot saved to demos/nilpotent_visualization.png")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   THE ALGEBRA OF NILPOTENTS: GEOMETRIC SERIES INVERSES            ║")
    print("║   Interactive Demonstrations                                       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_geometric_series_inverse()
    demo_nilpotency_bound()
    demo_truncated_binomial()
    demo_automatic_differentiation()
    demo_perturbation_theory()
    demo_nilpotent_visualization()

    print("\n" + "=" * 70)
    print("All demonstrations complete!")
    print("=" * 70)
