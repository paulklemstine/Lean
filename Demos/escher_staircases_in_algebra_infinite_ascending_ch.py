"""
Escher Staircases in Algebra: numerical demonstrations.

An *Escher staircase* is an infinite, strictly ascending chain of ideals
    I_0 ⊊ I_1 ⊊ I_2 ⊊ ...
in a commutative ring. This script illustrates, with finite computable models:

  1. The explicit Boolean staircase in F_2^N given by the "support-below-n"
     ideals, and the fact that every inclusion is strict.
  2. The Loop-Back Lemma: the infinite intersection of an ascending chain
     equals its first term (here, the zero ideal).
  3. The Escher Characterization in action: exhibiting one staircase certifies
     non-Noetherianity.
  4. The Anti-Escher collapse: the dyadic descending chain (2^n) in Z has
     intersection {0}, located element-by-element via the 2-adic valuation.

Everything is self-contained standard-library Python with type hints.
"""

from __future__ import annotations

from typing import Callable, FrozenSet, List, Set


# ---------------------------------------------------------------------------
# 1. The Boolean product ring F_2^N, modelled on finitely supported sequences.
#    A sequence f : N -> F_2 with finite support is stored as the frozenset of
#    positions where it equals 1. Pointwise addition is symmetric difference;
#    pointwise multiplication is intersection.
# ---------------------------------------------------------------------------

def bool_add(f: FrozenSet[int], g: FrozenSet[int]) -> FrozenSet[int]:
    """Pointwise addition in F_2^N: (f+g)(i) = f(i) XOR g(i)."""
    return f ^ g


def bool_mul(f: FrozenSet[int], g: FrozenSet[int]) -> FrozenSet[int]:
    """Pointwise multiplication in F_2^N: (f*g)(i) = f(i) AND g(i)."""
    return f & g


def in_suppLt(f: FrozenSet[int], n: int) -> bool:
    """Membership in the support-below-n ideal I_n = {f : f(i)=0 for all i>=n}."""
    return all(i < n for i in f)


def indicator(n: int) -> FrozenSet[int]:
    """The indicator e_n which is 1 at position n and 0 elsewhere."""
    return frozenset({n})


def demo_boolean_staircase(max_n: int = 6) -> None:
    print("=" * 70)
    print("1. The Boolean staircase  I_0 ⊊ I_1 ⊊ ... in F_2^N")
    print("=" * 70)
    print("I_n = { f : f(i) = 0 for all i >= n } (functions supported below n)")
    print()
    for n in range(max_n):
        e_n = indicator(n)  # witness for strictness of I_n ⊊ I_{n+1}
        in_next = in_suppLt(e_n, n + 1)
        in_here = in_suppLt(e_n, n)
        print(f"  e_{n} = 1 at position {n}:  in I_{n+1}? {str(in_next):>5}"
              f"   in I_{n}? {str(in_here):>5}   =>  I_{n} ⊊ I_{n+1}: {in_next and not in_here}")
    print()
    # I_0 is the zero ideal: only the empty-support (zero) sequence qualifies.
    print(f"  I_0 contains only the zero sequence?  "
          f"{in_suppLt(frozenset(), 0) and not in_suppLt(indicator(0), 0)}")
    print()


# ---------------------------------------------------------------------------
# 2. The Loop-Back Lemma on finite truncations.
#    We verify that intersecting I_0..I_N always returns exactly I_0.
# ---------------------------------------------------------------------------

def demo_loop_back(universe_bound: int = 8, N: int = 6) -> None:
    print("=" * 70)
    print("2. Loop-Back Lemma:  intersection of I_0..I_N equals I_0 = {0}")
    print("=" * 70)
    # Enumerate all sequences supported inside {0,...,universe_bound-1}.
    all_seqs: List[FrozenSet[int]] = []
    for mask in range(1 << universe_bound):
        supp = frozenset(i for i in range(universe_bound) if (mask >> i) & 1)
        all_seqs.append(supp)

    def ideal(n: int) -> Set[FrozenSet[int]]:
        return {f for f in all_seqs if in_suppLt(f, n)}

    intersection: Set[FrozenSet[int]] = set(all_seqs)
    for n in range(N + 1):
        intersection &= ideal(n)
        size = len(intersection)
        print(f"  after intersecting through I_{n}:  |intersection| = {size}")
    is_zero_only = intersection == {frozenset()}
    print(f"\n  Intersection equals the zero ideal {{0}}?  {is_zero_only}")
    print("  (matches I_0, confirming the Loop-Back Lemma)")
    print()


# ---------------------------------------------------------------------------
# 3. Escher Characterization: one strictly ascending chain => non-Noetherian.
# ---------------------------------------------------------------------------

def is_strictly_ascending(chain_membership: Callable[[FrozenSet[int], int], bool],
                          witnesses: List[FrozenSet[int]]) -> bool:
    """
    Given witnesses w_n with w_n in I_{n+1} \\ I_n, certify strict ascent of the
    chain (I_n). Returns True iff each witness certifies a proper inclusion.
    """
    for n, w in enumerate(witnesses):
        if not (chain_membership(w, n + 1) and not chain_membership(w, n)):
            return False
    return True


def demo_characterization(max_n: int = 10) -> None:
    print("=" * 70)
    print("3. Escher Characterization: a staircase certifies non-Noetherian")
    print("=" * 70)
    witnesses = [indicator(n) for n in range(max_n)]
    certified = is_strictly_ascending(in_suppLt, witnesses)
    print(f"  Strict ascent certified for {max_n} steps?  {certified}")
    print("  By the Escher Characterization, F_2^N is therefore NOT Noetherian.")
    print()


# ---------------------------------------------------------------------------
# 4. Anti-Escher collapse: dyadic descending chain (2^n) in Z.
#    Each nonzero x drops out of (2^n) exactly at n = v_2(x) + 1.
# ---------------------------------------------------------------------------

def two_adic_valuation(x: int) -> int:
    """Largest n with 2^n | x, for x != 0."""
    if x == 0:
        raise ValueError("2-adic valuation of 0 is +infinity")
    n = 0
    while x % 2 == 0:
        x //= 2
        n += 1
    return n


def in_dyadic(x: int, n: int) -> bool:
    """Membership x in (2^n) = {multiples of 2^n}."""
    return x % (2 ** n) == 0


def demo_anti_escher(samples: List[int] | None = None) -> None:
    print("=" * 70)
    print("4. Anti-Escher collapse:  ∩_n (2^n) = {0} in Z")
    print("=" * 70)
    if samples is None:
        samples = [6, 24, 40, 1024, 7, -96]
    for x in samples:
        v = two_adic_valuation(x)
        drop = v + 1
        print(f"  x = {x:>6}:  v_2(x) = {v}  =>  x ∈ (2^{v}) but x ∉ (2^{drop}); "
              f"drops out of the chain at stage {drop}")
    print()
    print("  Every nonzero integer exits the chain at a finite stage, so no")
    print("  nonzero element lies in all (2^n): the intersection is exactly {0}.")
    print()


def main() -> None:
    demo_boolean_staircase()
    demo_loop_back()
    demo_characterization()
    demo_anti_escher()
    print("Done. Ascending loop-back and descending collapse are two faces")
    print("of the same vanishing intersection.")


if __name__ == "__main__":
    main()
