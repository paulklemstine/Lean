#!/usr/bin/env python3
"""
Tropical Surprise Theory — Core Algorithms

Type-hinted implementations of the key algorithms from the framework.
"""

import math
from typing import List, Tuple, Optional
from dataclasses import dataclass


# ═══════════════════════════════════════════════════
# Algorithm 1: Surprise Decay Prediction
# ═══════════════════════════════════════════════════

@dataclass
class SurpriseDecayModel:
    """Model for geometric surprise decay under repetition."""
    initial_surprise: float  # s₀
    decay_rate: float        # r ∈ (0, 1)

    def surprise_at(self, n: int) -> float:
        """Surprise after n repetitions: s₀ · rⁿ."""
        return self.initial_surprise * self.decay_rate ** n

    def total_surprise(self, n_repetitions: int) -> float:
        """Partial sum of surprise over n repetitions."""
        return sum(self.surprise_at(k) for k in range(n_repetitions))

    def lifetime_surprise(self) -> float:
        """Total surprise over infinite repetitions: s₀ / (1 - r)."""
        return self.initial_surprise / (1 - self.decay_rate)

    def half_life(self) -> float:
        """Number of repetitions to halve surprise: -log2 / log(r)."""
        return -math.log(2) / math.log(self.decay_rate)

    def repetitions_until_threshold(self, threshold: float) -> int:
        """Minimum n such that s(n) < threshold."""
        if threshold <= 0:
            return -1  # never
        n = math.ceil(math.log(threshold / self.initial_surprise) / math.log(self.decay_rate))
        return max(0, n)


# ═══════════════════════════════════════════════════
# Algorithm 2: Entropy and KL Divergence Computation
# ═══════════════════════════════════════════════════

def shannon_entropy(probs: List[float]) -> float:
    """Compute Shannon entropy H(p) = -Σ pᵢ log(pᵢ)."""
    return -sum(p * math.log(p) for p in probs if p > 0)


def kl_divergence(p: List[float], q: List[float]) -> float:
    """Compute KL divergence D_KL(p || q) = Σ pᵢ log(pᵢ/qᵢ)."""
    assert len(p) == len(q), "Distributions must have same support"
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q) if pi > 0 and qi > 0)


def info_surprise(p: float) -> float:
    """Information-theoretic surprise: -log₂(p)."""
    if p <= 0:
        return float('inf')
    return -math.log2(p)


def entropy_gap(probs: List[float]) -> float:
    """Gap between maximum entropy and actual: log(n) - H(p)."""
    n = len(probs)
    return math.log(n) - shannon_entropy(probs)


# ═══════════════════════════════════════════════════
# Algorithm 3: Surprise Spectrum Analysis
# ═══════════════════════════════════════════════════

@dataclass
class SurpriseSpectrum:
    """Non-negative surprise weight distribution over outcomes."""
    weights: List[float]

    def __post_init__(self) -> None:
        assert all(w >= 0 for w in self.weights), "Weights must be non-negative"

    def total_surprise(self) -> float:
        """Sum of all surprise weights."""
        return sum(self.weights)

    def max_surprise(self) -> float:
        """Maximum surprise weight (tropical sum)."""
        return max(self.weights)

    def avg_surprise(self) -> float:
        """Average surprise weight."""
        return self.total_surprise() / len(self.weights)

    def spectral_ratio(self) -> float:
        """Ratio total/max ∈ [1, n]. Measures how spread the spectrum is."""
        m = self.max_surprise()
        return self.total_surprise() / m if m > 0 else 0

    def tropical_sum(self, other: 'SurpriseSpectrum') -> 'SurpriseSpectrum':
        """Tropical sum: pointwise max."""
        assert len(self.weights) == len(other.weights)
        return SurpriseSpectrum([max(a, b) for a, b in zip(self.weights, other.weights)])

    def tropical_scale(self, c: float) -> 'SurpriseSpectrum':
        """Tropical scaling: add constant to all weights."""
        return SurpriseSpectrum([w + c for w in self.weights])


# ═══════════════════════════════════════════════════
# Algorithm 4: Optimal Surprise Allocation
# ═══════════════════════════════════════════════════

def optimal_surprise_allocation(total_budget: float, n_slots: int) -> List[float]:
    """
    Allocate surprise budget across n slots to maximize entropy.
    By the entropy maximization theorem, uniform allocation is optimal.
    """
    return [total_budget / n_slots] * n_slots


def novelty_familiarity_impact(p: float) -> float:
    """
    Compute the novelty-familiarity product p·(-log p).
    Maximized at p = 1/e ≈ 0.368.
    """
    if p <= 0:
        return 0.0
    return p * (-math.log(p))


def optimal_familiarity() -> float:
    """The probability that maximizes impact: 1/e."""
    return 1.0 / math.e


# ═══════════════════════════════════════════════════
# Algorithm 5: Narrative Chain Analysis
# ═══════════════════════════════════════════════════

@dataclass
class NarrativeChain:
    """Row-stochastic transition matrix for narrative states."""
    trans: List[List[float]]  # n × n matrix

    @property
    def n(self) -> int:
        return len(self.trans)

    def conditional_entropy(self, state: int) -> float:
        """H(X_{t+1} | X_t = state) = -Σⱼ P(i,j) log P(i,j)."""
        return -sum(
            p * math.log(p) for p in self.trans[state] if p > 0
        )

    def transition_surprise(self, i: int, j: int) -> float:
        """Surprise of transitioning from state i to j: -log P(i,j)."""
        p = self.trans[i][j]
        return -math.log(p) if p > 0 else float('inf')

    def entropy_vector(self) -> List[float]:
        """Conditional entropy from each state."""
        return [self.conditional_entropy(i) for i in range(self.n)]

    def max_conditional_entropy(self) -> float:
        """Maximum conditional entropy across all states."""
        return max(self.conditional_entropy(i) for i in range(self.n))

    def entropy_bound(self) -> float:
        """Theoretical upper bound: log(n)."""
        return math.log(self.n)


# ═══════════════════════════════════════════════════
# Algorithm 6: Callback Placement Optimizer
# ═══════════════════════════════════════════════════

def optimal_callback_count(routine_length: int, decay_rate: float) -> int:
    """
    Optimal number of callbacks in a routine of given length.
    One callback per surprise half-life.
    """
    half_life = -math.log(2) / math.log(decay_rate)
    return max(1, int(routine_length / half_life))


def callback_total_surprise(
    routine_length: int,
    callback_positions: List[int],
    initial_surprise: float,
    decay_rate: float
) -> float:
    """
    Total surprise from callbacks at given positions.
    Surprise decays geometrically from the last callback.
    """
    total = 0.0
    last_pos = 0
    for pos in sorted(callback_positions):
        gap = pos - last_pos
        total += initial_surprise * decay_rate ** gap
        last_pos = pos
    return total


def equally_spaced_callbacks(
    routine_length: int,
    n_callbacks: int
) -> List[int]:
    """Generate equally-spaced callback positions."""
    return [routine_length * (j + 1) // (n_callbacks + 1) for j in range(n_callbacks)]


# ═══════════════════════════════════════════════════
# Main demonstration
# ═══════════════════════════════════════════════════

if __name__ == "__main__":
    # Surprise decay
    model = SurpriseDecayModel(initial_surprise=10.0, decay_rate=0.7)
    print(f"Surprise Decay Model: s₀={model.initial_surprise}, r={model.decay_rate}")
    print(f"  Half-life: {model.half_life():.2f} repetitions")
    print(f"  Lifetime surprise: {model.lifetime_surprise():.2f}")
    print(f"  Repetitions until <0.01: {model.repetitions_until_threshold(0.01)}")

    # Surprise spectrum
    spec = SurpriseSpectrum([1.0, 3.0, 7.0, 2.0, 0.5])
    print(f"\nSurprise Spectrum: {spec.weights}")
    print(f"  Total: {spec.total_surprise():.2f}")
    print(f"  Max (tropical sum): {spec.max_surprise():.2f}")
    print(f"  Spectral ratio: {spec.spectral_ratio():.2f}")

    # Narrative chain
    chain = NarrativeChain([
        [0.3, 0.4, 0.3],
        [0.1, 0.6, 0.3],
        [0.5, 0.2, 0.3],
    ])
    print(f"\nNarrative Chain ({chain.n} states):")
    print(f"  Entropy bound: {chain.entropy_bound():.4f}")
    for i in range(chain.n):
        print(f"  H(state {i}): {chain.conditional_entropy(i):.4f}")

    # Optimal familiarity
    print(f"\nOptimal familiarity: p* = 1/e = {optimal_familiarity():.6f}")
    print(f"  Max impact: {novelty_familiarity_impact(optimal_familiarity()):.6f}")
    print(f"  1/e = {1/math.e:.6f}")
