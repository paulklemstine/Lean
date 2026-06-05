"""
Graded Probability Measures: Interactive Demonstrations

Demonstrates the key properties of GPMs:
1. Tie-breaking refinement
2. Finite additivity
3. Complementary antisymmetry
4. Convex combinations
5. The impossibility of uniform infinitesimal indifference
"""

from fractions import Fraction
from typing import List, Tuple

# ============================================================
# Core GPM implementation
# ============================================================

class GradedPMF:
    """A Graded Probability Mass Function on {0, 1, ..., n-1}."""

    def __init__(self, std: List[float], inf: List[float]):
        assert len(std) == len(inf), "std and inf must have same length"
        assert all(s >= 0 for s in std), f"std must be nonneg: {std}"
        assert abs(sum(std) - 1.0) < 1e-10, f"std must sum to 1, got {sum(std)}"
        assert abs(sum(inf)) < 1e-10, f"inf must sum to 0, got {sum(inf)}"
        for i in range(len(std)):
            if std[i] == 0:
                assert inf[i] >= -1e-10, f"graded_pos violated at {i}"
        self.n = len(std)
        self.std = std
        self.inf = inf

    def lex_val(self, i: int) -> Tuple[float, float]:
        """Lexicographic probability of outcome i."""
        return (self.std[i], self.inf[i])

    def lex_prob(self, S: set) -> Tuple[float, float]:
        """Graded probability of subset S."""
        return (sum(self.std[i] for i in S), sum(self.inf[i] for i in S))

    def std_prob(self, S: set) -> float:
        return sum(self.std[i] for i in S)

    def inf_prob(self, S: set) -> float:
        return sum(self.inf[i] for i in S)

    def ties_broken(self) -> bool:
        """Check if all outcomes have distinct graded probabilities."""
        vals = [self.lex_val(i) for i in range(self.n)]
        return len(set(vals)) == len(vals)

    def __repr__(self):
        lines = [f"GradedPMF(n={self.n})"]
        for i in range(self.n):
            lines.append(f"  [{i}]: {self.std[i]:.6f} + ε·{self.inf[i]:.6f}")
        return "\n".join(lines)


def tiebreaking_refinement(p: List[float]) -> GradedPMF:
    """Construct a GPM that refines p and breaks all ties.

    Uses the construction: inf[i] = i - (n-1)/2 (centered linear).
    This sums to 0 and is injective.
    """
    n = len(p)
    if n <= 1:
        return GradedPMF(p, [0.0] * n)

    # Raw corrections: distinct values summing to 0
    raw = [i - (n - 1) / 2.0 for i in range(n)]
    # Scale down to be "infinitesimal" relative to probability differences
    scale = 0.001  # Conceptually ε
    inf_vals = [scale * r for r in raw]

    # Verify zero-sum
    total = sum(inf_vals)
    inf_vals[-1] -= total  # Correct floating point drift

    return GradedPMF(p, inf_vals)


def convex_combination(mu: GradedPMF, nu: GradedPMF, t: float) -> GradedPMF:
    """Compute (1-t)*mu + t*nu."""
    assert mu.n == nu.n
    assert 0 <= t <= 1
    std = [(1 - t) * mu.std[i] + t * nu.std[i] for i in range(mu.n)]
    inf = [(1 - t) * mu.inf[i] + t * nu.inf[i] for i in range(mu.n)]
    return GradedPMF(std, inf)


# ============================================================
# Demonstrations
# ============================================================

def demo_tiebreaking():
    """Demo 1: Tie-breaking refinement of a uniform distribution."""
    print("=" * 60)
    print("DEMO 1: Tie-Breaking Refinement")
    print("=" * 60)

    n = 5
    p = [1.0 / n] * n
    print(f"\nStandard uniform distribution on Fin {n}:")
    for i in range(n):
        print(f"  p[{i}] = {p[i]:.4f}")
    print(f"  All equal → {len(set(p))} distinct values (ties!)")

    mu = tiebreaking_refinement(p)
    print(f"\nGraded refinement:")
    print(mu)
    print(f"\n  Ties broken: {mu.ties_broken()}")
    print(f"  Num distinct values: {len(set(mu.lex_val(i) for i in range(n)))}")

    # Ranking
    ranking = sorted(range(n), key=lambda i: mu.lex_val(i), reverse=True)
    print(f"\n  Lexicographic ranking (most to least likely): {ranking}")


def demo_finite_additivity():
    """Demo 2: Finite additivity of graded probability."""
    print("\n" + "=" * 60)
    print("DEMO 2: Finite Additivity")
    print("=" * 60)

    mu = GradedPMF([0.5, 0.25, 0.25], [0.1, -0.05, -0.05])
    S = {0}
    T = {1, 2}

    print(f"\nGPM: {mu}")
    print(f"\nS = {S}, T = {T}")
    print(f"  lexProb(S) = {mu.lex_prob(S)}")
    print(f"  lexProb(T) = {mu.lex_prob(T)}")
    print(f"  lexProb(S∪T) = {mu.lex_prob(S | T)}")

    lp_s = mu.lex_prob(S)
    lp_t = mu.lex_prob(T)
    lp_union = mu.lex_prob(S | T)
    expected = (lp_s[0] + lp_t[0], lp_s[1] + lp_t[1])
    print(f"\n  Additivity check: {lp_union} == {expected}? {abs(lp_union[0] - expected[0]) < 1e-10 and abs(lp_union[1] - expected[1]) < 1e-10}")


def demo_complement_antisymmetry():
    """Demo 3: infProb(Sᶜ) = -infProb(S)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Complementary Antisymmetry")
    print("=" * 60)

    mu = GradedPMF([0.3, 0.3, 0.2, 0.2], [0.5, -0.3, 0.1, -0.3])
    S = {0, 2}
    Sc = {1, 3}

    print(f"\nGPM: {mu}")
    print(f"\nS = {S}, Sᶜ = {Sc}")
    print(f"  infProb(S)  = {mu.inf_prob(S):.6f}")
    print(f"  infProb(Sᶜ) = {mu.inf_prob(Sc):.6f}")
    print(f"  Sum = {mu.inf_prob(S) + mu.inf_prob(Sc):.10f} (should be 0)")
    print(f"  infProb(Sᶜ) = -infProb(S)? {abs(mu.inf_prob(Sc) + mu.inf_prob(S)) < 1e-10}")


def demo_no_uniform_correction():
    """Demo 4: Impossibility of uniform infinitesimal indifference."""
    print("\n" + "=" * 60)
    print("DEMO 4: Impossibility of Uniform Infinitesimal Indifference")
    print("=" * 60)

    for n in [2, 3, 5, 10]:
        for c in [0.1, -0.5, 0.0]:
            total = n * c
            print(f"  n={n}, c={c}: Σc = {total:.4f} {'= 0 ✓' if abs(total) < 1e-10 else '≠ 0 ✗'}")
    print("\n  Only c=0 gives Σc = 0, confirming the theorem.")


def demo_convexity():
    """Demo 5: Convex combination of GPMs."""
    print("\n" + "=" * 60)
    print("DEMO 5: Convexity of GPM Space")
    print("=" * 60)

    mu = GradedPMF([0.5, 0.3, 0.2], [0.2, -0.1, -0.1])
    nu = GradedPMF([0.4, 0.4, 0.2], [-0.1, 0.2, -0.1])

    print(f"\nμ = {mu}")
    print(f"\nν = {nu}")

    for t in [0.0, 0.25, 0.5, 0.75, 1.0]:
        mix = convex_combination(mu, nu, t)
        print(f"\n  t={t:.2f}: std={[round(x, 4) for x in mix.std]}, "
              f"inf={[round(x, 4) for x in mix.inf]}, "
              f"Σstd={sum(mix.std):.4f}, Σinf={sum(mix.inf):.10f}")


if __name__ == "__main__":
    demo_tiebreaking()
    demo_finite_additivity()
    demo_complement_antisymmetry()
    demo_no_uniform_correction()
    demo_convexity()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


"""
Visualization: Graded Probability Measures

Creates three visualizations:
1. Standard vs Graded probability comparison
2. Convexity of GPM space (mixing path)
3. Infinitesimal correction antisymmetry
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def construct_tiebreaking_gpm(p):
    n = len(p)
    if n <= 1:
        return list(p), [0.0] * n
    mean = (n - 1) / 2.0
    raw = [i - mean for i in range(n)]
    scale = 0.001
    inf_vals = [scale * r for r in raw]
    drift = sum(inf_vals)
    inf_vals[-1] -= drift
    return list(p), inf_vals

def plot_standard_vs_graded():
    """Plot 1: Standard vs Graded probability comparison."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    n = 6
    p = [1/6] * n
    std, inf_vals = construct_tiebreaking_gpm(p)

    # Standard probability
    ax = axes[0]
    colors = ['#4C72B0'] * n
    ax.bar(range(n), p, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_title('Standard Probability\n(All outcomes indistinguishable)', fontsize=13)
    ax.set_xlabel('Outcome')
    ax.set_ylabel('Probability')
    ax.set_ylim(0, 0.25)
    ax.set_xticks(range(n))
    ax.axhline(y=1/6, color='red', linestyle='--', alpha=0.5, label='p = 1/6')
    ax.legend()

    # Graded probability
    ax = axes[1]
    graded = [s + 100 * i for s, i in zip(std, inf_vals)]  # Amplify ε for visibility
    colors_graded = plt.cm.viridis(np.linspace(0.2, 0.8, n))
    bars = ax.bar(range(n), graded, color=colors_graded, edgecolor='black', linewidth=0.5)
    ax.set_title('Graded Probability (×100ε amplified)\n(All outcomes distinguishable)', fontsize=13)
    ax.set_xlabel('Outcome')
    ax.set_ylabel('Probability + 100ε·correction')
    ax.set_xticks(range(n))
    ax.axhline(y=1/6, color='red', linestyle='--', alpha=0.5, label='std part = 1/6')
    ax.legend()

    for i, bar in enumerate(bars):
        ax.annotate(f'ε·{inf_vals[i]:.4f}', xy=(bar.get_x() + bar.get_width()/2, bar.get_height()),
                    xytext=(0, 5), textcoords='offset points', ha='center', fontsize=8)

    plt.suptitle('Graded Probability Measures: Breaking the Tyranny of Equiprobability',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_standard_vs_graded.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_standard_vs_graded.png")


def plot_convex_path():
    """Plot 2: Mixing path between two GPMs."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n = 3
    mu_std = [0.5, 0.3, 0.2]
    mu_inf = [0.2, -0.1, -0.1]
    nu_std = [0.3, 0.4, 0.3]
    nu_inf = [-0.1, 0.15, -0.05]

    ts = np.linspace(0, 1, 50)
    for i in range(n):
        stds = [(1-t)*mu_std[i] + t*nu_std[i] for t in ts]
        infs = [(1-t)*mu_inf[i] + t*nu_inf[i] for t in ts]
        ax.plot(ts, stds, linewidth=2, label=f'std[{i}]')
        ax.plot(ts, infs, linewidth=1.5, linestyle='--', alpha=0.7, label=f'inf[{i}]')

    ax.set_xlabel('Mixing parameter t', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Convex Combination of GPMs: (1-t)·μ + t·ν', fontsize=14, fontweight='bold')
    ax.legend(ncol=2, fontsize=9)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_convex_path.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_convex_path.png")


def plot_complement_antisymmetry():
    """Plot 3: Infinitesimal correction antisymmetry for all subsets."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n = 4
    inf_vals = [0.3, -0.1, 0.2, -0.4]

    # Generate all subsets and their complements
    subsets = []
    inf_S = []
    inf_Sc = []
    labels = []

    for mask in range(2**n):
        S = {i for i in range(n) if mask & (1 << i)}
        Sc = set(range(n)) - S
        s_inf = sum(inf_vals[i] for i in S)
        sc_inf = sum(inf_vals[i] for i in Sc)
        subsets.append((S, Sc))
        inf_S.append(s_inf)
        inf_Sc.append(sc_inf)
        labels.append(str(S) if S else '∅')

    x = np.arange(len(subsets))
    width = 0.35

    bars1 = ax.bar(x - width/2, inf_S, width, label='infProb(S)', color='#4C72B0', edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(x + width/2, inf_Sc, width, label='infProb(Sᶜ)', color='#DD8452', edgecolor='black', linewidth=0.5)

    ax.set_xlabel('Subset S', fontsize=12)
    ax.set_ylabel('Infinitesimal Probability', fontsize=12)
    ax.set_title('Complementary Antisymmetry: infProb(Sᶜ) = −infProb(S)', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.legend()
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.grid(alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_complement_antisymmetry.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_complement_antisymmetry.png")


if __name__ == '__main__':
    plot_standard_vs_graded()
    plot_convex_path()
    plot_complement_antisymmetry()
    print("\nAll visualizations generated.")
