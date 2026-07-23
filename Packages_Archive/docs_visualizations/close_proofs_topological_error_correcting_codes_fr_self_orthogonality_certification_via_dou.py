from typing import List, Tuple

Word = Tuple[int, ...]

def is_doubly_even(v: Word) -> bool:
    return sum(v) % 4 == 0

def certify_self_orthogonal(code: List[Word]) -> bool:
    """Certify a linear code is self-orthogonal in O(|C|*n) via the bridge theorem.

    Correctness (Corollary 5.3): a binary *linear* code all of whose weights are
    divisible by 4 is self-orthogonal. We therefore avoid the naive O(|C|^2 * n)
    pairwise inner-product audit and check only one weight per codeword.
    """
    return all(is_doubly_even(c) for c in code)
