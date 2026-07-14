"""
Numerical demonstrations for:

    A Contrarian Fixed-Point Analysis of Causal Loops and the
    Novikov Self-Consistency Principle.

A causal loop is modelled by its one-traversal evolution map
``evolve : X -> X`` on a finite state space ``X`` (represented here as
``range(n)``).  A history is *self-consistent* exactly when ``evolve`` has a
fixed point; the *consistency count* is the number of fixed points.

This script is self-contained (standard library only) and demonstrates every
theorem in the paper on concrete examples.

Run with:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, List, Sequence, Optional


# --------------------------------------------------------------------------- #
# Core model
# --------------------------------------------------------------------------- #

Loop = Callable[[int], int]  # a causal loop on {0, 1, ..., n-1}


def fixed_points(evolve: Loop, n: int) -> List[int]:
    """Return the list of consistent histories (fixed points) of ``evolve``."""
    return [x for x in range(n) if evolve(x) == x]


def consistency_count(evolve: Loop, n: int) -> int:
    """Number of consistent histories of ``evolve`` on ``range(n)``."""
    return len(fixed_points(evolve, n))


def self_consistent(evolve: Loop, n: int) -> bool:
    """Novikov self-consistency: does ``evolve`` admit a fixed point?"""
    return consistency_count(evolve, n) > 0


def iterate(evolve: Loop, k: int) -> Loop:
    """The loop traversed ``k`` times: the k-fold composition of ``evolve``."""

    def repeated(x: int) -> int:
        for _ in range(k):
            x = evolve(x)
        return x

    return repeated


def compose(f: Loop, g: Loop) -> Loop:
    """The composite loop ``f . g`` (apply g, then f)."""
    return lambda x: f(g(x))


def is_bijection(evolve: Loop, n: int) -> bool:
    """Is the evolution map a bijection (reversible loop)?"""
    return len({evolve(x) for x in range(n)}) == n


def is_involutive(evolve: Loop, n: int) -> bool:
    """Is the loop involutive: evolve(evolve(x)) == x for all x?"""
    return all(evolve(evolve(x)) == x for x in range(n))


def from_table(table: Sequence[int]) -> Loop:
    """Build a loop from an explicit value table: table[x] = evolve(x)."""
    return lambda x: table[x]


# --------------------------------------------------------------------------- #
# Eventual consistency (constructive pigeonhole)
# --------------------------------------------------------------------------- #

def least_consistent_power(evolve: Loop, n: int) -> Optional[int]:
    """Smallest k >= 1 such that evolve^[k] is self-consistent, or None.

    Theorem (Eventual consistency): on a finite non-empty state space this is
    always found for some k <= n.
    """
    for k in range(1, n + 1):
        if self_consistent(iterate(evolve, k), n):
            return k
    return None


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_grandfather_and_identity() -> None:
    print("=" * 70)
    print("Concrete counts (Section 5)")
    print("=" * 70)

    grandfather = from_table([1, 0])   # NOT on {0,1}: 0<->1, no fixed point
    identity2 = from_table([0, 1])     # identity on {0,1}

    print(f"Grandfather loop  evolve = NOT  on 2 states:")
    print(f"    fixed points      = {fixed_points(grandfather, 2)}")
    print(f"    consistency count = {consistency_count(grandfather, 2)}  (expected 0)")
    print(f"    self-consistent?  = {self_consistent(grandfather, 2)}  (expected False)")

    print(f"Identity loop on 2 states:")
    print(f"    consistency count = {consistency_count(identity2, 2)}  (expected 2)")
    print()


def demo_disproofs() -> None:
    print("=" * 70)
    print("Disproofs: hypotheses that do NOT force consistency (Section 3)")
    print("=" * 70)

    # 3.1 Reversibility does not force consistency.
    grandfather = from_table([1, 0])
    print("3.1  Reversibility is insufficient:")
    print(f"     grandfather is a bijection?   {is_bijection(grandfather, 2)}")
    print(f"     grandfather self-consistent?  {self_consistent(grandfather, 2)}")
    print("     -> reversible but paradoxical.\n")

    # 3.2 Consistency does not descend along repetition.
    sq = iterate(grandfather, 2)
    print("3.2  Consistency does not descend:")
    print(f"     evolve^[2] self-consistent?   {self_consistent(sq, 2)}")
    print(f"     evolve      self-consistent?  {self_consistent(grandfather, 2)}")
    print("     -> double loop consistent, single loop paradoxical.\n")

    # 3.3 Consistency is not compositional (Fin 3 witnesses).
    f = from_table([1, 0, 2])  # swap 0,1 ; fix 2
    g = from_table([0, 2, 1])  # swap 1,2 ; fix 0
    fg = compose(f, g)
    print("3.3  Consistency is not compositional (on 3 states):")
    print(f"     f self-consistent? {self_consistent(f, 3)}  fixes {fixed_points(f, 3)}")
    print(f"     g self-consistent? {self_consistent(g, 3)}  fixes {fixed_points(g, 3)}")
    print(f"     f.g mapping: {[fg(x) for x in range(3)]}  (the 3-cycle 0->1->2->0)")
    print(f"     f.g self-consistent? {self_consistent(fg, 3)}")
    print("     -> two consistent loops compose to a paradox.\n")


def demo_proofs() -> None:
    print("=" * 70)
    print("Proofs: hypotheses that DO force consistency (Section 4)")
    print("=" * 70)

    # 4.1 Consistency ascends.
    consistent_loop = from_table([0, 2, 1])  # fixes 0, swaps 1,2
    print("4.1  Consistency ascends along repetition:")
    for k in range(1, 5):
        print(f"     evolve^[{k}] self-consistent? {self_consistent(iterate(consistent_loop, k), 3)}")
    print()

    # 4.3 / 4.4 Parity congruence for involutions.
    print("4.3/4.4  Parity congruence  c(evolve) = |X|  (mod 2)  for involutions:")
    involutions = {
        "NOT on 2 states": (from_table([1, 0]), 2),
        "identity on 2":   (from_table([0, 1]), 2),
        "swap 1,2 fix 0 (3 states, odd)": (from_table([0, 2, 1]), 3),
        "identity on 3 (odd)": (from_table([0, 1, 2]), 3),
        "double swap on 4": (from_table([1, 0, 3, 2]), 4),
    }
    for name, (loop, n) in involutions.items():
        c = consistency_count(loop, n)
        ok = (c % 2) == (n % 2)
        odd_world = " [odd world => forced consistent]" if n % 2 == 1 else ""
        print(f"     {name:34s}  |X|={n}  count={c}  "
              f"congruence holds? {ok}{odd_world}")
    print()

    # 4.5 Eventual consistency.
    print("4.5  Eventual consistency (least k with evolve^[k] consistent):")
    three_cycle = from_table([1, 2, 0])         # no fixed point at k=1
    four_cycle = from_table([1, 2, 3, 0])
    print(f"     3-cycle on 3 states: least consistent power = "
          f"{least_consistent_power(three_cycle, 3)}")
    print(f"     4-cycle on 4 states: least consistent power = "
          f"{least_consistent_power(four_cycle, 4)}")
    print()


def demo_contraction() -> None:
    print("=" * 70)
    print("4.2  Deterministic time travel: contraction => unique history")
    print("=" * 70)
    # A contraction on the real line: evolve(x) = 0.5 x + 3, constant K = 0.5.
    # Unique fixed point solves x = 0.5 x + 3  =>  x = 6.
    def evolve(x: float) -> float:
        return 0.5 * x + 3.0

    x = 100.0  # arbitrary starting guess
    for _ in range(60):
        x = evolve(x)
    print(f"     evolve(x) = 0.5 x + 3, contraction constant K = 0.5")
    print(f"     iterating from x0=100 converges to x* = {x:.10f}  (exact: 6)")
    print(f"     unique consistent history guaranteed by the Banach theorem.\n")


def main() -> None:
    demo_grandfather_and_identity()
    demo_disproofs()
    demo_proofs()
    demo_contraction()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
