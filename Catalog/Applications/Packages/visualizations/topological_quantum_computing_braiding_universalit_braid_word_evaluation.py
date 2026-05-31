def evaluate_braid(word, gen_matrix):
    import numpy as np
    M = np.eye(2, dtype=complex)
    for sign in word:
        M = M @ (gen_matrix if sign > 0 else np.linalg.inv(gen_matrix))
    return M