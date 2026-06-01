#!/usr/bin/env python3
"""
Yamabe Problem: Non-Compact Case — Numerical Demonstrations

Explores the key quantities of the Yamabe problem: dimensional constants,
bubble functions, energy functionals, and non-compact obstructions.
"""
import math


def yamabe_const(n: float) -> float:
    """Yamabe dimensional constant c_n = 4(n-1)/(n-2)."""
    return 4 * (n - 1) / (n - 2)


def sobolev_crit_exp(n: float) -> float:
    """Critical Sobolev exponent p* = 2n/(n-2)."""
    return 2 * n / (n - 2)


def yamabe_exp(n: float) -> float:
    """Yamabe nonlinearity exponent (n+2)/(n-2)."""
    return (n + 2) / (n - 2)


def conformal_weight(n: float) -> float:
    """Conformal weight alpha = (n-2)/2."""
    return (n - 2) / 2


def std_bubble(alpha: float, t: float) -> float:
    """Standard bubble function u_alpha(t) = (1 + t^2)^(-alpha)."""
    return (1 + t**2) ** (-alpha)


def algebraic_energy(bg_curvature: float, target_curvature: float,
                     p_star: float, u: float) -> float:
    """Algebraic energy: kappa * u^2 - lambda * u^(p*)."""
    return bg_curvature * u**2 - target_curvature * u**p_star


def sobolev_quotient(n: float) -> float:
    """Sobolev quotient Q(n) = p*/(p*-2)."""
    p = sobolev_crit_exp(n)
    return p / (p - 2)


def sphere_scalar_curvature(n: float) -> float:
    """Scalar curvature of the unit n-sphere: n(n-1)."""
    return n * (n - 1)


def main():
    print("=" * 70)
    print("YAMABE PROBLEM: NON-COMPACT CASE — NUMERICAL EXPLORATION")
    print("=" * 70)

    # --- Section 1: Dimensional Constants ---
    print("\n--- Yamabe Dimensional Constants ---")
    print(f"{'n':>4}  {'c_n':>8}  {'p*':>8}  {'yamExp':>8}  {'alpha':>8}  {'Q':>8}")
    print("-" * 60)
    for n in [3, 4, 5, 6, 7, 10, 20, 50, 100]:
        cn = yamabe_const(n)
        ps = sobolev_crit_exp(n)
        ye = yamabe_exp(n)
        al = conformal_weight(n)
        q = sobolev_quotient(n)
        print(f"{n:4d}  {cn:8.4f}  {ps:8.4f}  {ye:8.4f}  {al:8.4f}  {q:8.4f}")
    print(f"\nAs n → ∞: c_n → 4, p* → 2, yamExp → 1, alpha → ∞, Q → ∞")

    # --- Section 2: Verify Algebraic Identities ---
    print("\n--- Algebraic Identity Verification ---")
    for n in [3.0, 4.0, 5.0, 10.0, 100.0]:
        cn = yamabe_const(n)
        ps = sobolev_crit_exp(n)
        al = conformal_weight(n)
        ye = yamabe_exp(n)
        q = sobolev_quotient(n)

        # Sobolev conjugate identity: 1/2 - 1/p* = 1/n
        lhs = 1/2 - 1/ps
        rhs = 1/n
        assert abs(lhs - rhs) < 1e-12, f"Sobolev conjugate failed for n={n}"

        # c_n = p* + 2
        assert abs(cn - (ps + 2)) < 1e-12, f"Duality failed for n={n}"

        # yamExp = p* - 1
        assert abs(ye - (ps - 1)) < 1e-12, f"yamExp relation failed for n={n}"

        # 2*alpha + 2 = n
        assert abs(2*al + 2 - n) < 1e-12, f"conformal weight failed for n={n}"

        # alpha * yamExp = alpha + 2
        assert abs(al * ye - (al + 2)) < 1e-12, f"weight shift failed for n={n}"

        # Q = n/2
        assert abs(q - n/2) < 1e-12, f"Sobolev quotient failed for n={n}"

        # Pohozaev: n/2 - n/p* = 1
        assert abs(n/2 - n/ps - 1) < 1e-12, f"Pohozaev failed for n={n}"

        # Critical scaling: n - 2n/p* = 2
        assert abs(n - 2*n/ps - 2) < 1e-12, f"Critical scaling failed for n={n}"

        print(f"  n={n:5.1f}: All identities verified ✓")

    # --- Section 3: Bubble Function ---
    print("\n--- Standard Bubble Function ---")
    print("  α = 0.5 (dimension n=3):")
    alpha = 0.5
    for t in [0, 0.5, 1.0, 2.0, 5.0, 10.0]:
        u = std_bubble(alpha, t)
        print(f"    u({t:5.1f}) = {u:.6f}")

    print("\n  Bubble at origin for various α:")
    for al in [0.5, 1.0, 1.5, 2.0, 5.0]:
        assert abs(std_bubble(al, 0) - 1.0) < 1e-15
    print("    u_α(0) = 1.0 for all α (verified)")

    print("\n  Even symmetry check:")
    for al, t in [(0.5, 1.0), (1.0, 2.0), (2.5, 3.7)]:
        assert abs(std_bubble(al, t) - std_bubble(al, -t)) < 1e-15
    print("    u_α(t) = u_α(-t) verified for all test cases ✓")

    print("\n  Power rule: u_α(t)^β = u_{αβ}(t):")
    for al, be, t in [(0.5, 2.0, 1.0), (1.0, 3.0, 2.0), (0.7, 1.5, 3.0)]:
        lhs = std_bubble(al, t) ** be
        rhs = std_bubble(al * be, t)
        assert abs(lhs - rhs) < 1e-12
    print("    Verified for all test cases ✓")

    # --- Section 4: Algebraic Energy ---
    print("\n--- Algebraic Energy E(u) = κu² - λu^(p*) ---")
    n = 3
    ps = sobolev_crit_exp(n)
    print(f"  Dimension n={n}, p*={ps:.2f}")

    # Case 1: target > background (negative energy at u=1)
    bg, target = 1.0, 3.0
    e1 = algebraic_energy(bg, target, ps, 1.0)
    print(f"  κ={bg}, λ={target}: E(1) = {e1:.4f} {'< 0 ✓' if e1 < 0 else '≥ 0 ✗'}")

    # Case 2: background > target (positive energy at u=1)
    bg, target = 5.0, 2.0
    e2 = algebraic_energy(bg, target, ps, 1.0)
    print(f"  κ={bg}, λ={target}: E(1) = {e2:.4f} {'> 0 ✓' if e2 > 0 else '≤ 0 ✗'}")

    # Case 3: equal (zero energy at u=1)
    bg, target = 3.0, 3.0
    e3 = algebraic_energy(bg, target, ps, 1.0)
    print(f"  κ={bg}, λ={target}: E(1) = {e3:.4f} {'= 0 ✓' if abs(e3) < 1e-10 else '≠ 0 ✗'}")

    # --- Section 5: Monotonicity of Yamabe Constant ---
    print("\n--- Yamabe Constant Monotonicity ---")
    print("  c_n is strictly decreasing for n > 2:")
    prev_cn = yamabe_const(3)
    for n in range(4, 20):
        cn = yamabe_const(n)
        assert cn < prev_cn, f"Monotonicity failed at n={n}"
        prev_cn = cn
    print("  Verified: c_3 > c_4 > ... > c_19 ✓")
    print(f"  c_3 = {yamabe_const(3):.4f}, c_19 = {yamabe_const(19):.4f}, limit = 4.0000")

    # --- Section 6: Sphere Scalar Curvature ---
    print("\n--- Sphere Scalar Curvature ---")
    for n in [3, 4, 5, 6]:
        s = sphere_scalar_curvature(n)
        cn = yamabe_const(n)
        alpha = conformal_weight(n)
        # Verify: S = c_n * n*(n-2) / 4
        via_yamabe = cn * n * (n-2) / 4
        # Verify: S = (2α+2)(2α+1)
        via_weight = (2*alpha + 2) * (2*alpha + 1)
        print(f"  n={n}: S_n = {s:.1f}, via Yamabe const = {via_yamabe:.1f}, "
              f"via weight = {via_weight:.1f}")
        assert abs(s - via_yamabe) < 1e-10
        assert abs(s - via_weight) < 1e-10

    print("\n" + "=" * 70)
    print("All numerical demonstrations completed successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Yamabe Problem Constants and Bubble Functions

Generates publication-quality plots showing:
1. Yamabe constant c_n as a function of dimension
2. Standard bubble functions for various dimensions
3. Algebraic energy landscape
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def yamabe_const(n):
    return 4 * (n - 1) / (n - 2)

def sobolev_crit_exp(n):
    return 2 * n / (n - 2)

def conformal_weight(n):
    return (n - 2) / 2

def std_bubble(alpha, t):
    return (1 + t**2) ** (-alpha)

def algebraic_energy(kappa, lam, p_star, u):
    return kappa * u**2 - lam * np.abs(u)**p_star


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Yamabe constant vs dimension
ax = axes[0, 0]
ns = np.linspace(2.1, 50, 500)
cns = [yamabe_const(n) for n in ns]
ax.plot(ns, cns, 'b-', linewidth=2, label=r'$c_n = \frac{4(n-1)}{n-2}$')
ax.axhline(y=4, color='r', linestyle='--', alpha=0.7, label=r'$\lim_{n\to\infty} c_n = 4$')
for n_int in [3, 4, 5, 6, 10]:
    ax.plot(n_int, yamabe_const(n_int), 'ko', markersize=6)
    ax.annotate(f'n={n_int}', (n_int, yamabe_const(n_int)),
                textcoords="offset points", xytext=(10, 5), fontsize=8)
ax.set_xlabel('Dimension n', fontsize=12)
ax.set_ylabel(r'$c_n$', fontsize=14)
ax.set_title('Yamabe Dimensional Constant', fontsize=13)
ax.legend(fontsize=10)
ax.set_ylim(3.5, 12)
ax.grid(True, alpha=0.3)

# Plot 2: Bubble functions for various dimensions
ax = axes[0, 1]
t = np.linspace(-5, 5, 500)
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
for i, n_val in enumerate([3, 4, 5, 6, 10]):
    alpha = conformal_weight(n_val)
    u = std_bubble(alpha, t)
    ax.plot(t, u, color=colors[i], linewidth=2, label=f'n={n_val} (α={alpha:.1f})')
ax.set_xlabel('t (radial coordinate)', fontsize=12)
ax.set_ylabel(r'$u_\alpha(t)$', fontsize=14)
ax.set_title('Standard Bubble Functions', fontsize=13)
ax.legend(fontsize=9)
ax.set_ylim(0, 1.1)
ax.grid(True, alpha=0.3)

# Plot 3: Critical Sobolev exponent and Yamabe exponent
ax = axes[1, 0]
ns = np.linspace(2.5, 20, 300)
ps = [sobolev_crit_exp(n) for n in ns]
ye = [(n + 2) / (n - 2) for n in ns]
ax.plot(ns, ps, 'b-', linewidth=2, label=r"$p^* = \frac{2n}{n-2}$")
ax.plot(ns, ye, 'r-', linewidth=2, label=r"$\frac{n+2}{n-2}$ (Yamabe exp)")
ax.axhline(y=2, color='gray', linestyle=':', alpha=0.5, label='p* → 2')
ax.axhline(y=1, color='gray', linestyle='-.', alpha=0.5, label='yamExp → 1')
ax.set_xlabel('Dimension n', fontsize=12)
ax.set_ylabel('Exponent', fontsize=12)
ax.set_title('Critical Sobolev & Yamabe Exponents', fontsize=13)
ax.legend(fontsize=9)
ax.set_ylim(0, 8)
ax.grid(True, alpha=0.3)

# Plot 4: Algebraic energy landscape
ax = axes[1, 1]
u_vals = np.linspace(0.01, 2.5, 500)
n_val = 4
p_star = sobolev_crit_exp(n_val)

for kappa, lam, label in [(2, 1, 'κ>λ (positive)'),
                           (1, 1, 'κ=λ'),
                           (1, 3, 'κ<λ (obstruction)')]:
    e = algebraic_energy(kappa, lam, p_star, u_vals)
    ax.plot(u_vals, e, linewidth=2, label=label)

ax.axhline(y=0, color='k', linewidth=0.5)
ax.set_xlabel('Conformal factor u', fontsize=12)
ax.set_ylabel(r'$E_{alg}(u) = \kappa u^2 - \lambda u^{p^*}$', fontsize=11)
ax.set_title(f'Algebraic Energy (n={n_val}, p*={p_star:.0f})', fontsize=13)
ax.legend(fontsize=9)
ax.set_ylim(-5, 5)
ax.grid(True, alpha=0.3)

plt.suptitle('Yamabe Problem: Non-Compact Case', fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('yamabe_visualization.png', dpi=150, bbox_inches='tight')
print("Saved yamabe_visualization.png")
