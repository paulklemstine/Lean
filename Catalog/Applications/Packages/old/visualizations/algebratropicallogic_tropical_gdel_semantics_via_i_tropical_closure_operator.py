import numpy as np

def diamond_eval(A, v):
    n = A.shape[0]
    return np.array([min(A[x,y] + v[y] for y in range(n)) for x in range(n)])

def tropical_closure(A, v, N):
    """Tropical closure: pointwise min of diamond^k(v) for k=0..N"""
    result = v.copy()
    current = v.copy()
    for k in range(1, N + 1):
        current = diamond_eval(A, current)
        result = np.minimum(result, current)
    return result

# Example: 3-state system
A = np.array([[0,2,5],[5,0,1],[3,5,0]], dtype=float)
v = np.array([10.0, 5.0, 8.0])
for N in range(6):
    c = tropical_closure(A, v, N)
    print(f'N={N}: closure = {c}')
