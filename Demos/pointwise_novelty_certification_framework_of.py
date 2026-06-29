"""
Certified Novelty Detection in Metric Spaces — Numerical Demonstrations
=======================================================================

This self-contained script demonstrates, with concrete numerical examples, the
core results of the *certified novelty* framework:

  * the novelty score  noveltyScore(S, x) = inf_{s in S} dist(x, s);
  * the novelty predicate  IsNovel(eps, S, x)  <=>  eps <= noveltyScore(S, x);
  * 1-Lipschitz regularity of the score in the query point;
  * antitonicity of the score in the reference set;
  * triangle (robustness) transfer of certificates under query perturbation;
  * transport of certificates under expanding (antilipschitz) maps;
  * the packing core: mutually eps-separated sets yield disjoint eps/2 balls;
  * novelty *regions* as open strict super-level sets, with the persistence
    "birth time" reading and the decreasing threshold filtration;
  * approximate-Lipschitz layers with their affine error-composition law and
    the closed-form depth-budget (geometric series);
  * set-level novelty via the Hausdorff metric (sets-as-points duality).

Everything is plain Python with type hints; no third-party dependencies.
"""

from __future__ import annotations

from itertools import combinations
from math import inf, isclose, sqrt
from typing import Callable, Iterable, List, Sequence, Tuple

# A point lives in R^d, represented as a tuple of floats.
Point = Tuple[float, ...]


# --------------------------------------------------------------------------- #
# Basic metric geometry
# --------------------------------------------------------------------------- #
def dist(x: Point, y: Point) -> float:
    """Euclidean distance between two points of equal dimension."""
    return sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def novelty_score(reference: Sequence[Point], x: Point) -> float:
    """noveltyScore(S, x) = inf_{s in S} dist(x, s).

    For the empty reference set the infimum is +inf (everything is maximally
    novel against no knowledge).
    """
    if not reference:
        return inf
    return min(dist(x, s) for s in reference)


def is_novel(eps: float, reference: Sequence[Point], x: Point) -> bool:
    """IsNovel(eps, S, x): x is at least eps away from every known point."""
    return all(eps <= dist(x, s) for s in reference)


def is_novel_via_score(eps: float, reference: Sequence[Point], x: Point) -> bool:
    """Equivalent test through the score: eps <= noveltyScore(S, x)."""
    return eps <= novelty_score(reference, x)


# --------------------------------------------------------------------------- #
# Regularity, robustness and transport
# --------------------------------------------------------------------------- #
def triangle_transfer_threshold(eps: float, delta: float) -> float:
    """If x is eps-novel and dist(x, y) <= delta then y is (eps - delta)-novel."""
    return eps - delta


def antilipschitz_transfer_threshold(eps: float, K: float) -> float:
    """Expanding map with antilipschitz constant K transports eps -> eps / K."""
    return eps / K


def mutually_separated(eps: float, reference: Sequence[Point]) -> bool:
    """Every pair of distinct reference points is at distance >= eps."""
    return all(eps <= dist(a, b) for a, b in combinations(reference, 2))


# --------------------------------------------------------------------------- #
# Novelty regions, filtration and persistence birth time
# --------------------------------------------------------------------------- #
def birth_time(reference: Sequence[Point], x: Point) -> float:
    """The persistence birth time of x equals its novelty score."""
    return novelty_score(reference, x)


def in_novelty_region(reference: Sequence[Point], eps: float, x: Point) -> bool:
    """noveltyRegion(S, eps) = { x | eps < noveltyScore(S, x) } (strict)."""
    return eps < novelty_score(reference, x)


def in_region_iff_lt_birth(reference: Sequence[Point], eps: float, x: Point) -> bool:
    """Barcode reading: x in region at eps  <=>  eps < birthTime(S, x)."""
    return eps < birth_time(reference, x)


# --------------------------------------------------------------------------- #
# Approximate-Lipschitz layers: affine error composition and depth budget
# --------------------------------------------------------------------------- #
def approx_compose(K2: float, c2: float, K1: float, c1: float) -> Tuple[float, float]:
    """(K2, c2) o (K1, c1) = (K2*K1, K2*c1 + c2)."""
    return (K2 * K1, K2 * c1 + c2)


def approx_iterate(K: float, c: float, n: int) -> Tuple[float, float]:
    """n-fold self-composition of an (K, c)-approximately-Lipschitz layer."""
    K_acc, c_acc = 1.0, 0.0
    for _ in range(n):
        K_acc, c_acc = approx_compose(K, c, K_acc, c_acc)
    return (K_acc, c_acc)


def approx_iterate_closed_form(K: float, c: float, n: int) -> Tuple[float, float]:
    """Closed form: (K^n, c * (K^n - 1) / (K - 1)) for K != 1, else (1, c*n)."""
    if isclose(K, 1.0):
        return (1.0, c * n)
    return (K ** n, c * (K ** n - 1.0) / (K - 1.0))


def approx_novel_transfer_threshold(eps: float, K: float, c: float) -> float:
    """Error-aware certificate transfer: eps -> (eps - c) / K."""
    return (eps - c) / K


# --------------------------------------------------------------------------- #
# Set-level novelty via the Hausdorff metric (sets-as-points)
# --------------------------------------------------------------------------- #
def directed_hausdorff(A: Sequence[Point], B: Sequence[Point]) -> float:
    """sup_{a in A} inf_{b in B} dist(a, b)."""
    return max(min(dist(a, b) for b in B) for a in A)


def hausdorff_dist(A: Sequence[Point], B: Sequence[Point]) -> float:
    """Symmetric Hausdorff distance between two nonempty finite sets."""
    return max(directed_hausdorff(A, B), directed_hausdorff(B, A))


def is_novel_set(eps: float, family: Sequence[Sequence[Point]],
                 A: Sequence[Point]) -> bool:
    """A is eps-novel against a family of sets in the Hausdorff metric."""
    return all(eps <= hausdorff_dist(A, B) for B in family)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def section(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def main() -> None:
    reference: List[Point] = [(0.0, 0.0), (3.0, 0.0), (0.0, 4.0)]

    section("1. Novelty score and the score <-> predicate equivalence")
    query: Point = (1.0, 1.0)
    score = novelty_score(reference, query)
    print(f"reference knowledge base S = {reference}")
    print(f"query x = {query}")
    print(f"noveltyScore(S, x) = {score:.6f}")
    for eps in (1.0, 1.4142, 2.0):
        a = is_novel(eps, reference, query)
        b = is_novel_via_score(eps, reference, query)
        print(f"  eps={eps:<7}: IsNovel={a!s:<5}  via-score={b!s:<5}  agree={a == b}")

    section("2. 1-Lipschitz regularity in the query point")
    x: Point = (5.0, 5.0)
    y: Point = (5.3, 5.4)
    d = dist(x, y)
    gap = abs(novelty_score(reference, x) - novelty_score(reference, y))
    print(f"dist(x, y)               = {d:.6f}")
    print(f"|score(x) - score(y)|    = {gap:.6f}")
    print(f"Lipschitz bound holds (gap <= dist): {gap <= d + 1e-12}")

    section("3. Antitonicity in the reference set (more knowledge => less novelty)")
    smaller: List[Point] = [(0.0, 0.0)]
    bigger: List[Point] = reference
    print(f"score against small S = {novelty_score(smaller, query):.6f}")
    print(f"score against big   S = {novelty_score(bigger, query):.6f}")
    print(f"bigger reference lowers the score: "
          f"{novelty_score(bigger, query) <= novelty_score(smaller, query)}")

    section("4. Triangle transfer (robustness to query perturbation)")
    eps0 = 2.0
    base: Point = (10.0, 10.0)
    print(f"x = {base} is eps-novel with eps = {eps0}: "
          f"{is_novel(eps0, reference, base)}")
    for delta in (0.25, 0.5, 1.0):
        yq: Point = (base[0] + delta, base[1])
        guaranteed = triangle_transfer_threshold(eps0, dist(base, yq))
        print(f"  perturb by {delta}: guaranteed threshold = {guaranteed:.4f}, "
              f"actually novel at it: {is_novel(guaranteed, reference, yq)}")

    section("5. Transport under an expanding (antilipschitz) map")
    a_factor = 2.0  # f(x) = a * x expands distances by a, antilipschitz K = 1/a
    K = 1.0 / a_factor
    eps_orig = 1.0  # query (1,1) has score ~1.414, so it is 1-novel
    scaled_ref: List[Point] = [(a_factor * p[0], a_factor * p[1]) for p in reference]
    fx: Point = (a_factor * query[0], a_factor * query[1])
    transported = antilipschitz_transfer_threshold(eps_orig, K)
    print(f"x = {query} is eps-novel with eps = {eps_orig}: "
          f"{is_novel(eps_orig, reference, query)}")
    print(f"antilipschitz constant K = {K} (expansion factor {a_factor})")
    print(f"transported threshold eps/K = {transported}")
    print(f"f(x) is novel against f(S) at that threshold: "
          f"{is_novel(transported, scaled_ref, fx)}")

    section("6. Packing core: separation => disjoint half-radius balls")
    packed: List[Point] = [(0.0, 0.0), (3.0, 0.0), (0.0, 3.0), (3.0, 3.0)]
    eps_sep = 3.0
    print(f"set = {packed}")
    print(f"mutually {eps_sep}-separated: {mutually_separated(eps_sep, packed)}")
    radius = eps_sep / 2
    disjoint = all(dist(a, b) >= 2 * radius for a, b in combinations(packed, 2))
    print(f"balls of radius eps/2 = {radius} are pairwise disjoint: {disjoint}")

    section("7. Novelty regions, filtration and persistence birth time")
    probe: Point = (8.0, 8.0)
    bt = birth_time(reference, probe)
    print(f"birthTime(S, x) for x = {probe}: {bt:.6f}")
    thresholds = [2.0, 5.0, bt - 1e-9, bt + 1e-9]
    for eps in thresholds:
        print(f"  eps={eps:<10.6f}: in region={in_novelty_region(reference, eps, probe)!s:<5}"
              f"  (eps < birth: {in_region_iff_lt_birth(reference, eps, probe)})")
    print("Filtration is decreasing in eps:",
          all(
              (not in_novelty_region(reference, hi, probe))
              or in_novelty_region(reference, lo, probe)
              for lo, hi in [(2.0, 5.0), (5.0, 7.0)]
          ))

    section("8. Approximate-Lipschitz layers: error composition and depth budget")
    K_layer, c_layer = 1.5, 0.4
    for n in range(1, 6):
        it = approx_iterate(K_layer, c_layer, n)
        cf = approx_iterate_closed_form(K_layer, c_layer, n)
        ok = isclose(it[0], cf[0]) and isclose(it[1], cf[1])
        print(f"  n={n}: iterate=({it[0]:.4f}, {it[1]:.4f})  "
              f"closed=({cf[0]:.4f}, {cf[1]:.4f})  match={ok}")
    print("Certificate transfer through one layer, eps=3, (K, c)=(1.5, 0.4):",
          f"{approx_novel_transfer_threshold(3.0, K_layer, c_layer):.6f}")

    section("9. Set-level novelty via the Hausdorff metric (sets as points)")
    family: List[List[Point]] = [
        [(0.0, 0.0), (1.0, 0.0)],
        [(0.0, 5.0), (1.0, 5.0)],
    ]
    candidate: List[Point] = [(10.0, 0.0), (11.0, 0.0)]
    print(f"family of known sets = {family}")
    print(f"candidate set        = {candidate}")
    for B in family:
        print(f"  Hausdorff dist to {B}: {hausdorff_dist(candidate, B):.6f}")
    eps_set = 8.0
    print(f"candidate is {eps_set}-novel as a set: "
          f"{is_novel_set(eps_set, family, candidate)}")


if __name__ == "__main__":
    main()
