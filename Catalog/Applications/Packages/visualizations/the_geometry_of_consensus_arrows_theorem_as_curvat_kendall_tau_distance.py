def kendall_distance(r1, r2):
    n = len(r1)
    count = 0
    for i in range(n):
        for j in range(i+1, n):
            a, b = r1[i], r1[j]
            if r2.index(a) > r2.index(b):
                count += 1
    return count