import numpy as np

def tropical_matmul(W, x):
    return np.max(x[:, None] + W, axis=0)

def tropical_backward(W, y):
    return np.min(y[None, :] - W, axis=1)

def tropical_certificate(weights, z):
    """Compute exact backward certificate for multi-layer tropical network."""
    b = z.copy()
    for W in reversed(weights):
        b = tropical_backward(W, b)
    return b

# Example: 2-layer network
W1 = np.array([[1.0, 2.0], [3.0, 0.0]])
W2 = np.array([[0.0, 1.0], [2.0, 0.0]])
x = np.array([1.0, 0.5])
z = np.array([8.0, 7.0])

# Forward
h = tropical_matmul(W1, x)
out = tropical_matmul(W2, h)
print(f"Forward: x={x.tolist()} -> h={h.tolist()} -> out={out.tolist()}")
print(f"Output <= threshold? {(out <= z).tolist()}")

# Backward certificate
bound = tropical_certificate([W1, W2], z)
print(f"Backward bound: {bound.tolist()}")
print(f"x <= bound? {(x <= bound).tolist()}")
print(f"Galois connection verified: {all(out <= z) == all(x <= bound)}")
