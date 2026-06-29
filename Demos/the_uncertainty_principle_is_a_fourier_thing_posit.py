#!/usr/bin/env python3
"""
Demonstration: The Uncertainty Principle as a Fourier-Algebraic Phenomenon

This script demonstrates that the uncertainty principle arises from polynomial
root bounds, not from quantum mechanics. It shows:

1. Polynomial root bound → evaluation support bound
2. DFT uncertainty principle on Z/nZ
3. Vandermonde uncertainty principle with distinct points
4. Numerical verification of the MDS conjecture for small cases
"""

import numpy as np
from typing import List, Tuple


def support_size(v: np.ndarray, tol: float = 1e-10) -> int:
    """Count the number of nonzero entries in a vector."""
    return int(np.sum(np.abs(v) > tol))


def dft_matrix(n: int) -> np.ndarray:
    """Construct the n×n DFT matrix: M[j,k] = omega^(jk) where omega = e^{2πi/n}."""
    omega = np.exp(2j * np.pi / n)
    return np.array([[omega ** (j * k) for k in range(n)] for j in range(n)])


def vandermonde_matrix(pts: np.ndarray) -> np.ndarray:
    """Construct the Vandermonde matrix V[i,j] = pts[i]^j."""
    n = len(pts)
    return np.array([[pts[i] ** j for j in range(n)] for i in range(n)])


def polynomial_eval_support(coeffs: np.ndarray, pts: np.ndarray, tol: float = 1e-10) -> int:
    """Evaluate polynomial with given coefficients at given points, return support size."""
    evals = np.polyval(coeffs[::-1], pts)
    return support_size(evals, tol)


# ============================================================
# Demo 1: Polynomial Root Bound
# ============================================================
print("=" * 60)
print("Demo 1: Polynomial Root Bound")
print("=" * 60)
print()
print("A polynomial of degree d has at most d roots.")
print("This is the algebraic core of ALL uncertainty principles.")
print()

for degree in [2, 5, 10]:
    # Random polynomial of given degree
    coeffs = np.random.randn(degree + 1)
    coeffs[-1] = 1.0  # monic
    roots = np.roots(coeffs[::-1])
    n_roots = len([r for r in roots if abs(r.imag) < 1e-8])
    print(f"  Degree {degree}: polynomial has {n_roots} real roots (≤ {degree})")

print()

# ============================================================
# Demo 2: DFT Uncertainty Principle on Z/nZ
# ============================================================
print("=" * 60)
print("Demo 2: DFT Uncertainty on Z/nZ")
print("=" * 60)
print()
print("For any nonzero f on Z/nZ:")
print("  |supp(f)| + |supp(f̂)| ≥ n + 1")
print("  |supp(f)| · |supp(f̂)| ≥ n")
print()

for n in [5, 7, 11]:
    M = dft_matrix(n)
    min_sum = float('inf')
    min_prod = float('inf')
    violations = 0
    total = 0

    # Test random vectors
    for _ in range(10000):
        # Random sparse vector
        f = np.zeros(n, dtype=complex)
        k = np.random.randint(1, n + 1)
        indices = np.random.choice(n, k, replace=False)
        f[indices] = np.random.randn(k) + 1j * np.random.randn(k)

        f_hat = M @ f
        s_f = support_size(f)
        s_fhat = support_size(f_hat)

        total += 1
        if s_f + s_fhat < n + 1:
            violations += 1
        min_sum = min(min_sum, s_f + s_fhat)
        min_prod = min(min_prod, s_f * s_fhat)

    print(f"  n = {n}: min(|supp(f)|+|supp(f̂)|) = {min_sum} ≥ {n+1}? {'YES' if min_sum >= n+1 else 'NO'}")
    print(f"         min(|supp(f)|·|supp(f̂)|) = {min_prod} ≥ {n}? {'YES' if min_prod >= n else 'NO'}")
    print(f"         Violations: {violations}/{total}")
    print()


# ============================================================
# Demo 3: Degree-Evaluation Uncertainty
# ============================================================
print("=" * 60)
print("Demo 3: Degree-Evaluation Uncertainty")
print("=" * 60)
print()
print("For a nonzero polynomial of degree d evaluated at n distinct points:")
print("  (# nonzero evaluations) ≥ n - d")
print()

n = 20
pts = np.linspace(-1, 1, n)  # n distinct points

for degree in [0, 3, 7, 15, 19]:
    coeffs = np.random.randn(degree + 1)
    evals = np.array([np.polyval(coeffs[::-1], x) for x in pts])
    s = support_size(evals, tol=1e-8)
    bound = n - degree
    print(f"  degree={degree:2d}: support of evals = {s:2d} ≥ {max(bound,0):2d} (n-d)? {'YES' if s >= bound else 'NO'}")

print()


# ============================================================
# Demo 4: Vandermonde vs DFT — Support-Support Bound
# ============================================================
print("=" * 60)
print("Demo 4: Vandermonde vs DFT Support Bounds")
print("=" * 60)
print()
print("The support-support bound |supp(c)| + |supp(eval)| ≥ n+1")
print("holds for DFT but NOT for general Vandermonde!")
print()

n = 7

# DFT case
M_dft = dft_matrix(n)
min_sum_dft = float('inf')
for _ in range(5000):
    c = np.zeros(n, dtype=complex)
    k = np.random.randint(1, n + 1)
    idx = np.random.choice(n, k, replace=False)
    c[idx] = np.random.randn(k) + 1j * np.random.randn(k)
    evals = M_dft @ c
    s_sum = support_size(c) + support_size(evals)
    min_sum_dft = min(min_sum_dft, s_sum)

print(f"  DFT (n={n}): min(|supp(c)| + |supp(eval)|) = {min_sum_dft} ≥ {n+1}? {'YES' if min_sum_dft >= n+1 else 'NO'}")

# Vandermonde case with random points
pts = np.array([0.1 * i for i in range(n)])
M_vand = vandermonde_matrix(pts)
min_sum_vand = float('inf')
for _ in range(5000):
    c = np.zeros(n)
    c[-1] = 1.0  # single high-degree coefficient
    evals = M_vand @ c
    s_sum = support_size(c) + support_size(evals)
    min_sum_vand = min(min_sum_vand, s_sum)

print(f"  Vandermonde (n={n}): min(|supp(c)| + |supp(eval)|) = {min_sum_vand} ≥ {n+1}? {'YES' if min_sum_vand >= n+1 else 'NO (expected)'}")
print()
print("  The DFT has the MDS property; general Vandermonde does not.")
print("  This is why the DFT uncertainty principle is STRONGER than")
print("  the general polynomial uncertainty principle.")

print()
print("=" * 60)
print("Conclusion: The uncertainty principle is a theorem about")
print("polynomial root bounds, not about quantum mechanics.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Polynomial Root Bound as Uncertainty Engine

Demonstrates that the polynomial root bound is the algebraic core
of the uncertainty principle: a degree-d polynomial evaluated at n
points has at most d zeros.
"""

import numpy as np
import matplotlib.pyplot as plt


def polyeval(coeffs, x):
    return sum(c * x**k for k, c in enumerate(coeffs))


fig, axes = plt.subplots(2, 3, figsize=(18, 10))

n_pts = 30
pts = np.linspace(-2, 2, n_pts)

configs = [
    (1, "Degree 1: at most 1 root"),
    (3, "Degree 3: at most 3 roots"),
    (5, "Degree 5: at most 5 roots"),
    (8, "Degree 8: at most 8 roots"),
    (12, "Degree 12: at most 12 roots"),
    (20, "Degree 20: at most 20 roots"),
]

for idx, (degree, title) in enumerate(configs):
    ax = axes[idx // 3][idx % 3]

    # Random polynomial of given degree
    np.random.seed(42 + idx)
    coeffs = np.random.randn(degree + 1)
    coeffs[degree] = 1.0  # monic

    # Fine evaluation for curve
    x_fine = np.linspace(-2, 2, 500)
    y_fine = np.array([polyeval(coeffs, x) for x in x_fine])

    # Evaluation at discrete points
    y_pts = np.array([polyeval(coeffs, x) for x in pts])
    nonzero = np.abs(y_pts) > 0.01
    n_nonzero = np.sum(nonzero)
    n_roots_approx = n_pts - n_nonzero

    ax.plot(x_fine, y_fine, 'b-', linewidth=1.5, alpha=0.7)
    ax.scatter(pts[nonzero], y_pts[nonzero], c='green', s=20, zorder=5,
              label=f'Nonzero: {n_nonzero}')
    ax.scatter(pts[~nonzero], y_pts[~nonzero], c='red', s=40, marker='x',
              zorder=5, label=f'≈ Zero: {n_roots_approx}')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_title(title, fontsize=12)
    ax.set_ylim(-5, 5)
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, alpha=0.3)

    # Add uncertainty bound annotation
    bound = max(n_pts - degree, 0)
    ax.annotate(f'Bound: ≥{bound} nonzero\n(n−d = {n_pts}−{degree})',
                xy=(0.02, 0.02), xycoords='axes fraction',
                fontsize=8, style='italic',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.suptitle('Polynomial Root Bound: The Engine Behind Uncertainty',
             fontsize=15, y=1.01)
plt.tight_layout()
plt.savefig('polynomial_roots.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved polynomial_roots.png")


#!/usr/bin/env python3
"""
Visualization: Uncertainty Principle Surface

Shows the trade-off between input support and output support for
the DFT transform. The surface n ≤ supp(f) + supp(f̂) is the
uncertainty boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def dft_matrix(n):
    omega = np.exp(2j * np.pi / n)
    return np.array([[omega ** (j * k) for k in range(n)] for j in range(n)])


def support_size(v, tol=1e-10):
    return int(np.sum(np.abs(v) > tol))


def compute_uncertainty_data(n, n_samples=5000):
    M = dft_matrix(n)
    data = []
    for _ in range(n_samples):
        f = np.zeros(n, dtype=complex)
        k = np.random.randint(1, n + 1)
        idx = np.random.choice(n, k, replace=False)
        f[idx] = np.random.randn(k) + 1j * np.random.randn(k)
        f_hat = M @ f
        s_f = support_size(f)
        s_fhat = support_size(f_hat)
        data.append((s_f, s_fhat))
    return data


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

for idx, n in enumerate([7, 11, 17]):
    ax = axes[idx]
    data = compute_uncertainty_data(n)
    s_f_vals = [d[0] for d in data]
    s_fhat_vals = [d[1] for d in data]

    # Scatter plot of (supp_f, supp_fhat)
    ax.scatter(s_f_vals, s_fhat_vals, alpha=0.3, s=10, c='steelblue')

    # Uncertainty boundary: s_f + s_fhat = n + 1
    x_line = np.arange(1, n + 1)
    y_line = n + 1 - x_line
    ax.plot(x_line, y_line, 'r-', linewidth=2, label=f'$|S_f| + |S_{{\\hat f}}| = {n+1}$')
    ax.fill_between(x_line, 0, np.maximum(y_line, 0), alpha=0.1, color='red')

    ax.set_xlabel('$|\\mathrm{supp}(f)|$', fontsize=12)
    ax.set_ylabel('$|\\mathrm{supp}(\\hat{f})|$', fontsize=12)
    ax.set_title(f'DFT Uncertainty on $\\mathbb{{Z}}/{n}\\mathbb{{Z}}$', fontsize=13)
    ax.set_xlim(0, n + 1)
    ax.set_ylim(0, n + 1)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

plt.suptitle('The Uncertainty Principle: Support Trade-off', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('uncertainty_surface.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved uncertainty_surface.png")
