def cantor_ifs_iterate(c=1/3, depth=8):
    intervals = [(0.0, 1.0)]
    for _ in range(depth):
        new = []
        for a, b in intervals:
            new.append((c*a, c*b))
            new.append((c*a + (1-c), c*b + (1-c)))
        intervals = new
    return intervals