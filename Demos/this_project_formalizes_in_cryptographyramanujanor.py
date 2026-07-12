"""
Diagonalization as Topological Genericity: numerical demonstrations
===================================================================

This self-contained script illustrates the main results of the paper
"Diagonalization as Topological Genericity: A Baire-Category Bridge for
Ramanujan Oracles".

We model:

* a *ground truth* as a function  T : N -> {False, True}   (a point of Cantor
  space); in code, a callable ``Callable[[int], bool]``.
* an *oracle* as a function  O : N -> {False, True, None}   where ``None`` means
  "unknown"; in code, a callable ``Callable[[int], Optional[bool]]``.
* ``perfect(O, T, upto)`` checks O(n) == T(n) for all statements n < upto.

The demonstrations, in order:

  1. Uniqueness lemma: a perfect oracle pins down a single world.
  2. No isolated points: any finite cylinder around a world contains another world.
  3. The connector (diagonalization = genericity): given ANY finite prefix and a
     countable family of oracles, we build a defeating ground truth extending that
     prefix -- witnessing that the defeating set is DENSE.
  4. Covered set is "thin": among many random worlds, essentially none is decided
     perfectly by a fixed finite family -- an empirical shadow of meagreness.
  5. Countability of computable oracles: enumerate simple "programs" and confirm
     distinct oracles need distinct codes (injectivity of code assignment).

Everything is elementary and runs in a fraction of a second.
"""

from __future__ import annotations

from typing import Callable, Optional, List, Dict

# Type aliases mirroring the paper's model.
Truth = Callable[[int], bool]
Oracle = Callable[[int], Optional[bool]]


# ---------------------------------------------------------------------------
# Core predicates
# ---------------------------------------------------------------------------
def perfect(oracle: Oracle, truth: Truth, upto: int) -> bool:
    """Return True iff `oracle` gives the correct definite verdict on every
    statement 0 <= n < upto (a finite witness of the infinite `PerfectOn`)."""
    for n in range(upto):
        if oracle(n) != truth(n):
            return False
    return True


# ---------------------------------------------------------------------------
# Demo 1 -- Uniqueness lemma (perfect_unique)
# ---------------------------------------------------------------------------
def demo_uniqueness(upto: int = 64) -> None:
    """If an oracle is perfect for T and for T', then T and T' agree everywhere
    (up to our finite horizon).  We take a random world, build the oracle that
    memorizes it, then show every *other* world fails perfection."""
    import random

    rng = random.Random(0)
    world: Dict[int, bool] = {n: bool(rng.getrandbits(1)) for n in range(upto)}
    T: Truth = lambda n: world[n]

    # The oracle that has memorized `world` is perfect for it and only it.
    O: Oracle = lambda n: world[n]

    assert perfect(O, T, upto)

    # Any world differing at even one coordinate is no longer decided perfectly.
    disagreements_found = 0
    for flip in range(upto):
        world2 = dict(world)
        world2[flip] = not world2[flip]
        T2: Truth = lambda n, w=world2: w[n]
        if not perfect(O, T2, upto):
            disagreements_found += 1

    print("Demo 1 -- Uniqueness lemma")
    print(f"  oracle perfect for the original world : {perfect(O, T, upto)}")
    print(f"  worlds (one bit flipped) it now fails : {disagreements_found}/{upto}")
    print("  => a perfect oracle fingerprints exactly one world.\n")


# ---------------------------------------------------------------------------
# Demo 2 -- No isolated points
# ---------------------------------------------------------------------------
def demo_no_isolated_points(prefix_len: int = 10) -> None:
    """Every basic neighbourhood (cylinder) fixing finitely many coordinates
    contains a point other than its centre: flip a coordinate OUTSIDE the fixed
    prefix."""
    x: Truth = lambda n: (n % 3 == 0)  # some fixed centre world

    # Cylinder: all worlds agreeing with x on coordinates 0..prefix_len-1.
    j = prefix_len  # a coordinate outside the fixed prefix
    y: Truth = lambda n: (not x(n)) if n == j else x(n)

    agree_on_prefix = all(x(n) == y(n) for n in range(prefix_len))
    differ_somewhere = any(x(n) != y(n) for n in range(prefix_len + 5))

    print("Demo 2 -- No isolated points")
    print(f"  fixed prefix length                   : {prefix_len}")
    print(f"  y agrees with x on the whole prefix   : {agree_on_prefix}")
    print(f"  y differs from x (at coordinate {j})   : {differ_somewhere}")
    print("  => no cylinder shrinks to a single point; singletons are nowhere dense.\n")


# ---------------------------------------------------------------------------
# Demo 3 -- The connector: diagonalization = genericity (density)
# ---------------------------------------------------------------------------
def build_defeating_truth(
    prefix: List[bool], family: List[Oracle]
) -> Truth:
    """Given an arbitrary finite prefix and a finite/countable family of oracles,
    construct a ground truth EXTENDING the prefix that no oracle in the family
    decides perfectly.  This witnesses density of the defeating set: it meets
    every cylinder [prefix].

    Strategy (block diagonalization): keep the prefix fixed, then for the i-th
    oracle reserve a fresh statement index and set the truth value to disagree
    with that oracle's verdict there (defaulting when the oracle says 'unknown').
    """
    plan: Dict[int, bool] = {n: prefix[n] for n in range(len(prefix))}
    slot = len(prefix)
    for O in family:
        verdict = O(slot)
        # disagree with a definite verdict; if 'unknown', any value already beats it.
        plan[slot] = (not verdict) if verdict is not None else True
        slot += 1

    def T(n: int) -> bool:
        return plan.get(n, False)

    return T


def demo_connector() -> None:
    """Show that for a sample family, the constructed truth extends the requested
    prefix AND defeats every oracle in the family."""
    prefix = [True, False, True, True, False]

    # A small illustrative family of oracles.
    family: List[Oracle] = [
        lambda n: True,                       # always 'true'
        lambda n: False,                      # always 'false'
        lambda n: (n % 2 == 0),               # parity oracle
        lambda n: None if n > 7 else True,    # gives up on large statements
        lambda n: (n * n % 5 == 1),           # a quadratic-residue-ish oracle
    ]

    T = build_defeating_truth(prefix, family)

    horizon = len(prefix) + len(family) + 3
    extends_prefix = all(T(n) == prefix[n] for n in range(len(prefix)))
    defeated = [not perfect(O, T, horizon) for O in family]

    print("Demo 3 -- The connector: diagonalization = genericity")
    print(f"  requested prefix                      : {prefix}")
    print(f"  constructed truth extends the prefix  : {extends_prefix}")
    print(f"  each oracle defeated by this truth    : {defeated}")
    print(f"  ALL oracles defeated                  : {all(defeated)}")
    print("  => every cylinder contains a defeating world: the defeating set is DENSE.\n")


# ---------------------------------------------------------------------------
# Demo 4 -- Empirical shadow of meagreness (covered set is thin)
# ---------------------------------------------------------------------------
def demo_meagre_shadow(num_worlds: int = 100_000, upto: int = 40) -> None:
    """Sample many random worlds and count how many a fixed finite family decides
    perfectly.  Because each oracle is perfect on at most one world, the covered
    fraction is essentially zero -- an empirical shadow of the covered set being
    meagre (measure zero, in the probabilistic twin)."""
    import random

    rng = random.Random(12345)

    family: List[Oracle] = [
        lambda n: True,
        lambda n: False,
        lambda n: (n % 2 == 0),
        lambda n: (n % 3 == 0),
    ]

    covered = 0
    for _ in range(num_worlds):
        bits = [bool(rng.getrandbits(1)) for _ in range(upto)]
        T: Truth = lambda n, b=bits: b[n]
        if any(perfect(O, T, upto) for O in family):
            covered += 1

    print("Demo 4 -- Empirical shadow of meagreness")
    print(f"  random worlds sampled                 : {num_worlds}")
    print(f"  worlds decided perfectly by the family: {covered}")
    print(f"  covered fraction                      : {covered / num_worlds:.6f}")
    print("  => the covered set is vanishingly thin (meagre / measure zero).\n")


# ---------------------------------------------------------------------------
# Demo 5 -- Countability of computable oracles (injective code assignment)
# ---------------------------------------------------------------------------
def demo_countable_computable(num_codes: int = 6, upto: int = 12) -> None:
    """Enumerate a handful of tiny 'programs' (codes) that each define a total
    oracle, then confirm that distinct oracles arise from distinct codes -- the
    code assignment is injective, so computable oracles inject into the countable
    set of codes."""

    def program(code: int) -> Oracle:
        """A toy family of computable oracles indexed by a natural number `code`.
        (Any effective enumeration of programs would serve; this is illustrative.)"""
        return lambda n: bool((code >> (n % 6)) & 1)

    # Materialize the truth tables of the first `num_codes` programs.
    tables: Dict[int, tuple] = {}
    for code in range(num_codes):
        O = program(code)
        tables[code] = tuple(O(n) for n in range(upto))

    distinct = len(set(tables.values()))

    print("Demo 5 -- Countability of computable oracles")
    print(f"  codes enumerated                      : {num_codes}")
    print(f"  distinct oracle behaviours produced   : {distinct}")
    print("  each code -> one oracle; distinct oracles need distinct codes.")
    print("  => computable oracles inject into the countable set of codes.\n")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print(" Diagonalization as Topological Genericity -- numerical demos")
    print("=" * 70 + "\n")
    demo_uniqueness()
    demo_no_isolated_points()
    demo_connector()
    demo_meagre_shadow()
    demo_countable_computable()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
