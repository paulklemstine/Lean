def gf2_circulant_rank(first_row, n):
    row = (first_row + [0]*n)[:n]
    m = [row[-i:] + row[:-i] for i in range(n)]
    rank = 0
    for col in range(n):
        pivot = next((r for r in range(rank, n) if m[r][col]), None)
        if pivot is None: continue
        m[rank], m[pivot] = m[pivot], m[rank]
        for r in range(n):
            if r != rank and m[r][col]:
                m[r] = [m[r][j] ^ m[rank][j] for j in range(n)]
        rank += 1
    return rank