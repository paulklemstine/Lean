def qeml_layer(phases, couplings, weights, x=1.0):
    import numpy as np
    return sum(w * np.exp(1j * p) * np.log(1 + 1j * c * x)
               for p, c, w in zip(phases, couplings, weights))