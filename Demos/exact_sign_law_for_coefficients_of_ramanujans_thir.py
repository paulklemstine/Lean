"""
Numerical demonstration of the exact sign law for the coefficients r(n) of
Ramanujan's third order mock theta function

    rho(q) = sum_{m>=0} q^{2m(m+1)} / prod_{k=0}^{m} (1 + q^{2k+1} + q^{4k+2})
           = sum_{n>=0} r(n) q^n.

The computation uses the closed-form reciprocal of each denominator factor,
justified by the difference-of-cubes identity

    (1 - q^{2k+1})(1 + q^{2k+1} + q^{4k+2}) = 1 - q^{6k+3},

so that

    1 / (1 + q^{2k+1} + q^{4k+2}) = (1 - q^{2k+1}) * sum_{j>=0} q^{(6k+3)j}.

This avoids general power-series inversion: every reciprocal is the product of a
two-term polynomial and a lacunary geometric series.

All series are truncated integer coefficient lists (index = degree). Because the
m-th term contributes to q^n only when 2m(m+1) <= n, truncating at degree N
computes r(0), ..., r(N) EXACTLY (not approximately).

This script is self-contained: it depends only on the Python standard library.
"""

from __future__ import annotations

from typing import List


def ps_mul(a: List[int], b: List[int], n_max: int) -> List[int]:
    """Multiply two truncated power series (coefficient lists) up to degree n_max."""
    out: List[int] = [0] * (n_max + 1)
    for i, ai in enumerate(a):
        if ai == 0 or i > n_max:
            continue
        for j in range(0, n_max - i + 1):
            bj = b[j] if j < len(b) else 0
            if bj:
                out[i + j] += ai * bj
    return out


def one_minus(s: int, n_max: int) -> List[int]:
    """Coefficient list of the polynomial 1 - q^s, truncated at degree n_max."""
    v: List[int] = [0] * (n_max + 1)
    v[0] = 1
    if 0 < s <= n_max:
        v[s] -= 1
    return v


def geom(s: int, n_max: int) -> List[int]:
    """Coefficient list of the geometric series sum_{j>=0} q^{s j} (needs s >= 1)."""
    assert s >= 1
    return [1 if (n % s == 0) else 0 for n in range(n_max + 1)]


def factor_inv(k: int, n_max: int) -> List[int]:
    """Reciprocal of the k-th denominator factor 1 + q^{2k+1} + q^{4k+2}."""
    return ps_mul(one_minus(2 * k + 1, n_max), geom(6 * k + 3, n_max), n_max)


def inv_prod(m: int, n_max: int) -> List[int]:
    """Reciprocal of the partial denominator prod_{k=0}^{m} (1 + q^{2k+1} + q^{4k+2})."""
    result: List[int] = [0] * (n_max + 1)
    result[0] = 1
    for k in range(m + 1):
        result = ps_mul(result, factor_inv(k, n_max), n_max)
    return result


def rho_coeffs(n_max: int) -> List[int]:
    """Exact coefficients r(0), ..., r(n_max) of Ramanujan's rho(q)."""
    r: List[int] = [0] * (n_max + 1)
    m = 0
    while 2 * m * (m + 1) <= n_max:
        shift = 2 * m * (m + 1)
        ip = inv_prod(m, n_max)
        for n in range(0, n_max + 1 - shift):
            r[shift + n] += ip[n]
        m += 1
    return r


def check_sign_law(r: List[int]) -> None:
    """Verify the sign law and print any violations."""
    violations = []
    for n, val in enumerate(r):
        if n % 3 == 0 and not val > 0:
            violations.append((n, "expected r(3n) > 0", val))
        if n % 3 == 1 and not val <= 0:
            violations.append((n, "expected r(3n+1) <= 0", val))
        if n % 3 == 2 and not val <= 0:
            violations.append((n, "expected r(3n+2) <= 0", val))
    if violations:
        print("  SIGN LAW VIOLATIONS:", violations)
    else:
        print("  Sign law holds for all checked n: r(3n) > 0, r(3n+1) <= 0, r(3n+2) <= 0.")


def main() -> None:
    n_max = 150
    r = rho_coeffs(n_max)

    print("Coefficients r(0..59) of Ramanujan's rho(q):")
    print("  " + ", ".join(str(x) for x in r[:60]))
    print()

    # Cross-check the well-known initial segment.
    expected_head = [1, -1, 0, 1, 0, -1, 1, -1, 0, 1, -1, 0, 2]
    assert r[: len(expected_head)] == expected_head, "initial segment mismatch"
    print("Initial segment matches the reference values 1,-1,0,1,0,-1,1,-1,0,1,-1,0,2.")
    print()

    print(f"Sign law check up to n = {n_max}:")
    check_sign_law(r)
    print()

    zeros = [n for n, val in enumerate(r) if val == 0]
    print(f"Zero set of r(n) for n <= {n_max}: {zeros}")
    assert zeros == [2, 4, 8, 11, 20], "unexpected zero set"
    print("  Matches the conjectured sporadic zero set {2, 4, 8, 11, 20}.")
    print("  All zeros lie in the non-positive classes (n mod 3 != 0).")
    print()

    pos_class = [r[n] for n in range(0, n_max + 1, 3)]
    print("Positive class (r(3n)) first 20 values:")
    print("  " + ", ".join(str(x) for x in pos_class[:20]))
    print(f"  Strictly positive throughout: {all(x > 0 for x in pos_class)}")
    print("  Not monotone, e.g. r(12) = {}, r(15) = {}.".format(r[12], r[15]))
    print()

    # Illustrate the telescoping factorization numerically:
    #   prod (1 - q^{2k+1}) * prod (1 + q^{2k+1} + q^{4k+2}) == prod (1 - q^{6k+3}).
    m = 6
    left1: List[int] = [0] * (n_max + 1)
    left1[0] = 1
    left2: List[int] = [0] * (n_max + 1)
    left2[0] = 1
    right: List[int] = [0] * (n_max + 1)
    right[0] = 1
    for k in range(m + 1):
        trin = [0] * (n_max + 1)
        trin[0] = 1
        if 2 * k + 1 <= n_max:
            trin[2 * k + 1] += 1
        if 4 * k + 2 <= n_max:
            trin[4 * k + 2] += 1
        left1 = ps_mul(left1, one_minus(2 * k + 1, n_max), n_max)
        left2 = ps_mul(left2, trin, n_max)
        right = ps_mul(right, one_minus(6 * k + 3, n_max), n_max)
    lhs = ps_mul(left1, left2, n_max)
    print("Telescoping factorization check (m = 6):")
    print(f"  prod(1-q^(2k+1)) * prod(1+q^(2k+1)+q^(4k+2)) == prod(1-q^(6k+3)) : {lhs == right}")


if __name__ == "__main__":
    main()
