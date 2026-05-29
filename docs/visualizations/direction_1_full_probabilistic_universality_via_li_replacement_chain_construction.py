import numpy as np

def tropical_margin(W):
    n = W.shape[0]
    if n < 2: return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))

def replacement_chain(A, B):
    n = A.shape[0]
    chain = [A.copy()]
    Z = A.copy()
    for k in range(n * n):
        i, j = divmod(k, n)
        Z = Z.copy()
        Z[i, j] = B[i, j]
        chain.append(Z.copy())
    return chain

# Example
rng = np.random.default_rng(42)
A = rng.standard_normal((3, 3))
B = rng.choice([-1.0, 1.0], size=(3, 3))
chain = replacement_chain(A, B)
margins = [tropical_margin(Z) for Z in chain]
total = abs(margins[0] - margins[-1])
steps = sum(abs(margins[k] - margins[k+1]) for k in range(len(margins)-1))
print(f"Telescoping: |total| = {total:.4f} <= sum = {steps:.4f}: {total <= steps + 1e-10}")
