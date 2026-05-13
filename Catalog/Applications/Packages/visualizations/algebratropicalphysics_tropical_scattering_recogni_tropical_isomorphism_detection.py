def find_isomorphism(M1, M2):
    # Sort generators lexicographically, compare sorted weight matrices
    perm1 = sorted(range(M1.n), key=lambda i: tuple(M1.weight[:, i]))
    perm2 = sorted(range(M2.n), key=lambda i: tuple(M2.weight[:, i]))
    if np.allclose(M1.weight[:, perm1], M2.weight[:, perm2]):
        sigma = np.zeros(M1.n, dtype=int)
        for k in range(M1.n): sigma[perm1[k]] = perm2[k]
        return sigma
    return None