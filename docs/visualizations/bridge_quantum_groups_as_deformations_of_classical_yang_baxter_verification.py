def verify_yang_baxter(q: float):
    R = r_matrix(q)
    I2 = np.eye(2)
    R12 = np.kron(R, I2)
    R23 = np.kron(I2, R)
    P = np.zeros((8, 8))
    for a in range(2):
        for b in range(2):
            for c in range(2):
                P[a*4+b*2+c, a*4+c*2+b] = 1
    R13 = P @ R23 @ P
    err = np.linalg.norm(R12@R13@R23 - R23@R13@R12)
    return err, err < 1e-10