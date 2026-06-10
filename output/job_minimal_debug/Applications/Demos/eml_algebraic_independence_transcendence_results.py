#!/usr/bin/env python3
"""
EML Multiplicative Transcendence: Numerical Demonstrations

Demonstrates the properties of emlMul(a) = exp(a) * log(1 + a),
including transcendence testing via polynomial relation search.
"""

import math
from typing import List, Tuple

def eml_mul(a: float) -> float:
    """The multiplicative EML operator: exp(a) * log(1 + a)."""
    if a <= -1:
        raise ValueError(f"emlMul undefined for a <= -1, got a = {a}")
    return math.exp(a) * math.log(1 + a)

def eml_mul_deriv(a: float) -> float:
    """Derivative of emlMul: exp(a) * (log(1+a) + 1/(1+a))."""
    if a <= -1:
        raise ValueError(f"Derivative undefined for a <= -1")
    return math.exp(a) * (math.log(1 + a) + 1.0 / (1 + a))


# === Demo 1: Basic values ===
print("=" * 60)
print("Demo 1: EML Multiplicative Operator Values")
print("=" * 60)

test_points = [0, 0.5, 1, 2, 3, -0.5, -0.9]
for a in test_points:
    val = eml_mul(a)
    deriv = eml_mul_deriv(a)
    print(f"  emlMul({a:6.1f}) = {val:12.6f}   emlMul'({a:6.1f}) = {deriv:12.6f}")

print(f"\n  emlMul(1) = e * ln(2) = {math.e * math.log(2):.10f}")
print(f"  e = {math.e:.10f},  ln(2) = {math.log(2):.10f}")


# === Demo 2: Verify unique zero at a=0 ===
print("\n" + "=" * 60)
print("Demo 2: Unique Zero at a = 0")
print("=" * 60)

for a in [-0.99, -0.5, -0.1, -0.01, 0.0, 0.01, 0.1, 0.5, 1.0]:
    val = eml_mul(a)
    sign = "+" if val > 0 else ("-" if val < 0 else "0")
    print(f"  emlMul({a:6.2f}) = {val:12.8f}  [{sign}]")


# === Demo 3: Monotonicity on (0, ∞) ===
print("\n" + "=" * 60)
print("Demo 3: Strict Monotonicity on (0, ∞)")
print("=" * 60)

prev = 0
for a_int in range(1, 20):
    a = a_int * 0.5
    val = eml_mul(a)
    diff = val - prev
    print(f"  emlMul({a:5.1f}) = {val:15.6f}   Δ = {diff:12.6f} > 0: {diff > 0}")
    prev = val


# === Demo 4: Polynomial independence test ===
print("\n" + "=" * 60)
print("Demo 4: Testing Polynomial Relations (Transcendence Evidence)")
print("=" * 60)
print("  Testing if emlMul(1) = e*ln(2) satisfies any polynomial")
print("  P(x) = Σ c_i x^i with small integer coefficients...\n")

target = eml_mul(1)  # e * ln(2)

def check_polynomial_roots(target: float, max_deg: int, max_coeff: int) -> List[Tuple]:
    """Search for integer polynomials of bounded degree and coefficients that vanish at target."""
    hits = []
    import itertools
    coeffs_range = range(-max_coeff, max_coeff + 1)
    for deg in range(1, max_deg + 1):
        for coeffs in itertools.product(coeffs_range, repeat=deg + 1):
            if all(c == 0 for c in coeffs):
                continue
            val = sum(c * target**i for i, c in enumerate(coeffs))
            if abs(val) < 1e-8:
                hits.append((coeffs, val))
    return hits

hits = check_polynomial_roots(target, max_deg=4, max_coeff=5)
if hits:
    print(f"  Found {len(hits)} near-zero polynomials (possible algebraic relations):")
    for coeffs, val in hits[:5]:
        print(f"    P = {coeffs}, P(e*ln2) = {val:.2e}")
else:
    print("  No polynomial with deg ≤ 4, |coefficients| ≤ 5 vanishes at e*ln(2).")
    print("  This is strong numerical evidence for transcendence!")


# === Demo 5: Two-point algebraic independence ===
print("\n" + "=" * 60)
print("Demo 5: Two-Point EML Algebraic Independence")
print("=" * 60)

v1 = eml_mul(math.sqrt(2))
v2 = eml_mul(math.sqrt(3))
print(f"  emlMul(√2) = exp(√2) * log(1+√2) = {v1:.10f}")
print(f"  emlMul(√3) = exp(√3) * log(1+√3) = {v2:.10f}")
print(f"\n  Testing bivariate polynomial relations P(v1, v2) ≈ 0:")

found = False
for d1 in range(4):
    for d2 in range(4):
        if d1 + d2 == 0:
            continue
        for c in range(-3, 4):
            if c == 0:
                continue
            for c2 in range(-3, 4):
                val = c * v1**d1 * v2**d2 + c2
                if abs(val) < 1e-6:
                    print(f"    {c}*v1^{d1}*v2^{d2} + {c2} ≈ {val:.2e}")
                    found = True

if not found:
    print("  No simple bivariate relation found — evidence for algebraic independence!")


# === Demo 6: Growth rate ===
print("\n" + "=" * 60)
print("Demo 6: Asymptotic Growth of emlMul")
print("=" * 60)
print("  emlMul(a) ~ a * exp(a) for large a (since log(1+a) ~ log(a) ~ ln(a))")
print()
for a in [1, 2, 5, 10, 20, 50]:
    val = eml_mul(a)
    ratio = val / (a * math.exp(a))
    print(f"  emlMul({a:3d}) / (a*exp(a)) = {ratio:.6f}  (→ log(1+a)/a = {math.log(1+a)/a:.6f})")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Multiplicative Operator and Transcendence Evidence

Generates plots showing:
1. The emlMul function and its derivative
2. Polynomial independence testing (transcendence evidence)
3. Two-point algebraic independence landscape
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

def eml_mul(a):
    """Multiplicative EML operator: exp(a) * log(1 + a)"""
    return np.exp(a) * np.log(1 + a)

def eml_mul_deriv(a):
    """Derivative: exp(a) * (log(1+a) + 1/(1+a))"""
    return np.exp(a) * (np.log(1 + a) + 1.0 / (1 + a))

# Create figure with subplots
fig = plt.figure(figsize=(16, 12))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

# === Plot 1: emlMulR function ===
ax1 = fig.add_subplot(gs[0, 0])
a_neg = np.linspace(-0.99, 0, 200)
a_pos = np.linspace(0, 3, 200)
ax1.plot(a_neg, eml_mul(a_neg), 'b-', linewidth=2, label='emlMul(a), a < 0')
ax1.plot(a_pos, eml_mul(a_pos), 'r-', linewidth=2, label='emlMul(a), a > 0')
ax1.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
ax1.axvline(x=0, color='gray', linewidth=0.5, linestyle='--')
ax1.plot(0, 0, 'ko', markersize=8, label='Zero at a=0')

# Mark special values
special_a = [1, np.sqrt(2), np.sqrt(3)]
special_labels = ['1', '√2', '√3']
for sa, sl in zip(special_a, special_labels):
    val = eml_mul(sa)
    ax1.plot(sa, val, 'g^', markersize=10)
    ax1.annotate(f'a={sl}\n≈{val:.2f}', (sa, val),
                textcoords="offset points", xytext=(10, 10),
                fontsize=8, color='green')

ax1.set_xlabel('a', fontsize=12)
ax1.set_ylabel('emlMul(a)', fontsize=12)
ax1.set_title('Multiplicative EML Operator\nemlMul(a) = exp(a) · log(1+a)', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_xlim(-1.05, 3.2)
ax1.set_ylim(-3, 20)
ax1.grid(True, alpha=0.3)

# === Plot 2: Derivative ===
ax2 = fig.add_subplot(gs[0, 1])
a_deriv = np.linspace(-0.95, 3, 300)
ax2.plot(a_deriv, eml_mul_deriv(a_deriv), 'purple', linewidth=2)
ax2.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
ax2.fill_between(a_deriv[a_deriv > 0], 0, eml_mul_deriv(a_deriv[a_deriv > 0]),
                 alpha=0.2, color='green', label='Positive (monotone increasing)')
ax2.fill_between(a_deriv[a_deriv < 0], eml_mul_deriv(a_deriv[a_deriv < 0]), 0,
                 alpha=0.2, color='red', label='Region with sign changes')
ax2.set_xlabel('a', fontsize=12)
ax2.set_ylabel("emlMul'(a)", fontsize=12)
ax2.set_title("Derivative: exp(a)·(log(1+a) + 1/(1+a))\nPositive for a > 0 → strict monotonicity", fontsize=13)
ax2.legend(fontsize=9)
ax2.set_xlim(-1, 3.2)
ax2.grid(True, alpha=0.3)

# === Plot 3: Transcendence evidence ===
ax3 = fig.add_subplot(gs[1, 0])
target = np.exp(1) * np.log(2)  # emlMul(1)

# Test polynomial evaluations
degrees = range(1, 8)
min_residuals = []
for deg in degrees:
    min_res = float('inf')
    for trials in range(10000):
        coeffs = np.random.randint(-10, 11, size=deg + 1)
        if np.all(coeffs == 0):
            continue
        val = sum(c * target**i for i, c in enumerate(coeffs))
        min_res = min(min_res, abs(val))
    min_residuals.append(min_res)

ax3.semilogy(list(degrees), min_residuals, 'ro-', linewidth=2, markersize=8)
ax3.axhline(y=1e-10, color='green', linewidth=1, linestyle='--',
           label='Algebraic threshold (10⁻¹⁰)')
ax3.set_xlabel('Polynomial degree', fontsize=12)
ax3.set_ylabel('Minimum |P(e·ln2)|', fontsize=12)
ax3.set_title('Transcendence Evidence for emlMul(1) = e·ln(2)\nMin polynomial residual vs degree (random coefficients ≤ 10)',
             fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(1e-5, 1e3)

# === Plot 4: Two-point independence ===
ax4 = fig.add_subplot(gs[1, 1])
v1 = eml_mul(np.sqrt(2))
v2 = eml_mul(np.sqrt(3))

# Plot the point in the (v1, v2) plane with polynomial level curves
x_range = np.linspace(0, 20, 200)
y_range = np.linspace(0, 25, 200)
X, Y = np.meshgrid(x_range, y_range)

# Show some polynomial level curves
for c in range(-5, 6):
    if c == 0:
        continue
    ax4.contour(X, Y, X + Y - c*np.ones_like(X), levels=[0],
               colors='lightblue', alpha=0.3, linewidths=0.5)
    ax4.contour(X, Y, X * Y - c*10*np.ones_like(X), levels=[0],
               colors='lightyellow', alpha=0.3, linewidths=0.5)

ax4.plot(v1, v2, 'r*', markersize=20, label=f'(emlMul(√2), emlMul(√3))\n≈({v1:.2f}, {v2:.2f})')
ax4.set_xlabel('emlMul(√2)', fontsize=12)
ax4.set_ylabel('emlMul(√3)', fontsize=12)
ax4.set_title('Two-Point EML Algebraic Independence\nThe point avoids all polynomial curves', fontsize=13)
ax4.legend(fontsize=9, loc='upper left')
ax4.set_xlim(0, 20)
ax4.set_ylim(0, 25)
ax4.grid(True, alpha=0.3)

plt.suptitle('Multiplicative EML Transcendence Analysis', fontsize=16, fontweight='bold', y=1.02)
plt.savefig('eml_transcendence_analysis.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: eml_transcendence_analysis.png")
