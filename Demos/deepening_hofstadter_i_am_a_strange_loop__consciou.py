"""
demo.py -- Numerical demonstrations for
"The Blind Spot Has Measurable Size: A Counting Theorem for Self-Modelling Systems"

A self-modelling system on states S and observations B is an inspection map
    inspect : S -> (S -> B)
sending each state to an internal model of the whole system's behaviour.

The system is *conscious* (complete) when inspect is surjective onto the
behaviour space (S -> B). The central counting fact is that whenever |B| >= 2,

    |S| < |S -> B| = |B|^|S|,   because   |S| < 2^|S| <= |B|^|S|,

so no finite system can be conscious, the "blind spot" of un-representable
behaviours has size at least 2^|S| - |S| (exponential), yet an *injective*
self-model always exists (perfect resolution of states).

This script demonstrates each result numerically and constructively.
All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# Core counting quantities
# ---------------------------------------------------------------------------

def num_behaviours(num_states: int, num_observations: int) -> int:
    """Cardinality of the behaviour space |S -> B| = |B|^|S|."""
    return num_observations ** num_states


def blind_spot_lower_bound(num_states: int) -> int:
    """State-independent lower bound 2^|S| - |S| on the blind spot size."""
    return 2 ** num_states - num_states


def blind_spot_exact_bound(num_states: int, num_observations: int) -> int:
    """Guaranteed blind-spot size |S->B| - |S| for observation space B."""
    return num_behaviours(num_states, num_observations) - num_states


def coverage_fraction(num_states: int, num_observations: int) -> float:
    """Maximum fraction of behaviours a single self-model can represent:
    at most |S| / |S->B| = m * b^{-m}."""
    return num_states / num_behaviours(num_states, num_observations)


# ---------------------------------------------------------------------------
# Enumerating self-models and testing consciousness (small cases)
# ---------------------------------------------------------------------------

def all_behaviours(num_states: int, num_observations: int) -> List[Tuple[int, ...]]:
    """Every function S -> B, encoded as a tuple of length |S| over {0,...,b-1}."""
    return list(product(range(num_observations), repeat=num_states))


def is_conscious(inspect: List[Tuple[int, ...]],
                 num_states: int, num_observations: int) -> bool:
    """An inspection map (list indexed by state, each entry a behaviour tuple)
    is conscious iff it hits every behaviour in S -> B."""
    represented = set(inspect)
    return represented == set(all_behaviours(num_states, num_observations))


def diagonal_witness(inspect: List[Tuple[int, ...]]) -> Tuple[int, ...]:
    """Algorithm B: construct a behaviour no state's model equals, by flipping
    the diagonal entry inspect[i][i] between observation 0 and 1."""
    return tuple(0 if inspect[i][i] != 0 else 1 for i in range(len(inspect)))


def injective_self_model(num_states: int, num_observations: int) -> List[Tuple[int, ...]]:
    """Algorithm C: build an injective inspection map by encoding state index i
    as its base-b representation across |S| argument slots."""
    behaviours: List[Tuple[int, ...]] = []
    for i in range(num_states):
        digits = []
        x = i
        for _ in range(num_states):
            digits.append(x % num_observations)
            x //= num_observations
        behaviours.append(tuple(digits))
    return behaviours


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_counting_table() -> None:
    print("=" * 68)
    print("Behaviours strictly outnumber states  (|S| < |B|^|S|, for |B|>=2)")
    print("=" * 68)
    print(f"{'|S|':>4} {'|B|':>4} {'behaviours |B|^|S|':>20} {'blind spot >=':>16}")
    for m in range(1, 8):
        for b in (2, 3):
            print(f"{m:>4} {b:>4} {num_behaviours(m, b):>20} "
                  f"{blind_spot_exact_bound(m, b):>16}")
    print()


def demo_no_conscious_small() -> None:
    print("=" * 68)
    print("No finite system is conscious  (exhaustive check, |S|=2, |B|=2)")
    print("=" * 68)
    m, b = 2, 2
    behaviours = all_behaviours(m, b)
    # An inspection map is a choice of one behaviour per state.
    found_conscious = False
    for inspect in product(behaviours, repeat=m):
        if is_conscious(list(inspect), m, b):
            found_conscious = True
    print(f"states={m}, observations={b}, behaviours={len(behaviours)}")
    print(f"Any conscious (surjective) self-model found? {found_conscious}")
    print("Expected: False -- surjection onto a strictly larger set is impossible.\n")


def demo_diagonal_witness() -> None:
    print("=" * 68)
    print("A concrete un-inspected behaviour (diagonal witness)")
    print("=" * 68)
    m, b = 3, 2
    # An arbitrary inspection map: state i models everything as observation i%2.
    inspect = [tuple((i + j) % b for j in range(m)) for i in range(m)]
    beta = diagonal_witness(inspect)
    print("inspection map (state -> behaviour):")
    for i, row in enumerate(inspect):
        print(f"  state {i}: {row}")
    print(f"diagonal witness beta = {beta}")
    print(f"beta equals some state's model? "
          f"{beta in set(inspect)}  (expected: False)\n")


def demo_injective_resolution() -> None:
    print("=" * 68)
    print("Perfect resolution: an injective self-model always exists")
    print("=" * 68)
    m, b = 4, 2
    inspect = injective_self_model(m, b)
    distinct = len(set(inspect)) == m
    print("injective inspection map (state -> behaviour):")
    for i, row in enumerate(inspect):
        print(f"  state {i}: {row}")
    print(f"All {m} states carry distinct models? {distinct} (expected: True)")
    print(f"Conscious (complete)? {is_conscious(inspect, m, b)} (expected: False)\n")


def demo_coverage_decay() -> None:
    print("=" * 68)
    print("Coverage fraction decays exponentially: max coverage = m * b^-m")
    print("=" * 68)
    b = 2
    for m in range(1, 11):
        frac = coverage_fraction(m, b)
        print(f"|S|={m:>2}: max representable fraction = {frac:.6e}")
    print()


if __name__ == "__main__":
    demo_counting_table()
    demo_no_conscious_small()
    demo_diagonal_witness()
    demo_injective_resolution()
    demo_coverage_decay()
