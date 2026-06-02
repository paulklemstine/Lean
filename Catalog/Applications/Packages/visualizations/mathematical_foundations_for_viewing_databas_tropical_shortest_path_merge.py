def tropical_merge(n, weights, error_rates):
    import math, heapq
    edges = sorted(((-weights[i][j]*math.log(1-error_rates[i][j])), i, j)
                   for i in range(n) for j in range(i+1,n)
                   if weights[i][j] > 0 and 0 < error_rates[i][j] < 1)
    parent = list(range(n))
    def find(x):
        while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
        return x
    mst = []
    for cost, i, j in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj; mst.append((cost, i, j))
    return sum(c for c,_,_ in mst), mst