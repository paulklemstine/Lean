"""Numerical demonstrations of the Closure-Extractor Duality.

This script is fully self-contained (standard library only) and illustrates,
on concrete finite examples, every result from the framework:

  * closure operators (extensive / monotone / idempotent) and closed sets;
  * deficiency  def(A) = |cl(A)| - |A|  and the entropy surrogate;
  * closure-equivalence, closure-stable predicates, and the encoding map;
  * k-separation for predicate families, seed families, and matrices;
  * the encoding-separation equivalence (Theorem 6.1);
  * the duality, both directions (Theorems 7.1, 7.3);
  * certified reconstruction from a separating matrix (Theorem 8.1).

Two concrete closure operators are used:
  (1) a *partition closure*  cl(A) = union of blocks meeting A;
  (2) a *GF(2) span closure*  cl(A) = linear span of A in (Z/2)^d.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Tuple

# A closure operator is modelled as a function from frozensets to frozensets.
ClosureOp = Callable[[FrozenSet[int]], FrozenSet[int]]


# --------------------------------------------------------------------------- #
# Section 3: closure operators, closed sets, deficiency
# --------------------------------------------------------------------------- #
def partition_closure(blocks: Sequence[FrozenSet[int]]) -> ClosureOp:
    """cl(A) = union of all blocks that intersect A. (A partition of X.)"""
    def cl(a: FrozenSet[int]) -> FrozenSet[int]:
        out: set[int] = set()
        for block in blocks:
            if a & block:
                out |= block
        return frozenset(out)
    return cl


def down_closure(ground: FrozenSet[int], below: Callable[[int, int], bool]) -> ClosureOp:
    """cl(A) = A together with everything below some element of A.

    `below` must be a (transitive, reflexive) preorder for idempotence;
    e.g. divisibility:  below(y, x) = (x % y == 0).
    """
    def cl(a: FrozenSet[int]) -> FrozenSet[int]:
        out = set(a)
        for x in a:
            for y in ground:
                if below(y, x):
                    out.add(y)
        return frozenset(out)
    return cl


def gf2_span_closure(vectors: Dict[int, Tuple[int, ...]]) -> ClosureOp:
    """cl(A) = {x : vector[x] lies in the GF(2)-span of {vector[a] : a in A}}."""
    def span(rows: List[Tuple[int, ...]]) -> set[Tuple[int, ...]]:
        # Gaussian elimination over GF(2) to a basis, then enumerate the span.
        basis: List[Tuple[int, ...]] = []
        for r in rows:
            cur = list(r)
            for b in basis:
                # reduce by leading 1 of b
                lead = next((i for i, v in enumerate(b) if v == 1), None)
                if lead is not None and cur[lead] == 1:
                    cur = [(c ^ d) for c, d in zip(cur, b)]
            if any(cur):
                basis.append(tuple(cur))
        full: set[Tuple[int, ...]] = set()
        dim = len(basis)
        for coeffs in product((0, 1), repeat=dim):
            acc = None
            for c, b in zip(coeffs, basis):
                if c:
                    acc = tuple(b) if acc is None else tuple(x ^ y for x, y in zip(acc, b))
            if acc is None:
                acc = tuple(0 for _ in next(iter(vectors.values())))
            full.add(acc)
        return full

    def cl(a: FrozenSet[int]) -> FrozenSet[int]:
        sp = span([vectors[i] for i in a])
        return frozenset(x for x, v in vectors.items() if v in sp)
    return cl


def is_closed(cl: ClosureOp, c: FrozenSet[int]) -> bool:
    return cl(c) == c


def deficiency(cl: ClosureOp, a: FrozenSet[int]) -> int:
    return len(cl(a)) - len(a)


def entropy_surrogate(cl: ClosureOp, ground: FrozenSet[int], a: FrozenSet[int]) -> int:
    return len(ground) - deficiency(cl, a)


def all_closed_sets(cl: ClosureOp, ground: FrozenSet[int]) -> List[FrozenSet[int]]:
    closed: List[FrozenSet[int]] = []
    elems = sorted(ground)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            c = frozenset(combo)
            if is_closed(cl, c):
                closed.append(c)
    return closed


def check_closure_axioms(cl: ClosureOp, ground: FrozenSet[int]) -> bool:
    """Verify extensivity, monotonicity, idempotence on all subsets (small X)."""
    elems = sorted(ground)
    subsets = [frozenset(c) for r in range(len(elems) + 1) for c in combinations(elems, r)]
    for a in subsets:
        if not a <= cl(a):                       # extensivity
            return False
        if cl(cl(a)) != cl(a):                   # idempotence
            return False
        for b in subsets:
            if a <= b and not cl(a) <= cl(b):    # monotonicity
                return False
    return True


# --------------------------------------------------------------------------- #
# Section 4: closure-equivalence, predicates, encoding
# --------------------------------------------------------------------------- #
def closure_equiv(cl: ClosureOp, x: int, y: int) -> bool:
    return cl(frozenset({x})) == cl(frozenset({y}))


Predicate = Callable[[int], bool]


def is_closure_stable(cl: ClosureOp, ground: FrozenSet[int], phi: Predicate) -> bool:
    for x in ground:
        for y in ground:
            if closure_equiv(cl, x, y) and phi(x) != phi(y):
                return False
    return True


def encoding(phis: Sequence[Predicate], x: int) -> Tuple[bool, ...]:
    return tuple(phi(x) for phi in phis)


# --------------------------------------------------------------------------- #
# Section 5-6: separation notions and the encoding-separation equivalence
# --------------------------------------------------------------------------- #
def predicate_family_separates(
    cl: ClosureOp, ground: FrozenSet[int], phis: Sequence[Predicate], k: int
) -> bool:
    for c in all_closed_sets(cl, ground):
        if len(c) < k:
            continue
        for x, y in combinations(sorted(c), 2):
            if all(phi(x) == phi(y) for phi in phis):
                return False
    return True


def encoding_injective_on_large_closed(
    cl: ClosureOp, ground: FrozenSet[int], phis: Sequence[Predicate], k: int
) -> bool:
    for c in all_closed_sets(cl, ground):
        if len(c) < k:
            continue
        for x, y in combinations(sorted(c), 2):
            if encoding(phis, x) == encoding(phis, y):
                return False
    return True


SeedFamily = Callable[[int, int], object]  # (seed, x) -> output


def seed_family_separates(
    cl: ClosureOp, ground: FrozenSet[int], seeds: Sequence[int], f: SeedFamily, k: int
) -> bool:
    for c in all_closed_sets(cl, ground):
        if len(c) < k:
            continue
        for x, y in combinations(sorted(c), 2):
            if all(f(s, x) == f(s, y) for s in seeds):
                return False
    return True


def is_closure_compatible(
    cl: ClosureOp, ground: FrozenSet[int], seeds: Sequence[int], f: SeedFamily
) -> bool:
    for s in seeds:
        for x in ground:
            for y in ground:
                if closure_equiv(cl, x, y) and f(s, x) != f(s, y):
                    return False
    return True


def matrix_separates_closed_sets(
    cl: ClosureOp, ground: FrozenSet[int], rows: Sequence[Predicate], k: int
) -> bool:
    # A Boolean matrix is just a finite family of Boolean rows (predicates).
    return predicate_family_separates(cl, ground, rows, k)


# --------------------------------------------------------------------------- #
# Section 7-8: the duality constructions
# --------------------------------------------------------------------------- #
def duality_backward(phis: Sequence[Predicate]) -> Tuple[List[int], SeedFamily]:
    """Theorem 7.1: one seed whose map is the full encoding."""
    seeds = [0]
    def f(_s: int, x: int) -> Tuple[bool, ...]:
        return encoding(phis, x)
    return seeds, f


def duality_forward(
    seeds: Sequence[int], outputs: Sequence[object], f: SeedFamily
) -> List[Predicate]:
    """Theorem 7.3: indicator predicates phi_{s,y}(x) = [f(s,x) == y]."""
    preds: List[Predicate] = []
    for s in seeds:
        for y in outputs:
            preds.append((lambda s, y: (lambda x: f(s, x) == y))(s, y))
    return preds


def reconstruct_from_matrix(rows: Sequence[Predicate]) -> Tuple[List[int], SeedFamily]:
    """Theorem 8.1: each element maps to its own column vector."""
    seeds = [0]
    def f(_s: int, x: int) -> Tuple[bool, ...]:
        return tuple(row(x) for row in rows)
    return seeds, f


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_partition() -> None:
    banner("Example 1: divisibility down-closure on X = {1,...,6}")
    ground = frozenset(range(1, 7))
    below: Callable[[int, int], bool] = lambda y, x: x % y == 0   # y divides x
    cl = down_closure(ground, below)

    print("closure: cl(A) = A union all proper divisors of its elements")
    print("closure axioms hold:", check_closure_axioms(cl, ground))

    closed = all_closed_sets(cl, ground)
    print(f"number of closed (divisor-closed / down-) sets: {len(closed)}")

    a = frozenset({4})
    print(f"\nA = {sorted(a)} :  cl(A) = {sorted(cl(a))}  (divisors of 4)")
    print(f"  deficiency(A)        = {deficiency(cl, a)}  (drags in 1, 2)")
    print(f"  entropy surrogate(A) = {entropy_surrogate(cl, ground, a)}")
    c = frozenset({1, 2, 3, 6})
    print(f"C = {sorted(c)} is closed: {is_closed(cl, c)}  (divisor-closed)")
    print(f"  deficiency(C)        = {deficiency(cl, c)}  (zero on closed sets)")
    print(f"  entropy surrogate(C) = {entropy_surrogate(cl, ground, c)}  (== |X| = {len(ground)})")

    # Singleton closures cl({x}) = divisors of x are pairwise distinct here, so
    # closure-equivalence is trivial and *any* predicate is closure-stable.
    print("\nall singleton closures distinct (trivial closure-equivalence):",
          len({cl(frozenset({x})) for x in ground}) == len(ground))
    # 3-bit binary encoding of each value separates everything.
    phis = [(lambda b: (lambda x: bool((x >> b) & 1)))(b) for b in range(3)]
    print("phi_0,phi_1,phi_2 closure-stable:",
          all(is_closure_stable(cl, ground, p) for p in phis))
    for x in sorted(ground):
        print(f"  enc({x}) = {tuple(int(b) for b in encoding(phis, x))}")

    k = 1
    sep = predicate_family_separates(cl, ground, phis, k)
    inj = encoding_injective_on_large_closed(cl, ground, phis, k)
    print(f"\nk={k}: predicate family separates = {sep}")
    print(f"k={k}: encoding injective on large closed = {inj}")
    print(f"Theorem 6.1 (separation <=> injectivity) holds here: {sep == inj}")

    # Duality backward: collapse the 3 predicates to ONE vector-valued seed.
    seeds, f = duality_backward(phis)
    print("Theorem 7.1 backward: one-seed family separates =",
          seed_family_separates(cl, ground, seeds, f, k))


def demo_gf2() -> None:
    banner("Example 2: GF(2) span closure on 4 distinct vectors in (Z/2)^2")
    vectors = {
        0: (0, 0),  # zero vector
        1: (1, 0),
        2: (0, 1),
        3: (1, 1),
    }
    ground = frozenset(vectors)
    cl = gf2_span_closure(vectors)
    print("closure axioms hold:", check_closure_axioms(cl, ground))
    print("1 ~ 2 (different lines, not equivalent):", closure_equiv(cl, 1, 2))

    # A closure-COMPATIBLE seed family: each seed reads one coordinate of the
    # vector, so the output depends only on the vector (hence on the closure).
    seeds = [0, 1]
    def f(s: int, x: int) -> int:
        return vectors[x][s]
    print("seed family closure-compatible:",
          is_closure_compatible(cl, ground, seeds, f))

    k = 1
    print(f"k={k}: seed family separates =",
          seed_family_separates(cl, ground, seeds, f, k))

    # Duality forward: rebuild closure-stable predicates from the seed family.
    outputs = [0, 1]
    preds = duality_forward(seeds, outputs, f)
    print(f"Theorem 7.3 forward: built {len(preds)} indicator predicates "
          f"(= |Seed|*|Y| = {len(seeds) * len(outputs)})")
    print("  all closure-stable:",
          all(is_closure_stable(cl, ground, p) for p in preds))
    print("  predicate family separates:",
          predicate_family_separates(cl, ground, preds, k))

    # Necessity of respecting closure-equivalence: add a DUPLICATE vector.
    # Elements 1 and 4 then share a singleton closure, so NO closure-stable
    # predicate (and no closure-compatible seed) can ever separate them.
    vectors2 = dict(vectors); vectors2[4] = (1, 0)
    ground2 = frozenset(vectors2)
    cl2 = gf2_span_closure(vectors2)
    def f2(s: int, x: int) -> int:
        return vectors2[x][s]
    print("\nNecessity check (duplicate vector 4 == vector 1):")
    print("  1 ~ 4 closure-equivalent:", closure_equiv(cl2, 1, 4))
    # A naive bit-encoding DOES separate 1,4 -- but it is NOT closure-stable,
    # so it is an illegal probe in this framework:
    bad = [(lambda b: (lambda x: bool((x >> b) & 1)))(b) for b in range(3)]
    print("  bit-encoding closure-stable:",
          all(is_closure_stable(cl2, ground2, p) for p in bad),
          "(False: it illegally separates equivalent 1 and 4)")
    # The legal, closure-compatible seed family simply cannot tell 1 and 4 apart:
    print("  closure-compatible seed family separates closed sets:",
          seed_family_separates(cl2, ground2, seeds, f2, k),
          "(False: equivalence forbids separating 1 and 4)")


def demo_reconstruction() -> None:
    banner("Example 3: certified reconstruction from a separating matrix")
    ground = frozenset(range(4))
    blocks = [frozenset({i}) for i in range(4)]   # discrete: every set is closed
    cl = partition_closure(blocks)

    # A 2-row Boolean matrix whose columns are the 2-bit codes of 0,1,2,3.
    rows: List[Predicate] = [
        lambda x: bool((x >> 0) & 1),
        lambda x: bool((x >> 1) & 1),
    ]
    k = 1
    print("matrix separates closed sets:",
          matrix_separates_closed_sets(cl, ground, rows, k))

    seeds, f = reconstruct_from_matrix(rows)
    print("reconstructed seed family separates:",
          seed_family_separates(cl, ground, seeds, f, k))
    for x in sorted(ground):
        col = tuple(int(r(x)) for r in rows)
        print(f"  column({x}) = {col}  ==  f(*, {x}) = "
              f"{tuple(int(b) for b in f(0, x))}")


def main() -> None:
    demo_partition()
    demo_gf2()
    demo_reconstruction()
    banner("All demonstrations completed.")


if __name__ == "__main__":
    main()
