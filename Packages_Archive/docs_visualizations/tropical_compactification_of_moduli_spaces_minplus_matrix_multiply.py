def minplus_matmul(A: list[list[float]], B: list[list[float]]) -> list[list[float]]:
    n = len(A)
    C = [[float('inf')]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i][k] + B[k][j]
                if val < C[i][j]:
                    C[i][j] = val
    return C