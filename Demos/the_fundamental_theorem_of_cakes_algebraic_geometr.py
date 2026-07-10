"""
The Fundamental Theorem of Cakes: numerical demonstrations.

A *cake* is a closed orientable surface of genus ``g`` (the base) with ``n``
marked points (cherries) and a uniform boundary line bundle (frosting). The
classifying object of such cakes is the moduli space M_{g,n} of n-pointed
genus-g surfaces, whose dimension is ``3g - 3 + n`` on the stable locus.

This script demonstrates, purely arithmetically:

  * the moduli dimension formula and its per-handle / per-cherry increments;
  * the two Riemann-Roch computations of ``3g - 3`` (deformations and
    quadratic differentials) and their agreement by Serre duality;
  * the stability inequality ``2g - 2 + n > 0`` and the low-genus repair;
  * the rigid Euler-Betti-moduli-canonical triangle;
  * the inductive recurrence and the enumeration check for g <= 5.

All functions are self-contained and use only integer arithmetic.
"""

from __future__ import annotations


# ---------------------------------------------------------------------------
# Base-surface invariants
# ---------------------------------------------------------------------------

def euler_char(g: int) -> int:
    """Euler characteristic of a closed orientable genus-g surface: 2 - 2g."""
    return 2 - 2 * g


def first_betti(g: int) -> int:
    """First Betti number of a genus-g surface: 2g."""
    return 2 * g


def canonical_deg(g: int) -> int:
    """Degree of the canonical bundle K_C: 2g - 2."""
    return 2 * g - 2


def tangent_deg(g: int) -> int:
    """Degree of the tangent bundle T_C = K_C^{-1}: 2 - 2g."""
    return 2 - 2 * g


def rr_chi(d: int, g: int) -> int:
    """Riemann-Roch Euler characteristic of a degree-d line bundle: d + 1 - g."""
    return d + 1 - g


# ---------------------------------------------------------------------------
# Moduli / Teichmuller dimensions
# ---------------------------------------------------------------------------

def moduli_dim(g: int) -> int:
    """Dimension of M_g (unmarked): 3g - 3."""
    return 3 * g - 3


def moduli_dim_marked(g: int, n: int) -> int:
    """Dimension of M_{g,n}: 3g - 3 + n."""
    return 3 * g - 3 + n


def teich_dim(g: int) -> int:
    """Real Teichmuller dimension of a genus-g surface: 6g - 6."""
    return 6 * g - 6


def holo_diff_dim(g: int) -> int:
    """Dimension of H^0(K_C) via Riemann-Roch: chi(K) + 1 = g."""
    return rr_chi(canonical_deg(g), g) + 1


def is_stable(g: int, n: int) -> bool:
    """Stability of an n-pointed genus-g cake: 2g - 2 + n > 0."""
    return 2 * g - 2 + n > 0


# ---------------------------------------------------------------------------
# The two Riemann-Roch computations of 3g - 3
# ---------------------------------------------------------------------------

def dim_via_deformations(g: int) -> int:
    """h^1(T_C) = -chi(T_C), the space of first-order deformations."""
    return -rr_chi(tangent_deg(g), g)


def dim_via_quadratic(g: int) -> int:
    """h^0(2K_C) = chi(2K_C), the space of quadratic differentials."""
    return rr_chi(2 * canonical_deg(g), g)


# ---------------------------------------------------------------------------
# Inductive recurrence
# ---------------------------------------------------------------------------

def dim_rec(k: int) -> int:
    """Recurrence R(0) = -3, R(k+1) = R(k) + 3; closed form 3k - 3."""
    value = -3
    for _ in range(k):
        value += 3
    return value


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_dimension_table() -> None:
    print("=" * 70)
    print("Moduli dimension dim M_{g,n} = 3g - 3 + n  (marked genus/cherries)")
    print("=" * 70)
    header = "g \\ n |" + "".join(f"{n:5d}" for n in range(6))
    print(header)
    print("-" * len(header))
    for g in range(6):
        row = f"{g:5d} |"
        for n in range(6):
            row += f"{moduli_dim_marked(g, n):5d}"
        print(row)
    print()


def demo_two_riemann_roch() -> None:
    print("=" * 70)
    print("Two independent Riemann-Roch computations of 3g - 3")
    print("(deformations vs quadratic differentials, equal by Serre duality)")
    print("=" * 70)
    print(f"{'g':>3} {'-chi(T_C)':>12} {'chi(2K_C)':>12} {'3g-3':>8} {'agree?':>8}")
    for g in range(2, 8):
        a = dim_via_deformations(g)
        b = dim_via_quadratic(g)
        c = moduli_dim(g)
        print(f"{g:>3} {a:>12} {b:>12} {c:>8} {str(a == b == c):>8}")
    print()


def demo_stability_and_repair() -> None:
    print("=" * 70)
    print("Stability 2g-2+n>0 vs. non-negativity of 3g-3+n")
    print("=" * 70)
    exceptional = []
    for g in range(0, 4):
        for n in range(0, 5):
            stable = is_stable(g, n)
            dim = moduli_dim_marked(g, n)
            if not stable:
                exceptional.append((g, n))
            flag = "" if stable == (dim >= 0) else "  <-- MISMATCH"
            print(f"  (g={g}, n={n}): stable={stable!s:5}  dim={dim:3d}"
                  f"  dim>=0={dim >= 0!s:5}{flag}")
    print()
    print(f"Exceptional (unstable) locus found: {sorted(set(exceptional))}")
    print("Expected finite failure set: [(0, 0), (0, 1), (0, 2), (1, 0)]")
    print()


def demo_triangle() -> None:
    print("=" * 70)
    print("The rigid Euler-Betti-moduli-canonical triangle")
    print("  2*dim M_g = -3*chi = 3*b1 - 6 = 3*deg K = 6g - 6")
    print("=" * 70)
    print(f"{'g':>3} {'2*M(g)':>8} {'-3*chi':>8} {'3*b1-6':>8} "
          f"{'3*degK':>8} {'6g-6':>8}")
    for g in range(2, 8):
        a = 2 * moduli_dim(g)
        b = -3 * euler_char(g)
        c = 3 * first_betti(g) - 6
        d = 3 * canonical_deg(g)
        e = teich_dim(g)
        print(f"{g:>3} {a:>8} {b:>8} {c:>8} {d:>8} {e:>8}")
        assert a == b == c == d == e
    print("All five columns agree for every genus.\n")


def demo_recurrence_and_enumeration() -> None:
    print("=" * 70)
    print("Inductive recurrence and enumeration check for g <= 5")
    print("=" * 70)
    for g in range(0, 6):
        rec = dim_rec(g)
        closed = moduli_dim(g)
        print(f"  g={g}: R(g)={rec:3d}  3g-3={closed:3d}  match={rec == closed}")
    print()
    enumerated = [moduli_dim(g) for g in (2, 3, 4, 5)]
    print(f"Moduli dimensions for g=2,3,4,5: {enumerated}")
    print("Expected arithmetic progression: [3, 6, 9, 12] (step +3 per handle)")
    assert enumerated == [3, 6, 9, 12]
    print()


def demo_recovery() -> None:
    print("=" * 70)
    print("Fundamental Theorem (recovery half): invariants from dimension")
    print("=" * 70)
    print("Genus recovered from unmarked moduli dimension (strictly increasing):")
    dims = {g: moduli_dim(g) for g in range(2, 8)}
    print(f"  {dims}")
    assert len(set(dims.values())) == len(dims)  # injective
    print("  -> map g |-> 3g-3 is injective; genus is recovered.\n")


def main() -> None:
    demo_dimension_table()
    demo_two_riemann_roch()
    demo_stability_and_repair()
    demo_triangle()
    demo_recurrence_and_enumeration()
    demo_recovery()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
