"""
Numerical demonstrations of bounded-error surveillance and the sharp
rate-distortion law for finite dynamic networks.

All functions are self-contained and type-hinted. Running this script prints
worked examples that illustrate each theorem:

  * rate of a channel and the trivial ceiling rate <= |M|
  * reconstruction limited by rate: |recon set| <= rate
  * combinatorial Fano bound: |S| <= rate + #errors
  * minimum rate / bits for bounded-error surveillance
  * privacy forces near-total error (rate 1 => #errors >= |S| - 1)
  * achieving distortion D induces a D-cover of size <= rate
  * every D-cover is realised by a channel of rate <= |C|
  * sharp rate-distortion law: min achievable rate = D-covering number
"""

from __future__ import annotations

from itertools import combinations, product
from math import log2
from typing import Callable, Dict, Hashable, List, Optional, Sequence, Tuple

State = Hashable
Record = Hashable


# --------------------------------------------------------------------------
# Core quantities
# --------------------------------------------------------------------------

def rate(states: Sequence[State], obs: Callable[[State], Record]) -> int:
    """Number of distinct records the channel emits: |obs(S)|."""
    return len({obs(s) for s in states})


def recon_set(
    states: Sequence[State],
    obs: Callable[[State], Record],
    dec: Callable[[Record], State],
) -> List[State]:
    """Configurations reconstructed correctly: dec(obs(s)) == s."""
    return [s for s in states if dec(obs(s)) == s]


def err_set(
    states: Sequence[State],
    obs: Callable[[State], Record],
    dec: Callable[[Record], State],
) -> List[State]:
    """Configurations reconstructed incorrectly: dec(obs(s)) != s."""
    return [s for s in states if dec(obs(s)) != s]


def min_bits_for_error_budget(num_states: int, k: int) -> float:
    """Minimum bits to reconstruct all but k configs: log2(|S| - k)."""
    remaining = max(num_states - k, 0)
    return log2(remaining) if remaining > 0 else float("-inf")


# --------------------------------------------------------------------------
# Covers and distortion
# --------------------------------------------------------------------------

def is_d_cover(
    states: Sequence[State],
    d: Callable[[State, State], int],
    budget: int,
    centers: Sequence[State],
) -> bool:
    """True iff every state lies within `budget` of some center."""
    return all(any(d(c, s) <= budget for c in centers) for s in states)


def achieves_distortion(
    states: Sequence[State],
    obs: Callable[[State], Record],
    dec: Callable[[Record], State],
    d: Callable[[State, State], int],
    budget: int,
) -> bool:
    """True iff d(dec(obs(s)), s) <= budget for all s."""
    return all(d(dec(obs(s)), s) <= budget for s in states)


def covering_number(
    states: Sequence[State],
    d: Callable[[State, State], int],
    budget: int,
) -> int:
    """Exact D-covering number by brute-force minimum set cover (small |S|)."""
    n = len(states)
    for size in range(0, n + 1):
        for centers in combinations(states, size):
            if is_d_cover(states, d, budget, centers):
                return size
    return n


def channel_from_cover(
    states: Sequence[State],
    d: Callable[[State, State], int],
    budget: int,
    centers: Sequence[State],
) -> Tuple[Callable[[State], State], Callable[[State], State]]:
    """Realise a D-cover as a channel (map each s to a near center) + id decoder.

    Implements Theorem 4.2 (Covering implies achieving).
    """
    assignment: Dict[State, State] = {}
    for s in states:
        for c in centers:
            if d(c, s) <= budget:
                assignment[s] = c
                break
    obs: Callable[[State], State] = lambda s: assignment[s]
    dec: Callable[[State], State] = lambda r: r
    return obs, dec


def greedy_cover(
    states: Sequence[State],
    d: Callable[[State, State], int],
    budget: int,
) -> List[State]:
    """Greedy (1 + ln|S|)-approximate D-cover / rate upper bound."""
    uncovered = set(states)
    centers: List[State] = []
    while uncovered:
        best: Optional[State] = None
        best_gain = -1
        for c in states:
            gain = sum(1 for s in uncovered if d(c, s) <= budget)
            if gain > best_gain:
                best_gain, best = gain, c
        assert best is not None
        centers.append(best)
        uncovered = {s for s in uncovered if d(best, s) > budget}
    return centers


# --------------------------------------------------------------------------
# Example network: graphs on 3 labelled nodes, compared by edge-flip distance
# --------------------------------------------------------------------------

def three_node_graphs() -> List[Tuple[int, int, int]]:
    """All 2^3 undirected graphs on nodes {0,1,2}, as edge-indicator triples
    (e01, e02, e12)."""
    return list(product((0, 1), repeat=3))


def hamming(a: Tuple[int, ...], b: Tuple[int, ...]) -> int:
    """Edge-flip (Hamming) distance between two adjacency indicators."""
    return sum(x != y for x, y in zip(a, b))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_fano() -> None:
    print("=" * 70)
    print("Combinatorial Fano bound  |S| <= rate + #errors")
    print("=" * 70)
    states = list(range(8))  # |S| = 8

    # A rate-3 channel: collapse states into 3 records by s % 3.
    obs: Callable[[int], int] = lambda s: s % 3
    # Best-effort decoder: pick a canonical representative per record.
    dec: Callable[[int], int] = lambda r: r  # decodes to 0,1,2

    r = rate(states, obs)
    errors = err_set(states, obs, dec)
    correct = recon_set(states, obs, dec)
    print(f"|S| = {len(states)}, rate = {r}")
    print(f"correctly reconstructed = {correct}  (|R| = {len(correct)})")
    print(f"errors                  = {errors}   (#E = {len(errors)})")
    print(f"check |R| <= rate           : {len(correct)} <= {r}  ->",
          len(correct) <= r)
    print(f"check |S| <= rate + #errors : {len(states)} <= {r + len(errors)}  ->",
          len(states) <= r + len(errors))
    for k in (0, 2, 5):
        print(f"  budget k={k}: min rate >= {max(len(states) - k, 0)}, "
              f"min bits >= {min_bits_for_error_budget(len(states), k):.3f}")


def demo_privacy() -> None:
    print("\n" + "=" * 70)
    print("Privacy forces near-total error  (rate 1  =>  #errors >= |S| - 1)")
    print("=" * 70)
    states = list(range(6))
    obs: Callable[[int], int] = lambda s: 0  # perfectly private: constant
    # The optimal decoder can only ever be right about one state.
    dec: Callable[[int], int] = lambda r: 3
    r = rate(states, obs)
    errors = err_set(states, obs, dec)
    print(f"|S| = {len(states)}, rate (private) = {r}")
    print(f"#errors = {len(errors)}  (guaranteed >= {len(states) - 1})  ->",
          len(errors) >= len(states) - 1)


def demo_rate_distortion() -> None:
    print("\n" + "=" * 70)
    print("Sharp rate-distortion law  min achievable rate = D-covering number")
    print("=" * 70)
    states = three_node_graphs()
    d = hamming
    print(f"State space: {len(states)} graphs on 3 nodes, edge-flip distance")
    print(f"{'D':>3} | {'cov#(D)':>7} | {'greedy':>6} | "
          f"{'realised rate':>13} | achieves?")
    print("-" * 55)
    for D in range(0, 4):
        cov = covering_number(states, d, D)
        # Realise an optimal cover as a channel and check it achieves D.
        opt_cover: Optional[Tuple[State, ...]] = None
        for centers in combinations(states, cov):
            if is_d_cover(states, d, D, centers):
                opt_cover = centers
                break
        assert opt_cover is not None
        obs, dec = channel_from_cover(states, d, D, opt_cover)
        realised = rate(states, obs)
        ok = achieves_distortion(states, obs, dec, d, D)
        greedy = len(greedy_cover(states, d, D))
        print(f"{D:>3} | {cov:>7} | {greedy:>6} | {realised:>13} | {ok}")
    print("\nEquality of columns 'cov#(D)' and 'realised rate' verifies")
    print("Rate*(D) = Cov_d(D) on this network.")


def main() -> None:
    demo_fano()
    demo_privacy()
    demo_rate_distortion()


if __name__ == "__main__":
    main()
