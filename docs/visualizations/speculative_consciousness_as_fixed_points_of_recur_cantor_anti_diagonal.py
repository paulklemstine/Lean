def cantor_anti_diagonal(encode, n):
    return lambda i: not encode(i, i)