from itertools import combinations
from typing import FrozenSet, Iterator, List


def powerset(ground: FrozenSet[int]) -> Iterator[FrozenSet[int]]:
    """Yield every subset of the ground set as a frozenset."""
    elems: List[int] = sorted(ground)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            yield frozenset(combo)


def partial_twuality_polynomial(ground: FrozenSet[int],
                                feasible: FrozenSet[int]) -> List[int]:
    """Coefficient vector (c_0,...,c_n) with c_k = #{A subset E : |F triangle A| = k}.

    By the spectrum/interpolation theorem this always equals row |E| of
    Pascal's triangle, i.e. the binomial coefficients C(|E|, k).
    """
    n: int = len(ground)
    coeffs: List[int] = [0] * (n + 1)
    for a in powerset(ground):
        twisted: FrozenSet[int] = feasible ^ a   # symmetric difference F triangle A
        coeffs[len(twisted)] += 1
    return coeffs
