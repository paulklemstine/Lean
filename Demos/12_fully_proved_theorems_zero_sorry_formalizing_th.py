"""
demo.py — The Complexity-Barrier Lattice
=========================================

Self-contained numerical demonstrations of the results formalized in
`Catalog/Logic/BarrierLattice.lean` (and the supporting catalog file
`CircuitComplexityBarriers.lean`).

We model a *complexity barrier* as a triple (a finite list of techniques, a
strength function valued in the naturals, and a ceiling no technique exceeds).
We then implement the two compositions — JOIN (max-ceiling) and MEET
(min-ceiling) — and verify, on concrete and random instances:

  1. The barrier axiom (every technique's strength is <= the ceiling).
  2. Blocking duality:  JOIN blocks t  <=>  both block t   (logical AND)
                        MEET blocks t  <=>  either blocks t (logical OR)
  3. Blocking is antitone in the ceiling order.
  4. The full distributive-lattice signature on ceilings:
     commutativity, associativity, idempotence, absorption x2, distributivity.
  5. The Shannon bridge:  |BoolFn n| = 2 ** (2 ** n), and any finite inventory
     below that threshold omits a (hard) Boolean function.

Pure standard library; run with `python demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, List, Tuple
import random


# ----------------------------------------------------------------------------
# The barrier structure  (mirrors `BarrierLattice.Barrier`)
# ----------------------------------------------------------------------------

@dataclass(frozen=True)
class Barrier:
    """A complexity barrier.

    Attributes:
        techniques: a finite list of technique labels (the technique space).
        strength:   maps each technique label to a natural-number reach.
        ceiling:    the bound no technique exceeds.
    """
    techniques: Tuple[str, ...]
    strength: Tuple[int, ...]   # strength[i] is the reach of techniques[i]
    ceiling: int

    def __post_init__(self) -> None:
        assert len(self.techniques) == len(self.strength)
        assert len(self.techniques) >= 1, "barrier must be nontrivial (nonempty)"
        assert all(s <= self.ceiling for s in self.strength), \
            "barrier axiom violated: some technique exceeds the ceiling"

    def blocks(self, target: int) -> bool:
        """A barrier blocks a target iff the target exceeds its ceiling."""
        return self.ceiling < target


def join(b1: Barrier, b2: Barrier) -> Barrier:
    """JOIN (max-ceiling composition): both barriers must be overcome.

    Technique space is the product; strength is the per-coordinate max;
    ceiling is the max of the ceilings.
    """
    techs: List[str] = []
    strs: List[int] = []
    for (t1, s1), (t2, s2) in product(zip(b1.techniques, b1.strength),
                                      zip(b2.techniques, b2.strength)):
        techs.append(f"({t1},{t2})")
        strs.append(max(s1, s2))
    return Barrier(tuple(techs), tuple(strs), max(b1.ceiling, b2.ceiling))


def meet(b1: Barrier, b2: Barrier) -> Barrier:
    """MEET (min-ceiling composition): either barrier suffices.

    Technique space is the product; strength is the per-coordinate min
    (the aggregator MUST match the ceiling aggregator for the axiom to hold);
    ceiling is the min of the ceilings.
    """
    techs: List[str] = []
    strs: List[int] = []
    for (t1, s1), (t2, s2) in product(zip(b1.techniques, b1.strength),
                                      zip(b2.techniques, b2.strength)):
        techs.append(f"({t1},{t2})")
        strs.append(min(s1, s2))
    return Barrier(tuple(techs), tuple(strs), min(b1.ceiling, b2.ceiling))


def le(b1: Barrier, b2: Barrier) -> bool:
    """The lattice order: b1 <= b2 iff b1 has the lower (weaker) ceiling."""
    return b1.ceiling <= b2.ceiling


# ----------------------------------------------------------------------------
# Named example barriers (abstract stand-ins for the real obstructions)
# ----------------------------------------------------------------------------

# Ceilings are illustrative natural numbers; in practice they would be the
# largest separation a technique class can establish.
RELATIVIZATION = Barrier(("oracleA", "oracleB"), (3, 5), 5)
NATURAL_PROOFS = Barrier(("largeness", "constructivity"), (4, 7), 7)
ALGEBRIZATION  = Barrier(("lowdeg",), (6,), 6)


# ----------------------------------------------------------------------------
# Demo 1: blocking duality (join = AND, meet = OR)
# ----------------------------------------------------------------------------

def demo_blocking_duality() -> None:
    print("=" * 70)
    print("DEMO 1 — Blocking duality:  join = AND,  meet = OR")
    print("=" * 70)
    j = join(RELATIVIZATION, NATURAL_PROOFS)
    m = meet(RELATIVIZATION, NATURAL_PROOFS)
    print(f"relativization ceiling = {RELATIVIZATION.ceiling}")
    print(f"natural-proofs ceiling = {NATURAL_PROOFS.ceiling}")
    print(f"join ceiling = max = {j.ceiling},  meet ceiling = min = {m.ceiling}")
    print()
    print(f"{'target':>7} | {'R':>5} {'N':>5} | {'join':>6} {'R&N':>5} |"
          f" {'meet':>6} {'R|N':>5}")
    print("-" * 60)
    for t in range(3, 10):
        rb, nb = RELATIVIZATION.blocks(t), NATURAL_PROOFS.blocks(t)
        jb, mb = j.blocks(t), m.blocks(t)
        # the two formally-proved identities:
        assert jb == (rb and nb)
        assert mb == (rb or nb)
        print(f"{t:>7} | {str(rb):>5} {str(nb):>5} | {str(jb):>6} "
              f"{str(rb and nb):>5} | {str(mb):>6} {str(rb or nb):>5}")
    print("\n  All rows satisfy:  join blocks <=> R AND N,  meet blocks <=> R OR N.\n")


# ----------------------------------------------------------------------------
# Demo 2: antitonicity of blocking
# ----------------------------------------------------------------------------

def demo_antitone() -> None:
    print("=" * 70)
    print("DEMO 2 — Blocking is antitone in the ceiling order")
    print("=" * 70)
    weak = ALGEBRIZATION                # ceiling 6
    strong = NATURAL_PROOFS            # ceiling 7
    assert le(weak, strong)
    print(f"weak (algebrization) ceiling   = {weak.ceiling}")
    print(f"strong (natural proofs) ceiling = {strong.ceiling}")
    print("If the strong barrier blocks a target, so must the weaker one:")
    for t in range(5, 11):
        if strong.blocks(t):
            assert weak.blocks(t)
            print(f"  target {t}: strong blocks -> weak also blocks  (OK)")
    print()


# ----------------------------------------------------------------------------
# Demo 3: the distributive-lattice laws on ceilings (randomized stress test)
# ----------------------------------------------------------------------------

def random_barrier(rng: random.Random) -> Barrier:
    c = rng.randint(0, 20)
    k = rng.randint(1, 4)
    strs = tuple(rng.randint(0, c) for _ in range(k))
    techs = tuple(f"t{i}" for i in range(k))
    return Barrier(techs, strs, c)


def demo_lattice_laws(trials: int = 2000) -> None:
    print("=" * 70)
    print(f"DEMO 3 — Distributive-lattice laws on ceilings ({trials} random trials)")
    print("=" * 70)
    rng = random.Random(20260612)
    for _ in range(trials):
        a, b, c = (random_barrier(rng) for _ in range(3))
        # commutativity
        assert join(a, b).ceiling == join(b, a).ceiling
        assert meet(a, b).ceiling == meet(b, a).ceiling
        # associativity
        assert join(join(a, b), c).ceiling == join(a, join(b, c)).ceiling
        assert meet(meet(a, b), c).ceiling == meet(a, meet(b, c)).ceiling
        # idempotence
        assert join(a, a).ceiling == a.ceiling
        assert meet(a, a).ceiling == a.ceiling
        # absorption
        assert join(a, meet(a, b)).ceiling == a.ceiling
        assert meet(a, join(a, b)).ceiling == a.ceiling
        # distributivity
        assert join(a, meet(b, c)).ceiling == meet(join(a, b), join(a, c)).ceiling
    print("  commutativity ...... OK")
    print("  associativity ...... OK")
    print("  idempotence ........ OK")
    print("  absorption x2 ...... OK")
    print("  distributivity ..... OK")
    print(f"\n  All laws held on every one of {trials} random instances.\n")


# ----------------------------------------------------------------------------
# Demo 4: Shannon counting bridge
# ----------------------------------------------------------------------------

def card_bool_fn(n: int) -> int:
    """|BoolFn n| = 2 ** (2 ** n)  (Theorem `card_boolFn`)."""
    return 2 ** (2 ** n)


def enumerate_bool_fns(n: int) -> List[Tuple[bool, ...]]:
    """All Boolean functions on n inputs, as truth tables (length 2**n)."""
    rows = 2 ** n
    return [tuple(bool((k >> i) & 1) for i in range(rows))
            for k in range(2 ** rows)]


def shannon_incomplete(n: int, inventory: List[Tuple[bool, ...]]
                       ) -> Tuple[bool, ...] | None:
    """If the inventory is smaller than |BoolFn n|, return a hard function
    not in it (Theorem `shannon_barrier_incomplete`); else None."""
    if len(inventory) >= card_bool_fn(n):
        return None
    seen = set(inventory)
    for f in enumerate_bool_fns(n):
        if f not in seen:
            return f
    return None


def demo_shannon() -> None:
    print("=" * 70)
    print("DEMO 4 — Shannon bridge:  |BoolFn n| = 2 ** (2 ** n)")
    print("=" * 70)
    for n in range(0, 6):
        print(f"  n = {n}:  |BoolFn n| = 2^(2^{n}) = {card_bool_fn(n)}")
    print()
    n = 2
    all_fns = enumerate_bool_fns(n)
    assert len(all_fns) == card_bool_fn(n)
    # a finite "technique inventory" computing only 10 of the 16 functions:
    rng = random.Random(7)
    inventory = rng.sample(all_fns, 10)
    hard = shannon_incomplete(n, inventory)
    assert hard is not None and hard not in inventory
    print(f"  n = {n}: inventory has {len(inventory)} of {card_bool_fn(n)} functions.")
    print(f"  A guaranteed-hard function omitted by the inventory: truth table {hard}")
    print("  (Any finite inventory below 2^(2^n) must omit at least one function.)\n")


# ----------------------------------------------------------------------------

def main() -> None:
    demo_blocking_duality()
    demo_antitone()
    demo_lattice_laws()
    demo_shannon()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
