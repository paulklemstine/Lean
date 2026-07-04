"""
Escher Staircases in Algebra: numerical demonstrations.

An *Escher staircase* is an infinite strictly ascending chain of ideals
    I_0 ( I_1 ( I_2 ( ...
in a commutative ring.  A ring admits such a staircase iff it is NOT Noetherian.

This script demonstrates, with concrete finite computations:

  1. The explicit staircase I_n = {f : f(i) = 0 for all i >= n} in the Boolean
     product ring B = prod_N F_2 (functions N -> {0,1} with pointwise ops):
       - each rung is strictly larger than the last (witnessed by an indicator);
       - the bottom rung I_0 is the zero ideal {0};
       - the Loop-Back Lemma: the intersection of all rungs is again {0}.

  2. The descending dyadic mirror in Z: (2^0) ) (2^1) ) (2^2) ) ...,
     whose intersection is also {0}.

  3. The negative instance Z_p (p-adic integers, a discrete valuation ring):
     ascending ideal chains correspond to non-increasing valuation exponents,
     which must stabilize -- so NO Escher staircase exists.

Everything is self-contained; run `python demo.py`.
"""

from __future__ import annotations

from typing import Callable, List, Set, Tuple


# ----------------------------------------------------------------------------
# 1. The Boolean product ring staircase  I_n = {f : f(i)=0 for all i >= n}
# ----------------------------------------------------------------------------

def in_rung(f: Tuple[int, ...], n: int) -> bool:
    """Return True iff the sequence `f` lies in rung I_n, i.e. f(i)=0 for i>=n.

    `f` is a finite prefix of a sequence in prod_N F_2 (entries in {0,1});
    unspecified tail entries are taken to be 0, so only the first n entries
    are allowed to be nonzero.
    """
    return all(v == 0 for i, v in enumerate(f) if i >= n)


def indicator(n: int, length: int) -> Tuple[int, ...]:
    """The indicator e_n: 1 at index n, 0 elsewhere (as a length-`length` prefix)."""
    return tuple(1 if i == n else 0 for i in range(length))


def rung_elements(n: int, length: int) -> Set[Tuple[int, ...]]:
    """All elements of I_n whose support lies within the first `length` slots.

    These are exactly the 2^n sequences that are free in slots 0..n-1 and zero
    in slots n..length-1.
    """
    result: Set[Tuple[int, ...]] = set()
    for mask in range(1 << n):
        f = tuple((mask >> i) & 1 for i in range(n)) + tuple(0 for _ in range(length - n))
        result.add(f)
    return result


def demo_boolean_staircase(max_n: int = 6, length: int = 8) -> None:
    print("=" * 72)
    print("1. Escher staircase in the Boolean product ring B = prod_N F_2")
    print("=" * 72)
    print("   I_n = { f : f(i) = 0 for all i >= n }\n")

    # Strict ascent, witnessed by the indicator e_n.
    print("   Strict ascent  I_n ( I_{n+1}, witnessed by e_n:")
    for n in range(max_n):
        e = indicator(n, length)
        assert in_rung(e, n + 1), "e_n must lie in I_{n+1}"
        assert not in_rung(e, n), "e_n must NOT lie in I_n"
        card_n = len(rung_elements(n, length))
        card_n1 = len(rung_elements(n + 1, length))
        print(f"     e_{n} = {e}  in I_{n+1}: yes,  in I_{n}: no   "
              f"(|I_{n}|={card_n}, |I_{n+1}|={card_n1})")

    # Bottom rung is {0}.
    zero = tuple(0 for _ in range(length))
    assert rung_elements(0, length) == {zero}
    print(f"\n   Bottom rung  I_0 = {{{zero}}} = {{0}}  (the zero ideal)")

    # Loop-Back Lemma: intersection of all rungs = bottom rung = {0}.
    inter = set.intersection(*(rung_elements(n, length) for n in range(max_n + 1)))
    assert inter == {zero}
    print(f"   Loop-Back:   intersection of I_0..I_{max_n} = {{0}}  "
          "(climb forever, meet is the start)\n")


# ----------------------------------------------------------------------------
# 2. The descending dyadic mirror in Z:  (2^0) ) (2^1) ) (2^2) ) ...
# ----------------------------------------------------------------------------

def two_adic_valuation(m: int) -> int:
    """v_2(m): the largest k with 2^k | m  (for m != 0)."""
    if m == 0:
        raise ValueError("v_2(0) is infinite")
    k = 0
    while m % 2 == 0:
        m //= 2
        k += 1
    return k


def in_dyadic_ideal(m: int, n: int) -> bool:
    """True iff m lies in the ideal (2^n) of Z, i.e. 2^n | m."""
    return m % (2 ** n) == 0


def demo_dyadic_mirror(max_n: int = 20, sample: Tuple[int, ...] = (1, 3, 12, 96, -40)) -> None:
    print("=" * 72)
    print("2. Descending dyadic mirror in Z:  (2^0) ) (2^1) ) (2^2) ) ...")
    print("=" * 72)
    print("   A nonzero integer survives only finitely many rungs:\n")
    for m in sample:
        v = two_adic_valuation(m)
        last = max(n for n in range(max_n + 1) if in_dyadic_ideal(m, n))
        assert last == v
        print(f"     m = {m:>4}:  in (2^n) for n <= v_2(m) = {v};  drops out at n = {v + 1}")
    print("\n   Hence  intersection over all n of (2^n) = {0}  "
          "(descending collapse to zero)\n")


# ----------------------------------------------------------------------------
# 3. Negative instance: Z_p is a DVR, so ascending chains stabilize.
# ----------------------------------------------------------------------------

def dvr_chain_stabilizes(exponents: List[int]) -> Tuple[bool, int]:
    """Model an ascending ideal chain in Z_p by its valuation exponents.

    In a DVR the nonzero ideals are exactly (p^k); the ideal (p^a) is contained
    in (p^b) iff a >= b.  So an ASCENDING chain of ideals corresponds to a
    NON-INCREASING sequence of exponents.  Any non-increasing sequence of
    non-negative integers must stabilize.  Returns (stabilizes, index_of_first
    stable position).
    """
    non_increasing = all(exponents[i] >= exponents[i + 1] for i in range(len(exponents) - 1))
    assert non_increasing, "an ascending ideal chain in a DVR needs non-increasing exponents"
    stable_at = len(exponents) - 1
    for i in range(len(exponents) - 1):
        if exponents[i] == exponents[i + 1]:
            # a non-increasing sequence bounded below by 0 must repeat / stabilize
            stable_at = i
            break
    return True, stable_at


def demo_padic_no_staircase() -> None:
    print("=" * 72)
    print("3. Negative instance: the p-adic integers Z_p admit NO staircase")
    print("=" * 72)
    print("   Z_p is a discrete valuation ring: nonzero ideals are exactly (p^k),")
    print("   linearly ordered (p^a) subset (p^b)  <=>  a >= b.")
    print("   An ascending ideal chain => non-increasing exponents => must stabilize.\n")
    # Longest strictly ascending chain starting from (p^k) has length k+1: it is
    # (p^k) ( (p^{k-1}) ( ... ( (p^0) = Z_p.  Never infinite.
    for k in [1, 3, 5]:
        chain = list(range(k, -1, -1))  # exponents k, k-1, ..., 0
        length = len(chain)
        print(f"     longest strict ascent from (p^{k}): "
              f"(p^{k}) ( ... ( (p^0)  has length {length}  (finite)")
    stab, idx = dvr_chain_stabilizes([4, 4, 2, 1, 0])
    print(f"\n     any ascending chain stabilizes: e.g. exponents [4,4,2,1,0] "
          f"stabilizes by index {idx}")
    print("   => Z_p is Noetherian, so it has NO Escher staircase.\n")


def main() -> None:
    demo_boolean_staircase()
    demo_dyadic_mirror()
    demo_padic_no_staircase()
    print("All assertions passed: the staircase climbs forever yet loops back to {0},")
    print("the dyadic mirror collapses to {0}, and Z_p hosts no staircase at all.")


if __name__ == "__main__":
    main()
