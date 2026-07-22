from __future__ import annotations
# Assumes the Ordinal class of the ordinal-arithmetic algorithm is in scope.

OMEGA = None  # set to Ordinal.omega_pow(1) at call site


def refine_value(value: "Ordinal", omega: "Ordinal") -> "Ordinal":
    """omega-refinement multiplies the survival value by omega:
        value(R(G)) = omega * value(G)."""
    return omega * value


def refine_iterated(base: "Ordinal", omega: "Ordinal", k: int) -> "Ordinal":
    """Apply the omega-refinement k times.  Starting from the finite game
    (value omega) this yields omega^(k+1)."""
    v = base
    for _ in range(k):
        v = omega * v
    return v
