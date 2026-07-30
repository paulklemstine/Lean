#!/usr/bin/env python3
"""Finite demonstrations of diagonal self-models, fixed-point obstructions, and probing."""

from __future__ import annotations

from itertools import product
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)
X = TypeVar("X")
Observer = tuple[B, ...]
Model = tuple[Observer[B], ...]


def all_observers(observation_values: Sequence[B], state_count: int) -> list[Observer[B]]:
    """Enumerate every observer on a finite indexed state space."""
    return list(product(observation_values, repeat=state_count))


def is_complete(model: Model[B], observation_values: Sequence[B]) -> bool:
    """Test whether the rows of a finite model represent every observer."""
    state_count = len(model)
    if any(len(row) != state_count for row in model):
        raise ValueError("A model with n states must have n entries in every observer row")
    return set(model) == set(all_observers(observation_values, state_count))


def diagonal(model: Model[B]) -> Observer[B]:
    """Return d(a) = I(a)(a) for an indexed square model table."""
    if any(len(row) != len(model) for row in model):
        raise ValueError("The interpretation table must be square")
    return tuple(row[index] for index, row in enumerate(model))


def find_diagonal_witness(model: Model[B], transform: Callable[[B], B]) -> tuple[int, B] | None:
    """Find a state representing x ↦ g(d(x)); verify its diagonal is fixed."""
    diag = diagonal(model)
    target = tuple(transform(value) for value in diag)
    for state, represented_observer in enumerate(model):
        if represented_observer == target:
            value = diag[state]
            if transform(value) != value:
                raise AssertionError("Diagonal equality should force a fixed point")
            return state, value
    return None


def fixed_point_free(values: Iterable[B], transform: Callable[[B], B]) -> bool:
    """Return whether g(b) differs from b at every supplied observation."""
    return all(transform(value) != value for value in values)


def orbit(transform: Callable[[B], B], start: B, length: int) -> list[B]:
    """Compute b, g(b), ..., g^length(b)."""
    if length < 0:
        raise ValueError("Orbit length must be nonnegative")
    result = [start]
    for _ in range(length):
        result.append(transform(result[-1]))
    return result


def probe(observer: Sequence[B], test: Callable[[B], X]) -> tuple[X, ...]:
    """Compose an observer with a downstream test."""
    return tuple(test(value) for value in observer)


def omitted_observer_count(state_count: int, observation_count: int) -> int:
    """Lower bound on omitted observers for a finite interpretation map."""
    if state_count < 0 or observation_count < 0:
        raise ValueError("Cardinalities must be nonnegative")
    total = observation_count**state_count
    return max(0, total - state_count)


def demonstrate() -> None:
    """Print three numerical experiments tied to the main results."""
    print("DEMO 1 — The unique complete nonempty model")
    singleton_model: Model[int] = ((7,),)
    print("model:", singleton_model)
    print("complete:", is_complete(singleton_model, [7]))
    witness = find_diagonal_witness(singleton_model, lambda _: 7)
    print("diagonal witness (state, fixed observation):", witness)
    print("closed orbit through 8 steps:", orbit(lambda _: 7, 7, 8))

    print("\nDEMO 2 — Boolean negation obstructs completeness")
    boolean_values = [False, True]
    negate = lambda value: not value
    print("negation is fixed-point-free:", fixed_point_free(boolean_values, negate))
    for states in range(1, 5):
        total = 2**states
        represented_at_most = states
        omitted = omitted_observer_count(states, 2)
        print(
            f"{states} state(s): {total} Boolean observers, "
            f"at most {represented_at_most} represented, at least {omitted} omitted"
        )

    print("\nDEMO 3 — Identity probing recovers an observer")
    observer = (2, 0, 3, 1)
    identity_result = probe(observer, lambda value: value)
    parity_result = probe(observer, lambda value: value % 2)
    threshold_result = probe(observer, lambda value: value >= 2)
    print("observer:", observer)
    print("identity probe:", identity_result)
    print("parity probe:", parity_result)
    print("threshold probe:", threshold_result)
    assert identity_result == observer


if __name__ == "__main__":
    demonstrate()
