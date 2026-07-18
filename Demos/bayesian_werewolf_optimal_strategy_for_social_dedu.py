#!/usr/bin/env python3
"""Numerical demonstrations for Bayesian elimination decisions and spin scores."""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Iterable, Sequence


@dataclass(frozen=True)
class BayesianDecision:
    """The normalized posterior and its maximum-posterior action."""

    posterior: tuple[float, ...]
    map_index: int
    evidence_mass: float


def normalize_bayesian_weights(
    priors: Sequence[float], likelihoods: Sequence[float]
) -> BayesianDecision:
    """Normalize prior-times-likelihood weights and return a MAP index.

    Raises ValueError for unequal, empty, negative, or zero-mass inputs.
    """
    if len(priors) != len(likelihoods) or not priors:
        raise ValueError("priors and likelihoods must have equal positive length")
    if any(x < 0.0 for x in priors) or any(x < 0.0 for x in likelihoods):
        raise ValueError("probabilistic priors and likelihoods must be nonnegative")
    weights = tuple(prior * likelihood for prior, likelihood in zip(priors, likelihoods))
    mass = sum(weights)
    if mass <= 0.0:
        raise ValueError("evidence mass must be positive")
    posterior = tuple(weight / mass for weight in weights)
    map_index = max(range(len(weights)), key=weights.__getitem__)
    return BayesianDecision(posterior, map_index, mass)


def symmetric_continuation_values(
    posterior: Sequence[float], good: float, bad: float
) -> tuple[float, ...]:
    """Evaluate B + (G-B)p for every action in a symmetric model."""
    if not posterior or any(p < 0.0 for p in posterior):
        raise ValueError("posterior must be a nonempty nonnegative sequence")
    if not isclose(sum(posterior), 1.0, rel_tol=1e-9, abs_tol=1e-12):
        raise ValueError("posterior must sum to one")
    return tuple(bad + (good - bad) * p for p in posterior)


def identity_dependent_values(
    posterior: Sequence[float], hit_rewards: Sequence[float]
) -> tuple[float, ...]:
    """Expected values p_i R_i when misses have value zero."""
    if len(posterior) != len(hit_rewards) or not posterior:
        raise ValueError("posterior and rewards must have equal positive length")
    return tuple(p * reward for p, reward in zip(posterior, hit_rewards))


def spin_score(probability: float) -> float:
    """Map a binary-role probability to its centered spin score 2p-1."""
    return 2.0 * probability - 1.0


def constant_magnetization(rows: int, columns: int, probability: float) -> float:
    """Magnetization of a rows-by-columns constant posterior field."""
    if rows <= 0 or columns <= 0:
        raise ValueError("lattice dimensions must be positive")
    return rows * columns * spin_score(probability)


def fmt(values: Iterable[float]) -> str:
    """Format a numerical vector for console output."""
    return "[" + ", ".join(f"{value:.6f}" for value in values) + "]"


def demonstrate_normalization_and_map() -> None:
    """Show normalization, score-order preservation, and symmetric optimality."""
    priors = (0.40, 0.35, 0.25)
    likelihoods = (0.20, 0.80, 0.50)
    decision = normalize_bayesian_weights(priors, likelihoods)
    values = symmetric_continuation_values(decision.posterior, good=0.9, bad=0.2)
    value_index = max(range(len(values)), key=values.__getitem__)

    print("Example 1 — Bayesian normalization and symmetric continuation")
    print(f"  evidence mass: {decision.evidence_mass:.6f}")
    print(f"  posterior:     {fmt(decision.posterior)}")
    print(f"  posterior sum: {sum(decision.posterior):.12f}")
    print(f"  MAP suspect:   {decision.map_index}")
    print(f"  values:        {fmt(values)}")
    print(f"  value maximizer agrees with MAP: {value_index == decision.map_index}\n")


def demonstrate_regret_bound() -> None:
    """Compare exact symmetric regret with the theorem's upper bound."""
    posterior = (0.58, 0.33, 0.09)
    good, bad = 0.95, 0.15
    best, approximate = 0, 1
    epsilon = posterior[best] - posterior[approximate]
    values = symmetric_continuation_values(posterior, good, bad)
    regret = values[best] - values[approximate]
    bound = (good - bad) * epsilon

    print("Example 2 — posterior-approximation regret")
    print(f"  posterior gap epsilon: {epsilon:.6f}")
    print(f"  exact regret:          {regret:.6f}")
    print(f"  theorem bound:         {bound:.6f}")
    print(f"  bound respected:       {regret <= bound + 1e-12}\n")


def demonstrate_asymmetry_counterexample() -> None:
    """Show that identity-dependent rewards can overturn MAP ranking."""
    posterior = (3.0 / 5.0, 2.0 / 5.0)
    rewards = (1.0 / 10.0, 1.0)
    values = identity_dependent_values(posterior, rewards)
    map_index = max(range(2), key=posterior.__getitem__)
    utility_index = max(range(2), key=values.__getitem__)

    print("Example 3 — identity-dependent counterexample")
    print(f"  posterior:        {fmt(posterior)}")
    print(f"  hit rewards:      {fmt(rewards)}")
    print(f"  expected values:  {fmt(values)}")
    print(f"  MAP suspect:      {map_index}")
    print(f"  utility maximizer:{utility_index}")
    print(f"  rankings disagree:{map_index != utility_index}\n")


def demonstrate_spin_flip() -> None:
    """Show centered-score complementation and magnetization reversal."""
    probability = 0.70
    complement = 1.0 - probability
    magnetization = constant_magnetization(4, 5, probability)
    flipped = constant_magnetization(4, 5, complement)

    print("Example 4 — posterior complementation as spin flip")
    print(f"  s({probability:.2f}) = {spin_score(probability):.6f}")
    print(f"  s({complement:.2f}) = {spin_score(complement):.6f}")
    print(f"  4x5 magnetization:         {magnetization:.6f}")
    print(f"  complemented magnetization:{flipped:.6f}")
    print(f"  exact sign reversal:       {isclose(flipped, -magnetization)}")


def main() -> None:
    """Run all numerical demonstrations."""
    demonstrate_normalization_and_map()
    demonstrate_regret_bound()
    demonstrate_asymmetry_counterexample()
    demonstrate_spin_flip()


if __name__ == "__main__":
    main()
