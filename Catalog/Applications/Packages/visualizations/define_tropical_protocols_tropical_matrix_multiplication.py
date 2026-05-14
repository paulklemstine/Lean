INF = float('inf')

def tropical_matmul(A, B):
    n, p, m = len(A), len(B), len(B[0])
    return [[min(A[i][k] + B[k][j] for k in range(p)) for j in range(m)] for i in range(n)]

def tropical_matpow(M, k):
    n = len(M)
    result = [[0 if i==j else INF for j in range(n)] for i in range(n)]
    base = [row[:] for row in M]
    while k > 0:
        if k % 2 == 1: result = tropical_matmul(result, base)
        base = tropical_matmul(base, base)
        k //= 2
    return result

# Shortest paths via matrix power
M = [[0, 2, INF], [INF, 0, 1], [3, INF, 0]]
print("Distance matrix M:")
for row in M: print([x if x != INF else '∞' for x in row])
M2 = tropical_matpow(M, 2)
print("\n2-step shortest paths M²:")
for row in M2: print([x if x != INF else '∞' for x in row])
