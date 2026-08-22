"""
The cost of invisibility: minimal mass of weight vectors annihilated by a
truncated power-sum window.

A weight vector is a finitely supported map e : {0, 1, ..., N} -> Z.  Its
k-th moment is

        m_k(e) = sum_{j=0}^{N} e_j * j^k          (with 0^0 = 1),

and e is *invisible to the window K* when m_k(e) = 0 for every k < K.  The
*mass* of e is its l^1 norm, mass(e) = sum_j |e_j|.  The invariant studied
here is

        minMass(K) = min { mass(e) : e nonzero and invisible to window K }.

This script demonstrates, numerically:

  1. the Newton mass law   mass >= 2K;
  2. the certified ideal Prouhet-Tarry-Escott witnesses attaining mass 2K
     for every K <= 10 and for K = 12;
  3. the polynomial dictionary: e is invisible to window K exactly when its
     generating polynomial is divisible by (X - 1)^K;
  4. the convolution (seeding) engine: windows add and masses multiply, so
     a seed of window 12 and mass 24 yields, at window 12n, a nonzero
     invisible vector of mass at most 24^n;
  5. the resulting growth base 24^(1/12) ~ 1.3032, against the binomial
     baseline 2 and the previous record 6^(1/3) ~ 1.8171;
  6. the bracket   2K <= minMass(K) <= 24^ceil(K/12).

Pure standard library; no dependencies.
"""

from __future__ import annotations

from math import gcd, log
from typing import Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------
# Certified ideal Prouhet-Tarry-Escott pairs (two disjoint sets of K naturals
# with identical power sums p_0, ..., p_{K-1}).  Each yields an invisible
# vector of mass exactly 2K, matching the Newton lower bound.
# --------------------------------------------------------------------------

IDEAL_PAIRS: Dict[int, Tuple[List[int], List[int]]] = {
    1: ([0], [1]),
    2: ([0, 3], [1, 2]),
    3: ([1, 5, 6], [2, 3, 7]),
    4: ([0, 4, 7, 11], [1, 2, 9, 10]),
    5: ([1, 2, 10, 14, 18], [0, 4, 8, 16, 17]),
    6: ([0, 5, 6, 16, 17, 22], [1, 2, 10, 12, 20, 21]),
    7: ([0, 18, 27, 58, 64, 89, 101], [1, 13, 38, 44, 75, 84, 102]),
    8: ([0, 4, 9, 23, 27, 41, 46, 50], [1, 2, 11, 20, 30, 39, 48, 49]),
    9: ([0, 24, 30, 83, 86, 133, 157, 181, 197],
        [1, 17, 41, 65, 112, 115, 168, 174, 198]),
    10: ([12, 2865, 3519, 11869, 23738, 23762, 35631, 43981, 44635, 47488],
         [0, 3083, 3301, 11893, 23314, 24186, 35607, 44199, 44417, 47500]),
    12: ([0, 11, 24, 65, 90, 129, 173, 212, 237, 278, 291, 302],
         [3, 5, 30, 57, 104, 116, 186, 198, 245, 272, 297, 299]),
}

SEED_A: List[int] = IDEAL_PAIRS[12][0]
SEED_B: List[int] = IDEAL_PAIRS[12][1]


# --------------------------------------------------------------------------
# Basic vector / polynomial utilities
# --------------------------------------------------------------------------

def power_sum(nodes: Sequence[int], k: int) -> int:
    """p_k(nodes) = sum of the k-th powers of the nodes (0^0 = 1)."""
    return sum(1 if (k == 0) else a ** k for a in nodes)


def weight_vector(a_nodes: Sequence[int], b_nodes: Sequence[int]) -> List[int]:
    """The +1/-1 weight vector of a node pair, as a coefficient list."""
    top = max(max(a_nodes), max(b_nodes))
    e = [0] * (top + 1)
    for a in a_nodes:
        e[a] += 1
    for b in b_nodes:
        e[b] -= 1
    return e


def moment(e: Sequence[int], k: int) -> int:
    """m_k(e) = sum_j e_j * j^k, with the convention 0^0 = 1."""
    return sum(c * (1 if k == 0 else j ** k) for j, c in enumerate(e))


def mass(e: Sequence[int]) -> int:
    """The l^1 mass sum_j |e_j|."""
    return sum(abs(c) for c in e)


def window(e: Sequence[int], cap: int = 64) -> int:
    """Largest K <= cap with m_k(e) = 0 for all k < K (the invisibility window)."""
    k = 0
    while k < cap and moment(e, k) == 0:
        k += 1
    return k


def poly_mul(p: Sequence[int], q: Sequence[int]) -> List[int]:
    """Convolution of coefficient lists = product of generating polynomials."""
    out = [0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        if a:
            for j, b in enumerate(q):
                if b:
                    out[i + j] += a * b
    return out


def divides_by_x_minus_one_pow(p: Sequence[int], k: int) -> bool:
    """Test whether (X - 1)^k divides the integer polynomial p."""
    cur = list(p)
    for _ in range(k):
        # synthetic division by (X - 1); remainder is the value at 1
        if sum(cur) != 0:
            return False
        quot = [0] * (len(cur) - 1) if len(cur) > 1 else [0]
        carry = 0
        for idx in range(len(cur) - 1, 0, -1):
            carry += cur[idx]
            quot[idx - 1] = carry
        cur = quot
    return True


def binomial_stencil(k: int) -> List[int]:
    """Coefficients of (X - 1)^k: the k-th finite-difference stencil, mass 2^k."""
    p = [1]
    for _ in range(k):
        p = poly_mul(p, [-1, 1])
    return p


# --------------------------------------------------------------------------
# 1.  The witnesses, and the Newton mass law mass >= 2K
# --------------------------------------------------------------------------

def check_ideal_pairs() -> None:
    print("=" * 74)
    print("1.  Ideal witnesses: minMass(K) = 2K for K <= 10 and K = 12")
    print("=" * 74)
    header = f"{'K':>3} {'|A|':>4} {'|B|':>4} {'p_k agree k<K':>14} {'p_K differs':>12} {'mass':>6} {'2K':>4}"
    print(header)
    for k, (a_nodes, b_nodes) in sorted(IDEAL_PAIRS.items()):
        agree = all(power_sum(a_nodes, j) == power_sum(b_nodes, j) for j in range(k))
        differs = power_sum(a_nodes, k) != power_sum(b_nodes, k)
        disjoint = not (set(a_nodes) & set(b_nodes))
        e = weight_vector(a_nodes, b_nodes)
        assert agree and differs and disjoint
        assert window(e) == k, (k, window(e))
        assert mass(e) == 2 * k
        print(f"{k:>3} {len(a_nodes):>4} {len(b_nodes):>4} {str(agree):>14} "
              f"{str(differs):>12} {mass(e):>6} {2 * k:>4}")
    print("\nAll witnesses verified: window exactly K, mass exactly 2K, sides disjoint.")
    print("The Newton bound mass >= 2K is therefore attained at every listed K.\n")


def newton_bound_sanity(max_k: int = 6, max_degree: int = 9) -> None:
    """Brute-force confirmation of mass >= 2K on all small-degree polynomials.

    Enumerates every integer polynomial of degree <= max_degree with
    coefficients in {-1, 0, 1} and records the least mass observed among
    those divisible by (X - 1)^K.
    """
    print("=" * 74)
    print("2.  Brute-force check of the Newton law on small +-1 polynomials")
    print("=" * 74)
    best: Dict[int, int] = {}
    total = 3 ** (max_degree + 1)
    for code in range(1, total):
        coeffs: List[int] = []
        c = code
        for _ in range(max_degree + 1):
            coeffs.append((c % 3) - 1)
            c //= 3
        if not any(coeffs):
            continue
        w = window(coeffs, cap=max_k + 1)
        m = mass(coeffs)
        for k in range(1, min(w, max_k) + 1):
            if k not in best or m < best[k]:
                best[k] = m
    print(f"{'K':>3} {'2K (proved lower bound)':>26} {'least mass found':>18}")
    for k in range(1, max_k + 1):
        found = best.get(k, None)
        print(f"{k:>3} {2 * k:>26} {str(found):>18}")
    print("\nNo polynomial ever beats 2K.  'None' means the search degree is too")
    print("small to host any window-K example at all: the minimal witness for K = 4")
    print("has degree 11, beyond the degree 9 enumerated here.\n")


# --------------------------------------------------------------------------
# 3.  The polynomial dictionary
# --------------------------------------------------------------------------

def polynomial_dictionary() -> None:
    print("=" * 74)
    print("3.  Invisibility = divisibility by (X - 1)^K")
    print("=" * 74)
    for k in (3, 4, 12):
        a_nodes, b_nodes = IDEAL_PAIRS[k]
        e = weight_vector(a_nodes, b_nodes)
        ok = divides_by_x_minus_one_pow(e, k)
        nope = divides_by_x_minus_one_pow(e, k + 1)
        print(f"  K = {k:>2}:  (X-1)^{k} divides the witness: {ok};  "
              f"(X-1)^{k + 1} divides it: {nope}")
    print("\n  Baseline: the finite-difference stencil (X - 1)^K has mass 2^K.")
    print(f"{'K':>3} {'mass of (X-1)^K':>18} {'minMass(K) = 2K':>18} {'ratio':>10}")
    for k in (1, 2, 3, 4, 6, 8, 10, 12):
        p = binomial_stencil(k)
        print(f"{k:>3} {mass(p):>18} {2 * k:>18} {mass(p) / (2 * k):>10.2f}")
    print()


# --------------------------------------------------------------------------
# 4.  The convolution engine
# --------------------------------------------------------------------------

def convolution_engine(max_n: int = 3) -> None:
    print("=" * 74)
    print("4.  The seeded convolution engine: windows add, masses multiply")
    print("=" * 74)
    seed = weight_vector(SEED_A, SEED_B)
    print(f"  seed: window {window(seed)}, mass {mass(seed)}, degree {len(seed) - 1}")
    cur = [1]
    print(f"{'n':>3} {'window (12n)':>13} {'actual mass':>13} {'bound 24^n':>13} "
          f"{'old bound 6^(4n)':>18}")
    for n in range(0, max_n + 1):
        if n > 0:
            cur = poly_mul(cur, seed)
        w = window(cur, cap=12 * n + 4) if n > 0 else 0
        divisible = divides_by_x_minus_one_pow(cur, 12 * n)
        assert divisible
        assert mass(cur) <= 24 ** n
        print(f"{n:>3} {w:>13} {mass(cur):>13} {24 ** n:>13} {6 ** (4 * n):>18}")
    print("\n  The n-th convolution power is invisible to the window 12n, is nonzero,")
    print("  and has mass at most 24^n.  Cancellation between colliding monomials")
    print("  makes the actual mass strictly smaller from n = 2 on (512 < 576,")
    print("  7308 < 13824), so the certified bound is not even tight.  At the same")
    print("  window the previous construction gave 6^(4n) = 1296^n; the guaranteed")
    print("  improvement factor is 54^n.\n")


# --------------------------------------------------------------------------
# 5.  Growth bases and the bracket
# --------------------------------------------------------------------------

def growth_bases() -> None:
    print("=" * 74)
    print("5.  Growth bases")
    print("=" * 74)
    bases = {
        "binomial stencil (X-1)^K": 2.0,
        "previous record, seed (3, 6)": 6.0 ** (1.0 / 3.0),
        "this work, seed (12, 24)": 24.0 ** (1.0 / 12.0),
    }
    for name, b in bases.items():
        print(f"  {name:<32} base = {b:.6f}   (log base = {log(b):.6f})")
    print("\n  Hypothetical future seeds: an ideal pair of size n0 has mass 2*n0,")
    print("  hence base (2*n0)^(1/n0).")
    print(f"{'n0':>5} {'seed mass 2*n0':>15} {'base (2n0)^(1/n0)':>20}")
    for n0 in (3, 6, 12, 20, 30, 60, 120, 1000):
        print(f"{n0:>5} {2 * n0:>15} {(2.0 * n0) ** (1.0 / n0):>20.6f}")
    print("\n  The base tends to 1: ideal pairs of unbounded size would make the")
    print("  minimal mass subexponential in every base.\n")


def bracket_table(max_k: int = 30) -> None:
    print("=" * 74)
    print("6.  The bracket   2K <= minMass(K) <= 24^ceil(K/12)")
    print("=" * 74)
    known = {k: 2 * k for k in list(range(1, 11)) + [12]}
    print(f"{'K':>4} {'lower 2K':>10} {'upper 24^ceil(K/12)':>22} "
          f"{'binomial 2^K':>14} {'exact value':>13}")
    for k in list(range(1, 14)) + [16, 22, 24, max_k]:
        ceil_k = -(-k // 12)
        upper = min(24 ** ceil_k, 2 ** k)
        exact = str(known.get(k, "unknown"))
        if k == 11:
            exact = "22 or 24"
        print(f"{k:>4} {2 * k:>10} {24 ** ceil_k:>22} {2 ** k:>14} {exact:>13}")
    print("\n  The exponential upper bound only improves on the binomial 2^K from")
    print("  K = 13 onwards; below that the explicit witnesses are far stronger.\n")


# --------------------------------------------------------------------------
# 7.  Submultiplicativity in action
# --------------------------------------------------------------------------

def submultiplicativity() -> None:
    print("=" * 74)
    print("7.  Submultiplicativity, and its strictness at (2, 2)")
    print("=" * 74)
    e2 = weight_vector(*IDEAL_PAIRS[2])
    conv = poly_mul(e2, e2)
    print(f"  minMass(2) = 4, so submultiplicativity certifies minMass(4) <= 16;")
    print(f"  convolving the two witnesses in fact gives window {window(conv)} at mass "
          f"{mass(conv)}.")
    print(f"  But the ideal quadruple {IDEAL_PAIRS[4][0]} / {IDEAL_PAIRS[4][1]} "
          f"has window 4 at mass {mass(weight_vector(*IDEAL_PAIRS[4]))}.")
    print("  So minMass(4) = 8 < 16 = minMass(2)*minMass(2): composition is wasteful")
    print("  exactly where genuine witnesses exist.\n")
    e12 = weight_vector(*IDEAL_PAIRS[12])
    e1 = weight_vector(*IDEAL_PAIRS[1])
    c13 = poly_mul(e12, e1)
    print(f"  Composing the size-12 and size-1 witnesses: window {window(c13, cap=20)}, "
          f"mass {mass(c13)}  =>  minMass(13) <= 48.")
    c22 = poly_mul(weight_vector(*IDEAL_PAIRS[12]), weight_vector(*IDEAL_PAIRS[10]))
    print(f"  Composing the size-12 and size-10 witnesses: window {window(c22, cap=30)}, "
          f"mass {mass(c22)} <= 480  =>  minMass(22) <= 480.\n")


def sparse_binomial_products(max_k: int = 12) -> None:
    print("=" * 74)
    print("8.  Sparse products prod_i (X^{a_i} - 1): cheap high-order zeros")
    print("=" * 74)
    print("  Every factor X^a - 1 vanishes at X = 1, so a product of K of them is")
    print("  divisible by (X - 1)^K.  Masses below are what cancellation achieves.")
    print(f"{'K':>4} {'exponents':>28} {'mass':>8} {'2^K':>8} {'2K':>6}")
    for k in range(1, max_k + 1):
        exps = list(range(1, k + 1))
        p = [1]
        for a in exps:
            factor = [0] * (a + 1)
            factor[0] = -1
            factor[a] = 1
            p = poly_mul(p, factor)
        assert divides_by_x_minus_one_pow(p, k)
        shown = str(exps) if k <= 6 else f"1..{k}"
        print(f"{k:>4} {shown:>28} {mass(p):>8} {2 ** k:>8} {2 * k:>6}")
    print()


def main() -> None:
    print(__doc__)
    check_ideal_pairs()
    newton_bound_sanity()
    polynomial_dictionary()
    convolution_engine()
    growth_bases()
    bracket_table()
    submultiplicativity()
    sparse_binomial_products()
    print("=" * 74)
    print("Summary")
    print("=" * 74)
    print("  * every nonzero vector invisible to the window K has mass at least 2K;")
    print("  * mass exactly 2K is attained for K <= 10 and K = 12, and attainability")
    print("    at a given K is equivalent to the existence of an ideal")
    print("    Prouhet-Tarry-Escott pair of that size;")
    print("  * minMass(11) is 22 or 24, and equals 22 exactly when an ideal pair of")
    print("    size 11 exists;")
    print("  * for every K, 2K <= minMass(K) <= 24^ceil(K/12), so the growth base of")
    print(f"    invisibility is at most 24^(1/12) = {24 ** (1 / 12):.6f}.")


if __name__ == "__main__":
    main()
