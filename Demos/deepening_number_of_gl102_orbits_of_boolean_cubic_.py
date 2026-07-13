"""
Numerical demonstration of the structural window for the number of
GL(n, 2)-orbits of Boolean cubic forms.

A Boolean cubic form in n variables over GF(2) is a squarefree homogeneous
degree-three polynomial: one GF(2) coefficient per unordered triple of indices.
The space of forms has dimension C(n, 3), so there are 2^C(n,3) forms. The group
GL(n, 2) of invertible n x n matrices over GF(2) acts by linear substitution of
variables; the number of orbits classifies forms up to linear equivalence.

By the orbit-counting (pigeonhole) principle, each orbit has size at most |GL(n,2)|,
so the number of nonzero orbits is at least ceil((2^C(n,3) - 1) / |GL(n,2)|).

For n = 10 this floor is 3_627_409, and the proposed exact count 3_691_560 exceeds
it by exactly 64_151 (1.77%). All arithmetic here is exact big-integer arithmetic.
"""

from __future__ import annotations

from math import comb


def gl_order(n: int, q: int = 2) -> int:
    """Exact order of GL(n, q): product over i=0..n-1 of (q^n - q^i)."""
    order: int = 1
    for i in range(n):
        order *= q**n - q**i
    return order


def num_boolean_cubic_forms(n: int) -> int:
    """Number of Boolean cubic forms in n variables: 2^C(n,3)."""
    return 2 ** comb(n, 3)


def ceil_div(a: int, b: int) -> int:
    """Exact ceiling of a / b for positive integers."""
    return -(-a // b)


def pigeonhole_floor_nonzero(n: int, q: int = 2) -> int:
    """Proven lower bound on the number of NONZERO orbits:
    ceil((#forms - 1) / |GL(n,q)|)."""
    forms: int = num_boolean_cubic_forms(n)
    return ceil_div(forms - 1, gl_order(n, q))


def pigeonhole_floor_total(n: int, q: int = 2) -> int:
    """Proven lower bound on the TOTAL number of orbits: ceil(#forms / |GL(n,q)|)."""
    forms: int = num_boolean_cubic_forms(n)
    return ceil_div(forms, gl_order(n, q))


def window_report(n: int, proposed: int | None = None) -> dict[str, object]:
    """Assemble the two-sided window and (optionally) test a proposed count."""
    forms: int = num_boolean_cubic_forms(n)
    floor_nz: int = pigeonhole_floor_nonzero(n)
    report: dict[str, object] = {
        "n": n,
        "dimension_C(n,3)": comb(n, 3),
        "num_forms_2^C(n,3)": forms,
        "|GL(n,2)|": gl_order(n),
        "lower_bound_nonzero_orbits": floor_nz,
        "upper_bound_nonzero_orbits": forms - 1,
    }
    if proposed is not None:
        report["proposed"] = proposed
        report["fits_window"] = floor_nz <= proposed <= forms - 1
        report["defect_above_floor"] = proposed - floor_nz
        report["relative_gap"] = proposed / floor_nz
    return report


def main() -> None:
    print("=" * 72)
    print("Boolean cubic form orbits: the case n = 10")
    print("=" * 72)

    n: int = 10
    forms: int = num_boolean_cubic_forms(n)
    gl: int = gl_order(n)

    print(f"dimension  C(10,3)           = {comb(n, 3)}")
    print(f"# forms    2^120             = {forms}")
    print(f"|GL(10,2)|                   = {gl}")

    floor_nz: int = pigeonhole_floor_nonzero(n)
    proposed: int = 3_691_560
    print()
    print(f"proven lower bound (nonzero) = {floor_nz:,}")
    print(f"proposed exact count         = {proposed:,}")
    print(f"upper bound (2^120 - 1)      = {forms - 1}")
    print(f"defect above floor           = {proposed - floor_nz:,}")
    print(f"relative gap                 = {proposed / floor_nz:.6f} "
          f"({100 * (proposed / floor_nz - 1):.2f}% above floor)")

    # Sanity checks against the established exact values.
    assert gl == 366_440_137_299_948_128_422_802_227_200
    assert forms == 2**120
    assert floor_nz == 3_627_409
    assert proposed - floor_nz == 64_151
    assert floor_nz <= proposed <= forms - 1
    print("\nAll exact-integer assertions pass.")

    print()
    print("=" * 72)
    print("Ratio (proposed floor) / (form count / |GL|) for several n")
    print("(illustrates how the pigeonhole floor tracks the group order)")
    print("=" * 72)
    print(f"{'n':>3} | {'C(n,3)':>7} | {'floor(nonzero)':>28}")
    print("-" * 48)
    for m in range(5, 13):
        print(f"{m:>3} | {comb(m, 3):>7} | {pigeonhole_floor_nonzero(m):>28,}")


if __name__ == "__main__":
    main()
