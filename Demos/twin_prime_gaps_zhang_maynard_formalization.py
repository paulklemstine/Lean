"""
Numerical demonstrations for:

    The Unique Excluded Minor for Z/n-Gainable Parallel Classes

A *gain labelling* of a parallel class of k edges over the cyclic group Z/n
assigns a residue g(i) in {0,...,n-1} to each edge i. A two-edge loop ("digon")
out edge i and back edge j has gain g(i) - g(j) (mod n) and is *balanced* iff
this is 0, i.e. iff g(i) == g(j).

Main facts demonstrated:

  * Parallel-class threshold:  kK2 is Z/n-gainable  <=>  k <= n.
  * Pigeonhole obstruction:    (n+1)K2 is NEVER Z/n-gainable.
  * Excluded-minor / card criterion for a parallel class with balance classes:
        digon(s) is Z/n-gainable  <=>  #balance-classes <= n.
  * Divisibility law:          m | n  =>  every Z/m-gainable graph is Z/n-gainable.

Self-contained; standard library only.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Dict, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core checks
# ---------------------------------------------------------------------------

def digon_gain(g: Sequence[int], i: int, j: int, n: int) -> int:
    """Gain of the digon out edge i and back edge j, in Z/n."""
    return (g[i] - g[j]) % n


def all_digons_unbalanced(g: Sequence[int], n: int) -> bool:
    """True iff every two-edge loop of a parallel class is unbalanced.

    Equivalent to: the labels g are pairwise distinct mod n.
    """
    k = len(g)
    return all(
        digon_gain(g, i, j, n) != 0
        for i in range(k)
        for j in range(k)
        if i != j
    )


def is_parallel_class_gainable(k: int, n: int) -> Tuple[bool, Optional[List[int]]]:
    """Decide whether kK2 is Z/n-gainable; return a witness labelling if so.

    By the threshold theorem this holds iff k <= n, witnessed by g(i) = i.
    We also exhibit a brute-force search for small cases to *verify* the theorem.
    """
    if k <= n:
        return True, [i % n for i in range(k)]
    return False, None


def brute_force_parallel_class_gainable(k: int, n: int) -> bool:
    """Exhaustively search all n**k labellings for one with all digons unbalanced.

    Returns True iff some labelling works. Used to independently confirm the
    threshold theorem for small (k, n).
    """
    for g in product(range(n), repeat=k):
        if all_digons_unbalanced(g, n):
            return True
    return False


# ---------------------------------------------------------------------------
# Balance classes (union-find) and the card / excluded-minor criterion
# ---------------------------------------------------------------------------

class UnionFind:
    """Disjoint-set structure with path compression and union by size."""

    def __init__(self, n: int) -> None:
        self.parent: List[int] = list(range(n))
        self.size: List[int] = [1] * n

    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, a: int, b: int) -> None:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return
        if self.size[ra] < self.size[rb]:
            ra, rb = rb, ra
        self.parent[rb] = ra
        self.size[ra] += self.size[rb]

    def num_classes(self) -> int:
        return sum(1 for x in range(len(self.parent)) if self.find(x) == x)


def decide_digon_gainable(
    num_edges: int, balanced_pairs: Sequence[Tuple[int, int]], n: int
) -> Tuple[bool, Optional[Dict[int, int]]]:
    """Decide gainability of a parallel class with a prescribed balance relation.

    `balanced_pairs` lists pairs of edges declared balanced (their symmetric,
    reflexive, transitive closure is the balance equivalence). Returns
    (gainable, labelling) where the labelling, when present, is constant on
    classes and injective across classes (so it realises exactly the prescribed
    balances). By the card criterion gainability holds iff #classes <= n.
    """
    uf = UnionFind(num_edges)
    for a, b in balanced_pairs:
        uf.union(a, b)
    classes = uf.num_classes()
    if classes > n:
        return False, None
    # Assign each class root a distinct residue.
    roots = sorted({uf.find(e) for e in range(num_edges)})
    label_of_root = {r: (t % n) for t, r in enumerate(roots)}
    g = {e: label_of_root[uf.find(e)] for e in range(num_edges)}
    return True, g


# ---------------------------------------------------------------------------
# Divisibility embedding Z/m -> Z/n
# ---------------------------------------------------------------------------

def cyclic_embedding(m: int, n: int) -> Dict[int, int]:
    """Injective additive homomorphism Z/m -> Z/n when m | n (j -> j*(n//m))."""
    assert n % m == 0, "embedding requires m | n"
    step = n // m
    return {j: (j * step) % n for j in range(m)}


def embedding_is_injective_homomorphism(m: int, n: int) -> bool:
    f = cyclic_embedding(m, n)
    injective = len(set(f.values())) == m
    additive = all(
        f[(a + b) % m] == (f[a] + f[b]) % n for a in range(m) for b in range(m)
    )
    return injective and additive


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_threshold() -> None:
    print("=" * 68)
    print("Parallel-class threshold:  kK2 is Z/n-gainable  <=>  k <= n")
    print("=" * 68)
    for n in range(1, 5):
        print(f"\nClock Z/{n}:")
        for k in range(1, n + 3):
            predicted = k <= n
            verified = brute_force_parallel_class_gainable(k, n)
            ok, witness = is_parallel_class_gainable(k, n)
            tag = "GAINABLE" if predicted else "obstruction (n+1)K2+" if k == n + 1 else "not gainable"
            mark = "OK" if predicted == verified == ok else "MISMATCH!"
            extra = f"  witness g={witness}" if witness is not None else ""
            print(f"  k={k:2d}: predicted={predicted!s:5}  brute={verified!s:5}  [{mark}] {tag}{extra}")


def demo_pigeonhole() -> None:
    print("\n" + "=" * 68)
    print("Pigeonhole obstruction:  (n+1)K2 is never Z/n-gainable")
    print("=" * 68)
    for n in range(1, 6):
        k = n + 1
        verified = brute_force_parallel_class_gainable(k, n)
        print(f"  n={n}: searched all {n}^{k} = {n**k} labellings of (n+1)K2"
              f" -> gainable? {verified}")


def demo_balance_classes() -> None:
    print("\n" + "=" * 68)
    print("Excluded-minor / card criterion for a balance relation")
    print("=" * 68)
    # 6 parallel edges grouped into 3 balance classes: {0,1},{2,3},{4,5}.
    pairs = [(0, 1), (2, 3), (4, 5)]
    edges = 6
    for n in (2, 3, 4):
        ok, g = decide_digon_gainable(edges, pairs, n)
        print(f"  6 edges, 3 balance classes, clock Z/{n}: gainable? {ok}"
              + (f"  labelling={g}" if g else "  ((n+1)K2 minor present)"))


def demo_divisibility() -> None:
    print("\n" + "=" * 68)
    print("Divisibility law:  m | n  =>  Gainable_m  implies  Gainable_n")
    print("=" * 68)
    for m, n in [(2, 6), (3, 12), (4, 8), (5, 10)]:
        ok = embedding_is_injective_homomorphism(m, n)
        f = cyclic_embedding(m, n)
        print(f"  Z/{m} -> Z/{n}:  injective additive hom? {ok}   map(1)={f[1]}"
              f"  (order of generator image = {m})")


if __name__ == "__main__":
    demo_threshold()
    demo_pigeonhole()
    demo_balance_classes()
    demo_divisibility()
    print("\nAll demonstrations completed.")
