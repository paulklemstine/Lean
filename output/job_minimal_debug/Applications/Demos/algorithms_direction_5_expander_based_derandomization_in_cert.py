#!/usr/bin/env python3
"""
Expander Walk Majority Amplifier — Certified Algorithms

Implements the expander-walk majority amplification protocol with
explicit random-bit accounting and certified error bounds.
"""

import math
import random
from typing import Callable, Dict, List, Optional, Tuple

# ─────────────────────────────────────────────────────────────────
# Core data structures
# ─────────────────────────────────────────────────────────────────

class CayleyExpanderAmplifier:
    """
    A certified majority amplifier based on an expander walk
    on a Cayley graph of a finite group.

    Parameters
    ----------
    group_elements : list
        All elements of the finite group.
    generators : list
        The symmetric generating set {s₁, s₁⁻¹, s₂, s₂⁻¹, ...}.
    compose_fn : callable
        (g, h) -> g·h, the group operation.
    rho : float
        Upper bound on the spectral contraction parameter.
        Must satisfy 0 ≤ ρ < 1.
    """

    def __init__(
        self,
        group_elements: list,
        generators: list,
        compose_fn: Callable,
        rho: float,
    ):
        self.elements = group_elements
        self.generators = generators
        self.compose = compose_fn
        self.rho = rho
        self.n = len(group_elements)
        self.degree = len(generators)

        assert 0 <= rho < 1, f"ρ must satisfy 0 ≤ ρ < 1, got {rho}"

    @property
    def spectral_constant(self) -> float:
        """C(ρ) = (1+ρ)/(1-ρ), the multiplicative overhead from correlation."""
        return (1 + self.rho) / (1 - self.rho)

    def random_bits_needed(self, walk_length: int) -> int:
        """Total random bits needed for a walk of given length."""
        init_bits = math.ceil(math.log2(self.n)) if self.n > 1 else 0
        step_bits = math.ceil(math.log2(self.degree)) if self.degree > 1 else 0
        return init_bits + walk_length * step_bits

    def independent_bits_needed(self, num_samples: int) -> int:
        """Random bits needed for independent sampling."""
        init_bits = math.ceil(math.log2(self.n)) if self.n > 1 else 0
        return num_samples * init_bits

    def certified_error_bound(self, delta: float, k: int) -> float:
        """
        Certified upper bound on majority failure probability.

        For a {0,1}-valued function f with E[f] ≥ 1/2 + δ,
        the probability that majority of k walk samples fails is at most:

            (1+ρ) / ((1-ρ) · 4δ² · k)

        Parameters
        ----------
        delta : float
            The bias: E[f] - 1/2.
        k : int
            Walk length (number of samples).

        Returns
        -------
        float
            Certified error bound.
        """
        if delta <= 0 or k <= 0:
            return float('inf')
        return self.spectral_constant / (4 * delta**2 * k)

    def walk_length_for_error(self, delta: float, epsilon: float) -> int:
        """
        Minimum walk length k such that majority error ≤ ε.

        k ≥ (1+ρ) / ((1-ρ) · 4δ² · ε)

        Parameters
        ----------
        delta : float
            The bias: E[f] - 1/2.
        epsilon : float
            Target error probability.

        Returns
        -------
        int
            Minimum walk length.
        """
        if delta <= 0 or epsilon <= 0:
            return float('inf')
        return math.ceil(self.spectral_constant / (4 * delta**2 * epsilon))

    def sample_walk(
        self, start_element, k: int, rng: random.Random = None
    ) -> List:
        """
        Sample a walk of length k starting from start_element.

        At each step, a random generator is chosen and applied.

        Parameters
        ----------
        start_element :
            Starting group element.
        k : int
            Walk length.
        rng : random.Random, optional
            Random number generator.

        Returns
        -------
        list
            The k group elements visited during the walk.
        """
        if rng is None:
            rng = random.Random()
        path = [start_element]
        current = start_element
        for _ in range(k - 1):
            gen = rng.choice(self.generators)
            current = self.compose(gen, current)
            path.append(current)
        return path

    def majority_vote(
        self,
        f: Callable,
        start_element,
        k: int,
        rng: random.Random = None,
    ) -> Tuple[bool, float, Dict]:
        """
        Run the majority-vote amplifier.

        Parameters
        ----------
        f : callable
            Boolean predicate f : G → {0, 1}.
        start_element :
            Starting group element.
        k : int
            Walk length.
        rng : random.Random, optional
            Random number generator.

        Returns
        -------
        vote : bool
            True if majority says f = 1.
        empirical_mean : float
            The fraction of walk samples with f = 1.
        info : dict
            Diagnostic information including random bits used.
        """
        walk = self.sample_walk(start_element, k, rng)
        values = [f(g) for g in walk]
        total = sum(values)
        empirical_mean = total / k
        vote = empirical_mean > 0.5

        return vote, empirical_mean, {
            "k": k,
            "total_ones": total,
            "empirical_mean": empirical_mean,
            "random_bits_used": self.random_bits_needed(k),
        }

    def amplified_test(
        self,
        f: Callable,
        delta: float,
        epsilon: float,
        rng: random.Random = None,
    ) -> Tuple[bool, Dict]:
        """
        Run the amplifier with automatically chosen walk length
        to achieve target error ε.

        Parameters
        ----------
        f : callable
            Boolean predicate with E[f] ≥ 1/2 + δ.
        delta : float
            Known bias lower bound.
        epsilon : float
            Target error probability.
        rng : random.Random, optional
            Random number generator.

        Returns
        -------
        vote : bool
            Majority vote result.
        report : dict
            Full report including certified bounds and bit costs.
        """
        if rng is None:
            rng = random.Random()

        k = self.walk_length_for_error(delta, epsilon)
        start = rng.choice(self.elements)
        vote, emp_mean, info = self.majority_vote(f, start, k, rng)

        report = {
            **info,
            "delta": delta,
            "epsilon": epsilon,
            "certified_error_bound": self.certified_error_bound(delta, k),
            "spectral_contraction": self.rho,
            "spectral_constant": self.spectral_constant,
            "independent_bits_would_need": self.independent_bits_needed(k),
            "savings_ratio": 1 - info["random_bits_used"] / max(1, self.independent_bits_needed(k)),
        }

        return vote, report


# ─────────────────────────────────────────────────────────────────
# S_5 Cayley graph construction
# ─────────────────────────────────────────────────────────────────

def compose_perm(p: tuple, q: tuple) -> tuple:
    """Compose two permutations."""
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p: tuple) -> tuple:
    """Inverse of a permutation."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def build_s5_amplifier(rho: float = 0.907) -> CayleyExpanderAmplifier:
    """
    Build the expander amplifier for S_5 with generators {σ^±1, τ^±1}.

    Parameters
    ----------
    rho : float
        Spectral contraction bound. Default 0.907 (empirically computed).

    Returns
    -------
    CayleyExpanderAmplifier
    """
    sigma = (1, 2, 3, 4, 0)  # 5-cycle
    tau = (1, 0, 2, 3, 4)    # transposition (0 1)
    gens = [sigma, inverse_perm(sigma), tau, inverse_perm(tau)]

    # Generate S_5 by BFS
    identity = (0, 1, 2, 3, 4)
    elements = {identity}
    frontier = [identity]
    while frontier:
        nxt = []
        for g in frontier:
            for s in gens:
                h = compose_perm(s, g)
                if h not in elements:
                    elements.add(h)
                    nxt.append(h)
        frontier = nxt

    return CayleyExpanderAmplifier(
        group_elements=sorted(elements),
        generators=gens,
        compose_fn=compose_perm,
        rho=rho,
    )


# ─────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Expander Walk Majority Amplifier — Algorithm Demo")
    print("=" * 60)

    amp = build_s5_amplifier()
    print(f"\nGroup: S_5, |G| = {amp.n}")
    print(f"Degree: {amp.degree}")
    print(f"Spectral contraction: ρ = {amp.rho}")
    print(f"Spectral constant C(ρ) = {amp.spectral_constant:.4f}")

    # Create a biased Boolean function
    rng = random.Random(42)
    bias = 0.65
    num_ones = int(round(bias * amp.n))
    ones_set = set(rng.sample(amp.elements, num_ones))
    f = lambda g: 1 if g in ones_set else 0
    actual_mean = sum(f(g) for g in amp.elements) / amp.n

    print(f"\nBoolean function f: E[f] = {actual_mean:.4f}")
    print(f"Bias δ = E[f] - 1/2 = {actual_mean - 0.5:.4f}")

    # Run amplified test
    print("\n--- Amplified Test ---")
    for eps in [0.1, 0.01, 0.001]:
        vote, report = amp.amplified_test(f, delta=0.1, epsilon=eps, rng=random.Random(0))
        print(f"\nTarget ε = {eps}")
        print(f"  Walk length k = {report['k']}")
        print(f"  Random bits used: {report['random_bits_used']}")
        print(f"  Independent would need: {report['independent_bits_would_need']}")
        print(f"  Savings: {report['savings_ratio']:.1%}")
        print(f"  Certified error bound: {report['certified_error_bound']:.6f}")
        print(f"  Vote: {'ACCEPT' if vote else 'REJECT'}")
        print(f"  Empirical mean: {report['empirical_mean']:.4f}")
