"""Numerical demonstrations: the join of Gorenstein polytopes is Gorenstein.

This self-contained script models the Ehrhart ``h*``-data of a Gorenstein lattice
polytope as a list of nonnegative integer coefficients ``[h_0, h_1, ..., h_s]`` with
``h_0 == 1`` (normalization), all entries ``>= 0`` (Stanley nonnegativity), and a
palindromic coefficient vector (the Stanley--Hibi Gorenstein criterion).

The *join* of two polytopes corresponds to multiplication of their ``h*``-polynomials,
i.e. the discrete convolution of their coefficient vectors.  The central fact verified
here is that the convolution of two palindromic vectors is again palindromic, so the
join of Gorenstein data is always Gorenstein.

Run with:  python demo.py
"""

from __future__ import annotations

from typing import List


# --------------------------------------------------------------------------------------
# Core operations on h*-vectors
# --------------------------------------------------------------------------------------

def true_degree(h: List[int]) -> int:
    """Return the degree of an h*-polynomial, ignoring trailing zero coefficients.

    For the zero polynomial we return 0 by convention.
    """
    s = len(h) - 1
    while s > 0 and h[s] == 0:
        s -= 1
    return s


def is_palindromic(h: List[int]) -> bool:
    """Test whether the h*-vector reads the same forwards and backwards.

    This is the Stanley--Hibi Gorenstein criterion:  h_i == h_{s-i} for all i,
    where s is the true degree (trailing zeros are ignored).
    """
    s = true_degree(h)
    return all(h[i] == h[s - i] for i in range(s + 1))


def is_gorenstein(h: List[int]) -> bool:
    """Decide whether ``h`` is valid Gorenstein h*-data.

    Requires: constant term 1, all coefficients nonnegative, and palindromy.
    """
    if not h or h[0] != 1:
        return False
    if any(c < 0 for c in h):
        return False
    return is_palindromic(h)


def join_hstar(p: List[int], q: List[int]) -> List[int]:
    """Compute the h*-vector of the join P * Q as the convolution of p and q.

    This models the classical Ehrhart identity  h*_{P*Q} = h*_P * h*_Q.
    """
    result = [0] * (len(p) + len(q) - 1)
    for j, pj in enumerate(p):
        for k, qk in enumerate(q):
            result[j + k] += pj * qk
    return result


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

def poly_str(h: List[int]) -> str:
    """Pretty-print an h*-vector as a polynomial in z."""
    terms = []
    for i, c in enumerate(h):
        if c == 0:
            continue
        if i == 0:
            terms.append(f"{c}")
        elif i == 1:
            terms.append(f"{c}z")
        else:
            terms.append(f"{c}z^{i}")
    return " + ".join(terms) if terms else "0"


def demo_basic_examples() -> None:
    print("=" * 70)
    print("Example Gorenstein h*-data (palindromic, h_0 = 1, nonnegative)")
    print("=" * 70)
    point = [1]                       # hstarPoint
    polygon = [1, 4, 1]               # hstarReflexivePolygon (reflexive triangle)
    cross = [1, 6, 1]                 # another reflexive example
    for name, h in [("point", point), ("reflexive polygon", polygon),
                    ("reflexive cross-ish", cross)]:
        print(f"  {name:22s}: {poly_str(h):20s}  Gorenstein = {is_gorenstein(h)}")
    print()


def demo_join_preserves_gorenstein() -> None:
    print("=" * 70)
    print("The join multiplies h*-polynomials and preserves the Gorenstein property")
    print("=" * 70)
    examples = [
        ([1, 4, 1], [1, 4, 1]),
        ([1, 4, 1], [1]),            # join with a point = pyramid (identity)
        ([1, 6, 1], [1, 4, 1]),
        ([1, 2, 1], [1, 3, 3, 1]),
    ]
    for p, q in examples:
        r = join_hstar(p, q)
        print(f"  ({poly_str(p)}) * ({poly_str(q)})")
        print(f"     = {poly_str(r)}")
        print(f"     degree {true_degree(p)} + {true_degree(q)} = {true_degree(r)}"
              f"   (degree additivity)")
        assert is_gorenstein(p) and is_gorenstein(q)
        assert is_gorenstein(r), "join broke the Gorenstein property!"
        print(f"     join Gorenstein = {is_gorenstein(r)}\n")


def demo_point_is_identity() -> None:
    print("=" * 70)
    print("The point (h* = 1) is the identity for the join (pyramid construction)")
    print("=" * 70)
    point = [1]
    for h in ([1, 4, 1], [1, 6, 1], [1, 2, 2, 1]):
        assert join_hstar(point, h) == h
        print(f"  point * ({poly_str(h)}) = {poly_str(join_hstar(point, h))}")
    print()


def demo_commutative_associative() -> None:
    print("=" * 70)
    print("The join is commutative and associative (a commutative monoid)")
    print("=" * 70)
    p, q, r = [1, 4, 1], [1, 2, 1], [1, 1]
    assert join_hstar(p, q) == join_hstar(q, p)
    assert join_hstar(join_hstar(p, q), r) == join_hstar(p, join_hstar(q, r))
    print(f"  p*q == q*p           : {join_hstar(p, q) == join_hstar(q, p)}")
    print(f"  (p*q)*r == p*(q*r)   : "
          f"{join_hstar(join_hstar(p, q), r) == join_hstar(p, join_hstar(q, r))}")
    print()


def demo_contrast_free_sum() -> None:
    print("=" * 70)
    print("Contrast: concatenation (a free-sum-like, non-multiplicative combine)")
    print("can destroy palindromy --- this is where the original intuition lives")
    print("=" * 70)
    a, b = [1, 4, 1], [1, 1]
    concat = a + b
    print(f"  concat({poly_str(a)}; {poly_str(b)}) coefficients = {concat}")
    print(f"  palindromic = {is_palindromic(concat)}  (join would instead give a"
          f" palindrome)")
    join = join_hstar(a, b)
    print(f"  by contrast, join coefficients = {join}, palindromic ="
          f" {is_palindromic(join)}")
    print()


def demo_random_stress_test(trials: int = 2000) -> None:
    """Randomized check: products of palindromic nonnegative vectors stay palindromic."""
    import random
    print("=" * 70)
    print(f"Randomized stress test ({trials} trials): join always Gorenstein")
    print("=" * 70)

    def random_gorenstein(max_half: int = 4, max_coeff: int = 5) -> List[int]:
        half = [1] + [random.randint(0, max_coeff) for _ in range(max_half)]
        # build a palindrome of (possibly) even or odd length
        if random.random() < 0.5:
            return half + half[-2::-1]          # odd length, middle from half[-1]
        return half + half[::-1]                # even length

    failures = 0
    for _ in range(trials):
        p, q = random_gorenstein(), random_gorenstein()
        if not (is_gorenstein(p) and is_gorenstein(q)):
            continue
        if not is_gorenstein(join_hstar(p, q)):
            failures += 1
    print(f"  failures: {failures} / {trials}")
    assert failures == 0
    print("  PASS: the join preserved the Gorenstein property in every trial.\n")


def main() -> None:
    demo_basic_examples()
    demo_join_preserves_gorenstein()
    demo_point_is_identity()
    demo_commutative_associative()
    demo_contrast_free_sum()
    demo_random_stress_test()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
