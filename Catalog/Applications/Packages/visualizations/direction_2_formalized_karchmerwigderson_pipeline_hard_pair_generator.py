def generate_hard_pairs(n):
    path = {i*n+(i+1) for i in range(n-1)}
    return [(path, path - {p*n+p+1}, p*n+p+1) for p in range(n-1)]