from typing import List, Tuple

BinVec = Tuple[int, ...]


def wt(v: BinVec) -> int:
    return sum(1 for b in v if b == 1)


def vec_add(x: BinVec, y: BinVec) -> BinVec:
    return tuple((a + b) % 2 for a, b in zip(x, y))


def doubly_even(v: BinVec) -> bool:
    return wt(v) % 4 == 0


def certify_self_orthogonal_linear(code: List[BinVec]) -> bool:
    """Certify self-orthogonality in O(|C| * n) via the bridge theorem:
    if the code is closed under addition and every codeword is doubly even,
    then every pair is orthogonal (Theorem 4.1) -- no quadratic pairwise check."""
    distinct = set(code)
    closed = all(vec_add(x, y) in distinct for x in code for y in code)
    all_doubly_even = all(doubly_even(v) for v in code)
    # Closure + double-evenness imply (x+y) doubly even for all pairs, hence
    # ip(x,y) = 0 by the bridge theorem.
    return closed and all_doubly_even
