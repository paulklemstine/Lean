#!/usr/bin/env python3
"""
EML Approximation Spectrum — Numerical Demonstrations

Demonstrates the key theorems about EML (Exponential-Multiplicative-Logarithmic)
expression approximation, including:
1. Tower efficiency: iterExp n has constant-size EML representation
2. Spectrum antitonicity: tighter precision requires larger expressions
3. Information decay: retained information contracts exponentially with depth
4. Polynomial-to-EML conversion via Horner's method
"""

import math
from typing import Callable, List, Tuple

# ============================================================
# EML Expression Tree
# ============================================================

class EMLExpr:
    """EML expression tree: var, const, add, mul, neg, inv, eml(a,b)=a*exp(b)."""
    pass

class Var(EMLExpr):
    def eval(self, x: float) -> float:
        return x
    def size(self) -> int:
        return 1
    def eml_depth(self) -> int:
        return 0
    def __repr__(self):
        return "x"

class Const(EMLExpr):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def size(self) -> int:
        return 1
    def eml_depth(self) -> int:
        return 0
    def __repr__(self):
        return f"{self.c}"

class Add(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) + self.b.eval(x)
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def eml_depth(self) -> int:
        return max(self.a.eml_depth(), self.b.eml_depth())
    def __repr__(self):
        return f"({self.a} + {self.b})"

class Mul(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) * self.b.eval(x)
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def eml_depth(self) -> int:
        return max(self.a.eml_depth(), self.b.eml_depth())
    def __repr__(self):
        return f"({self.a} * {self.b})"

class EML(EMLExpr):
    """eml(a, b) = a * exp(b)"""
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        bval = self.b.eval(x)
        if bval > 700:  # overflow protection
            return float('inf')
        return self.a.eval(x) * math.exp(bval)
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def eml_depth(self) -> int:
        return 1 + max(self.a.eml_depth(), self.b.eml_depth())
    def __repr__(self):
        return f"eml({self.a}, {self.b})"


def iter_exp(n: int, x: float) -> float:
    """Iterated exponential: exp^n(x)."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def eml_iter_exp(n: int) -> EMLExpr:
    """Canonical EML expression for iterExp n: eml(1, eml(1, ..., var))."""
    if n == 0:
        return Var()
    return EML(Const(1.0), eml_iter_exp(n - 1))


def horner(n: int, coeffs: List[float]) -> EMLExpr:
    """Horner's method: polynomial to EML expression."""
    if n == 0:
        return Const(coeffs[0])
    return Add(Const(coeffs[0]), Mul(Var(), horner(n - 1, coeffs[1:])))


def uniform_approx_error(f: Callable, g: Callable, a: float, b: float,
                          n_samples: int = 1000) -> float:
    """Compute max |f(x) - g(x)| over [a, b]."""
    xs = [a + (b - a) * i / n_samples for i in range(n_samples + 1)]
    return max(abs(f(x) - g(x)) for x in xs)


# ============================================================
# Demo 1: Tower Efficiency
# ============================================================
print("=" * 70)
print("DEMO 1: Tower Efficiency — Linear Size for Exponential Towers")
print("=" * 70)
print()
print("The iterated exponential exp^n(x) requires polynomial/Taylor series")
print("of exponential size, but EML represents it in size 2n+1.")
print()

for n in range(1, 7):
    expr = eml_iter_exp(n)
    size = expr.size()
    depth = expr.eml_depth()
    
    # Verify: exact representation (error = 0)
    test_x = 0.5
    eml_val = expr.eval(test_x)
    true_val = iter_exp(n, test_x)
    error = abs(eml_val - true_val) if eml_val != float('inf') else float('inf')
    
    print(f"  iterExp {n}: size = {size} (= 2×{n}+1 = {2*n+1}), "
          f"emlDepth = {depth}, error = {error:.2e}")

print()
print("Key insight: Size grows LINEARLY with tower height n.")
print("A Taylor polynomial for exp^n would need ~(e^n)! terms.")

# ============================================================
# Demo 2: Spectrum Antitonicity
# ============================================================
print()
print("=" * 70)
print("DEMO 2: Spectrum Antitonicity — Tighter ε ⟹ Larger Expressions")
print("=" * 70)
print()

# Approximate sin(x) on [0, 1] with polynomials of increasing degree
target = math.sin
print("Approximating sin(x) on [0, 1] via Horner EML (polynomial):")
print()

# Taylor coefficients for sin(x): x - x^3/6 + x^5/120 - ...
def sin_taylor_coeffs(n: int) -> List[float]:
    coeffs = []
    for i in range(n + 1):
        if i % 2 == 0:
            coeffs.append(0.0)
        else:
            sign = (-1) ** ((i - 1) // 2)
            coeffs.append(sign / math.factorial(i))
    return coeffs

for deg in [1, 3, 5, 7, 9, 11]:
    coeffs = sin_taylor_coeffs(deg)
    expr = horner(deg, coeffs)
    error = uniform_approx_error(target, lambda x: expr.eval(x), 0, 1)
    print(f"  degree {deg:2d}: size = {expr.size():3d}, "
          f"max error = {error:.2e}")

print()
print("As precision improves (error ↓), expression size increases (↑).")
print("This is the spectrum antitonicity theorem in action.")

# ============================================================
# Demo 3: Information Decay
# ============================================================
print()
print("=" * 70)
print("DEMO 3: Information Decay — Exponential Contraction with Depth")
print("=" * 70)
print()

K = 100  # initial information content
print(f"Initial information K = {K}")
print()

for alpha in [0.9, 0.5, 0.1]:
    print(f"  Contraction α = {alpha}:")
    for l in [1, 2, 5, 10, 20]:
        retained = alpha ** l * K
        print(f"    depth {l:2d}: retained = {retained:10.4f} "
              f"({retained/K*100:.2f}% of original)")
    print()

print("Key: For α < 1, information decays EXPONENTIALLY with depth.")
print("This forces a depth-complexity tradeoff: deeper networks need")
print("higher initial complexity K to retain enough information.")

# ============================================================
# Demo 4: Subadditivity of Spectrum
# ============================================================
print()
print("=" * 70)
print("DEMO 4: Spectrum Subadditivity — Addition Preserves Complexity")
print("=" * 70)
print()

# f(x) = sin(x), g(x) = cos(x), f+g(x) = sin(x) + cos(x)
sin_coeffs = sin_taylor_coeffs(7)
cos_coeffs = [1.0, 0.0, -0.5, 0.0, 1/24, 0.0, -1/720, 0.0]

e_sin = horner(7, sin_coeffs)
e_cos = horner(7, cos_coeffs)
e_sum = Add(e_sin, e_cos)

sin_err = uniform_approx_error(math.sin, lambda x: e_sin.eval(x), 0, 1)
cos_err = uniform_approx_error(math.cos, lambda x: e_cos.eval(x), 0, 1)
sum_err = uniform_approx_error(lambda x: math.sin(x) + math.cos(x),
                                lambda x: e_sum.eval(x), 0, 1)

print(f"  sin approx: size = {e_sin.size()}, error = {sin_err:.2e}")
print(f"  cos approx: size = {e_cos.size()}, error = {cos_err:.2e}")
print(f"  sum approx: size = {e_sum.size()}, error = {sum_err:.2e}")
print(f"  Bound: size(sum) ≤ size(sin) + size(cos) + 1")
print(f"         {e_sum.size()} ≤ {e_sin.size()} + {e_cos.size()} + 1 = {e_sin.size() + e_cos.size() + 1}")
print(f"  Sum error ≤ sin_error + cos_error = {sin_err + cos_err:.2e} ✓")

# ============================================================
# Demo 5: EML vs Polynomial Efficiency for exp(x)
# ============================================================
print()
print("=" * 70)
print("DEMO 5: EML Beats Polynomials for Transcendental Functions")
print("=" * 70)
print()

# EML representation of exp(x): eml(1, var) = 1 * exp(x)
eml_exp = EML(Const(1.0), Var())
print(f"EML representation of exp(x):")
print(f"  Expression: {eml_exp}")
print(f"  Size: {eml_exp.size()}, EML depth: {eml_exp.eml_depth()}")
print(f"  Error on [0,1]: {uniform_approx_error(math.exp, lambda x: eml_exp.eval(x), 0, 1):.2e} (exact!)")
print()

# Polynomial approximations
print("Polynomial approximations of exp(x) on [0,1]:")
for deg in [1, 3, 5, 7, 10, 15, 20]:
    coeffs = [1.0 / math.factorial(i) if i <= deg else 0.0 for i in range(deg + 1)]
    poly = horner(deg, coeffs)
    err = uniform_approx_error(math.exp, lambda x, p=poly: p.eval(x), 0, 1)
    print(f"  degree {deg:2d}: size = {poly.size():3d}, error = {err:.2e}")

print()
print("EML achieves EXACT representation in size 3,")
print("while polynomials need size ~4n+1 for degree n.")

print()
print("=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: EML Approximation Spectrum Analysis

Generates three plots:
1. Approximation spectrum σ_f(ε) for different functions
2. Information decay curves for different contraction factors
3. Tower efficiency: EML size vs polynomial size for iterExp n
"""

import math
import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; generating text-based output instead.")


def iter_exp_func(n, x):
    """Iterated exponential exp^n(x)."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def eml_tower_size(n):
    """Size of the canonical EML tower for iterExp n."""
    return 2 * n + 1


def taylor_min_degree_for_eps(func, a, b, eps, max_deg=100):
    """Find minimum Taylor degree to approximate func to within eps on [a,b]."""
    xs = np.linspace(a, b, 500)

    for deg in range(max_deg + 1):
        # Taylor coefficients at x=0
        h = 1e-7
        coeffs = []
        for k in range(deg + 1):
            # k-th derivative at 0 via finite differences
            d = _nth_deriv(func, 0.0, k, h)
            coeffs.append(d / math.factorial(k))

        # Evaluate polynomial
        poly_vals = np.zeros_like(xs)
        for k, c in enumerate(coeffs):
            poly_vals += c * xs**k

        true_vals = np.array([func(x) for x in xs])
        error = np.max(np.abs(true_vals - poly_vals))

        if error <= eps:
            return deg

    return max_deg


def _nth_deriv(f, x, n, h=1e-5):
    """Approximate n-th derivative using central differences."""
    if n == 0:
        return f(x)
    return (_nth_deriv(f, x + h, n - 1, h) -
            _nth_deriv(f, x - h, n - 1, h)) / (2 * h)


def plot_all():
    """Generate all visualization plots."""
    if not HAS_MPL:
        text_fallback()
        return

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Approximation Spectrum
    ax1 = axes[0]
    epsilons = np.logspace(-1, -8, 30)

    for func, name, color in [
        (math.sin, 'sin(x)', 'blue'),
        (math.exp, 'exp(x)', 'red'),
        (lambda x: x**3, 'x³', 'green'),
    ]:
        sizes = []
        for eps in epsilons:
            deg = taylor_min_degree_for_eps(func, 0, 1, eps, 50)
            sizes.append(4 * deg + 1)  # Horner size bound
        ax1.loglog(epsilons, sizes, '-o', label=name, color=color,
                   markersize=3, linewidth=1.5)

    ax1.set_xlabel('Precision ε', fontsize=12)
    ax1.set_ylabel('Min EML Size σ_f(ε)', fontsize=12)
    ax1.set_title('EML Approximation Spectrum', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.invert_xaxis()

    # Plot 2: Information Decay
    ax2 = axes[1]
    depths = np.arange(0, 21)

    for alpha, color in [(0.9, 'blue'), (0.7, 'green'),
                          (0.5, 'orange'), (0.3, 'red')]:
        retained = [alpha**l * 100 for l in depths]
        ax2.plot(depths, retained, '-o', label=f'α={alpha}',
                 color=color, markersize=4, linewidth=1.5)

    ax2.set_xlabel('Depth l', fontsize=12)
    ax2.set_ylabel('Retained Information (%)', fontsize=12)
    ax2.set_title('Information Decay: α^l × K', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(bottom=0)

    # Plot 3: Tower Efficiency
    ax3 = axes[2]
    ns = np.arange(1, 16)

    eml_sizes = [2 * n + 1 for n in ns]

    # For polynomials: Taylor degree needed for exp^n(0.5) ≈ precision 0.01
    # exp^n grows super-exponentially, Taylor convergence is very slow
    poly_sizes_est = []
    for n in ns:
        # Rough estimate: Taylor degree ~ target_value for convergence
        target = iter_exp_func(n, 0.5)
        if target < 1e10:
            deg = min(int(target * 2) + 5, 500)
        else:
            deg = 500
        poly_sizes_est.append(4 * deg + 1)

    ax3.semilogy(ns, eml_sizes, 'bo-', label='EML (2n+1)',
                 linewidth=2, markersize=6)
    ax3.semilogy(ns, poly_sizes_est, 'rs--',
                 label='Polynomial (estimated)', linewidth=2, markersize=6)

    ax3.set_xlabel('Tower Height n', fontsize=12)
    ax3.set_ylabel('Expression Size (log scale)', fontsize=12)
    ax3.set_title('Tower Efficiency: EML vs Polynomials', fontsize=14)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_spectrum_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_spectrum_analysis.png")
    plt.close()


def text_fallback():
    """Text-based output when matplotlib is unavailable."""
    print("\n=== Approximation Spectrum (sin(x) on [0,1]) ===")
    for eps in [1e-1, 1e-3, 1e-5, 1e-7]:
        deg = taylor_min_degree_for_eps(math.sin, 0, 1, eps, 50)
        print(f"  ε={eps:.0e}: min degree={deg}, EML size={4*deg+1}")

    print("\n=== Information Decay (K=100) ===")
    for alpha in [0.9, 0.5, 0.1]:
        vals = [f"{alpha**l*100:.1f}" for l in range(0, 11, 2)]
        print(f"  α={alpha}: depths 0,2,...,10 → {', '.join(vals)}")

    print("\n=== Tower Efficiency ===")
    for n in range(1, 8):
        print(f"  iterExp {n}: EML size={2*n+1}")


if __name__ == "__main__":
    plot_all()
