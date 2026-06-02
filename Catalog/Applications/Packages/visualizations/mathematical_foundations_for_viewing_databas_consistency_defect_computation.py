def consistency_defect(values):
    n = len(values)
    return sum((values[j] - values[i])**2 for i in range(n) for j in range(n))