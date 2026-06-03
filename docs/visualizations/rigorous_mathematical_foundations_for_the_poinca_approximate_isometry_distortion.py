def distortion(points_x, f):
    D_x = squareform(pdist(points_x))
    mapped = np.array([f(p) for p in points_x])
    D_y = squareform(pdist(mapped))
    return max(abs(D_y[i,j]-D_x[i,j]) for i in range(len(points_x)) for j in range(i+1,len(points_x)))