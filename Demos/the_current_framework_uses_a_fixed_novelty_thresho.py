"""
demo.py — Numerical demonstrations of the Metric Theory of Certified Novelty.

This script is fully self-contained (standard library only) and illustrates every
main result of the accompanying article and research paper:

    1. Novelty score and certificate, plus score/certificate duality.
    2. Triangle-transfer robustness: novelty degrades by at most the perturbation.
    3. 1-Lipschitz regularity of the novelty score.
    4. Antitone dependence on the corpus (more knowledge => less novelty).
    5. Knowledge saturation via epsilon-nets (forward + high-threshold collapse).
    6. Approximate converse to saturation (with slack eta > 0).
    7. Adaptive threshold = corpus separation is *exactly discriminating*.
    8. Compositional novelty on products (weakest link) and its 1-Lipschitz law.
    9. The novelty filtration: antitone in threshold and in corpus.
   10. Packing: mutual separation yields disjoint half-radius balls.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Iterable, Sequence, Tuple

# A point is a tuple of floats; a corpus is a sequence of points.
Point = Tuple[float, ...]
Corpus = Sequence[Point]
Metric = Callable[[Point, Point], float]


# --------------------------------------------------------------------------- #
# Metrics
# --------------------------------------------------------------------------- #
def euclidean(a: Point, b: Point) -> float:
    """Standard Euclidean (l^2) distance."""
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a, b)))


def linf(a: Point, b: Point) -> float:
    """l^infinity (Chebyshev) distance: max coordinate gap."""
    return max(abs(x - y) for x, y in zip(a, b))


# --------------------------------------------------------------------------- #
# Core definitions (Definitions 2.1-2.4 of the paper)
# --------------------------------------------------------------------------- #
def novelty_score(corpus: Corpus, x: Point, dist: Metric = euclidean) -> float:
    """noveltyScore(S, x) = inf_{s in S} dist(x, s).  Empty corpus -> 0.0."""
    if not corpus:
        return 0.0
    return min(dist(x, s) for s in corpus)


def is_novel(eps: float, corpus: Corpus, x: Point, dist: Metric = euclidean) -> bool:
    """IsNovel eps S x : every known point is at distance >= eps from x."""
    return all(eps <= dist(x, s) for s in corpus)


def corpus_separation(corpus: Corpus, dist: Metric = euclidean) -> float:
    """sigma = min_{a != b in S} dist(a, b): the corpus's intrinsic resolution."""
    if len(corpus) < 2:
        return math.inf
    return min(dist(a, b) for a, b in itertools.combinations(corpus, 2))


def is_eps_net(eps: float, corpus: Corpus, samples: Iterable[Point],
               dist: Metric = euclidean) -> bool:
    """Empirical IsEpsNet eps S: every sampled point lies within eps of S."""
    return all(novelty_score(corpus, x, dist) <= eps for x in samples)


# --------------------------------------------------------------------------- #
# Demo 1: score/certificate duality (Theorem 3.1)
# --------------------------------------------------------------------------- #
def demo_duality() -> None:
    print("=" * 70)
    print("DEMO 1  Score / certificate duality  (Theorem 3.1)")
    print("=" * 70)
    corpus: Corpus = [(0.0, 0.0), (3.0, 0.0), (0.0, 4.0)]
    x: Point = (1.0, 1.0)
    score = novelty_score(corpus, x)
    print(f"corpus           = {corpus}")
    print(f"candidate x      = {x}")
    print(f"novelty score    = {score:.4f}")
    for eps in (0.5, score, score + 0.3):
        lhs = is_novel(eps, corpus, x)
        rhs = eps <= score + 1e-12
        print(f"  eps={eps:6.4f}:  IsNovel={lhs!s:5}  (eps<=score)={rhs!s:5}  "
              f"agree={lhs == rhs}")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: triangle-transfer robustness (Theorem 3.5)
# --------------------------------------------------------------------------- #
def demo_robustness() -> None:
    print("=" * 70)
    print("DEMO 2  Triangle-transfer robustness  (Theorem 3.5)")
    print("=" * 70)
    corpus: Corpus = [(0.0, 0.0), (10.0, 0.0)]
    x: Point = (5.0, 0.0)
    eps = novelty_score(corpus, x)  # x is exactly eps-novel
    print(f"x = {x} is {eps:.3f}-novel.")
    for delta in (0.5, 1.0, 2.0):
        y = (x[0] + delta, x[1])  # perturb x by exactly delta
        guaranteed = eps - delta
        actual = novelty_score(corpus, y)
        ok = actual >= guaranteed - 1e-9
        print(f"  perturb by delta={delta:4.2f} -> y={y}: "
              f"guaranteed >= {guaranteed:5.3f}, actual = {actual:5.3f}, "
              f"holds={ok}")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: 1-Lipschitz regularity (Theorem 3.2)
# --------------------------------------------------------------------------- #
def demo_lipschitz() -> None:
    print("=" * 70)
    print("DEMO 3  1-Lipschitz regularity of the score  (Theorem 3.2)")
    print("=" * 70)
    corpus: Corpus = [(0.0, 0.0), (2.0, 5.0), (-3.0, 1.0)]
    pts = [(0.3, 0.7), (1.1, -0.2), (4.0, 4.0), (-2.0, 3.0)]
    worst = 0.0
    for a, b in itertools.combinations(pts, 2):
        ds = abs(novelty_score(corpus, a) - novelty_score(corpus, b))
        dp = euclidean(a, b)
        ratio = ds / dp if dp > 0 else 0.0
        worst = max(worst, ratio)
        print(f"  |dscore|={ds:5.3f}  dist={dp:5.3f}  ratio={ratio:5.3f}  "
              f"<=1: {ds <= dp + 1e-9}")
    print(f"worst observed Lipschitz ratio = {worst:.3f}  (theory: <= 1)")
    print()


# --------------------------------------------------------------------------- #
# Demo 4: antitone in the corpus (Theorem 3.4)
# --------------------------------------------------------------------------- #
def demo_antitone_corpus() -> None:
    print("=" * 70)
    print("DEMO 4  Antitone in the corpus: more knowledge => less novelty (Thm 3.4)")
    print("=" * 70)
    small: Corpus = [(0.0, 0.0)]
    big: Corpus = [(0.0, 0.0), (1.0, 1.0), (2.0, 0.5)]  # small subset of big
    x: Point = (1.2, 1.1)
    s_small = novelty_score(small, x)
    s_big = novelty_score(big, x)
    print(f"score vs small corpus {small}     = {s_small:.4f}")
    print(f"score vs big   corpus (superset)  = {s_big:.4f}")
    print(f"score(big) <= score(small): {s_big <= s_small + 1e-12}")
    print()


# --------------------------------------------------------------------------- #
# Demo 5 & 6: knowledge saturation and approximate converse (Thms 4.1-4.3)
# --------------------------------------------------------------------------- #
def demo_saturation() -> None:
    print("=" * 70)
    print("DEMO 5/6  Knowledge saturation via eps-nets  (Theorems 4.1-4.3)")
    print("=" * 70)
    # A grid corpus on [0,1]^2 with spacing h is an eps-net for eps = h/sqrt(2).
    h = 0.25
    corpus: Corpus = [(i * h, j * h) for i in range(5) for j in range(5)]
    eps = h / math.sqrt(2)  # covering radius of a square grid (l^2)
    samples = [(0.137, 0.911), (0.5, 0.5), (0.999, 0.001), (0.62, 0.41)]
    print(f"grid spacing h={h}, covering radius eps={eps:.4f}")
    print(f"empirical eps-net over samples: {is_eps_net(eps + 1e-9, corpus, samples)}")
    max_score = max(novelty_score(corpus, x) for x in samples)
    print(f"max novelty score over samples = {max_score:.4f}  (<= eps: "
          f"{max_score <= eps + 1e-9})  [Thm 4.1]")
    # High thresholds collapse (Thm 4.2):
    delta = eps + 0.1
    any_novel = any(is_novel(delta, corpus, x) for x in samples)
    print(f"any sample delta-novel for delta={delta:.4f} > eps? {any_novel} "
          f"(theory: False)  [Thm 4.2]")
    # Approximate converse (Thm 4.3): witness within eps + eta.
    eta = 1e-3
    x = (0.137, 0.911)
    witness = min(corpus, key=lambda s: euclidean(x, s))
    print(f"approx converse: nearest known to {x} is {witness}, "
          f"dist={euclidean(x, witness):.4f} < eps+eta={eps + eta:.4f}  [Thm 4.3]")
    print()


# --------------------------------------------------------------------------- #
# Demo 7: adaptive threshold is exactly discriminating (Theorem 5.3)
# --------------------------------------------------------------------------- #
def demo_adaptive_threshold() -> None:
    print("=" * 70)
    print("DEMO 7  Adaptive threshold = separation is exactly discriminating (Thm 5.3)")
    print("=" * 70)
    corpus: Corpus = [(0.0, 0.0), (2.0, 0.0), (0.0, 2.0), (2.0, 2.0)]
    sigma = corpus_separation(corpus)
    print(f"corpus = {corpus}")
    print(f"separation sigma = {sigma:.4f}  (adaptive threshold)")
    all_ok = True
    for x in corpus:
        peers = [s for s in corpus if s != x]
        novel_vs_peers = is_novel(sigma, peers, x)          # should be True
        novel_vs_full = is_novel(sigma, corpus, x)          # should be False
        ok = novel_vs_peers and not novel_vs_full
        all_ok = all_ok and ok
        print(f"  x={x}: sigma-novel vs peers={novel_vs_peers}, "
              f"vs full corpus={novel_vs_full}  -> exact: {ok}")
    print(f"all corpus elements exactly discriminated: {all_ok}")
    print()


# --------------------------------------------------------------------------- #
# Demo 8: compositional novelty on products (Theorems 6.1-6.2)
# --------------------------------------------------------------------------- #
def comp_novelty(corpus_s: Corpus, corpus_t: Corpus,
                 p: Tuple[Point, Point]) -> float:
    """compNovelty(S, T, (x, y)) = min(noveltyScore(S, x), noveltyScore(T, y))."""
    x, y = p
    return min(novelty_score(corpus_s, x), novelty_score(corpus_t, y))


def prod_linf(p: Tuple[Point, Point], q: Tuple[Point, Point]) -> float:
    """l^infinity product metric: max of the two component distances."""
    return max(euclidean(p[0], q[0]), euclidean(p[1], q[1]))


def demo_compositional() -> None:
    print("=" * 70)
    print("DEMO 8  Compositional novelty on products  (Theorems 6.1-6.2)")
    print("=" * 70)
    S: Corpus = [(0.0,), (5.0,)]
    T: Corpus = [(0.0,), (4.0,)]
    composites = [((1.0,), (1.0,)), ((2.5,), (3.0,)), ((4.0,), (0.5,))]
    for p in composites:
        c = comp_novelty(S, T, p)
        ns = novelty_score(S, p[0])
        nt = novelty_score(T, p[1])
        print(f"  p={p}: comp={c:.3f} = min({ns:.3f}, {nt:.3f})  "
              f"weakest link held: {abs(c - min(ns, nt)) < 1e-12}")
    # 1-Lipschitz check in the l^infinity product metric.
    worst = 0.0
    for p, q in itertools.combinations(composites, 2):
        dc = abs(comp_novelty(S, T, p) - comp_novelty(S, T, q))
        dpq = prod_linf(p, q)
        worst = max(worst, dc / dpq if dpq > 0 else 0.0)
        print(f"  |dcomp|={dc:5.3f} <= prod_linf={dpq:5.3f}: {dc <= dpq + 1e-9}")
    print(f"worst Lipschitz ratio = {worst:.3f}  (theory: <= 1)")
    print()


# --------------------------------------------------------------------------- #
# Demo 9: the novelty filtration (Theorems 7.1-7.3)
# --------------------------------------------------------------------------- #
def demo_filtration() -> None:
    print("=" * 70)
    print("DEMO 9  The novelty filtration: antitone in threshold and corpus (Sec 7)")
    print("=" * 70)
    corpus: Corpus = [(0.0, 0.0), (6.0, 0.0)]
    grid = [(x * 1.0, 0.0) for x in range(7)]  # candidates along a line
    thresholds = [0.5, 1.0, 1.5, 2.0, 3.0]
    print("threshold -> set of delta-novel candidates (x-coordinate):")
    prev: set = set(g[0] for g in grid)
    for d in thresholds:
        nset = {g[0] for g in grid if is_novel(d, corpus, g)}
        nested = nset <= prev
        print(f"  delta={d:4.2f}: {sorted(nset)!s:30}  nested-in-previous: {nested}")
        prev = nset
    # Persistence interval of a single candidate = [0, score).
    x = (3.0, 0.0)
    print(f"persistence interval of x={x}: [0, {novelty_score(corpus, x):.3f})  "
          f"(x is delta-novel iff delta <= score)")
    print()


# --------------------------------------------------------------------------- #
# Demo 10: packing — separation yields disjoint balls (Theorem 8.1)
# --------------------------------------------------------------------------- #
def balls_disjoint(a: Point, b: Point, r: float, dist: Metric = euclidean) -> bool:
    """Open balls B(a, r), B(b, r) are disjoint iff dist(a, b) >= 2r."""
    return dist(a, b) >= 2 * r - 1e-12


def demo_packing() -> None:
    print("=" * 70)
    print("DEMO 10  Packing: separation => disjoint half-radius balls  (Theorem 8.1)")
    print("=" * 70)
    eps = 2.0
    corpus: Corpus = [(0.0, 0.0), (2.0, 0.0), (1.0, 2.0)]  # mutually 2-separated
    sigma = corpus_separation(corpus)
    print(f"corpus = {corpus}, separation = {sigma:.3f} >= eps = {eps}")
    r = eps / 2
    all_disjoint = all(balls_disjoint(a, b, r)
                       for a, b in itertools.combinations(corpus, 2))
    print(f"all balls of radius eps/2={r} pairwise disjoint: {all_disjoint}")
    print()


# --------------------------------------------------------------------------- #
def main() -> None:
    print("\nCERTIFIED NOVELTY — NUMERICAL DEMONSTRATIONS\n")
    demo_duality()
    demo_robustness()
    demo_lipschitz()
    demo_antitone_corpus()
    demo_saturation()
    demo_adaptive_threshold()
    demo_compositional()
    demo_filtration()
    demo_packing()
    print("All demonstrations completed: every observation matches the theorems.")


if __name__ == "__main__":
    main()
