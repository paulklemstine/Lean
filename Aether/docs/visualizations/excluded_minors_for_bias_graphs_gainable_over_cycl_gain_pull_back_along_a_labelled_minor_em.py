from typing import List, Sequence, Tuple

Walk = List[Tuple[int, bool]]

def pull_back_labelling(phi: Sequence[int], sigma: Sequence[bool],
                        g: Sequence[int], p: int) -> Tuple[int, ...]:
    """
    Pull a realising labelling g on graph G back along a labelled-minor embedding
    (phi, sigma) of H into G, producing a realising labelling on H.

    For each edge e of H: g'(e) = (-g[phi[e]]) mod p if sigma[e] else g[phi[e]] mod p.
    By the pull-back identity, signed sums (hence balance) are preserved, so g'
    realises H whenever g realises G. Complexity: O(|E(H)|).
    """
    return tuple((-g[phi[e]]) % p if sigma[e] else g[phi[e]] % p
                 for e in range(len(phi)))

def signed_sum(g: Sequence[int], c: Walk, p: int) -> int:
    """Signed sum of oriented walk c under labelling g in Z/p."""
    return sum(g[e] if fwd else -g[e] for (e, fwd) in c) % p
