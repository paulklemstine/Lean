"""Numerical demonstrations for the orbit-stabilizer analysis of Boolean cubic
forms in ten variables under the action of the general linear group GL(10, 2).

All computations are exact integer arithmetic (Python's built-in big integers).
The demonstrations reproduce, from first principles, every numerical claim in the
accompanying article and paper:

    * the dimension 120 of the cubic layer and the space size 2^120 - 1;
    * the exact order of GL(10, 2);
    * the forced orbit lower bound 3,627,409;
    * the consistency of the classification value 3,691,560;
    * the parity disproof that the action is free (so the naive quotient
      3,627,408 is impossible);
    * the surplus 64,151 interpreted as a stabilizer census.

Run directly:  python3 demo.py
"""

from __future__ import annotations

from math import comb, prod


# --------------------------------------------------------------------------- #
# Core exact-arithmetic helpers
# --------------------------------------------------------------------------- #
def gl_order(n: int, q: int = 2) -> int:
    """Exact order of GL(n, q) via the ordered-basis product.

    |GL(n, q)| = prod_{i=0}^{n-1} (q^n - q^i).
    """
    return prod(q**n - q**i for i in range(n))


def cubic_layer_dimension(n: int) -> int:
    """Dimension of the homogeneous degree-3 (cubic) layer in n Boolean variables."""
    return comb(n, 3)


def num_nonzero_cubic_forms(n: int) -> int:
    """Number of nonzero Boolean cubic forms in n variables: 2^C(n,3) - 1."""
    return 2 ** cubic_layer_dimension(n) - 1


def forced_orbit_lower_bound(space_size: int, group_order: int) -> int:
    """Orbit lower bound: ceil(|X| / |G|).

    By the orbit-stabilizer theorem every orbit has size at most |G|, so the
    number of orbits r satisfies r >= |X| / |G|, hence r >= ceil(|X| / |G|).
    """
    return -(-space_size // group_order)  # integer ceiling division


def naive_quotient_floor(space_size: int, group_order: int) -> int:
    """The naive 'all orbits regular' guess: floor(|X| / |G|)."""
    return space_size // group_order


def action_can_be_free(space_size: int, group_order: int) -> bool:
    """A free action requires |G| | |X|.  Returns True iff divisibility holds."""
    return space_size % group_order == 0


# --------------------------------------------------------------------------- #
# Demonstration routines
# --------------------------------------------------------------------------- #
def demo_group_order() -> None:
    print("=" * 72)
    print("1. The exact order of GL(10, 2)")
    print("=" * 72)
    g = gl_order(10)
    print(f"|GL(10,2)| = prod_(i=0..9) (2^10 - 2^i)")
    print(f"           = {g}")
    print(f"digits      : {len(str(g))}")
    print(f"even?       : {g % 2 == 0}   (factor 2^10 - 2 = {2**10 - 2})")
    print()


def demo_space_size() -> None:
    print("=" * 72)
    print("2. The space of nonzero Boolean cubic forms in 10 variables")
    print("=" * 72)
    dim = cubic_layer_dimension(10)
    x = num_nonzero_cubic_forms(10)
    print(f"cubic layer dimension  C(10,3) = {dim}")
    print(f"number of cubic forms  2^{dim}   = {2**dim}")
    print(f"nonzero forms  |X| = 2^{dim} - 1 = {x}")
    print(f"odd?                            : {x % 2 == 1}")
    print()


def demo_bounds_and_consistency() -> None:
    print("=" * 72)
    print("3. Orbit lower bound, consistency, and the surplus")
    print("=" * 72)
    g = gl_order(10)
    x = num_nonzero_cubic_forms(10)
    classification = 3_691_560

    lower = forced_orbit_lower_bound(x, g)
    floor = naive_quotient_floor(x, g)
    ratio = x / g

    print(f"|X| / |G|                = {ratio:.6f}")
    print(f"forced lower bound  ceil = {lower:,}")
    print(f"naive floor         floor= {floor:,}")
    print(f"classification value r   = {classification:,}")
    print()
    print(f"consistency  r >= ceil(|X|/|G|)   : "
          f"{classification} >= {lower}  -> {classification >= lower}")
    print(f"equivalently r*|G| >= |X|         : "
          f"{classification * g >= x}")
    surplus = classification - lower
    print(f"surplus  r - forced_lower_bound   : "
          f"{classification:,} - {lower:,} = {surplus:,}")
    print()


def demo_freeness_obstruction() -> None:
    print("=" * 72)
    print("4. Parity disproof: the action is NOT free")
    print("=" * 72)
    g = gl_order(10)
    x = num_nonzero_cubic_forms(10)
    print(f"|G| even  : {g % 2 == 0}")
    print(f"|X| odd   : {x % 2 == 1}")
    print(f"|G| divides |X|? : {action_can_be_free(x, g)}")
    print("An even number cannot divide an odd number, so |G| does not divide")
    print("|X|.  By the freeness obstruction, some nonzero cubic form has a")
    print("nontrivial stabilizer: the action is not free, and the naive")
    print(f"quotient floor(|X|/|G|) = {naive_quotient_floor(x, g):,} is impossible.")
    print()


def demo_small_n_group_orders() -> None:
    print("=" * 72)
    print("5. Companion data: layer dimensions and group orders for small n")
    print("=" * 72)
    print(f"{'n':>3} | {'C(n,3)':>7} | {'|GL(n,2)|':>28}")
    print("-" * 46)
    for n in range(4, 11):
        print(f"{n:>3} | {cubic_layer_dimension(n):>7} | {gl_order(n):>28}")
    print()


def main() -> None:
    demo_group_order()
    demo_space_size()
    demo_bounds_and_consistency()
    demo_freeness_obstruction()
    demo_small_n_group_orders()

    # Final self-check of every certified numerical claim.
    g = gl_order(10)
    x = num_nonzero_cubic_forms(10)
    assert cubic_layer_dimension(10) == 120
    assert g == 366_440_137_299_948_128_422_802_227_200
    assert forced_orbit_lower_bound(x, g) == 3_627_409
    assert naive_quotient_floor(x, g) == 3_627_408
    assert 3_691_560 >= forced_orbit_lower_bound(x, g)
    assert 3_691_560 * g >= x
    assert not action_can_be_free(x, g)
    assert 3_691_560 - forced_orbit_lower_bound(x, g) == 64_151
    print("All certified numerical claims verified.")


if __name__ == "__main__":
    main()
