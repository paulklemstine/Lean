def overflow_function(membership, N, max_depth):
    return [max((n for n in range(max_depth) if membership(i, n)), default=0) for i in range(N)]