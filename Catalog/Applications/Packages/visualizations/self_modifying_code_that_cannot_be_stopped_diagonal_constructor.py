def construct_diagonal(enum):
    return lambda n: not enum(n, n)