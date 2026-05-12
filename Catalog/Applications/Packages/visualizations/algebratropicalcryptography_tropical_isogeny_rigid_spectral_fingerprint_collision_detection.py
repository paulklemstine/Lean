def check_collision(oracle_A, oracle_B, g, M):
    import numpy as np
    def recover(oracle):
        A = np.zeros((g, g))
        for j in range(g):
            v = np.full(g, float(M)); v[j] = 0
            A[:, j] = oracle(v)
        return A
    return np.array_equal(recover(oracle_A), recover(oracle_B))