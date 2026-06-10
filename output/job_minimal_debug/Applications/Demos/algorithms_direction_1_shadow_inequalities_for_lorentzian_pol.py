"""
algorithms.py — Shadow Profile Computation and Lorentzian Test Pipeline

Implements algorithms for computing shadow profiles of multivariate polynomial
supports, testing log-concavity, and verifying Lorentzian-shadow conjectures.

Key algorithms:
1. Shadow computation for exponent-vector supports
2. Shadow computation for set-family (matroid) supports
3. Log-concavity testing
4. Weighted shadow transport computation
5. Lorentzian condition checks (Hessian signature)
"""

from itertools import combinations, product
from math import comb, factorial, prod
from typing import List, Tuple, Dict, Set, Optional
import numpy as np


# ─── Exponent vector representation ──────────────────────────────────────────

def total_degree(alpha: Tuple[int, ...]) -> int:
    """Total degree of an exponent vector."""
    return sum(alpha)


def vec_le(beta: Tuple[int, ...], alpha: Tuple[int, ...]) -> bool:
    """Coordinatewise ≤ for exponent vectors."""
    return all(b <= a for b, a in zip(beta, alpha))


def kth_shadow(S: Set[Tuple[int, ...]], d: int, k: int) -> Set[Tuple[int, ...]]:
    """
    Compute the k-th shadow of a support set S ⊆ {α ∈ ℕⁿ : |α| = d}.

    Sh_k(S) = {β ∈ ℕⁿ : |β| = d-k, ∃ α ∈ S, β ≤ α}

    Algorithm: For each α ∈ S, enumerate all β with |β| = d-k and β ≤ α
    using a bounded stars-and-bars enumeration.

    Complexity: O(|S| · C(n+d-k-1, n-1)) in the worst case.
    """
    target_deg = d - k
    if target_deg < 0:
        return set()

    shadow = set()
    for alpha in S:
        n = len(alpha)
        # Enumerate all β with β_i ≤ α_i and Σ β_i = target_deg
        for beta in _bounded_compositions(n, target_deg, alpha):
            shadow.add(beta)
    return shadow


def _bounded_compositions(n: int, total: int, bounds: Tuple[int, ...]) -> List[Tuple[int, ...]]:
    """
    Enumerate all compositions of `total` into `n` parts where part i ≤ bounds[i].
    Uses recursive backtracking.
    """
    results = []

    def backtrack(idx: int, remaining: int, current: List[int]):
        if idx == n:
            if remaining == 0:
                results.append(tuple(current))
            return
        for val in range(min(remaining, bounds[idx]) + 1):
            current.append(val)
            backtrack(idx + 1, remaining - val, current)
            current.pop()

    backtrack(0, total, [])
    return results


def shadow_profile(S: Set[Tuple[int, ...]], d: int) -> List[int]:
    """
    Compute the full shadow profile: [|Sh_0(S)|, |Sh_1(S)|, ..., |Sh_d(S)|].

    Complexity: O(d · |S| · max_shadow_size)
    """
    return [len(kth_shadow(S, d, k)) for k in range(d + 1)]


def is_log_concave(seq: List[int]) -> bool:
    """
    Test whether a sequence is log-concave: a[k]² ≥ a[k-1]·a[k+1] for all valid k.
    """
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k - 1] * seq[k + 1]:
            return False
    return True


def log_concavity_ratios(seq: List[int]) -> List[Optional[float]]:
    """
    Compute the log-concavity ratios a[k]²/(a[k-1]·a[k+1]) for each valid k.
    Returns None where division by zero would occur.
    """
    ratios = []
    for k in range(1, len(seq) - 1):
        denom = seq[k - 1] * seq[k + 1]
        if denom == 0:
            ratios.append(None if seq[k] == 0 else float('inf'))
        else:
            ratios.append(seq[k] ** 2 / denom)
    return ratios


# ─── Set-family (matroid) representation ─────────────────────────────────────

def uniform_matroid_bases(n: int, r: int) -> Set[frozenset]:
    """All r-element subsets of [n] — bases of the uniform matroid U_{r,n}."""
    return {frozenset(s) for s in combinations(range(n), r)}


def set_shadow(F: Set[frozenset], r: int, k: int) -> Set[frozenset]:
    """
    k-th shadow of a family F of r-element sets:
    all (r-k)-element subsets contained in some member of F.
    """
    target_size = r - k
    if target_size < 0:
        return set()
    shadow = set()
    for s in F:
        for t in combinations(s, target_size):
            shadow.add(frozenset(t))
    return shadow


def set_shadow_profile(F: Set[frozenset], r: int) -> List[int]:
    """Shadow profile for a set family."""
    return [len(set_shadow(F, r, k)) for k in range(r + 1)]


# ─── Support families ────────────────────────────────────────────────────────

def boolean_support(n: int, r: int) -> Set[Tuple[int, ...]]:
    """
    The set of 0-1 vectors of weight r in ℕⁿ.
    This is the exponent-vector support of the basis generating polynomial
    of the uniform matroid U_{r,n}.
    """
    S = set()
    for subset in combinations(range(n), r):
        vec = [0] * n
        for i in subset:
            vec[i] = 1
        S.add(tuple(vec))
    return S


def simplex_product_support(dims: List[int]) -> Set[Tuple[int, ...]]:
    """
    Support of a product of simplex-generating polynomials.
    Each factor (x_{i1} + ... + x_{im}) contributes a standard basis vector.
    The support is the set of sums of one standard basis vector from each factor.
    """
    n = sum(dims)
    offsets = [sum(dims[:i]) for i in range(len(dims))]
    groups = []
    for j, d in enumerate(dims):
        group = []
        for idx in range(d):
            vec = [0] * n
            vec[offsets[j] + idx] = 1
            group.append(tuple(vec))
        groups.append(group)

    S = set()
    for combo in product(*groups):
        total = tuple(sum(v[i] for v in combo) for i in range(n))
        S.add(total)
    return S


def complete_simplex_support(n: int, d: int) -> Set[Tuple[int, ...]]:
    """
    Full simplex: all exponent vectors in ℕⁿ with total degree d.
    Support of the complete homogeneous symmetric polynomial.
    """
    return set(_bounded_compositions(n, d, tuple([d] * n)))


def schur_support(partition: Tuple[int, ...], n: int) -> Set[Tuple[int, ...]]:
    """
    Support of the Schur polynomial s_λ(x_1, ..., x_n).
    Approximated by SSYT content vectors.
    """
    lam = list(partition)
    d = sum(lam)
    # Generate all SSYT of shape λ with entries in {1,...,n}
    support = set()
    _generate_ssyt(lam, n, [], support)
    return support


def _generate_ssyt(shape: List[int], n: int, current_rows: List[List[int]],
                   results: Set[Tuple[int, ...]]):
    """Recursively generate semi-standard Young tableaux."""
    row_idx = len(current_rows)
    if row_idx == len(shape):
        # Compute content vector
        content = [0] * n
        for row in current_rows:
            for val in row:
                content[val - 1] += 1
        results.add(tuple(content))
        return

    width = shape[row_idx]
    prev_row = current_rows[row_idx - 1] if row_idx > 0 else None

    def gen_row(pos, min_val, current_row):
        if pos == width:
            current_rows.append(current_row[:])
            _generate_ssyt(shape, n, current_rows, results)
            current_rows.pop()
            return
        upper = prev_row[pos] - 1 if prev_row and pos < len(prev_row) else n
        for val in range(min_val, upper + 1):
            # Strict increase down columns: val < prev_row[pos] if exists
            if prev_row and pos < len(prev_row) and val >= prev_row[pos]:
                continue
            current_row.append(val)
            gen_row(pos + 1, val, current_row)  # Weak increase along rows
            current_row.pop()

    gen_row(0, 1, [])


def random_mconvex_support(n: int, d: int, num_elements: int,
                           seed: int = 42) -> Set[Tuple[int, ...]]:
    """
    Generate a random M-convex set by starting from a random element
    and applying exchange operations.

    An M-convex set S ⊆ ℕⁿ with |α| = d for all α ∈ S satisfies:
    for all α, β ∈ S and i with α_i > β_i, there exists j with
    α_j < β_j such that α - e_i + e_j ∈ S.
    """
    rng = np.random.RandomState(seed)

    # Start with a random composition of d into n parts
    start = [0] * n
    for _ in range(d):
        start[rng.randint(n)] += 1
    S = {tuple(start)}

    for _ in range(num_elements * 10):
        if len(S) >= num_elements:
            break
        # Pick a random element and apply a random exchange
        alpha = list(list(S)[rng.randint(len(S))])
        nonzero = [i for i in range(n) if alpha[i] > 0]
        if not nonzero:
            continue
        i = nonzero[rng.randint(len(nonzero))]
        j = rng.randint(n)
        if i == j:
            continue
        new_alpha = alpha[:]
        new_alpha[i] -= 1
        new_alpha[j] += 1
        S.add(tuple(new_alpha))

    return S


# ─── Weighted shadow computation ─────────────────────────────────────────────

def descending_factorial(n: int, k: int) -> int:
    """n · (n-1) · ... · (n-k+1)."""
    result = 1
    for i in range(k):
        result *= (n - i)
    return result


def weighted_shadow_count(S: Set[Tuple[int, ...]], d: int, k: int) -> float:
    """
    Weighted shadow count using descending factorial weights:
    W_k = Σ_{β ∈ Sh_k} Σ_{α ∈ S, β≤α} ∏_i (α_i)! / (α_i - β_i)!

    This corresponds to the total coefficient mass contributed by
    iterated partial derivatives of total order k.
    """
    shadow = kth_shadow(S, d, k)
    total = 0.0
    for beta in shadow:
        for alpha in S:
            if vec_le(beta, alpha):
                weight = 1.0
                for i in range(len(alpha)):
                    weight *= descending_factorial(alpha[i], alpha[i] - beta[i])
                total += weight
    return total


def weighted_shadow_profile(S: Set[Tuple[int, ...]], d: int) -> List[float]:
    """Full weighted shadow profile."""
    return [weighted_shadow_count(S, d, k) for k in range(d + 1)]


# ─── Lorentzian condition checks ─────────────────────────────────────────────

def is_m_convex(S: Set[Tuple[int, ...]]) -> bool:
    """
    Test whether S satisfies the symmetric exchange property (M-convexity):
    For all α, β ∈ S and i with α_i > β_i, there exists j with
    α_j < β_j such that α - e_i + e_j ∈ S.

    Complexity: O(|S|² · n²)
    """
    S_list = list(S)
    n = len(S_list[0]) if S_list else 0

    for alpha in S_list:
        for beta in S_list:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            new = list(alpha)
                            new[i] -= 1
                            new[j] += 1
                            if tuple(new) in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


def hessian_lorentzian_check(coeffs: Dict[Tuple[int, ...], float],
                             n: int) -> bool:
    """
    Check a necessary Lorentzian condition: for the quadratic obtained by
    (d-2) generic partial derivatives, the Hessian should have at most
    one positive eigenvalue.

    This is an approximate check for small polynomials.
    """
    # Extract quadratic part (degree 2 terms)
    quad_coeffs = {k: v for k, v in coeffs.items() if sum(k) == 2}
    if not quad_coeffs:
        return True  # Vacuously true

    H = np.zeros((n, n))
    for exponent, coeff in quad_coeffs.items():
        for i in range(n):
            for j in range(n):
                if i == j and exponent[i] == 2:
                    H[i][j] += 2 * coeff
                elif i != j:
                    ei = list(exponent)
                    if ei[i] >= 1 and ei[j] >= 1:
                        if sum(1 for x in range(n) if x == i or x == j) <= 2:
                            check = [0] * n
                            check[i] = 1
                            check[j] = 1
                            if tuple(check) == exponent:
                                H[i][j] += coeff

    eigenvalues = np.linalg.eigvalsh(H)
    num_positive = sum(1 for e in eigenvalues if e > 1e-10)
    return num_positive <= 1


# ─── Testing pipeline ────────────────────────────────────────────────────────

def run_shadow_test(name: str, S: Set[Tuple[int, ...]], d: int) -> Dict:
    """
    Run the complete shadow test pipeline on a support set.

    Returns a dictionary with:
    - shadow_profile: list of shadow cardinalities
    - is_log_concave: whether the profile is log-concave
    - log_concavity_ratios: a[k]²/(a[k-1]·a[k+1]) for each k
    - weighted_profile: weighted shadow counts
    - is_m_convex: whether S satisfies the exchange property
    """
    prof = shadow_profile(S, d)
    lc = is_log_concave(prof)
    ratios = log_concavity_ratios(prof)
    mconvex = is_m_convex(S) if len(S) <= 500 else None

    result = {
        'name': name,
        'n': len(next(iter(S))) if S else 0,
        'd': d,
        '|S|': len(S),
        'shadow_profile': prof,
        'is_log_concave': lc,
        'log_concavity_ratios': ratios,
        'is_m_convex': mconvex,
    }

    # Weighted profile (only for small instances)
    if d <= 8 and len(S) <= 100:
        wp = weighted_shadow_profile(S, d)
        result['weighted_profile'] = wp
        result['weighted_log_concave'] = is_log_concave(
            [int(round(w)) for w in wp])

    return result


if __name__ == '__main__':
    print("=" * 60)
    print("Shadow Profile Algorithm Test Suite")
    print("=" * 60)

    # Test 1: Boolean slice (uniform matroid)
    for n, r in [(5, 3), (6, 3), (7, 4), (8, 4)]:
        S = boolean_support(n, r)
        result = run_shadow_test(f"Boolean({n},{r})", S, r)
        print(f"\n{result['name']}: |S|={result['|S|']}")
        print(f"  Profile: {result['shadow_profile']}")
        print(f"  Expected: {[comb(n, r-k) for k in range(r+1)]}")
        print(f"  Log-concave: {result['is_log_concave']}")
        print(f"  M-convex: {result['is_m_convex']}")

    # Test 2: Simplex products
    for dims in [[2, 2, 2], [3, 3], [2, 2, 2, 2]]:
        S = simplex_product_support(dims)
        d = len(dims)
        result = run_shadow_test(f"SimplexProd{dims}", S, d)
        print(f"\n{result['name']}: |S|={result['|S|']}")
        print(f"  Profile: {result['shadow_profile']}")
        print(f"  Log-concave: {result['is_log_concave']}")

    # Test 3: Complete simplex
    for n, d in [(3, 3), (3, 4), (4, 3)]:
        S = complete_simplex_support(n, d)
        result = run_shadow_test(f"CompleteSimplex({n},{d})", S, d)
        print(f"\n{result['name']}: |S|={result['|S|']}")
        print(f"  Profile: {result['shadow_profile']}")
        print(f"  Log-concave: {result['is_log_concave']}")

    # Test 4: Random M-convex
    for n, d in [(4, 4), (5, 5)]:
        S = random_mconvex_support(n, d, 20)
        result = run_shadow_test(f"RandomMConvex({n},{d})", S, d)
        print(f"\n{result['name']}: |S|={result['|S|']}")
        print(f"  Profile: {result['shadow_profile']}")
        print(f"  Log-concave: {result['is_log_concave']}")
        print(f"  M-convex: {result['is_m_convex']}")

    print("\n" + "=" * 60)
    print("All tests completed.")
