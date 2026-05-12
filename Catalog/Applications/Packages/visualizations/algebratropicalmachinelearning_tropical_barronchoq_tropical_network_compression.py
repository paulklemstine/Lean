import numpy as np

def tropical_compress(weights, eval_matrix):
    """Compress a tropical network by removing dominated units.
    
    Args:
        weights: array of shape (n_units,)
        eval_matrix: array of shape (n_units, n_inputs)
    
    Returns:
        active_indices: list of surviving unit indices
    """
    active = list(range(len(weights)))
    changed = True
    while changed:
        changed = False
        for idx, i in enumerate(active):
            for j in active:
                if j == i:
                    continue
                # Check pointwise domination via random sampling
                dominated = True
                for _ in range(500):
                    f = np.random.randn(eval_matrix.shape[1])
                    ci = weights[i] + eval_matrix[i] @ f
                    cj = weights[j] + eval_matrix[j] @ f
                    if ci > cj + 1e-10:
                        dominated = False
                        break
                if dominated:
                    active.pop(idx)
                    changed = True
                    break
            if changed:
                break
    return active

# Example
weights = np.array([2.0, 1.0, 1.0])  # Unit 2 dominated by unit 0
evals = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, 0.0]])
evals[2] = evals[0]  # Same evaluation as unit 0
weights[2] = weights[0] - 1  # Lower weight => dominated

result = tropical_compress(weights, evals)
print(f"Active units: {result}")  # Should exclude unit 2
