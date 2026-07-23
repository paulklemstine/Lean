from typing import List, Tuple

def whitehead_via_smith_normal_form(divisors: List[int]) -> Tuple[bool, List[int]]:
    """Decide whether a finitely generated abelian group is a Whitehead group.

    Input: the invariant factors d_1 | d_2 | ... | d_k from the Smith normal form
    of a presentation matrix, where d_i = 0 encodes a free Z summand and d_i = 1
    encodes a trivial summand.

    Mathematical foundation: Theorems 1 and 3. A finitely generated group
    decomposes as a sum of Z/d_i. It is Whitehead (equivalently free) iff it has
    no genuine torsion, i.e. every d_i is 0 or 1. Each d_i >= 2 yields a cyclic
    summand Z/d_i, which carries an explicit non-split extension (Theorem 3) and
    obstructs the Whitehead property.

    Complexity: O(k) given the invariant factors.

    Returns (is_whitehead, obstructing_divisors).
    """
    obstructions = [d for d in divisors if d >= 2]
    return (len(obstructions) == 0, obstructions)
