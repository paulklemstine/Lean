def inverse_quantum_eml(w):
    if w == 0: return 0.0, 0.0, np.e
    return np.angle(w), 0.0, np.exp(1 - abs(w))