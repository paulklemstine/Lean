"""
Numerical demonstration of the mod-3 sign law for the coefficients of
Ramanujan's third-order mock theta function

    rho(q) = sum_{m>=0} q^{2m(m+1)} / prod_{j=0}^{m} (1 + q^{2j+1} + q^{4j+2})
           = sum_{n>=0} r(n) q^n.

We recompute the integer sequence r(n) from the defining product using exact
truncated power-series arithmetic over the integers, then verify:

  * the sign law      r(3n) > 0,  r(3n+1) <= 0,  r(3n+2) <= 0;
  * the exact zero set { n : r(n) = 0 } = {2, 4, 8, 11, 20};
  * the cyclotomic identity (1 + x^k + x^{2k})(1 - x^k) = 1 - x^{3k}.

Pure standard library; no third-party dependencies.
"""

from typing import List

PREC: int = 301  # we work modulo q^PREC


def pzero() -> List[int]:
    """The zero series, as a length-PREC coefficient vector."""
    return [0] * PREC


def mono(k: int) -> List[int]:
    """The monomial q^k (truncated to the window)."""
    v = [0] * PREC
    if k < PREC:
        v[k] = 1
    return v


def padd(a: List[int], b: List[int]) -> List[int]:
    """Truncated addition of power series."""
    return [a[i] + b[i] for i in range(PREC)]


def pmul(a: List[int], b: List[int]) -> List[int]:
    """Truncated Cauchy product of power series."""
    c = [0] * PREC
    for i in range(PREC):
        s = 0
        for j in range(i + 1):
            s += a[j] * b[i - j]
        c[i] = s
    return c


def pinv(a: List[int]) -> List[int]:
    """Truncated inverse of a series with constant term 1.

    Uses the recurrence b_0 = 1, b_i = -sum_{k=1}^{i} a_k b_{i-k}.
    """
    assert a[0] == 1, "series must have constant term 1 to invert"
    b = [0] * PREC
    b[0] = 1
    for i in range(1, PREC):
        s = 0
        for k in range(1, i + 1):
            s += a[k] * b[i - k]
        b[i] = -s
    return b


def factor(m: int) -> List[int]:
    """The truncated finite product P_m = prod_{j=0}^{m} (1 + q^{2j+1} + q^{4j+2})."""
    acc = mono(0)
    for j in range(m + 1):
        block = padd(padd(mono(0), mono(2 * j + 1)), mono(4 * j + 2))
        acc = pmul(acc, block)
    return acc


def rho_coeffs(num_terms: int = 13) -> List[int]:
    """The coefficient vector (r(0), ..., r(PREC-1)) of rho(q).

    Only num_terms summands are needed: term m has order 2m(m+1), and
    2*13*14 = 364 > PREC = 301, so terms m >= 13 contribute nothing below
    the truncation window -- the result is therefore exact for n < PREC.
    """
    acc = pzero()
    for m in range(num_terms):
        term = pmul(mono(2 * m * (m + 1)), pinv(factor(m)))
        acc = padd(acc, term)
    return acc


def check_cyclotomic_identity(kmax: int = 6) -> None:
    """Verify (1 + x^k + x^{2k})(1 - x^k) = 1 - x^{3k} as truncated series."""
    print("Cyclotomic identity (1 + x^k + x^{2k})(1 - x^k) = 1 - x^{3k}:")
    for k in range(kmax + 1):
        if 3 * k >= PREC:
            break
        lhs = pmul(padd(padd(mono(0), mono(k)), mono(2 * k)),
                   padd(mono(0), [-c for c in mono(k)]))
        rhs = padd(mono(0), [-c for c in mono(3 * k)])
        ok = lhs == rhs
        print(f"  k = {k}: identity holds = {ok}")
    print()


def main() -> None:
    r = rho_coeffs()

    print("First 40 coefficients r(n):")
    print("  ", r[:40])
    print()

    # --- sign law ---
    pos_ok = all(r[3 * n] > 0 for n in range(100))
    lane1_ok = all(r[3 * n + 1] <= 0 for n in range(100))
    lane2_ok = all(r[3 * n + 2] <= 0 for n in range(100))
    print("Mod-3 sign law on n < 100 (indices < 300):")
    print(f"  r(3n)   > 0  for all n : {pos_ok}")
    print(f"  r(3n+1) <= 0 for all n : {lane1_ok}")
    print(f"  r(3n+2) <= 0 for all n : {lane2_ok}")
    print()

    # --- zero set ---
    zeros = [n for n in range(300) if r[n] == 0]
    print(f"Zero set on n < 300: {zeros}")
    print(f"  equals {{2,4,8,11,20}} : {zeros == [2, 4, 8, 11, 20]}")
    print()

    # zeros by residue lane
    print("Zeros by residue lane:")
    print(f"  lane 1 (n = 3k+1): {[n for n in zeros if n % 3 == 1]}")
    print(f"  lane 2 (n = 3k+2): {[n for n in zeros if n % 3 == 2]}")
    print()

    # --- lane previews ---
    print("Lane 0 (r(3n)), first 15:", [r[3 * n] for n in range(15)])
    print("Lane 1 (r(3n+1)), first 15:", [r[3 * n + 1] for n in range(15)])
    print("Lane 2 (r(3n+2)), first 15:", [r[3 * n + 2] for n in range(15)])
    print()

    check_cyclotomic_identity()


if __name__ == "__main__":
    main()
