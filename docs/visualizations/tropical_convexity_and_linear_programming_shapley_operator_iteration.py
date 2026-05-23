import numpy as np

def shapley_operator(A, B, x):
    Bx = np.max(B + x[np.newaxis, :], axis=1)
    return np.min(Bx[:, np.newaxis] - A, axis=0)

def solve_tropical(A, B, x0=None, max_iter=1000):
    p, n = A.shape
    x = np.zeros(n) if x0 is None else x0.copy()
    for it in range(max_iter):
        Tx = shapley_operator(A, B, x)
        if np.all(x <= Tx + 1e-10): return x, True, it
        x = 0.5 * x + 0.5 * Tx
    return None, False, max_iter

# Example
A = np.array([[1.0, 0.0]])
B = np.array([[0.0, 2.0]])
sol, ok, iters = solve_tropical(A, B)
print(f"Feasible: {ok}, solution: {sol}, iterations: {iters}")
print(f"T(x) = {shapley_operator(A, B, sol)}")
print(f"x <= T(x): {np.all(sol <= shapley_operator(A, B, sol) + 1e-9)}")