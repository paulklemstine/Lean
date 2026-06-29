"""Numerical demonstrations for:

    Bruhat Rank, Smooth Pattern Avoidance, and a Chain-Refined
    Regularity Bound for Schubert Varieties

Every function is self-contained and uses type hints. Permutations are
represented as tuples giving the one-line word, 0-indexed: the tuple
(2, 0, 1) is the permutation sending position 0 -> value 2, 1 -> 0,
2 -> 1.

The demonstrations mirror the formally verified results:
  * len_one              : the identity has inversion length 0
  * len_le_choose_two    : len(sigma) <= C(n, 2)
  * upperPairs_card      : there are exactly C(n, 2) position pairs i < j
  * chain_steps_le_len   : a strictly length-increasing chain to w has
                           at most len(w) steps
  * idPerm/revPerm avoid : identity and reversal are smooth
  * smooth_of_lt_four    : every permutation of rank < 4 is smooth
  * enumeration          : smooth-permutation counts = OEIS A005802
"""

from __future__ import annotations

from itertools import combinations, permutations
from math import comb
from typing import Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]

# The two Lakshmibai-Sandhya forbidden patterns, 0-indexed:
#   3412 -> (2, 3, 0, 1)      4231 -> (3, 1, 2, 0)
PATTERN_3412: Perm = (2, 3, 0, 1)
PATTERN_4231: Perm = (3, 1, 2, 0)


# --------------------------------------------------------------------------
# 1. Inversion length (Definitions 2.1-2.2; len_one, len_le_choose_two)
# --------------------------------------------------------------------------
def inversion_set(sigma: Perm) -> List[Tuple[int, int]]:
    """Return the inversions (i, j): pairs i < j with sigma[i] > sigma[j]."""
    n = len(sigma)
    return [(i, j) for i in range(n) for j in range(i + 1, n)
            if sigma[i] > sigma[j]]


def length(sigma: Perm) -> int:
    """Coxeter/Bruhat length: number of inversions of sigma."""
    return len(inversion_set(sigma))


def upper_pairs_count(n: int) -> int:
    """Number of position pairs i < j; equals C(n, 2) (upperPairs_card)."""
    return sum(1 for _ in combinations(range(n), 2))


def identity_perm(n: int) -> Perm:
    """The identity permutation of Fin n."""
    return tuple(range(n))


def reverse_perm(n: int) -> Perm:
    """The longest element w_0 (reversal): i -> n - 1 - i."""
    return tuple(n - 1 - i for i in range(n))


# --------------------------------------------------------------------------
# 2. Pattern containment and smoothness (Definitions 3.1-3.3)
# --------------------------------------------------------------------------
def _relative_order(values: Sequence[int]) -> Perm:
    """Standardize a sequence of distinct numbers to its relative-order word."""
    ranks = {v: r for r, v in enumerate(sorted(values))}
    return tuple(ranks[v] for v in values)


def contains_pattern(sigma: Perm, pattern: Perm) -> bool:
    """True iff sigma contains the length-4 `pattern` (Definition 3.1)."""
    k = len(pattern)
    for positions in combinations(range(len(sigma)), k):
        vals = [sigma[p] for p in positions]
        if _relative_order(vals) == pattern:
            return True
    return False


def is_smooth(sigma: Perm) -> bool:
    """Lakshmibai-Sandhya smoothness: avoid both 3412 and 4231."""
    return (not contains_pattern(sigma, PATTERN_3412)
            and not contains_pattern(sigma, PATTERN_4231))


def count_smooth(n: int) -> int:
    """Number of smooth permutations of Fin n (OEIS A005802)."""
    return sum(1 for p in permutations(range(n)) if is_smooth(p))


# --------------------------------------------------------------------------
# 3. Length chains and the chain-rank bound (Section 2.3)
# --------------------------------------------------------------------------
def is_length_chain(chain: Sequence[Perm]) -> bool:
    """True iff chain starts at the identity and strictly increases in length."""
    if not chain:
        return False
    n = len(chain[0])
    if chain[0] != identity_perm(n):
        return False
    return all(length(chain[i]) < length(chain[i + 1])
               for i in range(len(chain) - 1))


def chain_steps(chain: Sequence[Perm]) -> int:
    """Number of steps k in a chain of k+1 permutations."""
    return len(chain) - 1


def adjacent_transposition(sigma: Perm, i: int) -> Perm:
    """Swap values at adjacent positions i and i+1 (a simple reflection)."""
    s = list(sigma)
    s[i], s[i + 1] = s[i + 1], s[i]
    return tuple(s)


def saturated_chain_to_reverse(n: int) -> List[Perm]:
    """A saturated length chain id -> ... -> w_0 via adjacent transpositions.

    At each step we swap the first adjacent ascent (cur[i] < cur[i+1]); this
    creates one new inversion, raising length by exactly 1. The process stops
    only at the reversal (the unique permutation with no ascent), yielding a
    chain of exactly C(n, 2) steps.
    """
    chain: List[Perm] = [identity_perm(n)]
    cur = identity_perm(n)
    while True:
        ascent = next((i for i in range(n - 1) if cur[i] < cur[i + 1]), None)
        if ascent is None:        # no ascent left: cur is the reversal
            break
        cur = adjacent_transposition(cur, ascent)
        chain.append(cur)
    return chain


# --------------------------------------------------------------------------
# Demonstration driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("Schubert rank & smoothness: numerical demonstrations")
    print("=" * 70)

    # 1. Inversion length basics ------------------------------------------
    print("\n[1] Inversion length  (len_one, len_le_choose_two)")
    for n in range(1, 7):
        idp = identity_perm(n)
        rev = reverse_perm(n)
        print(f"  n={n}:  len(id)={length(idp):2d}   len(w0)={length(rev):2d}"
              f"   C(n,2)={comb(n, 2):2d}   #upperPairs={upper_pairs_count(n):2d}")
        assert length(idp) == 0                      # len_one
        assert length(rev) == comb(n, 2)             # diameter attained
        assert upper_pairs_count(n) == comb(n, 2)    # upperPairs_card
        for p in permutations(range(n)):
            assert length(p) <= comb(n, 2)           # len_le_choose_two

    # 2. Smoothness structural facts -------------------------------------
    print("\n[2] Smoothness  (idPerm/revPerm avoid, smooth_of_lt_four)")
    for n in range(1, 7):
        assert is_smooth(identity_perm(n))           # identity is smooth
        assert is_smooth(reverse_perm(n))            # reversal is smooth
        if n < 4:
            assert all(is_smooth(p) for p in permutations(range(n)))
    print("  identity & reversal smooth for all tested n: OK")
    print("  all permutations of rank < 4 are smooth:     OK")

    # The forbidden patterns are themselves singular, non-trivial perms.
    print(f"  3412 contains itself: {contains_pattern(PATTERN_3412, PATTERN_3412)}"
          f"   is_smooth(3412)={is_smooth(PATTERN_3412)}")
    print(f"  4231 contains itself: {contains_pattern(PATTERN_4231, PATTERN_4231)}"
          f"   is_smooth(4231)={is_smooth(PATTERN_4231)}")

    # 3. Enumeration vs OEIS A005802 -------------------------------------
    print("\n[3] Smooth-permutation census  (OEIS A005802)")
    a005802 = [1, 2, 6, 22, 88, 366, 1552]
    counts = [count_smooth(n) for n in range(1, 8)]
    print(f"  computed: {counts}")
    print(f"  A005802 : {a005802}")
    assert counts == a005802
    print("  match: OK")

    # 4. Chain-rank bound -------------------------------------------------
    print("\n[4] Chain-rank bound  (chain_steps_le_len, chain_steps_le_choose)")
    for n in range(2, 6):
        chain = saturated_chain_to_reverse(n)
        assert is_length_chain(chain)
        k = chain_steps(chain)
        w = chain[-1]
        print(f"  n={n}:  steps k={k:2d}  <=  len(w)={length(w):2d}  "
              f"<=  C(n,2)={comb(n, 2):2d}   (top is reversal: {w == reverse_perm(n)})")
        assert k <= length(w)                        # chain_steps_le_len
        assert k <= comb(n, 2)                       # chain_steps_le_choose

    print("\nAll assertions passed. The formal results are demonstrated"
          " numerically.")


if __name__ == "__main__":
    main()
