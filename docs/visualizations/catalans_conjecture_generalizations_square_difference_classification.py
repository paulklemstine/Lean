def classify_sq_diff(k, max_val=10000):
    solutions = []
    for d in range(1, k + 1):
        if k % d == 0:
            s = k // d
            if (d + s) % 2 == 0:
                x = (d + s) // 2
                y = (s - d) // 2
                if x >= 2 and y >= 2:
                    solutions.append((x, y))
    return solutions