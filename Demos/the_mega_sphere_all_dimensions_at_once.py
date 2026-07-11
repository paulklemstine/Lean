"""The Mega-Sphere: numerical demonstrations.

Self-contained Python demonstrations of the three strands developed in the
accompanying paper:

  1. Inverse limits of towers -- coherence, the collapse of the doubling tower,
     and the nontrivial 2-adic tower.
  2. The cohomological fingerprint of RP^infinity -- the dual Stiefel-Whitney
     series inverting (1 + w) in the ring of formal power series over F_2.
  3. Bernoulli numbers -- the recurrence, odd vanishing, and Faulhaber /
     Nicomachus power-sum identities.

Only the Python standard library is used (fractions for exact arithmetic).
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import Callable, List, Sequence


# ---------------------------------------------------------------------------
# 1. Inverse limits of towers
# ---------------------------------------------------------------------------

def is_coherent(seq: Sequence[int], pi: Callable[[int, int], int]) -> bool:
    """Return True iff (x_0, ..., x_N) is a coherent sequence for the tower.

    A sequence is coherent when pi(n, x_{n+1}) == x_n for every valid n, i.e.
    it is an element of the inverse limit restricted to the first N+1 stages.
    """
    return all(pi(n, seq[n + 1]) == seq[n] for n in range(len(seq) - 1))


def doubling_pi(_n: int, x: int) -> int:
    """Connecting map of the doubling tower Z <--x2-- Z: multiplication by 2."""
    return 2 * x


def two_adic_pi(n: int, x: int) -> int:
    """Reduction Z/2^(n+2) -> Z/2^(n+1) for the 2-adic tower."""
    return x % (2 ** (n + 1))


def demo_inverse_limits() -> None:
    print("=" * 66)
    print("1. INVERSE LIMITS OF TOWERS")
    print("=" * 66)

    # Doubling tower collapses: the only coherent sequence is all-zero.
    # A nonzero start cannot be extended coherently far, because x_0 must be
    # divisible by every power of 2.
    print("\nDoubling tower  Z <--x2-- Z <--x2-- ...")
    zero = [0, 0, 0, 0, 0]
    print(f"  all-zero sequence coherent? {is_coherent(zero, doubling_pi)}")
    attempt = [8, 4, 2, 1]  # 8 = 2*4, 4 = 2*2, 2 = 2*1 -- but 1 is not 2*(int)
    print(f"  [8,4,2,1] coherent? {is_coherent(attempt, doubling_pi)}  "
          "(1 cannot be halved in Z -> limit collapses to 0)")

    # 2-adic tower thrives: the residues of any fixed integer are coherent.
    print("\n2-adic tower  Z/2 <- Z/4 <- Z/8 <- ...")
    for value in (1, 5, 13):
        residues = [value % (2 ** (n + 1)) for n in range(6)]
        print(f"  residues of {value:>2}: {residues}  coherent? "
              f"{is_coherent(residues, two_adic_pi)}")
    print("  -> nonzero coherent sequences exist: the limit is Z_2 (nontrivial).")


# ---------------------------------------------------------------------------
# 2. Dual Stiefel-Whitney series in F_2[[w]]
# ---------------------------------------------------------------------------

def poly_mul_mod2(a: List[int], b: List[int], truncate: int) -> List[int]:
    """Multiply two polynomials over F_2, truncated at degree < `truncate`."""
    out = [0] * truncate
    for i, ai in enumerate(a):
        if ai % 2 == 0:
            continue
        for j, bj in enumerate(b):
            if i + j < truncate and bj % 2:
                out[i + j] ^= 1
    return out


def demo_dual_stiefel_whitney(truncate: int = 8) -> None:
    print("\n" + "=" * 66)
    print("2. DUAL STIEFEL-WHITNEY SERIES IN F_2[[w]]")
    print("=" * 66)
    total = [1, 1]                    # 1 + w
    dual = [1] * truncate            # 1 + w + w^2 + ... (the geometric series)
    product = poly_mul_mod2(total, dual, truncate)
    print(f"\n  total class  (1 + w)")
    print(f"  dual  class  (1 + w + w^2 + ... ) truncated to degree {truncate-1}")
    print(f"  (1 + w) * dual  =  {product}")
    print(f"  equals 1 in F_2[[w]]? {product == [1] + [0] * (truncate - 1)}")


# ---------------------------------------------------------------------------
# 3. Bernoulli numbers, Faulhaber, Nicomachus
# ---------------------------------------------------------------------------

def bernoulli_numbers(n_max: int) -> List[Fraction]:
    """Return [B_0, ..., B_{n_max}] with the B_1 = -1/2 convention.

    Uses the recurrence sum_{k=0}^{m} C(m+1, k) B_k = 0, solved for B_m.
    """
    b: List[Fraction] = []
    for m in range(n_max + 1):
        if m == 0:
            b.append(Fraction(1))
            continue
        s = sum(Fraction(comb(m + 1, k)) * b[k] for k in range(m))
        b.append(-s / Fraction(comb(m + 1, m)))
    return b


def power_sum_faulhaber(p: int, n: int, bern: List[Fraction]) -> Fraction:
    """Closed-form sum_{k=0}^{n-1} k^p via Bernoulli coefficients."""
    total = Fraction(0)
    for j in range(p + 1):
        total += Fraction(comb(p + 1, j)) * bern[j] * Fraction(n) ** (p + 1 - j)
    return total / Fraction(p + 1)


def demo_bernoulli() -> None:
    print("\n" + "=" * 66)
    print("3. BERNOULLI NUMBERS, FAULHABER, NICOMACHUS")
    print("=" * 66)
    bern = bernoulli_numbers(10)
    print("\n  Bernoulli numbers B_0 .. B_10:")
    for i, bi in enumerate(bern):
        print(f"    B_{i:>2} = {str(bi):>6}")
    print(f"\n  B_2 == 1/6 ? {bern[2] == Fraction(1, 6)}")
    print("  odd vanishing B_3=B_5=B_7=B_9=0 ? "
          f"{all(bern[m] == 0 for m in (3, 5, 7, 9))}")

    print("\n  Faulhaber closed forms vs direct summation:")
    for p in (1, 2, 3):
        for n in (5, 10, 20):
            direct = sum(Fraction(k) ** p for k in range(n))
            closed = power_sum_faulhaber(p, n, bern)
            ok = direct == closed
            print(f"    sum_{{k<{n:>2}}} k^{p} = {str(closed):>8}   matches? {ok}")

    print("\n  Nicomachus  sum k^3 == (sum k)^2 :")
    for n in (5, 10, 25):
        cubes = sum(k ** 3 for k in range(n))
        squared = sum(k for k in range(n)) ** 2
        print(f"    n={n:>2}:  {cubes} == {squared} ? {cubes == squared}")


def main() -> None:
    demo_inverse_limits()
    demo_dual_stiefel_whitney()
    demo_bernoulli()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
