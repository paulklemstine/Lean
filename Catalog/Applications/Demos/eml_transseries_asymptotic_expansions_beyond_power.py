"""
Transseries Demo: Asymptotic Expansions Beyond Power Series

Demonstrates the key concepts of dominance hierarchies in transseries:
- Iterated exponentials and their explosive growth
- The dominance chain theorem
- Exponential sum comparison
- EML as a two-level transseries
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def iter_exp(n: int, x: float) -> float:
    """Compute the n-fold iterated exponential: exp^(n)(x)."""
    result = x
    for _ in range(n):
        result = np.exp(np.clip(result, -500, 500))  # clip to avoid overflow
    return result


def iter_log(n: int, x: float) -> float:
    """Compute the n-fold iterated logarithm: log^(n)(x)."""
    result = x
    for _ in range(n):
        if result <= 0:
            return float('-inf')
        result = np.log(result)
    return result


def eml(x: float, y: float) -> float:
    """The EML operation: exp(x) - log(y)."""
    return np.exp(x) - np.log(y)


def exponential_growth_rate(f, x_range: np.ndarray) -> np.ndarray:
    """Estimate the exponential growth rate: log(f(x))/x."""
    values = np.array([f(x) for x in x_range])
    with np.errstate(divide='ignore', invalid='ignore'):
        rates = np.log(np.abs(values)) / x_range
    return rates


# ============================================================
# Demo 1: The Dominance Chain
# ============================================================
print("=" * 60)
print("DEMO 1: The Dominance Chain Theorem")
print("=" * 60)
print("\niterExp(n+1)(x) / iterExp(n)(x) → ∞ as x → ∞")
print("\nFor x = 3:")
for n in range(4):
    val_n = iter_exp(n, 3.0)
    val_n1 = iter_exp(n + 1, 3.0)
    if val_n > 0:
        ratio = val_n1 / val_n
        print(f"  iterExp({n+1})(3) / iterExp({n})(3) = "
              f"{val_n1:.4e} / {val_n:.4e} = {ratio:.4e}")
    else:
        print(f"  iterExp({n+1})(3) / iterExp({n})(3): overflow")

# ============================================================
# Demo 2: Exponential Sum Comparison
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Exponential Sum Comparison Theorem")
print("=" * 60)
print("\nIf Σ cᵢ exp(bᵢ x) = Σ dᵢ exp(bᵢ x) for all x, then c = d")

b = np.array([1.0, 2.0, 3.0])
c1 = np.array([0.5, -1.0, 2.0])
c2 = np.array([0.5, -1.0, 2.0])
c3 = np.array([0.5, -1.0, 2.1])  # different

x_test = np.linspace(0, 2, 100)
sum1 = sum(c1[i] * np.exp(b[i] * x_test) for i in range(3))
sum2 = sum(c2[i] * np.exp(b[i] * x_test) for i in range(3))
sum3 = sum(c3[i] * np.exp(b[i] * x_test) for i in range(3))

print(f"\nb = {b}")
print(f"c₁ = {c1}")
print(f"c₂ = {c2} (same as c₁)")
print(f"c₃ = {c3} (differs in last component)")
print(f"\nmax |Σ c₁ exp(bx) - Σ c₂ exp(bx)| = {np.max(np.abs(sum1 - sum2)):.2e}")
print(f"max |Σ c₁ exp(bx) - Σ c₃ exp(bx)| = {np.max(np.abs(sum1 - sum3)):.2e}")

# ============================================================
# Demo 3: EML Two-Level Transseries
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: EML as a Two-Level Transseries")
print("=" * 60)
print("\neml(x, y) = exp(x) - log(y)")
print("Leading term: exp(x) (level 1)")
print("Correction: -log(y) (level -1)")

y_val = 2.0
for x_val in [1.0, 5.0, 10.0, 20.0]:
    eml_val = eml(x_val, y_val)
    exp_val = np.exp(x_val)
    ratio = eml_val / exp_val
    print(f"  x={x_val:5.1f}: eml/exp = {ratio:.8f}, "
          f"correction = {eml_val - exp_val:.4f} "
          f"(-log(y) = {-np.log(y_val):.4f})")

# ============================================================
# Demo 4: Growth Rate Valuation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Exponential Growth Rate as Valuation")
print("=" * 60)
print("\nv(exp(c·x)) = c")

x_vals = np.linspace(10, 100, 50)
for c in [-1.0, 0.5, 1.0, 2.0]:
    rates = np.log(np.abs(np.exp(c * x_vals))) / x_vals
    avg_rate = np.mean(rates[-10:])
    print(f"  v(exp({c:4.1f}·x)) ≈ {avg_rate:.4f} (exact: {c:.4f})")

print(f"\nv(x^n) = 0 for polynomial growth:")
for n in [1, 2, 5, 10]:
    rates = np.log(x_vals ** n) / x_vals
    avg_rate = np.mean(rates[-10:])
    print(f"  v(x^{n:2d}) ≈ {avg_rate:.6f} → 0")

# ============================================================
# Demo 5: Dominance Filtration
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Dominance Filtration Levels")
print("=" * 60)
x = 10.0
print(f"\nGrowth hierarchy at x = {x}:")
print(f"  Level -2: log(log(x)) = {iter_log(2, x):.4f}")
print(f"  Level -1: log(x)      = {iter_log(1, x):.4f}")
print(f"  Level  0: x            = {x:.4f}")
print(f"  Level  1: exp(x)      = {iter_exp(1, x):.4e}")
print(f"  Level  2: exp(exp(x)) = {iter_exp(2, x):.4e}")
print("\nEach level dwarfs all lower levels!")

print("\n" + "=" * 60)
print("All demos completed successfully.")
print("=" * 60)


"""
Visualization: The Dominance Chain of Iterated Exponentials

Shows how each level of iterated exponential dwarfs the previous one,
creating the fundamental hierarchy of transseries.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def iter_exp(n: int, x: np.ndarray) -> np.ndarray:
    result = x.copy()
    for _ in range(n):
        result = np.exp(np.clip(result, -500, 500))
    return result


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Growth of iterated exponentials (log scale)
ax = axes[0]
x = np.linspace(0.5, 4, 200)
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
labels = ['x', 'exp(x)', 'exp(exp(x))', 'exp³(x)', 'exp⁴(x)']

for n in range(5):
    y = iter_exp(n, x)
    y_clipped = np.clip(y, 1e-10, 1e300)
    ax.semilogy(x, y_clipped, color=colors[n], linewidth=2, label=labels[n])

ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Value (log scale)', fontsize=12)
ax.set_title('The Dominance Chain', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.set_ylim(1e-1, 1e300)
ax.grid(True, alpha=0.3)

# Panel 2: Dominance ratios
ax = axes[1]
x = np.linspace(1, 5, 200)
for n in range(3):
    y_n = iter_exp(n, x)
    y_n1 = iter_exp(n + 1, x)
    ratio = np.clip(y_n1 / y_n, 0, 1e15)
    ax.semilogy(x, ratio, color=colors[n+1], linewidth=2,
                label=f'exp^({n+1})/exp^({n})')

ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Ratio (log scale)', fontsize=12)
ax.set_title('Dominance Ratios → ∞', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: The full hierarchy including logarithms
ax = axes[2]
x = np.linspace(2, 50, 200)

# Logarithmic levels
y_loglog = np.log(np.log(x))
y_log = np.log(x)
# Polynomial
y_x = x
y_x2 = x**2
# Exponential (shown as log)
y_exp_log = x  # log(exp(x)) = x

ax.plot(x, y_loglog, '--', color=colors[4], linewidth=2, label='log(log(x))')
ax.plot(x, y_log, '--', color=colors[3], linewidth=2, label='log(x)')
ax.plot(x, y_x, '-', color=colors[0], linewidth=2, label='x')
ax.plot(x, y_x2, '-', color=colors[1], linewidth=2, label='x²')
ax.plot(x, np.exp(x/10), '-', color=colors[2], linewidth=2, label='exp(x/10)')

ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Growth Level Hierarchy', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.set_ylim(0, 100)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('dominance_chain.png', dpi=150, bbox_inches='tight')
print("Saved dominance_chain.png")
plt.close()
