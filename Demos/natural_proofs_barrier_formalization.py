"""
Numerical demonstration of the Razborov--Rudich natural proofs barrier,
modeled as a self-dual counting law on acceptance probabilities.

This is a faithful, self-contained Python rendering of the formalized model:

  * A truth table on m rows is a tuple of m booleans  (think m = 2**n).
  * A property P is a predicate on truth tables.
  * accRandom(P) = (# truth tables satisfying P) / 2**m              [density]
  * accGen(G, P) = (# seeds s with P(G(s))) / |S|                    [gen. acc.]
  * P is "useful" against G iff P(G(s)) is false for every seed s.
  * advantage = accRandom(P) - accGen(G, P).

All probabilities are computed exactly with fractions.Fraction, mirroring the
exact-rational (Q) treatment in the formal development.

The script demonstrates:
  1. accGen_eq_zero_of_useful   - usefulness pins generator acceptance to 0.
  2. natural_property_distinguishes - large + useful => advantage >= delta.
  3. barrier - delta-pseudorandom + delta-large => P accepts some easy G(s).
  4. image_test_distinguishes / exists_large_useful - the membership test is
     large+useful unconditionally with maximal advantage 1 - |image G|/2**m.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, List, Sequence, Tuple

# A truth table on m rows: a tuple of m booleans.
TruthTable = Tuple[bool, ...]
# A property: a predicate on truth tables.
Property = Callable[[TruthTable], bool]
# A generator: maps a seed (here an int index) to a truth table.
Generator = Callable[[int], TruthTable]


def all_truth_tables(m: int) -> List[TruthTable]:
    """Enumerate all 2**m truth tables on m rows."""
    return [tuple(bits) for bits in product([False, True], repeat=m)]


def acc_random(P: Property, m: int) -> Fraction:
    """Density of P: fraction of all 2**m truth tables that satisfy P."""
    tables = all_truth_tables(m)
    numerator = sum(1 for T in tables if P(T))
    return Fraction(numerator, len(tables))


def acc_gen(G: Generator, P: Property, seeds: Sequence[int]) -> Fraction:
    """Generator acceptance: fraction of seeds s with P(G(s))."""
    numerator = sum(1 for s in seeds if P(G(s)))
    return Fraction(numerator, len(seeds))


def is_useful(G: Generator, P: Property, seeds: Sequence[int]) -> bool:
    """P is useful against G iff it rejects every generator output."""
    return all(not P(G(s)) for s in seeds)


def advantage(G: Generator, P: Property, seeds: Sequence[int], m: int) -> Fraction:
    """Distinguishing advantage accRandom(P) - accGen(G, P)."""
    return acc_random(P, m) - acc_gen(G, P, seeds)


def image_of(G: Generator, seeds: Sequence[int]) -> List[TruthTable]:
    """The small-circuit class: the (deduplicated) image of G over the seeds."""
    seen: List[TruthTable] = []
    for s in seeds:
        t = G(s)
        if t not in seen:
            seen.append(t)
    return seen


def not_in_image_property(G: Generator, seeds: Sequence[int]) -> Property:
    """The membership test notInImage_G(T) := T not in image(G)."""
    image = set(image_of(G, seeds))
    return lambda T: T not in image


def demo_keystone() -> None:
    print("=" * 70)
    print("1. accGen_eq_zero_of_useful : usefulness => accGen = 0")
    print("=" * 70)
    m = 3  # truth tables on 3 rows; 2**3 = 8 tables in total
    seeds = list(range(4))

    # A generator producing 4 (not necessarily distinct) easy truth tables.
    def G(s: int) -> TruthTable:
        table = [
            (False, False, False),
            (True, False, False),
            (False, True, False),
            (True, True, False),
        ]
        return table[s]

    # A property that rejects every output: "the last row is True".
    P: Property = lambda T: T[2] is True
    print(f"   image(G)            = {image_of(G, seeds)}")
    print(f"   useful against G    = {is_useful(G, P, seeds)}")
    print(f"   accGen(G, P)        = {acc_gen(G, P, seeds)}   (expected 0)")
    assert acc_gen(G, P, seeds) == Fraction(0)
    print("   OK: a useful property accepts none of the generator's outputs.\n")


def demo_forward() -> None:
    print("=" * 70)
    print("2. natural_property_distinguishes : large + useful => adv >= delta")
    print("=" * 70)
    m = 4  # 2**4 = 16 truth tables
    seeds = list(range(3))

    # Generator outputs three tables whose last row is False (so "easy").
    def G(s: int) -> TruthTable:
        return (bool(s & 1), bool(s & 2), False, False)

    # Property: "last row is True". Rejects all outputs => useful.
    P: Property = lambda T: T[3] is True

    dens = acc_random(P, m)
    useful = is_useful(G, P, seeds)
    adv = advantage(G, P, seeds, m)
    delta = dens  # the guaranteed advantage equals the density
    print(f"   density accRandom(P) = {dens}")
    print(f"   useful against G     = {useful}")
    print(f"   advantage            = {adv}")
    print(f"   delta (= density)    = {delta}")
    assert useful and adv >= delta
    print("   OK: advantage >= delta exactly because accGen = 0.\n")


def demo_barrier() -> None:
    print("=" * 70)
    print("3. barrier : delta-pseudorandom + delta-large => P accepts some G(s)")
    print("=" * 70)
    m = 3
    seeds = list(range(8))  # seeds cover ALL 8 truth tables (a 'perfect' PRG)

    # A generator whose image is the entire space => no test can distinguish.
    tables = all_truth_tables(m)

    def G(s: int) -> TruthTable:
        return tables[s]

    # A large property: "not the all-false table" (7/8 density).
    P: Property = lambda T: any(T)
    dens = acc_random(P, m)
    adv = advantage(G, P, seeds, m)
    delta = Fraction(1, 2)  # P is delta-large since 7/8 >= 1/2

    # G is delta-pseudorandom: advantage < delta.
    print(f"   density accRandom(P) = {dens}  (delta-large for delta=1/2)")
    print(f"   advantage            = {adv}  (< delta = {delta}: pseudorandom)")
    assert dens >= delta and adv < delta
    # Conclusion of the barrier: some seed s has P(G(s)).
    witness = next(s for s in seeds if P(G(s)))
    print(f"   barrier conclusion: seed s = {witness} has P(G(s)) = "
          f"{P(G(witness))}")
    print(f"   witness output G(s)  = {G(witness)}")
    print("   OK: a large property a secure generator survives is NOT useful.\n")


def demo_membership_test() -> None:
    print("=" * 70)
    print("4. image_test_distinguishes / exists_large_useful")
    print("   The membership test is large+useful unconditionally;")
    print("   its advantage = 1 - |image G| / 2**m is maximal.")
    print("=" * 70)
    m = 4  # 16 truth tables
    seeds = list(range(5))  # a seed-bounded generator: only 5 outputs

    def G(s: int) -> TruthTable:
        # five distinct easy tables
        return (bool(s & 1), bool(s & 2), bool(s & 4), False)

    P = not_in_image_property(G, seeds)
    img = image_of(G, seeds)
    dens = acc_random(P, m)
    adv = advantage(G, P, seeds, m)
    expected = Fraction(1) - Fraction(len(img), 2 ** m)

    print(f"   |image G|            = {len(img)}")
    print(f"   useful against G     = {is_useful(G, P, seeds)}")
    print(f"   accGen(G, P)         = {acc_gen(G, P, seeds)}  (= 0)")
    print(f"   density accRandom(P) = {dens}")
    print(f"   advantage            = {adv}")
    print(f"   1 - |image G|/2**m   = {expected}")
    assert adv == expected == dens
    print("   OK: large + useful exists for free; only constructivity is scarce.\n")


def main() -> None:
    demo_keystone()
    demo_forward()
    demo_barrier()
    demo_membership_test()
    print("All natural-proofs-barrier demonstrations passed.")


if __name__ == "__main__":
    main()


"""
Visualization of the natural proofs barrier as a self-dual counting law.

Left panel:  the (accRandom, accGen) state plane. Useful properties live on the
             accGen = 0 axis; the advantage is the horizontal distance to the
             diagonal accRandom = accGen. The delta-largeness and
             delta-pseudorandomness regions are shaded, and their intersection
             on the useful axis is EMPTY -- this emptiness is the barrier.

Right panel: maximal distinguishing advantage 1 - |image G| / 2**m of the
             membership test, as a function of the number of seeds, showing how
             a seed-bounded generator is always distinguishable in principle.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def max_advantage(num_seeds: int, m: int) -> float:
    """Maximal advantage 1 - |image|/2**m, with |image| <= min(num_seeds, 2**m)."""
    image_size = min(num_seeds, 2 ** m)
    return 1.0 - image_size / (2 ** m)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    # ----- Left: the (accRandom, accGen) state plane -----
    ax1.plot([0, 1], [0, 1], "k--", lw=1, label="advantage = 0 (accR = accG)")
    # The useful axis: accGen = 0.
    ax1.plot([0, 1], [0, 0], color="tab:blue", lw=3, label="useful tests (accGen = 0)")

    delta = 0.5
    # delta-largeness region: accRandom >= delta.
    ax1.axvspan(delta, 1.0, color="tab:green", alpha=0.12,
                label=r"$\delta$-large ($accR \geq \delta$)")
    # delta-pseudorandom region: accRandom - accGen < delta.
    xs = np.linspace(0, 1, 200)
    ax1.fill_between(xs, np.maximum(xs - delta, 0.0), 1.0,
                     color="tab:orange", alpha=0.12,
                     label=r"$\delta$-pseudorandom ($accR-accG<\delta$)")

    # A natural property (large + useful) -> big advantage, breaks pseudorandomness.
    ax1.scatter([0.8], [0.0], color="tab:red", zorder=5, s=70)
    ax1.annotate("natural property\n(large + useful)\nadvantage = 0.8",
                 (0.8, 0.0), textcoords="offset points", xytext=(-30, 30),
                 fontsize=9, ha="center")
    ax1.axvline(delta, color="gray", lw=0.8)
    ax1.set_xlabel("accRandom (density)")
    ax1.set_ylabel("accGen (generator acceptance)")
    ax1.set_title("State plane: useful axis meets large region\noutside the pseudorandom zone")
    ax1.set_xlim(0, 1)
    ax1.set_ylim(-0.05, 1)
    ax1.legend(fontsize=7, loc="upper left")

    # ----- Right: maximal advantage vs. number of seeds -----
    m = 6  # 2**6 = 64 truth tables
    seed_counts: List[int] = list(range(1, 2 ** m + 1))
    advs = [max_advantage(k, m) for k in seed_counts]
    ax2.plot(seed_counts, advs, color="tab:purple", lw=2)
    ax2.fill_between(seed_counts, advs, color="tab:purple", alpha=0.15)
    ax2.set_xlabel(f"number of seeds |S|  (space size 2^{m} = {2**m})")
    ax2.set_ylabel("maximal advantage  1 - |image|/2^m")
    ax2.set_title("Seed-bounded generators are always\ndistinguishable (membership test)")
    ax2.grid(alpha=0.3)

    fig.suptitle("The Natural Proofs Barrier as a Self-Dual Counting Law",
                 fontsize=13, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("natural_proofs_barrier.png", dpi=150)
    print("Saved natural_proofs_barrier.png")


if __name__ == "__main__":
    main()
