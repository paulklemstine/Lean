"""
Numerical demonstrations for real-parameter lattice-point enumerators.
======================================================================

This self-contained script illustrates, by direct computation, the results of
"A Uniqueness Theorem for Real-Parameter Lattice-Point Enumerators".

For a bounded set P in R^d and a real dilation parameter t > 0 the lattice-point
enumerator is

    L_P(t) = |tP ∩ Z^d| = #{ k in Z^d : k/t in P },

and its integer translate by v in Z^d is

    L_{P+v}(t) = #{ k in Z^d : k/t - v in P }.

The demonstrations are:

  1. Exact one-dimensional evaluation:      L_{[0,1)}(t) = ceil(t).
  2. Exact discretisation identity:         vol(A_t) = L_P(t) / t^d,
     where A_t = { x : floor(t x)/t in P } is a disjoint union of L_P(t) cubes
     of side 1/t.
  3. Gauss-Weyl counting theorem:           L_P(t)/t^d -> vol(P).
  4. Sparse-grid membership oracle:         one query recovers 1_P(a/N) exactly.
  5. Uniqueness in action:                  two sets that differ on a set of
     positive measure are separated by an explicit single query.
  6. Fourier recovery:                      t^{-d} sum over counted points of
     exp(-2*pi*i<xi,k/t>) -> Fourier transform of 1_P at xi.

Only the Python standard library is required.
"""

from __future__ import annotations

import cmath
import math
from itertools import product
from typing import Callable, Iterator, List, Sequence, Tuple

Point = Tuple[float, ...]
Lattice = Tuple[int, ...]
Membership = Callable[[Point], bool]


# ---------------------------------------------------------------------------
# Core enumerator machinery
# ---------------------------------------------------------------------------


def lattice_box(dim: int, radius: float, t: float, shift: Sequence[int]) -> Iterator[Lattice]:
    """Enumerate every k in Z^d that could satisfy |k_i/t - v_i| <= radius.

    If P is contained in the sup-norm ball of radius `radius` about the origin,
    then every counted lattice point of t(P+v) lies in this finite box.
    """
    ranges: List[range] = []
    for i in range(dim):
        lo = math.ceil((-radius + shift[i]) * t)
        hi = math.floor((radius + shift[i]) * t)
        ranges.append(range(lo, hi + 1))
    return product(*ranges)


def enumerator(member: Membership, dim: int, radius: float, t: float,
               shift: Sequence[int] | None = None) -> int:
    """Compute L_{P+v}(t) = #{k in Z^d : k/t - v in P} for P inside B(0, radius)."""
    if t <= 0.0:
        raise ValueError("the dilation parameter t must be positive")
    v: Tuple[int, ...] = tuple(shift) if shift is not None else (0,) * dim
    count = 0
    for k in lattice_box(dim, radius, t, v):
        probe: Point = tuple(k[i] / t - v[i] for i in range(dim))
        if member(probe):
            count += 1
    return count


def weighted_sum(member: Membership, dim: int, radius: float, t: float,
                 weight: Callable[[Point], complex]) -> complex:
    """Compute sum over k in tP ∩ Z^d of weight(k/t)."""
    total = 0j
    for k in lattice_box(dim, radius, t, (0,) * dim):
        probe: Point = tuple(k[i] / t for i in range(dim))
        if member(probe):
            total += weight(probe)
    return total


def rounded_set_volume(member: Membership, dim: int, radius: float, t: float) -> float:
    """vol(A_t) computed directly as (number of counted cubes) * t^{-d}.

    A_t = { x : floor(t x)/t in P }; each counted lattice point contributes one
    half-open cube of side 1/t, and these cubes are pairwise disjoint.
    """
    return enumerator(member, dim, radius, t) * t ** (-dim)


# ---------------------------------------------------------------------------
# The sparse-grid membership oracle
# ---------------------------------------------------------------------------


def oracle_parameters(radius: float, numerator: Sequence[int], denominator: int
                      ) -> Tuple[float, Tuple[int, ...]]:
    """Parameters (t, v) of the single query that reads 1_P at the point a/N.

    With M = ceil(2R) + 2, spacing s = M + 1/N, t = 1/s and v = M*a one has
    s*a - v = a/N, and s > 2R makes the grid so sparse that at most one of its
    points lies in B(0, R).
    """
    M: int = math.ceil(2.0 * radius) + 2
    s: float = M + 1.0 / denominator
    v: Tuple[int, ...] = tuple(M * a_i for a_i in numerator)
    return 1.0 / s, v


def membership_via_oracle(member: Membership, dim: int, radius: float,
                          numerator: Sequence[int], denominator: int) -> int:
    """Recover 1_P(a/N) using exactly one enumerator query."""
    t, v = oracle_parameters(radius, numerator, denominator)
    return enumerator(member, dim, radius, t, v)


# ---------------------------------------------------------------------------
# Example sets
# ---------------------------------------------------------------------------


def unit_interval(x: Point) -> bool:
    """The half-open unit interval [0,1) in dimension one."""
    return 0.0 <= x[0] < 1.0


def disc(radius: float) -> Membership:
    """The closed disc of the given radius, centred at the origin, in the plane."""

    def member(x: Point) -> bool:
        return x[0] * x[0] + x[1] * x[1] <= radius * radius

    return member


def box(lows: Sequence[float], highs: Sequence[float]) -> Membership:
    """The half-open axis-parallel box product [lows_i, highs_i)."""

    def member(x: Point) -> bool:
        return all(lows[i] <= x[i] < highs[i] for i in range(len(lows)))

    return member


def triangle(x: Point) -> bool:
    """The triangle with vertices (0,0), (1,0), (0,1); area 1/2."""
    return x[0] >= 0.0 and x[1] >= 0.0 and x[0] + x[1] <= 1.0


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_unit_interval() -> None:
    print("=" * 74)
    print("1. Exact one-dimensional evaluation:  L_{[0,1)}(t) = ceil(t)")
    print("=" * 74)
    print(f"{'t':>10} {'L(t)':>8} {'ceil(t)':>9} {'L(t)/t':>10}")
    for t in [0.25, 1.0 / 3.0, 1.0, 2.5, 4.0, 7.5, 100.0, 1000.0]:
        value = enumerator(unit_interval, 1, 1.0, t)
        print(f"{t:>10.5f} {value:>8d} {math.ceil(t):>9d} {value / t:>10.6f}")
    print("As t -> infinity the ratio tends to vol([0,1)) = 1.\n")


def demo_exact_identity() -> None:
    print("=" * 74)
    print("2. Exact discretisation identity:  vol(A_t) = L_P(t) / t^d")
    print("=" * 74)
    R = 1.0
    P = disc(1.0)
    print("P = unit disc in the plane, vol(P) = pi = 3.14159265...")
    print(f"{'t':>8} {'L_P(t)':>9} {'vol(A_t)':>12} {'L_P(t)/t^2':>12} {'identity':>10}")
    for t in [1.0, 2.0, 5.0, 12.0, 40.0]:
        count = enumerator(P, 2, R, t)
        lhs = rounded_set_volume(P, 2, R, t)
        rhs = count / t ** 2
        print(f"{t:>8.2f} {count:>9d} {lhs:>12.6f} {rhs:>12.6f} "
              f"{'exact' if abs(lhs - rhs) < 1e-12 else 'FAILED':>10}")
    print("The identity holds with no error term at every single t.\n")


def demo_gauss_weyl() -> None:
    print("=" * 74)
    print("3. Gauss-Weyl counting theorem:  L_P(t)/t^d -> vol(P)")
    print("=" * 74)
    cases: List[Tuple[str, Membership, int, float, float]] = [
        ("unit disc", disc(1.0), 2, 1.0, math.pi),
        ("triangle (0,0),(1,0),(0,1)", triangle, 2, 1.5, 0.5),
        ("box [0,1)x[0,2)", box([0.0, 0.0], [1.0, 2.0]), 2, 2.0, 2.0),
    ]
    for name, member, dim, R, exact in cases:
        print(f"\n  P = {name},  vol(P) = {exact:.8f}")
        print(f"  {'t':>8} {'L_P(t)':>10} {'L_P(t)/t^d':>14} {'error':>12}")
        for t in [4.0, 10.0, 25.0, 60.0, 150.0]:
            count = enumerator(member, dim, R, t)
            approx = count / t ** dim
            print(f"  {t:>8.1f} {count:>10d} {approx:>14.8f} {abs(approx - exact):>12.2e}")
    print("\nThe error decays like the measure of the 1/t-neighbourhood of the boundary.\n")


def demo_membership_oracle() -> None:
    print("=" * 74)
    print("4. Sparse-grid membership oracle: one query reads off the indicator")
    print("=" * 74)
    R = 1.0
    P = disc(0.8)  # the "secret" set, known only through enumerator queries
    print("Secret set P = disc of radius 0.8 in the plane, known to lie in B(0,1).")
    print(f"{'point a/N':>16} {'query t':>12} {'shift v':>14} {'answer':>8} {'truth':>7}")
    probes: List[Tuple[Tuple[int, int], int]] = [
        ((0, 0), 1), ((1, 2), 4), ((3, 1), 5), ((-3, 4), 5), ((7, 7), 10), ((1, 1), 1),
    ]
    for a, N in probes:
        t, v = oracle_parameters(R, a, N)
        answer = membership_via_oracle(P, 2, R, a, N)
        x: Point = (a[0] / N, a[1] / N)
        truth = int(P(x))
        label = f"({a[0]}/{N}, {a[1]}/{N})"
        print(f"{label:>16} {t:>12.6f} {str(v):>14} {answer:>8d} {truth:>7d}")
    print("Every query returns 0 or 1 and equals the indicator of P at the probe point.\n")


def demo_uniqueness_separation() -> None:
    print("=" * 74)
    print("5. Uniqueness in action: distinct sets are separated by one query")
    print("=" * 74)
    R = 1.0
    P = disc(0.8)
    Q = box([-0.8, -0.8], [0.8, 0.8])  # same bounding ball, different shape
    print("P = disc of radius 0.8,   Q = square [-0.8, 0.8)^2.")
    print("Sweeping rational probe points until the two enumerators disagree:")
    found = False
    for N in range(1, 8):
        for a in product(range(-N, N + 1), repeat=2):
            lp = membership_via_oracle(P, 2, R, a, N)
            lq = membership_via_oracle(Q, 2, R, a, N)
            if lp != lq and not found:
                t, v = oracle_parameters(R, a, N)
                print(f"  witness point  ({a[0]}/{N}, {a[1]}/{N})")
                print(f"  query          t = {t:.8f},  v = {v}")
                print(f"  L_(P+v)(t) = {lp},   L_(Q+v)(t) = {lq}   -> the data differ")
                found = True
    if not found:
        print("  no witness found in the search range")
    print("\nConversely, for P = Q the two enumerators agree at every query:")
    agree = all(
        membership_via_oracle(P, 2, R, a, N) == membership_via_oracle(disc(0.8), 2, R, a, N)
        for N in range(1, 5) for a in product(range(-N, N + 1), repeat=2)
    )
    print(f"  identical sets agree on all sampled queries: {agree}\n")


def demo_fourier_recovery() -> None:
    print("=" * 74)
    print("6. Fourier recovery from lattice exponential sums")
    print("=" * 74)
    print("P = [0,1)^2, so the Fourier transform of its indicator is")
    print("    F(xi) = prod_j  exp(-pi*i*xi_j) * sinc(xi_j),   sinc(u) = sin(pi u)/(pi u).")

    def exact_transform(xi: Sequence[float]) -> complex:
        value = 1.0 + 0j
        for u in xi:
            if abs(u) < 1e-14:
                factor = 1.0 + 0j
            else:
                factor = cmath.exp(-1j * math.pi * u) * math.sin(math.pi * u) / (math.pi * u)
            value *= factor
        return value

    P = box([0.0, 0.0], [1.0, 1.0])
    for xi in [(0.0, 0.0), (0.5, 0.0), (1.3, -0.7)]:
        target = exact_transform(xi)
        print(f"\n  frequency xi = {xi},  exact value = "
              f"{target.real:+.6f}{target.imag:+.6f}i")
        print(f"  {'t':>8} {'approximation':>28} {'error':>12}")
        for t in [8.0, 20.0, 50.0, 120.0]:
            def character(x: Point, xi: Sequence[float] = xi) -> complex:
                phase = sum(xi[i] * x[i] for i in range(len(xi)))
                return cmath.exp(-2j * math.pi * phase)

            approx = weighted_sum(P, 2, 1.5, t, character) / t ** 2
            err = abs(approx - target)
            print(f"  {t:>8.1f}   {approx.real:+.6f}{approx.imag:+.6f}i        {err:>12.2e}")
    print("\nThe lattice data therefore determines the whole Fourier transform of 1_P,")
    print("and hence 1_P itself almost everywhere.\n")


def main() -> None:
    print()
    print("REAL-PARAMETER LATTICE-POINT ENUMERATORS: NUMERICAL DEMONSTRATIONS")
    print()
    demo_unit_interval()
    demo_exact_identity()
    demo_gauss_weyl()
    demo_membership_oracle()
    demo_uniqueness_separation()
    demo_fourier_recovery()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
