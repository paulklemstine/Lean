from __future__ import annotations


def gsd(d: int, g: int) -> int:
    """Ground-state degeneracy on a genus-g surface for d=|A| anyon types.

    Returns d**g via Python's built-in fast exponentiation (O(log g) bigint
    multiplications).
    """
    if d < 1 or g < 0:
        raise ValueError("require d >= 1 and g >= 0")
    return d ** g


def verify_laws(d: int, gmax: int = 6) -> bool:
    """Verify handle recursion, connected sum, and torus value up to genus gmax."""
    handle = all(gsd(d, g + 1) == d * gsd(d, g) for g in range(gmax))
    csum = all(gsd(d, g + h) == gsd(d, g) * gsd(d, h)
               for g in range(gmax) for h in range(gmax))
    torus = gsd(d, 1) == d
    return handle and csum and torus
