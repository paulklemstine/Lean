def rips_graph(points, epsilon):
    n = len(points)
    D = squareform(pdist(points))
    return [(i, j) for i in range(n) for j in range(i+1, n) if D[i,j] <= epsilon]