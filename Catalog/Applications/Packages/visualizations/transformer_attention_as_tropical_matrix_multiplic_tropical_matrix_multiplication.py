import numpy as np

def tropical_matrix_multiply(X, Y):
    """Max-plus tropical matrix product."""
    return np.max(X[:, :, np.newaxis] + Y[np.newaxis, :, :], axis=1)

# Example
X = np.array([[1.0, 2.0], [3.0, 0.0]])
Y = np.array([[0.0, 1.0], [2.0, 0.0]])
print('X ⊙ Y =')
print(tropical_matrix_multiply(X, Y))