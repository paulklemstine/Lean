from typing import List

def cover_table(max_N: int, max_d: int) -> List[List[int]]:
    """Fill C(N, d) by the one-point recurrence C(N+1,d+1)=C(N,d+1)+C(N,d)."""
    T = [[0] * (max_d + 1) for _ in range(max_N + 1)]
    for d in range(1, max_d + 1):
        T[1][d] = 2
    for N in range(1, max_N + 1):
        T[N][1] = 2
    for N in range(1, max_N):
        for d in range(1, max_d):
            T[N + 1][d + 1] = T[N][d + 1] + T[N][d]
    return T
