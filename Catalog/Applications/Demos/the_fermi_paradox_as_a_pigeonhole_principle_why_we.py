#!/usr/bin/env python3
"""
Sparse Occupation Theory — Numerical Demonstrations

Demonstrates the mathematical framework connecting the Fermi Paradox
to the anti-pigeonhole principle via Sparse Occupation Systems.
"""

import math
from typing import NamedTuple


class DrakeSystem(NamedTuple):
    """Drake equation parameters."""
    R_star: float    # Star formation rate (per year)
    f_p: float       # Fraction with planets
    n_e: float       # Habitable planets per star
    f_l: float       # Fraction developing life
    f_i: float       # Fraction developing intelligence
    f_c: float       # Fraction developing technology
    L: float         # Longevity of civilization (years)

    def per_star_prob(self) -> float:
        """Per-star probability (product of all factors, normalized)."""
        return self.f_p * self.n_e * self.f_l * self.f_i * self.f_c

    def expected_civs(self, galaxy_lifetime: float = 1.0) -> float:
        """Expected number of simultaneously detectable civilizations."""
        return self.R_star * self.per_star_prob() * self.L

    def factors(self) -> list[float]:
        """All multiplicative factors."""
        return [self.f_p, self.n_e, self.f_l, self.f_i, self.f_c]


class SparseOccupation(NamedTuple):
    """Sparse Occupation System."""
    num_slots: int
    occ_prob: float

    def expected_occ(self) -> float:
        return self.num_slots * self.occ_prob

    def silence_prob(self) -> float:
        return (1 - self.occ_prob) ** self.num_slots

    def contact_prob(self) -> float:
        return 1 - self.silence_prob()

    def is_sparse(self) -> bool:
        return self.expected_occ() < 1

    def bernoulli_lower_bound(self) -> float:
        """Lower bound on silence prob: 1 - np."""
        return max(0, 1 - self.expected_occ())


def demo_drake_estimates():
    """Compare pessimistic and optimistic Drake estimates."""
    print("=" * 70)
    print("DEMO 1: Drake Equation Parameter Sweep")
    print("=" * 70)

    pessimistic = DrakeSystem(
        R_star=1.5, f_p=0.5, n_e=0.01, f_l=0.01, f_i=0.01, f_c=0.01, L=100
    )
    moderate = DrakeSystem(
        R_star=2.0, f_p=0.8, n_e=0.1, f_l=0.1, f_i=0.1, f_c=0.1, L=10000
    )
    optimistic = DrakeSystem(
        R_star=3.0, f_p=1.0, n_e=0.4, f_l=1.0, f_i=0.5, f_c=0.5, L=1e9
    )

    for name, drake in [("Pessimistic", pessimistic), ("Moderate", moderate),
                        ("Optimistic", optimistic)]:
        N = drake.expected_civs()
        psp = drake.per_star_prob()
        print(f"\n{name} estimate:")
        print(f"  Per-star prob: {psp:.2e}")
        print(f"  Expected civs: {N:.2e}")
        print(f"  Sparse regime: {'YES' if N < 1 else 'NO'}")
        if N < 1:
            print(f"  Silence prob ≥ {1 - N:.10f}")


def demo_bottleneck():
    """Demonstrate the bottleneck theorem."""
    print("\n" + "=" * 70)
    print("DEMO 2: Bottleneck Theorem")
    print("=" * 70)

    n_planets = 10**10  # ~10 billion habitable planets
    threshold = 1.0 / n_planets
    print(f"\nWith {n_planets:.0e} habitable planets:")
    print(f"Bottleneck threshold: any factor < {threshold:.2e} => silence")

    # Show how each factor being small forces silence
    factors = {
        "f_l (life)": [1e-5, 1e-10, 1e-15, 1e-20],
        "f_i (intelligence)": [1e-5, 1e-10, 1e-15, 1e-20],
        "f_c (technology)": [1e-5, 1e-10, 1e-15, 1e-20],
    }

    for factor_name, values in factors.items():
        print(f"\n  {factor_name}:")
        for v in values:
            is_bottleneck = v < threshold
            print(f"    {v:.0e} -> bottleneck: {is_bottleneck}")


def demo_silence_probability():
    """Demonstrate silence probability calculations."""
    print("\n" + "=" * 70)
    print("DEMO 3: Silence Probability vs Expected Occupancy")
    print("=" * 70)

    print(f"\n{'λ (expected)':<15} {'P(silence)':<15} {'P(contact)':<15} "
          f"{'Bernoulli LB':<15} {'Sparse?':<10}")
    print("-" * 70)

    lambdas = [0.001, 0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    n = 10**6  # large n for Poisson approximation

    for lam in lambdas:
        p = lam / n
        s = SparseOccupation(n, p)
        poisson_silence = math.exp(-lam)  # Poisson limit

        print(f"{lam:<15.3f} {s.silence_prob():<15.6f} {s.contact_prob():<15.6f} "
              f"{s.bernoulli_lower_bound():<15.6f} {'YES' if s.is_sparse() else 'NO':<10}")


def demo_birthday_bound():
    """Demonstrate the birthday/anti-pigeonhole bound."""
    print("\n" + "=" * 70)
    print("DEMO 4: Birthday Problem (Quantitative Anti-Pigeonhole)")
    print("=" * 70)

    n = 365  # slots
    print(f"\n  Slots (n={n}):")
    print(f"  {'k (items)':<12} {'P(no collision)':<20} {'P(collision)':<20}")
    print("  " + "-" * 50)

    for k in [2, 5, 10, 15, 20, 23, 30, 50]:
        prob = 1.0
        for i in range(k):
            prob *= (1 - i / n)
        print(f"  {k:<12} {prob:<20.6f} {1-prob:<20.6f}")


def demo_critical_threshold():
    """Compute the critical Drake factor for uniform factors."""
    print("\n" + "=" * 70)
    print("DEMO 5: Critical Threshold (Falsifiable Conjecture)")
    print("=" * 70)

    k = 7  # Drake factors
    n = 10**10  # habitable planets

    f_c = n ** (-1.0 / k)
    print(f"\n  For k={k} identical factors and n={n:.0e} planets:")
    print(f"  Critical factor f_c = n^(-1/k) = {f_c:.6f}")
    print(f"  Verification: n × f_c^k = {n * f_c**k:.6f} (should be ≈ 1)")
    print(f"\n  Interpretation: if the geometric mean of Drake factors")
    print(f"  exceeds {f_c:.4f} (~{f_c*100:.2f}%), we expect ≥ 1 civilization.")
    print(f"  Our silence constrains the geometric mean below this threshold.")


def demo_monotonicity():
    """Demonstrate monotonicity of silence probability."""
    print("\n" + "=" * 70)
    print("DEMO 6: Monotonicity of Silence")
    print("=" * 70)

    p = 0.001
    print(f"\n  Fixed p = {p}:")
    print(f"  {'n (slots)':<12} {'Silence prob':<15} {'Expected occ':<15}")
    print("  " + "-" * 40)
    for n in [10, 100, 500, 1000, 5000, 10000]:
        s = SparseOccupation(n, p)
        print(f"  {n:<12} {s.silence_prob():<15.6f} {s.expected_occ():<15.3f}")

    n = 1000
    print(f"\n  Fixed n = {n}:")
    print(f"  {'p (prob)':<12} {'Silence prob':<15} {'Expected occ':<15}")
    print("  " + "-" * 40)
    for p in [0.0001, 0.0005, 0.001, 0.005, 0.01, 0.05]:
        s = SparseOccupation(n, p)
        print(f"  {p:<12.4f} {s.silence_prob():<15.6f} {s.expected_occ():<15.3f}")


if __name__ == "__main__":
    demo_drake_estimates()
    demo_bottleneck()
    demo_silence_probability()
    demo_birthday_bound()
    demo_critical_threshold()
    demo_monotonicity()
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Drake Factor Heatmap

Shows how the expected number of civilizations varies as a function
of two Drake factors, with the silence boundary (N=1) highlighted.
"""

import math

def plot_drake_heatmap():
    """Generate the Drake factor heatmap."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping plot")
        return

    # Fix all factors except f_l (life) and f_i (intelligence)
    R_star = 2.0
    f_p = 0.8
    n_e = 0.1
    f_c = 0.1
    L = 10000  # years

    # Create grid
    f_l_range = np.logspace(-6, 0, 200)
    f_i_range = np.logspace(-6, 0, 200)
    F_L, F_I = np.meshgrid(f_l_range, f_i_range)

    # Compute expected civilizations
    N = R_star * f_p * n_e * F_L * F_I * f_c * L

    fig, ax = plt.subplots(figsize=(10, 8))

    # Heatmap
    im = ax.pcolormesh(f_l_range, f_i_range, np.log10(N),
                       cmap='RdYlBu_r', shading='auto', vmin=-6, vmax=6)
    plt.colorbar(im, ax=ax, label='$\\log_{10}(N)$ expected civilizations')

    # Silence boundary N = 1
    ax.contour(f_l_range, f_i_range, N, levels=[1],
               colors='white', linewidths=3, linestyles='--')
    ax.contour(f_l_range, f_i_range, N, levels=[0.01, 0.1, 10, 100],
               colors='gray', linewidths=1, linestyles=':')

    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.set_xlabel('$f_\\ell$ (probability of life)', fontsize=12)
    ax.set_ylabel('$f_i$ (probability of intelligence)', fontsize=12)
    ax.set_title(f'Drake Equation: Silence Region\n'
                 f'($R_*$={R_star}, $f_p$={f_p}, $n_e$={n_e}, '
                 f'$f_c$={f_c}, L={L}yr)', fontsize=14)

    # Annotate regions
    ax.text(1e-5, 1e-1, 'SILENCE\n(N < 1)', fontsize=14,
            color='white', ha='center', va='center', fontweight='bold')
    ax.text(1e-1, 1e-1, 'CONTACT\n(N > 1)', fontsize=14,
            color='black', ha='center', va='center', fontweight='bold')

    plt.tight_layout()
    plt.savefig('drake_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved drake_heatmap.png")


if __name__ == "__main__":
    plot_drake_heatmap()


#!/usr/bin/env python3
"""
Visualization: The Silence Landscape

Shows the silence probability as a function of expected occupancy λ = np,
comparing the exact value, Bernoulli bound, and Poisson approximation.
"""

import math

def compute_silence_data():
    """Compute silence probability curves."""
    n = 10000  # large n for smooth curves
    lambdas = []
    exact_vals = []
    bernoulli_vals = []
    poisson_vals = []

    for i in range(1, 1001):
        lam = i * 0.01  # λ from 0.01 to 10
        p = lam / n
        if p > 1:
            break
        lambdas.append(lam)
        exact_vals.append((1 - p) ** n)
        bernoulli_vals.append(max(0, 1 - lam))
        poisson_vals.append(math.exp(-lam))

    return lambdas, exact_vals, bernoulli_vals, poisson_vals


def plot_silence_landscape():
    """Generate the silence landscape plot."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping plot")
        return

    lambdas, exact, bernoulli, poisson = compute_silence_data()

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Silence probability
    ax1.plot(lambdas, exact, 'b-', linewidth=2, label='Exact: $(1-\\lambda/n)^n$')
    ax1.plot(lambdas, poisson, 'r--', linewidth=2, label='Poisson: $e^{-\\lambda}$')
    ax1.plot(lambdas, bernoulli, 'g:', linewidth=2, label='Bernoulli: $1-\\lambda$')
    ax1.axvline(x=1, color='gray', linestyle='--', alpha=0.5, label='$\\lambda = 1$ (threshold)')
    ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.3)
    ax1.set_xlabel('Expected Occupancy $\\lambda = np$', fontsize=12)
    ax1.set_ylabel('Silence Probability $P(\\text{silence})$', fontsize=12)
    ax1.set_title('The Silence Landscape', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_xlim(0, 5)
    ax1.set_ylim(0, 1)
    ax1.fill_between(lambdas, 0, [e if l < 1 else 0 for l, e in zip(lambdas, exact)],
                     alpha=0.1, color='blue', label='Sparse regime')

    # Right: Contact probability (complement)
    contact_exact = [1 - e for e in exact]
    contact_poisson = [1 - p for p in poisson]
    contact_markov = [min(1, l) for l in lambdas]

    ax2.plot(lambdas, contact_exact, 'b-', linewidth=2, label='Exact: $1-(1-\\lambda/n)^n$')
    ax2.plot(lambdas, contact_poisson, 'r--', linewidth=2, label='Poisson: $1-e^{-\\lambda}$')
    ax2.plot(lambdas, contact_markov, 'g:', linewidth=2, label='Markov bound: $\\min(1, \\lambda)$')
    ax2.axvline(x=1, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('Expected Occupancy $\\lambda = np$', fontsize=12)
    ax2.set_ylabel('Contact Probability $P(\\text{contact})$', fontsize=12)
    ax2.set_title('The Contact Probability', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_xlim(0, 5)
    ax2.set_ylim(0, 1)

    plt.tight_layout()
    plt.savefig('silence_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved silence_landscape.png")


if __name__ == "__main__":
    plot_silence_landscape()
