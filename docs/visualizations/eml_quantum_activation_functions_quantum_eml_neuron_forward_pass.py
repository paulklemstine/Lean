def quantum_eml_forward(w1, b1, w2, b2, x):
    import numpy as np
    phase = w1 * x + b1
    logScale = w2 * x + b2
    quantum_out = np.exp(1j * phase)
    classical_out = np.exp(phase) - logScale
    return quantum_out, classical_out