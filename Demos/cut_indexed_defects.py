"""
Cut-Indexed Defects: numerical demonstration
============================================

This self-contained script demonstrates, by direct enumeration, every
quantitative claim of the theory of cut-indexed defects:

  1. The cut rank r_C(S): the number of distinct patterns a codebook realises
     on a cut S, together with the three cut-data axioms
        r(empty) <= 1,   S subset T => r(S) <= r(T),   r(S+{a}) <= q * r(S).

  2. The COUNTING cut-wise Singleton inequality
        |C| <= q^(k - |S|) * r_C(S),        k = n + 1 - d,   |S| <= k,
     of which the classical Singleton bound |C| <= q^k is the S = empty case.

  3. Rigidity: for an MDS code (|C| = q^k) every cut with |S| <= k satisfies
     r_C(S) = q^|S| exactly, and every fibre has exactly q^(k-|S|) elements.

  4. The cut entropy H(S) of the marginal induced by the uniform distribution
     on C, its monotonicity, the chain-rule bound
        H(T) <= H(S) + (|T| - |S|) log q,
     and the ENTROPIC cut-wise Singleton inequality
        log |C| <= H(S) + (k - |S|) log q,
     which implies the counting one and is strictly sharper for non-uniform
     cut marginals.

  5. The MDS entropy plateau H(S) = min(|S|, k) log q, and the one-cut
     criterion: at a cut of size exactly k, H(S) = k log q iff C is MDS.

  6. The QUANTUM avatar: the uniform superposition |C> = |C|^(-1/2) sum |c>,
     its Schmidt rank and entanglement entropy E(S) across a cut, the bound
     E(S) <= min(|S|, k) log q, exact saturation for |S| <= min(k, d-1), and
     the "staircase versus tent" phenomenon.

  7. Negative result: the cut rank is NOT submodular, while the cut entropy is
     (checked numerically on the same witness).

Only the Python standard library is required (math, itertools, typing);
singular values are obtained from a small hand-rolled Jacobi eigensolver so
that no third-party package is needed.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from itertools import combinations, product
from typing import Dict, Iterable, List, Sequence, Tuple

Word = Tuple[int, ...]
Cut = Tuple[int, ...]


# ---------------------------------------------------------------------------
# 1. Basic combinatorics of a codebook
# ---------------------------------------------------------------------------

def restrict(word: Word, cut: Cut) -> Word:
    """Restriction of a word to the sites of a cut (sites are 0-indexed)."""
    return tuple(word[i] for i in cut)


def hamming_distance(x: Word, y: Word) -> int:
    """Number of coordinates where two equal-length words differ."""
    return sum(1 for a, b in zip(x, y) if a != b)


def minimum_distance(code: Sequence[Word]) -> int:
    """Minimum Hamming distance between distinct codewords (inf for |C| <= 1)."""
    if len(code) < 2:
        return math.inf  # type: ignore[return-value]
    return min(hamming_distance(x, y) for x, y in combinations(code, 2))


def all_cuts(n: int) -> List[Cut]:
    """All 2^n subsets of the n sites, as sorted tuples."""
    cuts: List[Cut] = []
    for size in range(n + 1):
        cuts.extend(combinations(range(n), size))
    return cuts


def cut_rank(code: Sequence[Word], cut: Cut) -> int:
    """r_C(S): number of distinct patterns realised by the code on the cut."""
    return len({restrict(c, cut) for c in code})


def fibre_sizes(code: Sequence[Word], cut: Cut) -> Dict[Word, int]:
    """Sizes of the fibres of the restriction map, keyed by realised pattern."""
    sizes: Dict[Word, int] = {}
    for c in code:
        y = restrict(c, cut)
        sizes[y] = sizes.get(y, 0) + 1
    return sizes


def singleton_dimension(n: int, d: int) -> int:
    """k = n + 1 - d, truncated at 0."""
    return max(0, n + 1 - d)


# ---------------------------------------------------------------------------
# 2. Cut entropy (counting form, numerically stable)
# ---------------------------------------------------------------------------

def cut_entropy(code: Sequence[Word], cut: Cut) -> float:
    """H(S) in nats: entropy of the marginal that uniform-on-C induces on S.

    Uses the counting form  H = log m - (1/m) * sum_y f_y log f_y  with
    m = |C| and f_y the fibre sizes; this avoids dividing before taking logs.
    """
    m = len(code)
    if m == 0:
        return 0.0
    total = sum(f * math.log(f) for f in fibre_sizes(code, cut).values())
    return math.log(m) - total / m


# ---------------------------------------------------------------------------
# 3. The three defects
# ---------------------------------------------------------------------------

def counting_defect(code: Sequence[Word], q: int, d: int, cut: Cut) -> int:
    """delta(S) = q^(k-|S|) * r_C(S) - |C|, the slack in the counting bound."""
    k = singleton_dimension(len(code[0]), d)
    return q ** (k - len(cut)) * cut_rank(code, cut) - len(code)


def entropic_defect(code: Sequence[Word], q: int, d: int, cut: Cut) -> float:
    """Delta(S) = H(S) + (k-|S|) log q - log|C|, the slack in the entropic bound."""
    k = singleton_dimension(len(code[0]), d)
    return (cut_entropy(code, cut)
            + (k - len(cut)) * math.log(q)
            - math.log(len(code)))


def local_entropic_defect(code: Sequence[Word], q: int, cut: Cut) -> float:
    """|S| log q - H(S): how far the cut marginal is from fully uniform."""
    return len(cut) * math.log(q) - cut_entropy(code, cut)


# ---------------------------------------------------------------------------
# 4. The quantum code state and its entanglement entropy
# ---------------------------------------------------------------------------

def code_state_matrix(code: Sequence[Word], q: int, n: int,
                      cut: Cut) -> List[List[float]]:
    """Coefficient matrix M_S of |C> = |C|^(-1/2) sum_c |c> across the cut S.

    Rows are indexed by patterns on S, columns by patterns on the complement;
    the entry is |C|^(-1/2) when gluing the two half-patterns gives a codeword.
    """
    comp = tuple(i for i in range(n) if i not in cut)
    rows = list(product(range(q), repeat=len(cut)))
    cols = list(product(range(q), repeat=len(comp)))
    row_index = {a: i for i, a in enumerate(rows)}
    col_index = {b: j for j, b in enumerate(cols)}
    amp = 1.0 / math.sqrt(len(code))
    M = [[0.0] * len(cols) for _ in rows]
    for c in code:
        M[row_index[restrict(c, cut)]][col_index[restrict(c, comp)]] = amp
    return M


def _symmetric_eigenvalues(A: List[List[float]], sweeps: int = 60) -> List[float]:
    """Eigenvalues of a real symmetric matrix by the cyclic Jacobi method."""
    n = len(A)
    M = [row[:] for row in A]
    for _ in range(sweeps):
        off = math.sqrt(sum(M[i][j] ** 2
                            for i in range(n) for j in range(n) if i != j))
        if off < 1e-14:
            break
        for p in range(n - 1):
            for r in range(p + 1, n):
                if abs(M[p][r]) < 1e-15:
                    continue
                theta = (M[r][r] - M[p][p]) / (2.0 * M[p][r])
                t = math.copysign(1.0, theta) / (abs(theta) + math.sqrt(theta * theta + 1.0))
                c = 1.0 / math.sqrt(t * t + 1.0)
                s = t * c
                for k in range(n):
                    mkp, mkr = M[k][p], M[k][r]
                    M[k][p] = c * mkp - s * mkr
                    M[k][r] = s * mkp + c * mkr
                for k in range(n):
                    mpk, mrk = M[p][k], M[r][k]
                    M[p][k] = c * mpk - s * mrk
                    M[r][k] = s * mpk + c * mrk
    return sorted((M[i][i] for i in range(n)), reverse=True)


def reduced_density_matrix(M: List[List[float]]) -> List[List[float]]:
    """rho_S = M M^T for a real coefficient matrix."""
    rows = len(M)
    return [[sum(M[i][t] * M[j][t] for t in range(len(M[0])))
             for j in range(rows)] for i in range(rows)]


def entanglement_entropy(M: List[List[float]], tol: float = 1e-10) -> float:
    """von Neumann entropy of rho_S = M M^T, in nats."""
    evals = _symmetric_eigenvalues(reduced_density_matrix(M))
    return -sum(x * math.log(x) for x in evals if x > tol)


def schmidt_rank(M: List[List[float]], tol: float = 1e-10) -> int:
    """Rank of the coefficient matrix = number of nonzero Schmidt coefficients."""
    evals = _symmetric_eigenvalues(reduced_density_matrix(M))
    return sum(1 for x in evals if x > tol)


# ---------------------------------------------------------------------------
# 5. Example codebooks
# ---------------------------------------------------------------------------

def even_weight_code() -> Tuple[List[Word], int, int, int]:
    """The [3,2,2]_2 even-weight MDS code {000, 011, 101, 110}."""
    code = [c for c in product(range(2), repeat=3) if (c[0] + c[1] + c[2]) % 2 == 0]
    return code, 2, 3, 2  # code, q, n, d


def penta_code() -> Tuple[List[Word], int, int, int]:
    """The five-word code {000, 100, 010, 110, 001}: non-MDS, non-submodular."""
    code = [c for c in product(range(2), repeat=3)
            if c[2] == 0 or (c[0] == 0 and c[1] == 0)]
    return code, 2, 3, 1  # minimum distance is 1


def repetition_code(n: int, q: int) -> Tuple[List[Word], int, int, int]:
    """The [n, 1, n]_q repetition code: MDS with k = 1."""
    return [tuple([a] * n) for a in range(q)], q, n, n


def parity_check_code(n: int, q: int) -> Tuple[List[Word], int, int, int]:
    """The [n, n-1, 2]_q single-parity-check code: MDS with k = n - 1."""
    code = [c for c in product(range(q), repeat=n) if sum(c) % q == 0]
    return code, q, n, 2


def reed_solomon(q: int, k: int) -> Tuple[List[Word], int, int, int]:
    """Reed-Solomon evaluation code over Z_q (q prime): [q, k, q-k+1]_q, MDS."""
    points = list(range(q))
    code: List[Word] = []
    for coeffs in product(range(q), repeat=k):
        word = tuple(
            sum(coeffs[j] * pow(x, j, q) for j in range(k)) % q for x in points
        )
        code.append(word)
    return code, q, q, q - k + 1


# ---------------------------------------------------------------------------
# 6. Verification drivers
# ---------------------------------------------------------------------------

def fmt(x: float) -> str:
    return f"{x:8.5f}"


def check_cut_data_axioms(code: Sequence[Word], q: int, n: int) -> None:
    """Verify (A1) empty cut, (A2) monotonicity, (A3) one-site growth."""
    assert cut_rank(code, ()) <= 1, "axiom (A1) failed"
    for S in all_cuts(n):
        setS = set(S)
        for a in range(n):
            T = tuple(sorted(setS | {a}))
            assert cut_rank(code, S) <= cut_rank(code, T), "axiom (A2) failed"
            assert cut_rank(code, T) <= q * cut_rank(code, S), "axiom (A3) failed"
    print("  cut-data axioms (A1) empty, (A2) monotone, (A3) one-site growth: OK")


def report_profile(name: str, code: Sequence[Word], q: int, n: int, d: int) -> None:
    """Print the full cut profile of a code and verify all the inequalities."""
    k = singleton_dimension(n, d)
    mds = (len(code) == q ** k)
    print(f"\n{'=' * 78}")
    print(f"{name}:  n = {n}, q = {q}, d = {d}, k = n+1-d = {k}, "
          f"|C| = {len(code)}, q^k = {q ** k}   ->  MDS: {mds}")
    print("=" * 78)
    check_cut_data_axioms(code, q, n)

    header = (f"{'cut S':>12} {'|S|':>4} {'r_C(S)':>7} {'H(S)':>9} "
              f"{'log r(S)':>9} {'min(|S|,k)lq':>13} {'delta(S)':>9} {'Delta(S)':>9}")
    print("\n" + header)
    print("-" * len(header))
    for S in all_cuts(n):
        r = cut_rank(code, S)
        H = cut_entropy(code, S)
        plateau = min(len(S), k) * math.log(q)
        assert H <= plateau + 1e-12, "entropic plateau bound violated"
        assert H <= math.log(r) + 1e-12, "H(S) <= log r_C(S) violated"
        if len(S) <= k:
            dc = counting_defect(code, q, d, S)
            de = entropic_defect(code, q, d, S)
            assert dc >= 0, "counting cut-wise Singleton violated"
            assert de >= -1e-12, "entropic cut-wise Singleton violated"
            dc_s, de_s = f"{dc:9d}", fmt(de)
        else:
            dc_s, de_s = f"{'-':>9}", f"{'-':>9}"
        label = "{" + ",".join(str(i + 1) for i in S) + "}" if S else "{}"
        print(f"{label:>12} {len(S):>4} {r:>7} {fmt(H)} {fmt(math.log(r))} "
              f"{fmt(plateau)} {dc_s} {de_s}")

    # monotonicity and the chain rule for the entropy profile
    for S in all_cuts(n):
        for T in all_cuts(n):
            if set(S) <= set(T):
                HS, HT = cut_entropy(code, S), cut_entropy(code, T)
                assert HS <= HT + 1e-12, "entropy monotonicity violated"
                assert HT <= HS + (len(T) - len(S)) * math.log(q) + 1e-12, \
                    "entropic chain-rule bound violated"
    print("\n  entropy profile: monotone   H(S) <= H(T) for S subset T           : OK")
    print("  chain rule     : H(T) <= H(S) + (|T|-|S|) log q                   : OK")
    print("  counting cut-wise Singleton |C| <= q^(k-|S|) r(S)                 : OK")
    print("  entropic cut-wise Singleton log|C| <= H(S) + (k-|S|) log q        : OK")

    if mds:
        for S in all_cuts(n):
            if len(S) <= k:
                assert cut_rank(code, S) == q ** len(S), "MDS rigidity failed"
                for f in fibre_sizes(code, S).values():
                    assert f == q ** (k - len(S)), "MDS balanced fibres failed"
            assert abs(cut_entropy(code, S)
                       - min(len(S), k) * math.log(q)) < 1e-12, "plateau failed"
        print("  MDS rigidity   : r(S) = q^|S| and every fibre has q^(k-|S|) words: OK")
        print("  MDS plateau    : H(S) = min(|S|, k) log q at every cut          : OK")


def demo_one_cut_criterion(code: Sequence[Word], q: int, n: int, d: int) -> None:
    """H(S) = k log q at a single cut of size k iff the code is MDS."""
    k = singleton_dimension(n, d)
    print(f"\n--- one-cut MDS criterion (cuts of size exactly k = {k}) ---")
    target = k * math.log(q)
    mds = (len(code) == q ** k)
    for S in combinations(range(n), k):
        H = cut_entropy(code, S)
        verdict = abs(H - target) < 1e-12
        label = "{" + ",".join(str(i + 1) for i in S) + "}"
        print(f"  S = {label:<10} H(S) = {fmt(H)}   k log q = {fmt(target)}"
              f"   H(S) = k log q ? {verdict}   (code is MDS: {mds})")
        assert verdict == mds, "one-cut criterion failed"
    print("  criterion agrees with the MDS property at every cut of size k     : OK")


def demo_quantum_profile(code: Sequence[Word], q: int, n: int, d: int) -> None:
    """Classical staircase versus quantum tent."""
    k = singleton_dimension(n, d)
    print(f"\n--- quantum profile (units of log q = {math.log(q):.5f}) ---")
    print(f"{'cut S':>12} {'|S|':>4} {'H(S)/lq':>9} {'E(S)/lq':>9} "
          f"{'SchmidtRk':>10} {'bound/lq':>9}")
    lq = math.log(q)
    for S in all_cuts(n):
        M = code_state_matrix(code, q, n, S)
        E = entanglement_entropy(M)
        rk = schmidt_rank(M)
        H = cut_entropy(code, S)
        bound = min(len(S), k)
        assert E <= bound * lq + 1e-9, "quantum cut-wise Singleton violated"
        assert rk <= cut_rank(code, S), "Schmidt rank <= cut rank violated"
        assert rk <= q ** (n - len(S)), "purity bound violated"
        if len(S) <= min(k, d - 1):
            assert abs(E - len(S) * lq) < 1e-9, "MDS quantum saturation failed"
            assert rk == q ** len(S), "MDS Schmidt rank failed"
        label = "{" + ",".join(str(i + 1) for i in S) + "}" if S else "{}"
        print(f"{label:>12} {len(S):>4} {H / lq:9.5f} {E / lq:9.5f} "
              f"{rk:>10} {bound:9d}")
    print("  E(S) <= min(|S|, k) log q, rank(M_S) <= min(r_C(S), q^|S^c|)      : OK")
    print("  exact saturation E(S) = |S| log q for |S| <= min(k, d-1)          : OK")


def demo_strictness_and_submodularity() -> None:
    """The five-word code: entropic bound strictly sharper; rank not submodular."""
    code, q, n, d = penta_code()
    k = singleton_dimension(n, d)
    print(f"\n{'=' * 78}")
    print("Five-word code C = {000, 100, 010, 110, 001}: strictness and "
          "non-submodularity")
    print("=" * 78)
    print(f"  |C| = {len(code)}, q = {q}, n = {n}, d = {d}, k = {k}")

    S = (0,)
    fibres = fibre_sizes(code, S)
    H = cut_entropy(code, S)
    r = cut_rank(code, S)
    print(f"\n  cut S = {{1}}: fibre sizes {sorted(fibres.values(), reverse=True)}"
          f"  ->  marginal (3/5, 2/5)")
    print(f"    H(S)        = {H:.6f} nats")
    print(f"    log r_C(S)  = {math.log(r):.6f} nats")
    print(f"    gap         = {math.log(r) - H:.6f} > 0  "
          f"=> entropic bound is STRICTLY sharper")
    assert H < math.log(r) - 1e-6

    print(f"\n    entropic bound:  log|C| = {math.log(len(code)):.6f} "
          f"<= H(S) + (k-|S|) log q = {H + (k - 1) * math.log(q):.6f}")
    print(f"    counting bound:  log|C| = {math.log(len(code)):.6f} "
          f"<= log r(S) + (k-|S|) log q = "
          f"{math.log(r) + (k - 1) * math.log(q):.6f}")

    A, B = (0, 2), (1, 2)
    union = tuple(sorted(set(A) | set(B)))
    inter = tuple(sorted(set(A) & set(B)))
    rA, rB = cut_rank(code, A), cut_rank(code, B)
    rU, rI = cut_rank(code, union), cut_rank(code, inter)
    print(f"\n  submodularity test with S = {{1,3}}, T = {{2,3}}:")
    print(f"    r(S) r(T)           = {rA} * {rB} = {rA * rB}")
    print(f"    r(S u T) r(S n T)   = {rU} * {rI} = {rU * rI}")
    print(f"    => cut RANK is NOT submodular ({rA * rB} < {rU * rI})")
    assert rA * rB < rU * rI

    HA, HB = cut_entropy(code, A), cut_entropy(code, B)
    HU, HI = cut_entropy(code, union), cut_entropy(code, inter)
    print(f"    H(S) + H(T)         = {HA + HB:.6f}")
    print(f"    H(S u T) + H(S n T) = {HU + HI:.6f}")
    print(f"    => cut ENTROPY IS submodular here "
          f"(slack {HA + HB - HU - HI:.6f} >= 0)")
    assert HA + HB >= HU + HI - 1e-12


def demo_grouping_inequality() -> None:
    """Numerical check of the grouping (log-sum) inequality."""
    def eta(x: float) -> float:
        return 0.0 if x <= 0.0 else -x * math.log(x)

    print(f"\n{'=' * 78}")
    print("Grouping inequality:  sum_i eta(p_i) <= eta(A) + A log N,  "
          "A = sum p_i, |F| <= N")
    print("=" * 78)
    cases: List[Tuple[List[float], int]] = [
        ([0.25, 0.25], 2),          # equality case: |F| = N and uniform
        ([0.3, 0.1, 0.05], 4),
        ([0.5], 8),
        ([0.1, 0.1, 0.1, 0.1], 4),  # equality case
        ([0.0, 0.4], 3),
    ]
    for weights, N in cases:
        A = sum(weights)
        lhs = sum(eta(p) for p in weights)
        rhs = eta(A) + A * math.log(N)
        assert lhs <= rhs + 1e-12
        tag = "  <-- equality" if abs(rhs - lhs) < 1e-12 else ""
        print(f"  p = {str(weights):<28} N = {N}   "
              f"lhs = {lhs:9.6f} <= rhs = {rhs:9.6f}{tag}")
    print("  grouping inequality verified on all cases                         : OK")


# ---------------------------------------------------------------------------
# 7. Main
# ---------------------------------------------------------------------------

def main() -> None:
    print("#" * 78)
    print("#  CUT-INDEXED DEFECTS: cut rank, cut entropy, and the entangled cut  #")
    print("#" * 78)

    # (a) The even-weight code: the smallest non-degenerate MDS code.
    code, q, n, d = even_weight_code()
    report_profile("Even-weight code {000, 011, 101, 110}  (the [3,2,2]_2 MDS code)",
                   code, q, n, d)
    demo_one_cut_criterion(code, q, n, d)
    demo_quantum_profile(code, q, n, d)
    full = tuple(range(n))
    print(f"\n  entropic cut defect at the FULL cut: "
          f"|S| log q - H(S) = {local_entropic_defect(code, q, full):.6f} "
          f"= log 2 = {math.log(2):.6f}  (strictly positive!)")
    print("  the third bit carries no new information, and the defect sees it.")
    print("\n  classical profile (units of log 2): staircase 0, 1, 2, 2")
    print("  quantum   profile (units of log 2): tent      0, 1, 1, 0")
    print("  => the guard |S| < d in the quantum saturation theorem is SHARP.")

    # (b) The repetition and parity-check codes: the two extreme MDS families.
    code, q, n, d = repetition_code(4, 3)
    report_profile("Repetition code [4,1,4]_3", code, q, n, d)
    demo_one_cut_criterion(code, q, n, d)

    code, q, n, d = parity_check_code(4, 3)
    report_profile("Single-parity-check code [4,3,2]_3", code, q, n, d)
    demo_one_cut_criterion(code, q, n, d)

    # (c) A Reed-Solomon code: a genuinely non-trivial MDS instance.
    code, q, n, d = reed_solomon(5, 2)
    report_profile("Reed-Solomon code [5,2,4]_5", code, q, n, d)
    demo_one_cut_criterion(code, q, n, d)

    # (d) The five-word code: non-MDS, strictness, non-submodularity of rank.
    code, q, n, d = penta_code()
    report_profile("Five-word code {000, 100, 010, 110, 001}", code, q, n, d)
    demo_one_cut_criterion(code, q, n, d)
    demo_strictness_and_submodularity()

    # (e) The analytic engine.
    demo_grouping_inequality()

    print(f"\n{'#' * 78}")
    print("#  ALL CHECKS PASSED                                                     #")
    print("#" * 78)


if __name__ == "__main__":
    main()
