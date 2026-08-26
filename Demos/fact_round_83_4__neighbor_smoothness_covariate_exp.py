"""
Numerical demonstrations for certified null results in feature augmentation.

Everything in this file is self-contained: no third-party packages are required
(the standard library only), and every helper function is inlined.

The six demonstrations correspond to the main theorems:

  1. Block ceiling        : Delta R^2 <= k rho^2 (1 - R0^2) / lambda.
  2. Block dichotomy      : lift > 0  <=>  some covariate correlates with the residual.
  3. Conditional dominance: an orthogonal feature keeps its full lift after the block.
  4. Permutation null     : mean shuffle increment is exactly (1 - R0^2) / (n - 1).
  5. Nonlinear ceiling    : best fit over ALL functions of a feature = within-cell SS.
  6. Arithmetic freedom   : a residue dial value coexists with arbitrarily rich
                            neighbour factorisations (explicit CRT construction).

Finally the reported design constants of the motivating sieve-yield experiment are
plugged into the certificates.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Hashable, List, Sequence, Tuple

Vector = List[float]

# ----------------------------------------------------------------------------------
# Linear algebra on the sample inner product
# ----------------------------------------------------------------------------------


def dot(u: Sequence[float], w: Sequence[float]) -> float:
    """Sample inner product <u, w> = sum_i u_i w_i."""
    return sum(a * b for a, b in zip(u, w))


def sq_norm(u: Sequence[float]) -> float:
    """Squared sample norm ||u||^2."""
    return dot(u, u)


def mean(u: Sequence[float]) -> float:
    return sum(u) / len(u)


def centre(u: Sequence[float]) -> Vector:
    """Subtract the mean, producing a centred vector."""
    m = mean(u)
    return [a - m for a in u]


def tss(y: Sequence[float]) -> float:
    """Total sum of squares of the response."""
    return sq_norm(centre(y))


def solve_least_squares(cols: Sequence[Sequence[float]], target: Sequence[float]) -> Vector:
    """Solve the normal equations for the design whose columns are `cols`.

    Uses Gaussian elimination with partial pivoting on the (k x k) Gram system,
    with a tiny ridge for numerical safety on singular designs.
    """
    k = len(cols)
    gram = [[dot(cols[i], cols[j]) for j in range(k)] for i in range(k)]
    rhs = [dot(cols[i], target) for i in range(k)]
    for i in range(k):
        gram[i][i] += 1e-12
    aug = [gram[i] + [rhs[i]] for i in range(k)]
    for col in range(k):
        pivot = max(range(col, k), key=lambda r: abs(aug[r][col]))
        aug[col], aug[pivot] = aug[pivot], aug[col]
        pv = aug[col][col]
        if abs(pv) < 1e-14:
            continue
        for r in range(k):
            if r == col:
                continue
            factor = aug[r][col] / pv
            for c in range(col, k + 1):
                aug[r][c] -= factor * aug[col][c]
    return [aug[i][k] / aug[i][i] if abs(aug[i][i]) > 1e-14 else 0.0 for i in range(k)]


def rss_linear(y: Sequence[float], baseline: Sequence[float],
               block: Sequence[Sequence[float]]) -> float:
    """Residual sum of squares of the best fit  baseline + span(block)."""
    residual = [a - b for a, b in zip(y, baseline)]
    if not block:
        return sq_norm(residual)
    coeffs = solve_least_squares(block, residual)
    fitted = [sum(c * v[i] for c, v in zip(coeffs, block)) for i in range(len(y))]
    return sq_norm([r - f for r, f in zip(residual, fitted)])


def r_squared(y: Sequence[float], baseline: Sequence[float],
              block: Sequence[Sequence[float]]) -> float:
    """R^2 of the best fit  baseline + span(block)."""
    return 1.0 - rss_linear(y, baseline, block) / tss(y)


def gram_min_eigenvalue(block: Sequence[Sequence[float]]) -> float:
    """Smallest eigenvalue of the Gram matrix, by symmetric QR-free Jacobi rotation."""
    k = len(block)
    a = [[dot(block[i], block[j]) for j in range(k)] for i in range(k)]
    for _ in range(200):
        off = max(((i, j) for i in range(k) for j in range(k) if i != j),
                  key=lambda ij: abs(a[ij[0]][ij[1]]), default=None)
        if off is None:
            break
        p, q = off
        if abs(a[p][q]) < 1e-14:
            break
        theta = 0.5 * math.atan2(2 * a[p][q], a[q][q] - a[p][p])
        c, s = math.cos(theta), math.sin(theta)
        rot = [[1.0 if i == j else 0.0 for j in range(k)] for i in range(k)]
        rot[p][p], rot[q][q], rot[p][q], rot[q][p] = c, c, s, -s
        a = [[sum(rot[m][i] * a[i][j] for i in range(k)) for j in range(k)] for m in range(k)]
        a = [[sum(a[i][j] * rot[m][j] for j in range(k)) for m in range(k)] for i in range(k)]
    return min(a[i][i] for i in range(k))


def gram_schmidt(block: Sequence[Sequence[float]]) -> List[Vector]:
    """Orthonormalise a block with respect to the sample inner product."""
    out: List[Vector] = []
    for v in block:
        w = list(v)
        for u in out:
            coeff = dot(w, u)
            w = [a - coeff * b for a, b in zip(w, u)]
        nrm = math.sqrt(sq_norm(w))
        if nrm > 1e-12:
            out.append([a / nrm for a in w])
    return out


# ----------------------------------------------------------------------------------
# 1. The block ceiling
# ----------------------------------------------------------------------------------


def demo_block_ceiling(seed: int = 20260826, trials: int = 400) -> None:
    """Delta R^2 <= k rho^2 (1 - R0^2) / lambda, checked on random designs."""
    print("=" * 78)
    print("1. BLOCK CEILING:  Delta R^2  <=  k rho^2 (1 - R0^2) / lambda")
    print("=" * 78)
    rng = random.Random(seed)
    n, k = 60, 4
    worst_slack = float("inf")
    for _ in range(trials):
        y = centre([rng.gauss(0.0, 1.0) for _ in range(n)])
        g = centre([rng.gauss(0.0, 0.6) for _ in range(n)])
        raw = [[rng.gauss(0.0, 1.0) for _ in range(n)] for _ in range(k)]
        block = gram_schmidt([centre(v) for v in raw])          # lambda = 1
        residual = [a - b for a, b in zip(y, g)]
        r0 = 1.0 - sq_norm(residual) / tss(y)
        rho = max(abs(dot(residual, v)) / math.sqrt(sq_norm(residual)) for v in block)
        ceiling = k * rho ** 2 * (1.0 - r0) / 1.0
        observed = r_squared(y, g, block) - r0
        worst_slack = min(worst_slack, ceiling - observed)
    print(f"  random trials              : {trials}  (n = {n}, k = {k}, orthonormal block)")
    print(f"  minimum ceiling - observed : {worst_slack:+.6e}")
    print(f"  ceiling never violated     : {worst_slack >= -1e-9}")

    # A collinear block: lambda < 1, so the honest ceiling is larger by 1/lambda.
    y = centre([rng.gauss(0.0, 1.0) for _ in range(n)])
    g = centre([rng.gauss(0.0, 0.6) for _ in range(n)])
    base = centre([rng.gauss(0.0, 1.0) for _ in range(n)])
    collinear = [[base[i] + 0.25 * rng.gauss(0.0, 1.0) for i in range(n)] for _ in range(k)]
    collinear = [[a / math.sqrt(sq_norm(v)) for a in v] for v in collinear]
    lam = gram_min_eigenvalue(collinear)
    residual = [a - b for a, b in zip(y, g)]
    r0 = 1.0 - sq_norm(residual) / tss(y)
    rho = max(abs(dot(residual, v)) / math.sqrt(sq_norm(residual)) for v in collinear)
    observed = r_squared(y, g, collinear) - r0
    naive = k * rho ** 2 * (1.0 - r0)
    honest = naive / lam
    print(f"  collinear block: lambda      = {lam:.6f}")
    print(f"    observed lift              = {observed:.6f}")
    print(f"    bound assuming lambda = 1  = {naive:.6f}")
    print(f"    honest ceiling (/ lambda)  = {honest:.6f}   valid = {observed <= honest + 1e-9}")
    print()


# ----------------------------------------------------------------------------------
# 2. The block dichotomy
# ----------------------------------------------------------------------------------


def demo_dichotomy(seed: int = 7) -> None:
    """A block lifts R^2 iff some covariate correlates with the baseline residual."""
    print("=" * 78)
    print("2. BLOCK DICHOTOMY:  lift > 0  <=>  some <r, v_j> != 0")
    print("=" * 78)
    rng = random.Random(seed)
    n = 40
    y = centre([rng.gauss(0.0, 1.0) for _ in range(n)])
    g = centre([rng.gauss(0.0, 0.5) for _ in range(n)])
    residual = [a - b for a, b in zip(y, g)]
    r0 = 1.0 - sq_norm(residual) / tss(y)

    # (a) a block engineered to be orthogonal to the residual
    raw = [[rng.gauss(0.0, 1.0) for _ in range(n)] for _ in range(3)]
    orth_block: List[Vector] = []
    for v in raw:
        coeff = dot(v, residual) / sq_norm(residual)
        orth_block.append([a - coeff * b for a, b in zip(v, residual)])
    orth_block = gram_schmidt(orth_block)
    lift_orth = r_squared(y, g, orth_block) - r0
    max_corr_orth = max(abs(dot(residual, v)) for v in orth_block)

    # (b) a block containing one covariate that does correlate
    tilted = list(orth_block)
    tilted[0] = [a + 0.3 * b for a, b in zip(tilted[0], residual)]
    tilted = gram_schmidt(tilted)
    lift_tilt = r_squared(y, g, tilted) - r0
    max_corr_tilt = max(abs(dot(residual, v)) for v in tilted)

    print(f"  orthogonal block : max |<r,v_j>| = {max_corr_orth:.3e}   lift = {lift_orth:+.3e}")
    print(f"  tilted block     : max |<r,v_j>| = {max_corr_tilt:.3e}   lift = {lift_tilt:+.3e}")
    print(f"  dichotomy holds  : {abs(lift_orth) < 1e-9 and lift_tilt > 1e-6}")
    print()


# ----------------------------------------------------------------------------------
# 3. Conditional dominance and lift asymmetry
# ----------------------------------------------------------------------------------


def demo_conditional_dominance(seed: int = 11) -> None:
    """An orthogonal feature keeps its whole lift after the block has been fitted."""
    print("=" * 78)
    print("3. CONDITIONAL DOMINANCE and LIFT ASYMMETRY")
    print("=" * 78)
    rng = random.Random(seed)
    n = 80
    w_raw = centre([rng.gauss(0.0, 1.0) for _ in range(n)])
    w = [a / math.sqrt(sq_norm(w_raw)) for a in w_raw]

    # a block orthogonal to w
    block: List[Vector] = []
    for _ in range(4):
        v = centre([rng.gauss(0.0, 1.0) for _ in range(n)])
        v = [a - dot(v, w) * b for a, b in zip(v, w)]
        block.append(v)
    block = gram_schmidt(block)

    # response: strongly driven by w, weakly by the block
    noise = [rng.gauss(0.0, 1.0) for _ in range(n)]
    y = centre([2.5 * w[i] + 0.12 * block[0][i] + 0.4 * noise[i] for i in range(n)])
    g = [0.0] * n

    r0 = r_squared(y, g, [])
    r_block = r_squared(y, g, block)
    r_joint = r_squared(y, g, list(block) + [w])
    residual = [a - b for a, b in zip(y, g)]
    individual_lift = dot(residual, w) ** 2 / (sq_norm(w) * tss(y))

    print(f"  R^2 baseline                       : {r0:.6f}")
    print(f"  R^2 block only                     : {r_block:.6f}")
    print(f"  R^2 block + w                      : {r_joint:.6f}")
    print(f"  individual lift of w               : {individual_lift:.6f}")
    print(f"  lift of w GIVEN the block          : {r_joint - r_block:.6f}")
    print(f"  dominance (given >= individual)    : {r_joint - r_block >= individual_lift - 1e-9}")
    print(f"  block given baseline               : {r_block - r0:.6f}")
    print(f"  asymmetry (dial|block > block|base): {r_joint - r_block > r_block - r0}")
    print()


# ----------------------------------------------------------------------------------
# 4. Exact permutation-null calibration
# ----------------------------------------------------------------------------------


def demo_permutation_null(n: int = 7, seed: int = 3) -> None:
    """Mean over ALL n! shuffles of the increment equals exactly (1 - R0^2)/(n-1)."""
    print("=" * 78)
    print("4. PERMUTATION-NULL CALIBRATION:  mean increment = (1 - R0^2)/(n - 1)")
    print("=" * 78)
    rng = random.Random(seed)
    y = centre([rng.gauss(0.0, 1.0) for _ in range(n)])
    g = centre([rng.gauss(0.0, 0.5) for _ in range(n)])
    v = centre([rng.gauss(0.0, 1.0) for _ in range(n)])
    residual = centre([a - b for a, b in zip(y, g)])
    g = [a - b for a, b in zip(y, residual)]   # make the residual exactly centred
    r0 = 1.0 - sq_norm(residual) / tss(y)

    total = 0.0
    count = 0
    for perm in itertools.permutations(range(n)):
        shuffled = [v[perm[i]] for i in range(n)]
        total += dot(residual, shuffled) ** 2 / (sq_norm(v) * tss(y))
        count += 1
    empirical = total / count
    predicted = (1.0 - r0) / (n - 1)

    print(f"  n = {n},  |S_n| = {count},  R0^2 = {r0:.6f}")
    print(f"  exhaustive mean increment : {empirical:.12f}")
    print(f"  closed-form (1-R0^2)/(n-1): {predicted:.12f}")
    print(f"  agreement to 1e-12        : {abs(empirical - predicted) < 1e-12}")

    # Markov tail bound, checked exhaustively
    t = 2.0 * predicted
    exceed = 0
    for perm in itertools.permutations(range(n)):
        shuffled = [v[perm[i]] for i in range(n)]
        if dot(residual, shuffled) ** 2 / (sq_norm(v) * tss(y)) >= t:
            exceed += 1
    frac = exceed / count
    bound = (1.0 - r0) / ((n - 1) * t)
    print(f"  P[increment >= {t:.4f}]      : {frac:.6f}   Markov bound {bound:.6f}"
          f"   ok = {frac <= bound + 1e-12}")
    print()


# ----------------------------------------------------------------------------------
# 5. The nonlinear ceiling
# ----------------------------------------------------------------------------------


def within_ss(y: Sequence[float], f: Sequence[Hashable]) -> float:
    """Within-cell sum of squares of y over the level sets of the feature f."""
    cells: Dict[Hashable, List[float]] = {}
    for value, target in zip(f, y):
        cells.setdefault(value, []).append(target)
    return sum(sum((t - mean(vals)) ** 2 for t in vals) for vals in cells.values())


def demo_nonlinear_ceiling(seed: int = 5) -> None:
    """RSS over ALL functions of a feature equals the within-cell sum of squares."""
    print("=" * 78)
    print("5. NONLINEAR CEILING:  best fit over all functions of f  =  within-cell SS")
    print("=" * 78)
    rng = random.Random(seed)
    n = 300
    f = [rng.randrange(6) for _ in range(n)]
    # a response that is a WILD function of f plus noise: linear fits will miss it
    y = [math.sin(3.1 * cell) * 4.0 + rng.gauss(0.0, 1.0) for cell in f]

    wss = within_ss(y, f)
    # best linear-in-f fit, for contrast
    x = centre([float(cell) for cell in f])
    yc = centre(y)
    linear_rss = sq_norm(yc) - dot(yc, x) ** 2 / sq_norm(x)
    # brute-force search over random step functions can only approach, never beat, WSS
    best_random = float("inf")
    for _ in range(2000):
        phi = {a: rng.gauss(0.0, 4.0) for a in set(f)}
        best_random = min(best_random, sum((y[i] - phi[f[i]]) ** 2 for i in range(n)))

    print(f"  within-cell SS (exact optimum over all functions of f) : {wss:.6f}")
    print(f"  best of 2000 random step functions                     : {best_random:.6f}")
    print(f"  never beats the optimum                                : {best_random >= wss - 1e-9}")
    print(f"  best LINEAR-in-f residual SS                           : {linear_rss:.6f}")
    print(f"  correlation ratio eta^2 = 1 - WSS/TSS                  : {1 - wss / tss(y):.6f}")
    print(f"  linear R^2                                             : {1 - linear_rss / tss(y):.6f}")
    print("  -> a null LINEAR result would badly misreport this feature; the")
    print("     nonlinear ceiling is what a coverage claim actually needs.")
    print()


# ----------------------------------------------------------------------------------
# 6. Arithmetic freedom of the dial and the neighbourhood layer
# ----------------------------------------------------------------------------------


def primes_up_to(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if limit < 2:
        return []
    flags = [True] * (limit + 1)
    flags[0] = flags[1] = False
    for p in range(2, int(limit ** 0.5) + 1):
        if flags[p]:
            for m in range(p * p, limit + 1, p):
                flags[m] = False
    return [p for p in range(2, limit + 1) if flags[p]]


def omega_lower_bound(m: int, cap: int = 200_000) -> Tuple[int, bool]:
    """Count distinct prime factors of |m| by trial division up to `cap`.

    Returns the count found together with a flag saying whether the factorisation
    was completed (in which case the count is the exact value of omega).
    """
    m = abs(m)
    count = 0
    d = 2
    while d <= cap and d * d <= m:
        if m % d == 0:
            count += 1
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m == 1:
        return count, True
    if d * d > m:
        return count + 1, True
    return count + 1, False


def is_quadratic_residue(a: int, p: int) -> bool:
    """Euler's criterion for an odd prime p not dividing a."""
    a %= p
    if a == 0:
        return True
    return pow(a, (p - 1) // 2, p) == 1


def qr_footprint_dial(n_mod: int, bound: int) -> float:
    """W_B(N) = sum of 2/p over odd primes p <= B for which N is a QR mod p."""
    return sum(2.0 / p for p in primes_up_to(bound)
               if p > 2 and is_quadratic_residue(n_mod, p))


def crt_pair(a1: int, m1: int, a2: int, m2: int, a3: int, m3: int) -> Tuple[int, int]:
    """Chinese Remainder Theorem for three pairwise coprime moduli."""
    def combine(x1: int, n1: int, x2: int, n2: int) -> Tuple[int, int]:
        g = math.gcd(n1, n2)
        assert g == 1, "moduli must be coprime"
        inv = pow(n1 % n2, -1, n2)
        k = ((x2 - x1) * inv) % n2
        return x1 + n1 * k, n1 * n2
    x, m = combine(a1, m1, a2, m2)
    return combine(x % m, m, a3, m3)


def demo_arithmetic_freedom(bound: int = 30, level: int = 3) -> None:
    """Explicitly build large N with a prescribed dial value and rich neighbours."""
    print("=" * 78)
    print("6. ARITHMETIC FREEDOM: any dial value coexists with rich neighbourhoods")
    print("=" * 78)
    fb = [p for p in primes_up_to(bound) if p > 2]
    modulus_p = 1
    for p in fb:
        modulus_p *= p

    # a target residue class: pick a witness modulus and copy its dial footprint
    witness = 1_000_003
    target_dial = qr_footprint_dial(witness, bound)

    # neighbour prime supplies, all exceeding the factor base
    big = [p for p in primes_up_to(120) if p > bound]
    s_minus, s_plus = big[:level], big[level:2 * level]
    q_minus = math.prod(s_minus)
    q_plus = math.prod(s_plus)

    n_value, period = crt_pair(witness % modulus_p, modulus_p, 1, q_minus, -1 % q_plus, q_plus)
    print(f"  odd factor base (p <= {bound})   : {fb}")
    print(f"  target dial value               : {target_dial:.8f}")
    print(f"  primes forced into N-1          : {s_minus}")
    print(f"  primes forced into N+1          : {s_plus}")
    for step in range(3):
        n_k = n_value + step * period
        dial = qr_footprint_dial(n_k, bound)
        om_minus, exact_minus = omega_lower_bound(n_k - 1)
        om_plus, exact_plus = omega_lower_bound(n_k + 1)
        forced_minus = all((n_k - 1) % p == 0 for p in s_minus)
        forced_plus = all((n_k + 1) % p == 0 for p in s_plus)
        tag_minus = "exact" if exact_minus else ">="
        tag_plus = "exact" if exact_plus else ">="
        print(f"    N = {n_k}")
        print(f"      dial(N) = {dial:.8f}   matches target: {abs(dial - target_dial) < 1e-12}")
        print(f"      forced primes divide N-1: {forced_minus},  N+1: {forced_plus}")
        print(f"      omega(N-1) {tag_minus} {om_minus} (>= {level}), "
              f"omega(N+1) {tag_plus} {om_plus} (>= {level})")
    print("  -> the dial value is fixed while the neighbour covariates are forced")
    print("     arbitrarily high: the two layers are uncoupled over the integers.")
    print()


# ----------------------------------------------------------------------------------
# 7. The reported design constants
# ----------------------------------------------------------------------------------


def demo_experiment_certificates() -> None:
    """Plug the reported design constants into every certificate."""
    print("=" * 78)
    print("7. CERTIFICATES AT THE REPORTED DESIGN CONSTANTS")
    print("=" * 78)
    k = 4
    lam = 1.0
    rho = 0.16
    r0 = 0.4112
    observed = 0.4307 - 0.4112
    d_reverse = 0.3987
    n_sample = 237

    ceiling = k * rho ** 2 * (1.0 - r0) / lam
    threshold_rho = math.sqrt(0.05 * lam / (k * (1.0 - r0)))
    null_mean = (1.0 - r0) / (n_sample - 1)
    markov_at_005 = (1.0 - r0) / ((n_sample - 1) * 0.05)

    print(f"  baseline dial R0^2                       : {r0:.4f}")
    print(f"  observed joint R^2                       : 0.4307")
    print(f"  observed Delta R^2                       : {observed:.5f}"
          f"   (pre-registered null boundary 0.02)")
    print(f"  block ceiling  k rho^2 (1-R0^2)/lambda   : {ceiling:.6f}")
    print(f"  observed inside ceiling                  : {observed <= ceiling}")
    print(f"  correlation level at which the ceiling")
    print(f"    alone would exclude Delta R^2 >= 0.05  : rho = {threshold_rho:.4f}")
    print(f"  observed best single |r| = 0.16 > {threshold_rho:.4f}: ceiling alone does NOT")
    print(f"    exclude H1 -- the verdict rests on the joint fit and permutation test.")
    print(f"  lift asymmetry hypothesis ceiling < d    : {ceiling:.6f} < {d_reverse}"
          f"  -> {ceiling < d_reverse}")
    print(f"  exact permutation-null mean increment    : {null_mean:.6f}")
    print(f"  Markov bound on P[increment >= 0.05]     : {markov_at_005:.6f}"
          f"   (empirical q95 = 0.046)")
    print(f"  nonlinear floor: within-cell energy >= 40% of TSS  =>  no function of")
    print(f"    (dial, neighbourhood) exceeds R^2 = 0.60.")
    print()


def main() -> None:
    demo_block_ceiling()
    demo_dichotomy()
    demo_conditional_dominance()
    demo_permutation_null()
    demo_nonlinear_ceiling()
    demo_arithmetic_freedom()
    demo_experiment_certificates()


if __name__ == "__main__":
    main()
