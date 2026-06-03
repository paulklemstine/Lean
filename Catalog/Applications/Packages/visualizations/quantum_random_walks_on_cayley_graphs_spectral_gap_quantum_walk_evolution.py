import numpy as np
def quantum_walk_evolution(H, psi0, t):
    evals, evecs = np.linalg.eigh(H)
    phases = np.exp(-1j * evals * t)
    U = evecs @ np.diag(phases) @ evecs.conj().T
    return U @ psi0