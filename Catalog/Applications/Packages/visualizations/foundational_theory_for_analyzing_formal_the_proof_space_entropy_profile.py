def entropy_profile(G, v, n):
    sizes = G.ball_growth_profile(v, n)
    return [np.log(sizes[k+1]/sizes[k]) if sizes[k]>0 else 0 for k in range(n)]