import numpy as np

def compute_depth(M):
    n = M.shape[0]
    dp = [0] * n
    pred = [-1] * n
    for j in range(n):
        for i in range(j):
            if M[i, j] > 0 and dp[i] + 1 > dp[j]:
                dp[j] = dp[i] + 1
                pred[j] = i
    depth = max(dp) if n > 0 else 0
    end = dp.index(depth) if depth > 0 else 0
    path = []
    v = end
    while v != -1:
        path.append(v)
        v = pred[v]
    path.reverse()
    return depth, path

# Example
M = np.array([[0,3,0,7],[0,0,2,0],[0,0,0,4],[0,0,0,0]])
d, p = compute_depth(M)
print(f"Depth: {d}, Path: {p}")
