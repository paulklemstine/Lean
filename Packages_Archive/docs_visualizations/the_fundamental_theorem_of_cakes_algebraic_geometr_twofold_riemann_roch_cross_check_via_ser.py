from __future__ import annotations


def rr_chi(d: int, g: int) -> int:
    """Riemann-Roch Euler characteristic d + 1 - g of a degree-d line bundle."""
    return d + 1 - g


def core_dimension_two_ways(g: int) -> tuple[int, int, int]:
    """Return (deformation count, quadratic-differential count, 3g-3) and assert
    all three coincide, exhibiting the Serre-duality identity for genus g >= 2."""
    deg_T = 2 - 2 * g
    deg_K = 2 * g - 2
    deformations = -rr_chi(deg_T, g)          # h^1(T_C)
    quadratics = rr_chi(2 * deg_K, g)         # h^0(2K_C)
    closed = 3 * g - 3
    assert deformations == quadratics == closed
    return deformations, quadratics, closed
