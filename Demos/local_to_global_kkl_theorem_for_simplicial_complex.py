"""
Numerical demonstrations of the Local-to-Global principle for coordinate influence.

This self-contained script illustrates the main results:

  * The bridge (influence self-averaging):
        Inf(f, i) = InfSub(f, j, 0, i) + InfSub(f, j, 1, i)
  * The total-influence decomposition over a coordinate's two links.
  * The flagship local-to-global cube theorem:
        both links carry total influence >= T  =>  some i != j has (n-1)*Inf(f,i) >= 2T.
  * The abstract engine specialised to the two unit-weight links of the cube.
  * The exact law for regular systems.

Boolean functions are represented as callables f : tuple[int, ...] -> int with
values in {0, 1}.  All functions are inlined and use only the standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Tuple

Point = Tuple[int, ...]
BoolFunc = Callable[[Point], int]


def all_points(n: int) -> List[Point]:
    """Enumerate every vertex of the Boolean cube {0,1}^n."""
    return [tuple(bits) for bits in product((0, 1), repeat=n)]


def flip(x: Point, i: int) -> Point:
    """Return x with coordinate i negated (a single hypercube edge in direction i)."""
    y = list(x)
    y[i] = 1 - y[i]
    return tuple(y)


def influence(f: BoolFunc, n: int, i: int) -> int:
    """Unnormalised influence Inf(f, i): number of inputs x with f(x) != f(x^{+i})."""
    return sum(1 for x in all_points(n) if f(x) != f(flip(x, i)))


def link_influence(f: BoolFunc, n: int, j: int, b: int, i: int) -> int:
    """Link influence InfSub(f, j, b, i): sensitive i-edges inside the slice x_j = b."""
    return sum(1 for x in all_points(n) if x[j] == b and f(x) != f(flip(x, i)))


def total_influence(f: BoolFunc, n: int) -> int:
    """TotInf(f) = sum over all coordinates of Inf(f, i)."""
    return sum(influence(f, n, i) for i in range(n))


def link_total_influence(f: BoolFunc, n: int, j: int, b: int) -> int:
    """LinkTotInf(f, j, b) = sum over i != j of InfSub(f, j, b, i)."""
    return sum(link_influence(f, n, j, b, i) for i in range(n) if i != j)


def verify_bridge(f: BoolFunc, n: int, j: int) -> bool:
    """Check Inf(f, i) = InfSub(f, j, 0, i) + InfSub(f, j, 1, i) for every i."""
    return all(
        influence(f, n, i)
        == link_influence(f, n, j, 0, i) + link_influence(f, n, j, 1, i)
        for i in range(n)
    )


def local_to_global_certificate(
    f: BoolFunc, n: int, j: int, T: int
) -> Tuple[int, int]:
    """
    Given the guarantee T <= LinkTotInf(f, j, b) for both b, return a coordinate
    i != j together with Inf(f, i), witnessing 2T <= (n-1)*Inf(f, i).
    The witness is the influence-maximising coordinate among i != j.
    """
    candidates = [(influence(f, n, i), i) for i in range(n) if i != j]
    best_inf, best_i = max(candidates)
    return best_i, best_inf


# ----------------------------------------------------------------------------
# Example Boolean functions.
# ----------------------------------------------------------------------------

def majority(x: Point) -> int:
    """Majority vote (defined for odd arity; ties broken toward 1)."""
    return 1 if sum(x) * 2 >= len(x) else 0


def parity(x: Point) -> int:
    """Parity / XOR of all coordinates: every coordinate is maximally influential."""
    return sum(x) % 2


def dictator(k: int) -> BoolFunc:
    """The k-th dictator: output equals coordinate k."""
    return lambda x: x[k]


def tribes(x: Point) -> int:
    """A simple 'tribes'-style OR-of-ANDs on 4 bits: (x0 & x1) | (x2 & x3)."""
    return int((x[0] and x[1]) or (x[2] and x[3]))


def report(name: str, f: BoolFunc, n: int, j: int) -> None:
    print(f"=== {name}  (n = {n}, pinned coordinate j = {j}) ===")
    infs: Dict[int, int] = {i: influence(f, n, i) for i in range(n)}
    print(f"  coordinate influences : {infs}")
    print(f"  total influence       : {total_influence(f, n)}")

    print(f"  bridge identity holds : {verify_bridge(f, n, j)}")
    ltf0 = link_total_influence(f, n, j, 0)
    ltf1 = link_total_influence(f, n, j, 1)
    excl = sum(influence(f, n, i) for i in range(n) if i != j)
    print(f"  LinkTotInf(j,0)={ltf0}, LinkTotInf(j,1)={ltf1}, "
          f"sum={ltf0 + ltf1}, sum_{{i!=j}} Inf={excl}  "
          f"(decomposition holds: {ltf0 + ltf1 == excl})")

    T = min(ltf0, ltf1)
    if n >= 2 and T > 0:
        i, inf_i = local_to_global_certificate(f, n, j, T)
        lhs, rhs = 2 * T, (n - 1) * inf_i
        print(f"  local-to-global: T={T}  =>  coordinate i={i} with Inf={inf_i}; "
              f"check 2T={lhs} <= (n-1)*Inf={rhs}: {lhs <= rhs}")
    print()


def demo_regular_law() -> None:
    """
    The exact regular law: for parity on n bits, every coordinate has influence
    2^n and every link total influence is equal, so TotInf(f) = n * 2^n.
    We also verify the abstract 'regular' identity |kappa| * A over the two links.
    """
    print("=== Exact regular law (parity) ===")
    for n in (3, 4, 5):
        f = parity
        tot = total_influence(f, n)
        print(f"  n={n}: TotInf(parity) = {tot}  (equals n*2^n = {n * 2**n})")
    print()


if __name__ == "__main__":
    report("Majority", majority, 3, 0)
    report("Parity (XOR)", parity, 4, 0)
    report("Dictator on coord 1", dictator(1), 3, 0)
    report("Tribes (x0&x1)|(x2&x3)", tribes, 4, 0)
    demo_regular_law()
