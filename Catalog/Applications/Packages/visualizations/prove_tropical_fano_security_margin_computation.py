def security_margin(points, lines):
    D = [[trop_defect(l, p) for l in lines] for p in points]
    I = [[d == 0 for d in row] for row in D]
    non_inc = [D[i][j] for i in range(len(D)) for j in range(len(D[0])) if not I[i][j]]
    return min(non_inc) if non_inc else float('inf')