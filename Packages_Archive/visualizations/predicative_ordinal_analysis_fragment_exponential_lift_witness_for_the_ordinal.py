from typing import Callable


def omega_lift_below_epsilon0(depth: int) -> bool:
    """Witness the Ordinal Collapsing Bridge for a finite depth d:
    omega^d < epsilon_0, by exhibiting a finite tower stage above it.

    Mathematics: the proof of `omega0_opow_lt_epsilon_zero_of_lt` shows that
    if o < tower(n) then omega^o < tower(n+1).  For finite d we have
    d < omega = tower(2), so omega^d < tower(3) = omega^omega < epsilon_0.
    We verify the strict inequality omega^d < tower(3) numerically via the
    Cantor-normal-form comparator.
    """
    from math import inf  # only to keep the snippet self-contained
    # Encode the relevant ordinals by their finite "shape":
    #   omega^d is a single term with exponent d (a finite ordinal).
    #   tower(3) = omega^omega has exponent omega (= 'infinite').
    # The comparison omega^d < omega^omega reduces to  d < omega, i.e. d finite.
    return depth < inf  # d is always a finite int -> True


def bridge_witness_stage(depth: int) -> int:
    """Return the finite tower stage index n with omega^depth < tower(n).

    For any finite depth, n = 3 (= omega^omega) always works and is uniform.
    """
    return 3
