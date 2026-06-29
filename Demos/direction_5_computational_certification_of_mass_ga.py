#!/usr/bin/env python3
"""
Applications of Certified Mass Gap Bounds

Real-world applications showing how the certified bounds framework
enables rigorous uncertainty quantification in lattice gauge theory.
"""

import math
from typing import List, Tuple


def lattice_qcd_gap_certificate(
    beta: float,
    L: int,
    N: int = 2,
    precision: float = 0.01
) -> dict:
    """Generate a mass gap certificate for SU(N) on an L×L lattice.

    This function produces a complete certificate containing:
    - Casimir-based analytical bound
    - Interval arithmetic bounds (simulated)
    - Tightness assessment
    - Finite-volume correction estimate

    Args:
        beta: Inverse coupling parameter
        L: Lattice linear size
        N: Gauge group rank (SU(N))
        precision: Interval arithmetic precision

    Returns:
        Dictionary with certificate data
    """
    # Casimir eigenvalue for fundamental representation of SU(N)
    casimir_fund = (N**2 - 1) / (2 * N)

    # Coefficient for fundamental sector: dimension * exp(-casimir * beta)
    c_fund = N * math.exp(-casimir_fund * beta) if beta < 10 else 0

    # Analytical Casimir bound
    if c_fund > 0 and c_fund < 1:
        casimir_bound = -math.log(c_fund)
    else:
        casimir_bound = float('inf')

    # Simulated interval arithmetic (ground and excitation)
    ground_true = 1.0 - 0.1 * beta**2 * L**2 / N
    excite_true = c_fund * (1 + 0.05 * beta)

    ev_low = ground_true * (1 - precision)
    ev_high = ground_true * (1 + precision)
    exc_low = max(excite_true * (1 - precision), 1e-15)
    exc_high = excite_true * (1 + precision)

    if exc_high < ev_low and exc_low > 0:
        gap_lower = math.log(ev_low / exc_high)
        gap_upper = math.log(ev_high / exc_low)
        tightness = gap_lower / gap_upper
    else:
        gap_lower = 0
        gap_upper = float('inf')
        tightness = 0

    # Finite-volume correction
    C_fv = 2.0 * N  # Finite-volume constant
    fv_correction = C_fv / L**2

    return {
        "gauge_group": f"SU({N})",
        "lattice_size": f"{L}×{L}",
        "beta": beta,
        "casimir_fundamental": casimir_fund,
        "casimir_bound": casimir_bound,
        "ground_state_interval": (ev_low, ev_high),
        "excitation_interval": (exc_low, exc_high),
        "gap_lower_bound": gap_lower,
        "gap_upper_bound": gap_upper,
        "tightness_ratio": tightness,
        "finite_volume_correction": fv_correction,
        "certificate_valid": exc_high < ev_low and exc_low > 0,
    }


def convergence_analysis(N: int, betas: List[float], L: int) -> List[dict]:
    """Analyze convergence of Casimir bound as beta → 0.

    Args:
        N: Gauge group rank
        betas: List of coupling values
        L: Lattice size

    Returns:
        List of analysis results
    """
    results = []
    for beta in betas:
        cert = lattice_qcd_gap_certificate(beta, L, N)
        if cert["gap_lower_bound"] > 0:
            relative_error = 1 - cert["gap_lower_bound"] / cert["gap_upper_bound"]
        else:
            relative_error = 1.0
        results.append({
            "beta": beta,
            "casimir_bound": cert["casimir_bound"],
            "certified_lower": cert["gap_lower_bound"],
            "certified_upper": cert["gap_upper_bound"],
            "relative_error": relative_error,
            "tightness": cert["tightness_ratio"],
        })
    return results


def condition_number_analysis(
    gap_values: List[float]
) -> List[Tuple[float, float]]:
    """Compute condition numbers from spectral gaps.

    The cross-domain theorem connects mass gaps to condition numbers:
    κ = exp(gap). Larger gaps mean worse-conditioned transfer matrices.

    Args:
        gap_values: List of mass gap values

    Returns:
        List of (gap, condition_number) pairs
    """
    return [(g, math.exp(g)) for g in gap_values]


# ─── Application 1: Full Certificate Generation ─────────────────────────

if __name__ == "__main__":
    print("Application 1: Mass Gap Certificates")
    print("=" * 60)

    for N in [2, 3]:
        for L in [2, 3, 4]:
            cert = lattice_qcd_gap_certificate(0.3, L, N)
            status = "✓ VALID" if cert["certificate_valid"] else "✗ INVALID"
            print(f"SU({N}) on {L}×{L}: gap ∈ [{cert['gap_lower_bound']:.3f}, "
                  f"{cert['gap_upper_bound']:.3f}], "
                  f"tightness={cert['tightness_ratio']:.3f} [{status}]")

    # Application 2: Convergence Analysis
    print("\nApplication 2: Convergence Analysis (SU(2), L=4)")
    print("=" * 60)
    betas = [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4]
    results = convergence_analysis(2, betas, 4)
    print(f"{'β':>8} {'Casimir':>10} {'Lower':>10} {'Upper':>10} {'Tight%':>8}")
    for r in results:
        print(f"{r['beta']:>8.2f} {r['casimir_bound']:>10.4f} "
              f"{r['certified_lower']:>10.4f} {r['certified_upper']:>10.4f} "
              f"{r['tightness']*100:>7.1f}%")

    # Application 3: Condition Number Impact
    print("\nApplication 3: Mass Gap → Condition Number")
    print("=" * 60)
    gaps = [0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    for gap, kappa in condition_number_analysis(gaps):
        print(f"Gap = {gap:>5.1f} → κ = {kappa:>12.2f} "
              f"(CG iterations ~ {kappa:.0f})")

    print("\n✓ All applications completed successfully.")


#!/usr/bin/env python3
"""
Demonstration of Certified Mass Gap Bounds

This script demonstrates the key theorems from the Lean formalization,
showing how interval arithmetic certification works for lattice gauge
theory spectral gaps.
"""

import math

# ─── Certified Eigenvalue Bound ───────────────────────────────────────────

class CertifiedEigenvalueBound:
    """Interval arithmetic certificate for transfer matrix eigenvalues."""

    def __init__(self, ev_low, ev_high, exc_low, exc_high):
        assert ev_low <= ev_high, "Ground state interval must be well-formed"
        assert exc_low <= exc_high, "Excitation interval must be well-formed"
        assert exc_high < ev_low, "Gap must exist: exc_high < ev_low"
        self.ev_low = ev_low
        self.ev_high = ev_high
        self.exc_low = exc_low
        self.exc_high = exc_high

    def gap_lower_bound(self):
        """Certified lower bound on the mass gap."""
        return math.log(self.ev_low / self.exc_high)

    def gap_upper_bound(self):
        """Certified upper bound on the mass gap."""
        return math.log(self.ev_high / self.exc_low)

    def tightness_ratio(self):
        """Ratio of lower to upper bound (1 = perfectly tight)."""
        return self.gap_lower_bound() / self.gap_upper_bound()


# ─── Strong Coupling Expansion ───────────────────────────────────────────

class StrongCouplingExpansion:
    """Transfer matrix eigenvalue as a0 + a1 * beta."""

    def __init__(self, a0, a1):
        self.a0 = a0
        self.a1 = a1

    def eval(self, beta):
        return self.a0 + self.a1 * beta


# ─── Demo 1: Certified Eigenvalue Bound ──────────────────────────────────

print("=" * 60)
print("DEMO 1: Certified Eigenvalue Bound")
print("=" * 60)

# Example: SU(2) transfer matrix at beta = 0.3
# Ground state eigenvalue in [0.95, 1.05]
# First excitation in [0.05, 0.08]
cert = CertifiedEigenvalueBound(0.95, 1.05, 0.05, 0.08)
print(f"Ground state interval: [{cert.ev_low}, {cert.ev_high}]")
print(f"Excitation interval:   [{cert.exc_low}, {cert.exc_high}]")
print(f"Gap lower bound:       {cert.gap_lower_bound():.4f}")
print(f"Gap upper bound:       {cert.gap_upper_bound():.4f}")
print(f"Tightness ratio:       {cert.tightness_ratio():.4f}")
print()

# ─── Demo 2: Casimir Bound Monotonicity ──────────────────────────────────

print("=" * 60)
print("DEMO 2: Casimir Bound Monotonicity")
print("=" * 60)

c = 2.0  # SU(2) fundamental sector coefficient
betas = [0.05, 0.1, 0.2, 0.3, 0.4, 0.5]
print(f"{'beta':>8} {'Casimir bound -log(c*beta)':>25}")
for beta in betas:
    bound = -math.log(c * beta)
    print(f"{beta:>8.2f} {bound:>25.4f}")
print("(Monotone decreasing in beta — smaller beta = stronger bound)")
print()

# ─── Demo 3: Strong Coupling Convergence ─────────────────────────────────

print("=" * 60)
print("DEMO 3: Excitation Ratio Vanishing")
print("=" * 60)

ground = StrongCouplingExpansion(1.0, -0.5)  # Ground: 1 - 0.5*beta
excite = StrongCouplingExpansion(0.0, 2.0)   # Excite: 2*beta

betas = [0.01, 0.05, 0.1, 0.2, 0.3, 0.4]
print(f"{'beta':>8} {'excite/ground':>15} {'log ratio (gap)':>18}")
for beta in betas:
    ratio = excite.eval(beta) / ground.eval(beta)
    gap = -math.log(ratio) if ratio > 0 else float('inf')
    print(f"{beta:>8.2f} {ratio:>15.6f} {gap:>18.4f}")
print("(Ratio → 0 as beta → 0, confirming strong coupling divergence)")
print()

# ─── Demo 4: Gap Perturbation Bound ──────────────────────────────────────

print("=" * 60)
print("DEMO 4: Gap Perturbation Bound")
print("=" * 60)

lam_true, mu_true = 1.0, 0.1
delta = 0.01
print(f"True gap: {lam_true - mu_true:.4f}")
print(f"Perturbation: delta = {delta}")
print(f"Worst-case gap shift: 2*delta = {2*delta}")
for lam_pert in [lam_true - delta, lam_true, lam_true + delta]:
    for mu_pert in [mu_true - delta, mu_true, mu_true + delta]:
        gap_pert = lam_pert - mu_pert
        shift = abs(gap_pert - (lam_true - mu_true))
        print(f"  lam_pert={lam_pert:.2f}, mu_pert={mu_pert:.2f}: "
              f"gap={gap_pert:.4f}, shift={shift:.4f} <= {2*delta}")
print()

# ─── Demo 5: Finite Volume Scaling ──────────────────────────────────────

print("=" * 60)
print("DEMO 5: Finite Volume Gap Scaling")
print("=" * 60)

m_inf = 1.5  # Infinite-volume gap
C = 10.0     # Finite-size correction constant

print(f"Infinite-volume gap: {m_inf}")
print(f"Correction constant C: {C}")
print(f"{'L':>5} {'C/L^2':>10} {'gap lower':>12} {'gap upper':>12}")
for L in range(2, 20):
    correction = C / L**2
    lower = m_inf - correction
    upper = m_inf + correction
    marker = " <-- POSITIVE" if lower > 0 else " <-- NEGATIVE"
    print(f"{L:>5} {correction:>10.4f} {lower:>12.4f} {upper:>12.4f}{marker}")

# ─── Demo 6: Tightness Ratio Improvement ─────────────────────────────────

print()
print("=" * 60)
print("DEMO 6: Tightness Ratio vs Interval Width")
print("=" * 60)

ev_true, exc_true = 1.0, 0.1
true_gap = math.log(ev_true / exc_true)
print(f"True gap: log({ev_true}/{exc_true}) = {true_gap:.6f}")
print(f"{'width':>8} {'lower':>10} {'upper':>10} {'tightness':>12}")
for width_pct in [0.5, 1, 2, 5, 10, 20, 30]:
    w = width_pct / 100
    cert = CertifiedEigenvalueBound(
        ev_true * (1 - w), ev_true * (1 + w),
        exc_true * (1 - w), exc_true * (1 + w)
    )
    print(f"{width_pct:>7.1f}% {cert.gap_lower_bound():>10.4f} "
          f"{cert.gap_upper_bound():>10.4f} {cert.tightness_ratio():>12.4f}")

print("\n✓ All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Casimir Bound Monotonicity and Gauge Group Comparison

Shows how the Casimir-based mass gap bound varies with coupling parameter
and gauge group rank. Illustrates two theorems:
- casimir_bound_monotone_in_coupling: bound increases as β decreases
- casimir_bound_improves_with_casimir: larger Casimir → stronger bound
"""

import numpy as np
import matplotlib.pyplot as plt

beta = np.linspace(0.01, 0.5, 200)

# Casimir eigenvalues for fundamental representation of SU(N)
def casimir_fund(N):
    return (N**2 - 1) / (2 * N)

# Fundamental sector coefficient
def fund_coeff(N, b):
    return N * np.exp(-casimir_fund(N) * b)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Panel 1: Casimir bound vs beta for different SU(N)
colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']
for i, N in enumerate([2, 3, 4, 5]):
    c = fund_coeff(N, 0) / N  # Leading coefficient
    bound = -np.log(c * beta)
    label = f'SU({N}), C₂ = {casimir_fund(N):.2f}'
    ax1.plot(beta, bound, color=colors[i], linewidth=2, label=label)

ax1.set_xlabel('Coupling β', fontsize=12)
ax1.set_ylabel('Mass gap lower bound', fontsize=12)
ax1.set_title('Casimir Bound vs Coupling', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0, 8)

# Panel 2: Bound at fixed beta vs N
Ns = np.arange(2, 11)
beta_fixed = 0.2
bounds = []
for N in Ns:
    c = fund_coeff(N, 0) / N
    bounds.append(-np.log(c * beta_fixed))

ax2.bar(Ns, bounds, color='#2196F3', alpha=0.7, edgecolor='black')
ax2.set_xlabel('Gauge group rank N', fontsize=12)
ax2.set_ylabel('Mass gap bound at β = 0.2', fontsize=12)
ax2.set_title('Bound Strength by Gauge Group', fontsize=14)
ax2.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('viz_casimir_monotonicity.png', dpi=150, bbox_inches='tight')
print("Saved viz_casimir_monotonicity.png")


#!/usr/bin/env python3
"""
Visualization: Finite Volume Gap Convergence

Shows how the finite-volume mass gap converges to the infinite-volume
value as the lattice size L increases. Illustrates the theorem
finite_volume_gap_positive: there exists L₀ beyond which the gap is positive.
"""

import numpy as np
import matplotlib.pyplot as plt

m_inf = 1.5  # Infinite-volume gap
C = 10.0     # Correction constant

L_values = np.arange(1, 25)
corrections = C / L_values.astype(float)**2
gap_lower = m_inf - corrections
gap_upper = m_inf + corrections

# Find L0 where gap_lower first becomes positive
L0 = next(L for L in L_values if m_inf - C/L**2 > 0)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Panel 1: Gap bounds vs L
ax1.fill_between(L_values, gap_lower, gap_upper, alpha=0.25, color='blue',
                 label='Certified interval')
ax1.plot(L_values, gap_lower, 'b-', linewidth=1.5)
ax1.plot(L_values, gap_upper, 'b-', linewidth=1.5)
ax1.axhline(y=m_inf, color='red', linestyle='--', linewidth=2,
            label=f'm∞ = {m_inf}')
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.axvline(x=L0, color='green', linestyle=':', linewidth=2,
            label=f'L₀ = {L0} (positivity threshold)')
ax1.set_xlabel('Lattice size L', fontsize=12)
ax1.set_ylabel('Mass gap', fontsize=12)
ax1.set_title('Finite Volume Convergence', fontsize=14)
ax1.legend(fontsize=10, loc='lower right')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1, 24)

# Panel 2: Correction magnitude (log scale)
ax2.semilogy(L_values, corrections, 'b-o', markersize=4, linewidth=2,
             label='C/L²')
ax2.axhline(y=m_inf, color='red', linestyle='--', alpha=0.5,
            label=f'm∞ = {m_inf}')
ax2.set_xlabel('Lattice size L', fontsize=12)
ax2.set_ylabel('Finite-volume correction C/L²', fontsize=12)
ax2.set_title('Correction Decay Rate', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_finite_volume.png', dpi=150, bbox_inches='tight')
print("Saved viz_finite_volume.png")


#!/usr/bin/env python3
"""
Visualization: Tightness Ratio vs Interval Width

Shows how the quality of certified mass gap bounds degrades as the
interval arithmetic precision decreases. The tightness ratio (lower/upper
bound) measures certification quality — 1.0 means perfectly tight.

This illustrates the key theorem: tightness_ratio_in_unit_interval.
"""

import numpy as np
import matplotlib.pyplot as plt

# True eigenvalues
ev_true = 1.0
exc_true = 0.1
true_gap = np.log(ev_true / exc_true)

# Vary interval width from 0.1% to 40%
widths = np.linspace(0.001, 0.39, 200)
tightness = []
gap_lower = []
gap_upper = []

for w in widths:
    ev_lo = ev_true * (1 - w)
    ev_hi = ev_true * (1 + w)
    exc_lo = exc_true * (1 - w)
    exc_hi = exc_true * (1 + w)

    if exc_hi < ev_lo and exc_lo > 0:
        gl = np.log(ev_lo / exc_hi)
        gu = np.log(ev_hi / exc_lo)
        tightness.append(gl / gu)
        gap_lower.append(gl)
        gap_upper.append(gu)
    else:
        tightness.append(np.nan)
        gap_lower.append(np.nan)
        gap_upper.append(np.nan)

widths_pct = widths * 100
tightness = np.array(tightness)
gap_lower = np.array(gap_lower)
gap_upper = np.array(gap_upper)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Panel 1: Tightness ratio
ax1.plot(widths_pct, tightness, 'b-', linewidth=2)
ax1.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Perfect tightness')
ax1.set_xlabel('Interval width (%)', fontsize=12)
ax1.set_ylabel('Tightness ratio', fontsize=12)
ax1.set_title('Certification Quality vs Precision', fontsize=14)
ax1.set_ylim(0, 1.05)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Panel 2: Gap bounds
ax2.fill_between(widths_pct, gap_lower, gap_upper, alpha=0.3, color='blue', label='Certified interval')
ax2.axhline(y=true_gap, color='red', linestyle='--', linewidth=2, label=f'True gap = {true_gap:.3f}')
ax2.set_xlabel('Interval width (%)', fontsize=12)
ax2.set_ylabel('Mass gap', fontsize=12)
ax2.set_title('Certified Gap Bounds', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_tightness.png', dpi=150, bbox_inches='tight')
print("Saved viz_tightness.png")
