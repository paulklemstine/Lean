#!/usr/bin/env python3
"""Numerical illustrations of standard-part non-Archimedean measurement.

Floating-point numbers do not contain genuine infinitesimals.  The epsilon-state
examples therefore use small positive real parameters to display the real family
whose limiting shadow is the standard-part result.  The lexicographic model is
represented exactly by rational pairs.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import isclose
from typing import Dict, Hashable, Iterable, Mapping, Sequence, Tuple, TypeVar

Label = TypeVar("Label", bound=Hashable)


@dataclass(frozen=True)
class LexWeight:
    """Exact value a + b*delta in the two-level lexicographic field."""

    dominant: Fraction
    infinitesimal: Fraction

    def __add__(self, other: "LexWeight") -> "LexWeight":
        return LexWeight(
            self.dominant + other.dominant,
            self.infinitesimal + other.infinitesimal,
        )

    def standard_part(self) -> Fraction:
        """Return the observable dominant coordinate."""
        return self.dominant


def born_distribution(amplitudes: Mapping[Label, float]) -> Dict[Label, float]:
    """Compute normalized squared-amplitude weights in O(number of labels)."""
    norm_sq = sum(value * value for value in amplitudes.values())
    if norm_sq == 0.0:
        raise ValueError("The zero state has no normalized Born distribution.")
    return {label: value * value / norm_sq for label, value in amplitudes.items()}


def epsilon_state_weights(epsilon: float) -> Tuple[float, float]:
    """Return weights of |0> + epsilon|1> for a positive real proxy epsilon."""
    if epsilon <= 0.0:
        raise ValueError("epsilon must be positive")
    weights = born_distribution({"0": 1.0, "1": epsilon})
    return weights["0"], weights["1"]


def equal_amplitude_weights(
    first_label: Label, second_label: Label, amplitude: float
) -> Dict[Label, float]:
    """Compute the equal-amplitude law for two distinct labels."""
    if first_label == second_label:
        raise ValueError("Labels must be distinct coordinates.")
    if amplitude == 0.0:
        raise ValueError("The common amplitude must be nonzero.")
    return born_distribution({first_label: amplitude, second_label: amplitude})


def lexicographic_event_weight(
    visible_count: int, selected_visible: Iterable[int], includes_reservoir: bool
) -> LexWeight:
    """Compute exact event mass in the n-visible-atom reservoir model."""
    if visible_count < 0:
        raise ValueError("visible_count must be nonnegative")
    selected = set(selected_visible)
    if any(index < 0 or index >= visible_count for index in selected):
        raise ValueError("A selected visible index is outside the sample space.")
    result = LexWeight(Fraction(0), Fraction(len(selected)))
    if includes_reservoir:
        result += LexWeight(Fraction(1), Fraction(-visible_count))
    return result


def print_epsilon_table(exponents: Sequence[int]) -> None:
    """Display convergence toward the standard-part shadow (1, 0)."""
    print("\nEpsilon-amplitude state |0> + epsilon|1>")
    print(f"{'epsilon':>14} {'P(0)':>20} {'P(1)':>20} {'sum':>12}")
    for exponent in exponents:
        epsilon = 10.0 ** (-exponent)
        p0, p1 = epsilon_state_weights(epsilon)
        print(f"{epsilon:14.3e} {p0:20.16f} {p1:20.12e} {p0 + p1:12.9f}")
        assert isclose(p0 + p1, 1.0, rel_tol=0.0, abs_tol=1e-15)


def print_label_invariance_demo() -> None:
    """Show that a tiny numerical label does not suppress an equal amplitude."""
    tiny_label = 1.0e-100
    weights = equal_amplitude_weights(0.0, tiny_label, 7.25)
    print("\nEqual amplitudes on labels 0 and 1e-100")
    for label, probability in weights.items():
        print(f"label={label!r:>8}: probability={probability:.6f}")
    assert all(isclose(value, 0.5) for value in weights.values())


def print_lexicographic_demo(visible_count: int) -> None:
    """Enumerate representative events and their exact and observed weights."""
    print(f"\nLexicographic model with {visible_count} visible atoms")
    examples = [
        ([], False, "empty event"),
        ([0], False, "one visible atom"),
        (range(visible_count), False, "all visible atoms"),
        ([], True, "reservoir only"),
        (range(visible_count), True, "whole space"),
    ]
    for selected, reservoir, name in examples:
        weight = lexicographic_event_weight(visible_count, selected, reservoir)
        print(
            f"{name:20} exact=({weight.dominant}, {weight.infinitesimal}) "
            f"observed={weight.standard_part()}"
        )
    whole = lexicographic_event_weight(
        visible_count, range(visible_count), includes_reservoir=True
    )
    assert whole == LexWeight(Fraction(1), Fraction(0))


def main() -> None:
    """Run all demonstrations and internal consistency checks."""
    print_epsilon_table([1, 2, 3, 4, 6])
    print_label_invariance_demo()
    print_lexicographic_demo(3)


if __name__ == "__main__":
    main()
