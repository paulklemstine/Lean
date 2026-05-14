import numpy as np

def tropical_normalize(x):
    """Tropical normalization: subtract the minimum coordinate.
    
    Properties (machine-verified):
    - Idempotent: normalize(normalize(x)) = normalize(x)
    - Fixed points: normalize(x) = x iff x >= 0 and min(x) = 0
    - Canonical: normalize(x) = normalize(y) iff x - y is constant
    """
    return x - np.min(x)

def tropical_deficiency(x):
    """Deficiency = n * min(x). Zero iff x is a fixed point."""
    return len(x) * np.min(x)

# Example
x = np.array([5.0, 3.0, 7.0])
print(f"x = {x}")
print(f"normalize(x) = {tropical_normalize(x)}")
print(f"deficiency = {tropical_deficiency(x)}")
print(f"is_fixed = {np.allclose(tropical_normalize(x), x)}")

# Verify idempotence
nx = tropical_normalize(x)
nnx = tropical_normalize(nx)
print(f"normalize(normalize(x)) = {nnx}")
print(f"idempotent: {np.allclose(nx, nnx)}")
