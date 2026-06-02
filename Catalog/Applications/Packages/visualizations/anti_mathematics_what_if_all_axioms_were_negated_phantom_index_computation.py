def phantom_index(n, rel):
    assigned = [False] * n
    num_classes = 0
    for i in range(n):
        if assigned[i]: continue
        num_classes += 1
        for j in range(i+1, n):
            if not assigned[j] and all(rel[x][i] == rel[x][j] for x in range(n)):
                assigned[j] = True
        assigned[i] = True
    return n - num_classes