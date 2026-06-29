from typing import List

Matrix = List[List[int]]

def is_symmetric(G: Matrix) -> bool:
    n = len(G)
    return all(G[i][j] == G[j][i] for i in range(n) for j in range(n))

def is_even_form(G: Matrix) -> bool:
    """Even-diagonal criterion: symmetric form is even iff diagonal is even."""
    if not is_symmetric(G):
        raise ValueError('form is not symmetric')
    return all(G[i][i] % 2 == 0 for i in range(len(G)))
