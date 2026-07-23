from __future__ import annotations


def pipeline_exponents(stages: list[tuple[float, float]]) -> tuple[float, float]:
    """Multiplicativity of Holder exponents under composition.
    Each stage is (r_forward, r_inverse). Returns (R_forward, R_inverse)."""
    r_fwd, r_inv = 1.0, 1.0
    for rf, ri in stages:
        r_fwd *= rf
        r_inv *= ri
    return r_fwd, r_inv


def dimension_envelope(base_dim: float,
                       stages: list[tuple[float, float]]) -> tuple[float, float]:
    """Certified [lo, hi] enclosing dimH of the final image (Theorem 4.2):
        dimH(image) <= base_dim / R_forward
        dimH(image) >= base_dim * R_inverse
    """
    r_fwd, r_inv = pipeline_exponents(stages)
    return base_dim * r_inv, base_dim / r_fwd
