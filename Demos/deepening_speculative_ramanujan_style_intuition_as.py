"""
Numerical demonstrations for:

    Ramanujan Oracles Cannot Be Computable: A Counting Argument

We model the abstract objects of the paper over a finite prefix of statements
(the first N Goedel-numbered statements) so that everything is concrete and
computable:

    * A "ground truth"  T : N -> {0, 1}     (a world / answer key)
    * An "oracle"       O : N -> {0, 1, None}   (None = "unknown")
    * "Correct(O, T, n)"  iff  O[n] == T[n]  (a None answer is never correct)
    * "Perfect(O, T)"     iff  O is correct on every statement

The theorems illustrated:

    * exists_perfect_oracle   -- the echo oracle is perfect for its world.
    * perfect_unique          -- a perfect oracle determines its world uniquely.
    * counting mismatch       -- 2^N worlds vs. a countable list of oracles.
    * adversarial world       -- drives any oracle's accuracy to exactly 0.
    * block diagonalization   -- one world defeats a whole family at once.
    * no guaranteed accuracy  -- the adversary refutes any fixed accuracy bound.

Everything is self-contained; run `python demo.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Optional, Sequence

# A truth value world is a tuple of bits; an oracle answer is 0, 1, or None.
Truth = Sequence[int]
Oracle = Sequence[Optional[int]]


# --------------------------------------------------------------------------- #
# Core predicates                                                             #
# --------------------------------------------------------------------------- #
def correct(oracle: Oracle, truth: Truth, n: int) -> bool:
    """Correct(O, T, n): the oracle commits to the true verdict at n."""
    return oracle[n] is not None and oracle[n] == truth[n]


def perfect_on(oracle: Oracle, truth: Truth) -> bool:
    """Perfect(O, T): correct on every statement in the prefix."""
    return all(correct(oracle, truth, n) for n in range(len(truth)))


def echo_oracle(truth: Truth) -> Oracle:
    """The echo oracle O(n) = T(n); perfect for exactly this world."""
    return list(truth)


def adversary(oracle: Oracle) -> Truth:
    """The adversarial world: opposite of every committed answer.

    Where the oracle says None (unknown), we output 1 (any value works).
    Guarantees the oracle is correct on *no* statement.
    """
    return [(1 - a) if a is not None else 1 for a in oracle]


def hits(oracle: Oracle, truth: Truth, upto: int) -> int:
    """Number of correct commitments among the first `upto` statements."""
    return sum(1 for n in range(upto) if correct(oracle, truth, n))


def all_worlds(n: int) -> List[Truth]:
    """All 2^n possible ground truths on a prefix of length n."""
    return [list(bits) for bits in product((0, 1), repeat=n)]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_perfect_unique(n: int = 4) -> None:
    """Each oracle is perfect for at most one world (perfect_unique)."""
    print("=" * 68)
    print("Demo 1: a perfect oracle determines its world uniquely")
    print("=" * 68)
    worlds = all_worlds(n)
    world = worlds[5]  # pick one world
    oracle = echo_oracle(world)
    matches = [w for w in worlds if perfect_on(oracle, w)]
    print(f"  prefix length n = {n},  #worlds = {len(worlds)}")
    print(f"  chosen world   = {world}")
    print(f"  echo oracle is perfect for exactly {len(matches)} world(s): {matches}")
    assert len(matches) == 1 and matches[0] == list(world)
    print("  -> confirmed: perfect for exactly one world.\n")


def demo_counting_mismatch(n: int = 6, num_oracles: int = 10) -> None:
    """A short list of oracles covers only a tiny fraction of worlds."""
    print("=" * 68)
    print("Demo 2: counting mismatch (few oracles cannot cover many worlds)")
    print("=" * 68)
    worlds = all_worlds(n)
    # A "countable family" modeled by the first `num_oracles` echo oracles.
    family: List[Oracle] = [echo_oracle(worlds[i]) for i in range(num_oracles)]
    covered = {tuple(w) for w in worlds if any(perfect_on(o, w) for o in family)}
    print(f"  #worlds (2^{n})       = {len(worlds)}")
    print(f"  #oracles in family    = {num_oracles}")
    print(f"  #worlds covered       = {len(covered)}  (<= #oracles)")
    print(f"  #worlds MISSED        = {len(worlds) - len(covered)}")
    assert len(covered) <= num_oracles
    print("  -> a finite/countable family covers <= (its size) worlds.\n")


def demo_adversary(n: int = 8) -> None:
    """The adversarial world drives an oracle's accuracy to 0 (no_accuracy)."""
    print("=" * 68)
    print("Demo 3: adversarial world -> accuracy identically zero")
    print("=" * 68)
    # An arbitrary (even partly "unknown") oracle.
    oracle: Oracle = [0, 1, None, 1, 0, None, 1, 0][:n]
    adv = adversary(oracle)
    print(f"  oracle           = {oracle}")
    print(f"  adversarial world= {adv}")
    for upto in range(1, n + 1):
        h = hits(oracle, adv, upto)
        print(f"    hits among first {upto}: {h}  (accuracy {h/upto:.0%})")
    assert all(hits(oracle, adv, upto) == 0 for upto in range(1, n + 1))
    print("  -> the 95% (or any positive) accuracy guarantee is refuted.\n")


def demo_block_diagonalization(block_size: int = 3, num_oracles: int = 4) -> None:
    """One world defeats an entire family at once (block diagonalization)."""
    print("=" * 68)
    print("Demo 4: block diagonalization defeats a whole family")
    print("=" * 68)
    n = block_size * num_oracles
    # Family of arbitrary oracles.
    family: List[Oracle] = [
        [(i + k) % 2 for k in range(n)] for i in range(num_oracles)
    ]
    # Block-diagonal world: on block i, play adversary against oracle i.
    world: List[int] = [0] * n
    for i in range(num_oracles):
        adv_i = adversary(family[i])
        for k in range(block_size):
            idx = i * block_size + k
            world[idx] = adv_i[idx]
    print(f"  n = {n}, {num_oracles} oracles, block size {block_size}")
    print(f"  block-diagonal world = {world}")
    for i, o in enumerate(family):
        block_idx = range(i * block_size, (i + 1) * block_size)
        errs = sum(1 for idx in block_idx if not correct(o, world, idx))
        print(f"    oracle {i}: wrong on {errs}/{block_size} of its own block")
        assert errs == block_size
    print("  -> every oracle errs on its entire block simultaneously.\n")


def demo_no_universal_oracle(n: int = 4) -> None:
    """No single oracle is perfect for every world (no_universal_oracle)."""
    print("=" * 68)
    print("Demo 5: no single oracle is perfect for every world")
    print("=" * 68)
    worlds = all_worlds(n)
    # Try any fixed oracle; count worlds it is perfect for.
    candidate: Oracle = [0] * n
    good = [w for w in worlds if perfect_on(candidate, w)]
    print(f"  candidate oracle = {candidate}")
    print(f"  perfect for {len(good)} of {len(worlds)} worlds; misses "
          f"{len(worlds) - len(good)}")
    assert len(good) < len(worlds)
    print("  -> a universal oracle would need to cover all worlds; impossible.\n")


def main() -> None:
    demo_perfect_unique()
    demo_counting_mismatch()
    demo_adversary()
    demo_block_diagonalization()
    demo_no_universal_oracle()
    print("All demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
