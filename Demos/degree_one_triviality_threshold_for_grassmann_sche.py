"""Numerical demonstrations for the degree-one triviality threshold backbone.

This self-contained script reproduces, with exact integer arithmetic, every
verified identity about Gaussian binomial coefficients (q-binomials) that
underpins the Grassmann-scheme degree-one triviality threshold conjecture:

* qBinom        -- the division-free q-Pascal recurrence
                   [n+1,k+1]_q = [n,k]_q + q^{k+1} [n,k+1]_q
* qBinom_one             -- [n,k]_1 = C(n,k)            (classical limit)
* qBinom_pos            -- [n,k]_q >= 1 for k <= n, q >= 1
* qBinom_one_eq_geom    -- [n,1]_q = 1 + q + ... + q^{n-1}
* qBinom_symm           -- [n,k]_q = [n,n-k]_q          (mirror symmetry)
* point_hyperplane_duality -- [n,1]_q = [n,n-1]_q
* qBinom_strictMono_left   -- [n,k]_q < [n+1,k]_q for q >= 2
* qBinom_one_unimodal_bound -- [n,k]_1 <= [n, n//2]_1
* qBinom_one_mono_ambient   -- [n,k]_1 <= [m,k]_1 for n <= m
* qBinom_one_total_mass     -- sum_k [n,k]_1 = 2^n

Run with `python demo.py`.
"""

from __future__ import annotations

from math import comb
from functools import lru_cache


@lru_cache(maxsize=None)
def q_binom(q: int, n: int, k: int) -> int:
    """Gaussian binomial [n,k]_q via the division-free q-Pascal recurrence.

    Definition (matching the Lean `qBinom`):
        [n,0]_q   = 1
        [0,k+1]_q = 0
        [n+1,k+1]_q = [n,k]_q + q^{k+1} * [n,k+1]_q
    """
    if k < 0 or k > n:
        return 0
    if k == 0:
        return 1
    if n == 0:
        return 0
    return q_binom(q, n - 1, k - 1) + (q ** k) * q_binom(q, n - 1, k)


def point_count_geom(q: int, n: int) -> int:
    """[n,1]_q as the geometric series 1 + q + ... + q^{n-1}."""
    return sum(q ** i for i in range(n))


def demo_classical_limit(n_max: int = 8) -> None:
    """qBinom_one: at q = 1 the q-binomial is the ordinary binomial."""
    print("== qBinom_one : [n,k]_1 = C(n,k) ==")
    for n in range(n_max + 1):
        row_q = [q_binom(1, n, k) for k in range(n + 1)]
        row_c = [comb(n, k) for k in range(n + 1)]
        assert row_q == row_c, (n, row_q, row_c)
        print(f"  n={n}: {row_q}")
    print("  OK: q=1 row equals Pascal's triangle for all tested n.\n")


def demo_point_count(q_values=(2, 3, 4, 5), n_max: int = 6) -> None:
    """qBinom_one_eq_geom: [n,1]_q = 1 + q + ... + q^{n-1}."""
    print("== qBinom_one_eq_geom : [n,1]_q = sum q^i ==")
    for q in q_values:
        for n in range(1, n_max + 1):
            lhs = q_binom(q, n, 1)
            rhs = point_count_geom(q, n)
            assert lhs == rhs == (q ** n - 1) // (q - 1), (q, n, lhs, rhs)
        seq = [q_binom(q, n, 1) for n in range(1, n_max + 1)]
        print(f"  q={q}: [n,1]_q = {seq}")
    print("  OK: point counts match the geometric series and (q^n-1)/(q-1).\n")


def demo_symmetry(q_values=(2, 3, 5), n_max: int = 7) -> None:
    """qBinom_symm and point_hyperplane_duality: [n,k]_q = [n,n-k]_q."""
    print("== qBinom_symm : [n,k]_q = [n,n-k]_q ==")
    for q in q_values:
        for n in range(n_max + 1):
            for k in range(n + 1):
                assert q_binom(q, n, k) == q_binom(q, n, n - k), (q, n, k)
        # point/hyperplane duality is the k = 1 slice
        for n in range(1, n_max + 1):
            assert q_binom(q, n, 1) == q_binom(q, n, n - 1), (q, n)
    print("  OK: mirror symmetry holds; [n,1]_q = [n,n-1]_q (points=hyperplanes).\n")


def demo_strict_mono(q_values=(2, 3, 4), n_max: int = 7) -> None:
    """qBinom_strictMono_left: [n,k]_q < [n+1,k]_q for q >= 2."""
    print("== qBinom_strictMono_left : [n,k]_q < [n+1,k]_q (q>=2) ==")
    for q in q_values:
        for n in range(1, n_max + 1):
            for k in range(1, n + 1):
                assert q_binom(q, n, k) < q_binom(q, n + 1, k), (q, n, k)
    # contrast: past the diagonal (k > n) q = 1 binomials plateau at 0,
    # so strict growth genuinely needs q >= 2 there.
    nonstrict = q_binom(1, 3, 5) == q_binom(1, 4, 5)  # 0 == 0 -> NOT strict
    print(f"  q>=2: strict growth confirmed for all tested (n,k).")
    print(f"  q=1 past the diagonal: [3,5]_1 = {q_binom(1,3,5)}, "
          f"[4,5]_1 = {q_binom(1,4,5)} -> not strictly increasing.\n")
    assert nonstrict


def demo_classical_shadows(n_max: int = 8) -> None:
    """Unimodality, ambient monotonicity, and total mass at q = 1."""
    print("== q=1 shadows: unimodality, monotonicity, total mass ==")
    for n in range(n_max + 1):
        mid = q_binom(1, n, n // 2)
        for k in range(n + 1):
            assert q_binom(1, n, k) <= mid  # qBinom_one_unimodal_bound
        total = sum(q_binom(1, n, k) for k in range(n + 1))
        assert total == 2 ** n  # qBinom_one_total_mass
    for k in range(n_max + 1):  # qBinom_one_mono_ambient
        for n in range(k, n_max):
            assert q_binom(1, n, k) <= q_binom(1, n + 1, k)
    print(f"  OK: [n,k]_1 <= [n,n//2]_1 (unimodal); sum_k [n,k]_1 = 2^n; "
          f"monotone in n.\n")


def demo_table(q: int = 3, n_max: int = 6) -> None:
    """Print the q-Pascal triangle for a chosen q."""
    print(f"== q-Pascal triangle for q = {q} ==")
    for n in range(n_max + 1):
        row = [q_binom(q, n, k) for k in range(n + 1)]
        print(f"  n={n}: {row}")
    print()


def main() -> None:
    print("Degree-one triviality threshold: verified q-binomial backbone\n")
    demo_classical_limit()
    demo_point_count()
    demo_symmetry()
    demo_strict_mono()
    demo_classical_shadows()
    demo_table(q=3)
    demo_table(q=2)
    print("All numerical checks passed.")


if __name__ == "__main__":
    main()
