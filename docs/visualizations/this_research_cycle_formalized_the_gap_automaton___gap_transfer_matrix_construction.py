def gap_transfer_matrix(modulus, admissible, alphabet):
    T = np.zeros((modulus, modulus))
    for s in range(modulus):
        if s not in admissible: continue
        for g in alphabet:
            t = (s + g) % modulus
            if t in admissible: T[s][t] += 1.0
    return T