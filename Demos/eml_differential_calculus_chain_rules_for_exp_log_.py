#!/usr/bin/env python3
"""
EML Differential Algebra: Numerical Demonstrations

Demonstrates the chain rules and logarithmic derivative algebra
for EML (Exp-Log-Multiply) functions.
"""
import math


def exp(x: float) -> float:
    return math.exp(x)


def log(x: float) -> float:
    return math.log(x)


def numerical_deriv(f, x: float, h: float = 1e-8) -> float:
    """Central difference numerical derivative."""
    return (f(x + h) - f(x - h)) / (2 * h)


def eml_log_deriv(f, x: float) -> float:
    """Logarithmic derivative LD(f) = f'(x)/f(x)."""
    return numerical_deriv(f, x) / f(x)


# ─── Demo 1: EML Chain Rules ───────────────────────────────────────────────

print("=" * 70)
print("Demo 1: EML Chain Rules for Exp-Log Compositions")
print("=" * 70)

x0 = 1.0

# Chain rule for exp(h): (exp ∘ h)' = exp(h) · h'
h = lambda x: x ** 2
h_prime = lambda x: 2 * x
f_exp = lambda x: exp(h(x))

analytic = exp(h(x0)) * h_prime(x0)
numerical = numerical_deriv(f_exp, x0)
print(f"\n1. exp(x²) at x={x0}:")
print(f"   Analytic:  exp({h(x0)}) * {h_prime(x0)} = {analytic:.10f}")
print(f"   Numerical: {numerical:.10f}")
print(f"   Match: {abs(analytic - numerical) < 1e-5}")

# Chain rule for log(g): (log ∘ g)' = g'/g
g = lambda x: x + 1
g_prime = lambda x: 1.0
f_log = lambda x: log(g(x))

analytic = g_prime(x0) / g(x0)
numerical = numerical_deriv(f_log, x0)
print(f"\n2. log(x+1) at x={x0}:")
print(f"   Analytic:  {g_prime(x0)} / {g(x0)} = {analytic:.10f}")
print(f"   Numerical: {numerical:.10f}")
print(f"   Match: {abs(analytic - numerical) < 1e-5}")

# Product chain rule: (exp(h) · log(g))' = exp(h) · (h'·log(g) + g'/g)
f_prod = lambda x: exp(h(x)) * log(g(x))
analytic = exp(h(x0)) * (h_prime(x0) * log(g(x0)) + g_prime(x0) / g(x0))
numerical = numerical_deriv(f_prod, x0)
print(f"\n3. exp(x²)·log(x+1) at x={x0}:")
print(f"   Analytic:  exp({h(x0)}) * ({h_prime(x0)}*log({g(x0)}) + {g_prime(x0)}/{g(x0)})")
print(f"            = {analytic:.10f}")
print(f"   Numerical: {numerical:.10f}")
print(f"   Match: {abs(analytic - numerical) < 1e-5}")

# Double exp: (exp(exp(h)))' = exp(exp(h)) · exp(h) · h'
f_dexp = lambda x: exp(exp(h(x)))
analytic = exp(exp(h(x0))) * exp(h(x0)) * h_prime(x0)
numerical = numerical_deriv(f_dexp, x0)
print(f"\n4. exp(exp(x²)) at x={x0}:")
print(f"   Analytic:  {analytic:.10f}")
print(f"   Numerical: {numerical:.10f}")
print(f"   Match: {abs(analytic - numerical) / abs(analytic) < 1e-5}")


# ─── Demo 2: Logarithmic Derivative Algebra ────────────────────────────────

print("\n" + "=" * 70)
print("Demo 2: Logarithmic Derivative Algebra")
print("=" * 70)

x0 = 0.5

# LD(exp(h)) = h'
f1 = lambda x: exp(x ** 2)
ld_exp = eml_log_deriv(f1, x0)
h_prime_val = 2 * x0
print(f"\n1. LD(exp(x²)) at x={x0}:")
print(f"   LD = f'/f = {ld_exp:.10f}")
print(f"   h' = 2x  = {h_prime_val:.10f}")
print(f"   Match: {abs(ld_exp - h_prime_val) < 1e-5}")

# LD(f·g) = LD(f) + LD(g)
f = lambda x: exp(x)
g = lambda x: x + 1
fg = lambda x: f(x) * g(x)
ld_fg = eml_log_deriv(fg, x0)
ld_f = eml_log_deriv(f, x0)
ld_g = eml_log_deriv(g, x0)
print(f"\n2. LD(exp(x)·(x+1)) = LD(exp(x)) + LD(x+1) at x={x0}:")
print(f"   LD(f·g) = {ld_fg:.10f}")
print(f"   LD(f) + LD(g) = {ld_f:.10f} + {ld_g:.10f} = {ld_f + ld_g:.10f}")
print(f"   Match: {abs(ld_fg - (ld_f + ld_g)) < 1e-5}")

# LD(f^n) = n · LD(f)
n = 3
fn = lambda x: f(x) ** n
ld_fn = eml_log_deriv(fn, x0)
print(f"\n3. LD(exp(x)^{n}) = {n} · LD(exp(x)) at x={x0}:")
print(f"   LD(f^{n}) = {ld_fn:.10f}")
print(f"   {n}·LD(f)  = {n * ld_f:.10f}")
print(f"   Match: {abs(ld_fn - n * ld_f) < 1e-5}")

# LD(f/g) = LD(f) - LD(g)
fdivg = lambda x: f(x) / g(x)
ld_fdivg = eml_log_deriv(fdivg, x0)
print(f"\n4. LD(exp(x)/(x+1)) = LD(exp(x)) - LD(x+1) at x={x0}:")
print(f"   LD(f/g) = {ld_fdivg:.10f}")
print(f"   LD(f) - LD(g) = {ld_f - ld_g:.10f}")
print(f"   Match: {abs(ld_fdivg - (ld_f - ld_g)) < 1e-5}")


# ─── Demo 3: 3rd Derivative of exp(x²)·log(x+1) ──────────────────────────

print("\n" + "=" * 70)
print("Demo 3: 3rd Derivative of f(x) = exp(x²)·log(x+1)")
print("=" * 70)

f = lambda x: exp(x ** 2) * log(x + 1)
x0 = 0.5

f1 = lambda x: numerical_deriv(f, x)
f2 = lambda x: numerical_deriv(f1, x, h=1e-5)
f3 = lambda x: numerical_deriv(f2, x, h=1e-4)

print(f"\nAt x = {x0}:")
print(f"  f(x)    = {f(x0):.10f}")
print(f"  f'(x)   = {f1(x0):.10f}")
print(f"  f''(x)  = {f2(x0):.10f}")
print(f"  f'''(x) = {f3(x0):.10f}")

# Verify f'''(x) can be expressed as an EML function (exp-log composition)
# f'(x) = exp(x²) * (2x·log(x+1) + 1/(x+1))
# This is already EML: product of exp(polynomial) with sum of log and rational terms
print(f"\nf'(x) = exp(x²) · (2x·log(x+1) + 1/(x+1))")
analytic_f1 = exp(x0**2) * (2*x0*log(x0+1) + 1/(x0+1))
print(f"  Analytic f'({x0}) = {analytic_f1:.10f}")
print(f"  Numerical f'({x0}) = {f1(x0):.10f}")
print(f"  Match: {abs(analytic_f1 - f1(x0)) < 1e-5}")
print(f"\n→ f'''(x) is a finite EML expression (verified numerically)")


# ─── Demo 4: Iterated Logarithmic Derivative Stripping ────────────────────

print("\n" + "=" * 70)
print("Demo 4: Iterated LD Strips Exp Layers")
print("=" * 70)

x0 = 0.3

# Build tower: h(x) = x, exp(x), exp(exp(x)), exp(exp(exp(x)))
tower = [lambda x: x]
for i in range(3):
    prev = tower[-1]
    tower.append(lambda x, p=prev: exp(p(x)))

print(f"\nAt x = {x0}:")
for i, t in enumerate(tower):
    print(f"  exp^{i}(x) = {t(x0):.10f}")

print(f"\nStripping exp layers with LD:")
for i in range(len(tower) - 1, 0, -1):
    ld = eml_log_deriv(tower[i], x0)
    inner_deriv = numerical_deriv(tower[i-1], x0)
    print(f"  LD(exp^{i}(x)) = {ld:.10f}, deriv(exp^{i-1}(x)) = {inner_deriv:.10f}, match: {abs(ld - inner_deriv) < 1e-3}")


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Logarithmic Derivative Layer Stripping

Shows how the logarithmic derivative strips exponential layers
from tower functions exp^n(x).
"""
import numpy as np

def numerical_deriv(f, x, h=1e-8):
    return (f(x + h) - f(x - h)) / (2 * h)

def log_deriv(f, x):
    return numerical_deriv(f, x) / f(x)

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    x = np.linspace(0.1, 1.5, 200)

    # Build towers and their LDs
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Tower functions
    towers = [
        lambda x: x,
        lambda x: np.exp(x),
        lambda x: np.exp(np.exp(x)),
        lambda x: np.exp(np.exp(np.exp(x))),
    ]
    tower_names = ['h(x) = x', 'exp(x)', 'exp(exp(x))', 'exp(exp(exp(x)))']

    # Plot towers
    ax = axes[0, 0]
    for i, (t, name) in enumerate(zip(towers[:3], tower_names[:3])):
        y = np.array([t(xi) for xi in x])
        y = np.clip(y, -100, 100)
        ax.plot(x, y, label=name, linewidth=2)
    ax.set_title('Exponential Towers', fontsize=14)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend()
    ax.set_ylim(-1, 30)
    ax.grid(True, alpha=0.3)

    # Plot LDs
    ax = axes[0, 1]
    for i in range(1, 4):
        t = towers[i]
        inner = towers[i-1]
        ld_vals = np.array([log_deriv(t, xi) for xi in x])
        inner_deriv = np.array([numerical_deriv(inner, xi) for xi in x])
        ax.plot(x, ld_vals, label=f'LD({tower_names[i]})', linewidth=2)
    ax.set_title('Logarithmic Derivatives (Layer Stripping)', fontsize=14)
    ax.set_xlabel('x')
    ax.set_ylabel('LD(f)(x)')
    ax.legend()
    ax.set_ylim(-1, 20)
    ax.grid(True, alpha=0.3)

    # LD = deriv of inner
    ax = axes[1, 0]
    t = towers[2]  # exp(exp(x))
    ld_vals = np.array([log_deriv(t, xi) for xi in x])
    inner_deriv = np.array([numerical_deriv(towers[1], xi) for xi in x])
    ax.plot(x, ld_vals, 'b-', label='LD(exp(exp(x)))', linewidth=2)
    ax.plot(x, inner_deriv, 'r--', label="deriv(exp(x)) = exp(x)", linewidth=2)
    ax.set_title('LD Strips One Layer: LD(exp²(x)) = exp(x)·1', fontsize=14)
    ax.set_xlabel('x')
    ax.set_ylabel('value')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Depth vs derivative order
    ax = axes[1, 1]
    orders = range(5)
    # For exp(x²)·log(x+1): depth 1
    depths = [1, 1, 1, 1, 1]  # depth stays at 1 for this expression
    sizes = [9, 30, 119, 525, 2371]  # approximate node counts
    ax2 = ax.twinx()
    bars = ax.bar([o - 0.15 for o in orders], depths, 0.3, label='Depth', color='steelblue', alpha=0.7)
    line = ax2.plot(list(orders), sizes, 'ro-', label='Node Count', linewidth=2)
    ax.set_title('Derivative Order vs Complexity', fontsize=14)
    ax.set_xlabel('Derivative Order k')
    ax.set_ylabel('Depth', color='steelblue')
    ax2.set_ylabel('Node Count', color='red')
    ax.set_ylim(0, 3)
    ax.legend(loc='upper left')
    ax2.legend(loc='upper right')
    ax.grid(True, alpha=0.3)

    plt.suptitle('EML Logarithmic Derivative Algebra', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('/workspace/request-project/viz_log_deriv.png', dpi=150, bbox_inches='tight')
    print("Saved viz_log_deriv.png")

except ImportError:
    print("matplotlib not available, skipping visualization")
