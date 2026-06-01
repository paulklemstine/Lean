#!/usr/bin/env python3
"""
Turing's Flowers: Morphogenesis as Algebraic Geometry — Demo

Demonstrates:
1. Chebyshev polynomial computation and the cos(nθ) = Tₙ(cos θ) identity
2. Turing instability criterion verification
3. Pattern generation and algebraic classification
4. Zero set extraction and polynomial fitting
"""

import numpy as np
from typing import Tuple, List

# ============================================================
# Section 1: Chebyshev Polynomials
# ============================================================

def chebyshev_T(n: int, x: np.ndarray) -> np.ndarray:
    """Evaluate Chebyshev polynomial T_n at points x using recurrence."""
    if n == 0:
        return np.ones_like(x, dtype=float)
    if n == 1:
        return x.copy().astype(float)
    T_prev2 = np.ones_like(x, dtype=float)
    T_prev1 = x.copy().astype(float)
    for _ in range(2, n + 1):
        T_curr = 2 * x * T_prev1 - T_prev2
        T_prev2 = T_prev1
        T_prev1 = T_curr
    return T_curr


def verify_chebyshev_identity():
    """Verify cos(nθ) = T_n(cos θ) numerically."""
    print("=" * 60)
    print("CHEBYSHEV IDENTITY VERIFICATION: cos(nθ) = T_n(cos θ)")
    print("=" * 60)
    theta = np.linspace(0, 2 * np.pi, 1000)
    for n in range(6):
        lhs = np.cos(n * theta)
        rhs = chebyshev_T(n, np.cos(theta))
        max_error = np.max(np.abs(lhs - rhs))
        print(f"  n = {n}: max |cos({n}θ) - T_{n}(cos θ)| = {max_error:.2e}")
    print()


# ============================================================
# Section 2: Turing Instability
# ============================================================

def check_turing_instability(D1: float, D2: float,
                              a11: float, a12: float,
                              a21: float, a22: float) -> dict:
    """Check Turing instability criterion for a 2-component system."""
    tr_J = a11 + a22
    det_J = a11 * a22 - a12 * a21
    cross_diff = D2 * a11 + D1 * a22
    discriminant = cross_diff**2 - 4 * D1 * D2 * det_J

    uniform_stable = tr_J < 0 and det_J > 0
    turing_unstable = uniform_stable and cross_diff > 0 and discriminant > 0

    result = {
        'tr_J': tr_J,
        'det_J': det_J,
        'cross_diff': cross_diff,
        'discriminant': discriminant,
        'uniform_stable': uniform_stable,
        'turing_unstable': turing_unstable,
    }

    if turing_unstable:
        q_minus = (cross_diff - np.sqrt(discriminant)) / (2 * D1 * D2)
        q_plus = (cross_diff + np.sqrt(discriminant)) / (2 * D1 * D2)
        result['q_minus'] = q_minus
        result['q_plus'] = q_plus
        result['k_critical'] = np.sqrt((q_minus + q_plus) / 2)

    return result


def demo_turing_instability():
    """Demonstrate the Turing instability criterion."""
    print("=" * 60)
    print("TURING INSTABILITY CRITERION")
    print("=" * 60)

    # Classic activator-inhibitor: activator self-activates (a11 > 0),
    # inhibitor self-inhibits (a22 < 0), cross-terms create feedback
    systems = [
        ("Gierer-Meinhardt", 0.01, 1.0, 1.0, -1.0, 2.0, -1.5),
        ("Gray-Scott (spots)", 0.02, 0.08, 0.5, -0.8, 1.5, -2.0),
        ("Schnakenberg", 0.05, 1.0, 0.8, -1.2, 1.0, -1.0),
        ("No instability", 0.5, 0.5, -1.0, 0.5, 0.5, -1.0),
    ]

    for name, D1, D2, a11, a12, a21, a22 in systems:
        result = check_turing_instability(D1, D2, a11, a12, a21, a22)
        print(f"\n  System: {name}")
        print(f"    D₁={D1}, D₂={D2}")
        print(f"    Jacobian: [[{a11}, {a12}], [{a21}, {a22}]]")
        print(f"    tr(J) = {result['tr_J']:.4f}")
        print(f"    det(J) = {result['det_J']:.4f}")
        print(f"    Cross-diffusion coeff = {result['cross_diff']:.4f}")
        print(f"    Discriminant = {result['discriminant']:.4f}")
        print(f"    Uniform stable: {result['uniform_stable']}")
        print(f"    Turing unstable: {result['turing_unstable']}")
        if result['turing_unstable']:
            print(f"    Critical wave numbers: k ∈ [{np.sqrt(result['q_minus']):.4f}, {np.sqrt(result['q_plus']):.4f}]")
    print()


# ============================================================
# Section 3: Pattern Generation and Classification
# ============================================================

def generate_pattern(coeffs: List[float], Lx: float = 2*np.pi,
                     Ly: float = 2*np.pi, nx: int = 200,
                     ny: int = 200) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Generate a 2D Turing-like pattern from cosine modes."""
    x = np.linspace(0, Lx, nx)
    y = np.linspace(0, Ly, ny)
    X, Y = np.meshgrid(x, y)

    pattern = np.zeros_like(X)
    for k, a_k in enumerate(coeffs):
        if abs(a_k) > 1e-15:
            # Add mode cos(kx) * cos(ky) scaled by coefficient
            pattern += a_k * np.cos(k * X) * np.cos(k * Y)

    return X, Y, pattern


def classify_pattern(coeffs: List[float]) -> str:
    """Classify pattern type based on algebraic degree."""
    max_mode = 0
    for k in range(len(coeffs) - 1, -1, -1):
        if abs(coeffs[k]) > 1e-15:
            max_mode = k
            break

    if max_mode == 0:
        return "constant (trivial)"
    elif max_mode == 1:
        return "linear (stripes)"
    elif max_mode == 2:
        return "quadratic (conic: spots/stripes/labyrinths)"
    elif max_mode <= 3:
        return "cubic (complex patterns)"
    elif max_mode <= 6:
        return f"degree {max_mode} (hexagonal/complex patterns)"
    else:
        return f"degree {max_mode} (high-complexity pattern)"


def demo_pattern_classification():
    """Demonstrate pattern classification by algebraic degree."""
    print("=" * 60)
    print("PATTERN CLASSIFICATION BY ALGEBRAIC DEGREE")
    print("=" * 60)

    patterns = [
        ("Uniform", [1.0]),
        ("Simple stripes", [0.0, 1.0]),
        ("Spots (conic)", [0.5, 0.0, 1.0]),
        ("Hexagonal", [0.3, 0.0, 0.0, 1.0]),
        ("Complex", [0.1, 0.3, 0.5, 0.2, 0.8]),
    ]

    for name, coeffs in patterns:
        ptype = classify_pattern(coeffs)
        print(f"\n  Pattern: {name}")
        print(f"    Coefficients: {coeffs}")
        print(f"    Classification: {ptype}")

        # Verify Chebyshev expansion
        theta = np.linspace(0, np.pi, 100)
        x = np.cos(theta)

        # Trigonometric form
        trig_values = sum(a * np.cos(k * theta) for k, a in enumerate(coeffs))
        # Polynomial form via Chebyshev
        poly_values = sum(a * chebyshev_T(k, x) for k, a in enumerate(coeffs))
        max_diff = np.max(np.abs(trig_values - poly_values))
        print(f"    Trig ↔ Polynomial agreement: max error = {max_diff:.2e}")

    print()


# ============================================================
# Section 4: Zero Set Analysis
# ============================================================

def demo_zero_set():
    """Demonstrate zero set extraction and algebraic structure."""
    print("=" * 60)
    print("ZERO SET ALGEBRAIC STRUCTURE")
    print("=" * 60)

    # 1D: spots pattern cos(2θ) + 0.5
    theta = np.linspace(0, 2 * np.pi, 10000)
    u = np.cos(2 * theta) + 0.5  # T₂(cos θ) + 0.5 = 2cos²θ - 1 + 0.5 = 2cos²θ - 0.5

    # Find zero crossings
    zero_crossings = []
    for i in range(len(u) - 1):
        if u[i] * u[i+1] < 0:
            # Linear interpolation
            t = theta[i] - u[i] * (theta[i+1] - theta[i]) / (u[i+1] - u[i])
            zero_crossings.append(t)

    print(f"\n  Pattern: cos(2θ) + 0.5")
    print(f"  Chebyshev form: T₂(x) + 0.5 = 2x² - 0.5")
    print(f"  Algebraic zero set: x² = 1/4, i.e., x = ±1/2")
    print(f"  Corresponding angles: θ = ±π/3 + 2πn")
    print(f"  Found {len(zero_crossings)} zero crossings in [0, 2π]:")
    for zc in zero_crossings:
        x_val = np.cos(zc)
        print(f"    θ = {zc:.4f} (cos θ = {x_val:.4f})")

    # Verify algebraic: 2x² - 0.5 = 0 → x = ±√(1/4) = ±0.5
    print(f"\n  Algebraic prediction: cos θ = ±0.5 at θ = π/3, 2π/3, 4π/3, 5π/3")
    print(f"  π/3 ≈ {np.pi/3:.4f}, 2π/3 ≈ {2*np.pi/3:.4f}, "
          f"4π/3 ≈ {4*np.pi/3:.4f}, 5π/3 ≈ {5*np.pi/3:.4f}")

    # 2D degree bound demonstration
    print(f"\n  DEGREE BOUNDS:")
    for N in range(1, 6):
        coeffs = [0.0] * (N + 1)
        coeffs[N] = 1.0
        ptype = classify_pattern(coeffs)
        print(f"    N={N} modes → algebraic degree ≤ {N}: {ptype}")

    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  TURING'S FLOWERS: MORPHOGENESIS AS ALGEBRAIC GEOMETRY   ║")
    print("╚" + "═" * 58 + "╝")
    print()

    verify_chebyshev_identity()
    demo_turing_instability()
    demo_pattern_classification()
    demo_zero_set()

    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
  Key Results Demonstrated:
  1. cos(nθ) = T_n(cos θ) verified to machine precision
  2. Turing instability criterion: algebraic conditions on
     diffusion coefficients and Jacobian entries
  3. Pattern classification by algebraic degree of Chebyshev
     expansion polynomial
  4. Zero sets are algebraic: pattern boundaries are roots of
     polynomials in cos θ

  The mathematics of leopard spots is the mathematics of
  conic sections.
""")


#!/usr/bin/env python3
"""
Visualization: The Chebyshev Bridge — From Trigonometry to Algebra

Shows how cos(nθ) = T_n(cos θ) converts trigonometric patterns
into algebraic polynomials, making pattern boundaries into algebraic curves.
"""

import numpy as np
import matplotlib.pyplot as plt


def chebyshev_eval(n, x):
    if n == 0:
        return np.ones_like(x, dtype=float)
    if n == 1:
        return x.astype(float)
    t2 = np.ones_like(x, dtype=float)
    t1 = x.astype(float)
    for _ in range(2, n + 1):
        t_new = 2.0 * x * t1 - t2
        t2 = t1
        t1 = t_new
    return t1


fig, axes = plt.subplots(3, 2, figsize=(14, 15))
fig.suptitle("The Chebyshev Bridge: cos(nθ) = Tₙ(cos θ)", fontsize=16, fontweight='bold')

theta = np.linspace(0, 2 * np.pi, 1000)

for n in range(6):
    ax = axes[n // 2, n % 2]

    # Trigonometric form
    trig = np.cos(n * theta)
    ax.plot(theta, trig, 'b-', linewidth=2, label=f'cos({n}θ)')

    # Chebyshev form
    cheb = chebyshev_eval(n, np.cos(theta))
    ax.plot(theta, cheb, 'r--', linewidth=2, label=f'T_{n}(cos θ)', alpha=0.7)

    # Mark zeros
    for i in range(len(trig) - 1):
        if trig[i] * trig[i + 1] < 0:
            t_zero = theta[i] - trig[i] * (theta[i + 1] - theta[i]) / (trig[i + 1] - trig[i])
            ax.plot(t_zero, 0, 'ko', markersize=6)

    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_title(f'n = {n}: {2 * n} zeros in [0, 2π], algebraic degree = {n}', fontsize=11)
    ax.set_xlabel('θ')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 2 * np.pi)
    ax.set_ylim(-1.3, 1.3)

plt.tight_layout()
plt.savefig('chebyshev_bridge.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: chebyshev_bridge.png")


#!/usr/bin/env python3
"""
Visualization: Turing Instability — The Dispersion Relation

Shows how the dispersion relation h(q) determines which wave numbers
go unstable, connecting the quadratic discriminant condition to
pattern formation.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 3, figsize=(18, 5))
fig.suptitle("Turing Instability: From Stability to Pattern Formation", fontsize=14, fontweight='bold')

q = np.linspace(0, 8, 500)

# Case 1: Stable (no instability)
ax1 = axes[0]
D1, D2 = 0.5, 0.5
a11, a22 = -0.5, -0.5
det_J = 0.5
h = D1 * D2 * q**2 - (D2 * a11 + D1 * a22) * q + det_J
ax1.plot(q, h, 'b-', linewidth=2.5)
ax1.fill_between(q, 0, h, where=(h > 0), alpha=0.1, color='blue')
ax1.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
ax1.set_title('No Instability\nD₂/D₁ = 1 (equal diffusion)', fontsize=11)
ax1.set_xlabel('q = k²')
ax1.set_ylabel('h(q)')
ax1.set_ylim(-0.5, 3)
ax1.grid(True, alpha=0.3)
ax1.annotate('h(q) > 0 for all q > 0\n→ Uniform state stable',
             xy=(3, 1.5), fontsize=9, ha='center',
             bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.5))

# Case 2: Near threshold
ax2 = axes[1]
D1, D2 = 0.01, 0.5
a11, a22 = 1.0, -1.5
det_J = 0.5
sigma = D2 * a11 + D1 * a22
disc = sigma**2 - 4 * D1 * D2 * det_J
h = D1 * D2 * q**2 - sigma * q + det_J
ax2.plot(q, h, 'orange', linewidth=2.5)
ax2.fill_between(q, 0, h, where=(h < 0), alpha=0.2, color='red')
ax2.fill_between(q, 0, h, where=(h > 0), alpha=0.1, color='blue')
ax2.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
q_min = sigma / (2 * D1 * D2)
h_min = det_J - sigma**2 / (4 * D1 * D2)
ax2.plot(q_min, h_min, 'rv', markersize=10)
ax2.set_title(f'Near Threshold\nσ = {sigma:.3f}, Δ = {disc:.3f}', fontsize=11)
ax2.set_xlabel('q = k²')
ax2.set_ylim(-0.5, 3)
ax2.grid(True, alpha=0.3)
if disc > 0:
    q_minus = (sigma - np.sqrt(disc)) / (2 * D1 * D2)
    q_plus = (sigma + np.sqrt(disc)) / (2 * D1 * D2)
    ax2.axvspan(q_minus, q_plus, alpha=0.15, color='red')
    ax2.annotate(f'Unstable band\nq ∈ [{q_minus:.1f}, {q_plus:.1f}]',
                 xy=((q_minus + q_plus) / 2, -0.3), fontsize=9, ha='center',
                 bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Case 3: Strong instability
ax3 = axes[2]
D1, D2 = 0.005, 2.0
a11, a22 = 1.0, -1.5
det_J = 0.5
sigma = D2 * a11 + D1 * a22
disc = sigma**2 - 4 * D1 * D2 * det_J
h = D1 * D2 * q**2 - sigma * q + det_J
ax3.plot(q, h, 'r-', linewidth=2.5)
ax3.fill_between(q, 0, h, where=(h < 0), alpha=0.2, color='red')
ax3.fill_between(q, 0, h, where=(h > 0), alpha=0.1, color='blue')
ax3.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
q_min = sigma / (2 * D1 * D2)
h_min = det_J - sigma**2 / (4 * D1 * D2)
ax3.plot(q_min, h_min, 'rv', markersize=10)
ax3.set_title(f'Strong Instability\nD₂/D₁ = {D2/D1:.0f}', fontsize=11)
ax3.set_xlabel('q = k²')
ax3.set_ylim(-30, 10)
ax3.grid(True, alpha=0.3)
if disc > 0:
    q_minus = (sigma - np.sqrt(disc)) / (2 * D1 * D2)
    q_plus = (sigma + np.sqrt(disc)) / (2 * D1 * D2)
    ax3.axvspan(q_minus, q_plus, alpha=0.15, color='red')
    ax3.annotate(f'Wide unstable band\nMany modes unstable\n→ Complex pattern',
                 xy=(q_min, h_min + 2), fontsize=9, ha='center',
                 bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('dispersion_relation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: dispersion_relation.png")


#!/usr/bin/env python3
"""
Visualization: Turing Patterns and Their Algebraic Zero Sets

Generates a figure showing Turing patterns alongside their Chebyshev
polynomial representations and algebraic zero sets.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def chebyshev_eval(n, x):
    if n == 0:
        return np.ones_like(x, dtype=float)
    if n == 1:
        return x.astype(float)
    t2 = np.ones_like(x, dtype=float)
    t1 = x.astype(float)
    for _ in range(2, n + 1):
        t_new = 2.0 * x * t1 - t2
        t2 = t1
        t1 = t_new
    return t1


def pattern_2d(coeffs_list, X, Y):
    """Evaluate pattern P(X,Y) = Σ a_k T_k(X) T_k(Y)."""
    Z = np.zeros_like(X)
    for k, a in enumerate(coeffs_list):
        Z += a * chebyshev_eval(k, X) * chebyshev_eval(k, Y)
    return Z


fig = plt.figure(figsize=(16, 12))
fig.suptitle("Turing Patterns as Algebraic Varieties", fontsize=16, fontweight='bold')
gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)

x = np.linspace(-1, 1, 500)
X, Y = np.meshgrid(x, x)

# Pattern 1: Stripes (degree 1)
ax1 = fig.add_subplot(gs[0, 0])
Z1 = chebyshev_eval(1, X)  # T_1(X) = X → stripes
ax1.contourf(X, Y, Z1, levels=20, cmap='RdBu_r')
ax1.contour(X, Y, Z1, levels=[0], colors='black', linewidths=2)
ax1.set_title('Stripes: T₁(X) = X\nDegree 1', fontsize=11)
ax1.set_xlabel('X = cos(θ)')
ax1.set_ylabel('Y = cos(φ)')
ax1.set_aspect('equal')

# Pattern 2: Spots (degree 2)
ax2 = fig.add_subplot(gs[0, 1])
Z2 = chebyshev_eval(2, X) + chebyshev_eval(2, Y)  # T_2(X) + T_2(Y)
ax2.contourf(X, Y, Z2, levels=20, cmap='RdBu_r')
ax2.contour(X, Y, Z2, levels=[0], colors='black', linewidths=2)
ax2.set_title('Spots: T₂(X) + T₂(Y)\nDegree 2 (Conic)', fontsize=11)
ax2.set_xlabel('X = cos(θ)')
ax2.set_aspect('equal')

# Pattern 3: Hexagonal (degree 3)
ax3 = fig.add_subplot(gs[0, 2])
Z3 = chebyshev_eval(3, X) + chebyshev_eval(3, Y) + 0.5 * chebyshev_eval(1, X) * chebyshev_eval(1, Y)
ax3.contourf(X, Y, Z3, levels=20, cmap='RdBu_r')
ax3.contour(X, Y, Z3, levels=[0], colors='black', linewidths=2)
ax3.set_title('Complex: T₃(X)+T₃(Y)+½T₁(X)T₁(Y)\nDegree 3', fontsize=11)
ax3.set_xlabel('X = cos(θ)')
ax3.set_aspect('equal')

# Pattern 4: Labyrinthine (degree 4)
ax4 = fig.add_subplot(gs[1, 0])
Z4 = chebyshev_eval(2, X) * chebyshev_eval(2, Y) - 0.3
ax4.contourf(X, Y, Z4, levels=20, cmap='RdBu_r')
ax4.contour(X, Y, Z4, levels=[0], colors='black', linewidths=2)
ax4.set_title('Labyrinth: T₂(X)·T₂(Y) − 0.3\nDegree 4', fontsize=11)
ax4.set_xlabel('X = cos(θ)')
ax4.set_ylabel('Y = cos(φ)')
ax4.set_aspect('equal')

# 1D Chebyshev polynomials
ax5 = fig.add_subplot(gs[1, 1])
theta = np.linspace(0, np.pi, 500)
x_1d = np.cos(theta)
for n in range(5):
    ax5.plot(x_1d, chebyshev_eval(n, x_1d), label=f'T_{n}(x)', linewidth=2)
ax5.set_title('Chebyshev Polynomials T_n(x)\nBridge: cos(nθ) = T_n(cos θ)', fontsize=11)
ax5.set_xlabel('x = cos(θ)')
ax5.set_ylabel('T_n(x)')
ax5.legend(fontsize=9)
ax5.grid(True, alpha=0.3)
ax5.axhline(y=0, color='k', linewidth=0.5)

# Dispersion relation
ax6 = fig.add_subplot(gs[1, 2])
q = np.linspace(0, 5, 500)
D1, D2 = 0.01, 1.0
a11, a22, det_J = 1.0, -1.5, 0.5

for d_ratio in [10, 50, 100, 200]:
    D2_var = D1 * d_ratio
    h = D1 * D2_var * q**2 - (D2_var * a11 + D1 * a22) * q + det_J
    ax6.plot(q, h, label=f'D₂/D₁ = {d_ratio}', linewidth=2)

ax6.axhline(y=0, color='k', linewidth=1, linestyle='--')
ax6.set_title('Dispersion Relation h(q)\nTuring instability: h(q) < 0', fontsize=11)
ax6.set_xlabel('q = k² (squared wave number)')
ax6.set_ylabel('h(q)')
ax6.legend(fontsize=9)
ax6.grid(True, alpha=0.3)
ax6.set_ylim(-2, 3)

plt.savefig('turing_patterns.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: turing_patterns.png")
