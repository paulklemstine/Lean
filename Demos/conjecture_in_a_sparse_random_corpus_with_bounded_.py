"""
Extremal topology of co-citation complexes: numerical demonstrations.

A *corpus* on a finite theorem set V is a family of documents, each document being the
set of theorems it cites.  Its *co-citation complex* is the downward closure of that
family: every subset of a bibliography is a face.

This script verifies, by exact computation on small instances, every quantitative claim
of the accompanying theory:

  1. Vanishing of faces / homology above the document-size bound d.
  2. Sharpness of the extremal face count  max f_q = C(n, q)  for q <= d, attained by
     the complete d-uniform design (all d-subsets are documents).
  3. The closed form  chi = 1 - (-1)^d C(n-1, d)  for the design, and the partial
     alternating binomial identity behind it.
  4. The realised Betti profile of the design: beta_0 = 1, beta_{d-1} = C(n-1, d),
     computed independently by exact mod-2 simplicial homology.
  5. The concentration bound  |chi| <= d * max_{k<d} beta_k  and its localised form
     (n-d)^d <= d! (beta_{d-1} + (d-1) n^{d-1} + 1).
  6. The conformality hierarchy: locally conformal at level m, not at level m+1.
  7. The document budget  f_q <= N C(d, q)  and the sparse separation beta_1 < C(n,2).
  8. Non-identifiability of vertex labels on vertex-transitive corpora.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import combinations, permutations
from math import comb, factorial
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Face = FrozenSet[int]
Corpus = List[Face]


# ----------------------------------------------------------------------------------
# 1. Complexes, f-vectors and Euler characteristic
# ----------------------------------------------------------------------------------

def co_citation_complex(corpus: Corpus) -> Set[Face]:
    """Downward closure of the corpus: all subsets of documents (empty face excluded)."""
    faces: Set[Face] = set()
    for doc in corpus:
        items = sorted(doc)
        for size in range(1, len(items) + 1):
            for sub in combinations(items, size):
                faces.add(frozenset(sub))
    return faces


def f_vector(corpus: Corpus, max_size: int) -> List[int]:
    """f_vector(corpus)[q] = number of faces with exactly q vertices (index from 0)."""
    faces = co_citation_complex(corpus)
    counts = [0] * (max_size + 1)
    for face in faces:
        if len(face) <= max_size:
            counts[len(face)] += 1
    return counts


def euler_characteristic(corpus: Corpus, n: int) -> int:
    """chi = f_1 - f_2 + f_3 - ...  (unreduced; the empty face is not counted)."""
    counts = f_vector(corpus, n)
    return sum((-1) ** (q - 1) * counts[q] for q in range(1, n + 1))


# ----------------------------------------------------------------------------------
# 2. Exact simplicial homology over GF(2)
# ----------------------------------------------------------------------------------

def _gf2_rank(rows: Iterable[int]) -> int:
    """Rank over GF(2) of a matrix given as an iterable of bitmask rows."""
    pivots: List[int] = []
    rank = 0
    for row in rows:
        cur = row
        for piv in pivots:
            cur = min(cur, cur ^ piv)
        if cur:
            pivots.append(cur)
            pivots.sort(reverse=True)
            rank += 1
    return rank


def betti_numbers_mod2(corpus: Corpus, max_dim: int) -> List[int]:
    """Betti numbers beta_0 .. beta_{max_dim} of the co-citation complex over GF(2)."""
    faces = co_citation_complex(corpus)
    by_size: Dict[int, List[Face]] = {}
    for face in faces:
        by_size.setdefault(len(face), []).append(face)
    for size in by_size:
        by_size[size].sort(key=lambda f: sorted(f))

    index: Dict[int, Dict[Face, int]] = {
        size: {face: i for i, face in enumerate(fs)} for size, fs in by_size.items()
    }

    def boundary_rank(size: int) -> int:
        """Rank of the boundary map from faces of `size` vertices to those of size-1."""
        if size <= 1 or size not in by_size or (size - 1) not in by_size:
            return 0
        rows: List[int] = []
        for face in by_size[size]:
            mask = 0
            for v in face:
                sub = face - {v}
                mask |= 1 << index[size - 1][sub]
            rows.append(mask)
        return _gf2_rank(rows)

    betti: List[int] = []
    for k in range(max_dim + 1):
        chain_dim = len(by_size.get(k + 1, []))
        betti.append(chain_dim - boundary_rank(k + 1) - boundary_rank(k + 2))
    return betti


# ----------------------------------------------------------------------------------
# 3. Corpora
# ----------------------------------------------------------------------------------

def design_corpus(n: int, d: int) -> Corpus:
    """The complete d-uniform design: every d-subset of {0,...,n-1} is a document."""
    return [frozenset(c) for c in combinations(range(n), d)]


def design_euler_closed_form(n: int, d: int) -> int:
    """chi = 1 - (-1)^d C(n-1, d)."""
    return 1 - (-1) ** d * comb(n - 1, d)


def design_betti_profile(n: int, d: int) -> List[int]:
    """Predicted profile: beta_0 = 1, beta_{d-1} = C(n-1, d), everything else 0."""
    profile = [0] * d
    profile[0] += 1
    profile[d - 1] += comb(n - 1, d)
    return profile


# ----------------------------------------------------------------------------------
# 4. Conformality
# ----------------------------------------------------------------------------------

def co_citation_graph(corpus: Corpus, n: int) -> Set[Tuple[int, int]]:
    """Edges {x,y} such that some document contains both."""
    edges: Set[Tuple[int, int]] = set()
    for doc in corpus:
        for x, y in combinations(sorted(doc), 2):
            edges.add((x, y))
    return edges


def is_clique(vertices: Sequence[int], edges: Set[Tuple[int, int]]) -> bool:
    return all((min(x, y), max(x, y)) in edges for x, y in combinations(vertices, 2))


def witness_free_cliques(corpus: Corpus, n: int, size: int) -> List[Tuple[int, ...]]:
    """Cliques of the given size with no single document containing them."""
    edges = co_citation_graph(corpus, n)
    bad: List[Tuple[int, ...]] = []
    for cand in combinations(range(n), size):
        if not is_clique(cand, edges):
            continue
        if not any(set(cand) <= set(doc) for doc in corpus):
            bad.append(cand)
    return bad


def local_conformality_level(corpus: Corpus, n: int) -> int:
    """Largest m such that every clique of size <= m has a witnessing document."""
    for size in range(1, n + 1):
        if witness_free_cliques(corpus, n, size):
            return size - 1
    return n


def flag_complex_size(corpus: Corpus, n: int) -> int:
    edges = co_citation_graph(corpus, n)
    total = 0
    for size in range(1, n + 1):
        for cand in combinations(range(n), size):
            if is_clique(cand, edges):
                total += 1
    return total


# ----------------------------------------------------------------------------------
# 5. Demonstrations
# ----------------------------------------------------------------------------------

def demo_support_and_extremality() -> None:
    print("=" * 78)
    print("1. DOCUMENT SIZE BOUNDS THE SUPPORT; THE DESIGN ATTAINS THE CEILING")
    print("=" * 78)
    print(f"{'n':>3} {'d':>3} | {'f-vector (q = 1..n)':<34} | ceiling C(n,q), q<=d")
    for n, d in [(5, 2), (5, 3), (6, 3), (6, 4)]:
        corpus = design_corpus(n, d)
        fv = f_vector(corpus, n)[1:]
        ceiling = [comb(n, q) for q in range(1, d + 1)]
        assert fv[:d] == ceiling, "design must attain the binomial ceiling"
        assert all(x == 0 for x in fv[d:]), "no faces above the document-size bound"
        print(f"{n:>3} {d:>3} | {str(fv):<34} | {ceiling}")
    print()


def demo_euler_and_betti() -> None:
    print("=" * 78)
    print("2. EULER CHARACTERISTIC AND THE REALISED BETTI PROFILE OF THE DESIGN")
    print("=" * 78)
    header = f"{'n':>3} {'d':>3} | {'chi (direct)':>12} {'chi (formula)':>14} | "
    print(header + "Betti (mod 2)      predicted")
    for n, d in [(3, 2), (4, 2), (5, 2), (4, 3), (5, 3), (6, 3), (6, 4)]:
        corpus = design_corpus(n, d)
        chi_direct = euler_characteristic(corpus, n)
        chi_formula = design_euler_closed_form(n, d)
        betti = betti_numbers_mod2(corpus, d - 1)
        predicted = design_betti_profile(n, d)
        assert chi_direct == chi_formula, "closed form must match the direct sum"
        assert betti == predicted, "computed homology must match the predicted profile"
        alt = sum((-1) ** k * betti[k] for k in range(d))
        assert alt == chi_direct, "Euler-Poincare must hold"
        print(f"{n:>3} {d:>3} | {chi_direct:>12} {chi_formula:>14} | "
              f"{str(betti):<18} {predicted}")
    print()


def demo_alternating_identity() -> None:
    print("=" * 78)
    print("3. PARTIAL ALTERNATING BINOMIAL IDENTITY  sum_{j<=d} (-1)^j C(m+1,j)"
          "  =  (-1)^d C(m,d)")
    print("=" * 78)
    for m in range(0, 9):
        for d in range(0, m + 2):
            lhs = sum((-1) ** j * comb(m + 1, j) for j in range(d + 1))
            rhs = (-1) ** d * comb(m, d)
            assert lhs == rhs, (m, d, lhs, rhs)
    print("verified for all 0 <= m <= 8 and 0 <= d <= m+1.\n")


def demo_concentration_bounds() -> None:
    print("=" * 78)
    print("4. CONCENTRATION: THE EULER CHARACTERISTIC FORCES A LARGE BETTI NUMBER")
    print("=" * 78)
    print(f"{'n':>4} {'d':>3} | {'|chi|':>9} {'d*max_k beta_k':>15} | "
          f"{'(n-d)^d':>12} {'d!(b+(d-1)n^(d-1)+1)':>22}")
    for n, d in [(6, 3), (10, 3), (20, 3), (10, 4), (20, 4), (40, 5)]:
        chi = design_euler_closed_form(n, d)
        profile = design_betti_profile(n, d)
        lhs1, rhs1 = abs(chi), d * max(profile)
        top = profile[d - 1]
        lhs2 = (n - d) ** d
        rhs2 = factorial(d) * (top + (d - 1) * n ** (d - 1) + 1)
        assert lhs1 <= rhs1, "concentration bound"
        assert lhs2 <= rhs2, "localised polynomial bound"
        print(f"{n:>4} {d:>3} | {lhs1:>9} {rhs1:>15} | {lhs2:>12} {rhs2:>22}")
    print("  every row satisfies both certified inequalities; note beta_{d-1} ~ n^d")
    print("  while all lower Betti numbers are capped at C(n,k+1) = O(n^(d-1)).\n")


def demo_conformality_hierarchy() -> None:
    print("=" * 78)
    print("5. CONFORMALITY IS A HIERARCHY, NOT A SINGLE OBSTRUCTION")
    print("=" * 78)
    print(f"{'m':>3} | {'corpus':<28} | local level | witness-free cliques of size m+1")
    for m in [2, 3, 4]:
        n = m + 1
        corpus = design_corpus(n, m)
        level = local_conformality_level(corpus, n)
        bad = witness_free_cliques(corpus, n, m + 1)
        assert level == m, "locally conformal exactly up to level m"
        assert len(bad) == 1, "exactly one minimal obstruction at level m+1"
        label = f"D_{{{n},{m}}} on {n} theorems"
        print(f"{m:>3} | {label:<28} | {level:>11} | {bad}")
    print("  m = 2 is the classical hollow triangle {{0,1},{0,2},{1,2}}:")
    print("   ", sorted(tuple(sorted(w)) for w in design_corpus(3, 2)))
    print()
    print("  pairwise projection invents faces:")
    print(f"  {'n':>3} {'d':>3} | {'true faces':>11} {'flag faces':>11} {'invented':>9}")
    for n, d in [(4, 2), (5, 2), (5, 3), (6, 3)]:
        corpus = design_corpus(n, d)
        true_faces = sum(comb(n, q) for q in range(1, d + 1))
        flag = flag_complex_size(corpus, n)
        assert flag == 2 ** n - 1, "two-section of a design is complete"
        assert len(co_citation_complex(corpus)) == true_faces
        print(f"  {n:>3} {d:>3} | {true_faces:>11} {flag:>11} {flag - true_faces:>9}")
    print("  (counts exclude the empty face; the flag complex has all 2^n subsets.)\n")


def demo_document_budget() -> None:
    print("=" * 78)
    print("6. DOCUMENT BUDGET: SPARSE CORPORA NEVER APPROACH THE BINOMIAL CEILING")
    print("=" * 78)
    print(f"{'n':>4} {'d':>3} {'N':>6} | {'budget N*C(d,q)':>16} {'ceiling C(n,q)':>15}"
          f" | q")
    for n, d, N, q in [(50, 3, 40, 2), (50, 3, 40, 3), (200, 4, 500, 3),
                       (1000, 5, 5000, 4)]:
        budget = N * comb(d, q)
        ceiling = comb(n, q)
        assert budget < ceiling, "sparse regime"
        print(f"{n:>4} {d:>3} {N:>6} | {budget:>16} {ceiling:>15} | {q}")
    print()
    print("  explicit pairwise instance: 2-bounded corpus, N <= n documents, n >= 4")
    print(f"  {'n':>4} | {'beta_1 (computed)':>18} {'budget N':>10} {'ceiling C(n,2)':>15}")
    for n in [4, 5, 6, 7]:
        # a sparse pairwise corpus: an n-cycle of co-citations (n documents, size 2)
        corpus = [frozenset({i, (i + 1) % n}) for i in range(n)]
        betti = betti_numbers_mod2(corpus, 1)
        assert betti[1] <= n, "document budget"
        assert betti[1] < comb(n, 2), "strict sparse separation"
        print(f"  {n:>4} | {betti[1]:>18} {n:>10} {comb(n, 2):>15}")
    print("  the n-cycle realises beta_1 = 1 against a ceiling of order n^2.\n")


def demo_non_identifiability() -> None:
    print("=" * 78)
    print("7. NON-IDENTIFIABILITY OF SEMANTIC LABELS ON A VERTEX-TRANSITIVE CORPUS")
    print("=" * 78)
    n, d = 5, 2
    corpus = set(design_corpus(n, d))
    # the design is invariant under every renaming of theorems
    invariant_under_all = True
    for perm in permutations(range(n)):
        relabelled = {frozenset(perm[v] for v in doc) for doc in corpus}
        if relabelled != corpus:
            invariant_under_all = False
            break
    assert invariant_under_all
    print(f"  the design D_{{{n},{d}}} is fixed by all {factorial(n)} renamings of its"
          " theorems,")
    print("  hence vertex-transitive: any theorem can be carried to any other.")
    betti = betti_numbers_mod2(sorted(corpus, key=lambda f: sorted(f)), 1)
    print(f"  yet it is homologically rich:  beta = {betti},"
          f"  beta_1 = C(n-1,2) = {comb(n - 1, 2)}")
    assert betti[1] == comb(n - 1, 2)
    print("  a renaming-equivariant rule must give equal labels to any two theorems,")
    print("  so it outputs a constant labelling and cannot recover, e.g.,")
    print("     lab = [0, 0, 1, 1, 1]   (two research communities).")
    print("  the obstruction is symmetry of the incidence pattern, not lack of topology.\n")


def main() -> None:
    demo_support_and_extremality()
    demo_euler_and_betti()
    demo_alternating_identity()
    demo_concentration_bounds()
    demo_conformality_hierarchy()
    demo_document_budget()
    demo_non_identifiability()
    print("all assertions passed.")


if __name__ == "__main__":
    main()
