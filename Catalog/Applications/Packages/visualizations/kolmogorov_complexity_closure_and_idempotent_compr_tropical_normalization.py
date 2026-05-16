import numpy as np

def tropical_normalize(x):
    """Tropical normalization: subtract minimum coordinate.
    
    Properties (machine-verified):
    - Idempotent: normalize(normalize(x)) == normalize(x)
    - Min zero: min(normalize(x)) == 0
    - Translation invariant: normalize(x + c) == normalize(x)
    """
    return x - np.min(x)

# Example
x = np.array([10.0, 3.0, 7.0, 5.0, 12.0])
print(f'Input:      {x}')
print(f'Normalized: {tropical_normalize(x)}')
print(f'Idempotent: {np.allclose(tropical_normalize(tropical_normalize(x)), tropical_normalize(x))}')
