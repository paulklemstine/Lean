def coboundary_norm(dbs, n_rows, n_cols):
    total = 0
    for i in range(len(dbs)):
        for j in range(len(dbs)):
            for r in range(n_rows):
                for c in range(n_cols):
                    v1, v2 = dbs[i].get((r,c)), dbs[j].get((r,c))
                    if v1 is not None and v2 is not None and v1 != v2:
                        total += 1
    return total