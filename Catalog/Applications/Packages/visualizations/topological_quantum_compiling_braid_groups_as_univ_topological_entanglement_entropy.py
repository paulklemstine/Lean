import numpy as np
def topological_entropy(quantum_dims: list) -> float:
    D_sq = sum(d**2 for d in quantum_dims)
    return 0.5 * np.log(D_sq)