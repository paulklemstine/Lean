def classical_free_energy(E, beta):
    """F(beta) = -(1/beta) * log sum exp(-beta*E_i)."""
    import numpy as np
    shifted = -beta * E
    max_val = np.max(shifted)
    log_Z = max_val + np.log(np.sum(np.exp(shifted - max_val)))
    return -log_Z / beta