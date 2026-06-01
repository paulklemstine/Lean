def cantor_diagonal(enum, size):
    def diagonal(x):
        return not enum(x, x)
    for n in range(size):
        assert diagonal(n) != enum(n, n)
    return diagonal