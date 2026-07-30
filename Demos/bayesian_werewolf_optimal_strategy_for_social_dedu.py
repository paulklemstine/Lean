#!/usr/bin/env python3
"""Numerical demonstrations for Bayesian one-step elimination.

The program uses only Python's standard library. It demonstrates posterior
normalization, maximum-posterior optimality against several randomized rules,
uniform-elimination baselines, and exact values of the proposed scaling factor.
"""

from __future__ import annotations

from fractions import Fraction
from math import isclose
from random import Random
from typing import Iterable, Sequence


def bayesian_posterior(
    priors: Sequence[float], likelihoods: Sequence[float]
) -> list[float]:
    """Return normalized prior-times-likelihood scores."""
    if len(priors) != len(likelihoods) or not priors:
        raise ValueError("priors and likelihoods must have equal nonzero length")
    if any(p < 0.0 for p in priors) or any(x < 0.0 for x in likelihoods):
        raise ValueError("probability inputs must be nonnegative")
    scores = [p * likelihood for p, likelihood in zip(priors, likelihoods)]
    normalizer = sum(scores)
    if normalizer <= 0.0:
        raise ValueError("the sum of Bayesian scores must be positive")
    return [score / normalizer for score in scores]


def randomized_success(rule: Sequence[float], posterior: Sequence[float]) -> float:
    """Compute the one-step success probability of a randomized rule."""
    if len(rule) != len(posterior) or not rule:
        raise ValueError("rule and posterior must have equal nonzero length")
    if any(q < 0.0 for q in rule):
        raise ValueError("rule weights must be nonnegative")
    if not isclose(sum(rule), 1.0, rel_tol=1e-12, abs_tol=1e-12):
        raise ValueError("rule weights must sum to one")
    return sum(q * probability for q, probability in zip(rule, posterior))


def maximum_posterior_targets(posterior: Sequence[float]) -> list[int]:
    """Return all zero-based indices attaining the largest posterior."""
    if not posterior:
        raise ValueError("posterior must be nonempty")
    maximum = max(posterior)
    return [i for i, value in enumerate(posterior) if isclose(value, maximum)]


def uniform_elimination_probability(n_players: int, n_wolves: int) -> Fraction:
    """Return the exact probability of hitting a wolf uniformly."""
    if n_players <= 0 or not 0 <= n_wolves <= n_players:
        raise ValueError("require n_players > 0 and 0 <= n_wolves <= n_players")
    return Fraction(n_wolves, n_players)


def proposed_scaling(n_players: int, n_wolves: int, constant: Fraction) -> Fraction:
    """Evaluate C(1-k/(n-k))^2 exactly."""
    if n_players == n_wolves:
        raise ValueError("the scaling expression is undefined when n = k")
    ratio = Fraction(n_wolves, n_players - n_wolves)
    return constant * (1 - ratio) ** 2


def monte_carlo_rule_success(
    rule: Sequence[float], posterior: Sequence[float], trials: int, seed: int = 20260730
) -> float:
    """Estimate success by sampling a target and its Bernoulli role indicator."""
    if trials <= 0:
        raise ValueError("trials must be positive")
    randomized_success(rule, posterior)  # validate the inputs
    rng = Random(seed)
    cumulative: list[float] = []
    running = 0.0
    for weight in rule:
        running += weight
        cumulative.append(running)
    hits = 0
    for _ in range(trials):
        draw = rng.random()
        target = next(i for i, cutoff in enumerate(cumulative) if draw <= cutoff)
        hits += rng.random() < posterior[target]
    return hits / trials


def format_vector(values: Iterable[float]) -> str:
    """Format a vector compactly."""
    return "[" + ", ".join(f"{value:.6f}" for value in values) + "]"


def main() -> None:
    """Run deterministic and Monte Carlo demonstrations."""
    n, k = 7, 2
    priors = [k / n] * n
    likelihoods = [0.12, 0.08, 0.25, 0.10, 0.18, 0.09, 0.18]
    posterior = bayesian_posterior(priors, likelihoods)
    targets = maximum_posterior_targets(posterior)

    deterministic = [0.0] * n
    deterministic[targets[0]] = 1.0
    uniform = [1.0 / n] * n
    mixed = [0.0] * n
    mixed[2] = 0.5
    mixed[4] = 0.5

    print("Bayesian one-step elimination demonstration")
    print(f"posterior: {format_vector(posterior)}")
    print(f"sum: {sum(posterior):.12f}")
    print(f"maximum-posterior player(s), one-based: {[i + 1 for i in targets]}")
    print(f"deterministic MAP success: {randomized_success(deterministic, posterior):.6f}")
    print(f"player 3/5 mixture success: {randomized_success(mixed, posterior):.6f}")
    print(f"uniform target success in normalized target model: {randomized_success(uniform, posterior):.6f}")

    best = max(posterior)
    for name, rule in [("deterministic", deterministic), ("mixed", mixed), ("uniform", uniform)]:
        assert randomized_success(rule, posterior) <= best + 1e-12, name

    baseline = uniform_elimination_probability(n, k)
    seven_two = proposed_scaling(7, 2, Fraction(1))
    parity = proposed_scaling(2 * k, k, Fraction(1))
    print(f"role-count uniform baseline k/n: {baseline} = {float(baseline):.6f}")
    print(f"scaling factor at (n,k,C)=(7,2,1): {seven_two} = {float(seven_two):.2f}")
    print(f"scaling factor at parity n=2k: {parity}")

    trials = 100_000
    estimate = monte_carlo_rule_success(deterministic, posterior, trials)
    print(f"Monte Carlo MAP estimate ({trials:,} trials): {estimate:.6f}")
    print("All exact inequality checks passed.")


if __name__ == "__main__":
    main()
