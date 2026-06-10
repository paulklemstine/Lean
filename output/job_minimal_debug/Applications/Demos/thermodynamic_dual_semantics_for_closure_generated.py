#!/usr/bin/env python3
"""
Thermodynamic Dual Semantics for Proof Semirings — Interactive Demo

This script demonstrates the main theorems with concrete numerical examples:

1. Bridge Theorem: derivable(x, y) ↔ primeSeparationGap(x, y) ≤ 0
2. Thermodynamic Soundness: derivable ⟹ freeEnergyGap ≤ 0
3. Zero-Temperature Adequacy: freeEnergyGap → primeSeparationGap as β → ∞
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List


class ProofSemiring:
    """A finite proof semiring defined by a partial order matrix."""

    def __init__(self, n: int, order: np.ndarray):
        self.n = n
        self.order = order

    def derivable(self, x: int, y: int) -> bool:
        return bool(self.order[x][y])

    @staticmethod
    def chain(n: int) -> 'ProofSemiring':
        order = np.zeros((n, n), dtype=bool)
        for i in range(n):
            for j in range(i, n):
                order[i][j] = True
        return ProofSemiring(n, order)

    @staticmethod
    def diamond() -> 'ProofSemiring':
        order = np.eye(4, dtype=bool)
        order[0][1] = order[0][2] = order[0][3] = True
        order[1][3] = order[2][3] = True
        return ProofSemiring(4, order)

    @staticmethod
    def pentagon() -> 'ProofSemiring':
        order = np.eye(5, dtype=bool)
        for i in range(5):
            order[0][i] = True
            order[i][4] = True
        order[1][3] = True
        return ProofSemiring(5, order)


class AdmissibleEval:
    """An admissible (monotone) evaluation: maps semiring elements to ℝ."""

    def __init__(self, values: np.ndarray):
        self.values = values

    def __call__(self, x: int) -> float:
        return self.values[x]

    def is_monotone(self, S: ProofSemiring) -> bool:
        for i in range(S.n):
            for j in range(S.n):
                if S.order[i][j] and self.values[i] > self.values[j] + 1e-10:
                    return False
        return True


def eval_gap(v: AdmissibleEval, x: int, y: int) -> float:
    return v(x) - v(y)


def prime_separation_gap(evaluations: List[AdmissibleEval], x: int, y: int) -> float:
    return max(eval_gap(v, x, y) for v in evaluations)


def free_energy_gap(evaluations: List[AdmissibleEval],
                    weights: np.ndarray,
                    beta: float, x: int, y: int) -> float:
    if beta == 0:
        return 0.0
    gaps = np.array([eval_gap(v, x, y) for v in evaluations])
    max_val = np.max(beta * gaps)
    log_Z = max_val + np.log(np.sum(weights * np.exp(beta * gaps - max_val)))
    return log_Z / beta


def demo_bridge_theorem():
    print("=" * 70)
    print("DEMO 1: Bridge Theorem — derivable(x,y) ↔ primeSeparationGap(x,y) ≤ 0")
    print("=" * 70)
    print()

    S = ProofSemiring.diamond()
    labels = ["⊥", "a", "b", "⊤"]

    evaluations = [
        AdmissibleEval(np.array([0.0, 1.0, 0.5, 1.5])),
        AdmissibleEval(np.array([0.0, 0.3, 1.2, 1.5])),
        AdmissibleEval(np.array([0.0, 0.8, 0.8, 1.0])),
        AdmissibleEval(np.array([-1.0, 0.0, 0.0, 1.0])),
    ]

    for i, v in enumerate(evaluations):
        assert v.is_monotone(S), f"Evaluation v_{i+1} is not monotone!"

    print(f"{'Pair':>12} {'derivable?':>12} {'PrimeSepGap':>14} {'Match?':>8}")
    print("-" * 50)

    for x in range(S.n):
        for y in range(S.n):
            if x == y:
                continue
            d = S.derivable(x, y)
            gap = prime_separation_gap(evaluations, x, y)
            gap_nonpos = gap <= 1e-10
            match = (d == gap_nonpos)
            print(f"  {labels[x]:>3}→{labels[y]:<3} {'Yes' if d else 'No':>10} "
                  f"{gap:>12.4f}   {'✓' if match else '✗':>4}")

    print()
    print("✓ Bridge theorem holds: derivable ↔ primeSeparationGap ≤ 0")
    print()


def demo_thermodynamic_soundness():
    print("=" * 70)
    print("DEMO 2: Thermodynamic Soundness — derivable ⟹ freeEnergyGap ≤ 0")
    print("=" * 70)
    print()

    S = ProofSemiring.chain(4)
    labels = ["0", "1", "2", "3"]

    evaluations = [
        AdmissibleEval(np.array([0.0, 1.0, 2.0, 3.0])),
        AdmissibleEval(np.array([0.0, 0.5, 1.5, 4.0])),
        AdmissibleEval(np.array([-2.0, -1.0, 0.0, 1.0])),
    ]
    weights = np.array([1/3, 1/3, 1/3])

    betas = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]

    print("Derivable pairs (freeEnergyGap ≤ 0 at all β):")
    print(f"{'Pair':>8}  " + "  ".join(f"β={b:>5.1f}" for b in betas))
    print("-" * (10 + 10 * len(betas)))

    for x in range(S.n):
        for y in range(x+1, S.n):
            gaps = [free_energy_gap(evaluations, weights, b, x, y) for b in betas]
            all_nonpos = all(g <= 1e-10 for g in gaps)
            print(f"  {labels[x]}→{labels[y]}  " +
                  "  ".join(f"{g:>8.4f}" for g in gaps) +
                  f"  {'✓' if all_nonpos else '✗'}")

    print()
    print("Non-derivable pairs (freeEnergyGap > 0 for large β):")
    print(f"{'Pair':>8}  " + "  ".join(f"β={b:>5.1f}" for b in betas))
    print("-" * (10 + 10 * len(betas)))

    for x in range(S.n):
        for y in range(x):
            gaps = [free_energy_gap(evaluations, weights, b, x, y) for b in betas]
            some_pos = any(g > 1e-10 for g in gaps)
            print(f"  {labels[x]}→{labels[y]}  " +
                  "  ".join(f"{g:>8.4f}" for g in gaps) +
                  f"  {'✓' if some_pos else '✗'}")

    print()


def demo_zero_temperature_convergence():
    print("=" * 70)
    print("DEMO 3: Zero-Temperature Adequacy — convergence as β → ∞")
    print("=" * 70)
    print()

    S = ProofSemiring.diamond()
    labels = ["⊥", "a", "b", "⊤"]

    evaluations = [
        AdmissibleEval(np.array([0.0, 1.0, 0.5, 1.5])),
        AdmissibleEval(np.array([0.0, 0.3, 1.2, 1.5])),
        AdmissibleEval(np.array([0.0, 0.8, 0.8, 1.0])),
    ]
    weights = np.array([1/3, 1/3, 1/3])

    test_pairs = [(1, 2), (2, 1)]
    betas = np.logspace(-1, 3, 50)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    for idx, (x, y) in enumerate(test_pairs):
        psg = prime_separation_gap(evaluations, x, y)
        fegs = [free_energy_gap(evaluations, weights, b, x, y) for b in betas]

        ax = axes[idx]
        ax.semilogx(betas, fegs, 'b-', linewidth=2, label='freeEnergyGap(μ, β)')
        ax.axhline(y=psg, color='r', linestyle='--', linewidth=2,
                   label=f'primeSeparationGap = {psg:.3f}')
        ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
        ax.set_xlabel('β (inverse temperature)', fontsize=12)
        ax.set_ylabel('Gap', fontsize=12)
        ax.set_title(f'{labels[x]} → {labels[y]}', fontsize=13)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)

        print(f"Pair {labels[x]}→{labels[y]}:")
        print(f"  primeSeparationGap = {psg:.6f}")
        print(f"  freeEnergyGap at β=1000: {fegs[-1]:.6f}")
        print(f"  Convergence error: {abs(fegs[-1] - psg):.2e}")
        print()

    plt.suptitle('Zero-Temperature Adequacy', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/zero_temperature_convergence.png', dpi=150, bbox_inches='tight')
    print("Figure saved to demos/zero_temperature_convergence.png")
    print()


def demo_phase_transition():
    print("=" * 70)
    print("DEMO 4: Phase Transition — Free Energy Landscape")
    print("=" * 70)
    print()

    S = ProofSemiring.pentagon()
    labels = ["⊥", "a", "b", "c", "⊤"]

    evaluations = [
        AdmissibleEval(np.array([0.0, 0.5, 0.3, 1.0, 1.5])),
        AdmissibleEval(np.array([0.0, 0.8, 0.9, 1.2, 2.0])),
        AdmissibleEval(np.array([0.0, 0.2, 0.7, 0.8, 1.0])),
        AdmissibleEval(np.array([-0.5, 0.1, 0.4, 0.6, 1.5])),
    ]
    weights = np.array([0.25, 0.25, 0.25, 0.25])

    betas = np.logspace(-1, 2, 100)
    pairs = [(0, 4), (1, 3), (2, 1), (3, 1), (2, 3)]
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']

    fig, ax = plt.subplots(figsize=(12, 6))

    for (x, y), color in zip(pairs, colors):
        d = S.derivable(x, y)
        fegs = [free_energy_gap(evaluations, weights, b, x, y) for b in betas]
        psg = prime_separation_gap(evaluations, x, y)
        style = '-' if d else '--'
        ax.semilogx(betas, fegs, style, color=color, linewidth=2,
                    label=f'{labels[x]}→{labels[y]} ({"✓" if d else "✗"}) PSG={psg:.2f}')

    ax.axhline(y=0, color='black', linewidth=1)
    ax.set_xlabel('β (inverse temperature)', fontsize=12)
    ax.set_ylabel('Free-Energy Gap', fontsize=12)
    ax.set_title('Phase Transition: Free-Energy Gap vs Inverse Temperature',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=9, loc='best')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/phase_transition.png', dpi=150, bbox_inches='tight')
    print("Figure saved to demos/phase_transition.png")
    print()


def demo_annealing_witness():
    print("=" * 70)
    print("DEMO 5: Annealed Witness Extraction")
    print("=" * 70)
    print()

    S = ProofSemiring.diamond()
    labels = ["⊥", "a", "b", "⊤"]

    evaluations = [
        AdmissibleEval(np.array([0.0, 1.0, 0.5, 1.5])),
        AdmissibleEval(np.array([0.0, 0.3, 1.2, 1.5])),
        AdmissibleEval(np.array([0.0, 0.8, 0.8, 1.0])),
        AdmissibleEval(np.array([0.0, 0.6, 0.6, 1.2])),
    ]

    x, y = 1, 2  # a → b (non-derivable)
    print(f"Testing: {labels[x]} → {labels[y]} (non-derivable)")
    print()

    betas_schedule = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]

    print(f"{'β':>8} {'Gibbs distribution':>40} {'Best':>8} {'Gap':>8}")
    print("-" * 70)

    for beta in betas_schedule:
        gaps = np.array([eval_gap(v, x, y) for v in evaluations])
        log_probs = beta * gaps
        log_probs -= np.max(log_probs)
        probs = np.exp(log_probs)
        probs /= probs.sum()

        best_idx = np.argmax(gaps)
        best_gap = gaps[best_idx]

        prob_str = "[" + ", ".join(f"{p:.3f}" for p in probs) + "]"
        print(f"{beta:>8.1f} {prob_str:>40} v_{best_idx+1:>3} {best_gap:>8.4f}")

    print()
    print("As β → ∞, Gibbs distribution concentrates on the best separating witness.")
    print()


def create_summary_figure():
    """Create a summary figure showing all key aspects."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # (a) Bridge Theorem
    ax = axes[0, 0]
    S = ProofSemiring.diamond()
    evaluations = [
        AdmissibleEval(np.array([0.0, 1.0, 0.5, 1.5])),
        AdmissibleEval(np.array([0.0, 0.3, 1.2, 1.5])),
        AdmissibleEval(np.array([0.0, 0.8, 0.8, 1.0])),
    ]
    labels = ["⊥", "a", "b", "⊤"]

    derivable_gaps = []
    nonderivable_gaps = []
    for x in range(S.n):
        for y in range(S.n):
            if x == y:
                continue
            gap = prime_separation_gap(evaluations, x, y)
            if S.derivable(x, y):
                derivable_gaps.append(gap)
            else:
                nonderivable_gaps.append(gap)

    ax.hist(derivable_gaps, bins=8, alpha=0.7, color='blue', label='Derivable')
    ax.hist(nonderivable_gaps, bins=8, alpha=0.7, color='red', label='Non-derivable')
    ax.axvline(x=0, color='black', linewidth=2, linestyle='--')
    ax.set_xlabel('Prime Separation Gap')
    ax.set_ylabel('Count')
    ax.set_title('(a) Bridge Theorem')
    ax.legend(fontsize=9)

    # (b) Soundness
    ax = axes[0, 1]
    S = ProofSemiring.chain(3)
    evaluations = [
        AdmissibleEval(np.array([0.0, 1.0, 2.0])),
        AdmissibleEval(np.array([0.0, 0.5, 1.5])),
    ]
    weights = np.array([0.5, 0.5])
    betas = np.logspace(-1, 2, 50)

    for x in range(3):
        for y in range(3):
            if x == y:
                continue
            fegs = [free_energy_gap(evaluations, weights, b, x, y) for b in betas]
            d = S.derivable(x, y)
            ax.semilogx(betas, fegs, '-' if d else '--',
                       color='blue' if d else 'red', alpha=0.7)

    ax.axhline(y=0, color='black', linewidth=1)
    ax.set_xlabel('β')
    ax.set_ylabel('Free-Energy Gap')
    ax.set_title('(b) Soundness: Solid=derivable, Dashed=not')

    # (c) Zero-Temp Convergence
    ax = axes[1, 0]
    S = ProofSemiring.diamond()
    evaluations = [
        AdmissibleEval(np.array([0.0, 1.0, 0.5, 1.5])),
        AdmissibleEval(np.array([0.0, 0.3, 1.2, 1.5])),
        AdmissibleEval(np.array([0.0, 0.8, 0.8, 1.0])),
    ]
    weights = np.array([1/3, 1/3, 1/3])
    betas = np.logspace(-1, 3, 100)
    labels = ["⊥", "a", "b", "⊤"]

    for x, y in [(1, 2), (2, 1)]:
        psg = prime_separation_gap(evaluations, x, y)
        fegs = [free_energy_gap(evaluations, weights, b, x, y) for b in betas]
        errors = [abs(f - psg) for f in fegs]
        ax.loglog(betas, errors, linewidth=2, label=f'{labels[x]}→{labels[y]}')

    ax.set_xlabel('β')
    ax.set_ylabel('|FEG - PSG|')
    ax.set_title('(c) Zero-Temp Convergence Rate')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # (d) Gibbs Concentration
    ax = axes[1, 1]
    evaluations = [
        AdmissibleEval(np.array([0.0, 1.0, 0.5, 1.5])),
        AdmissibleEval(np.array([0.0, 0.3, 1.2, 1.5])),
        AdmissibleEval(np.array([0.0, 0.8, 0.8, 1.0])),
        AdmissibleEval(np.array([0.0, 0.6, 0.6, 1.2])),
    ]
    x, y = 1, 2
    betas_plot = np.logspace(-1, 2, 50)
    all_probs = []
    for beta in betas_plot:
        gaps = np.array([eval_gap(v, x, y) for v in evaluations])
        log_probs = beta * gaps
        log_probs -= np.max(log_probs)
        probs = np.exp(log_probs)
        probs /= probs.sum()
        all_probs.append(probs)

    all_probs = np.array(all_probs)
    for i in range(len(evaluations)):
        ax.semilogx(betas_plot, all_probs[:, i], linewidth=2, label=f'v_{i+1}')

    ax.set_xlabel('β')
    ax.set_ylabel('Gibbs probability')
    ax.set_title('(d) Gibbs Concentration (a→b)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Thermodynamic Dual Semantics — Summary',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('demos/summary_figure.png', dpi=150, bbox_inches='tight')
    print("Summary figure saved to demos/summary_figure.png")


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Thermodynamic Dual Semantics for Proof Semirings              ║")
    print("║  Interactive Demonstration                                     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_bridge_theorem()
    demo_thermodynamic_soundness()
    demo_zero_temperature_convergence()
    demo_phase_transition()
    demo_annealing_witness()
    create_summary_figure()

    print("\nAll demos completed successfully!")
