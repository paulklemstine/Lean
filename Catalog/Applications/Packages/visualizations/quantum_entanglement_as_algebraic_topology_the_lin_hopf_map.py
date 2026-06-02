import numpy as np
def hopf_map(z1: complex, z2: complex) -> np.ndarray:
    w = z1 * np.conj(z2)
    return np.array([2*w.real, 2*w.imag, abs(z1)**2 - abs(z2)**2])