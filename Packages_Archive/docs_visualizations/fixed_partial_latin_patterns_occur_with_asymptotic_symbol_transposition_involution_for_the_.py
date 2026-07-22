from typing import Dict, List, Tuple

Square = Tuple[Tuple[int, ...], ...]


def swap_perm(n: int, s: int, t: int) -> Dict[int, int]:
    """The transposition exchanging symbols s and t (Equiv.swap s t)."""
    sigma = {x: x for x in range(n)}
    sigma[s], sigma[t] = t, s
    return sigma


def relabel(L: Square, sigma: Dict[int, int]) -> Square:
    """Apply a symbol permutation to every entry (permAct sigma L)."""
    return tuple(tuple(sigma[x] for x in row) for row in L)


def fiber_bijection(fiber_s: List[Square], n: int, r: int, c: int,
                    s: int, t: int) -> List[Square]:
    """Map F_s onto F_t by the involution tau = swap(s,t); tau . (tau . L) = L."""
    tau = swap_perm(n, s, t)
    image = [relabel(L, tau) for L in fiber_s]
    # involution check: applying tau twice is the identity
    assert all(relabel(M, tau) == L for L, M in zip(fiber_s, image))
    assert all(M[r][c] == t for M in image)  # lands in F_t
    return image
