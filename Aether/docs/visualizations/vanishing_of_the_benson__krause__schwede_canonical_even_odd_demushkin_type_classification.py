from typing import List

Matrix = List[List[int]]


def demushkin_type(gram: Matrix) -> str:
    """Classify a cup-product form as 'even' (alternating) or 'odd'.

    By the type-dichotomy theorem, the form is alternating iff the Kummer class
    vanishes, and over F_2 the Kummer class solves M chi = diag(M); it is zero
    iff diag(M) = 0. Hence the diagonal of the Gram matrix decides the type.
    """
    n = len(gram)
    diagonal_zero: bool = all((gram[i][i] & 1) == 0 for i in range(n))
    return "even" if diagonal_zero else "odd"
