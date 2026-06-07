#!/usr/bin/env python3
"""
Demo: EML Special Functions — Gamma, Hypergeometric, and Singularity Classification

Numerical demonstrations of the theorems proved in Lean 4.
"""

import math
from typing import List, Tuple

def rising_factorial(a: float, n: int) -> float:
    """Pochhammer symbol (a)_n = a(a+1)...(a+n-1)."""
    result = 1.0
    for k in range(n):
        result *= (a + k)
    return result

def hypergeom_coeff(a: float, b: float, c: float, n: int) -> float:
    """Hypergeometric coefficient c_n = (a)_n(b)_n / ((c)_n * n!)."""
    return rising_factorial(a, n) * rising_factorial(b, n) / (rising_factorial(c, n) * math.factorial(n))

def hypergeom_2f1_partial(a: float, b: float, c: float, z: float, N: int) -> float:
    """Partial sum of 2F1(a,b;c;z) up to N terms."""
    return sum(hypergeom_coeff(a, b, c, n) * z**n for n in range(N))

def eml(x: float, y: float) -> float:
    """EML operator: exp(x) - log(y)."""
    return math.exp(x) - math.log(y)

def eml_diag(z: float) -> float:
    """EML diagonal: exp(z) - log(z)."""
    return math.exp(z) - math.log(z)

# ============================================================
# Demo 1: Log-Gamma decomposition (Theorem 9)
# ============================================================
print("=" * 60)
print("Demo 1: Log-Gamma Decomposition (Theorem 9)")
print("log(n!) = sum_{k=0}^{n-1} log(k+1)")
print("=" * 60)
for n in range(1, 8):
    lhs = math.log(math.factorial(n))
    rhs = sum(math.log(k + 1) for k in range(n))
    print(f"  n={n}: log({n}!) = {lhs:.6f},  sum = {rhs:.6f},  diff = {abs(lhs-rhs):.2e}")

# ============================================================
# Demo 2: Stirling lower bound (Theorem 11)
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Stirling Lower Bound (Theorem 11)")
print("n*log(n) - n + 1 <= log(n!)")
print("=" * 60)
for n in range(1, 12):
    lower = n * math.log(n) - n + 1
    actual = math.log(math.factorial(n))
    gap = actual - lower
    print(f"  n={n:2d}: lower={lower:8.3f}, log(n!)={actual:8.3f}, gap={gap:.3f}")

# ============================================================
# Demo 3: Hypergeometric 2F1 values (Theorems 7, 8)
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Hypergeometric 2F1 Values")
print("=" * 60)
print(f"  2F1(1, 1; 2; 0) = {hypergeom_2f1_partial(1, 1, 2, 0, 50):.6f}  (should be 1)")
print(f"  2F1(0, 3; 2; 0.5) = {hypergeom_2f1_partial(0, 3, 2, 0.5, 50):.6f}  (should be 1)")
print(f"  2F1(1, 1; 2; 0.5) = {hypergeom_2f1_partial(1, 1, 2, 0.5, 50):.6f}  (= -log(1-0.5)/0.5 = {-math.log(0.5)/0.5:.6f})")

# ============================================================
# Demo 4: Hypergeometric ratio convergence (Theorem 23)
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Hypergeometric Ratio Convergence (Theorem 23)")
print("(a+n)(b+n)/((c+n)(n+1)) -> 1")
print("=" * 60)
a, b, c = 2.5, 3.7, 1.2
for n in [1, 5, 10, 50, 100, 1000]:
    ratio = (a + n) * (b + n) / ((c + n) * (n + 1))
    print(f"  n={n:4d}: ratio = {ratio:.8f}")

# ============================================================
# Demo 5: Rising factorial vanishing (Theorem 24)
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Rising Factorial Vanishing at -m (Theorem 24)")
print("risingFactorial(-m, n) = 0 for n > m")
print("=" * 60)
for m in range(4):
    vals = [rising_factorial(-m, n) for n in range(m + 3)]
    print(f"  m={m}: (−{m})_n for n=0..{m+2}: {vals}")

# ============================================================
# Demo 6: Gamma > log for natural numbers (Theorem 26)
# ============================================================
print("\n" + "=" * 60)
print("Demo 6: Gamma(n) > log(n) for n >= 1 (Theorem 26)")
print("=" * 60)
for n in range(1, 10):
    gamma_n = math.gamma(n)
    log_n = math.log(n) if n > 0 else 0
    print(f"  n={n}: Gamma({n}) = {gamma_n:10.4f},  log({n}) = {log_n:.4f},  diff = {gamma_n - log_n:.4f}")

# ============================================================
# Demo 7: EML-Pochhammer connection (Theorem 13)
# ============================================================
print("\n" + "=" * 60)
print("Demo 7: EML recovers Pochhammer factors (Theorem 13)")
print("eml'(log(a+k), 1) = a + k")
print("=" * 60)
a_val = 2.5
for k in range(6):
    target = a_val + k
    eml_val = eml(math.log(target), 1)
    print(f"  a={a_val}, k={k}: eml'(log({target}), 1) = {eml_val:.6f} == {target}")

# ============================================================
# Demo 8: Disproved conjecture — Gamma(x)-log(x) NOT monotone on (1,∞)
# ============================================================
print("\n" + "=" * 60)
print("Demo 8: Disproved Conjecture — f(x) = Gamma(x) - log(x)")
print("f is NOT monotone on (1, ∞): it decreases then increases")
print("=" * 60)
import numpy as np
xs = [1.0, 1.2, 1.5, 1.8, 2.0, 2.2, 2.5, 3.0, 4.0, 5.0]
for x in xs:
    fx = math.gamma(x) - math.log(x)
    print(f"  x={x:.1f}: Gamma({x:.1f}) - log({x:.1f}) = {fx:.6f}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Gamma-EML Bridge and Stirling Bound

Shows the log-gamma decomposition and Stirling lower bound.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def plot_gamma_eml_bridge():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle('Gamma-EML Bridge: Factorials, Stirling, and the Disproved Conjecture', fontsize=13, fontweight='bold')

    # Panel 1: Log-gamma decomposition
    ax = axes[0]
    ns = range(1, 12)
    log_factorials = [math.log(math.factorial(n)) for n in ns]
    cumulative = []
    for n in ns:
        cumulative.append(sum(math.log(k + 1) for k in range(n)))

    ax.bar(list(ns), log_factorials, alpha=0.6, color='#2196F3', label='log(n!)')
    ax.plot(list(ns), cumulative, 'ro-', linewidth=2, markersize=6, label='Σ log(k+1)')
    ax.set_xlabel('n')
    ax.set_ylabel('Value')
    ax.set_title('Log-Gamma = Sum of Logs (Thm 9)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Stirling lower bound
    ax = axes[1]
    ns = range(1, 20)
    actuals = [math.log(math.factorial(n)) for n in ns]
    bounds = [n * math.log(n) - n + 1 for n in ns]
    stirling = [n * math.log(n) - n + 0.5 * math.log(2 * math.pi * n) for n in ns]

    ax.plot(list(ns), actuals, 'b-o', linewidth=2, markersize=4, label='log(n!)')
    ax.plot(list(ns), bounds, 'r--s', linewidth=1.5, markersize=3, label='n·log(n) − n + 1 (lower bound)')
    ax.plot(list(ns), stirling, 'g-.^', linewidth=1.5, markersize=3, label='Stirling approx')
    ax.fill_between(list(ns), bounds, actuals, alpha=0.1, color='blue')
    ax.set_xlabel('n')
    ax.set_ylabel('Value')
    ax.set_title('Stirling Lower Bound (Thm 11)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Disproved conjecture — f(x) = Gamma(x) - log(x)
    ax = axes[2]
    from scipy.special import gamma as gamma_fn
    x = np.linspace(1.01, 5, 500)
    y = gamma_fn(x) - np.log(x)
    ax.plot(x, y, 'purple', linewidth=2, label='Γ(x) − log(x)')

    # Mark the minimum
    min_idx = np.argmin(y)
    x_min, y_min = x[min_idx], y[min_idx]
    ax.plot(x_min, y_min, 'ro', markersize=10, zorder=5, label=f'Minimum at x≈{x_min:.2f}')
    ax.axhline(y=0, color='gray', linewidth=0.5)

    # Mark integer values
    for n in range(1, 6):
        gn = math.gamma(n)
        ln = math.log(n) if n > 0 else 0
        ax.plot(n, gn - ln, 'ks', markersize=6)
        ax.annotate(f'n={n}: {gn-ln:.2f}', xy=(n, gn-ln), xytext=(n+0.1, gn-ln+0.3),
                   fontsize=7)

    ax.set_xlabel('x')
    ax.set_ylabel('Γ(x) − log(x)')
    ax.set_title('Disproved: NOT monotone on (1,∞)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('gamma_eml_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved gamma_eml_bridge.png")

if __name__ == "__main__":
    plot_gamma_eml_bridge()


#!/usr/bin/env python3
"""
Visualization: EML Singularity Spectrum Classification

Shows the Gamma function with its singularity spectrum overlaid.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy.special import gamma as gamma_fn

def plot_singularity_spectrum():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('EML Singularity Spectrum: Gamma, EML, and Classification', fontsize=14, fontweight='bold')

    # Panel 1: Gamma function with poles marked
    ax = axes[0, 0]
    xs = []
    ys = []
    for segment_start, segment_end in [(-4.99, -4.01), (-3.99, -3.01), (-2.99, -2.01),
                                         (-1.99, -1.01), (-0.99, -0.01), (0.01, 5.0)]:
        x = np.linspace(segment_start, segment_end, 200)
        y = gamma_fn(x)
        y = np.clip(y, -10, 10)
        ax.plot(x, y, 'b-', linewidth=1.5)

    # Mark poles
    for n in range(5):
        ax.axvline(x=-n, color='red', linestyle='--', alpha=0.5, linewidth=0.8)
        ax.plot(-n, 0, 'ro', markersize=8, zorder=5)
        ax.annotate(f'pole\norder 1', xy=(-n, 0), xytext=(-n+0.15, 6-n),
                   fontsize=7, color='red', alpha=0.8)

    ax.set_xlim(-5, 5)
    ax.set_ylim(-10, 10)
    ax.set_title('Γ(x): Meromorphic Singularity Spectrum')
    ax.set_xlabel('x')
    ax.set_ylabel('Γ(x)')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.grid(True, alpha=0.3)

    # Panel 2: EML diagonal
    ax = axes[0, 1]
    z = np.linspace(0.01, 4, 500)
    eml_diag = np.exp(z) - np.log(z)
    ax.plot(z, eml_diag, 'g-', linewidth=2, label='emlDiag(z) = eˣ − ln(z)')
    ax.axvline(x=0, color='red', linestyle='--', alpha=0.7, label='log branch point at z=0')
    ax.fill_between(z, eml_diag, alpha=0.1, color='green')
    ax.set_xlim(-0.5, 4)
    ax.set_ylim(0, 20)
    ax.set_title('EML Diagonal: Smooth on (0, ∞)')
    ax.set_xlabel('z')
    ax.set_ylabel('emlDiag(z)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Singularity type hierarchy
    ax = axes[1, 0]
    categories = ['Removable', 'Pole', 'Log Branch', 'Essential']
    meromorphic = [1, 1, 0, 0]
    eml_compat = [1, 1, 1, 0]
    x_pos = np.arange(len(categories))
    width = 0.35
    bars1 = ax.bar(x_pos - width/2, meromorphic, width, label='Meromorphic', color='#2196F3', alpha=0.8)
    bars2 = ax.bar(x_pos + width/2, eml_compat, width, label='EML-Compatible', color='#4CAF50', alpha=0.8)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(categories)
    ax.set_ylabel('Membership (1 = yes)')
    ax.set_title('Singularity Type Hierarchy')
    ax.legend()
    ax.set_ylim(0, 1.3)

    # Panel 4: Hypergeometric ratio convergence
    ax = axes[1, 1]
    a, b, c = 2.5, 3.7, 1.2
    ns = np.arange(1, 101)
    ratios = (a + ns) * (b + ns) / ((c + ns) * (ns + 1))
    ax.plot(ns, ratios, 'purple', linewidth=2, label=f'(a+n)(b+n)/((c+n)(n+1))\na={a}, b={b}, c={c}')
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Limit = 1')
    ax.set_xlabel('n')
    ax.set_ylabel('Ratio')
    ax.set_title('Hypergeometric Ratio → 1 (Theorem 23)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('singularity_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved singularity_spectrum.png")

if __name__ == "__main__":
    plot_singularity_spectrum()
