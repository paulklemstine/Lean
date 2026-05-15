import numpy as np

def extract_potentials(A, i0=0, j0=0):
    u = A[:, j0].copy()
    v = A[i0, :] - A[i0, j0]
    return u, v

# Example
A = np.array([[3, 0, 5], [5, 2, 7], [0, -3, 2], [7, 4, 9]], dtype=float)
u, v = extract_potentials(A)
print(f"u = {u}")
print(f"v = {v}")
print(f"Reconstruction matches: {np.allclose(A, u[:,None] + v[None,:])}")