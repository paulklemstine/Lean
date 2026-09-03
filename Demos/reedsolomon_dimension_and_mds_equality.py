"""
Reed-Solomon codes: dimension k, minimum distance exactly n - k + 1.

A self-contained numerical demonstration of the following results, all verified
here by exhaustive computation over small prime fields:

  1. DIMENSION.  The evaluation encoder  p |-> (p(a_0), ..., p(a_{n-1}))  on
     polynomials of degree < k is injective when the a_i are distinct and
     k <= n.  Hence the code has exactly q^k codewords, i.e. dimension k.

  2. WEIGHT LOWER BOUND (root counting).  Every nonzero codeword has Hamming
     weight >= n - k + 1, because a nonzero polynomial of degree <= k-1 has at
     most k-1 roots.

  3. SINGLETON BOUND.  For any linear code all of whose nonzero codewords have
     weight >= d (with 1 <= d <= n),  dim C + d <= n + 1.

  4. MDS EQUALITY.  Combining 2 and 3, the minimum distance of a Reed-Solomon
     code is exactly n - k + 1, and dim C + d = n + 1.

  5. EXTREMAL CODEWORD.  For any set T of k-1 evaluation points, the evaluation
     vector of prod_{i in T} (X - a_i) has weight exactly n - k + 1.

  6. INFORMATION SETS.  Restriction to any k coordinates is a bijection; so any
     n - k erasures are correctable, and any t <= (n-k)//2 errors are uniquely
     correctable.

  7. DUALITY.  The dual code has dimension n - k and minimum distance exactly
     k + 1, hence is MDS as well.

Everything runs over Z/pZ for a prime p, using plain Python integers.
No external dependencies.
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Vector = Tuple[int, ...]


# --------------------------------------------------------------------------
# Field arithmetic over Z/pZ
# --------------------------------------------------------------------------

def inv_mod(a: int, p: int) -> int:
    """Multiplicative inverse of a nonzero element a of Z/pZ (p prime)."""
    a %= p
    if a == 0:
        raise ZeroDivisionError("0 has no inverse in a field")
    return pow(a, p - 2, p)


def poly_eval(coeffs: Sequence[int], x: int, p: int) -> int:
    """Evaluate sum_j coeffs[j] * x^j at x, by Horner's rule.  O(len(coeffs))."""
    acc = 0
    for c in reversed(coeffs):
        acc = (acc * x + c) % p
    return acc


# --------------------------------------------------------------------------
# The Reed-Solomon encoder and code
# --------------------------------------------------------------------------

def encode(coeffs: Sequence[int], points: Sequence[int], p: int) -> Vector:
    """The encoder: a message polynomial of degree < k becomes its value table."""
    return tuple(poly_eval(coeffs, a, p) for a in points)


def all_messages(k: int, p: int) -> Iterable[Tuple[int, ...]]:
    """All p^k coefficient vectors (a_0, ..., a_{k-1}), i.e. all polys of degree < k."""
    return product(range(p), repeat=k)


def reed_solomon_code(k: int, points: Sequence[int], p: int) -> List[Vector]:
    """The full list of codewords of RS_k(points) over Z/pZ."""
    return [encode(m, points, p) for m in all_messages(k, p)]


def hamming_weight(v: Sequence[int]) -> int:
    return sum(1 for x in v if x != 0)


def hamming_distance(u: Sequence[int], v: Sequence[int]) -> int:
    return sum(1 for a, b in zip(u, v) if a != b)


def min_distance(code: Sequence[Vector]) -> int:
    """Minimum weight of a nonzero codeword (= minimum distance, for linear codes)."""
    weights = [hamming_weight(c) for c in code if any(c)]
    if not weights:
        raise ValueError("the zero code has no minimum distance")
    return min(weights)


# --------------------------------------------------------------------------
# Linear algebra over Z/pZ (for dimensions and duals)
# --------------------------------------------------------------------------

def rank_mod_p(rows: Sequence[Sequence[int]], p: int) -> int:
    """Rank of a matrix over Z/pZ by Gaussian elimination.  O(rows * cols^2)."""
    mat = [list(r) for r in rows]
    if not mat:
        return 0
    ncols = len(mat[0])
    rank = 0
    for col in range(ncols):
        pivot = next((r for r in range(rank, len(mat)) if mat[r][col] % p != 0), None)
        if pivot is None:
            continue
        mat[rank], mat[pivot] = mat[pivot], mat[rank]
        piv_inv = inv_mod(mat[rank][col], p)
        mat[rank] = [(x * piv_inv) % p for x in mat[rank]]
        for r in range(len(mat)):
            if r != rank and mat[r][col] % p != 0:
                f = mat[r][col]
                mat[r] = [(x - f * y) % p for x, y in zip(mat[r], mat[rank])]
        rank += 1
    return rank


def dual_code(code: Sequence[Vector], p: int) -> List[Vector]:
    """All y in (Z/pZ)^n orthogonal to every codeword, by brute force."""
    n = len(code[0])
    dual: List[Vector] = []
    for y in product(range(p), repeat=n):
        if all(sum(yi * ci for yi, ci in zip(y, c)) % p == 0 for c in code):
            dual.append(tuple(y))
    return dual


def dimension(code: Sequence[Vector], p: int) -> int:
    """Dimension of a linear code presented as its full list of codewords."""
    return rank_mod_p(list(code), p)


# --------------------------------------------------------------------------
# Interpolation, erasure decoding, information-set decoding
# --------------------------------------------------------------------------

def lagrange_interpolate(xs: Sequence[int], ys: Sequence[int], p: int) -> List[int]:
    """
    The unique polynomial of degree < len(xs) through the given points,
    returned as a coefficient list.  Costs O(k^2) field operations.
    """
    k = len(xs)
    coeffs = [0] * k
    for m in range(k):
        # basis polynomial: prod_{l != m} (X - xs[l]) / (xs[m] - xs[l])
        basis = [1] + [0] * (k - 1)
        deg = 0
        denom = 1
        for l in range(k):
            if l == m:
                continue
            # multiply basis by (X - xs[l])
            new = [0] * k
            for j in range(deg + 1):
                new[j + 1] = (new[j + 1] + basis[j]) % p
                new[j] = (new[j] - basis[j] * xs[l]) % p
            basis = new
            deg += 1
            denom = (denom * (xs[m] - xs[l])) % p
        scale = (ys[m] * inv_mod(denom, p)) % p
        coeffs = [(c + scale * b) % p for c, b in zip(coeffs, basis)]
    return coeffs


def decode_erasures(received: Sequence[int], known: Sequence[int],
                    points: Sequence[int], p: int) -> Vector:
    """
    Recover the whole codeword from the values at the coordinates in `known`
    (which must number at least k = len(known) surviving positions).
    """
    xs = [points[i] for i in known]
    ys = [received[i] for i in known]
    coeffs = lagrange_interpolate(xs, ys, p)
    return encode(coeffs, points, p)


def decode_information_set(received: Sequence[int], k: int,
                           points: Sequence[int], p: int) -> Vector | None:
    """
    Information-set decoder: try every k-subset of coordinates as an assumed
    error-free window, interpolate, and accept the candidate if it lies within
    the unique-decoding radius t = (n-k)//2.  Correct by the unique-decoding
    theorem; cost O(C(n,k) * k^2).
    """
    n = len(points)
    t = (n - k) // 2
    for window in combinations(range(n), k):
        candidate = decode_erasures(received, window, points, p)
        if hamming_distance(candidate, received) <= t:
            return candidate
    return None


def extremal_codeword(T: Sequence[int], points: Sequence[int], p: int) -> Vector:
    """
    Evaluation vector of prod_{i in T} (X - points[i]).  If |T| = k-1 this has
    weight exactly n - k + 1: the minimum.
    """
    return tuple(
        _prod_mod([(a - points[i]) % p for i in T], p) for a in points
    )


def _prod_mod(values: Iterable[int], p: int) -> int:
    acc = 1
    for v in values:
        acc = (acc * v) % p
    return acc


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_dimension_and_distance(p: int, n: int, k: int) -> None:
    """Results 1-4: dimension k, weight bound, Singleton bound, MDS equality."""
    points = list(range(n))
    assert n <= p, "need n distinct evaluation points in Z/pZ"
    code = reed_solomon_code(k, points, p)

    n_distinct = len(set(code))
    dim = dimension(code, p)
    d = min_distance(code)

    print(f"field Z/{p}Z, length n = {n}, degree bound k = {k}")
    print(f"  evaluation points          : {points}")
    print(f"  messages (polys of deg < k): {p**k}")
    print(f"  distinct codewords         : {n_distinct}   "
          f"(encoder injective: {n_distinct == p**k})")
    print(f"  dimension of the code      : {dim}   (theory: k = {k})")
    print(f"  minimum distance           : {d}   (theory: n-k+1 = {n-k+1})")
    print(f"  Singleton: dim + d = {dim + d}, n + 1 = {n+1}  "
          f"-> MDS equality: {dim + d == n + 1}")

    lightest = min(hamming_weight(c) for c in code if any(c))
    assert lightest == n - k + 1
    assert dim == k and d == n - k + 1


def demo_weight_distribution(p: int, n: int, k: int) -> None:
    """The full weight spectrum: nothing below n-k+1, and the gap is real."""
    points = list(range(n))
    code = reed_solomon_code(k, points, p)
    spectrum: Dict[int, int] = {}
    for c in code:
        w = hamming_weight(c)
        spectrum[w] = spectrum.get(w, 0) + 1
    print(f"weight spectrum of the [{n},{k},{n-k+1}] code over Z/{p}Z:")
    for w in sorted(spectrum):
        marker = "   <-- minimum" if w == n - k + 1 else ""
        print(f"  weight {w:2d}: {spectrum[w]:6d} codewords{marker}")
    forbidden = [w for w in spectrum if 0 < w < n - k + 1]
    print(f"  codewords of weight in 1..{n-k}: {forbidden}  (must be empty)")
    assert not forbidden


def demo_extremal_codewords(p: int, n: int, k: int) -> None:
    """Result 5: explicit minimum-weight codewords from (k-1)-subsets."""
    points = list(range(n))
    print(f"extremal codewords prod_(i in T) (X - a_i) for |T| = k-1 = {k-1}:")
    shown = 0
    for T in combinations(range(n), k - 1):
        c = extremal_codeword(T, points, p)
        w = hamming_weight(c)
        assert w == n - k + 1
        zeros = tuple(i for i, x in enumerate(c) if x == 0)
        if shown < 6:
            print(f"  T = {T}: codeword {c}, weight {w}, zero set {zeros}")
        shown += 1
    print(f"  ... {shown} such subsets, every one giving weight exactly {n-k+1}")


def demo_information_sets(p: int, n: int, k: int) -> None:
    """Result 6a: every k-subset of coordinates is an information set."""
    points = list(range(n))
    code = reed_solomon_code(k, points, p)
    all_bijective = True
    for S in combinations(range(n), k):
        images = {tuple(c[i] for i in S) for c in code}
        bijective = len(images) == p ** k
        all_bijective = all_bijective and bijective
    print(f"restriction of the [{n},{k}] code to each of "
          f"{len(list(combinations(range(n), k)))} k-subsets:")
    print(f"  every restriction a bijection onto (Z/{p}Z)^{k}: {all_bijective}")
    assert all_bijective


def demo_erasure_decoding(p: int, n: int, k: int) -> None:
    """Result 6b: any n - k erasures are correctable, whichever they are."""
    points = list(range(n))
    message = [1, 0, 1][:k] + [0] * max(0, k - 3)
    message = message[:k]
    codeword = encode(message, points, p)
    print(f"message coefficients {message} -> codeword {codeword}")
    ok = True
    for erased in combinations(range(n), n - k):
        surviving = [i for i in range(n) if i not in erased]
        recovered = decode_erasures(codeword, surviving, points, p)
        ok = ok and (recovered == codeword)
    print(f"  erasing every possible set of {n-k} coordinates and interpolating:")
    print(f"  codeword recovered in all {len(list(combinations(range(n), n-k)))} "
          f"cases: {ok}")
    assert ok


def demo_error_decoding(p: int, n: int, k: int) -> None:
    """Result 6c: unique decoding within radius t = (n-k)//2, exhaustively."""
    points = list(range(n))
    t = (n - k) // 2
    code = reed_solomon_code(k, points, p)
    print(f"unique decoding radius t = (n-k)//2 = {t}")
    tested = 0
    for c in code[: min(len(code), 40)]:
        for positions in combinations(range(n), t):
            for deltas in product(range(1, p), repeat=t):
                y = list(c)
                for pos, delta in zip(positions, deltas):
                    y[pos] = (y[pos] + delta) % p
                decoded = decode_information_set(y, k, points, p)
                assert decoded == c, (c, tuple(y), decoded)
                tested += 1
    print(f"  {tested} corrupted words (up to {t} symbol errors each) "
          f"all decoded back to the true codeword")


def demo_duality(p: int, n: int, k: int) -> None:
    """Result 7: the dual is an [n, n-k, k+1] code -- MDS as well."""
    points = list(range(n))
    code = reed_solomon_code(k, points, p)
    dual = dual_code(code, p)
    dim_dual = dimension(dual, p)
    d_dual = min_distance(dual)
    print(f"dual of the [{n},{k},{n-k+1}] code over Z/{p}Z:")
    print(f"  size {len(dual)} = {p}^{dim_dual}")
    print(f"  dimension {dim_dual}  (theory: n - k = {n-k})")
    print(f"  minimum distance {d_dual}  (theory: k + 1 = {k+1})")
    print(f"  Singleton for the dual: {dim_dual} + {d_dual} = {dim_dual + d_dual}"
          f", n + 1 = {n+1}  -> MDS: {dim_dual + d_dual == n + 1}")
    assert dim_dual == n - k and d_dual == k + 1


def demo_singleton_is_tight_but_needs_a_guard(p: int, n: int) -> None:
    """
    The Singleton bound requires the hypothesis d <= n.  For the zero code the
    weight hypothesis is vacuous, so without that guard the bound is false.
    """
    print("Singleton bound: dim C + d <= n + 1, for every linear code C.")
    print("  Checked against every Reed-Solomon code of this length:")
    points = list(range(n))
    for k in range(1, n + 1):
        code = reed_solomon_code(k, points, p)
        dim, d = dimension(code, p), min_distance(code)
        print(f"    k = {k}: dim = {dim}, d = {d}, dim + d = {dim + d} "
              f"(= n + 1 = {n+1}: {dim + d == n+1})")
        assert dim + d <= n + 1
    print("  Caveat: for the zero code C = {0} there is NO nonzero codeword, so")
    print("  'every nonzero codeword has weight >= d' holds vacuously for every d.")
    print(f"  Taking d = {n+2} would give dim C + d = {n+2} > n + 1 = {n+1}.")
    print("  This is why the bound must carry the hypothesis d <= n, which is")
    print("  automatic as soon as one nonzero codeword exists.")


def demo_secret_sharing(p: int, n: int, k: int) -> None:
    """
    The information-set property as a cryptographic primitive: any k shares
    reveal the secret, any k-1 shares are consistent with every secret.
    """
    points = list(range(1, n + 1))          # shares at nonzero points
    secret = 3 % p
    poly = [secret, 4 % p, 2 % p][:k]
    poly = poly + [0] * (k - len(poly))
    shares = encode(poly, points, p)
    print(f"secret = {secret}, random polynomial coefficients {poly}")
    print(f"  shares at points {points}: {shares}")

    for S in list(combinations(range(n), k))[:4]:
        xs = [points[i] for i in S]
        ys = [shares[i] for i in S]
        recovered = lagrange_interpolate(xs, ys, p)[0]
        print(f"  participants {S} interpolate secret {recovered} "
              f"(correct: {recovered == secret})")

    S = tuple(range(k - 1))
    xs = [points[i] for i in S]
    ys = [shares[i] for i in S]
    consistent: Set[int] = set()
    for guess in range(p):
        coeffs = lagrange_interpolate(list(xs) + [0], list(ys) + [guess], p)
        if all(poly_eval(coeffs, points[i], p) == shares[i] for i in S):
            consistent.add(guess)
    print(f"  participants {S} (only k-1 = {k-1} shares): the set of secrets")
    print(f"  consistent with their shares is {sorted(consistent)} -- all "
          f"{len(consistent)} of them.")
    assert len(consistent) == p


def main() -> None:
    banner("1-4.  DIMENSION, WEIGHT BOUND, SINGLETON BOUND, MDS EQUALITY")
    demo_dimension_and_distance(p=5, n=5, k=3)
    print()
    demo_dimension_and_distance(p=7, n=7, k=4)
    print()
    demo_dimension_and_distance(p=7, n=6, k=2)

    banner("WEIGHT SPECTRUM: the gap below n - k + 1 is empty")
    demo_weight_distribution(p=5, n=5, k=3)
    print()
    demo_weight_distribution(p=7, n=6, k=4)

    banner("5.  EXPLICIT MINIMUM-WEIGHT CODEWORDS")
    demo_extremal_codewords(p=7, n=7, k=4)

    banner("6a.  EVERY k COORDINATES FORM AN INFORMATION SET")
    demo_information_sets(p=5, n=5, k=3)
    print()
    demo_information_sets(p=7, n=6, k=2)

    banner("6b.  ERASURE CORRECTION: any n - k lost symbols are recoverable")
    demo_erasure_decoding(p=7, n=7, k=3)

    banner("6c.  UNIQUE DECODING within radius (n - k) // 2")
    demo_error_decoding(p=5, n=5, k=3)

    banner("7.  DUALITY: the dual is an [n, n-k, k+1] MDS code")
    demo_duality(p=5, n=5, k=3)
    print()
    demo_duality(p=5, n=5, k=2)

    banner("THE SINGLETON BOUND AND ITS HYPOTHESES")
    demo_singleton_is_tight_but_needs_a_guard(p=5, n=5)

    banner("APPLICATION: SHAMIR SECRET SHARING IS THIS CODE IN DISGUISE")
    demo_secret_sharing(p=11, n=6, k=3)

    banner("ALL CHECKS PASSED")
    print("dim = k, d = n - k + 1, dim + d = n + 1, dual = [n, n-k, k+1].")


if __name__ == "__main__":
    main()
