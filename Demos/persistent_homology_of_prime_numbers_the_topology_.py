"""Algorithm C: the exponential-law audit for the prime barcode."""

from __future__ import annotations

import math
from typing import Dict, List, Sequence, Tuple


def short_bar_count(bars: Sequence[int], n: int, threshold: float = 2.0) -> int:
    """#{ i < n : g_i < threshold }.  For the primes and threshold 2 this is 1."""
    return sum(1 for i in range(n) if bars[i] < threshold)


def exponential_prediction(n: int, mu: float, threshold: float = 2.0) -> float:
    """Expected number of bars shorter than `threshold` under Exp(mean = mu)."""
    return n * (1.0 - math.exp(-threshold / mu))


def rejection_threshold(mu: float, threshold: float = 2.0) -> int:
    """
    Smallest n for which the exponential prediction strictly exceeds the true
    count 1, i.e. the least n with n(1 - e^{-threshold/mu}) > 1.
    """
    c = 1.0 - math.exp(-threshold / mu)
    return math.floor(1.0 / c) + 1


def audit(bars: Sequence[int], means: Sequence[float]) -> List[Dict[str, float]]:
    """
    Compare, for each candidate mean, the exponential prediction for the number
    of bars shorter than 2 with the truth.  The truth is 1 for every window,
    while the prediction grows linearly in n, so the test rejects at every mean.
    """
    n = len(bars)
    truth = short_bar_count(bars, n)
    rows: List[Dict[str, float]] = []
    for mu in means:
        rows.append({
            "mu": mu,
            "predicted": exponential_prediction(n, mu),
            "truth": float(truth),
            "rejects_from_n": float(rejection_threshold(mu)),
        })
    return rows


def rescaled_empirical_cdf(primes: Sequence[int], ts: Sequence[float]) -> List[Tuple[float, float]]:
    """
    The rescaled barcode statistic  B_n(t) = #{ i < n : g_i <= t log p_i } / n,
    conjectured (but not proved) to converge to 1 - e^{-t}.  Dividing by the
    local mean gap destroys the lattice that defeats the raw exponential law.
    """
    n = len(primes) - 1
    out: List[Tuple[float, float]] = []
    for t in ts:
        c = 0
        for i in range(n):
            if primes[i + 1] - primes[i] <= t * math.log(primes[i]):
                c += 1
        out.append((t, c / n))
    return out


if __name__ == "__main__":
    from alg_barcode import prime_barcode, sieve_primes

    bars = prime_barcode(10**6)
    mean_gap = sum(bars) / len(bars)
    print(f"{'mu':>10} {'predicted':>14} {'truth':>8} {'rejects from n':>16}")
    for row in audit(bars, [2.0, 5.0, mean_gap, math.log(10**6), 50.0, 1000.0]):
        print(f"{row['mu']:>10.4f} {row['predicted']:>14.1f} "
              f"{row['truth']:>8.0f} {row['rejects_from_n']:>16.0f}")

    print("\nrescaled statistic B_n(t) versus 1 - exp(-t):")
    primes = sieve_primes(200000)
    for t, val in rescaled_empirical_cdf(primes, [0.25, 0.5, 1.0, 1.5, 2.0, 3.0]):
        print(f"  t = {t:>4}:  B_n(t) = {val:.4f}   1 - e^-t = {1 - math.exp(-t):.4f}")


"""Algorithm A: extraction of the degree-zero prime barcode."""

from __future__ import annotations

from typing import List


def sieve_primes(limit: int) -> List[int]:
    """All primes below `limit` by the sieve of Eratosthenes; O(limit log log limit)."""
    if limit < 3:
        return []
    flags = bytearray([1]) * limit
    flags[0] = flags[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if flags[i]:
            flags[i * i :: i] = bytearray(len(flags[i * i :: i]))
    return [i for i in range(limit) if flags[i]]


def prime_barcode(limit: int) -> List[int]:
    """
    The degree-zero persistence barcode of the prime point cloud below `limit`.

    For a point cloud on a line, two consecutive points lie in the same Rips
    component at scale eps exactly when their gap is at most eps, and the
    component ending at index i dies exactly at eps = g_i.  Therefore the
    barcode is the list of bars [0, g_i) and no persistence pairing has to be
    computed: the bar lengths ARE the consecutive differences.

    Returns the list of bar lengths g_0, g_1, ..., g_{n-1} with g_0 = 1.
    """
    primes = sieve_primes(limit)
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


def total_persistence(bars: List[int]) -> int:
    """Sum of all bar lengths; telescopes to p_n - 2 for the prime cloud."""
    return sum(bars)


if __name__ == "__main__":
    bars = prime_barcode(10**6)
    print(f"bars:               {len(bars)}")
    print(f"first ten:          {bars[:10]}")
    print(f"total persistence:  {total_persistence(bars)}  (= p_n - 2)")
    print(f"odd bars:           {sum(1 for b in bars if b % 2 == 1)}  (the bar 2 -> 3)")


"""Algorithm B: Betti curve, window counts and defect queries in O(log n)."""

from __future__ import annotations

import bisect
from typing import List, Sequence


class BettiCurve:
    """
    Query engine for the degree-zero Betti curve of a point cloud on a line.

    Given the bar lengths g_0, ..., g_{n-1} (i.e. the consecutive gaps), the
    Betti curve is

        b0(eps, n) = 1 + #{ i < n : g_i > eps },

    the Betti defect is  (n + 1) - b0(eps, n) = #{ i < n : g_i <= eps }, and by
    the window identity

        b0(e1, n) - b0(e2, n) = #{ i < n : e1 < g_i <= e2 }   for e1 <= e2.

    A single sort in O(n log n) makes every query a binary search, O(log n).
    """

    def __init__(self, bars: Sequence[float]) -> None:
        self.n: int = len(bars)
        self.sorted_bars: List[float] = sorted(bars)

    def count_le(self, eps: float) -> int:
        """#{ i < n : g_i <= eps }."""
        return bisect.bisect_right(self.sorted_bars, eps)

    def betti(self, eps: float) -> int:
        """b0(eps, n): number of connected components of the first n+1 points."""
        return 1 + (self.n - self.count_le(eps))

    def defect(self, eps: float) -> int:
        """(n + 1) - b0(eps, n): merges already performed at scale eps."""
        return self.count_le(eps)

    def window(self, e1: float, e2: float) -> int:
        """#{ i < n : e1 < g_i <= e2 } = b0(e1, n) - b0(e2, n)."""
        return self.count_le(e2) - self.count_le(e1)

    def twin_count(self) -> int:
        """T(n) = b0(1, n) - b0(2, n) = n - b0(2, n): number of twin-prime bars."""
        return self.window(1.0, 2.0)


if __name__ == "__main__":
    from alg_barcode import prime_barcode

    bars = prime_barcode(10**6)
    bc = BettiCurve(bars)
    n = bc.n
    print(f"n = {n}")
    print(f"b0(2, n)           = {bc.betti(2.0)}")
    print(f"T(n)               = {bc.twin_count()}")
    print(f"b0(2,n) + T(n)     = {bc.betti(2.0) + bc.twin_count()}  (should be n)")
    for eps in (2.0, 4.0, 12.0, 246.0):
        print(f"defect at eps={eps:>6}: {bc.defect(eps)}")


"""Algorithm D: mod-2 first homology of a Vietoris-Rips complex."""

from __future__ import annotations

from typing import Callable, List, Sequence, Tuple


def rips_edges(points: Sequence[int], dist: Callable[[int, int], float],
               eps: float) -> List[Tuple[int, int]]:
    """1-simplices: pairs at distance at most eps."""
    return [(points[i], points[j])
            for i in range(len(points)) for j in range(i + 1, len(points))
            if dist(points[i], points[j]) <= eps]


def rips_triangles(points: Sequence[int], dist: Callable[[int, int], float],
                   eps: float) -> List[Tuple[int, int, int]]:
    """2-simplices: triples of diameter at most eps."""
    out: List[Tuple[int, int, int]] = []
    m = len(points)
    for i in range(m):
        for j in range(i + 1, m):
            if dist(points[i], points[j]) > eps:
                continue
            for k in range(j + 1, m):
                a, b, c = points[i], points[j], points[k]
                if dist(b, c) <= eps and dist(a, c) <= eps:
                    out.append((a, b, c))
    return out


def f2_rank(rows: List[int]) -> int:
    """Rank over F_2 of a matrix given as bit-mask rows; Gaussian elimination."""
    rank = 0
    pivots: List[int] = []
    for row in rows:
        cur = row
        for p in pivots:
            cur = min(cur, cur ^ p)
        if cur:
            pivots.append(cur)
            pivots.sort(reverse=True)
            rank += 1
    return rank


def betti_one_mod2(points: Sequence[int], dist: Callable[[int, int], float],
                   eps: float) -> int:
    """
    dim H_1(Rips(X, eps); F_2) = (#E - rank d_1) - rank d_2.

    For any point cloud on a line this is always 0: the umbrella property fills
    every loop.  For the graph metric of a 4-cycle at scale 1 it is 1.
    """
    edges = rips_edges(points, dist, eps)
    tris = rips_triangles(points, dist, eps)
    v_index = {v: i for i, v in enumerate(points)}
    e_index = {e: i for i, e in enumerate(edges)}
    rank_d1 = f2_rank([(1 << v_index[a]) | (1 << v_index[b]) for a, b in edges])
    rank_d2 = f2_rank([
        (1 << e_index[(a, b)]) | (1 << e_index[(b, c)]) | (1 << e_index[(a, c)])
        for a, b, c in tris
    ])
    return (len(edges) - rank_d1) - rank_d2


if __name__ == "__main__":
    primes_small = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59]
    line = lambda a, b: float(abs(a - b))
    print("primes below 60, line metric:")
    for eps in (2.0, 4.0, 6.0, 8.0, 14.0, 40.0):
        print(f"  eps = {eps:>5}:  dim H_1 = {betti_one_mod2(primes_small, line, eps)}")

    def square(a: int, b: int) -> float:
        diff = (a - b) % 4
        return float(min(diff, 4 - diff))

    print("4-cycle metric at scale 1 (a planar configuration):")
    print(f"  edges     = {rips_edges([0, 1, 2, 3], square, 1.0)}")
    print(f"  triangles = {rips_triangles([0, 1, 2, 3], square, 1.0)}")
    print(f"  dim H_1   = {betti_one_mod2([0, 1, 2, 3], square, 1.0)}  (essential class)")


"""
Atlas of the prime H_0 barcode
==============================

A four-panel figure summarising the degree-zero persistent homology of the
prime point cloud P = {2, 3, 5, 7, ...} on the real line.

Panel A -- the barcode itself.  Each bar [0, g_i) is drawn for the first few
    hundred primes; bar length = prime gap.  Twin-prime bars (length 2) are
    highlighted: they are the shortest bars in the picture apart from the
    unique length-1 bar from 2 to 3.

Panel B -- the Betti staircase eps -> b0(eps, n) = 1 + #{i < n : g_i > eps}.
    The staircase is constant between consecutive even integers: the risers
    sit on the even lattice, the single exception being the step at eps = 1.

Panel C -- the bar-length spectrum.  A stem plot of the multiplicity of each
    bar length.  Every odd length except 1 has multiplicity zero: the barcode
    measure is supported on the lattice {1} U 2N.  This is what makes a
    continuous (exponential) law impossible.

Panel D -- the exponential-law audit.  Empirical fraction of bars of length
    <= t against the exponential prediction 1 - exp(-t/mu) with mu the
    empirical mean gap.  Below t = 2 the empirical curve is flat at 1/n while
    the prediction is already a large fraction: the discrepancy is Theta(n).

Requires: numpy, matplotlib.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(limit: int) -> List[int]:
    flags = bytearray([1]) * limit
    flags[0] = flags[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if flags[i]:
            flags[i * i :: i] = bytearray(len(flags[i * i :: i]))
    return [i for i in range(limit) if flags[i]]


def make_figure(limit: int = 200_000, n_bars_drawn: int = 220) -> plt.Figure:
    primes = sieve_primes(limit)
    gaps = np.diff(np.array(primes, dtype=float))
    n = len(gaps)

    fig, axes = plt.subplots(2, 2, figsize=(13.5, 9.0))
    fig.suptitle(
        "The degree-zero barcode of the prime point cloud "
        f"(primes below {limit:,})",
        fontsize=14,
        fontweight="bold",
    )

    # ---- Panel A: the barcode -------------------------------------------
    ax = axes[0][0]
    shown = gaps[:n_bars_drawn]
    for i, g in enumerate(shown):
        colour = "#d62728" if g == 2 else ("#7f7f7f" if g == 1 else "#1f77b4")
        ax.plot([0, g], [i, i], lw=1.4, color=colour, solid_capstyle="butt")
    ax.set_title("A. Barcode: one bar per prime gap\n(red = twin-prime bar, grey = the bar 2 → 3)")
    ax.set_xlabel(r"scale $\varepsilon$")
    ax.set_ylabel("bar index $i$")
    ax.set_xlim(0, max(shown) * 1.05)
    ax.invert_yaxis()

    # ---- Panel B: the Betti staircase ------------------------------------
    ax = axes[0][1]
    m = 4000
    eps_grid = np.linspace(0, 40, 2001)
    sub = gaps[:m]
    betti = np.array([1 + int(np.count_nonzero(sub > e)) for e in eps_grid])
    ax.step(eps_grid, betti, where="post", color="#2ca02c", lw=1.6)
    for k in range(1, 21):
        ax.axvline(2 * k, color="0.88", lw=0.6, zorder=0)
    ax.axvline(1, color="#d62728", lw=0.8, ls="--", label=r"the only odd jump, $\varepsilon = 1$")
    ax.axvline(2, color="#ff7f0e", lw=1.0, ls=":", label=r"twin scale $\varepsilon = 2$")
    ax.set_title(f"B. Betti staircase $b_0(\\varepsilon, n)$, $n = {m}$\n"
                 "constant between consecutive even scales")
    ax.set_xlabel(r"scale $\varepsilon$")
    ax.set_ylabel(r"components $b_0(\varepsilon, n)$")
    ax.legend(fontsize=8)

    # ---- Panel C: the atomic spectrum ------------------------------------
    ax = axes[1][0]
    max_len = int(gaps.max())
    counts = np.bincount(gaps.astype(int), minlength=max_len + 1)
    lengths = np.arange(len(counts))
    ax.stem(lengths[lengths % 2 == 0], counts[lengths % 2 == 0],
            linefmt="#1f77b4", markerfmt=" ", basefmt=" ", label="even lengths")
    odd = lengths[(lengths % 2 == 1) & (counts > 0)]
    ax.stem(odd, counts[odd], linefmt="#d62728", markerfmt="o", basefmt=" ",
            label="odd lengths (only $g = 1$, once)")
    ax.set_yscale("symlog")
    ax.set_xlim(-1, min(max_len, 90))
    ax.set_title("C. Bar-length spectrum is atomic: support $\\{1\\} \\cup 2\\mathbb{N}$")
    ax.set_xlabel("bar length")
    ax.set_ylabel("multiplicity (symlog)")
    ax.legend(fontsize=8)

    # ---- Panel D: the exponential audit ----------------------------------
    ax = axes[1][1]
    mu = float(gaps.mean())
    ts = np.linspace(0, 60, 1200)
    empirical = np.array([np.count_nonzero(gaps <= t) / n for t in ts])
    predicted = 1 - np.exp(-ts / mu)
    ax.plot(ts, empirical, color="#1f77b4", lw=1.8, label="empirical  $F_n(t)$")
    ax.plot(ts, predicted, color="#d62728", lw=1.6, ls="--",
            label=fr"exponential, $\mu = {mu:.2f}$")
    ax.axvline(2, color="0.4", lw=0.8, ls=":")
    ax.annotate(
        f"at $t = 2$:  truth $= {1/n:.2e}$,\nprediction $= {1 - np.exp(-2/mu):.3f}$",
        xy=(2, 1 - np.exp(-2 / mu)), xytext=(12, 0.30),
        arrowprops=dict(arrowstyle="->", color="0.3"), fontsize=9,
    )
    ax.set_title("D. Exponential-law audit: the prediction fails at every mean")
    ax.set_xlabel("bar length $t$")
    ax.set_ylabel(r"fraction of bars with $g_i \leq t$")
    ax.legend(fontsize=9, loc="lower right")

    fig.tight_layout(rect=(0, 0, 1, 0.96))
    return fig


if __name__ == "__main__":
    figure = make_figure()
    figure.savefig("prime_barcode_atlas.png", dpi=150)
    print("wrote prime_barcode_atlas.png")


"""
The arithmetic-topology dictionary, visualised
==============================================

Two panels showing how arithmetic statements about prime gaps become
statements about the Betti curve of the prime point cloud.

Panel A -- the twin-prime Betti identity.  The three curves
        n,            b0(2, n),           T(n) = n - b0(2, n)
    are plotted against n.  The identity b0(2, n) + T(n) = n holds exactly at
    every n; the vertical shortfall between the diagonal n and the component
    count b0(2, n) IS the twin-prime counting function.  The twin prime
    conjecture is the statement that this shortfall is unbounded.

Panel B -- the defect spectrum.  For a family of scales B the merge count
        M(B, n) = (n + 1) - b0(B, n) = #{ i < n : g_i <= B }
    is plotted as a function of n.  Each curve is the "bounded gaps at
    distance B" counting function.  B = 2 is the twin prime conjecture
    (unboundedness open); B = 246 is the Maynard-Tao theorem (unboundedness
    known).  Lowering the smallest B for which the curve is unbounded is
    exactly the small-gaps programme.

Requires: numpy, matplotlib.
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(limit: int) -> List[int]:
    flags = bytearray([1]) * limit
    flags[0] = flags[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if flags[i]:
            flags[i * i :: i] = bytearray(len(flags[i * i :: i]))
    return [i for i in range(limit) if flags[i]]


def make_figure(limit: int = 10**6) -> plt.Figure:
    primes = sieve_primes(limit)
    gaps = np.diff(np.array(primes, dtype=int))
    n_total = len(gaps)
    ns = np.arange(1, n_total + 1)

    fig, axes = plt.subplots(1, 2, figsize=(14.0, 5.6))
    fig.suptitle("Arithmetic as a Betti defect of the prime point cloud",
                 fontsize=14, fontweight="bold")

    # ---- Panel A: twin identity -----------------------------------------
    twins_cum = np.cumsum(gaps == 2)
    long_cum = np.cumsum(gaps > 2)
    betti2 = 1 + long_cum          # b0(2, n)
    ax = axes[0]
    ax.plot(ns, ns, color="0.25", lw=1.4, label=r"$n$  (number of bars)")
    ax.plot(ns, betti2, color="#1f77b4", lw=1.6, label=r"$b_0(2, n)$  (components at scale 2)")
    ax.plot(ns, twins_cum, color="#d62728", lw=1.6, label=r"$T(n) = n - b_0(2, n)$  (twin bars)")
    ax.fill_between(ns, betti2, ns, color="#d62728", alpha=0.12)
    ax.set_title("A. $b_0(2,n) + T(n) = n$ exactly\n"
                 f"at $n = {n_total}$:  {betti2[-1]} + {twins_cum[-1]} = {n_total}")
    ax.set_xlabel("number of bars $n$")
    ax.set_ylabel("count")
    ax.legend(fontsize=9, loc="upper left")

    # ---- Panel B: defect spectrum ---------------------------------------
    ax = axes[1]
    for B, colour in [(2, "#d62728"), (4, "#ff7f0e"), (6, "#2ca02c"),
                      (12, "#1f77b4"), (70, "#9467bd"), (246, "#8c564b")]:
        merges = np.cumsum(gaps <= B)
        ax.plot(ns, merges, color=colour, lw=1.4, label=fr"$B = {B}$")
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_title("B. Merge count $M(B,n) = (n+1) - b_0(B,n)$\n"
                 "$B=2$: twin primes (open).  $B=246$: Maynard–Tao (theorem).")
    ax.set_xlabel("number of bars $n$")
    ax.set_ylabel("merges performed by scale $B$")
    ax.legend(fontsize=9, title="scale", loc="upper left")

    fig.tight_layout(rect=(0, 0, 1, 0.93))
    return fig


if __name__ == "__main__":
    figure = make_figure()
    figure.savefig("prime_defect_dictionary.png", dpi=150)
    print("wrote prime_defect_dictionary.png")


"""Assemble PACKAGE.json from the individual deliverables in this directory."""

from __future__ import annotations

import json
import pathlib
from typing import Dict, List

ROOT = pathlib.Path(__file__).resolve().parent
A = ROOT / "assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES: List[str] = [
    "Catalog/NumberTheory/PrimeRipsH1Vanishing.lean",
    "Catalog/NumberTheory/RipsH1Sharpness.lean",
    "Catalog/NumberTheory/PrimeBarcodeArithmetic.lean",
    "Catalog/NumberTheory/PrimeBarcodeRigidity.lean",
    "Catalog/NumberTheory/PrimeBarcodeBoundedGaps.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n{read(ROOT / f)}" for f in LEAN_FILES
)

FUTURE_DIRECTIONS = read(ROOT / "assets" / "future_directions.md")
INTERACTIVE_LAYOUT = read(ROOT / "assets" / "interactive_layout.md")

package: Dict[str, object] = {
    "title": "The Topology of Arithmetic: Persistent Homology of the Prime Point Cloud",
    "domain": "Bridges",
    "description": (
        "A complete determination of the Vietoris-Rips barcode of the primes viewed as a "
        "point cloud on the line: degree-one homology vanishes at every scale, the degree-zero "
        "bar lengths are pinned to the lattice {1} u 2N (refuting the exponential/Poisson law "
        "for every mean), and the Betti defect at scale 2 is exactly the twin-prime counting "
        "function, so the twin prime conjecture becomes the unboundedness of a Betti number."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-31",
    "key_results": [
        "Vanishing of first homology on a line: the Vietoris-Rips complex of any point cloud on the real line has trivial mod-2 first homology at every scale, so the prime point cloud has no degree-one barcode at all; a four-point planar configuration with the four-cycle metric carries an essential one-cycle, showing the result is sharp at dimension one.",
        "Atomicity of the bar-length spectrum: every degree-zero bar of the prime cloud has length 1 (once, from 2 to 3) or an even length at least 2, so the barcode measure is supported on the lattice {1} u 2N.",
        "Refutation of the exponential (Poisson) law: the number of bars shorter than 2 among the first n is exactly 1 for every n, whereas an exponential law of any mean mu > 0 predicts n(1 - e^{-2/mu}) such bars, a quantity tending to infinity; no exponential law with any mean, in particular none with mean log x, fits the prime barcode.",
        "The twin prime counting function is a Betti defect: b0(2, n) + #{i < n : g_i = 2} = n, equivalently the twin count equals the single Betti difference b0(1, n) - b0(2, n), and the twin prime conjecture is equivalent to the unboundedness of the defect n - b0(2, n).",
        "Rigidity and stability of the Betti curve: the Betti curve is a complete invariant of the degree-zero barcode of a line cloud, jumps only on the even lattice for the primes, is 2-delta interleaved under delta-perturbations, and is unbounded at every fixed scale, so the prime cloud is never eventually connected.",
    ],
    "keywords": [
        "persistent homology",
        "Vietoris-Rips complex",
        "prime gaps",
        "twin primes",
        "Betti curve",
        "bounded gaps",
        "Cramer model",
        "barcode",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Verification of the Prime Barcode: Atomicity, the Poisson Refutation and the Twin-Prime Betti Identity",
            "description": (
                "A single self-contained script that sieves the primes to 10^6, builds the "
                "degree-zero barcode as the gap sequence, and then verifies numerically every "
                "identity proved in the paper: atomicity of the bar-length spectrum (exactly one "
                "odd bar, the length-1 bar from 2 to 3); the constancy at 1 of the number of bars "
                "shorter than 2 for every window size; the divergence of the exponential prediction "
                "n(1 - e^{-2/mu}) for a range of candidate means; the twin-prime Betti identity "
                "b0(2,n) + T(n) = n and the window form T(n) = b0(1,n) - b0(2,n); the merge identity "
                "(n+1) - b0(eps,n) = #{g_i <= eps} at scales up to the Maynard-Tao value 246; the "
                "telescoping of total persistence to p_n - 2 with the atomic bound p_n >= 2n+1; "
                "even-window rigidity of the Betti staircase; the 2-delta interleaving bound under a "
                "random perturbation of the primes; the factorial composite window that forces "
                "arbitrarily many components at every fixed scale; and a brute-force mod-2 "
                "computation of first homology showing 0 for prime windows and 1 for the four-cycle "
                "metric."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Barcode Extraction by Sieving: the Degree-Zero Persistence Diagram of a Line Cloud",
            "description": (
                "For a point cloud on the real line the degree-zero persistence pairing is "
                "degenerate in the best possible way: two consecutive points lie in the same Rips "
                "component at scale eps precisely when their gap is at most eps, so components are "
                "maximal runs of consecutive points and the component ending at index i dies exactly "
                "at eps = g_i. The barcode is therefore the multiset of consecutive differences, and "
                "no union-find pass or matrix reduction is required. This is what makes the prime "
                "cloud computable at scales where general Rips persistence is hopeless: a Rips "
                "complex on the 78,497 primes below 10^6 would have about 3 x 10^9 edges, while the "
                "barcode is obtained in one linear scan. Complexity: O(X log log X) time and O(X) "
                "bits for the sieve to X, then O(pi(X)) for the differences. Total persistence "
                "telescopes to p_n - 2, and by atomicity is bounded below by 2n - 1."
            ),
            "pseudocode": (
                "Input: limit X\n"
                "Output: bar lengths g_0, ..., g_{n-1} of the degree-zero barcode\n"
                "\n"
                "1. flags <- array of 1s of length X;  flags[0] <- flags[1] <- 0\n"
                "2. for i = 2 to floor(sqrt(X)):\n"
                "3.     if flags[i] = 1:\n"
                "4.         for j = i*i, i*i + i, ... < X:  flags[j] <- 0\n"
                "5. primes <- [ i : flags[i] = 1 ]\n"
                "6. for i = 0 to |primes| - 2:\n"
                "7.     emit g_i <- primes[i+1] - primes[i]        // the i-th bar [0, g_i)\n"
                "8. return (g_0, ..., g_{n-1})\n"
                "\n"
                "Invariant: sum_{i<n} g_i = p_{n+1} - 2 (telescoping total persistence).\n"
                "Invariant: g_0 = 1 and g_i is even for all i >= 1 (atomicity)."
            ),
            "code": read(A / "alg_barcode.py"),
        },
        {
            "name": "Logarithmic-Time Betti Curve, Window and Defect Queries",
            "description": (
                "All degree-zero invariants of a line cloud are upper-tail counts of the bar-length "
                "multiset: b0(eps, n) = 1 + #{g_i > eps}; the Betti defect (n+1) - b0(eps, n) is the "
                "merge count #{g_i <= eps}; the window difference b0(e1, n) - b0(e2, n) counts bars in "
                "(e1, e2]; and the twin-prime counting function is the single window (1, 2]. Since the "
                "Betti curve is a complete invariant of the barcode, this data structure loses nothing "
                "relative to the barcode itself. One sort in O(n log n) reduces every query to a binary "
                "search in O(log n), so scanning a whole staircase on a grid of m scales costs "
                "O(n log n + m log n) rather than the naive O(mn)."
            ),
            "pseudocode": (
                "Preprocess(bars g_0..g_{n-1}):\n"
                "1. S <- sort(bars) ascending;  store n\n"
                "\n"
                "CountLE(eps):\n"
                "2. return bisect_right(S, eps)                       // #{ i : g_i <= eps }\n"
                "\n"
                "Betti(eps):\n"
                "3. return 1 + (n - CountLE(eps))                     // b0(eps, n)\n"
                "\n"
                "Defect(eps):\n"
                "4. return CountLE(eps)                               // (n+1) - b0(eps, n)\n"
                "\n"
                "Window(e1, e2)   [requires e1 <= e2]:\n"
                "5. return CountLE(e2) - CountLE(e1)                  // b0(e1,n) - b0(e2,n)\n"
                "\n"
                "TwinCount():\n"
                "6. return Window(1, 2)                               // = n - Betti(2)\n"
                "\n"
                "Complexity: O(n log n) preprocessing, O(log n) per query."
            ),
            "code": read(A / "alg_betti.py"),
        },
        {
            "name": "The Exponential-Law Audit: a Quantitative Test that Rejects Every Candidate Mean",
            "description": (
                "The Cramer heuristic predicts exponentially distributed bar lengths with mean log x. "
                "The audit compares, for each candidate mean mu, the prediction n(1 - e^{-2/mu}) for "
                "the number of bars shorter than 2 with the true count, which is exactly 1 for every "
                "window. Because the prediction grows linearly in n while the truth is constant, the "
                "test rejects for every mu > 0 as soon as n exceeds floor(1/(1 - e^{-2/mu})) + 1 -- "
                "for the empirical mean 12.74 this is n = 7. The audit also computes the rescaled "
                "statistic B_n(t) = #{i < n : g_i <= t log p_i}/n, whose conjectural limit 1 - e^{-t} "
                "is the surviving, still open, form of the Poisson prediction; dividing by the local "
                "mean gap destroys the lattice that defeats the raw law while preserving the shape. "
                "Complexity: O(n) per threshold, O(n) memory."
            ),
            "pseudocode": (
                "Input: bar lengths g_0..g_{n-1}, candidate means mu_1..mu_k\n"
                "Output: for each mean, the prediction, the truth, and the rejection index\n"
                "\n"
                "1. truth <- #{ i < n : g_i < 2 }                      // provably equal to 1\n"
                "2. for each mu in the candidate list:\n"
                "3.     c   <- 1 - exp(-2/mu)                          // 0 < c < 1\n"
                "4.     pred <- n * c                                  // exponential prediction\n"
                "5.     N   <- floor(1/c) + 1                          // least n with n*c > 1\n"
                "6.     report (mu, pred, truth, N);  reject the law whenever pred > truth\n"
                "\n"
                "Rescaled test:\n"
                "7. for each t > 0:  B_n(t) <- #{ i < n : g_i <= t * log p_i } / n\n"
                "8. compare B_n(t) with 1 - exp(-t)                    // the open Cramer form"
            ),
            "code": read(A / "alg_audit.py"),
        },
        {
            "name": "Mod-2 First Homology of a Vietoris-Rips Complex by Rank Computation",
            "description": (
                "A direct verification tool for the vanishing theorem and its sharpness. Given a "
                "finite metric configuration and a scale, the algorithm enumerates the Rips edges "
                "(pairs of distance at most eps) and Rips triangles (triples of diameter at most eps), "
                "assembles the boundary matrices over F_2 as bit-vectors, and returns "
                "dim H_1 = (#E - rank d_1) - rank d_2 by Gaussian elimination. For any configuration "
                "on a line the answer is 0 at every scale, in accordance with the umbrella argument; "
                "for the graph metric of a 4-cycle at scale 1 there are four edges, no triangles, and "
                "the answer is 1 -- an essential class. Complexity: O(m^3) to enumerate triangles on "
                "m points, plus O(r * #E) word operations for elimination, so it is intended for small "
                "diagnostic configurations rather than for the full prime cloud (which needs none, "
                "since its degree-one homology is provably zero)."
            ),
            "pseudocode": (
                "Input: point labels V, distance function d, scale eps\n"
                "Output: dim H_1(Rips(V, eps); F_2)\n"
                "\n"
                "1. E <- [ (a,b) : a < b in V, d(a,b) <= eps ]\n"
                "2. T <- [ (a,b,c) : a < b < c in V, max(d(a,b), d(b,c), d(a,c)) <= eps ]\n"
                "3. d1 <- for each (a,b) in E: bitmask with bits a and b set\n"
                "4. d2 <- for each (a,b,c) in T: bitmask with the indices of (a,b),(b,c),(a,c) set\n"
                "5. r1 <- F2Rank(d1);  r2 <- F2Rank(d2)\n"
                "6. return (|E| - r1) - r2\n"
                "\n"
                "F2Rank(rows):\n"
                "7. pivots <- empty;  rank <- 0\n"
                "8. for r in rows:  for p in pivots: r <- min(r, r xor p)\n"
                "9.     if r != 0: append r to pivots (kept sorted descending); rank <- rank + 1\n"
                "10. return rank"
            ),
            "code": read(A / "alg_h1.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Atlas of the Prime Barcode: Bars, Staircase, Atomic Spectrum and the Failed Exponential Fit",
            "description": (
                "A four-panel figure. (A) The barcode itself for the first few hundred primes, one bar "
                "per gap, with twin-prime bars highlighted. (B) The Betti staircase eps -> b0(eps, n), "
                "with the even scales marked: the staircase is flat between consecutive even integers, "
                "its only odd riser sitting at eps = 1. (C) The bar-length spectrum on a symmetric log "
                "scale, showing that every odd length except 1 has multiplicity zero -- the lattice "
                "{1} u 2N. (D) The exponential-law audit: the empirical fraction of bars of length at "
                "most t against 1 - exp(-t/mu), annotated at t = 2 where the truth is 1/n and the "
                "prediction is a large fraction."
            ),
            "code": read(A / "viz_barcode_atlas.py"),
        },
        {
            "name": "The Arithmetic-Topology Dictionary: Twin Primes and Bounded Gaps as Betti Defects",
            "description": (
                "Two panels showing arithmetic as topology. (A) The diagonal n, the component count "
                "b0(2, n) and the shaded shortfall between them, which is exactly the twin-prime "
                "counting function T(n) = n - b0(2, n); the twin prime conjecture asserts that this "
                "shaded region is unbounded. (B) The merge count (n+1) - b0(B, n) = #{i < n : g_i <= B} "
                "for a family of scales B on log-log axes: B = 2 is the twin prime conjecture, whose "
                "unboundedness is open, while B = 246 is the Maynard-Tao theorem, whose unboundedness "
                "is known. Lowering the least such B is precisely the small-gaps programme."
            ),
            "code": read(A / "viz_defect_dictionary.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Prime Barcode Explorer: Watch Arithmetic Become Topology",
            "description": (
                "A live laboratory for the degree-zero barcode of the primes. A scale slider grows the "
                "Rips parameter eps while a second slider chooses the window of primes; the page draws "
                "the prime cloud coloured by connected component, the Betti staircase with the even "
                "scales marked and the current eps tracked, and the bar-length spectrum on a log axis "
                "with the exponential density overlaid. Six live readouts report the component count "
                "b0(eps, n), the merge count (n+1) - b0(eps, n), the twin count n - b0(2, n), the mean "
                "bar length, the number of bars shorter than 2 -- which stays pinned at 1 no matter how "
                "far the window is pushed -- and the exponential prediction for that same quantity, "
                "which races off to the thousands. Sliding eps through 2 makes the twin-prime identity "
                "visible as a single jump in the staircase."
            ),
            "html": read(A / "widget_barcode_explorer.html"),
        },
        {
            "title": "The Umbrella Lab: Why a Cloud on a Line Can Never Have a Hole",
            "description": (
                "A draggable-point sandbox that lets the reader discover the vanishing theorem for "
                "themselves. Points can be moved freely in the plane; edges appear between points "
                "within the current scale eps, triangles are shaded whenever all three sides are "
                "present, and the dimension of first homology is computed live over F_2 by rank "
                "computation. Starting from the square with the four-cycle metric, the reader sees an "
                "essential hole (dim H_1 = 1) with four edges and no triangle; pressing 'Snap to a "
                "line' collapses the configuration onto the real line, whereupon every loop is "
                "instantly filled and the reader cannot make a hole no matter how the points are "
                "dragged or the scale is tuned. An expandable note gives the umbrella argument: at the "
                "rightmost vertex of any loop, two incoming edges force a filled triangle, and adding "
                "its boundary slides the loop strictly downhill until it vanishes."
            ),
            "html": read(A / "widget_umbrella_lab.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "barcode_extraction": read(A / "alg_barcode.py"),
        "betti_queries": read(A / "alg_betti.py"),
        "exponential_audit": read(A / "alg_audit.py"),
        "mod2_first_homology": read(A / "alg_h1.py"),
    },
    "lean_files": LEAN_FILES,
}

(ROOT / "PACKAGE.json").write_text(
    json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
)
print("wrote PACKAGE.json")


"""
Persistent Homology of the Prime Point Cloud
============================================

Numerical companion to "The Topology of Arithmetic: Persistent Homology of the
Prime Point Cloud".

The prime point cloud is the set P = {2, 3, 5, 7, 11, ...} regarded as points on
the real line.  Its Vietoris-Rips filtration at scale eps joins two primes when
their distance is at most eps.  Because the cloud is one-dimensional:

  * the degree-one persistent homology vanishes identically, and
  * the degree-zero barcode is exactly the sequence of prime gaps
        g_i = p_{i+1} - p_i ,      i = 0, 1, 2, ...
    with Betti curve
        b0(eps, n) = 1 + #{ i < n : g_i > eps }.

This script verifies, numerically, every quantitative statement made in the
paper:

  1. Atomicity of the bar-length spectrum: g_0 = 1 and every later gap is even.
  2. Exactly one bar of length < 2 among the first n bars, for every n >= 1.
  3. Failure of the exponential (Poisson) prediction for every mean mu > 0.
  4. The twin-prime Betti identity      b0(2, n) + T(n) = n,
     and the window identity            T(n) = b0(1, n) - b0(2, n).
  5. The merge/defect identity          n + 1 - b0(eps, n) = #{ i < n : g_i <= eps },
     the barcode form of the bounded-gaps theorem.
  6. Total persistence  sum_i g_i = p_n - 2  and the lower bound  p_n >= 2n + 1.
  7. Even-window rigidity: b0(., n) is constant on (2k, 2k+2) for k >= 1.
  8. Interleaving stability: a delta-perturbation shifts the Betti curve by at
     most 2*delta in scale.
  9. Unboundedness of b0(eps, .) at every fixed scale, via factorial gaps.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterator, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. The point cloud
# ----------------------------------------------------------------------------


def sieve_primes(limit: int) -> List[int]:
    """All primes < limit, by a simple sieve of Eratosthenes."""
    if limit < 3:
        return []
    flags = bytearray([1]) * limit
    flags[0] = flags[1] = 0
    for i in range(2, int(limit**0.5) + 1):
        if flags[i]:
            flags[i * i :: i] = bytearray(len(flags[i * i :: i]))
    return [i for i in range(limit) if flags[i]]


def gaps(points: Sequence[int]) -> List[int]:
    """The H_0 bar lengths of a point cloud on the line: consecutive differences."""
    return [points[i + 1] - points[i] for i in range(len(points) - 1)]


# ----------------------------------------------------------------------------
# 2. Degree-zero persistent homology of a cloud on the line
# ----------------------------------------------------------------------------


def betti_zero(bar_lengths: Sequence[float], eps: float, n: int) -> int:
    """b0(eps, n) = 1 + #{ i < n : g_i > eps }: components of the first n+1 points."""
    return 1 + sum(1 for i in range(n) if bar_lengths[i] > eps)


def merge_count(bar_lengths: Sequence[float], eps: float, n: int) -> int:
    """The Betti defect n + 1 - b0(eps, n): merges already performed at scale eps."""
    return sum(1 for i in range(n) if bar_lengths[i] <= eps)


def total_persistence(bar_lengths: Sequence[float], n: int) -> float:
    """Sum of the first n bar lengths; telescopes to p_n - p_0."""
    return float(sum(bar_lengths[:n]))


# ----------------------------------------------------------------------------
# 3. Degree-one homology of a Rips complex (brute force, tiny clouds only)
# ----------------------------------------------------------------------------


def rips_edges(dist: Dict[Tuple[int, int], float], vertices: Sequence[int],
               eps: float) -> List[Tuple[int, int]]:
    """Edges of the Rips complex at scale eps."""
    out: List[Tuple[int, int]] = []
    for a_idx, a in enumerate(vertices):
        for b in vertices[a_idx + 1 :]:
            if dist[(a, b)] <= eps:
                out.append((a, b))
    return out


def rips_triangles(dist: Dict[Tuple[int, int], float], vertices: Sequence[int],
                   eps: float) -> List[Tuple[int, int, int]]:
    """2-simplices of the Rips complex: triples of diameter at most eps."""
    out: List[Tuple[int, int, int]] = []
    vs = list(vertices)
    for i in range(len(vs)):
        for j in range(i + 1, len(vs)):
            for k in range(j + 1, len(vs)):
                a, b, c = vs[i], vs[j], vs[k]
                if max(dist[(a, b)], dist[(b, c)], dist[(a, c)]) <= eps:
                    out.append((a, b, c))
    return out


def betti_one_mod2(dist: Dict[Tuple[int, int], float], vertices: Sequence[int],
                   eps: float) -> int:
    """
    dim H_1(Rips(X, eps); F_2) by rank computation over F_2.

    H_1 = ker(d_1) / im(d_2), so dim H_1 = (#E - rank d_1) - rank d_2.
    """
    edges = rips_edges(dist, vertices, eps)
    tris = rips_triangles(dist, vertices, eps)
    e_index = {e: i for i, e in enumerate(edges)}

    def f2_rank(rows: List[int]) -> int:
        rank = 0
        rows = [r for r in rows if r]
        pivots: List[int] = []
        for row in rows:
            cur = row
            for p in pivots:
                cur = min(cur, cur ^ p)
            if cur:
                pivots.append(cur)
                pivots.sort(reverse=True)
                rank += 1
        return rank

    # boundary_1 : edges -> vertices, as bit-rows indexed by vertices
    v_index = {v: i for i, v in enumerate(vertices)}
    d1_rows = [(1 << v_index[a]) | (1 << v_index[b]) for (a, b) in edges]
    rank_d1 = f2_rank(d1_rows)

    # boundary_2 : triangles -> edges, as bit-rows indexed by edges
    d2_rows = []
    for (a, b, c) in tris:
        row = (1 << e_index[(a, b)]) | (1 << e_index[(b, c)]) | (1 << e_index[(a, c)])
        d2_rows.append(row)
    rank_d2 = f2_rank(d2_rows)

    return (len(edges) - rank_d1) - rank_d2


def line_distance(points: Sequence[int]) -> Dict[Tuple[int, int], float]:
    d: Dict[Tuple[int, int], float] = {}
    for a in points:
        for b in points:
            d[(a, b)] = float(abs(a - b))
    return d


def square_distance() -> Tuple[Dict[Tuple[int, int], float], List[int]]:
    """Graph metric of the 4-cycle 0-1-2-3-0: the planar counterexample."""
    verts = [0, 1, 2, 3]
    d: Dict[Tuple[int, int], float] = {}
    for a in verts:
        for b in verts:
            diff = (a - b) % 4
            d[(a, b)] = float(min(diff, 4 - diff))
    return d, verts


# ----------------------------------------------------------------------------
# 4. Reporting
# ----------------------------------------------------------------------------


def hr(title: str) -> None:
    print()
    print("=" * 76)
    print(title)
    print("=" * 76)


def main() -> None:
    LIMIT = 10**6
    primes = sieve_primes(LIMIT)
    g = gaps(primes)
    n = len(g)

    hr("0.  The prime point cloud up to 10^6")
    print(f"primes below {LIMIT}:        {len(primes)}")
    print(f"H_0 bars (= prime gaps):    {n}")
    print(f"first ten bar lengths:      {g[:10]}")
    print(f"mean bar length:            {sum(g) / n:.4f}")
    print(f"log(10^6):                  {math.log(LIMIT):.4f}")
    longest = max(g)
    where = primes[g.index(longest)]
    print(f"longest bar:                {longest}  (starting at p = {where})")

    hr("1.  Atomicity of the bar-length spectrum:  lengths lie in {1} U 2N")
    odd = [i for i, x in enumerate(g) if x % 2 == 1]
    print(f"bars of odd length:         {len(odd)}  at index/indices {odd}")
    print(f"that bar runs from {primes[odd[0]]} to {primes[odd[0] + 1]}, length {g[odd[0]]}")
    print(f"all other bars even:        {all(x % 2 == 0 for x in g[1:])}")
    print(f"all other bars >= 2:        {all(x >= 2 for x in g[1:])}")

    hr("2.  Exactly one bar of length < 2 among the first n, for every n >= 1")
    for m in (1, 2, 10, 1000, n):
        c = sum(1 for i in range(m) if g[i] < 2)
        print(f"  n = {m:>6}:  #{{ i < n : g_i < 2 }} = {c}")

    hr("3.  Refutation of the exponential / Poisson law")
    print("  For an exponential law of mean mu, the expected number of bars of")
    print("  length < 2 among n bars is n * (1 - exp(-2/mu)).")
    print(f"{'mu':>10} {'prediction':>16} {'truth':>8}")
    for mu in (2.0, 5.0, sum(g) / n, math.log(LIMIT), 50.0, 1000.0):
        pred = n * (1 - math.exp(-2 / mu))
        print(f"{mu:>10.4f} {pred:>16.1f} {1:>8}")
    print("  The prediction diverges with n for every mu > 0; the truth is 1.")
    mu = sum(g) / n
    n_star = math.ceil(1 / (1 - math.exp(-2 / mu)))
    print(f"  Threshold for mu = {mu:.4f}: prediction exceeds 1 as soon as n >= {n_star}.")

    hr("4.  The twin-prime Betti identity")
    twins = sum(1 for x in g if x == 2)
    b2 = betti_zero(g, 2.0, n)
    b1 = betti_zero(g, 1.0, n)
    print(f"twin-prime bars T(n):              {twins}")
    print(f"b0(2, n):                          {b2}")
    print(f"b0(2, n) + T(n) = {b2 + twins}   (should equal n = {n})   -> {b2 + twins == n}")
    print(f"b0(1, n) - b0(2, n) = {b1 - b2}  (should equal T(n))     -> {b1 - b2 == twins}")
    print(f"Betti defect n - b0(2, n) = {n - b2}")

    hr("5.  Merge identity and bounded gaps")
    print("  n + 1 - b0(eps, n) = #{ i < n : g_i <= eps }  (merges by scale eps)")
    for eps in (2.0, 4.0, 6.0, 12.0, 246.0):
        defect = n + 1 - betti_zero(g, eps, n)
        merges = merge_count(g, eps, n)
        print(f"  eps = {eps:>6}: defect = {defect:>6}, merges = {merges:>6}, equal -> {defect == merges}")
    print("  Maynard-Tao (B = 246): the scale-246 defect grows without bound;")
    print(f"  already {merge_count(g, 246.0, n)} merges have occurred by 10^6.")

    hr("6.  Total persistence and the linear lower bound p_n >= 2n + 1")
    for m in (1, 5, 100, 10000, n):
        tp = total_persistence(g, m)
        print(f"  n = {m:>6}: total persistence = {tp:>9.0f} = p_n - 2 = {primes[m] - 2:>9}"
              f"   and p_n = {primes[m]:>8} >= 2n+1 = {2 * m + 1:>8}  -> {primes[m] >= 2 * m + 1}")

    hr("7.  Even-window rigidity: b0 is constant on (2k, 2k+2) for k >= 1")
    m = 20000
    for k in (1, 2, 3, 10):
        lo, hi = 2 * k + 0.001, 2 * k + 1.999
        vals = {betti_zero(g, e, m) for e in (lo, (lo + hi) / 2, hi)}
        print(f"  k = {k:>3}: b0 on (2k, 2k+2) takes values {sorted(vals)}"
              f"  -> constant: {len(vals) == 1}")
    print("  (at k = 0 the length-1 bar does cause a jump:")
    print(f"   b0(0.5, {m}) = {betti_zero(g, 0.5, m)}, b0(1.5, {m}) = {betti_zero(g, 1.5, m)})")

    hr("8.  Interleaving stability under a delta-perturbation")
    random.seed(20260831)
    delta = 0.4
    m = 5000
    perturbed = [p + random.uniform(-delta, delta) for p in primes[: m + 1]]
    gq = [perturbed[i + 1] - perturbed[i] for i in range(m)]
    ok = True
    for eps in (0.0, 1.0, 2.0, 4.0, 10.0, 30.0):
        lhs = betti_zero(gq, eps + 2 * delta, m)
        rhs = betti_zero(g, eps, m)
        ok = ok and lhs <= rhs
        print(f"  eps = {eps:>5}: b0_perturbed(eps+2d) = {lhs:>5} <= b0_prime(eps) = {rhs:>5}"
              f"  -> {lhs <= rhs}")
    print(f"  interleaving bound holds throughout: {ok}")

    hr("9.  Every fixed scale has arbitrarily many components (factorial gaps)")
    print("  For any m, the m-1 integers m!+2, ..., m!+m are all composite,")
    print("  so a bar of length > m occurs beyond p ~ m!.  Small verification:")
    for m in (5, 6, 7, 8):
        f = math.factorial(m)
        composite = all((f + k) % k == 0 for k in range(2, m + 1))
        print(f"  m = {m}: m! = {f:>7}, every m!+k (2<=k<=m) divisible by k -> {composite}")
    print("  Consequence: b0(eps, n) -> infinity in n for every fixed eps.")

    hr("10.  Degree one: the prime cloud has no holes; the square does")
    window = [p for p in primes if p < 60]
    d_line = line_distance(window)
    print("  H_1 of the Rips complex of the primes below 60:")
    for eps in (2.0, 4.0, 6.0, 8.0, 14.0):
        b1_dim = betti_one_mod2(d_line, window, eps)
        print(f"    eps = {eps:>5}:  dim H_1 = {b1_dim}")
    d_sq, vs = square_distance()
    print("  H_1 of the 4-cycle metric (a planar configuration) at scale 1:")
    print(f"    edges = {rips_edges(d_sq, vs, 1.0)}")
    print(f"    triangles = {rips_triangles(d_sq, vs, 1.0)}")
    print(f"    dim H_1 = {betti_one_mod2(d_sq, vs, 1.0)}   (an essential class)")
    print()
    print("  One dimension is exactly the boundary between trivial and nontrivial H_1.")


if __name__ == "__main__":
    main()
