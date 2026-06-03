def purity(rho):
    import numpy as np
    return float(np.real(np.trace(rho @ rho)))