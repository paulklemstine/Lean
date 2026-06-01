def diagonal_argument(encoding, n):
    return lambda x: not encoding(x)(x) if x < n else False