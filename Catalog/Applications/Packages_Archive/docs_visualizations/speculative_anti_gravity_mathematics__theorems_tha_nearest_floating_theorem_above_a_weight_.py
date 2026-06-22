from __future__ import annotations


def prime_witness(p: int) -> int:
    """primeWitness p = 2 ** p  (OWFStratum.primeWitness): an anti-gravity index."""
    return 2 ** p


def nearest_floating_theorem(w: int) -> int:
    """Smallest anti-gravity dependency index of weight >= w.

    Constructive witness for basic_open_contains_antiGravity / antiGravity_dense:
    returns 2 ** ceil(log2 w), the least power of two that clears the threshold w.
    Runs in O(log w).
    """
    if w <= 1:
        return 1
    p = (w - 1).bit_length()  # ceil(log2 w) for w >= 2
    return prime_witness(p)


def density_certificate(w: int) -> dict:
    """Return a certificate that the basic open Ici(w) meets the anti-gravity set."""
    witness = nearest_floating_theorem(w)
    pc = (witness.bit_length() - 1) if witness > 0 else 0  # log2 for a power of two
    return {
        "threshold": w,
        "witness_depth": witness,
        "weight": witness,
        "proof_complexity": pc,
        "covers_threshold": witness >= w,
        "is_anti_gravity": 2 ** pc == witness,
    }
