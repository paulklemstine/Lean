"""
Emergent Spacetime from Entanglement: numerical demonstrations.

This self-contained script illustrates, by explicit computation, the results of
the accompanying article and paper:

  1. Min-cut ("Ryu-Takayanagi") entropies of finite weighted bulk graphs.
  2. The holographic entropy inequalities -- subadditivity, strong
     subadditivity, monogamy of mutual information, and the five-party cyclic
     inequality -- verified on random geometries.
  3. The contraction (Hamming-nonexpansive Boolean map) certificates that prove
     those inequalities, checked exhaustively over Boolean patterns.
  4. The explicit five-party entropy vector S_w that satisfies subadditivity,
     strong subadditivity, weak monotonicity and monogamy on all disjoint
     triples, yet violates the cyclic inequality by exactly one unit -- hence
     is realised by no bulk geometry whatsoever.
  5. ER = EPR in the two-qubit toy model: throat area = concurrence,
     mutual information = twice the throat area, bridge <=> entanglement.
  6. Bulk non-uniqueness (star vs. triangle) and exact reconstruction in the
     hidden-cell-free case, w(u,v) = I(u:v)/2.

Only the Python standard library is required.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Pattern = Tuple[bool, ...]
Weights = List[List[float]]


# ----------------------------------------------------------------------------
# 1. Bulk geometries and min-cut entropy
# ----------------------------------------------------------------------------


def cut_weight(weights: Weights, region: Sequence[bool]) -> float:
    """Total area of the surface bounding a bulk region.

    ``weights`` is a symmetric nonnegative matrix; ``region`` is a Boolean
    membership vector on bulk cells.  The area is
    ``(1/2) * sum_{u,v} [f(u) != f(v)] * w(u,v)``.
    """
    n = len(weights)
    total = 0.0
    for u in range(n):
        for v in range(n):
            if region[u] != region[v]:
                total += weights[u][v]
    return total / 2.0


def entropy(weights: Weights, boundary: Sequence[bool],
            region: Sequence[bool]) -> float:
    """Min-cut entropy of a boundary region.

    Minimises ``cut_weight`` over all bulk regions whose trace on the boundary
    cells equals ``region``.  Hidden (non-boundary) cells are free.
    """
    n = len(weights)
    hidden = [i for i in range(n) if not boundary[i]]
    base = [bool(region[i]) if boundary[i] else False for i in range(n)]
    best = math.inf
    for bits in itertools.product([False, True], repeat=len(hidden)):
        trial = list(base)
        for idx, b in zip(hidden, bits):
            trial[idx] = b
        best = min(best, cut_weight(weights, trial))
    return best


def mutual_information(weights: Weights, boundary: Sequence[bool],
                       A: Sequence[bool], B: Sequence[bool]) -> float:
    """I(A:B) = S(A) + S(B) - S(A u B)."""
    union = [a or b for a, b in zip(A, B)]
    return (entropy(weights, boundary, A) + entropy(weights, boundary, B)
            - entropy(weights, boundary, union))


def random_geometry(n: int, hidden: int, rng: random.Random) -> Tuple[Weights, List[bool]]:
    """A random symmetric nonnegative weighted graph with ``hidden`` bulk cells."""
    weights = [[0.0] * n for _ in range(n)]
    for u in range(n):
        for v in range(u + 1, n):
            w = rng.choice([0.0, 0.0, rng.uniform(0.0, 2.0)])
            weights[u][v] = w
            weights[v][u] = w
    boundary = [True] * (n - hidden) + [False] * hidden
    return weights, boundary


def indicator(n: int, cells: Iterable[int]) -> List[bool]:
    """Boolean membership vector of a set of cells."""
    s = set(cells)
    return [i in s for i in range(n)]


# ----------------------------------------------------------------------------
# 2. Holographic entropy inequalities on random geometries
# ----------------------------------------------------------------------------


def check_inequalities(trials: int = 200, seed: int = 20240816) -> None:
    rng = random.Random(seed)
    worst_sa = worst_ssa = worst_mmi = worst_cyc = math.inf
    for _ in range(trials):
        n, hidden = 7, 2
        weights, boundary = random_geometry(n, hidden, rng)
        bcells = [i for i in range(n) if boundary[i]]
        rng.shuffle(bcells)
        # three disjoint boundary regions
        A = indicator(n, bcells[:1])
        B = indicator(n, bcells[1:2])
        C = indicator(n, bcells[2:4])
        AB = [a or b for a, b in zip(A, B)]
        BC = [b or c for b, c in zip(B, C)]
        AC = [a or c for a, c in zip(A, C)]
        ABC = [a or b for a, b in zip(AB, C)]
        S = lambda R: entropy(weights, boundary, R)
        worst_sa = min(worst_sa, S(A) + S(B) - S(AB))
        worst_ssa = min(worst_ssa, S(AB) + S(BC) - S(ABC) - S(B))
        worst_mmi = min(worst_mmi,
                        S(AB) + S(BC) + S(AC) - S(A) - S(B) - S(C) - S(ABC))
    print("Random-geometry check of the holographic inequalities")
    print(f"  min slack, subadditivity        S(A)+S(B)-S(AB)      = {worst_sa:.6f}")
    print(f"  min slack, strong subadditivity                      = {worst_ssa:.6f}")
    print(f"  min slack, monogamy (MMI)                            = {worst_mmi:.6f}")

    # Five-party cyclic inequality needs five disjoint regions.
    rng = random.Random(seed + 1)
    for _ in range(trials):
        n, hidden = 8, 3
        weights, boundary = random_geometry(n, hidden, rng)
        parts = [indicator(n, [i]) for i in range(5)]
        S = lambda R: entropy(weights, boundary, R)
        uni = lambda idxs: [any(parts[i][v] for i in idxs) for v in range(n)]
        lhs = sum(S(uni([i, (i + 1) % 5])) for i in range(5)) + S(uni(range(5)))
        rhs = sum(S(uni([i, (i + 1) % 5, (i + 2) % 5])) for i in range(5))
        worst_cyc = min(worst_cyc, rhs - lhs)
    print(f"  min slack, five-party cyclic inequality              = {worst_cyc:.6f}")
    print()


# ----------------------------------------------------------------------------
# 3. Contraction certificates
# ----------------------------------------------------------------------------


def hamming(a: Sequence[bool], b: Sequence[bool]) -> int:
    return sum(1 for x, y in zip(a, b) if x != y)


def is_contraction(chi: Callable[[Pattern], Sequence[bool]], k: int) -> bool:
    """Is ``chi`` nonexpansive for Hamming distance on ``{0,1}^k``?"""
    patterns = list(itertools.product([False, True], repeat=k))
    for a in patterns:
        for b in patterns:
            if hamming(chi(a), chi(b)) > hamming(a, b):
                return False
    return True


def inter_union_map(a: Pattern) -> Tuple[bool, bool]:
    return (a[0] and a[1], a[0] or a[1])


def minority_map(a: Pattern) -> Tuple[bool, bool, bool, bool]:
    return (a[0] and a[1] and not a[2],
            a[0] and a[2] and not a[1],
            a[1] and a[2] and not a[0],
            a[0] or a[1] or a[2])


def naive_pairwise_map(a: Pattern) -> Tuple[bool, bool, bool, bool]:
    return (a[0] and a[1], a[0] and a[2], a[1] and a[2],
            a[0] or a[1] or a[2])


def cyc(c0: bool, c1: bool, c2: bool, c3: bool, c4: bool) -> bool:
    """The cyclic recombination rule: c4 & ~c2 & (c0 | (c1 & ~c3))."""
    return c4 and (not c2) and (c0 or (c1 and not c3))


def cyclic_map(a: Pattern) -> Tuple[bool, ...]:
    rot = lambda j: tuple(a[(j + t) % 5] for t in range(5))
    return tuple(cyc(*rot(j)) for j in range(5)) + (any(a),)


def check_contractions() -> None:
    print("Contraction certificates (exhaustive over Boolean patterns)")
    print(f"  intersection/union map is a contraction : {is_contraction(inter_union_map, 2)}")
    print(f"  minority/union map is a contraction     : {is_contraction(minority_map, 3)}")
    print(f"  naive pairwise map is a contraction     : {is_contraction(naive_pairwise_map, 3)}"
          "   <- must be False")
    print(f"  cyclic five-to-six map is a contraction : {is_contraction(cyclic_map, 5)}")
    # boundary trace of the cyclic rule
    ok = True
    for a in itertools.product([False, True], repeat=5):
        if sum(a) > 1:
            continue
        triples = tuple(a[j] or a[(j + 1) % 5] or a[(j + 2) % 5] for j in range(5))
        if cyc(*triples) != (a[0] or a[1]):
            ok = False
    print(f"  cyclic rule traces triples to pairs     : {ok}")
    print()


# ----------------------------------------------------------------------------
# 4. The non-geometric entropy vector S_w
# ----------------------------------------------------------------------------

SW: Dict[int, int] = {
    0: 0, 1: 3, 2: 2, 3: 5, 4: 4, 5: 5, 6: 6, 7: 5,
    8: 2, 9: 5, 10: 4, 11: 7, 12: 6, 13: 6, 14: 7, 15: 5,
    16: 3, 17: 6, 18: 5, 19: 7, 20: 5, 21: 4, 22: 6, 23: 4,
    24: 4, 25: 5, 26: 6, 27: 6, 28: 4, 29: 3, 30: 5, 31: 2,
}


def sw(mask: int) -> int:
    return SW[mask]


def check_witness_vector() -> None:
    masks = range(32)
    sa = all(sw(X | Y) <= sw(X) + sw(Y)
             for X in masks for Y in masks if X & Y == 0)
    ssa = all(sw(X | Y | Z) + sw(Y) <= sw(X | Y) + sw(Y | Z)
              for X in masks for Y in masks for Z in masks
              if X & Y == 0 and Y & Z == 0 and X & Z == 0)
    wm = all(sw(X) + sw(Z) <= sw(X | Y) + sw(Y | Z)
             for X in masks for Y in masks for Z in masks
             if X & Y == 0 and Y & Z == 0 and X & Z == 0)
    mmi = all(sw(X | Y | Z) + sw(X) + sw(Y) + sw(Z)
              <= sw(X | Y) + sw(Y | Z) + sw(X | Z)
              for X in masks for Y in masks for Z in masks
              if X & Y == 0 and Y & Z == 0 and X & Z == 0)
    pairs = [3, 6, 12, 24, 17]
    triples = [7, 14, 28, 25, 19]
    lhs = sum(sw(m) for m in pairs) + sw(31)
    rhs = sum(sw(m) for m in triples)
    print("The witness entropy vector S_w (five parties, 32 subsets)")
    print(f"  subadditivity on all disjoint pairs     : {sa}")
    print(f"  strong subadditivity on disjoint triples: {ssa}")
    print(f"  weak monotonicity on disjoint triples   : {wm}")
    print(f"  monogamy on disjoint triples            : {mmi}")
    print(f"  cyclic inequality: LHS = {lhs}, RHS = {rhs}"
          f"  -> violated by {lhs - rhs}")
    print("  hence no finite bulk geometry realises S_w.")
    print()


# ----------------------------------------------------------------------------
# 5. ER = EPR for a two-qubit state
# ----------------------------------------------------------------------------


def concurrence(psi: Sequence[Sequence[float]]) -> float:
    """Concurrence of a real two-qubit pure state: C = 2|det psi|."""
    return 2.0 * abs(psi[0][0] * psi[1][1] - psi[0][1] * psi[1][0])


def linear_entropy(psi: Sequence[Sequence[float]]) -> float:
    """2(1 - Tr rho^2) for the left marginal rho of a normalised state."""
    rho = [[sum(psi[i][j] * psi[k][j] for j in range(2)) for k in range(2)]
           for i in range(2)]
    purity = sum(rho[i][k] ** 2 for i in range(2) for k in range(2))
    return 2.0 * (1.0 - purity)


def pair_model(w: float) -> Tuple[Weights, List[bool]]:
    """Two boundary cells joined by a single throat of area w."""
    return [[0.0, w], [w, 0.0]], [True, True]


def check_er_epr() -> None:
    print("ER = EPR in the two-qubit toy model")
    states = {
        "Bell (|00>+|11>)/sqrt2": [[1 / math.sqrt(2), 0.0], [0.0, 1 / math.sqrt(2)]],
        "product |0>|0>":         [[1.0, 0.0], [0.0, 0.0]],
        "product |+>|+>":         [[0.5, 0.5], [0.5, 0.5]],
        "partially entangled":    [[math.cos(0.4), 0.0], [0.0, math.sin(0.4)]],
    }
    header = f"  {'state':26s} {'C':>8s} {'2(1-Trρ²)':>11s} {'C²':>8s} {'I(0:1)':>8s} {'bridge':>7s}"
    print(header)
    for name, psi in states.items():
        C = concurrence(psi)
        weights, boundary = pair_model(C)
        I = mutual_information(weights, boundary, [True, False], [False, True])
        bridge = C > 0
        print(f"  {name:26s} {C:8.4f} {linear_entropy(psi):11.4f} "
              f"{C ** 2:8.4f} {I:8.4f} {str(bridge):>7s}")
    print("  throat area = concurrence;  I = 2C;  I^2 = 4 * linear entropy;")
    print("  a bridge exists exactly for entangled states.")
    print()


def check_matching_model(areas: Sequence[float] = (0.8, 0.3, 0.0)) -> None:
    """n Bell pairs: 2n boundary cells matched by throats of given areas."""
    n = len(areas)
    size = 2 * n
    weights = [[0.0] * size for _ in range(size)]
    for i, w in enumerate(areas):
        weights[2 * i][2 * i + 1] = w
        weights[2 * i + 1][2 * i] = w
    boundary = [True] * size
    print(f"Geometry of {n} independent Bell pairs (throat areas {list(areas)})")
    for i in range(n):
        A = indicator(size, [2 * i])
        B = indicator(size, [2 * i + 1])
        I = mutual_information(weights, boundary, A, B)
        print(f"  partners  ({2*i},{2*i+1}) : I = {I:.4f}  = 2 * {areas[i]}")
    if n >= 2:
        A = indicator(size, [0])
        B = indicator(size, [3])
        print(f"  strangers (0,3) : I = "
              f"{mutual_information(weights, boundary, A, B):.4f}  (exactly 0)")
    print()


# ----------------------------------------------------------------------------
# 6. Non-uniqueness and reconstruction
# ----------------------------------------------------------------------------


def star_and_triangle() -> None:
    """Star (one hidden cell, three unit throats) vs. triangle (weights 1/2)."""
    star = [[0.0, 0.0, 0.0, 1.0],
            [0.0, 0.0, 0.0, 1.0],
            [0.0, 0.0, 0.0, 1.0],
            [1.0, 1.0, 1.0, 0.0]]
    triangle = [[0.0, 0.5, 0.5, 0.0],
                [0.5, 0.0, 0.5, 0.0],
                [0.5, 0.5, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0]]
    boundary = [True, True, True, False]
    print("Star vs. triangle: same entanglement, different geometry")
    print(f"  {'region':12s} {'S_star':>8s} {'S_triangle':>11s}")
    for bits in itertools.product([False, True], repeat=3):
        region = list(bits) + [False]
        label = "{" + ",".join(str(i) for i in range(3) if bits[i]) + "}"
        s1 = entropy(star, boundary, region)
        s2 = entropy(triangle, boundary, region)
        print(f"  {label:12s} {s1:8.4f} {s2:11.4f}")
    print(f"  star edge w(0,1)     = {star[0][1]}")
    print(f"  triangle edge w(0,1) = {triangle[0][1]}   -> geometries differ")
    print("  yet every boundary entropy agrees: hidden cells spoil uniqueness.")
    print()


def reconstruction_demo(seed: int = 7) -> None:
    """Hidden-cell-free geometries are recovered by w(u,v) = I(u:v)/2."""
    rng = random.Random(seed)
    n = 5
    weights = [[0.0] * n for _ in range(n)]
    for u in range(n):
        for v in range(u + 1, n):
            w = round(rng.uniform(0.0, 1.5), 3)
            weights[u][v] = w
            weights[v][u] = w
    boundary = [True] * n
    print("Reconstruction: w(u,v) = I(u:v)/2 for geometries with no hidden cells")
    err = 0.0
    for u in range(n):
        for v in range(u + 1, n):
            I = mutual_information(weights, boundary,
                                   indicator(n, [u]), indicator(n, [v]))
            err = max(err, abs(weights[u][v] - I / 2))
    print(f"  maximal reconstruction error over all edges: {err:.2e}")
    print("  (the self-loop weights are pure gauge and are invisible)")
    print()


def main() -> None:
    print("=" * 74)
    print("EMERGENT SPACETIME FROM ENTANGLEMENT -- NUMERICAL DEMONSTRATIONS")
    print("=" * 74)
    print()
    check_inequalities()
    check_contractions()
    check_witness_vector()
    check_er_epr()
    check_matching_model()
    star_and_triangle()
    reconstruction_demo()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
