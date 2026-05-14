# See algorithms.py for full implementation
import numpy as np

def tropical_primal_value(s, d):
    per_b = np.max(s[:, np.newaxis] - d, axis=0)
    return np.min(per_b)

# Example
s = np.array([4.0, 1.0, 3.0])
d = np.array([[0.0, 1.0], [1.0, 0.0], [0.5, 0.5]])
print(f'Primal value P = {tropical_primal_value(s, d)}')