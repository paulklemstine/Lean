import numpy as np

def recover_weights(L_func, eval_matrix, active_indices):
    """Recover tropical network weights from functional values.
    
    Args:
        L_func: callable, the tropical functional
        eval_matrix: evaluation matrix
        active_indices: list of active unit indices
    
    Returns:
        recovered_weights: array of recovered weights
    """
    n = len(active_indices)
    recovered = np.zeros(n)
    
    for idx, i in enumerate(active_indices):
        # Find isolating input by gradient ascent
        f = np.random.randn(eval_matrix.shape[1])
        for _ in range(100):
            margins = []
            for j in active_indices:
                if j == i:
                    continue
                margin = (eval_matrix[i] - eval_matrix[j]) @ f
                margins.append((margin, j))
            if not margins:
                break
            min_margin, j_close = min(margins, key=lambda x: x[0])
            if min_margin > 1.0:
                break
            grad = eval_matrix[i] - eval_matrix[j_close]
            f = f + 0.5 * grad
        
        recovered[idx] = L_func(f) - eval_matrix[i] @ f
    
    return recovered

# Example
weights = np.array([2.0, -1.0, 0.5])
evals = np.array([[3.0, 0.0], [0.0, 3.0], [-1.0, -1.0]])
L = lambda f: max(weights[i] + evals[i] @ f for i in range(3))

recovered = recover_weights(L, evals, [0, 1, 2])
print(f"True weights: {weights}")
print(f"Recovered:    {recovered}")
