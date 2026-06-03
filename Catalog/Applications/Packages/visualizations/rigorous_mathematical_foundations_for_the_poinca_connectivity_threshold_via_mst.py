def connectivity_threshold(points):
    n = len(points)
    D = squareform(pdist(points))
    weights = sorted(set(D[i,j] for i in range(n) for j in range(i+1,n)))
    lo, hi = 0, len(weights)-1
    while lo < hi:
        mid = (lo+hi)//2
        if connected(n, rips_graph(points, weights[mid])): hi = mid
        else: lo = mid+1
    return weights[lo]