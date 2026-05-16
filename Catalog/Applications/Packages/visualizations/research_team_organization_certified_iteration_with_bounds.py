import numpy as np

def tropical_mat_map(A, x):
    return np.max(A + x[np.newaxis, :], axis=1)

def certified_iteration(A, x, k):
    """Iterate with post-fixed point certificate."""
    Tx = tropical_mat_map(A, x)
    is_postfixed = bool(np.all(x <= Tx + 1e-12))
    v = x.copy()
    for _ in range(k):
        v = tropical_mat_map(A, v)
    cert = {
        "postfixed": is_postfixed,
        "lower_bound_holds": is_postfixed and bool(np.all(x <= v + 1e-12)),
    }
    return v, cert

A = np.array([[0.5, 0.2], [0.3, 0.4]])
x = np.array([1.0, 2.0])
result, cert = certified_iteration(A, x, 10)
print(f"Result: {result}")
print(f"Certificate: {cert}")
