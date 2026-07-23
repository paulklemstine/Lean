from typing import Callable, Dict, List, Hashable

Atom = Hashable


def translate_derivation(
    derivation: List[Atom],
    vmap: Callable[[Atom], Atom],
    realize: Callable[[Atom, Atom], List[Atom]],
) -> List[Atom]:
    """Algorithm B (translate_deriv, Theorem 4.1).

    `derivation` is a source chain a = x0 -> x1 -> ... -> xk = b.
    `vmap` is the atom map; `realize(a, b)` returns a target derivation
    [vmap(a), ..., vmap(b)] of length <= stretch for each source axiom a->b.
    The concatenation has length <= stretch * k (holographic propagation)."""
    out: List[Atom] = [vmap(derivation[0])]
    for a, b in zip(derivation, derivation[1:]):
        piece = realize(a, b)          # vmap(a) -> ... -> vmap(b), len <= stretch
        out.extend(piece[1:])          # concatenate, dropping the shared endpoint
    return out
