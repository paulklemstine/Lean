"""Numerical demonstrations for *Stack-Sorting Depth*.

This self-contained script reimplements West's stack-sorting map exactly as in
the formalized development and reproduces every quantitative claim of the
accompanying article and research paper:

  * the one-pass map ``stack_sort`` (West's map) and its invariants,
  * the stack-sorting ``depth`` of a permutation,
  * the full depth distribution for small ``n`` (matching the Lean ``#eval``),
  * the Catalan law for one-pass-sortable permutations (n = 4, 5, 6),
  * the average depth ``A(n)`` and its scaled value ``A(n)/n``.

Run with:  ``python3 demo.py``
"""

from __future__ import annotations

from itertools import permutations
from math import comb
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# West's stack-sorting map (mirrors popLess / sortPass / stackSort)
# --------------------------------------------------------------------------- #
def pop_less(x: int, stack: List[int]) -> Tuple[List[int], List[int]]:
    """Pop every top element of ``stack`` (head = top) strictly smaller than ``x``.

    Returns ``(popped, remaining)`` with ``popped`` in pop order (top first) and
    ``remaining`` having a top element >= x (or empty). Mirrors ``popLess``.
    """
    popped: List[int] = []
    rest: List[int] = list(stack)
    while rest and rest[0] < x:
        popped.append(rest.pop(0))
    return popped, rest


def sort_pass(xs: List[int], stack: List[int]) -> List[int]:
    """One left-to-right pass against ``stack`` (head = top). Mirrors ``sortPass``."""
    out: List[int] = []
    s: List[int] = list(stack)
    for x in xs:
        popped, s = pop_less(x, s)
        out.extend(popped)
        s = [x] + s  # push x on top
    out.extend(s)  # final flush, top first
    return out


def stack_sort(l: List[int]) -> List[int]:
    """West's stack-sorting map: one full pass from an empty stack."""
    return sort_pass(l, [])


# --------------------------------------------------------------------------- #
# Depth
# --------------------------------------------------------------------------- #
def depth(l: List[int]) -> int:
    """Least number of ``stack_sort`` passes turning ``l`` into its ascending sort."""
    cur: List[int] = list(l)
    target: List[int] = sorted(l)
    steps: int = 0
    while cur != target:
        cur = stack_sort(cur)
        steps += 1
    return steps


# --------------------------------------------------------------------------- #
# Enumeration, distribution, Catalan law, average
# --------------------------------------------------------------------------- #
def perms_n(n: int) -> List[List[int]]:
    """All permutations of [1, 2, ..., n]."""
    return [list(p) for p in permutations(range(1, n + 1))]


def depth_distribution(n: int) -> List[Tuple[int, int]]:
    """List of (t, k): exactly k permutations of [1..n] have depth t."""
    ds: List[int] = [depth(p) for p in perms_n(n)]
    m: int = max(ds)
    return [(t, ds.count(t)) for t in range(m + 1)]


def stack_sortable_count(n: int) -> int:
    """Number of one-pass-sortable permutations of [1..n] (depth <= 1)."""
    return sum(1 for p in perms_n(n) if depth(p) <= 1)


def catalan(n: int) -> int:
    """The n-th Catalan number C_n = binom(2n, n) / (n + 1)."""
    return comb(2 * n, n) // (n + 1)


def average_depth(n: int) -> float:
    """A(n) = (1/n!) * sum over permutations of depth(w)."""
    ds: List[int] = [depth(p) for p in perms_n(n)]
    return sum(ds) / len(ds)


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 64)
    print("West's stack-sorting map: worked examples")
    print("=" * 64)
    for w in ([2, 3, 1], [3, 1, 2], [4, 3, 2, 1]):
        one = stack_sort(w)
        print(f"  w = {w}")
        print(f"    stack_sort(w)            = {one}")
        print(f"    stack_sort(stack_sort(w))= {stack_sort(one)}")
        print(f"    depth(w)                 = {depth(w)}")

    print()
    print("=" * 64)
    print("Invariants (sampled): pass is a permutation and preserves length")
    print("=" * 64)
    ok = all(
        sorted(stack_sort(p)) == sorted(p) and len(stack_sort(p)) == len(p)
        for p in perms_n(6)
    )
    print(f"  for all 720 permutations of [1..6]: invariants hold = {ok}")
    print(f"  sorted list [1,2,3,4] is a fixed point: "
          f"{stack_sort([1, 2, 3, 4]) == [1, 2, 3, 4]}, depth = {depth([1, 2, 3, 4])}")

    print()
    print("=" * 64)
    print("Depth distribution  (matches the formalized #eval output)")
    print("=" * 64)
    for n in range(1, 7):
        print(f"  n = {n}: {depth_distribution(n)}")

    print()
    print("=" * 64)
    print("Catalan law: one-pass-sortable count vs C_n")
    print("=" * 64)
    for n in range(4, 7):
        c = stack_sortable_count(n)
        print(f"  n = {n}: stackSortableCount = {c:>3}   C_{n} = {catalan(n):>3}   "
              f"equal = {c == catalan(n)}")

    print()
    print("=" * 64)
    print("Average depth A(n) and scaled value A(n)/n")
    print("=" * 64)
    prev: float | None = None
    for n in range(2, 9):
        a = average_depth(n)
        diff = "    --" if prev is None else f"{a - prev:6.4f}"
        print(f"  n = {n}: A(n) = {a:7.4f}   A(n)/n = {a / n:6.4f}   "
              f"A(n)-A(n-1) = {diff}")
        prev = a
    print()
    print("  Conjecture (open): A(n)/n -> 3/4 as n -> infinity.")


if __name__ == "__main__":
    main()


"""Visualizations for *Stack-Sorting Depth*.

Generates two figures:
  1. ``depth_distribution.png`` -- the depth distribution of permutations of
     [1..n] for n = 3..7 as grouped bars (the "spectrum of difficulty").
  2. ``average_depth.png`` -- the average depth A(n) and the scaled value
     A(n)/n, illustrating the conjectured linear growth A(n) ~ (3/4) n.

Run with:  ``python3 visualize.py``  (requires matplotlib).
"""

from __future__ import annotations

from itertools import permutations
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def stack_sort(l: List[int]) -> List[int]:
    """One pass of West's stack-sorting map (stack head = top)."""
    out: List[int] = []
    s: List[int] = []
    for x in l:
        while s and s[0] < x:
            out.append(s.pop(0))
        s = [x] + s
    out.extend(s)
    return out


def depth(l: List[int]) -> int:
    cur, target, steps = list(l), sorted(l), 0
    while cur != target:
        cur = stack_sort(cur)
        steps += 1
    return steps


def distribution(n: int) -> Dict[int, int]:
    counts: Dict[int, int] = {}
    for p in permutations(range(1, n + 1)):
        d = depth(list(p))
        counts[d] = counts.get(d, 0) + 1
    return counts


def average_depth(n: int) -> float:
    ds = [depth(list(p)) for p in permutations(range(1, n + 1))]
    return sum(ds) / len(ds)


def plot_distributions(ns: List[int], path: str = "depth_distribution.png") -> None:
    fig, ax = plt.subplots(figsize=(9, 5))
    max_d = max(max(distribution(n)) for n in ns)
    width = 0.8 / len(ns)
    for i, n in enumerate(ns):
        dist = distribution(n)
        xs = list(range(max_d + 1))
        ys = [dist.get(t, 0) for t in xs]
        offs = [t + (i - len(ns) / 2) * width + width / 2 for t in xs]
        ax.bar(offs, ys, width=width, label=f"n = {n}")
    ax.set_xlabel("stack-sorting depth t")
    ax.set_ylabel("number of permutations")
    ax.set_title("Depth distribution of permutations of [1..n]")
    ax.set_xticks(list(range(max_d + 1)))
    ax.legend()
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    print(f"wrote {path}")


def plot_average(ns: List[int], path: str = "average_depth.png") -> None:
    avgs: List[Tuple[int, float]] = [(n, average_depth(n)) for n in ns]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))
    ax1.plot([n for n, _ in avgs], [a for _, a in avgs], "o-", color="tab:blue")
    ax1.set_xlabel("n")
    ax1.set_ylabel("A(n)")
    ax1.set_title("Average stack-sorting depth A(n)")
    ax2.plot([n for n, _ in avgs], [a / n for n, a in avgs], "s-",
             color="tab:green", label="A(n)/n")
    ax2.axhline(0.75, ls="--", color="tab:red", label="conjectured limit 3/4")
    ax2.set_xlabel("n")
    ax2.set_ylabel("A(n)/n")
    ax2.set_ylim(0, 0.8)
    ax2.set_title("Scaled average A(n)/n")
    ax2.legend()
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    print(f"wrote {path}")


if __name__ == "__main__":
    plot_distributions([3, 4, 5, 6, 7])
    plot_average([2, 3, 4, 5, 6, 7, 8])
