def bls_verify(g: int, X: int, H: int, sigma: int) -> bool:
    '''Accept iff e(sigma, g) == e(H, X).'''
    return e(sigma, g) == e(H, X)
