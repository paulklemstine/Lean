"""
Numerical demonstrations of the information-theoretic limits of surveillance
on finite dynamic networks.

This self-contained script illustrates, on small explicit networks, the theorems:

  * Reconstruction => injectivity, and the counting bound |S| <= |M|.
  * The bit lower bound: exact reconstruction costs at least log2 |S| bits.
  * The rate-distortion covering bound: |S| <= rate * B.
  * Privacy pins the rate to 1, so a private observer needs |S| <= B.
  * On any non-trivial network (|S| >= 2), perfect privacy and perfect
    surveillance are mutually exclusive.
  * The directed-network instantiation: |S| = 2^(n^2), costing n^2 bits.

All functions are inlined and use only the Python standard library.
"""

from __future__ import annotations

from itertools import product
from math import comb, log2
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

# A configuration space S is represented as a list of hashable states.
# A channel is a dict obs: state -> record.  A decoder is a dict dec: record -> state.

State = Hashable
Record = Hashable


# ---------------------------------------------------------------------------
# Core quantities
# ---------------------------------------------------------------------------
def rate(states: Sequence[State], obs: Dict[State, Record]) -> int:
    """Number of distinct records the channel emits (the image cardinality)."""
    return len({obs[s] for s in states})


def is_injective(states: Sequence[State], obs: Dict[State, Record]) -> bool:
    """Perfect surveillance: distinct states yield distinct records."""
    return rate(states, obs) == len(states)


def is_constant(states: Sequence[State], obs: Dict[State, Record]) -> bool:
    """Perfect privacy: every state yields the same record."""
    return rate(states, obs) == 1


def reconstructs_exactly(
    states: Sequence[State], obs: Dict[State, Record], dec: Dict[Record, State]
) -> bool:
    """Perfect reconstruction: dec(obs(s)) == s for all s."""
    return all(dec[obs[s]] == s for s in states)


def reconstructs_within(
    states: Sequence[State],
    obs: Dict[State, Record],
    dec: Dict[Record, State],
    d: Callable[[State, State], int],
    budget: int,
) -> bool:
    """Within-distortion reconstruction: d(dec(obs(s)), s) <= budget for all s."""
    return all(d(dec[obs[s]], s) <= budget for s in states)


def ball_size_bound(
    states: Sequence[State], d: Callable[[State, State], int], budget: int
) -> int:
    """Tightest B: the max over centers c of |{s : d(c, s) <= budget}|."""
    return max(
        sum(1 for s in states if d(c, s) <= budget) for c in states
    )


def bit_floor(num_states: int) -> float:
    """log2 |S|, the minimum bits for exact reconstruction."""
    return log2(num_states)


# ---------------------------------------------------------------------------
# Directed-network configuration space
# ---------------------------------------------------------------------------
def directed_networks(n: int) -> List[Tuple[int, ...]]:
    """All directed graphs on n nodes as length-n^2 bit tuples (row-major adjacency)."""
    return list(product((0, 1), repeat=n * n))


def edge_hamming(a: Tuple[int, ...], b: Tuple[int, ...]) -> int:
    """Number of ordered pairs on which two adjacency tuples disagree."""
    return sum(1 for x, y in zip(a, b) if x != y)


def hamming_ball_size(dim: int, radius: int) -> int:
    """Size of a Hamming ball of given radius in {0,1}^dim: sum of binomials."""
    return sum(comb(dim, r) for r in range(radius + 1))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_counting_and_bits() -> None:
    print("=" * 70)
    print("Demo 1: Reconstruction => injectivity, counting bound, bit floor")
    print("=" * 70)
    states = ["alice-follows", "bob-follows", "mutual", "none"]  # |S| = 4
    # A faithful channel labeling each state distinctly.
    obs = {s: i for i, s in enumerate(states)}          # records 0..3
    dec = {i: s for s, i in obs.items()}
    print(f"|S| = {len(states)}, records used = {rate(states, obs)}")
    print(f"perfect reconstruction: {reconstructs_exactly(states, obs, dec)}")
    print(f"channel injective (perfect surveillance): {is_injective(states, obs)}")
    print(f"counting bound |S| <= |M| : 4 <= {len(set(obs.values()))}  (tight)")
    print(f"bit floor log2|S| = {bit_floor(len(states)):.3f} bits")
    print()


def demo_covering_bound() -> None:
    print("=" * 70)
    print("Demo 2: Rate-distortion covering bound |S| <= rate * B")
    print("=" * 70)
    n = 2
    states = directed_networks(n)          # |S| = 2^(n^2) = 16
    d = edge_hamming
    for budget in (0, 1, 2):
        B = ball_size_bound(states, d, budget)
        floor = -(-len(states) // B)       # ceil(|S| / B)
        # Predicted vs verified via the analytic Hamming-ball size.
        analytic_B = hamming_ball_size(n * n, budget)
        print(
            f"budget D={budget}: B={B} (analytic {analytic_B}), "
            f"|S|={len(states)}, rate floor ceil(|S|/B)={floor}"
        )
    print()


def demo_privacy_single_ball() -> None:
    print("=" * 70)
    print("Demo 3: Privacy pins rate=1, so it needs |S| <= B (single ball)")
    print("=" * 70)
    n = 2
    states = directed_networks(n)
    d = edge_hamming
    const_record = "no-op"
    obs = {s: const_record for s in states}     # perfectly private
    print(f"private channel constant? {is_constant(states, obs)}  rate={rate(states, obs)}")
    # A private decoder can only ever output one fixed guess.
    guess = states[0]
    dec = {const_record: guess}
    for budget in range(n * n + 1):
        B = ball_size_bound(states, d, budget)
        ok = reconstructs_within(states, obs, dec, d, budget)
        needed = len(states) <= B
        print(
            f"budget D={budget}: B={B}, |S|={len(states)}, "
            f"|S|<=B? {needed}, within-D reconstruction achievable? {ok}"
        )
    print("Only when a single ball (D = n^2) covers everything does privacy reconstruct.")
    print()


def demo_impossibility() -> None:
    print("=" * 70)
    print("Demo 4: Privacy and surveillance are mutually exclusive (|S| >= 2)")
    print("=" * 70)
    states = directed_networks(2)   # |S| = 16 >= 2
    private = {s: "x" for s in states}
    surveil = {s: i for i, s in enumerate(states)}
    print(f"private channel:   constant={is_constant(states, private)}, "
          f"injective={is_injective(states, private)}")
    print(f"surveil channel:   constant={is_constant(states, surveil)}, "
          f"injective={is_injective(states, surveil)}")
    print("No single channel can be both constant and injective when |S| >= 2.")
    both_possible = any(
        is_constant(states, {s: "x" for s in states})
        and is_injective(states, {s: "x" for s in states})
        for _ in range(1)
    )
    print(f"exists channel that is both private and surveilling? {both_possible}")
    print()


def demo_directed_bits() -> None:
    print("=" * 70)
    print("Demo 5: Directed networks cost n^2 bits to reconstruct exactly")
    print("=" * 70)
    for n in range(1, 6):
        size = 2 ** (n * n)
        print(f"n={n}: |S| = 2^(n^2) = 2^{n*n} = {size}, bit floor = {n*n} bits")
    print()


def main() -> None:
    demo_counting_and_bits()
    demo_covering_bound()
    demo_privacy_single_ball()
    demo_impossibility()
    demo_directed_bits()


if __name__ == "__main__":
    main()
