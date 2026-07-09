from typing import List

Matrix = List[List[int]]


def shift_of(a: Matrix) -> int:
    """Largest k with Shift k a, i.e. a[i][j] = 0 whenever j < i + k.

    For the zero matrix this returns n (the top filtration level); for a
    nonzero matrix it equals min{ j - i : a[i][j] != 0 }. By Shift.mul the
    shift of a product is at least the sum of the shifts, and by
    Shift.eq_zero_of_top a matrix of shift n over Fin n is the zero matrix.
    Complexity O(n^2).
    """
    n = len(a)
    best = n
    for i in range(n):
        for j in range(n):
            if a[i][j] != 0:
                best = min(best, j - i)
    return best
