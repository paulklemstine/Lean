def verify_spectral_gap(x):
    import numpy as np
    assert x > 0, 'x must be positive'
    val = np.exp(x) - np.log(x)
    gap = val - 2.0
    assert gap > 0, f'Gap violated at x={x}'
    return val, gap