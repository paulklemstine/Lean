"""
Strong completeness of sets of natural numbers: numerical demonstrations.
=========================================================================

A set A of natural numbers is COMPLETE if every sufficiently large integer is a
sum of DISTINCT elements of A, and STRONGLY COMPLETE if A \\ F is complete for
every finite set F.

This self-contained script illustrates, numerically:

  1. Subset-sum reachability and empirical completeness thresholds.
  2. The fragility of completeness: E_1 = evens + {1} shatters on one deletion.
  3. The ordered-block criterion (doubling + overlap) and its greedy
     representation algorithm.
  4. Dyadic blocks, and the sharp negative result: six (or any constant number
     of) elements per dyadic block does NOT imply completeness -- the multiples
     of 3 are a witness.
  5. Refutation of the parity conjecture: T = 3N u {1,2} is complete, has
     infinitely many odd elements, but is not strongly complete.
  6. The backbone-and-residues criterion in action.
  7. The rational divergence dictionary:
         sum over a in A of ||a/d||^2 diverges  <=>  infinitely many a with d not dividing a.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Iterable, List, Optional, Sequence, Set, Tuple


# ----------------------------------------------------------------------------
# 1. Subset-sum reachability
# ----------------------------------------------------------------------------

def reachable_mask(elements: Iterable[int], limit: int) -> int:
    """Bitmask of all subset sums <= `limit` of the given DISTINCT elements.

    Bit i of the returned integer is 1 iff i is a subset sum. Each element is
    used at most once (distinct-summand knapsack).
    """
    mask = 1  # only 0 is reachable initially
    full = (1 << (limit + 1)) - 1
    for a in elements:
        if a == 0 or a > limit:
            continue
        mask |= (mask << a) & full
    return mask


def reachable_set(elements: Iterable[int], limit: int) -> Set[int]:
    """Set of all subset sums <= limit."""
    mask = reachable_mask(elements, limit)
    return {i for i in range(limit + 1) if (mask >> i) & 1}


def empirical_threshold(elements: Sequence[int], limit: int) -> Optional[int]:
    """Largest n <= limit that is NOT a subset sum, plus one.

    Returns the empirical completeness threshold N (all n with N <= n <= limit
    are representable). Returns 0 if everything up to `limit` is representable.
    Returns None if the gap set is suspiciously large (a strong hint of
    non-completeness).
    """
    mask = reachable_mask(elements, limit)
    missing = [n for n in range(limit + 1) if not ((mask >> n) & 1)]
    if not missing:
        return 0
    top = max(missing)
    # heuristic: if more than a quarter of the top half is missing, declare failure
    upper_missing = sum(1 for n in missing if n > limit // 2)
    if upper_missing > limit // 8:
        return None
    return top + 1


def delete(elements: Iterable[int], deleted: Iterable[int]) -> List[int]:
    """A \\ F as a sorted list."""
    d = set(deleted)
    return sorted(x for x in elements if x not in d)


# ----------------------------------------------------------------------------
# 2. The example sets
# ----------------------------------------------------------------------------

def evens_with_one(limit: int) -> List[int]:
    """E_1 = all even numbers together with the single odd number 1."""
    return sorted({1} | {2 * m for m in range(1, limit // 2 + 1)})


def multiples_of(d: int, limit: int) -> List[int]:
    """d * N, restricted to (0, limit]."""
    return [d * m for m in range(1, limit // d + 1)]


def three_and_units(limit: int) -> List[int]:
    """T = 3N u {1,2}: the parity-conjecture counterexample."""
    return sorted({1, 2} | set(multiples_of(3, limit)))


def evens_and_infinite_odds(limit: int, odd_step: int = 101) -> List[int]:
    """All evens together with infinitely many odds (here: 1, 1+2*101, ...)."""
    evens = {2 * m for m in range(1, limit // 2 + 1)}
    odds = {1 + 2 * odd_step * k for k in range(limit // (2 * odd_step) + 1)}
    return sorted(evens | {o for o in odds if o <= limit})


# ----------------------------------------------------------------------------
# 3. Dyadic blocks
# ----------------------------------------------------------------------------

def dyadic_block(elements: Iterable[int], k: int) -> List[int]:
    """The k-th dyadic block: elements a with 2^k < a <= 2^(k+1)."""
    lo, hi = 2 ** k, 2 ** (k + 1)
    return sorted(a for a in elements if lo < a <= hi)


def dyadic_block_counts(elements: Sequence[int], kmax: int) -> List[Tuple[int, int]]:
    """Sizes of dyadic blocks 0..kmax."""
    return [(k, len(dyadic_block(elements, k))) for k in range(kmax + 1)]


# ----------------------------------------------------------------------------
# 4. Ordered-block criterion and greedy representation
# ----------------------------------------------------------------------------

def block_covers_interval(block: Sequence[int], lo: int, hi: int) -> bool:
    """Check that every integer in [lo, hi] is a subset sum of `block`."""
    mask = reachable_mask(block, hi)
    return all((mask >> n) & 1 for n in range(lo, hi + 1))


def check_block_hypotheses(
    blocks: Sequence[Sequence[int]], los: Sequence[int], his: Sequence[int]
) -> List[Tuple[str, bool]]:
    """Verify the five hypotheses of the ordered-block criterion on a finite prefix.

    1. coverage:      [lo_k, hi_k] subset of Sigma(B_k)
    2. positivity:    lo_k >= 1
    3. monotonicity:  lo_k nondecreasing
    4. doubling:      2 lo_k <= hi_k + 1
    5. overlap:       lo_{k+1} <= hi_k + 1
    plus orderedness of the blocks themselves.
    """
    n = len(blocks)
    ordered = all(max(blocks[k]) < min(blocks[k + 1]) for k in range(n - 1))
    coverage = all(block_covers_interval(blocks[k], los[k], his[k]) for k in range(n))
    positivity = all(lo >= 1 for lo in los)
    monotone = all(los[k] <= los[k + 1] for k in range(n - 1))
    doubling = all(2 * los[k] <= his[k] + 1 for k in range(n))
    overlap = all(los[k + 1] <= his[k] + 1 for k in range(n - 1))
    return [
        ("blocks pairwise ordered", ordered),
        ("coverage of [lo_k, hi_k]", coverage),
        ("positivity lo_k >= 1", positivity),
        ("monotonicity of lo", monotone),
        ("doubling 2 lo_k <= hi_k + 1", doubling),
        ("overlap lo_{k+1} <= hi_k + 1", overlap),
    ]


def greedy_block_representation(
    n: int, blocks: Sequence[Sequence[int]], los: Sequence[int], his: Sequence[int]
) -> Optional[List[int]]:
    """Represent n as a sum of distinct elements drawn from the ordered blocks.

    Implements the constructive content of the block-covering induction:
    peel off the largest usable block, then recurse on the remainder.
    """
    lo0 = los[0]
    if n < lo0:
        return None
    j = len(blocks) - 1
    chosen: List[int] = []
    while j >= 0:
        if n == 0:
            break
        if n <= his[j] and n >= los[j]:
            part = represent_in_block(n, blocks[j])
            if part is None:
                return None
            return sorted(chosen + part)
        if n > his[j]:
            v = his[j]
        else:
            j -= 1
            continue
        part = represent_in_block(v, blocks[j])
        if part is None:
            return None
        chosen += part
        n -= v
        j -= 1
    return sorted(chosen) if n == 0 else None


def represent_in_block(n: int, block: Sequence[int]) -> Optional[List[int]]:
    """Find a subset of `block` summing exactly to n (small exact search)."""
    if n == 0:
        return []
    items = sorted(block, reverse=True)
    result: List[int] = []

    def rec(idx: int, remaining: int) -> bool:
        if remaining == 0:
            return True
        if idx >= len(items):
            return False
        # prune: cannot reach remaining with what is left
        if sum(items[idx:]) < remaining:
            return False
        if items[idx] <= remaining:
            result.append(items[idx])
            if rec(idx + 1, remaining - items[idx]):
                return True
            result.pop()
        return rec(idx + 1, remaining)

    return result if rec(0, n) else None


# ----------------------------------------------------------------------------
# 5. Backbone-and-residues representation
# ----------------------------------------------------------------------------

def backbone_residue_representation(
    n: int, d: int, membership: Callable[[int], bool], max_deleted: int, search: int = 10_000
) -> Optional[List[int]]:
    """Represent n as a + d*q with a in A, a = n mod d, a > max_deleted.

    This is the constructive content of the backbone-and-residues criterion in
    the case where the backbone is d*N: pick one large residue-repair element,
    then discharge the remaining multiple of d with a single backbone element.
    """
    r = n % d
    a = None
    for cand in range(max_deleted + 1, max_deleted + 1 + search):
        if cand % d == r and membership(cand):
            a = cand
            break
    if a is None or a > n:
        return None
    rest = n - a
    if rest % d != 0:
        return None
    if rest == 0:
        return [a]
    if not membership(rest) or rest <= max_deleted or rest == a:
        return None
    return sorted([a, rest])


# ----------------------------------------------------------------------------
# 6. Distance to the nearest integer and the divergence dictionary
# ----------------------------------------------------------------------------

def dist_to_int(x: Fraction) -> Fraction:
    """||x||: exact distance from a rational x to the nearest integer."""
    frac = x - (x.numerator // x.denominator)
    return min(frac, 1 - frac)


def partial_divergence_sum(elements: Iterable[int], d: int) -> Fraction:
    """Partial sum of ||a/d||^2 over the given elements (exact rational)."""
    total = Fraction(0)
    for a in elements:
        total += dist_to_int(Fraction(a, d)) ** 2
    return total


def count_not_divisible(elements: Iterable[int], d: int) -> int:
    """Number of listed elements NOT divisible by d."""
    return sum(1 for a in elements if a % d != 0)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_fragility(limit: int = 400) -> None:
    banner("1. Completeness is fragile: E_1 = evens + {1}")
    A = evens_with_one(limit)
    print(f"E_1 up to {limit}: {A[:8]} ...  ({len(A)} elements)")
    thr = empirical_threshold(A, limit // 2)
    print(f"  empirical completeness threshold of E_1        : {thr}")
    A1 = delete(A, [1])
    thr1 = empirical_threshold(A1, limit // 2)
    missing = sorted(set(range(limit // 2 + 1)) - reachable_set(A1, limit // 2))[:10]
    print(f"  after deleting the single element 1            : {thr1}")
    print(f"  first unrepresentable values after deletion    : {missing}")
    print("  => complete, but NOT strongly complete: one deletion kills it.")


def demo_evens_and_infinite_odds(limit: int = 400) -> None:
    banner("2. Evens plus INFINITELY many odds is strongly complete")
    A = evens_and_infinite_odds(limit, odd_step=7)
    print(f"A up to {limit}: {A[:10]} ...")
    for F in ([], [1], [1, 15], [1, 15, 29, 43]):
        B = delete(A, F)
        thr = empirical_threshold(B, limit // 2)
        print(f"  delete F = {str(F):<18} -> completeness threshold {thr}")
    print("  => every finite deletion leaves a complete set: robustness.")


def demo_six_per_block(kmax: int = 10) -> None:
    banner("3. Six elements per dyadic block do NOT suffice: the multiples of 3")
    limit = 2 ** (kmax + 1)
    A = multiples_of(3, limit)
    print("  dyadic block sizes for the multiples of 3:")
    for k, c in dyadic_block_counts(A, kmax):
        flag = "  >= 6" if c >= 6 else ""
        print(f"    k = {k:2d}:  |A n (2^k, 2^(k+1)]| = {c:4d}{flag}")
    print()
    print("  explicit six elements inside each block with k >= 5:")
    for k in range(5, min(kmax, 8) + 1):
        c = 3 * ((2 ** k) // 3 + 1)
        six = [c + 3 * i for i in range(6)]
        assert all(2 ** k < x <= 2 ** (k + 1) and x % 3 == 0 for x in six)
        print(f"    k = {k}: {six}")
    print()
    unreachable = sorted(set(range(1, 60)) - reachable_set(A, 60))[:15]
    print(f"  yet the first unreachable totals are: {unreachable}")
    print("  (every subset sum of multiples of 3 is a multiple of 3)")
    print("  => density alone buys nothing; a congruence hypothesis is mandatory.")


def demo_parity_conjecture(limit: int = 300) -> None:
    banner("4. Refuting the parity conjecture: T = 3N u {1,2}")
    T = three_and_units(limit)
    print(f"  T up to {limit}: {T[:10]} ...")
    thr = empirical_threshold(T, limit // 2)
    print(f"  T is complete, empirical threshold             : {thr}")
    odds = [a for a in T if a % 2 == 1][:8]
    print(f"  infinitely many odd elements, e.g.             : {odds} ...")
    T2 = delete(T, [1, 2])
    missing = sorted(set(range(1, 40)) - reachable_set(T2, 40))[:12]
    print(f"  after deleting the two units {{1, 2}}            : not complete")
    print(f"  first unreachable totals                       : {missing}")
    print("  => complete + infinitely many odd elements does NOT imply")
    print("     strong completeness; the obstruction lives modulo 3, not 2.")


def demo_ordered_blocks(K: int = 2, nblocks: int = 4) -> None:
    banner("5. The ordered-block criterion (paired dyadic ranges)")
    blocks: List[List[int]] = []
    los: List[int] = []
    his: List[int] = []
    for j in range(nblocks):
        lo_exp = K + 2 * j
        block = list(range(2 ** lo_exp + 1, 2 ** (lo_exp + 2) + 1))
        blocks.append(block)
        los.append(2 ** lo_exp + 1)
        his.append(2 ** (lo_exp + 2))
    for j in range(nblocks):
        print(f"  B_{j} = ({2**(K+2*j)}, {2**(K+2*j+2)}] , "
              f"covers [{los[j]}, {his[j]}]")
    print()
    for name, ok in check_block_hypotheses(blocks, los, his):
        print(f"  {name:<32}: {'OK' if ok else 'FAIL'}")
    print()
    print("  greedy representations produced by the criterion's algorithm:")
    for n in (23, 57, 200, 700, 1100):
        rep = greedy_block_representation(n, blocks, los, his)
        if rep is not None:
            assert sum(rep) == n and len(set(rep)) == len(rep)
            print(f"    {n:5d} = {' + '.join(map(str, rep))}")
        else:
            print(f"    {n:5d} : outside the finite prefix used here")


def demo_backbone_residues(d: int = 5, max_deleted: int = 200) -> None:
    banner(f"6. Backbone-and-residues criterion (d = {d})")
    # A = all multiples of d, plus every number congruent to r mod d that is a
    # multiple of d*d + r (an artificially sparse but infinite residue stock).
    def membership(x: int) -> bool:
        if x % d == 0:
            return True
        return x % (d * d) in {r * (d + 1) % (d * d) for r in range(1, d)}

    print(f"  backbone: all multiples of {d}")
    print(f"  residues: an infinite sparse stock in every class mod {d}")
    print(f"  adversary deletes everything up to {max_deleted}")
    print()
    ok = True
    for n in range(3000, 3010):
        rep = backbone_residue_representation(n, d, membership, max_deleted)
        if rep is None:
            ok = False
            print(f"    n = {n}: no representation found in the search window")
        else:
            assert sum(rep) == n and len(set(rep)) == len(rep)
            assert all(x > max_deleted for x in rep)
            print(f"    {n} = {' + '.join(map(str, rep))}"
                  f"   (residue repair {rep[0] % d == n % d})")
    print(f"  all targets represented above the deleted range: {ok}")


def demo_divergence_dictionary(limit: int = 20_000) -> None:
    banner("7. The rational divergence dictionary")
    print("  For d >= 2:  sum ||a/d||^2 diverges  <=>  infinitely many a with d not | a")
    print()
    families = {
        "multiples of 3        ": multiples_of(3, limit),
        "T = 3N u {1,2}        ": three_and_units(limit),
        "all natural numbers   ": list(range(1, limit + 1)),
        "evens + one odd (E_1) ": evens_with_one(limit),
        "evens + infinitely many odds": evens_and_infinite_odds(limit, odd_step=7),
    }
    d = 3
    print(f"  test point theta = 1/{d}")
    print(f"  {'family':<30}{'#(a: 3 does not divide a)':>28}{'partial sum':>16}")
    for name, A in families.items():
        cnt = count_not_divisible(A, d)
        s = partial_divergence_sum(A, d)
        print(f"  {name:<30}{cnt:>28}{float(s):>16.3f}")
    print()
    print("  The multiples of 3 give partial sum exactly 0 (every term vanishes),")
    print("  and T gives a bounded partial sum (only the two units contribute):")
    print("  both FAIL the divergence hypothesis at theta = 1/3, exactly as the")
    print("  theory predicts, since neither is strongly complete.")
    print()
    print("  Growth of the partial sums at theta = 1/3 for the natural numbers:")
    for N in (100, 1000, 5000, 20000):
        s = partial_divergence_sum(range(1, N + 1), 3)
        print(f"    N = {N:6d}: sum = {float(s):10.3f}   (~ 2N/27 = {2*N/27:10.3f})")


def demo_necessity(limit: int = 2000) -> None:
    banner("8. Congruence necessity for strong completeness")
    print("  A strongly complete set has, for every d >= 2, infinitely many")
    print("  elements outside the subgroup dZ. Counting witnesses up to", limit, ":")
    print()
    families = {
        "all natural numbers": list(range(1, limit + 1)),
        "multiples of 3     ": multiples_of(3, limit),
        "T = 3N u {1,2}     ": three_and_units(limit),
        "evens + one odd    ": evens_with_one(limit),
    }
    print(f"  {'family':<22}" + "".join(f"{'d=' + str(d):>8}" for d in (2, 3, 4, 5)))
    for name, A in families.items():
        row = "".join(f"{count_not_divisible(A, d):>8}" for d in (2, 3, 4, 5))
        print(f"  {name:<22}{row}")
    print()
    print("  A bounded (in fact constant) column entry as `limit` grows signals a")
    print("  congruence obstruction: deleting those finitely many elements traps")
    print("  the set inside a proper subgroup.")


def main() -> None:
    print(__doc__)
    demo_fragility()
    demo_evens_and_infinite_odds()
    demo_six_per_block()
    demo_parity_conjecture()
    demo_ordered_blocks()
    demo_backbone_residues()
    demo_divergence_dictionary()
    demo_necessity()
    banner("Summary")
    print("""
  * Completeness can be destroyed by a single deletion (evens + {1}).
  * Strong completeness needs TWO deletion-stable mechanisms:
      - size      (blocks covering long intervals, or an arithmetic backbone),
      - congruence(infinitely many elements in every residue class).
  * Either alone fails: the multiples of 3 have unlimited size but no residues;
    evens + one odd have a residue only finitely often.
  * The parity conjecture is false: 3N u {1,2} is complete with infinitely many
    odd elements yet not strongly complete.
  * At rational test points the analytic divergence hypothesis is EXACTLY the
    congruence condition: sum ||a/d||^2 = infinity iff infinitely many elements
    escape the subgroup dZ.
""")


if __name__ == "__main__":
    main()
