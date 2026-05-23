import numpy as np

def tropical_to_game(A, B):
    p, n = A.shape
    print(f"Constructing game: {n} Max + {p} Min vertices, {2*n*p} edges")
    edges = []
    for i in range(n):
        for j in range(p):
            edges.append((f"Max(x_{i})", f"Min(C_{j})", -A[j][i]))
    for j in range(p):
        for k in range(n):
            edges.append((f"Min(C_{j})", f"Max(x_{k})", B[j][k]))
    for src, tgt, w in edges:
        print(f"  {src} -> {tgt}, weight = {w:.1f}")
    return edges

A = np.array([[2.0, 0.0], [0.0, 1.0]])
B = np.array([[0.0, 3.0], [2.0, 0.0]])
tropical_to_game(A, B)