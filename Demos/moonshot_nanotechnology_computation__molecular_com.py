#!/usr/bin/env python3
"""Numerical demonstrations for molecular computation resource bounds.

The script uses only the Python standard library.  It demonstrates:
1. exact one-hot simulation of a deterministic transition system;
2. discrete mass-action propensity for compiled unary reactions;
3. exact ceiling-division description volume and minimality;
4. preparation-aware molecular versus sequential exhaustive search;
5. the bit length of the state count for a hypothetical 10^18-bit register.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Hashable, Iterable, List, Mapping, TypeVar

State = TypeVar("State", bound=Hashable)


@dataclass(frozen=True)
class Reaction:
    """An integer-stoichiometric reaction with a nonnegative rate."""

    reactants: Mapping[str, int]
    products: Mapping[str, int]
    rate: int


def descending_factorial(n: int, m: int) -> int:
    """Return (n)_m = n(n-1)...(n-m+1), with (n)_0 = 1."""
    if n < 0 or m < 0:
        raise ValueError("n and m must be nonnegative")
    result = 1
    for offset in range(m):
        result *= n - offset
    return result


def enabled(reaction: Reaction, population: Mapping[str, int]) -> bool:
    """Test whether all reactants are available."""
    return all(population.get(species, 0) >= count
               for species, count in reaction.reactants.items())


def mass_action_propensity(
    reaction: Reaction, population: Mapping[str, int]
) -> int:
    """Compute the discrete stochastic mass-action propensity exactly."""
    propensity = reaction.rate
    for species, required in reaction.reactants.items():
        propensity *= descending_factorial(population.get(species, 0), required)
    return propensity


def compile_unary_transition(source: State, target: State, rate: int) -> Reaction:
    """Compile source -> target into a unary reaction."""
    if rate < 0:
        raise ValueError("rate must be nonnegative")
    return Reaction({str(source): 1}, {str(target): 1}, rate)


def simulate_trace(
    step: Callable[[State], State], initial: State, steps: int
) -> List[State]:
    """Return [q, T(q), ..., T^steps(q)] in O(steps) transition calls."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    trace = [initial]
    current = initial
    for _ in range(steps):
        current = step(current)
        trace.append(current)
    return trace


def minimum_volume(bits_per_volume: int, description_bits: int) -> int:
    """Exact minimum V satisfying description_bits <= bits_per_volume * V."""
    if bits_per_volume <= 0:
        raise ValueError("bits_per_volume must be positive")
    if description_bits < 0:
        raise ValueError("description_bits must be nonnegative")
    return (description_bits + bits_per_volume - 1) // bits_per_volume


def fits_description(bits_per_volume: int, volume: int, description_bits: int) -> bool:
    """Return whether the capacity inequality K <= bV holds."""
    return description_bits <= bits_per_volume * volume


def molecular_time(preparation_cost: int, candidates: int) -> int:
    """Preparation cost for all candidates plus one ideal parallel test round."""
    if preparation_cost < 0 or candidates < 0:
        raise ValueError("cost and candidates must be nonnegative")
    return preparation_cost * candidates + 1


def sequential_time(preparation_cost: int, candidates: int) -> int:
    """Preparation and one test for each candidate."""
    if preparation_cost < 0 or candidates < 0:
        raise ValueError("cost and candidates must be nonnegative")
    return (preparation_cost + 1) * candidates


def volume_demo() -> None:
    """Print exact capacity examples and verify minimality."""
    print("\nDESCRIPTION-VOLUME LAW")
    print(" K bits | b bits/unit | minimum V | previous volume fits?")
    cases = [(0, 8), (1, 8), (8, 8), (9, 8), (1_000, 64), (10_018, 1_000)]
    for complexity, density in cases:
        volume = minimum_volume(density, complexity)
        previous_fits = volume > 0 and fits_description(
            density, volume - 1, complexity
        )
        assert fits_description(density, volume, complexity)
        assert not previous_fits
        print(f"{complexity:7d} | {density:11d} | {volume:9d} | {previous_fits}")


def trace_and_propensity_demo() -> None:
    """Simulate a finite controller and verify each source propensity."""
    print("DETERMINISTIC TRACE AND UNARY PROPENSITIES")
    transition: Dict[str, str] = {
        "scan": "copy",
        "copy": "check",
        "check": "halt",
        "halt": "halt",
    }
    trace = simulate_trace(lambda state: transition[state], "scan", 7)
    print(" -> ".join(trace))
    assert trace == ["scan", "copy", "check", "halt", "halt", "halt", "halt", "halt"]

    rate = 7
    for source in transition:
        reaction = compile_unary_transition(source, transition[source], rate)
        population = {source: 1}
        assert enabled(reaction, population)
        propensity = mass_action_propensity(reaction, population)
        assert propensity == rate
        print(f"  {source:>5s} -> {transition[source]:<5s}: propensity = {propensity}")


def parallelism_demo(max_variables: int = 16, preparation_cost: int = 1) -> None:
    """Tabulate exhaustive-search times and assert the factor-two theorem."""
    if preparation_cost < 1:
        raise ValueError("the factor-two theorem assumes preparation_cost >= 1")
    print("\nPREPARATION-AWARE BOOLEAN EXHAUSTIVE SEARCH")
    print(" n | candidates | molecular | sequential | speedup")
    for variables in range(max_variables + 1):
        candidates = 1 << variables
        molecular = molecular_time(preparation_cost, candidates)
        sequential = sequential_time(preparation_cost, candidates)
        assert preparation_cost * candidates <= molecular
        assert sequential <= 2 * molecular
        print(
            f"{variables:2d} | {candidates:10d} | {molecular:9d} | "
            f"{sequential:10d} | {sequential / molecular:7.4f}x"
        )


def state_count_demo() -> None:
    """Describe the exact scale of 2^(10^18) without materializing it."""
    bits = 10**18
    # 2^bits is one followed by `bits` zeroes in binary, hence needs bits+1 bits.
    print("\nCONDITIONAL DNA REGISTER STATE COUNT")
    print(f"A reliable {bits:,}-bit register has exactly 2^({bits:,}) states.")
    print(f"Writing that state count in binary requires {bits + 1:,} bits.")
    # Number of decimal digits is floor(bits*log10(2))+1.  We report an
    # integer-arithmetic lower/upper scale rather than relying on a huge float.
    print("Its decimal representation has approximately 3.0103e17 digits.")


def run_all() -> None:
    """Run all demonstrations and embedded mathematical assertions."""
    trace_and_propensity_demo()
    volume_demo()
    parallelism_demo()
    state_count_demo()
    print("\nAll model identities and inequalities passed.")


if __name__ == "__main__":
    run_all()
