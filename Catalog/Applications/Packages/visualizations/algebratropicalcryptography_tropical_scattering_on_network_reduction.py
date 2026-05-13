import numpy as np

def is_essential(A, B, v):
    m, k = A.shape
    _, n = B.shape
    for i in range(m):
        for j in range(n):
            pw_v = A[i, v] + B[v, j]
            if all(pw_v < A[i, w] + B[w, j] for w in range(k) if w != v):
                return True
    return False

def reduce_network(A, B):
    while A.shape[1] > 1:
        found = False
        for v in range(A.shape[1]):
            if not is_essential(A, B, v):
                mask = [w for w in range(A.shape[1]) if w != v]
                A, B = A[:, mask], B[mask, :]
                found = True
                break
        if not found:
            break
    return A, B

A = np.array([[0, 1, 0], [1, 0, 1]])
B = np.array([[0, 5], [5, 0], [3, 3]])
print(f'Before: k={A.shape[1]}')
A2, B2 = reduce_network(A, B)
print(f'After: k={A2.shape[1]}')