from typing import List

Matrix = List[List[int]]


def direct_sum(a: Matrix, b: Matrix) -> Matrix:
    """Orthogonal block-diagonal direct sum [[A,0],[0,B]].

    Models the intersection form of a connected sum M # N.  The three
    structural predicates (unimodular, even, standard-diagonalizable) are each
    closed under this operation, so the E8 obstruction is stable: E8 (+) E8 is
    still even, unimodular, and non-standard.
    """
    n, p = len(a), len(b)
    top = [list(a[i]) + [0] * p for i in range(n)]
    bot = [[0] * n + list(b[i]) for i in range(p)]
    return top + bot
