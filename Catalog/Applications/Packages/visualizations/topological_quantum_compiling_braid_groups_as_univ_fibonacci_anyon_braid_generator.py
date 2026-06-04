import numpy as np
def braid_generator(strand: int) -> np.ndarray:
    phi = (1 + np.sqrt(5)) / 2
    F = np.array([[1/phi, 1/np.sqrt(phi)], [1/np.sqrt(phi), -1/phi]])
    R = np.diag([np.exp(-4j*np.pi/5), np.exp(3j*np.pi/5)])
    if strand == 0: return R
    return F @ R @ F