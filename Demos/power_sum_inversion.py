"""
Power-sum inversion: numerical demonstrations.

Everything here is exact rational arithmetic (fractions.Fraction), so the
printed identities are genuine equalities, not floating-point near-misses.

Contents
--------
1.  Construction of the inversion matrix W_N (coefficients of the Lagrange
    basis of the nodes 0, 1, ..., N).
2.  Verification of the inversion formula  c_f(v) = sum_k W_N(v,k) p_k(f)
    on random bounded functions.
3.  Lebesgue constants Lambda_N(v) = sum_k |W_N(v,k)| and the exact-recovery
    noise threshold 1 / Lambda_N(v).
4.  A noisy-recovery experiment showing that rounding succeeds below the
    threshold.
5.  Sharpness: the near-miss pair produced from the nodal weight vector of an
    arbitrary node set A, with equal power sums for all k < #A - 1.
6.  Sparse rigidity: two power sums suffice for values in {0, 10**6}.
7.  Spectral reading: power traces of diagonal matrices with small integral
    spectra.

Run:  python3 demo.py
"""

from __future__ import annotations

import random
from fractions import Fraction
from math import gcd
from typing import Dict, List, Sequence, Tuple

Poly = List[Fraction]  # poly[k] is the coefficient of X^k


# --------------------------------------------------------------------------
# 1. Lagrange basis coefficients = the inversion matrix
# --------------------------------------------------------------------------


def poly_mul(p: Poly, q: Poly) -> Poly:
    """Multiply two polynomials given as coefficient lists."""
    out: Poly = [Fraction(0)] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        if a:
            for j, b in enumerate(q):
                out[i + j] += a * b
    return out


def lagrange_basis_coeffs(nodes: Sequence[int], v: int) -> Poly:
    """Coefficients of L_v(X) = prod_{b != v} (X - b) / (v - b) over `nodes`."""
    if v not in nodes:
        raise ValueError(f"{v} is not one of the nodes")
    num: Poly = [Fraction(1)]
    denom = Fraction(1)
    for b in nodes:
        if b == v:
            continue
        num = poly_mul(num, [Fraction(-b), Fraction(1)])
        denom *= Fraction(v - b)
    return [c / denom for c in num]


def inversion_matrix(nodes: Sequence[int]) -> Dict[int, Poly]:
    """Row v of the inversion matrix = coefficient vector of L_v."""
    return {v: lagrange_basis_coeffs(nodes, v) for v in nodes}


def lebesgue_constant(nodes: Sequence[int], v: int) -> Fraction:
    """L1 norm of the v-th inversion row: the conditioning constant at v."""
    return sum((abs(c) for c in lagrange_basis_coeffs(nodes, v)), Fraction(0))


# --------------------------------------------------------------------------
# 2. Power sums, histograms, inversion
# --------------------------------------------------------------------------


def power_sums(values: Sequence[int], window: int) -> List[int]:
    """p_0, ..., p_{window-1} of a multiset of natural numbers (0**0 = 1)."""
    return [sum(x**k for x in values) for k in range(window)]


def histogram(values: Sequence[int], nodes: Sequence[int]) -> Dict[int, int]:
    return {v: sum(1 for x in values if x == v) for v in nodes}


def invert_power_sums(
    nodes: Sequence[int], moments: Sequence[Fraction]
) -> Dict[int, Fraction]:
    """Recover the histogram from the power sums by one matrix product."""
    W = inversion_matrix(nodes)
    return {
        v: sum((W[v][k] * Fraction(moments[k]) for k in range(len(nodes))), Fraction(0))
        for v in nodes
    }


# --------------------------------------------------------------------------
# 5. Nodal weights and the near-miss construction
# --------------------------------------------------------------------------


def nodal_weights(nodes: Sequence[int]) -> Dict[int, Fraction]:
    """w_a = prod_{b != a} 1 / (a - b): the top row of the inverse."""
    weights: Dict[int, Fraction] = {}
    for a in nodes:
        w = Fraction(1)
        for b in nodes:
            if b != a:
                w /= Fraction(a - b)
        weights[a] = w
    return weights


def integer_weights(nodes: Sequence[int]) -> Dict[int, int]:
    """Clear denominators in the nodal weights and reduce by the gcd."""
    w = nodal_weights(nodes)
    denom = 1
    for a in nodes:
        denom = denom * w[a].denominator // gcd(denom, w[a].denominator)
    z = {a: int(w[a] * denom) for a in nodes}
    g = 0
    for a in nodes:
        g = gcd(g, abs(z[a]))
    if g > 1:
        z = {a: z[a] // g for a in nodes}
    return z


def near_miss_pair(nodes: Sequence[int]) -> Tuple[List[int], List[int]]:
    """Two multisets with values in `nodes`, equal p_k for all k < #nodes - 1,
    and different histograms."""
    z = integer_weights(nodes)
    plus: List[int] = []
    minus: List[int] = []
    for a in nodes:
        if z[a] > 0:
            plus += [a] * z[a]
        elif z[a] < 0:
            minus += [a] * (-z[a])
    return sorted(plus), sorted(minus)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def _show_multiset(values: Sequence[int]) -> str:
    """Compact display: explicit list if short, multiplicity form if long."""
    if len(values) <= 12:
        return str(list(values))
    counts: Dict[int, int] = {}
    for x in values:
        counts[x] = counts.get(x, 0) + 1
    body = ", ".join(f"{v}^({c})" for v, c in sorted(counts.items()))
    return "{" + body + "}"


def demo_inversion_matrix(N: int = 4) -> None:
    print("=" * 74)
    print(f"1. Inversion matrix for the nodes 0..{N}  (rows = W_N(v, .))")
    print("=" * 74)
    nodes = list(range(N + 1))
    W = inversion_matrix(nodes)
    for v in nodes:
        row = ", ".join(str(c) for c in W[v])
        print(f"  v = {v}:  ({row})    Lambda = {lebesgue_constant(nodes, v)}")
    print()


def demo_exact_recovery(N: int = 5, trials: int = 5, seed: int = 20260820) -> None:
    print("=" * 74)
    print(f"2. Exact recovery of random histograms, values bounded by {N}")
    print("=" * 74)
    rng = random.Random(seed)
    nodes = list(range(N + 1))
    for t in range(trials):
        size = rng.randint(1, 12)
        values = [rng.randint(0, N) for _ in range(size)]
        p = power_sums(values, N + 1)
        recovered = invert_power_sums(nodes, [Fraction(x) for x in p])
        truth = histogram(values, nodes)
        ok = all(recovered[v] == truth[v] for v in nodes)
        print(f"  trial {t}: values={sorted(values)}")
        print(f"           power sums p_0..p_{N} = {p}")
        print(f"           recovered histogram   = "
              f"{[int(recovered[v]) for v in nodes]}   exact: {ok}")
        assert ok
    print()


def demo_lebesgue(Nmax: int = 8) -> None:
    print("=" * 74)
    print("3. Lebesgue constants and exact-recovery noise thresholds")
    print("=" * 74)
    print("   (recovery at v is guaranteed as soon as the power-sum error")
    print("    eps satisfies Lambda_N(v) * eps < 1)")
    for N in range(1, Nmax + 1):
        nodes = list(range(N + 1))
        lams = [lebesgue_constant(nodes, v) for v in nodes]
        worst = max(lams)
        print(f"  N = {N}:  Lambda(0) = {str(lams[0]):>6}   max_v Lambda = {worst}"
              f"   threshold 1/max = {Fraction(1) / worst}")
        assert lams[0] == N + 1, "conjectured identity Lambda_N(0) = N+1"
    print("  (the identity Lambda_N(0) = N + 1 holds in every case checked)")
    print()


def demo_noise(N: int = 4, seed: int = 7) -> None:
    print("=" * 74)
    print("4. Noisy power sums: rounding recovers the histogram below threshold")
    print("=" * 74)
    rng = random.Random(seed)
    nodes = list(range(N + 1))
    values = [rng.randint(0, N) for _ in range(15)]
    truth = histogram(values, nodes)
    exact = power_sums(values, N + 1)
    lam_max = max(lebesgue_constant(nodes, v) for v in nodes)
    threshold = Fraction(1) / lam_max
    print(f"  values      : {sorted(values)}")
    print(f"  true p_0..p_{N}: {exact}")
    print(f"  max Lebesgue constant = {lam_max}, threshold eps < {threshold}"
          f" ~= {float(threshold):.6f}")
    for eps in [threshold / 2, threshold * 4]:
        perturbed = [
            Fraction(x) + (eps if k % 2 == 0 else -eps) for k, x in enumerate(exact)
        ]
        rec = invert_power_sums(nodes, perturbed)
        rounded = {v: round(rec[v]) for v in nodes}
        ok = all(rounded[v] == truth[v] for v in nodes)
        tag = "below threshold" if eps < threshold else "above threshold"
        print(f"  eps = {float(eps):.6f} ({tag}): rounded = "
              f"{[rounded[v] for v in nodes]}  correct: {ok}")
    print()


def demo_sharpness(node_sets: Sequence[Sequence[int]] = ((0, 1, 2), (0, 1, 5),
                                                         (0, 1, 2, 3),
                                                         (0, 2, 7, 11))) -> None:
    print("=" * 74)
    print("5. Sharpness: near-miss pairs from the nodal weight vector")
    print("=" * 74)
    for A in node_sets:
        m = len(A)
        w = nodal_weights(A)
        z = integer_weights(A)
        plus, minus = near_miss_pair(A)
        p_plus = power_sums(plus, m + 1)
        p_minus = power_sums(minus, m + 1)
        agree = all(p_plus[k] == p_minus[k] for k in range(m - 1))
        differ = histogram(plus, A) != histogram(minus, A)
        print(f"  A = {list(A)}  (#A = {m})")
        print(f"    nodal weights w  = {[str(w[a]) for a in A]}")
        print(f"    integer weights z= {[z[a] for a in A]}")
        print(f"    multiset S+ = {_show_multiset(plus)}")
        print(f"    multiset S- = {_show_multiset(minus)}")
        print(f"    p_0..p_{m} of S+ = {p_plus}")
        print(f"    p_0..p_{m} of S- = {p_minus}")
        print(f"    agree for all k < {m - 1}: {agree};  histograms differ: {differ}")
        assert agree and differ
        # ... and the full window k < m does separate them:
        assert p_plus[m - 1] != p_minus[m - 1]
        print(f"    first disagreement at k = {m - 1}: "
              f"{p_plus[m - 1]} vs {p_minus[m - 1]}")
    print()


def demo_sparse(big: int = 10**6) -> None:
    print("=" * 74)
    print("6. Sparse rigidity: the window is #A, not the size of the values")
    print("=" * 74)
    A = [0, big]
    f = [0, 0, big, 0, big]
    p = power_sums(f, 2)
    rec = invert_power_sums(A, [Fraction(x) for x in p])
    print(f"  A = {A}, values = {f}")
    print(f"  only two power sums observed: p_0 = {p[0]}, p_1 = {p[1]}")
    print(f"  recovered histogram: {{0: {int(rec[0])}, {big}: {int(rec[big])}}}")
    assert int(rec[0]) == 3 and int(rec[big]) == 2
    A3 = [0, 1, big]
    z = integer_weights(A3)
    print(f"  on A = {A3} the near-miss integer weights are {[z[a] for a in A3]},")
    print(f"  i.e. the pair S+ = {{0 with multiplicity {z[0]}, {big} with"
          f" multiplicity {z[big]}}}")
    print(f"       and S- = {{1 with multiplicity {-z[1]}}}: equal p_0 and p_1,"
          " different histograms")
    assert z[0] + z[big] == -z[1]
    assert z[big] * big == -z[1] - 0 * z[0]
    print()


def demo_spectral(N: int = 3) -> None:
    print("=" * 74)
    print("7. Spectral reading: power traces determine small integral spectra")
    print("=" * 74)
    nodes = list(range(N + 1))
    spec_a = [0, 1, 1, 3, 2]
    spec_b = [1, 3, 0, 2, 1]  # same multiset, different order
    tr_a = power_sums(spec_a, N + 1)
    tr_b = power_sums(spec_b, N + 1)
    print(f"  spectrum A = {spec_a}, power traces = {tr_a}")
    print(f"  spectrum B = {spec_b}, power traces = {tr_b}")
    print(f"  traces agree for k <= {N}: {tr_a == tr_b}")
    rec = invert_power_sums(nodes, [Fraction(x) for x in tr_a])
    print(f"  eigenvalue multiplicities recovered from the traces: "
          f"{[int(rec[v]) for v in nodes]}")
    assert [int(rec[v]) for v in nodes] == [
        sum(1 for x in spec_a if x == v) for v in nodes
    ]
    print()


def main() -> None:
    demo_inversion_matrix()
    demo_exact_recovery()
    demo_lebesgue()
    demo_noise()
    demo_sharpness()
    demo_sparse()
    demo_spectral()
    print("All demonstrations completed; every assertion checked exactly.")


if __name__ == "__main__":
    main()
