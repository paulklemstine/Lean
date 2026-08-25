"""
Quartet codes: numerical demonstrations
=======================================

A binary (unrooted, fully resolved) phylogenetic tree on a leaf set X induces, on
every four-element subset {a,b,c,d} of X, one of exactly three resolutions

        ab|cd ,   ac|bd ,   ad|bc ,

called the *quartet* displayed on those four leaves.  Encoding a tree by the list
of its quartet resolutions turns a family of trees into a family of words over a
ternary alphabet, indexed by the four-element subsets of X.  Under this
dictionary:

    "the family displays a common quartet on {a,b,c,d}"
        <=>  "all words carry the same letter in coordinate {a,b,c,d}".

This script demonstrates, entirely by explicit computation:

  1. the quartet type of a caterpillar tree, read off from its leaf order;
  2. exact ternary balance: for four fixed distinct leaves each of the three
     quartet types is displayed by exactly n!/3 of the n! leaf orders;
  3. the first-moment identity Pr[k random caterpillars agree on a fixed
     quartet] = 3^{-(k-1)} exactly, and the resulting exponential lower bound;
  4. the sharp two-tree threshold: an explicit pair of five-leaf trees with no
     common quartet, and an exhaustive check that six leaves always force one;
  5. an explicit triple of nine-leaf trees with no common quartet;
  6. the constrained ("parity check") structure of tree-realisable words:
     only 15 of the 3^5 = 243 ternary words of length five are realisable, and
     15 = 5!/8;
  7. the packing bound  8 * #(distinct signatures) <= n!  , verified for small n;
  8. the collapse of the naive distance formulation: over a ternary alphabet, a
     family of words that pairwise differ in *every* coordinate has at most
     three members;
  9. a randomised search for large quartet-avoiding families, giving empirical
     values for the growth rate of the threshold.

Everything is standard library Python.
"""

from __future__ import annotations

import itertools
import random
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Order = Tuple[int, ...]  # order[leaf] = position of that leaf along the caterpillar
Quad = Tuple[int, int, int, int]


# ---------------------------------------------------------------------------
# 1. The ternary quartet letter
# ---------------------------------------------------------------------------


def code3(p: int, q: int, r: int, s: int) -> int:
    """The quartet type of four distinct positions p, q, r, s on a path.

    Returns 0 for the pairing {1st,2nd}|{3rd,4th} of the argument list, i.e.
    ``pq|rs``; 1 for ``pr|qs``; 2 for ``ps|qr``.  On a caterpillar tree whose
    leaves hang off a path in the order given by the positions, two leaves are
    paired precisely when they occupy the two lowest (or the two highest)
    positions among the four.
    """
    if max(p, q) < min(r, s) or max(r, s) < min(p, q):
        return 0
    if max(p, r) < min(q, s) or max(q, s) < min(p, r):
        return 1
    return 2


def qcode(order: Order, a: int, b: int, c: int, d: int) -> int:
    """Quartet type displayed on leaves a,b,c,d by the caterpillar with `order`."""
    return code3(order[a], order[b], order[c], order[d])


def signature(order: Order, n: int) -> Tuple[int, ...]:
    """Ternary word of length C(n,4): the quartet letters of the caterpillar."""
    return tuple(
        qcode(order, a, b, c, d) for a, b, c, d in itertools.combinations(range(n), 4)
    )


def all_orders(n: int) -> Iterable[Order]:
    return itertools.permutations(range(n))


# ---------------------------------------------------------------------------
# 2. Exact ternary balance
# ---------------------------------------------------------------------------


def ternary_balance(n: int, quad: Quad) -> Dict[int, int]:
    """Count the leaf orders on n leaves realising each type on a fixed quartet."""
    counts: Dict[int, int] = {0: 0, 1: 0, 2: 0}
    a, b, c, d = quad
    for order in all_orders(n):
        counts[qcode(order, a, b, c, d)] += 1
    return counts


def demo_balance() -> None:
    print("=" * 74)
    print("2.  EXACT TERNARY BALANCE:  each type occurs for exactly n!/3 orders")
    print("=" * 74)
    for n, quad in ((4, (0, 1, 2, 3)), (5, (0, 2, 3, 4)), (6, (1, 2, 4, 5))):
        counts = ternary_balance(n, quad)
        total = sum(counts.values())
        fact = 1
        for i in range(1, n + 1):
            fact *= i
        ok = all(3 * v == fact for v in counts.values())
        print(
            f"  n={n}, quartet {quad}:  counts {counts},  total {total} = {n}!"
            f"   balanced: {ok}"
        )
    print()


# ---------------------------------------------------------------------------
# 3. First moment and the exponential lower bound
# ---------------------------------------------------------------------------


def agreement_probability(n: int, k: int, quad: Quad) -> Fraction:
    """Exact probability that k independent uniform leaf orders agree on `quad`."""
    counts = ternary_balance(n, quad)
    total = sum(counts.values())
    num = sum(v**k for v in counts.values())
    return Fraction(num, total**k)


def demo_first_moment() -> None:
    print("=" * 74)
    print("3.  FIRST MOMENT:  Pr[k caterpillars agree on a fixed quartet] = 3^{1-k}")
    print("=" * 74)
    for n in (4, 5, 6):
        for k in (2, 3, 4):
            p = agreement_probability(n, k, (0, 1, 2, 3))
            print(
                f"  n={n}, k={k}:  P = {p}   (predicted 1/3^{k-1} = "
                f"{Fraction(1, 3 ** (k - 1))})   match: {p == Fraction(1, 3 ** (k - 1))}"
            )
    print()
    print("  Union bound: if n^4 < 3^m then m+1 caterpillars on n leaves avoid")
    print("  every common quartet.  Taking n = 3^v and m = 4v+1:")
    print(f"  {'v':>3} {'leaves n=3^v':>14} {'trees 4v+2':>12} {'n^4':>18} {'3^(4v+1)':>20}")
    for v in range(1, 7):
        n = 3**v
        print(f"  {v:>3} {n:>14} {4 * v + 2:>12} {n**4:>18} {3 ** (4 * v + 1):>20}")
    print("  Hence h(k) > 3^{(k-2)/4}: one extra tree buys a factor 3^{1/4} = 1.316 in leaves.")
    print()


# ---------------------------------------------------------------------------
# 4. The sharp two-tree threshold
# ---------------------------------------------------------------------------


def common_quartets(orders: Sequence[Order], n: int) -> List[Quad]:
    """Quartets on which every caterpillar in the list displays the same type."""
    out: List[Quad] = []
    for quad in itertools.combinations(range(n), 4):
        a, b, c, d = quad
        t = qcode(orders[0], a, b, c, d)
        if all(qcode(o, a, b, c, d) == t for o in orders[1:]):
            out.append((a, b, c, d))
    return out


def compose(pi: Order, sigma: Order) -> Order:
    """Composition (pi o sigma) of two permutations given in one-line notation."""
    return tuple(pi[sigma[i]] for i in range(len(sigma)))


def inverse(pi: Order) -> Order:
    out = [0] * len(pi)
    for i, v in enumerate(pi):
        out[v] = i
    return tuple(out)


def demo_two_trees() -> None:
    print("=" * 74)
    print("4.  THE TWO-TREE THRESHOLD IS EXACTLY SIX LEAVES")
    print("=" * 74)
    identity5: Order = (0, 1, 2, 3, 4)
    swapped5: Order = (0, 3, 2, 1, 4)  # positions of leaves 1 and 3 exchanged
    shared = common_quartets([identity5, swapped5], 5)
    print(f"  Five leaves, orders {identity5} and {swapped5}:")
    print(f"    quartets:            {list(itertools.combinations(range(5), 4))}")
    print(f"    types of tree 1:     {[qcode(identity5, *q) for q in itertools.combinations(range(5), 4)]}")
    print(f"    types of tree 2:     {[qcode(swapped5, *q) for q in itertools.combinations(range(5), 4)]}")
    print(f"    common quartets:     {shared}   -> h(2) > 5")
    # Six leaves: by the right-translation action it suffices to compare the
    # identity order with every order.
    bad = [u for u in all_orders(6) if not common_quartets([tuple(range(6)), u], 6)]
    print(f"  Six leaves: orders sharing no quartet with the identity order: {len(bad)}")
    print("    (the group action (pi,rho) -> (id, rho pi^{-1}) reduces all 720^2 pairs")
    print("     to these 720 cases)  ->  h(2) = 6 exactly for caterpillar-shaped trees.")
    print()


# ---------------------------------------------------------------------------
# 5. Three trees on nine leaves
# ---------------------------------------------------------------------------


def demo_three_trees() -> None:
    print("=" * 74)
    print("5.  THREE TREES ON NINE LEAVES WITH NO COMMON QUARTET")
    print("=" * 74)
    o1: Order = tuple(range(9))
    o2: Order = (7, 0, 2, 5, 4, 3, 1, 8, 6)
    o3: Order = (6, 5, 1, 3, 4, 2, 7, 8, 0)
    shared = common_quartets([o1, o2, o3], 9)
    print(f"  orders: {o1}\n          {o2}\n          {o3}")
    print(f"  number of quartets checked: {len(list(itertools.combinations(range(9), 4)))}")
    print(f"  common quartets: {shared}  ->  h(3) > 9, i.e. h(3) >= 10.")
    print("  Upper end (monotone-subsequence argument): h(3) <= 3^8 + 1 = 6562.")
    print()


# ---------------------------------------------------------------------------
# 6. The constrained code on five leaves
# ---------------------------------------------------------------------------


def demo_five_leaf_code() -> None:
    print("=" * 74)
    print("6.  THE FIVE-LEAF CODE:  15 realisable words out of 3^5 = 243")
    print("=" * 74)
    words: Set[Tuple[int, ...]] = {signature(o, 5) for o in all_orders(5)}
    print(f"  realisable ternary words of length 5 : {len(words)}")
    print(f"  ambient ternary cube                 : {3 ** 5}")
    print(f"  8 * 15 = {8 * len(words)} = 5! = 120 :", 8 * len(words) == 120)
    import math

    rate = math.log(len(words), 3) / 5
    print(f"  code rate  log_3(15)/5              = {rate:.4f}")
    # local rule: ab|cd and ab|ce force ab|de
    violations = 0
    for order in all_orders(5):
        for a, b, c, d, e in itertools.permutations(range(5)):
            if qcode(order, a, b, c, d) == 0 and qcode(order, a, b, c, e) == 0:
                if qcode(order, a, b, d, e) != 0:
                    violations += 1
    print(f"  cherry-propagation rule  (ab|cd & ab|ce => ab|de)  violations: {violations}")
    print()


# ---------------------------------------------------------------------------
# 7. Packing: the signature map is exactly eight-to-one
# ---------------------------------------------------------------------------


def demo_packing() -> None:
    print("=" * 74)
    print("7.  PACKING BOUND:  8 * #(distinct signatures) <= n!")
    print("=" * 74)
    print(f"  {'n':>3} {'n!':>8} {'#signatures':>13} {'n!/#sig':>9}")
    for n in (4, 5, 6, 7):
        words = {signature(o, n) for o in all_orders(n)}
        fact = 1
        for i in range(1, n + 1):
            fact *= i
        print(f"  {n:>3} {fact:>8} {len(words):>13} {fact // len(words):>9}")
    print("  The fibres are the eight caterpillar symmetries: the identity, the")
    print("  reversal of the path, the exchange of the two leaves at the left end,")
    print("  the exchange of the two leaves at the right end, and their products.")
    print()


# ---------------------------------------------------------------------------
# 8. Full Hamming distance collapses over a ternary alphabet
# ---------------------------------------------------------------------------


def largest_full_distance_family(length: int, alphabet: int = 3) -> int:
    """Largest family of words pairwise differing in EVERY coordinate."""
    best = 0
    words = list(itertools.product(range(alphabet), repeat=length))

    def extend(chosen: List[Tuple[int, ...]], start: int) -> None:
        nonlocal best
        best = max(best, len(chosen))
        for i in range(start, len(words)):
            w = words[i]
            if all(all(x != y for x, y in zip(w, c)) for c in chosen):
                chosen.append(w)
                extend(chosen, i + 1)
                chosen.pop()

    extend([], 0)
    return best


def demo_distance_collapse() -> None:
    print("=" * 74)
    print("8.  FULL-DISTANCE FAMILIES OVER A TERNARY ALPHABET HAVE <= 3 MEMBERS")
    print("=" * 74)
    for length in (1, 2, 3, 4):
        print(f"  word length {length}: largest family = {largest_full_distance_family(length)}")
    print("  Reason: the first letters are pairwise distinct, and there are only three.")
    print("  So 'no common quartet' cannot be obtained by maximising Hamming distance;")
    print("  the correct notion is the weaker 'no constant coordinate'.")
    print()


# ---------------------------------------------------------------------------
# 9. How large can an avoiding family be?  A randomised search
# ---------------------------------------------------------------------------


def type_vector(order: Order, quads: Sequence[Quad]) -> List[int]:
    return [code3(order[a], order[b], order[c], order[d]) for a, b, c, d in quads]


def agreement_cost(vectors: Sequence[Sequence[int]]) -> int:
    """Number of coordinates on which all words carry the same letter."""
    first = vectors[0]
    total = 0
    for idx, t in enumerate(first):
        if all(v[idx] == t for v in vectors[1:]):
            total += 1
    return total


def search_avoiding(k: int, n: int, restarts: int = 3, steps: int = 600,
                    seed: int = 20240825) -> Sequence[Order] | None:
    """Local search for k leaf orders on n leaves with no common quartet."""
    rng = random.Random(seed + 1000 * k + n)
    quads = list(itertools.combinations(range(n), 4))
    for _ in range(restarts):
        orders: List[Order] = []
        for _ in range(k):
            p = list(range(n))
            rng.shuffle(p)
            orders.append(tuple(p))
        vectors = [type_vector(o, quads) for o in orders]
        cur = agreement_cost(vectors)
        for _ in range(steps):
            if cur == 0:
                return orders
            i = rng.randrange(k)
            p = list(orders[i])
            x, y = rng.randrange(n), rng.randrange(n)
            p[x], p[y] = p[y], p[x]
            cand = tuple(p)
            cand_vec = type_vector(cand, quads)
            old_vec = vectors[i]
            vectors[i] = cand_vec
            new = agreement_cost(vectors)
            if new <= cur:
                orders[i], cur = cand, new
            else:
                vectors[i] = old_vec
        if cur == 0:
            return orders
    return None


def demo_search() -> None:
    print("=" * 74)
    print("9.  EMPIRICAL GROWTH OF THE LARGEST AVOIDING LEAF NUMBER")
    print("=" * 74)
    print("  (local search; a failure is evidence, not proof, that none exists)")
    print(f"  {'k trees':>8} {'largest n found with no common quartet':>44}")
    record: Dict[int, int] = {}
    for k in (2, 3, 4):
        best = 0
        for n in range(4, 19):
            found = search_avoiding(k, n)
            if found is not None:
                best = n
        record[k] = best
        print(f"  {k:>8} {best:>44}")
    ks = sorted(record)
    for k1, k2 in zip(ks, ks[1:]):
        if record[k1]:
            print(
                f"  ratio n(k={k2})/n(k={k1}) = {record[k2] / record[k1]:.2f}"
                f"   (certified rate from the first moment: 3^(1/4) = 1.32)"
            )
    print()


def main() -> None:
    print()
    print("QUARTET CODES: exponential lower bounds for the common-quartet threshold")
    print()
    demo_balance()
    demo_first_moment()
    demo_two_trees()
    demo_three_trees()
    demo_five_leaf_code()
    demo_packing()
    demo_distance_collapse()
    demo_search()
    print("Done.")


if __name__ == "__main__":
    main()
