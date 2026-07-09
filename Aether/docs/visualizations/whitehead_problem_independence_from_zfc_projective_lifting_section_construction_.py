from typing import Callable, List

def projective_splitting_section(
    r: int,
    p: Callable[[List[int]], List[int]],
    lift: Callable[[List[int]], List[int]],
) -> Callable[[List[int]], List[int]]:
    """Construct a Z-linear section s : Z^r -> G of a surjection p : G -> Z^r.

    Mathematical foundation: Theorem 1 (projective => Whitehead). Z^r is free,
    hence projective, hence every surjection onto it splits. The section is built
    by choosing a preimage g_i = lift(e_i) of each standard basis vector e_i
    (p(g_i) = e_i) and extending linearly: s(a) = sum_i a_i * g_i.

    Complexity: O(r * dim G) per evaluation; O(r * dim G) precomputation for the
    r basis lifts.
    """
    basis = [lift([1 if j == i else 0 for j in range(r)]) for i in range(r)]
    dim = len(basis[0])

    def s(a: List[int]) -> List[int]:
        out = [0] * dim
        for i, c in enumerate(a):
            for k in range(dim):
                out[k] += c * basis[i][k]
        return out
    return s
