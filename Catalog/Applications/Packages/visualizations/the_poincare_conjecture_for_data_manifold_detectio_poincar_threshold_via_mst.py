def poincare_threshold_fast(X):
    from scipy.spatial.distance import pdist, squareform
    from scipy.sparse.csgraph import minimum_spanning_tree
    D = squareform(pdist(X))
    mst = minimum_spanning_tree(D)
    return float(mst.max())