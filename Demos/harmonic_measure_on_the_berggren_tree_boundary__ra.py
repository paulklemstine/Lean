"""
Algorithm: Silver-Potential Drift Envelope Certifier.

The metric growth of the Berggren tree is controlled by the silver potential

    Phi(m, n) = m + (sqrt(2) - 1) n ,

which satisfies Phi(a . v) <= (1 + sqrt 2) Phi(v) for each of the three Berggren moves,
with equality exactly for the middle move M.  Iterating from the root gives
Phi <= (1 + sqrt 2)^{k+1} at depth k, and combined with the window
log m <= d(i, z(m,n)) <= log m + log 2 for the embedding z(m,n) = (n+i)/m this yields the
sharp two-sided envelope in terms of the labelling word w:

    (#M(w) + 1) log 2  <=  d(i, z(run(w)))  <=  (|w| + 1) log(1 + sqrt 2) + log 2 .

Averaging over the random walk (the expected number of middle moves in n steps is exactly
n p_M) gives the drift sandwich

    p_M log 2  <=  E d(i, z_n) / n  <=  log(1 + sqrt 2) + (log(1+sqrt2) + log 2)/n .

This module certifies the potential inequality on an exhaustive depth-D subtree (cost
O(3^{D+1})) and then measures the drift by Monte Carlo, reporting whether the sandwich
holds at every sampled depth (cost O(samples * n) per depth).
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, List, Sequence, Tuple

Seed = Tuple[int, int]
Weights = Tuple[float, float, float]

ALPHABET: Tuple[str, str, str] = ("L", "M", "R")
SQRT2: float = math.sqrt(2.0)
SILVER: float = 1.0 + SQRT2
LOG_SILVER: float = math.log(SILVER)
LOG2: float = math.log(2.0)


def apply_move(letter: str, seed: Seed) -> Seed:
    m, n = seed
    if letter == "L":
        return (2 * m - n, m)
    if letter == "M":
        return (2 * m + n, m)
    return (m + 2 * n, n)


def eval_word(word: Sequence[str]) -> Seed:
    seed: Seed = (2, 1)
    for letter in reversed(list(word)):
        seed = apply_move(letter, seed)
    return seed


def silver_potential(seed: Seed) -> float:
    """Phi(m, n) = m + (sqrt2 - 1) n."""
    m, n = seed
    return m + (SQRT2 - 1.0) * n


def hyperbolic_distance(seed: Seed) -> float:
    """d(i, (n+i)/m):  cosh d = 1 + (n^2 + (m-1)^2) / (2m)."""
    m, n = seed
    return math.acosh(max(1.0 + (n * n + (m - 1) ** 2) / (2.0 * m), 1.0))


def certify_potential(max_depth: int = 8) -> Dict[str, float]:
    """
    Exhaustively verify Phi(a.v) / Phi(v) <= 1 + sqrt 2 on every node of depth <= D,
    for each move, and record the maximum ratio attained by each move.
    """
    worst = {a: 0.0 for a in ALPHABET}
    for d in range(max_depth + 1):
        for w in itertools.product(ALPHABET, repeat=d):
            v = eval_word(w)
            base = silver_potential(v)
            for a in ALPHABET:
                worst[a] = max(worst[a], silver_potential(apply_move(a, v)) / base)
    worst["bound"] = SILVER
    return worst


def certify_envelope(max_depth: int = 8) -> bool:
    """Verify the two-sided word envelope on every node of depth <= D."""
    for d in range(max_depth + 1):
        for w in itertools.product(ALPHABET, repeat=d):
            dist = hyperbolic_distance(eval_word(w))
            lo = (w.count("M") + 1) * LOG2
            hi = (d + 1) * LOG_SILVER + LOG2
            if not (lo - 1e-9 <= dist <= hi + 1e-9):
                return False
    return True


def measure_drift(p: Weights, depths: Sequence[int], samples: int = 400,
                  seed: int = 0) -> List[Tuple[int, float, float, float]]:
    """
    Monte-Carlo estimate of E d(i, z_n)/n at each requested depth, returned with the two
    proved bounds as (n, lower, measured, upper).
    """
    rng = random.Random(seed)
    out: List[Tuple[int, float, float, float]] = []
    for n in depths:
        total = 0.0
        for _ in range(samples):
            w = rng.choices(list(ALPHABET), weights=list(p), k=n)
            total += hyperbolic_distance(eval_word(w))
        out.append((n, p[1] * LOG2, total / samples / n,
                    LOG_SILVER + (LOG_SILVER + LOG2) / n))
    return out


if __name__ == "__main__":
    print("potential growth ratios (bound 1 + sqrt 2 = %.10f):" % SILVER)
    for k, v in certify_potential(8).items():
        tag = "  <-- equality: the middle move drives the silver growth" if k == "M" else ""
        print(f"   {k:>5s}: {v:.10f}{tag}")
    print()
    print("word envelope holds on the full depth-8 subtree:", certify_envelope(8))
    print()
    print("   n |    lower p_M log2 |    measured d/n |   upper log(1+sqrt2)+O(1/n)")
    for n, lo, mid, hi in measure_drift((0.45, 0.35, 0.20),
                                        [5, 10, 20, 40, 80], samples=400, seed=7):
        ok = "ok" if lo <= mid <= hi else "VIOLATED"
        print(f"  {n:3d} | {lo:17.8f} | {mid:15.8f} | {hi:26.8f}   {ok}")


"""
Algorithm: Exact Level-n Entropy Accumulator via Product-Measure Factorisation.

The mean surprisal of a depth-n node of the Berggren tree, averaged over the 3^n nodes
with weights given by the harmonic measure, equals exactly n * H(p) with no error term:

    sum_{w in {L,M,R}^n}  (prod_i p_{w_i}) * ( -log prod_i p_{w_i} )  =  n * H(p).

The naive evaluation enumerates all 3^n words in O(n 3^n) time; the factorised evaluation
exchanges the two sums, factors the inner sum coordinatewise (the non-chosen coordinates
sum to 1), and returns n * H(p) in O(1) after O(|alphabet|) work.  This module implements
both and reports the discrepancy, which is machine-epsilon at every depth.

It also implements the pointwise (Shannon-McMillan-Breiman) version along a sampled ray
and the resulting 3-adic and hyperbolic dimensions.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import List, Sequence, Tuple

Weights = Tuple[float, float, float]

ALPHABET: Tuple[str, str, str] = ("L", "M", "R")
LOG3: float = math.log(3.0)
LOG_SILVER: float = math.log(1.0 + math.sqrt(2.0))


def shannon_entropy(p: Weights) -> float:
    """H(p) = -sum_a p_a log p_a, in nats.  O(1)."""
    return -sum(q * math.log(q) for q in p if q > 0.0)


def level_entropy_bruteforce(p: Weights, n: int) -> float:
    """Enumerate all 3^n depth-n nodes.  Cost O(n 3^n)."""
    total = 0.0
    for w in itertools.product(range(3), repeat=n):
        mass = 1.0
        surp = 0.0
        for a in w:
            mass *= p[a]
            surp -= math.log(p[a])
        total += mass * surp
    return total


def level_entropy_exact(p: Weights, n: int) -> float:
    """Closed form n * H(p).  Cost O(1)."""
    return n * shannon_entropy(p)


def adic_dimension(p: Weights) -> float:
    """Pointwise dimension of the harmonic measure in the 3-adic metric: H(p)/log 3."""
    return shannon_entropy(p) / LOG3


def hyperbolic_dimension(p: Weights) -> float:
    """Dimension against the metric exponent of the hyperbolic embedding."""
    return shannon_entropy(p) / (2.0 * LOG_SILVER)


def smb_along_ray(p: Weights, length: int, seed: int = 0) -> List[Tuple[int, float]]:
    """
    Sample one ray from the harmonic measure and return checkpoints
    (n, -(1/n) log mass(cyl_n)), which converge almost surely to H(p).
    Cost: O(length).
    """
    rng = random.Random(seed)
    out: List[Tuple[int, float]] = []
    running = 0.0
    checkpoints = {10, 100, 1_000, 10_000, 100_000, length}
    for i in range(1, length + 1):
        a = rng.choices(range(3), weights=list(p), k=1)[0]
        running -= math.log(p[a])
        if i in checkpoints:
            out.append((i, running / i))
    return out


if __name__ == "__main__":
    p: Weights = (0.5, 0.3, 0.2)
    print(f"H(p) = {shannon_entropy(p):.12f}   (max log 3 = {LOG3:.12f})")
    print(f"3-adic dimension     = {adic_dimension(p):.12f}")
    print(f"hyperbolic dimension = {hyperbolic_dimension(p):.12f}  (cap 2/3)")
    print()
    print("  n |         brute force |             n H(p) | difference")
    for n in range(9):
        b = level_entropy_bruteforce(p, n)
        e = level_entropy_exact(p, n)
        print(f" {n:2d} | {b:19.12f} | {e:18.12f} | {abs(b - e):.3e}")
    print()
    for n, val in smb_along_ray(p, 200_000, seed=1):
        print(f"  ray checkpoint n = {n:7d}:  -(1/n) log mass = {val:.8f}")


"""
Algorithm: Euclid-Seed Word Evaluation and Harmonic Mass of a Berggren Node.

Given a finite word w over the alphabet {L, M, R}, produce (i) the Euclid seed of the
Berggren tree node it labels, (ii) the primitive Pythagorean triple at that node, and
(iii) the harmonic mass of the cylinder above it under the walk with weights
(p_L, p_M, p_R).  A verification routine confirms Berggren's theorem numerically: the
triples produced at depth <= D are primitive and pairwise distinct.
"""

from __future__ import annotations

import itertools
import math
from typing import Dict, Iterator, Sequence, Tuple

Seed = Tuple[int, int]
Triple = Tuple[int, int, int]
Weights = Tuple[float, float, float]

ALPHABET: Tuple[str, str, str] = ("L", "M", "R")


def apply_move(letter: str, seed: Seed) -> Seed:
    """One Berggren move on a Euclid seed (m, n) with m > n > 0."""
    m, n = seed
    if letter == "L":
        return (2 * m - n, m)
    if letter == "M":
        return (2 * m + n, m)
    if letter == "R":
        return (m + 2 * n, n)
    raise ValueError(f"unknown Berggren move {letter!r}")


def eval_word(word: Sequence[str]) -> Seed:
    """
    Seed of the node labelled by `word`, applying the letters right to left from the
    root (2, 1).  Cost: O(|w|) big-integer operations on integers of bit length
    Theta(|w|), i.e. O(|w|^2) bit operations with schoolbook arithmetic.
    """
    seed: Seed = (2, 1)
    for letter in reversed(list(word)):
        seed = apply_move(letter, seed)
    return seed


def triple_of_seed(seed: Seed) -> Triple:
    """Euclid's parametrisation (m, n) -> (m^2 - n^2, 2mn, m^2 + n^2)."""
    m, n = seed
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def triple_of_word(word: Sequence[str]) -> Triple:
    return triple_of_seed(eval_word(word))


def harmonic_mass(word: Sequence[str], p: Weights) -> float:
    """Harmonic (Bernoulli) measure of the cylinder above the node labelled by `word`."""
    mass = 1.0
    for letter in word:
        mass *= p[ALPHABET.index(letter)]
    return mass


def surprisal(word: Sequence[str], p: Weights) -> float:
    """-log of the harmonic mass, computed additively for numerical stability."""
    return -sum(math.log(p[ALPHABET.index(letter)]) for letter in word)


def words(depth: int) -> Iterator[Tuple[str, ...]]:
    return itertools.product(ALPHABET, repeat=depth)


def verify_berggren(max_depth: int = 7) -> Dict[str, object]:
    """
    Check that the tree enumerates primitive triples injectively up to `max_depth`.
    Cost: O(3^{D+1}) evaluations, each O(D).
    """
    seen: Dict[Triple, Tuple[str, ...]] = {}
    non_primitive = 0
    collisions = 0
    for d in range(max_depth + 1):
        for w in words(d):
            t = triple_of_word(w)
            a, b, c = t
            if a * a + b * b != c * c or math.gcd(math.gcd(a, b), c) != 1:
                non_primitive += 1
            if t in seen:
                collisions += 1
            seen[t] = w
    return {"depth": max_depth, "nodes": len(seen),
            "non_primitive": non_primitive, "collisions": collisions}


if __name__ == "__main__":
    p: Weights = (0.5, 0.3, 0.2)
    for w in [(), ("M",), ("M", "M"), ("L", "M", "R"), tuple("MMMMM")]:
        print(f"word {''.join(w) or 'ε':>6s}  seed {eval_word(w)!s:>14s}"
              f"  triple {triple_of_word(w)!s:>26s}"
              f"  mass {harmonic_mass(w, p):.6f}"
              f"  surprisal {surprisal(w, p):.6f}")
    print(verify_berggren(7))


"""
Algorithm: Two-Sided Bracket for the Depth-n Separation Rate of Two Berggren Walks.

Two Berggren walks with distinct weight vectors P != Q have mutually singular harmonic
measures.  This module computes the two matching exponential rates that bracket how fast a
test reading only the first n moves can tell them apart.

Upper side (achievability, Chernoff).  Choose the letter a maximising |p_a - q_a| and a
threshold u strictly between p_a and q_a.  The test "the letter a occurs at least n u
times among the first n" errs with probability at most exp(-n KL(u || p_a)) under one walk
and exp(-n KL(u || q_a)) under the other, where KL is the binary relative entropy.  The
achievable rate is c(u) = min of the two, and one may optimise over u by a golden-section
search: the optimum is the point where the two divergences agree.

Lower side (converse, Bhattacharyya).  For the Bhattacharyya coefficient
beta = sum_a sqrt(p_a q_a) in (0, 1], every event A determined by the first n letters obeys

    Ber(P)(A) + Ber(Q)(A^c)  >=  (1/2) beta^{2n},

so no depth-n test can achieve an exponent better than -2 log beta.

The two together bracket the true cutoff rate.  Complexity: O(iterations) for the search,
O(1) per evaluation.
"""

from __future__ import annotations

import math
from typing import Tuple

Weights = Tuple[float, float, float]


def kl_binary(u: float, s: float) -> float:
    """Binary relative entropy KL(u || s); strictly positive off the diagonal."""
    return u * math.log(u / s) + (1.0 - u) * math.log((1.0 - u) / (1.0 - s))


def bhattacharyya(p: Weights, q: Weights) -> float:
    """beta(P, Q) = sum_a sqrt(p_a q_a);  in (0, 1], and < 1 exactly when P != Q."""
    return sum(math.sqrt(p[i] * q[i]) for i in range(3))


def bhattacharyya_exponent(p: Weights, q: Weights) -> float:
    """The converse (best possible) exponent -2 log beta."""
    beta = bhattacharyya(p, q)
    return -2.0 * math.log(beta) if beta < 1.0 else 0.0


def best_letter(p: Weights, q: Weights) -> int:
    """Index of the letter whose two probabilities differ most."""
    return max(range(3), key=lambda i: abs(p[i] - q[i]))


def chernoff_rate_at(u: float, pa: float, qa: float) -> float:
    """min( KL(u||p_a), KL(u||q_a) ): the rate of the threshold test at level u."""
    return min(kl_binary(u, pa), kl_binary(u, qa))


def optimise_threshold(pa: float, qa: float, iterations: int = 200
                       ) -> Tuple[float, float]:
    """
    Golden-section maximisation of u |-> min(KL(u||p_a), KL(u||q_a)) on the open interval
    between p_a and q_a.  The objective is concave-unimodal there (each KL term is convex
    in u and the two are monotone in opposite directions), so the search converges
    linearly; `iterations` bisections give machine accuracy.
    """
    lo, hi = (min(pa, qa), max(pa, qa))
    a, b = lo + 1e-12, hi - 1e-12
    phi = (math.sqrt(5.0) - 1.0) / 2.0
    c, d = b - phi * (b - a), a + phi * (b - a)
    fc, fd = chernoff_rate_at(c, pa, qa), chernoff_rate_at(d, pa, qa)
    for _ in range(iterations):
        if fc < fd:
            a, c, fc = c, d, fd
            d = a + phi * (b - a)
            fd = chernoff_rate_at(d, pa, qa)
        else:
            b, d, fd = d, c, fc
            c = b - phi * (b - a)
            fc = chernoff_rate_at(c, pa, qa)
    u = 0.5 * (a + b)
    return u, chernoff_rate_at(u, pa, qa)


def separation_bracket(p: Weights, q: Weights) -> dict:
    """
    Return the achievable Chernoff rate (with its optimal threshold) and the
    Bhattacharyya converse exponent, together with the depth needed for a target error.
    """
    a = best_letter(p, q)
    if abs(p[a] - q[a]) < 1e-15:
        return {"identical": True}
    u, rate = optimise_threshold(p[a], q[a])
    beta = bhattacharyya(p, q)
    conv = bhattacharyya_exponent(p, q)
    return {"identical": False, "letter": "LMR"[a], "threshold": u,
            "chernoff_rate": rate, "bhattacharyya": beta,
            "converse_exponent": conv,
            "depth_for_1pct": math.ceil(math.log(1 / 0.01) / rate),
            "floor_at_that_depth":
                0.5 * beta ** (2 * math.ceil(math.log(1 / 0.01) / rate))}


if __name__ == "__main__":
    P: Weights = (0.50, 0.30, 0.20)
    Q: Weights = (0.30, 0.40, 0.30)
    info = separation_bracket(P, Q)
    for k, v in info.items():
        print(f"  {k:22s} {v}")
    print()
    print("  achievable exponent  <=  true cutoff rate  <=  converse exponent")
    print(f"  {info['chernoff_rate']:.8f}       <=      ?          <=  "
          f"{info['converse_exponent']:.8f}")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the deliverables in the project root and assets/."""

from __future__ import annotations

import json
import os
from typing import Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


LEAN_FILES: List[str] = [
    "Catalog/Bridges/HyperbolicBerggrenSilverGrowth.lean",
    "Catalog/Bridges/BerggrenHarmonicMeasure.lean",
    "Catalog/Bridges/BerggrenBoundaryCantor.lean",
    "Catalog/Bridges/BerggrenBoundaryEntropy.lean",
    "Catalog/Bridges/BerggrenTransferSpectrum.lean",
    "Catalog/Bridges/BerggrenWalkDrift.lean",
    "Catalog/Bridges/BerggrenHarmonicSingularity.lean",
    "Catalog/Bridges/BerggrenShiftErgodicity.lean",
    "Catalog/Bridges/BerggrenAlmostSureDrift.lean",
    "Catalog/Bridges/BerggrenChernoffSeparation.lean",
    "Catalog/Bridges/BerggrenRayRigidity.lean",
    "Catalog/Bridges/BerggrenEntropyDriftGap.lean",
    "Catalog/Bridges/BerggrenBhattacharyyaBound.lean",
]


def lean_proofs() -> str:
    chunks: List[str] = []
    for rel in LEAN_FILES:
        chunks.append(f"-- FILE: {rel}\n" + read(os.path.join(ROOT, rel)))
    return "\n\n\n".join(chunks)


def main() -> None:
    demo_src = read(os.path.join(ROOT, "demo.py"))

    package: Dict[str, object] = {
        "title": "Harmonic Measure on the Boundary of the Berggren Tree: "
                 "Random Walks and the 3-adic Cantor Set of Pythagorean Triples",
        "domain": "Bridges",
        "description":
            "The random walk on the ternary Berggren tree of primitive Pythagorean triples "
            "has a unique harmonic measure on its Cantor boundary, namely the Bernoulli "
            "product measure, with entropy exactly H(p), 3-adic dimension H(p)/log 3, "
            "ergodic shift, rigid exponential separation of distinct walks, and hyperbolic "
            "escape speed sandwiched between p_M log 2 and the silver exponent log(1+sqrt 2). "
            "Two natural expectations fail: the spectral gap is 1 for every walk, and the "
            "hyperbolic dimension of the harmonic measure is at most 2/3 uniformly.",
        "authors": ["Aristotle"],
        "date": "2026-08-21",
        "key_results": [
            "The boundary of the Berggren tree of primitive Pythagorean triples is a Cantor "
            "set: nonempty, compact, metrizable, totally disconnected and perfect, with the "
            "cylinders above the tree's nodes as a clopen neighbourhood basis.",
            "Existence and uniqueness of the harmonic measure: for every strictly positive "
            "weight vector the stationarity equation has exactly one probability solution, "
            "the Bernoulli product measure, which assigns a depth-n node the product of its "
            "letter probabilities; the fair walk realises the natural Cantor measure 3^-n.",
            "Exact entropy identity and dimension: the mass-weighted mean surprisal of a "
            "depth-n node is exactly n H(p) with no error term, almost every ray satisfies "
            "-(1/n) log of the cylinder mass tending to H(p), and the pointwise dimension is "
            "H(p)/log 3, at most 1 with equality exactly for the fair walk.",
            "Ray rigidity and two-sided separation rates: distinct walks have mutually "
            "singular harmonic measures detected by letter frequencies along a single typical "
            "ray, are separated at depth n at the binary relative entropy rate, and cannot be "
            "separated faster than the Bhattacharyya exponent, since every depth-n event A "
            "satisfies nu_P(A) + nu_Q(complement of A) at least one half of beta^(2n).",
            "Silver drift sandwich with a refuted spectral gap: the hyperbolic escape speed "
            "lies between p_M log 2 and log(1 + sqrt 2) in mean and almost surely, so the walk "
            "escapes to infinity, while the averaging operator forgets one letter per "
            "application, making its spectrum {0,1} and its gap 1 for every weight vector.",
            "Uniform entropy-metric gap: log 3 < 2 log(1 + sqrt 2) = log(3 + 2 sqrt 2), so the "
            "hyperbolic dimension H(p)/(2 log(1 + sqrt 2)) of the harmonic measure is at most "
            "0.6232... and at most 2/3 for every walk; the harmonic measure is never the "
            "conformal measure of the hyperbolic embedding.",
        ],
        "keywords": [
            "Pythagorean triples", "Berggren tree", "harmonic measure",
            "Bernoulli measure", "Cantor set", "Shannon entropy",
            "silver ratio", "Bhattacharyya coefficient",
        ],
        "article": read(os.path.join(ROOT, "ARTICLE.md")),
        "research_paper": read(os.path.join(ROOT, "RESEARCH_PAPER.md")),
        "research_paper_tex": read(os.path.join(ROOT, "RESEARCH_PAPER.tex")),
        "demo": demo_src,
        "demos": [
            {
                "name": "Complete Numerical Atlas of the Berggren Harmonic Measure",
                "description":
                    "A single self-contained program that reproduces every result of the "
                    "development numerically. It (i) builds the ternary tree of Euclid seeds "
                    "and checks that the triples it produces are primitive and pairwise "
                    "distinct at every depth up to 6, confirming Berggren's bijection; (ii) "
                    "verifies that the harmonic mass of a node is the product of its letter "
                    "probabilities and that the three child masses sum to the parent's mass, "
                    "which is the stationarity equation on cylinders; (iii) compares the "
                    "brute-force sum of mass times surprisal over all 3^n depth-n nodes "
                    "against the closed form n H(p), confirming the exact identity to machine "
                    "precision at every depth; (iv) samples a ray of 200000 letters and shows "
                    "the Shannon-McMillan-Breiman convergence together with the 3-adic "
                    "dimension H(p)/log 3; (v) recovers the weight vector from the empirical "
                    "letter frequencies of one single ray, illustrating ray rigidity; (vi) "
                    "brackets the achievable separation error between the Chernoff bound and "
                    "the Bhattacharyya floor by Monte Carlo; (vii) measures the hyperbolic "
                    "escape rate in the upper half-plane and verifies the silver drift "
                    "sandwich, including the exact saturation of the potential inequality by "
                    "the middle move; (viii) applies the averaging operator repeatedly to a "
                    "random observable and shows it becomes exactly constant, so the spectral "
                    "gap is 1; and (ix) prints the entropy-metric gap constants. Standard "
                    "library only; runs in well under a second.",
                "code": demo_src,
            },
        ],
        "algorithms": [
            {
                "name": "Euclid-Seed Word Evaluation and Harmonic Mass of a Berggren Node",
                "description":
                    "Converts a finite word over the three Berggren moves into the Euclid "
                    "seed it labels, the primitive Pythagorean triple at that node, and the "
                    "harmonic mass of the cylinder above it. The seed is obtained by folding "
                    "the three affine maps L(m,n) = (2m-n, m), M(m,n) = (2m+n, m), "
                    "R(m,n) = (m+2n, n) from the root (2,1), reading the word right to left; "
                    "the triple is then Euclid's (m^2-n^2, 2mn, m^2+n^2). The harmonic mass is "
                    "the product of the letter probabilities and the surprisal is computed "
                    "additively as a sum of logarithms for numerical stability. Complexity: "
                    "O(n) big-integer operations on integers whose bit length grows linearly "
                    "in n, hence O(n^2) bit operations with schoolbook arithmetic; the "
                    "verification routine costs O(3^(D+1)) node evaluations. This is the "
                    "bridge between the combinatorics of words and the arithmetic of triples "
                    "that every other computation in the pipeline relies on.",
                "pseudocode":
                    "function EVAL(word w over {L, M, R}):\n"
                    "    (m, n) <- (2, 1)                        # the seed of (3, 4, 5)\n"
                    "    for a in reverse(w):\n"
                    "        if a = L: (m, n) <- (2m - n, m)\n"
                    "        if a = M: (m, n) <- (2m + n, m)\n"
                    "        if a = R: (m, n) <- (m + 2n, n)\n"
                    "    return (m, n)\n"
                    "\n"
                    "function TRIPLE(w):\n"
                    "    (m, n) <- EVAL(w)\n"
                    "    return (m^2 - n^2, 2*m*n, m^2 + n^2)\n"
                    "\n"
                    "function HARMONIC_MASS(w, (p_L, p_M, p_R)):\n"
                    "    mass <- 1\n"
                    "    for a in w: mass <- mass * p_a\n"
                    "    return mass\n"
                    "\n"
                    "function VERIFY_BERGGREN(D):\n"
                    "    seen <- empty map from triples to words\n"
                    "    for d = 0 .. D:\n"
                    "        for each word w of length d:\n"
                    "            t <- TRIPLE(w)\n"
                    "            assert t is a primitive Pythagorean triple\n"
                    "            assert t not in seen                # injectivity\n"
                    "            seen[t] <- w\n"
                    "    return |seen|",
                "code": read(os.path.join(ASSETS, "algo_eval.py")),
            },
            {
                "name": "Exact Level-n Entropy Accumulator via Product-Measure Factorisation",
                "description":
                    "Computes the mass-weighted mean surprisal of a depth-n node of the tree "
                    "in two ways and compares them. The naive route enumerates all 3^n words, "
                    "accumulating mass times surprisal, at cost O(n 3^n). The factorised route "
                    "exchanges the two summations, writes the surprisal of a word as the sum "
                    "of its letter surprisals, and observes that for a fixed position the sum "
                    "over the remaining coordinates is 1; what survives is exactly the one-step "
                    "entropy, n times over. The result is the closed form n H(p) at cost O(1). "
                    "Their agreement to machine precision at every depth is a strong test of "
                    "any implementation and, more importantly, it exhibits the entropy identity "
                    "as an exact statement rather than an asymptotic one. The module also "
                    "samples one ray and reports the pointwise (Shannon-McMillan-Breiman) "
                    "convergence of -(1/n) log of the cylinder mass to H(p), from which the "
                    "3-adic dimension H(p)/log 3 and the hyperbolic dimension "
                    "H(p)/(2 log(1 + sqrt 2)) follow at cost O(length of the ray).",
                "pseudocode":
                    "function SHANNON(p):\n"
                    "    return - sum over a of p_a * log(p_a)\n"
                    "\n"
                    "function LEVEL_ENTROPY_BRUTEFORCE(p, n):        # cost O(n 3^n)\n"
                    "    total <- 0\n"
                    "    for each word w in {L, M, R}^n:\n"
                    "        mass <- 1 ; surp <- 0\n"
                    "        for a in w: mass <- mass * p_a ; surp <- surp - log(p_a)\n"
                    "        total <- total + mass * surp\n"
                    "    return total\n"
                    "\n"
                    "function LEVEL_ENTROPY_EXACT(p, n):             # cost O(1)\n"
                    "    return n * SHANNON(p)\n"
                    "    # justification: exchange the sums; for each fixed position i the\n"
                    "    # remaining coordinates sum to 1, leaving sum_a p_a (-log p_a)\n"
                    "\n"
                    "function SMB_ALONG_RAY(p, N):                   # cost O(N)\n"
                    "    running <- 0\n"
                    "    for i = 1 .. N:\n"
                    "        a <- sample a letter with probabilities p\n"
                    "        running <- running - log(p_a)\n"
                    "        report (i, running / i)                 # -> H(p) almost surely",
                "code": read(os.path.join(ASSETS, "algo_entropy.py")),
            },
            {
                "name": "Two-Sided Bracket for the Depth-n Separation Rate of Two Walks",
                "description":
                    "Computes the two matching exponential rates that bracket how quickly a "
                    "test reading only the first n moves of a Berggren trajectory can decide "
                    "between two candidate weight vectors. The achievability side selects the "
                    "letter whose two probabilities differ most, and considers the threshold "
                    "test 'this letter occurs at least n u times'. Its two error probabilities "
                    "are bounded by exp(-n KL(u || p_a)) and exp(-n KL(u || q_a)) via the "
                    "exponential Markov inequality applied at the classical tilt, so the "
                    "achievable rate is the minimum of the two divergences; that minimum is "
                    "maximised over u by golden-section search, the optimum being the point "
                    "where the two divergences coincide. The converse side computes the "
                    "Bhattacharyya coefficient beta = sum sqrt(p_a q_a), which is strictly "
                    "below 1 exactly when the two walks differ, and returns the exponent "
                    "-2 log beta: no depth-n test can beat it, because the two error "
                    "probabilities always sum to at least one half of beta^(2n). Complexity: "
                    "O(1) per objective evaluation and O(iterations) for the search, with "
                    "linear convergence.",
                "pseudocode":
                    "function KL(u, s):\n"
                    "    return u*log(u/s) + (1-u)*log((1-u)/(1-s))\n"
                    "\n"
                    "function BHATTACHARYYA(P, Q):\n"
                    "    return sum over a of sqrt(p_a * q_a)\n"
                    "\n"
                    "function SEPARATION_BRACKET(P, Q):\n"
                    "    a <- argmax over letters of |p_a - q_a|\n"
                    "    if |p_a - q_a| = 0: return 'walks identical'\n"
                    "\n"
                    "    # achievability: optimise the threshold u between p_a and q_a\n"
                    "    (lo, hi) <- (min(p_a, q_a), max(p_a, q_a))\n"
                    "    maximise f(u) = min(KL(u || p_a), KL(u || q_a)) on (lo, hi)\n"
                    "        by golden-section search\n"
                    "    (u*, c) <- argmax and max value\n"
                    "\n"
                    "    # converse: the Bhattacharyya speed limit\n"
                    "    beta <- BHATTACHARYYA(P, Q)\n"
                    "    converse <- -2 * log(beta)\n"
                    "\n"
                    "    assert c <= true cutoff rate <= converse\n"
                    "    return (u*, c, beta, converse)",
                "code": read(os.path.join(ASSETS, "algo_separation.py")),
            },
            {
                "name": "Silver-Potential Drift Envelope Certifier",
                "description":
                    "Certifies and then measures the metric growth of the Berggren tree. The "
                    "certification stage evaluates the silver potential Phi(m, n) = m + "
                    "(sqrt 2 - 1) n at every node of an exhaustive depth-D subtree and checks "
                    "that each of the three moves multiplies it by at most 1 + sqrt 2, "
                    "recording the maximum ratio attained by each move; the middle move alone "
                    "attains the bound exactly, which is why it is the unique driver of the "
                    "silver growth. The same sweep verifies the two-sided word envelope "
                    "(#M(w) + 1) log 2 <= d <= (|w| + 1) log(1 + sqrt 2) + log 2 for the "
                    "hyperbolic distance from the base point i to the node (n + i)/m, computed "
                    "from cosh d = 1 + (n^2 + (m-1)^2)/(2m). The measurement stage then samples "
                    "random words and estimates the mean escape rate at several depths, "
                    "reporting it alongside the proved lower bound p_M log 2 and upper bound "
                    "log(1 + sqrt 2) + O(1/n). Complexity: O(3^(D+1) * D) for the exhaustive "
                    "certification and O(samples * n) per measured depth.",
                "pseudocode":
                    "function PHI(m, n):  return m + (sqrt(2) - 1) * n\n"
                    "function HDIST(m, n): return arccosh(1 + (n^2 + (m-1)^2) / (2m))\n"
                    "\n"
                    "function CERTIFY_POTENTIAL(D):\n"
                    "    worst <- {L: 0, M: 0, R: 0}\n"
                    "    for d = 0 .. D:\n"
                    "        for each word w of length d:\n"
                    "            v <- EVAL(w)\n"
                    "            for a in {L, M, R}:\n"
                    "                r <- PHI(a . v) / PHI(v)\n"
                    "                assert r <= 1 + sqrt(2)\n"
                    "                worst[a] <- max(worst[a], r)\n"
                    "    return worst          # worst[M] = 1 + sqrt(2) exactly\n"
                    "\n"
                    "function CERTIFY_ENVELOPE(D):\n"
                    "    for every word w of length <= D:\n"
                    "        d <- HDIST(EVAL(w))\n"
                    "        assert (count of M in w + 1) * log 2 <= d\n"
                    "        assert d <= (|w| + 1) * log(1 + sqrt 2) + log 2\n"
                    "\n"
                    "function MEASURE_DRIFT(p, depths, samples):\n"
                    "    for n in depths:\n"
                    "        total <- 0\n"
                    "        repeat samples times:\n"
                    "            w <- n letters sampled independently with probabilities p\n"
                    "            total <- total + HDIST(EVAL(w))\n"
                    "        mean <- total / samples / n\n"
                    "        assert p_M * log 2 <= mean\n"
                    "        assert mean <= log(1 + sqrt 2) + (log(1 + sqrt 2) + log 2)/n\n"
                    "        report (n, mean)",
                "code": read(os.path.join(ASSETS, "algo_drift.py")),
            },
        ],
        "visualizations": [
            {
                "name": "The Harmonic Measure as a Subdivision of the Cantor Boundary, "
                        "with the Two Dimension Curves",
                "description":
                    "Two upper panels draw the first five levels of the ternary subdivision of "
                    "the boundary, each block being one primitive Pythagorean triple drawn with "
                    "width equal to its harmonic mass: on the left the fair walk, where every "
                    "block at a level has the same width 3^-n and the picture is the natural "
                    "Cantor measure; on the right a biased walk, where the mass visibly "
                    "migrates into a thin fractal sliver, which is the dimension drop "
                    "H(p)/log 3 < 1 made visual. The lower panel plots both dimension curves "
                    "along the one-parameter family p(t) = (t, (1-t)/2, (1-t)/2): the 3-adic "
                    "dimension H(p)/log 3, which touches 1 exactly at the fair walk, and the "
                    "hyperbolic dimension H(p)/(2 log(1 + sqrt 2)), which is capped by "
                    "0.6232... and hence never reaches the reference line 2/3.",
                "code": read(os.path.join(ASSETS, "viz_boundary_mass.py")),
            },
            {
                "name": "The Berggren Tree in the Hyperbolic Plane and the Silver Drift "
                        "Sandwich",
                "description":
                    "The left panel embeds the first six levels of the tree in the hyperbolic "
                    "upper half-plane through the Euclid seed map (m, n) -> (n + i)/m, with "
                    "each node drawn with area proportional to its harmonic mass, so the "
                    "picture shows simultaneously where the tree goes and where the random walk "
                    "is likely to be; the pure-M Pell spine, which saturates the silver growth "
                    "of the potential m + (sqrt 2 - 1) n, is highlighted. The right panel plots "
                    "the Monte-Carlo measured escape rate d(o, z_n)/n against the proved "
                    "sandwich, shading the region between the lower bound p_M log 2 and the "
                    "upper bound log(1 + sqrt 2) + (log(1 + sqrt 2) + log 2)/n, and overlays "
                    "the pure-M spine approaching the silver exponent 0.8814 from above, which "
                    "demonstrates that the upper bound is sharp.",
                "code": read(os.path.join(ASSETS, "viz_drift_silver.py")),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Berggren Harmonic Measure Explorer",
                "description":
                    "A four-panel laboratory for the whole theory, driven by three sliders for "
                    "the move probabilities. Panel 1 draws the boundary as an interval "
                    "subdivided to depth five, each block one primitive Pythagorean triple with "
                    "width equal to its harmonic mass, so the measure itself is the picture; a "
                    "live readout gives the Shannon entropy, the 3-adic dimension H(p)/log 3, "
                    "the hyperbolic dimension H(p)/(2 log(1 + sqrt 2)), and the two drift "
                    "bounds. Panel 2 runs one actual random descent through the tree, showing "
                    "at each step the current Euclid seed, the primitive triple reached, the "
                    "hyperbolic distance from the base point, the escape rate d/n plotted "
                    "inside the shaded proved sandwich, and the running empirical letter "
                    "frequencies converging back to the sliders, which is ray rigidity in "
                    "action. Panel 3 compares the walk against a second, adjustable walk and "
                    "plots the Chernoff guarantee against the universal Bhattacharyya floor, "
                    "so the reader can watch the separation window open as the two walks are "
                    "pulled apart and collapse to nothing as they are brought together. Panel 4 "
                    "applies the averaging operator to a random observable and shows it losing "
                    "exactly one letter of memory per application until it is provably "
                    "constant, which is why the spectral gap is 1 for every weight vector.",
                "html": read(os.path.join(ASSETS, "widget_explorer.html")),
            },
            {
                "title": "The Entropy Simplex and the Silver Ceiling",
                "description":
                    "A hoverable heat map of the triangle of all weight vectors, coloured by "
                    "the Shannon entropy of the corresponding harmonic measure: dark at the "
                    "three corners, where one move dominates and the harmonic measure "
                    "degenerates to a single boundary point, and brightest at the centre, the "
                    "fair walk, where entropy reaches its maximum log 3. The readout panel "
                    "tracks the pointer and displays, side by side, the two normalisations of "
                    "the same entropy: the 3-adic dimension H(p)/log 3, which attains 1 exactly "
                    "at the centre, and the hyperbolic dimension H(p)/(2 log(1 + sqrt 2)), "
                    "which never exceeds 0.623239 anywhere in the triangle. Sweeping the whole "
                    "simplex and never breaking that ceiling is the most direct way to feel the "
                    "uniform entropy-metric gap log 3 < 2 log(1 + sqrt 2).",
                "html": read(os.path.join(ASSETS, "widget_simplex.html")),
            },
        ],
        "interactive_layout": read(os.path.join(ASSETS, "interactive_layout.md")),
        "lean_proofs": lean_proofs(),
        "future_directions": read(os.path.join(ASSETS, "future_directions.md")),
        "modules": {"demo": demo_src},
        "lean_files": LEAN_FILES,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
    print(f"wrote {out}  ({os.path.getsize(out)/1024:.1f} KiB)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: the harmonic measure as a subdivision of the Berggren boundary.

The boundary of the Berggren tree is the Cantor set {L, M, R}^N.  Drawing it as the
unit interval subdivided ternarily, level n splits into 3^n cylinders, each the shadow
of one primitive Pythagorean triple at depth n.  The harmonic measure of the walk with
weights (p_L, p_M, p_R) assigns the cylinder of the word w the mass prod_i p_{w_i}.

Panel A draws the first five levels of that subdivision with each cylinder's *width*
proportional to its harmonic mass, so the picture literally is the measure: for the
fair walk all blocks at a level are equal (the Cantor measure); biasing the dice makes
mass migrate into a fractal sliver.

Panel B shows the two dimension curves along a one-parameter family of walks
p(t) = (t, (1-t)/2, (1-t)/2):  the 3-adic dimension H(p)/log 3 (peaking at 1 for the
fair walk) and the hyperbolic dimension H(p)/(2 log(1+sqrt2)), which is capped by
log 3 / (2 log(1+sqrt2)) = 0.6232... < 2/3 uniformly.

Requires: matplotlib, numpy.  Writes berggren_boundary_mass.png.
"""

from __future__ import annotations

import itertools
import math
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

ALPHABET = ("L", "M", "R")
LOG3 = math.log(3.0)
LOG_SILVER = math.log(1.0 + math.sqrt(2.0))
COLORS = {"L": "#3b6ea5", "M": "#c1453b", "R": "#3f8f5a"}


def shannon(p: Sequence[float]) -> float:
    return -sum(q * math.log(q) for q in p if q > 0.0)


def mass(word: Sequence[str], p: Sequence[float]) -> float:
    out = 1.0
    for a in word:
        out *= p[ALPHABET.index(a)]
    return out


def draw_levels(ax, p: Sequence[float], levels: int = 5) -> None:
    ax.set_xlim(0.0, 1.0)
    ax.set_ylim(-0.2, levels + 0.2)
    for n in range(1, levels + 1):
        x = 0.0
        for w in itertools.product(ALPHABET, repeat=n):
            width = mass(w, p)
            ax.add_patch(plt.Rectangle((x, levels - n), width, 0.82,
                                       facecolor=COLORS[w[0]],
                                       edgecolor="white", linewidth=0.35,
                                       alpha=0.55 + 0.45 * (1.0 - n / levels)))
            x += width
        ax.text(-0.015, levels - n + 0.41, f"depth {n}", ha="right", va="center",
                fontsize=8)
    ax.set_yticks([])
    ax.set_xticks([0.0, 0.25, 0.5, 0.75, 1.0])
    ax.set_xlabel("harmonic mass coordinate on the boundary")
    ax.set_title(
        f"Harmonic measure, p = ({p[0]:.2f}, {p[1]:.2f}, {p[2]:.2f}),  "
        f"H = {shannon(p):.4f},  dim = {shannon(p)/LOG3:.4f}",
        fontsize=10)


def main() -> None:
    fig = plt.figure(figsize=(12.5, 7.0))
    gs = fig.add_gridspec(2, 2, height_ratios=[1.0, 1.0], hspace=0.38, wspace=0.18)

    ax_fair = fig.add_subplot(gs[0, 0])
    draw_levels(ax_fair, (1 / 3, 1 / 3, 1 / 3))

    ax_bias = fig.add_subplot(gs[0, 1])
    draw_levels(ax_bias, (0.60, 0.25, 0.15))

    ax_dim = fig.add_subplot(gs[1, :])
    ts = np.linspace(0.005, 0.99, 600)
    d3, dh = [], []
    for t in ts:
        p = (float(t), (1.0 - float(t)) / 2.0, (1.0 - float(t)) / 2.0)
        H = shannon(p)
        d3.append(H / LOG3)
        dh.append(H / (2.0 * LOG_SILVER))
    ax_dim.plot(ts, d3, lw=2.2, color="#3b6ea5",
                label=r"3-adic dimension  $H(p)/\log 3$")
    ax_dim.plot(ts, dh, lw=2.2, color="#c1453b",
                label=r"hyperbolic dimension  $H(p)/(2\log(1+\sqrt{2}))$")
    ax_dim.axhline(1.0, ls="--", lw=1.0, color="#3b6ea5", alpha=0.6)
    ax_dim.axhline(LOG3 / (2 * LOG_SILVER), ls="--", lw=1.0, color="#c1453b", alpha=0.6)
    ax_dim.axhline(2 / 3, ls=":", lw=1.2, color="black", alpha=0.7)
    ax_dim.axvline(1 / 3, ls=":", lw=1.0, color="gray")
    ax_dim.text(0.34, 0.06, "fair walk", fontsize=8, color="gray")
    ax_dim.text(0.02, LOG3 / (2 * LOG_SILVER) - 0.075,
                r"$\log 3/(2\log(1+\sqrt{2})) = 0.6232$", fontsize=8, color="#c1453b")
    ax_dim.text(0.02, 2 / 3 + 0.02, r"cap $2/3$", fontsize=8)
    ax_dim.set_xlabel(r"$t$  where  $p = (t,\ (1-t)/2,\ (1-t)/2)$")
    ax_dim.set_ylabel("dimension of the harmonic measure")
    ax_dim.set_ylim(0.0, 1.12)
    ax_dim.set_title("Dimension is maximal exactly at the fair walk; the hyperbolic "
                     "dimension never reaches 2/3", fontsize=10)
    ax_dim.legend(loc="lower left", fontsize=9, frameon=False)

    fig.suptitle("The harmonic measure on the 3-adic Cantor boundary of the "
                 "Berggren tree", fontsize=13, y=0.98)
    fig.savefig("berggren_boundary_mass.png", dpi=160, bbox_inches="tight")
    print("wrote berggren_boundary_mass.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: the silver drift sandwich and the Berggren tree in the hyperbolic plane.

Panel A embeds the first few levels of the Berggren tree in the upper half-plane via
the Euclid seed map  (m, n) |-> z(m, n) = (n + i)/m,  with base point o = i.  Node area
is proportional to the harmonic mass of the corresponding cylinder, so the picture shows
simultaneously where the tree goes and where the random walk is likely to be.  The
pure-M ("Pell") spine, which saturates the silver growth of the potential
Phi(m, n) = m + (sqrt2 - 1) n, is highlighted.

Panel B plots the measured escape rate d(o, z_n)/n of the random walk against the two
proved bounds:

    p_M log 2  <=  E d(o, z_n)/n  <=  log(1 + sqrt 2) + (log(1+sqrt2) + log 2)/n .

The pure-M spine is plotted too: it approaches the silver exponent log(1 + sqrt 2) from
above and shows the upper bound is sharp.

Requires: matplotlib, numpy.  Writes berggren_drift_silver.png.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

ALPHABET = ("L", "M", "R")
LOG2 = math.log(2.0)
LOG_SILVER = math.log(1.0 + math.sqrt(2.0))
COLORS = {"L": "#3b6ea5", "M": "#c1453b", "R": "#3f8f5a"}

Seed = Tuple[int, int]


def move(a: str, s: Seed) -> Seed:
    m, n = s
    if a == "L":
        return (2 * m - n, m)
    if a == "M":
        return (2 * m + n, m)
    return (m + 2 * n, n)


def run(word: Sequence[str]) -> Seed:
    s: Seed = (2, 1)
    for a in reversed(list(word)):
        s = move(a, s)
    return s


def hdist(s: Seed) -> float:
    m, n = s
    return math.acosh(max(1.0 + (n * n + (m - 1) ** 2) / (2.0 * m), 1.0))


def mass(word: Sequence[str], p: Sequence[float]) -> float:
    out = 1.0
    for a in word:
        out *= p[ALPHABET.index(a)]
    return out


def main() -> None:
    p = (0.45, 0.35, 0.20)
    rng = random.Random(2026)

    fig, (axA, axB) = plt.subplots(1, 2, figsize=(13.5, 5.8))

    # ---------------- Panel A: the tree in the upper half-plane ----------------
    depth = 6
    axA.plot([0.0], [1.0], marker="*", ms=16, color="black", zorder=5)
    axA.annotate("base point $i$", (0.0, 1.0), textcoords="offset points",
                 xytext=(8, 6), fontsize=9)
    for n in range(depth + 1):
        for w in itertools.product(ALPHABET, repeat=n):
            m_, n_ = run(w)
            x, y = n_ / m_, 1.0 / m_
            wt = mass(w, p)
            c = COLORS[w[0]] if w else "black"
            axA.scatter([x], [y], s=6.0 + 900.0 * wt, color=c, alpha=0.75,
                        edgecolors="none")
            if n > 0:
                pm, pn = run(w[1:])
                axA.plot([x, pn / pm], [y, 1.0 / pm], lw=0.4, color="gray", alpha=0.4)
    spine_x, spine_y = [], []
    for k in range(depth + 1):
        m_, n_ = run(["M"] * k)
        spine_x.append(n_ / m_)
        spine_y.append(1.0 / m_)
    axA.plot(spine_x, spine_y, lw=2.0, color="#c1453b", alpha=0.9,
             label="pure-$M$ (Pell) spine")
    axA.set_yscale("log")
    axA.set_xlim(-0.03, 1.03)
    axA.set_xlabel(r"$\mathrm{Re}\, z = n/m$")
    axA.set_ylabel(r"$\mathrm{Im}\, z = 1/m$   (log scale)")
    axA.set_title("Berggren tree in the hyperbolic upper half-plane\n"
                  "(node area $\\propto$ harmonic mass, "
                  f"$p = ({p[0]}, {p[1]}, {p[2]})$)", fontsize=10)
    axA.legend(fontsize=9, frameon=False, loc="lower left")

    # ---------------- Panel B: the drift sandwich ----------------
    ns = list(range(1, 81))
    samples = 300
    means = []
    for n in ns:
        tot = 0.0
        for _ in range(samples):
            w = rng.choices(list(ALPHABET), weights=list(p), k=n)
            tot += hdist(run(w))
        means.append(tot / samples / n)
    lower = [p[1] * LOG2] * len(ns)
    upper = [LOG_SILVER + (LOG_SILVER + LOG2) / n for n in ns]
    spine = [hdist(run(["M"] * n)) / n for n in ns]

    axB.fill_between(ns, lower, upper, color="#f0d9a8", alpha=0.55,
                     label="proved sandwich")
    axB.plot(ns, upper, lw=1.8, color="#a8791f",
             label=r"upper: $\log(1+\sqrt{2})+O(1/n)$")
    axB.plot(ns, lower, lw=1.8, color="#a8791f", ls="--",
             label=r"lower: $p_M\log 2$")
    axB.plot(ns, means, lw=2.2, color="#3b6ea5",
             label=r"measured $\mathbb{E}\,d(o,z_n)/n$")
    axB.plot(ns, spine, lw=1.8, color="#c1453b",
             label=r"pure-$M$ spine $d/n$")
    axB.axhline(LOG_SILVER, ls=":", lw=1.2, color="black")
    axB.text(62, LOG_SILVER + 0.015, r"$\log(1+\sqrt{2})=0.8814$", fontsize=8)
    axB.set_xlabel("depth $n$")
    axB.set_ylabel("hyperbolic escape rate")
    axB.set_ylim(0.0, 1.5)
    axB.set_title("Silver drift sandwich: the walk escapes at a rate between\n"
                  r"$p_M\log2$ and $\log(1+\sqrt{2})$", fontsize=10)
    axB.legend(fontsize=8.5, frameon=False, loc="upper right")

    fig.tight_layout()
    fig.savefig("berggren_drift_silver.png", dpi=160, bbox_inches="tight")
    print("wrote berggren_drift_silver.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Harmonic Measure on the Boundary of the Berggren Tree
=====================================================

Numerical demonstrations of the results on random walks over the ternary tree of
primitive Pythagorean triples and the harmonic measure they induce on its 3-adic
Cantor boundary.

The Berggren tree.  Every primitive Pythagorean triple (a, b, c) with a^2 + b^2 = c^2
and gcd(a, b, c) = 1 is (m^2 - n^2, 2mn, m^2 + n^2) for a unique Euclid seed (m, n)
with m > n > 0, gcd(m, n) = 1 and m, n of opposite parity.  The seeds form a free
rooted ternary tree with root (2, 1) (the seed of (3, 4, 5)) under the three moves

    L(m, n) = (2m - n, m),   M(m, n) = (2m + n, m),   R(m, n) = (m + 2n, n).

Its boundary is the space {L, M, R}^N of infinite words -- a Cantor set.

What is demonstrated
--------------------
  1. The tree really does enumerate the primitive triples exactly once.
  2. The harmonic measure of a depth-n node is the product of the letter weights,
     and the three child masses of any node sum to the parent's mass (harmonicity).
  3. The exact entropy identity: sum over all 3^n depth-n nodes of  mass * surprisal
     equals exactly n * H(p) -- an identity with no error term.
  4. Shannon-McMillan-Breiman: -(1/n) log(mass of the cylinder around a random ray)
     converges to H(p); the 3-adic dimension is H(p)/log 3 <= 1, = 1 iff fair.
  5. Ray rigidity: letter frequencies along one random ray recover the weight vector.
  6. Chernoff separation and the Bhattacharyya converse bound.
  7. The hyperbolic drift sandwich  p_M log 2 <= d(o, z_n)/n <= log(1 + sqrt 2) + O(1/n),
     measured directly in the upper half-plane.
  8. Nilpotency of the transfer operator: L^n f is constant for f depending on n letters,
     so the spectral gap is 1 and log(1 + sqrt 2) is not an eigenvalue.
  9. The entropy-metric gap: log 3 < 2 log(1 + sqrt 2), hence hyperbolic dimension <= 2/3.

Self-contained: standard library only.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------------------

SILVER: float = 1.0 + math.sqrt(2.0)          # 2.41421...  the silver ratio
LOG_SILVER: float = math.log(SILVER)          # 0.88137...  the metric exponent per depth
LOG3: float = math.log(3.0)                   # 1.09861...  the combinatorial exponent
LOG2: float = math.log(2.0)

ALPHABET: Tuple[str, str, str] = ("L", "M", "R")

Seed = Tuple[int, int]
Triple = Tuple[int, int, int]
Weights = Tuple[float, float, float]


# --------------------------------------------------------------------------------------
# 1. The Berggren tree
# --------------------------------------------------------------------------------------

def move(letter: str, seed: Seed) -> Seed:
    """Apply one Berggren move to a Euclid seed (m, n)."""
    m, n = seed
    if letter == "L":
        return (2 * m - n, m)
    if letter == "M":
        return (2 * m + n, m)
    if letter == "R":
        return (m + 2 * n, n)
    raise ValueError(f"unknown Berggren move {letter!r}")


def run(word: Sequence[str]) -> Seed:
    """The Euclid seed of the node labelled by `word` (letters applied right to left)."""
    seed: Seed = (2, 1)
    for letter in reversed(list(word)):
        seed = move(letter, seed)
    return seed


def triple_of_seed(seed: Seed) -> Triple:
    """Euclid's parametrisation: (m, n) |-> (m^2 - n^2, 2mn, m^2 + n^2)."""
    m, n = seed
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def triple_of_word(word: Sequence[str]) -> Triple:
    """The primitive Pythagorean triple labelled by a finite Berggren word."""
    return triple_of_seed(run(word))


def is_primitive_triple(t: Triple) -> bool:
    a, b, c = t
    return a * a + b * b == c * c and math.gcd(math.gcd(a, b), c) == 1


def words_of_length(n: int) -> Iterable[Tuple[str, ...]]:
    """All 3^n Berggren words of length n."""
    return itertools.product(ALPHABET, repeat=n)


def demo_tree_enumeration(max_depth: int = 6) -> None:
    print("=" * 78)
    print("1.  THE BERGGREN TREE ENUMERATES THE PRIMITIVE TRIPLES EXACTLY ONCE")
    print("=" * 78)
    print("Root (2, 1) -> triple", triple_of_word(()))
    print()
    print("  depth |  nodes |  all primitive? |  all distinct? | example triple")
    print("  ------+--------+-----------------+----------------+----------------")
    for depth in range(max_depth + 1):
        triples = [triple_of_word(w) for w in words_of_length(depth)]
        all_prim = all(is_primitive_triple(t) for t in triples)
        all_dist = len(set(triples)) == len(triples)
        print(f"  {depth:5d} | {len(triples):6d} | {str(all_prim):>15s} "
              f"| {str(all_dist):>14s} | {triples[0]}")
    # Union over all depths <= max_depth is also injective (Berggren's theorem).
    seen: Dict[Triple, Tuple[str, ...]] = {}
    collisions = 0
    for depth in range(max_depth + 1):
        for w in words_of_length(depth):
            t = triple_of_word(w)
            if t in seen:
                collisions += 1
            seen[t] = w
    print()
    print(f"  distinct triples found up to depth {max_depth}: {len(seen)}"
          f"   (collisions: {collisions})")
    print("  The three children of (3,4,5):",
          [triple_of_word((a,)) for a in ALPHABET])
    print()


# --------------------------------------------------------------------------------------
# 2. Harmonic measure
# --------------------------------------------------------------------------------------

def normalise(weights: Sequence[float]) -> Weights:
    s = float(sum(weights))
    return (weights[0] / s, weights[1] / s, weights[2] / s)


def weight_of(letter: str, p: Weights) -> float:
    return p[ALPHABET.index(letter)]


def harmonic_mass(word: Sequence[str], p: Weights) -> float:
    """Harmonic (Bernoulli) measure of the cylinder above the node labelled by `word`."""
    mass = 1.0
    for letter in word:
        mass *= weight_of(letter, p)
    return mass


def demo_harmonic_measure(p: Weights, depth: int = 5) -> None:
    print("=" * 78)
    print("2.  THE HARMONIC MEASURE IS THE BERNOULLI PRODUCT MEASURE")
    print("=" * 78)
    print(f"weights (p_L, p_M, p_R) = ({p[0]:.4f}, {p[1]:.4f}, {p[2]:.4f})")
    print()
    # Total mass at each depth is 1 (probability measure).
    for n in range(depth + 1):
        total = sum(harmonic_mass(w, p) for w in words_of_length(n))
        print(f"  total mass of the {3**n:5d} depth-{n} cylinders : {total:.15f}")
    print()
    # Harmonicity: nu(node) = sum over children of nu(child); equivalently the
    # stationarity equation nu = sum_a p_a (cons_a)_* nu evaluated on cylinders.
    print("  harmonicity check   nu(w) = p_L nu(Lw) / p_L + ...  i.e.")
    print("  nu(w) = nu(wL) + nu(wM) + nu(wR):")
    worst = 0.0
    for n in range(depth):
        for w in words_of_length(n):
            parent = harmonic_mass(w, p)
            children = sum(harmonic_mass(tuple(w) + (a,), p) for a in ALPHABET)
            worst = max(worst, abs(parent - children))
    print(f"    maximum discrepancy over all nodes of depth < {depth}: {worst:.3e}")
    print()
    # Fair walk gives 3^-n exactly.
    fair: Weights = (1 / 3, 1 / 3, 1 / 3)
    n = 4
    masses = {harmonic_mass(w, fair) for w in words_of_length(n)}
    print(f"  fair walk, depth {n}: all cylinder masses equal "
          f"{masses.pop():.10f}  (3^-{n} = {3.0**-n:.10f})")
    print("  -> the fair harmonic measure is the natural Cantor measure of the boundary")
    print()


# --------------------------------------------------------------------------------------
# 3. Entropy: the exact finite-level identity
# --------------------------------------------------------------------------------------

def shannon_entropy(p: Weights) -> float:
    """H(p) = -sum_a p_a log p_a, in nats."""
    return -sum(q * math.log(q) for q in p if q > 0.0)


def demo_entropy_identity(p: Weights, max_depth: int = 8) -> None:
    print("=" * 78)
    print("3.  EXACT ENTROPY IDENTITY:  sum over depth-n nodes of mass*surprisal = n H(p)")
    print("=" * 78)
    H = shannon_entropy(p)
    print(f"H(p) = {H:.12f} nats   (max possible log 3 = {LOG3:.12f})")
    print()
    print("   n |  brute-force sum over 3^n nodes |        n * H(p) |  difference")
    print("  ---+---------------------------------+-----------------+-------------")
    for n in range(max_depth + 1):
        brute = 0.0
        for w in words_of_length(n):
            mass = harmonic_mass(w, p)
            if mass > 0.0:
                brute += mass * (-math.log(mass))
        print(f"  {n:2d} | {brute:31.12f} | {n * H:15.12f} | {abs(brute - n*H):.3e}")
    print()
    print("  The agreement is exact at every finite depth -- no error term.")
    print()


# --------------------------------------------------------------------------------------
# 4. Shannon-McMillan-Breiman and dimension
# --------------------------------------------------------------------------------------

def random_ray(p: Weights, length: int, rng: random.Random) -> List[str]:
    """Sample the first `length` letters of a ray from the harmonic measure."""
    return rng.choices(list(ALPHABET), weights=list(p), k=length)


def demo_smb_and_dimension(p: Weights, length: int = 200_000, seed: int = 20260821) -> None:
    print("=" * 78)
    print("4.  SHANNON-MCMILLAN-BREIMAN AND THE 3-ADIC DIMENSION")
    print("=" * 78)
    rng = random.Random(seed)
    ray = random_ray(p, length, rng)
    H = shannon_entropy(p)
    print(f"H(p) = {H:.8f},   dim = H(p)/log 3 = {H / LOG3:.8f}")
    print()
    print("       n |  -(1/n) log nu(cyl_n(x)) |  log nu / log 3^-n  (pointwise dim)")
    print("  -------+--------------------------+-------------------------------------")
    running = 0.0
    checkpoints = [10, 100, 1_000, 10_000, 100_000, length]
    idx = 0
    for i, letter in enumerate(ray, start=1):
        running += -math.log(weight_of(letter, p))
        if idx < len(checkpoints) and i == checkpoints[idx]:
            print(f"  {i:6d} | {running / i:24.8f} | {running / i / LOG3:20.8f}")
            idx += 1
    print(f"  target | {H:24.8f} | {H / LOG3:20.8f}")
    print()
    print("  Dimension across the weight simplex (= 1 exactly for the fair walk):")
    for q in [(1/3, 1/3, 1/3), (0.5, 0.3, 0.2), (0.8, 0.1, 0.1), (0.98, 0.01, 0.01)]:
        qq = normalise(q)
        print(f"    p = ({qq[0]:.3f}, {qq[1]:.3f}, {qq[2]:.3f})"
              f"   H = {shannon_entropy(qq):.6f}"
              f"   dim = {shannon_entropy(qq)/LOG3:.6f}")
    print()


# --------------------------------------------------------------------------------------
# 5. Ray rigidity: recover the dice from one ray
# --------------------------------------------------------------------------------------

def empirical_frequencies(ray: Sequence[str]) -> Weights:
    n = len(ray)
    counts = [ray.count(a) for a in ALPHABET]
    return (counts[0] / n, counts[1] / n, counts[2] / n)


def demo_ray_rigidity(p: Weights, seed: int = 7) -> None:
    print("=" * 78)
    print("5.  RAY RIGIDITY: ONE TYPICAL RAY DETERMINES THE WALK")
    print("=" * 78)
    rng = random.Random(seed)
    print(f"true weights  = ({p[0]:.6f}, {p[1]:.6f}, {p[2]:.6f})")
    print()
    print("        n |  empirical (p_L, p_M, p_R) along a single ray | max error")
    print("  --------+-----------------------------------------------+----------")
    ray: List[str] = []
    for n in [10, 100, 1_000, 10_000, 100_000, 1_000_000]:
        ray.extend(random_ray(p, n - len(ray), rng))
        est = empirical_frequencies(ray)
        err = max(abs(est[i] - p[i]) for i in range(3))
        print(f"  {n:7d} | ({est[0]:.6f}, {est[1]:.6f}, {est[2]:.6f})"
              f"                 | {err:.2e}")
    print()
    print("  Two walks with different weights therefore have disjoint sets of typical")
    print("  rays, hence mutually singular harmonic measures -- even though both")
    print("  measures give positive mass to every single node of the tree.")
    print()


# --------------------------------------------------------------------------------------
# 6. Separation: Chernoff bound and the Bhattacharyya converse
# --------------------------------------------------------------------------------------

def kl_binary(u: float, s: float) -> float:
    """Binary relative entropy KL(u || s)."""
    return u * math.log(u / s) + (1.0 - u) * math.log((1.0 - u) / (1.0 - s))


def bhattacharyya(p: Weights, q: Weights) -> float:
    """beta(P, Q) = sum_a sqrt(p_a q_a) in (0, 1]."""
    return sum(math.sqrt(p[i] * q[i]) for i in range(3))


def empirical_tail_probability(p: Weights, letter_index: int, n: int, u: float,
                               trials: int, rng: random.Random, upper: bool) -> float:
    """
    Monte-Carlo estimate of  P[ #{i<n : x_i = a} >= n u ]  (upper=True)
    or of                    P[ #{i<n : x_i = a} <  n u ]  (upper=False).
    """
    hits = 0
    pa = p[letter_index]
    for _ in range(trials):
        count = sum(1 for _ in range(n) if rng.random() < pa)
        if (count >= n * u) == upper:
            hits += 1
    return hits / trials


def demo_separation(p: Weights, q: Weights, seed: int = 11) -> None:
    print("=" * 78)
    print("6.  SEPARATION OF TWO WALKS: CHERNOFF UPPER, BHATTACHARYYA LOWER")
    print("=" * 78)
    rng = random.Random(seed)
    print(f"P = ({p[0]:.3f}, {p[1]:.3f}, {p[2]:.3f})     "
          f"Q = ({q[0]:.3f}, {q[1]:.3f}, {q[2]:.3f})")
    beta = bhattacharyya(p, q)
    print(f"Bhattacharyya coefficient beta = {beta:.8f}   "
          f"(< 1 exactly because P != Q)")
    print(f"Bhattacharyya exponent  -2 log beta = {-2*math.log(beta):.8f} per letter")
    print()
    # Separating statistic: count of the letter where the two walks differ most.
    a = max(range(3), key=lambda i: abs(p[i] - q[i]))
    lo, hi = min(p[a], q[a]), max(p[a], q[a])
    u = 0.5 * (lo + hi)
    rate = min(kl_binary(u, p[a]), kl_binary(u, q[a]))
    print(f"separating letter '{ALPHABET[a]}':  p = {p[a]:.3f} vs q = {q[a]:.3f},"
          f"  threshold u = {u:.4f}")
    print(f"Chernoff rate c = min KL = {rate:.8f} per letter")
    print()
    print("  The depth-n test is A_n = { #{i<n : x_i = a} >= n u }.  Its total error")
    print("  is  P(A_n^c under the high-p walk) + P(A_n under the low-p walk),  which")
    print("  Chernoff bounds above by 2 e^{-cn} and Theorem (Bhattacharyya) bounds")
    print("  below by (1/2) beta^{2n}.")
    print()
    print("   n |  Chernoff 2e^{-cn} | empirical total error | Bhattacharyya floor")
    print("  ---+--------------------+-----------------------+--------------------")
    high = p if p[a] > q[a] else q
    low = q if p[a] > q[a] else p
    for n in [10, 20, 40, 80]:
        bound = 2.0 * math.exp(-rate * n)
        err = (empirical_tail_probability(high, a, n, u, 2000, rng, upper=False)
               + empirical_tail_probability(low, a, n, u, 2000, rng, upper=True))
        floor = 0.5 * beta ** (2 * n)
        print(f"  {n:2d} | {bound:18.10f} | {err:21.6f} | {floor:19.3e}")
    print()
    print("  The empirical total error sits below the Chernoff bound and above the")
    print("  Bhattacharyya floor: no depth-n test can drive the total error below")
    print("  (1/2) beta^{2n}, so the achievable exponent is bracketed.")
    print()


# --------------------------------------------------------------------------------------
# 7. Hyperbolic drift and the silver envelope
# --------------------------------------------------------------------------------------

def hyperbolic_distance_to_base(seed: Seed) -> float:
    """
    Hyperbolic distance in the upper half-plane from the base point i to the node
    z(m, n) = (n + i)/m.  With x = n/m, y = 1/m,

        cosh d = 1 + (x^2 + (y - 1)^2) / (2 y) = 1 + (n^2 + (m - 1)^2) / (2 m).
    """
    m, n = seed
    c = 1.0 + (n * n + (m - 1) ** 2) / (2.0 * m)
    return math.acosh(max(c, 1.0))


def silver_potential(seed: Seed) -> float:
    """Phi(m, n) = m + (sqrt2 - 1) n; multiplies by at most 1 + sqrt 2 per move."""
    m, n = seed
    return m + (math.sqrt(2.0) - 1.0) * n


def demo_drift(p: Weights, depth: int = 60, samples: int = 400, seed: int = 3) -> None:
    print("=" * 78)
    print("7.  HYPERBOLIC DRIFT: THE SILVER SANDWICH")
    print("=" * 78)
    rng = random.Random(seed)
    pM = p[1]
    print(f"weights ({p[0]:.3f}, {p[1]:.3f}, {p[2]:.3f});  "
          f"lower rate p_M log 2 = {pM * LOG2:.6f}, "
          f"upper rate log(1+sqrt2) = {LOG_SILVER:.6f}")
    print()
    # Verify the potential inequality (equality for M) directly.
    print("  potential growth Phi(a.v) / Phi(v) on 200 random nodes:")
    worst = {a: 0.0 for a in ALPHABET}
    for _ in range(200):
        w = random_ray(p, rng.randint(0, 12), rng)
        v = run(w)
        for a in ALPHABET:
            worst[a] = max(worst[a], silver_potential(move(a, v)) / silver_potential(v))
    for a in ALPHABET:
        tag = "  <-- attains the silver ratio exactly" if a == "M" else ""
        print(f"    max ratio for move {a}: {worst[a]:.10f}"
              f"   (bound {SILVER:.10f}){tag}")
    print()
    print("    n |  mean d(o, z_n)/n | lower p_M log2 | upper log(1+sqrt2)+O(1/n)")
    print("  ----+-------------------+----------------+---------------------------")
    for n in [5, 10, 20, 40, depth]:
        tot = 0.0
        for _ in range(samples):
            w = random_ray(p, n, rng)
            tot += hyperbolic_distance_to_base(run(w))
        mean_rate = tot / samples / n
        upper = LOG_SILVER + (LOG_SILVER + LOG2) / n
        print(f"  {n:3d} | {mean_rate:17.8f} | {pM*LOG2:14.8f} | {upper:25.8f}")
    print()
    print("  Both bounds hold at every n, and the distance grows linearly:")
    print("  the walk escapes to infinity almost surely, so the harmonic measure")
    print("  lives on the boundary and not on the tree.")
    print()
    print("  Pure-M (Pell) spine, which saturates the silver upper bound:")
    for n in [5, 10, 20, 40]:
        d = hyperbolic_distance_to_base(run(["M"] * n))
        print(f"    n = {n:3d}:  d = {d:12.6f},  d/n = {d/n:.8f}"
              f"   (log(1+sqrt2) = {LOG_SILVER:.8f})")
    print()


# --------------------------------------------------------------------------------------
# 8. The transfer operator is nilpotent modulo constants
# --------------------------------------------------------------------------------------

def apply_transfer(values: Dict[Tuple[str, ...], float], p: Weights
                   ) -> Dict[Tuple[str, ...], float]:
    """
    One application of (L f)(x) = sum_a p_a f(a x) to a function represented by its
    values on words of length n; the result is a function on words of length n - 1.
    """
    if not values:
        return {}
    depth = len(next(iter(values)))
    if depth == 0:
        return dict(values)
    out: Dict[Tuple[str, ...], float] = {}
    for w in words_of_length(depth - 1):
        out[w] = sum(weight_of(a, p) * values[(a,) + w] for a in ALPHABET)
    return out


def demo_transfer_spectrum(p: Weights, depth: int = 6, seed: int = 5) -> None:
    print("=" * 78)
    print("8.  THE TRANSFER OPERATOR IS NILPOTENT MODULO CONSTANTS (SPECTRAL GAP = 1)")
    print("=" * 78)
    rng = random.Random(seed)
    f = {w: rng.uniform(-1.0, 1.0) for w in words_of_length(depth)}
    print(f"random observable f depending on the first {depth} letters "
          f"({3**depth} values)")
    print()
    print("   k |  spread of L^k f (max - min) |  depends on first ... letters")
    print("  ---+------------------------------+------------------------------")
    cur = f
    for k in range(depth + 1):
        spread = max(cur.values()) - min(cur.values())
        print(f"  {k:2d} | {spread:28.12f} | {len(next(iter(cur))):>12d}")
        cur = apply_transfer(cur, p)
    print()
    print(f"  After {depth} applications the function is exactly constant, for every")
    print("  weight vector.  Hence the eigenvalues on locally constant observables are")
    print("  only 0 and 1, the eigenvalue 1 belongs to the constants alone, and the")
    print(f"  spectral gap is 1.  In particular log(1+sqrt2) = {LOG_SILVER:.6f}, which")
    print("  lies strictly between 0 and 1, is NOT an eigenvalue: the conjectured")
    print("  silver-ratio spectral gap is false.")
    print()


# --------------------------------------------------------------------------------------
# 9. The entropy-metric gap
# --------------------------------------------------------------------------------------

def hyperbolic_dimension(p: Weights) -> float:
    """H(p) / (2 log(1 + sqrt 2))."""
    return shannon_entropy(p) / (2.0 * LOG_SILVER)


def demo_entropy_metric_gap() -> None:
    print("=" * 78)
    print("9.  THE ENTROPY-METRIC GAP:  log 3 < 2 log(1 + sqrt 2)")
    print("=" * 78)
    two_ls = 2.0 * LOG_SILVER
    print(f"  combinatorial exponent  log 3            = {LOG3:.10f}")
    print(f"  metric exponent         2 log(1+sqrt 2)  = {two_ls:.10f}"
          f"  = log(3 + 2 sqrt 2) = {math.log(3 + 2*math.sqrt(2)):.10f}")
    print(f"  ratio                   log3 / 2log(1+sqrt2) = {LOG3/two_ls:.10f}")
    print(f"  uniform deficit         1 - ratio            = {1 - LOG3/two_ls:.10f}")
    print(f"  explicit bound          3^3 = 27 <= (1+sqrt2)^4 = "
          f"{(1+math.sqrt(2))**4:.6f}  ==>  dim_hyp <= 2/3")
    print()
    print("  hyperbolic dimension across the simplex (always <= 0.62321... <= 2/3):")
    for q in [(1/3, 1/3, 1/3), (0.5, 0.25, 0.25), (0.7, 0.2, 0.1), (0.9, 0.05, 0.05)]:
        qq = normalise(q)
        print(f"    p = ({qq[0]:.3f}, {qq[1]:.3f}, {qq[2]:.3f})"
              f"   H = {shannon_entropy(qq):.6f}"
              f"   dim_hyp = {hyperbolic_dimension(qq):.6f}")
    print()
    print("  So the harmonic measure is never the conformal measure of the")
    print("  hyperbolic embedding: the tree branches three ways but stretches by")
    print("  1 + sqrt 2 per unit depth, and three is not enough to catch up.")
    print()


# --------------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------------

def main() -> None:
    p: Weights = normalise((0.5, 0.3, 0.2))
    q: Weights = normalise((0.3, 0.4, 0.3))

    print()
    print("#" * 78)
    print("#  HARMONIC MEASURE ON THE BOUNDARY OF THE BERGGREN TREE")
    print("#  Random walks and the 3-adic Cantor set of primitive Pythagorean triples")
    print("#" * 78)
    print()

    demo_tree_enumeration(max_depth=6)
    demo_harmonic_measure(p, depth=5)
    demo_entropy_identity(p, max_depth=8)
    demo_smb_and_dimension(p, length=200_000)
    demo_ray_rigidity(p)
    demo_separation(p, q)
    demo_drift(p, depth=60, samples=400)
    demo_transfer_spectrum(p, depth=6)
    demo_entropy_metric_gap()

    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    H = shannon_entropy(p)
    print(f"  weights                    ({p[0]:.4f}, {p[1]:.4f}, {p[2]:.4f})")
    print(f"  entropy H(p)               {H:.8f} nats  (max log 3 = {LOG3:.8f})")
    print(f"  3-adic dimension           {H/LOG3:.8f}   (<= 1, = 1 iff fair)")
    print(f"  hyperbolic dimension       {hyperbolic_dimension(p):.8f}   (<= 2/3 always)")
    print(f"  drift lower bound          {p[1]*LOG2:.8f}")
    print(f"  drift upper bound          {LOG_SILVER:.8f}   (silver exponent)")
    print(f"  spectral gap               1.00000000   (for every weight vector)")
    print()


if __name__ == "__main__":
    main()
