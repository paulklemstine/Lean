from typing import List

def region_bound_table(M: int, N: int) -> List[List[int]]:
    """Table R[m][n] = regionBound(m, n) for 0<=m<=M, 0<=n<=N by the
    Pascal recurrence R(m+1,n+1) = R(m,n+1) + R(m,n), base R(0,n)=1.

    Dynamic programming in O(M*N) time and space; certifies the recurrence.
    """
    R: List[List[int]] = [[0] * (N + 1) for _ in range(M + 1)]
    for n in range(N + 1):
        R[0][n] = 1                      # one region with zero hyperplanes
    for m in range(1, M + 1):
        R[m][0] = 1                      # C(m,0) only
        for n in range(1, N + 1):
            R[m][n] = R[m - 1][n] + R[m - 1][n - 1]
    return R
