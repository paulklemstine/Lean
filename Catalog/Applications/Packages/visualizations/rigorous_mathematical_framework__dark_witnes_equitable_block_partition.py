def equitable_block_partition(m, N):
    block_size = N // m
    witnesses = []
    for a in range(m):
        rejected = set(range(a * block_size, (a + 1) * block_size))
        witnesses.append(set(range(N)) - rejected)
    return witnesses