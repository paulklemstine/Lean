def seq_compose_query(p1, p2, n):
    return any(p1(a) and p2(n - a) for a in range(n + 1))