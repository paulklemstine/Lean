"""
Kneser input for many lines: numerical demonstrations.
=======================================================

Setting.  Fix a prime p and work in the plane F_p^2.  Let v_1, ..., v_k be
*pairwise independent* directions (det(v_i, v_j) != 0 for i != j) and let
S_1, ..., S_k be subsets of F_p, each containing 0.  The *reach* of the
configuration is

    Reach(v, S) = { s_1 v_1 + ... + s_k v_k : s_i in S_i }  subset of  F_p^2.

The *deficiency* of S_i is d_i = p - |S_i|, and the total deficiency is
D = d_1 + ... + d_k.

This script demonstrates, by exhaustive computation over small primes:

  1. Three-line theorem:  k = 3 and d_1 + d_2 + d_3 < p  ==>  Reach = F_p^2,
     and the bound is sharp (there are non-spanning triples with sum exactly p).
  2. Triple criterion:  for arbitrary k, if SOME three distinct indices have
     d_i + d_j + d_l < p then Reach = F_p^2.
  3. Refutation of the (k-2)(p-1) conjecture: the harmonic family
     (1,0), (0,1), (1,1), (-1,1) with S_1 = S_2 = F_p \ {1}, S_3 = S_4 = {0,1}
     (padded by {0}) has total deficiency exactly (k-2)(p-1) and misses (1,2).
  4. Sharpness of the triple criterion in that same family: every triple of
     distinct indices has deficiency sum >= p, with p attained.
  5. What the conjectured bound does buy: surjectivity onto every quotient
     line, i.e. the reach meets every line parallel to each v_i.
  6. The "one full set" theorem: if some S_i = F_p, the conjectured bound
     (k-2)(p-1) is valid after all (iterated Cauchy-Davenport).
  7. The polynomial-method picture: all admissible coefficients of
     L_1^{p-1} L_2^{p-1} vanish exactly in the counterexample configurations.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Vec = Tuple[int, int]


# ----------------------------------------------------------------------------
# Basic arithmetic in F_p^2
# ----------------------------------------------------------------------------

def det(a: Vec, b: Vec, p: int) -> int:
    """Determinant a_1 b_2 - a_2 b_1 in F_p."""
    return (a[0] * b[1] - a[1] * b[0]) % p


def pairwise_independent(v: Sequence[Vec], p: int) -> bool:
    """True iff det(v_i, v_j) != 0 for all i != j."""
    return all(det(v[i], v[j], p) != 0 for i, j in combinations(range(len(v)), 2))


def reach(v: Sequence[Vec], S: Sequence[Sequence[int]], p: int) -> Set[Vec]:
    """All points s_1 v_1 + ... + s_k v_k with s_i in S_i (breadth-first sumset)."""
    acc: Set[Vec] = {(0, 0)}
    for vec, Si in zip(v, S):
        acc = {((x + s * vec[0]) % p, (y + s * vec[1]) % p) for (x, y) in acc for s in Si}
    return acc


def deficiencies(S: Sequence[Sequence[int]], p: int) -> List[int]:
    """d_i = p - |S_i|."""
    return [p - len(set(Si)) for Si in S]


def spans(v: Sequence[Vec], S: Sequence[Sequence[int]], p: int) -> bool:
    return len(reach(v, S, p)) == p * p


# ----------------------------------------------------------------------------
# 1. The three-line theorem and its sharpness
# ----------------------------------------------------------------------------

def subsets_containing_zero(p: int) -> List[Tuple[int, ...]]:
    """All subsets of F_p containing 0, as sorted tuples."""
    out: List[Tuple[int, ...]] = []
    rest = list(range(1, p))
    for mask in range(1 << (p - 1)):
        out.append(tuple([0] + [rest[i] for i in range(p - 1) if mask >> i & 1]))
    return out


def check_three_line_theorem(p: int) -> Tuple[int, int]:
    """Exhaustively verify: three pairwise independent directions and sets with
    total deficiency < p always span.  Returns (#hypothesis-satisfying triples,
    #non-spanning configurations at deficiency exactly p)."""
    dirs = [(1, m) for m in range(p)] + [(0, 1)]  # the p+1 projective directions
    subs = subsets_containing_zero(p)
    verified = 0
    sharp_witnesses = 0
    for v in combinations(dirs, 3):
        if not pairwise_independent(v, p):
            continue
        for S in product(subs, repeat=3):
            D = sum(deficiencies(S, p))
            if D < p:
                assert spans(v, S, p), f"counterexample to the three-line theorem: {v}, {S}"
                verified += 1
            elif D == p and not spans(v, S, p):
                sharp_witnesses += 1
    return verified, sharp_witnesses


# ----------------------------------------------------------------------------
# 2/3/4. The harmonic counterexample family
# ----------------------------------------------------------------------------

def harmonic_family(p: int, k: int) -> Tuple[List[Vec], List[List[int]]]:
    """The counterexample family: directions (1,0),(0,1),(1,1),(-1,1) followed by
    (1, j-2) for j >= 4, and sets F_p\\{1}, F_p\\{1}, {0,1}, {0,1}, {0}, ..., {0}.
    Requires 4 <= k <= p+1 and p >= 3."""
    assert p >= 3 and 4 <= k <= p + 1
    v: List[Vec] = [(1, 0), (0, 1), (1, 1), (p - 1, 1)]
    v += [(1, (j - 2) % p) for j in range(4, k)]
    S: List[List[int]] = [
        [x for x in range(p) if x != 1],
        [x for x in range(p) if x != 1],
        [0, 1],
        [0, 1],
    ]
    S += [[0] for _ in range(4, k)]
    return v, S


def check_harmonic_counterexample(p: int, k: int) -> Dict[str, object]:
    """Verify: pairwise independence, deficiency exactly (k-2)(p-1), (1,2) missing,
    every triple deficiency sum >= p with equality attained."""
    v, S = harmonic_family(p, k)
    d = deficiencies(S, p)
    R = reach(v, S, p)
    triples = [d[i] + d[j] + d[l] for i, j, l in combinations(range(k), 3)]
    return {
        "p": p,
        "k": k,
        "pairwise_independent": pairwise_independent(v, p),
        "total_deficiency": sum(d),
        "conjectured_bound": (k - 2) * (p - 1),
        "misses_(1,2)": (1, 2 % p) not in R,
        "missing_points": sorted(set(product(range(p), repeat=2)) - R),
        "min_triple_deficiency": min(triples),
        "all_triples_at_least_p": min(triples) >= p,
    }


# ----------------------------------------------------------------------------
# 5. Surjectivity onto quotient lines
# ----------------------------------------------------------------------------

def quotient_image(v: Sequence[Vec], S: Sequence[Sequence[int]], p: int, i0: int) -> Set[int]:
    """The image of the reach under r |-> det(r, v_{i0}); i.e. which lines parallel
    to v_{i0} the reach meets."""
    return {det(r, v[i0], p) for r in reach(v, S, p)}


# ----------------------------------------------------------------------------
# 6. The "one full set" theorem
# ----------------------------------------------------------------------------

def check_one_full_set(p: int, k: int, trials: Iterable[Sequence[Tuple[int, ...]]]) -> int:
    """For configurations in which S_0 = F_p and the total deficiency is at most
    (k-2)(p-1), verify that the reach is everything.  Returns the number checked."""
    dirs = [(1, m) for m in range(p)] + [(0, 1)]
    v = dirs[:k]
    assert pairwise_independent(v, p)
    checked = 0
    for tail in trials:
        S = [tuple(range(p))] + list(tail)
        if len(S) != k:
            continue
        if sum(deficiencies(S, p)) <= (k - 2) * (p - 1):
            assert spans(v, S, p), f"unexpected failure: {S}"
            checked += 1
    return checked


# ----------------------------------------------------------------------------
# 7. The polynomial-method picture
# ----------------------------------------------------------------------------

def multiply(f: Dict[Tuple[int, ...], int], g: Dict[Tuple[int, ...], int],
             p: int) -> Dict[Tuple[int, ...], int]:
    """Multiply two sparse multivariate polynomials over F_p (exponent tuples)."""
    h: Dict[Tuple[int, ...], int] = {}
    for e1, c1 in f.items():
        for e2, c2 in g.items():
            e = tuple(a + b for a, b in zip(e1, e2))
            h[e] = (h.get(e, 0) + c1 * c2) % p
    return {e: c for e, c in h.items() if c % p}


def lin_form(w: Sequence[int], k: int, p: int) -> Dict[Tuple[int, ...], int]:
    """The linear form sum_i w_i X_i as a sparse polynomial."""
    f: Dict[Tuple[int, ...], int] = {}
    for i in range(k):
        if w[i] % p:
            e = tuple(1 if j == i else 0 for j in range(k))
            f[e] = w[i] % p
    return f


def power(f: Dict[Tuple[int, ...], int], n: int, k: int,
          p: int) -> Dict[Tuple[int, ...], int]:
    res: Dict[Tuple[int, ...], int] = {tuple(0 for _ in range(k)): 1}
    for _ in range(n):
        res = multiply(res, f, p)
    return res


def admissible_coefficients(v: Sequence[Vec], S: Sequence[Sequence[int]],
                            p: int) -> List[Tuple[Tuple[int, ...], int]]:
    """All coefficients of L_1^{p-1} L_2^{p-1} at exponent vectors e with
    e_i < |S_i| and sum(e) = 2(p-1).  A single nonzero one certifies spanning."""
    k = len(v)
    L1 = lin_form([a for a, _ in v], k, p)
    L2 = lin_form([b for _, b in v], k, p)
    P = multiply(power(L1, p - 1, k, p), power(L2, p - 1, k, p), p)
    out = []
    caps = [len(set(Si)) - 1 for Si in S]
    for e in product(*[range(c + 1) for c in caps]):
        if sum(e) == 2 * (p - 1):
            out.append((e, P.get(e, 0) % p))
    return out


# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------

def main() -> None:
    print("=" * 78)
    print("KNESER INPUT FOR MANY LINES — numerical demonstrations")
    print("=" * 78)

    print("\n[1] THE THREE-LINE THEOREM (exhaustive verification)")
    print("    Claim: k = 3, pairwise independent directions, d_1+d_2+d_3 < p")
    print("           ==> every point of F_p^2 is reachable.")
    for p in (3, 5):
        verified, sharp = check_three_line_theorem(p)
        print(f"    p = {p}: {verified:6d} configurations with deficiency sum < p, all span.")
        print(f"            {sharp:6d} non-spanning configurations at deficiency sum exactly p")
        print("            (so the strict inequality cannot be relaxed).")

    print("\n[2] THE TRIPLE CRITERION FOR MANY LINES")
    print("    Claim: if SOME three distinct indices satisfy d_i+d_j+d_l < p,")
    print("           the whole configuration spans, however large k is.")
    p, k = 5, 6
    v = [(1, 0), (0, 1), (1, 1), (2, 1), (3, 1), (4, 1)]
    S = [[0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0], [0], [0]]
    d = deficiencies(S, p)
    print(f"    p = {p}, k = {k}: deficiencies {d}, total {sum(d)} "
          f"(conjectured bound {(k-2)*(p-1)})")
    print(f"    best triple sum = {min(d[i]+d[j]+d[l] for i,j,l in combinations(range(k),3))} < {p}"
          f"  ->  spans: {spans(v, S, p)}")

    print("\n[3] REFUTATION OF THE (k-2)(p-1) CONJECTURE")
    print("    The harmonic family has deficiency exactly (k-2)(p-1) and misses a point.")
    for p, k in ((3, 4), (5, 4), (5, 6), (7, 5), (7, 8), (11, 6)):
        info = check_harmonic_counterexample(p, k)
        print(f"    p={p:2d} k={k}: indep={info['pairwise_independent']}, "
              f"D={info['total_deficiency']} = (k-2)(p-1) = {info['conjectured_bound']}, "
              f"missing = {info['missing_points']}")

    print("\n[4] SHARPNESS OF THE TRIPLE CRITERION")
    print("    In the same family every triple has deficiency sum >= p, minimum exactly p.")
    for p, k in ((5, 4), (7, 6), (11, 8)):
        info = check_harmonic_counterexample(p, k)
        print(f"    p={p:2d} k={k}: min triple deficiency = {info['min_triple_deficiency']} "
              f"(= p = {p}), all >= p: {info['all_triples_at_least_p']}")

    print("\n[5] SURJECTIVITY ONTO EVERY QUOTIENT LINE")
    print("    Under D <= (k-2)(p-1) the reach meets every line in every direction v_i,")
    print("    so the missed set contains no whole line — the counterexamples miss only")
    print("    isolated points.")
    for p, k in ((5, 4), (7, 5)):
        vv, SS = harmonic_family(p, k)
        images = [len(quotient_image(vv, SS, p, i0)) for i0 in range(k)]
        print(f"    p={p:2d} k={k}: |image in each quotient line| = {images} (all equal p={p})")

    print("\n[6] THE 'ONE FULL SET' THEOREM")
    print("    If some S_i is all of F_p, the conjectured bound (k-2)(p-1) IS valid.")
    p, k = 5, 4
    subs = subsets_containing_zero(p)
    checked = check_one_full_set(p, k, product(subs, repeat=k - 1))
    print(f"    p = {p}, k = {k}: {checked} configurations with S_0 = F_p and "
          f"D <= {(k-2)*(p-1)} — all span.")

    print("\n[7] THE POLYNOMIAL-METHOD PICTURE")
    print("    A nonzero coefficient of L_1^{p-1} L_2^{p-1} at an exponent vector e with")
    print("    e_i < |S_i| and sum(e) = 2(p-1) certifies spanning; the degree budget for")
    print("    such an e exists exactly when D <= (k-2)(p-1).")
    for p, k in ((3, 4), (5, 4)):
        vv, SS = harmonic_family(p, k)
        coeffs = admissible_coefficients(vv, SS, p)
        nz = [c for _, c in coeffs if c != 0]
        print(f"    p={p} k={k} (counterexample): {len(coeffs)} admissible exponent vectors, "
              f"{len(nz)} with nonzero coefficient  ->  criterion silent, as it must be.")
    p, k = 5, 4
    vv = [(1, 0), (0, 1), (1, 1), (2, 1)]
    SS = [[0, 1, 2, 3, 4], [0, 1, 2, 3, 4], [0, 1], [0]]
    coeffs = admissible_coefficients(vv, SS, p)
    nz = [(e, c) for e, c in coeffs if c != 0]
    print(f"    p={p} k={k} (spanning example, D={sum(deficiencies(SS,p))} "
          f"<= {(k-2)*(p-1)}): {len(nz)} nonzero admissible coefficients, e.g. {nz[:2]}")
    print(f"    reach is everything: {spans(vv, SS, p)}")

    print("\n" + "=" * 78)
    print("All assertions passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
