def greedy_rota_solve(bases, max_iter=10000):
    n = len(bases)
    perms = [list(range(n)) for _ in range(n)]
    for _ in range(max_iter):
        current_def = total_deficiency(bases, perms)
        if current_def == 0:
            return perms
        improved = False
        for i in range(n):
            for a in range(n):
                for b in range(a + 1, n):
                    perms[i][a], perms[i][b] = perms[i][b], perms[i][a]
                    new_def = total_deficiency(bases, perms)
                    if new_def < current_def:
                        improved = True
                        break
                    else:
                        perms[i][a], perms[i][b] = perms[i][b], perms[i][a]
                if improved: break
            if improved: break
        if not improved: return None
    return None