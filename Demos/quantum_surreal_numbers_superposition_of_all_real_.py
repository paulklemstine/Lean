#!/usr/bin/env python3
"""Numerical demonstrations for quantum surreal observation.

Floating-point arithmetic has no genuine infinitesimals.  The parameter sweeps
below display the real limiting behavior that standard-part observation captures:
(1, epsilon) has Born weights approaching (1, 0), while equal amplitudes remain
(1/2, 1/2).  Exact lexicographic pairs model first-order infinitesimals without
floating-point approximation.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import isclose
from typing import Iterable, Sequence


@dataclass(frozen=True)
class LexValue:
    """A rational lexicographic value a + b*epsilon."""

    real: Fraction
    infinitesimal: Fraction

    def __add__(self, other: "LexValue") -> "LexValue":
        return LexValue(
            self.real + other.real,
            self.infinitesimal + other.infinitesimal,
        )

    def standard_part(self) -> Fraction:
        return self.real


def born_weights(amplitudes: Sequence[float]) -> list[float]:
    """Return normalized squared amplitudes for a nonzero real state."""
    norm_sq = sum(a * a for a in amplitudes)
    if norm_sq == 0.0:
        raise ValueError("The state must have nonzero squared norm.")
    return [(a * a) / norm_sq for a in amplitudes]


def epsilon_state_weights(epsilon: float) -> tuple[float, float]:
    """Born weights of |0> + epsilon |1>."""
    if epsilon < 0.0:
        raise ValueError("epsilon must be nonnegative")
    first, second = born_weights([1.0, epsilon])
    return first, second


def equal_amplitude_weights(amplitude: float) -> tuple[float, float]:
    """Born weights of two distinct labels with a common nonzero amplitude."""
    if amplitude == 0.0:
        raise ValueError("amplitude must be nonzero")
    first, second = born_weights([amplitude, amplitude])
    return first, second


def reservoir_event_mass(
    n_visible: int, visible_indices: Iterable[int], includes_reservoir: bool
) -> LexValue:
    """Compute exact mass (ordinary, infinitesimal) of a reservoir event."""
    if n_visible < 0:
        raise ValueError("n_visible must be nonnegative")
    indices = set(visible_indices)
    if any(i < 0 or i >= n_visible for i in indices):
        raise ValueError("visible index outside the outcome space")
    reservoir_flag = Fraction(int(includes_reservoir))
    infinitesimal = Fraction(len(indices) - n_visible * int(includes_reservoir))
    return LexValue(reservoir_flag, infinitesimal)


def tropical_reservoir_integral(
    reservoir_value: float, visible_values: Sequence[float], penalty: float
) -> tuple[float, str, float]:
    """Return max-plus value, a maximizing label, and the stability margin."""
    if penalty >= 0.0:
        raise ValueError("penalty must be negative")
    visible_scores = [value + penalty for value in visible_values]
    if not visible_scores:
        return reservoir_value, "reservoir", float("inf")
    best_visible_score = max(visible_scores)
    best_visible_index = visible_scores.index(best_visible_score)
    margin = reservoir_value - best_visible_score
    if reservoir_value >= best_visible_score:
        return reservoir_value, "reservoir", margin
    return best_visible_score, f"visible[{best_visible_index}]", margin


def demonstrate_epsilon_collapse() -> None:
    print("\n1. Infinitesimal-amplitude limit")
    print("epsilon       weight(0)              weight(1)              sum")
    for epsilon in (1.0, 0.1, 0.01, 0.001, 0.0001):
        w0, w1 = epsilon_state_weights(epsilon)
        print(f"{epsilon:<12g} {w0:<22.16g} {w1:<22.16g} {w0 + w1:.16g}")
        assert isclose(w0 + w1, 1.0, rel_tol=0.0, abs_tol=1e-15)


def demonstrate_label_invariance() -> None:
    print("\n2. Equal-amplitude obstruction")
    for amplitude in (1.0, 1e-3, 1e6):
        weights = equal_amplitude_weights(amplitude)
        print(f"common amplitude {amplitude:g}: weights = {weights}")
        assert all(isclose(weight, 0.5) for weight in weights)
    print("Changing the labels, even to infinitesimal labels, does not enter this calculation.")


def demonstrate_dirac_collapse() -> None:
    print("\n3. Lexicographic reservoir and standard-part collapse")
    n = 4
    events = [
        ("one visible atom", [0], False),
        ("all visible atoms", range(n), False),
        ("reservoir only", [], True),
        ("whole space", range(n), True),
    ]
    for name, visible, reservoir in events:
        mass = reservoir_event_mass(n, visible, reservoir)
        print(
            f"{name:18s}: exact=({mass.real}, {mass.infinitesimal}), "
            f"standard part={mass.standard_part()}"
        )
    assert reservoir_event_mass(n, range(n), True) == LexValue(Fraction(1), Fraction(0))


def demonstrate_tropical_bridge() -> None:
    print("\n4. Tropical stability and escape")
    stable = tropical_reservoir_integral(3.0, [2.0, 4.0, 1.0], -2.0)
    escaped = tropical_reservoir_integral(3.0, [2.0, 6.5, 1.0], -2.0)
    print(f"stable observable: value={stable[0]}, winner={stable[1]}, margin={stable[2]}")
    print(f"escape observable: value={escaped[0]}, winner={escaped[1]}, margin={escaped[2]}")
    assert stable[1] == "reservoir" and stable[2] >= 0.0
    assert escaped[1] != "reservoir" and escaped[2] < 0.0


def main() -> None:
    print("Quantum Surreal Observation — numerical demonstrations")
    demonstrate_epsilon_collapse()
    demonstrate_label_invariance()
    demonstrate_dirac_collapse()
    demonstrate_tropical_bridge()


if __name__ == "__main__":
    main()
