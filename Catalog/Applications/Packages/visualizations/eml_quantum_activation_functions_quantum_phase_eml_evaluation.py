def quantum_phase_eml(theta, x, y):
    return np.exp(1j * theta) * (np.exp(x) - np.log(y))