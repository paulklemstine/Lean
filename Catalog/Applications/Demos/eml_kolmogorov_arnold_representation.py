#!/usr/bin/env python3
"""
EML-KA (Exp-Log Kolmogorov-Arnold) Decomposition Demo
=====================================================

Demonstrates the core results from the EML-KA algebra theory:
1. Monomial decomposition via log-encoding
2. Polynomial approximation
3. Log-sum-exp bounds
4. AM-GM through EML encoding
5. Fenchel-Young duality
"""

import numpy as np

def eml_encode(x: float) -> float:
    """EML encoding: log(x) for x > 0."""
    return np.log(x)

def eml_decode(u: float) -> float:
    """EML decoding: exp(u)."""
    return np.exp(u)

def monomial_emlka(x: float, y: float, a: int, b: int) -> float:
    """
    1-term EML-KA decomposition for x^a * y^b.
    Uses: exp(a*log(x) + b*log(y))
    """
    return np.exp(a * np.log(x) + b * np.log(y))

def polynomial_emlka(x: float, y: float, 
                     coeffs: list, exps_a: list, exps_b: list) -> float:
    """
    M-term EML-KA decomposition for a polynomial.
    Each monomial c_i * x^a_i * y^b_i gets one EML-KA term.
    """
    return sum(c * np.exp(a * np.log(x) + b * np.log(y))
               for c, a, b in zip(coeffs, exps_a, exps_b))

def log_sum_exp(x: float, y: float) -> float:
    """Log-sum-exp: log(exp(x) + exp(y))."""
    m = max(x, y)
    return m + np.log(np.exp(x - m) + np.exp(y - m))

def geometric_mean_eml(x: float, y: float) -> float:
    """Geometric mean via EML encoding: exp((log(x) + log(y))/2)."""
    return np.exp((np.log(x) + np.log(y)) / 2)

def fenchel_young_gap(x: float, s: float) -> float:
    """Fenchel-Young gap: exp(x) + s*log(s) - s - x*s ≥ 0."""
    return np.exp(x) + s * np.log(s) - s - x * s

print("=" * 60)
print("EML-KA Decomposition Demo")
print("=" * 60)

# Demo 1: Monomial decomposition
print("\n--- Demo 1: Monomial EML-KA Decomposition ---")
for x, y in [(2.0, 3.0), (1.5, 2.5), (0.5, 4.0)]:
    for a, b in [(1, 1), (2, 1), (1, 2), (2, 2)]:
        direct = x**a * y**b
        emlka = monomial_emlka(x, y, a, b)
        print(f"  x={x}, y={y}, a={a}, b={b}: "
              f"direct={direct:.6f}, EML-KA={emlka:.6f}, "
              f"error={abs(direct-emlka):.2e}")

# Demo 2: Polynomial decomposition
print("\n--- Demo 2: Polynomial EML-KA ---")
# f(x,y) = 3x²y + 2xy² + x + y (on positive reals)
coeffs = [3, 2, 1, 1]
exps_a = [2, 1, 1, 0]
exps_b = [1, 2, 0, 1]
for x, y in [(1.0, 1.0), (2.0, 3.0), (0.5, 1.5)]:
    direct = 3*x**2*y + 2*x*y**2 + x + y
    emlka = polynomial_emlka(x, y, coeffs, exps_a, exps_b)
    print(f"  x={x}, y={y}: direct={direct:.6f}, EML-KA={emlka:.6f}, "
          f"error={abs(direct-emlka):.2e}")

# Demo 3: Log-sum-exp bounds
print("\n--- Demo 3: Log-Sum-Exp Bounds ---")
for x, y in [(1.0, 2.0), (5.0, 3.0), (-1.0, 1.0)]:
    lse = log_sum_exp(x, y)
    m = max(x, y)
    print(f"  x={x}, y={y}: max={m:.4f} ≤ LSE={lse:.4f} ≤ max+log2={m+np.log(2):.4f}")

# Demo 4: LSE in log-space = log of addition
print("\n--- Demo 4: LSE(log x, log y) = log(x+y) ---")
for x, y in [(2.0, 3.0), (1.0, 1.0), (0.5, 1.5)]:
    lse_log = log_sum_exp(np.log(x), np.log(y))
    log_add = np.log(x + y)
    print(f"  x={x}, y={y}: LSE(log x, log y)={lse_log:.6f}, "
          f"log(x+y)={log_add:.6f}, error={abs(lse_log-log_add):.2e}")

# Demo 5: AM-GM via EML
print("\n--- Demo 5: AM-GM via EML encoding ---")
for x, y in [(1.0, 4.0), (2.0, 8.0), (3.0, 3.0)]:
    gm = geometric_mean_eml(x, y)
    am = (x + y) / 2
    print(f"  x={x}, y={y}: GM(EML)={gm:.6f} ≤ AM={am:.6f}, "
          f"gap={am-gm:.6f}")

# Demo 6: Fenchel-Young duality
print("\n--- Demo 6: Fenchel-Young Gap (≥ 0) ---")
for x in [-1.0, 0.0, 1.0, 2.0]:
    for s in [0.5, 1.0, 2.0, 3.0]:
        gap = fenchel_young_gap(x, s)
        print(f"  x={x}, s={s}: gap={gap:.6f} {'✓' if gap >= -1e-10 else '✗'}")

# Demo 7: Log-linearization
print("\n--- Demo 7: Logarithmic Linearization ---")
print("  Monomial x^a * y^b in log-space becomes a*u + b*v:")
for x, y in [(2.0, 3.0)]:
    u, v = np.log(x), np.log(y)
    for a, b in [(1, 1), (2, 1), (3, 2)]:
        log_monomial = np.log(x**a * y**b)
        linear = a * u + b * v
        print(f"    a={a}, b={b}: log(x^a*y^b)={log_monomial:.6f}, "
              f"a*log(x)+b*log(y)={linear:.6f}")

print("\n" + "=" * 60)
print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualization: EML-KA Decomposition Landscape
Shows how the log-encoding linearizes monomials and how
EML-KA decompositions approximate functions.
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def plot_linearization():
    """Plot the log-linearization of monomials."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))

    x = np.linspace(0.1, 3, 100)
    y = np.linspace(0.1, 3, 100)
    X, Y = np.meshgrid(x, y)
    U, V = np.log(X), np.log(Y)

    monomials = [(1, 1, 'xy'), (2, 1, 'x²y'), (1, 2, 'xy²'),
                 (2, 2, 'x²y²'), (3, 1, 'x³y'), (1, 3, 'xy³')]

    for idx, (a, b, label) in enumerate(monomials):
        ax = axes[idx // 3, idx % 3]
        Z = a * U + b * V  # Linear in log-space!
        c = ax.contourf(U, V, Z, levels=20, cmap='viridis')
        ax.set_title(f'log({label}) = {a}u + {b}v', fontsize=12)
        ax.set_xlabel('u = log(x)')
        ax.set_ylabel('v = log(y)')
        plt.colorbar(c, ax=ax)

    fig.suptitle('Logarithmic Linearization: Monomials become linear in log-space',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_linearization.png', dpi=150, bbox_inches='tight')
    plt.close()

def plot_lse_bounds():
    """Plot log-sum-exp bounds."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    x = np.linspace(-3, 3, 200)
    y_fixed = 0.0

    lse = np.log(np.exp(x) + np.exp(y_fixed))
    max_vals = np.maximum(x, y_fixed)
    max_log2 = max_vals + np.log(2)

    ax1.fill_between(x, max_vals, max_log2, alpha=0.2, color='blue',
                     label='Approximation band')
    ax1.plot(x, lse, 'r-', linewidth=2, label='LSE(x, 0)')
    ax1.plot(x, max_vals, 'b--', linewidth=1.5, label='max(x, 0)')
    ax1.plot(x, max_log2, 'g--', linewidth=1.5, label='max(x, 0) + log 2')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Log-Sum-Exp Bounds (y = 0)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # LSE as smooth max in 2D
    x2 = np.linspace(-2, 2, 100)
    y2 = np.linspace(-2, 2, 100)
    X2, Y2 = np.meshgrid(x2, y2)
    LSE2 = np.log(np.exp(X2) + np.exp(Y2))
    MAX2 = np.maximum(X2, Y2)

    c = ax2.contourf(X2, Y2, LSE2 - MAX2, levels=20, cmap='coolwarm')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('y', fontsize=12)
    ax2.set_title('LSE(x,y) - max(x,y) ∈ [0, log 2]', fontsize=13)
    plt.colorbar(c, ax=ax2)

    fig.suptitle('Log-Sum-Exp: A Smooth Maximum via EML',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_lse_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()

def plot_amgm():
    """Plot AM-GM via EML encoding."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    x = np.linspace(0.1, 5, 200)
    y = np.linspace(0.1, 5, 200)
    X, Y = np.meshgrid(x, y)

    GM = np.exp((np.log(X) + np.log(Y)) / 2)  # Geometric mean via EML
    AM = (X + Y) / 2  # Arithmetic mean
    GAP = AM - GM

    c1 = ax1.contourf(X, Y, GAP, levels=20, cmap='YlOrRd')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('y', fontsize=12)
    ax1.set_title('AM(x,y) - GM(x,y) ≥ 0', fontsize=13)
    ax1.plot([0.1, 5], [0.1, 5], 'k--', linewidth=1, label='x = y (gap = 0)')
    ax1.legend()
    plt.colorbar(c1, ax=ax1)

    # 1D slice
    t = np.linspace(0.1, 5, 200)
    y_val = 1.0
    gm_slice = np.exp((np.log(t) + np.log(y_val)) / 2)
    am_slice = (t + y_val) / 2

    ax2.plot(t, am_slice, 'b-', linewidth=2, label='AM = (x+1)/2')
    ax2.plot(t, gm_slice, 'r-', linewidth=2, label='GM = exp((log x + log 1)/2)')
    ax2.fill_between(t, gm_slice, am_slice, alpha=0.2, color='green')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Mean value', fontsize=12)
    ax2.set_title('AM ≥ GM (y = 1 slice)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('AM-GM Inequality Through EML Encoding/Decoding',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_amgm.png', dpi=150, bbox_inches='tight')
    plt.close()

if __name__ == '__main__':
    plot_linearization()
    plot_lse_bounds()
    plot_amgm()
    print("Visualizations saved: viz_linearization.png, viz_lse_bounds.png, viz_amgm.png")
