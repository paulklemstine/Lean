from typing import List

PREC: int = 301  # truncation: work modulo q^PREC


def mono(k: int) -> List[int]:
    """The monomial q^k as a truncated coefficient vector."""
    v = [0] * PREC
    if k < PREC:
        v[k] = 1
    return v


def padd(a: List[int], b: List[int]) -> List[int]:
    """Entrywise (truncated) addition of two power series."""
    return [a[i] + b[i] for i in range(PREC)]


def pmul(a: List[int], b: List[int]) -> List[int]:
    """Truncated Cauchy product (a*b)_i = sum_{j} a_j b_{i-j}."""
    c = [0] * PREC
    for i in range(PREC):
        s = 0
        for j in range(i + 1):
            s += a[j] * b[i - j]
        c[i] = s
    return c


def pinv(a: List[int]) -> List[int]:
    """Inverse of a series with constant term 1 via
    b_0 = 1, b_i = -sum_{k=1}^{i} a_k b_{i-k}."""
    assert a[0] == 1
    b = [0] * PREC
    b[0] = 1
    for i in range(1, PREC):
        s = 0
        for k in range(1, i + 1):
            s += a[k] * b[i - k]
        b[i] = -s
    return b


def factor(m: int) -> List[int]:
    """P_m = prod_{j=0}^{m} (1 + q^{2j+1} + q^{4j+2})."""
    acc = mono(0)
    for j in range(m + 1):
        block = padd(padd(mono(0), mono(2 * j + 1)), mono(4 * j + 2))
        acc = pmul(acc, block)
    return acc


def rho_coeffs(num_terms: int = 13) -> List[int]:
    """Exact coefficients (r(0),...,r(PREC-1)) of Ramanujan's rho(q).
    13 terms suffice because 2*13*14 = 364 > PREC."""
    acc = [0] * PREC
    for m in range(num_terms):
        acc = padd(acc, pmul(mono(2 * m * (m + 1)), pinv(factor(m))))
    return acc
