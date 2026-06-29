"""
demo.py — Numerical demonstrations for:

    "The Dimension of the Character Table of the Symmetric Group:
     A Formalized Partition-Conjugacy Correspondence"

This self-contained script illustrates the formally verified results:

  * card_conjClasses_eq_card_partition :
        |ConjClasses(S_n)| = |Partition(n)| = p(n)
  * card_conjClasses_S3 / S4 / S5 :
        p(3) = 3, p(4) = 5, p(5) = 7
  * partitionEquivConjClasses :
        the explicit partition <-> conjugacy-class bijection
        (realized via permOfPartition / permPartition)
  * sum_sign_eq_zero :
        sum over S_n of sign(g) = 0 for n >= 2

It also exercises two consistency checks predicted by the squareness of the
character table:

  * sum of conjugacy-class sizes  n!/z_lambda  equals  n!
  * sum of squared irreducible dimensions (hook-length formula) equals n!

Run:  python3 demo.py
"""

from __future__ import annotations

from math import factorial
from typing import Dict, List, Tuple

Partition = Tuple[int, ...]  # parts in weakly decreasing order, summing to n
Permutation = List[int]      # one-line notation: image of 0..n-1


# --------------------------------------------------------------------------- #
# 1. Partitions of n  (the index set of the character table of S_n)
# --------------------------------------------------------------------------- #
def partitions(n: int, max_part: int | None = None) -> List[Partition]:
    """All partitions of ``n`` as weakly-decreasing tuples of positive ints."""
    if max_part is None:
        max_part = n
    if n == 0:
        return [()]
    result: List[Partition] = []
    for k in range(min(n, max_part), 0, -1):
        for rest in partitions(n - k, k):
            result.append((k,) + rest)
    return result


def p(n: int) -> int:
    """The partition number p(n) = number of partitions of n (OEIS A000041)."""
    return len(partitions(n))


# --------------------------------------------------------------------------- #
# 2. The forward map  permOfPartition : Partition(n) -> S_n
#    Arrange {0,..,n-1} into consecutive blocks of the prescribed sizes and
#    turn each block into a cycle (size-1 blocks become fixed points).
# --------------------------------------------------------------------------- #
def perm_of_partition(part: Partition, n: int) -> Permutation:
    """Concrete permutation (one-line notation) realizing cycle type ``part``."""
    perm: List[int] = list(range(n))
    start = 0
    for block in part:
        # cycle on the block [start, start+block): i -> i+1, last -> start
        for i in range(block):
            perm[start + i] = start + (i + 1) % block
        start += block
    return perm


# --------------------------------------------------------------------------- #
# 3. The backward map  permPartition : S_n -> Partition(n)
#    Decompose into disjoint cycles by orbit tracing; record all cycle lengths
#    (including fixed points), giving a partition of n.
# --------------------------------------------------------------------------- #
def perm_partition(perm: Permutation) -> Partition:
    """Cycle-type partition (with fixed points) of a one-line permutation."""
    n = len(perm)
    seen = [False] * n
    lengths: List[int] = []
    for i in range(n):
        if seen[i]:
            continue
        length = 0
        j = i
        while not seen[j]:
            seen[j] = True
            j = perm[j]
            length += 1
        lengths.append(length)
    return tuple(sorted(lengths, reverse=True))


# --------------------------------------------------------------------------- #
# 4. Sign of a permutation: sign = (-1)^(n - number_of_cycles)
# --------------------------------------------------------------------------- #
def sign(perm: Permutation) -> int:
    """Signature of a permutation, +1 (even) or -1 (odd)."""
    n = len(perm)
    num_cycles = len(perm_partition(perm))
    return (-1) ** (n - num_cycles)


def all_permutations(n: int) -> List[Permutation]:
    """All n! permutations of {0,..,n-1} in one-line notation."""
    from itertools import permutations as iperm
    return [list(q) for q in iperm(range(n))]


def sum_of_signs(n: int) -> int:
    """sum_{g in S_n} sign(g);  equals 0 for n >= 2 (sum_sign_eq_zero)."""
    return sum(sign(g) for g in all_permutations(n))


# --------------------------------------------------------------------------- #
# 5. Centralizer order z_lambda and conjugacy-class size n!/z_lambda
# --------------------------------------------------------------------------- #
def centralizer_order(part: Partition) -> int:
    """z_lambda = prod_i i^{m_i} * m_i!  where m_i = multiplicity of part i."""
    mult: Dict[int, int] = {}
    for x in part:
        mult[x] = mult.get(x, 0) + 1
    z = 1
    for value, m in mult.items():
        z *= (value ** m) * factorial(m)
    return z


def class_size(part: Partition, n: int) -> int:
    """Size of the conjugacy class of cycle type ``part`` in S_n."""
    return factorial(n) // centralizer_order(part)


# --------------------------------------------------------------------------- #
# 6. Irreducible dimension f^lambda via the hook-length formula
#    f^lambda = n! / prod_{cells} hook(cell)
# --------------------------------------------------------------------------- #
def hook_length_dimension(part: Partition, n: int) -> int:
    """Number of standard Young tableaux of shape ``part`` (dim of irrep)."""
    rows = list(part)
    # conjugate (transpose) partition: column lengths
    if rows:
        max_col = rows[0]
        cols = [sum(1 for r in rows if r > c) for c in range(max_col)]
    else:
        cols = []
    prod_hooks = 1
    for i, row_len in enumerate(rows):
        for j in range(row_len):
            arm = row_len - j - 1          # cells to the right
            leg = cols[j] - i - 1          # cells below
            prod_hooks *= (arm + leg + 1)
    return factorial(n) // prod_hooks


# --------------------------------------------------------------------------- #
# Demonstration driver
# --------------------------------------------------------------------------- #
def demonstrate(n: int) -> None:
    parts = partitions(n)
    pn = len(parts)
    print(f"\n================  S_{n}  ================")
    print(f"  p({n}) = number of partitions of {n} = number of conjugacy "
          f"classes = number of rows of the character table = {pn}")
    print(f"  => character table of S_{n} is a {pn} x {pn} square")

    print(f"\n  {'partition':<18}{'perm (1-line)':<22}"
          f"{'round-trip':<14}{'class size':<12}{'dim f^λ':<8}")
    print("  " + "-" * 72)
    total_class = 0
    sum_sq_dim = 0
    for part in parts:
        g = perm_of_partition(part, n)
        back = perm_partition(g)            # bijection round-trip
        cs = class_size(part, n)
        dim = hook_length_dimension(part, n)
        total_class += cs
        sum_sq_dim += dim * dim
        ok = "OK" if back == part else "MISMATCH"
        print(f"  {str(part):<18}{str(g):<22}{ok:<14}{cs:<12}{dim:<8}")

    print("  " + "-" * 72)
    print(f"  sum of class sizes   = {total_class}  (should equal {n}! = {factorial(n)})")
    print(f"  sum of (dim)^2       = {sum_sq_dim}  (should equal {n}! = {factorial(n)})")
    if n >= 2:
        s = sum_of_signs(n) if n <= 7 else 0
        note = "" if n <= 7 else "  (skipped explicit enumeration; even by theory)"
        print(f"  sum of sign(g)       = {s}  (should equal 0 for n >= 2){note}")


def main() -> None:
    print("Partition numbers p(n) (OEIS A000041):")
    print("  n :  " + "  ".join(f"{i:>2}" for i in range(0, 11)))
    print("  p :  " + "  ".join(f"{p(i):>2}" for i in range(0, 11)))

    # The three formally verified concrete counts.
    assert p(3) == 3, "card_conjClasses_S3"
    assert p(4) == 5, "card_conjClasses_S4"
    assert p(5) == 7, "card_conjClasses_S5"
    print("\nVerified: p(3)=3, p(4)=5, p(5)=7  "
          "(card_conjClasses_S3 / S4 / S5)")

    for n in (3, 4, 5):
        demonstrate(n)

    # Global consistency checks across a wider range.
    print("\n================  consistency checks  ================")
    for n in range(1, 9):
        parts = partitions(n)
        total_class = sum(class_size(pt, n) for pt in parts)
        sum_sq = sum(hook_length_dimension(pt, n) ** 2 for pt in parts)
        assert total_class == factorial(n)
        assert sum_sq == factorial(n)
        print(f"  n={n}: #classes={len(parts):>2}  "
              f"sum class sizes={total_class:>6}  "
              f"sum dim^2={sum_sq:>6}  = {n}!  OK")

    for n in range(2, 8):
        assert sum_of_signs(n) == 0
    print("  sum_{g} sign(g) = 0 verified for n = 2..7  (sum_sign_eq_zero)")
    print("\nAll demonstrations passed.")


if __name__ == "__main__":
    main()
