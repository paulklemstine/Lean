# See algorithms.py for full implementation
import numpy as np

def min_plus_closure(A):
    n = A.shape[0]
    result = A.copy()
    for i in range(n):
        result[i,i] = min(result[i,i], 0.0)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                result[i,j] = min(result[i,j], result[i,k] + result[k,j])
    return result

# Example
A = np.array([[0, 1, 10], [10, 0, 1], [1, 10, 0]], dtype=float)
print('Original:', A)
print('Closure:', min_plus_closure(A))