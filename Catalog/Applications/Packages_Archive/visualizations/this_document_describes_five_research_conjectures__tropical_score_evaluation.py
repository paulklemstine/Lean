def tropical_matmul(A, x):
    return [max(A[i][j] + x[j] for j in range(len(x))) for i in range(len(A))]

def tropical_score(W1, W2, x):
    return tropical_matmul(W2, tropical_matmul(W1, x))

def tropical_lipschitz(W1, W2):
    n, d, m = len(W1), len(W1[0]), len(W2)
    C = [[max(W2[i][k] + W1[k][j] for k in range(n)) for j in range(d)] for i in range(m)]
    return max(max(row) for row in C)

W1 = [[0.5, -0.2, 0.8], [-0.1, 0.6, 0.3], [0.4, 0.4, -0.5], [0.2, -0.3, 0.7]]
W2 = [[0.3, -0.1, 0.5, 0.2], [-0.2, 0.4, 0.1, 0.6], [0.1, 0.3, -0.2, 0.4]]
x = [1.0, 0.5, -0.3]
print(f"Scores: {tropical_score(W1, W2, x)}")
print(f"Lipschitz K: {tropical_lipschitz(W1, W2)}")
