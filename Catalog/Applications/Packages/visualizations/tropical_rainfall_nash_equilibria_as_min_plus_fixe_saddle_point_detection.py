import numpy as np

def find_saddle_points(A):
    n = A.shape[0]
    row_mins = np.min(A, axis=1)
    col_maxs = np.max(A, axis=0)
    saddles = []
    for i in range(n):
        for j in range(n):
            if A[i,j] == row_mins[i] and A[i,j] == col_maxs[j]:
                saddles.append((i,j))
    return saddles

# Example with saddle point
A = np.array([[3, 5, 7], [1, 4, 6], [2, 3, 8]], dtype=float)
print('Matrix:', A)
print('Saddle points:', find_saddle_points(A))
print('Lower value:', np.max(np.min(A, axis=1)))
print('Upper value:', np.min(np.max(A, axis=0)))