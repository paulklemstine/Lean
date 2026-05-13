import numpy as np

def tropical_adjoint(H, F):
    """Tropical adjoint reconstruction (inf-minus convention).
    
    Args:
        H: list of arrays (measurement directions)
        F: array (measurement data)
    Returns:
        array (reconstructed signal)
    """
    n = len(H[0])
    result = np.full(n, np.inf)
    for i, h in enumerate(H):
        result = np.minimum(result, F[i] - h)
    return result

# Example
H = [np.array([1, 0, -1]), np.array([0, 2, 1]), np.array([-1, -1, 3])]
F = np.array([3, 3, 3])
print(f"Adjoint({F}) = {tropical_adjoint(H, F)}")
