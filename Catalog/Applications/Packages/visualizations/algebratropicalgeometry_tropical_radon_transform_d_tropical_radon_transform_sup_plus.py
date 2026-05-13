import numpy as np

def tropical_radon_transform(H, f):
    """Tropical Radon transform (sup-plus convention).
    
    Args:
        H: list of arrays (measurement directions)
        f: array (signal)
    Returns:
        array of Radon values
    """
    return np.array([np.max(f + h) for h in H])

# Example
H = [np.array([1, 0, -1]), np.array([0, 2, 1]), np.array([-1, -1, 3])]
f = np.array([2, 1, 0])
print(f"Radon({f}) = {tropical_radon_transform(H, f)}")
