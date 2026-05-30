#!/usr/bin/env python3
"""
Visualization: Automatic Differentiation Accuracy

Compares the exact derivative (computed via the Leibniz rule / dual numbers)
with finite difference approximation, showing that the differential
lambda-calculus approach gives exact results.
"""

import matplotlib.pyplot as plt
import numpy as np
import math


class DualNumber:
    """Dual number for forward-mode AD."""
    def __init__(self, real, dual=0.0):
        self.real = real
        self.dual = dual

    def __add__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real + other, self.dual)
        return DualNumber(self.real + other.real, self.dual + other.dual)
    def __radd__(self, other): return self.__add__(other)

    def __mul__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real * other, self.dual * other)
        return DualNumber(self.real * other.real,
                         self.dual * other.real + self.real * other.dual)
    def __rmul__(self, other): return self.__mul__(other)

    def __sub__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real - other, self.dual)
        return DualNumber(self.real - other.real, self.dual - other.dual)
    def __rsub__(self, other):
        return DualNumber(other - self.real, -self.dual) if isinstance(other, (int, float)) else NotImplemented

    def __truediv__(self, other):
        if isinstance(other, (int, float)):
            return DualNumber(self.real / other, self.dual / other)
        return DualNumber(self.real / other.real,
                         (self.dual * other.real - self.real * other.dual) / other.real**2)

    def __pow__(self, n):
        if isinstance(n, (int, float)):
            return DualNumber(self.real ** n, n * self.real ** (n-1) * self.dual)
        raise NotImplementedError


def dual_sin(x):
    return DualNumber(math.sin(x.real), math.cos(x.real) * x.dual)

def dual_exp(x):
    e = math.exp(x.real)
    return DualNumber(e, e * x.dual)


def plot_ad_comparison():
    """Compare AD (Leibniz-based) vs finite differences."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Test function: f(x) = x³ - 2x² + x - 1
    # True derivative: f'(x) = 3x² - 4x + 1
    x_vals = np.linspace(-1, 3, 200)

    def f_real(x):
        return x**3 - 2*x**2 + x - 1

    def f_dual(x):
        return x**3 - 2*x**2 + x - 1

    def f_true_deriv(x):
        return 3*x**2 - 4*x + 1

    # Panel 1: Function and its derivative
    ax = axes[0, 0]
    ax.plot(x_vals, f_real(x_vals), 'b-', linewidth=2, label='f(x) = x³-2x²+x-1')
    ax.plot(x_vals, f_true_deriv(x_vals), 'r--', linewidth=2, label="f'(x) = 3x²-4x+1")
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_title('Function and True Derivative', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: AD vs finite difference errors
    ax = axes[0, 1]
    h_values = np.logspace(-1, -15, 30)
    x_test = 1.5
    true_deriv = f_true_deriv(x_test)

    fd_errors = []
    for h in h_values:
        fd = (f_real(x_test + h) - f_real(x_test)) / h
        fd_errors.append(abs(fd - true_deriv))

    # AD derivative (exact via Leibniz rule)
    ad_result = f_dual(DualNumber(x_test, 1.0))
    ad_error = abs(ad_result.dual - true_deriv)

    ax.loglog(h_values, fd_errors, 'bo-', markersize=4, label='Finite difference')
    ax.axhline(y=ad_error if ad_error > 0 else 1e-16, color='red', linewidth=2,
               linestyle='--', label=f'AD (Leibniz): error = {ad_error:.1e}')
    ax.axhline(y=np.finfo(float).eps, color='gray', linewidth=1, linestyle=':',
               label='Machine epsilon')
    ax.set_xlabel('Step size h')
    ax.set_ylabel('|error|')
    ax.set_title(f'Derivative Error at x={x_test}', fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Leibniz rule verification for product
    ax = axes[1, 0]

    def g(x): return x**2 + 1
    def h_fn(x): return 2*x - 3
    def g_prime(x): return 2*x
    def h_prime(x): return 2.0  # constant

    x_pts = np.linspace(-2, 4, 100)
    # D(g*h) directly
    d_gh = np.array([
        (g(DualNumber(x, 1.0)) * h_fn(DualNumber(x, 1.0))).dual
        for x in x_pts
    ])
    # D(g)*h + g*D(h)
    leibniz = np.array([g_prime(x)*h_fn(x) + g(x)*h_prime(x) for x in x_pts])

    ax.plot(x_pts, d_gh, 'b-', linewidth=3, label='D(g·h) via AD')
    ax.plot(x_pts, leibniz, 'r--', linewidth=2, label="g'·h + g·h' (Leibniz)")
    ax.fill_between(x_pts, d_gh, leibniz, alpha=0.1, color='green')
    ax.set_xlabel('x')
    ax.set_ylabel("(g·h)'(x)")
    ax.set_title('Leibniz Rule Verification', fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.text(0.05, 0.95, f'Max discrepancy: {np.max(np.abs(d_gh - leibniz)):.1e}',
            transform=ax.transAxes, fontsize=10, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    # Panel 4: Iterated derivative convergence
    ax = axes[1, 1]

    # D^n(polynomial of degree d) = 0 for n > d
    degrees = range(1, 7)
    n_derivs = range(0, 8)

    # For each degree d, compute D^n(x^d) at x=1
    results = np.zeros((len(list(degrees)), len(list(n_derivs))))
    for i, d in enumerate(degrees):
        val = 1.0  # coefficient
        for j, n in enumerate(n_derivs):
            if n <= d:
                # d! / (d-n)!
                coeff = 1.0
                for k in range(d, d-n, -1):
                    coeff *= k
                results[i, j] = coeff
            else:
                results[i, j] = 0

    # Normalize for display
    log_results = np.log10(results + 1)

    im = ax.imshow(log_results, aspect='auto', cmap='YlGnBu',
                   interpolation='nearest')
    ax.set_xticks(range(len(list(n_derivs))))
    ax.set_xticklabels([str(n) for n in n_derivs])
    ax.set_yticks(range(len(list(degrees))))
    ax.set_yticklabels([f'x^{d}' for d in degrees])
    ax.set_xlabel('Number of derivatives (n)')
    ax.set_ylabel('Polynomial')
    ax.set_title('D^n(x^d): Vanishing Pattern', fontweight='bold')

    # Add text annotations
    for i in range(len(list(degrees))):
        for j in range(len(list(n_derivs))):
            val = int(results[i, j])
            color = 'white' if log_results[i, j] > 2 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=8, color=color)

    plt.colorbar(im, ax=ax, label='log₁₀(value + 1)')

    plt.suptitle("Differential λ-Calculus: AD Correctness via the Leibniz Rule",
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig("viz_ad_comparison.png", dpi=150, bbox_inches='tight')
    print("Saved: viz_ad_comparison.png")
    plt.close()


if __name__ == "__main__":
    plot_ad_comparison()
    print("AD comparison visualization generated.")
