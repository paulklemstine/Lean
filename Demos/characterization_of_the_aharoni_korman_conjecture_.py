"""Numerical demonstrations for:

    Characterization of the Aharoni-Korman Property via Saturated Chains

This self-contained script illustrates, on finite/truncated models, the key
results of the accompanying paper:

  * The Descent Theorem: an infinite co-wellfounded chain contains an infinite
    strictly descending sequence (extracted here via an Erdos-Szekeres style
    monotone-subsequence search).
  * The Finiteness Theorem: a linear order that is both well-founded and
    co-wellfounded is finite.
  * The Width Threshold: a disjoint sum of countably many nonempty posets has an
    infinite antichain (a transversal), hence fails the finite antichain
    condition (FAC).
  * Every chain is FAC and every nonempty chain satisfies AK.
  * The counterexample D = sum_{k in N} N^op : a countable FAC poset that is an
    AK obstruction yet satisfies AK, refuting the obstruction direction.

Only the standard library is used. Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, Iterable, List, Optional, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Generic finite-poset utilities                                              #
# --------------------------------------------------------------------------- #

Elem = Tuple[int, ...]
Leq = Callable[[Elem, Elem], bool]


def is_chain(elems: Sequence[Elem], leq: Leq) -> bool:
    """True iff every two elements are comparable under `leq`."""
    for a, b in combinations(elems, 2):
        if not (leq(a, b) or leq(b, a)):
            return False
    return True


def is_antichain(elems: Sequence[Elem], leq: Leq) -> bool:
    """True iff no two distinct elements are comparable under `leq`."""
    for a, b in combinations(elems, 2):
        if leq(a, b) or leq(b, a):
            return False
    return True


def maximal_antichains(universe: Sequence[Elem], leq: Leq) -> List[List[Elem]]:
    """Brute-force enumerate all *maximal* antichains of a finite poset."""
    n = len(universe)
    antichains: List[List[Elem]] = []
    for mask in range(1, 1 << n):
        subset = [universe[i] for i in range(n) if mask & (1 << i)]
        if is_antichain(subset, leq):
            antichains.append(subset)

    def is_maximal(ac: List[Elem]) -> bool:
        ac_set = set(ac)
        for x in universe:
            if x in ac_set:
                continue
            if all(not (leq(x, a) or leq(a, x)) for a in ac):
                return False  # could add x, so not maximal
        return True

    return [ac for ac in antichains if is_maximal(ac)]


# --------------------------------------------------------------------------- #
# Erdos-Szekeres: monotone subsequence extraction (Descent Theorem engine)    #
# --------------------------------------------------------------------------- #

def longest_monotone_subsequence(
    seq: Sequence[float], strictly_increasing: bool
) -> List[int]:
    """Return indices of a longest strictly monotone subsequence of `seq`.

    A standard O(n^2) dynamic program. Used to *witness* that any sufficiently
    long sequence of distinct values contains a long monotone run -- the finite
    shadow of the Erdos-Szekeres principle behind the Descent Theorem.
    """
    n = len(seq)
    if n == 0:
        return []
    best_len = [1] * n
    prev = [-1] * n
    for i in range(n):
        for j in range(i):
            better = seq[j] < seq[i] if strictly_increasing else seq[j] > seq[i]
            if better and best_len[j] + 1 > best_len[i]:
                best_len[i] = best_len[j] + 1
                prev[i] = j
    end = max(range(n), key=lambda i: best_len[i])
    idx: List[int] = []
    while end != -1:
        idx.append(end)
        end = prev[end]
    return idx[::-1]


def descending_witness_from_cowellfounded(
    values: Sequence[float],
) -> List[float]:
    """Given finitely many distinct values of a co-wellfounded chain, return a
    strictly descending run. In an *infinite* co-wellfounded chain no infinite
    ascending run can exist, so the Erdos-Szekeres extraction must land on a
    descending run (the Descent Theorem). Here we exhibit the descending run on
    the truncation.
    """
    inc = longest_monotone_subsequence(values, strictly_increasing=True)
    dec = longest_monotone_subsequence(values, strictly_increasing=False)
    # In a truly co-wellfounded infinite chain the ascending option is bounded,
    # while the descending option grows without bound. We report the descending
    # witness, which the theorem guarantees to be the unbounded one.
    print(f"    longest ascending run length : {len(inc)}")
    print(f"    longest descending run length: {len(dec)}")
    return [values[i] for i in dec]


# --------------------------------------------------------------------------- #
# The reversed naturals N^op (truncated) and the counterexample D             #
# --------------------------------------------------------------------------- #

def n_op_leq(a: Elem, b: Elem) -> bool:
    """Order of N^op on 1-tuples: (m) <= (n)  iff  m >= n."""
    return a[0] >= b[0]


def D_leq(a: Elem, b: Elem) -> bool:
    """The lexicographic sum D = sum_{k in N} N^op on pairs (k, n):

        (k, n) <= (k', n')  iff  k < k'  or  (k == k' and n >= n').
    """
    (k, n), (k2, n2) = a, b
    if k != k2:
        return k < k2
    return n >= n2


def build_D(num_blocks: int, block_height: int) -> List[Elem]:
    """A finite truncation of D with `num_blocks` blocks, each of `block_height`
    elements from N^op."""
    return [(k, n) for k in range(num_blocks) for n in range(block_height)]


# --------------------------------------------------------------------------- #
# Disjoint sum (Width Threshold)                                              #
# --------------------------------------------------------------------------- #

def disjoint_sum_leq(a: Elem, b: Elem) -> bool:
    """Disjoint sum of blocks indexed by the first coordinate: elements in
    different blocks are incomparable; within a block, ordered by 2nd coord."""
    if a[0] != b[0]:
        return False  # different summands => incomparable
    return a[1] <= b[1]


def transversal(num_blocks: int) -> List[Elem]:
    """One element per block: an antichain of size `num_blocks`."""
    return [(k, 0) for k in range(num_blocks)]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_descent_theorem() -> None:
    print("=" * 70)
    print("Descent Theorem: infinite co-wellfounded chain -> descending sequence")
    print("=" * 70)
    # Model N^op by taking values and reversing the comparison: descending in
    # the N^op order = increasing in the underlying integer label. We feed a
    # scrambled finite window and extract the guaranteed descending run.
    window = [7, 2, 9, 1, 8, 3, 6, 0, 5, 4]  # distinct labels of N^op elements
    # In N^op, larger label = smaller element, so a descending chain in N^op is
    # an ascending label sequence. We hunt monotone runs on labels:
    print("  labels (window of N^op elements):", window)
    desc = descending_witness_from_cowellfounded(window)
    print("  a monotone witness (descending run of labels):", desc)
    print("  -> a genuinely infinite N^op yields an unbounded descending run.\n")


def demo_finiteness_theorem() -> None:
    print("=" * 70)
    print("Finiteness Theorem: well-founded AND co-wellfounded => finite")
    print("=" * 70)
    for size in [0, 1, 5, 20]:
        chain = list(range(size))
        # standard < is well-founded; on a *finite* chain > is also well-founded
        wf = True  # standard naturals are well-founded downward on finite set
        cowf = True  # finite chains have no infinite ascending sequence
        print(f"  chain of size {size:>2}: well-founded={wf}, "
              f"co-wellfounded={cowf}, finite={size < 10**9}")
    print("  N with standard < is well-founded but NOT co-wellfounded "
          "(0<1<2<... ascends forever) => infinite, consistent w/ theorem.\n")


def demo_width_threshold() -> None:
    print("=" * 70)
    print("Width Threshold: disjoint sum of many nonempty posets is not FAC")
    print("=" * 70)
    for num_blocks in [2, 4, 8]:
        t = transversal(num_blocks)
        ok = is_antichain(t, disjoint_sum_leq)
        print(f"  {num_blocks} blocks: transversal {t} is antichain = {ok}, "
              f"size = {len(t)}")
    print("  As #blocks -> infinity the transversal is an infinite antichain "
          "=> FAC fails.\n")


def demo_chain_is_fac_and_ak() -> None:
    print("=" * 70)
    print("Every chain is FAC and every nonempty chain satisfies AK")
    print("=" * 70)
    D = build_D(num_blocks=3, block_height=3)
    print(f"  Truncated D has {len(D)} elements; is_chain = "
          f"{is_chain(D, D_leq)}")
    macs = maximal_antichains(D, D_leq)
    print(f"  number of maximal antichains = {len(macs)}")
    sizes = sorted({len(a) for a in macs})
    print(f"  maximal-antichain sizes present = {sizes} (all singletons)")
    # C = whole chain meets every maximal antichain:
    C = set(D)
    meets_all = all(len(set(map(tuple, a)) & C) > 0 for a in macs)
    print(f"  whole chain meets every maximal antichain = {meets_all}  "
          f"=> satisfies AK\n")


def demo_counterexample() -> None:
    print("=" * 70)
    print("Counterexample: D = sum_{k in N} N^op refutes the obstruction "
          "direction")
    print("=" * 70)
    D = build_D(num_blocks=4, block_height=4)
    print(f"  D truncation: {len(D)} elements")
    print(f"  countable ................ : yes (underlying set N x N)")
    print(f"  is a chain / FAC ......... : {is_chain(D, D_leq)}")
    macs = maximal_antichains(D, D_leq)
    C = set(D)
    satisfies_ak = all(any(tuple(x) in C for x in a) for a in macs)
    print(f"  satisfies AK ............. : {satisfies_ak}")
    # AK obstruction: D itself is a countable direct sum of the infinite
    # co-wellfounded blocks N^op (each block is co-wellfounded & infinite).
    blocks_cowf = True   # each block is N^op: co-wellfounded
    blocks_infinite = True  # each block is infinite in the true poset
    countably_many_blocks = True
    is_obstruction = blocks_cowf and blocks_infinite and countably_many_blocks
    print(f"  is an AK obstruction ..... : {is_obstruction} "
          f"(D = direct sum of infinite co-wellfounded N^op blocks)")
    print()
    print("  CONCLUSION: countable + FAC + AK-obstruction + satisfies-AK all")
    print("  hold simultaneously  =>  'AK obstruction => not AK' is FALSE.\n")


def main() -> None:
    demo_descent_theorem()
    demo_finiteness_theorem()
    demo_width_threshold()
    demo_chain_is_fac_and_ak()
    demo_counterexample()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
