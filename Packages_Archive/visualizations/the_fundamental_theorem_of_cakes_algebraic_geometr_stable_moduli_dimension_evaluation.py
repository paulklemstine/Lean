from __future__ import annotations


def moduli_dimension(g: int, n: int) -> int:
    """Return dim M_{g,n} = 3g - 3 + n, the dimension of the moduli space of
    n-pointed genus-g surfaces. Raises ValueError on the unstable locus."""
    if 2 * g - 2 + n <= 0:
        raise ValueError(f"unstable flavour (g={g}, n={n}): 2g-2+n <= 0")
    return 3 * g - 3 + n
