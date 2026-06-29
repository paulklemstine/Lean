#!/usr/bin/env python3
"""
Surveillance Networks: Core Algorithms

Type-hinted implementations of the key algorithms from the rate-distortion
framework for surveillance networks.
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import TypeVar, Generic, Callable

S = TypeVar('S')
C = TypeVar('C')


@dataclass
class NetworkDistortion(Generic[S]):
    """A distortion measure on a finite state space."""
    states: list[S]
    d: Callable[[S, S], float]

    def is_separating(self) -> bool:
        """Check if the distortion separates points."""
        for x in self.states:
            for y in self.states:
                if x != y and self.d(x, y) == 0:
                    return False
        return True

    def is_nondegenerate(self) -> bool:
        """Check if the distortion is non-degenerate."""
        return any(
            self.d(x, y) > 0
            for x in self.states
            for y in self.states
        )


@dataclass
class ObservationChannel(Generic[S, C]):
    """An encoding-decoding observation channel."""
    encode: Callable[[S], C]
    decode: Callable[[C], S]
    codebook: list[C]

    def rate(self) -> float:
        """Compute the rate (log of codebook size)."""
        return math.log(len(self.codebook)) if self.codebook else 0.0

    def worst_case_distortion(
        self,
        nd: NetworkDistortion[S]
    ) -> float:
        """Compute worst-case distortion over all states."""
        return max(
            nd.d(s, self.decode(self.encode(s)))
            for s in nd.states
        )

    def is_surveillance_capable(
        self,
        nd: NetworkDistortion[S]
    ) -> bool:
        """Check if channel achieves zero distortion."""
        return all(
            nd.d(s, self.decode(self.encode(s))) == 0
            for s in nd.states
        )

    def is_privacy_preserving(self) -> bool:
        """Check if codebook has at most one element."""
        return len(self.codebook) <= 1

    def privacy_level(self, state_count: int) -> float:
        """Compute normalized privacy level."""
        max_rate = math.log(state_count) if state_count > 1 else 1.0
        return 1.0 - self.rate() / max_rate


def greedy_codebook(
    nd: NetworkDistortion[S],
    max_distortion: float
) -> list[S]:
    """
    Greedy algorithm for minimum-size codebook achieving given distortion.

    Algorithm:
    1. Start with all states uncovered
    2. Greedily pick the state covering the most uncovered states
    3. Repeat until all states are covered

    Returns: list of codebook representatives
    """
    uncovered: set[int] = set(range(len(nd.states)))
    codebook: list[S] = []

    while uncovered:
        best_idx = -1
        best_count = -1
        for i in range(len(nd.states)):
            count = sum(
                1 for j in uncovered
                if nd.d(nd.states[i], nd.states[j]) <= max_distortion
            )
            if count > best_count:
                best_count = count
                best_idx = i

        codebook.append(nd.states[best_idx])
        uncovered -= {
            j for j in uncovered
            if nd.d(nd.states[best_idx], nd.states[j]) <= max_distortion
        }

    return codebook


def rate_distortion_curve(
    nd: NetworkDistortion[S],
    distortion_values: list[float]
) -> list[tuple[float, float, int]]:
    """
    Compute the rate-distortion curve.

    Returns: list of (distortion, rate, codebook_size) tuples
    """
    results = []
    for D in distortion_values:
        cb = greedy_codebook(nd, D)
        rate = math.log2(len(cb)) if cb else 0.0
        results.append((D, rate, len(cb)))
    return results


def verify_exclusion_theorem(
    nd: NetworkDistortion[S],
    channel: ObservationChannel[S, C]
) -> dict[str, bool | str]:
    """
    Verify the surveillance-privacy exclusion theorem for a given channel.

    Returns a dict with:
    - 'is_surveillance_capable': bool
    - 'is_privacy_preserving': bool
    - 'exclusion_holds': bool (True if not both)
    - 'explanation': str
    """
    surv = channel.is_surveillance_capable(nd)
    priv = channel.is_privacy_preserving()

    if surv and priv:
        # This should be impossible for |S| >= 2 with separating distortion
        return {
            'is_surveillance_capable': True,
            'is_privacy_preserving': True,
            'exclusion_holds': False,
            'explanation': 'BUG: Both properties hold simultaneously!'
        }
    elif surv:
        return {
            'is_surveillance_capable': True,
            'is_privacy_preserving': False,
            'exclusion_holds': True,
            'explanation': f'Surveillance-capable but not privacy-preserving '
                          f'(codebook size = {len(channel.codebook)} > 1)'
        }
    elif priv:
        return {
            'is_surveillance_capable': False,
            'is_privacy_preserving': True,
            'exclusion_holds': True,
            'explanation': f'Privacy-preserving but not surveillance-capable '
                          f'(distortion = {channel.worst_case_distortion(nd):.2f})'
        }
    else:
        return {
            'is_surveillance_capable': False,
            'is_privacy_preserving': False,
            'exclusion_holds': True,
            'explanation': 'Neither property holds (intermediate channel)'
        }


def dynamic_codebook_bound(
    state_count: int,
    time_steps: int
) -> int:
    """
    Compute the minimum codebook size for perfect dynamic surveillance.

    For a network with |S| states observed over T time steps,
    the minimum codebook size is |S|^T.
    """
    return state_count ** time_steps


# Example usage
if __name__ == "__main__":
    # Create a simple 2-node network
    states = [(False, False), (False, True), (True, False), (True, True)]

    def hamming_d(s1: tuple[bool, ...], s2: tuple[bool, ...]) -> float:
        return sum(1 for a, b in zip(s1, s2) if a != b)

    nd = NetworkDistortion(states=states, d=hamming_d)

    print(f"State space size: {len(states)}")
    print(f"Separating: {nd.is_separating()}")
    print(f"Non-degenerate: {nd.is_nondegenerate()}")
    print()

    # Rate-distortion curve
    curve = rate_distortion_curve(nd, [0, 1, 2])
    print("Rate-Distortion Curve:")
    for D, R, cb_size in curve:
        print(f"  D={D:.0f}: R={R:.2f} bits, codebook size={cb_size}")
    print()

    # Dynamic scaling
    print("Dynamic Codebook Bounds:")
    for T in [1, 2, 5, 10]:
        bound = dynamic_codebook_bound(len(states), T)
        print(f"  T={T}: |S|^T = {bound}")
