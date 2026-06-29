def e(a: int, b: int) -> int:
    '''Bilinear pairing e(a,b) = GEN^(a*b mod R) mod P.'''
    return pow(GEN, ((a % R) * (b % R)) % R, P)
