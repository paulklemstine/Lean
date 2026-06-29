"""
Numerical demonstrations for:

    Designed Distance of Goppa and Alternant Codes
    A Formal Foundation for Code-Based (Post-Quantum) Cryptography

This file is fully self-contained (standard library only) and illustrates the
theorems formalized in the companion Lean development:

  * card_eval_zero_le_natDegree  -- a nonzero polynomial has at most deg(f)
                                    zero coordinates among distinct points.
  * grs_min_distance             -- GRS / Reed-Solomon designed distance:
                                    weight(evalVec f) >= n - k + 1.
  * grs_dist_lower               -- distinct degree-<k codewords differ in
                                    >= n - k + 1 coordinates.
  * grs_corrects_errors          -- if 2*tau + 1 <= n - k + 1 then any received
                                    word is within tau of <= one codeword.
  * bch_parity_min_weight        -- nonzero kernel vectors of a t x n Vandermonde
                                    parity check have weight > t.

Plus McEliece parameter / information-set-decoding cost analysis for 256-bit
post-quantum security.

All arithmetic for the GRS/BCH demonstrations is performed in a prime field
GF(p), implemented inline with Python integers.
"""

from __future__ import annotations

from itertools import product
from math import comb, log2, prod
from typing import List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Minimal prime-field polynomial arithmetic over GF(p)
# ---------------------------------------------------------------------------

def poly_eval(coeffs: Sequence[int], x: int, p: int) -> int:
    """Evaluate a polynomial (coeffs[i] is the X^i coefficient) at x in GF(p)."""
    acc = 0
    for c in reversed(coeffs):
        acc = (acc * x + c) % p
    return acc


def poly_degree(coeffs: Sequence[int], p: int) -> int:
    """Natural-number degree of a polynomial over GF(p); degree of 0 is 0."""
    d = 0
    for i, c in enumerate(coeffs):
        if c % p != 0:
            d = i
    return d


def is_zero_poly(coeffs: Sequence[int], p: int) -> bool:
    return all(c % p == 0 for c in coeffs)


def eval_vec(alpha: Sequence[int], coeffs: Sequence[int], p: int) -> List[int]:
    """The evaluation codeword (evalVec) of a polynomial at the locators alpha."""
    return [poly_eval(coeffs, a, p) % p for a in alpha]


def hamming_weight(v: Sequence[int], p: int) -> int:
    return sum(1 for x in v if x % p != 0)


def hamming_dist(u: Sequence[int], v: Sequence[int], p: int) -> int:
    return sum(1 for a, b in zip(u, v) if (a - b) % p != 0)


# ---------------------------------------------------------------------------
# Demo 1: zero-counting lemma (card_eval_zero_le_natDegree)
# ---------------------------------------------------------------------------

def demo_zero_counting() -> None:
    print("=" * 72)
    print("Demo 1: card_eval_zero_le_natDegree")
    print("A nonzero polynomial has at most deg(f) zero coordinates.")
    print("=" * 72)
    p = 13
    alpha = list(range(p))               # 13 distinct locators 0..12
    # f(X) = (X-1)(X-2)(X-3) ; degree 3, exactly 3 roots among the locators.
    def linear(r: int) -> List[int]:
        return [(-r) % p, 1]
    def mul(a: List[int], b: List[int]) -> List[int]:
        out = [0] * (len(a) + len(b) - 1)
        for i, x in enumerate(a):
            for j, y in enumerate(b):
                out[i + j] = (out[i + j] + x * y) % p
        return out
    f = mul(mul(linear(1), linear(2)), linear(3))
    vec = eval_vec(alpha, f, p)
    zeros = sum(1 for x in vec if x == 0)
    deg = poly_degree(f, p)
    print(f"  locators       : {alpha}")
    print(f"  f coefficients : {f}   (degree {deg})")
    print(f"  evalVec        : {vec}")
    print(f"  zero count     : {zeros}   <=   deg f = {deg}   -> {zeros <= deg}")
    print()


# ---------------------------------------------------------------------------
# Demo 2: GRS designed distance (grs_min_distance) over all degree-<k polys
# ---------------------------------------------------------------------------

def demo_grs_min_distance() -> None:
    print("=" * 72)
    print("Demo 2: grs_min_distance  (MDS / Singleton-optimal distance)")
    print("Every nonzero degree-<k codeword has weight >= n - k + 1.")
    print("=" * 72)
    p = 7
    n = 7
    k = 3
    alpha = list(range(n))               # distinct locators
    bound = n - k + 1
    min_weight = None
    for coeffs in product(range(p), repeat=k):     # all polys of degree < k
        if is_zero_poly(coeffs, p):
            continue
        w = hamming_weight(eval_vec(alpha, coeffs, p), p)
        min_weight = w if min_weight is None else min(min_weight, w)
    print(f"  n={n}, k={k}, GF({p})")
    print(f"  designed distance bound n-k+1 = {bound}")
    print(f"  observed minimum weight       = {min_weight}")
    print(f"  bound holds (and is tight)    : {min_weight == bound}")
    print()


# ---------------------------------------------------------------------------
# Demo 3: unique decoding (grs_corrects_errors)
# ---------------------------------------------------------------------------

def demo_unique_decoding() -> None:
    print("=" * 72)
    print("Demo 3: grs_corrects_errors")
    print("If 2*tau+1 <= n-k+1, a received word lies within tau of <= 1 codeword.")
    print("=" * 72)
    p = 11
    n = 11
    k = 3
    alpha = list(range(n))
    tau = (n - k) // 2
    assert 2 * tau + 1 <= n - k + 1
    # genuine codeword from f(X) = 2 + 3X + X^2
    f = [2, 3, 1]
    code = eval_vec(alpha, f, p)
    # inject exactly tau errors
    received = code[:]
    for i in range(tau):
        received[i] = (received[i] + 1) % p
    print(f"  n={n}, k={k}, GF({p}), tau={tau}")
    print(f"  codeword  : {code}")
    print(f"  received  : {received}   (dist {hamming_dist(code, received, p)})")
    # brute-force search: how many codewords lie within tau?
    near = []
    for coeffs in product(range(p), repeat=k):
        cw = eval_vec(alpha, coeffs, p)
        if hamming_dist(received, cw, p) <= tau:
            near.append(cw)
    print(f"  codewords within tau of received : {len(near)}  (theorem: <= 1)")
    print(f"  unique decoder recovers original : {near == [code]}")
    print()


# ---------------------------------------------------------------------------
# Demo 4: BCH / alternant bound (bch_parity_min_weight) via Vandermonde kernel
# ---------------------------------------------------------------------------

def vandermonde(alpha: Sequence[int], t: int, p: int) -> List[List[int]]:
    """t x n Vandermonde parity-check matrix H[j][i] = alpha_i^j over GF(p)."""
    return [[pow(a, j, p) for a in alpha] for j in range(t)]


def matvec(H: Sequence[Sequence[int]], c: Sequence[int], p: int) -> List[int]:
    return [sum(H[j][i] * c[i] for i in range(len(c))) % p for j in range(len(H))]


def demo_bch_bound() -> None:
    print("=" * 72)
    print("Demo 4: bch_parity_min_weight")
    print("Nonzero kernel vectors of a t x n Vandermonde check have weight > t.")
    print("=" * 72)
    p = 7
    n = 6
    t = 2
    alpha = list(range(1, n + 1))        # distinct nonzero locators
    H = vandermonde(alpha, t, p)
    min_w = None
    for c in product(range(p), repeat=n):
        if all(x == 0 for x in c):
            continue
        if all(s == 0 for s in matvec(H, c, p)):     # c in ker H
            w = hamming_weight(c, p)
            min_w = w if min_w is None else min(min_w, w)
    print(f"  n={n}, t={t}, GF({p})")
    print(f"  minimum weight of nonzero kernel vector = {min_w}")
    print(f"  bound: weight > t = {t}  ->  {min_w > t}")
    print()


# ---------------------------------------------------------------------------
# Demo 5: McEliece parameters and information-set-decoding cost
# ---------------------------------------------------------------------------

def isd_log2_work(n: int, k: int, t: int) -> float:
    """log2 of Prange ISD expected iteration count C(n,t)/C(n-k,t)."""
    return log2(comb(n, t)) - log2(comb(n - k, t))


def mceliece_public_key_bytes(n: int, k: int) -> int:
    """Systematic public-key size: k*(n-k) bits, rounded up to bytes."""
    bits = k * (n - k)
    return (bits + 7) // 8


def demo_parameters() -> None:
    print("=" * 72)
    print("Demo 5: McEliece parameters for 256-bit post-quantum security")
    print("=" * 72)
    # Classic McEliece Category 5 parameter set.
    n, k, t, m = 6960, 5413, 119, 13
    work = isd_log2_work(n, k, t)
    pk = mceliece_public_key_bytes(n, k)
    tau = (n - k) // 2
    print(f"  field GF(2^{m}),  n={n},  k={k},  t={t}")
    print(f"  Goppa rate check k >= n - m*t : {k} >= {n - m * t}  ->  {k >= n - m * t}")
    print(f"  certified correction radius tau = floor((n-k)/2) = {tau}  (>= t={t}: {tau >= t})")
    print(f"  Prange ISD work factor   : ~2^{work:.1f} operations")
    print(f"  meets 256-bit target     : {work >= 256}")
    print(f"  public-key size          : {pk:,} bytes (~{pk / 1e6:.2f} MB)")
    print()
    print("  Comparison across NIST categories:")
    table: List[Tuple[str, int, int, int]] = [
        ("Cat 1  (128-bit)", 3488, 2720, 64),
        ("Cat 3  (192-bit)", 4608, 3360, 96),
        ("Cat 5  (256-bit)", 6960, 5413, 119),
        ("Cat 5+ (256-bit)", 8192, 6528, 128),
    ]
    print(f"    {'set':<18}{'n':>6}{'k':>6}{'t':>5}{'log2(ISD)':>11}{'PKbytes':>11}")
    for name, nn, kk, tt in table:
        print(f"    {name:<18}{nn:>6}{kk:>6}{tt:>5}"
              f"{isd_log2_work(nn, kk, tt):>11.1f}"
              f"{mceliece_public_key_bytes(nn, kk):>11,}")
    print()


def main() -> None:
    demo_zero_counting()
    demo_grs_min_distance()
    demo_unique_decoding()
    demo_bch_bound()
    demo_parameters()


if __name__ == "__main__":
    main()
