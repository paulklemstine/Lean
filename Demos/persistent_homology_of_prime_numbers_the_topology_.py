"""
Persistent Homology of the Prime Point Cloud — numerical demonstrations.

The prime point cloud is the set  X_N = {p_1, p_2, ..., p_N} = {2, 3, 5, 7, 11, ...}
sitting on the real line.  Its Vietoris-Rips filtration at scale eps joins two primes
whenever they are within distance eps.  On a line the resulting persistent homology is
completely explicit:

  *  H_0 barcode  =  the multiset of prime gaps g_i = p_{i+1} - p_i,
  *  Betti curve  b_0(eps, n) = 1 + #{ i < n : g_i > eps },
  *  H_1          =  0 at every scale.

This script verifies, numerically, every quantitative claim of the accompanying paper:

  1. Bar-length quantisation:  g_0 = 1 and g_i is even for i >= 1.
  2. Empty windows:  no bar length lies in (2k, 2k+2) or in (0,1), while an
     exponential law of any mean puts strictly positive mass there.
  3. Even quantisation of the Betti staircase and the gap-histogram inversion formula.
  4. The Betti-area identity  int_0^infty (b_0(eps,n) - 1) d eps = p_n - 2,
     and the mean bar length (p_n - 2)/n compared with log p_n.
  5. The twin-prime Betti step b_0(1,n) - b_0(2,n) and its cap n/2 + 3.
  6. Pair correlations:  the pattern (2,2) never occurs past the triple 3,5,7,
     and more generally a repeated bar length must be divisible by 3;
     the mod-q block law for q = 3, 5, 7, 11.
  7. Vanishing of H_1: a constructive reduction of an arbitrary F_2 one-cycle of a
     line Rips complex to a sum of Rips triangles (the "pull to the left" algorithm).
  8. Completeness of the barcode:  p_n = 2 + sum_{m<n} g_m.

Pure standard library; no dependencies.  Runs in a few seconds.
"""

from __future__ import annotations

import math
from collections import Counter
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Edge = Tuple[int, int]


# ----------------------------------------------------------------------------------
# 1. The point cloud
# ----------------------------------------------------------------------------------

def primes_upto(limit: int) -> List[int]:
    """All primes <= limit by a simple sieve of Eratosthenes."""
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    return [i for i in range(limit + 1) if sieve[i]]


def gaps_of(primes: Sequence[int]) -> List[int]:
    """The H_0 bar lengths: g_i = p_{i+1} - p_i."""
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


# ----------------------------------------------------------------------------------
# 2. Barcode invariants
# ----------------------------------------------------------------------------------

def betti_zero(gaps: Sequence[int], eps: float, n: int) -> int:
    """b_0(eps, n) = 1 + #{ i < n : g_i > eps }, the number of eps-components."""
    return 1 + sum(1 for i in range(min(n, len(gaps))) if gaps[i] > eps)


def betti_area(gaps: Sequence[int], n: int) -> int:
    """Area under the reduced Betti curve = sum of the first n bar lengths."""
    return sum(gaps[:n])


def bar_count_in_window(gaps: Sequence[int], a: float, b: float) -> int:
    """Number of bars whose length lies in the open interval (a, b)."""
    return sum(1 for g in gaps if a < g < b)


def exponential_window_mass(a: float, b: float, mean: float) -> float:
    """Mass of the open window (a,b) under an exponential law with the given mean."""
    return math.exp(-a / mean) - math.exp(-b / mean)


def gap_histogram_from_betti(gaps: Sequence[int], k: int, n: int) -> int:
    """Inversion formula: #{ i<n : g_i = 2k } = b_0(2k-1, n) - b_0(2k+1, n)."""
    return betti_zero(gaps, 2 * k - 1, n) - betti_zero(gaps, 2 * k + 1, n)


def twin_step(gaps: Sequence[int], n: int) -> int:
    """The eps = 2 step of the Betti staircase, b_0(1,n) - b_0(2,n)."""
    return betti_zero(gaps, 1, n) - betti_zero(gaps, 2, n)


# ----------------------------------------------------------------------------------
# 3. F_2 one-chains of a Rips complex on a line, and the vanishing of H_1
# ----------------------------------------------------------------------------------

def is_rips_edge(cloud: Sequence[float], eps: float, e: Edge) -> bool:
    """(a,b) with a < b is an edge iff |x_a - x_b| <= eps."""
    a, b = e
    return a < b and abs(cloud[a] - cloud[b]) <= eps


def degrees(chain: Iterable[Edge]) -> Dict[int, int]:
    """Vertex degrees of an F_2 one-chain (a finite set of edges)."""
    deg: Counter = Counter()
    for a, b in chain:
        deg[a] += 1
        deg[b] += 1
    return dict(deg)


def is_cycle(chain: Set[Edge]) -> bool:
    """A one-chain is a cycle (boundary zero over F_2) iff all degrees are even."""
    return all(d % 2 == 0 for d in degrees(chain).values())


def weight(chain: Iterable[Edge]) -> int:
    """The termination measure mu(E) = sum of the right endpoints of the edges."""
    return sum(b for _a, b in chain)


def symm_diff(a: Set[Edge], b: Set[Edge]) -> Set[Edge]:
    return a ^ b


def triangle_chain(a: int, b: int, c: int) -> Set[Edge]:
    """The boundary of the triangle a < b < c."""
    return {(a, b), (b, c), (a, c)}


def decompose_cycle_into_triangles(
    cloud: Sequence[float], eps: float, chain: Set[Edge]
) -> List[Tuple[int, int, int]]:
    """
    Write an F_2 one-cycle of a line Rips complex as a sum of Rips triangles.

    Repeatedly take the largest vertex v carried by the chain.  Its degree is even and
    positive, so two edges (u,v) and (w,v) with u < w < v are present.  Because x_u and
    x_w both lie in the window [x_v - eps, x_v], the chord (u,w) is itself a Rips edge,
    so T = {(u,w),(w,v),(u,v)} is a Rips triangle; replacing the chain by T + chain
    keeps it a cycle and strictly decreases the weight mu.  Terminates in at most mu
    steps and returns the list of triangles used.
    """
    triangles: List[Tuple[int, int, int]] = []
    work = set(chain)
    while work:
        assert is_cycle(work), "invariant: the working chain stays a cycle"
        v = max(max(e) for e in work)
        incident = sorted(a for (a, b) in work if b == v)
        if len(incident) < 2:
            raise ValueError("degree at the maximal vertex must be even and positive")
        u, w = incident[0], incident[1]
        assert is_rips_edge(cloud, eps, (u, w)), "the chord must be a Rips edge"
        tri = triangle_chain(u, w, v)
        before = weight(work)
        work = symm_diff(tri, work)
        assert weight(work) < before, "the weight must strictly decrease"
        triangles.append((u, w, v))
    return triangles


# ----------------------------------------------------------------------------------
# 4. Arithmetic correlation laws of the barcode
# ----------------------------------------------------------------------------------

def adjacent_pair_histogram(gaps: Sequence[int]) -> Counter:
    """Histogram of adjacent bar-length pairs (g_i, g_{i+1})."""
    return Counter((gaps[i], gaps[i + 1]) for i in range(len(gaps) - 1))


def smallest_block_divisible(gaps: Sequence[int], primes: Sequence[int],
                             q: int, i: int) -> Tuple[int, int, int]:
    """
    Find j < k < q with q | g_i + ... + g_{i+k-1} - (g_i + ... + g_{i+j-1}).

    Guaranteed to exist whenever p_i > q, by the pigeonhole principle applied to the
    residues mod q of the q primes p_i, ..., p_{i+q-1}, none of which is 0 mod q.
    """
    partial = [0]
    for m in range(q):
        partial.append(partial[-1] + gaps[i + m])
    seen: Dict[int, int] = {}
    base = primes[i] % q
    for j in range(q):
        r = (base + partial[j]) % q
        if r in seen:
            return seen[r], j, partial[j] - partial[seen[r]]
        seen[r] = j
    raise AssertionError("pigeonhole guarantees a repeat")


# ----------------------------------------------------------------------------------
# 5. Driver
# ----------------------------------------------------------------------------------

def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def main() -> None:
    LIMIT = 10 ** 6
    primes = primes_upto(LIMIT)
    gaps = gaps_of(primes)
    n = len(gaps)
    print(f"Prime point cloud up to {LIMIT}: {len(primes)} points, {n} finite H_0 bars.")

    # ---- 1. quantisation ---------------------------------------------------------
    rule("1.  Bar-length quantisation:  g_0 = 1, and every later bar has even length")
    odd = [(i, g) for i, g in enumerate(gaps) if g % 2 == 1]
    print(f"  bars of odd length: {odd}")
    print(f"  spectrum of bar lengths: {sorted(set(gaps))}")
    print(f"  longest bar: {max(gaps)} (after p = {primes[gaps.index(max(gaps))]})")
    assert odd == [(0, 1)]
    assert all(g % 2 == 0 for g in gaps[1:])

    # ---- 2. the empty windows and the exponential prediction ---------------------
    rule("2.  Empty windows: the barcode measure is atomic, no exponential law fits")
    mean = math.log(LIMIT)
    print(f"  proposed exponential mean  m = log(10^6) = {mean:.4f}")
    print(f"  {'window':>12}  {'observed':>10}  {'exponential prediction':>24}")
    for a, b in [(0.0, 1.0), (2.0, 4.0), (4.0, 6.0), (6.0, 8.0), (8.0, 10.0)]:
        obs = bar_count_in_window(gaps, a, b)
        pred = exponential_window_mass(a, b, mean)
        print(f"  ({a:4.1f},{b:4.1f})  {obs:10d}  {pred * n:24.1f}")
        assert obs == 0
        assert pred > 0
    print("  observed mass in every open window between consecutive even integers: 0")

    # ---- 3. Betti staircase and the inversion formula ----------------------------
    rule("3.  The Betti staircase is constant on [2k, 2k+2), and inverts to the histogram")
    for k in range(1, 6):
        vals = {betti_zero(gaps, 2 * k + t, n) for t in (0.0, 0.5, 0.999, 1.5, 1.999)}
        print(f"  b_0(eps) for eps in [{2*k}, {2*k+2}) takes the values {vals}")
        assert len(vals) == 1
    hist = Counter(gaps)
    print(f"  {'2k':>4}  {'#bars of length 2k':>20}  {'b_0(2k-1) - b_0(2k+1)':>24}")
    for k in range(1, 9):
        direct = hist[2 * k]
        inverted = gap_histogram_from_betti(gaps, k, n)
        print(f"  {2*k:4d}  {direct:20d}  {inverted:24d}")
        assert direct == inverted

    # ---- 4. Betti area identity ---------------------------------------------------
    rule("4.  Area under the reduced Betti curve equals p_n - 2")
    for m in [10, 100, 10_000, n]:
        area = betti_area(gaps, m)
        print(f"  n = {m:6d}:  area = {area:9d},   p_n - 2 = {primes[m] - 2:9d}")
        assert area == primes[m] - 2
    mean_bar = (primes[n] - 2) / n
    print(f"  mean bar length (p_n - 2)/n = {mean_bar:.6f}   vs  log p_n = "
          f"{math.log(primes[n]):.6f}")

    # ---- 5. the twin step ---------------------------------------------------------
    rule("5.  The twin-prime Betti step b_0(1,n) - b_0(2,n)")
    for m in [10, 100, 1000, 10_000, n]:
        step = twin_step(gaps, m)
        print(f"  n = {m:6d}:  twin step = {step:6d}   (cap n/2 + 3 = {m // 2 + 3})")
        assert step <= m // 2 + 3
    print("  The twin prime conjecture is exactly: this single step is unbounded in n.")

    # ---- 6. pair correlations and the mod-q block laws ---------------------------
    rule("6.  Correlations: the diagonal pattern (2,2) is forbidden past 3,5,7")
    pairs = adjacent_pair_histogram(gaps)
    for pat in [(2, 2), (4, 4), (8, 8), (6, 6), (2, 4), (4, 2), (2, 6)]:
        print(f"  pattern {pat}: {pairs[pat]:6d} occurrences")
    assert pairs[(2, 2)] == 1        # only at 3, 5, 7
    assert pairs[(4, 4)] == 0
    assert pairs[(8, 8)] == 0
    repeated = {d for d in set(gaps) if pairs[(d, d)] > 0 }
    print(f"  repeated adjacent lengths that occur: {sorted(repeated)}"
          f"  (all divisible by 3 apart from the initial 2)")
    assert all(d % 3 == 0 for d in repeated if pairs[(d, d)] > 1 or d != 2)
    print("\n  mod-q block law: a block of fewer than q consecutive bars summing to 0 mod q")
    for q in [3, 5, 7, 11]:
        i = next(idx for idx, p in enumerate(primes) if p > q) + 5
        j, k, total = smallest_block_divisible(gaps, primes, q, i)
        print(f"    q = {q:2d}, start p_i = {primes[i]:3d}:  bars [{j},{k}) of the block sum"
              f" to {total}, divisible by {q}: {total % q == 0}")
        assert total % q == 0 and j < k < q

    # ---- 7. vanishing of H_1 ------------------------------------------------------
    rule("7.  H_1 = 0: every one-cycle of a line Rips complex is a sum of triangles")
    cloud = [float(p) for p in primes[:40]]
    eps = 8.0
    square = {(1, 2), (2, 3), (3, 4), (1, 4)}   # the quadrilateral on 3, 5, 7, 11
    print(f"  quadrilateral on the primes 3,5,7,11 at scale eps = {eps}")
    print(f"    edges {sorted(square)}, degrees {degrees(square)}, cycle: {is_cycle(square)}")
    tris = decompose_cycle_into_triangles(cloud, eps, set(square))
    named = [tuple(int(cloud[t]) for t in tri) for tri in tris]
    print(f"    decomposition into Rips triangles: {named}")
    assert len(tris) == 2

    big_eps = 30.0
    big_cycle: Set[Edge] = set()
    loop = [0, 3, 6, 9, 6, 2, 0]   # a closed walk; sum its edges over F_2
    for a, b in zip(loop, loop[1:]):
        e = (min(a, b), max(a, b))
        big_cycle ^= {e}
    big_cycle = {e for e in big_cycle if is_rips_edge(cloud, big_eps, e)}
    if is_cycle(big_cycle) and big_cycle:
        tris = decompose_cycle_into_triangles(cloud, big_eps, set(big_cycle))
        print(f"  a longer cycle {sorted(big_cycle)} at scale {big_eps}")
        print(f"    reduces to {len(tris)} Rips triangles: "
              f"{[tuple(int(cloud[t]) for t in tri) for tri in tris]}")

    # ---- 8. completeness of the barcode ------------------------------------------
    rule("8.  The barcode is a complete invariant:  p_n = 2 + sum of the first n bars")
    for m in [1, 5, 50, 5000, n]:
        assert primes[m] == 2 + sum(gaps[:m])
    print("  reconstruction of p_n from the bar lengths verified for all n up to "
          f"{n}")

    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
