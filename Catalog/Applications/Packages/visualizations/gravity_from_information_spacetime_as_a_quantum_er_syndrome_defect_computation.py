def syndrome_defect(S, X, Y):
    return S[X] + S[Y] - S[X & Y] - S[X | Y]