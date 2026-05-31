def compute_persistence_intervals(dist_matrix):
    n = dist_matrix.shape[0]
    edges = sorted((dist_matrix[i,j], i, j) for i in range(n) for j in range(i+1, n))
    parent = list(range(n))
    rank = [0] * n
    birth = [0.0] * n
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry: return False
        if rank[rx] < rank[ry]: rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]: rank[rx] += 1
        return True
    intervals = []
    for dist, i, j in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            younger = rj if birth[ri] <= birth[rj] else ri
            intervals.append((birth[younger], dist))
            union(i, j)
    return intervals