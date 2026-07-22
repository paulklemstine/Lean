import numpy as np
from scipy.linalg import null_space

def chain_complex_to_css(d2: np.ndarray, d1: np.ndarray) -> dict:
    """Convert a 3-term chain complex to a CSS code."""
    assert np.allclose(d1 @ d2, 0), 'Chain condition violated'
    n = d1.shape[1]
    # C_X = ker(d1)
    cx_basis = null_space(d1)
    dim_cx = cx_basis.shape[1]
    # C_Z = im(d2) = column space of d2
    dim_cz = int(np.linalg.matrix_rank(d2))
    k = dim_cx - dim_cz  # logical qubits = β₁
    return {'n': n, 'k': k, 'dim_CX': dim_cx, 'dim_CZ': dim_cz}

# Example: square graph
d1 = np.array([[-1,-1,0,0],[1,0,-1,0],[0,1,0,-1],[0,0,1,1]], dtype=float)
d2 = np.zeros((4, 0), dtype=float)
result = chain_complex_to_css(d2, d1)
print(f'CSS code: n={result["n"]}, k={result["k"]} logical qubits')