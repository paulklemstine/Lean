#!/usr/bin/env python3
"""
applications.py — Applications of symmetric power transfer theory.

Demonstrates real-world applications:
1. L-function coefficient computation
2. Complexity growth analysis under functorial transfer
3. Random matrix spectral statistics from self-dual parameters
"""

import numpy as np
from typing import List, Tuple


# ─── Inline core functions ───────────────────────────────────────────────────

def symm_pow_roots(n: int, alpha: complex, beta: complex) -> List[complex]:
    return [alpha**(n - i) * beta**i for i in range(n + 1)]

def euler_poly_from_roots(roots: List[complex]) -> np.ndarray:
    poly = np.array([1.0 + 0j])
    for r in roots:
        poly = np.convolve(poly, np.array([-r, 1.0]))
    return poly

def symm_pow_euler_coeffs(n: int, alpha: complex, beta: complex) -> np.ndarray:
    return euler_poly_from_roots(symm_pow_roots(n, alpha, beta))


# ─── Application 1: L-function Dirichlet coefficients ────────────────────────

def local_euler_factor_coeffs(
    n: int, alpha: float, beta: float, num_terms: int = 20
) -> np.ndarray:
    """
    Compute the first `num_terms` coefficients of the local Euler factor
    L_p(s, Sym^n π) = 1 / ∏(1 - r_i X).

    The inverse Euler polynomial is ∏(1 - r_i X). To get L_p itself,
    we compute the power series expansion 1/P(X).

    This is how automorphic L-functions are computed in practice:
    the Satake parameters determine the local factor, and the Dirichlet
    series coefficients arise from power series inversion.

    Args:
        n: Symmetric power index
        alpha, beta: Satake parameters at the prime p
        num_terms: Number of power series terms

    Returns:
        Coefficients [a_0, a_1, ..., a_{num_terms-1}] of L_p(X)
    """
    roots = symm_pow_roots(n, alpha, beta)
    # Euler factor inverse: ∏(1 - r_i X)
    inv_euler = np.array([1.0])
    for r in roots:
        inv_euler = np.convolve(inv_euler, np.array([1.0, -r]))

    # Power series inversion: if P = Σ p_k X^k, then L = 1/P has
    # L_0 = 1/p_0, L_k = -(1/p_0) Σ_{j=1}^{k} p_j L_{k-j}
    d = len(inv_euler)
    L = np.zeros(num_terms)
    L[0] = 1.0 / inv_euler[0]
    for k in range(1, num_terms):
        s = 0.0
        for j in range(1, min(k + 1, d)):
            s += inv_euler[j] * L[k - j]
        L[k] = -s / inv_euler[0]
    return L


def demo_l_function():
    """Demonstrate L-function coefficient computation."""
    print("=" * 70)
    print("  APPLICATION 1: L-FUNCTION DIRICHLET COEFFICIENTS")
    print("=" * 70)
    print()
    print("  For the Ramanujan Δ function at p=2:")
    print("  Satake parameters satisfy α·β = p^11 = 2048, α+β = τ(2) = -24")
    print()

    # For Ramanujan Δ at p=2: τ(2) = -24, αβ = 2^11 = 2048
    # α + β = -24, αβ = 2048
    # α, β are roots of t^2 + 24t + 2048 = 0
    disc = 24**2 - 4 * 2048
    alpha = (-24 + np.sqrt(disc + 0j)) / 2
    beta = (-24 - np.sqrt(disc + 0j)) / 2
    print(f"  α = {alpha:.4f}")
    print(f"  β = {beta:.4f}")
    print(f"  αβ = {(alpha * beta).real:.0f}")

    for sym_n in [1, 2, 3, 4]:
        coeffs = local_euler_factor_coeffs(sym_n, alpha, beta, 8)
        print(f"\n  Sym^{sym_n} L-factor coefficients at p=2:")
        for k, c in enumerate(coeffs):
            print(f"    a_{k} = {c.real:>14.2f}")


# ─── Application 2: Complexity Growth Under Transfer ─────────────────────────

def complexity_growth_analysis(max_n: int = 20):
    """
    Analyze the growth of algebraic complexity under symmetric power transfer.

    The Euler polynomial of Sym^n has degree n+1. By the depth-degree tradeoff
    (depth ≥ log₂(degree)), any algebraic circuit computing this polynomial
    needs depth ≥ log₂(n+1).

    This is "functoriality as complexity amplification."
    """
    print("\n" + "=" * 70)
    print("  APPLICATION 2: COMPLEXITY GROWTH UNDER FUNCTORIAL TRANSFER")
    print("=" * 70)
    print()
    print("  The Euler polynomial of Sym^n has degree n+1.")
    print("  Circuit depth lower bound: depth ≥ ⌈log₂(n+1)⌉")
    print()
    print(f"  {'n':>4} | {'Degree':>6} | {'Depth LB':>8} | {'#Roots':>6} | {'Complexity':>10}")
    print("  " + "-" * 45)

    for n in range(1, max_n + 1):
        degree = n + 1
        depth_lb = int(np.ceil(np.log2(degree))) if degree > 1 else 0
        num_roots = n + 1
        # Total multiplicative complexity: need n multiplications to build product
        mul_complexity = n
        print(f"  {n:>4} | {degree:>6} | {depth_lb:>8} | {num_roots:>6} | {mul_complexity:>10}")


# ─── Application 3: Spectral Statistics of Self-Dual Transfer ────────────────

def spectral_statistics(alpha_vals: List[float], n_vals: List[int]):
    """
    Analyze the spectral statistics (root distribution on the unit circle)
    for self-dual transfers β = α⁻¹.

    For unitary parameters (|α| = 1), the roots lie on the unit circle
    and their spacing statistics connect to random matrix theory.
    """
    print("\n" + "=" * 70)
    print("  APPLICATION 3: SPECTRAL STATISTICS OF SELF-DUAL TRANSFER")
    print("=" * 70)
    print()

    for alpha_val in alpha_vals:
        beta_val = 1.0 / alpha_val
        print(f"  α = {alpha_val}, β = {beta_val:.4f}")

        for n in n_vals:
            roots = symm_pow_roots(n, alpha_val, beta_val)
            root_mags = [abs(r) for r in roots]
            log_roots = [np.log(abs(r)) for r in roots if abs(r) > 0]

            # Check palindromic structure of magnitudes
            mags_sorted = sorted(root_mags)
            is_symmetric = all(
                abs(mags_sorted[i] * mags_sorted[-(i+1)] - 1.0) < 1e-10
                for i in range(len(mags_sorted) // 2)
            )

            coeffs = symm_pow_euler_coeffs(n, alpha_val, beta_val)
            abs_coeffs = np.abs(coeffs)

            print(f"    Sym^{n}: roots ∈ [{min(root_mags):.4f}, {max(root_mags):.4f}]"
                  f"  mag-symmetric: {'✓' if is_symmetric else '✗'}"
                  f"  coeff range: [{min(abs_coeffs):.2f}, {max(abs_coeffs):.2f}]")
        print()


# ─── Application 4: Representation Growth ────────────────────────────────────

def representation_growth(max_n: int = 15):
    """
    Track how the transferred local data grows with n.

    For a fixed prime p with Satake parameters (α, β), the local datum
    of Sym^n has n+1 roots. The total "representation complexity" grows
    as the sum of absolute values of all roots.
    """
    print("\n" + "=" * 70)
    print("  APPLICATION 4: REPRESENTATION GROWTH")
    print("=" * 70)
    print()

    alpha, beta = 1.5, 0.8
    print(f"  Satake parameters: α = {alpha}, β = {beta}")
    print()
    print(f"  {'n':>4} | {'#Roots':>6} | {'∑|roots|':>10} | {'∏|roots|':>12} | {'Max root':>10}")
    print("  " + "-" * 55)

    for n in range(1, max_n + 1):
        roots = symm_pow_roots(n, alpha, beta)
        abs_roots = [abs(r) for r in roots]
        print(f"  {n:>4} | {len(roots):>6} | {sum(abs_roots):>10.4f} | "
              f"{np.prod(abs_roots):>12.4f} | {max(abs_roots):>10.4f}")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_l_function()
    complexity_growth_analysis()
    spectral_statistics([2.0, 3.0, 1.5], [2, 4, 6, 8])
    representation_growth()

    print("\n" + "=" * 70)
    print("  ALL APPLICATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Langlands functoriality:
Local Euler factors, symmetric power transfer, Hecke recurrences,
and the unimodality conjecture for self-dual coefficients.

Usage: python demo.py
"""

import numpy as np
from numpy.polynomial import polynomial as P
from itertools import product as iprod


# ─── Core Functions ──────────────────────────────────────────────────────────

def symm_pow_roots(n, alpha, beta):
    """Roots of Sym^n(alpha, beta): alpha^(n-i) * beta^i for i=0..n."""
    return [alpha**(n - i) * beta**i for i in range(n + 1)]


def euler_poly_coeffs(roots):
    """
    Compute the polynomial ∏(X - r_i) as a coefficient list [a_0, a_1, ..., a_d].
    Uses iterative multiplication by linear factors.
    """
    poly = np.array([1.0])
    for r in roots:
        # Multiply by (X - r): shift up by 1 and subtract r * current
        poly = np.convolve(poly, np.array([-r, 1.0]))
    return poly


def hecke_trace(alpha, beta, m):
    """Hecke trace t_m = alpha^m + beta^m."""
    return alpha**m + beta**m


def hecke_trace_recurrence(alpha, beta, m):
    """Compute t_m via the recurrence t_{m+2} = (a+b)*t_{m+1} - ab*t_m."""
    if m == 0:
        return 2
    if m == 1:
        return alpha + beta
    s = alpha + beta
    p = alpha * beta
    t_prev, t_curr = 2, s
    for _ in range(m - 1):
        t_prev, t_curr = t_curr, s * t_curr - p * t_prev
    return t_curr


def root_product(n, alpha, beta):
    """∏_{i=0}^{n} alpha^(n-i) * beta^i = (alpha*beta)^{n(n+1)/2}."""
    prod = 1.0
    for i in range(n + 1):
        prod *= alpha**(n - i) * beta**i
    return prod


def is_unimodal(seq):
    """Check if a sequence is unimodal (increases then decreases)."""
    if len(seq) <= 2:
        return True
    increasing = True
    for i in range(1, len(seq)):
        if increasing:
            if seq[i] < seq[i-1]:
                increasing = False
        else:
            if seq[i] > seq[i-1]:
                return False
    return True


def is_log_concave(seq):
    """Check if a positive sequence is log-concave: a_i^2 >= a_{i-1}*a_{i+1}."""
    for i in range(1, len(seq) - 1):
        if seq[i] <= 0:
            return False
        if seq[i]**2 < seq[i-1] * seq[i+1] - 1e-10:
            return False
    return True


# ─── Interactive Demo ────────────────────────────────────────────────────────

def demo_euler_factors():
    """Demonstrate local Euler factor computation for Sym^n."""
    print("=" * 70)
    print("  SYMMETRIC POWER LOCAL EULER FACTORS")
    print("=" * 70)

    alpha, beta = 2.0, 3.0
    print(f"\nSatake parameters: α = {alpha}, β = {beta}")

    for n in range(1, 6):
        roots = symm_pow_roots(n, alpha, beta)
        coeffs = euler_poly_coeffs(roots)
        print(f"\n  Sym^{n}:")
        print(f"    Roots: {[f'{r:.1f}' for r in roots]}")
        print(f"    Euler poly coefficients: {[f'{c:.1f}' for c in coeffs]}")
        print(f"    Degree: {len(coeffs) - 1}")


def demo_determinant():
    """Verify determinant / central character compatibility."""
    print("\n" + "=" * 70)
    print("  DETERMINANT COMPATIBILITY: ∏ roots = (αβ)^{n(n+1)/2}")
    print("=" * 70)

    alpha, beta = 2.0, 3.0
    print(f"\nSatake parameters: α = {alpha}, β = {beta}")

    for n in range(1, 8):
        prod = root_product(n, alpha, beta)
        expected = (alpha * beta) ** (n * (n + 1) // 2)
        match = abs(prod - expected) < 1e-6
        status = "✓" if match else "✗"
        print(f"  n={n}: ∏ roots = {prod:.4e}, (αβ)^{{n(n+1)/2}} = {expected:.4e}  [{status}]")


def demo_hecke_recurrence():
    """Test the Hecke trace recurrence t_{m+2} = (α+β)t_{m+1} - αβ·t_m."""
    print("\n" + "=" * 70)
    print("  HECKE TRACE RECURRENCE")
    print("=" * 70)

    alpha, beta = 2.0, 3.0
    s = alpha + beta
    p = alpha * beta
    print(f"\nSatake parameters: α = {alpha}, β = {beta}")
    print(f"  α + β = {s},  αβ = {p}")
    print(f"\n  {'m':>3} | {'t_m (direct)':>14} | {'t_m (recurrence)':>16} | {'Match':>5}")
    print("  " + "-" * 50)

    for m in range(10):
        direct = hecke_trace(alpha, beta, m)
        recur = hecke_trace_recurrence(alpha, beta, m)
        match = abs(direct - recur) < 1e-8
        status = "✓" if match else "✗"
        print(f"  {m:>3} | {direct:>14.2f} | {recur:>16.2f} | {status:>5}")


def demo_self_duality():
    """Demonstrate root inversion symmetry when β = α⁻¹."""
    print("\n" + "=" * 70)
    print("  SELF-DUALITY: β = α⁻¹ ⟹ ROOTS CLOSED UNDER INVERSION")
    print("=" * 70)

    alpha = 2.0
    beta = 1.0 / alpha
    print(f"\nSatake parameters: α = {alpha}, β = α⁻¹ = {beta}")

    for n in range(1, 7):
        roots = symm_pow_roots(n, alpha, beta)
        inverses = [1.0 / r for r in roots]
        # Check each inverse appears in the root list
        all_closed = True
        for inv in inverses:
            if not any(abs(inv - r) < 1e-10 for r in roots):
                all_closed = False
                break
        status = "✓ CLOSED" if all_closed else "✗ NOT CLOSED"
        print(f"  n={n}: roots = {[f'{r:.4f}' for r in roots]}")
        print(f"         1/roots = {[f'{r:.4f}' for r in inverses]}  [{status}]")


def demo_unimodality_conjecture():
    """Test the unimodality/log-concavity conjecture for self-dual coefficients."""
    print("\n" + "=" * 70)
    print("  CONJECTURE: UNIMODALITY OF |coefficients| FOR β = α⁻¹")
    print("=" * 70)

    test_alphas = [1.1, 1.5, 2.0, 3.0, 5.0, 10.0]
    max_n = 20
    print(f"\nTesting for α ∈ {test_alphas}, n = 1..{max_n}")
    print()

    failures = 0
    for alpha in test_alphas:
        beta = 1.0 / alpha
        all_uni = True
        all_lc = True
        for n in range(1, max_n + 1):
            roots = symm_pow_roots(n, alpha, beta)
            coeffs = euler_poly_coeffs(roots)
            abs_coeffs = [abs(c) for c in coeffs]
            if not is_unimodal(abs_coeffs):
                all_uni = False
                failures += 1
            if not is_log_concave(abs_coeffs):
                all_lc = False
        uni_status = "✓" if all_uni else "✗"
        lc_status = "✓" if all_lc else "✗"
        print(f"  α = {alpha:>5.1f}: Unimodal [{uni_status}]  Log-concave [{lc_status}]")

    if failures == 0:
        print(f"\n  All {len(test_alphas) * max_n} tests PASSED — conjecture holds on this grid.")
    else:
        print(f"\n  {failures} failures detected — conjecture may be FALSE.")


def demo_coefficient_profiles():
    """Show coefficient profiles for self-dual cases."""
    print("\n" + "=" * 70)
    print("  COEFFICIENT PROFILES FOR SELF-DUAL CASES (β = 1/α)")
    print("=" * 70)

    alpha = 2.0
    beta = 1.0 / alpha
    print(f"\nSatake parameters: α = {alpha}, β = {beta}")

    for n in [2, 4, 6, 8]:
        roots = symm_pow_roots(n, alpha, beta)
        coeffs = euler_poly_coeffs(roots)
        abs_coeffs = [abs(c) for c in coeffs]
        print(f"\n  Sym^{n} coefficient magnitudes:")
        for k, c in enumerate(abs_coeffs):
            bar = "█" * int(c / max(abs_coeffs) * 40) if max(abs_coeffs) > 0 else ""
            print(f"    coeff[{k:>2}] = {c:>12.4f}  {bar}")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   LANGLANDS FUNCTORIALITY: LOCAL EULER DATA & SYMMETRIC POWER      ║")
    print("║   TRANSFER — INTERACTIVE DEMONSTRATION                             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_euler_factors()
    demo_determinant()
    demo_hecke_recurrence()
    demo_self_duality()
    demo_unimodality_conjecture()
    demo_coefficient_profiles()

    print("\n" + "=" * 70)
    print("  DEMO COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Coefficient profiles of symmetric power Euler polynomials.

Shows how the coefficient magnitudes of Sym^n Euler polynomials form
unimodal profiles for self-dual parameters (β = α⁻¹), illustrating
the palindromic symmetry proven in the Lean formalization.
"""

import numpy as np
import matplotlib.pyplot as plt


def symm_pow_roots(n, alpha, beta):
    return [alpha**(n - i) * beta**i for i in range(n + 1)]

def euler_poly_from_roots(roots):
    poly = np.array([1.0 + 0j])
    for r in roots:
        poly = np.convolve(poly, np.array([-r, 1.0]))
    return poly

def symm_pow_euler_coeffs(n, alpha, beta):
    return euler_poly_from_roots(symm_pow_roots(n, alpha, beta))


fig, axes = plt.subplots(2, 3, figsize=(14, 9))
fig.suptitle("Symmetric Power Euler Polynomial Coefficients\n"
             r"$\mathrm{Sym}^n(\alpha, \alpha^{-1})$: Self-Dual Case",
             fontsize=14, fontweight='bold')

alpha = 2.0
ns = [2, 4, 6, 8, 10, 12]

for ax, n in zip(axes.flat, ns):
    coeffs = symm_pow_euler_coeffs(n, alpha, 1.0/alpha)
    abs_coeffs = np.abs(coeffs.real)
    indices = np.arange(len(abs_coeffs))

    colors = plt.cm.viridis(abs_coeffs / max(abs_coeffs) if max(abs_coeffs) > 0 else abs_coeffs)
    ax.bar(indices, abs_coeffs, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_title(f"$\\mathrm{{Sym}}^{{{n}}}$  (degree {n+1})", fontsize=11)
    ax.set_xlabel("Coefficient index $k$", fontsize=9)
    ax.set_ylabel("$|a_k|$", fontsize=9)

    # Mark the palindromic symmetry axis
    mid = len(abs_coeffs) / 2 - 0.5
    ax.axvline(mid, color='red', linestyle='--', alpha=0.5, label='Symmetry axis')
    ax.legend(fontsize=7, loc='upper right')

plt.tight_layout()
plt.savefig("coefficient_profiles.png", dpi=150, bbox_inches='tight')
print("Saved coefficient_profiles.png")


#!/usr/bin/env python3
"""
Visualization: Hecke trace sequences and their recurrence structure.

Plots the Hecke trace t_m = α^m + β^m for various Satake parameters,
illustrating the second-order linear recurrence proven in the Lean formalization.
"""

import numpy as np
import matplotlib.pyplot as plt


def hecke_trace_sequence(alpha, beta, length):
    if length <= 0:
        return []
    s = alpha + beta
    p = alpha * beta
    result = [2.0]
    if length == 1:
        return result
    result.append(s)
    for m in range(2, length):
        result.append(s * result[-1] - p * result[-2])
    return result


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Hecke Trace Sequences $t_m = \\alpha^m + \\beta^m$\n"
             "Governed by recurrence: $t_{m+2} = (\\alpha+\\beta)\\,t_{m+1} - \\alpha\\beta\\,t_m$",
             fontsize=13, fontweight='bold')

length = 15

# Panel 1: Real parameters
ax = axes[0]
params = [(2, 3), (1.5, 0.8), (3, 1), (1.1, 0.9)]
for alpha, beta in params:
    traces = hecke_trace_sequence(alpha, beta, length)
    ax.semilogy(range(length), [abs(t) for t in traces], 'o-',
                label=f"α={alpha}, β={beta}", markersize=4)
ax.set_title("Real Parameters", fontsize=11)
ax.set_xlabel("$m$")
ax.set_ylabel("$|t_m|$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Self-dual (β = 1/α)
ax = axes[1]
for alpha in [1.5, 2.0, 3.0, 5.0]:
    beta = 1.0/alpha
    traces = hecke_trace_sequence(alpha, beta, length)
    ax.plot(range(length), traces, 'o-',
            label=f"α={alpha}, β=1/α", markersize=4)
ax.set_title("Self-Dual: $\\beta = \\alpha^{-1}$", fontsize=11)
ax.set_xlabel("$m$")
ax.set_ylabel("$t_m$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Ratio t_{m+1}/t_m → max(|α|, |β|)
ax = axes[2]
for alpha, beta in [(2, 3), (1.5, 0.8), (3, 1)]:
    traces = hecke_trace_sequence(alpha, beta, 25)
    ratios = [abs(traces[m+1] / traces[m]) if abs(traces[m]) > 1e-10 else 0
              for m in range(len(traces)-1)]
    ax.plot(range(len(ratios)), ratios, 'o-',
            label=f"α={alpha}, β={beta}", markersize=3)
    ax.axhline(max(abs(alpha), abs(beta)), linestyle='--', alpha=0.3)
ax.set_title("Ratio $|t_{m+1}/t_m| \\to \\max(|\\alpha|, |\\beta|)$", fontsize=11)
ax.set_xlabel("$m$")
ax.set_ylabel("$|t_{m+1}/t_m|$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("hecke_traces.png", dpi=150, bbox_inches='tight')
print("Saved hecke_traces.png")


#!/usr/bin/env python3
"""
Visualization: Root geometry of symmetric power Euler polynomials.

Shows the multiplicative structure of roots α^{n-i}β^i on a log scale,
and the inversion symmetry for self-dual parameters.
"""

import numpy as np
import matplotlib.pyplot as plt


def symm_pow_roots(n, alpha, beta):
    return [alpha**(n - i) * beta**i for i in range(n + 1)]


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("Root Geometry of Symmetric Power Transfer\n"
             "$\\mathrm{Sym}^n(\\alpha, \\beta)$: roots $= \\alpha^{n-i}\\beta^i$",
             fontsize=13, fontweight='bold')

# Panel 1: Root magnitudes on log scale
ax = axes[0]
alpha, beta = 2.0, 3.0
for n in [2, 4, 6, 8, 10]:
    roots = symm_pow_roots(n, alpha, beta)
    log_roots = [np.log(abs(r)) for r in roots]
    ax.plot(range(n+1), log_roots, 'o-', label=f"$n={n}$", markersize=5)
ax.set_title(f"Root magnitudes ($\\alpha={alpha}, \\beta={beta}$)", fontsize=11)
ax.set_xlabel("Root index $i$")
ax.set_ylabel("$\\ln|\\alpha^{n-i}\\beta^i|$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Self-dual root symmetry
ax = axes[1]
alpha = 2.0
n_vals = [4, 6, 8, 10]
for n in n_vals:
    roots = symm_pow_roots(n, alpha, 1.0/alpha)
    log_roots = [np.log(abs(r)) for r in roots]
    ax.plot(range(n+1), log_roots, 'o-', label=f"$n={n}$", markersize=5)
ax.axhline(0, color='red', linestyle='--', alpha=0.5, label='$|r|=1$')
ax.set_title(f"Self-dual: $\\beta=\\alpha^{{-1}}$ ($\\alpha={alpha}$)", fontsize=11)
ax.set_xlabel("Root index $i$")
ax.set_ylabel("$\\ln|\\alpha^{n-2i}|$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Determinant product growth
ax = axes[2]
alpha_vals = [1.5, 2.0, 3.0]
n_range = range(1, 16)
for alpha in alpha_vals:
    beta = 2.0
    products = [(alpha * beta) ** (n * (n + 1) // 2) for n in n_range]
    ax.semilogy(list(n_range), products, 'o-',
                label=f"$\\alpha={alpha}, \\beta={beta}$", markersize=4)
ax.set_title("Determinant growth: $(\\alpha\\beta)^{n(n+1)/2}$", fontsize=11)
ax.set_xlabel("$n$")
ax.set_ylabel("$\\det(\\mathrm{Sym}^n)$")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("root_geometry.png", dpi=150, bbox_inches='tight')
print("Saved root_geometry.png")
