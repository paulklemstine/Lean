"""Numerical demonstrations for
"Controlled Failure of Associativity: Thinness, Coherence, and a Catalan
Census of Rebracketing".

This self-contained script demonstrates, with concrete computations, the main
results of the paper:

  1. Bracketings (parenthesizations) of a product are binary trees; enumerating
     them for n+1 factors yields exactly the Catalan number C_n.
  2. The census obeys the Segner convolution recurrence
     C_{n+1} = sum_{i=0}^{n} C_i * C_{n-i}, cross-checked against the closed
     form C_n = binom(2n, n)/(n+1) and against direct enumeration.
  3. Tensoring is NOT associative on objects: (a*b)*c and a*(b*c) are distinct
     trees, but they flatten to the same word (they are "canonically
     isomorphic"). Two bracketings are isomorphic iff they flatten equally.
  4. Strictification: every bracketing has a unique right-nested normal form,
     and normal forms multiply by word concatenation (the free monoid).

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from math import comb
from typing import Iterator, List, Optional


# ---------------------------------------------------------------------------
# Parenthesization trees (objects of the parenthesization category)
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class PTree:
    """A binary tree = a fully-bracketed word.

    * leaf: label is a string, left = right = None.
    * node: label is None, left and right are subtrees (the product left*right).
    """
    label: Optional[str] = None
    left: Optional["PTree"] = None
    right: Optional["PTree"] = None

    @staticmethod
    def leaf(a: str) -> "PTree":
        return PTree(label=a, left=None, right=None)

    @staticmethod
    def node(left: "PTree", right: "PTree") -> "PTree":
        return PTree(label=None, left=left, right=right)

    @property
    def is_leaf(self) -> bool:
        return self.left is None and self.right is None

    def flatten(self) -> List[str]:
        """Underlying leaf-word, forgetting the bracketing."""
        if self.is_leaf:
            return [] if self.label is None else [self.label]
        assert self.left is not None and self.right is not None
        return self.left.flatten() + self.right.flatten()

    def bracketed(self) -> str:
        """Human-readable fully-parenthesized string."""
        if self.is_leaf:
            return self.label if self.label is not None else "1"
        assert self.left is not None and self.right is not None
        return f"({self.left.bracketed()}*{self.right.bracketed()})"


def tensor(s: PTree, t: PTree) -> PTree:
    """The tensor product on objects: s (x) t = node(s, t)."""
    return PTree.node(s, t)


def iso(s: PTree, t: PTree) -> bool:
    """Two bracketings are isomorphic iff they flatten to the same word."""
    return s.flatten() == t.flatten()


def normalize(s: PTree) -> PTree:
    """Right-nested normal form of a bracketing (its skeleton representative)."""
    return of_word(s.flatten())


def of_word(word: List[str]) -> PTree:
    """Canonical right-nested bracketing of a word (free-monoid element)."""
    if not word:
        return PTree.leaf("1")  # unit / empty product placeholder
    if len(word) == 1:
        return PTree.leaf(word[0])
    return PTree.node(PTree.leaf(word[0]), of_word(word[1:]))


# ---------------------------------------------------------------------------
# Enumeration of bracketings (the reassociation-groupoid census)
# ---------------------------------------------------------------------------
def enumerate_bracketings(factors: List[str]) -> Iterator[PTree]:
    """Yield every bracketing (parse tree) of the given ordered factors.

    Recursion mirrors the Segner split: choose the outermost bracket position,
    recurse on the left and right halves.
    """
    if len(factors) == 1:
        yield PTree.leaf(factors[0])
        return
    for i in range(1, len(factors)):
        for left in enumerate_bracketings(factors[:i]):
            for right in enumerate_bracketings(factors[i:]):
                yield PTree.node(left, right)


def count_bracketings(n_factors: int) -> int:
    """Number of bracketings of `n_factors` factors, by direct enumeration."""
    factors = [f"x{i}" for i in range(n_factors)]
    return sum(1 for _ in enumerate_bracketings(factors))


# ---------------------------------------------------------------------------
# Catalan numbers: closed form and Segner convolution
# ---------------------------------------------------------------------------
def catalan_closed(n: int) -> int:
    """C_n = binom(2n, n) / (n + 1)."""
    return comb(2 * n, n) // (n + 1)


def catalan_segner(n: int) -> int:
    """C_n via the convolution recurrence C_{m+1} = sum_i C_i C_{m-i}."""
    c: List[int] = [1]
    for m in range(n):
        c.append(sum(c[i] * c[m - i] for i in range(m + 1)))
    return c[n]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_census() -> None:
    print("=" * 68)
    print("1. Census of bracketings  =  Catalan numbers")
    print("=" * 68)
    print(f"{'factors':>8} | {'n':>3} | {'enumerated':>11} | "
          f"{'C_n closed':>11} | {'C_n Segner':>11}")
    print("-" * 60)
    for n_factors in range(1, 9):
        n = n_factors - 1
        enum = count_bracketings(n_factors)
        closed = catalan_closed(n)
        segner = catalan_segner(n)
        assert enum == closed == segner, "census mismatch!"
        print(f"{n_factors:>8} | {n:>3} | {enum:>11} | {closed:>11} | {segner:>11}")
    print("All three agree:  |Brk(n)| = C_n.\n")


def demo_segner_recurrence() -> None:
    print("=" * 68)
    print("2. Segner convolution:  C_{n+1} = sum_i C_i * C_{n-i}")
    print("=" * 68)
    c = [catalan_closed(k) for k in range(8)]
    for n in range(7):
        conv = sum(c[i] * c[n - i] for i in range(n + 1))
        assert conv == c[n + 1]
        terms = " + ".join(f"{c[i]}*{c[n - i]}" for i in range(n + 1))
        print(f"C_{n+1} = {terms} = {conv}")
    print()


def demo_nonassociativity() -> None:
    print("=" * 68)
    print("3. Associativity fails on objects, but holds up to isomorphism")
    print("=" * 68)
    a, b, c = PTree.leaf("a"), PTree.leaf("b"), PTree.leaf("c")
    left = tensor(tensor(a, b), c)   # (a*b)*c
    right = tensor(a, tensor(b, c))  # a*(b*c)
    print(f"(a*b)*c  as a tree:  {left.bracketed()}")
    print(f"a*(b*c)  as a tree:  {right.bracketed()}")
    print(f"Equal as objects?           {left == right}   (distinct trees)")
    print(f"Isomorphic (same word)?     {iso(left, right)}   "
          f"(both flatten to {left.flatten()})")
    print("=> The associator is a genuine, non-identity isomorphism.\n")


def demo_strictification() -> None:
    print("=" * 68)
    print("4. Strictification: unique normal form; skeleton = free monoid")
    print("=" * 68)
    factors = ["a", "b", "c", "d"]
    forms = list(enumerate_bracketings(factors))
    print(f"The {len(forms)} bracketings of {''.join(factors)} and their normal forms:")
    normals = set()
    for t in forms:
        nf = normalize(t)
        normals.add(nf.bracketed())
        print(f"   {t.bracketed():<22} -> {nf.bracketed()}")
    print(f"Distinct normal forms: {len(normals)}  (all collapse to one word).")

    # Normal forms multiply by concatenation (free monoid).
    w1, w2 = ["a", "b"], ["c", "d"]
    lhs = tensor(of_word(w1), of_word(w2))
    rhs = of_word(w1 + w2)
    print(f"\nofList({w1}) (x) ofList({w2}) flattens to {lhs.flatten()}")
    print(f"ofList({w1 + w2})           flattens to {rhs.flatten()}")
    print(f"Isomorphic (free-monoid multiplication)? {iso(lhs, rhs)}\n")


def main() -> None:
    demo_census()
    demo_segner_recurrence()
    demo_nonassociativity()
    demo_strictification()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
