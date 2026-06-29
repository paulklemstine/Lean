"""
Betti-Whittaker Periods and Contragredients of GL(n): numerical demonstrations.

This self-contained script exercises the main theorems of the package on
concrete integer weights:

  * periodExp_dual          e(dual(L)) == e(L)                    (Theorem 1)
  * coeff_sum_zero          sum_i (2i+1-n) == 0                   (Lemma 1)
  * periodExp_twist         e(twist(k, L)) == e(L)                (Theorem 3)
  * bw_functional_equation  e(dual(twist(k, L))) == e(L)          (Theorem 4)
  * dual_eq_self_iff        dual(L) == L  <=>  all purity == 0    (Theorem 2)
  * regularityFree_witness  (1,1,0) not regular, relation holds   (Theorem 5)

A "weight" L = (L_0, ..., L_{n-1}) is a list of integers modelling the highest
weight / infinitesimal character of a cohomological representation of GL(n).
The centered period exponent records the 2*pi*i-content of the Betti-Whittaker
period. Every function is inlined; the script runs under Python 3.9+ with no
external dependencies.
"""

from __future__ import annotations

from itertools import product
from typing import List


# --------------------------------------------------------------------------
# Core definitions (mirroring the Lean development)
# --------------------------------------------------------------------------

def period_exp(lam: List[int]) -> int:
    """Centered period exponent  e(L) = sum_i (2i + 1 - n) * L_i  (Definition 3)."""
    n = len(lam)
    return sum((2 * i + 1 - n) * lam[i] for i in range(n))


def dual(lam: List[int]) -> List[int]:
    """Contragredient: negate-and-reverse,  (L^v)_i = -L_{n-1-i}  (Definition 2)."""
    n = len(lam)
    return [-lam[n - 1 - i] for i in range(n)]


def twist(k: int, lam: List[int]) -> List[int]:
    """Determinant twist by |det|^k:  (twist k L)_i = L_i + k  (Definition 4)."""
    return [x + k for x in lam]


def is_regular(lam: List[int]) -> bool:
    """Regularity: strictly decreasing weight (strict dominance)  (Definition 5)."""
    return all(lam[i] > lam[i + 1] for i in range(len(lam) - 1))


def purity_weights(lam: List[int]) -> List[int]:
    """Purity weights  p_i = L_i + L_{n-1-i}  (Definition 6)."""
    n = len(lam)
    return [lam[i] + lam[n - 1 - i] for i in range(n)]


def centered_coeffs(n: int) -> List[int]:
    """The centered coefficient vector  c_i = 2i + 1 - n."""
    return [2 * i + 1 - n for i in range(n)]


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_balanced_gauss_sum(max_n: int = 8) -> None:
    """Lemma 1 (coeff_sum_zero): the centered coefficients sum to zero."""
    print("=== Lemma 1: balanced Gauss sum  sum_i (2i+1-n) = 0 ===")
    for n in range(1, max_n + 1):
        c = centered_coeffs(n)
        s = sum(c)
        print(f"  n={n}: coeffs={c}  sum={s}")
        assert s == 0
    print("  OK: vanishes for all tested n\n")


def demo_contragredient_invariance() -> None:
    """Theorem 1 (periodExp_dual): e(L^v) = e(L) over an exhaustive small grid."""
    print("=== Theorem 1: contragredient invariance  e(dual L) = e(L) ===")
    checked = 0
    for n in range(1, 5):
        for lam in product(range(-2, 3), repeat=n):
            L = list(lam)
            assert period_exp(dual(L)) == period_exp(L)
            checked += 1
    print(f"  OK: verified on {checked} integer weights (n=1..4, entries in -2..2)")
    # A worked example.
    L = [3, 1, -2, -4]
    print(f"  example L={L}: e={period_exp(L)},  dual={dual(L)}, "
          f"e(dual)={period_exp(dual(L))}\n")


def demo_twist_invariance() -> None:
    """Theorem 3 (periodExp_twist): e(twist k L) = e(L) for all k."""
    print("=== Theorem 3: twist invariance  e(twist k L) = e(L) ===")
    L = [3, 1, -2, -4]
    e0 = period_exp(L)
    for k in range(-5, 6):
        Lk = twist(k, L)
        ek = period_exp(Lk)
        print(f"  k={k:+d}: twist={Lk}  e={ek}")
        assert ek == e0
    print(f"  OK: invariant at e={e0} across all twists\n")


def demo_functional_equation() -> None:
    """Theorem 4 (bw_functional_equation): e(dual(twist k L)) = e(L) for all k, L."""
    print("=== Theorem 4: functional equation  e(dual(twist k L)) = e(L) ===")
    checked = 0
    for n in range(1, 5):
        for lam in product(range(-2, 3), repeat=n):
            L = list(lam)
            for k in range(-3, 4):
                assert period_exp(dual(twist(k, L))) == period_exp(L)
                checked += 1
    print(f"  OK: verified on {checked} (weight, twist) pairs\n")


def demo_self_duality() -> None:
    """Theorem 2 (dual_eq_self_iff): dual L == L  <=>  all purity weights vanish."""
    print("=== Theorem 2: self-duality  <=>  purity weights vanish ===")
    examples = [[2, 0, -2], [1, -1], [1, 1, 0], [3, 0, 0, -3]]
    for L in examples:
        p = purity_weights(L)
        sd_lhs = (dual(L) == L)
        sd_rhs = all(x == 0 for x in p)
        tag = "self-dual" if sd_lhs else "not self-dual"
        print(f"  L={L}: dual={dual(L)}  purity={p}  -> {tag}")
        assert sd_lhs == sd_rhs
    print("  OK: equivalence holds on all examples\n")


def demo_regularity_free_witness() -> None:
    """Theorem 5 (regularityFree_witness): (1,1,0) is not regular, relation holds."""
    print("=== Theorem 5: regularity-free witness  L=(1,1,0) ===")
    L = [1, 1, 0]
    print(f"  L={L}  regular? {is_regular(L)}  (Chen's hypothesis requires regular)")
    print(f"  dual(L)={dual(L)}  e(L)={period_exp(L)}  e(dual L)={period_exp(dual(L))}")
    assert not is_regular(L)
    assert period_exp(dual(L)) == period_exp(L)
    print("  OK: non-regular yet contragredient relation holds\n")


def demo_off_center_breaks(max_n: int = 6) -> None:
    """Contrast (Remark / Conjecture 1): the uncentered moment is NOT invariant."""
    print("=== Contrast: uncentered moment  m(L) = sum_i i*L_i  is NOT invariant ===")
    for n in range(2, max_n + 1):
        print(f"  n={n}: sum_i i = {sum(range(n))}  (!= 0, so twist breaks invariance)")
    L = [3, 1, -2, -4]
    n = len(L)
    m = lambda w: sum(i * w[i] for i in range(len(w)))  # noqa: E731
    defect = m(L) - m(dual(L))
    print(f"  example L={L}: m(L)={m(L)}, m(dual L)={m(dual(L))}, "
          f"defect={defect} = (n-1)*sum(L) = {(n - 1) * sum(L)}")
    assert defect == (n - 1) * sum(L)
    print("  OK: defect equals (n-1)*sum(L), as conjectured\n")


def main() -> None:
    print("Betti-Whittaker Periods and Contragredients of GL(n)")
    print("Numerical demonstration of the main theorems\n")
    demo_balanced_gauss_sum()
    demo_contragredient_invariance()
    demo_twist_invariance()
    demo_functional_equation()
    demo_self_duality()
    demo_regularity_free_witness()
    demo_off_center_breaks()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
