"""
Numerical demonstrations for the refined correspondence between greedy
1-Tamari intervals (graded by lower-endpoint valley count) and rooted
bipartite planar maps (graded by black-vertex count).

The demonstrations here focus on the fully self-contained, elementary
"endpoint layer" of the correspondence:

  * generation of Dyck paths,
  * the valley and peak statistics,
  * the peak-valley alternation identity  pk(x) = val(x) + 1,
  * the Narayana refinement of the valley statistic, and
  * the Catalan row-sum check.

These are the identities that pin down the marginal distribution of the
valley statistic on lower endpoints, which the main theorem reweights (by
an interval multiplicity) into the bipartite black-vertex distribution.

Run:  python demo.py
"""

from __future__ import annotations

from math import comb
from typing import Dict, Iterator, List, Tuple


# ---------------------------------------------------------------------------
# Dyck paths
# ---------------------------------------------------------------------------

def dyck_paths(n: int) -> Iterator[Tuple[int, ...]]:
    """Yield every Dyck path of semilength ``n`` as a tuple over {+1, -1}.

    A Dyck path has ``n`` up-steps (+1) and ``n`` down-steps (-1), and every
    prefix sum is nonnegative.  Paths are produced by recursive prefix
    extension, maintaining the current height and remaining step budgets.
    """
    path: List[int] = []

    def extend(height: int, ups_left: int, downs_left: int) -> Iterator[Tuple[int, ...]]:
        if ups_left == 0 and downs_left == 0:
            yield tuple(path)
            return
        if ups_left > 0:
            path.append(1)
            yield from extend(height + 1, ups_left - 1, downs_left)
            path.pop()
        if downs_left > 0 and height > 0:
            path.append(-1)
            yield from extend(height - 1, ups_left, downs_left - 1)
            path.pop()

    yield from extend(0, n, n)


def valleys(path: Tuple[int, ...]) -> int:
    """Number of valleys (occurrences of a down-step followed by an up-step)."""
    return sum(1 for a, b in zip(path, path[1:]) if a == -1 and b == 1)


def peaks(path: Tuple[int, ...]) -> int:
    """Number of peaks (occurrences of an up-step followed by a down-step)."""
    return sum(1 for a, b in zip(path, path[1:]) if a == 1 and b == -1)


# ---------------------------------------------------------------------------
# Classical closed forms
# ---------------------------------------------------------------------------

def catalan(n: int) -> int:
    """The n-th Catalan number  C_n = binom(2n, n) / (n + 1)."""
    return comb(2 * n, n) // (n + 1)


def narayana(n: int, k: int) -> int:
    """The Narayana number  N(n, k) = binom(n, k) * binom(n, k-1) / n."""
    if n == 0:
        return 1 if k == 0 else 0
    if k < 1 or k > n:
        return 0
    return comb(n, k) * comb(n, k - 1) // n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def valley_histogram(n: int) -> Dict[int, int]:
    """Distribution of Dyck paths of semilength ``n`` by valley count."""
    hist: Dict[int, int] = {}
    for path in dyck_paths(n):
        v = valleys(path)
        hist[v] = hist.get(v, 0) + 1
    return hist


def demo_peak_valley_alternation(max_n: int = 7) -> None:
    print("=" * 68)
    print("Peak-valley alternation:  pk(x) = val(x) + 1  for every Dyck path")
    print("=" * 68)
    ok = True
    for n in range(1, max_n + 1):
        bad = [p for p in dyck_paths(n) if peaks(p) != valleys(p) + 1]
        status = "OK" if not bad else f"FAILED ({len(bad)} counterexamples)"
        ok = ok and not bad
        print(f"  n = {n}:  checked {catalan(n):>4} paths ... {status}")
    print(f"  => identity holds up to n = {max_n}: {ok}")
    print()


def demo_narayana_refinement(max_n: int = 7) -> None:
    print("=" * 68)
    print("Valley distribution of lower endpoints matches Narayana N(n, k+1)")
    print("=" * 68)
    all_ok = True
    for n in range(1, max_n + 1):
        hist = valley_histogram(n)
        row_ok = True
        for k in range(0, n):
            observed = hist.get(k, 0)
            predicted = narayana(n, k + 1)
            if observed != predicted:
                row_ok = False
        counts = " ".join(f"{hist.get(k, 0):>4}" for k in range(0, n))
        predicted_row = " ".join(f"{narayana(n, k + 1):>4}" for k in range(0, n))
        total = sum(hist.values())
        cat = catalan(n)
        row_ok = row_ok and (total == cat)
        all_ok = all_ok and row_ok
        print(f"  n = {n}")
        print(f"     observed by valleys : {counts}")
        print(f"     Narayana N(n, k+1)  : {predicted_row}")
        print(f"     row sum = {total}   Catalan C_{n} = {cat}   match: {row_ok}")
    print(f"  => endpoint layer matches Narayana up to n = {max_n}: {all_ok}")
    print()


def demo_catalan_rowsums(max_n: int = 9) -> None:
    print("=" * 68)
    print("Catalan row sums:  sum_k N(n, k) = C_n")
    print("=" * 68)
    for n in range(1, max_n + 1):
        s = sum(narayana(n, k) for k in range(1, n + 1))
        print(f"  n = {n}:  sum N(n,k) = {s:>6}   C_{n} = {catalan(n):>6}   "
              f"match: {s == catalan(n)}")
    print()


def demo_sample_paths(n: int = 3) -> None:
    print("=" * 68)
    print(f"All Dyck paths of semilength {n} with their statistics")
    print("=" * 68)
    for path in dyck_paths(n):
        word = "".join("U" if s == 1 else "D" for s in path)
        print(f"  {word}   valleys = {valleys(path)}   peaks = {peaks(path)}")
    print()


def main() -> None:
    demo_sample_paths(3)
    demo_peak_valley_alternation(7)
    demo_narayana_refinement(7)
    demo_catalan_rowsums(9)


if __name__ == "__main__":
    main()
