def ihara_determinant(A, q, u):
    n = A.shape[0]
    I = np.eye(n)
    H = (1 + (q-1)*u**2)*I - u*A
    return np.linalg.det(H)